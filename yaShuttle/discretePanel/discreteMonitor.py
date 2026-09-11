#!/usr/bin/env python3
"""Watch the GPC discrete bus and print what is published on it.

Every device that owns a discrete publishes set/reset bit messages; this
prints them as they arrive, decoded, and keeps a running picture of what
the two registers would hold for a GPC that had been listening the whole
time.  It publishes nothing itself.

    python3 discreteMonitor.py            # follow until interrupted
    python3 discreteMonitor.py --seconds 10
    python3 discreteMonitor.py --changes  # only when a register changes

The --changes form is the useful one when a mass memory is running: its
READY line is republished several times a second whether or not anything
has happened, and only the transitions are interesting.
"""

import argparse
import time

import discretes as D

# Labels for the bits, from the IOP Principles of Operation as documented
# in gpc/iop.coffee and yaGPC2's src/iop.c.  IBM numbering.
NAMES = {
    D.REG_A: {
        0: "HALT", 1: "STANDBY", 2: "RUN", 3: "IPL",
        4: "MM1 IPL source", 5: "MM2 IPL source",
        6: "MM1 READY", 7: "MM2 READY",
        12: "IOP terminate A", 13: "IOP terminate B",
    },
    D.REG_B: {
        0: "GPC ID b0", 1: "GPC ID b1", 2: "GPC ID b2",
        3: "BFS engage 1", 4: "BFS engage 2", 5: "BFS engage 3",
        6: "CRT select A", 7: "CRT select B",
    },
}
REGNAME = {D.REG_A: "A", D.REG_B: "B"}


def bits(mask):
    return [i for i in range(32) if mask & D.bit_mask(i)]


def describe(reg, mask):
    return ", ".join(NAMES.get(reg, {}).get(b, "bit %d" % b) for b in bits(mask)) \
        or "no bits"


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--seconds", type=float, default=None,
                    help="stop after this long (default: run until interrupted)")
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the UDP port range the buses use: bus n is "
                         "base+n and the discrete bus base+80 (default 6900, "
                         "matching busConfig).  Give a second emulation its "
                         "own base -- the same option on yaGPC2 and MEDS -- "
                         "to run it alongside the first without port "
                         "conflicts.  NSTS_BUS_PORT_BASE sets it too.")
    ap.add_argument("--changes", action="store_true",
                    help="print only when a register value actually changes")
    args = ap.parse_args()

    # Before any socket is opened.
    if args.port_base is not None:
        D.set_port_base(args.port_base)

    sock = D.receiver(timeout=0.5)
    print("listening on %s:%d" % (D.GROUP, D.PORT))
    state = {D.REG_A: 0, D.REG_B: 0}
    t0 = time.time()
    n = 0
    try:
        while True:
            if args.seconds is not None and time.time() - t0 >= args.seconds:
                break
            try:
                data, _ = sock.recvfrom(2048)
            except OSError:
                continue
            msg = D.decode(data)
            if msg is None:
                continue
            n += 1
            reg = msg["reg"]
            before = state[reg]
            state[reg] = D.apply(before, msg)
            if args.changes and state[reg] == before:
                continue
            print("%7.2fs  %-5s reg %s  %-28s   A=%08x B=%08x"
                  % (time.time() - t0,
                     "SET" if msg["op"] == D.SET else "RESET",
                     REGNAME.get(reg, "?"),
                     describe(reg, msg["mask"]),
                     state[D.REG_A], state[D.REG_B]))
    except KeyboardInterrupt:
        pass
    print("%d discrete message(s)" % n)


if __name__ == "__main__":
    main()
