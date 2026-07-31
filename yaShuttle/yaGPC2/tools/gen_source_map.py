#!/usr/bin/env python3
"""gen_source_map.py -- builds a JSON address -> HAL/S-source-statement map
for yaGPC2's --debug mode (Stage 3), from a HALSFC compile's plain-text
pass1.rpt/pass2.rpt reports plus the linker's -lnk101.json section table.

Why text reports instead of the SDF binary format debugger-planner.md
originally targeted: an earlier pass of this tool tried to read the SDF's
per-statement SRN (Statement Reference Number) field and found it came
back all-blank -- turns out that's not a toolchain gap, just this
script asking the wrong question. SRN comes from columns 73-78 of the
HAL/S source card image, an optional field the test source here simply
never had characters in; and even when present, SRN is a poor statement
identifier since it isn't required to be unique. The number that's
actually universal is the HAL/S *statement number*: a HAL/S statement's
1-based position in the SDF's own `statementIndexTable` (equivalently,
the SDF "member" restarts numbering at 1 per file) -- and that's exactly
the number immediately before "M|" on each pass1.rpt listing line (the
*only* number there, unless the source actually has SRN data in columns
73-78, in which case that appears too, to its left -- see parse_pass1()),
which this tool was already reading correctly under the wrong name.
Renamed "srn" -> "stmt" throughout accordingly; no logic changed beyond
also handling a leading SRN column when present. pass1.rpt/pass2.rpt
remain the data source (plain text, no cmem/sdf/sdfpkg dependency
needed) -- they already contain everything needed: full source text per
statement in
pass1.rpt; statement-start markers "ST#N EQU *" interleaved with the
CSECT-relative code addresses in pass2.rpt (that `N` is the same
statement number).

Must be compiled without NOTABLES for pass2.rpt's per-statement "ST#N EQU
*" markers to appear (same TABLES-vs-NOTABLES finding debugger-planner.md
made for SDF generation -- this project's usual --parms sweep convention
always includes NOTABLES, so a debug-target compile needs its own
invocation without it; see test/fixtures/build_hal_fixtures.sh for the
normal convention this diverges from).

A linked memory image is, in general, the result of linking many
separately-compiled HAL/S units (a program plus the procedures/functions
it calls, each its own HALSFC compile) -- so this tool takes one
repeatable --unit per compiled unit, all resolved against the same
shared --lnk101 (one linked image, one output covering every unit).

--unit optionally takes a third, HALMAT-file path (MODULE=PASS1:PASS2:
HALMAT_FILE) for yaGPC2's --debug 'halmat on' HAL/S-statement -> HALMAT-
instruction-number display -- pass whichever of optmat.bin (preferred:
what Phase 2/ASM101 actually generates object code from) or halmat.bin
(pre-optimization fallback, e.g. a --no-opt compile) the caller finds.
This is unrelated to, and much simpler than, the SDF-embedded-HALMAT
format modules/sdf/sdf/sdf.py's own docstring discusses and declines to
parse: it works directly off the raw HALMAT file every compile already
produces (never gated behind SDF's own HALMAT parm), via 'yaHALMAT2
--disasm', reusing that tool's own already-correct SMRK-based statement
correlation (see parse_halmat_offsets()) rather than re-deriving it from
SDF's statement-scoped, SMRK-stripped storage, which does not actually
retain enough information to reconstruct the original word offsets.

Usage:
    gen_source_map.py --unit HELLO=pass1.rpt:pass2.rpt \\
        --lnk101 foo-lnk101.json -o foo.srcmap.json

    # Multi-unit; hundreds of --unit flags can exceed a shell's command-
    # line length limit, so any/all options can instead come from a
    # file, one flag (or a "--flag value" pair) per line:
    gen_source_map.py @build.args -o foo.srcmap.json
    # where build.args contains lines like:
    #   --unit 176-P=176-P.pass1.rpt:176-P.pass2.rpt
    #   --unit 176.1-READ_ACC=176.1-READ_ACC.pass1.rpt:176.1-READ_ACC.pass2.rpt
    #   --lnk101 176-P-lnk101.json
"""
import argparse
import json
import re
import shlex
import subprocess
import sys


def parse_pass1(path):
    """Returns {stmt: [source_text_line, ...]} -- a statement may span
    multiple physical listing lines, and not just the "M|" (Main) lines
    a first version of this tool captured exclusively: HAL/S source that
    uses subscripts or exponents (matrix/array element references,
    "**") gets typeset across up to three aligned physical lines -- "E|"
    (Exponent, printed above) and "S|" (Subscript, printed below) lines
    besides the "M|" line itself. Each captured line keeps its own "X|"
    tag verbatim (rather than stripping it) so a reader can still tell a
    main line from an exponent/subscript line once it's re-displayed
    outside the fixed-column layout that made the distinction visually
    obvious in the original report.

    pass1.rpt also has "C|" (Comment) and "D|" (the DEBUG pragma) lines,
    which are deliberately *not* captured here even though they're
    typeset the same way E|/S| are: they aren't HAL/S statements at all
    (a comment is discarded entirely by the compiler; DEBUG is a
    directive, not executable source), so they have no business being
    shown as part of one. They fall through untouched to the same
    "unrecognized line" handling a page header/footer gets, below.

    The line format is "[SRN ]STMT M|SOURCE_TEXT_PADDED|SCOPE" for a
    Main line, or "     X|SOURCE_TEXT_PADDED|[SCOPE]" (no statement
    number of its own) for an Exponent/Subscript line -- matched on the
    LAST '|' rather than the first, since HAL/S source can itself
    contain '|' characters (the '||' string-concatenation operator). The
    leading SRN (Statement Reference Number, from source columns 73-78)
    is present only when the HAL/S source actually populates those
    columns -- e.g. "000010    1 M|..." rather than "          1 M|..."
    -- and is always the statement number's own decimal value, so the
    optional leading group below only ever needs to consume one extra
    digit run, not a specific width or format. SRN is never used as the
    statement identifier here even when present: it isn't required to be
    unique, unlike the *statement number* (this capture group), which is
    always a HAL/S statement's 1-based position in the SDF's
    statementIndexTable and is what pass2.rpt's "ST#N" markers key off
    of too.

    E|/S| lines carry no statement number of their own, so which
    statement they belong to has to be inferred from position: an E|
    line is typeset *above* the M| line it decorates (an exponent sits
    above its base), so when one directly follows a blank line (or a
    page break, or a C|/D| line) it's attached to whichever M| line
    comes *next*. An S| line is typeset *below* its M| line, so when one
    directly follows an M| line (or another such trailing annotation, no
    blank in between) it's attached to that *preceding* statement
    instead. A blank line or anything unrecognized (page headers/
    footers, C|/D| lines) resets this so a fresh run of annotation lines
    is re-classified from scratch -- confirmed against a real pass1.rpt
    (108-EXAMPLE_5.hal) where a lone "E|" line sits between two
    statements' M| lines and, per this rule, correctly attaches to the
    following one rather than the preceding one."""
    m_re = re.compile(r"^\s*(?:\d+\s+)?(\d+)\s+M\|")
    tag_re = re.compile(r"^\s*([ES])\|")

    def extract(rest):
        close = rest.rfind("|")
        return rest[:close].rstrip() if close >= 0 else rest.rstrip()

    statements = {}
    current_stmt = None
    pending = []  # E|/S| lines not yet attached, waiting for the next M| line
    mode = None  # 'trailing' right after an M| line (or another trailing line); else None
    with open(path, "r", errors="replace") as f:
        for line in f:
            if not line.strip():
                mode = None
                continue
            m = m_re.match(line)
            if m:
                stmt = int(m.group(1))
                bucket = statements.setdefault(stmt, [])
                bucket.extend(pending)
                pending = []
                bucket.append("M|" + extract(line[m.end():]))
                current_stmt = stmt
                mode = "trailing"
                continue
            tm = tag_re.match(line)
            if tm:
                tag = tm.group(1)
                text = tag + "|" + extract(line[tm.end():])
                if mode == "trailing" and current_stmt is not None:
                    statements[current_stmt].append(text)
                else:
                    pending.append(text)
                    mode = "pending"
                continue
            mode = None  # unrecognized line (page header/footer, C|/D|, etc.) -- treat as a boundary
    return statements


def parse_pass2(path):
    """Returns [(csectName, offset, stmt), ...] in file order.

    "ST#N EQU *" markers are emitted wherever the assembler happens to be
    when it reaches statement N's boundary, which is not always inside a
    *code* CSECT -- e.g. a zero-code DECLARE statement's marker can land
    in the middle of a literal/data CSECT the compiler interleaved into
    the listing, and the very first marker can even precede any CSECT
    line at all. A single compile can also have more than one code
    CSECT (e.g. a HAL/S PROGRAM with an internal PROCEDURE compiles to
    two, conventionally named "$0NAME" and "A1NAME") and can bounce
    between a code CSECT and a data one and back several times -- so
    this can't be reduced to "one fixed target CSECT name" the way an
    earlier version of this function assumed.

    Which CSECTs are "code" is deliberately *not* determined by name
    (confirmed, by reading lnk101's own placement rule in
    ~/donschmidt/nsts-sdl-dps/src/lnk101/linker.py's _ZONE_BY_PREFIX,
    that this is subtler than a prefix guess: e.g. "#CREADAC" starts
    with "#" like the data CSECTs do, but is actually code because CODE
    is the *default* zone when no data/ZCON prefix matches -- a rule
    that lives in someone else's actively-developed repo and could
    drift). Instead: every real instruction line pass2.rpt prints
    carries a "TIME: N.NN" annotation (see src/timing.c's own porting
    notes for the same annotation) and a DC (data) pseudo-op line never
    does, so a CSECT occurrence is classified as code by scanning its
    own lines for that annotation -- self-contained within pass2.rpt,
    no dependency on CSECT-naming conventions at all.

    Two passes: first splits the file into CSECT-bounded "runs" (each
    with its own name, its own starting offset from the CSECT line
    itself, and an isCode flag), tagging each "ST#N EQU *" marker with
    the run it falls in (run index -1 for markers before any CSECT line
    at all). Second walks the runs in order, buffering markers seen in
    a non-code run and binding them -- to *that run's own starting
    offset* -- as soon as a code run is entered, since that's the
    address execution actually reaches next; not discarded, or a
    statement's source line would appear to "linger" past code that's
    really implementing a later statement (observed directly for a
    WRITE statement whose zero-code neighbors' markers fell inside a
    data CSECT). Resuming can land in a *different* code CSECT than
    where execution left off (e.g. buffered while in a data CSECT
    between two different-named code CSECTs)."""
    csect_re = re.compile(r"^([0-9A-Fa-f]*)\s+(\S+)\s+CSECT\b")
    stmt_re = re.compile(r"^([0-9A-Fa-f]+)\s+ST#(\d+)\s+EQU\s+\*")

    runs = []  # [{"name":..., "offset0":..., "isCode": bool}, ...]
    markers = []  # [(runIndex, offset, stmt), ...] in file order
    current_run = -1
    with open(path, "r", errors="replace") as f:
        for line in f:
            m = csect_re.match(line)
            if m:
                loc_str, name = m.group(1), m.group(2)
                runs.append({"name": name, "offset0": int(loc_str, 16) if loc_str else 0, "isCode": False})
                current_run = len(runs) - 1
                continue
            if current_run >= 0 and " TIME:" in line:
                runs[current_run]["isCode"] = True
            m = stmt_re.match(line)
            if m:
                markers.append((current_run, int(m.group(1), 16), int(m.group(2))))

    entries = []
    pending_stmts = []
    mi = 0
    while mi < len(markers) and markers[mi][0] == -1:
        pending_stmts.append(markers[mi][2])
        mi += 1
    for run_idx, run in enumerate(runs):
        if run["isCode"] and pending_stmts:
            entries.extend((run["name"], run["offset0"], stmt) for stmt in pending_stmts)
            pending_stmts = []
        while mi < len(markers) and markers[mi][0] == run_idx:
            _, offset, stmt = markers[mi]
            if run["isCode"]:
                entries.append((run["name"], offset, stmt))
            else:
                pending_stmts.append(stmt)
            mi += 1
    return entries


class ArgParser(argparse.ArgumentParser):
    """Splits each line of an "@file" argument (see fromfile_prefix_chars
    below) as a normal shell-style token sequence (shlex), instead of
    argparse's default of one whole token per line -- so a units file
    for a large multi-unit link can hold readable "--unit MODULE=..."
    lines instead of forcing each flag and its value onto separate
    lines."""

    def convert_arg_line_to_args(self, arg_line):
        return shlex.split(arg_line, comments=True)


def parse_unit_spec(spec):
    """"--unit" values look like "MODULE=PASS1_PATH:PASS2_PATH" or
    "MODULE=PASS1_PATH:PASS2_PATH:HALMAT_FILE" (see module docstring).
    Returns (module, pass1_path, pass2_path, halmat_path_or_None), or
    exits with a usage error."""
    module, eq, rest = spec.partition("=")
    pass1_path, colon, rest = rest.partition(":")
    pass2_path, colon2, halmat_path = rest.partition(":")
    if not eq or not colon or not module or not pass1_path or not pass2_path:
        sys.exit(f"error: --unit {spec!r} must be of the form MODULE=PASS1_PATH:PASS2_PATH[:HALMAT_FILE]")
    return module, pass1_path, pass2_path, (halmat_path if colon2 else None)


def run_yahalmat2_disasm(halmat_path):
    """Returns 'yaHALMAT2 --disasm halmat_path's stdout, or None (after
    printing a warning) if yaHALMAT2 isn't available or fails -- HALMAT-
    instruction-number display is an opt-in debugger nicety, not a hard
    requirement, matching this tool's other non-fatal fallbacks."""
    try:
        result = subprocess.run(
            ["yaHALMAT2", "--disasm", halmat_path],
            capture_output=True,
            text=True,
            check=True,
        )
    except (OSError, subprocess.CalledProcessError) as e:
        detail = e.stderr if isinstance(e, subprocess.CalledProcessError) and e.stderr else str(e)
        print(
            f"warning: 'yaHALMAT2 --disasm {halmat_path}' failed ({detail}) "
            "-- continuing without HALMAT instruction numbers",
            file=sys.stderr,
        )
        return None
    return result.stdout


def parse_halmat_offsets(disasm_text):
    """Returns {stmt: [word_offset, ...]} (offsets in ascending order),
    parsed from 'yaHALMAT2 --disasm's own text output -- reusing that
    tool's already-correct, already-tested HALMAT decoding rather than
    re-implementing it, the same "parse an existing tool's report" style
    this whole script already uses for pass1.rpt/pass2.rpt.

    Every instruction line looks like "#N 0xOOO MNEM  numop=... ; comment"
    (N is the word offset -- see yaShuttle/yaHALMAT2/src/disasm.c's own
    format string). A "SMRK" (HALMAT Statement Marker) instruction's own
    operand -- printed on the following "[0] data=0xNNNN(NNNN) ..." line
    -- is the HAL/S statement number it closes (confirmed against
    yaShuttle/yaHALMAT2/src/debug.c's find_word_index_for_stmt(), which
    matches on exactly this operand). Verified by hand, statement by
    statement, against a real compile: the instructions strictly between
    the previous SMRK (its own word offset + 2, since SMRK is always a
    1-operand/2-word instruction) and this SMRK belong to the statement
    it closes -- e.g. a statement with no code of its own (a plain
    DECLARE) has two SMRKs back to back, no instructions between them.
    The compiler's own leading PXRC/MDEF header instructions (before any
    SMRK at all -- a record header and the program-definition header,
    never any statement's own content) are excluded by mnemonic, not
    attributed to statement 1."""
    HEADER_MNEMONICS = {"PXRC", "MDEF"}
    instr_re = re.compile(r"^#(\d+)\s+0x[0-9A-Fa-f]+\s+(\S+)")
    operand_re = re.compile(r"^\s*\[0\]\s+data=0x([0-9A-Fa-f]+)")

    stmt_offsets = {}
    pending = []
    lines = disasm_text.splitlines()
    for i, line in enumerate(lines):
        m = instr_re.match(line)
        if not m:
            continue
        offset, mnemonic = int(m.group(1)), m.group(2)
        if mnemonic in HEADER_MNEMONICS:
            continue
        if mnemonic != "SMRK":
            pending.append(offset)
            continue
        stmt = None
        if i + 1 < len(lines):
            om = operand_re.match(lines[i + 1])
            if om:
                stmt = int(om.group(1), 16)
        if stmt is not None:
            stmt_offsets.setdefault(stmt, []).extend(pending)
        pending = []
    return stmt_offsets


def build_unit(module, pass1_path, pass2_path, halmat_path, sections_by_name):
    """Returns {"module":..., "statements":[...], "addresses":[...],
    "codeRanges":[...]} for one compiled unit -- each statement entry
    additionally gets a "halmat" field (list of word offsets, see
    parse_halmat_offsets()) when halmat_path is given and that statement
    has any. Resolves
    parse_pass2()'s (csectName, offset) pairs to absolute linked
    addresses via sections_by_name (looked up directly by CSECT name --
    a real linked CSECT name is already unique, so no module cross-check
    is needed here). Returns None (after printing a warning) if the unit
    has no code markers at all -- expected and harmless for a COMPOOL/
    template-only compile (e.g. a shared STRUCTURE declaration with no
    executable statements of its own, confirmed harmless to still link
    in as an empty section): main() drops these from the output rather
    than treating them as a hard error, since a real multi-unit build
    legitimately mixes such units in with ones that have real code.

    codeRanges records the [start, end) byte range of every CSECT that
    actually contributed an address entry -- a unit's code isn't always
    one contiguous range (e.g. a HAL/S PROGRAM with an internal
    PROCEDURE compiles to two separate code CSECTs) -- so the C side can
    reject a lookup address that falls outside all of them, rather than
    trusting the address table's binary search alone: a linker-
    generated section that isn't backed by any HAL/S statement (e.g. the
    entry trampoline) can still be tagged with this same module's name
    while sitting far outside its actual mapped code, which would
    otherwise make the "nearest address <= target" search spuriously
    return whichever statement happens to have the highest address."""
    statements = parse_pass1(pass1_path)
    entries = parse_pass2(pass2_path)
    if not entries:
        print(
            f"warning: no 'ST#N EQU *' code markers found in {pass2_path} for module {module!r} "
            "-- skipping (expected for a COMPOOL/template-only compile; "
            "otherwise, was this compiled without NOTABLES?)",
            file=sys.stderr,
        )
        return None

    addr_to_stmt = {}
    code_ranges = {}  # csectName -> (start, end)
    for csect_name, offset, stmt in entries:
        sect = sections_by_name.get(csect_name)
        if sect is None:
            sys.exit(f"error: CSECT {csect_name!r} (from {pass2_path}, module {module!r}) not found in --lnk101")
        addr_to_stmt[sect["address"] + offset] = stmt  # last one wins for a shared (zero-code-statement) address
        code_ranges[csect_name] = (sect["address"], sect["address"] + sect["size"])

    halmat_offsets = {}
    if halmat_path:
        disasm_text = run_yahalmat2_disasm(halmat_path)
        if disasm_text is not None:
            halmat_offsets = parse_halmat_offsets(disasm_text)

    addresses = [{"addr": a, "stmt": s} for a, s in sorted(addr_to_stmt.items())]
    stmt_list = []
    for stmt, lines in sorted(statements.items()):
        entry = {"stmt": stmt, "lines": lines}
        if halmat_offsets.get(stmt):
            entry["halmat"] = halmat_offsets[stmt]
        stmt_list.append(entry)
    ranges = [{"start": start, "end": end} for start, end in sorted(code_ranges.values())]
    return {"module": module, "statements": stmt_list, "addresses": addresses, "codeRanges": ranges}


def main():
    ap = ArgParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        fromfile_prefix_chars="@",
    )
    ap.add_argument(
        "--unit",
        action="append",
        required=True,
        metavar="MODULE=PASS1_PATH:PASS2_PATH",
        help="one compiled unit's module name and its pass1.rpt/pass2.rpt paths; "
        "repeat for a multi-unit linked image",
    )
    ap.add_argument("--lnk101", required=True, help="lnk101's --json-symbols output")
    ap.add_argument("-o", "--output", required=True)
    args = ap.parse_args()

    with open(args.lnk101) as f:
        linked = json.load(f)
    sections_by_name = {sect["name"]: sect for sect in linked.get("sections", [])}

    units = [build_unit(*parse_unit_spec(spec), sections_by_name) for spec in args.unit]
    units = [u for u in units if u is not None]
    if not units:
        sys.exit("error: none of the given --unit compiles had any code markers -- nothing to write")

    with open(args.output, "w") as f:
        json.dump({"units": units}, f, indent=1)
    total_stmts = sum(len(u["statements"]) for u in units)
    total_addrs = sum(len(u["addresses"]) for u in units)
    print(f"Wrote {args.output}: {len(units)} unit(s), {total_stmts} statements, {total_addrs} address entries")


if __name__ == "__main__":
    main()
