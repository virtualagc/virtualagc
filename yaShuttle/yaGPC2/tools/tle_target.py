#!/usr/bin/env python3
"""A TLE as a target line for YAGPC_VEHDYN_TARGETS (vehdyn.c's other vehicles).

    tools/tle_target.py TLE_FILE [--at YYYY-MM-DDTHH:MM:SS] [--bc KG_PER_M2]
                        [--attitude lvlh|inertial] [--port X,Y,Z] >> targets.txt

SGP4 (Skyfield) gives the vehicle's state at one instant -- the TLE's own
epoch unless --at names another, best near the flight -- in GCRS, which is
J2000 to well within a metre here, as the target line wants; vehdyn turns it
into M50 and moves it from then on with its own gravity and the vehicle's
drag, not SGP4.  TLE_FILE holds the two element lines (a name line before
them is allowed); with several sets, the one whose epoch is nearest --at is
used.  The ISS's TLE for STS-134 is Space-Track's (epoch 11138.51317551).
--port gives the vehicle a docking port the Orbiter's ODS can capture
(vehdyn.c, THE DOCKING): its face's centre in the vehicle's body, metres,
axis +X.  PMA-2 on Node 2 in May 2011: --port 15.655,0,5.562, the face of
the PMA-2 in portview's ISS model, so that what MON1 shows lines up with
what vehdyn captures (a model value, not a sourced one).
"""
import argparse
import datetime
import sys


def read_sets(path):
    lines = [ln.rstrip() for ln in open(path) if ln.strip()]
    sets = []
    for i, ln in enumerate(lines):
        if ln.startswith("1 ") and i + 1 < len(lines) and lines[i + 1].startswith("2 "):
            name = lines[i - 1].strip() if i > 0 and not lines[i - 1].startswith(("1 ", "2 ")) else None
            sets.append((ln, lines[i + 1], name))
    return sets


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("tle")
    ap.add_argument("--at", help="the instant (UTC, ISO 8601); default the TLE's epoch")
    ap.add_argument("--bc", type=float, default=130.0,
                    help="ballistic coefficient, kg/m^2 (default 130, the ISS's; 0 for no drag)")
    ap.add_argument("--attitude", choices=("lvlh", "inertial"), default="lvlh",
                    help="lvlh: +X along the velocity, +Z nadir (the ISS's); inertial: held "
                         "as identity -- edit the line for another")
    ap.add_argument("--port", help="X,Y,Z: a docking port's face in the vehicle's body, m (axis +X)")
    args = ap.parse_args()
    port = ""
    if args.port:
        try:
            xyz = [float(x) for x in args.port.split(",")]
        except ValueError:
            xyz = []
        if len(xyz) != 3:
            sys.exit("tle_target: --port wants X,Y,Z in metres")
        port = " port %g %g %g" % tuple(xyz)
    try:
        from skyfield.api import EarthSatellite, load
    except ImportError:
        sys.exit("tle_target: pip install skyfield")
    sets = read_sets(args.tle)
    if not sets:
        sys.exit("tle_target: no element lines in %s" % args.tle)
    ts = load.timescale()
    sats = [EarthSatellite(l1, l2, name, ts) for l1, l2, name in sets]
    if args.at:
        when = datetime.datetime.fromisoformat(args.at).replace(tzinfo=datetime.timezone.utc)
        t = ts.from_datetime(when)
        sat = min(sats, key=lambda s: abs(s.epoch.tt - t.tt))
    else:
        sat = sats[-1]
        t = sat.epoch
    g = sat.at(t)
    r, v = g.position.m, g.velocity.m_per_s
    unix = (t.utc_datetime() - datetime.datetime(1970, 1, 1, tzinfo=datetime.timezone.utc)).total_seconds()
    att = "lvlh" if args.attitude == "lvlh" else "inertial 1 0 0 0"
    print("# %s, TLE epoch %s, state at %s UTC" % (sat.name or "NORAD %d" % sat.model.satnum,
                                                  sat.epoch.utc_iso(), t.utc_iso()))
    print("target %d %.3f %.3f %.3f %.3f %.6f %.6f %.6f %s bc %g%s"
          % (sat.model.satnum, unix, r[0], r[1], r[2], v[0], v[1], v[2], att, args.bc, port))


if __name__ == "__main__":
    main()
