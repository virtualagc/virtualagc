#!/usr/bin/env python3
"""FLY STS-134: one GPC, from IPL on the pad to the orbit after OMS 2, by the
book -- the crew's keystrokes, the ground's countdown and uplinks, PASS
doing the flying.

    python3 examples/flights/fly_sts134.py --logs DIR [--port-base N]
                                           [--tape VOLUME] [--from STAGE]

It starts simulatePASS.py and then, phase by phase:

  IPL      one GPC to OPS 9, the launch-day NBAT for memory configurations
           1 and 9, GSE polling on (SPEC 1 ITEM 50)
  UPLINK   the ground: the RNP epoch for 2011 day 136 (message 59) and the
           day-of-launch I-loads (sts134-dolilu.json)
  IMU      SPEC 104: the three IMUs to OPERATE, selected, ATT DET, selected
           again (ATT DET deselects them), GYROCOMP; about 50 minutes
  COUNT    OPS 101; the ground's GMT of liftoff 136/12:56:28 and RESUME;
           GO FOR AUTO SEQUENCE at T-47 s and GO FOR ENGINE START at T-27 s,
           by the vehicle's own clock
  ASCENT   PASS's: RSLS, liftoff, SRB and ET separation
  OMS 2    the STS-134 Ascent Checklist's OMS 2 cards: DAP AUTO, OPS 105,
           TRIM LOAD, LOAD, TIMER, MNVR, and EXEC at TIG
  ORBIT    one orbit coasting, the truth's osculating orbit logged

with a capture at the end of each phase (sts134-<phase> in DIR), and
--from STAGE to resume from one.  The vehicle's clock starts at
2011-05-16 11:30:00 UTC so that liftoff, when the alignment is done, is at
STS-134's own 12:56:28.

The STS-134 volume is the generic OI-34 tape with the flight's OPS 1
overlay I-loads (yaGPC2/tools/mission_reconfig.py with
sts134-reconfig.json): make it once with

    python3 yaGPC2/tools/mission_reconfig.py \\
        discretePanel/examples/flights/sts134-reconfig.json VOLUME \\
        --mem <an OPS 1 capture's gpc1.mem.bin> --out STS134.mmv
"""
import argparse
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
GMTLO = 136 * 86400 + 12 * 3600 + 56 * 60 + 28.0     # 136/12:56:28
OMS2_DTIG = 1756.0                                  # after ET separation (DOLILU message 25)
PHASES = ["IPL", "UPLINK", "IMU", "COUNT", "ASCENT", "OMS2", "ORBIT"]

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


class Flight:
    def __init__(self, a):
        self.a = a
        self.base = a.port_base
        self.log = os.path.join(a.logs, "logs", "yaGPC2.log")

    def say(self, text):
        print("fly_sts134: %s" % text, flush=True)

    # --- the vehicle ----------------------------------------------------
    def start(self, resume=None):
        env = dict(os.environ, YAGPC_MDM_DEVICES="1", YAGPC_VEHDYN="1", YAGPC_VEHDYN_PAD="1",
                   YAGPC_VEHDYN_ORBITER_KG="121826", YAGPC_OMS_ARMED="1",
                   YAGPC_RNP="2011,136", YAGPC_VEHDYN_STATELOG="5", PYTHONUNBUFFERED="1")
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
        target = os.path.join(self.a.logs, "sts134-" + name)
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
        link.send_message(groundstation.two_stage(groundstation.OP_RNP, [2011, 136]))
        self.say("ground: RNP epoch 2011 day 136 (message 59)")
        time.sleep(3)
        subprocess.run([sys.executable, os.path.join(PANEL, "groundstation.py"), "--port-base",
                        str(self.base), "dolilu", os.path.join(HERE, "sts134-dolilu.json")], check=True)
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
        self.play("+1     keys OPS 1 0 1 PRO\n", "ops101")
        self.wait_sim(40)
        crewscript.send_lps("gmtlo =%.0f" % GMTLO, self.base)
        time.sleep(2)
        crewscript.send_lps("resume", self.base)
        self.say("ground: GMT of liftoff 136/12:56:28, count resumed")
        self.wait_gmt(GMTLO - 47.0)
        crewscript.send_lps("go_auto", self.base)
        self.say("ground: GO FOR AUTO SEQUENCE")
        self.wait_gmt(GMTLO - 27.0)
        crewscript.send_lps("go_engine", self.base)
        self.say("ground: GO FOR ENGINE START")
        self.wait_gmt(GMTLO - 15.0)

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

    def oms2(self):
        etsep = float(open(os.path.join(self.a.logs, "etsep.gmt")).read())
        tig = etsep + OMS2_DTIG
        self.wait_gmt(etsep + 600.0)        # the post-MECO procedures first
        self.play(OMS2_SETUP, "oms2-setup")
        self.wait_gmt(tig - 8.0)
        self.play("+0     keys EXEC\n", "oms2-exec")
        self.say("crew: EXEC at TIG-8 s (TIG GMT %.1f)" % tig)
        self.wait_gmt(tig + 300.0)

    def orbit(self):
        self.wait_sim(5600)
        orb = [l for l in self.log_text().splitlines() if l.startswith("vehdyn-orbit")]
        self.say("%d orbit samples; last: %s" % (len(orb), orb[-1] if orb else "none"))

    def run(self):
        start = PHASES.index(self.a.from_) if self.a.from_ else 0
        resume = (os.path.join(self.a.logs, "sts134-" + PHASES[start - 1].lower())
                  if start else None)
        self.start(resume)
        for ph in PHASES[start:]:
            self.say("== %s" % ph)
            getattr(self, ph.lower())()
            self.snapshot(ph.lower())
        self.say("done")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--logs", required=True, help="directory for the logs, scripts and captures")
    ap.add_argument("--port-base", type=int, default=38000)
    ap.add_argument("--tape", default=os.path.expanduser("~/workspace/pass-run/OI340700-v44boot-sts134.mmv"))
    ap.add_argument("--from", dest="from_", choices=PHASES[1:],
                    help="resume from the capture the previous phase left")
    Flight(ap.parse_args()).run()


if __name__ == "__main__":
    main()
