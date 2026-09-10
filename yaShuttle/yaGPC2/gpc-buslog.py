#!/usr/bin/env python3
"""
License:    Public Domain, no restrictions believed to exist.
Filename:   gpc-buslog.py
Purpose:    Decode and query the binary bus log written by YAGPC_BUSLOG.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      gpc-buslog.py FILE summary
            gpc-buslog.py FILE bus N [--from=SEC] [--to=SEC] [--limit=N]
            gpc-buslog.py FILE rate [--bin=SEC] [--from=] [--to=]
            gpc-buslog.py FILE gaps N [--min=MS] [--from=] [--to=]
            gpc-buslog.py FILE busy [--from=] [--to=]
            gpc-buslog.py FILE overlap A B [--min=MS]

WHY.  The emulator carries 43 separate YAGPC_*TRACE variables, each answering
one question and each costing a fresh run of the same scenario -- so a question
not anticipated in advance cannot be answered without running again.  A whole
~1000 s run moves about 1.49 million bus words; at 12 bytes an event that is
under 18 MB.  Capturing everything once is cheaper than a single re-run.

    ./yaGPC2 ... with YAGPC_BUSLOG=/tmp/run.bus
    gpc-buslog.py /tmp/run.bus gaps 6 --min=100
    gpc-buslog.py /tmp/run.bus overlap 6 18

`gaps` is the one that matters for the open DK question: it shows, per bus,
every interval in which NOTHING happened, which is what a "1053 ms hold" looks
like from the wire's point of view.  `overlap` tests whether one bus goes quiet
exactly while another is active -- e.g. whether the DK buses stall for the
duration of a mass-memory transfer (see gpc-causes.py show 27).
"""

import os, struct, sys, collections

REC = 12

# GpcServiceNumber, from yaGpcIntegration.h.  Kept here rather than imported so
# the decoder stands alone; if the enum changes, this is the one place to fix.
#
# GET THE ORDER RIGHT.  It is XMIT_WORD=0, XMIT_CMD=1, RECV_WORD=2,
# RECV_POLL=3 -- word before command in each pair, which is the opposite of
# the way one says it.  This table had both pairs transposed, and the reading
# it produced was plausible enough to survive a while: an ordinary DEU fill
# (1 command + 100 data words) decoded as "100 commands issued in zero time",
# which looks like a bus program spinning.  The cross-check is the DEU model's
# own wordsIn -- 111,164 for bus 6 in v91a, which must equal that bus's
# XMIT_WORD count, not its XMIT_CMD count.
KIND = {0: "XMIT_WORD", 1: "XMIT_CMD", 2: "RECV_WORD", 3: "RECV_POLL",
        4: "SVC4", 5: "SVC5", 6: "SVC6", 7: "SVC7"}


def load(path, lo=None, hi=None):
    """Yield (t_sec, bus, kind, aux, value)."""
    with open(path, "rb") as f:
        while True:
            b = f.read(REC * 8192)
            if not b:
                return
            for i in range(0, len(b) - REC + 1, REC):
                t, bus, kind, aux, val = struct.unpack_from("<IBBHI", b, i)
                ts = t / 1e6
                if lo is not None and ts < lo:
                    continue
                if hi is not None and ts > hi:
                    continue
                yield ts, bus, kind, aux, val


def opt(o, k, d=None, cast=float):
    return cast(o[k]) if k in o else d


def cmd_summary(path, o):
    n = collections.Counter()
    kinds = collections.Counter()
    first = last = None
    for ts, bus, kind, aux, val in load(path):
        n[bus] += 1
        kinds[(bus, kind)] += 1
        if first is None:
            first = ts
        last = ts
    total = sum(n.values())
    print("%d events, t=%.3f .. %.3f s, %.1f MB"
          % (total, first or 0, last or 0, total * REC / 1e6))
    print("\n  bus    events  XMIT_WORD   XMIT_CMD  RECV_WORD  RECV_POLL")
    for bus in sorted(n):
        print("  %3d %9d  %9d  %9d  %9d  %9d"
              % (bus, n[bus], kinds[(bus, 0)], kinds[(bus, 1)],
                 kinds[(bus, 2)], kinds[(bus, 3)]))
    return 0


def cmd_bus(path, o, args):
    bus = int(args[0])
    lim = opt(o, "limit", 40, int)
    k = 0
    for ts, b, kind, aux, val in load(path, opt(o, "from"), opt(o, "to")):
        if b != bus:
            continue
        print("  t=%12.6f  %-9s  val=%08x" % (ts, KIND.get(kind, kind), val))
        k += 1
        if k >= lim:
            print("  ... (--limit=%d reached)" % lim); break
    if k == 0:
        print("  nothing on bus %d in that window" % bus)
    return 0


def cmd_rate(path, o):
    binsec = opt(o, "bin", 1.0)
    cnt = collections.Counter()
    buses = set()
    for ts, bus, kind, aux, val in load(path, opt(o, "from"), opt(o, "to")):
        cnt[(int(ts / binsec), bus)] += 1
        buses.add(bus)
    slots = sorted({s for s, _ in cnt})
    bl = sorted(buses)
    print("  t/%gs  " % binsec + "".join("%8s" % ("bus%d" % b) for b in bl))
    for s in slots:
        print("  %6.0f  " % (s * binsec)
              + "".join("%8d" % cnt[(s, b)] for b in bl))
    return 0


def cmd_gaps(path, o, args):
    """Every interval in which NOTHING happened on a bus."""
    bus = int(args[0])
    minms = opt(o, "min", 50.0)
    prev = None
    out = []
    for ts, b, kind, aux, val in load(path, opt(o, "from"), opt(o, "to")):
        if b != bus:
            continue
        if prev is not None and (ts - prev) * 1000.0 >= minms:
            out.append((prev, ts, (ts - prev) * 1000.0))
        prev = ts
    if not out:
        print("  no gap >= %g ms on bus %d" % (minms, bus)); return 0
    print("  %d gap(s) >= %g ms on bus %d:" % (len(out), minms, bus))
    for a, b_, ms in out:
        print("     %10.6f .. %10.6f   %9.2f ms" % (a, b_, ms))
    tot = sum(x[2] for x in out)
    print("  total silent: %.1f ms" % tot)
    return 0


def cmd_busy(path, o):
    """Per-bus event counts and span -- a quick shape of the window."""
    lo, hi = opt(o, "from"), opt(o, "to")
    n = collections.Counter(); first = {}; last = {}
    for ts, bus, kind, aux, val in load(path, lo, hi):
        n[bus] += 1
        first.setdefault(bus, ts)
        last[bus] = ts
    for bus in sorted(n):
        span = last[bus] - first[bus]
        print("  bus %3d  %8d events  %.3f .. %.3f s  %.1f/s"
              % (bus, n[bus], first[bus], last[bus],
                 n[bus] / span if span > 0 else 0))
    return 0


def cmd_overlap(path, o, args):
    """Does bus A fall silent exactly while bus B is active?"""
    a, b = int(args[0]), int(args[1])
    minms = opt(o, "min", 100.0)
    ev = [(ts, bus) for ts, bus, k, x, v in load(path, opt(o, "from"),
                                                 opt(o, "to")) if bus in (a, b)]
    ta = [t for t, bus in ev if bus == a]
    tb = [t for t, bus in ev if bus == b]
    if not ta or not tb:
        print("  one of the buses has no traffic in that window"); return 0
    gaps = []
    for i in range(len(ta) - 1):
        ms = (ta[i + 1] - ta[i]) * 1000.0
        if ms >= minms:
            gaps.append((ta[i], ta[i + 1], ms))
    print("  bus %d has %d silence(s) >= %g ms; bus %d activity inside each:"
          % (a, len(gaps), minms, b))
    import bisect
    for s, e, ms in gaps:
        lo_i = bisect.bisect_left(tb, s); hi_i = bisect.bisect_right(tb, e)
        inside = hi_i - lo_i
        print("     %10.6f .. %10.6f  %8.2f ms   bus%d events inside: %d"
              % (s, e, ms, b, inside))
    return 0


def main(argv):
    if len(argv) < 3 or argv[1] in ("-h", "--help"):
        print(__doc__); return 0
    path, cmd = argv[1], argv[2]
    if not os.path.exists(path):
        print("no such log: %s" % path); return 1
    o, rest = {}, []
    for x in argv[3:]:
        if x.startswith("--") and "=" in x:
            k, v = x[2:].split("=", 1); o[k] = v
        else:
            rest.append(x)
    if cmd == "summary": return cmd_summary(path, o)
    if cmd == "bus":     return cmd_bus(path, o, rest)
    if cmd == "rate":    return cmd_rate(path, o)
    if cmd == "gaps":    return cmd_gaps(path, o, rest)
    if cmd == "busy":    return cmd_busy(path, o)
    if cmd == "overlap": return cmd_overlap(path, o, rest)
    print("unknown command %r" % cmd); return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
