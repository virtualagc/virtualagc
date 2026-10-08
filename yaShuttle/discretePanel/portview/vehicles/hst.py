"""The Hubble Space Telescope (NORAD 20580), from NASA 3D Resources' Hubble (A)."""
import numpy as np

KEY = 'hst'

# In inches: the aperture at +z (the 3.0 m light shield; the 4.3 m aft
# shroud, with WFC3's bay, at the other end), the solar arrays along x; the
# file's node already centres it.  This takes it to V1 (toward the
# aperture), V2 (along the arrays), V3, in metres.
ROOT = np.array([[0.0, 0.0, 1.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0]]) * 0.0254


def build(kit):
    parts = kit.nasa_glb("Hubble Space Telescope (A)/Hubble Space Telescope (A).glb", ROOT)
    return dict(meta=dict(name="Hubble Space Telescope (after SM4, 2009)",
                          frame="HST V1 (toward the aperture), V2 (along the arrays), V3; m; its middle",
                          source="NASA 3D Resources, Hubble Space Telescope (A)",
                          norad=20580, mag_1000km=1.5),
                parts=parts)
