#!/usr/bin/env python3
"""Build fly_return.py's starting capture: the Orbiter on STS-134's deorbit day.

    make_return_start.py --sep3 DIR/sts134r-sep3 --out DIR2 --tape VOLUME --targets FILE
                         [--utc 2011-06-01T03:50:00] [--port-base N] [--rate 3]

From the SEP3 capture (150/08:41, the end of fly_undock.py's re-rendezvous) to DIR2/sts134r-ready, the
capture fly_return.py --from ORBIT restores:
  1. a fresh PASS booted at --utc (fly_rndz134.py --start-utc ... --to UPLINK; the START_REL it needs is a
     dummy -- the physics is replaced) -- its clock is the timing unit's, which no edit of a capture gives
     (ledger #308);
  2. the SEP3 physics (the Orbiter, the ISS, the tanks) carried to that capture's GMT by yaGPC2/build/vehdyn_coast
     (nothing fires: the FCS checkout, RCS hot-fire, RAMBO and the dumps are not flown);
  3. orbit_overlay.py puts it on the fresh capture, with the tanks and the mass of the Mission Report (see the
     comment in main()), not the simulation's residuals.
The coast needs the built tool: cc -O2 -std=c11 -o build/vehdyn_coast tools/vehdyn_coast.c src/vehdyn.c
src/physics.c src/envcache.c src/eiumodel.c src/mecmodel.c -lm -pthread (from yaShuttle/yaGPC2).
"""
import argparse
import calendar
import json
import os
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
YAGPC2 = os.environ.get("YAGPC2_DIR") or os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(HERE))), "yaGPC2")
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(YAGPC2, "tools"))
import undock_coast        # noqa: E402
import orbit_overlay       # noqa: E402

LB_KG = 0.45359237


def unix_of(utc):
    return calendar.timegm(time.strptime(utc, "%Y-%m-%dT%H:%M:%S"))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--sep3", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--tape", required=True); ap.add_argument("--targets", required=True)
    ap.add_argument("--utc", default="2011-06-01T03:50:00")
    ap.add_argument("--port-base", type=int, default=45800); ap.add_argument("--rate", default="3")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    boot = os.path.join(a.out, "boot")
    if not os.path.isdir(os.path.join(boot, "sts134r-uplink")):
        env = dict(os.environ, YAGPC_VEHDYN_START_REL="25544,-1524,0,0,0,0,0,%.3f" % unix_of(a.utc),
                   NSTS_NO_AUDIO="1", PYTHONUNBUFFERED="1")
        cmd = [sys.executable, "-u", os.path.join(HERE, "fly_rndz134.py"), "--logs", boot, "--tape", a.tape,
               "--targets", a.targets, "--start-utc", a.utc, "--to", "UPLINK", "--rate", a.rate,
               "--port-base", str(a.port_base)]
        print("booting a fresh PASS at %s: %s" % (a.utc, " ".join(cmd)), flush=True)
        subprocess.run(cmd, env=env, check=True, stdout=open(os.path.join(a.out, "boot.out"), "w"), stderr=subprocess.STDOUT)
    base = os.path.join(boot, "sts134r-uplink")
    gmt_unix = json.load(open(os.path.join(base, "capture.json")))["gmtUnix"]
    src_v = json.load(open(os.path.join(a.sep3, "vehdyn.json")))["vehdyn"]
    src_unix = 1293840000.0 + src_v[126] - 86400.0
    secs = gmt_unix - src_unix
    print("SEP3 physics at unix %.1f, the fresh capture at %.1f: coasting %.0f s (%.1f h)" % (src_unix, gmt_unix, secs, secs / 3600.0))
    coasted = os.path.join(a.out, "coasted")
    if os.path.exists(coasted):
        shutil.rmtree(coasted)
    d = undock_coast.coast(a.sep3, secs, coasted, a.targets)
    v = d["vehdyn"]
    # THE TANKS AND THE MASS ARE THE REPORT'S, not the simulation's residuals from the legs before it (owner,
    # 2026-10-18: the pre-ISS and post-ISS runs are independent, and runs differ from one another so that no
    # set of them gives a unique value; c1's off-nominal chain left the forward RCS EMPTY at SEP3 and the
    # deorbit burn then never happened -- no forward jets, no maneuver to burn attitude).
    #   forward RCS  ~167 lb before its dump (STS-133's four-jet dump rate, 3.05 lb/s a jet, applied to STS-134's
    #                11.04 s: 135 lb, and the 32 lb landing residual; ledger #302)
    #   left, right  the landing residuals 1,081 and 1,048 lb (MR p. 43) plus ~250 lb each for the entry's use
    #                (an ESTIMATE: no figure in the report)
    #   OMS          loaded less the burns to the deorbit: 4,271 / 4,391 lb (phase0-notes item 9)
    #   mass         the landing weight 204,463 lb (Missions Summary A-9) + the deorbit burn 6,103 lb + the
    #                entry RCS (~500 lb) + the forward dump (135 lb) = 211,201 lb
    prop_lb = [167.0, 1081.0 + 250.0, 1048.0 + 250.0, 4271.0, 4391.0]
    prop_kg = [x * LB_KG for x in prop_lb]
    mass = 211201.0 * LB_KG
    mass0 = v[167] + sum(v[16:21])
    print("the simulation's own SEP3 tanks (lb) %s, mass %.0f kg -- NOT used; the report's: %s lb, %.0f kg"
          % ([round(x / LB_KG) for x in v[16:21]], mass0, prop_lb, mass))
    out = os.path.join(a.out, "sts134r-ready")
    if os.path.exists(out):
        shutil.rmtree(out)
    rec = orbit_overlay.overlay(coasted, out, base, mass_kg=mass, prop_kg=prop_kg)
    print(json.dumps(rec))
    for f in os.listdir(os.path.join(boot)):
        if f.endswith(".json") and not os.path.exists(os.path.join(a.out, f)):
            shutil.copy(os.path.join(boot, f), a.out)
    print("done: %s" % out)


if __name__ == "__main__":
    main()
