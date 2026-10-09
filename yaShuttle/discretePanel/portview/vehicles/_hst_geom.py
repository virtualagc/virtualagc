"""Textured shapes for the Hubble models: meshes with normals and texture
coordinates, as dicts pos, nrm, uv, idx (nrm None: flat).

The frame is HST's: X = V1 (toward the aperture), Y = V2, Z = V3; a point
round the body is given by its station s (m from the aft bulkhead, along
V1), azimuth phi (deg, from +V2 toward +V3) and radius r.  S0 is the
station of the origin (the centre of mass), set by the caller.
"""
import math

import numpy as np


class Frame(object):
    def __init__(self, s0):
        self.s0 = s0

    def p(self, s, phi, r):
        a = math.radians(phi)
        return np.array([s - self.s0, r * math.cos(a), r * math.sin(a)])

    def x(self, s):
        return s - self.s0


def mesh(pos, idx, nrm=None, uv=None):
    return dict(pos=np.asarray(pos, float), idx=np.asarray(idx, np.int64).reshape(-1, 3),
                nrm=None if nrm is None else np.asarray(nrm, float),
                uv=None if uv is None else np.asarray(uv, np.float32))


def join(*ms):
    """Meshes of one kind (all smooth with uv, or all flat) as one."""
    pos, idx, nrm, uv, base = [], [], [], [], 0
    smooth = all(m['nrm'] is not None for m in ms)
    for m in ms:
        pos.append(m['pos'])
        idx.append(m['idx'] + base)
        base += len(m['pos'])
        if smooth:
            nrm.append(m['nrm'])
        uv.append(m['uv'] if m['uv'] is not None else np.zeros((len(m['pos']), 2), np.float32))
    return mesh(np.vstack(pos), np.vstack(idx), np.vstack(nrm) if smooth else None, np.vstack(uv))


def from_kit(m):
    """A kit (points, triangles) mesh, flat."""
    return mesh(m[0], m[1])


def cyl(F, r, s0, s1, phi0=0.0, phi1=360.0, n=96, inward=False, u0=0.0, u1=1.0, v_top=None,
        v_scale=None, nseg=1):
    """The side of a cylinder (or an arc of it) from station s0 to s1, with
    smooth normals.  u runs u0..u1 with phi; v = (v_top - s) * v_scale
    (default: 0 at s1, 1 at s0 -- the image's top toward the aperture)."""
    if v_top is None:
        v_top = s1
    if v_scale is None:
        v_scale = 1.0 / (s1 - s0)
    m = max(2, int(round(n * abs(phi1 - phi0) / 360.0)) + 1)
    ph = np.linspace(phi0, phi1, m)
    ss = np.linspace(s0, s1, nseg + 1)
    pos, nrm, uv = [], [], []
    for s in ss:
        for k, f in enumerate(ph):
            a = math.radians(f)
            pos.append((s - F.s0, r * math.cos(a), r * math.sin(a)))
            nn = (0.0, math.cos(a), math.sin(a))
            nrm.append(tuple(-c for c in nn) if inward else nn)
            uv.append((u0 + (u1 - u0) * k / (m - 1), (v_top - s) * v_scale))
    idx = []
    for i in range(nseg):
        for k in range(m - 1):
            a, b = i * m + k, i * m + k + 1
            c, d = a + m, b + m
            idx += [(a, b, d), (a, d, c)]
    return mesh(pos, idx, nrm, uv)


def frustum_side(F, r0, r1, s0, s1, n=96, phi0=0.0, phi1=360.0):
    """A cone's side between (s0, r0) and (s1, r1), smooth, no uv."""
    m = max(2, int(round(n * abs(phi1 - phi0) / 360.0)) + 1)
    ph = np.radians(np.linspace(phi0, phi1, m))
    slope = (r0 - r1) / (s1 - s0) if s1 != s0 else 0.0
    pos, nrm = [], []
    for s, r in ((s0, r0), (s1, r1)):
        for a in ph:
            pos.append((s - F.s0, r * math.cos(a), r * math.sin(a)))
            nn = np.array([slope, math.cos(a), math.sin(a)])
            nrm.append(nn / np.linalg.norm(nn))
    idx = []
    for k in range(m - 1):
        idx += [(k, k + 1, m + k + 1), (k, m + k + 1, m + k)]
    return mesh(pos, idx, nrm, np.zeros((len(pos), 2)))


def ngon_prism(F, r_flat, n_sides, s0, s1, phase=0.0, u_per_side=None):
    """An n-sided prism's sides (flat facets; facet k centred on azimuth
    phase + 360 k / n), each facet's u running k/n .. (k+1)/n, v from 0 at s1
    to 1 at s0."""
    R = r_flat / math.cos(math.pi / n_sides)
    pos, idx, uv = [], [], []
    for k in range(n_sides):
        fa = math.radians(phase + 360.0 * (k - 0.5) / n_sides)
        fb = math.radians(phase + 360.0 * (k + 0.5) / n_sides)
        b = len(pos)
        for s in (s1, s0):
            for f in (fa, fb):
                pos.append((s - F.s0, R * math.cos(f), R * math.sin(f)))
        u0, u1 = k / n_sides, (k + 1) / n_sides
        uv += [(u0, 0.0), (u1, 0.0), (u0, 1.0), (u1, 1.0)]
        idx += [(b, b + 1, b + 3), (b, b + 3, b + 2)]
    return mesh(pos, idx, None, uv)


def disc_planar(F, r, s, n=96, r_in=0.0, centre=(0.0, 0.0), uv_box=None):
    """A flat disc (or annulus) at station s, facing along V1, with u =
    (V2 - (cy - r)) / 2r along +V2 and v along -V3 (uv_box: (y0, z1, size)
    for another mapping)."""
    a = np.linspace(0, 2 * math.pi, n, endpoint=False)
    cy, cz = centre
    outer = np.column_stack([np.full(n, s - F.s0), cy + r * np.cos(a), cz + r * np.sin(a)])
    if r_in > 0:
        inner = np.column_stack([np.full(n, s - F.s0), cy + r_in * np.cos(a), cz + r_in * np.sin(a)])
        pos = np.vstack([outer, inner])
        idx = []
        for i in range(n):
            j = (i + 1) % n
            idx += [(i, j, n + j), (i, n + j, n + i)]
    else:
        pos = np.vstack([outer, [[s - F.s0, cy, cz]]])
        idx = [(n, i, (i + 1) % n) for i in range(n)]
    y0, z1, size = uv_box if uv_box else (cy - r, cz + r, 2 * r)
    uv = np.column_stack([(pos[:, 1] - y0) / size, (z1 - pos[:, 2]) / size])
    return mesh(pos, idx, None, uv)


def quad(p0, p1, p2, p3, uv=((0, 0), (1, 0), (1, 1), (0, 1))):
    """A flat quadrilateral p0 p1 p2 p3 (in order round it), with uv."""
    return mesh([p0, p1, p2, p3], [(0, 1, 2), (0, 2, 3)], None, list(uv))


def part(name, rgb, meshes, texture=None, metallic=0.0):
    """A material: name, colour (linear albedo; 1 under a texture), its meshes."""
    m = join(*meshes) if len(meshes) > 1 else meshes[0]
    rgb = list(rgb)
    return dict(name=name, color=(rgb + [1.0]) if len(rgb) == 3 else rgb, metallic=metallic,
                texture=texture, pos=m['pos'], nrm=m['nrm'], uv=m['uv'], idx=m['idx'])
