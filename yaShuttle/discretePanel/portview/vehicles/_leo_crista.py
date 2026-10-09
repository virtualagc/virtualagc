"""CRISTA-SPAS: the ASTRO-SPAS carrier (see _leo_astrospas) with the
Cryogenic Infrared Spectrometers and Telescopes for the Atmosphere and the
Middle Atmosphere High Resolution Spectrograph Investigation (MAHRSI).
Flown free on STS-66 (November 1994) and STS-85 (August 1997).

What the photographs show on the instrument side (+Z, away from the keel):
CRISTA's liquid-helium cryostat, a blanketed cylinder 1.36 m across standing
1.15 m out of the middle of the carrier, its end a lid with a raised ring;
on its +Y flank, near its end, the hood of the three telescopes (they look
out along +Y at the limb, 18 degrees apart: s85e5096, sts066-96-030,
sts066-129-043); MAHRSI, a white blanketed cylinder 0.6 m across, standing
up the +X face beside the DARA plate (s85e5096, KSC-97PC1005); blanketed
electronics boxes, a tall shroud and the turnstile-and-disc antenna toward
-Y (s85e5096, sts085-706-051).  STS-66's blankets photographed beige-gold
(sts066-129-043, sts066-96-030), STS-85's whiter, peppered with black vent
holes (s85e5096, KSC-97PC1005).  STS-85 also carried IPEX-II, a 2.35 m
nine-bay ADAM mast, 0.3 m square, cantilevered along the -X face
(sts085-706-051: its gold end seen square-on beside the -Y end)."""
import math

import numpy as np

from . import _leo_astrospas as A
from . import _leo_util as U

R_DEWAR = 0.68
H_DEWAR = 1.15                         # above the carrier's instrument face
MAHRSI_AT = (A.HX + 0.33, 1.05)


def parts(kit, flight):
    hx, hz = A.HX, A.HZ
    two = flight == 2
    finish = A.BEIGE if two else A.BEIGE_GOLD
    # the vent holes the photographs show on the bays, MAHRSI and the cryostat
    extra = []
    if two:
        extra = [((A.HX, -1.95, -0.25), (1, 0, 0)), ((A.HX, -1.15, 0.30), (1, 0, 0))]
    p = A.carrier(kit, finish=finish, end_bays={1: 'osr', -1: 'osr'} if two else {1: 'silver', -1: 'osr'},
                  logos=('NASA', 'DARA') if two else ('DARA', 'NASA-worm'),
                  contractor="Daimler-Benz Aerospace" if two else "Deutsche Aerospace",
                  osr_strip=two, logo_face=1, extra_dots=extra)

    # -- the cryostat ------------------------------------------------------
    top = hz + H_DEWAR
    # made along X so that it can be wrapped (cylinder-mapped), then stood up along +Z
    dew = U.cylinder_fine(R_DEWAR, hz - 0.15, top, n=40, max_len=0.35, caps=False)
    dew = U.tpart(kit, "CRISTA cryostat (blanket)", finish, dew, U.tex_mli(66, seams=3, depth=0.38),
                  cyl=(0.9, 4.0), smooth=True)
    p += kit.transform_parts([dew], kit.rot('y', -90))
    # its blanketed end: the lid, the raised ring, the vent fitting
    lid = [kit.along(kit.disc(R_DEWAR, 0.0, n=40), (0, 0, 1), (0, 0, top)),
           kit.along(kit.cylinder(0.50, 0.0, 0.06, n=40, caps=False), (0, 0, 1), (0, 0, top)),
           kit.along(kit.disc(0.50, 0.0, n=40), (0, 0, 1), (0, 0, top + 0.06))]
    p.append(U.tpart(kit, "cryostat lid", (0.80, 0.78, 0.72) if two else (0.78, 0.72, 0.58), kit.merge(*lid),
                     U.tex_mli(67, seams=1, depth=0.3), tile=0.7))
    p.append(kit.part("lid fitting", (0.62, 0.62, 0.64),
                      kit.along(kit.cylinder(0.11, 0.0, 0.07, n=16), (0, 0, 1), (0, 0, top + 0.06)),
                      kit.along(kit.cylinder(0.05, 0.0, 0.20, n=10), (0, 0, 1), (0, 0, top + 0.06))))
    # the telescopes' hood on the +Y flank, three black apertures out of it
    hood_c = np.array([0.0, R_DEWAR + 0.20, top - 0.40])
    hood = kit.box((0.92, 0.50, 0.52), hood_c)
    p.append(U.tpart(kit, "telescope hood (blanket)", finish, hood, U.tex_mli(68, seams=1, depth=0.45), tile=0.6))
    tubes, mouths = [], []
    for k, x in enumerate((-0.29, 0.0, 0.29)):
        d = np.array([math.sin(math.radians(18.0 * (k - 1))), 1.0, 0.0])
        d /= np.linalg.norm(d)
        base = hood_c + (x, 0.20, 0.02)
        tubes.append(kit.along(kit.tube(0.135, 0.115, 0.0, 0.26, n=20), d, base))
        mouths.append(kit.along(kit.disc(0.118, 0.0, n=20), d, base + 0.18 * d))
    p.append(kit.part("telescope baffles", finish, *tubes))
    p.append(kit.part("telescope apertures", (0.015, 0.015, 0.02), *mouths))

    # -- MAHRSI up the +X face --------------------------------------------
    mx, my = MAHRSI_AT
    mah = kit.along(U.cylinder_fine(0.30, 0.0, 1.32, n=24, max_len=0.4, caps=True), (0, 0, 1), (mx, my, -0.06))
    p.append(U.tpart(kit, "MAHRSI (white blanket)", (0.84, 0.82, 0.77) if two else finish, mah,
                     U.tex_mli(69, seams=2, depth=0.4), tile=0.7))
    p.append(kit.part("MAHRSI aperture", (0.02, 0.02, 0.02),
                      kit.along(kit.disc(0.17, 0.0, n=20), (0, 0, -1), (mx, my, -0.065))))

    # -- the -Y side of the instrument face: boxes, shroud, antenna ---------
    boxes = [kit.box((1.10, 0.85, 0.32), (-0.25, -1.40, hz + 0.16)),
             kit.box((0.55, 0.50, 0.40), (0.55, -0.95, hz + 0.20)),
             kit.box((0.34, 0.40, 1.05), (0.70, -1.62, hz + 0.525))]
    p.append(U.tpart(kit, "instrument boxes (blanket)", finish, kit.merge(*boxes), U.tex_mli(70, seams=1, depth=0.45), tile=0.6))
    ant = [kit.along(kit.cylinder(0.14, 0.0, 0.28, n=16), (0, 0, 1), (-0.45, -1.80, hz + 0.32))]
    p.append(kit.part("antenna mast", (0.20, 0.20, 0.22), *ant))
    p.append(kit.part("antenna disc", (0.70, 0.70, 0.72),
                      kit.along(kit.cylinder(0.28, 0.0, 0.015, n=32), (0, 0, 1), (-0.45, -1.80, hz + 0.60))))
    cross = [kit.rod((-0.45 + 0.22 * math.cos(a), -1.80 + 0.22 * math.sin(a), hz + 0.64),
                     (-0.45 - 0.22 * math.cos(a), -1.80 - 0.22 * math.sin(a), hz + 0.64), 0.012, n=6)
             for a in (math.radians(20), math.radians(110))]
    cross.append(kit.rod((-0.45, -1.80, hz + 0.615), (-0.45, -1.80, hz + 0.70), 0.02, n=6))
    p.append(kit.part("turnstile", (0.78, 0.70, 0.40), *cross))

    # -- vent holes on the cryostat, MAHRSI and the boxes ----------------------
    spots = []
    for a, z in ((-20, 0.35), (10, 0.65), (40, 0.30), (-45, 0.75), (70, 0.55), (160, 0.45), (200, 0.70),
                 (250, 0.40), (290, 0.62), (120, 0.85)):
        t = math.radians(a)
        nrm = np.array([math.cos(t), math.sin(t), 0.0])
        spots.append((np.array([0, 0, hz + z]) + R_DEWAR * nrm, nrm))
    for z in (0.35, 0.75):
        spots.append(((mx + 0.30, my, z), (1, 0, 0)))
    spots.append(((0.55 + 0.275, -0.95, hz + 0.22), (1, 0, 0)))
    if two:
        p.append(kit.part("cryostat vent holes", (0.02, 0.02, 0.02), *A.dots(kit, spots, r=0.05)))
    else:
        p.append(kit.part("cryostat vent holes", (0.03, 0.03, 0.03), *A.dots(kit, spots[:3], r=0.05)))

    # -- IPEX-II on STS-85 -------------------------------------------------
    if two:
        x0 = -hx - 0.24
        p.append(kit.part("IPEX-II mast (gold)", (0.70, 0.55, 0.22),
                          kit.truss((x0, -2.25, 0.32), (x0, 0.10, 0.32), 0.42, 9, 0.012, sides=4)))
        p.append(kit.part("IPEX-II end plates", (0.68, 0.52, 0.20),
                          kit.box((0.32, 0.03, 0.32), (x0, -2.27, 0.32)), kit.box((0.32, 0.03, 0.32), (x0, 0.12, 0.32))))
        p.append(kit.part("IPEX-II brackets", A.STRUT, kit.rod((-hx, -1.2, 0.32), (x0, -1.2, 0.32), 0.03, n=8),
                          kit.rod((-hx, 0.1, 0.32), (x0, 0.1, 0.32), 0.03, n=8)))
    return p


def module(kit, flight, mission, norad):
    return dict(meta=dict(name="CRISTA-SPAS %s (%s)" % ("I" * flight, mission),
                          frame="ASTRO-SPAS: +X along the payload bay when berthed (the face with the "
                                "DARA/NASA plates and MAHRSI), +Y across it (between the longeron "
                                "trunnions; the grapple fixture's end), +Z away from the keel struts "
                                "(the cryostat's end); m; the carrier box's centre",
                          source="simple shapes to the STS-66/STS-85 flight and KSC processing photographs "
                                 "(s85e5096, KSC-97PC1005, KSC-97PC1192, sts085-706-051, sts085-722-087, "
                                 "sts066-96-030, sts066-129-043), scaled to the bay's trunnion span",
                          norad=norad, mag_1000km=2.5),
                parts=U.refine_parts(parts(kit, flight)))
