#!/usr/bin/env python3
"""A prepared vehicle seen from six points round a fly-around, as one
contact sheet: for checking a model.

    python3 portview/vehicles/preview.py KEY [--range M] [--out FILE.png]

Each frame is portview's overhead view, --test flyaround at the range given
(default: 2.5 x the model's size), in daylight, at 0, 60, ... 300 deg round
the circle (0: from ahead on the +V-bar; 90: from below, looking up at the
vehicle's nadir side ... the fly-around's own sense).
"""
import argparse
import json
import os
import subprocess
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("key")
    ap.add_argument("--range", type=float)
    ap.add_argument("--out")
    ap.add_argument("--size", type=int, default=360)
    ap.add_argument("--vehicle", action="append", default=[],
                    help="portview's --vehicle: a variant to draw (e.g. hst1990)")
    a = ap.parse_args()
    from PIL import Image, ImageDraw
    d = os.path.join(PANEL, "portview", "cache", "models", a.key)
    z = np.load(os.path.join(d, "model.npz"))
    meta = json.load(open(os.path.join(d, "model.json")))
    pts = np.vstack([z['pos%d' % k] for k in range(len(meta['materials']))])
    size = float(np.max(pts.max(0) - pts.min(0)))
    rng = a.range or max(8.0, 2.5 * size)
    tmp = tempfile.mkdtemp()
    frames = []
    for deg in (0, 60, 120, 180, 240, 300):
        pre = os.path.join(tmp, "f%d" % deg)
        subprocess.run([sys.executable, os.path.join(PANEL, "portview.py"), "--test", "flyaround",
                        "--test-target", a.key, "--test-range", "%g" % rng, "--test-lap", "1e9",
                        "--test-phase", "%g" % deg,
                        "--test-date", "2011-05-18T08:30", "--test-lon", "-30", "--views", "up",
                        "--size", str(a.size), "--snapshot", pre]
                       + [x for v in a.vehicle for x in ("--vehicle", v)],
                       cwd=PANEL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        f = pre + "-up.png"
        im = Image.open(f).convert("RGB") if os.path.exists(f) else Image.new("RGB", (a.size * 2, a.size * 2))
        ImageDraw.Draw(im).text((10, im.size[1] - 24), "%s  %d deg  %g m" % (a.key, deg, rng),
                                fill=(255, 255, 0))
        frames.append(im)
    w, h = frames[0].size
    sheet = Image.new("RGB", (3 * w, 2 * h))
    for i, im in enumerate(frames):
        sheet.paste(im, ((i % 3) * w, (i // 3) * h))
    out = a.out or os.path.join(tmp, "%s-sheet.png" % a.key)
    sheet.save(out)
    print(out)


if __name__ == "__main__":
    main()
