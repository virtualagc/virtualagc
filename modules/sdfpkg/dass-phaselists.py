#!/usr/bin/env python3
"""Per-phase object lists: exactly what each PHASE deck names, and nothing else.

MAP* decks are deliberately NOT descended into -- a MAP card is an earlier
phase mapped in, handled by lnk101's --map-lib, and pulling its modules into
this phase is what destroys cross-phase resolution (see dass-phases.sh)."""
import io, os, re, json, sys
T = sys.argv[1]; C = os.path.join(T, "CON80")
c2o = json.load(io.open(os.path.join(T, "link", "csect-to-object.json")))

def resolve(n):
    """An INCLUDE names a member, and not every member is one of our objects.

    SYSLIBL1 members were being dropped silently, because the name was looked up
    only in csect-to-object.json.  That is how SM2TAB's

        CHANGE  #PCSAINB(#PCS2INB)
        INCLUDE SYSLIBL1(#ESAFACQ)

    left phase 15 with no #PCS2INB at all: the CHANGE applies to the INCLUDE
    that follows it, lnk101 reads the card itself from --concard, but the member
    has to be in the list for the rename to have anything to rename.
    """
    o = os.path.join(T, "objects", c2o[n]) if n in c2o else None
    if o and os.path.exists(o):
        return o
    for libdir in ("SYSLIBL1",):
        q = os.path.join(T, libdir, n + ".obj")
        if os.path.exists(q):
            return q
    return None


def chain(top):
    seen, st, names = set(), [top], set()
    while st:
        x = st.pop()
        if x in seen or x.startswith("MAP") or not os.path.exists(os.path.join(C, x)):
            continue
        seen.add(x)
        for l in io.open(os.path.join(C, x), errors="replace"):
            b = l[:72]
            if b[:1] == "*": continue
            m = (re.match(r'\s+INCLUDE\s+CONCARDS?\((\w+)\)', b)
                 or re.match(r'\s+INCLUDE\s+([A-Z0-9]+)\s*$', b))
            if m: st.append(m.group(1)); continue
            p = b.split()
            if len(p) >= 2 and p[0] in ("INSERT", "RESERVE"): names.add(p[1])
            m = re.search(r'INCLUDE\s+\w+\(([^)]*)\)', b)
            if m: names.update(y.strip() for y in m.group(1).split(","))
            # A CHANGE renames a reference to a compool this phase must then
            # define.  lnk101 applies the rename and reports "Undefined
            # COMPOOL: #PCS2INB" -- its library search is on demand and does
            # not go looking for the name it has just renamed TO.  Naming the
            # member breaks the same deadlock change_includes() breaks one
            # level up.
            m = re.match(r'\s+CHANGE\s+(\S+?)\((\S+?)\)', b)
            if m: names.add(m.group(2))
    return names

os.makedirs(os.path.join(T, "phase"), exist_ok=True)
for p in ("01","02","03","04","05","06","07","08","09","10",
          "12","13","14","15","16","18","21","22"):
    if not os.path.exists(os.path.join(C, "PHASE" + p)): continue
    objs = sorted(filter(None, {resolve(n) for n in chain("PHASE" + p)}))
    io.open(os.path.join(T, "phase", "objlist-%s.txt" % p), "w").write("\n".join(objs) + "\n")
