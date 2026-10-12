#!/usr/bin/env python3
"""Compare a simulated flight with the flown record: the STS-134 Space Shuttle
Mission Report's Appendix A (STS-134 MISSION EVENTS, a table of EVENT /
DESCRIPTION / ACTUAL GMT), event by event, against the vehicle's own log.

    tools/missionaudit.py LOG [--report PDF|TXT] [--tol SECONDS] [--json]

LOG is a yaGPC2.log of a run.  Run with YAGPC_VEHDYN_TRACE=1 to have the OMS
and jet events in it (the assist and the OMS burns); without it those rows read
"not in the log".  Times are compared FROM SRB IGNITION, which is the one
instant both records name (the report: 136/12:56:27.994; the log: "mec: SRM
IGNITION FIRED"), so the simulation's absolute GMT need not agree with the
flight's.  A row is a difference of more than --tol seconds (default 2.0).

This is the first of the "every change needs a cause" checks: a row that
differs is a lead, not a verdict -- the report is one flight, and the usual
reading of an event time is a few tenths of a second.
"""
import argparse
import json
import os
import re
import subprocess
import sys

DEFAULT_REPORT = os.path.expanduser(
    "~/Desktop/sandroid.org/public_html/apollo/Shuttle/Reports/Mission Reports/"
    "STS-134 Space Shuttle Mission Report.pdf")
GMT_RE = re.compile(r"\b(\d{3})/(\d\d):(\d\d):(\d\d(?:\.\d+)?)\s*$")


def report_text(path):
    if path.lower().endswith(".txt"):
        return open(path, errors="ignore").read()
    return subprocess.run(["pdftotext", "-layout", path, "-"], capture_output=True,
                          text=True, check=True).stdout


def appendix_a(text):
    """[(event, description, gmt_seconds)] from the STS-134 MISSION EVENTS tables;
    a row with no event label belongs to the label above it."""
    rows, event, inside = [], "", False
    for line in text.splitlines():
        if re.search(r"EVENT\s+DESCRIPTION\s+ACTUAL GMT", line):
            inside = True                      # the table's own header, on each page
            continue
        if not inside:
            continue
        m = GMT_RE.search(line)
        body = line[:m.start()] if m else line
        if not body.strip() and not m:
            continue
        if re.match(r"\s*APPENDIX\s+[B-Z]", line) and rows:
            break
        parts = re.split(r"\s{2,}", body.strip())
        if len(line) - len(line.lstrip()) < 4 and len(parts) >= 2:
            event, desc = parts[0], " ".join(parts[1:])
        elif m and len(parts) >= 1 and parts[0]:
            desc = " ".join(parts)
        else:
            continue
        if m:
            d, h, mi, s = m.groups()
            rows.append((event, desc, int(d) * 86400 + int(h) * 3600 + int(mi) * 60 + float(s)))
        elif re.search(r"Not Required", line):
            rows.append((event, desc.replace("Not Required", "").strip(), None))
    return rows


def sim_events(log):
    """What the log can say, as {name: [t, ...]} in vehicle seconds."""
    ev = {}
    def add(k, t):
        ev.setdefault(k, []).append(t)
    pct = {}
    for line in open(log, errors="ignore"):
        m = re.search(r"mec: (SRM IGNITION|SRB SEPARATION|ET SEPARATION) FIRED \(MEC1\) at t=([\d.]+)", line)
        if m:
            add(m.group(1), float(m.group(2)))
            continue
        m = re.search(r"vehdyn: t=([\d.]+) s (left|right) OMS (ON|off)", line)
        if m:
            add("OMS " + m.group(3), float(m.group(1)))
            continue
        m = re.search(r"eiu: ME(\d) \w+ accepted at t=([\d.]+) -- phase (\d) mode (\d+), ([\d.]+)%", line)
        if m:
            me, t, ph, md, p = int(m.group(1)), float(m.group(2)), int(m.group(3)), int(m.group(4)), float(m.group(5))
            if ph == 3 and md == 1:
                ev.setdefault("SSME-%d start" % me, []).append(t) if not ev.get("SSME-%d start" % me) else None
            if ph in (4, 5) and p != pct.get(me):
                ev.setdefault("SSME-%d throttle" % me, []).append((t, p))
                pct[me] = p
            if ph == 5 and not ev.get("MECO"):
                add("MECO", t)
    return ev


def throttle_event(ev, t0, label):
    """The sim's time for one of the report's throttle events.  The log's
    percent is the power in effect when a command is accepted, so the k-th
    change is the command that left the k-th level; the 3g throttling is the
    first change after T+300 s and 'to 67 for cutoff' is the first command
    that finds the engines at 67 percent."""
    ch = sorted(ev.get("SSME-1 throttle", []))
    if not ch:
        return None
    lab = label.lower()
    if "up 104.5" in lab or "up to 104.5" in lab:
        ups = [t for t, p in ch if t - t0 < 300][:3]
        idx = 0 if "up 104.5 percent" in lab and "to" not in lab.split("up")[1][:4] else 2
        return ups[idx] if len(ups) > idx else None
    if "72" in lab:
        return ([t for t, p in ch if t - t0 < 300][1:2] or [None])[0]
    if "3g" in lab or "for 3g" in lab:
        return next((t for t, p in ch if t - t0 > 300), None)
    if "67" in lab or "cutoff" in lab:
        return next((t for t, p in ch if p <= 67.0), None)
    return None


def audit(log, report, tol):
    rows = appendix_a(report_text(report))
    ev = sim_events(log)
    if not ev.get("SRM IGNITION"):
        raise SystemExit("no 'mec: SRM IGNITION FIRED' in the log: not a run that launched")
    t0 = ev["SRM IGNITION"][0]
    ign = next((g for e, d, g in rows if e.startswith("SRB Ignition") and g), None)
    out = []
    oms_on = sorted(ev.get("OMS ON", []))
    oms_off = sorted(ev.get("OMS off", []))
    def first(k, after=-1.0):
        return next((t for t in sorted(ev.get(k, [])) if t > after), None)
    for e, d, g in rows:
        want = None if g is None or ign is None else g - ign
        sim = None
        note = ""
        key = (e + " " + d).lower()
        if e.startswith("SRB Ignition"):
            sim = t0
        elif "srb separation command" in key:
            sim = first("SRB SEPARATION")
        elif "start command accepted" in key:
            m = re.search(r"SSME-(\d)", d)
            sim = (ev.get("SSME-%s start" % m.group(1)) or [None])[0] if m else None
        elif e.lower().startswith("throttle") or e.lower().startswith("for cutoff"):
            sim = throttle_event(ev, t0, e + " " + d)
        elif key.startswith("ssme shutdown"):
            sim = first("MECO")
        elif key.startswith("main engine cutoff") and "confirmed" not in key:
            sim = first("MECO")
        elif e.startswith("ET Separation") and "command" in key:
            sim = first("ET SEPARATION")
        elif e.startswith("OMS Assist Ignition"):
            sim = first("OMS ON"); note = "" if sim else "needs YAGPC_VEHDYN_TRACE"
        elif e.startswith("OMS Assist Cutoff"):
            on = first("OMS ON"); sim = first("OMS off", on or -1.0) if on else None
        elif e.startswith("OMS 2 Ignition"):
            sim = first("OMS ON", t0 + 1200.0)
        elif e.startswith("OMS 2 Cutoff"):
            on = first("OMS ON", t0 + 1200.0); sim = first("OMS off", on) if on else None
        elif g is None:
            note = "not required (the report)"
        if sim is not None and sim >= 0 and g is not None and e.startswith(("OMS 2", "OMS Assist")) is False:
            pass
        sim_rel = None if sim is None else (sim - t0 if not e.startswith("SRB Ignition") else 0.0)
        diff = None if (sim_rel is None or want is None) else sim_rel - want
        out.append(dict(event=e, description=d, report_met=want, sim_met=sim_rel, diff=diff,
                        flag=(diff is not None and abs(diff) > tol), note=note))
    return out, ev, t0


def fmt(x):
    return "     --" if x is None else "%8.1f" % x


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("log")
    ap.add_argument("--report", default=DEFAULT_REPORT)
    ap.add_argument("--tol", type=float, default=2.0)
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args(argv)
    rows, ev, t0 = audit(a.log, a.report, a.tol)
    if a.json:
        print(json.dumps(rows, indent=1))
        return 0
    print("%-34s %-30s %8s %8s %7s" % ("EVENT", "DESCRIPTION", "FLOWN", "SIM", "DIFF"))
    for r in rows:
        print("%-34s %-30s %s %s %s %s%s" % (r["event"][:34], r["description"][:30],
              fmt(r["report_met"]), fmt(r["sim_met"]), fmt(r["diff"]),
              "  <<" if r["flag"] else "", ("  " + r["note"]) if r["note"] else ""))
    n = sum(1 for r in rows if r["diff"] is not None)
    bad = [r for r in rows if r["flag"]]
    print("\n%d of %d events compared, %d differ by more than %.1f s" % (n, len(rows), len(bad), a.tol))
    thr = {k: v for k, v in ev.items() if k.startswith("SSME-") and k.endswith("throttle")}
    if thr:
        k = sorted(thr)[0]
        print("\nSIM THROTTLE CHANGES (%s), s after ignition:" % k)
        print("  " + ", ".join("%.1f:%g%%" % (t - t0, p) for t, p in thr[k][:14]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
