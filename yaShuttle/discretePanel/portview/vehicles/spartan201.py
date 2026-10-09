"""Spartan 201-01 (NORAD 22623), deployed and retrieved by STS-56: see _leo_spartan."""
from . import _leo_spartan

KEY = 'spartan201'


def build(kit):
    return _leo_spartan.module(kit, 1, "STS-56", 22623)
