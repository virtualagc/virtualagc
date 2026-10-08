"""The Tethered Satellite System's satellite on its reflight, TSS-1R (NORAD
23805), STS-75, February 1996: reeled out above Columbia on its
conducting tether to 19.7 km, when the tether burned through near the
deployer; the satellite, trailing the tether, rose away and was never met
again (it re-entered in March).  The same satellite flew tethered on
STS-46 (TSS-1, 1992; reel jammed at 256 m; not catalogued).

The satellite (Alenia, for ASI/NASA): a 1.6 m sphere, 518 kg, light grey
painted panels with dark seams; on top the tripod and tether attachment
mast, two short instrument booms at the equator, and below the interface
ring that seated it on the deployer's boom.  The tether itself (2.5 mm
across, 19.7 km long) is not modelled -- it is far below a pixel.
From the STS-75 photograph 9612176.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'tss1r'

R = 0.80


def _seams():
    """Light grey with dark seams: eight gores and three latitude bands
    (u round, v pole to pole)."""
    from PIL import Image
    h, w = 128, 256
    v = (np.arange(h) / h)[:, None] * np.ones((1, w))
    u = (np.arange(w) / w)[None, :] * np.ones((h, 1))
    a = np.ones((h, w))
    a[(np.abs((u * 8) % 1 - 0.5) > 0.485)] = 0.25
    for lat in (0.30, 0.5, 0.70):
        a[np.abs(v - lat) < 0.008] = 0.25
    rgb = np.stack([a] * 3, -1)
    return Image.fromarray((rgb ** (1 / 2.2) * 255).astype(np.uint8))


def build(kit):
    p = []
    sph = kit.sphere(R, n=24)
    pts, tris = U.unshare(sph)
    # uv: u the longitude round X (the tether axis), v from +X pole to -X
    ang = (np.arctan2(pts[:, 2], pts[:, 1]) / (2 * math.pi)) % 1.0
    t = np.asarray(tris)
    tri = ang[t]
    for i in np.where(tri.max(1) - tri.min(1) > 0.5)[0]:
        for c in range(3):
            if tri[i, c] < 0.5:
                ang[t[i, c]] += 1.0
    vv = np.arccos(np.clip(pts[:, 0] / R, -1, 1)) / math.pi
    uv = np.column_stack([ang, vv]).astype(np.float32)
    part = kit.part("sphere (painted panels)", (0.70, 0.71, 0.73), (pts, tris), texture=_seams(), uv=uv)
    part['nrm'] = pts / np.linalg.norm(pts, axis=1, keepdims=True)
    p.append(part)
    # the tether tripod and mast on top (+X)
    apex = np.array([R + 0.55, 0.0, 0.0])
    legs = []
    for k in range(3):
        a = 2 * math.pi * k / 3
        base = np.array([R * 0.80, R * 0.6 * math.cos(a), R * 0.6 * math.sin(a)])
        legs.append(kit.rod(base, apex, 0.02, n=6))
    legs.append(kit.rod((R - 0.02, 0, 0), apex, 0.035, n=8))
    p.append(kit.part("tether tripod and mast", (0.75, 0.75, 0.75), *legs))
    p.append(kit.part("tether attachment", (0.45, 0.45, 0.46), kit.cylinder(0.06, R + 0.50, R + 0.62, n=12)))
    # instrument booms at the equator
    bo = [kit.rod((0.05, s * R * 0.98, 0.0), (0.05, s * (R + 0.30), 0.0), 0.015, n=6) for s in (-1, 1)]
    p.append(kit.part("instrument booms", (0.75, 0.75, 0.75), *bo,
                      kit.box((0.06, 0.06, 0.10), (0.05, R + 0.32, 0.0)),
                      kit.box((0.06, 0.06, 0.10), (0.05, -R - 0.32, 0.0))))
    # the deployer interface below (-X): a copper-blanketed ring
    p.append(kit.part("interface ring", (0.58, 0.34, 0.14), kit.cylinder(0.32, -R - 0.12, -R + 0.10, n=24)))
    p.append(kit.part("thruster pods", (0.30, 0.30, 0.31),
                      *[kit.box((0.10, 0.10, 0.10), (-0.1, R * 0.97 * math.cos(a), R * 0.97 * math.sin(a)))
                        for a in (math.pi / 4, 3 * math.pi / 4, 5 * math.pi / 4, 7 * math.pi / 4)]))
    return dict(meta=dict(name="TSS-1R tethered satellite (STS-75)",
                          frame="TSS: +X up the tether mast (toward where the tether led), +Y "
                                "along the instrument booms, +Z; m; the sphere's centre",
                          source="simple shapes to published dimensions and the STS-75 photograph",
                          norad=23805, mag_1000km=4.0),
                parts=U.refine_parts(p))
