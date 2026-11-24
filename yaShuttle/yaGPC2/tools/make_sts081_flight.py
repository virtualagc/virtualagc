#!/usr/bin/env python3
"""Make STS-81's flight files from STS-135's and STS-134's, the way sts135 was made from sts134.

    tools/make_sts081_flight.py [--archive S16609.txt] [--out DIR]

Writes examples/flights/sts081-flight.json, sts081-dolilu.json and sts081-reconfig.json: the flight
constants fly_sts134.py --flight takes, the DOLILU (launch targeting from MIR's plane, OMS-2 TIG,
masses) and the OPS 1 overlay I-loads (MECO velocity, radius, flight-path angle).  Everything not
changed here is STS-135's (the DOLILU tables shaped for STS-134) -- STS-81 is flown first as a cross-check
flight, as STS-135 was, and the tables retuned by flight.  What is sourced and what is not is said in each
file's notes; the weights are the Missions Summary's Appendix A-6 table (pdf page 278).

Sources: STS-81 Space Shuttle Mission Report (Table I, events; mission summary), Space Shuttle Missions
Summary 2-98 (MECO VI 25,922 fps actual, 25,915 predicted; MECO 8:29.9; post OMS-2 159.9 x 84.9 nmi;
104/104/109 % throttle; MPS Isp tag 453.18 s; fuel bias 884 lb; ET-83 LWT), and Mir's own plane from
the element archive (tools/mir_elements.py).
"""
import argparse
import copy
import datetime
import json
import math
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FLIGHTS = os.path.join(os.path.dirname(os.path.dirname(HERE)), "discretePanel", "examples", "flights")
sys.path.insert(0, HERE)
import mir_elements  # noqa: E402
from mission_reconfig import ibm_long, ibm_short  # noqa: E402

UTC = datetime.timezone.utc
FT = 0.3048
NM_FT = 6076.115
A_PASS_FT = 20925646.3           # PASS's equatorial radius (fly_sts134 / sts134-reconfig notes)
MU_FT = 1.407644e16              # ft^3/s^2

SRB_IGN = datetime.datetime(1997, 1, 12, 9, 27, 22, 984000, tzinfo=UTC)
ET_SEP = datetime.datetime(1997, 1, 12, 9, 36, 14, tzinfo=UTC)
OMS2_TIG = datetime.datetime(1997, 1, 12, 10, 10, 23, 300000, tzinfo=UTC)
# a flight-day start: the vehicle's clock starts 5,187.99 s before SRB ignition on STS-134 and 135
CLOCK_START = SRB_IGN - datetime.timedelta(seconds=5187.99)
# Space Shuttle Missions Summary, Appendix A-6 (pdf page 278), STS-81 row: orbiter 250,167 lb at SRB ignition (242,178 at
# insertion; landing 215,337), ET 1,663,879 lb and SRB 1,298,753 lb (each, the table's average) at SRB ignition, shuttle total 4,511,011
ORBITER_LB = 250167.0
ET_LB = 1663879.0
SRB_LB = 1298753.0
TAPE_ET_LB = 1662224.0           # the tape's default ET, from sts135's MASS_VEHICLE_ET shift (1,657,525 lb gave -146.05 slug)


def gmt_s(t):
    return (t - datetime.datetime(1997, 1, 1, tzinfo=UTC)).total_seconds() + 86400.0


def mir_plane(archive):
    """(inclination deg, Earth-fixed node east longitude deg at SRB ignition, in-plane GMT)."""
    from sgp4.api import Satrec, jday
    from skyfield.api import load
    sets, _ = mir_elements.read_sets(archive)
    sets.sort(key=lambda s: s[0])
    c = [s for s in sets if s[0] <= SRB_IGN][-1]
    sat = Satrec.twoline2rv(c[1], c[2])
    ts = load.timescale()

    def state(t):
        jd, fr = jday(t.year, t.month, t.day, t.hour, t.minute, t.second + t.microsecond * 1e-6)
        e, r, v = sat.sgp4(jd, fr)
        h = [r[1] * v[2] - r[2] * v[1], r[2] * v[0] - r[0] * v[2], r[0] * v[1] - r[1] * v[0]]
        n = math.sqrt(sum(x * x for x in h))
        return [x / n for x in h]

    def gst(t):
        return ts.from_datetime(t).gast * 15.0
    h = state(SRB_IGN)
    inc = math.degrees(math.acos(h[2]))
    raan = math.degrees(math.atan2(h[0], -h[1])) % 360.0
    node_ef = (raan - gst(SRB_IGN)) % 360.0
    lat, lon = math.radians(28.627), math.radians(-80.621)    # pad 39B

    def oop(t):
        ra = math.radians(gst(t)) + lon
        s = [math.cos(lat) * math.cos(ra), math.cos(lat) * math.sin(ra), math.sin(lat)]
        hh = state(SRB_IGN)          # the plane frozen at liftoff, as CGGB_EF_PLANE_SW does
        return math.asin(sum(a * b for a, b in zip(hh, s)))
    lo, hi = 0.0, 900.0
    for _ in range(60):
        mid = (lo + hi) / 2
        if oop(SRB_IGN + datetime.timedelta(seconds=mid)) > 0:
            lo = mid
        else:
            hi = mid
    t_in = SRB_IGN + datetime.timedelta(seconds=lo)
    return inc, node_ef, t_in, c[0], oop(SRB_IGN)


def iyd(inc, node):
    i, o = math.radians(inc), math.radians(node)
    return [round(-math.sin(i) * math.sin(o), 5), round(math.sin(i) * math.cos(o), 5), round(-math.cos(i), 5)]


def meco_radius_for_apogee(ha_nmi, vi, gamma_deg):
    """The MECO radius (ft) at inertial velocity vi (ft/s) and flight-path angle gamma_deg whose coast
    reaches an apogee of ha_nmi above PASS's equatorial radius."""
    ra = A_PASS_FT + ha_nmi * NM_FT
    vt = vi * math.cos(math.radians(gamma_deg))
    lo, hi = A_PASS_FT, ra
    for _ in range(100):
        r = (lo + hi) / 2
        h = r * vt
        en = vi * vi / 2 - MU_FT / r
        a = -MU_FT / (2 * en)
        e = math.sqrt(max(0.0, 1 - h * h / (MU_FT * a)))
        if a * (1 + e) < ra:
            lo = r
        else:
            hi = r
    return (lo + hi) / 2


def words(ws):
    return "".join("%04X" % w for w in ws)


def read_sounding(path):
    rows = []
    for ln in open(path).read().splitlines()[1:]:
        c = [x.strip() for x in ln.split(",")]
        if len(c) < 13 or not c[4] or not c[11] or not c[12]:
            continue
        rows.append(dict(raw=c, h=float(c[4]), dirn=float(c[11]), spd=float(c[12])))
    rows.sort(key=lambda r: r["h"])
    return rows


def uv_fps(r):
    """(east, north) wind in ft/s toward which it blows (the file's direction is where it comes FROM)."""
    sp = r["spd"] / FT
    d = math.radians(r["dirn"])
    return -sp * math.sin(d), -sp * math.cos(d)


def wind_tab(rows):
    """WNDE_TAB, WNDN_TAB at 0/8/18/28/38/48/58/80 kft: the mean over +-1,000 ft, as sts134's."""
    ek, nk = [], []
    for alt in (0, 8, 18, 28, 38, 48, 58, 80):
        lo, hi = max(0.0, (alt - 1.0)) * 1000 * FT, (alt + 1.0) * 1000 * FT
        sel = [r for r in rows if lo <= r["h"] <= hi] or [min(rows, key=lambda r: abs(r["h"] - alt * 1000 * FT))]
        uv = [uv_fps(r) for r in sel]
        ek.append(round(sum(x[0] for x in uv) / len(uv), 1))
        nk.append(round(sum(x[1] for x in uv) / len(uv), 1))
    return ek, nk


def interp_sounding(before, after, w, out):
    """The air at launch: the two balloons' profiles (columns by height) blended, weight w on the later."""
    def at(rows, h, col):
        xs = [r for r in rows if r["raw"][col] not in ("",)]
        for a, b in zip(xs, xs[1:]):
            if a["h"] <= h <= b["h"] and b["h"] > a["h"]:
                t = (h - a["h"]) / (b["h"] - a["h"])
                return float(a["raw"][col]) * (1 - t) + float(b["raw"][col]) * t
        return float(xs[0 if h < xs[0]["h"] else -1]["raw"][col])
    hdr = open(os.path.join(FLIGHTS, "sts081-sounding-72206-1997011211Z.csv")).readline().strip()
    lines = [hdr]
    for r in after:
        h = r["h"]
        v = []
        for col in (3, 5, 6, 7, 8, 9, 10):
            v.append(w * float(r["raw"][col] or 0) + (1 - w) * at(before, h, col))
        u1, v1 = uv_fps(r)
        u0 = [uv_fps({"spd": at(before, h, 12), "dirn": at(before, h, 11)})][0]
        ue, vn = w * u1 + (1 - w) * u0[0], w * v1 + (1 - w) * u0[1]
        spd = math.hypot(ue, vn) * FT
        dirn = (math.degrees(math.atan2(-ue, -vn))) % 360.0
        lines.append("1997-01-12 09:27:23,%s,%s,%.1f,%5d,%5.1f,%5.1f,%5.1f,%3.0f,%3.0f,%.2f,%3.0f,%5.1f" % (
            r["raw"][1], r["raw"][2], v[0], round(h), v[1], v[2], v[3], v[4], v[5], v[6], dirn, spd))
    open(out, "w").write("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--archive", default=os.path.expanduser("~/Desktop/Shuttle Stuff/S16609.txt"))
    ap.add_argument("--out", default=FLIGHTS)
    ap.add_argument("--orbiter-lb", type=float, default=ORBITER_LB)
    ap.add_argument("--oms-assist-dt", type=float, default=109.0, help="ASSIST_OMS_DT, s: the tape's (STS-134) value; STS-81's use of the OMS assist is not established")
    ap.add_argument("--apogee-trim", type=float, default=-6.7, help="nmi added to the 159.9 nmi MECO apogee aim: run 2 (VI aim 25,915) came out 6.7 nmi high after OMS-2 (166.6 vs 159.9), so the aim is lowered by that")
    a = ap.parse_args()
    inc, node, t_in, setep, off = mir_plane(a.archive)
    pl = iyd(inc, node)
    in_plane = gmt_s(t_in)
    d135 = json.load(open(os.path.join(a.out, "sts135-dolilu.json")))
    d = copy.deepcopy(d135)
    d["flight"] = "STS-81, Atlantis, LC-39B, 1997-01-12 09:27:23 UTC"
    d["sources"] = [
        "STS-81 Space Shuttle Mission Report: Table I (SRB ignition 012:09:27:22.984, MECO 09:35:55, ET separation 09:36:14, OMS-2 TIG 10:10:23.3); Missions Summary NASA/TM-2011-216142 p. 2-98 (MECO VI 25,922 actual / 25,915 predicted, MECO cmd 8:29.9, 104/104/109%, ET-83 LWT, post OMS-2 159.9 x 84.9 nmi, launch window 6m59s, Mir planar/phase window)",
        "Mir's plane: the element set of %s UTC from S16609.txt (tools/mir_elements.py), inclination %.4f deg" % (setep.strftime("%Y-%m-%dT%H:%M:%S"), inc),
        "Everything else as sts135-dolilu.json, which is as sts134-dolilu.json: STS-81 is flown first as a cross-check flight",
    ]
    d["notes"] = [
        "A CROSS-CHECK FLIGHT, as STS-135: the vehicle model and first-stage tables were built for STS-134; flown with them to see which differences from the real flight are the model's.  The first run will show how far the yaw, pitch and throttle tables are off; retune by flight.",
        "IYD: MIR's plane at SRB ignition, Earth-fixed: inclination %.4f deg, node %.4f deg east (RAAN of date less GMST); IYD = (-sin i sin node, sin i cos node, -cos i), the form sts134/135's use.  The pad (39B) is %.2f deg off this plane at SRB ignition and in plane at 1997 day 12 GMT %s (T_GMTLO_REF), about %d s later: the flown launch was at the opening of the 6m59s planar window, so the window closed about when the pad passed through the plane." % (inc, node, math.degrees(off), t_in.strftime("%H:%M:%S"), (t_in - SRB_IGN).total_seconds()),
        "MASSES: the Space Shuttle Missions Summary's Appendix A-6 weight table (pdf page 278), STS-81 row: orbiter %.0f lb at SRB ignition (242,178 at insertion), ET 1,663,879 lb, SRB 1,298,753 lb, shuttle total 4,511,011 lb.  The first run used an estimate of 242,000 lb and MECO came 7 s early." % a.orbiter_lb,
        "NO WIND TABLE YET: add message 11 from the 1997-01-12 Cape sounding (74794) before this is flown for comparison; until then PASS indexes its first-stage tables with the tape's default wind.",
        "OMS 2: TIG = ET separation + %.1f s (ET sep 09:36:14, OMS-2 10:10:23.3); pre-flight targets are placeholders -- the ground designs them after MECO for 159.9 x 84.9 nmi (75.5 ft/s flown)." % (OMS2_TIG - ET_SEP).total_seconds(),
    ]
    slug = a.orbiter_lb / 32.174
    dm = slug - 6315.438         # the tape's MASS_ORBITER_LIFTOFF
    for m in d["messages"]:
        if m["op"] in (15, 25):
            for f in m["fields"]:
                n = f.get("name", "")
                if n.startswith("T_GMTLO_REF"):
                    f["D"] = float(round(in_plane)); f["name"] = "T_GMTLO_REF 012/%s (the in-plane time)" % t_in.strftime("%H:%M:%S")
                elif n in ("IY_MIN", "IYD", "IYD_NOM") or n.startswith("IYD_OMS"):
                    f["D"] = pl
                    if n.startswith("IYD_OMS(1)"):
                        f["name"] = "IYD_OMS(1): the Mir plane (PEG 4 flies the present orbit's plane regardless, GGILTV step 31)"
                elif n.startswith("OMS 2:"):
                    f["E"] = [round((OMS2_TIG - ET_SEP).total_seconds(), 1), 84.9, 330.0, 0.0, 0.0]
                    f["name"] = "OMS 2: TIG = ET separation + %.1f s (STS-81: ET sep 09:36:14, OMS-2 TIG 10:10:23.3); placeholders -- the ground designs them for 159.9 x 84.9 nmi" % (OMS2_TIG - ET_SEP).total_seconds()
        elif m["op"] == 96:
            for f in m["fields"]:
                if f.get("name") == "VDMAG":
                    f["E"] = 25915.0
        elif m["op"] == 37:
            for f in m["fields"]:
                n = f.get("name", "")
                if n in ("M_EMPTY", "MASS_VEHICLE_ET", "ET_LEVEL_SENSOR_MASS", "MASS_ORBITER_LIFTOFF", "OMS_CUTOFF_MASS(1)", "OMS_CUTOFF_MASS(2)", "MBOD_ONE", "MBOD_TWO"):
                    f["E"] = round(f["was"] + dm + ((ET_LB - TAPE_ET_LB) / 32.174 if n == "MASS_VEHICLE_ET" else 0.0), 2)
                    f["note"] = "STS-81: orbiter %.0f lb at SRB ignition (Missions Summary A-6); the tape's value moved with it" % a.orbiter_lb
                elif n == "ASSIST_OMS_DT":
                    f["E"] = a.oms_assist_dt
                    f["note"] = "the tape's: STS-81's OMS assist time not found"
    # the air: Cape Canaveral's 74794 is not in the Wyoming archive for 1997, so the nearest east-coast balloon, Jacksonville
    # (72206, 30.5 N, 81.7 W): PASS's wind table from the last one before liftoff (1997-01-11 23:04Z), the truth's air the
    # 23:04Z and 11:03Z profiles blended to 09:27Z
    s0 = read_sounding(os.path.join(a.out, "sts081-sounding-72206-1997011123Z.csv"))
    s1 = read_sounding(os.path.join(a.out, "sts081-sounding-72206-1997011211Z.csv"))
    w = ((SRB_IGN - datetime.datetime(1997, 1, 11, 23, 4, tzinfo=UTC)).total_seconds()
         / (datetime.datetime(1997, 1, 12, 11, 3, tzinfo=UTC) - datetime.datetime(1997, 1, 11, 23, 4, tzinfo=UTC)).total_seconds())
    interp_sounding(s0, s1, w, os.path.join(a.out, "sts081-sounding-72206-19970112-0927Z.csv"))
    ek, nk = wind_tab(s0)
    d["messages"].append({"op": 11, "name": "wind table (WNDE_TAB, WNDN_TAB)", "fields": [
        {"E": ek, "name": "WNDE_TAB(1-8), ft/s toward east, at ALT_WND 0/8/18/28/38/48/58/80 kft: Jacksonville 72206 of 1997-01-11 23:04Z (University of Wyoming archive; Cape Canaveral 74794 is not archived for 1997), the last balloon before liftoff, averaged over +-1,000 ft"},
        {"E": nk, "name": "WNDN_TAB(1-8), ft/s toward north, the same sounding"}]})
    d["notes"][3] = "Message 11, the wind table: Jacksonville's (72206) balloon of 1997-01-11 23:04Z, the last before liftoff -- Cape Canaveral's 74794 is not in the archive for 1997, and Jacksonville is the nearest east-coast station that is.  The truth flies the 23:04Z and 11:03Z profiles blended to 09:27Z (sts081-sounding-72206-19970112-0927Z.csv, weight %.2f on the later)." % w
    json.dump(d, open(os.path.join(a.out, "sts081-dolilu.json"), "w"), indent=1)
    # the flight file
    f135 = json.load(open(os.path.join(a.out, "sts135-flight.json")))
    t0 = [12, 9, 27, 22.984]
    flight = {"name": "sts081", "dolilu": "sts081-dolilu.json", "rnp": [1997, 12],
              "epoch": CLOCK_START.strftime("%Y-%m-%dT%H:%M:%S"), "t0": t0, "gmtlo": [12, 9, 27, 20.0],
              "oms2_dtig": round((OMS2_TIG - ET_SEP).total_seconds(), 1), "oms2_hp": 84.9, "oms2_ha": 159.9,
              "orbiter_kg": round(a.orbiter_lb * 0.45359237),
              "env": {"YAGPC_VEHDYN_SSME_ISP": "453.18", "YAGPC_VEHDYN_FUEL_BIAS_LB": "884",
                      "YAGPC_VEHDYN_SOUNDING": "sts081-sounding-72206-19970112-0927Z.csv",
                      "YAGPC_VEHDYN_PAD_ALT": "64.1",
                      "YAGPC_VEHDYN_ET_LB": "%.0f" % ET_LB, "YAGPC_VEHDYN_SRB_LB": "%.0f" % SRB_LB},
              "notes": ["STS-81 (Mission Report Table I; Missions Summary p. 2-98): SRB ignition 012/09:27:22.984; GMTLO 09:27:20 gives T-0 at :22.8 (PASS's 2.8 s, see fly_sts134.py).",
                        "Weights (Missions Summary A-6, pdf page 278): orbiter %.0f lb, ET 1,663,879, SRB 1,298,753 at SRB ignition; SSME Isp tag 453.18 s and fuel bias 884 lb from the Missions Summary p. 2-98." % a.orbiter_lb,
                        "Air: Jacksonville's 1997-01-11 23:04Z and 01-12 11:03Z balloons blended to liftoff (Cape Canaveral 74794 is not archived for 1997).  Pad: vehdyn and PASS's own nav-base I-load put the vehicle at LC-39A's latitude and longitude (2.6 km from 39B), kept on purpose so the truth and PASS agree; the height is 39B's, 55 ft instead of 39A's 48 (YAGPC_VEHDYN_PAD_ALT 64.1 m = 62.0 + 7 ft).",
                        "Made by tools/make_sts081_flight.py; do not edit by hand."]}
    json.dump(flight, open(os.path.join(a.out, "sts081-flight.json"), "w"), indent=1)
    # the OPS 1 overlay: the MECO targets
    rc = json.load(open(os.path.join(a.out, "sts134-reconfig.json")))
    rc["flight"] = "STS-81, Atlantis"
    vi = 25915.0
    gam = 0.5                    # the tape's flight-path angle: STS-81's MECO value not found
    r_ft = meco_radius_for_apogee(159.9 + a.apogee_trim, vi, gam)
    alt = (r_ft - A_PASS_FT) / NM_FT
    rc["notes"] = ["STS-81 MECO targets: VI 25,915 ft/s (predicted; 25,922 flown, Missions Summary 2-98), the tape's flight-path angle 0.5 deg (STS-81's value NOT found), and the radius that makes the coast's apogee 159.9 nmi, the post OMS-2 apogee (OMS-2 at apogee raises the perigee): %.2f nmi above PASS's equatorial radius.  104%% throttle as STS-134 (K_CMD 104).  The rest as sts134-reconfig.json." % alt]
    for c in rc["cells"]:
        # the volume this goes on already carries STS-134's overlay (the KSC6 lineage, tools/mission_reconfig.py): what
        # the cell holds now is STS-134's value, so that is its "was"
        for k in ("E", "H"):
            if k in c:
                c["was"] = c[k]
                break
        if c["name"] == "CGGS_V_MAG_MECO_NOM":
            c["E"] = vi
        elif c["name"] in ("CGGS_RAD_MECO_NOM", "CGGV_RAD_MECO"):
            c["H"] = words(ibm_long(r_ft)); c["value"] = "%.0f ft = a + %.2f nmi (computed for a 159.9 nmi apogee at VI 25,915, FPA 0.5 deg; tape 21,290,308 = a + 60.02 nmi)" % (r_ft, alt)
        elif c["name"] == "CGGS_FPA_MECO_NOM":
            c["H"] = words(ibm_short(math.radians(gam))); c["value"] = "0.5 deg: the tape's (STS-81's value not found)"
    json.dump(rc, open(os.path.join(a.out, "sts081-reconfig.json"), "w"), indent=1)
    print("Mir plane: inc %.4f node(EF) %.4f  pad off-plane at SRB ign %.3f deg  in-plane %s (+%.0f s)" % (inc, node, math.degrees(off), t_in.strftime("%H:%M:%S"), (t_in - SRB_IGN).total_seconds()))
    print("IYD", pl, " T_GMTLO_REF", round(in_plane), " clock start", CLOCK_START.isoformat(), " MECO radius %.0f ft = a + %.2f nmi" % (r_ft, alt))


if __name__ == "__main__":
    main()
