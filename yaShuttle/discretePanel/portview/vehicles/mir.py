"""Mir (NORAD 16609) as the Shuttle last saw it: STS-91, Discovery, docked
4-8 June 1998 -- built from shapes to published dimensions and the STS-71..91
fly-around photographs (no better public-domain model exists: NASA 3D
Resources' "Mir" is a 5,800-triangle sketch).

The complex then (the layout unchanged since Priroda arrived in April
1996; Spektr damaged by Progress M-34 on 25 June 1997):

  base block (DOS-7, 20.4 t)  its transfer node forward, five ports:
    forward axial   Soyuz TM-27 (there since 20 Feb 1998)
    Mir -Z (ours -Z)  Kristall, the Docking Module on its end (the Shuttle's port)
    Mir +Z (ours +Z)  Priroda
    Mir +Y (ours -Y)  Kvant-2
    Mir -Y (ours +Y)  Spektr
  aft: Kvant-1 (Sofora girder, VDU; the cooperative array and a Russian one)
    and on Kvant-1's aft port Progress M-39 (docked 16 May 1998).

Body frame: +X along the core's axis toward the forward node (Mir's own -X:
Mir's +X points aft, toward Kvant-1); +Z Mir's +Z (toward Priroda; -Z,
Kristall and the Docking Module, faced the Shuttle and the Earth when it
docked from below); +Y = Mir's -Y (toward Spektr), so the frame stays
right-handed.  Origin: the complex's centre of mass, from the module masses
(NASA RP-1357, "Mir Hardware Heritage"; Soyuz TM and Progress M loaded
masses) each at its hull's mid-length -- 4 m aft of the node's centre and
a few tenths of a metre off the axis.

The pieces are in _mir_core.py (base block, Kvant-1), _mir_tks.py (the
four TKS-bus modules and the Docking Module), _mir_soyuz.py (Soyuz TM,
Progress M) and _mir_shapes.py (lathed hulls, folded and framed wings,
textures).
"""
import math

import numpy as np

KEY = 'mir'


def _materials(sh):
    blanket = sh.blanket_texture()
    cells = sh.cell_texture('russian')
    us = sh.cell_texture('us')
    back = sh.back_texture()
    return {
        # hulls: off-white thermal blankets, aged toward cream
        'blanket': dict(rgb=(0.72, 0.71, 0.66), smooth=True, texture=blanket),
        'blanket flat': dict(rgb=(0.66, 0.65, 0.60), texture=blanket),
        'core radiator': dict(rgb=(0.80, 0.80, 0.77), smooth=True, texture=blanket),
        'hull white': dict(rgb=(0.76, 0.76, 0.73), smooth=True),
        'radiator': dict(rgb=(0.82, 0.82, 0.80)),
        'louvre': dict(rgb=(0.55, 0.56, 0.58)),
        'gold': dict(rgb=(0.62, 0.46, 0.22), smooth=True, texture=blanket),
        'dm skin': dict(rgb=(0.66, 0.52, 0.27), smooth=True, texture=blanket),
        'orange': dict(rgb=(0.55, 0.24, 0.09)),
        'soyuz skin': dict(rgb=(0.34, 0.37, 0.30), smooth=True, texture=blanket),
        'white': dict(rgb=(0.80, 0.80, 0.78)),
        'pao white': dict(rgb=(0.74, 0.74, 0.71), smooth=True, texture=blanket),
        'metal': dict(rgb=(0.55, 0.55, 0.53), smooth=True),
        'hatch': dict(rgb=(0.50, 0.50, 0.47), smooth=True),
        'dark': dict(rgb=(0.04, 0.04, 0.045)),
        'rail': dict(rgb=(0.70, 0.62, 0.38)),
        'crane': dict(rgb=(0.78, 0.78, 0.74), smooth=True),
        'sofora': dict(rgb=(0.72, 0.62, 0.38)),
        'vdu': dict(rgb=(0.74, 0.72, 0.66)),
        'array frame': dict(rgb=(0.58, 0.56, 0.50)),
        # solar cells (the texture multiplies these), and the wings' backs
        'cells': dict(rgb=(0.13, 0.13, 0.24), texture=cells),
        'cells aged': dict(rgb=(0.20, 0.15, 0.15), texture=cells),
        'cells blue': dict(rgb=(0.12, 0.13, 0.25), texture=cells),
        'cells kvant1': dict(rgb=(0.14, 0.14, 0.22), texture=cells),
        'cells us': dict(rgb=(0.08, 0.09, 0.19), texture=us),
        'panel back': dict(rgb=(0.66, 0.60, 0.48), texture=back),
    }


def _frame(x, y):
    """Columns: the station directions of a module's local X, Y and Z."""
    x, y = np.asarray(x, float), np.asarray(y, float)
    return np.column_stack([x, y, np.cross(x, y)])


def build(kit):
    from . import _mir_shapes as sh, _mir_core as co, _mir_tks as tk, _mir_soyuz as sz
    a = sh.Assembly(_materials(sh))
    ports = co.node_ports()
    MASSES = []                     # (name, kg, centre in the node frame)

    co.core(a)
    co.core_extras(a)
    MASSES.append(('base block', 20400, (-4.9, 0, 0)))
    co.kvant1(a)
    MASSES.append(('Kvant-1', 11050, (co.X_AFT_PORT - 2.9, 0, 0)))

    def module(fn, port, local_y, mass, centre_x):
        at, d = ports[port]
        R = _frame(d, local_y)
        out = fn(a.sub(R, at))
        MASSES.append((fn.__name__, mass, at + R @ np.array([centre_x, 0, 0])))
        return R, at, out

    module(tk.kvant2, '-Y', (1, 0, 0), 19565, 6.0)
    module(tk.spektr, '+Y', (-1, 0, 0), 19640, 6.5)
    module(tk.priroda, '+Z', (0, -1, 0), 19700, 5.6)
    Rk, atk, apas = module(tk.kristall, '-Z', (-1, 0, 0), 19640, 5.6)
    # the Docking Module on Kristall's axial APAS, turned 60 deg so the
    # petals interleave
    Rd = Rk @ kit.rot('x', 60)
    at_dm = atk + Rk @ np.array([apas, 0, 0])
    tk.docking_module(a.sub(Rd, at_dm))
    MASSES.append(('Docking Module', 4090, at_dm + Rk @ np.array([2.35, 0, 0])))

    # Soyuz TM-27 at the node's forward port: its probe in the drogue, its
    # collar on the port's ring; wings 35 deg round from +Y
    t = math.radians(35)
    Rs = _frame((-1, 0, 0), (0, math.cos(t), math.sin(t)))
    o = np.array([co.X_FWD_PORT - 0.53, 0, 0])
    sz.soyuz_tm(a.sub(Rs, o))
    MASSES.append(('Soyuz TM-27', 7070, o + Rs @ np.array([-3.6, 0, 0])))
    # Progress M-39 on Kvant-1's aft port
    t = math.radians(-20)
    Rp = _frame((1, 0, 0), (0, math.cos(t), math.sin(t)))
    o = np.array([co.X_AFT_PORT - co.KV1_LEN + 0.53, 0, 0])
    sz.progress_m(a.sub(Rp, o))
    MASSES.append(('Progress M-39', 7130, o + Rp @ np.array([-3.8, 0, 0])))

    m = np.array([w for _, w, _ in MASSES], float)
    c = np.array([p for _, _, p in MASSES], float)
    com = (m[:, None] * c).sum(0) / m.sum()
    parts = kit.transform_parts(a.parts(kit), np.eye(3), -com)
    return dict(meta=dict(
        name="Mir (STS-91, June 1998: Kvant-1, -2, Kristall with the Docking Module, Spektr, "
             "Priroda, Soyuz TM-27, Progress M-39)",
        frame="Mir: +X along the core toward the forward node (Mir -X), +Z toward Priroda "
              "(Mir +Z), +Y toward Spektr (Mir -Y); m; centre of mass",
        source="portview/vehicles/mir.py: shapes to published dimensions (NASA RP-1357 Mir Hardware "
               "Heritage, NASA TM-107502, NASA Mir Mission Chronicle) and STS-71..91 photographs",
        norad=16609, mag_1000km=-0.8, mass_kg=float(m.sum()),
        com_node_frame=[round(float(v), 3) for v in com]),
        parts=parts)
