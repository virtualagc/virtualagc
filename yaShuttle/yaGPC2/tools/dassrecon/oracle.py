"""Literal oracle: decimal literals that HALSFC converts to given IBM floats, found by compiling."""
import json, os, subprocess, sys
from fractions import Fraction
from decimal import Decimal, getcontext
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import dasscp
getcontext().prec = 80
from paths import HERE, TREE, WORK
CACHE = os.path.join(WORK, "oracle.json")
def _load():
    try: return json.load(open(CACHE))
    except Exception: return {}
def _cands(bits, dp, rnd):
    nw = 4 if dp else 2
    ws = [(bits >> (16 * (nw - 1 - i))) & 0xFFFF for i in range(nw)]
    x = dasscp.ibm_dp(ws) if dp else dasscp.ibm_sp(*ws)
    if x == 0: return ["0.0"]
    # one unit in the last place
    e = (bits >> (8 * nw * 2 - 8)) & 0x7F; ulp = (Fraction(16) ** (e - 64)) / (1 << (56 if dp else 24))
    out = []
    digs = range(7, 18) if not dp else range(15, 21)
    for k in ([0] if rnd == 0 else [Fraction(j, 8) for j in range(-4, 8)]):
        for dg in digs:
            s = dasscp.sci(x + k * ulp * (1 if x > 0 else -1), dg)
            if s not in out: out.append(s)
    return out
def _compile(pairs, dp):
    src = [" ORACLE: COMPOOL RIGID;"]
    for i, (_, l) in enumerate(pairs):
        src.append(" DECLARE Q%05d SCALAR%s INITIAL(%s);" % (i, " DOUBLE" if dp else "", l))
    src.append(" CLOSE ORACLE;")
    open(os.path.join(TREE, "APPLSRC/ORACLE.hal"), "w").write(
        "\n".join(s.ljust(72) + "%08d" % (i * 10) for i, s in enumerate(src)) + "\n")
    r = subprocess.run([os.path.join(HERE, "hc.sh"), "ORACLE"], capture_output=True, text=True)
    if "compiled" not in r.stdout: raise SystemExit("oracle compile failed\n" + r.stdout)
    raw = open(os.path.join(TREE, "objects/ORACLE.obj"), "rb").read()
    text = {}
    for c in (raw[i:i+80] for i in range(0, len(raw), 80)):
        if c[0] == 2 and c[1:4].decode("cp037") == "TXT":
            a = int.from_bytes(c[5:8], "big"); n = (c[10] << 8) | c[11]
            for k in range(n): text[a + k] = c[16 + k]
    sz = 8 if dp else 4
    got = []
    for i in range(len(pairs)):
        o = i * sz
        if dp: o = (o + 7) // 8 * 8 if False else o
        got.append(int.from_bytes(bytes(text.get(o + k, 0) for k in range(sz)), "big"))
    return got
def literals(targets, dp=False):
    """{bits: literal} for every IBM float in targets (ints: 32-bit SP or 64-bit DP)."""
    cache = _load(); key = "dp" if dp else "sp"; cache.setdefault(key, {})
    want = [t for t in set(targets) if str(t) not in cache[key]]
    for rnd in (0, 1):
        if not want: break
        pairs = [(t, l) for t in want for l in _cands(t, dp, rnd)]
        for b in range(0, len(pairs), 3000):
            chunk = pairs[b:b + 3000]
            for (t, l), g in zip(chunk, _compile(chunk, dp)):
                if g == t and str(t) not in cache[key]: cache[key][str(t)] = l
        want = [t for t in want if str(t) not in cache[key]]
    json.dump(cache, open(CACHE, "w"))
    if want: raise SystemExit("no literal found for %s" % ["%x" % t for t in want])
    return {t: cache[key][str(t)] for t in set(targets)}
