"""SPAS-01, the first Shuttle Pallet Satellite (NORAD 14142), as STS-7
deployed it in June 1983, flew in formation with it (photographing
Challenger -- the first pictures of an orbiter in flight) and caught it
again with the arm.

MBB's SPAS-01 was an open truss of carbon-fibre tubes shaped to the
payload bay's cross-section: 4.8 m across the bay (Y) at its top, 3.4 m
high (Z), 1.5 m along the bay (X), 1,448 kg (STS-41B press kit, for the
same platform refitted as SPAS-01A); the longeron trunnions at the top
corners and the keel fitting at its narrow foot.  Its ten experiments
(MOMS, the remote-sensing scanner; metal-alloy and heat-pipe
experiments; a mass spectrometer) and its cameras (a 70 mm Hasselblad, a
16 mm film and two TV cameras, the ones that pictured Challenger) sat on
the top deck and in the truss, with the batteries and avionics boxes.
Few close photographs of the free-flyer exist (it carried the cameras):
the layout of the boxes here is representative, not exact.
"""
import numpy as np

from . import _leo_util as U

KEY = 'spas01'

CFRP = (0.06, 0.06, 0.07)
WHITE = (0.80, 0.80, 0.78)
SILVER = (0.62, 0.62, 0.64)
GOLD = (0.60, 0.42, 0.14)

HX = 0.75
TOP, FOOT = 1.4, -2.0
TOP_Y, FOOT_Y = 2.4, 0.6


def build(kit):
    p = []
    # the truss: two trapezoid end frames joined by longerons, diagonals in
    # each face
    corners = lambda x: [np.array(c, float) for c in ((x, -TOP_Y, TOP), (x, TOP_Y, TOP),
                                                         (x, FOOT_Y, FOOT), (x, -FOOT_Y, FOOT))]
    a, b = corners(-HX), corners(HX)
    st = []
    for k in range(4):
        st.append(kit.rod(a[k], a[(k + 1) % 4], 0.045, n=6))
        st.append(kit.rod(b[k], b[(k + 1) % 4], 0.045, n=6))
        st.append(kit.rod(a[k], b[k], 0.045, n=6))
        st.append(kit.rod(a[k], b[(k + 1) % 4], 0.03, n=6))
    # the end frames' cross bracing and the mid-height ring
    for c in (a, b):
        st.append(kit.rod(c[0], c[2], 0.03, n=6))
        st.append(kit.rod(c[1], c[3], 0.03, n=6))
    mid = lambda x, s: np.array([x, s * 0.5 * (TOP_Y + FOOT_Y), 0.5 * (TOP + FOOT)])
    for s in (-1, 1):
        st.append(kit.rod(mid(-HX, s), mid(HX, s), 0.035, n=6))
    st.append(kit.rod(mid(-HX, -1), mid(-HX, 1), 0.035, n=6))
    st.append(kit.rod(mid(HX, -1), mid(HX, 1), 0.035, n=6))
    p.append(kit.part("carbon-fibre truss", CFRP, *st))
    # the top deck: a plate of honeycomb panels with the experiments
    deck = kit.box((2 * HX - 0.1, 2 * TOP_Y - 0.3, 0.06), (0, 0, TOP + 0.03))
    p.append(U.tpart(kit, "top deck", (0.55, 0.55, 0.56), deck, U.tex_panels(2, 6, seed=91), tile=(1.4, 4.5), fine=0.5,
                     axes=((1, 0, 0), (0, 1, 0))))
    boxes = [kit.box((0.9, 0.9, 0.55), (0.1, -1.55, TOP + 0.335)),      # MOMS
             kit.box((0.7, 0.6, 0.45), (-0.2, -0.55, TOP + 0.285)),
             kit.box((1.0, 0.8, 0.35), (0.05, 0.45, TOP + 0.235)),
             kit.box((0.6, 0.7, 0.60), (0.2, 1.55, TOP + 0.36))]
    p.append(U.tpart(kit, "experiments (white blankets)", WHITE, kit.merge(*boxes), U.tex_mli(92, seams=1), tile=0.8))
    cams = [kit.box((0.35, 0.30, 0.30), (0.55, 0.9, TOP + 0.21)), kit.box((0.25, 0.25, 0.25), (0.55, -0.1, TOP + 0.18))]
    p.append(kit.part("camera housings", (0.30, 0.30, 0.31), *cams))
    lens = [kit.along(kit.cylinder(0.07, 0.0, 0.12, n=12), (1, 0, 0), (0.725, 0.9, TOP + 0.21)),
            kit.along(kit.cylinder(0.05, 0.0, 0.10, n=12), (1, 0, 0), (0.675, -0.1, TOP + 0.18))]
    p.append(kit.part("lenses", (0.03, 0.03, 0.03), *lens))
    # boxes inside the truss: batteries, avionics, the alloy furnaces
    inner = [kit.box((1.2, 1.2, 0.6), (0.0, 0.0, 0.6)), kit.box((1.1, 0.9, 0.7), (0.0, -0.7, -0.4)),
             kit.box((1.1, 0.9, 0.7), (0.0, 0.7, -0.4)), kit.box((0.9, 0.8, 0.5), (0.0, 0.0, -1.4))]
    p.append(U.tpart(kit, "inner boxes (silver blankets)", SILVER, kit.merge(*inner), U.tex_mli(93, seams=2), tile=0.9))
    p.append(kit.part("heat-pipe radiators", WHITE, kit.box((0.02, 1.0, 0.8), (HX + 0.03, -1.4, 0.4)),
                      kit.box((0.02, 1.0, 0.8), (-HX - 0.03, 1.4, 0.4))))
    p.append(kit.part("gold-blanketed experiment", GOLD, kit.box((0.6, 0.6, 0.5), (0.0, 1.9, 0.9))))
    # trunnions at the top corners (+-Y) and the keel pin at the foot
    tr = [U.trunnion(kit, (0.0, s * (TOP_Y + 0.02), TOP - 0.1), (0, s, 0), 0.28, 0.041) for s in (-1, 1)]
    tr.append(U.trunnion(kit, (0.0, 0.0, FOOT), (0, 0, -1), 0.30, 0.05))
    tr.append(kit.rod((-HX, 0, FOOT), (HX, 0, FOOT), 0.05, n=6))
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *tr))
    for name, rgb, m in U.frgf(kit, (0.0, -0.45, TOP + 0.51), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="SPAS-01 (Shuttle Pallet Satellite, STS-7)",
                          frame="SPAS-01: +X along the payload bay when berthed, +Y across it "
                                "(between the longeron trunnions), +Z up out of the bay (the top "
                                "deck); m; ~0.3 m above the truss's mid-height (the heavy boxes sit "
                                "high in it)",
                          source="simple shapes to the STS-41B press kit's dimensions; layout "
                                 "representative",
                          norad=14142, mag_1000km=3.0),
                parts=U.refine_parts(p))
