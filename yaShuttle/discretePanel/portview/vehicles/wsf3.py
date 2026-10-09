"""The Wake Shield Facility's STS-80 flight (WSF-3, NORAD 24662), deployed, flown free for about three days and retrieved: white-painted equipment boxes and pads, gold bars, an extra white box and a bar along -X (sts080-708-084, sts080-755-016, sts080-708-065).  See _leo_wsf."""
from . import _leo_wsf

KEY = 'wsf3'


def build(kit):
    return _leo_wsf.module(kit, "STS-80", 24662, variant='wsf3')
