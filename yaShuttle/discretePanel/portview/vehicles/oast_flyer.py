"""OAST-Flyer (Spartan 206, NORAD 23763), as STS-72 deployed and
retrieved it in January 1996: the Spartan service module with NASA's
Office of Aeronautics and Space Technology experiments -- REFLEX
(thermal-model samples), GADACS (GPS attitude determination: four GPS
antennas spread over the end), SELODE (laser-initiated ordnance), SPRE
(solar-cell samples) -- and the amateur-radio package, in copper-gold
Kapton blankets.

From STS072-726-051 (images.nasa.gov) and STS072-726-054 (eol.jsc.nasa.gov,
full resolution), the flyer just released, and the low-resolution frames
726-043...053 on the arm:

* +Y: the grapple fixture on its round white plate, a little toward +Z,
  and beside it toward -Z the "Spartan" plate, its long side along X and
  its lettering reading from +X to -X (726-051, -054).
* +Z: the louvred radiator -- four bays stacked along X -- over the -Y
  half; on the +Y half two square mirror-finish sample panels one above
  the other along X, a white instrument box lying across between them,
  the round mission sticker at the +X/+Y corner (726-051, -054).
* +X: the experiment section, ~0.45 m deep -- blanketed boxes of several
  sizes with gaps between, a silver cylinder in an open box near the +Z
  edge, and at the four corners the round white GPS antennas, all facing
  +X (726-054).
* a gold-foil panel on the -X end at the +Z edge (726-051); the thruster
  clusters at the -Y face's corners.
The earlier model's leaning SPRE radiator and blue cell panel are not in
the photographs and are gone.  Not seen: the -Z face and -X end."""
import numpy as np

from . import _leo_spartan as S
from . import _leo_util as U

KEY = 'oast_flyer'

MIRROR = (0.72, 0.74, 0.78)
X1 = S.BX + 0.45                 # the experiment section's outer end


def build(kit):
    bx, by, bz = S.BX, S.BY, S.BZ
    logo = ((0.0, by + 0.009, -0.32), (0, 1, 0), (-1, 0, 0), 0.60, 0.30)
    p = S.bus_parts(kit, logo=logo, grapple_z=0.10, x1=bx)
    # +Z, the +Y half: the mirror sample panels, the white box, the sticker
    mir = [kit.box((0.26, 0.26, 0.012), (-0.26, 0.31, bz + 0.011)), kit.box((0.26, 0.26, 0.012), (0.20, 0.27, bz + 0.011))]
    p.append(kit.part("mirror sample panels (REFLEX/SPRE)", MIRROR, *mir))
    p.append(U.tpart(kit, "experiment box (white)", (0.82, 0.82, 0.80), kit.box((0.13, 0.44, 0.09), (-0.03, 0.30, bz + 0.05)),
                     U.tex_panels(1, 3, seed=206, spread=0.08), tile=0.3))
    p.append(S.quad(kit, "mission sticker", (0.95, 0.95, 0.95), S.tex_patch(seed=72), (0.40, 0.49, bz + 0.009),
                    (0, 0, 1), (1, 0, 0), 0.17, 0.17))
    p.append(kit.part("gold foil panel", (0.80, 0.66, 0.22), kit.box((0.05, 0.36, 0.16), (-bx - 0.02, -0.12, bz - 0.10))))
    # +X: the experiment deck and its boxes
    p.append(kit.part("experiment deck (dark blanket)", (0.30, 0.17, 0.07),
                      U.refine(kit.box((0.02, 2 * by - 0.04, 2 * bz - 0.04), (bx + 0.015, 0, 0)), 0.4)))
    boxes = [kit.box((0.36, 0.50, 0.42), (bx + 0.21, -0.30, 0.20)), kit.box((0.36, 0.46, 0.40), (bx + 0.21, 0.30, -0.26)),
             kit.box((0.26, 0.32, 0.30), (bx + 0.16, 0.34, 0.30)), kit.box((0.30, 0.36, 0.30), (bx + 0.18, -0.34, -0.30))]
    p.append(U.tpart(kit, "experiments (copper Kapton)", S.KAPTON, kit.merge(*boxes), U.tex_mli(131, seams=1, depth=0.6),
                     tile=0.45))
    p.append(kit.part("SELODE box (open)", (0.55, 0.55, 0.57), kit.box((0.22, 0.20, 0.03), (bx + 0.14, 0.06, bz - 0.06)),
                      kit.box((0.22, 0.03, 0.16), (bx + 0.14, 0.17, bz - 0.15)), kit.box((0.22, 0.03, 0.16), (bx + 0.14, -0.05, bz - 0.15))))
    p.append(kit.part("silver cylinder", (0.78, 0.78, 0.80),
                      kit.along(kit.cylinder(0.06, 0.0, 0.18, n=16), (1, 0, 0), (bx + 0.05, 0.06, bz - 0.15)), smooth=True))
    # GADACS: the four GPS antennas at the corners, facing +X, on posts
    posts, ant, ant_face = [], [], []
    for y in (-by + 0.12, by - 0.12):
        for z in (-bz + 0.12, bz - 0.12):
            posts.append(kit.rod((bx + 0.02, y, z), (X1 - 0.03, y, z), 0.025, n=8))
            ant.append(kit.along(kit.cylinder(0.10, 0.0, 0.03, n=24), (1, 0, 0), (X1 - 0.03, y, z)))
            ant_face.append(kit.along(kit.disc(0.06, 0.0, n=16), (1, 0, 0), (X1 + 0.005, y, z)))
    p.append(kit.part("GPS antenna posts", (0.55, 0.55, 0.57), *posts))
    p.append(kit.part("GPS antennas (white)", (0.85, 0.85, 0.83), *ant))
    p.append(kit.part("GPS antenna elements", (0.45, 0.45, 0.48), *ant_face))
    return dict(meta=S.bus_meta("OAST-Flyer (Spartan 206, STS-72)", 23763,
                                "simple shapes to the STS-72 photographs (STS072-726-051, -054; "
                                "726-043...053) and the Spartan press-kit section (42 x 48 in)"),
                parts=U.refine_parts(p))
