#!/usr/bin/env python3
"""Download and prepare portview's large inputs into portview/cache/.

    python3 portview/fetch_assets.py [--keep-downloads]

The cache is git-ignored; run this once per clone (it skips whatever is
already prepared).  Each item is downloaded, converted to the compact form
portview.py loads, and the download deleted unless --keep-downloads.

  milkyway_8k.npy   NASA SVS 4851 "Deep Star Maps 2020", milkyway_2020_8k.exr:
                    the sky's diffuse light (Gaia DR2) with the Hipparcos and
                    Tycho-2 stars taken out, plate carree in J2000 right
                    ascension and declination, centred on 0h, RA increasing to
                    the left.  Linear radiance, kept as float16 RGB.
  de440s.bsp        JPL planetary ephemeris DE440s (1849-2150), read by
                    Skyfield for the Sun, Moon and planets; used as downloaded.
  hipparcos.npy     ESA Hipparcos main catalogue (CDS I/239, hip_main.dat): RA,
                    Dec (ICRS, epoch J1991.25), proper motions, V magnitude and
                    B-V of ~118,000 stars, drawn by portview as points.
"""
import argparse
import os
import sys
import urllib.request

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")

SVS = "https://svs.gsfc.nasa.gov/vis/a000000/a004800/a004851/"
MILKYWAY_URL = SVS + "milkyway_2020_8k.exr"
HIPPARCOS_URL = "https://cdsarc.cds.unistra.fr/ftp/I/239/hip_main.dat"
DE440S_URL = "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de440s.bsp"

MILKYWAY = os.path.join(CACHE, "milkyway_8k.npy")
HIPPARCOS = os.path.join(CACHE, "hipparcos.npy")
DE440S = os.path.join(CACHE, "de440s.bsp")

STAR_DTYPE = np.dtype([('ra', 'f8'), ('dec', 'f8'), ('pmra', 'f4'), ('pmdec', 'f4'),
                       ('vmag', 'f4'), ('bv', 'f4')])


def download(url, path):
    if os.path.exists(path):
        return path
    part = path + ".part"
    print("fetching", url)
    with urllib.request.urlopen(url) as r, open(part, "wb") as f:
        total = int(r.headers.get("Content-Length") or 0)
        got = 0
        while True:
            b = r.read(1 << 20)
            if not b:
                break
            f.write(b)
            got += len(b)
            if total:
                print("\r  %5.1f%% of %.0f MB" % (100.0 * got / total, total / 1e6),
                      end="", flush=True)
    print()
    os.replace(part, path)
    return path


def prepare_milkyway(keep):
    if os.path.exists(MILKYWAY):
        return
    try:
        import OpenEXR
    except ImportError:
        sys.exit("fetch_assets: pip install OpenEXR (needed once, to convert the map)")
    exr = download(MILKYWAY_URL, os.path.join(CACHE, "milkyway_2020_8k.exr"))
    print("converting", os.path.basename(exr))
    with OpenEXR.File(exr) as f:
        ch = f.channels()
        if "RGB" in ch:
            rgb = np.asarray(ch["RGB"].pixels)
        else:
            rgb = np.stack([np.asarray(ch[c].pixels) for c in "RGB"], axis=-1)
    np.save(MILKYWAY, np.ascontiguousarray(rgb, dtype=np.float16))
    if not keep:
        os.remove(exr)


def prepare_hipparcos(keep):
    if os.path.exists(HIPPARCOS):
        return
    dat = download(HIPPARCOS_URL, os.path.join(CACHE, "hip_main.dat"))
    print("converting", os.path.basename(dat))
    rows = []
    with open(dat, encoding="latin-1") as f:
        for line in f:
            h = line.split("|")
            try:
                ra, dec, vmag = float(h[8]), float(h[9]), float(h[5])
            except (ValueError, IndexError):
                continue
            pmra = float(h[12]) if h[12].strip() else 0.0
            pmdec = float(h[13]) if h[13].strip() else 0.0
            bv = float(h[37]) if h[37].strip() else 0.6
            rows.append((ra, dec, pmra, pmdec, vmag, bv))
    np.save(HIPPARCOS, np.array(rows, dtype=STAR_DTYPE))
    print("  %d stars" % len(rows))
    if not keep:
        os.remove(dat)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--keep-downloads", action="store_true",
                    help="keep the original downloads beside the prepared files")
    args = ap.parse_args()
    os.makedirs(CACHE, exist_ok=True)
    download(DE440S_URL, DE440S)
    prepare_hipparcos(args.keep_downloads)
    prepare_milkyway(args.keep_downloads)
    print("portview assets ready in", CACHE)


if __name__ == "__main__":
    main()
