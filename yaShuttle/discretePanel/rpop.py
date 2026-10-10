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
    propagation about the target's orbit; the IMU's sensed delta-V (the
    truth's velocity change relative to the target's, less the difference
    in gravity) in the IMU's 0.01049 m/s counts, taken once it passes
    [NESC]'s 0.01829 m/s threshold (held until then, not dropped: dropped,
    the docking's jet pulses went unmodelled); HPH' underweighted x 1.2
    while sqrt(Pxx+Pyy+Pzz) > 10 ft, as [NESC] says; process noise
    1e-2 ft/s^2, our choice (examples/rpop_filtercheck.py); the
    four TCS measurements processed one at a time with exactly
    rndz_instruments' geometry (the TCS head's lever arm, the reflector at
    PMA-2's face in the target's own attitude, the same bearing signs); an
    edit test at three sigma, taken anyway after five rejections in a row
    (the checklist's "Force Measurements") -- with the variances set wider
    than rndz_instruments' noise, as [NESC] says RPOP's were.  Checked on
    examples/rpop_synth.py's docking (jet pulses, capture, hard mate): within
    0.1 ft of the truth from 100 ft through contact, residual ratios under
    0.5, and DP-DP 0.0 +/- 0.03 ft for 20 minutes mated.
  - TCS to contact: JSC-63400 Fig 20.4 has TCS NAV still accepting marks at
    docking (raw Rng 5, REJ 0), and the VBAR APPROACH card lists raw TCS
    ranges to contact, so no minimum range is modelled.  (The STS-134
    checklist's STORRM pages, 7-41, do say "when range < 10 ft, TCS data will
    be lost and PGSC ALERT will be annunciated".)
  - The Orbiter's DP is the ODS ring's face: ready to dock (Zo 475.75) until
    TRU1 [30] says hard-mated, then retracted (Zo 460).  RATIO is the
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
  - The plot's frame is fixed, as JSC-63400 Fig 20.4's: the target's point
    91 % across and 43 % down, 50 ft ticks ~10 % of the width apart.  Only
    the documented keys change it (Ctrl+PgUp/PgDn, Ctrl+arrows, Ctrl+Home).
  - HHL: rndz_instruments' reading (the cue cards' ranges: CG-CG less 10 ft
    on the approach, DP-DP plus 7 ft to Node 2 on the V-bar, none inside
    12 ft); a mark every 5 s; HHL/dt is the range difference over the last
    mark, HHLFlt an alpha-beta filter on the marks (the real one also used
    radar R-dot, which this simulator does not feed RPOP).

KEYS, from the checklist's RPOP FUNCTION KEY SUMMARY: F5 Rdot window,
F7 view (XZ, XY, YZ), Shift+F7 overlay, F8 target / orbiter centred,
Ctrl+F8 point of reference (CG-CG / DP-DP), F9 THC clear, Shift+F9 clear
trajectory, Ctrl+F9 back 1, Shift+F10 exit, Ctrl+F10 RPOP Configuration,
Ctrl+PgUp / Ctrl+PgDn zoom (with X, Y or Z held, that axis only),
Ctrl+Home "Resume autoscaling and reset scale" (autoscaling: the scale
only, in steps, never moving the target; see AUTO_STEPS), Ctrl+arrows move the axes, Space
the function-key menu, arrows the THC "What if" pulses (-Z sense: Right
Z IN, Left Z OUT, Up X UP, Down X DOWN; plain DAP B8, Shift DAP A8).
The menus hold the same functions with their keys; the undescribed ones
are greyed, and so is Help.

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
# [NESC] 6.1: the IMU's sensed velocity comes in counts of 0.01049 m/s per
# axis, and RPOP takes a delta-V into its propagation only when its
# magnitude exceeds 0.01829 m/s (the REL NAV software's own threshold)
IMU_LSB_MPS = 0.01049
DV_THRESH_MPS = 0.01829
UNDERWEIGHT_FT = 10.0                   # [NESC]: HPH' x 1.2 while sqrt(Pxx+Pyy+Pzz) > 10
UNDERWEIGHT_K = 1.2
HHL_PERIOD_S = 5.0
# The plot's frame, from JSC-63400 Fig 20.4 (1770 px wide): the target's
# point at x 1605 (91 %), y 43 % down the plot; 50 ft ticks 185 px apart.
ORIGIN_X, ORIGIN_Y = 0.907, 0.434
PX_PER_FT = DESIGN_W * 185.0 / 1770.0 / 50.0
# Autoscaling (RNDZ 7-25: Ctrl+Home "Resume autoscaling and reset scale";
# each view "may be independently scaled and/or autoscaled").  How the real
# one chose its scale isn't described; this one only ever changes the scale,
# never moves the target, in steps: the scale at which ticks of AUTO_STEPS
# ft would sit [JSC]'s 50 ft apart.  It fits the orbiter's point of
# reference and its last AUTO_TRAIL_S of trail (not the predictors) inside
# the plot; it zooms out at once when one would leave AUTO_BOX, in only after
# they have all sat inside AUTO_COMFORT of it at the next step for AUTO_DWELL_S.
AUTO_STEPS = (5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000)
AUTO_TRAIL_S = 60.0
AUTO_DWELL_S = 10.0
AUTO_COMFORT = 0.7
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
            "cg": v[27:30] if n >= 30 else (0.0, 0.0, 0.0),
            "dock": int(v[30]) if n >= 31 else 0}        # 0 free, 1 captured, 2 hard-mated


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
    FORCE_AFTER = 5                 # then take it anyway (RNDZ 7-27's "Force Measurements")
    Q_ACC = 1e-2                    # ft/s^2: what the delta-V and CW miss -- chiefly the IMU's
                                    # sub-count remainder (rpop_filtercheck.py: 1e-2 best of 1e-3..1e-1)

    def __init__(self):
        self.force = True           # the TCS options' "Force Measurements" (RNDZ 7-27)
        self.reset()

    def reset(self):
        self.x = None
        self.P = None
        self.t = None
        self.resid = [None] * 4
        self.ratio = [None] * 4
        self.acpt = [0] * 4
        self.rej = [0] * 4
        self.run = [0] * 4             # rejections in a row
        self.last_accept = None

    @staticmethod
    def predict(x, geo):
        """TCS range (ft), range rate (ft/s), elevation and azimuth (rad)
        for the state x and the measurement geometry."""
        A, arm, wrel = geo["A"], geo["arm"], geo["wrel"]
        head = x[:3] + A @ arm
        los = geo["refl"] - head
        rng = np.linalg.norm(los)
        vhead = x[3:] + np.cross(wrel, A @ arm)
        rdot = float(los @ (-vhead)) / rng
        tb = A.T @ los
        azi = math.atan2(tb[1], -tb[2])
        elv = math.atan2(-tb[0], -tb[2])
        return np.array([rng, rdot, elv, azi])

    def init_from(self, z, geo, quiet=False):
        rng, rdot, elv, azi = z
        # the boresight -Z with the two bearings off it
        d = np.array([-math.tan(elv), math.tan(azi), -1.0])
        d /= np.linalg.norm(d)
        los = geo["A"] @ (d * rng)
        head = geo["refl"] - los
        x = np.zeros(6)
        x[:3] = head - geo["A"] @ geo["arm"]
        x[3:] = -rdot * los / rng                  # the range rate, along the line of sight
        self.x = x
        self.P = np.diag([(0.02 * rng + 2.0) ** 2] * 3 + [0.5 ** 2] * 3)
        if not quiet:
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
            HPH = float(H @ self.P @ H)
            if math.sqrt(max(0.0, self.P[0, 0] + self.P[1, 1] + self.P[2, 2])) > UNDERWEIGHT_FT:
                HPH *= UNDERWEIGHT_K               # [NESC]: Kalman filter underweighting
            S = HPH + sig * sig
            res = z[i] - h0[i]
            if i >= 2:
                res = (res + math.pi) % (2 * math.pi) - math.pi
            ratio = abs(res) / (3.0 * math.sqrt(S))
            self.resid[i] = math.degrees(res) if i >= 2 else res
            self.ratio[i] = ratio
            if ratio > 1.0 and self.acpt[i] > 5 and (not self.force or self.run[i] < self.FORCE_AFTER):
                self.rej[i] += 1
                self.run[i] += 1
                continue
            self.run[i] = 0
            K = self.P @ H / S
            self.x = self.x + K * res
            self.P = (np.eye(6) - np.outer(K, H)) @ self.P
            self.P = 0.5 * (self.P + self.P.T)
            self.acpt[i] += 1
        self.last_accept = t


def ri_pma2_ft():
    return np.array(ri.PMA2) / FT


def ods_face(cg, dock):
    """The ODS ring's face (the Orbiter's DP), body ft from the CG: ready to
    dock (Zo 475.75) until hard mate, then retracted (Zo 460)."""
    b = ri.ODS_HARDMATE_BODY if dock >= 2 else ri.ODS_BODY
    return (np.array(b) - np.array(cg)) / FT


def dp_of(x, geo, cg):
    """Orbiter DP to target DP (PMA-2's face), LVLH ft and ft/s, for the state x."""
    arm = geo["A"] @ ods_face(cg, geo["dock"])
    return x[:3] + arm - geo["refl"], x[3:] + np.cross(geo["wrel"], arm)


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
        self.hist = []                 # (t, CG-CG, DP-DP) filtered, LVLH ft
        self.raw_tcs = None            # (t, rng, rdot, elv, azi)
        self.next_tcs = None
        self.next_hhl = None
        self.hhl = []                  # (t, range, rdot) marks
        self.hhl_flt = None            # (t, range, rdot)
        self.last_v = None             # (t, v, r) for IMU delta-V
        self.dv_acc = np.zeros(3)      # delta-V for the filter's next propagation, M50 m/s
        self.imu_acc = np.zeros(3)     # the IMU's sub-count remainder
        self.dv_pend = np.zeros(3)     # counted, under the threshold
        # the TCS trajectory's options (RNDZ 7-27): "nav" (TCS NAV, Kalman
        # filtering), "auto" (each raw mark taken as it is), "none"
        self.tcs_mode = "nav"
        self.tcs_period = TCS_PERIOD_S   # RPOP Configuration's "Data Freq..." (RNDZ 7-24)
        self.auto = None               # (t, x) from the raw marks, TCS Auto
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
        if self.tgt is None:
            return
        tgt = self.tgt_at(t)
        # THE IMU'S SENSED DELTA-V: the change in velocity less gravity's.
        # Taken relative to the target, whose state RPOP had from the GPC
        # propagated by the same gravity: the change in the two velocities'
        # difference less the difference of gravity at the two (point mass
        # and J2 suffice for that difference; vehdyn's full field drops out).
        # Handed to the filter at the next mark.
        dv = np.array(s["v"]) - tgt["v"]
        dg = gravity(s["r"]) - gravity(tgt["r"])
        if self.last_v is not None and 0.0 < t - self.last_v[0] < 5.0:
            h = t - self.last_v[0]
            # the IMU's counts: the stable member is inertial, so M50 axes;
            # whole counts go out, the remainder stays in the accumulator
            self.imu_acc += dv - self.last_v[1] - 0.5 * (dg + self.last_v[2]) * h
            counts = np.trunc(self.imu_acc / IMU_LSB_MPS)
            self.imu_acc -= counts * IMU_LSB_MPS
            self.dv_pend += counts * IMU_LSB_MPS
            # [NESC]'s threshold: the sensed delta-V is taken only once it
            # exceeds 0.01829 m/s (held until then, not dropped -- see the
            # findings: dropped, a docking's small pulses went unmodelled)
            if np.linalg.norm(self.dv_pend) > DV_THRESH_MPS:
                self.dv_acc += self.dv_pend
                self.dv_pend = np.zeros(3)
        self.last_v = (t, dv, dg)
        self.s_used = s
        if self.next_tcs is None or t >= self.next_tcs or t < self.next_tcs - 2 * self.tcs_period:
            self.next_tcs = t + self.tcs_period
            self._mark(t, s, tgt)

    def geometry(self, s, tgt):
        L = lvlh(tgt["r"], tgt["v"])
        C = ri.qmat(s["q"])
        A = L.T @ np.array(C)                                  # body -> LVLH
        arm = (np.array(ri.TCS_BODY) - np.array(s["cg"])) / FT
        n = ri.orbital_rate(tgt["r"], tgt["v"])
        w_lvlh_body = A @ np.array(s["w"])                     # body rate, in LVLH axes
        wrel = w_lvlh_body - np.array([0.0, -n, 0.0])           # less LVLH's own turn
        # The reflector, PMA-2's face, where rndz_instruments puts it: the
        # target's own attitude (the crew's "Update target attitude", RNDZ
        # 7-17), moving with the target's LVLH (instruments.points).
        refl = L.T @ (np.array(ri.qmat(tgt["q"])) @ np.array(ri.PMA2)) / FT
        return {"A": A, "arm": arm, "wrel": wrel, "L": L, "n": n, "refl": refl,
                "dock": s.get("dock", 0)}

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
        dv_use = geo["L"].T @ self.dv_acc / FT
        self.dv_acc = np.zeros(3)
        if "tcs_range_ft" in rd:
            azi, elv = (math.radians(a) for a in rd["tcs_bearing_deg"])
            z = np.array([rd["tcs_range_ft"], rd["tcs_rdot_fps"], elv, azi])
            if self.raw_tcs is None:
                log("TCS: track at %.0f ft" % z[0])
            self.raw_tcs = (t, z[0], z[1], math.degrees(elv), math.degrees(azi))
            if self.tcs_mode == "nav":
                self.nav.update(t, z, geo, geo["n"], dv_use)
            elif self.tcs_mode == "auto":
                # TCS Auto: the mark itself, its position as TCS NAV would
                # start from it; the velocity from this mark and the last
                tmp = TcsNav()
                tmp.init_from(z, geo, quiet=True)
                x = tmp.x
                if self.auto is not None and 0.0 < t - self.auto[0] < 10.0:
                    x[3:] = (x[:3] - self.auto[1][:3]) / (t - self.auto[0])
                self.auto = (t, x)
        elif self.nav.x is not None and self.tcs_mode == "nav":
            self.nav.propagate(t, geo["n"], dv_use)
        x = self.prime_x()
        if x is not None:
            if not self.hist or t - self.hist[-1][0] >= 1.0:
                self.hist.append((t, x[:3].copy(), dp_of(x, geo, s["cg"])[0]))
                del self.hist[:-20000]
            if int(t) % 30 == 0:
                tr, _ = self.rel_truth(s, tgt, geo)
                log("t %.0f nav %.1f %.1f %.1f ft, truth %.1f %.1f %.1f ft"
                    % (t, x[0], x[1], x[2], tr[0], tr[1], tr[2]))
        # the HHL as rndz_instruments reads it: the STS-134 cue cards' ranges,
        # none inside 12 ft (RNDZ 7-21, note 9)
        if "hhl_range_ft" in rd and (self.next_hhl is None or t >= self.next_hhl):
            self.next_hhl = t + HHL_PERIOD_S
            self._hhl_mark(t, rd["hhl_range_ft"], rd["hhl_rdot_fps"])

    def prime_x(self):
        """The prime trajectory's state (CG, target LVLH ft, ft/s): TCS NAV's
        or TCS Auto's, or None."""
        if self.tcs_mode == "nav":
            return self.nav.x
        if self.tcs_mode == "auto" and self.auto is not None:
            return self.auto[1]
        return None

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
        self.imu_acc = np.zeros(3)
        self.dv_pend = np.zeros(3)
        self.auto = None
        self.pending = []
        self.tgts = []
        self.geo = None


# ---------------------------------------------------------------------------
# The display.

def nice_step(span):
    """50, 100, 500, 1000 ... ft ticks: about four across the span."""
    for s in (5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000):
        if span / s <= 10:
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
        self.zoom = [1.0, 1.0, 1.0]     # per LVLH axis (RNDZ 7-25: Ctrl+X/Y/Z with PgUp/PgDn)
        self.pan = [0.0, 0.0]
        self.auto = True                # autoscaling, until a manual zoom (RNDZ 7-25)
        self.auto_i = AUTO_STEPS.index(50)
        self.auto_pick = True           # choose at once (start, Ctrl+Home, a new view)
        self.auto_since = None          # data time the next step in has fitted since
        self.held = set()               # X, Y, Z held with Ctrl, for those
        self.orb_centered = False       # F8, Tgt/Orb (RNDZ 7-23)
        self.overlay = True             # Shift+F7, Ovrlay
        self.show_resids = True         # the TCS options' "Display Resids and Ratios" (7-27)
        self.whatif = np.zeros(3)       # THC "What if" delta-V, LVLH ft/s (7-25)
        self.whatif_dap = "prox"        # RPOP Configuration's THC "What if"... (7-24)
        self.whatif_user = (0.10, 0.05)
        self.n_pred, self.dt_pred = 9, 60.0   # Predictors... (7-24); [JSC]'s 1-9, a minute apart
        fams = set(QtGui.QFontDatabase.families())
        fam = next((f for f in ("Courier New", "Menlo", "DejaVu Sans Mono", "Courier") if f in fams),
                   "Monospace")
        self.fam = fam
        self.met_zero = parse_dhms(args.met_zero)
        self.setFocusPolicy(QtCore.Qt.FocusPolicy.StrongFocus)
        t = QtCore.QTimer(self)
        t.timeout.connect(self.tick)
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
        x = self.rp.prime_x()
        return x is not None and np.linalg.norm(x[:3]) < 400.0     # the APPROACH card's switch

    def state_shown(self):
        """(pos, vel) of the point of reference, LVLH ft, ft/s; and the CG."""
        x = self.rp.prime_x()
        if x is None or getattr(self.rp, "geo", None) is None:
            return None
        cg = x[:3].copy()
        if not self.por_dp():
            return x[:3], x[3:], cg
        p, v = dp_of(x, self.rp.geo, self.rp.tru["cg"])
        return p, v, cg

    # --- keys -------------------------------------------------------------
    # --- actions: the documented functions (RNDZ 7-22..7-27), from keys and menus
    def act_exit(self):
        QtWidgets.QApplication.quit()

    def act_rdot(self):
        self.show_rdot = not self.show_rdot

    def act_view(self, which=None):
        self.view = (self.view + 1) % len(self.VIEWS) if which is None else which
        self.auto_pick = True

    def act_overlay(self):
        self.overlay = not self.overlay

    def act_tgt_orb(self):
        self.orb_centered = not self.orb_centered
        self.auto_pick = True

    def act_por(self):
        self.por = "cg" if self.por_dp() else "dp"

    def act_thc_clear(self):
        self.whatif = np.zeros(3)

    def act_traj_clear(self):
        self.rp.hist = self.rp.hist[-2:]

    def act_back1(self):
        self.rp.hist = self.rp.hist[:-1]

    def act_fkeys(self):
        self.fkeys = not self.fkeys

    def act_zoom(self, f, axes=(0, 1, 2)):
        if self.auto:
            log("autoscale off (manual zoom)")
        self.auto = False                  # a manual scale holds until Ctrl+Home
        for a in axes:
            self.zoom[a] *= f

    def act_reset_scale(self):
        """RNDZ 7-25: Ctrl+Home, "Resume autoscaling and reset scale"."""
        self.zoom, self.pan = [1.0, 1.0, 1.0], [0.0, 0.0]
        self.auto, self.auto_pick, self.auto_since = True, True, None

    # --- autoscaling ---------------------------------------------------------
    def tick(self):
        try:
            self.autoscale()
        except Exception as e:             # never let the scale stop the display
            log("autoscale: %s" % e)
        self.update()

    def frame(self, H, st):
        """The plot's fixed frame: the screen point of the view's centre
        (the target, or the orbiter's POR when orbiter-centred) and that centre."""
        (ih, _), _ = self.axes_of()
        centre = st[0] if (self.orb_centered and st is not None) else np.zeros(3)
        ox = (DESIGN_W * (0.5 if (ih != 0 or self.orb_centered) else ORIGIN_X)) + self.pan[0]
        oy = (H - 20) * ORIGIN_Y + self.pan[1]
        return ox, oy, centre

    def autoscale(self):
        if not self.auto or not self.rp.pcm_ok():
            return
        st = self.state_shown()
        if st is None:
            return
        H = DESIGN_H - 40
        (ih, sh), (iv, sv) = self.axes_of()
        ox, oy, centre = self.frame(H, st)
        now = self.rp.tru["t"]
        dp = self.por_dp()
        pts = [st[0]] + [h[2] if dp else h[1] for h in self.rp.hist if h[0] >= now - AUTO_TRAIL_S]
        if self.orb_centered:
            pts.append(np.zeros(3))        # the target, which moves in this view
        # the plot clear of its edges and the header (x 30..994, y 60..H-50)
        x0, x1, y0, y1 = 30.0, DESIGN_W - 30.0, 60.0, H - 50.0

        def fits(i, frac):
            k = PX_PER_FT * 50.0 / AUTO_STEPS[i]
            for q in pts:
                x = (q[ih] - centre[ih]) * sh * k
                y = (q[iv] - centre[iv]) * sv * k
                if not (frac * (x0 - ox) <= x <= frac * (x1 - ox) and frac * (y0 - oy) <= y <= frac * (y1 - oy)):
                    return False
            return True

        def best():
            for i in range(len(AUTO_STEPS)):
                if fits(i, AUTO_COMFORT):
                    return i
            return len(AUTO_STEPS) - 1

        i = self.auto_i
        why = None
        if self.auto_pick:
            self.auto_pick = False
            i, why = best(), "reset"
        elif not fits(i, 1.0):
            i, why = max(best(), i + 1), "out"
            self.auto_since = None
        elif i > 0 and fits(i - 1, AUTO_COMFORT):
            if self.auto_since is None:
                self.auto_since = now
            elif now - self.auto_since >= AUTO_DWELL_S:
                i, why = i - 1, "in"
                self.auto_since = None
        else:
            self.auto_since = None
        if why is not None and i != self.auto_i:
            r = float(np.linalg.norm(st[0]))
            log("autoscale %s: %d -> %d ft step, range %.1f ft (%s), MET %s"
                % (why, AUTO_STEPS[self.auto_i], AUTO_STEPS[i], r, "DP-DP" if dp else "CG-CG",
                   fmt_met(self.rp.tru["gmt"] - self.met_zero)))
            self.auto_i = i

    def act_move(self, dx, dy):
        self.pan[0] += dx
        self.pan[1] += dy

    def pulse_size(self, big):
        """The THC "What if" pulse, ft/s: DAP A8 (Shift) or B8 (RNDZ 7-25),
        or the DAP chosen in RPOP Configuration (7-24); TRANS PLS from the
        ISS RNDZ OPS DAP CONFIGURATIONS (6-2): A7 0.10 B7 0.05, A8 0.10 B8 0.05."""
        if self.whatif_dap == "user":
            return self.whatif_user[0 if big else 1]
        return 0.10 if big else 0.05

    def act_whatif(self, body_axis, sign, big):
        """A THC pulse "what if", -Z sense: Z IN / Z OUT along body -Z / +Z,
        X UP / X DOWN along body +X / -X; the prime trajectory's predictors
        take it (RNDZ 7-23, 7-25)."""
        if self.rp.geo is None:
            return
        d = np.zeros(3)
        d[body_axis] = sign * self.pulse_size(big)
        self.whatif = self.whatif + self.rp.geo["A"] @ d

    def act_tcs_mode(self, mode):
        rp = self.rp
        if mode != rp.tcs_mode:
            rp.tcs_mode = mode
            rp.auto = None
            rp.hist = []
            if mode == "nav":
                rp.nav.reset()          # TCS NAV starts again from the next mark

    def act_reinit(self):
        self.rp.nav.reset()             # "Re-Initialize on [OK]" (RNDZ 7-27)

    # --- keys ---------------------------------------------------------------
    def keyReleaseEvent(self, ev):
        self.held.discard(ev.key())
        super().keyReleaseEvent(ev)

    def keyPressEvent(self, ev):
        k, m = ev.key(), ev.modifiers()
        K, M = QtCore.Qt.Key, QtCore.Qt.KeyboardModifier
        ctrl, shift = bool(m & M.ControlModifier), bool(m & M.ShiftModifier)
        if sys.platform == "darwin":       # Qt swaps them there; the PGSC's Ctrl is the Ctrl key
            ctrl = bool(m & M.MetaModifier) or ctrl
        if k in (K.Key_X, K.Key_Y, K.Key_Z):
            self.held.add(k)
            return
        axes = tuple(a for a, key in enumerate((K.Key_X, K.Key_Y, K.Key_Z)) if key in self.held) or (0, 1, 2)
        if k == K.Key_F10 and shift:
            self.act_exit()
        elif k == K.Key_F10 and ctrl:
            self.window().act_config()
        elif k == K.Key_F5 and not (ctrl or shift):
            self.act_rdot()
        elif k == K.Key_F7 and shift:
            self.act_overlay()
        elif k == K.Key_F7 and not ctrl:
            self.act_view()
        elif k == K.Key_F8 and ctrl:
            self.act_por()
        elif k == K.Key_F8 and not shift:
            self.act_tgt_orb()
        elif k == K.Key_F9 and shift:
            self.act_traj_clear()
        elif k == K.Key_F9 and ctrl:
            self.act_back1()
        elif k == K.Key_F9:
            self.act_thc_clear()
        elif k == K.Key_Space:
            self.act_fkeys()
        elif ctrl and k == K.Key_PageUp:
            self.act_zoom(1.05 if shift else 1.25, axes)
        elif ctrl and k == K.Key_PageDown:
            self.act_zoom(1 / (1.05 if shift else 1.25), axes)
        elif ctrl and k == K.Key_Home:
            self.act_reset_scale()
        elif ctrl and k in (K.Key_Left, K.Key_Right, K.Key_Up, K.Key_Down):
            st = 5.0 if shift else 25.0
            self.act_move(*{K.Key_Left: (-st, 0), K.Key_Right: (st, 0),
                            K.Key_Up: (0, -st), K.Key_Down: (0, st)}[k])
        elif k in (K.Key_Right, K.Key_Left, K.Key_Up, K.Key_Down):
            # THC "What if", -Z sense (RNDZ 7-25): -> Z IN, <- Z OUT, up X UP,
            # down X DOWN; Shift DAP A8, plain DAP B8
            ax, sg = {K.Key_Right: (2, -1), K.Key_Left: (2, 1), K.Key_Up: (0, 1), K.Key_Down: (0, -1)}[k]
            self.act_whatif(ax, sg, shift)
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
        self.text(p, 358, 34, "%.0f" % r, 28, GREEN, bold=True, align="r")
        self.text(p, 404, 34, "R", 28, GREEN, bold=True)
        self.dot(p, 413, 8, GREEN, 2.5)
        self.text(p, 545, 34, ("%.2f" if abs(rdot) < 10 else "%.1f") % rdot, 28, GREEN, bold=True,
                  align="r")
        for i, (nm, y) in enumerate((("X", 72), ("Y", 98), ("Z", 124))):
            self.text(p, 264, y, nm, 19, GREEN)
            self.text(p, 358, y, "%.0f" % pos[i] if abs(pos[i]) >= 0.5 or pos[i] >= 0 else "-0",
                      19, GREEN, align="r")
            self.text(p, 407, y, nm, 19, GREEN)
            self.dot(p, 413, y - 17, GREEN, 1.8)
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
        if nav.x is None or self.rp.tcs_mode != "nav" or not self.show_resids:
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
        lab = {"nav": "TCS NAV", "auto": "TCS Auto", "none": "TCS"}[self.rp.tcs_mode]
        if self.rp.tcs_mode != "none":            # the prime trajectory's key, lit
            p.fillRect(r, GREEN)
            self.text(p, 290, y, lab, 12, QtGui.QColor(0, 0, 0), align="c")
        else:
            self.text(p, 290, y, lab, 12, GREY_TXT, align="c")
        self.text(p, 576, y, "PCM", 12, GREY_TXT, align="c")

    def draw_rdot(self, p):
        """The Rdot window: a Windows dialog over the plot ([GNC], [RNDZ] 7-16)."""
        rp = self.rp
        x0, y0, w, h = 732, 556, 288, 124       # lower right, clear of the docking
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
        pts = [h[2] if dp else h[1] for h in hist]
        preds = []
        x0 = rp.prime_x()
        if x0 is not None:
            s = x0.copy()
            s[3:] += self.whatif            # THC "What if" inputs, on the prime trajectory only
            n = rp.geo["n"]
            for k in range(self.n_pred):
                s = cw_step(s, n, self.dt_pred)
                preds.append(s[:3] + off)
        # A FIXED FRAME, as JSC-63400 Fig 20.4: the target's point at a fixed
        # place on the screen (the figure's, 91 % across and 43 % down the
        # plot), never moved but by Ctrl+arrows (move the axes, RNDZ 7-25).
        # The scale steps with autoscaling until Ctrl+PgUp/PgDn sets it by
        # hand; Ctrl+Home resets it and resumes autoscaling (7-25).  The YZ
        # view, seen along the V-bar, has the target in the middle.
        # Autoscaling (see autoscale) changes only the scale, in steps.
        k0 = PX_PER_FT * 50.0 / AUTO_STEPS[self.auto_i]
        kh, kv = k0 * self.zoom[ih], k0 * self.zoom[iv]
        k = kh
        # F8: target-centred (the target fixed, at [JSC]'s place) or
        # orbiter-centred (the orbiter's point of reference fixed in the
        # middle, the target moving)
        ox, oy, centre = self.frame(H, st)
        right, left = DESIGN_W - 20.0, 20.0

        def to_px(q):
            return QtCore.QPointF(ox + (q[ih] - centre[ih]) * sh * kh, oy + (q[iv] - centre[iv]) * sv * kv)

        p.save()
        p.setClipRect(QtCore.QRectF(0, 0, DESIGN_W, H - 20))
        # axes through the target, with ticks
        pen = QtGui.QPen(GREY_TXT, 1)
        p.setPen(pen)
        o = to_px(np.zeros(3))                  # the axes through the target
        ax_x, ax_y = o.x(), o.y()
        p.drawLine(QtCore.QPointF(0, ax_y), QtCore.QPointF(DESIGN_W, ax_y))
        p.drawLine(QtCore.QPointF(ax_x, 0), QtCore.QPointF(ax_x, H))
        step_h = nice_step((right - left) / kh)
        step_v = nice_step((right - left) / kv)
        tick = 7
        for i in range(-60, 61):
            if i == 0:
                continue
            x = ax_x + i * step_h * kh
            if -10 < x < DESIGN_W + 10:
                p.drawLine(QtCore.QPointF(x, ax_y - tick), QtCore.QPointF(x, ax_y + tick))
            y = ax_y + i * step_v * kv
            if -10 < y < H + 10:
                p.drawLine(QtCore.QPointF(ax_x - tick, y), QtCore.QPointF(ax_x + tick, y))
        self.text(p, ax_x - step_h * kh, ax_y - 10, "%d" % step_h, 13, GREY_TXT, align="c")
        self.text(p, ax_x - 12, ax_y + step_v * kv + 5, "%d" % step_v, 13, GREY_TXT, align="r")
        refl = rp.geo["refl"] if rp.geo is not None else ri_pma2_ft()
        if self.overlay:
            self.draw_overlay(p, to_px, ih, iv, np.zeros(3) if dp else refl)
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
        g = self.rp.geo
        face = np.zeros(3) if dp else (g["refl"] if g is not None else ri_pma2_ft())
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
        shift = -self.rp.geo["refl"] if self.por_dp() else np.zeros(3)
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
    """RPOP's window: the trajectory display under the menu bar of [GNC]'s
    screen capture (File Edit Control Views Display Sensors Help).

    WHAT IS IN THE MENUS.  No source shows the menus opened, so their
    contents are the checklist's documented functions (RNDZ 7-15..7-27),
    each with its key beside it, filed under the menu whose name fits --
    the filing is ours.  A function the checklist names but does not
    describe well enough to build (or that needs a sensor this simulator does
    not give RPOP) is there, greyed: Guidance, PCMMU mode, the attitude and
    subtended-angle inputs, Low Z, Declutter, the Range Ruler, Help, and the
    SV, RR, HHL and CCTV trajectory sources."""

    def __init__(self, rpop, args):
        super().__init__()
        self.setWindowTitle("RPOP")
        self.rp = rpop
        self.view = View(rpop, args)
        self.setCentralWidget(self.view)
        mb = self.menuBar()
        mb.setNativeMenuBar(False)                # in the window, as on the PGSC
        v = self.view

        def item(menu, text, key, fn=None, check=None):
            a = menu.addAction("%s\t%s" % (text, key) if key else text)
            if fn is None:
                a.setEnabled(False)
            else:
                if check is not None:
                    a.setCheckable(True)
                    a.setChecked(bool(check()))
                    menu.aboutToShow.connect(lambda a=a, c=check: a.setChecked(bool(c())))
                a.triggered.connect(lambda _x=False, f=fn: (f(), v.update()))
            return a

        m = mb.addMenu("File")
        item(m, "Exit (save output files)", "Shift+F10", v.act_exit)
        m = mb.addMenu("Edit")
        item(m, "THC Clear (\"What if\" inputs)", "F9", v.act_thc_clear)
        item(m, "Trajectory Clear", "Shift+F9", v.act_traj_clear)
        item(m, "Back 1", "Ctrl+F9", v.act_back1)
        m = mb.addMenu("Control")
        item(m, "Guidance...", "Ctrl+F5")
        item(m, "Orbiter Attitude...", "Shift+F5")
        item(m, "Target Attitude...", "Shift+F6")
        item(m, "PCMMU Mode (PCM / No PCM)", "Ctrl+F6")
        item(m, "Low Z (THC \"What if\")", "Shift+F8")
        m.addSeparator()
        sub = m.addMenu("THC \"What if\" pulse")
        item(sub, "Z IN, DAP B8 (A8)", "Right (Shift+Right)", lambda: v.act_whatif(2, -1, False))
        item(sub, "Z OUT, DAP B8 (A8)", "Left (Shift+Left)", lambda: v.act_whatif(2, 1, False))
        item(sub, "X UP, DAP B8 (A8)", "Up (Shift+Up)", lambda: v.act_whatif(0, 1, False))
        item(sub, "X DOWN, DAP B8 (A8)", "Down (Shift+Down)", lambda: v.act_whatif(0, -1, False))
        m.addSeparator()
        item(m, "RPOP Configuration...", "Ctrl+F10", self.act_config)
        m = mb.addMenu("Views")
        for i, name in enumerate(View.VIEWS):
            item(m, "View %s" % name, "F7" if i == 0 else "", lambda i=i: v.act_view(i),
                 check=lambda i=i: v.view == i)
        item(m, "Orbiter-Centered LVLH", "F8", v.act_tgt_orb, check=lambda: v.orb_centered)
        m.addSeparator()
        item(m, "Zoom In", "Ctrl+PgUp", lambda: v.act_zoom(1.25))
        item(m, "Zoom Out", "Ctrl+PgDn", lambda: v.act_zoom(1 / 1.25))
        for a, nm in enumerate("XYZ"):
            item(m, "Zoom In %s Axis" % nm, "Ctrl+%s+PgUp" % nm, lambda a=a: v.act_zoom(1.25, (a,)))
            item(m, "Zoom Out %s Axis" % nm, "Ctrl+%s+PgDn" % nm, lambda a=a: v.act_zoom(1 / 1.25, (a,)))
        item(m, "Resume Autoscaling and Reset Scale", "Ctrl+Home", v.act_reset_scale)
        m = mb.addMenu("Display")
        item(m, "Rdot Window", "F5", v.act_rdot, check=lambda: v.show_rdot)
        item(m, "Overlay", "Shift+F7", v.act_overlay, check=lambda: v.overlay)
        item(m, "Point of Reference (CG-CG / DP-DP)", "Ctrl+F8", v.act_por, check=lambda: v.por_dp())
        item(m, "Function Key Menu", "Space", v.act_fkeys, check=lambda: v.fkeys)
        m.addSeparator()
        item(m, "Subtended Angle...", "F6")
        item(m, "Declutter", "F11")
        item(m, "Range Ruler Snap", "F12")
        item(m, "Range Ruler Clear", "Shift+F12")
        m = mb.addMenu("Sensors")
        for nm in ("SV (State Vector)", "RR (Rendezvous Radar)", "HHL (Hand-Held Laser)", "CCTV"):
            item(m, nm, "")
        tcs = m.addMenu("TCS (Trajectory Control Sensor)")
        item(tcs, "Nav (Kalman Filtering)", "", lambda: v.act_tcs_mode("nav"),
             check=lambda: self.rp.tcs_mode == "nav")
        item(tcs, "Auto", "", lambda: v.act_tcs_mode("auto"), check=lambda: self.rp.tcs_mode == "auto")
        item(tcs, "Manual", "")
        item(tcs, "None", "", lambda: v.act_tcs_mode("none"), check=lambda: self.rp.tcs_mode == "none")
        tcs.addSeparator()
        item(tcs, "Display Resids and Ratios", "", lambda: setattr(v, "show_resids", not v.show_resids),
             check=lambda: v.show_resids)
        item(tcs, "Force Measurements", "", lambda: setattr(self.rp.nav, "force", not self.rp.nav.force),
             check=lambda: self.rp.nav.force)
        item(tcs, "Re-Initialize", "", v.act_reinit)
        m = mb.addMenu("Help")
        item(m, "Help", "F10")
        h = args.size
        self.resize(int(round(h * DESIGN_W / DESIGN_H)), h)
        self.view.setFocus()

    def act_config(self):
        """RPOP Configuration (Ctrl+F10, RNDZ 7-24): the options built here
        are Data Freq, Predictors, Update MET and THC "What if"; Debug, Altitude,
        Comm Ports, TCS/Refl and Views are shown, greyed."""
        v, rp = self.view, self.rp
        d = QtWidgets.QDialog(self)
        d.setWindowTitle("RPOP Configuration")
        f = QtWidgets.QFormLayout(d)
        freq = QtWidgets.QDoubleSpinBox(); freq.setRange(0.5, 60.0); freq.setDecimals(1)
        freq.setSuffix(" s"); freq.setValue(rp.tcs_period)
        f.addRow("Data Freq... (TCS)", freq)
        npred = QtWidgets.QSpinBox(); npred.setRange(0, 20); npred.setValue(v.n_pred)
        dpred = QtWidgets.QDoubleSpinBox(); dpred.setRange(5.0, 600.0); dpred.setDecimals(0)
        dpred.setSuffix(" s"); dpred.setValue(v.dt_pred)
        f.addRow("Predictors... number", npred)
        f.addRow("Predictors... time increment", dpred)
        met = QtWidgets.QLineEdit()
        met.setPlaceholderText("DDD/HH:MM:SS (blank: unchanged)")
        f.addRow("Update MET...", met)
        dap = QtWidgets.QComboBox()
        dap.addItems(["Rndz DAP (A7/B7: 0.10/0.05)", "Prox Ops DAP (A8/B8: 0.10/0.05)",
                      "User-Configurable DAP"])
        dap.setCurrentIndex({"rndz": 0, "prox": 1, "user": 2}[v.whatif_dap])
        ua = QtWidgets.QDoubleSpinBox(); ua.setRange(0.0, 1.0); ua.setDecimals(3); ua.setValue(v.whatif_user[0])
        ub = QtWidgets.QDoubleSpinBox(); ub.setRange(0.0, 1.0); ub.setDecimals(3); ub.setValue(v.whatif_user[1])
        f.addRow("THC \"What if\"... DAP", dap)
        f.addRow("  user pulse, Shift (A) ft/s", ua)
        f.addRow("  user pulse (B) ft/s", ub)
        for nm in ("Debug", "Altitude...", "Comm Ports...", "TCS/Refl...", "Views..."):
            b = QtWidgets.QPushButton(nm); b.setEnabled(False)
            f.addRow(b)
        bb = QtWidgets.QDialogButtonBox(QtWidgets.QDialogButtonBox.StandardButton.Ok
                                        | QtWidgets.QDialogButtonBox.StandardButton.Cancel)
        bb.accepted.connect(d.accept)
        bb.rejected.connect(d.reject)
        f.addRow(bb)
        if d.exec() != QtWidgets.QDialog.DialogCode.Accepted:
            return
        rp.tcs_period = freq.value()
        v.n_pred, v.dt_pred = npred.value(), dpred.value()
        v.whatif_dap = ("rndz", "prox", "user")[dap.currentIndex()]
        v.whatif_user = (ua.value(), ub.value())
        txt = met.text().strip()
        if txt and rp.tru is not None:
            try:
                v.met_zero = rp.tru["gmt"] - parse_dhms(txt)
            except (ValueError, IndexError):
                log("Update MET: not DDD/HH:MM:SS: %r" % txt)
        v.update()


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
        # QPixmap.save fails silently on a missing directory or an unknown
        # suffix: make the directory, default to PNG, and say if it failed
        path = os.path.abspath(os.path.expanduser(args.snapshot))

        def snap():
            try:
                os.makedirs(os.path.dirname(path), exist_ok=True)
            except OSError as e:
                log("snapshot: %s" % e)
            ext = os.path.splitext(path)[1][1:].upper()
            fmt = ext if ext.encode() in [bytes(f).upper() for f in QtGui.QImageWriter.supportedImageFormats()] \
                else "PNG"
            if w.grab().save(path, fmt) and os.path.isfile(path) and os.path.getsize(path) > 0:
                log("snapshot %s" % path)
            else:
                log("snapshot FAILED: could not write %s" % path)
            app.quit()
        QtCore.QTimer.singleShot(int(args.snapshot_after * 1000), snap)
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
