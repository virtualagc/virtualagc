"""Raw-address semantic comparison of the DCD member statements, ours vs flight."""
import re, glob, os, json, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from paths import HERE as H, TREE
import dcdflt
def our_listing(stem="DCDDS2"):
    d = sorted(glob.glob(TREE + "/HALSFC %s.hal*.results" % stem), key=os.path.getmtime)[-1]
    out = {}; cur = None
    for l in open(d + "/pass2.rpt", errors="replace"):
        m = re.match(r"^0?([0-9A-F]{5,7})\s+ST#(\d+)\s+EQU", l)
        if m: cur = out.setdefault(int(m.group(2)), []); continue
        m = re.match(r"^\s?([0-9A-F]{5})\s+([0-9A-F]{4})(?:\s([0-9A-F]{4}))?\s+(?:[0-9A-F]{4}\s+)?\s*([A-Z@#]+)\s+(\S+)", l)
        if m and cur is not None:
            cur.append(dict(loc=int(m.group(1), 16), n=2 if m.group(3) else 1, op=m.group(4), opnd=m.group(5)))
    return out
def dump(cs, out):
    subprocess.run(["python3", H + "/objcmp.py", TREE + "/objects/DCDDS2.obj", cs, "S2", "--show", "0", "--dump", out], capture_output=True)
    return json.load(open(out))
DISP = re.compile(r"^(?:[RF]\d+,)?X?'?([0-9A-F]+)'?\(R1\)$|^(?:[RF]\d+,)?(\d+)\(R1\)$")
def r1disp(opnd):
    m = re.search(r",(?:X'([0-9A-F]+)'|(\d+))\(R1\)$", opnd)
    if not m: return None
    return int(m.group(1), 16) if m.group(1) else int(m.group(2))
def decode(ins, word, lit):
    """ins: [(op, opnd, words)]; word(k) not needed; lit(disp) -> 32-bit literal"""
    ops = [i[0] for i in ins]
    if "MVH" in ops:
        lits = [lit(r1disp(i[1])) for i in ins if i[0] == "L" and r1disp(i[1]) is not None]
        zrb = "ZRB" in ops
        if len(lits) < 2 or None in lits: return ("MVH?",)
        dst = (lits[0] >> 16) & (0x7FFF if zrb else 0xFFFF)
        return ("MVH", dst, lits[0] & 0xFFFF, lits[1] >> 16)
    body = []
    for op, opnd, ws in ins:
        if op in ("LH", "L", "LE", "LED", "STH", "ST", "STE", "STED", "IHL"):
            body.append((op, ws[1] if len(ws) > 1 else ("R1+%d" % r1disp(opnd) if r1disp(opnd) is not None else opnd.split(",")[-1])))
        else:
            body.append((op, None))
    return ("MOV", tuple(body))
def flight_stmts():
    F = {}
    for s in dcdflt.statements():
        if s["srn"] in dcdflt.MEMBERS and s["kind"] in ("%COPY", "ASSIGN"):
            lits = {}
            for i in s["ins"]:
                m = re.search(r"=X'([0-9A-F]{8})'", i["note"])
                if m and r1disp(i["opnd"]) is not None: lits[r1disp(i["opnd"])] = int(m.group(1), 16)
                m = re.search(r"=X'([0-9A-F]{4})'", i["note"])
                if m and not re.search(r"=X'([0-9A-F]{8})'", i["note"]) and r1disp(i["opnd"]) is not None: lits[r1disp(i["opnd"])] = int(m.group(1), 16)
            F[s["st"]] = (s, decode([(i["op"], i["opnd"], i["w"]) for i in s["ins"]], None, lambda d, L=lits: L.get(d)))
    return F
def our_stmts(sts):
    L = our_listing(); code = dump("#CDCDDS2", os.path.join(os.path.dirname(TREE), "oc.json")); data = dump("#DDCDDS2", os.path.join(os.path.dirname(TREE), "od.json"))
    out = {}
    for st in sts:
        ins = [(i["op"], i["opnd"], code[i["loc"]:i["loc"] + i["n"]]) for i in L.get(st, [])]
        lit = lambda d: ((data[d] << 16) | data[d + 1]) if d is not None and d + 1 < len(data) else None
        # a halfword literal (LH Rx,lit) is one word
        out[st] = decode(ins, None, lit)
    return out
if __name__ == "__main__":
    F = flight_stmts(); O = our_stmts(F)
    bad = [st for st in F if F[st][1] != O.get(st)]
    for st in bad[:int(sys.argv[1]) if len(sys.argv) > 1 else 10]:
        s = F[st][0]
        print("ST#%d %s line %d\n  flight %s\n  ours   %s" % (st, dcdflt.MEMBERS[s["srn"]], s["line"], F[st][1], O.get(st)))
    print(len(bad), "of", len(F), "member statements differ")
