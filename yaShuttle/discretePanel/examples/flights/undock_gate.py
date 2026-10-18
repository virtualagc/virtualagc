#!/usr/bin/env python3
"""The undocking start-state gate (RENDEZVOUS/undock plan, Phase 0).

Restores LOGS/sts134r-dock -- an undock_start.py capture, the docked stack at
150/03:52 -- sends PASS the ground's uplinks (RNP epoch, Orbiter and target state
vectors), shows what the flight software makes of the new time and state, then
STAYs.  Usage as dock_autopilot.py, with --from GATE.
"""
import sys
import time

import dock_autopilot            # noqa: F401  (extends fly_rndz134 with DOCK30, DOCK, STAY)
import fly_rndz134 as R


def gate(self):
    tru = self.truth()
    self.say("GATE: truth GMT %.1f, restored at the undocking start" % tru["gmt"])
    for name, keys in (("gate-spec2", "SPEC 2 PRO"),):
        self.play("+1     keys %s\n" % keys, name)
        self.script_done(name, 60)
        self.wait_sim(8)
        self.dump_screen(keys)
    self.uplink()
    self.wait_sim(60)
    self.say("GATE: after the uplinks: %s" % self.compare())
    self.dump_screen("after the uplinks")
    # CONFIGURE RNDZ NAV FOR SEP (Rendezvous book, Undocking/Separation Timeline): RNDZ NAV ENA
    self.play("+1     keys SPEC 3 3 PRO\n+5     keys ITEM 1 EXEC\n", "gate-rndznav")
    self.script_done("gate-rndznav", 120)
    self.wait_sim(60)
    self.dump_screen("SPEC 33 after RNDZ NAV ENA")
    c = self.compare() or {}
    self.say("GATE: after RNDZ NAV ENA: tgt_err %.0f ft, orb_err %.1f ft, pass_rng %s truth %s" % (
        c.get("tgt_err_ft", -1), c.get("orb_err_ft", -1), c.get("pass_rng_ft"), c.get("true_rng_ft")))
    self.stay()


R.Rendezvous.gate = gate
R.PHASES.insert(R.PHASES.index("STAY"), "GATE")

if __name__ == "__main__":
    for a in ("--rhc", "--station", "--input"):
        pass
    if "--rhc" not in sys.argv:
        sys.argv += ["--rhc", "aft"]
    if "--station" not in sys.argv:
        sys.argv += ["--station", "aft"]
    if "--input" not in sys.argv:
        sys.argv += ["--input", "virtual"]
    R.main()
