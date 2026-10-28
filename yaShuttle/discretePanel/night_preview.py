#!/usr/bin/env python3
"""A night view of the landing, in about a minute: portview fed by a synthetic flight down the final approach.

    python3 night_preview.py [--night-terrain F] [--views front,left] [--utc 2011-06-01T06:30:00]
                             [--runway 15|33] [--dist-nmi 6] [--alt-ft AUTO] [--speed-kt 300] [--hold]
                             [--port-base 44700] [-- more portview options]

Starts portview and sends it the TRU1 datagrams yaGPC2 would (portview.py, DATA), for an Orbiter on the
approach to KSC at the date and hour given (the default is the flown landing's night, the Moon down).  It flies the
last --dist-nmi miles at --speed-kt along the 19 deg outer glideslope's line (--alt-ft overrides the height) and
starts again from the beginning when it reaches the threshold; --hold keeps it still.  No flight computer, no
simulation: the picture is portview's alone, so --night-terrain (or NSTS_NIGHT_TERRAIN) can be tried at will.
"""
import argparse
import math
import os
import socket
import struct
import subprocess
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import portview as P                                   # noqa: E402

A, F = 6378137.0, 1.0 / 298.3                           # PASS's ellipsoid
E2 = F * (2.0 - F)
OMEGA = 7.292115e-5


def navaid(name):
    path = os.path.join(os.path.dirname(HERE), "yaGPC2", "tools", "sites", "ksc-navaids.txt")
    for line in open(path):
        w = line.split()
        if len(w) >= 6 and w[0] == "runway" and w[2] == name:
            return [float(x) for x in w[3:7]]           # lat, lon (rad), height (m), heading (rad)
    raise SystemExit("night_preview: no runway %s in %s" % (name, path))


def geodetic(lat, lon, h):
    n = A / math.sqrt(1.0 - E2 * math.sin(lat) ** 2)
    return np.array([(n + h) * math.cos(lat) * math.cos(lon), (n + h) * math.cos(lat) * math.sin(lon),
                     (n * (1.0 - E2) + h) * math.sin(lat)])


def ned_to_ef(lat, lon):
    sl, cl, so, co = math.sin(lat), math.cos(lat), math.sin(lon), math.cos(lon)
    n = np.array([-sl * co, -sl * so, cl])
    e = np.array([-so, co, 0.0])
    d = np.array([-cl * co, -cl * so, -sl])
    return np.stack([n, e, d], axis=1)                  # columns: north, east, down in Earth-fixed


def quat_of(m):
    """w x y z of a rotation matrix."""
    t = m[0, 0] + m[1, 1] + m[2, 2]
    if t > 0.0:
        s = math.sqrt(t + 1.0) * 2.0
        q = [0.25 * s, (m[2, 1] - m[1, 2]) / s, (m[0, 2] - m[2, 0]) / s, (m[1, 0] - m[0, 1]) / s]
    else:
        i = int(np.argmax([m[0, 0], m[1, 1], m[2, 2]]))
        j, k = (i + 1) % 3, (i + 2) % 3
        s = math.sqrt(m[i, i] - m[j, j] - m[k, k] + 1.0) * 2.0
        v = [0.0] * 3
        v[i] = 0.25 * s
        v[j] = (m[j, i] + m[i, j]) / s
        v[k] = (m[k, i] + m[i, k]) / s
        q = [(m[k, j] - m[j, k]) / s] + v
    q = np.array(q)
    return q / np.linalg.norm(q)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--night-terrain", type=float, default=float(os.environ.get("NSTS_NIGHT_TERRAIN", "0.25")))
    ap.add_argument("--views", default="front")
    ap.add_argument("--utc", default="2011-06-01T06:30:00")
    ap.add_argument("--runway", default="15", choices=("15", "33"))
    ap.add_argument("--dist-nmi", type=float, default=6.0)
    ap.add_argument("--alt-ft", type=float, default=None)
    ap.add_argument("--speed-kt", type=float, default=300.0)
    ap.add_argument("--alpha-deg", type=float, default=3.0)
    ap.add_argument("--hold", action="store_true")
    ap.add_argument("--port-base", type=int, default=44700)
    a, extra = ap.parse_known_args()
    extra = [x for x in extra if x != "--"]

    lat0, lon0, h0, hdg = navaid("KSC" + a.runway)
    import calendar
    t_utc = calendar.timegm(time.strptime(a.utc, "%Y-%m-%dT%H:%M:%S"))
    env = dict(os.environ, NSTS_NIGHT_TERRAIN=str(a.night_terrain))
    cmd = [sys.executable, os.path.join(HERE, "portview.py"), "--views", a.views, "--port-base", str(a.port_base),
           "--night-terrain", str(a.night_terrain)] + extra
    proc = subprocess.Popen(cmd, env=env)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 1)
    dest = (P.MCAST_GROUP, a.port_base + P.TRUTH_OFFSET)

    nm = 1852.0
    gamma = math.radians(19.0)
    v_ms = a.speed_kt * 1852.0 / 3600.0
    run_s = a.dist_nmi * nm / v_ms
    pitch = -gamma + math.radians(a.alpha_deg)          # nose attitude: along the glide path, plus alpha
    wall0 = time.monotonic()
    veh_t = 0.0
    print("night_preview: portview starting (about a minute to load); the approach to KSC%s, %s UTC, night terrain %.2f"
          % (a.runway, a.utc, a.night_terrain), flush=True)
    try:
        while proc.poll() is None:
            s = 0.0 if a.hold else (veh_t % run_s) * v_ms                   # metres flown down the line
            dist = a.dist_nmi * nm - s                                      # to the threshold, along the ground
            alt = (a.alt_ft * 0.3048 if a.alt_ft is not None else math.tan(gamma) * dist) + h0 + 1.0
            # the position: the threshold, back along the reciprocal heading by dist (flat-Earth offsets are fine at 6 nmi)
            n_off, e_off = -dist * math.cos(hdg), -dist * math.sin(hdg)
            lat = lat0 + n_off / A
            lon = lon0 + e_off / (A * math.cos(lat0))
            r_ef = geodetic(lat, lon, alt)
            unix = t_utc + veh_t
            m50_to_ef = P.gmst_matrix(unix)
            ef_to_m50 = m50_to_ef.T
            # body (X forward, Y right, Z down) -> north-east-down: heading, then pitch
            ch, sh, cp, sp = math.cos(hdg), math.sin(hdg), math.cos(pitch), math.sin(pitch)
            b2ned = np.array([[ch * cp, -sh, ch * sp], [sh * cp, ch, sh * sp], [-sp, 0.0, cp]])
            q = quat_of(ef_to_m50 @ ned_to_ef(lat, lon) @ b2ned)
            track = ned_to_ef(lat, lon) @ np.array([math.cos(hdg) * math.cos(gamma), math.sin(hdg) * math.cos(gamma), math.sin(gamma)])
            v_ef = (0.0 if a.hold else v_ms) * track
            v_m50 = ef_to_m50 @ (v_ef + np.cross([0.0, 0.0, OMEGA], r_ef))
            r_m50 = ef_to_m50 @ r_ef
            vals = [veh_t, 0.0, *q, 0.0, 0.0, 0.0, *r_m50, *v_m50, (alt - h0) / 0.3048, a.speed_kt,
                    unix, *m50_to_ef.reshape(9), 0.0, 0.0, 0.0]
            sock.sendto(b"TRU1" + struct.pack(">%dd" % len(vals), *vals), dest)
            veh_t += 0.05
            wait = wall0 + veh_t - time.monotonic()
            if wait > 0:
                time.sleep(wait)
    except KeyboardInterrupt:
        pass
    finally:
        if proc.poll() is None:
            proc.terminate()


if __name__ == "__main__":
    main()
