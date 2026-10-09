"""The Plasma Diagnostics Package (NORAD 15929), University of Iowa, as it
flew free on STS-51F (Spacelab 2, July-August 1985): released from the arm,
it was circled by Challenger for some six hours (passing through the
orbiter's wake and plasma) and caught again.  (It had flown on STS-3 too,
only on the arm.)

PDP, as the photographs and the University of Iowa's specification show it:

  - a drum 107 cm across and 66 cm high (the RPDP specification, NTRS
    19810006441, table 1), its side in light grey-white blankets with a
    darker rectangular access panel carrying two round sensor ports
    (STS-51F's 8772046);
  - on its grapple end (-X) the outer annulus silver, stepped in at 0.39 m
    radius to a 0.3 m high, 0.76 m wide white cylinder whose end is a
    white ring round a dark recessed well with a serrated ring, the
    grapple fixture's shaft at its centre (51F-33-024 and STS-3's
    sts003-009-444 look straight at this end; 51F-34-041 shows the step
    from the side);
  - a gold-blanketed box and a silver box on that end near the rim
    (51F-33-024, sts003-009-444);
  - two 17 cm spheres on short stalks standing off the grapple end near
    the rim, dark on 51F (8772046; silver on STS-3);
  - a white wedge-shaped box on the drum's side by the grapple end
    (sts003-009-444, 51F-33-024);
  - six short probe booms round the rim at the grapple end, each a white
    cylinder with brass bands, leaning back toward -X (51F-33-024,
    sts003-009-444);
  - the two long electric-antenna booms, opposite each other: each leaves
    the grapple end's rim at 45 degrees outward and forward (toward +X)
    for 0.5 m, then runs straight out radially, tipped with the 7 cm
    spherical probe, ~1.85 m from the axis; dark, with white guard beads
    every 0.3 m (51F-34-041, free-flying, side-on; 51F-33-024 end-on,
    which shows them 1.2-1.5 m beyond the rim);
  - on the +X end a grey face with an instrument box and a thin rod
    antenna standing past the rim (51F-34-041).

Measured on 51F-34-041 (the drum's 1.07 m diameter scales it, ~113 px/m
on the 1919 px scan) and 51F-33-024 (~207 px/m), with 8772046 and
sts003-009-444 for the arrangement.  Uncertain: the stub probes' exact
angles (the two flights differ), the +X face's detail (no flight photo
shows it well), the boom tips' distance (foreshortened in every view).
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'pdp'

R, L = 0.535, 0.66
RA, LA = 0.38, 0.30          # the grapple-end step: radius, height
X0, X1 = -L / 2, L / 2
WHITE = (0.80, 0.80, 0.78)
SILVER = (0.64, 0.65, 0.67)
GOLD = (0.72, 0.55, 0.20)
BRASS = (0.62, 0.48, 0.20)
DARK = (0.05, 0.05, 0.06)


def _radial(theta_deg):
    t = math.radians(theta_deg)
    return np.array([0.0, math.cos(t), math.sin(t)])


def build(kit):
    p = []
    drum = U.cylinder_fine(R, X0, X1, n=48, max_len=0.35, caps=False)
    p.append(U.tpart(kit, "drum (white blanket)", WHITE, drum, U.tex_mli(111, seams=2, depth=0.30),
                     cyl=(0.66, 4), smooth=True))
    p.append(kit.part("drum rims", (0.60, 0.60, 0.61),
                      kit.tube(R + 0.012, R - 0.03, X1 - 0.025, X1 + 0.012, n=48),
                      kit.tube(R + 0.012, R - 0.03, X0 - 0.012, X0 + 0.025, n=48)))
    # the access panel with its two ports and a small plate (8772046)
    n_ = _radial(-20)
    Rm = U.frame_from(n_, (1, 0, 0))
    pan = U.place(kit, kit.box((0.012, 0.36, 0.42)), Rm, n_ * (R + 0.006) + (0.02, 0, 0))
    p.append(kit.part("access panel", (0.52, 0.52, 0.50), pan))
    ports = [U.place(kit, kit.disc(0.065, 0.0, n=16), Rm, n_ * (R + 0.014) + (0.10, 0, 0) + Rm[:, 1] * dy)
             for dy in (-0.09, 0.09)]
    p.append(kit.part("sensor ports", DARK, *ports))
    p.append(kit.part("port collars", (0.70, 0.35, 0.15),
                      *[U.place(kit, kit.disc(0.085, 0.0, n=16, r_in=0.066), Rm, n_ * (R + 0.013) + (0.10, 0, 0)
                                + Rm[:, 1] * dy) for dy in (-0.09, 0.09)]))
    # +X end: grey face, an instrument box, a rod antenna past the rim
    p.append(kit.part("+X end face", (0.34, 0.34, 0.36), U.refine(kit.disc(R - 0.005, X1 - 0.005, n=48), 0.3)))
    p.append(kit.part("+X instrument box", (0.66, 0.66, 0.68), kit.box((0.10, 0.24, 0.18), (X1 + 0.045, -0.15, 0.12))))
    p.append(kit.part("+X rod antenna", (0.55, 0.55, 0.56), kit.rod((X1 + 0.03, 0.0, 0.30), (X1 + 0.03, 0.0, R + 0.32), 0.012, n=6),
                      kit.box((0.04, 0.06, 0.08), (X1 + 0.03, 0.0, 0.30))))
    # the grapple end (-X): silver outer annulus, the step cylinder, its
    # white ring and dark well, the serrated ring, the grapple fixture
    p.append(kit.part("grapple-end annulus (silver)", SILVER,
                      U.facing_aft(kit, kit.disc(R - 0.005, 0.0, n=48, r_in=RA), X0 - 0.005)))
    step = U.cylinder_fine(RA, X0 - LA, X0, n=40, max_len=0.35, caps=False)
    p.append(U.tpart(kit, "grapple-end drum (white blanket)", WHITE, step, U.tex_mli(112, seams=1, depth=0.3),
                     cyl=(0.3, 3), smooth=True))
    xe = X0 - LA
    p.append(kit.part("grapple-end ring (white)", (0.84, 0.84, 0.82),
                      U.facing_aft(kit, kit.disc(RA, 0.0, n=40, r_in=0.22), xe)))
    p.append(kit.part("grapple well", DARK, U.flip(kit.cylinder(0.22, xe, xe + 0.12, n=32, caps=False)),
                      U.facing_aft(kit, kit.disc(0.22, 0.0, n=32), xe + 0.12)))
    teeth = []
    for k in range(24):
        a = 2 * math.pi * k / 24
        c = np.array([xe + 0.03, 0.20 * math.cos(a), 0.20 * math.sin(a)])
        teeth.append(kit.box((0.06, 0.02, 0.04), c))
    p.append(kit.part("serrated ring", (0.10, 0.10, 0.11), *teeth))
    for name, rgb, m in U.frgf(kit, (xe + 0.115, 0.0, 0.0), (-1, 0, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    # the gold and silver boxes on the grapple end near the rim
    ug = _radial(100)
    p.append(U.tpart(kit, "gold-blanketed box", GOLD, kit.box((0.18, 0.22, 0.20), (X0 - 0.095, *(ug[1:] * 0.47))),
                     U.tex_mli(113, seams=0, depth=0.5), tile=0.25))
    us = _radial(130)
    p.append(kit.part("silver box", (0.72, 0.72, 0.74), kit.box((0.10, 0.18, 0.15), (X0 - 0.055, *(us[1:] * 0.45)))))
    # the two spheres on short stalks off the grapple end
    sph, stalks = [], []
    for th in (165, 5):
        u = _radial(th)
        base = np.array([X0 - 0.005, 0, 0]) + u * 0.46
        tip = base + np.array([-0.28, 0, 0]) + u * 0.06
        stalks.append(kit.rod(base, tip, 0.012, n=6))
        sph.append(kit.sphere(0.085, n=12, centre=tip + (-0.07, 0, 0) + u * 0.02))
    p.append(kit.part("spheres (dark, STS-51F)", (0.12, 0.12, 0.13), *sph, smooth=True))
    # the white wedge box on the side
    uw = _radial(215)
    Rw = U.frame_from(uw, (1, 0, 0))                # local x out, z along +X
    wedge = kit.prism([(-0.15, -0.30), (0.15, -0.30), (0.15, 0.10), (-0.15, 0.20)], 0.0, 0.16)
    # prism along local x (out); section (local y, local z): taller at -X
    p.append(U.tpart(kit, "white wedge box", WHITE, U.place(kit, wedge, Rw, uw * (R + 0.005) + (X0 + 0.02, 0, 0)),
                     U.tex_mli(114, seams=0, depth=0.3), tile=0.3))
    # six short probe booms round the grapple-end rim, leaning back to -X
    probes, bands = [], []
    for th in (170, 200, 235, 262, 300, 330):
        u = _radial(th)
        a = np.array([X0 + 0.04, 0, 0]) + u * (R + 0.01)
        d = u * math.cos(math.radians(30)) + np.array([-math.sin(math.radians(30)), 0, 0])
        b = a + d * 0.14
        stalks.append(kit.rod(a, b, 0.012, n=6))
        probes.append(kit.along(kit.cylinder(0.022, 0.0, 0.24, n=10), d, b))
        bands.append(kit.along(kit.cylinder(0.025, 0.0, 0.03, n=10), d, b + d * 0.06))
        bands.append(kit.along(kit.cylinder(0.025, 0.0, 0.04, n=10), d, b + d * 0.20))
    p.append(kit.part("probe cylinders (white)", (0.82, 0.82, 0.80), *probes))
    p.append(kit.part("probe bands (brass)", BRASS, *bands))
    p.append(kit.part("stalks", (0.60, 0.60, 0.61), *stalks))
    # the two long antenna booms (+-Y): a 45-degree leg forward, then radial
    booms, beads, tips = [], [], []
    for s in (-1, 1):
        u = np.array([0.0, s, 0.0])
        a = np.array([X0 + 0.03, 0, 0]) + u * (R + 0.01)
        knee = a + np.array([0.35, 0, 0]) + u * 0.35
        tip = knee + u * (1.85 - (R + 0.36))
        booms.append(kit.rod(a, knee, 0.013, n=6))
        booms.append(kit.rod(knee, tip, 0.011, n=6))
        r = R + 0.36 + 0.25
        while r < 1.80:
            beads.append(kit.box((0.035, 0.035, 0.035), np.array([knee[0], 0, 0]) + u * r))
            r += 0.30
        tips.append(kit.sphere(0.035, n=8, centre=tip + u * 0.035))
    p.append(kit.part("antenna booms", (0.12, 0.12, 0.12), *booms))
    p.append(kit.part("boom beads", (0.85, 0.85, 0.83), *beads))
    p.append(kit.part("spherical probes", (0.10, 0.10, 0.10), *tips, smooth=True))
    return dict(meta=dict(name="Plasma Diagnostics Package (STS-51F)",
                          frame="PDP: +X along the drum's axis away from the grapple fixture, +Y "
                                "along the long booms, +Z; m; the drum's centre",
                          source="simple shapes to the University of Iowa's specification (107 x 66 cm, "
                                 "NTRS 19810006441) and photographs 51F-34-041, 51F-33-024, 8772046 "
                                 "(STS-51F) and sts003-009-444, s03-21-080 (STS-3)",
                          norad=15929, mag_1000km=5.0),
                parts=U.refine_parts(p))
