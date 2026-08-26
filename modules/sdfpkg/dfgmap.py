#!/usr/bin/env python3
'''
Map a display compool's halfwords back to the .dfg statements that produced
them, and say what a DASS dump holds at each one.

DFG annotates everything it emits: a "C -- TEXT" line names the deck
statement the following halfwords come from, and "C - TEXT" lines explain
the individual field.  That mapping is the whole point of this script -- it
turns "these halfwords differ" into "this statement differs".

    dfgmap.py GEN.hal                        the annotated map
    dfgmap.py GEN.hal --at N [--count M]     just that window
    dfgmap.py GEN.hal --find HHHH,HHHH,...   where that sequence occurs
    dfgmap.py GEN.hal --dump F.fcm --address HEX
                                             compare against a memory image
                                             and name the differing statements
    dfgmap.py x --corpus DIR --find HHHH,...  which statement in ANY deck
                                             emits that sequence

TWO WORKFLOWS.  Going forwards, --dump says which of OUR statements the dump
disagrees with.  Going backwards -- the harder direction, and the reason this
exists -- --corpus --find takes halfwords FROM the dump and names the deck
statement that produces them, even when the deck they came from is one we do
not have.  DFG's output is regular enough for that to work: the same STAT
preamble, coordinate pairs and CHAR runs recur across every display, so a
sequence lifted from an unknown display is usually identifiable from the
decks we do have.

    $ dfgmap.py x --corpus hal/ --find 8471,9102
    CV1060    @41    XC = 5 | YC = 4
    $ dfgmap.py x --corpus hal/ --find E349,E945
    CS2020    @175   CHAR = (FIRE CMD)
'''
import re, sys, argparse, pathlib

HEXV = re.compile(r"HEX'([0-9A-Fa-f]{1,4})'")

def parse(path):
    """[(offset, value, statement, detail)] in declaration order.

    Declaration order is memory order within the COMPOOL, so the running
    count of emitted halfwords IS the offset into the CSECT."""
    stmt, detail, out, off = None, [], [], 0
    for raw in open(path, errors="replace"):
        line = raw.rstrip("\n")
        if line.startswith("C -- "):
            stmt, detail = line[5:].strip(), []      # a deck statement
            continue
        if line.startswith("C - "):
            detail.append(line[4:].strip())          # a field explanation
            continue
        if line.startswith("C ") or line.startswith("D "):
            # continuation of a wrapped statement comment, e.g. a long VPARM
            if stmt is not None and line[2:].strip() and not line[2:].strip().startswith("*"):
                stmt += " " + line[2:].strip()
            continue
        for m in HEXV.finditer(line):
            out.append((off, int(m.group(1), 16), stmt, tuple(detail)))
            off += 1
    return out

def hw_image(path):
    b = pathlib.Path(path).read_bytes()
    return [(b[i] << 8) | b[i + 1] for i in range(0, len(b) - 1, 2)]

def show(rows, dump=None, base=None, only_diff=False):
    last = None
    for off, val, stmt, detail in rows:
        if stmt != last:
            print(f"\n  {stmt or '(no statement)'}")
            for d in detail:
                print(f"      . {d}")
            last = stmt
        if dump is None:
            print(f"      +{off:<5} {val:04X}")
        else:
            i = base + off
            theirs = dump[i] if 0 <= i < len(dump) else None
            mark = "" if theirs == val else "   <-- DIFFERS"
            if only_diff and not mark:
                continue
            t = "----" if theirs is None else f"{theirs:04X}"
            print(f"      +{off:<5} ours={val:04X} dump={t}{mark}")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("hal")
    p.add_argument("--at", type=int)
    p.add_argument("--count", type=int, default=16)
    p.add_argument("--find")
    p.add_argument("--dump")
    p.add_argument("--address")
    p.add_argument("--only-diff", action="store_true")
    p.add_argument("--corpus", help="directory of generated .hal to search "
                                    "with --find, instead of one file")
    a = p.parse_args()
    if a.corpus and a.find:
        want = [int(x, 16) for x in re.split(r"[ ,]+", a.find.strip()) if x]
        found = 0
        for f in sorted(pathlib.Path(a.corpus).glob("*.hal")):
            rows = parse(f)
            vals = [r[1] for r in rows]
            for i in range(len(vals) - len(want) + 1):
                if vals[i:i + len(want)] == want:
                    stmts = []
                    for r in rows[i:i + len(want)]:
                        if not stmts or stmts[-1] != r[2]:
                            stmts.append(r[2])
                    print(f"{f.stem:<9} @{i:<5} {' | '.join(str(x) for x in stmts)}")
                    found += 1
        print(f"\n{found} occurrence(s) of the {len(want)}-halfword sequence")
        return
    rows = parse(a.hal)
    if a.find:
        want = [int(x, 16) for x in re.split(r"[ ,]+", a.find.strip()) if x]
        vals = [r[1] for r in rows]
        hits = [i for i in range(len(vals) - len(want) + 1)
                if vals[i:i + len(want)] == want]
        if not hits:
            print(f"{len(want)} halfword(s) not found in {a.hal}")
            return
        for h in hits:
            print(f"=== match at offset {h} ===")
            show(rows[h:h + len(want)])
        return
    if a.at is not None:
        rows = [r for r in rows if a.at <= r[0] < a.at + a.count]
    dump = base = None
    if a.dump:
        dump = hw_image(a.dump)
        base = int(a.address, 16)
    show(rows, dump, base, a.only_diff)

main()
