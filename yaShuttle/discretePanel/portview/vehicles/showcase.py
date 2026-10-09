#!/usr/bin/env python3
"""Every prepared vehicle in turn, a fly-around each, in portview's
overhead and forward views; then the ISS approach to PMA-2.

    python3 portview/vehicles/showcase.py [--seconds S] [--rate X] [--only KEY,...]

Each lap takes S wall seconds (default 150) at --rate times real time
(default 12); the range is 2.5 x the vehicle's size.  Ctrl+C stops it.
"""
import argparse
import json
import os
import signal
import subprocess
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
MODELS = os.path.join(PANEL, "portview", "cache", "models")


def vehicles():
    out = []
    for key in sorted(os.listdir(MODELS)):
        try:
            meta = json.load(open(os.path.join(MODELS, key, "model.json")))
        except (OSError, ValueError):
            continue
        if not meta.get('norad'):
            continue
        z = np.load(os.path.join(MODELS, key, "model.npz"))
        pts = np.vstack([z['pos%d' % k] for k in range(len(meta['materials']))])
        out.append((key, meta['name'], float(np.max(pts.max(0) - pts.min(0)))))
    return out


def run(args, seconds):
    p = subprocess.Popen([sys.executable, os.path.join(PANEL, "portview.py")] + args, cwd=PANEL,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        p.wait(timeout=seconds)
    except subprocess.TimeoutExpired:
        p.send_signal(signal.SIGTERM)
        p.wait()


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--seconds", type=float, default=150.0)
    ap.add_argument("--rate", type=float, default=12.0)
    ap.add_argument("--only", help="these keys only, comma-separated")
    ap.add_argument("--size", type=int, default=640)
    a = ap.parse_args()
    only = set(a.only.split(",")) if a.only else None
    common = ["--test-date", "2011-05-18T08:30", "--test-lon", "-30", "--views", "up,front",
              "--size", str(a.size), "--test-rate", "%g" % a.rate]
    for key, name, size in vehicles():
        if only and key not in only:
            continue
        rng = max(8.0, 2.5 * size)
        print("%s  %s (%s), fly-around at %.0f m" % (time.strftime("%H:%M:%S"), name, key, rng), flush=True)
        run(["--test", "flyaround", "--test-target", key, "--test-range", "%g" % rng,
             "--test-lap", "%g" % (a.seconds * a.rate)] + common, a.seconds + 15)
    if not only or 'iss' in only:
        print("%s  the ISS: approach on the +V-bar to PMA-2, then station-keeping" % time.strftime("%H:%M:%S"),
              flush=True)
        run(["--test", "vbar", "--test-approach", "400", "--test-range", "20"] + common,
            a.seconds * 2 + 15)
    print("%s  done" % time.strftime("%H:%M:%S"))


if __name__ == "__main__":
    main()
