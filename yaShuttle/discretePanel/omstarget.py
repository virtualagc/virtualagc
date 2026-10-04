#!/usr/bin/env python3
"""OMS TARGETS: what orbit an OMS burn's PEG 4 targets give, and the targets
for a wanted orbit -- the flight designer's job for OMS 1 and OMS 2.

    python3 omstarget.py orbit  STATE.json HT THETA C1 C2
    python3 omstarget.py design STATE.json HP HA [--thetat DEG]

STATE.json: {"tig_state": {"r": [x,y,z], "v": [vx,vy,vz]},     M50 ft, ft/s
             "r_liftoff": [x,y,z]}         the launch site at liftoff, M50 ft
-- the vehicle at the burn's TIG (coasted to it) and CGGV_M50_R_LIFTOFF.

PASS's OWN EQUATIONS, ported:
  - the target position (GGOTGT.hal, GGO_TGT_POS): THETA is the central angle
    from the launch site at liftoff, measured in the vehicle's present orbit
    plane, to the target; HT its height in nmi above the mean equatorial
    radius;
  - the velocity wanted now (GGILTV.hal, steps 21-27, the linear terminal
    velocity constraint): the conic through here and the target whose
    velocity there satisfies C1 (ft/s) and C2.
An impulsive burn: the orbit is the one that velocity gives.  The real burn
takes minutes and PEG closes the loop on it, so expect small differences.

'design' looks for an apsis target (C1 = C2 = 0) half an orbit on, or at
--thetat, giving perigee HP and apogee HA (nmi above the mean equatorial
radius, as PASS displays HA and HP).
"""
import argparse
import json
import math

MU = 1.4076539e16          # CGNS_EARTH_MU, ft^3/s^2
RE = 20925646.3255         # CGNS_EARTH_EQU_RADIUS_D, ft
NMI = 6076.11549           # ft (CGIK_CNMFS)


def dot(a, b): return sum(x * y for x, y in zip(a, b))
def cross(a, b): return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]
def norm(a): return math.sqrt(dot(a, a))
def unit(a): n = norm(a); return [x / n for x in a]
def scale(k, a): return [k * x for x in a]
def add(a, b): return [x + y for x, y in zip(a, b)]


def target_position(ht, theta, rgd, vgd, rls):
    """GGO_TGT_POS: RT, and the central angle from here to it (deg)."""
    idr = unit(cross(rgd, cross(vgd, rgd)))
    ir = unit(rgd)
    theta_ls = math.degrees(math.atan2(-dot(rls, idr), dot(rls, ir)))
    if theta_ls < 0.0:
        theta_ls += 360.0
    d = math.radians(theta - theta_ls)
    rt = add(scale(math.cos(d), ir), scale(math.sin(d), idr))
    return scale(RE + ht * NMI, rt), math.degrees(d)


def ltvc(rd, r1, iy, c1, c2):
    """GGI_LTVC_PEG steps 21-27: the velocity wanted at RD."""
    r0, r1m = norm(rd), norm(r1)
    k = (r1m - r0) / r0
    w = r0 * r1m - dot(rd, r1)
    w = -dot(cross(rd, r1), iy) / w
    a = k * (1 + w * w) + 2.0 * (1.0 - c2 * w)
    b = c1 * w
    c = 2.0 * MU / r1m
    vh1 = c / (math.sqrt(b * b + a * c) - b)
    return scale(1.0 / r0, add(scale(vh1 * (k * w - c2) - c1, rd),
                               scale((1.0 + k) * vh1, cross(rd, iy))))


def apsides(r, v):
    """Perigee and apogee, nmi above the mean equatorial radius."""
    rm, vm = norm(r), norm(v)
    a = 1.0 / (2.0 / rm - vm * vm / MU)
    h = norm(cross(r, v))
    e = math.sqrt(max(0.0, 1.0 - h * h / (MU * a)))
    return (a * (1 - e) - RE) / NMI, (a * (1 + e) - RE) / NMI


def burn(state, ht, theta, c1, c2):
    r, v = state["tig_state"]["r"], state["tig_state"]["v"]
    iy = unit(cross(v, r))                       # in plane: IY = V x R
    rt, ang = target_position(ht, theta, r, v, state["r_liftoff"])
    vd = ltvc(r, rt, iy, c1, c2)
    dv = norm([a - b for a, b in zip(vd, v)])
    return apsides(r, vd), dv, ang


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    o = sub.add_parser("orbit")
    o.add_argument("state")
    o.add_argument("ht", type=float)
    o.add_argument("theta", type=float)
    o.add_argument("c1", type=float)
    o.add_argument("c2", type=float)
    d = sub.add_parser("design")
    d.add_argument("state")
    d.add_argument("hp", type=float)
    d.add_argument("ha", type=float)
    d.add_argument("--thetat", type=float)
    a = ap.parse_args()
    with open(a.state) as fh:
        st = json.load(fh)
    r, v = st["tig_state"]["r"], st["tig_state"]["v"]
    print("before: HP %.1f HA %.1f nmi" % apsides(r, v))
    if a.cmd == "orbit":
        (hp, ha), dv, ang = burn(st, a.ht, a.theta, a.c1, a.c2)
        print("after:  HP %.1f HA %.1f nmi, dV %.1f ft/s, target %.1f deg ahead" % (hp, ha, dv, ang))
        return
    # here to the launch site's angle: the target half an orbit on, by default
    _, here = target_position(0.0, 0.0, r, v, st["r_liftoff"])
    theta = a.thetat if a.thetat is not None else (-here + 180.0) % 360.0
    best = None
    for ht in [a.ha + 0.1 * i for i in range(-300, 301)]:
        (hp, ha), dv, ang = burn(st, ht, theta, 0.0, 0.0)
        err = (hp - a.hp) ** 2 + (ha - a.ha) ** 2
        if best is None or err < best[0]:
            best = (err, ht, hp, ha, dv)
    _, ht, hp, ha, dv = best
    print("HT %.1f  THETA T %.1f  C1 0  C2 0  ->  HP %.1f HA %.1f nmi, dV %.1f ft/s"
          % (ht, theta, hp, ha, dv))


if __name__ == "__main__":
    main()
