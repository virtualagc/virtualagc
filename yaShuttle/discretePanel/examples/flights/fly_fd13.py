#!/usr/bin/env python3
"""FLY STS-134 FROM THE END OF ASCENT TO THE RENDEZVOUS START: OPS 2 coast
through the NC1-NC4 phasing burns, so that the rendezvous begins from the
Orbiter's own state and not from rndz_start.py's synthesized one.

    python3 examples/flights/fly_fd13.py --logs DIR --port-base N --tape VOLUME
            [--from OPS2|NC1|NC2|NC3|NC4] [--to NC4] [--rate X] [--snap-every S]

This is fly_sts134.py with its post-OPS 2 phases replaced.  --from OPS2
resumes DIR/sts134-ops2 (a capture of the ascent run: copy or link the
ascent's sts134-ops2 into --logs); the earlier phases (--from absent) fly the
whole ascent first, in this process.  Each NC phase is a recorded burn (Mission
Report p. 44, p. 40: time, duration, size, engines -- not the direction) done
as the ground did:

  at TIG - 20 min the truth state (standing in for MCC's tracking) is taken
  and a burn designed, in the J2-J4 field both vehicles fly in, so that the
  Orbiter reaches the checklist's NC point (rndz_start.py: 246 kft behind the
  ISS and 1.2 kft below it, Ti - 92 min) at NC4's time -- NC4 itself aims at
  the Ti point (TGT 9's T2) at Ti TIG.  The designed delta-V is keyed through
  PASS in OPS 202 as EXT DV (ITEMs 10, 19-21), LOADed, TIMERed, MNVRed and
  EXECed at TIG - 15 s.  The size flown is logged beside the one designed: a
  difference is the ascent's (a 1 km error in orbit size is 240 km of phasing
  by NC4), or the model's, or the record's, and is a result, not a tolerance.

A capture every --snap-every simulated seconds (default 1800) and one before
each burn, then 'sts134-nc1' ... 'sts134-nc4' at the burns' ends.
"""
import calendar
import math
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
YAGPC2 = os.path.join(os.path.dirname(PANEL), "yaGPC2")
sys.path.insert(0, PANEL)
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(YAGPC2, "tools"))
import fly_sts134 as F          # noqa: E402
import groundstation            # noqa: E402
import rndz_start as RS         # noqa: E402

FT = 0.3048
NORAD = 25544


def gmt(d, h, m, s):
    return d * 86400 + h * 3600 + m * 60 + s


# name, GMT, engines, flown size ft/s, flown duration s  (Mission Report pp. 40, 44)
BURNS = {
    "NC1": (gmt(136, 15, 48, 38.1), "both", 93.6, 66.7),
    "NC2": (gmt(137, 6, 22, 51.6), "right", 11.2, 14.4),
    "NC3": (gmt(137, 15, 41, 14.0), "rcs", 2.7, 11.5),
    "NC4": (gmt(138, 6, 7, 27.4), "left", 8.2, 10.6),
}
TI_GMT = gmt(138, 7, 38, 0.0)
NC_POINT = (-246.0e3 * FT, 0.0, 1.2e3 * FT)     # rndz_start.py's NC point (TGT: X, Y, Z m)
TI_POINT = (-48.6e3 * FT, 0.0, 1.2e3 * FT)      # TGT 9's T2
LEAD_S = 20 * 60.0                              # the design is taken this long before TIG
UNIX_DAY1 = calendar.timegm((2011, 1, 1, 0, 0, 0)) - 86400.0    # GMT 86400 is 2011-01-01 00:00

F.PHASES = ["IPL", "UPLINK", "IMU", "COUNT", "TERMINAL", "ASCENT", "OMS2", "OPS2",
            "NC1", "NC2", "NC3", "NC4"]


def vadd(a, b):
    return [a[i] + b[i] for i in range(3)]


def rel_full(rt, vt, rs, vs):
    """RS.m50_to_lvc, with the along-track angle over the whole circle (atan2):
    the curvilinear X is meaningless past 90 degrees of phase, and an
    unburned Orbiter laps the ISS many times in 38 hours."""
    L, w = RS.gwj_frame(rt, vt)
    R = RS.norm(rt)
    rl = RS.matvec(L, RS.sub(rs, rt))
    vl = RS.matvec(L, RS.sub(vs, vt))
    vl[0] -= -w * rl[2]
    vl[2] -= w * rl[0]
    zcon = R - rl[2]
    th = math.atan2(rl[0], zcon)
    rr = math.hypot(rl[0], zcon)
    return [R * th, rl[1], R - rr, vl[0], vl[1], vl[2]]


def design(r0, v0, rt0, vt0, burn_dts, dtA, aim, unknowns, cons, start=None):
    """The ground's design: burns at burn_dts (seconds from now, the first
    0), unknowns = [(burn index, LVLH axis)], LVLH axes 0 along the track,
    1 minus the orbit normal, 2 down.  Newton over them so that the Orbiter
    is at `aim` (X, Y, Z m, LVC) in the components `cons`, dtA from now.
    Returns the first burn's delta-V (M50 m/s and LVLH components), every
    unknown's value, and the miss left in cons."""
    rtT, vtT = RS.propagate(rt0, vt0, dtA, step=20.0)

    def run(x):
        r, v, t = list(r0), list(v0), 0.0
        first = None
        for i, tb in enumerate(burn_dts):
            if tb > t:
                r, v = RS.propagate(r, v, tb - t, step=20.0)
                t = tb
            rows = RS.lvlh_rows(r, v)
            dvm, dvl = [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]
            for xi, (bi, ax) in zip(x, unknowns):
                if bi == i:
                    dvm = vadd(dvm, RS.mul(xi, rows[ax]))
                    dvl[ax] += xi
            v = vadd(v, dvm)
            if i == 0:
                first = (dvm, dvl)
        r, v = RS.propagate(r, v, dtA - t, step=20.0)
        rel = rel_full(rtT, vtT, r, v)
        return [rel[k] - aim[k] for k in cons], first
    x = list(start) if start else [0.0] * len(unknowns)
    n = len(unknowns)
    for _ in range(10):
        m, _f = run(x)
        if max(abs(c) for c in m) < 5.0:
            break
        h = 0.05
        J = []
        for j in range(n):
            x2 = list(x)
            x2[j] += h
            m2, _ = run(x2)
            J.append([(m2[i] - m[i]) / h for i in range(len(cons))])
        A = [[J[j][i] for j in range(n)] for i in range(len(cons))]
        bvec = [-c for c in m]
        for i in range(n):                                  # square: len(cons) == n
            pv = max(range(i, n), key=lambda q: abs(A[q][i]))
            A[i], A[pv] = A[pv], A[i]
            bvec[i], bvec[pv] = bvec[pv], bvec[i]
            for q in range(i + 1, n):
                f = A[q][i] / A[i][i]
                for c in range(i, n):
                    A[q][c] -= f * A[i][c]
                bvec[q] -= f * bvec[i]
        d = [0.0] * n
        for i in reversed(range(n)):
            d[i] = (bvec[i] - sum(A[i][c] * d[c] for c in range(i + 1, n))) / A[i][i]
        x = [x[j] + d[j] for j in range(n)]
    m, first = run(x)
    return first[0], first[1], x, m


class FD13(F.Flight):
    # --- helpers --------------------------------------------------------
    def orbiter_lb(self):
        for line in reversed(self.log_text().splitlines()):
            m = re.search(r"vehdyn-state:.*mass_kg=([\d.]+)", line)
            if m:
                return float(m.group(1)) / 0.45359237
        return 220000.0 / 2.20462

    def states(self):
        """(orbiter r, v, target r, v, GMT) now, M50 m and m/s, together."""
        tr = self.truth()
        tg = None
        for _ in range(20):
            tg = groundstation.target_state(self.base, NORAD, timeout=3.0)
            if tg:
                break
        if not tg:
            raise SystemExit("fly_fd13: no target state for the ISS (YAGPC_VEHDYN_TARGETS?)")
        rt, vt = RS.propagate(list(tg["r"]), list(tg["v"]), tr["gmt"] - tg["gmt"], step=10.0)
        return list(tr["r"]), list(tr["v"]), rt, vt, tr["gmt"]

    def coast_to(self, gmt_end, tag):
        """Wait for a GMT, with a capture every --snap-every simulated seconds."""
        every = float(self.a.snap_every)
        while True:
            now = self.truth()["gmt"]
            if now >= gmt_end:
                return
            nxt = min(gmt_end, now + every)
            self.wait_gmt(nxt)
            if nxt < gmt_end:
                self.snapshot("%s-g%d" % (tag, int(nxt)))

    # --- one burn -------------------------------------------------------
    def burn(self, name):
        tig, eng, flown_dv, flown_s = BURNS[name]
        self.coast_to(tig - LEAD_S - 60.0, name.lower() + "c")
        r, v, rt, vt, g = self.states()
        # the burn point: both vehicles carried to TIG
        dt0 = tig - g
        rB, vB = RS.propagate(r, v, dt0, step=10.0)
        rtB, vtB = RS.propagate(rt, vt, dt0, step=10.0)
        order = ["NC1", "NC2", "NC3", "NC4"]
        later = [n for n in order[order.index(name):] if n != "NC4"]
        if name == "NC4":
            aim, dtA, tag = TI_POINT, TI_GMT - tig, "the Ti point"
            unknowns, cons, burn_dts = [(0, 0)], [0], [0.0]     # along-track only: the Z is MC's
        else:
            aim, dtA, tag = NC_POINT, BURNS["NC4"][0] - tig, "the NC point"
            burn_dts = [BURNS[n][0] - tig for n in later]
            if name == "NC1":      # along-track and out of plane now, along-track at NC2
                unknowns, cons = [(0, 0), (0, 1), (1, 0)], [0, 1, 2]
            elif name == "NC2":    # along-track now and at NC3
                unknowns, cons = [(0, 0), (1, 0)], [0, 2]
            else:                  # NC3: along-track and radial
                unknowns, cons = [(0, 0), (0, 2)], [0, 2]
        start = None
        if name == "NC1":          # the flown family: posigrade
            start = [flown_dv * FT, 0.0, 0.0]
        dvm, dvl, xs, miss = design(rB, vB, rtB, vtB, burn_dts, dtA, aim, unknowns, cons, start)
        rel = None
        size = math.sqrt(sum(x * x for x in dvm)) / FT
        relnow = RS.m50_to_lvc(rtB, vtB, rB, vB)
        self.say("%s: at TIG the Orbiter is X %+.1f Y %+.1f Z %+.1f kft from the ISS" % (
            name, relnow[0] / FT / 1e3, relnow[1] / FT / 1e3, relnow[2] / FT / 1e3))
        self.say("%s: designed to %s: DVX %+.2f DVY %+.2f DVZ %+.2f ft/s = %.2f ft/s "
                 "(flown %.1f ft/s, %.1f s %s); planned later %s ft/s; miss %s ft" % (
                     name, tag, dvl[0] / FT, dvl[1] / FT, dvl[2] / FT, size, flown_dv, flown_s,
                     eng, ", ".join("%+.1f" % (x / FT) for x in xs[len([1 for u in unknowns if u[0] == 0]):]),
                     ", ".join("%.0f" % (x / FT) for x in miss)))
        self.designs = getattr(self, "designs", {})
        self.designs[name] = dict(dvx=dvl[0] / FT, dvy=dvl[1] / FT, dvz=dvl[2] / FT, size=size,
                                  flown=flown_dv, miss_ft=[x / FT for x in miss], later_ft_s=[x / FT for x in xs],
                                  rel_at_tig_ft=[x / FT for x in relnow])
        with open(os.path.join(self.a.logs, "fd13-designs.json"), "w") as fh:
            import json
            json.dump(self.designs, fh, indent=1)
        self.wait_gmt(tig - LEAD_S)
        self.snapshot(name.lower() + "-pre")
        # --- OPS 202, as the checklist's burn: engines, trims, WT, EXT DV, LOAD
        met = tig - F.T0
        d, rem = divmod(met, 86400.0)
        h, rem = divmod(rem, 3600.0)
        m_, sx = divmod(rem, 60.0)
        trims = ("+4     keys ITEM 6 + 0 . 4 - 5 . 7 + 5 . 7 EXEC\n" if eng == "both" else
                 "+4     keys ITEM 6 + 0 . 4 + 5 . 2 - 5 . 2 EXEC\n")
        sel = {"both": "", "left": "+3     keys ITEM 2 EXEC\n", "right": "+3     keys ITEM 3 EXEC\n",
               "rcs": "+3     keys ITEM 4 EXEC\n"}[eng]
        wt = self.orbiter_lb()

        def kn(x):
            t = "%.1f" % abs(x)
            return ("- " if x < 0 else "+ ") + " ".join(t)
        self.play("+1     keys OPS 2 0 2 PRO\n"
                  "wait crt 1 title 2021/ timeout 180\n"
                  "+3     keys RESUME\n"
                  "wait crt 1 title MNVR EXEC timeout 60\n"
                  + sel + (trims if eng != "rcs" else "") +
                  "+4     keys ITEM 9 + %s EXEC\n" % " ".join("%d" % round(wt)) +
                  "+3     keys ITEM 1 0 + %d + %s + %s + %s EXEC\n" % (
                      d, " ".join("%d" % h), " ".join("%d" % m_), " ".join("%.1f" % sx)) +
                  "+4     keys ITEM 1 9 %s %s %s EXEC\n" % (
                      kn(dvl[0] / FT), kn(dvl[1] / FT), kn(dvl[2] / FT)) +
                  "+3     keys ITEM 2 2 EXEC\n"
                  "+4     keys ITEM 2 3 EXEC\n"
                  "+3     dap c3 a\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 2 7 EXEC\n"
                  "+3     dap c3 x_norm\n"
                  "+2     dap c3 y_norm\n"
                  "+2     dap c3 z_norm\n", name.lower() + "-mnvr")
        self.script_done(name.lower() + "-mnvr", 240)
        self.say("crew: %s LOADed, TIMER, MNVR; %s" % (name, eng))
        self.wait_gmt(tig - 15.0)
        kg0 = self.vehicle_kg()
        self.play("+0     keys EXEC\n", name.lower() + "-exec")
        self.say("crew: EXEC at TIG-15 s (TIG GMT %.1f)" % tig)
        if eng == "rcs":
            self.wait_gmt(tig + flown_s + 60.0)
        else:
            self.wait_gmt(tig + 10.0)
            t0, last = self.truth()["t"], self.vehicle_kg()
            while self.truth()["t"] - t0 < 900.0:
                self.wait_sim(5)
                kg = self.vehicle_kg()
                if kg is None:
                    continue
                if last is not None and kg > last - 2.0:
                    break
                last = kg
            if kg0 is not None and last is not None:
                self.say("%s done: %.0f kg of propellant in the burn" % (name, kg0 - last))
        self.play("+1     dap c3 b\n+2     dap c3 inrtl\n+2     dap c3 alt\n"
                  "+2     dap c3 x_pulse\n+2     dap c3 y_pulse\n+2     dap c3 z_pulse\n"
                  "+3     keys ITEM 4 EXEC\n+3     keys OPS 2 0 1 PRO\n", name.lower() + "-post")
        self.script_done(name.lower() + "-post", 180)
        r, v, rt, vt, g = self.states()
        rel = RS.m50_to_lvc(rt, vt, r, v)
        self.say("%s: after the burn the Orbiter is X %+.1f Y %+.1f Z %+.1f kft, XD %+.2f YD %+.2f "
                 "ZD %+.2f ft/s from the ISS" % (name, rel[0] / FT / 1e3, rel[1] / FT / 1e3,
                                                 rel[2] / FT / 1e3, rel[3] / FT, rel[4] / FT,
                                                 rel[5] / FT))

    def nc1(self): self.burn("NC1")
    def nc2(self): self.burn("NC2")
    def nc3(self): self.burn("NC3")

    def nc4(self):
        self.burn("NC4")
        # the rendezvous starts ten minutes before NCC: carry on to 06:10 UTC
        # (GMT 138/06:10), then hand over
        self.coast_to(gmt(138, 6, 10, 0.0), "nc4c")


def main():
    # the targets: the ISS flown from its May 2011 TLE, so that the truth has
    # a target (fly_rndz134.py's file)
    tf = os.environ.get("YAGPC_VEHDYN_TARGETS") or os.path.expanduser(
        "~/sts134-runs/rendezvous/sts134-targets.txt")
    os.environ["YAGPC_VEHDYN_TARGETS"] = tf
    os.environ.setdefault("YAGPC_MTU_MET_EPOCH", "1305550587.994")
    os.environ.setdefault("YAGPC_OMS_ARMED", "1")
    sys.argv[1:] = [x for x in sys.argv[1:]]
    # --snap-every is ours: pull it out before fly_sts134's parser sees it
    snap = 1800.0
    if "--snap-every" in sys.argv:
        i = sys.argv.index("--snap-every")
        snap = float(sys.argv[i + 1])
        del sys.argv[i:i + 2]
    orig = F.Flight

    class Bound(FD13):
        def __init__(self, a):
            a.snap_every = snap
            super().__init__(a)
    F.Flight = Bound
    F.main()


if __name__ == "__main__":
    main()
