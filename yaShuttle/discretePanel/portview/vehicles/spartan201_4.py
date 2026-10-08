"""Spartan 201-04 (NORAD 25062), deployed and retrieved by STS-87: see _leo_spartan."""
from . import _leo_spartan

KEY = 'spartan201_4'


def build(kit):
    return _leo_spartan.module(kit, 4, "STS-87", 25062, " (failed to activate; caught by hand on EVA)")
