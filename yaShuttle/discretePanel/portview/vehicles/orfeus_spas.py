"""ORFEUS-SPAS flight 1 (NORAD 22798), deployed, flown free and retrieved by STS-51: see _leo_orfeus."""
from . import _leo_orfeus

KEY = 'orfeus_spas'


def build(kit):
    return _leo_orfeus.module(kit, 1, "STS-51", 22798)
