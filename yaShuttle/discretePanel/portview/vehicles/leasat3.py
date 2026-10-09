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
on its mast, the two helices still folded.  GRAPPLE_BAR = True (the default)
adds the crew's grapple bar: the press kit's EVA timeline has van Hoften
"present pivot trunnions" and "install grapple bar", and the arm then
grapples that bar -- drawn here as a bar between the two pivot fittings on
one side of the drum, a standard grapple fixture at its middle.

The shape, from the press kits and photographs (51D-31-081, 51D-32-013,
51D-11-010, 51D-37-019 .. -022, 41D-02-020, STS032-87-030, 51I-S-237,
51I-102-033, and Hughes' factory photographs of the spacecraft in its
anechoic chamber):

  - the spun drum, 4.26 m in diameter (STS-41D press kit: "4.2 m across";
    Gunter: 4.26 m) and about 3.3 m long (measured off the photographs,
    side-on: 0.77-0.81 of the diameter; the stowed spacecraft is 4.29 m
    long overall -- Gunter's Space Page), its cells a dark violet-blue,
    red-orange lines between the panels: three rings round it (at about
    17, 48 and 83 % of its length from the forward rim) and the two rims,
    thin seams along it;
  - four broad red-orange rails along it, 90 deg apart, a yellow line with
    dots down each and a wider pad near the forward end: the cradle's
    attach lines.  The cradle held the spacecraft at five internal points
    -- four longeron, one keel (STS-51I press kit) -- the silvered latch
    fittings drawn on the rails;
  - two red-orange sensor panels (the "HUGHES" / "U.S. NAVY" placards, a
    sun sensor, an earth-sensor window, radiator slots above) in adjacent
    bays, each with a smaller sensor patch below it, and a cream-centred
    square;
  - the forward face: a grey blanket in gores round a raised central disc
    (the despun platform's bearing), about 1.9 m across;
  - folded flat across it, the two UHF helices -- square lattice booms
    about 0.3 m wide and 3.8 m long (Astronautix: 30 cm by 3.8 m), parallel
    about 1.25 m apart, each with its basket-like cup at the feed end
    (the end at one edge of the face) and running out past the far rim;
    between them the despun platform's dark beam, with the omni antenna
    (a white rod, a banded tip) lying along it;
  - the aft end: the solar drum runs on past the aft bulkhead as a skirt;
    inside it the bulkhead is dark, the perigee motor (the Minuteman third
    stage, STS-51D press kit) under a ragged gold blanket, a blue-grey ring
    round its nozzle and the nozzle's dark cover ("REPLACE NOZZLE COVER",
    the EVA timeline), and the two liquid engines' ports as white rings.

Body frame: +X along the spin axis toward the antennas (forward); +Y along
the folded helices, from their tips toward the cup end; +Z = X x Y.
Metres.  Origin: the estimated centre of mass on the axis, 1.3 m forward of
the aft end of the drum: the loaded solid perigee motor (some 3.5 t, in the
aft half round the axis) dominates the ~7 t spacecraft, the liquid
propellant tanks and the rest of the spun section sit about mid-drum.
"""
import math

import numpy as np

from . import _hughes_mesh as hm

KEY = 'leasat3'
OMNI_DEPLOYED = False
GRAPPLE_BAR = True

R = 2.13                 # the drum (4.26 m)
L = 3.30                 # its length
XC = 1.30                # the centre of mass, forward of the drum's aft end
AFT = 0.32               # the aft bulkhead, recessed into the skirt

CELL = (0.030, 0.024, 0.068)          # dark violet-blue cells
CELL_GAP = (0.050, 0.030, 0.050)
RED = (0.62, 0.15, 0.06)              # the red-orange lines, rails, placards
RAIL_LINE = (0.72, 0.50, 0.18)
FACE = (0.24, 0.25, 0.27)
GOLD = (0.82, 0.60, 0.22)
TRUSS = (0.13, 0.065, 0.040)
CUP = (0.40, 0.22, 0.09)
FITTING = (0.62, 0.62, 0.64)

RAILS = (0.0, 0.25, 0.5, 0.75)        # u (round the drum: 0 at +Y, 0.25 at +Z)
PANELS = (0.125, 0.375)               # the sensor panels' bays


def X(s):
    return s - XC


def drum_point(u, s, out=0.0):
    """The point on the drum's surface at u (round, 0 at +Y) and s (metres
    from its aft end), out metres proud of it; and the outward normal."""
    a = 2 * math.pi * u
    n = np.array((0.0, math.cos(a), math.sin(a)))
    return np.array((X(s), 0.0, 0.0)) + (R + out) * n, n


# ------------------------------------------------------------ the drum's skin
class _Skin:
    """Painting on the drum's image by u (0-1 round) and f (fraction of the
    length from the aft end: the image's top row is the aft end)."""

    def __init__(self, h, w):
        self.h, self.w = h, w
        self.img = self._cells()

    def _cells(self):
        h, w = self.h, self.w
        n_around, n_along = 440, 110
        rng = np.random.default_rng(381)
        yy = (np.arange(h) + 0.5) / h * n_along
        xx = (np.arange(w) + 0.5) / w * n_around
        scatter = 1.0 + 0.14 * rng.uniform(-1, 1, (n_along + 1, n_around + 1))
        s = scatter[np.floor(yy).astype(int)][:, np.floor(xx).astype(int)]
        img = s[:, :, None] * np.asarray(CELL, float)[None, None, :]
        g = ((yy % 1.0) < 0.08)[:, None] | ((xx % 1.0) < 0.06)[None, :]
        img[g] = CELL_GAP
        return img

    def rect(self, u0, f0, u1, f1, rgb):
        a, b = int(round(min(u0, u1) * self.w)), int(round(max(u0, u1) * self.w))
        r0, r1 = int(round(min(f0, f1) * self.h)), int(round(max(f0, f1) * self.h))
        b, r1 = max(b, a + 1), max(r1, r0 + 1)
        cols = np.arange(a, b) % self.w
        self.img[max(0, r0):min(self.h, r1)][:, cols] = np.asarray(rgb, float)

    def ring(self, f, width, rgb):
        self.rect(0.0, f - 0.5 * width, 1.0, f + 0.5 * width, rgb)


def _drum_texture():
    sk = _Skin(1024, 4096)
    for k in range(32):                                      # the panels' seams
        u = k / 32
        sk.rect(u - 0.0003, 0.0, u + 0.0003, 1.0, (0.30, 0.07, 0.04) if k % 2 else RED)
    for f in (0.17, 0.52, 0.83):                             # the three rings
        sk.ring(f, 0.011, RED)
    sk.rect(0.0, 0.0, 1.0, 0.008, RED)                       # the rims
    sk.rect(0.0, 0.992, 1.0, 1.0, RED)
    for u in RAILS:                                          # the cradle's rails
        sk.rect(u - 0.0055, 0.0, u + 0.0055, 1.0, RED)
        sk.rect(u - 0.0105, 0.74, u + 0.0105, 0.88, RED)       # the forward pads
        sk.rect(u - 0.0005, 0.01, u + 0.0005, 0.99, RAIL_LINE)
        for k in range(12):
            f = 0.04 + k * 0.083
            sk.rect(u - 0.0016, f - 0.006, u + 0.0016, f + 0.006, RAIL_LINE)
    for c in PANELS:                                         # the sensor panels
        sk.rect(c - 0.017, 0.60, c + 0.017, 0.885, RED)
        sk.rect(c - 0.040, 0.76, c - 0.017, 0.86, RED)
        sk.rect(c - 0.012, 0.885, c + 0.012, 0.995, RED)        # radiator slots
        for k in range(4):
            uu = c - 0.010 + k * 0.0062
            sk.rect(uu, 0.89, uu + 0.0032, 0.99, (0.035, 0.03, 0.04))
        sk.rect(c - 0.012, 0.835, c + 0.012, 0.855, (0.80, 0.78, 0.74))   # HUGHES
        sk.rect(c - 0.008, 0.615, c + 0.008, 0.630, (0.70, 0.66, 0.60))   # U.S. NAVY
        sk.rect(c - 0.008, 0.66, c + 0.008, 0.73, (0.20, 0.20, 0.21))     # earth sensor
        sk.rect(c - 0.010, 0.675, c + 0.010, 0.680, (0.45, 0.45, 0.46))
        sk.rect(c - 0.012, 0.37, c + 0.012, 0.47, RED)                    # the patch below
        sk.rect(c + 0.002, 0.39, c + 0.010, 0.395, (0.08, 0.08, 0.08))
    sk.rect(0.425, 0.33, 0.440, 0.44, RED)                   # the cream-centred square
    sk.rect(0.4295, 0.36, 0.4355, 0.41, (0.70, 0.62, 0.45))
    sk.rect(0.90, 0.60, 0.905, 0.70, RED)                    # small tabs
    sk.rect(0.62, 0.20, 0.628, 0.26, RED)
    return hm.image(sk.img)


# ----------------------------------------------------------------- shapes
def _sensor_boxes(kit):
    """The sun sensors and their mounts standing on the sensor panels."""
    m = []
    for c in PANELS:
        for (f, size) in ((0.785, (0.07, 0.10, 0.22)), (0.425, (0.05, 0.08, 0.09))):
            p, n = drum_point(c, f * L, 0.5 * size[0] + 0.004)
            a = 2 * math.pi * c
            t = np.array((0.0, -math.sin(a), math.cos(a)))
            Rm = np.column_stack([n, t, (1.0, 0.0, 0.0)])     # x out, y round, z along
            m.append(kit.move(kit.turn(kit.box((size[0], size[2], size[1])), Rm), p))
    return m


def _fitting(kit, u, s):
    """A cradle latch fitting on a rail: a block with a pin."""
    p, n = drum_point(u, s, 0.035)
    a = 2 * math.pi * u
    t = np.array((0.0, -math.sin(a), math.cos(a)))
    Rm = np.column_stack([n, t, (1.0, 0.0, 0.0)])
    block = kit.turn(kit.box((0.07, 0.15, 0.20)), Rm)
    pin = kit.rod(np.zeros(3), 0.10 * n, 0.028, 10)
    return [kit.move(block, p), kit.move(pin, p + 0.03 * n)]


def _grapple_bar(kit):
    """The 51-I grapple bar across the two pivot fittings on the +Z rail,
    a grapple fixture at its middle: [(name, rgb, mesh)]."""
    u = 0.25
    s0, s1 = 0.12 * L, 0.80 * L
    p0, n = drum_point(u, s0, 0.20)
    p1, _ = drum_point(u, s1, 0.20)
    f0, _ = drum_point(u, s0, 0.10)
    f1, _ = drum_point(u, s1, 0.10)
    bar = [kit.rod(p0 - (0.05, 0, 0), p1 + (0.05, 0, 0), 0.04, 8),
           kit.rod(f0, p0, 0.03, 8), kit.rod(f1, p1, 0.03, 8),
           kit.move(kit.box((0.14, 0.14, 0.10)), f0 + 0.03 * n),
           kit.move(kit.box((0.14, 0.14, 0.10)), f1 + 0.03 * n)]
    mid = 0.5 * (p0 + p1) + 0.04 * n
    # a grapple fixture standing out along n (+Z here): base, shaft, cam tip
    base = kit.box((0.36, 0.36, 0.025), mid + 0.0125 * n)
    shaft = kit.rod(mid, mid + 0.36 * n, 0.035, 12)
    collar = kit.rod(mid, mid + 0.06 * n, 0.11, 16)
    tip = kit.box((0.10, 0.02, 0.04), mid + 0.34 * n)
    post = kit.rod(mid + (0.13, 0, 0), mid + (0.13, 0, 0) + 0.40 * n, 0.012, 8)
    disc = kit.rod(mid + (0.13, 0, 0) + 0.395 * n, mid + (0.13, 0, 0) + 0.40 * n, 0.065, 16)
    return [("grapple bar", (0.70, 0.70, 0.72), kit.merge(*bar)),
            ("grapple fixture", (0.55, 0.55, 0.57), kit.merge(base, shaft, collar, tip)),
            ("grapple target", (0.85, 0.85, 0.85), disc),
            ("grapple target post", (0.03, 0.03, 0.03), post)]


def _gold_blanket(x0):
    """The perigee motor's blanket: a ragged, crinkled ring of gold from the
    nozzle out to about 1.1 m, bulging aft; flat-shaded so its facets catch
    the light."""
    rng = np.random.default_rng(7)
    na, nr = 72, 7
    harm = [(k, rng.uniform(0.02, 0.07) / k ** 0.5, rng.uniform(0, 2 * math.pi)) for k in range(2, 9)]
    pos, uv = [], []
    for i in range(nr + 1):
        t = i / nr
        for j in range(na + 1):
            a = 2 * math.pi * j / na
            rout = 1.10 + sum(A * math.sin(k * a + ph) for k, A, ph in harm)
            r = 0.44 + (rout - 0.44) * t
            jitter = 0.0 if j in (0, na) else rng.uniform(-0.025, 0.025)
            x = x0 - 0.010 - 0.13 * (1 - t * t) + jitter * (0.3 + t)
            if i == nr:
                x = x0 - 0.008
            pos.append((x, r * math.cos(a), r * math.sin(a)))
            uv.append((0.5 + 0.5 * r * math.cos(a) / 1.2, 0.5 + 0.5 * r * math.sin(a) / 1.2))
    m = na + 1
    idx = []
    for i in range(nr):
        for j in range(na):
            a, b, c, d = i * m + j, i * m + j + 1, (i + 1) * m + j + 1, (i + 1) * m + j
            idx += [(a, c, d), (a, b, c)]        # facing aft (-X)
    return np.array(pos), np.array(idx), np.array(uv, np.float32)


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
    # --- the drum: outside, the skirt's inside and its aft lip
    P.append(hm.part(kit, "solar drum", hm.cylinder(R, X(0.0), X(L), n=192), texture=_drum_texture()))
    P.append(hm.part(kit, "skirt inside", hm.cylinder(R - 0.012, X(0.0), X(AFT + 0.01), n=96, inward=True),
                     rgb=(0.035, 0.035, 0.045)))
    P.append(hm.part(kit, "skirt lip", hm.annulus(R - 0.012, R, X(0.0), n=96, rows=1, facing=-1.0),
                     rgb=RED))

    # --- the forward face
    face = hm.image(hm.gores(1024, 16, FACE, (0.15, 0.15, 0.16), 0.446, (0.32, 0.33, 0.32), 51))
    P.append(hm.part(kit, "forward blanket", hm.annulus(0.95, R, X(L), n=128, rows=4, scale=R), texture=face))
    P.append(hm.part(kit, "despun bearing", hm.merge(hm.cylinder(0.95, X(L), X(L + 0.08), n=96),
                                                      hm.annulus(0.0, 0.95, X(L + 0.08), n=96, rows=3, scale=R)),
                     texture=face))

    # --- the aft bulkhead, the perigee motor and the liquid engines
    aft = hm.image(hm.blanket(512, 512, (0.035, 0.045, 0.075), 52, crinkle=0.25))
    P.append(hm.part(kit, "aft bulkhead", hm.annulus(0.40, R - 0.012, X(AFT), n=128, rows=4, facing=-1.0),
                     texture=aft))
    gp, gi, guv = _gold_blanket(X(AFT))
    gold = hm.image(hm.blanket(512, 512, GOLD, 53, crinkle=0.9, cells=(14, 14)))
    P.append(kit.part("perigee motor blanket", (1.0, 1.0, 1.0), (gp, gi), texture=gold, uv=guv))
    P.append(hm.part(kit, "nozzle ring", hm.merge(hm.cylinder(0.66, X(AFT - 0.20), X(AFT - 0.11), n=64),
                                                   hm.cylinder(0.58, X(AFT - 0.20), X(AFT - 0.11), n=64, inward=True),
                                                   hm.annulus(0.58, 0.66, X(AFT - 0.20), n=64, rows=1,
                                                              facing=-1.0)),
                     rgb=(0.36, 0.42, 0.52)))
    P.append(hm.part(kit, "perigee motor nozzle", hm.frustum(0.36, 0.43, X(AFT - 0.01), X(-0.12), n=48, rows=2),
                     rgb=(0.06, 0.06, 0.07)))
    P.append(hm.part(kit, "nozzle cover", hm.annulus(0.0, 0.43, X(-0.12), n=48, rows=2, facing=-1.0),
                     rgb=(0.025, 0.028, 0.035)))
    ports, holes = [], []
    for a in (40.0, 215.0):
        t = math.radians(a)
        c = np.array((0.0, 1.62 * math.cos(t), 1.62 * math.sin(t)))
        ports.append(kit.move(kit.tube(0.15, 0.125, X(AFT - 0.03), X(AFT), n=24), c))
        holes.append(kit.move(kit.disc(0.126, X(AFT - 0.006), n=24), c))
    P.append(kit.part("liquid engine ports", (0.70, 0.70, 0.72), *ports))
    P.append(kit.part("liquid engine throats", (0.02, 0.02, 0.02),
                      *[(p, t[:, ::-1]) for p, t in holes]))       # facing aft

    # --- on the drum: sensors, the cradle's latch fittings
    P.append(kit.part("sun sensors", (0.62, 0.62, 0.64), *_sensor_boxes(kit)))
    fit = []
    for u, fs in ((0.25, (0.12, 0.80)), (0.75, (0.12, 0.80)), (0.5, (0.50,)), (0.0, (0.80,))):
        for f in fs:
            fit += _fitting(kit, u, f * L)
    P.append(kit.part("latch fittings", FITTING, *fit))
    if GRAPPLE_BAR:
        for name, rgb, m in _grapple_bar(kit):
            P.append(kit.part(name, rgb, m))

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
                                "1.3 m forward of the drum's aft end",
                          source="built from STS-51D/51I/41D press kits and photographs (51D-31-081, 51D-32-013, "
                                 "51D-11-010, 51D-37-019..022, 41D-02-020, STS032-87-030, 51I-S-237), Hughes "
                                 "factory photographs, Gunter's Space Page, Astronautix "
                                 "(portview/vehicles/leasat3.py)",
                          norad=15643, mag_1000km=2.0),
                parts=P)
