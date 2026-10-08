"""Mir's four 20-tonne add-on modules -- Kvant-2, Kristall, Spektr and
Priroda, all built on the TKS/FGB bus (77KS) -- and the Docking Module,
for mir.py.

Each is made in its own frame: +X out from the node along the module's axis,
the docking plane at X = 0; +Y and +Z as mir.py turns them (see there).
The bus: the instrument-cargo compartment 4.1-4.35 m across next to the
node, a cone, and a 2.9 m section outboard (photographs from STS-71..91 show
the wide end at the node).  Lengths: Kvant-2 12.4 m, Kristall 11.9 m,
Spektr 14.4 m (an 8.8 m pressurised hull, then a 5.6 m unpressurised cone),
Priroda ~11.6 m; the Docking Module 4.7 m long and 2.2 m across.
"""
import math

import numpy as np

from . import kit
from . import _mir_shapes as sh


def bus(a, wide_r, wide_x, narrow_r, narrow_x, n=64, skin='blanket'):
    """The common hull: neck and docking collar at the node, a rounded
    shoulder to wide_r, a cylinder to wide_x, a cone, and the narrow
    cylinder to narrow_x.  Returns the station of the shoulder's end."""
    a.add('metal', kit.tube(0.74, 0.55, 0.0, 0.10, 48))                  # the docking collar
    a.add('metal', kit.cylinder(0.64, 0.10, 0.45, 48, caps=False))
    for k in range(8):
        t = math.radians(22.5 + 45 * k)
        a.add('metal', kit.box((0.10, 0.08, 0.08), (0.10, 0.70 * math.cos(t), 0.70 * math.sin(t))))
    sh_end = 1.55
    prof = [(0.45, 0.66), (0.70, 1.05), (1.00, 1.55), (1.30, wide_r - 0.15), (sh_end, wide_r)]
    a.add(skin, sh.lathe(prof, n, uv=(10, 2.0)))
    a.add(skin, sh.lathe([(sh_end, wide_r), (wide_x, wide_r)], n, uv=(12, 2.0)))
    cone_end = wide_x + (wide_r - narrow_r) * 0.85
    a.add(skin, sh.lathe([(wide_x, wide_r), (cone_end, narrow_r)], n, uv=(10, 2.0)))
    a.add(skin, sh.lathe([(cone_end, narrow_r), (narrow_x, narrow_r)], n, uv=(8, 2.0)))
    for x in (sh_end + 0.04, wide_x - 0.04):
        a.add('metal', sh.ring(wide_r, x, 0.07, 0.025, n))
    for x in (cone_end + 0.04, narrow_x - 0.04):
        a.add('metal', sh.ring(narrow_r, x, 0.07, 0.025, n))
    # the Lyappa arm (it swung the module from the axial port to a radial
    # one), folded against the shoulder
    a.add('metal', sh.on_hull(kit.box((0.25, 0.30, 0.30), (0.12, 0, 0)), 1.25, 90, 0.95))
    a.add('metal', kit.rod((1.05, 0, 1.40), (0.45, 0, 0.95), 0.05, 8))
    # handrails
    a.add('rail', sh.hull_rails(wide_r, sh_end + 0.3, wide_x - 0.3, (35, 145, 215, 325)))
    a.add('rail', sh.hull_rails(narrow_r, cone_end + 0.3, narrow_x - 0.3, (45, 135, 225, 315)))
    a.add('rail', sh.hoop_rail(wide_r, sh_end + 0.25, 0, 355, segs=28))
    seed = int(wide_x * 100 + narrow_x * 10)
    sh.clutter(a, wide_r, sh_end + 0.2, wide_x - 0.2, 26, seed)
    sh.clutter(a, narrow_r, cone_end + 0.2, narrow_x - 0.2, 22, seed + 1,
               avoid=((0, 10), (90, 10), (180, 10), (270, 10)))
    return sh_end, cone_end


def radiators(a, r, x0, x1, angles, width_deg=34, mat='radiator', standoff=0.04):
    """Big flat-white radiator panels on a cylinder (the photographs' boxy
    white patches), each a curved sheet with its edges turned down."""
    for t in angles:
        a.add(mat, sh.hull_panel(r + standoff, t, width_deg, x0, x1, 8))
        for e in (t - width_deg / 2, t + width_deg / 2):
            e = math.radians(e)
            d = np.array([0, math.cos(e), math.sin(e)])
            q0, q1 = np.array([x0, 0, 0]) + d * r, np.array([x1, 0, 0]) + d * r
            a.add(mat, (np.array([q0, q1, q1 + d * standoff, q0 + d * standoff]),
                        np.array([(0, 1, 2), (0, 2, 3)])))


def boxes(a, mat, specs):
    """Equipment boxes on a hull: (r, theta, x, (dx, dy, dz)) each, dx up from the hull."""
    for r, t, x, size in specs:
        a.add(mat, sh.on_hull(kit.box(size, (size[0] / 2, 0, 0)), r, t, x))


# --------------------------------------------------------------- Kvant-2
def kvant2(a):
    """Kvant-2 (1989): the airlock module, 12.4 m, 19.6 t.  Its two wings
    (each ~10 m x 2.7 m, 24 m tip to tip) along local +-Z."""
    wr, nr = 2.175, 1.45
    s0, c1 = bus(a, wr, 6.9, nr, 11.7)
    radiators(a, wr, 2.0, 6.5, (0, 90, 180, 270), 50)
    # the airlock end: a domed cap with the 1 m outward-opening EVA hatch on the side
    a.add('blanket', sh.lathe([(11.7, nr), (12.0, 1.30), (12.2, 0.9), (12.25, 0.4)], 48, uv=(8, 2.0)))
    a.add('dark', kit.disc(0.38, 12.255, 32))
    a.add('metal', sh.on_hull(kit.tube(0.62, 0.50, 0.0, 0.12, 32), nr, 90, 11.0))
    a.add('hatch', sh.on_hull(kit.cylinder(0.50, 0.04, 0.08, 32), nr, 90, 11.0))
    # the scan platform on its short truss off the end (seen in STS-91 photographs)
    a.add('array frame', kit.truss((12.25, 0, 0), (13.6, 0, 0), 0.45, 3, 0.02, 4))
    a.add('gold', kit.box((0.7, 0.9, 0.6), (13.9, 0, 0)))
    # equipment on the narrow section: boxes, the gyrodyne fairings, antennas
    boxes(a, 'blanket flat', [(nr, 200, 8.3, (0.35, 0.8, 1.2)), (nr, 340, 9.4, (0.30, 0.9, 0.9)),
                              (nr, 160, 10.2, (0.4, 0.7, 0.7)), (nr, 20, 8.9, (0.3, 0.6, 1.0))])
    boxes(a, 'blanket flat', [(wr, 45, 3.0, (0.30, 0.9, 1.4)), (wr, 225, 5.2, (0.3, 1.0, 1.0))])
    a.add('metal', kit.along(sh.kurs_antenna(1.0, 0.2), (0.3, 0.2, 1), (2.0, 0.4, wr)))
    a.add('metal', kit.along(sh.whip(1.6), (0.2, -1, -0.3), (10.5, -nr, 0)))
    a.add('metal', kit.along(sh.whip(1.2), (-0.3, 0.6, -1), (6.0, 0.6, -wr)))
    # wings, on drives at the cone's foot
    for s in (1, -1):
        a.add('metal', kit.along(kit.cylinder(0.16, 0.0, 0.40, 16), (0, 0, s), (7.9, 0, s * (nr - 0.05))))
        sh.solar_wing(a, (7.9, 0, s * (nr + 0.35)), (0, 0, s), (0.25, 1, 0), 10.2, 2.7, 9,
                      'grid', mats=dict(cells='cells aged'))


# --------------------------------------------------------------- Kristall
def kristall(a):
    """Kristall (1990): 11.9 m, 19.6 t; its docking compartment at the end
    with two APAS-89 ports (the axial one carrying the Docking Module).
    One wing left (60 % deployed since May 1995) along local +Y; the other
    went to Kvant-1 in 1995 (its drive stays, empty)."""
    wr, nr = 2.175, 1.45
    s0, c1 = bus(a, wr, 6.4, nr, 10.2)
    radiators(a, wr, 1.9, 6.0, (45, 135, 225, 315), 40)
    # the docking compartment: a cone down to 2.2 m, a short drum, the axial
    # APAS and a radial APAS (with its cover) on local -Z
    a.add('blanket', sh.lathe([(10.2, nr), (10.6, 1.12), (11.6, 1.12)], 48, uv=(8, 2.0)))
    a.add('metal', sh.ring(1.12, 11.55, 0.08, 0.03, 48))
    a.add('metal', sh.apas(11.6, 1, 0.80))
    a.add('metal', kit.disc(1.12, 11.595, 48, r_in=0.70))
    a.add('metal', kit.along(kit.cylinder(0.85, 0.0, 0.35, 40), (0, 0, -1), (11.0, 0, -0.9)))
    a.add('dark', kit.along(kit.disc(0.80, 0.0, 40), (0, 0, -1), (11.0, 0, -1.255)))
    a.add('metal', kit.along(sh.apas(0.0, 1, 0.80), (0, 0, -1), (11.0, 0, -1.25)))
    boxes(a, 'blanket flat', [(nr, 0, 8.0, (0.35, 1.0, 1.2)), (nr, 180, 8.6, (0.30, 0.9, 1.6)),
                              (nr, 120, 9.4, (0.30, 0.6, 0.8))])
    boxes(a, 'blanket flat', [(wr, 0, 2.6, (0.30, 0.8, 1.6)), (wr, 270, 4.6, (0.3, 1.0, 1.0))])
    a.add('metal', kit.along(sh.kurs_antenna(1.0, 0.2), (0.3, 1, 0.2), (2.2, wr, 0.3)))
    a.add('metal', kit.along(sh.whip(1.4), (0.1, -0.5, 1), (9.0, -0.4, nr)))
    # the remaining wing (accordion type), 60 % out of 15 m, on local +Y
    a.add('metal', kit.along(kit.cylinder(0.18, 0.0, 0.45, 16), (0, 1, 0), (7.4, nr - 0.05, 0)))
    sh.solar_wing(a, (7.4, nr + 0.45, 0), (0, 1, 0), (0.3, 0, 1), 9.0, 2.4, 22, 'accordion',
                  mats=dict(cells='cells aged'), root_gap=0.5, tilt=9)
    a.add('array frame', kit.box((2.6, 0.9, 0.55), (7.4, nr + 0.45 + 0.45, 0)))   # the retracted stack
    # the empty drive on local -Y
    a.add('metal', kit.along(kit.cylinder(0.18, 0.0, 0.45, 16), (0, -1, 0), (7.4, -nr + 0.05, 0)))
    a.add('array frame', kit.box((0.6, 0.3, 0.6), (7.4, -nr - 0.55, 0)))
    return 11.6 + 0.40                      # its axial APAS's interface plane


# ------------------------------------------------------------ Docking Module
def docking_module(a):
    """The Docking Module (STS-74, 1995): 4.7 m long, 2.2 m across, an APAS
    at each end; it carried up two solar arrays, both since moved to Kvant-1,
    so only their mounting frames and the empty containers stay.  Local X
    from its Kristall end; the free APAS at X = 4.7."""
    r = 1.10
    a.add('dm skin', sh.lathe([(0.45, 0.85), (0.75, r), (3.95, r), (4.25, 0.85)], 48, uv=(6, 1.5)))
    a.add('metal', sh.apas(0.40, -1, 0.80))
    a.add('metal', sh.apas(4.30, 1, 0.80))
    a.add('metal', kit.tube(0.88, 0.80, 0.30, 0.45, 48))
    a.add('metal', kit.tube(0.88, 0.80, 4.25, 4.40, 48))
    for x in (0.8, 2.35, 3.9):
        a.add('metal', sh.ring(r, x, 0.06, 0.02, 48))
    # the two array containers' frames (orange-brown) and the empty canisters
    for s in (1, -1):
        y = s * (r + 0.55)
        a.add('orange', kit.rod((1.2, s * r, 0.4), (1.2, y, 0.45), 0.05, 6))
        a.add('orange', kit.rod((3.6, s * r, 0.4), (3.6, y, 0.45), 0.05, 6))
        a.add('orange', kit.rod((1.2, y, 0.45), (3.6, y, 0.45), 0.05, 6))
        a.add('orange', kit.rod((1.2, s * r, -0.4), (3.6, y, 0.45), 0.04, 6))
        a.add('orange', kit.rod((1.2, y, -0.45), (3.6, y, -0.45), 0.05, 6))
        a.add('orange', kit.rod((1.2, s * r, -0.4), (1.2, y, -0.45), 0.05, 6))
        a.add('orange', kit.rod((3.6, s * r, -0.4), (3.6, y, -0.45), 0.05, 6))
        a.add('metal', kit.move(kit.cylinder(0.28, 1.4, 3.4, 20), (0, y + s * 0.30, 0)))
    a.add('rail', sh.hull_rails(r, 0.9, 3.8, (45, 135, 225, 315), 0.08))
    a.add('metal', kit.along(sh.whip(1.0), (0.2, 0.3, 1), (2.0, 0.3, r)))
    a.add('dark', sh.on_hull(kit.cylinder(0.12, 0.0, 0.02, 16), r, 270, 2.35))       # a window
    return 4.70


# ---------------------------------------------------------------- Spektr
def spektr(a):
    """Spektr (1995): 14.4 m, 19.6 t.  Two wings on the pressurised body
    along local +-Z (23.3 m tip to tip), and a V of two bigger ones (~38 m2
    each) on the unpressurised aft cone, splayed outboard.  The Progress
    M-34 collision of 25 June 1997 holed and bent the +Z body wing (its
    beams sheared) and bent another; Spektr has been sealed off since."""
    wr, nr = 2.05, 1.45
    s0, c1 = bus(a, wr, 5.6, nr, 8.8)
    # the big flat-white boxes on the wide section
    radiators(a, wr, 1.8, 5.3, (0, 180), 60)
    boxes(a, 'radiator', [(wr, 90, 2.0, (0.45, 1.6, 3.0)), (wr, 270, 2.3, (0.40, 1.4, 2.6))])
    # the unpressurised aft cone, 5.6 m, instruments on it
    a.add('gold', sh.lathe([(8.8, nr), (11.2, 1.2), (13.6, 0.75), (14.2, 0.45)], 48, uv=(6, 1.5)))
    a.add('metal', kit.disc(0.45, 14.205, 24))
    a.add('metal', kit.cylinder(0.08, 14.2, 14.9, 10))
    a.add('metal', kit.frustum(0.25, 0.05, 14.9, 15.2, 12))
    boxes(a, 'blanket flat', [(1.3, 60, 9.6, (0.5, 0.7, 0.9)), (1.25, 230, 10.4, (0.6, 0.8, 1.0)),
                              (1.0, 300, 12.0, (0.45, 0.6, 0.6)), (nr, 150, 7.6, (0.35, 0.9, 1.0))])
    a.add('metal', kit.along(sh.kurs_antenna(0.8, 0.18), (0.2, 1, 0.2), (3.5, wr, 0.4)))
    a.add('metal', kit.along(sh.whip(1.5), (0.4, -1, 0.3), (12.5, -1.0, 0.3)))
    # body wings (on drives at the narrow section), damaged one on +Z
    for s in (1, -1):
        a.add('metal', kit.along(kit.cylinder(0.16, 0.0, 0.40, 16), (0, 0, s), (6.9, 0, s * (nr - 0.05))))
    sh.solar_wing(a, (6.9, 0, nr + 0.35), (0, 0, 1), (0.2, 1, 0), 10.2, 2.7, 9, 'grid',
                  mats=dict(cells='cells aged'),
                  damage={(2, -1): 'missing', (3, -1): 'missing', (3, 1): 18, (4, -1): 32,
                          (2, 1): -10, (5, -1): 14})
    sh.solar_wing(a, (6.9, 0, -nr - 0.35), (0, 0, -1), (-0.1, 1, 0), 10.2, 2.7, 9, 'grid',
                  mats=dict(cells='cells aged'), damage={(6, 1): 8})
    # the V pair on the aft cone, each leaning 30 deg outboard; bigger
    for s, dmg in ((1, {}), (-1, {(9, 1): 25, (10, 1): 35, (10, -1): 20})):
        d = np.array([math.sin(math.radians(30)), 0, s * math.cos(math.radians(30))])
        root = np.array([11.0, 0, s * 1.15])
        a.add('metal', kit.rod(root - d * 0.2, root + d * 0.35, 0.12, 12))
        sh.solar_wing(a, root + d * 0.35, d, (0, 1, 0.15), 12.0, 3.2, 11, 'grid',
                      mats=dict(cells='cells blue'), damage=dmg)


# ---------------------------------------------------------------- Priroda
def priroda(a):
    """Priroda (1996): ~11.6 m, 19.7 t, the remote-sensing module: no
    wings; radiator panels round the wide section, a cluster of sensors on
    the outboard end, and the Travers synthetic-aperture radar's big mesh
    antenna along its side (local +Y)."""
    wr, nr = 2.05, 1.45
    s0, c1 = bus(a, wr, 6.6, nr, 10.6)
    radiators(a, wr, 1.9, 6.3, (0, 90, 180), 60)
    a.add('louvre', sh.hull_panel(wr + 0.05, 270, 70, 2.2, 6.0, 10))
    # the outboard end: a flat bulkhead crowded with sensors
    a.add('blanket', sh.lathe([(10.6, nr), (10.9, 1.40), (11.0, 1.2)], 48, uv=(8, 2.0)))
    a.add('metal', kit.disc(1.2, 11.005, 48))
    for (y, z, sx, sy, sz, mat) in ((0.5, 0.5, 0.8, 0.7, 0.6, 'blanket flat'), (-0.6, 0.4, 0.6, 0.5, 0.8, 'gold'),
                                    (0.1, -0.6, 0.7, 0.9, 0.5, 'blanket flat'), (-0.6, -0.5, 0.5, 0.4, 0.4, 'dark')):
        a.add(mat, kit.box((sx, sy, sz), (11.0 + sx / 2, y, z)))
    for (y, z) in ((0.75, -0.2), (-0.2, 0.8), (0.0, 0.0)):
        a.add('dark', kit.move(kit.cylinder(0.12, 11.0, 11.6 + 0.3 * (y == 0), 16), (0, y, z)))
    # sensor boxes on the narrow section (MOS-Obzor, Istok, ...)
    boxes(a, 'blanket flat', [(nr, 30, 8.0, (0.6, 1.0, 1.4)), (nr, 330, 9.3, (0.5, 0.9, 0.9)),
                              (nr, 200, 8.6, (0.4, 1.2, 1.0)), (nr, 150, 9.8, (0.45, 0.8, 0.8))])
    a.add('dark', sh.on_hull(kit.cylinder(0.25, 0.0, 0.25, 20), nr, 270, 9.0))
    a.add('metal', kit.along(sh.kurs_antenna(0.9, 0.18), (0.2, -1, 0.2), (2.4, -wr, 0.3)))
    a.add('metal', kit.along(sh.whip(1.4), (0.3, 0.2, -1), (8.8, 0.2, -nr)))
    # the Travers antenna: a 6 x 3 m lattice, hinged off the wide section's +Y
    # side on two arms, standing out ~1.2 m, slightly curved
    y0 = wr + 1.3
    grid = []
    nx, nz = 12, 6
    P = lambda i, j: np.array([2.0 + 6.0 * i / nx, y0 - 0.25 * math.cos(math.pi * (j / nz - 0.5)),
                               -1.5 + 3.0 * j / nz])
    for i in range(nx + 1):
        for j in range(nz):
            grid.append(kit.rod(P(i, j), P(i, j + 1), 0.012, 4))
    for j in range(nz + 1):
        for i in range(nx):
            grid.append(kit.rod(P(i, j), P(i + 1, j), 0.012, 4))
            grid.append(kit.rod(P(i, j), P(i + 1, min(j + 1, nz)), 0.008, 4))
    a.add('array frame', kit.merge(*grid))
    for x in (2.6, 7.4):
        a.add('metal', kit.rod((x, wr, 0), (x, y0 - 0.25, 0), 0.05, 8))
