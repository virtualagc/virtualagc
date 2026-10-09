"""The Wake Shield Facility's STS-69 flight (WSF-2, NORAD 23669), deployed, flown free for about three days and retrieved: grey equipment boxes, dark green bars (sts069-723-072, sts069-732-048).  See _leo_wsf."""
from . import _leo_wsf

KEY = 'wsf2'


def build(kit):
    return _leo_wsf.module(kit, "STS-69", 23669)
