#!/usr/bin/env python3
"""SUPERSEDED by dass-resolve.py.  Kept for the record: it explains the
defect and it is the measurement dass-resolve.py had to beat.  Applying
this merge on top of a dass-resolve.py link changes 318 halfwords in G16
and not one scored section, because dropping the modules that were never
loaded here fixes the same relocations at their source.

Resolve a configuration's CROSS-PHASE relocations, which one link cannot.

    dass-xphase.py <build-tree> <config> <concard-root>

WHAT IS BROKEN WITHOUT THIS

FIOADCNS and FIOADCCL are resident tables of external addresses -- they sit at
the same place in all eight configurations -- and they hold the addresses of
display pages that live in OTHER phases.  A configuration-at-a-time link has
nowhere to get those addresses: `--external-syms` supplies only the sections
THIS configuration's DASS index names, so lnk101 appends the rest past the end
of the image and bakes a truncated address into every reference.  That is 458
wrong halfwords in S2 and the largest single defect in every configuration.

WHY THE OBVIOUS FIXES DO NOT WORK, ALL MEASURED

  * Linking with a COMBINED external-syms -- this configuration's index plus
    the addresses the other seven agree on -- does fix the tables outright, but
    the borrowed sections then EMIT THEIR CONTENT at those addresses and
    overwrite what this configuration really holds: S2 falls from 867 exact to
    552.  Ordering the foreign modules first barely helps; the clobber is by
    placement, not by write order.
  * Dropping the foreign modules from the link instead loses their symbol
    DEFINITIONS -- unresolved relocations go from 283 to 992 -- because
    --external-syms places sections but does not define the entry points inside
    them, and it is entry points these tables reference.
  * `lnk101 -D SYM=addr` does not help either: the defining module IS linked,
    merely placed past the image, so the module's definition wins and the
    override is ignored.

WHAT WORKS

Link twice and take each halfword from the link that is right about it:

    A   the normal link          content correct, cross-phase addresses wrong
    B   combined external-syms   cross-phase addresses correct, content clobbered

then copy from B ONLY the relocation sites whose symbol A placed past the end
of the image -- the ones A demonstrably could not resolve.  Everything else
stays as A had it.

The restriction is the whole point.  Taking B's value at EVERY relocation site
imports B's clobbered content and costs more than it gains: S2 goes 867 -> 624.
Restricted to past-the-image symbols it is 867 -> 879, and FIOADCNS/FIOADCCL
drop to zero differing halfwords.

Measured over all eight configurations, on uncontested genuinely-loaded CSECTs
with the dump's own post-build changes and never-printed fields excused:
7320/8292 (88.3%) -> 7404/8292 (89.3%), every configuration improved.
"""

import json, io, os, struct, subprocess, sys, collections
from dasspfs import pfsDir

IMAGE_HW = 330394
CONFIGS = {"SSW": (), "G16": (3, 4), "G2": (3, 5), "G3": (3, 6), "S2": (14, 15),
           "P9": (9, 12), "G8": (3, 7), "G9": (3, 8, 18)}


def combined_syms(mafgen, cfg, out):
    """This configuration's index, plus every section it does NOT place taken
    from the others -- but only where they AGREE.  979 names sit at different
    addresses in different configurations; those are overlay alternatives
    belonging to other phases and are left out rather than guessed at."""
    A = {c: json.load(io.open("%s/augmented-%s.json" % (mafgen, c)))
         for c in CONFIGS}
    mine = dict(A[cfg])
    elsewhere = collections.defaultdict(set)
    for c, d in A.items():
        if c == cfg:
            continue
        for n, g in d.items():
            if n not in mine:
                elsewhere[n].add((g["start"], g["end"]))
    added = ambiguous = 0
    for n, v in elsewhere.items():
        if len(v) == 1:
            s, e = v.pop()
            mine[n] = {"start": s, "end": e}
            added += 1
        else:
            ambiguous += 1
    json.dump(mine, io.open(out, "w"))
    return len(A[cfg]), added, ambiguous


def halfwords(path):
    b = io.open(path, "rb").read()
    return list(struct.unpack(">%dH" % (len(b) // 2), b))


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__.strip().split("\n")[2].strip())
    tree, cfg, root = sys.argv[1], sys.argv[2], sys.argv[3]
    pfs = pfsDir()
    mafgen = os.path.join(pfs, "mafgen")
    binp = os.environ.get("LNK101_BIN",
                          os.path.expanduser("~/donschmidt/nsts-sdl-dps/build/bin"))
    comb = os.path.join(tree, "link", "combined-%s.json" % cfg)
    own, added, amb = combined_syms(mafgen, cfg, comb)
    print("%s: own %d + %d borrowed, %d ambiguous left out" % (cfg, own, added, amb))

    r = subprocess.run(
        [os.path.join(binp, "lnk101"), "@link/objlist-%s.txt" % cfg,
         "-L", "lib/runtime/RUN", "-L", "lib/runtime/ZCON",
         "--external-syms", comb, "--concard", "CON80",
         "--concard-root", root, "--allow-undefined",
         "-o", "link/%s-c.fcm" % cfg,
         "--json-symbols", "link/%s-c-symbols.json" % cfg],
        cwd=tree, capture_output=True, text=True)
    if not os.path.exists(os.path.join(tree, "link", "%s-c.fcm" % cfg)):
        sys.exit("the combined link produced nothing:\n" + (r.stderr or "")[-800:])

    d = json.load(io.open("%s/link/%s-symbols.json" % (tree, cfg)))
    placed = {s["name"]: s["address"] for s in d["symbols"]}
    A = halfwords("%s/link/%s.fcm" % (tree, cfg))
    B = halfwords("%s/link/%s-c.fcm" % (tree, cfg))
    merged, sites, patched = list(A), 0, 0
    for x in d["relocations"]:
        # `targetName` is the SYMBOL the site references; `symbol` is only a
        # rendering of where this link RESOLVED it, as "<section>+<hex>".  The
        # two disagree exactly when the resolution is wrong, which is the case
        # this tool exists to fix, so testing `symbol` silently skips them.
        # FIOCBLKS+186 references TFIVFAB1, placed at 430759 -- past the image
        # and in need of patching -- while its `symbol` reads "#PCD0020+261",
        # whose section sits at 168006 and looks perfectly fine.
        name = x.get("targetName") or x["symbol"].split("+")[0]
        if placed.get(name, 0) < IMAGE_HW:
            continue                       # this link resolved it; leave it be
        sites += 1
        for a in (x["address"], x["address"] + 1):
            if a < len(merged) and a < len(B) and merged[a] != B[a]:
                merged[a] = B[a]
                patched += 1
    out = "%s/link/%s-x.fcm" % (tree, cfg)
    io.open(out, "wb").write(b"".join(struct.pack(">H", v) for v in merged))
    print("  %d relocation sites reference a symbol placed past the image; "
          "%d halfwords taken from the combined link" % (sites, patched))
    print("  wrote %s" % out)


if __name__ == "__main__":
    main()
