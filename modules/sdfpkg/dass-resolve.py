#!/usr/bin/env python3
"""Link a configuration so that its symbols resolve to the modules it LOADS.

    dass-resolve.py <build-tree> <config> [concard-root]

Supersedes dass-xphase.py, which this makes redundant: applying the xphase
merge on top of this link changes 318 halfwords in G16 and not one scored
section.

WHAT IS BROKEN WITHOUT THIS

dass-link.sh links every object, and its own header records why (point 4):
scoping the list to modules with a CSECT in augmented-<config>.json loses the
symbol DEFINITIONS the dropped modules supply, undefined symbols go from 91 to
337, and every relocation to one of them comes out wrong.  That is all true.
What it leaves in place is the opposite error.

A module this configuration does not load has no entry in its index, so
--external-syms cannot place it and lnk101 appends it past the end of the
image.  It then contributes no compared halfword at all -- but its entry points
are still in the symbol table, and they still win resolution.  Overlay
alternatives are the whole problem, because the alternatives export the SAME
names:

    FCMBMT16 references FIOBY23C.  Both FIOMFE02 and FIOMFE16 define it.  G16
    loads FIOMFE16 -- it is the only one of the five FIO?FE? variants in G16's
    index -- and the link resolved to FIOMFE02's, placed at 821892, past the
    end of a 330394-halfword image.  Every such ADCON is truncated garbage.

G16's object list carries all eight FCMBMT* and all five FIO[HM]FE* variants
while G16's index names exactly FCMBMT16, FIOHFE16 and FIOMFE16.

WHAT WORKS

Iterate, and supply the definitions rather than doing without them:

  1. ORACLE.  Link the whole object list against this configuration's index
     plus the addresses the other seven agree on (dass-xphase's combined map).
     Every symbol the system defines anywhere gets an address here.
  2. DROP every module lnk101 placed ENTIRELY past the image.  This is safe by
     construction: such a module cannot contribute a halfword to the compared
     region, so dropping it removes no correct content.  It can only change
     symbol resolution, and only toward the definition this configuration
     actually loads.
  3. RE-LINK, giving every now-undefined symbol a -D from the oracle.
  4. Repeat until the object list, the override set and the score all hold
     still.  Three passes, in every configuration.

-D TAKES A BYTE ADDRESS.  --json-symbols reports halfwords, and lnk101's
processDefinedSymbols does `baseAddress=Addr(value)`.  Pass 2*address or every
patched ADCON comes out at half its value -- DASS 3C50 against ours 1E28 -- and
looks like a wrong section rather than a wrong unit.

MEASURED, on uncontested genuinely-loaded CSECTs with the dump's own post-build
changes and never-printed fields excused:

    baseline   6843 exact, 7334 excused   88.4%
    dass-xphase 6946 exact, 7437 excused  89.7%
    this       7012 exact, 7507 excused   90.5%      all of 8292

Every configuration improves and all eight now stand at or above 90%.  In G16
the three families that exposed it go to nothing: FCMBMT16 157 differing
halfwords -> 0, FIOHFE16 42 -> 0, FIOMFE16 40 -> 0.

ONE MORE THING THE OBJECT LIST GETS WRONG, in the other direction.
dass-link.sh's overlay-alternative exclusion drops a module when another
configuration's deck names it and this configuration's chain does not.  That
rule is about DECKS, and it drops modules whose CSECT this configuration's
index plainly contains and whose content the dump plainly holds: GSIABT,
GVWQUA and GVXQUA in G16 and G3, PGPPLD in S2, and the whole DCDD*/DKFCM*/
D*LIGHT family nearly everywhere.  So before iterating, every module owning a
CSECT that is in this configuration's index, UNCONTESTED, and under half fill
in the dump is put back.  All three conditions matter: uncontested keeps the
re-add away from overlay alternatives, where emitting content would clobber,
and it is the same test the score uses, so nothing is being added that the
score would not then look at.  137 modules across the corpus.

WHAT IS LEFT.  31 symbols still resolve to nothing in G16 -- 24 #PC* compools
belonging to no configuration's index, FCMINSSL, and six FSVC* SVC entry
points.  They are undefined in the oracle too, so there is nothing to supply.
"""

import glob
from dasspfs import pfsDir
import collections, re, io, json, os, struct, subprocess, sys

IMAGE_HW = 330394
GRT = {"G16": (3, 4), "G2": (3, 5), "G3": (3, 6), "S2": (14, 15),
       "S4": (14, 16), "P9": (9, 12), "G8": (3, 7), "G9": (3, 8, 18)}
IPL_PHASES = (10, 2, 13, 3)
ROOTS = {"SSW": "SSW", "G16": "GNC1", "G2": "GNC2", "G3": "GNC3",
         "G8": "GNC8", "G9": "GNC9", "P9": "PL9", "S2": "SM2"}
MAX_PASSES = 8

# A configuration loads the IPL set plus its GRT row (ap101Utils.mcconfigs).
# CHANGE cards live in the phase decks as well as the root deck: MFB14 carries
# S2's, and it is reached through PHASE14, not through SM2.
IPL_PHASES = (10, 2, 13, 3)
GRT = {"G16": (3, 4), "G2": (3, 5), "G3": (3, 6), "S2": (14, 15),
       "S4": (14, 16), "P9": (9, 12), "G8": (3, 7), "G9": (3, 8, 18)}

# Symbols no configuration's index names and no linked module defines, whose
# address all eight dumps nevertheless state identically.
#
#   FCMINSSL   FCMPSA+0014 is TPSASRP, `DC Y`, and reads 6FBC in every one of
#              the eight dumps.  FCMINSSL.obj exists and is 934 halfwords, but
#              0x6FBC belongs to #DGG9GLI in G16 and #DSSPEXE in S2, so the
#              module is IPL-time code that the resident image later overwrites
#              -- which is why no index names it and why it must NOT be linked.
#              Supplying the address alone makes FCMPSA exact in all eight.
#   FIOG9ADB   the G9 alternate-display buffer, and FIOPDG9 the G9 payload
#   FIOPDG9    display.  Each is a whole CSECT of its own, each sits at one
#              address in every configuration -- 122512 and 122466, whose low
#              halves DE90 and DE62 are what all eight dumps store at
#              FIOCMPLT+01BE and FIOPDISP+027D -- and G9, whose phases do
#              include them, links both correctly without help.  The phase test
#              zeroes them in the other seven because their module belongs to no
#              phase those configurations load, which is true and beside the
#              point: the address is known and agreed.  Worth 14 CSECTs.
KNOWN = {"FCMINSSL": 0x6FBC, "FIOG9ADB": 122512, "FIOPDG9": 122466}


def combined_syms(mafgen, cfg, out):
    """This configuration's index, plus every section it does NOT place taken
    from the others where they AGREE.  Names sitting at different addresses in
    different configurations are overlay alternatives of other phases and are
    left out rather than guessed at."""
    A = {c: json.load(io.open("%s/augmented-%s.json" % (mafgen, c)))
         for c in ROOTS}
    mine = dict(A[cfg])
    elsewhere = collections.defaultdict(set)
    for c, d in A.items():
        if c != cfg:
            for n, g in d.items():
                if n not in mine:
                    elsewhere[n].add((g["start"], g["end"]))
    for n, v in elsewhere.items():
        if len(v) == 1:
            s, e = v.pop()
            mine[n] = {"start": s, "end": e}
    json.dump(mine, io.open(out, "w"))
    return mine


def link(binp, tree, objlist, syms, root, out, sj, defines=()):
    argv = [os.path.join(binp, "lnk101"), "@" + objlist,
            "-L", "lib/runtime/RUN", "-L", "lib/runtime/ZCON",
            "--external-syms", syms, "--concard", "CON80",
            "--concard-root", root, "--allow-undefined"]
    for n, v in sorted(defines):
        argv += ["-D", "%s=%d" % (n, 2 * v)]      # -D is a BYTE address
    argv += ["-o", out, "--json-symbols", sj]
    r = subprocess.run(argv, cwd=tree, capture_output=True, text=True)
    if not os.path.exists(os.path.join(tree, sj)):
        sys.exit("link failed:\n" + (r.stderr or r.stdout or "")[-800:])
    return json.load(io.open(os.path.join(tree, sj)))


def readd(tree, mafgen, cfg, oracle_sym, base):
    """Modules dass-link.sh's deck-based exclusion dropped although this
    configuration's index names a CSECT of theirs that the dump really holds."""
    aug = json.load(io.open("%s/augmented-%s.json" % (mafgen, cfg)))
    b = io.open("%s/%s.fcm" % (mafgen, cfg), "rb").read()
    r = struct.unpack(">%dH" % (len(b) // 2), b)
    rng = sorted((g["start"], g["end"], n) for n, g in aug.items())
    cont = set()
    for i in range(len(rng) - 1):
        for j in range(i + 1, len(rng)):
            if rng[j][0] > rng[i][1]:
                break
            cont.add(rng[i][2]); cont.add(rng[j][2])
    c2m = {e["name"]: e.get("module") for e in oracle_sym["sections"]}
    have = {os.path.splitext(os.path.basename(l))[0] for l in base}
    allp = {os.path.splitext(os.path.basename(l.strip()))[0]: l.strip()
            for l in io.open("%s/link/objlist-%s-all.txt" % (tree, cfg))
            if l.strip()}
    add = {}
    for n, g in aug.items():
        s0, e0 = g["start"], g["end"]
        if e0 + 1 > len(r) or n in cont:
            continue
        sz = e0 - s0 + 1
        if sum(1 for i in range(s0, e0 + 1) if r[i] in (0xC6C6, 0xC9FB)) / sz >= 0.5:
            continue
        m = c2m.get(n)
        if m and m not in have and m in allp:
            add[m] = allp[m]
    if add:
        print("  putting back %d modules whose loaded CSECT this configuration's "
              "index names: %s" % (len(add), " ".join(sorted(add))))
    return list(add.values())


def natively_supplies(objlist, names):
    """Modules whose own ESD declares one of `names` as an SD."""
    sys.path.insert(0, os.path.expanduser(
        os.environ.get("AP101UTILS", "~/donschmidt/nsts-sdl-dps/src")))
    try:
        import ap101Utils.objModule as om
    except ImportError:
        return set()
    out = set()
    for path in objlist:
        path = path.strip()
        if not path or not os.path.exists(path):
            continue
        try:
            mods = om.ObjectFile(path).modules
        except Exception:
            continue
        for c in mods:
            for x in c.esdEntries:
                if x.type.name == "SD" and (x.name or "").strip() in names:
                    out.add(os.path.splitext(os.path.basename(path))[0])
    return out


def change_includes(tree, root, cfg):
    """Modules a CHANGE card renames, which must be LOADED for it to apply.

    A configuration selects among same-shaped alternatives with a CHANGE card
    plus an INCLUDE naming the copy it wants.  MFB14 has

        CHANGE  #PCSAMMU(#PCVNMMU)      RATHER THAN THE 32 BLOCK
        INCLUDE SYSLIBL1(#PCSAMMU)      BUFFERS USED IN PL 9

    and GNC9STUB the same for #PCVQMMU.  lnk101 reads the card and then says
    "no loaded module supplies INCLUDE member '#PCVQMMU'; renames skipped",
    because a library is searched on demand and nothing references the name
    being renamed FROM -- every reference is to #PCVNMMU, the name it is being
    renamed TO.  Naming the object explicitly breaks the deadlock: the CHANGE
    then applies, #PCVNMMU comes out as the 4105-halfword CVQ_MM_UTILITY that
    G9's index describes rather than our 16393-halfword CVN_MM_UTILITY, and
    CPR -- which the 32-block copy was overwriting -- matches the dump exactly.
    """
    con = os.path.join(tree, "CON80")
    inc = re.compile(r"\s+INCLUDE\s+CONCARDS?\((\w+)\)")
    chg = re.compile(r"\s+CHANGE\s+(\S+?)\((\S+?)\)")
    lib = re.compile(r"\s+INCLUDE\s+SYSLIBL1\(([^)]*)\)")
    stack = [root] + ["PHASE%02d" % p
                      for p in sorted(set(IPL_PHASES) | set(GRT.get(cfg, ())))]
    seen, pairs, wanted = set(), set(), set()
    while stack:
        deck = stack.pop()
        path = os.path.join(con, deck)
        if deck in seen or not os.path.exists(path):
            continue
        seen.add(deck)
        for l in io.open(path, errors="replace"):
            b = l[:72]
            if b[:1] == "*":
                continue
            m = inc.match(b)
            if m:
                stack.append(m.group(1)); continue
            m = chg.match(b)
            if m:
                pairs.add((m.group(1), m.group(2))); continue
            m = lib.match(b)
            if m:
                wanted.update(y.strip() for y in m.group(1).split(",") if y.strip())
    out, targets = [], set()
    for a, b in sorted(pairs):
        if a not in wanted:
            continue
        p = os.path.join(tree, "SYSLIBL1", a + ".obj")
        if os.path.exists(p):
            out.append(p)
            targets.add(b)
    if out:
        print("  %d module(s) named by a CHANGE card loaded explicitly: %s"
              % (len(out), " ".join(os.path.basename(x) for x in out)))
    return out, targets


def local_definitions(tree, cfg, own):
    """Symbol addresses taken from the definition THIS configuration loads.

    An EQUATE EXTERNAL alias is declared once per configuration against a
    different compool -- TFIVAN14 is CS2INB's #PCS2INB, CVHPLD's #PCVHPLD and
    CS4INB's #PCS4INB -- and the oracle link resolves each name once, so it can
    only pick one.  Where a module's SD is named by this configuration's index,
    its LD offsets give the address this configuration really uses: TFIVAN14 is
    at byte 12 of #PCVHPLD, G9's index puts #PCVHPLD at 63760, and 63760+6 is
    F916, which is what the G9 dump stores.

    Fill is deliberately not consulted.  #PCVHPLD is 98% fill in G9 -- it is a
    buffer -- so the re-add step rightly declines to emit it, but its ADDRESS is
    still the one the references use."""
    sys.path.insert(0, os.path.expanduser(
        os.environ.get("AP101UTILS", "~/donschmidt/nsts-sdl-dps/src")))
    try:
        import ap101Utils.objModule as om
    except ImportError:
        return {}
    out = {}
    for line in io.open("%s/link/objlist-%s-all.txt" % (tree, cfg)):
        path = line.strip()
        if not path:
            continue
        full = path if os.path.isabs(path) else os.path.join(tree, path)
        if not os.path.exists(full):
            continue
        try:
            mods = om.ObjectFile(full).modules
        except Exception:
            continue
        for c in mods:
            sd = {x.esdId: (x.name or "").strip()
                  for x in c.esdEntries if x.type.name == "SD"}
            for x in c.esdEntries:
                if x.type.name != "LD" or x.ldid not in sd:
                    continue
                owner = sd[x.ldid]
                if owner in own and x.address is not None:
                    out[(x.name or "").strip()] = own[owner]["start"] + x.address // 2
    return out


def not_here(sym, own):
    """Modules this configuration does not load.

    Two ways to tell.  A module whose sections lnk101 put past the end of the
    image is plainly absent.  So is one none of whose sections this
    configuration's index names -- and that case is NOT covered by the first,
    because --external-syms places only what the index names and lnk101
    auto-places the rest wherever it fits, which is usually INSIDE the image.
    CGBGPS is the type case in SSW: #PCGBGPS is in five other indexes at 25350
    and in SSW's at all, so lnk101 put it at 211066, its TFIVGPS1 won
    resolution at that invented address, and every dump stores 630A -- the low
    half of 25354, where the combined map says it lives."""
    by = collections.defaultdict(list)
    named = collections.defaultdict(bool)
    for s in sym["sections"]:
        if s.get("size", 0) > 0 and s.get("module"):
            by[s["module"]].append(s["address"])
            if s["name"] in own:
                named[s["module"]] = True
    return {m for m, a in by.items()
            if all(x >= IMAGE_HW for x in a) or not named[m]}


def invariant_sections(mafgen, cfgs, min_placements=1):
    """CSECTs whose address and bytes are identical in every dump placing them.

    Such a section was resolved ONCE with the whole system in view and copied
    into each configuration: FIOADCNS and FIOADCCL are the same bytes at the
    same address in all eight, and they hold FIOMDPPG's addresses even in SSW
    and P9, where FIOMDPPG is pure fill.  A section that differs between dumps
    was linked per configuration: FIOCDATS takes three distinct forms across
    G9, P9 and S2, and holds 0 where its target is not loaded.
    """
    import hashlib
    imgs = {c: struct.unpack(
        ">%dH" % (os.path.getsize("%s/%s.fcm" % (mafgen, c)) // 2),
        io.open("%s/%s.fcm" % (mafgen, c), "rb").read()) for c in cfgs}
    seen, count = {}, {}
    for c in cfgs:
        for n, g in json.load(io.open("%s/augmented-%s.json" % (mafgen, c))).items():
            if g["end"] + 1 > len(imgs[c]):
                continue
            k = g["end"] - g["start"] + 1
            h = hashlib.md5(struct.pack(">%dH" % k,
                                        *imgs[c][g["start"]:g["end"] + 1])).hexdigest()
            seen.setdefault(n, set()).add((g["start"], h))
            count[n] = count.get(n, 0) + 1
    return {n for n, v in seen.items()
            if len(v) == 1 and count[n] >= min_placements}


def per_config_only(sym, own, oracle, inv, dimg, osec):
    """Symbols to leave undefined: they live in a section this dump does not
    hold, and every section referencing them was linked per configuration.

    The reference map must come from THIS link, not the oracle link: the oracle
    places sections from a combined map and they overlap, so an address lookup
    there reports FCMBMT02 as the referrer of FIO00SOU when FIOCDATS is.
    """
    refs = reference_map(sym, own)
    s2n = {e["name"]: e.get("section") for e in sym["symbols"]}
    def unloaded(name):
        e = osec.get(name)
        if not e: return False
        lo = e["address"]; hi = min(lo + e["size"] - 1, len(dimg) - 1)
        return hi >= lo and sum(1 for i in range(lo, hi + 1)
                                if dimg[i] in (0xC6C6, 0xC9FB)) / (hi - lo + 1) >= 0.5
    out = set()
    for n, holders in refs.items():
        if n in own or n not in oracle:
            continue
        sec = s2n.get(n)
        if not sec or sec in own or not unloaded(sec):
            continue
        if holders and not all(h in inv for h in holders):
            out.add(n)
    return out


def reference_map(sym, own):
    """symbol -> the sections of THIS link that reference it.

    It has to come from this link, not the oracle: the oracle places sections
    from a combined map and they overlap, so an address lookup there names
    FCMBMT02 as the referrer of FIO00SOU when it is FIOCDATS.
    """
    rng = sorted((e["address"], e["address"] + e["size"] - 1, e["name"])
                 for e in sym["sections"] if e.get("size", 0) > 0 and e["name"] in own)
    def holder(a):
        lo, hi = 0, len(rng)
        while lo < hi:
            mid = (lo + hi) // 2
            if rng[mid][1] < a: lo = mid + 1
            else: hi = mid
        return rng[lo][2] if lo < len(rng) and rng[lo][0] <= a else None
    refs = collections.defaultdict(set)
    for x in sym["relocations"]:
        t = x.get("targetName")
        if t:
            h = holder(x["address"])
            if h: refs[t].add(h)
    return refs


def stale_phase_check(tree, order):
    """Refuse to trust phase tables older than the objects they were linked from.

    They were a day stale when this rule was first measured, predating every
    source fix of that session, and the measurement that followed was wrong in
    both directions -- it reported a regression where refreshing them gives a
    gain.  A phase table is evidence about the build; if the build has moved,
    it is not evidence about anything.
    """
    objs = glob.glob("%s/objects/*.obj" % tree)
    if not objs:
        return
    newest = max(os.path.getmtime(f) for f in objs)
    for ph in order:
        f = "%s/phase/PHASE%02d.sym.json" % (tree, ph)
        if os.path.exists(f) and os.path.getmtime(f) < newest:
            sys.exit("phase/PHASE%02d.sym.json is older than objects/; "
                     "re-run dass-phases.sh before resolving" % ph)


def phase_symbol_tables(tree, cfg):
    """Per-phase (sections, entry symbols) for the phases this configuration links,
    in link order, plus that order.

    The per-phase links were run with the real --map-lib chains, so their symbol
    tables already state what each phase could resolve and nothing here has to
    model MAP semantics.  That matters, because the chains are not symmetric:
    PHASE08 maps MAP2 and MAP3 while PHASE09 maps MAP2 alone, which is the whole
    reason G9 resolves FIOHFE89's #LBR operands and P9 leaves them 0.
    """
    order = tuple(IPL_PHASES) + tuple(GRT.get(cfg, ()))
    secs, syms, keep = {}, {}, []
    for ph in order:
        f = "%s/phase/PHASE%02d.sym.json" % (tree, ph)
        if not os.path.exists(f):
            continue
        d = json.load(io.open(f))
        secs[ph] = {e["name"]: (e["address"], e["size"])
                    for e in d.get("sections", []) if e.get("size", 0) > 0}
        syms[ph] = {e["name"] for e in d.get("symbols", []) if e.get("type") == "entry"}
        keep.append(ph)
    return tuple(keep), secs, syms


def owning_phase(tree, order, psecs, sec, ref, cache={}):
    """The phase whose linked copy of a section is the one the dump holds.

    Deck order is not the answer.  SSW's FIOHFEPG is linked by phases 2 and 3
    and the dump holds phase 2's copy -- 70 halfwords out of 1144 differ against
    phase 3's 1099 -- so taking the last phase attributes it to a link that
    never produced it and zeroes TFIVH251, which the dump resolves.  Comparing
    the copies settles it directly, and settles it hard: P9's FIOCDATS matches
    its phase 9 copy in all 580 halfwords.
    """
    key = (id(psecs), sec, len(ref))
    if key in cache:
        return cache[key]
    best = None
    for ph in order:
        e = psecs.get(ph, {}).get(sec)
        if not e:
            continue
        f = "%s/phase/PHASE%02d.fcm" % (tree, ph)
        if not os.path.exists(f):
            continue
        img = phase_image(f)
        a = e[0]
        if a + len(ref) > len(img):
            continue
        d = sum(1 for i in range(len(ref)) if img[a + i] != ref[i])
        if best is None or d < best[1]:
            best = (ph, d)
    cache[key] = best[0] if best else None
    return cache[key]


def phase_image(f, cache={}):
    if f not in cache:
        b = io.open(f, "rb").read()
        cache[f] = struct.unpack(">%dH" % (len(b) // 2), b)
    return cache[f]


def phase_undefined(refs, oracle, own, csects, order, psecs, psyms, inv2,
                    tree, dimg, aug):
    """Symbols the phase that links their referrer could not have resolved.

    Applies only to symbols that are NOT themselves CSECT names.  A CSECT's
    address is a system-wide constant, is handled by the existing phase rule, and
    zeroing one breaks the invariant tables -- SSW's FIOHFEPG, FIOACTMD and
    FIOPDHF all reach FIOMDPPG across a phase boundary and the dump resolves
    every one.  What this catches is the other kind: an entry label inside a
    section, an EQUATE EXTERNAL alias or an assembly entry point, where the
    original link had no definition and stored the addend as it stood.
    """
    out = set()
    for n, holders in refs.items():
        if n in own or n in csects or n not in oracle:
            continue
        # The per-phase tables come from OUR phase decks, which are themselves
        # approximate: phase 8 lists 1502 entries where the system has tens of
        # thousands, so unqualified the test fires on anything our decks happen
        # to omit and costs 77 CSECTs.  Restrict it to references made from a
        # table that was demonstrably linked per configuration -- one that is
        # NOT byte-identical across the dumps that place it, counting a section
        # only one dump places as no evidence either way.
        if not holders or all(h in inv2 for h in holders):
            continue
        for h in holders:
            g = aug.get(h)
            if not g or g["end"] + 1 > len(dimg):
                continue
            p = owning_phase(tree, order, psecs,
                             h, dimg[g["start"]:g["end"] + 1])
            if p is not None and n not in psyms.get(p, ()):
                out.add(n)
    return out


def main():
    if len(sys.argv) not in (3, 4):
        sys.exit(__doc__.strip().split("\n")[2].strip())
    tree, cfg = sys.argv[1], sys.argv[2]
    root = sys.argv[3] if len(sys.argv) == 4 else ROOTS[cfg]
    pfs = pfsDir()
    mafgen = os.path.join(pfs, "mafgen")
    binp = os.environ.get("LNK101_BIN",
                          os.path.expanduser("~/donschmidt/nsts-sdl-dps/build/bin"))
    aug = "%s/augmented-%s.json" % (mafgen, cfg)
    comb = "link/combined-%s.json" % cfg
    index = combined_syms(mafgen, cfg, os.path.join(tree, comb))

    o = link(binp, tree, "link/objlist-%s-all.txt" % cfg, comb, root,
             "link/%s-oracle.fcm" % cfg, "link/%s-oracle-symbols.json" % cfg)
    oracle = {s["name"]: s["address"] for s in o["symbols"]}
    for n, g in index.items():
        oracle.setdefault(n, g["start"])          # a CSECT name used as a symbol
    local = local_definitions(tree, cfg, json.load(io.open(aug)))
    oracle.update(local)
    print("  %d symbols redefined from the copy this configuration loads" % len(local))
    oracle.update(KNOWN)

    # A symbol that IS a CSECT this configuration does not load, and whose
    # module belongs to no phase this configuration loads, was undefined for
    # the original link editor too: it stored the bare offset, so the base is
    # 0.  The phase test is what makes this safe.  "Foreign section" alone
    # conflates two populations -- another PHASE of this configuration, where
    # the borrowed address is right and is exactly what fixes FCMBMT16, and
    # another CONFIGURATION, where 0 is right -- and zeroing both costs
    # sections rather than gaining them.
    own = json.load(io.open(aug))
    phases = set(IPL_PHASES) | set(GRT.get(cfg, ()))
    mine = set()
    for ph in sorted(phases):
        f = "%s/phase/objlist-%02d.txt" % (tree, ph)
        if os.path.exists(f):
            mine |= {os.path.splitext(os.path.basename(l.strip()))[0]
                     for l in io.open(f) if l.strip()}
    s2m = {e["name"]: e.get("module") for e in o["sections"]}
    zeroed = 0
    for n in set(s2m) - set(own) - set(KNOWN):
        if n in oracle and s2m.get(n) not in mine:
            oracle.pop(n, None)   # leave UNDEFINED, not defined-as-0
            zeroed += 1
    print("  %d CSECT-name symbols belong to no phase this configuration "
          "loads; defined as 0" % zeroed)

    base = [l.strip() for l in
            io.open("%s/link/objlist-%s.txt" % (tree, cfg)) if l.strip()]
    base += readd(tree, mafgen, cfg, o, base)
    changed, targets = change_includes(tree, root, cfg)
    base += changed
    if targets:
        # A CHANGE names the copy this configuration wants; the module that
        # supplies that CSECT name NATIVELY must go, or both define it after
        # the rename and which one wins is lnk101's tie-break rather than our
        # intent.  In G9 that is CVNMMUTI, still in the list and still 16393
        # halfwords long.
        # Determined from the OBJECTS, not from the oracle link: that link
        # applies the rename too, so its section map already reports the
        # renamed copy as the supplier of the target name.
        native = natively_supplies(base, targets)
        native -= {os.path.splitext(os.path.basename(x))[0] for x in changed}
        if native:
            base = [l for l in base
                    if os.path.splitext(os.path.basename(l))[0] not in native]
            print("  excluding %s, which supplies %s natively"
                  % (" ".join(sorted(native)), " ".join(sorted(targets))))
    inv = invariant_sections(mafgen, sorted(ROOTS))
    inv2 = invariant_sections(mafgen, sorted(ROOTS), min_placements=2)
    porder, psecs, psyms = phase_symbol_tables(tree, cfg)
    stale_phase_check(tree, porder)
    csects = {e["name"] for e in o["sections"] if e.get("size", 0) > 0}
    dimg = struct.unpack(">%dH" % (os.path.getsize("%s/%s.fcm" % (mafgen, cfg)) // 2),
                         io.open("%s/%s.fcm" % (mafgen, cfg), "rb").read())
    osec = {e["name"]: e for e in o["sections"] if e.get("size", 0) > 0}
    drop, over, sym, prev, withheld = set(), {}, None, None, set()
    for it in range(MAX_PASSES):
        keep = [l for l in base
                if os.path.splitext(os.path.basename(l))[0] not in drop]
        io.open("%s/link/objlist-%s-resolved.txt" % (tree, cfg), "w") \
          .write("\n".join(keep) + "\n")
        if sym:
            refs = reference_map(sym, own)
            new = (per_config_only(sym, own, oracle, inv, dimg, osec)
                   | phase_undefined(refs, oracle, own, csects,
                                     porder, psecs, psyms, inv2,
                                     tree, dimg, own)) - withheld
            if new:
                withheld |= new
                for n in new:
                    oracle.pop(n, None); over.pop(n, None)
                print("  %d symbol(s) referenced only by per-configuration "
                      "tables, in sections this dump does not hold; left "
                      "undefined" % len(new))
            for n in {x["symbol"].split("+")[0]
                      for x in sym["unresolvedRelocations"]}:
                if n not in withheld and oracle.get(n, IMAGE_HW) < IMAGE_HW:
                    over[n] = oracle[n]
        sym = link(binp, tree, "link/objlist-%s-resolved.txt" % cfg, aug, root,
                   "link/%s-r.fcm" % cfg, "link/%s-r-symbols.json" % cfg,
                   over.items())
        state = (len(keep), len(over), len(sym["unresolvedRelocations"]))
        print("  pass %d: %d objects, %d -D overrides, %d unresolved relocations"
              % ((it,) + state))
        if state == prev:
            break
        prev = state
        drop |= not_here(sym, own)
    print("  wrote link/%s-r.fcm (%d modules dropped as not loaded here)"
          % (cfg, len(drop)))


if __name__ == "__main__":
    main()
