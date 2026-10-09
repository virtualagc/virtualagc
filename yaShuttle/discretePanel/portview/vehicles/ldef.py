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
  s32-85-063 against the 53 in tray.  The end support beam is a V of two
  tubes across the Earth end from the row-9 rim (its spindle and trunnion)
  to the row-3 side, through a spoked centre fitting (41c-36-1618,
  S32-85-081).
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
    anod_p=(0.34, 0.31, 0.32),      # S0001 chromic anodise, pink-tinted plate
    anod_g=(0.30, 0.33, 0.31),      # ... greenish-grey plate
    teflon=(0.80, 0.82, 0.85),      # silvered Teflon thermal covers
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
    chevron=(1.0, 1.0, 1.0),        # C1's plate with the painted chevrons
    plate=(0.45, 0.46, 0.46),       # anodised cover / mounting plates
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
    'G12': [('samples1', W)], 'G2': [('white', W)], 'G4': S0001, 'G6': [('white', W)], 'G8': S0001,
    'G10': [('ide', W)], 'G3': [('plate', W)], 'G9': [('plate', W)], 'G0': [('plate', W)],
    # space end
    'H12': [('blanket', W)], 'H1': [('cells', W)], 'H3': [('blanket', W)], 'H5': S0001, 'H6': [('white', W)],
    'H7': [('copper', W)], 'H9': [('white', W)], 'H11': H2('ide', 'samples4'), 'H0': [('plate', W)],
}
GRID = {12: (1, 0), 2: (1, 1), 1: (1, 1), 3: (0, 1), 4: (-1, 1), 5: (-1, 1), 6: (-1, 0),
        7: (-1, -1), 8: (-1, -1), 9: (0, -1), 10: (1, -1), 11: (1, -1), 0: (0, 0)}
# A0178 covers sit nearly flush; others recessed in their trays
DEPTH = dict(teflon=0.012, blanket=0.010, torn=0.016)


# -------------------------------------------------------------- textures
def _img(a):
    from PIL import Image
    a = np.clip(a, 0, 1)
    if a.ndim == 2:
        a = np.stack([a] * 3, -1)
    return Image.fromarray((a ** (1 / 2.2) * 255).astype(np.uint8))


def tex_teflon(seed):
    """Wrinkled silvered Teflon: broad soft wrinkles, the Velcro pads (3 x 4
    oval dimples) and scalloped, shadowed edges."""
    g = np.random.default_rng(seed)
    s = 256
    a = U._blur(U._blur(g.standard_normal((s, s)), 20), 20) * 30 + U._blur(g.standard_normal((s, s)), 6) * 0.6
    a = (a - a.min()) / (a.max() - a.min())
    v = 0.78 + 0.22 * a
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
    """C1's chromic-anodised mounting plate with the black double chevron
    painted on its Earth-end half (the crew's tray identification)."""
    s = 256
    a = np.ones((s, s, 3)) * np.asarray(FIN['plate'])
    yy, xx = np.mgrid[0:s, 0:s] / s       # yy: v (across), xx: u (along the tray)
    for off in (0.0, 0.09):
        d = np.abs(np.abs(yy - 0.5) * 0.9 - (xx - 0.08 - off))
        a[(d < 0.025) & (xx < 0.55) & (np.abs(yy - 0.5) < 0.42)] = BLK
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
        anod_p=tex_s0001(), anod_g=tex_s0001(), teflon=tex_teflon(178), white=U.tex_panels(2, 2, seed=276, spread=0.06),
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
        for fin, (u0, v0, u1, v1) in spec:
            if look == "1990" and name in ('H3', 'H12') and fin == 'blanket':
                fin = 'torn'
            if look == "1990" and name == 'A8' and fin == 'cells':
                fin = 'hole'                    # plate I came loose and flew off (SP-531 fig. 21)
            iu, iv = L - 2 * rim, Wd - 2 * rim
            a0, a1 = -iu / 2 + u0 * iu, -iu / 2 + u1 * iu
            b0, b1 = -iv / 2 + v0 * iv, -iv / 2 + v1 * iv
            gap = 0.006 if len(spec) > 1 else 0.0
            dep = DEPTH.get(fin, 0.03)
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
    frame = kit.part("LDEF frame (chromic-anodised aluminium)", (0.50, 0.51, 0.51), *rings, *lon)
    parts = [frame]
    # the black interior, behind the trays
    parts.append(kit.part("LDEF interior (Z306 black)", (0.03, 0.03, 0.03),
                          U.flip(U.ngon_prism(kit, N, APOTHEM - 0.16, -LENGTH / 2 + 0.05, LENGTH / 2 - 0.05,
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
        at = n * (APOTHEM - 0.035) + (BAY_X[b] + 0.18, 0, 0) - 0.05 * tv
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
    # (row 6), two at the Earth end on the support beam (row 9: its spindle)
    # and on the end frame (row 3); yellow scuff plates round the row-3 and
    # row-9 pins (mustard by 1990 on the trailing side)
    yellow = (0.80, 0.62, 0.05)
    mustard = (0.52, 0.40, 0.10) if look == "1990" else yellow
    pins, scuff_t, scuff_l = [], [], []
    xe = -LENGTH / 2 + END_W / 2
    for r, x in ((3, 0.0), (9, 0.0), (3, xe)):
        n, tv = row_dir(r), row_tan(r)
        base = n * (APOTHEM + 0.016) + (x, 0, 0)
        pins.append(U.trunnion(kit, base, n, 0.25, 0.041))
        disc = kit.along(kit.cylinder(0.22, 0.0, 0.008, n=24), n, base + 0.004 * n)
        (scuff_t if r == 3 else scuff_l).append(disc)
    n6 = row_dir(6)
    pins.append(U.trunnion(kit, n6 * (APOTHEM + 0.016), n6, 0.30, 0.05))
    # the end support beam: apex fitting and spindle at the row-9 rim, two
    # tubes to the row-3 side, a spoked centre fitting
    xb = -LENGTH / 2 - 0.10
    u9, u3, u12 = row_dir(9), row_dir(3), row_dir(12)
    apex = np.array([xb, 0, 0]) + 2.02 * u9
    feet = [np.array([xb, 0, 0]) + 1.85 * u3 + s * 0.42 * u12 for s in (-1, 1)]
    beam = [kit.rod(apex, f, 0.055, n=10) for f in feet]
    beam.append(kit.rod(feet[0], feet[1], 0.045, n=10))
    for f in feet:
        beam.append(kit.rod(f, f + np.array([0.10, 0, 0]), 0.05, n=8))      # feet to the end frame
    beam.append(kit.rod(apex, apex + np.array([0.10, 0, 0]), 0.07, n=10))
    hub = np.array([xb + 0.03, 0, 0])
    beam.append(kit.along(kit.cylinder(0.22, 0.0, 0.04, n=24), (1, 0, 0), hub - (0.02, 0, 0)))
    for k in range(8):
        a = 2 * math.pi * k / 8
        d = np.array([0.0, math.cos(a), math.sin(a)])
        beam.append(kit.rod(hub + 0.2 * d, hub + 0.55 * d + (0.06, 0, 0), 0.02, n=6))
    parts.append(kit.part("end support beam", (0.55, 0.56, 0.56), *beam))
    pins.append(U.trunnion(kit, apex + 0.05 * u9, u9, 0.25, 0.041))
    parts.append(kit.part("spindle disc", (0.03, 0.03, 0.03),
                          kit.along(kit.cylinder(0.12, 0.0, 0.03, n=20), u9, apex + 0.20 * u9)))
    parts.append(kit.part("trunnions and keel pin (stainless)", (0.70, 0.70, 0.70), *pins))
    parts.append(kit.part("trunnion scuff plates (trailing side)", mustard, *scuff_t))
    parts.append(kit.part("trunnion scuff plates (leading side)", yellow if look == "1984" else (0.70, 0.55, 0.08),
                          *scuff_l))

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
