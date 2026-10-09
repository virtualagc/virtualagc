"""Shapes and procedural textures for smm.py (the Solar Maximum Mission).

Private to smm.py: oriented boxes, textured quads, a paraboloid dish, and
the two textures (the solar cells' atlas and a crinkled-blanket map), made
with a fixed random seed so that every build is the same.
"""
import math

import numpy as np


# ------------------------------------------------------------------ meshes
def frame(normal, tangent):
    """The rotation whose columns are (X, tangent, normal): a local box's x
    along the body's X, y along the face, z out of it."""
    x = np.array([1.0, 0.0, 0.0])
    t = np.asarray(tangent, float)
    n = np.asarray(normal, float)
    return np.column_stack([x, t / np.linalg.norm(t), n / np.linalg.norm(n)])


def obox(kit, size, centre, R=None):
    """A box of size (dx, dy, dz) in the local frame R (3x3, columns the
    local axes in the body), centred at centre (body)."""
    m = kit.box(size)
    if R is not None:
        m = kit.turn(m, R)
    return kit.move(m, centre)


def quad(p0, p1, p2, p3, uv=((0, 0), (1, 0), (1, 1), (0, 1))):
    """A flat quad (corners in order) and its corners' (u, v)."""
    pts = np.array([p0, p1, p2, p3], float)
    return (pts, np.array([(0, 1, 2), (0, 2, 3)])), np.asarray(uv, np.float32)


def merge_uv(items):
    """[(mesh, uv), ...] -> (mesh, uv) merged."""
    pts, tris, uvs, base = [], [], [], 0
    for (p, t), uv in items:
        pts.append(p)
        tris.append(np.asarray(t) + base)
        uvs.append(uv)
        base += len(p)
    return (np.vstack(pts), np.vstack(tris)), np.vstack(uvs).astype(np.float32)


def paraboloid(r, depth, n_r=10, n_a=48, flip=False):
    """A dish along +X: apex at the origin, rim (radius r) at x = depth,
    opening toward +X.  Shared points (draw it smooth)."""
    pts = [[0.0, 0.0, 0.0]]
    for i in range(1, n_r + 1):
        rho = r * i / n_r
        x = depth * (rho / r) ** 2
        for k in range(n_a):
            a = 2 * math.pi * k / n_a
            pts.append([x, rho * math.cos(a), rho * math.sin(a)])
    tris = []
    for k in range(n_a):
        tris.append((0, 1 + k, 1 + (k + 1) % n_a))
    for i in range(1, n_r):
        b0, b1 = 1 + (i - 1) * n_a, 1 + i * n_a
        for k in range(n_a):
            j = (k + 1) % n_a
            tris += [(b0 + k, b1 + k, b1 + j), (b0 + k, b1 + j, b0 + j)]
    t = np.array(tris)
    if flip:
        t = t[:, ::-1]
    return np.array(pts), t


# ---------------------------------------------------------------- textures
def _blur(a, radius):
    from PIL import Image, ImageFilter
    im = Image.fromarray(np.uint8(np.clip(a * 255, 0, 255)))
    return np.asarray(im.filter(ImageFilter.GaussianBlur(radius)), float) / 255.0


def blanket_texture(size=512, seed=11703):
    """Multilayer insulation's outer layer, crinkled: a pale grey map
    (sRGB ~175-255) to multiply a blanket's colour by."""
    from PIL import Image
    rng = np.random.default_rng(seed)
    a = np.zeros((size, size))
    for radius, w in ((24, 0.55), (9, 0.30), (3, 0.15)):
        a += w * (_blur(rng.random((size, size)), radius) - 0.5)
    a = (a - a.min()) / (a.max() - a.min())
    # creases: a few long soft streaks
    yy, xx = np.mgrid[0:size, 0:size]
    for _ in range(14):
        ang = rng.uniform(0, math.pi)
        off = rng.uniform(-size / 2, size / 2)
        d = np.abs((xx - size / 2) * math.sin(ang) - (yy - size / 2) * math.cos(ang) - off)
        a -= 0.25 * np.exp(-(d / rng.uniform(1.5, 4.0)) ** 2)
    a = (a - a.min()) / (a.max() - a.min())
    g = 0.69 + 0.31 * a
    rgb = np.uint8(np.clip(np.dstack([g, g, g]) * 255, 0, 255))
    return Image.fromarray(rgb)


# The solar array's panels: 3 a wing, each 1.18 m (tangential, the atlas's
# u) by 2.20 m (radial, v), at ~2.1 mm a pixel.  v = 0 the wing's inner
# (body) edge.  Colours sRGB.
PANEL_PX = (560, 1040)
CELL = (70, 72, 132)            # the cells, a violet blue (as the STS-41C photographs show them)
GAP = (22, 22, 30)
EDGE = (176, 112, 56)           # copper-coloured edge members
SEAM = (196, 150, 70)           # the gold-coloured strip across each panel's middle
STRIP = (104, 30, 34)           # the maroon strips (bare substrate) on some panels


def cells_atlas(seed=1984):
    """The three panels of a wing side by side: (PIL image, panel count)."""
    from PIL import Image
    rng = np.random.default_rng(seed)
    w, h = PANEL_PX
    img = np.zeros((h, 3 * w, 3), float)
    cw, ch = 10, 19                       # a cell, 2 cm x 4 cm
    for k in range(3):
        p = np.zeros((h, w, 3), float)
        p[:] = GAP
        ny, nx = h // ch + 1, w // cw + 1
        shade = rng.normal(1.0, 0.07, (ny, nx))
        bright = rng.random((ny, nx)) < 0.006
        for j in range(ny):
            for i in range(nx):
                s = shade[j, i] * (1.6 if bright[j, i] else 1.0)
                c = np.clip(np.array(CELL) * s, 0, 255)
                p[j * ch + 1:(j + 1) * ch, i * cw + 1:(i + 1) * cw] = c
        e = 9
        p[:e, :] = EDGE
        p[-e:, :] = EDGE
        p[:, :e] = EDGE
        p[:, -e:] = EDGE
        mid = h // 2
        p[mid - 9:mid + 9, :] = SEAM
        # streaks of solder along the seam, as the photographs show
        jit = rng.integers(-3, 4, w)
        for i in range(w):
            p[mid - 11 + jit[i]:mid - 9, i] = (150, 105, 50)
        # the maroon strips (bare substrate) -- as on the STS-41C photographs
        if k == 0:
            p[60:mid - 9, 330:400] = STRIP
        elif k == 1:
            p[e:150, 250:340] = STRIP
        else:
            p[mid + 9:mid + 260, 150:225] = STRIP
        img[:, k * w:(k + 1) * w] = p
    return Image.fromarray(np.uint8(np.clip(img, 0, 255))), 3


# The paddles' backs: white (the substrate's white paint) with the wiring
# harness laid over it in dark-brown runs -- as the STS-41C photographs of
# the released observatory show them: two runs across the wing's width, jogging
# over the middle panel, a radial trunk up the middle panel's centre and
# short branches, each run dotted with tie-downs.  The atlas is the whole
# wing's back, u across the three panels (as cells_atlas), v radial.
BACK_PX = (3 * 280, 520)
BACK = (232, 232, 228)
HARNESS = (92, 62, 40)
TIE = (60, 40, 26)


def back_atlas(seed=1985):
    from PIL import Image, ImageDraw
    rng = np.random.default_rng(seed)
    w, h = BACK_PX
    pw = w // 3
    img = Image.new("RGB", (w, h), BACK)
    d = ImageDraw.Draw(img)
    for k in range(3):                         # each panel a shade apart, a grey frame
        s = int(rng.integers(-6, 6))
        d.rectangle([k * pw, 0, (k + 1) * pw - 1, h - 1], fill=tuple(c + s for c in BACK),
                    outline=(150, 150, 148), width=4)
    def run(pts, width=4, ties=True):
        d.line(pts, fill=HARNESS, width=width, joint="curve")
        if not ties:
            return
        for (x0, y0), (x1, y1) in zip(pts[:-1], pts[1:]):
            L = math.hypot(x1 - x0, y1 - y0)
            for t in np.arange(8, L, 16):
                x, y = x0 + (x1 - x0) * t / L, y0 + (y1 - y0) * t / L
                d.rectangle([x - 3, y - 3, x + 3, y + 3], fill=TIE)
    # the two long runs across the wing (v ~ 0.40 and 0.56), jogging over the middle panel
    run([(10, int(0.40 * h)), (int(1.15 * pw), int(0.40 * h)), (int(1.30 * pw), int(0.47 * h)),
         (int(1.70 * pw), int(0.47 * h)), (int(1.85 * pw), int(0.40 * h)), (w - 10, int(0.40 * h))])
    run([(10, int(0.62 * h)), (int(1.10 * pw), int(0.62 * h)), (int(1.25 * pw), int(0.55 * h)),
         (int(1.75 * pw), int(0.55 * h)), (int(1.90 * pw), int(0.62 * h)), (w - 10, int(0.62 * h))])
    # the radial trunk to the yoke (v = 0, the inner edge) up the middle panel, doubled
    for du in (-10, 10):
        run([(int(1.5 * pw) + du, 0), (int(1.5 * pw) + du, int(0.80 * h))], width=5)
    # short radial branches on the outer panels (a cross with each long run)
    for xc in (int(0.5 * pw), int(2.5 * pw)):
        run([(xc, int(0.25 * h)), (xc, int(0.78 * h))], width=3)
    # the panels' hinge-line cable crossings
    for k in (1, 2):
        run([(k * pw - 14, int(0.51 * h)), (k * pw + 14, int(0.51 * h))], width=3, ties=False)
    return img
