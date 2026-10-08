"""Spartan 201-02 (NORAD 23253), deployed and retrieved by STS-64: see _leo_spartan."""
from . import _leo_spartan

KEY = 'spartan201_2'


def build(kit):
    return _leo_spartan.module(kit, 2, "STS-64", 23253)
