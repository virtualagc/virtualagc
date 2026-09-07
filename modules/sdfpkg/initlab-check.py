#!/usr/bin/env python3
"""What HALSFC emits for each initialization state, asserted against probes.

    initlab-check.py [--keep]

compiles the HAL/S probes in initlab/ and checks the object and the SDF against
what they are known to contain.  Exits 1 on any mismatch.  --keep leaves the
work directory for inspection.

WHY THIS EXISTS.  Four separate theories about HAL/S initialization were argued
from statistics over the corpus and all four were wrong: that the compiler omits
zero initializers, that a zero in the SDF's initialization table is never memory
content, that a per-symbol count of initialized elements must exist, and that
partial initialization is illegal.  A probe compool with unique values and
guards settles each question in about a minute, which is cheaper than any of the
arguments was.  Reach for this before theorising about what the compiler does.

WHAT IS ASSERTED, and where it came from.

  THE EMISSION MODEL.  The object is written in two passes: a BULK pass writing
  0000 across the CSECT that SKIPS certain types, then a pass writing explicit
  initializers.  A halfword neither bulk-zeroed nor explicitly initialized stays
  a HOLE, and the linker fills it with C6C6.  In TSTINIT the bulk pass covers 42
  of 45 halfwords and skips exactly the three INTEGERs; the uninitialized one is
  never written by either pass, while the uninitialized BIT is bulk-zeroed.  So
  BIT is bulk-zeroed and INTEGER is not.

  INITIAL(0) IS EMITTED AS 0000, at the scalar, the INTEGER and the array.

  PARTIAL INITIALIZATION IS LEGAL -- Programmer's Guide USA003087 section 16.3 --
  in two forms: n# for a run of n uninitialized elements anywhere in the list,
  and a trailing * for the remainder.  TSTPRT2 uses both.  TSTPART supplies too
  few elements using NEITHER form and must fail with DI5, which is what makes it
  a probe rather than a mistake.

  THE SDF TABLE CANNOT DISTINGUISH uninitialized from initialized-to-zero: in
  TSTPRT2 it reads 0000 identically at the n# gap, the * remainder and the
  explicit zeros.  That is harmless for a bulk-zeroed type, because the two are
  then the same in memory.  It bites only for a type the bulk pass skips, which
  is why an uninitialized arithmetic field inside a structure reads C6C6.

  THE SYMBOL FIELDS.  reladdr (field 10) is the 0-based CSECT offset; the extent
  is rangeOfDim1 * valueOfBiasOfArray (fields 21 and 16); INITIAL is flag bit 17
  and arrays are bit 16; and symbolClass must be 1, because template terminals
  are class 4 and carry TEMPLATE-relative reladdr that collides with real
  variables -- FLD1/FLD2/FLD3 sit at 0/1/2 against TSTB_GUARD1/TSTB_ZERO/
  TSTB_GUARD2.

ENVIRONMENT.  HALSFC and its passes must be on the PATH, or HALSFC_DIR set;
IBMOBJDUMP names the object dumper.  Note that SRNs in columns 73-80 must be
absent from a probe, or PASS1 parses them as source.
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.realpath(__file__))
LAB = os.path.join(HERE, "initlab")
HALSFC_DIR = os.environ.get(
    "HALSFC_DIR",
    os.path.expanduser("~/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0"))
OBJDUMP = os.environ.get(
    "IBMOBJDUMP",
    os.path.expanduser("~/donschmidt/nsts-sdl-dps/build/bin/ibmobjdump"))

TXT = re.compile(r"^TXT\s+\[\s*\d+\]\s+(\S+)\s+addr=([0-9A-F]+)\s+(\d+) bytes")
HEXL = re.compile(r"^\s+([0-9A-F]{5,6}):\s+((?:[0-9A-F]{4} ?)+)\s*$")

fails = []


def check(what, ok, detail=""):
    print("   %-58s %s" % (what, "ok" if ok else "FAIL"))
    if not ok:
        fails.append(what + ((" -- " + detail) if detail else ""))


def compile(work, name):
    shutil.copy(os.path.join(LAB, name + ".hal"), work)
    for d in ("SDFLIB", "INCLIB", "TEMPLIB"):
        os.makedirs(os.path.join(work, d), exist_ok=True)
    env = dict(os.environ, PATH=HALSFC_DIR + os.pathsep + os.environ["PATH"])
    r = subprocess.run(["HALSFC", name + ".hal"], cwd=work, env=env,
                       capture_output=True, text=True, timeout=1800)
    rpt = os.path.join(work, "current.results", "pass1.rpt")
    return r.returncode, (open(rpt, errors="replace").read()
                          if os.path.exists(rpt) else "")


def esdLengths(work):
    obj = os.path.join(work, "current.results", "cards.bin")
    out = subprocess.run([OBJDUMP, "--no-repro", obj],
                         capture_output=True, text=True, timeout=600).stdout
    d = {}
    for line in out.splitlines():
        m = re.match(r"^ESD\s+\[\s*\d+\]\s+SD\s+(\S+)\s+addr=\S+\s+len=(\d+) hw",
                     line)
        if m:
            d[m.group(1)] = int(m.group(2))
    return d


def coverage(work, csect):
    """(written, image) for one CSECT -- which halfwords any TXT record writes.

    A halfword no record writes is a HOLE, and the linker fills it with C6C6.
    That is the whole point of these probes: alignment padding inside a fully
    initialized structure is such a hole.
    """
    obj = os.path.join(work, "current.results", "cards.bin")
    out = subprocess.run([OBJDUMP, "-x", "--no-repro", obj],
                         capture_output=True, text=True, timeout=600).stdout
    cov, image, cur = set(), {}, None
    for line in out.splitlines():
        m = TXT.match(line)
        if m:
            cur = (m.group(1), int(m.group(2), 16))
            continue
        h = HEXL.match(line)
        if h and cur and cur[0] == csect:
            for i, v in enumerate(h.group(2).split()):
                a = int(h.group(1), 16) + i
                cov.add(a)
                image[a] = int(v, 16)
    return cov, image


def rldAddresses(work, csect):
    """Halfword addresses the object asks the linker to relocate.

    A NAME pointer is stored as the target's CSECT-RELATIVE offset with a YCON
    relocation over it, so what lands in memory is the target's ABSOLUTE
    address.  Without checking the RLDs one would compute a relative value and
    compare it against an absolute one, which is what made the first attempt at
    class B wrong at every site.
    """
    obj = os.path.join(work, "current.results", "cards.bin")
    out = subprocess.run([OBJDUMP, "--no-repro", obj],
                         capture_output=True, text=True, timeout=600).stdout
    a = set()
    for line in out.splitlines():
        m = re.match(r"^RLD\s+\S+\s+(\S+)\s+->\s+\S+\s+addr=([0-9A-F]+)", line)
        if m and m.group(1) == csect:
            a.add(int(m.group(2), 16))
    return a


def objectPasses(work):
    """(bulk, explicit, image) -- the halfwords each pass writes, and the result.

    Records arrive in emission order, so the first group is the bulk pass and
    what follows overwrites it; the image is simply every record applied in
    order, which is what the loader sees.
    """
    obj = os.path.join(work, "current.results", "cards.bin")
    out = subprocess.run([OBJDUMP, "-x", "--no-repro", obj],
                         capture_output=True, text=True, timeout=600).stdout
    recs, cur = [], None
    for line in out.splitlines():
        m = TXT.match(line)
        if m:
            cur = [int(m.group(2), 16), []]
            recs.append(cur)
            continue
        h = HEXL.match(line)
        if h and cur is not None:
            cur[1].extend(int(v, 16) for v in h.group(2).split())
    image, seen = {}, []
    for addr, vals in recs:
        hws = set(range(addr, addr + len(vals)))
        seen.append(hws)
        for i, v in enumerate(vals):
            image[addr + i] = v
    bulk = seen[0] if seen else set()
    rest = set().union(*seen[1:]) if len(seen) > 1 else set()
    # the bulk pass is the leading run of records that only write zeros
    n = 0
    for addr, vals in recs:
        if any(vals):
            break
        n += 1
    bulk = set().union(*seen[:n]) if n else set()
    rest = set().union(*seen[n:]) if len(seen) > n else set()
    return bulk, rest, image


def sdfOf(work, member):
    for p in ("modules/sdfpkg/sdfpkg", "modules/sdf/sdf", "modules/cmem/cmem"):
        sys.path.insert(0, os.path.expanduser("~/git/virtualagc/" + p))
    from sdfpkg import sdfpkg
    here = os.getcwd()
    os.chdir(work)
    try:
        mem = bytearray(0x100000)
        C = {k: None for k in
             ("APGAREA AFCBAREA NPAGES NBYTES MISC CRETURN BLKNO SYMBNO STMTNO "
              "BLKNLEN SYMBNLEN PNTR ADDR SDFNAM CSECTNAM SREFNO INCLCNT "
              "BLKNAM SYMBNAM").split()}
        p = sdfpkg(mem, "SDFLIB", C)
        C.update({"MISC": 0, "APGAREA": 0x100000, "AFCBAREA": 0x10000,
                  "NPAGES": 1, "NBYTES": 1024, "ADDR": 0, "PNTR": 0})
        p.sdfpkg(0, 0x1000)
        C["SDFNAM"] = member
        p.sdfpkg(4)
        p.s.verbose = False
        p.s.parseSDF()
        return p.s
    finally:
        os.chdir(here)


def symbols(s):
    from sdf import sdf as SDF
    out = {}
    for sym in (getattr(s, "symbolIndexTable", None) or []):
        c = getattr(sym, "symbolDataCell", None)
        if c is None:
            continue
        out[SDF.fullSymbolASCII(sym).strip()] = c
    return out


def main():
    work = tempfile.mkdtemp(prefix="initlab-")
    keep = "--keep" in sys.argv
    try:
        INIT = 1 << (31 - 17)
        ARR = 1 << (31 - 16)

        print("TSTINIT -- emission model, INITIAL(0), and the symbol fields")
        rc, rpt = compile(work, "TSTINIT")
        check("compiles", rc == 0, "rc=%d" % rc)
        if rc:
            return 1
        bulk, rest, image = objectPasses(work)
        check("the bulk pass skips exactly the three INTEGERs",
              sorted(set(range(45)) - bulk) == [7, 9, 11],
              str(sorted(set(range(45)) - bulk)))
        check("the uninitialized INTEGER is a hole, written by neither pass",
              9 not in bulk and 9 not in rest)
        check("the uninitialized BIT is bulk-zeroed to 0000",
              3 in bulk and image.get(3) == 0)
        check("INITIAL(HEX'0000') on a BIT emits 0000", image.get(1) == 0)
        check("INITIAL(0) on an INTEGER emits 0000",
              7 in rest and image.get(7) == 0)
        check("INITIAL(HEX'0000') on ARRAY(4) emits four 0000",
              all(image.get(i) == 0 for i in range(13, 17)))
        check("a non-zero INTEGER initializer survives", image.get(11) == 0x1001)

        s = sdfOf(work, "##TSTINI")
        tab = list(getattr(s, "initializationTable", None) or [])
        check("the SDF table is the CSECT image", len(tab) == 45)
        check("the SDF table equals the object, halfword for halfword",
              all(tab[i] == image.get(i, 0) for i in range(len(tab))))
        sy = symbols(s)
        for nm, want in (("TSTB_ZERO", True), ("TSTB_UNINIT", False),
                         ("TSTI_ZERO", True), ("TSTI_UNINIT", False),
                         ("TSTB_ARR_ALLZERO", True), ("TSTB_ARR_UNINIT", False),
                         ("TSTK_RECS", True), ("TSTK_RECU", False)):
            c = sy.get(nm)
            got = bool(c and (getattr(c, "flagBits", 0) or 0) & INIT)
            check("INITIAL flag on %-17s is %s" % (nm, want), got == want)
        for nm, ra in (("TSTB_GUARD1", 0), ("TSTB_ZERO", 1), ("TSTI_UNINIT", 9),
                       ("TSTK_RECS", 28), ("TSTB_GUARDC", 44)):
            c = sy.get(nm)
            check("reladdr of %-17s is the CSECT offset %d" % (nm, ra),
                  c is not None and
                  getattr(c, "relativeMemoryAddressOfSymbol", None) == ra)
        for nm, ext in (("TSTB_ARR_ALLZERO", 4), ("TSTK_RECS", 9),
                        ("TSTK_RECU", 6)):
            c = sy.get(nm)
            got = ((getattr(c, "rangeOfDim1", 0) or 0)
                   * (getattr(c, "valueOfBiasOfArray", 0) or 0)) if c else 0
            check("rangeOfDim1*bias for %-14s is %d" % (nm, ext), got == ext)
        check("an array carries flag bit 16",
              bool((getattr(sy["TSTB_ARR_ALLZERO"], "flagBits", 0) or 0) & ARR))
        check("a variable is symbolClass 1",
              getattr(sy["TSTB_ZERO"], "symbolClass", None) == 1)
        check("a template terminal is symbolClass 4",
              getattr(sy["FLD1"], "symbolClass", None) == 4)
        check("template terminals collide with variables on reladdr",
              getattr(sy["FLD2"], "relativeMemoryAddressOfSymbol", None)
              == getattr(sy["TSTB_ZERO"], "relativeMemoryAddressOfSymbol", None))

        print("\nTSTPRT2 -- legal partial initialization, and the ambiguity")
        rc, rpt = compile(work, "TSTPRT2")
        check("n# and trailing * both compile", rc == 0, "rc=%d" % rc)
        if rc == 0:
            bulk, rest, image = objectPasses(work)
            check("the bulk pass covers the whole CSECT",
                  set(range(28)) <= bulk)
            check("the n# run is left unwritten by the explicit pass",
                  not ({3, 4, 5} & rest))
            check("the * remainder is left unwritten by the explicit pass",
                  not (set(range(12, 18)) & rest))
            s2 = sdfOf(work, "##TSTPRT")
            t2 = list(getattr(s2, "initializationTable", None) or [])
            check("the table cannot distinguish n#, * and explicit zero",
                  all(v == 0 for v in t2[3:6] + t2[12:18] + t2[20:26]))

        print("\nTSTPROG -- a PROGRAM's table is segmented per block")
        rc, rpt = compile(work, "TSTPROG")
        check("compiles", rc == 0, "rc=%d" % rc)
        if rc == 0:
            s3 = sdfOf(work, "##TSTPRO")
            t3 = list(getattr(s3, "initializationTable", None) or [])
            sy3 = symbols(s3)
            lens = esdLengths(work)
            check("the data CSECT is exactly as long as the table",
                  lens.get("#DTSTPRO") == len(t3), str(lens.get("#DTSTPRO")))
            for nm, ra, v in (("TSRB_MAIN1", 6, 0x9991), ("TSRB_MAIN2", 7, 0x9992),
                              ("TSRB_PROC1", 12, 0xAAA1), ("TSRB_PROC2", 13, 0xAAA2),
                              ("TSRI_FUN1", 18, 0x7531), ("TSRB_FUN2", 19, 0xBBB2)):
                c = sy3.get(nm)
                check("%-11s of block %s sits at %2d holding %04X"
                      % (nm, getattr(c, "blockIndexNumber", "?"), ra, v),
                      c is not None
                      and getattr(c, "relativeMemoryAddressOfSymbol", None) == ra
                      and ra < len(t3) and t3[ra] == v)
            check("the three blocks are numbered 1, 2, 3 in the table",
                  [t3[4], t3[10], t3[16]] == [1, 2, 3],
                  str([t3[4], t3[10], t3[16]]))
            check("the PROGRAM's segment header carries 18, its stack size",
                  t3[5] == 18, str(t3[5]))
            check("a local carries no COMPOOL flag, unlike a compool variable",
                  not ((getattr(sy3["TSRB_MAIN1"], "flagBits", 0) or 0) >> 31))

        print("\nTSTMIX -- alignment padding is a hole, even when initialized")
        rc, rpt = compile(work, "TSTMIX")
        check("compiles", rc == 0, "rc=%d" % rc)
        if rc == 0:
            cov, img = coverage(work, "#PTSTMIX")
            s4 = sdfOf(work, "##TSTMIX")
            t4 = list(getattr(s4, "initializationTable", None) or [])
            sy4 = symbols(s4)
            c = sy4.get("TSMK_FULL")
            check("TSMK_FULL is INITIAL and spans 3 copies of 6 halfwords",
                  c is not None and (getattr(c, "rangeOfDim1", 0) or 0) == 3
                  and (getattr(c, "valueOfBiasOfArray", 0) or 0) == 6)
            check("though fully initialized, its SCALAR padding is never written",
                  not ({5, 11, 17} & cov), str(sorted({5, 11, 17} & cov)))
            check("and the SDF table reads 0000 at that padding",
                  all(t4[i] == 0 for i in (5, 11, 17)))
            check("SCALAR INITIAL(0) emits 0000 0000",
                  img.get(36) == 0 and img.get(37) == 0)
            check("an uninitialized SCALAR is never written",
                  not ({38, 39} & cov))
            check("in an uninitialized structure only BIT fields are bulk-zeroed",
                  img.get(22) == 0 and img.get(24) == 0
                  and not ({23, 25, 26, 27} & cov))

        print("\nTSTNAME -- where a NAME pointer lands and what it holds")
        rc, rpt = compile(work, "TSTNAME")
        check("compiles", rc == 0, "rc=%d" % rc)
        if rc == 0:
            s5 = sdfOf(work, "##TSTNAM")
            t5 = list(getattr(s5, "initializationTable", None) or [])
            sy5 = symbols(s5)
            rld = rldAddresses(work, "#PTSTNAM")
            NAMEF = 1 << (31 - 5)

            def ra(n):
                c = sy5.get(n)
                return getattr(c, "relativeMemoryAddressOfSymbol", None) if c else None

            for ptr, tgt in (("TSNP_PTR1", "TSNI_TARGET1"),
                             ("TSNP_PTR2", "TSNI_TARGET2")):
                p_, t_ = ra(ptr), ra(tgt)
                check("%s holds %s's CSECT-relative offset" % (ptr, tgt),
                      p_ is not None and t_ is not None
                      and p_ < len(t5) and t5[p_] == t_,
                      "table[%s]=%s want %s" % (p_, t5[p_] if p_ is not None
                                                and p_ < len(t5) else "?", t_))
            check("a NAME pointer occupies one halfword",
                  ra("TSNP_PTR2") - ra("TSNP_PTR1") == 2)   # a guard sits between
            check("every pointer carries a YCON relocation, so memory is absolute",
                  {ra("TSNP_PTR1"), ra("TSNP_PTR2")} <= rld,
                  "rld=%s" % sorted(rld))
            h = ra("TSNK_RECS")
            check("both copies of the NAME structure are initialized",
                  [t5[h + k] for k in range(4)]
                  == [ra("TSNI_TARGET1"), ra("TSNI_TARGET2"),
                      ra("TSNI_TARGET2"), ra("TSNI_TARGET1")],
                  str([t5[h + k] for k in range(4)]))
            check("and all four are relocated",
                  set(range(h, h + 4)) <= rld)
            for f in ("NFLD1", "NFLD2"):
                check("template terminal %s carries the NAME flag, bit 5" % f,
                      bool((getattr(sy5[f], "flagBits", 0) or 0) & NAMEF))
            check("NAME terminals sit at template offsets 0 and 1",
                  (ra("NFLD1"), ra("NFLD2")) == (0, 1))
            nti = getattr(s5, "nameTerminalInitialization", None) or {}
            tbl5 = getattr(s5, "symbolIndexTable", None) or []
            recs = None
            for k, v in nti.items():
                from sdf import sdf as SDF
                if SDF.fullSymbolASCII(tbl5[k - 1]).strip() == "TSNK_RECS":
                    recs = v
            check("nameTerminalInitialization describes TSNK_RECS", recs is not None)
            if recs:
                check("its first element is the TERMINAL ORDINAL, not a copy number",
                      [(o, t) for o, t, _r, _l in recs]
                      == [(1, "TSNI_TARGET1"), (2, "TSNI_TARGET2")], str(recs))

        print("\nTSTPART -- too few elements, using neither legal form")
        rc, rpt = compile(work, "TSTPART")
        check("is rejected", rc != 0, "rc=%d" % rc)
        check("with DI5, TOO FEW ELEMENTS SUPPLIED IN INITIAL LIST",
              "DI5" in rpt and "TOO FEW ELEMENTS SUPPLIED" in rpt)
    finally:
        if keep:
            print("\nwork directory kept: %s" % work)
        else:
            shutil.rmtree(work, ignore_errors=True)

    print()
    if fails:
        print("%d CHECK(S) FAILED:" % len(fails))
        for f in fails:
            print("   %s" % f)
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
