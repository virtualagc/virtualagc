#!/usr/bin/env python3
"""RPOP: THE RENDEZVOUS AND PROXIMITY OPERATIONS PROGRAM, as the crew saw it
on the aft-station PGSC laptop during an ISS docking.

    python3 rpop.py [--port-base N] [--size N] [--por auto|cg|dp]

A crew display, not a debugging one: the window holds only what RPOP itself
showed.  Anything about the simulator goes to stderr.

WHAT IT SHOWS, AND WHERE THAT COMES FROM.  The screen is RPOP's trajectory
display with TCS NAV (the TCS Kalman filter) as the Prime Trajectory, laid
out after these, which are cited in full in rpop-findings.md (the
forClaude dropbox, docs/):
  [JSC]  JSC-63400 Rev 3, "History of Space Shuttle Rendezvous" (2011),
         Figure 20.4, a recreation of the RPOP display at the STS-126 docking:
         the header (R, R-dot, X Y Z and their rates, the point of reference
         line "Orb DP to Tgt DP"), "Prop Age", the "Raw TCS 2(CW)" block
         (Refl, Age, Rng, Rdot, Elv, Azi), MET / Pitch / Alt, the "TGT LVLH"
         axis key, the V-bar corridor overlay, the predictor digits, the
         orbiter and target outlines, the CG mark, the TCS NAV residual table
         (RESID RATIO ACPT REJ for RNG RDOT ELV AZI) and the function-key
         line ("TCS NAV", "PCM").
  [GNC]  "Space Shuttle GN&C Development History and Evolution" (AIAA
         2011, NTRS 20110014833), Figure IV.4, a screen capture of RPOP in
         flight colours: black ground, green prime data and trajectory, white
         reference-point line and overlays, and the Rdot window (HHLFlt,
         HHL/dt, HHLRaw; Rng, Rdot, Age) on a grey Windows dialog.
  [RNDZ] JSC-48072-134, STS-134 Rendezvous checklist, RNDZ TOOLS (7-15 to
         7-27): the function keys and what they do, the point of reference
         sets, "PCM" above F6, the message "RPOP is not receiving PCMMU data",
         TCS NAV as "Kalman Filtering" with "Display Resids and Ratios"; the
         APPROACH and VBAR APPROACH cue cards (CC 9-7, 9-8) for the 8 and 5
         degree corridors, the 170 +/- 10 ft hold and the 350-250 ft V-bar
         arrival (DP-DP), and "RPOP POR - Orb DP to Tgt DP" from ~400 ft.
  [NESC] NASA/TM-2013-217992 (NESC-RP-11-00753), section 6.1: RPOP's TCS NAV
         is a 6-state relative Kalman filter on TCS range, range rate,
         azimuth and elevation, propagated with the orbiter's IMU-sensed
         delta-V (used only above 0.01829 m/s) and attitude from the PCMMU,
         with the target assumed held in LVLH; its I-loaded measurement
         variances were set larger than the TCS's real noise.

WHAT IS APPROXIMATED (said again in the findings):
  - The filter's own equations and I-loads are not public: this one is an
    extended Kalman filter on the [NESC] description -- Clohessy-Wiltshire
    propagation about the target's orbit, IMU delta-V from the truth's
    velocity less gravity (J2), the four TCS measurements processed one at a
    time, an edit test at three sigma -- with the variances set wider than
    rndz_instruments' noise, as [NESC] says RPOP's were.  RATIO is the
    residual over three sigma of its predicted spread (edited above 1), the
    Shuttle REL NAV convention; RPOP's own definition is not published.
  - "Pitch" is taken as the orbiter's LVLH pitch on the aft ADI (forward
    ADI + 90): 181 at the STS-126 docking [JSC] and the AFT 90 / FWD 0 of the
    R-bar attitude on the APPROACH card [RNDZ] agree with it.  "Alt" is the
    target's altitude (nmi) -- the "Altitude..." RPOP is configured with.
    "Prop Age" is shown as the seconds since the filter's last accepted mark.
  - Azi and Elv are rndz_instruments' two bearings, off the TCS head's
    boresight (Orbiter -Z) toward Orbiter +Y and -X; TCS unit 2 in CW mode
    and reflector 1 (the PMA-2 docking target the model ranges to) are shown
    as in both figures and the VBAR APPROACH card.
  - The orbiter and Node 2 / PMA-2 outlines are simple side views drawn to
    the real dimensions, not RPOP's own artwork.  The fonts are a fixed-width
    face (Courier New, else Menlo / DejaVu Sans Mono) like the figures'.
  - Autoscale: the view fits the target, the orbiter and its predictors, in
    50 / 100 / 500 ... ft ticks; RPOP's own autoscale rule is not published.
  - HHL: a mark every 5 s; HHL/dt is the range difference over the last
    mark, HHLFlt an alpha-beta filter on the marks (the real one also used
    radar R-dot, which this simulator does not feed RPOP).

KEYS, from the checklist's RPOP FUNCTION KEY SUMMARY: F5 Rdot window,
F7 view (XZ, XY, YZ), Ctrl+F8 point of reference (CG-CG / DP-DP),
Shift+F9 clear trajectory, Ctrl+F9 back 1, Shift+F10 exit, Ctrl+PgUp /
Ctrl+PgDn zoom, Ctrl+Home autoscale, Ctrl+arrows move the axes, Space the
function-key menu.

DATA.  TRU1 (port base + 98) and TGT1 (port base + 109), multicast on
239.255.1.1 on the interface NSTS_BUS_IFACE (default 127.0.0.1), as
portview.py reads them; the readings are rndz_instruments.Instruments'.
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

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "examples", "flights"))
import rndz_instruments as ri                     # noqa: E402

MCAST_GROUP = "239.255.1.1"
TRUTH_OFFSET, TARGET_OFFSET = 98, 109
STALE_S = 3.0
FT = 0.3048
NMI = 1852.0
MU = 3.986004418e14
RE = 6378137.0
J2 = 1.08262668e-3
DESIGN_W, DESIGN_H = 1024, 768          # --size 768: the PGSC's 1024 x 768 screen
TCS_PERIOD_S = 1.0                      # TCS marks to the filter (vehicle s)
HHL_PERIOD_S = 5.0
DV_THRESHOLD = 0.01829                  # m/s, [NESC]
MET_ZERO = "136/12:56:27.994"           # STS-134 (fly_rndz134.MET_ZERO_UNIX)

GREEN = QtGui.QColor(0, 255, 0)
WHITE = QtGui.QColor(255, 255, 255)
GREY_TXT = QtGui.QColor(230, 230, 230)
RED = QtGui.QColor(255, 40, 40)
DLG = QtGui.QColor(212, 208, 200)       # Windows' classic 3-D face, the Rdot window


def log(msg):
    sys.stderr.write("rpop: %s\n" % msg)
    sys.stderr.flush()


# ---------------------------------------------------------------------------
# The feeds.

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


def parse_tru(d):
    if d[:4] != b"TRU1" or len(d) < 4 + 8 * 15:
        return None
    n = (len(d) - 4) // 8
    v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
    return {"t": v[0], "gmt": v[1], "q": v[2:6], "w": v[6:9], "r": v[9:12], "v": v[12:15],
            "cg": v[27:30] if n >= 30 else (0.0, 0.0, 0.0)}


def parse_tgt(d):
    if d[:4] != b"TGT1" or len(d) < 4 + 8 * 12:
        return None
    v = struct.unpack(">12d", d[4:4 + 8 * 12])
    return {"t": v[0], "norad": int(v[1]), "r": v[2:5], "v": v[5:8], "q": v[8:12]}


# ---------------------------------------------------------------------------
# Geometry.

def gravity(r):
    """Point mass and J2, M50 (its pole is the Earth's to ~0.3 deg)."""
    r = np.asarray(r, float)
    rn = np.linalg.norm(r)
    z2 = (r[2] / rn) ** 2
    k = 1.5 * J2 * (RE / rn) ** 2
    g = -MU * r / rn ** 3
    return g * np.array([1 + k * (1 - 5 * z2), 1 + k * (1 - 5 * z2), 1 + k * (3 - 5 * z2)])


def lvlh(r, v):
    """Columns: the LVLH axes in M50 (x along, y -orbit normal, z down)."""
    r, v = np.asarray(r, float), np.asarray(v, float)
    ez = -r / np.linalg.norm(r)
    h = np.cross(r, v)
    ey = -h / np.linalg.norm(h)
    ex = np.cross(ey, ez)
    return np.column_stack([ex, ey, ez])


def cw_deriv(s, n):
    """Clohessy-Wiltshire in the Shuttle's LVLH (x along, z down)."""
    x, y, z, vx, vy, vz = s
    return np.array([vx, vy, vz, 2 * n * vz, -n * n * y, 3 * n * n * z - 2 * n * vx])


def cw_step(s, n, dt):
    """RK4 steps of at most 10 s."""
    s = np.array(s, float)
    m = max(1, int(math.ceil(abs(dt) / 10.0)))
    h = dt / m
    for _ in range(m):
        k1 = cw_deriv(s, n)
        k2 = cw_deriv(s + 0.5 * h * k1, n)
        k3 = cw_deriv(s + 0.5 * h * k2, n)
        k4 = cw_deriv(s + h * k3, n)
        s = s + h / 6.0 * (k1 + 2 * k2 + 2 * k3 + k4)
    return s


def cw_phi(n, dt):
    """The CW state transition matrix (numerically, from the same steps)."""
    P = np.zeros((6, 6))
    for i in range(6):
        e = np.zeros(6)
        e[i] = 1.0
        P[:, i] = cw_step(e, n, dt)
    return P


def orbiter_side(xo_zo):
    """Structural X_o, Z_o (in) -> body x, z (ft) from the dry CG."""
    return [((ri.DRY_CG_XO - xo) / 12.0, -(zo - ri.DRY_CG_ZO) / 12.0) for xo, zo in xo_zo]


# A side view of the Orbiter, structural inches (X_o aft, Z_o up): fuselage
# 238 (nose) to ~1528, payload bay sill ~Z_o 410, crew cabin roof ~500, fin
# tip ~Z_o 1060 -- to scale, not RPOP's own artwork.
ORBITER_OUTLINE = orbiter_side([
    (238, 330), (260, 375), (320, 430), (420, 490), (520, 500), (582, 480),
    (1307, 480), (1310, 510), (1460, 1060), (1540, 1060), (1525, 520),
    (1560, 450), (1590, 330), (1530, 270), (1400, 255), (500, 260), (300, 285)])
ODS_OUTLINE = orbiter_side([(600, 410), (600, 476), (698, 476), (698, 410)])


# ---------------------------------------------------------------------------
# TCS NAV: the relative Kalman filter.

class TcsNav(object):
    """Orbiter CG relative to the target's CG, target LVLH, ft and ft/s.

    The target is taken as held in LVLH (as RPOP took it, [NESC]); the TCS
    reflector, PMA-2's face (rndz_instruments.PMA2), is fixed in that frame.
    """
    NAMES = ("RNG", "RDOT", "ELV", "AZI")
    SIG = (lambda r: 1.0 + 0.002 * r, lambda r: 0.03, lambda r: math.radians(0.1),
           lambda r: math.radians(0.1))
    Q_ACC = 1e-3                    # ft/s^2: the thrusting below the delta-V threshold, drag

    def __init__(self):
        self.reset()

    def reset(self):
        self.x = None
        self.P = None
        self.t = None
        self.resid = [None] * 4
        self.ratio = [None] * 4
        self.acpt = [0] * 4
        self.rej = [0] * 4
        self.last_accept = None

    @staticmethod
    def predict(x, geo):
        """TCS range (ft), range rate (ft/s), elevation and azimuth (rad)
        for the state x and the measurement geometry."""
        A, arm, wrel = geo["A"], geo["arm"], geo["wrel"]
        head = x[:3] + A @ arm
        los = ri_pma2_ft() - head
        rng = np.linalg.norm(los)
        vhead = x[3:] + np.cross(wrel, A @ arm)
        rdot = float(los @ (-vhead)) / rng
        tb = A.T @ los
        azi = math.atan2(tb[1], -tb[2])
        elv = math.atan2(-tb[0], -tb[2])
        return np.array([rng, rdot, elv, azi])

    def init_from(self, z, geo):
        rng, rdot, elv, azi = z
        # the boresight -Z with the two bearings off it
        d = np.array([-math.tan(elv), math.tan(azi), -1.0])
        d /= np.linalg.norm(d)
        los = geo["A"] @ (d * rng)
        head = ri_pma2_ft() - los
        x = np.zeros(6)
        x[:3] = head - geo["A"] @ geo["arm"]
        x[3:] = -rdot * los / rng                  # the range rate, along the line of sight
        self.x = x
        self.P = np.diag([(0.02 * rng + 2.0) ** 2] * 3 + [0.5 ** 2] * 3)
        log("TCS NAV initialised at %.0f ft" % rng)

    def propagate(self, t, n, dv_lvlh):
        if self.x is None:
            return
        dt = t - self.t
        if dt > 0:
            Phi = cw_phi(n, dt)
            self.x = Phi @ self.x
            q = self.Q_ACC ** 2
            Q = np.zeros((6, 6))
            for i in range(3):            # white-noise acceleration
                Q[i, i] = q * dt ** 3 / 3
                Q[i, i + 3] = Q[i + 3, i] = q * dt ** 2 / 2
                Q[i + 3, i + 3] = q * dt
            self.P = Phi @ self.P @ Phi.T + Q
        if dv_lvlh is not None:
            self.x[3:] += dv_lvlh
        self.t = t

    def update(self, t, z, geo, n, dv_lvlh):
        if self.x is None:
            self.init_from(z, geo)
            self.t = t
            return
        self.propagate(t, n, dv_lvlh)
        for i in range(4):
            h0 = self.predict(self.x, geo)
            H = np.zeros(6)
            for j in range(6):
                e = np.zeros(6)
                e[j] = 1e-3
                H[j] = (self.predict(self.x + e, geo)[i] - h0[i]) / 1e-3
            sig = TcsNav.SIG[i](z[0])
            S = float(H @ self.P @ H) + sig * sig
            res = z[i] - h0[i]
            if i >= 2:
                res = (res + math.pi) % (2 * math.pi) - math.pi
            ratio = abs(res) / (3.0 * math.sqrt(S))
            self.resid[i] = math.degrees(res) if i >= 2 else res
            self.ratio[i] = ratio
            if ratio > 1.0 and self.acpt[i] > 5:
                self.rej[i] += 1
                continue
            K = self.P @ H / S
            self.x = self.x + K * res
            self.P = (np.eye(6) - np.outer(K, H)) @ self.P
            self.P = 0.5 * (self.P + self.P.T)
            self.acpt[i] += 1
        self.last_accept = t


def ri_pma2_ft():
    return np.array(ri.PMA2) / FT


# ---------------------------------------------------------------------------
# The program's state: what RPOP holds, fed from the truth.

class Rpop(QtCore.QObject):
    def __init__(self, port_base, seed):
        super().__init__()
        self.inst = ri.Instruments(seed)
        self.nav = TcsNav()
        self.tru = None
        self.truAt = -1e9
        self.tgt = None
        self.tgts = []                 # the last few TGT1s
        self.pending = []              # TRU1s waiting for their TGT1
        self.s_used = None             # the TRU1 the filter has reached
        self.geo = None
        self.hist = []                 # (t, x, y, z) filtered CG-CG, ft
        self.raw_tcs = None            # (t, rng, rdot, elv, azi)
        self.next_tcs = None
        self.next_hhl = None
        self.hhl = []                  # (t, range, rdot) marks
        self.hhl_flt = None            # (t, range, rdot)
        self.last_v = None             # (t, v, r) for IMU delta-V
        self.dv_acc = np.zeros(3)
        self.socks = []
        for off, fn in ((TRUTH_OFFSET, self._tru), (TARGET_OFFSET, self._tgt)):
            s = mcast_socket(port_base + off)
            nt = QtCore.QSocketNotifier(s.fileno(), QtCore.QSocketNotifier.Type.Read, self)
            nt.activated.connect(lambda _x, s=s, fn=fn: self._drain(s, fn))
            self.socks.append((s, nt))
        self.flusher = QtCore.QTimer(self)
        self.flusher.timeout.connect(self._flush)
        self.flusher.start(200)
        log("TRU1 on port %d, TGT1 on port %d, interface %s"
            % (port_base + TRUTH_OFFSET, port_base + TARGET_OFFSET,
               os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')))

    def _drain(self, s, fn):
        while True:
            try:
                d = s.recv(2048)
            except (BlockingIOError, OSError):
                break
            fn(d)

    def _tgt(self, d):
        g = parse_tgt(d)
        if g is None:
            return
        if self.tgt is None:
            log("TGT1: NORAD %d" % g["norad"])
        if self.tgts and g["t"] < self.tgts[-1]["t"] - 1.0:
            self.tgts = []
        self.tgt = g
        self.tgts.append(g)
        del self.tgts[:-40]
        self._flush()

    def pcm_ok(self):
        return self.tru is not None and time.monotonic() - self.truAt < STALE_S

    def tgt_at(self, t):
        """The target at vehicle time t, from the TGT1 nearest it."""
        g = min(self.tgts, key=lambda g: abs(g["t"] - t)) if self.tgts else self.tgt
        dt = t - g["t"]
        a = gravity(g["r"])
        r = np.array(g["r"]) + np.array(g["v"]) * dt + 0.5 * a * dt * dt
        return {"r": r, "v": np.array(g["v"]) + a * dt, "q": g["q"]}

    def _tru(self, d):
        s = parse_tru(d)
        if s is None:
            return
        if self.tru is not None and s["t"] < self.tru["t"] - 1.0:
            log("vehicle time went back (%.1f -> %.1f): a new run; trajectory cleared"
                % (self.tru["t"], s["t"]))
            self.clear()
        if self.tru is None:
            log("TRU1: first datagram, t %.1f" % s["t"])
        self.tru, self.truAt = s, time.monotonic()
        self.pending.append((s, self.truAt))
        self._flush()

    def _flush(self):
        """Each TRU1 in turn, once the TGT1 of its time is in (or it has
        waited half a second): the two arrive separately, and a target
        carried far forward is metres off."""
        now = time.monotonic()
        while self.pending:
            s, at = self.pending[0]
            ready = bool(self.tgts) and self.tgts[-1]["t"] >= s["t"] - 1e-6
            if not ready and now - at < 0.5:
                break
            self.pending.pop(0)
            self._process(s)

    def _process(self, s):
        t = s["t"]
        # The IMU's sensed delta-V: the change in velocity less gravity's.
        if self.last_v is not None and 0.0 < t - self.last_v[0] < 5.0:
            h = t - self.last_v[0]
            gm = 0.5 * (gravity(self.last_v[2]) + gravity(s["r"]))
            self.dv_acc += np.array(s["v"]) - self.last_v[1] - gm * h
        self.last_v = (t, np.array(s["v"]), np.array(s["r"]))
        if self.tgt is None:
            return
        tgt = self.tgt_at(t)
        self.s_used = s
        if self.next_tcs is None or t >= self.next_tcs or t < self.next_tcs - 2 * TCS_PERIOD_S:
            self.next_tcs = t + TCS_PERIOD_S
            self._mark(t, s, tgt)

    def geometry(self, s, tgt):
        L = lvlh(tgt["r"], tgt["v"])
        C = ri.qmat(s["q"])
        A = L.T @ np.array(C)                                  # body -> LVLH
        arm = (np.array(ri.TCS_BODY) - np.array(s["cg"])) / FT
        n = ri.orbital_rate(tgt["r"], tgt["v"])
        w_lvlh_body = A @ np.array(s["w"])                     # body rate, in LVLH axes
        wrel = w_lvlh_body - np.array([0.0, -n, 0.0])           # less LVLH's own turn
        return {"A": A, "arm": arm, "wrel": wrel, "L": L, "n": n}

    def rel_truth(self, s, tgt, geo):
        L = geo["L"]
        dr = L.T @ (np.array(s["r"]) - tgt["r"]) / FT
        dv = L.T @ (np.array(s["v"]) - tgt["v"]) / FT
        dv -= np.cross(np.array([0.0, -geo["n"], 0.0]), dr)
        return dr, dv

    def _mark(self, t, s, tgt):
        geo = self.geometry(s, tgt)
        self.geo = geo
        rd = self.inst.read(s, tgt)
        dv = geo["L"].T @ self.dv_acc / FT
        self.dv_acc = np.zeros(3)
        dv_use = dv if np.linalg.norm(dv) * FT > DV_THRESHOLD else None
        if "tcs_range_ft" in rd:
            azi, elv = (math.radians(a) for a in rd["tcs_bearing_deg"])
            z = np.array([rd["tcs_range_ft"], rd["tcs_rdot_fps"], elv, azi])
            if self.raw_tcs is None:
                log("TCS: track at %.0f ft" % z[0])
            self.raw_tcs = (t, z[0], z[1], math.degrees(elv), math.degrees(azi))
            self.nav.update(t, z, geo, geo["n"], dv_use)
        elif self.nav.x is not None:
            self.nav.propagate(t, geo["n"], dv_use)
        if self.nav.x is not None:
            x = self.nav.x
            if not self.hist or t - self.hist[-1][0] >= 1.0:
                self.hist.append((t, x[0], x[1], x[2]))
                del self.hist[:-20000]
            if int(t) % 30 == 0:
                tr, _ = self.rel_truth(s, tgt, geo)
                log("t %.0f nav %.1f %.1f %.1f ft, truth %.1f %.1f %.1f ft"
                    % (t, x[0], x[1], x[2], tr[0], tr[1], tr[2]))
        # no HHL marks closer than 12 ft ([RNDZ] 7-21, note 9)
        if ("hhl_range_ft" in rd and rd["hhl_range_ft"] >= 12.0
                and (self.next_hhl is None or t >= self.next_hhl)):
            self.next_hhl = t + HHL_PERIOD_S
            self._hhl_mark(t, rd["hhl_range_ft"], rd["hhl_rdot_fps"])

    def _hhl_mark(self, t, rng, rdot):
        self.hhl.append((t, rng, rdot))
        del self.hhl[:-50]
        if self.hhl_flt is None:
            self.hhl_flt = (t, rng, rdot)
            return
        t0, r0, v0 = self.hhl_flt
        dt = t - t0
        rp = r0 + v0 * dt
        a, b = 0.5, 0.15
        e = rng - rp
        self.hhl_flt = (t, rp + a * e, v0 + b * e / max(dt, 1e-3))

    def clear(self):
        self.nav.reset()
        self.hist = []
        self.raw_tcs = None
        self.hhl = []
        self.hhl_flt = None
        self.next_tcs = self.next_hhl = None
        self.last_v = None
        self.dv_acc = np.zeros(3)
        self.pending = []
        self.tgts = []
        self.geo = None


# ---------------------------------------------------------------------------
# The display.

def nice_step(span):
    """50, 100, 500, 1000 ... ft ticks: about four across the span."""
    for s in (5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000):
        if span / s <= 6:
            return s
    return 100000


def fmt_met(sec):
    if sec is None:
        return ""
    sec = int(math.floor(sec))
    d, r = divmod(sec, 86400)
    return "%d/%02d:%02d:%02d" % (d, r // 3600, (r % 3600) // 60, r % 60)


def parse_dhms(s):
    d, hms = s.split("/")
    h, m, sec = hms.split(":")
    return int(d) * 86400 + int(h) * 3600 + int(m) * 60 + float(sec)


class View(QtWidgets.QWidget):
    VIEWS = ("XZ", "XY", "YZ")

    def __init__(self, rpop, args):
        super().__init__()
        self.rp = rpop
        self.args = args
        self.view = 0
        self.por = args.por
        self.show_rdot = True
        self.fkeys = False
        self.zoom = 1.0
        self.pan = [0.0, 0.0]
        self.scale_hold = None
        fams = set(QtGui.QFontDatabase.families())
        fam = next((f for f in ("Courier New", "Menlo", "DejaVu Sans Mono", "Courier") if f in fams),
                   "Monospace")
        self.fam = fam
        self.met_zero = parse_dhms(args.met_zero)
        self.setFocusPolicy(QtCore.Qt.FocusPolicy.StrongFocus)
        t = QtCore.QTimer(self)
        t.timeout.connect(self.update)
        t.start(200)

    def font(self, px, bold=False):
        f = QtGui.QFont(self.fam)
        f.setPixelSize(int(px))
        f.setBold(bold)
        f.setStyleHint(QtGui.QFont.StyleHint.TypeWriter)
        return f

    # --- what is shown --------------------------------------------------
    def por_dp(self):
        if self.por == "dp":
            return True
        if self.por == "cg":
            return False
        x = self.rp.nav.x
        return x is not None and np.linalg.norm(x[:3]) < 400.0     # the APPROACH card's switch

    def state_shown(self):
        """(pos, vel) of the point of reference, LVLH ft, ft/s; and the CG."""
        nav = self.rp.nav
        if nav.x is None or getattr(self.rp, "geo", None) is None:
            return None
        x = nav.x
        cg = x[:3].copy()
        if not self.por_dp():
            return x[:3], x[3:], cg
        geo = self.rp.geo
        A = geo["A"]
        ods = (np.array(ri.ODS_BODY) - np.array(self.rp.tru["cg"])) / FT
        p = x[:3] + A @ ods - ri_pma2_ft()
        v = x[3:] + np.cross(geo["wrel"], A @ ods)
        return p, v, cg

    # --- keys -------------------------------------------------------------
    def keyPressEvent(self, ev):
        k, m = ev.key(), ev.modifiers()
        K, M = QtCore.Qt.Key, QtCore.Qt.KeyboardModifier
        ctrl, shift = bool(m & M.ControlModifier), bool(m & M.ShiftModifier)
        if sys.platform == "darwin":       # Qt swaps them there; the PGSC's Ctrl is the Ctrl key
            ctrl = bool(m & M.MetaModifier) or ctrl
        if k == K.Key_F10 and shift:
            QtWidgets.QApplication.quit()
        elif k == K.Key_F5 and not (ctrl or shift):
            self.show_rdot = not self.show_rdot
        elif k == K.Key_F7 and not (ctrl or shift):
            self.view = (self.view + 1) % len(self.VIEWS)
        elif k == K.Key_F8 and ctrl:
            self.por = "cg" if self.por_dp() else "dp"
        elif k == K.Key_F9 and shift:
            self.rp.hist = self.rp.hist[-2:]
        elif k == K.Key_F9 and ctrl:
            self.rp.hist = self.rp.hist[:-1]
        elif k == K.Key_Space:
            self.fkeys = not self.fkeys
        elif ctrl and k == K.Key_PageUp:
            self.zoom *= 1.05 if shift else 1.25
        elif ctrl and k == K.Key_PageDown:
            self.zoom /= 1.05 if shift else 1.25
        elif ctrl and k == K.Key_Home:
            self.zoom, self.pan = 1.0, [0.0, 0.0]
        elif ctrl and k in (K.Key_Left, K.Key_Right, K.Key_Up, K.Key_Down):
            st = 5.0 if shift else 25.0
            if k == K.Key_Left:
                self.pan[0] -= st
            elif k == K.Key_Right:
                self.pan[0] += st
            elif k == K.Key_Up:
                self.pan[1] -= st
            else:
                self.pan[1] += st
        else:
            super().keyPressEvent(ev)
        self.update()

    # --- drawing ------------------------------------------------------------
    def paintEvent(self, _ev):
        p = QtGui.QPainter(self)
        p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing, True)
        p.fillRect(self.rect(), QtGui.QColor(0, 0, 0))
        sx, sy = self.width() / DESIGN_W, self.height() / (DESIGN_H - 40)
        p.scale(sx, sy)
        self.draw(p)
        p.end()

    def text(self, p, x, y, s, px, color, bold=False, align="l", w=None):
        p.setFont(self.font(px, bold))
        p.setPen(color)
        fm = QtGui.QFontMetricsF(p.font())
        if align == "r":
            x -= fm.horizontalAdvance(s)
        elif align == "c":
            x -= fm.horizontalAdvance(s) / 2.0
        p.drawText(QtCore.QPointF(x, y), s)

    def draw(self, p):
        rp = self.rp
        H = DESIGN_H - 40                       # the client area under the menu bar
        if not rp.pcm_ok():
            # [RNDZ] 7-15: the message RPOP shows without PCMMU data
            self.text(p, DESIGN_W / 2, H * 0.55, "RPOP is not receiving PCMMU data", 17, RED, align="c")
            self.draw_fkeys(p, H)
            return
        st = self.state_shown()
        self.draw_plot(p, H, st)
        self.draw_header(p, st)
        self.draw_raw_tcs(p)
        self.draw_met(p)
        self.draw_resids(p, H)
        if self.show_rdot:
            self.draw_rdot(p)
        self.draw_fkeys(p, H)

    def draw_header(self, p, st):
        rp = self.rp
        nav = rp.nav
        age = "" if nav.last_accept is None else "%d" % max(0, int(rp.tru["t"] - nav.last_accept))
        self.text(p, 8, 20, "Prop Age", 15, GREY_TXT)
        self.text(p, 130, 20, age, 15, GREY_TXT, align="r")
        por = "Orb DP to Tgt DP" if self.por_dp() else "Orb CG to Tgt CG"
        self.text(p, 410, 165, por, 18, WHITE, bold=True, align="c")
        if st is None:
            return
        pos, vel, _ = st
        r = float(np.linalg.norm(pos))
        rdot = float(pos @ vel) / r if r > 1e-6 else 0.0
        self.text(p, 262, 34, "R", 28, GREEN, bold=True)
        self.text(p, 372, 34, "%.0f" % r, 28, GREEN, bold=True, align="r")
        self.text(p, 400, 34, "R", 28, GREEN, bold=True)
        self.dot(p, 409, 8, GREEN, 2.5)
        self.text(p, 545, 34, ("%.2f" if abs(rdot) < 10 else "%.1f") % rdot, 28, GREEN, bold=True,
                  align="r")
        for i, (nm, y) in enumerate((("X", 72), ("Y", 98), ("Z", 124))):
            self.text(p, 264, y, nm, 19, GREEN)
            self.text(p, 372, y, "%.0f" % pos[i] if abs(pos[i]) >= 0.5 or pos[i] >= 0 else "-0",
                      19, GREEN, align="r")
            self.text(p, 403, y, nm, 19, GREEN)
            self.dot(p, 409, y - 17, GREEN, 1.8)
            self.text(p, 545, y, "%.2f" % vel[i], 19, GREEN, align="r")

    def dot(self, p, x, y, color, rad):
        p.setPen(QtCore.Qt.PenStyle.NoPen)
        p.setBrush(color)
        p.drawEllipse(QtCore.QPointF(x, y), rad, rad)
        p.setBrush(QtCore.Qt.BrushStyle.NoBrush)

    def draw_raw_tcs(self, p):
        rp = self.rp
        x0, xr = 688, 822
        self.text(p, x0 - 6, 18, "Raw TCS 2(CW)", 15, GREEN)
        rows = [("Refl", "1"), ("Age", ""), ("Rng", ""), ("Rdot", ""), ("Elv", ""), ("Azi", "")]
        if rp.raw_tcs is not None:
            t, rng, rdot, elv, azi = rp.raw_tcs
            rows = [("Refl", "1"), ("Age", "%d" % max(0, int(rp.tru["t"] - t))),
                    ("Rng", "%.0f" % rng), ("Rdot", "%.2f" % rdot),
                    ("Elv", "%.2f" % elv), ("Azi", "%.2f" % azi)]
        for i, (nm, val) in enumerate(rows):
            y = 36 + 18 * i
            self.text(p, x0, y, nm, 15, GREEN)
            self.text(p, xr if i else x0 + 75, y, val, 15, GREEN, align="r" if i else "l")

    def draw_met(self, p):
        rp = self.rp
        tru = rp.tru
        met = tru["gmt"] - self.met_zero if tru["gmt"] > 0 else None
        self.text(p, 870, 18, "MET:", 15, GREY_TXT)
        self.text(p, 1018, 18, fmt_met(met), 15, GREY_TXT, align="r")
        pitch = alt = ""
        if rp.tgt is not None and getattr(rp, "geo", None) is not None:
            A = rp.geo["A"]
            fwd = math.degrees(math.atan2(-A[2, 0], A[0, 0]))
            pitch = "%d" % (int(round(fwd + 90.0)) % 360)
            alt = "%d" % round((np.linalg.norm(rp.tgt["r"]) - RE) / NMI)
        self.text(p, 935, 36, "Pitch", 15, GREY_TXT)
        self.text(p, 1018, 36, pitch, 15, GREY_TXT, align="r")
        self.text(p, 935, 54, "Alt", 15, GREY_TXT)
        self.text(p, 1018, 54, alt, 15, GREY_TXT, align="r")

    def draw_resids(self, p, H):
        nav = self.rp.nav
        if nav.x is None:
            return
        y0 = H - 118
        cols = (("RESID", 112), ("RATIO", 172), ("ACPT", 225), ("REJ", 268))
        for nm, x in cols:
            self.text(p, x, y0, nm, 14, GREY_TXT, align="r")
        for i, nm in enumerate(TcsNav.NAMES):
            y = y0 + 19 * (i + 1)
            self.text(p, 8, y, nm, 14, GREY_TXT)
            if nav.resid[i] is None:
                continue
            vals = ("%.2f" % abs(nav.resid[i]) if i else "%.1f" % abs(nav.resid[i]),
                    "%.2f" % nav.ratio[i], "%d" % nav.acpt[i], "%d" % nav.rej[i])
            for (nm2, x), v in zip(cols, vals):
                self.text(p, x, y, v, 14, GREY_TXT, align="r")

    def draw_fkeys(self, p, H):
        """PCM mode is selected ([RNDZ] 7-15): \"PCM\" whether or not data come."""
        y = H - 14
        if self.fkeys:
            # [RNDZ] 7-22..7-25: each key's plain, Shift and Ctrl names
            labels = [("", "", ""), ("", "", ""), ("TCS NAV", "Show/Hide", "Data"), ("", "", ""),
                      ("Rdot", "Orb Att", "Guid"), ("Sub Ang", "Tgt Att", "PCM"),
                      ("View", "Ovrlay", ""), ("Tgt/Orb", "Low Z", "POR"),
                      ("THC Clr", "TrajClr", "Back 1"), ("Help", "Exit", "Config"),
                      ("Declutter", "", ""), ("Rng Ruler", "Clear", "")]
            w = DESIGN_W / 12.0
            top = H - 46
            p.setPen(QtGui.QPen(GREY_TXT, 1))
            for i, (a, b, c) in enumerate(labels):
                r = QtCore.QRectF(i * w + 1, top, w - 2, 44)
                if i == 2:
                    p.fillRect(r, GREEN)
                p.setPen(QtGui.QPen(GREY_TXT, 1))
                p.drawRect(r)
                col = QtGui.QColor(0, 0, 0) if i == 2 else GREY_TXT
                for j, s in enumerate((c, b, a)):
                    self.text(p, i * w + w / 2, top + 13 + 14 * j, s, 11, col, align="c")
            return
        # [GNC], [JSC]: the prime trajectory's key and the PCM status above F6
        r = QtCore.QRectF(242, y - 13, 96, 17)
        p.fillRect(r, GREEN)
        self.text(p, 290, y, "TCS NAV", 12, QtGui.QColor(0, 0, 0), align="c")
        self.text(p, 576, y, "PCM", 12, GREY_TXT, align="c")

    def draw_rdot(self, p):
        """The Rdot window: a Windows dialog over the plot ([GNC], [RNDZ] 7-16)."""
        rp = self.rp
        x0, y0, w, h = 732, 340, 288, 124
        p.fillRect(QtCore.QRectF(x0, y0, w, h), DLG)
        p.fillRect(QtCore.QRectF(x0 + 2, y0 + 2, w - 4, 14), QtGui.QColor(128, 128, 128))
        black = QtGui.QColor(0, 0, 0)
        # the [sources] button and the column heads
        p.setPen(QtGui.QPen(QtGui.QColor(255, 255, 255), 1))
        p.drawRect(QtCore.QRectF(x0 + 4, y0 + 20, 60, 18))
        self.text(p, x0 + 34, y0 + 33, "sources", 10, black, align="c")
        for nm, x in (("Rng", x0 + 152), ("Rdot", x0 + 210), ("Age", x0 + 278)):
            self.text(p, x, y0 + 33, nm, 13, black, bold=True, align="r")
        p_rows = []
        t = rp.tru["t"]
        flt = rp.hhl_flt
        dt_row = None
        if len(rp.hhl) >= 2:
            (t1, r1, _), (t2, r2, _) = rp.hhl[-2], rp.hhl[-1]
            dt_row = (r2, (r2 - r1) / (t2 - t1), t2)
        raw = rp.hhl[-1] if rp.hhl else None
        p_rows = [("HHLFlt", None if flt is None else (flt[1], flt[2], flt[0])),
                  ("HHL/dt", dt_row),
                  ("HHLRaw", None if raw is None else (raw[1], raw[2], raw[0]))]
        p.fillRect(QtCore.QRectF(x0 + 76, y0 + 42, w - 80, 78), black)
        for i, (nm, v) in enumerate(p_rows):
            y = y0 + 42 + 26 * i
            br = QtCore.QRectF(x0 + 4, y + 1, 70, 24)
            p.fillRect(br, DLG)
            p.setPen(QtGui.QPen(QtGui.QColor(255, 255, 255), 1))
            p.drawLine(br.topLeft(), br.topRight())
            p.drawLine(br.topLeft(), br.bottomLeft())
            p.setPen(QtGui.QPen(QtGui.QColor(90, 90, 90), 1))
            p.drawLine(br.bottomLeft(), br.bottomRight())
            p.drawLine(br.topRight(), br.bottomRight())
            self.text(p, x0 + 39, y + 18, nm, 14, black, bold=True, align="c")
            if v is None:
                continue
            rng, rdot, tm = v
            self.text(p, x0 + 152, y + 19, "%.0f" % rng, 16, WHITE, align="r")
            self.text(p, x0 + 210, y + 19, "%.2f" % rdot, 16, WHITE, align="r")
            self.text(p, x0 + 278, y + 19, "%d" % max(0, int(t - tm)), 12, WHITE, align="r")

    # --- the trajectory plot ---------------------------------------------------
    def axes_of(self):
        """Indices into LVLH (x, y, z) for the horizontal and vertical axes,
        and their signs on the screen (+X to the left, +Z down, as [JSC])."""
        return {"XZ": ((0, -1), (2, 1)), "XY": ((0, -1), (1, 1)), "YZ": ((1, 1), (2, 1))}[
            self.VIEWS[self.view]]

    def draw_plot(self, p, H, st):
        rp = self.rp
        (ih, sh), (iv, sv) = self.axes_of()
        hist = rp.hist
        dp = self.por_dp()
        off = np.zeros(3)
        if st is not None:
            pos, vel, cg = st
            off = pos - cg                       # the POR's offset from the CG, now
        pts = [np.array([h[1], h[2], h[3]]) + off for h in hist]
        preds = []
        if rp.nav.x is not None:
            s = rp.nav.x.copy()
            n = rp.geo["n"]
            for k in range(1, 10):
                s = cw_step(s, n, 60.0)
                preds.append(s[:3] + off)
        # autoscale: the target, the orbiter and its predictors
        span_pts = [np.zeros(3)] + ([st[0]] if st is not None else []) + preds
        hs = [q[ih] * sh for q in span_pts]
        vs = [q[iv] * sv for q in span_pts]
        top, bot = 190.0, H - 135.0
        left, right = 20.0, DESIGN_W - 20.0
        ext = max(max(hs) - min(hs), (max(vs) - min(vs)) * (right - left) / (bot - top), 150.0)
        k = (right - left) / (ext * 1.25) * self.zoom          # px per ft
        ch = 0.5 * (max(hs) + min(hs))
        cv = 0.5 * (max(vs) + min(vs))
        ox = (left + right) / 2 - ch * k + self.pan[0]
        oy = (top + bot) / 2 - cv * k + self.pan[1]

        def to_px(q):
            return QtCore.QPointF(ox + q[ih] * sh * k, oy + q[iv] * sv * k)

        p.save()
        p.setClipRect(QtCore.QRectF(0, 0, DESIGN_W, H - 20))
        # axes through the target, with ticks
        pen = QtGui.QPen(GREY_TXT, 1)
        p.setPen(pen)
        p.drawLine(QtCore.QPointF(0, oy), QtCore.QPointF(DESIGN_W, oy))
        p.drawLine(QtCore.QPointF(ox, 0), QtCore.QPointF(ox, H))
        step = nice_step((right - left) / k)
        tick = 7
        for i in range(-60, 61):
            if i == 0:
                continue
            x = ox + i * step * k
            if -10 < x < DESIGN_W + 10:
                p.drawLine(QtCore.QPointF(x, oy - tick), QtCore.QPointF(x, oy + tick))
            y = oy + i * step * k
            if -10 < y < H + 10:
                p.drawLine(QtCore.QPointF(ox - tick, y), QtCore.QPointF(ox + tick, y))
        self.text(p, ox - step * k, oy - 10, "%d" % step, 13, GREY_TXT, align="c")
        self.text(p, ox - 12, oy + step * k + 5, "%d" % step, 13, GREY_TXT, align="r")
        self.draw_overlay(p, to_px, ih, iv, np.zeros(3) if dp else ri_pma2_ft())
        self.draw_target(p, to_px, ih, iv, dp)
        # the prime trajectory: its history, the orbiter, the predictors
        tri = QtGui.QPolygonF([QtCore.QPointF(0, -4.5), QtCore.QPointF(4, 3), QtCore.QPointF(-4, 3)])
        p.setPen(QtCore.Qt.PenStyle.NoPen)
        p.setBrush(GREEN)
        last = None
        for q in pts:                      # [JSC]: a triangle per mark, drawn where they part
            c = to_px(q)
            if last is None or abs(c.x() - last.x()) + abs(c.y() - last.y()) >= 6.0:
                p.drawPolygon(tri.translated(c))
                last = c
        p.setBrush(QtCore.Qt.BrushStyle.NoBrush)
        if st is not None:
            self.draw_orbiter(p, to_px, ih, iv, st)
        for i, q in enumerate(preds):
            self.text(p, to_px(q).x() - 4, to_px(q).y() + 5, "%d" % (i + 1), 14, GREEN)
        p.restore()
        # the view's axes key, top left ([JSC]: "x<- TGT LVLH, z down")
        names = "xyz"
        self.draw_axis_key(p, names[ih], names[iv], sh, sv)

    def draw_axis_key(self, p, hn, vn, sh, sv):
        """[JSC]: an arrow for each axis of the view, "TGT LVLH" in the corner."""
        x0, y0 = 40, 112
        p.setPen(QtGui.QPen(GREY_TXT, 1.2))
        hx = x0 - 26 if sh < 0 else x0 + 26
        d = 5 if sh < 0 else -5
        p.drawLine(QtCore.QPointF(x0, y0), QtCore.QPointF(hx, y0))
        p.drawLine(QtCore.QPointF(hx, y0), QtCore.QPointF(hx + d, y0 - 4))
        p.drawLine(QtCore.QPointF(hx, y0), QtCore.QPointF(hx + d, y0 + 4))
        vy = y0 + 30
        p.drawLine(QtCore.QPointF(x0, y0), QtCore.QPointF(x0, vy))
        p.drawLine(QtCore.QPointF(x0, vy), QtCore.QPointF(x0 - 4, vy - 5))
        p.drawLine(QtCore.QPointF(x0, vy), QtCore.QPointF(x0 + 4, vy - 5))
        self.text(p, hx - 10 if sh < 0 else hx + 3, y0 + 4, hn, 12, GREY_TXT)
        self.text(p, x0 - 3, vy + 13, vn, 12, GREY_TXT)
        self.text(p, x0 - 4, y0 + 14, "TGT", 10, GREY_TXT, align="r")
        self.text(p, x0 - 4, y0 + 25, "LVLH", 10, GREY_TXT, align="r")

    def draw_overlay(self, p, to_px, ih, iv, face):
        """The +V-bar docking corridor ([RNDZ] CC 9-7, 9-8; drawn as [JSC]):
        8 deg out to 250 ft, the 170 +/- 10 ft hold, 5 deg inside 30 ft, and
        the 350-250 ft V-bar arrival zone."""
        if ih != 0:
            return
        p.setPen(QtGui.QPen(WHITE, 1))

        def P(x, lat):                     # about PMA-2's face and axis
            q = face.copy()
            q[0] += x
            q[iv] += lat
            return to_px(q)

        t8, t5 = math.tan(math.radians(8.0)), math.tan(math.radians(5.0))
        for a, b in ((P(0, 0), P(250, 250 * t8)), (P(0, 0), P(250, -250 * t8)),
                     (P(250, 250 * t8), P(250, -250 * t8)),
                     (P(160, 160 * t8), P(160, -160 * t8)), (P(180, 180 * t8), P(180, -180 * t8)),
                     (P(0, 0), P(30, 30 * t5)), (P(0, 0), P(30, -30 * t5)),
                     (P(30, 30 * t5), P(30, -30 * t5)),
                     (P(250, 250 * t8), P(350, 350 * t8)), (P(250, -250 * t8), P(350, -350 * t8)),
                     (P(350, 350 * t8), P(350, -350 * t8))):
            p.drawLine(a, b)

    def draw_target(self, p, to_px, ih, iv, dp):
        """PMA-2 and Node 2 ahead of the ISS ([JSC] draws the node as a box):
        PMA-2's face at rndz_instruments.PMA2, ~6 ft across and 8 ft long,
        then Node 2, 14.5 ft across and 24 ft long, aft of it (-X)."""
        face = np.zeros(3) if dp else ri_pma2_ft()
        p.setPen(QtGui.QPen(WHITE, 1))

        def box(x0, x1, half):
            q = []
            for x, lat in ((x0, -half), (x1, -half), (x1, half), (x0, half)):
                v = face.copy()
                v[0] += x
                if iv != 0:
                    v[iv] += lat
                q.append(to_px(v))
            p.drawPolygon(QtGui.QPolygonF(q))

        if ih == 0:
            box(0.0, -8.0, 3.0)
            box(-8.0, -32.0, 7.25)

    def draw_orbiter(self, p, to_px, ih, iv, st):
        """The orbiter's outline at its attitude, and its CG (the [JSC] circle-plus)."""
        _, _, cg = st
        shift = -ri_pma2_ft() if self.por_dp() else np.zeros(3)
        A = self.rp.geo["A"]
        cgb = np.array(self.rp.tru["cg"]) / FT

        def body(xz):
            b = np.array([xz[0], 0.0, xz[1]]) - cgb
            return cg + shift + A @ b

        p.setPen(QtGui.QPen(WHITE, 1))
        for outline in (ORBITER_OUTLINE, ODS_OUTLINE):
            p.drawPolygon(QtGui.QPolygonF([to_px(body(q)) for q in outline]))
        c = to_px(cg + shift)
        p.drawEllipse(c, 4, 4)
        p.drawLine(QtCore.QPointF(c.x() - 4, c.y()), QtCore.QPointF(c.x() + 4, c.y()))
        p.drawLine(QtCore.QPointF(c.x(), c.y() - 4), QtCore.QPointF(c.x(), c.y() + 4))


class Window(QtWidgets.QMainWindow):
    def __init__(self, rpop, args):
        super().__init__()
        self.setWindowTitle("RPOP")
        mb = self.menuBar()
        mb.setNativeMenuBar(False)                # in the window, as on the PGSC
        for name in ("File", "Edit", "Control", "Views", "Display", "Sensors", "Help"):
            m = mb.addMenu(name)
            if name == "File":
                a = m.addAction("Exit\tShift+F10")
                a.triggered.connect(QtWidgets.QApplication.quit)
        self.view = View(rpop, args)
        self.setCentralWidget(self.view)
        h = args.size
        self.resize(int(round(h * DESIGN_W / DESIGN_H)), h)
        self.view.setFocus()


def main(argv=None):
    ap = argparse.ArgumentParser(description="RPOP, the Rendezvous and Proximity Operations Program's "
                                             "trajectory display (TCS NAV prime).")
    ap.add_argument("--port-base", type=int,
                    default=int(os.environ.get("NSTS_BUS_PORT_BASE", "6900")))
    ap.add_argument("--size", type=int, default=DESIGN_H, metavar="N",
                    help="window height in pixels; 768 is the PGSC's 1024 x 768 screen")
    ap.add_argument("--por", choices=("auto", "cg", "dp"), default="auto",
                    help="point of reference: Orb CG to Tgt CG, Orb DP to Tgt DP, or auto "
                         "(DP-DP inside 400 ft, as the APPROACH cue card has the crew select)")
    ap.add_argument("--met-zero", default=MET_ZERO, metavar="DDD/HH:MM:SS",
                    help="GMT of MET zero (default STS-134's, %s)" % MET_ZERO)
    ap.add_argument("--seed", type=int, default=134, help="the instruments' noise seed")
    ap.add_argument("--snapshot", metavar="PNG", help="save the window after --snapshot-after s and exit")
    ap.add_argument("--snapshot-after", type=float, default=5.0, metavar="S")
    args = ap.parse_args(argv)
    try:
        import macdock
        macdock.set_app_name("RPOP")
    except Exception:
        pass
    app = QtWidgets.QApplication(sys.argv[:1])
    rp = Rpop(args.port_base, args.seed)
    w = Window(rp, args)
    w.show()
    if args.snapshot:
        def snap():
            w.grab().save(args.snapshot)
            log("snapshot %s" % args.snapshot)
            app.quit()
        QtCore.QTimer.singleShot(int(args.snapshot_after * 1000), snap)
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
