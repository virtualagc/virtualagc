#!/usr/bin/env python3
"""THE TRUTH BALL: an attitude indicator driven by the vehicle itself.

A debugging instrument, not a crew display.  The PFD's ADI shows what the
flight software computes (GDFORB.hal -> the DDU messages on FC1-4); this one
shows what the vehicle dynamics in yaGPC2 are really doing, so the two can be
set side by side -- the attitude counterpart of comparing GPS with PASS's
navigation state.

    python3 truthball.py [--port-base N] [--size PX] [--ref inrtl|lvlh]

Data: yaGPC2 (src/mdmdev.c, truth_publish) sends the truth state when run
with YAGPC_MDM_DEVICES=1 YAGPC_VEHDYN=1 and a panel: "TRU1" and big-endian
doubles -- vehicle time, PASS GMT, quaternion body -> M50 (w x y z), body
rates (rad/s), M50 position (m) and velocity (m/s) -- on port base + 98.
PASS's own ADI attitude is read alongside from the commander's DDU message
on the selected FC bus (port base + 97, as MEDS2's FCInstrumentFeed).

Keys: I inertial (M50) reference, L LVLH reference, 1-4 the FC bus whose
PASS ADI is shown, Q or Esc to quit.

THE BALL'S GEOMETRY.  The Orbiter's ADIs are pitch-yaw-roll gimballed: the
attitude of the body relative to the reference is C = Ry(P) Rz(Y) Rx(R)
(body axes X forward, Y right, Z down; positive pitch nose up, yaw nose
right, roll right wing down).  The ball is fixed in the reference frame,
and the marking at the face's centre is the (pitch, yaw) of the direction
the nose points, d = Ry(P) Rz(Y) X; roll turns the ball about the line of
sight.  The texture, adi_ball.png from the Space Shuttle Ultra add-on for
the Orbiter simulator (samples/, a local copy -- not in the repository; a
plain ball in the same layout is drawn when it is absent), maps 360 deg of pitch along its 1800-pixel
height (180 at both ends, 0 in the middle) and yaw -90..+90 across its 900
pixels, onto a sphere whose longitude runs about the model's Y axis; worked
through, a ball point of label (P, Y) is the model point
(-cos P cos Y, sin Y, -sin P cos Y) = D d with D = diag(-1, 1, 1) -- the
mirror is the texture's, drawn to be seen from outside -- and the eye's
axes are body Y right, body -Z up, body X toward the viewer.  The model
matrix is then A = B C^T D, B taking body to eye.
"""
import argparse
import math
import os
import socket
import struct
import sys
import time

import numpy as np
import pygame
from pygame.locals import DOUBLEBUF, OPENGL, QUIT, KEYDOWN

try:
    from OpenGL.GL import *        # noqa: F401,F403
    from OpenGL.GLU import gluPerspective
except ImportError:
    print("truthball: PyOpenGL is required (pip install pyopengl)")
    sys.exit(1)

HERE = os.path.dirname(os.path.abspath(__file__))
TEXTURE = os.path.join(HERE, "samples", "adi_ball.png")
MCAST_GROUP = "239.255.1.1"
FC_INSTR_OFFSET = 97
TRUTH_OFFSET = 98
STALE_S = 1.0

# The texture's 900 x 1800 map inside its 1024 x 2048 image.
U_SCALE = 900.0 / 1024.0
V_SCALE = 1800.0 / 2048.0
V_OFFSET = (2048.0 - 1800.0) / 2048.0

B_EYE = np.array([[0.0, 1.0, 0.0],       # eye x = body Y (right)
                  [0.0, 0.0, -1.0],      # eye y = body -Z (up)
                  [1.0, 0.0, 0.0]])      # eye z = body X (toward the viewer)
D_TEX = np.diag([-1.0, 1.0, 1.0])


def quat_to_matrix(q):
    """Body -> M50 rotation of the unit quaternion [w x y z]."""
    w, x, y, z = q
    return np.array([
        [1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
        [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
        [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]])


def lvlh_axes(r, v):
    """PASS's LVLH (GVFRVT.hal): Z toward the Earth's centre, Y along V x R
    (minus the orbit normal), X = Y x Z -- as rows, in M50."""
    r = np.asarray(r, float)
    v = np.asarray(v, float)
    zh = -r / np.linalg.norm(r)
    y = np.cross(v, r)
    yh = y / np.linalg.norm(y)
    xh = np.cross(yh, zh)
    return np.array([xh, yh, zh])


def pyr_of(C):
    """Pitch, yaw, roll (deg, 0-360) of C = Ry(P) Rz(Y) Rx(R)."""
    p = math.degrees(math.atan2(-C[2, 0], C[0, 0]))
    y = math.degrees(math.asin(max(-1.0, min(1.0, C[1, 0]))))
    r = math.degrees(math.atan2(-C[1, 2], C[1, 1]))
    return p % 360.0, y % 360.0, r % 360.0


def frac(w):
    if w & 0x8000:
        w -= 0x10000
    return (w >> 3) / 4095.0


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


class Feeds(object):
    def __init__(self, base):
        self.truthSock = mcast_socket(base + TRUTH_OFFSET)
        self.fcSock = mcast_socket(base + FC_INSTR_OFFSET)
        self.truth = None
        self.truthAt = -1e9
        self.passAdi = {}          # FC bus -> (pitch, yaw, roll, valid, at)

    def poll(self):
        while True:
            try:
                d = self.truthSock.recv(256)
            except (BlockingIOError, OSError):
                break
            if len(d) >= 4 + 8 * 15 and d[:4] == b"TRU1":
                v = struct.unpack(">15d", d[4:4 + 8 * 15])
                self.truth = {'t': v[0], 'gmt': v[1], 'q': v[2:6], 'w': v[6:9],
                              'r': v[9:12], 'v': v[12:15]}
                self.truthAt = time.monotonic()
        while True:
            try:
                d = self.fcSock.recv(256)
            except (BlockingIOError, OSError):
                break
            if len(d) < 10 or len(d) % 2:
                continue
            h = struct.unpack('>%dH' % (len(d) // 2), d)
            if h[0] != 0xFC01:
                continue
            cmd = (h[2] << 16) | h[3]
            n = h[4]
            # the commander's DDU (IUA 6), ADI message (select 0x020)
            if (cmd >> 19) & 0x1f != 6 or (cmd & 0x7fe0) != 0x020 or n < 8:
                continue
            w = h[5:5 + n]
            valid = all(w[0] & (0x8000 >> (k - 1)) for k in range(2, 8))
            r = math.degrees(math.atan2(frac(w[2]), frac(w[3]))) % 360
            p = math.degrees(math.atan2(frac(w[4]), frac(w[5]))) % 360
            y = math.degrees(math.atan2(frac(w[6]), frac(w[7]))) % 360
            self.passAdi[h[1]] = (p, y, r, valid, time.monotonic())


def procedural_ball():
    """The ball's map drawn here, in the texture's own layout, for when
    adi_ball.png (third-party artwork, not in the repository) is absent:
    1800 rows of pitch at 5 per degree, 180 at both ends and 0 in the
    middle, the positive half white and the negative dark; 900 columns of
    yaw, -90 to +90; pitch lines and labels every 30 deg, yaw meridians every
    30 deg, and the zero-yaw circle doubled."""
    surf = pygame.Surface((1024, 2048), pygame.SRCALPHA)
    surf.fill((0, 0, 0, 0))
    W, H, PX = 900, 1800, 5
    white, dark = (235, 235, 235), (60, 62, 80)
    pygame.draw.rect(surf, white, (0, 0, W, H // 2))
    pygame.draw.rect(surf, dark, (0, H // 2, W, H // 2))
    pygame.font.init()
    font = pygame.font.SysFont("dejavusans,sans", 44, bold=True)
    small = pygame.font.SysFont("dejavusans,sans", 30, bold=True)
    for p in range(-180, 181, 10):
        y = H // 2 - p * PX
        if y < 0 or y >= H:
            continue
        ink = dark if p > 0 else white
        if p % 30 == 0:
            pygame.draw.line(surf, ink if p else (20, 20, 20), (0, y), (W, y), 4 if p else 6)
            lab = "%d" % (((p % 360) // 10) % 36)
            for x in (225, 450 - 60, 450 + 60, 675):
                t = font.render(lab, True, ink)
                surf.blit(t, (x - t.get_width() // 2, y - t.get_height() - 4 if p >= 0 else y + 4))
        else:
            for x in range(60, W, 90):
                pygame.draw.line(surf, ink, (x - 12, y), (x + 12, y), 3)
    for yw in range(-90, 91, 30):
        x = 450 + yw * PX
        x = min(max(x, 2), W - 3)
        for half, ink in ((0, dark), (1, white)):
            pygame.draw.line(surf, ink, (x, half * H // 2), (x, (half + 1) * H // 2), 3)
        if yw:
            lab = "%d" % ((yw % 360) // 10)
            for p in (15, 45, -15, -45):
                y = H // 2 - p * PX
                ink = dark if p > 0 else white
                t = small.render(lab, True, ink)
                surf.blit(t, (x + 6, y - t.get_height() // 2))
    for dx in (-6, 6):
        for half, ink in ((0, dark), (1, white)):
            pygame.draw.line(surf, ink, (450 + dx, half * H // 2), (450 + dx, (half + 1) * H // 2), 3)
    return surf


def load_texture(path):
    if os.path.exists(path):
        surf = pygame.image.load(path)
    else:
        print("truthball: %s not found -- drawing a plain ball instead" % path)
        surf = procedural_ball()
    data = pygame.image.tostring(surf, "RGBA", True)
    w, h = surf.get_rect().size
    tid = glGenTextures(1)
    glBindTexture(GL_TEXTURE_2D, tid)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data)
    return tid


def build_sphere_list(radius, lats, longs, tid):
    """The textured sphere as a display list: longitude about the model's Y
    axis, latitude from it, texture u along latitude, v along longitude."""
    lst = glGenLists(1)
    glNewList(lst, GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D, tid)
    glColor3f(1.0, 1.0, 1.0)
    for i in range(lats):
        lat0 = math.pi * (-0.5 + float(i) / lats)
        lat1 = math.pi * (-0.5 + float(i + 1) / lats)
        glBegin(GL_QUAD_STRIP)
        for j in range(longs + 1):
            lng = 2 * math.pi * float(j) / longs
            tv = V_OFFSET + (float(j) / longs) * V_SCALE
            for lat, ti in ((lat0, i), (lat1, i + 1)):
                x = math.cos(lng) * math.cos(lat)
                y = math.sin(lat)
                z = math.sin(lng) * math.cos(lat)
                glTexCoord2f(float(ti) / lats * U_SCALE, tv)
                glNormal3f(x, y, z)
                glVertex3f(x * radius, y * radius, z * radius)
        glEnd()
    glEndList()
    return lst


class Text(object):
    def __init__(self, size):
        pygame.font.init()
        self.font = pygame.font.SysFont("dejavusansmono,monospace", size)

    def draw(self, x, y, s, color=(255, 255, 255)):
        """At window pixel (x, y) from the top left."""
        surf = self.font.render(s, True, color, (0, 0, 0))
        data = pygame.image.tostring(surf, "RGBA", True)
        w, h = surf.get_size()
        H = glGetIntegerv(GL_VIEWPORT)[3]
        # Pixel rectangles are textured and lit like any fragment: off, or
        # the text takes the colour of whatever texel the raster position
        # happens to sample.
        glDisable(GL_TEXTURE_2D)
        glDisable(GL_LIGHTING)
        glWindowPos2d(x, H - y - h)
        glDrawPixels(w, h, GL_RGBA, GL_UNSIGNED_BYTE, data)
        glEnable(GL_LIGHTING)
        glEnable(GL_TEXTURE_2D)


def draw_symbol(W, H):
    """The fixed vehicle symbol at the face's centre."""
    glMatrixMode(GL_PROJECTION)
    glPushMatrix()
    glLoadIdentity()
    glOrtho(0, W, H, 0, -1, 1)
    glMatrixMode(GL_MODELVIEW)
    glPushMatrix()
    glLoadIdentity()
    glDisable(GL_LIGHTING)
    glDisable(GL_TEXTURE_2D)
    glDisable(GL_DEPTH_TEST)
    cx, cy, k = W / 2.0, H / 2.0, W / 600.0
    glColor3f(1.0, 0.85, 0.0)
    glLineWidth(3.0)
    glBegin(GL_LINES)
    glVertex2f(cx - 60 * k, cy); glVertex2f(cx - 15 * k, cy)
    glVertex2f(cx + 15 * k, cy); glVertex2f(cx + 60 * k, cy)
    glVertex2f(cx, cy - 15 * k); glVertex2f(cx, cy - 35 * k)
    glEnd()
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_TEXTURE_2D)
    glEnable(GL_LIGHTING)
    glMatrixMode(GL_PROJECTION)
    glPopMatrix()
    glMatrixMode(GL_MODELVIEW)
    glPopMatrix()


def main():
    ap = argparse.ArgumentParser(description="Truth attitude indicator (debugging).")
    ap.add_argument("--port-base", type=int,
                    default=int(os.environ.get("NSTS_BUS_PORT_BASE", "6900")))
    ap.add_argument("--size", type=int, default=600, help="window size, pixels")
    ap.add_argument("--ref", choices=("inrtl", "lvlh"), default="inrtl")
    ap.add_argument("--fc", type=int, default=1, choices=(1, 2, 3, 4),
                    help="the FC bus whose PASS ADI is shown beside the truth")
    ap.add_argument("--test", metavar="P,Y,R",
                    help="no feed: draw this fixed attitude (deg), for checking the ball")
    ap.add_argument("--snapshot", metavar="PNG",
                    help="save the first frame (after a second of data, with a feed) and exit")
    args = ap.parse_args()

    pygame.init()
    W = H = args.size
    pygame.display.set_mode((W, H), DOUBLEBUF | OPENGL)
    pygame.display.set_caption("Truth ADI")
    glViewport(0, 0, W, H)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45, 1.0, 0.1, 50.0)
    glMatrixMode(GL_MODELVIEW)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_TEXTURE_2D)
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glLightfv(GL_LIGHT0, GL_POSITION, [1.0, 1.0, 2.0, 0.0])
    glLightfv(GL_LIGHT0, GL_AMBIENT, [0.6, 0.6, 0.6, 1.0])
    glLightfv(GL_LIGHT0, GL_DIFFUSE, [0.5, 0.5, 0.5, 1.0])
    glEnable(GL_COLOR_MATERIAL)
    glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
    tid = load_texture(TEXTURE)
    sphere = build_sphere_list(1.8, 48, 96, tid)
    text = Text(max(12, W // 40))
    feeds = None if args.test else Feeds(args.port_base)
    ref = args.ref
    fc = args.fc
    clock = pygame.time.Clock()
    lastC = np.eye(3)
    started = time.monotonic()
    while True:
        for ev in pygame.event.get():
            if ev.type == QUIT:
                return
            if ev.type == KEYDOWN:
                k = ev.unicode.lower() if ev.unicode else ''
                if k in ('q', '\x1b'):
                    return
                if k == 'i':
                    ref = 'inrtl'
                elif k == 'l':
                    ref = 'lvlh'
                elif k in ('1', '2', '3', '4'):
                    fc = int(k)
        lines = []
        stale = True
        if args.test:
            p, y, r = (math.radians(float(a)) for a in args.test.split(','))
            cp, sp, cy, sy, cr, sr = (math.cos(p), math.sin(p), math.cos(y),
                                      math.sin(y), math.cos(r), math.sin(r))
            Ry = np.array([[cp, 0, sp], [0, 1, 0], [-sp, 0, cp]])
            Rz = np.array([[cy, -sy, 0], [sy, cy, 0], [0, 0, 1]])
            Rx = np.array([[1, 0, 0], [0, cr, -sr], [0, sr, cr]])
            lastC = Ry @ Rz @ Rx
            stale = False
            lines.append(("TEST", (255, 255, 0)))
        else:
            feeds.poll()
            tr = feeds.truth
            stale = tr is None or time.monotonic() - feeds.truthAt > STALE_S
            if tr is not None:
                Cm = quat_to_matrix(tr['q'])                  # M50 <- body
                if ref == 'lvlh':
                    lastC = lvlh_axes(tr['r'], tr['v']) @ Cm  # LVLH <- body
                else:
                    lastC = Cm
                g = tr['gmt']
                if g >= 0:
                    d = int(g // 86400)
                    s = g - d * 86400
                    lines.append(("GMT %03d/%02d:%02d:%06.3f" % (
                        d, s // 3600, (s % 3600) // 60, s % 60), (200, 200, 200)))
                wd = [math.degrees(x) for x in tr['w']]
                lines.append(("rates p q r %+7.3f %+7.3f %+7.3f deg/s" % tuple(wd),
                              (200, 200, 200)))
        P, Y, R = pyr_of(lastC)
        head = "TRUTH %s" % ("INRTL (M50)" if ref == 'inrtl' else "LVLH")
        lines.insert(0, ("%s   R %05.1f  P %05.1f  Y %05.1f" % (head, R, P, Y),
                         (255, 80, 80) if stale else (120, 255, 120)))
        if feeds is not None:
            pa = feeds.passAdi.get(fc)
            if pa is not None and time.monotonic() - pa[4] < STALE_S and pa[3]:
                lines.insert(1, ("PASS ADI FC%d   R %05.1f  P %05.1f  Y %05.1f" % (
                    fc, pa[2], pa[0], pa[1]), (255, 255, 255)))
            else:
                lines.insert(1, ("PASS ADI FC%d   (no valid data)" % fc, (150, 150, 150)))
        if stale and not args.test:
            lines.append(("NO TRUTH DATA (YAGPC_VEHDYN=1, port %d)" % (
                args.port_base + TRUTH_OFFSET), (255, 80, 80)))

        A = B_EYE @ lastC.T @ D_TEX
        M = np.eye(4)
        M[:3, :3] = A
        glClearColor(0.05, 0.05, 0.08, 1.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glLoadIdentity()
        glTranslatef(0.0, 0.0, -5.0)
        glMultMatrixf(M.T.astype(np.float32))           # column-major
        glCallList(sphere)
        draw_symbol(W, H)
        for i, (s, col) in enumerate(lines):
            text.draw(8, 6 + i * (text.font.get_linesize() + 2), s, col)
        if args.snapshot and (args.test or time.monotonic() - started > 1.0):
            px = glReadPixels(0, 0, W, H, GL_RGBA, GL_UNSIGNED_BYTE)
            pygame.image.save(pygame.image.fromstring(px, (W, H), "RGBA", True), args.snapshot)
            return
        pygame.display.flip()
        clock.tick(30)


if __name__ == "__main__":
    try:
        main()
    finally:
        pygame.quit()
