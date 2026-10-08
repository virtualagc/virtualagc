"""Leasat 3 (Syncom IV-3, NORAD 15643), as repaired by STS-51I: a first
approximation, simple shapes to published dimensions."""

KEY = 'leasat3'


def build(kit):
    p = [kit.part("solar drum", (0.04, 0.05, 0.10), kit.cylinder(2.13, -1.40, 1.40)),
         kit.part("forward deck", (0.80, 0.80, 0.80), kit.disc(2.13, 1.405)),
         kit.part("aft deck", (0.75, 0.62, 0.30), kit.disc(2.13, -1.405)),
         kit.part("UHF helix", (0.85, 0.85, 0.85), kit.cylinder(0.30, 1.40, 3.30)),
         kit.part("UHF dish", (0.90, 0.90, 0.90), kit.frustum(0.15, 0.85, 1.40, 1.80)),
         kit.part("omni", (0.80, 0.80, 0.80), kit.cylinder(0.06, 3.30, 3.90)),
         kit.part("liquid motor", (0.30, 0.30, 0.30), kit.frustum(0.30, 0.60, -1.40, -2.20))]
    return dict(meta=dict(name="Leasat 3 (Syncom IV; approximate)",
                          frame="Leasat: +X along the spin axis toward the antennas; m; mid-drum",
                          source="simple shapes to published dimensions (portview/vehicles)",
                          norad=15643, mag_1000km=2.0),
                parts=p)
