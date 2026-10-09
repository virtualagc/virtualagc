"""The vehicles portview draws besides the ISS, one module each.

A module here is a vehicle: it defines KEY (its directory under
portview/cache/models/) and build(kit), which returns

    dict(meta=dict(name=..., frame=..., source=..., norad=NNNNN, mag_1000km=M),
         parts=[...])

-- parts as kit.part() makes them (or kit.nasa_glb() loads them), in the
vehicle's body frame, metres, with the origin at its centre of mass (a
vehicle's state is its centre of mass's).  `python3 portview/fetch_assets.py
--vehicles KEY --rebuild` prepares one; portview finds every prepared model
whose model.json has a NORAD id and draws it when TGT1 names that id.
"""
import importlib
import os
import pkgutil


def discover():
    """{KEY: module} for every vehicle module here."""
    out = {}
    for m in pkgutil.iter_modules([os.path.dirname(__file__)]):
        if m.name.startswith('_') or m.name == 'kit':
            continue
        mod = importlib.import_module(__name__ + '.' + m.name)
        if hasattr(mod, 'KEY') and hasattr(mod, 'build'):
            out[mod.KEY] = mod
    return out
