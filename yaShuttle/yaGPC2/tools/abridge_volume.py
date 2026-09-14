#!/usr/bin/env python3
"""Cut memory configurations out of a mass-memory volume, leaving the rest usable.

    tools/abridge_volume.py VOLUME.mmv --con80 CON80 --drop-mc 1,3 -o OUT.mmv

WHAT IS REMOVED, AND WHY THAT IS ENOUGH

A memory configuration (MC) is the list of phases an OPS transition loads:
the GNC major-function base (phase 3) or the SM/PL base, then the MC's own
application phases.  The rows below are the flight table CZ2V_GRT_PHASES
(SSSRC/CZ2COMMO), as nsts-sdl-dps's ap101Utils/mcconfigs.py carries them;
each row's last phase is the one CON80/MMUSYS1 tags with MC=, and that is
checked against the deck here, so a deck that has moved on is refused rather
than followed.

A phase is removed only if NO kept configuration and not the IPL set
(CON80/MMLOAD's IPL,PH=(...)) loads it.  Dropping MC1 (GNC OPS 1 and 6) and
MC3 (GNC OPS 3) therefore removes phases 4 and 6 and keeps phase 3, which
every GNC configuration and the IPL share.

What goes is each removed phase's whole tape ALLOCATION (CON80/MMUDATn),
not only the blocks the build happened to write.  An allocation that
overlaps any other allocation is refused.  In the volume format a block
absent from the directory reads back as zeros (yaGPC2 src/mmumodel.c), so
removal is just leaving the blocks out.

Nothing else changes: not phase 2's in-core phase table (#PFCMGPT), not a
single byte of any block that stays -- which is re-read and verified before
this exits.  The IPL and every kept configuration read exactly what they
read from the full volume.

WHAT A REMOVED OPS DOES

The in-core phase table still describes the removed phases, so an OPS
transition to one of them still reads their tape addresses and gets zeros.
A zero load block passes its own checksum (the sum of zeros is zero), so the
flight software will most likely "load" zeros and fail when it runs them.
Do not request a removed OPS from an abridged volume.

Repeatable by construction: the inputs are the full volume and the CON80
deck it was built from.  tapebuild/build.sh runs this as its last stage.
"""
import argparse
import re
import struct
import sys
from pathlib import Path

HW_PER_BLOCK = 512
HEADER_SIZE = 32
MAGIC = b"MMUVOL01"

# MC number -> (name, phase row, what it is).  CZ2V_GRT_PHASES, SSSRC/CZ2COMMO;
# see the module docstring.
MCS = {
    1: ("G16", (3, 4), "GNC OPS 1 and 6"),
    2: ("G2", (3, 5), "GNC OPS 2"),
    3: ("G3", (3, 6), "GNC OPS 3"),
    4: ("S2", (14, 15), "SM OPS 2"),
    5: ("S4", (14, 16), "SM OPS 4"),
    6: ("P9", (9, 12), "PL OPS 9"),
    8: ("G8", (3, 7), "GNC OPS 8"),
    9: ("G9", (3, 8, 18), "GNC OPS 9"),
}

_PHASE_RE = re.compile(r"^(\S+)\s+PHASE,(\S+)")
_ALLOC_RE = re.compile(r"^(\S+)\s+ALLOC,ADDR=(\d{5})(?:,BLKS=(\d+))?")
_IPL_RE = re.compile(r"\bIPL,PH=\(([\d,]+)\)")


def die(msg):
    sys.exit("abridge_volume: " + msg)


def card_block(addr):
    """A CON80 ADDR=FTSBB as a block index: file, track, subfile, then the
    block in DECIMAL -- the volume directory's own ordering (mmu2mmv's
    blockIndex)."""
    f, t, s, bb = int(addr[0]), int(addr[1]), int(addr[2]), int(addr[3:5])
    if f > 7 or t > 7 or s > 7 or bb > 31:
        die("ADDR=%s is not a tape address" % addr)
    return ((f * 8 + t) * 8 + s) * 32 + bb


def fmt(index):
    return "%d/%d/%d/%d" % (index // 256 % 8, index // 2048 % 8,
                            index // 32 % 8, index % 32)


def read_deck(con80):
    """(IPL phase set, {area: {member: (phase, mc)}}, [(area, member, first, n)])"""
    ipl = None
    for ln in (con80 / "MMLOAD").read_text(errors="replace").splitlines():
        m = _IPL_RE.search(ln)
        if m and not ln.lstrip().startswith("*"):
            ipl = {int(p) for p in m.group(1).split(",")}
            break
    if ipl is None:
        die("%s/MMLOAD has no IPL,PH=(...) card" % con80)
    phases, allocs = {}, []
    for area in (1, 2, 3):
        sysf, datf = con80 / ("MMUSYS%d" % area), con80 / ("MMUDAT%d" % area)
        if not sysf.exists() or not datf.exists():
            continue
        members = {}
        for ln in sysf.read_text(errors="replace").splitlines():
            m = _PHASE_RE.match(ln)
            if not m:
                continue
            opts = dict(kv.partition("=")[::2] for kv in m.group(2).rstrip(";").split(","))
            if "PH" in opts:
                members[m.group(1)] = (int(opts["PH"]), int(opts["MC"]) if "MC" in opts else None)
        phases[area] = members
        for ln in datf.read_text(errors="replace").splitlines():
            m = _ALLOC_RE.match(ln)
            if m and m.group(3):
                allocs.append((area, m.group(1), card_block(m.group(2)), int(m.group(3))))
    if 1 not in phases:
        die("%s has no MMUSYS1/MMUDAT1" % con80)
    return ipl, phases, allocs


def read_volume(path):
    if not path.is_file():
        die("no volume %s" % path)
    b = path.read_bytes()
    if b[:8] != MAGIC:
        die("%s is not an MMUVOL01 volume" % path)
    hw, n, flags = struct.unpack(">III", b[8:20])
    if hw != HW_PER_BLOCK:
        die("%s has %d halfwords per block" % (path, hw))
    idx = struct.unpack(">%dI" % n, b[HEADER_SIZE:HEADER_SIZE + 4 * n])
    at = HEADER_SIZE + 4 * n
    size = hw * 2
    blocks = {i: b[at + k * size:at + (k + 1) * size] for k, i in enumerate(idx)}
    if len(blocks) != n or at + n * size != len(b):
        die("%s: directory and data do not agree" % path)
    return flags, b[20:HEADER_SIZE], blocks


def write_volume(path, flags, reserved, blocks):
    idx = sorted(blocks)
    out = bytearray(MAGIC)
    out += struct.pack(">III", HW_PER_BLOCK, len(idx), flags) + reserved
    out += struct.pack(">%dI" % len(idx), *idx)
    for i in idx:
        out += blocks[i]
    path.write_bytes(bytes(out))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("volume", type=Path)
    ap.add_argument("--con80", type=Path, required=True,
                    help="the CON80 deck the volume was built from")
    ap.add_argument("--drop-mc", required=True, metavar="LIST",
                    help="memory configurations to remove, e.g. 1,3 (%s)" %
                         "; ".join("%d %s" % (k, v[2]) for k, v in sorted(MCS.items())))
    ap.add_argument("-o", "--out", type=Path, required=True)
    a = ap.parse_args()

    if not (a.con80 / "MMLOAD").is_file():
        die("%s is not a CON80 deck (no MMLOAD)" % a.con80)
    drop = {int(x) for x in a.drop_mc.split(",") if x.strip()}
    unknown = drop - set(MCS)
    if unknown:
        die("no memory configuration %s" % sorted(unknown))
    ipl, phases, allocs = read_deck(a.con80)

    # The deck must agree with the table: MC= sits on each row's last phase.
    tagged = {mc: ph for ph, mc in phases[1].values() if mc is not None}
    for mc, (name, row, _) in MCS.items():
        if tagged.get(mc) != row[-1]:
            die("CON80/MMUSYS1 tags MC=%d on phase %s, the flight table says %d -- "
                "the deck has moved on" % (mc, tagged.get(mc), row[-1]))

    kept = set(ipl)
    for mc, (_, row, _) in MCS.items():
        if mc not in drop:
            kept |= set(row)
    gone = set()
    for mc in drop:
        gone |= set(MCS[mc][1])
    gone -= kept
    if not gone:
        die("dropping MC %s removes no phase: every one is also loaded elsewhere"
            % sorted(drop))

    remove, removing = set(), []
    for area, members in sorted(phases.items()):
        for member, (ph, _) in sorted(members.items()):
            if ph not in gone:
                continue
            mine = [x for x in allocs if x[0] == area and x[1] == member]
            if len(mine) != 1:
                die("phase %d (%s) has %d ALLOC cards in MMUDAT%d" % (ph, member, len(mine), area))
            _, _, first, n = mine[0]
            span = set(range(first, first + n))
            for other in allocs:
                if other is mine[0]:
                    continue
                if span & set(range(other[2], other[2] + other[3])):
                    die("phase %d's allocation (%s) overlaps %s's" % (ph, member, other[1]))
            remove |= span
            removing.append((area, ph, member, first, n))

    flags, reserved, blocks = read_volume(a.volume)
    for area, ph, member, first, n in removing:
        present = len(set(range(first, first + n)) & set(blocks))
        print("  area %d phase %2d %-9s %s, %d blocks allocated, %d on the volume: removed"
              % (area, ph, member, fmt(first), n, present))
    keep = {i: blk for i, blk in blocks.items() if i not in remove}
    write_volume(a.out, flags, reserved, keep)

    # Verify from the written file, not from memory.
    flags2, reserved2, check = read_volume(a.out)
    if flags2 != flags or reserved2 != reserved or check != keep:
        die("%s does not read back as written" % a.out)
    if any(i in check for i in remove):
        die("%s still holds a removed block" % a.out)
    print("  %s: %d of %d blocks kept, every one byte-identical to %s; removed MC %s (%s)"
          % (a.out, len(check), len(blocks), a.volume.name,
             ",".join(map(str, sorted(drop))),
             "; ".join(MCS[m][2] for m in sorted(drop))))


if __name__ == "__main__":
    main()
