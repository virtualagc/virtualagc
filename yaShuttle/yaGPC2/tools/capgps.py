#!/usr/bin/env python3
"""Is PASS still taking GPS in a capture?  capgps.py CAPDIR [CAPDIR ...]

A capture whose GPS has stopped carries a navigation state that is only IMU-propagated from the last accepted fix, and
an entry flown from it arrives at TAEM thousands of feet off (6-9 kft low in altitude), then dives -- the gear-up
landings of ledger #316 / the stale-GPS entry.  This reads CGPV_T_GPS_NEW (the last accepted fix) and CGMV_IMU_TIME_LFE
from the capture's gpc1.mem.bin through pasvar.py and says FRESH (age under 5 s) or STALE.  Exit status 1 if any STALE.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def times(capdir):
    run = subprocess.run([sys.executable, os.path.join(HERE, "pasvar.py"), "--config", "G3",
                          os.path.join(capdir, "gpc1.mem.bin"), "CGPV_T_GPS_NEW$(1)", "CGMV_IMU_TIME_LFE"],
                         capture_output=True, text=True)
    out = run.stdout
    if run.returncode != 0 and run.stderr.strip():
        print("pasvar.py failed (it needs the SDF library, see its usage):\n  " + run.stderr.strip().splitlines()[-1])
    got = {}
    for line in out.splitlines():
        m = re.match(r"\s+(CG\w+)(?:\$\(1\))?\s+@\w+\s+.*?\s(-?\d+\.\d+)\s*$", line)
        if m:
            got[m.group(1)] = float(m.group(2))
    return got.get("CGPV_T_GPS_NEW"), got.get("CGMV_IMU_TIME_LFE")


def main(argv):
    bad = 0
    for d in argv:
        gps, imu = times(d)
        if gps is None or imu is None:
            print("%s: could not read the GPS and IMU times" % d)
            bad = 1
            continue
        age = imu - gps
        stale = age > 5.0
        bad |= stale
        print("%s: GPS %s (last fix %.1f s, IMU %.1f s, age %.1f s)" % (d, "STALE" if stale else "FRESH", gps, imu, age))
    return bad


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]) if len(sys.argv) > 1 else print(__doc__))
