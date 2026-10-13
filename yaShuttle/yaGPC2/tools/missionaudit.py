#!/usr/bin/env python3
"""Compare a simulated flight with the flown record: the STS-134 Space Shuttle
Mission Report's Appendix A (STS-134 MISSION EVENTS, a table of EVENT /
DESCRIPTION / ACTUAL GMT), event by event, against the vehicle's own log.

    tools/missionaudit.py LOG [--report PDF|TXT] [--tol SECONDS] [--json]
                             [--entry-log ENTRY_LOG]

LOG is a yaGPC2.log of a run.  Run with YAGPC_VEHDYN_TRACE=1 to have the OMS
and jet events in it (the assist and the OMS burns); without it those rows read
"not in the log".  Times are compared FROM SRB IGNITION, which is the one
instant both records name (the report: 136/12:56:27.994; the log: "mec: SRM
IGNITION FIRED"), so the simulation's absolute GMT need not agree with the
flight's.  A row is a difference of more than --tol seconds (default 2.0).

This is the first of the "every change needs a cause" checks: a row that
differs is a lead, not a verdict -- the report is one flight, and the usual
reading of an event time is a few tenths of a second.

SOURCE identifies the reference for each text row. Mission Report flown
values take precedence over Missions Summary actual/planned values;
disagreements appear as separate marked rows. Entry quantities name their
units, preserve source precision, and use only logged evidence. --tol is a
seconds tolerance, not an altitude/Mach/speed tolerance. An entry-resume log
may be supplied alone or alongside an ascent log with --entry-log.
--json retains all original event records unchanged and appends entry and
procedure records with units/source; alternate claims appear in text output.
"""
import argparse
import json
import os
import re
import subprocess
import sys
import bisect

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


REPORT_SOURCE = "Mission Report App A"
SUMMARY_SOURCE = "Missions Summary NASA 20110001406"
CHECKLIST_SOURCE = "checklist ASC/134 FB 2-5"

# NASA 20110001406, STS-134 pp. 2-240/241. These are source claims,
# not replacements for Appendix A. In particular its OMS-2 MET differs
# by about a minute. P/A are the document's planned/actual labels.
SUMMARY_TIMES = {
    "Main Engine Cutoff (MECO)": [(501.5, "actual"), (501.8, "planned")],
    "OMS 2 Ignition": [(2217.0, "actual"), (2220.0, "planned")],
    "Nose Landing Gear": [(None, "152/06:34:54")],
    "Drag Chute Deployment": [(None, "152/06:34:53")],
    "Drag Chute Jettison": [(None, "152/06:35:19")],
    "Wheels Stop": [(None, "152/06:35:32")],
}


def summary_alternatives(rows, tol=2.0):
    """Render alternate times separately; never change the legacy rows."""
    out = {}
    for i, r in enumerate(rows):
        claims = SUMMARY_TIMES.get(r["event"], [])
        for value, label in claims:
            if value is None:
                # The summary rounds ignition to .000 rather than .994;
                # align all absolute claims to Appendix A's ignition.
                d, h, m, s = label.replace("/", ":").split(":")
                value = (int(d) - 136) * 86400 + int(h) * 3600 + int(m) * 60 + float(s)
                value -= 12 * 3600 + 56 * 60 + 27.994
                label = "actual " + label
            conflict = r["report_met"] is not None and abs(value - r["report_met"]) > 0.05
            if conflict:
                alt = dict(r, report_met=value, diff=None if r["sim_met"] is None else r["sim_met"] - value,
                           source=SUMMARY_SOURCE + " p2-241 (" + label + ")",
                           note="source conflict; Mission Report flown value takes precedence")
                alt["flag"] = alt["diff"] is not None and abs(alt["diff"]) > tol
                out.setdefault(i, []).append(alt)
    return out


def log_lines(log):
    with open(log, errors="ignore") as stream:
        yield from stream


def entry_measurements(log):
    """Only explicit log evidence. Do not mistake sensor availability for
    PASS incorporation, first recontact for first touchdown, or the last
    sample for wheels stop. Deployment Mach uses a nearby logged sample
    and records its time offset. Missing observables stay None."""
    result, notes, samples = {}, {}, []
    touchdown, brakes, deployment, stop, interface, deorbit = None, None, None, None, None, None
    oms_on, oms_off = {}, {}
    number = r"[-+]?\d+(?:\.\d+)?"
    for line in log_lines(log):
        m = re.search(r"vehdyn-entry: t=(%s).*?h=(%s) ft M=(%s)" % (number, number, number), line)
        if m:
            samples.append(tuple(map(float, m.groups())))
        m = re.search(r"air data probe DEPLOYING at t=(%s)" % number, line)
        if m and deployment is None:
            deployment = float(m.group(1))
        m = re.search(r"MAIN gear TOUCHDOWN at t=(%s): ground speed (%s) kt, sink (%s) ft/s" % (number, number, number), line)
        if m and touchdown is None:
            touchdown, result["td_kgs"], result["td_sink"] = map(float, m.groups())
        m = re.search(r"BRAKES on at t=(%s)" % number, line)
        if m and brakes is None:
            brakes = float(m.group(1))
        m = re.search(r"(?:ENTRY INTERFACE|Entry Interface).*?t=(%s)" % number, line)
        if m and interface is None:
            interface = float(m.group(1))
        m = re.search(r"DEORBIT.*?(?:start|ignition).*?t=(%s)" % number, line, re.IGNORECASE)
        if m and deorbit is None:
            deorbit = float(m.group(1))
        m = re.search(r"WHEELS STOP.*?t=(%s)" % number, line)
        if m and stop is None:
            stop = float(m.group(1))
        # These require incorporation/event statements, not GPS/MLS setup lines.
        if re.search(r"ADTA.*(?:INCORPORATED|incorporated)|air data.*(?:INCORPORATED|incorporated)", line):
            m = re.search(r"(?:Mach|M=)\s*(%s)" % number, line)
            if m:
                result.setdefault("adta_mach", float(m.group(1)))
        if re.search(r"GPS.*(?:INCORPORATED|incorporated)", line):
            m = re.search(r"(?:h=|altitude[ =]+)(%s)\s*ft" % number, line)
            if m:
                result.setdefault("gps_alt", float(m.group(1)))
            m = re.search(r"EI\+(%s)\s*s" % number, line)
            if m:
                result.setdefault("gps_ei", float(m.group(1)))
        if re.search(r"MLS.*(?:INCORPORATED|incorporated)", line):
            m = re.search(r"(?:h=|altitude[ =]+)(%s)\s*ft" % number, line)
            if m:
                result.setdefault("mls_alt", float(m.group(1)))
        m = re.search(r"vehdyn: t=(%s) s (left|right) OMS (ON|off)" % number, line)
        if m:
            target = oms_on if m.group(3) == "ON" else oms_off
            target.setdefault(m.group(2), []).append(float(m.group(1)))
        # Support explicit diagnostic fields without fabricating them from qbar.
        for key, pattern in [
            ("td_keas", r"MAIN gear TOUCHDOWN.*?(?:equivalent airspeed|KEAS)[ =]+(%s)"),
            ("brake_kgs", r"BRAKES on.*?(?:ground speed|KGS)[ =]+(%s)"),
            ("rollout_ft", r"rollout distance[ =]+(%s)\s*ft"),
            ("rollout_s", r"rollout time[ =]+(%s)\s*s"),
            ("deorbit_dv", r"deorbit.*?(?:delta-V|delta_v)[ =]+(%s)\s*ft/s"),
            ("deorbit_s", r"deorbit.*?duration[ =]+(%s)\s*s"),
        ]:
            m = re.search(pattern % number, line, re.IGNORECASE)
            if m:
                result.setdefault(key, float(m.group(1)))
    if deployment is not None and samples:
        times = [s[0] for s in samples]
        i = bisect.bisect_left(times, deployment)
        choices = samples[max(0, i - 1):min(len(samples), i + 1)]
        sample = min(choices, key=lambda s: abs(s[0] - deployment))
        if abs(sample[0] - deployment) <= 3.0:
            result["deploy_mach"] = sample[2]
            notes["deploy_mach"] = "nearest Mach sample at deployment %+.2f s" % (sample[0] - deployment)
    if touchdown is not None and brakes is not None and brakes >= touchdown:
        result["brake_td"] = brakes - touchdown
        notes["brake_td"] = "from first main touchdown and brakes-on timestamps"
    if touchdown is not None and stop is not None and stop >= touchdown:
        result.setdefault("rollout_s", stop - touchdown)
    if interface is not None and deorbit is not None:
        # A named deorbit interval prevents mistaking the last *logged*
        # OMS-2 firing for a deorbit burn whose telemetry is absent.
        candidates = [(t, engine) for engine, times in oms_on.items()
                      for t in times if deorbit <= t < interface]
        if candidates and "deorbit_s" not in result:
            on, engine = max(candidates)
            off = min((t for t in oms_off.get(engine, []) if on < t < interface), default=None)
            if off is not None:
                result["deorbit_s"] = off - on
                notes["deorbit_s"] = "last %s OMS valve interval before explicit EI" % engine
    return result, notes


def additional_rows(log, tol):
    sim, notes = entry_measurements(log)
    specs = [
        ("ADTA deploy", "deploy_mach", 4.9, "Mach", "p54"),
        ("ADTA incorporation", "adta_mach", 3.0, "Mach", "p54"),
        ("GPS incorporation since EI", "gps_ei", 1244.0, "s since EI", "p55; 20:44"),
        ("GPS incorporation altitude", "gps_alt", 153000.0, "ft", "p55"),
        ("MLS incorporation altitude", "mls_alt", 16300.0, "ft", "p55"),
        ("Main touchdown ground speed", "td_kgs", 195.3, "KGS", "p57"),
        ("Main touchdown airspeed", "td_keas", 190.6, "KEAS", "p57"),
        ("Main touchdown sink", "td_sink", 1.21, "ft/s down", "p57"),
        ("Rollout distance", "rollout_ft", 6596.0, "ft", "p57"),
        ("Rollout time", "rollout_s", 42.5, "s", "p57"),
        ("Brakes since touchdown", "brake_td", 16.76, "s since TD", "p57"),
        ("Brakes ground speed", "brake_kgs", 118.8, "KGS", "p57"),
        ("Deorbit burn duration", "deorbit_s", 159.2, "s", "p44 OMS table"),
        ("Deorbit delta-V", "deorbit_dv", 296.9, "ft/s", "p44 OMS table"),
    ]
    rows = []
    for label, key, flown, unit, page in specs:
        value = sim.get(key)
        diff = None if value is None else value - flown
        rows.append(dict(event=label, description=unit, report_met=flown, sim_met=value, diff=diff,
                         flag=diff is not None and unit.startswith("s") and abs(diff) > tol,
                         note=notes.get(key, "") if value is not None else "not in the log",
                         units=unit, source="Mission Report " + page))
    # Checklist conditions are not a flown measurement. Absence of an explicit
    # translation interval in the log must not be filled with a jet count.
    rows.append(dict(event="Post-ET +X translation", description="s (conditional procedure)",
                     report_met=11.0, sim_met=None, diff=None, flag=False, units="s",
                     source=CHECKLIST_SOURCE,
                     note="MM104+2 s, ET Sep complete, HA >72; not a flown duration"))
    return rows


def entry_alternatives(row, tol=2.0):
    """Report disagreement on comparable quantities, with explicit provenance."""
    claims = {
        "Main touchdown ground speed": [(196.0, SUMMARY_SOURCE + " p2-240", "rounded actual KGS")],
        "Main touchdown airspeed": [(191.0, SUMMARY_SOURCE + " p2-240", "rounded actual KEAS")],
        "Main touchdown sink": [(1.0, SUMMARY_SOURCE + " p2-240", "HDOT -1.0 converted to sink-down sign")],
        "Deorbit burn duration": [(158.3, "Mission Report p15 summary", "report internal conflict")],
        "Deorbit delta-V": [(298.4, "Mission Report p15 summary", "report internal conflict")],
    }
    out = []
    for value, source, note in claims.get(row["event"], []):
        diff = None if row["sim_met"] is None else row["sim_met"] - value
        out.append(dict(row, report_met=value, diff=diff,
                        flag=diff is not None and row["units"].startswith("s") and abs(diff) > tol,
                        source=source, note="source conflict; " + note))
    return out


def reference_only(report):
    """An entry-resume log has no SRB ignition; retain the report's old rows
    with absent sim values rather than assigning t=0 to a different phase."""
    rows = appendix_a(report_text(report))
    ign = next((g for e, d, g in rows if e.startswith("SRB Ignition") and g), None)
    return [dict(event=e, description=d, report_met=None if g is None or ign is None else g - ign,
                 sim_met=None, diff=None, flag=False, note="not in the log") for e, d, g in rows]


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("log")
    ap.add_argument("--report", default=DEFAULT_REPORT)
    ap.add_argument("--tol", type=float, default=2.0)
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--entry-log", help="optional separate entry-run log for the additional rows")
    a = ap.parse_args(argv)
    ev = sim_events(a.log)
    if ev.get("SRM IGNITION"):
        rows, ev, t0 = audit(a.log, a.report, a.tol)
    else:
        if not any(line.startswith("vehdyn-entry:") or "MAIN gear TOUCHDOWN" in line
                   for line in log_lines(a.log)):
            raise SystemExit("no 'mec: SRM IGNITION FIRED' in the log: not a run that launched")
        rows, t0 = reference_only(a.report), None
    extra = additional_rows(a.entry_log or a.log, a.tol)
    if a.json:
        # The old records' keys, values and order are deliberately unchanged.
        # New records carry units and provenance; alternates are textual rows.
        print(json.dumps(rows + extra, indent=1))
        return 0
    print("%-34s %-30s %8s %8s %7s  SOURCE" % ("EVENT", "DESCRIPTION", "FLOWN", "SIM", "DIFF"))
    def emit(r, source, conflict=False):
        # Old event formatting stays byte-for-byte identical before SOURCE.
        # Preserve entry values such as 1.21 ft/s and TD+16.76 s.
        value_fmt = fmt if "units" not in r else lambda x: "     --" if x is None else "%8.2f" % x
        print("%-34s %-30s %s %s %s %s%s  | %s%s" % (r["event"][:34], r["description"][:30],
              value_fmt(r["report_met"]), value_fmt(r["sim_met"]), value_fmt(r["diff"]),
              "  <<" if r["flag"] else "", ("  " + r["note"]) if r["note"] else "",
              source, " [source conflict]" if conflict else ""))
    alternates = summary_alternatives(rows, a.tol)
    for i, r in enumerate(rows):
        emit(r, REPORT_SOURCE, i in alternates)
        for alt in alternates.get(i, []):
            emit(alt, alt["source"], True)
    n = sum(1 for r in rows if r["diff"] is not None)
    bad = [r for r in rows if r["flag"]]
    print("\n%d of %d events compared, %d differ by more than %.1f s" % (n, len(rows), len(bad), a.tol))
    thr = {k: v for k, v in ev.items() if k.startswith("SSME-") and k.endswith("throttle")}
    if thr:
        k = sorted(thr)[0]
        print("\nSIM THROTTLE CHANGES (%s), s after ignition:" % k)
        print("  " + ", ".join("%.1f:%g%%" % (t - t0, p) for t, p in thr[k][:14]))
    print("\nENTRY AND PROCEDURE VALUES (units in DESCRIPTION; -- means absent evidence):")
    for r in extra:
        alts = entry_alternatives(r, a.tol)
        emit(r, r["source"], bool(alts))
        for alt in alts:
            emit(alt, alt["source"], True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
