#!/usr/bin/env python3
"""Carry a capture's physics forward in time with nothing firing: STS-134's days between events.

    undock_coast.py SRC_CAPTURE SECONDS OUT_CAPTURE [--targets FILE] [--mass-kg KG] [--prop-kg F,L,R,OL,OR]

SRC_CAPTURE is a capture directory (sts134r-sep3, say).  OUT_CAPTURE is a copy of it whose
vehdyn.json has the Orbiter and the ISS SECONDS later, by yaGPC2/build/vehdyn_coast (the
vehicle's own physics in one go, tools/vehdyn_coast.c): it holds the state only -- the flight
software's memory and clock are the source's, so OUT_CAPTURE is not itself restorable across the
gap.  undock_start.py --base overlays this vehdyn.json on a fresh boot at the new date, as it did
for the 12 docked days (ledger #308).
"""
import argparse
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
YAGPC2 = os.environ.get("YAGPC2_DIR") or os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(HERE))), "yaGPC2")
COAST = os.path.join(YAGPC2, "build", "vehdyn_coast")
LB_KG = 0.45359237


def coast(src, secs, out, targets=None, mass_kg=None, prop_kg=None):
    if os.path.exists(out):
        raise SystemExit("OUT_CAPTURE exists: %s" % out)
    d = json.load(open(os.path.join(src, "vehdyn.json")))
    tmp = out + ".tmp"
    os.makedirs(tmp)
    f = lambda name: os.path.join(tmp, name)
    open(f("v.txt"), "w").write("\n".join("%.17g" % x for x in d["vehdyn"]) + "\n")
    open(f("t.txt"), "w").write("\n".join("%.17g" % x for x in d["targets"]) + "\n")
    cmd = [COAST, f("v.txt"), f("t.txt"), "%.3f" % secs, f("ov.txt"), f("ot.txt")] + ([targets] if targets else [])
    r = subprocess.run(cmd, capture_output=True, text=True)
    sys.stderr.write(r.stderr)
    if r.returncode:
        shutil.rmtree(tmp)
        raise SystemExit("vehdyn_coast failed")
    ov = [float(x) for x in open(f("ov.txt"))]
    ot = [float(x) for x in open(f("ot.txt"))]
    d["vehdyn"] = ov
    d["targets"] = ot
    shutil.copytree(src, out)
    if prop_kg:
        ov[16:21] = list(prop_kg)
    if mass_kg:
        ov[167] = mass_kg - sum(ov[16:21])
    json.dump(d, open(os.path.join(out, "vehdyn.json"), "w"), indent=2)
    shutil.rmtree(tmp)
    return d


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src"); ap.add_argument("secs", type=float); ap.add_argument("out")
    ap.add_argument("--targets"); ap.add_argument("--mass-kg", type=float)
    ap.add_argument("--prop-kg")
    a = ap.parse_args()
    coast(a.src, a.secs, a.out, a.targets, a.mass_kg, [float(x) for x in a.prop_kg.split(",")] if a.prop_kg else None)
