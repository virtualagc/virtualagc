"""Spartan 207 with the Inflatable Antenna Experiment (NORAD 23871), as
STS-77 saw it in May 1996 (see _leo_iae).

The Spartan carrier (the Spartan 201 file's, its telescope tubes cut away)
in the copper-gold Kapton blankets of 207, as sts077-711-039 and s77e5064
show it on the arm after the antenna's jettison: on +Z a louvred radiator
of four bays (white vanes in copper frames) across the whole face; beyond
it at -X a copper-blanketed equipment section with the mission sticker; at
+X the IAE's aluminium canister tray (packed 2.04 x 1.08 x 0.5 m: here the
0.45 m tray across the carrier's end, open at +X, the struts' root) with
its "IAE" plate; the grapple fixture on +Y.  The NASA file's carrier is
turned end for end (180 degrees about Y) so that its louvred face, -Z in the
file, is the +Z the photographs show beside the +Y grapple fixture with
the IAE at +X; the louvres the file draws there are replaced by the four
bays.  IAE_ATTACHED False gives the bare Spartan that Endeavour retrieved
after the jettison: the empty tray."""
import numpy as np

from . import _leo_iae, _leo_spartan
from . import _leo_util as U

KEY = 'spartan207'
IAE_ATTACHED = True

COPPER = (0.68, 0.37, 0.12)               # 207's Kapton: brighter, more orange than the file's (sts077-711-039)
ALU = (0.70, 0.71, 0.73)
X_TRAY0, X_TRAY1 = 0.515, 0.965           # the canister tray, from the carrier's +X face
ROOT = np.array([X_TRAY1 - 0.05, 0.0, 0.0])
_TEX = {}


def tex_louvres(w=600, h=500, bays=4, vanes=13):
    """sts077-711-039's radiator: four bays of white louvre vanes, copper
    frames between; u across the bays (Y), v along the vanes' stack (X).
    Colour in the texture (use a white part colour)."""
    key = ('louvres', w, h, bays, vanes)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image
    yy, xx = np.mgrid[0:h, 0:w]
    img = np.ones((h, w, 3)) * np.array([0.03, 0.03, 0.035])
    pitch = (h - 40) / vanes
    vane = ((yy - 20) % pitch) < pitch * 0.38
    img[vane] = (0.80, 0.80, 0.80)
    bay_w = (w - 20) / bays
    frame = ((xx - 10) % bay_w < 14) | (xx > w - 12) | (yy < 20) | (yy > h - 20)
    img[frame] = (0.60, 0.33, 0.11)
    im = Image.fromarray((np.clip(img, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))
    _TEX[key] = im
    return im


def tex_label(text, w=256, h=128):
    key = ('label', text, w, h)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image, ImageDraw, ImageFont
    im = Image.new("RGB", (w, h), (235, 235, 230))
    d = ImageDraw.Draw(im)
    try:
        d.text((w / 2, h / 2), text, font=ImageFont.load_default(size=int(h * 0.7)), fill=(10, 10, 10), anchor="mm")
    except Exception:
        d.text((w / 3, h / 3), text, fill=(10, 10, 10))
    d.rectangle((0, 0, w - 1, h - 1), outline=(130, 130, 135), width=6)
    _TEX[key] = im
    return im


def tex_sticker(w=128, h=128):
    key = ('sticker', w, h)
    if key in _TEX:
        return _TEX[key]
    from PIL import Image, ImageDraw
    im = Image.new("RGB", (w, h), (235, 235, 230))
    d = ImageDraw.Draw(im)
    d.ellipse((10, 14, 86, 90), fill=(40, 60, 120))
    d.ellipse((30, 30, 70, 70), fill=(220, 160, 40))
    d.ellipse((70, 40, 118, 88), fill=(160, 160, 165))
    _TEX[key] = im
    return im


def quad(kit, name, rgb, image, centre, normal, right, su, sv, thick=0.01):
    n, r = np.asarray(normal, float), np.asarray(right, float)
    up = np.cross(n, r)
    m = U.unshare(U.refine(U.place(kit, kit.box((thick, su, sv)), np.column_stack([n, r, up]), centre), 0.4))
    q = np.asarray(m[0]) - np.asarray(centre, float)
    uv = np.column_stack([q @ r / su + 0.5, 0.5 - q @ up / sv]).astype(np.float32)
    return kit.part(name, rgb, m, texture=image, uv=uv)


def carrier(kit):
    """The copper carrier turned end for end, the file's louvred face (now
    +Z) cleared for the four-bay radiator."""
    R = kit.rot('y', 180)
    out = []
    for q in kit.transform_parts(_leo_spartan.copper_carrier(kit), R):
        pos, idx = np.asarray(q['pos'], float), np.asarray(q['idx']).reshape(-1, 3)
        c = pos[idx].mean(axis=1)
        n = np.cross(pos[idx[:, 1]] - pos[idx[:, 0]], pos[idx[:, 2]] - pos[idx[:, 0]])
        flat = np.abs(n[:, 2]) > 0.95 * np.linalg.norm(n, axis=1)       # facing +-Z
        on_face = flat & (c[:, 2] > 0.50) & (np.abs(c[:, 0]) < 0.53) & (np.abs(c[:, 1]) < 0.66)
        if on_face.all():
            continue
        q['idx'] = idx[~on_face]
        if q['name'] in _leo_spartan._BLANKETS:
            q['color'] = list(COPPER) + [1.0]
        out.append(q)
    return out


def build(kit):
    p = carrier(kit)
    p.append(quad(kit, "louvred radiator", (0.95, 0.95, 0.95), tex_louvres(), (0.0, -0.01, 0.590),
                  (0, 0, 1), (0, 1, 0), 1.24, 1.04, thick=0.03))
    # the equipment section at -X, copper blankets, the mission sticker
    sec = kit.box((0.62, 1.18, 1.10), (-0.83, -0.02, 0.0))
    side = kit.box((0.30, 0.22, 0.62), (-0.70, 0.66, 0.05))
    p.append(U.tpart(kit, "equipment section (copper Kapton)", COPPER, kit.merge(sec, side),
                     U.tex_mli(207, seams=1, depth=0.65), tile=0.6, fine=0.35))
    p.append(quad(kit, "mission sticker", (0.9, 0.9, 0.9), tex_sticker(), (-0.95, -0.15, 0.556),
                  (0, 0, 1), (0, 1, 0), 0.28, 0.28, thick=0.008))
    # the IAE canister tray at +X: aluminium walls, the dark inside
    t0, t1 = X_TRAY0, X_TRAY1
    L, hy, hz, wall = t1 - t0, 0.60, 0.56, 0.03
    xc = (t0 + t1) / 2
    walls = [kit.box((L, 2 * hy, wall), (xc, 0, hz - wall / 2)), kit.box((L, 2 * hy, wall), (xc, 0, -hz + wall / 2)),
             kit.box((L, wall, 2 * hz - 2 * wall), (xc, hy - wall / 2, 0)),
             kit.box((L, wall, 2 * hz - 2 * wall), (xc, -hy + wall / 2, 0)),
             kit.box((0.04, 2 * hy + 0.04, 0.04), (t1, 0, hz)), kit.box((0.04, 2 * hy + 0.04, 0.04), (t1, 0, -hz)),
             kit.box((0.04, 0.04, 2 * hz), (t1, hy, 0)), kit.box((0.04, 0.04, 2 * hz), (t1, -hy, 0))]
    p.append(U.tpart(kit, "IAE canister tray (aluminium)", ALU, kit.merge(*walls), U.tex_panels(3, 2, seed=77, spread=0.12),
                     tile=0.6))
    p.append(kit.part("tray floor", (0.05, 0.05, 0.055), kit.box((0.02, 2 * hy - 0.08, 2 * hz - 0.08), (t0 + 0.03, 0, 0))))
    p.append(quad(kit, "IAE plate", (0.9, 0.9, 0.9), tex_label("IAE"), (xc, 0.0, hz + 0.007),
                  (0, 0, 1), (0, 1, 0), 0.40, 0.20, thick=0.008))
    if IAE_ATTACHED:
        # the packed envelope's remains and the struts' manifold in the tray
        p.append(U.tpart(kit, "inflation manifold (aluminised wrap)", _leo_iae.STRUT,
                         kit.box((0.30, 0.80, 0.70), (t1 - 0.17, 0, 0)), U.tex_mli(83, seams=0, depth=0.6), tile=0.4))
        p += _leo_iae.parts(kit, root=ROOT)
    return dict(meta=dict(name="Spartan 207 / Inflatable Antenna Experiment (STS-77)" +
                          ("" if IAE_ATTACHED else " (antenna jettisoned)"),
                          frame="Spartan: +X out of the IAE canister's open end (toward the antenna), "
                                "+Y toward the grapple fixture's face, +Z the louvred radiator's face "
                                "(the NASA file's carrier turned 180 degrees about Y to put it there); "
                                "m; the carrier box's centre (the antenna's ~60 kg against the "
                                "Spartan's ~0.8 t)",
                          source="NASA 3D Resources' Spartan 201 carrier (tubes cut away, turned end "
                                 "for end); simple shapes for the equipment section, louvres, canister "
                                 "and IAE to published dimensions (eoPortal) and the STS-77 photographs "
                                 "(sts077-711-039, s77e5064, s77e5025, s77e5027)",
                          norad=23871, mag_1000km=0.5 if IAE_ATTACHED else 3.5),
                parts=U.refine_parts(p))
