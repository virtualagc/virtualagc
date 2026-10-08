"""The Compton Gamma Ray Observatory (NORAD 21225), as STS-37 deployed it
in April 1991 -- after Ross and Apt freed its stuck high-gain antenna boom
by EVA: from NASA 3D Resources' "Gamma Ray Observatory", recoloured.

The file's units are ~6.9 m each (its body 1.09 x 0.60 x 0.65 units against
CGRO's published 7.6 m length and 4.6 m girth; its arrays' 3.17 units
against the 21 m span): x along the body (EGRET's dome toward +x, OSSE at
-x), y the instruments' pointing axis (the domes on +y), z along the
solar arrays, the 4.4 m high-gain antenna boom down and aft (-x, -y).
Here: +X along the body toward EGRET, +Z the instruments' pointing
direction, +Y = -z (along the arrays); the origin the main body's
centre (the 17 t observatory's mass is mostly in it)."""
import numpy as np

KEY = 'cgro'

SCALE = 6.9
ROOT = np.array([[1.0, 0.0, 0.0], [0.0, 0.0, -1.0], [0.0, 1.0, 0.0]]) * SCALE
ORIGIN = (0.033, 0.10, 0.0)

# The file's colours are lit-render values (pure white, purple cells);
# these are linear albedos.
RECOLOUR = {
    "GRO-DetailWhiteFlat": (0.78, 0.78, 0.76),
    "GRO-DetailWhiteSmooth": (0.78, 0.78, 0.76),
    "GRO-mainbody-X": (0.80, 0.80, 0.78),
    "GRO-mainbody-Y": (0.80, 0.80, 0.78),
    "GRO-mainbody-Z": (0.80, 0.80, 0.78),
    "GRO-mainbodyComptel": (0.80, 0.80, 0.78),
    "GRO-humpyWhite": (0.80, 0.80, 0.78),
    "GRO-SolarPanelFace": (0.04, 0.05, 0.13),
    "GRO-SolarPanelEdges": (0.30, 0.30, 0.30),
    "GRO-mainbodyEgretDome": (0.62, 0.62, 0.64),
    "GRO-mainbodyComptelDome": (0.62, 0.62, 0.64),
    "GRO-mainbodyComptelBatseSensor": (0.55, 0.55, 0.57),
    "GRO-humpySilver": (0.60, 0.60, 0.62),
    "GRO-DetailBlackFlat": (0.04, 0.04, 0.04),
    "GRO-DetailSilverFlat": (0.25, 0.25, 0.26),
}


def build(kit):
    parts = kit.nasa_glb("Gamma Ray Observatory/Gamma Ray Observatory.glb", ROOT, ORIGIN)
    for p in parts:
        if p['name'] == "GRO-SolarPanelFace":
            # the file's cell faces lie in the plane of the arrays' white
            # backs (GRO-DetailWhiteFlat): stand them 5 mm off, along their
            # own normals, so the cells show on the front and the backs behind
            pos, idx = np.asarray(p['pos'], float), np.asarray(p['idx']).reshape(-1, 3)
            f = np.cross(pos[idx[:, 1]] - pos[idx[:, 0]], pos[idx[:, 2]] - pos[idx[:, 0]])
            n = np.zeros_like(pos)
            for j in range(3):
                np.add.at(n, idx[:, j], f)
            n /= np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)
            p['pos'] = pos + 0.005 * n
        if p['name'] in RECOLOUR:
            p['color'] = list(RECOLOUR[p['name']]) + [1.0]
        p['metallic'] = 0.0
    return dict(meta=dict(name="Compton Gamma Ray Observatory",
                          frame="CGRO: +X along the body toward EGRET, +Y along the solar arrays, "
                                "+Z the instruments' pointing axis (the domes' side); m; the main "
                                "body's centre",
                          source="NASA 3D Resources, Gamma Ray Observatory (scaled ~6.9 m a unit, recoloured)",
                          norad=21225, mag_1000km=1.0),
                parts=parts)
