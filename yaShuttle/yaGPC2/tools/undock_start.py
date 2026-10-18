#!/usr/bin/env python3
"""Build the undocking start: STS-134's docked stack at 150/03:52, from a docking capture.

Usage: undock_start.py SOURCE DEST --base FRESH [--gmt 2011-05-30T03:19:40.639]
                       [--targets FILE] [--mass-kg 97376] [--prop-kg F,L,R,OMSL,OMSR]

THE RECIPE (gate runs 1-9, 2026-10-18; ledger #308).  A restored capture whose GMT was
moved by 12 days leaves the flight software's own clock at the capture's time
and nothing in SPEC 2 brings it across, so SOURCE's flight software cannot be
used.  Instead:
  1. a fresh PASS at the date, to the UPLINK phase (about 8 simulated minutes, a
     few real minutes at --rate 3):
       YAGPC_VEHDYN_START_REL=25544,-1524,0,0,0,0,0,<unix of the start> \
       fly_rndz134.py --logs FRESH --tape OI340700-v44boot-sts134-ksc6-rndz2.mmv \
         --targets <any line within 30 days> --start-utc 2011-05-30T03:11:30 --to UPLINK --rate 3
     -> FRESH/sts134r-uplink, its clock (read from its capture.json gmtUnix) the timing unit's
  2. the ISS line for exactly that time: tools/tle_target.py TLEFILE --at ISOTIME --port 15.655,0,5.562
     (the TLEs: forClaude/iss-tle-2011-149-150.txt)
  3. this tool: undock_start.py SOURCE DEST/sts134r-dock --base FRESH/sts134r-uplink
       --gmt <that time> --targets <that line>
  4. examples/flights/undock_gate.py --from GATE restores DEST (as sts134r-dock under
     --logs), uplinks the state vectors and RNDZ NAV ENA, and shows SPEC 2 / SPEC 33.
     Result: MTU ACCUM and GPC GMT equal, orbiter nav error under 15 ft, target 1 ft.

SOURCE is a capture directory taken while the stack was docked (approach-mine's
sts134r-dock); DEST must be new.  The 12 docked days are skipped (owner,
2026-10-18): the vehicle's GMT, the ISS's state and the Orbiter's mass and
propellant are replaced and nothing else is touched -- the flight software's
memory still holds the docking day's time and navigation, which the ground's
uplinks (groundstation.py sv, tsv) replace after the restore.

Changed, and only these (with --base, the flight software, capture.json and
vehicle.json are FRESH's, and vehdyn.json's GMT is FRESH's):
  capture.json  gmtUnix                      the vehicle's GMT, Unix seconds
  vehicle.json  epoch                        moved by the same amount (its
                                             offset from gmtUnix kept)
  vehdyn.json   [126]                        the state's GMT, day*86400+seconds
                [16:21], dryKg [167]         propellant (kg) and dry mass
                targets                      the ISS's epoch, position, velocity
                [3:9]                        the Orbiter's position and velocity,
                                             the old offset from the ISS carried
                                             into the new LVLH frame (docked, the
                                             simulation sets it from the ISS each step)
The ISS stays LVLH, the Orbiter's attitude in it unchanged: the stack is already
in the undocking attitude (tail to the Earth's centre, UNIV PTG TGT ID 2, BODY
VECT 5, P 180, OM 0 -- the VBAR attitude).  Defaults are the notes in
sts134-runs/undock/phase0-notes.txt: Orbiter 97,376 kg (the landing weight
worked back, mean with the liftoff weight worked forward), propellant at
the undock from the Mission Report, targets from sts134-targets-undock.txt.
"""
import argparse, calendar, json, math, shutil, sys
from pathlib import Path

TARGETS = "/mnt/STORAGE/forClaude/mc1/sts134-targets-undock.txt"
PROP_KG = (252.0, 767.0, 766.0, 1937.0, 1992.0)     # F, L, R RCS; L, R OMS
MASS_KG = 97376.0
GMT = "2011-05-30T03:52:00"
IDX_GMT, IDX_DRY, IDX_PROP = 126, 167, 16


def unix_of(text):
    t = text.rstrip("Z")
    d, h = t.split("T")
    y, mo, da = (int(x) for x in d.split("-"))
    hh, mm, ss = (float(x) for x in h.split(":"))
    return calendar.timegm((y, mo, da, 0, 0, 0)) + hh * 3600 + mm * 60 + ss


def vehicle_gmt(unix):
    """The vehicle's [126]: day-of-year * 86400 + seconds of the day."""
    jan1 = calendar.timegm((time_year(unix), 1, 1, 0, 0, 0))
    day = int((unix - jan1) // 86400) + 1
    return day * 86400.0 + (unix - jan1 - (day - 1) * 86400.0)


def time_year(unix):
    import time
    return time.gmtime(unix).tm_year


def read_target(path):
    for line in Path(path).read_text().splitlines():
        w = line.split()
        if len(w) >= 9 and w[0] == "target":
            return int(w[1]), float(w[2]), [float(x) for x in w[3:6]], [float(x) for x in w[6:9]]
    raise ValueError("no target line in %s" % path)


def sub(a, b): return [x - y for x, y in zip(a, b)]
def add(a, b): return [x + y for x, y in zip(a, b)]
def dot(a, b): return sum(x * y for x, y in zip(a, b))
def cross(a, b): return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]
def unit(a):
    n = math.sqrt(dot(a, a))
    return [x / n for x in a]


def lvlh(r, v):
    """Rows: x along the track, y the negative orbit normal, z down."""
    z = unit([-c for c in r])
    y = unit([-c for c in cross(r, v)])
    x = cross(y, z)
    return [x, y, z]


def to_frame(F, a): return [dot(row, a) for row in F]
def from_frame(F, a): return [sum(F[k][i] * a[k] for k in range(3)) for i in range(3)]


def build(src, dst, gmt, targets, mass_kg, prop_kg, base=None):
    src, dst = Path(src).resolve(), Path(dst).resolve()
    if not src.is_dir() or dst.exists():
        raise ValueError("SOURCE must be a directory and DEST must not exist")
    cap = json.loads((src / "capture.json").read_text())
    veh = json.loads((src / "vehicle.json").read_text())
    vd = json.loads((src / "vehdyn.json").read_text())
    v = vd["vehdyn"]
    t = vd["targets"]
    if len(v) < IDX_DRY + 1 or v[IDX_GMT] < 1e6 or t[0] != -2:
        raise ValueError("unexpected vehdyn.json layout (version, GMT or targets)")
    if not (v[-33] == -3.0):
        raise ValueError("no docking block at the end of vehdyn.json")
    if int(v[-32]) != 1:
        raise ValueError("SOURCE is not a docked capture (dock.state %d)" % int(v[-32]))
    norad, epoch, r_new, v_new = read_target(targets)
    if int(t[1]) != norad:
        raise ValueError("target %d in the capture, %d in %s" % (int(t[1]), norad, targets))
    new_unix = unix_of(gmt)
    if abs(new_unix - epoch) > 1.0:
        raise ValueError("target epoch %.1f is not %s (%.1f)" % (epoch, gmt, new_unix))
    old = dict(gmtUnix=cap["gmtUnix"], epoch=veh["epoch"], gmt=v[IDX_GMT], prop=v[IDX_PROP:IDX_PROP + 5],
               dry=v[IDX_DRY], target=t[8:15], orbiter=v[3:9])
    # the Orbiter, relative to the ISS in the old LVLH frame, carried into the new
    r_t, v_t = t[9:12], t[12:15]
    old_F = lvlh(r_t, v_t)
    rel_r = to_frame(old_F, sub(v[3:6], r_t))
    rel_v = to_frame(old_F, sub(v[6:9], v_t))
    new_F = lvlh(r_new, v_new)
    v[3:6] = add(r_new, from_frame(new_F, rel_r))
    v[6:9] = add(v_new, from_frame(new_F, rel_v))
    t[8] = new_unix
    t[9:12], t[12:15] = r_new, v_new
    # the clocks
    shift = new_unix - cap["gmtUnix"]
    cap["gmtUnix"] = new_unix
    veh["epoch"] = veh["epoch"] + shift
    v[IDX_GMT] = vehicle_gmt(new_unix)
    # the mass
    v[IDX_PROP:IDX_PROP + 5] = list(prop_kg)
    v[IDX_DRY] = mass_kg - sum(prop_kg)
    if base:
        # BASE: a capture from a fresh start at GMT (fly_rndz134.py --start-utc ... --to UPLINK).
        # The flight software, its clock and the timing unit are BASE's, so they agree;
        # only the physics (vehdyn.json) is the docked stack's.  The software's
        # memory is not the docking day's, so nothing here edits its clock.
        base = Path(base).resolve()
        bcap = json.loads((base / "capture.json").read_text())
        if abs(bcap["gmtUnix"] - new_unix) > 3600.0:
            raise ValueError("BASE is at %.0f, not within an hour of %s" % (bcap["gmtUnix"], gmt))
        shutil.copytree(base, dst)
        cap, veh = bcap, json.loads((base / "vehicle.json").read_text())
        # the physics' clock is BASE's: the docked state is carried to it
        v[IDX_GMT] = vehicle_gmt(bcap["gmtUnix"])
    else:
        shutil.copytree(src, dst)
    (dst / "capture.json").write_text(json.dumps(cap, indent=2) + "\n")
    (dst / "vehicle.json").write_text(json.dumps(veh, indent=1) + "\n")
    (dst / "vehdyn.json").write_text(json.dumps(vd, indent=2) + "\n")
    record = dict(source=str(src), gmt=gmt, targets=str(targets), mass_kg=mass_kg, prop_kg=list(prop_kg),
                  before=old, after=dict(gmtUnix=new_unix, epoch=veh["epoch"], gmt=v[IDX_GMT], dry=v[IDX_DRY],
                                         orbiter=v[3:9], target=t[8:15]),
                  note="the flight software's memory is the docking day's; uplink sv and tsv after the restore")
    (dst / "undock-start.json").write_text(json.dumps(record, indent=2) + "\n")
    return record


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("source"); p.add_argument("dest")
    p.add_argument("--gmt", default=GMT)
    p.add_argument("--base", help="a fresh capture at GMT whose flight software and clocks are kept")
    p.add_argument("--targets", default=TARGETS)
    p.add_argument("--mass-kg", type=float, default=MASS_KG)
    p.add_argument("--prop-kg", default=",".join("%g" % x for x in PROP_KG),
                   help="forward, left, right RCS, left, right OMS (kg)")
    a = p.parse_args()
    prop = [float(x) for x in a.prop_kg.split(",")]
    if len(prop) != 5 or a.mass_kg < sum(prop) + 50000.0:
        p.error("--prop-kg takes five amounts and the mass must exceed them by the dry mass")
    try:
        rec = build(a.source, a.dest, a.gmt, a.targets, a.mass_kg, prop, a.base)
    except (ValueError, OSError, KeyError) as e:
        p.error(str(e))
    print(json.dumps(rec, indent=2))


if __name__ == "__main__":
    main()
