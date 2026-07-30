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

Usage:
    gen_source_map.py --pass1 pass1.rpt --pass2 pass2.rpt \\
        --lnk101 foo-lnk101.json --module HELLO -o foo.srcmap.json
"""
import argparse
import json
import re
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


def parse_pass2(path, code_csect):
    """Returns [(offset, stmt), ...] in ascending-offset order.

    "ST#N EQU *" markers are emitted wherever the assembler happens to be
    when it reaches statement N's boundary, which is not always inside
    `code_csect` -- e.g. a zero-code DECLARE statement's marker can land
    in the middle of a literal/data CSECT the compiler interleaved into
    the listing (#DHELLO/#EHELLO-style), and the very first marker can
    even precede any CSECT line at all. Markers seen outside `code_csect`
    are buffered and bound to wherever `code_csect` next resumes (that
    CSECT line's own LOC field), since that's the address execution
    actually reaches next -- not discarded, or a statement's source line
    would appear to "linger" past code that's really implementing a
    later statement (observed directly for a WRITE statement whose
    zero-code neighbors' markers fell inside #DHELLO)."""
    csect_re = re.compile(r"^([0-9A-Fa-f]*)\s+(\S+)\s+CSECT\b")
    stmt_re = re.compile(r"^([0-9A-Fa-f]+)\s+ST#(\d+)\s+EQU\s+\*")
    in_code = False
    pending_stmts = []
    entries = []
    with open(path, "r", errors="replace") as f:
        for line in f:
            m = csect_re.match(line)
            if m:
                loc_str, name = m.group(1), m.group(2)
                in_code = name == code_csect
                if in_code and pending_stmts:
                    offset = int(loc_str, 16) if loc_str else 0
                    entries.extend((offset, stmt) for stmt in pending_stmts)
                    pending_stmts = []
                continue
            m = stmt_re.match(line)
            if not m:
                continue
            if in_code:
                entries.append((int(m.group(1), 16), int(m.group(2))))
            else:
                pending_stmts.append(int(m.group(2)))
    return entries


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--pass1", required=True, help="HALSFC's pass1.rpt")
    ap.add_argument("--pass2", required=True, help="HALSFC's pass2.rpt")
    ap.add_argument("--lnk101", required=True, help="lnk101's --json-symbols output")
    ap.add_argument("--module", required=True, help="HAL/S program/module name, e.g. HELLO")
    ap.add_argument("-o", "--output", required=True)
    args = ap.parse_args()

    with open(args.lnk101) as f:
        linked = json.load(f)
    code_csect = "$0" + args.module
    base = None
    size = None
    for sect in linked.get("sections", []):
        if sect.get("name") == code_csect:
            base = sect["address"]
            size = sect["size"]
            break
    if base is None:
        sys.exit(f"error: code section {code_csect!r} not found in {args.lnk101}")

    statements = parse_pass1(args.pass1)
    entries = parse_pass2(args.pass2, code_csect)
    if not entries:
        sys.exit(
            f"error: no 'ST#N EQU *' markers found for CSECT {code_csect!r} in {args.pass2} "
            "-- was this compiled without NOTABLES?"
        )

    addr_to_stmt = {}
    for offset, stmt in entries:
        addr_to_stmt[base + offset] = stmt  # last one wins for a shared (zero-code-statement) address

    addresses = [{"addr": a, "stmt": s} for a, s in sorted(addr_to_stmt.items())]
    stmt_list = [{"stmt": stmt, "lines": lines} for stmt, lines in sorted(statements.items())]

    out = {
        "module": args.module,
        "codeStart": base,
        "codeEnd": base + size,
        "statements": stmt_list,
        "addresses": addresses,
    }
    with open(args.output, "w") as f:
        json.dump(out, f, indent=1)
    print(f"Wrote {args.output}: {len(stmt_list)} statements, {len(addresses)} address entries")


if __name__ == "__main__":
    main()
