#!/usr/bin/env python3
"""STS-134 FD16 to landing: from SEP3 to the wheels stopped at KSC (Phase 3 of the post-docking plan).

    fly_return.py --logs DIR --from DEORBIT [--to LAND] --tape OI340700-v44boot-sts134-ksc6-rndz2.mmv
                  --targets .../sts134-targets-undock-0320.txt [--rate 1] [--crts 2]

The 42 hours from SEP3 (150/08:38) to the deorbit day carry no event the simulation flies (the FCS
checkout, the RCS hot-fire, RAMBO and the water dumps are not modelled), so they are crossed as the 12
docked days were: undock_coast.py carries the physics (the Orbiter's orbit and the ISS) over the gap,
a fresh PASS is booted at the deorbit day (fly_rndz134.py --start-utc ... --to UPLINK), and
orbit_overlay.py puts the coasted state on it.  That capture, DIR/sts134r-orbit, is where this driver
begins; --from DEORBIT restores it.  The recipe is in ../../../yaGPC2/tools/orbit_overlay.py.

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
    def __init__(self, a):
        # the arguments fly_sts134's own parser gives its phases and fly_rndz134's does not
        for k, v in (("g3_from_mm", False), ("abort", None), ("attach", False)):
            if not hasattr(a, k):
                setattr(a, k, v)
        super().__init__(a)


def main():
    R.Rendezvous = Return
    for ph in ("ORBIT", "DEORBIT", "ENTRY", "LAND"):
        if ph not in R.PHASES:
            R.PHASES.append(ph)
    for a, v in (("--rhc", "both"), ("--station", "all"), ("--input", "virtual")):
        if a not in sys.argv:
            sys.argv += [a, v]
    R.main()


if __name__ == "__main__":
    main()
