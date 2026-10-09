"""Building blocks for vehicle models (see __init__.py).

A MESH is (points (n, 3) float, triangles (m, 3) int), metres, in whatever
frame it was made in; shapes make meshes along +X by default, and
move/turn/along place them.  A PART is one material: part(name, rgb, *meshes)
-- rgb a linear albedo, 0-1 (what the surface reflects; portview lights it:
white paint ~0.8, MLI blanket silver ~0.7 or gold ~(0.75, 0.6, 0.3), solar
cells ~(0.05, 0.07, 0.16), black ~0.03).  Parts are drawn flat-shaded
unless smooth=True (normals averaged where triangles share corners -- for
curved surfaces made with shared points, as cylinders here are).

Units are metres; inches(x) converts.  Every function returns new arrays.
"""
import math
import os

import numpy as np

INCH = 0.0254


def inches(x):
    return np.asarray(x, float) * INCH


# --------------------------------------------------------------- transforms
def rot(axis, deg):
    """The rotation matrix about 'x', 'y', 'z' or a vector, by deg."""
    if isinstance(axis, str):
        axis = {'x': (1, 0, 0), 'y': (0, 1, 0), 'z': (0, 0, 1)}[axis]
    a = np.asarray(axis, float)
    a = a / np.linalg.norm(a)
    t = math.radians(deg)
    c, s = math.cos(t), math.sin(t)
    x, y, z = a
    return np.array([[c + x * x * (1 - c), x * y * (1 - c) - z * s, x * z * (1 - c) + y * s],
                     [y * x * (1 - c) + z * s, c + y * y * (1 - c), y * z * (1 - c) - x * s],
                     [z * x * (1 - c) - y * s, z * y * (1 - c) + x * s, c + z * z * (1 - c)]])


def move(mesh, offset):
    p, t = mesh
    return p + np.asarray(offset, float), t


def turn(mesh, R, about=(0.0, 0.0, 0.0)):
    """Rotate by matrix R about a point."""
    p, t = mesh
    c = np.asarray(about, float)
    return (p - c) @ np.asarray(R, float).T + c, t


def along(mesh, direction, at=(0.0, 0.0, 0.0)):
    """A mesh made along +X, turned so +X points along direction, then moved to at."""
    d = np.asarray(direction, float)
    d = d / np.linalg.norm(d)
    x = np.array([1.0, 0.0, 0.0])
    v = np.cross(x, d)
    s, c = np.linalg.norm(v), float(np.dot(x, d))
    if s < 1e-12:
        R = np.eye(3) if c > 0 else rot('z', 180)
    else:
        k = v / s
        K = np.array([[0, -k[2], k[1]], [k[2], 0, -k[0]], [-k[1], k[0], 0]])
        R = np.eye(3) + s * K + (1 - c) * K @ K
    return move(turn(mesh, R), at)


def scale(mesh, f):
    p, t = mesh
    return p * np.asarray(f, float), t


def merge(*meshes):
    pts, tris, base = [], [], 0
    for p, t in meshes:
        pts.append(np.asarray(p, float))
        tris.append(np.asarray(t, int) + base)
        base += len(p)
    if not pts:
        return np.zeros((0, 3)), np.zeros((0, 3), int)
    return np.vstack(pts), np.vstack(tris)


# ------------------------------------------------------------------- shapes
def _ring(r, x, n, phase=0.0):
    a = np.linspace(0.0, 2 * math.pi, n, endpoint=False) + phase
    return np.column_stack([np.full(n, x), r * np.cos(a), r * np.sin(a)])


def frustum(r0, r1, x0, x1, n=48, caps=True, phase=0.0):
    """A cone's frustum along X from radius r0 at x0 to r1 at x1 (a
    cylinder if r0 == r1); n sides (n=6 a hexagonal prism, 8 octagonal)."""
    pts = [_ring(r0, x0, n, phase), _ring(r1, x1, n, phase)]
    tris = []
    for i in range(n):
        j = (i + 1) % n
        tris += [(i, j, n + j), (i, n + j, n + i)]
    if caps:
        pts.append([[x0, 0, 0], [x1, 0, 0]])
        for i in range(n):
            j = (i + 1) % n
            tris += [(2 * n, j, i), (2 * n + 1, n + i, n + j)]
    return np.vstack(pts), np.array(tris)


def cylinder(r, x0, x1, n=48, caps=True, phase=0.0):
    return frustum(r, r, x0, x1, n, caps, phase)


def tube(r_out, r_in, x0, x1, n=48):
    """A hollow cylinder: outside, inside and the two annular ends."""
    o0, o1, i0, i1 = _ring(r_out, x0, n), _ring(r_out, x1, n), _ring(r_in, x0, n), _ring(r_in, x1, n)
    pts = np.vstack([o0, o1, i0, i1])
    tris = []
    for i in range(n):
        j = (i + 1) % n
        tris += [(i, j, n + j), (i, n + j, n + i),                       # outside
                 (2 * n + i, 3 * n + j, 2 * n + j), (2 * n + i, 3 * n + i, 3 * n + j),   # inside
                 (i, 2 * n + j, j), (i, 2 * n + i, 2 * n + j),           # x0 end
                 (n + i, n + j, 3 * n + j), (n + i, 3 * n + j, 3 * n + i)]  # x1 end
    return pts, np.array(tris)


def disc(r, x, n=48, r_in=0.0):
    """A flat disc (or annulus) in the plane X = x, facing +X."""
    if r_in > 0:
        o, i_ = _ring(r, x, n), _ring(r_in, x, n)
        tris = []
        for i in range(n):
            j = (i + 1) % n
            tris += [(i, j, n + j), (i, n + j, n + i)]
        return np.vstack([o, i_]), np.array(tris)
    pts = np.vstack([_ring(r, x, n), [[x, 0, 0]]])
    return pts, np.array([(n, i, (i + 1) % n) for i in range(n)])


def sphere(r, n=24, centre=(0.0, 0.0, 0.0), x_range=None):
    """A UV sphere (n bands), optionally only between x_range (lo, hi): a dome."""
    lo, hi = x_range if x_range else (-r, r)
    t0, t1 = math.acos(max(-1, min(1, hi / r))), math.acos(max(-1, min(1, lo / r)))
    rows = []
    for k in range(n + 1):
        th = t0 + (t1 - t0) * k / n
        rows.append(_ring(r * math.sin(th), r * math.cos(th), 2 * n))
    pts = np.vstack(rows)
    m = 2 * n
    tris = []
    for k in range(n):
        for i in range(m):
            j = (i + 1) % m
            a, b, c, d = k * m + i, k * m + j, (k + 1) * m + j, (k + 1) * m + i
            tris += [(a, b, c), (a, c, d)]
    return pts + np.asarray(centre, float), np.array(tris)


def box(size, centre=(0.0, 0.0, 0.0)):
    """A rectangular box, size (dx, dy, dz)."""
    c = np.array([[i, j, k] for i in (-0.5, 0.5) for j in (-0.5, 0.5) for k in (-0.5, 0.5)])
    pts = c * np.asarray(size, float) + np.asarray(centre, float)
    quads = ((0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3))
    return pts, np.array([t for q in quads for t in ((q[0], q[1], q[2]), (q[0], q[2], q[3]))])


def prism(points2d, x0, x1):
    """A prism along X whose section is the convex polygon points2d [(y, z), ...]."""
    p = np.asarray(points2d, float)
    n = len(p)
    a = np.column_stack([np.full(n, x0), p])
    b = np.column_stack([np.full(n, x1), p])
    pts = np.vstack([a, b, [[x0, *p.mean(0)], [x1, *p.mean(0)]]])
    tris = []
    for i in range(n):
        j = (i + 1) % n
        tris += [(i, j, n + j), (i, n + j, n + i), (2 * n, j, i), (2 * n + 1, n + i, n + j)]
    return pts, np.array(tris)


def rod(p0, p1, r, n=8):
    """A strut from p0 to p1, radius r (an n-sided prism)."""
    p0, p1 = np.asarray(p0, float), np.asarray(p1, float)
    L = float(np.linalg.norm(p1 - p0))
    return along(cylinder(r, 0.0, L, n), p1 - p0, p0)


def panel(size_y, size_z, thickness=0.02, centre=(0.0, 0.0, 0.0)):
    """A flat panel in the Y-Z plane (facing X), e.g. a solar array."""
    return box((thickness, size_y, size_z), centre)


def truss(p0, p1, width, bays, r, sides=3):
    """A lattice boom from p0 to p1: `sides` longerons (3 triangular, 4
    square) on a circle of radius width/2, battens at each bay and diagonals
    across each face."""
    p0, p1 = np.asarray(p0, float), np.asarray(p1, float)
    L = float(np.linalg.norm(p1 - p0))
    meshes = []
    a = [2 * math.pi * k / sides for k in range(sides)]
    corner = lambda k, x: np.array([x, 0.5 * width * math.cos(a[k]), 0.5 * width * math.sin(a[k])])
    for k in range(sides):
        meshes.append(rod(corner(k, 0), corner(k, L), r))
        for b in range(bays + 1):
            x = L * b / bays
            meshes.append(rod(corner(k, x), corner((k + 1) % sides, x), r * 0.7))
            if b < bays:
                meshes.append(rod(corner(k, x), corner((k + 1) % sides, L * (b + 1) / bays), r * 0.6))
    return along(merge(*meshes), p1 - p0, p0)


# -------------------------------------------------------------------- parts
def part(name, rgb, *meshes, smooth=False, texture=None, uv=None):
    """A material and its geometry.  smooth: normals averaged at shared
    corners (curved surfaces); otherwise flat."""
    pts, tris = merge(*meshes)
    rgb = list(rgb)
    out = dict(name=name, color=rgb + [1.0] if len(rgb) == 3 else rgb, metallic=0.0,
               pos=pts, idx=tris, uv=uv, texture=texture, nrm=None)
    if smooth and len(pts):
        n = np.zeros_like(pts)
        f = np.cross(pts[tris[:, 1]] - pts[tris[:, 0]], pts[tris[:, 2]] - pts[tris[:, 0]])
        for j in range(3):
            np.add.at(n, tris[:, j], f)
        out['nrm'] = n / np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)
        if out['uv'] is None:
            out['uv'] = np.zeros((len(pts), 2), np.float32)
    return out


def transform_parts(parts, R=np.eye(3), offset=(0.0, 0.0, 0.0)):
    """Parts (e.g. from nasa_glb) turned by R and then moved by offset."""
    out = []
    R = np.asarray(R, float)
    for p in parts:
        q = dict(p)
        q['pos'] = np.asarray(p['pos'], float) @ R.T + np.asarray(offset, float)
        if p.get('nrm') is not None:
            q['nrm'] = np.asarray(p['nrm'], float) @ R.T
        out.append(q)
    return out


def bounds(parts):
    pts = np.vstack([np.asarray(p['pos'], float) for p in parts])
    return pts.min(0), pts.max(0)


# ---------------------------------------------------------------- NASA glTF
NASA_3D = "https://raw.githubusercontent.com/nasa/NASA-3D-Resources/master/3D%20Models/"


def nasa_glb(path, root=np.eye(3), origin=(0.0, 0.0, 0.0), exclude=frozenset()):
    """A model from NASA 3D Resources (path under '3D Models/', URL-encoded or
    not), downloaded once into the cache, as parts in the frame root (3x3,
    applied in place of the file's root node; include the units' scale),
    with origin (file units) at 0."""
    import urllib.parse
    import fetch_assets as fa              # portview/, on the path when fetch_assets runs
    url = NASA_3D + urllib.parse.quote(urllib.parse.unquote(path))
    local = os.path.join(fa.CACHE, "models", "src", os.path.basename(urllib.parse.unquote(path)))
    os.makedirs(os.path.dirname(local), exist_ok=True)
    fa.download(url, local)
    return fa.glb_parts(local, root, origin, exclude)
