"""Spartan 101 (Spartan-1, NORAD 15831), as STS-51G deployed and
retrieved it in June 1985: the first Spartan, the NRL's X-ray astronomy
payload (two large proportional counters with collimators, scanning the
Perseus cluster, the galactic centre and Scorpius X-2) on the carrier's
instrument end.  Spartan-1's blankets were silver-white rather than the
later copper-gold.  The instrument geometry is representative; see
_leo_spartan."""
from . import _leo_spartan as S
from . import _leo_util as U

KEY = 'spartan101'

SILVER = (0.66, 0.66, 0.68)


def build(kit):
    p = []
    for q in S.carrier_parts(kit):
        if q['name'] in S._BLANKETS:
            q['color'] = list(SILVER) + [1.0]
        p.append(q)
    det = [kit.box((1.10, 0.55, 0.95), (1.05, -0.32, 0.0)), kit.box((1.10, 0.55, 0.95), (1.05, 0.32, 0.0))]
    p.append(U.tpart(kit, "X-ray detectors (silver blankets)", SILVER, kit.merge(*det), U.tex_mli(141, seams=1), tile=0.8))
    col = [kit.box((0.02, 0.47, 0.85), (1.61, y, 0.0)) for y in (-0.32, 0.32)]
    p.append(U.tpart(kit, "collimator faces", (0.12, 0.12, 0.13), kit.merge(*col), U.tex_panels(8, 12, seed=142, line=3.0),
                     tile=(0.47, 0.85), axes=((0, 1, 0), (0, 0, 1))))
    return dict(meta=S.flyer_meta(kit, "Spartan 101 (Spartan-1, STS-51G)", 15831,
                                  source_extra="; the X-ray instruments representative shapes"),
                parts=U.refine_parts(p))
