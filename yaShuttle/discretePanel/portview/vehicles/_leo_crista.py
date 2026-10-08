"""CRISTA-SPAS: the ASTRO-SPAS carrier with the Cryogenic Infrared
Spectrometers and Telescopes for the Atmosphere (its helium dewar a 1.25 m
cylinder standing 1.1 m off the carrier's face away from the keel, the
three telescopes looking out of the -X side) and the Middle Atmosphere High
Resolution Spectrograph Investigation (MAHRSI) in its tube up the +X face
near -Y.  Flown free on STS-66 (1994) and STS-85 (1997)."""
import numpy as np

from . import _leo_astrospas as A
from . import _leo_util as U


def parts(kit):
    p = A.carrier(kit)
    hx, hz = A.DX / 2, A.DZ / 2
    dew = kit.along(U.cylinder_fine(0.62, 0.0, 1.1 + A.DZ, n=40, max_len=0.4), (0, 0, 1), (0.0, 0.0, -hz))
    p.append(U.tpart(kit, "CRISTA dewar (beige blanket)", A.BEIGE, dew, U.tex_mli(66, seams=2, depth=0.35), tile=1.0))
    p.append(kit.part("dewar end", (0.70, 0.70, 0.70),
                      kit.along(kit.disc(0.55, 0.0, n=40), (0, 0, 1), (0.0, 0.0, hz + 1.105))))
    # the telescopes' baffles out of the -X side (three, one above another)
    tel = [kit.box((0.55, 0.45, 0.35), (-hx - 0.27, y, z)) for y, z in ((-0.6, 0.35), (0.0, 0.35), (0.6, 0.35))]
    p.append(U.tpart(kit, "CRISTA telescopes (beige)", A.BEIGE, kit.merge(*tel), U.tex_mli(67, seams=1), tile=0.6))
    ap = [kit.along(kit.disc(0.12, 0.0, n=16), (-1, 0, 0), (-hx - 0.55, y, 0.35)) for y in (-0.6, 0.0, 0.6)]
    p.append(kit.part("telescope apertures", (0.03, 0.03, 0.03), *ap))
    mah = kit.along(kit.cylinder(0.30, 0.0, 2.1, n=20), (0, 0, 1), (hx + 0.35, -1.0, -hz - 0.1))
    p.append(U.tpart(kit, "MAHRSI (beige)", A.BEIGE, mah, U.tex_mli(68, seams=2), tile=0.7))
    holes = [kit.along(kit.disc(0.07, 0.0, n=12), (1, 0, 0), (0.625, 0.0, z)) for z in (hz + 0.3, hz + 0.7)]
    p.append(kit.part("vents", (0.02, 0.02, 0.02), *holes))
    return p


def module(kit, flight, mission, norad):
    return dict(meta=dict(name="CRISTA-SPAS %s (%s)" % ("I" * flight, mission),
                          frame="ASTRO-SPAS: +X along the payload bay when berthed (the grapple "
                                "fixture's face), +Y across it (between the longeron trunnions), +Z "
                                "away from the keel tripod (the dewar's end); m; the carrier box's centre",
                          source="simple shapes to the STS-66/STS-85 photographs, scaled to the bay",
                          norad=norad, mag_1000km=2.5),
                parts=U.refine_parts(parts(kit)))
