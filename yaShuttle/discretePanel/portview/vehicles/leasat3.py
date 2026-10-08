"""Leasat 3 (Syncom IV-3, NORAD 15643), a Hughes HS-381, as STS-51I met it
on 31 August 1985 for the salvage.

What it was.  STS-51D "Frisbee"-deployed it on 13 April 1985, but its
sequencer never started: the omni antenna was not raised, the spin-up never
came and the solid perigee motor never fired (STS-51I press kit).  So
STS-51I found it exactly as it had left the bay -- in launch configuration,
spinning slowly, its perigee motor and liquid propellants still loaded.  Van
Hoften and Fisher fitted the bypass box, *then* deployed the omni (press
kit's EVA timeline: "DEPLOY OMNI") and spun it up by hand; this model is the
spacecraft at the rendezvous and capture, omni stowed.  OMNI_DEPLOYED = True
draws it as van Hoften released it (photographs 51I-102-029/033): the omni
on its mast, the two helices still folded.

The shape, from the press kits and photographs (51D-31-081, 51D-32-013,
51D-11-010, 41D-02-020, STS032-87-030, 51I-S-237, 51I-102-033):

  - the spun drum, 4.26 m in diameter (STS-41D press kit: "4.2 m across";
    Gunter: 4.26 m) and about 3.0 m long (measured off the photographs; the
    stowed spacecraft is 4.29 m long overall -- Gunter's Space Page), dark
    blue-black cells with copper lines in rows and columns, a copper belt
    round the middle, a few copper patches and silvered strips;
  - the forward face: a silvered blanket in radial gores round a raised
    central disc (the despun platform's bearing), about 1.9 m across;
  - folded flat across it, the two UHF helices -- square lattice booms
    about 0.3 m wide and 3.8 m long (Astronautix: 30 cm by 3.8 m), parallel
    about 1.25 m apart, each with its basket-like cup at the feed end
    (the end at one edge of the face) and running out past the far rim;
    between them the despun platform's dark beam, with the omni antenna
    (a white rod, a banded tip) lying along it;
  - the aft face: dark, with the gold-blanketed dome of the perigee motor
    (the Minuteman third stage, STS-51D press kit) and its nozzle at the
    centre, and two small liquid-engine nozzles.

Body frame: +X along the spin axis toward the antennas (forward); +Y along
the folded helices, from their tips toward the cup end; +Z = X x Y.
Metres.  Origin: the estimated centre of mass on the axis, 1.2 m forward of
the aft face: the loaded solid perigee motor (some 3.5 t, in the aft half
round the axis) dominates the ~7 t spacecraft, the liquid propellant tanks
and the rest of the spun section sit about mid-drum.
"""
import math

import numpy as np

from . import _hughes_mesh as hm

KEY = 'leasat3'
OMNI_DEPLOYED = False

R = 2.13                 # the drum (4.26 m)
L = 3.00                 # its length
XC = 1.20                # the centre of mass, forward of the aft face
CELL = (0.028, 0.034, 0.085)
CELL_GAP = (0.075, 0.078, 0.092)
COPPER = (0.45, 0.15, 0.05)
SILVER = (0.50, 0.50, 0.52)
GOLD = (0.50, 0.36, 0.12)
TRUSS = (0.065, 0.052, 0.040)
CUP = (0.40, 0.22, 0.09)


def X(s):
    return s - XC


def _drum_texture():
    img = hm.solar_cells(1024, 2048, 330, 150, CELL, CELL_GAP, 381)
    for v in (0.25, 0.75):
        hm.paint_rows(img, v - 0.002, v + 0.002, COPPER)
    hm.paint_rows(img, 0.49, 0.51, COPPER)                       # the belt
    for k in range(48):                                          # its pads
        u = (k + 0.5) / 48
        hm.paint_rect(img, u - 0.002, 0.485, u + 0.002, 0.515, (0.60, 0.32, 0.10))
    for k in range(16):
        u = (k + 0.5) / 16
        hm.paint_cols(img, u - 0.0008, u + 0.0008, COPPER)
    for k in range(4):                                           # silvered strips
        u = k / 4 + 0.03
        hm.paint_cols(img, u - 0.0025, u + 0.0025, (0.40, 0.40, 0.42))
    rng = np.random.default_rng(3)
    for _ in range(9):                                           # copper patches
        u, v = rng.uniform(0, 1), rng.choice((0.12, 0.38, 0.62, 0.88))
        hm.paint_rect(img, u, v - 0.035, u + 0.011, v + 0.035, (0.50, 0.20, 0.07))
    hm.paint_rect(img, 0.30, 0.47, 0.312, 0.53, (0.70, 0.70, 0.72))   # a sensor on the belt
    hm.paint_rows(img, 0.0, 0.006, (0.10, 0.10, 0.12))
    hm.paint_rows(img, 0.994, 1.0, (0.45, 0.45, 0.47))
    return hm.image(img)


def _cup(kit, base, axis):
    """A helix's cup: a frustum cage from radius 0.24 to 0.38 over 0.38 m
    along axis, a spoked wheel across its wide end."""
    a = np.asarray(axis, float)
    a /= np.linalg.norm(a)
    e1 = np.cross(a, (1.0, 0.0, 0.0))
    if np.linalg.norm(e1) < 1e-6:
        e1 = np.cross(a, (0.0, 1.0, 0.0))
    e1 /= np.linalg.norm(e1)
    e2 = np.cross(a, e1)
    ring = lambda c, r, k, n: c + r * (math.cos(2 * math.pi * k / n) * e1 + math.sin(2 * math.pi * k / n) * e2)
    b0, b1 = np.asarray(base, float), np.asarray(base, float) + 0.38 * a
    m = []
    n = 16
    for k in range(n):
        m.append(kit.rod(ring(b0, 0.24, k, n), ring(b0, 0.24, k + 1, n), 0.012, 6))
        m.append(kit.rod(ring(b1, 0.38, k, n), ring(b1, 0.38, k + 1, n), 0.014, 6))
        m.append(kit.rod(ring(b0 + 0.19 * a, 0.31, k, n), ring(b0 + 0.19 * a, 0.31, k + 1, n), 0.008, 6))
        if k % 2 == 0:
            m.append(kit.rod(ring(b0, 0.24, k, n), ring(b1, 0.38, k, n), 0.010, 6))
            m.append(kit.rod(b1, ring(b1, 0.38, k, n), 0.009, 6))
    m.append(kit.rod(b1 - 0.02 * a, b1 + 0.03 * a, 0.07, 12))      # the wheel's hub
    return m


def build(kit):
    P = []
    # --- the drum and its ends
    P.append(hm.part(kit, "solar drum", hm.cylinder(R, X(0.0), X(L), n=160), texture=_drum_texture()))
    face = hm.gores(1024, 24, SILVER, (0.38, 0.38, 0.40), 0.446, (0.50, 0.50, 0.52), 51)
    face = hm.image(face)
    P.append(hm.part(kit, "forward blanket", hm.annulus(0.95, R, X(L), n=128, rows=4, scale=R), texture=face))
    P.append(hm.part(kit, "despun bearing", hm.merge(hm.cylinder(0.95, X(L), X(L + 0.08), n=96),
                                                      hm.annulus(0.0, 0.95, X(L + 0.08), n=96, rows=3, scale=R)),
                     texture=face))
    aft = hm.image(hm.blanket(512, 512, (0.06, 0.07, 0.09), 52, crinkle=0.25))
    P.append(hm.part(kit, "aft face", hm.annulus(1.15, R, X(0.0), n=128, rows=4), texture=aft))
    gold = hm.image(hm.blanket(512, 512, GOLD, 53, crinkle=1.0, cells=(9, 9)))
    P.append(hm.part(kit, "perigee motor blanket", hm.dome(1.15, 0.22, X(0.0), n=64, rows=10, toward=-1.0),
                     texture=gold))
    P.append(hm.part(kit, "perigee motor nozzle", hm.frustum(0.27, 0.37, X(-0.20), X(-0.55), n=48, rows=3),
                     rgb=(0.10, 0.10, 0.105)))
    P.append(kit.part("nozzle lip", (0.25, 0.25, 0.26), kit.disc(0.39, X(-0.55), n=48, r_in=0.37)))
    P.append(kit.part("nozzle throat", (0.015, 0.015, 0.015), kit.disc(0.275, X(-0.25), n=32)))
    P.append(hm.part(kit, "motor ring", hm.merge(hm.cylinder(0.62, X(-0.25), X(-0.14), n=64),
                                                 hm.annulus(0.56, 0.62, X(-0.25), n=64, rows=1)),
                     rgb=(0.55, 0.55, 0.57)))
    lae = []
    for a in (45.0, 225.0):
        t = math.radians(a)
        c = np.array((0.0, 1.55 * math.cos(t), 1.55 * math.sin(t)))
        lae.append(kit.move(kit.frustum(0.07, 0.12, X(0.0), X(-0.20), n=24, caps=False), c))
    P.append(kit.part("liquid engines", (0.13, 0.13, 0.14), *lae, smooth=True))

    # --- the despun platform's structure, folded antennas
    s_beam, s_top = L + 0.085, L + 0.30           # stood 5 mm off the bearing
    s_h = L + 0.45                                     # the helices' axis
    beam = [kit.box((s_top - s_beam, 2.95, 0.36), (X(0.5 * (s_beam + s_top)), 0.275, 0.0)),
            kit.box((0.36, 0.55, 0.55), (X(s_beam + 0.18), 0.0, 0.0))]
    for y in (1.30, 0.20, -1.00):
        for z in (-1.0, 1.0):
            beam.append(kit.rod((X(s_top - 0.02), y, 0.16 * z), (X(s_h), y, 0.62 * z), 0.025, 8))
    P.append(kit.part("despun structure", (0.05, 0.05, 0.055), *beam))
    trusses, cups = [], []
    for z in (-0.62, 0.62):
        trusses.append(kit.truss((X(s_h), 1.60, z), (X(s_h), -2.20, z), 0.42, 13, 0.011, sides=4))
        cups += _cup(kit, (X(s_h), 1.60, z), (0.0, 1.0, 0.0))
    P.append(kit.part("UHF helix booms", TRUSS, *trusses))
    P.append(kit.part("UHF helix cups", CUP, *cups))

    # --- the omni antenna: stowed along the beam, or raised on its mast
    if OMNI_DEPLOYED:
        p0 = np.array((X(s_top), -0.30, 0.0))
        d = np.array((0.55, -0.83, 0.0))
    else:
        p0 = np.array((X(s_top + 0.06), 1.30, 0.0))
        d = np.array((0.0, -1.0, 0.0))
    d = d / np.linalg.norm(d)
    p1 = p0 + 2.85 * d
    P.append(kit.part("omni mast", (0.70, 0.70, 0.72), kit.rod(p0, p1, 0.022, 10)))
    bands = [[], []]
    for k in range(4):
        bands[k % 2].append(kit.rod(p1 + 0.10 * k * d, p1 + 0.10 * (k + 1) * d, 0.065, 16))
    P.append(kit.part("omni tip white", (0.70, 0.70, 0.72), *bands[0]))
    P.append(kit.part("omni tip black", (0.03, 0.03, 0.03), *bands[1]))

    return dict(meta=dict(name="Leasat 3 (Syncom IV-3, HS-381, as found by STS-51I)",
                          frame="Leasat: +X along the spin axis toward the folded antennas; +Y along the "
                                "folded helices toward their cups; m; origin the estimated centre of mass, "
                                "1.2 m forward of the aft face",
                          source="built from STS-51D/51I/41D press kits and photographs (51D-31-081, 51D-32-013, "
                                 "51D-11-010, 41D-02-020, STS032-87-030, 51I-S-237), Gunter's Space Page, "
                                 "Astronautix (portview/vehicles/leasat3.py)",
                          norad=15643, mag_1000km=2.0),
                parts=P)
