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
51A-39-034, 51A-39-036, 51A-18-020, and Hughes's factory photographs of
the series) show:

  - the outer (telescoping) solar panel: dark blue-black cells in fine
    rows (brown-red under floodlights), an orange-red ring at its forward
    edge and a thin one at its aft edge, and rows of short orange dashes
    round it -- the cell strings' interconnect tabs -- at about a quarter,
    a half and three quarters of its length; faint seams along it.  It
    covers almost all of the drum and is open at the aft end (the "aft
    skirt" the press kit says the Stinger went into);
  - a band of the inner (fixed) panel, slightly narrower, above it, with
    its own orange-red ring at its forward edge;
  - the 1.83 m dual-gridded reflector (two polarisation-selective surfaces)
    folded down flat over the forward end: in sunlight a dark mirror (it
    reflects black sky) crossed by a fine bright grid, a crinkled silvered
    blanket round its rim, black beneath, gold-wrapped brackets under it;
  - a gold-blanketed feed assembly lying across the reflector from a bulky
    block at its centre to a tower at the rim, which drops past the rim to
    the drum; a black strap across the reflector beside it; and on a gold
    strut the omni antenna -- a short black cylinder -- sticking out past
    the rim the other way (the press kit had it cut off before the antenna
    bridge went on; for Westar it was kept as a handhold);
  - inside the aft skirt, the Star 30 apogee motor's nozzle (fired: empty),
    into which the Stinger was pushed ("the spent apogee kick motor
    casing, which is inside the aft skirt").

The capture hardware (capture=True in parts()).  The Stinger -- the Apogee
Kick Motor Capture Device, about 6 ft (1.8 m) long, carried on the MMU's
arms -- went into the nozzle; toggle fingers opened inside the motor, a
crank drew the satellite against a padded ring at the Stinger's base, and
the RMS took the grapple fixture on its shaft.  The A-frame (the Antenna
Bridge Structure) never went on either satellite: on Palapa a waveguide
stood further out than the drawings said and it would not fit, and on
Westar Allen held the antenna end by hand -- "a human A-frame" -- while
Gardner bolted the cradle adaptor to the aft end (americaspace.com, NASA
history office).  So the A-frame is not drawn; the Stinger is, as it was
while the arm held the satellite.  It is off by default: the satellite as
the Orbiter approached it.

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
CELL = (0.030, 0.034, 0.075)        # solar cells, linear albedo
CELL_GAP = (0.075, 0.072, 0.080)    # the gaps and interconnects between them
SEAM = (0.10, 0.095, 0.10)          # the faint seams along the panel
COPPER = (0.55, 0.16, 0.05)         # the interconnect dashes
RED = (0.62, 0.12, 0.04)            # the rings at the panels' edges (orange-red)
GOLD = (0.85, 0.50, 0.10)           # gold (Kapton) blankets
SILVER = (0.42, 0.43, 0.45)         # silvered blankets
BLACK = (0.035, 0.035, 0.04)        # black blankets and paint
STEEL = (0.50, 0.50, 0.52)          # the Stinger (bare aluminium)


# ------------------------------------------------------------- textures

def _facets(h, w, n, seed):
    """Crumpled-foil facets: a tiling Voronoi pattern of about n cells (one
    jittered point per cell of a grid), each a random brightness (its tilt
    to the light).  (f, edge): f about 0.3-1.4, edge 0-1 near the creases."""
    rng = np.random.default_rng(seed)
    gy = max(2, int(round(math.sqrt(n * h / w))))
    gx = max(2, int(round(n / gy)))
    jit = rng.uniform(0.05, 0.95, (gy, gx, 2))
    val = rng.uniform(0.0, 1.0, (gy, gx))
    yy = (np.arange(h) + 0.5) / h * gy
    xx = (np.arange(w) + 0.5) / w * gx
    Y, Xg = np.meshgrid(yy, xx, indexing='ij')
    cy, cx = np.floor(Y).astype(int), np.floor(Xg).astype(int)
    best = np.full((h, w), 9.0)
    second = np.full((h, w), 9.0)
    v = np.zeros((h, w))
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            jy, jx = (cy + dy) % gy, (cx + dx) % gx
            py = cy + dy + jit[jy, jx, 0]
            px = cx + dx + jit[jy, jx, 1]
            d = np.hypot(Y - py, Xg - px)
            closer = d < best
            second = np.where(closer, best, np.minimum(second, d))
            v = np.where(closer, val[jy, jx], v)
            best = np.where(closer, d, best)
    edge = np.clip(1.0 - (second - best) / 0.10, 0.0, 1.0)
    f = 0.30 + 1.0 * v ** 1.5 + 0.10 * hm._noise(h, w, (6, 6), seed + 1, octaves=2)
    return f, edge


def _foil(h, w, base, seed, n=160, glint=0.5):
    """Crinkled foil (multi-layer insulation) of linear albedo base: facets
    at random tilts, creases, the brightest facets whitened (glints)."""
    f, edge = _facets(h, w, n, seed)
    f2, _ = _facets(h, w, n * 4, seed + 11)
    f = 0.7 * f + 0.3 * f2
    f = f * (1.0 - 0.35 * edge) + 0.5 * edge * (f > 0.9)
    img = f[:, :, None] * np.asarray(base, float)[None, None, :]
    img += glint * np.clip(f - 1.05, 0.0, None)[:, :, None]
    return np.clip(img, 0.0, 1.0)


def _drum_texture(length, seed):
    """The outer panel's cells, unrolled: x round, y along (aft at the top)."""
    n_around, n_along = 110, int(round(length / 0.02))        # 6 x 2 cm cells
    img = hm.solar_cells(1024, 2048, n_around, n_along, CELL, CELL_GAP, seed)
    h, w = img.shape[:2]
    for k in range(16):                                       # seams along it
        u = (k + 0.5) / 16
        hm.paint_cols(img, u - 0.0005, u + 0.0005, SEAM)
    # the rows of orange dashes: one cell long, every other cell round
    for v in (0.25, 0.50, 0.75):
        r0, r1 = int((v - 0.006) * h), int((v + 0.006) * h)
        cols = ((np.arange(w) + 0.5) / w * n_around / 2.0) % 1.0
        img[r0:r1, (cols > 0.10) & (cols < 0.45)] = COPPER
    hm.paint_rows(img, 0.0, 0.004, (0.08, 0.08, 0.09))        # the aft edge's frame
    hm.paint_rows(img, 0.004, 0.009, RED)                     # a thin ring at the aft edge
    hm.paint_rows(img, 0.984, 1.0, RED)                       # the forward edge's ring
    # two sensor windows (black, framed) at 1/3 of the length
    for u in (0.21, 0.71):
        hm.paint_rect(img, u - 0.006, 0.30, u + 0.006, 0.33, (0.30, 0.10, 0.04))
        hm.paint_rect(img, u - 0.004, 0.303, u + 0.004, 0.327, (0.01, 0.01, 0.012))
    return hm.image(img)


def _band_texture(seed):
    n_along = int(round(BAND / 0.02))
    img = hm.solar_cells(160, 2048, 108, n_along, CELL, CELL_GAP, seed)
    hm.paint_rows(img, 0.0, 0.03, (0.08, 0.08, 0.09))
    hm.paint_rows(img, 0.88, 1.0, RED)
    return hm.image(img)


def _reflector_texture(seed, n_lines=15, size=1024):
    """The gridded reflector face-on: a dark mirror (black sky in it), a
    little crinkle catching the sun, a fine bright grid; the rim's
    silvered blanket beyond 0.94 of the radius."""
    yy, xx = np.mgrid[0:size, 0:size]
    u, v = (xx + 0.5) / size * 2 - 1, (yy + 0.5) / size * 2 - 1
    f, _ = _facets(size, size, 70, seed)
    img = (0.6 + 0.5 * f)[:, :, None] * np.asarray((0.018, 0.020, 0.030))[None, None, :]
    fu, fv = (u + 1) / 2 * n_lines % 1.0, (v + 1) / 2 * n_lines % 1.0
    lw = 0.035
    img[(fu < lw) | (fv < lw)] = (0.36, 0.35, 0.31)
    r = np.hypot(u, v)
    rim = _foil(size, size, SILVER, seed + 7, n=900)
    img[r > 0.94] = rim[r > 0.94]
    img[(r > 0.935) & (r <= 0.94)] = (0.20, 0.20, 0.21)
    return hm.image(img)


# ------------------------------------------------------------- shapes

def _torus(R, r, x, n=48, m=8):
    """A ring of tube (radius r) round the X axis, radius R, in the plane X = x:
    kit-style (points, triangles), shared points (for smooth=True)."""
    pts = []
    for i in range(n):
        a = 2 * math.pi * i / n
        for j in range(m):
            b = 2 * math.pi * j / m
            rr = R + r * math.cos(b)
            pts.append((x + r * math.sin(b), rr * math.cos(a), rr * math.sin(a)))
    tris = []
    for i in range(n):
        i2 = (i + 1) % n
        for j in range(m):
            j2 = (j + 1) % m
            a, b, c, d = i * m + j, i2 * m + j, i2 * m + j2, i * m + j2
            tris += [(a, c, b), (a, d, c)]
    return np.array(pts, float), np.array(tris, int)


def _stinger(kit, X, s_throat, seed):
    """The Apogee Kick Motor Capture Device as the arm held it: its shaft up
    the nozzle to the throat, the padded ring at its base against the aft
    skirt's PAM ring, spokes to a hub, the grapple fixture on the shaft and
    the MMU attach frame at the far end -- 1.8 m from tip to base ring."""
    P = []
    tip = X(s_throat + 0.05)
    base = tip - 1.80
    s_ring = X(-0.06)                   # the padded ring, just aft of the skirt
    metal = [kit.rod((tip, 0, 0), (base - 0.35, 0, 0), 0.035, 12)]
    # the toggle fingers, opened inside the motor case past the throat
    for k in range(4):
        a = math.radians(45 + 90 * k)
        d = np.array((0.0, math.cos(a), math.sin(a)))
        metal.append(kit.rod(np.array((tip - 0.02, 0, 0)), np.array((tip + 0.10, 0, 0)) + 0.13 * d, 0.012, 6))
    # the hub, its spokes to the ring, and struts back to the MMU frame
    hub = s_ring - 0.30
    metal.append(kit.cylinder(0.07, hub - 0.05, hub + 0.05, 16))
    for k in range(4):
        a = math.radians(90 * k)
        d = np.array((0.0, math.cos(a), math.sin(a)))
        metal.append(kit.rod(np.array((hub, 0, 0)) + 0.06 * d, np.array((s_ring, 0, 0)) + 0.53 * d, 0.016, 6))
        metal.append(kit.rod(np.array((hub, 0, 0)) + 0.06 * d, np.array((base - 0.30, 0, 0)) + 0.32 * d, 0.016, 6))
    # the MMU attach frame: a square of tube at the far end
    c = [np.array((base - 0.30, 0, 0)) + 0.32 * np.array((0.0, math.cos(math.radians(90 * k)),
                                                          math.sin(math.radians(90 * k)))) for k in range(4)]
    for k in range(4):
        metal.append(kit.rod(c[k], c[(k + 1) % 4], 0.018, 6))
    P.append(kit.part("stinger", STEEL, *metal))
    P.append(kit.part("stinger padded ring", (0.70, 0.70, 0.68), _torus(0.53, 0.022, s_ring), smooth=True))
    # the grapple fixture on the shaft, between the ring and the MMU: a
    # square base plate, the black-and-white target, the pin
    g = base + 0.55
    P.append(kit.part("stinger grapple fixture", (0.62, 0.62, 0.63),
                      kit.box((0.04, 0.30, 0.30), (g, 0.0, 0.0)),
                      kit.rod((g, 0.0, 0.0), (g - 0.22, 0.0, 0.0), 0.03, 10),
                      kit.box((0.03, 0.10, 0.10), (g - 0.23, 0.0, 0.0))))
    P.append(kit.part("stinger grapple target", (0.03, 0.03, 0.035),
                      kit.box((0.004, 0.16, 0.16), (g - 0.022, 0.0, 0.0))))
    return P


# ------------------------------------------------------------- the model

def parts(kit, skirt=1.95, seed=376, capture=False):
    """The parts of an HS-376 whose outer solar panel is skirt metres long;
    capture: with the Stinger in its nozzle (see the module's notes)."""
    xc = skirt - 0.50                       # the centre of mass, from the aft edge
    X = lambda s: s - xc                    # a station (m from the aft edge) in the body frame
    top = skirt + BAND                      # the inner panel's forward edge
    rim = top + 0.15                        # the reflector's rim
    P = []

    # --- the spun drum: outer panel (open aft), its inside, the band above
    P.append(hm.part(kit, "outer solar panel", hm.cylinder(R_OUT, X(0.0), X(skirt), n=128),
                     texture=_drum_texture(skirt, seed)))
    P.append(hm.part(kit, "outer panel inside", hm.cylinder(R_OUT - 0.008, X(0.0), X(skirt), n=96, inward=True),
                     rgb=BLACK))
    P.append(hm.part(kit, "outer panel edges", hm.annulus(R_OUT - 0.008, R_OUT, X(0.0), n=128, rows=1,
                                                          facing=-1.0), rgb=(0.10, 0.10, 0.11)))
    P.append(hm.part(kit, "panel step ring", hm.annulus(R_IN, R_OUT, X(skirt), n=128, rows=1), rgb=RED))
    P.append(hm.part(kit, "inner solar panel", hm.cylinder(R_IN, X(skirt), X(top), n=128),
                     texture=_band_texture(seed + 1)))

    # --- aft: the thermal barrier across the drum, the PAM interface ring,
    # the Star 30's nozzle (exit 0.25 m radius, recessed 0.12 m), sooty
    # inside: it has fired
    s_bar, s_exit, s_thr = 0.46, 0.12, 0.62
    r_exit, r_thr = 0.25, 0.10
    r_at = lambda s: r_exit + (r_thr - r_exit) * (s - s_exit) / (s_thr - s_exit)
    blk = hm.image(hm.blanket(256, 256, (0.03, 0.03, 0.035), seed + 2, crinkle=0.5))
    P.append(hm.part(kit, "aft thermal barrier",
                     hm.annulus(r_at(s_bar) + 0.004, R_OUT - 0.008, X(s_bar), n=96, rows=3, facing=-1.0),
                     texture=blk))
    noz_out = hm.frustum(r_exit + 0.006, r_at(s_bar) + 0.010, X(s_exit), X(s_bar) - 0.005, n=48, rows=4)
    P.append(hm.part(kit, "apogee motor nozzle", noz_out, rgb=(0.08, 0.08, 0.085)))
    noz_in = hm.frustum(r_exit, r_thr, X(s_exit), X(s_thr), n=48, rows=6)
    noz_in['nrm'] = -noz_in['nrm']                            # seen from inside the bell
    P.append(hm.part(kit, "apogee motor nozzle inside", noz_in, rgb=(0.045, 0.043, 0.042)))
    P.append(hm.part(kit, "nozzle lip", hm.annulus(r_exit, r_exit + 0.022, X(s_exit), n=48, rows=1,
                                                   facing=-1.0), rgb=(0.30, 0.30, 0.31)))
    P.append(hm.part(kit, "nozzle throat", hm.annulus(0.0, r_thr, X(s_thr), n=32, rows=1, facing=-1.0),
                     rgb=(0.015, 0.015, 0.015)))
    P.append(hm.part(kit, "PAM interface ring",
                     hm.merge(hm.cylinder(0.60, X(0.38), X(s_bar) - 0.005, n=96),
                              hm.cylinder(0.57, X(0.38), X(s_bar) - 0.005, n=96, inward=True)),
                     rgb=(0.45, 0.45, 0.46)))
    P.append(hm.part(kit, "PAM interface ring face", hm.annulus(0.57, 0.60, X(0.38), n=96, rows=1, facing=-1.0),
                     rgb=(0.40, 0.40, 0.41)))
    # the struts inside the skirt, from the PAM ring out to the drum's frame
    struts = []
    for k in range(8):
        a = math.radians(22.5 + 45 * k)
        d = np.array((0.0, math.cos(a), math.sin(a)))
        struts.append(kit.rod(np.array((X(0.40), 0, 0)) + 0.60 * d, np.array((X(0.20), 0, 0)) + 1.05 * d, 0.018, 6))
    P.append(kit.part("aft skirt struts", (0.20, 0.20, 0.21), *struts))

    # --- small things on the drum: the sun sensors, thruster fairings at the aft edge
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
    P.append(hm.part(kit, "inner panel edge", hm.annulus(R_IN - 0.006, R_IN, X(top), n=128, rows=1),
                     rgb=(0.10, 0.10, 0.11)))

    depth = 0.10
    P.append(hm.part(kit, "reflector", hm.dish(R_REFL, depth, X(rim), n=96, rows=14),
                     texture=_reflector_texture(seed + 3)))
    back = hm.dish(R_REFL - 0.004, depth, X(rim) - 0.006, n=64, rows=8)
    back['nrm'] = -back['nrm']                                # black beneath, facing aft
    P.append(hm.part(kit, "reflector back", back, rgb=BLACK))
    sil = hm.image(_foil(256, 512, SILVER, seed + 4, n=200))
    P.append(hm.part(kit, "reflector rim blanket",
                     hm.merge(hm.cylinder(R_REFL + 0.004, X(rim - 0.055), X(rim + 0.006), n=96),
                              hm.cylinder(R_REFL - 0.008, X(rim - 0.055), X(rim + 0.006), n=96, inward=True),
                              hm.annulus(R_REFL - 0.008, R_REFL + 0.004, X(rim + 0.006), n=96, rows=1)),
                     texture=sil))
    # the black strap across the reflector beside the feed (on the dish's
    # surface, stood off 5 mm)
    strap = []
    for k in range(10):
        r0, r1 = 0.20 + 0.07 * k, 0.20 + 0.07 * (k + 1)
        x0 = X(rim) - depth * (1 - (r0 / R_REFL) ** 2) + 0.006
        x1 = X(rim) - depth * (1 - (r1 / R_REFL) ** 2) + 0.006
        a = math.radians(205.0)
        d = np.array((0.0, math.cos(a), math.sin(a)))
        p0, p1 = np.array((x0, 0, 0)) + r0 * d, np.array((x1, 0, 0)) + r1 * d
        mid = 0.5 * (p0 + p1)
        L = np.linalg.norm(p1 - p0)
        strap.append(kit.along(kit.box((L, 0.003, 0.09)), p1 - p0, mid))
    P.append(kit.part("reflector strap", BLACK, *strap))

    gold = []
    gold.append(hm.with_uv(hm.cylinder(0.28, X(s_fb), X(rim - depth) - 0.008, n=40), 2.0))   # despun mast
    for a in (200.0, 320.0, 80.0):                                                       # brackets
        t = math.radians(a)
        cs = np.array((0.0, math.cos(t), math.sin(t)))
        gold.append(hm.with_uv(hm.from_kit(kit.rod(np.array((X(s_fb + 0.01), 0, 0)) + 0.96 * cs,
                                                   np.array((X(rim - 0.05), 0, 0)) + 0.86 * cs, 0.03, 8)), 3.0))
        gold.append(hm.box((0.10, 0.12, 0.12), np.array((X(rim - 0.07), 0, 0)) + 0.86 * cs, 3.0))
    # the feed assembly across the reflector: its block at the centre, the
    # boom to the rim, rising toward it, the tower at the rim end and its
    # leg down past the rim to the drum's forward edge
    xb = X(rim - depth) + 0.004                               # the dish's vertex
    gold.append(hm.box((0.34, 0.40, 0.44), (xb + 0.17, 0.0, 0.0), 2.0))
    gold.append(hm.box((0.10, 0.24, 0.30), (xb + 0.39, -0.03, 0.02), 2.0))     # its cap
    # the boom: one box from the block to the rim, its underside along the
    # dish's chord (which clears the dish) 1 cm up
    yb0, yb1, hb = 0.18, 0.93, 0.18
    xb0 = X(rim) - depth * (1 - (yb0 / R_REFL) ** 2) + 0.01
    xb1 = X(rim) + 0.01
    L = math.hypot(yb1 - yb0, xb1 - xb0)
    tilt = math.degrees(math.atan2(xb1 - xb0, yb1 - yb0))
    R = kit.rot('z', -tilt)
    up = R @ np.array((1.0, 0.0, 0.0))
    mid = np.array((0.5 * (xb0 + xb1), 0.5 * (yb0 + yb1), 0.0)) + 0.5 * hb * up
    gold.append(hm.place(hm.box((hb, L, 0.22), (0, 0, 0), 2.0), R, mid))
    gold.append(hm.box((0.30, 0.20, 0.30), (X(rim) + 0.16, 0.95, 0.0), 2.0))   # the tower
    gold.append(hm.box((X(rim) + 0.01 - X(top + 0.01), 0.07, 0.16),
                       (0.5 * (X(rim) + 0.01 + X(top + 0.01)), 1.02, 0.0), 2.0))   # its leg
    # the omni's strut: a flat gold-wrapped bar from the block out past the rim
    t = math.radians(135.0)
    d = np.array((0.0, math.cos(t), math.sin(t)))
    p0 = np.array((xb + 0.30, 0.0, 0.0)) + 0.12 * d
    p1 = np.array((X(rim + 0.38), 0.0, 0.0)) + 1.00 * d
    gold.append(hm.with_uv(hm.from_kit(kit.rod(p0, p1, 0.030, 6)), 3.0))
    goldtex = hm.image(_foil(512, 512, GOLD, seed + 5, n=120))
    P.append(hm.part(kit, "gold blankets", hm.merge(*gold), texture=goldtex))

    # waveguides along the boom (bare, silvery), on its -Z side
    xa = lambda y, h: xb0 + (xb1 - xb0) * (y - yb0) / (yb1 - yb0) + h
    P.append(kit.part("feed waveguides", (0.45, 0.44, 0.40),
                      kit.rod((xa(0.24, 0.06), 0.24, -0.128), (xa(0.92, 0.06), 0.92, -0.128), 0.018, 6),
                      kit.rod((xa(0.24, 0.12), 0.24, -0.126), (xa(0.92, 0.12), 0.92, -0.126), 0.014, 6)))

    # the omni antenna: a black cylinder on the strut's end, a pale end cap
    u = (p1 - p0) / np.linalg.norm(p1 - p0)
    P.append(kit.part("omni antenna", (0.04, 0.04, 0.045), kit.rod(p1, p1 + 0.22 * u, 0.045, 16),
                      kit.rod(p1 - 0.02 * u, p1 + 0.04 * u, 0.06, 16)))
    P.append(kit.part("omni cap", (0.40, 0.40, 0.42), kit.rod(p1 + 0.22 * u, p1 + 0.26 * u, 0.05, 16)))

    if capture:
        P += _stinger(kit, X, s_thr, seed)
    return P


def meta(name, norad, source_extra=""):
    return dict(name=name,
                frame="HS-376 stowed: +X along the spin axis toward the folded antenna; +Y toward the feed "
                      "assembly's rim end; m; origin the estimated centre of mass, 0.50 m aft of the outer "
                      "solar panel's forward edge",
                source="built from STS-51A press kit drawings and photographs (51A-46-057, 51A-104-029, "
                       "51A-39-036, 51A-18-020), Hughes factory photographs, STS-41B/41D press kit "
                       "dimensions, Gunter's Space Page" + source_extra
                       + "; procedural textures (portview/vehicles/_hs376.py)",
                norad=norad, mag_1000km=3.0)
