"""The Wake Shield Facility's STS-80 flight (NORAD 24662), deployed, flown free and retrieved: see _leo_wsf."""
from . import _leo_wsf

KEY = 'wsf3'


def build(kit):
    return _leo_wsf.module(kit, "STS-80", 24662)
