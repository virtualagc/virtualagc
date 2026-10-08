"""The Plasma Diagnostics Package (NORAD 15929), University of Iowa, as it
flew free on STS-51F (Spacelab 2, July-August 1985): released from the arm,
it was circled by Challenger for some six hours (passing through the
orbiter's wake and plasma) and caught again.  (It had flown on STS-3 too,
only on the arm.)

PDP: a squat drum ~1.06 m across and ~0.65 m long (360 kg), white-
blanketed, its end faces grey with the instrument boxes; two electric-
field booms (~1.9 m) straight out either side tipped with small spheres,
and a ring of short probe stubs round the drum; the grapple fixture on
the -X face.  Proportions from 51F-33-024 and 51F-34-041.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'pdp'

R, L = 0.53, 0.65
WHITE = (0.78, 0.78, 0.76)


def build(kit):
    p = []
    drum = kit.cylinder(R, -L / 2, L / 2, n=36, caps=False)
    p.append(U.tpart(kit, "drum (white blanket)", WHITE, drum, U.tex_mli(111, seams=2, depth=0.35),
                     cyl=(0.65, 3), smooth=True))
    p.append(kit.part("drum rims", (0.55, 0.55, 0.56),
                      kit.tube(R + 0.015, R - 0.04, L / 2 - 0.03, L / 2 + 0.02, n=36),
                      kit.tube(R + 0.015, R - 0.04, -L / 2 - 0.02, -L / 2 + 0.03, n=36)))
    p.append(kit.part("end faces", (0.40, 0.40, 0.42), kit.disc(R - 0.01, L / 2 - 0.01, n=36),
                      U.facing_aft(kit, kit.disc(R - 0.01, 0.0, n=36), -L / 2 + 0.01)))
    p.append(kit.part("instrument box (gold)", (0.60, 0.42, 0.14), kit.box((0.10, 0.22, 0.18), (L / 2 + 0.04, 0.0, 0.0))))
    # the two long electric-field booms and their spheres
    booms, tips = [], []
    for s in (-1, 1):
        a = np.array([0.0, s * R, 0.0])
        b = np.array([0.0, s * (R + 1.9), 0.0])
        booms.append(kit.rod(a, b, 0.012, n=6))
        tips.append(kit.sphere(0.04, n=8, centre=b))
    # the short probe stubs round the drum
    for k in range(6):
        t = math.radians(30 + 60 * k)
        if abs(math.cos(t)) > 0.99:
            continue
        d = np.array([0.0, math.cos(t), math.sin(t)])
        booms.append(kit.rod(d * R + (0.15, 0, 0), d * (R + 0.40) + (0.15, 0, 0), 0.012, n=6))
        tips.append(kit.along(kit.cylinder(0.025, 0.0, 0.10, n=8), d, d * (R + 0.40) + (0.15, 0, 0)))
    p.append(kit.part("booms", (0.70, 0.70, 0.70), *booms))
    p.append(kit.part("probe tips", (0.60, 0.50, 0.25), *tips))
    for name, rgb, m in U.frgf(kit, (-L / 2 - 0.01, 0.0, 0.0), (-1, 0, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="Plasma Diagnostics Package (STS-51F)",
                          frame="PDP: +X along the drum's axis away from the grapple fixture, +Y "
                                "along the long booms, +Z; m; the drum's centre",
                          source="simple shapes to published dimensions and STS-51F photographs",
                          norad=15929, mag_1000km=5.0),
                parts=U.refine_parts(p))
