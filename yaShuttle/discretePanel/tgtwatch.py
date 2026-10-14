#!/usr/bin/env python3
"""tgtwatch.py [--port-base N]: LOOK FOR GLITCHES in the truth streams.

Listens to TRU1 (port base + 98, the Orbiter) and TGT1 (port base + 109,
other vehicles) like tgtprobe.py and portview do, and prints ONLY anomalies,
each with the vehicle's GMT and wall clock:

  GAP     a datagram type did not arrive for more than --gap s (wall)
  VTIME   vehicle time moved by more than twice its wall interval, or
          backwards (the vehicle stood still or was reset)
  STEP    the target's position relative to the Orbiter changed by more than
          --step ft beyond what its relative velocity over the interval
          explains (a discontinuity in either state)

Run it beside the simulation for as long as you like; a quiet terminal means
nothing happened.  It is a diagnostic, not a crew display (owner,
2026-10-14: the ISS vanished from the views for a fraction of a second at
138/11:07:18 and for ~2 s at 11:11:49).  Standard library only.
"""
import argparse
import math
import socket
import struct
import time

FT = 0.3048


def mcast(port):
    import os
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    s.bind(("", port))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton("239.255.1.1") + socket.inet_aton(os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")))
    s.setblocking(False)
    return s


def doubles(d, n):
    k = (len(d) - 4) // 8
    return struct.unpack(">%dd" % k, d[4:4 + 8 * k])[:n] if k >= n else None


def stamp(gmt_unix):
    w = time.strftime("%H:%M:%S", time.localtime())
    if gmt_unix is not None and gmt_unix > 0:
        return "%s UTC (wall %s)" % (time.strftime("%j/%H:%M:%S", time.gmtime(gmt_unix)), w)
    return "wall %s" % w


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--port-base", type=int, default=50000)
    ap.add_argument("--gap", type=float, default=0.5, help="seconds without a datagram (default 0.5)")
    ap.add_argument("--step", type=float, default=2.0, help="feet of unexplained relative jump (default 2)")
    ap.add_argument("--seconds", type=float, default=0.0)
    a = ap.parse_args()
    tru, tgt = mcast(a.port_base + 98), mcast(a.port_base + 109)
    last_wall = {"TRU1": None, "TGT1": None}
    last_v = {"TRU1": None, "TGT1": None}          # (vehicle t, wall t)
    hist = {}
    prev_rel = None                                # (vt, rel position m, rel velocity m/s)
    unix = None
    start = time.time()
    print("# tgtwatch: anomalies only (GAP > %.2f s, VTIME, STEP > %.1f ft)" % (a.gap, a.step), flush=True)
    while a.seconds <= 0 or time.time() - start < a.seconds:
        got = False
        for s in (tru, tgt):
            while True:
                try:
                    d = s.recv(4096)
                except (BlockingIOError, OSError):
                    break
                got = True
                now = time.time()
                kind = d[:4].decode("latin1")
                if kind not in last_wall:
                    continue
                v = doubles(d, 18 if kind == "TRU1" else 12)
                if v is None:
                    continue
                if last_wall[kind] is not None and now - last_wall[kind] > a.gap:
                    print("GAP    %s %.2f s without %s" % (stamp(unix), now - last_wall[kind], kind), flush=True)
                last_wall[kind] = now
                if last_v[kind] is not None:
                    dv, dw = v[0] - last_v[kind][0], now - last_v[kind][1]
                    if dv < -1e-6 or (dw > 0.05 and dv > 2.0 * dw + 0.5):
                        print("VTIME  %s %s vehicle time moved %+.3f s in %.3f s wall" % (stamp(unix), kind, dv, dw), flush=True)
                last_v[kind] = (v[0], now)
                if kind == "TRU1":
                    if v[17] > 0:
                        unix = v[17]
                    hist[round(v[0], 3)] = v
                    for k in sorted(hist)[:-100]:
                        del hist[k]
                else:
                    near = min(hist, key=lambda t: abs(t - v[0]), default=None)
                    if near is None or abs(near - v[0]) > 0.15:
                        continue
                    tr = hist[near]
                    # THE ORBITER AT THE TARGET DATAGRAM'S OWN TIME: the nearest
                    # TRU1 may be a few hundredths of a second off (a dropped
                    # or reordered datagram), and 7.7 km/s of orbital velocity
                    # turns 0.06 s into 460 m (1,500 ft) of "step".
                    dtp = v[0] - tr[0]
                    rel = [v[2 + i] - (tr[9 + i] + tr[12 + i] * dtp) for i in range(3)]
                    # relative velocity: TGT1 doubles 5-7 (target), TRU1 12-14 (orbiter) when present
                    try:
                        relv = [v[5 + i] - tr[12 + i] for i in range(3)]
                    except IndexError:
                        relv = [0.0, 0.0, 0.0]
                    if prev_rel is not None:
                        dt = v[0] - prev_rel[0]
                        if 0 < dt < 30:
                            pred = [prev_rel[1][i] + 0.5 * (prev_rel[2][i] + relv[i]) * dt for i in range(3)]
                            err = math.sqrt(sum((rel[i] - pred[i]) ** 2 for i in range(3))) / FT
                            if err > a.step:
                                print("STEP   %s relative position off by %.1f ft over %.2f s (range %.0f ft)"
                                      % (stamp(unix), err, dt, math.sqrt(sum(x * x for x in rel)) / FT), flush=True)
                    prev_rel = (v[0], rel, relv)
        if not got:
            time.sleep(0.01)
            for kind in last_wall:
                w = last_wall[kind]
                if w is not None and time.time() - w > max(a.gap, 1.0) * 4 and False:
                    pass


if __name__ == "__main__":
    main()
