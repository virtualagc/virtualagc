"""Shared helpers for the Hughes spinners (Westar 6, Palapa B2 -- HS-376 --
and Leasat 3 -- HS-381): textured surfaces of revolution with their own
texture coordinates and exact normals, and the procedural textures (solar
cells, gold and silver blankets, a gridded reflector) they carry.

kit.cylinder() etc. share one ring of points round the seam, which is right
for flat colour but cannot carry a texture (the last strip would run its u
from 1 back to 0); these duplicate the seam.  A MESH here is a dict
(pos, idx, uv, nrm) -- nrm None for a flat-shaded one -- and part() makes a
kit part of it.

All shapes are along +X, like kit's.  Textures are PIL images in sRGB (the
renderer decodes them to linear and multiplies by the part's colour, which
part() sets to white for a textured part): pass linear albedos to the
painting helpers and they encode.
"""
import math

import numpy as np

# --------------------------------------------------------------- meshes


def _mesh(pos, idx, uv=None, nrm=None):
    return dict(pos=np.asarray(pos, float), idx=np.asarray(idx, int).reshape(-1, 3),
                uv=None if uv is None else np.asarray(uv, np.float32),
                nrm=None if nrm is None else np.asarray(nrm, float))


def merge(*ms):
    """One mesh of several (all smooth or all flat; uv kept if all have it)."""
    pos, idx, uv, nrm, base = [], [], [], [], 0
    has_uv = all(m['uv'] is not None for m in ms)
    has_n = all(m['nrm'] is not None for m in ms)
    for m in ms:
        pos.append(m['pos'])
        idx.append(m['idx'] + base)
        base += len(m['pos'])
        if has_uv:
            uv.append(m['uv'])
        if has_n:
            nrm.append(m['nrm'])
    return _mesh(np.vstack(pos), np.vstack(idx), np.vstack(uv) if has_uv else None,
                 np.vstack(nrm) if has_n else None)


def place(m, R=np.eye(3), t=(0.0, 0.0, 0.0)):
    """The mesh turned by R (3x3) and then moved by t."""
    R = np.asarray(R, float)
    out = dict(m)
    out['pos'] = m['pos'] @ R.T + np.asarray(t, float)
    if m['nrm'] is not None:
        out['nrm'] = m['nrm'] @ R.T
    return out


def from_kit(mesh, tex_scale=None):
    """A kit (points, triangles) mesh, flat-shaded; uv projected from the
    points (metres x tex_scale) if tex_scale is given."""
    m = _mesh(mesh[0], mesh[1])
    return with_uv(m, tex_scale) if tex_scale else m


def with_uv(m, tex_scale=1.0):
    """The mesh with uv projected from its points, if it has none: for small
    blanketed parts, where any unstretched-enough mapping will do."""
    if m['uv'] is not None:
        return m
    out = dict(m)
    p = m['pos']
    out['uv'] = (np.column_stack([p[:, 1] + 0.7 * p[:, 2], p[:, 0] + 0.7 * p[:, 2]]) * tex_scale).astype(np.float32)
    return out


def grid_surface(xr, n_around, n_along, u_range=(0.0, 1.0), v_range=(0.0, 1.0), phase=0.0,
                 a0=0.0, a1=2 * math.pi):
    """A surface of revolution about X: xr(t) -> (x, r, dx/dt, dr/dt) for t in
    [0, 1] along it; n_around columns (seam duplicated), n_along rows.  u runs
    round (u_range), v along (v_range).  Normals outward (away from the axis
    for a cylinder; toward +X for a disc whose r grows with t ... the right-hand
    rule on (around, along))."""
    ts = np.linspace(0.0, 1.0, n_along + 1)
    angs = np.linspace(a0, a1, n_around + 1) + phase
    pos, nrm, uv = [], [], []
    for t in ts:
        x, r, dx, dr = xr(t)
        for j, a in enumerate(angs):
            c, s = math.cos(a), math.sin(a)
            pos.append((x, r * c, r * s))
            # around (0, -s, c) x along (dx, dr c, dr s): outward on a cylinder
            n = np.cross((0.0, -s, c), (dx, dr * c, dr * s))
            L = np.linalg.norm(n)
            nrm.append(n / L if L > 1e-12 else (1.0, 0.0, 0.0))
            uv.append((u_range[0] + (u_range[1] - u_range[0]) * j / n_around,
                       v_range[0] + (v_range[1] - v_range[0]) * t))
    m = n_around + 1
    idx = []
    for i in range(n_along):
        for j in range(n_around):
            a, b, c, d = i * m + j, i * m + j + 1, (i + 1) * m + j + 1, (i + 1) * m + j
            idx += [(a, d, c), (a, c, b)]
    return _mesh(pos, idx, uv, nrm)


def cylinder(r, x0, x1, n=96, rows=1, inward=False, **kw):
    """The side of a cylinder from x0 to x1 (no caps), u round, v along x."""
    m = grid_surface(lambda t: (x0 + (x1 - x0) * t, r, x1 - x0, 0.0), n, rows, **kw)
    if inward:
        m['nrm'] = -m['nrm']
    return m


def frustum(r0, r1, x0, x1, n=64, rows=1, **kw):
    return grid_surface(lambda t: (x0 + (x1 - x0) * t, r0 + (r1 - r0) * t, x1 - x0, r1 - r0), n, rows, **kw)


def annulus(r_in, r_out, x, n=96, rows=2, scale=None, facing=1.0):
    """A flat ring (a disc if r_in is 0) in the plane X = x; uv planar (u from
    y, v from z, over +-scale, default r_out), normal +-X."""
    S = scale or r_out
    m = grid_surface(lambda t: (x, r_in + (r_out - r_in) * t, 0.0, r_out - r_in), n, rows)
    m['uv'] = np.column_stack([0.5 + 0.5 * m['pos'][:, 1] / S, 0.5 + 0.5 * m['pos'][:, 2] / S]).astype(np.float32)
    m['nrm'] = np.tile((facing, 0.0, 0.0), (len(m['pos']), 1))
    return m


def dish(R, depth, x_rim, n=96, rows=12, r_in=0.0):
    """A paraboloidal dish, rim radius R at x_rim, its vertex depth behind
    (toward -X): concave toward +X.  uv planar over the rim."""
    def xr(t):
        r = r_in + (R - r_in) * t
        return (x_rim - depth * (1.0 - (r / R) ** 2), r, 2 * depth * r / R ** 2 * (R - r_in), R - r_in)
    m = grid_surface(xr, n, rows)
    m['uv'] = np.column_stack([0.5 + 0.5 * m['pos'][:, 1] / R, 0.5 + 0.5 * m['pos'][:, 2] / R]).astype(np.float32)
    m['nrm'] = -m['nrm']                         # the concave side's, toward +X
    return m


def dome(R, height, x0, n=64, rows=10, toward=-1.0):
    """A spherical cap on a base circle of radius R at x0, bulging height along
    toward (+-1).  uv planar."""
    rho = (R * R + height * height) / (2 * height)     # the sphere's radius
    c = x0 - toward * (rho - height)                   # its centre
    th1 = math.asin(min(1.0, R / rho))

    def xr(t):
        th = th1 * (1 - t)
        return (c + toward * rho * math.cos(th), rho * math.sin(th),
                toward * rho * math.sin(th) * th1, -rho * math.cos(th) * th1)
    m = grid_surface(xr, n, rows)
    m['uv'] = np.column_stack([0.5 + 0.5 * m['pos'][:, 1] / R, 0.5 + 0.5 * m['pos'][:, 2] / R]).astype(np.float32)
    p = m['pos'] - (c, 0.0, 0.0)
    m['nrm'] = p / np.linalg.norm(p, axis=1, keepdims=True)
    return m


def box(size, centre=(0.0, 0.0, 0.0), tex_scale=1.0):
    """A box with its own corners per face (so a texture lies on each face
    unstretched: uv = the face's own metres x tex_scale).  Flat-shaded."""
    sx, sy, sz = (0.5 * float(s) for s in size)
    cx, cy, cz = (float(c) for c in centre)
    faces = [((1, 0, 0), (0, 1, 0), (0, 0, 1), sx, sy, sz), ((-1, 0, 0), (0, 0, 1), (0, 1, 0), sx, sz, sy),
             ((0, 1, 0), (0, 0, 1), (1, 0, 0), sy, sz, sx), ((0, -1, 0), (1, 0, 0), (0, 0, 1), sy, sx, sz),
             ((0, 0, 1), (1, 0, 0), (0, 1, 0), sz, sx, sy), ((0, 0, -1), (0, 1, 0), (1, 0, 0), sz, sy, sx)]
    pos, uv, idx = [], [], []
    for n, a, b, dn, da, db in faces:
        n, a, b = np.array(n, float), np.array(a, float), np.array(b, float)
        base = len(pos)
        for ia, ib in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
            pos.append(n * dn + a * da * ia + b * db * ib + (cx, cy, cz))
            uv.append(((ia + 1) * da * tex_scale, (ib + 1) * db * tex_scale))
        idx += [(base, base + 1, base + 2), (base, base + 2, base + 3)]
    return _mesh(pos, idx, uv)


def rod(p0, p1, r, n=8, caps=True):
    """A strut from p0 to p1 (kit's), flat."""
    import importlib
    kit = importlib.import_module(__package__ + '.kit')
    return from_kit(kit.rod(p0, p1, r, n))


def along_matrix(direction):
    """The rotation taking +X to direction."""
    d = np.asarray(direction, float)
    d = d / np.linalg.norm(d)
    x = np.array([1.0, 0.0, 0.0])
    v = np.cross(x, d)
    s, c = np.linalg.norm(v), float(np.dot(x, d))
    if s < 1e-12:
        return np.eye(3) if c > 0 else np.diag([-1.0, -1.0, 1.0])
    k = v / s
    K = np.array([[0, -k[2], k[1]], [k[2], 0, -k[0]], [-k[1], k[0], 0]])
    return np.eye(3) + s * K + (1 - c) * K @ K


def part(kit, name, m, rgb=(1.0, 1.0, 1.0), texture=None):
    """A kit part of one of these meshes: smooth if it has normals, textured
    if texture is given (its colour then white unless rgb says otherwise)."""
    p = kit.part(name, rgb, (m['pos'], m['idx']), texture=texture,
                 uv=m['uv'] if texture is not None else None)
    if m['nrm'] is not None:
        n = m['nrm']
        p['nrm'] = n / np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)
        if p['uv'] is None:
            p['uv'] = np.zeros((len(m['pos']), 2), np.float32)
    return p


# ------------------------------------------------------------- textures


def srgb(lin):
    """Linear albedo (array, 0-1) to sRGB 0-255 uint8."""
    a = np.clip(np.asarray(lin, float), 0.0, 1.0)
    s = np.where(a <= 0.0031308, 12.92 * a, 1.055 * np.power(a, 1 / 2.4) - 0.055)
    return np.clip(np.round(s * 255.0), 0, 255).astype(np.uint8)


def image(lin_rgb):
    """A PIL image of an (h, w, 3) linear-albedo array."""
    from PIL import Image
    return Image.fromarray(srgb(lin_rgb), 'RGB')


def _noise(h, w, cells, seed, octaves=3):
    """Smooth value noise in about [-1, 1], (h, w), tiling."""
    rng = np.random.default_rng(seed)
    out = np.zeros((h, w))
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        ch, cw = max(2, int(cells[0] * 2 ** o)), max(2, int(cells[1] * 2 ** o))
        g = rng.uniform(-1, 1, (ch, cw))
        yy = np.linspace(0, ch, h, endpoint=False)
        xx = np.linspace(0, cw, w, endpoint=False)
        y0, x0 = np.floor(yy).astype(int), np.floor(xx).astype(int)
        fy, fx = (yy - y0)[:, None], (xx - x0)[None, :]
        fy, fx = fy * fy * (3 - 2 * fy), fx * fx * (3 - 2 * fx)
        y1, x1 = (y0 + 1) % ch, (x0 + 1) % cw
        a = g[y0][:, x0] * (1 - fx) + g[y0][:, x1] * fx
        b = g[y1][:, x0] * (1 - fx) + g[y1][:, x1] * fx
        out += amp * (a * (1 - fy) + b * fy)
        tot += amp
        amp *= 0.5
    return out / tot


def blanket(h, w, base, seed, crinkle=0.35, cells=(6, 6)):
    """Multi-layer insulation: base albedo (rgb) crinkled -- bright and dark
    facets, as the foil catches the light."""
    n = _noise(h, w, cells, seed, octaves=4)
    ridges = 1.0 - np.abs(_noise(h, w, (cells[0] * 2, cells[1] * 2), seed + 1, octaves=3))
    f = 1.0 + crinkle * (0.8 * n + 0.6 * (ridges - 0.6))
    return np.clip(f[:, :, None] * np.asarray(base, float)[None, None, :], 0, 1)


def solar_cells(h, w, n_around, n_along, cell, gap, seed, mottle=0.12):
    """A drum's cells: an (h, w) image whose x runs round the drum (n_around
    cells) and y along it (n_along; row fraction f is v = f, the cylinder's
    x0 end at the image's top):
    cell colour with a little cell-to-cell scatter, gap colour between."""
    rng = np.random.default_rng(seed)
    yy = (np.arange(h) + 0.5) / h * n_along
    xx = (np.arange(w) + 0.5) / w * n_around
    fy, fx = yy % 1.0, xx % 1.0
    gy = (fy < 0.10)[:, None] | np.zeros((1, w), bool)
    gx = (fx < 0.05)[None, :] | np.zeros((h, 1), bool)
    scatter = 1.0 + mottle * rng.uniform(-1, 1, (int(n_along) + 1, int(n_around) + 1))
    s = scatter[np.floor(yy).astype(int)][:, np.floor(xx).astype(int)]
    img = s[:, :, None] * np.asarray(cell, float)[None, None, :]
    g = gy | gx
    img[g] = np.asarray(gap, float)
    return img


def paint_rows(img, v0, v1, rgb):
    """Fill rows between fractions v0..v1 (0 the image's top)."""
    h = img.shape[0]
    a, b = int(round(min(v0, v1) * h)), int(round(max(v0, v1) * h))
    img[max(0, a):max(a + 1, min(h, b))] = np.asarray(rgb, float)


def paint_cols(img, u0, u1, rgb, v0=0.0, v1=1.0):
    h, w = img.shape[:2]
    a, b = int(round(u0 * w)), int(round(u1 * w))
    r0, r1 = int(round(v0 * h)), int(round(v1 * h))
    img[r0:r1, max(0, a):max(a + 1, min(w, b))] = np.asarray(rgb, float)


def paint_rect(img, u0, v0, u1, v1, rgb):
    paint_cols(img, u0, u1, rgb, v0, v1)


def grid_reflector(size, n_lines, base, line, rim_frac, rim, seed):
    """A gridded (polarisation-selective) reflector seen face-on: base, the
    crossed grid of n_lines each way, a blanketed rim beyond rim_frac of
    the radius."""
    yy, xx = np.mgrid[0:size, 0:size]
    u, v = (xx + 0.5) / size * 2 - 1, (yy + 0.5) / size * 2 - 1
    img = np.empty((size, size, 3))
    img[:] = np.asarray(base, float)
    n = _noise(size, size, (5, 5), seed, octaves=3)
    img *= (1.0 + 0.25 * n)[:, :, None]
    fu, fv = (u + 1) / 2 * n_lines % 1.0, (v + 1) / 2 * n_lines % 1.0
    lw = 0.035
    img[(fu < lw) | (fv < lw)] = np.asarray(line, float)
    r = np.hypot(u, v)
    rimimg = blanket(size, size, rim, seed + 7, crinkle=0.4, cells=(10, 10))
    img[r > rim_frac] = rimimg[r > rim_frac]
    return img


def gores(size, n_gores, base, seam, r_hub, hub, seed):
    """A blanketed end face seen face-on: crinkled base, n_gores radial seams
    and two circumferential ones, a hub disc inside r_hub (fraction)."""
    img = blanket(size, size, base, seed, crinkle=0.22, cells=(8, 8))
    yy, xx = np.mgrid[0:size, 0:size]
    u, v = (xx + 0.5) / size * 2 - 1, (yy + 0.5) / size * 2 - 1
    r, a = np.hypot(u, v), np.arctan2(v, u)
    ga = (a / (2 * math.pi) * n_gores) % 1.0
    width = 0.012 / np.maximum(r, 0.05) * n_gores / (2 * math.pi)
    img[(ga < width) & (r > r_hub)] = np.asarray(seam, float)
    for rr in (r_hub, 0.5 * (r_hub + 1.0), 0.985):
        img[np.abs(r - rr) < 0.005] = np.asarray(seam, float)
    hubimg = blanket(size, size, hub, seed + 3, crinkle=0.12, cells=(4, 4))
    img[r < r_hub] = hubimg[r < r_hub]
    return img
