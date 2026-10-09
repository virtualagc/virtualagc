"""Spartan 201-03 (NORAD 23668), deployed and retrieved by STS-69: see _leo_spartan."""
from . import _leo_spartan

KEY = 'spartan201_3'


def build(kit):
    return _leo_spartan.module(kit, 3, "STS-69", 23668)
