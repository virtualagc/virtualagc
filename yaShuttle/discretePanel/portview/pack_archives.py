#!/usr/bin/env python3
"""MAINTAINER'S tool: pack portview's prepared assets into the two downloads kept on www.ibiblio.org/apollo.

  portview-essential.7z   what portview cannot run without, and what any STS-134 flight needs: the star catalogue, the
                          ephemeris, the land/water mask, the night lights, every vehicle model (the ISS among them) and
                          the launch gantry, and KSC's imagery (sites/ksc: the pads and runways of the launch and RTLS flights).
                          Small; with it alone portview shows the stars, a flat land-and-water Earth, and KSC in detail.
  portview-optional.7z    the large pictures: the Milky Way, the twelve Blue Marble months and the sites' imagery.

Both are made from yaShuttle/discretePanel (the paths are those portview looks in), each member stored under its own
path, so that unpacking in yaShuttle/discretePanel puts everything in place.  Most users' unpackers make a folder named for
the archive (portview-essential/); portview.py moves its contents into place.

  python3 portview/pack_archives.py [--out DIR] [--dry-run]

Writes DIR/portview-essential.7z, DIR/portview-optional.7z and DIR/portview-archives.json (size and SHA-256 of each, and
the files in each).  Needs the `7z` program; it is not needed by anyone who only downloads the archives.
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)                              # yaShuttle/discretePanel
ESSENTIAL_FILES = ["portview/cache/hipparcos.npy", "portview/cache/de440s.bsp", "portview/cache/watermask.png",
                   "portview/cache/nightlights.jpg", "portview/cache/README.txt"]
ESSENTIAL_DIRS = ["portview/cache/models",                # every vehicle model, the ISS and the gantry
                  "portview/cache/sites/ksc"]             # KSC: where STS-134 launched and where the RTLS flights land


def members():
    """(essential, optional): lists of paths relative to ROOT, every file under portview/cache once."""
    essential = [f for f in ESSENTIAL_FILES if os.path.exists(os.path.join(ROOT, f))]
    cache = os.path.join(ROOT, "portview", "cache")
    allfiles = []
    for dp, dn, fn in os.walk(cache):
        for f in fn:
            allfiles.append(os.path.relpath(os.path.join(dp, f), ROOT))
    ess = set(essential)
    for d in ESSENTIAL_DIRS:
        ess |= {f for f in allfiles if f.startswith(d + "/")}
    return sorted(ess), sorted(set(allfiles) - ess)


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0], formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=os.path.join(ROOT, "local", "archives"))
    ap.add_argument("--dry-run", action="store_true", help="list what each archive would hold, and its size")
    a = ap.parse_args()
    essential, optional = members()
    for need in ("portview/cache/hipparcos.npy", "portview/cache/de440s.bsp", "portview/cache/watermask.png"):
        if need not in essential:
            sys.exit("pack_archives: %s is not in %s" % (need, ROOT))
    # the repository's own small textures/ files (adi_ball.png, LICENSE.md) are in git, not in either archive
    out = {}
    for name, files in (("portview-essential.7z", essential), ("portview-optional.7z", optional)):
        size = sum(os.path.getsize(os.path.join(ROOT, f)) for f in files)
        print("%-24s %5d files, %8.1f MB before compression" % (name, len(files), size / 1e6))
        out[name] = {"files": files, "bytes": size}
    if a.dry_run:
        return
    os.makedirs(a.out, exist_ok=True)
    for name, d in out.items():
        path = os.path.join(a.out, name)
        if os.path.exists(path):
            os.unlink(path)
        listing = path + ".list"
        with open(listing, "w") as f:
            f.write("\n".join(d["files"]) + "\n")
        r = subprocess.run(["7z", "a", "-t7z", "-mx=5", "-y", path, "@" + listing], cwd=ROOT,
                           stdout=subprocess.DEVNULL)
        os.unlink(listing)
        if r.returncode != 0:
            sys.exit("pack_archives: 7z failed on %s" % name)
        d["archiveBytes"], d["sha256"] = os.path.getsize(path), sha256(path)
        print("wrote %s: %.1f MB, sha256 %s" % (path, d["archiveBytes"] / 1e6, d["sha256"]))
    with open(os.path.join(a.out, "portview-archives.json"), "w") as f:
        json.dump(out, f, indent=1)


if __name__ == "__main__":
    main()
