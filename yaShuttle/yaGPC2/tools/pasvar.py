#!/usr/bin/env python3
"""Read named PASS compool variables out of a yaGPC2 GPC memory image.

    tools/pasvar.py <mem.bin> NAME [NAME ...]       print each variable
    tools/pasvar.py <mem.bin> --list-compool CZ1COM list a compool's variables
    tools/pasvar.py <mem.bin> --check CGMCOM ...    compare a compool's memory
                                                    with its SDF INITIAL image

<mem.bin> is main storage as big-endian halfwords, address = halfword index:
the session-save capture's gpcN.mem.bin, a YAGPC_SNAPSHOT=<t>:<prefix> .bin,
or a DASS dump (PFS/mafgen/*.fcm), which has the same layout.

NAME may carry a subscript, CZEB_COMM_FAULT$(1) or CZEB_COMM_FAULT(1), to
print one element (or one structure copy) only.  A compool can be named
explicitly as CZ1COM:CZEB_COMM_FAULT, which skips the search.

WHERE THE ADDRESS COMES FROM -- two pieces, neither guessed:

  * the variable's offset within its compool CSECT is field 10 of its Symbol
    Data Cell in the compool's SDF ("relative memory address", in HALFWORDS:
    CZ2V_GRT_TAB is 1209 there and opsdiag.py reads the GRT at #PCZ2COM+1209).
    The SDF is read with modules/sdf over modules/cmem, as modules/sdfpkg's
    README describes.  The CSECT is the SDF's own blockCsectName (#P + the
    compool's 6-character name, e.g. #PCZ1COM for CZ1_COMMON).

  * the CSECT's base is the one the tape's link PINNED it to.  tapebuild/
    derive.py hands every phase's lnk101 run --external-syms = PFS/mafgen/
    csects-<CFG>.json (phase 2 SSW, phase 5 G2, ... see its PHASE_CONFIG),
    read at PFSREV 24af1848 by build.sh; that table is the DASS dump's own
    csect table for the configuration.  So the base table here is that same
    file, read from git at the same revision.  --config picks the memory
    configuration (default G2, GNC OPS 2); each configuration's table also
    carries the resident (SSW) compools, at the same addresses.

Every base is only as good as that pinning, so --check exists to test it:
it lays the compool's SDF Initialization Table (the compiler's own image of
its INITIAL values, halfword for halfword from offset 0) over memory at the
computed base and reports how much of it matches.  Run-time variables drift
from their initial values, but a wrong base matches almost nothing.  On an
OPS 2 snapshot (2026-09-30): CGMCOM 360/393 non-zero INITIAL halfwords match
at the base and at most 38 one or two halfwords either side; CZ2COM 355/558
vs <=125; CGMIPC 39/49 vs <=4.  Two more checks hold as well: every G2
compool's SDF initialization image is exactly as long as the csect the table
gives it (83 of 84; the exception is flagged, below), and NAME variables
resolve exactly onto variables -- those their INITIAL(NAME(...)) names.

The SDFs default to PFS/OI340600/SDFLIB, as opsdiag.py's offsets did; the
tape is OI340700.  A compool OI340700 changed shows as an SDF whose length
differs from its csect's, and the tool says so: give --sdflib an OI340700
SDFLIB (~/pass-build/OI340700/SDFLIB is one) for those.

Representation notes:
  * BIT(n), n <= 16, is one halfword, n <= 32 two; the string is right-
    justified and HAL bit 1 is its most significant bit (bit n is the LSB):
    the SDF's INITIAL image has CGZB_ALGN_OPT BIT(3) INITIAL(BIN'100') as 0004.
  * a NAME variable is one halfword (two if REMOTE -- assumed, not seen)
    holding the target's address LESS the target array's bias (SDF field
    16); it is followed and the target printed with the NAME's declared type.
  * arrays are stored with the LAST subscript varying fastest: a 3x4 SCALAR
    has bias 10 = (1*4+1)*2, not (1*3+1)*2.
  * a structure copy is padded to its strictest member's alignment.
  * DENSE bit fields are shown raw, not decoded.
  * SCALAR is IBM System/360 hexadecimal floating point.
"""

import argparse, functools, io, json, os, re, struct, subprocess, sys

HOME = os.path.expanduser("~")
PFS = os.environ.get("PFS", os.path.join(HOME, "workspace", "PFS"))
PFSREV = os.environ.get("PFSREV", "24af1848")      # tapebuild/build.sh's
SDFLIB = os.path.join(PFS, "OI340600", "SDFLIB")
CONFIGS = ("SSW", "G16", "G2", "G3", "G8", "G9", "S2", "P9")

# Symbol Data Cell field 7, symbol type, for class 1 (Variable).
T_BIT16, T_CHAR, T_MAT, T_VEC, T_SCA, T_INT = 1, 2, 3, 4, 5, 6
T_BIT32, T_MATD, T_VECD, T_SCAD, T_INTD = 9, 11, 12, 13, 14
T_STRUC, T_EVENT = 16, 17
TYPENAME = {1: "BIT", 2: "CHARACTER", 3: "MATRIX", 4: "VECTOR", 5: "SCALAR",
            6: "INTEGER", 9: "BIT", 11: "MATRIX DOUBLE", 12: "VECTOR DOUBLE",
            13: "SCALAR DOUBLE", 14: "INTEGER DOUBLE", 16: "STRUCTURE",
            17: "EVENT"}

F_NAME = 0x04000000
F_TEMPLATE = 0x02000000
F_DENSE = 0x00400000
F_REMOTE = 0x00010000
F_CONSTANT = 0x00200000
F_EXTERNAL = 0x00000800


# --------------------------------------------------------------------------
# memory
def load_memory(path):
    b = io.open(path, "rb").read()
    n = len(b) // 2
    return list(struct.unpack(">%dH" % n, b[:2 * n]))


def ibm_float(words):
    """IBM System/360 hex float, single (2 halfwords) or double (4)."""
    v = 0
    for w in words:
        v = (v << 16) | w
    nbits = 16 * len(words)
    sign = -1.0 if v >> (nbits - 1) else 1.0
    exp = ((v >> (nbits - 8)) & 0x7f) - 64
    frac = v & ((1 << (nbits - 8)) - 1)
    return sign * frac / float(1 << (nbits - 8)) * 16.0 ** exp


# --------------------------------------------------------------------------
# SDF
class Sym:
    """One symbol of a compool SDF, reduced to what reading memory needs."""

    def __init__(self, sdfmod, entry, number):
        d = entry.symbolDataCell
        self.number = number
        self.name = sdfmod.fullSymbolASCII(entry).strip()
        self.cls = d.symbolClass
        self.type = d.symbolType
        self.flags = d.flagBits
        self.offset = getattr(d, "relativeMemoryAddressOfSymbol", None)
        self.bits = getattr(d, "numberOfBitsOrCharInString", None)
        self.dense = (getattr(d, "alignment", None),
                      getattr(d, "numberOfBits", None))
        self.rows = getattr(d, "numberOfRows", None)
        self.cols = getattr(d, "numberOfColumns", None)
        nd = getattr(d, "numberOfDimensions", 0) or 0
        self.dims = [getattr(d, "rangeOfDim%d" % (i + 1)) for i in range(nd)]
        self.bias = getattr(d, "valueOfBiasOfArray", 0) or 0
        self.const = getattr(d, "constantValue", None)
        self.template = getattr(d, "symbolNumberOfTemplate", None)
        self.son = getattr(d, "linkToEldestSon", 0) or 0
        self.brother = getattr(d, "linkToBrother", 0) or 0

    @property
    def is_name(self):
        return bool(self.flags & F_NAME)

    def align(self):
        """Alignment in halfwords: 4 for double precision, 2 for other
        fullword data, else 1."""
        if self.is_name:
            return 2 if self.flags & F_REMOTE else 1
        if self.type in (T_SCAD, T_VECD, T_MATD):
            return 4
        if self.type in (T_SCA, T_VEC, T_MAT, T_INTD, T_BIT32) or (
                self.type == T_BIT16 and (self.bits or 16) > 16):
            return 2
        return 1

    def count(self):
        """Elements stored here: a NAME is ONE pointer whatever the
        dimensions of what it points at."""
        return 1 if self.is_name else _count(self.dims)

    def elem_hw(self, comp):
        """Halfwords one element (or one structure copy) occupies."""
        if self.is_name:
            return 2 if self.flags & F_REMOTE else 1
        t = self.type
        if t == T_BIT16:
            return 1 if (self.bits or 16) <= 16 else 2
        if t == T_BIT32:
            return 2
        if t == T_CHAR:
            return 1 + ((self.bits or 0) + 1) // 2
        if t in (T_INT, T_EVENT):
            return 1
        if t in (T_SCA, T_INTD):
            return 2
        if t == T_SCAD:
            return 4
        n = max(self.rows or 1, 1) * max(self.cols or 1, 1)
        if t == T_VEC or t == T_MAT:
            return 2 * n
        if t == T_VECD or t == T_MATD:
            return 4 * n
        if t == T_STRUC:
            return comp.copy_size(self)
        return 1

    def decl(self):
        s = ""
        if self.dims:
            s += "ARRAY(%s) " % ",".join(map(str, self.dims))
        if self.is_name:
            s = "NAME " + s
        tn = TYPENAME.get(self.type, "type%d" % self.type)
        if self.type in (T_BIT16, T_BIT32, T_CHAR):
            tn += "(%s)" % (self.bits if self.bits else
                            (32 if self.type == T_BIT32 else 16))
        elif self.type in (T_VEC, T_VECD):
            tn += "(%d)" % max(self.rows or 1, self.cols or 1)
        elif self.type in (T_MAT, T_MATD):
            tn += "(%d,%d)" % (self.rows or 0, self.cols or 0)
        if self.flags & F_DENSE:
            tn += " DENSE"
        return s + tn


class Compool:
    def __init__(self, name, csect, syms, init):
        self.name, self.csect, self.init = name, csect, init
        self.syms = syms                         # by symbol number, 1-based
        # EXTERNAL symbols are allocated by another compool (##CAASCC
        # declares CZ2COM's CZ2V_ICC_BUF), and a CONSTANT is not allocated
        # at all (every CGMK_* is at "offset" 0); neither is storage here.
        named = [s for s in syms[1:] if s and s.cls == 1]
        self.vars = {s.name: s for s in named if s.offset is not None
                     and not s.flags & (F_EXTERNAL | F_CONSTANT)}
        self.consts = {s.name: s for s in named if s.flags & F_CONSTANT}
        self._copy = {}

    def members(self, tmpl):
        """Template's direct members, in brother order."""
        out, n, seen = [], self.syms[tmpl].son, set()
        while n and n not in seen and n < len(self.syms):
            seen.add(n)
            out.append(self.syms[n])
            n = self.syms[n].brother
        return out

    def terminals(self, tmpl, prefix=""):
        """[(qualified name, Sym)] of a template's terminals, depth first.
        A terminal's offset is relative to the start of a copy."""
        out = []
        for m in self.members(tmpl):
            q = prefix + m.name
            if m.type == T_STRUC and m.son:
                out += self.terminals(m.number, q + ".")
            else:
                out.append((q, m))
        return out

    def copy_size(self, sym):
        t = sym.template
        if t not in self._copy:
            # A copy is padded to its strictest member's alignment: CZ1V_D_MACT
            # ends at 29 halfwords, holds a SCALAR DOUBLE, and its 7 copies
            # take 224 = 7 x 32 (the next variable is at +240 = 16 + 224).
            end, align = 0, 1
            for _, m in self.terminals(t):
                n = m.elem_hw(self) * m.count()
                end = max(end, m.offset + n)
                align = max(align, m.align())
            self._copy[t] = -(-end // align) * align
        return self._copy[t]


def _count(dims):
    n = 1
    for d in dims:
        n *= d
    return n


class SDFLib:
    def __init__(self, path):
        from cmem import cmem
        from sdf import sdf
        self.sdf = sdf
        self.path = path
        self.c = cmem(bytearray(0x400000), path)
        self.c.fromNative({"MISC": 0, "APGAREA": 0x2000, "AFCBAREA": 0,
                           "NPAGES": 64, "NBYTES": 0x400, "ADDR": 0,
                           "PNTR": 0}, commtabl=0x100)
        self.c.monitor22(0, 0x100)
        self.cache = {}

    def has(self, name):
        return os.path.exists(os.path.join(self.path, "##%s.sdf" % name))

    def compool(self, name):
        if name in self.cache:
            return self.cache[name]
        if not self.has(name):
            raise KeyError("no SDF ##%s in %s" % (name, self.path))
        self.c.fromNative({"SDFNAM": "##" + name})
        self.c.monitor22(4)
        s = self.sdf(self.c)
        s.parseSDF()
        csect = self.sdf.convertEbcdicToAscii(s.blockIndexTable[0]
                                              .blockCsectName).strip()
        syms = [None] + [Sym(self.sdf, e, i + 1)
                         for i, e in enumerate(s.symbolIndexTable)]
        cp = Compool(name, csect, syms, list(s.initializationTable))
        self.cache[name] = cp
        return cp


# --------------------------------------------------------------------------
# CSECT bases
@functools.lru_cache(None)
def csect_table(config):
    rel = "mafgen/csects-%s.json" % config
    try:
        txt = subprocess.run(["git", "-C", PFS, "show", "%s:%s" % (PFSREV, rel)],
                             capture_output=True, check=True).stdout
        src = "%s@%s" % (rel, PFSREV)
    except (subprocess.CalledProcessError, FileNotFoundError):
        txt = io.open(os.path.join(PFS, rel), "rb").read()
        src = rel + " (working tree: PFSREV not readable)"
    return json.loads(txt), src


def base_of(csect, config):
    tab, _ = csect_table(config)
    e = tab.get(csect)
    if e is None:
        raise KeyError("%s is not in the %s csect table" % (csect, config))
    return e["start"], e["end"]


# tapebuild/derive.py's PHASE_CONFIG: the configuration whose csect table
# each linked phase was pinned to.
PHASE_CONFIG = {2: "SSW", 3: "G9", 4: "G16", 5: "G2", 6: "G3", 7: "G8",
                8: "G9", 9: "P9", 12: "P9", 14: "S2", 15: "S2", 18: "G9"}


def overlay_note(rd):
    """Which overlay the image says is loaded, from CZ2V_GST.CZ2V_PROG_OVLY
    (resident #PCZ2COM, the same address in every configuration), so a
    --config that does not match the image is caught rather than read."""
    try:
        cp = rd.lib.compool("CZ2COM")
        gst = cp.vars["CZ2V_GST"]
        po = dict((q, m) for q, m in cp.terminals(gst.template))["CZ2V_PROG_OVLY"]
        base, _ = base_of(cp.csect, rd.config)
        step = gst.elem_hw(cp)
        ph = [rd.mem[base + gst.offset + step * i + po.offset]
              for i in range(gst.dims[0])]
    except Exception as e:                        # noqa: advisory only
        return "(could not read CZ2V_PROG_OVLY: %s)" % e
    cfgs = sorted(set(PHASE_CONFIG.get(p, "phase %d" % p) for p in ph if p))
    s = "image: CZ2V_PROG_OVLY per GPC = %s -> %s" % (
        ",".join(map(str, ph)), ", ".join(cfgs) or "none recorded")
    if cfgs and rd.config not in cfgs and rd.config != "SSW":
        s += "   ** --config %s does not match: overlay addresses may be " \
             "wrong **" % rd.config
    return s


# --------------------------------------------------------------------------
# name -> compool index
def build_index(lib, config):
    """{variable name: compool} over every compool SDF whose #P csect the
    configuration's table places.  Cached beside nothing in the repository:
    under ~/.cache/pasvar."""
    tab, _ = csect_table(config)
    stamp = "3|%s|%s|%s|%d" % (lib.path, PFSREV, config,
                             int(os.path.getmtime(lib.path)))
    cdir = os.path.join(HOME, ".cache", "pasvar")
    cfile = os.path.join(cdir, "index-%s.json" % config)
    try:
        j = json.load(io.open(cfile))
        if j.get("stamp") == stamp:
            return j["index"]
    except (OSError, ValueError):
        pass
    idx = {}
    for cs in sorted(tab):
        if not cs.startswith("#P") or not lib.has(cs[2:]):
            continue
        try:
            cp = lib.compool(cs[2:])
        except Exception as e:                    # noqa: one bad SDF only
            print("  (skipping %s: %s)" % (cs[2:], e), file=sys.stderr)
            continue
        # A program's SDF carries the compools it includes, and its block 0
        # names the program's csect (##CGA2MC -> #PCDKANN); only an SDF whose
        # csect is its own #P name is the compool that allocates the storage.
        if cp.csect != cs:
            continue
        for v in list(cp.vars) + list(cp.consts):
            idx.setdefault(v, []).append(cp.name)
    try:
        os.makedirs(cdir, exist_ok=True)
        json.dump({"stamp": stamp, "index": idx}, io.open(cfile, "w"))
    except OSError:
        pass
    return idx


# --------------------------------------------------------------------------
# formatting
def fmt_bits(val, n):
    s = format(val, "0%db" % n)
    grp = " ".join(s[i:i + 4] for i in range(0, n, 4)) if n % 4 == 0 else s
    on = [i + 1 for i, ch in enumerate(s) if ch == "1"]
    return "%s  HAL bits on: %s" % (grp, ",".join(map(str, on)) or "none")


def fmt_value(sym, w, comp):
    """One element of a non-structure, non-NAME symbol, from its halfwords."""
    t = sym.type
    hx = " ".join("%04x" % x for x in w)
    if sym.flags & F_DENSE:
        return "%s  (DENSE, alignment=%s bits=%s: raw halfword, not decoded)" \
            % (hx, sym.dense[0], sym.dense[1])
    if t in (T_BIT16, T_BIT32):
        n = sym.bits or (32 if t == T_BIT32 else 16)
        v = 0
        for x in w:
            v = (v << 16) | x
        v &= (1 << n) - 1
        return "%s  %s" % (hx, fmt_bits(v, n))
    if t == T_INT:
        v = w[0] - 0x10000 if w[0] & 0x8000 else w[0]
        return "%s  %d" % (hx, v)
    if t == T_INTD:
        v = (w[0] << 16) | w[1]
        return "%s  %d" % (hx, v - (1 << 32) if v >> 31 else v)
    if t == T_SCA:
        return "%s  %.9g" % (hx, ibm_float(w))
    if t == T_SCAD:
        return "%s  %.17g" % (hx, ibm_float(w))
    if t in (T_VEC, T_MAT, T_VECD, T_MATD):
        k = 4 if t in (T_VECD, T_MATD) else 2
        return "%s  (%s)" % (hx, ", ".join("%.9g" % ibm_float(w[i:i + k])
                                         for i in range(0, len(w), k)))
    if t == T_CHAR:
        b = b"".join(struct.pack(">H", x) for x in w[1:])
        cur = w[0] & 0xff
        return "%s  '%s'" % (hx, b[:cur].decode("cp037", "replace"))
    return hx


def subscripts(dims):
    """Every subscript tuple of an array, last subscript fastest."""
    if not dims:
        yield ()
        return
    for i in range(1, dims[0] + 1):
        for rest in subscripts(dims[1:]):
            yield (i,) + rest


def elem_index(dims, sub):
    k = 0
    for d, s in zip(dims, sub):
        if not 1 <= s <= d:
            raise IndexError("subscript %s out of range %s" % (sub, dims))
        k = k * d + (s - 1)
    return k


class Reader:
    def __init__(self, mem, lib, config):
        self.mem, self.lib, self.config = mem, lib, config
        self._rev = None

    def hw(self, a, n):
        if a < 0 or a + n > len(self.mem):
            return None
        return self.mem[a:a + n]

    def where(self, comp):
        b, e = base_of(comp.csect, self.config)
        return b, e

    # reverse lookup for NAME targets
    def symbol_at(self, addr):
        if self._rev is None:
            self._rev = []
            tab, _ = csect_table(self.config)
            for cs, e in tab.items():
                self._rev.append((e["start"], e["end"], cs))
        for b, e, cs in self._rev:
            if b <= addr <= e:
                note = "%s+%d" % (cs, addr - b)
                if cs.startswith("#P") and self.lib.has(cs[2:]):
                    cp = self.lib.compool(cs[2:])
                    best = None
                    for v in cp.vars.values():
                        if v.offset <= addr - b and (best is None or
                                                     v.offset > best.offset):
                            best = v
                    if best is not None:
                        n = best.elem_hw(cp) * best.count()
                        if addr - b < best.offset + n:
                            note += " = %s" % best.name
                            if addr - b != best.offset:
                                note += "+%d" % (addr - b - best.offset)
                return note
        return "not in any %s csect" % self.config

    def show(self, comp, sym, sub=None, indent="  ", addr=None, follow=True):
        if addr is None:
            base, _ = self.where(comp)
            addr = base + sym.offset
        esz = sym.elem_hw(comp)
        if sym.is_name:
            self.show_name(comp, sym, sub, indent, addr, follow)
            return
        subs = list(subscripts(sym.dims)) if sub is None else [sub]
        for s in subs:
            a = addr + esz * elem_index(sym.dims, s) if s else addr
            lab = "%s$(%s)" % (sym.name, ",".join(map(str, s))) if s \
                else sym.name
            w = self.hw(a, esz)
            if w is None:
                print("%s%-28s @%05x  (outside the image)" % (indent, lab, a))
                continue
            if sym.type == T_STRUC and sym.template:
                print("%s%-28s @%05x  (copy of %d halfwords)"
                      % (indent, lab, a, esz))
                for q, m in comp.terminals(sym.template):
                    mm = _Qualified(m, q)
                    self.show(comp, mm, None, indent + "    ",
                              a + m.offset, follow)
                continue
            print("%s%-28s @%05x  %s" % (indent, lab, a,
                                         fmt_value(sym, w, comp)))


    def show_name(self, comp, sym, sub, indent, addr, follow):
        """A NAME holds the address of what it points at, less that array's
        bias -- the address its all-zero subscript would have.  The bias is
        the SDF's field 16; CGMV_COMPRES_NIPG (NAME ARRAY(3,4) SCALAR,
        bias 10) holds #PCGMIPC+280 for CGMV_COMPRES_MFE at +290."""
        esz = sym.elem_hw(comp)
        w = self.hw(addr, esz)
        if w is None:
            print("%s%-28s @%05x  (outside the image)" % (indent, sym.name,
                                                          addr))
            return
        ptr = w[-1] if esz == 1 else ((w[0] << 16) | w[1]) & 0x7ffff
        tgt = ptr + sym.bias
        print("%s%-28s @%05x  %s  NAME -> %05x%s  (%s)"
              % (indent, sym.name, addr, " ".join("%04x" % x for x in w), tgt,
                 " (pointer %04x + bias %d)" % (ptr, sym.bias)
                 if sym.bias else "", self.symbol_at(tgt)))
        if follow and ptr:
            self.show(comp, _Pointee(sym), sub, indent + "    ", tgt, False)


class _Pointee:
    """The data a NAME variable points at: the NAME's own declared type and
    dimensions, but not itself a NAME."""

    def __init__(self, s):
        self.__dict__.update(s.__dict__)
        self.flags = s.flags & ~(F_NAME | F_REMOTE)
        self.name = "*" + s.name

    is_name = property(lambda self: False)
    elem_hw = Sym.elem_hw
    decl = Sym.decl
    count = Sym.count
    align = Sym.align


class _Qualified(_Pointee):
    def __init__(self, s, q):
        self.__dict__.update(s.__dict__)
        self.name = q

    is_name = property(lambda self: bool(self.flags & F_NAME))


# --------------------------------------------------------------------------
NAMERE = re.compile(r"^(?:(\w+):)?([A-Z0-9_@#]+)(?:\$?\(([\d, ]+)\))?$", re.I)


def describe(comp, config):
    b, e = base_of(comp.csect, config)
    tab, src = csect_table(config)
    note = ""
    # The SDF's Initialization Table spans the whole compool, so its length
    # must equal the csect the link placed.  It does for 83 of the 84 G2
    # compools with OI340600 SDFs; the exception, #PCDQANN (2010 vs 2695),
    # is one OI340700 changed -- its OI340700 SDF is 2695.
    if len(comp.init) != e - b + 1:
        note = ("\n  ** SDF compool length %d != csect length %d: this SDF is "
                "not the build's (try --sdflib with an OI340700 SDFLIB) **"
                % (len(comp.init), e - b + 1))
    return "%s at %05x-%05x (%s)%s" % (comp.csect, b, e, src, note)


def cmd_names(rd, names, idx):
    for raw in names:
        m = NAMERE.match(raw.strip())
        if not m:
            print("%s: cannot parse" % raw)
            continue
        cpn, var, sub = m.group(1), m.group(2).upper(), m.group(3)
        if cpn:
            cpn = cpn.upper()
        else:
            hits = idx().get(var, [])
            if not hits:
                print("%s: not a variable of any compool in the %s "
                      "configuration" % (var, rd.config))
                continue
            if len(hits) > 1:
                print("%s: declared in %s; using %s (name one as COMPOOL:%s)"
                      % (var, ", ".join(hits), hits[0], var))
            cpn = hits[0]
        comp = rd.lib.compool(cpn)
        sym = comp.vars.get(var)
        if sym is None and var in comp.consts:
            c = comp.consts[var]
            print("%s  CONSTANT %s in %s = %r  (from the SDF; not in memory)"
                  % (var, c.decl(), cpn, c.const))
            continue
        if sym is None:
            print("%s: not in compool %s" % (var, cpn))
            continue
        try:
            print("%s  %s  in %s, offset %d" % (var, sym.decl(), cpn,
                                                 sym.offset))
            print("  %s" % describe(comp, rd.config))
            s = tuple(int(x) for x in sub.split(",")) if sub else None
            rd.show(comp, sym, s)
        except (KeyError, IndexError) as e:
            print("  %s" % e)


def cmd_list(rd, cpn):
    comp = rd.lib.compool(cpn.upper())
    print("%s  %s" % (comp.name, describe(comp, rd.config)))
    try:
        base, _ = rd.where(comp)
    except KeyError:
        base = None
    for s in sorted(comp.vars.values(), key=lambda s: (s.offset, s.name)):
        n = s.elem_hw(comp) * s.count()
        print("  %5d  %s  %3d hw  %-32s %s"
              % (s.offset, "@%05x" % (base + s.offset) if base is not None
                 else "      ", n, s.name, s.decl()))


def cmd_check(rd, cpn):
    comp = rd.lib.compool(cpn.upper())
    base, end = rd.where(comp)
    init = comp.init
    w = rd.hw(base, len(init))
    if w is None:
        print("%s: outside the image" % cpn)
        return
    same = sum(1 for a, b in zip(init, w) if a == b)
    nz = [(i, a) for i, a in enumerate(init) if a]
    nzsame = sum(1 for i, a in nz if w[i] == a)
    print("%s  %s" % (comp.name, describe(comp, rd.config)))
    print("  SDF Initialization Table: %d halfwords; csect table length %d"
          % (len(init), end - base + 1))
    print("  matching at the computed base: %d / %d halfwords;"
          " non-zero INITIAL values: %d / %d" % (same, len(init), nzsame,
                                                 len(nz)))
    # The same test one halfword either side, so a near miss shows as one.
    for d in (-2, -1, 1, 2):
        ww = rd.hw(base + d, len(init))
        if ww:
            k = sum(1 for i, a in nz if ww[i] == a)
            print("    base%+d: non-zero INITIAL values matching %d / %d"
                  % (d, k, len(nz)))


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("mem", help="memory image, big-endian halfwords")
    ap.add_argument("names", nargs="*", help="variables to print")
    ap.add_argument("--list-compool", metavar="COMPOOL", action="append",
                    default=[])
    ap.add_argument("--check", metavar="COMPOOL", action="append", default=[],
                    help="compare memory at the computed base with the "
                         "compool's SDF INITIAL image")
    ap.add_argument("--config", default="G2", choices=CONFIGS,
                    help="memory configuration whose csect table gives the "
                         "bases (default G2: GNC OPS 2)")
    ap.add_argument("--sdflib", default=SDFLIB,
                    help="SDF library (default PFS/OI340600/SDFLIB)")
    a = ap.parse_args()
    if not (a.names or a.list_compool or a.check):
        ap.error("nothing to do: give NAMEs, --list-compool or --check")
    rd = Reader(load_memory(a.mem), SDFLib(a.sdflib), a.config)
    idx = functools.lru_cache(None)(lambda: build_index(rd.lib, a.config))
    print(overlay_note(rd))
    for c in a.list_compool:
        cmd_list(rd, c)
    for c in a.check:
        cmd_check(rd, c)
    cmd_names(rd, a.names, idx)


if __name__ == "__main__":
    main()
