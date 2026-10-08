"""The Hughes HS-376 as STS-51A found Westar 6 and Palapa B2 (November 1984):
still in its launch (stowed) configuration, shared by westar6.py and
palapab2.py.

What they were.  Both were deployed by STS-41B in February 1984; each PAM-D
perigee stage shut down seconds into its burn, leaving the satellites in
low orbits, healthy but never on their way to geostationary orbit -- so the
antenna was never erected and the outer solar panel never dropped: they
stayed as they had left the bay, a 2.16 m drum 2.7-2.8 m long.  Hughes
lowered their orbits and slowed their spin from 50 to about 1 rpm for the
retrieval (STS-51A press kit).  The photographs (51A-46-057, 51A-104-029,
51A-39-034, 51A-39-036, 51A-18-020) show:

  - the outer (telescoping) solar panel, dark blue-black cells in fine rows,
    a few copper-red lines round and along it and an orange ring at its
    forward edge, covering almost all of the drum and open at the aft end
    (the "aft skirt" the press kit says the Stinger went into);
  - a short band of the inner (fixed) panel, slightly narrower, above it;
  - the 1.83 m dual-gridded reflector (two polarisation-selective surfaces,
    the grid plainly visible) folded down flat over the forward end, a
    silvered blanket round its rim, gold-wrapped brackets beneath;
  - a gold-blanketed feed assembly lying across the reflector from its
    centre to one edge, and on a gold strut the omni antenna -- a short
    black cylinder -- sticking out past the rim (the press kit had it cut
    off before the antenna bridge went on; for Westar it was kept as a
    handhold);
  - inside the aft skirt, the Star 30 apogee motor's nozzle, into which the
    Stinger was pushed ("the spent apogee kick motor casing, which is
    inside the aft skirt").

Dimensions: diameter 2.16 m; stowed height 2.82 m for the series (STS-41D
press kit, SBS-4), 9 ft (2.74 m) for Westar 4-6 and 9 ft 4 in (2.84 m) for
Palapa B (Gunter's Space Page, from Hughes data sheets); the reflector
6 ft (1.83 m).  The outer panel's length (about 0.9 diameters, 1.95 m for
Westar) and the band and reflector heights are from the photographs.

Body frame: +X along the spin axis toward the antenna (forward); +Y toward
the end of the feed assembly that reaches the reflector's rim; +Z = X x Y
(the omni sticks out between -Y and +Z).  Metres.  Origin: the estimated
centre of mass on the axis -- 0.50 m aft of the outer panel's forward edge,
about 3/4 of the way up the drum from the aft skirt: the dry spacecraft
(about 580-630 kg with its hydrazine) has its despun communications shelf
and antenna forward and a spent (empty) Star 30 case aft (NASA's press kit
calls it spent; if the motor was in fact still loaded, the centre of mass
would be some 0.25 m further aft).
"""
import math

import numpy as np

from . import _hughes_mesh as hm

R_OUT = 1.08            # the outer solar panel (2.16 m)
R_IN = 1.062            # the inner (fixed) panel, inside it
BAND = 0.26             # the inner panel showing above the outer, m
R_REFL = 0.915          # the reflector (1.83 m)
CELL = (0.030, 0.036, 0.080)        # solar cells, linear albedo
CELL_GAP = (0.085, 0.085, 0.095)    # the gaps and interconnects between them
COPPER = (0.42, 0.13, 0.045)        # the copper-red lines
ORANGE = (0.60, 0.25, 0.07)         # the rings at the panels' forward edges
GOLD = (0.52, 0.37, 0.12)           # gold blankets
SILVER = (0.62, 0.62, 0.64)         # silvered blankets
BLACK = (0.035, 0.035, 0.04)        # black blankets and paint


def _drum_texture(length, seed, stripes):
    """The outer panel's cells, unrolled: x round, y along (aft at the top)."""
    n_around, n_along = 110, int(round(length / 0.02))        # 2 x 6 cm cells
    img = hm.solar_cells(1024, 2048, n_around, n_along, CELL, CELL_GAP, seed)
    for v in stripes:                                         # copper lines round it
        hm.paint_rows(img, v - 0.0015, v + 0.0015, COPPER)
    for k in range(16):                                       # and along it
        u = (k + 0.5) / 16
        hm.paint_cols(img, u - 0.0006, u + 0.0006, COPPER)
    hm.paint_rows(img, 0.0, 0.006, (0.10, 0.10, 0.11))        # the aft edge's frame
    hm.paint_rows(img, 0.982, 1.0, ORANGE)                    # the forward edge's ring
    return hm.image(img)


def _band_texture(seed):
    n_along = int(round(BAND / 0.02))
    img = hm.solar_cells(160, 2048, 108, n_along, CELL, CELL_GAP, seed)
    hm.paint_rows(img, 0.0, 0.04, (0.10, 0.10, 0.11))
    hm.paint_rows(img, 0.40, 0.43, COPPER)
    hm.paint_rows(img, 0.90, 1.0, ORANGE)
    return hm.image(img)


def parts(kit, skirt=1.95, seed=376):
    """The parts of an HS-376 whose outer solar panel is skirt metres long."""
    xc = skirt - 0.50                       # the centre of mass, from the aft edge
    X = lambda s: s - xc                    # a station (m from the aft edge) in the body frame
    top = skirt + BAND                      # the inner panel's forward edge
    rim = top + 0.15                        # the reflector's rim
    P = []

    # --- the spun drum: outer panel (open aft), its inside, the band above
    P.append(hm.part(kit, "outer solar panel", hm.cylinder(R_OUT, X(0.0), X(skirt), n=128),
                     texture=_drum_texture(skirt, seed, (0.34, 0.67))))
    P.append(hm.part(kit, "outer panel inside", hm.cylinder(R_OUT - 0.008, X(0.0), X(skirt), n=96, inward=True),
                     rgb=BLACK))
    P.append(kit.part("outer panel edges", (0.12, 0.12, 0.13),
                      kit.disc(R_OUT, X(0.0), n=128, r_in=R_OUT - 0.008)))
    P.append(kit.part("panel step ring", ORANGE, kit.disc(R_OUT, X(skirt), n=128, r_in=R_IN)))
    P.append(hm.part(kit, "inner solar panel", hm.cylinder(R_IN, X(skirt), X(top), n=128),
                     texture=_band_texture(seed + 1)))

    # --- aft: the thermal barrier across the drum, the PAM interface ring,
    # the Star 30's nozzle (exit 0.25 m radius, recessed 0.12 m)
    s_bar, s_exit, s_thr = 0.46, 0.12, 0.62
    r_exit, r_thr = 0.25, 0.10
    r_at = lambda s: r_exit + (r_thr - r_exit) * (s - s_exit) / (s_thr - s_exit)
    blk = hm.image(hm.blanket(256, 256, (0.03, 0.03, 0.035), seed + 2, crinkle=0.5))
    P.append(hm.part(kit, "aft thermal barrier",
                     hm.annulus(r_at(s_bar), R_OUT - 0.008, X(s_bar), n=96, rows=3), texture=blk))
    P.append(hm.part(kit, "apogee motor nozzle",
                     hm.frustum(r_exit, r_at(s_bar) + 0.004, X(s_exit), X(s_bar) + 0.004, n=48, rows=4),
                     rgb=(0.11, 0.11, 0.115)))
    P.append(kit.part("nozzle lip", (0.22, 0.22, 0.23), kit.disc(r_exit + 0.015, X(s_exit), n=48, r_in=r_exit)))
    P.append(kit.part("nozzle throat", (0.02, 0.02, 0.02), kit.disc(r_at(s_bar) + 0.01, X(s_bar) + 0.05, n=32)))
    P.append(hm.part(kit, "PAM interface ring",
                     hm.merge(hm.cylinder(0.60, X(0.38), X(s_bar), n=96),
                              hm.cylinder(0.57, X(0.38), X(s_bar), n=96, inward=True)),
                     rgb=(0.45, 0.45, 0.46)))
    P.append(kit.part("PAM interface ring face", (0.40, 0.40, 0.41), kit.disc(0.60, X(0.38), n=96, r_in=0.57)))

    # --- small things on the drum: the sun sensor, thruster fairings at the aft edge
    bits = []
    for a, s, size in ((30, 1.62, (0.10, 0.03, 0.07)), (210, 1.62, (0.10, 0.03, 0.07))):
        t = math.radians(a)
        c = (X(s), (R_OUT + 0.015) * math.cos(t), (R_OUT + 0.015) * math.sin(t))
        bits.append(kit.turn(kit.box(size, c), kit.rot('x', a), about=c))
    P.append(kit.part("sun sensors", (0.55, 0.55, 0.57), *bits))
    bits = []
    for a in (95, 275):
        t = math.radians(a)
        c = (X(0.06), (R_OUT + 0.035) * math.cos(t), (R_OUT + 0.035) * math.sin(t))
        bits.append(kit.turn(kit.box((0.10, 0.07, 0.09), c), kit.rot('x', a), about=c))
    P.append(kit.part("thruster fairings", (0.06, 0.06, 0.065), *bits))

    # --- forward: the black barrier across the drum's end (inside the band),
    # the despun mast, the folded reflector and its gold brackets
    s_fb = top - 0.05
    P.append(hm.part(kit, "forward thermal barrier", hm.annulus(0.0, R_IN - 0.006, X(s_fb), n=96, rows=3),
                     texture=blk))
    P.append(hm.part(kit, "inner panel inside", hm.cylinder(R_IN - 0.006, X(s_fb), X(top), n=96, inward=True),
                     rgb=BLACK))
    P.append(kit.part("inner panel edge", (0.12, 0.12, 0.13), kit.disc(R_IN, X(top), n=128, r_in=R_IN - 0.006)))

    refl = hm.grid_reflector(1024, 17, (0.08, 0.085, 0.10), (0.30, 0.30, 0.32), 0.955, SILVER, seed + 3)
    P.append(hm.part(kit, "reflector", hm.dish(R_REFL, 0.10, X(rim), n=96, rows=14), texture=hm.image(refl)))
    sil = hm.image(hm.blanket(256, 512, SILVER, seed + 4, crinkle=0.45, cells=(4, 16)))
    P.append(hm.part(kit, "reflector rim blanket",
                     hm.merge(hm.cylinder(R_REFL, X(rim - 0.055), X(rim + 0.006), n=96),
                              hm.cylinder(R_REFL - 0.01, X(rim - 0.055), X(rim + 0.006), n=96, inward=True)),
                     texture=sil))

    gold = []
    gold.append(hm.with_uv(hm.cylinder(0.28, X(s_fb), X(rim - 0.094), n=40), 2.0))      # despun mast
    for a in (200.0, 320.0, 80.0):                                                       # brackets
        t = math.radians(a)
        cs = np.array((0.0, math.cos(t), math.sin(t)))
        gold.append(hm.with_uv(hm.from_kit(kit.rod(np.array((X(s_fb + 0.01), 0, 0)) + 0.96 * cs,
                                                   np.array((X(rim - 0.05), 0, 0)) + 0.86 * cs, 0.03, 8)), 3.0))
        gold.append(hm.box((0.10, 0.12, 0.12), np.array((X(rim - 0.07), 0, 0)) + 0.86 * cs, 3.0))
    # the feed assembly across the reflector, its block at the centre, the
    # tower at the rim end; the omni's strut
    gold.append(hm.box((0.19, 1.08, 0.24), (X(rim + 0.10), 0.44, 0.0), 2.0))
    gold.append(hm.box((0.34, 0.44, 0.42), (X(rim + 0.08), 0.0, 0.0), 2.0))
    gold.append(hm.box((0.32, 0.20, 0.28), (X(rim + 0.16), 0.92, 0.0), 2.0))
    t = math.radians(135.0)
    d = np.array((0.0, math.cos(t), math.sin(t)))
    p0 = np.array((X(rim + 0.22), 0.0, 0.0)) + 0.12 * d
    p1 = np.array((X(rim + 0.40), 0.0, 0.0)) + 0.96 * d
    gold.append(hm.with_uv(hm.from_kit(kit.rod(p0, p1, 0.028, 8)), 3.0))
    goldtex = hm.image(hm.blanket(512, 512, GOLD, seed + 5, crinkle=1.1, cells=(9, 9)))
    P.append(hm.part(kit, "gold blankets", hm.merge(*gold), texture=goldtex))

    # the omni antenna: a black cylinder on the strut's end, a grey cap
    u = (p1 - p0) / np.linalg.norm(p1 - p0)
    P.append(kit.part("omni antenna", (0.04, 0.04, 0.045), kit.rod(p1, p1 + 0.24 * u, 0.045, 16),
                      kit.rod(p1 - 0.02 * u, p1 + 0.03 * u, 0.06, 16)))
    P.append(kit.part("omni cap", (0.45, 0.45, 0.47), kit.sphere(0.05, 8, centre=p1 + 0.25 * u)))
    return P


def meta(name, norad, source_extra=""):
    return dict(name=name,
                frame="HS-376 stowed: +X along the spin axis toward the folded antenna; +Y toward the feed "
                      "assembly's rim end; m; origin the estimated centre of mass, 0.50 m aft of the outer "
                      "solar panel's forward edge",
                source="built from STS-51A press kit drawings and photographs (51A-46-057, 51A-104-029, "
                       "51A-39-036, 51A-18-020), STS-41B/41D press kit dimensions, Gunter's Space Page"
                       + source_extra + " (portview/vehicles/_hs376.py)",
                norad=norad, mag_1000km=3.0)
