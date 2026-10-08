"""The Infrared Background Signature Survey on SPAS-II (NORAD 21244), as
STS-39 flew it in April-May 1991: released from the arm, it watched
Discovery's thruster plumes, the Earth's limb and the chemical-release
canisters from up to ~10 km while the orbiter manoeuvred round it, and was
recaptured.

SPAS-II (MBB, for the SDIO): a long blanketed carrier box across the
payload bay (~4.4 m, Y) ~1.3 m along it (X) and ~0.85 m deep, with blue
solar-cell/radiator patches on its faces; under it a V of struts to the
keel pin; on top, IBSS's cryogenic infrared sensor (the big white dewar,
~1.6 m across, lying along X) and, at the -Y end, the ultraviolet/visible
imager's small tubes on their box.  The grapple fixture on top at +Y.
Proportions from s39-15-017, s39-17-017, s39-19-015 and the preflight
s91-27781.
"""
import numpy as np

from . import _leo_util as U

KEY = 'ibss'

WHITE = (0.78, 0.77, 0.73)
BLUE = (0.06, 0.09, 0.26)
STRUT = (0.78, 0.78, 0.76)

DX, DY, DZ = 1.3, 4.4, 0.85


def build(kit):
    hx, hy, hz = DX / 2, DY / 2, DZ / 2
    p = []
    box = kit.box((DX, DY, DZ))
    p.append(U.tpart(kit, "carrier blankets", WHITE, box, U.tex_mli(101, seams=3, depth=0.35), tile=1.4, fine=0.4))
    # the box's bays show as raised blanket panels on +-X
    bays = [kit.box((0.04, 0.95, 0.70), (s * (hx + 0.02), y, 0.0)) for s in (-1, 1) for y in (-1.6, -0.55, 1.05, 1.75)]
    p.append(U.tpart(kit, "bay blankets", WHITE, kit.merge(*bays), U.tex_mli(102, seams=1, depth=0.45), tile=0.9))
    blue = [kit.box((0.02, 0.33, 0.20), (hx + 0.052, y, z)) for y, z in ((-0.95, 0.12), (-0.62, 0.12), (0.25, 0.20),
                                                                          (0.25, -0.12), (0.58, 0.20), (0.58, -0.12))]
    blue += [kit.box((0.25, 0.60, 0.02), (0.30, -1.05, hz + 0.012))]
    p.append(U.tpart(kit, "solar cells / radiators (blue)", BLUE, kit.merge(*blue), U.tex_cells(4, 3, line=0.3),
                     tile=0.33))
    # IBSS's dewar on top: a big white cylinder lying along X
    dew = kit.along(kit.cylinder(0.80, 0.0, 1.55, n=40), (1, 0, 0), (-0.85, 0.35, hz + 0.82))
    p.append(U.tpart(kit, "IBSS dewar (white blankets)", WHITE, dew, U.tex_mli(103, seams=2, depth=0.4), tile=1.0))
    p.append(kit.part("dewar ends", (0.70, 0.70, 0.70),
                      kit.along(kit.disc(0.70, 0.0, n=40), (1, 0, 0), (0.705, 0.35, hz + 0.82))))
    p.append(kit.part("sensor aperture", (0.03, 0.03, 0.03),
                      kit.along(kit.disc(0.30, 0.0, n=24), (1, 0, 0), (0.71, 0.35, hz + 0.95))))
    p.append(kit.part("dewar cradle", STRUT, kit.box((1.2, 1.1, 0.10), (0.0, 0.35, hz + 0.05))))
    # the UV/visible imagers at -Y: a blue box and two small tubes on it
    p.append(U.tpart(kit, "imager box", BLUE, kit.box((0.50, 0.70, 0.30), (-0.1, -1.55, hz + 0.15)),
                     U.tex_cells(4, 4, line=0.3), tile=0.35))
    tubes = [kit.along(kit.cylinder(0.14, 0.0, 0.85, n=16), (0, 1, 0), (-0.1, -1.95, hz + 0.45)),
             kit.along(kit.cylinder(0.10, 0.0, 0.50, n=16), (1, 0, 0), (-0.40, -1.25, hz + 0.40))]
    p.append(kit.part("imager tubes", WHITE, *tubes, smooth=False))
    # the keel V and its cross strut, the keel pin; longeron trunnions
    apex = np.array([0.0, 0.1, -hz - 1.65])
    legs = [kit.rod((0.0, -1.2, -hz), apex, 0.05, n=8), kit.rod((0.0, 1.3, -hz), apex, 0.05, n=8),
            kit.rod((0.0, -0.75, -hz - 0.6), (0.0, 0.95, -hz - 0.6), 0.035, n=6)]
    p.append(kit.part("keel struts", STRUT, *legs))
    tr = [U.trunnion(kit, apex, (0, 0, -1), 0.20, 0.05)]
    tr += [U.trunnion(kit, (0.0, s * (hy + 0.01), 0.0), (0, s, 0), 0.28, 0.041) for s in (-1, 1)]
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *tr))
    for name, rgb, m in U.frgf(kit, (0.0, 1.55, hz + 0.01), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="IBSS on SPAS-II (STS-39)",
                          frame="SPAS-II: +X along the payload bay when berthed (the dewar's "
                                "aperture end), +Y across it (between the longeron trunnions), +Z "
                                "up (the instruments' side; the keel V below); m; the carrier box's "
                                "centre, 0.2 m below the whole's centre of mass (the dewar sits on top)",
                          source="simple shapes to the STS-39 photographs, scaled to the payload bay",
                          norad=21244, mag_1000km=2.5),
                parts=U.refine_parts(p))
