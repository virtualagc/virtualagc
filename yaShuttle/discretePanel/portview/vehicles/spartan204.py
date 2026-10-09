"""Spartan 204 (NORAD 23470), as STS-63 deployed and retrieved it in
February 1995 (the flight that also made the near-rendezvous with Mir):
the Spartan service module in copper-gold Kapton blankets carrying NRL's
Far Ultraviolet Imaging Spectrograph on its +X end.  After retrieval it was
unberthed again on the arm for EVA mass-handling practice.

From the STS-63 Hasselblad roll 716, frames 44-77 (eol.jsc.nasa.gov;
sts063-716-064 also on images.nasa.gov), taken as Discovery backed away:

* The whole flyer is nearly a cube (716-055, -066, -072), not the carrier
  with a long box on its end: the instrument sits in an open, copper-
  blanketed end frame ~0.3 m deep on the +X face, whose dominant feature is
  a big copper-wrapped ring ~0.55 m across (the spectrograph's aperture
  baffle), set back in the frame a little above the middle, a blanketed
  block beside it toward -Y/-Z, and a black rail along the -Y edge.
* +Y: the grapple fixture on its round white plate at the middle of the
  face (716-064/066/072).
* +Z: the "Spartan / Goddard Space Flight Center" plate on the +Y half,
  long side along X, and the louvred radiator -- four bays of silver vanes
  in copper frames -- over the -Y half (716-055/066/072).
* the cold-gas thrusters: clusters of nozzles on short booms at the corners
  of the -Y face (716-055/066).
Proportions: the 42 x 48 in section from the Spartan press-kit figures
(see _leo_spartan); the end frame's depth and the ring's size measured off
716-066 against the 1.07 m face.  Not seen: the -X end and the -Z face
(drawn plain blanket, the -Z radiator as on +Z)."""
import numpy as np

from . import _leo_spartan as S
from . import _leo_util as U

KEY = 'spartan204'

X1 = S.BX + 0.30             # the instrument frame's open end


def build(kit):
    bx, by, bz = S.BX, S.BY, S.BZ
    logo = ((-0.02, 0.33, bz + 0.009), (0, 0, 1), (1, 0, 0), 0.62, 0.32)
    p = S.bus_parts(kit, logo=logo, x1=bx)
    # the +X end frame: four blanketed walls, open at +X, the bus's face its floor
    L, w = X1 - bx, 0.04
    xc = (bx + X1) / 2 + 0.005
    walls = [kit.box((L, 2 * by, w), (xc, 0, bz - w / 2)), kit.box((L, 2 * by, w), (xc, 0, -bz + w / 2)),
             kit.box((L, w, 2 * bz - 2 * w), (xc, by - w / 2, 0)),
             kit.box((L, w, 2 * bz - 2 * w), (xc, -by + w / 2, 0))]
    p.append(U.tpart(kit, "instrument frame (copper Kapton)", S.KAPTON, kit.merge(*walls),
                     U.tex_mli(204, seams=1, depth=0.6), tile=0.5, fine=0.35))
    # the aperture ring and what shows inside it
    rc = np.array([0.0, 0.10, 0.04])
    ring = kit.move(kit.tube(0.28, 0.23, bx + 0.02, X1 - 0.03, n=40), rc)
    p.append(U.tpart(kit, "FUV aperture baffle (copper wrap)", (0.66, 0.40, 0.16), ring,
                     U.tex_mli(205, seams=0, depth=0.5), cyl=(0.3, 3)))
    p.append(kit.part("aperture (dark)", (0.03, 0.03, 0.035), kit.move(kit.disc(0.23, bx + 0.03, n=40), rc)))
    blk = kit.box((0.22, 0.34, 0.30), (bx + 0.12, -0.33, -0.28))
    p.append(U.tpart(kit, "instrument electronics (copper blanket)", S.KAPTON, blk,
                     U.tex_mli(206, seams=1, depth=0.6), tile=0.4))
    p.append(kit.part("frame floor (dark)", (0.10, 0.07, 0.04),
                      U.refine(kit.box((0.01, 2 * by - 0.1, 2 * bz - 0.1), (bx + 0.012, 0, 0)), 0.4)))
    p.append(kit.part("black rail", (0.04, 0.04, 0.045), kit.box((0.06, 0.05, 2 * bz - 0.1), (X1 - 0.05, -by - 0.03, 0))))
    p.append(kit.part("sun sensor", (0.80, 0.80, 0.78), kit.box((0.08, 0.10, 0.10), (X1 - 0.05, by - 0.12, bz - 0.12))))
    return dict(meta=S.bus_meta("Spartan 204 (STS-63)", 23470,
                                "simple shapes to the STS-63 photographs (STS063-716-055/060/066/072, "
                                "sts063-716-064) and the Spartan press-kit section (42 x 48 in)"),
                parts=U.refine_parts(p))
