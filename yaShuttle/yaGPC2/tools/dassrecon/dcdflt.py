"""Decompile the downlist-member statements of #CDCDDS2 from the DASS SM2 listing."""
import re, sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dasscp
INSTR = re.compile(r'^ ([0-9A-F]{6})(?:-[0-9A-F]{6})?\s+#CDCDDS2\+([0-9A-F]{4})\s+([0-9A-F]{4})(?:\s+([0-9A-F]{4}))?\s+(?:([0-9A-F]{6})\s+)?([A-Z@#]+)\s+(\S+)\s*(.*?)\s*$')
STMT = re.compile(r'#CDCDDS2\+([0-9A-F]{4})\s+ST#(\d+)\s+EQU\s+\*\s+(\S.*?)\s+(\d{6})\s+(\d+)\s*$')
def statements(cfg="S2"):
    out = []; cur = None
    for l in dasscp.lines(cfg):
        m = STMT.search(l)
        if m:
            cur = dict(off=int(m.group(1), 16), st=int(m.group(2)), kind=m.group(3).strip(), srn=m.group(4), line=int(m.group(5)), ins=[])
            out.append(cur); continue
        m = INSTR.match(l)
        if m and cur is not None:
            cur["ins"].append(dict(addr=int(m.group(1), 16), w=[int(m.group(3), 16)] + ([int(m.group(4), 16)] if m.group(4) else []),
                                   ea=int(m.group(5), 16) if m.group(5) else None, op=m.group(6), opnd=m.group(7), note=m.group(8)))
    return out
if __name__ == "__main__":
    S = statements()
    for s in S:
        if s["srn"] == sys.argv[1]:
            print("%3d %-7s" % (s["line"], s["kind"]), " ; ".join("%s %s %s" % (i["op"], i["opnd"], i["note"][:40]) for i in s["ins"])[:220])

MEMBERS = {"006300": "DCD12425", "006500": "DCD12412", "006800": "DCD12405", "007100": "DCD12401",
           "007230": "DCD12625", "007240": "DCD12612", "007255": "DCD12605", "007270": "DCD12601"}
LIT = re.compile(r"=X'([0-9A-F]{4,8})'")
def slot(ea, names):
    """destination address -> ('DL', n) or ('HS', n)"""
    return names(ea)
def decode(s, dest_of):
    """(kind, dest, count, src) with src = ('ea', addr) | ('lit16', value) | ('note', text)"""
    k = s["kind"]; ins = s["ins"]
    if k in ("DO", "END"): return (k, None, 0, None)
    loads = [i for i in ins if i["op"] in ("LH", "L", "LE", "LED")]
    stores = [i for i in ins if i["op"] in ("STH", "ST", "STE", "STED")]
    mvh = [i for i in ins if i["op"] == "MVH"]
    if mvh:
        lits = [LIT.search(i["note"]).group(1) for i in ins if i["op"] == "L" and LIT.search(i["note"])]
        d = int(lits[0], 16); sr = int(lits[1], 16)
        zrb = any(i["op"] == "ZRB" for i in ins)
        dst16 = (d >> 16) & (0x7FFF if zrb else 0xFFFF); cnt = d & 0xFFFF
        return (k, dest_of(dst16, zrb), cnt, ("lit16", sr >> 16))
    # LH/STH, L/ST pairs; a based load (LH R2,lit; LH R4,d(R2)) reads through a register
    cnt = sum(4 if i["op"] == "STED" else 2 if i["op"] in ("ST", "STE") else 1 for i in stores)
    first_st = stores[0]; first_ld = [i for i in loads if not LIT.search(i["note"])][0]
    return (k, dest_of(first_st["ea"], False), cnt, ("note", first_ld["note"], first_ld["ea"]))
