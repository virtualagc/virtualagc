#!/usr/bin/env python3
"""Per-phase external symbol tables, so a phase links at the REAL addresses.

    dass-phaseextsyms.py <build-tree>

writes <tree>/phase/extsyms-NN.json for each phase, in the same shape as
augmented-<cfg>.json, for lnk101's --external-syms.

WHY.  Without --external-syms, lnk101 lays sections out by its own CON80
BANK/OVERLAY/INSERT program, and dass-link.sh's header records what that is
worth: con80build's own layout places 0 of 327 sections correctly, against 1243
of 1243 with --external-syms.  Measured over the phase links, 36.4% of
phase-placed sections (3332 of 9164) sat at an address the index does not give.
A phase image's content is relocated for whatever map it was laid out on, so
those 36.4% cannot be compared against the dump at index addresses at all --
which is why substituting phase content wholesale lost 572,965 halfwords.

WHY A PHASE CANNOT JUST BORROW ONE CONFIGURATION'S INDEX.  979 of 3875 sections
sit at different addresses in different configurations, because different
phases supply them: $0AIGDEU appears at 01464A, 020022 and 03365E.  But a phase
is loaded by a KNOWN set of configurations, and within that set its own sections
agree -- exactly, for every phase that only one configuration loads, and for all
but 92 of 924 (phase 2) and 34 of 669 (phase 3) of the shared ones.  A section
whose address is ambiguous across that set is left out rather than guessed at;
lnk101 then places it as before.

WHERE THE SECTION LIST COMES FROM, and why not from the phase links.
dass-phases.sh deletes PHASE*.lib, PHASE*.fcm and PHASE*.sym.json before it
starts, and must: each phase's .lib feeds later phases through --map-lib, so a
phase that fails or is skipped would otherwise leave the previous run's library
for later phases to map.  Reading those files here would make this run depend on
the last one, which is the staleness this codebase guards against everywhere
else.  The objlists that dass-phaselists.py has just written say what each phase
will contain, and csect-to-object says which sections each module supplies.
"""

import collections
import io
import json
import os
import sys

IPL = [10, 2, 13, 3]
GRT = {"G16": (3, 4), "G2": (3, 5), "G3": (3, 6), "G8": (3, 7),
       "G9": (3, 8, 18), "P9": (9, 12), "S2": (14, 15), "S4": (14, 16),
       "SSW": ()}


def main():
    tree = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1
                              else "~/pass-build/OI340700")
    mafgen = os.path.join(os.path.expanduser("~/workspace/PFS"), "mafgen")
    idx = {}
    for c in GRT:
        p = "%s/augmented-%s.json" % (mafgen, c)
        if os.path.exists(p):
            idx[c] = json.load(io.open(p))
    c2o = "%s/link/csect-to-object.json" % tree
    if not idx or not os.path.exists(c2o):
        print("  no index or csect-to-object; phases link unpinned")
        return 0
    o2c = {}
    for cs, ob in json.load(io.open(c2o)).items():
        o2c.setdefault(os.path.splitext(ob)[0], []).append(cs)

    loaders = collections.defaultdict(list)
    for c, g in GRT.items():
        if c not in idx:
            continue
        for ph in set(IPL) | set(g):
            loaders[ph].append(c)

    for ph in sorted(loaders):
        ol = "%s/phase/objlist-%02d.txt" % (tree, ph)
        if not os.path.exists(ol):
            continue
        out, ambiguous = {}, 0
        for line in io.open(ol):
            line = line.strip()
            if not line:
                continue
            mod = os.path.splitext(os.path.basename(line))[0]
            for n in o2c.get(mod, []):
                seen = {idx[c][n]["start"]: idx[c][n]
                        for c in loaders[ph] if n in idx[c]}
                if len(seen) == 1:
                    out[n] = list(seen.values())[0]
                elif len(seen) > 1:
                    ambiguous += 1
        json.dump(out, io.open("%s/phase/extsyms-%02d.json" % (tree, ph), "w"),
                  indent=2)
        print("  PHASE%02d: %d section(s) pinned%s"
              % (ph, len(out),
                 ", %d ambiguous left unpinned" % ambiguous if ambiguous else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
