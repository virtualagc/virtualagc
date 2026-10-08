"""CRISTA-SPAS flight 2 (NORAD 24890), deployed, flown free and retrieved by STS-85: see _leo_crista."""
from . import _leo_crista

KEY = 'crista_spas2'


def build(kit):
    return _leo_crista.module(kit, 2, "STS-85", 24890)
