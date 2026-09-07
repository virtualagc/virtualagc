#!/usr/bin/env python3
"""Restore the initialization values MAFGEN failed to print, from the SDFs.

    dass-corrections.py <build-tree> <config> [--dry-run] [--rebuild-cache]
                        [--contested]

writes, beside the recovered images in PFS/mafgen:

    corrections-<cfg>.json   every correction, with its evidence
    corrected-<cfg>.fcm      <cfg>.fcm with those corrections applied

THE BUG THIS CORRECTS.  A variable that HAL/S initializes to zero often appears
in the DASS report with NO HEXADECIMAL VALUE AT ALL, so unlinkMAFGEN2 has
nothing to extract and synthesises fill from the address -- C9FB below 0x20000,
C6C6 above.  The memory held zeros; the report simply failed to state them.
Proving that the unprinted values should have been printed is the whole purpose
of reading the SDFs, and it is what this does.

<cfg>.fcm is never modified.  It is the primary artefact of the listing, and the
corrected image is derived from it.

WHAT IS CORRECTED, and nothing else.  An address is corrected when all of these
hold, none of which consults our build:

  * an SDF symbol of class 1 in its own block carries the INITIAL flag (bit 17)
    and its initialization table entry for that halfword is zero;
  * the halfword is a real element, not structure alignment padding -- padding
    is excluded by walking the template terminals, since a fully initialized
    structure still leaves its padding unwritten;
  * the DASS listing prints NO value for the address, so what stands there is
    unlinkMAFGEN2's synthesised fill rather than anything read from the dump;
  * and the reference does hold fill there, confirming that is what happened.

CONTESTED CSECTS.  Where two CSECTs' index ranges overlap, an address belongs to
both and the dump may hold either one's content.  Such an address is corrected
only when every claiming CSECT agrees the value is zero, and only with
--contested; by default they are left alone.

THE INDEPENDENT CHECK.  Nothing here reads a link/ image, so the tool runs with
every build artefact deleted.  That keeps one measurement honest: our own build,
compiled from the same sources but never consulted, holds 0000 at 95.4% of the
addresses this corrects.  Two independent routes agreeing is the evidence that
the corrections are right -- and it is evidence only while they stay
independent.

HOW THE SEMANTICS WERE ESTABLISHED: by compiling probe compools, not by argument
over the corpus.  See initlab-check.py, which asserts them.  INITIAL(0) really
is emitted as 0000; the SDF's table cannot distinguish an uninitialized element
from a zero one, which is harmless for a bulk-zeroed type and decisive for
padding; reladdr is the 0-based CSECT offset; the extent is rangeOfDim1 times
valueOfBiasOfArray; and symbolClass must be 1, because template terminals carry
template-relative offsets that collide with real variables.

A NOTE ON HOW THIS WAS NEARLY MISSED.  An earlier pass gated on addresses the
listing PRINTED, reasoning that an absent report cannot be a wrong one.  That
excluded the entire phenomenon, since the bug IS the absence, and the analysis
duly reported that the class did not exist.  A second gate required a symbol's
non-zero initial values to corroborate its mapping -- which no all-zero variable
can supply, so exactly the variables at issue were dropped.  Neither gate is
here.  If a future change reinstates either, it will find nothing, and that
finding will mean nothing.
"""

import collections
import io
import json
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
for _p in ("modules/sdfpkg/sdfpkg", "modules/sdf/sdf", "modules/cmem/cmem"):
    sys.path.insert(0, os.path.expanduser("~/git/virtualagc/" + _p))

from dasspfs import mafgenDir                                    # noqa: E402

OBJDUMP = os.environ.get(
    "IBMOBJDUMP",
    os.path.expanduser("~/donschmidt/nsts-sdl-dps/build/bin/ibmobjdump"))
FILL = {0xC6C6, 0xC9FB}
INITIAL_FLAG = 1 << (31 - 17)
NAME_FLAG = 1 << (31 - 5)
# halfwords per field, by symbolType, measured by initlab/TSTTYPE.  CHARACTER
# and VECTOR depend on the declared length rather than the type, so they are
# not here: only their first halfword is claimed and the rest left alone.
FIXED = {1: 1, 9: 2, 6: 1, 14: 2, 5: 2, 13: 4}
CFGS = ["SSW", "G16", "G2", "G3", "G8", "G9", "P9", "S2"]


def printedAddresses(cfg):
    """dass-score's own definition of what the listing states a value for."""
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


def templateOffsets(tbl, index, seen):
    """Halfword offsets a template's terminals occupy, so padding is excluded.

    A fully initialized structure still leaves its alignment padding unwritten,
    so those halfwords are fill in memory however the table reads.  Recursing
    through nested templates keeps their terminals rather than the parent.
    """
    out = set()
    if not (1 <= index <= len(tbl)) or index in seen:
        return out
    seen.add(index)
    cell = getattr(tbl[index - 1], "symbolDataCell", None)
    if cell is None:
        return out
    j = getattr(cell, "linkToEldestSon", 0) or 0
    while 1 <= j <= len(tbl) and j not in (0, 0xFFFF):
        c = getattr(tbl[j - 1], "symbolDataCell", None)
        if c is None:
            break
        son = getattr(c, "linkToEldestSon", 0) or 0
        if son and son != 0xFFFF:
            out |= templateOffsets(tbl, j, seen)
        else:
            off = getattr(c, "relativeMemoryAddressOfSymbol", None)
            if off is not None:
                r1 = getattr(c, "rangeOfDim1", 0) or 0
                bi = getattr(c, "valueOfBiasOfArray", 0) or 0
                n = (r1 * bi) if (r1 and bi) else \
                    FIXED.get(getattr(c, "symbolType", None), 1)
                out |= set(range(off, off + n))
        j = getattr(c, "linkToBrother", 0) or 0
        if j == 0xFFFF:
            break
    return out


def relocatedHalfwords(tree):
    """(CSECT, offset) pairs an object asks the link editor to relocate.

    An address constant's initialization-table entry is the UNRELOCATED value,
    normally zero, so the SDF says "zero" while memory holds base+0 -- the
    target CSECT's address.  Correcting such a halfword to zero overwrites a
    real pointer, which is what 666 of these corrections did before this guard,
    #DDMTERR's 152 among them.

    In an RLD line the CONTAINER is the SECOND name and addr is an offset within
    it: "#PCANNCO -> #DDMTERR addr=00014" is a pointer to #PCANNCO living at
    halfword 0x14 of #DDMTERR.  Reading that backwards is easy and costly.  A
    fullword ADCON is flagged at its even offset while the address occupies the
    odd halfword after it, and a halfword YCON is flagged at the pointer itself,
    so both o and o+1 are withheld.
    """
    import subprocess
    objs = os.path.join(tree, "objects")
    if not os.path.isdir(objs):
        return {}
    files = [os.path.join(objs, f) for f in sorted(os.listdir(objs))
             if f.endswith(".obj")]
    if not files:
        return {}
    out = subprocess.run([OBJDUMP, "--no-repro"] + files,
                         capture_output=True, text=True, timeout=1800).stdout
    pat = re.compile(r"^RLD\s+\S+(?:\([-+]\))?\s+(\S+)\s+->\s+(\S+)"
                     r"\s+addr=([0-9A-F]+)")
    out2 = collections.defaultdict(set)
    for line in out.splitlines():
        m = pat.match(line)
        if m:
            o = int(m.group(3), 16)
            out2[m.group(2)].update((o, o + 1))
    return out2


def buildCache(tree, sizes, path):
    """unit -> CSECT and the zero-initialized halfwords its symbols declare.

    Parsing is about 0.06s a unit, cheap once and far too dear eight times.
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
            stats["CSECT ambiguous" if hit else "CSECT not identified"] += 1
            continue
        tbl = getattr(s, "symbolIndexTable", None) or []
        zeros = []
        for sym in tbl:
            c = getattr(sym, "symbolDataCell", None)
            if c is None or getattr(c, "symbolClass", None) != 1:
                continue
            if getattr(c, "blockIndexNumber", None) != 1:
                continue
            if not (getattr(c, "flagBits", 0) or 0) & INITIAL_FLAG:
                continue
            ra = getattr(c, "relativeMemoryAddressOfSymbol", None)
            if ra is None:
                continue
            r1 = getattr(c, "rangeOfDim1", 0) or 0
            bi = getattr(c, "valueOfBiasOfArray", 0) or 0
            n = r1 * bi or 1
            if getattr(c, "symbolType", None) == 16 and bi:
                occ = templateOffsets(
                    tbl, getattr(c, "symbolNumberOfTemplate", 0) or 0, set())
                if not occ:
                    stats["template unreadable, structure skipped"] += 1
                    continue
                span = [k for k in range(n) if k % bi in occ]
            else:
                span = range(n)
            # A CHARACTER's buffer is only emitted as far as it is used.  Its
            # first halfword is (maximum length, current length), so
            # ceil((2 + current) / 2) halfwords carry data and the rest of the
            # declared extent is a hole the link editor fills.  The SDF pads
            # that tail with zeros -- CVSP_MESSAGE_TEXT, ARRAY(15)
            # CHARACTER(34), reads 2201 2000 then sixteen zeros a copy -- and
            # correcting them wrote zeros over 240 halfwords of fill in
            # #PCVTTCS alone.  The padding is the SDF's, not the memory's.
            if getattr(c, "symbolType", None) == 2:
                elems, esz = (r1, bi) if (r1 and bi) else (1, n)
                tail = set()
                for e in range(elems):
                    b0 = ra + e * esz
                    if b0 >= len(init):
                        break
                    used = (2 + (init[b0] & 0xFF) + 1) // 2
                    tail.update(range(e * esz + used, e * esz + esz))
                span = [k for k in span if k not in tail]
            nm = SDF.fullSymbolASCII(sym).strip()
            for k in span:
                if ra + k < len(init) and init[ra + k] == 0:
                    zeros.append([ra + k, nm])
        if zeros:
            out[unit] = {"csect": hit[0], "zeros": zeros}
            stats["usable"] += 1
    os.chdir(here)
    json.dump(out, io.open(path, "w"))
    for k, v in sorted(stats.items()):
        print("   %-36s %d" % (k, v))
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry-run" in sys.argv
    withContested = "--contested" in sys.argv
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

    cache = os.path.join(tree, "sdf-zeros-cache.json")
    if os.path.exists(cache) and "--rebuild-cache" not in sys.argv:
        units = json.load(io.open(cache))
    else:
        print("parsing SDFLIB once:")
        units = buildCache(tree, sizes, cache)

    aug = json.load(io.open("%s/augmented-%s.json" % (M, cfg)))
    raw = open("%s/%s.fcm" % (M, cfg), "rb").read()
    img = list(struct.unpack(">%dH" % (len(raw) // 2), raw))
    printed = printedAddresses(cfg)
    relocated = relocatedHalfwords(tree)

    rng = sorted((g["start"], g["end"], n) for n, g in aug.items())
    contested = set()
    for i in range(len(rng) - 1):
        for j in range(i + 1, len(rng)):
            if rng[j][0] > rng[i][1]:
                break
            contested.add(rng[i][2])
            contested.add(rng[j][2])

    # An address claimed by more than one CSECT is corrected only when every
    # claim agrees; a symbol declaring it zero in one CSECT and a value in
    # another is exactly the ambiguity a contested range creates.
    claim = collections.defaultdict(list)
    for unit, rec in units.items():
        g = aug.get(rec["csect"])
        if not g:
            continue
        if rec["csect"] in contested and not withContested:
            continue
        rl = relocated.get(rec["csect"], ())
        for off, nm in rec["zeros"]:
            if off in rl:
                continue                      # an address constant, not a zero
            a = g["start"] + off
            if a < len(img):
                claim[a].append((rec["csect"], nm, unit))

    corr, stats = [], collections.Counter()
    for a, who in sorted(claim.items()):
        if a in printed:
            stats["the listing states a value: left alone"] += 1
            continue
        if img[a] not in FILL:
            stats["not synthesised fill: left alone"] += 1
            continue
        cs = {c for c, _n, _u in who}
        if len(cs) > 1:
            stats["contested, claims agree"] += 1
        corr.append({"address": a, "old": img[a], "new": 0,
                     "class": "initial-zero-never-printed",
                     "symbol": who[0][1], "csect": who[0][0],
                     "unit": who[0][2],
                     "alsoClaimedBy": sorted(cs - {who[0][0]}) or None})
        stats["CORRECTED to 0000"] += 1

    print("%s: %d correction(s)" % (cfg, len(corr)))
    for k, v in sorted(stats.items()):
        print("   %-40s %d" % (k, v))
    if dry:
        return 0
    json.dump(corr, io.open("%s/corrections-%s.json" % (M, cfg), "w"), indent=2)
    for c in corr:
        img[c["address"]] = c["new"]
    open("%s/corrected-%s.fcm" % (M, cfg), "wb").write(
        struct.pack(">%dH" % len(img), *img))
    print("   wrote corrections-%s.json and corrected-%s.fcm" % (cfg, cfg))
    return 0


if __name__ == "__main__":
    sys.exit(main())
