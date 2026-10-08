"""The Inflatable Antenna Experiment (L'Garde / JPL, STS-77, May 1996),
flown on Spartan 207: a 14 m offset reflector of aluminised Mylar (a
lenticular envelope whose front canopy was clear) held in an inflated
torus, on three inflated struts 28 m long running back to its canister
on the Spartan's +X face.  Inflated beside Endeavour for about 90
minutes, then jettisoned (it re-entered within days); the Spartan was
retrieved.  Proportions from s77e5022/5027/5033."""
import math

import numpy as np

from . import _leo_util as U

SILVER = (0.62, 0.63, 0.66)       # the reflector: aluminised Mylar, crinkled
STRUT = (0.60, 0.60, 0.62)
CENTRE = np.array([26.0, 0.0, -5.0])  # the reflector rim's centre, from the canister's face
RIM = 7.0
SAG = 0.9


def parts(kit, root=(0.0, 0.0, 0.0)):
    """The inflated antenna, struts from `root` (the canister's top)."""
    root = np.asarray(root, float)
    p = []
    Rs = (RIM ** 2 + SAG ** 2) / (2 * SAG)
    dome = kit.sphere(Rs, n=24, centre=(0.0, 0.0, 0.0), x_range=(Rs - SAG, Rs))
    dome = kit.move(dome, CENTRE - (Rs - SAG, 0, 0))
    p.append(U.tpart(kit, "reflector (aluminised Mylar)", SILVER, dome, U.tex_mli(81, seams=0, depth=0.5), tile=3.0))
    # the canopy is clear; the torus round the rim
    p.append(kit.part("torus", STRUT, U.torus(RIM, 0.30, n=72, m=10, centre=CENTRE), smooth=True))
    st = []
    for deg in (80.0, 200.0, 320.0):
        a = math.radians(deg)
        q = CENTRE + RIM * np.array([0.0, math.cos(a), math.sin(a)])
        st.append(kit.rod(root, q, 0.15, n=10))
    p.append(kit.part("inflated struts", STRUT, *st))
    return p
