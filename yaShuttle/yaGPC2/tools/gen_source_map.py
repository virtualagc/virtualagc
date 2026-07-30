#!/usr/bin/env python3
"""gen_source_map.py -- builds a JSON address -> HAL/S-source-statement map
for yaGPC2's --debug mode (Stage 3), from a HALSFC compile's plain-text
pass1.rpt/pass2.rpt reports plus the linker's -lnk101.json section table.

Why text reports instead of the SDF binary format debugger-planner.md
originally targeted: direct investigation found the SDF's per-statement
SRN (Statement Reference Number) field comes back all-blank from this
toolchain's HAL/S compiler port (modules/sdf + modules/sdfpkg parse it
fine -- the field itself is just never populated at compile time), which
makes the binary SDF route a dead end for now. pass1.rpt/pass2.rpt are
plain text, already contain everything needed (full source text per
statement in pass1.rpt; statement-start markers "ST#N EQU *" interleaved
with the CSECT-relative code addresses in pass2.rpt), and don't depend on
that unpopulated field at all.

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
    """Returns {srn: [source_text_line, ...]} -- a statement may span
    multiple physical listing lines (e.g. a label line plus the statement
    it labels, both tagged with the same SRN).

    The line format is "SRN M|SOURCE_TEXT_PADDED|SCOPE" with the source
    text padded to a fixed column -- matched on the LAST '|' rather than
    the first, since HAL/S source can itself contain '|' characters (the
    '||' string-concatenation operator)."""
    prefix_re = re.compile(r"^\s*(\d+)\s+M\|")
    statements = {}
    with open(path, "r", errors="replace") as f:
        for line in f:
            m = prefix_re.match(line)
            if not m:
                continue
            rest = line[m.end():]
            close = rest.rfind("|")
            if close < 0:
                continue
            srn = int(m.group(1))
            text = rest[:close].rstrip()
            statements.setdefault(srn, []).append(text)
    return statements


def parse_pass2(path, code_csect):
    """Returns [(offset, srn), ...] in ascending-offset order.

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
    pending_srns = []
    entries = []
    with open(path, "r", errors="replace") as f:
        for line in f:
            m = csect_re.match(line)
            if m:
                loc_str, name = m.group(1), m.group(2)
                in_code = name == code_csect
                if in_code and pending_srns:
                    offset = int(loc_str, 16) if loc_str else 0
                    entries.extend((offset, srn) for srn in pending_srns)
                    pending_srns = []
                continue
            m = stmt_re.match(line)
            if not m:
                continue
            if in_code:
                entries.append((int(m.group(1), 16), int(m.group(2))))
            else:
                pending_srns.append(int(m.group(2)))
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

    addr_to_srn = {}
    for offset, srn in entries:
        addr_to_srn[base + offset] = srn  # last one wins for a shared (zero-code-statement) address

    addresses = [{"addr": a, "srn": s} for a, s in sorted(addr_to_srn.items())]
    stmt_list = [{"srn": srn, "lines": lines} for srn, lines in sorted(statements.items())]

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
