#!/usr/bin/env python3
"""Record what a person does in the simulation as a draft crew script.

    python3 recordscript.py [--port-base N] OUT.script

Collects the script lines that panelO6.py, the DPS keyboards (stsKeyboard.py)
and the MDUs (MEDS2.py) send whenever a PERSON operates something -- a panel
switch or pushbutton, a keyboard key, an MDU edgekey -- on port base + 89
(crewscript.send_record), and writes them to OUT.script as a crew script.
OUT.script is rewritten after every action, so stopping this program (Ctrl-C,
or the manager's SCRIPT Record button pressed again) loses nothing.  What a
playing script does is not recorded: only a person's actions are sent.

IT IS A DRAFT, meant to be edited before it is used:

  * The times are as performed, to a tenth of a second, as '+N' steps.
  * A pause longer than --pause seconds (default 8) gets a comment above the
    line after it.  A person usually pauses because they are waiting for
    something -- a display to come up, a GPC to reach RUN -- and a replay
    with a fixed delay in its place fails on a slower host, so a 'wait'
    line probably belongs there.
  * Keys typed on one keyboard less than --gap seconds apart (default 2.5)
    are joined into one 'keys' line.
  * A GPC switch is preceded by 'gpc N' only when the column changes.
  * The hand controllers are not recorded, nor are the manager's own buttons,
    nor the MDU panes' IDP switches.
  * Any line that does not pass crewscript's checks is kept as a comment, with
    the reason.

Check the result with 'python3 crewscript.py OUT.script'.
"""
import argparse
import os
import signal
import sys
import time

import crewscript
import discretes as D


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                 epilog=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("out", metavar="OUT.script", help="the script to write")
    ap.add_argument("--port-base", type=int, default=None,
                    help="the simulation's port base (default 6900, or NSTS_BUS_PORT_BASE)")
    ap.add_argument("--gap", type=float, default=2.5,
                    help="keys this close together (s) go on one 'keys' line (2.5)")
    ap.add_argument("--pause", type=float, default=8.0,
                    help="a pause this long (s) is marked as a likely 'wait' (8)")
    args = ap.parse_args(argv)
    if args.port_base is not None:
        D.set_port_base(args.port_base)
    sock = crewscript.record_receiver(D.PORT_BASE)
    sock.settimeout(0.5)

    started = time.strftime("%Y-%m-%d %H:%M:%S")
    steps = []          # [t, line, last_t] -- last_t: when a keys line last grew
    last_gpc = [None]

    def check(line):
        try:
            crewscript.parse("+0 %s\n" % line)
            return None
        except crewscript.ScriptError as e:
            return str(e)

    def write():
        out = ["# Recorded by recordscript.py, %s, port base %d." % (started, D.PORT_BASE),
               "# A DRAFT: the times are as performed.  Edit before use -- see",
               "# 'python3 recordscript.py --help' for what is and is not recorded.",
               ""]
        prev = None
        for t, line, _last in steps:
            dt = 0.0 if prev is None else t - prev
            prev = t
            if dt >= args.pause:
                out.append("# paused %.0f s here: if this was waiting for something, "
                           "a 'wait' line belongs here" % dt)
            why = check(line)
            text = "+%-6.1f %s" % (dt, line)
            out.append(text if why is None else "# (does not check: %s) %s" % (why, text))
        tmp = args.out + ".tmp"
        with open(tmp, "w") as fh:
            fh.write("\n".join(out) + "\n")
        os.replace(tmp, args.out)

    def stop(*_a):
        write()
        print("recordscript: %d step(s) in %s" % (len(steps), args.out), flush=True)
        sys.exit(0)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    write()
    print("recordscript: recording to %s (port base %d); Ctrl-C to stop"
          % (args.out, D.PORT_BASE), flush=True)
    while True:
        try:
            data, _a = sock.recvfrom(4096)
        except OSError:
            continue
        src, _, line = data.decode("utf-8", errors="replace").partition("\t")
        line = " ".join(line.split())
        if not line:
            continue
        t = time.monotonic()
        words = line.split()
        if words[0] == "gpc":
            if len(words) > 1 and words[1] == last_gpc[0]:
                continue                       # the column it is already on
            last_gpc[0] = words[1]
        if words[0] == "keys" and steps:
            pt, pline, plast = steps[-1]
            pw = pline.split()
            if pw[0] == "keys" and pw[1] == words[1] and t - plast <= args.gap:
                steps[-1] = [pt, pline + " " + " ".join(words[2:]), t]
                write()
                continue
        steps.append([t, line, t])
        print("recordscript: %s" % line, flush=True)
        write()


if __name__ == "__main__":
    sys.exit(main())
