"""PAMS-STU, the Passive Aerodynamically-stabilised Magnetically-damped
Satellite's Satellite Test Unit (NORAD 23876), as STS-77 met it in May
1996: released from a canister in the payload bay, it was the target of
four rendezvous by Endeavour (tests of rendezvous techniques for later
missions) while the crew judged its coning by eye.

A cylinder about 0.6 m across and 0.9 m long (NASA's "2 x 3 ft"; 35-49
kg), weighted at one end so the drag would point it like a dart, two
magnetic rods inside to damp the wobble; painted white with black bars
(for the crew's and cameras' attitude estimates) and a red band round the
heavy forward end.  From s77e5067-5069.
"""
import numpy as np

from . import _leo_util as U

KEY = 'pams_stu'

R, L = 0.30, 0.90


def _stripes():
    """White with black bars and a red band at the +X end (u along X, 0..1
    the length; v round, 0..1 a turn)."""
    from PIL import Image
    h, w = 256, 128                       # rows v (round), columns u (along)
    a = np.ones((h, w, 3))
    v = (np.arange(h) / h)[:, None]
    u = (np.arange(w) / w)[None, :]
    # four black bars round, each a quarter of the way, from aft to 80%;
    # a short cross-bar on alternate ones
    for k in range(4):
        c = k / 4 + 0.08
        bar = (np.abs(((v - c + 0.5) % 1.0) - 0.5) < 0.035) & (u > 0.10) & (u < 0.82)
        a[np.broadcast_to(bar, (h, w))] = 0.04
        if k % 2 == 0:
            cross = (np.abs(((v - c - 0.06 + 0.5) % 1.0) - 0.5) < 0.06) & (np.abs(u - 0.45) < 0.04)
            a[np.broadcast_to(cross, (h, w))] = 0.04
    red = np.broadcast_to(u > 0.88, (h, w))
    a[red] = (0.75, 0.06, 0.05)
    return Image.fromarray((a ** (1 / 2.2) * 255).astype(np.uint8))


def build(kit):
    p = []
    body = kit.cylinder(R, -L / 2, L / 2, n=32, caps=False)
    m, uv = U.cyl_uv(body, tile_x=L, n_round=1.0)
    uv[:, 0] = uv[:, 0] + 0.5                 # u 0..1 from the aft end
    part = kit.part("body (white, black bars, red band)", (0.80, 0.80, 0.78), m, texture=_stripes(), uv=uv)
    q = np.asarray(m[0], float).copy()
    q[:, 0] = 0.0
    part['nrm'] = q / np.maximum(np.linalg.norm(q, axis=1, keepdims=True), 1e-12)
    p.append(part)
    p.append(kit.part("forward end (red)", (0.70, 0.07, 0.05), kit.disc(R, L / 2, n=32)))
    p.append(kit.part("aft end", (0.55, 0.55, 0.56), U.facing_aft(kit, kit.disc(R, 0.0, n=32), -L / 2)))
    p.append(kit.part("aft fitting", (0.35, 0.35, 0.36), kit.cylinder(0.12, -L / 2 - 0.06, -L / 2 - 0.005, n=16)))
    return dict(meta=dict(name="PAMS-STU (STS-77)",
                          frame="PAMS-STU: +X along the axis toward the weighted (red-banded) "
                                "forward end, +Y, +Z; m; the cylinder's middle (the ballast puts "
                                "the true centre of mass somewhat forward of it)",
                          source="simple shapes to NASA's description and STS-77 photographs",
                          norad=23876, mag_1000km=7.0),
                parts=U.refine_parts(p))
