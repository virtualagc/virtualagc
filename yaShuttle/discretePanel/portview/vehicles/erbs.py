"""The Earth Radiation Budget Satellite (NORAD 15354), as STS-41G released
it on 5 October 1984 -- after Sally Ride, at the arm's controls, shook its
stuck solar panel free -- both panels out.  Ball Aerospace built it (2,449
kg); it boosted itself to 610 km.

A T, in gold blanket (Ball's own drawing as NASA Langley shows it, and the
41-G photographs: STS-41-G deployment, the RMS views; KSC s84-41265/-41266):

  - the base module, 4.2 m long, 1.5 m wide, 0.75 m deep, carrying the
    instruments on its Earth (-Z) face -- SAGE II's silver telescope on its
    azimuth gimbal, the ERBE scanner and non-scanner, an omni antenna on a
    post -- and white louvred radiators along its sides; the trunnion
    fittings on its ends; the grapple fixture on its Earth face near +X;
  - the keel module standing ~2 m up out of its middle, stepped in at the
    top, a louvred radiator on each side;
  - on top of the keel module the two solar panels, 3.8 x 2.85 m with the
    corners at their hinge edge cut off (s84-41265, where one hangs stowed
    from the keel module's top down past the base module; sized from the
    RMS view, which looks nearly square-on at the Earth face), swung up and
    out to either side with a little dihedral, cells to the zenith (blue in
    a gold border), backs white with black holes (the RMS view);
  - the TDRS antenna, an electrically steerable spherical array -- a white
    ball tiled with round elements (s84-41266) -- on a mast off the top.

Textures procedural (_cgro_util.py's, shared with cgro.py, and the panel
faces below).
"""
import math

import numpy as np

from . import _cgro_util as U

KEY = 'erbs'

GOLD = (0.95, 0.54, 0.17)           # linear ratio as the flight photographs' (1 : 0.5-0.6 : 0.2)
WHITE = (0.82, 0.82, 0.80)
SILVER = (0.66, 0.68, 0.70)
DARK = (0.05, 0.05, 0.06)

# the base module (origin: the estimated centre of mass, ~0.75 m above its
# centre, the keel module being nearly as heavy)
BX, BY, BZ = 2.10, 0.75, 0.375
ZB = -0.75                          # the base module's centre
Z_TOP_BASE = ZB + BZ                # its top (-0.375), the keel module's foot
Z_BOT = ZB - BZ                     # its Earth face (-1.125)
XK = -0.25                          # the keel module's centre in x
KEEL_LO = (1.90, 1.30)              # its lower tier (x, y)
KEEL_HI = (1.65, 1.20)              # its upper tier
Z_STEP, Z_KEEL = 0.85, 1.68         # the step; the keel module's top
PANEL_W, PANEL_D, CHAMFER = 3.8, 2.85, 0.75
DIHEDRAL = 10.0                     # deg, the panels' outer edges up
Y_HINGE = 0.80                      # the hinge lines: stowed, the panels hung clear of the base module


def _box(c0, c1):
    from .kit import box
    c0, c1 = np.asarray(c0, float), np.asarray(c1, float)
    return box(c1 - c0, (c0 + c1) / 2)


# ------------------------------------------------------------------ textures
def _panel_outline_mask(xx, yy, margin):
    """In a panel's texture (u along x 0..1 = 3.6 m, v outward 0..1 = 2.5 m,
    the hinge edge at v = 0): inside the chamfered outline, margin m in."""
    s, t = xx * PANEL_W, yy * PANEL_D
    c = CHAMFER
    inside = (s > margin) & (s < PANEL_W - margin) & (t > margin) & (t < PANEL_D - margin)
    inside &= (s + t > c + margin * 1.41) & ((PANEL_W - s) + t > c + margin * 1.41)
    return inside


def tex_panel_cells(seed=41, w=720, h=500):
    """The cell side, in absolute colour (the part's albedo is white): blue
    cells, each a little different, in strings running across the panel,
    thin gold lines between the strings and a gold border, stepped where
    the cells meet the chamfers (s84-41265)."""
    key = ('erbs-cells', seed, w, h)
    if key in U._TEX:
        return U._TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:h, 0:w] + 0.5)
    yy, xx = yy / h, xx / w                          # v (outward) = image row: portview puts row 0 at v = 0
    nx, ny = 96, 64                                  # cells (~4 x 4 cm)
    cx, cy = (xx * nx).astype(int), (yy * ny).astype(int)
    jit = g.uniform(0.70, 1.15, (ny + 1, nx + 1))
    v = jit[cy, cx]
    blue = np.stack([0.10 * v, 0.14 * v, 0.27 * v], -1)
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    gaps = (fx < 0.08) | (fy < 0.08)
    gold = np.array([0.80, 0.60, 0.25])
    rgb = np.where(gaps[..., None], blue * 0.6 + 0.08, blue)
    strings = (np.abs(((xx * 8) % 1) - 0.0) < 0.004) | (np.abs(((xx * 8) % 1) - 1.0) < 0.004)
    rgb[strings] = gold * 0.8
    # cells only on whole cells inside the outline (stepped at the chamfers)
    ccx, ccy = (cx + 0.5) / nx, (cy + 0.5) / ny
    cellin = _panel_outline_mask(ccx, ccy, 0.06)
    rgb[~cellin] = gold
    rgb[~_panel_outline_mask(xx, yy, 0.0)] = gold * 0.7
    U._TEX[key] = U._img(rgb)
    return U._TEX[key]


def tex_panel_back(seed=42, w=720, h=500):
    """The back, absolute colour: white, the honeycomb panels' outlines as
    grey lines, harness runs, two black holes near the outer corners and the
    hinge-side brackets (the RMS view)."""
    key = ('erbs-back', seed, w, h)
    if key in U._TEX:
        return U._TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:h, 0:w] + 0.5)
    yy, xx = yy / h, xx / w
    v = 0.86 + 0.03 * U._noise(g, max(w, h), 12)[:h, :w]
    s, t = xx * PANEL_W, yy * PANEL_D
    lines = np.zeros_like(v, bool)
    for x in (0.9, 1.8, 2.7):
        lines |= (np.abs(s - x) < 0.008) & (t > 0.35)
    for y in (0.65, 1.25, 1.85):
        lines |= (np.abs(t - y) < 0.008)
    v[lines] *= 0.72
    # harness: a wandering line from the hinge edge out across each half
    for s0 in (1.1, 2.5):
        tt = np.linspace(0.1, 2.3, 400)
        ss = s0 + 0.25 * np.sin(tt * 3.1 + g.uniform(0, 6)) + 0.1 * np.sin(tt * 7.3)
        for a, b in zip(ss, tt):
            px, py = int(a / PANEL_W * w), int(b / PANEL_D * h)
            v[max(0, py - 1):py + 1, max(0, px - 1):px + 1] *= 0.6
    for hs, ht in ((0.45, 2.15), (PANEL_W - 0.45, 2.15)):
        v[(s - hs) ** 2 + (t - ht) ** 2 < 0.07 ** 2] = 0.03
    for hs in (0.9, 2.7):                              # brackets
        v[(np.abs(s - hs) < 0.05) & (np.abs(t - 0.9) < 0.04)] *= 0.45
    rgb = np.stack([v, v, v * 0.98], -1)
    rgb[~_panel_outline_mask(xx, yy, 0.0)] = 0.6
    U._TEX[key] = U._img(rgb)
    return U._TEX[key]


def tex_essa(size=128):
    """The spherical array: one round element per repeat, a raised white
    disc with a darker rim and centre pin, on white."""
    key = ('erbs-essa', size)
    if key in U._TEX:
        return U._TEX[key]
    yy, xx = (np.mgrid[0:size, 0:size] + 0.5) / size - 0.5
    r = np.hypot(xx, yy)
    v = np.full((size, size), 0.80)
    v[r < 0.36] = 0.95
    v[(r > 0.34) & (r < 0.38)] = 0.55
    v[r < 0.04] = 0.45
    U._TEX[key] = U._img(v)
    return U._TEX[key]


# -------------------------------------------------------------------- panels
def _panel_frame(side):
    """(origin, s axis (along x), t axis (outward), n (the cell side)) of
    the panel on side +-1: its hinge edge along x at the keel module's top
    edge, tilted up DIHEDRAL deg."""
    a = math.radians(DIHEDRAL)
    origin = np.array([XK - PANEL_W / 2, side * Y_HINGE, Z_KEEL + 0.06])
    s = np.array([1.0, 0.0, 0.0])
    t = np.array([0.0, side * math.cos(a), math.sin(a)])
    n = np.array([0.0, -side * math.sin(a), math.cos(a)])
    return origin, s, t, n


def _panel_meshes(kit):
    """(cells mesh+uv, backs mesh+uv, edges mesh): each panel a chamfered
    slab 30 mm thick, its faces separate parts so the cells and back can
    carry their own textures."""
    c = CHAMFER
    outline = [(0.0, 0.0), (PANEL_W, 0.0), (PANEL_W, PANEL_D - c), (PANEL_W - c, PANEL_D),
               (c, PANEL_D), (0.0, PANEL_D - c)]
    # the chamfers are at the hinge edge: flip t so the cut corners sit at t = 0
    outline = [(s, PANEL_D - t) for s, t in outline]
    th = 0.03
    cells, backs, edges = [], [], []
    for side in (-1, 1):
        o, S, T, N = _panel_frame(side)

        def P(s, t, h):
            return o + s * S + t * T + h * N
        poly = np.asarray(outline)
        n = len(poly)
        # faces: a fan from the centroid, refined; uv = (s / W, t / D)
        cen = poly.mean(0)
        for h, store in ((th / 2 + 0.002, cells), (-th / 2, backs)):
            pts2 = np.vstack([cen[None], poly])
            tris = [(0, 1 + i, 1 + (i + 1) % n) for i in range(n)]
            m2 = U.refine((np.column_stack([pts2, np.zeros(len(pts2))]), np.asarray(tris)), 0.45)
            st = m2[0][:, :2]
            pts3 = np.array([P(a, b, h) for a, b in st])
            m, uv = U.planar_uv((pts3, m2[1]), 1.0, axes=((1, 0, 0), (0, 1, 0)))
            stu = U.unshare((np.column_stack([st, np.zeros(len(st))]), m2[1]))[0][:, :2]
            uv = np.column_stack([stu[:, 0] / PANEL_W, stu[:, 1] / PANEL_D]).astype(np.float32)
            store.append((m, uv))
        # the rim
        rim = []
        for i in range(n):
            j = (i + 1) % n
            a0, a1 = poly[i], poly[j]
            q = [P(*a0, -th / 2), P(*a1, -th / 2), P(*a1, th / 2), P(*a0, th / 2)]
            rim.append((np.asarray(q), np.array([(0, 1, 2), (0, 2, 3)])))
        edges.append(kit.merge(*rim))
    return cells, backs, edges


def _merge_uv(items):
    pts, tris, uvs, base = [], [], [], 0
    for (p, t), uv in items:
        pts.append(p)
        tris.append(np.asarray(t) + base)
        uvs.append(uv)
        base += len(p)
    return (np.vstack(pts), np.vstack(tris)), np.vstack(uvs)


# --------------------------------------------------------------------- build
def build(kit):
    p = []
    gold_tex = U.tex_blanket(151, depth=0.42, crinkle=3.0, seams=1, seam_dark=0.8, glints=0.9)
    # the base and keel modules, gold blanket
    base = _box((-BX, -BY, Z_BOT), (BX, BY, Z_TOP_BASE))
    lo = _box((XK - KEEL_LO[0] / 2, -KEEL_LO[1] / 2, Z_TOP_BASE - 0.05), (XK + KEEL_LO[0] / 2, KEEL_LO[1] / 2, Z_STEP))
    hi = _box((XK - KEEL_HI[0] / 2, -KEEL_HI[1] / 2, Z_STEP - 0.05), (XK + KEEL_HI[0] / 2, KEEL_HI[1] / 2, Z_KEEL))
    p.append(U.tpart(kit, "base and keel modules (gold blanket)", GOLD, U.refine_each([base, lo, hi], 0.45),
                     gold_tex, tile=1.3))
    # the base module's radiators: white louvres in two banks each side
    louv = []
    for sy in (-1, 1):
        y0, y1 = sorted((sy * (BY + 0.004), sy * (BY + 0.02)))
        for xc in (1.70, 1.32, 0.94, 0.56, -0.62, -1.00, -1.38):
            louv.append(_box((xc - 0.17, y0, Z_BOT + 0.09), (xc + 0.17, y1, Z_TOP_BASE - 0.09)))
        # the keel module's radiator, high on each side
        y0, y1 = sorted((sy * (KEEL_HI[1] / 2 + 0.004), sy * (KEEL_HI[1] / 2 + 0.02)))
        louv.append(_box((XK - 0.65, y0, 1.00), (XK + 0.10, y1, 1.55)))
    p.append(U.tpart(kit, "radiators (white louvres)", WHITE, kit.merge(*louv), U.tex_louvres(9, slat=0.95),
                     axes=((1, 0, 0), (0, 0, 1)), tile=(0.34, 0.57)))
    # the solar panels
    cells, backs, edges = _panel_meshes(kit)
    m, uv = _merge_uv(cells)
    p.append(kit.part("solar cells (on gold substrate)", (1.0, 1.0, 1.0), m, texture=tex_panel_cells(), uv=uv))
    m, uv = _merge_uv(backs)
    p.append(kit.part("solar panel backs (white)", (1.0, 1.0, 1.0), m, texture=tex_panel_back(), uv=uv))
    p.append(kit.part("solar panel edges", (0.70, 0.55, 0.28), *edges))
    struts = []
    for side in (-1, 1):
        o, S, T, N = _panel_frame(side)
        for s in (0.95, PANEL_W - 0.95):
            a = np.array([XK - PANEL_W / 2 + s, side * KEEL_HI[1] / 2, Z_KEEL - 0.05])
            b = o + s * S + 0.85 * T - 0.03 * N
            struts += [kit.rod(a, b, 0.025, n=6), _box(a - (0.06, 0.04, 0.05), a + (0.06, 0.04, 0.07))]
        struts.append(kit.rod(o + 0.6 * S - 0.03 * N, o + (PANEL_W - 0.6) * S - 0.03 * N, 0.02, n=6))   # hinge line
    p.append(kit.part("panel hinges and struts", (0.85, 0.85, 0.84), *struts))
    # the spherical array (TDRS antenna) on its mast
    m0 = np.array([XK + 0.45, 0.0, Z_KEEL])
    d = np.array([0.5, 0.0, 0.866])
    top = m0 + 1.05 * d
    r = 0.42
    centre = top + 0.75 * r * d
    p.append(U.tpart(kit, "antenna mast (gold blanket)", GOLD, kit.rod(m0, top, 0.07, n=12), gold_tex, tile=0.5))
    ball = U.sphere_z(r, n=14, z_lo=-0.75 * r)
    R = U.frame_from(d)[:, [1, 2, 0]]                       # +Z -> d
    ball = (ball[0] @ R.T + centre, ball[1])
    m, uv = U.polar_uv(ball, centre, d, n_round=16, n_lat=4.0)
    part = kit.part("spherical array antenna (white)", WHITE, m, texture=tex_essa(), uv=uv)
    part['nrm'] = U.sphere_normals(m, centre)
    p.append(part)
    # the ball is cut flat 0.75 r below its centre, at the mast's top: close it
    p.append(kit.part("antenna array base", (0.75, 0.75, 0.74),
                      kit.along(kit.disc(r * math.sqrt(1 - 0.75 ** 2), 0.0, n=28), -d, top)))
    # the Earth face: instruments
    zb = Z_BOT
    inst_w, inst_g, inst_s = [], [], []
    # SAGE II: azimuth gimbal and its silver telescope
    inst_s.append(kit.along(kit.cylinder(0.24, 0.0, 0.16, n=24), (0, 0, -1), (1.15, -0.35, zb)))
    inst_s.append(_box((0.95, -0.55, zb - 0.45), (1.35, -0.15, zb - 0.16)))
    inst_s.append(kit.along(kit.cylinder(0.13, 0.0, 0.42, n=20), (0, 0, -1), (1.15, -0.35, zb - 0.45)))
    # the ERBE scanner (white, its scan head a drum across Y) and non-scanner (gold)
    inst_w.append(_box((0.45, -0.05, zb - 0.42), (0.90, 0.55, zb + 0.01)))
    inst_w.append(kit.along(kit.cylinder(0.17, -0.25, 0.25, n=20), (0, 1, 0), (0.68, 0.25, zb - 0.55)))
    inst_g.append(_box((-0.05, -0.55, zb - 0.62), (0.40, 0.05, zb + 0.01)))
    inst_g.append(_box((-1.70, -0.20, zb - 0.70), (-1.30, 0.35, zb + 0.01)))
    p.append(U.tpart(kit, "ERBE scanner (white blanket)", WHITE, kit.merge(*inst_w),
                     U.tex_blanket(152, depth=0.25, crinkle=1.5, seams=0), tile=0.6))
    p.append(U.tpart(kit, "instrument boxes (gold blanket)", GOLD, kit.merge(*inst_g), gold_tex, tile=0.7))
    p.append(kit.part("SAGE II (aluminium)", SILVER, *inst_s))
    apertures = [kit.along(kit.disc(0.05, 0.0, n=12), (0, 0, -1), (x, y, zb - 0.625))
                 for x, y in ((0.05, -0.40), (0.30, -0.40), (0.05, -0.10), (0.30, -0.10))]
    apertures.append(kit.along(kit.disc(0.11, 0.0, n=20), (0, 0, -1), (1.15, -0.35, zb - 0.875)))
    p.append(kit.part("apertures", DARK, *apertures))
    # the omni antenna on its post; round white covers in pairs (the RMS
    # view's white discs); the decal
    omni = [kit.along(kit.cylinder(0.04, 0.0, 0.62, n=10), (0, 0, -1), (-0.60, 0.25, zb)),
            kit.along(kit.frustum(0.05, 0.18, 0.0, 0.06, n=20), (0, 0, -1), (-0.60, 0.25, zb - 0.62))]
    p.append(U.tpart(kit, "omni antenna post (gold blanket)", GOLD, omni[0], gold_tex, tile=0.4))
    p.append(kit.part("omni antenna (white)", (0.85, 0.85, 0.84), omni[1]))
    covers = [kit.along(kit.disc(0.065, 0.0, n=16), (0, 0, -1), (x, y, zb - 0.006))
              for x in (-0.15, -0.95, -1.95) for y in (-0.55, 0.55)]
    covers.append(_box((1.55, -0.60, zb - 0.008), (1.85, -0.30, zb - 0.004)))
    p.append(kit.part("white covers and decal", (0.88, 0.88, 0.86), *covers))
    # trunnion fittings on the ends: a disc and pin on +X, two discs on -X
    fit, pins = [], []
    fit.append(kit.along(kit.cylinder(0.30, 0.0, 0.08, n=28), (1, 0, 0), (BX, 0.0, ZB)))
    pins.append(kit.rod((BX + 0.08, 0.0, ZB), (BX + 0.30, 0.0, ZB), 0.041, n=12))
    for y in (-0.38, 0.38):
        fit.append(kit.along(kit.cylinder(0.26, 0.0, 0.08, n=28), (-1, 0, 0), (-BX, y, ZB)))
    pins.append(kit.rod((-BX - 0.08, 0.38, ZB), (-BX - 0.30, 0.38, ZB), 0.041, n=12))
    pins.append(kit.rod((XK, 0.0, zb), (XK, 0.0, zb - 0.30), 0.041, n=12))           # keel pin
    p.append(U.tpart(kit, "trunnion fittings (gold)", (0.90, 0.60, 0.22), kit.merge(*fit),
                     U.tex_grid_panel(nx=4, ny=4), tile=0.6))
    p.append(kit.part("trunnion pins", (0.60, 0.60, 0.62), *pins))
    slots = []
    for y in (-0.38, 0.38):
        for k in range(5):
            a = 2 * math.pi * k / 5
            slots.append(_box((-BX - 0.085, y + 0.17 * math.cos(a) - 0.02, ZB + 0.17 * math.sin(a) - 0.04),
                              (-BX - 0.081, y + 0.17 * math.cos(a) + 0.02, ZB + 0.17 * math.sin(a) + 0.04)))
    p.append(kit.part("fitting slots", DARK, *slots))
    for name, rgb, m in U.frgf(kit, (1.50, 0.35, zb), (0, 0, -1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="Earth Radiation Budget Satellite (STS-41G)",
                          frame="ERBS: +X along the base module (the grapple fixture's end), +Z up the keel "
                                "module to the solar panels and the TDRS array (zenith), -Z the instruments' "
                                "(Earth) face, +Y across; m; the estimated centre of mass, ~0.75 m above the "
                                "base module's centre",
                          source="shapes after Ball's configuration as NASA Langley shows it and the STS-41G "
                                 "and KSC photographs (s84-41265, -41266)",
                          norad=15354, mag_1000km=2.5),
                parts=U.refine_parts(p))
