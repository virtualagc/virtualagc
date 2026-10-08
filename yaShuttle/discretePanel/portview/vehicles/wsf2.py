"""The Wake Shield Facility's STS-69 flight (NORAD 23669), deployed, flown free and retrieved: see _leo_wsf."""
from . import _leo_wsf

KEY = 'wsf2'


def build(kit):
    return _leo_wsf.module(kit, "STS-69", 23669)
