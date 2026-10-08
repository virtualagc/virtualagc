"""Mir (NORAD 16609), from NASA 3D Resources' simple Mir."""
import numpy as np

KEY = 'mir'

# ~0.0221 m a unit (its core module's 4.15 m across is ~188 units), the core
# along y (+y toward the docking node), the axis at x 461, z -940.  To +X
# along the core toward the node, +Y = model x, +Z = -model z; origin in
# the middle of the complex (its extent's centre, standing in for the
# centre of mass).
SCALE = 0.0221
ROOT = np.array([[0.0, 1.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, -1.0]]) * SCALE
ORIGIN = (449.0, 298.0, -940.0)


def build(kit):
    parts = kit.nasa_glb("Mir/Mir.glb", ROOT, ORIGIN)
    return dict(meta=dict(name="Mir (a simple model)",
                          frame="Mir: +X along the core toward the node, +Y, +Z; m; mid-complex",
                          source="NASA 3D Resources, Mir", norad=16609, mag_1000km=-0.8),
                parts=parts)
