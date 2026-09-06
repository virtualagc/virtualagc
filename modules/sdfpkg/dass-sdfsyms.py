#!/usr/bin/env python3
"""Symbol name -> offset within its CSECT, read from an sdfpkg.py report.

    dass-sdfsyms.py <report> [name-prefix]

WHY THIS EXISTS

The DASS listing names a CSECT's fields, but MAFGEN omits fields whose value is
all zero, so "declared by us and not named in the dump" is NOT evidence that the
original lacked a variable.  That test cracked GSIABT and misleads on PGGPCF.
The SDF gives our own offsets outright, and comparing them against the offsets
the listing DOES print localises a layout difference without depending on
MAFGEN naming anything.

HOW THE REPORT IS SHAPED, AND THE TRAP IN IT

A symbol is a "First 8 characters of symbol name" line followed by a
SymbolDataCell holding field 10, the relative memory address, and -- only when
the name exceeds eight characters -- field 15, the continuation.  Field 15
comes AFTER field 10.  So a symbol cannot be emitted when its address is seen;
it has to be held until the next "First 8 characters" line or end of file.
Emitting at the address line drops every continuation and yields truncated
names: CSAS_PX for CSAS_PXT, CSAS_REM for CSAS_REMOTE_SCALING.

Two more things worth knowing.  The "relative" address is already the offset
within the CSECT -- do not add the local block's base to it; PGG_I reports 200
and the S2 dump has it at #DPGGPCF+200.  And the symbol class matters: class 4
is a Template, whose address means nothing, while class 1 is a Variable and is
a real allocation.  PGGPCF's seven CSAS_PDT_* symbols at offsets 244-250 are
class 1, which is what makes them the answer there rather than an artefact.
"""
import io, re, sys

FIRST = re.compile(r'First 8 characters of symbol name:.*"(.*)"')
CONT = re.compile(r'Continuation of symbol name:.*"(.*)"')
ADDR = re.compile(r'Relative memory address of symbol:\s*(-?\d+)')
CLASS = re.compile(r'Symbol class:\s*(\d+)')
CLASSNAME = re.compile(r'^\s+([A-Za-z][\w /]*)\s*$')


def symbols(path):
    """[(name, offset, class number, class name)], in report order."""
    out, cur, want_class = [], None, False

    def flush():
        if cur and cur["addr"] is not None:
            out.append((cur["name"].rstrip(), cur["addr"],
                        cur["cls"], cur["clsname"]))

    for line in io.open(path, errors="replace"):
        m = FIRST.search(line)
        if m:
            flush()
            cur = {"name": m.group(1), "addr": None,
                   "cls": None, "clsname": None}
            want_class = False
            continue
        if cur is None:
            continue
        m = ADDR.search(line)
        if m:
            cur["addr"] = int(m.group(1)); continue
        m = CONT.search(line)
        if m:
            cur["name"] = cur["name"].rstrip() + m.group(1); continue
        m = CLASS.search(line)
        if m:
            cur["cls"] = int(m.group(1)); want_class = True; continue
        if want_class:
            n = CLASSNAME.match(line.rstrip())
            if n:
                cur["clsname"] = n.group(1).strip()
            want_class = False
    flush()
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip().split("\n")[2].strip())
    pre = sys.argv[2] if len(sys.argv) > 2 else ""
    rows = [r for r in symbols(sys.argv[1]) if r[0].startswith(pre)]
    print("%-30s %6s  %s" % ("symbol", "offset", "class"))
    for n, a, c, cn in sorted(rows, key=lambda r: r[1]):
        print("%-30s %6d  %s (%s)" % (n, a, c, cn))


if __name__ == "__main__":
    main()
