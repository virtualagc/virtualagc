"""The Inflatable Antenna Experiment (L'Garde / JPL, STS-77, May 1996),
flown on Spartan 207: a 14 m off-axis reflector (f/D 0.5) of aluminised
Mylar, a lenticular envelope whose front canopy (62 gores of clear Mylar)
faced the canister, held in an inflated torus 0.61 m thick, on three
inflated struts 0.46 m thick (neoprene-coated Kevlar under aluminised wrap)
running back to the canister on the Spartan's +X end.  Inflated beside
Endeavour for about 90 minutes, then jettisoned (it re-entered within
days); the Spartan was retrieved.  Dimensions: eoPortal (from L'Garde).

The geometry measured off the STS-77 photographs: from the side (s77e5025,
77iaeinflight) the reflector's rim stands ~24.5 m along its axis from the
canister, the struts meeting the torus at two points 55 degrees either side
of the canister's side and one diametrically opposite (it crosses in front
of the dish); seen along the axis (s77e5027, feature.jpg, Inflatable_
Antenna_Experiment.jpg) the canister lies ~10 m off the axis, just outside
the rim -- the offset feed geometry.  So the near struts are ~26 m long and
the far one ~30 m.  The reflector bows ~1.4 m away from the canister."""
import math

import numpy as np

from . import _leo_util as U

SILVER = (0.72, 0.73, 0.76)       # the reflector seen through the clear canopy: aluminised Mylar
TORUS = (0.70, 0.70, 0.72)        # crinkled aluminised wrap
STRUT = (0.62, 0.62, 0.64)
RIM = 7.0
SAG = 1.4
AXIAL, OFFSET = 24.5, 10.0
AXIS = np.array([1.0, 0.0, 0.0])          # the rim's normal, from the canister's side
OFFSET_DIR = np.array([0.0, 0.0, -1.0])   # from the canister's foot on the rim plane to the rim's centre
CENTRE = AXIAL * AXIS + OFFSET * OFFSET_DIR   # the rim's centre, from the struts' root
ATTACH_DEG = (55.0, -55.0, 180.0)          # the struts' feet, from the canister's side of the rim


def _rim_basis():
    u = -OFFSET_DIR                      # toward the canister's side of the rim
    w = np.cross(AXIS, u)
    return u, w


def rim_point(deg):
    u, w = _rim_basis()
    t = math.radians(deg)
    return CENTRE + RIM * (math.cos(t) * u + math.sin(t) * w)


_TEX = {}


def tex_gores(n_gores=62, w=1024, h=256, seed=91):
    """The reflector through its canopy (s77e5027, feature.jpg): a mirror
    film crinkled into a glitter of small facets, the gore seams running
    out from the centre.  u round the dish (one gore per 1/n), v out to the
    rim."""
    key = ('gores', n_gores, w, h, seed)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    g = np.random.default_rng(seed)
    a = U._blur(g.standard_normal((h, w)), 2) * 2.2 + U._blur(g.standard_normal((h, w)), 8) * 5.0
    a = (a - a.min()) / (a.max() - a.min())
    v = 0.74 + 0.50 * (a - 0.5)
    v += (g.random((h, w)) > 0.995) * 0.6                   # glints
    xx = np.arange(w)[None, :]
    seam = (xx % (w // 16)) < 2
    v = np.where(seam, v * 0.72, v)
    v = np.clip(v, 0, 1)
    im = Image.fromarray((v ** (1 / 2.2) * 255).astype(np.uint8)).convert("RGB")
    _TEX[key] = im
    return im


def _dish(kit, n_ang=96, n_rad=14):
    """The reflector: a paraboloidal cap on the rim, bowed SAG away from the
    canister, uv polar (u round, v out)."""
    u, w = _rim_basis()
    pts, uv = [], []
    for i in range(n_rad + 1):
        r = RIM * i / n_rad
        for j in range(n_ang + 1):
            t = 2 * math.pi * j / n_ang
            depth = SAG * (1.0 - (r / RIM) ** 2)
            pts.append(CENTRE + r * (math.cos(t) * u + math.sin(t) * w) + depth * AXIS)
            uv.append((16.0 * j / n_ang, r / RIM))
    tris = []
    m = n_ang + 1
    for i in range(n_rad):
        for j in range(n_ang):
            a0, a1, b0, b1 = i * m + j, i * m + j + 1, (i + 1) * m + j, (i + 1) * m + j + 1
            if i > 0:
                tris.append((a0, b0, b1))
            tris.append((a0, b1, a1) if i > 0 else (a0, b0, b1))
    return np.asarray(pts, float), np.asarray(tris, int), np.asarray(uv, np.float32)


def strut_roots(root):
    """Where the three struts leave the canister: a little apart, round its face."""
    root = np.asarray(root, float)
    out = []
    for deg in ATTACH_DEG:
        q = rim_point(deg) + root
        d = q - root
        side = d - AXIS * (d @ AXIS)
        side /= max(np.linalg.norm(side), 1e-9)
        out.append(root + 0.22 * side)
    return out


def parts(kit, root=(0.0, 0.0, 0.0)):
    """The inflated antenna, struts from `root` (the canister's open end)."""
    root = np.asarray(root, float)
    p = []
    P, T, UV = _dish(kit)
    p.append(kit.part("reflector (aluminised Mylar)", SILVER, (P + root, T), texture=tex_gores(), uv=UV))
    tor = U.torus(RIM, 0.305, n=96, m=12)                 # round X: turn it to AXIS (X already) and place
    tor = (np.asarray(tor[0]) + CENTRE + root, tor[1])
    p.append(U.tpart(kit, "torus (aluminised wrap)", TORUS, tor, U.tex_mli(81, seams=0, depth=0.65), tile=0.6))
    st = []
    for base, deg in zip(strut_roots(root), ATTACH_DEG):
        foot = rim_point(deg) + root
        st.append(kit.rod(base, foot, 0.23, n=14))
        st.append(kit.sphere(0.32, n=8, centre=foot))          # the joint at the torus
    p.append(U.tpart(kit, "inflated struts (aluminised wrap)", STRUT, kit.merge(*st),
                     U.tex_mli(82, seams=6, depth=0.45), tile=1.2))
    return p
