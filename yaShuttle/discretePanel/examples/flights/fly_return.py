#!/usr/bin/env python3
"""STS-134 FD16 to landing: from SEP3 to the wheels stopped at KSC (Phase 3 of the post-docking plan).

    fly_return.py --logs DIR --from DEORBIT [--to LAND] --tape OI340700-v44boot-sts134-ksc6-rndz2.mmv
                  --targets .../sts134-targets-undock-0320.txt [--rate 1] [--crts 2]

The 42 hours from SEP3 (150/08:38) to the deorbit day carry no event the simulation flies (the FCS
checkout, the RCS hot-fire, RAMBO and the water dumps are not modelled), so they are crossed as the 12
docked days were: undock_coast.py carries the physics (the Orbiter's orbit and the ISS) over the gap,
a fresh PASS is booted at the deorbit day (fly_rndz134.py --start-utc ... --to UPLINK), and
orbit_overlay.py puts the coasted state on it.  That capture, DIR/sts134r-orbit, is where this driver
begins as READY; --from ORBIT restores it, uplinks the new orbit's state vectors and captures sts134r-orbit,
which --from DEORBIT restores.  The recipe is in ../../../yaGPC2/tools/orbit_overlay.py.

PHASES, fly_sts134's own, unchanged -- the Entry Checklist as that driver flies it:
  DEORBIT  the ground's targets for the first KSC 15 opportunity (deorbit_target.py from the ORBIT
           capture), single-G3 and OPS 301 at TIG-75, the DEORB MNVR targets, OPS 302, the burn, OPS 303
  ENTRY    OPS 304 at EI-5 and PASS flying to about TAEM
  LAND     TAEM, the approach and landing, the gear and the chute, the wheels stopped
The real deorbit burn was 152/05:29:03 (Mission Report); EI about 06:03, wheels stop 06:35:33.
Run with YAGPC_NAVAIDS=.../ksc-navaids.txt for the landing aids.
"""
import json
import os
import sys

import fly_sts134
import fly_undock as U
import fly_rndz134 as R


class Return(U.Undock):
    def ready(self):
        """The overlaid capture itself (make_return_start.py); nothing to do."""

    def orbit(self):
        """MCC UPLINK ORB SV and the RNP epoch for the new orbit -- the fresh flight software's navigation state is
        the boot's, not the Orbiter's -- and the minutes for the filter to settle; then the capture, which is
        where DEORBIT starts.  (fly_sts134's ORBIT is one orbit of coasting, not needed here.)"""
        self.uplink()
        self.wait_sim(120)
        c = self.compare() or {}
        self.say("ORBIT: after the uplinks: PASS orbiter error %s ft, attitude vs the truth %s deg"
                 % (c.get("orb_err_ft"), c.get("pass_att_err_deg")))
        self.dump_screen("OPS 201 after the uplinks")

    def deorbit(self):
        """fly_sts134's DEORBIT, with the DAP set on BOTH panels first, then a check that the burn happened.

        The DAP: the maneuver to burn attitude never started in r2 (the DAP attitude error stayed -59 deg for the
        20 minutes before TIG): the script presses only C3's AUTO, and the DAP the fresh boot's panels leave is
        one the aft station's A6U also has a say in -- so A/AUTO/PRI on both.
        The check: the perigee of the truth's orbit under EI's altitude, without which a burn that never fired went
        on into ENTRY and LAND, which ran out of time 335 km up (c1/r1/r2, 2026-10-18)."""
        self.dap_both(("a", "auto", "pri"), "ret-dap")
        super().deorbit()
        self.check_burn()

    def key_weight(self):
        """DEORB MNVR EXEC's WT (ITEM 9), then LOAD (22) and TIMER (23) again.  The page showed WT 0 at TIG-20 min on a
        fresh boot (r2, 2026-10-18) and PASS never started the maneuver; the ascent-run flows had the weight from the
        OMS 2 burn's display.  The crew's DEL PAD has it."""
        wt = self.orbiter_lb()
        self.say("DEORBIT: WT %d lb keyed (the display had 0)" % round(wt))
        self.play("+1     keys ITEM 9 + %s EXEC\n+4     keys ITEM 2 2 EXEC\n+4     keys ITEM 2 3 EXEC\n" % U.sp(round(wt)), "deorb-wt")
        self.script_done("deorb-wt", 120)
        self.wait_sim(6)

    def burn(self):
        """DEORBIT from the pre-mnvr capture (--from BURN): the sequence's tail, for iterating on the burn without the
        65 minutes before it."""
        t = json.load(open(os.path.join(self.a.logs, "deorbit-targets.json")))
        self.tgt = t
        tig = t["tig"]
        self.dap_both(("a", "auto", "pri"), "ret-dap2")
        self.key_weight()
        self.deorbit_hook("pre-mnvr-b")
        self.play(fly_sts134.DEORB_MNVR, "deorb-mnvr")
        self.script_done("deorb-mnvr", 120)
        self.deorbit_hook("post-mnvr")
        self.wait_gmt(tig - 15.0)
        self.play("+0     keys EXEC\n", "deorb-exec")
        self.say("crew: EXEC at TIG-15 s (TIG GMT %.1f)" % tig)
        self.wait_gmt(tig + 6 * 60.0)
        self.play("+1     keys OPS 3 0 3 PRO\nwait crt 1 title 3031/ timeout 120\n+3     keys ITEM 2 7 EXEC\n", "ops303")
        self.script_done("ops303", 180)
        self.say("crew: OPS 303, MNVR to EI attitude")
        self.check_burn()

    def check_burn(self):
        tru = self.ears.snap()[0]
        r, v = list(tru["r"]), list(tru["v"])
        rn = sum(x * x for x in r) ** 0.5
        mu = 3.986004418e14
        a = 1.0 / (2.0 / rn - sum(x * x for x in v) / mu)
        h = [r[1] * v[2] - r[2] * v[1], r[2] * v[0] - r[0] * v[2], r[0] * v[1] - r[1] * v[0]]
        e = max(0.0, 1.0 - sum(x * x for x in h) / (mu * a)) ** 0.5
        perigee_km = (a * (1.0 - e) - 6378137.0) / 1000.0
        self.say("DEORBIT: after the burn the truth's orbit is %.0f km x %.0f km (EI is at 122 km)"
                 % ((a * (1.0 + e) - 6378137.0) / 1000.0, perigee_km))
        if perigee_km > 110.0:
            raise SystemExit("fly_return: the deorbit burn did not happen (perigee %.0f km) -- stopping before ENTRY and LAND; "
                             "check the DAP (the attitude error), the forward RCS and the OMS" % perigee_km)

    def deorbit_hook(self, where):
        """The page and the DAP at the points of the sequence where the maneuver should start (r2: it never did)."""
        if where == "pre-mnvr":
            self.snapshot("pre-mnvr")
            self.key_weight()
        self.wait_sim(4)
        self.dump_screen("deorbit %s" % where)
        c = self.compare() or {}
        self.say("DEORBIT %s: DAP attitude error %s, %s" % (where, c.get("dap_att_err"), c.get("dap_state")))

    def __init__(self, a):
        # the arguments fly_sts134's own parser gives its phases and fly_rndz134's does not
        for k, v in (("g3_from_mm", False), ("abort", None), ("attach", False), ("incorporate_at_land", False),
                     ("land_time", 900.0)):
            if not hasattr(a, k):
                setattr(a, k, v)
        super().__init__(a)


def main():
    R.Rendezvous = Return
    setattr(Return, "pre-mnvr", lambda self: None)       # the capture --from BURN restores
    for ph in ("READY", "ORBIT", "DEORBIT", "ENTRY", "LAND", "PRE-MNVR", "BURN"):
        if ph not in R.PHASES:
            R.PHASES.append(ph)
    for a, v in (("--rhc", "both"), ("--station", "all"), ("--input", "virtual")):
        if a not in sys.argv:
            sys.argv += [a, v]
    R.main()


if __name__ == "__main__":
    main()
