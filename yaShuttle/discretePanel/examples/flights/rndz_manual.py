#!/usr/bin/env python3
"""THE MANUAL PHASE OF STS-134'S RENDEZVOUS (RENDEZVOUS_PLAN.md, Stage 5),
for fly_rndz134.py: the scripted commander from the R-bar arrival to
station-keeping 100 ft out on the +V-bar.

    RBAR   the R-bar: brake and station-keep 600 ft below the ISS (APPROACH
           cue card's last gate, "stationkeep at 600-620 ft"); LOW Z only
           with --low-z (vehdyn's jets have no cant, and the DAP's LOW Z
           +Z, which lives on the aft jets' cant, came out -Z).
    RPM    the R-bar pitch maneuver: SPEC 20 PRI/VERN ROT RATE 0.75, then
           four quarter turns of UNIV PTG's body vector (P 180, 270, 0, 90:
           -X, +Z, +X and back to -Z on the ISS, TGT ID 1, BODY VECT 5),
           a full 360 deg of pitch with the ISS tracked; the rates put back.
    TORVA  the twice-orbital-rate fly-around from the R-bar to the +V-bar,
           -Z target track throughout, 600 ft below to 400 ft ahead.
    VBAR   the docking attitude (UNIV PTG TGT ID 2, BODY VECT 5 P 180: the
           tail to the Earth's centre, the nose to the zenith, the bay toward
           the ISS -- OM found by trying), then the ODS ring brought in along
           PMA-2's axis to 100 ft.
    HOLD   station-keeping there: the ring held 100 ft from PMA-2's face, the
           errors and the propellant measured.

THE SCOPE ENDS AT 100 FT (Ron and PASS-IDLE, 2026-10-06): nothing models the
ODS mechanism or contact, so no close-in approach, no contact.  Docking
would pick up from HOLD: the final approach at 0.1 ft/s from 100 to 30 ft
(the TARGET ALIGNMENT card's pause), then contact at 0.1 ft/s, capture.

THE PILOT.  The crew flew on the instruments (rndz_instruments.py), the
cockpit's own displays and their eyes; this pilot model has one control law
for every leg: the instruments' relative state of a control point (the
Orbiter's centre of mass, or for VBAR and HOLD its ODS ring) against a goal
-- a point and a velocity in the ISS's LVLH frame, moving along the leg's
path -- turned into a velocity wanted,

    v_cmd = v_goal + clip((r_goal - r) / tau, vmax),   dv = v_cmd - v,

and that into THC pulses in DAP TRANS PULSE (DAP A7's PRI TRAN PLS, 0.10
ft/s each) along the body axes, whenever any axis needs more than a deadband.
The crew counted pulses the same way.  Relative positions come from the TCS
(range and bearing of the reflectors at PMA-2, inside 10,000 ft) and HHL,
which here is the truth with their noise added (the same source as their
readings in the logs).
"""
import json
import math
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import rndz_instruments as ins  # noqa: E402

FT = 0.3048
PULSE_FPS = 0.10                 # DAP A7 PRI TRAN PLS (p. 6-2)
RBAR_FT = 600.0                  # APPROACH cue card: stationkeep 600-620 ft
TORVA_END_FT = 400.0             # the +V-bar point TORVA ends at (CG range, "400-310 ft")
HOLD_FT = 100.0                  # ODS ring to PMA-2's face
RPM_RATE = 0.75                  # deg/s, RPM SETUP's PRI and VERN ROT RATE
RPM_STEPS = (180, 270, 0, 90)    # UNIV PTG BODY VECT 5 P: -X, +Z, +X, -Z on the ISS
# DAP A10 and B10, the DOCKING configurations, as JSC-48072-134 p. 6-2's
# DOCKING column has them (SPEC 20 items; this tape's A10/B10 are the generic
# load, 11 items different in each).  Stored, not selected, before the V-bar
# approach, so that the 100 ft capture holds them for the docking autopilot
# (keyed at the hold they cost ~3.5 min and 27-36 ft of drift).
DAP_DOCK = {
    "A": {10: 0.050, 11: 0.60, 12: 0.10, 13: 0.10, 14: 0.0, 15: "TAIL", 16: "TAIL", 17: 0.05,
          18: 0.10, 19: "TAIL", 20: 2, 21: 0.08, 22: 0.0,
          23: 0.050, 24: 0.50, 25: 0.020, 26: 0.050, 27: 0.0, 28: 0},
    "B": {30: 0.050, 31: 0.60, 32: 0.10, 33: 0.04, 34: 0.0, 35: "TAIL", 36: "TAIL", 37: 0.01,
          38: 0.10, 39: "TAIL", 40: 2, 41: 0.08, 42: 0.0,
          43: 0.050, 44: 0.50, 45: 0.020, 46: 0.020, 47: 0.0, 48: 0},
}
DAP_OPTIONS = ("ALL", "NOSE", "TAIL")     # PRI P and Y OPTION cycle in this order;
# ALT JET OPT (row 9) only toggles ALL <-> TAIL (GKKORB.hal 688-697: option 1 <-> 3)


def turn_stopped(t, rate, peak):
    """Whether an attitude maneuver has come to rest (deg/s): slower than
    0.1 deg/s after it has been under way -- faster than 0.3 deg/s at some
    point.  The verniers take more than a minute to bring the Orbiter up
    to speed, so a time limit alone (the first test, "60 s and under
    0.1 deg/s") ends a quarter turn that has barely begun: full-run1's
    first RPM stopped P 180 after 1.2 min, 98 deg from the ISS, turning at
    0.07 deg/s.  A maneuver that never gets going is given up after 5 min."""
    if peak > 0.3:
        return rate < 0.1
    return t > 300.0 and rate < 0.1


def vclip(x, m):
    return max(-m, min(m, x))


class ManualPhase(object):
    """Mixed into fly_rndz134.Rendezvous: needs play, script_done,
    wait_sim, ears, say, snapshot, a.rate, a.logs, TRACK_KEYS."""

    # --- the instruments ---------------------------------------------------
    def _inst(self):
        if not hasattr(self, "_instruments"):
            self._instruments = ins.Instruments(134)
            self.pulses = {k: 0 for k in ("+x", "-x", "+y", "-y", "+z", "-z")}
            # each body axis's pulse as it comes out (ft/s), learned from the
            # response: A7's PRI TRAN PLS is 0.10, but the midcourse trims
            # saw 0.24 (vol-run1, MC3/MC4) -- the DAP's pulse is a minimum
            # jet on-time, and the jets' thrust over the Orbiter's mass
            self.pulse_est = {"x": 0.2, "y": 0.2, "z": 0.2}
        return self._instruments

    def feeds(self):
        """TRU1 and TGT1 at ONE instant, TRU1's GMT: the target's 20 Hz
        samples interpolated there, or -- when TRU1's newest sample is newer
        than TGT1's, so nothing brackets it -- TGT1's newest carried forward
        to it along its velocity with gravity (0.05 s: about a centimetre).
        Before, the raw TGT1 was used then, up to a sample old: 0.066 s at
        7.7 km/s is ~505 m, ~1,650 ft outliers in rel("ods") (PASS-IDLE's
        dock7, at 25 ft).  More than 1 s apart, nothing is returned."""
        tru, tgt, _ = self.ears.snap()
        if not tru or not tgt:
            return None, None
        g = tru["gmt"]
        at = self.ears.truth_at("target", g)
        if at:
            return tru, dict(tgt, r=at[0], v=at[1], gmt=g)
        with self.ears.lock:
            last = self.ears.hist_t[-1] if self.ears.hist_t else None
        if last is None:
            return None, None
        dt = g - last[0]
        if abs(dt) > 1.0:
            self.say("feeds: TRU1 and TGT1 %.2f s apart -- no state this time" % dt)
            return None, None
        r, v = list(last[1]), list(last[2])
        rn = math.sqrt(sum(x * x for x in r))
        a = [-3.986004418e14 * x / rn ** 3 for x in r]
        r = [r[i] + v[i] * dt + 0.5 * a[i] * dt * dt for i in range(3)]
        v = [v[i] + a[i] * dt for i in range(3)]
        return tru, dict(tgt, r=r, v=v, gmt=g)

    def rel(self, point="cg", noisy=True):
        """_rel_once until it gives a state (a dropped jump, or the feeds
        not yet in): a few tries 0.1 s apart, then whatever it gives."""
        for _ in range(30):
            st = self._rel_once(point, noisy)
            if st is not None:
                return st
            time.sleep(0.1)
        return self._rel_once(point, noisy)

    def _rel_once(self, point="cg", noisy=True):
        """The control point's state in the ISS's LVLH (ft, ft/s; x ahead,
        y right of the track, z down, the rotating frame's rates): the
        Orbiter's centre of mass against the ISS's, or ("ods") the ODS ring
        against PMA-2's face.  With noise, as the TCS reads it."""
        tru, tgt = self.feeds()
        if tru is None:
            return None
        if point == "ods":
            _, _, rs, vs, rt, vt = ins.points(tru, tgt)
        else:
            rs, vs, rt, vt = list(tru["r"]), list(tru["v"]), list(tgt["r"]), list(tgt["v"])
        ex, ey, ez = ins.lvlh_axes(list(tgt["r"]), list(tgt["v"]))
        n = ins.orbital_rate(tgt["r"], tgt["v"])
        d, dv = ins.sub(rs, rt), ins.sub(vs, vt)
        r = [ins.dot(d, e) / FT for e in (ex, ey, ez)]
        v = [ins.dot(dv, e) / FT for e in (ex, ey, ez)]
        # rates in the turning frame (as rndz_start.m50_to_lvc): it turns at
        # omega = -n y, and omega x r = (-n z, 0, n x)
        v = [v[0] + n * r[2], v[1], v[2] - n * r[0]]
        # A JUMP GUARD on the truth itself: from one sample to the next the
        # point can move only as its rate carries it (the jets add well under
        # a foot per second); a step far beyond that is a timing fault in the
        # feeds, logged and not used -- three in a row are taken (a restore)
        lastj = self._rel_last.get(point) if hasattr(self, "_rel_last") else None
        if not hasattr(self, "_rel_last"):
            self._rel_last, self._rel_bad = {}, {}
        if lastj and tru["gmt"] > lastj[0]:
            dtj = tru["gmt"] - lastj[0]
            pred = [lastj[1][i] + lastj[2][i] * dtj for i in range(3)]
            jump = math.sqrt(sum((r[i] - pred[i]) ** 2 for i in range(3)))
            if jump > 5.0 + 2.0 * dtj and self._rel_bad.get(point, 0) < 2:
                self._rel_bad[point] = self._rel_bad.get(point, 0) + 1
                self.say("rel(%s): a %.1f ft jump in %.2f s, beyond the motion -- sample dropped"
                         % (point, jump, dtj))
                return None
        self._rel_bad[point] = 0
        self._rel_last[point] = (tru["gmt"], list(r), list(v))
        if noisy:
            g = self._inst().g
            rng = math.sqrt(sum(x * x for x in r))
            # Range and bearing errors separately: the TCS ranges to 0.1 ft +
            # 0.05 % along the line of sight, but the sideways position comes
            # from its bearings (0.03 deg), so it is good to rng x 0.03 deg --
            # a hundredth of an inch at a foot, not the range floor.  Close in
            # to PMA-2 the crew flew on the centerline camera's crosshair: its
            # picture read to about 0.05 deg from the camera, 53 in behind the
            # ring face (rndz_instruments.CLCAM_BODY), whichever is the finer.
            sr = 0.1 + 0.0005 * rng
            sl = rng * math.radians(0.03)
            if point == "ods":
                sl = min(sl, (rng + 4.4) * math.radians(0.05))
            sl = max(sl, 0.002)
            if rng > 1e-6:
                u = [x / rng for x in r]
                # two unit vectors across the line of sight
                a = [0.0, 0.0, 1.0] if abs(u[2]) < 0.9 else [1.0, 0.0, 0.0]
                p1 = [u[1] * a[2] - u[2] * a[1], u[2] * a[0] - u[0] * a[2], u[0] * a[1] - u[1] * a[0]]
                n1 = math.sqrt(sum(x * x for x in p1))
                p1 = [x / n1 for x in p1]
                p2 = [u[1] * p1[2] - u[2] * p1[1], u[2] * p1[0] - u[0] * p1[2], u[0] * p1[1] - u[1] * p1[0]]
                er, e1, e2 = g(sr), g(sl), g(sl)
                r = [r[i] + er * u[i] + e1 * p1[i] + e2 * p2[i] for i in range(3)]
            else:
                r = [x + g(sr) for x in r]
            v = [x + g(0.005) for x in v]
        return {"r": r, "v": v, "t": tru["t"], "gmt": tru["gmt"], "tru": tru, "tgt": tgt,
                "axes": (ex, ey, ez)}

    def readings(self):
        tru, tgt = self.feeds()
        return ins.fmt(self._inst().read(tru, tgt)) if tru else "(no feeds)"

    # --- the THC ------------------------------------------------------------
    def thc_pulses(self, dv_lvlh, axes, q, label, nmax=4):
        """dv (ft/s, LVLH) as THC pulses along the body axes: one deflection
        per pulse (each axis's learned size), back to back.  Returns the
        signed pulse count on each body axis."""
        self._inst()
        ex, ey, ez = axes
        m = [dv_lvlh[0] * ex[i] + dv_lvlh[1] * ey[i] + dv_lvlh[2] * ez[i] for i in range(3)]
        R = ins.qmat(q)
        b = ins.to_body(R, m)
        lines, flown = [], [0.0, 0.0, 0.0]
        for k, ax in enumerate("xyz"):
            npl = int(round(abs(b[k]) / self.pulse_est[ax]))
            npl = min(npl, nmax)
            if npl == 0:
                continue
            sgn = "+" if b[k] > 0 else "-"
            self.pulses[sgn + ax] += npl
            flown[k] = (1 if b[k] > 0 else -1) * npl
            lines += ["+1.0   thc fwd %s%s 0.30" % (sgn, ax)] * npl
        if lines:
            name = "man-%s-%d" % (label, int(time.time() * 10) % 100000)
            self.play("\n".join(lines) + "\n", name)
            self.script_done(name, 120)
            try:
                os.remove(os.path.join(self.a.logs, name + ".script"))
            except OSError:
                pass
        return flown

    def lamps(self):
        """The C3 DAP lamps as PASS lights them (dap_lamps.DapLamps)."""
        if getattr(self, "_lamps", None) is None:
            from dap_lamps import DapLamps
            self._lamps = DapLamps(self.a.port_base)
            if not self._lamps.wait(15.0):
                self.say("DAP lamps: no lamp words from FF1 on port base + 100 in 15 s")
        return self._lamps

    def dap_pulse_modes(self, low_z=None):
        """DAP A/AUTO/VERN, TRANS PULSE in X, Y and Z -- buttons that select,
        so pressing them again does no harm -- and LOW Z as the run asks
        (--low-z; low_z overrides).  LOW Z TOGGLES (GCQORB.hal 1443-1458,
        3256-3280: pressed with the +Z jets already inhibited, it turns the
        option off), so it is pressed only while its lamp disagrees, and the
        lamp is then checked: pressed blind, every second call turned it
        off.  The Y column's third button, a jet selection of its own beside
        Z's NORM/PULSE, which leave it alone; HIGH Z would clear it."""
        if low_z is None:
            low_z = bool(getattr(self.a, "low_z", False))
        self.play("+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 vern\n"
                  "+2     dap c3 x_pulse\n+2     dap c3 y_pulse\n+2     dap c3 z_pulse\n", "man-dap")
        self.script_done("man-dap", 120)
        from dap_lamps import set_low_z
        n = {"k": 0}

        def press():
            n["k"] += 1
            name = "man-low-z-%d" % n["k"]
            self.play("+1     dap c3 low_z\n", name)
            self.script_done(name, 60)

        lamps = self.lamps()
        before = lamps.low_z_lit()
        ok, presses = set_low_z(lamps, press, low_z)
        self.say("DAP: LOW Z %s (lamp %s -> %s, %d press%s)%s"
                 % ("ON" if low_z else "OFF", before, lamps.low_z_lit(), presses,
                    "" if presses == 1 else "es", "" if ok else " -- THE LAMP DID NOT FOLLOW"))

    # --- the one control law ---------------------------------------------------
    def fly(self, label, goal, done, point="cg", tau=120.0, vmax=0.3, dead=0.07, every=10.0,
            limit=1800.0, nmax=4, log_every=60.0):
        """Fly a leg: goal(t) -> (r_goal, v_goal) (ft, ft/s, LVLH), done(t,
        rel, err) -> True to end; t in seconds since the leg began."""
        st0 = self.rel(point)
        t0 = st0["t"]
        last_log = -1e9
        stats = []
        fired = None                     # (LVLH dv commanded, the truth's v then)
        wrong = 0
        while True:
            if hasattr(self, "cw_ack"):
                self.cw_ack()                  # a known alarm, between pulses
            st = self.rel(point)
            if st is None:
                time.sleep(1.0)
                continue
            t = st["t"] - t0
            rg, vg = goal(t)
            err = [rg[i] - st["r"][i] for i in range(3)]
            vcmd = [vg[i] + vclip(err[i] / tau, vmax) for i in range(3)]
            dv = [vcmd[i] - st["v"][i] for i in range(3)]
            truth = self.rel(point, noisy=False)
            terr = [rg[i] - truth["r"][i] for i in range(3)]
            stats.append((t, terr, truth["v"]))
            # THE RESPONSE CHECK: what the last pulses did to the truth's
            # velocity, against what they were for.  Twice the wrong way and
            # the leg stops (manual-run1, 2026-10-09: LOW Z's +Z came out -Z)
            if fired:
                cmd, v_then, counts, axes0, q0 = fired
                got = [truth["v"][i] - v_then[i] for i in range(3)]
                # the pulse size learned, axis by axis, from the body dv
                gm = [got[0] * axes0[0][i] + got[1] * axes0[1][i] + got[2] * axes0[2][i] for i in range(3)]
                gb = ins.to_body(ins.qmat(q0), gm)
                for k, ax in enumerate("xyz"):
                    if counts[k]:
                        est = gb[k] / counts[k]
                        if 0.03 < est < 0.6:
                            self.pulse_est[ax] = 0.6 * self.pulse_est[ax] + 0.4 * est
                cn = math.sqrt(sum(x * x for x in cmd))
                if cn >= 0.15 and sum(cmd[i] * got[i] for i in range(3)) / cn < -0.5 * cn:
                    wrong += 1
                    self.say("%s: the pulses for %+.2f %+.2f %+.2f ft/s changed the velocity by %+.2f %+.2f %+.2f"
                             % (label, *cmd, *got))
                    if wrong >= 2:
                        raise RuntimeError("%s: THC pulses move the vehicle the wrong way; the pilot stops" % label)
                else:
                    wrong = 0
                fired = None
            if t - last_log >= log_every:
                last_log = t
                self.say("%s %+.1f min: %s at X %+.1f Y %+.1f Z %+.1f ft, XD %+.3f YD %+.3f ZD %+.3f ft/s "
                         "(truth); goal X %+.1f Y %+.1f Z %+.1f; pulses %.2f %.2f %.2f ft/s; %s"
                         % (label, t / 60.0, "ODS ring from PMA-2" if point == "ods" else "CG from the ISS's",
                            *truth["r"], *truth["v"], *rg, self.pulse_est["x"], self.pulse_est["y"],
                            self.pulse_est["z"], self.readings()))
            if done(t, st, err) or t > limit:
                if t > limit:
                    self.say("%s: the leg's %.0f min ran out" % (label, limit / 60.0))
                return stats
            # no firing for less than most of a pulse: a pulse is ~0.15
            # ft/s, and a deadband under it limit-cycles (manual-run2's R-bar)
            if max(abs(x) for x in dv) >= max(dead, 0.6 * min(self.pulse_est.values())):
                flown = self.thc_pulses(dv, st["axes"], st["tru"]["q"], label.lower(), nmax)
                if any(flown):
                    fired = (dv, list(truth["v"]), flown, st["axes"], st["tru"]["q"])
            time.sleep(every / max(self.a.rate, 1.0))

    def leg_report(self, label, stats, tail_s=None):
        """The truth's errors over a leg (or its last tail_s seconds)."""
        if not stats:
            return {}
        t1 = stats[-1][0]
        s = [x for x in stats if tail_s is None or x[0] >= t1 - tail_s]
        mx = [max(abs(x[1][i]) for x in s) for i in range(3)]
        rms = [math.sqrt(sum(x[1][i] ** 2 for x in s) / len(s)) for i in range(3)]
        vmx = [max(abs(x[2][i]) for x in s) for i in range(3)]
        rep = {"max_err_ft": mx, "rms_err_ft": rms, "max_rate_fps": vmx, "samples": len(s),
               "span_min": (s[-1][0] - s[0][0]) / 60.0}
        self.say("%s: over %.1f min, the truth's error from the goal max X %.1f Y %.1f Z %.1f ft, "
                 "rms %.1f %.1f %.1f ft; rates up to %.3f %.3f %.3f ft/s"
                 % (label, rep["span_min"], *mx, *rms, *vmx))
        return rep

    def propellant(self, name):
        """RCS propellant left (kg: forward, left aft, right aft) in a capture."""
        try:
            b = json.load(open(os.path.join(self.a.logs, "sts134r-" + name, "vehdyn.json")))["vehdyn"]
            return b[16:19]
        except (OSError, ValueError, KeyError, IndexError):
            return None

    def man_record(self, phase, **kw):
        path = os.path.join(self.a.logs, "manual.json")
        try:
            rec = json.load(open(path))
        except (OSError, ValueError):
            rec = {}
        rec[phase] = kw
        json.dump(rec, open(path, "w"), indent=1)

    # --- UNIV PTG --------------------------------------------------------------
    def univ_ptg(self, name, tgt_id, p, om=0, dap="vern", side="a"):
        """UNIV PTG: CNCL, TGT ID, BODY VECT 5 at pitch p, yaw 0, OM, TRK;
        DAP side/AUTO/dap for the maneuver."""
        self.play("+1     keys RESUME\n"
                  "+3     keys ITEM 2 1 EXEC\n"
                  "+3     keys ITEM 8 + %d EXEC\n"
                  "+3     keys ITEM 1 4 + 5 EXEC\n"
                  "+3     keys ITEM 1 5 + %s EXEC\n"
                  "+3     keys ITEM 1 6 + 0 EXEC\n"
                  "+3     keys ITEM 1 7 + %s EXEC\n"
                  "+3     dap c3 %s\n+2     dap c3 auto\n+2     dap c3 %s\n"
                  "+3     keys ITEM 1 9 EXEC\n"
                  % (tgt_id, " ".join(str(int(p))), " ".join(str(int(om))), side, dap), name)
        self.script_done(name, 180)

    def body_vec_err(self, p, toward="iss"):
        """Degrees between UNIV PTG's BODY VECT 5 at pitch p and its target:
        the ISS, or the Earth's centre."""
        tru, tgt = self.feeds()
        R = ins.qmat(tru["q"])
        bv = ins.to_m50(R, [math.cos(math.radians(p)), 0.0, -math.sin(math.radians(p))])
        d = ins.sub(list(tgt["r"]), list(tru["r"])) if toward == "iss" else [-x for x in tru["r"]]
        c = ins.dot(bv, d) / ins.norm(d)
        return math.degrees(math.acos(max(-1.0, min(1.0, c))))

    def body_rate_dps(self):
        tru, _ = self.feeds()
        return math.degrees(math.sqrt(sum(x * x for x in tru["w"])))

    def wait_pointed(self, p, toward, tol=3.0, limit=600.0, label=""):
        """Until BODY VECT P is on its target by the truth, or the maneuver
        has stopped (body rate under 0.1 deg/s for ~15 s after the first
        minute): TGT ID 1 points at PASS's own state of the ISS, which runs
        degrees off the truth once the radar is down to OUTPUT LOW
        (manual-run2's R-bar: 12 deg), as track_complete found after MC4."""
        t0 = self.ears.snap()[0]["t"]
        still, peak = 0, 0.0
        while True:
            e = self.body_vec_err(p, toward)
            w = self.body_rate_dps()
            t = self.ears.snap()[0]["t"] - t0
            peak = max(peak, w)
            still = still + 1 if turn_stopped(t, w, peak) else 0
            if (e < tol and w < 0.1) or still >= 3 or t > limit:
                self.say("%s: BODY VECT P %d %.1f deg from %s after %.1f min (rate %.2f deg/s)%s"
                         % (label, p, e, "the ISS" if toward == "iss" else "the Earth's centre", t / 60.0, w,
                            "" if e < tol else (" -- stopped there (PASS's own target)" if still >= 3
                                                else " -- NOT THERE")))
                return e, t
            time.sleep(5.0 / max(self.a.rate, 1.0))

    def spec20_rates(self, name, pri, vern):
        """SPEC 20: the selected DAP A's PRI ROT RATE (ITEM 10) and VERN ROT
        RATE (ITEM 23)."""
        def keys_short(x, fmt):            # as fly_rndz134's
            t = (fmt % abs(x)).rstrip("0").rstrip(".") or "0"
            t = t[1:] if t.startswith("0.") else t
            return ("- " if x < 0 else "+ ") + " ".join(t)
        self.play("+1     keys SPEC 2 0 PRO\n"
                  "wait crt 1 title /020/ timeout 120\n"
                  "+3     keys ITEM 1 0 %s EXEC\n"
                  "+3     keys ITEM 2 3 %s EXEC\n"
                  "+3     keys RESUME\n" % (keys_short(pri, "%.4f"), keys_short(vern, "%.4f")), name)
        self.script_done(name, 240)

    # --- the phases -------------------------------------------------------------
    def man_start(self):
        """Every phase of the manual part, resumed or not, starts here."""
        self._inst()
        st = self.rel("cg", noisy=False)
        self.say("MANUAL: CG from the ISS's X %+.1f Y %+.1f Z %+.1f ft, XD %+.3f YD %+.3f ZD %+.3f ft/s; %s"
                 % (*st["r"], *st["v"], self.readings()))
        return st

    def rbar(self):
        """APPROACH cue card's end: brake to the 600 ft gate and stationkeep
        at 600-620 ft on the R-bar, out-of-plane nulled; LOW Z (below
        1,000 ft, so that the up-firing jets do not plume the ISS); DAP
        A/AUTO/VERN, TRANS PULSE."""
        self.man_start()
        self.dap_pulse_modes()
        self.say("crew: DAP A/AUTO/VERN, TRANS PULSE%s; stationkeep on the R-bar at %.0f ft"
                 % (", LOW Z" if getattr(self.a, "low_z", False) else " (NOT LOW Z: --low-z not given)",
                    RBAR_FT))
        settled = {"n": 0}

        def done(t, st, err):
            ok = (abs(err[0]) < 25 and abs(err[1]) < 25 and abs(err[2]) < 15
                  and max(abs(x) for x in st["v"]) < 0.12)       # a pulse is ~0.15 ft/s
            settled["n"] = settled["n"] + 1 if ok else 0
            return t > 480.0 and settled["n"] >= 12

        stats = self.fly("RBAR", lambda t: ([0.0, 0.0, RBAR_FT], [0.0, 0.0, 0.0]), done,
                         tau=150.0, vmax=0.3, dead=0.08, every=10.0, limit=1800.0)
        rep = self.leg_report("RBAR (the last 3 min)", stats, 180.0)
        self.man_record("RBAR", report=rep, pulses=dict(self.pulses))

    def rpm(self):
        """RPM SETUP and the RPM (cue card RPM): the rates to 0.75 deg/s,
        then a full turn in pitch about the ISS line of sight, the ISS held
        in the track and the R-bar point held; then the rates back (p. 6-2's
        A7: 0.200 and 0.016) and the -Z target track."""
        self.man_start()
        self.spec20_rates("rpm-setup", RPM_RATE, RPM_RATE)
        self.say("crew: RPM SETUP -- PRI and VERN ROT RATE %.2f deg/s" % RPM_RATE)
        # read them back: full-run1's quarter turns crawled at ~0.07 deg/s
        try:
            from fly_rndz134 import parse_spec20
            sel, vals = parse_spec20(self.spec20_page("rpm-check"))
            self.say("RPM SETUP check: SPEC 20 DAP A%s PRI ROT RATE %s, VERN ROT RATE %s; DAP B%s %s, %s"
                     % (sel.get("A"), vals.get(10), vals.get(23), sel.get("B"), vals.get(30), vals.get(43)))
            self.play("+1     keys RESUME\n", "rpm-check-resume")
            self.script_done("rpm-check-resume", 60)
            mem = self.probe("rpm-setup")
            ds = mem.dap_selected() if mem else None
            if ds:
                self.say("RPM SETUP check: PASS's selected DAP MNVR_RATE %.4f deg/s (A %s, B %s)"
                         % (ds["MNVR_RATE"], ds["A"], ds["B"]))
        except Exception as e:                       # a check only
            self.say("RPM SETUP check: could not read SPEC 20 (%s)" % e)
        t0 = self.ears.snap()[0]["t"]
        times, stats = [], []
        hold = lambda t: ([0.0, 0.0, RBAR_FT], [0.0, 0.0, 0.0])
        for p in RPM_STEPS:
            self.univ_ptg("rpm-p%03d" % p, 1, p)
            # THE R-BAR POINT HELD THROUGH THE TURN: the verniers that turn
            # the Orbiter also push it (vehdyn's jets fire along the body
            # axes, so every pitch pair is a net -Z), and manual-run2's
            # first RPM, holding only between quarter turns, drifted out
            # to 1,640 ft at 2 ft/s
            w = {"still": 0, "peak": 0.0}

            def turned(t, st, err, p=p, w=w):
                e = self.body_vec_err(p, "iss")
                rate = self.body_rate_dps()
                w["peak"] = max(w["peak"], rate)
                w["still"] = w["still"] + 1 if turn_stopped(t, rate, w["peak"]) else 0
                if (e < 3.0 and rate < 0.1) or w["still"] >= 2:
                    w["e"], w["t"] = e, t
                    return True
                return False

            off = stats[-1][0] + 8.0 if stats else 0.0     # the quarter turns end to end
            stats += [(x[0] + off,) + tuple(x[1:])
                      for x in self.fly("RPM P %d" % p, hold, turned, tau=120.0, vmax=0.3, dead=0.08,
                                        every=8.0, limit=480.0, log_every=120.0)]
            times.append((p, w.get("e", self.body_vec_err(p, "iss")), w.get("t", 480.0)))
            self.say("RPM: BODY VECT P %d %.1f deg from the ISS after %.1f min%s"
                     % (p, times[-1][1], times[-1][2] / 60.0,
                        "" if times[-1][1] < 3.0 else " (stopped there: PASS's own target)"))
        t = self.ears.snap()[0]["t"] - t0
        self.say("RPM: 360 deg of pitch in %.1f min (the flight's 0.75 deg/s: 8.0 min); quarter turns %s"
                 % (t / 60.0, ", ".join("P %d %.1f deg in %.1f min" % (p, e, d / 60.0) for p, e, d in times)))
        self.spec20_rates("rpm-end", 0.200, 0.016)
        self.play("+1     keys RESUME\n" + self.TRACK_KEYS.replace("dap c3 b", "dap c3 a")
                  .replace("dap c3 alt", "dap c3 vern"), "rpm-track")
        self.script_done("rpm-track", 180)
        rep = self.leg_report("RPM (the R-bar point through the turn)", stats)
        self.man_record("RPM", minutes=t / 60.0, steps=times, report=rep, pulses=dict(self.pulses))

    def torva(self):
        """TORVA: from the R-bar to the +V-bar at twice the orbital rate,
        -Z on the ISS (target track) and the ISS in the centerline camera,
        range kept above 250 ft port to port; the arc's radius from where
        the R-bar left the Orbiter to TORVA_END_FT."""
        st = self.man_start()
        self.dap_pulse_modes()
        tru, tgt = self.feeds()
        n = ins.orbital_rate(tgt["r"], tgt["v"])
        th0 = math.atan2(st["r"][0], st["r"][2])          # 0 below, 90 deg ahead
        r0 = math.hypot(st["r"][0], st["r"][2])
        th1 = math.pi / 2.0
        w = 2.0 * n
        T = (th1 - th0) / w

        def goal(t):
            u = min(max(t, 0.0), T)
            th = th0 + w * u
            rr = r0 + (TORVA_END_FT - r0) * (u / T)
            drr = (TORVA_END_FT - r0) / T if t < T else 0.0
            dth = w if t < T else 0.0
            pos = [rr * math.sin(th), 0.0, rr * math.cos(th)]
            vel = [drr * math.sin(th) + rr * math.cos(th) * dth, 0.0, drr * math.cos(th) - rr * math.sin(th) * dth]
            return pos, vel

        self.say("crew: TORVA -- %.0f deg around at twice the orbital rate (%.1f min), %.0f to %.0f ft"
                 % (math.degrees(th1 - th0), T / 60.0, r0, TORVA_END_FT))
        settled = {"n": 0}

        def done(t, s, err):
            ok = abs(err[0]) < 20 and abs(err[2]) < 20 and abs(err[1]) < 20 and max(abs(x) for x in s["v"]) < 0.12
            settled["n"] = settled["n"] + 1 if (t > T and ok) else 0
            return settled["n"] >= 9

        stats = self.fly("TORVA", goal, done, tau=60.0, vmax=0.6, dead=0.08, every=10.0, limit=T + 900.0)
        rep = self.leg_report("TORVA (whole)", stats)
        self.man_record("TORVA", minutes=T / 60.0, report=rep, pulses=dict(self.pulses))

    def docking_attitude(self):
        """ESTABLISH VBAR: the attitude held in LVLH -- UNIV PTG TGT ID 2
        (the Earth's centre), BODY VECT 5 P 180 (-X), so the nose is at the
        zenith; the roll about it (OM) the one that turns the bay (-Z) to the
        ISS, found by trying 0, 90, 180, 270 (OM's reference is not in this
        repository's notes) and kept."""
        best = None
        here = self.rel("cg", noisy=False)["r"]
        hold = lambda t: (list(here), [0.0, 0.0, 0.0])
        for om in (0, 90, 180, 270):
            # DAP B/AUTO/ALT for the maneuver (B7's 0.5 deg/s), as the
            # track's own maneuvers ([12A]); A7's VERN ROT RATE is 0.016
            # deg/s, a 90 deg roll in an hour and a half (manual-run2's first
            # VBAR: no OM had time to roll)
            self.univ_ptg("vbar-att-om%d" % om, 2, 180, om, dap="alt", side="b")
            w = {"still": 0}

            def turned(t, st, err, w=w):
                # OM rolls the Orbiter about -X, which is already on the
                # Earth's centre: -X's pointing cannot show the roll done, so
                # the turn is done once the vehicle has been seen turning and
                # has stopped (or never started, after 90 s)
                rate = self.body_rate_dps()
                w["moved"] = w.get("moved") or rate > 0.15
                w["still"] = w["still"] + 1 if (t > 20.0 and rate < 0.1 and (w["moved"] or t > 90.0)) else 0
                return w["still"] >= 3

            # the point TORVA left the Orbiter at held through the turn (the
            # verniers push, as in the RPM)
            self.fly("VBAR attitude OM %d" % om, hold, turned, tau=120.0, vmax=0.3, dead=0.08, every=8.0,
                     limit=600.0, log_every=120.0)
            tru, tgt = self.feeds()
            ex, _, _ = ins.lvlh_axes(list(tgt["r"]), list(tgt["v"]))
            mz = ins.to_m50(ins.qmat(tru["q"]), [0.0, 0.0, -1.0])
            ang = math.degrees(math.acos(max(-1.0, min(1.0, -ins.dot(mz, ex)))))
            self.say("VBAR attitude: OM %d puts -Z %.1f deg from the -V-bar (toward the ISS); -X %.1f deg "
                     "from the Earth's centre" % (om, ang, self.body_vec_err(180, "earth")))
            if best is None or ang < best[1]:
                best = (om, ang)
            # a wrong OM is ~90 deg off; what is left of a right one is the
            # track's own error (PASS's state, the DAP's deadband)
            if ang < 15.0:
                break
        if best[0] != om:
            self.univ_ptg("vbar-att-om%d-final" % best[0], 2, 180, best[0], dap="alt", side="b")
            w = {"still": 0}

            def back(t, st, err, w=w):
                rate = self.body_rate_dps()
                w["moved"] = w.get("moved") or rate > 0.15
                w["still"] = w["still"] + 1 if (t > 20.0 and rate < 0.1 and (w["moved"] or t > 90.0)) else 0
                return w["still"] >= 3

            self.fly("VBAR attitude OM %d" % best[0], hold, back, tau=120.0, vmax=0.3, dead=0.08, every=8.0,
                     limit=600.0, log_every=120.0)
        self.play("+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 vern\n", "vbar-att-vern")
        self.script_done("vbar-att-vern", 60)
        self.say("crew: ESTABLISH VBAR -- LVLH, nose to the zenith, bay to the ISS (OM %d, -Z %.1f deg off)"
                 % best)
        return best

    def dap_dock_store(self, config=10, tries=3):
        """DAP A10/B10 keyed to DAP_DOCK in the stored configurations (DAP
        EDIT: DAP A - ITEM 3 +10, the edit column's item 50 + row, LOAD -
        ITEM 5; the same with DAP B - ITEM 4), A7/B7 left selected; every
        item read back off SPEC 20's edit column.  An option item is pressed
        once per step ALL -> NOSE -> TAIL, ALT JET OPT once (it toggles ALL
        <-> TAIL).  Returns the items still wrong."""
        from fly_rndz134 import parse_spec20, keys_short, DAP_FMT
        left = {}
        for side, edit in (("A", 3), ("B", 4)):
            base = 10 if side == "A" else 30
            want = DAP_DOCK[side]
            bad = None
            for attempt in range(tries):
                name = "dap-dock-%s%d-%d" % (side.lower(), config, attempt)
                self.play("+1     keys SPEC 2 0 PRO\n"
                          "wait crt 1 title /020/ timeout 120\n"
                          "+3     keys ITEM %d + %s EXEC\n" % (edit, " ".join(str(config))), name)
                self.script_done(name, 180)
                self.wait_sim(6)
                sel, vals = parse_spec20(self.spec20_page(name + "-page"))
                bad, keys = {}, ""
                for item, w in sorted(want.items()):
                    row = item - base
                    e = 50 + row
                    got = vals.get(e)
                    if isinstance(w, str):
                        if got != w:
                            bad[item] = (got, w)
                            if row == 9:                      # ALT JET OPT: a toggle
                                n = 1
                            else:
                                n = ((DAP_OPTIONS.index(w) - DAP_OPTIONS.index(got)) % 3
                                     if got in DAP_OPTIONS else 1)
                            keys += "+3     keys ITEM %s EXEC\n" % " ".join(str(e)) * 1
                            keys += ("+3     keys ITEM %s EXEC\n" % " ".join(str(e))) * (n - 1)
                    else:
                        fmt = DAP_FMT.get(row, "%.3f")
                        if got is None or isinstance(got, str) or abs(got - w) > 0.5 * 10 ** -int(
                                fmt[2] if fmt[1] == "." else 0):
                            bad[item] = (got, w)
                            keys += "+3     keys ITEM %s %s EXEC\n" % (" ".join(str(e)), keys_short(w, fmt))
                if not bad:
                    break
                self.say("DAP %s%d: %d items differ from p. 6-2's DOCKING column: %s -- keyed (DAP EDIT, LOAD)"
                         % (side, config, len(bad), "; ".join("item %d %s, 6-2 %s" % (i, g, w2)
                                                            for i, (g, w2) in sorted(bad.items()))))
                name = "dap-dock-%s%d-edit-%d" % (side.lower(), config, attempt)
                self.play("+1" + (keys + "+3     keys ITEM 5 EXEC\n")[2:], name)
                self.script_done(name, 600)
                self.wait_sim(6)
            if bad:
                left[side] = bad
            self.say("DAP %s%d: %s" % (side, config, "every item as p. 6-2's DOCKING column" if not bad
                                         else "STILL DIFFERENT: %s" % bad))
        sel, _ = parse_spec20(self.spec20_page("dap-dock-check"))
        if sel != {"A": "07", "B": "07"}:
            # "__": the active DAP edited in place (RPM SETUP's rates, then
            # A7's put back by hand) -- A7/B7 loaded again, as stored
            self.say("DAP DOCK: SPEC 20 shows A%s B%s -- DAP A/B - ITEM 1/2 +7 keyed"
                     % (sel.get("A"), sel.get("B")))
            self.play("+1     keys ITEM 1 + 7 EXEC\n+3     keys ITEM 2 + 7 EXEC\n", "dap-dock-sel7")
            self.script_done("dap-dock-sel7", 120)
            self.wait_sim(6)
            sel, _ = parse_spec20(self.spec20_page("dap-dock-check2"))
        self.say("DAP DOCK: stored A%d/B%d; selected A%s B%s" % (config, config, sel.get("A"), sel.get("B")))
        self.play("+1     keys RESUME\n", "dap-dock-resume")
        self.script_done("dap-dock-resume", 60)
        return left

    def vbar(self):
        """VBAR APPROACH to 100 ft, ODS ring to PMA-2's face, along PMA-2's
        axis: closing at range/1000 ft/s (0.1 ft/s at the least), the
        lateral and vertical lined up to the centerline camera's cross.
        First DAP A10/B10 are stored as p. 6-2's DOCKING (dap_dock_store)."""
        self.man_start()
        self.dap_dock_store()
        om = self.docking_attitude()
        self.dap_pulse_modes()
        st = self.rel("ods")
        d0 = st["r"][0]
        self.say("VBAR: ODS ring %.1f ft from PMA-2's face; %s" % (d0, self.readings()))

        def dist(t):
            # d' = -max(0.1, d/1000): exponential to 100 ft, then linear
            d = d0
            t_e = 1000.0 * math.log(max(d0, 100.0) / 100.0) if d0 > 100.0 else 0.0
            if t < t_e:
                d = d0 * math.exp(-t / 1000.0)
                return max(d, HOLD_FT), -d / 1000.0
            return HOLD_FT, 0.0

        def goal(t):
            d, dd = dist(t)
            return [d, 0.0, 0.0], [dd, 0.0, 0.0]

        settled = {"n": 0}

        def done(t, s, err):
            d, _ = dist(t)
            ok = d <= HOLD_FT and all(abs(x) < 5.0 for x in err) and max(abs(x) for x in s["v"]) < 0.1
            settled["n"] = settled["n"] + 1 if ok else 0
            return settled["n"] >= 6

        stats = self.fly("VBAR", goal, done, point="ods", tau=60.0, vmax=0.4, dead=0.05, every=10.0,
                         limit=3600.0, nmax=3)
        rep = self.leg_report("VBAR (whole)", stats)
        self.man_record("VBAR", om=om, start_ft=d0, report=rep, pulses=dict(self.pulses))

    def hold(self):
        """Station-keeping 100 ft out on the +V-bar, the ring on PMA-2's
        axis, for --hold-min minutes; the truth's errors, the pulses and the
        propellant over the hold."""
        self.man_start()
        # the docking start point clean: IMU 1 selected (a capture flown
        # before the [10A]/[10B] fix has it deselected), the latched class-2
        # messages and lamps reset, the tone acknowledged
        if hasattr(self, "imu1_select"):
            self.imu1_select(True, "hold")
            # MSG RESET twice: with a class-5 message pending (an ILLEGAL
            # ENTRY on the IDP), the first press only clears that and brings
            # back the queued fault message -- CDL_MSG is not set
            # (DMTERR.hal:766-788), so the C&W latches (DGNLIGHT, DLALIGHT)
            # stay set; the second press resets them.  A spare press is harmless.
            self.play("+1     keys MSG_RESET\n+3     keys MSG_RESET\n+3     press master_alarm\n",
                      "hold-msg-reset")
            self.script_done("hold-msg-reset", 60)
            self.say("crew: MSG RESET, MASTER ALARM")
        p0 = dict(self.pulses)
        prop0 = self.propellant("vbar")
        mins = getattr(self.a, "hold_min", 20.0)
        stats = self.fly("HOLD", lambda t: ([HOLD_FT, 0.0, 0.0], [0.0, 0.0, 0.0]),
                         lambda t, s, e: t >= mins * 60.0, point="ods", tau=90.0, vmax=0.2, dead=0.05,
                         every=10.0, limit=mins * 60.0 + 60.0, nmax=2, log_every=120.0)
        rep = self.leg_report("HOLD", stats)
        dp = {k: self.pulses[k] - p0.get(k, 0) for k in self.pulses}
        self.say("HOLD: %d THC pulses (%s) in %.0f min, about %.2f ft/s of translation; %s"
                 % (sum(dp.values()), ", ".join("%s %d" % kv for kv in dp.items() if kv[1]), mins,
                    sum(n * self.pulse_est[k[1]] for k, n in dp.items()), self.readings()))
        # p. 6-2's DOCKING A10/B10 checked (and finished) in the stored configurations
        # and A7/B7 selected, so that the capture after the hold carries them
        dock_left = self.dap_dock_store()
        self.dap_pulse_modes()
        self.man_record("HOLD", minutes=mins, report=rep, pulses=dp, prop_before=prop0,
                        dap_dock_left={k: {str(i): v for i, v in d.items()} for k, d in dock_left.items()})
        self.snapshot("hold-end")
        self.manual_summary()

    def manual_summary(self):
        """The propellant over the manual phase, from the phase captures."""
        names = ["arrival", "rbar", "rpm", "torva", "vbar", "hold-end"]
        prev, lines = None, []
        for nm in names:
            p = self.propellant(nm)
            if p and prev:
                used = [(prev[i] - p[i]) / 0.45359237 for i in range(3)]
                lines.append("  %-8s FRCS %6.1f  L ARCS %6.1f  R ARCS %6.1f  total %6.1f lb"
                             % (nm.upper(), *used, sum(used)))
            prev = p or prev
        if lines:
            self.say("THE MANUAL PHASE'S RCS PROPELLANT (truth, from the captures):\n" + "\n".join(lines))
