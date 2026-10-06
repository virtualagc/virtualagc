#!/usr/bin/env python3
"""tools/entryaero.py -- the orbiter's longitudinal entry aerodynamics, built from
primary sources.  `python3 tools/entryaero.py --header` writes src/entryaero.h
(the tables vehdyn interpolates); with no argument it prints the OFP
calibration.  Data in tools/aero/: oa98-final.csv (CR-141550 appendix, read
from the scans and proofread), la66-run{1,2,3}.txt (CR-147621 runs 1-3),
sts1-entry-ofp.csv (JSC-14483 Vol. 5, digitized).

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

def coeffs(M, a, de, dbf, dsb):
    """CN, CA, CM (about the MRP) at Mach M, alpha a, deflections in degrees."""
    cn, ca, cm = shape(M, a, de, dbf, dsb)
    lm = math.log(max(M, 0.05))
    xs = [c[0] for c in CAL]
    return (cn + _interp_clamped(xs, [c[1] for c in CAL], lm),
            ca + _interp_clamped(xs, [c[2] for c in CAL], lm),
            cm + _interp_clamped(xs, [c[3] for c in CAL], lm))

def _interp_clamped(xs, ys, x):
    if x <= xs[0]: return ys[0]
    if x >= xs[-1]: return ys[-1]
    return _interp(xs, ys, x)

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
