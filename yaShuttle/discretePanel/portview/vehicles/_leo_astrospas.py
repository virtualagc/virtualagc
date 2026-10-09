"""The ASTRO-SPAS carrier (MBB/DASA's Shuttle Pallet Satellite of the
1990s: ORFEUS-SPAS on STS-51 and STS-80, CRISTA-SPAS on STS-66 and STS-85),
and the instrument fits that made each flight's look.

The carrier, as the flight and processing photographs show it: a long box of
carbon-fibre struts under beige-white beta-cloth blankets, 4.4 m across the
payload bay (Y) between the longeron trunnions, 1.9 m along it (X), 1.6 m
deep (Z) in two tiers -- the instrument tier (0.85 m) on the side away from
the keel, and the keel tier (0.75 m) whose ends are cut back at 45 degrees
so that its keel face is only 2.9 m long.  Each long (+-X) face is five bays
by two tiers, framed by blanketed struts: at the ends mirror radiators
(blue, taped in a diamond lattice) or silver blankets; in the middle the
white plates with the DARA and NASA marks (instrument tier) and the prime
contractor's (keel tier: "Deutsche Aerospace" to 1994, "Daimler-Benz
Aerospace" after); black vent holes through the blankets.  On each end
(+-Y) a yellow shield-shaped trunnion fitting carries the longeron
trunnion; under the keel face four struts meet at the keel pin 1.0 m below;
the grapple fixture stands on the instrument side near the +Y end.  Battery
powered: no solar wings.

Measured off s85e5096 (the +X face, with the keel tier's chamfers and the
bays), KSC-97PC1005 (the same face in its stand: the two tiers and the keel
struts), KSC-97PC1192 (from above in the bay: the 1.9 m depth), sts085-706-051
and sts085-722-087 (the ends and their yellow fittings), sts066-96-030 and
sts066-129-043 (STS-66), sts080-704-008 and sts080-719-005 (ORFEUS-SPAS II),
and the flight article in the Deutsches Museum; scaled to the bay's trunnion
span.
"""
import math

import numpy as np

from . import _leo_util as U

BEIGE = (0.76, 0.72, 0.63)        # the beta-cloth outer blankets, a little yellowed
BEIGE_GOLD = (0.74, 0.65, 0.50)   # as STS-66's photographs show them (sts066-129-043)
SILVER = (0.60, 0.61, 0.63)
OSR = (0.10, 0.11, 0.16)          # mirror radiators: they show the black sky (old name, kept)
YELLOW = (0.78, 0.58, 0.08)
STRUT = (0.80, 0.77, 0.69)

DX, DY, DZ = 1.9, 4.4, 1.6
HX, HY, HZ = DX / 2, DY / 2, DZ / 2
Z_TIER = -0.05                    # the keel tier below it, the instrument tier above
HY_KEEL = 1.45                    # half the keel face's length (the 45-degree chamfers)
BAYS = (-2.2, -1.47, -0.67, 0.67, 1.47, 2.2)
APEX = np.array([0.0, 0.0, -HZ - 1.0])
GF_AT = np.array([0.15, 1.6, HZ])            # the grapple fixture's base, on the instrument side
TRUNNION_Z = 0.55


def half_length(z):
    """The body's half-length (Y) at height z (the keel tier's chamfers)."""
    if z >= Z_TIER:
        return HY
    return HY_KEEL + (z + HZ) * (HY - HY_KEEL) / (Z_TIER + HZ)


# ------------------------------------------------------------------ textures
_TEX = {}


def _srgb(a):
    return (np.clip(a, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)


def tex_osr_lattice(size=256, blue=(0.07, 0.10, 0.25), lines=2, seed=71):
    """A mirror radiator taped in a diamond lattice (s85e5096): dark blue
    (the sky it reflects, a little of the Earth's blue), white tape lines
    crossing diagonally, `lines` diamonds to a repeat.  Use with a white
    part colour: the texture carries the colour."""
    key = ('osr', size, blue, lines, seed)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    g = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:size, 0:size] / size
    base = np.ones((size, size, 3)) * np.asarray(blue)
    base *= (0.85 + 0.3 * U._blur(g.standard_normal((size, size)), 12)[..., None] * 4).clip(0.6, 1.3)
    d1 = np.abs(((xx + yy) * lines) % 1.0 - 0.5)
    d2 = np.abs(((xx - yy) * lines) % 1.0 - 0.5)
    tape = np.maximum(d1, d2) > 0.5 - 0.014
    base[tape] = 0.85
    im = Image.fromarray(_srgb(base))
    _TEX[key] = im
    return im


def _font(px):
    from PIL import ImageFont
    try:
        return ImageFont.load_default(size=px)
    except Exception:                       # no FreeType: the small bitmap font
        return ImageFont.load_default()


def _text(draw, xy, s, px, fill, anchor="mm", fit=None):
    """Text centred at xy, px high, shrunk if need be to fit `fit` pixels wide."""
    f = _font(px)
    if fit:
        try:
            w = f.getbbox(s)[2]
            if w > fit:
                f = _font(max(8, int(px * fit / w)))
        except Exception:
            pass
    try:
        draw.text(xy, s, font=f, fill=fill, anchor=anchor)
    except Exception:
        draw.text(xy, s, font=f, fill=fill)


def tex_plate(kind, w=512, h=160):
    """The white mark plates, drawn: 'DARA', 'NASA' (the 1990s meatball),
    'NASA-worm' (the red logotype, 1993-94), 'Deutsche Aerospace' or
    'Daimler-Benz Aerospace' (grey-blue lettering after the four-pointed
    star).  Use with a white part colour."""
    key = ('plate', kind, w, h)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image, ImageDraw
    im = Image.new("RGB", (w, h), (236, 236, 230))
    d = ImageDraw.Draw(im)
    cx, cy = w // 2, h // 2
    if kind == 'DARA':
        _text(d, (cx - 22, cy + 4), "DARA", int(h * 0.70), (20, 20, 24), fit=int(w * 0.62))
        d.polygon([(cx + 40, cy + 48), (cx + 120, cy - 52), (cx + 132, cy - 52), (cx + 64, cy + 48)], fill=(225, 90, 20))
        d.polygon([(cx + 64, cy + 48), (cx + 132, cy - 52), (cx + 140, cy - 52), (cx + 80, cy + 48)], fill=(250, 200, 30))
    elif kind == 'NASA':
        r = int(h * 0.44)
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(20, 50, 140))
        _text(d, (cx, cy + 2), "NASA", int(r * 0.62), (245, 245, 245))
        d.arc((cx - r * 1.25, cy - r * 0.55, cx + r * 1.25, cy + r * 0.55), 200, 340, fill=(210, 30, 40), width=6)
    elif kind == 'NASA-worm':
        _text(d, (cx, cy + 4), "NASA", int(h * 0.80), (205, 35, 40), fit=int(w * 0.85))
    else:                                   # the contractor's plate
        s = kind
        sx = int(w * 0.12)
        for a in range(4):                  # the four-pointed star
            t = a * math.pi / 2
            d.polygon([(sx + 34 * math.cos(t), cy + 34 * math.sin(t)),
                       (sx + 6 * math.cos(t + 0.8), cy + 6 * math.sin(t + 0.8)),
                       (sx, cy), (sx + 6 * math.cos(t - 0.8), cy + 6 * math.sin(t - 0.8))], fill=(70, 95, 140))
        _text(d, (int(w * 0.57), cy), s, int(h * 0.40), (60, 70, 95), fit=int(w * 0.76))
    _TEX[key] = im
    return im


# ------------------------------------------------------------------- helpers
def plate_part(kit, name, rgb, image, centre, normal, right, size_u, size_v, thick=0.012):
    """A thin box facing `normal`, its outer face mapped once by `image`
    (u along `right`, v down: the image upright when seen from outside with
    `right` to the right)."""
    n = np.asarray(normal, float)
    r = np.asarray(right, float)
    up = np.cross(n, r)
    R = np.column_stack([n, r, up])
    m = U.place(kit, kit.box((thick, size_u, size_v)), R, centre)
    m = U.unshare(m)
    p = np.asarray(m[0])
    q = p - np.asarray(centre, float)
    uv = np.column_stack([q @ r / size_u + 0.5, 0.5 - q @ up / size_v]).astype(np.float32)
    return kit.part(name, rgb, m, texture=image, uv=uv)


def _xface_box(kit, sx, y0, y1, z0, z1, proud=0.012, thick=0.01):
    """A panel on the sx (+-1) X face over the bay y0..y1, z0..z1."""
    return kit.box((thick, abs(y1 - y0), abs(z1 - z0)),
                   (sx * (HX + proud), (y0 + y1) / 2, (z0 + z1) / 2))


def _xface_poly(kit, sx, poly, proud=0.012, thick=0.01):
    """A panel on the sx X face, the convex polygon [(y, z) ...] (CCW)."""
    x = sx * (HX + proud)
    return kit.prism(poly, x - thick / 2, x + thick / 2)


def dots(kit, spots, r=0.045):
    """Black vent holes in the blankets: [(point, outward normal)]."""
    return [U.place(kit, kit.disc(r, 0.0, n=12), U.frame_from(nrm), np.asarray(pt, float) + 0.004 * np.asarray(nrm, float))
            for pt, nrm in spots]


# ------------------------------------------------------------------- carrier
def carrier(kit, osr_faces=False, finish=BEIGE, logos=('DARA', 'NASA'), contractor="Daimler-Benz Aerospace",
            end_bays=None, osr_strip=False, logo_face=1, extra_dots=()):
    """The carrier's parts.  Body frame: X along the bay, Y across it, Z away
    from the keel; origin the box's centre.

    osr_faces: the end bays mirror radiators (True) or silver blankets
    (False; ORFEUS-SPAS's); end_bays overrides it per end, {+1: kind, -1:
    kind}.  logos: the instrument tier's two plates, left to right as seen
    from outside the logo face (keel down); contractor: the keel tier's
    plate.  osr_strip: the band of radiator under the plates (CRISTA-SPAS
    II).  logo_face: +1 or -1, the X face that carries the marks."""
    if end_bays is None:
        end_bays = {1: 'osr' if osr_faces else 'silver', -1: 'osr' if osr_faces else 'silver'}
    p = []
    # the body: one closed hexagonal prism (the keel tier's chamfered ends)
    sec = [(-HY, HZ), (-HY, Z_TIER), (-HY_KEEL, -HZ), (HY_KEEL, -HZ), (HY, Z_TIER), (HY, HZ)]
    if _ccw(sec) is False:
        sec = sec[::-1]
    body = kit.prism(sec, -HX, HX)
    p.append(U.tpart(kit, "carrier blankets", finish, body, U.tex_mli(61, seams=3, depth=0.32), tile=1.5, fine=0.4))

    # -- the long faces: radiators / silver panels / plates ---------------------
    osr_m, sil_m = [], []
    for sx in (-1, 1):
        for sy in (-1, 1):
            kind = end_bays[sy]
            tgt = osr_m if kind == 'osr' else sil_m
            y0, y1 = sorted((sy * 1.52, sy * 2.15))
            tgt.append(_xface_box(kit, sx, y0, y1, 0.0, HZ - 0.05))
            # the keel tier's end bay: a triangle under the chamfer
            tri = [(sy * 1.52, Z_TIER - 0.05), (sy * 2.12, Z_TIER - 0.05), (sy * 1.52, -HZ + 0.11)]
            if not _ccw([(y, z) for y, z in tri]):
                tri = tri[::-1]
            tgt.append(_xface_poly(kit, sx, tri))
        if sx != logo_face:
            sil_m.append(_xface_box(kit, sx, -0.62, 0.62, 0.05, HZ - 0.08))
    if osr_strip:
        osr_m.append(_xface_box(kit, logo_face, -0.62, 0.62, 0.47, 0.64))
    if osr_m:
        m = kit.merge(*osr_m)
        p.append(U.tpart(kit, "mirror radiators (taped)", (0.85, 0.85, 0.85), m, tex_osr_lattice(), tile=0.75,
                         axes=((0, 1, 0), (0, 0, 1))))
    if sil_m:
        p.append(U.tpart(kit, "silver blankets", SILVER, kit.merge(*sil_m), U.tex_mli(62, seams=1, depth=0.55), tile=0.9))
    # the plates on the logo face: seen from outside it, "right" is +Y on +X
    sx = logo_face
    right = np.array([0.0, float(sx), 0.0])
    n = np.array([float(sx), 0.0, 0.0])
    xs = sx * (HX + 0.012)
    left_kind, right_kind = logos
    p.append(plate_part(kit, "mark plate (%s)" % left_kind, (0.86, 0.86, 0.84), tex_plate(left_kind),
                        (xs, -0.31 * sx, 0.23), n, right, 0.60, 0.38))
    p.append(plate_part(kit, "mark plate (%s)" % right_kind, (0.86, 0.86, 0.84), tex_plate(right_kind),
                        (xs, 0.31 * sx, 0.23), n, right, 0.60, 0.38))
    p.append(plate_part(kit, "mark plate (%s)" % contractor, (0.86, 0.86, 0.84), tex_plate(contractor, 640, 160),
                        (xs, 0.0, -0.36), n, right, 1.22, 0.34))

    # -- the frame's struts, blanketed, standing on the faces ------------------
    st = []
    r = 0.032
    for sx in (-1, 1):
        x = sx * (HX + 0.02)
        st.append(kit.rod((x, -HY, HZ), (x, HY, HZ), r, n=8))
        st.append(kit.rod((x, -HY, Z_TIER), (x, HY, Z_TIER), r, n=8))
        st.append(kit.rod((x, -HY_KEEL, -HZ), (x, HY_KEEL, -HZ), r, n=8))
        for sy in (-1, 1):
            st.append(kit.rod((x, sy * HY, Z_TIER), (x, sy * HY_KEEL, -HZ), r, n=8))      # chamfer edge
            st.append(kit.rod((x, sy * HY, Z_TIER), (x, sy * HY, HZ), r, n=8))            # end post
            st.append(kit.rod((x, sy * 1.47, Z_TIER), (x, sy * 1.47, HZ), r * 0.8, n=8))
            st.append(kit.rod((x, sy * 0.67, -HZ), (x, sy * 0.67, HZ), r * 0.8, n=8))
    for sy in (-1, 1):                                                              # along X at the ends
        for z in (HZ, Z_TIER):
            st.append(kit.rod((-HX, sy * (HY + 0.01), z), (HX, sy * (HY + 0.01), z), r, n=8))
        st.append(kit.rod((-HX, sy * HY_KEEL, -HZ - 0.01), (HX, sy * HY_KEEL, -HZ - 0.01), r, n=8))
    p.append(kit.part("frame struts (blanketed)", STRUT, *st))

    # -- black vent holes ----------------------------------------------------
    sp = []
    for sx in (-1, 1):
        nrm = (sx, 0, 0)
        x = sx * HX
        for sy in (-1, 1):
            sp += [((x, sy * 1.15, -0.30), nrm), ((x, sy * 0.95, -0.55), nrm), ((x, sy * 1.07, 0.55), nrm)]
    sp += list(extra_dots)
    p.append(kit.part("vent holes", (0.02, 0.02, 0.02), *dots(kit, sp)))

    # -- the ends: yellow trunnion fittings and the longeron trunnions ---------
    yel, marks, pins = [], [], []
    shield = [(-0.30, 0.40), (0.30, 0.40), (0.22, 0.02), (0.11, -0.28), (0.0, -0.36), (-0.11, -0.28), (-0.22, 0.02)]
    for sy in (-1, 1):
        flip = -1.0 if sy > 0 else 1.0         # +Y (sts085-722-087): tip toward the instrument side; -Y (sts085-706-051): toward the keel
        zc = 0.40
        poly = [(px * sy, zc + flip * pz) for px, pz in shield]   # (x, z) on the end face
        if not _ccw(poly):
            poly = poly[::-1]
        y = sy * (HY + 0.02)
        pr = kit.prism(poly, -0.01, 0.01)                         # along X: (y, z) := (x, z)
        pr = (np.asarray(pr[0])[:, [1, 0, 2]] + (0, y, 0), pr[1])  # swap so it lies in the X-Z plane
        yel.append(pr)
        # the fitting's markings (a slot, dashes), 4 mm proud
        ys = sy * (HY + 0.034)
        marks.append(kit.box((0.035, 0.006, 0.30), (0.0, ys, zc - flip * 0.06)))
        for k in range(5):
            a = math.radians(-60 + 30 * k)
            marks.append(kit.box((0.08, 0.006, 0.025), (0.20 * math.sin(a), ys, zc + flip * (0.22 + 0.05 * math.cos(a)))))
        pins.append(U.trunnion(kit, (0.0, sy * (HY + 0.03), TRUNNION_Z), (0, sy, 0), 0.26, 0.041))
        pins.append(kit.along(kit.cylinder(0.075, 0.0, 0.05, n=16), (0, sy, 0), (0.0, sy * (HY + 0.03), TRUNNION_Z)))
    p.append(kit.part("trunnion fittings (yellow)", YELLOW, *yel))
    p.append(kit.part("fitting markings", (0.04, 0.04, 0.04), *marks))
    p.append(kit.part("trunnions", (0.82, 0.82, 0.82), *pins))

    # -- the keel struts: four legs from the keel face's corners ---------------
    legs = [kit.rod((sx * (HX - 0.04), sy * (HY_KEEL - 0.04), -HZ), APEX, 0.05, n=10)
            for sx in (-1, 1) for sy in (-1, 1)]
    legs.append(kit.box((0.36, 0.42, 0.16), APEX + (0, 0, 0.02)))
    legs.append(kit.rod(APEX + (0, -0.35, 0.05), APEX + (0, 0.35, 0.05), 0.035, n=8))
    p.append(kit.part("keel struts", STRUT, *legs))
    p.append(kit.part("keel pin", (0.82, 0.82, 0.82), U.trunnion(kit, APEX - (0, 0, 0.06), (0, 0, -1), 0.25, 0.05)))
    # three small blanketed boxes on the keel face (sts085-706-051)
    kb = [kit.box((0.36, 0.36, 0.26), (x, -1.0, -HZ - 0.13)) for x in (-0.48, 0.0, 0.48)]
    p.append(U.tpart(kit, "keel-face boxes", finish, kit.merge(*kb), U.tex_mli(63, seams=1, depth=0.4), tile=0.5))

    # -- the grapple fixture on the instrument side, near +Y -------------------
    for name, rgb, m in U.frgf(kit, GF_AT + (0, 0, 0.002), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    p.append(U.tpart(kit, "grapple box (gold foil)", U.GOLD_MLI, kit.box((0.22, 0.30, 0.20), GF_AT + (0.42, 0.0, 0.10)),
                     U.tex_mli(64, seams=0, depth=0.6), tile=0.3))
    # -- the S-band antennas: white posts with a ball, at opposite corners ----
    ant = []
    for base, d in ((( HX - 0.25, -HY - 0.02, HZ - 0.12), (0.0, -0.55, 0.83)),
                    ((-HX + 0.25, half_length(-0.45) + 0.02, -0.45), (0.0, 0.55, -0.83))):
        base, d = np.asarray(base, float), np.asarray(d, float) / np.linalg.norm(d)
        ant.append(kit.rod(base, base + 0.30 * d, 0.03, n=8))
        ant.append(kit.sphere(0.065, n=8, centre=base + 0.36 * d))
        ant.append(kit.along(kit.frustum(0.04, 0.0, 0.0, 0.12, n=8), d, base + 0.40 * d))
    p.append(kit.part("S-band antennas", (0.88, 0.88, 0.86), *ant))
    # a sun sensor's dome on the logo face
    p.append(kit.part("sun sensor", (0.85, 0.85, 0.85),
                      kit.sphere(0.05, n=8, centre=(logo_face * (HX + 0.01), -0.30 * logo_face, 0.70))))
    return p


def _ccw(poly):
    a = 0.0
    for (y0, z0), (y1, z1) in zip(poly, poly[1:] + poly[:1]):
        a += y0 * z1 - y1 * z0
    return a > 0
