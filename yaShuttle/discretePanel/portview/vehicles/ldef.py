"""The Long Duration Exposure Facility (NORAD 14898), deployed by STS-41C
(7 April 1984) and retrieved by STS-32 (12 January 1990) after 5.7 years.

LDEF (NASA Langley) was a 12-sided open grid of aluminium rings and
longerons, 30 ft (9.14 m) long and 14 ft (4.27 m) across, carrying 86
experiment trays clamped into it: 72 round the sides (12 rows x 6 bays) and
14 on the ends (6 on the Earth end, 8 on the space end).  It flew gravity-
gradient stabilised, long axis vertical, row 9 leading and row 3 trailing.

What decided what:

* Layout -- NASA SP-473 (LDEF Mission 1 Experiments, 1984; NTRS
  19840016564) fig. 2, the experiment integration map, checked against
  NASA SP-531 (Photographic Survey of the LDEF Mission, 1996; NTRS
  19970017047) table 1, whose tray numbers are the flown ones (SP-531 is
  followed where they differ).  Rows are numbered 1-12 clockwise as seen
  facing the Earth end (the end with the support beam), bays A-F from the
  Earth end; Earth-end trays G2 ... G12 and space-end trays H1 ... H12 take
  the clock position (row) they face.  The 3 x 3 end grids, the Earth end's
  open middle row and the space end's covered centre are from the same
  map and from S32-85-081 (Earth end) and s32-541-018, STS032-85-008
  (space end).
* Structure -- SP-531 "Description of LDEF": centre ring the main load
  member, longerons to the end frames, intercostals between; four trunnions
  (two on the centre ring, two on the end support beam at the Earth end) and
  a keel pin on the centre ring; standard grapple fixture in tray C1 (with
  the black chevrons painted on its plate), the rigidize-sensing one that
  started the experiments in C10.  The trunnion scuff plates are on rows 3
  and 9 (SP-531 figs. 34-36 and A3), the keel-camera target in A6, so row 12
  was up and row 6 down in the payload bay (KSC-84PC-0219, the LDEF in
  Challenger's bay seen from above, shows C12's four fibre-optic coils on
  the top row and the C1 chevron tray one row over).  Peripheral trays 53 x
  42 in, end trays ~34 in square (SP-531); the centre ring ~0.30 m wide and
  the intercostals and end frames ~0.12 m, measured off KSC-84PC-0219 and
  s32-85-063 against the 53 in tray.  The end support beam is a triangle
  of tubes across the Earth end: from the apex fitting at the row-9 rim
  (its spindle and trunnion) one tube straight across, just clear of the
  hub, to the row-3 rim, one down to a node below the hub and one from
  the node back up to the row-3 rim, with a ribbed bow-tie web from the
  upper tube through the hub to the node (S32-85-081 and the 1990 KSC
  lift-out, GPN-2000-000676).  The Earth end's top row (toward row 12)
  holds the apertured G10, the mixed G12 and G2's dozen canisters, its
  bottom row two open, empty-looking boxes and a plain plate.  The side
  trunnions stand in D-shaped scuff plates, the tray clamps sit three to
  a tray edge along the longerons (Langley postflight EL-1994 series).
* Finishes -- per experiment, from SP-531's tray descriptions and the
  colour photographs 41c-36-1618, 41c-02-0067, 8898996, KSC-84PC-0219
  (1984) and s32-85-063, s32-541-018, STS032-85-008/-030/-039 (1990): the
  16 UHCRE trays (A0178) and F2 under wrinkled silvered-Teflon covers held
  by Velcro pads (they read white or sky-coloured); the 25 Space Debris
  Impact trays (S0001) and the frame chromic-anodised aluminium, a
  specular grey with pink and greenish-grey tints that looks black against
  space and pale against the Earth; Chemglaze A276 white on A0038, C12,
  F8, D4/D8's covers, G6, A0015's housings; graphite composites in A1/A7;
  the aluminised-Kapton modules of A0054 (B4, D10); the mirror-like IDE
  detectors; APEX's black-painted cell array in E9 (its primer showed
  reddish-brown by 1990); M0001's blanketed modules on the space end (H3,
  H12) and so on; mixed sample trays get a procedural coupon pattern.  The
  Earth end's thermal panels were black (SP-531, G2), the space end's
  anodised.  Interior surfaces Chemglaze Z306 black.

LOOK = "1990" (default) is the STS-32 rendezvous and retrieval: a light
brown film on the trailing rows (strongest on row 3), the scuff plates'
yellow gone to mustard, M0001's blankets shredded, E9's black paint eroded
to its primer and the A8 solar-cell plate lost (it flew beside the LDEF,
SP-531 fig. 21).  LOOK = "1984" gives the clean deployment look of STS-41C.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'ldef'

LOOK = "1990"

N = 12
APOTHEM = 2.10                  # 14 ft class: 4.20 m across the flats, 4.35 m across the corners
LENGTH = 9.14
END_W, CENTRE_W, INTER_W = 0.12, 0.30, 0.12
BAY = (LENGTH - 2 * END_W - CENTRE_W - 4 * INTER_W) / 6     # 1.353 m openings
TRAY_L, TRAY_W = 1.346, 1.067   # 53 x 42 in
END_TRAY, END_PITCH = 0.864, 0.944

ROW_UP, ROW_TRAIL, ROW_LEAD = 12, 3, 9


def _bay_x():
    """Centre X of bays A..F."""
    out, x = [], -LENGTH / 2 + END_W
    for b in range(6):
        out.append(x + BAY / 2)
        x += BAY + (CENTRE_W if b == 2 else INTER_W)
    return out


BAY_X = _bay_x()


def row_dir(r):
    """Outward unit normal of row r's face (row 1 +Y, rows round +X)."""
    t = math.radians(30.0 * (r - 1))
    return np.array([0.0, math.cos(t), math.sin(t)])


def row_tan(r):
    t = math.radians(30.0 * (r - 1))
    return np.array([0.0, -math.sin(t), math.cos(t)])


# -------------------------------------------------------------- finishes
# linear albedo; 'tex' names a texture made below
FIN = dict(
    anod_p=(0.50, 0.46, 0.47),      # S0001 chromic anodise, pink-tinted plate (pale in the
    anod_g=(0.45, 0.49, 0.46),      # ... greenish-grey plate      1990 KSC/Langley photos)
    teflon=(0.70, 0.75, 0.84),      # silvered Teflon thermal covers: crumpled, sky-blue
    frost=(0.84, 0.85, 0.84),       # ... the same, AO-frosted to a diffuse white (leading side)
    holes=(1.0, 1.0, 1.0),          # G10: a plate with four groups of round apertures
    brownplate=(1.0, 1.0, 1.0),     # H0: the space end's centre plate under the brown film
    white=(0.80, 0.79, 0.74),       # Chemglaze A276
    black=(0.035, 0.035, 0.04),     # Chemglaze Z306
    graphite=(0.10, 0.10, 0.11),    # graphite-epoxy / polyimide panels
    vda=(0.62, 0.62, 0.66),         # aluminised Kapton (A0054)
    kapton=(0.62, 0.42, 0.16),      # Kapton outer blankets (A0076, F12)
    blanket=(0.72, 0.72, 0.72),     # white/silver multilayer blankets
    torn=(0.50, 0.44, 0.34),        # M0001's shredded blankets (1990)
    cells=(0.05, 0.06, 0.15),       # solar cells
    apex=(1.0, 1.0, 1.0),           # E9: cells on black (1984) / primer (1990)
    ide=(1.0, 1.0, 1.0),            # IDE detector arrays
    samples1=(1.0, 1.0, 1.0), samples2=(1.0, 1.0, 1.0), samples3=(1.0, 1.0, 1.0),
    samples4=(1.0, 1.0, 1.0),
    copper=(0.55, 0.32, 0.17),      # A0133's grids (H7)
    chevron=(1.0, 1.0, 1.0),        # C1's white plate with the painted chevrons
    plate=(0.56, 0.57, 0.57),       # bare / anodised cover and mounting plates
    gold=(0.70, 0.55, 0.28),
    hole=(0.03, 0.03, 0.035),       # an empty tray bottom
)

# each tray: [(finish, (u0, v0, u1, v1))] -- u along +X across the tray
# (0 at its Earth-end edge), v across it toward the next row (v toward the
# 3-o'clock side of an end tray); () means the whole tray
W = (0, 0, 1, 1)
T3 = lambda f1, f2, f3: [(f1, (0, 0, 1, 1 / 3)), (f2, (0, 1 / 3, 1, 2 / 3)), (f3, (0, 2 / 3, 1, 1))]
H2 = lambda f1, f2: [(f1, (0, 0, 0.5, 1)), (f2, (0.5, 0, 1, 1))]
S0001 = [('anod_p', (0, 0, 0.5, 1)), ('anod_g', (0.5, 0, 1, 1))]
A0178 = [('teflon', W)]
TRAYS = {
    # row 1
    'A1': [('graphite', W)], 'B1': S0001, 'C1': [('chevron', W)], 'D1': A0178, 'E1': S0001, 'F1': S0001,
    # row 2
    'A2': A0178, 'B2': S0001, 'C2': T3('white', 'samples1', 'samples3'),
    'D2': [('samples2', (0, 0, 1, 0.5)), ('anod_p', (0, 0.5, 1, 1))], 'E2': A0178, 'F2': [('teflon', W)],
    # row 3
    'A3': [('plate', W)], 'B3': T3('blanket', 'samples4', 'blanket'), 'C3': [('samples3', W)],
    'D3': [('samples1', W)], 'E3': T3('plate', 'ide', 'ide'), 'F3': S0001,
    # row 4
    'A4': A0178, 'B4': [('vda', W)], 'C4': S0001, 'D4': T3('plate', 'samples2', 'white'), 'E4': S0001,
    'F4': A0178,
    # row 5
    'A5': S0001, 'B5': A0178, 'C5': A0178, 'D5': A0178,
    'E5': [('black', (0, 0, 1, 5 / 6)), ('samples4', (0, 5 / 6, 1, 1))], 'F5': S0001,
    # row 6
    'A6': S0001, 'B6': S0001, 'C6': A0178, 'D6': [('ide', (0, 0, 1, 1 / 3)), ('anod_g', (0, 1 / 3, 1, 1))],
    'E6': [('samples2', W)], 'F6': [('white', W)],
    # row 7
    'A7': [('graphite', W)], 'B7': A0178, 'C7': S0001, 'D7': A0178, 'E7': S0001, 'F7': S0001,
    # row 8
    'A8': [('graphite', (0, 0, 0.5, 1 / 3)), ('samples1', (0.5, 0, 1, 1 / 3)),
           ('kapton', (0, 1 / 3, 0.5, 2 / 3)), ('samples3', (0.5, 1 / 3, 1, 2 / 3)),
           ('plate', (0, 2 / 3, 0.5, 1)), ('cells', (0.5, 2 / 3, 1, 1))],
    'B8': [('anod_p', (0, 0, 1, 0.5)), ('samples4', (0, 0.5, 1, 1))], 'C8': A0178,
    'D8': T3('plate', 'samples3', 'white'), 'E8': [('ide', W)], 'F8': [('white', W)],
    # row 9 (leading)
    'A9': [('teflon', W)], 'B9': H2('graphite', 'samples2'), 'C9': [('samples3', W)], 'D9': [('samples1', W)],
    'E9': [('apex', W)], 'F9': [('kapton', (0, 0, 1, 0.6)), ('teflon', (0, 0.6, 0.5, 1)), ('black', (0.5, 0.6, 1, 1))],
    # row 10
    'A10': A0178, 'B10': [('teflon', W)], 'C10': [('plate', W)], 'D10': [('vda', W)], 'E10': A0178,
    'F10': S0001,
    # row 11
    'A11': [('plate', W)], 'B11': S0001, 'C11': A0178, 'D11': A0178, 'E11': S0001, 'F11': S0001,
    # row 12 (up in the payload bay)
    'A12': S0001, 'B12': T3('ide', 'plate', 'samples4'), 'C12': [('white', W)],
    'D12': H2('samples2', 'graphite'), 'E12': [('white', W)],
    'F12': [('kapton', (0.5, 0, 1, 1)), ('teflon', (0, 0, 0.5, 1))],
    # Earth end (grid position (a, b): a toward row 12, b toward row 3)
    'G12': [('samples1', (0, 0, 0.5, 0.5)), ('samples3', (0.5, 0, 1, 0.5)), ('samples2', (0, 0.5, 0.5, 1)),
            ('plate', (0.5, 0.5, 1, 1))],
    'G2': [('plate', W)], 'G4': [('plate', W)], 'G6': [('plate', W)], 'G8': [('plate', W)],
    'G10': [('holes', W)], 'G3': [('plate', W)], 'G9': [('plate', W)], 'G0': [('plate', W)],
    # space end
    'H12': [('blanket', W)], 'H1': [('cells', W)], 'H3': [('blanket', W)], 'H5': S0001, 'H6': [('white', W)],
    'H7': [('copper', W)], 'H9': [('white', W)], 'H11': H2('ide', 'samples4'), 'H0': [('brownplate', W)],
}
GRID = {12: (1, 0), 2: (1, 1), 1: (1, 1), 3: (0, 1), 4: (-1, 1), 5: (-1, 1), 6: (-1, 0),
        7: (-1, -1), 8: (-1, -1), 9: (0, -1), 10: (1, -1), 11: (1, -1), 0: (0, 0)}
# A0178 covers sit nearly flush; others recessed in their trays
DEPTH = dict(teflon=0.012, frost=0.012, blanket=0.010, torn=0.016)
# the Earth end's lower row: open, empty-looking boxes (S32-85-081, KSC 1990)
DEEP = {'G4': 0.12, 'G8': 0.12}


# -------------------------------------------------------------- textures
def _img(a):
    from PIL import Image
    a = np.clip(a, 0, 1)
    if a.ndim == 2:
        a = np.stack([a] * 3, -1)
    return Image.fromarray((a ** (1 / 2.2) * 255).astype(np.uint8))


def tex_teflon(seed, frosted=False):
    """Wrinkled silvered Teflon: crumpled into sharp ridges between the
    Velcro pads (3 x 4 oval dimples), scalloped, shadowed edges.  Frosted
    (the leading side's, eroded by atomic oxygen to a diffuse white) the
    ridges show far less."""
    g = np.random.default_rng(seed)
    s = 256
    a = np.zeros((s, s))
    for r, w in ((10, 1.0), (5, 0.6)):
        n = U._blur(U._blur(g.standard_normal((s, s)), r), r)
        n /= np.abs(n).max() + 1e-9
        a += w * (1 - np.abs(n)) ** 6              # creases: bright ridges, dark troughs
    a += 0.6 * U._blur(U._blur(g.standard_normal((s, s)), 18), 18) * 25
    a = (a - a.min()) / (a.max() - a.min())
    v = (0.80 + 0.20 * a) if frosted else (0.45 + 0.65 * a)
    yy, xx = np.mgrid[0:s, 0:s] / s
    for i in range(4):
        for j in range(3):
            cy, cx = (i + 0.5) / 4, (j + 0.5) / 3
            d = ((yy - cy) / 0.045) ** 2 + ((xx - cx) / 0.03) ** 2
            v *= 1 - 0.30 * np.exp(-d) + 0.12 * np.exp(-d / 3)
    edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
    v *= np.clip(0.55 + edge / 0.04, 0, 1)
    return _img(v)


def tex_s0001():
    """A debris witness plate: rolling-mill streaks along it, a darker
    border where the tray wall shades it."""
    g = np.random.default_rng(5)
    s = 256
    st = U._blur(g.standard_normal((1, s)).repeat(s, 0), 1)
    v = 0.86 + 0.06 * st / (np.abs(st).max() + 1e-9) + 0.04 * U._blur(g.standard_normal((s, s)), 8)
    yy, xx = np.mgrid[0:s, 0:s] / s
    edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
    v *= np.clip(0.7 + edge / 0.03, 0, 1)
    return _img(v)


def tex_samples(seed, base, palette, nx=6, ny=4):
    """Sample coupons on a plate: a grid of cells, each holding a coupon of
    random size and finish, gaps the plate's colour.  RGB, linear albedo."""
    g = np.random.default_rng(seed)
    s = 256
    a = np.ones((s, s, 3)) * np.asarray(base)
    yy, xx = np.mgrid[0:s, 0:s] / s
    for i in range(ny):
        for j in range(nx):
            if g.uniform() < 0.12:
                continue
            k = g.integers(1, 3) if g.uniform() < 0.3 else 1          # some coupons subdivided
            for m in range(k):
                for q in range(k):
                    c = np.asarray(palette[g.integers(len(palette))])
                    y0 = (i + (m + 0.08) / k) / ny
                    y1 = (i + (m + g.uniform(0.6, 0.92)) / k) / ny
                    x0 = (j + (q + 0.08) / k) / nx
                    x1 = (j + (q + g.uniform(0.6, 0.92)) / k) / nx
                    sel = (yy >= y0) & (yy < y1) & (xx >= x0) & (xx < x1)
                    a[sel] = c * g.uniform(0.85, 1.05)
    edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
    a *= np.clip(0.6 + edge / 0.03, 0, 1)[..., None]
    return _img(a)


ALU = (0.50, 0.50, 0.51)
WHT = (0.80, 0.79, 0.74)
BLK = (0.04, 0.04, 0.045)
GLD = (0.70, 0.52, 0.22)
CPR = (0.55, 0.30, 0.16)
BLU = (0.05, 0.07, 0.18)
MIR = (0.68, 0.70, 0.76)
GRY = (0.25, 0.25, 0.26)
BRN = (0.40, 0.26, 0.14)


def tex_ide():
    """IDE: rows of mirror-like square detectors (they show the sky's blue)
    on a die-cast frame."""
    s = 256
    a = np.ones((s, s, 3)) * np.asarray(ALU) * 0.8
    yy, xx = np.mgrid[0:s, 0:s] / s
    fy, fx = (yy * 8) % 1, (xx * 5) % 1
    det = (fy > 0.12) & (fy < 0.88) & (fx > 0.12) & (fx < 0.88)
    a[det] = (0.36, 0.42, 0.56)
    return _img(a)


def tex_apex(year):
    """APEX (S0014): 155 solar cells in recessed aluminium plates on a
    black-painted structure; by 1990 the black had eroded to the reddish-
    brown primer."""
    s = 256
    bg = (0.30, 0.12, 0.07) if year == "1990" else BLK
    a = np.ones((s, s, 3)) * np.asarray(bg)
    yy, xx = np.mgrid[0:s, 0:s] / s
    fy, fx = (yy * 4) % 1, (xx * 3) % 1
    plate = (fy > 0.06) & (fy < 0.94) & (fx > 0.05) & (fx < 0.95)
    a[plate] = BLK
    cy, cx = (yy * 12) % 1, (xx * 9) % 1
    cell = plate & (cy > 0.18) & (cy < 0.82) & (cx > 0.18) & (cx < 0.82)
    a[cell] = (0.06, 0.08, 0.20)
    return _img(a)


def tex_chevron():
    """C1's white-painted mounting plate with the black double chevron on
    its Earth-end half (the crew's tray identification; EL-1994-00114)."""
    s = 256
    a = np.ones((s, s, 3)) * np.asarray(WHT)
    yy, xx = np.mgrid[0:s, 0:s] / s       # yy: v (across), xx: u (along the tray)
    for off in (0.0, 0.09):
        d = np.abs(np.abs(yy - 0.5) * 0.9 - (xx - 0.08 - off))
        a[(d < 0.025) & (xx < 0.55) & (np.abs(yy - 0.5) < 0.42)] = BLK
    return _img(a)


def tex_holes():
    """G10: a bare plate with four groups of 4 x 6 round apertures, dark
    behind (S32-85-081, KSC 1990)."""
    s = 256
    a = np.ones((s, s, 3)) * np.asarray(ALU) * 1.1
    yy, xx = np.mgrid[0:s, 0:s] / s
    for gy in (0.06, 0.53):
        for gx in (0.08, 0.54):
            for i in range(6):
                for j in range(4):
                    cy, cx = gy + (i + 0.5) * 0.068, gx + (j + 0.5) * 0.095
                    a[((yy - cy) / 0.026) ** 2 + ((xx - cx) / 0.036) ** 2 < 1] = (0.10, 0.12, 0.16)
    edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
    a *= np.clip(0.6 + edge / 0.03, 0, 1)[..., None]
    return _img(a)


def tex_brownplate():
    """H0, the space end's centre plate: riveted panels under the 1990 brown
    film, a white disc at the middle (STS-32 photos of the space end)."""
    p = np.asarray(U.tex_panels(2, 2, seed=4, spread=0.12, line=0.7).convert("L"), float) / 255.0
    s = p.shape[0]
    yy, xx = np.mgrid[0:s, 0:s] / s
    a = np.stack([p] * 3, -1) ** 2.2 * np.array([0.46, 0.33, 0.20])
    r = np.hypot(yy - 0.5, xx - 0.5)
    a[r < 0.07] = (0.80, 0.80, 0.78)
    return _img(a)


def tex_vda():
    """A0054: six fibreglass modules (3 x 2) under aluminised-Kapton
    samples, the seams taped."""
    return U.tex_panels(3, 2, seed=54, spread=0.12, line=0.55)


def tex_graphite():
    return U.tex_panels(3, 2, seed=175, spread=0.3, line=0.6)


def tex_blanket(seed, depth):
    return U.tex_mli(seed, seams=2, depth=depth)


def textures(look):
    pal1 = [WHT, ALU, BLK, GLD, MIR, GRY, CPR]
    pal2 = [WHT, WHT, BLK, ALU, BLU, GRY]
    pal3 = [MIR, ALU, GLD, BLK, (0.62, 0.50, 0.30), WHT]
    pal4 = [GRY, BLK, ALU, CPR, WHT, BRN]
    return dict(
        anod_p=tex_s0001(), anod_g=tex_s0001(), teflon=tex_teflon(178), frost=tex_teflon(179, True),
        holes=tex_holes(), brownplate=tex_brownplate(), white=U.tex_panels(2, 2, seed=276, spread=0.06),
        black=U.tex_panels(2, 2, seed=306, spread=0.3), graphite=tex_graphite(), vda=tex_vda(),
        kapton=U.tex_mli(76, seams=2, depth=0.45), blanket=tex_blanket(1, 0.35), torn=tex_blanket(2, 0.9),
        cells=U.tex_cells(8, 6, line=0.5), apex=tex_apex(look), ide=tex_ide(),
        samples1=tex_samples(11, ALU, pal1), samples2=tex_samples(12, WHT, pal2, 5, 4),
        samples3=tex_samples(13, ALU, pal3, 7, 5), samples4=tex_samples(14, GRY, pal4, 4, 3),
        copper=U.tex_cells(6, 6, gap=0.2, line=0.4), chevron=tex_chevron(),
        plate=U.tex_panels(2, 1, seed=8, spread=0.1, line=0.7), gold=U.tex_mli(9, seams=1),
        hole=U.tex_panels(1, 1, seed=1, spread=0.0),
    )


# ------------------------------------------------------------- geometry
def _local(kit, size, centre, M, origin):
    """A box made in a tray's local (u, v, w) axes, put into the body frame:
    p = origin + M @ p_local (M's columns the body directions of u, v, w)."""
    p, t = kit.box(size, centre)
    return p @ np.asarray(M).T + origin, t


def _uv_section(mesh, M, origin, u0, v0, su, sv):
    """(mesh unshared, uv): u, v the tray-local coordinates (by M) scaled so
    the section (u0..u0+su, v0..v0+sv) spans 0..1."""
    p, t = U.unshare(mesh)
    loc = (p - origin) @ np.asarray(M)
    uv = np.column_stack([(loc[:, 0] - u0) / su, (loc[:, 1] - v0) / sv]).astype(np.float32)
    return (p, t), uv


def ngon_band(r_out, r_in, x0, x1):
    """A 12-sided band: its outer faces at apothem r_out, the inner at r_in,
    and its two annular edges -- one ring of the frame."""
    co, ci = r_out / math.cos(math.pi / N), r_in / math.cos(math.pi / N)
    ang = [math.radians(30.0 * k - 15.0) for k in range(N)]       # corners between the rows
    pts, tris = [], []
    for x in (x0, x1):
        for R in (co, ci):
            pts += [(x, R * math.cos(a), R * math.sin(a)) for a in ang]
    o0, i0, o1, i1 = 0, N, 2 * N, 3 * N
    for k in range(N):
        j = (k + 1) % N
        tris += [(o0 + k, o0 + j, o1 + j), (o0 + k, o1 + j, o1 + k)]          # outside
        tris += [(i0 + k, i1 + j, i0 + j), (i0 + k, i1 + k, i1 + j)]          # inside
        tris += [(o0 + k, i0 + j, o0 + j), (o0 + k, i0 + k, i0 + j)]          # x0 edge
        tris += [(o1 + k, o1 + j, i1 + j), (o1 + k, i1 + j, i1 + k)]          # x1 edge
    return np.asarray(pts, float), np.asarray(tris)


def build(kit):
    look = LOOK
    TEX = textures(look)
    groups = {}                         # (finish, tint) -> [(mesh, uv)]
    flat = {}                           # name -> (rgb, [meshes])

    def add_flat(name, rgb, m):
        flat.setdefault(name, (rgb, []))[1].append(m)

    def tint_of(row):
        if look != "1990" or row is None:
            return 0.0
        d = (row - ROW_TRAIL) % 12
        d = min(d, 12 - d)                      # rows away from the trailing row 3
        return {0: 0.30, 1: 0.22, 2: 0.10}.get(d, 0.0)

    def tray(name, M, origin, L, Wd, row, ttl=None):
        """One tray in local axes (u along L, v across Wd, w out): its anodised
        rim (4 walls, flange flush with the face plane) and the sections."""
        hu, hv = L / 2, Wd / 2
        rim = 0.035
        for c, s in (((0, -hv + rim / 2, -0.015), (L, rim, 0.03)), ((0, hv - rim / 2, -0.015), (L, rim, 0.03)),
                     ((-hu + rim / 2, 0, -0.015), (rim, Wd - 2 * rim, 0.03)),
                     ((hu - rim / 2, 0, -0.015), (rim, Wd - 2 * rim, 0.03))):
            add_flat("tray flanges (chromic anodise)", (0.42, 0.43, 0.43), _local(kit, s, c, M, origin))
        spec = TRAYS[name]
        if name in DEEP:                        # an open box: its walls down to the floor
            d = DEEP[name] + 0.01
            for c, sz in (((0, -hv + rim + 0.005, -d / 2), (L - 2 * rim, 0.01, d)),
                          ((0, hv - rim - 0.005, -d / 2), (L - 2 * rim, 0.01, d)),
                          ((-hu + rim + 0.005, 0, -d / 2), (0.01, Wd - 2 * rim - 0.02, d)),
                          ((hu - rim - 0.005, 0, -d / 2), (0.01, Wd - 2 * rim - 0.02, d))):
                add_flat("open tray walls", (0.50, 0.51, 0.51), _local(kit, sz, c, M, origin))
        for fin, (u0, v0, u1, v1) in spec:
            if look == "1990" and name in ('H3', 'H12') and fin == 'blanket':
                fin = 'torn'
            if look == "1990" and name == 'A8' and fin == 'cells':
                fin = 'hole'                    # plate I came loose and flew off (SP-531 fig. 21)
            if look == "1990" and fin == 'teflon' and row is not None and abs(row - ROW_LEAD) <= 1:
                fin = 'frost'                   # the ram face's covers eroded to a diffuse white
            if look != "1990" and fin == 'brownplate':
                fin = 'plate'
            iu, iv = L - 2 * rim, Wd - 2 * rim
            a0, a1 = -iu / 2 + u0 * iu, -iu / 2 + u1 * iu
            b0, b1 = -iv / 2 + v0 * iv, -iv / 2 + v1 * iv
            gap = 0.006 if len(spec) > 1 else 0.0
            dep = DEEP.get(name, DEPTH.get(fin, 0.03))
            if fin == 'hole':
                dep = 0.14
            box = U.refine(_local(kit, (a1 - a0 - gap, b1 - b0 - gap, 0.01),
                                  ((a0 + a1) / 2, (b0 + b1) / 2, -dep - 0.005), M, origin), 0.45)
            # one texture repeat across the section, but S0001's and the
            # samples' over each plate's own size
            groups.setdefault((fin, tint_of(row)), []).append(
                _uv_section(box, M, origin, a0, b0, a1 - a0, b1 - b0))

    # ---------------------------------------------------- the side trays
    for r in range(1, 13):
        n, tv = row_dir(r), row_tan(r)
        M = np.column_stack([(1.0, 0.0, 0.0), tv, n])
        for b, bay in enumerate("ABCDEF"):
            tray(bay + str(r), M, n * APOTHEM + (BAY_X[b], 0, 0), TRAY_L, TRAY_W, r)

    # ------------------------------------------------------- the end trays
    p12, p3 = row_dir(12), row_dir(3)
    x_end = LENGTH / 2
    for end, sgn in (('G', -1), ('H', +1)):
        x = sgn * x_end
        nrm = np.array([sgn, 0.0, 0.0])
        for key, (a, b) in GRID.items():
            name = end + str(key)
            if name not in TRAYS:
                continue
            centre = np.array([x, 0, 0]) + a * END_PITCH * p12 + b * END_PITCH * p3
            Mloc = np.column_stack([p12, np.cross(nrm, p12), nrm])
            tray(name, Mloc, centre, END_TRAY, END_TRAY, None)

    # G2: a dozen cylindrical canisters standing out of the plate, two with
    # copper-coloured caps (S32-85-081, KSC 1990)
    g2 = np.array([-x_end, 0, 0]) + END_PITCH * p12 + END_PITCH * p3
    cans, caps = [], []
    for i in range(4):
        for j in range(3):
            if (i, j) in ((1, 1), (2, 1)):
                continue
            c = g2 + (i - 1.5) * 0.19 * p12 + (j - 1) * 0.24 * p3
            r_ = 0.075 if (i + j) % 2 else 0.065
            cans.append(kit.move(kit.cylinder(r_, -0.10, 0.03, n=14), (-x_end, c[1], c[2])))
            if (i, j) in ((1, 0), (2, 0)):
                caps.append(kit.move(kit.cylinder(r_ * 0.7, -0.106, -0.10, n=14), (-x_end, c[1], c[2])))
    for m in cans:
        add_flat("G2 canisters", (0.62, 0.63, 0.64), m)
    for m in caps:
        add_flat("G2 canister caps", (0.55, 0.30, 0.14), m)

    # ------------------------------------------------------- structure
    rings = []
    ring_spans = [(-LENGTH / 2, -LENGTH / 2 + END_W), (LENGTH / 2 - END_W, LENGTH / 2)]
    for b in range(5):
        w = CENTRE_W if b == 2 else INTER_W
        x0 = BAY_X[b] + BAY / 2
        ring_spans.append((x0, x0 + w))
    for x0, x1 in ring_spans:
        rings.append(U.refine(ngon_band(APOTHEM + 0.016, APOTHEM - 0.10, x0, x1), 0.5))
    # longerons: a flat strip over each corner, 8 mm below the rings' faces
    Rc = APOTHEM / math.cos(math.pi / N)
    lon = []
    for k in range(N):
        a = math.radians(30.0 * k - 15.0)
        d = np.array([0.0, math.cos(a), math.sin(a)])
        t = np.array([0.0, -math.sin(a), math.cos(a)])
        Mk = np.column_stack([(1.0, 0, 0), t, d])
        lon.append(_local(kit, (LENGTH - 0.02, 0.11, 0.05), (0, 0, -0.025), Mk, d * (Rc - 0.012 + 0.008)))
    # the tray clamps: small bolted blocks along each longeron, three to a
    # tray edge (EL-1994-00287/-00305)
    clamps = []
    for k in range(N):
        a = math.radians(30.0 * k - 15.0)
        d = np.array([0.0, math.cos(a), math.sin(a)])
        t = np.array([0.0, -math.sin(a), math.cos(a)])
        Mk = np.column_stack([(1.0, 0, 0), t, d])
        for bx in BAY_X:
            for f in (-0.38, 0.0, 0.38):
                clamps.append(_local(kit, (0.08, 0.075, 0.014), (bx + f * BAY, 0, 0.007), Mk, d * (Rc - 0.004)))
    parts_clamps = kit.part("tray clamps", (0.66, 0.67, 0.67), *clamps)
    frame = kit.part("LDEF frame (chromic-anodised aluminium)", (0.58, 0.59, 0.59), *rings, *lon)
    parts = [frame, parts_clamps]
    # the black interior, behind the trays
    parts.append(kit.part("LDEF interior (Z306 black)", (0.03, 0.03, 0.03),
                          U.flip(U.ngon_prism(kit, N, APOTHEM - 0.16, -LENGTH / 2 + 0.18, LENGTH / 2 - 0.18,
                                              fine=0.5))))

    # end faces: thermal panels between the 12-gon and the tray grid, a
    # grid of frame bars, a backing plate behind the trays
    half = 1.5 * END_PITCH
    for end, sgn in (('G', -1), ('H', +1)):
        x = sgn * x_end
        panels = []
        corners = [math.radians(30.0 * k - 15.0) for k in range(N)]
        # sample the boundary between 12-gon and square at the polygon's
        # corners, the square's corners and a few between
        e1, e2 = p12[1:], p3[1:]

        def sq_hit(th):
            d = np.array([math.cos(th), math.sin(th)])
            s1, s2 = abs(d @ e1), abs(d @ e2)
            return d * (half + 0.04) / max(s1, s2)

        def poly_hit(th):
            d = np.array([math.cos(th), math.sin(th)])
            best = 1e9
            for k in range(N):
                nn = np.array([math.cos(math.radians(30.0 * k)), math.sin(math.radians(30.0 * k))])
                c = d @ nn
                if c > 1e-9:
                    best = min(best, (APOTHEM - 0.01) / c)
            return d * best
        sq_corner = [math.atan2(*(s1 * e1 + s2 * e2)[::-1]) for s1, s2 in ((1, 1), (1, -1), (-1, -1), (-1, 1))]
        for k in range(N):
            a0, a1 = corners[k], corners[(k + 1) % N] + (2 * math.pi if k == N - 1 else 0)
            ths = [a0 + 0.01, a1 - 0.01]
            for c in sq_corner:
                for cc in (c, c + 2 * math.pi):
                    if a0 + 0.01 < cc < a1 - 0.01:
                        ths.insert(-1, cc)
            ths.sort()
            for t0, t1 in zip(ths, ths[1:]):
                q = [sq_hit(t0), poly_hit(t0), poly_hit(t1), sq_hit(t1)]
                yz = [tuple(v) for v in q]
                if sgn > 0:
                    pm = kit.prism(yz[::-1], x - 0.012, x - 0.002)
                else:
                    pm = kit.prism(yz[::-1], x + 0.002, x + 0.012)
                panels.append(pm)
        colour = (0.035, 0.035, 0.04) if end == "G" else (0.42, 0.42, 0.41)
        parts.append(kit.part("thermal panels (%s end)" % ("Earth" if end == 'G' else "space"), colour,
                              *[U.refine(m, 0.45) for m in panels]))
        # grid bars: one direction 4 mm above the other
        bars = []
        for k in range(4):
            o = -half + k * END_PITCH
            c1 = np.array([x + sgn * 0.004, 0, 0]) + o * p12
            bars.append(kit.move(kit.turn(kit.box((0.012, 2 * half + 0.06, 0.07)),
                                          np.column_stack([(1, 0, 0), p3, p12])), c1))
            c2 = np.array([x + sgn * 0.008, 0, 0]) + o * p3
            bars.append(kit.move(kit.turn(kit.box((0.012, 2 * half + 0.06, 0.07)),
                                          np.column_stack([(1, 0, 0), p12, p3])), c2))
        parts.append(kit.part("end grid (%s end)" % ("Earth" if end == 'G' else "space"), (0.50, 0.51, 0.51), *bars))
        parts.append(kit.part("end backing (%s end)" % ("Earth" if end == 'G' else "space"), (0.03, 0.03, 0.03),
                              U.refine(kit.disc(APOTHEM - 0.03, x - 0.16, n=N)
                                       if sgn > 0 else U.facing_aft(kit, kit.disc(APOTHEM - 0.03, 0.0, n=N),
                                                                    x + 0.16), 0.5)))

    # --------------------------------------------- textured tray sections
    for (fin, tint), items in sorted(groups.items()):
        base = np.asarray(FIN[fin], float)
        if tint:
            base = base * (1 - tint * (1 - np.array([1.0, 0.80, 0.55])))
        meshes = [m for m, _ in items]
        uvs = np.vstack([uv for _, uv in items])
        mesh = kit.merge(*meshes)
        name = "trays: " + fin + (" (stained %.2f)" % tint if tint else "")
        parts.append(kit.part(name, list(base), mesh, texture=TEX[fin], uv=uvs))

    # ------------------------------------------ fittings on the trays
    # C12 and F8: the fibre-optic coils (C12: two black, one blue, one
    # orange; F8: black, blue, yellow/tan) on their white plates
    for name, cols in (('C12', [(0.03, 0.03, 0.03), (0.75, 0.30, 0.06), (0.08, 0.15, 0.45), (0.03, 0.03, 0.03)]),
                       ('F8', [(0.03, 0.03, 0.03), (0.08, 0.15, 0.45), (0.75, 0.62, 0.25)])):
        r = int(name[1:])
        n, tv = row_dir(r), row_tan(r)
        b = "ABCDEF".index(name[0])
        org = n * APOTHEM + (BAY_X[b], 0, 0)
        spots = [(-0.25, -0.22), (0.25, -0.22), (-0.25, 0.22), (0.25, 0.22)][:len(cols)]
        for (u, v), c in zip(spots, cols):
            ring = kit.disc(0.19, 0.0, n=24, r_in=0.08)
            ring = kit.turn(ring, kit.rot('y', -90))                # face +Z (local w)
            M = np.column_stack([(1.0, 0, 0), tv, n])
            p_, t_ = ring
            p_ = (p_ + (u, v, -0.018)) @ M.T + org
            add_flat("fibre-optic coils %s" % str(c), c, (p_, t_))

    # grapple fixtures: standard FRGF in C1 (deploy and retrieval), the
    # rigidize-sensing one in C10; both on 6-in tray plates, the shaft and
    # target standing above the face; C10's black EIS status square
    fx = []
    for name, active in (('C1', False), ('C10', True)):
        r = int(name[1:])
        n, tv = row_dir(r), row_tan(r)
        b = 2
        at = n * (APOTHEM - 0.035) + (BAY_X[b] + (0.18 if name == 'C1' else 0.0), 0, 0) - (0.05 if name == 'C1' else 0.0) * tv
        fx += U.frgf(kit, at, n, (1, 0, 0), active)
        if name == 'C10':
            add_flat("EIS status indicator", (0.03, 0.03, 0.03),
                     kit.move(kit.turn(kit.box((0.012, 0.10, 0.10)), np.column_stack([n, (1, 0, 0), tv])),
                              n * (APOTHEM - 0.028) + (BAY_X[b] + 0.2, 0, 0) + 0.32 * tv))
    for nm, rgb, m in fx:
        parts.append(kit.part(nm, rgb, m))
    # A6: the keel-camera target (black, white stripes, a short rod)
    n, tv = row_dir(6), row_tan(6)
    c = n * (APOTHEM - 0.035) + (BAY_X[0] + 0.35, 0, 0)
    M6 = np.column_stack([(1.0, 0, 0), tv, n])
    add_flat("keel-camera target", (0.03, 0.03, 0.03), _local(kit, (0.22, 0.22, 0.05), (0, 0, 0.025), M6, c))
    add_flat("keel-camera target stripes", (0.8, 0.8, 0.8),
             _local(kit, (0.03, 0.20, 0.006), (0, 0, 0.053), M6, c))
    add_flat("keel-camera target", (0.03, 0.03, 0.03), kit.rod(c + 0.05 * n, c + 0.28 * n, 0.012, n=6))

    # trunnions: two on the centre ring (rows 3 and 9), the keel pin on it
    # (row 6), two at the Earth end: at the support beam's apex (row 9) and
    # on the end frame (row 3).  Each side pin stands in a yellow scuff
    # plate cut as a D (EL-1994-00287/-00304, KSC 1990, STS-32 photos):
    # about 0.66 m across, on the centre ring its flat edge along the axis
    # toward row 6, at the end its flat edge on the end.  By 1990 the
    # leading side's were still bright and the trailing side's a dull
    # mustard brown; the keel pin's round plate went half and half
    # (yellow toward the ram, brown toward the wake: EL-1994-00149/-00114).
    yellow = (0.80, 0.62, 0.05)
    lead_y = yellow if look == "1984" else (0.86, 0.68, 0.08)
    trail_y = yellow if look == "1984" else (0.46, 0.31, 0.10)

    def dplate(centre, n, e_flat, e_dome, R, cut, z0, z1, npts=20):
        """A D-shaped plate (a disc of radius R, cut by a chord `cut` from the
        centre on the -e_dome side), z0..z1 along n from `centre`."""
        th0 = math.asin(-cut / R)
        th = np.linspace(th0, math.pi - th0, npts)
        pts2 = [(R * math.cos(t), R * math.sin(t)) for t in th]       # (along e_flat, along e_dome)
        pm = kit.prism([(y, z) for y, z in pts2], z0, z1)
        P, T = pm
        B = np.column_stack([n, e_flat, e_dome])
        out = (P @ B.T + centre, T)
        return out if np.linalg.det(B) > 0 else U.flip(out)

    pins, scuff_t, scuff_l = [], [], []
    xe = -LENGTH / 2 + END_W / 2
    x_end0 = -LENGTH / 2
    for r, x in ((3, 0.0), (9, 0.0), (3, xe), (9, xe)):
        n, tv = row_dir(r), row_tan(r)
        base = n * (APOTHEM + 0.016) + (x, 0, 0)
        pins.append(U.trunnion(kit, base, n, 0.25, 0.041))
        e12 = row_dir(12) - n * (row_dir(12) @ n)
        e12 /= np.linalg.norm(e12)
        if x == 0.0:
            plate = dplate(base, n, np.array([1.0, 0, 0]), e12, 0.33, 0.10, 0.004, 0.012)
        else:
            c = n * (APOTHEM + 0.016) + (x_end0, 0, 0)
            plate = dplate(c, n, e12, np.array([1.0, 0, 0]), 0.33, 0.0, 0.010, 0.018)
        (scuff_t if r == 3 else scuff_l).append(plate)
    n6, t6 = row_dir(6), row_tan(6)
    k0 = n6 * (APOTHEM + 0.016)
    pins.append(U.trunnion(kit, k0, n6, 0.30, 0.05))
    scuff_l.append(dplate(k0, n6, np.array([1.0, 0, 0]), t6, 0.30, 0.0, 0.004, 0.012))
    scuff_t.append(dplate(k0, n6, np.array([1.0, 0, 0]), -t6, 0.30, 0.0, 0.004, 0.012))

    # the end support beam (S32-85-081 and the KSC lift-out of 1990): a
    # tube from the apex fitting at the row-9 rim straight across the Earth
    # end, just above the hub, to the row-3 rim; a second from the apex
    # down to a node below the hub, a third from the node back up to the
    # row-3 rim; a ribbed bow-tie web from the upper tube through the hub
    # to the node.  Coordinates (s, a): s toward row 3, a toward row 12.
    xb = -LENGTH / 2 - 0.10
    u9, u3, u12 = row_dir(9), row_dir(3), row_dir(12)

    def E(s_, a_, dx=0.0):
        return np.array([xb + dx, 0, 0]) + s_ * u3 + a_ * u12
    apex, r_hi, r_lo, node = E(-2.02, 0.0), E(1.93, 0.60), E(1.88, 0.36), E(0.05, -0.47)
    beam = [kit.rod(apex, r_hi, 0.055, n=10), kit.rod(apex, node, 0.055, n=10),
            kit.rod(node, r_lo, 0.055, n=10)]
    for f_ in (r_hi, r_lo):
        beam.append(kit.rod(f_, f_ + np.array([0.11, 0, 0]), 0.045, n=8))   # to the end frame
    beam.append(kit.rod(apex, E(-2.02, 0.0, 0.10 + END_W / 2 + 0.05), 0.07, n=10))
    beam.append(kit.along(kit.cylinder(0.11, 0.0, 0.05, n=20), (1, 0, 0), E(0, 0, 0.0)))   # hub boss
    hub = E(0, 0, 0.03)
    a_up = 0.60 * (0.0 + 2.02) / (1.93 + 2.02)            # the upper tube's a over the hub
    for sx in (-0.30, -0.15, 0.0, 0.15, 0.30):
        beam.append(kit.rod(hub, E(sx, a_up, 0.02), 0.022, n=6))
        beam.append(kit.rod(hub, E(0.05 + 0.45 * sx, -0.44, 0.02), 0.022, n=6))
    beam.append(kit.move(kit.turn(kit.box((0.05, 0.10, 0.47 + a_up)), np.column_stack([(1, 0, 0), u3, u12])),
                         E(0.03, (a_up - 0.47) / 2, 0.06)))            # the web's channel
    parts.append(kit.part("end support beam", (0.62, 0.63, 0.63), *beam))
    parts.append(kit.part("spindle disc", (0.03, 0.03, 0.03),
                          kit.along(kit.cylinder(0.12, 0.0, 0.03, n=20), u9, u9 * (APOTHEM + 0.17) + (xe, 0, 0))))
    parts.append(kit.part("trunnions and keel pin (stainless)", (0.70, 0.70, 0.70), *pins))
    parts.append(kit.part("trunnion scuff plates (trailing side)", trail_y, *scuff_t))
    parts.append(kit.part("trunnion scuff plates (leading side)", lead_y, *scuff_l))

    for nm, (rgb, ms) in flat.items():
        parts.append(kit.part(nm, rgb, *ms))
    return dict(meta=dict(name="Long Duration Exposure Facility (LDEF)%s" %
                          (", as STS-32 retrieved it (1990)" if look == "1990" else ", as STS-41C deployed it (1984)"),
                          frame="LDEF: +X along the axis toward the space end (the Earth end, with the "
                                "end support beam, -X; bays A-F from -X), +Y out of row 1's face, rows "
                                "1-12 round +X (row 12 up and row 6 down in the payload bay; row 9 "
                                "leading, row 3 trailing in flight); m; the middle (its mass was spread "
                                "nearly evenly)",
                          source="simple shapes to NASA SP-473 fig. 2 and SP-531 (tray map, structure, "
                                 "finishes) and the STS-41C/STS-32 and KSC photographs",
                          norad=14898, mag_1000km=1.8),
                parts=U.refine_parts(parts))
