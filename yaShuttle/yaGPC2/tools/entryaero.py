#!/usr/bin/env python3
"""tools/entryaero.py -- the orbiter's longitudinal entry aerodynamics, built from
primary sources.  `python3 tools/entryaero.py --header` writes src/entryaero.h
(the tables vehdyn interpolates); with no argument it prints the OFP
calibration.  Data in tools/aero/: oa98-final.csv (CR-141550 appendix, read
from the scans and proofread), la66-run{1,2,3}.txt (CR-147621 runs 1-3),
sts1-entry-ofp.csv (JSC-14483 Vol. 5, digitized), tp1011-lat.csv,
tp1634-dyn.csv, tp1779-static.csv (NASA TP-1011/1634/1779, digitized).

THE RULE.  Wind-tunnel tables give the SHAPES: how CN, CA and Cm vary with
alpha, and what each surface does.  The STS-1 descent OFP (JSC-14483 Vol. 5,
April 1979 ADDB) gives the LEVEL: at each of its points the model reproduces
the flown CL and CD, and is trimmed (Cm = 0 about the flight c.g.) at the
flown elevon, body flap and speedbrake.

  hypersonic shapes  OA98, NASA CR-141550: M 5.25, 10.27; 140A/B, O11-M7+M14
  subsonic shapes    LA66, NASA CR-147621: M 0.29, RN 8.4/ft, speedbrake 25
  level and trim     JSC-14483 Vol. 5 figs 6.2-33..43 (entry-ofp.csv)

Body axes, coefficients on S 2690 ft^2, c 474.8 in; moments about the MRP
X 1076.7 / Z 375.0 in (both tunnel reports and the OFP's c.g. are in the
same orbiter structural frame: X aft, Z up).  Angles in degrees; elevon and
body flap positive trailing edge DOWN; speedbrake in degrees (100% = 98.6).
"""
import csv, math, os, bisect

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, 'aero')
SREF, CREF, XMRP, ZMRP = 2690.0, 474.8, 1076.7, 375.0
SB_DEG_PER_PCT = 0.986

def _interp(xs, ys, x):
    """Linear, extrapolating linearly from the end segments."""
    if x <= xs[0]: i = 0
    elif x >= xs[-1]: i = len(xs) - 2
    else: i = bisect.bisect_right(xs, x) - 1
    f = (x - xs[i]) / (xs[i + 1] - xs[i])
    return ys[i] + f * (ys[i + 1] - ys[i])

class Curve:
    """CN, CA, CM against alpha for one tunnel run."""
    def __init__(self, rows):
        rows = sorted(rows, key=lambda r: r[0])
        self.a = [r[0] for r in rows]
        self.cn = [r[1] for r in rows]; self.ca = [r[2] for r in rows]; self.cm = [r[3] for r in rows]
    def at(self, a):
        return _interp(self.a, self.cn, a), _interp(self.a, self.ca, a), _interp(self.a, self.cm, a)

# ---------- the tunnel data ----------
def _oa98():
    runs = {}
    for r in csv.DictReader(open(os.path.join(DATA, 'oa98-final.csv'))):
        if not r['config'].startswith('OA98 (O11-M7+M14) ') or float(r['beta']) != 0.0:
            continue
        k = (float(r['mach']), float(r['elevon']), float(r['bdflap']), float(r['spdbrk']))
        runs.setdefault(k, []).append((float(r['alpha']), float(r['cn']), float(r['ca']), float(r['clm'])))
    return {k: Curve(v) for k, v in runs.items()}

def _la66(name):
    rows = []
    for l in open(os.path.join(DATA, name)):
        if l.startswith('#'): continue
        v = [float(x) for x in l.split()]
        rows.append((v[1], v[3], v[4], v[5]))         # alpha CN CA CLM
    return Curve(rows)

OA = _oa98()
LA = {0.0: _la66('la66-run1.txt'), 5.0: _la66('la66-run2.txt'), -5.0: _la66('la66-run3.txt')}

# Hypersonic surfaces, as increments from the elevon 0 / body flap -11.7 /
# speedbrake 55 run at the same Mach.  Body flap only at M 10.27 (used for
# both); speedbrake only at M 5.25 (used for both); elevon at both.
def _hyp_base(M):
    return OA[(M, 0.0, -11.7, 55.0)]

def _hyp_incr(M, a, de, dbf, dsb):
    b = _hyp_base(M).at(a)
    out = [0.0, 0.0, 0.0]
    # elevon: -40, -10, 0 measured; positive deflections extrapolate the 0/-10 slope
    els = sorted(e for (m, e, f, s) in OA if m == M and f == -11.7 and s == 55.0)
    vals = [OA[(M, e, -11.7, 55.0)].at(a) for e in els]
    for j in range(3):
        out[j] += _interp(els, [v[j] for v in vals], de) - b[j]
    # body flap: -11.7, 0, 16.3 at M 10.27, elevon 0
    bfs = [-11.7, 0.0, 16.3]
    bv = [OA[(10.27, 0.0, f, 55.0)].at(a) for f in bfs]
    b10 = bv[0]
    for j in range(3):
        out[j] += _interp(bfs, [v[j] for v in bv], dbf) - b10[j]
    # speedbrake: 55 and 85 at M 5.25, elevon 0 -- linear in deflection
    s55 = OA[(5.25, 0.0, -11.7, 55.0)].at(a); s85 = OA[(5.25, 0.0, -11.7, 85.0)].at(a)
    for j in range(3):
        out[j] += (s85[j] - s55[j]) / 30.0 * (dsb - 55.0)
    return b, out

def _sub_incr(a, de):
    b = LA[0.0].at(a)
    els = [-5.0, 0.0, 5.0]
    vals = [LA[e].at(a) for e in els]
    return b, [_interp(els, [v[j] for v in vals], de) - b[j] for j in range(3)]

# ---------- the shape at any Mach, before the OFP level is applied ----------
LOGM_SUB, LOGM_HYP = math.log(0.29), math.log(5.25)

def shape(M, a, de, dbf, dsb):
    """Tunnel CN, CA, CM about the MRP: hypersonic interpolated between 5.25
    and 10.27 (held beyond), subsonic below 0.29, and between the two a blend
    in log Mach.  Subsonic has no body flap or speedbrake data yet: those
    increments are the hypersonic ones faded out (FLAGGED: to be replaced
    from TP-1779 when digitized)."""
    def hyp(M):
        Mc = min(max(M, 5.25), 10.27)
        w = (Mc - 5.25) / (10.27 - 5.25)
        b5, i5 = _hyp_incr(5.25, a, de, dbf, dsb)
        b10, i10 = _hyp_incr(10.27, a, de, dbf, dsb)
        return [(1 - w) * (b5[j] + i5[j]) + w * (b10[j] + i10[j]) for j in range(3)]
    def sub():
        b, i = _sub_incr(a, de)
        return [b[j] + i[j] for j in range(3)]
    if M >= 5.25: return hyp(M)
    if M <= 0.29: return sub()
    w = (math.log(M) - LOGM_SUB) / (LOGM_HYP - LOGM_SUB)
    h, s = hyp(5.25), sub()
    return [(1 - w) * s[j] + w * h[j] for j in range(3)]

def moment_about(cn, ca, cm, xcg, zcg):
    """Cm about the c.g. from Cm about the MRP (X aft, Z up, inches)."""
    return cm + cn * (xcg - XMRP) / CREF - ca * (ZMRP - zcg) / CREF

def lift_drag(cn, ca, a):
    r = math.radians(a)
    return cn * math.cos(r) - ca * math.sin(r), cn * math.sin(r) + ca * math.cos(r)

# ---------- the OFP level ----------
def _ofp():
    pts = []
    for r in csv.DictReader(open(os.path.join(DATA, 'sts1-entry-ofp.csv'))):
        if not (r['CL'] and r['Mach'] and r['alpha_deg']): continue
        if not (r['elevator_deg'] and r['body_flap_deg'] and r['speedbrake_pct']): continue
        pts.append(dict(M=float(r['Mach']), a=float(r['alpha_deg']), cl=float(r['CL']), cd=float(r['CD']),
                        de=float(r['elevator_deg']), dbf=float(r['body_flap_deg']),
                        dsb=float(r['speedbrake_pct']) * SB_DEG_PER_PCT, t=float(r['t_EI_min'])))
    return sorted(pts, key=lambda p: p['M'])

OFP = _ofp()
OFP_XCG, OFP_ZCG = 1098.6, 374.0       # Table 5.0-I, entry interface

def _calibration():
    """Per OFP point: the CN, CA and CM offsets that make the shape match."""
    cal = []
    for p in OFP:
        cn, ca, cm = shape(p['M'], p['a'], p['de'], p['dbf'], p['dsb'])
        r = math.radians(p['a'])
        cn_t = p['cl'] * math.cos(r) + p['cd'] * math.sin(r)
        ca_t = -p['cl'] * math.sin(r) + p['cd'] * math.cos(r)
        dcn, dca = cn_t - cn, ca_t - ca
        # trim: the offset in CM (about the MRP) that zeroes Cm about the c.g.
        dcm = -moment_about(cn_t, ca_t, cm, OFP_XCG, OFP_ZCG)
        cal.append((math.log(p['M']), dcn, dca, dcm, p))
    return cal

CAL = _calibration()

def _calibrated(M, a, de, dbf, dsb):
    cn, ca, cm = shape(M, a, de, dbf, dsb)
    lm = math.log(max(M, 0.05))
    xs = [c[0] for c in CAL]
    return (cn + _interp_clamped(xs, [c[1] for c in CAL], lm),
            ca + _interp_clamped(xs, [c[2] for c in CAL], lm),
            cm + _interp_clamped(xs, [c[3] for c in CAL], lm))

# ---------- the pitch derivatives, corrected to measurements below Mach 5 ----------
# Between LA66 (M 0.29) and OA98 (M 5.25) the shapes are a log-Mach BLEND, and
# the blend's pitching-moment slopes are wrong where it matters: it made the
# vehicle statically UNSTABLE at Mach 1.3-2 (dCm/dalpha +0.0022..+0.0028/deg
# about Xcg 1098.6), and PASS's pitch loop lost the vehicle at Mach 1.3 on the
# first TAEM flight (2026-10-06).  The orbiter is stable there.  So the SLOPES
# are set to measured values and the level is left alone: the correction is
#   dCM = Ka (alpha - alpha_ref) + Kd (de - de_ref) + Kb (dbf - dbf_ref)
# with K = (measured slope - the blend's own, both about Xcg 1098.6 / Zcg 374)
# and the references the STS-1 OFP trim condition at that Mach -- so at every
# OFP point the correction is ZERO and the calibration (level and trim) holds.
# Faded out from Mach 4 to 5.25, where OA98 is data.  Sources, digitized with
# pages and uncertainties in aero-docs/transonic-findings.md:
#   Cm_alpha  NASA TM X-72661 Vols II (Langley 8-ft, M .35-1.2) and IX (UPWT,
#             M 1.5-2.5); Young & Underwood 1985 fig 36 (the data book's
#             subsonic neutral point, ~Xo 1077); flight: Iliff & Shafer
#             TM-4500 fig 19 (-0.0035 M 1.4, -0.0027 M 1.7, -0.0016 M 2-4).
#             M 1.5-1.7 here are between the tunnel and flight values.
#   Cm_de     the same tunnel volumes (trailing edge up), TP-1779 at M .35,
#             TM-4500 (-0.0022..-0.0027 at M 3-5).
#   Cm_dbf    TM X-72661 Vol II, M .35-1.2 only; above that blended to OA98's.
STAB_XCG, STAB_ZCG = 1098.6, 374.0
CMA_TARGET = [(0.29, 0.0024), (0.35, 0.0024), (0.6, 0.0012), (0.8, 0.0), (0.95, -0.004),
              (1.2, -0.006), (1.5, -0.0045), (1.7, -0.003), (2.0, -0.002), (2.5, -0.0016),
              (4.0, -0.0016)]
CMDE_TARGET = [(0.29, -0.0085), (0.35, -0.0085), (0.8, -0.0078), (1.0, -0.007), (1.2, -0.007),
               (1.5, -0.0043), (2.0, -0.0034), (2.5, -0.0025), (4.0, -0.0023)]
CMBF_TARGET = [(0.29, -0.0018), (0.8, -0.0018), (0.9, -0.0014), (1.2, -0.0014)]
STAB_FADE = (4.0, 5.25)

def _lin_logm(pts, M):
    return _interp_clamped([math.log(m) for m, v in pts], [v for m, v in pts], math.log(M))

def _ofp_ref(M):
    """The STS-1 trim condition at Mach M: alpha, elevon, body flap, speedbrake."""
    pts = OFP
    xs = [math.log(p['M']) for p in pts]
    g = lambda k: _interp_clamped(xs, [p[k] for p in pts], math.log(M))
    return g('a'), g('de'), g('dbf'), g('dsb')

def _cm_cg(M, a, de, dbf, dsb):
    cn, ca, cm = _calibrated(M, a, de, dbf, dsb)
    return moment_about(cn, ca, cm, STAB_XCG, STAB_ZCG)

_STAB_CACHE = {}
def _stab_gains(M):
    """(weight, Ka, Kd, Kb): measured minus the blend's slopes at Mach M."""
    key = round(M, 4)
    if key in _STAB_CACHE:
        return _STAB_CACHE[key]
    if M >= STAB_FADE[1]:
        out = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    else:
        w = 1.0 if M <= STAB_FADE[0] else \
            (math.log(STAB_FADE[1]) - math.log(M)) / (math.log(STAB_FADE[1]) - math.log(STAB_FADE[0]))
        a0, de0, bf0, sb0 = _ofp_ref(M)
        base = _cm_cg(M, a0, de0, bf0, sb0)
        ka_m = (_cm_cg(M, a0 + 1, de0, bf0, sb0) - base)
        kd_m = (_cm_cg(M, a0, de0 - 1, bf0, sb0) - base) * -1.0      # trailing edge up, as measured
        kb_m = (_cm_cg(M, a0, de0, bf0 + 1, sb0) - base)
        kb_hyp = (_cm_cg(STAB_FADE[1], *(lambda r: (r[0], r[1], r[2] + 1, r[3]))(_ofp_ref(STAB_FADE[1])))
                  - _cm_cg(STAB_FADE[1], *_ofp_ref(STAB_FADE[1])))
        kb_t = _lin_logm(CMBF_TARGET + [(STAB_FADE[1], kb_hyp)], M)
        out = (w, _lin_logm(CMA_TARGET, M) - ka_m, _lin_logm(CMDE_TARGET, M) - kd_m, kb_t - kb_m,
               a0, de0, bf0)
    _STAB_CACHE[key] = out
    return out

def coeffs(M, a, de, dbf, dsb):
    """CN, CA, CM (about the MRP) at Mach M, alpha a, deflections in degrees."""
    cn, ca, cm = _calibrated(M, a, de, dbf, dsb)
    w, ka, kd, kb, a0, de0, bf0 = _stab_gains(M)
    if w:
        cm += w * (ka * (a - a0) + kd * (de - de0) + kb * (dbf - bf0))
    return cn, ca, cm

def _interp_clamped(xs, ys, x):
    if x <= xs[0]: return ys[0]
    if x >= xs[-1]: return ys[-1]
    return _interp(xs, ys, x)

# ---------- lateral-directional (per degree, body axes, Cl Cn on qSb) ----------
# Against Mach along the trim alpha schedule, about the MRP (TP-1011's c.g.
# is 65% of the fuselage reference length, Xo 1076.7 -- the same point).
#   M >= 1.3   NASA TP-1011 fig 4 (Stone & Powell 1977, June 1974 data set)
#   M 0.5      the data book lines TP-1779 figs 6-7 reproduce, at alpha 6
#   rudder     TP-1011 only gives M 1.2-4.05: held below and above that range
#              (FLAGGED: no subsonic rudder source yet)
# Damping (per radian, on qcbar/2V and pb/2V, rb/2V): TP-1634 figs 4-8,
# the data book line at M 0.4, against alpha 0-18 and held beyond; used at
# every Mach (FLAGGED: no supersonic or hypersonic source).
LAT_KEYS = ['Cy_beta', 'Cn_beta', 'Cl_beta', 'Cy_da', 'Cn_da', 'Cl_da', 'Cy_dr', 'Cn_dr', 'Cl_dr']
SUBSONIC_M05 = dict(Cy_beta=-0.0179, Cn_beta=0.00151, Cl_beta=-0.00172,
                    Cy_da=-0.00396, Cn_da=0.00076, Cl_da=0.00398)     # TP-1779 data book, M 0.4, alpha 6

def _csv_rows(name):
    return list(csv.DictReader(l for l in open(os.path.join(DATA, name)) if not l.startswith('#')))

def lateral_table():
    rows = [r for r in _csv_rows('tp1011-lat.csv') if float(r['Mach']) >= 1.3]
    ms = [0.5] + [float(r['Mach']) for r in rows]
    out = {}
    for k in LAT_KEYS:
        pts = [(0.5, SUBSONIC_M05[k])] if k in SUBSONIC_M05 else []
        pts += [(float(r['Mach']), float(r[k])) for r in rows if r[k]]
        xs = [math.log(m) for m, v in pts]; ys = [v for m, v in pts]
        out[k] = [_interp_clamped(xs, ys, math.log(m)) for m in ms]
    return ms, out

def damping_table():
    want = {'Cmq': 'Cmq+Cmalphadot', 'Clp': 'Clp (flt)', 'Clr': 'Clr-Clbetadot', 'Cnp': 'Cnp (flt)', 'Cnr': 'Cnr-Cnbetadot'}
    rows = [r for r in _csv_rows('tp1634-dyn.csv') if r['source'].startswith('Ref.9') and r['Mach'] == '0.4']
    alphas = [float(a) for a in range(0, 19, 2)]
    out = {}
    for k, pre in want.items():
        pts = sorted((float(r['alpha_deg']), float(r['value_per_rad'])) for r in rows if r['parameter'].startswith(pre))
        out[k] = [_interp_clamped([a for a, v in pts], [v for a, v in pts], a) for a in alphas]
    return alphas, out

# ---------- src/entryaero.h ----------
# Mach breakpoints include every OFP calibration Mach and both tunnel Machs,
# so interpolating in log Mach between them reproduces coeffs() exactly
# (the model is piecewise linear in log Mach there); 5.25-10.27, linear in
# Mach in the model, is sampled finely enough not to matter.
H_MACH = sorted(set([0.29, 0.4, 0.5] + [round(p['M'], 3) for p in OFP] +
                    [5.25, 6.5, 8.5, 10.27, 30.0]))
H_ALPHA = [float(a) for a in range(-4, 47, 2)]
H_DE = [-40.0, -30.0, -20.0, -10.0, -5.0, 0.0, 5.0, 10.0, 15.0, 20.0]
H_DBF = [-11.7, 0.0, 8.0, 16.3, 22.5]
H_DSB = [0.0, 25.0, 55.0, 85.0, 98.6]

def write_header(path):
    def arr(name, xs):
        return 'static const double %s[%d] = {\n    %s };\n' % (
            name, len(xs), ',\n    '.join(', '.join('%.6g' % x for x in xs[i:i + 8]) for i in range(0, len(xs), 8)))
    def table(name, f):
        rows = []
        for M in H_MACH:
            for a in H_ALPHA:
                rows.append(f(M, a))
        n = len(rows[0])
        out = 'static const float %s[%d][%d][%d][3] = {\n' % (name, len(H_MACH), len(H_ALPHA), n)
        i = 0
        for M in H_MACH:
            out += '  { /* M %.3f */\n' % M
            for a in H_ALPHA:
                out += '    { ' + ', '.join('{ %.5f, %.5f, %.5f }' % tuple(c) for c in rows[i]) + ' },\n'
                i += 1
            out += '  },\n'
        return out + '};\n'
    base = lambda M, a: [coeffs(M, a, 0.0, 0.0, 0.0)]
    def incr(grid, which):
        def f(M, a):
            b = coeffs(M, a, 0.0, 0.0, 0.0)
            out = []
            for d in grid:
                args = [0.0, 0.0, 0.0]; args[which] = d
                c = coeffs(M, a, *args)
                out.append([c[j] - b[j] for j in range(3)])
            return out
        return f
    with open(path, 'w') as fp:
        fp.write('/* THE ORBITER\'S LONGITUDINAL ENTRY AERODYNAMICS for src/vehdyn.c.\n'
                 ' * GENERATED by tools/entryaero.py --header from tools/aero/ (OA98, LA66,\n'
                 ' * the STS-1 descent OFP) -- do not edit; see that file for the method.\n'
                 ' * Body-axis CN, CA and CM about the MRP X 1076.7 / Z 375.0 in, on\n'
                 ' * S 2690 ft^2 and c 474.8 in.  BASE is every surface at 0 (speedbrake\n'
                 ' * closed); D_* are increments from BASE, one surface moved, superposed.\n'
                 ' * Index [Mach][alpha][deflection][CN CA CM]; Mach in log, the rest\n'
                 ' * linear; degrees, elevon and body flap trailing edge down. */\n')
        fp.write(arr('EA_MACH', H_MACH) + arr('EA_ALPHA', H_ALPHA) + arr('EA_DE', H_DE)
                 + arr('EA_DBF', H_DBF) + arr('EA_DSB', H_DSB))
        fp.write(table('EA_BASE', base))
        fp.write(table('EA_D_ELEVON', incr(H_DE, 0)))
        fp.write(table('EA_D_BODYFLAP', incr(H_DBF, 1)))
        fp.write(table('EA_D_SPEEDBRAKE', incr(H_DSB, 2)))
        ms, lt = lateral_table()
        fp.write('/* Lateral-directional, per degree, against EA_LAT_MACH (log): ' + ' '.join(LAT_KEYS) + ' */\n')
        fp.write(arr('EA_LAT_MACH', ms))
        fp.write('static const double EA_LAT[%d][%d] = {\n' % (len(ms), len(LAT_KEYS)))
        for i in range(len(ms)):
            fp.write('    { ' + ', '.join('%.6f' % lt[k][i] for k in LAT_KEYS) + ' },\n')
        fp.write('};\n')
        al, dt = damping_table()
        fp.write('/* Damping, per radian, against EA_DAMP_ALPHA: Cmq Clp Clr Cnp Cnr */\n')
        fp.write(arr('EA_DAMP_ALPHA', al))
        fp.write('static const double EA_DAMP[%d][5] = {\n' % len(al))
        for i in range(len(al)):
            fp.write('    { ' + ', '.join('%.4f' % dt[k][i] for k in ('Cmq', 'Clp', 'Clr', 'Cnp', 'Cnr')) + ' },\n')
        fp.write('};\n')

if __name__ == '__main__':
    import sys
    if '--header' in sys.argv:
        out = os.path.join(os.path.dirname(HERE), 'src', 'entryaero.h')
        write_header(out)
        print('wrote', out)
        sys.exit(0)
    print('OFP calibration points (offsets the tunnel shapes need to reach the OFP level):')
    print('  t   Mach  alpha   de    dbf   dsb |  dCN     dCA     dCM')
    for lm, dcn, dca, dcm, p in CAL:
        print('%4.0f %6.2f %5.1f %5.1f %5.1f %5.1f | %+.4f %+.4f %+.4f' %
              (p['t'], p['M'], p['a'], p['de'], p['dbf'], p['dsb'], dcn, dca, dcm))
