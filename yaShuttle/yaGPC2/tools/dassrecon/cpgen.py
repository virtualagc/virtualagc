"""Regenerate compool DECLAREs from a DASS dump: values from memory, layout from the listing."""
import re, sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dasscp, oracle, halsrc
RAW = re.compile(r"^((?:[0-9A-F]{4}\s+)*?)\s*(\S.*?)?\s{2,}((?:ARRAY\s+)?(?:SP |DP )?(?:NAME\s+)?(?:INTEGER|SCALAR|BIT STRING|CHARACTER|EVENT|STRUCTURE|VECTOR|MATRIX))\s+(?:TERMINAL|VARIABLE)\s*$")
class Gen:
    def __init__(self, cfg="S2"):
        self.cfg = cfg; self.mem = dasscp.memory(cfg); self.sp = set(); self.dp = set(); self.names = None
    def w(self, a): return dasscp.hw(self.mem, a)
    # ---------------------------------------------------------- one value
    def term(self, t, bitlen=None):
        """HAL/S literal for one terminal/scalar line dict(addr,end,raw)"""
        raw = t["raw"]; a, b = t["addr"], t.get("end", t["addr"])
        if " NAME " in " " + raw + " " or "NAME" in raw.split():
            return self.name_of(self.w(a), t)
        if "SCALAR" in raw:
            if "DP " in raw or b - a == 3:
                v = 0
                for k in range(4): v = (v << 16) | self.w(a + k)
                self.dp.add(v); return ("DP", v)
            v = (self.w(a) << 16) | self.w(a + 1); self.sp.add(v); return ("SP", v)
        if "INTEGER" in raw:
            if "DP " in raw or b > a:
                v = (self.w(a) << 16) | self.w(a + 1)
                return str(v - (1 << 32) if v & 0x80000000 else v)
            return str(dasscp.signed(self.w(a)))
        if "BIT STRING" in raw:
            tf = re.search(r"\b(TRUE|FALSE)\b", raw)
            if tf: return "ON" if tf.group(1) == "TRUE" else "OFF"
            m = re.search(r"BIN'([01]+)'", raw)
            if m:                 # the dump decodes the field itself (DENSE packing)
                return self.bits(int(m.group(1), 2), len(m.group(1)))
            n = bitlen or 16
            v = self.w(a) if b == a else (self.w(a) << 16) | self.w(a + 1)
            return self.bits(v, n)
        if "CHARACTER" in raw:
            m = re.search(r"('(?:[^']|'')*')", raw)
            if m: return m.group(1)
        raise SystemExit("cannot render %r" % raw)
    @staticmethod
    def bits(v, n):
        v &= (1 << n) - 1 if n < 32 else 0xFFFFFFFF
        if n % 4 == 0: return "HEX'%0*X'" % (n // 4, v)
        return "BIN'%s'" % format(v, "0%db" % n)
    def name_of(self, p, t=None):
        if p == 0: return "NULL"
        r = self.resolve(p, whole=bool(t and "STRUCTURE" in t.get("raw", "")))
        if r is None: raise SystemExit("NAME %04X at %06X does not resolve" % (p, t["addr"] if t else 0))
        return "NAME(%s)" % r
    def all_names(self, p):
        self.resolve(0x10)
        return [nm for kind, nm, cs in self.names.get(p, [])]
    def resolve(self, p, whole=False):
        """a variable or STRUCT.TERMINAL at address p, from the whole listing"""
        if self.names is None:
            self.names = collections.defaultdict(list)
            FIELD = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+([#@$]?\w+)\+([0-9A-F]{4})\s+(\S+)\s*(.*)$')
            stru = None; copy = None; ncop = 1
            COPYL = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+\+\+\+ COPY (\d+) OF (\d+) \+\+\+')
            for l in dasscp.lines(self.cfg):
                cm = COPYL.match(l)
                if cm and stru:
                    copy = int(cm.group(3)); ncop = int(cm.group(4)); continue
                m = FIELD.match(l)
                if not m or "ALIGNMENT GAP" in l or re.fullmatch(r"\*?[0-9A-F]{4}", m.group(5)): continue
                a = int(m.group(1), 16); b = int(m.group(2), 16) if m.group(2) else a
                kind = "VARIABLE" if l.rstrip().endswith("VARIABLE") else "TERMINAL"
                if kind == "VARIABLE":
                    stru = (m.group(5), a, b) if "STRUCTURE" in l else None; copy = None; ncop = 1
                    self.names[a].append(("V", m.group(5), m.group(3)))
                    rest = m.group(6)
                    if re.search(r"\bARRAY\b", rest) and b > a:
                        step = 4 if "DP SCALAR" in rest else 2 if ("SCALAR" in rest or "DP INTEGER" in rest) else 1
                        colon = ":" if ("BIT STRING" in rest or "CHARACTER" in rest) else ""
                        for k, x in enumerate(range(a, b + 1, step)):
                            self.names[x].append(("E", "%s$(%d%s)" % (m.group(5), k + 1, colon), m.group(3)))
                elif stru and stru[1] <= a <= stru[2]:
                    q = "$(%d;)" % copy if (copy and ncop > 1) else ""
                    self.names[a].append(("T", "%s.%s%s" % (stru[0], m.group(5), q), m.group(3)))
        c = self.names.get(p, [])
        order = ("V", "T", "E") if whole else ("T", "E", "V")
        for want in order:
            for kind, nm, cs in c:
                if kind == want: return nm
        return None
    # ---------------------------------------------------------- whole variables
    def values(self, var, bitlen=None, elem=None):
        """list of copies; each a list of values (strings or ('SP'|'DP', bits))"""
        if var["copies"]:
            out = []
            for c in var["copies"]:
                row = []
                for t in c:
                    if re.search(r"\bARRAY\b", t["raw"]) and t["end"] > t["addr"]:
                        row += self.values(dict(copies=[], raw=t["raw"], start=t["addr"], end=t["end"]), bitlen=bitlen)[0]
                    else: row.append(self.term(t))
                out.append(row)
            return out
        raw = var["raw"]
        if raw.lstrip().startswith("ARRAY") or "ARRAY" in raw.split()[:3]:
            a, b = var["start"], var["end"]; out = []
            if "SCALAR" in raw or "VECTOR" in raw or "MATRIX" in raw:
                step = 4 if "DP " in raw else 2
                for x in range(a, b + 1, step): out.append(self.term(dict(addr=x, end=x + step - 1, raw=("DP " if step == 4 else "SP ") + "SCALAR")))
            elif "INTEGER" in raw:
                step = 2 if "DP " in raw else 1
                for x in range(a, b + 1, step): out.append(self.term(dict(addr=x, end=x + step - 1, raw=("DP " if step == 2 else "SP ") + "INTEGER")))
            elif "BIT STRING" in raw:
                n = bitlen or 16; step = 1 if n <= 16 else 2
                for x in range(a, b + 1, step): out.append(self.bits(self.w(x) if step == 1 else (self.w(x) << 16) | self.w(x + 1), n))
            else: raise SystemExit("array kind %r" % raw)
            return [out]
        if "VECTOR" in raw or "MATRIX" in raw:      # a single vector/matrix: its scalars in order
            step = 4 if "DP " in raw else 2
            return [[self.term(dict(addr=x, end=x + step - 1, raw=("DP " if step == 4 else "SP ") + "SCALAR"))
                     for x in range(var["start"], var["end"] + 1, step)]]
        return [[self.term(dict(addr=var["start"], end=var["end"], raw=raw))]]
    def zeros(self, var, bitlen=None):
        """the value list of `var` with every value zero"""
        real = self.values(var, bitlen=bitlen)
        def z(x):
            if isinstance(x, tuple): return "0.0"
            if x.startswith("NAME") or x == "NULL": return "NULL"
            if x.startswith("HEX'"): return "HEX'%s'" % ("0" * (len(x) - 5))
            if x.startswith("BIN'"): return "BIN'%s'" % ("0" * (len(x) - 5))
            if x in ("ON", "OFF"): return "OFF"
            if x.startswith("'"): return "''"
            return "0"
        return [[z(x) for x in c] for c in real]
    def finish(self, v):
        if isinstance(v, tuple):
            return (self.split[v[1]] if v[0] == "SP" else self.dplit[v[1]])
        return v
    def resolve_literals(self):
        self.split = oracle.literals(self.sp) if self.sp else {}
        self.dplit = oracle.literals(self.dp, dp=True) if self.dp else {}
    def initial(self, copies, flat_array=False):
        """INITIAL list text, with runs of identical copies (or elements) folded as k#(...)"""
        items = [[self.finish(v) for v in c] for c in copies]
        if flat_array: items = [[v] for v in items[0]]
        out = []; i = 0
        while i < len(items):
            j = i
            while j + 1 < len(items) and items[j + 1] == items[i]: j += 1
            n = j - i + 1; body = ",".join(items[i])
            if n > 1 and len(items[i]) == 1 and body.startswith("-"): body = "(%s)" % body
            if n > 1: out.append("%d#%s" % (n, body if len(items[i]) == 1 else "(%s)" % body))
            else: out.append(body)
            i = j + 1
        return ",\x00".join(out) if not flat_array else ",".join(out)

from paths import PFS, TREE, HERE
def source_path(stem):
    for layer in ("OI340700", "OI340600"):
        for d in ("APPLSRC", "SSSRC"):
            p = "%s/%s/%s/%s.hal" % (PFS, layer, d, stem)
            if os.path.exists(p) and os.path.getsize(p): return p, layer, d
    raise SystemExit("no source for " + stem)
def regenerate(stem, csect, cfg="S2", keep=(), drop_missing=True, verbose=True, template=None, zero=()):
    """Rewrite every DECLARE of `stem` that the dump holds; returns (Src, report)."""
    path, layer, sub = source_path(stem)
    src = halsrc.Src(path); g = Gen(cfg)
    dvars = {v["name"]: v for v in dasscp.parse(csect, cfg)}
    seen = set(); rep = collections.defaultdict(list); pending = []; first_removed = None
    for f, l, ents in src.declares():
        names = [e["name"] for e in ents]
        inpool = [n for n in names if n in dvars]
        if not inpool:
            rep["source-only"].append(names)
            if drop_missing and all(e["init"] or True for e in ents) and not any(n in keep for n in names):
                if any(e.get("const") for e in ents): rep["kept-constant"].append(names); continue
                c1 = src.remove_statement(f - 0, l); rep["removed"].append(names)
                if first_removed is None: first_removed = (src.toks[f][0], c1)
            continue
        for e in ents:
            v = dvars.get(e["name"])
            if v is None: rep["entity-not-in-dump"].append(e["name"]); continue
            seen.add(e["name"])
            bitlen = None
            for at, val in e["attrs"]:
                if at == "BIT" and val and val.isdigit(): bitlen = int(val)
            if not e["init"] and not e["dim"]:
                continue                      # nothing to regenerate (e.g. a CONSTANT)
            if ("CHARACTER" in v["raw"] or "EVENT" in v["raw"]) and not v["copies"]:
                rep["character-kept"].append(e["name"]); continue
            if e["name"] in zero:
                copies = g.zeros(v, bitlen=bitlen)
                pending.append((e, copies, not v["copies"] and "ARRAY" in v["raw"]))
                rep["zeroed(flight has no text)"].append(e["name"]); continue
            copies = g.values(v, bitlen=bitlen)
            isarray = not v["copies"] and ("ARRAY" in v["raw"].split()[:2] or v["raw"].lstrip().startswith("ARRAY"))
            n = len(copies[0]) if isarray else len(copies)
            if isarray:
                per = 1
                for at, val in e["attrs"]:
                    if at == "VECTOR": per = int(val) if val and val.isdigit() else 3
                    if at == "MATRIX":
                        rc = [int(x) for x in (val or "3,3").split(",")]; per = rc[0] * rc[1]
                if "VECTOR" in v["raw"] and per == 1: per = 3
                if "MATRIX" in v["raw"] and per == 1: per = 9
                n //= per
            if e["dim"]:
                old = src.span_text(*e["dim"]).strip()
                if old != str(n):
                    if not old.isdigit(): rep["dim-expression"].append((e["name"], old, n))
                    else: src.replace_between(e["dim"][0], e["dim"][1], str(n)); rep["dim"].append((e["name"], old, n))
            elif (isarray and n > 1) or (v["copies"] and len(copies) > 1):
                rep["dim-missing"].append((e["name"], n))
            allfill = all(isinstance(x, str) and x in ("-13829", "-14650", "HEX'C9FB'", "HEX'C6C6'")
                          for c in copies for x in c) or \
                      all(g.w(x) in (0xC9FB, 0xC6C6, 0) for x in range(v["start"], v["end"] + 1)) and \
                      any(g.w(x) in (0xC9FB, 0xC6C6) for x in range(v["start"], v["end"] + 1))
            if allfill:
                # The flight compiler emitted NO TEXT for an all-zero variable
                # (CSDMDT's 115#0 pad, CRDCIL's zero-vector CONSTANT), so fill in
                # the dump means zero or uninitialised -- leave the source alone.
                rep["flight-no-text(source kept)"].append(e["name"])
                continue
            if e["init"]: pending.append((e, copies, isarray))
            elif any(x not in ("0", "0.0", "HEX'0000'", "NULL") for c in copies for x in c if isinstance(x, str)):
                rep["uninitialised-in-source"].append(e["name"])
    # templates only the removed declarations used
    if rep.get("removed"):
        kept = src.text
        for f, l, ents in src.declares():
            pass
        gone = {n for grp in rep["removed"] for n in grp}
        for f, l, tname in src.structures():
            uses = [m.start() for m in re.finditer(r"\b%s-STRUCTURE\b" % re.escape(tname), src.text)]
            live = False
            for f2, l2, ents in src.declares():
                if any(src.toks[f2][0] <= u <= src.toks[l2][1] for u in uses) and not all(e["name"] in gone for e in ents):
                    live = True
            if not live and uses:
                src.remove_statement(f, l); rep["template-removed"].append(tname)
    adds = [n for n in dvars if n not in seen]
    newstmts = []
    if adds and template:
        for n in adds:
            v = dvars[n]; t = template(n, v)
            if t is None: continue
            copies = g.values(v)
            dim = "(%d)" % len(copies) if len(copies) > 1 else ""
            newstmts.append((n, t, dim, copies))
    g.resolve_literals()
    if newstmts:
        order = list(dvars)
        stm = {}                                   # name -> (first char pos, last char pos, last card)
        removed_at = []                            # (char pos, card) of removed statements
        for f, l, ents in src.declares():
            for e in ents:
                stm[e["name"]] = (src.toks[f][0], src.toks[l][0], src.pos[src.toks[l][0]][0])
        for op in getattr(src, "ops", []):
            if op[0] == "del": removed_at.append((op[1], op[2]))
        byname = {n: (n, t, dim, c) for n, t, dim, c in newstmts}
        groups = []; cur = []
        for n in order:
            if n in byname: cur.append(n)
            elif cur: groups.append((cur, n)); cur = []
        if cur: groups.append((cur, None))
        for grp, succ in groups:
            i = order.index(grp[0]); pred = next((order[k] for k in range(i - 1, -1, -1) if order[k] in stm and order[k] not in byname), None)
            lo = stm[pred][1] if pred else -1; hi = stm[succ][0] if succ in stm else 10 ** 9
            cand = sorted(r for r in removed_at if lo < r[0] < hi)
            if cand: key, card = cand[0]
            elif pred: key, card = stm[pred][1] + 1, stm[pred][2] + 1
            else: raise SystemExit("nowhere to insert %s" % grp)
            src.insert_at_card(key, card, ["DECLARE %s %s-STRUCTURE%s INITIAL(%s);" % (n, byname[n][1], byname[n][2], g.initial(byname[n][3]).replace("\x00", "")) for n in grp])
        rep["added"] = [n for n, _, _, _ in newstmts]
        adds = [n for n in adds if n not in rep["added"]]
    for e, copies, isarray in pending:
        src.replace_between(e["init"][0], e["init"][1], g.initial(copies, flat_array=isarray))
    rep["dump-only"] = adds
    if verbose:
        for k, v in rep.items():
            if v: print("  %s: %s" % (k, v if len(str(v)) < 300 else str(v)[:300] + " ..."))
    return src, rep, path, layer, sub
def trial(stem, csect, cfg="S2", **kw):
    src, rep, path, layer, sub = regenerate(stem, csect, cfg, **kw)
    out = "%s/%s/%s.hal" % (TREE, sub, stem)
    open(out, "w").write(src.render())
    import subprocess
    r = subprocess.run([os.path.join(HERE, "hc.sh"), stem, sub], capture_output=True, text=True)
    print(r.stdout.strip())
    if "compiled" in r.stdout:
        r2 = subprocess.run(["python3", os.path.join(HERE, "objcmp.py"), "%s/objects/%s.obj" % (TREE, stem), csect, cfg, "--show", "8"], capture_output=True, text=True)
        print(r2.stdout.rstrip()); return r2.returncode == 0
    return False

NOTE = """C/              2026-09-11 RSB  OI340700 form: data rebuilt from the
C/                              DASS dump by dass-cpgen.py.
C/ Note (OI340700): THE INITIAL DATA, AND WHERE IT DIFFERS THE DECLARED
C/              COUNTS, ARE RECOVERED FROM THE DASS SM2 MEMORY DUMP OF
C/              OI340700 (#P{stem} at {addr}); every other card is
C/              {layer}'s, unchanged.  These tables are generated,
C/              mission-dependent data (the F GEN blocks), and {layer}
C/              carried another flight's: compiled as it stood, #P{stem}
C/              was {old} halfwords against the flight's {new}{overlap}.
C/              Each value was read from memory and the result compiled
C/              with HAL/S-FC and compared with the dump halfword for
C/              halfword, NAME pointers relocated to the dump's own
C/              addresses: they agree{nottext}.
C/              Per-entry comment cards inside a regenerated list
C/              described {layer}'s entries and are dropped; the dump
C/              records values, not comments.{changes}"""
def header(text, stem, csect, layer, old, new, rep, addr):
    L = text.split("\n")
    i = next((k for k, l in enumerate(L) if l.startswith("C/ History:")), None)
    if i is None: raise SystemExit("%s: no C/ History line" % stem)
    j = i + 1
    while j < len(L) and L[j].startswith("C/ ") and L[j][3:4] == " ": j += 1
    ch = []
    if rep.get("dim"): ch.append("counts changed: " + ", ".join("%s %s->%s" % d for d in rep["dim"]))
    if rep.get("removed"): ch.append("%d declarations not in the dump removed" % len(rep["removed"]))
    if rep.get("added"): ch.append("%d declared from the dump" % len(rep["added"]))
    if rep.get("zeroed(flight has no text)"): ch.append("zeroed (no text in the flight): " + ", ".join(rep["zeroed(flight has no text)"]))
    chs = ""
    for c in ch:
        words = c.split(); line = "C/              "
        out = []
        for w in words:
            if len(line) + len(w) + 1 > 72: out.append(line.rstrip()); line = "C/                "
            line += w + " "
        out.append(line.rstrip()); chs += "\n" + "\n".join(out)
    nt = "" if not rep.get("_nottext") else " (except %d halfwords the flight\nC/              compiler left without text, as it did for all-zero\nC/              data, where HAL/S-FC emits zeros)" % rep["_nottext"]
    ov = " and overlapped its neighbours in the link" if old > new else ""
    note = NOTE.format(stem=csect[2:], addr=addr, layer=layer, old=old, new=new, overlap=ov, nottext=nt, changes=chs)
    L[j:j] = note.split("\n")
    return "\n".join(L)
