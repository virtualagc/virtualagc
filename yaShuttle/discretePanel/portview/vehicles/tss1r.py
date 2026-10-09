"""The Tethered Satellite System's satellite on its reflight, TSS-1R (NORAD
23805), STS-75, February 1996: reeled out above Columbia on its
conducting tether to 19.7 km, when the tether burned through near the
deployer; the satellite, trailing the tether, rose away and was never met
again (it re-entered in March).  The same satellite flew tethered on
STS-46 (TSS-1, 1992; reel jammed at 256 m; not catalogued).

The satellite (Aeritalia/Alenia, for ASI and NASA): a 1.6 m sphere, 518
kg, an aluminium shell in conductive white paint, built as two
hemispheres -- the service module (the tether attachment at its pole) and
the payload module (its polar panel) -- joined at an external ring round
the equator.  Arrangement from Aeritalia's exploded view (Messidoro et
al., "Magnetic cleanliness verification approach on Tethered Satellite",
NTRS 19910009845, fig. 3 and text: two fixed booms at the equator, one for
the S-band antenna and one for science instruments; the tether attachment
at the service module's pole), and from the flight photographs:

* 9311302 (STS-46, the service-module side, closest and sharpest) and
  STS075-701-087 (STS-75, the same side, satellite just off the deployer):
  round the tether pole a black disc ~0.37 m across with a metal fitting in
  its middle and a black tab off one side; four black slots ~0.38 m long,
  ~0.045 m wide, along the parallel 50 deg from that pole, 90 deg apart;
  two round ports (dark, metal-rimmed) 33 deg from the pole on the slots'
  meridians either side of the tab's; dotted rivet seams on four
  meridians between the slots; recessed dark windows just short of the
  equator; the equatorial ring and the two booms just on the payload side
  of it, the science boom (~0.55 m, probes crossed at its tip) and the
  shorter antenna boom (a crossbar on a stubby canister) opposite.
* 9612176 (STS-75, the satellite on the deployer's docking ring) and
  9606462 (STS-75, deploying, side-on at a distance): the payload pole's
  mast, silver with a yellow helical wrap, carrying an instrument box at
  its tip ~1 m beyond the shell (9606462 measures 0.8 m projected; 9311302
  and 701-087 suggest it was run out further in flight -- the length is
  the least certain dimension here), steadied by three festooned stays
  from the shell 30 deg off the pole to two thirds of the way up.
  Sizes scaled from the 1.6 m sphere in each photograph.

The tether itself (2.5 mm across, 19.7 km long) is not modelled -- it is
far below a pixel.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'tss1r'

R = 0.80
TEX_W, TEX_H = 1024, 512


def _paint():
    """The shell's paint and markings, mapped u round +X (0 at +Y, toward
    +Z), v the colatitude from the +X (mast) pole, 0..1 to the -X (tether)
    pole: every texel's point on the sphere, the markings tested in 3D."""
    from PIL import Image
    v = (np.arange(TEX_H) + 0.5) / TEX_H
    u = (np.arange(TEX_W) + 0.5) / TEX_W
    th = np.pi * v[:, None] * np.ones((1, TEX_W))
    ph = 2 * np.pi * u[None, :] * np.ones((TEX_H, 1))
    t = np.pi - th                        # colatitude from the tether pole
    a = np.full((TEX_H, TEX_W), 0.96)
    s = R * t                             # arc length from the tether pole
    lon = (np.degrees(ph) + 360) % 360

    def dlon(c):
        return (lon - c + 180) % 360 - 180
    # rivet seams: dotted, on four meridians between the slots, both halves
    for c in (45, 135, 225, 315):
        d = np.abs(np.radians(dlon(c))) * R * np.sin(th)
        dots = (np.sin(th * R / 0.025 * 2 * np.pi) > 0.3)
        a[(d < 0.004) & dots & (s > 0.20)] *= 0.55
    # a seam round the payload module's polar panel (mast side)
    a[(np.abs(th * R - 0.42) < 0.004) & (np.sin(ph * R * np.sin(0.52) / 0.025 * 2 * np.pi) > 0.3)] *= 0.55
    # the tether pole's black disc and its tab (toward +Z, lon 90)
    a[s < 0.185] = 0.05
    tab = (np.abs(np.radians(dlon(90)) * R * np.sin(t)) < 0.04) & (s < 0.32)
    a[tab] = 0.05
    # four black slots on the parallel 50 deg from the tether pole
    for c in (0, 90, 180, 270):
        along = np.abs(np.radians(dlon(c)) * R * np.sin(t))
        a[(np.abs(t - math.radians(50)) * R < 0.023) & (along < 0.19)] = 0.04
    # two round ports on the slots' meridians either side of the tab's
    for c in (0, 180):
        p = np.stack([np.cos(t), np.sin(t) * np.cos(ph), np.sin(t) * np.sin(ph)])
        q = np.array([math.cos(math.radians(33)), math.sin(math.radians(33)) * math.cos(math.radians(c)),
                      math.sin(math.radians(33)) * math.sin(math.radians(c))])
        d = R * np.arccos(np.clip(np.tensordot(q, p, 1), -1, 1))
        a[d < 0.050] = 0.45
        a[d < 0.034] = 0.06
    # recessed windows short of the equator, 20 deg off the booms' meridians
    for c in (20, 160, 200, 340):
        along = np.abs(np.radians(dlon(c)) * R)
        a[(np.abs(t - math.radians(78)) * R < 0.05) & (along < 0.08)] = 0.18
        a[(np.abs(t - math.radians(78)) * R < 0.03) & (along < 0.06)] = 0.40
    rgb = np.stack([a] * 3, -1)
    return Image.fromarray((np.clip(rgb, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))


def build(kit):
    p = []
    sph = kit.sphere(R, n=32)
    pts, tris = U.unshare(sph)
    ang = (np.arctan2(pts[:, 2], pts[:, 1]) / (2 * math.pi)) % 1.0
    t = np.asarray(tris)
    tri = ang[t]
    for i in np.where(tri.max(1) - tri.min(1) > 0.5)[0]:
        for c in range(3):
            if tri[i, c] < 0.5:
                ang[t[i, c]] += 1.0
    vv = np.arccos(np.clip(pts[:, 0] / R, -1, 1)) / math.pi
    uv = np.column_stack([ang, vv]).astype(np.float32)
    part = kit.part("sphere (white conductive paint)", (0.80, 0.80, 0.78), (pts, tris), texture=_paint(), uv=uv)
    part['nrm'] = pts / np.linalg.norm(pts, axis=1, keepdims=True)
    p.append(part)
    # the external ring round the equator, 12 mm proud
    p.append(kit.part("equatorial ring", (0.62, 0.62, 0.63), kit.tube(R + 0.012, R - 0.03, -0.022, 0.022, n=64)))
    # the tether pole's black disc (a cap 3 mm proud, crisper than the
    # texture can be at the pole) and the attachment fitting in it
    cap = kit.sphere(R + 0.003, n=16, x_range=(-(R + 0.003), -(R + 0.003) * math.cos(0.185 / R)))
    p.append(kit.part("tether pole disc (black)", (0.04, 0.04, 0.045), cap, smooth=True))
    p.append(kit.part("tether attachment", (0.62, 0.60, 0.56),
                      kit.cylinder(0.085, -R - 0.03, -R + 0.02, n=20),
                      kit.cylinder(0.035, -R - 0.07, -R - 0.03, n=12)))
    # the payload pole's mast: the boom canister, silver with a yellow
    # helical wrap, its instrument box at the tip ~1 m beyond the shell
    x0, x1 = R - 0.02, R + 0.92
    p.append(kit.part("mast (silver)", (0.66, 0.66, 0.68), kit.cylinder(0.062, x0, x1, n=16), smooth=True))
    helix = []
    for k in range(18):
        xa = x0 + 0.08 + k * 0.045
        a0, a1 = k * 2.1, k * 2.1 + 1.9
        helix.append(kit.rod((xa, 0.066 * math.cos(a0), 0.066 * math.sin(a0)),
                             (xa + 0.04, 0.066 * math.cos(a1), 0.066 * math.sin(a1)), 0.006, n=4))
    p.append(kit.part("mast wrap (yellow)", (0.70, 0.55, 0.10), *helix))
    p.append(kit.part("mast head fitting", (0.55, 0.55, 0.57), kit.cylinder(0.075, x1, x1 + 0.06, n=16),
                      kit.cylinder(0.05, x1 + 0.06, x1 + 0.10, n=12)))
    p.append(U.tpart(kit, "tip instrument box (white)", (0.80, 0.80, 0.78),
                     kit.box((0.15, 0.16, 0.14), (x1 + 0.175, 0.0, 0.0)), U.tex_panels(1, 1, seed=231), tile=0.2))
    p.append(kit.part("tip instrument (gold)", (0.72, 0.56, 0.24), kit.box((0.04, 0.07, 0.05), (x1 + 0.27, 0.03, 0.03)),
                      kit.box((0.05, 0.04, 0.04), (x1 + 0.12, -0.10, 0.06))))
    stays = []
    top = np.array([x0 + 0.66 * (x1 - x0), 0.0, 0.0])
    for k in range(3):
        a = 2 * math.pi * k / 3 + math.pi / 2
        c = math.radians(30)
        base = np.array([R * math.cos(c), R * math.sin(c) * math.cos(a), R * math.sin(c) * math.sin(a)])
        q = top + 0.07 * np.array([0.0, math.cos(a), math.sin(a)])
        stays.append(kit.rod(base, q, 0.014, n=6))
        stays.append(kit.box((0.06, 0.09, 0.09), base + 0.005 * base / R))
    p.append(kit.part("mast stays (festooned)", (0.78, 0.78, 0.76), *stays))
    # the science boom (+Y) and the S-band antenna boom (-Y), on the
    # payload side of the ring
    xb = 0.07
    sci = [kit.rod((xb, R * 0.99, 0.0), (xb, R + 0.50, 0.0), 0.034, n=12),
           kit.rod((xb, R + 0.30, 0.0), (xb, R + 0.36, 0.0), 0.045, n=12),
           kit.rod((xb, R + 0.50, 0.0), (xb, R + 0.58, 0.0), 0.022, n=8)]
    for d in ((0, 0, 1), (0, 0, -1), (1, 0, 0), (-1, 0, 0)):
        c = np.array([xb, R + 0.54, 0.0])
        sci.append(kit.rod(c, c + 0.11 * np.asarray(d, float), 0.007, n=4))
    ant = [kit.rod((xb, -R * 0.99, 0.0), (xb, -R - 0.27, 0.0), 0.042, n=12),
           kit.rod((xb, -R - 0.27, 0.0), (xb, -R - 0.31, 0.0), 0.030, n=10)]
    p.append(kit.part("booms", (0.72, 0.72, 0.73), *sci, *ant))
    p.append(kit.part("antenna crossbar (gold)", (0.72, 0.58, 0.22),
                      kit.rod((xb, -R - 0.22, -0.14), (xb, -R - 0.22, 0.14), 0.010, n=6)))
    p.append(kit.part("probe tips", (0.20, 0.20, 0.21),
                      *[kit.sphere(0.014, n=6, centre=np.array([xb, R + 0.54, 0.0]) + 0.115 * np.asarray(d, float))
                        for d in ((0, 0, 1), (0, 0, -1), (1, 0, 0), (-1, 0, 0))]))
    # thruster and bracket boxes on the ring (the auxiliary propulsion's
    # in-line thrusters sit on the equatorial floor)
    pods = []
    for a in (45, 135, 225, 315):
        r = math.radians(a)
        pods.append(kit.box((0.07, 0.08, 0.08), (0.0, (R + 0.03) * math.cos(r), (R + 0.03) * math.sin(r))))
    p.append(kit.part("thruster pods", (0.50, 0.50, 0.52), *pods))
    return dict(meta=dict(name="TSS-1R tethered satellite (STS-75)",
                          frame="TSS: +X out of the payload module's pole along the instrument mast, "
                                "-X the service module's pole (the tether attachment, toward where the "
                                "tether led), +Y along the science boom (the S-band antenna boom -Y); m; "
                                "the sphere's centre.  (Until 2026-10 the frame text called +X the tether "
                                "side; the axes are unchanged, the tether fitting now -X as the photos show)",
                          source="simple shapes to Aeritalia's exploded view (NTRS 19910009845) and "
                                 "photographs 9311302 (STS-46), STS075-701-087, 9612176, 9606462",
                          norad=23805, mag_1000km=4.0),
                parts=U.refine_parts(p))
