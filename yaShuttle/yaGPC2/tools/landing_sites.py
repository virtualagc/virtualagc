#!/usr/bin/env python3
"""THE LANDING SITE ON THE VOLUME: a site file (tools/sites/*.json) as PASS's
G3 landing-site I-loads, written as a tools/mission_reconfig.py spec.

    tools/landing_sites.py SITE.json VOLUME > SPEC.json
    tools/mission_reconfig.py SPEC.json VOLUME --out OUT.mmv

WHY.  CGN13R's runway, MLS and TACAN area tables (CGNS_RW_AREA_TABLE(90),
CGNS_MLS_AREA_TABLE(15), CGNS_TACAN_AREA_TABLE(90)) are blank in the source
and in the DASS dumps: every flight's own I-loads filled them, and without
them entry has no runway -- R_LS_EF falls at latitude 0, longitude 0.  The
compool is in G3 and G16 only, an overlay reloaded at each OPS 3
transition, so it has to be on the volume.  Area 1 (the default on entering
OPS 3) takes runway slots 1 and 2 (GVPRUN.hal:190,200) and TACAN slot 1
(GVQSIT.hal:253), so a site in slots 1-2 needs no crew action.

WHERE.  The blank tables repeat so often that mission_reconfig's context
search cannot place them.  The G3 copy is the load block that starts with
the compool (#PCGN13R, G3 halfword 0x30322): G3_TABLE_FLAT, measured on
OI340700-v44boot-sts134.mmv against an OPS 301 capture (3276 of 3276
halfwords agree; block 1328128, length 3736).  mission_reconfig refuses a
cell whose volume position does not hold the blank image, so a different
volume is caught rather than written over.

LAYOUTS (CGN13R.hal:59-98), IBM short floats (2 halfwords) unless noted:
  runway (18 hw): RUNWAY_ID CHARACTER(6) (a 0606 length halfword then six
    ASCII bytes -- PASS's character constants are ASCII in memory), LAT
    geodetic rad, LON east rad, AZIMUTH true rad (the landing direction),
    MAG_VAR east rad, RUNWAY_ALT ft above the ellipsoid, DELH ft (MSL above
    the ellipsoid), LENGTH integer ft, MSBLS_INDEX integer (0 none)
  TACAN (12 hw): MAGNETIC_VARIATION rad, MSL_ABOVE_ELLIPSOID ft,
    ALT_ABOVE_ELLIPSOID ft, LONGITUDE_EAST rad, LATITUDE_GEODETIC rad,
    TAC_ID integer (channel, negative for Y), TAC_CHAN bit(16) left for
    GVQSIT.hal:382-401 to compute.
"""
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mission_reconfig import ibm_short   # noqa: E402

RW_BASE, RW_STRIDE = 0x30322, 18
MLS_BASE, MLS_STRIDE = 0x30976, 28
TAC_BASE, TAC_STRIDE = 0x30B1A, 12
G3_TABLE_FLAT = 1328128          # the G3 copy's first halfword on the STS-134 volume
G3_TABLE_BLOCK = [1328128, 3736]  # ... and its load block
BLANK_RW = [0x0606, 0x2020, 0x2020, 0x2020] + [0] * 14
BLANK_TAC = [0] * 12


def dms(s):
    d, m, x = s[:-1].split("-")
    v = int(d) + int(m) / 60.0 + float(x) / 3600.0
    return -v if s[-1] in "SW" else v


def floats(*vals):
    out = []
    for v in vals:
        out += ibm_short(v)
    return out


def i16(v):
    return int(v) & 0xFFFF


def name6(s):
    b = (s + "      ")[:6].encode("ascii")
    return [0x0606] + [(b[i] << 8) | b[i + 1] for i in range(0, 6, 2)]


def azimuth(lat1, lon1, lat2, lon2):
    """True azimuth from point 1 to 2 (deg), on the local ellipsoid radii --
    a 15,000 ft runway is far too short for the difference to matter."""
    A, f = 6378137.0, 1 / 298.257223563
    e2 = f * (2 - f)
    lat = math.radians((lat1 + lat2) / 2)
    N = A / math.sqrt(1 - e2 * math.sin(lat) ** 2)
    M = A * (1 - e2) / (1 - e2 * math.sin(lat) ** 2) ** 1.5
    dn = math.radians(lat2 - lat1) * M
    de = math.radians(lon2 - lon1) * N * math.cos(lat)
    return (math.degrees(math.atan2(de, dn)) + 360.0) % 360.0, dn, de


def cells(site):
    out = []
    D = math.radians
    rws = {}
    for r in site["runways"]:
        lat, lon = dms(r["lat_dms"]), dms(r["lon_dms"])
        az, _, _ = azimuth(lat, lon, dms(r["other_end_lat_dms"]), dms(r["other_end_lon_dms"]))
        rws[r["slot"]] = (lat, lon, az, r)
        hw = (name6(r["id"]) + floats(D(lat), D(lon), D(az), D(r["mag_var_deg"]),
                                      r["alt_ft"] + r["delh_ft"], r["delh_ft"])
              + [i16(r["length_ft"]), i16(r["msbls_index"])])
        assert len(hw) == RW_STRIDE
        addr = RW_BASE + (r["slot"] - 1) * RW_STRIDE
        out.append(dict(name="RW(%d) %s az %.3f" % (r["slot"], r["id"], az), config="G3",
                        addr="%05x" % addr, flat=G3_TABLE_FLAT + addr - RW_BASE, block=G3_TABLE_BLOCK,
                        H="".join("%04X" % x for x in hw), was="".join("%04X" % x for x in BLANK_RW)))
    for t in site["tacans"]:
        if "lat_dms" in t:
            lat, lon = dms(t["lat_dms"]), dms(t["lon_dms"])
        else:                               # abeam a runway's midpoint, offset east
            lat0, lon0, az, r = rws[t["abeam_runway_slot"]]
            _, dn, de = azimuth(lat0, lon0, dms(r["other_end_lat_dms"]), dms(r["other_end_lon_dms"]))
            A, f = 6378137.0, 1 / 298.257223563
            e2 = f * (2 - f)
            phi = math.radians(lat0)
            N = A / math.sqrt(1 - e2 * math.sin(phi) ** 2)
            M = A * (1 - e2) / (1 - e2 * math.sin(phi) ** 2) ** 1.5
            off = t["east_offset_ft"] * 0.3048
            lat = lat0 + math.degrees((dn / 2) / M)
            lon = lon0 + math.degrees((de / 2 + off) / (N * math.cos(phi)))
        tid = -t["channel"] if t["mode"] == "Y" else t["channel"]
        hw = floats(D(t["mag_var_deg"]), t["delh_ft"], t["alt_ft"] + t["delh_ft"], D(lon), D(lat)) + [i16(tid), 0]
        assert len(hw) == TAC_STRIDE
        addr = TAC_BASE + (t["slot"] - 1) * TAC_STRIDE
        out.append(dict(name="TACAN(%d) %s %d%s" % (t["slot"], t["id"], t["channel"], t["mode"]),
                        config="G3", addr="%05x" % addr, flat=G3_TABLE_FLAT + addr - RW_BASE, block=G3_TABLE_BLOCK,
                        H="".join("%04X" % x for x in hw), was="".join("%04X" % x for x in BLANK_TAC),
                        value="lat %.6f lon %.6f" % (lat, lon)))
    return out


def main():
    site = json.load(open(sys.argv[1]))
    spec = {"flight": site["site"], "notes": "generated by tools/landing_sites.py from %s" % sys.argv[1],
            "cells": cells(site)}
    json.dump(spec, sys.stdout, indent=1)
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
