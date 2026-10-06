#!/usr/bin/env python3
"""DEORBIT TARGETS: the PEG 4 targets and TIG that bring the orbiter from its
present orbit to entry interface at the right range from the runway -- the
ground's job at TIG-45 min ("MCC UPLINK PASS TGT", Entry Checklist 3-5).

    python3 deorbit_target.py CAPTURE_DIR SITE.json [--after HOURS]
                              [--rei NMI] [--tff MIN] [--runway N]

CAPTURE_DIR: a simulatePASS capture (its vehdyn.json: the truth's M50 state
and GMT).  SITE.json: tools/sites/*.json, the same file PASS's site I-loads
come from.  Prints TIG (GMT and MET) and the DEORB MNVR items: C1 (14), C2
(15), HT (16), THETA T (17).

THE TARGETS (FSSR STS 83-0003-34 p.207, 237-239, 304-305):
  THETA T  deg, the central angle from the TIG position to the EI target, in
           the TIG orbit plane, downrange: iRT = iR cos + iDR sin, iDR = iR x
           iYO, iYO = unit(V x R); R7 = |RT| iRT, fixed in inertial space
  HT       n.mi., the target's geodetic height on the Fischer ellipsoid
  C1, C2   VR = C1 + C2 VH at the target (radial up, horizontal; ft/s, none)
PEG flies a conic coast to R7 (the J2 drift is in the ground's biases); here
the burn is impulsive and the coast after it is integrated WITH J2 to the
400,000 ft crossing, so the EI point is where the vehicle will really be.
C1 and C2 are STS-1's (OFP JSC-14483 Vol 5 Table 6.1-III: 15310, -.6157,
HT 65.832 = 400,000 ft): the target line gives about -1.2 deg at EI.
THETA T is solved so that the surface range from the EI point to the runway
threshold is --rei (STS-1: 4,358 n.mi., EI to touchdown 31.5 min; STS-134
flew EI to touchdown in 31:44), and TIG is put on the chosen pass so that the
coast from TIG to EI is --tff minutes (STS-1 28:10, STS-134 34:03).

The Earth's orientation is GMST (IAU 1982) with M50 taken as the 1950 mean
equator and equinox (a 0.70 deg rotation about the pole from J2000's, the
pole's own 0.28 deg ignored): good to tens of n.mi. on the ground track --
PASS's own REI, displayed after LOAD, is the check to close on.
"""
import argparse
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from omstarget import ltvc, dot, cross, norm, unit, scale, add   # noqa: E402

MU = 1.40764487566e16      # EARTH_MU, FSSR 83-0003 K-loads, ft^3/s^2
J2 = 1.0826271e-3
RE = 20925741.4698         # the Fischer ellipsoid's equatorial radius, ft (FSSR p.299)
FLAT = 3.352329869e-3
NMI = 6076.11549
FT = 0.3048
WE = 7.29211514646e-5      # CGNS_EARTH_RATE
H_EI = 400000.0
C1, C2, HT = 15310.0, -0.6157, 65.832
GMT0_JD = 2455561.5        # 2011 GMT day 0 (PASS counts days from 0: 136/12:56 = 11,796,988 s)


def gmst(gmt_s):
    jd = GMT0_JD + gmt_s / 86400.0
    T = (jd - 2451545.0) / 36525.0
    g = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * T * T
    # M50 -> J2000: the equinox moved about 0.70 deg in RA in 50 years
    return math.radians(g % 360.0) - math.radians(0.6996)


def to_earth(r, gmt_s):
    th = gmst(gmt_s)
    return [r[0] * math.cos(th) + r[1] * math.sin(th), -r[0] * math.sin(th) + r[1] * math.cos(th), r[2]]


def geodetic(x):
    """Latitude, longitude (rad) and height (ft) on the Fischer ellipsoid."""
    e2 = FLAT * (2 - FLAT)
    p = math.hypot(x[0], x[1])
    lat = math.atan2(x[2], p * (1 - e2))
    for _ in range(5):
        N = RE / math.sqrt(1 - e2 * math.sin(lat) ** 2)
        h = p / math.cos(lat) - N
        lat = math.atan2(x[2], p * (1 - e2 * N / (N + h)))
    return lat, math.atan2(x[1], x[0]), h


def accel(r):
    x, y, z = r
    rn = norm(r)
    k = -MU / rn ** 3
    f = 1.5 * J2 * MU * RE * RE / rn ** 5
    zz = 5 * z * z / (rn * rn)
    return [k * x + f * x * (zz - 1), k * y + f * y * (zz - 1), k * z + f * z * (zz - 3)]


def step(r, v, h):
    def f(s):
        return s[3:] + accel(s[:3])
    s = r + v
    k1 = f(s)
    k2 = f([s[i] + h / 2 * k1[i] for i in range(6)])
    k3 = f([s[i] + h / 2 * k2[i] for i in range(6)])
    k4 = f([s[i] + h * k3[i] for i in range(6)])
    s = [s[i] + h / 6 * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]) for i in range(6)]
    return s[:3], s[3:]


def coast(r, v, gmt, dt, h=5.0):
    n = max(1, int(abs(dt) / h))
    for _ in range(n):
        r, v = step(r, v, dt / n)
    return r, v, gmt + dt


def to_ei(r, v, gmt, h=2.0, tmax=4000.0):
    """Coast with J2 until the geodetic height falls through 400,000 ft."""
    t = 0.0
    hprev = geodetic(to_earth(r, gmt))[2]
    while t < tmax:
        r1, v1 = step(r, v, h)
        hh = geodetic(to_earth(r1, gmt + h))[2]
        if hh <= H_EI < hprev:
            f = (hprev - H_EI) / (hprev - hh)
            r2, v2 = step(r, v, f * h)
            return r2, v2, gmt + f * h, t + f * h
        r, v, gmt, hprev, t = r1, v1, gmt + h, hh, t + h
    return None


def surface_range(lat1, lon1, lat2, lon2):
    c = math.sin(lat1) * math.sin(lat2) + math.cos(lat1) * math.cos(lat2) * math.cos(lon2 - lon1)
    return math.degrees(math.acos(max(-1.0, min(1.0, c)))) * 60.0


def target(r, v, theta):
    """R7: THETA T downrange of the TIG position in its orbit plane, at HT."""
    ir = unit(r)
    iyo = unit(cross(v, r))
    idr = cross(ir, iyo)
    th = math.radians(theta)
    irt = add(scale(math.cos(th), ir), scale(math.sin(th), idr))
    # HT is geodetic: the ellipsoid's radius at the target's latitude, plus HT
    lat = math.asin(irt[2])
    rell = RE * (1 - FLAT * math.sin(lat) ** 2)
    return scale(rell + HT * NMI, irt)


def fly(r, v, gmt, theta):
    """The impulsive burn at (r, v) for THETA T, and the EI it gives."""
    r7 = target(r, v, theta)
    iy = unit(cross(v, r))
    vd = ltvc(r, r7, iy, C1, C2)
    dv = norm([a - b for a, b in zip(vd, v)])
    ei = to_ei(r, vd, gmt)
    return vd, dv, ei


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("capture")
    ap.add_argument("site")
    ap.add_argument("--after", type=float, default=0.0, help="earliest TIG, hours after the capture")
    ap.add_argument("--rei", type=float, default=4350.0, help="EI to runway, n.mi.")
    ap.add_argument("--tff", type=float, default=30.0, help="TIG to EI, minutes")
    ap.add_argument("--runway", type=int, default=1, help="the site file's runway slot")
    ap.add_argument("--max-crossrange", type=float, default=550.0)
    a = ap.parse_args()

    vd = json.load(open(os.path.join(a.capture, "vehdyn.json")))["vehdyn"]
    r = [x / FT for x in vd[3:6]]
    v = [x / FT for x in vd[6:9]]
    gmt = vd[126]
    site = json.load(open(a.site))
    rw = [x for x in site["runways"] if x["slot"] == a.runway][0]

    def dms(s):
        d, m, x = s[:-1].split("-")
        val = int(d) + int(m) / 60.0 + float(x) / 3600.0
        return -val if s[-1] in "SW" else val
    lat_rw, lon_rw = math.radians(dms(rw["lat_dms"])), math.radians(dms(rw["lon_dms"]))

    # 1. the pass: coast, watching the ground track's distance from the runway
    r, v, gmt = coast(r, v, gmt, a.after * 3600.0)
    best = None
    t, prev = 0.0, []
    while t < 30 * 3600.0:
        r, v, gmt = coast(r, v, gmt, 30.0)
        t += 30.0
        la, lo, _ = geodetic(to_earth(r, gmt))
        d = surface_range(la, lo, lat_rw, lon_rw)
        prev.append((d, t, r, v, gmt))
        if len(prev) >= 3 and prev[-2][0] < prev[-3][0] and prev[-2][0] <= prev[-1][0]:
            h = cross(r, v)
            he = to_earth(h, gmt)
            K = [math.cos(lat_rw) * math.cos(lon_rw), math.cos(lat_rw) * math.sin(lon_rw), math.sin(lat_rw)]
            xr = math.degrees(math.asin(dot(he, K) / norm(he))) * 60.0
            if abs(xr) <= a.max_crossrange:
                best = prev[-2] + (xr,)
                break
        prev = prev[-3:]
    if best is None:
        print("no pass within %.0f n.mi. crossrange in 30 h" % a.max_crossrange)
        return 1
    d_min, t_close, rc, vc, gmt_close, xr = best
    print("pass: closest %.0f n.mi. from %s at GMT %s (capture + %.2f h), crossrange %+.0f n.mi."
          % (d_min, rw["id"], fmt_gmt(gmt_close), (a.after * 3600 + t_close) / 3600.0, xr))

    # 2. TIG: about (tff + ~31 min entry) before the closest approach; then
    #    THETA T so that the EI point is REI from the runway, and TIG slid so
    #    that TIG -> EI is TFF
    tig_off = -(a.tff + 31.0) * 60.0
    for _ in range(12):
        rt, vt, gt = coast(rc, vc, gmt_close, tig_off)
        theta = solve_theta(rt, vt, gt, lat_rw, lon_rw, a.rei)
        if theta is None:
            print("no THETA T gives REI %.0f n.mi. from this TIG" % a.rei)
            return 1
        vdd, dv, ei = fly(rt, vt, gt, theta)
        tff = ei[3] / 60.0
        if abs(tff - a.tff) < 0.05:
            break
        tig_off += (tff - a.tff) * 60.0      # too long a coast: burn later, nearer the site
    re, ve, ge, tfree = ei
    la, lo, _ = geodetic(to_earth(re, ge))
    vh = norm(cross(re, ve)) / norm(re)
    vr = dot(re, ve) / norm(re)
    print("TIG GMT %s  (%.1f s after the capture)" % (fmt_gmt(gt), gt - vd[126]))
    print("  C1 %.0f  C2 %+.4f  HT %.3f  THETA T %.3f   (items 14, 15, 16, 17)" % (C1, C2, HT, theta))
    print("  impulsive dV %.1f ft/s; coast to EI %.2f min" % (dv, tfree / 60.0))
    print("EI GMT %s  lat %.2f lon %.2f  V %.0f ft/s inertial  gamma %.3f deg  REI %.0f n.mi."
          % (fmt_gmt(ge), math.degrees(la), math.degrees(lo), norm(ve),
             math.degrees(math.atan2(vr, vh)), surface_range(la, lo, lat_rw, lon_rw)))
    return 0


def solve_theta(r, v, gmt, lat_rw, lon_rw, rei):
    """THETA T for which the EI point is REI n.mi. short of the runway."""
    def miss(th):
        vd, dv, ei = fly(r, v, gmt, th)
        if ei is None:
            return None
        la, lo, _ = geodetic(to_earth(ei[0], ei[2]))
        return surface_range(la, lo, lat_rw, lon_rw) - rei
    lo_, hi_ = 80.0, 200.0
    m_lo, m_hi = miss(lo_), miss(hi_)
    if m_lo is None or m_hi is None or m_lo * m_hi > 0:
        # scan for a bracket
        prev = None
        for th in range(80, 201, 5):
            m = miss(float(th))
            if m is not None and prev is not None and prev[1] * m <= 0:
                lo_, hi_, m_lo, m_hi = prev[0], float(th), prev[1], m
                break
            prev = (float(th), m) if m is not None else prev
        else:
            return None
    for _ in range(40):
        mid = 0.5 * (lo_ + hi_)
        m = miss(mid)
        if m is None:
            return None
        if m_lo * m <= 0:
            hi_, m_hi = mid, m
        else:
            lo_, m_lo = mid, m
        if hi_ - lo_ < 1e-4:
            break
    return 0.5 * (lo_ + hi_)


def fmt_gmt(g):
    d = int(g // 86400)
    s = g - d * 86400
    return "%03d/%02d:%02d:%06.3f" % (d, int(s // 3600), int(s % 3600 // 60), s % 60)


if __name__ == "__main__":
    sys.exit(main())
