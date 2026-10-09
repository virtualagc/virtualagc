"""The Infrared Background Signature Survey on SPAS-II (NORAD 21244), as
STS-39 flew it in April-May 1991: released from the arm, it watched
Discovery's thruster plumes, the Earth's limb and the chemical-release
canisters from up to ~10 km while the orbiter manoeuvred round it, and was
recaptured.

SPAS-II (MBB, for the SDIO) as the photographs show it:

  - the carrier: a long blanketed box across the payload bay (Y), 4.5 m
    between its yellow end plates, 1.35 m along the bay (X), 0.9 m deep,
    in white beta-cloth panels.  Its +X face (the one s39-15-017 looks at
    from the aft flight deck during berthing) is three sections: the -Y
    end section; a middle section set back ~0.12 m; the +Y end section a
    little proud.  On it four mirror radiators, which flew blue (they
    mirror the Earth; s91-27784 shows the same panels silver, preflight):
    a small one and a tall one at -Y near the top, two stacked in the
    middle section at +0.15..+0.63 m;
  - each end (+-Y) a yellow shield-shaped plate, square above and tapered
    below the box, the longeron trunnion out of it 0.2 m above the box's
    mid-height (s39-15-017; s39-19-015 and s39-17-017 show the shape);
  - under it the keel structure: legs from the bottom corners at
    Y = -1.32 and +1.28 meeting 1.7 m below the box at the keel pin
    (which ends in a brown bumper ball), a cross strut 0.8 m below the
    box, and a vertical post from the box's middle down to the apex
    (s39-15-017, s39-11-027);
  - on top, IBSS's cryostat: a 1.4 m drum lying ALONG Y (across the bay;
    the old model had it along X), its back a rounded dome toward +Y with
    the blanket's gores radiating from its centre (s39-17-017), its
    aperture end toward -Y stepped in twice -- a slightly smaller drum,
    then a thick annular ring round the arched aperture, whose black
    cover stands open above it (s39-15-017; preflight s91-27781/27784).
    It sits down into a blanket saddle in the deck, from Y = -0.55
    (aperture ring) to +1.15 (dome), "MBB / IBSS/SPAS II" lettered on its
    +X side (s39-15-017);
  - at the -Y end on the deck, the ultraviolet/visible imagers: a blue
    ribbed electronics box (Y -1.34..-0.73, 0.26 m high), two white
    blanketed tubes (0.22 m, 0.8 m long) on posts above it pointing -Y,
    side by side across X (s39-15-017 shows the front one; s91-27781 and
    s91-27784 both), a small white box beside them;
  - a white-housed TV camera hanging under the -Y end, lens to +X
    (s39-15-017);
  - the grapple fixture on the deck at Y = +1.53 (where the end effector
    meets it in s39-15-017), on a round grey base plate whose three brass
    cam ramps s39-17-017 shows from above; silver-blanketed boxes beside it
    on the +Y end section.

Measured on s39-15-017 (NASA, images.nasa.gov, the 4220 x 2800 scan:
the carrier between its end plates 4.5 m scales the frame to ~385 px/m
at the carrier), with s39-17-017 for the cryostat's diameter (equal to
the carrier's X width) and its dome, and s39-19-015 for the end plates.
Uncertain: the -X face (no photo of it from the flight; drawn as plain
blanket with one radiator), the exact X positions of the imager tubes.
"""
import math

import numpy as np

from . import _leo_util as U

KEY = 'ibss'

WHITE = (0.78, 0.77, 0.73)
STRUT = (0.78, 0.78, 0.76)
YELLOW = (0.78, 0.58, 0.10)
BRASS = (0.62, 0.48, 0.20)

DX, DY, DZ = 1.35, 4.5, 0.9
HX, HY, HZ = DX / 2, DY / 2, DZ / 2
RD = 0.70                          # the cryostat drum's radius
ZD = HZ + 0.50                     # its axis, above the deck
Y_AP, Y_FRONT, Y_BACK = -0.55, -0.29, 0.90     # aperture ring face, drum front, dome start
DOME = 0.25                        # the back dome's depth (to Y = +1.15)
APEX = np.array([0.0, 0.0, -HZ - 1.75])
GF_Y = 1.53


def tex_radiator(nx=4, ny=3, size=256, seed=7):
    """A mirror radiator as it flew: deep blue (the Earth it mirrors)
    tiles in a light aluminium frame (s39-15-017).  White part colour."""
    from PIL import Image
    g = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:size, 0:size] / size
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    jit = g.uniform(0.8, 1.15, (ny, nx))
    v = jit[(yy * ny).astype(int) % ny, (xx * nx).astype(int) % nx]
    rgb = np.stack([0.06 * v, 0.10 * v, 0.30 * v], -1)
    frame = (fx < 0.05) | (fx > 0.95) | (fy < 0.06) | (fy > 0.94)
    rgb[frame] = 0.55
    return Image.fromarray((np.clip(rgb, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))


def tex_ribbed(size=256, ribs=12):
    """The imagers' electronics box: blue panels between bright vertical
    ribs (s39-15-017).  White part colour."""
    from PIL import Image
    yy, xx = np.mgrid[0:size, 0:size] / size
    rgb = np.ones((size, size, 3)) * np.array([0.07, 0.10, 0.30])
    rib = ((xx * ribs) % 1) < 0.22
    rgb[rib] = 0.60
    rgb[(yy < 0.06) | (yy > 0.94)] = 0.60
    return Image.fromarray((np.clip(rgb, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))


def tex_label(w=512, h=200):
    """The lettering on the cryostat's +X side: MBB's four-pointed star,
    "MBB" and "IBSS/SPAS II" in black on the white blanket (s39-15-017).
    White part colour; u along -Y... +Y, v down."""
    from PIL import Image, ImageDraw
    from ._leo_astrospas import _text
    im = Image.new("RGB", (w, h), (232, 231, 224))
    d = ImageDraw.Draw(im)
    sx, cy = int(w * 0.10), int(h * 0.45)
    for a in range(4):
        t = a * math.pi / 2
        d.polygon([(sx + 40 * math.cos(t), cy + 40 * math.sin(t)),
                   (sx + 5 * math.cos(t + 0.8), cy + 5 * math.sin(t + 0.8)),
                   (sx, cy), (sx + 5 * math.cos(t - 0.8), cy + 5 * math.sin(t - 0.8))], fill=(40, 40, 46))
    _text(d, (int(w * 0.62), int(h * 0.26)), "MBB", int(h * 0.30), (25, 25, 30))
    d.line((int(w * 0.26), int(h * 0.47), int(w * 0.97), int(h * 0.47)), fill=(40, 40, 46), width=3)
    _text(d, (int(w * 0.61), int(h * 0.70)), "IBSS/SPAS II", int(h * 0.28), (25, 25, 30), fit=int(w * 0.70))
    return im


def _yz_box(kit, y0, y1, z0, z1, x0, x1):
    return kit.box((x1 - x0, y1 - y0, z1 - z0), ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))


def _drum_y(kit, r0, r1, y0, y1, n=48, caps=True):
    """A frustum along +Y from radius r0 at y0 to r1 at y1, on the cryostat's axis."""
    m = kit.frustum(r0, r1, 0.0, y1 - y0, n=n, caps=caps)
    return kit.along(m, (0, 1, 0), (0.0, y0, ZD))


def _outward(mesh):
    """A closed mesh with its triangles wound outward (positive volume)."""
    P, T = np.asarray(mesh[0], float), np.asarray(mesh[1])
    v = np.einsum('ij,ij->i', P[T[:, 0]], np.cross(P[T[:, 1]], P[T[:, 2]])).sum()
    return (P, T[:, ::-1].copy()) if v < 0 else (P, T)


def build(kit):
    p = []
    # ------------------------------------------------------------ the carrier
    mli = U.tex_mli(101, seams=2, depth=0.35)
    left = _yz_box(kit, -HY, -0.73, -HZ, HZ, -HX, HX)
    mid = _yz_box(kit, -0.745, 0.735, -HZ + 0.01, HZ - 0.01, -HX, HX - 0.12)      # the +X face set back
    right = _yz_box(kit, 0.72, HY, -HZ, HZ, -HX, HX + 0.04)                        # a little proud
    p.append(U.tpart(kit, "carrier blankets", WHITE, kit.merge(left, right), mli, tile=1.1, fine=0.4))
    p.append(U.tpart(kit, "carrier blankets (middle)", WHITE, mid, U.tex_mli(102, seams=2, depth=0.4), tile=1.0,
                     fine=0.4))
    # the +X face's panel seams: slightly raised blanket panels over the end
    # sections' faces (the joins s39-15-017 shows at Y -1.67, -1.04, +1.47)
    pan = [_yz_box(kit, y0, y1, -HZ + 0.03, HZ - 0.03, HX, HX + 0.012) for y0, y1 in ((-2.22, -1.69), (-1.65, -1.06))]
    pan += [_yz_box(kit, y0, y1, -HZ + 0.03, HZ - 0.03, HX + 0.04, HX + 0.052) for y0, y1 in ((0.75, 1.45), (1.49, 2.22))]
    p.append(U.tpart(kit, "blanket panels", WHITE, kit.merge(*pan), U.tex_mli(103, seams=1, depth=0.45), tile=0.7))
    # the lower edge beam along the +X face
    p.append(kit.part("lower edge beam", (0.84, 0.84, 0.82), _yz_box(kit, -1.10, HY - 0.08, -HZ - 0.03, -HZ + 0.07,
                                                                         HX - 0.10, HX + 0.07)))
    # mirror radiators (+X face), and the boxes the middle two stand on
    rad = [_yz_box(kit, -1.32, -1.07, 0.27, 0.43, HX + 0.012, HX + 0.024),
           _yz_box(kit, -0.95, -0.73, 0.02, 0.42, HX + 0.012, HX + 0.024),
           _yz_box(kit, 0.15, 0.63, 0.17, 0.39, HX + 0.005, HX + 0.017),
           _yz_box(kit, 0.15, 0.63, -0.27, -0.04, HX + 0.005, HX + 0.017)]
    rad.append(_yz_box(kit, -0.6, 0.6, -0.25, 0.25, -HX - 0.017, -HX - 0.005))        # -X face (assumed)
    p.append(U.tpart(kit, "mirror radiators", (1, 1, 1), kit.merge(*rad), tex_radiator(), tile=(0.25, 0.20),
                     axes=((0, 1, 0), (0, 0, 1))))
    p.append(kit.part("radiator housings", (0.72, 0.72, 0.70),
                      _yz_box(kit, 0.12, 0.66, 0.14, 0.42, HX - 0.13, HX), _yz_box(kit, 0.12, 0.66, -0.30, -0.01, HX - 0.13, HX)))
    p.append(kit.part("radiator housing ends", (0.05, 0.05, 0.06),
                      _yz_box(kit, 0.52, 0.63, 0.17, 0.39, HX + 0.018, HX + 0.022),
                      _yz_box(kit, 0.52, 0.63, -0.27, -0.04, HX + 0.018, HX + 0.022)))
    # the yellow end plates, square above and tapered below the box
    plate = [(-HX - 0.02, 0.40), (-HX - 0.02, -0.30), (-0.16, -HZ - 0.20), (0.16, -HZ - 0.20), (HX + 0.02, -0.30),
             (HX + 0.02, 0.40)]
    plates = []
    for s in (-1, 1):
        y = s * (HY + 0.005)
        P, T = kit.prism(plate, 0.0, 0.025 * s)          # section (x, z), along the first axis
        P = np.column_stack([P[:, 1], P[:, 0] + y, P[:, 2]])
        plates.append(_outward((P, T)))
    p.append(kit.part("yellow end plates", YELLOW, *plates))
    tr = [U.trunnion(kit, (0.0, s * (HY + 0.03), 0.20), (0, s, 0), 0.20, 0.041) for s in (-1, 1)]
    tr.append(U.trunnion(kit, APEX, (0, 0, -1), 0.22, 0.05))
    p.append(kit.part("trunnions", (0.80, 0.80, 0.80), *tr))
    p.append(kit.part("keel pin bumper", (0.36, 0.20, 0.10), kit.sphere(0.09, n=10, centre=APEX + (0, 0, -0.26)),
                      smooth=True))
    # the keel structure
    legs = []
    for sx in (-1, 1):
        for y in (-1.32, 1.28):
            legs.append(kit.rod((sx * (HX - 0.15), y, -HZ), APEX, 0.045, n=8))
    legs.append(kit.rod((0.0, -0.10, -HZ), APEX, 0.04, n=8))
    zc = -HZ - 0.80
    f = 0.80 / 1.75
    for sx in (-1, 1):
        a = np.array([sx * (HX - 0.15), -1.32, -HZ]) * (1 - f) + APEX * f
        b = np.array([sx * (HX - 0.15), 1.28, -HZ]) * (1 - f) + APEX * f
        legs.append(kit.rod(a, b, 0.03, n=6))
    legs.append(kit.rod((-0.4, 0.0, zc), (0.4, 0.0, zc), 0.025, n=6))
    p.append(kit.part("keel struts", STRUT, *legs))
    # ------------------------------------------------------- the cryostat
    drum = U.cylinder_fine(RD, 0.0, Y_BACK - Y_FRONT, n=48, max_len=0.35, caps=False)
    drum = kit.along(drum, (0, 1, 0), (0.0, Y_FRONT, ZD))
    p.append(U.tpart(kit, "IBSS cryostat (white blankets)", WHITE, drum, U.tex_mli(104, seams=3, depth=0.35), tile=0.9))
    # the back dome: a rounded shoulder, then a flattened crown, the
    # blanket's gores radiating from its centre (s39-17-017)
    n = 48
    prof = []
    for k in range(5):
        t = (math.pi / 2) * k / 4
        prof.append((RD - DOME + DOME * math.cos(t), Y_BACK + DOME * math.sin(t) * 0.8))
    for k in range(1, 5):
        r = (RD - DOME) * (1 - k / 4)
        prof.append((r, Y_BACK + DOME * 0.8 + 0.05 * (1 - (r / (RD - DOME)) ** 2)))
    P = []
    for r, yy in prof:
        a = np.linspace(0, 2 * math.pi, n, endpoint=False)
        P.append(np.column_stack([r * np.cos(a), np.full(n, yy), ZD + r * np.sin(a)]))
    P = np.vstack(P)
    T = []
    for k in range(len(prof) - 1):
        for i in range(n):
            j = (i + 1) % n
            a0, a1, b0, b1 = k * n + i, k * n + j, (k + 1) * n + i, (k + 1) * n + j
            T += [(a0, b0, b1), (a0, b1, a1)]
    dome = (P, np.asarray(T))

    def tex_gores(size=256, gores=16):
        from PIL import Image
        yy, xx = np.mgrid[0:size, 0:size] / size
        g = np.random.default_rng(105)
        v = 0.88 + 0.12 * U._blur(g.standard_normal((size, size)), 5) * 5
        seam = np.abs(((xx * gores) % 1) - 0.5) > 0.47
        v = np.where(seam, 0.6, v)
        return Image.fromarray((np.clip(np.stack([v] * 3, -1), 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))
    dm, duv = U.unshare(dome), None
    q = np.asarray(dm[0])
    ang = (np.arctan2(q[:, 2] - ZD, q[:, 0]) / (2 * math.pi)) % 1.0
    t = np.asarray(dm[1])
    tri = ang[t]
    for i in np.where(tri.max(1) - tri.min(1) > 0.5)[0]:
        for c in range(3):
            if tri[i, c] < 0.5:
                ang[t[i, c]] += 1.0
    rad_ = np.hypot(q[:, 0], q[:, 2] - ZD)
    duv = np.column_stack([ang, rad_ / RD]).astype(np.float32)
    p.append(kit.part("cryostat dome (blanket gores)", WHITE, dm, texture=tex_gores(), uv=duv))
    # the aperture end: a slightly smaller drum, then the thick ring
    p.append(U.tpart(kit, "aperture-end drum", WHITE, _drum_y(kit, RD - 0.10, RD - 0.10, Y_AP + 0.10, Y_FRONT + 0.01,
                                                            caps=False), U.tex_mli(106, seams=1, depth=0.35), tile=0.7))
    p.append(kit.part("drum front shoulder", (0.70, 0.70, 0.68),
                      kit.along(kit.disc(RD, 0.0, n=48, r_in=RD - 0.11), (0, -1, 0), (0.0, Y_FRONT, ZD))))
    ring = kit.along(kit.tube(0.46, 0.26, 0.0, 0.10, n=40), (0, 1, 0), (0.0, Y_AP, ZD))
    p.append(kit.part("aperture ring", (0.82, 0.82, 0.79), ring))
    p.append(kit.part("aperture-end face", (0.62, 0.62, 0.60),
                      kit.along(kit.disc(RD - 0.10, 0.0, n=48, r_in=0.46), (0, -1, 0), (0.0, Y_AP + 0.10, ZD))))
    p.append(kit.part("aperture (dark)", (0.03, 0.03, 0.03),
                      kit.along(kit.disc(0.26, 0.0, n=32), (0, -1, 0), (0.0, Y_AP + 0.06, ZD))))
    # the aperture cover, open: a black plate standing up over the ring,
    # with its hinge arms
    cover = kit.turn(kit.box((0.50, 0.03, 0.50)), kit.rot('x', -25))
    p.append(kit.part("aperture cover (open)", (0.06, 0.06, 0.07), kit.move(cover, (0.0, Y_AP - 0.12, ZD + 0.72)),
                      kit.rod((0.18, Y_AP + 0.02, ZD + 0.42), (0.18, Y_AP - 0.10, ZD + 0.60), 0.02, n=6),
                      kit.rod((-0.18, Y_AP + 0.02, ZD + 0.42), (-0.18, Y_AP - 0.10, ZD + 0.60), 0.02, n=6)))
    # boxes on the cryostat (s39-15-017: one on top near the aperture end,
    # one on its -Y shoulder) and the vent fittings
    p.append(U.tpart(kit, "cryostat boxes", WHITE, kit.merge(
        kit.box((0.30, 0.25, 0.22), (0.15, 0.22, ZD + RD + 0.10)),
        kit.box((0.20, 0.16, 0.20), (0.45, Y_FRONT + 0.04, ZD + 0.40))), U.tex_mli(107, seams=1), tile=0.4))
    p.append(kit.part("vent fittings", (0.70, 0.70, 0.72),
                      kit.along(kit.cylinder(0.035, 0.0, 0.10, n=10), (1, 0, 0), (RD - 0.02, 1.12, ZD + 0.10)),
                      kit.along(kit.cylinder(0.05, 0.0, 0.03, n=12), (1, 0, 0), (RD + 0.07, 1.12, ZD + 0.10))))
    # the lettering, on a thin label standing 5 mm off the drum's +X side
    from ._leo_astrospas import plate_part
    ang_l = math.radians(30)
    nrm = np.array([math.cos(ang_l), 0.0, math.sin(ang_l)])
    p.append(plate_part(kit, "MBB IBSS/SPAS II lettering", (1, 1, 1), tex_label(),
                        np.array([0.0, 0.42, ZD]) + nrm * (RD + 0.022), nrm, (0, 1, 0), 0.62, 0.24, thick=0.006))
    # the saddle: a blanket wedge each side under the drum, down into the deck
    sad = [_yz_box(kit, Y_FRONT + 0.02, Y_BACK - 0.02, HZ - 0.01, HZ + 0.22, sx * 0.42 - 0.20, sx * 0.42 + 0.20)
           for sx in (-1, 1)]
    p.append(U.tpart(kit, "cryostat saddle", WHITE, kit.merge(*sad), U.tex_mli(108, seams=1, depth=0.4), tile=0.6))
    # -------------------------------------------------- the -Y end's imagers
    p.append(U.tpart(kit, "imager electronics box (ribbed, blue)", (1, 1, 1),
                     kit.box((0.70, 0.61, 0.26), (0.18, -1.035, HZ + 0.13)), tex_ribbed(), tile=(0.61, 0.26),
                     axes=((0, 1, 0), (0, 0, 1))))
    tubes = [kit.along(kit.cylinder(0.11, 0.0, 0.81, n=20), (0, -1, 0), (x, y, HZ + 0.46))
             for x, y in ((0.36, -0.81), (-0.04, -0.66))]
    p.append(U.tpart(kit, "imager tubes (white blankets)", WHITE, kit.merge(*tubes), U.tex_mli(109, seams=1, depth=0.35),
                     tile=0.4))
    p.append(kit.part("imager apertures", (0.03, 0.03, 0.03),
                      *[kit.along(kit.disc(0.09, 0.0, n=20), (0, -1, 0), (x, y - 0.815, HZ + 0.46))
                        for x, y in ((0.36, -0.81), (-0.04, -0.66))]))
    posts = []
    for x, y in ((0.36, -0.81), (-0.04, -0.66)):
        for dy in (-0.15, -0.60):
            posts.append(kit.rod((x, y + dy, HZ + 0.26), (x, y + dy, HZ + 0.36), 0.018, n=6))
    p.append(kit.part("imager posts", (0.65, 0.65, 0.66), *posts))
    p.append(U.tpart(kit, "small boxes (-Y end)", WHITE, kit.merge(kit.box((0.25, 0.15, 0.22), (0.40, -1.45, HZ + 0.11)),
                                                                  kit.box((0.35, 0.40, 0.18), (-0.30, -1.80, HZ + 0.09))),
                     U.tex_mli(110, seams=1), tile=0.4))
    p.append(kit.part("dark box (-Y end)", (0.06, 0.06, 0.07), kit.box((0.25, 0.18, 0.15), (0.20, -1.65, HZ + 0.075))))
    # the TV camera under the -Y end, lens to +X
    p.append(kit.part("TV camera housing", (0.85, 0.85, 0.83), kit.box((0.30, 0.22, 0.22), (HX - 0.10, -1.92, -HZ - 0.13))))
    p.append(kit.part("TV camera lens", (0.03, 0.03, 0.03),
                      kit.along(kit.cylinder(0.075, 0.0, 0.08, n=16), (1, 0, 0), (HX + 0.05, -1.92, -HZ - 0.13))))
    # ------------------------------------------------- the +Y end section
    p.append(U.tpart(kit, "silver-blanketed boxes (+Y end)", (0.66, 0.66, 0.68),
                     kit.merge(kit.box((0.55, 0.40, 0.20), (0.30, 1.98, HZ + 0.10)),
                               kit.box((0.30, 0.25, 0.30), (-0.38, 2.02, HZ + 0.15))),
                     U.tex_mli(111, seams=1, depth=0.6), tile=0.35))
    p.append(kit.part("star sensor (black)", (0.04, 0.04, 0.05), kit.box((0.22, 0.22, 0.25), (-0.40, 1.55, HZ + 0.125))))
    # the grapple fixture on its round base plate with three brass cams
    p.append(kit.part("grapple base plate", (0.55, 0.56, 0.57),
                      kit.along(kit.cylinder(0.24, 0.0, 0.012, n=32), (0, 0, 1), (0.10, GF_Y, HZ))))
    cams = []
    for k in range(3):
        a = 2 * math.pi * k / 3 + 0.3
        d = np.array([math.cos(a), math.sin(a), 0.0])
        c0 = np.array([0.10, GF_Y, HZ + 0.012])
        cams.append(kit.rod(c0 + d * 0.20, c0 + d * 0.04 + (0, 0, 0.18), 0.018, n=6))
    p.append(kit.part("grapple cams (brass)", BRASS, *cams))
    for name, rgb, m in U.frgf(kit, (0.10, GF_Y, HZ + 0.017), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    return dict(meta=dict(name="IBSS on SPAS-II (STS-39)",
                          frame="SPAS-II: +X along the payload bay when berthed (the face with the "
                                "mirror radiators, which faced the crew cabin as STS-39 berthed it), "
                                "+Y across the bay between the longeron trunnions (+Y the grapple "
                                "fixture's end; the cryostat's aperture faces -Y -- until 2026 this "
                                "model had the cryostat along X), +Z up (the instruments' side; the "
                                "keel structure below); m; the carrier box's centre, ~0.3 m below "
                                "the whole's centre of mass (the cryostat sits on top)",
                          source="simple shapes measured on STS-39 photographs s39-15-017, s39-17-017, "
                                 "s39-19-015, s39-11-027 and preflight s91-27781/27784 (images.nasa.gov), "
                                 "scaled to the bay's trunnion span",
                          norad=21244, mag_1000km=2.5),
                parts=U.refine_parts(p))
