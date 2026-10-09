"""Spartan 201-05 (NORAD 25521), deployed and retrieved by STS-95: see _leo_spartan."""
from . import _leo_spartan

KEY = 'spartan201_5'


def build(kit):
    return _leo_spartan.module(kit, 5, "STS-95", 25521)
