#!/usr/bin/env python3
"""How well rpop.py's TCS NAV holds the relative velocity, and how steady
its predictors are: a station-keeping case flown straight into the filter
(no sockets, no window), the truth beside it.

    python3 examples/rpop_filtercheck.py [--range 100] [--minutes 30] [--pulse 0.1]

The ISS flies a circular 350 km, 51.6 deg orbit (J2) held in LVLH; the
Orbiter in the docking attitude on the +V-bar, its CG drifting by
Clohessy-Wiltshire, with a THC pulse of --pulse ft/s every 60 s (+X or -X
alternately, and every third one also +Z or -Z) -- a crew holding a point
by hand.  The TCS reads it as rndz_instruments does, a mark a second, and
rpop.Rpop._process runs on each 0.1 s step as it does on each TRU1.

Printed: the filter's velocity error (filtered minus truth, ft/s rms, all
three axes), overall and over the quiet 5-60 s after each pulse; how long
after a pulse the error takes to fall back under 0.02 ft/s; and the
9-minute predictor's scatter (the point predicted from the filtered state
less the one predicted from the truth, ft rms, quiet times).
"""
import argparse
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
sys.path.insert(0, os.path.join(HERE, "flights"))
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
import rpop                             # noqa: E402
import rndz_instruments as ri           # noqa: E402
import rpop_synth as syn                # noqa: E402

FT = 0.3048


class Bare(rpop.Rpop):
    """Rpop's processing without its sockets or timers."""
    def __init__(self, seed):
        rpop.QtCore.QObject.__init__(self)
        self.inst = ri.Instruments(seed)
        self.nav = rpop.TcsNav()
        self.tru = None
        self.truAt = 0.0
        self.tgt = None
        self.tgts = []
        self.pending = []
        self.s_used = None
        self.geo = None
        self.hist = []
        self.raw_tcs = None
        self.next_tcs = None
        self.next_hhl = None
        self.hhl = []
        self.hhl_flt = None
        self.last_v = None
        self.dv_acc = np.zeros(3)
        self.imu_acc = np.zeros(3)
        self.dv_pend = np.zeros(3)
        self.tcs_mode = "nav"
        self.tcs_period = rpop.TCS_PERIOD_S
        self.auto = None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--range", type=float, default=100.0, help="DP-DP ft held")
    ap.add_argument("--minutes", type=float, default=30.0)
    ap.add_argument("--pulse", type=float, default=0.1, help="ft/s")
    ap.add_argument("--seed", type=int, default=134)
    a = ap.parse_args()
    rp = Bare(a.seed)
    rn = syn.RE + 350e3
    inc = math.radians(51.6)
    r = np.array([rn, 0.0, 0.0])
    v = math.sqrt(syn.MU / rn) * np.array([0.0, math.cos(inc), math.sin(inc)])
    A = np.column_stack([[0, 0, -1.0], [0, 1.0, 0], [1.0, 0, 0]])
    pma = np.array(ri.PMA2) / FT
    ods = np.array(ri.ODS_BODY) / FT
    off = pma - A @ ods
    s = np.concatenate([off + np.array([a.range, 1.0, -1.0]), [0.0, 0.0, 0.0]])
    h, t = 0.1, 0.0
    pulses = []
    k = 0
    errs = []                         # (t, |dv err|, pred err ft)
    n_end = a.minutes * 60.0
    next_pulse = 60.0
    while t < n_end:
        x = np.concatenate([r, v])

        def f(xx):
            return np.concatenate([xx[3:], syn.gravity(xx[:3])])
        k1 = f(x); k2 = f(x + 0.5 * h * k1); k3 = f(x + 0.5 * h * k2); k4 = f(x + h * k3)
        x = x + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        r, v = x[:3], x[3:]
        n = math.sqrt(syn.MU / np.linalg.norm(r) ** 3)
        c1 = syn.cw(s, n); c2 = syn.cw(s + 0.5 * h * c1, n); c3 = syn.cw(s + 0.5 * h * c2, n)
        c4 = syn.cw(s + h * c3, n)
        s = s + h / 6 * (c1 + 2 * c2 + 2 * c3 + c4)
        t += h
        if t >= next_pulse:
            next_pulse += 60.0
            k += 1
            dv = np.zeros(3)
            dv[0] = a.pulse * (1 if k % 2 else -1)
            if k % 3 == 0:
                dv[2] = a.pulse * (1 if (k // 3) % 2 else -1)
            s[3:] += dv
            pulses.append(t)
        L = np.column_stack([np.array(c) for c in ri.lvlh_axes(list(r), list(v))])
        no = ri.orbital_rate(list(r), list(v))
        w_lvlh = L @ np.array([0.0, -no, 0.0])
        C = L @ A
        rel, relv = s[:3] * FT, s[3:] * FT
        ro = r + L @ rel
        vo = v + L @ relv + np.cross(w_lvlh, L @ rel)
        tru = {"t": t, "gmt": syn.GMT0 + t, "q": tuple(syn.quat(C)), "w": tuple(C.T @ w_lvlh),
               "r": tuple(ro), "v": tuple(vo), "cg": (0.0, 0.0, 0.0), "dock": 0}
        tgt = {"t": t, "norad": 25544, "r": tuple(r), "v": tuple(v), "q": tuple(syn.quat(L))}
        rp.tgt = tgt
        rp.tgts.append(tgt)
        del rp.tgts[:-40]
        rp.tru = tru
        rp._process(tru)
        if rp.nav.x is not None and rp.geo is not None and abs(t - round(t)) < h / 2 and t > 120:
            tg = rp.tgt_at(t)
            tr, tv = rp.rel_truth(tru, tg, rp.geo)
            dverr = float(np.linalg.norm(rp.nav.x[3:] - tv))
            pf = rpop.cw_step(rp.nav.x, rp.geo["n"], 540.0)[:3]
            pt = rpop.cw_step(np.concatenate([tr, tv]), rp.geo["n"], 540.0)[:3]
            errs.append((t, dverr, float(np.linalg.norm(pf - pt))))
    E = np.array(errs)
    since = np.array([t - max([p for p in pulses if p <= t] or [-1e9]) for t in E[:, 0]])
    quiet = (since >= 5.0) & (since < 60.0)
    lags = []
    for p in pulses:
        after = E[(E[:, 0] > p) & (E[:, 0] < p + 60)]
        ok = after[after[:, 1] < 0.02]
        lags.append(ok[0, 0] - p if len(ok) else float("nan"))
    rms = lambda x: float(np.sqrt(np.mean(np.square(x))))
    print("velocity error rms, ft/s: all %.4f, quiet %.4f; max %.4f" % (rms(E[:, 1]), rms(E[quiet, 1]),
                                                                         E[:, 1].max()))
    print("back under 0.02 ft/s after a pulse: median %.1f s, worst %.1f s (%d pulses)"
          % (float(np.nanmedian(lags)), float(np.nanmax(lags)), len(pulses)))
    print("9-min predictor, filtered less truth, ft: rms quiet %.1f, max %.1f"
          % (rms(E[quiet, 2]), E[quiet, 2].max()))


if __name__ == "__main__":
    main()
