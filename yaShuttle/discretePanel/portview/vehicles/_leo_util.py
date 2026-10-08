"""Shared helpers for the LEO free-flyers (ldef, eureca, sfu, the SPAS and
Spartan carriers ...): small fixtures that recur on Shuttle-serviced
payloads, made from kit's shapes.  Everything in metres; each function
returns a list of (name, rgb, mesh, smooth) tuples or a mesh, as noted."""
import math

import numpy as np

WHITE = (0.80, 0.80, 0.78)
SILVER_MLI = (0.62, 0.62, 0.64)
GOLD_MLI = (0.72, 0.56, 0.28)
ALUMINIUM = (0.55, 0.55, 0.56)
DARK = (0.05, 0.05, 0.06)
BLACK = (0.03, 0.03, 0.03)
CELLS = (0.04, 0.05, 0.12)           # silicon cells
CELLS_BACK = (0.55, 0.55, 0.52)      # the array's back (Kapton/glass cloth)
GREY = (0.35, 0.35, 0.36)


def frame_from(normal, up_hint=(0.0, 0.0, 1.0)):
    """A rotation whose +X is normal (the fixture's outward axis)."""
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


def frgf(kit, at, normal, up=(0.0, 0.0, 1.0), active=False):
    """A flight-releasable grapple fixture standing out of a surface at `at`
    along `normal`: its 0.35 m square base plate, the 0.06 m shaft, the
    0.25 m cam-arm 'tip', and the black-and-white target off to one side.
    Returns [(name, rgb, mesh)]."""
    R = frame_from(normal, up)
    base = kit.box((0.025, 0.36, 0.36), (0.0125, 0, 0))
    shaft = kit.cylinder(0.035, 0.025, 0.36, n=12)
    tip = kit.box((0.04, 0.10, 0.02), (0.34, 0, 0))
    collar = kit.cylinder(0.11, 0.025, 0.06, n=16)
    tgt_post = kit.cylinder(0.012, 0.025, 0.40, n=8, phase=0.0)
    tgt_post = kit.move(tgt_post, (0, 0, 0.13))
    tgt_disc = kit.move(kit.disc(0.06, 0.40, n=16), (0, 0, 0.13))
    tgt_back = kit.move(kit.cylinder(0.065, 0.395, 0.399, n=16, caps=False), (0, 0, 0.13))
    out = [("grapple fixture", ALUMINIUM if not active else (0.30, 0.30, 0.32),
            kit.merge(*[place(kit, m, R, at) for m in (base, shaft, tip, collar)])),
           ("grapple target", (0.85, 0.85, 0.85), place(kit, tgt_disc, R, at)),
           ("grapple target post", BLACK, kit.merge(place(kit, tgt_post, R, at), place(kit, tgt_back, R, at)))]
    return out


def trunnion(kit, at, axis, length=0.25, r=0.04):
    """A payload-bay trunnion pin: a 3.25-inch rod from `at` along axis."""
    a = np.asarray(axis, float)
    return kit.rod(np.asarray(at, float), np.asarray(at, float) + length * a / np.linalg.norm(a), r, n=12)


def solar_wing(kit, root, span_dir, width_dir, length, width, panels=1, gap=0.04,
               thickness=0.03, cells=CELLS, back=CELLS_BACK, frame=ALUMINIUM, start=0.0,
               face=None):
    """A flat solar array from root, along span_dir for `length` (beginning
    `start` out), `width` across width_dir, cut into `panels` with gaps;
    the cells on the face toward `face` (default span x width), the back
    another material: [(name, rgb, mesh)]."""
    s = np.asarray(span_dir, float)
    s /= np.linalg.norm(s)
    w = np.asarray(width_dir, float)
    w /= np.linalg.norm(w)
    n = np.cross(s, w) if face is None else np.asarray(face, float) / np.linalg.norm(face)
    R = np.column_stack([n, s, w])                 # box axes: thickness, span, width
    root = np.asarray(root, float)
    pl = (length - gap * (panels - 1)) / panels
    cell_m, back_m, edge_m = [], [], []
    for k in range(panels):
        c = start + k * (pl + gap) + pl / 2
        cell_m.append(place(kit, kit.box((0.004, pl - 0.02, width - 0.02), (thickness / 2 + 0.002, c, 0)), R, root))
        back_m.append(place(kit, kit.box((thickness, pl, width), (0, c, 0)), R, root))
    return [("solar cells", cells, kit.merge(*cell_m)), ("solar array back", back, kit.merge(*back_m))]


def ngon_face_frames(n, r_apothem, phase_deg=0.0):
    """For an n-sided prism along X with flat faces: [(outward unit normal,
    point on the face centre-line at x=0)], face k's normal at angle
    phase + k*360/n about +X from +Y."""
    out = []
    for k in range(n):
        t = math.radians(phase_deg + 360.0 * k / n)
        nrm = np.array([0.0, math.cos(t), math.sin(t)])
        out.append((nrm, nrm * r_apothem))
    return out


def ngon_prism(kit, n, r_apothem, x0, x1, phase_deg=0.0, caps=True, fine=None):
    """An n-sided prism along X whose face k's normal is at phase + k*360/n
    from +Y (kit.cylinder puts corners there; turn by half a side)."""
    R_corner = r_apothem / math.cos(math.pi / n)
    # kit's _ring puts a corner at angle `phase` from +Y; a face centre is half a side on.
    ph = math.radians(phase_deg) - math.pi / n
    if fine and caps:           # few sides: refine the closed prism uniformly
        return refine(kit.cylinder(R_corner, x0, x1, n=n, caps=True, phase=ph), fine)
    if fine:
        return cylinder_fine(R_corner, x0, x1, n=n, max_len=fine, caps=False, phase=ph)
    return kit.cylinder(R_corner, x0, x1, n=n, caps=caps,
                        phase=math.radians(phase_deg) - math.pi / n)


def flip(mesh):
    """The same surface facing the other way (e.g. the inside of a drum)."""
    p, t = mesh
    return p, np.asarray(t)[:, ::-1].copy()


def facing_aft(kit, mesh, x):
    """A mesh made facing +X (a kit.disc), turned to face -X, at X = x."""
    return kit.move(kit.turn(mesh, kit.rot('z', 180)), (x, 0, 0))


# ------------------------------------------------------------------ textures
# Procedural greyscale-ish textures (PIL images) that multiply a part's
# albedo, mapped by planar projection: enough surface detail (blanket
# wrinkles and seams, cell grids) to read at proximity-operations range.
_TEX = {}


def _rng(seed):
    return np.random.default_rng(seed)


def _blur(a, r):
    """A cheap box blur, r pixels, wrapping (textures repeat)."""
    for ax in (0, 1):
        acc = np.zeros_like(a)
        for d in range(-r, r + 1):
            acc += np.roll(a, d, axis=ax)
        a = acc / (2 * r + 1)
    return a


def tex_mli(seed=1, size=256, seams=2, depth=0.40, tint=(1.0, 1.0, 1.0)):
    """Multilayer blanket: soft wrinkles and creases, darker seams `seams`
    to a repeat each way, with tie-down buttons."""
    key = ('mli', seed, size, seams, depth, tint)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    g = _rng(seed)
    a = _blur(g.standard_normal((size, size)), 6) * 6
    a += _blur(g.standard_normal((size, size)), 2) * 1.2
    # creases: a few long bright/dark streaks
    yy, xx = np.mgrid[0:size, 0:size]
    for _ in range(14):
        t = g.uniform(0, np.pi)
        c = g.uniform(0, size)
        d = np.abs((xx * np.cos(t) + yy * np.sin(t) - c + size) % size - size / 2) if False else \
            np.abs(((xx * np.cos(t) + yy * np.sin(t) - c) + size / 2) % size - size / 2)
        a += g.choice((-1, 1)) * 1.6 * np.exp(-(d / 1.5) ** 2)
    a = (a - a.min()) / (a.max() - a.min())
    v = 1.0 - depth + depth * a
    step = size // max(seams, 1)
    for k in range(seams):
        s = k * step
        v[max(0, s - 1):s + 2, :] *= 0.55
        v[:, max(0, s - 1):s + 2] *= 0.55
        for b in range(seams * 3):
            cy, cx = s + step // 2, b * (size // (seams * 3)) + size // (seams * 6)
            v[(yy - cy) ** 2 + (xx - cx) ** 2 < 5] *= 0.5
    rgb = np.clip(np.stack([v * t for t in tint], -1), 0, 1)
    im = Image.fromarray((rgb ** (1 / 2.2) * 255).astype(np.uint8))
    _TEX[key] = im
    return im


def tex_cells(nx=8, ny=8, size=256, gap=0.08, seed=3, line=0.55, busbar=False):
    """A solar-cell grid: nx x ny cells to a repeat, light gaps between
    (the substrate) at `line` x the cells' brightness ratio inverted."""
    key = ('cells', nx, ny, size, gap, seed, line, busbar)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    g = _rng(seed)
    yy, xx = np.mgrid[0:size, 0:size] / size
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    cell = (fx > gap / 2) & (fx < 1 - gap / 2) & (fy > gap / 2) & (fy < 1 - gap / 2)
    jitter = g.uniform(0.85, 1.0, (ny, nx))
    v = np.where(cell, jitter[(yy * ny).astype(int) % ny, (xx * nx).astype(int) % nx], 1.0 / line)
    if busbar:
        v = np.where(cell & (np.abs(fx - 0.5) < 0.015), 2.5, v)
    v = v / v.max()
    im = Image.fromarray((np.clip(v, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)).convert("RGB")
    _TEX[key] = im
    return im


def tex_panels(nx=4, ny=4, size=256, seed=5, spread=0.25, line=0.6):
    """Painted or anodised panels: a grid of plates each a little different,
    dark joints between."""
    key = ('panels', nx, ny, size, seed, spread, line)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    g = _rng(seed)
    yy, xx = np.mgrid[0:size, 0:size] / size
    fx, fy = (xx * nx) % 1, (yy * ny) % 1
    jit = g.uniform(1 - spread, 1.0, (ny, nx))
    v = jit[(yy * ny).astype(int) % ny, (xx * nx).astype(int) % nx]
    joint = (fx < 0.02) | (fx > 0.98) | (fy < 0.02) | (fy > 0.98)
    v = np.where(joint, v * line, v)
    im = Image.fromarray((np.clip(v, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)).convert("RGB")
    _TEX[key] = im
    return im


def unshare(mesh):
    """Every triangle its own three corners (for per-face texture mapping)."""
    p, t = mesh
    p = np.asarray(p, float)[np.asarray(t).ravel()]
    return p, np.arange(len(p)).reshape(-1, 3)


def planar_uv(mesh, tile=1.0, axes=None):
    """(mesh unshared, uv): each triangle mapped on the body plane its normal
    is nearest (box mapping), `tile` metres a repeat (a number or (u, v));
    axes forces one projection: a pair of unit vectors (u, v)."""
    p, t = unshare(mesh)
    tu, tv = (tile, tile) if np.isscalar(tile) else tile
    uv = np.zeros((len(p), 2), np.float32)
    tri = p[t]
    n = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    dom = np.argmax(np.abs(n), axis=1)
    for k, (i, j) in enumerate(((1, 2), (0, 2), (0, 1))):
        sel = np.where(dom == k)[0]
        for c in range(3):
            v = t[sel, c]
            if axes is None:
                uv[v, 0] = p[v, i] / tu
                uv[v, 1] = p[v, j] / tv
    if axes is not None:
        a, b = (np.asarray(x, float) for x in axes)
        uv[:, 0] = p @ a / tu
        uv[:, 1] = p @ b / tv
    return (p, t), uv


def cyl_uv(mesh, tile_x=1.0, n_round=1.0, axis_origin=(0.0, 0.0)):
    """(mesh unshared, uv) for a surface round the X axis: u along X (tile_x
    m a repeat), v round it (n_round repeats a turn).  The seam triangle is
    fixed up so it does not smear the whole repeat."""
    p, t = unshare(mesh)
    ang = np.arctan2(p[:, 2] - axis_origin[1], p[:, 1] - axis_origin[0]) / (2 * np.pi)
    ang = ang % 1.0
    tri = ang[t]
    wrap = (tri.max(1) - tri.min(1)) > 0.5
    for i in np.where(wrap)[0]:
        for c in range(3):
            if tri[i, c] < 0.5:
                ang[t[i, c]] += 1.0
    uv = np.column_stack([p[:, 0] / tile_x, ang * n_round]).astype(np.float32)
    return (p, t), uv


def tpart(kit, name, rgb, mesh, image, tile=1.0, axes=None, cyl=None, smooth=False, fine=None):
    """A textured part: box-mapped (or cylinder-mapped round X when cyl is
    (tile_x, n_round)); fine: refine the mesh first to that edge length."""
    if fine:
        mesh = refine(mesh, fine)
    if cyl is not None:
        m, uv = cyl_uv(mesh, *cyl)
    else:
        m, uv = planar_uv(mesh, tile, axes)
    out = kit.part(name, rgb, m, smooth=False, texture=image, uv=uv)
    if smooth and cyl is not None:          # round X: radial normals
        q = np.asarray(m[0], float).copy()
        q[:, 0] = 0.0
        out['nrm'] = q / np.maximum(np.linalg.norm(q, axis=1, keepdims=True), 1e-12)
    return out


def torus(R, r, n=64, m=12, centre=(0.0, 0.0, 0.0)):
    """A torus round the X axis: ring radius R, tube radius r (shared
    points: smooth)."""
    pts = []
    for i in range(n):
        a = 2 * math.pi * i / n
        for j in range(m):
            b = 2 * math.pi * j / m
            rr = R + r * math.cos(b)
            pts.append((r * math.sin(b), rr * math.cos(a), rr * math.sin(a)))
    tris = []
    for i in range(n):
        for j in range(m):
            a0, a1 = i * m + j, i * m + (j + 1) % m
            b0, b1 = ((i + 1) % n) * m + j, ((i + 1) % n) * m + (j + 1) % m
            tris += [(a0, b0, b1), (a0, b1, a1)]
    return np.asarray(pts, float) + np.asarray(centre, float), np.asarray(tris)


# --------------------------------------------------------------- refinement
# portview writes a depth linear in distance at each vertex, and the GPU
# interpolates it linearly across the screen: across a long triangle seen
# obliquely the depth is wrong by ~ L^2 / (8 d) (L the triangle's length, d
# the range) -- 0.14 m for a 4.3 m drum side at 17 m -- enough for a lining
# 2 cm inside to show through the skin.  So big surfaces with other surfaces
# close behind or in front of them are cut into pieces no longer than ~0.5 m.
def refine(mesh, max_len=0.5):
    """Every triangle cut into k x k smaller ones on a barycentric grid, k
    the same for the whole mesh (so neighbours' edges match: no cracks),
    enough that no edge is longer than max_len; shared points merged."""
    p, t = np.asarray(mesh[0], float), np.asarray(mesh[1], int)
    if len(t) == 0:
        return p, t
    e = np.concatenate([np.linalg.norm(p[t[:, i]] - p[t[:, (i + 1) % 3]], axis=1) for i in range(3)])
    k = int(math.ceil(e.max() / max_len))
    if k <= 1:
        return p, t
    # the grid's local points (i, j) with i + j <= k, and its triangles
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
           + c[:, None, :] * loc[None, :, 1, None])                  # (m, g, 3)
    g = len(loc)
    tris = (sub[None, :, :] + (np.arange(len(t)) * g)[:, None, None]).reshape(-1, 3)
    pts = pts.reshape(-1, 3)
    key = np.round(pts / 1e-6).astype(np.int64)
    _, first, inv = np.unique(key, axis=0, return_index=True, return_inverse=True)
    inv = inv.ravel()
    return pts[first], inv[tris]


def frustum_fine(r0, r1, x0, x1, n=48, max_len=0.5, caps=True, phase=0.0):
    """kit.frustum cut along its length into pieces no longer than max_len
    (see refine): rings shared, so smooth shading still works."""
    m = max(1, int(math.ceil(abs(x1 - x0) / max_len)))
    rings = []
    for s in range(m + 1):
        f = s / m
        r, x = r0 + (r1 - r0) * f, x0 + (x1 - x0) * f
        a = np.linspace(0.0, 2 * math.pi, n, endpoint=False) + phase
        rings.append(np.column_stack([np.full(n, x), r * np.cos(a), r * np.sin(a)]))
    pts = list(rings)
    tris = []
    for s in range(m):
        b0, b1 = s * n, (s + 1) * n
        for i in range(n):
            j = (i + 1) % n
            tris += [(b0 + i, b0 + j, b1 + j), (b0 + i, b1 + j, b1 + i)]
    if caps:
        c0, c1 = (m + 1) * n, (m + 1) * n + 1
        pts.append([[x0, 0, 0], [x1, 0, 0]])
        for i in range(n):
            j = (i + 1) % n
            tris += [(c0, j, i), (c1, m * n + i, m * n + j)]
    return np.vstack(pts), np.asarray(tris)


def cylinder_fine(r, x0, x1, n=48, max_len=0.5, caps=True, phase=0.0):
    return frustum_fine(r, r, x0, x1, n, max_len, caps, phase)


def _components(t, npts):
    """Connected pieces of a triangle list (triangles sharing a point)."""
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
    """refine() every flat, untextured part (kit.part's without smooth
    normals or uv), each connected piece with its own grid, in place."""
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
            ax = np.linalg.svd(q, full_matrices=False)[2]          # principal axes
            ext = np.sort(np.ptp(q @ ax.T, axis=0))
            # thin things (struts, rods, booms) need no cutting: nothing
            # lies close along their length, and k^2 pieces would be wasteful
            meshes.append((pos, idx[comp]) if ext[1] < max(0.25, 0.1 * ext[2]) else refine((pos, idx[comp]), max_len))
        P, T = [], []
        base = 0
        for mp, mt in meshes:
            used = np.unique(mt)
            remap = np.full(len(mp), -1)
            remap[used] = np.arange(len(used))
            P.append(mp[used])
            T.append(remap[mt] + base)
            base += len(used)
        p['pos'], p['idx'] = np.vstack(P), np.vstack(T)
    return parts
