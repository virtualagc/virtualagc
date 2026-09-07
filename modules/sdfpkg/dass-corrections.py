#!/usr/bin/env python3
"""
RECORDED DEAD END, AND THE USER DISSENTS FROM THE CONCLUSION.

This tool was to emit corrected-<cfg>.fcm from the SDFs.  It never shipped an
artefact, and the investigation behind it concluded that neither MAFGEN
reporting class exists.  THE USER DOES NOT ACCEPT THAT CONCLUSION, having seen
both errors directly -- which is why the work was commissioned -- though without
a record of where.  That dissent is not a formality: the scope of what was
actually checked is narrow enough to have missed them, and the numbers say so.

WHAT WAS CHECKED: addresses the listing PRINTED, in UNCONTESTED CSECTs, for
symbols whose own non-zero initial values corroborate their mapping.  That is
6,842 of about 16,000 symbols for class A, and 4,691 of 21,157 pointer sites for
class B.  Within it, no misreports.

WHAT THAT EXCLUDED, counted over the corpus by shape:

    class A shape (our build 0000, listing shows fill)
        uncontested, PRINTED           1
        uncontested, NOT printed       140,301
        contested,   PRINTED           393
        contested,   NOT printed       197,923

    class B shape (listing shows 0000, our build non-zero)
        uncontested, PRINTED           4
        contested,   PRINTED           12,684
        contested,   NOT printed       4,610

Both gates removed exactly where each phenomenon would sit.  Class A as the user
described it -- a variable initialized to zero appearing in the DASS file as
uninitialized fill -- IS a location MAFGEN did not report, so gating on
"printed" answers a different question than the one asked; 140,301 uncontested
positions carry that shape.  Class B's shape is overwhelmingly contested, and
contested CSECTs were excluded wholesale.

SO THE HONEST STATE IS: not refuted, but unexamined where it matters.  Whoever
picks this up should drop the printed gate for class A and confront the
contested regions for class B, rather than treat the classes as closed.
Correct MAFGEN's reporting bugs in a recovered image, from the SDFs.

    dass-corrections.py <build-tree> <config> [--dry-run] [--rebuild-cache]

writes, beside the recovered images in PFS/mafgen:

    corrections-<cfg>.json   every correction, with its evidence
    corrected-<cfg>.fcm      <cfg>.fcm with those corrections applied

WHAT THIS IS.  <cfg>.fcm is what MAFGEN's listing says the memory held, and
MAFGEN misreports two kinds of initialization.  The corrected image is a better
estimate of AS-BUILT MEMORY than the raw one, so it is the reference that moves,
never our build.  <cfg>.fcm itself is left untouched: it is the primary artefact
of the listing and everything here is derived from it.

THE TWO CLASSES.

  * ZERO SHOWN AS FILL.  A variable the SDF initializes to zero where the
    listing prints fill (C6C6 from the compiler and the link editor, C9FB from
    the assembler).  Corrected to 0.

  * INITIAL(NAME(...)) SHOWN AS ZERO.  A NAME variable the SDF gives an
    initialization target for, where the listing prints 0000.  Corrected to the
    target's address.  A pointer reported as zero costs almost nothing in the
    CSECT score and is fatal the moment the code dereferences it, which is why
    this class matters far more to execution than to scoring.

STILL NOT TRUSTWORTHY -- DO NOT RUN IT FOR REAL.  The analysis below is
SUPERSEDED: it was argued from statistics over the corpus, and initlab-check.py
settles the same questions by compiling probes.  Run that first.  In particular
'a zero means nothing initialized here' is WRONG -- INITIAL(0) is emitted as
0000; the table cannot distinguish a zero from an uninitialized element, which
is harmless for a bulk-zeroed type because the two are then identical in memory,
and bites only for a type the bulk pass skips.  What is right, and what is not:

  RIGHT.  The extent rule works exactly as stated below, and the unit-to-CSECT
  mapping with it.  ##CDTANN's four initialized symbols tile its table with no
  gaps, and the table matches BOTH the dump and our independently built image in
  all 645 halfwords in all eight configurations.  The machinery is sound.

  WRONG.  A ZERO IN THE INITIALIZATION TABLE MEANS "NOTHING INITIALIZED HERE",
  NOT "INITIALIZED TO ZERO", and this file reads every zero as the latter.
  Evidence: restrict corrections to symbols whose NON-ZERO initial values are
  all corroborated by the dump -- so the extent and base are demonstrably right
  -- and 1,473 of 1,522 remaining corrections still contradict our build, which
  holds fill at those positions just as the dump does.  Two independent images
  agree that nothing was placed there.  So class A cannot be found this way at
  all: the table alone does not say WHICH positions an INITIAL clause actually
  covered, and a partially initialized array is indistinguishable from a
  zero-filled one.  Finding that per-symbol count of initialized elements is the
  next thing to look for.

  ALSO WRONG.  Class B's address arithmetic -- holder address plus (copy - 1) --
  is not right either.  Of 14 candidates none validate, and where neither value
  matches our build holds small integers (0006, 0001) at addresses where this
  computes pointers, so the holder location is off.

EVERYTHING COMES FROM THE SDF -- NO HALSTAT, NO DATATYPES.  An earlier version
looked symbols up in HALSTAT by name and got 2,295 of 2,509 corrections wrong,
because names are not unique there: CZ2V_GST appears as a cross-reference list,
a STRUCTURE TEMPLATE and a STRUCTURE(5) VARIABLE, and the variable entry gives
"(SEE TEMPLATE ...)" instead of an extent.  None of that is needed.  The symbol
data cell states the extent directly:

    field 20  numberOfDimensions
    field 21  rangeOfDim1
    field 16  valueOfBiasOfArray      ->  size = rangeOfDim1 * bias halfwords

and field 10, relativeMemoryAddressOfSymbol, is where it starts.  What those
halfwords MEAN is irrelevant -- no structure layout or datatype is consulted.
The rule is self-checking: in ##CDTANN the four initialized symbols tile the
initialization table exactly, 6 + 192 + 312 + 135 = 645, with no gaps, and 645
is both the table's length and the size of #PCDTANN, the only CSECT of that
size.

THE UNIT'S CSECT is found the same way: for SDF ##NAME, the CSECT #?NAME whose
size equals the initialization table's length.  That is unique for 1144 of 1199
units.  23 more have a table LARGER than the CSECT of that name -- INCLUDE
REMOTE data living elsewhere -- and with 16 unnamed and 16 ambiguous they are
skipped rather than guessed at.

TWO GATES THAT MATTER.  Only addresses the listing actually PRINTED can be
misreported; the rest of the fill in <cfg>.fcm was synthesised by unlinkMAFGEN2
for addresses MAFGEN never stated, which are absent reports, not wrong ones.
Without that gate the first class fires 70,471 times against the 589 proven.
And a correction may never be derived from our build: nothing here opens a
link/ image, so the tool runs correctly with every build artefact deleted.  That
keeps the validation honest -- asking whether corrections move the reference
toward our independently built image is evidence only while the two are
genuinely independent.
"""

import collections
import io
import json
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
for _p in ("modules/sdfpkg/sdfpkg", "modules/sdf/sdf", "modules/cmem/cmem"):
    sys.path.insert(0, os.path.expanduser("~/git/virtualagc/" + _p))

from dasspfs import mafgenDir                                    # noqa: E402

FILL = {0xC6C6, 0xC9FB}
INITIAL_FLAG = 1 << (31 - 17)
CFGS = ["SSW", "G16", "G2", "G3", "G8", "G9", "P9", "S2"]


def _printed(cfg):
    """dass-score's own definition, rather than a second copy of it."""
    import importlib.util
    f = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                     "dass-score.py")
    spec = importlib.util.spec_from_file_location("_ds", f)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m.printed(cfg)


def openSdf(name):
    from sdfpkg import sdfpkg
    mem = bytearray(0x100000)
    C = {k: None for k in
         ("APGAREA AFCBAREA NPAGES NBYTES MISC CRETURN BLKNO SYMBNO STMTNO "
          "BLKNLEN SYMBNLEN PNTR ADDR SDFNAM CSECTNAM SREFNO INCLCNT BLKNAM "
          "SYMBNAM").split()}
    p = sdfpkg(mem, "SDFLIB", C)
    C.update({"MISC": 0, "APGAREA": 0x100000, "AFCBAREA": 0x10000,
              "NPAGES": 1, "NBYTES": 1024, "ADDR": 0, "PNTR": 0})
    p.sdfpkg(0, 0x1000)
    C["SDFNAM"] = name
    p.sdfpkg(4)
    p.s.verbose = False
    p.s.parseSDF()
    return p.s


def buildCache(tree, sizes, path):
    """Parse every SDF once: unit -> CSECT, init table, symbols, NAME targets.

    Parsing is 0.06s a unit, so the library is about 75 seconds -- cheap once
    and far too dear eight times.
    """
    from sdf import sdf as SDF
    here = os.getcwd()
    os.chdir(tree)
    out, stats = {}, collections.Counter()
    for f in sorted(os.listdir("SDFLIB")):
        if not f.endswith(".sdf"):
            continue
        unit = f[:-4]
        try:
            s = openSdf(unit)
        except Exception:
            stats["sdf unreadable"] += 1
            continue
        init = getattr(s, "initializationTable", None) or []
        if not init:
            stats["no initialization table"] += 1
            continue
        stem = unit.lstrip("#")
        hit = [c for c, sz in sizes.items()
               if len(c) > 2 and c[0] == "#" and c[2:] == stem
               and sz == len(init)]
        if len(hit) != 1:
            stats["CSECT not identified" if not hit else "CSECT ambiguous"] += 1
            continue
        syms = getattr(s, "symbolIndexTable", None) or []
        rec = {"csect": hit[0], "init": list(init), "syms": [], "names": []}
        for sym in syms:
            c = getattr(sym, "symbolDataCell", None)
            if c is None:
                continue
            ra = getattr(c, "relativeMemoryAddressOfSymbol", None)
            r1 = getattr(c, "rangeOfDim1", 0) or 0
            bi = getattr(c, "valueOfBiasOfArray", 0) or 0
            nm = SDF.fullSymbolASCII(sym)
            size = r1 * bi
            if ra is not None and size > 0:
                rec["syms"].append(
                    [nm, ra, size,
                     bool((getattr(c, "flagBits", 0) or 0) & INITIAL_FLAG)])
        for symbno, entries in (getattr(s, "nameTerminalInitialization",
                                        None) or {}).items():
            if not (1 <= symbno <= len(syms)):
                continue
            holder = SDF.fullSymbolASCII(syms[symbno - 1])
            for copy, target, _raw, _loops in entries:
                if isinstance(target, str):
                    rec["names"].append([holder, copy or 1, target])
        out[unit] = rec
        stats["usable"] += 1
    os.chdir(here)
    json.dump(out, io.open(path, "w"))
    for k, v in sorted(stats.items()):
        print("   %-28s %d" % (k, v))
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv
    if len(args) != 2:
        sys.exit(__doc__.strip().split("\n")[2].strip())
    tree, cfg = os.path.expanduser(args[0]), args[1]
    M = mafgenDir()

    sizes = {}
    for c in CFGS:
        p = "%s/augmented-%s.json" % (M, c)
        if os.path.exists(p):
            for n, g in json.load(io.open(p)).items():
                sizes.setdefault(n, g["end"] - g["start"] + 1)

    cache = os.path.join(tree, "sdf-init-cache.json")
    if os.path.exists(cache) and "--rebuild-cache" not in sys.argv:
        units = json.load(io.open(cache))
    else:
        print("parsing SDFLIB once:")
        units = buildCache(tree, sizes, cache)

    aug = json.load(io.open("%s/augmented-%s.json" % (M, cfg)))
    raw = open("%s/%s.fcm" % (M, cfg), "rb").read()
    img = list(struct.unpack(">%dH" % (len(raw) // 2), raw))
    PRINTED = _printed(cfg)

    # symbol -> absolute address, built from the SDFs and the recovered index
    # alone.  A name defined by two units is dropped rather than guessed at.
    where, dup = {}, set()
    for unit, rec in units.items():
        g = aug.get(rec["csect"])
        if not g:
            continue
        for nm, ra, _sz, _fl in rec["syms"]:
            a = g["start"] + ra
            if nm in where and where[nm] != a:
                dup.add(nm)
            where[nm] = a
    for nm in dup:
        where.pop(nm, None)

    corr, stats = [], collections.Counter()
    for unit, rec in units.items():
        g = aug.get(rec["csect"])
        if not g:
            stats["CSECT not in this configuration"] += 1
            continue
        base, init = g["start"], rec["init"]

        for nm, ra, size, flagged in rec["syms"]:
            if not flagged:
                continue
            for k in range(size):
                if ra + k >= len(init) or init[ra + k] != 0:
                    continue
                a = base + ra + k
                if a >= len(img) or img[a] not in FILL or a not in PRINTED:
                    continue
                corr.append({"address": a, "old": img[a], "new": 0,
                             "class": "zero-shown-as-fill", "symbol": nm,
                             "csect": rec["csect"], "offset": ra + k,
                             "unit": unit})
                stats["zero-shown-as-fill"] += 1

        for holder, copy, target in rec["names"]:
            t = where.get(target)
            if t is None and "." in target:
                t = where.get(target.rsplit(".", 1)[1])
            if t is None:
                stats["NAME target unresolved"] += 1
                continue
            h = where.get(holder)
            if h is None:
                stats["NAME holder unresolved"] += 1
                continue
            a = h + (copy - 1)
            if a >= len(img) or img[a] != 0 or a not in PRINTED:
                continue
            corr.append({"address": a, "old": 0, "new": t & 0xFFFF,
                         "class": "name-initial-shown-as-zero",
                         "symbol": holder, "csect": rec["csect"],
                         "target": target, "unit": unit})
            stats["name-initial-shown-as-zero"] += 1

    seen, uniq = set(), []
    for c in sorted(corr, key=lambda c: c["address"]):
        if c["address"] in seen:
            stats["duplicate address dropped"] += 1
            continue
        seen.add(c["address"])
        uniq.append(c)

    print("%s: %d correction(s)" % (cfg, len(uniq)))
    for k, v in sorted(stats.items()):
        print("   %-32s %d" % (k, v))
    if dry:
        return 0
    json.dump(uniq, io.open("%s/corrections-%s.json" % (M, cfg), "w"),
              indent=2)
    for c in uniq:
        img[c["address"]] = c["new"]
    open("%s/corrected-%s.fcm" % (M, cfg), "wb").write(
        struct.pack(">%dH" % len(img), *img))
    print("   wrote corrections-%s.json and corrected-%s.fcm" % (cfg, cfg))
    return 0


if __name__ == "__main__":
    sys.exit(main())
