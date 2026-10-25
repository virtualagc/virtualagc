#!/usr/bin/env python3
"""sts134-mission-db.py -- build sts134-mission.db from the Cooper shift-report cache.

SOURCE: ~/Desktop/"Shuttle Stuff"/"Cooper Shift"/ (48 files: the STS-134 Consolidated Shift Reports, the daily
reports, the CSR report, the 5/17 on-orbit report, the landing-plus-2-hour report and Boeing's Actual Mass
Properties Report SE11HOU028).  Nothing is typed in by hand except the SOURCES list of which table a file feeds
and the regexes below; every row carries its document and line, so a number can be checked against the page.

TABLES (all times GMT unless a column says MET; *_unix is seconds since 1970-01-01T00:00Z, year 2011):
  documents     one row per file: kind, flight day, shift, the GMT period it covers
  lines         every line of every document, with its section heading (the full text; nothing is discarded)
  lines_fts     full-text index over lines (SELECT ... FROM lines_fts WHERE lines_fts MATCH 'interconnect')
  events        every paragraph / numbered item that carries a GMT stamp, one row per distinct text, with the first
                stamp, all stamps, a kind (burn, dap, jets, interconnect, ...) and the documents that repeat it
  burns         OMS and RCS firings with TIG, cutoff, duration, delta-V, resulting orbit and jets, parsed from events
  propellant    the OMS/RCS block of every shift report: PFS % oxidizer/fuel for left, right and forward, and the OMS
                interconnect usage; with the report's own GMT where it gives one, else the end of its period
  consumables   GN2, waste tank, supply water, PPCO2, ... as reported per shift
  thrusters     the "N of 38 primary thrusters have been fired" count per report
  orbits        every "resulting orbit was HP x HA" sentence
  mass_items    Boeing's weight-and-balance checklist lines (item, weight lb, X, Y)
  mass_summary  the weight-and-balance totals (as weighed, inert, comparison)
  v_timeline    events ordered by time (a view)

USAGE
  sts134-mission-db.py build [--cache DIR] [--db FILE]     (re)build the database
  sts134-mission-db.py timeline [FROM] [TO]                print events between two GMT stamps, e.g. 150/02:00 150/12:00
  sts134-mission-db.py search TEXT                         full-text search of every line
  sts134-mission-db.py prop                                the PFS % series
"""
import argparse, calendar, json, os, re, sqlite3, subprocess, sys
from pathlib import Path

CACHE = Path.home() / "Desktop" / "Shuttle Stuff" / "Cooper Shift"
DB = Path(__file__).resolve().parent / "sts134-mission.db"
YEAR = 2011

SCHEMA = """
CREATE TABLE documents(id INTEGER PRIMARY KEY, path TEXT, name TEXT, kind TEXT, fd INTEGER, shift INTEGER,
    period_start TEXT, period_end TEXT, start_unix REAL, end_unix REAL, nlines INTEGER);
CREATE TABLE lines(doc_id INTEGER, seq INTEGER, section TEXT, text TEXT);
CREATE VIRTUAL TABLE lines_fts USING fts5(text, section, doc_id UNINDEXED, seq UNINDEXED);
CREATE TABLE events(id INTEGER PRIMARY KEY, gmt TEXT, unix REAL, kind TEXT, section TEXT, text TEXT,
    stamps TEXT, first_doc INTEGER, first_seq INTEGER, docs TEXT);
CREATE TABLE burns(id INTEGER PRIMARY KEY, name TEXT, tig TEXT, tig_unix REAL, cutoff TEXT, cutoff_unix REAL,
    duration_s REAL, dv_fps REAL, orbit_hp_nmi REAL, orbit_ha_nmi REAL, jets TEXT, engines TEXT, event_id INTEGER, note TEXT);
CREATE TABLE propellant(id INTEGER PRIMARY KEY, doc_id INTEGER, gmt TEXT, unix REAL, gmt_is_report INTEGER,
    left_ox REAL, left_fu REAL, right_ox REAL, right_fu REAL, fwd_ox REAL, fwd_fu REAL, ic_left REAL, ic_right REAL, seq INTEGER);
CREATE TABLE consumables(id INTEGER PRIMARY KEY, doc_id INTEGER, gmt TEXT, unix REAL, quantity TEXT, value REAL, unit TEXT, text TEXT, seq INTEGER);
CREATE TABLE thrusters(id INTEGER PRIMARY KEY, doc_id INTEGER, gmt TEXT, unix REAL, fired INTEGER, total INTEGER, seq INTEGER);
CREATE TABLE orbits(id INTEGER PRIMARY KEY, event_id INTEGER, gmt TEXT, unix REAL, after TEXT, hp_nmi REAL, ha_nmi REAL);
CREATE TABLE mass_items(id INTEGER PRIMARY KEY, doc_id INTEGER, category TEXT, item INTEGER, description TEXT, weight_lb REAL, x_in REAL, y_in REAL, seq INTEGER);
CREATE TABLE mass_summary(id INTEGER PRIMARY KEY, doc_id INTEGER, description TEXT, weight_lb REAL, x_in REAL, y_in REAL, seq INTEGER);
CREATE TABLE discrepancies(id INTEGER PRIMARY KEY, topic TEXT, value_a TEXT, source_a TEXT, value_b TEXT, source_b TEXT, reading TEXT);
CREATE TABLE sim_impact(id INTEGER PRIMARY KEY, topic TEXT, datum TEXT, affects TEXT, action TEXT, status TEXT);
CREATE TABLE attitudes(id INTEGER PRIMARY KEY, gmt TEXT, unix REAL, attitude TEXT, dap TEXT, note TEXT, source TEXT);
CREATE TABLE sources(id INTEGER PRIMARY KEY, name TEXT, path TEXT, note TEXT);
CREATE VIEW v_timeline AS SELECT gmt, unix, kind, text, first_doc FROM events ORDER BY unix, id;
CREATE INDEX events_unix ON events(unix); CREATE INDEX prop_unix ON propellant(unix);
"""

# -------------------------------------------------------------------------------------------------- time parsing
GMT = re.compile(r"(?<![\d.])(?:2011\s*[:/]\s*)?(\d{3})\s*[/:]\s*(\d{1,2}):(\d{2})(?::(\d{2}(?:\.\d+)?))?(?![\d:])")
HEAD_PERIOD = re.compile(r"GMT:?\s*2011:(\d{3}):(\d{2}):(\d{2})\s*-\s*(?:2011:(\d{3}):(\d{2}):(\d{2})|(\d{3}):(\d{2}):(\d{2}))")


def unix(day, hh, mm, ss=0.0):
    return calendar.timegm((YEAR, 1, 1, 0, 0, 0)) + (int(day) - 1) * 86400 + int(hh) * 3600 + int(mm) * 60 + float(ss)


def fmt(day, hh, mm, ss=None):
    return "%03d/%02d:%02d%s" % (int(day), int(hh), int(mm), (":%s" % ss) if ss not in (None, "") else "")


CDT = re.compile(r"(?<![\d:])(\d{1,2}):(\d{2})\s*([AaPp])\.?[Mm]\.?\s*(?:CDT|CT)\b[,\s]*(?:\(?(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)[a-z]*,?\s*)?(?:May|Jun)\s*(\d{1,2})")


def cdt_stamps(text):
    """'9:20 PM CDT, May 30' -> GMT (CDT = GMT-5); day of year of May N is 120+N."""
    out = []
    for m in CDT.finditer(text):
        hh, mm, ap, dom = int(m.group(1)), int(m.group(2)), m.group(3).lower(), int(m.group(4))
        hh = hh % 12 + (12 if ap == "p" else 0)
        doy = (120 + dom) if "May" in m.group(0) else (151 + dom)
        t = unix(doy, hh, mm) + 5 * 3600
        d = int((t - unix(1, 0, 0)) // 86400) + 1
        out.append((fmt(d, int((t % 86400) // 3600), int((t % 3600) // 60)), t))
    return out


def stamps(text):
    """GMT stamps in text as (gmt string, unix).  Days 100-366 only: the MET stamps (12/15:45:17) have one or two digits."""
    out = []
    for m in GMT.finditer(text):
        d = int(m.group(1))
        if not 125 <= d <= 160:
            continue
        hh, mm = int(m.group(2)), int(m.group(3))
        if hh > 23 or mm > 59:
            continue
        ss = m.group(4)
        out.append((fmt(d, hh, mm, ss), unix(d, hh, mm, ss or 0)))
    out += cdt_stamps(text)
    return out


# -------------------------------------------------------------------------------------------------- reading
SECTION = re.compile(r"^(ATCS|ECLSS|Passive Thermal|S&MA|PASS SW|BFS SW|RMS|RMS/OBSS Operations:|OMS/RCS|WIS GFE|WLE|EPD&C|OBSS|"
                     r"C&T/S-Band, Ku-Band|FC/PRSD|GPS Nav|APU|HYD|DATA REVIEW|DPS HW|ORBIT/RENDEZVOUS|ORBIT|IMU|RPOP|ASCENT|Ascent|ODS|"
                     r"TPS/RCC|MEDS|MMU|Navaids|PV&D|Crew Equipment|D&C|Landing/Decel|Flight Controls|Mechanisms|Inst|Integrated GNC|"
                     r"VEHICLE STATUS AND ISS OPERATIONS|DEVELOPMENT TEST OBJECTIVES.*|OV-105/On-Orbit:|Pre-Launch)\s*:?\s*$")


def read_text(path):
    if path.suffix.lower() == ".pdf":
        return subprocess.run(["pdftotext", "-layout", str(path), "-"], capture_output=True, text=True).stdout
    return path.read_text(errors="replace")


def doc_kind(path):
    n = path.name
    if "Shift Report" in str(path.parent) or re.search(r"FD\d+_S\d", n):
        return "shift"
    if "Daily Report" in n:
        return "daily"
    if "Mass Properties" in n:
        return "mass"
    if "CSR" in n:
        return "csr"
    if "On-orbit" in n:
        return "onorbit"
    return "other"


def doc_fd_shift(name):
    m = re.search(r"FD0?(\d+)_S(\d)", name) or re.search(r"FD0?(\d+) Daily", name)
    if m:
        return int(m.group(1)), (int(m.group(2)) if m.lastindex and m.lastindex > 1 else None)
    return None, None


def period_of(text):
    for l in text.split("\n")[:12]:
        m = HEAD_PERIOD.search(l)
        if m:
            g = m.groups()
            d0, h0, m0 = g[0], g[1], g[2]
            if g[3]:
                d1, h1, m1 = g[3], g[4], g[5]
            else:
                d1, h1, m1 = g[6], g[7], g[8]
            return fmt(d0, h0, m0), fmt(d1, h1, m1), unix(d0, h0, m0), unix(d1, h1, m1)
    m = re.search(r"(\d{3})/(\d{2}):(\d{2})\s*GMT", "\n".join(text.split("\n")[:12]))
    if m:
        s = fmt(*m.groups())
        return s, s, unix(*m.groups()), unix(*m.groups())
    return None, None, None, None


def clean(s):
    return re.sub(r"\s+", " ", s).strip()


def noise(l):
    s = l.strip()
    return len(s) <= 3 and not s.isdigit()


# Shift reports whose header has no usable period; the periods are those of the neighbouring shifts (S2 starts at 16:00 GMT,
# S3 at the end of S2; the ascent report ends where FD01_S2 begins).  INFERRED, not read.
PERIOD_GUESS = {
    "STS-134 FD01_S1.pdf": ((136, 12, 0), (136, 15, 0)),
    "STS-134 FD02_S1.pdf": ((137, 8, 15), (137, 16, 0)),
    "STS-134 FD03_S1.pdf": ((138, 8, 15), (138, 16, 0)),
    "STS-134 FD06_S1.pdf": ((141, 8, 0), (141, 16, 0)),
    "STS-134 FD09_S1.pdf": ((144, 8, 0), (144, 16, 0)),
}

# -------------------------------------------------------------------------------------------------- build
def build(cache, dbpath):
    if dbpath.exists():
        dbpath.unlink()
    db = sqlite3.connect(dbpath)
    db.executescript(SCHEMA)
    files = sorted(p for p in cache.rglob("*") if p.is_file() and p.suffix.lower() in (".txt", ".pdf"))
    docs = []
    for p in files:
        text = read_text(p)
        fd, sh = doc_fd_shift(p.name)
        ps, pe, us, ue = period_of(text)
        if ps is None and p.name in PERIOD_GUESS:            # the header gives "16:yy" or none: the sibling shifts bound it
            a, b = PERIOD_GUESS[p.name]
            ps, pe, us, ue = fmt(*a), fmt(*b), unix(*a, 0), unix(*b, 0)
        cur = db.execute("INSERT INTO documents(path,name,kind,fd,shift,period_start,period_end,start_unix,end_unix) VALUES(?,?,?,?,?,?,?,?,?)",
                         (str(p), p.name, doc_kind(p), fd, sh, ps, pe, us, ue))
        did = cur.lastrowid
        lines, section = [], "HEADER"
        for i, l in enumerate(text.split("\n"), 1):
            s = l.rstrip()
            if SECTION.match(s.strip()):
                section = s.strip().rstrip(":")
            lines.append((did, i, section, s))
        db.executemany("INSERT INTO lines VALUES(?,?,?,?)", [x for x in lines if x[3].strip()])
        db.executemany("INSERT INTO lines_fts(text,section,doc_id,seq) VALUES(?,?,?,?)", [(x[3], x[2], x[0], x[1]) for x in lines if x[3].strip()])
        db.execute("UPDATE documents SET nlines=? WHERE id=?", (sum(1 for x in lines if x[3].strip()), did))
        docs.append(dict(id=did, path=p, kind=doc_kind(p), name=p.name, pe=ue, ps=us, lines=lines))
    events(db, docs)
    burns(db)
    propellant(db, docs)
    consumables(db, docs)
    thrusters(db, docs)
    mass(db, docs)
    curated(db)
    db.commit()
    return db


KINDS = [
    ("burn", r"\bTIG\b|burn|firing|OMS-\d|\bNC-?\d|\bNH\d?|\bNSR|\bTPI|\bSep ?\d|MAUI|RAMBO|reboost|translation"),
    ("dap", r"\bDAP\b|Free Drift|attitude|LVLH|\bTEA\b|maneuver"),
    ("jets", r"thrusters? .*(selected|fired)|Jets? (de)?selected|Jet .*Selected|drivers|Thruster Logic|window protect"),
    ("interconnect", r"Interconnect|OMS .*(He|Vap|Crossfeed)|Crossfeed"),
    ("dock", r"\bdock|ODS|hook|Guide Ring|undock|Ring "),
    ("rms", r"\bRMS\b|SRMS|OBSS|ELC|EVA|grapple|unberth|berth"),
    ("power", r"fuel cell|\bFC\b|APU|SSPTS|bus|heater|PRSD|cryo|\bO2\b|\bH2\b"),
    ("eclss", r"FES|dump|LiOH|water|waste|GN2|PPCO2|repress|supply"),
    ("nav", r"GPS|IMU|star|align|state vector|\bRPOP\b|TCS"),
    ("comm", r"Ku|S-Band|comm|MHA|HHM|TDRS"),
]


def kind_of(text):
    for k, rx in KINDS:
        if re.search(rx, text, re.I):
            return k
    return "other"


def units(lines):
    """Text units from a document's lines: numbered items run to the next number, other text to the next blank line or
    section heading; a unit with several stamps is then cut into sentence groups (a sentence with a stamp, plus the
    stamp-less sentences that follow it) so that one row is one event."""
    raw, cur, start, sec = [], [], None, None
    NUM = re.compile(r"^\s{0,8}(\d{1,2})\.\s+(\S.*)")

    def flush():
        nonlocal cur, start, sec
        if cur:
            raw.append((start, sec, clean(" ".join(cur))))
        cur, start, sec = [], None, None

    for did, seq, section, l in lines:
        if not l.strip():
            flush()
            continue
        if noise(l):
            continue
        if SECTION.match(l.strip()):
            flush()
            continue
        m = NUM.match(l)
        if m:
            flush()
            cur, start, sec = [m.group(2).strip()], seq, section
            continue
        if not cur:
            start, sec = seq, section
        cur.append(l.strip())
    flush()
    out = []
    for seq, sec, text in raw:
        text = text.replace("\uf044", "Δ")
        sents = re.split(r"(?<=[a-z0-9)]\.)\s+(?=[A-Z\[(])", text)
        groups, g = [], None
        for sn in sents:
            if not stamps(sn) and re.match(r"(The )?(MC|NC|Nominal|Midcourse|OMS|Out-of|Rendezvous)\b.*(maneuver|firing)", sn) and len(sn) < 200:
                g = [sn]                # a new maneuver's lead-in sentence starts its own group
                groups.append(g)
            elif stamps(sn) and g is not None and len(g) == 1 and not stamps(g[0]) and len(g[0]) < 200:
                g.append(sn)          # a short stamp-less lead-in ("SEP2 Ground targeted burn.") belongs to the sentence after it
            elif stamps(sn) or g is None:
                g = [sn]
                groups.append(g)
            elif len(g) < 4:
                g.append(sn)
        for g in groups:
            out.append((seq, sec, " ".join(g)))
    return out


def events(db, docs):
    seen = {}
    for d in docs:
        if d["kind"] == "mass":
            continue
        for seq, sec, text in units(d["lines"]):
            st = stamps(text)
            if not st:
                continue
            key = re.sub(r"[^a-z0-9]", "", text.lower())[:140]
            if key in seen:
                eid = seen[key]
                row = db.execute("SELECT docs FROM events WHERE id=?", (eid,)).fetchone()
                ds = json.loads(row[0])
                if d["id"] not in ds:
                    ds.append(d["id"])
                    db.execute("UPDATE events SET docs=? WHERE id=?", (json.dumps(ds), eid))
                continue
            cur = db.execute("INSERT INTO events(gmt,unix,kind,section,text,stamps,first_doc,first_seq,docs) VALUES(?,?,?,?,?,?,?,?,?)",
                             (st[0][0], st[0][1], kind_of(text), sec, text[:3000], json.dumps([s[0] for s in st]), d["id"], seq, json.dumps([d["id"]])))
            seen[key] = cur.lastrowid


NAMES = [
    (r"OMS Assist", "OMS Assist"), (r"OMS[- ]?2\b", "OMS-2"), (r"OMS[- ]?3\b", "OMS-3 (NC-1)"), (r"OMS[- ]?4\b", "OMS-4 (NC-2)"),
    (r"NC-?3\b", "NC-3"), (r"\(OMS\) ?6\b|OMS ?6\b", "OMS-6 (NC-4)"), (r"OMS ?7\b|Terminal Initiation", "OMS-7 (Ti)"),
    (r"\(MC\) ?1\b|MC ?1\b", "MC1"), (r"\(MC\) ?2\b|MC ?2\b", "MC2"), (r"\(MC\) ?4\b|MC ?4\b", "MC4"), (r"Rendezvous Pitch", "RPM"),
    (r"ET Sep ", "ET Sep"), (r"ET Photo \+X", "ET Photo +X"), (r"RCS window protect", "RCS window protect"),
    (r"Reboost TIG", "Reboost (VRCS)"), (r"Fly Around", "Fly-around start"), (r"Sep 1|SEP ?1", "SEP1"), (r"Sep 2|SEP ?2", "SEP2"),
    (r"NH2", "NH2"), (r"MC5", "MC5"), (r"MC6", "MC6"), (r"NSR", "NSR"), (r"TPI", "TPI"), (r"TDA", "TDA"), (r"Sep 3|SEP ?3", "SEP3"),
    (r"MAUI was initiated", "MAUI"), (r"ISS Sep was initiated", "Undock +Z pulse"), (r"deorbit maneuver", "Deorbit"),
]
XYZ = r"X\s*=\s*(-?[\d.]+)\s*,?\s*Y\s*=\s*(-?[\d.]+)\s*Y?\s*,?\s*Z\s*=\s*(-?[\d.]+)"


def burns(db):
    for col in ("lvlh_x", "lvlh_y", "lvlh_z", "res_x", "res_y", "res_z"):
        db.execute("ALTER TABLE burns ADD COLUMN %s REAL" % col)
    db.execute("ALTER TABLE burns ADD COLUMN met_tig TEXT")
    db.execute("ALTER TABLE burns ADD COLUMN targeted TEXT")
    rows = db.execute("SELECT id,gmt,unix,text FROM events WHERE kind IN ('burn','dap','jets','other','nav') ORDER BY unix,id").fetchall()
    for eid, gmt, u, text in rows:
        head = text[:90]
        for rx, name in NAMES:
            if not re.search(rx, head):
                continue
            if re.search(r"Totalizer|Iso |Interconnect|heater|Pod|dropped|GN2|Repress", head):
                continue
            tig = re.search(r"(?:TIG(?: of| was| occurred at)?|initiated at|initiated with[^.]*? at|was performed at|performed on orbit \d+ at|occurring at(?: TIG of)?|[Ii]gnition (?:occurred )?at|began at|Reboost TIG was|would have occurred at)\s*(\d{3}[/:]\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?)", text)
            st = stamps(text)
            if not tig and not st:
                continue
            tst = stamps(tig.group(1)) if tig else []
            tg, tu = tst[0] if tst else st[0]
            cut = re.search(r"cut-?off (?:at|was at)?\s*(\d{3}[/:]\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?)", text)
            cst = stamps(cut.group(1)) if cut else []
            dur = re.search(r"(?:burn time|firing time|firing duration|duration of the maneuver|duration)\s*(?:was|of)?\s*([\d.]+) ?s|([\d.]+)[- ]seconds?\b|([\d.]+) sec\b", text)
            dv = re.search(r"(?:[dD]elta[_ -]?[vV]\w*|[Dd]ifferential [Vv]elocity|[∆Δ]\s?V|\bV)\s*(?:\([^)]*\))?\s*(?:of|was|delivered was)?\s*([\d.]+)\s*(?:ft|fps|f/s)", text)
            orb = re.search(r"resulting orbit was ([\d.]+)\s*(?:x|by)\s*([\d.]+)|into a ([\d.]+) by ([\d.]+) nmi", text)
            jets = re.findall(r"\b([FLR][1-5][ULRDFA])\b", text)
            eng = "dual OMS" if re.search(r"Dual OMS|two-engine|dual engine", text, re.I) else ("left OMS" if re.search(r"left engine", text, re.I) else ("right OMS" if re.search(r"Right engine", text, re.I) else None))
            d = next((float(g) for g in (dur.groups() if dur else ()) if g), None)
            lv = re.search(r"LVLH " + XYZ, text)
            rs = re.search(r"residuals were " + XYZ, text)
            met = re.search(r"\(?(\d{1,2}/\d{2}:\d{2}:\d{2})\s*(?:\(?MET|Mission)", text)
            targ = "ground" if "Ground targeted" in text else ("onboard" if "Onboard targeted" in text else None)
            lvv = tuple(float(x) for x in lv.groups()) if lv else (None, None, None)
            rsv = tuple(float(x) for x in rs.groups()) if rs else (None, None, None)
            hp = ha = None
            if orb:
                g = [x for x in orb.groups() if x]
                hp, ha = float(g[0]), float(g[1])
            db.execute("INSERT INTO burns(name,tig,tig_unix,cutoff,cutoff_unix,duration_s,dv_fps,orbit_hp_nmi,orbit_ha_nmi,jets,engines,event_id,"
                       "lvlh_x,lvlh_y,lvlh_z,res_x,res_y,res_z,met_tig,targeted) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                       (name, tg, tu, cst[0][0] if cst else None, cst[0][1] if cst else None, d, float(dv.group(1)) if dv else None, hp, ha,
                        " ".join(sorted(set(jets), key=jets.index)) or None, eng, eid,
                        *lvv, *rsv, met.group(1) if met else None, targ))
            if orb:
                db.execute("INSERT INTO orbits(event_id,gmt,unix,after,hp_nmi,ha_nmi) VALUES(?,?,?,?,?,?)", (eid, gmt, u, name, hp, ha))
            break


def propellant(db, docs):
    PFS = re.compile(r"PFS\s*%\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)")
    USE = re.compile(r"Usage\s+([\d.]+)\s+([\d.]+)")
    for d in docs:
        L = d["lines"]
        for i, (did, seq, sec, l) in enumerate(L):
            m = PFS.search(l)
            if not m:
                continue
            ic = None
            for j in range(i, min(i + 12, len(L))):
                u = USE.search(L[j][3])
                if u:
                    ic = (float(u.group(1)), float(u.group(2)))
                    break
            gm, isrep = None, 0
            for j in range(max(0, i - 12), i + 1):
                mm = re.search(r"GMT:\s*(\d{3})/(\d{2}):(\d{2})", L[j][3]) or re.search(r"GMT:\s*2011:(\d{3}):(\d{2}):(\d{2})", L[j][3]) if "OMS/RCS" in L[j][3] or "GMT:" in L[j][3] else None
                if mm and "Consolidated" not in L[j][3] and " - " not in L[j][3]:
                    gm = (fmt(*mm.groups()), unix(*mm.groups()))
                    isrep = 1
            if gm is None:
                gm = (None, d["pe"])
                if d["pe"]:
                    t = d["pe"] - unix(1, 0, 0)
                    gm = (fmt(t // 86400 + 1, (t % 86400) // 3600, (t % 3600) // 60), d["pe"])
            v = [float(x) for x in m.groups()]
            db.execute("INSERT INTO propellant(doc_id,gmt,unix,gmt_is_report,left_ox,left_fu,right_ox,right_fu,fwd_ox,fwd_fu,ic_left,ic_right,seq) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",
                       (d["id"], gm[0], gm[1], isrep, *v, ic[0] if ic else None, ic[1] if ic else None, seq))


CONS = [("GN2", r"Total GN2 Qty:\s*([\d.]+)\s*lb", "lbm"), ("waste_tank_pct", r"Waste Tank Qty:\s*([\d.]+)\s*%", "%"),
        ("waste_tank", r"Waste Tank Qty:\s*[\d.]+\s*%\s*([\d.]+)\s*lb", "lbm"), ("supply_h2o", r"Total Supply H2O Qty:\s*([\d.]+)", "lbm"),
        ("ppco2", r"(?:PPCO2|ppCO2)[^0-9]{0,20}([\d.]+)\s*mm", "mmHg"), ("fes_dump", r"FES Dump (?:Init|term)[^\n]*?\(~?([\d.]+)\s*lbm\)", "lbm")]


def consumables(db, docs):
    for d in docs:
        for did, seq, sec, l in d["lines"]:
            for q, rx, unit in CONS:
                m = re.search(rx, l)
                if m:
                    st = stamps(l)
                    t = (st[0] if st else (None, d["pe"]))
                    db.execute("INSERT INTO consumables(doc_id,gmt,unix,quantity,value,unit,text,seq) VALUES(?,?,?,?,?,?,?,?)",
                               (d["id"], t[0], t[1], q, float(m.group(1)), unit, clean(l), seq))


def thrusters(db, docs):
    for d in docs:
        for did, seq, sec, l in d["lines"]:
            m = re.search(r"(\d+) of (\d+) primary thrusters", l)
            if m:
                db.execute("INSERT INTO thrusters(doc_id,gmt,unix,fired,total,seq) VALUES(?,?,?,?,?,?)", (d["id"], None, d["pe"], int(m.group(1)), int(m.group(2)), seq))


def mass(db, docs):
    for d in docs:
        if d["kind"] != "mass":
            continue
        cat = None
        for did, seq, sec, l in d["lines"]:
            s = l.rstrip()
            m = re.match(r"\s*EXTRANEOUS ITEMS - ([A-Z ,]+?)(?: \(Subtotal\))?\s+(\d+)\s+([\d.]+)\s+(-?[\d.]+)\s*$", s)
            if m:
                cat = m.group(1).strip()
                db.execute("INSERT INTO mass_summary(doc_id,description,weight_lb,x_in,y_in,seq) VALUES(?,?,?,?,?,?)", (d["id"], "EXTRANEOUS " + cat + " (subtotal)", float(m.group(2)), float(m.group(3)), float(m.group(4)), seq))
                continue
            m = re.match(r"\s*(FLIGHT SHORTAGE ITEMS|STS FLIGHT UNIQUE \(INERT\)) \(Subtotal\)\s+(\d+)\s+([\d.]+)\s+(-?[\d.]+)\s*$", s)
            if m:
                cat = m.group(1)
                db.execute("INSERT INTO mass_summary(doc_id,description,weight_lb,x_in,y_in,seq) VALUES(?,?,?,?,?,?)", (d["id"], cat + " (subtotal)", float(m.group(2)), float(m.group(3)), float(m.group(4)), seq))
                continue
            m = re.match(r"\s*(\d{1,2})\s+(.*?)\s{2,}(?:[A-Z0-9][A-Z0-9/\-]+\s+)?(\d+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s*$", s)
            if m and cat:
                db.execute("INSERT INTO mass_items(doc_id,category,item,description,weight_lb,x_in,y_in,seq) VALUES(?,?,?,?,?,?,?,?)",
                           (d["id"], cat, int(m.group(1)), clean(m.group(2)), float(m.group(3)), float(m.group(4)), float(m.group(5)), seq))
                continue
            m = re.match(r"\s*([A-Z][A-Za-z0-9 \-\(\)/\.,'&]+?)\s{2,}(-?\s?\d{3,6})\s+(-?[\d.]+)\s+(-?[\d.]+)\s*$", s)
            if m and any(k in s for k in ("TOTAL", "INERT", "ACTUAL", "AVERAGE", "PREDICTED", "LESS", "PLUS", "NOSE", "MAIN", "Remove", "Add", "ADD", "SUBTRACT", "a.)", "b.)", "c.)", "d.)")):
                db.execute("INSERT INTO mass_summary(doc_id,description,weight_lb,x_in,y_in,seq) VALUES(?,?,?,?,?,?)",
                           (d["id"], clean(m.group(1)), float(m.group(2).replace(" ", "")), float(m.group(3)), float(m.group(4)), seq))



# -------------------------------------------------------------------------------------------------- curated
# These rows are READINGS, not extractions: where two documents (or a document and the clock arithmetic) disagree, the
# disagreement and what the simulation uses.  Mission Report JSC-37461 beats the shift reports (user, 2026-10-13).
LAUNCH = unix(136, 12, 56, 27.994)          # liftoff, the Ascent-plus-2-hour report; GNC says 27.958, the OMS/RCS list 12:56:28

DISCREPANCIES = [
    ("Payload bay doors closed", "153/02:48:23 (MET 15/13:54:16)", "FD16 daily, Mission Report text", "152/02:48:24 left, 02:49:45 right", "Mission Report event table",
     "day typo: MET 15/13:54:16 is 152/02:50 GMT; use 152/02:48:24 and 02:49:45"),
    ("Drag chute jettison", "153/06:35:19", "FD16 daily, Mission Report text", "152/06:35:18.7", "Mission Report event table", "day typo; 152/06:35:18.7"),
    ("Initial contact with the ISS", "138/1:13:52 (MET 01/21:17:24)", "FD3 daily", "138/10:13:51", "Mission Report 'Docking' RCS table", "hour typo; 10:13:52 matches MET 01/21:17:24 and the hook drive at 10:22:52"),
    ("OMS-7 (Ti) MET", "01/12:41:35", "FD3 daily", "01/18:41:45", "computed from liftoff 136/12:56:27.994", "hour typo in the MET; the GMT 138/07:38:13 is right"),
    ("Reboost altitude gain", "1.0 nmi", "FD13_S3 shift report ORBIT item 3", "0.6 nmi", "FD14 daily report", "both give 2.0 fps; the daily (and the Mission Report FD14 text) say 0.6"),
    ("Reboost TIG", "149/05:03:29, cutoff 05:17:29 (burn 14 min)", "FD13_S3 ORBIT", "149/05:03:27", "FD13_S3 Integrated GNC, FD14 daily", "29 s is the first jet fired (RCS table 05:03:29-05:17:30); 27 s is the DAP's start"),
    ("Burn start times, FD15", "SEP1 05:06:01, SEP2 05:34:04, NH2 06:39:38, MC5 06:59:07, NSR 07:24:07, TPI 07:57:35, SEP3 08:38:35", "FD14_S3 Integrated GNC (TIG)",
     "05:06:02, 05:34:06, 06:39:38, 06:59:08, 07:24:08, 07:57:34, 08:38:36", "ORBIT list / Mission Report (first jet)", "GNC gives the programmed TIG, the list the first jet fired; 0-2 s apart"),
    ("Liftoff", "136/12:56:27.958", "FD1_S1 Integrated GNC (IMU)", "136/12:56:27.994 (daily), 12:56:28 (OMS/RCS list)", "FD1 daily, FD1_S1", "use .994 (Mission Report)"),
    ("RCS thruster logic ON", "039/06:26", "FD1_S1 OMS/RCS pre-launch", "136/06:26", "OMS engine valve power line above it", "day typo"),
    ("Undock time", "150/03:55:22 (+Z pulse L2U R2U)", "ORBIT list", "150/03:55:11 (undock occurred)", "FD14_S3 Integrated GNC", "pulse at :22, hooks fully open :15, separation sensed about :11 in the ISS's frame; Missions Summary says :12"),
    ("RAMBO-2 firing", "three 10-second +X firings, L1A and R1A", "Mission Report FD16 text", "firing time 10.6 s", "Mission Report p.43 RCS table (firing time column)", "unresolved: 30 s of two jets is 7.9 ft/s, 10.6 s is 0.9 ft/s; the sim fires three equal pulses totalling 10.6 s"),
    ("MC5 and NSR labels", "06:59:08 NSR 1.6 s, 07:24:08 MC5 9.12 s", "Mission Report p.43 table", "06:59:08 MC5 1.6 s, 07:24:08 NSR 9.12 s", "Mission Report text, FD14_S3, Rendezvous book", "table labels swapped"),
    ("OMS interconnect usage", "left 0.161 %, right 1.605 % (-> 2.057 % at 150/10:25)", "shift reports", "267.56 lb left, 333.87 lb right (mission)", "Mission Report p.44", "percent of the OMS tank; the right changes at the 150/10:25:00 interconnect"),
    ("OMS-6 designations", "OMS-6 = NC4 (left engine, 138/06:07:27.4, 10.6 s, 8.2 fps)", "FD3 daily", "OMS-5 (NC4)", "Mission Report p.44", "the report numbers differently; same burn"),
    ("OMS-7 (Ti) engines", "two-engine straight-fed", "FD3 daily", "Left Engine", "Mission Report p.44", "the daily says two engines for 10.8 s / 8.6 fps; the report says left, 8.2 fps; unresolved"),
]

SIM_IMPACT = [
    ("propellant", "PFS % series: forward 37.0/36.0 (149/16:00) -> 16.8/14.6 (150/09:00); aft 76.8/77.2 -> 64.8/65.0 (L), 75.4/76.4 -> 62.8/63.8 (R)", "undock start load; per-leg usage",
     "forward start 733 lb (undock_start.py ef20833e5); the flown forward use undock->09:00 is about 430 lb, the simulation's ~390", "done"),
    ("coast", "events 150/09:10 to 152/02:49 (DAP LVLH, water dumps, interconnect, MAUI, FRCS drivers off, FCS C/O, hot-fire, RAMBO, FES/waste dumps, Ku stow, PLBD close)", "fly_return.py COAST phase",
     "fly the coast from the SEP3 capture; schedule these events; no physics skip", "in progress"),
    ("deorbit", "orbit 248 opportunity: TIG 152/05:29:03.1, 159.2 s dual OMS, 296.9 ft/s (text 158.3 s / 298.4), 23.2 x 188.5 nmi, EI 06:03:06 = TIG+34:03", "deorbit_target.py --near-gmt --tff; fly_return DEORBIT",
     "target the flown opportunity from the simulated state; TFF 34.05 min; compare TIG, EI, burn length and post-burn orbit with the record", "in progress"),
    ("entry", "TAEM (MM305) 152/06:28:21; main gear 06:34:50; chute 06:34:52.9; nose 06:35:00; chute jettison 06:35:18.7; wheels stop 06:35:33; EI to touchdown 31:44", "acceptance values for ENTRY/LAND",
     "report the simulated times beside these", "in progress"),
    ("frcs_dump", "forward RCS dump 152/05:45:06.7, 11.04 s (Mission Report p.43)", "fly_return after OPS 303", "not in fly_sts134; add when the dump's keystrokes are known", "open"),
    ("mass", "inert OV-105 178,280 lb at X 1113.1 in (SE11HOU028); landing weight 204,463 lb (Missions Summary A-9)", "dry mass and the keyed WT",
     "the sim's dry mass should be checked against the inert weight plus the mission kits", "open"),
    ("rendezvous_fd1_3", "burn table FD1-3 (OMS assist, OMS-2/3/4/6/7, NC3, MC1/2/4, RPM) with TIGs, durations, delta-V and resulting orbits", "Codex FD1-3 flight (fly_fd13.py)",
     "acceptance values for each stage's burn; sts134-mission.db burns table", "sent to Codex"),
    ("consumables", "GN2, waste tank, supply water per shift; FES dumps; supply dump 148.04 lb, waste dump 115.8 lb at 150/09:32-10:38", "orbiter mass over the coast", "mass changes of about 0.3 % over the coast; the keyed WT is the PAD's", "noted"),
]


# Attitudes and DAP states the documents give.  GMT is the time the document says the state began.
ATTITUDES = [
    ((149, 4, 41, 44), "attitude control handover to the Orbiter", None, "ISS CMG control -> Orbiter DAP for the reboost", "FD13_S3 ORBIT 1"),
    ((149, 4, 47, 32), "14 deg maneuver from the mated TEA to the reboost attitude", None, "starts 04:47:28 in the GNC paragraph", "FD13_S3 ORBIT 2"),
    ((149, 5, 3, 29), "reboost attitude, configuration 3 (VRCS) burn 14 min", "VRCS", "F5L 713.32 s (7 pulses), F5R 782.16 s (5), L5D 414.76 s (3), R5D 414.4 s (3), R5R 34.8 s (1), L5L 0", "FD13_S3 ORBIT 3"),
    ((149, 5, 23, 53), "15 deg maneuver back to the mated TEA", None, "complete 06:07:27; max attitude error excursion in the reboost 0.14 deg in pitch", "FD13_S3 ORBIT 4, GNC"),
    ((149, 5, 54, 19), "DAP B13 for the direct deadband collapse, FREE at 06:07:27", "B13", "ISS CMG momentum peaked about 74 % after handoff", "FD13_S3 Integrated GNC"),
    ((150, 2, 35, 28), "Orbiter takes control; DAP to Auto for the maneuver to the undock attitude", "Auto", "start of undock preparation", "FD14_S3 ORBIT 1"),
    ((150, 2, 46, 28), "maneuver to the undock attitude begins (complete 03:18:31)", "Auto", "the MR also dates the table 02:35:28", "FD14_S3 Integrated GNC"),
    ((150, 3, 20, 21), "DAP B12 (hold) selected", "B12", None, "FD14_S3 Integrated GNC"),
    ((150, 3, 35, 30), "DAP Free Drift (logic configuration)", "Free", None, "FD14_S3 ORBIT 3"),
    ((150, 3, 38, 49), "DAP Auto", "Auto", None, "FD14_S3 ORBIT 5"),
    ((150, 3, 52, 28), "DAP Free Drift (driver configuration), undock - 3 min", "Free", None, "FD14_S3 ORBIT 7"),
    ((150, 3, 53, 0), "DAP B/ALT/No Low Z", "B/ALT/NoLowZ", "primary drivers on 03:52:41", "FD14_S3 ORBIT 9"),
    ((150, 3, 55, 22), "undock: +Z pulse L2U R2U", "B/ALT/NoLowZ", "ISS attitude errors at separation -0.14, -0.81, +0.78 deg; 4 DAP B +pitch firings to stop the initial pitch rate", "FD14_S3 ORBIT 10, ODS text"),
    ((150, 4, 2, 4), "DAP A/Low Z", "A/LowZ", None, "FD14_S3 ORBIT 12"),
    ((150, 5, 34, 6), "burns in DAP A/Auto/Pri", "A/AUTO/PRI", "'DAP used for all burns was A/Auto/Pri'", "FD14_S3 Integrated GNC"),
    ((150, 9, 10, 19), "DAP to LVLH for the conclusion of the STORRM DTO", "LVLH", "ExPkg ORB ATT -ZLV +YVV (water dump)", "FD15_S1 ORBIT 23; FD15 Execute Package"),
    ((150, 11, 43, 18), "MAUI: MNVR (TRK) -ZLV -XVV, TG=2 BV=3 OM=0", "A1/AUTO/VERN", "MAUI TIG planned MET 13/22:46:38; flown 22:46:50 (150/11:43:18)", "FD15 Execute Package"),
    ((151, 8, 15, 0), "top Earth, tail on the velocity vector; solar beta +15.5 deg", None, "passive thermal paragraph of FD16_S1", "FD16_S1 Passive Thermal"),
]


def curated(db):
    for (d, h, m, sec), att, dap, note, src in ATTITUDES:
        db.execute("INSERT INTO attitudes(gmt,unix,attitude,dap,note,source) VALUES(?,?,?,?,?,?)", (fmt(d, h, m, sec), unix(d, h, m, sec), att, dap, note, src))
    for r in DISCREPANCIES:
        db.execute("INSERT INTO discrepancies(topic,value_a,source_a,value_b,source_b,reading) VALUES(?,?,?,?,?,?)", r)
    for r in SIM_IMPACT:
        db.execute("INSERT INTO sim_impact(topic,datum,affects,action,status) VALUES(?,?,?,?,?)", r)
    for n, note in (("Cooper Shift cache", "the 48 files; shift reports FD01_S1..FD16_S2, daily reports, CSR, on-orbit 5/17, landing report, Actual Mass Properties"),
                    ("JSC-37461 STS-134 Mission Report", "outranks the shift reports; not loaded into this database"),
                    ("Missions Summary NASA 20110001406", "secondary; landing weight A-9")):
        db.execute("INSERT INTO sources(name,path,note) VALUES(?,?,?)", (n, str(CACHE), note))

# -------------------------------------------------------------------------------------------------- queries
def parse_when(s):
    st = stamps(s if s.count("/") else s)
    if st:
        return st[0][1]
    m = re.match(r"(\d{3})/(\d{2}):?(\d{2})?", s)
    return unix(m.group(1), m.group(2), m.group(3) or 0)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["build", "timeline", "search", "prop"])
    ap.add_argument("args", nargs="*")
    ap.add_argument("--cache", default=str(CACHE))
    ap.add_argument("--db", default=str(DB))
    a = ap.parse_args()
    if a.cmd == "build":
        db = build(Path(a.cache), Path(a.db))
        for t in ("documents", "lines", "events", "burns", "propellant", "consumables", "thrusters", "orbits", "mass_items", "mass_summary"):
            print("%-12s %6d" % (t, db.execute("SELECT count(*) FROM %s" % t).fetchone()[0]))
        return
    db = sqlite3.connect(a.db)
    if a.cmd == "timeline":
        lo = parse_when(a.args[0]) if a.args else 0
        hi = parse_when(a.args[1]) if len(a.args) > 1 else 1e12
        for g, k, t in db.execute("SELECT gmt,kind,text FROM events WHERE unix BETWEEN ? AND ? ORDER BY unix,id", (lo, hi)):
            print("%-14s %-12s %s" % (g, k, t[:230]))
    elif a.cmd == "search":
        for did, seq, sec, t in db.execute("SELECT doc_id,seq,section,text FROM lines_fts WHERE lines_fts MATCH ? LIMIT 80", (" ".join(a.args),)):
            print("%s:%s [%s] %s" % (db.execute("SELECT name FROM documents WHERE id=?", (did,)).fetchone()[0], seq, sec, clean(t)[:200]))
    elif a.cmd == "prop":
        print("%-10s %6s %6s %6s %6s %6s %6s  IC L/R   doc" % ("gmt", "L ox", "L fu", "R ox", "R fu", "F ox", "F fu"))
        for r in db.execute("SELECT p.gmt,left_ox,left_fu,right_ox,right_fu,fwd_ox,fwd_fu,ic_left,ic_right,d.name FROM propellant p JOIN documents d ON d.id=p.doc_id ORDER BY p.unix"):
            print("%-10s %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f  %s/%s  %s" % r)


if __name__ == "__main__":
    main()
