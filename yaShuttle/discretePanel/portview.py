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
The Moon passes in front of the Sun; the Earth in front of all.

THE EARTH.  Ray-cast per pixel against PASS's ellipsoid (a = 6378137 m,
f = 1/298.3) in PASS's Earth-fixed frame, from TRU1 [18-26] (or, lacking it,
sidereal time from [17], ~0.7 deg off; lacking both, a plain dark Earth):
  - by day, NASA Blue Marble NG for the flight's month (cloud-free), lit by
    the Sun through the atmosphere, with sun glint on water (GEBCO's
    land/water mask) and the Moon's shadow in solar eclipses;
  - by night, NASA Black Marble's city lights;
  - the atmosphere (Rayleigh, Mie, ozone; single scattering through a
    transmittance table), giving the blue limb, twilight, haze, the sky's
    blue seen from the ground, and the dimming and reddening of whatever is
    seen through it;
  - near a landing site (--site, default ksc), the site's own imagery from
    portview/fetch_assets.py, four nested rings from +-2000 km at ~500 m
    down to +-4 km at ~1 m (NAIP), so the approach and the runway are real
    photographs; the ground there at the runway's height from the navaids.
OTHER VEHICLES.  yaGPC2 sends TGT1 datagrams (port base + 109) for YAGPC_VEHDYN_TARGETS:
"TGT1" and big-endian doubles -- vehicle t, NORAD id, M50 position (m) and
velocity (m/s) of the centre of mass, quaternion body -> M50 (w x y z).  The
ISS (25544) is drawn from NASA JSC IGOAL's model as at STS-134 (May 2011),
prepared by portview/fetch_assets.py, in the ISS analysis frame (+X forward
through PMA-2, +Y starboard, +Z nadir): real 3-D with its own depth, lit by
the Sun less the Earth's shadow, with earthshine; not drawn when the Earth is
between; and, shrinking below ~10 pixels, a brilliant point that takes over
by its magnitude.  The views see from the crew's eye points (forward or aft
station), which matters at docking ranges.

NO SIMULATED GLARE OR ADAPTATION.  Every view shows the sky at the same
exposure, whatever bright object is in it: the viewer's own eyes already dim
the stars next to a Sun, Moon or daylit Earth on the screen, and a view that
dimmed its own stars would look wrong beside one that didn't.
Light is added up linearly in a floating-point buffer per view and only then
clipped and encoded for the screen, so exposure is one physical factor.  How
the sky "looks" from orbit is a matter of exposure: --exposure and
--milkyway set it, and the keys below change it live.

SIZE.  --size N scales every window as panelO6.py does: 768 is full size,
384 half.  Resizing a window (by --size or by dragging) scales the view, which
keeps its field of view; with --crop it keeps its angle per pixel instead,
so a bigger window shows more sky.

Keys: + / - exposure up / down 1/3 stop; ] / [ the Milky Way's brightness
relative to the stars; H the status line (with the settings); Ctrl+Q (Cmd+Q
on a Mac) quits -- nothing else does, so a stray key can't close the views.
"""
import argparse
import importlib.util
import math
import os
import socket
import struct
import sys
import time


def preflight():
    """Why portview can't run here, in one line, or None -- cheaply, before
    any of the large modules load.  simulatePASS runs `portview.py --check`
    before starting it, so a machine without them just goes without views."""
    need = (("numpy", "numpy"), ("PyQt6", "PyQt6"), ("OpenGL", "PyOpenGL"),
            ("PIL", "Pillow"), ("skyfield", "skyfield"))
    missing = [pip for mod, pip in need if importlib.util.find_spec(mod) is None]
    if missing:
        return "%s missing; pip install %s" % (", ".join(missing), " ".join(missing))
    cache = os.path.join(os.path.dirname(os.path.abspath(__file__)), "portview", "cache")
    files = ("milkyway_8k.npy", "hipparcos.npy", "de440s.bsp", "nightlights.jpg",
             "watermask.png")
    absent = [f for f in files if not os.path.exists(os.path.join(cache, f))]
    if not any(f.startswith("bluemarble_") for f in (os.listdir(cache) if os.path.isdir(cache)
                                                    else [])):
        absent.append("bluemarble_MM.jpg")
    if absent:
        return ("its prepared assets are missing from portview/cache (%s); unpack the "
                "portview cache tarball there, or run python3 portview/fetch_assets.py"
                % ", ".join(absent))
    return None


if __name__ == "__main__":
    _why = preflight()
    if "--check" in sys.argv[1:]:
        print("portview: ready" if _why is None else "portview: not started -- " + _why)
        sys.exit(0 if _why is None else 1)
    if _why is not None:
        print("portview: not started -- " + _why)
        sys.exit(1)

import numpy as np                     # noqa: E402 (after the cheap check above)

from PyQt6 import QtCore, QtGui, QtWidgets
from PyQt6.QtCore import Qt
from PyQt6.QtOpenGLWidgets import QOpenGLWidget

# Linux desktops under Wayland (WSLg among them): Qt draws through XWayland
# with GLX, but PyOpenGL, seeing WAYLAND_DISPLAY, would look for an EGL
# context and find none.  And under WSL, Mesa falls back to software unless
# told to use the GPU through Direct3D 12.  (Both before OpenGL or Qt load.)
if sys.platform.startswith('linux'):
    # Unset, Qt 6 picks Wayland wherever WAYLAND_DISPLAY is set (WSLg sets
    # it): choose X11 when there is a display, as simulatePASS does (and the
    # window layouts need X11 windows anyway); then PyOpenGL must use GLX.
    # A Wayland choice made on purpose gets EGL to match.
    if not os.environ.get('QT_QPA_PLATFORM') and os.environ.get('DISPLAY'):
        os.environ['QT_QPA_PLATFORM'] = 'xcb'
    qpa = os.environ.get('QT_QPA_PLATFORM', '')
    if qpa.startswith('xcb'):
        os.environ.setdefault('PYOPENGL_PLATFORM', 'glx')
    elif qpa.startswith('wayland'):
        os.environ.setdefault('PYOPENGL_PLATFORM', 'egl')
    try:
        with open('/proc/version') as _f:
            if 'microsoft' in _f.read().lower():
                os.environ.setdefault('GALLIUM_DRIVER', 'd3d12')
    except OSError:
        pass

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
SITES_DIR = os.path.join(CACHE, "sites")
ISS_MODEL = os.path.join(CACHE, "models", "iss")
def vehicle_models(chosen=()):
    """{key: NORAD id} for the prepared vehicle models (portview/vehicles/,
    by fetch_assets.py): each whose model.json names a NORAD id, unless one
    of chosen is a variant of the same vehicle (its model.json's
    'variant_of', e.g. Hubble as deployed in 1990), which then stands in
    for it."""
    import json
    out, variants = {}, {}
    d = os.path.join(CACHE, "models")
    for key in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        try:
            with open(os.path.join(d, key, "model.json")) as f:
                meta = json.load(f)
        except (OSError, ValueError):
            continue
        if meta.get('norad'):
            out[key] = int(meta['norad'])
        elif meta.get('variant_of'):
            variants[key] = int(meta['variant_of'])
    for key in chosen:
        if key not in variants:
            sys.exit("portview: no vehicle variant %r (variants: %s)" % (key, ", ".join(sorted(variants))
                                                                        or "none"))
        out = {k: n for k, n in out.items() if n != variants[key]}
        out[key] = variants[key]
    return out
GANTRY_MODEL = os.path.join(CACHE, "models", "gantry")
# Launch pads.  vehdyn (PASS's nav-base I-loads, CGNCOM.hal) stands the
# stack nose up with the belly (+Z, the ET's side) north, so the port side and
# its crew hatch face west -- toward the Fixed Service Structure, which is on
# the pad's west side (NASA KSC, "Launch Complexes 39-A and 39-B"), its access
# arm reaching east to the hatch; the RSS swings round to the payload bay on
# the south.  The gantry model has its FSS on its +N side, so it is turned
# -90 deg (its north to the west); GANTRY_STACK is where, in its own frame,
# the ET's axis stands (estimated: FSS centre +26 m to the hatch, the hatch
# 2.2 m west of the Orbiter's line, that line 9.1 m south of the ET's axis).
# Each pad: the ET axis's place (lat, lon, deg) and the model's heading.  For
# 39A, vehdyn's nav base (PAD_LAT_RAD 0.49931150, PAD_LON_RAD -1.4068068:
# 28.6084416 N, 80.6040922 W, on PASS's ellipsoid) plus 9.12 m north, the
# Orbiter's line to the ET's axis.  vehdyn has no 39B; that one is approximate.
GANTRY_STACK = (8.9, 12.6)               # model east, north (m)
# The model's base is the pad's surface, 48 ft above sea level (the pads are
# raised 15 m on their hardstands; its MLP deck, on 22 ft pedestals and 25 ft
# deep, 16 m above that).  Heights here are sea-level heights, as PASS's site
# heights are (the SLF's 8.3 ft), not true ellipsoidal ones (KSC's geoid is
# ~29 m below the ellipsoid).  Over the flat ground drawn at the site's height
# the pad's mound isn't modelled, so the gantry stands on a 12 m step.
PAD_SURFACE_M = 48 * 0.3048
PADS = {'lc39a': (28.608524, -80.604092, -90.0), 'lc39b': (28.62722, -80.62083, -90.0)}
DE440S = os.path.join(CACHE, "de440s.bsp")
MOON_IMAGE = os.path.join(HERE, "portview", "moon.jpg")
NIGHTLIGHTS = os.path.join(CACHE, "nightlights.jpg")
WATERMASK = os.path.join(CACHE, "watermask.png")


def bluemarble_path(month):
    return os.path.join(CACHE, "bluemarble_%02d.jpg" % month)

FULL_SIZE = 768                    # --size units: 768 is the design (full) window
FRAME_PX = 4                       # the frame drawn around each view, logical px, any --size
FRAME_SRGB = (0.62, 0.62, 0.62)
MCAST_GROUP = "239.255.1.1"
TRUTH_OFFSET = 98
TARGET_OFFSET = 109                # TGT1: other vehicles, from yaGPC2 (not 81-85, the GPCs' discretes; not 96, the crew scripts' progress)
ISS_NORAD = 25544
ISS_PMA2 = (15.66, 0.0, 5.48)            # its docking face, the ISS frame (m): --test vbar aims there
TRUTH_DOUBLES_MIN = 15
TRUTH_DOUBLES_MAX = 30
STALE_S = 2.0                      # wall seconds without truth before "STALE"
MU_EARTH = 3.986004418e14          # m^3/s^2, only for extrapolating ~0.05 s
OMEGA_EARTH = 7.2921159e-5         # rad/s, the same

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


# Ron's shapes: the front view 2:1, the others square at its height, all at
# the same angle per pixel; that height the forward window's own, 29 deg (10 up
# to 19 down, below), so 29 deg square and 54.7 deg across the front.
VIEW_VFOV = 29.0
SIDE_HFOV = VIEW_VFOV
FRONT_HFOV = 2.0 * math.degrees(math.atan(2.0 * math.tan(math.radians(VIEW_VFOV / 2.0))))

# The crew's eyes, body axes (m) from vehdyn's body origin, the Orbiter's dry
# CG at X_o 1100, Y_o 0, Z_o 375 in (vehdyn.c DRY_CG_XO/ZO; body =
# (-(X_o - 1100), Y_o, -(Z_o - 375)) * 0.0254).  TRU1's r is the current
# centre of mass, offset from it by TRU1 [27-29] (the whole stack's on the
# pad: ~12.7 m), which the views subtract.
# The eye, approximately: the pilots' design eye ~X_o 520, Z_o 470, for every
# view (the overhead windows, X_o 542.5 per SFOM vol. 12 fig. 2.1-3, are just
# behind and above their heads).  It matters most on the pad and near another
# vehicle.
def _structural(xo, yo, zo):
    return (-(xo - 1100.0) * 0.0254, yo * 0.0254, -(zo - 375.0) * 0.0254)


EYE_FWD = _structural(520.0, 0.0, 470.0)

# The views.  'fwd' is the line of sight and 'up' the top of the picture, in
# body axes; 'w' x 'h' the window in logical pixels at --size 768, and 'hfov'
# its horizontal field of view (deg) at that size.  The lines of sight are the
# centres of the windows' fields of view from the crew's design eye points,
# SFOM vol. 12, Crew Systems (JSC-12770), fig. 3.28-5:
#   front: the forward windows W3/W4, 18 deg outboard to 14 deg inboard,
#          10 deg up to 19 deg down: straight ahead, 4.5 deg down.
#   up:    the overhead windows W7/W8, 35 deg forward to 45 deg aft of the
#          zenith: 5 deg aft of straight up, seen as the pilots see them, from
#          their seats facing forward with heads tipped back (top of the
#          picture toward the tail; right is right, as in the other views):
#          for the Earth below while the Orbiter flies upside down (Ron).
#   left, right: the side windows W1/W6, 71-103 deg outboard, 6 deg up to
#          18-28 deg down: 88 deg out, 8 deg down.
#   aft:   the aft flight deck's overhead windows W11/W12, from the aft
#          station (eye ~X_o 560, Z_o 470), facing aft with the head tipped
#          back: 10 deg aft of the zenith, the top of the picture toward the
#          nose -- where the crew watched the ISS from the R-bar to the
#          +V-bar.  APPROXIMATE.
#   cl:    the ODS centerline camera, on the docking ring's axis at X_o 649.00,
#          Z_o 422.85 (rndz_instruments.py's CLCAM_XO/ZO: Shuttle Systems
#          Handbook Vol 3, SCOM 2.20), looking out along the ring's axis
#          (body -Z), the top of the picture the nose; a 30 deg field.  The
#          rendezvous's last legs are flown on it.
#   cctv:  the same camera as the crew saw it on the aft station's MON 1
#          (panel A3): the CTVC's own 4:3 NTSC picture at its zoom (40.0 deg
#          for the corridor, 10.1 for the alignment, 74.4 with none), the
#          monitor's green crosshair and data, and the CC 9-17 transparency
#          taped over the screen.  See CCTV below.
VIEWS = {
    'front': dict(title="CDR/PLT Forward View", fwd=_dir(0, -4.5), up=(0, 0, -1),
                  w=1536, h=768, hfov=FRONT_HFOV, eye=EYE_FWD),
    'up': dict(title="CDR/PLT Overhead View", fwd=_dir(180, 85), up=(-1, 0, 0),
               w=768, h=768, hfov=SIDE_HFOV, eye=EYE_FWD),
    'left': dict(title="CDR Side View", fwd=_dir(-88, -8), up=(0, 0, -1),
                 w=768, h=768, hfov=SIDE_HFOV, eye=EYE_FWD),
    'right': dict(title="PLT Side View", fwd=_dir(88, -8), up=(0, 0, -1),
                  w=768, h=768, hfov=SIDE_HFOV, eye=EYE_FWD),
    'aft': dict(title="Aft Station Overhead View", fwd=_dir(180, 80), up=(1, 0, 0),
                w=768, h=768, hfov=SIDE_HFOV, eye=_structural(560.0, 0.0, 470.0)),
    'cl': dict(title="ODS Centerline Camera", fwd=(0, 0, -1), up=(1, 0, 0),
               w=768, h=768, hfov=30.0, eye=_structural(649.0, 0.0, 422.85)),
    'cctv': dict(title="A3 MON 1: Centerline Camera", fwd=(0, 0, -1), up=(1, 0, 0),
                 w=768, h=576, hfov=40.0, eye=_structural(649.0, 0.0, 422.85), cctv=True),
}

# THE AFT MONITOR'S PICTURE (the 'cctv' view): STS-134's docking setup, from
# the documents gathered in forClaude/docs/apds-cctv-aft-findings.md (B):
#   - the camera: a CTVC, colour, 3-CCD, NTSC (RS-170A), so 4:3, behind the
#     ODS hatch window (APAS p4; SCOM p163).  Its fields (GPO p114 Table
#     3.9-2): full zoom 10.1 x 7.6 deg, the corridor setting 40.0 x 30.8, no
#     zoom 74.4 x 59.9.  STS-134 docked at 40.0 with the corridor scale and
#     checked alignment at 10.1 (RNDZ p154).
#   - set up ALC AVG, GAM BLK STR ON, COLOR BAL SUN (RNDZ p154); the black
#     stretch's gamma is 2.0 (SCOM p163).  Here: the low end of the picture
#     lifted by a gamma-2 curve fading out by mid-grey.
#   - the CTVC's resolution and lens distortion are NOT documented: drawn as
#     a broadcast NTSC camera, ~480 visible lines and ~330 TV lines of
#     horizontal resolution (a slight horizontal softness), faint scan
#     lines, no distortion.  Choices, not data.
#   - the monitor (A3 MON 1, a 10-inch colour CTVM, MON 1 - CENTERLINE): an
#     electronic GREEN crosshair drawn by the monitor, green lens data
#     (zoom/focus/iris) at the top and camera data (ID, pan/tilt, temp) at
#     the bottom, USCAN ON so the whole frame shows (SCOM p172-173).
#   - over the screen, a TRANSPARENCY, CC 9-17 "C/L CAMERA CORRIDOR AND
#     ALIGNMENT" (RNDZ p315): a 10 x 8 grid on the crosshair, axis ticks 1-5
#     across and 1-3 up, a small centre square, two circles -- the 5 and 8
#     deg corridors at 40 deg (an inference from the card's scale, not
#     printed on it).  Fixed to the screen, not the scene; black ink.
CCTV = dict(zoom=40.0, overlay='corridor')
CCTV_ZOOMS = {10.1: 7.6, 40.0: 30.8, 74.4: 59.9}         # HFOV -> VFOV, deg (GPO p114)


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
    __slots__ = ('t', 'gmt', 'q', 'w', 'r', 'v', 'unix', 'm50_to_ef', 'cg', 'a', 'v_seen')

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
        # The centre of mass r and v describe, from the dry CG, body axes (m):
        # the whole stack's on the pad and in ascent; moves with propellant.
        s.cg = np.array(v[27:30]) if n >= 30 else np.zeros(3)
        s.a = None                     # acceleration, from successive datagrams
        s.v_seen = None                # velocity, as the positions show it
        return s


class VehicleClock(object):
    """Vehicle time now, from the datagrams' own vehicle time stamps.

    The target is a least-squares line, vehicle time against wall time, through
    the last FIT_S of datagrams, which averages out their arrival jitter.  The
    time shown follows the target at the fitted rate, speeding up or slowing
    down by at most SLEW of it to close any gap, so the picture never jerks.
    A jump (restore, a new run, time going backward) resets it, and it never
    runs more than HOLD_S of vehicle time past the newest datagram, so a
    paused vehicle holds still.  Both limits are for a vehicle running at real
    time and scale with the rate: at --rate 10, 0.12 s of vehicle time is
    12 ms of wall time, and every late datagram stopped the clock and then
    snapped it on -- a picture that jerked."""
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
        # The rate is kept: a run at --rate 10 measured as 1 (the first
        # guess) fell 0.5 s behind within 50 ms and reset again, before
        # ever fitting -- so it ran at 1x, snapping on about once a second.
        self.pts = []
        self.a = None
        self.shown = None

    def _scale(self):
        return max(1.0, self.rate or 1.0)

    def datagram(self, t, wall):
        if self.last_t is not None and (t < self.last_t or t - self.last_t > 5.0 * self._scale()
                                        or (self.rate is not None and
                                            abs(t - self.a - self.rate * wall) > self.RESET_S * self._scale())):
            self._reset()
        self.last_t = t
        self.pts.append((wall, t))
        while wall - self.pts[0][0] > self.FIT_S:
            self.pts.pop(0)
        n = len(self.pts)
        if n < 2:
            self.rate = self.rate or 1.0
            self.a = t - self.rate * wall
            return
        w0 = self.pts[0][0]
        sw = sum(p[0] - w0 for p in self.pts) / n
        st = sum(p[1] for p in self.pts) / n
        cov = sum((p[0] - w0 - sw) * (p[1] - st) for p in self.pts)
        var = sum((p[0] - w0 - sw) ** 2 for p in self.pts)
        if var > 1e-8 and wall - w0 > 0.05:
            self.rate = max(0.0, cov / var)
        self.a = st - self.rate * (sw + w0)

    def now(self, wall):
        if self.a is None:
            return None
        k = self._scale()
        target = min(self.a + self.rate * wall, self.last_t + self.HOLD_S * k)
        if self.shown is None or abs(target - self.shown) > self.RESET_S * k:
            self.shown, self.shownAt = target, wall
            return target
        dw = wall - self.shownAt
        step = self.rate * dw
        gap = target - (self.shown + step)
        lim = self.SLEW * step
        step += max(-lim, min(lim, gap))
        hold = max(self.shown, self.last_t + self.HOLD_S * k)
        self.shown, self.shownAt = min(self.shown + max(0.0, step), hold), wall
        return self.shown


class FrameState(object):
    """Everything a frame is drawn from, once per tick for all the views."""
    __slots__ = ('ok', 'stale', 't', 'gmt', 'unix', 'C', 'r', 'v', 'r_j2k',
                 'm50_to_ef', 'sky', 'targets', 'cg')

    def __init__(self):
        self.ok = False
        self.stale = False
        self.sky = None                # SkyBodies, when the date is known
        self.targets = {}              # NORAD id -> (M50 position, body -> M50)


class Target(object):
    """One TGT1 datagram: another vehicle (the ISS), from yaGPC2's vehicle
    dynamics: vehicle t, NORAD id, M50 position (m) and velocity (m/s) of its
    centre of mass, and its attitude, quaternion body -> M50 (w x y z)."""
    __slots__ = ('t', 'id', 'r', 'v', 'q')

    @classmethod
    def parse(cls, d):
        if len(d) < 4 + 8 * 12 or d[:4] != b"TGT1":
            return None
        v = struct.unpack(">12d", d[4:4 + 8 * 12])
        s = cls()
        s.t, s.id = v[0], int(v[1])
        s.r, s.v, s.q = np.array(v[2:5]), np.array(v[5:8]), np.array(v[8:12])
        return s

    def at(self, t):
        """Position and attitude at vehicle time t (the attitude turns too
        slowly, ~0.07 deg/s in LVLH, to matter between datagrams)."""
        dt = t - self.t
        rn = np.linalg.norm(self.r)
        g = -MU_EARTH * self.r / rn ** 3
        return self.r + self.v * dt + 0.5 * g * dt * dt, quat_to_matrix(unit(self.q))


def extrapolate(s, t):
    """The state of datagram s carried forward to vehicle time t."""
    dt = t - s.t
    fs = FrameState()
    fs.ok = True
    fs.t = t
    fs.gmt = s.gmt + dt
    fs.unix = None if s.unix is None else s.unix + dt
    # The acceleration seen between the last two datagrams: right on the pad
    # (held up, not falling), under thrust and in orbit alike.  Free fall would
    # sag the stack ~7 cm between datagrams and snap it back, a jitter of the
    # gantry 22 m outside the commander's window.
    if s.a is not None:
        g = s.a
    else:
        rn = np.linalg.norm(s.r)
        g = -MU_EARTH * s.r / rn ** 3 if rn > 1e6 else np.zeros(3)
    # And the velocity the positions themselves show, where there is one: on
    # the pad vehdyn's v (omega x r about M50's pole) differs from how r moves
    # (about the true pole, 0.6 deg away) by 1.5 m/s -- 8 cm between datagrams.
    v = s.v_seen if s.v_seen is not None else s.v
    fs.r = s.r + v * dt + 0.5 * g * dt * dt
    fs.v = v + g * dt
    fs.r_j2k = J2000_TO_M50.T @ fs.r
    fs.cg = s.cg
    fs.C = quat_to_matrix(unit(quat_advance(s.q, s.w, dt)))     # body -> M50
    # The Earth turns too: carrying the position forward but not the Earth
    # would slide the ground under the Orbiter by up to ~20 m (0.05 s at
    # 408 m/s at KSC) and snap it back at each datagram.
    if s.m50_to_ef is None:
        fs.m50_to_ef = None
    else:
        th = OMEGA_EARTH * dt
        fs.m50_to_ef = np.array([[math.cos(th), math.sin(th), 0.0],
                                 [-math.sin(th), math.cos(th), 0.0],
                                 [0.0, 0.0, 1.0]]) @ s.m50_to_ef
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
        self.targets = {}                 # id -> (Target, wall time received)
        self.tsock = mcast_socket(port_base + TARGET_OFFSET)
        self.tnotifier = QtCore.QSocketNotifier(
            self.tsock.fileno(), QtCore.QSocketNotifier.Type.Read, self)
        self.tnotifier.activated.connect(self._read_targets)

    def _read_targets(self, *_):
        while True:
            try:
                d = self.tsock.recv(1024)
            except (BlockingIOError, OSError):
                break
            g = Target.parse(d)
            if g is not None:
                self.targets[g.id] = (g, time.monotonic())

    def _target_states(self, fs, wall):
        for k, (g, at) in list(self.targets.items()):
            if wall - at > STALE_S:
                del self.targets[k]
            else:
                fs.targets[k] = g.at(fs.t)

    def _read(self, *_):
        while True:
            try:
                d = self.sock.recv(1024)
            except (BlockingIOError, OSError):
                break
            s = Truth.parse(d)
            if s is not None:
                wall = time.monotonic()
                prev = self.latest
                if prev is not None and 0.0 < s.t - prev.t < 1.0:
                    h = s.t - prev.t
                    s.a = (s.v - prev.v) / h
                    s.v_seen = (s.r - prev.r) / h + 0.5 * s.a * h     # at s.t
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
        self._target_states(fs, wall)
        return fs


class TestFeed(TruthFeed):
    """No yaGPC2: a synthetic circular orbit (400 km, 51.6 deg), sent through
    the same datagram, clock and extrapolation path as the real feed.

    mode 'lvlh': nose along the velocity, belly to the Earth.
    mode 'baydown': nose along the velocity, payload bay to the Earth (the
    overhead windows look straight down).
    mode (ra, dec): inertial hold, nose at that J2000 direction (deg) and
    the top of the forward view toward the celestial north pole.
    mode 'sun', 'moon', 'venus', ...: the same, at that body's direction from
    the Earth's centre at the start.
    mode ('hover', lat, lon, alt_m, heading, pitch): fixed over the ground (on
    PASS's ellipsoid, degrees and metres), nose at that heading and pitch, wings
    level: for looking at a landing site.
    mode 'vbar': the final approach to the ISS on the +V-bar, as STS-134
    docked: the ISS (TGT1, synthetic) target_range metres behind along the
    velocity, in its +XVV Z-nadir attitude; the Orbiter ahead of it with its
    payload bay (-Z) toward it and its nose up, so the overhead windows look
    at PMA-2.  With approach_from, it starts that far off and closes as the
    Shuttle's approaches did, range rate = range / 1000 per second (the
    corridor's rule of thumb; 1 m/s at 1 km), to target_range, and holds
    there: station-keeping.  A demonstration, not the flight software's
    rendezvous.
    mode 'flyaround': the Orbiter circling the ISS in the orbit's plane at
    target_range metres, from the +V-bar up over the top and round, one lap
    in lap_s seconds, its payload bay (-Z) toward the station all the way,
    as the Shuttle's fly-arounds after undocking were flown.  Scripted, as
    'vbar' is."""
    PERIOD_S = 0.05
    APPROACH_TAU_S = 1000.0

    def __init__(self, mode, rate=1.0, unix0=None, ephemeris=None, alt_km=400.0, lon=None,
                 target_range=100.0, target_id=ISS_NORAD, approach_from=None, lap_s=5400.0,
                 phase_deg=0.0):
        QtCore.QObject.__init__(self)
        self.targets = {}
        self.target_range = target_range
        self.sight = 'up'                   # the view whose sight line the target is on
        self.offset = (0.0, 0.0)            # m off it, that view's right and up
        self.approach_from = approach_from
        self.lap_s = lap_s
        self.phase_deg = phase_deg
        self.target_id = target_id
        self.unix0 = time.time() if unix0 is None else unix0
        if isinstance(mode, str) and mode not in ('lvlh', 'baydown', 'hover', 'vbar', 'flyaround'):
            d = unit(ephemeris.at(self.unix0).pos[mode])
            mode = (math.degrees(math.atan2(d[1], d[0])) % 360.0,
                    math.degrees(math.asin(d[2])))
        self.mode = mode
        self.rate = rate
        self.latest = None
        self.latestAt = -1e9
        self.clock = VehicleClock()
        self.R = 6378137.0 + alt_km * 1e3
        self.n = math.sqrt(MU_EARTH / self.R ** 3)
        self.inc = 51.6 * D2R
        self.raan = 0.0
        if lon is not None:            # start over that longitude (on the equator)
            x = gmst_matrix(self.unix0) @ np.array([1.0, 0.0, 0.0])
            self.raan = lon * D2R - math.atan2(x[1], x[0])
        self.t = 0.0
        # The test's time runs with the wall clock (times the rate), not a
        # step per timer firing: at --test-rate 10 the timer is due every
        # 5 ms, and drawing delays it, so stepping made the time run at 1x to
        # 60x by turns -- a fly-around that jerked.
        self.wall0 = time.monotonic()
        self.timer = QtCore.QTimer(self)
        self.timer.setTimerType(Qt.TimerType.PreciseTimer)
        self.timer.timeout.connect(self._send)
        self.timer.start(max(10, int(round(1000 * self.PERIOD_S / rate))))
        self._send()

    def describe(self):
        return "test orbit"

    def _flyaround_dir(self, t, r, v):
        """The direction from the crew to the vehicle: the Orbiter on a circle
        round it in the orbit's plane, starting ahead on the +V-bar and going
        up over the top."""
        z = -unit(r)
        x = np.cross(unit(np.cross(v, r)), z)
        th = 2.0 * math.pi / self.lap_s * t + math.radians(self.phase_deg)
        return -(math.cos(th) * x + math.sin(th) * z)

    def _target_at(self, t):
        """The vehicle's place (M50, m) at test time t: on the overhead
        view's sight line from the forward crew station (14.7 m ahead of the
        centre of mass and 2.4 m above it -- from which aiming at it missed
        a vehicle 25 m off by 30 deg), at the approach's range or the
        fly-around's."""
        r, v = self._orbit(t)
        C = self._attitude(t)
        sv = VIEWS[self.sight]
        eye = r + C @ np.asarray(sv['eye'], float)
        if self.mode == 'flyaround':
            return eye + self.target_range * self._flyaround_dir(t, r, v)
        los = unit(C @ np.asarray(sv['fwd'], float))
        B = view_basis(sv)                  # camera -> body: right, up, line of sight
        eye = eye + C @ (B[:, 0] * self.offset[0] + B[:, 1] * self.offset[1])
        aim = np.zeros(3)
        if self.target_id == ISS_NORAD:     # the docking port, not the middle
            z = -unit(r)
            y = unit(np.cross(v, r))
            aim = np.column_stack([np.cross(y, z), y, z]) @ np.asarray(ISS_PMA2)
        return eye + self._range(t)[0] * los - aim

    def _range(self, t):
        """The target's distance (m) and its rate (m/s) at test time t."""
        hold = self.target_range
        if not self.approach_from or self.approach_from <= hold:
            return hold, 0.0
        r = self.approach_from * math.exp(-t / self.APPROACH_TAU_S)
        return (r, -r / self.APPROACH_TAU_S) if r > hold else (hold, 0.0)

    def _orbit(self, t):
        if isinstance(self.mode, tuple) and self.mode[0] == 'hover':
            r, _, m = self._hover(t)
            w = np.array([0.0, 0.0, 7.2921159e-5])
            return m.T @ r, m.T @ np.cross(w, r)
        u = self.n * t
        cO, sO, ci, si = math.cos(self.raan), math.sin(self.raan), math.cos(self.inc), math.sin(self.inc)
        P = np.array([cO, sO, 0.0])
        Q = np.array([-sO * ci, cO * ci, si])
        r = self.R * (math.cos(u) * P + math.sin(u) * Q)
        v = self.R * self.n * (-math.sin(u) * P + math.cos(u) * Q)
        return r, v

    def _hover(self, t):
        """Earth-fixed position and body axes, and the M50 -> Earth-fixed matrix."""
        _, lat, lon, alt, hdg, pitch = self.mode
        e2 = 1.0 - (EARTH_B / EARTH_A) ** 2
        la, lo = math.radians(lat), math.radians(lon)
        Nr = EARTH_A / math.sqrt(1.0 - e2 * math.sin(la) ** 2)
        r = np.array([(Nr + alt) * math.cos(la) * math.cos(lo), (Nr + alt) * math.cos(la) * math.sin(lo),
                      (Nr * (1.0 - e2) + alt) * math.sin(la)])
        east = np.array([-math.sin(lo), math.cos(lo), 0.0])
        north = np.array([-math.sin(la) * math.cos(lo), -math.sin(la) * math.sin(lo), math.cos(la)])
        up = np.cross(east, north)
        h, p = math.radians(hdg), math.radians(pitch)
        fwd = math.cos(h) * north + math.sin(h) * east
        x = math.cos(p) * fwd + math.sin(p) * up
        y = math.cos(h) * east - math.sin(h) * north
        return r, np.column_stack([x, y, np.cross(x, y)]), gmst_matrix(self.unix0 + t)

    def _attitude(self, t):
        if isinstance(self.mode, tuple) and self.mode[0] == 'hover':
            r, axes, m = self._hover(t)
            return m.T @ axes
        if self.mode == 'flyaround':        # the overhead view's sight line at it, nose out of plane
            r, v = self._orbit(t)
            y = unit(np.cross(v, r))
            d = self._flyaround_dir(t, r, v)
            los = np.asarray(VIEWS['up']['fwd'], float)
            los = los / np.linalg.norm(los)
            e2b = unit(np.array([1.0, 0.0, 0.0]) - los[0] * los)
            e2i = unit(y - np.dot(y, d) * d)
            B = np.column_stack([los, e2b, np.cross(los, e2b)])
            I = np.column_stack([d, e2i, np.cross(d, e2i)])
            return I @ B.T
        if self.mode in ('lvlh', 'baydown', 'vbar'):
            r, v = self._orbit(t)
            z = -unit(r)
            y = unit(np.cross(v, r))
            if self.mode == 'baydown':
                z, y = -z, -y
            if self.mode == 'vbar':          # -Z (bay) aft along -V, nose up
                x_l = np.cross(y, z)
                return np.column_stack([-z, y, x_l])
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
        t = self.t = (time.monotonic() - self.wall0) * self.rate
        r, v = self._orbit(t)
        C = self._attitude(t)
        h = 1e-3
        dC = (self._attitude(t + h) - self._attitude(t - h)) / (2 * h)
        W = C.T @ dC                                   # skew(w), body rates
        w = np.array([W[2, 1], W[0, 2], W[1, 0]])
        m50_to_ef = gmst_matrix(self.unix0 + t)
        vals = ([t, t] + list(matrix_to_quat(C)) + list(w) + list(r) + list(v)
                + [0.0, 0.0, self.unix0 + t] + list(m50_to_ef.ravel()))
        s = Truth.parse(b"TRU1" + struct.pack(">27d", *vals))
        wall = time.monotonic()
        self.clock.datagram(s.t, wall)
        self.latest, self.latestAt = s, wall
        if self.mode in ('vbar', 'flyaround'):
            z = -unit(r)
            y = unit(np.cross(v, r))
            x = np.cross(y, z)
            lvlh = np.column_stack([x, y, z])          # the ISS: +XVV, Z nadir
            p = self._target_at(t)
            pv_ = (self._target_at(t + h) - self._target_at(t - h)) / (2 * h)
            g = Target.parse(b"TGT1" + struct.pack(
                ">12d", t, self.target_id, *p, *pv_, *matrix_to_quat(lvlh)))
            self.targets[g.id] = (g, wall)


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

# The view's buffer to the screen: clip (keeping the hue) and encode sRGB.
PRESENT_FS = """
#version 410 core
out vec4 fragColor;
uniform sampler2D uHdr, uEarth, uEarthTrans;
uniform ivec2 uOffset;              // the view's corner in the window (inside its frame)
uniform int uCctv;                  // 1: the aft monitor's camera picture (see CCTV)
uniform ivec2 uSize;                // the view, device px
vec3 toSrgb(vec3 c) {
    c = max(c, 0.0);
    c /= max(1.0, max(c.r, max(c.g, c.b)));    // saturate keeping the hue
    return mix(12.92 * c, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055,
               step(0.0031308, c));
}
vec3 scene(ivec2 p) {               // the linear picture at a pixel (as main's below)
    p = clamp(p, ivec2(0), uSize - 1);
    vec3 front = texelFetch(uEarth, p, 0).rgb;
    float sky = dot(front, vec3(0.2126, 0.7152, 0.0722));
    return texelFetch(uHdr, p, 0).rgb * texelFetch(uEarthTrans, p, 0).rgb
           * exp(-sky / 0.002) + front;
}
vec3 cctv(ivec2 p) {
    // ~330 TV lines across a 4:3 picture's height: a five-tap horizontal
    // blur a little under a 640-pixel line's pixel wide; a touch vertically.
    float s = max(1.0, float(uSize.x) / 640.0);
    vec3 c = vec3(0.0);
    float wt[5] = float[](1.0, 4.0, 6.0, 4.0, 1.0);
    for (int i = -2; i <= 2; i++)
        c += wt[i + 2] * scene(p + ivec2(int(round(float(i) * s * 0.6)), 0));
    c /= 16.0;
    c = mix(c, 0.5 * (scene(p + ivec2(0, 1)) + scene(p - ivec2(0, 1))), 0.15);
    vec3 o = toSrgb(c);
    // GAM BLK STR ON: the shadows lifted by a gamma-2 curve, fading out by
    // mid-grey (SCOM p163).
    o = mix(o, sqrt(o), 0.6 * (1.0 - smoothstep(0.0, 0.5, o)));
    // NTSC colour: a little less saturated.
    float y = dot(o, vec3(0.299, 0.587, 0.114));
    o = mix(vec3(y), o, 0.88);
    // ~480 visible lines: a faint line structure where the screen has the
    // pixels to show it (two or more a line).
    float per = float(uSize.y) / 480.0;
    if (per >= 2.0)
        o *= 0.93 + 0.07 * cos(6.2831853 * float(p.y) / per);
    return o;
}
void main() {
    ivec2 p = ivec2(gl_FragCoord.xy) - uOffset;
    if (uCctv == 1) {
        fragColor = vec4(cctv(p), 1.0);
        return;
    }
    vec4 fr = texelFetch(uEarth, p, 0);
    vec3 front = fr.rgb;
    // A star or the Milky Way can't show through a daylit sky: the air's own
    // light, many thousands of times brighter, masks it.  Fade what lies
    // behind as that pixel's sky brightens (twilight about half way); the
    // same in every view, and nothing at all in space or a night sky.
    float sky = dot(front, vec3(0.2126, 0.7152, 0.0722));
    vec3 c = texelFetch(uHdr, p, 0).rgb * texelFetch(uEarthTrans, p, 0).rgb
           * exp(-sky / 0.002) + front;
    // The screen has 8 bits a channel: a sky whose colour changes a level
    // every few degrees shows rings at each step.  Dither it away with about
    // a level of triangular noise, fixed to the pixel so it doesn't crawl.
    uint h = uint(p.x) * 1973u + uint(p.y) * 9277u + 26699u;     // PCG hash
    h = h * 747796405u + 2891336453u;
    h = ((h >> ((h >> 28u) + 4u)) ^ h) * 277803737u;
    h ^= h >> 22u;
    float n1 = float(h & 0xffffu) / 65535.0, n2 = float(h >> 16u) / 65535.0;
    vec3 o = toSrgb(c);
    // Only on the sky and the Earth: not on a vehicle (alpha is the part of
    // the pixel no vehicle covers), whose fine detail needs no help.
    o += (n1 + n2 - 1.0) / 255.0 * step(0.5 / 255.0, max(o.r, max(o.g, o.b)))   // black stays black
       * clamp(fr.a, 0.0, 1.0);
    fragColor = vec4(o, 1.0);
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


def load_rgb(path):
    from PIL import Image
    Image.MAX_IMAGE_PIXELS = None
    return np.asarray(Image.open(path).convert('RGB'))


# Texture memory.  'full': the Earth's maps uncompressed at full size (about
# 1.2 GB of textures in all).  'reduced', for GPUs with under REDUCED_BELOW of
# their own memory (a 2 GB card thrashes with four views): the large maps at
# half size and DXT1-compressed, the Milky Way at half size (about 0.5 GB).
# Unified-memory GPUs (Apple, Intel) report nothing and get 'full'.
TEXTURES = {'mode': 'full'}
TERRAIN = {'on': True}                  # the ground's heights near a site (--terrain)
MSAA = {'samples': 4}                   # the Earth-and-vehicles pass's samples a pixel (--msaa)
REDUCED_BELOW_KB = 3 * 1024 * 1024


def gpu_memory_kb():
    """The GPU's own memory, kB, where the driver says (NVIDIA, AMD); else None."""
    try:
        exts = {GL.glGetStringi(GL.GL_EXTENSIONS, i).decode()
                for i in range(GL.glGetIntegerv(GL.GL_NUM_EXTENSIONS))}
        if 'GL_NVX_gpu_memory_info' in exts:
            return int(GL.glGetIntegerv(0x9048))      # TOTAL_AVAILABLE_MEMORY_NVX
        if 'GL_ATI_meminfo' in exts:
            return int(np.asarray(GL.glGetIntegerv(0x87FC)).ravel()[0])   # TEXTURE_FREE_MEMORY
    except GL.GLError:
        pass
    return None


def halve(a):
    """An image at half size (2 x 2 box average), any channels and type."""
    h, w = a.shape[0] // 2 * 2, a.shape[1] // 2 * 2
    a = a[:h, :w].astype(np.float32)
    b = 0.25 * (a[0::2, 0::2] + a[1::2, 0::2] + a[0::2, 1::2] + a[1::2, 1::2])
    return b


def make_earth_texture(rgb):
    """A large sRGB map of the Earth, mipmapped, wrapping east-west.  Not
    compressed: DXT1's 4x4 blocks show as squares when the map is magnified
    (low over the ground), and the memory (530 MB for 16384 x 8192) is there --
    unless TEXTURES says 'reduced'."""
    reduced = TEXTURES['mode'] == 'reduced'
    if reduced:
        rgb = np.clip(halve(rgb) + 0.5, 0, 255).astype(np.uint8)
    h, w, _ = rgb.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1)
    GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, 0x8C4C if reduced else GL.GL_SRGB8,   # DXT1 sRGB
                    w, h, 0, GL.GL_RGB, GL.GL_UNSIGNED_BYTE, np.ascontiguousarray(rgb))
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)
    GL.glGenerateMipmap(GL.GL_TEXTURE_2D)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR_MIPMAP_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE)
    try:
        GL.glTexParameterf(GL.GL_TEXTURE_2D, 0x84FE, min(8.0, GL.glGetFloatv(0x84FF)))
    except GL.GLError:
        pass
    return tid


def load_gray(path):
    from PIL import Image
    Image.MAX_IMAGE_PIXELS = None
    return np.asarray(Image.open(path).convert('L'))


def make_mask_texture(a):
    """A one-channel 0-255 map, mipmapped, filtered."""
    h, w = a.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1)
    GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_R8, w, h, 0, GL.GL_RED, GL.GL_UNSIGNED_BYTE,
                    np.ascontiguousarray(a))
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)
    GL.glGenerateMipmap(GL.GL_TEXTURE_2D)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR_MIPMAP_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE)
    return tid


def make_height_array(layers):
    """Heights (n, h, w float32) as an R32F texture array, linear, clamped."""
    n, h, w = layers.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D_ARRAY, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)
    GL.glTexImage3D(GL.GL_TEXTURE_2D_ARRAY, 0, GL.GL_R32F, w, h, n, 0, GL.GL_RED, GL.GL_FLOAT,
                    np.ascontiguousarray(layers, dtype=np.float32))
    for p, v in ((GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR), (GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR),
                 (GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP_TO_EDGE), (GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE)):
        GL.glTexParameteri(GL.GL_TEXTURE_2D_ARRAY, p, v)
    return tid


def make_ring_texture(rgb, compress):
    """A site ring: sRGB, mipmapped, clamped at its edges (it fades out
    before them).  The innermost, magnified close to the ground, uncompressed;
    the others DXT1 (1/6 the memory)."""
    h, w, _ = rgb.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1)
    compress = compress or TEXTURES['mode'] == 'reduced'
    GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, 0x8C4C if compress else GL.GL_SRGB8,
                    w, h, 0, GL.GL_RGB, GL.GL_UNSIGNED_BYTE, np.ascontiguousarray(rgb))
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)
    GL.glGenerateMipmap(GL.GL_TEXTURE_2D)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR_MIPMAP_LINEAR)
    GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR)
    for wrap in (GL.GL_TEXTURE_WRAP_S, GL.GL_TEXTURE_WRAP_T):
        GL.glTexParameteri(GL.GL_TEXTURE_2D, wrap, GL.GL_CLAMP_TO_EDGE)
    try:
        GL.glTexParameterf(GL.GL_TEXTURE_2D, 0x84FE, min(8.0, GL.glGetFloatv(0x84FF)))
    except GL.GLError:
        pass
    return tid


def make_lut_texture(rgb):
    h, w, _ = rgb.shape
    tid = GL.glGenTextures(1)
    GL.glBindTexture(GL.GL_TEXTURE_2D, tid)
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1)
    GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_RGB32F, w, h, 0, GL.GL_RGB, GL.GL_FLOAT,
                    np.ascontiguousarray(rgb))
    GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4)
    for p, v in ((GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR), (GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR),
                 (GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP_TO_EDGE), (GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE)):
        GL.glTexParameteri(GL.GL_TEXTURE_2D, p, v)
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

    def __init__(self, milkyway, stars, moon, site):
        self.milkyway = milkyway
        self.stars = stars
        self.moon = moon
        self.site = site                       # Site, or None
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
        if TEXTURES['mode'] == 'auto':
            kb = gpu_memory_kb()
            TEXTURES['mode'] = 'reduced' if kb is not None and kb < REDUCED_BELOW_KB else 'full'
            print("portview: GPU memory %s; textures %s" % (
                "%.1f GB" % (kb / 1048576.0) if kb is not None else "unreported (shared)",
                TEXTURES['mode']))
        if TEXTURES['mode'] == 'reduced':
            self.milkyway = halve(self.milkyway).astype(np.float16)
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
        self.earthProg = compile_program(FULLSCREEN_VS, EARTH_FS)
        self.earthU = uniforms(self.earthProg, "uCamToEF", "uOrigin", "uSun", "uTan", "uDay",
                               "uNight", "uTrans", "uWater", "uSunE", "uNightGain", "uLit", "uMoonGain",
                               "uMoonEF", "uCTop", "uCGround", "uSiteOn", "uCamEnu", "uEfToEnu",
                               "uRingNear", "uRingFar", "uRing0", "uRing1", "uRing2", "uRing3",
                               "uPatchCount", "uPatch", "uPatch0", "uPatch1", "uPatch2",
                               "uHgtOn", "uHgt", "uHgtP", "uPatchHgt", "uSiteEF", "uSiteH",
                               "uInvR", "uHgtMax")
        self.earthPlainProg = compile_program(FULLSCREEN_VS, EARTH_PLAIN_FS)
        self.earthPlainU = uniforms(self.earthPlainProg, "uCamToEF", "uOrigin", "uTan")
        self.transTex = make_lut_texture(transmittance_table())
        self.earthNightTex = make_earth_texture(load_rgb(NIGHTLIGHTS))
        self.waterTex = make_mask_texture(load_gray(WATERMASK))
        self.ringTex = []
        if self.site is not None:
            for k, img in enumerate(self.site.images):
                self.ringTex.append(make_ring_texture(img, compress=k > 0))
            self.patchTex = [make_ring_texture(img, compress=False)
                             for img in self.site.patch_images]
            self.site.images = self.site.patch_images = None
        # The ground's heights; a 1-texel array stands in where there are none
        # (each sampler must still name a unit of its own type).
        empty = np.zeros((1, 1, 1), np.float32)
        site = self.site
        self.hgtTex = make_height_array(site.heights if site is not None and site.heights is not None
                                        else empty)
        self.hgtMax = float(site.heights.max()) + 1.0 if site is not None and site.heights is not None else 0.0
        self.patchHgtLayer = [-1, -1, -1]
        ph = [] if site is None else [a for a in site.patch_heights if a is not None]
        if site is not None:
            k = 0
            for i, a in enumerate(site.patch_heights):
                if a is not None:
                    self.patchHgtLayer[i] = k
                    self.hgtMax = max(self.hgtMax, float(a.max()) + 1.0)
                    k += 1
            site.heights = site.patch_heights = None
        self.hgtPTex = make_height_array(np.stack(ph) if ph else empty)
        self.earthDayTex = None
        self.earthMonth = None
        self.modelProg = compile_program(MODEL_VS, MODEL_FS)
        self.modelU = uniforms(self.modelProg, "uRot", "uTrans", "uTan", "uNear", "uFar", "uTex",
                               "uHasTex", "uColor", "uSunB", "uEyeB", "uEarthB", "uSunE",
                               "uSunVis", "uEarthLit")
        self.presentProg = compile_program(FULLSCREEN_VS, PRESENT_FS)
        self.presentU = uniforms(self.presentProg, "uHdr", "uEarth", "uEarthTrans", "uOffset",
                                 "uCctv", "uSize")
        self.set_star_epoch(2000.0)
        self.ready = True

    def set_month(self, unix):
        """The Blue Marble month of the flight (loaded on first need, ~1.5 s);
        the nearest prepared month if that one isn't."""
        month = time.gmtime(unix).tm_mon
        if month == self.earthMonth:
            return
        have = [m for m in range(1, 13) if os.path.exists(bluemarble_path(m))]
        if not have:
            sys.exit("portview: no Blue Marble month prepared\n"
                     "  run: python3 portview/fetch_assets.py")
        use = min(have, key=lambda m: min(abs(m - month), 12 - abs(m - month)))
        if use != month:
            print("portview: Blue Marble month %d not prepared; using %d" % (month, use))
        if self.earthDayTex is not None:
            GL.glDeleteTextures([self.earthDayTex])
        self.earthDayTex = make_earth_texture(load_rgb(bluemarble_path(use)))
        self.earthMonth = month

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
# The Earth and its atmosphere.  One full-screen pass per view: each pixel's
# ray is intersected with PASS's ellipsoid (a = 6378137 m, f = 1/298.3) in
# PASS's Earth-fixed frame (TRU1's M50 -> Earth-fixed matrix), and the
# atmosphere along it is integrated: Rayleigh, Mie and ozone, single
# scattering, the Sun's light reaching each point through a precomputed
# transmittance table (Bruneton and Neyret's parameterization).  The result
# goes to the view's Earth buffers, a colour and the atmosphere's own
# transmittance; the final pass shows the sky through that transmittance and
# adds the colour, so stars, the Sun and the Moon dim and redden toward the
# limb.  (Dual-source blending would do it in one pass, but Apple's OpenGL on
# Metal falls back to software for it.)
# The same code serves later for views from inside the atmosphere.

EARTH_A = 6378137.0                   # PASS's ellipsoid (vehdyn.c; GNKGEO)
EARTH_F = 1.0 / 298.3
EARTH_B = EARTH_A * (1.0 - EARTH_F)
ATMOS_TOP = 100e3                     # m above the ellipsoid
RAYLEIGH = np.array([5.802e-6, 13.558e-6, 33.1e-6])     # scattering, 1/m
RAYLEIGH_H = 8000.0
MIE_SCAT, MIE_EXT, MIE_H, MIE_G = 3.996e-6, 4.440e-6, 1200.0, 0.8
OZONE = np.array([0.650e-6, 1.881e-6, 0.085e-6])        # absorption, 1/m
TRANS_W, TRANS_H = 256, 64


def height_above_ellipsoid(r):
    """Height (m) of Earth-fixed r above PASS's ellipsoid (Bowring, one step:
    good to millimetres from the ground to orbit)."""
    e2 = 1.0 - (EARTH_B / EARTH_A) ** 2
    ep2 = (EARTH_A / EARTH_B) ** 2 - 1.0
    p = math.hypot(r[0], r[1])
    th = math.atan2(r[2] * EARTH_A, p * EARTH_B)
    lat = math.atan2(r[2] + ep2 * EARTH_B * math.sin(th) ** 3, p - e2 * EARTH_A * math.cos(th) ** 3)
    N = EARTH_A / math.sqrt(1.0 - e2 * math.sin(lat) ** 2)
    if abs(lat) < 1.0:
        return p / math.cos(lat) - N
    return r[2] / math.sin(lat) - N * (1.0 - e2)


def transmittance_table():
    """Transmittance to the top of the atmosphere, over (mu, r) in Bruneton
    and Neyret's mapping, RGB float32, rows by r."""
    Rg, Rt = EARTH_A, EARTH_A + ATMOS_TOP
    H = math.sqrt(Rt * Rt - Rg * Rg)
    xm = (np.arange(TRANS_W) + 0.5) / TRANS_W
    xr = (np.arange(TRANS_H) + 0.5) / TRANS_H
    rho = (H * xr)[:, None]
    r = np.sqrt(rho * rho + Rg * Rg)
    dmin, dmax = Rt - r, rho + H
    d = dmin + xm[None, :] * (dmax - dmin)
    mu = np.clip(np.where(d == 0, 1.0, (H * H - rho * rho - d * d) / (2 * r * d)), -1, 1)
    n = 500
    s = (np.arange(n) + 0.5) / n
    t = d[..., None] * s                                   # (h, w, n)
    rr = np.sqrt(r[..., None] ** 2 + t * t + 2 * r[..., None] * mu[..., None] * t)
    h = rr - Rg
    ds = (d / n)[..., None]
    tr = (np.exp(-h / RAYLEIGH_H) * ds).sum(-1)
    tm = (np.exp(-h / MIE_H) * ds).sum(-1)
    to = (np.clip(1 - np.abs(h - 25e3) / 15e3, 0, None) * ds).sum(-1)
    tau = (RAYLEIGH * tr[..., None] + MIE_EXT * tm[..., None] + OZONE * to[..., None])
    return np.exp(-tau).astype(np.float32)


EARTH_FS = """
#version 410 core
in vec2 vNdc;
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragTrans;     // what is behind passes x this
uniform mat3 uCamToEF;
uniform vec3 uOrigin;           // the eye, Earth-fixed, m
uniform vec3 uSun;              // the Sun's direction, Earth-fixed
uniform vec2 uTan;
uniform sampler2D uDay, uNight, uTrans, uWater;
uniform float uSunE, uNightGain, uLit, uMoonGain;
uniform vec3 uMoonEF;           // the Moon, Earth-fixed, m (its shadow: solar eclipses; moonlight)
uniform float uCTop, uCGround;  // |eye|^2 - radius^2, atmosphere top and ground (scaled space)
// A landing site's imagery: four nested rings, finest first.  Rings 0 and 1
// are placed from the eye's offset from the site (east, north, up; metres,
// from the CPU in double precision), exact to centimetres near the ground;
// rings 2 and 3, hundreds of kilometres across, by latitude and longitude.
uniform int uSiteOn;
uniform vec3 uCamEnu;
uniform mat3 uEfToEnu;
uniform vec4 uRingNear[2];      // u, v at the site; du/dEast, dv/dNorth (per m)
uniform vec4 uRingFar[2];       // lon0, lat0, lon1, lat1 (radians)
uniform sampler2D uRing0, uRing1, uRing2, uRing3;
// Fine patches (the runway at rollout, the launch pads): up to three, placed as rings 0-1.
uniform int uPatchCount;
uniform vec4 uPatch[3];         // as uRingNear
uniform sampler2D uPatch0, uPatch1, uPatch2;
// The ground's heights (m from the site's height), on rings 0-2's footprints
// (layers 0-2) and under some patches (uPatchHgt: a layer of uHgtP, or -1).
uniform int uHgtOn;
uniform sampler2DArray uHgt, uHgtP;
uniform int uPatchHgt[3];
uniform vec3 uSiteEF;           // the site, Earth-fixed (float: ring 2's placing only)
uniform float uSiteH;           // the site's height above sea level, m
uniform vec2 uInvR;             // 1 / (2 x the radii of curvature east and north), at the site
uniform float uHgtMax;          // the highest ground, m from the site's height
const float PI = 3.14159265358979;
const float R_SUN = 6.957e8, R_MOON = 1.7374e6, AU = 1.495978707e11;
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
const float A = """ + repr(EARTH_A) + """, K = """ + repr(EARTH_A / EARTH_B) + """;
const float E2 = """ + repr(1.0 - (EARTH_B / EARTH_A) ** 2) + """;
const float RG = A, RT = A + """ + repr(ATMOS_TOP) + """;
const vec3 B_R = vec3(""" + ", ".join(repr(float(x)) for x in RAYLEIGH) + """);
const vec3 B_O = vec3(""" + ", ".join(repr(float(x)) for x in OZONE) + """);
const float B_MS = """ + repr(MIE_SCAT) + """, B_ME = """ + repr(MIE_EXT) + """;
const float H_R = """ + repr(RAYLEIGH_H) + """, H_M = """ + repr(MIE_H) + """, G = """ + repr(MIE_G) + """;

// Bicubic B-spline in four bilinear taps (Sigg and Hadwiger, GPU Gems 2 ch. 20).
vec3 bicubic(sampler2D t, vec2 uv) {
    vec2 size = vec2(textureSize(t, 0));
    vec2 p = uv * size - 0.5;
    vec2 f = fract(p);
    p -= f;
    vec4 nx = vec4(1.0, 2.0, 3.0, 4.0) - f.x, ny = vec4(1.0, 2.0, 3.0, 4.0) - f.y;
    vec4 sx = nx * nx * nx, sy = ny * ny * ny;
    vec4 wx = vec4(sx.x, sx.y - 4.0 * sx.x, sx.z - 4.0 * sx.y + 6.0 * sx.x, 0.0);
    wx.w = 6.0 - wx.x - wx.y - wx.z;
    vec4 wy = vec4(sy.x, sy.y - 4.0 * sy.x, sy.z - 4.0 * sy.y + 6.0 * sy.x, 0.0);
    wy.w = 6.0 - wy.x - wy.y - wy.z;
    vec4 c = p.xxyy + vec2(-0.5, 1.5).xyxy;
    vec4 s = vec4(wx.xz + wx.yw, wy.xz + wy.yw);
    vec4 o = (c + vec4(wx.yw, wy.yw) / s) / size.xxyy;
    vec3 a = textureLod(t, o.xz, 0.0).rgb, b = textureLod(t, o.yz, 0.0).rgb;
    vec3 d = textureLod(t, o.xw, 0.0).rgb, e = textureLod(t, o.yw, 0.0).rgb;
    float tx = s.x / (s.x + s.y), ty = s.z / (s.z + s.w);
    return mix(mix(e, d, tx), mix(b, a, tx), ty);
}

float ringWeight(vec2 uv) {     // 1 inside, fading to 0 over the outer 4% to the edge
    vec2 e = min(uv, 1.0 - uv);
    return smoothstep(0.0, 0.04, min(e.x, e.y));
}

// A map of the Earth: mipmapped as usual, but bicubic where it is magnified
// (a texel wider than a pixel, low over the ground), so it blurs softly
// instead of showing its texels.
vec3 earthSample(sampler2D t, vec2 uv, vec2 gx, vec2 gy) {
    vec2 size = vec2(textureSize(t, 0));
    float texelsPerPixel = max(length(gx * size), length(gy * size));
    vec3 m = textureGrad(t, uv, gx, gy).rgb;
    if (texelsPerPixel >= 1.0) return m;
    return mix(bicubic(t, uv), m, smoothstep(0.5, 1.0, texelsPerPixel));
}

vec3 ringSample(sampler2D t, vec2 uv, float w, vec3 under) {
    vec2 gx = dFdx(uv), gy = dFdy(uv);
    if (w <= 0.0) return under;
    return mix(under, earthSample(t, uv, gx, gy), w);
}

// Rings 1-3 are Sentinel-2's 2016 mosaic, whose open sea is blotched by its
// cloud masking: over water they give way to Blue Marble's plain ocean (the
// NAIP of ring 0 and the patches is kept; its shore water is good).
vec3 siteImagery(vec3 albedo, float lon, float lat, vec3 enu, float water) {
    float land = 1.0 - water;
    if (uSiteOn == 0) return albedo;
    vec2 uv3 = vec2((lon - uRingFar[1].x) / (uRingFar[1].z - uRingFar[1].x),
                    (uRingFar[1].w - lat) / (uRingFar[1].w - uRingFar[1].y));
    vec2 uv2 = vec2((lon - uRingFar[0].x) / (uRingFar[0].z - uRingFar[0].x),
                    (uRingFar[0].w - lat) / (uRingFar[0].w - uRingFar[0].y));
    vec2 uv1 = uRingNear[1].xy + vec2(enu.x * uRingNear[1].z, -enu.y * uRingNear[1].w);
    vec2 uv0 = uRingNear[0].xy + vec2(enu.x * uRingNear[0].z, -enu.y * uRingNear[0].w);
    vec3 c = albedo;
    c = ringSample(uRing3, uv3, ringWeight(uv3) * land, c);
    c = ringSample(uRing2, uv2, ringWeight(uv2) * land, c);
    c = ringSample(uRing1, uv1, ringWeight(uv1) * land, c);
    c = ringSample(uRing0, uv0, ringWeight(uv0), c);
    if (uPatchCount > 0) {
        vec2 uvP = uPatch[0].xy + vec2(enu.x * uPatch[0].z, -enu.y * uPatch[0].w);
        c = ringSample(uPatch0, uvP, ringWeight(uvP), c);
    }
    if (uPatchCount > 1) {
        vec2 uvP = uPatch[1].xy + vec2(enu.x * uPatch[1].z, -enu.y * uPatch[1].w);
        c = ringSample(uPatch1, uvP, ringWeight(uvP), c);
    }
    if (uPatchCount > 2) {
        vec2 uvP = uPatch[2].xy + vec2(enu.x * uPatch[2].z, -enu.y * uPatch[2].w);
        c = ringSample(uPatch2, uvP, ringWeight(uvP), c);
    }
    return c;
}

// The ground's height at a point (east, north, up from the site; m from the
// site's height): the finest map there, blended at the rings' edges as the
// imagery is; sea level beyond ring 2.
float terrain(vec3 enu) {
    vec3 ef = uSiteEF + transpose(uEfToEnu) * enu;
    float lon = atan(ef.y, ef.x), lat = atan(ef.z, (1.0 - E2) * length(ef.xy));
    vec2 uv2 = vec2((lon - uRingFar[0].x) / (uRingFar[0].z - uRingFar[0].x),
                    (uRingFar[0].w - lat) / (uRingFar[0].w - uRingFar[0].y));
    vec2 uv1 = uRingNear[1].xy + vec2(enu.x * uRingNear[1].z, -enu.y * uRingNear[1].w);
    vec2 uv0 = uRingNear[0].xy + vec2(enu.x * uRingNear[0].z, -enu.y * uRingNear[0].w);
    float h = -uSiteH;
    h = mix(h, textureLod(uHgt, vec3(uv2, 2.0), 0.0).r, ringWeight(uv2));
    h = mix(h, textureLod(uHgt, vec3(uv1, 1.0), 0.0).r, ringWeight(uv1));
    h = mix(h, textureLod(uHgt, vec3(uv0, 0.0), 0.0).r, ringWeight(uv0));
    for (int i = 0; i < 3; i++) {
        if (i >= uPatchCount || uPatchHgt[i] < 0) continue;
        vec2 uvP = uPatch[i].xy + vec2(enu.x * uPatch[i].z, -enu.y * uPatch[i].w);
        h = mix(h, textureLod(uHgtP, vec3(uvP, float(uPatchHgt[i])), 0.0).r, ringWeight(uvP));
    }
    return h;
}

// The ray's height over the site's level: up, plus the ground's fall away
// from the tangent plane with distance.
float rayHeight(vec3 p) {
    return p.z + p.x * p.x * uInvR.x + p.y * p.y * uInvR.y;
}

// Where the ray from the eye (uCamEnu) along dE (east, north, up) meets the
// ground, no farther than tFar (m): a march, its steps no longer than the gap
// to the ground could close in (ground slopes to 1:2.5, or ~2% of the range),
// then bisection.  The slope there (dh/dEast, dh/dNorth) for the shading.
bool terrainHit(vec3 dE, float tFar, out float tHit, out vec2 slope) {
    float t = 0.0, tPrev = 0.0;
    tHit = 0.0;
    slope = vec2(0.0);
    vec3 p = uCamEnu;
    if (rayHeight(p) - terrain(p) < 0.0) return false;   // below it (map error): ignore it
    bool hit = false;
    for (int i = 0; i < 200; i++) {
        p = uCamEnu + t * dE;
        float hr = rayHeight(p), gap = hr - terrain(p);
        if (gap < 0.0) { hit = true; break; }
        float dU = dE.z + 2.0 * (p.x * dE.x * uInvR.x + p.y * dE.y * uInvR.y);
        if ((hr > uHgtMax && dU >= 0.0) || t > tFar) return false;
        tPrev = t;
        t += max(gap / (0.4 + max(-dU, 0.0)), max(0.5, 0.02 * t));
    }
    if (!hit) return false;
    float lo = tPrev, hi = t;
    for (int i = 0; i < 8; i++) {
        float mid = 0.5 * (lo + hi);
        vec3 q = uCamEnu + mid * dE;
        if (rayHeight(q) - terrain(q) < 0.0) hi = mid; else lo = mid;
    }
    tHit = 0.5 * (lo + hi);
    vec3 q = uCamEnu + tHit * dE;
    float e = clamp(0.002 * tHit, 2.0, 300.0);
    slope = vec2(terrain(q + vec3(e, 0.0, 0.0)) - terrain(q - vec3(e, 0.0, 0.0)),
                 terrain(q + vec3(0.0, e, 0.0)) - terrain(q - vec3(0.0, e, 0.0))) / (2.0 * e);
    return true;
}

vec3 transmittance(float r, float mu) {     // to the top of the atmosphere
    float H = sqrt(RT * RT - RG * RG);
    float rho = sqrt(max(r * r - RG * RG, 0.0));
    float d = max(-r * mu + sqrt(max(r * r * (mu * mu - 1.0) + RT * RT, 0.0)), 0.0);
    float dmin = RT - r, dmax = rho + H;
    vec2 uv = vec2((d - dmin) / max(dmax - dmin, 1.0), rho / H);
    uv = 0.5 / vec2(""" + "%d.0, %d.0" % (TRANS_W, TRANS_H) + """) + uv * (1.0 - 1.0 / vec2(""" + "%d.0, %d.0" % (TRANS_W, TRANS_H) + """));
    return texture(uTrans, uv).rgb;
}

// Sunlight reaching radius r at cos(zenith angle of the Sun) mu: through the
// air, and fading out as the Sun's disk (0.27 deg) sets behind the Earth.
vec3 sunlight(float r, float mu) {
    float muH = -sqrt(max(1.0 - (RG / r) * (RG / r), 0.0));
    return transmittance(r, mu) * smoothstep(muH - 0.0047, muH + 0.0047, mu);
}

void main() {
    vec3 dirEF = normalize(uCamToEF * vec3(vNdc * uTan, 1.0));
    // Work where the ellipsoid is a sphere of radius A (z stretched by K).
    vec3 o = uOrigin * vec3(1.0, 1.0, K);
    vec3 d = normalize(dirEF * vec3(1.0, 1.0, K));
    vec3 sun = normalize(uSun * vec3(1.0, 1.0, K));
    float b = dot(o, d);
    float c = uCTop;                 // |o|^2 - RT^2, from the CPU in double precision
    float disc = b * b - c;
    // The ground point, wanted outside any branch for the texture gradients.
    // The near root as c / (-b + sqrt(disc)), with c = |o|^2 - RG^2 from the
    // CPU in double precision: exact to millimetres at a few metres' height,
    // where -b - sqrt(disc) loses everything to cancellation in float.
    float discG = b * b - uCGround;
    float tg = uCGround / max(-b + sqrt(max(discG, 0.0)), 1e-6);
    bool ground = discG >= 0.0 && b < 0.0 && uCGround > 0.0;
    // Near a site with its ground's heights, the ground is that (uCGround is
    // then sea level's, beyond them); scaled-space distance = true x kd.
    vec2 slope = vec2(0.0);
    if (uHgtOn == 1) {
        float kd = length(dirEF * vec3(1.0, 1.0, K));
        float tHit;
        vec2 sl;
        if (terrainHit(uEfToEnu * dirEF, ground ? tg / kd : 6.0e5, tHit, sl)) {
            tg = tHit * kd;
            ground = true;
            slope = sl;
        }
    }
    vec3 rel = max(tg, 0.0) * d * vec3(1.0, 1.0, 1.0 / K);     // eye to ground, Earth-fixed
    vec3 pg = uOrigin + rel;                                     // Earth-fixed
    float lon = atan(pg.y, pg.x);
    float lat = atan(pg.z, (1.0 - E2) * length(pg.xy));
    vec2 uv = vec2((lon + PI) / (2.0 * PI), (0.5 * PI - lat) / PI);
    vec2 gx = dFdx(uv), gy = dFdy(uv);
    gx.x -= round(gx.x);
    gy.x -= round(gy.x);
    vec3 albedo = earthSample(uDay, uv, gx, gy);
    vec3 lights = earthSample(uNight, uv, gx, gy);
    float water = textureGrad(uWater, uv, gx, gy).r;
    albedo = siteImagery(albedo, lon, lat, uCamEnu + uEfToEnu * rel, water);
    if (disc < 0.0) discard;                       // misses the atmosphere
    float t0 = max(0.0, -b - sqrt(disc)), t1 = -b + sqrt(disc);
    if (t1 <= 0.0) discard;
    if (ground) t1 = tg;
    // In-scattering along the ray.
    float len = t1 - t0;
    int n = int(clamp(len / 25000.0, 8.0, 40.0));
    float ds = len / float(n);
    float nu = dot(d, sun);
    float pr = 3.0 / (16.0 * PI) * (1.0 + nu * nu);
    float pm = 3.0 / (8.0 * PI) * (1.0 - G * G) * (1.0 + nu * nu)
             / ((2.0 + G * G) * pow(1.0 + G * G - 2.0 * G * nu, 1.5));
    vec3 tau = vec3(0.0), inscat = vec3(0.0);
    for (int i = 0; i < n; i++) {
        vec3 p = o + (t0 + (float(i) + 0.5) * ds) * d;
        float r = length(p), h = r - RG;
        float rhoR = exp(-h / H_R), rhoM = exp(-h / H_M);
        float rhoO = max(0.0, 1.0 - abs(h - 25000.0) / 15000.0);
        vec3 ext = B_R * rhoR + B_ME * rhoM + B_O * rhoO;
        vec3 tv = exp(-(tau + 0.5 * ext * ds));
        vec3 ts = sunlight(r, dot(p, sun) / r);
        // single scattering, and a little more for the light scattered many times
        inscat += tv * ts * (B_R * rhoR * (pr + 0.02) + B_MS * rhoM * pm) * ds;
        tau += ext * ds;
    }
    vec3 trans = exp(-tau);
    vec3 color = inscat * uSunE;
    if (ground) {
        vec3 n = normalize(vec3(pg.xy, pg.z * K * K));        // geodetic normal
        mat3 enuToEf = transpose(uEfToEnu);                    // tilted by the ground's slope
        n = normalize(n - slope.x * enuToEf[0] - slope.y * enuToEf[1]);
        float mus = dot(n, uSun);
        vec3 ts = sunlight(RG, dot(normalize(o + tg * d), sun));
        vec3 toMoon = uMoonEF - pg;
        float dm = length(toMoon);
        float sep = acos(clamp(dot(toMoon / dm, uSun), -1.0, 1.0));
        ts *= uncovered(R_SUN / AU, R_MOON / dm, sep);
        // Lambertian ground (albedo / pi), in the same units as the air's light.
        vec3 direct = albedo / PI * max(mus, 0.0) * ts;
        vec3 sky = albedo / PI * vec3(0.05, 0.065, 0.09) * smoothstep(-0.12, 0.25, mus);
        // Sun glint on water: the GEBCO mask, bilinear, so coastlines stay smooth.
        vec3 hv = normalize(uSun - dirEF);
        float fres = 0.02 + 0.98 * pow(1.0 - max(dot(-dirEF, hv), 0.0), 5.0);
        // Wave slopes ~0.1 rad (Blinn exponent ~200): a peak about as bright as land.
        float spec = water * fres * pow(max(dot(n, hv), 0.0), 200.0) * 8.0 / PI * step(0.0, mus);
        // Moonlight, on the night side's scale with the city lights: the
        // ground lit by the Moon (its brightness by phase, Allen's lunar
        // magnitudes), and the Moon's glint on the sea.
        vec3 md = toMoon / dm;
        float mum = dot(n, md);
        float alpha = degrees(acos(clamp(-dot(md, uSun), -1.0, 1.0)));
        float phase = pow(10.0, -0.4 * (0.026 * alpha + 4.0e-9 * pow(alpha, 4.0)));
        vec3 tm = sunlight(RG, dot(normalize(o + tg * d), normalize(md * vec3(1.0, 1.0, K))));
        vec3 hm = normalize(md - dirEF);
        float fresm = 0.02 + 0.98 * pow(1.0 - max(dot(-dirEF, hm), 0.0), 5.0);
        float specm = water * fresm * pow(max(dot(n, hm), 0.0), 200.0) * 8.0 / PI * step(0.0, mum);
        vec3 moonlit = (albedo / PI * max(mum, 0.0) + specm) * tm * phase * uMoonGain;
        vec3 night = (lights + moonlit) * uNightGain * (1.0 - smoothstep(-0.1, 0.02, mus));
        vec3 surf = (direct + sky + spec * ts) * uSunE * uLit + night;
        color += surf * trans;
        fragColor = vec4(color, 1.0);
        fragTrans = vec4(0.0);
    } else {
        fragColor = vec4(color, 1.0);
        fragTrans = vec4(trans, 1.0);
    }
}
"""

# Without a date or an Earth orientation, the Earth is still in the way: a
# plain dark ellipsoid hides what is behind it.
EARTH_PLAIN_FS = """
#version 410 core
in vec2 vNdc;
uniform mat3 uCamToEF;
uniform vec3 uOrigin;
uniform vec2 uTan;
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragTrans;
const float A = """ + repr(EARTH_A) + """, K = """ + repr(EARTH_A / EARTH_B) + """;
void main() {
    vec3 o = uOrigin * vec3(1.0, 1.0, K);
    vec3 d = normalize((uCamToEF * vec3(vNdc * uTan, 1.0)) * vec3(1.0, 1.0, K));
    float b = dot(o, d), c = dot(o, o) - A * A;
    if (b * b - c < 0.0 || -b - sqrt(b * b - c) <= 0.0) discard;
    fragColor = vec4(0.004, 0.006, 0.010, 1.0);
    fragTrans = vec4(0.0);
}
"""


def gmst_matrix(unix):
    """A rough M50 -> Earth-fixed rotation from the time alone (the Earth's
    rotation, no precession: ~0.7 deg off), for when TRU1 has no matrix."""
    d = unix / 86400.0 + 2440587.5 - 2451545.0
    th = math.radians((280.46061837 + 360.98564736629 * d) % 360.0)
    R = np.array([[math.cos(th), math.sin(th), 0.0], [-math.sin(th), math.cos(th), 0.0],
                  [0.0, 0.0, 1.0]])
    return R @ J2000_TO_M50.T


class Site(object):
    """A landing site's ring imagery (portview/fetch_assets.py) and its place:
    the centre on PASS's ellipsoid at the runway's height, the east-north-up
    frame there, and the rings' mappings."""

    def __init__(self, path):
        import json
        with open(os.path.join(path, "ring.json")) as f:
            meta = json.load(f)
        if len(meta['rings']) != 4:
            raise ValueError("expected four rings in %s" % path)
        self.name = meta['name']
        self.height = meta['alt_ft'] * 0.3048
        lat, lon = math.radians(meta['lat']), math.radians(meta['lon'])
        e2 = 1.0 - (EARTH_B / EARTH_A) ** 2
        sl, cl, so, co = math.sin(lat), math.cos(lat), math.sin(lon), math.cos(lon)
        Nr = EARTH_A / math.sqrt(1.0 - e2 * sl * sl)          # prime vertical radius
        Mr = EARTH_A * (1.0 - e2) / (1.0 - e2 * sl * sl) ** 1.5   # meridian radius
        h = self.height
        self.ef = np.array([(Nr + h) * cl * co, (Nr + h) * cl * so, (Nr * (1.0 - e2) + h) * sl])
        self.ef_to_enu = np.array([[-so, co, 0.0], [-sl * co, -sl * so, cl], [cl * co, cl * so, sl]])
        def near_map(bounds):           # u, v at the site; du/dEast, dv/dNorth
            lon0, lat0, lon1, lat1 = (math.radians(v) for v in bounds)
            return [(lon - lon0) / (lon1 - lon0), (lat1 - lat) / (lat1 - lat0),
                    1.0 / ((Nr + h) * cl * (lon1 - lon0)), 1.0 / ((Mr + h) * (lat1 - lat0))]
        near, far = [], []
        for k, r in enumerate(meta['rings']):
            if k < 2:
                near.append(near_map(r['bounds']))
            else:
                far.append([math.radians(v) for v in r['bounds']])
        self.near, self.far = np.array(near), np.array(far)
        self.images = [load_rgb(os.path.join(path, r['file'])) for r in meta['rings']]
        # Fine patches: the runway's (ringF), then any others (the launch
        # pads); at most three.
        patches = ([meta['fine']] if meta.get('fine') else []) + list(meta.get('patches', {}).values())
        patches = patches[:3]
        self.patches = np.array([near_map(p['bounds']) for p in patches]).reshape(-1, 4)
        self.patch_images = [load_rgb(os.path.join(path, p['file'])) for p in patches]
        # The ground's heights (3DEP, sea level) under rings 0-2 and some
        # patches, as metres from the site's height; None without them.
        self.inv_r = (0.5 / (Nr + h), 0.5 / (Mr + h))
        self.heights = None
        if meta.get('heights') and TERRAIN['on']:
            self.heights = np.stack([np.load(os.path.join(path, f)) for f in meta['heights']]) - h
        self.patch_heights = [np.load(os.path.join(path, p['height'])) - h
                              if TERRAIN['on'] and p.get('height') else None for p in patches]


class EarthLayer(object):
    target = 'earth'                    # draws into the view's Earth buffers
    SUN_E = 2.0 * math.pi               # sunlight: a sunlit albedo-0.3 ground shows ~0.6
    NIGHT_GAIN = 0.3                    # city lights, display-referred
    # Full-moonlit ground against the city lights, as in VIIRS night images:
    # albedo-0.3 ground under a full Moon overhead shows ~0.04, a town ~0.1.
    MOON_GAIN = 1.4

    def draw(self, res, view, fs):
        m = fs.m50_to_ef
        if m is None and fs.unix is not None:
            m = gmst_matrix(fs.unix)
        f32 = np.float32
        if m is None or fs.sky is None:
            # No orientation: the Earth's place is known (it is the origin),
            # but not its face or the Sun.  M50 axes stand in for Earth-fixed.
            prog, U = res.earthPlainProg, res.earthPlainU
            GL.glUseProgram(prog)
            GL.glUniformMatrix3fv(U["uCamToEF"], 1, GL.GL_TRUE, (fs.C @ view.basis).astype(f32))
            GL.glUniform3fv(U["uOrigin"], 1, view_eye(view, fs).astype(f32))
            GL.glUniform2f(U["uTan"], view.tanX, view.tanY)
            GL.glDrawArrays(GL.GL_TRIANGLES, 0, 3)
            return
        res.set_month(fs.unix)
        U = res.earthU
        GL.glUseProgram(res.earthProg)
        GL.glUniformMatrix3fv(U["uCamToEF"], 1, GL.GL_TRUE, (m @ fs.C @ view.basis).astype(f32))
        eye = view_eye(view, fs)                     # M50, the crew's eye
        GL.glUniform3fv(U["uOrigin"], 1, (m @ eye).astype(f32))
        sun = unit(m @ J2000_TO_M50 @ fs.sky.pos['sun'])
        GL.glUniform3fv(U["uSun"], 1, sun.astype(f32))
        GL.glUniform3fv(U["uMoonEF"], 1, (m @ J2000_TO_M50 @ fs.sky.pos['moon']).astype(f32))
        # In double precision here, so the shader never subtracts big numbers.
        o_ef = m @ eye
        o_s = o_ef * np.array([1.0, 1.0, EARTH_A / EARTH_B])
        site = res.site
        # The ground's heights near the site, while the eye is within ~60 km
        # of the ground there (from higher, the relief is a few pixels).
        terrain = (site is not None and res.hgtMax != 0.0
                   and np.linalg.norm(site.ef_to_enu @ (m @ eye - site.ef)) < 6.5e5
                   and (site.ef_to_enu @ (m @ eye - site.ef))[2] < 6.0e4)
        ground_r = EARTH_A + (site.height if site is not None and not terrain else 0.0)
        GL.glUniform1f(U["uCTop"], float(o_s @ o_s - (EARTH_A + ATMOS_TOP) ** 2))
        GL.glUniform1f(U["uCGround"], float(o_s @ o_s - ground_r ** 2))
        GL.glUniform1i(U["uSiteOn"], 1 if site is not None else 0)
        if site is not None:
            GL.glUniform3fv(U["uCamEnu"], 1, (site.ef_to_enu @ (o_ef - site.ef)).astype(f32))
            GL.glUniformMatrix3fv(U["uEfToEnu"], 1, GL.GL_TRUE, site.ef_to_enu.astype(f32))
            GL.glUniform4fv(U["uRingNear"], 2, site.near.astype(f32))
            GL.glUniform4fv(U["uRingFar"], 2, site.far.astype(f32))
            GL.glUniform1i(U["uHgtOn"], 1 if terrain else 0)
            GL.glUniform3fv(U["uSiteEF"], 1, site.ef.astype(f32))
            GL.glUniform1f(U["uSiteH"], site.height)
            GL.glUniform2f(U["uInvR"], *site.inv_r)
            GL.glUniform1f(U["uHgtMax"], res.hgtMax)
            GL.glUniform1iv(U["uPatchHgt"], 3, np.array(res.patchHgtLayer, np.int32))
            for k in range(4):
                GL.glActiveTexture(GL.GL_TEXTURE4 + k)
                GL.glBindTexture(GL.GL_TEXTURE_2D, res.ringTex[k])
                GL.glUniform1i(U["uRing%d" % k], 4 + k)
            n = len(site.patches)
            GL.glUniform1i(U["uPatchCount"], n)
            if n:
                GL.glUniform4fv(U["uPatch"], n, site.patches.astype(f32))
            for k in range(3):
                if k < n:
                    GL.glActiveTexture(GL.GL_TEXTURE8 + k)
                    GL.glBindTexture(GL.GL_TEXTURE_2D, res.patchTex[k])
                    GL.glUniform1i(U["uPatch%d" % k], 8 + k)
                else:
                    GL.glUniform1i(U["uPatch%d" % k], 3)
        else:
            for k in range(4):                 # samplers must name a unit even if unused
                GL.glUniform1i(U["uRing%d" % k], 3)
            for k in range(3):
                GL.glUniform1i(U["uPatch%d" % k], 3)
            GL.glUniform1i(U["uPatchCount"], 0)
        if site is None:
            GL.glUniform1i(U["uHgtOn"], 0)
        GL.glActiveTexture(GL.GL_TEXTURE11)
        GL.glBindTexture(GL.GL_TEXTURE_2D_ARRAY, res.hgtTex)
        GL.glUniform1i(U["uHgt"], 11)
        GL.glActiveTexture(GL.GL_TEXTURE12)
        GL.glBindTexture(GL.GL_TEXTURE_2D_ARRAY, res.hgtPTex)
        GL.glUniform1i(U["uHgtP"], 12)
        GL.glUniform2f(U["uTan"], view.tanX, view.tanY)
        GL.glUniform1f(U["uSunE"], self.SUN_E)
        GL.glUniform1f(U["uNightGain"], self.NIGHT_GAIN)
        GL.glUniform1f(U["uMoonGain"], self.MOON_GAIN)
        GL.glUniform1f(U["uLit"], 1.0)
        for unit_, name, tex in ((0, "uDay", res.earthDayTex), (1, "uNight", res.earthNightTex),
                                 (2, "uTrans", res.transTex), (3, "uWater", res.waterTex)):
            GL.glActiveTexture(GL.GL_TEXTURE0 + unit_)
            GL.glBindTexture(GL.GL_TEXTURE_2D, tex)
            GL.glUniform1i(U[name], unit_)
        GL.glActiveTexture(GL.GL_TEXTURE0)
        GL.glDrawArrays(GL.GL_TRIANGLES, 0, 3)


# --------------------------------------------------------------------------
# Other vehicles (the ISS): real 3-D models, in front of the Earth (drawn into
# the Earth's buffers, opaque), lit by the Sun -- less the part of its disk the
# Earth hides, so they go dark in the Earth's shadow -- with a little
# earthshine.  A vehicle beyond the Earth's limb (the Earth between) isn't
# drawn; at such ranges it would be well under a pixel anyway.

MODEL_VS = """
#version 410 core
in vec3 aPos;
in vec3 aNrm;
in vec2 aUv;
uniform mat3 uRot;              // vehicle body -> camera
uniform vec3 uTrans;            // the vehicle's origin in the camera frame, m
uniform vec2 uTan;
uniform float uNear, uFar;
// CENTROID: multisampled, an edge pixel's colour is computed once for its
// covered samples -- by default at the pixel's centre, which may lie off the
// triangle, where the texture coordinates and normal are extrapolated past
// its edge: a line of wrong, often bright, pixels crawling along every
// outline against black space.  At the covered samples' centroid instead.
centroid out vec3 vNrm;         // body frame
centroid out vec3 vPos;         // body frame
centroid out vec2 vUv;
centroid out float vDist;       // the camera-frame depth, for the fragment's own
void main() {
    vec3 c = uRot * aPos + uTrans;
    // Depth linear in distance over just this vehicle's span: exact to well
    // under a millimetre in 24 bits.  (Clipping only: the depth tested is the
    // fragment's own, below.)
    float z = ((c.z - uNear) / (uFar - uNear)) * 2.0 - 1.0;
    gl_Position = vec4(c.x / uTan.x, c.y / uTan.y, z * c.z, c.z);
    vDist = c.z;
    vNrm = aNrm;
    vPos = aPos;
    vUv = aUv;
}
"""

MODEL_FS = """
#version 410 core
centroid in vec3 vNrm;
centroid in vec3 vPos;
centroid in vec2 vUv;
centroid in float vDist;
uniform float uNear, uFar;
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragTrans;
uniform sampler2D uTex;
uniform int uHasTex;
uniform vec4 uColor;
uniform vec3 uSunB;             // the Sun's direction, body frame
uniform vec3 uEyeB;             // the eye, body frame, m
uniform vec3 uEarthB;           // the Earth's direction (nadir), body frame
uniform float uSunE, uSunVis, uEarthLit;
const float PI = 3.14159265358979;
void main() {
    vec3 alb = uColor.rgb;
    if (uHasTex != 0) alb *= texture(uTex, vUv).rgb;
    vec3 n = normalize(vNrm);
    vec3 toEye = normalize(uEyeB - vPos);
    if (dot(n, toEye) < 0.0) n = -n;                 // two-sided
    float sun = max(dot(n, uSunB), 0.0) * uSunVis;
    // Earthshine: the sunlit Earth below, broad (the Earth fills ~140 deg).
    float earth = 0.3 * uEarthLit * (0.5 + 0.5 * dot(n, uEarthB));
    vec3 h = normalize(uSunB + toEye);
    float spec = 0.04 * pow(max(dot(n, h), 0.0), 40.0) * uSunVis * step(0.0, dot(n, uSunB));
    vec3 c = (alb / PI * (sun + earth + 0.01) + spec) * uSunE;
    fragColor = vec4(c, 0.0);       // alpha 0: a vehicle here (no dither; see PRESENT_FS)
    fragTrans = vec4(0.0);
    // ITS OWN DEPTH, from its interpolated distance.  The depth the vertex
    // stage gives is linear in distance at the corners, but the rasterizer
    // interpolates it linearly across the screen, which is right only for
    // 1/z: along a long triangle seen obliquely it was off by ~L*L/(8d)
    // (14 cm on a 4.3 m drum at 17 m), and a lining 5 cm behind a surface
    // showed through it.  vDist is interpolated perspective-correctly.
    gl_FragDepth = clamp((vDist - uNear) / (uFar - uNear), 0.0, 1.0);
}
"""


class Model(object):
    """A prepared model (portview/fetch_assets.py): per material, vertices in
    the vehicle's body frame (m), triangles, colour and texture."""

    def __init__(self, path, point=True):
        import json
        with open(os.path.join(path, "model.json")) as f:
            self.meta = json.load(f)
        z = np.load(os.path.join(path, "model.npz"))
        self.point = point              # far away, a point by magnitude (vehicles only)
        self.parts = []
        for k, m in enumerate(self.meta['materials']):
            data = np.hstack([z['pos%d' % k], z['nrm%d' % k], z['uv%d' % k]]).astype(np.float32)
            img = load_rgb(os.path.join(path, m['texture'])) if m['texture'] else None
            self.parts.append(dict(data=data, idx=np.ascontiguousarray(z['idx%d' % k], np.uint32),
                                   color=m['color'], img=img))
        pos = np.vstack([z['pos%d' % k] for k in range(len(self.meta['materials']))])
        self.radius = float(np.max(np.linalg.norm(pos, axis=1)))
        self.ready = False

    def build(self):
        """Buffers and textures, in the first view's (shared) context."""
        for p in self.parts:
            p['vbo'] = GL.glGenBuffers(1)
            GL.glBindBuffer(GL.GL_ARRAY_BUFFER, p['vbo'])
            GL.glBufferData(GL.GL_ARRAY_BUFFER, p['data'].nbytes, p['data'], GL.GL_STATIC_DRAW)
            p['ebo'] = GL.glGenBuffers(1)
            GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, p['ebo'])
            GL.glBufferData(GL.GL_ELEMENT_ARRAY_BUFFER, p['idx'].nbytes, p['idx'], GL.GL_STATIC_DRAW)
            p['count'] = len(p['idx'])
            p['tex'] = make_srgb_texture(p['img']) if p['img'] is not None else None
            for wrap in (GL.GL_TEXTURE_WRAP_S, GL.GL_TEXTURE_WRAP_T):
                if p['tex'] is not None:
                    GL.glTexParameteri(GL.GL_TEXTURE_2D, wrap, GL.GL_REPEAT)
            p['data'] = p['idx'] = p['img'] = None
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, 0)
        self.ready = True


class GroundObject(object):
    """A model fixed to the ground (the launch pad's structures): its frame
    east-north-up at a geodetic point on PASS's ellipsoid, turned by heading
    (deg, clockwise from north) -- placed each frame through the Earth's
    orientation, so it turns with the Earth like everything on the ground."""

    def __init__(self, key, lat, lon, height, heading=0.0, offset=(0.0, 0.0)):
        self.key = key
        self.offset = offset            # the model point (east, north, m) placed at lat, lon
        e2 = 1.0 - (EARTH_B / EARTH_A) ** 2
        la, lo = math.radians(lat), math.radians(lon)
        Nr = EARTH_A / math.sqrt(1.0 - e2 * math.sin(la) ** 2)
        self.ef = np.array([(Nr + height) * math.cos(la) * math.cos(lo),
                            (Nr + height) * math.cos(la) * math.sin(lo),
                            (Nr * (1.0 - e2) + height) * math.sin(la)])
        east = np.array([-math.sin(lo), math.cos(lo), 0.0])
        north = np.array([-math.sin(la) * math.cos(lo), -math.sin(la) * math.sin(lo), math.cos(la)])
        up = np.cross(east, north)
        h = math.radians(heading)
        e2_, n2_ = math.cos(h) * east - math.sin(h) * north, math.sin(h) * east + math.cos(h) * north
        self.axes = np.column_stack([e2_, n2_, up])          # model -> Earth-fixed
        self.ef = self.ef - self.axes @ np.array([offset[0], offset[1], 0.0])

    def state(self, fs):
        m = fs.m50_to_ef if fs.m50_to_ef is not None else gmst_matrix(fs.unix)
        return m.T @ self.ef, m.T @ self.axes


class VehicleLayer(object):
    """The vehicles in TGT1 (by NORAD id), each with its model.  Far away
    its parts are thinner than a pixel and vanish, so a point like a star, by
    its magnitude when sunlit (the ISS: about -1.8 at 1000 km, full phase),
    fades in as it shrinks below FADE_PX pixels in radius; under MODEL_PX
    the model isn't drawn at all."""
    target = 'earth'
    SUN_E = 2.0 * math.pi               # as the Earth's ground
    MODEL_PX = 1.5
    FADE_PX = 10.0
    MAG_1000KM = -1.8

    def __init__(self, models, exposure):
        self.models = models            # NORAD id -> Model
        self.points = PointLayer(exposure, 'vehicles')

    def draw(self, res, view, fs):
        if not fs.targets or fs.sky is None:
            return
        cam = fs.C @ view.basis                                  # camera -> M50
        eye = view_eye(view, fs)                                 # M50
        sun_m50 = J2000_TO_M50 @ fs.sky.pos['sun']
        for vid, (r, Cv) in fs.targets.items():
            model = self.models.get(vid)
            if model is None:
                continue
            d = r - eye
            dist = float(np.linalg.norm(d))
            if dist < 1e-3 or behind_earth(eye, r):
                continue
            rel = cam.T @ d                                      # camera frame, double
            if rel[2] < -model.radius:
                continue
            to_sun = sun_m50 - r
            dsun = float(np.linalg.norm(to_sun))
            sep = math.acos(max(-1.0, min(1.0, float(np.dot(to_sun / dsun, -r / np.linalg.norm(r))))))
            vis = uncovered_disk(R_SUN / dsun, EARTH_A / float(np.linalg.norm(r)), sep)
            px = model.radius / dist * (view.view_size()[0] / 2.0) / view.tanX
            if model.point and px < self.FADE_PX and vis > 0.01 and rel[2] > 0:
                # Phase: lit fraction seen from the eye, as a Lambert sphere.
                phase = 0.5 * (1.0 + float(np.dot(to_sun / dsun, -d / dist)))
                fade = min(1.0, (self.FADE_PX - px) / (self.FADE_PX - self.MODEL_PX))
                mag = (model.meta.get('mag_1000km', self.MAG_1000KM) + 5.0 * math.log10(dist / 1.0e6)
                       - 2.5 * math.log10(max(vis * phase * fade, 1e-6)))
                self._point(res, view, fs, J2000_TO_M50.T @ (d / dist), mag)
            if px < self.MODEL_PX:
                continue
            if not model.ready:
                model.build()
            sun_b = Cv.T @ (to_sun / dsun)
            earth_b = Cv.T @ (-r / np.linalg.norm(r))
            # The Earth below lit: the Sun's height over the sub-vehicle point.
            earth_lit = max(0.0, float(np.dot(r / np.linalg.norm(r), to_sun / dsun)))
            U = res.modelU
            f32 = np.float32
            GL.glUseProgram(res.modelProg)
            GL.glUniformMatrix3fv(U["uRot"], 1, GL.GL_TRUE, (cam.T @ Cv).astype(f32))
            GL.glUniform3fv(U["uTrans"], 1, rel.astype(f32))
            GL.glUniform2f(U["uTan"], view.tanX, view.tanY)
            GL.glUniform1f(U["uNear"], max(0.05, dist - model.radius))
            GL.glUniform1f(U["uFar"], dist + model.radius)
            GL.glUniform3fv(U["uSunB"], 1, sun_b.astype(f32))
            GL.glUniform3fv(U["uEyeB"], 1, (Cv.T @ (-d)).astype(f32))
            GL.glUniform3fv(U["uEarthB"], 1, earth_b.astype(f32))
            GL.glUniform1f(U["uSunE"], self.SUN_E)
            GL.glUniform1f(U["uSunVis"], vis)
            GL.glUniform1f(U["uEarthLit"], earth_lit)
            GL.glUniform1i(U["uTex"], 0)
            GL.glEnable(GL.GL_DEPTH_TEST)
            GL.glClear(GL.GL_DEPTH_BUFFER_BIT)
            for p in model.parts:
                vao = view.modelVaos.get((vid, id(p)))
                if vao is None:
                    vao = view.modelVaos[(vid, id(p))] = GL.glGenVertexArrays(1)
                    GL.glBindVertexArray(vao)
                    GL.glBindBuffer(GL.GL_ARRAY_BUFFER, p['vbo'])
                    GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, p['ebo'])
                    for name, size, off in (("aPos", 3, 0), ("aNrm", 3, 3), ("aUv", 2, 6)):
                        loc = GL.glGetAttribLocation(res.modelProg, name)
                        GL.glEnableVertexAttribArray(loc)
                        GL.glVertexAttribPointer(loc, size, GL.GL_FLOAT, GL.GL_FALSE, 32,
                                                 GL.ctypes.c_void_p(4 * off))
                GL.glBindVertexArray(vao)
                GL.glUniform4fv(U["uColor"], 1, np.asarray(p['color'], f32))
                GL.glUniform1i(U["uHasTex"], 1 if p['tex'] is not None else 0)
                if p['tex'] is not None:
                    GL.glActiveTexture(GL.GL_TEXTURE0)
                    GL.glBindTexture(GL.GL_TEXTURE_2D, p['tex'])
                GL.glDrawElements(GL.GL_TRIANGLES, p['count'], GL.GL_UNSIGNED_INT, None)
            GL.glBindVertexArray(view.vao)
            GL.glDisable(GL.GL_DEPTH_TEST)

    def _point(self, res, view, fs, dir_j2k, mag):
        """A vehicle as a point (the eye's offset from TRU1's point is
        negligible at such ranges; the star program uses the latter)."""
        if not hasattr(res, 'vehicleVbo'):
            res.vehicleVbo = GL.glGenBuffers(1)
        data = np.array([[*dir_j2k, mag, 1.0, 1.0, 1.0]], np.float32)
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, res.vehicleVbo)
        GL.glBufferData(GL.GL_ARRAY_BUFFER, data.nbytes, data, GL.GL_DYNAMIC_DRAW)
        GL.glBindBuffer(GL.GL_ARRAY_BUFFER, 0)
        self.points.draw_points(res, view, fs, res.vehicleVbo, 1)


def view_eye(view, fs):
    """The crew's eye for a view, M50 (m): TRU1's centre of mass, plus the eye's
    offset from the dry CG, less the centre of mass's (TRU1 [27-29])."""
    return fs.r + fs.C @ (np.asarray(view.spec['eye'], float) - fs.cg)


def behind_earth(eye, r):
    """Whether the Earth (PASS's ellipsoid) is between eye and r (M50; the
    flattening ignored here, a few km at most)."""
    d = r - eye
    L = float(np.linalg.norm(d))
    u = d / L
    b = float(np.dot(eye, u))
    c = float(np.dot(eye, eye)) - EARTH_B ** 2
    disc = b * b - c
    if disc < 0:
        return False
    t = -b - math.sqrt(disc)
    return 0 < t < L


def uncovered_disk(a, b, sep):
    """The fraction of a disk of angular radius a uncovered by one of radius b,
    their centres sep apart (as the shaders' uncovered())."""
    if sep >= a + b:
        return 1.0
    if sep <= b - a:
        return 0.0
    if sep <= a - b:
        return 1.0 - (b * b) / (a * a)
    x = (sep * sep + a * a - b * b) / (2 * sep)
    y = sep - x
    area = (a * a * math.acos(max(-1.0, min(1.0, x / a))) - x * math.sqrt(max(a * a - x * x, 0.0))
            + b * b * math.acos(max(-1.0, min(1.0, y / b))) - y * math.sqrt(max(b * b - y * y, 0.0)))
    return 1.0 - area / (math.pi * a * a)


# --------------------------------------------------------------------------
# The windows.

def confirm_quit(parent):
    """Quit every view, once asked: a slip of the fingers shouldn't end a
    flight's views (closing one window still closes just that view)."""
    ans = QtWidgets.QMessageBox.question(
        parent, "Quit portview", "Close all of portview's views?",
        QtWidgets.QMessageBox.StandardButton.Yes | QtWidgets.QMessageBox.StandardButton.No,
        QtWidgets.QMessageBox.StandardButton.No)
    if ans == QtWidgets.QMessageBox.StandardButton.Yes:
        QtWidgets.QApplication.quit()


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
        self.modelVaos = {}
        self.frames = 0
        self.hdrFbo = self.hdrTex = None
        self.earthFbo = self.earthTex = self.earthTransTex = None
        self.depthRb = None
        self.earthMs = None                 # (fbo, [renderbuffers]) when multisampled
        self.hdrSize = None
        self.setWindowTitle(spec['title'])
        self.resize(max(64, round(spec['w'] * scale)) + 2 * FRAME_PX,
                    max(36, round(spec['h'] * scale)) + 2 * FRAME_PX)

    def initializeGL(self):
        Resources.get().build()
        self.vao = GL.glGenVertexArrays(1)

    def view_size(self):
        """The viewing area, logical px: the window less its frame."""
        return (max(1, self.width() - 2 * FRAME_PX), max(1, self.height() - 2 * FRAME_PX))

    def _fov(self):
        w, h = self.view_size()
        if self.crop:
            f = self.focal768
        else:
            f = (w / 2.0) / math.tan(self.spec['hfov'] * D2R / 2.0)
        self.tanX, self.tanY = (w / 2.0) / f, (h / 2.0) / f

    def _hdr_target(self, w, h):
        """The view's linear floating-point buffers, remade on a resize: the
        sky, and the Earth's colour and transmittance in front of it."""
        if self.hdrSize == (w, h):
            return
        if self.hdrFbo is not None:
            GL.glDeleteFramebuffers(2, [self.hdrFbo, self.earthFbo])
            GL.glDeleteTextures([self.hdrTex, self.earthTex, self.earthTransTex])
            GL.glDeleteRenderbuffers(1, [self.depthRb])
        if self.earthMs is not None:
            GL.glDeleteFramebuffers(1, [self.earthMs[0]])
            GL.glDeleteRenderbuffers(3, self.earthMs[1])
            self.earthMs = None

        def tex():
            t = GL.glGenTextures(1)
            GL.glBindTexture(GL.GL_TEXTURE_2D, t)
            GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_RGBA16F, w, h, 0,
                            GL.GL_RGBA, GL.GL_HALF_FLOAT, None)
            GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST)
            GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST)
            return t
        self.hdrTex, self.earthTex, self.earthTransTex = tex(), tex(), tex()
        self.hdrFbo, self.earthFbo = GL.glGenFramebuffers(2)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.hdrFbo)
        GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_COLOR_ATTACHMENT0,
                                  GL.GL_TEXTURE_2D, self.hdrTex, 0)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.earthFbo)
        for i, t in enumerate((self.earthTex, self.earthTransTex)):
            GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_COLOR_ATTACHMENT0 + i,
                                      GL.GL_TEXTURE_2D, t, 0)
        GL.glDrawBuffers(2, [GL.GL_COLOR_ATTACHMENT0, GL.GL_COLOR_ATTACHMENT1])
        self.depthRb = GL.glGenRenderbuffers(1)              # for vehicles' own surfaces
        GL.glBindRenderbuffer(GL.GL_RENDERBUFFER, self.depthRb)
        GL.glRenderbufferStorage(GL.GL_RENDERBUFFER, GL.GL_DEPTH_COMPONENT24, w, h)
        GL.glFramebufferRenderbuffer(GL.GL_FRAMEBUFFER, GL.GL_DEPTH_ATTACHMENT,
                                     GL.GL_RENDERBUFFER, self.depthRb)
        # ANTI-ALIASED VEHICLES.  The ISS's 1.9 million triangles are mostly
        # handrails and struts finer than a pixel: drawn once a pixel, each
        # pixel caught one or missed it, and as the station moved its detail
        # swarmed.  So the Earth-and-vehicles pass is multisampled and
        # averaged down into the textures above: an edge pixel is then the
        # vehicle by its coverage, over whatever is behind (the
        # transmittance averages too).  The Earth's ray-cast still runs once
        # a pixel.  Fewer samples if the driver can't, none in 'reduced'.
        n = MSAA['samples'] if TEXTURES['mode'] != 'reduced' else 0
        try:
            n = min(n, int(GL.glGetIntegerv(GL.GL_MAX_SAMPLES)))
        except (GL.GLError, TypeError, ValueError):
            pass
        while n > 1:
            fbo = GL.glGenFramebuffers(1)
            rbs = list(GL.glGenRenderbuffers(3))
            GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, fbo)
            try:
                for i, (rb, fmt) in enumerate(zip(rbs, (GL.GL_RGBA16F, GL.GL_RGBA16F,
                                                        GL.GL_DEPTH_COMPONENT24))):
                    GL.glBindRenderbuffer(GL.GL_RENDERBUFFER, rb)
                    GL.glRenderbufferStorageMultisample(GL.GL_RENDERBUFFER, n, fmt, w, h)
                    GL.glFramebufferRenderbuffer(GL.GL_FRAMEBUFFER, GL.GL_DEPTH_ATTACHMENT if i == 2
                                                 else GL.GL_COLOR_ATTACHMENT0 + i, GL.GL_RENDERBUFFER, rb)
                GL.glDrawBuffers(2, [GL.GL_COLOR_ATTACHMENT0, GL.GL_COLOR_ATTACHMENT1])
                ok = GL.glCheckFramebufferStatus(GL.GL_FRAMEBUFFER) == GL.GL_FRAMEBUFFER_COMPLETE
            except GL.GLError:              # more samples than this format allows
                ok = False
            if ok:
                self.earthMs = (fbo, rbs)
                break
            GL.glDeleteFramebuffers(1, [fbo])
            GL.glDeleteRenderbuffers(3, rbs)
            n //= 2
        self.hdrSize = (w, h)

    def paintGL(self):
        self.frames += 1
        dpr = self.devicePixelRatioF()
        vw, vh = self.view_size()
        w, h = round(vw * dpr), round(vh * dpr)
        frame = round(FRAME_PX * dpr)
        fs = self.app.frame
        res = Resources.get()
        self._hdr_target(w, h)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.hdrFbo)
        GL.glViewport(0, 0, w, h)
        GL.glClearColor(0.0, 0.0, 0.0, 1.0)
        GL.glClear(GL.GL_COLOR_BUFFER_BIT)
        GL.glBindVertexArray(self.vao)
        sky = [l for l in self.layers if getattr(l, 'target', 'sky') == 'sky']
        earth = [l for l in self.layers if getattr(l, 'target', 'sky') == 'earth']
        if fs.ok:
            self._fov()
            for layer in sky:
                layer.draw(res, self, fs)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.earthMs[0] if self.earthMs else self.earthFbo)
        if self.earthMs:
            GL.glEnable(GL.GL_MULTISAMPLE)  # on by default, but Qt's context may not leave it so
        GL.glClearBufferfv(GL.GL_COLOR, 0, (0.0, 0.0, 0.0, 1.0))     # alpha 1: no vehicle
        GL.glClearBufferfv(GL.GL_COLOR, 1, (1.0, 1.0, 1.0, 1.0))
        GL.glClearBufferfv(GL.GL_DEPTH, 0, (1.0,))
        if fs.ok:
            for layer in earth:
                layer.draw(res, self, fs)
        if self.earthMs:                    # average the samples into the textures
            GL.glBindFramebuffer(GL.GL_READ_FRAMEBUFFER, self.earthMs[0])
            GL.glBindFramebuffer(GL.GL_DRAW_FRAMEBUFFER, self.earthFbo)
            for i in (0, 1):
                GL.glReadBuffer(GL.GL_COLOR_ATTACHMENT0 + i)
                GL.glDrawBuffers(1, [GL.GL_COLOR_ATTACHMENT0 + i])
                GL.glBlitFramebuffer(0, 0, w, h, 0, 0, w, h, GL.GL_COLOR_BUFFER_BIT, GL.GL_NEAREST)
            GL.glDrawBuffers(2, [GL.GL_COLOR_ATTACHMENT0, GL.GL_COLOR_ATTACHMENT1])
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, self.defaultFramebufferObject())
        GL.glViewport(0, 0, round(self.width() * dpr), round(self.height() * dpr))
        GL.glClearColor(*FRAME_SRGB, 1.0)
        GL.glClear(GL.GL_COLOR_BUFFER_BIT)
        GL.glViewport(frame, frame, w, h)
        GL.glUseProgram(res.presentProg)
        GL.glUniform2i(res.presentU["uOffset"], frame, frame)
        GL.glUniform1i(res.presentU["uCctv"], 1 if self.spec.get('cctv') else 0)
        GL.glUniform2i(res.presentU["uSize"], w, h)
        for i, (name, t) in enumerate((("uHdr", self.hdrTex), ("uEarth", self.earthTex),
                                       ("uEarthTrans", self.earthTransTex))):
            GL.glActiveTexture(GL.GL_TEXTURE0 + i)
            GL.glBindTexture(GL.GL_TEXTURE_2D, t)
            GL.glUniform1i(res.presentU[name], i)
        GL.glDrawArrays(GL.GL_TRIANGLES, 0, 3)
        GL.glActiveTexture(GL.GL_TEXTURE0)
        GL.glBindVertexArray(0)
        GL.glUseProgram(0)
        GL.glBindTexture(GL.GL_TEXTURE_2D, 0)       # leave Qt's painter a clean state
        if self.spec.get('cctv'):
            self._cctv_overlay()
        # The status line is the operator's, shown only when asked for (H):
        # nothing like it was ever on a window or a CCTV monitor, so a view
        # with no truth is simply dark (the CCTV keeps its monitor-generated
        # crosshair and data) and the state goes to stderr when it changes.
        line = self.app.status_line(fs)
        warn = not fs.ok or fs.stale or fs.unix is None
        if line and self.app.hud:
            p = QtGui.QPainter(self)
            p.setPen(QtGui.QColor(255, 80, 80) if warn else QtGui.QColor(200, 200, 200))
            # Fixed-width, so the digits changing every frame don't shift the line.
            f = QtGui.QFontDatabase.systemFont(QtGui.QFontDatabase.SystemFont.FixedFont)
            f.setPointSizeF(max(9.0, self.height() / 60.0))
            p.setFont(f)
            p.drawText(QtCore.QRectF(FRAME_PX + 8, FRAME_PX + 4, self.width() - 2 * FRAME_PX - 16,
                                     self.height() / 10),
                       Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop, line)
            p.end()

    def _cctv_overlay(self):
        """The monitor's green crosshair and data, and the CC 9-17
        transparency over them (see CCTV)."""
        vw, vh = self.view_size()
        x0, y0 = float(FRAME_PX), float(FRAME_PX)
        cx, cy = x0 + vw / 2.0, y0 + vh / 2.0
        p = QtGui.QPainter(self)
        p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing)
        p.setClipRect(QtCore.QRectF(x0, y0, vw, vh))
        # The transparency first, the monitor's own graphics are on the
        # screen's face below it, but both show; the ink is black.
        if CCTV['overlay'] != 'none':
            ux, uy = vw / 10.0, vh / 8.0
            ink = QtGui.QColor(0, 0, 0, 225)
            pen = QtGui.QPen(ink)
            pen.setWidthF(max(1.0, vw / 640.0))
            p.setPen(pen)
            for k in range(1, 10):
                p.drawLine(QtCore.QPointF(x0 + k * ux, y0), QtCore.QPointF(x0 + k * ux, y0 + vh))
            for k in range(1, 8):
                p.drawLine(QtCore.QPointF(x0, y0 + k * uy), QtCore.QPointF(x0 + vw, y0 + k * uy))
            pen.setWidthF(max(1.5, vw / 400.0))
            p.setPen(pen)
            p.setBrush(Qt.BrushStyle.NoBrush)
            for r in (1.25, 2.0):               # the 5 and 8 deg corridors at 40 deg
                p.drawEllipse(QtCore.QPointF(cx, cy), r * ux, r * ux)
            q = 0.12 * ux                         # the centre square
            p.drawRect(QtCore.QRectF(cx - q, cy - q, 2 * q, 2 * q))
            f = QtGui.QFont("Helvetica")
            f.setPixelSize(max(8, round(vh / 30.0)))
            f.setBold(True)
            p.setFont(f)
            t = 0.12 * uy
            for k in range(1, 6):                 # axis ticks and their numbers
                for sx in (-1, 1):
                    x = cx + sx * k * ux
                    p.drawLine(QtCore.QPointF(x, cy - 2 * t), QtCore.QPointF(x, cy + 2 * t))
                    if k < 5:
                        p.drawText(QtCore.QPointF(x + 3, cy - 3 * t), str(k))
                    else:
                        p.drawText(QtCore.QPointF(x - f.pixelSize(), cy - 3 * t), str(k))
            for k in range(1, 4):
                for sy in (-1, 1):
                    y = cy + sy * k * uy
                    p.drawLine(QtCore.QPointF(cx - 2 * t, y), QtCore.QPointF(cx + 2 * t, y))
                    p.drawText(QtCore.QPointF(cx + 3 * t, y - 2), str(k))
        # The monitor's electronic crosshair, green, edge to edge, with ticks
        # at the edges; its data in green above and below.
        g = QtGui.QColor(60, 255, 90, 235)
        pen = QtGui.QPen(g)
        pen.setWidthF(max(1.0, vw / 500.0))
        p.setPen(pen)
        p.drawLine(QtCore.QPointF(x0, cy), QtCore.QPointF(x0 + vw, cy))
        p.drawLine(QtCore.QPointF(cx, y0), QtCore.QPointF(cx, y0 + vh))
        e = vh / 40.0
        for a, b, c_, d in ((x0, cy - e, x0, cy + e), (x0 + vw - 1, cy - e, x0 + vw - 1, cy + e),
                            (cx - e, y0, cx + e, y0), (cx - e, y0 + vh - 1, cx + e, y0 + vh - 1)):
            p.drawLine(QtCore.QPointF(a, b), QtCore.QPointF(c_, d))
        f = QtGui.QFontDatabase.systemFont(QtGui.QFontDatabase.SystemFont.FixedFont)
        f.setPixelSize(max(8, round(vh / 28.0)))
        p.setFont(f)
        z = CCTV['zoom']
        p.drawText(QtCore.QRectF(x0 + 8, y0 + 4, vw - 16, vh / 12.0),
                   Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop,
                   "Z %5.1f   F  INF   I AUTO" % z)
        p.drawText(QtCore.QRectF(x0 + 8, y0 + vh - vh / 12.0 - 4, vw - 16, vh / 12.0),
                   Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignBottom,
                   "C/L   P +00  T +00   +22C")
        p.end()

    def keyPressEvent(self, ev):
        k = ev.key()
        x = self.app.exposure
        if k == Qt.Key.Key_Q and ev.modifiers() & Qt.KeyboardModifier.ControlModifier:
            confirm_quit(self)                # Ctrl+Q; Qt maps the Mac's Cmd to Control
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
        self.ground = []
        # Frames at FRAME_HZ: a fine tick that draws whenever a frame is due,
        # not a 16 ms timer, which Windows' timer granularity held to ~55/s.
        self.frameDue = time.monotonic()
        self.timer = QtCore.QTimer()
        self.timer.setTimerType(Qt.TimerType.PreciseTimer)
        self.timer.timeout.connect(self._maybe_tick)
        self.timer.start(4)

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
        s += "  alt %7.1f km" % (height_above_ellipsoid(
            fs.r if fs.m50_to_ef is None else fs.m50_to_ef @ fs.r) / 1000.0)
        ranges = [float(np.linalg.norm(rt - fs.r)) for k, (rt, _) in fs.targets.items()
                  if isinstance(k, int)]       # vehicles by NORAD id; not the pad's structures
        if ranges:                          # the nearest other vehicle's
            d = min(ranges)
            s += ("  target %5.0f m" % d) if d < 1e5 else ("  target %5.0f km" % (d / 1000.0))
        s += "  EV %+.2f  Milky Way x%.2f" % (self.exposure.ev, self.exposure.milkyway)
        if fs.stale:
            s += "  STALE"
        return s

    FRAME_HZ = 60.0

    def _maybe_tick(self):
        now = time.monotonic()
        if now < self.frameDue:
            return
        # The next frame a period after this one was due, unless far behind.
        self.frameDue = max(self.frameDue + 1.0 / self.FRAME_HZ, now - 0.5 / self.FRAME_HZ)
        self.tick()

    def tick(self):
        fs = self.feed.state()
        if fs.ok and fs.unix is not None:
            fs.sky = self.ephemeris.at(fs.unix)
            for g in self.ground:
                fs.targets[g.key] = g.state(fs)
        self.frame = fs
        state = "no truth" if not fs.ok else "stale" if fs.stale else "no date" if fs.unix is None else "ok"
        if state != getattr(self, "_feedState", None):
            if state == "ok":
                if getattr(self, "_feedState", None) is not None:
                    print("portview: truth data back", file=sys.stderr, flush=True)
            elif state == "no truth":
                print("portview: NO TRUTH DATA (yaGPC2 with YAGPC_VEHDYN=1, %s); views dark"
                      % self.feed.describe(), file=sys.stderr, flush=True)
            elif state == "stale":
                print("portview: truth data STALE", file=sys.stderr, flush=True)
            else:
                print("portview: truth data has no date (Sun, Moon, planets hidden)",
                      file=sys.stderr, flush=True)
            self._feedState = state
        for v in self.views:
            if v.isVisible():
                v.update()
        self.ticks += 1
        if self.args.stats:
            now = time.monotonic()
            if not hasattr(self, 'statsAt'):
                self.statsAt, self.statsN = now, {v.name: v.frames for v in self.views}
            elif now - self.statsAt >= 5.0:
                dt = now - self.statsAt
                print("portview: frames/s " + "  ".join(
                    "%s %.1f" % (v.name, (v.frames - self.statsN[v.name]) / dt) for v in self.views),
                    flush=True)
                self.statsAt, self.statsN = now, {v.name: v.frames for v in self.views}
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
    ap.add_argument("--cctv-zoom", type=float, default=40.0, choices=sorted(CCTV_ZOOMS),
                    help="the cctv view's camera field, deg across: 40.0 (the corridor, default), "
                         "10.1 (full zoom, alignment) or 74.4 (no zoom)")
    ap.add_argument("--cctv-overlay", choices=('auto', 'corridor', 'alignment', 'none'), default='auto',
                    help="the CC 9-17 transparency on the cctv view (auto: on at 40.0 and 10.1)")
    ap.add_argument("--test-sight", default='up', metavar="VIEW",
                    help="--test vbar/flyaround: the view whose sight line the target is put on "
                         "(default up; cctv or cl to line PMA-2 up on the centerline camera)")
    ap.add_argument("--test-offset", default="0,0", metavar="RIGHT,UP",
                    help="--test vbar: move the target off that sight line, m, in the view's "
                         "right and up (e.g. 0.3048,0 for a foot to the right)")
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
    ap.add_argument("--pad", default="lc39a", choices=list(PADS) + ['none'],
                    help="the launch pad whose structures to draw (default lc39a, STS-134's)")
    ap.add_argument("--site", default="ksc", metavar="SITE",
                    help="the landing site whose close-up imagery to load (default ksc; "
                         "none for none)")
    ap.add_argument("--msaa", type=int, default=4, metavar="N",
                    help="samples a pixel for the vehicles' edges (default 4; 0 or 1 for none; "
                         "none with reduced textures)")
    ap.add_argument("--terrain", choices=('on', 'off'), default='on',
                    help="the ground's heights near the landing site and the pads (default on)")
    ap.add_argument("--textures", choices=('auto', 'full', 'reduced'), default='auto',
                    help="texture memory: full (~1.2 GB), reduced (~0.5 GB: half-size, "
                         "compressed), or auto: reduced on a GPU with under 3 GB of its own "
                         "(default)")
    ap.add_argument("--check", action="store_true",
                    help="only say whether portview can run here (modules, assets), and exit")
    ap.add_argument("--stats", action="store_true",
                    help="print each view's frames per second to stdout, every 5 s")
    ap.add_argument("--exposure", type=float, default=-1.0, metavar="EV",
                    help="exposure, stops above (+) or below (-) the design one "
                         "(default -1)")
    ap.add_argument("--milkyway", type=float, default=0.5, metavar="X",
                    help="the Milky Way's brightness relative to the stars "
                         "(default 0.5)")
    ap.add_argument("--test", nargs='?', const='lvlh',
                    metavar="lvlh|baydown|vbar|flyaround|hover|RA,DEC|BODY",
                    help="no yaGPC2: a synthetic orbit, holding LVLH (default), LVLH "
                         "with the payload bay to the Earth (baydown), or "
                         "inertial with the nose at J2000 RA,DEC (deg) or at a body "
                         "(sun, moon, venus, mars, jupiter, saturn)")
    ap.add_argument("--test-date", metavar="UTC",
                    help="with --test, the start, YYYY-MM-DD[THH:MM[:SS]] UTC (default now)")
    ap.add_argument("--test-alt", type=float, default=400.0, metavar="KM",
                    help="with --test, the orbit's altitude (default 400 km)")
    ap.add_argument("--test-at", metavar="LAT,LON,ALT_M,HDG,PITCH",
                    help="with --test hover: where, how high, heading and pitch (deg, m)")
    ap.add_argument("--vehicle", action="append", default=[], metavar="KEY",
                    help="draw this variant of a vehicle instead of its usual model (e.g. hst1990: "
                         "Hubble as deployed); repeatable")
    ap.add_argument("--test-target", default='iss', metavar="KEY",
                    help="with --test vbar or flyaround, the vehicle (default iss)")
    ap.add_argument("--test-range", type=float, default=100.0, metavar="M",
                    help="with --test vbar or flyaround, the vehicle's distance (default 100 m); with "
                         "--test-approach, where the approach stops and station-keeping begins")
    ap.add_argument("--test-phase", type=float, default=0.0, metavar="DEG",
                    help="with --test flyaround, where round the circle to start (deg; 0 ahead "
                         "on the +V-bar, 90 below)")
    ap.add_argument("--test-lap", type=float, default=5400.0, metavar="S",
                    help="with --test flyaround, the seconds a lap (default 5400)")
    ap.add_argument("--test-approach", type=float, metavar="M",
                    help="with --test vbar, start this far off and close at range/1000 per "
                         "second (the Shuttle's rule of thumb) to --test-range, then hold")
    ap.add_argument("--test-lon", type=float, metavar="DEG",
                    help="with --test, start over this longitude (east +) on the equator")
    ap.add_argument("--test-rate", type=float, default=1.0, metavar="X",
                    help="with --test, vehicle time per wall second")
    ap.add_argument("--snapshot", metavar="PREFIX",
                    help="save each view's first second as PREFIX-VIEW.png and exit")
    args = ap.parse_args(argv)

    CCTV['zoom'] = args.cctv_zoom
    VIEWS['cctv']['hfov'] = args.cctv_zoom
    CCTV['overlay'] = (('none' if args.cctv_zoom > 70.0 else
                        'alignment' if args.cctv_zoom < 20.0 else 'corridor')
                       if args.cctv_overlay == 'auto' else args.cctv_overlay)
    names = [n.strip() for n in args.views.split(',') if n.strip()]
    for n in names:
        if n not in VIEWS:
            sys.exit("portview: no view %r (views: %s)" % (n, ", ".join(VIEWS)))
    geoms = parse_geometry(args.geometry, names)
    test = None
    bodies = ['sun', 'moon'] + [n for n, _, _ in PLANETS]
    if args.test:
        if args.test in ('lvlh', 'baydown', 'vbar', 'flyaround') or args.test in bodies:
            test = args.test
        elif args.test == 'hover':
            try:
                test = ('hover',) + tuple(float(x) for x in args.test_at.split(','))
                assert len(test) == 6
            except (AttributeError, ValueError, AssertionError):
                sys.exit("portview: --test hover needs --test-at LAT,LON,ALT_M,HDG,PITCH")
        else:
            try:
                ra, dec = (float(x) for x in args.test.split(','))
            except ValueError:
                sys.exit("portview: --test lvlh|baydown, --test RA,DEC or --test %s"
                         % "|".join(bodies))
            test = (ra, dec)

    for path in (MILKYWAY, HIPPARCOS, DE440S, NIGHTLIGHTS, WATERMASK):
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
    site = None
    TERRAIN['on'] = args.terrain == 'on'
    MSAA['samples'] = args.msaa
    if args.site != 'none':
        path = os.path.join(SITES_DIR, args.site)
        if os.path.exists(os.path.join(path, "ring.json")):
            site = Site(path)
        else:
            print("portview: no imagery for site %r (python3 portview/fetch_assets.py "
                  "--sites %s); the Earth near it is Blue Marble only" % (args.site, args.site))

    QtCore.QCoreApplication.setAttribute(Qt.ApplicationAttribute.AA_ShareOpenGLContexts)
    fmt = QtGui.QSurfaceFormat()
    fmt.setVersion(4, 1)
    fmt.setProfile(QtGui.QSurfaceFormat.OpenGLContextProfile.CoreProfile)
    fmt.setSwapInterval(0)
    QtGui.QSurfaceFormat.setDefaultFormat(fmt)
    try:                                    # its name in the Dock, and no App Nap (macdock.py)
        import macdock
        macdock.set_app_name("portview")
    except Exception:
        pass
    qapp = QtWidgets.QApplication(sys.argv[:1])
    TEXTURES['mode'] = args.textures
    Resources._instance = Resources(milkyway, stars, moon, site)

    unix0 = None
    if args.test_date:
        import datetime
        try:
            unix0 = datetime.datetime.fromisoformat(args.test_date).replace(
                tzinfo=datetime.timezone.utc).timestamp()
        except ValueError:
            sys.exit("portview: --test-date wants YYYY-MM-DD[THH:MM[:SS]] (UTC)")
    vehicles = vehicle_models(args.vehicle)
    if args.test_target != 'iss' and args.test_target not in vehicles:
        sys.exit("portview: no vehicle %r (prepared: iss, %s)" % (args.test_target, ", ".join(vehicles)))
    target_id = vehicles.get(args.test_target, ISS_NORAD)
    feed = (TestFeed(test, args.test_rate, unix0, ephemeris, args.test_alt, args.test_lon,
                     args.test_range, target_id, args.test_approach, args.test_lap,
                     args.test_phase) if test
            else TruthFeed(args.port_base))
    if test:
        if args.test_sight not in VIEWS:
            sys.exit("portview: --test-sight: no view %r" % args.test_sight)
        try:
            feed.offset = tuple(float(x) for x in args.test_offset.split(','))
            assert len(feed.offset) == 2
        except (ValueError, AssertionError):
            sys.exit("portview: --test-offset wants RIGHT,UP (m)")
        feed.sight = args.test_sight
    scale = args.size / float(FULL_SIZE)
    exposure = Exposure(args.exposure, args.milkyway)
    models = {}
    if os.path.exists(os.path.join(ISS_MODEL, "model.json")):
        models[ISS_NORAD] = Model(ISS_MODEL)
    for key, norad in vehicles.items():
        models[norad] = Model(os.path.join(CACHE, "models", key))
    ground = []
    if os.path.exists(os.path.join(GANTRY_MODEL, "model.json")) and args.pad != 'none':
        lat, lon, heading = PADS[args.pad]
        models[args.pad] = Model(GANTRY_MODEL, point=False)
        ground.append(GroundObject(args.pad, lat, lon, PAD_SURFACE_M, heading, offset=GANTRY_STACK))
    layers = [MilkyWayLayer(exposure), StarLayer(exposure), PlanetLayer(exposure),
              SunLayer(), MoonLayer(), EarthLayer(), VehicleLayer(models, exposure)]
    views = []
    app = Portview(args, feed, views, exposure, ephemeris)
    app.ground = ground
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
