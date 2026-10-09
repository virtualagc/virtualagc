#!/usr/bin/env python3
"""THE DOCKING AUTOPILOT: STS-134's final approach from station-keeping 100 ft
out on the +V-bar to contact with PMA-2, flown by a program on the THC.

    python3 dock_autopilot.py --logs DIR --tape VOLUME --from DOCK30 [...]

takes every option fly_rndz134.py takes, and adds two phases after its HOLD
(so --from DOCK30 resumes from DIR/sts134r-hold):

    DOCK30   100 ft to 30 ft along PMA-2's axis, lined up laterally on the
             way: LOW Z at 0.15 ft/s to 75 ft, then NORM Z, DAP B with
             A10/B10, 0.10 ft/s to 30 ft.
    DOCK     the pause at 30 ft until the ring is on the axis and the drift
             has died (the crew's TARGET ALIGNMENT pause), then 0.07 ft/s to
             10 ft and 0.10 ft/s to contact; capture, and the hard mate.

THE SCHEDULE is the STS-134 VBAR APPROACH cue card (RNDZ p306, CC 9-8;
~/workspace/pass-run/rndz/docking-geometry-findings.md section 4):

    110 ft  -0.15 ft/s
     75 ft  -0.10 ft/s   no LO Z (NORM Z), A10/B10, DAP B; F1F, F2F deselected
     30 ft   0.0         5 deg corridor; angular flyout if required
     30 ft  -0.07 ft/s   "Initiating final approach"
     10 ft  -0.10 ft/s   check no LO Z
      3 ft  -0.10 ft/s   maintain the 3 in lateral alignment cylinder

NOT DONE HERE YET: the F1F/F2F deselection (SPEC 23), and the angular
flyout -- the misalignment is read off the centerline camera at 30 ft and at
contact and reported, but nothing is flown to correct it.

THERE WAS NO DOCKING AUTOPILOT.  Every Shuttle final approach was flown by
hand, the commander on the THC with the centerline camera's cross on the
target.  This is a robot crew member doing the same thing for a crew that
has not trained for it (Ron Burkey, 2026-10-09).  It flies with the manual
phase's one control law (rndz_manual.ManualPhase.fly), on the ODS ring as
the control point, from the instruments' noisy relative state; PASS's DAP
holds the docking attitude throughout.

CONTACT AND CAPTURE are vehdyn.c's (THE DOCKING): the ring meets PMA-2's
face, which stops it; inside the APDS's capture envelope the latches hold and
the Orbiter moves with the ISS, damped, retracted and hooked to hard mate by
itself; outside it there is no capture.  vehdyn reports both in TRU1 [30-31],
and this leg ends on them, the DAP to FREE after a capture.  The ISS needs its
port in the targets file ("port 15.66 0 5.48"; tools/tle_target.py --port).
With a yaGPC2 that does not send them, the leg ends at CONTACT_FT by the
truth, as before.
"""
import os
import socket
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fly_rndz134 as R  # noqa: E402
import discretes as D    # noqa: E402  (fly_rndz134 put the panel directory on the path)

DOCK30_FT = 30.0
NORM_Z_FT = 75.0                 # CC 9-8: no LO Z, A10/B10, DAP B
FINAL_10_FT = 10.0
APPROACH_FPS = 0.15              # 110 -> 75 ft
CLOSE_FPS = 0.10                 # 75 -> 30 ft, and 10 ft to contact
FINAL_FPS = 0.07                 # 30 -> 10 ft
ALIGN_FT = 0.20                  # lateral alignment wanted before closing (~2.4 in)
CONTACT_FT = 0.5                 # where the leg ends while there is no capture model

# THE DOCKING DAP, A10 and B10: JSC-48072-134 p. 6-2, ISS RNDZ OPS DAP
# CONFIGURATIONS, the DOCKING column, by SPEC 20 item (A 10-28, B 30-48) --
# fly_rndz134.DAP_RNDZ's layout.  B10's TRANS PLS 0.01 is the fine pulse
# the last 75 ft are flown with.
DAP_DOCK = {
    "A": {10: 0.050, 11: 0.60, 12: 0.10, 13: 0.10, 14: 0.0, 15: "TAIL", 16: "TAIL", 17: 0.05,
          18: 0.10, 19: "TAIL", 20: 2, 21: 0.08, 22: 0.00,
          23: 0.050, 24: 0.50, 25: 0.020, 26: 0.050, 27: 0.0, 28: 0},
    "B": {30: 0.050, 31: 0.60, 32: 0.10, 33: 0.04, 34: 0.0, 35: "TAIL", 36: "TAIL", 37: 0.01,
          38: 0.10, 39: "TAIL", 40: 2, 41: 0.08, 42: 0.00,
          43: 0.050, 44: 0.50, 45: 0.020, 46: 0.020, 47: 0.0, 48: 0},
}

TRUTH_OFFSET = 98                # TRU1 (mdmdev.c truth_publish)


def tru_dock(self, timeout=3.0):
    """vehdyn's docking from TRU1 [30], [31]: (0 free / 1 captured / 2
    hard-mated, contacts so far), or None from a yaGPC2 that does not send
    them."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    try:
        D.share_port(s)
        s.bind(("", self.a.port_base + TRUTH_OFFSET))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                     struct.pack("4s4s", socket.inet_aton(D.GROUP), socket.inet_aton(D.IFACE)))
        s.settimeout(0.5)
        end = time.monotonic() + timeout
        while time.monotonic() < end:
            try:
                d = s.recv(512)
            except socket.timeout:
                continue
            if d[:4] != b"TRU1":
                continue
            n = (len(d) - 4) // 8
            if n < 32:
                return None
            v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
            return int(v[30]), int(v[31])
        return None
    finally:
        s.close()


def dap_modes(self, side, low_z):
    """DAP <side>/AUTO/VERN, TRANS PULSE in X, Y and Z -- buttons that
    select -- and LOW Z as asked, pressed only while its lamp disagrees: it
    TOGGLES (GCQORB.hal 1348-1360), and dock3, pressing it blind, flew its
    DOCK leg in NORM Z.  The lamps are rndz_manual's (dap_lamps.py)."""
    from dap_lamps import set_low_z
    self.play("+1     dap c3 %s\n+2     dap c3 auto\n+2     dap c3 vern\n"
              "+2     dap c3 x_pulse\n+2     dap c3 y_pulse\n+2     dap c3 z_pulse\n" % side.lower(),
              "dock-dap")
    self.script_done("dock-dap", 120)
    n = {"k": 0}

    def press():
        n["k"] += 1
        name = "dock-lowz-%d" % n["k"]
        self.play("+1     dap c3 low_z\n", name)
        self.script_done(name, 60)

    lamps = self.lamps()
    ok, presses = set_low_z(lamps, press, low_z)
    b_ok = lamps.until("B", side.upper() == "B", timeout=8.0)
    self.say("DAP: %s (lamp %s), LOW Z %s (%d press%s)%s"
             % (side, "B" if lamps.dap_b() else "A", "ON" if lamps.low_z_lit() else "off (NORM Z)",
                presses, "" if presses == 1 else "es",
                "" if ok and b_ok else " -- THE LAMPS DID NOT FOLLOW"))


def _mismatch(vals, side, table):
    bad = {}
    for i, want in table[side].items():
        got = vals.get(i)
        if isinstance(want, str) or got is None or isinstance(got, str):
            if got != want:
                bad[i] = (got, want)
        elif abs(got - want) > 0.0006:
            bad[i] = (got, want)
    return bad


def dap_load(self, label, n, table):
    """"Config DAP A,B to An,Bn" on SPEC 20, the page checked against the
    table, and any difference keyed into the stored configuration (DAP EDIT
    ITEM 3/4 + n, the edit column's 50 + row, LOAD ITEM 5) -- fly_rndz134's
    dap_config, for any n.  An option item (TAIL/ALL) cycles when keyed, so
    it is keyed once a round and read again."""
    nn = "%02d" % n
    nk = " ".join(str(n))
    select = "+3     keys ITEM 1 + %s EXEC\n+3     keys ITEM 2 + %s EXEC\n" % (nk, nk)
    page = self.spec20_page("dock-spec20-%s" % label)
    sel, vals = R.parse_spec20(page)
    self.dump_screen("SPEC 20 DAP CONFIG (%s), as found" % label)
    for rnd in range(4):
        if sel != {"A": nn, "B": nn}:
            name = "dock-select-%s-%d" % (label, rnd)
            self.play("+1" + select[2:], name)
            self.script_done(name, 120)
            self.wait_sim(6)
            sel, vals = R.parse_spec20(self.spec20_page(name + "-page"))
            continue
        edits = ""
        for side, edit in (("A", 3), ("B", 4)):
            bad = _mismatch(vals, side, table)
            if not bad:
                continue
            base = 10 if side == "A" else 30
            self.say("DAP %s%d differs from p. 6-2: %s -- keyed (DAP EDIT, LOAD)"
                     % (side, n, "; ".join("%s (item %d) %s, 6-2 %s" % (R.DAP_ROWS[i - base], i, g, w)
                                           for i, (g, w) in sorted(bad.items()))))
            edits += "+3     keys ITEM %d + %s EXEC\n" % (edit, nk)
            for i, (got, want) in sorted(bad.items()):
                row = i - base
                if isinstance(want, str):
                    edits += "+3     keys ITEM %s EXEC\n" % " ".join(str(50 + row))
                else:
                    edits += "+3     keys ITEM %s %s EXEC\n" % (" ".join(str(50 + row)),
                                                               R.keys_short(want, R.DAP_FMT[row]))
            edits += "+3     keys ITEM 5 EXEC\n"
        if not edits:
            break
        name = "dock-edit-%s-%d" % (label, rnd)
        self.play("+1" + (edits + select)[2:], name)
        self.script_done(name, 300)
        self.wait_sim(6)
        sel, vals = R.parse_spec20(self.spec20_page(name + "-page"))
    self.dump_screen("SPEC 20 DAP CONFIG (%s), A%d/B%d" % (label, n, n))
    bad = {s: _mismatch(vals, s, table) for s in ("A", "B")}
    self.say("DAP CONFIG (%s): SPEC 20 shows DAP A%s B%s, %s"
             % (label, sel.get("A"), sel.get("B"),
                "every item as p. 6-2" if not (bad["A"] or bad["B"]) else "STILL DIFFERENT: %s" % bad))
    self.play("+1     keys RESUME\n", "dock-resume-%s" % label)
    self.script_done("dock-resume-%s" % label, 60)


def camera(self):
    """The centerline camera's misalignment (deg): pitch, yaw, roll."""
    tru, tgt = self.feeds()
    rd = self._inst().read(tru, tgt) if tru else {}
    if "cl_pitch_deg" not in rd:
        return None
    return rd["cl_pitch_deg"], rd["cl_yaw_deg"], rd["cl_roll_deg"]


LEAD_FT = 2.0                    # the schedule never runs further ahead of the Orbiter
JUMP_FT = 20.0                   # a reading this far from the goal is not believed


class RangeSchedule:
    """A goal moving in along PMA-2's axis at the card's rate FOR ITS RANGE
    -- segments [(down_to_ft, fps), ...] -- never more than LEAD_FT ahead of
    where the instruments put the ring.  A goal on a clock ran ahead while
    dock5 flew out a 36 ft offset and then had it sprint at 0.36 ft/s to
    catch up; the crew flies the rate the card gives at the range it reads.
    holding = True keeps it where it is (a pause), and then it does not
    follow the Orbiter out either."""

    def __init__(self, ap, x0, segments):
        self.ap, self.x, self.segments = ap, x0, segments
        self.last, self.holding = None, False

    def rate(self):
        for down_to, fps in self.segments:
            if self.x > down_to + 1e-9:
                return fps
        return 0.0

    def __call__(self, t):
        dt = 0.0 if self.last is None else max(0.0, t - self.last)
        self.last = t
        fps = 0.0 if self.holding else self.rate()
        floor = self.segments[-1][0]
        self.x = max(floor, self.x - fps * dt)
        st = None if self.holding else self.ap.rel("ods")
        if st is not None and abs(st["r"][0] - self.x) < JUMP_FT:
            self.x = max(self.x, st["r"][0] - LEAD_FT)
        fps = 0.0 if self.holding else self.rate()
        return [self.x, 0.0, 0.0], [-fps, 0.0, 0.0]


def settled_at(t_run, n_needed=6, lat_ft=0.5, x_ft=1.0, rate=0.04):
    st = {"n": 0}

    def done(t, s, err):
        ok = (t >= t_run and abs(err[0]) < x_ft and abs(s["r"][1]) < lat_ft
              and abs(s["r"][2]) < lat_ft and max(abs(x) for x in s["v"]) < rate)
        st["n"] = st["n"] + 1 if ok else 0
        return st["n"] >= n_needed
    return done


def orbit_pfd_on_crt2(self):
    """With --crts 2: CRT 2 powered and showing the ORBIT PFD (MEDS FLT INST
    menu: edgekey 2 FLT INST, then edgekey 3 ORBIT PFD), the attitude and
    rates beside the DPS display the driver keys on CRT 1.  PASS loads IDP 2
    itself once it is powered, in about 5 s (fly_sts134.PFD_ON_CRT2)."""
    if self.a.crts < 2 or getattr(self, "pfd_up", False):
        return
    self.play("+1     idppower 2 on\n"
              "+10    edgekey crt2 1\n"          # UP: the main menu
              "+2     edgekey crt2 2\n"          # FLT INST
              "+2     edgekey crt2 3\n",         # ORBIT PFD
              "dock-pfd-crt2")
    self.script_done("dock-pfd-crt2", 120)
    self.pfd_up = True
    self.say("crew: ORBIT PFD on CRT 2")


def dock30(self):
    """A10/B10 loaded and selected while stationkeeping (A10's PRI TRAN PLS
    is the 0.05 ft/s pulse this leg wants); then one continuous approach:
    LOW Z at 0.15 ft/s to 75 ft, where DAP B and NORM Z are pressed on the
    move, and 0.10 ft/s on to 30 ft.

    THE CONFIGURATION IS LOADED FIRST, not at 75 ft: keying the tape's
    generic A10/B10 to p. 6-2 through DAP EDIT took five minutes, and dock4,
    doing it at 75 ft, drifted back out to 102 ft meanwhile.  The card's
    "A10/B10" at 75 ft is a selection the crew had prepared."""
    self.man_start()
    orbit_pfd_on_crt2(self)
    # Lamps latched from before the capture -- rndz-hold-v2's IMU caution and
    # B/U C&W, whose dilemma the RM-threshold seeding had already cleared --
    # reset as the crew would: MSG RESET twice (a pending class-5 ILLEGAL
    # ENTRY absorbs the first, DMTERR.hal 766-788) and MASTER ALARM
    self.play("+1     keys MSG_RESET\n+3     keys MSG_RESET\n+3     press master_alarm\n",
              "dock-msg-reset")
    self.script_done("dock-msg-reset", 60)
    dap_load(self, "dock", 10, DAP_DOCK)
    dap_modes(self, "A", low_z=True)
    self._inst()
    for ax in "xyz":
        self.pulse_est[ax] = DAP_DOCK["A"][17]
    st = self.rel("ods")
    d0 = st["r"][0]
    self.say("DOCK30: ODS ring %.1f ft from PMA-2's face, %.2f %.2f ft off the axis; %s"
             % (d0, st["r"][1], st["r"][2], self.readings()))
    goal = RangeSchedule(self, d0, [(NORM_Z_FT, APPROACH_FPS), (DOCK30_FT, CLOSE_FPS)])

    switched = {"b": d0 <= NORM_Z_FT}
    if switched["b"]:
        dap_modes(self, "B", low_z=False)
        for ax in "xyz":
            self.pulse_est[ax] = 0.02
    settled = settled_at(0.0)

    def done(t, s, err):
        # CC 9-8 at 75 ft: no LO Z, A10/B10, DAP B -- pressed on the move
        if not switched["b"] and s["r"][0] <= NORM_Z_FT:
            switched["b"] = True
            dap_modes(self, "B", low_z=False)
            for ax in "xyz":
                self.pulse_est[ax] = 0.02     # B10's 0.01, as it comes out: learned from here
            self.say("DOCK30: 75 ft -- DAP B, NORM Z; %s" % self.readings())
        return goal.x <= DOCK30_FT + 1e-6 and settled(t, s, err)

    # tau 40 s, every 5 s: dock2 (tau 60, every 8, two pulses) let a sub-foot
    # lateral error stand and was slow to brake in LOW Z
    stats = self.fly("DOCK30", goal, done, point="ods", tau=40.0, vmax=0.20, dead=0.02,
                     every=5.0, limit=(d0 - DOCK30_FT) / CLOSE_FPS + 1800.0, nmax=6)
    self.man_record("DOCK30", start_ft=d0, report=self.leg_report("DOCK30", stats),
                    pulses=dict(self.pulses))


def dock(self):
    """The 30 ft pause until aligned, then 0.07 ft/s to 10 ft and 0.10 ft/s
    to contact; then vehdyn's verdict -- CAPTURE (and the DAP to FREE, the
    stack in free drift until hard mate) or none."""
    self.man_start()
    dap_modes(self, "B", low_z=False)
    # B10's 0.01 ft/s pulse, as it comes out (0.02-0.04 in dock4): unless
    # this process has learned it already (DOCK30), from there.  A fresh
    # process's 0.2 -- A7's -- rounded every correction under 0.1 ft/s to
    # no pulse at all, and with none fired nothing was learned (dock6)
    self._inst()
    for ax in "xyz":
        if self.pulse_est[ax] > 0.06:
            self.pulse_est[ax] = 0.02
    phase = {"closing": False, "aligned": 0, "t10": None, "result": None}
    hist = []
    d0 = tru_dock(self)
    contacts0 = d0[1] if d0 else None
    if d0 is None:
        self.say("DOCK: this yaGPC2 sends no docking state (TRU1 [30-31]); the leg ends at "
                 "%.1f ft of the face" % CONTACT_FT)

    # "on through the face": it is the contact that stops the ring
    goal = RangeSchedule(self, DOCK30_FT, [(FINAL_10_FT, FINAL_FPS), (-1.0, CLOSE_FPS)])
    goal.holding = True

    def contact_report(truth, what):
        # the camera as last read before the ring met the face: at the face
        # PMA-2 is no longer in its picture
        r, v = truth["r"], truth["v"]
        cam = phase.get("cam")
        self.say("DOCK: %s -- ring %.2f ft from the face, %.2f %.2f ft off the axis "
                 "(%.1f %.1f in), closing %.3f ft/s, lateral rates %.3f %.3f ft/s; camera P %s Y %s R %s deg"
                 % ((what, r[0], r[1], r[2], 12 * r[1], 12 * r[2], -v[0], v[1], v[2])
                    + (tuple("%+.1f" % a for a in cam) if cam else ("?",) * 3)))

    def done(t, s, err):
        if not phase["closing"]:
            # judged on the last six readings' MEAN, as a crew reads a
            # jittering display: at 30 ft the instruments' noise is ~0.13 ft
            # a reading, and six in a row inside 0.2 ft held dock4 at 30 ft
            # for minutes while it sat 0.1 ft off the axis
            hist.append((s["r"][1], s["r"][2], s["v"][1], s["v"][2]))
            del hist[:-6]
            m = [sum(h[i] for h in hist) / len(hist) for i in range(4)]
            ok = (len(hist) == 6 and abs(m[0]) < ALIGN_FT and abs(m[1]) < ALIGN_FT
                  and max(abs(m[2]), abs(m[3])) < 0.01)
            phase["aligned"] = 6 if ok else 0
            if phase["aligned"] >= 6:
                phase["closing"] = True
                goal.holding = False
                cam = camera(self)
                self.say("DOCK: aligned at 30 ft (%.2f, %.2f ft off the axis; camera P %s Y %s R %s deg); "
                         "initiating final approach at %.2f ft/s"
                         % ((s["r"][1], s["r"][2]) + (tuple("%+.1f" % a for a in cam) if cam else ("?",) * 3)
                            + (FINAL_FPS,)))
            return False
        truth = self.rel("ods", noisy=False)
        phase["cam"] = camera(self) or phase.get("cam")
        if phase["t10"] is None and truth["r"][0] <= FINAL_10_FT:
            phase["t10"] = t
            self.say("DOCK: 10 ft, %.2f %.2f ft off the axis, closing %.3f ft/s; 0.10 ft/s to contact"
                     % (truth["r"][1], truth["r"][2], -truth["v"][0]))
        if contacts0 is None:
            if truth["r"][0] <= CONTACT_FT:
                contact_report(truth, "CONTACT (by the truth; no capture model)")
                phase["result"] = "contact"
                return True
            return False
        if truth["r"][0] > 2.0:
            return False
        dk = tru_dock(self)
        if dk is None or dk[1] == contacts0:
            return False
        if dk[0] >= 1:
            contact_report(truth, "CAPTURE")
            phase["result"] = "capture"
        else:
            contact_report(truth, "CONTACT, NO CAPTURE (outside the envelope: vehdyn's log has why)")
            phase["result"] = "no capture"
        return True

    stats = self.fly("DOCK", goal, done, point="ods", tau=15.0, vmax=0.12, dead=0.02,
                     every=3.0, limit=3600.0, nmax=5)
    rep = self.leg_report("DOCK", stats)
    self.man_record("DOCK", report=rep, pulses=dict(self.pulses), result=phase["result"])
    if phase["result"] == "capture":
        # "Capture confirmed": the Orbiter's DAP to free drift (CC 9-8
        # CAPTURE block; the ISS goes free too); the APDS damps, retracts
        # and hooks by itself in vehdyn
        self.play("+1     dap c3 free\n", "dock-free")
        self.script_done("dock-free", 60)
        self.say("DOCK: DAP FREE; waiting for the hard mate")
        t_end = time.monotonic() + 1800.0
        while time.monotonic() < t_end:
            dk = tru_dock(self)
            if dk and dk[0] == 2:
                self.say("DOCK: HARD MATE -- %s" % self.readings())
                break
            time.sleep(10.0)
        else:
            self.say("DOCK: no hard mate within 30 min of wall time")
    self.manual_summary()


R.Rendezvous.dock30 = dock30
R.Rendezvous.dock = dock
R.PHASES.extend(["DOCK30", "DOCK"])

if __name__ == "__main__":
    R.main()
