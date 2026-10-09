"""The Hubble Space Telescope as deployed by STS-31 (April 1990): the
flexible SA1 arrays (12.1 x 3.3 m wings, gold-brown blanket backs), new
blankets, no NOBL covers, no Soft Capture Mechanism, the magnetometers
uncovered.  A variant of hst.py (see there and _hst_model.py) for later
selection: it has no NORAD id, since 20580 is hst's and two models can't
share one -- portview draws it only if a NORAD id is given it.
"""
from . import _hst_model

KEY = 'hst1990'

DOOR_DEG = 0.0
ARRAY_DEG = 0.0


def build(kit):
    parts = _hst_model.build(kit, '1990', DOOR_DEG, ARRAY_DEG)
    return dict(meta=dict(name="Hubble Space Telescope (as deployed, 1990)",
                          frame="HST V1 (toward the aperture), V2 (along the solar-array masts), "
                                "V3 (along the HGA masts); m; centre of mass (est.), "
                                "4.65 m forward of the aft bulkhead",
                          source="portview/vehicles/_hst_model.py: published dimensions (HST Media "
                                 "Reference Guides), procedural textures, STS-31 photographs",
                          mag_1000km=1.5, variant_of=20580),   # portview --vehicle hst1990
                parts=parts)
