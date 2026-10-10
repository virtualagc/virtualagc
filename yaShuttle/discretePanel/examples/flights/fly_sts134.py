#!/usr/bin/env python3
"""FLY STS-134: one GPC, from IPL on the pad to the orbit after OMS 2, by the
book -- the crew's keystrokes, the ground's countdown and uplinks, PASS
doing the flying.

    python3 examples/flights/fly_sts134.py --logs DIR [--port-base N]
                                           [--tape VOLUME] [--from STAGE]
                                           [--to STAGE]

It starts simulatePASS.py and then, phase by phase:

  IPL      one GPC to OPS 9, the launch-day NBAT for memory configurations
           1 and 9, GSE polling on (SPEC 1 ITEM 50)
  UPLINK   the ground: the RNP epoch for 2011 day 136 (message 59) and the
           day-of-launch I-loads (sts134-dolilu.json)
  IMU      SPEC 104: the three IMUs to OPERATE, selected, ATT DET, selected
           again (ATT DET deselects them), GYROCOMP; about 50 minutes
  COUNT    OPS 101; the ground's GMT of liftoff 136/12:56:25 (SRB ignition
           follows 2.8 s later) and RESUME; ends, and is captured, at T minus
           --count-to s (default 5 min) with the stack on the pad
  TERMINAL GO FOR AUTO SEQUENCE at T-31 s and GO FOR ENGINE START at T-10 s,
           by the vehicle's own clock; captured at T-8 s
  ASCENT   PASS's: RSLS, liftoff, SRB and ET separation
  OMS 2    the STS-134 Ascent Checklist's OMS 2 cards: DAP AUTO, OPS 105,
           TRIM LOAD, LOAD, TIMER, MNVR, and EXEC at TIG
  OPS2     the Ascent Checklist's post-burn MAJOR MODE CHANGE (OPS 106 PRO),
           then at MET 0:50 the Post Insertion book's TRANSITION TO GNC
           OPS 2 for a single G2: GPC MEMORY configuration 2 per its table,
           and OPS 201 PRO
  ORBIT    one orbit coasting, the truth's osculating orbit logged
  DEORBIT  the ground's targets for the first KSC 15 opportunity within 550
           n.mi. crossrange (deorbit_target.py, from the ORBIT capture);
           the Entry Checklist (ENT/ALL/GEN H): single-G3 GPC MEMORY and
           OPS 301 at TIG-75, the DEORB MNVR targets (TIG, C1, C2, HT,
           THETA T, PRPLT), LOAD, TIMER and the two-engine trims at TIG-45,
           OPS 302 at TIG-25, MNVR to burn attitude at TIG-20, EXEC at
           TIG-15 s; after the burn OPS 303 and MNVR to the EI attitude
  ENTRY    OPS 304 PRO at EI-5 (ENTRY MANEUVERS cue card) and PASS flying;
           ends at EI+25 min, about TAEM -- the vehicle has no ground or
           landing gear yet

with a capture at the end of each phase (sts134-<phase> in DIR), --from
STAGE to resume from one, and --to STAGE to stop after one.  The vehicle's
clock starts at 2011-05-16 11:30:00 UTC so that liftoff, when the alignment
is done, is at STS-134's own 12:56:27.994.

The STS-134 volume is the generic OI-34 tape with the flight's OPS 1
overlay I-loads (yaGPC2/tools/mission_reconfig.py with
sts134-reconfig.json): make it once with

    python3 yaGPC2/tools/mission_reconfig.py \\
        discretePanel/examples/flights/sts134-reconfig.json VOLUME \\
        --mem <an OPS 1 capture's gpc1.mem.bin> --out STS134.mmv
"""
import argparse
import json
import math
import os
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, PANEL)
import crewscript    # noqa: E402
import groundstation  # noqa: E402

EPOCH = "2011-05-16T11:30:00"
# THE GROUND'S "GMT OF PREDICTED LIFTOFF" IS NOT T-0.  PASS's RSLS starts the
# main engines when the countdown (GMT - GMTLO) passes CGSV_T_SSME_ST, -3.8 s,
# and fires SRB ignition CGSV_T_ENG_OK_CK, 6.6 s, later: T-0 = GMTLO + 2.8 s
# (GSRRSL.hal:370, 379, 822-823, 1859-1872).  GMTLO goes up as whole seconds,
# so for STS-134's SRB ignition at 136/12:56:27.994 the ground sent
# 12:56:25, giving 12:56:27.8 plus the RSLS's own latency.
T0 = 136 * 86400 + 12 * 3600 + 56 * 60 + 27.994        # STS-134's SRB ignition
GMTLO = 136 * 86400 + 12 * 3600 + 56 * 60 + 25.0       # what the ground sends
OMS2_DTIG = 1756.0                                  # after ET separation (DOLILU message 25)
# THE FLIGHT: STS-134 unless --flight FILE names another (a JSON object with
# any of these keys; "t0" and "gmtlo" as [day, h, m, s]; "env" extra
# environment for the vehicle, e.g. vehdyn's YAGPC_VEHDYN_ET_LB)
FL = {"name": "sts134", "dolilu": "sts134-dolilu.json", "rnp": [2011, 136],
      "orbiter_kg": 121912, "oms2_hp": 124.3, "oms2_ha": 175.8,
      # the day's air and wind for the truth (vehdyn); the same sounding
      # makes the DOLILU's wind table (message 11).  A flight file's
      # relative sounding path is taken from this directory.
      # The truth flies the air at launch, 12:56Z: the 12Z and 15Z Cape
      # soundings interpolated in time.  PASS's table is from 12Z alone, the
      # last balloon before launch (none earlier is archived for 74794).
      "env": {"YAGPC_VEHDYN_SOUNDING": "sts134-sounding-74794-20110516-1256Z.csv"}}
PHASES = ["IPL", "UPLINK", "IMU", "COUNT", "TERMINAL", "ASCENT", "OMS2", "OPS2", "ORBIT", "DEORBIT", "ENTRY", "LAND"]

IPL_SCRIPT = """
+0     gpc 1
+0     mode HALT
+0.02  idppower 1 on
+0.01  script {panel}/examples/ipl-one-gpc.script gpc=1 crt=1 idp=1 kb=KB1
{nbat1}
# the same NBAT for memory configuration 9 (OPS 9): otherwise string 1 alone
+8     keys ITEM 1 + 9 EXEC
{nbat}
+21    keys OPS 9 0 1 PRO
# GSE POLL ENABLE: the launch data bus to the ground (DPS UTILITY, OPS 9)
+40    keys SPEC 1 PRO
+5     keys ITEM 5 0 EXEC
+10    keys SPEC 1 0 4 PRO
"""
NBAT_ITEMS = ["2 + 1", "3 + 0", "4 + 0", "5 + 0", "7 + 1", "8 + 1", "9 + 1",
              "1 0 + 1", "1 1 + 1", "1 2 + 1", "1 8 + 1", "1 9 + 1"]

IMU_OPER = """
+1     keys ITEM 1 3 EXEC
+3     keys ITEM 1 4 EXEC
+3     keys ITEM 1 5 EXEC
"""
IMU_ATTDET = """
+1     keys ITEM 1 6 EXEC
+3     keys ITEM 1 7 EXEC
+3     keys ITEM 1 8 EXEC
+5     keys ITEM 1 9 EXEC
"""
IMU_GYROCOMP = """
+1     keys ITEM 1 6 EXEC
+3     keys ITEM 1 7 EXEC
+3     keys ITEM 1 8 EXEC
+3     keys ITEM 2 4 EXEC
"""
OMS2_SETUP = """
# STS-134 Ascent Checklist (ASC/134/FIN) 3-3..3-7: MAJOR MODE CHANGE, OMS 2 BURN SETUP
+1     dap c3 auto
+5     keys OPS 1 0 5 PRO
+20    keys ITEM 6 + 0 . 4 - 5 . 7 + 5 . 7 EXEC
+5     keys ITEM 2 2 EXEC
+5     keys ITEM 2 3 EXEC
+10    keys ITEM 2 7 EXEC
"""
# STS-134 Ascent Checklist (ASC/134/FIN) 5-2, after the post-burn checks:
# MAJOR MODE CHANGE, "CRT1 GNC, OPS 106 PRO".
OPS106 = """
+1     keys OPS 1 0 6 PRO
"""
# STS-134 Post Insertion (PI/134/FIN) 1-2, CONFIG GPCs FOR OPS 2, step 4
# TRANSITION TO GNC OPS 2, the SINGLE G2 column: GNC 0 GPC MEMORY,
# CONFIG - ITEM 1 +2 EXEC, "Modify MC 2 per table" -- GPC 10000; STR 1-4
# to GPC 1; PL 1/2 0; CRT 1,2,4 to 1, CRT 3 0; L 1,2 0; MM 1,2 to 1 -- then
# GNC, OPS 201 PRO, whose base page is GNC UNIV PTG.  Steps 1-3 (freeze-
# drying a second GPC) and the BFC CRT switch steps belong to the
# redundant set and the BFS, which a one-GPC vehicle has not got.  GPC
# MEMORY's items 2-6 are the GPCs, 7-19 the buses: STR 1-4, PL 1/2, CRT
# 1-4, L 1-2, MM 1-2 (CD0001.dfg, CZ2V_STRNG_MC 1-13).
OPS201_ITEMS = ["2 + 1", "3 + 0", "4 + 0", "5 + 0", "6 + 0",
                "7 + 1", "8 + 1", "9 + 1", "1 0 + 1", "1 1 + 0",
                "1 2 + 1", "1 3 + 1", "1 4 + 0", "1 5 + 1",
                "1 6 + 0", "1 7 + 0", "1 8 + 1", "1 9 + 1"]
OPS201 = ("+1     keys SPEC 0 PRO\n"
          "+5     keys ITEM 1 + 2 EXEC\n"
          + "".join("+8     keys ITEM %s EXEC\n" % i for i in OPS201_ITEMS)
          + "+10    keys OPS 2 0 1 PRO\n"
          "wait crt 1 title 2011/ timeout 600\n"
          "+5     subtitle\n")

# THE OPS 3 TRANSITION for a single G3: the OPS 201 single-G2 GPC MEMORY
# table with memory configuration 3 (Entry Checklist ENT/ALL/GEN H deorbit
# prep; the bus items are the same strings).
OPS301 = ("+1     keys SPEC 0 PRO\n"
          "+5     keys ITEM 1 + 3 EXEC\n"
          + "".join("+8     keys ITEM %s EXEC\n" % i for i in OPS201_ITEMS)
          + "+10    keys OPS 3 0 1 PRO\n"
          "wait crt 1 title 3011/ timeout 900\n"
          "+5     subtitle\n")
# ENT/ALL/GEN H 3-9..3-10: TIG-25 "GNC, OPS 302 PRO"; TIG-20 "MNVR - ITEM 27
# EXEC"; 3-25 "TIG-:15 EXEC".  The two-engine trims are 3-8's "L,R - ITEM 6
# +0.0 -5.7 +5.7 EXEC".
# --g3-from-mm ONLY: DPS UTILITY ITEM 49 turns the G3 archive retrieve off,
# so OPS 3 loads G3 from mass memory.  A WORKAROUND for captures made before
# yaGPC2 c87bce8b6 (ledger #283), whose archive was "stored" empty at launch
# and would be retrieved over G3.  Never the default: a flight launched on a
# fixed emulator retrieves G3 from upper memory, as the real one did.
G3_FROM_MM = ("+1     keys SPEC 1 PRO\n"
              "+8     keys ITEM 4 9 EXEC\n"
              "+8     keys RESUME\n")
# GPS INCORPORATE: SPEC 50, NAV GPS item 44 (FORCE), back to the display it
# came from -- Deorbit Prep at the targets ("G50,B50 GPS, INCORPORATE") and
# the Entry Checklist at V = 7K (ENT/134/FIN FS 3-34).  Legal only with the
# mission I-load CGNS_GPS_LOCKOUT >= 3 (tools/sites/sts134-gps-lockout.json,
# on the ksc4 volume); a generic tape rejects it as an ILLEGAL ENTRY.
GPS_INCORPORATE = ("+1     keys SPEC 5 0 PRO\n"
                   "+3     keys ITEM 4 4 EXEC\n"
                   "+3     keys RESUME\n")
# DEVELOPMENT ONLY, with --incorporate-at-land: SPEC 55 ITEM 38, METERING
# OVERRIDE (a toggle; legal in MM 301-603, GKAGPS.hal CASE_10).  A capture
# resumed in TAEM can carry a nav error of 30,000 ft; incorporated, PASS meters
# it into the guidance state at ~130 ft/s and in MM 305 keeps metering until
# the relative velocity is below 200 ft/s -- past touchdown -- so guidance
# flies 7-16 kft off.  A flight that incorporates at the checklist's points
# never builds that error and never needs this.
METERING_OVERRIDE = ("+1     keys SPEC 5 5 PRO\n"
                     "+3     keys ITEM 3 8 EXEC\n"
                     "+3     keys RESUME\n")
# V = 7K, ENT/134/FIN FS 3-34: "ADTA PROBES - DEPLOY (HEAT)"; and ADTA to
# G&C AUT (SPEC 50 ITEM 28, the checklist's "ADTA AUT 28"), so PASS takes the
# probes' air data into guidance and control once V < 2500 ft/s ("M = 2.0
# Ensure ADTA to G&C") instead of its drag-derived estimate.
AIR_DATA = ("+1     switch adp_l DEPLOY\n"
            "+1     switch adp_r DEPLOY\n"
            "+1     keys SPEC 5 0 PRO\n"
            "+3     keys ITEM 2 8 EXEC\n"
            "+3     keys RESUME\n")
OPS302 = "+1     keys OPS 3 0 2 PRO\n"
DEORB_MNVR = "+1     dap c3 auto\n+5     keys ITEM 2 7 EXEC\n"
ENTRY_OPS304 = "+1     keys OPS 3 0 4 PRO\nwait crt 1 title 3041/ timeout 120\n"


def keys_signed(x, fmt):
    """A number as DEORB MNVR keystrokes: its sign, then digit by digit."""
    t = fmt % abs(x)
    return ("- " if x < 0 else "+ ") + " ".join(t)


class Flight:
    def __init__(self, a):
        self.a = a
        self.base = a.port_base
        self.log = os.path.join(a.logs, "logs", "yaGPC2.log")

    def say(self, text):
        print("fly_sts134: %s" % text, flush=True)

    # --- the vehicle ----------------------------------------------------
    def start(self, resume=None):
        fenv = {k: (os.path.join(HERE, v) if k == "YAGPC_VEHDYN_SOUNDING" and not os.path.isabs(v) else v)
                for k, v in FL["env"].items()}
        env = dict(os.environ, YAGPC_MDM_DEVICES="1", YAGPC_VEHDYN="1", YAGPC_VEHDYN_PAD="1",
                   YAGPC_VEHDYN_ORBITER_KG=str(FL["orbiter_kg"]), YAGPC_OMS_ARMED="1",
                   YAGPC_RNP="%d,%d" % tuple(FL["rnp"]), YAGPC_VEHDYN_STATELOG=os.environ.get("FLY_STATELOG", "5"),
                   PYTHONUNBUFFERED="1", **fenv)
        cmd = [sys.executable, "-u", os.path.join(PANEL, "simulatePASS.py"), "--gpcs", "1",
               "--crts", str(self.a.crts), "--tape", self.a.tape, "--no-wait-user", "--size", "384",
               "--port-base", str(self.base), "--logs", os.path.join(self.a.logs, "logs"),
               "--snapshot-dir", self.a.logs, "--duration", "20000"]
        cmd += ["--snapshot-resume", resume] if resume else ["--date-time-epoch", EPOCH]
        if self.a.rate != 1.0:                   # simulated seconds per wall second
            cmd += ["--rt-factor", "%g" % self.a.rate]
        if not self.a.portview:                  # the out-the-window views: opt in
            cmd += ["--no-portview"]
        if os.environ.get("FLY_YAGPC"):          # another build, for bisecting
            cmd += ["--yagpc", os.environ["FLY_YAGPC"]]
        os.makedirs(self.a.logs, exist_ok=True)
        # a fresh output file, so that an earlier run's lines are never taken
        # for this one's (a run still up on the port refuses to start)
        outp = os.path.join(self.a.logs, "simulatePASS.out")
        if os.path.exists(outp):
            os.replace(outp, outp + ".%d" % int(time.time()))
        self.out = open(outp, "w")
        self.proc = subprocess.Popen(cmd, env=env, stdout=self.out, stderr=subprocess.STDOUT,
                                     stdin=subprocess.DEVNULL, cwd=PANEL)
        self.wait_file(outp, "session commands on port", 180)
        time.sleep(5)

    def wait_file(self, path, text, timeout, after=0):
        """text in path, looking only past byte offset after."""
        end = time.time() + timeout
        while time.time() < end:
            if getattr(self, "proc", None) is not None and self.proc.poll() is not None:
                # and why, in its own words: "has exited" alone sent the owner
                # looking (a missing --layout file, 2026-10-09)
                outp = os.path.join(self.a.logs, "simulatePASS.out")
                why = ""
                try:
                    lines = [l.strip() for l in open(outp, errors="replace") if l.strip()]
                    why = (": " + lines[-1]) if lines else ""
                except OSError:
                    pass
                raise SystemExit("fly_sts134: simulatePASS.py has exited%s (%s)" % (why, outp))
            try:
                with open(path, "rb") as fh:
                    fh.seek(after)
                    if text in fh.read().decode("utf-8", "replace"):
                        return True
            except OSError:
                pass
            time.sleep(2)
        raise SystemExit("fly_sts134: '%s' never appeared in %s" % (text, path))

    def panel_size(self):
        try:
            return os.path.getsize(os.path.join(self.a.logs, "logs", "panel.log"))
        except OSError:
            return 0

    def play(self, text, name):
        # WHERE THE PANEL LOG STOOD when this script was sent: its steps are
        # looked for only after it.  A script's last line can repeat an
        # earlier script's ("+5 subtitle" ends both OPS 201 and OPS 301), and
        # searching the whole log matched OPS 201's at once (2026-10-06).
        self.played_at = self.panel_size()
        path = os.path.join(self.a.logs, name + ".script")
        with open(path, "w") as fh:
            fh.write(text.lstrip())
        crewscript.send_control("play %s" % path, self.base)
        self.say("crew: %s" % name)
        self.wait_file(os.path.join(self.a.logs, "logs", "panel.log"),
                       "script command: play %s" % path, 60, after=self.played_at)

    def script_done(self, name, timeout):
        path = os.path.join(self.a.logs, name + ".script")
        n = sum(1 for l in open(path) if l.strip() and not l.lstrip().startswith("#"))
        # the panel logs every step; done when its last line has been logged
        last = [l for l in open(path) if l.strip() and not l.lstrip().startswith("#")][-1].strip()
        self.wait_file(os.path.join(self.a.logs, "logs", "panel.log"), last, timeout,
                       after=getattr(self, "played_at", 0))
        # ...but a step is logged when it STARTS: a `keys` line is still being
        # typed (about 0.35 s a key), and a script played meanwhile stops this
        # one (panelO6.py 5571), which drops its last keys without a word.
        # Mac-portview found [10A] SPEC 21 ITEM 7 EXEC losing its "7 EXEC",
        # and ITEM 7 toggles, so [10B] then DESELECTED IMU 1; dock5 lost the
        # end of a DAP-button script, and dock4-dock10 the last pulses of THC
        # trains (2026-10-09).  Done is "script complete" (crewscript.py
        # 1516), which a stopped player never logs.
        self.wait_file(os.path.join(self.a.logs, "logs", "panel.log"), "script complete", timeout,
                       after=getattr(self, "played_at", 0))
        return n

    def truth(self):
        # the feed goes quiet while the GPC is off its buses -- an OPS
        # transition reloading from mass memory takes tens of seconds
        for _ in range(100):
            tr = groundstation.truth_state(self.base, timeout=3.0)
            if tr:
                return tr
        raise SystemExit("fly_sts134: no truth state for five minutes")

    def wait_gmt(self, gmt):
        while True:
            now = self.truth()["gmt"]
            if now >= gmt:
                return
            time.sleep(min(30.0, max(0.5, (gmt - now) / 2.0)))

    def wait_sim(self, dt):
        t0 = self.truth()["t"]
        while self.truth()["t"] < t0 + dt:
            time.sleep(min(30.0, max(0.5, dt / 20.0)))

    def snapshot(self, name):
        target = os.path.join(self.a.logs, FL["name"] + "-" + name)
        crewscript.send_session("save %s" % target, self.base)
        self.wait_file(os.path.join(target, "vehicle.json"), "{", 180)
        self.say("captured %s" % target)

    def log_text(self):
        try:
            return open(self.log, errors="replace").read()
        except OSError:
            return ""

    # --- the phases -------------------------------------------------------
    def ipl(self):
        nbat = "\n".join("+8     keys ITEM %s EXEC" % i for i in NBAT_ITEMS)
        nbat1 = "+11    keys ITEM 1 + 1 EXEC\n" + nbat
        self.play(IPL_SCRIPT.format(panel=PANEL, nbat1=nbat1, nbat=nbat), "ipl")
        self.script_done("ipl", 900)
        self.wait_sim(10)

    def uplink(self):
        link = groundstation.Link(self.base)
        link.send_message(groundstation.two_stage(groundstation.OP_RNP, list(FL["rnp"])))
        self.say("ground: RNP epoch %d day %d (message 59)" % tuple(FL["rnp"]))
        time.sleep(3)
        subprocess.run([sys.executable, os.path.join(PANEL, "groundstation.py"), "--port-base",
                        str(self.base), "dolilu", os.path.join(HERE, FL["dolilu"])], check=True)
        self.wait_sim(10)

    def imu(self):
        self.play(IMU_OPER, "imu-oper")
        while self.log_text().count("IN OPERATE") < 3:
            time.sleep(5)
        self.wait_sim(10)
        self.play(IMU_ATTDET, "imu-attdet")
        self.wait_sim(300)                  # ATT DET: thermal stabilization 180 s and data
        self.play(IMU_GYROCOMP, "imu-gyrocomp")
        self.wait_sim(3000)                 # two positions, each ~3 min to stabilize + 10 min data
        self.say("gyrocompass alignment: the time it took on the ground (47 min) has passed")

    def count(self):
        if self.a.reuplink:
            # the day-of-launch I-loads again, in OPS 9, before OPS 101: a
            # revised DOLILU onto an already-aligned vehicle
            subprocess.run([sys.executable, os.path.join(PANEL, "groundstation.py"), "--port-base",
                            str(self.base), "dolilu", os.path.join(HERE, FL["dolilu"])],
                           check=True)
            self.wait_sim(10)
        self.play("+1     keys OPS 1 0 1 PRO\n", "ops101")
        self.wait_sim(40)
        crewscript.send_lps("gmtlo =%.0f" % GMTLO, self.base)
        time.sleep(2)
        crewscript.send_lps("resume", self.base)
        g = int(GMTLO)
        self.say("ground: GMT of liftoff %03d/%02d:%02d:%02d (T-0 2.8 s later), count resumed"
                 % (g // 86400, g % 86400 // 3600, g % 3600 // 60, g % 60))
        # the phase ends -- and its capture is taken -- at T - --count-to s, so
        # that --from TERMINAL restores a stack sitting on the pad with the
        # count running, for as long as a viewer wants to watch it there
        self.wait_gmt(T0 - self.a.count_to)
        self.say("count: T-%.0f s" % self.a.count_to)

    def terminal(self):
        """The ground's last two calls, by the vehicle's own clock; a call
        whose time has already passed (a capture restored later) is skipped."""
        if self.truth()["gmt"] > T0 - 31.0:
            self.say("terminal: restored after T-31 s; GO FOR AUTO SEQUENCE not sent")
        else:
        # the GLS's own times (KLO-82-0071 App A): GO FOR AUTO SEQUENCE at
        # T-31 s -- PASS acts on it from GMTLO - 25 s, CGSV_LPS_GO_AUTO_SEQ_TIME
        # -- and GO FOR ENGINE START at about T-10 s
            self.wait_gmt(T0 - 31.0)
            crewscript.send_lps("go_auto", self.base)
            self.say("ground: GO FOR AUTO SEQUENCE (T-31 s)")
        if self.truth()["gmt"] > T0 - 10.0:
            self.say("terminal: restored after T-10 s; GO FOR ENGINE START not sent")
        else:
            self.wait_gmt(T0 - 10.0)
            crewscript.send_lps("go_engine", self.base)
            self.say("ground: GO FOR ENGINE START (T-10 s)")
        self.wait_gmt(T0 - 8.0)

    def ascent(self):
        aborted = not self.a.abort
        while "ET SEPARATION at" not in self.log_text():
            if not aborted:
                m = re.search(r"eiu: ME\d FAILED at t=[\d.]+", self.log_text())
                if m:
                    # the crew's minimum (ASC/134 cue cards' boundaries are
                    # the caller's: it picks the failure time and the mode):
                    # ABORT MODE rotary to the mode, ABORT pb, rotary OFF
                    self.wait_sim(self.a.abort_react)
                    self.play("+0     switch abort_mode %s\n+1     press abort_pb\n"
                              "+3     switch abort_mode OFF\n" % self.a.abort, "abort")
                    self.say("crew: %s seen; ABORT MODE %s, ABORT pb" % (m.group(0), self.a.abort))
                    aborted = True
            time.sleep(1 if not aborted else 5)
        # ET separation in the vehicle's GMT, from the time-tagged state lines
        # around it, kept for OMS 2 (which may start from a capture)
        text = self.log_text()
        tsep = float(re.search(r"vehdyn: ET SEPARATION at t=([\d.]+)", text).group(1))
        rows = [(float(m.group(1)), float(m.group(2))) for m in
                re.finditer(r"vehdyn-state: t=([\d.]+) gmt=([\d.]+)", text)]
        t, g = min(rows, key=lambda x: abs(x[0] - tsep))
        with open(os.path.join(self.a.logs, "etsep.gmt"), "w") as fh:
            fh.write("%.3f\n" % (g + tsep - t))
        self.say("ET separation at GMT %.3f" % (g + tsep - t))
        self.wait_sim(20)

    def oms2_targets(self):
        """THE GROUND'S OMS-2 TARGETS from the actual insertion: the truth
        state after ET separation coasted to TIG (standing in for Mission
        Control's tracking), designed with omstarget.py for STS-134's
        124.3 x 175.8 nmi, and uplinked as message 25 (legal in OPS 1,
        GTCUPL) -- as the ground updated OMS-2 targets after MECO."""
        omst = os.path.join(PANEL, "omstarget.py")
        state = os.path.join(self.a.logs, "oms2-state.json")
        log = self.log if "ET SEPARATION at" in self.log_text() else None
        if log is None:
            self.say("no ET separation in this run's log: OMS-2 targets as uplinked before launch")
            return
        subprocess.run([sys.executable, omst, "fromlog", log, "%.1f" % OMS2_DTIG, state], check=True)
        # the reports give HA x HP above a spherical Earth of the mean radius,
        # 6,371 km -- 3.854 nmi below the equatorial radius omstarget and PASS
        # measure from: STS-134's 124.3 x 175.8 for 259.2 ft/s is unreachable
        # otherwise, and taken so it designs to 262.0 (flight sts134d)
        mr = (6378137.0 - 6371000.0) / 1852.0
        out = subprocess.run([sys.executable, omst, "design", state, "%.2f" % (FL["oms2_hp"] - mr),
                              "%.2f" % (FL["oms2_ha"] - mr)], check=True,
                             capture_output=True, text=True).stdout
        m = re.search(r"HT ([\d.]+)\s+THETA T ([\d.]+)", out)
        ht, th = float(m.group(1)), float(m.group(2))
        dol = json.load(open(os.path.join(HERE, FL["dolilu"])))
        msg = [x for x in dol["messages"] if x["op"] == 25][0]
        msg["fields"][3]["E"] = [OMS2_DTIG, ht, th, 0.0, 0.0]
        path = os.path.join(self.a.logs, "oms2-targets.json")
        json.dump({"messages": [msg]}, open(path, "w"), indent=1)
        subprocess.run([sys.executable, os.path.join(PANEL, "groundstation.py"), "--port-base",
                        str(self.base), "dolilu", path], check=True)
        self.say("ground: OMS-2 targets HT %.2f THETA T %.2f uplinked (%s)"
                 % (ht, th, out.strip().splitlines()[-1]))

    def oms2(self):
        etsep = float(open(os.path.join(self.a.logs, "etsep.gmt")).read())
        tig = etsep + OMS2_DTIG
        self.wait_gmt(etsep + 120.0)
        self.oms2_targets()
        self.wait_gmt(etsep + 600.0)        # the post-MECO procedures first
        self.play(OMS2_SETUP, "oms2-setup")
        self.wait_gmt(tig - 8.0)
        self.play("+0     keys EXEC\n", "oms2-exec")
        self.say("crew: EXEC at TIG-8 s (TIG GMT %.1f)" % tig)
        self.wait_gmt(tig + 300.0)

    def ops2(self):
        # PRO to post-OMS-2 coast once the burn is done and checked; the
        # OMS 2 phase ends at TIG + 300 s
        self.play(OPS106, "ops106")
        self.script_done("ops106", 120)
        # the Post Insertion timeline puts CONFIG GPCs FOR OPS 2 at MET 0:50
        self.wait_gmt(T0 + 50 * 60.0)
        self.play(OPS201, "ops201")
        self.script_done("ops201", 900)
        self.say("OPS 201: GNC UNIV PTG on CRT 1")
        self.wait_sim(30)

    def orbit(self):
        self.wait_sim(5600)
        orb = [l for l in self.log_text().splitlines() if l.startswith("vehdyn-orbit")]
        self.say("%d orbit samples; last: %s" % (len(orb), orb[-1] if orb else "none"))

    # --- deorbit and entry -------------------------------------------------
    def deorbit_targets(self):
        """THE GROUND'S DEORBIT TARGETS from the truth at the ORBIT capture:
        deorbit_target.py, standing in for Mission Control's tracking."""
        cap = os.path.join(self.a.logs, FL["name"] + "-orbit")
        site = os.path.join(PANEL, "..", "yaGPC2", "tools", "sites", "ksc.json")
        out = subprocess.run([sys.executable, os.path.join(PANEL, "deorbit_target.py"), cap, site],
                             check=True, capture_output=True, text=True).stdout
        for line in out.strip().splitlines():
            self.say("ground: " + line.strip())
        g = lambda pat: re.search(pat, out)
        def gmt(s):
            d, h, m, sec = re.match(r"(\d+)/(\d+):(\d+):([\d.]+)", s).groups()
            return int(d) * 86400 + int(h) * 3600 + int(m) * 60 + float(sec)
        tig = gmt(g(r"TIG GMT (\S+)").group(1))
        ei = gmt(g(r"EI GMT (\S+)").group(1))
        theta = float(g(r"THETA T ([\d.]+)").group(1))
        dv = float(g(r"impulsive dV ([\d.]+)").group(1))
        c1 = float(g(r"C1 (-?[\d.]+)").group(1))
        c2 = float(g(r"C2 ([-+][\d.]+)").group(1))
        ht = float(g(r"HT ([\d.]+)").group(1))
        # PRPLT: the propellant the burn needs (no out-of-plane waste), from
        # the truth's mass: 2 OMS, Isp 316 s (VEX 10136.8 ft/s, FSSR K-loads)
        vd = json.load(open(os.path.join(cap, "vehdyn.json")))["vehdyn"]
        kg = vd[-1] + sum(vd[16:21])
        prplt = kg / 0.45359237 * (1.0 - math.exp(-dv / 10136.8))
        return dict(tig=tig, ei=ei, theta=theta, c1=c1, c2=c2, ht=ht, prplt=prplt)

    def deorbit(self):
        t = self.deorbit_targets()
        self.tgt = t
        json.dump(t, open(os.path.join(self.a.logs, "deorbit-targets.json"), "w"), indent=1)
        tig = t["tig"]
        self.wait_gmt(tig - 75 * 60.0)
        if self.a.attach:
            # --attach: the running vehicle's OPS 301 script was sent by the
            # driver that stopped; wait for that one, from where it was played.
            with open(os.path.join(self.a.logs, "logs", "panel.log"), "rb") as fh:
                at = fh.read().rfind(b"script command: play %s"
                                     % os.path.join(self.a.logs, "ops301.script").encode())
            if at < 0:
                raise SystemExit("fly_sts134: --attach, but no OPS 301 script was played")
            self.played_at = at
        elif self.a.g3_from_mm:
            self.say("WORKAROUND --g3-from-mm: ITEM 49 off, G3 from mass memory, not the archive")
            self.play(G3_FROM_MM + OPS301, "ops301")
        else:
            self.play(OPS301, "ops301")
        self.script_done("ops301", 1200)
        # THE TRANSITION MUST HAVE HAPPENED before anything else is keyed:
        # the next steps are ITEM entries, and on the GPC MEMORY page that a
        # failed transition leaves up, ITEMs 10-19 are the string and CRT
        # assignments (2026-10-06: OPS 301 accepted, G3 never loaded).
        with open(os.path.join(self.a.logs, "logs", "panel.log"), "rb") as fh:
            fh.seek(self.played_at)
            met = [l for l in fh.read().decode("utf-8", "replace").splitlines()
                   if "wait met after" in l and "title 3011/" in l]
        if not met:
            raise SystemExit("fly_sts134: OPS 301 did not complete (no DEORB MNVR COAST on CRT 1) "
                             "-- stopping before the deorbit targets are keyed")
        self.say("crew: OPS 301 (single G3)")
        # TIG-45: the DEL PAD read up, the targets keyed on DEORB MNVR COAST
        self.wait_gmt(tig - 45 * 60.0)
        met = tig - T0
        d, rem = divmod(met, 86400.0)
        hh, rem = divmod(rem, 3600.0)
        mm, ss = divmod(rem, 60.0)
        script = ("+1     keys ITEM 1 0 + %s + %s + %s + %s EXEC\n"
                  % (" ".join("%d" % d), " ".join("%d" % hh), " ".join("%d" % mm), " ".join("%.1f" % ss)))
        # ONE ITEM AT A TIME, C1 first.  The five-field entry "ITEM 14 C1 C2
        # HT THETA PRPLT EXEC" was refused as a whole on 2026-10-06 (PEG 4
        # left at its defaults, PEG 7 still loaded, LOAD solved a 370 ft/s
        # burn).  C1 alone was taken and cleared PEG 7, and the other four
        # then went in one by one; why the combined entry was refused is not
        # established (the message line is not logged).
        for item, v, fmt in ((14, t["c1"], "%.0f"), (15, t["c2"], "%.4f"), (16, t["ht"], "%.3f"),
                             (17, t["theta"], "%.3f"), (18, t["prplt"], "%.0f")):
            script += "+4     keys ITEM %s %s EXEC\n" % (" ".join(str(item)), keys_signed(v, fmt))
        script += ("+5     keys ITEM 6 + 0 . 0 - 5 . 7 + 5 . 7 EXEC\n"
                   "+5     keys ITEM 2 2 EXEC\n"
                   "+5     keys ITEM 2 3 EXEC\n")
        open(os.path.join(self.a.logs, "deorb-targets.script"), "w").write(script)
        self.play(script, "deorb-targets")
        self.script_done("deorb-targets", 300)
        self.say("crew: DEORB MNVR targets loaded (MET TIG %d/%02d:%02d:%04.1f)" % (d, hh, mm, ss))
        self.play(GPS_INCORPORATE, "gps-incorporate-deorbit")
        self.script_done("gps-incorporate-deorbit", 60)
        self.say("crew: GPS INCORPORATE (SPEC 50 ITEM 44)")
        self.wait_gmt(tig - 25 * 60.0)
        self.play(OPS302, "ops302")
        self.wait_gmt(tig - 20 * 60.0)
        self.play(DEORB_MNVR, "deorb-mnvr")
        self.wait_gmt(tig - 15.0)
        self.play("+0     keys EXEC\n", "deorb-exec")
        self.say("crew: EXEC at TIG-15 s (TIG GMT %.1f)" % tig)
        # the burn (about 2.5 min), the trim of the residuals, then MM 303 and
        # the maneuver to the EI-5 attitude
        self.wait_gmt(tig + 6 * 60.0)
        # THE TRANSITION BEFORE ANYTHING ELSE: the DEORBIT capture follows this,
        # and one taken before PASS had reached MM 303 (2026-10-06) restored a
        # vehicle still in MM 302, where OPS 304 is illegal -- it entered
        # tail-first and skipped out.
        self.play("+1     keys OPS 3 0 3 PRO\n"
                  "wait crt 1 title 3031/ timeout 120\n"
                  "+3     keys ITEM 2 7 EXEC\n", "ops303")
        self.script_done("ops303", 180)
        self.say("crew: OPS 303, MNVR to EI attitude")

    PFD_ON_CRT2 = ("+1     idppower 2 on\n"
                   # PASS loads IDP 2 itself once it is powered (IPL_REQUIRED,
                   # then the format fills) -- measured 2026-10-06, about 5 s
                   "+10    edgekey crt2 1\n"          # UP: the main menu
                   "+2     edgekey crt2 2\n"          # FLT INST
                   "+2     edgekey crt2 2\n")         # A/E PFD

    def pfd_on_crt2(self):
        """THE OWNER'S PFD: CRT 2 powered and showing the A/E PFD, as a pilot's
        MDU would through entry and landing.  CRT 1 stays the crew's DPS
        display, where the driver keys."""
        if self.a.crts < 2 or getattr(self, "pfd_up", False):
            return
        self.play(self.PFD_ON_CRT2, "pfd-crt2")
        self.script_done("pfd-crt2", 120)
        self.pfd_up = True
        self.say("crew: A/E PFD on CRT 2")

    def entry(self):
        t = getattr(self, "tgt", None) or json.load(open(os.path.join(self.a.logs, "deorbit-targets.json")))
        self.wait_gmt(t["ei"] - 5 * 60.0)
        self.play(ENTRY_OPS304, "ops304")
        self.script_done("ops304", 180)
        self.say("crew: OPS 304 at EI-5")
        self.pfd_on_crt2()
        # V = 7K: GPS INCORPORATE (Entry Checklist FS 3-34)
        while True:
            tr = self.truth()
            if tr.get("gs_kt", 1e9) * 0.514444 / 0.3048 < 7000.0 or tr["gmt"] > t["ei"] + 25 * 60.0:
                break
            time.sleep(2.0)
        self.play(GPS_INCORPORATE, "gps-incorporate-entry")
        self.script_done("gps-incorporate-entry", 60)
        self.say("crew: V = 7K, GPS INCORPORATE (SPEC 50 ITEM 44)")
        self.play(AIR_DATA, "air-data")
        self.script_done("air-data", 60)
        self.air_data_done = True
        self.say("crew: V = 7K, ADTA PROBES DEPLOY; ADTA to G&C AUT (SPEC 50 ITEM 28)")
        self.wait_gmt(t["ei"] + 25 * 60.0)

    def last_entry_state(self):
        """The newest vehdyn-entry line's numbers: h (ft), M, and t."""
        for l in reversed(self.log_text().splitlines()):
            if l.startswith("vehdyn-entry:"):
                f = dict(re.findall(r"(\w+)=([-0-9.]+)", l))
                return {k: float(v) for k, v in f.items() if k in ("t", "h", "M", "alpha", "q")}
        return None

    # THE LANDING'S CREW ACTIONS (STS-134 Entry cue cards; gear-rollout
    # findings): gear ARM at 2000 ft and DN at 300 ft wheel height; the drag
    # chute at main-gear touchdown; brakes once the nose is down and below
    # 120 KGS; the chute off at 60 KGS; wheels stop.  The landing gear and the
    # chute are hardwired (panel F6, F2) -- PASS commands neither.
    GEAR_ARM_FT, GEAR_DN_FT = 2000.0, 300.0
    BRAKES_KGS, CHUTE_JETT_KGS = 120.0, 60.0

    def wheels_and_speed(self, tr):
        """Main-wheel height above the runway (ft) and ground speed (kt): the
        crew's eyes and their airspeed / ground-speed cues, from the truth
        feed (vehdyn_ground_state)."""
        return tr.get("wheel_ft", 1e9), tr.get("gs_kt", 0.0)

    def land(self):
        """TAEM, approach and landing: PASS flies (MM 305 follows MM 304 by
        itself, autoland in A/L); the crew deploys the gear and the drag
        chute and brakes; until the wheels stop or the time runs out."""
        self.pfd_on_crt2()
        if self.a.abort in ("RTLS", "TAL"):
            # an abort's entry flies itself (MM 304 after a TAL's ET SEP; RTLS
            # MM 601-603 then 305): the air data probes at Mach 5, not before
            while (self.last_entry_state() or {}).get("M", 99.0) > 5.0:
                time.sleep(2.0)
        if not getattr(self, "air_data_done", False):    # resumed past V = 7K
            self.play(AIR_DATA, "air-data")
            self.script_done("air-data", 60)
            self.air_data_done = True
            self.say("crew: ADTA PROBES DEPLOY; ADTA to G&C AUT (at the start of LAND)")
        if self.a.incorporate_at_land:
            self.play(GPS_INCORPORATE, "gps-incorporate-land")
            self.script_done("gps-incorporate-land", 60)
            self.say("crew: GPS INCORPORATE at the start of LAND (--incorporate-at-land)")
            self.play(METERING_OVERRIDE, "metering-override-land")
            self.script_done("metering-override-land", 60)
            self.say("crew: SPEC 55 METERING OVERRIDE (--incorporate-at-land)")
        t_end = self.truth()["t"] + self.a.land_time
        last, done = None, set()
        log0 = len(self.log_text())
        stopped_since = None
        while True:
            tr = self.truth()
            if tr["t"] >= t_end:
                self.say("land: time is up")
                return
            wh, kgs = self.wheels_and_speed(tr)
            text = self.log_text()[log0:]
            st = self.last_entry_state()
            if st and st != last:
                last = st
                self.say("land: t=%.0f h=%.0f ft (wheels %.0f) M=%.3f alpha=%.1f q=%.0f GS %.0f kt"
                         % (st["t"], st["h"], wh, st["M"], st.get("alpha", 0), st.get("q", 0), kgs))
            if "arm" not in done and wh < self.GEAR_ARM_FT:
                self.play("+0     press gear_arm\n", "gear-arm"); done.add("arm")
                self.say("crew: LANDING GEAR ARM at %.0f ft" % wh)
            if "dn" not in done and "arm" in done and wh < self.GEAR_DN_FT:
                self.play("+0     press gear_dn\n", "gear-dn"); done.add("dn")
                self.say("crew: LANDING GEAR DN at %.0f ft, %.0f KGS" % (wh, kgs))
            if "chute" not in done and "MAIN gear TOUCHDOWN" in text:
                self.play("+0     press chute_arm\n+1     press chute_dpy\n", "chute"); done.add("chute")
                self.say("crew: DRAG CHUTE ARM, DPY at main-gear touchdown, %.0f KGS" % kgs)
            if "brakes" not in done and "NOSE gear TOUCHDOWN" in text and kgs < self.BRAKES_KGS:
                self.play("+0     press brakes_on\n", "brakes"); done.add("brakes")
                self.say("crew: BRAKES at %.0f KGS" % kgs)
            if "jett" not in done and "chute" in done and kgs < self.CHUTE_JETT_KGS:
                self.play("+0     press chute_jett\n", "chute-jett"); done.add("jett")
                self.say("crew: DRAG CHUTE JETT at %.0f KGS" % kgs)
            if "WITHOUT THE GEAR DOWN" in text:
                self.say("land: ON THE GROUND WITHOUT THE GEAR -- stopping")
                return
            if "dn" in done and "MAIN gear TOUCHDOWN" in text and kgs < 0.5:
                stopped_since = stopped_since or time.time()
                if time.time() - stopped_since > 5.0:
                    for l in text.splitlines():
                        if "TOUCHDOWN" in l:
                            self.say(l.strip())
                    self.say("land: WHEELS STOP")
                    return
            else:
                stopped_since = None
            time.sleep(0.5)

    def run(self):
        start = PHASES.index(self.a.from_) if self.a.from_ else 0
        resume = (os.path.join(self.a.logs, FL["name"] + "-" + PHASES[start - 1].lower())
                  if start else None)
        if resume and not os.path.isdir(resume) and PHASES[start - 1] == "TERMINAL":
            # a run made before TERMINAL existed: its COUNT capture is at T-7 s
            resume = os.path.join(self.a.logs, FL["name"] + "-count")
        if self.a.attach:
            self.say("attached to the vehicle already running on port base %d" % self.base)
        else:
            self.start(resume)
        stop = PHASES.index(self.a.to) + 1 if self.a.to else len(PHASES)
        phases = PHASES[start:stop]
        if self.a.abort in ("RTLS", "TAL") and "ASCENT" in phases:
            # no orbit: from the abort's ET SEP straight to the landing
            phases = phases[:phases.index("ASCENT") + 1] + (["LAND"] if "LAND" in phases else [])
        for ph in phases:
            self.say("== %s" % ph)
            getattr(self, ph.lower())()
            self.snapshot(ph.lower())
        # every phase captured: end the simulation, which would otherwise run
        # on to its --duration (hours) holding a core
        crewscript.send_session("quit", self.base)
        self.say("done")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--logs", required=True, help="directory for the logs, scripts and captures")
    ap.add_argument("--port-base", type=int, default=38000)
    ap.add_argument("--rate", type=float, default=1.0,
                    help="simulated seconds per wall second (simulatePASS --rt-factor); 2 is "
                         "measured clean for one GPC on orbit")
    ap.add_argument("--tape", default=os.path.expanduser("~/workspace/pass-run/OI340700-v44boot-sts134.mmv"))
    ap.add_argument("--portview", action="store_true",
                    help="start portview's out-the-window views (simulatePASS does by default; "
                         "this driver passes --no-portview unless asked, so automated and "
                         "headless runs never render four views in software)")
    ap.add_argument("--count-to", type=float, default=300.0,
                    help="COUNT ends, and is captured, this many seconds before T-0 (default 300); "
                         "--from TERMINAL then restores the stack on the pad with the count running")
    ap.add_argument("--reuplink", action="store_true",
                    help="with --from COUNT: send the DOLILU again before OPS 101")
    ap.add_argument("--to", choices=PHASES,
                    help="stop after this phase (an ascent test needs no OPS 2 or orbit: --to OMS2)")
    ap.add_argument("--from", dest="from_", choices=PHASES[1:],
                    help="resume from the capture the previous phase left")
    ap.add_argument("--g3-from-mm", action="store_true",
                    help="WORKAROUND, not for new flights: disable the G3 archive retrieve "
                         "(DPS UTILITY ITEM 49) before OPS 301, for captures made before "
                         "yaGPC2 c87bce8b6 whose archive is empty (ledger #283)")
    ap.add_argument("--crts", type=int, default=2,
                    help="display units: CRT 1 for the crew's DPS pages (the driver keys there), "
                         "CRT 2 (and 3) for the owner -- the A/E PFD in entry (default 2)")
    ap.add_argument("--land-time", type=float, default=900.0,
                    help="LAND: simulated seconds to fly before giving up (default 900)")
    ap.add_argument("--incorporate-at-land", action="store_true",
                    help="DEVELOPMENT: force a GPS incorporation as LAND starts, for a run "
                         "resumed straight into TAEM, then SPEC 55 METERING OVERRIDE (not in any checklist)")
    ap.add_argument("--attach", action="store_true",
                    help="with --from DEORBIT: drive the vehicle ALREADY RUNNING on --port-base "
                         "(a driver that stopped after sending OPS 301) instead of starting one")
    ap.add_argument("--abort", choices=["RTLS", "TAL", "ATO"],
                    help="ASCENT: on the first engine failure (YAGPC_SSME_FAIL), the crew's "
                         "ABORT MODE rotary and ABORT pb; RTLS and TAL then go from ET SEP "
                         "straight to LAND (give --land-time for the whole entry)")
    ap.add_argument("--abort-react", type=float, default=5.0,
                    help="with --abort: simulated seconds from the failure to the ABORT pb")
    ap.add_argument("--flight", help="a JSON file of another flight's constants (default STS-134)")
    a = ap.parse_args()
    if a.flight:
        global EPOCH, T0, GMTLO, OMS2_DTIG
        f = json.load(open(a.flight))
        FL.update(f)
        hms = lambda x: x[0] * 86400 + x[1] * 3600 + x[2] * 60 + x[3]
        EPOCH = f.get("epoch", EPOCH)
        T0 = hms(f["t0"]) if "t0" in f else T0
        GMTLO = hms(f["gmtlo"]) if "gmtlo" in f else GMTLO
        OMS2_DTIG = f.get("oms2_dtig", OMS2_DTIG)
    Flight(a).run()


if __name__ == "__main__":
    main()
