#!/usr/bin/env python3
"""Ground solutions for STS-134's FD15 separation and STORRM re-rendezvous (Clohessy-Wiltshire).

MCC's SEP2, NH2, MC5 and the targeting behind NSR and TPI are not in the record this
project has; what is, is the timeline (Mission Report FD15 and the STS-134 Rendezvous book,
"STORRM DTO RE-RENDEZVOUS", pp. 1-10 and 1-11):

    undock 03:55, fly-around +X pulse 04:20:00, SEP1 05:06:02 (1.5 ft/s), SEP2 05:34:06 (1.5),
    NH2 06:39:38 (2.0), MC5 06:59:08 (planned 0.0), NSR 07:24:08 (2.4), TPI 07:57:34 (3.4) at
    ~6,860 ft CG-CG, targeted for TDA, 1,000 ft below and 333 ft behind the ISS, 08:24:25,
    SEP3 08:38:36 (1.0 ft/s retrograde, 15 min after TDA).

The geometry follows from these.  The fly-around (an up-radial pulse from +V-bar at 650 ft) is
a half-orbit centred ellipse (2:1, 325 ft by 650 ft), 46 min -- exactly the 04:20 to 05:06 of
the record -- ending 650 ft behind the ISS on the -V-bar.  SEP1 (the jets' +X, L1A and R1A) is
a radial-up 1.5 ft/s.  NH2, half an orbit before NSR, is a horizontal-ish burn that puts the
Orbiter at an apsis for NSR; NSR is the coelliptic burn.  The jet lists the Mission Report
gives for SEP2 and NH2 point to the same burns this module finds (SEP2 toward the ISS, NH2
retrograde and up), which is the check on the sign conventions.

Frame: x ahead along the track, y to the right (out of plane), z toward the Earth (down); the
state is (x, y, z, xdot, ydot, zdot) in ft, ft/s, the rotating frame's rates (rndz_manual.rel).
    xddot = 2 n zdot,   yddot = -n^2 y,   zddot = 3 n^2 z - 2 n xdot.
"""
import math

import numpy as np

N_ISS = 1.146832e-3          # rad/s, 343 km (rndz_start: "orbital rate 1.146832e-03")


def _expm(M):
    s = max(0, int(math.ceil(math.log2(max(1e-9, np.linalg.norm(M, 1))))) + 1)
    M = M / 2.0 ** s
    E = np.eye(len(M))
    T = np.eye(len(M))
    for k in range(1, 20):
        T = T @ M / k
        E = E + T
    for _ in range(s):
        E = E @ E
    return E


def phi(t, n=N_ISS):
    """The state transition over t seconds."""
    A = np.zeros((6, 6))
    A[0, 3] = A[1, 4] = A[2, 5] = 1.0
    A[3, 5] = 2.0 * n
    A[4, 1] = -n * n
    A[5, 2] = 3.0 * n * n
    A[5, 3] = -2.0 * n
    return _expm(A * t)


def prop(s, t, n=N_ISS):
    return phi(t, n) @ np.asarray(s, float)


def kick(s, dv):
    s = np.array(s, float)
    s[3:] += np.asarray(dv, float)
    return s


def coelliptic_dv(s, n=N_ISS):
    """NSR: from the state s (at the burn), the horizontal burn that leaves the Orbiter coelliptic --
    no radial rate, the along-track rate 1.5 n z of a constant height difference z (below +) --
    and out-of-plane at rest.  Returns the ft/s in x, y, z."""
    return np.array([1.5 * n * s[2] - s[3], -s[4], -s[5]])


def transfer_dv(s, dt, target, n=N_ISS):
    """TPI: the burn from s that arrives at target (x, y, z) dt seconds later."""
    P = phi(dt, n)
    Prr, Prv = P[:3, :3], P[:3, 3:]
    v_need = np.linalg.solve(Prv, np.asarray(target, float) - Prr @ s[:3])
    return v_need - s[3:]


# The record's times, GMT seconds into day 150 (the vehicle's form: day*86400 + the day's)
def gmt(h, m, s):
    return 150 * 86400 + h * 3600 + m * 60 + s


T = dict(FA=gmt(4, 20, 0), SEP1=gmt(5, 6, 2), SEP2=gmt(5, 34, 6), NH2=gmt(6, 39, 38), MC5=gmt(6, 59, 8),
         NSR=gmt(7, 24, 8), TPI=gmt(7, 57, 34), TDA=gmt(8, 24, 25), SEP3=gmt(8, 38, 36))
TDA_POINT = (-333.0, 0.0, 1000.0)       # 1,000 ft below and 333 ft behind
PLAN = dict(SEP1=1.5, SEP2=1.5, NH2=2.0, MC5=0.0, NSR=2.4, TPI=3.4, SEP3=1.0)       # ft/s, the Rendezvous book
TPI_RANGE_FT = 6860.0


def flyaround_dv(x_ahead, n=N_ISS):
    """The fly-around's radial-up pulse from the +V-bar at x_ahead ft: a centred 2:1 ellipse, half
    of which is flown before SEP1.  zdot = -n x/2 (up)."""
    return np.array([0.0, 0.0, -0.5 * n * x_ahead])


def flyaround_dv_state(s, n=N_ISS):
    """The burn that makes the Orbiter's motion the centred 2:1 ellipse about the ISS, from any state s
    (x, y, z, rates): half an orbit on it must carry the position to its opposite (-x, -y, -z), which
    fixes the two velocity components that matter and puts the drift and the centre right."""
    P = phi(math.pi / n, n)
    r, v = np.asarray(s[:3], float), np.asarray(s[3:], float)
    ix = [0, 2]                      # x and z; y oscillates on its own (sin(pi) = 0: ydot cannot reach it), so ydot is just nulled
    need = np.linalg.solve(P[np.ix_(ix, [3, 5])], -r[ix] - P[np.ix_(ix, [0, 1, 2])] @ r)
    return np.array([need[0] - v[0], -v[1], need[1] - v[2]])


def sep2_nh2(s_sep2, mag2=PLAN["SEP2"], mag_nh=PLAN["NH2"], n=N_ISS):
    """The ground solutions for SEP2 and NH2, from the state just before SEP2: the in-plane
    directions (SEP2 near forward, NH2 near backward and up) for which NSR is 2.4 ft/s, TPI is
    3.4 ft/s and the range at TPI 6,860 ft.  Returns (dv_sep2, dv_nh2, report)."""
    best = None
    for a2 in np.radians(np.arange(-40.0, 61.0, 1.0)):
        s1 = kick(prop(kick(s_sep2, (mag2 * math.cos(a2), 0.0, mag2 * math.sin(a2))), T["NH2"] - T["SEP2"], n), (0, 0, 0))
        for a3 in np.radians(np.arange(-180.0, -119.0, 1.0)):
            dv3 = (mag_nh * math.cos(a3), 0.0, mag_nh * math.sin(a3))
            r = chain(kick(s1, dv3), T["NH2"], n)
            err = (((r["NSR"] - PLAN["NSR"]) / 0.1) ** 2 + ((r["TPI"] - PLAN["TPI"]) / 0.1) ** 2 +
                   ((r["range_tpi"] - TPI_RANGE_FT) / 300.0) ** 2)
            if best is None or err < best[0]:
                best = (err, a2, a3, r)
    err, a2, a3, r = best
    return ((mag2 * math.cos(a2), 0.0, mag2 * math.sin(a2)), (mag_nh * math.cos(a3), 0.0, mag_nh * math.sin(a3)),
            dict(a2=math.degrees(a2), a_nh=math.degrees(a3), err=err, **r))


def chain(s_after_nh2, t_nh2, n=N_ISS):
    """From the state just after NH2: NSR (coelliptic), TPI (to the TDA point), the ft/s and the range."""
    s = prop(s_after_nh2, T["NSR"] - t_nh2, n)
    dv_nsr = coelliptic_dv(s, n)
    s = prop(kick(s, dv_nsr), T["TPI"] - T["NSR"], n)
    dv_tpi = transfer_dv(s, T["TDA"] - T["TPI"], TDA_POINT, n)
    return dict(NSR=float(np.linalg.norm(dv_nsr)), TPI=float(np.linalg.norm(dv_tpi)),
                range_tpi=float(np.linalg.norm(s[:3])), x_tpi=float(s[0]), z_tpi=float(s[2]))


def nh2_dv(s, mag=PLAN["NH2"], n=N_ISS, t_now=None):
    """NH2, from the state s at its time (T['NH2'] unless t_now): the in-plane direction, retrograde and
    up as the jets' list has it, for which NSR is 2.4 and TPI 3.4 ft/s and the range at TPI 6,860 ft.
    Returns (dv, report)."""
    t_now = T["NH2"] if t_now is None else t_now
    best = None
    for a3 in np.radians(np.arange(-180.0, -100.0, 0.5)):
        dv = (mag * math.cos(a3), 0.0, mag * math.sin(a3))
        r = chain(kick(s, dv), t_now, n)
        err = (((r["NSR"] - PLAN["NSR"]) / 0.1) ** 2 + ((r["TPI"] - PLAN["TPI"]) / 0.1) ** 2 +
               ((r["range_tpi"] - TPI_RANGE_FT) / 300.0) ** 2)
        if best is None or err < best[0]:
            best = (err, dv, r, math.degrees(a3))
    err, dv, r, a3 = best
    z_nsr = float(prop(kick(s, dv), T["NSR"] - t_now, n)[2])
    return np.array(dv), dict(err=err, a_nh=a3, z_nsr=z_nsr, **r)


def mc5_dv(s, z_nsr, n=N_ISS):
    """MC5, from the state s at its time: the burn (x, z only) that leaves the Orbiter at the height
    z_nsr (ft below) with no radial rate when NSR comes -- the apsis NSR needs."""
    P = phi(T["NSR"] - T["MC5"], n)
    # [z, zdot] at NSR as linear in the (dvx, dvz) of the burn
    base = P @ np.asarray(s, float)
    cols = [P[:, 3], P[:, 5]]
    M = np.array([[cols[0][2], cols[1][2]], [cols[0][5], cols[1][5]]])
    rhs = np.array([z_nsr - base[2], 0.0 - base[5]])
    d = np.linalg.solve(M, rhs)
    return np.array([d[0], 0.0, d[1]])


def sep3_dv(mag=PLAN["SEP3"]):
    """SEP3: 1.0 ft/s retrograde (the book: 'AxA, NORMZ, RETROGRADE')."""
    return np.array([-mag, 0.0, 0.0])


if __name__ == "__main__":
    # the nominal chain, as a check
    s = np.array([650.0, 0.0, 0.0, 0.0, 0.0, 0.0])
    s = kick(s, flyaround_dv(650.0))
    s = prop(s, T["SEP1"] - T["FA"])
    print("at SEP1: x %.0f z %.0f" % (s[0], s[2]))
    s = kick(s, (0, 0, -PLAN["SEP1"]))
    s = prop(s, T["SEP2"] - T["SEP1"])
    print("at SEP2: x %.0f z %.0f" % (s[0], s[2]))
    d2, d3, rep = sep2_nh2(s)
    print("SEP2 %s NH2 %s" % (np.round(d2, 2), np.round(d3, 2)), rep)
