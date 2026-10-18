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
        """fly_sts134's DEORBIT, then a check that the burn happened: the perigee of the truth's orbit under
        EI's altitude.  Without it a burn that never fired (c1/r1, 2026-10-18: the forward RCS empty, no
        maneuver to the burn attitude, the OMS burning 13 s of 159) went on into ENTRY and LAND, which ran
        out of time 335 km up."""
        tru0 = self.ears.snap()[0]
        prop0 = self.vehdyn_props()
        super().deorbit()
        tru = self.ears.snap()[0]
        r, v = [x * 0.3048 for x in tru["r"]], [x * 0.3048 for x in tru["v"]]
        rn = sum(x * x for x in r) ** 0.5
        vn2 = sum(x * x for x in v)
        mu = 3.986004418e14
        a = 1.0 / (2.0 / rn - vn2 / mu)
        h = [r[1] * v[2] - r[2] * v[1], r[2] * v[0] - r[0] * v[2], r[0] * v[1] - r[1] * v[0]]
        hn2 = sum(x * x for x in h)
        e = max(0.0, 1.0 - hn2 / (mu * a)) ** 0.5
        perigee_km = (a * (1.0 - e) - 6378137.0) / 1000.0
        self.say("DEORBIT: after the burn the truth's perigee is %.0f km (EI is at 122 km); OMS used %s lb"
                 % (perigee_km, [round((p0 - p1) / 0.45359237) for p0, p1 in zip(prop0[3:5], self.vehdyn_props()[3:5])]))
        if perigee_km > 110.0:
            raise SystemExit("fly_return: the deorbit burn did not happen (perigee %.0f km) -- stopping before ENTRY and LAND; "
                             "check the forward RCS (%s kg) and the OMS" % (perigee_km, [round(x) for x in self.vehdyn_props()[:3]]))

    def vehdyn_props(self):
        """The newest vehdyn-state line's tanks are not logged; the truth's: the log's 'RCS propellant F/L/R ... OMS L/R'."""
        import re
        txt = self.log_text()
        m = None
        for m in re.finditer(r"RCS propellant F/L/R ([\d.]+)/([\d.]+)/([\d.]+) kg; OMS L/R ([\d.]+)/([\d.]+) kg", txt):
            pass
        return [float(x) for x in m.groups()] if m else [0.0] * 5

    def __init__(self, a):
        # the arguments fly_sts134's own parser gives its phases and fly_rndz134's does not
        for k, v in (("g3_from_mm", False), ("abort", None), ("attach", False), ("incorporate_at_land", False),
                     ("land_time", 900.0)):
            if not hasattr(a, k):
                setattr(a, k, v)
        super().__init__(a)


def main():
    R.Rendezvous = Return
    for ph in ("READY", "ORBIT", "DEORBIT", "ENTRY", "LAND"):
        if ph not in R.PHASES:
            R.PHASES.append(ph)
    for a, v in (("--rhc", "both"), ("--station", "all"), ("--input", "virtual")):
        if a not in sys.argv:
            sys.argv += [a, v]
    R.main()


if __name__ == "__main__":
    main()
