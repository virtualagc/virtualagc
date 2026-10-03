#!/usr/bin/env python3
"""THE DOWNLIST DECODE TABLE: which PASS variable is in each word of each
downlist frame, generated from the flight source, once per release.

    python3 dltable.py [--release OI340700] [--out FILE] [--report]
    python3 dltable.py --release OI340600 --root ~/workspace/PFS/OI340600 \\
                       --sdflib ~/workspace/PFS/OI340600/SDFLIB

writes downlist-<RELEASE>.json beside this file: for every format ID PASS
can put on the downlist, frame number 0-49 and word 1..N (word 1 is the
EB90 sync, HAL's DL(1)), the variable (element, component) that word holds,
its declared type, how many halfwords it spans, and the measurement cards
(MSID, units, A0/A1 calibration, discrete bit and S0/S1 labels) the source
attaches to it.  downlist.py decodes frames with it; groundstation.py
downlink --decode shows and logs the values.

WHERE IT COMES FROM

  * The frame is built every minor cycle by DCD_DOW (APPLSRC/DCDDOW.hal):
    word 1 is the CDWV_DWNLST INITIAL value EB90 and never rewritten; in
    frames 0 and 25, word 3 = vehicle || GPC || mission ID and words 4-6
    the FCOS time TFCMLTQM, TFCMLTQH; then the OPS 0 members DCD12025,
    DCD12012, DCD12005, DCD12001 run in EVERY major mode, then the loaded
    memory configuration's formatter (DCD_DG1/DG2/DG3/DS2/DS4/DS8/DG8/DG9)
    its own four members INCL80/DCD1FFRR (FF the format, RR the rate 25,
    12 = 12.5, 05, 01 samples a second); last, word 2 = frame number ||
    format ID.  So a format's frame is the OPS 0 layout overwritten by the
    format's own -- the simulation below runs them in that order.
  * A member is `DO; /* FRAME k */ ... END;` blocks selected by DO CASE on
    CDWV_CNTR_12 = frame mod 2 + 1 (DCDDOW 015200), CDWV_CNTR_1 = frame mod
    25 + 1 (016800-017000) and CDWV_CNTR_5 = frame mod 5 + 1 (017400); the
    25 s/s member's one block runs every frame.
  * Statements are %COPY(DL(n), X, k) -- k halfwords from X's address,
    across whatever variables follow X in its compool -- DL(n) = X (an
    assignment, converted to INTEGER), and the same into HS(n), the
    formatter's HS_BUFFER, which is filled in frame 0's block (so at frames
    0 and 25) and copied out in later frames: such words carry data sampled
    at frame 0 or 25 (flag "hs").
  * DL is REPLACE DL(WRD) BY "CDWV_DWNLST$(1;WRD:)" (CDWDOWNL.hal): a
    persistent buffer.  A word a frame does not write keeps what an earlier
    frame put there; the table carries those too, flagged "stale" with the
    frame that wrote it, and the decoder skips them unless asked.
  * Addresses come from the compilers' SDFs (modules/sdfpkg), through
    yaGPC2/tools/pasvar.py's reader: a variable's halfword offset in its
    compool, array bias and ordering (last subscript fastest), structure
    copy size, element size by type.  A %COPY's halfwords are named by
    looking up what the compool holds at each offset, so a copy that runs
    across several variables is named variable by variable.
  * Measurement cards are the source's comment cards
    `C M=<MSID> N=<variable> T= L= B= U= S0= S1= A0= A1= X=`; their N= is
    resolved to an offset the same way, so a card meets a downlist word by
    address, not by spelling.  A second card with the same M= and no N=
    adds units and calibration.

A release's tree may be an overlay: --root takes the release's own tree
first and the base after it (OI340700 replaces DCDDS2, DCD12401, DCD12601,
DCD16001 and takes the rest from OI340600).  --sdflib must be the SDFs of
that release's compilation.
"""

import argparse
import datetime
import glob
import io
import json
import os
import re
import sys
from collections import OrderedDict, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "yaGPC2", "tools"))
import pasvar  # noqa: E402  (the SDF reader and its layout rules)

HOME = os.path.expanduser("~")
PFS = os.environ.get("PFS", os.path.join(HOME, "workspace", "PFS"))

RELEASES = {
    "OI340700": {"roots": [os.path.join(PFS, "OI340700"), os.path.join(PFS, "OI340600")],
                 "sdflib": os.path.join(HOME, "pass-build", "OI340700", "SDFLIB")},
    "OI340600": {"roots": [os.path.join(PFS, "OI340600")],
                 "sdflib": os.path.join(PFS, "OI340600", "SDFLIB")},
}

SRCDIRS = ("APPLSRC", "INCL80", "SSSRC")

# Format ID -> (formatter, member prefix, OPS for MSID choice, HDR format if
# this is its low-data-rate twin).  The frame lengths are read from each
# formatter's FRAME_LENGTH_OF_nn / LDR_SIZE_OF_nn constants.
#   DCDDOW 004000:  GNC 1/6 DG1, GNC 2 DG2, GNC 3 DG3, GNC 8 DG8, GNC 9 DG9,
#                   SM 2 DS2, SM 4 DS4, PL 9 DS8.
FORMATS = OrderedDict([
    (20, ("DCDDOW", "120", 0, None)),
    (21, ("DCDDG1", "121", 1, None)),
    (22, ("DCDDG2", "122", 2, None)),
    (62, ("DCDDG2", "122", 2, 22)),      # DCD_FORMATS (62, 22): LDR, HDR
    (23, ("DCDDG3", "123", 3, None)),
    (32, ("DCDDG8", "132", 8, None)),
    (72, ("DCDDG8", "132", 8, 32)),
    (24, ("DCDDS2", "124", "SM2", None)),
    (64, ("DCDDS2", "124", "SM2", 24)),  # DCD_FORMATS(2,2) (64, 24, 26, 26)
    (26, ("DCDDS2", "126", "SM2", None)),
    (25, ("DCDDS4", "125", "SM4", None)),
    (65, ("DCDDS4", "125", "SM4", 25)),
    (52, ("DCDDS8", "152", "PL9", None)),
    (48, ("DCDDS8", "148", "PL9", None)),
    (44, ("DCDDG9", "144", 9, None)),    # POSSIBLE_FMT_IDS (44,53,60,42,46,
    (53, ("DCDDG9", "153", 9, None)),    #   97,98,99,43,45)
    (60, ("DCDDG9", "160", 9, None)),
    (42, ("DCDDG9", "142", 9, None)),
    (46, ("DCDDG9", "146", 9, None)),
    (97, ("DCDDG9", None, 9, None)),
    (98, ("DCDDG9", None, 9, None)),
    (99, ("DCDDG9", None, 9, None)),
    (43, ("DCDDG9", "143", 9, None)),
    (45, ("DCDDG9", "145", 9, None)),
])
FIXED_LEN = {97: 128, 98: 128, 99: 128}          # DCDDG9's DCD_FR_LEN 6-8
RATES = ("25", "12", "05", "01")
NFRAMES = 50

# flags on a frame entry
F_STALE, F_HS, F_ASSIGN, F_PARTIAL, F_UNRESOLVED = 1, 2, 4, 8, 16


# --------------------------------------------------------------------------
# source tree
class Tree:
    def __init__(self, roots):
        self.roots = [os.path.abspath(os.path.expanduser(r)) for r in roots]
        self._files = None

    def find(self, member):
        """The release's copy of a member; an empty file in an overlay
        deletes the base's (PFS/OI340700/README.md)."""
        for r in self.roots:
            for d in SRCDIRS:
                p = os.path.join(r, d, member + ".hal")
                if os.path.exists(p):
                    return p if os.path.getsize(p) else None
        return None

    def files(self):
        """Every .hal of the release, the overlay's copy in place of the
        base's."""
        if self._files is None:
            seen = OrderedDict()
            for r in self.roots:
                for d in SRCDIRS:
                    for p in sorted(glob.glob(os.path.join(r, d, "*.hal"))):
                        seen.setdefault(os.path.basename(p), p)
            self._files = [p for p in seen.values() if os.path.getsize(p)]
        return self._files


def code_lines(path):
    """(line number, text) of a member's code: columns 1-72, comment cards
    (C in column 1) and directives (D) dropped."""
    out = []
    for i, l in enumerate(io.open(path, encoding="latin-1"), 1):
        if l[:1] in ("C", "D", "F"):
            continue
        s = l[:72].rstrip()
        if s.strip():
            out.append((i, s))
    return out


# --------------------------------------------------------------------------
# the compools
TYPECODE = {pasvar.T_SCA: "F", pasvar.T_VEC: "F", pasvar.T_MAT: "F",
            pasvar.T_SCAD: "D", pasvar.T_VECD: "D", pasvar.T_MATD: "D",
            pasvar.T_INT: "I", pasvar.T_INTD: "J",
            pasvar.T_BIT16: "B", pasvar.T_BIT32: "B",
            pasvar.T_CHAR: "C", pasvar.T_EVENT: "E"}


class Universe:
    """Every compool of the release, with name -> storage and offset ->
    storage lookups."""

    def __init__(self, sdflib, tree=None, log=print):
        self.lib = pasvar.SDFLib(sdflib)
        self.sdflib = sdflib
        names = set()
        lengths = defaultdict(set)
        for cfg in pasvar.CONFIGS:
            try:
                tab, _ = pasvar.csect_table(cfg)
            except Exception:                         # noqa: table missing
                continue
            for cs, e in tab.items():
                if cs.startswith("#P"):
                    names.add(cs[2:])
                    lengths[cs[2:]].add(e["end"] - e["start"] + 1)
        self.label = {}           # compool SDF name -> its COMPOOL label
        self.by_label = {}        # label (what D INCLUDE TEMPLATE names) -> SDF names
        src_names = set()
        for p in (tree.files() if tree else ()):
            # a compool's SDF is its member name's first six characters
            # (CDWDOWNL -> ##CDWDOW); one not in any csect table still counts
            try:
                head = io.open(p, encoding="latin-1").read(20000)
            except OSError:
                continue
            m = re.search(r"^ (\S+):\s*COMPOOL\b", head, re.M)
            if m:
                n6 = os.path.basename(p)[:-4][:6]
                names.add(n6)
                src_names.add(n6)
                self.label[n6] = m.group(1)
                self.by_label.setdefault(m.group(1), set()).add(n6)
        self.comps = OrderedDict()
        for n in sorted(names):
            sdfn = n if self.lib.has(n) else n.ljust(6)   # ##CRATE .sdf
            if not self.lib.has(sdfn):
                continue
            try:
                cp = self.lib.compool(sdfn)
            except Exception as e:                    # noqa: one bad SDF
                log("  (skipping %s: %s)" % (n, e))
                continue
            if cp.csect.strip() != "#P" + n and len(cp.init) not in lengths.get(n, ()) \
                    and n not in src_names:
                # not the compool's own #P csect anywhere in its block
                # table, nor sized like one, nor declared COMPOOL in the
                # source: a program's SDF, carrying the compools it includes
                continue
            self.comps[n] = cp
        # name -> [(compool, var Sym, qualified member path or None, member)]
        self.byname = defaultdict(list)
        self.spans = {}                # compool -> sorted [(start, end, Sym)]
        for n, cp in self.comps.items():
            sp = []
            for v in cp.vars.values():
                self.byname[v.name].append((n, v, None, None))
                size = v.elem_hw(cp) * v.count()
                sp.append((v.offset, v.offset + size, v))
                if v.type == pasvar.T_STRUC and v.template and not v.is_name:
                    for q, m in cp.terminals(v.template):
                        self.byname[m.name].append((n, v, q, m))
            sp.sort(key=lambda t: (t[0], -t[1]))
            self.spans[n] = sp
        self._terms = {}

    def terms(self, n, v):
        """Sorted terminals of structure variable v: [(off, end, q, m)]."""
        k = (n, v.name)
        if k not in self._terms:
            cp = self.comps[n]
            t = []
            for q, m in cp.terminals(v.template):
                t.append((m.offset, m.offset + m.elem_hw(cp) * m.count(), q, m))
            t.sort(key=lambda x: (x[0], -x[1]))
            self._terms[k] = t
        return self._terms[k]

    # ---------------------------------------------------------------- names
    def unique_terminal(self, name):
        return len(self.byname.get(name, ())) == 1

    def leaves_at(self, n, off):
        """The storage leaves (an element, or one component of a vector or
        matrix element) of compool n that cover halfword offset off:
        [dict(name, type, hw, start, bits, sym...)]."""
        cp = self.comps[n]
        out = []
        for s, e, v in self.spans[n]:
            if s > off:
                break
            if not s <= off < e:
                continue
            rel = off - s
            if v.type == pasvar.T_STRUC and v.template and not v.is_name:
                csz = v.elem_hw(cp)
                copy = rel // csz
                r2 = rel % csz
                ncopies = v.count()
                for ts, te, q, m in self.terms(n, v):
                    if ts <= r2 < te:
                        sub_s = (copy + 1,) if ncopies > 1 else ()
                        nm = m.name if self.unique_terminal(m.name) \
                            else v.name + "." + q
                        lf = self._leaf(cp, m, nm, sub_s, r2 - ts,
                                        s + copy * csz + ts)
                        if lf:
                            out.append(lf)
            else:
                lf = self._leaf(cp, v, v.name, (), rel, s)
                if lf:
                    out.append(lf)
        return out

    def _leaf(self, cp, sym, name, sub_s, rel, base):
        esz = sym.elem_hw(cp)
        if esz <= 0:
            return None
        k, r = divmod(rel, esz)
        sub_a = ()
        if sym.dims and not sym.is_name:
            sub_a = _unravel(k, sym.dims)
        estart = base + k * esz
        t = sym.type
        if sym.is_name:
            return dict(name=name + _subs(sub_s, sub_a, ()), type="N",
                        hw=esz, start=estart, bits=16 * esz, decl=sym.decl())
        if t in (pasvar.T_VEC, pasvar.T_MAT, pasvar.T_VECD, pasvar.T_MATD):
            c = 4 if t in (pasvar.T_VECD, pasvar.T_MATD) else 2
            ci, _ = divmod(r, c)
            if t in (pasvar.T_MAT, pasvar.T_MATD):
                cols = max(sym.cols or 1, 1)
                sub_c = (ci // cols + 1, ci % cols + 1)
            else:
                sub_c = (ci + 1,)
            return dict(name=name + _subs(sub_s, sub_a, sub_c),
                        type=TYPECODE[t], hw=c, start=estart + ci * c,
                        bits=16 * c, decl=sym.decl())
        if t == pasvar.T_STRUC:
            return dict(name=name + _subs(sub_s, sub_a, ()), type="S",
                        hw=esz, start=estart, bits=16 * esz, decl=sym.decl())
        bits = 16 * esz
        if t in (pasvar.T_BIT16, pasvar.T_BIT32):
            bits = sym.bits or (32 if t == pasvar.T_BIT32 else 16)
        d = dict(name=name + _subs(sub_s, sub_a, ()), type=TYPECODE.get(t, "?"),
                 hw=esz, start=estart, bits=bits, decl=sym.decl())
        if sym.flags & pasvar.F_DENSE:
            # a DENSE terminal shares its halfword: the SDF's field 12a is
            # the field's shift from the least significant bit, X'FF' for 0
            # (CGNFL2+443: CGNB_NAV_PWRD_FLT_B1 15, ..., CGNB_WD1_FILL 255
            # with 6 bits), 12b its width
            align, nb = sym.dense
            d["bits"] = nb or d["bits"]
            d["shift"] = 0 if align in (None, 255) else align
            if d["shift"] >= 16 * esz:
                d["shift"] -= 16 * esz      # in the second halfword's word
        return d

    # -------------------------------------------------------------- resolve
    def compools_of(self, labels):
        """The SDF names of the compools a program's D INCLUDE TEMPLATEs
        name."""
        out = set()
        for l in labels:
            out |= self.by_label.get(l, set())
        return out

    def resolve(self, expr, allowed=None):
        """A HAL variable reference -> (compool, halfword offset, bit or
        None, leaf type code) or raises ValueError with the reason.  A name
        two compools declare (CGMS_ACC_BILO in CGMCOM and CGMIMU) is taken
        from the one in allowed -- the compools the program includes."""
        m = REF.match(expr.replace(" ", ""))
        if not m:
            raise ValueError("cannot parse %r" % expr)
        path, sub = m.group(1).upper().split("."), m.group(2)
        subs = _parse_subs(sub)
        cands = self.byname.get(path[0], [])
        if (not cands or all(c[2] is not None for c in cands)) and len(path) > 1:
            # qualified from a minor structure: CRBV_WORD6.CRBV_RAW_TACH
            hits = [(n, v, q, mem) for n, v, q, mem in self.byname.get(path[-1], [])
                    if q is not None and _in_order(path[:-1], q.split(".")[:-1])]
            if hits:
                cands, path = hits, [path[-1]]
        if not cands:
            raise ValueError("%s is not a variable of any compool" % path[0])
        hits = []
        for n, v, q, mem in cands:
            if len(path) > 1:
                if q is not None or v.type != pasvar.T_STRUC:
                    continue
                want = ".".join(path[1:])
                for qq, mm in self.comps[n].terminals(v.template):
                    if qq == want or qq.endswith("." + want) or \
                            mm.name == path[-1] and qq.endswith(path[-1]) and \
                            all(p in qq.split(".") for p in path[1:]):
                        hits.append((n, v, qq, mm))
                        break
            else:
                hits.append((n, v, q, mem))
        if not hits:
            raise ValueError("%s: no such member" % expr)
        if allowed and len(set(h[0] for h in hits)) > 1:
            inc = [h for h in hits if h[0] in allowed]
            hits = inc or hits
        if len(set((h[0], h[1].name, h[2]) for h in hits)) > 1:
            raise ValueError("%s is ambiguous: %s" % (
                expr, ", ".join("%s:%s%s" % (h[0], h[1].name,
                                             "." + h[2] if h[2] else "")
                                for h in hits)))
        n, v, q, mem = hits[0]
        return self._address(n, v, mem, subs, expr)

    def _address(self, n, v, mem, subs, expr):
        cp = self.comps[n]
        if subs == "runtime":
            raise ValueError("%s: run-time subscript" % expr)
        s_sub, a_sub, c_sub, explicit = subs
        sym = mem if mem is not None else v
        ncopies = v.count() if v.type == pasvar.T_STRUC else 1
        off = v.offset
        flat = list(s_sub) + list(a_sub) + list(c_sub)
        if not explicit:
            # no ';' or ':' -- subscripts fill structure, array, component
            # in that order
            s_sub, a_sub, c_sub = [], [], []
            if ncopies > 1 and v.type == pasvar.T_STRUC:
                if flat:
                    s_sub = [flat.pop(0)]
            if sym.dims and not sym.is_name:
                a_sub, flat = flat[:len(sym.dims)], flat[len(sym.dims):]
            c_sub = flat
        elif a_sub and not c_sub and (not sym.dims or sym.is_name):
            # $(48;3) on a terminal with no array dimensions: the 3 is a
            # component -- CGYV_2_8_I_STAR_SEL$(48;3), a VECTOR in 50
            # structure copies (DCD12201 frame 11; checked against memory)
            a_sub, c_sub = [], a_sub
        if v.type == pasvar.T_STRUC and v.template and not v.is_name:
            if s_sub:
                if not 1 <= s_sub[0] <= max(v.count(), 1):
                    raise ValueError("%s: structure copy %d of %d" % (expr, s_sub[0], v.count()))
                off += (s_sub[0] - 1) * v.elem_hw(cp)
            if mem is None:
                return n, off, None, "S"
            off += mem.offset
        elif s_sub:
            raise ValueError("%s: structure subscript on a non-structure" % expr)
        esz = sym.elem_hw(cp)
        if a_sub and not sym.is_name:
            if len(a_sub) < len(sym.dims):
                a_sub = list(a_sub) + [1] * (len(sym.dims) - len(a_sub))
            off += esz * pasvar.elem_index(sym.dims, tuple(a_sub[:len(sym.dims)]))
        t = sym.type
        bit = None
        if c_sub:
            if t in (pasvar.T_VEC, pasvar.T_VECD):
                off += (c_sub[0] - 1) * (4 if t == pasvar.T_VECD else 2)
            elif t in (pasvar.T_MAT, pasvar.T_MATD):
                cols = max(sym.cols or 1, 1)
                k = (c_sub[0] - 1) * cols + ((c_sub[1] if len(c_sub) > 1 else 1) - 1)
                off += k * (4 if t == pasvar.T_MATD else 2)
            elif t in (pasvar.T_BIT16, pasvar.T_BIT32, pasvar.T_INT):
                bit = c_sub[0]
        return n, off, bit, TYPECODE.get(t, "?")


def _in_order(want, have):
    i = 0
    for h in have:
        if i < len(want) and h == want[i]:
            i += 1
    return i == len(want)


REF = re.compile(r"^([A-Z0-9_@#]+(?:\.[A-Z0-9_@#]+)*)(\$.*)?$", re.I)


def _parse_subs(sub):
    """'$3', '$(1;12)', '$(3;12:1)', '$(1:)', '$(2,3)' -> (structure,
    array, component, explicit separators?) -- or 'runtime'."""
    if not sub:
        return [], [], [], False
    s = sub[1:]
    if s.startswith("("):
        s = s[1:s.rindex(")")]
    explicit = ";" in s or ":" in s
    st, ar, co = "", s, ""
    if ";" in ar:
        st, ar = ar.split(";", 1)
    if ":" in ar:
        ar, co = ar.split(":", 1)

    def ints(x):
        out = []
        for t in x.split(","):
            t = t.strip()
            if not t:
                continue
            if not t.isdigit():
                return None
            out.append(int(t))
        return out
    st, ar, co = ints(st), ints(ar), ints(co)
    if st is None or ar is None or co is None:
        return "runtime"
    if not explicit:
        return [], ar, [], False
    return st, ar, co, True


def _unravel(k, dims):
    out = []
    for d in reversed(dims):
        out.append(k % d + 1)
        k //= d
    return tuple(reversed(out))


def _subs(s, a, c):
    st = ",".join(map(str, s)) + ";" if s else ""
    ar = ",".join(map(str, a))
    co = ",".join(map(str, c))
    if c and (a or s):
        inner = st + ar + ":" + co
    elif c:
        inner = co
    else:
        inner = st + ar
    if not inner:
        return ""
    if len(s) + len(a) + len(c) == 1 and not s:
        return "$" + inner
    return "$(" + inner + ")"


# --------------------------------------------------------------------------
# measurement cards
CARDFIELD = re.compile(r"\b(M|N|R|T|L|B|U|S0|S1|A0|A1|X)=(\S+)")


def read_cards(tree):
    """{MSID: card dict} from every `C M=` card of the release."""
    cards = OrderedDict()
    for p in tree.files():
        try:
            lines = io.open(p, encoding="latin-1").read().split("\n")
        except OSError:
            continue
        ops_note = None
        for i, l in enumerate(lines):
            if not l.startswith("C"):
                continue
            body = l[:72]
            mo = re.search(r"MSID FOR .* IS FOR OPS\s*(\d+)", body)
            if mo:
                ops_note = int(mo.group(1))
                continue
            if not body.startswith("C M="):
                continue
            f = dict(CARDFIELD.findall(body))
            msid = f.get("M")
            if not msid:
                continue
            c = cards.get(msid)
            if c is None or ("N" in f and "N" in c and c["N"] != f["N"]):
                key = msid if c is None else "%s#%d" % (msid, i)
                c = cards[key] = {"msid": msid, "file": os.path.basename(p),
                                  "line": i + 1}
            for k, v in f.items():
                if k != "M":
                    c.setdefault(k, v)
            if ops_note is not None and "N" in f:
                c["ops"] = ops_note
                ops_note = None
    return cards


def _num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def card_meas(c):
    """The decoder's view of a card."""
    d = {"msid": c["msid"]}
    t = c.get("T")
    if t is not None and t.isdigit():
        d["t"] = int(t)
    for k, kk in (("B", "b"), ("L", "l")):
        if c.get(k, "").isdigit():
            d[kk] = int(c[k])
    if "U" in c:
        d["u"] = c["U"]
    for k, kk in (("A0", "a0"), ("A1", "a1")):
        v = _num(c.get(k))
        if v is not None:
            d[kk] = v
    for k, kk in (("S0", "s0"), ("S1", "s1"), ("X", "x")):
        if k in c:
            d[kk] = c[k]
    if "ops" in c:
        d["ops"] = c["ops"]
    return d


# --------------------------------------------------------------------------
# the members
STMT_COPY = re.compile(r"^%COPY\(\s*(DL|HS)\(\s*(\d+)\s*\)\s*,\s*(.+?)\s*,\s*(\d+)\s*\)\s*;$")
STMT_ASSIGN = re.compile(r"^(DL|HS)\(\s*(\d+)\s*\)\s*=\s*(.+?)\s*;$")
HSREF = re.compile(r"^HS\(\s*(\d+)\s*\)$")


def read_member(tree, name):
    """[[statement, ...] per DO block] of an INCL80 member."""
    p = tree.find(name)
    if p is None:
        raise FileNotFoundError("member %s not in %s" % (name, tree.roots))
    blocks, cur = [], None
    for ln, s in code_lines(p):
        t = s.strip()
        if re.match(r"^DO\s*;", t):
            cur = []
            blocks.append(cur)
        elif t == "END;":
            cur = None
        elif cur is not None:
            cur.append((ln, t))
        else:
            raise ValueError("%s:%d: statement outside a DO block: %s" % (name, ln, t))
    return p, blocks


def frame_length(tree, formatter, fmt, ldr_of):
    if fmt in FIXED_LEN:
        return FIXED_LEN[fmt]
    p = tree.find(formatter)
    txt = io.open(p, encoding="latin-1").read()
    if formatter == "DCDDOW":
        m = re.search(r"FRAME_LENGTH_OF_20\s+INTEGER\s+CONSTANT\(\s*(\d+)", txt)
        return int(m.group(1))
    key = ldr_of if ldr_of else fmt
    m = re.search(r"%s_OF_%d\s+INTEGER\s+CONSTANT\(\s*(\d+)" % (
        "LDR_SIZE" if ldr_of else "FRAME_LENGTH", key), txt)
    if not m:
        raise ValueError("%s: no %s length for format %d" % (formatter, "LDR" if ldr_of else "frame", fmt))
    return int(m.group(1))


# --------------------------------------------------------------------------
# the generator
class Generator:
    def __init__(self, tree, uni, log=print):
        self.tree, self.uni, self.log = tree, uni, log
        self.items = []                  # item dicts
        self.item_ix = {}
        self.unresolved = defaultdict(set)    # reason -> {member:line expr}
        self.cards = read_cards(tree)
        self._cards_at = None
        self.card_problems = []
        self.type_check = defaultdict(lambda: defaultdict(int))
        self._ref_cache = {}

    # cards keyed by (compool, leaf start)
    def cards_at(self):
        if self._cards_at is None:
            idx = defaultdict(list)
            nres = 0
            for key, c in self.cards.items():
                ref = c.get("N")
                if not ref:
                    continue
                try:
                    own = c["file"][:-4][:6]
                    n, off, bit, tc = self.uni.resolve(ref, {own, own.ljust(6)})
                except (ValueError, KeyError, IndexError) as e:
                    self.card_problems.append((c["msid"], ref, str(e)))
                    continue
                leaves = self.uni.leaves_at(n, off)
                if not leaves:
                    self.card_problems.append((c["msid"], ref, "no storage at offset"))
                    continue
                lf = leaves[0]
                d = card_meas(c)
                if bit is not None and "b" not in d and d.get("t") == 6:
                    d["b"] = bit
                d["_ref"] = ref
                idx[(n, lf["start"])].append(d)
                self.type_check[d.get("t")][lf["type"]] += 1
                nres += 1
            self._cards_at = idx
            self.log("  measurement cards: %d, resolved to storage %d, not %d"
                     % (len(self.cards), nres, len(self.card_problems)))
        return self._cards_at

    def item(self, n, lf, ops):
        ms = [dict(m) for m in self.cards_at().get((n, lf["start"]), [])]
        key = (n, lf["start"], lf["name"], ops if any("ops" in m for m in ms) else None)
        if key in self.item_ix:
            return self.item_ix[key]
        # an MSID noted as one OPS's applies to that OPS's formats only
        if any("ops" in m for m in ms):
            pick = [m for m in ms if m.get("ops") in (None, ops)]
            ms = pick or ms
        for m in ms:
            m.pop("_ref", None)
            m.pop("ops", None)
        # T=9 words with several cards: the first is the parent word's
        # (usually ...P); the rest name its discretes without bit numbers.
        t9 = [m for m in ms if m.get("t") == 9]
        if len(t9) > 1:
            first = t9[0]
            first["also"] = [m["msid"] for m in t9[1:]]
            ms = [m for m in ms if m.get("t") != 9 or m is first]
        it = {"name": lf["name"], "compool": n, "offset": lf["start"],
              "type": lf["type"], "hw": lf["hw"], "bits": lf["bits"],
              "decl": lf["decl"]}
        if "shift" in lf:
            it["shift"] = lf["shift"]
        if ms:
            it["meas"] = ms
        self.items.append(it)
        self.item_ix[key] = len(self.items) - 1
        return self.item_ix[key]

    def ref(self, expr, allowed=None):
        key = (expr, allowed)
        if key not in self._ref_cache:
            try:
                self._ref_cache[key] = self.uni.resolve(expr, allowed)
            except (ValueError, KeyError, IndexError) as e:
                self._ref_cache[key] = e
        return self._ref_cache[key]

    def includes(self, program):
        """frozenset of the compools a formatter's D INCLUDE TEMPLATE
        directives bring in (the OPS 0 members run inside DCD_DOW)."""
        k = ("inc", program)
        if k not in self._ref_cache:
            p = self.tree.find(program)
            labels = []
            if p:
                for l in io.open(p, encoding="latin-1"):
                    m = re.match(r"D\s+INCLUDE\s+TEMPLATE\s+(\S+)", l[:72])
                    if m:
                        labels.append(m.group(1))
            self._ref_cache[k] = frozenset(self.uni.compools_of(labels))
        return self._ref_cache[k]

    # one statement acting on the DL and HS states
    def run_stmt(self, member, ln, t, frame, dl, hs, stmt_id, allowed=None):
        m = STMT_COPY.match(t)
        a = None if m else STMT_ASSIGN.match(t)
        if not m and not a:
            self.unresolved["statement not understood"].add("%s:%d %s" % (member, ln, t))
            return
        dst, dn = (m or a).group(1), int((m or a).group(2))
        src = (m or a).group(3).strip()
        count = int(m.group(4)) if m else 1
        tgt = dl if dst == "DL" else hs
        h = HSREF.match(src.replace(" ", ""))
        if h:
            sn = int(h.group(1))
            for i in range(count):
                v = hs.get(sn + i)
                tgt[dn + i] = None if v is None else \
                    (v[0], v[1], v[2], frame, v[3] if dst == "DL" else None)
            return
        r = self.ref(src, allowed)
        if isinstance(r, Exception):
            why = str(r)
            self.unresolved[why if "run-time" in why else "variable not resolved"].add(
                "%s:%d %s  (%s)" % (member, ln, src, why))
            for i in range(count):
                tgt[dn + i] = ("?", src, stmt_id, frame, None)
            return
        n, off, bit, tc = r
        if a:
            # DL(n) = X: X converted to INTEGER, one halfword
            tgt[dn] = ("=", (n, off), stmt_id, frame, None)
            return
        for i in range(count):
            tgt[dn + i] = ("c", (n, off + i), stmt_id, frame, None)

    def build_format(self, fmt):
        formatter, prefix, ops, ldr_of = FORMATS[fmt]
        length = frame_length(self.tree, formatter, fmt, ldr_of)
        members = []
        layers = [("120", 0)] if fmt != 20 else []
        if prefix:
            layers.append((prefix, ops))
        for pre, o in layers:
            inc = self.includes("DCDDOW" if pre == "120" else formatter)
            for r in RATES:
                p, blocks = read_member(self.tree, "DCD" + pre + r)
                members.append(("DCD" + pre + r, r, blocks, inc))
        dl, hs = {}, {}
        frames = []

        def run_frame(f, record):
            # DCDDOW: header words in frames 0 and 25
            if f in (0, 25):
                dl[3] = ("hdr3", None, ("hdr", f), f, None)
                for w, (nm, k) in ((4, ("TFCMLTQM", 0)), (5, ("TFCMLTQH", 0)),
                                   (6, ("TFCMLTQH", 1))):
                    r = self.ref(nm)
                    dl[w] = ("c", (r[0], r[1] + k), ("hdr", f), f, None) \
                        if not isinstance(r, Exception) else ("?", nm, ("hdr", f), f, None)
            sel = {"25": 0, "12": f % 2, "05": f % 5, "01": f % 25}
            for mname, r, blocks, inc in members:
                k = sel[r]
                if k >= len(blocks):
                    continue
                for ln, t in blocks[k]:
                    self.run_stmt(mname, ln, t, f, dl, hs, (mname, ln, f), inc)
            if fmt in (97, 98, 99):
                # DCDDG9 cases 6-8: %COPY(DL(3),CVCV_FMT_97$3,126) or
                # DL(3 TO 128) = CVCV_FMT_98 (99), from word 7 in frames 0
                # and 25.  CVC_S9_DL_FRMS (CVCS9DL.hal) makes all three
                # CONSTANTs: FMT_97 the ramp 0..127, FMT_98 21845 (X'5555'),
                # FMT_99 43690 (X'AAAA').
                first = 7 if f in (0, 25) else 3
                for w in range(first, 129):
                    if fmt == 97:
                        k = ("CVCV_FMT_97$%d" % w, w - 1)
                    else:
                        k = ("CVCV_FMT_%d" % fmt, 0x5555 if fmt == 98 else 0xAAAA)
                    dl[w] = ("k", k, ("fmt", f), f, None)
            dl[2] = ("hdr2", None, ("hdr", f), f, None)
            if record:
                frames.append(dict(dl))

        for f in range(NFRAMES):           # the cycle once, to fill stale words
            run_frame(f, False)
        for f in range(NFRAMES):
            run_frame(f, True)
        return length, [m[0] for m in members], frames

    def encode_frame(self, fmt, ops, length, f, state, stats):
        """[[word, item, flags, part, frame written], ...] for one frame:
        part is the halfword of the item this word starts with (0 but for a
        partial), frame written differs from f only for a stale word."""
        out = []
        stats["words"] += length
        covered = set()

        def add(w, it, flags, part, wf):
            out.append([w, it, flags, part, wf])

        for w in range(1, length + 1):
            s = state.get(w)
            if w == 1:
                add(1, self.pseudo("SYNC", "sync word EB90", "B", 1), 0, 0, f)
                stats["fresh"] += 1
                continue
            if w == 2:
                add(2, self.pseudo("FRAME_FORMAT", "2-bit counter || frame number "
                                   "(6 bits) || format ID (8 bits)", "B", 1), 0, 0, f)
                stats["fresh"] += 1
                continue
            if s is None:
                stats["unwritten"] += 1
                continue
            kind, src, stmt, wf, hsf = s
            flags = F_HS if hsf is not None else 0
            age = (f - wf) % NFRAMES
            if age:
                flags |= F_STALE
            tally = "stale" if age else "fresh"
            if kind == "hdr3":
                add(w, self.pseudo("ID_WORD", "vehicle (3 bits) || GPC (3) || "
                                   "mission ID (8)", "B", 1), flags, 0, wf)
                stats[tally] += 1
                continue
            if kind == "k":
                add(w, self.pseudo(src[0], "CONSTANT %d (X'%04X')" % (src[1], src[1]),
                                   "I", 1), flags, 0, wf)
                stats[tally] += 1
                continue
            if kind == "?":
                # not resolvable here (a run-time subscript): listed by its
                # source expression, shown raw
                add(w, self.pseudo(src, "not resolved: %s" % src, "B", 1),
                    flags | F_UNRESOLVED, 0, wf)
                stats["unresolved"] += 1
                continue
            n, off = src
            if kind == "=":
                lvs = self.uni.leaves_at(n, off)
                if not lvs:
                    stats["unresolved"] += 1
                    continue
                for lf in lvs:
                    if lf["type"] == "N":
                        # DL(n) = a NAME variable: HAL dereferences it, so
                        # the word is whatever it points at (run-time)
                        lf = dict(lf, name="*" + lf["name"], type="I", hw=1, bits=16,
                                  decl="INTEGER at the address %s holds" % lf["name"])
                    add(w, self.item(n, lf, ops), flags | F_ASSIGN, 0, wf)
                stats[tally] += 1
                continue
            if w in covered:
                stats[tally] += 1
                continue
            lvs = self.uni.leaves_at(n, off)
            if not lvs:
                stats["no storage"] += 1
                self.unresolved["copied halfword outside any variable"].add(
                    "format %d frame %d word %d: %s+%d" % (fmt, f, w, n, off))
                continue
            for lf in lvs:
                part = off - lf["start"]
                if part and self._same(state, w - 1, n, off - 1, stmt) and w - 1 > 2:
                    continue            # inside an item already listed
                ok = not part and w + lf["hw"] - 1 <= length and all(
                    self._same(state, w + i, n, off + i, stmt) for i in range(lf["hw"]))
                add(w, self.item(n, lf, ops), flags | (0 if ok else F_PARTIAL), part, wf)
                if ok:
                    covered.update(range(w + 1, w + lf["hw"]))
            stats[tally] += 1
        return out

    @staticmethod
    def _same(state, w, n, off, stmt):
        s = state.get(w)
        return s is not None and s[0] == "c" and s[1] == (n, off) and s[2] == stmt

    def pseudo(self, name, what, t, hw):
        key = ("pseudo", name)
        if key not in self.item_ix:
            self.items.append({"name": name, "compool": None, "offset": None,
                               "type": t, "hw": hw, "bits": 16 * hw, "decl": what})
            self.item_ix[key] = len(self.items) - 1
        return self.item_ix[key]

    def run(self, formats=None):
        out = OrderedDict()
        report = OrderedDict()
        for fmt in (formats or FORMATS):
            formatter, prefix, ops, ldr_of = FORMATS[fmt]
            try:
                length, members, frames = self.build_format(fmt)
            except (OSError, ValueError) as e:
                self.log("  format %d: %s" % (fmt, e))
                report[fmt] = {"error": str(e)}
                continue
            stats = defaultdict(int)
            fr = []
            for f in range(NFRAMES):
                fr.append(self.encode_frame(fmt, ops, length, f, frames[f], stats))
            out[str(fmt)] = OrderedDict([
                ("length", length), ("formatter", formatter), ("ops", ops),
                ("ldr_of", ldr_of), ("members", members), ("frames", fr)])
            report[fmt] = dict(stats)
            report[fmt]["length"] = length
        return out, report


# --------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--release", default="OI340700", help="release name (default OI340700)")
    ap.add_argument("--root", action="append", default=None,
                    help="source tree, overlay first (repeat); default per release")
    ap.add_argument("--sdflib", default=None, help="SDF library of the release's build")
    ap.add_argument("--out", default=None, help="output JSON (default downlist-RELEASE.json here)")
    ap.add_argument("--format", type=int, action="append", help="only these format IDs")
    ap.add_argument("--report", action="store_true",
                    help="list every unresolved statement and card")
    a = ap.parse_args()
    rel = RELEASES.get(a.release, {})
    roots = a.root or rel.get("roots")
    sdflib = a.sdflib or rel.get("sdflib")
    if not roots or not sdflib:
        ap.error("unknown release %s: give --root and --sdflib" % a.release)
    tree = Tree(roots)
    print("release %s: source %s; SDFs %s" % (a.release, " + ".join(tree.roots), sdflib))
    uni = Universe(sdflib, tree)
    print("  compools: %d" % len(uni.comps))
    g = Generator(tree, uni)
    formats, report = g.run(a.format)
    outp = a.out or os.path.join(HERE, "downlist-%s.json" % a.release)
    doc = OrderedDict([
        ("release", a.release),
        ("generated", datetime.date.today().isoformat()),
        ("source", tree.roots), ("sdflib", sdflib),
        ("word_base", 1),
        ("legend", {
            "frames": "per format, frames[0..49]: [word, item, flags, part, frame written]: part = "
                      "the item's halfword this word holds first (non-zero only for a partial), "
                      "frame written = the frame whose processing put it there (not this one "
                      "if stale)",
            "flags": {"1": "stale: written by an earlier frame, not this one",
                      "2": "HS-staged: sampled into HS_BUFFER at frame 0/25, copied out later",
                      "4": "assigned (DL(n) = X): X converted to a 16-bit INTEGER",
                      "8": "partial: only some halfwords of the item are in this frame",
                      "16": "not resolved (run-time subscript): the item is the source expression, raw"},
            "type": {"F": "SCALAR, IBM short float", "D": "DOUBLE, IBM long float",
                     "I": "INTEGER (signed 16)", "J": "INTEGER DOUBLE (signed 32)",
                     "B": "BIT(bits), HAL bit 1 the most significant", "C": "CHARACTER",
                     "E": "EVENT", "N": "NAME (address)", "S": "structure copy"},
            "meas": "measurement cards: msid, t (card type), b (bit), l (field length), u (units), "
                    "a0/a1 (value = a0 + a1 x raw), s0/s1 (discrete labels), x (calibration code)"}),
        ("items", g.items),
        ("formats", formats),
        ("coverage", {str(k): v for k, v in report.items()}),
        ("unresolved", {k: sorted(v) for k, v in g.unresolved.items()}),
    ])
    with io.open(outp, "w") as f:
        json.dump(doc, f, separators=(",", ":"))
    print("wrote %s: %d items" % (outp, len(g.items)))
    print("\n  format  length  fresh/written  stale  unwritten  unresolved   (word-frames over 50 frames)")
    for fmt, r in report.items():
        if "error" in r:
            print("  %6d  %s" % (fmt, r["error"]))
            continue
        tot = r["words"]
        print("  %6d  %6d  %6d %5.1f%%  %6d  %9d  %10d"
              % (fmt, r["length"], r.get("fresh", 0), 100.0 * r.get("fresh", 0) / tot,
                 r.get("stale", 0), r.get("unwritten", 0),
                 r.get("unresolved", 0) + r.get("no storage", 0)))
    print("\n  unresolved:")
    for why, v in g.unresolved.items():
        print("    %s: %d" % (why, len(v)))
        for x in sorted(v)[: (None if a.report else 8)]:
            print("        %s" % x)
    print("\n  card type (T=) vs declared type of the storage it names:")
    for t in sorted(g.type_check, key=lambda x: (x is None, x)):
        print("    T=%s: %s" % (t, ", ".join("%s %d" % kv for kv in sorted(g.type_check[t].items()))))
    if a.report:
        print("\n  cards not resolved (%d):" % len(g.card_problems))
        for c in g.card_problems:
            print("    %s N=%s: %s" % c)
    else:
        print("  cards not resolved to storage: %d (--report lists them)" % len(g.card_problems))


if __name__ == "__main__":
    main()
