#!/usr/bin/env python3
"""Download and prepare portview's large inputs into portview/cache/.

    python3 portview/fetch_assets.py [--keep-downloads] [--months 1,2,...]

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
  bluemarble_MM.jpg NASA Blue Marble Next Generation (2004), month MM: the
                    cloud-free Earth by day, without relief shading or
                    bathymetry, 21600x10800 cut to 16384x8192 (the largest GL
                    texture).  portview loads the flight's month.  All twelve
                    by default (~275 MB to download), or --months.
  nightlights.jpg   NASA Black Marble 2016 (3 km): the city lights alone, its
                    blue moonlit-land base taken out, 8192x4096.
  watermask.png     Where there is water (oceans, seas, lakes; 0-255 by
                    coverage), from the GEBCO bathymetry and elevation maps NASA
                    publishes on Blue Marble's own grid, 8192x4096: for sun
                    glint, with coastlines that stay smooth when magnified.
"""
import argparse
import os
import ssl
import sys
import urllib.request

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")

SVS = "https://svs.gsfc.nasa.gov/vis/a000000/a004800/a004851/"
MILKYWAY_URL = SVS + "milkyway_2020_8k.exr"
HIPPARCOS_URL = "https://cdsarc.cds.unistra.fr/ftp/I/239/hip_main.dat"
DE440S_URL = "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de440s.bsp"
BMNG = ("https://assets.science.nasa.gov/content/dam/science/esd/eo/images/bmng/"
        "bmng-base/%s/world.2004%02d.3x21600x10800.jpg")
MONTHS = ("january", "february", "march", "april", "may", "june", "july",
          "august", "september", "october", "november", "december")
BATHYMETRY_URL = ("https://assets.science.nasa.gov/content/dam/science/esd/eo/images/bmng/"
                  "bathymetry/gebco_08_rev_bath_21600x10800.jpg")
ELEVATION_URL = ("https://assets.science.nasa.gov/content/dam/science/esd/eo/images/bmng/"
                 "topography/gebco_08_rev_elev_21600x10800.jpg")
BLACKMARBLE_URL = ("https://eoimages.gsfc.nasa.gov/images/imagerecords/144000/144898/"
                   "BlackMarble_2016_3km.jpg")

MILKYWAY = os.path.join(CACHE, "milkyway_8k.npy")
HIPPARCOS = os.path.join(CACHE, "hipparcos.npy")
DE440S = os.path.join(CACHE, "de440s.bsp")
NIGHTLIGHTS = os.path.join(CACHE, "nightlights.jpg")
WATERMASK = os.path.join(CACHE, "watermask.png")
EARTH_SIZE = (16384, 8192)
NIGHT_SIZE = (8192, 4096)


def bluemarble_path(month):
    return os.path.join(CACHE, "bluemarble_%02d.jpg" % month)

STAR_DTYPE = np.dtype([('ra', 'f8'), ('dec', 'f8'), ('pmra', 'f4'), ('pmdec', 'f4'),
                       ('vmag', 'f4'), ('bv', 'f4')])


def download(url, path):
    if os.path.exists(path):
        return path
    part = path + ".part"
    print("fetching", url)
    try:
        # python.org's macOS Python has no certificates of its own until its
        # "Install Certificates" step is run; certifi (Skyfield brings it) does.
        import certifi
        ctx = ssl.create_default_context(cafile=certifi.where())
    except ImportError:
        ctx = None
    with urllib.request.urlopen(url, context=ctx) as r, open(part, "wb") as f:
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


def _image():
    try:
        from PIL import Image
    except ImportError:
        sys.exit("fetch_assets: pip install Pillow")
    Image.MAX_IMAGE_PIXELS = None
    return Image


def prepare_bluemarble(month, keep):
    out = bluemarble_path(month)
    if os.path.exists(out):
        return
    Image = _image()
    src = download(BMNG % (MONTHS[month - 1], month),
                   os.path.join(CACHE, "world.2004%02d.3x21600x10800.jpg" % month))
    print("converting", os.path.basename(src))
    Image.open(src).convert("RGB").resize(EARTH_SIZE, Image.LANCZOS).save(
        out, quality=92, subsampling=0)
    if not keep:
        os.remove(src)


def prepare_nightlights(keep):
    if os.path.exists(NIGHTLIGHTS):
        return
    Image = _image()
    src = download(BLACKMARBLE_URL, os.path.join(CACHE, "BlackMarble_2016_3km.jpg"))
    print("converting", os.path.basename(src))
    a = np.asarray(Image.open(src).convert("RGB").resize(NIGHT_SIZE, Image.LANCZOS),
                   dtype=np.float32)
    # The lights are warm, the base (moonlit land, ice) blue-grey: keep what
    # is yellower than the base, faded in over a few levels.
    warm = 0.5 * (a[..., 0] + a[..., 1]) - 0.9 * a[..., 2]
    k = np.clip((warm - 4.0) / 24.0, 0.0, 1.0)[..., None]
    Image.fromarray(np.clip(a * k, 0, 255).astype(np.uint8)).save(
        NIGHTLIGHTS, quality=92, subsampling=0)
    if not keep:
        os.remove(src)


def prepare_watermask(keep):
    if os.path.exists(WATERMASK):
        return
    Image = _image()
    bath = download(BATHYMETRY_URL, os.path.join(CACHE, "gebco_08_rev_bath_21600x10800.jpg"))
    elev = download(ELEVATION_URL, os.path.join(CACHE, "gebco_08_rev_elev_21600x10800.jpg"))
    print("converting", os.path.basename(bath), "and", os.path.basename(elev))
    # Bathymetry: land exactly 255, the shallowest water 254 (the Bioko
    # channel, the Bahamas banks), deeper darker.  Elevation: water 0, ~25 m a
    # level.  Water needs both; the elevation's JPEG ringing reaches a few
    # levels into the sea along coastlines, hence <= 8 there.
    b = np.asarray(Image.open(bath).convert("L"))
    e = np.asarray(Image.open(elev).convert("L"))
    water = ((b <= 254) & (e <= 8)).astype(np.uint8) * 255
    Image.fromarray(water).resize(NIGHT_SIZE, Image.BOX).save(WATERMASK)
    if not keep:
        os.remove(bath)
        os.remove(elev)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--keep-downloads", action="store_true",
                    help="keep the original downloads beside the prepared files")
    ap.add_argument("--months", default="1,2,3,4,5,6,7,8,9,10,11,12", metavar="LIST",
                    help="the Blue Marble months to prepare (default all twelve)")
    args = ap.parse_args()
    months = [int(m) for m in args.months.split(",") if m.strip()]
    if any(m < 1 or m > 12 for m in months):
        sys.exit("fetch_assets: months are 1-12")
    os.makedirs(CACHE, exist_ok=True)
    download(DE440S_URL, DE440S)
    prepare_hipparcos(args.keep_downloads)
    prepare_milkyway(args.keep_downloads)
    prepare_nightlights(args.keep_downloads)
    prepare_watermask(args.keep_downloads)
    for m in months:
        prepare_bluemarble(m, args.keep_downloads)
    print("portview assets ready in", CACHE)


if __name__ == "__main__":
    main()
