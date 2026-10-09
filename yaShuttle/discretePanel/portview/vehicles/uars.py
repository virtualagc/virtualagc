"""The Upper Atmosphere Research Satellite (NORAD 21701), as STS-48
released it on 15 September 1991: its solar array run out flat and its
high-gain antenna swung out to the end while it hung on the arm, the ZEPS
boom up.

UARS (GE Astro for GSFC): 10.7 m long overall, 4.6 m across the
trunnions, 6.5 t (NASA; eoPortal).  At one end the Multimission Modular
Spacecraft -- the hydrazine propulsion module at the very end and the
module support structure with its 1.2 m modules, their faces silver
radiator panels -- then the long instrument module in crumpled amber
Kapton with square silver radiator windows, a white radiator and a dark
equipment bay along its lower side, four yellow semicircular trunnion
fittings (out on dark struts to the payload bay's longerons) and the
instruments round it; the single solar array, six panels each 1.5 x 3.3
m in a line (~9 m, "about 30 feet": NTRS 19930015545) on a drive on the
module's top three-quarters of the way along; the SSPP (the solar
instruments' pointing platform) on its A-frame and the 1.4 m high-gain
dish at the far end; the Zenith Energetic Particle (ZEPS) boom standing
2 m up at the MMS end.

What decided what (NASA photographs, STS-48, and drawings):
* 9254338 (images.nasa.gov; the +Y side square on, Earth behind) is the
  measuring photograph: the array's 3.3 m width (817 px) gives the scale,
  and from it the MMS end to the far-end structure is 10.0 m (10.6 m to
  the dish's rim, as the published 10.7 m); every position along X and up
  Z here was read off it -- the MMS module face (1.6 m square, 2 x 3
  panels), the instrument module's top (1.36 m) and gold band down to
  -0.14 m, the white radiators (-2.2..1.0 m along, under the gold) and the
  dark bay under them, the six silver windows, the yellow fittings
  (0.9 m, at -2.35 and +4.14 m), the PEM box, the CLAES aperture box
  tilted on the top edge, the omni whip, the ZEPS boom (to 3.3 m), the
  array's root (1.94 m up, -0.5..2.8 m along), the A-frame and SSPP box,
  the HGA dish (1.38 m across, centred 4.9 m along, 0.6 m up, looking
  along +X and a little up), the gold thruster skirts under the MMS.
* 9248071 and s48-05-024 (the same side, array part-folded) and
  Ron's sts48uarsdeploy.jpg (the same view as 9254338): confirmation;
  s48-31-002 (release, upside down): the white radiators' height (1.07 m,
  so they slope: they look 0.57 m tall square on), the grapple fixture on
  the +X panel, the PEM box's sensor.
* STS048-23-12 and -21 (EOL; the same side upside down, the array
  stowed as a stack on top and then unfolding): the array's root on the
  top, the ZEPS boom on the same side.
* s48-e-013 (in the bay, from the aft flight deck): the dark trunnion
  struts carrying the yellow fittings out to the longerons.
* NTRS 19930015545 fig. 1 and 19930019519 (the UARS jitter study's
  labelled drawing): six equal array panels, the array's drive near the
  HGA end, instruments' names (CLAES, ISAMS, HRDI, HALOE, MLS, WINDII,
  SSPP with SOLSTICE and SUSIM).
The -Y side and the underside are seen in no photograph found: they are
the +Y side's kinds of surface (windows, radiator), not measured.  Ron's
Blender renders (PhotosOfSatellites/uars) were not used as evidence.
"""
import math

import numpy as np

from . import _leo_util as U
from . import _cgro_util as C

KEY = 'uars'

GOLD = (0.80, 0.42, 0.09)        # 9254338: amber, linear 1 : 0.42 : 0.07
SILVER = (0.58, 0.60, 0.61)      # the MMS modules' faces (mirror-like)
WHITE = (0.82, 0.83, 0.80)
YELLOW = (0.80, 0.55, 0.03)
DARK = (0.07, 0.07, 0.08)
WIN = (0.62, 0.66, 0.66)

# the instrument module (IM): +Y face at Y_IM, top at Z_TOP
Y_IM = 1.25
Z_TOP, Z_GOLD = 1.36, -0.14
X_IM0, X_IM1 = -2.62, 3.58


def _back_tex():
    """The array panels' white backs (9254338): two black dots on each and
    harness lines along the panel, a darker frame (u along X across the
    3.3 m panel, v along the 1.5 m panel; one repeat a panel)."""
    from PIL import Image
    s = 256
    yy, xx = (np.mgrid[0:s, 0:s] + 0.5) / s
    v = np.full((s, s), 1.0)
    for c in (0.62, 0.66, 0.70):
        v[(np.abs(xx - c) < 0.004)] = 0.75
    v[(np.abs(xx - 0.80) < 0.01) & (yy > 0.3)] = 0.8
    for cx, cy in ((0.18, 0.35), (0.45, 0.70)):
        v[(xx - cx) ** 2 + ((yy - cy) * 0.45) ** 2 < 0.00012] = 0.08
    v[(xx < 0.01) | (xx > 0.99) | (yy < 0.02) | (yy > 0.98)] = 0.55
    return Image.fromarray((np.clip(v, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)).convert("RGB")


def _mirror_y(parts):
    """The model is laid out below with the photographed side (9254338's) at
    +Y; that photograph looks from -Y (the MMS on the left, +Z up), so the
    whole is mirrored in Y at the end: the photographed side is -Y."""
    for q in parts:
        pos = np.asarray(q['pos'], float).copy()
        pos[:, 1] *= -1
        q['pos'] = pos
        q['idx'] = np.asarray(q['idx']).reshape(-1, 3)[:, ::-1].copy()
        if q.get('nrm') is not None:
            n = np.asarray(q['nrm'], float).copy()
            n[:, 1] *= -1
            q['nrm'] = n
    return parts


def build(kit):
    p = []
    gold_tex = C.tex_blanket(seed=21, crinkle=3.0, depth=0.55, seams=2, glints=0.9)
    silver_crumple = C.tex_blanket(seed=22, crinkle=3.0, depth=0.5, seams=1, glints=1.0)
    # --------------------------------------------------------------- the MMS
    # propulsion module at the very end, the module support structure, the
    # +Y, -Y and top modules (their faces 1.6 m square, 2 x 3 radiator panels)
    p.append(U.tpart(kit, "MMS propulsion module (silver blanket)", (0.62, 0.63, 0.64),
                     kit.box((0.66, 1.60, 1.45), (-4.69, 0.0, 0.18)), silver_crumple, tile=0.8, fine=0.4))
    p.append(U.tpart(kit, "MMS structure (gold blanket)", GOLD, kit.box((1.62, 1.90, 1.55), (-3.48, 0.0, 0.18)),
                     gold_tex, tile=1.0, fine=0.4))
    mods = [kit.box((1.57, 0.40, 1.51), (-3.50, s * 1.155, 0.175)) for s in (-1, 1)]
    mods.append(kit.box((1.37, 1.40, 0.40), (-3.52, 0.0, 1.16)))
    p.append(U.tpart(kit, "MMS modules (silver radiators)", SILVER, kit.merge(*mods),
                     C.tex_osr(2, 3, seed=23, base=0.95, spread=0.25, line=0.35), tile=(1.57, 1.51), fine=0.4))
    sk = []
    for x in (-4.60, -2.95):
        for s in (-1, 1):
            sk.append(kit.along(kit.frustum(0.16, 0.30, 0.0, 0.50, n=12, caps=False), (0, 0.25 * s, -1),
                                (x, s * 0.55, -0.57)))
    p.append(kit.part("thruster skirts (gold blanket)", GOLD, *sk))
    # -------------------------------------------------- the instrument module
    im = kit.box((X_IM1 - X_IM0, 2 * Y_IM, Z_TOP - Z_GOLD), (0.5 * (X_IM0 + X_IM1), 0.0, 0.5 * (Z_TOP + Z_GOLD)))
    p.append(U.tpart(kit, "instrument module (gold blanket)", GOLD, im, gold_tex, tile=1.3, fine=0.4))
    # the lower bay, set back 0.25 m: dark equipment, the white radiators
    # sloping out on its +Y side (s48-31-002), the dark rail beneath
    low = kit.box((3.50, 1.20, 1.19), (-0.62, 0.0, -0.745))
    p.append(U.tpart(kit, "lower bay (dark)", DARK, low, C.tex_grid_panel(nx=4, ny=2, seed=24), tile=0.9, fine=0.4))
    rail = kit.box((3.10, 0.40, 0.34), (-0.72, 0.85, -1.18))
    p.append(U.tpart(kit, "equipment rail (dark grey)", (0.20, 0.22, 0.26), rail, C.tex_grid_panel(nx=8, ny=1, seed=25),
                     tile=(1.0, 0.36)))
    rad = []
    tilt = math.radians(50)                      # the panels' face: +Y tipped 50 deg toward -Z
    nrm = np.array([0.0, math.cos(tilt), -math.sin(tilt)])
    up = np.array([0.0, math.sin(tilt), math.cos(tilt)])
    R = np.column_stack([nrm, (1.0, 0.0, 0.0), up])
    for x0, x1 in ((-2.23, -0.45), (-0.41, 1.01)):
        m = kit.box((0.02, x1 - x0, 1.05), (0.0, 0.0, 0.0))
        rad.append(kit.move(kit.turn(m, R), (0.5 * (x0 + x1), 1.05, -0.66)))
    p.append(U.tpart(kit, "white radiators", WHITE, kit.merge(*rad), C.tex_grid_panel(nx=3, ny=2, seed=26, line=0.85),
                     tile=0.9, fine=0.4))
    # silver radiator windows on the +Y face (9254338) and, unmeasured, the
    # same on -Y
    win = []
    for x0, x1, z0, z1 in ((-0.66, -0.35, 0.48, 0.80), (0.07, 0.27, 0.52, 0.72), (0.84, 1.30, 0.19, 0.72),
                           (0.97, 1.18, 0.86, 1.05), (1.90, 2.21, 0.19, 0.56), (2.85, 3.14, 0.37, 0.72),
                           (-2.25, -1.95, 0.30, 0.60)):
        for s in (-1, 1):
            win.append(kit.box((x1 - x0, 0.012, z1 - z0), (0.5 * (x0 + x1), s * (Y_IM + 0.011), 0.5 * (z0 + z1))))
    p.append(U.tpart(kit, "radiator windows (silver)", WIN, kit.merge(*win), C.tex_osr(3, 3, seed=27, base=1.0, spread=0.3),
                     tile=0.4))
    # the far end: the gold-blanketed end structure the HGA hangs off
    p.append(U.tpart(kit, "far-end structure (gold blanket)", GOLD, kit.box((1.40, 1.60, 0.65), (4.30, 0.0, -0.075)),
                     gold_tex, tile=0.9, fine=0.4))
    # under the far half: HALOE, HRDI and the silver box (9254338, lower right)
    p.append(U.tpart(kit, "silver box (HALOE electronics)", (0.66, 0.67, 0.69), kit.box((1.0, 0.9, 0.42), (3.26, 0.75, -0.30)),
                     silver_crumple, tile=0.6))
    ins = [kit.box((0.70, 0.75, 0.55), (2.25, 0.55, -0.65)), kit.box((0.55, 0.60, 0.65), (2.95, 0.45, -0.95)),
           kit.box((0.60, 0.55, 0.50), (1.55, 0.35, -0.55)), kit.box((0.80, 0.80, 0.45), (2.30, -0.60, -0.55))]
    p.append(U.tpart(kit, "limb instruments (silver blanket: HRDI, HALOE, ISAMS)", (0.62, 0.63, 0.65), kit.merge(*ins),
                     silver_crumple, tile=0.7))
    # the PEM box with its round sensor (9254338, s48-31-002)
    p.append(kit.part("PEM box", (0.75, 0.74, 0.70), kit.box((0.66, 0.30, 0.38), (-1.50, Y_IM + 0.02, -0.04))))
    p.append(kit.part("PEM sensor", (0.10, 0.10, 0.11),
                      kit.along(kit.cylinder(0.11, 0.0, 0.03, n=16), (0, 1, 0), (-1.45, Y_IM + 0.17, -0.04))))
    # ------------------------------------------------------------ on top
    # the CLAES aperture box, tilted toward +Y over the top edge
    cl = kit.turn(kit.box((0.70, 0.45, 0.62), (0, 0, 0)), kit.rot('x', -35))
    p.append(U.tpart(kit, "CLAES aperture box (dark, silver patches)", (0.10, 0.10, 0.11),
                     kit.move(cl, (-1.52, Y_IM - 0.15, Z_TOP + 0.05)), C.tex_osr(3, 3, seed=28, base=1.0, spread=0.9, line=0.3),
                     tile=0.5))
    p.append(kit.part("omni whip", (0.08, 0.08, 0.08), kit.rod((-1.15, 0.6, Z_TOP), (-0.86, 0.6, 1.80), 0.015, n=6),
                      kit.sphere(0.05, n=8, centre=(-0.86, 0.6, 1.82))))
    # the ZEPS boom, white, 2 m up at the MMS end, its sensor head
    zb = np.array([-2.48, 0.55, Z_TOP])
    p.append(kit.part("ZEPS boom (white)", (0.80, 0.80, 0.78), kit.rod(zb, zb + (0, 0, 1.70), 0.06, n=12)))
    p.append(kit.part("ZEPS head (gold)", GOLD, kit.along(kit.cylinder(0.08, 0.0, 0.18, n=12), (0, 0, 1), zb + (0, 0, 1.70))))
    p.append(kit.part("ZEPS sensor", (0.10, 0.10, 0.11),
                      kit.box((0.10, 0.10, 0.10), zb + (0, 0, 1.93)),
                      kit.rod(zb + (-0.12, 0, 1.93), zb + (0.12, 0, 1.93), 0.012, n=6)))
    # MLS and the instruments on the top's far half
    tops = [kit.box((0.85, 1.30, 0.50), (2.20, -0.25, Z_TOP + 0.25)), kit.box((0.60, 0.70, 0.45), (-0.10, -0.45, Z_TOP + 0.225))]
    p.append(U.tpart(kit, "top instruments (gold blanket: MLS, WINDII)", GOLD, kit.merge(*tops), gold_tex, tile=0.7))
    # the A-frame (a pin on its apex) and the SSPP box on its gimbal
    ap = np.array([2.88, 0.30, 2.62])
    fr = [kit.rod((2.50, 0.95, Z_TOP), ap, 0.03, n=6), kit.rod((3.20, 0.95, Z_TOP), ap, 0.03, n=6),
          kit.rod((2.85, -0.45, Z_TOP), ap, 0.03, n=6)]
    p.append(kit.part("A-frame (gold)", (0.85, 0.55, 0.15), *fr))
    p.append(kit.part("A-frame pin", (0.80, 0.80, 0.80), kit.rod(ap, ap + (0, 0, 0.22), 0.025, n=8)))
    ss = kit.turn(kit.box((1.10, 0.70, 0.58), (0, 0, 0)), kit.rot('y', 10))
    p.append(U.tpart(kit, "SSPP (white)", (0.80, 0.80, 0.78), kit.move(ss, (3.85, 0.20, 1.86)),
                     C.tex_grid_panel(nx=2, ny=2, seed=29), tile=0.7))
    p.append(kit.part("SSPP top (mirror)", (0.08, 0.09, 0.10),
                      kit.move(kit.turn(kit.box((1.02, 0.62, 0.02), (0, 0, 0.30)), kit.rot('y', 10)), (3.85, 0.20, 1.86))))
    p.append(kit.part("SSPP gimbal", (0.30, 0.30, 0.32), kit.rod((3.70, 0.2, Z_TOP), (3.75, 0.2, 1.58), 0.09, n=10)))
    # ------------------------------------------------- the solar array
    # its drive on the top, a yoke up to the root bar, six panels in a line
    # straight up (+Z), 3.3 m along X; the white backs to +Y (9254338), the
    # cells to -Y
    ax0, ax1, root = -0.50, 2.80, 1.94
    yo = [kit.rod((0.40, 0.25, Z_TOP), (0.60, 0.15, root), 0.04, n=6), kit.rod((1.55, 0.25, Z_TOP), (1.35, 0.15, root), 0.04, n=6),
          kit.rod((0.40, 0.25, Z_TOP), (1.35, 0.15, root), 0.03, n=6), kit.rod((-0.45, 0.15, root), (2.75, 0.15, root), 0.04, n=8)]
    p.append(kit.part("array yoke (gold)", (0.85, 0.55, 0.15), *yo))
    p.append(U.tpart(kit, "array drive (white blanket)", (0.80, 0.80, 0.78), kit.box((1.30, 0.70, 0.30), (0.98, 0.25, Z_TOP + 0.15)),
                     C.tex_blanket(seed=30, crinkle=1.5, depth=0.25, seams=1), tile=0.7))
    backs, cells, hinges = [], [], []
    pl, gap, y0 = 1.50, 0.03, 0.15
    for k in range(6):
        z0 = root + 0.05 + k * (pl + gap)
        backs.append(kit.box((ax1 - ax0, 0.025, pl), (0.5 * (ax0 + ax1), y0 + 0.0125, z0 + pl / 2)))
        cells.append(kit.box((ax1 - ax0 - 0.04, 0.004, pl - 0.04), (0.5 * (ax0 + ax1), y0 - 0.007, z0 + pl / 2)))
        hinges.append(kit.box((ax1 - ax0, 0.035, 0.025), (0.5 * (ax0 + ax1), y0 + 0.0125, z0 - gap / 2)))
    m, uv = U.planar_uv(kit.merge(*backs), (ax1 - ax0, pl + gap), ((1, 0, 0), (0, 0, 1)))
    uv[:, 0] -= ax0 / (ax1 - ax0)
    uv[:, 1] -= (root + 0.05) / (pl + gap)
    p.append(kit.part("solar array backs (white)", (0.85, 0.85, 0.82), m, texture=_back_tex(), uv=uv))
    p.append(U.tpart(kit, "solar cells", U.CELLS, kit.merge(*cells), C.tex_cells(10, 6, seed=31, line=0.5),
                     tile=(1.1, 0.75), axes=((1, 0, 0), (0, 0, 1))))
    p.append(kit.part("array frames (gold)", (0.85, 0.55, 0.15), *hinges))
    # ------------------------------------------------- the high-gain antenna
    # 9254338 sees into the bowl, its rim a flat ellipse 1.38 m wide: it
    # looks up (+Z), tipped ~20 deg toward +Y and a little toward +X (s48-05-024
    # sees its back from -Y)
    hc = np.array([4.92, 0.10, 0.63])
    d = np.array([0.30, 0.36, 0.88])
    d /= np.linalg.norm(d)
    dish = kit.along(kit.frustum(0.10, 0.69, -0.32, 0.0, n=36, caps=False), d, hc)
    p.append(kit.part("HGA dish (white)", (0.85, 0.86, 0.84), dish, U.flip(dish), smooth=True))
    p.append(kit.part("HGA feed and gimbal", (0.30, 0.30, 0.32),
                      kit.rod(hc - 0.32 * d, hc - 0.05 * d, 0.03, n=6),
                      kit.rod(hc - 0.32 * d, (4.70, 0.0, 0.25), 0.07, n=10),
                      kit.box((0.30, 0.30, 0.10), (4.70, 0.0, 0.30))))
    # ------------------------------------- trunnion fittings, struts, keel
    yel, pins, struts = [], [], []
    for xf, zf in ((-2.35, 0.0), (4.14, -0.06)):
        for s in (-1, 1):
            yf = s * 1.95
            half = kit.prism([(0.45 * math.cos(a), 0.45 * math.sin(a)) for a in np.linspace(0, math.pi, 13)], 0.0, 0.06)
            yel.append(kit.move(kit.turn(half, np.column_stack([(0, 1, 0), (-1, 0, 0), (0, 0, 1)])), (xf, yf - 0.03, zf)))
            pins.append(U.trunnion(kit, (xf, yf, zf + 0.06), (0, s, 0), 0.38, 0.041))
            ends = (((-2.55, 1.2, 0.6), (-2.0, 1.2, 0.6), (-2.2, 0.55, -0.5)) if xf < 0 else
                    ((3.45, 1.2, 0.6), (4.4, 0.75, 0.15), (3.9, 0.75, -0.3)))
            for ex, ey, ez in ends:
                struts.append(kit.rod((xf, yf, zf + 0.1), (ex, s * ey, ez), 0.035, n=6))
    p.append(kit.part("trunnion fittings (yellow)", YELLOW, *yel))
    p.append(kit.part("trunnion pins", (0.75, 0.75, 0.75), *pins))
    p.append(kit.part("trunnion struts (dark)", (0.08, 0.08, 0.09), *struts))
    p.append(kit.part("keel pin", (0.75, 0.75, 0.75), U.trunnion(kit, (0.9, 0.0, -1.34), (0, 0, -1), 0.28, 0.05)))
    # the grapple fixture on the +X white radiator (s48-31-002)
    gat = np.array([0.42, 1.05, -0.66]) + 0.012 * nrm
    for name, rgb, m in U.frgf(kit, gat, nrm, (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="Upper Atmosphere Research Satellite (UARS)",
                          frame="UARS: +X along the body from the MMS bus toward the high-gain "
                                "antenna end, +Z up from the instrument module's top (the solar "
                                "array's and the ZEPS boom's side), -Y the side NASA 9254338 shows, "
                                "with the grapple fixture (it was +Y before: that photograph, the MMS to "
                                "its left and +Z up, looks from -Y); trunnion pins along +-Y; the array "
                                "(as released) straight up +Z, its white backs toward -Y, its cells "
                                "toward +Y; m; mid-length of the 10.0 m body (the MMS "
                                "and the far-end instruments balance near it)",
                          source="simple shapes measured off NASA 9254338 (scale: the array's 3.3 m "
                                 "width) with 9248071, s48-05-024, s48-31-002, s48-e-013, "
                                 "STS048-23-12/21; NTRS 19930015545 and 19930019519 drawings",
                          norad=21701, mag_1000km=1.5),
                parts=_mirror_y(U.refine_parts(p)))
