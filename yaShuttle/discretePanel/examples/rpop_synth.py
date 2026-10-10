#!/usr/bin/env python3
"""A synthetic +V-bar approach and docking for testing rpop.py without the
simulator: TRU1 (port base + 98) and TGT1 (port base + 109) as yaGPC2 sends
them, with TRU1 [30] [31] the docking state (0 free, 1 captured, 2
hard-mated) and contacts.

    python3 examples/rpop_synth.py --port-base 59100 --from 360 --rate 20

The ISS flies a circular 350 km, 51.6 deg orbit (J2 gravity) held in LVLH.
The Orbiter is in the docking attitude (nose to the zenith, payload bay to
the ISS) on the +V-bar.  Its centre of mass moves by Clohessy-Wiltshire
about the ISS plus jet pulses: every 2 s a 0.02 ft/s pulse in any axis that
is off the VBAR APPROACH cue card's range rate (STS-134 RNDZ CC 9-8), or
drifting off the axis, by more than 0.015 ft/s -- each pulse below RPOP's
delta-V threshold, as a docking's are.  At contact (the ODS ring's face on
PMA-2's) it is captured: the closing rate stops, it moves with the ISS, the
captured misalignment damps out in 30 s, and the ring then draws it in to
hard mate (the face from Zo 475.75 to 460, 60 s).  --to N stops and holds at
N ft instead of docking.  Vehicle time runs --rate times the wall clock.
"""
import argparse
import math
import os
import socket
import struct
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "flights"))
import rndz_instruments as ri          # noqa: E402

MU, RE, J2 = 3.986004418e14, 6378137.0, 1.08262668e-3
FT = 0.3048
GMT0 = 136 * 86400 + 12 * 3600 + 56 * 60 + 27.994 + (1 * 86400 + 21 * 3600)   # MET 1/21:00:00
RETRACT_FT = (ri.ODS_ZO - ri.ODS_HARDMATE_ZO) / 12.0


def gravity(r):
    rn = np.linalg.norm(r)
    z2 = (r[2] / rn) ** 2
    k = 1.5 * J2 * (RE / rn) ** 2
    return -MU * r / rn ** 3 * np.array([1 + k * (1 - 5 * z2), 1 + k * (1 - 5 * z2), 1 + k * (3 - 5 * z2)])


def quat(C):
    """Rotation matrix -> quaternion w x y z."""
    t = np.trace(C)
    if t > 0:
        s = math.sqrt(t + 1.0) * 2
        return [0.25 * s, (C[2, 1] - C[1, 2]) / s, (C[0, 2] - C[2, 0]) / s, (C[1, 0] - C[0, 1]) / s]
    i = int(np.argmax(np.diag(C)))
    j, k = (i + 1) % 3, (i + 2) % 3
    s = math.sqrt(1.0 + C[i, i] - C[j, j] - C[k, k]) * 2
    q = [0.0] * 4
    q[0] = (C[k, j] - C[j, k]) / s
    q[1 + i] = 0.25 * s
    q[1 + j] = (C[j, i] + C[i, j]) / s
    q[1 + k] = (C[k, i] + C[i, k]) / s
    return q


def rdot_for(rng):
    """The VBAR APPROACH card's range rates, ft/s, by DP-DP range."""
    if rng > 170:
        return -0.20
    if rng > 110:
        return -0.15
    if rng > 30:
        return -0.10
    if rng > 10:
        return -0.07
    return -0.10


def cw(s, n):
    x, y, z, vx, vy, vz = s
    return np.array([vx, vy, vz, 2 * n * vz, -n * n * y, 3 * n * n * z - 2 * n * vx])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port-base", type=int, required=True)
    ap.add_argument("--from", dest="r0", type=float, default=360.0, help="start, DP-DP ft")
    ap.add_argument("--to", dest="r1", type=float, default=None, help="hold at this DP-DP ft (default: dock)")
    ap.add_argument("--rate", type=float, default=20.0)
    ap.add_argument("--hz", type=float, default=10.0, help="datagrams per wall second")
    ap.add_argument("--duration", type=float, default=0.0, help="wall s, 0 forever")
    a = ap.parse_args()
    if a.port_base in (48800, 49900):
        sys.exit("port base %d is other runs'" % a.port_base)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 1)
    iface = os.environ.get('NSTS_BUS_IFACE', '127.0.0.1')
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(iface))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    dest_t, dest_g = ("239.255.1.1", a.port_base + 98), ("239.255.1.1", a.port_base + 109)

    rn = RE + 350e3
    inc = math.radians(51.6)
    r = np.array([rn, 0.0, 0.0])
    v = math.sqrt(MU / rn) * np.array([0.0, math.cos(inc), math.sin(inc)])
    A = np.column_stack([[0, 0, -1.0], [0, 1.0, 0], [1.0, 0, 0]])     # body -> LVLH, docking attitude
    pma = np.array(ri.PMA2) / FT
    ods = np.array(ri.ODS_BODY) / FT
    off = pma - A @ ods                 # CG - (ODS face - PMA face), LVLH ft
    # the Orbiter's centre of mass relative to the ISS's, LVLH ft, ft/s
    s = np.concatenate([off + np.array([a.r0, 3.0, -4.0]), [rdot_for(a.r0), 0.0, 0.0]])
    t, h = 0.0, 0.5
    dock, t_cap, cap_p, next_jet = 0, None, None, 0.0
    wall0 = time.monotonic()
    sent = 0
    while True:
        tw = (time.monotonic() - wall0) * a.rate
        while t < tw:
            def f(x):
                return np.concatenate([x[3:], gravity(x[:3])])
            x = np.concatenate([r, v])
            k1 = f(x); k2 = f(x + 0.5 * h * k1); k3 = f(x + 0.5 * h * k2); k4 = f(x + h * k3)
            x = x + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
            r, v = x[:3], x[3:]
            n = math.sqrt(MU / np.linalg.norm(r) ** 3)
            p = s[:3] - off                                      # ODS face - PMA face, ft
            if dock == 0:
                k1 = cw(s, n); k2 = cw(s + 0.5 * h * k1, n); k3 = cw(s + 0.5 * h * k2, n); k4 = cw(s + h * k3, n)
                s = s + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
                p = s[:3] - off
                hold = a.r1 is not None and p[0] <= a.r1
                if t >= next_jet:                                # the pilot's pulses
                    next_jet = t + 2.0
                    want = np.array([0.0 if hold else rdot_for(p[0]),
                                     max(-0.05, min(0.05, -0.02 * p[1])),
                                     max(-0.05, min(0.05, -0.02 * p[2]))])
                    for i in range(3):
                        if abs(want[i] - s[3 + i]) > 0.015:
                            s[3 + i] += math.copysign(0.02, want[i] - s[3 + i])
                if p[0] <= 0.0 and a.r1 is None:                 # contact: capture
                    dock, t_cap, cap_p = 1, t, p.copy()
                    sys.stderr.write("rpop_synth: t %.0f CAPTURE, misalignment %.2f %.2f ft\n"
                                     % (t, p[1], p[2]))
            else:
                tc = t - t_cap
                lat = cap_p * max(0.0, 1.0 - tc / 30.0)          # misalignment damping out
                ax = -RETRACT_FT * min(1.0, max(0.0, (tc - 30.0) / 60.0))
                new = off + np.array([ax, lat[1], lat[2]])
                s = np.concatenate([new, (new - s[:3]) / h])
                if tc >= 90.0 and dock == 1:
                    dock = 2
                    sys.stderr.write("rpop_synth: t %.0f HARD MATE\n" % t)
            t += h
        L = np.column_stack([np.array(c) for c in ri.lvlh_axes(list(r), list(v))])   # LVLH -> M50
        n = ri.orbital_rate(list(r), list(v))
        w_lvlh = L @ np.array([0.0, -n, 0.0])
        C = L @ A
        rel = s[:3] * FT
        relv = s[3:] * FT
        ro = r + L @ rel
        vo = v + L @ relv + np.cross(w_lvlh, L @ rel)
        wb = C.T @ w_lvlh
        tru = ([t, GMT0 + t] + quat(C) + list(wb) + list(ro) + list(vo) + [0.0, 0.0, -1.0]
               + [1, 0, 0, 0, 1, 0, 0, 0, 1] + [0.0, 0.0, 0.0] + [float(dock), 1.0 if dock else 0.0])
        sock.sendto(b"TRU1" + struct.pack(">32d", *tru), dest_t)
        tgt = [t, 25544] + list(r) + list(v) + quat(L)
        sock.sendto(b"TGT1" + struct.pack(">12d", *tgt), dest_g)
        sent += 1
        if sent % int(a.hz * 10) == 0:
            p = s[:3] - off
            sys.stderr.write("rpop_synth: t %.0f DP-DP %.2f %.2f %.2f ft, dock %d\n" % (t, *p, dock))
        if a.duration and time.monotonic() - wall0 > a.duration:
            return
        time.sleep(1.0 / a.hz)


if __name__ == "__main__":
    main()
