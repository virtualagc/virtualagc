"""The Hubble Space Telescope (NORAD 20580) as after Servicing Mission 4
(STS-125, May 2009) -- as the Shuttle last saw it: the rigid SA3 arrays,
the NOBL covers on seven Equipment Section bays, the Soft Capture
Mechanism on the aft bulkhead, the aperture door closed.

Built to the published dimensions (HST Media Reference Guides, SM3A and
SM4 editions) with procedural textures, checked against the STS-125
photographs (S125-E-006669..6956 at rendezvous, -011615..011780 at
release), with layout details (the forward shell / light shield split,
the grapple fixtures', trunnions', instrument doors' and magnetometers'
places) from NASA 3D Resources' "Hubble Space Telescope (B)" -- an
engineering-derived model too incomplete to use as it is (no aft shroud
skin, no array blankets, many parts misplaced) -- see _hst_model.py.

Frame: V1 (toward the aperture), V2 (along the solar-array masts), V3 (along
the high-gain-antenna masts; the door's hinge on +V3); m; origin at the
estimated centre of mass, on the axis 4.65 m forward of the aft bulkhead.
"""
from . import _hst_model

KEY = 'hst'

DOOR_DEG = 0.0          # aperture door: 0 closed .. 105 fully open
ARRAY_DEG = 0.0         # solar arrays turned about V2 from cells-toward-+V3


def build(kit):
    parts = _hst_model.build(kit, '2009', DOOR_DEG, ARRAY_DEG)
    return dict(meta=dict(name="Hubble Space Telescope (after SM4, 2009)",
                          frame="HST V1 (toward the aperture), V2 (along the solar-array masts), "
                                "V3 (along the HGA masts); m; centre of mass (est.), "
                                "4.65 m forward of the aft bulkhead",
                          source="portview/vehicles/_hst_model.py: published dimensions (HST Media "
                                 "Reference Guides), procedural textures, STS-125 photographs; layout "
                                 "details from NASA 3D Resources' Hubble Space Telescope (B)",
                          norad=20580, mag_1000km=1.5),
                parts=parts)
