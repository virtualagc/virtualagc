#!/usr/bin/env python3
"""Put a coasted vehdyn state on a fresh boot: the free-flying Orbiter, days on.

Usage: orbit_overlay.py SRC DEST --base FRESH [--mass-kg KG] [--prop-kg F,L,R,OL,OR]

SRC is a capture (or the OUT_CAPTURE of examples/flights/undock_coast.py) whose vehdyn.json is the
physics at the same GMT as FRESH's capture -- the coast has carried it there.  FRESH is a capture from
a fresh boot at that date (fly_rndz134.py --start-utc ... --to UPLINK), whose flight software, clock and
timing unit are consistent with each other; DEST is FRESH with SRC's vehdyn.json (the state, the ISS, the
IMU and star-tracker blocks, the tanks) and, where given, the mass and propellant.  Ledger #308: a
restore across a gap in GMT leaves the flight software's clock behind, so the gap is crossed by
booting at the date, not by editing a capture.
"""
import argparse
import json
import shutil
import sys
from pathlib import Path

IDX_GMT, IDX_DRY, IDX_PROP = 126, 167, 16


def vehicle_gmt(unix):
    import calendar
    import time
    year = time.gmtime(unix).tm_year
    jan1 = calendar.timegm((year, 1, 1, 0, 0, 0))
    day = int((unix - jan1) // 86400) + 1
    return day * 86400.0 + (unix - jan1 - (day - 1) * 86400.0)


def overlay(src, dst, base, mass_kg=None, prop_kg=None):
    src, dst, base = Path(src).resolve(), Path(dst).resolve(), Path(base).resolve()
    if dst.exists():
        raise ValueError("DEST exists")
    cap = json.loads((base / "capture.json").read_text())
    vd = json.loads((src / "vehdyn.json").read_text())
    v = vd["vehdyn"]
    want = vehicle_gmt(cap["gmtUnix"])
    if abs(v[IDX_GMT] - want) > 5.0:
        raise ValueError("SRC's physics is at GMT %.1f, FRESH at %.1f: coast SRC to FRESH's time first" % (v[IDX_GMT], want))
    v[IDX_GMT] = want
    if prop_kg:
        v[IDX_PROP:IDX_PROP + 5] = list(prop_kg)
    if mass_kg:
        v[IDX_DRY] = mass_kg - sum(v[IDX_PROP:IDX_PROP + 5])
    shutil.copytree(base, dst)
    (dst / "vehdyn.json").write_text(json.dumps(vd, indent=2) + "\n")
    return dict(gmt=want, mass_kg=v[IDX_DRY] + sum(v[IDX_PROP:IDX_PROP + 5]), prop_kg=v[IDX_PROP:IDX_PROP + 5])


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src"); ap.add_argument("dest"); ap.add_argument("--base", required=True)
    ap.add_argument("--mass-kg", type=float); ap.add_argument("--prop-kg")
    a = ap.parse_args()
    try:
        print(json.dumps(overlay(a.src, a.dest, a.base, a.mass_kg,
                                 [float(x) for x in a.prop_kg.split(",")] if a.prop_kg else None), indent=1))
    except (ValueError, OSError, KeyError) as e:
        sys.exit("orbit_overlay: %s" % e)
