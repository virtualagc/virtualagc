"""The Solar Maximum Mission (NORAD 11703), as repaired by STS-41C: a first
approximation, simple shapes to published dimensions."""

KEY = 'smm'


def build(kit):
    cells = (0.04, 0.05, 0.10)
    p = [kit.part("MMS bus", (0.80, 0.80, 0.78), kit.cylinder(1.15, -2.00, -0.50)),
         kit.part("instrument module", (0.75, 0.62, 0.30), kit.cylinder(1.00, -0.50, 2.00)),
         kit.part("Sun end", (0.20, 0.20, 0.20), kit.disc(1.00, 2.005)),
         kit.part("solar array +Y", cells, kit.box((1.5, 4.2, 0.04), (-1.2, 3.3, 0.0))),
         kit.part("solar array -Y", cells, kit.box((1.5, 4.2, 0.04), (-1.2, -3.3, 0.0))),
         kit.part("high-gain mast", (0.80, 0.80, 0.80), kit.cylinder(0.05, -2.00, -3.20)),
         kit.part("grapple pin", (0.80, 0.80, 0.80), kit.box((0.10, 0.10, 0.25), (-1.25, 0.0, 1.20)))]
    return dict(meta=dict(name="Solar Maximum Mission (approximate)",
                          frame="SMM: +X along the instruments' axis (toward the Sun); m; mid-length",
                          source="simple shapes to published dimensions (portview/vehicles)",
                          norad=11703, mag_1000km=2.0),
                parts=p)
