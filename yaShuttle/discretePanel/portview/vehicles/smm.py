"""The Solar Maximum Mission (Solar Max, SMM; NORAD 11703, 1980-014A) as
STS-41C met it in April 1984: before the repair, its high-gain antenna
still stowed (Goddard first deployed it on the arm after the repair).

BODY FRAME (SMM's own +X; the 1980 JSC retrieval study's figure 3):
  +X  the observatory's axis, toward the Sun: out of the instrument
      module's white forward closeout (the octagonal "Sun face").
  +Y  across the instrument module's short width, out of the long side the
      +Y solar wing deploys from.
  +Z  = X x Y, along the instrument module's long width (the octagon is
      2.15 m along Z, 1.55 m along Y).  The Multimission Modular
      Spacecraft's triangular truss has a vertex toward -Z, where the RMS
      grapple fixture is; the trunnion pin (Nelson's TPAD target) sticks
      out of the transition adapter just round from it.
  metres; ORIGIN the centre of mass, estimated from a mass budget (MASSES
  below: the instrument module ~1.2 t, the three MMS modules ~0.74 t, the
  rest ~0.37 t, 2315 kg at launch), which puts it on the axis about 1.7 m
  above the MMS's aft end -- near the transition adapter, as one expects
  of the RMS grapple fixture's place "between the observatory and the MMS".

SOURCES (dimensions):
  * Bohlin, Frost, Burr, Guha & Withbroe, "Solar Maximum Mission", Solar
    Physics 65, 5 (1980), https://articles.adsabs.harvard.edu/pdf/1980SoPh...65....5B
    -- ~4 m long within a 2.3 m circular envelope; the instrument module the
    top 2.3 m; MMS modules each ~1.2 x 1.2 x 0.5 m on a triangular frame;
    the transition adapter carrying the two fixed paddles; figures 1-2.
  * NASA, "Renewing Solar Science: the Solar Maximum Repair Mission"
    (NTRS 19860015243) -- the exploded view (thermal and electronics
    enclosures, instrument support plate, transition adapter, trunnion
    pin, grapple point, HGAS).
  * NASA STS-41C press kit (March 1984),
    https://www.nasa.gov/wp-content/uploads/2023/05/sts-41c-press-kit.pdf
    -- the 1.27 m (50 in) TDRSS high-gain antenna, deployed after repair.
  * NASA, "Repairing Solar Max" (NTRS 19840020814) -- modules 1.2 x 1.2 x
    0.5 m (4 x 4 x 1.7 ft).
  * JSC, "Proximity operations analysis: retrieval of the SMM observatory"
    (NTRS 19800019910) -- +X at the Sun through the octagonal face;
    figure 8's top view (each wing ~1.8:1, set off the octagon, canted).
  * Time, 1984 ("Tinkering with Solar Max") -- the 7-ft-long panels.
  * Photographs: 41C-34-1380 (from above the Sun face: the octagon's
    proportions, the Sun face's apertures, the wings' size, cant and set-
    off, measured by fitting the octagon), 41C-37-1715, -1711, -1718,
    41C-52-2646 (in the FSS: colours, heights, the modules), GSFC
    G-80-1663/1737/1738 and G-80-5496 (assembly: the radiators, louvers,
    the transition adapter ring, the stowed dish under the MMS).
  * "Returned Solar Max hardware degradation study" (NTRS 19890014166) --
    the blankets' outer layer aluminized Kapton (amber), silver Teflon on
    the louvers and radiators.
"""
import math

import numpy as np

from . import _smm_shapes as S

KEY = 'smm'

HGA_DEPLOYED = False            # True: the high-gain antenna as deployed after the repair

# ----------------------------------------------------------------- colours
# linear albedo
KAPTON = (0.66, 0.29, 0.07)          # aluminized Kapton, outward (x the crinkle map ~0.8)
KAPTON_B = (0.57, 0.24, 0.055)       # the neighbouring blankets, a shade apart
SEAMS = (0.10, 0.05, 0.02)           # between blankets
WHITE = (0.80, 0.80, 0.78)           # the Sun face's white paint
SILVER = (0.70, 0.71, 0.72)          # bare aluminium, silver Teflon
OSR = (0.07, 0.09, 0.17)             # mirror radiators (they show the black sky)
BLACK = (0.03, 0.03, 0.03)
GOLD = (0.72, 0.52, 0.16)            # gold foil
MAROON = (0.16, 0.035, 0.03)         # the louvers' frames
ARRAY_BACK = (0.72, 0.72, 0.70)      # the paddles' white backs
GREY = (0.40, 0.40, 0.41)

# ---------------------------------------------------------------- geometry
# Stations along X, metres from the MMS's aft (anti-Sun) end, before the
# centre of mass is subtracted.
X_MSS0, X_MSS1 = 0.15, 1.40          # module support structure (and modules)
X_TA0, X_TA1 = 1.40, 1.62            # transition adapter ring
X_IM0, X_IM1 = 1.62, 3.85            # instrument module
X_FACE = 3.87                        # the Sun face's outer surface
X_WING = 1.70                        # the solar paddles' mid-plane

# The instrument module's octagon: 1.55 m (Y) x 2.15 m (Z) across the
# flats, 0.37 m chamfers -- from the octagon fitted to 41C-34-1380 (to 5
# px in ~440) scaled to the 2.3 m envelope.
IM_HY, IM_HZ, IM_CH = 0.775, 1.075, 0.37
OCT = [(IM_HY, IM_HZ - IM_CH), (IM_HY, -(IM_HZ - IM_CH)), (IM_HY - IM_CH, -IM_HZ),
       (-(IM_HY - IM_CH), -IM_HZ), (-IM_HY, -(IM_HZ - IM_CH)), (-IM_HY, IM_HZ - IM_CH),
       (-(IM_HY - IM_CH), IM_HZ), (IM_HY - IM_CH, IM_HZ)]

# The MMS: a triangular frame (a vertex toward -Z), modules 1.22 x 1.22 x
# 0.46 m on its faces.
MSS_SIDE = 1.45
MSS_IN = MSS_SIDE / (2 * math.sqrt(3))       # 0.42 m, centre to a face
MSS_VR = 2 * MSS_IN                          # 0.84 m, centre to a vertex
MOD_W, MOD_H, MOD_D = 1.22, 1.21, 0.46
# face normals' angles (from +Y toward +Z) and the modules there
# (41C-37-1715, from the orbiter's aft windows: the white-faced module
# square on, a silver-blanketed one beside it to -Y; which module is which
# is otherwise a guess)
MODULES = ((90.0, 'power'), (210.0, 'C&DH'), (330.0, 'ACS'))
TA_R = 0.95

# The paddles (41C-34-1380): each wing three panels side by side, each
# panel 2.20 m radially (the "7-ft-long" panels) by 1.18 m; the wing's
# radial axis canted 23 deg from Y toward Z, its centre 2.45 m out at 14
# deg; the -Y wing the +Y wing turned 180 deg about X.
PANEL_L, PANEL_W, PANEL_GAP = 2.20, 1.18, 0.03
WING_CANT = 23.0
WING_R_IN = 1.32                    # the inner edge, along the wing's own axis
WING_Z_MID = -0.38                  # the wing's centre, across its own axis

HGA_R, HGA_DEPTH = 0.635, 0.20      # the 1.27 m dish

# A mass budget for the centre of mass: (kg, (x, y, z)) in the build frame.
MASSES = None                       # filled in by build()


def _deg(a):
    return math.radians(a)


def _yz(angle, r):
    return np.array([r * math.cos(_deg(angle)), r * math.sin(_deg(angle))])


# ------------------------------------------------------------ the pieces
def instrument_module(kit, tex):
    """The octagonal instrument module, its blankets, radiators and Sun face."""
    parts = []
    core = kit.prism(OCT, X_IM0, X_IM1)
    parts.append(kit.part("IM seams", SEAMS, core))
    rows = [(X_IM0 + 0.01, 2.12), (2.12, 2.98), (2.98, X_IM1)]
    gap = 0.012
    rng = np.random.default_rng(80)
    tiles = {0: [], 1: []}
    n = len(OCT)
    for f in range(n):
        p0, p1 = np.array(OCT[f]), np.array(OCT[(f + 1) % n])
        t = p1 - p0
        L = float(np.linalg.norm(t))
        t /= L
        nn = np.array([t[1], -t[0]])               # outward (the polygon runs clockwise)
        if np.dot(nn, (p0 + p1) / 2) < 0:
            nn = -nn
        cols = 2 if L > 1.0 else 1
        for r, (xa, xb) in enumerate(rows):
            for c in range(cols):
                a0 = L * c / cols + gap / 2
                a1 = L * (c + 1) / cols - gap / 2
                q0 = p0 + t * a0 + nn * 0.012
                q1 = p0 + t * a1 + nn * 0.012
                xa_, xb_ = xa + gap / 2, xb - gap / 2
                corners = [(xa_, *q0), (xa_, *q1), (xb_, *q1), (xb_, *q0)]
                # a window of the crinkle map, its size the tile's (1 map = 2 m)
                du, dv = (a1 - a0) / 2.0, (xb_ - xa_) / 2.0
                u0, v0 = rng.uniform(0, 1 - du), rng.uniform(0, 1 - dv)
                uv = [(u0, v0), (u0 + du, v0), (u0 + du, v0 + dv), (u0, v0 + dv)]
                tiles[(f + r + c) % 2].append(S.quad(*corners, uv=uv))
    for k, col in ((0, KAPTON), (1, KAPTON_B)):
        mesh, uv = S.merge_uv(tiles[k])
        parts.append(kit.part("IM blankets %d" % k, col, mesh, texture=tex, uv=uv))

    # radiators: 2 x 3 on the +Y side, 1 x 3 on the +Y/+Z chamfer (G-80-1737;
    # 41C-37-1715 shows them beside the white-faced MMS module; 41C-34-1380,
    # looking at the -Y and -Z sides, shows none)
    rad, rad_frame = [], []
    R_py = S.frame((0, 1, 0), (0, 0, 1))
    for xc in (3.53, 3.06, 2.59):
        for zc in (-0.25, 0.25):
            rad.append(S.obox(kit, (0.42, 0.42, 0.012), (xc, IM_HY + 0.030, zc), R_py))
            rad_frame.append(S.obox(kit, (0.45, 0.45, 0.010), (xc, IM_HY + 0.020, zc), R_py))
    c0, c1 = np.array(OCT[7]), np.array(OCT[0])
    tt = (c1 - c0) / np.linalg.norm(c1 - c0)
    nn = np.array([-tt[1], tt[0]])
    if np.dot(nn, (c0 + c1) / 2) < 0:
        nn = -nn
    R_ch = S.frame((0, *nn), (0, *tt))
    mid = (c0 + c1) / 2
    for xc in (3.53, 3.06, 2.59):
        rad.append(S.obox(kit, (0.42, 0.40, 0.012), (xc, *(mid + nn * 0.030)), R_ch))
        rad_frame.append(S.obox(kit, (0.45, 0.43, 0.010), (xc, *(mid + nn * 0.020)), R_ch))
    parts.append(kit.part("IM radiators", OSR, *rad))
    parts.append(kit.part("IM radiator frames", SILVER, *rad_frame))

    # the two white bars along the top of the -Y side (41C-34-1380)
    R_my = S.frame((0, -1, 0), (0, 0, 1))
    bars = [S.obox(kit, (0.06, 0.62, 0.04), (3.70, -IM_HY - 0.06, z), R_my) for z in (0.36, -0.36)]
    bars += [S.obox(kit, (0.04, 0.03, 0.05), (3.70, -IM_HY - 0.035, z), R_my)
             for z in (0.62, 0.10, -0.10, -0.62)]
    parts.append(kit.part("IM -Y rails", WHITE, *bars))

    # the Sun face: a white closeout over the blankets' tops
    big = [(y * (1 + 0.016 / IM_HY), z * (1 + 0.016 / IM_HZ)) for y, z in OCT]
    parts.append(kit.part("Sun face", WHITE, kit.prism(big, X_IM1, X_FACE)))
    parts += sun_face(kit)
    # the instrument support plate's rim, a lighter band at the module's foot
    foot = [(y * (1 + 0.02 / IM_HY), z * (1 + 0.02 / IM_HZ)) for y, z in OCT]
    parts.append(kit.part("IM foot ring", SILVER, kit.prism(foot, X_IM0, X_IM0 + 0.05)))
    return parts


def sun_face(kit):
    """The apertures on the Sun face (+X), placed from 41C-34-1380 by the
    fitted octagon: (y, z) metres."""
    x = X_FACE
    blk, wht, gry, gld = [], [], [], []

    def plate(lst, sy, sz, y, z, h=0.004, x0=x):
        lst.append(kit.box((h, sy, sz), (x0 + h / 2, y, z)))

    # ACRIM: three cavities in a ring (the trefoil), -0.23, +0.82
    gry.append(kit.move(kit.tube(0.095, 0.080, 0.0, 0.012, n=24), (x, -0.23, 0.82)))
    for k in range(3):
        a = _deg(90 + 120 * k)
        blk.append(kit.move(kit.cylinder(0.035, 0.0, 0.003, n=16),
                            (x, -0.23 + 0.03 * math.cos(a), 0.82 + 0.03 * math.sin(a))))
    # a gridded window in a black frame (-0.44, +0.41)
    plate(blk, 0.33, 0.33, -0.44, 0.41)
    for i in range(3):
        for j in range(3):
            plate(wht, 0.07, 0.07, -0.44 + (i - 1) * 0.095, 0.41 + (j - 1) * 0.095, h=0.006)
    plate(gry, 0.13, 0.22, -0.41, 0.40, h=0.008)
    # the X-ray polychromator's bent crystal spectrometer: a slotted grille
    plate(blk, 0.33, 0.15, 0.37, 0.42)
    for k in range(5):
        plate(gld, 0.012, 0.11, 0.30 + 0.035 * k, 0.42, h=0.006)
    # its flat crystal spectrometer: a gold window in a black frame
    plate(blk, 0.34, 0.23, 0.36, 0.16)
    plate(gld, 0.26, 0.15, 0.36, 0.16, h=0.007)
    # two small slots
    plate(blk, 0.12, 0.04, -0.15, 0.09)
    plate(blk, 0.12, 0.04, -0.15, 0.02)
    # the coronagraph/polarimeter: a raised box on a dark recessed base
    plate(blk, 0.42, 0.42, 0.34, -0.24)
    gry.append(kit.box((0.16, 0.28, 0.28), (x + 0.08, 0.34, -0.24)))
    blk.append(kit.box((0.004, 0.20, 0.20), (x + 0.162, 0.34, -0.24)))
    # a gold disc (+0.25, -0.70)
    gld.append(kit.move(kit.cylinder(0.165, 0.0, 0.005, n=32), (x, 0.25, -0.70)))
    # the UV spectrometer/polarimeter's window, black frame (-0.29, -0.75)
    plate(blk, 0.31, 0.23, -0.29, -0.75)
    plate(wht, 0.23, 0.15, -0.29, -0.75, h=0.006)
    blk.append(kit.box((0.008, 0.02, 0.15), (x + 0.004, -0.27, -0.75)))
    # the fine and coarse sun sensors (two small heads near opposite corners)
    for y, z in ((-0.53, 0.78), (0.58, -0.69)):
        blk.append(kit.box((0.06, 0.08, 0.06), (x + 0.03, y, z)))
        gry.append(kit.box((0.012, 0.10, 0.08), (x + 0.006, y, z)))
    # the raised lip round the face, inset from the edge
    lip = [(y * 0.94, z * 0.955) for y, z in OCT]
    lipo = [(y * 0.955, z * 0.965) for y, z in OCT]
    ring = []
    for k in range(8):
        a0, a1 = np.array(lip[k]), np.array(lip[(k + 1) % 8])
        b0, b1 = np.array(lipo[k]), np.array(lipo[(k + 1) % 8])
        ring.append(S.quad((x + 0.002, *a0), (x + 0.002, *a1), (x + 0.002, *b1), (x + 0.002, *b0))[0])
    return [kit.part("Sun face apertures", BLACK, *blk),
            kit.part("Sun face white fittings", WHITE, *wht),
            kit.part("Sun face grey fittings", GREY, *gry),
            kit.part("Sun face gold", GOLD, *gld),
            kit.part("Sun face lip", (0.55, 0.55, 0.55), *ring)]


def transition_adapter(kit):
    ring = kit.tube(TA_R, TA_R - 0.10, X_TA0, X_TA1, n=64)
    flange = kit.tube(TA_R + 0.03, TA_R - 0.10, X_TA1 - 0.025, X_TA1, n=64)
    flange2 = kit.tube(TA_R + 0.03, TA_R - 0.10, X_TA0, X_TA0 + 0.025, n=64)
    holes = []
    for k in range(36):
        a = 360.0 * (k + 0.5) / 36
        n = np.array([0.0, math.cos(_deg(a)), math.sin(_deg(a))])
        t = np.array([0.0, -math.sin(_deg(a)), math.cos(_deg(a))])
        R = S.frame(n, t)
        holes.append(S.obox(kit, (0.05, 0.05, 0.006), (X_TA0 + 0.11, *(n[1:] * (TA_R + 0.002))), R))
    # the closeout between the ring and the instrument module (dark blanket)
    cover = kit.cylinder(TA_R - 0.10, X_TA0 + 0.03, X_TA1 - 0.01, n=48)
    return [kit.part("transition adapter", SILVER, ring, flange, flange2),
            kit.part("transition adapter holes", BLACK, *holes),
            kit.part("transition adapter closeout", (0.25, 0.13, 0.04), cover)]


def mms(kit, tex):
    """The module support structure and its three modules."""
    parts = []
    verts = [tuple(_yz(a, MSS_VR)) for a in (-90.0, 30.0, 150.0)]
    parts.append(kit.part("MSS blanket", (0.50, 0.30, 0.09), kit.prism(verts, X_MSS0, X_MSS1)))
    # the frame's longerons and rings at the vertices
    frame = []
    for v in verts:
        p = np.array(v) * 1.02
        frame.append(kit.box((X_MSS1 - X_MSS0, 0.08, 0.08), ((X_MSS0 + X_MSS1) / 2, *p)))
    for x in (X_MSS0 + 0.02, X_MSS1 - 0.02):
        for k in range(3):
            frame.append(kit.rod((x, *np.array(verts[k]) * 1.02), (x, *np.array(verts[(k + 1) % 3]) * 1.02), 0.03))
    parts.append(kit.part("MSS frame", SILVER, *frame))

    body, louv, louv_base, frames, white, straps, mli = [], [], [], [], [], [], []
    silver, silverq = [], []
    for ang, name in MODULES:
        n = np.array([0.0, math.cos(_deg(ang)), math.sin(_deg(ang))])
        t = np.array([0.0, -math.sin(_deg(ang)), math.cos(_deg(ang))])
        R = S.frame(n, t)
        rc = MSS_IN + MOD_D / 2 + 0.005
        xc = (X_MSS0 + X_MSS1) / 2
        body.append(S.obox(kit, (MOD_H, MOD_W, MOD_D), (xc, *(n[1:] * rc)), R))
        ro = MSS_IN + MOD_D + 0.005                  # the module's outer face
        # every module: a dark-red rim round its face (G-80-5496)
        frames.append(S.obox(kit, (MOD_H, MOD_W, 0.012), (xc, *(n[1:] * (ro + 0.006))), R))

        def at(dx, dt, dr, size):
            c = np.array([xc + dx, 0.0, 0.0]) + t * dt + n * (ro + dr)
            return S.obox(kit, size, c, R)
        if name == 'ACS':
            # louvers: two banks of eight vertical blades (G-80-5496)
            for bank in (-0.29, 0.29):
                louv_base.append(at(bank, 0.0, 0.016, (0.54, 1.10, 0.006)))
                for k in range(8):
                    louv.append(at(bank, -0.48 + k * 0.137, 0.024, (0.52, 0.115, 0.008)))
            # the star trackers' shades (a pair, near the top of the face)
            for dt in (-0.35, 0.35):
                louv_base.append(at(0.52, dt, 0.05, (0.10, 0.12, 0.10)))
        elif name == 'power':
            # white thermal face, crossed straps (41C-37-1715)
            white.append(at(0.0, 0.0, 0.016, (1.15, 1.15, 0.008)))
            L = math.hypot(1.10, 1.10)
            for s in (1, -1):
                a = math.atan2(1.10, s * 1.10)
                Rs = R @ np.array([[math.cos(a), -math.sin(a), 0], [math.sin(a), math.cos(a), 0], [0, 0, 1]])
                straps.append(S.obox(kit, (L, 0.04, 0.008), np.array([xc, 0, 0]) + n * (ro + 0.024), Rs))
            for dx in (-0.45, 0.0, 0.45):
                straps.append(at(dx, 0.0, 0.022, (0.03, 1.10, 0.006)))
        else:
            # C&DH: silver blanket over the face (41C-37-1715), a bank of
            # louvers at its foot
            q = [np.array([xc + sx * MOD_H / 2 * 0.96, 0, 0]) + t * st * MOD_W / 2 * 0.96 + n * (ro + 0.016)
                 for sx, st in ((-1, -1), (-1, 1), (1, 1), (1, -1))]
            silverq.append(S.quad(*q, uv=[(0.1, 0.1), (0.7, 0.1), (0.7, 0.7), (0.1, 0.7)]))
            louv_base.append(at(-0.42, 0.0, 0.020, (0.28, 1.10, 0.006)))
            for k in range(5):
                louv.append(at(-0.52 + k * 0.05, 0.0, 0.028, (0.035, 1.06, 0.006)))
        # the modules' sides: blanket (silver on the C&DH, gold elsewhere)
        for side in (-1, 1):
            c = np.array([xc, 0.0, 0.0]) + t * side * (MOD_W / 2 + 0.006) + n * rc
            Rt = S.frame(t * side, n)
            (mli if name != 'C&DH' else silver).append(S.obox(kit, (MOD_H - 0.02, MOD_D - 0.02, 0.006), c, Rt))
    mesh, uv = S.merge_uv(silverq)
    parts.append(kit.part("MMS silver blanket face", (0.82, 0.82, 0.84), mesh, texture=tex, uv=uv))
    parts.append(kit.part("MMS silver side blankets", SILVER, *silver))
    parts.append(kit.part("MMS module bodies", (0.45, 0.28, 0.09), *body))
    parts.append(kit.part("MMS module side blankets", KAPTON, *mli))
    parts.append(kit.part("MMS louver frames", MAROON, *frames))
    parts.append(kit.part("MMS louver blades", SILVER, *louv))
    parts.append(kit.part("MMS louver beds", (0.12, 0.12, 0.13), *louv_base))
    parts.append(kit.part("MMS white faces", WHITE, *white))
    parts.append(kit.part("MMS straps", (0.30, 0.30, 0.30), *straps))
    # the FSS latch pins: three, at the aft vertices
    pins = []
    for a in (-90.0, 30.0, 150.0):
        d = _yz(a, 1.0)
        pins.append(kit.rod((X_MSS0 + 0.10, *(d * 0.80)), (X_MSS0 + 0.10, *(d * 1.00)), 0.03, n=12))
        pins.append(kit.rod((X_MSS0 + 0.10, *(d * 0.97)), (X_MSS0 + 0.10, *(d * 1.00)), 0.05, n=12))
    parts.append(kit.part("FSS latch pins", SILVER, *pins))
    return parts


def grapple_fixture(kit):
    """The RMS flight-releasable grapple fixture at the MSS's -Z vertex."""
    xg = X_MSS1 - 0.24
    zb = -(MSS_VR + 0.06)
    R = S.frame((0, 0, -1), (0, 1, 0))
    metal = [S.obox(kit, (0.32, 0.32, 0.03), (xg, 0.0, zb), R),
             kit.rod((xg, 0.0, zb), (xg, 0.0, zb - 0.26), 0.032, n=16),
             kit.rod((xg, 0.0, zb - 0.24), (xg, 0.0, zb - 0.28), 0.05, n=16)]
    for k in range(3):                               # the three cam ramps
        a = _deg(120 * k)
        metal.append(kit.box((0.05, 0.05, 0.10), (xg + 0.10 * math.cos(a), 0.10 * math.sin(a), zb - 0.06)))
    # the target: a standoff, a black disc with a white cross
    xt, yt = xg + 0.11, 0.11
    metal.append(kit.rod((xt, yt, zb), (xt, yt, zb - 0.24), 0.012, n=8))
    disc = kit.along(kit.cylinder(0.075, 0.0, 0.006, n=24), (0, 0, -1), (xt, yt, zb - 0.24))
    cross = [kit.box((0.11, 0.012, 0.004), (xt, yt, zb - 0.248)),
             kit.box((0.012, 0.11, 0.004), (xt, yt, zb - 0.248)),
             kit.rod((xt, yt, zb - 0.246), (xt, yt, zb - 0.33), 0.008, n=8)]
    return [kit.part("grapple fixture", (0.78, 0.78, 0.76), *metal),
            kit.part("grapple target", BLACK, disc),
            kit.part("grapple target cross", WHITE, *cross)]


def trunnion_pin(kit):
    """The trunnion pin on the transition adapter (the TPAD's target) and
    the grommet beside it that defeated the TPAD."""
    a = -105.0
    d = _yz(a, 1.0)
    x = (X_TA0 + X_TA1) / 2
    metal = [kit.rod((x, *(d * (TA_R - 0.02))), (x, *(d * 1.30)), 0.032, n=16),
             kit.rod((x, *(d * TA_R)), (x, *(d * (TA_R + 0.03))), 0.075, n=20),
             kit.rod((x, *(d * 1.27)), (x, *(d * 1.31)), 0.042, n=16)]
    t = _yz(a + 90, 1.0)
    grommet = [kit.rod((x + 0.075, *(d * TA_R + t * 0.05)), (x + 0.075, *(d * (TA_R + 0.035) + t * 0.05)), 0.022, n=12)]
    # an omni antenna on a short mast (Bohlin et al. fig. 1)
    o = _yz(150.0, 1.0)
    metal += [kit.rod((x, *(o * TA_R)), (x, *(o * 1.22)), 0.02, n=8)]
    omni = [kit.rod((x - 0.10, *(o * 1.22)), (x + 0.06, *(o * 1.22)), 0.045, n=12)]
    return [kit.part("trunnion pin", (0.78, 0.78, 0.78), *metal),
            kit.part("grommet", BLACK, *grommet),
            kit.part("omni antenna", WHITE, *omni)]


def solar_wings(kit):
    """Both paddles: (parts, (mass centre of the +Y wing, y-z))."""
    atlas, npan = S.cells_atlas()
    x = X_WING
    th = 0.025
    one_cells, backs, hinges, yoke, drive = [], [], [], [], []
    z0 = WING_Z_MID - (3 * PANEL_W + 2 * PANEL_GAP) / 2
    du = 1.0 / npan
    eps = 0.5 / S.PANEL_PX[0] / npan
    for k in range(3):
        za, zb = z0 + k * (PANEL_W + PANEL_GAP), z0 + k * (PANEL_W + PANEL_GAP) + PANEL_W
        ya, yb = WING_R_IN, WING_R_IN + PANEL_L
        backs.append(kit.box((th, PANEL_L, PANEL_W), (x, (ya + yb) / 2, (za + zb) / 2)))
        xf = x + th / 2 + 0.003
        u0, u1 = k * du + eps, (k + 1) * du - eps
        one_cells.append(S.quad((xf, ya, za), (xf, ya, zb), (xf, yb, zb), (xf, yb, za),
                                uv=[(u0, 0.0), (u1, 0.0), (u1, 1.0), (u0, 1.0)]))
        if k < 2:                                    # hinges between the panels
            zh = zb + PANEL_GAP / 2
            for yh in (ya + 0.35, yb - 0.35):
                hinges.append(kit.box((0.04, 0.10, 0.05), (x - 0.005, yh, zh)))
    # the yoke: from a drive at the instrument module's foot to the inner edge
    c, s = math.cos(_deg(WING_CANT)), math.sin(_deg(WING_CANT))
    Rinv = np.array([[c, s], [-s, c]])               # body y-z -> wing y'-z'
    base = Rinv @ np.array([IM_HY + 0.07, 0.10])
    drive.append(kit.box((0.12, 0.14, 0.18), (x, *base)))
    for dz in (-0.30, 0.30):
        yoke.append(kit.rod((x, base[0], base[1] + dz * 0.4), (x, WING_R_IN, WING_Z_MID + dz), 0.022, n=8))
    yoke.append(kit.rod((x, base[0], base[1]), (x, WING_R_IN, WING_Z_MID), 0.02, n=8))
    yoke.append(kit.box((0.05, 0.04, 0.80), (x, WING_R_IN - 0.02, WING_Z_MID)))

    def placed(meshes, flip):
        R = kit.rot('x', WING_CANT + (180.0 if flip else 0.0))
        return [kit.turn(m, R) for m in meshes]
    cells_mesh, cells_uv = S.merge_uv(one_cells)
    cells_all, uv_all = [], []
    for flip in (False, True):
        R = kit.rot('x', WING_CANT + (180.0 if flip else 0.0))
        cells_all.append(kit.turn(cells_mesh, R))
        uv_all.append(cells_uv)
    cells, cells_uv2 = S.merge_uv(list(zip(cells_all, uv_all)))
    parts = [kit.part("solar cells", (1.0, 1.0, 1.0), cells, texture=atlas, uv=cells_uv2),
             kit.part("solar paddle backs", ARRAY_BACK, *(placed(backs, False) + placed(backs, True))),
             kit.part("solar paddle hinges", SILVER, *(placed(hinges, False) + placed(hinges, True))),
             kit.part("solar paddle yokes", SILVER, *(placed(yoke, False) + placed(yoke, True))),
             kit.part("solar paddle drives", (0.30, 0.30, 0.31), *(placed(drive, False) + placed(drive, True)))]
    centre = np.array([[c, -s], [s, c]]) @ np.array([WING_R_IN + PANEL_L / 2, WING_Z_MID])
    return parts, centre


def high_gain_antenna(kit):
    """The 1.27 m TDRSS dish: stowed under the MMS (as met), or deployed."""
    dish_w, dish_b, metal = [], [], []
    if not HGA_DEPLOYED:
        apex = X_MSS0 - 0.03
        # opening toward -X: built along +X, turned 180 deg about Z
        R = kit.rot('z', 180.0)
        dish_w.append(kit.move(kit.turn(S.paraboloid(HGA_R, HGA_DEPTH), R), (apex, 0, 0)))
        dish_b.append(kit.move(kit.turn(S.paraboloid(HGA_R, HGA_DEPTH, flip=True), R), (apex + 0.012, 0, 0)))
        metal.append(kit.cylinder(0.05, apex - 0.30, apex, n=16))
        metal.append(kit.cylinder(0.11, apex - 0.33, apex - 0.30, n=24))
        metal.append(kit.cylinder(0.20, apex, X_MSS0 + 0.01, n=24))
        mass_at = (apex - 0.1, 0.0, 0.0)
    else:
        # mast and gimbal below the MMS (Bohlin et al. fig. 2), the dish
        # looking out sideways and down
        metal.append(kit.cylinder(0.14, X_MSS0 - 0.55, X_MSS0 + 0.01, n=24))
        for k in range(8):
            a0, a1 = _deg(45 * k), _deg(45 * (k + 1))
            metal.append(kit.rod((X_MSS0 - 0.55, 0.17 * math.cos(a0), 0.17 * math.sin(a0)),
                                 (X_MSS0 - 0.85, 0.17 * math.cos(a1), 0.17 * math.sin(a1)), 0.012, n=6))
        metal.append(kit.box((0.12, 0.16, 0.16), (X_MSS0 - 0.93, 0.0, 0.0)))
        d = np.array([-0.5, 0.0, 0.866])
        piv = np.array([X_MSS0 - 0.93, 0.0, 0.20])
        metal.append(kit.rod((X_MSS0 - 0.93, 0, 0), piv, 0.04, n=12))
        dish_w.append(kit.along(S.paraboloid(HGA_R, HGA_DEPTH), d, piv + 0.02 * d))
        dish_b.append(kit.along(S.paraboloid(HGA_R, HGA_DEPTH, flip=True), d, piv + 0.008 * d))
        metal.append(kit.rod(piv + 0.02 * d, piv + 0.35 * d, 0.03, n=10))
        metal.append(kit.along(kit.cylinder(0.10, 0.0, 0.02, n=24), d, piv + 0.35 * d))
        mass_at = tuple(piv + 0.1 * d)
    return [kit.part("HGA dish", (0.78, 0.78, 0.76), *dish_w, smooth=True),
            kit.part("HGA dish back", (0.22, 0.13, 0.05), *dish_b, smooth=True),
            kit.part("HGA feed and mast", SILVER, *metal)], mass_at


# ------------------------------------------------------------------ build
def build(kit):
    global MASSES
    tex = S.blanket_texture()
    parts = []
    parts += instrument_module(kit, tex)
    parts += transition_adapter(kit)
    parts += mms(kit, tex)
    parts += grapple_fixture(kit)
    parts += trunnion_pin(kit)
    wings, wc = solar_wings(kit)
    parts += wings
    hga, hga_at = high_gain_antenna(kit)
    parts += hga

    xm = (X_MSS0 + X_MSS1) / 2
    mods = {name: _yz(a, MSS_IN + MOD_D / 2) for a, name in MODULES}
    MASSES = [
        (1215.0, (X_IM0 + 0.42 * (X_IM1 - X_IM0), 0.0, 0.0)),   # instrument module, heavier low
        (60.0, ((X_TA0 + X_TA1) / 2, 0.0, 0.0)),                # transition adapter
        (130.0, (xm, 0.0, 0.0)),                                # module support structure
        (240.0, (xm, *mods['ACS'])),                            # attitude control module
        (300.0, (xm, *mods['power'])),                          # power (three NiCd batteries)
        (200.0, (xm, *mods['C&DH'])),                           # communications & data handling
        (50.0, (X_WING, *wc)), (50.0, (X_WING, *(-wc))),         # the paddles
        (70.0, hga_at),                                         # high-gain antenna system
    ]
    m = np.array([k for k, _ in MASSES])
    r = np.array([p for _, p in MASSES], float)
    cm = (m[:, None] * r).sum(0) / m.sum()
    parts = kit.transform_parts(parts, np.eye(3), -cm)
    return dict(meta=dict(
        name="Solar Maximum Mission (SMM), as met by STS-41C, April 1984",
        frame=("SMM body axes: +X toward the Sun (out of the instrument module's octagonal Sun "
               "face), +Y across the octagon's 1.55 m width (the +Y solar paddle's side), "
               "+Z = X x Y along its 2.15 m width (the MMS truss's grapple-fixture vertex at -Z); "
               "m; origin the estimated centre of mass, %.2f m above the MMS's aft end" % cm[0]),
        source=("simple shapes to published dimensions and STS-41C photographs: Bohlin et al., "
                "Solar Phys. 65, 5 (1980); NASA STS-41C press kit; NTRS 19860015243, 19840020814, "
                "19800019910, 19890014166; photographs 41C-34-1380, 41C-37-1715 and GSFC "
                "G-80-1663/1737/5496 (portview/vehicles/smm.py)"),
        norad=11703, mag_1000km=2.0),
        parts=parts)
