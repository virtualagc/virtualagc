"""The Space Flyer Unit (NORAD 23521), as STS-72 retrieved it in January
1996: launched by Japan's H-II in March 1995, it had flown ten months; its
two solar array paddles failed to latch after retraction and were
jettisoned before capture, so Endeavour's arm took a bare octagon.

SFU (Mitsubishi, for ISAS/NASDA/USEF): an octagonal truss 4.46 m across
the corners (4.12 m across the flats), 1.68 m deep, eight trapezoid
payload bays round it; ~3.0 m tall overall with the experiments on its
top deck (NASDA/globalsecurity: 3.0 m).  One end (+X here, the bottom
deck: the H-II adapter end, away from the Sun) is eight triangular
radiator sectors round a 1.5 m gold disc; the other (-X, the top deck,
which flew facing the Sun) carries the experiments -- the 2-D array's
1.5 m blue cell panel on its gold box, silver-blanketed packages either
side, equipment below, the grapple fixture near the top rim.  Crumpled
orange-gold Kapton blanket over nearly everything else.

What decided what (NASA photographs, STS-72):
* STS072-720-076 (side view, square on to the -Z face, -X end to the
  right; images.nasa.gov): the truss's depth (1.68 m = 415 px against the
  4.12 m across the flats = 1020 px), the bays seen -- the white radiator
  (0.77 x 1.46 m, red marks at two corners) on -Z, the black panel on the
  +Y-Z face and the blue cells on the -Y-Z face, the gold end rings, the
  four trunnion pins on the +-Y flats near each end ring with their gold
  scuff plates, and the experiments standing up to 0.93 m off the top deck
  (the 2-D array box) with the grey dish antenna 0.6 m to -Y of centre.
* STS072-734-018 (EOL original scan; the top deck end on, on the arm):
  flats on +-Y and +-Z (pins left and right), the blue 2-D array panel
  1.48 x 1.56 m with five black stripes, centred 0.42 m to -Y and 0.13 m
  up; the silver packages either side, the gold sectors above, the
  equipment below, the arm on the grapple fixture at the top rim.
* sts072-720-042 (the bottom deck end on, arrays still out): eight
  sectors at 45 deg, alternately plain white panels and silver OSR panels
  with white tiles (four white, three tiled, one with a silver cone --
  taken to be IRTS's sunshade), the 1.5 m gold disc with four small white
  squares, gold radial beams to the corners.  The camera's roll on that
  end is not certain, so which sector holds what is matched to the
  others' faces only approximately.
* STS072-734-011: the top deck obliquely (the blue panel on its gold box,
  more blue cell patches on the side bays).
The far side bays (+Y, +Z, +Y+Z, -Y+Z) are not seen squarely in any
photograph found; they are filled with the same kinds of panel.
"""
import math

import numpy as np

from . import _leo_util as U
from . import _cgro_util as C

KEY = 'sfu'

N = 8
APOTHEM = 2.06                 # 4.46 m across the corners
X0, X1 = -0.84, 0.84           # the truss: -X the top deck (experiments), +X the bottom deck
GOLD = (0.92, 0.55, 0.16)      # orange-gold Kapton (720-076: linear 1 : 0.6 : 0.18)
WHITE = (0.78, 0.85, 0.84)     # 720-076's radiator, a little green-blue
SILVER = (0.62, 0.64, 0.68)
BLUE = (0.05, 0.07, 0.13)      # 720-076's cells
R_C = APOTHEM / math.cos(math.pi / N)
SIDE = 2 * APOTHEM * math.tan(math.pi / N)       # 1.71 m


def _face(k):
    """Face k's (outward normal, centre at x=0, along-face unit vector):
    normal at 45k deg from +Y toward +Z."""
    t = math.radians(45.0 * k)
    n = np.array([0.0, math.cos(t), math.sin(t)])
    w = np.array([0.0, -math.sin(t), math.cos(t)])
    return n, n * APOTHEM, w


def _on_face(kit, k, xc, wc, dx, dw, h, off):
    """A box on face k: dx along X, dw along the face, h thick, its inner
    side `off` out from the face plane, centred at xc, wc."""
    n, c, w = _face(k)
    R = np.column_stack([n, w, np.cross(n, w)])     # local x out, y along the face, z ~ +-X
    m = kit.box((h, dw, dx), (off + h / 2, wc, 0.0))     # cross(n, w) is +X for every face
    p = kit.move(kit.turn(m, R), c)
    return kit.move(p, (xc, 0, 0))


def _tiles():
    """Silver OSR panel with groups of white tiles (as 720-042 shows)."""
    from PIL import Image
    s = 256
    yy, xx = (np.mgrid[0:s, 0:s] + 0.5) / s
    v = np.full((s, s), 0.62)
    for cx, cy in ((0.3, 0.3), (0.7, 0.3), (0.3, 0.7), (0.7, 0.7)):
        box = (np.abs(xx - cx) < 0.16) & (np.abs(yy - cy) < 0.16)
        v[box] = 1.0
        fx, fy = ((xx - cx + 0.16) * 12) % 1, ((yy - cy + 0.16) * 12) % 1
        v[box & ((fx < 0.08) | (fy < 0.08))] = 0.75
    return Image.fromarray((np.clip(v, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)).convert("RGB")


def _stripes():
    """The 2-D array panel: blue cells, five black stripes along Z, a white
    border (u along Y, v along Z, one repeat the panel)."""
    from PIL import Image
    s = 256
    yy, xx = (np.mgrid[0:s, 0:s] + 0.5) / s
    fx, fy = (xx * 16) % 1, (yy * 30) % 1
    v = np.where((fx < 0.06) | (fy < 0.05), 1.6, 1.0)
    rgb = np.stack([v] * 3, -1)
    for c in (0.15, 0.33, 0.47, 0.70, 0.86):
        rgb[(np.abs(xx - c) < 0.012) & (yy > 0.15) & (yy < 0.92)] = 0.12
    edge = (xx < 0.03) | (xx > 0.97) | (yy < 0.03) | (yy > 0.97)
    rgb[edge] = 4.0
    rgb = rgb / rgb.max()
    return Image.fromarray((np.clip(rgb, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))


def _decal(kit, name, rgb, mesh, image, centre, axes, size):
    """A textured part whose one repeat exactly covers `size` (u, v) centred
    on `centre` (planar map along `axes`)."""
    c = np.asarray(centre, float)
    m, uv = U.planar_uv(kit.move(mesh, -c), (size[0], size[1]), axes)
    uv = uv + 0.5
    return kit.part(name, rgb, kit.move(m, c), texture=image, uv=uv.astype(np.float32))


def build(kit):
    p = []
    gold_tex = C.tex_blanket(seed=41, crinkle=3.0, depth=0.45, seams=2, glints=0.6, tint=(1.0, 0.95, 0.85))
    # ------------------------------------------------------------ the truss
    body = U.ngon_prism(kit, N, APOTHEM, X0, X1, phase_deg=0.0, caps=False, fine=0.4)
    p.append(U.tpart(kit, "payload bays (gold blanket)", GOLD, body, gold_tex, tile=1.2))
    lon = []
    for k in range(N):
        a = math.radians(45.0 * k) - math.pi / N
        c = np.array([0.0, R_C * math.cos(a), R_C * math.sin(a)])
        lon.append(kit.rod(c + (X0 - 0.02, 0, 0), c + (X1 + 0.02, 0, 0), 0.05, n=6))
    # the end rings, 0.16 m deep (720-076), standing 3 cm proud of the bays
    lon.append(U.ngon_prism(kit, N, APOTHEM + 0.03, X1 - 0.16, X1, caps=False))
    lon.append(U.ngon_prism(kit, N, APOTHEM + 0.03, X0, X0 + 0.16, caps=False))
    p.append(U.tpart(kit, "truss rings and longerons (gold blanket)", (0.85, 0.52, 0.16), kit.merge(*lon),
                     C.tex_blanket(seed=43, crinkle=2.0, depth=0.35, seams=0, glints=0.4), tile=0.8))
    # --------------------------------------------------- the side bays' panels
    # 720-076: -Z (k=6) a white radiator 0.77 x 1.46 m with red marks; the
    # +Y-Z face (k=7) a black panel with a darker square; -Y-Z (k=5) blue
    # cells 0.8 x 1.2 m.  The far faces carry the same kinds.
    white, black, cells, silver = [], [], [], []
    marks = []
    for k, kind in ((6, 'white'), (2, 'white'), (7, 'black'), (3, 'black'), (5, 'cells'), (1, 'cells')):
        if kind == 'white':
            white.append(_on_face(kit, k, 0.0, 0.0, 0.77, 1.46, 0.02, 0.005))
            for wc in (-0.66, 0.66):
                marks.append(_on_face(kit, k, -0.31 if wc < 0 else 0.31, wc, 0.08, 0.08, 0.004, 0.026))
        elif kind == 'black':
            black.append(_on_face(kit, k, 0.0, 0.0, 0.95, 1.40, 0.02, 0.005))
        else:
            cells.append(_on_face(kit, k, 0.0, 0.0, 0.85, 1.25, 0.02, 0.005))
    for k in (0, 4):                    # the paddles' faces: small silver radiators between the latches
        silver.append(_on_face(kit, k, 0.0, 0.0, 0.70, 0.60, 0.02, 0.005))
    p.append(U.tpart(kit, "bay radiators (white)", WHITE, kit.merge(*white), C.tex_osr(4, 8, seed=44, base=0.95, spread=0.08),
                     tile=0.77))
    p.append(kit.part("radiator marks (red)", (0.55, 0.07, 0.05), *marks))
    p.append(kit.part("bay panels (black)", (0.06, 0.045, 0.035), *black,
                      *[_on_face(kit, k, 0.05, 0.25, 0.45, 0.45, 0.004, 0.026) for k in (7, 3)]))
    p.append(U.tpart(kit, "bay solar cells", BLUE, kit.merge(*cells), C.tex_cells(8, 12, seed=45, line=0.45), tile=0.85))
    p.append(U.tpart(kit, "bay radiators (silver)", SILVER, kit.merge(*silver), C.tex_osr(6, 6, seed=46), tile=0.6))
    # ---------------------------------------------- +X: the bottom deck's sectors
    tiles = _tiles()
    p.append(kit.part("bottom-deck floor", (0.20, 0.14, 0.06), U.ngon_prism(kit, N, APOTHEM - 0.02, X1 - 0.12, X1 - 0.10,
                                                                             fine=0.4)))
    sec = {"white": [], "tiles": []}
    # 720-042, going round: white, tiles, (cone), white, white, tiles, tiles, white
    kinds = ("white", "tiles", None, "white", "white", "tiles", "tiles", "white")   # k=2: the cone's bay, open
    xs = X1 - 0.05
    for k in range(N):
        a0 = math.radians(45.0 * k) - math.pi / N + 0.05
        a1 = math.radians(45.0 * (k + 1)) - math.pi / N - 0.05
        r0, r1 = 0.80, R_C - 0.16
        pts = [(r0 * math.cos(a0), r0 * math.sin(a0)), (r1 * math.cos(a0), r1 * math.sin(a0)),
               (r1 * math.cos(a1), r1 * math.sin(a1)), (r0 * math.cos(a1), r0 * math.sin(a1))]
        if kinds[k]:
            sec[kinds[k]].append(kit.prism(pts, xs - 0.025, xs))
    p.append(U.tpart(kit, "bottom-deck radiators (white)", WHITE, kit.merge(*sec["white"]),
                     C.tex_osr(6, 6, seed=47, base=0.95, spread=0.06), tile=0.9, axes=((0, 1, 0), (0, 0, 1))))
    p.append(U.tpart(kit, "bottom-deck radiators (OSR, white tiles)", (0.70, 0.72, 0.75), kit.merge(*sec["tiles"]),
                     tiles, tile=1.1, axes=((0, 1, 0), (0, 0, 1))))
    # the gold disc in the middle with its four small white squares
    p.append(U.tpart(kit, "bottom-deck disc (gold blanket)", GOLD, kit.cylinder(0.75, X1 - 0.08, X1 + 0.04, n=40),
                     gold_tex, tile=0.8))
    p.append(kit.part("disc sensors (white)", (0.85, 0.85, 0.85),
                      *[kit.box((0.03, 0.13, 0.13), (X1 + 0.06, 0.30 * math.cos(a), 0.30 * math.sin(a)))
                        for a in (0, math.pi / 2, math.pi, 1.5 * math.pi)]))
    # gold beams from the disc to the corners, standing just off the sectors
    beams = []
    for k in range(N):
        a = math.radians(45.0 * k) - math.pi / N
        beams.append(kit.rod((X1 + 0.02, 0.74 * math.cos(a), 0.74 * math.sin(a)),
                             (X1 + 0.02, (R_C - 0.08) * math.cos(a), (R_C - 0.08) * math.sin(a)), 0.05, n=6))
    # and the two diagonal braces 720-042 shows across the sectors
    for s in (-1, 1):
        beams.append(kit.rod((X1 + 0.03, s * 0.55, -0.55), (X1 + 0.03, s * 1.85, 0.40), 0.035, n=6))
    p.append(kit.part("bottom-deck beams (gold)", (0.85, 0.52, 0.16), *beams))
    # the silver cone in the +Z sector (IRTS's sunshade, as taken here)
    # (720-076 shows nothing standing far off this end: the cone sits mostly
    # down in its bay, its lip 8 cm out)
    cone_c = (X1 - 0.35, 0.0, 1.35)
    cone = kit.move(kit.frustum(0.24, 0.50, 0.0, 0.43, n=28, caps=False), cone_c)
    p.append(kit.part("IRTS sunshade (silver)", (0.72, 0.73, 0.75), cone, U.flip(cone), smooth=True))
    p.append(kit.part("IRTS aperture", (0.05, 0.05, 0.06), kit.move(kit.disc(0.23, 0.01, n=24), cone_c)))
    p.append(kit.part("bottom-deck box (black)", (0.05, 0.05, 0.06),
                      kit.box((0.25, 0.30, 0.55), (X1 + 0.06, 1.55 * math.cos(math.radians(150)),
                                                   1.55 * math.sin(math.radians(150))))))
    # ------------------------------------------------- -X: the top deck's experiments
    xd = X0
    deck = U.ngon_prism(kit, N, APOTHEM - 0.05, xd - 0.03, xd - 0.005, fine=0.4)
    p.append(U.tpart(kit, "top deck (gold blanket)", GOLD, deck, gold_tex, tile=1.2))
    # the 2-D array's box (0.93 m out, 734-018 / 720-076) and its blue panel
    bx, by, bz = 0.90, 1.50, 1.60
    bc = (xd - 0.035 - bx / 2, -0.38, 0.13)
    p.append(U.tpart(kit, "2-D array box (gold blanket)", GOLD, kit.box((bx, by, bz), bc), gold_tex, tile=0.9, fine=0.4))
    panel = kit.box((0.02, 1.48, 1.56), (bc[0] - bx / 2 - 0.015, bc[1], bc[2]))
    p.append(_decal(kit, "2-D array panel (blue cells)", (0.14, 0.22, 0.42), panel, _stripes(),
                    (bc[0] - bx / 2 - 0.015, bc[1], bc[2]), ((0, -1, 0), (0, 0, -1)), (1.48, 1.56)))
    # silver-white blanketed packages either side (734-018; 720-076's lumps)
    sil = [kit.box((0.85, 0.70, 1.40), (xd - 0.035 - 0.425, 0.75, 0.05)),
           kit.box((0.50, 0.55, 1.50), (xd - 0.035 - 0.25, -1.50, -0.10)),
           kit.box((0.60, 0.80, 0.55), (xd - 0.035 - 0.30, 0.60, -1.20))]
    p.append(U.tpart(kit, "experiment packages (silver blanket)", (0.75, 0.76, 0.78), kit.merge(*sil),
                     C.tex_blanket(seed=48, crinkle=3.0, depth=0.45, seams=1, glints=0.8), tile=0.8))
    # the box off the +Y side (720-076 top: dark, an orange edge) and the
    # gold one off -Y (720-076 bottom), equipment boxes below
    p.append(U.tpart(kit, "experiment box (dark)", (0.10, 0.10, 0.11), kit.box((0.65, 0.55, 0.55), (xd - 0.035 - 0.325, 1.55, -0.35)),
                     C.tex_grid_panel(nx=4, ny=4, seed=49), tile=0.6))
    eq = [kit.box((0.62, 0.40, 0.50), (xd - 0.035 - 0.31, -1.35, -1.12)),
          kit.box((0.35, 1.00, 0.45), (xd - 0.035 - 0.175, -0.40, -1.25)),
          kit.box((0.30, 0.70, 0.35), (xd - 0.035 - 0.15, 0.75, 1.30)),
          kit.box((0.25, 0.60, 0.40), (xd - 0.035 - 0.125, -1.20, 1.25))]
    p.append(U.tpart(kit, "equipment boxes (gold blanket)", GOLD, kit.merge(*eq), gold_tex, tile=0.6))
    # a boom along the deck (720-076's gold bar) and the grey dish antenna
    p.append(kit.part("deck boom", (0.85, 0.52, 0.16),
                      kit.rod((xd - 0.05, 1.05, 0.95), (xd - 0.90, 1.05, 0.95), 0.05, n=8)))
    dish_c = np.array([xd - 0.30, -0.61, -1.60])
    p.append(kit.part("dish antenna (grey)", (0.42, 0.43, 0.45),
                      kit.along(kit.frustum(0.05, 0.19, 0.0, 0.07, n=24, caps=False), (0, 0, -1), dish_c),
                      kit.along(kit.disc(0.05, 0.0, n=12), (0, 0, 1), dish_c), smooth=True))
    p.append(kit.part("dish mount", (0.55, 0.55, 0.56), kit.rod(dish_c + (0, 0, 0.0), (xd - 0.03, -0.61, -1.45), 0.03, n=6)))
    # the grapple fixture at the top rim of the top deck, standing out along -X
    for name, rgb, m in U.frgf(kit, (xd - 0.035, 0.0, 1.70), (-1, 0, 0), (0, 0, 1)):
        p.append(kit.part(name, rgb, m))
    # ------------------------------ trunnion pins and the paddles' latches (+-Y)
    tr, plates, br = [], [], []
    for sy in (-1, 1):
        for x in (X1 - 0.10, X0 + 0.12):
            tr.append(U.trunnion(kit, (x, sy * (APOTHEM + 0.03), 0.0), (0, sy, 0), 0.20, 0.041))
            plates.append(kit.box((0.45, 0.03, 0.30), (x + (-0.12 if x > 0 else 0.12), sy * (APOTHEM + 0.05), 0.0)))
        # what the jettisoned paddle left: its latch brackets mid-face
        br.append(kit.box((0.30, 0.18, 0.36), (0.0, sy * (APOTHEM + 0.08), 0.55)))
        br.append(kit.box((0.30, 0.18, 0.36), (0.0, sy * (APOTHEM + 0.08), -0.55)))
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *tr))
    p.append(kit.part("trunnion scuff plates (gold)", (0.70, 0.50, 0.18), *plates))
    p.append(kit.part("paddle latch brackets", (0.50, 0.50, 0.52), *br))
    return dict(meta=dict(name="Space Flyer Unit (SFU), arrays jettisoned, as STS-72 retrieved it",
                          frame="SFU: +X along the octagon's axis out of the bottom deck (the radiator "
                                "sectors and gold disc; anti-Sun), -X out of the top deck (the "
                                "experiments; flown Sun-facing); +Y and -Y the flats that carried the "
                                "array paddles (jettisoned) and the four trunnion pins (moved here from "
                                "+-Z, after STS072-720-076/734-018); flats on +-Y and +-Z; m; the "
                                "octagon's centre",
                          source="simple shapes measured off STS072-720-076, STS072-734-018/011 and "
                                 "sts072-720-042; 4.46 m across the corners (JAXA)",
                          norad=23521, mag_1000km=2.0),
                parts=U.refine_parts(p))
