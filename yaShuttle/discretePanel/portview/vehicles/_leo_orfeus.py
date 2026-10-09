"""ORFEUS-SPAS: the ASTRO-SPAS carrier with the Orbiting and Retrievable
Far and Extreme Ultraviolet Spectrometers' 1 m telescope standing through
it (its tube ~1.3 m across, 4.0 m long, 1.7 m of it above the carrier on
the side away from the keel), and the Interstellar Medium Absorption
Profile Spectrograph (IMAPS) in its silver-blanketed tube up the +X face.
Flown free for days beside the Shuttle on STS-51 (1993) and STS-80
(1996)."""
import numpy as np

from . import _leo_astrospas as A
from . import _leo_util as U


def parts(kit):
    p = A.carrier(kit)
    hz = A.DZ / 2
    tube = kit.along(U.cylinder_fine(0.65, 0.0, 4.0, n=40, max_len=0.4, caps=False), (0, 0, 1), (0.0, -0.2, -hz - 0.6))
    p.append(U.tpart(kit, "ORFEUS telescope (beige blanket)", A.BEIGE, tube, U.tex_mli(64, seams=2, depth=0.35),
                     cyl=None, tile=1.2))
    top = np.array([0.0, -0.2, hz + 1.7])
    p.append(kit.part("telescope door and rim", (0.25, 0.25, 0.26),
                      kit.along(kit.disc(0.66, 0.0, n=40), (0, 0, 1), top),
                      kit.along(kit.disc(0.66, 0.0, n=40), (0, 0, -1), (0.0, -0.2, -hz - 0.6))))
    p.append(kit.part("sunshade lip", (0.60, 0.60, 0.62),
                      kit.along(kit.tube(0.70, 0.64, 0.0, 0.08, n=40), (0, 0, 1), top - (0, 0, 0.04))))
    # the black vent holes the blankets show
    holes = [kit.along(kit.disc(0.08, 0.0, n=12), (1, 0, 0), (0.655, -0.2, z)) for z in (hz + 0.6, -hz - 0.25)]
    p.append(kit.part("vents", (0.02, 0.02, 0.02), *holes))
    imaps = kit.along(U.cylinder_fine(0.28, 0.0, 3.2, n=20, max_len=0.4), (0, 0, 1), (A.DX / 2 + 0.33, 1.0, -1.6))
    p.append(U.tpart(kit, "IMAPS (silver blanket)", A.SILVER, imaps, U.tex_mli(65, seams=2, depth=0.5), tile=0.8))
    return p


def module(kit, flight, mission, norad):
    return dict(meta=dict(name="ORFEUS-SPAS %s (%s)" % ("I" * flight, mission),
                          frame="ASTRO-SPAS: +X along the payload bay when berthed (the grapple "
                                "fixture's face), +Y across it (between the longeron trunnions), +Z "
                                "the telescope's aperture (away from the keel tripod); m; the "
                                "carrier box's centre (the telescope's mass sits near it)",
                          source="simple shapes to the STS-51/STS-80 photographs, scaled to the bay",
                          norad=norad, mag_1000km=2.5),
                parts=U.refine_parts(parts(kit)))
