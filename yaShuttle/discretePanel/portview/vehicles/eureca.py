"""EURECA, the European Retrievable Carrier (NORAD 22065): deployed by
STS-46 (August 1992), retrieved by STS-57 (June 1993).

A box of carbon-fibre struts and titanium nodes, 4.6 m across the payload
bay (Y), 2.6 m along it (X) and ~2.3 m deep (Z), almost wholly in multilayer
blanket (silver-white; it came home yellowed), with painted boxes on the
keel side, the experiments on the top deck, an FRGF on the +Y face and
the payload-bay trunnions.  Its two solar wings (five panels each, ~7.5 m
by 2.9 m; 20 m tip to tip deployed) folded against the +-X faces.

ARRAYS_DEPLOYED picks the configuration: False (the default) is the
STS-57 retrieval -- the wings already retracted and latched, the
folded stacks on the +-X faces, and the two communication antennas standing
up off the top deck (the EVA crew pushed them home before berthing);
True is the free-flying vehicle STS-46 released.

Dimensions: eoPortal (bus 4.6 x 2.6 m, 20 m span, 99 m^2 of array
front and back); proportions and finishes from sts046-76-028,
sts046-102-021, sts057-93-052 and the Astrotech processing photo s92-41442.
"""
import numpy as np

from . import _leo_util as U

KEY = 'eureca'
ARRAYS_DEPLOYED = False

DX, DY, DZ = 2.6, 4.6, 2.3
MLI = (0.66, 0.64, 0.58)            # aged silver-white blanket
WHITE = (0.80, 0.80, 0.78)
YELLOW = (0.80, 0.62, 0.12)


def build(kit):
    p = []
    hx, hy, hz = DX / 2, DY / 2, DZ / 2
    # the body: the blanketed box, its blanket standing 1 cm proud of the
    # strut frame whose corners show
    p.append(U.tpart(kit, "blankets", MLI, kit.box((DX, DY, DZ)), U.tex_mli(11), tile=1.3, fine=0.4))
    edges = []
    for sy in (-1, 1):
        for sz in (-1, 1):
            edges.append(kit.box((DX + 0.04, 0.06, 0.06), (0, sy * hy, sz * hz)))
    for sx in (-1, 1):
        for sz in (-1, 1):
            edges.append(kit.box((0.06, DY + 0.04, 0.06), (sx * hx, 0, sz * hz)))
        for sy in (-1, 1):
            edges.append(kit.box((0.06, 0.06, DZ + 0.04), (sx * hx, sy * hy, 0)))
    p.append(kit.part("frame edges", (0.30, 0.30, 0.32), *edges))
    # keel side (-Z): painted electronics boxes and the radiators
    boxes = [kit.box((0.8, 1.0, 0.25), (-0.6, -1.4, -hz - 0.125)),
             kit.box((0.7, 0.9, 0.30), (0.6, -1.3, -hz - 0.15)),
             kit.box((0.9, 1.2, 0.20), (0.5, 1.2, -hz - 0.10)),
             kit.box((0.6, 0.8, 0.28), (-0.7, 1.5, -hz - 0.14))]
    p.append(U.tpart(kit, "keel-side boxes (white paint)", WHITE, kit.merge(*boxes), U.tex_panels(3, 3, seed=7), tile=0.8))
    rad = [kit.box((0.02, 2.0, 1.2), (sx * (hx + 0.012), 0.9, 0.25)) for sx in (-1, 1)] if ARRAYS_DEPLOYED else []
    rad.append(kit.box((1.8, 0.02, 1.4), (0.0, -hy - 0.012, 0.2)))
    p.append(kit.part("radiators", (0.85, 0.85, 0.85), *rad))
    # top deck (+Z): the experiments -- the solar instruments (SOSP),
    # ORA's cylinder, the Wide Angle Telescope, boxes under blankets
    top = [kit.box((1.0, 1.4, 0.45), (-0.5, -1.4, hz + 0.225)),
           kit.box((0.8, 0.9, 0.35), (0.6, -1.5, hz + 0.175)),
           kit.box((1.1, 1.1, 0.55), (0.2, 0.2, hz + 0.275)),
           kit.box((0.7, 0.7, 0.30), (-0.7, 1.4, hz + 0.15))]
    p.append(U.tpart(kit, "top-deck experiments", MLI, kit.merge(*top), U.tex_mli(12, seams=1), tile=0.9))
    cyl = [kit.along(kit.cylinder(0.35, 0.0, 1.30, n=24), (1, 0, 0), (-0.65, 1.3, hz + 0.40)),
           kit.along(kit.cylinder(0.18, 0.0, 0.70, n=16), (0, 0, 1), (0.75, 1.3, hz))]
    p.append(kit.part("experiment cylinders (white)", WHITE, *cyl, smooth=True))
    p.append(kit.part("cylinder ends", (0.25, 0.25, 0.25),
                      kit.move(kit.disc(0.30, 0.0, n=24), (0.655, 1.3, hz + 0.40)),
                      kit.move(kit.turn(kit.disc(0.15, 0.0, n=16), kit.rot('y', -90)), (0.75, 1.3, hz + 0.705))))
    # the yellow triangle (a thermal/radiator panel) and sun sensor on +Y
    tri = kit.prism([(-0.6, -0.7), (0.6, -0.7), (0.0, 0.7)], 0.0, 0.02)
    p.append(kit.part("yellow panel", YELLOW,
                      kit.move(kit.turn(tri, U.frame_from((0, 1, 0), (0, 0, 1))), (0.6, hy + 0.01, 0.2))))
    # grapple fixture on +Y, trunnions on +-X... the longeron trunnions stand
    # out of the +-Y faces (EURECA rode across the bay), the keel pin below
    for name, rgb, m in U.frgf(kit, (-0.5, hy + 0.01, 0.4), (0, 1, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    tr = [U.trunnion(kit, (sx * 0.9, sy * (hy + 0.01), -0.6), (0, sy, 0), 0.25, 0.041)
          for sx in (-1, 1) for sy in (-1, 1)]
    tr.append(U.trunnion(kit, (0.0, 0.0, -hz), (0, 0, -1), 0.55, 0.05))
    p.append(kit.part("trunnions", (0.75, 0.75, 0.75), *tr))
    # the solar wings on the +-X faces
    cells, backs, yokes = [], [], []
    for sx in (-1, 1):
        if ARRAYS_DEPLOYED:
            root = np.array([sx * (hx + 1.05), 0.0, 0.0])
            yokes.append(kit.rod((sx * hx, -0.9, 0.0), root + (0, -0.9, 0), 0.04))
            yokes.append(kit.rod((sx * hx, 0.9, 0.0), root + (0, 0.9, 0), 0.04))
            yokes.append(kit.rod((sx * hx, -0.9, 0.0), root + (0, 0.9, 0), 0.03))
            w = U.solar_wing(kit, root, (sx, 0, 0), (0, 1, 0), 7.45, 2.9, panels=5,
                             face=(0, 0, 1))
            cells.append(w[0][2])
            backs.append(w[1][2])
        else:
            # the folded stack: five panels, 2.9 x 1.5 m, 0.30 m deep, with
            # the panel edges (cells inward, backs out) showing as stripes
            for k in range(5):
                x = sx * (hx + 0.04 + 0.06 * k + 0.03)
                backs.append(kit.box((0.05, 2.9, 1.5), (x, 0.0, 0.05)))
            yokes.append(kit.box((0.04, 3.0, 0.10), (sx * (hx + 0.36), 0.0, 0.85)))
            yokes.append(kit.box((0.04, 3.0, 0.10), (sx * (hx + 0.36), 0.0, -0.75)))
    if cells:
        p.append(kit.part("solar cells", U.CELLS, *cells))
    p.append(kit.part("solar panel backs" if ARRAYS_DEPLOYED else "folded solar panels",
                      (0.04, 0.05, 0.10) if not ARRAYS_DEPLOYED else U.CELLS_BACK, *backs))
    p.append(kit.part("array yokes and tie-downs", (0.55, 0.55, 0.56), *yokes))
    if not ARRAYS_DEPLOYED:
        # the two communication antennas, up off the top deck before EVA latched them
        ant = []
        for y, tilt in ((-0.4, 25.0), (0.9, -35.0)):
            base = np.array([0.95, y, hz])
            d = np.array([np.sin(np.radians(tilt)) * 0.3, 0.0, 1.0])
            d /= np.linalg.norm(d)
            ant.append(kit.rod(base, base + 1.1 * d, 0.03, n=8))
            ant.append(kit.along(kit.frustum(0.05, 0.28, 0.0, 0.18, n=16), d, base + 1.1 * d))
        p.append(kit.part("communication antennas", (0.80, 0.80, 0.80), *ant))
    return dict(meta=dict(name="EURECA (European Retrievable Carrier)" +
                          (" (arrays deployed)" if ARRAYS_DEPLOYED else " (arrays folded, as STS-57 retrieved it)"),
                          frame="EURECA: +X along the solar wings' axis (along the payload bay when "
                                "berthed), +Y across the bay (the grapple fixture's face), +Z the top "
                                "deck (the experiments); m; the box's centre (the mass is spread "
                                "through the frame)",
                          source="simple shapes to published dimensions (eoPortal) and STS-46/57 photographs",
                          norad=22065, mag_1000km=1.0 if ARRAYS_DEPLOYED else 2.0),
                parts=U.refine_parts(p))
