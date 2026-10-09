"""Spartan 101 (Spartan-1, NORAD 15831), as STS-51G deployed and
retrieved it in June 1985: the first Spartan, the NRL's X-ray astronomy
payload (two large proportional counters behind collimators, mapping the
Perseus cluster, the galactic centre and Scorpius X-2).

The STS-51G press kit: "a rectangular structure, 126 by 42 by 48 in.;
weight 2,223 lb" -- 3.20 x 1.07 x 1.22 m, a long white box, not the later
Spartans' near-cube.  The photographs (Hasselblad rolls 35-37 at
eol.jsc.nasa.gov, full resolution; 51g-035-053 on images.nasa.gov):

* STS51G-35-54/53 (in the bay, the arm coming down): the 42 x 48 in end
  facing forward is a white-rimmed opening ~0.08 m in from the edges onto a
  deep black interior; inside, across the upper (+Y) half, a light sheet
  with the "Spartan / Goddard Space Flight Center" logo, below it black
  depth.  The long +Y face, white blankets, carries the 51-G mission patch.
* STS51G-35-57, -64; 36-77, -80, -82 (on the arm and free): the box
  2.6 times as long as wide; the last ~0.6 m at the instrument (+X) end
  black on the outside, its end face open, and through the opening the
  Earth or sky shows -- the black end section is open on its -Y side too;
  two black posts stand out of +Z at that end, with a light fin and a
  green sun-sensor window (36-77); a white plate with red caps on -Z just
  short of the black section (35-57, 36-77, 36-80).
* the grapple fixture on its white plate on +Y at 16% of the length from
  the -X end -- the service module's middle, 0.5 m from that end -- with a
  white box and a handrail beside it; the oval mission patch on +Y ~1.1 m
  from the black end; thruster nozzles on short booms at the service
  module's -Y corners (36-77, -80).
The faces away from the Sun are dark in every frame (all taken looking
down, so no earthshine reaches them): their white is assumed.  No
radiator louvres show on +Y or +Z; none drawn.  The origin stays the
service module's centre, as for the other Spartans; the long instrument
section puts the true centre of mass ~0.6 m toward +X of it."""
import numpy as np

from . import _leo_spartan as S
from . import _leo_util as U

KEY = 'spartan101'

WHITE = (0.80, 0.80, 0.77)
BLACK = (0.04, 0.04, 0.045)
X_END = S.BX + 3.20 - 2 * S.BX           # 2.69: the 126 in from -X to the open end
X_COL = X_END - 0.60                     # where the black end section begins


def build(kit):
    bx, by, bz = S.BX, S.BY, S.BZ
    p = S.bus_parts(kit, blanket=WHITE, tex_seed=101, x1=X_COL, plus_x_face=False, radiator=False,
                    thruster_x=(-bx, bx))
    # the black end section: walls round an open end, the -Y wall cut by a
    # wide window; the back wall; the logo sheet across the +Y half inside
    L, w = X_END - X_COL, 0.03
    xc = (X_COL + X_END) / 2
    walls = [kit.box((L, 2 * by, w), (xc, 0, bz - w / 2)), kit.box((L, 2 * by, w), (xc, 0, -bz + w / 2)),
             kit.box((L, w, 2 * bz - 2 * w), (xc, by - w / 2, 0)),
             # -Y wall: a frame round a window 0.40 (X) x 0.70 (Z)
             kit.box((0.10, w, 2 * bz - 2 * w), (X_COL + 0.05, -by + w / 2, 0)),
             kit.box((0.10, w, 2 * bz - 2 * w), (X_END - 0.05, -by + w / 2, 0)),
             kit.box((L - 0.2, w, (2 * bz - 2 * w - 0.70) / 2), (xc, -by + w / 2, 0.35 + (2 * bz - 2 * w - 0.70) / 4)),
             kit.box((L - 0.2, w, (2 * bz - 2 * w - 0.70) / 2), (xc, -by + w / 2, -0.35 - (2 * bz - 2 * w - 0.70) / 4)),
             kit.box((0.02, 2 * by, 2 * bz), (X_COL + 0.01, 0, 0))]                    # the back wall
    p.append(U.tpart(kit, "end section (black)", BLACK, kit.merge(*walls), U.tex_panels(2, 2, seed=102, spread=0.2),
                     tile=0.6, fine=0.35))
    rim = [kit.box((0.02, 2 * by, 0.08), (X_END + 0.012, 0, bz - 0.04)), kit.box((0.02, 2 * by, 0.08), (X_END + 0.012, 0, -bz + 0.04)),
           kit.box((0.02, 0.08, 2 * bz - 0.16), (X_END + 0.012, by - 0.04, 0)),
           kit.box((0.02, 0.08, 2 * bz - 0.16), (X_END + 0.012, -by + 0.04, 0))]
    p.append(kit.part("end rim (white)", WHITE, *rim))
    p.append(S.quad(kit, "Spartan logo sheet", (0.55, 0.55, 0.53), S.tex_logo(), (X_COL + 0.30, 0.30, 0.0),
                    (1, 0, 0), (0, 0, -1), 2 * bz - 0.12, 2 * by * 0.40, thick=0.01))
    # +Z at the end: the two black posts, the light fin and its sun sensor
    p.append(kit.part("posts (black)", BLACK, kit.box((0.15, 0.15, 0.20), (X_END - 0.12, 0.40, bz + 0.105)),
                      kit.box((0.15, 0.15, 0.20), (X_END - 0.12, -0.28, bz + 0.105))))
    p.append(kit.part("fin", (0.70, 0.70, 0.70), kit.box((0.22, 0.02, 0.18), (X_COL + 0.15, by - 0.10, bz + 0.095))))
    p.append(kit.part("sun sensor window", (0.10, 0.45, 0.30),
                      kit.along(kit.disc(0.035, 0.0, n=12), (0, 1, 0), (X_COL + 0.15, by - 0.085, bz + 0.12))))
    # -Z, just short of the end section: the white plate with red caps
    p.append(kit.part("sensor plate", (0.82, 0.82, 0.80), kit.box((0.26, 0.26, 0.015), (X_COL - 0.20, 0.38, -bz - 0.0125))))
    p.append(kit.part("red covers", (0.70, 0.08, 0.06),
                      *[kit.along(kit.cylinder(0.035, 0.0, 0.05, n=12), (0, 0, -1), (X_COL - 0.20 + dx, 0.38 + dy, -bz - 0.015))
                        for dx, dy in ((-0.06, -0.06), (0.06, -0.05), (-0.04, 0.07))]))
    # +Y: the mission patch; beside the grapple fixture a white box and a handrail
    p.append(S.quad(kit, "51-G mission patch", (0.95, 0.95, 0.95), S.tex_patch(seed=51), (X_END - 1.10, by + 0.009, 0.12),
                    (0, 1, 0), (1, 0, 0), 0.22, 0.30))
    p.append(U.tpart(kit, "box by the grapple fixture", WHITE, kit.box((0.22, 0.16, 0.20), (0.40, by + 0.085, 0.32)),
                     U.tex_panels(1, 1, seed=103, spread=0.05), tile=0.3))
    p.append(kit.part("handrail", (0.78, 0.78, 0.76), kit.rod((0.30, by + 0.06, -0.35), (0.30, by + 0.06, -0.05), 0.012, n=6),
                      kit.rod((0.30, by + 0.005, -0.35), (0.30, by + 0.06, -0.35), 0.012, n=6),
                      kit.rod((0.30, by + 0.005, -0.05), (0.30, by + 0.06, -0.05), 0.012, n=6)))
    return dict(meta=S.bus_meta("Spartan 101 (Spartan-1, STS-51G)", 15831,
                                "simple shapes to the STS-51G press kit (126 x 42 x 48 in) and the 51-G "
                                "photographs (STS51G-35-53/54/57/64, 36-77/80/82)",
                                extra_frame=" (the true centre of mass ~0.6 m toward +X)"),
                parts=U.refine_parts(p))
