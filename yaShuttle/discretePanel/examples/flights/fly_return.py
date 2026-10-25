#!/usr/bin/env python3
"""STS-134 FD15 SEP3 to the wheels stopped at KSC (Phase 3 of the post-docking plan).

    fly_return.py --logs DIR --from COAST [--to LAND] --tape OI340700-v44boot-sts134-ksc6-rndz2.mmv
                  --targets .../sts134-targets-undock-0320.txt [--rate 3] [--crts 2]

THE COAST IS FLOWN (owner, 2026-10-24: from the SEP3 snapshot of an undocking run made without tricks, itself
without tricks, to the point where the deorbit preparations begin).  The 42 hours from SEP3 (150/08:38) to the
deorbit day are crossed by running the simulation at --rate, not by carrying the physics over the gap and booting
a fresh flight computer (undock_coast.py + make_return_start.py, the earlier path, still here for --from ORBIT
on such a capture).  COAST restores DIR/sts134r-sep3 and flies, by the Cooper shift reports and the Mission Report:
  150/09:10:19  DAP to LVLH for the end of the STORRM DTO: the water-dump attitude -ZLV +YVV (UNIV PTG TGT ID 2,
                BODY VECT 3, OM 310 -- the FD15 execution package's ORB ATT), DAP A/AUTO/VERN
  151/07:33:10  RAMBO-2: three +X firings of L1A and R1A (the Mission Report text: 10 s each; its table says 10.6)
  every 6 h     the ground's state-vector uplink (MCC UPLINK ORB SV); every 30 min a log line against the truth
  every 4 h     a capture, DIR/sts134r-coast-NN, from which --from COAST can be resumed with RETURN_COAST_FROM
NOT flown, and why (the blockers, not the effort; ledger entries): MAUI (150/11:43:18: four primary RCS firings
totalling 144 s over AMOS -- the direction and the split are in no document we have, and 144 s of two aft jets
would be 38 ft/s); the RCS hot-fire (151/03:30:57, all 38 jets: its procedure is not in the documents here);
the FCS checkout (151/02:24:36) and the water dumps (no model); FRCS logic/drivers OFF (150/11:50:46: no panel
control for them).  RETURN_COAST_END (default 152/01:29:03, the flown TIG - 4:00, where the Deorbit Prep checklist begins) is where the coast stops and ORBIT begins.

DEORBIT then targets the opportunity the Orbiter flew (orbit 248, landing 152/06:34:50) from the simulated
state, with TIG to EI the flown 34:03.

PHASES, fly_sts134's own, unchanged -- the Entry Checklist as that driver flies it:
  DEORBIT  the ground's targets for the first KSC 15 opportunity (deorbit_target.py from the ORBIT
           capture), single-G3 and OPS 301 at TIG-75, the DEORB MNVR targets, OPS 302, the burn, OPS 303
  ENTRY    OPS 304 at EI-5 and PASS flying to about TAEM
  LAND     TAEM, the approach and landing, the gear and the chute, the wheels stopped
The real deorbit burn was 152/05:29:03 (Mission Report); EI about 06:03, wheels stop 06:35:33.
Run with YAGPC_NAVAIDS=.../ksc-navaids.txt for the landing aids.
"""
import json
import math
import os
import sys
import time

import fly_sts134
import fly_undock as U
import fly_rndz134 as R


def G(d, h, m, s=0.0):
    """A GMT of the 2011 year as the flight software counts it (seconds from day 0)."""
    return d * 86400.0 + h * 3600.0 + m * 60.0 + s


def gmt_arg(text, default):
    """RETURN_* environment: 'DDD/HH:MM[:SS]' -> GMT seconds."""
    t = os.environ.get(text)
    if not t:
        return default
    d, rest = t.split("/")
    parts = [float(x) for x in rest.split(":")] + [0.0, 0.0]
    return G(int(d), parts[0], parts[1], parts[2])


class Return(U.Undock):
    COAST_END = G(152, 1, 29, 3)        # TIG - 4:00 of the flown deorbit (152/05:29:03): "Begin NOMINAL DEORBIT PREP timeline at TIG-4 hr" (Deorbit Prep Rev Q, CONTINGENCY DELTAS)
    COAST_LOG_S = 1800.0
    COAST_UPLINK_S = 6 * 3600.0
    COAST_SNAP_S = 4 * 3600.0
    LVLH_KEYS = ("+3     keys ITEM 2 1 EXEC\n"
                 "+3     keys ITEM 8 + 2 EXEC\n"
                 "+3     keys ITEM 1 4 + 3 EXEC\n"
                 "+3     keys ITEM 1 7 + 3 1 0 EXEC\n"
                 "+3     dap c3 a\n"
                 "+2     dap c3 auto\n"
                 "+2     dap c3 vern\n"
                 "+3     keys ITEM 1 9 EXEC\n")
    # THE OPPORTUNITY THE ORBITER TOOK: orbit 248, KSC 15, wheels stopped 152/06:35:33, main gear 06:34:50 (Mission Report); TIG to EI
    # 34:03 (TIG 05:29:03, EI 06:03:06).  The pass is chosen by its closest approach to the runway nearest that landing; the burn is
    # then designed from the simulated state, the ground's way (deorbit_target.py), so TIG and the burn differ by the run's dispersion.
    # The target line is the one that reproduces the flown post-burn orbit (23.2 x 188.5 n.mi. -> EI gamma -1.17 deg; STS-1's C1 gives -1.38 and
    # 394 ft/s where the flight burned 297), and EI is put at the flown 06:03:06 by the range from EI to the runway (REI solved, 4,438 n.mi.).
    DEORBIT_ARGS = ["--tff", "34.05", "--gamma-ei", "-1.10", "--ei-gmt", "%.1f" % (152 * 86400.0 + 6 * 3600.0 + 3 * 60.0 + 6.0),
                    "--near-gmt", "%.1f" % (152 * 86400.0 + 6 * 3600.0 + 34 * 60.0 + 50.0)]
    RAMBO_PULSES = 3
    RAMBO_S = 10.0

    def start(self, resume=None):
        """RETURN_COAST_FROM=DIR: resume the coast from one of its own captures (sts134r-coast-NN)."""
        alt = os.environ.get("RETURN_COAST_FROM")
        return super().start(alt or resume)

    # --- the coast: SEP3 to the deorbit preparations, flown ---------------------------------------------------
    def coast_events(self):
        """(GMT, name, method): what the record has the crew do between SEP3 and the deorbit day that this
        simulation can fly.  See the module docstring for what it cannot."""
        return [(G(150, 9, 10, 19), "lvlh", self.ev_lvlh),
                (G(151, 7, 33, 10), "rambo", self.ev_rambo)]

    def ev_lvlh(self):
        """150/09:10:19 'DAP to LVLH at 150/09:10:19 GMT for conclusion of STORRM DTO' (FD15 shift report); the attitude
        is the execution package's -ZLV +YVV (UNIV PTG TGT ID 2, BODY VECT 3, OM 310).  The maneuver is flown on the
        primaries (A/AUTO/PRI, 0.2 deg/s: the verniers turn at 0.019 deg/s and would take an hour and a half for the
        ~110 deg), the verniers take over when the -Z axis is on the nadir (the truth's angle, since the maneuver is
        UNIV PTG's own), the hold the Orbiter keeps to the deorbit day."""
        self.play("+1     keys OPS 2 0 1 PRO\nwait crt 1 title 2011/ timeout 180\n" + self.LVLH_KEYS.replace("dap c3 vern", "dap c3 pri"), "coast-lvlh")
        self.script_done("coast-lvlh", 300)
        t0 = self.truth()["t"]
        still = 0
        err = None
        while self.truth()["t"] - t0 < 5400.0:
            time.sleep(10.0 / max(self.a.rate, 1.0))
            tru = self.ears.snap()[0]
            if not tru:
                continue
            nadir = [-c / R.vnorm(tru["r"]) for c in tru["r"]]
            mz = [-c for c in R.body_axis(tru["q"], 2)]
            err = math.degrees(math.acos(max(-1.0, min(1.0, R.vdot(mz, nadir)))))
            if err < 2.0 and math.degrees(R.vnorm(tru["w"])) < 0.05 and self.truth()["t"] - t0 > 30:
                still += 1
                if still >= 3:
                    break
            else:
                still = 0
        self.press_jets("vern", "coast-lvlh-vern")
        self.say("COAST: the water-dump attitude (-ZLV +YVV): -Z axis %s deg from the nadir after %.0f s; DAP A/AUTO/VERN; DAP attitude error %s"
                 % ("%.2f" % err if err is not None else "?", self.truth()["t"] - t0, (self.compare() or {}).get("dap_att_err")))

    def ev_rambo(self):
        """151/07:33:10 RAMBO-2 'a set of three 10-sec +X firings using the L1A and R1A thrusters' (Mission Report
        FD16; its RCS table lists 10.6 s).  DAP A/AUTO/PRI for the firings, THC +X, then the verniers again."""
        self.press_jets("pri", "coast-rambo-pri")
        t0 = self.truth()["gmt"]
        lines = "".join("+%.1f   thc fwd +x %.1f\n" % (0.0 if i == 0 else 20.0 + self.RAMBO_S, self.RAMBO_S) for i in range(self.RAMBO_PULSES))
        self.play(lines, "coast-rambo")
        self.script_done("coast-rambo", 300)
        self.wait_sim(self.RAMBO_S + 5)
        self.press_jets("vern", "coast-rambo-vern")
        self.say("COAST: RAMBO-2, %d +X firings of %.0f s (L1A, R1A), GMT %.0f to %.0f" % (self.RAMBO_PULSES, self.RAMBO_S, t0, self.truth()["gmt"]))

    @staticmethod
    def gmt_str(g):
        d = int(g // 86400)
        r = g - d * 86400
        return "%03d/%02d:%02d:%02d" % (d, int(r // 3600), int(r % 3600 // 60), int(r % 60))

    def log_nav(self, why):
        c = self.compare() or {}
        tru = self.ears.snap()[0] or {}
        self.say("COAST %s: GMT %.0f (%s), PASS orbiter error %s ft, attitude vs the truth %s deg, DAP error %s, mass %.0f kg"
                 % (why, self.truth()["gmt"], self.gmt_str(self.truth()["gmt"]),
                    c.get("orb_err_ft"), c.get("pass_att_err_deg"), c.get("dap_att_err"), self.orbiter_lb() * 0.45359237))

    def coast(self):
        end = gmt_arg("RETURN_COAST_END", self.COAST_END)
        now = self.truth()["gmt"]
        events = sorted(e for e in self.coast_events() if e[0] > now - 1.0)
        next_log, next_up, next_snap = now + self.COAST_LOG_S, now + self.COAST_UPLINK_S, now + self.COAST_SNAP_S
        n_snap = 0
        self.say("COAST: from GMT %.0f to %.0f (%.1f h) at rate %.1f; events %s"
                 % (now, end, (end - now) / 3600.0, self.a.rate, [(e[1], round(e[0])) for e in events]))
        while True:
            nxt = min([end, next_log, next_up, next_snap] + [events[0][0]] if events else [end, next_log, next_up, next_snap])
            self.wait_gmt(nxt)
            now = self.truth()["gmt"]
            if events and now >= events[0][0] - 0.5:
                gmt, name, fn = events.pop(0)
                self.say("COAST: event %s (scheduled GMT %.0f, now %.0f)" % (name, gmt, now))
                fn()
                continue
            if now >= next_up:
                self.uplink()
                next_up += self.COAST_UPLINK_S
            if now >= next_snap:
                n_snap += 1
                self.snapshot("coast-%02d" % n_snap)
                next_snap += self.COAST_SNAP_S
            if now >= next_log:
                self.log_nav("check")
                next_log += self.COAST_LOG_S
            if now >= end - 0.5:
                break
        self.log_nav("end")

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
        self.dump_screen("OPS 303 after the burn (the Mission Report has a forward RCS dump at TIG+15:56, 11.04 s)")

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
    for ph in ("START", "SEPCFG", "UNDOCK", "FLYAROUND", "SEP1", "SEP2", "NH2", "MC5", "NSR", "TPI", "TDA", "SEP3",      # fly_undock's, so that COAST resumes from sts134r-sep3
               "COAST", "READY", "ORBIT", "DEORBIT", "ENTRY", "LAND", "PRE-MNVR", "BURN"):
        if ph not in R.PHASES:
            R.PHASES.append(ph)
    for a, v in (("--rhc", "both"), ("--station", "all"), ("--input", "virtual")):
        if a not in sys.argv:
            sys.argv += [a, v]
    R.main()


if __name__ == "__main__":
    main()
