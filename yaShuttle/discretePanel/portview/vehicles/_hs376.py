"""The Hughes HS-376 (Westar 6, Palapa B2) as retrieved by STS-51A: a
first approximation, simple shapes to published dimensions.  +X along the
spin axis toward the antenna; m; the drum's middle."""


def parts(kit):
    cells = (0.04, 0.05, 0.10)
    gold = (0.75, 0.62, 0.30)
    return [kit.part("solar drum", cells, kit.cylinder(1.08, -1.41, 0.40), smooth=False),
            kit.part("solar skirt", cells, kit.cylinder(1.07, 0.40, 1.41)),
            kit.part("forward barrier", gold, kit.disc(1.08, 1.415)),
            kit.part("antenna mast", (0.8, 0.8, 0.8), kit.cylinder(0.25, 1.41, 2.10)),
            kit.part("stowed reflector", (0.85, 0.85, 0.85), kit.cylinder(0.85, 1.80, 1.95)),
            kit.part("apogee motor nozzle", (0.25, 0.25, 0.25), kit.frustum(0.20, 0.45, -1.41, -2.00)),
            kit.part("aft barrier", gold, kit.disc(1.08, -1.415))]
