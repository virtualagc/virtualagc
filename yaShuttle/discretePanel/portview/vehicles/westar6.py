"""Westar 6 (NORAD 14688), a Hughes HS-376, as STS-51A retrieved it on
14 November 1984: still stowed, as its failed PAM-D left it in February
(antenna folded, outer solar panel not dropped).  The geometry is
_hs376.py's; this is its Westar dimensions: stowed height 9 ft (2.74 m),
the outer solar panel 1.95 m long.  Body frame and origin: see _hs376.py
(+X along the spin axis toward the folded antenna; origin the estimated
centre of mass)."""
from . import _hs376

# True: with the Stinger in the apogee motor's nozzle, as the RMS held it
# after the EVA capture (see _hs376.py); False: as the Orbiter approached it.
CAPTURED = False

KEY = 'westar6'


def build(kit):
    return dict(meta=_hs376.meta("Westar 6 (HS-376, stowed, as retrieved by STS-51A)", 14688),
                parts=_hs376.parts(kit, skirt=1.95, seed=6, capture=CAPTURED))
