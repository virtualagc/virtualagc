#!/usr/bin/env python3
"""gpc-phases.py -- where each STS-134 flight phase stands, per platform, and the runs behind it.

WHY: gpc-causes.py records causes and fixes, not whether a phase NOW PASSES.  Answering "does deorbit/entry/landing
pass, and on which platforms" meant reassembling it from a dozen ledger entries and a narrative document that lags
(it is only synced on request), and it was answered wrongly from the stale one.  This is the one place that says it.

TABLES (gpc-phases.db; PHASES.md is GENERATED from them -- edit with this script, never by hand):
  status   one CURRENT row per (phase, platform): verdict, the run, the build, the numbers, and the evidence (ledger
           ids, files).  `set` replaces the row and moves the old one to history.
  history  every row `set` has replaced, with when.
  runs     the inventory of runs found on disk (landing runs and pre-ISS runs), taken from the logs by `scan`:
           date, name, numbers, and an ERA that says whether the numbers can be believed (see ERA RULES).

VERDICTS: PASS  FAIL  PENDING (running or promised)  UNVERIFIED (passed once, build or capture since changed, not
re-run)  NOT-RUN  UNRECORDED (a run may exist; nobody wrote the result down).

ERA RULES (landing runs; assigned by `scan` from the run's name and date, NOT from knowing what each run was for):
  stale-gps   deorbit*, rootcause/*, undock/deorb*, flown*, before 2026-11-02: PASS navigated on a stale GPS fix
              (ledger #319), so touchdown speed and sink of these runs say nothing about the aerodynamics.
  probe       fd13x runs of 2026-11-02 before the fix was verified: aero, gear-drag and GPS experiments (#316-#319).
              Purpose of each is not recorded; low speeds here (155-190 kt) were an experiment's side effect.
  fixed       only the runs the ledger names as GPS-live: E5, E6, E6src, X3src, S125a/b (#316, #320).
  rtls        rtls33*: ascent-abort landings, a different phase.

USAGE
  gpc-phases.py list [--phase=P] [--platform=X]        current status rows
  gpc-phases.py show PHASE PLATFORM                    one row, its history
  gpc-phases.py set PHASE PLATFORM VERDICT --run=R --build=B --numbers=N --evidence=E [--note=N]
  gpc-phases.py runs [--kind=landing|preiss] [--era=E] runs found by `scan`
  gpc-phases.py scan                                   re-read ~/sts134-runs and rebuild `runs`
  gpc-phases.py docs                                   regenerate PHASES.md
  gpc-phases.py check                                  exit 1 if PHASES.md is out of date
"""
import json, os, re, sqlite3, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
DB = HERE / "gpc-phases.db"
MD = HERE / "PHASES.md"
RUNS = Path.home() / "sts134-runs"
VERDICTS = ("PASS", "FAIL", "PENDING", "UNVERIFIED", "NOT-RUN", "UNRECORDED")
PLATFORMS = ("Linux", "Mac", "Win11", "WSL")

SCHEMA = """
CREATE TABLE IF NOT EXISTS status(phase TEXT, platform TEXT, verdict TEXT, run TEXT, build TEXT, numbers TEXT,
    evidence TEXT, note TEXT, updated TEXT, PRIMARY KEY(phase, platform));
CREATE TABLE IF NOT EXISTS history(phase TEXT, platform TEXT, verdict TEXT, run TEXT, build TEXT, numbers TEXT,
    evidence TEXT, note TEXT, updated TEXT, replaced TEXT);
CREATE TABLE IF NOT EXISTS runs(kind TEXT, name TEXT, path TEXT, mtime REAL, era TEXT, td_kt REAL, sink_fps REAL,
    gearup INTEGER, wheels_stop INTEGER, pre_trim TEXT, final TEXT, status TEXT);
"""


def conn():
    c = sqlite3.connect(DB)
    c.executescript(SCHEMA)
    return c


def now():
    return time.strftime("%Y-%m-%d %H:%M")


def arg(args, key, default=""):
    for a in args:
        if a.startswith("--" + key + "="):
            return a.split("=", 1)[1]
    return default


# ---------------------------------------------------------------- scan
TD = re.compile(r"LEFT MAIN gear TOUCHDOWN at t=([\d.]+): ground speed ([\d.]+) kt, sink (-?[\d.]+) ft/s")
FOUND = {"E5", "E6", "E6src", "X3src", "S125a", "S125b"}   # the runs ledger #316 and #320 name as GPS-live


def landing_era(name, mtime):
    if name.startswith("rtls33"):
        return "rtls"
    day = time.strftime("%Y-%m-%d", time.localtime(mtime))
    if name.startswith("fd13x/"):
        return "fixed" if name.split("/")[1] in FOUND else "probe"
    if day < "2026-11-02":
        return "stale-gps"
    return "probe"


def scan():
    c = conn()
    c.execute("DELETE FROM runs")
    seen = set()
    for dp, dn, fn in os.walk(RUNS):
        depth = dp[len(str(RUNS)):].count("/")
        if depth > 3:
            dn[:] = []
            continue
        for f in fn:
            p = Path(dp) / f
            rel = str(p.relative_to(RUNS))
            if f.endswith(".out") or f in ("driver.out", "yaGPC2.log"):
                try:
                    t = p.read_text(errors="replace")
                except OSError:
                    continue
                m = TD.search(t)
                gu = "WITHOUT THE GEAR" in t
                if not m and not gu:
                    continue
                key = re.sub(r"/logs/yaGPC2\.log|/driver\.out|\.out$", "", rel)
                if key in seen:
                    continue
                seen.add(key)
                mt = p.stat().st_mtime
                c.execute("INSERT INTO runs VALUES('landing',?,?,?,?,?,?,?,?,?,?,?)",
                          (key, rel, mt, landing_era(key, mt), float(m.group(2)) if m else None,
                           float(m.group(3)) if m else None, int(gu), int("WHEELS STOP" in t), None, None, None))
            elif f == "RESULT.json" and "fd13x" in dp:
                try:
                    d = json.load(open(p))
                except Exception:
                    continue
                fin = d.get("final") or {}
                a, b = fin.get("acceptance"), fin.get("acceptance_before_trim")
                if not a:
                    continue
                fmt = lambda x: "%.0f ft / %.2f ft/s%s" % (x["position_error_ft"], x["velocity_error_fts"],
                                                         "" if x.get("accepted") else " (fails)")
                c.execute("INSERT INTO runs VALUES('preiss',?,?,?,?,?,?,?,?,?,?,?)",
                          (os.path.relpath(dp, RUNS), os.path.relpath(p, RUNS), p.stat().st_mtime, "", None, None,
                           0, 0, fmt(b) if b else "", fmt(a), d.get("status")))
    c.commit()
    n = c.execute("SELECT kind, count(*) FROM runs GROUP BY kind").fetchall()
    print("scanned:", dict(n))


# ---------------------------------------------------------------- docs
def render(c):
    o = ["# STS-134 phase status", "",
         "GENERATED by `gpc-phases.py docs` from `gpc-phases.db`.  Do not edit by hand; use `gpc-phases.py set`.",
         "Read this BEFORE spending a run: it says what already passes, on which build, and where the proof is.",
         "A phase marked UNVERIFIED passed once and has not been re-run since the build or capture changed.", ""]
    phases = [r[0] for r in c.execute("SELECT phase FROM status GROUP BY phase ORDER BY min(rowid)")]
    for ph in phases:
        o += ["## " + ph, "", "| Platform | Verdict | Run | Build | Numbers | Evidence | Note |", "|---|---|---|---|---|---|---|"]
        for r in c.execute("SELECT platform,verdict,run,build,numbers,evidence,note FROM status WHERE phase=? "
                           "ORDER BY rowid", (ph,)):
            o.append("| " + " | ".join((x or "").replace("|", "/").replace("\n", " ") for x in r) + " |")
        o.append("")
    o += ["## Landing runs on disk (from the logs)", "",
          "Eras: **stale-gps** = PASS navigated on a stale GPS fix (#319), speeds say nothing about the aerodynamics; "
          "**probe** = 2026-11-02 experiments, purpose not recorded; **fixed** = GPS live (#320); **rtls** = a different phase.  "
          "Flown: 195.3 kt, 1.2 ft/s, 3,186 ft past the threshold.", "",
          "| Era | Count | Touchdown kt (min-max) | Gear-up |", "|---|---|---|---|"]
    for era, n, lo, hi, gu in c.execute("SELECT era,count(*),min(td_kt),max(td_kt),sum(gearup) FROM runs "
                                        "WHERE kind='landing' GROUP BY era ORDER BY min(mtime)"):
        o.append("| %s | %d | %s | %d |" % (era, n, "-" if lo is None else "%.0f-%.0f" % (lo, hi), gu))
    o += ["", "Per run: `gpc-phases.py runs --kind=landing --era=fixed`.", ""]
    return "\n".join(o)


def docs():
    c = conn()
    MD.write_text(render(c))
    print("wrote", MD)


def check():
    c = conn()
    if not MD.exists() or MD.read_text() != render(c):
        print("PHASES.md is out of date; run gpc-phases.py docs")
        sys.exit(1)
    print("ok")


# ---------------------------------------------------------------- commands
def cmd_list(args):
    c = conn()
    q, a = "SELECT phase,platform,verdict,run,numbers FROM status WHERE 1=1", []
    for k in ("phase", "platform"):
        if arg(args, k):
            q += " AND %s=?" % k
            a.append(arg(args, k))
    for r in c.execute(q + " ORDER BY rowid", a):
        print("%-34s %-6s %-10s %-12s %s" % (r[0][:34], r[1], r[2], (r[3] or "")[:12], (r[4] or "")[:80]))


def cmd_show(args):
    c = conn()
    r = c.execute("SELECT * FROM status WHERE phase=? AND platform=?", (args[0], args[1])).fetchone()
    cols = [d[0] for d in c.execute("SELECT * FROM status").description]
    if not r:
        print("no such row")
        return
    for k, v in zip(cols, r):
        print("%-9s %s" % (k, v))
    for h in c.execute("SELECT verdict,run,numbers,updated,replaced FROM history WHERE phase=? AND platform=? "
                       "ORDER BY replaced", (args[0], args[1])):
        print("  was:", h)


def cmd_set(args):
    pos = [a for a in args if not a.startswith("--")]
    if len(pos) != 3 or pos[2] not in VERDICTS or pos[1] not in PLATFORMS:
        sys.exit("usage: set PHASE PLATFORM VERDICT(%s) --run= --build= --numbers= --evidence= [--note=]\nplatforms: %s"
                 % ("|".join(VERDICTS), ", ".join(PLATFORMS)))
    c = conn()
    old = c.execute("SELECT * FROM status WHERE phase=? AND platform=?", (pos[0], pos[1])).fetchone()
    if old:
        c.execute("INSERT INTO history VALUES(?,?,?,?,?,?,?,?,?,?)", old + (now(),))
        c.execute("DELETE FROM status WHERE phase=? AND platform=?", (pos[0], pos[1]))
    c.execute("INSERT INTO status VALUES(?,?,?,?,?,?,?,?,?)",
              (pos[0], pos[1], pos[2], arg(args, "run"), arg(args, "build"), arg(args, "numbers"),
               arg(args, "evidence"), arg(args, "note"), now()))
    c.commit()
    docs()


def cmd_runs(args):
    c = conn()
    q, a = "SELECT kind,name,mtime,era,td_kt,sink_fps,gearup,wheels_stop,pre_trim,final,status FROM runs WHERE 1=1", []
    if arg(args, "kind"):
        q += " AND kind=?"
        a.append(arg(args, "kind"))
    if arg(args, "era"):
        q += " AND era=?"
        a.append(arg(args, "era"))
    for r in c.execute(q + " ORDER BY mtime", a):
        when = time.strftime("%m-%d %H:%M", time.localtime(r[2]))
        if r[0] == "landing":
            print("%s %-28s %-9s %s %s%s" % (when, r[1][:28], r[3],
                  "-" if r[4] is None else "%.1f kt %.1f fps" % (r[4], r[5]), "GEARUP " if r[6] else "",
                  "STOP" if r[7] else ""))
        else:
            print("%s %-22s before %-28s after %-28s %s" % (when, r[1][:22], r[8] or "-", r[9], r[10]))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return
    cmd, args = sys.argv[1], sys.argv[2:]
    with_args = {"list": cmd_list, "show": cmd_show, "set": cmd_set, "runs": cmd_runs}
    without = {"scan": scan, "docs": docs, "check": check}
    if cmd in with_args:
        with_args[cmd](args)
    elif cmd in without:
        without[cmd]()
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
