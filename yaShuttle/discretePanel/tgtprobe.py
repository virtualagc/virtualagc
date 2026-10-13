#!/usr/bin/env python3
"""tgtprobe.py [--port-base N] [--seconds S]: where the other vehicles are, as
yaGPC2 sends them -- one line a second.

For each vehicle in TGT1 (port base + 109), paired with the Orbiter's TRU1
(port base + 98) of the same vehicle time: the date, the range, and the
direction from the Orbiter in its own body axes (az from the nose, + to the
right; el from the X-Y plane, + toward the crew's up, i.e. -Z), so you can say
which window should hold it, whether it is in the Earth's shadow, and -- run
it in both a run that has evolved and one restored to the same moment -- whether
the two disagree about where it is, before portview draws anything.

    python3 tgtprobe.py --port-base 50000
"""
import argparse
import math
import socket
import struct
import time


def mcast(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    s.bind(("", port))
    import os
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton("239.255.1.1") + socket.inet_aton(os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")))
    s.setblocking(False)
    return s


def doubles(d, n):
    k = (len(d) - 4) // 8
    return struct.unpack(">%dd" % k, d[4:4 + 8 * k])[:n] if k >= n else None


def body_matrix(q):
    n = math.sqrt(sum(x * x for x in q)) or 1.0
    w, x, y, z = (c / n for c in q)
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--port-base", type=int, default=50000)
    ap.add_argument("--seconds", type=float, default=0.0, help="stop after S s (default: until ^C)")
    a = ap.parse_args()
    tru, tgt = mcast(a.port_base + 98), mcast(a.port_base + 109)
    hist = {}                                  # recent TRU1 by rounded vehicle time
    last_print, last_tgt, start, n_tgt = 0.0, None, time.time(), 0
    print("# t(s)  date(UTC)             id      range      az     el   (body axes: az + right, el + crew-up)")
    while a.seconds <= 0 or time.time() - start < a.seconds:
        got = False
        for s, kind in ((tru, "TRU1"), (tgt, "TGT1")):
            while True:
                try:
                    d = s.recv(4096)
                except (BlockingIOError, OSError):
                    break
                got = True
                if d[:4] == b"TRU1":
                    v = doubles(d, 18)
                    if v:
                        hist[round(v[0], 3)] = v
                        for k in sorted(hist)[:-200]:
                            del hist[k]
                elif d[:4] == b"TGT1":
                    v = doubles(d, 12)
                    if not v:
                        continue
                    n_tgt += 1
                    last_tgt = time.time()
                    near = min(hist, key=lambda t: abs(t - v[0]), default=None)
                    if near is None or abs(near - v[0]) > 0.15 or time.time() - last_print < 1.0:
                        continue
                    last_print = time.time()
                    tr = hist[near]
                    C = body_matrix(tr[2:6])                      # body -> M50
                    rel = [v[2 + i] - tr[9 + i] for i in range(3)]
                    b = [sum(C[r][c] * rel[r] for r in range(3)) for c in range(3)]     # C^T rel
                    rng = math.sqrt(sum(x * x for x in b))
                    az = math.degrees(math.atan2(b[1], b[0]))
                    el = math.degrees(math.atan2(-b[2], math.hypot(b[0], b[1])))
                    unix = tr[17] if tr[17] >= 0 else None
                    date = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(unix)) if unix else "no date"
                    print("%7.1f  %s  %6d  %9.1f km %6.1f %6.1f" % (v[0], date, int(v[1]), rng / 1000.0, az, el),
                          flush=True)
        if not got:
            time.sleep(0.02)
            if last_tgt is None and time.time() - last_print > 5.0:
                last_print = time.time()
                print("# no TGT1 yet (no vehicle placed, or no panel wired / dynamics off)", flush=True)


if __name__ == "__main__":
    main()
