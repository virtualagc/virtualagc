"""The Earth Radiation Budget Satellite (NORAD 15354), as STS-41G released
it on 5 October 1984 -- after Sally Ride, at the arm's controls, shook its
solar panel free (a hinge, stiff with cold, held it), with both panels
out.  Challenger stood off while ERBS checked out, and it boosted itself to
610 km with its own thrusters.

ERBS (Ball Aerospace, 2,449 kg): a keel module, a base module and an
instrument module in gold blanket, ~3.6 m long, ~1.2 m wide, 1.6 m deep;
two solar panels ~3.8 x 2.5 m with their outboard corners cut off, stowed
flat against the long sides for launch (the 4.6 x 3.8 x 1.6 m envelope),
swung out at the keel to stand out either side, cells up; on top the ERBE
scanner and non-scanner instruments and SAGE II on its turntable; the
TDRS and omni antennas on short masts.  From s84-41265/41266 and NSSDC.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'erbs'

GOLD = (0.60, 0.42, 0.14)
WHITE = (0.80, 0.80, 0.78)

LX, LY, LZ = 3.6, 1.2, 1.6


def _panel(kit, side):
    """A panel, its hinge along X at the keel's edge on side +-Y, out along
    +-Y, cells toward +Z: the 3.8 x 2.5 m outline with the outer corners
    cut 0.6 m."""
    hy, hz = LY / 2, -LZ / 2 + 0.15
    w, d, c = 3.8, 2.5, 0.6
    # outline in (x, s) where s runs out from the hinge
    pts = [(-w / 2, 0.0), (w / 2, 0.0), (w / 2, d - c), (w / 2 - c, d), (-w / 2 + c, d), (-w / 2, d - c)]
    out = []
    for z0, z1, name in ((0.0, 0.03, "back"), (0.03, 0.036, "cells")):
        # a prism along Z built in (y, z) = (s, x) coords, then mapped
        sec = [(s, x) for x, s in pts]
        m = kit.prism(sec, z0, z1)                        # along X: thickness; section (y=s, z=x)
        P, T = m
        P = np.column_stack([P[:, 2], side * (hy + 0.05 + P[:, 1]), hz + P[:, 0]])
        if side < 0:
            T = T[:, ::-1]
        out.append((name, (P, T)))
    return out


def build(kit):
    p = []
    body = kit.box((LX, LY, LZ))
    p.append(U.tpart(kit, "modules (gold blanket)", GOLD, body, U.tex_mli(151, seams=2, depth=0.5), tile=1.2, fine=0.4))
    keel = U.refine(kit.box((LX + 0.1, LY + 0.1, 0.25), (0.0, 0.0, -LZ / 2 + 0.10)), 0.4)
    p.append(kit.part("keel module structure", (0.55, 0.55, 0.56), keel))
    cells, backs = [], []
    for side in (-1, 1):
        for name, m in _panel(kit, side):
            (cells if name == "cells" else backs).append(m)
    p.append(U.tpart(kit, "solar cells", (0.05, 0.08, 0.22), kit.merge(*cells), U.tex_cells(12, 8, line=0.5),
                     tile=(3.8, 2.5), axes=((1, 0, 0), (0, 1, 0)), fine=0.4))
    p.append(kit.part("panel substrate", (0.60, 0.52, 0.30), U.refine(kit.merge(*backs), 0.4)))
    hinges = [kit.rod((x, s * (LY / 2), -LZ / 2 + 0.15), (x, s * (LY / 2 + 0.06), -LZ / 2 + 0.15), 0.04, n=6)
              for s in (-1, 1) for x in (-1.4, 0.0, 1.4)]
    p.append(kit.part("hinges", (0.65, 0.65, 0.66), *hinges))
    # the instruments on top: the ERBE scanner (three telescopes on a
    # rotating head), the non-scanner's box with its apertures, SAGE II
    top = LZ / 2
    p.append(U.tpart(kit, "instrument module (white)", WHITE, kit.box((1.3, 1.0, 0.45), (0.9, 0.0, top + 0.225)),
                     U.tex_panels(2, 2, seed=152), tile=0.8))
    p.append(kit.part("ERBE scanner head", (0.70, 0.70, 0.72),
                      kit.along(kit.cylinder(0.22, 0.0, 0.35, n=20), (0, 0, 1), (1.2, -0.2, top + 0.45))))
    p.append(kit.part("ERBE non-scanner", (0.75, 0.75, 0.73), kit.box((0.45, 0.45, 0.35), (-0.6, 0.0, top + 0.175))))
    ap = [kit.along(kit.disc(0.06, 0.0, n=12), (0, 0, 1), (-0.6 + dx, dy, top + 0.355)) for dx, dy in ((-0.1, -0.1), (0.1, 0.1), (0.1, -0.1))]
    p.append(kit.part("apertures", (0.03, 0.03, 0.03), *ap))
    p.append(kit.part("SAGE II", (0.65, 0.65, 0.66),
                      kit.along(kit.cylinder(0.15, 0.0, 0.25, n=16), (0, 0, 1), (0.5, 0.3, top + 0.45)),
                      kit.box((0.25, 0.30, 0.20), (0.5, 0.3, top + 0.80))))
    # antennas: the TDRS antenna mast and an omni at each end
    ant = [kit.rod((-1.6, 0.0, top), (-1.6, 0.0, top + 0.8), 0.03, n=6),
           kit.rod((1.75, 0.0, -0.2), (2.15, 0.0, -0.2), 0.03, n=6)]
    p.append(kit.part("antenna masts", (0.80, 0.80, 0.80), *ant))
    p.append(kit.part("antennas", (0.85, 0.85, 0.85), kit.along(kit.frustum(0.05, 0.25, 0.0, 0.12, n=16), (0, 0, 1), (-1.6, 0.0, top + 0.8)),
                      kit.sphere(0.07, n=8, centre=(2.2, 0.0, -0.2))))
    for name, rgb, m in U.frgf(kit, (-0.6, LY / 2 + 0.005, 0.2), (0, 1, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="Earth Radiation Budget Satellite (STS-41G)",
                          frame="ERBS: +X along the body (the instrument module's end), +Y and -Y "
                                "the solar panels' sides, +Z the instruments' (zenith) side, the "
                                "keel -Z; m; the body's centre",
                          source="simple shapes to published dimensions and the KSC processing photographs",
                          norad=15354, mag_1000km=2.5),
                parts=U.refine_parts(p))
