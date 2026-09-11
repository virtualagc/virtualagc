#!/usr/bin/env python3
"""objcmp.py OBJ CSECT CFG [--show N] : compare a compiled compool CSECT's text with the DASS dump."""
import sys, json, struct
obj, cs, cfg = sys.argv[1:4]; show = int(sys.argv[sys.argv.index("--show") + 1]) if "--show" in sys.argv else 10
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from paths import MAFGEN as M, SDL
raw = open(obj, "rb").read(); cards = [raw[i:i+80] for i in range(0, len(raw), 80)]
def eb(b): return b.decode("cp037", "replace")
esd = {}; length = {}
for c in cards:
    if c[0] == 2 and eb(c[1:4]) == "ESD":
        n = (c[10] << 8) | c[11]; first = (c[14] << 8) | c[15]
        for i in range(n // 16):
            e = c[16+16*i:32+16*i]; nm = eb(e[:8]).strip(); t = e[8]
            if t in (0, 4, 5):          # SD, PC, CM
                esd[first + i] = nm; length[nm] = int.from_bytes(e[13:16], "big")
            if t in (0,1,2,4,5,6,10): first_i = None
text = {}
for c in cards:
    if c[0] == 2 and eb(c[1:4]) == "TXT":
        addr = int.from_bytes(c[5:8], "big"); cnt = (c[10] << 8) | c[11]; eid = (c[14] << 8) | c[15]
        if esd.get(eid) == cs:
            for k in range(cnt): text[addr + k] = c[16 + k]
tab = json.load(open(M + "csects-%s.json" % cfg)); e = tab[cs]
# ---- relocate: every RLD whose position is in this csect, against the dump's addresses
names = {}          # esdid -> name, for SD/LD/ER
for c in cards:
    if c[0] == 2 and eb(c[1:4]) == "ESD":
        n = (c[10] << 8) | c[11]; first = (c[14] << 8) | c[15]; k = 0
        for i in range(n // 16):
            en = c[16+16*i:32+16*i]; t = en[8]
            if t in (0, 1, 2, 4, 5, 6, 10):
                names[first + k] = eb(en[:8]).strip(); k += 1 if t != 1 else 0
            if t == 1: pass
lds = {}
for nm, ent in tab.items():
    if isinstance(ent, dict) and "start" in ent:
        lds.setdefault(nm, ent["start"])
        for ld, off in (ent.get("contents") or {}).items():
            lds.setdefault(ld, ent["start"] + (off if isinstance(off, int) else off.get("offset", 0)))
relocated = 0; unres = []
for c in cards:
    if c[0] != 2 or eb(c[1:4]) != "RLD": continue
    n = (c[10] << 8) | c[11]; d = c[16:16 + n]; i = 0; R = P = None; cont = False
    while i < len(d):
        if not cont:
            R = (d[i] << 8) | d[i+1]; P = (d[i+2] << 8) | d[i+3]; i += 4
        fl = d[i]; addr = int.from_bytes(d[i+1:i+4], "big"); i += 4
        cont = bool(fl & 1)
        if esd.get(P) != cs: continue
        L = ((fl >> 2) & 3) + 1; typ = (fl >> 4) & 7
        tgt = lds.get(names.get(R))
        if tgt is None: unres.append(names.get(R)); continue
        if (fl & 0x7F) in (0x04, 0x10, 0x50, 0x54, 0x14) or typ in (1, 5):
            import sys as _s; _s.path.insert(0, SDL)
            from ap101Utils.addrcon import ZCon
            from ap101Utils.addr import Addr
            buf = bytearray(text.get(addr + k, 0) for k in range(4))
            z = ZCon.from_image(buf, 0); z.apply(Addr.from_hw(tgt), fl & 0x7F, fl); z.write_to_image(buf, 0)
            for k in range(4): text[addr + k] = buf[k]
            relocated += 1; continue
        if typ != 0 or L != 1: unres.append("%s(type %d len %d)" % (names.get(R), typ, L)); continue
        ex = (text.get(addr, 0) << 8) | text.get(addr + 1, 0)
        v = (tgt - ex if (fl & 0x80) else tgt + ex); v = -v if (fl & 2) else v
        v = (0x8000 | (v & 0x7FFF)) if v >= 0x8000 else v      # sector-encoded above 32K
        text[addr] = v >> 8; text[addr + 1] = v & 0xFF; relocated += 1
if unres: print("  unrelocated:", sorted(set(map(str, unres)))[:8])
d = open(M + cfg + ".fcm", "rb").read()
dz = e["end"] - e["start"] + 1; oz = length.get(cs, 0) // 2
diff = []; covered = 0
for h in range(max(dz, oz)):
    b0, b1 = text.get(2*h), text.get(2*h+1)
    ours = None if b0 is None else (b0 << 8) | (b1 or 0)
    dv = struct.unpack_from(">H", d, (e["start"] + h) * 2)[0] if h < dz else None
    if ours is not None: covered += 1
    if ours != dv and not (ours is None and dv in (0xC6C6, 0xC9FB)): diff.append((h, ours, dv))
if "--dump" in sys.argv:
    json.dump([(text.get(2*h, 0) << 8) | text.get(2*h+1, 0) for h in range(oz)], open(sys.argv[sys.argv.index("--dump") + 1], "w"))
cfill = [x for x in diff if x[1] == 0 and x[2] in (0xC6C6, 0xC9FB)]
diff = [x for x in diff if x not in cfill]
print("%s: ours %d hw (text %d), DASS %s %d hw; %d differ%s" % (cs, oz, covered, cfg, dz, len(diff),
      "  (+%d where we emit 0000 and the flight has no text)" % len(cfill) if cfill else ""))
for h, o, dv in diff[:show]: print("   +%04x ours %s DASS %s" % (h, "%04x" % o if o is not None else "----", "%04x" % dv if dv is not None else "----"))
sys.exit(1 if diff or oz != dz else 0)
