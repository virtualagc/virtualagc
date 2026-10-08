"""Mir's base block (DOS-7, the core module) and Kvant-1, for mir.py.

The core in its own frame: +X along its axis toward the transfer node, the
node's centre at the origin; +Y, +Z the node's radial ports' directions.
Profile (m): the node a 2.2 m sphere; the small working compartment 2.9 m
across, 3.7 m long; a 0.7 m cone; the large compartment 4.15 m across
(pressurised, then the unpressurised propulsion compartment round the aft
transfer tunnel); the aft docking port 13.13 m from the forward one.  The
same hull, DOS-8, flies as the ISS's Zvezda; NASA's Zvezda model (ISS (C),
JSC VCL) was measured for the stations along it.
"""
import math

import numpy as np

from . import kit
from . import _mir_shapes as sh
from ._mir_tks import radiators

R_NODE = 1.10
R_SMALL = 1.45
R_LARGE = 2.075
X_FWD_PORT = 1.50                 # the forward port's docking plane
X_SMALL0, X_SMALL1 = -1.95, -5.80
X_LARGE0, X_LARGE1 = -6.50, -10.55
X_AFT_PORT = X_FWD_PORT - 13.13   # the aft docking plane (Kvant-1's)
PORT_R = 1.50                     # the radial ports' docking planes from the axis


def node_ports():
    """{name: (docking-plane centre, outward direction)} in the core frame."""
    return {'fwd': (np.array([X_FWD_PORT, 0, 0]), np.array([1.0, 0, 0])),
            '+Y': (np.array([0, PORT_R, 0]), np.array([0, 1.0, 0])),
            '-Y': (np.array([0, -PORT_R, 0]), np.array([0, -1.0, 0])),
            '+Z': (np.array([0, 0, PORT_R]), np.array([0, 0, 1.0])),
            '-Z': (np.array([0, 0, -PORT_R]), np.array([0, 0, -1.0])),
            'aft': (np.array([X_AFT_PORT, 0, 0]), np.array([-1.0, 0, 0]))}


def _port_collar(a, at, d, drogue=True):
    """A passive port on the node: neck, collar and the drogue cone, its
    docking plane at `at`, facing d."""
    R = sh.frame_of(d, (0, 0, 1) if abs(d[2]) < 0.9 else (1, 0, 0))
    s = a.sub(R, at)
    base = -(np.linalg.norm(at) - 0.98)
    s.add('hull white', kit.cylinder(0.56, base, -0.18, 40, caps=False))
    s.add('metal', kit.frustum(0.66, 0.62, -0.18, -0.02, 40, caps=False))
    s.add('metal', kit.tube(0.68, 0.50, -0.02, 0.0, 40))
    if drogue:
        s.add('dark', kit.frustum(0.52, 0.14, -0.015, -0.42, 32, caps=False))
    for k in range(8):                                  # hooks round the collar
        t = math.radians(22.5 + 45 * k)
        s.add('metal', kit.box((0.06, 0.07, 0.07), (-0.05, 0.64 * math.cos(t), 0.64 * math.sin(t))))


def core(a):
    """The base block into assembly a (core frame)."""
    # ---- the transfer node: a sphere with five ports
    a.add('hull white', kit.sphere(R_NODE, 20, (0, 0, 0)))
    for name, (at, d) in node_ports().items():
        if name != 'aft':
            _port_collar(a, at, d)
    # neck from the node to the working compartment
    a.add('hull white', sh.lathe([(-0.80, 0.80), (-1.25, 0.86), (-1.70, 1.25), (X_SMALL0, R_SMALL)], 64,
                                 uv=(8, 2.0)))
    # ---- the working compartment: small, cone, large
    a.add('blanket', sh.lathe([(X_SMALL0, R_SMALL), (X_SMALL1, R_SMALL)], 64, uv=(8, 2.0)))
    a.add('blanket', sh.lathe([(X_SMALL1, R_SMALL), (X_LARGE0, R_LARGE)], 64, uv=(10, 2.0)))
    # the large compartment: its skin is the radiator (2 mm, 20 mm off the hull)
    a.add('core radiator', sh.lathe([(X_LARGE0, R_LARGE), (X_LARGE1, R_LARGE)], 72, uv=(12, 2.0)))
    for x in (X_SMALL0 - 0.05, X_SMALL1 + 0.05):
        a.add('metal', sh.ring(R_SMALL, x, 0.08, 0.025, 64))
    for x in (X_LARGE0 - 0.05, -8.6, X_LARGE1 + 0.05):
        a.add('metal', sh.ring(R_LARGE, x, 0.08, 0.025, 72))
    # the propulsion compartment's aft end: an annulus round the tunnel
    a.add('metal', kit.disc(R_LARGE, X_LARGE1 - 0.005, 72, r_in=0.75))
    a.add('dark', kit.disc(R_LARGE - 0.15, X_LARGE1 - 0.012, 72, r_in=0.80))
    for y in (-1.15, 1.15):                            # the two main engines
        a.add('dark', kit.move(kit.frustum(0.10, 0.28, X_LARGE1, X_LARGE1 - 0.55, 20), (0, y, 0)))
    # the aft transfer tunnel and Kvant-1's port
    a.add('hull white', kit.cylinder(0.75, X_LARGE1, X_AFT_PORT + 0.25, 48, caps=False))
    a.add('metal', kit.tube(0.82, 0.60, X_AFT_PORT, X_AFT_PORT + 0.25, 48))
    # attitude thruster clusters round the aft compartment
    for k in range(4):
        t = 45 + 90 * k
        a.add('metal', sh.on_hull(kit.box((0.18, 0.35, 0.30), (0.09, 0, 0)), R_LARGE, t, -10.2))
        for j in (-1, 1):
            a.add('dark', sh.on_hull(kit.move(kit.frustum(0.03, 0.06, 0.18, 0.30, 10), (0, j * 0.10, 0)),
                                     R_LARGE, t, -10.2))
    # windows round the small compartment (dark discs standing proud)
    for t, x in ((200, -2.6), (220, -3.4), (160, -3.0), (270, -4.2), (90, -4.6), (330, -2.8)):
        a.add('dark', sh.on_hull(kit.cylinder(0.12, 0.0, 0.025, 20), R_SMALL, t, x))
        a.add('metal', sh.on_hull(kit.tube(0.16, 0.12, 0.0, 0.03, 20), R_SMALL, t, x))
    # radiator panels on the large compartment (white, standing off)
    for t in (20, 160, 200, 340):
        a.add('blanket flat', sh.hull_panel(R_LARGE + 0.06, t, 22, -7.4, -8.6))
    # handrails along and round
    a.add('rail', sh.hull_rails(R_SMALL, -2.2, -5.6, (45, 135, 225, 315)))
    a.add('rail', sh.hull_rails(R_LARGE, -6.8, -10.3, (50, 130, 230, 310)))
    a.add('rail', sh.hoop_rail(R_SMALL, -2.3, 0, 350, segs=24))
    a.add('rail', sh.hoop_rail(R_LARGE, -6.9, 0, 350, segs=30))
    sh.clutter(a, R_SMALL, X_SMALL1 + 0.2, X_SMALL0 - 0.3, 26, 7, avoid=((0, 14), (180, 14), (90, 12)))
    sh.clutter(a, R_LARGE, X_LARGE1 + 0.3, X_LARGE0 - 0.2, 30, 8)


# ------------------------------------------------- the core's own wings etc.
WING_X = -3.85                   # the main wings' axis station (on the 2.9 m section)


def core_extras(a):
    """The core's wings: two sun-tracking 13.4 x 2.9 m (38 m2 each, 29.73 m
    tip to tip) along +-Y on the small section, and the fixed third, dorsal
    one (1987; 10.6 m, 22 m2) up +Z; antennas; the two Strela cranes."""
    for s in (1, -1):
        a.add('metal', kit.along(kit.cylinder(0.20, 0.0, 0.45, 16), (0, s, 0), (WING_X, s * (R_SMALL - 0.05), 0)))
        sh.solar_wing(a, (WING_X, s * (R_SMALL + 0.40), 0), (0, s, 0), (0.8, 0, 0.6), 13.4, 2.95, 10,
                      'grid', mats=dict(cells='cells aged'))
    a.add('metal', kit.along(kit.cylinder(0.15, 0.0, 0.35, 12), (0, 0, 1), (-5.0, 0, R_SMALL - 0.05)))
    sh.solar_wing(a, (-5.0, 0, R_SMALL + 0.30), (0, 0, 1), (1, -0.35, 0), 10.6, 2.0, 8, 'grid',
                  mats=dict(cells='cells aged'), mast_w=0.2)
    # Kurs and communication antennas on the node and the large compartment
    a.add('metal', kit.along(sh.kurs_antenna(1.1, 0.22), (0.5, 0.6, -0.6), (0.4, 0.7, -0.75)))
    a.add('metal', kit.along(sh.kurs_antenna(0.9, 0.18), (0.6, -0.6, 0.5), (0.3, -0.7, 0.75)))
    a.add('metal', kit.along(sh.whip(1.8), (0.0, 0.5, -1), (-9.5, 0.9, -R_LARGE + 0.05)))
    a.add('metal', kit.along(sh.whip(1.5), (0.0, -0.7, 1), (-10.0, -1.1, R_LARGE - 0.3)))
    # the high-gain dish on its boom, under the large compartment
    a.add('metal', kit.along(sh.boom_dish(0.55, 0.18, 1.6, 24), (0.0, 0.3, -1), (-8.0, 0.4, -R_LARGE + 0.05)))
    # Strela cranes: one swung out, one stowed along the hull
    for base, d, L in (((-2.3, -0.9, -1.15), (0.05, -0.75, -0.66), 9.0),
                       ((-2.3, 0.9, 1.15), (-1.0, 0.0, 0.0), 6.0)):
        b = np.array(base)
        dv = np.array(d) / np.linalg.norm(d)
        a.add('metal', kit.along(kit.cylinder(0.18, 0.0, 0.30, 12), b / np.linalg.norm(b * [0, 1, 1]) * [0, 1, 1], b))
        tip = b + np.array(b * [0, 1, 1]) / np.linalg.norm(b * [0, 1, 1]) * 0.35
        a.add('crane', kit.along(kit.cylinder(0.11, 0.0, L * 0.5, 12), dv, tip))
        a.add('crane', kit.along(kit.cylinder(0.08, L * 0.5 - 0.1, L, 12), dv, tip))
        a.add('metal', kit.box((0.25, 0.25, 0.25), tip + dv * L))


# ------------------------------------------------------------------ Kvant-1
KV1_LEN = 5.8


def kvant1(a):
    """Kvant-1 (1987) on the core's aft port: 5.8 m long, 4.15 m across, 11 t.
    In the core frame, from X_AFT_PORT aft (-X); its own aft port (Progress
    M-39 in June 1998) at X_AFT_PORT - 5.8.  Its two sun-tracking drives
    carry arrays along +-Z: the US-Russian cooperative array (MCSA, 18 x 2.7
    m, 42 folded panels) on -Z, the Russian one fitted in Nov 1997 on +Z.
    The Sofora girder (14.5 m, 20 bays) stands off it along -Y with the VDU
    thruster block at its top; the shorter Rapana truss behind it."""
    x0 = X_AFT_PORT
    r = R_LARGE
    a.add('metal', kit.tube(0.82, 0.60, x0 - 0.15, x0, 48))
    a.add('hull white', kit.cylinder(0.72, x0 - 0.55, x0 - 0.15, 48, caps=False))
    a.add('blanket', sh.lathe([(x0 - 0.55, 0.80), (x0 - 0.85, 1.6), (x0 - 1.05, r)], 64, uv=(10, 2.0)))
    a.add('metal', kit.disc(0.81, x0 - 0.545, 48, r_in=0.70))
    a.add('blanket', sh.lathe([(x0 - 1.05, r), (x0 - 4.85, r)], 64, uv=(12, 2.0)))
    a.add('blanket', sh.lathe([(x0 - 4.85, r), (x0 - 5.25, 1.5), (x0 - 5.45, 0.85)], 64, uv=(10, 2.0)))
    for x in (x0 - 1.1, x0 - 3.0, x0 - 4.8):
        a.add('metal', sh.ring(r, x, 0.08, 0.025, 64))
    xa = x0 - KV1_LEN
    a.add('hull white', kit.cylinder(0.72, xa + 0.35, x0 - 5.45, 48, caps=False))
    a.add('metal', kit.frustum(0.80, 0.74, xa + 0.35, xa + 0.02, 48, caps=False))
    a.add('metal', kit.tube(0.82, 0.55, xa, xa + 0.02, 48))
    a.add('dark', kit.frustum(0.52, 0.14, xa + 0.015, xa + 0.40, 32, caps=False))
    radiators(a, r, x0 - 1.3, x0 - 4.6, (45, 135, 225, 315), 30)
    a.add('rail', sh.hull_rails(r, x0 - 1.2, x0 - 4.7, (0, 90, 180, 270)))
    sh.clutter(a, r, x0 - 4.7, x0 - 1.2, 24, 11, avoid=((90, 12), (270, 12), (0, 8), (180, 8)))
    for k in range(4):
        t = 45 + 90 * k
        a.add('metal', sh.on_hull(kit.box((0.2, 0.3, 0.3), (0.1, 0, 0)), r, t, x0 - 4.95))
    # the array drives and arrays
    xm = x0 - 2.9
    for s in (1, -1):
        a.add('metal', kit.along(kit.cylinder(0.22, 0.0, 0.5, 16), (0, 0, s), (xm, 0, s * (r - 0.05))))
    sh.solar_wing(a, (xm, 0, -(r + 0.45)), (0, 0, -1), (1, 0.25, 0), 18.0, 2.7, 42, 'accordion',
                  mats=dict(cells='cells us'), root_gap=0.4, tilt=7)
    sh.solar_wing(a, (xm, 0, r + 0.45), (0, 0, 1), (1, 0.15, 0), 15.0, 2.6, 34, 'accordion',
                  mats=dict(cells='cells kvant1'), root_gap=0.4, tilt=7)
    # Sofora: a square lattice girder 14.5 m along -Y, the VDU on top
    xs = x0 - 1.8
    base = np.array([xs, -(r + 0.1), 0.4])
    tip = base + np.array([0, -14.5, 0])
    a.add('metal', kit.box((1.0, 0.25, 1.0), base + (0, 0.05, 0)))
    a.add('sofora', sh.truss_mesh(base, tip, 0.85, 20, 0.022, sides=4))
    a.add('vdu', kit.box((1.1, 1.3, 1.1), tip + (0, -0.65, 0)))
    for j in (-1, 1):
        a.add('dark', kit.along(kit.frustum(0.08, 0.2, 0.0, 0.45, 14), (0, 0, j), tip + (0, -0.65, j * 0.55)))
    # Rapana: a 5 m truss aft of Sofora, leaning aft (STS-79 photographs)
    b2 = np.array([x0 - 3.8, -(r + 0.05), 0.6])
    a.add('metal', kit.box((0.6, 0.2, 0.6), b2))
    a.add('sofora', sh.truss_mesh(b2, b2 + np.array([-2.5, -4.3, 0.3]), 0.55, 7, 0.02, sides=3))
    # antennas
    a.add('metal', kit.along(sh.kurs_antenna(0.9, 0.18), (-0.4, 0.7, 0.6), (xa + 0.6, 0.6, 0.6)))
    a.add('metal', kit.along(sh.whip(1.4), (-0.2, 0.5, -1), (x0 - 4.4, 0.6, -r)))
