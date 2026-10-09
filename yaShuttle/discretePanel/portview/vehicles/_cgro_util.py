"""Private helpers for cgro.py and erbs.py: mesh refinement, texture mapping
and procedural textures (blankets, louvres, cells, domes ...), with a few
shapes kit lacks (extrusions, a paraboloid dish).

Much of this is copied from _leo_util.py (refine, the UV mappings, the
grapple fixture), so that these two models don't move when that shared file
does; the rest is new.  Meshes are kit's (points, triangles), metres.
"""
import math

import numpy as np


# ------------------------------------------------------------------ geometry
def frame_from(normal, up_hint=(0.0, 0.0, 1.0)):
    """A rotation whose +X is normal (a fixture's outward axis)."""
    n = np.asarray(normal, float)
    n = n / np.linalg.norm(n)
    u = np.asarray(up_hint, float)
    if abs(np.dot(u, n)) > 0.95:
        u = np.array([0.0, 1.0, 0.0]) if abs(n[1]) < 0.9 else np.array([1.0, 0.0, 0.0])
    y = np.cross(u, n)
    y /= np.linalg.norm(y)
    z = np.cross(n, y)
    return np.column_stack([n, y, z])


def place(kit, mesh, R, at):
    return kit.move(kit.turn(mesh, R), at)


def flip(mesh):
    p, t = mesh
    return p, np.asarray(t)[:, ::-1].copy()


def _cap(n, centre_index, ring, reverse=False):
    out = []
    for i in range(n):
        j = (i + 1) % n
        out.append((centre_index, ring[j], ring[i]) if not reverse else (centre_index, ring[i], ring[j]))
    return out


def extrude(poly, a0, a1, axis='y'):
    """A prism whose section is the convex polygon poly (2-D points, in
    order) between a0 and a1 along axis: for 'y' the points are (x, z), for
    'z' (x, y), for 'x' (y, z)."""
    p = np.asarray(poly, float)
    n = len(p)
    c = p.mean(0)

    def lift(q, a):
        if axis == 'y':
            return np.column_stack([q[:, 0], np.full(len(q), a), q[:, 1]])
        if axis == 'z':
            return np.column_stack([q[:, 0], q[:, 1], np.full(len(q), a)])
        return np.column_stack([np.full(len(q), a), q[:, 0], q[:, 1]])
    pts = np.vstack([lift(p, a0), lift(p, a1), lift(c[None], a0), lift(c[None], a1)])
    tris = []
    for i in range(n):
        j = (i + 1) % n
        tris += [(i, j, n + j), (i, n + j, n + i), (2 * n, j, i), (2 * n + 1, n + i, n + j)]
    return pts, np.asarray(tris)


def rounded_rect(x0, x1, z0, z1, r0=0.0, r1=0.0, k=6):
    """A rectangle's outline (x0..x1, z0..z1) with its top corners rounded:
    radius r0 at the x0 end, r1 at the x1 end, k segments each."""
    pts = [(x0, z0), (x1, z0)]
    if r1 > 0:
        for i in range(k + 1):
            t = math.pi / 2 * i / k
            pts.append((x1 - r1 + r1 * math.cos(t), z1 - r1 + r1 * math.sin(t)))
    else:
        pts.append((x1, z1))
    if r0 > 0:
        for i in range(k + 1):
            t = math.pi / 2 + math.pi / 2 * i / k
            pts.append((x0 + r0 + r0 * math.cos(t), z1 - r0 + r0 * math.sin(t)))
    else:
        pts.append((x0, z1))
    return pts


def dish(R, depth, n=40, m=6, thickness=0.0):
    """A paraboloid reflector along +X: its rim radius R at x = depth, vertex
    at 0 (a single sheet; portview draws both sides)."""
    rows = [np.zeros((1, 3))]
    for k in range(1, m + 1):
        rho = R * k / m
        a = np.linspace(0.0, 2 * math.pi, n, endpoint=False)
        rows.append(np.column_stack([np.full(n, depth * (rho / R) ** 2), rho * np.cos(a), rho * np.sin(a)]))
    pts = np.vstack(rows)
    tris = [(0, 1 + (i + 1) % n, 1 + i) for i in range(n)]
    for k in range(1, m):
        b0, b1 = 1 + (k - 1) * n, 1 + k * n
        for i in range(n):
            j = (i + 1) % n
            tris += [(b0 + i, b0 + j, b1 + j), (b0 + i, b1 + j, b1 + i)]
    return pts, np.asarray(tris)


def sphere_z(r, n=16, centre=(0.0, 0.0, 0.0), z_lo=None, z_hi=None):
    """A UV sphere round Z (n bands pole to pole, 2n round), optionally only
    between heights z_lo and z_hi above its centre (a dome or a truncated
    ball), open where cut."""
    lo = -r if z_lo is None else z_lo
    hi = r if z_hi is None else z_hi
    t0, t1 = math.acos(max(-1, min(1, hi / r))), math.acos(max(-1, min(1, lo / r)))
    m = 2 * n
    rows = []
    for k in range(n + 1):
        th = t0 + (t1 - t0) * k / n
        a = np.linspace(0.0, 2 * math.pi, m, endpoint=False)
        rows.append(np.column_stack([r * math.sin(th) * np.cos(a), r * math.sin(th) * np.sin(a),
                                     np.full(m, r * math.cos(th))]))
    pts = np.vstack(rows)
    tris = []
    for k in range(n):
        for i in range(m):
            j = (i + 1) % m
            a, b, c, d = k * m + i, k * m + j, (k + 1) * m + j, (k + 1) * m + i
            tris += [(a, d, c), (a, c, b)]
    return pts + np.asarray(centre, float), np.asarray(tris)


def tube_z(r, z0, z1, n=48, centre=(0.0, 0.0), caps=False, max_len=0.5):
    """A cylinder round Z between z0 and z1 at (x, y) = centre, its side cut
    into rings no more than max_len apart (see refine), smooth-ready."""
    m = max(1, int(math.ceil(abs(z1 - z0) / max_len)))
    a = np.linspace(0.0, 2 * math.pi, n, endpoint=False)
    rows = [np.column_stack([centre[0] + r * np.cos(a), centre[1] + r * np.sin(a),
                             np.full(n, z0 + (z1 - z0) * s / m)]) for s in range(m + 1)]
    pts = np.vstack(rows)
    tris = []
    for s in range(m):
        b0, b1 = s * n, (s + 1) * n
        for i in range(n):
            j = (i + 1) % n
            tris += [(b0 + i, b0 + j, b1 + j), (b0 + i, b1 + j, b1 + i)]
    if caps:
        c0, c1 = len(pts), len(pts) + 1
        pts = np.vstack([pts, [[centre[0], centre[1], z0], [centre[0], centre[1], z1]]])
        tris += _cap(n, c0, list(range(n)), reverse=False)
        tris += _cap(n, c1, list(range(m * n, m * n + n)), reverse=True)
    return pts, np.asarray(tris)


def radial_normals(mesh, centre, axis):
    """Smooth normals for a surface of revolution: from the axis (through
    centre, along axis) out to each point."""
    p = np.asarray(mesh[0], float) - np.asarray(centre, float)
    a = np.asarray(axis, float) / np.linalg.norm(axis)
    q = p - np.outer(p @ a, a)
    return q / np.maximum(np.linalg.norm(q, axis=1, keepdims=True), 1e-12)


def sphere_normals(mesh, centre):
    p = np.asarray(mesh[0], float) - np.asarray(centre, float)
    return p / np.maximum(np.linalg.norm(p, axis=1, keepdims=True), 1e-12)


# --------------------------------------------------------------- refinement
# portview interpolates depth linearly across the screen: across a long
# triangle seen obliquely it is wrong by ~L^2 / (8 d), so big surfaces with
# other surfaces close behind or in front are cut to pieces <= ~0.5 m.
def refine(mesh, max_len=0.5):
    """Every triangle cut into k x k smaller ones (k the same for the whole
    mesh, so neighbours match), enough that no edge exceeds max_len."""
    p, t = np.asarray(mesh[0], float), np.asarray(mesh[1], int)
    if len(t) == 0:
        return p, t
    e = np.concatenate([np.linalg.norm(p[t[:, i]] - p[t[:, (i + 1) % 3]], axis=1) for i in range(3)])
    k = int(math.ceil(e.max() / max_len))
    if k <= 1:
        return p, t
    loc = [(i, j) for i in range(k + 1) for j in range(k + 1 - i)]
    index = {ij: n for n, ij in enumerate(loc)}
    sub = []
    for i in range(k):
        for j in range(k - i):
            sub.append((index[(i, j)], index[(i + 1, j)], index[(i, j + 1)]))
            if i + j < k - 1:
                sub.append((index[(i + 1, j)], index[(i + 1, j + 1)], index[(i, j + 1)]))
    loc = np.asarray(loc, float) / k
    sub = np.asarray(sub, int)
    a, b, c = p[t[:, 0]], p[t[:, 1]], p[t[:, 2]]
    w0 = 1.0 - loc[:, 0] - loc[:, 1]
    pts = (a[:, None, :] * w0[None, :, None] + b[:, None, :] * loc[None, :, 0, None]
           + c[:, None, :] * loc[None, :, 1, None])
    g = len(loc)
    tris = (sub[None, :, :] + (np.arange(len(t)) * g)[:, None, None]).reshape(-1, 3)
    pts = pts.reshape(-1, 3)
    key = np.round(pts / 1e-6).astype(np.int64)
    _, first, inv = np.unique(key, axis=0, return_index=True, return_inverse=True)
    return pts[first], inv.ravel()[tris]


def refine_each(meshes, max_len=0.5):
    """refine() each mesh on its own grid (a big panel doesn't make a small
    bracket's triangles tiny), merged."""
    pts, tris, base = [], [], 0
    for m in meshes:
        p, t = refine(m, max_len)
        pts.append(p)
        tris.append(np.asarray(t) + base)
        base += len(p)
    return np.vstack(pts), np.vstack(tris)


def _components(t, npts):
    parent = np.arange(npts)

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i
    for a, b, c in t:
        ra, rb, rc = find(a), find(b), find(c)
        parent[rb] = ra
        parent[find(rc)] = ra
    roots = np.array([find(i) for i in range(npts)])
    labels = roots[t[:, 0]]
    return [np.where(labels == r)[0] for r in np.unique(labels)]


def refine_parts(parts, max_len=0.5):
    """refine() every flat, untextured part, each connected piece with its
    own grid; thin things (struts, rods) left alone."""
    for p in parts:
        if p.get('nrm') is not None or p.get('uv') is not None or p.get('texture') is not None:
            continue
        pos, idx = np.asarray(p['pos'], float), np.asarray(p['idx'], int).reshape(-1, 3)
        if len(idx) == 0:
            continue
        e = np.concatenate([np.linalg.norm(pos[idx[:, i]] - pos[idx[:, (i + 1) % 3]], axis=1) for i in range(3)])
        if e.max() <= max_len:
            continue
        meshes = []
        for comp in _components(idx, len(pos)):
            q = pos[np.unique(idx[comp])]
            q = q - q.mean(0)
            ax = np.linalg.svd(q, full_matrices=False)[2]
            ext = np.sort(np.ptp(q @ ax.T, axis=0))
            meshes.append((pos, idx[comp]) if ext[1] < max(0.25, 0.1 * ext[2]) else refine((pos, idx[comp]), max_len))
        P, T, base = [], [], 0
        for mp, mt in meshes:
            used = np.unique(mt)
            remap = np.full(len(mp), -1)
            remap[used] = np.arange(len(used))
            P.append(mp[used])
            T.append(remap[mt] + base)
            base += len(used)
        p['pos'], p['idx'] = np.vstack(P), np.vstack(T)
    return parts


# ------------------------------------------------------------- UV mappings
def unshare(mesh):
    p, t = mesh
    p = np.asarray(p, float)[np.asarray(t).ravel()]
    return p, np.arange(len(p)).reshape(-1, 3)


def planar_uv(mesh, tile=1.0, axes=None, offset=(0.0, 0.0)):
    """(mesh unshared, uv): box mapping (each triangle on the body plane its
    normal is nearest), tile metres a repeat (number or (u, v)); or one
    projection on axes (two vectors)."""
    p, t = unshare(mesh)
    tu, tv = (tile, tile) if np.isscalar(tile) else tile
    uv = np.zeros((len(p), 2), np.float32)
    if axes is not None:
        a, b = (np.asarray(x, float) for x in axes)
        uv[:, 0] = p @ a / tu + offset[0]
        uv[:, 1] = p @ b / tv + offset[1]
        return (p, t), uv
    tri = p[t]
    n = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    dom = np.argmax(np.abs(n), axis=1)
    for k, (i, j) in enumerate(((1, 2), (0, 2), (0, 1))):
        sel = np.where(dom == k)[0]
        for c in range(3):
            v = t[sel, c]
            uv[v, 0] = p[v, i] / tu + offset[0]
            uv[v, 1] = p[v, j] / tv + offset[1]
    return (p, t), uv


def _azimuth_fix(ang, t):
    """Angles (turns, 0..1) per point of an unshared mesh: triangles that
    straddle the seam get their small values lifted a turn."""
    tri = ang[t]
    wrap = (tri.max(1) - tri.min(1)) > 0.5
    for i in np.where(wrap)[0]:
        for c in range(3):
            if tri[i, c] < 0.5:
                ang[t[i, c]] += 1.0
    return ang


def axial_uv(mesh, centre, axis, tile_len=1.0, n_round=1.0, ref=None):
    """(mesh unshared, uv) for a surface round an axis: u round it (n_round
    repeats a turn), v along it (tile_len m a repeat)."""
    p, t = unshare(mesh)
    a = np.asarray(axis, float) / np.linalg.norm(axis)
    e1 = np.asarray(ref if ref is not None else frame_from(a)[:, 1], float)
    e1 = e1 - a * np.dot(e1, a)
    e1 /= np.linalg.norm(e1)
    e2 = np.cross(a, e1)
    q = p - np.asarray(centre, float)
    ang = (np.arctan2(q @ e2, q @ e1) / (2 * np.pi)) % 1.0
    ang = _azimuth_fix(ang, t)
    uv = np.column_stack([ang * n_round, (q @ a) / tile_len]).astype(np.float32)
    return (p, t), uv


def polar_uv(mesh, centre, axis, n_round=12, n_lat=4.0, ref=None):
    """(mesh unshared, uv) for a dome or ball round an axis: u the azimuth
    (n_round repeats a turn: one gore each), v the angle from the pole
    (n_lat repeats a quarter turn)."""
    p, t = unshare(mesh)
    a = np.asarray(axis, float) / np.linalg.norm(axis)
    e1 = np.asarray(ref if ref is not None else frame_from(a)[:, 1], float)
    e1 = e1 - a * np.dot(e1, a)
    e1 /= np.linalg.norm(e1)
    e2 = np.cross(a, e1)
    q = p - np.asarray(centre, float)
    r = np.maximum(np.linalg.norm(q, axis=1), 1e-12)
    ang = (np.arctan2(q @ e2, q @ e1) / (2 * np.pi)) % 1.0
    ang = _azimuth_fix(ang, t)
    lat = np.arccos(np.clip((q @ a) / r, -1, 1)) / (np.pi / 2)
    # near the pole the azimuth is meaningless: take the triangle's others'
    near = lat < 1e-6
    if near.any():
        tri_of = np.repeat(np.arange(len(t)), 3)
        for v in np.where(near)[0]:
            others = [w for w in t[tri_of[v]] if w != v]
            ang[v] = ang[others].mean()
    uv = np.column_stack([ang * n_round, lat * n_lat]).astype(np.float32)
    return (p, t), uv


def tpart(kit, name, rgb, mesh, image, tile=1.0, axes=None, fine=None, uvmap=None, normals=None):
    """A textured part: box-mapped (tile, axes; see planar_uv) unless uvmap
    is a ready (mesh, uv); fine: refine the mesh first; normals: a function
    of the unshared points giving smooth normals (else flat)."""
    if uvmap is not None:
        m, uv = uvmap
    else:
        if fine:
            mesh = refine(mesh, fine)
        m, uv = planar_uv(mesh, tile, axes)
    out = kit.part(name, rgb, m, smooth=False, texture=image, uv=uv)
    if normals is not None:
        out['nrm'] = normals(np.asarray(m[0], float))
    return out


# ------------------------------------------------------------------ fixtures
ALUMINIUM = (0.55, 0.55, 0.56)
BLACK = (0.03, 0.03, 0.03)


def frgf(kit, at, normal, up=(0.0, 0.0, 1.0)):
    """A flight-releasable grapple fixture standing out of a surface at `at`
    along `normal`: base plate, shaft, cam-arm tip, and the black-and-white
    target post beside it: [(name, rgb, mesh)]."""
    R = frame_from(normal, up)
    base = kit.box((0.025, 0.36, 0.36), (0.0125, 0, 0))
    shaft = kit.cylinder(0.035, 0.025, 0.36, n=12)
    tip = kit.box((0.04, 0.10, 0.02), (0.34, 0, 0))
    collar = kit.cylinder(0.11, 0.025, 0.06, n=16)
    post = kit.move(kit.cylinder(0.012, 0.025, 0.40, n=8), (0, 0, 0.13))
    disc = kit.move(kit.disc(0.06, 0.40, n=16), (0, 0, 0.13))
    rim = kit.move(kit.cylinder(0.065, 0.395, 0.399, n=16, caps=False), (0, 0, 0.13))
    return [("grapple fixture", ALUMINIUM, kit.merge(*[place(kit, m, R, at) for m in (base, shaft, tip, collar)])),
            ("grapple target", (0.85, 0.85, 0.85), place(kit, disc, R, at)),
            ("grapple target post", BLACK, kit.merge(place(kit, post, R, at), place(kit, rim, R, at)))]


# ------------------------------------------------------------------ textures
# Procedural images (multiplying a part's albedo; stored sRGB as the others'
# are), each cached by its arguments.
_TEX = {}


def _img(a):
    from PIL import Image
    a = np.clip(a, 0, 1)
    if a.ndim == 2:
        a = np.stack([a] * 3, -1)
    return Image.fromarray((a ** (1 / 2.2) * 255 + 0.5).astype(np.uint8))


def _blur(a, r):
    """A box blur, r pixels, wrapping (the textures repeat)."""
    for ax in (0, 1):
        acc = np.zeros_like(a)
        for d in range(-r, r + 1):
            acc += np.roll(a, d, axis=ax)
        a = acc / (2 * r + 1)
    return a


def _noise(g, size, r):
    a = _blur(g.standard_normal((size, size)), r)
    return a / max(a.std(), 1e-9)


def _creases(g, size, count, width, strength):
    """Long straight creases (wrapping): bright/dark lines at random angles."""
    yy, xx = np.mgrid[0:size, 0:size].astype(float)
    a = np.zeros((size, size))
    for _ in range(count):
        t = g.uniform(0, np.pi)
        c = g.uniform(0, size)
        d = np.abs(((xx * np.cos(t) + yy * np.sin(t) - c) + size / 2) % size - size / 2)
        a += g.choice((-1, 1)) * strength * g.uniform(0.4, 1.0) * np.exp(-(d / width) ** 2)
    return a


def tex_blanket(seed=1, size=256, depth=0.25, crinkle=1.0, seams=2, seam_dark=0.7, tint=(1, 1, 1),
                buttons=True, glints=0.0):
    """A multilayer blanket: soft billows, creases (crinkle: how many and how
    sharp -- 1 for beta cloth, 3 for crumpled Kapton), darker seams `seams`
    to a repeat each way, tie-down buttons; glints: bright specks where
    crumpled foil catches the light."""
    key = ('blanket', seed, size, depth, crinkle, seams, seam_dark, tint, buttons, glints)
    if key in _TEX:
        return _TEX[key]
    g = np.random.default_rng(seed)
    a = _noise(g, size, 10) * 1.0 + _noise(g, size, 3) * 0.5 * crinkle
    a += _creases(g, size, int(10 * crinkle), 1.2 + 0.6 / crinkle, 1.4)
    if crinkle > 1.5:                      # crumpled foil: facets
        f = _noise(g, size, 2)
        a += np.sign(f) * np.abs(f) ** 0.5 * 0.8
    a = (a - a.min()) / (a.max() - a.min())
    v = 1.0 - depth + depth * a
    if glints > 0:
        s = _noise(g, size, 1)
        v = np.where(s > 2.3, v + glints * (s - 2.3), v)
    yy, xx = np.mgrid[0:size, 0:size]
    if seams:
        step = size // seams
        for k in range(seams):
            s = k * step
            v[max(0, s - 1):s + 2, :] *= seam_dark
            v[:, max(0, s - 1):s + 2] *= seam_dark
            if buttons:
                for b in range(3):
                    cy, cx = s + step // 2, b * (size // 3) + size // 6
                    v[(yy - cy) ** 2 + (xx - cx) ** 2 < 6] *= 0.75
    v = v / max(v.max(), 1e-9)
    rgb = np.stack([v * c for c in tint], -1)
    _TEX[key] = _img(rgb)
    return _TEX[key]


def tex_louvres(n=8, size=256, frame=0.08, slat=0.70, gap=0.10, vertical=False, seed=4):
    """A louvred radiator: n bright slats side by side along u (each blade
    running along v; vertical=True: the other way), dark gaps, a frame round
    it (one repeat = one radiator panel)."""
    key = ('louvres', n, size, frame, slat, gap, vertical, seed)
    if key in _TEX:
        return _TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:size, 0:size] + 0.5) / size
    u, w = (xx, yy) if not vertical else (yy, xx)
    inside = (xx > frame) & (xx < 1 - frame) & (yy > frame) & (yy < 1 - frame)
    f = ((u - frame) / (1 - 2 * frame) * n) % 1.0
    jit = g.uniform(0.85, 1.0, n + 2)[np.clip(((u - frame) / (1 - 2 * frame) * n).astype(int), 0, n + 1)]
    slats = np.where(f < 1 - gap, slat * jit * (0.85 + 0.15 * np.sin(np.pi * f / (1 - gap))), 0.12)
    v = np.where(inside, slats, 0.55)
    _TEX[key] = _img(v)
    return _TEX[key]


def tex_osr(nx=8, ny=8, size=256, seed=6, base=0.85, spread=0.25, line=0.45):
    """Optical solar reflector tiles (second-surface mirrors): a grid of
    tiles each catching the light differently, dark lines between."""
    key = ('osr', nx, ny, size, seed, base, spread, line)
    if key in _TEX:
        return _TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:size, 0:size] + 0.5) / size
    jit = g.uniform(base - spread, base, (ny, nx))
    v = jit[(yy * ny).astype(int) % ny, (xx * nx).astype(int) % nx]
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    v = np.where((fx < 0.04) | (fx > 0.96) | (fy < 0.04) | (fy > 0.96), v * line, v)
    _TEX[key] = _img(v)
    return _TEX[key]


def tex_cells(nx=8, ny=8, size=256, gap=0.06, seed=3, line=0.5, jitter=0.15, tint=(1, 1, 1),
              border=0.0, border_rgb=(1, 1, 1), dots=0):
    """A solar-cell grid: nx x ny cells to a repeat, lighter gaps between
    (the substrate: 1/line the cells' brightness), each cell a little
    different; border: a substrate margin (fraction) round the repeat in
    border_rgb (relative brightness, before the part's albedo); dots: bright
    specks (interconnect tabs) per cell row."""
    key = ('cells', nx, ny, size, gap, seed, line, jitter, tint, border, border_rgb, dots)
    if key in _TEX:
        return _TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:size, 0:size] + 0.5) / size
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    cell = (fx > gap / 2) & (fx < 1 - gap / 2) & (fy > gap / 2) & (fy < 1 - gap / 2)
    jit = g.uniform(1 - jitter, 1.0, (ny, nx))
    v = np.where(cell, jit[(yy * ny).astype(int) % ny, (xx * nx).astype(int) % nx], 1.0 / line)
    rgb = np.stack([v * c for c in tint], -1)
    if dots:
        cx, cy = (xx * nx).astype(int), (yy * ny).astype(int)
        sel = (np.abs(fx - 0.5) < 0.06) & (np.abs(fy - 0.5) < 0.06) & ((cx + cy) % max(1, dots) == 0)
        rgb[sel] = 3.0
    if border > 0:
        edge = (xx < border) | (xx > 1 - border) | (yy < border) | (yy > 1 - border)
        rgb[edge] = np.asarray(border_rgb, float)
    rgb = rgb / max(rgb.max(), 1e-9)
    _TEX[key] = _img(rgb)
    return _TEX[key]


def tex_gores(size=256, line=4.0, ring=True, seed=9, base=0.30, mottle=0.35):
    """A blanketed dome, one gore to a repeat in u (the azimuth) and a
    latitude band in v: bright taped seams at the gore's edges (line: their
    brightness relative to the panel) and across the band; the film mottled
    (reflections of a cloudy Earth)."""
    key = ('gores', size, line, ring, seed, base, mottle)
    if key in _TEX:
        return _TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:size, 0:size] + 0.5) / size
    v = base * (1.0 + mottle * _noise(g, size, 12))
    v += base * 0.25 * _creases(g, size, 6, 1.5, 1.0)
    seam = np.exp(-((np.minimum(xx, 1 - xx)) / 0.012) ** 2)
    if ring:
        seam = np.maximum(seam, np.exp(-((np.minimum(yy, 1 - yy)) / 0.015) ** 2))
    v = v * (1 - seam) + base * line * seam
    _TEX[key] = _img(v / max(v.max(), 1e-9))
    return _TEX[key]


def tex_grid_panel(size=256, nx=6, ny=6, dot=True, seed=7, line=0.8):
    """A painted panel with a faint grid of rivet lines and fastener dots."""
    key = ('gridpanel', size, nx, ny, dot, seed, line)
    if key in _TEX:
        return _TEX[key]
    g = np.random.default_rng(seed)
    yy, xx = (np.mgrid[0:size, 0:size] + 0.5) / size
    v = 0.95 + 0.05 * _noise(g, size, 8) * 0.5
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    v = np.where((fx < 0.02) | (fy < 0.02), v * line, v)
    if dot:
        v = np.where(((fx - 0.5) ** 2 + (fy - 0.5) ** 2) < 0.004, v * 0.4, v)
    _TEX[key] = _img(v / max(v.max(), 1e-9))
    return _TEX[key]
