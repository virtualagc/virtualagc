"""Spartan 207 with the Inflatable Antenna Experiment (NORAD 23871), as
STS-77 saw it in May 1996 (see _leo_iae): the Spartan carrier (the
Spartan 201 file's carrier, its telescope tubes cut away, its blankets the
copper-gold of 207's) with the IAE canister on its +X face and the
antenna inflated.  IAE_ATTACHED False gives the bare Spartan that
Endeavour retrieved after the antenna's jettison."""
import numpy as np

from . import _leo_iae, _leo_spartan
from . import _leo_util as U

KEY = 'spartan207'
IAE_ATTACHED = True

COPPER = _leo_spartan.COPPER


def build(kit):
    p = _leo_spartan.copper_carrier(kit)
    # the IAE canister on the +X face
    can = kit.box((0.55, 0.75, 0.75), (0.80, 0.0, 0.0))
    p.append(U.tpart(kit, "IAE canister (copper blanket)", COPPER, can, U.tex_mli(82, seams=1, depth=0.5), tile=0.7))
    p.append(kit.part("IAE label plate", (0.70, 0.70, 0.70), kit.box((0.01, 0.40, 0.30), (1.08, 0.0, 0.15))))
    if IAE_ATTACHED:
        p += _leo_iae.parts(kit, root=(1.08, 0.0, 0.0))
    return dict(meta=dict(name="Spartan 207 / Inflatable Antenna Experiment (STS-77)" +
                          ("" if IAE_ATTACHED else " (antenna jettisoned)"),
                          frame="Spartan: +X out of the IAE canister's face (toward the antenna), +Y "
                                "toward the grapple fixture's face, +Z across; m; the carrier box's "
                                "centre (the antenna's ~60 kg against the Spartan's ~1.3 t)",
                          source="NASA 3D Resources' Spartan 201 carrier (tubes cut away), simple "
                                 "shapes for the IAE to published dimensions and STS-77 photographs",
                          norad=23871, mag_1000km=0.5 if IAE_ATTACHED else 3.5),
                parts=U.refine_parts(p))
