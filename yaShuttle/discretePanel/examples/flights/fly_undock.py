#!/usr/bin/env python3
"""STS-134 FD15: the undocking, as the crew flies it from the stack in the undock attitude.

Phase 1 of the post-docking plan (RENDEZVOUS_PLAN / the 2026-10-18 plan "STS-134
after docking").  The starting capture is made by tools/undock_start.py (see its
docstring for the recipe); it is the docked stack at 150/03:19:40, 35 minutes
before the undock, in the VBAR attitude that UNIV PTG TGT ID 2 / BODY VECT 5 /
P 180 / OM 0 holds (tail to the Earth's centre, nose to the zenith, the bay toward
the ISS), and the flight software has its clock but not the navigation state.

    fly_undock.py --logs DIR --from SEPCFG [--to SEPCFG] [--rate 3] [--port-base N]
                  --tape .../OI340700-v44boot-sts134-ksc6-rndz2.mmv
                  --targets .../sts134-targets-undock-0320.txt

DIR holds sts134r-start (the undock_start.py capture, renamed) and the JSON files
beside the other drivers' captures.

PHASES (the STS-134 Rendezvous book, "UNDOCKING / SEPARATION TIMELINE", 2-4 to 2-7):
  START    the capture itself (no work; --from SEPCFG restores it)
  SEPCFG   UNDOCK PET -0:45 to -0:15: MCC UPLINK ORB SV / TGT SV and the RNP epoch;
           CONFIGURE RNDZ NAV FOR SEP [4C] (RNDZ NAV ENA, SV SEL FLTR);
           CONFIGURE FOR SEPARATION [5A] (DAP A12/B12, A/AUTO/VERN, LO Z; the forward
           RCS jets that plume the ISS deselected; UNIV PTG TGT ID 2, BODY VECT 5,
           P 180, Y 0, OM 0, TRK; ORBIT MNVR EXEC with TIG = the undock and the
           Orbiter's weight); the docking mechanism powered up.
Not modelled, so not done: RPOP/TCS/HHL, the STORRM PGSC, the CCTV configuration,
the RJD driver switches O14-O16, the MCC GO calls.
"""
import os
import sys

import dock_autopilot as D       # extends fly_rndz134 with the A7L helpers
import fly_rndz134 as R

UNDOCK_GMT = 150 * 86400 + 3 * 3600 + 55 * 60 + 22          # +Z pulse, Mission Report (03:55:22)
FREE_GMT = 150 * 86400 + 3 * 3600 + 52 * 60 + 28            # ISS FREE / Orbiter FREE (03:52:28)


def sp(n):
    """A number as the keyboard takes it: one key a digit."""
    return " ".join(str(int(n)))


def met_of_gmt(gmt):
    """The mission elapsed time (s) of a GMT (s of the year, the vehicle's form)."""
    return gmt - R.gmt_of_unix(R.MET_ZERO_UNIX)


class Undock(R.Rendezvous):
    # --- helpers --------------------------------------------------------------
    def do(self, name, text, settle=8, dump=None, timeout=180):
        """Play a crew script, wait for its last step and a settle time, and show a page."""
        self.play(text, name)
        self.script_done(name, timeout)
        self.wait_sim(settle)
        if dump:
            return self.dump_screen(dump)
        return ""

    def start(self, resume=None):
        # the start capture is the undock_start.py one: restore it as it is
        return super().start(resume)

    # --- phases ---------------------------------------------------------------
    def sepcfg(self):
        tru = self.truth()
        self.say("SEPCFG: GMT %.1f, the stack %.1f min before the undock" % (tru["gmt"], (UNDOCK_GMT - tru["gmt"]) / 60.0))
        # MCC UPLINK ORB SV, TGT SV [5A] (the RNP epoch first)
        self.uplink()
        self.wait_sim(20)
        # CONFIGURE RNDZ NAV FOR SEP [4C]: RNDZ NAV ENA - ITEM 1 EXEC (*), SV SEL - FLTR
        page = self.do("sep-rndznav", "+1     keys SPEC 3 3 PRO\n+5     keys ITEM 1 EXEC\n", 20, "SPEC 33 after RNDZ NAV ENA")
        if "SV SEL 4 PROP" in page:
            page = self.do("sep-svsel", "+1     keys ITEM 4 EXEC\n", 12, "SPEC 33 after SV SEL")
        self.say("SEPCFG: SV SEL %s" % ("FLTR" if "SV SEL 4 FLTR" in page else "not FLTR: " + page[:0]))
        # CONFIGURE FOR SEPARATION [5A]: DAP config A12, B12
        self.do("sep-dapcfg", "+1     keys SPEC 2 0 PRO\nwait crt 1 title /020/ timeout 120\n"
                              "+3     keys ITEM 1 + 1 2 EXEC\n+3     keys ITEM 2 + 1 2 EXEC\n", 10, "SPEC 20 DAP CONFIG")
        # DAP: A/AUTO/VERN, LO Z (the DAP panel, C3)
        self.do("sep-dap", "+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 vern\n+2     dap c3 low_z\n", 4)
        # [GNC_23_RCS]: RCS F - ITEM 1 EXEC (*), the forward jets that plume the ISS off
        jets = "".join("+3     keys ITEM %s EXEC\n" % " ".join(str(i)) for i in (9, 11, 13, 15, 17, 19, 21))
        self.do("sep-rcs", "+1     keys SPEC 2 3 PRO\nwait crt 1 title /023/ timeout 120\n+3     keys ITEM 1 EXEC\n" + jets,
                10, "SPEC 23 RCS, the forward jets deselected")
        # [GNC_UNIV_PTG]: TGT ID +2, BODY VECT +5, P +180, Y +0, OM +0, ERR TOT, TRK
        self.do("sep-univptg", "+1     keys RESUME\n"
                               "+3     keys ITEM 8 + 2 EXEC\n"
                               "+3     keys ITEM 1 4 + 5 EXEC\n"
                               "+3     keys ITEM 1 5 + 1 8 0 EXEC\n"
                               "+3     keys ITEM 1 6 + 0 EXEC\n"
                               "+3     keys ITEM 1 7 + 0 EXEC\n"
                               "+3     keys ITEM 2 3 EXEC\n"
                               "+3     keys ITEM 1 9 EXEC\n", 15, "UNIV PTG")
        c = self.compare() or {}
        self.say("SEPCFG: DAP attitude error %s, PASS attitude vs the truth %s" % (c.get("dap_att_err"), c.get("pass_att_err_deg")))
        # ORBIT MNVR EXEC [5A]: TIG = the undock, any non-zero delta-V, the Orbiter's weight
        wt = self.orbiter_lb()
        met = met_of_gmt(UNDOCK_GMT)
        d, h, m, s = R.dhms_f(met)
        self.do("sep-mnvr", "+1     keys OPS 2 0 2 PRO\nwait crt 1 title 2021/ timeout 180\n"
                            "+3     keys RESUME\nwait crt 1 title MNVR EXEC timeout 60\n"
                            "+4     keys ITEM 9 + %s EXEC\n"
                            "+4     keys ITEM 1 0 + %s + %s + %s + %s EXEC\n"
                            "+4     keys ITEM 1 9 + 1 EXEC\n"
                            "+4     keys ITEM 2 2 EXEC\n"
                            "+4     keys ITEM 2 3 EXEC\n"
                            % (sp(round(wt)), sp(d), sp(h), sp(m), sp(round(s))), 10, "ORBIT MNVR EXEC loaded", timeout=300)
        self.do("sep-ops201", "+1     keys OPS 2 0 1 PRO\nwait crt 1 title 2011/ timeout 180\n", 10, "back in OPS 201")
        # DOCKING MECHANISM POWERUP (APDS)
        D.a7l(self, "power_on", tag="sep-apds-power")
        self.wait_sim(5)
        self.say("SEPCFG: A7L lights %s" % (D.a7l_lights(self),))
        self.say("SEPCFG done: UNDOCK GMT %d (MET %03d/%02d:%02d:%02d), Orbiter weight %d lb"
                 % (UNDOCK_GMT, d, h, m, s, round(wt)))


def main():
    R.Rendezvous = Undock
    R.PHASES.extend(["START", "SEPCFG"])      # after dock_autopilot's DOCK30, DOCK, STAY
    for a, v in (("--rhc", "aft"), ("--station", "aft"), ("--input", "virtual")):
        if a not in sys.argv:
            sys.argv += [a, v]
    R.main()


if __name__ == "__main__":
    main()
