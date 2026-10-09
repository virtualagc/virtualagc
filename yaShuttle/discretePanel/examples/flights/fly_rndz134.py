#!/usr/bin/env python3
"""FLY STS-134'S RENDEZVOUS, FROM NCC - 10 MIN: one GPC in OPS 201 on FD3,
the Orbiter on its real final approach to the real ISS, PASS navigating and
targeting the Ti burn and pointing the overhead windows at the station
(RENDEZVOUS_PLAN.md, the first milestone, M1).

    python3 examples/flights/fly_rndz134.py --logs DIR [--port-base N]
            [--tape VOLUME] [--from STAGE] [--to STAGE] [--rate X]

It starts simulatePASS.py at 2011-05-18 06:30:00 UTC -- Ti - 68 min, ten
minutes before NCC -- with the ISS flown from its May 2011 TLE
(YAGPC_VEHDYN_TARGETS) and the Orbiter put on the checklist's nominal NC
transfer toward the Ti point (YAGPC_VEHDYN_START_REL, worked out by
yaGPC2/tools/rndz_start.py), and MET counting from STS-134's liftoff
(YAGPC_MTU_MET_EPOCH) so that the crew keys the burn pads' own times.  Then,
phase by phase, with a capture (sts134r-<phase>) after each:

  IPL      one GPC IPL'd and taken straight to OPS 201 (GPC MEMORY
           configuration 2), DAP FREE, SPEC 21 IMUs 1-3 to OPERATE, DAP
           A/AUTO (examples/1gpc-ops201-imu.script)
  UPLINK   the ground (RNDZ timeline p. 4-5, "MCC UPLINK ORB SV, TGT SV"):
           the RNP epoch 2011/136 (message 59), the Orbiter's state
           (message 9) and the ISS's (message 10), both from the truth
  RNDZNAV  ENABLE RENDEZVOUS NAV [7A] (p. 4-7): SPEC 33 RNDZ NAV ENA - ITEM
           1; SV SEL PROP and S TRK checked; SPEC 34 TGT NO 1, BASE TIME = Ti
           TIG, LOAD - ITEM 26
  TRACK    -Z AXIS TARGET TRACK [12A] (p. 4-12): UNIV PTG CNCL - ITEM 21,
           TGT ID +1, BODY VECT +3, OM +0, DAP B/AUTO/ALT, TRK - ITEM 19;
           when the maneuver is complete DAP A/AUTO/VERN
  TI       TARGET Ti BURN [13A] (p. 4-13) at PET -0:55 (and, with --to TI,
           the final [15A] at TIG - 17 min, in OPS 201): SPEC 34 TGT NO
           +10; the set checked against the checklist (DT 76.9, DX -0.9,
           DY 0, DZ +1.8, EL 0, T1 TIG = BASE TIME) and, this tape's
           I-loads being zero, keyed and LOADed; COMPUTE T1 - ITEM 28.  The
           solution and the states it came from are read out of PASS's
           memory (a capture) and set beside rndz_start.py's independent
           Lambert from the same states and from the truth
  TIBURN   (M1b) [15A] in OPS 202 and RNDZ OMS BURN (p. 5-4): L OMS, WT,
           COMPUTE T1, PROP or the ground (truth) solution by the
           final-ground limits, LOAD, TIMER, MNVR, EXEC at TIG - 15 s
  COAST    OPS 201, -Z target track again, and the coast to T2 (TIG + 76.9
           min), the truth's relative state logged every 30 s

Each step that keys an entry is checked in PASS's memory before the next
(probe captures, sts134r-tgt10-*), since an entry can be lost.  Throughout
it logs, every --check-every s of vehicle time (rndz-check.log): PASS's
relative range and rate (from its own Orbiter and target states in the
downlist, format 22) against the truth's (TRU1/TGT1) at the same instant,
the Orbiter's navigation error in LVLH, and the angle between the body -Z
axis -- the -Z star tracker's and COAS's line of sight; the overhead
windows look 5 deg aft of it -- and the ISS.

--rate 2 works: the IDP transfers that broke at rate 2 with SPEC 33 up, and
lost every key after it (2026-10-08), were macOS App Nap throttling MEDS2;
fixed in b4eb048 (macdock.py opts the GUI programs out, MEDS2's bus pump
yields between buses).

Unlike fly_sts134.py this is not the flight from liftoff: the start skips
FD1-FD3's phasing (RENDEZVOUS_PLAN.md, Stage 7), and one GPC flies where the
flight rules want two GNC GPCs for Ti.
"""
import argparse
import calendar
import datetime
import json
import math
import os
import re
import socket
import struct
import subprocess
import sys
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
YAGPC2 = os.path.join(os.path.dirname(PANEL), "yaGPC2")
sys.path.insert(0, PANEL)
sys.path.insert(0, HERE)
import downlist      # noqa: E402
import fly_sts134    # noqa: E402
import groundstation  # noqa: E402

FT = 0.3048
EPOCH = "2011-05-18T06:30:00"
TI_TIG = "2011-05-18T07:38:00"            # STS-134's Ti, as flown (left OMS, ~8.4 ft/s)
# MET ZERO: SRB ignition, 136/12:56:27.994 (fly_sts134.T0)
MET_ZERO_UNIX = calendar.timegm((2011, 5, 16, 12, 56, 27)) + 0.994
NORAD_ISS = 25544
RNP = (2011, 136)                          # the flight's RNP epoch, launch day
ORBITER_KG = 121912                        # fly_sts134.FL; see the note in main()
PHASES = ["IPL", "UPLINK", "RNDZNAV", "TRACK", "TI", "TIBURN", "COAST"]
# TGT 10 as JSC-48072-134 lists it (TARGET Ti BURN [13A], [15A]):
TGT10 = {"EL": 0.0, "DT": 76.9, "DX": -0.9, "DY": 0.0, "DZ": 1.8}


def unix(when):
    d = datetime.datetime.fromisoformat(when)
    return calendar.timegm(d.timetuple()) + d.microsecond * 1e-6


def gmt_of_unix(u):
    t = time.gmtime(u)
    return (t.tm_yday * 86400 + t.tm_hour * 3600 + t.tm_min * 60 + t.tm_sec) + (u - math.floor(u))


def dhms(sec):
    d, r = divmod(int(round(sec)), 86400)
    h, r = divmod(r, 3600)
    m, s = divmod(r, 60)
    return d, h, m, s


def keys_num(x, fmt):
    t = fmt % abs(x)
    return ("- " if x < 0 else "+ ") + " ".join(t)


# --- what the ground hears: truth, the downlist, the displays ----------------
def _listen(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    if hasattr(socket, "SO_REUSEPORT"):
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    s.bind(("", port))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton("239.255.1.1") + socket.inet_aton(os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")))
    s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1 << 20)
    s.settimeout(1.0)
    return s


class Ears(object):
    """Threads that keep the latest truth (TRU1), the ISS (TGT1), the
    decoded format-22 downlist values and each display's full text."""

    def __init__(self, base):
        self.lock = threading.Lock()
        self.tru = None
        self.tgt = None
        self.hist_o, self.hist_t = [], []      # (gmt, r, v), the last couple of minutes
        self.dl = {}
        self.dl_t = {}
        self.cycle, self._cyc = None, {}       # PASS's two states from one downlist cycle
        self.screens = {}
        self.table = downlist.load_table(None)
        for fn, port in ((self._truth, base + 98), (self._target, base + 85),
                         (self._downlist, base + 88), (self._screen, base + 91)):
            threading.Thread(target=fn, args=(_listen(port),), daemon=True).start()

    def _truth(self, s):
        while True:
            try:
                d = s.recv(512)
            except socket.timeout:
                continue
            if d[:4] == b"TRU1" and len(d) >= 4 + 8 * 15:
                n = (len(d) - 4) // 8
                v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
                with self.lock:
                    self.tru = {"t": v[0], "gmt": v[1], "q": v[2:6], "w": v[6:9], "r": v[9:12], "v": v[12:15]}
                    self.hist_o.append((v[1], v[9:12], v[12:15]))
                    del self.hist_o[:-3000]

    def _target(self, s):
        while True:
            try:
                d = s.recv(512)
            except socket.timeout:
                continue
            if d[:4] == b"TGT1" and len(d) >= 4 + 8 * 8:
                n = (len(d) - 4) // 8
                v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
                with self.lock:
                    g = (self.tru["gmt"] - self.tru["t"] + v[0]) if self.tru else None
                    self.tgt = {"t": v[0], "gmt": g, "norad": int(v[1]), "r": v[2:5], "v": v[5:8]}
                    if g is not None:
                        self.hist_t.append((g, v[2:5], v[5:8]))
                        del self.hist_t[:-3000]

    def _downlist(self, s):
        while True:
            try:
                d = s.recv(1024)
            except socket.timeout:
                continue
            f = groundstation.parse_downlist(d)
            if f is None:
                continue
            h = groundstation.frame_header(f["words"])
            fmt, fr = h.get("format"), h.get("frame")
            if fmt not in self.table.formats:
                continue
            try:
                vals = downlist.decode_full(f["words"], fmt, fr, self.table)
            except Exception:
                continue
            with self.lock:
                for x in vals:
                    self.dl[x["name"]] = x["value"]
                    self.dl_t[x["name"]] = f["t_us"] / 1e6
                # THE ORBITER'S STATE AND THE TARGET'S, KEPT TOGETHER: frame 0
                # (25) carries T_STATE and R/V_AVGG, staged at the frame's start;
                # frame 5 (30), 0.2 s on, R/V_TARGET (format 22, DCDDG2)
                g = lambda n: self.dl.get(n)
                if fmt == 22 and fr in (0, 25):
                    self._cyc = {"t_state": g("CGGV_T_STATE_HFE"),
                                 "ro": [g("CGGV_R_AVGG_HFE$%d" % i) for i in (1, 2, 3)],
                                 "vo": [g("CGGV_V_AVGG_HFE$%d" % i) for i in (1, 2, 3)]}
                elif fmt == 22 and fr in (5, 30) and self._cyc:
                    self._cyc["rt"] = [g("CGGV_R_TARGET$%d" % i) for i in (1, 2, 3)]
                    self._cyc["vt"] = [g("CGGV_V_TARGET$%d" % i) for i in (1, 2, 3)]
                    if all(isinstance(x, float) for k in ("ro", "vo", "rt", "vt") for x in self._cyc[k]):
                        self.cycle = self._cyc
                    self._cyc = {}

    def _screen(self, s):
        while True:
            try:
                d = s.recv(8192)
            except socket.timeout:
                continue
            name, _, body = d.decode("utf-8", "replace").partition("\n")
            with self.lock:
                self.screens[name.strip().lower()] = body

    def truth_at(self, which, gmt):
        """A vehicle's truth (r, v, m and m/s) at a GMT of the last minutes,
        linearly interpolated between the 20 Hz samples (millimetres)."""
        with self.lock:
            h = list(self.hist_o if which == "orbiter" else self.hist_t)
        for k in range(len(h) - 1, 0, -1):
            if h[k - 1][0] <= gmt <= h[k][0]:
                a, b = h[k - 1], h[k]
                f = (gmt - a[0]) / (b[0] - a[0]) if b[0] > a[0] else 0.0
                return ([a[1][i] + f * (b[1][i] - a[1][i]) for i in range(3)],
                        [a[2][i] + f * (b[2][i] - a[2][i]) for i in range(3)])
        return None

    def snap(self):
        with self.lock:
            return (dict(self.tru) if self.tru else None, dict(self.tgt) if self.tgt else None,
                    dict(self.dl))

    def screen(self, name="crt1"):
        with self.lock:
            return self.screens.get(name, "")


def vsub(a, b): return [a[i] - b[i] for i in range(3)]
def vdot(a, b): return sum(a[i] * b[i] for i in range(3))
def vnorm(a): return math.sqrt(vdot(a, a))


def range_rate(ro, vo, rt, vt):
    d, dv = vsub(rt, ro), vsub(vt, vo)
    rng = vnorm(d)
    return rng, vdot(d, dv) / rng


def body_axis(q, k):
    """Body axis k (0 X, 1 Y, 2 Z) in M50 from the body -> M50 quaternion."""
    w, x, y, z = q
    R = [[1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
         [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
         [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]]
    return [R[0][k], R[1][k], R[2][k]]


def dhms_f(sec):
    d, r = divmod(sec, 86400.0)
    h, r = divmod(r, 3600.0)
    m, sx = divmod(r, 60.0)
    return int(d), int(h), int(m), sx


class PassMemory(object):
    """PASS's own variables, read from a capture's memory image (gpcN.mem.bin:
    main storage as big-endian halfwords, the address the halfword index).

    THE ADDRESSES are the OPS 2 (G2) memory configuration's, from the OI-34
    GNC2 DASS memory map (PFS/mafgen/DASS_G2.ASC, MAFGEN REL 26.020): the
    compools CGZ_MC2 (#PCGZMC2, orbit targeting) and CGN_MC2.  The tape's
    links pin these compools to the same addresses (yaGPC2/tools/pasvar.py
    explains the pinning), and check() confirms it on the image at hand: the
    Lambert flags' INITIAL(10#ON,30#OFF) (CGZMC2.hal:288) must read back."""
    A = {"PROX_TGT_SET_NO": 0xDE24, "COMP_PROX_DT": 0xDE26, "COMP_T2_OFF": 0xDE18,
         "ORB_TGT_EL_ANG": 0xDDF8, "DISP_DV_LVLH": 0xDE34, "DV_MAG": 0xDE3A,
         "TOTAL_SECS": (0xDE6C, 0xDE78, 0xDE84), "BASE_MET": 0xDEA0, "TIME_PROX": 0xDE9C,
         "RS_T1TIG": 0xDEA4, "VS_T1TIG": 0xDEB0, "VS_REQUIRED": 0xDED0,
         "T1_ILOAD": 0xDEDC, "DT_ILOAD": 0xDF2C, "EL_ILOAD": 0xDF7C, "ROFF_ILOAD": 0xDFCC,
         "SHUTTLE_M50": 0xE1F0, "TARGET_M50": 0xE214, "LAMB_ILOAD": 0xE34E,
         "DISP_MISS": 0xE376, "ALARM_KILL": 0xE386,
         "TARGET_MASS": 0xE7DE, "TARGET_CD": 0xE7E0, "TARGET_AREA": 0xE7E2,
         # the ORBIT MNVR EXEC display's VGO, body axes (CGZ123; read 9.36
         # -0.68 -0.34 before the Ti burn and 0.04 -2.15 +1.01 after it in
         # m1b-run2, as the display would), and PASS's one-engine OMS trims,
         # pitch then the left and right yaw (CGGC02 I-loads, -0.1, +5.21,
         # -5.21 on this tape)
         "VGO_BODY": 0xF0C2, "ONE_ENG_TRIM_P": 0xF10C, "ONE_ENG_TRIM_Y": 0xF10E}

    def __init__(self, path):
        self.m = open(path, "rb").read()
        self.path = path

    @classmethod
    def from_capture(cls, *dirs):
        for d in dirs:
            p = os.path.join(d, "gpc1.mem.bin")
            if os.path.exists(p):
                mem = cls(p)
                if mem.check():
                    return mem
        return None

    def hw(self, a, n=1):
        return list(struct.unpack(">%dH" % n, self.m[2 * a:2 * a + 2 * n]))

    def ibm(self, a, n):
        return groundstation.from_ibm_long(self.hw(a, 4)) if n == 4 else groundstation.from_ibm_short(self.hw(a, 2))

    def sp(self, a): return self.ibm(a, 2)
    def dp(self, a): return self.ibm(a, 4)
    def dvec(self, a): return [self.dp(a + 4 * i) for i in range(3)]
    def svec(self, a): return [self.sp(a + 2 * i) for i in range(3)]

    def check(self):
        return self.hw(self.A["LAMB_ILOAD"], 11) == [1] * 10 + [0]

    def iload(self, k):
        i = k - 1
        roff = self.dvec(self.A["ROFF_ILOAD"] + 12 * i)
        return {"T1": self.sp(self.A["T1_ILOAD"] + 2 * i), "DT": self.sp(self.A["DT_ILOAD"] + 2 * i),
                "EL": self.sp(self.A["EL_ILOAD"] + 2 * i),
                "DX": roff[0] / 1000.0, "DY": roff[1] / 1000.0, "DZ": roff[2] / 1000.0}

    def orbit_tgt(self):
        A = self.A
        base = self.dp(A["BASE_MET"])
        t = [self.dp(a) for a in A["TOTAL_SECS"]]
        tm = A["TARGET_M50"]
        return {"TGT_NO": struct.unpack(">h", self.m[2 * A["PROX_TGT_SET_NO"]:2 * A["PROX_TGT_SET_NO"] + 2])[0],
                "DISP_DV_LVLH": self.svec(A["DISP_DV_LVLH"]), "DV_MAG": self.sp(A["DV_MAG"]),
                "BASE_MET": base, "T1_TIG_MET": t[0], "T2_TIG_MET": t[1], "BASE_TIME_MET": t[2],
                "T1_TIG_GMT": t[0] + base, "COMP_PROX_DT": self.sp(A["COMP_PROX_DT"]),
                "COMP_T2_OFF": self.dvec(A["COMP_T2_OFF"]), "EL": self.sp(A["ORB_TGT_EL_ANG"]),
                "RS_T1TIG": self.dvec(A["RS_T1TIG"]), "VS_T1TIG": self.dvec(A["VS_T1TIG"]),
                "VS_REQUIRED": self.dvec(A["VS_REQUIRED"]),
                "TARGET_R_FIN": self.dvec(tm), "TARGET_V_FIN": self.dvec(tm + 12),
                "TARGET_T_IN": self.dp(tm + 24), "TARGET_T_FIN": self.dp(tm + 28),
                "DISP_MISS": self.sp(A["DISP_MISS"]), "ALARM_KILL": self.hw(A["ALARM_KILL"])[0],
                "TARGET_MASS_CD_AREA": [self.sp(A["TARGET_MASS"]), self.sp(A["TARGET_CD"]),
                                        self.sp(A["TARGET_AREA"])]}


class Rendezvous(fly_sts134.Flight):
    def __init__(self, a):
        super().__init__(a)
        self.checklog = open(os.path.join(a.logs, "rndz-check.log"), "a")
        self.ti_unix = unix(TI_TIG)
        self.ti_gmt = gmt_of_unix(self.ti_unix)
        self.ti_met = self.ti_unix - MET_ZERO_UNIX

    def say(self, text):
        print("fly_rndz134: %s" % text, flush=True)
        self.checklog.write("%s %s\n" % (time.strftime("%H:%M:%S"), text))
        self.checklog.flush()

    # --- the vehicle ------------------------------------------------------
    def start(self, resume=None):
        rel = os.environ.get("YAGPC_VEHDYN_START_REL")
        if not rel:
            out = subprocess.run([sys.executable, os.path.join(YAGPC2, "tools", "rndz_start.py"), "start",
                                  "--targets", self.a.targets, "--ti", TI_TIG, "--start", EPOCH],
                                 check=True, capture_output=True, text=True).stdout
            open(os.path.join(self.a.logs, "rndz-start.txt"), "w").write(out)
            rel = re.search(r"YAGPC_VEHDYN_START_REL=(\S+)", out).group(1)
            for line in out.strip().splitlines():
                self.say("start: " + line)
        env = dict(os.environ, YAGPC_MDM_DEVICES="1", YAGPC_VEHDYN="1",
                   YAGPC_VEHDYN_ORBITER_KG=str(ORBITER_KG), YAGPC_OMS_ARMED="1",
                   YAGPC_RNP="%d,%d" % RNP, YAGPC_VEHDYN_STATELOG="10",
                   YAGPC_VEHDYN_TARGETS=self.a.targets, YAGPC_VEHDYN_START_REL=rel,
                   YAGPC_MTU_MET_EPOCH="%.3f" % MET_ZERO_UNIX,
                   PYTHONUNBUFFERED="1")
        cmd = [sys.executable, "-u", os.path.join(PANEL, "simulatePASS.py"), "--gpcs", "1",
               "--crts", "1", "--tape", self.a.tape, "--no-wait-user", "--size", "384",
               "--port-base", str(self.base), "--logs", os.path.join(self.a.logs, "logs"),
               "--snapshot-dir", self.a.logs, "--duration", "20000",
               # the commander's station, for the THC that trims the Ti burn's
               # residuals: without a hand-controller window a script's `thc`
               # moves nothing (m1b-run3, 2026-10-08: "no hand-controller
               # window for that station is running")
               "--rhc", "lh"]
        cmd += ["--snapshot-resume", resume] if resume else ["--date-time-epoch", EPOCH]
        if self.a.rate != 1.0:
            cmd += ["--rt-factor", "%g" % self.a.rate]
        if not self.a.portview:
            cmd += ["--no-portview"]
        os.makedirs(self.a.logs, exist_ok=True)
        outp = os.path.join(self.a.logs, "simulatePASS.out")
        if os.path.exists(outp):
            os.replace(outp, outp + ".%d" % int(time.time()))
        self.out = open(outp, "w")
        self.ears = Ears(self.base)
        self.proc = subprocess.Popen(cmd, env=env, stdout=self.out, stderr=subprocess.STDOUT,
                                     stdin=subprocess.DEVNULL, cwd=PANEL)
        self.wait_file(outp, "session commands on port", 180)
        time.sleep(5)
        threading.Thread(target=self.monitor, daemon=True).start()

    def met_now(self):
        return self.truth()["gmt"] - (gmt_of_unix(MET_ZERO_UNIX))

    def wait_unix(self, u):
        self.wait_gmt(gmt_of_unix(u))

    # --- the checks, all through the run -------------------------------------
    def compare(self):
        """PASS's relative state and the truth's, now; and the -Z axis to
        the ISS.  None until both feeds and the downlist have spoken."""
        tru, tgt, dl = self.ears.snap()
        if not tru or not tgt:
            return None
        out = {"gmt": tru["gmt"]}
        rng, rdot = range_rate(tru["r"], tru["v"], tgt["r"], tgt["v"])
        out["true_rng_ft"], out["true_rdot_fts"] = rng / FT, rdot / FT
        los = vsub(tgt["r"], tru["r"])
        mz = [-c for c in body_axis(tru["q"], 2)]
        out["minusZ_to_iss_deg"] = math.degrees(math.acos(max(-1, min(1, vdot(mz, los) / vnorm(los)))))
        cyc = self.ears.cycle
        if cyc and cyc.get("t_state"):
            ts = cyc["t_state"]
            ro, vo, rt, vt = cyc["ro"], cyc["vo"], cyc["rt"], cyc["vt"]
            prng, prdot = range_rate(ro, vo, rt, vt)
            out.update(pass_rng_ft=prng, pass_rdot_fts=prdot, pass_t_state=ts,
                       pass_states=(ro, vo, rt, vt))
            to, tt = self.ears.truth_at("orbiter", ts), self.ears.truth_at("target", ts)
            # R/V_TARGET ride in frame 5, 0.2 s after frame 0's T_STATE; when
            # the navigation's cycle turns over between them the two states
            # are of different times (seen: a 24 kft "error", ~1 s of orbital
            # speed).  Such a cycle is not a comparison; keep the last good one.
            # The TARGET's error is the test: R/V_TARGET are the ones that
            # come late, and PASS's target state stays within a few hundred
            # feet of the truth, while a turnover moves it ~24 kft.  The
            # Orbiter's own error is no test -- it grew past 2 kft by Ti - 29
            # min in m1-run4, and from there every comparison was refused and
            # the log repeated the last good one for the rest of the run.
            if to and tt and vnorm(vsub(rt, [x / FT for x in tt[0]])) > 8000.0:
                for k in [k for k in out if k.startswith("pass_")]:
                    del out[k]
                out.update(getattr(self, "_last_good", {}))
                return out
            if to and tt:
                trng, trdot = range_rate(to[0], to[1], tt[0], tt[1])
                out.update(truth_rng_at_ts_ft=trng / FT, truth_rdot_at_ts_fts=trdot / FT,
                           orb_err_ft=vnorm(vsub(ro, [x / FT for x in to[0]])),
                           tgt_err_ft=vnorm(vsub(rt, [x / FT for x in tt[0]])),
                           truth_states_at_ts=([x / FT for x in to[0]], [x / FT for x in to[1]],
                                               [x / FT for x in tt[0]], [x / FT for x in tt[1]]))
                # the Orbiter's navigation error in its own LVLH (x along, y
                # -orbit normal, z down): ft and ft/s
                tr_, tv_ = [x / FT for x in to[0]], [x / FT for x in to[1]]
                ez = [-x / vnorm(tr_) for x in tr_]
                h = [tr_[1] * tv_[2] - tr_[2] * tv_[1], tr_[2] * tv_[0] - tr_[0] * tv_[2],
                     tr_[0] * tv_[1] - tr_[1] * tv_[0]]
                ey = [-x / vnorm(h) for x in h]
                ex = [ey[1] * ez[2] - ey[2] * ez[1], ey[2] * ez[0] - ey[0] * ez[2], ey[0] * ez[1] - ey[1] * ez[0]]
                dr, dvv = vsub(ro, tr_), vsub(vo, tv_)
                out.update(orb_dr_lvlh=[vdot(dr, e) for e in (ex, ey, ez)],
                           orb_dv_lvlh=[vdot(dvv, e) for e in (ex, ey, ez)])
                self._last_good = {k: v for k, v in out.items() if k not in ("gmt", "true_rng_ft",
                                   "true_rdot_fts", "minusZ_to_iss_deg")}
        return out

    def monitor(self):
        last = -1e9
        while True:
            time.sleep(2.0)
            try:
                c = self.compare()
            except Exception as e:      # never let the log take the flight down
                self.say("monitor: %s" % e)
                continue
            if not c or c["gmt"] - last < self.a.check_every:
                continue
            last = c["gmt"]
            line = ("GMT %.0f (Ti %+.1f min): truth RNG %.1f ft RDOT %+.3f ft/s; -Z to ISS %.2f deg"
                    % (c["gmt"], (c["gmt"] - self.ti_gmt) / 60.0, c["true_rng_ft"], c["true_rdot_fts"],
                       c["minusZ_to_iss_deg"]))
            if "truth_rng_at_ts_ft" in c:
                line += ("\n      at PASS's T_STATE %.2f: PASS RNG %.1f RDOT %+.4f, truth RNG %.1f RDOT %+.4f "
                         "(diff %+.1f ft %+.4f ft/s); |PASS - truth| orbiter %.0f ft, target %.0f ft"
                         % (c["pass_t_state"], c["pass_rng_ft"], c["pass_rdot_fts"], c["truth_rng_at_ts_ft"],
                            c["truth_rdot_at_ts_fts"], c["pass_rng_ft"] - c["truth_rng_at_ts_ft"],
                            c["pass_rdot_fts"] - c["truth_rdot_at_ts_fts"], c["orb_err_ft"], c["tgt_err_ft"]))
                line += ("\n      orbiter nav error LVLH: %+.1f %+.1f %+.1f ft, %+.4f %+.4f %+.4f ft/s"
                         % tuple(c["orb_dr_lvlh"] + c["orb_dv_lvlh"]))
            self.say("check: " + line)

    def snapshot(self, name):
        """A capture, as fly_sts134's -- but one that does not come is not
        the end of the flight: tried twice, then noted and flown on."""
        import shutil
        old = os.path.join(self.a.logs, "sts134r-" + name)
        if os.path.isdir(old):            # a capture of that name is replaced, never read stale
            shutil.rmtree(old)
        for attempt in (1, 2):
            try:
                return super().snapshot(name)
            except SystemExit as e:
                self.say("capture %s failed (attempt %d): %s" % (name, attempt, e))
        self.say("NO CAPTURE for %s; flying on" % name)

    def dump_screen(self, what):
        txt = self.ears.screen("crt1")
        self.say("CRT 1, %s:\n%s" % (what, "\n".join("    | " + l for l in txt.splitlines() if l.strip())))
        return txt

    # --- the phases ---------------------------------------------------------
    IPL_SCRIPT = """
+0     gpc 1
+0     mode HALT
+0.02  idppower 1 on
+0.01  script {panel}/examples/ipl-one-gpc.script gpc=1 crt=1 idp=1 kb=KB1
+11    keys ITEM 1 + 2 EXEC
+8     keys ITEM 2 + 1 EXEC
+8     keys ITEM 7 + 1 EXEC
+8     keys ITEM 8 + 1 EXEC
+8     keys ITEM 9 + 1 EXEC
+8     keys ITEM 1 0 + 1 EXEC
+8     keys ITEM 1 1 + 1 EXEC
+8     keys ITEM 1 2 + 1 EXEC
+8     keys ITEM 1 8 + 1 EXEC
+8     keys ITEM 1 9 + 1 EXEC
+21    keys OPS 2 0 1 PRO
wait crt 1 title 2011/ timeout 600
+20    dap c3 free
+10    keys SPEC 2 1 PRO
+5     keys ITEM 4 EXEC
+3     keys ITEM 5 EXEC
+3     keys ITEM 6 EXEC
+15    keys RESUME
+5     dap c3 a
+2     dap c3 auto
+2     dap c3 vern
"""

    def ipl(self):
        self.play(self.IPL_SCRIPT.format(panel=PANEL), "ipl")
        self.script_done("ipl", 1500)
        self.say("OPS 201, IMUs in OPERATE, DAP A/AUTO/VERN")
        self.wait_sim(10)

    @property
    def iloads(self):
        """TGT sets 1-14 as this tape's I-loads hold them (the IPL capture)."""
        if not hasattr(self, "_iloads"):
            mem = PassMemory.from_capture(os.path.join(self.a.logs, "sts134r-ipl"))
            self._iloads = {k: mem.iload(k) for k in range(1, 15)} if mem else {}
            if mem:
                self.say("this tape's orbit-targeting I-loads (IPL capture): TGT 9 %s; TGT 10 %s; "
                         "target mass/CD/area %s" % (self._iloads[9], self._iloads[10],
                                                     mem.orbit_tgt()["TARGET_MASS_CD_AREA"]))
        return self._iloads

    def uplink(self):
        link = groundstation.Link(self.base)
        link.send_message(groundstation.two_stage(groundstation.OP_RNP, list(RNP)))
        self.say("ground: RNP epoch %d day %d (message 59)" % RNP)
        time.sleep(5)
        for verb in ("sv", "tsv"):
            out = subprocess.run([sys.executable, os.path.join(PANEL, "groundstation.py"), "--port-base",
                                  str(self.base), verb], check=True, capture_output=True, text=True).stdout
            self.say("ground: " + out.strip().splitlines()[0 if verb == "sv" else 1])
            time.sleep(5)
        self.wait_sim(20)

    def rndznav(self):
        # ENABLE RENDEZVOUS NAV [7A]
        self.play("+1     keys SPEC 3 3 PRO\n+5     keys ITEM 1 EXEC\n", "rndz-nav-ena")
        self.script_done("rndz-nav-ena", 120)
        self.wait_sim(10)
        self.dump_screen("SPEC 33 after RNDZ NAV ENA")
        d, h, m, s = dhms(self.ti_met)
        script = ("+1     keys SPEC 3 4 PRO\n"
                  "+5     keys ITEM 1 + 1 EXEC\n"
                  "+4     keys ITEM 2 1 + %d + %s + %s + %s EXEC\n"
                  "+4     keys ITEM 2 6 EXEC\n"
                  % (d, " ".join("%d" % h), " ".join("%d" % m), " ".join("%d" % s)))
        self.play(script, "tgt1-base")
        self.script_done("tgt1-base", 120)
        self.wait_sim(5)
        self.dump_screen("SPEC 34, TGT 1, BASE TIME %03d/%02d:%02d:%02d MET loaded" % (d, h, m, s))

    def track(self):
        # -Z AXIS TARGET TRACK [12A] (and LOAD TARGET TRACK [9A]'s CNCL first)
        script = ("+1     keys RESUME\n"
                  "+3     keys ITEM 2 1 EXEC\n"
                  "+3     keys ITEM 8 + 1 EXEC\n"
                  "+3     keys ITEM 1 4 + 3 EXEC\n"
                  "+3     keys ITEM 1 7 + 0 EXEC\n"
                  "+3     dap c3 b\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 1 9 EXEC\n")
        self.play(script, "target-track")
        self.script_done("target-track", 120)
        self.wait_sim(5)
        self.dump_screen("UNIV PTG, TRK")
        self.track_complete("dap-a-vern")

    def track_complete(self, name):
        """[12A] "When MNVR cmplt, DAP: A/AUTO/VERN(ALT)": the -Z axis on the
        ISS, then the verniers hold it."""
        t0 = self.truth()["t"]
        while True:
            c = self.compare()
            if c and c["minusZ_to_iss_deg"] < 2.0:
                break
            if self.truth()["t"] - t0 > 1200:
                self.say("TRACK: the maneuver did not complete in 20 min")
                break
            time.sleep(5)
        self.play("+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 vern\n", name)
        self.script_done(name, 60)
        self.say("crew: MNVR complete (-Z %.2f deg from the ISS); DAP A/AUTO/VERN"
                 % (self.compare() or {}).get("minusZ_to_iss_deg", -1))

    def probe(self, name):
        """PASS's memory now: a capture, read (the IDP's part of it is not
        needed, so a capture the IDP fails to join still serves)."""
        self.snapshot(name)
        return PassMemory.from_capture(os.path.join(self.a.logs, "sts134r-" + name),
                                       os.path.join(self.a.logs, "logs", "snapshot-staging"))

    def tgt10(self, label):
        """TARGET Ti BURN: TGT NO 10; the set checked against the checklist
        and, where it differs, keyed and LOADed; COMPUTE T1; then the
        solution, and the states it was computed from, read out of PASS's
        memory and set beside the independent Lambert.  Each step is checked
        in memory before the next: an item entry can be lost (one TGT NO 10,
        keyed five seconds after SPEC 34 was called from UNIV PTG, never
        arrived, and COMPUTE T1 then solved TGT 1's empty set)."""
        for attempt in range(3):
            self.play("+1     keys SPEC 3 4 PRO\n"
                      "wait crt 1 title /034/ timeout 120\n"
                      "+3     keys ITEM 1 + 1 0 EXEC\n", "tgt10-%s-%d" % (label, attempt))
            self.script_done("tgt10-%s-%d" % (label, attempt), 180)
            self.wait_sim(5)
            mem = self.probe("tgt10-%s" % label)
            if mem and mem.orbit_tgt()["TGT_NO"] == 10:
                break
            self.say("TGT NO 10 not taken (attempt %d); keying it again" % (attempt + 1))
        else:
            self.say("TGT NO 10 was never taken; no COMPUTE T1 (%s)" % label)
            return
        il = mem.iload(10)
        ok = (abs(il["DT"] - TGT10["DT"]) < 0.05 and abs(il["EL"]) < 1e-6 and abs(il["T1"]) < 1e-6
              and all(abs(il[k] - TGT10[k]) < 0.005 for k in ("DX", "DY", "DZ")))
        self.say("TGT 10 as selected (%s): %s -- %s" % (label, il, "as the checklist" if ok else
                 "NOT the checklist's (DT 76.9, DX -0.9, DY 0, DZ +1.8, EL 0, T1 = BASE); the crew keys "
                 "the set and LOADs it -- a deviation: the flight's I-loads held it"))
        if not ok:
            script = ("+1     keys ITEM 6 + 0 EXEC\n"
                      "+4     keys ITEM 1 7 %s EXEC\n"
                      "+4     keys ITEM 1 8 %s %s %s EXEC\n"
                      "+4     keys ITEM 2 6 EXEC\n"
                      % (keys_num(TGT10["DT"], "%.1f"), keys_num(TGT10["DX"], "%.2f"),
                         keys_num(TGT10["DY"], "%.2f"), keys_num(TGT10["DZ"], "%.2f")))
            self.play(script, "tgt10-set-%s" % label)
            self.script_done("tgt10-set-%s" % label, 120)
            self.wait_sim(5)
            mem = self.probe("tgt10-loaded-%s" % label)
            self.say("TGT 10 after LOAD (%s): %s; T1 TIG MET %03d/%02d:%02d:%06.3f"
                     % (label, mem.iload(10), *dhms_f(mem.orbit_tgt()["T1_TIG_MET"])))
        before = self.compare()
        self.play("+1     keys ITEM 2 8 EXEC\n", "compute-t1-%s" % label)
        self.script_done("compute-t1-%s" % label, 60)
        for wait in range(10):
            self.wait_sim(15)
            mem = self.probe("ti-" + label)
            busy = mem.hw(0xDE16)[0]                    # CGZB_COMP_QUEUED_ACTIVE_GK3
            if not busy and struct.unpack(">h", mem.m[2 * 0xDE32:2 * 0xDE32 + 2])[0] == 10:
                break                                   # CGZV_MAN_TGT_NO: GWA saw it done
        self.dump_screen("after COMPUTE T1 (%s)" % label)
        sol = mem.orbit_tgt()
        json.dump(sol, open(os.path.join(self.a.logs, "ti-%s.json" % label), "w"), indent=1)
        dv = sol["DISP_DV_LVLH"]
        tig = sol["T1_TIG_MET"]
        self.say("PASS's COMPUTE T1, TGT %d (%s): T1 TIG MET %03d/%02d:%02d:%06.3f (GMT %.3f), "
                 "DT %.2f min, T2 offset %+.3f %+.3f %+.3f kft, EL %.3f deg;\n"
                 "      DVX %+.2f DVY %+.2f DVZ %+.2f DVT %.2f ft/s  (alarm kill %s, miss %.1f)"
                 % (sol["TGT_NO"], label, *dhms_f(tig), sol["T1_TIG_GMT"], sol["COMP_PROX_DT"] / 60.0,
                    *(x / 1000.0 for x in sol["COMP_T2_OFF"]), math.degrees(sol["EL"]),
                    dv[0], dv[1], dv[2], sol["DV_MAG"], sol["ALARM_KILL"], sol["DISP_MISS"]))
        sol["lambert"] = self.lambert_check(label, before, sol)
        json.dump(sol, open(os.path.join(self.a.logs, "ti-%s.json" % label), "w"), indent=1)
        return sol

    def lambert_check(self, label, c, sol):
        """rndz_start.py lambert from PASS's own states -- the Orbiter at T1
        TIG (CGZV_RS/VS_T1TIG) and the target at T2 (CGZV_TARGET_M50) as GWR
        left them -- and from the truth when COMPUTE T1 was keyed."""
        runs = [("PASS's own (GWR's RS/VS_T1TIG, TARGET_M50 at T2)",
                 sol["T1_TIG_GMT"], sol["RS_T1TIG"] + sol["VS_T1TIG"],
                 sol["TARGET_T_FIN"], sol["TARGET_R_FIN"] + sol["TARGET_V_FIN"])]
        if c and "truth_states_at_ts" in c:
            ro, vo, rt, vt = c["truth_states_at_ts"]
            runs.append(("the truth at COMPUTE T1", c["pass_t_state"], ro + vo, c["pass_t_state"], rt + vt))
        offset = [x / 1000.0 for x in sol["COMP_T2_OFF"]]
        res = {}
        for name, go, so, gt, stt in runs:
            args = [sys.executable, os.path.join(YAGPC2, "tools", "rndz_start.py"), "lambert",
                    "--orb", "%.4f" % go] + ["%.4f" % x for x in so] + \
                   ["--tgt", "%.4f" % gt] + ["%.4f" % x for x in stt] + \
                   ["--tig", "%.3f" % sol["T1_TIG_GMT"], "--dt", "%.6f" % (sol["COMP_PROX_DT"] / 60.0),
                    "--offset", "%.6f,%.6f,%.6f" % tuple(offset)]
            out = subprocess.run(args, capture_output=True, text=True)
            self.say("independent Lambert from %s (%s):\n%s%s"
                     % (name, label, out.stdout.rstrip(), out.stderr.rstrip()))
            m = re.search(r"precision.*DVX\s+([-+\d.]+)\s+DVY\s+([-+\d.]+)\s+DVZ\s+([-+\d.]+)", out.stdout)
            if m:
                res["PASS" if name.startswith("PASS") else "truth"] = [float(x) for x in m.groups()]
        return res

    def ti(self):
        # [13A] Preliminary at PET -0:55; [15A] Final at TIG - 17 min -- in
        # OPS 201 when the burn is not to be flown (M1); otherwise the final
        # targeting is TIBURN's, in OPS 202, as the checklist has it
        burn = not self.a.to or PHASES.index(self.a.to) >= PHASES.index("TIBURN")
        for label, before in (("preliminary", 55 * 60.0),) + ((() if burn else (("final", 17 * 60.0),))):
            if self.truth()["gmt"] < self.ti_gmt - before:
                self.wait_gmt(self.ti_gmt - before)
            self.say("== TARGET Ti BURN (%s), Ti %+.1f min" % (label, (self.truth()["gmt"] - self.ti_gmt) / 60.0))
            self.tgt10(label)

    def orbiter_lb(self):
        """The truth's mass, for the burn pad's WT (lb): the newest
        vehdyn-state line."""
        for line in reversed(self.log_text().splitlines()):
            m = re.search(r"vehdyn-state:.*mass_kg=([\d.]+)", line)
            if m:
                return float(m.group(1)) / 0.45359237
        return ORBITER_KG / 0.45359237

    def tiburn(self):
        """TARGET Ti BURN [15A] (Final) and RNDZ OMS BURN (CONTINGENCY OPS
        5-4), the burn the checklist calls for when DVT > 6 ft/s: at TIG - 17
        min OPS 202 PRO; ORBIT MNVR EXEC: L OMS (ITEM 2) and WT (ITEM 9) per
        the burn pad -- TV ROLL and the trims left at PASS's own for the
        engine, the pad's not being known -- LOAD (ITEM 22); SPEC 34 TGT 10,
        COMPUTE T1, which in MM 202 hands its PEG 7 solution to the MNVR
        display; LOAD, TIMER, DAP A/AUTO/ALT, MNVR (ITEM 27); EXEC at TIG -
        15 s; after the burn OPS 201 PRO and the -Z target track again."""
        tig = self.ti_gmt
        if self.truth()["gmt"] < tig - 17 * 60.0:
            self.wait_gmt(tig - 17 * 60.0)
        wt = self.orbiter_lb()
        trims = self.one_engine_trims()
        self.play("+1     keys OPS 2 0 2 PRO\n"
                  "wait crt 1 title 2021/ timeout 180\n"
                  "+3     keys ITEM 2 EXEC\n" + trims +
                  "+4     keys ITEM 9 + %s EXEC\n"
                  "+4     keys ITEM 2 2 EXEC\n" % " ".join("%d" % round(wt)), "ops202")
        self.script_done("ops202", 300)
        self.say("crew: OPS 202, L OMS, trims, WT %d lb, LOAD" % round(wt))
        sol = self.tgt10("final") or {}
        # FINAL SOLUTION (p. 4-15 and the burn solution rules, p. 1-3): with
        # no sensor pass there is no FLTR solution; burn PROP if it is within
        # the final-ground limits (DVX 1.3, DVY 1.3, DVZ 1.1 ft/s, p. 4-14) of
        # the ground's -- here the precision Lambert from the truth, standing
        # in for MCC's tracking -- else the ground solution's EXT DVs
        prop, gnd = sol.get("DISP_DV_LVLH"), (sol.get("lambert") or {}).get("truth")
        keyed = ""
        if prop and gnd:
            diff = [prop[i] - gnd[i] for i in range(3)]
            within = all(abs(diff[i]) <= lim for i, lim in enumerate((1.3, 1.3, 1.1)))
            self.say("FINAL Ti: PROP %+.2f %+.2f %+.2f, ground %+.2f %+.2f %+.2f ft/s: %s"
                     % (*prop, *gnd, "PROP within the limits -- burn PROP" if within else
                        "PROP outside the limits -- burn the ground solution's EXT DVs"))
            if not within:
                d, h, m_, sx = dhms_f(self.ti_met)
                keyed = ("+3     keys ITEM 1 0 + %d + %s + %s + %s EXEC\n"
                         "+4     keys ITEM 1 9 %s %s %s EXEC\n"
                         % (d, " ".join("%d" % h), " ".join("%d" % m_), " ".join("%.1f" % sx),
                            keys_num(gnd[0], "%.1f"), keys_num(gnd[1], "%.1f"), keys_num(gnd[2], "%.1f")))
        self.play("+1     keys RESUME\n"
                  "wait crt 1 title 2021/ timeout 60\n"
                  # 5-4 step 2, "Eng sel ... per Burn Pad": checked again after
                  # COMPUTE T1, which in MM 202 re-initialises the MNVR display
                  # -- the first run's L OMS did not survive it, and both
                  # engines burned (2026-10-08)
                  "+3     keys ITEM 2 EXEC\n" + trims +
                  "+4     keys ITEM 9 + %s EXEC\n" % " ".join("%d" % round(wt)) + keyed +
                  "+3     keys ITEM 2 2 EXEC\n"
                  "+4     keys ITEM 2 3 EXEC\n"
                  "+3     dap c3 a\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 2 7 EXEC\n", "ti-mnvr")
        self.script_done("ti-mnvr", 180)
        mem = self.probe("ti-loaded")
        self.say("crew: Ti burn LOADed, TIMER, MNVR to burn attitude")
        self.wait_gmt(tig - 15.0)
        tr0 = self.truth()
        self.play("+0     keys EXEC\n", "ti-exec")
        self.say("crew: EXEC at TIG-15 s (TIG GMT %.1f)" % tig)
        self.wait_gmt(tig + 60.0)
        after = self.probe("ti-cutoff")
        v0, v1 = self.vehdyn_capture("ti-loaded"), self.vehdyn_capture("ti-cutoff")
        if v0 and v1:
            dv = [(v1["sensed"][i] - v0["sensed"][i]) / FT for i in range(3)]
            self.say("Ti burn: the truth's sensed delta-V %.2f ft/s (M50 %+.2f %+.2f %+.2f); OMS on "
                     "L %.2f s, R %.2f s" % (vnorm(dv), *dv, v1["oms_s"][0] - v0["oms_s"][0],
                                            v1["oms_s"][1] - v0["oms_s"][1]))
        if after:
            self.say("Ti burn: residuals VGO %+.2f %+.2f %+.2f ft/s (body)" % tuple(after.svec(after.A["VGO_BODY"])))
        self.trim_residuals()
        del mem, tr0

    def one_engine_trims(self):
        """The burn pad's trims for a single-engine burn (5-4, "TRIM per Burn
        Pad").  The pad is not to hand; PASS's own one-engine trims are (the
        I-loads CGGV_ONE_ENG_OMS_PITCH_TRIM and _YAW_TRIM), keyed as P and LY
        (ITEMs 6 and 7).  Without them m1b-run2 burned the left engine on the
        two-engine trims (P +0.4, LY -5.75): the burn attitude was computed
        for thrust along body X, the gimbal then swung 13 deg to put the
        left engine's thrust through the CG, and the burn ended with VGO Y
        -2.15 and Z +1.01 ft/s."""
        mem = PassMemory.from_capture(os.path.join(self.a.logs, "sts134r-ti"),
                                      os.path.join(self.a.logs, "sts134r-ipl"))
        if not mem:
            self.say("one-engine trims: no capture to read them from; left as they are")
            return ""
        p = mem.sp(mem.A["ONE_ENG_TRIM_P"])
        ly = mem.sp(mem.A["ONE_ENG_TRIM_Y"])
        if not (abs(p) <= 6.0 and 0.0 < ly <= 7.0):
            self.say("one-engine trims read as P %+.2f LY %+.2f -- not believable; left as they are" % (p, ly))
            return ""
        self.say("one-engine trims (PASS's I-loads): P %+.1f LY %+.1f" % (p, ly))
        return "+4     keys ITEM 6 %s %s EXEC\n" % (keys_num(p, "%.1f"), keys_num(ly, "%.1f"))

    def vehdyn_capture(self, name):
        """The truth in a capture: the sensed delta-V (m/s, M50) and each OMS
        engine's burning seconds (vehdyn_save's order)."""
        try:
            b = json.load(open(os.path.join(self.a.logs, "sts134r-" + name, "vehdyn.json")))["vehdyn"]
        except (OSError, ValueError, KeyError):
            return None
        i = 3 + 3 + 3 + 4 + 3 + 5                # version, have, t, r, v, q, w, propellant
        sensed = b[i:i + 3]
        i += 3 + 2 * 44                           # on[], onSec[]
        return {"sensed": sensed, "oms_s": (b[i + 6], b[i + 13])}

    # RESIDUALS: trimmed with the THC to 0.2 ft/s per axis, the tolerance
    # assumed here for a rendezvous burn (5-4's own numbers are not to hand).
    # Body axes, as the MNVR display shows VGO; the THC's directions are the
    # orbiter's (+z down), so each residual is flown in its own sign.  The
    # hold is the residual over a guessed 0.25 ft/s^2, then measured again.
    TRIM_TOL, TRIM_ACC = 0.2, 0.25

    def trim_residuals(self):
        for n in range(8):
            mem = self.probe("ti-trim-%d" % n)
            if not mem:
                self.say("TRIM: no capture; residuals left")
                return
            vgo = mem.svec(mem.A["VGO_BODY"])
            if all(abs(v) <= self.TRIM_TOL for v in vgo):
                self.say("TRIM: residuals VGO %+.2f %+.2f %+.2f ft/s -- trimmed" % tuple(vgo))
                return
            script, longest = "", 0.0
            for ax, v in zip("xyz", vgo):
                if abs(v) > self.TRIM_TOL:
                    hold = min(max(abs(v) / self.TRIM_ACC, 0.2), 10.0)
                    longest = max(longest, hold)
                    script += "+1     thc fwd %s%s %.2f\n" % ("+" if v > 0 else "-", ax, hold)
            self.say("TRIM %d: VGO %+.2f %+.2f %+.2f ft/s; THC %s" % (n, *vgo, script.strip().replace("\n", "; ")))
            self.play(script, "ti-trim-%d" % n)
            self.script_done("ti-trim-%d" % n, 120)
            self.wait_sim(longest + 5.0)          # the holds run on after the script ends
        self.say("TRIM: residuals not within %.1f ft/s after 8 tries" % self.TRIM_TOL)

    def coast(self):
        """After Ti: OPS 201, the -Z target track again ([12A]), and the
        coast toward the MC4 region, T2 = TIG + 76.9 min; MC1-MC4 are not
        flown.  Where the truth arrives is logged against TGT 10's aim point
        (-0.9 kft behind, 1.8 kft below)."""
        self.play("+1     keys OPS 2 0 1 PRO\n"
                  "wait crt 1 title 2011/ timeout 180\n"
                  "+3     keys ITEM 2 1 EXEC\n"
                  "+3     keys ITEM 8 + 1 EXEC\n"
                  "+3     keys ITEM 1 4 + 3 EXEC\n"
                  "+3     keys ITEM 1 7 + 0 EXEC\n"
                  "+3     dap c3 b\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 1 9 EXEC\n", "post-ti-track")
        self.script_done("post-ti-track", 300)
        self.say("crew: OPS 201, -Z target track")
        # and, as before Ti, the verniers once the -Z axis is on the ISS: the
        # first M1b run left DAP B/ALT holding the track with the primaries
        # for the whole coast, which [12A] does not, and whose translations
        # move the truth itself
        self.track_complete("post-ti-dap-a-vern")
        t2 = self.ti_gmt + TGT10["DT"] * 60.0
        stop = min(t2, self.ti_gmt + self.a.coast_min * 60.0)
        while self.truth()["gmt"] < stop:
            time.sleep(30)
            tru, tgt, _ = self.ears.snap()
            if tru and tgt:
                self.rel_now(tru, tgt, "coast")
        self.say("coast: ended at Ti %+.1f min" % ((self.truth()["gmt"] - self.ti_gmt) / 60.0))

    def rel_now(self, tru, tgt, what):
        """The truth's relative state, in PASS's curvilinear target LVLH."""
        sys.path.insert(0, os.path.join(YAGPC2, "tools"))
        import rndz_start
        # the target at the truth's own instant (the two feeds are sampled
        # apart; a second's difference is a mile of orbit)
        at = self.ears.truth_at("target", tru["gmt"])
        rt, vt = (at if at else (list(tgt["r"]), list(tgt["v"])))
        rel = rndz_start.m50_to_lvc(list(rt), list(vt), list(tru["r"]), list(tru["v"]))
        self.say("%s: truth at Ti %+.1f min: %s" % (what, (tru["gmt"] - self.ti_gmt) / 60.0,
                                                    rndz_start.fmt_rel(rel)))
        return rel


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--logs", required=True)
    ap.add_argument("--port-base", type=int, default=48600)
    ap.add_argument("--rate", type=float, default=1.0)
    ap.add_argument("--tape", default=os.path.expanduser(
        "~/dropbox-copy/sts134-ksc6-entry/OI340700-v44boot-sts134-ksc6.mmv"))
    ap.add_argument("--targets", default=os.path.expanduser("~/sts134-runs/rendezvous/sts134-targets.txt"))
    ap.add_argument("--portview", action="store_true", help="start portview's window views")
    ap.add_argument("--to", choices=PHASES)
    ap.add_argument("--from", dest="from_", choices=PHASES[1:])
    ap.add_argument("--crts", type=int, default=1)
    ap.add_argument("--coast-min", type=float, default=76.9,
                    help="COAST: minutes after Ti to fly before stopping (default 76.9, to T2)")
    ap.add_argument("--attach", dest="attach_running", action="store_true",
                    help="with --from: drive the vehicle already running on --port-base")
    ap.add_argument("--check-every", type=float, default=30.0,
                    help="seconds of vehicle time between rndz-check.log comparisons (default 30)")
    a = ap.parse_args()
    a.attach = a.attach_running
    fly_sts134.FL["name"] = "sts134r"
    f = Rendezvous(a)
    if a.attach:
        f.ears = Ears(a.port_base)
        threading.Thread(target=f.monitor, daemon=True).start()
    fly_sts134.PHASES[:] = PHASES     # the base class's run() walks these
    f.run()


if __name__ == "__main__":
    main()
