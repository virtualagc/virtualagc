"""ORFEUS-SPAS flight 2 (NORAD 24661), deployed, flown free and retrieved by STS-80: see _leo_orfeus."""
from . import _leo_orfeus

KEY = 'orfeus_spas2'


def build(kit):
    return _leo_orfeus.module(kit, 2, "STS-80", 24661)
