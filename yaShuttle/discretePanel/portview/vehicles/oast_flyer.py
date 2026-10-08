"""OAST-Flyer (Spartan 206, NORAD 23763), as STS-72 deployed and
retrieved it in January 1996: the Spartan carrier with NASA's Office of
Aeronautics and Space Technology experiment deck on its +X end -- REFLEX
(thermal-model samples), GADACS (GPS attitude determination: four patch
antennas on booms), SELODE (laser ordnance), SPRE (a solar-cell array
with its open radiators) -- and the amateur-radio package.  From
STS072-726-051 and STS072-320-014; see _leo_spartan."""
import numpy as np

from . import _leo_spartan as S
from . import _leo_util as U

KEY = 'oast_flyer'


def build(kit):
    p = S.copper_carrier(kit)
    deck = kit.box((0.06, 1.25, 1.25), (0.55, 0.0, 0.0))
    p.append(kit.part("experiment deck", (0.55, 0.55, 0.56), deck))
    boxes = [kit.box((0.45, 0.50, 0.40), (0.81, -0.30, 0.30)), kit.box((0.35, 0.40, 0.45), (0.76, 0.30, -0.30)),
             kit.box((0.30, 0.35, 0.30), (0.73, 0.35, 0.35))]
    p.append(U.tpart(kit, "experiments (copper blanket)", S.COPPER, kit.merge(*boxes), U.tex_mli(131, seams=1, depth=0.5), tile=0.6))
    cells = kit.box((0.02, 0.55, 0.90), (0.59, -0.33, -0.15))
    p.append(U.tpart(kit, "SPRE cells", (0.10, 0.14, 0.30), kit.move(cells, (0.0, 0.0, 0.0)),
                     U.tex_cells(3, 6, line=0.35), tile=(0.55, 0.9), axes=((0, 1, 0), (0, 0, 1))))
    # the cell panels stood on the deck's face, sideways out of it: as the
    # photo shows, a panel leaning out over the -Y side
    panel = kit.turn(kit.box((0.02, 0.45, 0.95), (0, 0, 0)), kit.rot('z', 35))
    p.append(U.tpart(kit, "SPRE radiator panel", (0.70, 0.72, 0.76), kit.move(panel, (0.80, -0.75, -0.05)),
                     U.tex_panels(1, 4, seed=132, line=0.4), tile=(0.45, 0.95), axes=((0, 1, 0), (0, 0, 1))))
    ant = []
    for y, z in ((-0.62, 0.62), (0.62, 0.62), (-0.62, -0.62), (0.62, -0.62)):
        a = np.array([0.58, y, z])
        b = a + np.array([0.0, np.sign(y) * 0.25, np.sign(z) * 0.25])
        ant.append(kit.rod(a, b, 0.012, n=6))
        ant.append(kit.along(kit.cylinder(0.06, 0.0, 0.02, n=12), (1, 0, 0), b))
    p.append(kit.part("GPS antennas (GADACS)", (0.80, 0.80, 0.78), *ant))
    return dict(meta=S.flyer_meta(kit, "OAST-Flyer (Spartan 206, STS-72)", 23763,
                                  source_extra="; the experiment deck simple shapes to STS-72 photographs"),
                parts=U.refine_parts(p))
