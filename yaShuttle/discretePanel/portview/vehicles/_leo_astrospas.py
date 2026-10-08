"""The ASTRO-SPAS carrier (MBB/DASA's Shuttle Pallet Satellite of the
1990s: ORFEUS-SPAS on STS-51 and STS-80, CRISTA-SPAS on STS-66 and STS-85),
and the instrument fits that made each flight's look.

The carrier: a box frame of carbon-fibre struts ~4.4 m across the payload
bay (Y, a longeron trunnion out of each end), ~1.9 m along it (X), ~1.5 m
deep (Z), beige-white blanketed with silver and second-surface-mirror
radiator panels; a tripod under it carrying the keel pin (-Z); the
yellow-plated grapple fixture on the +X face near the +Y end.  Battery
powered: no solar wings.  Proportions from STS-51, STS-66, STS-80 and STS-85
photographs (sts051-15-035, sts080-704-008, sts080-719-005, s85e5096,
sts085-706-051, sts085-722-087), scaled to the bay's 4.6 m.
"""
import numpy as np

from . import _leo_util as U

BEIGE = (0.72, 0.68, 0.60)        # the beta-cloth outer blankets, a little yellowed
SILVER = (0.60, 0.61, 0.63)
OSR = (0.10, 0.11, 0.16)          # mirror radiators: they show the black sky
YELLOW = (0.75, 0.58, 0.10)
STRUT = (0.75, 0.72, 0.65)

DX, DY, DZ = 1.9, 4.4, 1.5


def carrier(kit, osr_faces=True):
    """The carrier's parts: frame box, radiators, keel tripod, trunnions,
    grapple fixture.  Body frame: X along the bay, Y across it, Z away from
    the keel; origin the box's centre."""
    hx, hy, hz = DX / 2, DY / 2, DZ / 2
    p = []
    box = kit.box((DX, DY, DZ))
    p.append(U.tpart(kit, "carrier blankets (beige)", BEIGE, box, U.tex_mli(61, seams=3, depth=0.35), tile=1.5, fine=0.4))
    # the frame's struts showing along the box's edges, and the mid-height
    # longerons along the faces
    st = []
    for sz in (-1, 0, 1):
        for sx in (-1, 1):
            st.append(kit.box((0.07, DY + 0.06, 0.07), (sx * hx, 0, sz * hz)))
    for sx in (-1, 1):
        for y in (-hy, -hy / 3, hy / 3, hy):
            st.append(kit.box((0.07, 0.07, DZ + 0.06), (sx * hx, y, 0)))
    p.append(kit.part("frame struts", STRUT, *st))
    # radiators / silver panels on the +-X faces, standing 5 mm proud
    sil, osr = [], []
    for sx in (-1, 1):
        for y0, kind in ((-1.47, "osr"), (0.0, "silver"), (1.47, "osr")):
            m = kit.box((0.02, 1.25, 1.25), (sx * (hx + 0.015), y0, 0.0))
            (osr if (kind == "osr" and osr_faces) else sil).append(m)
    p.append(U.tpart(kit, "silver panels", SILVER, kit.merge(*sil), U.tex_mli(62, seams=1, depth=0.4), tile=1.3))
    if osr:
        p.append(U.tpart(kit, "mirror radiators", OSR, kit.merge(*osr), U.tex_panels(3, 3, seed=63, line=2.0), tile=1.25))
    # the keel tripod: three struts from the bottom to an apex 1.0 m below
    apex = np.array([0.0, 0.0, -hz - 1.0])
    legs = [kit.rod((sx * hx * 0.9, sy * hy * 0.85, -hz), apex, 0.05, n=8)
            for sx, sy in ((-1, -1), (-1, 1), (1, 0))]
    legs.append(kit.rod((-hx * 0.9, -hy * 0.85, -hz), (-hx * 0.9, hy * 0.85, -hz - 0.02), 0.04, n=6))
    p.append(kit.part("keel tripod", STRUT, *legs))
    tr = [U.trunnion(kit, apex, (0, 0, -1), 0.25, 0.05)]
    tr += [U.trunnion(kit, (0.0, sy * (hy + 0.03), -0.35), (0, sy, 0), 0.30, 0.041) for sy in (-1, 1)]
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *tr))
    # the grapple fixture on its yellow triangular plate, +X face near +Y
    tri = kit.prism([(-0.30, -0.45), (0.30, -0.45), (0.0, 0.55)], 0.0, 0.03)
    R = U.frame_from((1, 0, 0), (0, 0, 1))
    p.append(kit.part("grapple plate (yellow)", YELLOW, kit.move(kit.turn(tri, R), (hx + 0.03, 1.75, 0.05))))
    for name, rgb, m in U.frgf(kit, (hx + 0.06, 1.75, -0.15), (1, 0, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    # S-band and GPS antennas on the top corners
    ant = [kit.rod((hx - 0.2, sy * (hy - 0.15), hz), (hx - 0.2, sy * (hy - 0.15), hz + 0.35), 0.03, n=6)
           for sy in (-1, 1)]
    p.append(kit.part("antennas", (0.85, 0.85, 0.85), *ant))
    return p
