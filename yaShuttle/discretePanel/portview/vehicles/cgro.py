"""The Compton Gamma Ray Observatory (NORAD 21225), as STS-37 released it
on 7 April 1991 -- after Ross and Apt had freed its stuck high-gain antenna
boom by EVA: built from shapes.

The arrangement follows the GRO Prelaunch Mission Operations Report's
configuration drawings (NASA, 1991: figures 1 and 2, top and bottom views)
and the STS-37 photographs (S37-96-009, -010, S37-99-031, -056, -098,
S37-18-032; KSC-91PC-137 and S90-36709 on the ground); the overall
proportions NASA 3D Resources' "Gamma Ray Observatory" (which this replaces:
too coarse, and white all over), corrected where the photographs disagree.

  - The platform: a box 6.1 m long, 2.8 m wide and 2.7 m deep, full-width
    (4.1 m) end frames, equipment bays low along the sides; white beta
    cloth and blanket, the underside gold blanket (KSC-91PC-137) with the
    four propellant tanks bulging out of it (S90-36709; MOR figure 2) and
    the orbit-adjust thrusters.
  - On top, along the body: OSSE's rounded housing at the -X end (its
    four detectors swing on an axis along Y), COMPTEL's and EGRET's
    domes -- blue-silvered blankets in taped gores -- on white collars;
    the grapple fixture between them on the +Y side.
  - BATSE's eight detector modules at the eight corners, each facing out
    along a corner diagonal (the faces of an octahedron); those at the
    OSSE end's top in white bags (S37-96-010, S37-99-056).
  - The +X end: the two power modules' radiators (louvres over optical
    solar reflectors) either side of a white panel (S37-99-031).
  - Two four-panel solar wings on booms out of the sides, an A-frame at
    each root, white backs toward +Z as released (S37-96-010; the cells
    face -Z), 21.3 m tip to tip.
  - The 1.5 m high-gain dish on its ~4.7 m boom, down and out from the
    -X end's underside, the three magnetic torquers across it.
"""
import math

import numpy as np

from . import _cgro_util as U

KEY = 'cgro'

WHITE = (0.80, 0.80, 0.80)          # beta cloth / white and silvered blanket
BRIGHT = (0.86, 0.86, 0.84)         # bagged BATSE modules, the OSSE end's bags
SILVER = (0.62, 0.64, 0.68)         # aluminised blanket
GOLD = (0.95, 0.52, 0.17)           # gold (Kapton) blanket: the photographs' linear 1 : 0.5 : 0.2
MIRROR = (0.46, 0.52, 0.66)         # BATSE faces: silvered film, sky-blue in the photographs
DOME = (0.36, 0.46, 0.72)           # the domes' silvered film (dark: it mirrors black sky)
CELLS = (0.05, 0.06, 0.13)
ARRAY_BACK = (0.80, 0.80, 0.78)
DARK = (0.06, 0.06, 0.07)
ALUMINIUM = (0.55, 0.55, 0.56)

# the platform (origin its centre; the observatory's mass is mostly in and
# on it): x -3.05..3.05, y +-1.40, z +-1.35, the deck z = 1.35
XC, YC, ZC = 3.05, 1.40, 1.35
X_END = 2.35                        # the end frames, |x| 2.35..3.10
Y_END = 2.05
X_COMPTEL, X_EGRET = 0.10, 2.06
X_ARRAY, Z_ARRAY = 1.30, -0.60      # the solar wings' axis
Y_TIP = 10.65


def _box(c0, c1):
    c0, c1 = np.asarray(c0, float), np.asarray(c1, float)
    from .kit import box
    return box(c1 - c0, (c0 + c1) / 2)


def split_by_normal(mesh, axis, thresh=0.9):
    """(the triangles facing +-axis, the rest)."""
    p, t = np.asarray(mesh[0], float), np.asarray(mesh[1])
    n = np.cross(p[t[:, 1]] - p[t[:, 0]], p[t[:, 2]] - p[t[:, 0]])
    n /= np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)
    s = np.abs(n @ np.asarray(axis, float)) > thresh
    return (p, t[s]), (p, t[~s])


def tex_array_back(seed=21, size=256):
    """A wing panel's back: white Kapton over the honeycomb, the harness
    runs (dark wandering lines) and their tie-downs (dots) -- as the backs
    show in S37-96-010."""
    key = ('cgro-array-back', seed, size)
    if key in U._TEX:
        return U._TEX[key]
    g = np.random.default_rng(seed)
    v = 0.93 + 0.04 * U._noise(g, size, 10) * 0.5
    yy, xx = np.mgrid[0:size, 0:size]
    frame = (xx < 3) | (xx > size - 4) | (yy < 3) | (yy > size - 4)
    v[frame] *= 0.45
    for _ in range(3):
        y = g.uniform(0.15, 0.85) * size
        pts = [(0.0, y)]
        x = 0.0
        while x < size:
            x += g.uniform(20, 60)
            y = np.clip(y + g.uniform(-25, 25), 10, size - 10)
            pts.append((x, y))
        for (x0, y0), (x1, y1) in zip(pts[:-1], pts[1:]):
            for s in np.linspace(0, 1, int(abs(x1 - x0) + abs(y1 - y0)) + 1):
                px, py = int(x0 + s * (x1 - x0)), int(y0 + s * (y1 - y0))
                if 0 <= px < size and 0 <= py < size:
                    v[max(0, py - 1):py + 1, px] *= 0.55
            px, py = int(x1) % size, int(y1)
            v[(yy - py) ** 2 + (xx - px) ** 2 < 5] *= 0.4
    U._TEX[key] = U._img(v)
    return U._TEX[key]


def _platform(kit):
    p = []
    blanket = U.tex_blanket(301, depth=0.30, crinkle=2.0, seams=2, glints=0.25)
    white = []
    white.append(_box((-XC, -YC, -ZC), (XC, YC, ZC)))                          # core
    for sx in (-1, 1):                                                         # end frames
        x0, x1 = sorted((sx * X_END, sx * (XC + 0.05)))
        white.append(_box((x0, -Y_END, -ZC + 0.05), (x1, Y_END, 0.95)))
    for sy in (-1, 1):                                                         # side bays
        y0, y1 = sorted((sy * (YC - 0.02), sy * 1.95))
        white.append(_box((-X_END + 0.05, y0, -ZC + 0.10), (X_END - 0.05, y1, 0.02)))
    # BATSE pedestals at the corners, over and under the end frames
    for sx in (-1, 1):
        for sy in (-1, 1):
            x0, x1 = sorted((sx * 2.45, sx * 3.25))
            y0, y1 = sorted((sy * 1.25, sy * 2.00))
            white.append(_box((x0, y0, 0.90), (x1, y1, 1.42)))
            white.append(_box((x0, y0, -1.62), (x1, y1, -ZC + 0.10)))
    p.append(U.tpart(kit, "platform (white blanket)", WHITE, U.refine_each(white, 0.5), blanket, tile=1.4))
    # the underside: gold blanket between the end frames, the propellant
    # tanks bulging out of it
    gold = [_box((-X_END + 0.02, -1.70, -ZC - 0.06), (X_END - 0.02, 1.70, -ZC + 0.05))]
    tm, tuv, tn = [], [], []
    for x in (-1.25, 0.95):
        for y in (-0.80, 0.80):
            c = (x, y, -ZC - 0.02)
            m, uv = U.polar_uv(U.sphere_z(0.52, n=10, centre=c, z_hi=0.30, z_lo=-0.52), c, (0, 0, -1),
                               n_round=3, n_lat=1.0)
            tm.append(m), tuv.append(uv), tn.append(U.sphere_normals(m, c))
    gt = U.tex_blanket(302, depth=0.40, crinkle=3.0, seams=1, seam_dark=0.8, glints=0.6)
    p.append(U.tpart(kit, "underside (gold blanket)", GOLD, U.refine_each(gold, 0.5), gt, tile=1.1))
    tanks = kit.part("propellant tanks (gold blanket)", GOLD, kit.merge(*tm), texture=gt, uv=np.vstack(tuv))
    tanks['nrm'] = np.vstack(tn)
    p.append(tanks)
    # orbit-adjust thruster module, and the four dual-thruster modules
    oatm = [_box((-0.45, -0.35, -ZC - 0.22), (0.25, 0.35, -ZC - 0.05))]
    nozzles = []
    for dx in (-0.25, 0.05):
        for dy in (-0.17, 0.17):
            nozzles.append(kit.along(kit.frustum(0.05, 0.10, 0.0, 0.22, n=12, caps=False), (0, 0, -1),
                                     (dx, dy, -ZC - 0.22)))
    for sx in (-1, 1):
        for sy in (-1, 1):
            c = np.array([sx * 2.70, sy * 1.10, -ZC - 0.05])
            oatm.append(_box(c - (0.15, 0.12, 0.12), c + (0.15, 0.12, 0.0)))
            for d in (-0.07, 0.07):
                nozzles.append(kit.along(kit.frustum(0.02, 0.04, 0.0, 0.08, n=8, caps=False),
                                         (sx * 0.35, 0, -1), c + (d, 0, -0.12)))
    p.append(kit.part("thruster modules", ALUMINIUM, *oatm))
    p.append(kit.part("thruster nozzles", DARK, *nozzles))
    return p


def _instruments(kit):
    p = []
    blanket = U.tex_blanket(311, depth=0.25, crinkle=1.3, seams=2)
    # OSSE: a housing on the -X end of the deck, rounded over the top
    # toward COMPTEL; white sides, the top aluminised
    prof = U.rounded_rect(-XC + 0.05, -0.95, ZC - 0.05, 2.65, r0=0.35, r1=0.85, k=6)
    hump = U.refine(U.extrude(prof, -1.27, 1.27, axis='y'), 0.45)
    sides, top = split_by_normal(hump, (0, 1, 0))
    p.append(U.tpart(kit, "OSSE housing (white blanket)", WHITE, sides, blanket, tile=1.2))
    p.append(U.tpart(kit, "OSSE housing top (aluminised blanket)", SILVER, top,
                     U.tex_blanket(312, depth=0.35, crinkle=2.0, seams=2, glints=0.3), tile=1.0))
    # the box on the -X end (OSSE's electronics; the fine Sun sensor on it)
    p.append(U.tpart(kit, "-X end box (white blanket)", WHITE, _box((-XC - 0.45, -0.24, 0.0), (-XC + 0.02, 0.24, 1.62)),
                     blanket, tile=1.0, fine=0.5))
    # COMPTEL and EGRET: white collars, blanketed domes
    domes = [((x, 0.0, top - 0.02), 0.74) for x, top in ((X_COMPTEL, 2.10), (X_EGRET, 1.87))]
    cm, cuv, cn = [], [], []
    for (x, top), r in (((X_COMPTEL, 2.10), 0.78), ((X_EGRET, 1.87), 0.78)):
        tube = U.tube_z(r, ZC - 0.05, top, n=48, centre=(x, 0.0), max_len=0.3)
        m, uv = U.axial_uv(tube, (x, 0, 0), (0, 0, 1), tile_len=0.8, n_round=4)
        cm.append(m), cuv.append(uv), cn.append(U.radial_normals(m, (x, 0, 0), (0, 0, 1)))
        cap = kit.along(kit.disc(r, 0.0, n=48, r_in=0.70), (0, 0, 1), (x, 0, top))
        m, uv = U.planar_uv(cap, 1.0)
        cm.append(m), cuv.append(uv), cn.append(np.tile([0.0, 0.0, 1.0], (len(m[0]), 1)))
    pts, tris, base = [], [], 0
    for m in cm:
        pts.append(m[0])
        tris.append(np.asarray(m[1]) + base)
        base += len(m[0])
    part = kit.part("instrument collars (white blanket)", WHITE, (np.vstack(pts), np.vstack(tris)),
                    texture=U.tex_blanket(313, depth=0.30, crinkle=1.5, seams=1), uv=np.vstack(cuv))
    part['nrm'] = np.vstack(cn)
    p.append(part)
    gores = U.tex_gores(line=4.0, base=0.25, mottle=0.45)
    dm, duv, dn = [], [], []
    for c, r in domes:
        s = U.sphere_z(r, n=10, centre=c, z_lo=0.0)
        m, uv = U.polar_uv(s, c, (0, 0, 1), n_round=16, n_lat=2.0)
        dm.append(m), duv.append(uv), dn.append(U.sphere_normals(m, c))
    pts, tris, base = [], [], 0
    for m in dm:
        pts.append(m[0])
        tris.append(np.asarray(m[1]) + base)
        base += len(m[0])
    part = kit.part("COMPTEL and EGRET domes (silvered blanket)", DOME, (np.vstack(pts), np.vstack(tris)),
                    texture=gores, uv=np.vstack(duv))
    part['nrm'] = np.vstack(dn)
    p.append(part)
    # BATSE: a module at each corner facing out along the diagonal
    housings, faces, bags, spec = [], [], [], []
    for sx in (-1, 1):
        for sy in (-1, 1):
            for sz in (-1, 1):
                n = np.array([sx, sy, sz]) / math.sqrt(3)
                c = np.array([sx * 3.22, sy * 1.92, 1.62 if sz > 0 else -1.78])
                R = U.frame_from(n, (sx, 0, 0))
                body = U.place(kit, kit.box((0.34, 0.62, 0.62), (0, 0, 0)), R, c)
                face = U.place(kit, kit.box((0.02, 0.58, 0.58), (0.18, 0, 0)), R, c)
                det = U.place(kit, kit.cylinder(0.085, -0.05, 0.22, n=12), R, c + R @ (0.0, 0.0, -0.45))
                spec.append(det)
                if sx < 0 and sz > 0:
                    bags.append(U.refine(kit.merge(body, face), 0.3))
                else:
                    housings.append(body)
                    faces.append(face)
    p.append(U.tpart(kit, "BATSE modules (white bags)", BRIGHT, kit.merge(*bags),
                     U.tex_blanket(314, depth=0.40, crinkle=2.0, seams=0), tile=0.6))
    p.append(U.tpart(kit, "BATSE housings (white blanket)", WHITE, kit.merge(*housings), blanket, tile=0.8))
    p.append(U.tpart(kit, "BATSE detector faces (silvered film)", MIRROR, kit.merge(*faces),
                     U.tex_blanket(315, depth=0.45, crinkle=2.5, seams=0, glints=0.5), tile=0.6))
    p.append(kit.part("BATSE spectroscopy detectors", (0.70, 0.70, 0.70), *spec))
    return p


def _ends_and_sides(kit):
    p = []
    # +X end: the two power modules' radiators either side of a white panel
    xf = XC + 0.05
    boxes = [_box((xf - 0.05, sy * 0.82 if sy > 0 else -1.90, 0.0), (xf + 0.26, 1.90 if sy > 0 else -0.82, 0.93))
             for sy in (-1, 1)]
    boxes.append(_box((xf - 0.05, -0.90, -1.28), (xf + 0.30, 0.90, -0.82)))       # attitude control module
    p.append(U.tpart(kit, "+X end modules (white blanket)", WHITE, kit.merge(*boxes),
                     U.tex_blanket(321, depth=0.22, seams=1), tile=1.0))
    louv, osr = [], []
    for sy in (-1, 1):
        y0, y1 = (0.86, 1.86) if sy > 0 else (-1.86, -0.86)
        louv.append(_box((xf + 0.26, y0, 0.45), (xf + 0.275, y1, 0.90)))
        osr.append(_box((xf + 0.26, y0, 0.03), (xf + 0.275, y1, 0.42)))
    p.append(U.tpart(kit, "power module louvres", (0.72, 0.72, 0.74), kit.merge(*louv), U.tex_louvres(10),
                     axes=((0, 1, 0), (0, 0, 1)), tile=(1.0, 0.45)))
    p.append(U.tpart(kit, "power module reflectors", (0.55, 0.62, 0.78), kit.merge(*osr), U.tex_osr(10, 4),
                     axes=((0, 1, 0), (0, 0, 1)), tile=(1.0, 0.39)))
    p.append(U.tpart(kit, "+X end panel (white paint)", (0.84, 0.84, 0.82), _box((xf - 0.05, -0.78, -0.78), (xf + 0.02, 0.78, 0.93)),
                     U.tex_grid_panel(nx=8, ny=8), axes=((0, 1, 0), (0, 0, 1)), tile=(1.56, 1.73)))
    ports = [kit.along(kit.disc(0.11, 0.0, n=20), (1, 0, 0), (xf + 0.305, sy * 0.45, -1.05)) for sy in (-1, 1)]
    p.append(kit.part("+X end sensor ports", DARK, *ports))
    # the sides: the C&DH and attitude-control radiators, louvred, on the
    # platform's upper sides between the domes (MOR figure 1)
    rad = []
    for sy in (-1, 1):
        y = sy * (YC + 0.01)
        for x0, x1 in ((-0.25, 0.85), (1.00, 2.20)):
            rad.append(_box((x0, min(y, y + sy * 0.015), 0.12), (x1, max(y, y + sy * 0.015), 1.22)))
    p.append(U.tpart(kit, "side radiators (louvres)", (0.70, 0.70, 0.72), kit.merge(*rad), U.tex_louvres(12, vertical=False),
                     axes=((1, 0, 0), (0, 0, 1)), tile=(1.1, 1.1)))
    # trunnions and the keel pin; the grapple fixture; low-gain antennas
    pins = []
    for sx in (-1, 1):
        for sy in (-1, 1):
            pins.append(kit.rod((sx * 2.72, sy * Y_END, -0.20), (sx * 2.72, sy * (Y_END + 0.28), -0.20), 0.041, n=12))
    pins.append(kit.rod((0.0, 0.0, -ZC - 0.06), (0.0, 0.0, -ZC - 0.36), 0.041, n=12))
    p.append(kit.part("trunnions", ALUMINIUM, *pins))
    for name, rgb, m in U.frgf(kit, (1.08, 1.02, ZC), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    lga = []
    for sx in (-1, 1):
        a = np.array([sx * 3.0, -sx * 1.25, -1.20])
        d = np.array([sx * 0.5, -sx * 0.3, -0.8])
        d /= np.linalg.norm(d)
        lga += [kit.rod(a, a + 0.65 * d, 0.02, n=8),
                kit.along(kit.frustum(0.07, 0.02, 0.0, 0.16, n=12), d, a + 0.65 * d)]
    lga.append(_box((-XC - 0.12, -0.95, 0.55), (-XC + 0.01, -0.70, 0.75)))          # fine Sun sensor
    p.append(kit.part("low-gain antennas and Sun sensor", (0.75, 0.75, 0.74), *lga))
    return p


def _wings(kit):
    p = []
    cells, backs, frame, sada = [], [], [], []
    for sy in (-1, 1):
        def Y(y):
            return sy * y
        y_root = 1.95
        sada.append(_box((X_ARRAY - 0.22, min(Y(y_root), Y(y_root + 0.32)), Z_ARRAY - 0.20),
                         (X_ARRAY + 0.22, max(Y(y_root), Y(y_root + 0.32)), Z_ARRAY + 0.20)))
        frame.append(kit.rod((X_ARRAY, Y(y_root + 0.30), Z_ARRAY), (X_ARRAY, Y(Y_TIP), Z_ARRAY), 0.045, n=8))
        apex, base_y = 2.90, 4.12
        for dx in (-1.42, 1.42):
            frame.append(kit.rod((X_ARRAY, Y(apex), Z_ARRAY), (X_ARRAY + dx, Y(base_y), Z_ARRAY), 0.04, n=8))
        frame.append(kit.rod((X_ARRAY - 1.44, Y(base_y), Z_ARRAY), (X_ARRAY + 1.44, Y(base_y), Z_ARRAY), 0.04, n=8))
        frame.append(kit.rod((X_ARRAY - 0.3, Y(apex), Z_ARRAY), (X_ARRAY + 0.3, Y(apex), Z_ARRAY), 0.035, n=8))
        for k in range(4):
            y0 = 4.20 + k * 1.615
            y1 = y0 + 1.575
            for x0, x1 in ((X_ARRAY + 0.06, X_ARRAY + 1.40), (X_ARRAY - 1.40, X_ARRAY - 0.06)):
                lo, hi = sorted((Y(y0), Y(y1)))
                backs.append(_box((x0, lo, Z_ARRAY - 0.0125), (x1, hi, Z_ARRAY + 0.0125)))
                cells.append(_box((x0 + 0.02, lo + 0.02, Z_ARRAY - 0.0185), (x1 - 0.02, hi - 0.02, Z_ARRAY - 0.0155)))
        # a stiffener across each wing's outer end
        frame.append(kit.rod((X_ARRAY - 1.40, Y(Y_TIP), Z_ARRAY), (X_ARRAY + 1.40, Y(Y_TIP), Z_ARRAY), 0.025, n=6))
    p.append(U.tpart(kit, "solar array backs", ARRAY_BACK, U.refine_each(backs, 0.6), tex_array_back(),
                     axes=((1, 0, 0), (0, 1, 0)), tile=(1.34, 1.575)))
    p.append(U.tpart(kit, "solar cells", CELLS,
                     U.refine_each(cells, 0.6),
                     U.tex_cells(nx=12, ny=16, gap=0.05, line=0.45, jitter=0.25, tint=(0.9, 0.95, 1.2), dots=3),
                     axes=((1, 0, 0), (0, 1, 0)), tile=(1.34, 1.575)))
    p.append(kit.part("solar array booms and A-frames", (0.82, 0.82, 0.80), *frame))
    p.append(kit.part("solar array drives", (0.12, 0.12, 0.13), *sada))
    return p


def _hga(kit):
    p = []
    hinge = np.array([-2.55, -0.55, -ZC - 0.06])
    d = np.array([-0.69, 0.0, -0.72])
    d /= np.linalg.norm(d)
    tip = hinge + 4.65 * d
    boom = [kit.rod(hinge, tip, 0.05, n=12),
            _box(hinge - (0.15, 0.15, 0.0), hinge + (0.15, 0.15, 0.10))]                 # hinge bracket
    w = np.cross(d, (0, 1, 0))
    t = hinge + 3.55 * d                                                              # the magnetic torquers
    tq = [kit.rod(t - 0.55 * np.array([0, 1, 0]), t + 0.55 * np.array([0, 1, 0]), 0.035, n=8),
          kit.rod(t - 0.55 * w, t + 0.55 * w, 0.035, n=8),
          kit.rod(t - 0.50 * d, t + 0.45 * d, 0.065, n=10)]
    gimbal = _box(tip - 0.12, tip + 0.12)
    axis = np.array([-1.0, 0.0, 0.0])                                                 # the dish looks -X
    vertex = tip + 0.18 * axis
    reflector = kit.along(U.dish(0.76, 0.20, n=40, m=6), axis, vertex)
    feed = kit.along(kit.frustum(0.13, 0.05, 0.05, 0.42, n=16), axis, vertex)
    p.append(kit.part("high-gain antenna boom", (0.82, 0.82, 0.80), *boom, gimbal))
    p.append(kit.part("magnetic torquers", (0.30, 0.30, 0.32), *tq))
    p.append(kit.part("high-gain dish (white paint)", (0.84, 0.84, 0.82), U.refine(reflector, 0.4), feed))
    return p


def build(kit):
    parts = _platform(kit) + _instruments(kit) + _ends_and_sides(kit) + _wings(kit) + _hga(kit)
    return dict(meta=dict(name="Compton Gamma Ray Observatory",
                          frame="CGRO: +X along the body toward EGRET (OSSE and the high-gain antenna at -X), "
                                "+Y along the solar arrays, +Z the instruments' pointing axis (the domes' "
                                "side; the gold underside -Z); m; the platform's centre",
                          source="shapes after the GRO Prelaunch Mission Operations Report's configuration "
                                 "drawings and the STS-37 photographs; proportions after NASA 3D Resources' "
                                 "Gamma Ray Observatory",
                          norad=21225, mag_1000km=1.0),
                parts=U.refine_parts(parts))
