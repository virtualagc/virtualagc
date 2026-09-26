#!/usr/bin/env python3
"""Score a simulatePASS run for the timing unit and the redundant set.

WHY THIS EXISTS.  Ledger #210 has been re-measured a dozen times and more than
one of those measurements was thrown away because the two arms of a comparison
were not scored the same way -- once because a "control" ran with the feature
still on, once because a restored vehicle was used to test how the flight
software CONFIGURES itself, and twice because a log was read while its run was
still going.  Scoring is therefore a script and not a habit.

    mtuscore.py LOGDIR [SNAPDIR] [--duration SECONDS]

LOGDIR is the --logs directory of the run.  SNAPDIR, if given, is a capture
taken at the END of that run; it is what makes the bypass verdict possible,
because the six overlaid branches are read out of memory and out of nothing
else.

THE SIX SLOTS are FIOPRMPG's bypass branches -- three commander elements and
three listener elements, one pair per accumulator.  A live slot holds a #BU
(f0xx); a bypassed one holds #DLYI (c0xx), which FCMBCEMD wrote.  Addresses
from the CSECT tables, identical in csects-SSW and csects-G9.
"""
import json, os, re, struct, sys

SLOTS = [("FIOBY51",  0x1cc74), ("FIOBY52",  0x1cc7e), ("FIOBY53",  0x1cc88),
         ("FIOBY51L", 0x1cc98), ("FIOBY52L", 0x1cca0), ("FIOBY53L", 0x1cca8)]


def slot_state(word):
    """A slot is live when it still holds the branch GPCIPL's fill left."""
    top = word >> 12
    return "live" if top == 0xf else ("BYPASSED" if top == 0xc else "?%04x" % word)


def read_slots(snapdir):
    out = {}
    for g in range(1, 6):
        f = os.path.join(snapdir, "gpc%d.mem.bin" % g)
        if not os.path.isfile(f):
            continue
        raw = open(f, "rb").read()
        w = struct.unpack(">%dH" % (len(raw) // 2), raw)
        out[g] = [(name, slot_state(w[a])) for name, a in SLOTS if a < len(w)]
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    pos = [a for a in sys.argv[1:] if not a.startswith("--")]
    prev = sys.argv[1:]
    pos = [a for i, a in enumerate(prev)
           if not a.startswith("--") and not (i and prev[i - 1] == "--duration")]
    log, snap = pos[0], (pos[1] if len(pos) > 1 else None)

    def rd(name):
        p = os.path.join(log, name)
        return open(p, errors="replace").read() if os.path.isfile(p) else ""

    panel, cam, gpc = rd("panel.log"), rd("cam.log"), rd("yaGPC2.log")

    # HOW FAR THE RUN GOT.  A run that never reached the transition has not
    # tested anything, and a vote count from it means nothing.
    ts = re.findall(r"t=([0-9]+\.[0-9])", panel)
    print("run:      reached t=%s, script %s" %
          (ts[-1] if ts else "?",
           "complete" if "script complete" in panel else "DID NOT COMPLETE"))

    # VOTES, WITH THEIR TIMES.  #187: an undated vote may only have been a
    # vote at the SIGINT teardown, so the time is not decoration.
    # THE DIAGONAL IS NOT A VOTE.  cam.py drives cell (n,n) from the COMMFAULT
    # register and the off-diagonal (voter, voted-against) from REG_FAILVOTE,
    # so "22" is GPC2's own commfault lamp and "12" is GPC1 voting against
    # GPC2.  Reading every lit cell as a vote overstates what happened.
    votes = re.findall(r"voting: +(\d)(\d) +ON \(bus\) +\[t=([0-9.]+)\]", cam)
    # THE RUN'S END IS THE DURATION IT WAS GIVEN, and nothing in the log
    # directory records it -- the last t= in cam.log is the VOTE's own stamp,
    # so using that flags every vote as a teardown.  Say nothing unless told.
    end = None
    for i, a in enumerate(sys.argv):
        if a == "--duration" and i + 1 < len(sys.argv):
            end = float(sys.argv[i + 1])
    real = [(r, c, t) for r, c, t in votes if r != c]
    cfs  = [(r, c, t) for r, c, t in votes if r == c]
    def near_end(t):
        # #187: a vote at the teardown is the set noticing a computer being
        # shut down, not a defect.  Only sayable when the duration is known.
        if end is None:
            return ""
        return " (AT TEARDOWN)" if end - float(t) < 5.0 else " (in run)"
    print("votes:    %d%s" % (len(real),
          ("  " + ", ".join("GPC%s->GPC%s@%s%s" % (r, c, t, near_end(t)) for r, c, t in real))
          if real else "  (set held)"))
    if cfs:
        print("commfault:%s" % "".join("  GPC%s@%s" % (r, t) for r, _, t in cfs))

    # THE TIMING UNIT'S OWN COUNTERS, which are not subject to the command
    # trace's budget.
    m = re.findall(r'\{"commands":\d+,"timeReads":\d+[^}]*\}', gpc)
    if m:
        d = json.loads(m[-1])
        print("mtu:      %d reads of %d commands, %d words out, lastTime %s" %
              (d.get("timeReads", 0), d.get("commands", 0),
               d.get("wordsOut", 0), d.get("lastTime", "?")))
    lw = re.search(r"mtu: (\d+) word\(s\) delivered to listening computers", gpc)
    if lw:
        print("listeners:%s words delivered" % lw.group(1))

    # WAS ANYTHING ILLEGAL EXECUTED.  Unprogrammed store shows up here.
    for pat, label in (("BST_I", "illegal BCE opcode"), ("runaway", "runaway BCE")):
        n = gpc.count(pat)
        if n:
            print("warn:     %d %s line(s)" % (n, label))

    # THE BYPASS VERDICT, the one that actually answers #210.
    if snap:
        st = read_slots(snap)
        if not st:
            print("slots:    no gpcN.mem.bin in %s" % snap)
        for g in sorted(st):
            bad = [n for n, s in st[g] if s != "live"]
            print("slots:    GPC%d  %s" % (g, "ALL LIVE -- the unit is being read"
                  if not bad else "BYPASSED: " + " ".join(bad)))
    else:
        print("slots:    (no capture given -- bypass state unknown)")


if __name__ == "__main__":
    main()
