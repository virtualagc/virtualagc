"""Intelsat 603 (Intelsat VI F-3, NORAD 20523), as STS-49 met it in May
1992: stranded in a 557 km orbit since the Titan III's two-satellite
adapter failed to separate its perigee stage in March 1990, still in its
launch configuration -- the Hughes HS-393's two cylindrical solar drums
telescoped one over the other (3.64 m across), the antenna farm folded
down under a gold blanket on the forward end, the TT&C omni on its mast
leaning out over that end, and the aft end open -- a gold-blanketed
annulus round the 2.35 m ring the Titan's adapter had held, where the
crew fitted the capture bar and then the new Orbus-21 perigee motor.

What the STS-49 photographs decided (sizes scaled from the 3.64 m drum):

* drum length: 3.75 m of cells and a 0.25 m dark band at the aft end
  (9301572, the satellite side-on from far off, level; s49-91-020 gives
  about the same).  The close views from the cabin (s49-91-026/-029,
  9257083) look 15% longer -- wide-angle perspective -- and were not
  used for length.
* the cell drum's three gold joint rings 28%, 48% and 67% of the way
  aft from its forward edge (the same in 9301572, s49-91-026, -029); a
  few full-length axial panel joints (9301572, s49-91-020).
* windows: in the band below the middle ring, sitting on the third ring,
  gold-framed openings (a 0.5 x 0.4 m outline frame), solid gold squares
  0.33 m with a dark centre 46 deg either side of it, and a dark slot
  (s49-91-020, -029, 9301572); one solid square 75 deg the other way
  (-029).  The far side's are a guess.  Small gold squares (0.07 m) every
  45 deg just forward of the middle ring.
* the forward end (9257083, s49-91-026, 9301572): a dark grey band 0.10 m
  inset at the drum's forward edge, then the stowed antenna farm under a
  wrinkled gold blanket -- a drum 3.1 m across (0.85 of the solar drum)
  standing 0.45 m higher, its top dished and in shadow; a crinkled silver
  package on its rim; and on the opposite rim, from a white hinge box,
  the TT&C omni mast (gold-wrapped, ~2.7 m) leaning 44 deg in over the
  end so its tip, a gold cocoon and the silver omni, stands ~1.9 m above
  the blanket just past the spin axis (9301572, s49-91-020, -026).
* the aft end (9301420, from the rendezvous; 9259496, during capture): a
  gold annulus set in 0.3 m; two cream sectors opposite each other, one
  with a dark round port; the 2.35 m ring (white rim) inside it; within,
  gold walls down to a floor with a cluster of silver cylinders.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'intelsat603'

R = 1.82                       # the drum
X_AFT, X_FWD = -2.00, 2.00
X_CELL0 = X_AFT + 0.25         # where the cells begin, past the dark aft band
CELL_L = X_FWD - X_CELL0
CELLS = (0.050, 0.046, 0.044)  # the cells, near black-bronze under the cover glass
GOLD = (0.72, 0.55, 0.26)
GOLD_JOINT = (0.62, 0.50, 0.26)
R_COVER = 1.55                 # the antenna farm's gold cover
X_BAND = X_FWD + 0.10          # top of the grey band at the drum's forward edge
X_TOP = X_BAND + 0.45          # the cover's rim
R_RING = 1.17                  # the aft adapter ring
X_ANN = X_AFT + 0.30           # the aft annulus
X_FLOOR = X_AFT + 0.75         # the floor inside the ring
O_AZ = 90.0                    # the outline window's azimuth (from +Y toward +Z)


def _n(az):
    t = math.radians(az)
    return np.array([0.0, math.cos(t), math.sin(t)])


def _on_drum(kit, m, az, x, r=R + 0.006):
    """A mesh made facing +X (thickness along X), laid on the drum at
    azimuth az, axial position x: its +X out, its Z along the axis."""
    n = _n(az)
    Rm = np.column_stack([n, np.cross((1, 0, 0), n), (1, 0, 0)])
    return kit.move(kit.turn(m, Rm), n * r + (x, 0, 0))


def build(kit):
    p = []
    f = lambda frac: X_FWD - frac * CELL_L          # fraction aft of the forward edge -> X
    # the solar drum (the aft skirt telescoped over the forward drum)
    cells = U.tex_cells(12, 12, gap=0.10, line=0.45)
    p.append(U.tpart(kit, "solar drum (cells)", CELLS,
                     U.cylinder_fine(R, X_CELL0, X_FWD, n=72, max_len=0.4, caps=False), cells, cyl=(0.45, 26),
                     smooth=True))
    # the gold joint rings between the cell panels, and the axial joints
    bands = [kit.tube(R + 0.004, R - 0.02, f(fr) - 0.0125, f(fr) + 0.0125, n=72) for fr in (0.28, 0.48, 0.67)]
    bands.append(kit.tube(R + 0.004, R - 0.02, X_FWD - 0.02, X_FWD, n=72))
    bands.append(kit.tube(R + 0.004, R - 0.02, X_CELL0, X_CELL0 + 0.02, n=72))
    ax = [_on_drum(kit, kit.box((0.006, 0.022, CELL_L - 0.04), (0, 0, 0)), O_AZ + d, 0.5 * (X_CELL0 + X_FWD), R + 0.001)
          for d in (19, 146, 273)]
    p.append(kit.part("cell panel joints (gold)", GOLD_JOINT, *bands, *ax))
    # windows on the band below the middle ring
    xw = f(0.67)
    solid, solid_c, frame, frame_in, slot = [], [], [], [], []
    for d, kind in ((0, 'O'), (46, 'S'), (105, 'D'), (180, 'O'), (226, 'S'), (285, 'S')):
        az = O_AZ + d
        if kind == 'S':
            solid.append(_on_drum(kit, kit.box((0.012, 0.33, 0.33), (0, 0, 0)), az, xw + 0.19))
            solid_c.append(_on_drum(kit, kit.box((0.012, 0.13, 0.11), (0, 0, 0)), az, xw + 0.20, R + 0.012))
        elif kind == 'O':
            w, h, t = 0.50, 0.40, 0.035
            for (cy, cz, sy, sz) in ((0, h / 2 - t / 2, w, t), (0, -h / 2 + t / 2, w, t),
                                     (w / 2 - t / 2, 0, t, h), (-w / 2 + t / 2, 0, t, h)):
                frame.append(_on_drum(kit, kit.box((0.012, sy, sz), (0, cy, cz)), az, xw + 0.22))
            frame_in.append(_on_drum(kit, kit.box((0.010, w - 2 * t, h - 2 * t), (0, 0, 0)), az, xw + 0.22, R + 0.004))
            frame.append(_on_drum(kit, kit.box((0.012, 0.025, 0.14), (0, -0.12, -0.06)), az, xw + 0.22, R + 0.010))
            frame.append(_on_drum(kit, kit.box((0.012, 0.16, 0.025), (0, -0.05, -0.12)), az, xw + 0.22, R + 0.010))
        else:
            slot.append(_on_drum(kit, kit.box((0.010, 0.11, 0.26), (0, 0, 0)), az, xw + 0.18))
    sq = [_on_drum(kit, kit.box((0.010, 0.07, 0.07), (0, 0, 0)), O_AZ + 22.5 + 45 * k, f(0.45)) for k in range(8)]
    p.append(kit.part("windows (gold)", GOLD, *solid, *frame, *sq))
    p.append(kit.part("window openings (dark)", (0.03, 0.03, 0.035), *solid_c, *frame_in, *slot))
    # forward: the inset grey band, the antenna farm's gold cover with its
    # dished top, the silver package on its rim, the omni mast
    p.append(kit.part("forward band (dark grey)", (0.16, 0.16, 0.17),
                      kit.cylinder(R - 0.06, X_FWD - 0.01, X_BAND, n=72, caps=False),
                      kit.disc(R - 0.005, X_FWD + 0.002, n=72, r_in=R - 0.06),
                      kit.disc(R - 0.06, X_BAND, n=72, r_in=R_COVER - 0.01)))
    gold_tex = U.tex_mli(61, seams=0, depth=0.75, tint=(1.0, 0.95, 0.85))
    wall = U.cylinder_fine(R_COVER, X_BAND - 0.005, X_TOP, n=64, max_len=0.25, caps=False)
    p.append(U.tpart(kit, "antenna farm cover (gold blanket)", GOLD, wall, gold_tex, cyl=(0.9, 9), smooth=True))
    dish = U.refine(kit.frustum(R_COVER - 0.01, 0.10, X_TOP, X_TOP - 0.30, n=64, caps=False), 0.35)
    p.append(U.tpart(kit, "antenna farm cover top (gold, in shadow)", (0.38, 0.28, 0.12), dish, gold_tex, tile=1.1,
                     axes=((0, 1, 0), (0, 0, 1))))
    p.append(kit.part("cover top centre", (0.30, 0.22, 0.10), kit.disc(0.11, X_TOP - 0.302, n=24)))
    p.append(kit.part("cover rim", (0.70, 0.56, 0.30), kit.tube(R_COVER + 0.02, R_COVER - 0.03, X_TOP - 0.02, X_TOP + 0.015, n=64)))
    pkg = kit.box((0.45, 0.38, 0.48), (X_TOP - 0.05, -(R_COVER - 0.10), 0.0))
    p.append(U.tpart(kit, "silver package (crinkled blanket)", (0.62, 0.62, 0.64), pkg,
                     U.tex_mli(62, seams=0, depth=0.6), tile=0.5))
    base = np.array([X_TOP + 0.10, R_COVER - 0.07, 0.0])
    tip = np.array([X_TOP + 1.90, -0.30, 0.0])
    d = (tip - base) / np.linalg.norm(tip - base)
    Lm = float(np.linalg.norm(tip - base))
    p.append(kit.part("omni mast hinge (white)", (0.80, 0.80, 0.78), kit.box((0.20, 0.18, 0.18), base - (0.06, 0, 0))))
    mast = kit.along(kit.cylinder(0.045, 0.0, Lm * 0.72, n=10), d, base)
    cocoon = kit.along(kit.merge(kit.frustum(0.05, 0.14, 0.0, 0.10, n=14, caps=False),
                                 kit.cylinder(0.14, 0.10, 0.45, n=14, caps=False),
                                 kit.frustum(0.14, 0.05, 0.45, 0.58, n=14, caps=False)), d, base + d * Lm * 0.70)
    p.append(U.tpart(kit, "omni mast (gold-wrapped)", GOLD, kit.merge(mast, cocoon), U.tex_mli(63, seams=0, depth=0.6),
                     tile=0.25))
    p.append(kit.part("omni antenna (silver)", (0.75, 0.75, 0.77),
                      kit.along(kit.merge(kit.cylinder(0.04, 0.0, Lm * 0.02 + 0.06, n=12),
                                          kit.cylinder(0.07, 0.06, 0.10, n=16),
                                          kit.cylinder(0.05, 0.10, 0.18, n=12),
                                          kit.cylinder(0.07, 0.18, 0.21, n=16)), d, base + d * (Lm * 0.70 + 0.58))))
    # aft: the dark band, the drum's inside, the gold annulus with its two
    # cream sectors, the adapter ring, the deeper floor and its cylinders
    p.append(kit.part("aft band (dark)", (0.07, 0.07, 0.08),
                      kit.cylinder(R - 0.03, X_AFT, X_CELL0 + 0.005, n=72, caps=False),
                      U.facing_aft(kit, kit.disc(R + 0.004, 0.0, n=72, r_in=R - 0.035), X_CELL0 - 0.003),
                      kit.tube(R - 0.01, R - 0.05, X_AFT - 0.02, X_AFT + 0.02, n=72)))
    p.append(kit.part("aft band inside", (0.20, 0.16, 0.08),
                      U.flip(U.cylinder_fine(R - 0.05, X_AFT + 0.02, X_ANN, n=72, max_len=0.2, caps=False)), smooth=True))
    ann = U.refine(U.facing_aft(kit, kit.disc(R - 0.05, 0.0, n=72, r_in=R_RING), X_ANN), 0.35)
    p.append(U.tpart(kit, "aft annulus (gold blanket)", GOLD, ann, U.tex_mli(64, seams=0, depth=0.55), tile=0.9,
                     axes=((0, 1, 0), (0, 0, 1))))
    sect = []
    for az0 in (40.0, 220.0):
        a = np.radians(np.linspace(az0, az0 + 60, 13))
        r0, r1 = R_RING + 0.03, R - 0.08
        pts = np.vstack([np.column_stack([np.full(13, X_ANN - 0.006), r0 * np.cos(a), r0 * np.sin(a)]),
                         np.column_stack([np.full(13, X_ANN - 0.006), r1 * np.cos(a), r1 * np.sin(a)])])
        tris = []
        for i in range(12):
            tris += [(i, 13 + i, 13 + i + 1), (i, 13 + i + 1, i + 1)]
        sect.append((pts, np.asarray(tris)))
    p.append(kit.part("aft cream sectors", (0.78, 0.74, 0.62), *sect))
    port_c = _n(70.0) * 0.5 * (R_RING + R)
    p.append(kit.part("aft port", (0.03, 0.03, 0.03),
                      U.facing_aft(kit, kit.move(kit.disc(0.13, 0.0, n=20), (0, port_c[1], port_c[2])), X_ANN - 0.012)))
    p.append(kit.part("adapter ring (white rim)", (0.75, 0.75, 0.74),
                      kit.tube(R_RING + 0.03, R_RING - 0.01, X_AFT + 0.08, X_ANN + 0.01, n=72)))
    p.append(kit.part("ring inside (gold)", (0.55, 0.42, 0.18),
                      U.flip(U.cylinder_fine(R_RING - 0.012, X_AFT + 0.09, X_FLOOR, n=72, max_len=0.2, caps=False)),
                      smooth=True))
    p.append(kit.part("inner floor", (0.20, 0.20, 0.21),
                      U.refine(U.facing_aft(kit, kit.disc(R_RING - 0.01, 0.0, n=72), X_FLOOR), 0.35)))
    cyl = []
    for i in range(-3, 3):
        for j in range(-3, 3):
            y, z = 0.17 * i + 0.085, 0.17 * j + 0.085 - 0.10
            if abs(i + 0.5) + abs(j + 0.5) > 4.5 or (i, j) in ((-1, 0), (0, 0)):
                continue
            cyl.append(kit.move(kit.cylinder(0.055, -0.20, -0.002, n=12), (X_FLOOR, y, z)))
    p.append(kit.part("silver cylinders", (0.70, 0.70, 0.72), *cyl, smooth=True))
    p.append(kit.part("white box", (0.80, 0.80, 0.78), kit.box((0.12, 0.22, 0.16), (X_FLOOR - 0.06, 0.0, -0.10))))
    return dict(meta=dict(name="Intelsat 603 (Intelsat VI F-3, stowed, as STS-49 captured it)",
                          frame="HS-393: +X along the spin axis toward the forward (antenna) end, "
                                "+Y the omni mast's hinge side (the mast leans across toward -Y), +Z the "
                                "outline window's side; m; mid-drum (the stowed satellite's mass sits near it)",
                          source="simple shapes to the STS-49 photographs (9301572, 9257083, 9259496, "
                                 "9301420, s49-91-020/026/029) and the published 3.64 m drum",
                          norad=20523, mag_1000km=2.0),
                parts=U.refine_parts(p))
