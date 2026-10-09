"""Shapes for mir.py beyond kit's: lathed hulls, textured solar wings,
dishes, handrails, docking hardware -- and the textures they use.

Meshes are kit's (points, triangles), metres, made along +X like kit's;
a mesh that carries texture coordinates is a TMESH, (points, triangles, uv).
"""
import math

import numpy as np

from . import kit


# ------------------------------------------------------------------ helpers
def tmerge(*tmeshes):
    """Textured meshes merged: (points, triangles, uv)."""
    pts, tris, uvs, base = [], [], [], 0
    for p, t, u in tmeshes:
        pts.append(np.asarray(p, float))
        tris.append(np.asarray(t, int) + base)
        uvs.append(np.asarray(u, float))
        base += len(p)
    return np.vstack(pts), np.vstack(tris), np.vstack(uvs)


def tplace(tm, R=np.eye(3), at=(0.0, 0.0, 0.0)):
    p, t, u = tm
    return p @ np.asarray(R, float).T + np.asarray(at, float), t, u


def frame_of(x, y):
    """The rotation taking +X to x and +Y to (y made perpendicular to x)."""
    x = np.asarray(x, float)
    x = x / np.linalg.norm(x)
    y = np.asarray(y, float)
    y = y - x * np.dot(x, y)
    y = y / np.linalg.norm(y)
    return np.column_stack([x, y, np.cross(x, y)])


def place(mesh, R=np.eye(3), at=(0.0, 0.0, 0.0)):
    p, t = mesh
    return p @ np.asarray(R, float).T + np.asarray(at, float), t


# ------------------------------------------------------------------- hulls
def lathe(profile, n=64, phase=0.0, uv=None):
    """A surface of revolution about X through profile [(x, r), ...] -- one
    smooth band, its points shared (so kit.part(smooth=True) rounds it round
    the axis and along gentle profile changes).  Sharp corners: make
    separate lathes.  uv=(u_repeats, v_metres): also texture coordinates,
    u round the axis, v along the profile's length."""
    prof = np.asarray(profile, float)
    m = len(prof)
    a = np.linspace(0.0, 2 * math.pi, n + 1) + phase       # seam repeated, for u
    pts = np.zeros((m, n + 1, 3))
    pts[:, :, 0] = prof[:, :1]
    pts[:, :, 1] = prof[:, 1:2] * np.cos(a)
    pts[:, :, 2] = prof[:, 1:2] * np.sin(a)
    tris = []
    for k in range(m - 1):
        for i in range(n):
            p0, p1 = k * (n + 1) + i, k * (n + 1) + i + 1
            q0, q1 = p0 + n + 1, p1 + n + 1
            tris += [(p0, p1, q1), (p0, q1, q0)]
    pts = pts.reshape(-1, 3)
    tris = np.array(tris)
    if uv is None:
        # weld the seam (smooth normals across it)
        idx = np.arange(m * (n + 1)).reshape(m, n + 1)
        remap = idx.copy()
        remap[:, n] = idx[:, 0]
        return pts, remap.ravel()[tris]
    s = np.concatenate([[0.0], np.cumsum(np.hypot(np.diff(prof[:, 0]), np.diff(prof[:, 1])))])
    u = np.tile(a - phase, (m, 1)) / (2 * math.pi) * uv[0]
    v = np.repeat(s[:, None], n + 1, axis=1) / uv[1]
    return pts, tris, np.column_stack([u.ravel(), v.ravel()])


def seam_normals(p, t):
    """Normals for a textured lathe whose seam points are doubled: averaged
    over coincident points too."""
    n = np.zeros_like(p)
    f = np.cross(p[t[:, 1]] - p[t[:, 0]], p[t[:, 2]] - p[t[:, 0]])
    for j in range(3):
        np.add.at(n, t[:, j], f)
    key = np.round(p, 5)
    _, inv = np.unique(key, axis=0, return_inverse=True)
    inv = inv.ravel()
    acc = np.zeros((inv.max() + 1, 3))
    np.add.at(acc, inv, n)
    n = acc[inv]
    return n / np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)


def bands(x0, x1, r, n=64, count=3, w=0.06, h=0.012):
    """Raised ring frames (stiffening rings, blanket straps) round a cylinder."""
    out = []
    for k in range(count):
        x = x0 + (x1 - x0) * (k + 0.5) / count
        out.append(kit.tube(r + h, r - 0.01, x - w / 2, x + w / 2, n))
    return out


def ring(r, x, w, h, n=64):
    """One raised ring of width w standing h proud of radius r, at x."""
    return kit.tube(r + h, r - 0.02, x - w / 2, x + w / 2, n)


# ------------------------------------------------------------ small things
def on_hull(mesh, r, theta, x):
    """A mesh made at the origin with +X outward (up from the hull) set on a
    cylinder of radius r at angle theta (deg, from +Y toward +Z) and station x."""
    t = math.radians(theta)
    out = np.array([0.0, math.cos(t), math.sin(t)])
    R = frame_of(out, (1.0, 0.0, 0.0))
    return place(mesh, R, np.array([x, 0, 0]) + out * r)


def handrail(p0, p1, standoff=0.08, r=0.012, n=6):
    """An EVA handrail p0-p1 standing off a surface along `standoff` vector
    (or, if a number, along the rail's own perpendicular +radial guess)."""
    p0, p1 = np.asarray(p0, float), np.asarray(p1, float)
    s = np.asarray(standoff, float)
    out = [kit.rod(p0 + s, p1 + s, r, n), kit.rod(p0, p0 + s, r * 0.8, n), kit.rod(p1, p1 + s, r * 0.8, n)]
    L = np.linalg.norm(p1 - p0)
    if L > 1.2:
        k = int(L / 0.6)
        for j in range(1, k):
            q = p0 + (p1 - p0) * j / k
            out.append(kit.rod(q, q + s, r * 0.8, n))
    return kit.merge(*out)


def hull_rails(r, x0, x1, thetas, standoff=0.09):
    """Lengthwise handrails along a cylinder at angles thetas (deg)."""
    out = []
    for th in thetas:
        t = math.radians(th)
        d = np.array([0.0, math.cos(t), math.sin(t)])
        out.append(handrail(np.array([x0, 0, 0]) + d * r, np.array([x1, 0, 0]) + d * r, d * standoff))
    return kit.merge(*out)


def hoop_rail(r, x, th0, th1, standoff=0.09, segs=8):
    """A handrail round part of a hoop at station x, th0..th1 deg."""
    out = []
    pts = []
    for j in range(segs + 1):
        t = math.radians(th0 + (th1 - th0) * j / segs)
        pts.append(np.array([x, (r + standoff) * math.cos(t), (r + standoff) * math.sin(t)]))
    for j in range(segs):
        out.append(kit.rod(pts[j], pts[j + 1], 0.012, 6))
    for j in (0, segs // 2, segs):
        d = pts[j] - np.array([x, 0, 0])
        d /= np.linalg.norm(d)
        out.append(kit.rod(pts[j] - d * standoff, pts[j], 0.010, 6))
    return kit.merge(*out)


def dish(r, depth, n=24, rings=6, thick=0.01):
    """A parabolic dish opening toward +X, its vertex at the origin."""
    prof = [(depth * (k / rings) ** 2, r * k / rings) for k in range(rings + 1)]
    prof[0] = (0.0, 1e-4)
    front = lathe(prof, n)
    back = lathe([(x - thick, rr) for x, rr in prof], n)
    return kit.merge(front, back, kit.tube(r, r - 0.02, depth - thick, depth, n))


def boom_dish(r, depth, boom, n=24):
    """A dish on a boom: boom along +X from the origin, the dish at its end facing +X."""
    return kit.merge(kit.cylinder(0.035, 0.0, boom, 8),
                     kit.move(dish(r, depth, n), (boom, 0, 0)),
                     kit.rod((boom + depth, 0, 0), (boom + depth * 1.6, 0, 0), 0.012, 6))


def whip(length, r=0.008):
    """A rod antenna along +X."""
    return kit.merge(kit.cylinder(r * 3, 0.0, 0.08, 8), kit.cylinder(r, 0.08, length, 6))


def kurs_antenna(boom=0.9, r=0.18):
    """A Kurs-style antenna: a short boom with a small dish/helix head."""
    return kit.merge(kit.cylinder(0.03, 0.0, boom, 8),
                     kit.move(dish(r, 0.06, 16, 3), (boom, 0, 0)),
                     kit.cylinder(0.025, boom, boom + 0.25, 8))


def thruster_block(n=4, size=0.22):
    """An attitude-thruster cluster: a box with n nozzles out along +X."""
    out = [kit.box((0.12, size * 1.6, size), (0.06, 0, 0))]
    for k in range(n):
        y = (k - (n - 1) / 2) * size * 1.4 / max(n - 1, 1)
        out.append(kit.move(kit.frustum(0.025, 0.05, 0.12, 0.22, 10), (0, y, 0)))
    return kit.merge(*out)


def hull_panel(r, theta, width_deg, x0, x1, n=6):
    """A curved panel (a radiator, a blanket patch) standing off a cylinder:
    radius r, centred at theta deg, width_deg wide, from x0 to x1."""
    a0 = math.radians(theta - width_deg / 2)
    a1 = math.radians(theta + width_deg / 2)
    pts, tris = [], []
    for i in range(n + 1):
        t = a0 + (a1 - a0) * i / n
        pts += [[x0, r * math.cos(t), r * math.sin(t)], [x1, r * math.cos(t), r * math.sin(t)]]
    for i in range(n):
        tris += [(2 * i, 2 * i + 2, 2 * i + 3), (2 * i, 2 * i + 3, 2 * i + 1)]
    return np.array(pts), np.array(tris)


# --------------------------------------------------------- docking hardware
def probe_drogue(x, r_collar=0.8, active=True, fwd=1):
    """A Soyuz-type docking assembly at station x, facing fwd (+1/-1 along X):
    a collar ring, a cone (drogue, passive) or a probe (active)."""
    s = fwd
    out = [kit.frustum(r_collar, r_collar * 0.92, x, x + s * 0.12, 48),
           kit.tube(r_collar + 0.05, r_collar - 0.05, min(x, x + s * 0.05), max(x, x + s * 0.05), 48)]
    if active:
        out += [kit.frustum(0.35, 0.12, x + s * 0.12, x + s * 0.45, 24),
                kit.cylinder(0.05, x + s * 0.45, x + s * 0.95, 12),
                kit.frustum(0.05, 0.015, x + s * 0.95, x + s * 1.05, 12)]
    return kit.merge(*out)


def apas(x, fwd=1, r=0.80):
    """An androgynous peripheral (APAS-89) docking unit at x facing fwd:
    the structural ring with its three guide petals."""
    s = fwd
    out = [kit.tube(r, r - 0.13, min(x, x + s * 0.25), max(x, x + s * 0.25), 48),
           kit.tube(r - 0.05, r - 0.22, min(x + s * 0.25, x + s * 0.4), max(x + s * 0.25, x + s * 0.4), 48)]
    for k in range(3):
        t = math.radians(120 * k + 30)
        d = np.array([0, math.cos(t), math.sin(t)])
        e = np.array([0, -math.sin(t), math.cos(t)])
        base = np.array([x + s * 0.40, 0, 0]) + d * (r - 0.14)
        tip = np.array([x + s * 0.72, 0, 0]) + d * (r - 0.38)
        w = 0.32
        pts = np.array([base - e * w, base + e * w, tip + e * 0.06, tip - e * 0.06])
        quad = (pts, np.array([(0, 1, 2), (0, 2, 3)]))
        out.append(quad)
        out.append(kit.move(quad, d * 0.012))            # its back, standing off
    return kit.merge(*out)


# --------------------------------------------------------------- textures
_TEX = {}


def cell_texture(kind='russian'):
    """A tiling texture of solar cells (one tile = 8 x 8 cells), as a PIL image,
    multiplied in portview by the part's colour (so it is near white where
    the cell is its nominal colour)."""
    if kind in _TEX:
        return _TEX[kind]
    from PIL import Image
    rng = np.random.default_rng(16609 + len(kind))
    N, c = 256, 32                     # 8 x 8 cells of 32 px
    img = np.zeros((N, N, 3))
    yy, xx = np.mgrid[0:N, 0:N]
    cy, cx = yy // c, xx // c
    tint = rng.normal(1.0, 0.06, (N // c, N // c, 3))
    tint[..., 2] = tint[..., 0] * rng.normal(1.0, 0.03, (N // c, N // c))
    base = tint[cy, cx]
    if kind == 'russian':              # violet-blue silicon, dark gaps
        base = base * np.array([0.95, 0.92, 1.0])
    elif kind == 'us':                 # the cooperative array: darker, bluer cells
        base = base * np.array([0.85, 0.9, 1.05])
    # gaps between cells and the bus lines
    gap = ((yy % c) < 2) | ((xx % c) < 2)
    img = base.copy()
    img[gap] = 0.25
    bus = ((xx % c) == c // 2) & ~gap
    img[bus] = img[bus] * 0.7 + 0.15
    img = np.clip(img * 0.85 * 255, 0, 255).astype(np.uint8)
    _TEX[kind] = Image.fromarray(img)
    return _TEX[kind]


def back_texture():
    """A tiling texture for a wing's back: pale substrate, darker lines
    where the cells' edges show through."""
    if 'back' in _TEX:
        return _TEX['back']
    from PIL import Image
    N, c = 256, 32
    yy, xx = np.mgrid[0:N, 0:N]
    v = np.full((N, N), 0.9)
    v[((yy % c) < 2) | ((xx % c) < 2)] = 0.75
    v[((yy % (4 * c)) < 4)] = 0.6
    _TEX['back'] = Image.fromarray(np.clip(np.dstack([v, v, v * 0.97]) * 255, 0, 255).astype(np.uint8))
    return _TEX['back']


def _periodic_noise(rng, N, slope):
    """Tileable noise, N x N, its spectrum falling as f**-slope; 0..1."""
    fy = np.fft.fftfreq(N)[:, None]
    fx = np.fft.fftfreq(N)[None, :]
    f = np.hypot(fx, fy)
    f[0, 0] = 1.0
    spec = (rng.normal(size=(N, N)) + 1j * rng.normal(size=(N, N))) / f ** slope
    spec[0, 0] = 0
    v = np.real(np.fft.ifft2(spec))
    return (v - v.min()) / np.ptp(v)


def blanket_texture(kind='white'):
    """A tiling texture of thermal blanket: blotchy wrinkles, patches of
    slightly different shades (the separate blankets) with darker seams
    and stitch lines -- near 1 (the part's colour) on average."""
    key = 'blanket-' + kind
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    rng = np.random.default_rng(1986)
    N = 512
    big = _periodic_noise(rng, N, 1.6)
    fine = _periodic_noise(rng, N, 0.9)
    v = 0.90 + 0.16 * (big - 0.5) + 0.08 * (fine - 0.5)
    yy, xx = np.mgrid[0:N, 0:N]
    # blanket pieces: rows of varying height, each cut into pieces of
    # varying width (like brickwork), each its own shade, seams darker
    shade = np.ones((N, N))
    seam = np.zeros((N, N), bool)
    ys = [0]
    while ys[-1] < N:
        ys.append(min(N, ys[-1] + int(rng.integers(90, 170))))
    if N - ys[-2] < 60:
        ys[-2] = N
        ys.pop()
    for y0, y1 in zip(ys[:-1], ys[1:]):
        xs = [int(rng.integers(0, 80))]
        while xs[-1] < xs[0] + N:
            xs.append(xs[-1] + int(rng.integers(100, 220)))
        xs[-1] = xs[0] + N
        for x0, x1 in zip(xs[:-1], xs[1:]):
            cols = np.arange(x0, x1) % N
            shade[y0:y1, cols] = rng.uniform(0.94, 1.05)
            seam[y0:y1, x0 % N] = True
        seam[y0, :] = True
    v *= shade
    sm = seam | np.roll(seam, 1, 0) | np.roll(seam, 1, 1)
    v[sm] *= 0.86
    stitch = (((xx % 128) < 1) & ((yy % 7) < 4)) | (((yy % 128) < 1) & ((xx % 7) < 4))
    v[stitch] *= 0.90
    img = np.clip(np.dstack([v, v * 0.995, v * 0.97]) * 255, 0, 255).astype(np.uint8)
    _TEX[key] = Image.fromarray(img)
    return _TEX[key]


# -------------------------------------------------------------- solar wings
def wing(span, width, panels, root_gap=0.3, hinge_frac=0.5, thickness=0.03, frame_w=0.04,
         cells_per_m=None, mast=True, mast_r=0.05):
    """A solar wing lying in the X-Y plane (cells facing +Z), its root at the
    origin and its span out along +Y, `width` along X (centred on X = 0):
    `panels` panels across the span, each a textured cell face (and a plain
    back, stood off), a frame round each, and a central mast if mast.
    Returns (cells TMESH, backs TMESH, frames mesh)."""
    cells, backs, frames = [], [], []
    pw = (span - root_gap) / panels
    tile_m = 0.4                         # metres per texture tile (8 cells of 5 cm)
    gap = 0.03
    for k in range(panels):
        y0 = root_gap + k * pw + gap / 2
        y1 = root_gap + (k + 1) * pw - gap / 2
        for half in ((-width / 2, -frame_w / 2), (frame_w / 2, width / 2)) if mast else ((-width / 2, width / 2),):
            x0, x1 = half
            p = np.array([[x0, y0, thickness / 2], [x1, y0, thickness / 2], [x1, y1, thickness / 2],
                          [x0, y1, thickness / 2]])
            uv = np.array([[x0, y0], [x1, y0], [x1, y1], [x0, y1]]) / tile_m
            t = np.array([(0, 1, 2), (0, 2, 3)])
            cells.append((p, t, uv))
            q = p.copy()
            q[:, 2] = -thickness / 2
            backs.append((q, t[:, ::-1], uv))
            # the frame: thin box edges
            for (a, b) in (((x0, y0), (x1, y0)), ((x0, y1), (x1, y1)), ((x0, y0), (x0, y1)), ((x1, y0), (x1, y1))):
                c = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2, 0.0)
                sx = abs(b[0] - a[0]) or frame_w * 0.5
                sy = abs(b[1] - a[1]) or frame_w * 0.5
                frames.append(kit.box((sx, sy, thickness * 0.8), c))
    if mast:
        frames.append(kit.rod((0, 0, 0), (0, span, 0), mast_r, 8))
    return tmerge(*cells), tmerge(*backs), kit.merge(*frames)


# ------------------------------------------------------------ an assembly
class Assembly(object):
    """Geometry gathered by material across a whole vehicle: add() meshes
    (or textured meshes) under a material name, transformed by R and at;
    parts() gives kit parts, one per material.  Materials: name ->
    dict(rgb=..., smooth=bool, texture=PIL image or None)."""

    def __init__(self, materials):
        self.materials = materials
        self.geo = {k: [] for k in materials}

    def add(self, mat, mesh, R=np.eye(3), at=(0.0, 0.0, 0.0)):
        if mat not in self.materials:
            raise KeyError(mat)
        R = np.asarray(R, float)
        at = np.asarray(at, float)
        if len(mesh) == 3:
            p, t, u = mesh
            self.geo[mat].append((p @ R.T + at, np.asarray(t, int), np.asarray(u, float)))
        else:
            p, t = mesh
            self.geo[mat].append((p @ R.T + at, np.asarray(t, int), None))

    def sub(self, R=np.eye(3), at=(0.0, 0.0, 0.0)):
        """A view of this assembly that adds through a further transform
        (for building a module in its own frame)."""
        return _Sub(self, np.asarray(R, float), np.asarray(at, float))

    def parts(self, kit):
        out = []
        for name, spec in self.materials.items():
            g = self.geo[name]
            if not g:
                continue
            pts, tris, uvs, base = [], [], [], 0
            for p, t, u in g:
                pts.append(p)
                tris.append(t + base)
                uvs.append(u if u is not None else np.zeros((len(p), 2)))
                base += len(p)
            P, T, U = np.vstack(pts), np.vstack(tris), np.vstack(uvs)
            tex = spec.get('texture')
            part = kit.part(name, spec['rgb'], (P, T), smooth=spec.get('smooth', False),
                            texture=tex, uv=U.astype(np.float32) if tex is not None else None)
            if spec.get('smooth') and tex is not None:
                part['nrm'] = seam_normals(P, T)
            out.append(part)
        return out

    def points(self):
        return np.vstack([p for g in self.geo.values() for p, _, _ in g])


class _Sub(object):
    def __init__(self, parent, R, at):
        self.parent, self.R, self.at = parent, R, at

    def add(self, mat, mesh, R=np.eye(3), at=(0.0, 0.0, 0.0)):
        R2 = self.R @ np.asarray(R, float)
        at2 = self.R @ np.asarray(at, float) + self.at
        self.parent.add(mat, mesh, R2, at2)

    def sub(self, R=np.eye(3), at=(0.0, 0.0, 0.0)):
        return _Sub(self.parent, self.R @ np.asarray(R, float), self.R @ np.asarray(at, float) + self.at)


# ------------------------------------------------------- solar arrays, placed
def _quad(p0, p1, p2, p3, tile=0.4, uvs=None):
    p = np.array([p0, p1, p2, p3], float)
    uv = (np.array(uvs, float) if uvs is not None else p[:, :2]) / tile
    return p, np.array([(0, 1, 2), (0, 2, 3)]), uv


def wing_frame(span_dir, normal):
    """Rotation taking a wing's own axes (width X, span Y, cells +Z) to the
    given span direction and cell-face normal (made perpendicular)."""
    s = np.asarray(span_dir, float)
    s = s / np.linalg.norm(s)
    n = np.asarray(normal, float)
    n = n - s * np.dot(n, s)
    n = n / np.linalg.norm(n)
    return np.column_stack([np.cross(s, n), s, n])


def solar_wing(a, root, span_dir, normal, length, width, panels, style='grid', mats=None,
               root_gap=0.4, mast_w=0.30, damage=None, tilt=7.0, rails=True):
    """A solar wing into assembly a: from `root` out along span_dir for
    `length` m, `width` m across, its cells facing `normal`.
    style 'grid': a central mast with rigid panels either side (`panels`
    along the span), framed -- Mir's usual wings.  style 'accordion': one
    column of `panels` narrow panels folded alternately by +-tilt deg (the
    Kristall-type collapsible wings, and the US-Russian cooperative array),
    on a lattice mast behind.  mats: dict(cells=, back=, frame=, mast=).
    damage: {panel index: 'missing' | degrees (bent about its root edge)},
    a key (k, side) for one column of a grid wing (side -1, +1)."""
    m = dict(cells='cells', back='panel back', frame='array frame', mast='array frame')
    m.update(mats or {})
    damage = damage or {}
    R = wing_frame(span_dir, normal)
    root = np.asarray(root, float)
    t = 0.025
    cells, backs, frames = [], [], []
    if style == 'grid':
        pitch = (length - root_gap) / panels
        gap = 0.05
        col_w = (width - mast_w) / 2
        for k in range(panels):
            y0 = root_gap + k * pitch + gap / 2
            y1 = y0 + pitch - gap
            for side in (-1, 1):
                d = damage.get((k, side), damage.get(k))
                if d == 'missing':
                    continue
                xa, xb = sorted((side * mast_w / 2, side * (mast_w / 2 + col_w)))
                q = [np.array(v, float) for v in ((xa, y0, 0), (xb, y0, 0), (xb, y1, 0), (xa, y1, 0))]
                if d:                                 # bent about its root edge
                    Rb = kit.rot('x', d)
                    q = [Rb @ (v - q[0] * [0, 1, 1]) + q[0] * [0, 1, 1] for v in q]
                nrm = np.cross(q[1] - q[0], q[3] - q[0])
                nrm /= np.linalg.norm(nrm)
                up = [v + nrm * t / 2 for v in q]
                dn = [v - nrm * t / 2 for v in q]
                uv = [(v[0], v[1]) for v in ((xa, y0), (xb, y0), (xb, y1), (xa, y1))]
                cells.append(_quad(*up, uvs=uv))
                p, tr, u = _quad(*dn, uvs=uv)
                backs.append((p, tr[:, ::-1], u))
                for e0, e1 in ((0, 1), (1, 2), (2, 3), (3, 0)):
                    frames.append(kit.rod(q[e0], q[e1], 0.018, 4))
                # a cross member half way
                frames.append(kit.rod((q[0] + q[3]) / 2, (q[1] + q[2]) / 2, 0.012, 4))
        # the mast: a box-section lattice along the middle
        L = length
        for x in (-mast_w / 2, mast_w / 2):
            for z in (-0.05, 0.05):
                frames.append(kit.rod((x, 0, z), (x, L, z), 0.02, 4))
        nb = int(L / 0.6)
        for j in range(nb + 1):
            y = L * j / nb
            frames.append(kit.rod((-mast_w / 2, y, 0.05), (mast_w / 2, y, 0.05), 0.012, 4))
            frames.append(kit.rod((-mast_w / 2, y, -0.05), (mast_w / 2, y, -0.05), 0.012, 4))
            if j < nb:
                frames.append(kit.rod((-mast_w / 2, y, 0.05), (mast_w / 2, L * (j + 1) / nb, 0.05), 0.010, 4))
    else:                                             # accordion
        pitch = (length - root_gap) / panels
        h = pitch * math.sin(math.radians(tilt))
        for k in range(panels):
            d = damage.get(k)
            if d == 'missing':
                continue
            y0 = root_gap + k * pitch
            y1 = y0 + pitch * math.cos(math.radians(tilt)) / math.cos(math.radians(tilt))
            z0, z1 = (0.0, h) if k % 2 == 0 else (h, 0.0)
            q = [np.array(v, float) for v in ((-width / 2, y0, z0), (width / 2, y0, z0),
                                              (width / 2, y1, z1), (-width / 2, y1, z1))]
            if d:
                Rb = kit.rot('x', d)
                q = [Rb @ (v - q[0] * [0, 1, 1]) + q[0] * [0, 1, 1] for v in q]
            nrm = np.cross(q[1] - q[0], q[3] - q[0])
            nrm /= np.linalg.norm(nrm)
            up = [v + nrm * 0.006 for v in q]
            dn = [v - nrm * 0.006 for v in q]
            uv = [(v[0], v[1]) for v in ((-width / 2, y0), (width / 2, y0), (width / 2, y1), (-width / 2, y1))]
            cells.append(_quad(*up, uvs=uv))
            p, tr, u = _quad(*dn, uvs=uv)
            backs.append((p, tr[:, ::-1], u))
            frames.append(kit.rod(q[0], q[1], 0.010, 4))
        # edge rails (the guide wires) and the lattice mast behind
        if rails:
            for x in (-width / 2 - 0.02, width / 2 + 0.02):
                frames.append(kit.rod((x, 0, h / 2), (x, length, h / 2), 0.012, 4))
        mz = -0.25
        frames.append(truss_mesh((0, 0, mz), (0, length, mz), 0.32, max(4, int(length / 0.5)), 0.012))
        frames.append(kit.box((width + 0.1, 0.12, 0.12), (0, length + 0.06, h / 2)))   # the tip bar
        frames.append(kit.box((width + 0.1, 0.35, 0.40), (0, 0.18, 0.0)))             # the canister
    out = R
    for c in cells:
        a.add(m['cells'], c, out, root)
    for b in backs:
        a.add(m['back'], b, out, root)
    for f in frames:
        a.add(m['frame'], f, out, root)


def truss_mesh(p0, p1, width, bays, r, sides=3):
    """kit.truss with thin 4-sided rods (cheap)."""
    p0, p1 = np.asarray(p0, float), np.asarray(p1, float)
    L = float(np.linalg.norm(p1 - p0))
    meshes = []
    ang = [2 * math.pi * k / sides + math.pi / sides for k in range(sides)]
    corner = lambda k, x: np.array([x, 0.5 * width * math.cos(ang[k]), 0.5 * width * math.sin(ang[k])])
    for k in range(sides):
        meshes.append(kit.rod(corner(k, 0), corner(k, L), r, 4))
        for b in range(bays + 1):
            x = L * b / bays
            meshes.append(kit.rod(corner(k, x), corner((k + 1) % sides, x), r * 0.7, 4))
            if b < bays:
                meshes.append(kit.rod(corner(k, x), corner((k + 1) % sides, L * (b + 1) / bays), r * 0.6, 4))
    return kit.along(kit.merge(*meshes), p1 - p0, p0)


# ------------------------------------------------------------ hull clutter
def clutter(a, r, x0, x1, count, seed, avoid=(), mats=('blanket flat', 'metal', 'gold', 'dark')):
    """The small things on a Russian hull: equipment boxes under blankets,
    cylinders (tanks, sensors, connectors), EVA handholds and foot
    restraints, scattered over a cylinder of radius r between x0 and x1
    (module frame, axis X).  avoid: [(theta_deg, half_width_deg), ...]."""
    rng = np.random.default_rng(seed)
    boxm, metal, gold, dark = mats
    placed = 0
    tries = 0
    while placed < count and tries < count * 20:
        tries += 1
        t = float(rng.uniform(0, 360))
        if any(abs((t - c + 180) % 360 - 180) < w for c, w in avoid):
            continue
        x = float(rng.uniform(x0, x1))
        kind = rng.random()
        if kind < 0.45:                                  # a blanketed box
            h, w, l = rng.uniform(0.10, 0.35), rng.uniform(0.25, 0.8), rng.uniform(0.3, 1.0)
            a.add(boxm if rng.random() < 0.85 else gold, on_hull(kit.box((h, w, l), (h / 2, 0, 0)), r, t, x))
        elif kind < 0.65:                                # a cylinder lying along the hull
            rr, l = rng.uniform(0.06, 0.16), rng.uniform(0.3, 0.9)
            m = kit.along(kit.cylinder(rr, 0.0, l, 10), (0, 0, 1), (rr + 0.02, 0, -l / 2))
            a.add(metal if rng.random() < 0.6 else boxm, on_hull(m, r, t, x), )
        elif kind < 0.80:                                # a sensor or connector, standing up
            rr, l = rng.uniform(0.05, 0.12), rng.uniform(0.1, 0.3)
            a.add(dark if rng.random() < 0.4 else metal, on_hull(kit.cylinder(rr, 0.0, l, 10), r, t, x))
        else:                                            # a short handrail across the hull
            tt = math.radians(t)
            dt = 0.5 / r
            p0 = np.array([x, r * math.cos(tt - dt / 2), r * math.sin(tt - dt / 2)])
            p1 = np.array([x, r * math.cos(tt + dt / 2), r * math.sin(tt + dt / 2)])
            d = np.array([0, math.cos(tt), math.sin(tt)])
            a.add('rail', handrail(p0, p1, d * 0.08))
        placed += 1
