#!/usr/bin/env python3
"""Download and prepare portview's large inputs into portview/cache/.

    python3 portview/fetch_assets.py [--keep-downloads] [--months 1,2,...]
                                     [--sites ksc,...]

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
  sites/SITE/       Nested images centred on a landing site, where the views
                    come close to the ground (entry, approach, landing, and the
                    pad at launch), each 8192 x 8192 in geodetic latitude and
                    longitude, with ring.json giving their bounds:
                      ring0.jpg  +-4 km,    ~1 m:   USDA NAIP (USGS National Map;
                                 US sites only), public domain
                      ring1.jpg  +-40 km,   ~10 m:  Sentinel-2 cloudless 2016
                      ring2.jpg  +-400 km,  ~100 m: the same
                      ring3.jpg  +-2000 km, ~500 m: the same
                    Sentinel-2 cloudless - https://s2maps.eu by EOX IT Services
                    GmbH (Contains modified Copernicus Sentinel data 2016),
                    CC BY 4.0.  Each ring's colours are matched to the next
                    coarser one's, so the seams between them don't show.
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


# Landing sites: the centre of the rings (the runway's midpoint), from the
# navaids file yaGPC2's tools/landing_sites.py writes (geodetic, PASS's
# ellipsoid), and the ground's height there (ft, the runway threshold's).
SITES = {
    'ksc': dict(name="KSC Shuttle Landing Facility", lat=28.61489, lon=-80.69437,
                alt_ft=8.3, naip=True),
}
RINGS = ((4.0, 'naip'), (40.0, 's2'), (400.0, 's2'), (2000.0, 's2'))   # half-size, km
RING_PX = 8192

NAIP_URL = ("https://imagery.nationalmap.gov/arcgis/rest/services/USGSNAIPImagery/ImageServer/"
            "exportImage?bbox=%.7f,%.7f,%.7f,%.7f&bboxSR=4326&imageSR=4326&size=%d,%d"
            "&format=jpg&f=image")
S2_URL = ("https://tiles.maps.eox.at/wms?service=WMS&request=GetMap&version=1.1.1"
          "&layers=s2cloudless&styles=&srs=EPSG:4326&bbox=%.7f,%.7f,%.7f,%.7f"
          "&width=%d&height=%d&format=image/jpeg")


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


def ring_bounds(site, half_km):
    """(lon0, lat0, lon1, lat1), degrees: a square of the given half-size."""
    dlat = half_km / 111.32
    dlon = half_km / (111.32 * np.cos(np.radians(site['lat'])))
    return (site['lon'] - dlon, site['lat'] - dlat, site['lon'] + dlon, site['lat'] + dlat)


def fetch_image(url):
    import io
    import certifi
    ctx = ssl.create_default_context(cafile=certifi.where())
    Image = _image()
    for attempt in range(4):
        try:
            with urllib.request.urlopen(url, context=ctx, timeout=300) as r:
                return Image.open(io.BytesIO(r.read())).convert("RGB")
        except Exception as e:                  # noqa: BLE001 -- the services are flaky
            print("  retrying (%s)" % e)
    sys.exit("fetch_assets: could not fetch %s" % url)


def fetch_mosaic(source, bounds, n_tiles):
    """The bounds as one RING_PX-square image, from n_tiles x n_tiles requests."""
    Image = _image()
    lon0, lat0, lon1, lat1 = bounds
    tile = -(-RING_PX // n_tiles)
    out = Image.new("RGB", (RING_PX, RING_PX))
    for j in range(n_tiles):                    # rows, north to south
        for i in range(n_tiles):
            x0, x1 = i * tile, min(RING_PX, (i + 1) * tile)
            y0, y1 = j * tile, min(RING_PX, (j + 1) * tile)
            b = (lon0 + (lon1 - lon0) * x0 / RING_PX, lat1 - (lat1 - lat0) * y1 / RING_PX,
                 lon0 + (lon1 - lon0) * x1 / RING_PX, lat1 - (lat1 - lat0) * y0 / RING_PX)
            w, h = x1 - x0, y1 - y0
            if source == 'naip':
                # The ImageServer keeps its pixels square in degrees, widening
                # the box otherwise: ask for that shape, then resample.
                h = int(round(w * (b[3] - b[1]) / (b[2] - b[0])))
                url = NAIP_URL % (b + (w, h))
            else:
                url = S2_URL % (b + (w, h))
            print("  tile %d,%d" % (i, j), flush=True)
            out.paste(fetch_image(url).resize((x1 - x0, y1 - y0), Image.LANCZOS), (x0, y0))
    return out


def match_colours(child, cb, parent, pb):
    """The child's channels scaled to the parent's mean and spread over the
    child's area, so a ring and the next coarser one meet without a seam."""
    Image = _image()
    lon0, lat0, lon1, lat1 = cb
    plon0, plat0, plon1, plat1 = pb
    pw, ph = parent.size
    box = ((lon0 - plon0) / (plon1 - plon0) * pw, (plat1 - lat1) / (plat1 - plat0) * ph,
           (lon1 - plon0) / (plon1 - plon0) * pw, (plat1 - lat0) / (plat1 - plat0) * ph)
    p = np.asarray(parent.crop(tuple(int(round(v)) for v in box)).resize((512, 512), Image.BOX),
                   dtype=np.float32)
    c = np.asarray(child, dtype=np.float32)
    small = np.asarray(child.resize((512, 512), Image.BOX), dtype=np.float32)
    for k in range(3):
        ms, ss = small[..., k].mean(), small[..., k].std() + 1e-3
        mp, sp = p[..., k].mean(), p[..., k].std() + 1e-3
        c[..., k] = (c[..., k] - ms) * (sp / ss) + mp
    return Image.fromarray(np.clip(c, 0, 255).astype(np.uint8))


def prepare_site(key):
    import json
    site = SITES[key]
    d = os.path.join(CACHE, "sites", key)
    meta_path = os.path.join(d, "ring.json")
    if os.path.exists(meta_path):
        return
    os.makedirs(d, exist_ok=True)
    Image = _image()
    rings = []
    for k, (half_km, source) in enumerate(RINGS):
        if source == 'naip' and not site.get('naip'):
            continue
        b = ring_bounds(site, half_km)
        print("site %s ring %d: +-%g km from %s" % (key, k, half_km, source))
        img = fetch_mosaic(source, b, 3 if source == 'naip' else 2)
        img.save(os.path.join(d, "ring%d.raw.jpg" % k), quality=95)
        rings.append(dict(file="ring%d.jpg" % k, bounds=b, half_km=half_km, source=source))
    # Colours: the coarsest as fetched; each finer one matched to the next.
    for k in range(len(rings) - 1, -1, -1):
        r = rings[k]
        img = Image.open(os.path.join(d, r['file'].replace(".jpg", ".raw.jpg")))
        if k < len(rings) - 1:
            parent = rings[k + 1]
            img = match_colours(img, r['bounds'],
                                Image.open(os.path.join(d, parent['file'])), parent['bounds'])
        img.save(os.path.join(d, r['file']), quality=92, subsampling=0)
        os.remove(os.path.join(d, r['file'].replace(".jpg", ".raw.jpg")))
    with open(meta_path, "w") as f:
        json.dump(dict(site=key, name=site['name'], lat=site['lat'], lon=site['lon'],
                       alt_ft=site['alt_ft'], rings=rings), f, indent=1)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--keep-downloads", action="store_true",
                    help="keep the original downloads beside the prepared files")
    ap.add_argument("--months", default="1,2,3,4,5,6,7,8,9,10,11,12", metavar="LIST",
                    help="the Blue Marble months to prepare (default all twelve)")
    ap.add_argument("--sites", default=",".join(SITES), metavar="LIST",
                    help="the landing sites to prepare imagery for (default %s)" % ",".join(SITES))
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
    for key in [k.strip() for k in args.sites.split(",") if k.strip()]:
        if key not in SITES:
            sys.exit("fetch_assets: no site %r (sites: %s)" % (key, ", ".join(SITES)))
        prepare_site(key)
    print("portview assets ready in", CACHE)


if __name__ == "__main__":
    main()
