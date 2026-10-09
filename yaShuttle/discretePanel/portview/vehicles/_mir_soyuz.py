"""Soyuz TM and Progress M, for mir.py: in a frame with +X toward the
docking probe, its tip at the origin, the body along -X, the solar wings
along +-Y.  Dimensions: Soyuz TM 7.0 m long without the probe (7.48 m
with), 2.72 m across at the instrument-assembly module's skirt, 10.6 m
across the wings; orbital module 2.26 m across, descent module 2.17 m;
Progress M 7.23 m long, its cargo module 2.2 m across, the refuelling
module 1.7 m, the same service module and wings."""
import math

import numpy as np

from . import kit
from . import _mir_shapes as sh


def _probe(a):
    """The docking probe and its collar, from x = 0 (tip) to -0.55."""
    a.add('metal', kit.frustum(0.012, 0.045, 0.0, -0.08, 12))
    a.add('metal', kit.cylinder(0.045, -0.08, -0.42, 12, caps=False))
    a.add('metal', kit.frustum(0.30, 0.08, -0.55, -0.40, 24, caps=False))
    a.add('metal', sh.ring(0.62, -0.53, 0.06, 0.03, 48))
    for k in range(4):                          # latches round the collar
        t = math.radians(45 + 90 * k)
        a.add('dark', kit.box((0.08, 0.10, 0.10), (-0.52, 0.66 * math.cos(t), 0.66 * math.sin(t))))


def _service_module(a, x0, skin, wings_rgb_key='cells'):
    """The instrument-assembly module (PAO) from x0 aft: the adapter, the
    instrument compartment, the flared propulsion compartment, engines, and
    the two wings.  Returns its aft station."""
    # the intermediate compartment: a short dark truss-like band
    a.add('dark', kit.frustum(1.00, 1.08, x0, x0 - 0.30, 48, caps=False))
    for k in range(12):
        t = math.radians(30 * k)
        p0 = np.array([x0, 1.01 * math.cos(t), 1.01 * math.sin(t)])
        p1 = np.array([x0 - 0.30, 1.09 * math.cos(t + 0.26), 1.09 * math.sin(t + 0.26)])
        a.add('metal', kit.rod(p0, p1, 0.02, 6))
    x1 = x0 - 0.30
    a.add(skin, sh.lathe([(x1, 1.09), (x1 - 0.75, 1.10)], 48, uv=(6, 1.5)))
    x2 = x1 - 0.75
    # the propulsion compartment: white (its radiator), its aft end white
    # round a darker ring and the engines
    a.add('pao white', sh.lathe([(x2, 1.10), (x2 - 0.55, 1.22), (x2 - 1.20, 1.36)], 48, uv=(6, 1.5)))
    x3 = x2 - 1.20
    a.add('pao white', kit.disc(1.36, x3 - 0.005, 48))
    a.add('metal', kit.disc(0.75, x3 - 0.012, 48, r_in=0.55))
    a.add('metal', sh.ring(1.36, x3 + 0.05, 0.10, 0.02, 48))
    # radiator strip round the instrument compartment: white panels
    for k in range(6):
        t = 60 * k + 15
        a.add('white', sh.on_hull(kit.box((0.02, 0.55, 0.45), (0.01, 0, 0)), 1.10, t, x1 - 0.38))
    # the main engine and its backup, aft
    a.add('dark', kit.frustum(0.16, 0.30, x3, x3 - 0.40, 24))
    for k in range(2):
        y = 0.55 * (1 if k else -1)
        a.add('dark', kit.move(kit.frustum(0.06, 0.12, x3, x3 - 0.18, 12), (0, y, 0.3)))
    # attitude thrusters round the skirt
    for k in range(4):
        t = 45 + 90 * k
        a.add('metal', sh.on_hull(kit.box((0.10, 0.18, 0.18), (0.05, 0, 0)), 1.30, t, x3 + 0.2))
    # the wings: root on the skirt, 1.47 m wide, 3.9 m long, four panels
    xw = x2 - 0.75
    for s in (1, -1):
        cells, backs, frames = sh.wing(3.95, 1.47, 4, root_gap=0.15, mast=False, thickness=0.03)
        R = np.diag([1.0, s, s])                 # along +-Y, cells toward +-Z
        a.add(wings_rgb_key, cells, R, (xw, s * 1.30, 0))
        a.add('panel back', backs, R, (xw, s * 1.30, 0))
        a.add('metal', frames, R, (xw, s * 1.30, 0))
        a.add('metal', kit.rod((xw, s * 1.20, 0), (xw, s * 1.45, 0), 0.04, 8))
    # a few antennas
    a.add('metal', kit.along(sh.whip(1.0), (0, 0.4, -1), (x2 - 0.3, 0.0, -1.18)))
    a.add('metal', kit.along(sh.whip(0.8), (0, -0.5, 1), (x2 - 0.2, 0.0, 1.16)))
    return x3


def soyuz_tm(a, skin='soyuz skin'):
    """A Soyuz TM into assembly a (its frame: see the module docstring)."""
    _probe(a)
    # the orbital module: a sphere with a short cylinder in it, 2.26 m across
    prof = []
    c0, c1, R = -1.55, -1.95, 1.13
    for k in range(13):
        th = math.radians(90 * k / 12)
        prof.append((c0 + R * 0.95 * math.cos(th) * 1.0, R * math.sin(th)))
    prof[0] = (prof[0][0], 0.45)
    for k in range(1, 13):
        th = math.radians(90 + 70 * k / 12)
        prof.append((c1 + R * 0.95 * math.cos(th), R * math.sin(th)))
    prof = [(min(x, -0.50), r) for x, r in prof]
    a.add(skin, sh.lathe(prof, 48, uv=(6, 1.5)))
    xs = prof[-1][0]
    # the descent module: a headlight bell, 2.17 m across
    bell = [(xs + 0.02, 0.60)]
    for k in range(1, 11):
        f = k / 10
        bell.append((xs - 1.75 * f, 0.62 + 0.465 * math.sin(f * math.pi / 2) ** 0.9))
    a.add(skin, sh.lathe(bell, 48, uv=(6, 1.5)))
    x_hs = bell[-1][0]
    a.add('dark', kit.sphere(2.4, 16, (x_hs + 2.4 - 0.3, 0, 0), (-2.4, -2.4 + 0.30)))
    # a window and the periscope on the descent module
    a.add('dark', sh.on_hull(kit.cylinder(0.11, 0.0, 0.03, 16), 0.98, 200, xs - 0.9))
    a.add('metal', sh.on_hull(kit.cylinder(0.06, 0.0, 0.20, 12), 0.92, 270, xs - 0.6))
    # orbital-module antennas: the Kurs boom and whips
    a.add('metal', kit.along(sh.kurs_antenna(0.9, 0.16), (0.3, 0.2, 1.0), (-1.0, 0.2, 1.05)))
    a.add('metal', kit.along(sh.whip(1.2), (0.6, -1, 0.3), (-1.2, -1.05, 0.2)))
    a.add('metal', kit.along(sh.whip(1.0), (0.2, 0.6, -1), (-2.3, 0.3, -1.0)))
    a.add('dark', sh.on_hull(kit.cylinder(0.12, 0.0, 0.03, 16), 1.12, 20, -1.75))     # window
    _service_module(a, x_hs - 0.05, skin)


def progress_m(a, skin='soyuz skin'):
    """A Progress M into assembly a."""
    _probe(a)
    # the cargo module: a domed cylinder, 2.2 m across, ~3.1 m long
    prof = [(-0.50, 0.45)]
    for k in range(1, 9):
        th = math.radians(90 * k / 8)
        prof.append((-0.50 - 0.65 * (1 - math.cos(th)), 0.45 + 0.65 * math.sin(th)))
    prof += [(-3.30, 1.10), (-3.55, 0.90), (-3.60, 0.85)]
    a.add(skin, sh.lathe(prof, 48, uv=(6, 1.5)))
    # the refuelling module: 1.7 m across, unpressurised, tanks inside
    a.add(skin, sh.lathe([(-3.60, 0.85), (-4.60, 0.85), (-5.10, 1.00)], 48, uv=(5, 1.5)))
    for k in range(4):
        t = 45 + 90 * k
        a.add('metal', sh.on_hull(kit.cylinder(0.05, 0.0, 0.08, 8), 0.85, t, -4.0))
        a.add('white', sh.on_hull(kit.box((0.02, 0.6, 0.5), (0.01, 0, 0)), 0.86, t + 45, -4.1))
    # Kurs antennas on the cargo module, and the docking-light/TV boom
    a.add('metal', kit.along(sh.kurs_antenna(1.1, 0.18), (0.3, 0.1, 1.0), (-1.2, 0.0, 1.10)))
    a.add('metal', kit.along(sh.kurs_antenna(0.7, 0.12), (0.3, -1.0, 0.0), (-1.0, -1.08, 0.0)))
    a.add('metal', kit.along(sh.whip(1.3), (0.5, 0.7, -1), (-2.6, 0.4, -1.0)))
    _service_module(a, -5.10, skin)
