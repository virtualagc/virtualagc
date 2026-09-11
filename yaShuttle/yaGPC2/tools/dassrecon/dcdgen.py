"""Rebuild the OI340700 SM downlist members (DCD124xx/DCD126xx) from the flight #CDCDDS2."""
import re, sys, os, difflib, collections
H = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, H)
import dcdflt, cpgen, dasscp
from paths import PFS
S = dcdflt.statements()
area = hs = None
for s in S:
    for i in s["ins"]:
        m = re.match(r"CDWV_DWNLST_AREA\+(\d+)", i["note"])
        if m and area is None and i["ea"]: area = i["ea"] - int(m.group(1))
        m = re.match(r"HS_BUFFER\+(\d+)", i["note"])
        if m and hs is None and i["ea"]: hs = i["ea"] - int(m.group(1))
def full(a16, zrb=False):
    return 0x38000 | (a16 & 0x7FFF) if (zrb or a16 >= 0x8000) else a16
def dest_of(a, zrb):
    f = full(a, zrb) if a < 0x10000 else a
    if hs <= f < hs + 64: return ("HS", f - hs)
    return ("DL", f - area - 127)
G = cpgen.Gen("S2")
def src_candidates(src):
    kind = src[0]
    if kind == "note":
        a16 = src[2]
        if a16 is None: return []
        if a16 >= 0x10000: return [a16]
    else:
        a16 = src[1]
    return [(s << 15) | (a16 & 0x7FFF) for s in range(8)] if a16 & 0x8000 else [a16]
STMT_RE = re.compile(r"^\s*(DO\b.*|END\b.*|%COPY\((DL|HS)\(\s*(\d+)\s*\),\s*(.*?),\s*(\d+)\s*\);|(DL|HS)\(\s*(\d+)\s*\)\s*=\s*(.*?);)\s*$")
def src_member(name):
    for layer in ("OI340700", "OI340600"):
        p = "%s/%s/INCL80/%s.hal" % (PFS, layer, name)
        if os.path.exists(p) and os.path.getsize(p): return p
def parse_member(path):
    """[(kind, dest, count, srcexpr, card)] for statement cards"""
    out = []
    for c in open(path).read().split("\n"):
        if not c or c[0] != " ": continue
        body = c[1:72]; m = STMT_RE.match(body)
        if not m: raise SystemExit("unparsed card in %s: %r" % (path, c))
        if m.group(2): out.append(("%COPY", (m.group(2), int(m.group(3))), int(m.group(5)), m.group(4).strip(), c))
        elif m.group(6): out.append(("ASSIGN", (m.group(6), int(m.group(7))), 1, m.group(8).strip(), c))
        elif body.strip().startswith("END"): out.append(("END", None, 0, None, c))
        else: out.append(("DO", None, 0, None, c))
    return out
def plain(src):
    return src[0] == "note" and re.fullmatch(r"[A-Z0-9_]+", src[1] or "") and src[1]
def resolve_src(src, count):
    if plain(src): return plain(src), None
    for a in src_candidates(src):
        r = G.resolve(a)
        if r: return r, a
    return None, None
def rebuild(srn):
    name = dcdflt.MEMBERS[srn]
    fl = [s for s in S if s["srn"] == srn]
    fd = [dcdflt.decode(s, dest_of) for s in fl]
    old = parse_member(src_member(name))
    sig = lambda t: (t[0], t[1], t[2])
    sm = difflib.SequenceMatcher(None, [sig(o) for o in old], [sig(d) for d in fd], autojunk=False)
    cards = []; kept = new = 0; frame = -1; fixed = []; origin = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            for k in range(i2 - i1):
                o = old[i1 + k]; fdk = fd[j1 + k]
                if False and o[0] in ("%COPY", "ASSIGN") and not same_source(o[3], fdk[3]):
                    expr, a = resolve_src(fdk[3], fdk[2])
                    if expr is None: raise SystemExit("%s: flight source %r does not resolve" % (name, fdk[3]))
                    c = o[4][:72].rstrip().replace(o[3], expr, 1)
                    cards.append(c); fixed.append((o[3], expr)); continue
                cards.append(o[4][:72].rstrip()); kept += 1; origin.append(fl[j1 + k])
            continue
        for j in range(j1, j2):
            kind, dest, cnt, src = fd[j]
            origin.append(fl[j])
            if kind == "DO": cards.append(" DO;"); new += 1; continue
            if kind == "END": cards.append(" END;"); new += 1; continue
            expr, a = resolve_src(src, cnt)
            if expr is None: raise SystemExit("%s line %d: source %r does not resolve" % (name, fl[j]["line"], src))
            d = "%s(%3d)" % dest
            cards.append(" %%COPY(%s,%s, %d);" % (d, expr, cnt) if kind == "%COPY" else " %s = %s;" % ("%s( %d )" % dest, expr))
            new += 1
    rebuild.fixed = fixed; rebuild.origin = origin
    return name, cards, kept, new, len(old), len(fd)
def norm(e):
    e = e.replace(" ", "")
    e = re.sub(r"\$(\d+)$", r"$(\1)", e)
    parts = e.split(".")
    return (parts[0] + "." + parts[-1]) if len(parts) > 2 else e
def same_source(expr, src):
    ex = norm(expr); cands = [plain(src)] if plain(src) else []
    for a in src_candidates(src):
        for nm in G.all_names(a):
            cands.append(norm(nm)); cands.append(norm(nm.split(".")[-1]))
            cands.append(norm(re.sub(r"\$\((\d+):?\)$", r"$(\1)", nm)))
    exb = re.sub(r"\$\((\d+):?\)$", r"$(\1)", ex)
    return ex in cands or exb in cands or ex.split(".")[-1] in cands
if __name__ == "__main__":
    for srn in dcdflt.MEMBERS:
        name, cards, kept, new, no, nf = rebuild(srn)
        print("%s: OI340600 %d statements, flight %d; kept %d, written %d" % (name, no, nf, kept, new))

def write_member(name, cards, dst):
    src = open(src_member(name)).read().split("\n")
    head = [c for c in src if c.startswith("C/")]
    rest = [c for c in src if c and not c.startswith("C/")]
    body = []; last = None; code = None
    for c in src:
        if c and c[0] == " ":
            code = c[78:80] or code
    k = 0
    for c in cards:
        if len(c) > 72: raise SystemExit("long card %r" % c)
        # reuse the card's own SRN when it is an OI340600 card, else follow the previous
        orig = next((o for o in src if o[:72].rstrip() == c.rstrip() and o[0] == " "), None)
        if orig is not None and len(orig) >= 80:
            srn = orig[72:80]; last = int(orig[72:78]); code = orig[78:80]
        else:
            last = (last or 0) + 1; srn = "%06d%s" % (last, code or "AA")
        body.append(c.ljust(72) + srn)
    open(dst, "w").write("\n".join(head + [c for c in src if c.startswith("C") and not c.startswith("C/") and False] + body) + "\n")
