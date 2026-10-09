"""PAMS-STU, the Passive Aerodynamically-stabilised Magnetically-damped
Satellite's Satellite Test Unit (NORAD 23876), as STS-77 met it in May
1996: ejected from a Hitchhiker canister in the payload bay (TEAMS), it
was the target of Endeavour's rendezvous and station-keeping 2,000-2,300
ft behind it on three later days, the crew and cameras judging its
coning by eye (its own attitude sensor failed).

A cylinder about 0.6 m across and 0.9 m long (NASA's "2 x 3 ft"; 35-49
kg), weighted at one end so the drag would point it like a dart, two
magnetic rods inside to damp the wobble.  From the three Electronic Still
Camera frames of its ejection, S77-E-5067, -5068 and -5069 (GSFC/JSC,
images.nasa.gov), which agree with each other:

* proportions: length 1.5 x the diameter in all three (so the 2 x 3 ft);
* white paint; a red band 0.08 m wide round one end; a bare-aluminium
  band 0.10 m wide round the other, whose end face is recessed inside a
  light lip (the ejection interface: concentric rings, a central plate);
* black bars ~0.037 m wide along the length, 45 deg apart: on the
  photographed side one full-length bar with a short white break 82% of
  the way from the red band, one bar from the red band 60% of the way
  down 50 deg to one side, and on the other side 45 deg away two
  segments (0-35% and 73-100%) -- the crew's attitude code.  The far
  side never faced the camera: its three bars here are a guess, a
  different code in the same style.

Which end carried the ballast is not stated anywhere found; the red band
is assumed to mark it (the "nose").
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'pams_stu'

R, L = 0.30, 0.90
RED_W, AL_W = 0.08, 0.10
BAR_W = 0.037


def _paint():
    """White with the black bars and the red band at the +X end, the
    aluminium band at -X (u along X, 0..1 the length; v round, 0..1 a turn
    from +Y toward +Z)."""
    from PIL import Image
    h, w = 512, 256                       # rows v (round), columns u (along)
    a = np.ones((h, w, 3)) * 0.97
    v = ((np.arange(h) + 0.5) / h)[:, None] * np.ones((1, w))
    u = ((np.arange(w) + 0.5) / w)[None, :] * np.ones((h, 1))
    u_red = 1 - RED_W / L
    u_al = AL_W / L
    span = u_red - u_al

    def frac(f):                           # fraction down from the red band -> u
        return u_red - f * span
    def bar(lon, f0, f1):
        c = lon / 360.0
        dv = np.abs(((v - c) + 0.5) % 1.0 - 0.5)
        m = (dv < BAR_W / (2 * math.pi * R) / 2) & (u <= frac(f0)) & (u >= frac(f1))
        a[m] = 0.035
    # the photographed side (S77-E-5067/5068/5069)
    bar(0, 0.0, 1.0)
    a[(np.abs(((v - 0.0) + 0.5) % 1.0 - 0.5) < BAR_W / (2 * math.pi * R) / 2) &
      (np.abs(u - frac(0.82)) < 0.012 / L)] = 0.97
    bar(50, 0.0, 0.60)
    bar(-45, 0.0, 0.35)
    bar(-45, 0.73, 1.0)
    # the far side: a guess in the same style
    bar(135, 0.40, 1.0)
    bar(180, 0.0, 1.0)
    a[(np.abs(((v - 0.5) + 0.5) % 1.0 - 0.5) < BAR_W / (2 * math.pi * R) / 2) &
      (np.abs(u - frac(0.18)) < 0.012 / L)] = 0.97
    bar(225, 0.0, 0.27)
    bar(225, 0.65, 1.0)
    a[u > u_red] = (0.62, 0.05, 0.05)
    a[u < u_al] = (0.62, 0.62, 0.64)
    return Image.fromarray((np.clip(a, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))


def build(kit):
    p = []
    body = kit.cylinder(R, -L / 2, L / 2, n=48, caps=False)
    m, uv = U.cyl_uv(body, tile_x=L, n_round=1.0)
    uv[:, 0] = uv[:, 0] + 0.5                 # u 0..1 from the -X end
    part = kit.part("body (white, black bars, red and aluminium bands)", (0.80, 0.80, 0.78), m,
                    texture=_paint(), uv=uv)
    q = np.asarray(m[0], float).copy()
    q[:, 0] = 0.0
    part['nrm'] = q / np.maximum(np.linalg.norm(q, axis=1, keepdims=True), 1e-12)
    p.append(part)
    # the red-banded end's face, a little in from the rim
    p.append(kit.part("red end face", (0.62, 0.62, 0.62), kit.disc(R - 0.004, L / 2 - 0.006, n=48),
                      kit.tube(R, R - 0.02, L / 2 - 0.006, L / 2, n=48)))
    # the aluminium end: a recessed face inside a light lip, concentric
    # rings and the central plate (the ejection interface)
    p.append(kit.part("aft annulus", (0.50, 0.50, 0.52),
                      U.facing_aft(kit, kit.disc(R - 0.004, 0.0, n=48, r_in=0.25), -L / 2 + 0.004)))
    p.append(kit.part("ejection lip", (0.78, 0.78, 0.76), kit.tube(0.255, 0.235, -L / 2 - 0.035, -L / 2 + 0.01, n=48)))
    p.append(kit.part("recessed end face", (0.30, 0.30, 0.31),
                      U.facing_aft(kit, kit.disc(0.236, 0.0, n=48, r_in=0.15), -L / 2 + 0.025)))
    p.append(kit.part("interface rings", (0.55, 0.55, 0.57), kit.tube(0.16, 0.145, -L / 2 - 0.01, -L / 2 + 0.03, n=40),
                      kit.cylinder(0.10, -L / 2 - 0.005, -L / 2 + 0.03, n=32)))
    p.append(kit.part("interface gap", (0.08, 0.08, 0.09),
                      U.facing_aft(kit, kit.disc(0.145, 0.0, n=40, r_in=0.10), -L / 2 + 0.02)))
    return dict(meta=dict(name="PAMS-STU (STS-77)",
                          frame="PAMS-STU: +X along the axis toward the red-banded end (assumed the "
                                "weighted forward end), -X the aluminium-banded ejection interface, +Y "
                                "the full-length bar's side; m; the cylinder's middle (the ballast puts "
                                "the true centre of mass somewhat toward one end)",
                          source="simple shapes to NASA's description and the STS-77 ESC frames "
                                 "S77-E-5067/5068/5069",
                          norad=23876, mag_1000km=7.0),
                parts=U.refine_parts(p))
