"""The Inflatable Antenna Experiment after its jettison from Spartan 207
(NORAD 23872), STS-77, May 1996: the 14 m reflector, its torus, the three
struts and the plate they met at (see _leo_iae)."""
import numpy as np

from . import _leo_iae
from . import _leo_util as U

KEY = 'iae'


def build(kit):
    parts = _leo_iae.parts(kit, root=(0.0, 0.0, 0.0))
    # the origin near the reflector, where most of the mass (the inflated
    # envelope and torus) is: shift everything so the rim centre is 3/4 of
    # the way from the struts' root
    off = -0.75 * _leo_iae.CENTRE
    for p in parts:
        p['pos'] = np.asarray(p['pos'], float) + off
    parts.append(kit.part("jettison plate", (0.62, 0.62, 0.64), kit.box((0.10, 0.75, 0.75), off - (0.05, 0, 0))))
    c = 0.25 * _leo_iae.CENTRE
    return dict(meta=dict(name="Inflatable Antenna Experiment (jettisoned, STS-77)",
                          frame="IAE: +X the reflector's axis (normal to the torus's plane, from the "
                                "struts' root toward it), +Z toward the struts' root's side of the rim "
                                "(the root lies %.0f m off the axis); the rim's centre at (%.2f, 0, %.2f) "
                                "m; the origin three quarters of the way from the root to it"
                                % (_leo_iae.OFFSET, c[0], c[2]),
                          source="simple shapes to published dimensions (eoPortal, from L'Garde) and the "
                                 "STS-77 photographs (s77e5025, s77e5027, s77e5033, sts077-150-044)",
                          norad=23872, mag_1000km=0.0),
                parts=U.refine_parts(parts))
