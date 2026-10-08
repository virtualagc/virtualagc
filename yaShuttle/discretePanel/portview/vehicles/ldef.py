"""The Long Duration Exposure Facility (NORAD 14898), as deployed by
STS-41C (April 1984) and retrieved by STS-32 (January 1990).

LDEF was a 12-sided open frame of aluminium rings and longerons, 30 ft
(9.14 m) long and 14 ft (4.27 m) across, carrying 86 experiment trays: 72
on the sides (12 rows, 6 bays along the length, each tray ~34 x 50 in,
0.86 x 1.27 m) and 14 on the ends (6 on the Earth end, 8 on the space
end).  It flew gravity-gradient stabilised, long axis vertical, with row 9
facing the ram and row 3 the wake.  Two grapple fixtures, a passive FRGF
and the active one whose rigidize signal started the experiments, sat on
the side; the payload-bay trunnions stood out of the centre ring.

Tray finishes are a deterministic pattern of the families the 41C and
STS-32 photographs show (black anodise, mirror/silver, white paint, gold
foil, blue cells, grey composites), not each tray's real one.  After 5.7
years the trays were dulled and the ram side frosted; this model is the
fresh 1984 look.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'ldef'

N = 12
APOTHEM = 2.10                  # ~4.27 m across the corners
LENGTH = 9.14
BAYS = 6
# finishes, by tray: dark anodise, specular aluminium, white, gold, cells, grey
FIN = dict(dark=(0.05, 0.05, 0.06), mirror=(0.50, 0.52, 0.56), white=(0.78, 0.78, 0.75),
           gold=(0.70, 0.55, 0.28), cells=(0.05, 0.06, 0.14), grey=(0.25, 0.25, 0.26),
           copper=(0.55, 0.32, 0.18))
PATTERN = ("dark", "mirror", "dark", "grey", "white", "dark", "mirror", "gold", "dark",
           "grey", "mirror", "cells", "dark", "white", "copper", "dark", "mirror", "grey")


def build(kit):
    side = 2 * APOTHEM * math.tan(math.pi / N)
    x0, x1 = -LENGTH / 2, LENGTH / 2
    rings = np.linspace(x0, x1, BAYS + 1)
    R_corner = APOTHEM / math.cos(math.pi / N)
    faces = U.ngon_face_frames(N, APOTHEM)
    trays = {k: [] for k in FIN}
    frame = []
    ring_w, ring_d = 0.10, 0.10
    # frame: a ring of 12 flat bars at each station, a longeron at each corner
    for x in rings:
        frame.append(U.ngon_prism(kit, N, APOTHEM + 0.005, x - ring_w / 2, x + ring_w / 2, caps=False))
    corner_a = [2 * math.pi * k / N - math.pi / N for k in range(N)]
    for a in corner_a:
        c = np.array([0.0, R_corner * math.cos(a), R_corner * math.sin(a)])
        frame.append(kit.rod(c + (x0, 0, 0), c + (x1, 0, 0), 0.05, n=6))
    # side trays, 0.03 m in from the face, between rings and longerons
    i = 0
    for k, (nrm, pc) in enumerate(faces):
        R = U.frame_from(nrm, (1.0, 0.0, 0.0))
        for b in range(BAYS):
            xm = 0.5 * (rings[b] + rings[b + 1])
            L = rings[b + 1] - rings[b] - ring_w - 0.04
            fin = PATTERN[(7 * k + 5 * b + (k * b) % 4) % len(PATTERN)]
            # face-local: x out, y = along X? frame_from(nrm, up=X) gives z ~ +X
            m = kit.box((0.04, side - 0.16, L), (-0.04, 0, 0))
            trays[fin].append(kit.move(kit.turn(m, R), pc + (xm, 0, 0)))
            i += 1
    # the inner skin: closes the frame behind the trays
    inner = U.ngon_prism(kit, N, APOTHEM - 0.12, x0 + 0.02, x1 - 0.02, fine=0.5)
    # end frames: a 12-sided plate at each end, set in 0.03 m, with trays on it
    ends = [U.ngon_prism(kit, N, APOTHEM - 0.02, x0 - 0.03, x0 - 0.01, fine=0.5),
            U.ngon_prism(kit, N, APOTHEM - 0.02, x1 + 0.01, x1 + 0.03, fine=0.5)]
    end_trays = []
    for sgn, count in ((+1, 8), (-1, 6)):
        xs = x1 + 0.055 if sgn > 0 else x0 - 0.055
        cols = (-1.25, 0.0, 1.25) if count == 6 else (-1.35, -0.45, 0.45, 1.35)
        slots = [(y, z) for y in cols for z in (-0.57, 0.57)]
        for j, (y, z) in enumerate(slots):
            fin = PATTERN[(3 * j + (5 if sgn > 0 else 11)) % len(PATTERN)]
            trays[fin].append(kit.box((0.04, 0.82 if count == 8 else 1.10, 1.02), (xs, y, z)))
        # the centre spine across the end
        end_trays.append(kit.box((0.05, 3.9, 0.10), (xs + 0.01 * sgn, 0, 0)))
    parts = [kit.part("LDEF frame (aluminium)", (0.60, 0.60, 0.60), *frame),
             kit.part("LDEF inner skin", (0.08, 0.08, 0.08), inner),
             kit.part("LDEF end plates", (0.22, 0.22, 0.23), *ends),
             kit.part("LDEF end spines", (0.60, 0.60, 0.60), *end_trays)]
    # each finish its own surface detail: sample plates in a grid, the cell
    # modules, the blankets' wrinkles
    TEX = dict(dark=U.tex_panels(3, 2, seed=1, spread=0.35, line=0.5), mirror=U.tex_panels(2, 2, seed=2, spread=0.3),
               white=U.tex_panels(4, 3, seed=3, spread=0.15), gold=U.tex_mli(4, seams=1, depth=0.4),
               cells=U.tex_cells(6, 8, line=0.4), grey=U.tex_panels(5, 4, seed=5, spread=0.4, line=0.4),
               copper=U.tex_panels(2, 3, seed=6, spread=0.3))
    for fin, ms in trays.items():
        if ms:
            parts.append(U.tpart(kit, "trays: " + fin, FIN[fin], kit.merge(*ms), TEX[fin], tile=0.9, fine=0.5))
    # two grapple fixtures on row 1's face (the active one and an FRGF), and
    # the trunnions out of the centre ring on rows 4 and 10, a keel on row 7
    nrm, pc = faces[0]
    fx = []
    for xb, active in ((rings[1] + 0.05, True), (rings[5] - 0.05, False)):
        fx += U.frgf(kit, pc + nrm * 0.0 + (xb, 0, 0) + nrm * 0.02, nrm, (1, 0, 0), active)
    for name, rgb, m in fx:
        parts.append(kit.part(name, rgb, m))
    tr = []
    for k in (3, 9):
        nrm, pc = faces[k]
        tr.append(U.trunnion(kit, pc + nrm * 0.03, nrm, 0.30, 0.041))
    nrm, pc = faces[6]
    tr.append(U.trunnion(kit, pc + nrm * 0.03, nrm, 0.25, 0.04))
    parts.append(kit.part("trunnions", (0.75, 0.75, 0.75), *tr))
    return dict(meta=dict(name="Long Duration Exposure Facility (LDEF)",
                          frame="LDEF: +X along the axis toward the space end (the Earth end -X), "
                                "+Y out of row 1's face (the grapple fixtures' row), rows numbered "
                                "round +X; m; the middle (its mass was spread nearly evenly)",
                          source="simple shapes to published dimensions (NASA LDEF fact sheets, "
                                 "STS-41C/STS-32 photographs)",
                          norad=14898, mag_1000km=1.8),
                parts=U.refine_parts(parts))
