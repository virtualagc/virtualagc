"""Parse the MAFGEN field listing of one compool CSECT out of a DASS_<cfg>.ASC dump."""
import re, io, struct, json
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from paths import MAFGEN as M
FURN = re.compile(r'^(\+\s*$|1M A F G E N|0?[0-9A-F]*\s+M E M O R Y   M A P|\s*$)')
_cache = {}
def lines(cfg):
    if cfg not in _cache:
        _cache[cfg] = [l.rstrip("\r\n") for l in io.open(M + "DASS_%s.ASC" % cfg, errors="replace") if not FURN.match(l.rstrip("\r\n"))]
    return _cache[cfg]
FIELD = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+(#P\w+)\+([0-9A-F]{4})\s+(\S+)\s*(.*)$')
COPY = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+\+\+\+ COPY (\d+) OF (\d+) \+\+\+')
GAP = re.compile(r'^ ([0-9A-F]{6})\s+(#P\w+)\+([0-9A-F]{4})\s+([0-9A-F]{4})\s+\*\*\* ALIGNMENT GAP')
def parse(csect, cfg):
    """[{'name','start','end','kind','type','copies':[[terminal...]...]} ...] in memory order.
    terminal = dict(name, addr, end, words, type)"""
    L = lines(cfg); out = []; cur = None; copy = None
    started = False
    for l in L:
        m = FIELD.match(l)
        if m and ("ALIGNMENT GAP" in l or re.fullmatch(r"\*?[0-9A-F]{4}", m.group(5))): continue
        if m and m.group(3) == csect:
            started = True
            a = int(m.group(1), 16); b = int(m.group(2), 16) if m.group(2) else a
            name = m.group(5); rest = m.group(6)
            kindm = re.search(r'(VARIABLE|TERMINAL|CONSTANT)\s*$', rest)
            kind = kindm.group(1) if kindm else "?"
            if kind == "CONSTANT": kind = "VARIABLE"
            typ = re.sub(r'\s+(VARIABLE|TERMINAL|CONSTANT)\s*$', '', rest).strip()
            if kind == "VARIABLE":
                t = re.search(r'((?:ARRAY\s+)?(?:SP |DP )?(?:INTEGER|SCALAR|BIT STRING|CHARACTER|STRUCTURE|EVENT|BOOLEAN|VECTOR|MATRIX)|NAME\s+\S.*|STRUCTURE)\s*$', typ)
                cur = dict(name=name, start=a, end=b, kind=kind, type=(t.group(1) if t else typ), raw=rest, copies=[])
                out.append(cur); copy = None
                if "STRUCTURE" in rest: cur["copies"] = []
            else:
                if cur is None: continue
                if copy is None:
                    copy = []; cur["copies"].append(copy)
                copy.append(dict(name=name, addr=a, end=b, raw=rest))
            continue
        c = COPY.match(l)
        if c and started and cur is not None and int(c.group(1), 16) >= cur["start"] and int(c.group(2) or c.group(1), 16) <= cur["end"]:
            copy = []; cur["copies"].append(copy); continue
        if started and l.startswith(" ") and re.match(r'^ [0-9A-F]{6}(-[0-9A-F]{6})?\s+(#[A-Z]\w+|\$\w+|@\w+|\w+)\s+\*\*\*\*', l):
            if out: break
    return out
def memory(cfg):
    return open(M + cfg + ".fcm", "rb").read()
def hw(mem, a): return struct.unpack_from(">H", mem, a * 2)[0]

# ---------------------------------------------------------------- values
VALRE = re.compile(r'^((?:[0-9A-F]{4}\s{1,2})*[0-9A-F]{4})?\s*(.*?)\s{2,}((?:SP |DP )?\S.*?)\s+(?:VARIABLE|TERMINAL)\s*$')
def ibm_sp(w0, w1):
    v = (w0 << 16) | w1
    if v & 0x7FFFFFFF == 0: return 0.0
    s = -1 if v >> 31 else 1; e = ((v >> 24) & 0x7F) - 64; f = v & 0xFFFFFF
    from fractions import Fraction
    return s * Fraction(f, 1 << 24) * (Fraction(16) ** e)
def ibm_dp(ws):
    v = 0
    for w in ws: v = (v << 16) | w
    if v & 0x7FFFFFFFFFFFFFFF == 0: return 0
    s = -1 if v >> 63 else 1; e = ((v >> 56) & 0x7F) - 64; f = v & 0xFFFFFFFFFFFFFF
    from fractions import Fraction
    return s * Fraction(f, 1 << 56) * (Fraction(16) ** e)
def to_ibm_sp(x):
    """nearest IBM single-precision (round half up on the 24-bit fraction) -> (w0, w1)"""
    from fractions import Fraction
    x = Fraction(x)
    if x == 0: return (0, 0)
    s = 0x80 if x < 0 else 0; x = abs(x); e = 0
    while x >= 1: x /= 16; e += 1
    while x < Fraction(1, 16): x *= 16; e -= 1
    f = x * (1 << 24); fi = int(f); r = f - fi
    if r >= Fraction(1, 2): fi += 1
    if fi >= (1 << 24): fi >>= 4; e += 1
    v = ((s | (e + 64)) << 24) | fi
    return (v >> 16, v & 0xFFFF)
def sci(x, digits):
    """x (Fraction) as HAL/S literal with `digits` significant digits, E notation"""
    from decimal import Decimal, getcontext
    getcontext().prec = 60
    d = Decimal(x.numerator) / Decimal(x.denominator)
    t = format(d, ".%dE" % (digits - 1))
    m, ex = t.split("E"); ex = int(ex)
    return "%sE%s%02d" % (m, "+" if ex >= 0 else "-", abs(ex))
def scalar_literal(w0, w1):
    if (w0 & 0x7FFF) == 0 and w1 == 0 and (w0 & 0x7F00) == 0: 
        if w0 == 0 and w1 == 0: return "0.0"
    x = ibm_sp(w0, w1)
    if x == 0: return "0.0"
    for dg in range(7, 12):
        lit = sci(x, dg)
        from fractions import Fraction
        if to_ibm_sp(Fraction(__import__("decimal").Decimal(lit))) == (w0, w1): return lit
    return sci(x, 17)
def signed(w): return w - 0x10000 if w & 0x8000 else w
