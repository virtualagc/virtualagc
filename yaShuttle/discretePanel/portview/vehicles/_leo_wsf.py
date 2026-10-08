"""The Wake Shield Facility free-flyer (University of Houston / Space
Vacuum Epitaxy Center): a 3.66 m (12 ft) stainless-steel disc whose wake
side, flown trailing at 7.7 km/s, leaves an ultra-vacuum behind
it for growing thin semiconductor films.

The wake side (+X here): a smooth polished face, slightly domed, with the
substrate carousel and the effusion cells on a strut frame ~0.9 m out from
its centre.  The ram side (-X): a shallow cone of sixteen radial ribbed
bays round the central equipment boxes (batteries, avionics, the cold-gas
attitude system's tanks) and the grapple fixture at the centre; six
light-grey round pads round the ring, two green GPS/antenna bars.  On STS-60
(1994) it never left the arm; it flew free on STS-69 (1995) and STS-80
(1996).  Proportions from sts060-76-095, sts069-723-072, sts069-732-048.
"""
import math

import numpy as np

from . import _leo_util as U

R = 1.83
STEEL = (0.30, 0.30, 0.31)          # polished: it mostly mirrors black sky
STEEL_DARK = (0.33, 0.33, 0.34)
GREY = (0.55, 0.56, 0.57)
GREEN = (0.32, 0.45, 0.30)


def parts(kit):
    p = []
    # wake side: the polished dish
    wake = U.refine(kit.frustum(R, 0.25, 0.0, 0.10, n=64, caps=False), 0.4)
    p.append(kit.part("wake shield (polished steel)", STEEL, wake, kit.disc(0.25, 0.10, n=64), smooth=True))
    p.append(kit.part("rim", STEEL_DARK, kit.tube(R + 0.02, R - 0.06, -0.10, 0.01, n=64)))
    # ram side: the ribbed cone and the central bay floor
    cone = U.flip(U.refine(kit.frustum(R - 0.06, 0.95, -0.08, -0.38, n=64, caps=False), 0.4))
    p.append(U.tpart(kit, "ram-side bays", STEEL_DARK, cone, U.tex_panels(16, 2, seed=71, spread=0.3, line=0.5),
                     cyl=(0.6, 16), smooth=True))
    p.append(kit.part("central bay floor", STEEL_DARK, U.facing_aft(kit, kit.disc(0.95, 0.0, n=48), -0.38)))
    ribs = []
    for k in range(16):
        a = 2 * math.pi * k / 16
        c, s = math.cos(a), math.sin(a)
        for r0, r1, x0, x1 in ((0.95, R - 0.06, -0.38, -0.08),):
            ribs.append(kit.rod((x0 - 0.03, r0 * c, r0 * s), (x1 - 0.03, r1 * c, r1 * s), 0.025, n=4))
    ribs.append(kit.tube(1.30, 1.26, -0.30, -0.22, n=48))
    p.append(kit.part("radial ribs", (0.65, 0.65, 0.66), *ribs))
    # the central equipment boxes and the grapple fixture
    boxes = [kit.box((0.55, 0.90, 0.70), (-0.66, 0.0, 0.15)),
             kit.box((0.45, 0.55, 0.45), (-0.60, -0.45, -0.45)),
             kit.box((0.40, 0.45, 0.50), (-0.58, 0.55, -0.40)),
             kit.box((0.35, 0.40, 0.35), (-0.55, 0.95, 0.75))]
    p.append(U.tpart(kit, "equipment boxes", GREY, kit.merge(*boxes), U.tex_panels(2, 2, seed=72), tile=0.6))
    p.append(kit.part("white box", (0.80, 0.80, 0.78), kit.box((0.35, 0.40, 0.35), (-0.30, -1.30, 0.45))))
    for name, rgb, m in U.frgf(kit, (-0.93, 0.0, -0.05), (-1, 0, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    pads = []
    for k in range(6):
        a = 2 * math.pi * (k + 0.5) / 6
        q = np.array([0.0, 1.5 * math.cos(a), 1.5 * math.sin(a)])
        x = -0.08 - 0.30 * (R - 0.06 - 1.5) / (R - 0.06 - 0.95) - 0.04
        pads.append(kit.along(kit.cylinder(0.17, 0.0, 0.03, n=20), (-1, 0, 0), q + (x, 0, 0)))
    p.append(kit.part("pads", (0.70, 0.70, 0.70), *pads))
    p.append(kit.part("green bars", GREEN, kit.box((0.06, 0.12, 0.90), (-0.12, -1.55, 0.0)),
                      kit.box((0.06, 0.90, 0.12), (-0.12, 0.2, 1.55))))
    # the wake-side experiment frame: struts out to the carousel
    hub = np.array([0.95, 0.0, 0.0])
    st = []
    for k in range(6):
        a = 2 * math.pi * k / 6
        st.append(kit.rod((0.08, 0.75 * math.cos(a), 0.75 * math.sin(a)), hub + (0, 0.18 * math.cos(a), 0.18 * math.sin(a)),
                          0.025, n=6))
    p.append(kit.part("wake-side struts", (0.70, 0.70, 0.70), *st))
    p.append(kit.part("substrate carousel", (0.75, 0.73, 0.68),
                      kit.cylinder(0.22, 0.75, 1.15, n=24), kit.cylinder(0.12, 1.15, 1.30, n=16), smooth=False))
    cells = [kit.box((0.25, 0.18, 0.18), (0.30, 0.55 * math.cos(a), 0.55 * math.sin(a)))
             for a in (0.3, 2.4, 4.4)]
    p.append(kit.part("effusion cells", (0.50, 0.40, 0.25), *cells))
    return p


def module(kit, mission, norad):
    return dict(meta=dict(name="Wake Shield Facility (%s)" % mission,
                          frame="WSF: +X out of the polished wake side (the experiments' side), -X "
                                "the ram side (the grapple fixture), +Y and +Z in the disc; m; the "
                                "disc's centre (the equipment's mass is just behind it)",
                          source="simple shapes to published dimensions (3.66 m disc) and STS-60/69 photographs",
                          norad=norad, mag_1000km=2.5),
                parts=U.refine_parts(parts(kit)))
