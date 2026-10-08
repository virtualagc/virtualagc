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

HST_URL = ("https://raw.githubusercontent.com/nasa/NASA-3D-Resources/master/3D%20Models/"
           "Hubble%20Space%20Telescope%20(A)/Hubble%20Space%20Telescope%20(A).glb")
# Hubble, in inches: the aperture at +z (the 3.0 m light shield; the 4.3 m
# aft shroud, with WFC3's bay, at z 0-200), the solar arrays along x.  This
# takes it to its V1 (toward the aperture), V2 (along the arrays), V3, in
# metres, about the middle of its length.
MIR_URL = ("https://raw.githubusercontent.com/nasa/NASA-3D-Resources/master/3D%20Models/"
           "Mir/Mir.glb")
# Mir: ~0.0221 m a unit (its core module's 4.15 m across is ~188 units),
# the core along y (+y toward the docking node, at y ~520), the axis at
# x 461, z -940.  To +X along the core toward the node, +Y = model x,
# +Z = -model z; origin in the middle of the complex (its extent's centre,
# 4.9 m aft of the node -- standing in for the centre of mass, which a
# vehicle's state is of).
MIR_SCALE = 0.0221
MIR_ROOT = np.array([[0.0, 1.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, -1.0]]) * MIR_SCALE
MIR_ORIGIN = np.array([449.0, 298.0, -940.0])
HST_ROOT = np.array([[0.0, 0.0, 1.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0]]) * INCH
HST_ORIGIN = np.zeros(3)                  # its file already centres it

MODELS = {
    'iss': dict(url=ISS_URL, glb="iss-igoal.glb", root=ISS_ROOT, origin=np.zeros(3),
                exclude=ISS_NOT_2011, name="ISS, STS-134 (May 2011)",
                frame="ISS analysis: +X fwd, +Y stbd, +Z nadir; m",
                source="NASA 3D Resources, ISS (D) (IGOAL)"),
    'gantry': dict(url=GANTRY_URL, glb="gantry.glb", root=GANTRY_ROOT, origin=GANTRY_ORIGIN,
                   exclude=set(), name="LC-39 pad structures (Shuttle era)",
                   frame="pad east-north-up; m; origin on the ground under the stack",
                   source="NASA 3D Resources, Gantry"),
    'hst': dict(url=HST_URL, glb="hst.glb", root=HST_ROOT, origin=HST_ORIGIN, exclude=set(),
                name="Hubble Space Telescope (after SM4, 2009)",
                frame="HST V1 (toward the aperture), V2 (along the arrays), V3; m; mid-length",
                source="NASA 3D Resources, Hubble Space Telescope (A)",
                mag_1000km=1.5),            # ~2.2 half lit (the satellite catalogues' standard)
    'mir': dict(url=MIR_URL, glb="mir.glb", root=MIR_ROOT, origin=MIR_ORIGIN, exclude=set(),
                name="Mir (a simple model: core, node, Kvant, Kristall, Spektr, Priroda, Soyuz)",
                frame="Mir: +X along the core toward the node, +Y, +Z; m; origin mid-complex",
                source="NASA 3D Resources, Mir", mag_1000km=-0.8),
}


# Satellites the Shuttle visited that have no published model: simple
# shapes to their published dimensions, as each was met (antennas stowed on
# the HS-376s, retrieved by STS-51A; Leasat 3's deployed, repaired on
# STS-51I).  Approximate -- shapes and colours, not details.  Each: name,
# NORAD id, frame, brightness, parts (material, rgb, shape, dimensions, m):
# 'cyl' (radius, x0, x1) along +X; 'cone' (r0, r1, x0, x1); 'box' (centre,
# size); 'disc' (radius, x) facing +X.  A disc on a cylinder's end stands
# 5 mm off its cap: in the cap's plane the two fought for the depth, and
# the end flashed in wedges of both colours.
HS376 = (('solar drum', (0.04, 0.05, 0.10), 'cyl', (1.08, -1.41, 0.40)),
         ('solar skirt', (0.04, 0.05, 0.10), 'cyl', (1.07, 0.40, 1.41)),
         ('forward barrier', (0.75, 0.62, 0.30), 'disc', (1.08, 1.415)),
         ('antenna mast', (0.80, 0.80, 0.80), 'cyl', (0.25, 1.41, 2.10)),
         ('stowed reflector', (0.85, 0.85, 0.85), 'cyl', (0.85, 1.80, 1.95)),
         ('apogee motor nozzle', (0.25, 0.25, 0.25), 'cone', (0.20, 0.45, -1.41, -2.00)),
         ('aft barrier', (0.75, 0.62, 0.30), 'disc', (1.08, -1.415)))
PROCEDURAL = {
    'westar6': dict(norad=14688, name="Westar 6 (HS-376; approximate)", parts=HS376, mag_1000km=3.0,
                    frame="HS-376: +X along the spin axis toward the antenna; m; mid-drum"),
    'palapab2': dict(norad=14692, name="Palapa B2 (HS-376; approximate)", parts=HS376, mag_1000km=3.0,
                     frame="HS-376: +X along the spin axis toward the antenna; m; mid-drum"),
    'leasat3': dict(norad=15643, name="Leasat 3 (Syncom IV; approximate)", mag_1000km=2.0,
                    frame="Leasat: +X along the spin axis toward the antennas; m; mid-drum",
                    parts=(('solar drum', (0.04, 0.05, 0.10), 'cyl', (2.13, -1.40, 1.40)),
                           ('forward deck', (0.80, 0.80, 0.80), 'disc', (2.13, 1.405)),
                           ('aft deck', (0.75, 0.62, 0.30), 'disc', (2.13, -1.405)),
                           ('UHF helix', (0.85, 0.85, 0.85), 'cyl', (0.30, 1.40, 3.30)),
                           ('UHF dish', (0.90, 0.90, 0.90), 'cone', (0.15, 0.85, 1.40, 1.80)),
                           ('omni', (0.80, 0.80, 0.80), 'cyl', (0.06, 3.30, 3.90)),
                           ('liquid motor', (0.30, 0.30, 0.30), 'cone', (0.30, 0.60, -1.40, -2.20)))),
    'smm': dict(norad=11703, name="Solar Maximum Mission (approximate)", mag_1000km=2.0,
                frame="SMM: +X along the instruments' axis (toward the Sun); m; mid-length",
                parts=(('MMS bus', (0.80, 0.80, 0.78), 'cyl', (1.15, -2.00, -0.50)),
                       ('instrument module', (0.75, 0.62, 0.30), 'cyl', (1.00, -0.50, 2.00)),
                       ('Sun end', (0.20, 0.20, 0.20), 'disc', (1.00, 2.005)),
                       ('solar array +Y', (0.04, 0.05, 0.10), 'box', ((-1.2, 3.3, 0.0), (1.5, 4.2, 0.04))),
                       ('solar array -Y', (0.04, 0.05, 0.10), 'box', ((-1.2, -3.3, 0.0), (1.5, 4.2, 0.04))),
                       ('high-gain mast', (0.80, 0.80, 0.80), 'cyl', (0.05, -2.00, -3.20)),
                       ('grapple pin', (0.80, 0.80, 0.80), 'box', ((-1.25, 0.0, 1.20), (0.10, 0.10, 0.25))))),
}


def shape_mesh(kind, dims, n=48):
    """Corner points (k, 3) and triangles of a simple shape (see PROCEDURAL)."""
    a = np.linspace(0.0, 2.0 * np.pi, n, endpoint=False)
    c, s = np.cos(a), np.sin(a)
    if kind in ('cyl', 'cone'):
        r0, r1, x0, x1 = (dims[0], dims[0], dims[1], dims[2]) if kind == 'cyl' else dims
        ring0 = np.column_stack([np.full(n, x0), r0 * c, r0 * s])
        ring1 = np.column_stack([np.full(n, x1), r1 * c, r1 * s])
        pts = np.vstack([ring0, ring1, [[x0, 0, 0]], [[x1, 0, 0]]])
        tris = []
        for i in range(n):
            j = (i + 1) % n
            tris += [(i, j, n + j), (i, n + j, n + i), (2 * n, j, i), (2 * n + 1, n + i, n + j)]
        return pts, np.array(tris)
    if kind == 'disc':
        r, x = dims
        pts = np.vstack([np.column_stack([np.full(n, x), r * c, r * s]), [[x, 0, 0]]])
        return pts, np.array([(n, i, (i + 1) % n) for i in range(n)])
    centre, size = (np.array(v, float) for v in dims)
    corners = np.array([[i, j, k] for i in (-0.5, 0.5) for j in (-0.5, 0.5) for k in (-0.5, 0.5)])
    pts = centre + corners * size
    quads = ((0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3))
    return pts, np.array([t for q in quads for t in ((q[0], q[1], q[2]), (q[0], q[2], q[3]))])


def prepare_procedural(key):
    import json
    spec = PROCEDURAL[key]
    out_dir = os.path.join(CACHE, "models", key)
    if os.path.exists(os.path.join(out_dir, "model.json")):
        return
    os.makedirs(out_dir, exist_ok=True)
    arrays, mats = {}, []
    for k, (name, rgb, kind, dims) in enumerate(spec['parts']):
        pts, tris = shape_mesh(kind, dims)
        v = pts[tris].reshape(-1, 3)                  # each triangle its own corners: flat shading
        fn = np.cross(pts[tris[:, 1]] - pts[tris[:, 0]], pts[tris[:, 2]] - pts[tris[:, 0]])
        fn /= np.maximum(np.linalg.norm(fn, axis=1, keepdims=True), 1e-12)
        arrays['pos%d' % k] = v.astype(np.float32)
        arrays['nrm%d' % k] = np.repeat(fn, 3, axis=0).astype(np.float32)
        arrays['uv%d' % k] = np.zeros((len(v), 2), np.float32)
        arrays['idx%d' % k] = np.arange(len(v), dtype=np.uint32)
        mats.append(dict(name=name, color=list(rgb) + [1.0], metallic=0.0, texture=None))
    np.savez_compressed(os.path.join(out_dir, "model.npz"), **arrays)
    with open(os.path.join(out_dir, "model.json"), "w") as f:
        json.dump(dict(name=spec['name'], frame=spec['frame'], norad=spec['norad'],
                       source="simple shapes to published dimensions (fetch_assets.py)",
                       mag_1000km=spec['mag_1000km'], materials=mats,
                       triangles=sum(len(a) // 3 for n_, a in arrays.items() if n_.startswith('idx'))),
                  f, indent=1)
    print("model %s: %s" % (key, spec['name']))


def prepare_iss(keep):
    prepare_model('iss', keep)


def prepare_model(key, keep):
    import io
    import json
    spec = MODELS[key]
    out_dir = os.path.join(CACHE, "models", key)
    if os.path.exists(os.path.join(out_dir, "model.json")):
        return
    try:
        import DracoPy
        import pygltflib
    except ImportError:
        sys.exit("fetch_assets: pip install DracoPy pygltflib (needed once, to convert models)")
    Image = _image()
    src = download(spec['url'], os.path.join(CACHE, "models", spec['glb']))
    print("converting", os.path.basename(src))
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

    groups = {}                                  # material -> lists of arrays
    root = g.scenes[g.scene or 0].nodes[0]
    top = np.eye(4)
    top[:3, :3] = spec['root']
    top[:3, 3] = -spec['root'] @ spec['origin']

    def walk(i, parent):
        n = g.nodes[i]
        if n.name in spec['exclude']:
            return
        w = parent @ local(n)
        if n.mesh is not None:
            nrm_m = np.linalg.inv(w[:3, :3]).T
            for p in g.meshes[n.mesh].primitives:
                ext = (p.extensions or {}).get('KHR_draco_mesh_compression')
                if not ext:
                    continue                     # (every primitive in this model is Draco)
                bv = g.bufferViews[ext['bufferView']]
                o = bv.byteOffset or 0
                d = DracoPy.decode(blob[o:o + bv.byteLength])
                pts = np.asarray(d.points, np.float64).reshape(-1, 3)
                nrm = (np.asarray(d.normals, np.float64).reshape(-1, 3) if d.normals is not None
                       else np.zeros_like(pts))
                uv = (np.asarray(d.tex_coord, np.float32).reshape(-1, 2) if d.tex_coord is not None
                      else np.zeros((len(pts), 2), np.float32))
                pos = pts @ w[:3, :3].T + w[:3, 3]
                nrm = nrm @ nrm_m.T
                nrm /= np.maximum(np.linalg.norm(nrm, axis=1, keepdims=True), 1e-12)
                groups.setdefault(p.material, []).append(
                    (pos.astype(np.float32), nrm.astype(np.float32), uv,
                     np.asarray(d.faces, np.uint32).reshape(-1, 3)))
        for c in n.children or []:
            walk(c, w)

    for c in g.nodes[root].children or []:
        walk(c, top)
    os.makedirs(out_dir, exist_ok=True)
    arrays, mats = {}, []
    for k, (mi, parts) in enumerate(sorted(groups.items(), key=lambda kv: (kv[0] is None, kv[0] or 0))):
        base, n = 0, []
        for pos, nrm, uv, faces in parts:
            n.append(faces + base)
            base += len(pos)
        arrays['pos%d' % k] = np.vstack([p[0] for p in parts])
        arrays['nrm%d' % k] = np.vstack([p[1] for p in parts])
        arrays['uv%d' % k] = np.vstack([p[2] for p in parts])
        arrays['idx%d' % k] = np.vstack(n).ravel()
        if mi is None:                           # no material: plain light grey
            mats.append(dict(name="(none)", color=[0.7, 0.7, 0.7, 1.0], metallic=0.0, texture=None))
            continue
        mat = g.materials[mi]
        pbr = mat.pbrMetallicRoughness
        entry = dict(name=mat.name, color=list(pbr.baseColorFactor or [1, 1, 1, 1]),
                     metallic=pbr.metallicFactor if pbr.metallicFactor is not None else 1.0,
                     texture=None)
        if pbr.baseColorTexture is not None:
            t = g.textures[pbr.baseColorTexture.index]
            srcimg = ((t.extensions or {}).get('EXT_texture_webp') or {}).get('source', t.source)
            im = g.images[srcimg]
            bv = g.bufferViews[im.bufferView]
            o = bv.byteOffset or 0
            img = Image.open(io.BytesIO(blob[o:o + bv.byteLength])).convert("RGB")
            if max(img.size) > 2048:
                f = 2048.0 / max(img.size)
                img = img.resize((max(1, int(img.size[0] * f)), max(1, int(img.size[1] * f))),
                                 Image.LANCZOS)
            entry['texture'] = "tex%d.jpg" % k
            img.save(os.path.join(out_dir, entry['texture']), quality=90)
        mats.append(entry)
    np.savez_compressed(os.path.join(out_dir, "model.npz"), **arrays)
    tris = sum(len(arrays['idx%d' % k]) // 3 for k in range(len(mats)))
    with open(os.path.join(out_dir, "model.json"), "w") as f:
        extra = {'mag_1000km': spec['mag_1000km']} if 'mag_1000km' in spec else {}
        json.dump(dict(name=spec['name'], frame=spec['frame'], source=spec['source'],
                       triangles=tris, materials=mats, **extra), f, indent=1)
    print("  %d triangles in %d materials" % (tris, len(mats)))
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
# Their textured surfaces, as plain colours: the Soyuz and Progress blankets,
# and the solar cells.
VISITOR_COLOURS = {'soyuz-side': (0.27, 0.28, 0.25), 'progress-side': (0.27, 0.28, 0.25),
                   'soyuz-pan': (0.05, 0.07, 0.16), 'soyuz-panR': (0.05, 0.07, 0.16),
                   'progress-pan': (0.05, 0.07, 0.16), 'progress-panR': (0.05, 0.07, 0.16),
                   'ATV-panels': (0.05, 0.07, 0.16)}


def read_lwo(path):
    """A LightWave LWO2 object: [(surface, rgb, points (n, 3), triangles)],
    every polygon's corners its own points (flat shading), all layers."""
    import struct
    data = open(path, 'rb').read()
    if data[:4] != b'FORM' or data[8:12] != b'LWO2':
        sys.exit("fetch_assets: %s is not an LWO2 object" % path)

    def vx(b, o):                       # LightWave's variable-length index
        if b[o] == 0xFF:
            return struct.unpack('>I', b[o:o + 4])[0] & 0xFFFFFF, o + 4
        return struct.unpack('>H', b[o:o + 2])[0], o + 2

    def strings(b, o):                  # NUL-terminated, padded to even
        e = b.index(b'\0', o)
        return b[o:e].decode('latin-1'), e + 1 + ((e + 1 - o) & 1)

    pos, end = 12, 8 + struct.unpack('>I', data[4:8])[0]
    tags, colours, layers, cur = [], {}, [], None
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
        elif cid == b'SURF':
            name, o = strings(b, 0)
            _, o = strings(b, o)
            rgb = (0.7, 0.7, 0.7)
            while o + 6 <= len(b):
                sid, ss = b[o:o + 4], struct.unpack('>H', b[o + 4:o + 6])[0]
                if sid == b'COLR':
                    rgb = struct.unpack('>3f', b[o + 6:o + 18])
                o += 6 + ss + (ss & 1)
            colours[name] = rgb
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
    return [(name, colours.get(name, (0.7, 0.7, 0.7)), np.vstack(pts), np.array(tris, np.uint32))
            for name, (pts, tris) in surfaces.items()]


def prepare_iss_visitors(keep):
    """Add Pirs and the vehicles docked in May 2011 (Soyuz TMA-20 and -21,
    Progress M-10M, ATV-2) to the prepared ISS model, which lacks them."""
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
    files = sorted({v[1] for v in ISS_VISITORS})
    subprocess.run([tool, "x", "-y", "-o" + work, src] + ["Objects/Modules/" + f for f in files],
                   check=True, stdout=subprocess.DEVNULL)
    z = dict(np.load(os.path.join(out_dir, "model.npz")))
    mats = meta['materials']
    placed = {}
    for name, f, probe, across, port, inward, across_iss, depth in ISS_VISITORS:
        parts = read_lwo(os.path.join(work, "Objects", "Modules", f))
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
        for surf, rgb, pts, tris in parts:
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
            z['uv%d' % k] = np.zeros((len(pos), 2), np.float32)
            z['idx%d' % k] = tris.ravel()
            mats.append(dict(name="%s: %s" % (name, surf), color=list(VISITOR_COLOURS.get(surf, rgb)) + [1.0],
                             metallic=0.0, texture=None))
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
    ap.add_argument("--rematch", action="store_true",
                    help="only match the prepared sites' ring colours again (no downloads)")
    args = ap.parse_args()
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
    for key in PROCEDURAL:
        prepare_procedural(key)
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
