"""SPAS-01, the first Shuttle Pallet Satellite (NORAD 14142), as STS-7
deployed it in June 1983, flew in formation with it (photographing
Challenger -- the first pictures of an orbiter in flight) and caught it
again with the arm.  (The same platform, refitted as SPAS-01A, stayed on
the arm on STS-41B.)

MBB's SPAS-01 is a long blanketed beam across the payload bay with a keel
truss under it, not an open trapezoid: the photographs show

* the body: a box 4.33 m long (Y, across the bay) under the top deck, all
  in white beta-cloth blankets, with the round lower longeron (a blanketed
  tube ~0.6 m across, round-ended) along its foot, 1.28 m below the deck;
  on each end a yellow triangular trunnion fitting, its longeron trunnion
  pin at the top (pin tips 5.0 m apart, the bay's longeron trunnions);
* the forward face (+X), left to right seen from the cabin: a blanketed
  box, a white blanketed cylinder standing upright, a white-painted box
  with a small black tag, a second cylinder, and a wide blanketed box (two
  boxes) -- all hung from the deck's edge, ~0.95 m tall;
* the top deck: (from -Y) a blanketed camera box with its lens forward,
  two small boxes, a dark flat box, the grapple fixture (the arm took it
  from above, a little -Y of the middle), a flat white box, the white dome,
  the second camera box (the big lens forward) and small boxes at +Y;
* the keel truss: two white struts in a V from the lower longeron down to
  the keel fitting, a cross bar and centre post, the white triangular
  shear panel lettered "MBB SPAS-01" with the US and German flags, the
  brown ball at the apex and the keel pin below it; more struts run from
  the apex back up to the body.

Proportions measured off S07-25-1421 (the satellite square-on from the
front just after release: trunnion tips 1305 px = 5.0 m gives 261 px/m,
and the whole then measures 3.41 m from dome to keel pin, the press kits'
3.4 m), checked against S07-11-528, S83-35782 and S07-18-774 (STS-7, in
the bay from the aft windows) and the STS-7 frame of it on the arm seen
from below (Wikimedia Commons "STS-7 SPAS-1.jpg"; its NASA number not
given there): the round lower longeron, the end fittings, the keel struts
fore and aft, the arm on the top deck.  41B-32-1224/1231 and 41B-40-2209/2210
(SPAS-01A on STS-41B) confirm the forward face; 41B's top deck and
right-hand boxes differ (a gold-foil package, a louvred radiator), so
STS-7's arrangement is the one drawn.  The depth along the bay (1.5 m) is
the press kits'; nothing photographed shows the aft face, which is drawn
plain.
"""
import math

import numpy as np

from . import _leo_util as U
from . import _leo_astrospas as A

KEY = 'spas01'

BLANKET = (0.80, 0.80, 0.77)        # white beta cloth
BLANKET_DIM = (0.70, 0.70, 0.68)    # the lower longeron (in the deck's shade)
PAINT = (0.85, 0.85, 0.83)          # white paint (the flat-faced box, struts)
YELLOW = (0.78, 0.58, 0.12)         # the trunnion fittings
BROWN = (0.40, 0.17, 0.09)          # the ball at the keel
STEEL = (0.62, 0.62, 0.64)
DARK = (0.10, 0.10, 0.11)

DECK = 0.70                         # the top deck's Z (the origin ~0.7 m below it)
HY = 2.165                          # the body's half-length (4.33 m)
X_FRONT, X_CORE, X_BACK = 0.78, 0.20, -0.72


def _z(dz):
    """A height measured down from the deck (S07-25-1421) as body Z."""
    return DECK + dz


def _tex_keel_panel():
    """The keel panel: white, 'MBB / SPAS-01' in black, the flags."""
    from PIL import Image, ImageDraw
    w, h = 512, 300
    im = Image.new("RGB", (w, h), (236, 236, 232))
    d = ImageDraw.Draw(im)
    A._text(d, (w // 2, int(h * 0.26)), "MBB", 78, (25, 25, 28), fit=int(w * 0.32))
    A._text(d, (w // 2, int(h * 0.48)), "SPAS-01", 44, (25, 25, 28), fit=int(w * 0.34))
    y0, y1 = int(h * 0.60), int(h * 0.68)
    x0 = w // 2 - 40                    # the US flag (stripes, canton) ...
    for k in range(7):
        d.rectangle((x0, y0 + k * (y1 - y0) / 7, x0 + 30, y0 + (k + 0.5) * (y1 - y0) / 7), fill=(200, 30, 40))
    d.rectangle((x0, y0, x0 + 12, (y0 + y1) // 2), fill=(30, 40, 110))
    x1 = w // 2 + 6                     # ... and the German: black, red, gold
    for k, c in enumerate(((15, 15, 15), (210, 20, 25), (240, 200, 20))):
        d.rectangle((x1, y0 + k * (y1 - y0) / 3, x1 + 34, y0 + (k + 1) * (y1 - y0) / 3), fill=c)
    return im


def _keel_panel(kit, x, tri, t=0.01):
    """The triangular shear panel in the plane X = x, its +X face mapped by
    the lettering (tri: [(y, z)] top-left, top-right, apex)."""
    m = U.unshare(U.refine(kit.prism(tri, x - t / 2, x + t / 2), 0.35))
    p = np.asarray(m[0])
    (ya, za), (yb, _), (_, zc) = tri
    # seen from +X, +Y is to the left: u runs along -Y
    uv = np.column_stack([(yb - p[:, 1]) / (yb - ya), (za - p[:, 2]) / (za - zc)]).astype(np.float32)
    # only the +X face carries the lettering (else it shows mirrored from -X)
    t = np.asarray(m[1])
    nx = np.cross(p[t[:, 1]] - p[t[:, 0]], p[t[:, 2]] - p[t[:, 0]])[:, 0]
    front = nx > 1e-9
    return [kit.part("keel panel (MBB SPAS-01)", PAINT, (p, t[front]), texture=_tex_keel_panel(), uv=uv),
            kit.part("keel panel (back and edges)", PAINT, (p, t[~front]))]


def build(kit):
    p = []
    mli = U.tex_mli(92, seams=2, depth=0.30)
    mli_mod = U.tex_mli(93, seams=1, depth=0.35)
    # ---------------------------------------------------------------- body
    # the core under the deck, the deck slab, and the round lower longeron
    core = kit.box((X_CORE - X_BACK, 2 * HY - 0.01, 0.89), ((X_CORE + X_BACK) / 2, 0.0, _z(-0.52)))
    deck = kit.box((X_FRONT - X_BACK + 0.02, 2 * HY, 0.07), ((X_FRONT + X_BACK) / 2, 0.0, _z(-0.035)))
    p.append(U.tpart(kit, "body blankets", BLANKET, kit.merge(core, deck), mli, tile=1.3, fine=0.4))
    beam = U.cylinder_fine(0.30, -2.04, 2.04, n=24, max_len=0.4, caps=False)
    beam = kit.move(kit.turn(beam, kit.rot('z', 90)), (-0.12, 0.0, _z(-0.98)))
    cap = kit.sphere(0.30, n=8, x_range=(0.0, 0.30))
    ends = [kit.move(kit.turn(cap, kit.rot('z', s * 90)), (-0.12, s * 2.04, _z(-0.98))) for s in (-1, 1)]
    p.append(U.tpart(kit, "lower longeron (blanket)", BLANKET_DIM, kit.merge(beam, *ends), mli, tile=0.9))
    # the yellow trunnion fittings on the ends, the pins at their tops
    fit = []
    tri = [(X_BACK + 0.15, _z(-0.06)), (X_FRONT - 0.15, _z(-0.06)), (0.03, _z(-0.88))]
    for s in (-1, 1):
        # a prism across Y (made along X, section (-x, z), turned a quarter about Z)
        plate = kit.turn(kit.prism([(-x, z) for x, z in tri], -0.015, 0.015), kit.rot('z', 90))
        fit.append(kit.move(plate, (0, s * (HY + 0.02), 0)))
    p.append(kit.part("trunnion fittings (yellow)", YELLOW, *fit))
    pins = [U.trunnion(kit, (0.03, s * (HY + 0.035), _z(-0.11)), (0, s, 0), 0.30, 0.041) for s in (-1, 1)]
    p.append(kit.part("trunnion pins", STEEL, *pins))
    # ----------------------------------------------------- the forward face
    xm = (X_FRONT + X_CORE + 0.005) / 2
    dxm = X_FRONT - X_CORE - 0.005
    boxes = [kit.box((dxm, 0.76, 0.865), (xm, -1.77, _z(-0.5075))),          # left
             kit.box((dxm, 0.80, 0.865), (xm, 1.13, _z(-0.5075))),           # wide box, two halves
             kit.box((dxm, 0.62, 0.865), (xm, 1.85, _z(-0.5075)))]
    p.append(U.tpart(kit, "forward boxes (blankets)", BLANKET, kit.merge(*boxes), mli_mod, tile=0.8))
    cyl = [kit.along(U.cylinder_fine(r, 0.0, 0.97, n=28, max_len=0.4), (0, 0, -1), (X_CORE + 0.005 + r, y, _z(-0.075)))
           for y, r in ((-1.04, 0.305), (0.39, 0.29))]
    p.append(U.tpart(kit, "forward cylinders (blankets)", BLANKET, kit.merge(*cyl), mli_mod, tile=0.7))
    p.append(kit.part("white-painted box", PAINT, kit.box((dxm - 0.02, 0.74, 0.85), (xm - 0.01, -0.33, _z(-0.505)))))
    p.append(kit.part("box tag", DARK, kit.box((0.01, 0.03, 0.08), (X_FRONT - 0.013, -0.36, _z(-0.55)))))
    # ----------------------------------------------------------- top deck
    top = [kit.box((0.55, 0.60, 0.38), (0.45, -1.75, DECK + 0.195)),        # camera box (lens fwd)
           kit.box((0.40, 0.29, 0.31), (0.40, -1.19, DECK + 0.160)),
           kit.box((0.70, 0.67, 0.20), (0.05, 0.37, DECK + 0.105)),         # flat box
           kit.box((0.50, 0.42, 0.50), (0.40, 1.59, DECK + 0.255)),         # camera box (big lens)
           kit.box((0.35, 0.30, 0.23), (0.30, 1.98, DECK + 0.120)),
           kit.box((0.40, 0.45, 0.25), (-0.40, -1.20, DECK + 0.130)),      # aft of the deck (plan only)
           kit.box((0.45, 0.55, 0.30), (-0.40, 1.60, DECK + 0.155))]
    p.append(U.tpart(kit, "deck boxes (blankets)", BLANKET, kit.merge(*top), mli_mod, tile=0.6))
    p.append(kit.part("dark box", (0.22, 0.22, 0.23), kit.box((0.45, 0.30, 0.21), (0.30, -0.85, DECK + 0.110))))
    # the dome: a short drum and a hemisphere, 0.62 m across, 0.48 m high
    dome = [kit.along(kit.cylinder(0.31, 0.0, 0.17, n=32, caps=False), (0, 0, 1), (0.30, 1.04, DECK + 0.005)),
            kit.move(kit.turn(kit.sphere(0.31, n=12, x_range=(0.0, 0.31)), kit.rot('y', -90)), (0.30, 1.04, DECK + 0.175))]
    p.append(kit.part("dome", PAINT, *dome, smooth=True))
    lens = [kit.along(kit.cylinder(0.07, 0.0, 0.065, n=16), (1, 0, 0), (0.72, -1.58, DECK + 0.295)),
            kit.along(kit.cylinder(0.10, 0.0, 0.075, n=20), (1, 0, 0), (0.645, 1.55, DECK + 0.305))]
    p.append(kit.part("camera lens barrels", (0.45, 0.45, 0.46), *lens))
    glass = [kit.along(kit.disc(0.05, 0.0, n=16), (1, 0, 0), (0.79, -1.58, DECK + 0.295)),
             kit.along(kit.disc(0.075, 0.0, n=20), (1, 0, 0), (0.725, 1.55, DECK + 0.305))]
    p.append(kit.part("lenses", (0.02, 0.02, 0.03), *glass))
    for name, rgb, m in U.frgf(kit, (0.20, -0.28, DECK + 0.005), (0, 0, 1), (1, 0, 0)):
        p.append(kit.part(name, rgb, m))
    # ------------------------------------------------------------- keel
    zb = _z(-1.18)                       # the struts meet the longeron's underside
    apex = np.array([-0.12, 0.0, _z(-2.64)])
    zbar = _z(-1.75)
    st = [kit.rod((-0.12, -1.12, zb), apex, 0.045, n=8), kit.rod((-0.12, 1.24, zb), apex, 0.045, n=8),
          kit.rod((-0.12, -0.72, zbar), (-0.12, 0.74, zbar), 0.035, n=8),
          kit.rod((-0.12, 0.0, _z(-1.27)), (-0.12, 0.0, zbar), 0.035, n=8),
          # the struts from the apex back up to the body, fore and aft
          kit.rod(apex, (X_CORE - 0.05, -0.55, _z(-0.94)), 0.035, n=8),
          kit.rod(apex, (X_CORE - 0.05, 0.55, _z(-0.94)), 0.035, n=8),
          kit.rod(apex, (X_BACK + 0.05, -0.55, _z(-0.94)), 0.035, n=8),
          kit.rod(apex, (X_BACK + 0.05, 0.55, _z(-0.94)), 0.035, n=8)]
    p.append(kit.part("keel struts (white)", PAINT, *st))
    # the panel fills the V below the cross bar
    t = (zbar - 0.04 - apex[2]) / (zb - apex[2])
    yl, yr = -1.12 * t + 0.05, 1.24 * t - 0.05
    p.extend(_keel_panel(kit, -0.12, [(yr, zbar - 0.04), (yl, zbar - 0.04), (0.0, apex[2] + 0.10)]))
    p.append(kit.part("keel ball", BROWN, kit.sphere(0.11, n=10, centre=apex + (0.0, 0.0, 0.02)), smooth=True))
    p.append(kit.part("keel pin", STEEL, kit.along(kit.cylinder(0.04, 0.0, 0.30, n=12), (0, 0, -1),
                                                   apex - (0.0, 0.0, 0.02))))
    return dict(meta=dict(name="SPAS-01 (Shuttle Pallet Satellite, STS-7)",
                          frame="SPAS-01: +X along the payload bay toward the orbiter's nose when "
                                "berthed (the face with the cylinders and the lettered keel panel), "
                                "+Y across it to port (between the longeron trunnions), +Z up out of "
                                "the bay (the top deck); m; ~0.7 m below the top deck (the blanketed "
                                "body holds nearly all the mass)",
                          source="simple shapes measured off STS-7 photographs (S07-25-1421, "
                                 "S07-11-528, S83-35782, S07-18-774) and STS-41B's (41B-32-1224, "
                                 "41B-40-2210); press kits' 1.5 m depth",
                          norad=14142, mag_1000km=3.0),
                parts=U.refine_parts(p))
