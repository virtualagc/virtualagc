#!/usr/bin/env python3
"""A night view of the landing, in about a minute: portview fed by a synthetic flight down the final approach.

    python3 night_preview.py [--night-terrain F] [--views front,left] [--utc 2011-06-01T06:30:00]
                             [--runway 15|33] [--dist-nmi 6] [--hold] [--alt-ft H] [--level] [--pitch-deg D]
                             [--set knob=value ...] [--port-base 44700] [-- more portview options]

Starts portview and sends it the TRU1 datagrams yaGPC2 would (portview.py, DATA), for an Orbiter landing at KSC at
the date and hour given (the default is the flown landing's night, the Moon down).  The flight is the Shuttle's
profile, flown over and over: the 19 deg outer glideslope at 300 kt from --dist-nmi out, the preflare at 1,750 ft,
the 1.5 deg inner glideslope, touchdown 760 m past the threshold at 195 kt, then the rollout to a stop and a pause,
and again.  --hold keeps it still instead, at --dist-nmi (negative: past the threshold) and --alt-ft, the nose
level with --level.  No flight computer, no simulation: the picture is portview's alone.

WHILE IT FLIES, type a knob and a value in this terminal (portview rereads them within a second).  Default, and a
useful range (past it things still work, but are blown out, invisible or slow):
    flood_gain 0.003       the xenon floodlights' light on the ground, display per lux: 0.0003 - 1 (1.68 is the Moon's)
    flood_exp 10           the beam, cos^N of the angle off the aim: 600 = 3 deg to half power, 300 = 4, 100 = 7,
                           30 = 13, 10 = 23, 0 = every way; 3 - 2000
    flood_aim_m 1000       each lamp toed in to the centreline this far down the runway: 100 - 3000
    flood_tilt_deg 0.3     and this far below the horizontal there: 0 - 2
    flood_lat_m 55         the two clusters' distance either side of the centreline: 0 - 150
    flood_height_m 3       their height: 1 - 30
    flood_back_m 20        their distance before the threshold (negative: past it): -200 - 200
    flood_spill 0.001      what a lamp sends every way, as a fraction of its peak (what a pilot behind it sees): 0 - 0.1
    flood_visible 1        1: the lamps drawn as points, 0: only their light on the ground
    flood_cd 1e9           each lamp's peak candela (it scales the light on the ground and the points alike)
    lamp_gain 0.01         every drawn lamp's brightness, edge, centreline, threshold, approach and floodlights: 0.0001 - 0.05
                           (the lamps' real candela is far beyond the display's range: this puts the distance at which a
                           lamp fades from the display's white at about 20 km at 0.01, 5 km at 0.0005)
    hirl_spacing_m 30      the runway edge lamps' spacing (the FAA's maximum is 61): 15 - 100 (under 10 is slow)
    approach_rows 5        the amber approach rows (the photographs show 3 or 5): 1 - 9
    edge_elev_deg 10       the edge lamps shine across the runway, this far above the horizontal: 0 - 45
    edge_n 3               their beam, cos^N off that axis (3 = 40 deg to half power, 10 = 22, 0 = every way): 0 - 30
    edge_spill 0.02        what they send every way, as a fraction of the beam's peak (what is seen from far off): 0 - 0.3
    center_elev_deg 75     the centreline lamps' axis, above the horizontal, tilted toward the approach: 0 - 90
    center_n 6             their beam: 0 - 30
    center_spill 0.01      their leak: 0 - 0.3
    approach_elev_deg 25   the approach lamps' axis, above the horizontal, tilted toward the approach: 0 - 90
    approach_n 20          their beam (20 = 8 deg to half power): 0 - 60
    approach_spill 0.01    their leak: 0 - 0.3
    night_terrain 0.1      the moonless terrain glow, a fraction of an overhead full Moon's: 0 (flat black) - 1
    night_terrain_high 0.3 the same from orbit, fading to night_terrain between night_alt_hi_km (80) and night_alt_lo_km (15)
                           above the ground (this preview flies low, so only night_terrain shows)
    show                   the values now;  quit
"""
import argparse
import json
import math
import tempfile
import threading
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


TAN_OGS = math.tan(math.radians(19.0))
TAN_IGS = math.tan(math.radians(1.5))
PREFLARE_X = 3650.0                  # m before the threshold: the 19 deg line's 1,750 ft
AIM_X = 2100.0                       # m before the threshold: where the 19 deg line meets the ground
TOUCHDOWN_X = -760.0                 # m before the threshold (negative: past it)
FLARE_H = TAN_OGS * (PREFLARE_X - AIM_X)
V_FINAL_MS, V_TD_MS = 300.0 * 1852.0 / 3600.0, 195.0 * 1852.0 / 3600.0
ROLLOUT_DECEL = 2.5                  # m/s^2


def wheel_height(x):
    """Main-wheel height (m) over the runway, x metres before the threshold."""
    if x >= PREFLARE_X:
        return TAN_OGS * (x - AIM_X)
    if x > TOUCHDOWN_X:
        w = x - TOUCHDOWN_X
        return TAN_IGS * w + (FLARE_H - TAN_IGS * (PREFLARE_X - TOUCHDOWN_X)) * (w / (PREFLARE_X - TOUCHDOWN_X)) ** 3
    return 0.0


def controls(knobs, path):
    """Type 'knob value' lines; each rewrites the JSON portview is watching."""
    def write():
        tmp = path + ".tmp"
        with open(tmp, "w") as f:
            json.dump(knobs, f)
        os.replace(tmp, path)
    write()
    for line in sys.stdin:
        w = line.split()
        if not w:
            continue
        if w[0] == "quit":
            os._exit(0)
        if w[0] == "show":
            print("night_preview: %s" % json.dumps(knobs), flush=True)
            continue
        if len(w) == 2 and w[0] in P.LIGHT_KNOBS:
            try:
                knobs[w[0]] = float(w[1])
            except ValueError:
                print("night_preview: %s wants a number" % w[0], flush=True)
                continue
            write()
            print("night_preview: %s = %s" % (w[0], w[1]), flush=True)
        else:
            print("night_preview: knobs: %s" % " ".join(sorted(P.LIGHT_KNOBS)), flush=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--night-terrain", type=float, default=float(os.environ.get("NSTS_NIGHT_TERRAIN", "0.1")))
    ap.add_argument("--views", default="front")
    ap.add_argument("--utc", default="2011-06-01T06:30:00")
    ap.add_argument("--runway", default="15", choices=("15", "33"))
    ap.add_argument("--dist-nmi", type=float, default=6.0)
    ap.add_argument("--alt-ft", type=float, default=None)
    ap.add_argument("--hold", action="store_true")
    ap.add_argument("--level", action="store_true", help="with --hold: the nose level (alpha only)")
    ap.add_argument("--pitch-deg", type=float, default=None, help="with --hold: the nose this far above the horizontal (negative: down)")
    ap.add_argument("--set", action="append", default=[], metavar="KNOB=VALUE")
    ap.add_argument("--port-base", type=int, default=44700)
    a, extra = ap.parse_known_args()
    extra = [x for x in extra if x != "--"]

    lat0, lon0, h0, hdg = navaid("KSC" + a.runway)
    import calendar
    t_utc = calendar.timegm(time.strptime(a.utc, "%Y-%m-%dT%H:%M:%S"))
    knobs = {"night_terrain": a.night_terrain}
    for kv in a.set:
        k, _, v = kv.partition("=")
        knobs[k] = float(v)
    lights_file = os.path.join(tempfile.gettempdir(), "night_preview-%d.json" % os.getpid())
    env = dict(os.environ, NSTS_LIGHTS_FILE=lights_file)
    cmd = [sys.executable, os.path.join(HERE, "portview.py"), "--views", a.views, "--port-base", str(a.port_base),
           "--lit-runway", a.runway, "--night-terrain", str(a.night_terrain)] + extra
    proc = subprocess.Popen(cmd, env=env)
    threading.Thread(target=controls, args=(knobs, lights_file), daemon=True).start()

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 1)
    dest = (P.MCAST_GROUP, a.port_base + P.TRUTH_OFFSET)

    x0 = a.dist_nmi * 1852.0
    x, v_g, rolled, pause = x0, V_FINAL_MS, False, 0.0
    CG_ABOVE_WHEELS = 4.5
    wall0 = time.monotonic()
    veh_t = 0.0
    dt = 0.05
    print("night_preview: portview starting (about a minute to load); landing at KSC%s, %s UTC.  Type a knob and a value "
          "to change the lights (see --help); 'show' lists them" % (a.runway, a.utc), flush=True)
    try:
        while proc.poll() is None:
            if a.hold:
                x = x0
                h = a.alt_ft * 0.3048 if a.alt_ft is not None else wheel_height(x0)
                v_g, slope = 0.0, 0.0
                pitch = (math.radians(a.pitch_deg) if a.pitch_deg is not None else
                         math.radians(5.0) if a.level else math.radians(-19.0 + 12.0))
            else:
                # the profile, stepped: speed by distance, height by distance, the nose along the path plus alpha
                if x > PREFLARE_X:
                    v_g = V_FINAL_MS
                elif x > TOUCHDOWN_X:
                    v_g = V_TD_MS + (V_FINAL_MS - V_TD_MS) * (x - TOUCHDOWN_X) / (PREFLARE_X - TOUCHDOWN_X)
                    rolled = False
                else:
                    rolled = True
                    v_g = max(0.0, v_g - ROLLOUT_DECEL * dt)
                if rolled and v_g <= 0.0:
                    pause += dt
                    if pause > 8.0:
                        x, v_g, rolled, pause = x0, V_FINAL_MS, False, 0.0
                x -= v_g * dt
                h = wheel_height(x)
                slope = (wheel_height(x) - wheel_height(x - 1.0)) if h > 0.0 else 0.0
                alpha = 8.0 + 4.0 * min(max(x / PREFLARE_X, 0.0), 1.0)
                if rolled:
                    alpha = 8.0 * min(max((v_g - 30.0) / (V_TD_MS - 30.0), 0.0), 1.0)
                pitch = -math.atan(slope) + math.radians(alpha)
            alt = h + CG_ABOVE_WHEELS + h0
            along = -x
            lat = lat0 + along * math.cos(hdg) / A
            lon = lon0 + along * math.sin(hdg) / (A * math.cos(lat0))
            r_ef = geodetic(lat, lon, alt)
            unix = t_utc + veh_t
            m50_to_ef = P.gmst_matrix(unix)
            ef_to_m50 = m50_to_ef.T
            ch, sh, cp, sp = math.cos(hdg), math.sin(hdg), math.cos(pitch), math.sin(pitch)
            b2ned = np.array([[ch * cp, -sh, ch * sp], [sh * cp, ch, sh * sp], [-sp, 0.0, cp]])
            q = quat_of(ef_to_m50 @ ned_to_ef(lat, lon) @ b2ned)
            track = ned_to_ef(lat, lon) @ np.array([math.cos(hdg), math.sin(hdg), slope])
            v_ef = v_g * track
            v_m50 = ef_to_m50 @ (v_ef + np.cross([0.0, 0.0, OMEGA], r_ef))
            r_m50 = ef_to_m50 @ r_ef
            vals = [veh_t, 0.0, *q, 0.0, 0.0, 0.0, *r_m50, *v_m50, h / 0.3048, v_g * 3600.0 / 1852.0,
                    unix, *m50_to_ef.reshape(9), 0.0, 0.0, 0.0]
            sock.sendto(b"TRU1" + struct.pack(">%dd" % len(vals), *vals), dest)
            veh_t += dt
            wait = wall0 + veh_t - time.monotonic()
            if wait > 0:
                time.sleep(wait)
    except KeyboardInterrupt:
        pass
    finally:
        if proc.poll() is None:
            proc.terminate()
        try:
            os.remove(lights_file)
        except OSError:
            pass


if __name__ == "__main__":
    main()
