#!/usr/bin/env python3
"""A synthetic +V-bar approach for testing rpop.py without the simulator:
TRU1 (port base + 98) and TGT1 (port base + 109) as yaGPC2 sends them.

    python3 examples/rpop_synth.py --port-base 59100 --from 360 --to 3 --rate 20

The ISS flies a circular 350 km, 51.6 deg orbit (J2 gravity), held in LVLH;
the Orbiter is in the docking attitude (nose to the zenith, payload bay to
the ISS) on the +V-bar, its ODS ring's face coming in on PMA-2's along the
VBAR APPROACH cue card's range rates (STS-134 RNDZ CC 9-8), with a few feet
of drift off the axis that the crew would be nulling.  It stops at --to and
holds there.  Vehicle time runs --rate times faster than the wall clock.
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port-base", type=int, required=True)
    ap.add_argument("--from", dest="r0", type=float, default=360.0, help="start, DP-DP ft")
    ap.add_argument("--to", dest="r1", type=float, default=3.0, help="hold at, DP-DP ft")
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

    # the ISS: circular, 350 km, 51.6 deg
    rn = RE + 350e3
    inc = math.radians(51.6)
    r = np.array([rn, 0.0, 0.0])
    v = math.sqrt(MU / rn) * np.array([0.0, math.cos(inc), math.sin(inc)])
    pma = np.array(ri.PMA2)
    ods = np.array(ri.ODS_BODY)
    t, rng, h = 0.0, a.r0, 0.5          # vehicle time, DP-DP range (ft), the integrator's step
    wall0 = time.monotonic()
    sent = 0
    while True:
        tw = (time.monotonic() - wall0) * a.rate
        while t < tw:                   # the ISS's orbit (RK4) and the approach
            def f(s):
                return np.concatenate([s[3:], gravity(s[:3])])
            s = np.concatenate([r, v])
            k1 = f(s); k2 = f(s + 0.5 * h * k1); k3 = f(s + 0.5 * h * k2); k4 = f(s + h * k3)
            s = s + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
            r, v = s[:3], s[3:]
            if rng > a.r1:
                rng = max(a.r1, rng + rdot_for(rng) * h)
            t += h
        L = ri.lvlh_axes(list(r), list(v))
        L = np.column_stack([np.array(c) for c in L])           # LVLH -> M50
        n = ri.orbital_rate(list(r), list(v))
        w_lvlh = L @ np.array([0.0, -n, 0.0])                    # LVLH's turn, M50
        # the Orbiter: body X up (-Z LVLH), body Z toward +X LVLH, body Y = +Y LVLH
        A = np.column_stack([[0, 0, -1.0], [0, 1.0, 0], [1.0, 0, 0]])     # body -> LVLH
        C = L @ A
        # a little drift off the axis, shrinking with range (ft)
        dz = 0.012 * rng * math.sin(t / 240.0)
        dy = 0.008 * rng * math.cos(t / 300.0)
        rdot = rdot_for(rng) if rng > a.r1 else 0.0
        face = pma + np.array([rng, dy, dz]) * FT                # the ODS face, ISS LVLH frame, m
        rel = face - A @ ods                                     # the Orbiter's CG
        relv = np.array([rdot, 0.0, 0.0]) * FT
        ro = r + L @ rel
        vo = v + L @ relv + np.cross(w_lvlh, L @ rel)
        wb = C.T @ w_lvlh                                        # body rates: LVLH hold
        tru = ([t, GMT0 + t] + quat(C) + list(wb) + list(ro) + list(vo) + [0.0, 0.0, -1.0]
               + [1, 0, 0, 0, 1, 0, 0, 0, 1] + [0.0, 0.0, 0.0])
        sock.sendto(b"TRU1" + struct.pack(">30d", *tru), dest_t)
        tgt = [t, 25544] + list(r) + list(v) + quat(L)
        sock.sendto(b"TGT1" + struct.pack(">12d", *tgt), dest_g)
        sent += 1
        if sent % int(a.hz * 10) == 0:
            sys.stderr.write("rpop_synth: t %.0f DP-DP %.1f ft\n" % (t, rng))
        if a.duration and time.monotonic() - wall0 > a.duration:
            return
        time.sleep(1.0 / a.hz)


if __name__ == "__main__":
    main()
