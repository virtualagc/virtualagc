"""The Upper Atmosphere Research Satellite (NORAD 21701), as STS-48
released it in September 1991: its solar wing and high-gain antenna boom
deployed (both were run out while it hung on the arm).

UARS: 10.7 m long, 4.6 m across (35 x 15 ft), 6.5 t.  At one end the
Multimission Modular Spacecraft bus (the silver-blanketed module box with
its yellow trunnion fittings), then the long instrument module in gold
blanket with silver radiator windows, the instruments' boxes (CLAES's big
cryostat housing, ISAMS, MLS's antenna, HALOE, HRDI, WINDII, the solar
instruments SUSIM/SOLSTICE/ACRIM II on their pointing platform) along its
top, and white radiators along its lower sides; one solar wing (an
accordion of panels, white-backed, ~3.3 x 9.6 m) on a boom off the
instrument module's top, and the 1.5 m high-gain dish on a boom off the far
end.  Proportions from s48-31-002, s48-05-024, NASA 9248071; dimensions
NASA's UARS fact sheets.
"""
import numpy as np

from . import _leo_util as U

KEY = 'uars'

GOLD = (0.60, 0.42, 0.14)
SILVER = (0.62, 0.62, 0.64)
WHITE = (0.80, 0.80, 0.78)
YELLOW = (0.75, 0.60, 0.08)


def build(kit):
    p = []
    gold_tex = U.tex_mli(21, seams=2, depth=0.45)
    silver_tex = U.tex_mli(22, seams=2, depth=0.35)
    # the MMS bus at -X: a box with its modules' faces
    mms = kit.box((2.6, 3.0, 2.6), (-4.05, 0.0, 0.0))
    p.append(U.tpart(kit, "MMS bus (silver blanket)", SILVER, mms, U.tex_panels(2, 2, seed=31, spread=0.2), tile=1.4, fine=0.4))
    # the instrument module: the long box in gold blanket
    im = kit.box((7.9, 2.4, 2.1), (1.2, 0.0, -0.15))
    p.append(U.tpart(kit, "instrument module (gold blanket)", GOLD, im, gold_tex, tile=1.6, fine=0.4))
    # silver windows (radiators) on its +Y and -Y faces
    win = []
    for x, z, s in ((-1.6, 0.1, 0.5), (-0.2, 0.0, 0.35), (1.4, 0.2, 0.5), (2.6, -0.3, 0.45), (3.9, 0.1, 0.5)):
        for sy in (-1, 1):
            win.append(kit.box((s, 0.01, s), (x, sy * 1.206, z)))
    p.append(kit.part("radiator windows", (0.70, 0.70, 0.72), *win))
    # white radiator panels along the lower +Y side and the end
    rad = [kit.box((3.0, 0.03, 1.0), (-0.8, 1.22, -0.75)), kit.box((1.6, 0.03, 0.9), (2.4, -1.22, -0.70))]
    p.append(U.tpart(kit, "white radiators", WHITE, kit.merge(*rad), U.tex_panels(2, 1, seed=33), tile=1.5))
    # instruments on top (+Z): CLAES (the big box), ISAMS, MLS, HALOE,
    # HRDI, WINDII, and the solar stellar pointing platform at the far end
    inst = [kit.box((1.8, 1.8, 1.3), (-1.7, 0.1, 1.55)),        # CLAES
            kit.box((1.0, 1.2, 0.7), (-0.2, -0.3, 1.25)),       # ISAMS
            kit.box((1.2, 1.0, 0.9), (2.6, 0.5, 1.35)),         # HALOE
            kit.box((0.9, 0.9, 0.8), (3.8, -0.4, 1.30)),        # HRDI
            kit.box((0.8, 0.7, 0.9), (4.4, 0.6, 1.35))]         # WINDII
    p.append(U.tpart(kit, "instruments (gold blanket)", GOLD, kit.merge(*inst), U.tex_mli(23, seams=1, depth=0.45), tile=1.0))
    plat = [kit.box((1.2, 1.3, 0.25), (4.7, -0.5, 1.95)), kit.box((0.6, 0.5, 0.5), (4.7, -0.5, 2.32))]
    p.append(U.tpart(kit, "solar instruments (silver)", SILVER, kit.merge(*plat), silver_tex, tile=0.8))
    # MLS's antenna: a tilted rectangular reflector on the -Y side
    mls = kit.turn(kit.box((0.05, 1.6, 0.8), (0, 0, 0)), kit.rot('x', 30))
    p.append(kit.part("MLS antenna", (0.75, 0.75, 0.75), kit.move(mls, (0.9, -1.55, 0.95))))
    # yellow trunnion fittings (the round 'scoops') at the module ends
    yel = [kit.along(kit.cylinder(0.42, 0.0, 0.10, n=24), (0, sy, 0), (x, sy * 1.21, -0.6))
           for x in (-2.5, 4.9) for sy in (-1, 1)]
    p.append(kit.part("trunnion fittings (yellow)", YELLOW, *yel, smooth=False))
    tr = [U.trunnion(kit, (x, sy * 1.31, -0.6), (0, sy, 0), 0.25, 0.041) for x in (-2.5, 4.9) for sy in (-1, 1)]
    p.append(kit.part("trunnions", (0.75, 0.75, 0.75), *tr))
    for name, rgb, m in U.frgf(kit, (0.6, 1.21, 0.35), (0, 1, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    # the solar wing: a mast off the top of the module, the array 3.3 x 9.6 m
    # out along -Y, cells toward +Z
    mast0, mast1 = np.array([0.8, -0.8, 0.95]), np.array([0.8, -2.6, 2.6])
    p.append(kit.part("solar array boom", (0.60, 0.60, 0.60), kit.rod(mast0, mast1, 0.08, n=10),
                      kit.box((0.4, 0.4, 0.4), mast1)))
    wing = U.solar_wing(kit, mast1 + (0, -0.2, 0.0), (0, -1, 0), (1, 0, 0), 9.6, 3.3, panels=6, face=(0, 0, 1))
    p.append(U.tpart(kit, "solar cells", U.CELLS, wing[0][2], U.tex_cells(6, 10), tile=(3.3, 1.6),
                     axes=((1, 0, 0), (0, 1, 0))))
    p.append(kit.part("solar array backs (white)", (0.75, 0.75, 0.72), wing[1][2]))
    # the high-gain antenna boom off the +X end and its 1.5 m dish
    h0, h1 = np.array([5.15, 0.6, -0.7]), np.array([7.6, 1.2, -2.2])
    p.append(kit.part("HGA boom", (0.70, 0.70, 0.70), kit.rod(h0, h1, 0.06, n=10)))
    dish_axis = np.array([1.0, 0.0, -0.4])
    dish = kit.along(kit.frustum(0.08, 0.75, 0.0, 0.32, n=32, caps=False), dish_axis, h1)
    p.append(kit.part("HGA dish", (0.82, 0.82, 0.80), dish, smooth=True))
    # the 'whip' antenna mast on the MMS end
    p.append(kit.part("omni mast", (0.80, 0.80, 0.80), kit.rod((-2.9, 0.9, 1.3), (-2.9, 0.9, 3.0), 0.05, n=8)))
    return dict(meta=dict(name="Upper Atmosphere Research Satellite (UARS)",
                          frame="UARS: +X along the body from the MMS bus toward the high-gain "
                                "antenna end, +Z the instruments' (zenith-facing top) side, +Y the "
                                "grapple fixture's side (the solar wing out along -Y); m; the body's "
                                "mid-length (the heavy MMS bus and the instruments balance near it)",
                          source="simple shapes to NASA's published dimensions and STS-48 photographs",
                          norad=21701, mag_1000km=1.5),
                parts=U.refine_parts(p))
