"""The Hubble Space Telescope, built to its published dimensions with
procedural textures (see hst.py for the sources).  build(kit, era) gives
the parts for era '2009' (after Servicing Mission 4: rigid SA3 arrays, the
NOBL covers, the Soft Capture Mechanism) or '1990' (as deployed by STS-31:
the flexible SA1 arrays, new blankets).

Body frame: X = V1 (toward the aperture), Y = V2 (along the solar-array
masts), Z = V3 (along the high-gain-antenna masts; the aperture door's
hinge is on +V3), metres, origin at the estimated centre of mass.  Inside,
positions are given as station s (m forward of the aft bulkhead), azimuth
phi (deg from +V2 toward +V3) and radius.
"""
import math

import numpy as np

from . import _hst_geom as G
from . import _hst_tex as T

# ----------------------------------------------------------------- layout
# Stations (m from the aft bulkhead) and radii, from the HST Media
# Reference Guides: aft shroud 3.5 m long, 4.3 m across; Equipment Section
# 1.5 m, the same outside; forward shell and light shield ~4 m each, 3.1 m
# across; 13.2 m overall with the door.  The split between the forward
# shell and the light shield, and the narrow ring of OTA electronics bays
# between the Equipment Section and the forward shell, follow the
# Lockheed-drawing-derived NASA model "Hubble Space Telescope (B)".
S_AFT_TOP = 3.50          # aft shroud / Equipment Section interface
S_ES_TOP = 5.00           # Equipment Section / OTA-bay ring
S_FS = 5.90               # forward shell begins (narrow from here)
S_LS = 8.95               # light shield begins
S_AP = 12.95              # the aperture (light shield's forward edge)
R_AFT = 2.13              # aft shroud
R_ES = 2.10               # Equipment Section, to its flat bay doors (12-sided)
R_OTA = 1.96              # the ring of OTA bays
R_FS = 1.56               # forward shell and light shield (outside the blankets)
R_IN = 1.50               # inside the light shield
R_DOOR = 1.62

# Centre of mass: no published station; estimated from a mass budget of
# the major items (aft shroud and its four axial instruments ~2.4 t at
# s ~1.8; radial instruments and FGSs ~1.1 t at 3.2; Equipment Section
# with batteries and wheels ~2.5 t at 4.25; the OTA ~2.4 t at 5.5; forward
# shell 1 t at 7; light shield 0.6 t at 11; arrays 0.6 t at 5.25): s ~4.65,
# on the axis -- near the Equipment Section's forward face, where the
# arrays' masts are (they turn about it).
S_CM = 4.65

S_MAST = 5.25             # the solar arrays' masts (V2)
S_HGA = 6.15              # the high-gain antennas' mast hinges (V3)

SILVER = (0.55, 0.55, 0.56)
WHITE = (0.78, 0.78, 0.76)
BLACK = (0.025, 0.025, 0.03)
GOLD = (0.72, 0.50, 0.16)
BROWN = (0.40, 0.24, 0.08)


def _rot_about(points, axis, deg, pivot):
    R = _rmat(axis, deg)
    return (np.asarray(points, float) - pivot) @ R.T + pivot


def _rmat(axis, deg):
    a = np.asarray(axis, float)
    a = a / np.linalg.norm(a)
    t = math.radians(deg)
    c, s = math.cos(t), math.sin(t)
    x, y, z = a
    return np.array([[c + x * x * (1 - c), x * y * (1 - c) - z * s, x * z * (1 - c) + y * s],
                     [y * x * (1 - c) + z * s, c + y * y * (1 - c), y * z * (1 - c) - x * s],
                     [z * x * (1 - c) - y * s, z * y * (1 - c) + x * s, c + z * z * (1 - c)]])


def _turned(m, R, pivot):
    q = dict(m)
    q['pos'] = (m['pos'] - pivot) @ R.T + pivot
    if m['nrm'] is not None:
        q['nrm'] = m['nrm'] @ R.T
    return q


class Builder(object):
    def __init__(self, kit, era):
        self.kit = kit
        self.era = era
        self.F = G.Frame(S_CM)
        self.parts = []
        self.flat = {}                    # material -> [meshes], flat-shaded, untextured

    # -- helpers
    def P(self, s, phi, r):
        return self.F.p(s, phi, r)

    def add_flat(self, name, rgb, *kit_meshes):
        self.flat.setdefault((name, tuple(rgb)), []).extend(G.from_kit(m) for m in kit_meshes)

    def add_mesh(self, name, rgb, *meshes):
        self.flat.setdefault((name, tuple(rgb)), []).extend(meshes)

    def textured(self, name, meshes, image, rgb=(1.0, 1.0, 1.0)):
        self.parts.append(G.part(name, rgb, meshes, texture=image))

    def radial_box(self, s, phi, r0, r1, w_s, w_t):
        """A box standing on the body: from radius r0 to r1 at (s, phi), w_s
        long along V1 and w_t wide round the body."""
        k = self.kit
        b = k.box((w_s, r1 - r0, w_t), (0.0, 0.5 * (r0 + r1), 0.0))
        return k.turn(k.move(b, (self.F.x(s), 0, 0)), k.rot('x', phi))

    def rod(self, p0, p1, r, n=6):
        return self.kit.rod(p0, p1, r, n)

    def handrail_line(self, pts, standoff_pts, r=0.016):
        """A handrail through pts (body points on its line) with a post
        down to the body at each of standoff_pts [(rail point, body point)]."""
        out = []
        for a, b in zip(pts[:-1], pts[1:]):
            out.append(self.rod(a, b, r))
        for a, b in standoff_pts:
            out.append(self.rod(a, b, r * 0.8))
        return out

    def rail_long(self, phi, s0, s1, r_body, h=0.075):
        """A handrail along V1 at azimuth phi from s0 to s1."""
        r = r_body + h
        a, b = self.P(s0, phi, r), self.P(s1, phi, r)
        n = max(2, int(abs(s1 - s0) / 0.6) + 1)
        posts = [(self.P(s, phi, r), self.P(s, phi, r_body)) for s in np.linspace(s0, s1, n)]
        return self.handrail_line([a, b], posts)

    def rail_arc(self, s, phi0, phi1, r_body, h=0.075, seg_deg=6.0):
        r = r_body + h
        n = max(2, int(abs(phi1 - phi0) / seg_deg) + 1)
        ph = np.linspace(phi0, phi1, n)
        pts = [self.P(s, f, r) for f in ph]
        npost = max(2, int(abs(phi1 - phi0) / 30.0) + 1)
        posts = [(self.P(s, f, r), self.P(s, f, r_body)) for f in np.linspace(phi0, phi1, npost)]
        return self.handrail_line(pts, posts)

    def ring(self, s, r0, r1, w, rgb=SILVER, name="rings"):
        """An external reinforcing ring: band of outer radius r1 on a body
        of radius r0, w wide along V1."""
        F = self.F
        self.add_mesh(name, rgb,
                      G.cyl(F, r1, s - w / 2, s + w / 2, n=96),
                      G.disc_planar(F, r1, s + w / 2, n=96, r_in=r0),
                      G.disc_planar(F, r1, s - w / 2, n=96, r_in=r0))

    # ------------------------------------------------------------ the body
    def light_shield_and_forward_shell(self):
        F = self.F
        L = S_AP - S_FS
        C = 2 * math.pi * R_FS
        cv = T.Canvas(C, L, 210)
        T.mli(cv, 101, crinkle=1.0 if self.era == '2009' else 0.3, patch=(0.95, 0.75))
        # the 'worm' and ESA's roundel on the light shield's -V3 side (as on
        # orbit 1990-2009; photographs at release on STS-31, -61 and -125)
        y = lambda s: S_AP - s
        xph = lambda phi: (phi % 360.0) / 360.0 * C
        T.nasa_worm(cv, xph(263.0), y(11.85), 0.40)
        T.esa_logo(cv, xph(289.0), y(11.80), 0.14)
        # the forward shell's blanket a shade different from the light shield's
        i = int((S_AP - S_LS) * cv.ppm)
        cv.a[i:] *= 0.95
        side = G.cyl(F, R_FS, S_FS, S_AP, n=128, nseg=4)
        self.textured("light shield and forward shell", [side], cv.image())
        # rings: forward shell's reinforcing rings, the shell/shield joint,
        # the SA/HGA latch support ring, the aperture's lip
        for s in (6.55, 7.35, 8.15):
            self.ring(s, R_FS, R_FS + 0.035, 0.05)
        self.ring(S_LS, R_FS, R_FS + 0.05, 0.08)
        self.ring(11.15, R_FS, R_FS + 0.04, 0.06)
        # the aperture: the lip, the black inside and the baffles
        self.add_mesh("aperture lip", (0.50, 0.50, 0.50),
                      G.disc_planar(F, R_FS + 0.005, S_AP, n=128, r_in=R_IN))
        inside = [G.cyl(F, R_IN, S_LS, S_AP, n=96, inward=True),
                  G.disc_planar(F, R_IN, S_LS, n=96)]
        for s in np.linspace(S_LS + 0.4, S_AP - 0.3, 6):     # light baffles
            inside.append(G.disc_planar(F, R_IN, s, n=96, r_in=R_IN - 0.18))
        self.add_mesh("light shield inside (flat black)", BLACK, *inside)

    def ota_bay_ring(self):
        F = self.F
        C = 2 * math.pi * R_OTA
        L = S_FS - S_ES_TOP
        cv = T.Canvas(C, L, 180)
        T.mli(cv, 202, crinkle=1.0 if self.era == '2009' else 0.35, patch=(0.8, 0.5))
        side = G.cyl(F, R_OTA, S_ES_TOP, S_FS, n=96)
        self.textured("OTA equipment-bay ring", [side], cv.image())
        # its forward face, out from the forward shell
        self.add_mesh("bulkhead faces", (0.34, 0.34, 0.35),
                      G.disc_planar(F, R_OTA, S_FS, n=96, r_in=R_FS - 0.01))

    def equipment_section(self):
        F, k = self.F, self.kit
        n = 12
        phase = 15.0
        wf = 2 * R_ES * math.tan(math.pi / n)
        L = S_ES_TOP - S_AFT_TOP
        cv = T.Canvas(n * wf, L, 150)
        # every facet: aluminised-blanket-faced door in its frame
        T.mli(cv, 303, crinkle=0.55 if self.era == '2009' else 0.25, patch=(0.6, 0.5))
        trunnion = (15.0, 195.0)
        louvred = (255.0, 285.0, 45.0)
        if self.era == '2009':
            nobl = (75.0, 105.0, 135.0, 165.0, 225.0, 315.0, 345.0)
        else:
            nobl = ()
        for j in range(n):
            phi = (phase + 360.0 * j / n) % 360.0
            x0, x1 = j * wf, (j + 1) * wf
            # frame round the door
            cv.rect(x0, 0, x1, 0.06, (0.62, 0.62, 0.62))
            cv.rect(x0, L - 0.06, x1, L, (0.62, 0.62, 0.62))
            cv.rect(x0, 0, x0 + 0.04, L, (0.50, 0.50, 0.50))
            cv.rect(x1 - 0.04, 0, x1, L, (0.50, 0.50, 0.50))
            if any(abs(phi - t) < 1 for t in trunnion):
                cv.rect(x0 + 0.04, 0.06, x1 - 0.04, L - 0.06, (0.60, 0.60, 0.61))
                continue
            if any(abs(phi - t) < 1 for t in louvred):
                T.louvres(cv, x0 + 0.12, 0.18, x1 - 0.12, 0.72)
            elif any(abs(phi - t) < 1 for t in nobl):
                T.nobl(cv, x0 + 0.06, 0.08, x1 - 0.06, L - 0.08, 400 + j)
            # door latches / handhold pads
            for xx in (x0 + 0.15, x1 - 0.15):
                cv.rect(xx - 0.03, L - 0.22, xx + 0.03, L - 0.12, (0.25, 0.25, 0.25))
        side = G.ngon_prism(F, R_ES, n, S_AFT_TOP, S_ES_TOP, phase=phase)
        self.textured("Equipment Section", [side], cv.image())
        # forward face of the ring of bays, and the interface rings
        Rc = R_ES / math.cos(math.pi / n)
        self.add_mesh("bulkhead faces", (0.34, 0.34, 0.35),
                      G.disc_planar(F, Rc, S_ES_TOP, n=n, r_in=R_OTA - 0.01))
        self.ring(S_AFT_TOP, R_AFT, R_AFT + 0.07, 0.06, SILVER, "rings")
        self.ring(S_ES_TOP - 0.03, Rc - 0.02, Rc + 0.03, 0.05, SILVER, "rings")
        # the aft trunnions (at the trunnion bays) and the keel trunnion (+V3)
        for phi in trunnion:
            self.add_flat("trunnions", (0.70, 0.70, 0.70),
                          self.radial_box(4.25, phi, R_ES - 0.02, R_ES + 0.12, 0.40, 0.40),
                          k.along(k.cylinder(0.085, 0.0, 0.42, 16), self.P(0, phi, 1) - self.P(0, phi, 0),
                                  self.P(4.25, phi, R_ES + 0.12)))
        self.add_flat("trunnions", (0.70, 0.70, 0.70),
                      k.along(k.cylinder(0.07, 0.0, 0.40, 16), (0, 0, 1), self.P(3.70, 90.0, R_AFT)),
                      self.radial_box(3.70, 90.0, R_AFT - 0.02, R_AFT + 0.08, 0.35, 0.35))

    def aft_shroud(self):
        F = self.F
        C = 2 * math.pi * R_AFT
        L = S_AFT_TOP
        cv = T.Canvas(C, L, 150)
        base = (0.30, 0.33, 0.40) if self.era == '2009' else (0.36, 0.38, 0.44)
        T.panels(cv, 404, base, grid=(C / 24, L / 6), line=0.010)
        xph = lambda phi: (phi % 360.0) / 360.0 * C
        y = lambda s: S_AFT_TOP - s
        # the four axial science-instrument doors (each ~1 x 2.3 m), at
        # +-35 deg either side of +-V2 (the model (B)'s door positions)
        for phi in (35.0, 145.0, 215.0, 325.0):
            x0, x1 = xph(phi) - 0.52, xph(phi) + 0.52
            for xx in (x0, x1):
                cv.vline(xx, y(2.65), y(0.40), 0.03, (0.12, 0.13, 0.16))
            for yy in (y(2.65), y(0.40)):
                cv.hline(yy, x0, x1, 0.03, (0.12, 0.13, 0.16))
        # the white radiator panel down the +V2 side of the -V3 face
        cv.rect(xph(318.0), y(3.42), xph(338.0), y(0.18), (0.72, 0.72, 0.70))
        cv.vline(xph(328.0), y(3.42), y(0.18), 0.01, (0.50, 0.50, 0.50))
        # the radial bay (WF/PC, WFC3 from 2009) at the top of the -V3 face:
        # its white radiator band and door
        cv.rect(xph(222.0), y(3.47), xph(316.0), y(3.02), (0.74, 0.74, 0.72))
        cv.rect(xph(255.0), y(3.42), xph(285.0), y(3.07), (0.62, 0.62, 0.62))
        cv.rect(xph(257.0), y(3.38), xph(283.0), y(3.11), (0.74, 0.74, 0.72))
        # the Fixed Head Star Trackers' light shades: two large ovals and a
        # round port, black, in silver collars
        for phi in (246.0, 294.0):
            cv.fill(cv.mask_ellipse(xph(phi), y(2.00), 0.43, 0.66), (0.60, 0.60, 0.62))
            cv.fill(cv.mask_ellipse(xph(phi), y(2.00), 0.37, 0.60), (0.02, 0.02, 0.025))
        cv.fill(cv.mask_ellipse(xph(270.0), y(2.82), 0.21, 0.21), (0.60, 0.60, 0.62))
        cv.fill(cv.mask_ellipse(xph(270.0), y(2.82), 0.16, 0.16), (0.02, 0.02, 0.025))
        # the bottom band (bulkhead ring)
        cv.rect(0, y(0.07), C, y(0.0), (0.58, 0.58, 0.58))
        side = G.cyl(F, R_AFT, 0.0, S_AFT_TOP, n=128, nseg=2)
        self.textured("aft shroud", [side], cv.image())

    def aft_bulkhead(self):
        F, k = self.F, self.kit
        cv = T.bulkhead(R_AFT)
        disc = G.disc_planar(F, R_AFT, 0.0, n=128)
        self.textured("aft bulkhead", [disc], cv.image())
        # the rear low-gain antenna (gold cone) near the rim
        phi = 140.0
        base = self.P(-0.02, phi, 1.90)
        self.add_flat("low-gain antennas", GOLD,
                      k.along(k.frustum(0.12, 0.03, 0.0, 0.32, 16), (-1, 0, 0), base),
                      k.along(k.cylinder(0.15, 0.0, 0.02, 16), (-1, 0, 0), base))
        # the umbilical connector bracket and plate
        self.add_flat("aft bulkhead hardware", (0.45, 0.45, 0.46),
                      k.box((0.20, 0.30, 0.30), self.P(-0.10, 335.0, 1.70)),
                      k.box((0.12, 0.40, 0.18), self.P(-0.06, 30.0, 1.30)))
        # the three FSS berthing pins (and the SCM on them after 2009)
        pins = []
        for phi in (90.0, 210.0, 330.0):
            p = self.P(0.0, phi, 1.10)
            pins.append(k.along(k.cylinder(0.05, 0.0, 0.20, 12), (-1, 0, 0), p))
            pins.append(k.along(k.cylinder(0.12, 0.0, 0.04, 12), (-1, 0, 0), p))
        self.add_flat("berthing pins", (0.70, 0.70, 0.70), *pins)
        # the bulkhead handrail round its rim (yellow, as on STS-109's photographs)
        rail = []
        n = 36
        for i in range(n):
            a, b = 360.0 * i / n, 360.0 * (i + 1) / n
            rail.append(self.rod(self.P(-0.09, a, 2.04), self.P(-0.09, b, 2.04), 0.016))
            if i % 3 == 0:
                rail.append(self.rod(self.P(-0.09, a, 2.04), self.P(0.0, a, 2.04), 0.013))
        self.add_flat("handrails", T.YELLOW, *rail)

    def soft_capture_mechanism(self):
        """The SCM (2009): a LIDS-compatible docking ring held off the aft
        bulkhead on the three berthing pins, with three guide petals and
        relative-navigation targets.  Its size is approximate (~1.4 m ring,
        ~0.5 m deep)."""
        k = self.kit
        out = []
        r_ring = 0.75
        s_ring = -0.42
        for phi in (90.0, 210.0, 330.0):
            out.append(self.rod(self.P(-0.20, phi, 1.10), self.P(s_ring, phi, r_ring + 0.03), 0.05, 8))
            out.append(self.rod(self.P(-0.20, phi, 1.10), self.P(s_ring, phi + 25, r_ring), 0.035, 8))
            out.append(self.rod(self.P(-0.20, phi, 1.10), self.P(s_ring, phi - 25, r_ring), 0.035, 8))
        self.add_flat("SCM structure", (0.62, 0.62, 0.63), *out)
        ring = k.turn(k.tube(r_ring + 0.06, r_ring - 0.10, self.F.x(s_ring - 0.10), self.F.x(s_ring), 64),
                      np.eye(3))
        self.add_flat("SCM ring", (0.66, 0.66, 0.66), ring)
        petals = []
        for phi in (30.0, 150.0, 270.0):
            a = self.P(s_ring - 0.10, phi - 14, r_ring - 0.02)
            b = self.P(s_ring - 0.10, phi + 14, r_ring - 0.02)
            c = self.P(s_ring - 0.38, phi, r_ring - 0.20)
            d = c + np.array([0.0, 0.0, 0.0])
            m = G.mesh([a, b, c], [(0, 1, 2)])
            petals.append(m)
            # a second sheet 2 cm inside: the petal's thickness
            off = (self.P(0, phi, 1) - self.P(0, phi, 0)) * -0.02
            petals.append(G.mesh([a + off, b + off, d + off], [(0, 2, 1)]))
        self.add_mesh("SCM petals", (0.70, 0.70, 0.70), *petals)
        tg = []
        for phi in (0.0, 120.0, 240.0):
            tg.append(k.box((0.03, 0.14, 0.14), self.P(s_ring - 0.115, phi, r_ring - 0.02)))
        self.add_flat("SCM targets", (0.04, 0.04, 0.04), *tg)

    def aperture_door(self, open_deg=0.0):
        """Closed by default (as for rendezvous, capture and release); open
        up to 105 deg about its hinge on the +V3 side."""
        F, k = self.F, self.kit
        cv = T.Canvas(2 * R_DOOR, 2 * R_DOOR, 220, base=(0.55, 0.55, 0.55))
        T.mli(cv, 505, crinkle=0.35 if self.era == "2009" else 0.15, base=0.55, patch=(0.6, 0.6))
        mask = ~cv.mask_ellipse(R_DOOR, R_DOOR, R_DOOR * 0.999, R_DOOR * 0.999, wrap=False)
        cv.fill(mask, (0.6, 0.6, 0.6))
        s_out, s_in = S_AP + 0.11, S_AP + 0.04
        outer = G.disc_planar(F, R_DOOR, s_out, n=96)
        inner = G.disc_planar(F, R_DOOR, s_in, n=96)
        rim = G.cyl(F, R_DOOR, s_in, s_out, n=96)
        hinge = [k.box((0.18, 0.16, 0.14), (F.x(S_AP + 0.06), y, R_DOOR + 0.05)) for y in (-0.62, 0.72)]
        hinge.append(k.box((0.10, 1.60, 0.06), (F.x(S_AP + 0.07), 0.05, R_DOOR + 0.02)))
        support = [k.box((0.34, 0.10, 0.12), (F.x(S_AP - 0.10), y, R_DOOR + 0.03)) for y in (-0.62, 0.72)]
        pieces = dict(outer=outer, inner=inner, rim=rim)
        if open_deg:
            pivot = np.array([F.x(S_AP + 0.07), 0.0, R_DOOR + 0.05])
            R = _rmat((0, 1, 0), -open_deg)
            pieces = {kk: _turned(m, R, pivot) for kk, m in pieces.items()}
        self.textured("aperture door", [pieces['outer']], cv.image())
        self.add_mesh("aperture door inside (black)", BLACK, pieces['inner'])
        self.add_mesh("aperture door rim", (0.30, 0.27, 0.22), pieces["rim"])
        self.add_flat("door hinge", (0.60, 0.60, 0.60), *(hinge + support))

    # ------------------------------------------------------- appendages
    def solar_arrays_sa3(self, deg=0.0):
        """SA3 (2002-): two rigid wings, 7.1 m along V1 by 2.6 m, each on a
        mast along V2 to its middle; cells toward +V3 at deg = 0."""
        k, F = self.kit, self.F
        W, Lw = 2.6, 7.1
        rc = 4.45                           # the wing's centre line, from the axis
        front = T.sa3_front(W, Lw).image()
        back = T.sa3_back(W, Lw).image()
        fronts, backs = [], []
        frames, braces, masts = [], [], []
        for sgn in (1, -1):
            yi, yo = sgn * (rc - W / 2), sgn * (rc + W / 2)
            x0, x1 = F.x(S_MAST - Lw / 2), F.x(S_MAST + Lw / 2)
            zf, zb = 0.025, 0.0              # cells' plane, back's plane
            uv = ((0, 1), (1, 1), (1, 0), (0, 0))
            f = G.quad((x0, yi, zf), (x0, yo, zf), (x1, yo, zf), (x1, yi, zf), uv)
            b = G.quad((x0, yi, zb), (x0, yo, zb), (x1, yo, zb), (x1, yi, zb), uv)
            fl, bl = [f], [b]
            # frames: the perimeter, the hinge lines between panels, the
            # centre line along the wing
            fr = []
            th = 0.05
            for xx in np.linspace(x0, x1, 5):
                fr.append(k.box((th, W + th, 0.06), (xx, sgn * rc, 0.012)))
            for yy in (yi, yo):
                fr.append(k.box((Lw + th, th, 0.06), (0.5 * (x0 + x1), yy, 0.012)))
            fr.append(k.box((Lw, 0.03, 0.05), (0.5 * (x0 + x1), sgn * rc, -0.015)))
            # the back's diagonal braces: an X over the panel each side of the mast
            br = []
            zbr = -0.05
            xm = F.x(S_MAST)
            for xa, xb in ((xm, xm + Lw / 4), (xm, xm - Lw / 4)):
                br.append(self.rod((xa, yi, zbr), (xb, yo, zbr), 0.022))
                br.append(self.rod((xa, yo, zbr), (xb, yi, zbr), 0.022))
            # the mast: from the drive on the body to the wing's far edge
            ms = [k.box((0.13, rc + W / 2 - (R_OTA - 0.05), 0.13),
                        (xm, sgn * 0.5 * (rc + W / 2 + R_OTA - 0.05), -0.09))]
            ms.append(k.box((0.45, 0.40, 0.40), (xm, sgn * (R_OTA + 0.18), -0.04)))   # drive
            ms.append(k.box((0.35, 0.20, 0.25), (xm, sgn * (R_OTA + 0.65), -0.09)))   # hinge
            ms.append(k.box((0.30, 0.40, 0.18), (xm - 0.35, sgn * (R_OTA + 0.40), 0.10)))  # diode box
            if deg:
                R = _rmat((0, 1, 0), deg)
                piv = np.array([xm, 0.0, 0.0])
                fl = [_turned(m, R, piv) for m in fl]
                bl = [_turned(m, R, piv) for m in bl]
                fr = [k.turn(m, R, piv) for m in fr]
                br = [k.turn(m, R, piv) for m in br]
            fronts += fl
            backs += bl
            frames += fr
            braces += br
            masts += ms
        self.textured("SA3 cells", fronts, front)
        self.textured("SA3 backs", backs, back)
        self.add_flat("SA3 frames and masts", (0.60, 0.60, 0.62), *(frames + braces + masts))

    def solar_arrays_sa1(self, deg=0.0):
        """SA1 (1990-93): two flexible wings, each two blankets rolled out
        fore and aft from a drum on its mast, 12.1 m along V1 in all by
        3.3 m, tensioned by bi-stem booms; cells toward +V3 at deg = 0."""
        k, F = self.kit, self.F
        Lw, Wd = 12.1, 3.3
        Wb = 2.5                              # the blanket's width
        rc = 4.45
        front = T.sa1_blanket(Wb, Lw / 2, True).image()
        back = T.sa1_blanket(Wb, Lw / 2, False).image()
        fronts, backs, hw, booms = [], [], [], []
        xm = F.x(S_MAST)
        for sgn in (1, -1):
            yi, yo = sgn * (rc - Wb / 2), sgn * (rc + Wb / 2)
            fl, bl, hh, bb = [], [], [], []
            for d in (1, -1):
                xa, xb = xm + d * 0.20, xm + d * Lw / 2
                uv = ((0, 1), (1, 1), (1, 0), (0, 0))
                fl.append(G.quad((xa, yi, 0.012), (xa, yo, 0.012), (xb, yo, 0.012), (xb, yi, 0.012), uv))
                bl.append(G.quad((xa, yi, 0.0), (xa, yo, 0.0), (xb, yo, 0.0), (xb, yi, 0.0), uv))
                # spreader bar at the tip
                hh.append(k.box((0.08, Wd, 0.08), (xb, sgn * rc, -0.03)))
                # bi-stem booms along the blanket's edges, from the drum's ends
                for yy in (sgn * (rc - Wd / 2 + 0.05), sgn * (rc + Wd / 2 - 0.05)):
                    bb.append(self.rod((xm, yy, -0.04), (xb, yy, -0.04), 0.018, 6))
            # the drum (the blankets' storage rolls) and its housing
            hh.append(k.along(k.cylinder(0.14, 0.0, Wd, 16), (0, sgn, 0), (xm, sgn * (rc - Wd / 2), -0.02)))
            hh.append(k.box((0.30, 0.25, 0.30), (xm, sgn * (rc - Wd / 2 - 0.1), -0.02)))
            hh.append(k.box((0.30, 0.25, 0.30), (xm, sgn * (rc + Wd / 2 + 0.1), -0.02)))
            # the mast and drive
            ms = [k.box((0.11, rc - Wd / 2 - (R_OTA - 0.05), 0.11),
                        (xm, sgn * 0.5 * (rc - Wd / 2 + R_OTA - 0.05), -0.02)),
                  k.box((0.45, 0.40, 0.40), (xm, sgn * (R_OTA + 0.18), -0.02))]
            if deg:
                R = _rmat((0, 1, 0), deg)
                piv = np.array([xm, 0.0, 0.0])
                fl = [_turned(m, R, piv) for m in fl]
                bl = [_turned(m, R, piv) for m in bl]
                hh = [k.turn(m, R, piv) for m in hh]
                bb = [k.turn(m, R, piv) for m in bb]
            fronts += fl
            backs += bl
            hw += hh + ms
            booms += bb
        self.textured("SA1 cells", fronts, front)
        self.textured("SA1 blanket backs", backs, back)
        self.add_flat("SA1 drums and masts", (0.62, 0.62, 0.62), *hw)
        self.add_flat("SA1 bi-stem booms", (0.75, 0.70, 0.55), *booms)

    def high_gain_antennas(self):
        """Two HGAs on ~3.8 m masts along +-V3 from hinges on the forward
        shell; 1.3 m graphite dishes on two-axis gimbals, facing +V1."""
        k, F = self.kit, self.F
        booms, gimb, dfront, dback = [], [], [], []
        for phi in (90.0, 270.0):
            u = self.P(0, phi, 1) - self.P(0, phi, 0)
            base = self.P(S_HGA, phi, R_FS)
            tip = self.P(S_HGA, phi, 5.45)
            booms.append(k.along(k.box((5.45 - R_FS - 0.20, 0.10, 0.10),
                                       (0.5 * (5.45 - R_FS - 0.20), 0, 0)), u, base + 0.20 * u))
            gimb.append(k.box((0.30, 0.30, 0.22), base + 0.10 * u))            # hinge drive
            gimb.append(k.along(k.cylinder(0.09, 0.0, 0.22, 12), u, tip))     # gimbal
            gimb.append(k.box((0.25, 0.22, 0.22), tip + 0.30 * u))
            # the dish: a paraboloid, vertex just forward of the gimbal
            c = tip + 0.30 * u + np.array([0.20, 0.0, 0.0])
            Rd, depth = 0.66, 0.24
            nr, na = 6, 32
            pts, tri = [c.copy()], []
            for i in range(1, nr + 1):
                rr = Rd * i / nr
                for j in range(na):
                    a = 2 * math.pi * j / na
                    pts.append(c + np.array([depth * (rr / Rd) ** 2, rr * math.cos(a), rr * math.sin(a)]))
            for j in range(na):
                tri.append((0, 1 + j, 1 + (j + 1) % na))
            for i in range(nr - 1):
                for j in range(na):
                    a0 = 1 + i * na + j
                    a1 = 1 + i * na + (j + 1) % na
                    b0, b1 = a0 + na, a1 + na
                    tri += [(a0, b0, b1), (a0, b1, a1)]
            pts = np.array(pts)
            dfront.append(G.mesh(pts, tri))
            dback.append(G.mesh(pts - np.array([0.012, 0, 0]), [(a, c_, b) for a, b, c_ in tri]))
            # the feed: a small cone at the focus on three struts
            f = c + np.array([0.42, 0.0, 0.0])
            gimb.append(k.along(k.frustum(0.05, 0.08, 0.0, 0.10, 12), (1, 0, 0), f))
            for j in range(3):
                a = 2 * math.pi * j / 3 + 0.3
                rimp = c + np.array([depth, Rd * math.cos(a), Rd * math.sin(a)])
                gimb.append(self.rod(rimp, f, 0.008, 4))
        self.add_flat("HGA masts", WHITE, *booms)
        self.add_flat("HGA gimbals and feeds", GOLD, *gimb)
        self.add_mesh("HGA dishes (front)", (0.10, 0.10, 0.085), *dfront)
        self.add_mesh("HGA dishes (back)", (0.06, 0.06, 0.055), *dback)

    def light_shield_hardware(self):
        k, F = self.kit, self.F
        # scuff plates on struts by the SA latches (+-V2), ~30 in. out
        plates, struts = [], []
        for phi in (0.0, 180.0):
            u = self.P(0, phi, 1) - self.P(0, phi, 0)
            c = self.P(11.10, phi, R_FS + 0.76)
            t = self.P(0, phi + 90, 1) - self.P(0, phi + 90, 0)
            plates.append(k.box((0.80, 0.04, 0.60), c) if phi == 0 else k.box((0.80, 0.04, 0.60), c))
            for ds in (-0.35, 0.35):
                for dt in (-0.25, 0.25):
                    top = c + np.array([ds, 0, 0]) + dt * t
                    bot = self.P(11.10 + ds * 0.6, phi, R_FS) + dt * 0.7 * t
                    struts.append(self.rod(top, bot, 0.025, 6))
            # the SA and HGA latches, stowed-position fittings
            plates.append(self.radial_box(10.0, phi, R_FS - 0.01, R_FS + 0.12, 0.25, 0.30))
            plates.append(self.radial_box(7.6, phi, R_FS - 0.01, R_FS + 0.12, 0.25, 0.30))
        for phi in (90.0, 270.0):
            plates.append(self.radial_box(10.6, phi, R_FS - 0.01, R_FS + 0.14, 0.30, 0.30))
        self.add_flat("scuff plates and latches", (0.58, 0.58, 0.58), *plates)
        self.add_flat("scuff-plate struts", BROWN, *struts)
        # magnetometers (2) near the aperture on the +V3 side, under their
        # white covers (fitted on STS-61, 1993)
        mags = []
        for phi in (55.0, 125.0):
            mags.append(self.radial_box(12.55, phi, R_FS - 0.01, R_FS + 0.10, 0.12, 0.12))
            mags.append(self.radial_box(12.55, phi, R_FS + 0.10, R_FS + 0.30, 0.34, 0.26))
        self.add_flat("magnetometers", WHITE if self.era == '2009' else (0.58, 0.58, 0.58), *mags)
        # the forward low-gain antenna on +V2 and its waveguide along the body
        lga = self.P(12.55, 6.0, R_FS + 0.25)
        self.add_flat("low-gain antennas", GOLD,
                      k.along(k.frustum(0.12, 0.03, 0.0, 0.32, 16), (1, 0, 0), lga))
        wg = [self.rod(self.P(S_FS + 0.1, 8.0, R_FS + 0.05), self.P(12.5, 8.0, R_FS + 0.05), 0.03, 6),
              self.rod(self.P(12.5, 8.0, R_FS + 0.05), lga, 0.03, 6),
              self.radial_box(12.55, 6.0, R_FS - 0.01, R_FS + 0.22, 0.10, 0.10)]
        self.add_flat("waveguide", (0.52, 0.52, 0.54), *wg)

    def forward_shell_hardware(self):
        k, F = self.kit, self.F
        # four magnetic torquers, 90 deg apart, ~2.5 m bars on brackets
        mt = []
        for phi in (45.0, 135.0, 225.0, 315.0):
            u = self.P(0, phi, 1) - self.P(0, phi, 0)
            a = self.P(6.35, phi, R_FS + 0.20)
            mt.append(k.along(k.cylinder(0.06, 0.0, 2.45, 12), (1, 0, 0), a))
            for s in (6.55, 8.55):
                mt.append(self.radial_box(s, phi, R_FS - 0.01, R_FS + 0.20, 0.10, 0.16))
        self.add_flat("magnetic torquers", (0.66, 0.66, 0.66), *mt)
        # two grapple fixtures (where the RMS takes hold), -V3 side
        gf, gt = [], []
        for phi in (232.0, 308.0):
            u = self.P(0, phi, 1) - self.P(0, phi, 0)
            gf.append(self.radial_box(6.60, phi, R_FS - 0.02, R_FS + 0.05, 0.40, 0.40))
            gf.append(k.along(k.cylinder(0.04, 0.0, 0.26, 10), u, self.P(6.60, phi, R_FS + 0.05)))
            gf.append(k.along(k.box((0.04, 0.14, 0.04), (0.0, 0.0, 0.0)), u, self.P(6.60, phi, R_FS + 0.30)))
            # its visual target on a post beside it
            gt.append(k.along(k.cylinder(0.11, 0.0, 0.02, 16), u, self.P(6.95, phi, R_FS + 0.28)))
            gf.append(k.along(k.cylinder(0.02, 0.0, 0.28, 6), u, self.P(6.95, phi, R_FS)))
        self.add_flat("grapple fixtures", WHITE, *gf)
        self.add_flat("grapple targets", (0.05, 0.05, 0.05), *gt)

    def handrails(self):
        rails = []
        # aft shroud: along it, and round it near each end
        for phi in (270.0, 207.0, 333.0, 90.0, 30.0, 150.0):
            rails += self.rail_long(phi, 0.30, 3.30, R_AFT)
        rails += self.rail_arc(0.14, 0.0, 360.0, R_AFT)
        rails += self.rail_arc(3.20, 200.0, 340.0, R_AFT)
        # Equipment Section: a rail over each bay door
        for j in range(12):
            phi = 15.0 + 30.0 * j
            Rc = R_ES
            rails += self.rail_arc(4.80, phi - 9, phi + 9, Rc / math.cos(math.radians(9)), h=0.06)
        # forward shell and light shield
        for phi in (200.0, 340.0, 20.0, 160.0):
            rails += self.rail_long(phi, 6.25, 8.70, R_FS)
        for phi in (30.0, 150.0, 210.0, 330.0):
            rails += self.rail_long(phi, 9.25, 12.70, R_FS)
        rails += self.rail_arc(9.15, 0.0, 360.0, R_FS)
        rails += self.rail_arc(12.78, 160.0, 380.0, R_FS)
        self.add_flat("handrails", T.YELLOW, *rails)

    # -------------------------------------------------------------- all
    def build(self, door_deg=0.0, array_deg=0.0):
        self.light_shield_and_forward_shell()
        self.ota_bay_ring()
        self.equipment_section()
        self.aft_shroud()
        self.aft_bulkhead()
        self.aperture_door(door_deg)
        if self.era == '2009':
            self.solar_arrays_sa3(array_deg)
            self.soft_capture_mechanism()
        else:
            self.solar_arrays_sa1(array_deg)
        self.high_gain_antennas()
        self.light_shield_hardware()
        self.forward_shell_hardware()
        self.handrails()
        for (name, rgb), ms in self.flat.items():
            self.parts.append(G.part(name, list(rgb), ms))
        return self.parts


def build(kit, era='2009', door_deg=0.0, array_deg=0.0):
    return Builder(kit, era).build(door_deg, array_deg)
