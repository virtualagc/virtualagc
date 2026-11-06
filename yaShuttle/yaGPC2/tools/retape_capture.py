#!/usr/bin/env python3
"""A CAPTURE MOVED TO ANOTHER VOLUME: the resident memory a load from that volume would have produced.

    tools/retape_capture.py --to NEW.mmv --capture DIR --config G1 [--config G16 ...] --spec FILE.json [--spec ...] [--dry-run]

simulatePASS refuses a capture on any volume but the one it was taken with, because PASS reads mass memory at every
OPS transition and the resident memory is the volume's load.  The volumes our flights use are the generic one plus
cells from tools/sites/sts134-*-iloads.json (tools/mission_reconfig.py), which are known BY ADDRESS and configuration.
So moving a capture to a volume that holds more of them is: put those cells in the capture's memory, and change
the volume it records.

A cell of a --spec whose "config" is one of the --config is set only if memory holds its "was" value (the value the
volume was built from) or already the new one; anything else was changed by the flight software since it was loaded,
or the configuration is not resident, and is left and counted.  The count is printed: a retape that leaves a large
share unset has not moved the capture.
"""
import argparse
import hashlib
import json
import os
import re
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mission_reconfig import encode                # noqa: E402


def digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--to", required=True, dest="new")
    ap.add_argument("--capture", required=True)
    ap.add_argument("--config", action="append", required=True)
    ap.add_argument("--spec", action="append", required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    cfgs = set(a.config)
    for mf in sorted(f for f in os.listdir(a.capture) if re.match(r"gpc\d+\.mem\.bin$", f)):
        path = os.path.join(a.capture, mf)
        M = np.frombuffer(open(path, "rb").read(), dtype=">u2").astype(np.int64)
        for sp in a.spec:
            cells = [c for c in json.load(open(sp))["cells"] if c.get("config") in cfgs]
            setn = same = skip = 0
            for c in cells:
                key = next(k for k in ("E", "D", "H") if k in c)
                new = [int(x) for x in encode(c, c[key])]
                was = [int(x) for x in encode(c, c["was"])]
                at = int(c["addr"], 16)
                cur = [int(x) for x in M[at:at + len(new)]]
                if cur == new:
                    same += 1
                elif cur == was:
                    M[at:at + len(new)] = new
                    setn += 1
                else:
                    skip += 1
            print("%s: %-28s %5d cells set, %5d already new, %5d left (not resident or changed since loading)"
                  % (mf, os.path.basename(sp), setn, same, skip))
        if not a.dry_run:
            open(path, "wb").write(M.astype(">u2").tobytes())
    if not a.dry_run:
        vj = os.path.join(a.capture, "vehicle.json")
        v = json.load(open(vj))
        v["tapeSha256"] = digest(a.new)
        v["tape"] = os.path.abspath(a.new)
        json.dump(v, open(vj, "w"), indent=1)
        print("recorded volume", a.new)


if __name__ == "__main__":
    main()
