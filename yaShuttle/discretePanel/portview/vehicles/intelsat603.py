"""Intelsat 603 (Intelsat VI F-3, NORAD 20523), as STS-49 met it in May
1992: stranded in a 557 km orbit since the Titan III's two-satellite
adapter failed to separate its perigee stage in March 1990, still in its
launch configuration -- the Hughes HS-393's two cylindrical solar drums
telescoped one over the other (3.64 m across, ~4.3 m long), the antenna
farm folded down under its blankets on the forward end, the TT&C omni on
its mast standing up off the forward deck, and the aft end an open,
gold-blanketed cavity round the separation ring where the crew fitted the
capture bar and then the new Orbus-21 perigee motor.

Proportions from the STS-49 capture photographs (s49-91-020/026/029) and
the published dimensions (3.64 m drum; 5.3 m stowed overall)."""
import math

import numpy as np

from . import _leo_util as U

KEY = 'intelsat603'

R = 1.82                       # the drum
X_AFT, X_FWD = -2.15, 2.15
CELLS = (0.035, 0.035, 0.05)   # the drum's cells, near black under the cover glass
GOLD = (0.72, 0.55, 0.26)


def build(kit):
    p = []
    # the solar drums: the aft (outer) skirt over the forward (inner) drum,
    # whose lip shows 0.12 m at the top, a little smaller
    cells = U.tex_cells(12, 12, gap=0.10, line=0.45)
    p.append(U.tpart(kit, "solar drum (aft skirt)", CELLS,
                     U.cylinder_fine(R, X_AFT, X_FWD - 0.14, n=64, max_len=0.4, caps=False), cells, cyl=(0.5, 24), smooth=True))
    p.append(U.tpart(kit, "solar drum (forward)", CELLS,
                     kit.cylinder(R - 0.03, X_FWD - 0.14, X_FWD, n=64, caps=False), cells, cyl=(0.5, 24), smooth=True))
    p.append(kit.part("drum step", (0.10, 0.10, 0.12), kit.disc(R, X_FWD - 0.14, n=64, r_in=R - 0.03)))
    # the bands where the cell panels meet, and the drum's bottom rim
    bands = [kit.tube(R + 0.004, R - 0.02, x, x + 0.03, n=64) for x in (-0.95, 0.15, 1.25)]
    p.append(kit.part("drum panel joints", (0.55, 0.45, 0.25), *bands))
    p.append(kit.part("aft rim", (0.10, 0.10, 0.12), kit.tube(R + 0.006, R - 0.08, X_AFT - 0.08, X_AFT + 0.02, n=64)))
    # sun sensor and thermal windows: small gold squares on the drum
    win = []
    for a, x, s in ((10, -1.0, 0.34), (95, -1.0, 0.24), (200, -1.05, 0.30), (290, 0.2, 0.10),
                    (40, 0.25, 0.10), (130, 0.9, 0.09), (250, 0.95, 0.09), (330, -0.95, 0.10)):
        t = math.radians(a)
        n = np.array([0.0, math.cos(t), math.sin(t)])
        m = kit.box((0.01, s, s), (0, 0, 0))
        Rm = np.column_stack([n, np.cross((1, 0, 0), n), (1, 0, 0)])
        win.append(kit.move(kit.turn(m, Rm), n * (R + 0.006) + (x, 0, 0)))
    p.append(kit.part("windows", GOLD, *win))
    # forward end: gold blanket annulus inside the lip, the folded antenna
    # farm under black blankets in the middle, the omni mast
    p.append(kit.part("forward blanket", GOLD,
                      U.refine(kit.disc(R - 0.04, X_FWD - 0.05, n=64), 0.4),
                      kit.tube(R - 0.03, R - 0.10, X_FWD - 0.05, X_FWD + 0.06, n=64)))
    p.append(kit.part("stowed antenna farm", (0.07, 0.07, 0.08),
                      kit.cylinder(1.15, X_FWD - 0.04, X_FWD + 0.30, n=40),
                      kit.box((0.45, 0.9, 0.7), (X_FWD + 0.45, 0.25, -0.30))))
    mast_base = np.array([X_FWD + 0.30, -0.35, 0.30])
    mast_top = mast_base + 2.0 * np.array([math.cos(math.radians(14)), -math.sin(math.radians(14)), 0.0])
    p.append(kit.part("omni mast (gold-wrapped)", GOLD, kit.rod(mast_base, mast_top, 0.05, n=10),
                      kit.rod(mast_base + 0.7 * (mast_top - mast_base), mast_top - 0.05 * (mast_top - mast_base),
                              0.10, n=10)))
    p.append(kit.part("omni antenna", (0.70, 0.70, 0.70),
                      kit.along(kit.cylinder(0.07, 0.0, 0.22, n=12), mast_top - mast_base, mast_top),
                      kit.along(kit.sphere(0.05, n=8, centre=(0.24, 0, 0)), mast_top - mast_base, mast_top)))
    # aft end: an open cavity lined with gold blanket, the bus's aft bulkhead
    # 0.6 m in, the separation ring and the motor's thrust tube
    p.append(kit.part("drum inside", (0.30, 0.24, 0.12),
                      U.flip(U.cylinder_fine(R - 0.02, X_AFT + 0.02, X_AFT + 0.65, n=64, max_len=0.2, caps=False)),
                      smooth=True))
    p.append(kit.part("aft bulkhead blanket", GOLD, U.refine(U.facing_aft(kit, kit.disc(R - 0.02, 0.0, n=64), X_AFT + 0.65), 0.4)))
    p.append(kit.part("separation ring", (0.60, 0.60, 0.62),
                      kit.tube(0.62, 0.56, X_AFT + 0.10, X_AFT + 0.65, n=48)))
    p.append(kit.part("thrust tube end", (0.25, 0.25, 0.27),
                      U.facing_aft(kit, kit.disc(0.56, 0.0, n=48), X_AFT + 0.63)))
    # the two aft-end propellant tank domes either side, as the photos show
    domes = [kit.sphere(0.20, n=10, centre=(X_AFT + 0.55, 0, s * 1.25), x_range=(-0.20, 0.0)) for s in (-1, 1)]
    p.append(kit.part("tank domes", (0.12, 0.12, 0.13), *domes, smooth=True))
    return dict(meta=dict(name="Intelsat 603 (Intelsat VI F-3, stowed, as STS-49 captured it)",
                          frame="HS-393: +X along the spin axis toward the forward (antenna) end, "
                                "+Y the omni mast's lean the other way; m; mid-drum (the stowed "
                                "satellite's mass sits near it)",
                          source="simple shapes to published dimensions and the STS-49 photographs",
                          norad=20523, mag_1000km=2.0),
                parts=U.refine_parts(p))
