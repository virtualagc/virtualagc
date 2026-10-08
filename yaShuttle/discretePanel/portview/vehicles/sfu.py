"""The Space Flyer Unit (NORAD 23521), as STS-72 retrieved it in January
1996: launched by Japan's H-II in March 1995, it had flown ten months; its
two solar array paddles (24.4 m tip to tip) failed to latch after
retraction and were jettisoned, canisters and all, before capture, so
Endeavour's arm took a bare octagon.

SFU: an octagonal aluminium truss 4.46 m across, ~2.0 m deep, its eight
trapezoid bays holding the payload units; gold blanket over all, silver
and white radiators and small blue cell panels in the side bays; the end
facing the Sun (+X here) eight triangular sectors (white and silver) round
a gold central disc; experiment packages stand off the other end.  Four
trunnion pins stand out radially at the ends.  Proportions from
sts072-720-042/076 and STS072-734-011; diameter JAXA's SFU pages.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'sfu'

N = 8
APOTHEM = 2.06                 # 4.46 m across the corners
X0, X1 = -1.0, 1.0
GOLD = (0.60, 0.40, 0.12)
WHITE = (0.80, 0.80, 0.78)
SILVER = (0.45, 0.47, 0.50)


def build(kit):
    p = []
    body = U.ngon_prism(kit, N, APOTHEM, X0, X1, phase_deg=0.0, fine=0.4)
    p.append(U.tpart(kit, "truss bays (gold blanket)", GOLD, body, U.tex_mli(41, seams=2, depth=0.45), tile=1.4))
    faces = U.ngon_face_frames(N, APOTHEM, 0.0)
    side = 2 * APOTHEM * math.tan(math.pi / N)
    # side-bay panels: radiators and cell panels, 5 mm proud
    kinds = ("silver", "cells", "white", "silver", "cells", "white", "silver", "gold")
    mesh = {"silver": [], "cells": [], "white": []}
    for k, (n, c) in enumerate(faces):
        kind = kinds[k]
        if kind == "gold":
            continue
        R = U.frame_from(n, (1, 0, 0))            # x out, z along +X
        for xm, h in ((-0.45, 0.8), (0.45, 0.8)) if kind != "white" else ((0.0, 1.5),):
            m = kit.box((0.02, side * 0.62, h), (0.015, 0, 0))
            mesh[kind].append(kit.move(kit.turn(m, R), c + (xm, 0, 0)))
    p.append(kit.part("radiators (silver)", SILVER, *mesh["silver"]))
    p.append(U.tpart(kit, "cell panels", (0.05, 0.08, 0.20), kit.merge(*mesh["cells"]), U.tex_cells(4, 8, line=0.4), tile=0.8))
    p.append(kit.part("radiators (white)", WHITE, *mesh["white"]))
    # the corner longerons and the end rings of the truss
    R_c = APOTHEM / math.cos(math.pi / N)
    lon = []
    for k in range(N):
        a = math.radians(360.0 * k / N) - math.pi / N
        c = np.array([0.0, R_c * math.cos(a), R_c * math.sin(a)])
        lon.append(kit.rod(c + (X0 - 0.03, 0, 0), c + (X1 + 0.03, 0, 0), 0.045, n=6))
    lon.append(U.ngon_prism(kit, N, APOTHEM + 0.02, X1 - 0.03, X1 + 0.03, caps=False))
    lon.append(U.ngon_prism(kit, N, APOTHEM + 0.02, X0 - 0.03, X0 + 0.03, caps=False))
    p.append(kit.part("truss (gold-anodised)", (0.55, 0.38, 0.12), *lon))
    # the +X end: eight triangular sectors, alternately white and silver,
    # round a gold central disc, with radial struts between
    sec = {"white": [], "silver": []}
    for k in range(N):
        a0 = math.radians(360.0 * k / N) - math.pi / N + 0.06
        a1 = math.radians(360.0 * (k + 1) / N) - math.pi / N - 0.06
        r0, r1 = 0.62, R_c - 0.12
        pts = [(r0 * math.cos(a0), r0 * math.sin(a0)), (r1 * math.cos(a0), r1 * math.sin(a0)),
               (r1 * math.cos(a1), r1 * math.sin(a1)), (r0 * math.cos(a1), r0 * math.sin(a1))]
        sec["white" if k % 2 == 0 else "silver"].append(kit.prism(pts, X1 + 0.005, X1 + 0.03))
    p.append(kit.part("end sectors (white)", WHITE, *sec["white"]))
    p.append(kit.part("end sectors (silver)", SILVER, *sec["silver"]))
    p.append(kit.part("central disc (gold)", GOLD, kit.cylinder(0.58, X1 + 0.005, X1 + 0.06, n=32)))
    struts = []
    for k in range(N):
        a = math.radians(360.0 * k / N) - math.pi / N
        struts.append(kit.rod((X1 + 0.04, 0.6 * math.cos(a), 0.6 * math.sin(a)),
                              (X1 + 0.04, (R_c - 0.05) * math.cos(a), (R_c - 0.05) * math.sin(a)), 0.035, n=6))
    p.append(kit.part("end struts", (0.55, 0.38, 0.12), *struts))
    # the -X end: experiment packages under gold and silver blankets, the
    # infrared telescope's (IRTS) sunshade, the EFFU exposed-facility plate
    pk = [kit.box((0.6, 1.4, 1.0), (X0 - 0.30, 0.6, -0.9)),
          kit.box((0.8, 0.9, 0.9), (X0 - 0.40, -0.9, 0.8)),
          kit.box((0.45, 1.6, 1.2), (X0 - 0.225, -0.2, 0.4))]
    p.append(U.tpart(kit, "experiment packages (gold)", GOLD, kit.merge(*pk), U.tex_mli(42, seams=1), tile=0.9))
    p.append(kit.part("IRTS sunshade", (0.70, 0.70, 0.72),
                      kit.along(kit.cylinder(0.30, 0.0, 0.70, n=24), (-1, 0, 0), (X0, 1.0, 0.7))), )
    p.append(kit.part("EFFU plate", (0.75, 0.75, 0.75), kit.box((0.05, 1.2, 0.8), (X0 - 0.86, -0.9, 0.8))))
    # trunnion pins out of the +-Z corners' faces at the ends (in the photos
    # they stand out of the rim, two each side)
    tr = []
    for x in (X0 + 0.05, X1 - 0.05):
        for sz in (-1, 1):
            tr.append(U.trunnion(kit, (x, 0.0, sz * (APOTHEM - 0.02)), (0, 0, sz), 0.35, 0.041))
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *tr))
    n, c = faces[1]
    for name, rgb, m in U.frgf(kit, c + n * 0.01 + (0.55, 0, 0), n, (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    # the paddle hinge brackets left on the +-Y faces after the jettison
    br = [kit.box((0.4, 0.25, 0.3), (0.0, sy * (APOTHEM + 0.125), 0.0)) for sy in (-1, 1)]
    p.append(kit.part("array jettison brackets", (0.50, 0.50, 0.50), *br))
    return dict(meta=dict(name="Space Flyer Unit (SFU), arrays jettisoned, as STS-72 retrieved it",
                          frame="SFU: +X along the octagon's axis toward its Sun-facing end, +Y and "
                                "-Y the array paddles' faces (jettisoned), +Z the trunnions' side; m; "
                                "the octagon's centre",
                          source="simple shapes to published dimensions (JAXA) and STS-72 photographs",
                          norad=23521, mag_1000km=2.0),
                parts=U.refine_parts(p))
