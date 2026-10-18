#!/usr/bin/env python3
"""The propellant along a run: every capture's RCS and OMS tanks, in GMT order, with the checks that catch a bad correction.

Usage: propellant_table.py DIR [DIR ...]       (run directories holding sts134r-* / sts134-* captures)

For each capture: GMT, forward / left / right RCS and left / right OMS in lb, and the mass.  Flags
  INCREASED  a tank gained propellant from the previous capture (carry-over broken, or a correction applied mid-run)
  START      the first capture's RCS against a fresh start's (fly_rndz134.ascent_end_state: 1546 / 2109 / 2107 lb,
             OMS 4179 / 4096 lb; the loads 1906.6 / 2486.6 / 2485.5, OMS 12361 / 12347 less the ascent's own use
             and the estimated FD1-3 use PRESTART_EXTRA_RCS_LB): a lineage that starts elsewhere has been
             corrected differently, and a further correction must be the DIFFERENCE, not the whole (ledger #309:
             snapfix was given the whole one and took the 250/300/300 lb off twice).
"""
import glob
import json
import os
import sys

LB = 0.45359237
FRESH = (1546, 2109, 2107, 4179, 4096)


def main(dirs):
    rows = []
    for d in dirs:
        for f in glob.glob(os.path.join(d, "sts134*-*", "vehdyn.json")) + glob.glob(os.path.join(d, "*", "sts134*-*", "vehdyn.json")):
            try:
                v = json.load(open(f))["vehdyn"]
                rows.append((v[126], os.sep.join(os.path.dirname(f).split(os.sep)[-2:]), [round(x / LB) for x in v[16:21]],
                             round(v[167] + sum(v[16:21])) if len(v) > 167 else None))
            except (OSError, ValueError, KeyError, IndexError):
                pass
    rows.sort()
    prev = None
    for g, name, p, m in rows:
        flag = ""
        if prev and any(p[i] > prev[i] + 1 for i in range(5)):
            flag = "  INCREASED"
        print("GMT %9.0f %-42s F/L/R %5d %5d %5d  OMS L/R %5d %5d  %s kg%s" % (g, name, *p, m, flag))
        prev = p
    if rows:
        p = rows[0][2]
        print("first capture vs a fresh start (%s): %s" % (FRESH[:3], [p[i] - FRESH[i] for i in range(3)]))


if __name__ == "__main__":
    main(sys.argv[1:] or ["."])
