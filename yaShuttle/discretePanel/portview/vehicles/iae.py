"""The Inflatable Antenna Experiment after its jettison from Spartan 207
(NORAD 23872), STS-77, May 1996: the 14 m reflector, its torus, the three
28 m struts and the canister plate they met at (see _leo_iae)."""
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
    parts.append(kit.part("jettison plate", (0.55, 0.55, 0.56), kit.box((0.10, 0.6, 0.6), off - (0.05, 0, 0))))
    return dict(meta=dict(name="Inflatable Antenna Experiment (jettisoned, STS-77)",
                          frame="IAE: +X from the struts' root toward the reflector, the reflector's "
                                "rim centre at +Z -1.25 m; m; three quarters of the way out to the rim",
                          source="simple shapes to published dimensions and STS-77 photographs",
                          norad=23872, mag_1000km=0.0),
                parts=U.refine_parts(parts))
