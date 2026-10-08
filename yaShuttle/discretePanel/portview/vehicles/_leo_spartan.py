"""The Spartan 201 free-flyer (the NASA/GSFC Spartan carrier with the
Ultraviolet Coronal Spectrometer and the White Light Coronagraph), from NASA
3D Resources' "Spartan 201" -- in metres already (its carrier ~1.0 x 1.2 x
1.2 m, the two telescope tubes through it 3.3 m end to end, the WLC 2.63 m
long; the grapple fixture's base 0.3 m).  Flown five times: STS-56 (1993),
STS-64 (1994), STS-69 (1995), STS-87 (1997; it failed to start and tumbled
slowly, and was caught by hand on EVA), STS-95 (1998)."""
import numpy as np

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
