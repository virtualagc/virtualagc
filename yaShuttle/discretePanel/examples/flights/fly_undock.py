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
  UNDOCK   UNDOCK PET -3:00 to +10 min: DAP FREE at the Orbiter FREE time (03:52:28), DAP B/FREE/ALT, NORM Z;
           APDS CIRC PROT OFF and UNDOCKING at the hook-drive command (03:53:08): the hooks open in 2:07
           (vehdyn's undocking model), HOOKS 1/2 OPEN and UNDOCK COMPLETE; the +Z pulse at 03:55:22 and the
           book's +Z pulses every 10 s to RDOT 0.2 ft/s; coast to 150 ft.  Ends in sts134r-undock.
Not modelled, so not done: RPOP/TCS/HHL, the STORRM PGSC, the CCTV configuration,
the RJD driver switches O14-O16, the MCC GO calls.
"""
import os
import sys

import json
import math

import numpy as np

import dock_autopilot as D       # extends fly_rndz134 with the A7L helpers
import fly_rndz134 as R
import rerndz as RR
import rndz_instruments as ins

FLOWN_BURNS = bool(os.environ.get("UNDOCK_FLOWN_BURNS"))      # UNDOCK_FLOWN_BURNS=1: NH2 -1.8 0 0 and MC5 0.1 0 0.5 ft/s as flown (History ch. 21), from the run's own state; NSR, TPI computed
FLOWN = bool(os.environ.get("UNDOCK_FLOWN"))      # UNDOCK_FLOWN=1: SEP2/NH2 as flown open-loop (rerndz.py) -- tried 2026-10-19, NH2 came out 10,000 ft off and MC5 asked 8.4 ft/s: the flown values were targeted from the real state, not ours; default: the CW designs of c1/c2
# THE FLY-AROUND'S RADIUS: the Rendezvous book gives 650 ft (+-50) CG-CG from the +V-bar at 04:20:00, but Figure 21.1's curve from
# SEP1 is, to a Clohessy-Wiltshire fit (11 points read off the figure, 81 ft rms, 2026-10-19), a trajectory that starts at x +836 ft,
# z -56 ft with xdot -0.03, zdot -3.2 ft/s up: a circle of ~800 ft turning at the 1.98 n rate (1.9 ft/s) plus the 1.5 ft/s SEP1.  The
# circle therefore opens from the book's 650 ft to 820 ft over its revolution, so that it ends where the figure's curve begins.  The
# fit is of a drawn curve and good to ~100 ft; the book's 650 is the planned radius, the figure's the reference trajectory.  Ledger #316.
# The documented profile (Stuit, AIAA STORRM DTO paper, p. 12 and Fig. 10; JSC-49686 sec. 6.17 p. 114): separate to 450 +-50 ft ahead, begin the
# fly-around there, open to 650 +-50 ft in the first ~100 deg of the lap and hold it; SEP1 at 650 ft.  (UNDOCK_FA_RHO0/RHO1/OPEN_DEG override;
# the 650 -> 820 spiral above was a fit to Figure 21.1 and is not documented -- UNDOCK_FA_RHO0=650 UNDOCK_FA_RHO1=820 restores it, but then
# UNDOCK_FA_OPEN_DEG=360.)
FA_RHO0 = float(os.environ.get("UNDOCK_FA_RHO0", "450"))
FA_RHO1 = float(os.environ.get("UNDOCK_FA_RHO1", "650"))
FA_OPEN = math.radians(float(os.environ.get("UNDOCK_FA_OPEN_DEG", "100")))
# UNDOCK_NO_VERN=1: the book's substitutes for the vernier DAP everywhere the checklist says VERN(...) (RNDZ failure/response summary, p. 1-4,
# "Loss of VRCS"): A/AUTO/PRI in place of VERN(PRI) -- the fly-around [9A] and SEP1 [8C] -- and A/AUTO/ALT in place of VERN(ALT) -- the
# track [11A] and the track holds after every burn, the undock/sep and the approach outside 2,000 ft; inside 2,000 ft (TDA) PRI again.
NO_VERN = bool(os.environ.get("UNDOCK_NO_VERN"))
SEP1_JETS = os.environ.get("UNDOCK_SEP1_JETS", "1") not in ("0", "")     # DEFAULT ON since 2026-10-22: SEP1 as the Mission Report flew it (UNDOCK_SEP1_JETS=0: the old planned-1.5 burn)
DAP62 = os.environ.get("UNDOCK_DAP62", "1") not in ("0", "")             # DEFAULT ON since 2026-10-22: the tape's generic A9/B9 and A7/B7 made p. 6-2's (dap_to_62 / dap_config)
os.environ.setdefault("YAGPC_VEHDYN_JET_DELAY_MS", "15")           # DEFAULT 15 since 2026-10-22: the 15 ms tail-on/tail-off transient of every RCS firing (JSC-10511 Rev B p. 7-2)      # SEP1 as flown: 6.48 s of L1A+R1A (1.67 up, 0.30 ahead) instead of the planned 1.5 ft/s radial up with the circle's trim
SEP1_VERN = bool(os.environ.get("UNDOCK_SEP1_VERN"))      # with NO_VERN: the checklist's A/AUTO/VERN after SEP1 [8C] and for the SEP2 track [11A] (f21); every other leg keeps the substitutes
FA_P_LEAD = float(os.environ.get("UNDOCK_FA_P_LEAD", "60"))     # (UNDOCK_FA_P_LEAD)           # deg of the circle: the next quarter turn starts 14 deg after the crossing (45 less half of the 62 deg the turn lasts)
HOOK_GMT = 150 * 86400 + 3 * 3600 + 53 * 60 + 8             # the hook-drive command (Mission Report)
UNDOCK_GMT = 150 * 86400 + 3 * 3600 + 55 * 60 + 22          # +Z pulse, Mission Report (03:55:22)
FREE_GMT = 150 * 86400 + 3 * 3600 + 52 * 60 + 28            # ISS FREE / Orbiter FREE (03:52:28)


def sp(n):
    """A number as the keyboard takes it: one key a digit."""
    return " ".join(str(int(n)))


def met_of_gmt(gmt):
    """The mission elapsed time (s) of a GMT (s of the year, the vehicle's form)."""
    return gmt - R.gmt_of_unix(R.MET_ZERO_UNIX)


D.A7L_LIGHT.update({"HOOKS 1 OPEN": (0, 0x0400), "HOOKS 2 OPEN": (0, 0x0200), "UNDOCK COMPLETE": (0, 0x0080),
                    "APDS PROTECT CIRCUIT OFF": (0, 0x4000)})


class Undock(R.Rendezvous):
    ku_low = True        # the Ku RADAR OUTPUT LOW switch is NOT thrown by rr_watch_output's thread (it fires the moment range < 700 ft -- at SEP1's ~640 ft that is
                         # mid-keying, and its script REPLACED the DAP keying: f36a, f38a, f38c died at 'dap a6u z_norm' never appeared); sep1() throws it first, in order
    # The re-rendezvous' -Z AXIS TARGET TRACK [11A] (book p. 2-11, PDF p. 43) is DAP A/AUTO/VERN(ALT), not [12A]'s B/AUTO/ALT that the
    # rendezvous phase's TRACK_KEYS has: the B/ALT primaries left ~0.2 ft/s of net translation when the maneuver stopped
    # (f6, GMT 12978870: a step of -0.21 ft/s in RDOT; SEP2's solution then needed a -0.9 ft/s radial part).  Ledger #316.
    TRACK_KEYS = ("+3     keys ITEM 2 1 EXEC\n"
                  "+3     keys ITEM 8 + 1 EXEC\n"
                  "+3     keys ITEM 1 4 + 3 EXEC\n"
                  "+3     keys ITEM 1 7 + 0 EXEC\n"
                  "+3     dap c3 a\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 %s\n"
                  "+3     keys ITEM 1 9 EXEC\n") % os.environ.get("UNDOCK_TRACK_JETS", "alt" if NO_VERN else "vern")      # UNDOCK_TRACK_JETS=alt|pri: the experiment (f12, f13)

    def ops201_track(self, name, limit=1200.0):
        """UNDOCK_TRACK_ONCE=1: the -Z AXIS TARGET TRACK [11A] is keyed ONCE, at SEP2 -00:20 (the re-rendezvous timeline has it nowhere else: pages 2-10 to 2-26);
        the base class re-keys it (OPS 201, UNIV PTG items, TRK) after every burn and again before each burn.  After a burn the book's cards go OPS 201 PRO and
        the DAP back to A/AUTO/VERN, nothing more, so with the option only that is keyed and no track maneuver is restarted."""
        if os.environ.get("UNDOCK_TRACK_ONCE") and getattr(self, "_track_keyed", False):
            dap = "".join(l + "\n" for l in self.TRACK_KEYS.splitlines() if "dap c3" in l)
            self.play("+1     keys OPS 2 0 1 PRO\nwait crt 1 title 2011/ timeout 180\n" + dap, name)
            self.script_done(name, 300)
            self.say("crew: OPS 201 and the DAP back to VERN; the -Z track is already on ([11A] is performed once)")
            return
        self._track_keyed = True
        return super().ops201_track(name, limit)

    def track_complete(self, name, limit=1200.0):
        """The base class ends the track maneuver with DAP A/AUTO/VERN; with UNDOCK_NO_VERN the hold is A/AUTO/ALT ([11A]'s
        VERN(ALT) with its substitute).  (The base class's log line still says VERN.)"""
        if not NO_VERN or (SEP1_VERN and name.startswith("sep2")):
            return super().track_complete(name, limit)
        orig = self.play
        self.play = lambda text, nm, *a, **k: orig(text.replace("dap c3 vern", "dap c3 alt"), nm, *a, **k)
        try:
            return super().track_complete(name, limit)
        finally:
            del self.play

    def press_jets(self, opt, name):
        """DAP A/AUTO/<opt> on C3 (NO_VERN's substitutes where dock_autopilot's dap_modes presses VERN)."""
        self.do(name, "+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 %s\n" % opt, 2)

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
        D.dap_modes(self, "a", True)
        # [GNC_23_RCS]: RCS F - ITEM 1 EXEC (*), the forward jets that plume the ISS off
        # The book's step is "JET DES F1L ... F2U - ITEMs 9-21 EXEC (no *)": the mated attitude control's deselected jets
        # (the same page, "(*)") are put back, so the forward jets are AVAILABLE at the undock.  The start capture has them
        # all selected already (PASS: FWD mask FFFF), so there is nothing to key; the earlier version keyed the items and
        # DESELECTED them (mask 9979, then BB7B after the up jets were put back), leaving F1L F3L F2R F4R out through the
        # fly-around and the re-rendezvous and the DAP's rotations with net force (ledger #316).
        self.do("sep-rcs", "+1     keys SPEC 2 3 PRO\nwait crt 1 title /023/ timeout 120\n+3     keys ITEM 1 EXEC\n",
                10, "SPEC 23 RCS F selected, the forward jets as they are (all available)")
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


    def thc_pulse(self, ax, sgn, n=1, gap=10.0, name="und-pulse"):
        """n THC pulses on the aft THC along body axis ax (x, y, z), sign sgn, gap seconds apart."""
        st_ax, pos = D.AFT_STICK[ax]
        neg = "+" if pos == "-" else "-"
        stick = (pos if sgn > 0 else neg) + st_ax
        text = "".join("+%s   thc aft %s 0.30\n" % ("1.0" if i == 0 else "%.1f" % gap, stick) for i in range(n))
        self.play(text, name)
        self.script_done(name, 60 + n * (gap + 2))

    def rng(self):
        """The CG-CG range (ft) and range rate (ft/s) from the truth's relative state (rel(): the two feeds
        at one instant, a dropped-sample guard)."""
        s = self.lvlh_state()
        r = float(np.linalg.norm(s[:3]))
        return r, float(np.dot(s[:3], s[3:]) / max(r, 1e-6))

    def undock(self):
        self.say("UNDOCK: GMT %.1f; FREE drift at %d, hook drive at %d, the +Z pulse at %d"
                 % (self.truth()["gmt"], FREE_GMT, HOOK_GMT, UNDOCK_GMT))
        if DAP62:
            # the stored A9 / B9 made 6-2's NOW (the edit takes ~8 min of vehicle time), the stack back on A12/B12 until the book's A9/B9 at PET -3:00
            self.dap_to_62(9, self.DAP_PROX, "A9B9-undock")
            self.do("und-dap12", "+1     keys SPEC 2 0 PRO\nwait crt 1 title /020/ timeout 120\n"
                                 "+3     keys ITEM 1 + 1 2 EXEC\n+3     keys ITEM 2 + 1 2 EXEC\n+3     keys RESUME\n", 6, "SPEC 20, back on A12 B12")
        # [GNC_20] Config DAP A,B to A9,B9 -- UNDOCK PET -3:00 (the book), before the FREE drift
        self.wait_gmt(FREE_GMT - 150)
        self.do("und-dap9", "+1     keys SPEC 2 0 PRO\nwait crt 1 title /020/ timeout 120\n"
                            "+3     keys ITEM 1 + 9 EXEC\n+3     keys ITEM 2 + 9 EXEC\n", 10, "SPEC 20, DAP A9 B9")
        self.do("und-resume", "+1     keys RESUME\n", 4)
        # UNDOCKING OPERATIONS [6A] step 1, "When MCC-H and ISS issue GO for Undocking": ORB TO TGT -- the
        # docked pair is one point, and PASS's two propagated states had drifted apart (0.65 ft/s by now)
        self.wait_gmt(FREE_GMT - 60)
        self.do("und-orb2tgt", "+1     keys SPEC 3 3 PRO\n+4     keys ITEM 1 0 EXEC\n", 10, "SPEC 33 after ORB TO TGT")
        self.do("und-resume2", "+1     keys RESUME\n", 4)
        # DAP: B/FREE/ALT, NO LO Z, PULSE/PULSE/PULSE -- both stations in FREE drift (03:52:28)
        self.wait_gmt(FREE_GMT - 45)          # the DAP buttons take ~25 s of script and lamp checks
        D.dap_modes(self, "b", False)
        self.do("und-free", "+1     dap c3 free\n+2     dap c3 alt\n", 4)
        r, rd = self.rng()
        self.say("UNDOCK: DAP B/FREE/ALT at GMT %.0f, range %s ft" % (self.truth()["gmt"], r))
        # COMMAND UNDOCKING: APDS CIRC PROT OFF, then UNDOCKING (hook drive at 03:53:08)
        self.wait_gmt(HOOK_GMT - 6)
        D.a7l(self, "circ_prot_off", "undocking", tag="und-apds")
        t_cmd = self.truth()["gmt"]
        self.say("UNDOCK: UNDOCKING pb pressed, GMT %.0f (the command acts a second after the press)" % t_cmd)
        ok = D.a7l_wait(self, "UNDOCK COMPLETE", limit=240, label="the hooks opening")
        t_done = self.truth()["gmt"]
        lit = D.a7l_lights(self)
        self.say("UNDOCK: UNDOCK COMPLETE %s at GMT %.0f (%.0f s after the command, the MR drive 127 s); lights: %s"
                 % ("lit" if ok else "NEVER LIT", t_done, t_done - t_cmd, ", ".join(sorted(lit)) if lit else "?"))
        # the +Z pulse at 03:55:22
        self.wait_gmt(UNDOCK_GMT - 1)
        self.thc_pulse("z", +1, 1, name="und-pulse-1")
        self.wait_sim(3)
        r, rd = self.rng()
        self.say("UNDOCK: the +Z pulse at GMT %.0f: range %s ft rdot %s ft/s" % (self.truth()["gmt"], r, rd))
        # physical separation +1:00 and on: DAP A/VERN? the book's +Z pulses every 10 s to RDOT > 0.2 ft/s
        self.wait_gmt(UNDOCK_GMT + 60)
        # the book's +Z (out) pulses to RDOT > 0.2 ft/s: the DAP's pulses come out at ~0.04 ft/s here (the jets'
        # 0.16 s for the 0.10 ft/s the page says), so the speed is flown as a THC hold along the port's axis (+x)
        self.reselect_fwd_up_jets()
        s = self.lvlh_state()
        self.thc_burn((0.35 - s[3], 0.0, 0.0), "und-sep")
        r, rd = self.rng()
        self.say("UNDOCK: separating at RDOT %s ft/s, range %s ft" % (rd, r))
        t0 = self.truth()["t"]
        while (self.rng()[0] or 0) < 150.0 and self.truth()["t"] - t0 < 1800:
            self.wait_sim(20)
        r, rd = self.rng()
        self.say("UNDOCK done: range %s ft, RDOT %s ft/s at GMT %.0f" % (r, rd, self.truth()["gmt"]))


    # ------------------------------------------------------------------------------------------------
    # THE LEGS AFTER THE UNDOCKING: fly-around, SEP1, SEP2 (this file), then the re-rendezvous
    # ------------------------------------------------------------------------------------------------
    def deselect_fwd_jets(self):
        """[5A] CONFIGURE FOR SEPARATION, as the book has it: SPEC 23, JET DES F1L F3L F2R F4R F1U F3U F2U -- ITEMs 9-21 EXEC (no *), i.e. the seven
        forward jets that plume the ISS DESELECTED (the same items with (*) on the return-to-flight-plan page put them back).  UNDOCK_FWD_DESELECT=1
        (f27): the capture has them all selected (FWD mask FFFF); this toggles them out at the start of the fly-around, and they stay out."""
        if not os.environ.get("UNDOCK_FWD_DESELECT") or getattr(self, "_fwd_out", False):
            return
        keys = "".join("+3     keys ITEM %s EXEC\n" % " ".join(str(i)) for i in (9, 11, 13, 15, 17, 19, 21))
        self.do("fa-fwd-out", "+1     keys SPEC 2 3 PRO\nwait crt 1 title /023/ timeout 120\n" + keys + "+4     keys RESUME\n", 8,
                "SPEC 23: F1L F3L F2R F4R F1U F3U F2U deselected")
        self._fwd_out = True

    def restore_fwd_jets(self):
        """The same seven items again (SPEC 23, ITEMs 9-21 EXEC) put the forward jets back after the SEP1-to-SEP2 leg (UNDOCK_FWD_RESTORE=1; f28):
        the unbalanced forward firings were only a problem on that leg, the later legs ran fine with them selected."""
        if not (os.environ.get("UNDOCK_FWD_DESELECT") and os.environ.get("UNDOCK_FWD_RESTORE")) or not getattr(self, "_fwd_out", False):
            return
        keys = "".join("+3     keys ITEM %s EXEC\n" % " ".join(str(i)) for i in (9, 11, 13, 15, 17, 19, 21))
        self.do("sep2-fwd-in", "+1     keys SPEC 2 3 PRO\nwait crt 1 title /023/ timeout 120\n" + keys + "+4     keys RESUME\n", 8,
                "SPEC 23: F1L F3L F2R F4R F1U F3U F2U selected again")
        self._fwd_out = False

    def reselect_fwd_up_jets(self):
        """SPEC 23: F1U, F3U and F2U back in (ITEMs 17, 19, 21).  SEPCFG deselects them as the book does, to keep
        their plumes off the ISS; with them out the DAP's +Z translation (the pulses and THC holds along the
        port's axis, 'out') fires only the aft up jets, the pitching moment is taken out with the down jets,
        and the Orbiter gets a tenth of the delta-V.  The simulation has no plume, so they go back in (a
        deviation, logged)."""
        if getattr(self, "_fwd_up_in", False) or not os.environ.get("UNDOCK_DESELECT_JETS"):
            return          # SEPCFG leaves the forward jets selected now (ledger #316); UNDOCK_DESELECT_JETS=1: the old keying
        self.do("fa-jets", "+1     keys SPEC 2 3 PRO\nwait crt 1 title /023/ timeout 120\n"
                           "+3     keys ITEM 1 7 EXEC\n+3     keys ITEM 1 9 EXEC\n+3     keys ITEM 2 1 EXEC\n"
                           "+4     keys RESUME\n", 8, "SPEC 23, F1U F3U F2U reselected")
        self._fwd_up_in = True

    def lvlh_state(self):
        """The Orbiter's centre of mass against the ISS: (x, y, z, xdot, ydot, zdot) in ft, ft/s, LVLH
        (x ahead, y right, z down), the rotating frame's rates (rndz_manual.rel)."""
        r = self.rel("cg", noisy=False)
        return np.array(list(r["r"]) + list(r["v"]))

    def body_axes_lvlh(self):
        """The truth's attitude: (LVLH axes, q)."""
        tru, tgt = self.feeds()
        ex, ey, ez = ins.lvlh_axes(list(tgt["r"]), list(tgt["v"]))
        return (ex, ey, ez), tru["q"]

    def p_for(self, x, z, current=None):
        """UNIV PTG's P (BODY VECT 5, TGT ID 2) for the fly-around's next quarter turn: P 180 for the ISS behind, 90
        below, 0 ahead, 270 above (the book's P 180 +VBAR, 90 -RBAR, 0 -VBAR, 270 +RBAR).  The quarter turn is
        flown at the DAP's vernier rate, 0.19 deg/s (f8: the error fell 28 deg in 446 s), which takes 474 s,
        62 deg of the circle, so it is started FA_P_LEAD deg of the circle after the crossing -- the turn then
        straddles the quadrant and the bay stays within ~15 deg of the ISS (the book's +-15 deg vertical on the
        centreline camera, [9A] 1).  f8 changed P at the quadrant's end (53 deg after the crossing) and the bay
        was 22 to 53 deg off for the whole revolution."""
        ang = (math.degrees(math.atan2(-z, -x)) - FA_P_LEAD) % 360.0   # the ISS's direction from the Orbiter, +x toward +z(down), less the lead
        want = {180: 180.0, 90: 90.0, 0: 0.0, 270: 270.0}
        def dist(p):
            d = abs((ang - want[p] + 180.0) % 360.0 - 180.0)
            return d
        best = min(want, key=dist)
        if getattr(self, "_p90_at_done", False):
            return 90                   # the settled P 90 stays: no further stepping before the burn
        if os.environ.get("UNDOCK_FA_NO_P90") and best == 90 and current is not None:
            return current              # the burn is done "in +Vbar attitude" ([9A] 7): the next quarter turn (P 90) is commanded AFTER SEP1, not during the last leg
        if current is not None and current in want and dist(current) <= dist(best) + 2.0:
            return current
        return best

    def p90_at(self, p_now):
        """UNDOCK_P90_T=s: the final quarter turn (P 90, -RBAR) commanded exactly s seconds before SEP1's TIG ([9A] 6 'prior to +Vbar crossing'; [8C] burns +X up in the P 90 attitude),
        so it is settled by the burn at any rate; used with UNDOCK_FA_NO_P90.  Returns the P now in force."""
        t = float(os.environ.get("UNDOCK_P90_T", "0"))
        if t > 0 and not getattr(self, "_p90_at_done", False) and self.truth()["gmt"] >= RR.T["SEP1"] - t:
            self._p90_at_done = True
            self.set_p(90, "fa-p90-at")
            self.say("FLYAROUND: P 90 commanded at TIG -%.0f s" % (RR.T["SEP1"] - self.truth()["gmt"]))
            return 90
        return p_now

    def set_p(self, p, name):
        """UNIV PTG: BODY VECT 5 at pitch P, TRK."""
        self.do(name, "+1     keys RESUME\n"
                      "+3     keys ITEM 1 5 + %s EXEC\n"
                      "+3     keys ITEM 1 9 EXEC\n" % sp(p), 4)
        self.say("UNIV PTG: TGT ID 2, BODY VECT 5, P %d" % p)

    def lvlh_pulses(self, dv, label, nmax=12):
        """dv (ft/s, LVLH) as aft-THC pulses along the body axes (the learned pulse size each)."""
        axes, q = self.body_axes_lvlh()
        return D.thc_pulses_aft(self, list(dv), axes, q, label, nmax=nmax)

    def dap_both(self, buttons, name):
        """The DAP buttons on both panels, C3 (forward) and A6U (aft): the aft THC takes its translation mode
        from A6U, the forward from C3, and the aft station's burns were not moving the Orbiter with C3 alone."""
        lines = ""
        for i, b in enumerate(buttons):
            lines += "+%d     dap c3 %s\n+0.5   dap a6u %s\n" % (1 if i == 0 else 2, b, b)
        self.play(lines, name)
        self.script_done(name, 90)
        self.wait_sim(2)

    def thc_burn(self, dv, label, tig=None, fixed_hold=None):
        """A THC burn of dv (ft/s, LVLH) flown as continuous holds on the aft THC, DAP A/AUTO/PRI, TRANS
        NORM: each body axis held for its share of the time (the acceleration seeded from the MC burns,
        scaled to this Orbiter's mass), checked against the truth's relative rates and finished with one
        correcting hold.  Returns the delta-V got (ft/s, LVLH).
        fixed_hold: one +X hold of exactly this many seconds, no sizing and no correction passes (SEP1 as flown: the Mission
        Report's 6.48 s of L1A+R1A).
        tig: the GMT the first hold starts at.  The DAP keying takes ~25 s of simulated time, so the caller
        starts the burn that long before TIG; without tig the keying comes first and the burn after it
        (f8: SEP1 started 26 s after its TIG)."""
        dv = np.array(dv, float)
        self.dap_both(("a", "auto", "pri", "x_norm", "y_norm", "z_norm"), label + "-norm")
        if tig is not None:
            if self.truth()["gmt"] > tig + 2.0:
                self.say("%s: the DAP keying ran %.0f s past TIG" % (label, self.truth()["gmt"] - tig))
            self.wait_gmt(tig)
        s0 = self.lvlh_state()
        want = dv.copy()
        mass_scale = 120.7 / 97.4
        for attempt in range(3):
            axes, q = self.body_axes_lvlh()
            m = [float(sum(want[k] * axes[k][i] for k in range(3))) for i in range(3)]
            b = ins.to_body(ins.qmat(q), m)
            lines, gap, plan = [], 0.0, []
            for k, ax in enumerate("xyz"):
                if abs(b[k]) < 0.04:
                    continue
                key = ("+" if b[k] > 0 else "-") + ax
                acc = (getattr(self, "thc_acc", None) or {}).get(key) or R.THC_ACC_SEED[key] * mass_scale
                hold = min(max(abs(b[k]) / acc * (0.85 if attempt == 0 else 1.0), 0.1), 20.0)
                st_ax, pos = D.AFT_STICK[ax]
                neg = "+" if pos == "-" else "-"
                stick = (pos if b[k] > 0 else neg) + st_ax
                lines.append("+%.2f   thc aft %s %.2f" % (gap, stick, hold))
                plan.append("%s %.2f s" % (key.upper(), hold))
                gap = hold + 0.3
            if fixed_hold is not None:
                st_ax, pos = D.AFT_STICK["x"]
                lines, gap, plan = ["+0.00   thc aft %s %.2f" % (pos + st_ax, fixed_hold)], fixed_hold + 0.3, ["+X %.2f s (as flown)" % fixed_hold]
            if not lines:
                break
            self.say("%s: THC burn pass %d: want %+.2f %+.2f %+.2f ft/s (LVLH) = body %+.2f %+.2f %+.2f; holds %s"
                     % (label, attempt, *want, *b, ", ".join(plan)))
            name = "%s-hold-%d" % (label, attempt)
            self.play("\n".join(lines) + "\n", name)
            self.script_done(name, 120)
            self.thc_moved_check(label)
            self.wait_sim(gap + 1.0)
            s1 = self.lvlh_state()
            got = s1[3:] - s0[3:]
            # the rotating frame turns: xdot, zdot change by 2 n z... over the burn (a few s) -- negligible
            want = dv - got
            # a THC hold has a floor: the shortest (0.1 s) gives 0.12-0.17 ft/s, so a correction smaller than that
            # is not made -- it came out larger than the error it was for (f3, c1)
            if fixed_hold is not None or np.max(np.abs(want)) < 0.12:
                break
        got = self.lvlh_state()[3:] - s0[3:]
        self.say("%s: delta-V got %+.2f %+.2f %+.2f ft/s (|%.2f|), wanted %+.2f %+.2f %+.2f (|%.2f|)"
                 % (label, *got, np.linalg.norm(got), *dv, np.linalg.norm(dv)))
        after = os.environ.get("UNDOCK_FA_JETS") or ("vern" if SEP1_VERN and label.startswith("sep1") else (("pri" if label.startswith(("fa-", "sep1")) else "alt") if NO_VERN else "vern"))
        self.dap_both((after, "x_pulse", "y_pulse", "z_pulse"), label + "-after")      # UNDOCK_FA_JETS=pri: the book's loss-of-VRCS substitute for VERN(PRI) ([9A], [8C]; p. 1-4)
        return got

    def gburn(self, name, tig_gmt, dv, lead=420.0):
        """RE-RNDZ RCS BURN (+X, -X, Multi-axis) (CC 9-26) with MCC's solution: OPS 202 PRO, RCS SEL (ITEM 4),
        WT (ITEM 9), TIG (ITEM 10) and the EXT delta-Vs (ITEMs 19-21, LVLH) keyed, LOAD (22), TIMER (23); at
        TIG - 30 s DAP A/AUTO/PRI, TRANS NORM; at TIG the burn flown on the THC to null VGO (null_vgo, as the
        midcourses); then DAP ALT, TRANS PULSE, OPS 201 PRO and the -Z target track again.  Returns the
        delta-V the truth got (ft/s, LVLH)."""
        dv = [float(x) for x in dv]
        if self.truth()["gmt"] < tig_gmt - lead:
            self.wait_gmt(tig_gmt - lead)
        wt = self.orbiter_lb()
        d, h, m, sec = R.dhms_f(met_of_gmt(tig_gmt))
        self.say("== %s: RCS BURN, TIG GMT %.0f (MET %03d/%02d:%02d:%04.1f), %+.2f %+.2f %+.2f ft/s (|%.2f|), WT %d lb"
                 % (name, tig_gmt, d, h, m, sec, *dv, math.sqrt(sum(x * x for x in dv)), round(wt)))
        self.do(name.lower() + "-load",
                "+1     keys OPS 2 0 2 PRO\nwait crt 1 title 2021/ timeout 180\n"
                "+3     keys RESUME\nwait crt 1 title MNVR EXEC timeout 60\n"
                "+3     keys ITEM 4 EXEC\n"
                "+4     keys ITEM 9 + %s EXEC\n"
                "+4     keys ITEM 1 0 + %s + %s + %s + %s EXEC\n"
                "+4     keys ITEM 1 9 %s %s %s EXEC\n"
                "+3     keys ITEM 2 2 EXEC\n"
                "+4     keys ITEM 2 3 EXEC\n"
                % (sp(round(wt)), sp(d), sp(h), sp(m), " ".join("%.1f" % sec), R.keys_num(dv[0], "%.1f"),
                   R.keys_num(dv[1], "%.1f"), R.keys_num(dv[2], "%.1f")), 6, name + " loaded", timeout=400)
        mem = self.probe(name.lower() + "-loaded")
        if mem:
            self.say("%s LOADed, TIMER: VGO %+.2f %+.2f %+.2f ft/s (body)" % ((name,) + tuple(mem.svec(mem.A["VGO_BODY"]))))
        if self.truth()["gmt"] < tig_gmt - 30.0:
            self.wait_gmt(tig_gmt - 30.0)
        self.do(name.lower() + "-tig30", "+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 pri\n"
                                          "+2     dap c3 x_norm\n+2     dap c3 y_norm\n+2     dap c3 z_norm\n", 2)
        self.wait_gmt(tig_gmt)
        s0 = self.lvlh_state()
        self.say("%s: TIG, state x %.0f y %.0f z %.0f ft, rates %+.2f %+.2f %+.2f" % (name, *s0[:3], *s0[3:]))
        vgo = self.null_vgo(name.lower(), 6)
        self.wait_sim(5)
        s1 = self.lvlh_state()
        got = s1[3:] - s0[3:]
        self.say("%s: the truth's delta-V %+.2f %+.2f %+.2f ft/s (LVLH, |%.2f|) against the %+.2f %+.2f %+.2f asked; VGO left %s"
                 % (name, *got, float(np.linalg.norm(got)), *dv,
                    ("%+.2f %+.2f %+.2f" % (vgo["x"], vgo["y"], vgo["z"])) if vgo else None))
        self.rr_burns = getattr(self, "rr_burns", {})
        self.rr_burns[name] = [float(x) for x in got]
        self.do(name.lower() + "-post", "+1     dap c3 alt\n+2     dap c3 x_pulse\n+2     dap c3 y_pulse\n+2     dap c3 z_pulse\n", 2)
        self.ops201_track(name.lower() + "-track", 300.0)
        return got

    def flyaround(self):
        """SEP/FLYAROUND [8A] to [9A]: from 150 ft to 650 ft ahead on the +V-bar by 04:20:00 (the Mission
        Report's fly-around pulse), the radial-up pulse that starts the half-orbit 2:1 ellipse about the ISS
        (rerndz.flyaround_dv), the UNIV PTG pitch stepped to keep the bay toward the ISS, ending just before
        SEP1.  The ISS is not in the Ku radar's lock at the end here, nor in the TCS."""
        t_fa = RR.T["FA"]
        if DAP62 and os.environ.get("UNDOCK_DAP62_AT_FA"):    # a run that starts HERE (the undock capture's A9/B9 are the tape's generic ones)
            self.dap_to_62(9, self.DAP_PROX, "A9B9-fa")
        self.reselect_fwd_up_jets()
        self.deselect_fwd_jets()
        if NO_VERN:
            self.press_jets("alt", "fa-alt")          # [6A] 4: VERN(ALT) after the separation, ALT for it
        n = RR.N_ISS
        # 1. THE TRANSFER to 650 ft ahead on the +V-bar, arriving at T_FA: along-track speed on the V-bar costs
        #    height (zddot = -2 n xdot, ~500 ft in 20 min at 0.3 ft/s), so the burn is the CW one for the point
        #    (650, 0, 0), not a speed along x.
        self.uplink()
        self.wait_sim(5)
        s = self.lvlh_state()
        dt = t_fa - self.truth()["gmt"] - 30.0
        dv1 = RR.transfer_dv(RR.prop(s, 30.0), dt, (FA_RHO0, 0.0, 0.0))
        self.say("FLYAROUND: x %.0f z %.0f ft; the transfer to %.0f ft ahead at 04:20:00 (%.0f s): %+.2f %+.2f %+.2f ft/s"
                 % (s[0], s[2], FA_RHO0, dt, *dv1))
        self.thc_burn(tuple(dv1 - 0.0), "fa-transfer")
        # 2. THE MIDCOURSE halfway, if the transfer was off
        self.wait_gmt(t_fa - 0.5 * dt - 30.0)
        self.uplink()
        self.wait_sim(5)
        s = self.lvlh_state()
        dt2 = t_fa - self.truth()["gmt"] - 10.0
        dv2 = RR.transfer_dv(RR.prop(s, 10.0), dt2, (FA_RHO0, 0.0, 0.0))
        self.say("FLYAROUND: halfway, x %.0f z %.0f ft; the midcourse %+.2f %+.2f %+.2f ft/s" % (s[0], s[2], *dv2))
        if float(np.linalg.norm(dv2)) > 0.06:
            self.thc_burn(tuple(dv2), "fa-mc")
        if not os.environ.get("UNDOCK_ELLIPSE"):
            return self._circle(t_fa)
        # 3. THE FLY-AROUND: at 04:20:00 one burn that stops the transfer's rates and starts the half-orbit 2:1
        #    ellipse about the ISS (zdot = -n x/2, up) -- the Mission Report's +X pulse of L3A and R3A
        self.wait_gmt(t_fa - 40.0)
        self.uplink()
        self.wait_gmt(t_fa)
        for k in range(3):
            s = self.lvlh_state()
            dv = RR.flyaround_dv_state(s)
            self.say("FLYAROUND: at x %.0f y %.0f z %.0f ft, rates %+.2f %+.2f %+.2f; the fly-around burn %+.2f %+.2f %+.2f ft/s at GMT %.0f"
                     % (*s[:3], *s[3:], *dv, self.truth()["gmt"]))
            if float(np.linalg.norm(dv)) < 0.06 and k > 0:
                break
            self.thc_burn(tuple(dv), "fa-pulse%d" % k)
            self.wait_sim(5)
        self.uplink()
        s = self.lvlh_state()
        self.fa_s0, self.fa_t0 = s, self.truth()["gmt"]
        self.say("FLYAROUND: now x %.0f z %.0f ft, rates %+.3f %+.3f %+.3f ft/s; half an orbit on: %s"
                 % (s[0], s[2], *s[3:], np.round(RR.prop(s, math.pi / n)[:3], 0)))
        p_now = 180
        # the attitude, quarter by quarter, until SEP1 minus 90 s -- and the range kept: [9A] has the crew hold
        # 650 +- 50 ft with the THC all the way round, and the DAP's own maneuvers (the quarter turns, and the
        # verniers' small net force) take the Orbiter off the ellipse by ~0.8 ft/s over the half orbit.  Every
        # 4 minutes the state is brought back toward where the ellipse would have it at SEP1.
        # the centred ellipse itself, from T_FA: x = 650 cos(n t), z = -325 sin(n t) (the half orbit that ends
        # 650 ft behind on the -V-bar), not the one the state after the fly-around burn would fly -- that one is
        # as off as the burn was (-0.4 ft/s of xdot left in c1), and trimming to it kept the error
        t_end = RR.T["SEP1"] - 90.0
        a_end = n * (t_end - t_fa)
        s_end = np.array([650.0 * math.cos(a_end), 0.0, -325.0 * math.sin(a_end), 0.0, 0.0, 0.0])
        next_trim = self.truth()["gmt"] + 240.0
        while self.truth()["gmt"] < RR.T["SEP1"] - 90.0:
            s = self.lvlh_state()
            p_now = self.p90_at(p_now)
            p = self.p_for(s[0], s[2], p_now)
            if p != p_now:
                self.set_p(p, "fa-p%d" % p)
                p_now = p
                self.say("FLYAROUND: x %.0f z %.0f ft (range %.0f), P %d" % (s[0], s[2], math.sqrt(s[0] ** 2 + s[2] ** 2), p))
            if self.truth()["gmt"] >= next_trim and RR.T["SEP1"] - 90.0 - self.truth()["gmt"] > 420.0:
                s = self.lvlh_state()
                left = RR.T["SEP1"] - 90.0 - self.truth()["gmt"] - 20.0
                dv = RR.transfer_dv(RR.prop(s, 20.0), left, s_end[:3])
                a_now = n * (self.truth()["gmt"] - t_fa)
                ideal = np.array([650.0 * math.cos(a_now), 0.0, -325.0 * math.sin(a_now)])
                self.say("FLYAROUND: trim, x %.0f z %.0f (the ellipse x %.0f z %.0f); %+.2f %+.2f %+.2f ft/s"
                         % (s[0], s[2], ideal[0], ideal[2], *dv))
                if float(np.linalg.norm(dv)) > 0.05:
                    self.thc_burn(tuple(dv), "fa-trim")
                next_trim = self.truth()["gmt"] + 240.0
            self.wait_sim(20)
        s = self.lvlh_state()
        self.say("FLYAROUND done: x %.0f z %.0f ft, xdot %+.2f zdot %+.2f, range %.0f ft"
                 % (s[0], s[2], s[3], s[5], math.sqrt(s[0] ** 2 + s[2] ** 2)))

    def _circle(self, t_fa):
        """THE FLY-AROUND as [9A] and the History (JSC-63400 ch. 21, p. 150) have it: one full revolution of 650 ft
        (CG-CG, +-50) about the ISS from the +V-bar at 04:20:00 to the +V-bar at SEP1 (05:06:02, 2,762 s -- 1.98 n,
        so forced, not the free 2:1 ellipse): up first (-Rbar, -Vbar, +Rbar, +Vbar crossings, the bay toward the ISS
        by the quarter-turn P 180/90/0/270).  The first burn is the +X pulse (radial up, ~1.5 ft/s); then twelve
        CW legs of 230 s, each burned from the truth's state to the next point of the circle (~0.35 ft/s each,
        4 ft/s in all, the range held within ~15 ft by the geometry).  Ledger #316: the earlier half-orbit ellipse
        ended on the -V-bar, which put SEP2 3,200 ft from Figure 21.1's."""
        n, legs = RR.N_ISS, 12
        tf = RR.T["SEP1"] - t_fa
        w = 2.0 * math.pi / tf
        dl = tf / legs
        self.wait_gmt(t_fa - 40.0)
        self.uplink()
        self.wait_gmt(t_fa)
        p_now = 180
        for k in range(legs):
            s = self.lvlh_state()
            th = w * (k + 1) * dl
            rho = FA_RHO0 + (FA_RHO1 - FA_RHO0) * min(th / FA_OPEN, 1.0)
            tgt = (rho * math.cos(th), 0.0, -rho * math.sin(th))
            lead = 10.0
            dv = RR.transfer_dv(RR.prop(s, lead), dl - lead, tgt)
            self.say("FLYAROUND leg %d/%d: at x %.0f y %.0f z %.0f ft (range %.0f), rates %+.2f %+.2f %+.2f; to x %.0f z %.0f in %.0f s: %+.2f %+.2f %+.2f ft/s"
                     % (k + 1, legs, *s[:3], math.sqrt(s[0] ** 2 + s[2] ** 2), *s[3:], tgt[0], tgt[2], dl - lead, *dv))
            t_end = t_fa + (k + 1) * dl
            if float(np.linalg.norm(dv)) > 0.05:
                self.thc_burn(tuple(dv), "fa-leg%d" % (k + 1))
            while self.truth()["gmt"] < t_end - (75.0 if k == legs - 1 else 25.0):      # the last leg: SEP1's keying (~25 s) is done by TIG
                s = self.lvlh_state()
                p_now = self.p90_at(p_now)
                p = self.p_for(s[0], s[2], p_now)
                if p != p_now:
                    self.set_p(p, "fa-p%d-%d" % (p, k + 1))
                    p_now = p
                    self.say("FLYAROUND: x %.0f z %.0f ft (range %.0f), P %d" % (s[0], s[2], math.sqrt(s[0] ** 2 + s[2] ** 2), p))
                self.wait_sim(15)
        s = self.lvlh_state()
        self.say("FLYAROUND done: x %.0f z %.0f ft, xdot %+.2f zdot %+.2f, range %.0f ft"
                 % (s[0], s[2], s[3], s[5], math.sqrt(s[0] ** 2 + s[2] ** 2)))

    # THE PROX OPS DAP CONFIGURATIONS A9 / B9, the RNDZ book's p. 6-2 ("ISS RNDZ OPS DAP CONFIGURATIONS"): the book has the crew config DAP A,B to A9,B9 at
    # the undock (-3:00) and they stay through SEP1 until SEP2 Preliminary's "Config DAP A, B to A7, B7".  THIS TAPE'S stored A9 / B9 are generic I-loads
    # (f41a read SPEC 20 at SEP1: A9 ROT RATE 0.2000, ATT DB 5.00, P/Y OPTION ALL, VERN ROT RATE 0.2000, ROT PLS 0.010; B9 ROT RATE 0.5000, VERN ROT PLS
    # 0.002 ... against 6-2's 0.130, 2.00, TAIL, 0.130, 0.050 / 0.130, 0.020), the same situation fly_rndz134.dap_config corrects for A7/B7.
    DAP_PROX = {
        "A": {10: 0.130, 11: 2.00, 12: 0.10, 13: 0.10, 14: 0.0, 15: "TAIL", 16: "TAIL", 17: 0.05,
              18: 0.10, 19: "TAIL", 20: 2, 21: 0.08, 22: 0.00,
              23: 0.130, 24: 1.00, 25: 0.020, 26: 0.050, 27: 0.0, 28: 0},
        "B": {30: 0.130, 31: 2.00, 32: 0.10, 33: 0.04, 34: 0.0, 35: "TAIL", 36: "TAIL", 37: 0.01,
              38: 0.10, 39: "TAIL", 40: 2, 41: 0.08, 42: 10.00,
              43: 0.130, 44: 1.00, 45: 0.020, 46: 0.020, 47: 0.0, 48: 0},
    }

    def dap_to_62(self, n, table, label):
        """Config DAP A,B to An,Bn with the stored configurations made p. 6-2's (DAP EDIT: DAP A/B - ITEM 3/4 +n, the edit column's items 50+row
        keyed, LOAD - ITEM 5; an option item cycles, so it is pressed until it reads right), then selected (ITEM 1/2 +n) and read back."""
        def mism(vals, side):
            bad = {}
            for i, want in table[side].items():
                got = vals.get(i)
                if isinstance(want, str) or got is None or isinstance(got, str):
                    if got != want:
                        bad[i] = (got, want)
                elif abs(got - want) > 0.0006:
                    bad[i] = (got, want)
            return bad
        page = self.spec20_page("dap62-%s-0" % label)
        sel, vals = R.parse_spec20(page)
        self.say("DAP CONFIG %s: SPEC 20 selected A%s B%s; stored A%d / B%d differ from 6-2 in: A %s | B %s" % (label, sel.get("A"), sel.get("B"), n, n,
                 sorted(mism(vals, "A")) if sel.get("A") == "%02d" % n else "(not selected)", sorted(mism(vals, "B")) if sel.get("B") == "%02d" % n else "(not selected)"))
        for side, item, edit, base in (("A", 1, 3, 10), ("B", 2, 4, 30)):
            # select the configuration so its values are on the page, copy it to the edit column
            self.play("+1     keys ITEM %d + %d EXEC\n+3     keys ITEM %d + %d EXEC\n" % (item, n, edit, n), "dap62-%s-%s-copy" % (label, side))
            self.script_done("dap62-%s-%s-copy" % (label, side), 120)
            self.wait_sim(5)
            page = self.spec20_page("dap62-%s-%s-pg" % (label, side))
            sel, vals = R.parse_spec20(page)
            bad = mism(vals, side)
            if not bad:
                self.say("DAP %s%d already 6-2's" % (side, n)); continue
            keys = ""
            for i, (got, want) in sorted(bad.items()):
                row = i - base
                if isinstance(want, str):
                    continue
                keys += "+3     keys ITEM %s %s EXEC\n" % (" ".join(str(50 + row)), R.keys_short(want, R.DAP_FMT[row]))
            if keys:
                self.play("+1" + keys[2:] + "+3     keys ITEM 5 EXEC\n", "dap62-%s-%s-num" % (label, side))
                self.script_done("dap62-%s-%s-num" % (label, side), 300)
                self.wait_sim(6)
            # the option rows: the edit column's item cycles on each press
            for i, (got, want) in sorted(bad.items()):
                if not isinstance(want, str):
                    continue
                row = i - base
                for k in range(3):
                    page = self.spec20_page("dap62-%s-%s-opt%d-%d" % (label, side, i, k))
                    sel, vals = R.parse_spec20(page)
                    if vals.get(i) == want:
                        break
                    self.play("+1     keys ITEM %s EXEC\n+3     keys ITEM 5 EXEC\n" % " ".join(str(50 + row)), "dap62-%s-%s-opt%d-press%d" % (label, side, i, k))
                    self.script_done("dap62-%s-%s-opt%d-press%d" % (label, side, i, k), 120)
                    self.wait_sim(5)
        # select the (now 6-2) configurations and read them back
        self.play("+1     keys ITEM 1 + %d EXEC\n+3     keys ITEM 2 + %d EXEC\n" % (n, n), "dap62-%s-sel" % label)
        self.script_done("dap62-%s-sel" % label, 120)
        self.wait_sim(6)
        page = self.spec20_page("dap62-%s-final" % label)
        sel, vals = R.parse_spec20(page)
        self.dump_screen("SPEC 20 DAP CONFIG after dap_to_62 (%s)" % label)
        bad = {s: mism(vals, s) for s in ("A", "B")}
        self.say("DAP CONFIG %s: SPEC 20 shows A%s B%s -- %s" % (label, sel.get("A"), sel.get("B"),
                 "every item as 6-2" if not (bad["A"] or bad["B"]) else "STILL DIFFERENT: %s" % bad))
        self.play("+1     keys RESUME\n", "dap62-%s-resume" % label)
        self.script_done("dap62-%s-resume" % label, 60)

    def sep1(self):
        """SEP1 BURN [8C]: 1.5 ft/s radially up (the jets' +X in the Mission Report), DAP TRANS NORM,
        THC, then A/AUTO/VERN, TRANS PULSE.  TIG 05:06:02 -- the first hold starts AT TIG (the keying is done
        before it).  The fly-around ends on its circle: the burn is the 1.5 ft/s on top of the circle's own rate
        at the +V-bar (rho w, up), so the legs' position-only aim leaves no short rate behind it (f8: the
        circle ended at 1.27 ft/s up against its 1.48, and SEP1 came 0.2 ft/s short of Figure 21.1's)."""
        tig = RR.T["SEP1"]
        if not getattr(self, "_ku_low_done", False):
            self._ku_low_done = True
            self.ku_switches("ku-output-low", radar_output="LOW")      # RADAR OUTPUT LOW at ~700 ft, thrown here in sequence (under the panel lock)
        if DAP62 and os.environ.get("UNDOCK_DAP62_AT_SEP1"):   # only for a run started AT SEP1: it delays the burn by ~8 min
            self.dap_to_62(9, self.DAP_PROX, "A9B9-sep1")
        if os.environ.get("UNDOCK_DAP_DUMP"):                       # read back the DAP configuration actually in effect (SPEC 20: the active A and B columns)
            pg = self.spec20_page("dap-spec20-sep1")
            self.dump_screen("SPEC 20 DAP CONFIG at SEP1 (A12/B12 in effect)")
        self.deselect_fwd_jets()          # a no-op if the fly-around already did it
        p90_lead = float(os.environ.get("UNDOCK_P90_LEAD", "0"))   # [9A] 6: "prior to +Vbar crossing ... P +90 (-RBAR)": the quarter turn commanded this many s BEFORE TIG (0: after the burn, as before)
        if p90_lead > 0:
            self.wait_gmt(tig - p90_lead)
            self.set_p(90, "sep1-p90-early")
        self.wait_gmt(tig - 70)
        s = self.lvlh_state()
        dt = tig - self.truth()["gmt"]
        st = RR.prop(s, dt)
        w = 2.0 * math.pi / (tig - RR.T["FA"])
        v_circ = (0.0, 0.0, -FA_RHO1 * w)
        trim = np.array([v_circ[0] - st[3], -st[4], v_circ[2] - st[5]])
        dv = trim + np.array([0.0, 0.0, -RR.PLAN["SEP1"]])
        if SEP1_JETS:
            # The burn AS FLOWN: the Mission Report's 6.48 s of L1A + R1A (vehdyn.c REF_FORCE sum 1713.6 lbf body +X, 302.2 lbf body +Z, ~96,900 kg)
            # is 1.672 ft/s radial up and 0.295 ft/s ahead (body +Z is away from the ISS at the burn), |1.70|; the 1.5 ft/s is the planned figure
            # (Stuit).  CW from the circle to Figure 21.1's SEP2 point needs 1.72 up (+0.13 ahead) -- sep1fit.py, ledger #316.  No circle trim.
            dv = np.array([0.295, 0.0, -1.672])
            if os.environ.get("UNDOCK_SEP1_DV"):      # "ahead,up" ft/s: the bisection / correction runs (f26)
                a_, u_ = (float(q) for q in os.environ["UNDOCK_SEP1_DV"].split(","))
                dv = np.array([a_, 0.0, -u_])
        self.say("SEP1: x %.0f z %.0f ft, xdot %+.2f zdot %+.2f at GMT %.0f; at TIG x %.0f z %.0f xdot %+.2f zdot %+.2f; the circle's rate "
                 "%+.2f up, trim %+.2f %+.2f %+.2f + the book's 1.5 = %+.2f %+.2f %+.2f ft/s"
                 % (s[0], s[2], s[3], s[5], self.truth()["gmt"], st[0], st[2], st[3], st[5], -v_circ[2], *trim, *dv))
        flown_hold = float(os.environ.get("UNDOCK_SEP1_HOLD", "6.48")) if SEP1_JETS else 0.0
        got = self.thc_burn(tuple(dv), "sep1", tig=tig, fixed_hold=(flown_hold or None))      # UNDOCK_SEP1_HOLD=0: the old sized holds + corrections
        if not float(os.environ.get("UNDOCK_P90_LEAD", "0")) > 0:
            self.set_p(90, "sep1-p90")        # [9A] 6: the next quarter turn (-RBAR), so the bay follows the ISS as the Orbiter climbs
        self.uplink()
        self.rr_burns = getattr(self, "rr_burns", {})
        self.rr_burns["SEP1"] = [float(x) for x in got]

    def sep2(self):
        """RE-RENDEZVOUS: the -Z axis target track [11A] after SEP1, the ground's SEP2 solution (rerndz:
        the direction for which NSR comes to 2.4 and TPI 3.4 ft/s), loaded and burned at 05:34:06."""
        self.wait_gmt(RR.T["SEP1"] + 240)
        if DAP62:
            self.dap_config("[SEP2 Preliminary]")     # [GNC_20_DAP_CONFIG] Config DAP A, B to A7, B7 (checklist p. 2-9), the tape's generic A7/B7 made 6-2's
        self.uplink()                     # MCC UPLINK ORB SV, TGT SV
        self.wait_sim(10)
        if SEP1_VERN:
            self.TRACK_KEYS = self.TRACK_KEYS.replace("dap c3 alt", "dap c3 vern")
        self.ops201_track("sep2-track", 300.0)
        if SEP1_VERN:
            del self.TRACK_KEYS
        self.wait_gmt(RR.T["SEP2"] - 420)
        s = self.lvlh_state()
        self.say("SEP2: state x %.0f y %.0f z %.0f ft, xdot %+.2f ydot %+.2f zdot %+.2f; range %.0f ft"
                 % (*s[:3], *s[3:], np.linalg.norm(s[:3])))
        s2 = RR.prop(s, RR.T["SEP2"] - self.truth()["gmt"])
        ref = RR.ref()
        if FLOWN:
            d2 = np.array(RR.FLOWN_SEP2)
            ref = dict(ref, nh2_pos=np.zeros(3))
        else:
            d2 = RR.targeted_dv(s2, RR.T["SEP2"], RR.T["NH2"], ref["nh2_pos"])
        nominal = ref["sep2"]
        self.say("SEP2: the ground's solution %+.2f %+.2f %+.2f ft/s (LVLH, |%.2f|), aimed at the reference NH2 point x %.0f z %.0f ft; "
                 "the nominal chain's is %+.2f %+.2f %+.2f"
                 % (*d2, float(np.linalg.norm(d2)), ref["nh2_pos"][0], ref["nh2_pos"][2], *nominal))
        self.rr_plan = dict(SEP2=list(d2))
        self.gburn("SEP2", RR.T["SEP2"], d2)
        self.restore_fwd_jets()


    # ------------------------------------------------------------------------------------------------
    # THE STORRM RE-RENDEZVOUS (Rendezvous book pp. 1-10, 1-11, 2-11 to 2-20; Mission Report FD15)
    # ------------------------------------------------------------------------------------------------
    def rr_uplink_track(self, name, before_tig):
        """MCC UPLINK ORB SV, TGT SV and the -Z axis target track [11A], some minutes before a burn."""
        self.wait_gmt(before_tig - 900)
        self.uplink()
        self.wait_sim(10)
        self.ops201_track(name + "-track", 300.0)

    def nh2(self):
        """NH2 (2.0 ft/s, 06:39:38): the ground's solution from the truth at the burn's time."""
        self.rr_uplink_track("nh2", RR.T["NH2"])
        self.wait_gmt(RR.T["NH2"] - 450)
        s = self.lvlh_state()
        s_t = RR.prop(s, RR.T["NH2"] - self.truth()["gmt"])
        if FLOWN:
            ref = dict(nsr_pos=np.array(RR.NSR_POINT))
            dv = np.array(RR.FLOWN_NH2)
        elif FLOWN_BURNS:
            ref = RR.ref()
            dv = np.array(RR.FLOWN_NH2)
            if os.environ.get("UNDOCK_NH2_X"):
                dv[0] = float(os.environ["UNDOCK_NH2_X"])      # the experiment: a larger NH2 than the flown -1.8 ft/s
        else:
            ref = RR.ref()
            dv = RR.targeted_dv(s_t, RR.T["NH2"], RR.T["NSR"], ref["nsr_pos"])
        rep = RR.chain(RR.kick(s_t, dv), RR.T["NH2"])
        rep["z_nsr"] = float(ref["nsr_pos"][2])
        self.say("NH2: state x %.0f z %.0f ft; at TIG x %.0f z %.0f; solution %+.2f %+.2f %+.2f ft/s (|%.2f|, the book 2.0), aimed at the "
                 "reference NSR point x %.0f z %.0f; predicted NSR %.2f TPI %.2f ft/s, range at TPI %.0f ft"
                 % (s[0], s[2], s_t[0], s_t[2], *dv, float(np.linalg.norm(dv)), ref["nsr_pos"][0], ref["nsr_pos"][2],
                    rep["NSR"], rep["TPI"], rep["range_tpi"]))
        self.rr_plan = getattr(self, "rr_plan", {})
        self.rr_plan["z_nsr"] = rep["z_nsr"]
        json.dump({"z_nsr": rep["z_nsr"]}, open(os.path.join(self.a.logs, "rr-plan.json"), "w"))
        self.gburn("NH2", RR.T["NH2"], dv)

    def _z_nsr(self):
        try:
            return json.load(open(os.path.join(self.a.logs, "rr-plan.json")))["z_nsr"]
        except (OSError, ValueError, KeyError):
            return 4260.0

    def mc5(self):
        """MC5 (planned 0.0 ft/s, 06:59:08; flown 1.6 s of multi-axis jets): the correction that leaves the
        Orbiter at NH2's height with no radial rate when NSR comes; skipped under 0.1 ft/s."""
        self.wait_gmt(RR.T["MC5"] - 600)
        s = self.lvlh_state()
        s_t = RR.prop(s, RR.T["MC5"] - self.truth()["gmt"])
        if FLOWN:
            dv = RR.targeted_dv(s_t, RR.T["MC5"], RR.T["NSR"], RR.NSR_POINT)       # on-board Lambert to the NSR point
        elif FLOWN_BURNS:
            dv = np.array((0.1, 0.0, 0.5))      # the flown MC5 solution (History ch. 21 p. 154)
        else:
            dv = RR.mc5_dv(s_t, self._z_nsr())
        mag = float(np.linalg.norm(dv))
        self.say("MC5: at TIG x %.0f z %.0f ft; the correction %+.2f %+.2f %+.2f ft/s (|%.2f|)" % (s_t[0], s_t[2], *dv, mag))
        if mag < 0.1:
            self.say("MC5: under 0.1 ft/s -- no burn (the book plans 0.0)")
            return
        self.gburn("MC5", RR.T["MC5"], dv)

    def nsr(self):
        """NSR (2.4 ft/s, 07:24:08): the coelliptic burn, horizontal, at the apsis."""
        self.wait_gmt(RR.T["NSR"] - 900)
        self.uplink()
        self.wait_sim(10)
        s = self.lvlh_state()
        s_t = RR.prop(s, RR.T["NSR"] - self.truth()["gmt"])
        dv = RR.coelliptic_dv(s_t)
        self.say("NSR: at TIG x %.0f y %.0f z %.0f ft, rates %+.2f %+.2f %+.2f; the coelliptic burn %+.2f %+.2f %+.2f ft/s (|%.2f|)"
                 % (*s_t[:3], *s_t[3:], *dv, float(np.linalg.norm(dv))))
        self.gburn("NSR", RR.T["NSR"], dv)

    def tpi_shift(self):
        """Seconds TPI slipped from the Mission Report's time (the book's TPI is Lambert-targeted on the 42 deg elevation
        angle with no TIG slip limit; the flown TIGs were 33 s early); TDA and SEP3 follow it (+15 min, +26:51)."""
        if hasattr(self, "_tpi_shift"):
            return self._tpi_shift
        try:
            return float(json.load(open(os.path.join(self.a.logs, "rr-plan.json"))).get("tpi_shift", 0.0))
        except (OSError, ValueError):
            return 0.0

    def tpi(self):
        """TPI (3.4 ft/s, 07:57:34, ~6,860 ft): the onboard targeted burn to the TDA point, 1,000 ft below and 333 ft
        behind the ISS, 26:51 later -- at the instant the ISS's elevation from the Orbiter's local horizontal reaches
        42 deg (the book's elevation-angle option, History ch. 21 p. 150), as the crew would load the TIG: predicted
        from the state 15 minutes ahead, within 10 minutes of the Mission Report's time either way, else its time.
        UNDOCK_TPI_FIXED=1: the fixed time (f1-f8)."""
        self.wait_gmt(RR.T["TPI"] - 900)
        self.uplink()
        self.wait_sim(10)
        s = self.lvlh_state()
        now = self.truth()["gmt"]
        tig = RR.T["TPI"]
        if not os.environ.get("UNDOCK_TPI_FIXED"):
            for tt in np.arange(RR.T["TPI"] - 300.0, RR.T["TPI"] + 600.0, 2.0):
                q = RR.prop(s, tt - now)
                if math.degrees(math.atan2(q[2], -q[0])) >= 42.0:
                    tig = float(tt)
                    break
        s_t = RR.prop(s, tig - now)
        dv = RR.transfer_dv(s_t, RR.T["TDA"] - RR.T["TPI"], RR.TDA_POINT)
        self._tpi_shift = tig - RR.T["TPI"]
        try:
            plan = json.load(open(os.path.join(self.a.logs, "rr-plan.json")))
        except (OSError, ValueError):
            plan = {}
        plan["tpi_shift"] = self._tpi_shift
        json.dump(plan, open(os.path.join(self.a.logs, "rr-plan.json"), "w"))
        self.say("TPI: elevation %.1f deg at the Mission Report's time; TIG %+.0f s from it (42 deg); at TIG x %.0f y %.0f z %.0f ft (range %.0f, the book ~6,860), "
                 "rates %+.2f %+.2f %+.2f; the burn %+.2f %+.2f %+.2f ft/s (|%.2f|)"
                 % (math.degrees(math.atan2(*(lambda q: (q[2], -q[0]))(RR.prop(s, RR.T["TPI"] - now)))), self._tpi_shift,
                    *s_t[:3], float(np.linalg.norm(s_t[:3])), *s_t[3:], *dv, float(np.linalg.norm(dv))))
        self.gburn("TPI", tig, dv)

    GATES = ((2000.0, -3.7), (1500.0, -2.9), (1000.0, -1.8), (600.0, 0.0))       # ft, the closing rate to brake to (ft/s)

    def tda(self):
        """The approach to TDA (08:24:25, ~1,050 ft): the braking gates (2000 ft to -3.7 ft/s, 1500 to -2.9, 1000
        to -1.8 and LOW Z, 600 to 0.0) acted on if the closing is faster; NORM Z again after 1000 ft going out."""
        gate_done = set()
        lowz = False
        while self.truth()["gmt"] < RR.T["TDA"] + self.tpi_shift() + 30:
            s = self.lvlh_state()
            rng = float(np.linalg.norm(s[:3]))
            rdot = float(np.dot(s[:3], s[3:]) / max(rng, 1.0))
            for g, rd in self.GATES:
                if rng <= g and g not in gate_done and rdot < 0:
                    gate_done.add(g)
                    self.say("TDA: braking gate %d ft: range %.0f, RDOT %+.2f ft/s (gate %+.1f)" % (g, rng, rdot, rd))
                    if g == 1000.0 and not lowz:
                        D.dap_modes(self, "a", True)
                        if NO_VERN:
                            self.press_jets("pri", "tda-pri")           # inside 2,000 ft: PRI for VERN
                        lowz = True
                    if rdot < rd:
                        u = s[:3] / rng
                        self.lvlh_pulses(tuple((rd - rdot) * -u), "tda-brake-%d" % g, nmax=20)
            self.wait_sim(10)
        s = self.lvlh_state()
        self.say("TDA: range %.0f ft (the book ~1,050), x %.0f z %.0f, GMT %.0f" % (float(np.linalg.norm(s[:3])), s[0], s[2], self.truth()["gmt"]))

    def sep3(self):
        """SEP3 (1.0 ft/s retrograde, 08:38:36, 15 min after TDA), DAP A, NORM Z, in the target track."""
        self.wait_gmt(RR.T["SEP3"] + self.tpi_shift() - 60)
        if lowz_on(self):
            D.dap_modes(self, "a", False)
            if NO_VERN:
                self.press_jets("alt", "sep3-alt")
        got = self.thc_burn(tuple(RR.sep3_dv()), "sep3", tig=RR.T["SEP3"] + self.tpi_shift())
        self.rr_burns = getattr(self, "rr_burns", {})
        self.rr_burns["SEP3"] = [float(x) for x in got]
        self.wait_sim(120)
        s = self.lvlh_state()
        self.say("SEP3 done: range %.0f ft, x %.0f z %.0f, GMT %.0f; burns got %s"
                 % (float(np.linalg.norm(s[:3])), s[0], s[2], self.truth()["gmt"], getattr(self, "rr_burns", {})))


def lowz_on(f):
    return bool(f.lamps().low_z_lit())


def main():
    R.Rendezvous = Undock
    R.PHASES.extend(["START", "SEPCFG", "UNDOCK", "FLYAROUND", "SEP1", "SEP2", "NH2", "MC5", "NSR", "TPI", "TDA", "SEP3"])      # after dock_autopilot's DOCK30, DOCK, STAY
    for a, v in (("--rhc", "both"), ("--station", "all"), ("--input", "virtual")):
        if a not in sys.argv:
            sys.argv += [a, v]
    R.main()


if __name__ == "__main__":
    main()
