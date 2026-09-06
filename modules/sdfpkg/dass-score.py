#!/usr/bin/env python3
"""The honest accuracy figure for a set of linked configurations.

    dass-score.py <build-tree> [-r|-x|''] [config ...]

The second argument is the suffix of the images to score: '-r' for
dass-resolve.py's, '-x' for dass-xphase.py's, '' for dass-link.sh's own.
Default '-r', default all eight configurations.

WHAT THE DENOMINATOR IS, AND WHY IT IS NOT EVERY CSECT

A CSECT counts only if it is

  * UNCONTESTED -- its index range overlaps no other CSECT's.  Where two
    overlap, one of them is an overlay alternative and the dump can hold either
    or a mixture, so neither is evidence about our build.
  * GENUINELY LOADED -- under half its halfwords are fill (C6C6 from the
    compiler and the link editor's HAL holes, C9FB from the assembler).  A
    CSECT that is mostly fill was not loaded in this configuration and matching
    it proves nothing.

That is 8292 CSECTs over the eight configurations.  A CSECT scores only if it
is placed at exactly the index's address and length AND every halfword agrees.

TWO THINGS THE DUMPS DO NOT SAY, both excused in the later columns

  * POST-BUILD CHANGES.  The dump marks them with '*'; exceptions-<cfg>-curated.txt
    is the scrape.  No build can reproduce a patch applied after the build.
  * ADDRESSES MAFGEN NEVER PRINTS A VALUE FOR.  unlinkMAFGEN2.py sets every
    address it never saw a value for to 0xC9FB below 0x20000 and 0xC6C6 above
    (its lines 484-488).  That fill is SYNTHETIC and chosen by address: it says
    nothing whatever about the dump, and no build could match it except by
    accident.  Such an address is excused.

    An address MAFGEN covered by a field header but printed no values for is a
    different thing -- MAFGEN omits an all-zero field entirely, so the extractor
    records a real zero (its -2 sentinel) and the address IS known.  The two are
    told apart by the extracted value: unknown addresses hold the synthetic
    fill, known-zero ones hold 0.  Requiring the value to BE fill is therefore
    not a safety margin but the discriminator itself.

    This is why the set has to be built from what the listing PRINTS rather than
    from headers with missing value lines.  The earlier implementation looked
    only for a ranged header whose next line was not a value line, which finds
    the all-zero fields -- the known ones -- and misses the addresses that fall
    between printed rows entirely.  #DARBIDL is the type case: the listing
    prints +0000-+0001, then jumps straight to +0004, and +0002-+0003 are never
    mentioned at all.  Correcting this moved the figure from 7507 to 8111 with
    no change to any build.

    printed() is validated on every configuration: every non-fill, non-zero
    halfword in all eight .fcm files falls inside it, so it cannot be excusing
    an address the listing really did print.

Quote the LAST column.  It stands at 8111/8292, 97.8%.
"""
import io, json, os, re, struct, sys

from dasspfs import mafgenDir

M = mafgenDir()
E = os.path.expanduser("~/ForClaude/OI340600-clc")
FILL = {0xC6C6, 0xC9FB}
ASC = {"SSW": "DASS_SSW_(PostIPL).ASC"}
CONFIGS = ["SSW", "G16", "G2", "G3", "G8", "G9", "P9", "S2"]

# <addr>[-<addr>]  <NAME>+<hex offset>  <anything containing a 4-hex-digit group>
LINE = re.compile(r'^\s*([0-9A-F]{5,6})(?:-([0-9A-F]{5,6}))?'
                  r'\s+([A-Z0-9#$@-]+\s*\+[0-9A-F]+)\s+(.*)$')
HEXV = re.compile(r'(?<![0-9A-Z_])[0-9A-F]{4}(?![0-9A-Z_])')


def printed(cfg):
    """Every address the listing prints a value for.  Anything else inside a
    CSECT is an address unlinkMAFGEN2.py synthesised a fill byte for."""
    p = "%s/%s" % (M, ASC.get(cfg, "DASS_%s.ASC" % cfg))
    if not os.path.exists(p):
        return set()
    s = set()
    for l in io.open(p, errors="replace"):
        m = LINE.match(l.rstrip("\n"))
        if not m or not HEXV.search(m.group(4)):
            continue
        a = int(m.group(1), 16)
        b = int(m.group(2), 16) if m.group(2) else a
        if a <= b <= a + 4096:
            s.update(range(a, b + 1))
    return s


_warned = set()


def exc_dir(fn):
    """Where to read one exceptions file from.  The tracked copy in mafgen/ is
    canonical; the working copy the sweep writes in ~/ForClaude is the
    fallback.  If both exist and differ, SAY SO -- a tracked copy of derived
    data silently shadowing a newer one is exactly how csects-*.json went 1077
    CSECTs stale without anything noticing."""
    a, b = "%s/%s" % (M, fn), "%s/%s" % (E, fn)
    if os.path.exists(a) and os.path.exists(b) and fn not in _warned:
        if io.open(a, "rb").read() != io.open(b, "rb").read():
            _warned.add(fn)
            sys.stderr.write("WARNING: %s differs between\n    %s (used)\n"
                             "    %s (ignored)\n" % (fn, a, b))
    return a if os.path.exists(a) else b


def exc_set(cfg):
    s = set()
    for fn in ("exceptions-%s-curated.txt" % cfg,):
        p = exc_dir(fn)
        if not os.path.exists(p):
            continue
        for l in io.open(p, errors="replace"):
            l = l.strip()
            if l and not l.startswith("#"):
                try:
                    s.add(int(l.split()[0], 16))
                except ValueError:
                    pass
    return s


def halfwords(p):
    b = io.open(p, "rb").read()
    return list(struct.unpack(">%dH" % (len(b) // 2), b))


def main():
    tree = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1
                              else "~/pass-build/OI340700")
    sfx = sys.argv[2] if len(sys.argv) > 2 else "-r"
    cfgs = sys.argv[3:] or CONFIGS
    print("%-5s %7s %7s %7s %9s %7s %10s %7s"
          % ("cfg", "loaded", "exact", "rate", "+patches", "rate",
             "+unknown", "rate"))
    TT = RR = EE = FF = 0
    XS = XF = NF = 0
    excused = []
    for cfg in cfgs:
        aug = json.load(io.open("%s/augmented-%s.json" % (M, cfg)))
        r = halfwords("%s/%s.fcm" % (M, cfg))
        d = json.load(io.open("%s/link/%s%s-symbols.json" % (tree, cfg, sfx)))
        m = halfwords("%s/link/%s%s.fcm" % (tree, cfg, sfx))
        o = {e["name"]: (e["address"], e["size"]) for e in d["sections"]}
        exc, pr = exc_set(cfg), printed(cfg)
        rng = sorted((g["start"], g["end"], n) for n, g in aug.items())
        cont = set()
        for i in range(len(rng) - 1):
            for j in range(i + 1, len(rng)):
                if rng[j][0] > rng[i][1]:
                    break
                cont.add(rng[i][2]); cont.add(rng[j][2])
        tot = raw = ex1 = ex2 = 0
        exhS = exhF = nfill = 0
        for n, g in aug.items():
            s, e = g["start"], g["end"]
            if e + 1 > len(r) or n in cont:
                continue
            sz = e - s + 1
            # Halfwords the listing never stated a value for, which
            # unlinkMAFGEN2 synthesised fill into.  We neither match nor differ
            # there, so they are excused rather than tested.
            never = sum(1 for i in range(s, e + 1)
                        if i not in pr and r[i] in FILL)
            if sum(1 for i in range(s, e + 1) if r[i] in FILL) / sz >= 0.5:
                nfill += 1
                exhF += never
                continue
            exhS += never
            tot += 1
            if o.get(n) != (s, sz):
                continue
            dif = [s + i for i in range(sz) if m[s + i] != r[s + i]]
            if not dif:
                raw += 1; ex1 += 1; ex2 += 1; continue
            d1 = [a for a in dif if a not in exc]
            if not d1:
                ex1 += 1; ex2 += 1; continue
            if all(a not in pr and r[a] in FILL for a in d1):
                ex2 += 1
        TT += tot; RR += raw; EE += ex1; FF += ex2
        XS += exhS; XF += exhF; NF += nfill
        excused.append((cfg, exhS, exhF, nfill))
        print("%-5s %7d %7d %6.1f%% %9d %6.1f%% %10d %6.1f%%"
              % (cfg, tot, raw, 100 * raw / tot, ex1, 100 * ex1 / tot,
                 ex2, 100 * ex2 / tot))
    print("%-5s %7d %7d %6.1f%% %9d %6.1f%% %10d %6.1f%%"
          % ("ALL", TT, RR, 100 * RR / TT, EE, 100 * EE / TT, FF, 100 * FF / TT))

    # EXCUSED HALFWORDS.  The columns above are CSECT pass/fail and are at 100%,
    # so they cannot show progress on the one large thing still outstanding:
    # addresses the MAFGEN listing never stated a value for.  unlinkMAFGEN2
    # synthesises fill there, we neither match nor differ, and the CSECT is
    # excused.  An initial value recovered from the compiler's SDF converts each
    # such halfword from an excuse into a test, so THIS is the number that
    # measures that work.
    #
    # Split, because the two halves behave differently.  A halfword in a scored
    # CSECT becomes a comparison the moment a value is supplied.  One in a CSECT
    # excluded as at least half fill does more: supplying values can carry the
    # CSECT below the fill threshold and bring it into the denominator, which is
    # where the mass-memory compools (#PCDIMMU, #PCVNMMU, #CDCDDG9) sit.
    print("\nEXCUSED HALFWORDS -- the listing stated no value, so neither"
          " matched nor differing")
    print("%-5s %14s %16s %14s" % ("cfg", "in scored", "in mostly-fill",
                                   "mostly-fill"))
    print("%-5s %14s %16s %14s" % ("", "CSECTs", "CSECTs", "CSECTs"))
    for cfg, a, b, c in excused:
        print("%-5s %14d %16d %14d" % (cfg, a, b, c))
    print("%-5s %14d %16d %14d" % ("ALL", XS, XF, NF))
    print("total excused: %d halfwords" % (XS + XF))

    # REDUNDANT EXCEPTIONS.  An exception asserts no claim about an address, so
    # it goes on suppressing the comparison after the difference it covered is
    # gone, and nothing says so.  Five of the seven entries alive on 2026-09-06
    # were already redundant -- rebuilding the compiler that morning made four
    # of them match and a fifth had never been what it claimed -- and they were
    # found by hand.  Report them: an exception that no longer changes anything
    # should be deleted, not carried.
    # Only the curated files are reported by address.  The base files are derived
    # from the listing alone and know nothing of our build, so a redundant
    # entry there is expected and regenerates anyway; it is counted, not named.
    stale, base = [], 0
    for cfg in cfgs:
        try:
            r = halfwords("%s/%s.fcm" % (M, cfg))
            m = halfwords("%s/link/%s%s.fcm" % (tree, cfg, sfx))
        except IOError:
            continue
        for fn, curated in (("exceptions-%s-curated.txt" % cfg, True),):
            p = exc_dir(fn)
            if not os.path.exists(p):
                continue
            for l in io.open(p, errors="replace"):
                l = l.strip()
                if not l or l.startswith("#"):
                    continue
                try:
                    a = int(l.split()[0], 16)
                except ValueError:
                    continue
                if a < len(r) and a < len(m) and r[a] == m[a]:
                    if curated:
                        stale.append((cfg, a, " ".join(l.split()[2:])[:44]))
                    else:
                        base += 1
    if stale:
        print("\n%d CURATED exception(s) no longer change anything -- delete:"
              % len(stale))
        for cfg, a, why in stale:
            print("    %-4s %05X  %s" % (cfg, a, why))
    if base:
        print("\n(%d generated base entries are also redundant; they are derived"
              " from the\n listing alone and regenerate, so they are counted"
              " rather than named.)" % base)


if __name__ == "__main__":
    main()
