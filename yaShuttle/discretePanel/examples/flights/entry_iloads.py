"""STS-134's flown G3 entry-guidance I-loads, written into a capture's memory.

WHY A CAPTURE'S MEMORY AND NOT THE TAPE.  OPS 3 is resident from MM 302 (the deorbit burn), so a capture taken at or after
TIG-60 s already holds G3 and PASS never reloads it from the volume: a patched tape changes nothing for such a run.  The
generic values (the volume's, and so the capture's) fly the entry about a minute short (EI to touchdown 30:39 against the
flown 31:44, TAEM interface 26 nmi from the runway against ~60); the flown ones give 31:45 (ledger #306).

The cells are tools/sites/sts134-entry-iloads.json's (#PCGGC03).  apply() is idempotent: a cell that already holds the flown
value is left alone, one that holds the generic value is written, anything else is left alone and reported.  The first time a
memory image is changed it is kept beside itself as gpcN.mem.bin.generic.
"""
import glob
import json
import os
import shutil

import numpy as np

SPEC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "yaGPC2", "tools", "sites",
                    "sts134-entry-iloads.json")


def tacan_cells():
    """A TACAN vehicle's configuration (FLY_TACAN=1; the volume's is OV-105's, GPS only): PASS's TACAN filter,
    GRY_TAC_FDI, runs only if CGNV_NUM_GPS_INSTALLED < 3 (GYTTAC.hal:236-242; CGBGPS.hal:158 INITIAL 3, here @064F4) and the
    entry nav takes TACAN only with CGNS_GPS_TAC_CONFIG OFF (CGNGPS.hal:897 INITIAL ON, @0CAFF).  Addresses are G3's."""
    if not os.environ.get("FLY_TACAN"):
        return []
    return [dict(addr="064f4", was="0003", H="0000", name="CGNV_NUM_GPS_INSTALLED"),
            dict(addr="0caff", was="0001", H="0000", name="CGNS_GPS_TAC_CONFIG")]


def apply(capdir, say=print):
    """Write the flown cells into every gpcN.mem.bin of `capdir`; returns (written, already, other) of the last image."""
    cells = json.load(open(SPEC))["cells"] + tacan_cells()
    result = (0, 0, 0)
    for path in sorted(glob.glob(os.path.join(capdir, "gpc*.mem.bin"))):
        mem = np.frombuffer(open(path, "rb").read(), dtype=">u2").copy()
        wrote = same = other = 0
        for c in cells:
            a, n = int(c["addr"], 16), len(c["H"]) // 4
            got = "".join("%04X" % x for x in mem[a:a + n])
            if got.upper() == c["H"].upper():
                same += 1
            elif got.upper() == c["was"].upper():
                for i in range(n):
                    mem[a + i] = int(c["H"][4 * i:4 * i + 4], 16)
                wrote += 1
            else:
                other += 1
        if wrote:
            if not os.path.exists(path + ".generic"):
                shutil.copy2(path, path + ".generic")
            with open(path, "wb") as fh:
                fh.write(mem.astype(">u2").tobytes())
        say("entry I-loads: %s: %d written, %d already flown, %d neither (left alone)"
            % (os.path.relpath(path, os.path.dirname(capdir)), wrote, same, other))
        result = (wrote, same, other)
    return result


def request_text(spec=None):
    """The cells as yaGPC2's live-patch request (run.c batchrunner_apply_patch): ADDR WAS NEW per line."""
    cells = json.load(open(spec or SPEC))["cells"] + tacan_cells()
    return "".join("%s %s %s\n" % (c["addr"], c["was"], c["H"]) for c in cells)

