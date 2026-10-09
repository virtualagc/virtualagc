"""The Wake Shield Facility free-flyer (University of Houston / Space
Vacuum Epitaxy Center): a 3.66 m (12 ft) stainless-steel disc whose wake
side, flown trailing at 7.7 km/s, leaves an ultra-vacuum behind it for
growing thin semiconductor films.  On STS-60 (1994) it never left the arm;
it flew free on STS-69 (1995, WSF-2) and STS-80 (1996, WSF-3).

What the photographs decided (scales from the 3.66 m disc):

* The wake side (+X) is a flat polished plate -- black where it mirrors
  the sky, a bright smear where it mirrors the orbiter or the Earth --
  with an inner circle (r ~0.9 m) where the hexapod's feet stand; six
  struts in three pairs (a hexapod) carry the cylindrical, flanged
  experiment hub (~0.42 m across, ~0.35 m long) ~0.65-1.0 m off the
  plate, a slim central column with a small disc halfway out between
  plate and hub, and a sensor tube standing off the plate near the rim
  (sts069-732-048, sts080-708-065, sts060-74-054).  The old model's
  shallow cone on this side is gone: every photo shows the plate flat.
* The ram side (-X): a rim band ~0.3 m deep, then a shallow cone of bare
  metal bays (light grey, not dark) cut by radial gusset ribs and two
  ring webs (r ~1.32 m and the central opening's edge at r ~0.88 m);
  four round grey/white target pads (0.31 m across, a 0.10 m black hole
  and a side tab) on the outer annulus at r ~1.58 m, about 90 deg apart
  on the diagonals (sts069-723-072, measured face-on, and sts060-76-095);
  a fifth pad on the central boxes' end.  The central equipment boxes
  (avionics, batteries, the cold-gas system) fill the opening and stand
  ~0.9 m behind the plate, the grapple fixture on their -X face
  (sts069-723-072 for the box layout; sts060-74-054 and sts080-708-065,
  edge-on, for the depth).  Round the cone: a tangential bar 1.07 m long
  at r ~1.54 m and a short one (0.47 m) at the bottom -- light green on
  STS-60, dark green on STS-69 (723-072), gold on STS-80 (708-084,
  755-016); a gridded round panel (0.6 m) on the inner annulus; a
  foil-wrapped instrument and a small gold box near the top of the rim;
  a camera box straddling the rim on one side and a T-shaped latch pin on
  the other; three rounded tabs sticking out of the rim (723-072,
  732-048).
* WSF-3 (STS-80) differs in finish: its central boxes and pads are
  white-painted, the bars gold, and it carried an extra white box on the
  upper cone and a gold-and-black bar along -X from the boxes
  (sts080-708-084, sts080-755-016, sts080-708-065).  The geometry is
  otherwise WSF-2's (variant='wsf3').

Uncertain: the clocking of the wake-side hexapod relative to the ram-side
layout (no photo shows both sides' features together), the exact depth of
the ram-side cone, and the small boxes' sizes (to ~0.1 m).
"""
import math

import numpy as np

from . import _leo_util as U

R = 1.83
STEEL = (0.07, 0.07, 0.075)          # polished: it mostly mirrors black sky
STEEL_INNER = (0.09, 0.09, 0.095)
BAYS = (0.44, 0.44, 0.45)           # the bare-metal ram-side bays
RIB = (0.60, 0.60, 0.61)
RIM = (0.62, 0.62, 0.63)
GREY = (0.55, 0.56, 0.57)
WHITE = (0.80, 0.80, 0.78)
GOLD = (0.70, 0.52, 0.18)
BLACK = (0.03, 0.03, 0.03)

# the ram-side cone: from the rim (r R_C0 at X_C0) back to the central
# opening (r R_C1 at X_C1)
R_C0, X_C0 = R - 0.03, -0.04
R_C1, X_C1 = 0.88, -0.36
SLOPE = math.atan2(X_C0 - X_C1, R_C0 - R_C1)       # ~19 deg


def _xf(r):
    """The ram-side floor's X at radius r."""
    return X_C0 - (X_C0 - X_C1) * (R_C0 - r) / (R_C0 - R_C1)


def _dir(theta):
    """A unit vector in the disc (Y, Z) at angle theta (deg), measured as in
    sts069-723-072 (looking along +X from the ram side): 0 to the image's
    right (-Y), 90 up (+Z)."""
    t = math.radians(theta)
    return np.array([0.0, -math.cos(t), math.sin(t)])


def _slab(kit, c, t):
    """A thin plate on the four coplanar corners c (convex, in order),
    thickness t."""
    c = np.asarray(c, float)
    n = np.cross(c[1] - c[0], c[2] - c[0])
    n = n / np.linalg.norm(n) * t / 2
    pts = np.vstack([c - n, c + n])
    q = ((0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0))
    return pts, np.array([tr for a, b, cc, d in q for tr in ((a, b, cc), (a, cc, d))])


def _on_cone(kit, mesh, theta, r, lift):
    """A mesh made facing +X (centred on the origin, 'up' +Z), laid on the
    ram-side cone at (theta, r), facing out of it (-X, tilted outward by
    the cone's slope), `lift` metres off the floor."""
    d = _dir(theta)
    nrm = np.array([-math.cos(SLOPE), 0, 0]) + math.sin(SLOPE) * d
    R_ = U.frame_from(nrm, d)
    at = np.array([_xf(r), 0, 0]) + r * d + lift * nrm
    return kit.move(kit.turn(mesh, R_), at)


def _box_ram(kit, y0, y1, z0, z1, x0, x1):
    return kit.box((x1 - x0, y1 - y0, z1 - z0), ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))


def parts(kit, variant='wsf2'):
    three = variant == 'wsf3'
    equip = WHITE if three else GREY
    pad_c = (0.85, 0.85, 0.83) if three else (0.72, 0.72, 0.72)
    bar_c = GOLD if three else (0.16, 0.28, 0.16)
    p = []
    # ---- the wake side: the flat polished plate, its inner circle
    p.append(kit.part("wake shield (polished steel)", STEEL, U.refine(kit.disc(R - 0.02, 0.0, n=72), 0.4)))
    p.append(kit.part("wake shield inner plate", STEEL_INNER, U.refine(kit.disc(0.92, 0.005, n=48), 0.4)))
    # the rim band and its wake-side lip
    p.append(U.tpart(kit, "rim band", RIM, kit.tube(R + 0.012, R - 0.035, -0.30, 0.012, n=72),
                     U.tex_panels(24, 1, seed=73, spread=0.12, line=0.7), cyl=(0.3, 24)))
    p.append(kit.part("rim lip", (0.60, 0.60, 0.61), kit.tube(R + 0.022, R - 0.012, -0.02, 0.02, n=72)))
    # ---- the ram side: the cone of bays, the rib gussets, the two ring webs
    cone = U.flip(U.refine(kit.frustum(R_C0, R_C1, X_C0, X_C1, n=64, caps=False), 0.4))
    p.append(U.tpart(kit, "ram-side bays (bare metal)", BAYS, cone,
                     U.tex_panels(16, 2, seed=71, spread=0.3, line=0.55), cyl=(0.5, 16), smooth=True))
    p.append(kit.part("central bay floor", BAYS, U.facing_aft(kit, kit.disc(R_C1, 0.0, n=48), -0.40)))
    ribs = []
    for k in range(16):
        d = _dir(360.0 * k / 16 + 11.25)
        c = [np.array([x, 0, 0]) + r * d for x, r in
             ((-0.02, R - 0.04), (-0.30, R - 0.04), (-0.50, R_C1 + 0.01), (_xf(R_C1 + 0.01) + 0.01, R_C1 + 0.01))]
        ribs.append(_slab(kit, c, 0.02))
    ribs.append(kit.tube(1.33, 1.31, _xf(1.32) - 0.16, _xf(1.32) + 0.01, n=64))
    ribs.append(kit.tube(R_C1 + 0.01, R_C1 - 0.01, -0.52, X_C1 + 0.01, n=48))
    p.append(kit.part("ribs and ring webs", RIB, *ribs))
    # the four target pads on the outer annulus (and their side tabs)
    pads, holes = [], []
    for th in (31, 132, 218, 307):
        pads.append(_on_cone(kit, kit.cylinder(0.155, -0.03, 0.0, n=24), th, 1.58, 0.05))
        pads.append(_on_cone(kit, kit.box((0.03, 0.08, 0.10), (-0.015, 0.0, 0.17)), th, 1.58, 0.05))
        pads.append(_on_cone(kit, kit.cylinder(0.04, -0.06, -0.03, n=10), th, 1.58, 0.05))   # standoff
        holes.append(_on_cone(kit, kit.disc(0.05, 0.005, n=16), th, 1.58, 0.05))
    # ---- the central equipment boxes (sts069-723-072, face-on)
    boxes = [_box_ram(kit, -0.49, 0.42, 0.045, 0.49, -0.86, -0.40),      # upper box
             _box_ram(kit, 0.54, 1.09, -0.71, 0.0, -0.95, -0.30),        # +Y box
             _box_ram(kit, -0.89, -0.13, -0.71, 0.02, -0.90, -0.38),     # -Y box (pad on its end)
             _box_ram(kit, -0.13, 0.54, -0.71, 0.03, -0.80, -0.40)]      # core (grapple fixture)
    p.append(U.tpart(kit, "equipment boxes", equip, kit.merge(*boxes),
                     U.tex_panels(3, 3, seed=72, spread=0.12, line=0.75), tile=0.6))
    pads.append(kit.along(kit.cylinder(0.155, 0.0, 0.025, n=24), (-1, 0, 0), (-0.905, -0.34, -0.40)))
    holes.append(kit.along(kit.disc(0.05, 0.0, n=16), (-1, 0, 0), (-0.935, -0.34, -0.40)))
    p.append(kit.part("target pads", pad_c, *pads))
    p.append(kit.part("target pad holes", BLACK, *holes))
    for name, rgb, m in U.frgf(kit, (-0.805, 0.13, -0.31), (-1, 0, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    # the two tangential bars on the cone (and STS-80's bar along -X)
    bars = []
    for th, r, L in ((0.0, 1.54, 1.07), (284.0, 1.50, 0.47)):
        bars.append(_on_cone(kit, kit.box((0.08, 0.13, L), (0.04, 0, 0)), th, r, 0.09))
        bars.append(_on_cone(kit, kit.box((0.09, 0.04, 0.04), (0.045, 0, 0.0)), th, r, 0.006))
    if three:
        bars.append(_box_ram(kit, 0.10, 0.24, -0.82, -0.68, -1.30, -0.50))
    p.append(kit.part("bars (%s)" % ("gold" if three else "green"), bar_c, *bars))
    # instruments round the cone
    foil = [_on_cone(kit, kit.box((0.30, 0.35, 0.40), (0.15, 0, 0)), 88, 1.43, 0.006)]
    p.append(U.tpart(kit, "foil-wrapped instrument", (0.72, 0.72, 0.74), kit.merge(*foil),
                     U.tex_mli(74, seams=1, depth=0.55), tile=0.35))
    p.append(kit.part("gold box", GOLD, _on_cone(kit, kit.box((0.15, 0.27, 0.16), (0.075, 0, 0)), 67, 1.66, 0.006)))
    p.append(kit.part("brown box", (0.40, 0.30, 0.18),
                      _on_cone(kit, kit.box((0.20, 0.22, 0.25), (0.10, 0, 0)), 144, 1.64, 0.006)))
    small = [_on_cone(kit, kit.box((0.12, 0.45, 0.38), (0.06, 0, 0)), 196, 1.63, 0.006),
             _on_cone(kit, kit.box((0.15, 0.22, 0.22), (0.075, 0, 0)), 318, 1.56, 0.006),
             _box_ram(kit, 0.31, 0.49, -0.96, -0.71, -0.50, -0.30)]
    if three:     # STS-80's extra white box on the upper cone (708-084)
        small.append(_on_cone(kit, kit.box((0.35, 0.55, 0.50), (0.175, 0, 0)), 115, 1.25, 0.006))
    p.append(kit.part("small boxes", equip, *small))
    grid = _on_cone(kit, kit.cylinder(0.30, -0.03, 0.0, n=32), 38, 1.02, 0.04)
    p.append(U.tpart(kit, "gridded panel", (0.36, 0.39, 0.46), grid,
                     U.tex_panels(6, 6, seed=75, spread=0.2, line=0.35), tile=0.6))
    # the camera box straddling the rim (+Y) and the T latch pin (-Y)
    cam = _box_ram(kit, R - 0.45, R + 0.13, 0.13, 0.58, -0.36, -0.05)
    p.append(kit.part("rim camera box", (0.70, 0.70, 0.70), cam))
    p.append(kit.part("camera lens", BLACK, kit.along(kit.cylinder(0.07, 0.0, 0.06, n=16), (0, 1, 0),
                                                       (-0.20, R + 0.13, 0.35))))
    d = _dir(0.0)
    tee = [kit.rod(np.array([-0.15, 0, 0]) + (R + 0.01) * d, np.array([-0.15, 0, 0]) + (R + 0.14) * d, 0.03, n=8),
           kit.rod(np.array([-0.15, 0, -0.16]) + (R + 0.14) * d, np.array([-0.15, 0, 0.16]) + (R + 0.14) * d, 0.035, n=8),
           kit.rod(np.array([-0.30, 0, 0]) + (R + 0.10) * d, np.array([0.0, 0, 0]) + (R + 0.10) * d, 0.025, n=8)]
    p.append(kit.part("latch pin", (0.75, 0.70, 0.55), *tee))
    tabs = []
    for th in (56, 130, 270):
        dd = _dir(th)
        tabs.append(kit.move(kit.cylinder(0.15, -0.21, -0.19, n=20), (R - 0.01) * dd))
    p.append(kit.part("rim tabs", (0.76, 0.76, 0.76), *tabs))
    # ---- the wake side's experiment frame: the hexapod, the hub, the column
    st, feet = [], []
    base = lambda a: np.array([0.03, 0.0, 0.0]) + 0.90 * np.array([0, math.cos(math.radians(a)), math.sin(math.radians(a))])
    hub = lambda a: np.array([0.68, 0.0, 0.0]) + 0.19 * np.array([0, math.cos(math.radians(a)), math.sin(math.radians(a))])
    for k in range(3):
        a = 120.0 * k
        st.append(kit.rod(base(a + 16), hub(a + 60 - 16), 0.022, n=6))
        st.append(kit.rod(base(a - 16), hub(a - 60 + 16), 0.022, n=6))
        for s in (-16, 16):
            u = np.array([0, math.cos(math.radians(a + s)), math.sin(math.radians(a + s))])
            Rf = U.frame_from((1, 0, 0), u)
            feet.append(kit.move(kit.turn(kit.box((0.018, 0.13, 0.20), (0, 0, 0)), Rf), base(a + s) - (0.009, 0, 0)))
    col = [kit.rod((0.01, 0, 0), (0.68, 0, 0), 0.05, n=10),
           kit.cylinder(0.17, 0.33, 0.36, n=24)]
    for k in range(4):
        a = math.radians(45 + 90 * k)
        col.append(kit.rod((0.01, 0.10 * math.cos(a), 0.10 * math.sin(a)), (0.68, 0.10 * math.cos(a), 0.10 * math.sin(a)),
                           0.012, n=6))
    p.append(kit.part("hexapod struts and column", (0.72, 0.72, 0.72), *st, *col))
    p.append(kit.part("hexapod feet", (0.70, 0.70, 0.69), *feet))
    p.append(U.tpart(kit, "experiment hub", (0.66, 0.66, 0.67), kit.cylinder(0.21, 0.68, 1.02, n=32, caps=False),
                     U.tex_panels(8, 2, seed=76, spread=0.1, line=0.7), cyl=(0.34, 8), smooth=True))
    p.append(kit.part("hub end plates", (0.45, 0.45, 0.46), kit.disc(0.21, 1.02, n=32),
                      U.facing_aft(kit, kit.disc(0.21, 0.0, n=32), 0.68)))
    p.append(kit.part("hub flanges", (0.58, 0.58, 0.59), kit.tube(0.235, 0.20, 0.685, 0.72, n=32),
                      kit.tube(0.235, 0.20, 0.975, 1.015, n=32)))
    dd = _dir(235)
    p.append(kit.part("wake-side sensor tube", (0.70, 0.70, 0.70),
                      kit.move(kit.cylinder(0.05, 0.005, 0.45, n=12), 1.45 * dd)))
    return p


def module(kit, mission, norad, variant='wsf2'):
    return dict(meta=dict(name="Wake Shield Facility (%s)" % mission,
                          frame="WSF: +X out of the polished wake side (the experiments' side), -X "
                                "the ram side (the grapple fixture), +Y and +Z in the disc (+Y the "
                                "rim camera box's side, as in sts069-723-072 seen from the ram side "
                                "with +Z up); m; the disc's centre (the equipment's mass is just "
                                "behind it)",
                          source="simple shapes measured off STS-60/69/80 photographs (sts069-723-072, "
                                 "sts069-732-048, sts060-76-095, sts060-74-054, sts080-708-065/084, "
                                 "sts080-755-016) to the 3.66 m disc",
                          norad=norad, mag_1000km=2.5),
                parts=U.refine_parts(parts(kit, variant)))
