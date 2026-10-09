"""The Spartan 201 free-flyer (the NASA/GSFC Spartan carrier with the
Ultraviolet Coronal Spectrometer and the White Light Coronagraph), from NASA
3D Resources' "Spartan 201" -- in metres already (its carrier ~1.0 x 1.2 x
1.2 m, the two telescope tubes through it 3.3 m end to end, the WLC 2.63 m
long; the grapple fixture's base 0.3 m).  Flown five times: STS-56 (1993),
STS-64 (1994), STS-69 (1995), STS-87 (1997; it failed to start and tumbled
slowly, and was caught by hand on EVA), STS-95 (1998).

Below it, bus_parts(): a procedural service module from the STS-63/72
photographs, used by spartan101, spartan204 and oast_flyer (spartan201*
and spartan207 keep the file's carrier)."""
import numpy as np

from . import _leo_util as U

# the file: x along the telescopes, y toward the grapple fixture (+0.6..0.8),
# z across.  Here the same axes; the origin the carrier box's centre.
ORIGIN = (0.0, -0.1, 0.0)

RECOLOUR = {
    "SPmaincylinder": (0.70, 0.55, 0.28),          # the gold blankets
    "SPmainSphere": (0.70, 0.55, 0.28),
    "SPmainXaxis": (0.70, 0.55, 0.28),
    "SPmainYaxis": (0.70, 0.55, 0.28),
    "SPmainZaxis": (0.70, 0.55, 0.28),
    "SPsidepanelGridbaks": (0.70, 0.55, 0.28),
    "SPmaincylinderBevelend": (0.70, 0.55, 0.28),
    "SPmainZaxisWhite": (0.80, 0.80, 0.78),
    "SPmainVGSWhite": (0.80, 0.80, 0.78),
    "SPmainVGSWhiteSmooth": (0.80, 0.80, 0.78),
    "SPsidepanels": (0.78, 0.78, 0.76),            # white-painted side panels
    "SPsideplates": (0.70, 0.70, 0.70),
    "SPsidepanelGrids": (0.30, 0.30, 0.31),        # the louvred radiator
    "SPBrassFlat": (0.55, 0.42, 0.18),
    "SPSteelFlat": (0.45, 0.45, 0.46),
    "SPSteelSmooth": (0.45, 0.45, 0.46),
    "SPSteelCylinder": (0.40, 0.40, 0.41),
    "SPthermal Panel": (0.20, 0.20, 0.21),
    "SPthermalBrkts": (0.50, 0.50, 0.50),
    "SPthrustrCone": (0.50, 0.50, 0.50),
    "SPthrustr": (0.50, 0.50, 0.50),
    "SPmainVGSBlack": (0.05, 0.05, 0.05),
    "HST-DockingPointGold": (0.60, 0.48, 0.22),
    "HST-DockingPointBlack": (0.04, 0.04, 0.04),
    "HST-DockingPointWhite": (0.80, 0.80, 0.80),
    "HST-DockingPoint": (0.55, 0.55, 0.56),
}


def parts(kit):
    out = []
    for p in kit.nasa_glb("Spartan 201/Spartan 201.glb", np.eye(3), ORIGIN):
        if p['name'] == "Default":                  # degenerate, all at the origin
            continue
        if p['name'] in RECOLOUR:
            p['color'] = list(RECOLOUR[p['name']]) + [1.0]
        p['metallic'] = 0.0
        out.append(p)
    return out


def module(kit, flight, mission, norad, note=""):
    return dict(meta=dict(name="Spartan 201-%02d (%s)%s" % (flight, mission, note),
                          frame="Spartan 201: +X along the telescopes, +Y toward the grapple "
                                "fixture's face, +Z across; m; the carrier box's centre",
                          source="NASA 3D Resources, Spartan 201 (recoloured)",
                          norad=norad, mag_1000km=3.5),
                parts=parts(kit))


def carrier_parts(kit, keep_x=0.56):
    """The Spartan carrier alone: the Spartan 201 file with its telescope
    tubes cut away where they stand out of the carrier box (every triangle
    whose centre is beyond |x| = keep_x), for the other Spartan missions'
    fits (204, 206, 207 ...).  The box spans x -0.5..0.5."""
    out = []
    for p in parts(kit):
        pos, idx = np.asarray(p['pos'], float), np.asarray(p['idx']).reshape(-1, 3)
        c = pos[idx].mean(axis=1)
        far = np.abs(pos[idx][:, :, 0]).max(axis=1)
        keep = (np.abs(c[:, 0]) <= keep_x) & (far <= keep_x + 0.15)
        if not keep.any():
            continue
        q = dict(p)
        q['idx'] = idx[keep]
        out.append(q)
    return out


COPPER = (0.58, 0.34, 0.14)
_BLANKETS = ("SPmaincylinder", "SPmainSphere", "SPmainXaxis", "SPmainYaxis", "SPmainZaxis",
             "SPsidepanelGridbaks", "SPmaincylinderBevelend", "SPsidepanels")


def copper_carrier(kit):
    """The carrier alone (carrier_parts), its blankets the copper-gold the
    later Spartans (204, 206, 207) wore."""
    out = []
    for q in carrier_parts(kit):
        if q['name'] in _BLANKETS:
            q['color'] = list(COPPER) + [1.0]
        out.append(q)
    return out


def flyer_meta(kit, name, norad, extra_frame="", mag=3.5, source_extra=""):
    return dict(name=name,
                frame="Spartan: +X out of the instrument section's end, +Y toward the grapple "
                      "fixture's face, +Z across; m; the carrier box's centre" + extra_frame,
                source="NASA 3D Resources' Spartan 201 carrier (tubes cut away)" + source_extra,
                norad=norad, mag_1000km=mag)


# ---------------------------------------------------------------------------
# A procedural Spartan service module, drawn from the free-flight photographs
# of the later Spartans (STS063-716-055/060/066/072, STS072-726-051/054)
# rather than the 201 file, for the modules whose instruments sat on the
# carrier's end instead of running through it (101, 204, 206).  The same box
# as the file's carrier (X -0.51..0.51, Y -0.62..0.62, Z -0.55..0.55: the
# 42 x 48 in section of the STS-51G press kit) in the same frame: +Y the
# grapple fixture's face, +X the instrument end.  What the photographs agree
# on: the grapple fixture on a round white plate at the middle of +Y; on +Z
# the louvred radiator -- four bays stacked along X, each a frame of vanes
# running along X -- over the -Y half (y -0.60..0.02), the +Y half left for
# the logo plate (204) or experiments (206); the cold-gas thrusters as four
# clusters of three nozzles at the corners of the -Y face (STS063-716-066,
# STS072-726-054: on the edge opposite the grapple fixture).
BX, BY, BZ = 0.51, 0.62, 0.55
KAPTON = (0.68, 0.37, 0.12)        # the later Spartans' copper-gold Kapton, as spartan207 has it
_PTEX = {}


def tex_vanes(w=512, h=512, bays=4, vanes=26):
    """The radiator: `bays` bays stacked along v (X), each of `vanes`
    bright vanes along v side by side across u (Y), dark gaps, copper-gold
    frames between the bays.  Colour in the texture (white part colour)."""
    key = ('vanes', w, h, bays, vanes)
    if key in _PTEX:
        return _PTEX[key]
    from PIL import Image
    yy, xx = np.mgrid[0:h, 0:w]
    rng = np.random.default_rng(204)
    shade = rng.uniform(0.70, 0.95, vanes + 1)
    img = np.ones((h, w, 3)) * np.array([0.05, 0.05, 0.06])
    pitch = (w - 16) / vanes
    k = ((xx - 8) // pitch).astype(int).clip(0, vanes)
    vane = ((xx - 8) % pitch) < pitch * 0.72
    img[vane] = shade[k[vane]][:, None] * np.array([0.92, 0.94, 1.0])[None, :]
    bay_h = (h - 16) / bays
    frame = ((yy - 8) % bay_h < 10) | (yy > h - 9) | (xx < 8) | (xx > w - 9)
    img[frame] = (0.62, 0.42, 0.16)
    im = Image.fromarray((np.clip(img, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8))
    _PTEX[key] = im
    return im


def tex_logo(w=512, h=256):
    """The 'Spartan / Goddard Space Flight Center' plate: white, a dark-blue
    rounded frame, the word in dark blue with the red star burst."""
    key = ('logo', w, h)
    if key in _PTEX:
        return _PTEX[key]
    from PIL import Image, ImageDraw, ImageFont
    im = Image.new("RGB", (w, h), (232, 232, 228))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((14, 14, w - 15, h - 15), radius=26, outline=(30, 40, 110), width=7)
    try:
        d.text((w * 0.50, h * 0.44), "Spartan", font=ImageFont.load_default(size=int(h * 0.42)),
               fill=(30, 40, 110), anchor="mm")
        d.text((w * 0.50, h * 0.78), "Goddard Space Flight Center",
               font=ImageFont.load_default(size=int(h * 0.09)), fill=(40, 40, 60), anchor="mm")
    except Exception:
        d.text((w / 3, h / 3), "Spartan", fill=(30, 40, 110))
    d.ellipse((w * 0.62, h * 0.12, w * 0.70, h * 0.28), fill=(220, 60, 30))
    _PTEX[key] = im
    return im


def tex_patch(w=128, h=128, seed=0):
    """A round mission sticker: coloured rings round a blue-and-white
    centre (no design legible at proximity range)."""
    key = ('patch', w, h, seed)
    if key in _PTEX:
        return _PTEX[key]
    from PIL import Image, ImageDraw
    im = Image.new("RGB", (w, h), (230, 230, 226))
    d = ImageDraw.Draw(im)
    d.ellipse((6, 6, w - 7, h - 7), fill=(200, 70, 30))
    d.ellipse((16, 16, w - 17, h - 17), fill=(225, 175, 50))
    d.ellipse((24, 24, w - 25, h - 25), fill=(40, 70, 150))
    d.ellipse((44, 34, w - 44, h - 30), fill=(215, 220, 225))
    _PTEX[key] = im
    return im


def quad(kit, name, rgb, image, centre, normal, right, su, sv, thick=0.008):
    """A thin textured plate centred at `centre`, facing `normal`, the
    image's u along `right` (su m) and its v down the plate (sv m)."""
    n, r = np.asarray(normal, float), np.asarray(right, float)
    up = np.cross(n, r)
    m = U.unshare(U.refine(U.place(kit, kit.box((thick, su, sv)), np.column_stack([n, r, up]), centre), 0.4))
    q = np.asarray(m[0]) - np.asarray(centre, float)
    uv = np.column_stack([q @ r / su + 0.5, 0.5 - q @ up / sv]).astype(np.float32)
    return kit.part(name, rgb, m, texture=image, uv=uv)


def _thruster(kit, corner, outs):
    """A cold-gas thruster cluster at `corner`: a block on a short strut,
    three nozzles out along the unit vectors `outs`."""
    c = np.asarray(corner, float)
    m = [kit.box((0.09, 0.09, 0.09), c)]
    for o in outs:
        o = np.asarray(o, float)
        m.append(kit.rod(c + 0.04 * o, c + 0.26 * o, 0.014, n=8))
        m.append(kit.rod(c + 0.20 * o, c + 0.27 * o, 0.024, n=8))
    return m


def bus_parts(kit, blanket=KAPTON, tex_seed=151, x1=BX, plus_x_face=True, radiator=True,
              logo=None, thrusters=True, grapple=True, grapple_z=0.0, thruster_x=None):
    """The service module: a blanketed box from x -BX to x1, the radiators
    on +Z and -Z (-Y halves), the grapple fixture on its white plate at
    (0, +Y, grapple_z), thrusters at the -Y corners (x = -BX and x1, or
    thruster_x).
    logo: None, or (centre, normal, right, su, sv) for the plate.
    Returns parts."""
    p = []
    body = kit.box((x1 + BX, 2 * BY, 2 * BZ), ((x1 - BX) / 2, 0, 0))
    if not plus_x_face:                       # drop the +X end's two triangles (another part covers it)
        pts, tri = body
        c = pts[tri].mean(axis=1)
        tri = tri[c[:, 0] < x1 - 1e-6]
        body = (pts, tri)
    p.append(U.tpart(kit, "service module (Kapton blankets)", blanket, body,
                     U.tex_mli(tex_seed, seams=2, depth=0.55), tile=0.7, fine=0.35))
    if radiator:
        for s in (1, -1):
            # the radiator's frame stands 3 cm proud; the vanes on it
            y0, y1 = -BY + 0.02, 0.02
            p.append(quad(kit, "louvred radiator", (0.95, 0.95, 0.95), tex_vanes(),
                          (0.0, (y0 + y1) / 2, s * (BZ + 0.021)), (0, 0, s), (0, s, 0) if s > 0 else (0, -1, 0),
                          y1 - y0, 2 * BX - 0.04, thick=0.032))
    if grapple:
        gp = np.array([0.0, BY + 0.005, grapple_z])
        p.append(kit.part("grapple plate (white)", (0.82, 0.82, 0.80),
                          kit.along(kit.cylinder(0.17, 0.0, 0.012, n=32), (0, 1, 0), gp)))
        for name, rgb, m in U.frgf(kit, gp + (0, 0.012, 0), (0, 1, 0), (1, 0, 0)):
            p.append(kit.part(name, rgb, m))
    if logo is not None:
        p.append(quad(kit, "Spartan logo plate", (0.95, 0.95, 0.95), tex_logo(), *logo))
    if thrusters:
        th = []
        for x in (thruster_x or (-BX, x1)):
            for z in (-BZ, BZ):
                c = np.array([x + (0.05 if x < 0 else -0.05), -BY - 0.06, z + (0.05 if z < 0 else -0.05)])
                th += _thruster(kit, c, ((0, -1, 0), (0, 0, np.sign(z)), (np.sign(x), 0, 0)))
        p.append(kit.part("cold-gas thrusters", (0.72, 0.72, 0.74), *th))
    return p


def bus_meta(name, norad, source, extra_frame="", mag=3.5):
    return dict(name=name,
                frame="Spartan: +X out of the instrument end, +Y toward the grapple fixture's face, "
                      "+Z the louvred radiator's face beside it; m; the service module's centre" + extra_frame,
                source=source, norad=norad, mag_1000km=mag)
