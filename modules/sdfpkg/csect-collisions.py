#!/usr/bin/env python3
'''Which sections must be withheld from a configuration's link, on positive
evidence rather than on absence from the memory map alone.

ABSENCE FROM THE MAP IS NOT ENOUGH.  dass-syms.py's own note records that
across the eight configurations 79 map-absent sections MATCH the dump, 59 of
them verifying content the --no-data patterns do not cover -- up to 477
halfwords in SSW's #DDCDDG3 -- so withholding every map-absent section throws
away real agreement.  Measured: it costs SSW 27 sections that were all OK.

THE COLLISION IS THE EVIDENCE.  A map-absent section that occupies the same
addresses as a section the map DOES place cannot both be there; the map says
which one is, and the other is overwriting it.  A map-absent section that
collides with nothing costs nothing to keep and may be verifying content.

Usage: collisions.py TABLE.json DASS.ASC > keep.txt
'''
import json, re, sys

MM = re.compile(r"^ [0-9A-F]{6}-[0-9A-F]{6}  (\S+)\s+\*\*\*\*")

table, dass = sys.argv[1], sys.argv[2]

placed = set()
for line in open(dass, errors="replace"):
    m = MM.match(line)
    if m and not m.group(1).startswith("-"):
        placed.add(m.group(1))

t = json.load(open(table))
spans = {}
for name, info in t.items():
    if not isinstance(info, dict):
        continue
    s, e = info.get("start"), info.get("end")
    if s is not None and e is not None:
        spans[name] = (s, e)

resident = sorted((s, e, n) for n, (s, e) in spans.items() if n in placed)
drop = []
for name, (s, e) in sorted(spans.items()):
    if name in placed:
        continue
    hit = [n for rs, re_, n in resident if rs <= e and s <= re_]
    if hit:
        drop.append((name, hit[:3]))

dropped = {n for n, _ in drop}
for name in sorted(spans):
    if name not in dropped:
        print(name)
# A name with no span in the table cannot be judged, so it is kept.
for name in sorted(set(t) - set(spans)):
    print(name)

print(f"{len(placed)} sections placed by the map, {len(spans)} with spans in "
      f"the table", file=sys.stderr)
print(f"{len(spans) - len(placed & set(spans))} are map-absent; "
      f"{len(drop)} of those COLLIDE with a placed section and are withheld:",
      file=sys.stderr)
for name, hit in drop:
    print(f"   {name:10} overlaps {hit}", file=sys.stderr)
