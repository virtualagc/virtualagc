"""EURECA, the European Retrievable Carrier (NORAD 22065): deployed by
STS-46 (August 1992), retrieved by STS-57 (June 1993).

A box of carbon-fibre struts and titanium nodes under beta-cloth blankets:
4.2 m across the payload bay (Y; 4.6 m over the trunnions), 2.3 m along it
(X, the wings' axis) and 2.6 m deep (Z).  On each end (+-Y) the yellow
shield-shaped trunnion fitting (the same as the ASTRO-SPAS's) with the
longeron trunnion out of its top, a black sensor port above it, painted
radiators below; the keel struts and pin under the bottom; the experiments
on the top deck (+Z, the Sun side), whose -Y edge is bevelled and whose +Y
end steps down to the grapple fixture; the "EURECA / esa / MBB ERNO" plate
high on the +X face.  Two solar wings of five panels each, 1.4 x 3.4 m
(ESA's meteoroid survey of the returned panels), fold up against the +-X
faces into stacks that show the outer panel's cells; deployed, they stand
1.1 m out on V-shaped yokes, the wings 7 m long, cells to +Z.  Two
communication antennas on 2 m booms swing out from diagonally opposite top
corners.

ARRAYS_DEPLOYED picks the configuration: False (the default) is the
STS-57 retrieval -- the wings retracted and latched, the blankets browned
by eleven months of sunlight and outgassing (sts057-93-052, sts057-84-000AD),
the antenna booms not quite home (the EVA crew pushed them in before
berthing); True is the white, newly released vehicle of STS-46 with its
wings out (sts046-76-028, sts046-102-021, s46-08-010).

Proportions measured off sts046-76-028 (the deployed silhouette, scaled
by the panels' 1.4 m), sts057-84-000AD (the +X face berthed: the 3.4 m
stack across a 4.2 m face, the trunnions, the upper band and the plate),
s46-08-010 (the +Y face: the yellow fitting, the yokes' height) and
s92-41442 (Astrotech, 1991).  Two photographs eoPortal shows as
Eureca_Auto9 and Eureca_Auto5 are EURECA's own: the STS-46 release (2 Aug
1992, wings part-unfolded) and the STS-57 capture -- not LDEF's flights.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'eureca'
ARRAYS_DEPLOYED = False

DX, DY, DZ = 2.3, 4.2, 2.6
HX, HY, HZ = DX / 2, DY / 2, DZ / 2
Z_DECK = 0.85                       # the main box's top; the upper block above it to HZ
PANEL_SPAN, PANEL_W, N_PANELS = 1.4, 3.4, 5
HINGE_Z = -0.45                     # the wings' axis (s46-08-010)
STACK_Z = -0.52                     # the folded stack's centre (sts057-84-000AD)
WHITE_MLI = (0.80, 0.79, 0.75)      # STS-46, new
AGED_MLI = (0.70, 0.60, 0.45)       # STS-57: browned (sts057-93-052)
PAINT = (0.82, 0.82, 0.80)
YELLOW = (0.80, 0.60, 0.10)
KAPTON = (0.72, 0.47, 0.16)         # the panels' backs (STS-46 photographs: amber-gold)
TRUNNION_Z = 0.45


# ------------------------------------------------------------------ textures
_TEX = {}


def _srgb(a):
    return (np.clip(a, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)


def tex_panel_cells(w=1024, h=420, seed=21):
    """One wing panel's cell face (sts057-84-000AD): blue-black cells in ten
    strings across its 3.4 m, a fine silver grid of interconnects, the
    strings' gaps a little lighter.  Colour carried by the texture (use a
    white part colour)."""
    key = ('cells', w, h, seed)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    g = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:h, 0:w]
    base = np.ones((h, w, 3)) * np.array([0.035, 0.042, 0.085])
    base *= (0.8 + 0.4 * g.random((h // 6 + 1, w // 6 + 1))[yy // 6, xx // 6])[..., None]
    grid = ((xx % 12) == 0) | ((yy % 16) == 0)
    base[grid] = (0.30, 0.30, 0.32)
    strings = (xx % (w // 10)) < 3
    base[strings] = (0.55, 0.52, 0.45)
    edge = (xx < 4) | (xx > w - 5) | (yy < 4) | (yy > h - 5)
    base[edge] = (0.55, 0.40, 0.18)
    im = Image.fromarray(_srgb(base))
    _TEX[key] = im
    return im


def tex_panel_back(w=512, h=212):
    """A panel's back: amber Kapton over the frame's ribs."""
    key = ('back', w, h)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    yy, xx = np.mgrid[0:h, 0:w]
    v = 0.92 + 0.08 * np.sin(xx * 0.31) * np.sin(yy * 0.23)
    rib = ((xx % (w // 4)) < 4) | ((yy % (h // 2)) < 4) | (xx > w - 5) | (yy > h - 5)
    v = np.where(rib, 0.55, v)
    im = Image.fromarray(_srgb(np.stack([v, v, v], -1)))
    _TEX[key] = im
    return im


def tex_logo(w=256, h=256):
    """The EURECA / esa / MBB ERNO plate (sts057-84-000AD), drawn."""
    key = ('logo', w, h)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image, ImageDraw, ImageFont
    im = Image.new("RGB", (w, h), (238, 238, 232))
    d = ImageDraw.Draw(im)

    def font(px):
        try:
            return ImageFont.load_default(size=px)
        except Exception:
            return ImageFont.load_default()
    for s, y, px in (("EURECA", 0.20, 52), ("esa", 0.70, 34), ("MBB ERNO", 0.88, 22)):
        try:
            d.text((w / 2, h * y), s, font=font(px), fill=(15, 15, 15), anchor="mm")
        except Exception:
            d.text((w / 4, h * y), s, fill=(15, 15, 15))
    d.ellipse((w / 2 - 26, h * 0.45 - 26, w / 2 + 26, h * 0.45 + 26), fill=(15, 15, 15))
    d.ellipse((w / 2 - 13, h * 0.45 - 13, w / 2 + 13, h * 0.45 + 13), fill=(238, 238, 232))
    _TEX[key] = im
    return im


def quad(kit, name, rgb, image, centre, normal, right, su, sv, thick=0.01, fine=0.35):
    """A thin box facing `normal`, its outer face mapped once by `image`
    (upright seen from outside, `right` to the right); cut into pieces no
    longer than `fine` (see _leo_util.refine: the wing layers lie close)."""
    n, r = np.asarray(normal, float), np.asarray(right, float)
    up = np.cross(n, r)
    m = U.place(kit, kit.box((thick, su, sv)), np.column_stack([n, r, up]), centre)
    if fine:
        m = U.refine(m, fine)
    m = U.unshare(m)
    q = np.asarray(m[0]) - np.asarray(centre, float)
    uv = np.column_stack([q @ r / su + 0.5, 0.5 - q @ up / sv]).astype(np.float32)
    return kit.part(name, rgb, m, texture=image, uv=uv)


def _merge_parts(kit, name, rgb, parts_list, image):
    """Several quad() parts (same image) as one."""
    P, T, UV, base = [], [], [], 0
    for q in parts_list:
        P.append(q['pos'])
        T.append(np.asarray(q['idx']) + base)
        UV.append(q['uv'])
        base += len(q['pos'])
    return kit.part(name, rgb, (np.vstack(P), np.vstack(T)), texture=image, uv=np.vstack(UV))


# --------------------------------------------------------------------- build
def build(kit):
    dep = ARRAYS_DEPLOYED
    mli = WHITE_MLI if dep else AGED_MLI
    p = []
    # -- the body: the main box, the upper block (bevelled at -Y, stepped at +Y)
    body = kit.box((DX, DY, Z_DECK + HZ), (0, 0, (Z_DECK - HZ) / 2))
    upper = kit.prism([(-HY, Z_DECK - 0.05), (1.15, Z_DECK - 0.05), (1.15, HZ), (-HY + 0.40, HZ)], -HX + 0.05, HX - 0.05)
    step = kit.box((DX - 0.14, 0.52, 0.38), (0, 1.39, Z_DECK + 0.14))
    p.append(U.tpart(kit, "blankets", mli, kit.merge(body, upper, step), U.tex_mli(11, seams=2, depth=0.42), tile=1.4, fine=0.4))
    # the strut frame's edges, showing through the blankets' seams
    e = []
    for sy in (-1, 1):
        for sz in (-HZ, Z_DECK):
            e.append(kit.box((DX + 0.03, 0.05, 0.05), (0, sy * HY, sz)))
        for sx in (-1, 1):
            e.append(kit.box((0.05, 0.05, Z_DECK + HZ + 0.03), (sx * HX, sy * HY, (Z_DECK - HZ) / 2)))
    for sx in (-1, 1):
        for sz in (-HZ, Z_DECK):
            e.append(kit.box((0.05, DY + 0.03, 0.05), (sx * HX, 0, sz)))
    p.append(kit.part("frame edges", (0.40, 0.38, 0.34), *e))

    # -- the +X face's plate, sensor window, red patch -----------------------
    p.append(quad(kit, "EURECA plate", (0.86, 0.86, 0.84), tex_logo(), (HX - 0.04, 0.40, 1.07), (1, 0, 0), (0, 1, 0), 0.44, 0.44))
    p.append(kit.part("sensor window", (0.02, 0.02, 0.02), kit.box((0.012, 0.20, 0.20), (HX - 0.04, -1.45, 1.00))))
    p.append(kit.part("red patch", (0.55, 0.06, 0.05), kit.box((0.012, 0.13, 0.13), (HX + 0.006, 1.55, 0.62))))

    # -- the ends: yellow trunnion fittings, longeron trunnions, ports, radiators
    yel, pins, black, rad = [], [], [], []
    shield = [(-0.34, 0.50), (0.34, 0.50), (0.27, 0.05), (0.13, -0.33), (0.0, -0.43), (-0.13, -0.33), (-0.27, 0.05)]
    for sy in (-1, 1):
        pr = kit.prism(shield, -0.01, 0.01)
        pr = (np.asarray(pr[0])[:, [1, 0, 2]] + (0, sy * (HY + 0.02), 0), pr[1])
        yel.append(pr)
        pins.append(U.trunnion(kit, (0.0, sy * (HY + 0.03), TRUNNION_Z), (0, sy, 0), 0.26, 0.041))
        pins.append(kit.along(kit.cylinder(0.075, 0.0, 0.05, n=16), (0, sy, 0), (0.0, sy * (HY + 0.03), TRUNNION_Z)))
        black.append(kit.along(kit.disc(0.15, 0.0, n=20), (0, sy, 0), (0.55 * sy, sy * (HY + 0.006), 0.95)))
        black.append(kit.box((0.20, 0.012, 0.20), (0.0, sy * (HY + 0.016), -0.80)))
        rad.append(kit.box((DX - 0.30, 0.012, 0.62), (0.0, sy * (HY + 0.006), -0.95 + 0.0)))
    p.append(kit.part("trunnion fittings (yellow)", YELLOW, *yel))
    p.append(kit.part("fitting markings", (0.04, 0.04, 0.04),
                      *[kit.box((0.035, 0.008, 0.36), (0.0, sy * (HY + 0.035), 0.05)) for sy in (-1, 1)]))
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *pins))
    p.append(U.tpart(kit, "radiators (white paint)", PAINT, kit.merge(*rad), U.tex_panels(4, 2, seed=8, spread=0.08), tile=(1.0, 0.62)))
    p.append(kit.part("sensor ports", (0.02, 0.02, 0.02), *black))

    # -- the keel side: painted boxes, the keel struts and pin ----------------
    boxes = [kit.box((0.8, 1.0, 0.25), (-0.5, -1.35, -HZ - 0.125)),
             kit.box((0.7, 0.9, 0.30), (0.55, -1.25, -HZ - 0.15)),
             kit.box((0.9, 1.1, 0.20), (0.45, 1.25, -HZ - 0.10)),
             kit.box((0.6, 0.8, 0.28), (-0.6, 1.45, -HZ - 0.14))]
    p.append(U.tpart(kit, "keel-side boxes (white paint)", PAINT, kit.merge(*boxes), U.tex_panels(3, 3, seed=7), tile=0.8))
    apex = np.array([0.0, 0.0, -HZ - 0.65])
    legs = [kit.rod((sx * 0.85, sy * 0.45, -HZ), apex, 0.05, n=10) for sx in (-1, 1) for sy in (-1, 1)]
    p.append(kit.part("keel struts", (0.75, 0.75, 0.74), *legs))
    p.append(kit.part("keel pin", (0.80, 0.80, 0.80), U.trunnion(kit, apex, (0, 0, -1), 0.25, 0.05),
                      kit.box((0.22, 0.22, 0.10), apex)))

    # -- the top deck: experiments under blankets, a strut cage -----------------
    top = [kit.box((0.9, 1.0, 0.30), (-0.45, -0.85, HZ + 0.15)),
           kit.box((0.7, 0.8, 0.22), (0.55, -0.20, HZ + 0.11)),
           kit.box((1.0, 0.7, 0.18), (-0.30, 0.55, HZ + 0.09))]
    p.append(U.tpart(kit, "top-deck experiments", mli, kit.merge(*top), U.tex_mli(12, seams=1), tile=0.9))
    cage = []
    c0 = np.array([0.45, -1.15, HZ])
    for a in (-1, 1):
        for b in (-1, 1):
            cage.append(kit.rod(c0 + (0.35 * a, 0.35 * b, 0), c0 + (0.35 * a, 0.35 * b, 0.5), 0.02, n=6))
    for z in (0.0, 0.5):
        for (a0, b0), (a1, b1) in (((-1, -1), (1, -1)), ((1, -1), (1, 1)), ((1, 1), (-1, 1)), ((-1, 1), (-1, -1))):
            cage.append(kit.rod(c0 + (0.35 * a0, 0.35 * b0, z), c0 + (0.35 * a1, 0.35 * b1, z), 0.02, n=6))
    p.append(kit.part("instrument cage", (0.70, 0.70, 0.72), *cage))
    p.append(kit.part("cage instrument", (0.35, 0.35, 0.37), kit.box((0.40, 0.40, 0.30), c0 + (0, 0, 0.20))))
    cyl = kit.along(kit.cylinder(0.22, 0.0, 0.55, n=20), (0, 0, 1), (-0.45, 1.75 - 0.95, HZ))
    p.append(kit.part("experiment cylinder (white)", PAINT, cyl, smooth=False))
    # the grapple fixture on the +Y step, its gold box
    gf = np.array([0.30, 1.85, Z_DECK])
    for name, rgb, m in U.frgf(kit, gf + (0, 0, 0.002), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    p.append(U.tpart(kit, "grapple box (gold foil)", U.GOLD_MLI, kit.box((0.25, 0.28, 0.20), gf + (-0.45, 0.0, 0.10)),
                     U.tex_mli(13, seams=0, depth=0.6), tile=0.3))

    # -- the solar wings -------------------------------------------------------
    cells, backs, frames, yokes, bosses = [], [], [], [], []
    for sx in (-1, 1):
        if dep:
            root_x = sx * (HX + 1.10)
            hinge = np.array([sx * (HX + 0.25), 0.0, HINGE_Z])
            yokes.append(kit.rod((sx * HX, 0.0, HINGE_Z), hinge, 0.05, n=8))
            for sy in (-1, 1):
                yokes.append(kit.rod(hinge, (root_x, sy * (PANEL_W / 2 - 0.05), HINGE_Z), 0.035, n=8))
            yokes.append(kit.rod((root_x, -PANEL_W / 2, HINGE_Z), (root_x, PANEL_W / 2, HINGE_Z), 0.03, n=8))
            for k in range(N_PANELS):
                xc = root_x + sx * (k * (PANEL_SPAN + 0.03) + PANEL_SPAN / 2)
                cells.append(quad(kit, "solar cells", (0.95, 0.95, 0.95), tex_panel_cells(),
                                  (xc, 0.0, HINGE_Z + 0.010), (0, 0, 1), (0, 1, 0), PANEL_W, PANEL_SPAN, thick=0.012))
                backs.append(quad(kit, "panel back", KAPTON, tex_panel_back(),
                                  (xc, 0.0, HINGE_Z - 0.012), (0, 0, -1), (0, 1, 0), PANEL_W, PANEL_SPAN, thick=0.008))
        else:
            # the folded stack: five panels, cells of the outermost outward
            for k in range(N_PANELS):
                x = sx * (HX + 0.06 + 0.045 * k)
                backs.append(quad(kit, "panel back", KAPTON, tex_panel_back(), (x, 0.0, STACK_Z), (sx, 0, 0),
                                  (0, sx, 0), PANEL_W, PANEL_SPAN, thick=0.022))
            xo = sx * (HX + 0.06 + 0.045 * (N_PANELS - 1) + 0.017)
            cells.append(quad(kit, "solar cells", (0.95, 0.95, 0.95), tex_panel_cells(), (xo, 0.0, STACK_Z),
                              (sx, 0, 0), (0, sx, 0), PANEL_W, PANEL_SPAN, thick=0.004))
            for yy in (-1.15, 0.0, 1.15):
                for zz in (-0.42, 0.42):
                    bosses.append(kit.along(kit.cylinder(0.05, 0.0, 0.02, n=14), (sx, 0, 0), (xo, yy, STACK_Z + zz)))
            # the retracted yoke along the stack's top, the stack's side frames
            frames.append(kit.box((0.26, PANEL_W + 0.08, 0.05), (sx * (HX + 0.15), 0.0, STACK_Z + PANEL_SPAN / 2 + 0.04)))
            frames.append(kit.box((0.26, PANEL_W + 0.08, 0.04), (sx * (HX + 0.15), 0.0, STACK_Z - PANEL_SPAN / 2 - 0.03)))
            for sy in (-1, 1):
                frames.append(kit.box((0.26, 0.04, PANEL_SPAN + 0.10), (sx * (HX + 0.15), sy * (PANEL_W / 2 + 0.03), STACK_Z)))
    p.append(_merge_parts(kit, "solar cells", (0.95, 0.95, 0.95), cells, tex_panel_cells()))
    p.append(_merge_parts(kit, "panel backs (Kapton)", KAPTON, backs, tex_panel_back()))
    if yokes:
        p.append(kit.part("array yokes", (0.70, 0.50, 0.22), *yokes))
    if frames:
        p.append(kit.part("stack frames and yoke", (0.62, 0.55, 0.42), *frames))
    if bosses:
        p.append(kit.part("stack latches", (0.80, 0.80, 0.82), *bosses))

    # -- the communication antennas on their booms --------------------------
    ant = []
    for sx, sy in ((-1, 1), (1, -1)):
        root = np.array([sx * (HX - 0.12), sy * (HY - 0.12), Z_DECK + 0.05])
        out = np.array([sx * 0.78, sy * 0.60, 0.15])
        out /= np.linalg.norm(out)
        if dep:
            d = out
        else:                               # nearly home: 15 degrees short of lying along the deck edge
            stow = np.array([-sx * 1.0, 0.0, 0.0])
            t = math.radians(15.0)
            side = np.array([0.0, sy * 1.0, 0.0])
            d = stow * math.cos(t) + side * math.sin(t)
            d = d / np.linalg.norm(d) + np.array([0, 0, 0.12])
            d /= np.linalg.norm(d)
        ant.append(kit.rod(root, root + 2.0 * d, 0.03, n=8))
        tip = root + 2.0 * d
        ant.append(kit.box((0.22, 0.22, 0.16), tip))
        ant.append(kit.along(kit.frustum(0.05, 0.16, 0.0, 0.14, n=14), (0, 0, 1), tip + (0, 0, 0.08)))
        ant.append(kit.box((0.20, 0.20, 0.12), root))
    p.append(kit.part("antenna booms", (0.72, 0.62, 0.42), *ant))

    return dict(meta=dict(name="EURECA (European Retrievable Carrier)" +
                          (" (arrays deployed, STS-46)" if dep else " (arrays folded, as STS-57 retrieved it)"),
                          frame="EURECA: +X along the solar wings' axis (along the payload bay when "
                                "berthed; the face with the EURECA plate), +Y across the bay (the "
                                "grapple fixture's end: it stands on the top deck's +Y step), +Z the "
                                "top deck (the experiments; the Sun side, the cells' face when "
                                "deployed); m; the box's centre (the mass is spread through the frame)",
                          source="simple shapes to published dimensions (eoPortal; ESA's post-flight "
                                 "survey) and the STS-46/STS-57 photographs (sts046-76-028, "
                                 "sts057-84-000AD, s46-08-010, sts057-93-052, s92-41442)",
                          norad=22065, mag_1000km=1.0 if dep else 2.0),
                parts=U.refine_parts(p))
