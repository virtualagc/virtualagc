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
           follows 2.8 s later) and RESUME; GO FOR AUTO SEQUENCE at T-31 s and
           GO FOR ENGINE START at T-10 s, by the vehicle's own clock
  ASCENT   PASS's: RSLS, liftoff, SRB and ET separation
  OMS 2    the STS-134 Ascent Checklist's OMS 2 cards: DAP AUTO, OPS 105,
           TRIM LOAD, LOAD, TIMER, MNVR, and EXEC at TIG
  OPS2     the Ascent Checklist's post-burn MAJOR MODE CHANGE (OPS 106 PRO),
           then at MET 0:50 the Post Insertion book's TRANSITION TO GNC
           OPS 2 for a single G2: GPC MEMORY configuration 2 per its table,
           and OPS 201 PRO
  ORBIT    one orbit coasting, the truth's osculating orbit logged

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
PHASES = ["IPL", "UPLINK", "IMU", "COUNT", "ASCENT", "OMS2", "OPS2", "ORBIT"]

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
                   YAGPC_RNP="%d,%d" % tuple(FL["rnp"]), YAGPC_VEHDYN_STATELOG="5",
                   PYTHONUNBUFFERED="1", **fenv)
        cmd = [sys.executable, "-u", os.path.join(PANEL, "simulatePASS.py"), "--gpcs", "1",
               "--crts", "1", "--tape", self.a.tape, "--no-wait-user", "--size", "384",
               "--port-base", str(self.base), "--logs", os.path.join(self.a.logs, "logs"),
               "--snapshot-dir", self.a.logs, "--duration", "20000"]
        cmd += ["--snapshot-resume", resume] if resume else ["--date-time-epoch", EPOCH]
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

    def wait_file(self, path, text, timeout):
        end = time.time() + timeout
        while time.time() < end:
            if getattr(self, "proc", None) is not None and self.proc.poll() is not None:
                raise SystemExit("fly_sts134: simulatePASS.py has exited (see simulatePASS.out)")
            try:
                if text in open(path, errors="replace").read():
                    return True
            except OSError:
                pass
            time.sleep(2)
        raise SystemExit("fly_sts134: '%s' never appeared in %s" % (text, path))

    def play(self, text, name):
        path = os.path.join(self.a.logs, name + ".script")
        with open(path, "w") as fh:
            fh.write(text.lstrip())
        crewscript.send_control("play %s" % path, self.base)
        self.say("crew: %s" % name)
        self.wait_file(os.path.join(self.a.logs, "logs", "panel.log"),
                       "script command: play %s" % path, 60)

    def script_done(self, name, timeout):
        path = os.path.join(self.a.logs, name + ".script")
        n = sum(1 for l in open(path) if l.strip() and not l.lstrip().startswith("#"))
        # the panel logs every step; done when its last line has been logged
        last = [l for l in open(path) if l.strip() and not l.lstrip().startswith("#")][-1].strip()
        self.wait_file(os.path.join(self.a.logs, "logs", "panel.log"), last, timeout)
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
        # the GLS's own times (KLO-82-0071 App A): GO FOR AUTO SEQUENCE at
        # T-31 s -- PASS acts on it from GMTLO - 25 s, CGSV_LPS_GO_AUTO_SEQ_TIME
        # -- and GO FOR ENGINE START at about T-10 s
        self.wait_gmt(T0 - 31.0)
        crewscript.send_lps("go_auto", self.base)
        self.say("ground: GO FOR AUTO SEQUENCE (T-31 s)")
        self.wait_gmt(T0 - 10.0)
        crewscript.send_lps("go_engine", self.base)
        self.say("ground: GO FOR ENGINE START (T-10 s)")
        self.wait_gmt(T0 - 8.0)

    def ascent(self):
        while "ET SEPARATION at" not in self.log_text():
            time.sleep(5)
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

    def run(self):
        start = PHASES.index(self.a.from_) if self.a.from_ else 0
        resume = (os.path.join(self.a.logs, FL["name"] + "-" + PHASES[start - 1].lower())
                  if start else None)
        self.start(resume)
        stop = PHASES.index(self.a.to) + 1 if self.a.to else len(PHASES)
        for ph in PHASES[start:stop]:
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
    ap.add_argument("--tape", default=os.path.expanduser("~/workspace/pass-run/OI340700-v44boot-sts134.mmv"))
    ap.add_argument("--reuplink", action="store_true",
                    help="with --from COUNT: send the DOLILU again before OPS 101")
    ap.add_argument("--to", choices=PHASES,
                    help="stop after this phase (an ascent test needs no OPS 2 or orbit: --to OMS2)")
    ap.add_argument("--from", dest="from_", choices=PHASES[1:],
                    help="resume from the capture the previous phase left")
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
