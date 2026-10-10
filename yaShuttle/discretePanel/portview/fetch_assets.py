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
                      ring0.jpg  +-4 km,    ~1 m:   USDA NAIP (US sites only), public
                                 domain: the latest flight (USGS National Map), or
                                 a site's naip_year (Microsoft Planetary Computer,
                                 2010 onward) for its era -- KSC's 2010-05-02
                                 flight, the pads as they were for STS-134
                      ring1.jpg  +-40 km,   ~10 m:  Sentinel-2 cloudless 2016
                      ring2.jpg  +-400 km,  ~100 m: the same
                      ring3.jpg  +-2000 km, ~500 m: the same
                      ringF.jpg  +-1.5 km,  ~0.37 m: NAIP again, for the runway
                                 itself at rollout (US sites)
                      patch_NAME.jpg  more fine patches where needed, e.g.
                                 KSC's launch pads 39A and 39B (+-1.2 km, ~0.3 m)
                    Sentinel-2 cloudless - https://s2maps.eu by EOX IT Services
                    GmbH (Contains modified Copernicus Sentinel data 2016),
                    CC BY 4.0.  Each ring's colours are matched to the next
                    coarser one's, so the seams between them don't show.
  models/iss/       The International Space Station as at STS-134 (May 2011),
                    from NASA JSC IGOAL's model (NASA 3D Resources, "ISS (D)
                    (IGOAL)"): the meshes decoded (Draco), in metres in the ISS
                    analysis frame (+X forward through Node 2 and PMA-2, +Y
                    starboard along the truss, +Z nadir), the origin at the S0
                    truss (near the centre of mass), grouped by material, with
                    the base-colour textures as JPEG.  Parts added later (BEAM,
                    Bishop, Nauka, Prichal, the IDAs, iROSAs, later payloads)
                    and STS-134's own cargo (AMS-02, ELC-3) are left out.
                    Needs DracoPy and pygltflib to prepare.
  models/gantry/    Launch Complex 39's pad structures in the Shuttle era (the
                    Fixed and Rotating Service Structures, lightning mast, pad
                    deck), NASA 3D Resources "Gantry": in metres in the pad's
                    east-north-up frame, the origin on the ground under the
                    flame trench's opening (where the stack stands), the Fixed
                    Service Structure to the north.  Untextured.
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
                alt_ft=8.3, naip=True, naip_year=2010,
                # The launch pads' centres (approximate; vehdyn's pad to come).
                patches={'lc39a': (28.60839, -80.60433, 1.2), 'lc39b': (28.62722, -80.62083, 1.2)}),
    # No navaids file yet: the airfield reference points and elevations
    # (approximate; to be taken from tools/sites/*.json when yaGPC2 has them).
    'edw': dict(name="Edwards AFB", lat=34.9056, lon=-117.8836, alt_ft=2302.0, naip=True),
    'nor': dict(name="White Sands Space Harbor (Northrup Strip)", lat=32.9433, lon=-106.4194,
                alt_ft=3880.0, naip=True),
}
RINGS = ((4.0, 'naip'), (40.0, 's2'), (400.0, 's2'), (2000.0, 's2'))   # half-size, km
RING_PX = 8192
FINE_RING = (1.5, 'naip')                     # half-size km: the runway at rollout

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


PC_STAC = "https://planetarycomputer.microsoft.com/api/stac/v1/search"
PC_RENDER = ("https://planetarycomputer.microsoft.com/api/data/v1/item/bbox/%.7f,%.7f,%.7f,%.7f/"
             "%dx%d.png?collection=naip&item=%s&assets=image&asset_bidx=image%%7C1%%2C2%%2C3")


def naip_items(bounds, year):
    """The NAIP photographs of a year over a box (Planetary Computer's catalogue):
    (id, bbox) each."""
    import json
    import certifi
    body = json.dumps(dict(collections=["naip"], bbox=list(bounds),
                           datetime="%d-01-01/%d-12-31" % (year, year), limit=200)).encode()
    req = urllib.request.Request(PC_STAC, data=body, headers={"Content-Type": "application/json"})
    ctx = ssl.create_default_context(cafile=certifi.where())
    with urllib.request.urlopen(req, context=ctx, timeout=120) as r:
        return [(f['id'], f['bbox']) for f in json.load(r)['features']]


def fetch_naip_year(b, w, h, year):
    """One tile, b = (lon0, lat0, lon1, lat1), from a year's NAIP photographs,
    each rendered by the Planetary Computer for the box and laid together by
    their transparency (outside a photograph is transparent)."""
    import io
    import certifi
    Image = _image()
    ctx = ssl.create_default_context(cafile=certifi.where())
    out = Image.new("RGBA", (w, h))
    for item, _ in naip_items(b, year):
        for attempt in range(4):
            try:
                with urllib.request.urlopen(PC_RENDER % (b + (w, h, item)), context=ctx,
                                            timeout=300) as r:
                    img = Image.open(io.BytesIO(r.read())).convert("RGBA")
                break
            except Exception as e:              # noqa: BLE001 -- the service is flaky
                print("  retrying (%s)" % e)
        else:
            sys.exit("fetch_assets: could not fetch NAIP %s" % item)
        out.alpha_composite(img)
    return out.convert("RGB")


def fetch_mosaic(source, bounds, n_tiles, year=None):
    """The bounds as one RING_PX-square image, from n_tiles x n_tiles requests.
    source 'naip' with a year: that year's NAIP, else the latest."""
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
            if source == 'naip' and year:
                print("  tile %d,%d (NAIP %d)" % (i, j, year), flush=True)
                out.paste(fetch_naip_year(b, w, h, year), (x0, y0))
                continue
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


def blank(img):
    """An image with nothing in it (a service's no-data fill)."""
    a = np.asarray(img.resize((256, 256)), dtype=np.float32)
    return float(a.reshape(-1, 3).std(axis=0).max()) < 2.0      # per channel


def _blur(a, sigma):
    """A Gaussian blur of an (h, w, c) float array, by FFT (wraps; fine away
    from the edges, and the edges are faded out anyway)."""
    ky = np.fft.fftfreq(a.shape[0])[:, None]
    kx = np.fft.rfftfreq(a.shape[1])[None, :]
    g = np.exp(-2.0 * (np.pi * sigma) ** 2 * (kx ** 2 + ky ** 2))
    return np.stack([np.fft.irfft2(np.fft.rfft2(a[..., k]) * g, s=a.shape[:2])
                     for k in range(a.shape[2])], axis=-1)


def match_colours(child, cb, parent, pb):
    """The child matched to the parent, first in each channel's mean and
    spread over its area, then in its large-scale colour everywhere (a smooth
    gain, ~1/30 of the ring across): a ring and the next coarser one then meet
    without a step (it read as a cloud shadow over land, a line over the sea),
    while the child keeps all its fine detail."""
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
        small[..., k] = (small[..., k] - ms) * (sp / ss) + mp
    gain = np.clip((_blur(p, 16.0) + 8.0) / (_blur(small, 16.0) + 8.0), 0.5, 2.0)
    gain = np.stack([np.asarray(Image.fromarray(gain[..., k].astype(np.float32)).resize(
        child.size, Image.BILINEAR)) for k in range(3)], axis=-1)
    return Image.fromarray(np.clip(c * gain, 0, 255).astype(np.uint8))


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
            source = 's2'
        b = ring_bounds(site, half_km)
        print("site %s ring %d: +-%g km from %s" % (key, k, half_km, source))
        img = fetch_mosaic(source, b, 3 if source == 'naip' else 2, site.get('naip_year'))
        if source == 'naip' and blank(img):
            # NAIP has no imagery over some military installations (Edwards,
            # White Sands): Sentinel-2's 10 m instead.
            print("  NAIP is blank here; Sentinel-2 instead")
            source = 's2'
            img = fetch_mosaic(source, b, 2)
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


ISS_URL = ("https://raw.githubusercontent.com/nasa/NASA-3D-Resources/master/3D%20Models/"
           "International%20Space%20Station%20(ISS)%20(D)%20(IGOAL)/"
           "International%20Space%20Station%20(ISS).glb")

# Not on the station at STS-134's docking (May 2011): added later, or STS-134's
# own cargo.  Node names in the IGOAL model; a node drops its whole subtree.
ISS_NOT_2011 = {
    'BEAM', 'Bishop_Airlock', 'MLM', 'Russian_RSNode_DockingModule',     # 2016-2021
    'AMS', 'ELC_3',                                                       # STS-134's cargo
    'IDA2', 'IDA3', 'PMA3',                  # docking adapters 2016-19; PMA-3 moved 2017
    'IROSA_Deployed_P44A', 'IROSA_Deployed_P62B', 'IROSA_Deployed_P64B',
    'IROSA_Deployed_S41A', 'IROSA_Deployed_S43A', 'IROSA_Deployed_S61B',    # 2021-
    'Columbus_BARTOLOMEO', 'Payload_ASIM', 'Payload_STP_H7', 'ColKa',
    'JEM_EF_CALET', 'JEM_EF_ECOSTRESS', 'JEM_EF_GEDI', 'JEM_EF_HISUI', 'JEM_EF_OCO3',
    'JEM_EF_NREP', 'JEM_EF_EFU_Adapter_iSEEP', 'JEM_EF_EFU_Adapter2_iSEEP2',
    'JEM_EF_SFA_Base', 'STP-H8_Body', 'STP-H9',
    'Payload_NICER', 'Payload_MISSE_FF', 'Payload_TUS-RA', 'SAGE_NVP', 'Payload_MUSES',
    'Payload_HRSRadiator', 'Payload_EMIT', 'Payload_AWE',
}
INCH = 0.0254
# The model's root scales by -0.00258 (a point reflection: a mirrored
# station) in inches.  In its own axes, positively scaled: +x forward, +y
# nadir, -z starboard.  This takes inches there to metres in the ISS frame.
ISS_ROOT = np.array([[1.0, 0.0, 0.0], [0.0, 0.0, -1.0], [0.0, 1.0, 0.0]]) * INCH


GANTRY_URL = ("https://raw.githubusercontent.com/nasa/NASA-3D-Resources/master/3D%20Models/"
              "Gantry/Gantry.glb")
# The gantry model is ~5.89 m a unit (the Fixed Service Structure's 40 ft
# square footprint is 2.07 units; its 106 m to the mast's tip, 18.2), y up,
# the FSS at +z from the flame trench's opening (0.73, 1.32, -1.84) on the pad
# deck, whose foot (the ground) is at y = -1.39.  Pad 39A's imagery has the
# FSS north of the trench: model (x, y, z) -> east-north-up (-x, z, y).
GANTRY_SCALE = 5.89
GANTRY_ROOT = np.array([[-1.0, 0.0, 0.0], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0]]) * GANTRY_SCALE
GANTRY_ORIGIN = np.array([0.73, -1.39, -1.84])          # model units: ground under the trench

MODELS = {
    'iss': dict(url=ISS_URL, glb="iss-igoal.glb", root=ISS_ROOT, origin=np.zeros(3),
                exclude=ISS_NOT_2011, name="ISS, STS-134 (May 2011)",
                frame="ISS analysis: +X fwd, +Y stbd, +Z nadir; m",
                source="NASA 3D Resources, ISS (D) (IGOAL)"),
    'gantry': dict(url=GANTRY_URL, glb="gantry.glb", root=GANTRY_ROOT, origin=GANTRY_ORIGIN,
                   exclude=set(), name="LC-39 pad structures (Shuttle era)",
                   frame="pad east-north-up; m; origin on the ground under the stack",
                   source="NASA 3D Resources, Gantry"),
}


def prepare_iss(keep):
    prepare_model('iss', keep)


def glb_parts(src, root, origin, exclude=frozenset()):
    """A glTF binary's meshes (Draco-compressed or plain) as model parts, one
    per material: dict(name, color [r g b a], metallic, texture (a PIL image
    or None), pos, nrm, uv, idx), in the frame root (3x3, applied to the
    glTF scene's root node's children, in place of that node's own
    transform), with origin (in the file's units) at 0.  A node named in
    exclude drops its whole subtree."""
    import io
    try:
        import pygltflib
    except ImportError:
        sys.exit("fetch_assets: pip install DracoPy pygltflib (needed once, to convert models)")
    Image = _image()
    g = pygltflib.GLTF2().load(src)
    blob = g.binary_blob()

    def qmat(q):
        x, y, z, w = q
        return np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
                         [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
                         [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]])

    def local(n):
        if n.matrix:
            return np.array(n.matrix).reshape(4, 4).T
        m = np.eye(4)
        m[:3, :3] = (qmat(n.rotation) if n.rotation else np.eye(3)) @ np.diag(n.scale or [1, 1, 1])
        if n.translation:
            m[:3, 3] = n.translation
        return m

    def accessor(i):
        a = g.accessors[i]
        bv = g.bufferViews[a.bufferView]
        comps = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}[a.type]
        dt = np.dtype({5120: np.int8, 5121: np.uint8, 5122: np.int16, 5123: np.uint16,
                       5125: np.uint32, 5126: np.float32}[a.componentType])
        o = (bv.byteOffset or 0) + (a.byteOffset or 0)
        stride = bv.byteStride or comps * dt.itemsize
        if stride == comps * dt.itemsize:
            return np.frombuffer(blob, dt, count=a.count * comps, offset=o).reshape(a.count, comps)
        return np.vstack([np.frombuffer(blob, dt, count=comps, offset=o + k * stride)
                          for k in range(a.count)])

    groups = {}                                  # material -> lists of arrays
    top = np.eye(4)
    top[:3, :3] = root
    top[:3, 3] = -np.asarray(root) @ np.asarray(origin, float)

    def walk(i, parent):
        n = g.nodes[i]
        if n.name in exclude:
            return
        w = parent @ local(n)
        if n.mesh is not None:
            nrm_m = np.linalg.inv(w[:3, :3]).T
            for p in g.meshes[n.mesh].primitives:
                ext = (p.extensions or {}).get('KHR_draco_mesh_compression')
                if ext:
                    import DracoPy
                    bv = g.bufferViews[ext['bufferView']]
                    o = bv.byteOffset or 0
                    d = DracoPy.decode(blob[o:o + bv.byteLength])
                    pts = np.asarray(d.points, np.float64).reshape(-1, 3)
                    nrm = (np.asarray(d.normals, np.float64).reshape(-1, 3) if d.normals is not None
                           else None)
                    uv = (np.asarray(d.tex_coord, np.float32).reshape(-1, 2) if d.tex_coord is not None
                          else None)
                    faces = np.asarray(d.faces, np.uint32).reshape(-1, 3)
                else:
                    pts = accessor(p.attributes.POSITION).astype(np.float64)
                    nrm = (accessor(p.attributes.NORMAL).astype(np.float64)
                           if p.attributes.NORMAL is not None else None)
                    uv = (accessor(p.attributes.TEXCOORD_0).astype(np.float32)
                          if p.attributes.TEXCOORD_0 is not None else None)
                    faces = (accessor(p.indices).astype(np.uint32).reshape(-1, 3) if p.indices is not None
                             else np.arange(len(pts), dtype=np.uint32).reshape(-1, 3))
                pos = pts @ w[:3, :3].T + w[:3, 3]
                if nrm is not None:
                    nrm = nrm @ nrm_m.T
                    nrm /= np.maximum(np.linalg.norm(nrm, axis=1, keepdims=True), 1e-12)
                groups.setdefault(p.material, []).append((pos, nrm, uv, faces))
        for c in n.children or []:
            walk(c, w)

    scene_root = g.scenes[g.scene or 0].nodes[0]
    for c in g.nodes[scene_root].children or []:
        walk(c, top)
    if g.nodes[scene_root].mesh is not None:   # a file whose root itself is a mesh
        walk(scene_root, top)
    parts = []
    for mi, chunks in sorted(groups.items(), key=lambda kv: (kv[0] is None, kv[0] or 0)):
        base, idx, pos, nrm, uv = 0, [], [], [], []
        for p_, n_, u_, f_ in chunks:
            idx.append(f_ + base)
            base += len(p_)
            pos.append(p_)
            nrm.append(n_ if n_ is not None else flat_normals(p_, f_))
            uv.append(u_ if u_ is not None else np.zeros((len(p_), 2), np.float32))
        part = dict(pos=np.vstack(pos), nrm=np.vstack(nrm), uv=np.vstack(uv), idx=np.vstack(idx),
                    name="(none)", color=[0.7, 0.7, 0.7, 1.0], metallic=0.0, texture=None)
        if mi is not None:
            mat = g.materials[mi]
            pbr = mat.pbrMetallicRoughness
            part.update(name=mat.name or "material %d" % mi,
                        color=list(pbr.baseColorFactor or [1, 1, 1, 1]),
                        metallic=pbr.metallicFactor if pbr.metallicFactor is not None else 1.0)
            if pbr.baseColorTexture is not None:
                t = g.textures[pbr.baseColorTexture.index]
                srcimg = ((t.extensions or {}).get('EXT_texture_webp') or {}).get('source', t.source)
                im = g.images[srcimg]
                bv = g.bufferViews[im.bufferView]
                o = bv.byteOffset or 0
                part['texture'] = Image.open(io.BytesIO(blob[o:o + bv.byteLength])).convert("RGB")
        parts.append(part)
    return parts


def flat_normals(pos, faces):
    """Per-vertex normals for a mesh whose vertices are shared: each face's,
    averaged at its corners (smooth where the mesh is, which glTF without
    normals usually means)."""
    n = np.zeros_like(pos, dtype=np.float64)
    f = np.cross(pos[faces[:, 1]] - pos[faces[:, 0]], pos[faces[:, 2]] - pos[faces[:, 0]])
    for j in range(3):
        np.add.at(n, faces[:, j], f)
    return n / np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)


def write_model(key, meta, parts):
    """A prepared model, cache/models/KEY/: model.npz (per part: pos, nrm, uv,
    idx) and model.json (meta, and per part its name, colour, metallic and
    texture file).  parts as glb_parts gives them; a part's nrm may be None
    (flat normals: each triangle given its own corners), uv None, texture a
    PIL image or None.  meta: name, frame, source, and for a vehicle norad
    and mag_1000km."""
    import json
    out_dir = os.path.join(CACHE, "models", key)
    os.makedirs(out_dir, exist_ok=True)
    Image = _image()
    arrays, mats = {}, []
    for k, p in enumerate(parts):
        pos = np.asarray(p['pos'], np.float64)
        idx = np.asarray(p['idx'], np.int64).reshape(-1, 3)
        uv = p.get('uv')
        if p.get('nrm') is None:                 # flat: each triangle its own corners
            v = pos[idx].reshape(-1, 3)
            fn = np.cross(pos[idx[:, 1]] - pos[idx[:, 0]], pos[idx[:, 2]] - pos[idx[:, 0]])
            fn /= np.maximum(np.linalg.norm(fn, axis=1, keepdims=True), 1e-12)
            nrm = np.repeat(fn, 3, axis=0)
            uv = (np.asarray(uv, np.float32)[idx].reshape(-1, 2) if uv is not None
                  else np.zeros((len(v), 2), np.float32))
            pos, idx = v, np.arange(len(v)).reshape(-1, 3)
        else:
            nrm = np.asarray(p['nrm'], np.float64)
            uv = np.asarray(uv, np.float32) if uv is not None else np.zeros((len(pos), 2), np.float32)
        arrays['pos%d' % k] = pos.astype(np.float32)
        arrays['nrm%d' % k] = nrm.astype(np.float32)
        arrays['uv%d' % k] = uv
        arrays['idx%d' % k] = idx.astype(np.uint32).ravel()
        entry = dict(name=p.get('name', 'part %d' % k), color=list(p.get('color', [0.7, 0.7, 0.7, 1.0])),
                     metallic=p.get('metallic', 0.0), texture=None)
        if len(entry['color']) == 3:
            entry['color'].append(1.0)
        img = p.get('texture')
        if img is not None:
            if max(img.size) > 2048:
                f = 2048.0 / max(img.size)
                img = img.resize((max(1, int(img.size[0] * f)), max(1, int(img.size[1] * f))), Image.LANCZOS)
            entry['texture'] = "tex%d.jpg" % k
            img.save(os.path.join(out_dir, entry['texture']), quality=90)
        mats.append(entry)
    np.savez_compressed(os.path.join(out_dir, "model.npz"), **arrays)
    tris = sum(len(arrays['idx%d' % k]) // 3 for k in range(len(mats)))
    with open(os.path.join(out_dir, "model.json"), "w") as f:
        json.dump(dict(meta, triangles=tris, materials=mats), f, indent=1)
    print("  model %s: %d triangles in %d parts" % (key, tris, len(mats)))


def prepare_model(key, keep):
    spec = MODELS[key]
    out_dir = os.path.join(CACHE, "models", key)
    if os.path.exists(os.path.join(out_dir, "model.json")):
        return
    src = download(spec['url'], os.path.join(CACHE, "models", spec['glb']))
    print("converting", os.path.basename(src))
    parts = glb_parts(src, spec['root'], spec['origin'], spec['exclude'])
    meta = dict(name=spec['name'], frame=spec['frame'], source=spec['source'])
    if 'mag_1000km' in spec:
        meta['mag_1000km'] = spec['mag_1000km']
    write_model(key, meta, parts)
    if not keep:
        os.remove(src)


ISS2011_URL = ("https://raw.githubusercontent.com/nasa/NASA-3D-Resources/master/3D%20Models/"
               "International%20Space%20Station%20(ISS)%20(C)%20(High%20Res)/"
               "International%20Space%20Station%20(ISS)%20(C)%20(High%20Res).7z")
# What IGOAL lacks for May 2011, from JSC's VCL "ISS 2011" LightWave models
# (inches, left-handed): each vehicle's file; the direction from its body to
# its docking probe and a direction across it (its solar wings), in its own
# axes made right-handed (z negated); the port, the direction from the port
# into the station, and where the across-direction points (ISS frame, m).
# Ports from IGOAL's own modules: Rassvet's nadir and Poisk's zenith drogues;
# Zvezda's aft port; Zvezda's nadir port where IGOAL's Nauka (2021) has its
# probe, Pirs's place until 2021.  The probe goes 0.35 m into a drogue.
ISS_VISITORS = (
    ('Pirs', 'pirs/Pirs.lwo', (0, 1, 0), (1, 0, 0), (-23.69, 0.0, 4.81), (0, 0, -1), (1, 0, 0), 0.0),
    ('Progress M-10M, at Pirs', 'progress/prog-ani.lwo', (0, 0, -1), (0, 1, 0), 'Pirs', (0, 0, -1),
     (1, 0, 0), 0.35),
    ('Soyuz TMA-20, at Rassvet', 'soyuz/soyuz-ext.lwo', (0, 0, -1), (0, 1, 0), (-11.14, 0.0, 11.243),
     (0, 0, -1), (1, 0, 0), 0.35),
    ('Soyuz TMA-21, at Poisk', 'soyuz/soyuz-ext.lwo', (0, 0, -1), (0, 1, 0), (-23.69, 0.0, -1.032),
     (0, 0, 1), (1, 0, 0), 0.35),
    ('ATV-2 Johannes Kepler, at Zvezda aft', 'atv/ATV_temp.lwo', (1, 0, 0), (0, 1, 0),
     (-35.676, 0.0, 4.26), (1, 0, 0), (0, 1, 0), 0.35),
)
# A surface whose colour layer has an image is drawn with it, the image's
# values taken for albedo (as LightWave takes them, and as these models'
# plain colours are taken); one with only a bump image (Pirs's blankets'
# wrinkles), with that image's variation about its colour, the shading it
# gave in LightWave, which portview does not do.  Here, surfaces' colours
# (albedo; with an image, its mean, the image scaled to it): the solar
# cells, whose image is a pale grey-violet (0.21, 0.19, 0.29), the dark blue
# they are; the arrays' backs, which the files make a peach brighter than
# white, tan.
VISITOR_COLOURS = {'soyuz-pan': (0.05, 0.07, 0.16), 'progress-pan': (0.05, 0.07, 0.16),
                   'ATV-panels': (0.05, 0.07, 0.16),
                   'soyuz-panR': (0.55, 0.46, 0.38), 'progress-panR': (0.55, 0.46, 0.38)}


def _lwo_albedo_image(img):
    """An image whose sRGB-decoded values (as portview samples it) are img's
    own values: LightWave works on its images' values as they are, and the
    plain colours of these models are taken so too."""
    lut = [int(round(255 * (1.055 * (i / 255) ** (1 / 2.4) - 0.055 if i / 255 > 0.0031308
                            else 12.92 * i / 255))) for i in range(256)]
    return img.point(lut * 3)


def _lwo_rotation(hpb):
    """A texture's TMAP rotation, heading, pitch, bank (rad), as the matrix
    taking a point (relative to its centre) to the texture's own axes:
    heading about +y (+z toward +x), pitch about +x (+z toward -y), bank
    about +z (+y toward -x), applied bank, pitch, heading.  (The SDK's
    sample ignores rotation; this sense of heading is the one that lays
    Pirs's name, planar along a turned z, flat on its plate and reading
    left to right from outside.  Pitch and bank are unused here.)"""
    h, p, b = hpb
    ch, sh, cp, sp, cb, sb = np.cos(h), np.sin(h), np.cos(p), np.sin(p), np.cos(b), np.sin(b)
    H = np.array([[ch, 0, sh], [0, 1, 0], [-sh, 0, ch]])
    P = np.array([[1, 0, 0], [0, cp, -sp], [0, sp, cp]])
    B = np.array([[cb, -sb, 0], [sb, cb, 0], [0, 0, 1]])
    return H @ P @ B


def _lwo_heading(x, z):
    """The LightWave SDK's xyztoh: the heading of (x, z), 0 <= h < 2 pi."""
    return np.mod(-np.arctan2(x, z), 2 * np.pi)


def _lwo_uv(m, pts, nrm, firsts):
    """Texture coordinates (v down the image from its top) of a surface's
    corners pts (n, 3), by its colour layer's projection m (dict: proj, axis,
    cntr, size, rota, wrpw, wrph), as the LightWave SDK's sample objacces.c
    computes them; nrm (n, 3) each corner's polygon's normal (for cubic).
    Cylindrical and spherical u is made continuous across each polygon (whose
    first corners are at firsts), so that the seam's polygons do not run
    the whole image backwards: the renderer wraps."""
    s = (pts - m['cntr']) @ _lwo_rotation(m['rota']).T      # the texture's own axes
    x, y, z = s[:, 0], s[:, 1], s[:, 2]
    sx, sy, sz = [v if abs(v) > 1e-9 else 1.0 for v in m['size']]
    proj, axis = m['proj'], m['axis']
    if proj in (1, 2):
        # objacces: xyztoh(z, x, -y) about x, (-x, y, z) about y, (-x, z, -y) about z.
        a, b, c = {0: (z, x, -y), 1: (-x, y, z), 2: (-x, z, -y)}[axis]
        u = (1.0 - _lwo_heading(a, c) / (2 * np.pi)) * m['wrpw']
        if proj == 1:
            v = 0.5 - (x / sx, y / sy, z / sz)[axis]
        else:
            v = (0.5 - np.arctan2(b, np.hypot(a, c)) / np.pi) * m['wrph']
        # Each polygon's u within half a turn of its first corner's.
        turn = m['wrpw']
        first = np.repeat(u[firsts], np.diff(np.append(firsts, len(u))))
        u = u - turn * np.round((u - first) / turn)
    else:                                                    # planar, cubic
        if proj == 3:
            an = np.abs(nrm @ _lwo_rotation(m['rota']).T)
            ax = np.where((an[:, 0] >= an[:, 1]) & (an[:, 0] > an[:, 2]), 0,
                          np.where(an[:, 1] > an[:, 2], 1, 2))
        else:
            ax = np.full(len(s), axis)
        u = np.where(ax == 0, z / sz, x / sx) + 0.5
        v = 0.5 - np.where(ax == 1, z / sz, y / sy)
    return np.column_stack([u, v]).astype(np.float32)


def _lwo_image(root, path, cache):
    """A CLIP's still image (PIL, RGB), path relative to the content
    directory root; None if it is not there."""
    if path not in cache:
        Image = _image()
        cache[path] = None
        rel = path.replace('\\', '/').split(':')[-1].lstrip('/')
        for p in (os.path.join(root, rel), os.path.join(root, "Textures", os.path.basename(rel))):
            if os.path.exists(p):
                try:
                    cache[path] = Image.open(p).convert("RGB")
                    break
                except OSError:
                    pass
    return cache[path]


def read_lwo(path, root=None):
    """A LightWave LWO2 object: [(surface, rgb, points (n, 3), triangles,
    texture, uv, bump)], every polygon's corners its own points (flat
    shading), all layers.  texture: the image (PIL, RGB) of the surface's
    colour layer, or None; uv (n, 2) then its coordinates at the points, by
    the layer's projection (planar, cylindrical, spherical or cubic; image v
    from the top).  bump: (image, uv) of its bump layer likewise, or None.
    root: the content directory the object's image paths are relative to
    (default: the one holding its Objects directory)."""
    import struct
    data = open(path, 'rb').read()
    if data[:4] != b'FORM' or data[8:12] != b'LWO2':
        sys.exit("fetch_assets: %s is not an LWO2 object" % path)
    if root is None:
        parts = os.path.abspath(path).split(os.sep)
        root = os.sep.join(parts[:parts.index('Objects')]) if 'Objects' in parts else os.path.dirname(path)

    def vx(b, o):                       # LightWave's variable-length index
        if b[o] == 0xFF:
            return struct.unpack('>I', b[o:o + 4])[0] & 0xFFFFFF, o + 4
        return struct.unpack('>H', b[o:o + 2])[0], o + 2

    def strings(b, o):                  # NUL-terminated, padded to even
        e = b.index(b'\0', o)
        return b[o:e].decode('latin-1'), e + 1 + ((e + 1 - o) & 1)

    def subchunks(b, o=0):              # (id, body) of a chunk's subchunks
        while o + 6 <= len(b):
            sid, ss = b[o:o + 4], struct.unpack('>H', b[o + 4:o + 6])[0]
            yield sid, b[o + 6:o + 6 + ss]
            o += 6 + ss + (ss & 1)

    def block(b):
        """A SURF's BLOK: its image layer as a dict, or None."""
        hid, hb = next(subchunks(b))
        if hid != b'IMAP':
            return None
        ordinal, o = strings(hb, 0)
        m = dict(ordinal=ordinal, chan=None, enab=1, proj=0, axis=0, clip=None,
                 cntr=np.zeros(3), size=np.ones(3), rota=np.zeros(3), wrpw=1.0, wrph=1.0)
        for sid, sb in subchunks(hb, o):
            if sid == b'CHAN':
                m['chan'] = sb[:4]
            elif sid == b'ENAB':
                m['enab'] = struct.unpack('>H', sb[:2])[0]
        for sid, sb in subchunks(b):
            if sid == b'TMAP':
                for tid, tb in subchunks(sb):
                    if tid in (b'CNTR', b'SIZE', b'ROTA'):
                        m[tid.decode().lower()] = np.array(struct.unpack('>3f', tb[:12]), np.float64)
            elif sid in (b'PROJ', b'AXIS'):
                m[sid.decode().lower()] = struct.unpack('>H', sb[:2])[0]
            elif sid == b'IMAG':
                m['clip'] = vx(sb, 0)[0]
            elif sid in (b'WRPW', b'WRPH'):
                m[sid.decode().lower()] = struct.unpack('>f', sb[:4])[0]
        return m

    pos, end = 12, 8 + struct.unpack('>I', data[4:8])[0]
    tags, colours, maps, clips, layers, cur = [], {}, {}, {}, [], None
    while pos < end:
        cid, size = data[pos:pos + 4], struct.unpack('>I', data[pos + 4:pos + 8])[0]
        b = data[pos + 8:pos + 8 + size]
        pos += 8 + size + (size & 1)
        if cid == b'TAGS':
            o = 0
            while o < len(b):
                t, o = strings(b, o)
                tags.append(t)
        elif cid in (b'LAYR', b'PNTS') and (cid == b'LAYR' or cur is None):
            cur = dict(points=np.zeros((0, 3)), polys=[], ptag={})
            layers.append(cur)
        if cid == b'PNTS':
            cur['points'] = np.frombuffer(b, '>f4').reshape(-1, 3).astype(np.float64)
        elif cid == b'POLS' and b[:4] == b'FACE':
            o, polys = 4, []
            while o < len(b):
                nv = struct.unpack('>H', b[o:o + 2])[0] & 0x3FF
                o += 2
                idx = []
                for _ in range(nv):
                    v, o = vx(b, o)
                    idx.append(v)
                polys.append(idx)
            cur['polys'] = polys
        elif cid == b'PTAG' and b[:4] == b'SURF':
            o = 4
            while o < len(b):
                i, o = vx(b, o)
                cur['ptag'][i] = struct.unpack('>H', b[o:o + 2])[0]
                o += 2
        elif cid == b'CLIP':
            for sid, sb in subchunks(b, 4):
                if sid == b'STIL':
                    clips[struct.unpack('>I', b[:4])[0]] = strings(sb, 0)[0]
        elif cid == b'SURF':
            name, o = strings(b, 0)
            _, o = strings(b, o)
            rgb, layer = (0.7, 0.7, 0.7), {}
            for sid, sb in subchunks(b, o):
                if sid == b'COLR':
                    rgb = struct.unpack('>3f', sb[:12])
                elif sid == b'BLOK':
                    m = block(sb)
                    if (m and m['chan'] in (b'COLR', b'BUMP') and m['enab'] and m['clip'] is not None
                            and m['proj'] in (0, 1, 2, 3)):
                        layer.setdefault(m['chan'], []).append(m)
            colours[name] = rgb
            for chan, ms in layer.items():  # each channel's top layer (they sort by ordinal)
                maps[name, chan] = max(ms, key=lambda m: m['ordinal'].encode('latin-1'))
    surfaces = {}
    for L in layers:
        for i, poly in enumerate(L['polys']):
            if len(poly) < 3:
                continue
            name = tags[L['ptag'].get(i, 0)] if tags else 'default'
            pts, tris = surfaces.setdefault(name, ([], []))
            base = sum(len(q) for q in pts)
            pts.append(L['points'][poly])
            tris.extend((base, base + k, base + k + 1) for k in range(1, len(poly) - 1))
    images, out = {}, []
    for name, (pts, tris) in surfaces.items():
        p, t = np.vstack(pts), np.array(tris, np.uint32)
        firsts = np.cumsum([0] + [len(q) for q in pts[:-1]])
        # Each polygon's normal (Newell's), at its corners.
        nrm = np.vstack([np.tile(np.cross(q - q.mean(0), np.roll(q, -1, 0) - q.mean(0)).sum(0),
                                 (len(q), 1)) for q in pts])
        got = {}
        for chan in (b'COLR', b'BUMP'):
            m = maps.get((name, chan))
            img = _lwo_image(root, clips.get(m['clip'], ''), images) if m is not None else None
            if img is not None:
                got[chan] = (img, _lwo_uv(m, p, nrm, firsts))
        img, uv = got.get(b'COLR', (None, None))
        out.append((name, colours.get(name, (0.7, 0.7, 0.7)), p, t, img, uv, got.get(b'BUMP')))
    return out


def prepare_iss_visitors(keep):
    """Add Pirs and the vehicles docked in May 2011 (Soyuz TMA-20 and -21,
    Progress M-10M, ATV-2) to the prepared ISS model, which lacks them."""
    import hashlib
    import json
    import shutil
    import subprocess
    out_dir = os.path.join(CACHE, "models", "iss")
    meta_path = os.path.join(out_dir, "model.json")
    if not os.path.exists(meta_path):
        return
    with open(meta_path) as f:
        meta = json.load(f)
    if meta.get('visitors'):
        return
    tool = shutil.which("7z") or shutil.which("7zz")
    if tool is None:
        print("fetch_assets: no 7z, so the ISS has no Soyuz, Progress, ATV or Pirs")
        return
    src = download(ISS2011_URL, os.path.join(CACHE, "models", "iss-2011.7z"))
    work = os.path.join(CACHE, "models", "iss-2011")
    # The objects and their images (beside them, in other modules' folders
    # and in Textures/).
    subprocess.run([tool, "x", "-y", "-o" + work, src, "Objects/Modules/*", "Textures/*"],
                   check=True, stdout=subprocess.DEVNULL)
    Image = _image()
    z = dict(np.load(os.path.join(out_dir, "model.npz")))
    mats = meta['materials']
    placed, saved = {}, {}
    for name, f, probe, across, port, inward, across_iss, depth in ISS_VISITORS:
        parts = read_lwo(os.path.join(work, "Objects", "Modules", f), work)
        rh = np.diag([INCH, INCH, -INCH])                    # inches, left-handed -> m, right
        allp = np.vstack([p[2] for p in parts]) @ rh
        a, c = np.array(probe, float), np.array(across, float)
        # Its axis: the middle, across the probe direction, of its body's
        # shell (the '-side' or 'body' surface; antennas and wings make the
        # whole lopsided); the probe's tip: the farthest point along it
        # within 0.4 m of the axis.
        shell = [p[2] for p in parts if p[0].endswith('-side') or p[0] == 'body']
        sp = (np.vstack(shell) if shell else np.vstack([p[2] for p in parts])) @ rh
        sp = sp - np.outer(sp @ a, a)
        mid = 0.5 * (sp.min(0) + sp.max(0))
        body = allp - np.outer(allp @ a, a)
        near = np.linalg.norm(body - mid, axis=1) < 0.4
        tip = mid + a * (allp[near] @ a).max()
        # Turned so the probe points into the station and the wings across as given.
        n_in, w = np.array(inward, float), np.array(across_iss, float)
        R = (np.column_stack([n_in, w, np.cross(n_in, w)]) @
             np.column_stack([a, c, np.cross(a, c)]).T)
        p0 = placed[port] if isinstance(port, str) else np.array(port, float)
        t = p0 + np.array(inward, float) * depth - R @ tip
        # The far end, for whatever docks to it.
        free = mid - a * (allp[near] @ (-a)).max()
        placed[name.split(',')[0]] = R @ free + t
        for surf, rgb, pts, tris, img, uv, bump in parts:
            k = len(mats)
            pos = (pts @ rh) @ R.T + t
            v = pos[tris]
            fn = np.cross(v[:, 1] - v[:, 0], v[:, 2] - v[:, 0])
            fn /= np.maximum(np.linalg.norm(fn, axis=1, keepdims=True), 1e-12)
            nrm = np.zeros_like(pos)
            for j in range(3):
                nrm[tris[:, j]] = fn
            z['pos%d' % k] = pos.astype(np.float32)
            z['nrm%d' % k] = nrm.astype(np.float32)
            colour = np.asarray(VISITOR_COLOURS.get(surf, rgb), np.float64)
            if img is not None:         # (see VISITOR_COLOURS)
                mean = np.asarray(img, np.float64).reshape(-1, 3).mean(0) / 255
                colour = colour / mean if surf in VISITOR_COLOURS else np.ones(3)
            elif bump is not None:
                img, uv = bump
                colour = colour / (np.asarray(img.convert('L'), np.float64).mean() / 255)
            z['uv%d' % k] = uv if uv is not None else np.zeros((len(pos), 2), np.float32)
            z['idx%d' % k] = tris.ravel()
            mat = dict(name="%s: %s" % (name, surf), color=[float(c) for c in colour] + [1.0],
                       metallic=0.0, texture=None)
            if img is not None:
                key = hashlib.sha1(img.tobytes() + repr(img.size).encode()).hexdigest()
                if key not in saved:    # one file an image
                    saved[key] = tex = "tex%d.jpg" % k
                    if max(img.size) > 2048:
                        g = 2048.0 / max(img.size)
                        img = img.resize((max(1, int(img.size[0] * g)), max(1, int(img.size[1] * g))),
                                         Image.LANCZOS)
                    _lwo_albedo_image(img).save(os.path.join(out_dir, tex), quality=95)
                mat['texture'] = saved[key]
            mats.append(mat)
        print("  %s: %d triangles" % (name, sum(len(p[3]) for p in parts)))
    np.savez_compressed(os.path.join(out_dir, "model.npz"), **z)
    meta['visitors'] = [v[0] for v in ISS_VISITORS]
    meta['triangles'] = sum(len(z['idx%d' % k]) // 3 for k in range(len(mats)))
    meta['source'] += "; Pirs and the visiting vehicles: NASA 3D Resources, ISS (C) (High Res)"
    with open(meta_path, "w") as f:
        json.dump(meta, f, indent=1)
    shutil.rmtree(work, ignore_errors=True)
    if not keep:
        os.remove(src)


# THE SHUTTLE CENTERLINE TARGET on PMA-2 (STS-134 RNDZ checklist p149, 6-11;
# CC 9-9, p307): a backplate with 3 in. and 4 in. radius arcs, pitch/yaw
# indicator bars at 2, 3, 4, 5 and 6 in. from its centre and roll blocks at
# 2 deg steps, and a stand-off cross on a stalk 12 in. in front of it; the
# centerline camera reads the Orbiter's misalignment off the cross against
# the backplate.  Its place: on PMA-2's axis, against the face the model
# closes PMA-2 with (X 15.655 m; the real target is behind the hatch
# window, a recess not documented here).  Up on the target is the ISS's -Z
# (zenith), as the Orbiter docks nose up.  Colours: a white plate with black
# markings and a black cross and stalk -- as the target looks in docking
# video; not from a document.  Sizes not on the drawing (the plate's 8 in.
# radius, the cross's 1 in. arms, line widths) are choices.
CL_TARGET_FACE = (15.655, 0.0, 5.562)     # PMA-2's face on its axis, ISS frame (m); portview's ISS_PMA2


def _cl_target_tris():
    """[(name, rgb, pos (N,3), normals, triangles)] for the target, ISS frame."""
    x0, yc, zc = CL_TARGET_FACE
    out = {}

    def add(name, rgb, quads):
        P, N, T = out.setdefault(name, (rgb, [], [], []))[1:]
        for q, n in quads:
            b = len(P)
            P.extend(q)
            N.extend([n] * 4)
            T.extend([(b, b + 1, b + 2), (b, b + 2, b + 3)])

    def pt(x, u, w):                        # u along +Y (right as the camera sees it), w up (-Z)
        return (x, yc + u, zc - w)

    def flat(x, u0, w0, u1, w1):            # a rectangle facing +X
        return ([pt(x, u0, w0), pt(x, u1, w0), pt(x, u1, w1), pt(x, u0, w1)], (1.0, 0.0, 0.0))

    def box(xa, xb, u0, w0, u1, w1):
        q = [flat(xb, u0, w0, u1, w1)]
        for (ua, wa, ub, wb), n in (((u0, w0, u1, w0), (0, 0, 1)), ((u0, w1, u1, w1), (0, 0, -1)),
                                    ((u0, w0, u0, w1), (0, -1, 0)), ((u1, w0, u1, w1), (0, 1, 0))):
            q.append(([pt(xa, ua, wa), pt(xb, ua, wa), pt(xb, ub, wb), pt(xa, ub, wb)], n))
        return q

    def ring(x, r, wdt, n=72):
        q = []
        for k in range(n):
            a0, a1 = 2 * np.pi * k / n, 2 * np.pi * (k + 1) / n
            ri, ro = r - wdt / 2, r + wdt / 2
            q.append(([pt(x, ri * np.cos(a0), ri * np.sin(a0)), pt(x, ro * np.cos(a0), ro * np.sin(a0)),
                       pt(x, ro * np.cos(a1), ro * np.sin(a1)), pt(x, ri * np.cos(a1), ri * np.sin(a1))],
                      (1.0, 0.0, 0.0)))
        return q

    white, black = (0.85, 0.85, 0.83), (0.04, 0.04, 0.04)
    R = 8 * INCH
    plate = []
    for k in range(48):                     # the plate, a disc a little proud of the face
        a0, a1 = 2 * np.pi * k / 48, 2 * np.pi * (k + 1) / 48
        plate.append(([pt(x0 + 0.003, 0, 0), pt(x0 + 0.003, R * np.cos(a0), R * np.sin(a0)),
                       pt(x0 + 0.003, R * np.cos(a1), R * np.sin(a1)), pt(x0 + 0.003, 0, 0)],
                      (1.0, 0.0, 0.0)))
    add("centerline target: plate", white, plate)
    xm = x0 + 0.006                         # the markings, on the plate
    marks = ring(xm, 3 * INCH, 0.25 * INCH) + ring(xm, 4 * INCH, 0.25 * INCH)
    for d in (2, 3, 4, 5, 6):               # pitch/yaw indicator bars, each axis both ways
        h, l = 0.15 * INCH, 0.6 * INCH
        for su in (-1, 1):
            u = su * d * INCH
            marks.append(flat(xm, u - h, -l, u + h, l))
        for sw in (-1, 1):
            w = sw * d * INCH
            marks.append(flat(xm, -l, w - h, l, w + h))
    for a in (-6, -4, -2, 0, 2, 4, 6):      # roll blocks, at 2 deg, at the top
        th = np.radians(90 + a)
        u, w, b = 6.8 * INCH * np.cos(th), 6.8 * INCH * np.sin(th), 0.15 * INCH
        marks.append(flat(xm, u - b, w - 2 * b, u + b, w + 2 * b))
    add("centerline target: markings", black, marks)
    s = 0.25 * INCH                         # the stalk and the stand-off cross, 12 in. out
    xc = x0 + 0.003 + 12 * INCH
    cross = box(x0 + 0.003, xc - 0.1 * INCH, -s, -s, s, s)
    a, t = 1.0 * INCH, 0.125 * INCH
    cross += box(xc - 0.1 * INCH, xc, -a, -t, a, t) + box(xc - 0.1 * INCH, xc, -t, -a, t, a)
    add("centerline target: stand-off cross", black, cross)
    return [(name, rgb, np.array(P, np.float32), np.array(N, np.float32), np.array(T, np.int32))
            for name, (rgb, P, N, T) in out.items()]


# THE S1 RADIATOR'S DAMAGE.  IGOAL models the face sheet peeled up off a
# starboard (S1) heat-rejection radiator panel -- found in 2008 and there for
# STS-134 (NASA photo S1 Radiator Damage, commons.wikimedia.org/wiki/File:
# S1_Radiator_Damage.jpg) -- but maps it, like the panels' edges, onto the
# Truss texture's near-white edge texel (u 0.804, v 1.0), so in sunlight it
# shone white, "like a mouse cursor".  It is the panel's own skin: given the
# panels' texture strip (u 0.128, v 0.662-1.0) the way the panel beside it
# has it.  Found by shape, not index: of the white-texel triangles over the
# S1 radiators, the one connected piece that rises well clear of its panel's
# plane (1.7 m; the panels' edge strips measure ~0.6 m by this test).
RAD_REGION = ((-24.0, 4.0, -3.0), (-4.0, 21.0, 3.0))    # S1's radiators, ISS frame (m)
RAD_EDGE_UV, RAD_FACE_U, RAD_FACE_V = (0.804, 1.0), 0.128, (0.662, 1.0)


def _radiator_damage(P, I, UV):
    """The peeled sheet's triangles (indices into I), or an empty array."""
    from collections import defaultdict
    T = P[I]
    c = T.mean(1)
    lo, hi = np.array(RAD_REGION[0]), np.array(RAD_REGION[1])
    inside = np.all((c > lo) & (c < hi), axis=1)
    white = np.all(np.abs(UV[I] - RAD_EDGE_UV).max(2) < 0.002, axis=1)
    cand = np.where(inside & white)[0]
    face = np.where(inside & np.all(np.abs(UV[I][:, :, 0] - RAD_FACE_U) < 0.002, axis=1))[0]
    if not len(cand) or not len(face):
        return np.zeros(0, int), face
    vt = defaultdict(list)
    for t in cand:
        for j in range(3):
            vt[tuple(np.round(P[I[t, j]], 4))].append(t)
    n = np.cross(T[face, 1] - T[face, 0], T[face, 2] - T[face, 0])
    n /= np.maximum(np.linalg.norm(n, axis=1), 1e-12)[:, None]
    seen, best, best_h = set(), np.zeros(0, int), 1.0
    for t in cand:
        if t in seen:
            continue
        comp, stack = [t], [t]
        seen.add(t)
        while stack:
            u = stack.pop()
            for j in range(3):
                for w in vt[tuple(np.round(P[I[u, j]], 4))]:
                    if w not in seen:
                        seen.add(w)
                        comp.append(w)
                        stack.append(w)
        comp = np.array(comp)
        # each vertex's height off the plane of the panel face nearest it
        v = P[I[comp]].reshape(-1, 3)
        k = np.argmin(np.linalg.norm(v[:, None, :] - c[face][None], axis=2), axis=1)
        h = np.abs(((v - c[face[k]]) * n[k]).sum(1)).max()
        if h > best_h:              # the edge strips reach ~0.6 m (big faces' centroids), the sheet 1.7
            best, best_h = comp, h
    return best, face


def prepare_iss_radiator_damage():
    """Give the S1 radiator's peeled face sheet the panels' own texture."""
    import json
    out_dir = os.path.join(CACHE, "models", "iss")
    meta_path = os.path.join(out_dir, "model.json")
    if not os.path.exists(meta_path):
        return
    with open(meta_path) as f:
        meta = json.load(f)
    if meta.get('radiator_damage'):
        return
    names = [m.get('name') for m in meta['materials']]
    if 'Truss' not in names:
        return
    k = names.index('Truss')
    z = dict(np.load(os.path.join(out_dir, "model.npz")))
    P, UV = z['pos%d' % k], z['uv%d' % k].copy()
    I = z['idx%d' % k].reshape(-1, 3).copy()
    sheet, face = _radiator_damage(P, I, UV)
    if not len(sheet):
        print("  the S1 radiator's damage: not found; left as it is")
        return
    # the panels' v runs across them: fitted from the panel faces nearby, so
    # the sheet takes the strip where the panel it came off has it
    near = face[np.linalg.norm(P[I[face]].mean(1) - P[I[sheet]].reshape(-1, 3).mean(0), axis=1) < 4.0]
    pv = P[I[near]].reshape(-1, 3)
    vv = UV[I[near]].reshape(-1, 2)[:, 1]
    A = np.hstack([pv, np.ones((len(pv), 1))])
    g = np.linalg.lstsq(A, vv, rcond=None)[0]
    # its own vertices (the white edge strips keep theirs), with the new UVs
    old = np.unique(I[sheet])
    newi = np.arange(len(P), len(P) + len(old))
    remap = dict(zip(old.tolist(), newi.tolist()))
    sv = P[old]
    uvn = np.column_stack([np.full(len(old), RAD_FACE_U),
                           np.clip(np.hstack([sv, np.ones((len(old), 1))]) @ g, *RAD_FACE_V)])
    z['pos%d' % k] = np.vstack([P, sv]).astype(P.dtype)
    z['nrm%d' % k] = np.vstack([z['nrm%d' % k], z['nrm%d' % k][old]]).astype(z['nrm%d' % k].dtype)
    z['uv%d' % k] = np.vstack([UV, uvn]).astype(UV.dtype)
    I[sheet] = np.vectorize(remap.get)(I[sheet])
    z['idx%d' % k] = I.ravel().astype(z['idx%d' % k].dtype)
    np.savez_compressed(os.path.join(out_dir, "model.npz"), **z)
    meta['radiator_damage'] = True
    meta['source'] += "; the S1 radiator's peeled face sheet given the panels' texture"
    with open(meta_path, "w") as f:
        json.dump(meta, f, indent=1)
    print("  the S1 radiator's damage: %d triangles given the panels' texture" % len(sheet))


def prepare_iss_cl_target():
    """Add the Shuttle centerline target to the prepared ISS model's PMA-2."""
    import json
    out_dir = os.path.join(CACHE, "models", "iss")
    meta_path = os.path.join(out_dir, "model.json")
    if not os.path.exists(meta_path):
        return
    with open(meta_path) as f:
        meta = json.load(f)
    made = _cl_target_tris()
    mats = meta['materials']
    placed = sum(1 for m in mats if m.get('name') in {t[0] for t in made})
    if meta.get('cl_target') == list(CL_TARGET_FACE) and placed == len(made):
        return                   # there, once, at this face (a doubled one is redone)
    z = dict(np.load(os.path.join(out_dir, "model.npz")))
    # A target placed before (at an older face, or more than one): every
    # material of it taken off, wherever it sits -- other parts (the ISS's
    # visitors) may have been added after it -- and the rest renumbered.
    names = {m[0] for m in made}
    keep = [k for k, m in enumerate(mats) if m.get('name') not in names]
    if len(keep) != len(mats):
        z2 = {}
        for new_k, old_k in enumerate(keep):
            for a in ('pos', 'nrm', 'uv', 'idx'):
                if '%s%d' % (a, old_k) in z:
                    z2['%s%d' % (a, new_k)] = z['%s%d' % (a, old_k)]
        z = {**{key: v for key, v in z.items() if not any(key.startswith(a) and key[len(a):].isdigit()
                                                          for a in ('pos', 'nrm', 'uv', 'idx'))}, **z2}
        mats[:] = [mats[k] for k in keep]
    meta['source'] = meta['source'].replace("; the centerline target at PMA-2: STS-134 RNDZ checklist p149", "")
    for name, rgb, pos, nrm, tris in made:
        k = len(mats)
        z['pos%d' % k], z['nrm%d' % k] = pos, nrm
        z['uv%d' % k] = np.zeros((len(pos), 2), np.float32)
        z['idx%d' % k] = tris.ravel()
        mats.append(dict(name=name, color=[float(c) for c in rgb] + [1.0], metallic=0.0, texture=None))
    np.savez_compressed(os.path.join(out_dir, "model.npz"), **z)
    meta['cl_target'] = list(CL_TARGET_FACE)
    meta['triangles'] = sum(len(z['idx%d' % k]) // 3 for k in range(len(mats)))
    meta['source'] += "; the centerline target at PMA-2: STS-134 RNDZ checklist p149"
    with open(meta_path, "w") as f:
        json.dump(meta, f, indent=1)
    print("  the centerline target at PMA-2")


def prepare_vehicles(keys=None, rebuild=False):
    """The vehicles in portview/vehicles/ (one module each; see its
    __init__.py): each prepared unless it is already, or rebuild."""
    import vehicles
    from vehicles import kit
    mods = vehicles.discover()
    for key in (keys or sorted(mods)):
        if key not in mods:
            sys.exit("fetch_assets: no vehicle %r (vehicles: %s)" % (key, ", ".join(sorted(mods))))
        out = os.path.join(CACHE, "models", key)
        if os.path.exists(os.path.join(out, "model.json")) and not rebuild:
            continue
        print("vehicle", key)
        made = mods[key].build(kit)
        if os.path.isdir(out):
            import shutil
            shutil.rmtree(out)
        write_model(key, made['meta'], made['parts'])


def prepare_site_fine(key):
    """The fine ring (+-1.5 km, ~0.37 m) for a site already prepared."""
    import json
    site = SITES[key]
    d = os.path.join(CACHE, "sites", key)
    meta_path = os.path.join(d, "ring.json")
    if not site.get('naip') or not os.path.exists(meta_path):
        return
    with open(meta_path) as f:
        meta = json.load(f)
    if 'fine' in meta:
        return
    Image = _image()
    half_km, source = FINE_RING
    b = ring_bounds(site, half_km)
    print("site %s fine ring: +-%g km from %s" % (key, half_km, source))
    img = fetch_mosaic(source, b, 4, site.get('naip_year'))
    if blank(img):
        print("  NAIP is blank here; no fine ring")
        meta['fine'] = None
        with open(meta_path, "w") as f:
            json.dump(meta, f, indent=1)
        return
    ring0 = meta['rings'][0]
    img = match_colours(img, b, Image.open(os.path.join(d, ring0['file'])), ring0['bounds'])
    img.save(os.path.join(d, "ringF.jpg"), quality=92, subsampling=0)
    meta['fine'] = dict(file="ringF.jpg", bounds=b, half_km=half_km, source=source)
    with open(meta_path, "w") as f:
        json.dump(meta, f, indent=1)


def prepare_site_patches(key):
    """More fine patches for a site already prepared: (lat, lon, half km) each,
    from NAIP, colour-matched to ring 0 or ring 1 (whichever covers them)."""
    import json
    site = SITES[key]
    d = os.path.join(CACHE, "sites", key)
    meta_path = os.path.join(d, "ring.json")
    if not site.get('patches') or not os.path.exists(meta_path):
        return
    with open(meta_path) as f:
        meta = json.load(f)
    have = meta.setdefault('patches', {})
    Image = _image()
    for name, (lat, lon, half_km) in site['patches'].items():
        if name in have:
            continue
        b = ring_bounds(dict(lat=lat, lon=lon), half_km)
        print("site %s patch %s: +-%g km from naip" % (key, name, half_km))
        img = fetch_mosaic('naip', b, 4, site.get('naip_year'))
        if blank(img):
            print("  NAIP is blank here; no patch")
            continue
        r0 = meta['rings'][0]
        inside0 = (r0['bounds'][0] <= b[0] and b[2] <= r0['bounds'][2] and
                   r0['bounds'][1] <= b[1] and b[3] <= r0['bounds'][3])
        parent = r0 if inside0 else meta['rings'][1]
        img = match_colours(img, b, Image.open(os.path.join(d, parent['file'])), parent['bounds'])
        f = "patch_%s.jpg" % name
        img.save(os.path.join(d, f), quality=92, subsampling=0)
        have[name] = dict(file=f, bounds=b, half_km=half_km, source='naip')
        with open(meta_path, "w") as fp:
            json.dump(meta, fp, indent=1)


DEM_URL = ("https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/"
           "exportImage?bbox=%.7f,%.7f,%.7f,%.7f&bboxSR=4326&imageSR=4326&size=%d,%d"
           "&format=tiff&pixelType=F32&noData=-9999&interpolation=RSP_BilinearInterpolation&f=image")
DEM_PX = 2048


def fetch_heights(bounds, n):
    """USGS 3DEP's bare-earth heights (m, NAVD88: sea level, as PASS's site
    heights are) over a box, n x n, rows north first; 0 where it has none
    (the sea, other countries)."""
    import io
    import certifi
    ctx = ssl.create_default_context(cafile=certifi.where())
    Image = _image()
    for attempt in range(4):
        try:
            with urllib.request.urlopen(DEM_URL % (tuple(bounds) + (n, n)), context=ctx, timeout=300) as r:
                data = r.read()
            break
        except Exception as e:                  # noqa: BLE001 -- the service is flaky
            print("  retrying (%s)" % e)
    else:
        sys.exit("fetch_assets: could not fetch 3DEP heights")
    # A tiled, uncompressed float TIFF, which Pillow's float decoder mangles:
    # assembled here from its tiles.
    im = Image.open(io.BytesIO(data))
    order = '<f4' if data[:2] == b'II' else '>f4'
    w, h = im.size
    out = np.zeros((h + 512, w + 512), np.float32)
    for t in im.tile:
        if t.codec_name != 'raw':
            sys.exit("fetch_assets: 3DEP sent %s-compressed tiles" % t.codec_name)
        x0, y0, x1, y1 = t.extents
        tw, th = x1 - x0, y1 - y0
        if t.offset == 0:                       # a tile with no data at all: left out
            continue
        out[y0:y0 + th, x0:x0 + tw] = np.frombuffer(data[t.offset:t.offset + tw * th * 4], order).reshape(th, tw)
    out = out[:h, :w]
    out[~np.isfinite(out) | (out < -100.0) | (out > 9000.0)] = 0.0     # its no-data, -9999
    return out


def prepare_site_heights(key):
    """The ground's heights under a site's rings 0-2 (3DEP), for portview's
    terrain: the launch pads' mounds, and the mountains round Edwards and
    White Sands."""
    import json
    d = os.path.join(CACHE, "sites", key)
    meta_path = os.path.join(d, "ring.json")
    if not os.path.exists(meta_path):
        return
    with open(meta_path) as f:
        meta = json.load(f)
    if not meta.get('heights'):
        files = []
        for k in range(3):
            b = meta['rings'][k]['bounds']
            print("site %s heights %d: +-%g km from 3DEP" % (key, k, meta['rings'][k]['half_km']))
            f = "height%d.npy" % k
            np.save(os.path.join(d, f), fetch_heights(b, DEM_PX))
            files.append(f)
        meta['heights'] = files
    # And finer under the launch pads (their mounds, ~2 m).
    for name, pa in meta.get('patches', {}).items():
        if 'height' not in pa:
            print("site %s heights under %s: +-%g km from 3DEP" % (key, name, pa['half_km']))
            f = "height_%s.npy" % name
            np.save(os.path.join(d, f), fetch_heights(pa['bounds'], 1024))
            pa['height'] = f
    with open(meta_path, "w") as fp:
        json.dump(meta, fp, indent=1)


def rematch_site(key):
    """Match a prepared site's rings' colours again (as match_colours now
    does), from the coarsest inward, then its fine patches; no downloads."""
    import json
    d = os.path.join(CACHE, "sites", key)
    meta_path = os.path.join(d, "ring.json")
    if not os.path.exists(meta_path):
        return
    Image = _image()
    with open(meta_path) as f:
        meta = json.load(f)
    rings = meta['rings']
    print("site %s: matching colours again" % key)
    for k in range(len(rings) - 2, -1, -1):
        r, parent = rings[k], rings[k + 1]
        img = match_colours(Image.open(os.path.join(d, r['file'])), r['bounds'],
                            Image.open(os.path.join(d, parent['file'])), parent['bounds'])
        img.save(os.path.join(d, r['file']), quality=92, subsampling=0)
    patches = ([meta['fine']] if meta.get('fine') else []) + list(meta.get('patches', {}).values())
    r0 = rings[0]
    for pa in patches:
        b = pa['bounds']
        inside0 = (r0['bounds'][0] <= b[0] and b[2] <= r0['bounds'][2] and
                   r0['bounds'][1] <= b[1] and b[3] <= r0['bounds'][3])
        parent = r0 if inside0 else rings[1]
        img = match_colours(Image.open(os.path.join(d, pa['file'])), b,
                            Image.open(os.path.join(d, parent['file'])), parent['bounds'])
        img.save(os.path.join(d, pa['file']), quality=92, subsampling=0)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--keep-downloads", action="store_true",
                    help="keep the original downloads beside the prepared files")
    ap.add_argument("--months", default="1,2,3,4,5,6,7,8,9,10,11,12", metavar="LIST",
                    help="the Blue Marble months to prepare (default all twelve)")
    ap.add_argument("--sites", default=",".join(SITES), metavar="LIST",
                    help="the landing sites to prepare imagery for (default %s)" % ",".join(SITES))
    ap.add_argument("--vehicles", metavar="LIST",
                    help="only prepare these vehicles (portview/vehicles/; 'all' for every one)")
    ap.add_argument("--rebuild", action="store_true",
                    help="with --vehicles, prepare them again even if they are already")
    ap.add_argument("--rematch", action="store_true",
                    help="only match the prepared sites' ring colours again (no downloads)")
    args = ap.parse_args()
    if args.vehicles:
        prepare_vehicles(None if args.vehicles == 'all' else
                         [k.strip() for k in args.vehicles.split(",") if k.strip()], args.rebuild)
        return
    if args.rematch:
        for key in [k.strip() for k in args.sites.split(",") if k.strip()]:
            rematch_site(key)
        return
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
    for key in MODELS:
        prepare_model(key, args.keep_downloads)
    prepare_iss_visitors(args.keep_downloads)
    prepare_iss_cl_target()
    prepare_iss_radiator_damage()
    prepare_vehicles()
    for key in [k.strip() for k in args.sites.split(",") if k.strip()]:
        if key not in SITES:
            sys.exit("fetch_assets: no site %r (sites: %s)" % (key, ", ".join(SITES)))
        prepare_site(key)
        prepare_site_fine(key)
        prepare_site_patches(key)
        prepare_site_heights(key)
    print("portview assets ready in", CACHE)


if __name__ == "__main__":
    main()
