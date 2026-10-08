"""Palapa B2 (NORAD 14692), a Hughes HS-376, as STS-51A retrieved it on
12 November 1984: still stowed, as its failed PAM-D left it in February
(antenna folded, outer solar panel not dropped).  Palapa B is the HS-376
stretched for 24 transponders and 1100 W: 9 ft 4 in (2.84 m) stowed against
Westar's 9 ft, 6.96 m deployed against 6.58 m (Gunter's Space Page; STS-41B
press kit: 6.8 m) -- so its outer solar panel is drawn 0.10 m longer than
Westar 6's; otherwise the photographs (51A-39-036, 51A-41-021) show the
same outside: the same 1.83 m dual-gridded reflector folded over the
forward end, the gold feed assembly and the omni.  Body frame and origin:
see _hs376.py."""
from . import _hs376

KEY = 'palapab2'


def build(kit):
    return dict(meta=_hs376.meta("Palapa B2 (HS-376, stowed, as retrieved by STS-51A)", 14692),
                parts=_hs376.parts(kit, skirt=2.05, seed=2))
