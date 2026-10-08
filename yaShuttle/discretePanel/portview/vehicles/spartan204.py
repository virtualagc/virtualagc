"""Spartan 204 (NORAD 23470), as STS-63 deployed and retrieved it in
February 1995 (the flight that also made the near-rendezvous with Mir):
the Spartan carrier in copper-gold blankets with its instrument section
(the Far Ultraviolet Imaging Spectrograph, NRL) on the +X end, a louvred
radiator on the -Z face, the grapple fixture and its white target disc on
+Y.  After retrieval it was unberthed again on the arm for EVA
mass-handling practice.  From sts063-716-064; see _leo_spartan."""
from . import _leo_spartan as S
from . import _leo_util as U

KEY = 'spartan204'


def build(kit):
    p = S.copper_carrier(kit)
    sec = kit.box((0.80, 1.10, 1.10), (0.95, -0.05, 0.0))
    p.append(U.tpart(kit, "FUV instrument section (copper blanket)", S.COPPER, sec, U.tex_mli(121, seams=1, depth=0.5), tile=0.9))
    p.append(kit.part("FUV aperture", (0.03, 0.03, 0.03),
                      kit.along(kit.disc(0.16, 0.0, n=20), (1, 0, 0), (1.355, 0.2, 0.15))))
    p.append(kit.part("aperture door", (0.70, 0.70, 0.70), kit.box((0.02, 0.36, 0.36), (1.36, 0.2, -0.28))))
    rad = kit.box((0.75, 1.0, 0.02), (0.95, -0.05, -0.565))
    p.append(U.tpart(kit, "louvred radiator", (0.65, 0.65, 0.67), rad, U.tex_panels(10, 2, seed=122, line=0.45),
                     tile=(0.75, 1.0), axes=((1, 0, 0), (0, 1, 0))))
    return dict(meta=S.flyer_meta(kit, "Spartan 204 (STS-63)", 23470), parts=U.refine_parts(p))
