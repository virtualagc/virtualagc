"""Westar 6 (NORAD 14688), an HS-376, as retrieved by STS-51A."""
from . import _hs376

KEY = 'westar6'


def build(kit):
    return dict(meta=dict(name="Westar 6 (HS-376; approximate)",
                          frame="HS-376: +X along the spin axis toward the antenna; m; mid-drum",
                          source="simple shapes to published dimensions (portview/vehicles)",
                          norad=14688, mag_1000km=3.0),
                parts=_hs376.parts(kit))
