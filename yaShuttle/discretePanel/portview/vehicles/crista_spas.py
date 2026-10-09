"""CRISTA-SPAS flight 1 (NORAD 23341), deployed, flown free and retrieved by STS-66: see _leo_crista."""
from . import _leo_crista

KEY = 'crista_spas'


def build(kit):
    return _leo_crista.module(kit, 1, "STS-66", 23341)
