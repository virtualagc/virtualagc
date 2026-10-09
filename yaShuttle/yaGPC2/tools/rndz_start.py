#!/usr/bin/env python3
"""The Orbiter's starting state for a run that begins on STS-134's final
approach to the ISS, and an independent Lambert check of PASS's Ti burn.

    tools/rndz_start.py start [--targets FILE] [--ti WHEN] [--start WHEN]
                              [--ti-point DX,DY,DZ] [--rate XD,YD,ZD]
    tools/rndz_start.py lambert --orb GMT X Y Z VX VY VZ --tgt GMT X Y Z VX VY VZ
                                --tig GMT [--dt MIN] [--offset DX,DY,DZ]

START works back from the Ti point to the state at --start (default
06:30:00, Ti - 68 min, ten minutes before NCC) and prints it as
YAGPC_VEHDYN_START_REL (vehdyn.c) with that time, the target-centred
curvilinear LVLH
state of PASS's orbit targeting (GWJ_ORB_TGT_REL_COMP, GWJORB.hal): metres
and metres a second, X along the track (+ ahead), Y = -(orbit normal) (+ to
the right), Z down.

  * THE TI POINT is where NCC aims (JSC-48072-134 Rendezvous checklist Rev A,
    TARGET NCC BURN [11A], TGT 9): 48.6 kft behind the ISS and 1.2 kft below
    it, at Ti TIG -- 07:38:00 UTC on 2011-05-18 as flown (collectSPACE FD3
    journal; NASA status reports).
  * HOW IT GETS THERE is the checklist's ORBT RENDEZVOUS PROFILE (p. 1-5):
    the NC burn at PET -1:32, 246 kft behind and about 1.2 kft below, starts
    a loop one revolution long that dips some 40 kft under the station and
    comes up to the Ti point; NCC (PET -0:58) only trims it.  The Orbiter is
    put on that nominal transfer: a precision Lambert arc from the NC point
    at Ti - 92 min to the Ti point at Ti TIG (--nc-point, --nc-before).  It
    arrives with the station drawing away from it, XD about -9 ft/s, and
    Ti's posigrade burn -- about 9 ft/s here against STS-134's 8.4 -- starts
    the second, smaller loop to MC4.  A co-elliptic arrival (the Orbiter
    on a circle 1.2 kft below, XD = 1.5 n DZ: --rate coelliptic) is NOT this
    profile: it makes Ti a 2.7 ft/s retrograde burn.
  * THE ARC is flown numerically in the J2-J4 zonal field, as vehdyn flies
    both vehicles in a 4x4 one of which the zonals are nearly all; the
    Clohessy-Wiltshire and two-body equivalents are shown beside it as
    checks.  Drag is not modelled here; differential drag over the hour
    moves the arrival by tens to a couple of hundred feet, which NCC (or
    Ti's own targeting, when NCC is not flown) absorbs.

The target is the ISS line of --targets (default
~/sts134-runs/rendezvous/sts134-targets.txt, tools/tle_target.py's state at
docking), carried back by the same J2-J4 propagation; its J2000 state
becomes M50 by the matrix vehdyn.c uses.

LAMBERT is the acceptance check of SPEC 34's COMPUTE T1 for TGT 10 (the Ti
burn: TARGET Ti BURN [13A]/[15A], T1 TIG = BASE TIME, DT 76.9 min, DX -0.9,
DY 0, DZ +1.8 kft, EL 0).  From the Orbiter's and the target's M50 states
(feet, feet a second, at their PASS GMTs -- TRU1/TGT1 truth, or PASS's own
from the downlist), carried to TIG and the target to TIG + DT in the J2-J4
field, the aim point is the T2 offset turned to M50 as GWJ does (INER_TO_LVC
off), and the burn is solved twice: a conic Lambert, and a precision one --
the aim point moved by the miss of a J2-J4 propagation of the conic answer
until it closes, as PASS's precision velocity-required task does (GWWORB).
The delta-V is shown in the Orbiter's LVLH at TIG (GWRORB.hal step 350:
rows unit(r x (v x r)), unit(v x r), -unit(r)), which is what SPEC 34 shows
as DVX DVY DVZ.
"""
import argparse
import calendar
import datetime
import math
import os
import sys

MU = 3.986004418e14          # m^3/s^2 (physics.c PHYS_MU_EARTH)
RE = 6378136.3               # m, EGM96 reference radius (physics.c)
J2, J3, J4 = 1.08263e-3, -2.5327e-6, -1.6196e-6
FT = 0.3048
J2000_TO_M50 = [[0.9999256782, 0.0111820610, 0.0048579479],
                [-0.0111820611, 0.9999374784, -0.0000271474],
                [-0.0048579477, -0.0000271765, 0.9999881997]]
# The Earth's pole in M50: J2000's (to 0.06 deg -- eleven years of
# precession -- which moves nothing here that matters).
POLE = [J2000_TO_M50[0][2], J2000_TO_M50[1][2], J2000_TO_M50[2][2]]


# --- vectors ------------------------------------------------------------
def dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
def cross(a, b): return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]
def norm(a): return math.sqrt(dot(a, a))
def add(a, b): return [a[i] + b[i] for i in range(3)]
def sub(a, b): return [a[i] - b[i] for i in range(3)]
def mul(k, a): return [k * x for x in a]
def unit(a): return mul(1.0 / norm(a), a)
def matvec(M, v): return [dot(M[i], v) for i in range(3)]


# --- gravity and propagation ----------------------------------------------
def accel(r, zonal=True):
    rn = norm(r)
    a = mul(-MU / rn ** 3, r)
    if not zonal:
        return a
    # zonal harmonics J2-J4 about POLE (Vallado 8-30 form, in a frame whose
    # z is the pole: the components along and across the pole)
    s = dot(r, POLE) / rn                   # sin(latitude)
    k = MU / rn ** 2
    q = RE / rn
    # radial and polar parts of -grad of U = -mu/r sum Jn (R/r)^n Pn(s)
    # with dP: Pn'(s).  a = sum over n of k Jn q^n [ (n+1) Pn r_hat - Pn' (pole - s r_hat) ]
    P = {2: 0.5 * (3 * s * s - 1), 3: 0.5 * (5 * s ** 3 - 3 * s), 4: (35 * s ** 4 - 30 * s * s + 3) / 8.0}
    dP = {2: 3 * s, 3: 0.5 * (15 * s * s - 3), 4: (140 * s ** 3 - 60 * s) / 8.0}
    rh = mul(1.0 / rn, r)
    for n, J in ((2, J2), (3, J3), (4, J4)):
        f = k * J * q ** n
        for i in range(3):
            a[i] += f * ((n + 1) * P[n] * rh[i] - dP[n] * (POLE[i] - s * rh[i]))
    return a


def propagate(r, v, dt, zonal=True, step=10.0):
    """RK4, either direction."""
    r, v = list(r), list(v)
    if dt == 0:
        return r, v
    n = max(1, int(math.ceil(abs(dt) / step)))
    h = dt / n
    for _ in range(n):
        k1r, k1v = v, accel(r, zonal)
        r2, v2 = add(r, mul(h / 2, k1r)), add(v, mul(h / 2, k1v))
        k2r, k2v = v2, accel(r2, zonal)
        r3, v3 = add(r, mul(h / 2, k2r)), add(v, mul(h / 2, k2v))
        k3r, k3v = v3, accel(r3, zonal)
        r4, v4 = add(r, mul(h, k3r)), add(v, mul(h, k3v))
        k4r, k4v = v4, accel(r4, zonal)
        r = [r[i] + h / 6 * (k1r[i] + 2 * k2r[i] + 2 * k3r[i] + k4r[i]) for i in range(3)]
        v = [v[i] + h / 6 * (k1v[i] + 2 * k2v[i] + 2 * k3v[i] + k4v[i]) for i in range(3)]
    return r, v


# --- PASS's relative frame (GWJORB.hal) -------------------------------------
def gwj_frame(rt, vt):
    vxr = cross(vt, rt)
    L = [unit(cross(rt, vxr)), unit(vxr), mul(-1.0 / norm(rt), rt)]
    return L, norm(vxr) / dot(rt, rt)


def lvc_to_m50(rt, vt, rel):
    """GWJ with INER_TO_LVC off: target-centred curvilinear -> M50 (steps 90-120)."""
    L, w = gwj_frame(rt, vt)
    R = norm(rt)
    x, y, z, xd, yd, zd = rel
    th, thd, zcon = x / R, xd / R, R - z
    rl = [math.sin(th) * zcon, y, R - math.cos(th) * zcon]
    vl = [math.cos(th) * zcon * thd - zd * math.sin(th), yd, math.cos(th) * zd + rl[0] * thd]
    vl[0] += -w * rl[2]
    vl[2] += w * rl[0]
    r = [rt[i] + sum(L[k][i] * rl[k] for k in range(3)) for i in range(3)]
    v = [vt[i] + sum(L[k][i] * vl[k] for k in range(3)) for i in range(3)]
    return r, v


def m50_to_lvc(rt, vt, rs, vs):
    """GWJ with INER_TO_LVC on: the shuttle relative to the target (steps 60-80)."""
    L, w = gwj_frame(rt, vt)
    R = norm(rt)
    rl = matvec(L, sub(rs, rt))
    vl = matvec(L, sub(vs, vt))
    vl[0] -= -w * rl[2]
    vl[2] -= w * rl[0]
    zcon = R - rl[2]
    th = math.atan(rl[0] / zcon)
    thd = (math.cos(th) / zcon) ** 2 * (vl[0] * zcon + rl[0] * vl[2])
    return [R * th, rl[1], R - zcon / math.cos(th), R * thd, vl[1], (vl[2] - thd * rl[0]) / math.cos(th)]


# --- Clohessy-Wiltshire, x along, z down ------------------------------------
def cw(rel, n, t):
    """Hill's equations in x (along, + ahead), y (+ right), z (+ down):
    xdd = 2n zd, zdd = 3n^2 z - 2n xd, ydd = -n^2 y -- the textbook solution
    with R = -z (radial out), S = x."""
    x, y, z, xd, yd, zd = rel
    R0, Rd0, S0, Sd0 = -z, -zd, x, xd
    s, c = math.sin(n * t), math.cos(n * t)
    R = (4 - 3 * c) * R0 + s / n * Rd0 + 2 / n * (1 - c) * Sd0
    S = 6 * (s - n * t) * R0 + S0 - 2 / n * (1 - c) * Rd0 + (4 * s - 3 * n * t) / n * Sd0
    Rd = 3 * n * s * R0 + c * Rd0 + 2 * s * Sd0
    Sd = -6 * n * (1 - c) * R0 - 2 * s * Rd0 + (4 * c - 3) * Sd0
    Y = y * math.cos(n * t) + yd / n * math.sin(n * t)
    Yd = -y * n * math.sin(n * t) + yd * math.cos(n * t)
    return [S, Y, -R, Sd, Yd, -Rd]


# --- Lambert (universal variables; Vallado alg. 58, prograde) -------------------
def stumpff(z):
    if z > 1e-6:
        sz = math.sqrt(z)
        return (1 - math.cos(sz)) / z, (sz - math.sin(sz)) / sz ** 3
    if z < -1e-6:
        sz = math.sqrt(-z)
        return (1 - math.cosh(sz)) / z, (math.sinh(sz) - sz) / sz ** 3
    return 0.5, 1.0 / 6.0


def lambert(r1, r2, dt, h_dir):
    r1n, r2n = norm(r1), norm(r2)
    cdn = dot(r1, r2) / (r1n * r2n)
    dnu = math.acos(max(-1.0, min(1.0, cdn)))
    if dot(cross(r1, r2), h_dir) < 0:
        dnu = 2 * math.pi - dnu
    A = math.sin(dnu) * math.sqrt(r1n * r2n / (1 - cdn))

    def tof(z):
        C, S = stumpff(z)
        y = r1n + r2n + A * (z * S - 1) / math.sqrt(C)
        if y < 0:
            return None, y, C, S
        chi = math.sqrt(y / C)
        return (chi ** 3 * S + A * math.sqrt(y)) / math.sqrt(MU), y, C, S

    # bracket z (elliptic, one revolution at most): bisect on time of flight
    lo, hi = -4 * math.pi ** 2, 4 * math.pi ** 2 - 1e-9
    while tof(lo)[0] is None:
        lo += 0.1
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        t, y, C, S = tof(mid)
        if t is None or t < dt:
            lo = mid
        else:
            hi = mid
    t, y, C, S = tof(0.5 * (lo + hi))
    f = 1 - y / r1n
    g = A * math.sqrt(y / MU)
    gd = 1 - y / r2n
    v1 = mul(1.0 / g, sub(r2, mul(f, r1)))
    v2 = mul(1.0 / g, sub(mul(gd, r2), r1))
    return v1, v2


def lvlh_rows(r, v):
    """GWRORB.hal step 350: rows unit(r x (v x r)), unit(v x r), unit(-r)."""
    vxr = cross(v, r)
    return [unit(cross(r, vxr)), unit(vxr), unit(mul(-1.0, r))]


# --- the targets file -------------------------------------------------------------
def read_target(path, norad):
    for ln in open(path):
        t = ln.split()
        if len(t) >= 9 and t[0] == "target" and int(t[1]) == norad:
            epoch = float(t[2])
            rj = [float(x) for x in t[3:6]]
            vj = [float(x) for x in t[6:9]]
            return epoch, matvec(J2000_TO_M50, rj), matvec(J2000_TO_M50, vj)
    sys.exit("rndz_start: no 'target %d' line in %s" % (norad, path))


def unix_of(when):
    d = datetime.datetime.fromisoformat(when)
    return calendar.timegm(d.timetuple()) + d.microsecond * 1e-6


def kft3(s):
    return [float(x) * 1000.0 * FT for x in s.split(",")]


def fmt_rel(rel, unit="ft"):
    k = 1.0 / FT
    return ("X %+10.1f  Y %+8.1f  Z %+8.1f ft   XD %+7.3f  YD %+7.3f  ZD %+7.3f ft/s"
            % tuple(x * k for x in rel))


def solve3(J, b):
    """J x = b, 3x3, Cramer."""
    def det(M):
        return (M[0][0] * (M[1][1] * M[2][2] - M[1][2] * M[2][1])
                - M[0][1] * (M[1][0] * M[2][2] - M[1][2] * M[2][0])
                + M[0][2] * (M[1][0] * M[2][1] - M[1][1] * M[2][0]))
    d = det(J)
    out = []
    for k in range(3):
        M = [row[:] for row in J]
        for i in range(3):
            M[i][k] = b[i]
        out.append(det(M) / d)
    return out


def shoot(r1, v1, r2, dt, zonal=True):
    """The velocity at r1, near v1, that reaches r2 in dt: Newton's method on
    a numerical propagation (finite-difference Jacobian).  Works where a
    Lambert solution is singular -- the NC arc is a whisker over one
    revolution -- and serves as the precision refinement of a conic answer,
    in the manner of PASS's precision velocity-required task (GWWORB)."""
    v = list(v1)
    for it in range(1, 30):
        got, _ = propagate(r1, v, dt, zonal)
        miss = sub(r2, got)
        if norm(miss) < 0.01:
            return v, it
        J = [[0.0] * 3 for _ in range(3)]
        for k in range(3):
            dv = [0.0, 0.0, 0.0]
            dv[k] = 1e-3
            g2, _ = propagate(r1, add(v, dv), dt, zonal)
            for i in range(3):
                J[i][k] = (g2[i] - got[i]) / 1e-3
        v = add(v, solve3(J, miss))
    sys.exit("rndz_start: the arc did not converge")


def shoot_inplane(rt0, vt0, rel0, rt1, vt1, want, dt, zonal=True):
    """The NC arc: from the relative position rel0 (LVC, m) with no out-of-
    plane rate -- the Orbiter in the station's plane at NC, as the ground's
    phasing (NPC) leaves it -- the in-plane rates XD, ZD that bring X and Z
    to `want` at the end, the target at rt1, vt1 then.  Y is left to the
    dynamics (the J2 drift between the two orbits).  Newton on the
    numerical propagation; returns the rates and the arrival."""
    xd, zd = rel0[3], rel0[5]
    for it in range(30):
        def arrive(a, b):
            r, v = lvc_to_m50(rt0, vt0, rel0[:3] + [a, 0.0, b])
            r1, v1 = propagate(r, v, dt, zonal)
            return m50_to_lvc(rt1, vt1, r1, v1)
        g = arrive(xd, zd)
        mx, mz = want[0] - g[0], want[2] - g[2]
        if math.hypot(mx, mz) < 0.01:
            return xd, zd, g
        e = 1e-3
        gx, gz = arrive(xd + e, zd), arrive(xd, zd + e)
        A11, A12 = (gx[0] - g[0]) / e, (gz[0] - g[0]) / e
        A21, A22 = (gx[2] - g[2]) / e, (gz[2] - g[2]) / e
        det = A11 * A22 - A12 * A21
        xd += (mx * A22 - A12 * mz) / det
        zd += (A11 * mz - A21 * mx) / det
    sys.exit("rndz_start: the NC arc did not converge")


def cmd_start(a):
    epoch, rT, vT = read_target(a.targets, a.norad)
    t_ti, t0 = unix_of(a.ti), unix_of(a.start)
    t_nc = t_ti - a.nc_before * 60.0
    rTi, vTi = propagate(rT, vT, t_ti - epoch)
    L, n = gwj_frame(rTi, vTi)
    p = kft3(a.ti_point)
    print("Ti TIG %s UTC; start %s UTC (Ti %+.1f min)" % (a.ti, a.start, (t0 - t_ti) / 60.0))
    print("the ISS at Ti: |r| %.1f km, orbital rate %.6e rad/s (period %.1f min)"
          % (norm(rTi) / 1e3, n, 2 * math.pi / n / 60.0))
    out = {}
    if a.rate:
        rate = ([1.5 * n * p[2], 0.0, 0.0] if a.rate == "coelliptic"
                else [float(x) * FT for x in a.rate.split(",")])
        rel_ti = p + rate
        print("the Ti point, rate as given:  " + fmt_rel(rel_ti))
        out["CW"] = cw(rel_ti, n, t0 - t_ti)
        for name, zonal in (("two-body", False), ("J2-J4", True)):
            rO, vO = lvc_to_m50(rTi, vTi, rel_ti)
            rt0, vt0 = propagate(rTi, vTi, t0 - t_ti, zonal)
            ro0, vo0 = propagate(rO, vO, t0 - t_ti, zonal)
            out[name] = m50_to_lvc(rt0, vt0, ro0, vo0)
    else:
        q = kft3(a.nc_point)
        print("NC point at Ti - %.1f min: X %.1f Y %.1f Z %.1f kft" % ((a.nc_before,) + tuple(x / FT / 1e3 for x in q)))
        print("the Ti point (TGT 9's T2):  X %.1f Y %.1f Z %.1f kft" % tuple(x / FT / 1e3 for x in p))
        # Clohessy-Wiltshire: the in-plane arc NC -> Ti, then back to the start
        dt = t_ti - t_nc

        def at(xd, zd, t):
            return cw([q[0], q[1], q[2], xd, 0.0, zd], n, t)
        b0, bx, bz = at(0, 0, dt), at(1, 0, dt), at(0, 1, dt)
        A11, A12, A21, A22 = bx[0] - b0[0], bz[0] - b0[0], bx[2] - b0[2], bz[2] - b0[2]
        r1, r2 = p[0] - b0[0], p[2] - b0[2]
        det = A11 * A22 - A12 * A21
        xd, zd = (r1 * A22 - A12 * r2) / det, (A11 * r2 - A21 * r1) / det
        out["CW"] = at(xd, zd, t0 - t_nc)
        cw_arrive = at(xd, zd, dt)
        for name, zonal in (("two-body", False), ("J2-J4", True)):
            rtn, vtn = propagate(rTi, vTi, t_nc - t_ti, zonal)
            nxd, nzd, arr = shoot_inplane(rtn, vtn, q + [xd, 0.0, zd], rTi, vTi, p, dt, zonal)
            rN, vN = lvc_to_m50(rtn, vtn, q + [nxd, 0.0, nzd])
            ro0, vo0 = propagate(rN, vN, t0 - t_nc, zonal)
            rt0, vt0 = propagate(rTi, vTi, t0 - t_ti, zonal)
            out[name] = m50_to_lvc(rt0, vt0, ro0, vo0)
            if zonal:
                roT, voT = propagate(rN, vN, dt, zonal)
                arrive = m50_to_lvc(rTi, vTi, roT, voT)
                # the burn NC was, against a co-elliptic Orbiter at the NC point
                L0, n0 = gwj_frame(rtn, vtn)
                rC, vC = lvc_to_m50(rtn, vtn, q + [1.5 * n0 * q[2], 0.0, 0.0])
                dvnc = matvec(lvlh_rows(rN, vN), sub(vN, vC))
        print("arrival at the Ti point, J2-J4:  " + fmt_rel(arrive))
        print("                  and by CW:     " + fmt_rel(cw_arrive))
        print("NC itself, against a co-elliptic Orbiter there: DVX %+.2f DVY %+.2f DVZ %+.2f ft/s"
              % tuple(x / FT for x in dvnc))
    print("the start:")
    for name in ("CW", "two-body", "J2-J4"):
        print("  %-10s " % name + fmt_rel(out[name]))
    d = [(out["J2-J4"][i] - out["CW"][i]) / FT for i in range(6)]
    print("  J2-J4 less CW: position %.1f ft, velocity %.3f ft/s"
          % (math.sqrt(sum(x * x for x in d[:3])), math.sqrt(sum(x * x for x in d[3:]))))
    print()
    # the state's own time last: vehdyn places the Orbiter when the calendar
    # becomes known, a minute or two later (the IPL's HALT), and coasts it on
    print("YAGPC_VEHDYN_START_REL=%d,%s,%.3f" % (a.norad, ",".join("%.3f" % x for x in out["J2-J4"]), t0))


def state_args(v):
    g = float(v[0])
    return g, [float(x) * FT for x in v[1:4]], [float(x) * FT for x in v[4:7]]


def cmd_lambert(a):
    go, ro, vo = state_args(a.orb)
    gt, rt, vt = state_args(a.tgt)
    tig = float(a.tig)
    dt = a.dt * 60.0
    off = kft3(a.offset)
    ro1, vo1 = propagate(ro, vo, tig - go)
    rt1, vt1 = propagate(rt, vt, tig - gt)
    rt2, vt2 = propagate(rt1, vt1, dt)
    aim = lvc_to_m50(rt2, vt2, off + [0.0, 0.0, 0.0])[0]
    print("at T1 TIG (GMT %.3f) the Orbiter relative to the target: %s"
          % (tig, fmt_rel(m50_to_lvc(rt1, vt1, ro1, vo1))))
    h = cross(ro1, vo1)
    M = lvlh_rows(ro1, vo1)

    def show(name, v1):
        dv = matvec(M, sub(v1, vo1))
        print("  %-28s DVX %+7.2f  DVY %+7.2f  DVZ %+7.2f  DVT %6.2f ft/s"
              % (name, dv[0] / FT, dv[1] / FT, dv[2] / FT, norm(dv) / FT))
        return dv

    # the conic answer against a target carried by two-body, as a conic
    # Lambert assumes; the precision one in the J2-J4 field throughout
    rt2c, vt2c = propagate(rt1, vt1, dt, zonal=False)
    aimc = lvc_to_m50(rt2c, vt2c, off + [0.0, 0.0, 0.0])[0]
    show("conic (two-body throughout)", lambert(ro1, aimc, dt, h)[0])
    v1, it = shoot(ro1, lambert(ro1, aim, dt, h)[0], aim, dt)
    dv = show("precision (J2-J4), %d iter" % it, v1)
    r2, v2 = propagate(ro1, v1, dt)
    print("  arrival at T2 relative to the target: " + fmt_rel(m50_to_lvc(rt2, vt2, r2, v2)))
    return dv


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub_ = ap.add_subparsers(dest="cmd", required=True)
    s = sub_.add_parser("start", help="the starting relative state, as YAGPC_VEHDYN_START_REL")
    s.add_argument("--targets", default=os.path.expanduser("~/sts134-runs/rendezvous/sts134-targets.txt"))
    s.add_argument("--norad", type=int, default=25544)
    s.add_argument("--ti", default="2011-05-18T07:38:00", help="Ti TIG, UTC (default STS-134's)")
    s.add_argument("--start", default="2011-05-18T06:30:00", help="the run's start, UTC")
    s.add_argument("--ti-point", default="-48.6,0,1.2",
                   help="DX,DY,DZ kft at Ti TIG (default TGT 9's T2 offset)")
    s.add_argument("--nc-point", default="-246,0,1.2",
                   help="DX,DY,DZ kft of the NC burn (default the checklist's profile, p. 1-5)")
    s.add_argument("--nc-before", type=float, default=92.0,
                   help="NC TIG, minutes before Ti (default 92: PET -1:32, p. 1-5)")
    s.add_argument("--rate", help="instead of the NC arc: XD,YD,ZD ft/s at the Ti point, or "
                                  "'coelliptic' (XD = 1.5 n DZ)")
    l = sub_.add_parser("lambert", help="an independent solution of the Ti burn")
    l.add_argument("--orb", nargs=7, required=True, metavar=("GMT", "X", "Y", "Z", "VX", "VY", "VZ"),
                   help="the Orbiter: PASS GMT s, M50 ft, ft/s")
    l.add_argument("--tgt", nargs=7, required=True, metavar=("GMT", "X", "Y", "Z", "VX", "VY", "VZ"),
                   help="the target, likewise")
    l.add_argument("--tig", required=True, help="T1 TIG, PASS GMT s")
    l.add_argument("--dt", type=float, default=76.9, help="transfer time, min (default TGT 10's)")
    l.add_argument("--offset", default="-0.9,0,1.8", help="T2 offset DX,DY,DZ kft (default TGT 10's)")
    a = ap.parse_args()
    if a.cmd == "start":
        cmd_start(a)
    else:
        cmd_lambert(a)


if __name__ == "__main__":
    main()
