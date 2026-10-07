#!/usr/bin/env python3
"""PORTVIEW: the views out of the Orbiter's windows.

    python3 portview.py [--views front,up,left,right] [--size N] [--crop]
                        [--geometry VIEW=WxH+X+Y ...] [--port-base N]
                        [--test [lvlh | RA,DEC | BODY]] [--test-date UTC]
                        [--snapshot PREFIX]

One window per selected view, all in one process, sharing one set of GL
textures.  The plan, and what is still to come (Sun, Moon, planets, Earth,
LEO objects, and later ascent and entry), is in PORTVIEW_PLAN.md.

DATA.  yaGPC2's vehicle dynamics (YAGPC_VEHDYN=1) multicasts its truth state
as "TRU1" and big-endian doubles on port base + 98, one datagram per 0.05 s of
VEHICLE time: [0] vehicle t, [1] PASS GMT, [2-5] quaternion body -> M50
(w x y z), [6-8] body rates (rad/s), [9-11] M50 position (m), [12-14] M50
velocity (m/s), [15] main-wheel height (ft), [16] ground speed (kt), and in
newer builds [17] Unix time (-1 until set) and [18-26] the M50 -> Earth-fixed
rotation, row-major.  The views show the truth -- where the vehicle IS --
not PASS's navigated state.  Between datagrams the state is extrapolated, on
a vehicle clock locked to the datagrams' own time stamps, with the velocity
(and gravity) and the body rates, so the picture moves smoothly at the display
rate; when the vehicle is paused or restoring, nothing arrives and the
picture holds.

FRAMES.  Body: X forward, Y right, Z down.  M50: mean equator and equinox of
B1950, PASS's inertial frame; J2000 vectors are taken into it with the matrix
yaGPC2's star trackers use (src/startrk.c), so the two agree.

THE SKY.  Two layers, both from real catalogues (prepared once by
portview/fetch_assets.py into portview/cache/):
  - the diffuse light of the Milky Way, NASA SVS 4851 "Deep Star Maps 2020"
    with the Hipparcos and Tycho-2 stars removed: a plate carree map in J2000
    RA and Dec, centred on 0h, RA increasing to the left, in linear radiance;
  - the ~118,000 Hipparcos stars as points, brightness by V magnitude and
    colour by B-V, carried to the flight's date by their proper motions.
    Points stay sharp at any field of view, as a texture's stars cannot.
THE SUN, MOON AND PLANETS.  JPL's DE440s ephemeris (1849-2150) through
Skyfield, at the Unix time in TRU1 [17] (until yaGPC2 sends it, they are
hidden and the status line says NO DATE), seen from the Orbiter itself (the
Moon's parallax from LEO is up to a degree), at their true angular sizes:
  - the Sun, a white disk far brighter than anything else;
  - the Moon, portview/moon.jpg (north up, the near side), its phase and the
    tilt of its terminator from the Sun's direction, lit by the Lommel-
    Seeliger law, dimmed and reddened by the Earth's shadow in a lunar
    eclipse, with earthshine on the night side.  It is shown as an eye
    adapted to it sees it, keeping its markings at any exposure;
  - Venus, Mars, Jupiter and Saturn as points like the stars (they are under
    a pixel), by their magnitudes, in Ron's colours.
The Moon passes in front of the Sun; the Earth (to come) in front of all.
Light is added up linearly in a floating-point buffer per view and only then
clipped and encoded for the screen, so exposure is one physical factor.  How
the sky "looks" from orbit is a matter of exposure (the eye's adaptation):
--exposure and --milkyway set it, and the keys below change it live.

SIZE.  --size N scales every window as panelO6.py does: 768 is full size,
384 half.  Resizing a window (by --size or by dragging) scales the view, which
keeps its field of view; with --crop it keeps its angle per pixel instead,
so a bigger window shows more sky.

Keys: + / - exposure up / down 1/3 stop; ] / [ the Milky Way's brightness
relative to the stars; H the status line (with the settings); Q or Esc quit.
"""
import argparse
import math
import os
import socket
import struct
import sys
import time

import numpy as np

from PyQt6 import QtCore, QtGui, QtWidgets
from PyQt6.QtCore import Qt
from PyQt6.QtOpenGLWidgets import QOpenGLWidget

try:
    from OpenGL import GL
except ImportError as e:
    print("portview: a module it needs is missing (%s).\n"
          "  pip install PyOpenGL" % e.name)
    sys.exit(1)

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "portview", "cache")
MILKYWAY = os.path.join(CACHE, "milkyway_8k.npy")
HIPPARCOS = os.path.join(CACHE, "hipparcos.npy")
DE440S = os.path.join(CACHE, "de440s.bsp")
MOON_IMAGE = os.path.join(HERE, "portview", "moon.jpg")

FULL_SIZE = 768                    # --size units: 768 is the design (full) window
MCAST_GROUP = "239.255.1.1"
TRUTH_OFFSET = 98
TRUTH_DOUBLES_MIN = 15
TRUTH_DOUBLES_MAX = 27
STALE_S = 2.0                      # wall seconds without truth before "STALE"
MU_EARTH = 3.986004418e14          # m^3/s^2, only for extrapolating ~0.05 s

D2R = math.pi / 180.0

# J2000 -> M50 (B1950), exactly yaGPC2's src/startrk.c J2000_TO_B1950.
J2000_TO_M50 = np.array([
    [0.9999256782, 0.0111820610, 0.0048579479],
    [-0.0111820611, 0.9999374784, -0.0000271474],
    [-0.0048579477, -0.0000271765, 0.9999881997]])

UNIX_J2000 = 946728000.0          # 2000-01-01 12:00 TT, near enough for stars


def _dir(az, el):
    """Body-frame unit vector at azimuth az (deg, right of the nose) and
    elevation el (deg, above the body X-Y plane; body Z is down)."""
    a, e = az * D2R, el * D2R
    return (math.cos(e) * math.cos(a), math.cos(e) * math.sin(a), -math.sin(e))


# The views.  'fwd' is the line of sight and 'up' the top of the picture, in
# body axes; 'w' x 'h' the window in logical pixels at --size 768, and 'hfov'
# its horizontal field of view (deg) at that size.
#   front: the forward windows.
#   up:    the overhead windows W7/W8, as seen from the aft station facing aft
#          (top of the picture toward the nose).
#   left, right: the commander's and pilot's side windows W1/W6, looking
#          outward, a little forward and down.  PROVISIONAL angles, to be
#          taken from Orbiter drawings.
VIEWS = {
    'front': dict(title="Forward windows", fwd=(1, 0, 0), up=(0, 0, -1),
                  w=1536, h=864, hfov=40.0),
    'up': dict(title="Overhead windows", fwd=(0, 0, -1), up=(1, 0, 0),
               w=1152, h=864, hfov=40.0),
    'left': dict(title="Left side window", fwd=_dir(-75, -10), up=(0, 0, -1),
                 w=1152, h=864, hfov=40.0),
    'right': dict(title="Right side window", fwd=_dir(75, -10), up=(0, 0, -1),
                  w=1152, h=864, hfov=40.0),
}


def unit(v):
    v = np.asarray(v, float)
    return v / np.linalg.norm(v)


def view_basis(spec):
    """Camera -> body: columns right, up, line of sight."""
    f = unit(spec['fwd'])
    u = unit(np.asarray(spec['up'], float) - np.dot(spec['up'], f) * f)
    r = np.cross(f, u)
    return np.column_stack([r, u, f])


# --------------------------------------------------------------------------
# Quaternions: [w x y z], body -> M50, as in TRU1.

def quat_to_matrix(q):
    w, x, y, z = q
    return np.array([
        [1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
        [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
        [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]])


def matrix_to_quat(m):
    t = m[0, 0] + m[1, 1] + m[2, 2]
    if t > 0:
        s = 2.0 * math.sqrt(1.0 + t)
        q = [0.25 * s, (m[2, 1] - m[1, 2]) / s, (m[0, 2] - m[2, 0]) / s,
             (m[1, 0] - m[0, 1]) / s]
    else:
        i = int(np.argmax([m[0, 0], m[1, 1], m[2, 2]]))
        j, k = (i + 1) % 3, (i + 2) % 3
        s = 2.0 * math.sqrt(1.0 + m[i, i] - m[j, j] - m[k, k])
        q = [0.0, 0.0, 0.0, 0.0]
        q[0] = (m[k, j] - m[j, k]) / s
        q[1 + i] = 0.25 * s
        q[1 + j] = (m[j, i] + m[i, j]) / s
        q[1 + k] = (m[k, i] + m[i, k]) / s
    q = np.array(q)
    return q / np.linalg.norm(q)


def quat_mul(a, b):
    w1, x1, y1, z1 = a
    w2, x2, y2, z2 = b
    return np.array([w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2,
                     w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
                     w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2,
                     w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2])


def quat_advance(q, w_body, dt):
    """q (body -> M50) after turning at body rates w_body for dt."""
    w = np.asarray(w_body, float)
    a = np.linalg.norm(w) * dt
    if a < 1e-12:
        return np.asarray(q, float)
    ax = w / np.linalg.norm(w)
    dq = np.concatenate([[math.cos(a / 2)], ax * math.sin(a / 2)])
    return quat_mul(q, dq)


# --------------------------------------------------------------------------
# The truth state.

class Truth(object):
    """One TRU1 datagram."""
    __slots__ = ('t', 'gmt', 'q', 'w', 'r', 'v', 'unix', 'm50_to_ef')

    @classmethod
    def parse(cls, d):
        if len(d) < 4 + 8 * TRUTH_DOUBLES_MIN or d[:4] != b"TRU1":
            return None
        n = min((len(d) - 4) // 8, TRUTH_DOUBLES_MAX)
        v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
        s = cls()
        s.t, s.gmt = v[0], v[1]
        s.q = np.array(v[2:6])
        s.w = np.array(v[6:9])
        s.r = np.array(v[9:12])
        s.v = np.array(v[12:15])
        s.unix = v[17] if n > 17 and v[17] >= 0 else None
        s.m50_to_ef = np.array(v[18:27]).reshape(3, 3) if n >= 27 else None
        return s


class VehicleClock(object):
    """Vehicle time now, from the datagrams' own vehicle time stamps.

    The target is a least-squares line, vehicle time against wall time, through
    the last FIT_S of datagrams, which averages out their arrival jitter.  The
    time shown follows the target at the fitted rate, speeding up or slowing
    down by at most SLEW of it to close any gap, so the picture never jerks.
    A jump (restore, a new run, time going backward) resets it, and it never
    runs more than HOLD_S of vehicle time past the newest datagram, so a
    paused vehicle holds still."""
    FIT_S = 3.0
    RESET_S = 0.5
    HOLD_S = 0.12
    SLEW = 0.1

    def __init__(self):
        self.pts = []              # (wall, vehicle t)
        self.a = self.rate = None  # target(wall) = a + rate * wall
        self.last_t = None
        self.shown = self.shownAt = None

    def _reset(self):
        self.pts = []
        self.a = self.rate = None
        self.shown = None

    def datagram(self, t, wall):
        if self.last_t is not None and (t < self.last_t or t - self.last_t > 5.0
                                        or (self.rate is not None and
                                            abs(t - self.a - self.rate * wall) > self.RESET_S)):
            self._reset()
        self.last_t = t
        self.pts.append((wall, t))
        while wall - self.pts[0][0] > self.FIT_S:
            self.pts.pop(0)
        n = len(self.pts)
        if n < 2:
            self.a, self.rate = t - wall, (self.rate or 1.0)
            return
        w0 = self.pts[0][0]
        sw = sum(p[0] - w0 for p in self.pts) / n
        st = sum(p[1] for p in self.pts) / n
        cov = sum((p[0] - w0 - sw) * (p[1] - st) for p in self.pts)
        var = sum((p[0] - w0 - sw) ** 2 for p in self.pts)
        if var > 1e-6 and wall - w0 > 0.2:
            self.rate = max(0.0, cov / var)
        self.a = st - self.rate * (sw + w0)

    def now(self, wall):
        if self.a is None:
            return None
        target = min(self.a + self.rate * wall, self.last_t + self.HOLD_S)
        if self.shown is None or abs(target - self.shown) > self.RESET_S:
            self.shown, self.shownAt = target, wall
            return target
        dw = wall - self.shownAt
        step = self.rate * dw
        gap = target - (self.shown + step)
        lim = self.SLEW * step
        step += max(-lim, min(lim, gap))
        hold = max(self.shown, self.last_t + self.HOLD_S)
        self.shown, self.shownAt = min(self.shown + max(0.0, step), hold), wall
        return self.shown


class FrameState(object):
    """Everything a frame is drawn from, once per tick for all the views."""
    __slots__ = ('ok', 'stale', 't', 'gmt', 'unix', 'C', 'r', 'v', 'r_j2k',
                 'm50_to_ef', 'sky')

    def __init__(self):
        self.ok = False
        self.stale = False
        self.sky = None                # SkyBodies, when the date is known


def extrapolate(s, t):
    """The state of datagram s carried forward to vehicle time t."""
    dt = t - s.t
    fs = FrameState()
    fs.ok = True
    fs.t = t
    fs.gmt = s.gmt + dt
    fs.unix = None if s.unix is None else s.unix + dt
    rn = np.linalg.norm(s.r)
    g = -MU_EARTH * s.r / rn ** 3 if rn > 1e6 else np.zeros(3)
    fs.r = s.r + s.v * dt + 0.5 * g * dt * dt
    fs.v = s.v + g * dt
    fs.r_j2k = J2000_TO_M50.T @ fs.r
    fs.C = quat_to_matrix(unit(quat_advance(s.q, s.w, dt)))     # body -> M50
    fs.m50_to_ef = s.m50_to_ef
    return fs


def mcast_socket(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    s.bind(('', port))
    iface = os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton(MCAST_GROUP) + socket.inet_aton(iface))
    s.setblocking(False)
    return s


class TruthFeed(QtCore.QObject):
    """TRU1 from yaGPC2, read as each datagram arrives."""

    def __init__(self, port_base):
        super().__init__()
        self.port = port_base + TRUTH_OFFSET
        self.sock = mcast_socket(self.port)
        self.latest = None
        self.latestAt = -1e9
        self.clock = VehicleClock()
        self.notifier = QtCore.QSocketNotifier(
            self.sock.fileno(), QtCore.QSocketNotifier.Type.Read, self)
        self.notifier.activated.connect(self._read)

    def _read(self, *_):
        while True:
            try:
                d = self.sock.recv(1024)
            except (BlockingIOError, OSError):
                break
            s = Truth.parse(d)
            if s is not None:
                wall = time.monotonic()
                self.clock.datagram(s.t, wall)
                self.latest, self.latestAt = s, wall

    def describe(self):
        return "port %d" % self.port

    def state(self):
        wall = time.monotonic()
        t = self.clock.now(wall)
        if self.latest is None or t is None:
            return FrameState()
        fs = extrapolate(self.latest, t)
        fs.stale = wall - self.latestAt > STALE_S
        return fs


class TestFeed(TruthFeed):
    """No yaGPC2: a synthetic 400 km, 51.6 deg circular orbit, sent through
    the same datagram, clock and extrapolation path as the real feed.

    mode 'lvlh': nose along the velocity, belly to the Earth.
    mode (ra, dec): inertial hold, nose at that J2000 direction (deg) and
    the top of the forward view toward the celestial north pole.
    mode 'sun', 'moon', 'venus', ...: the same, at that body's direction from
    the Earth's centre at the start."""
    PERIOD_S = 0.05

    def __init__(self, mode, rate=1.0, unix0=None, ephemeris=None):
        QtCore.QObject.__init__(self)
        self.unix0 = time.time() if unix0 is None else unix0
        if isinstance(mode, str) and mode != 'lvlh':
            d = unit(ephemeris.at(self.unix0).pos[mode])
            mode = (math.degrees(math.atan2(d[1], d[0])) % 360.0,
                    math.degrees(math.asin(d[2])))
        self.mode = mode
        self.rate = rate
        self.latest = None
        self.latestAt = -1e9
        self.clock = VehicleClock()
        self.R = 6378137.0 + 400e3
        self.n = math.sqrt(MU_EARTH / self.R ** 3)
        self.inc = 51.6 * D2R
        self.t = 0.0
        self.timer = QtCore.QTimer(self)
        self.timer.setTimerType(Qt.TimerType.PreciseTimer)
        self.timer.timeout.connect(self._send)
        self.timer.start(int(round(1000 * self.PERIOD_S / rate)))
        self._send()

    def describe(self):
        return "test orbit"

    def _orbit(self, t):
        u = self.n * t
        P = np.array([1.0, 0.0, 0.0])
        Q = np.array([0.0, math.cos(self.inc), math.sin(self.inc)])
        r = self.R * (math.cos(u) * P + math.sin(u) * Q)
        v = self.R * self.n * (-math.sin(u) * P + math.cos(u) * Q)
        return r, v

    def _attitude(self, t):
        if self.mode == 'lvlh':
            r, v = self._orbit(t)
            z = -unit(r)
            y = unit(np.cross(v, r))
            return np.column_stack([np.cross(y, z), y, z])
        ra, dec = self.mode
        j = np.array([math.cos(dec * D2R) * math.cos(ra * D2R),
                      math.cos(dec * D2R) * math.sin(ra * D2R),
                      math.sin(dec * D2R)])
        x = unit(J2000_TO_M50 @ j)
        north = J2000_TO_M50 @ np.array([0.0, 0.0, 1.0])
        z = -unit(north - np.dot(north, x) * x)
        return np.column_stack([x, np.cross(z, x), z])

    def _send(self):
        t = self.t
        r, v = self._orbit(t)
        C = self._attitude(t)
        h = 1e-3
        dC = (self._attitude(t + h) - self._attitude(t - h)) / (2 * h)
        W = C.T @ dC                                   # skew(w), body rates
        w = np.array([W[2, 1], W[0, 2], W[1, 0]])
        th = 7.2921159e-5 * (self.unix0 + t) % (2 * math.pi)   # test only
        m50_to_ef = np.array([[math.cos(th), math.sin(th), 0],
                              [-math.sin(th), math.cos(th), 0], [0, 0, 1]])
        vals = ([t, t] + list(matrix_to_quat(C)) + list(w) + list(r) + list(v)
                + [0.0, 0.0, self.unix0 + t] + list(m50_to_ef.ravel()))
        s = Truth.parse(b"TRU1" + struct.pack(">27d", *vals))
        wall = time.monotonic()
        self.clock.datagram(s.t, wall)
        self.latest, self.latestAt = s, wall
        self.t += self.PERIOD_S


# --------------------------------------------------------------------------
# The Sun, Moon and planets: JPL DE440s through Skyfield, geocentric J2000
# (ICRF), apparent from the Earth's centre (light time).  Refreshed every
# REFRESH_S of vehicle time and carried between refreshes by their velocities;
# each frame then takes them to the Orbiter (the Moon's parallax from LEO is up
# to a degree).

R_SUN = 6.957e8
R_MOON = 1.7374e6
R_EARTH = 6378137.0

# Ron's colours (PortviewThoughts.md), sRGB.
PLANETS = (('venus', 'venus', 0xFAF6E8), ('mars', 'mars barycenter', 0xD47A4A),
           ('jupiter', 'jupiter barycenter', 0xE3D5C1),
           ('saturn', 'saturn barycenter', 0xEADAA2))


def srgb_hex_to_linear(h):
    c = np.array([(h >> 16) & 255, (h >> 8) & 255, h & 255]) / 255.0
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


class SkyBodies(object):
    """Geocentric J2000 positions (m) of the Sun, Moon and planets, and the
    planets' magnitudes, at a Unix time."""
    __slots__ = ('pos', 'mag')


class Ephemeris(object):
    REFRESH_S = 1.0

    def __init__(self, path):
        from skyfield.api import load
        from skyfield.magnitudelib import planetary_magnitude
        self._mag = planetary_magnitude
        self.ts = load.timescale(builtin=True)
        self.eph = load(path)
        self.earth = self.eph['earth']
        self.names = [('sun', 'sun'), ('moon', 'moon')] + [(n, b) for n, b, _ in PLANETS]
        self.t0 = None

    def _refresh(self, unix):
        t = self.ts.utc(1970, 1, 1, 0, 0, unix)
        e = self.earth.at(t)
        self.p0, self.v0, self.mag = {}, {}, {}
        for name, body in self.names:
            a = e.observe(self.eph[body])
            self.p0[name] = np.array(a.position.m)
            self.v0[name] = np.array(a.velocity.m_per_s)
            if name not in ('sun', 'moon'):
                self.mag[name] = float(self._mag(a))
        self.t0 = unix

    def at(self, unix):
        if self.t0 is None or abs(unix - self.t0) > self.REFRESH_S:
            self._refresh(unix)
        dt = unix - self.t0
        b = SkyBodies()
        b.pos = {n: self.p0[n] + self.v0[n] * dt for n in self.p0}
        b.mag = self.mag
        return b


# --------------------------------------------------------------------------
# GL resources shared by every view (one share group:
# Qt.ApplicationAttribute.AA_ShareOpenGLContexts).  Programs, textures and
# buffers are shared; vertex arrays and framebuffers are per view.

FULLSCREEN_VS = """
#version 410 core
out vec2 vNdc;
void main() {
    vec2 p = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
    vNdc = p * 2.0 - 1.0;
    gl_Position = vec4(vNdc, 0.0, 1.0);
}
"""

# The Milky Way's diffuse light, in linear radiance, into the view's
# floating-point buffer.
MILKYWAY_FS = """
#version 410 core
in vec2 vNdc;
out vec4 fragColor;
uniform sampler2D uMap;
uniform mat3 uCamToJ2k;     // camera (right, up, line of sight) -> J2000
uniform vec2 uTan;          // tan of the half fields of view
uniform float uGain;
const float PI = 3.14159265358979;
void main() {
    vec3 d = normalize(uCamToJ2k * vec3(vNdc * uTan, 1.0));
    float ra = atan(d.y, d.x);
    float dec = asin(clamp(d.z, -1.0, 1.0));
    vec2 uv = vec2(0.5 - ra / (2.0 * PI), 0.5 - dec / PI);
    // Gradients taken across the RA = 12h seam would pick the smallest mip
    // level for one column of pixels; unwrap them.
    vec2 gx = dFdx(uv), gy = dFdy(uv);
    gx.x -= round(gx.x);
    gy.x -= round(gy.x);
    fragColor = vec4(textureGrad(uMap, uv, gx, gy).rgb * uGain, 1.0);
}
"""

# Stars as points.  A star of magnitude uMagRef (at the current exposure)
# just fills its core pixel; fainter ones are dimmer, brighter ones grow, as
# the eye and a camera see them.
STARS_VS = """
#version 410 core
in vec3 aDir;               // J2000 unit vector
in float aMag;
in vec3 aCol;               // linear colour, luminance ~1
uniform mat3 uJ2kToCam;
uniform vec2 uTan;
uniform float uMagRef;
uniform float uCore;        // core radius, physical pixels
uniform float uCut;         // relative brightness below which a star is skipped
out vec3 vCol;
void main() {
    vec3 d = uJ2kToCam * aDir;
    float L = pow(10.0, -0.4 * (aMag - uMagRef));
    if (d.z <= 0.0 || L < uCut) {
        gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
        gl_PointSize = 0.0;
        return;
    }
    gl_Position = vec4(d.xy / d.z / uTan, 0.0, 1.0);
    float grow = clamp(pow(L, 0.2), 1.0, 3.5);   // Sirius ~2, Venus ~3: points, not disks
    gl_PointSize = 2.0 * uCore * grow + 2.0;
    vCol = aCol * L / (grow * grow);
}
"""

STARS_FS = """
#version 410 core
in vec3 vCol;
out vec4 fragColor;
void main() {
    vec2 q = gl_PointCoord * 2.0 - 1.0;
    float r2 = dot(q, q);
    if (r2 > 1.0) discard;
    fragColor = vec4(vCol * exp(-3.0 * r2), 1.0);
}
"""

# The view's buffer to the screen: clip (keeping the hue) and encode sRGB.  (Tone mapping,
# glare and the eye's adaptation belong here later.)
PRESENT_FS = """
#version 410 core
out vec4 fragColor;
uniform sampler2D uHdr;
vec3 toSrgb(vec3 c) {
    c = max(c, 0.0);
    c /= max(1.0, max(c.r, max(c.g, c.b)));    // saturate keeping the hue
    return mix(12.92 * c, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055,
               step(0.0031308, c));
}
void main() {
    fragColor = vec4(toSrgb(texelFetch(uHdr, ivec2(gl_FragCoord.xy), 0).rgb), 1.0);
}
"""


def compile_program(vs, fs):
    def sh(kind, src):
        s = GL.glCreateShader(kind)
        GL.glShaderSource(s, src)
        GL.glCompileShader(s)
        if not GL.glGetShaderiv(s, GL.GL_COMPILE_STATUS):
            raise RuntimeError(GL.glGetShaderInfoLog(s).decode())
        return s
    p = GL.glCreateProgram()
    for s in (sh(GL.GL_VERTEX_SHADER, vs), sh(GL.GL_FRAGMENT_SHADER, fs)):
        GL.glAttachShader(p, s)
    GL.glLinkProgram(p)
    if not GL.glGetProgramiv(p, GL.GL_LINK_STATUS):
        raise RuntimeError(GL.glGetProgramInfoLog(p).decode())
    return p


def uniforms(prog, *names):
    return {n: GL.glGetUniformLocation(prog, n) for n in names}


def make_float_texture(rgb):
    """An (H, W, 3) float16 map, mipmapped, in a compact float format."""
    h, w, _ = rgb.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1)
    GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_R11F_G11F_B10F, w, h, 0,
                    GL.GL_RGB, GL.GL_HALF_FLOAT, np.ascontiguousarray(rgb))
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)          # Qt's default, for its text
    GL.glGenerateMipmap(GL.GL_TEXTURE_2D)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER,
                       GL.GL_LINEAR_MIPMAP_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE)
    try:
        GL.glTexParameterf(GL.GL_TEXTURE_2D, 0x84FE,       # MAX_ANISOTROPY
                           min(8.0, GL.glGetFloatv(0x84FF)))
    except GL.GLError:
        pass
    return tid


def make_srgb_texture(rgb):
    """An (H, W, 3) uint8 sRGB image, mipmapped, decoded to linear on sampling."""
    h, w, _ = rgb.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1)
    GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_SRGB8, w, h, 0, GL.GL_RGB,
                    GL.GL_UNSIGNED_BYTE, np.ascontiguousarray(rgb))
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)          # Qt's default, for its text
    GL.glGenerateMipmap(GL.GL_TEXTURE_2D)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER,
                       GL.GL_LINEAR_MIPMAP_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR)
    for wrap in (GL.GL_TEXTURE_WRAP_S, GL.GL_TEXTURE_WRAP_T):
        GL.glTexParameteri(GL.GL_TEXTURE_2D, wrap, GL.GL_CLAMP_TO_EDGE)
    return tid


def bv_to_rgb(bv):
    """Linear RGB of stars of colour index B-V, luminance ~1, softened toward
    white as the eye sees star colours.  Temperature by Ballesteros (2012),
    then a black body's colour (Planck at the sRGB primaries' wavelengths)."""
    bv = np.clip(bv, -0.4, 2.0)
    T = 4600.0 * (1.0 / (0.92 * bv + 1.7) + 1.0 / (0.92 * bv + 0.62))
    lam = np.array([611e-9, 549e-9, 464e-9])
    c2 = 1.4388e-2
    rgb = 1.0 / (lam[None, :] ** 5 * (np.exp(c2 / (lam[None, :] * T[:, None])) - 1.0))
    rgb /= rgb @ np.array([0.2126, 0.7152, 0.0722])[:, None]
    return 0.5 * rgb + 0.5


class Resources(object):
    """Programs, textures and buffers, made once in the first view's context."""
    _instance = None

    def __init__(self, milkyway, stars, moon):
        self.milkyway = milkyway
        self.stars = stars
        self.moon = moon
        self.starsEpoch = None
        self.ready = False

    @classmethod
    def get(cls):
        return cls._instance

    def build(self):
        if self.ready:
            return
        self.mwProg = compile_program(FULLSCREEN_VS, MILKYWAY_FS)
        self.mwU = uniforms(self.mwProg, "uMap", "uCamToJ2k", "uTan", "uGain")
        self.mwTex = make_float_texture(self.milkyway)
        self.milkyway = None                   # on the GPU now
        self.starProg = compile_program(STARS_VS, STARS_FS)
        self.starU = uniforms(self.starProg, "uJ2kToCam", "uTan", "uMagRef",
                              "uCore", "uCut")
        self.starVbo = GL.glGenBuffers(1)
        self.starCount = len(self.stars)
        self.planetVbo = GL.glGenBuffers(1)
        disk = ("uD", "uR", "uU", "uTanR", "uTan")
        self.sunProg = compile_program(DISK_VS, SUN_FS)
        self.sunU = uniforms(self.sunProg, "uColor", *disk)
        self.moonProg = compile_program(DISK_VS, MOON_FS)
        self.moonU = uniforms(self.moonProg, "uTex", "uDw", "uRw", "uUw", "uMoon", "uSun",
                              "uGain", "uEarthshine", *disk)
        self.moonTex = make_srgb_texture(self.moon)
        self.moon = None
        self.presentProg = compile_program(FULLSCREEN_VS, PRESENT_FS)
        self.presentU = uniforms(self.presentProg, "uHdr")
        self.set_star_epoch(2000.0)
        self.ready = True

    def set_star_epoch(self, year):
        """Carry the catalogue (epoch J1991.25) to the given year."""
        if self.starsEpoch is not None and abs(year - self.starsEpoch) < 0.5:
            return
        s = self.stars
        dt = year - 1991.25
        dec = np.radians(s['dec'] + s['pmdec'] / 3.6e6 * dt)
        ra = np.radians(s['ra'] + s['pmra'] / 3.6e6 * dt / np.maximum(np.cos(dec), 1e-6))
        data = np.empty((len(s), 7), np.float32)
        data[:, 0] = np.cos(dec) * np.cos(ra)
        data[:, 1] = np.cos(dec) * np.sin(ra)
        data[:, 2] = np.sin(dec)
        data[:, 3] = s['vmag']
        data[:, 4:7] = bv_to_rgb(s['bv'].astype(float))
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, self.starVbo)
        GL.glBufferData(GL.GL_ARRAY_BUFFER, data.nbytes, data, GL.GL_STATIC_DRAW)
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, 0)
        self.starsEpoch = year


# --------------------------------------------------------------------------
# Layers: drawn back to front into the view's linear buffer, each from the
# frame state and the view.  Later layers (Sun, Moon, planets, Earth,
# atmosphere, terrain, LEO objects) slot in here, each able to fade with the
# state (altitude, for ascent and entry).

class Exposure(object):
    """The eye's (or camera's) adaptation, shared by every view."""
    def __init__(self, ev, milkyway):
        self.ev = ev                    # stops; 0 = the design exposure
        self.milkyway = milkyway        # the Milky Way's gain relative to the stars

    @property
    def factor(self):
        return 2.0 ** self.ev


class MilkyWayLayer(object):
    GAIN = 1.0                          # map radiance -> display at EV 0

    def __init__(self, exposure):
        self.exposure = exposure

    def draw(self, res, view, fs):
        u = res.mwU
        GL.glUseProgram(res.mwProg)
        GL.glActiveTexture(GL.GL_TEXTURE0)
        GL.glBindTexture(GL.GL_TEXTURE_2D, res.mwTex)
        GL.glUniform1i(u["uMap"], 0)
        cam_to_j2k = J2000_TO_M50.T @ fs.C @ view.basis
        GL.glUniformMatrix3fv(u["uCamToJ2k"], 1, GL.GL_TRUE, cam_to_j2k.astype(np.float32))
        GL.glUniform2f(u["uTan"], view.tanX, view.tanY)
        GL.glUniform1f(u["uGain"], self.GAIN * self.exposure.factor * self.exposure.milkyway)
        GL.glDrawArrays(GL.GL_TRIANGLES, 0, 3)


# A disk on the sky (Sun, Moon): a quad around the body's direction, in the
# body's own (right, up) axes, with perspective-correct local coordinates.
DISK_VS = """
#version 410 core
uniform vec3 uD, uR, uU;    // camera frame: direction, right and up of the disk
uniform float uTanR;        // tan of the angular radius
uniform vec2 uTan;
out vec2 vS;
void main() {
    vec2 s = vec2(float(gl_VertexID & 1), float(gl_VertexID >> 1)) * 2.0 - 1.0;
    s *= 1.1;
    vec3 c = uD + uTanR * (s.x * uR + s.y * uU);
    vS = s;
    gl_Position = vec4(c.x / uTan.x, c.y / uTan.y, 0.0, c.z);
}
"""

DISK_EDGE_GLSL = """
float diskAlpha(vec2 s) {
    float r = length(s);
    float fw = max(fwidth(r), 1e-4);
    return clamp((1.0 - r) / fw + 0.5, 0.0, 1.0);
}
"""

SUN_FS = """
#version 410 core
in vec2 vS;
out vec4 fragColor;
uniform vec3 uColor;
""" + DISK_EDGE_GLSL + """
void main() {
    float a = diskAlpha(vS);
    if (a <= 0.0) discard;
    fragColor = vec4(uColor, a);
}
"""

# The Moon: the near-side image by the Lommel-Seeliger law (a dusty surface:
# flat at full Moon, no Lambert darkening toward the limb), lit by the part of
# the Sun's disk the Earth leaves uncovered at each point (lunar eclipses,
# with the umbra's red), plus earthshine on the night side.
MOON_FS = """
#version 410 core
in vec2 vS;
out vec4 fragColor;
uniform sampler2D uTex;
uniform vec3 uDw, uRw, uUw;     // J2000: direction to the Moon, its right and up
uniform vec3 uMoon, uSun;       // geocentric J2000, m
uniform float uGain, uEarthshine;
const float R_MOON = 1.7374e6, R_SUN = 6.957e8, R_EARTH_SHADOW = 6.378e6 * 1.02;
const float PI = 3.14159265358979;
""" + DISK_EDGE_GLSL + """
// The fraction of a disk of angular radius a uncovered by a disk of radius b,
// their centres sep apart (small angles, flat geometry).
float uncovered(float a, float b, float sep) {
    if (sep >= a + b) return 1.0;
    if (sep <= b - a) return 0.0;
    if (sep <= a - b) return 1.0 - (b * b) / (a * a);
    float a2 = a * a, b2 = b * b;
    float x = (sep * sep + a2 - b2) / (2.0 * sep);
    float y = sep - x;
    float area = a2 * acos(clamp(x / a, -1.0, 1.0)) - x * sqrt(max(a2 - x * x, 0.0))
               + b2 * acos(clamp(y / b, -1.0, 1.0)) - y * sqrt(max(b2 - y * y, 0.0));
    return 1.0 - area / (PI * a2);
}
void main() {
    float a = diskAlpha(vS);
    if (a <= 0.0) discard;
    vec2 s = vS / max(1.0, length(vS));
    vec3 n = s.x * uRw + s.y * uUw - sqrt(max(0.0, 1.0 - dot(s, s))) * uDw;
    vec3 p = uMoon + R_MOON * n;
    vec3 toSun = uSun - p;
    float dS = length(toSun), dE = length(p);
    float mu0 = dot(n, toSun / dS), mu = max(dot(n, -uDw), 1e-3);
    float lit = mu0 > 0.0 ? 2.0 * mu0 / (mu0 + mu) : 0.0;
    float sep = acos(clamp(dot(toSun / dS, -p / dE), -1.0, 1.0));
    float vis = uncovered(R_SUN / dS, R_EARTH_SHADOW / dE, sep);
    vec3 alb = texture(uTex, vec2(0.5 + 0.5 * s.x, 0.5 - 0.5 * s.y)).rgb;
    alb = mix(vec3(dot(alb, vec3(0.2126, 0.7152, 0.0722))), alb, 0.3);
    vec3 umbra = vec3(0.05, 0.012, 0.004);    // sunlight bent through the atmosphere
    vec3 c = alb * (uGain * lit * (vis + (1.0 - vis) * umbra) + uEarthshine);
    fragColor = vec4(c, a);
}
"""


class DiskLayer(object):
    """A body drawn as a disk: right/up axes from a pole direction."""

    def _axes(self, view, fs, d_j2k, pole_j2k):
        j2k_to_cam = (J2000_TO_M50.T @ fs.C @ view.basis).T
        u = pole_j2k - np.dot(pole_j2k, d_j2k) * d_j2k
        if np.linalg.norm(u) < 1e-9:
            u = np.array([0.0, 0.0, 1.0]) - d_j2k[2] * d_j2k
        u = unit(u)
        r = np.cross(d_j2k, u)
        return j2k_to_cam, r, u

    def _uniforms(self, U, view, j2k_to_cam, d, r, u, ang_radius):
        f32 = np.float32
        GL.glUniform3fv(U["uD"], 1, (j2k_to_cam @ d).astype(f32))
        GL.glUniform3fv(U["uR"], 1, (j2k_to_cam @ r).astype(f32))
        GL.glUniform3fv(U["uU"], 1, (j2k_to_cam @ u).astype(f32))
        GL.glUniform1f(U["uTanR"], math.tan(ang_radius))
        GL.glUniform2f(U["uTan"], view.tanX, view.tanY)

    @staticmethod
    def _draw():
        GL.glEnable(GL.GL_BLEND)
        GL.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA)    # opaque: hides stars
        GL.glDrawArrays(GL.GL_TRIANGLE_STRIP, 0, 4)
        GL.glDisable(GL.GL_BLEND)


class SunLayer(DiskLayer):
    RADIANCE = 1.0e4                     # far past white at any exposure

    def draw(self, res, view, fs):
        if fs.sky is None:
            return
        v = fs.sky.pos['sun'] - fs.r_j2k
        dist = np.linalg.norm(v)
        d = v / dist
        m, r, u = self._axes(view, fs, d, np.array([0.0, 0.0, 1.0]))
        GL.glUseProgram(res.sunProg)
        self._uniforms(res.sunU, view, m, d, r, u, math.asin(R_SUN / dist))
        GL.glUniform3f(res.sunU["uColor"], self.RADIANCE, self.RADIANCE, self.RADIANCE)
        self._draw()


class MoonLayer(DiskLayer):
    # Shown as the eye sees it, adapted to the Moon itself rather than to the
    # stars: a full Moon is bright but keeps its markings at any exposure.
    GAIN = 0.8
    EARTHSHINE = 0.004                   # at a full Earth (a new Moon)

    def draw(self, res, view, fs):
        if fs.sky is None:
            return
        moon, sun = fs.sky.pos['moon'], fs.sky.pos['sun']
        v = moon - fs.r_j2k
        dist = np.linalg.norm(v)
        d = v / dist
        m, r, u = self._axes(view, fs, d, moon_pole(fs.unix))
        GL.glUseProgram(res.moonProg)
        U = res.moonU
        self._uniforms(U, view, m, d, r, u, math.asin(R_MOON / dist))
        f32 = np.float32
        GL.glUniform3fv(U["uDw"], 1, d.astype(f32))
        GL.glUniform3fv(U["uRw"], 1, r.astype(f32))
        GL.glUniform3fv(U["uUw"], 1, u.astype(f32))
        GL.glUniform3fv(U["uMoon"], 1, moon.astype(f32))
        GL.glUniform3fv(U["uSun"], 1, sun.astype(f32))
        GL.glUniform1f(U["uGain"], self.GAIN)
        # The Earth's phase seen from the Moon is the complement of the Moon's.
        cos_phase = np.dot(unit(sun - moon), unit(-moon))
        GL.glUniform1f(U["uEarthshine"], self.EARTHSHINE * 0.5 * (1.0 + cos_phase))
        GL.glActiveTexture(GL.GL_TEXTURE0)
        GL.glBindTexture(GL.GL_TEXTURE_2D, res.moonTex)
        GL.glUniform1i(U["uTex"], 0)
        self._draw()


def moon_pole(unix):
    """The Moon's north pole, J2000 (IAU WGCCRE, secular terms only: the
    periodic ones are under 4 deg and only turn the image a little)."""
    T = (unix - UNIX_J2000) / (36525.0 * 86400.0)
    a, d = (269.9949 + 0.0031 * T) * D2R, (66.5392 + 0.0130 * T) * D2R
    return np.array([math.cos(d) * math.cos(a), math.cos(d) * math.sin(a), math.sin(d)])


class PointLayer(object):
    """Points through the star program: a shared buffer of
    (J2000 direction, magnitude, linear colour) and a vertex array per view."""
    MAG_REF = 3.0                       # just fills its core at EV 0
    CUT = 1e-3                          # skip points fainter than this, relative

    def __init__(self, exposure, key):
        self.exposure = exposure
        self.key = key

    def draw_points(self, res, view, fs, vbo, count):
        vao = view.pointVaos.get(self.key)
        if vao is None:
            vao = view.pointVaos[self.key] = GL.glGenVertexArrays(1)
            GL.glBindVertexArray(vao)
            GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbo)
            for name, size, off in (("aDir", 3, 0), ("aMag", 1, 3), ("aCol", 3, 4)):
                loc = GL.glGetAttribLocation(res.starProg, name)
                GL.glEnableVertexAttribArray(loc)
                GL.glVertexAttribPointer(loc, size, GL.GL_FLOAT, GL.GL_FALSE, 28,
                                         GL.ctypes.c_void_p(4 * off))
            GL.glBindBuffer(GL.GL_ARRAY_BUFFER, 0)
        u = res.starU
        GL.glUseProgram(res.starProg)
        j2k_to_cam = (J2000_TO_M50.T @ fs.C @ view.basis).T
        GL.glUniformMatrix3fv(u["uJ2kToCam"], 1, GL.GL_TRUE, j2k_to_cam.astype(np.float32))
        GL.glUniform2f(u["uTan"], view.tanX, view.tanY)
        GL.glUniform1f(u["uMagRef"], self.MAG_REF + 2.5 * math.log10(self.exposure.factor))
        GL.glUniform1f(u["uCore"], 1.0 * view.devicePixelRatioF())
        GL.glUniform1f(u["uCut"], self.CUT)
        GL.glEnable(GL.GL_PROGRAM_POINT_SIZE)
        GL.glEnable(GL.GL_BLEND)
        GL.glBlendFunc(GL.GL_ONE, GL.GL_ONE)
        GL.glBindVertexArray(vao)
        GL.glDrawArrays(GL.GL_POINTS, 0, count)
        GL.glBindVertexArray(view.vao)
        GL.glDisable(GL.GL_BLEND)


class StarLayer(PointLayer):
    def __init__(self, exposure):
        super().__init__(exposure, 'stars')

    def draw(self, res, view, fs):
        if fs.unix is not None:
            res.set_star_epoch(2000.0 + (fs.unix - UNIX_J2000) / (365.25 * 86400.0))
        self.draw_points(res, view, fs, res.starVbo, res.starCount)


class PlanetLayer(PointLayer):
    """Venus, Mars, Jupiter and Saturn: points like the stars (at 10-40
    arcsec they are under a pixel), by their magnitudes, in Ron's colours."""

    def __init__(self, exposure):
        super().__init__(exposure, 'planets')
        self.colors = []
        for _, _, h in PLANETS:
            c = srgb_hex_to_linear(h)
            self.colors.append(c / np.dot(c, [0.2126, 0.7152, 0.0722]))

    def draw(self, res, view, fs):
        if fs.sky is None:
            return
        data = np.empty((len(PLANETS), 7), np.float32)
        for i, (name, _, _) in enumerate(PLANETS):
            data[i, 0:3] = unit(fs.sky.pos[name] - fs.r_j2k)
            data[i, 3] = fs.sky.mag[name]
            data[i, 4:7] = self.colors[i]
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, res.planetVbo)
        GL.glBufferData(GL.GL_ARRAY_BUFFER, data.nbytes, data, GL.GL_DYNAMIC_DRAW)
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, 0)
        self.draw_points(res, view, fs, res.planetVbo, len(PLANETS))


# --------------------------------------------------------------------------
# The windows.

class ViewWidget(QOpenGLWidget):
    def __init__(self, app, name, spec, scale, crop, layers):
        super().__init__()
        self.app = app
        self.name = name
        self.spec = spec
        self.basis = view_basis(spec)
        self.layers = layers
        self.crop = crop
        # Focal length, logical pixels, at --size 768: --crop keeps it.
        self.focal768 = (spec['w'] / 2.0) / math.tan(spec['hfov'] * D2R / 2.0)
        self.tanX = self.tanY = 1.0
        self.vao = None
        self.pointVaos = {}
        self.hdrFbo = self.hdrTex = None
        self.hdrSize = None
        self.setWindowTitle("Portview: %s" % spec['title'])
        self.resize(max(64, round(spec['w'] * scale)),
                    max(36, round(spec['h'] * scale)))

    def initializeGL(self):
        Resources.get().build()
        self.vao = GL.glGenVertexArrays(1)

    def _fov(self):
        w, h = max(1, self.width()), max(1, self.height())
        if self.crop:
            f = self.focal768
        else:
            f = (w / 2.0) / math.tan(self.spec['hfov'] * D2R / 2.0)
        self.tanX, self.tanY = (w / 2.0) / f, (h / 2.0) / f

    def _hdr_target(self, w, h):
        """The view's linear floating-point buffer, remade on a resize."""
        if self.hdrSize == (w, h):
            return
        if self.hdrFbo is not None:
            GL.glDeleteFramebuffers(1, [self.hdrFbo])
            GL.glDeleteTextures([self.hdrTex])
        self.hdrTex = GL.glGenTextures(1)
        GL.glBindTexture(GL.GL_TEXTURE_2D, self.hdrTex)
        GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_RGBA16F, w, h, 0,
                        GL.GL_RGBA, GL.GL_HALF_FLOAT, None)
        GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST)
        GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST)
        self.hdrFbo = GL.glGenFramebuffers(1)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.hdrFbo)
        GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_COLOR_ATTACHMENT0,
                                  GL.GL_TEXTURE_2D, self.hdrTex, 0)
        self.hdrSize = (w, h)

    def paintGL(self):
        dpr = self.devicePixelRatioF()
        w, h = round(self.width() * dpr), round(self.height() * dpr)
        fs = self.app.frame
        res = Resources.get()
        self._hdr_target(w, h)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.hdrFbo)
        GL.glViewport(0, 0, w, h)
        GL.glClearColor(0.0, 0.0, 0.0, 1.0)
        GL.glClear(GL.GL_COLOR_BUFFER_BIT)
        GL.glBindVertexArray(self.vao)
        if fs.ok:
            self._fov()
            for layer in self.layers:
                layer.draw(res, self, fs)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.defaultFramebufferObject())
        GL.glViewport(0, 0, w, h)
        GL.glUseProgram(res.presentProg)
        GL.glActiveTexture(GL.GL_TEXTURE0)
        GL.glBindTexture(GL.GL_TEXTURE_2D, self.hdrTex)
        GL.glUniform1i(res.presentU["uHdr"], 0)
        GL.glDrawArrays(GL.GL_TRIANGLES, 0, 3)
        GL.glBindVertexArray(0)
        GL.glUseProgram(0)
        GL.glBindTexture(GL.GL_TEXTURE_2D, 0)       # leave Qt's painter a clean state
        line = self.app.status_line(fs)
        warn = not fs.ok or fs.stale or fs.unix is None
        if line and (self.app.hud or warn):
            p = QtGui.QPainter(self)
            p.setPen(QtGui.QColor(255, 80, 80) if warn else QtGui.QColor(200, 200, 200))
            # Fixed-width, so the digits changing every frame don't shift the line.
            f = QtGui.QFontDatabase.systemFont(QtGui.QFontDatabase.SystemFont.FixedFont)
            f.setPointSizeF(max(9.0, self.height() / 60.0))
            p.setFont(f)
            p.drawText(QtCore.QRectF(8, 4, self.width() - 16, self.height() / 10),
                       Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop, line)
            p.end()

    def keyPressEvent(self, ev):
        k = ev.key()
        x = self.app.exposure
        if k in (Qt.Key.Key_Q, Qt.Key.Key_Escape):
            QtWidgets.QApplication.quit()
        elif k == Qt.Key.Key_H:
            self.app.hud = not self.app.hud
        elif k in (Qt.Key.Key_Plus, Qt.Key.Key_Equal):
            x.ev += 1.0 / 3.0
        elif k == Qt.Key.Key_Minus:
            x.ev -= 1.0 / 3.0
        elif k == Qt.Key.Key_BracketRight:
            x.milkyway *= 2.0 ** (1.0 / 3.0)
        elif k == Qt.Key.Key_BracketLeft:
            x.milkyway /= 2.0 ** (1.0 / 3.0)
        else:
            super().keyPressEvent(ev)


class Portview(object):
    def __init__(self, args, feed, views, exposure, ephemeris):
        self.args = args
        self.feed = feed
        self.ephemeris = ephemeris
        self.views = views
        self.exposure = exposure
        self.frame = FrameState()
        self.hud = False
        self.ticks = 0
        self.timer = QtCore.QTimer()
        self.timer.setTimerType(Qt.TimerType.PreciseTimer)
        self.timer.timeout.connect(self.tick)
        self.timer.start(16)

    def status_line(self, fs):
        if not fs.ok:
            return "NO TRUTH DATA (yaGPC2 with YAGPC_VEHDYN=1, %s)" % self.feed.describe()
        g = fs.gmt
        s = "GMT %03d/%02d:%02d:%06.3f" % (int(g // 86400) % 1000, int(g // 3600) % 24,
                                           int(g // 60) % 60, g % 60)
        if fs.unix is not None:
            s += "  " + time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime(fs.unix))
        else:
            s += "  NO DATE (Sun, Moon, planets hidden)"
        s += "  alt %7.1f km" % ((np.linalg.norm(fs.r) - 6378137.0) / 1000.0)
        s += "  EV %+.2f  Milky Way x%.2f" % (self.exposure.ev, self.exposure.milkyway)
        if fs.stale:
            s += "  STALE"
        return s

    def tick(self):
        fs = self.feed.state()
        if fs.ok and fs.unix is not None:
            fs.sky = self.ephemeris.at(fs.unix)
        self.frame = fs
        for v in self.views:
            if v.isVisible():
                v.update()
        self.ticks += 1
        if self.args.snapshot and self.ticks == 60:
            for v in self.views:
                path = "%s-%s.png" % (self.args.snapshot, v.name)
                v.grabFramebuffer().save(path)
                print("portview: saved", path)
            QtWidgets.QApplication.quit()


def parse_geometry(specs, names):
    """--geometry VIEW=WxH+X+Y (or a bare WxH+X+Y with a single view)."""
    out = {}
    for spec in specs or []:
        name, _, g = spec.rpartition('=')
        if not name:
            if len(names) != 1:
                sys.exit("portview: with several views, give --geometry VIEW=WxH+X+Y")
            name = names[0]
        if name not in names:
            sys.exit("portview: --geometry for a view not shown: %s" % name)
        import re
        m = re.fullmatch(r'(?:(\d+)x(\d+))?(?:([+-]\d+)([+-]\d+))?', g)
        if not m or not g:
            sys.exit("portview: bad geometry %r" % g)
        out[name] = tuple(None if x is None else int(x) for x in m.groups())
    return out


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="The views out of the Orbiter's windows, from yaGPC2's truth state.")
    ap.add_argument("--views", default="front", metavar="LIST",
                    help="comma-separated, from %s (default front)" % ",".join(VIEWS))
    ap.add_argument("--size", type=int, default=FULL_SIZE, metavar="N",
                    help="Scale: 768 is full size (default), 512 is 2/3, 384 is half, etc.")
    ap.add_argument("--crop", action="store_true",
                    help="resizing keeps the angle per pixel (shows more or less sky) "
                         "instead of the field of view")
    ap.add_argument("--geometry", action="append", metavar="VIEW=WxH+X+Y",
                    help="a view's window size and/or place, logical pixels "
                         "(overrides --size for that window); repeatable")
    ap.add_argument("--port-base", type=int,
                    default=int(os.environ.get("NSTS_BUS_PORT_BASE", "6900")))
    ap.add_argument("--exposure", type=float, default=-1.0, metavar="EV",
                    help="exposure, stops above (+) or below (-) the design one "
                         "(default -1)")
    ap.add_argument("--milkyway", type=float, default=0.5, metavar="X",
                    help="the Milky Way's brightness relative to the stars "
                         "(default 0.5)")
    ap.add_argument("--test", nargs='?', const='lvlh', metavar="lvlh|RA,DEC|BODY",
                    help="no yaGPC2: a synthetic orbit, holding LVLH (default) or "
                         "inertial with the nose at J2000 RA,DEC (deg) or at a body "
                         "(sun, moon, venus, mars, jupiter, saturn)")
    ap.add_argument("--test-date", metavar="UTC",
                    help="with --test, the start, YYYY-MM-DD[THH:MM[:SS]] UTC (default now)")
    ap.add_argument("--test-rate", type=float, default=1.0, metavar="X",
                    help="with --test, vehicle time per wall second")
    ap.add_argument("--snapshot", metavar="PREFIX",
                    help="save each view's first second as PREFIX-VIEW.png and exit")
    args = ap.parse_args(argv)

    names = [n.strip() for n in args.views.split(',') if n.strip()]
    for n in names:
        if n not in VIEWS:
            sys.exit("portview: no view %r (views: %s)" % (n, ", ".join(VIEWS)))
    geoms = parse_geometry(args.geometry, names)
    test = None
    bodies = ['sun', 'moon'] + [n for n, _, _ in PLANETS]
    if args.test:
        if args.test == 'lvlh' or args.test in bodies:
            test = args.test
        else:
            try:
                ra, dec = (float(x) for x in args.test.split(','))
            except ValueError:
                sys.exit("portview: --test lvlh, --test RA,DEC or --test %s" % "|".join(bodies))
            test = (ra, dec)

    for path in (MILKYWAY, HIPPARCOS, DE440S):
        if not os.path.exists(path):
            sys.exit("portview: missing %s\n  run: python3 portview/fetch_assets.py" % path)
    try:
        from PIL import Image
        ephemeris = Ephemeris(DE440S)
    except ImportError as e:
        sys.exit("portview: a module it needs is missing (%s).\n"
                 "  pip install skyfield Pillow" % e.name)
    milkyway = np.load(MILKYWAY)
    stars = np.load(HIPPARCOS)
    moon = np.asarray(Image.open(MOON_IMAGE).convert('RGB'))

    QtCore.QCoreApplication.setAttribute(Qt.ApplicationAttribute.AA_ShareOpenGLContexts)
    fmt = QtGui.QSurfaceFormat()
    fmt.setVersion(4, 1)
    fmt.setProfile(QtGui.QSurfaceFormat.OpenGLContextProfile.CoreProfile)
    fmt.setSwapInterval(0)
    QtGui.QSurfaceFormat.setDefaultFormat(fmt)
    qapp = QtWidgets.QApplication(sys.argv[:1])
    Resources._instance = Resources(milkyway, stars, moon)

    unix0 = None
    if args.test_date:
        import datetime
        try:
            unix0 = datetime.datetime.fromisoformat(args.test_date).replace(
                tzinfo=datetime.timezone.utc).timestamp()
        except ValueError:
            sys.exit("portview: --test-date wants YYYY-MM-DD[THH:MM[:SS]] (UTC)")
    feed = (TestFeed(test, args.test_rate, unix0, ephemeris) if test
            else TruthFeed(args.port_base))
    scale = args.size / float(FULL_SIZE)
    exposure = Exposure(args.exposure, args.milkyway)
    layers = [MilkyWayLayer(exposure), StarLayer(exposure), PlanetLayer(exposure),
              SunLayer(), MoonLayer()]
    views = []
    app = Portview(args, feed, views, exposure, ephemeris)
    for i, n in enumerate(names):
        v = ViewWidget(app, n, VIEWS[n], scale, args.crop, layers)
        w, h, x, y = geoms.get(n, (None,) * 4)
        if w is not None:
            v.resize(w, h)
        v.move(x if x is not None else 40 + 40 * i, y if y is not None else 40 + 40 * i)
        v.show()
        views.append(v)
    return qapp.exec()


if __name__ == "__main__":
    sys.exit(main())
