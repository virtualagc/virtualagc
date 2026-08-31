#!/usr/bin/env python3
"""Write the SYS5 and SYS8 allocations onto a mass-memory volume.

WHY THIS EXISTS

`mmu2mmv` builds a volume from ONE PASS area: it reads `MMUDAT<area>` and
`MMUSYS<area>` and nothing else (mmu2mmv.py:235,271).  Every allocation
carrying a different SYSID is therefore never written, and two whole
SYSIDs are missed:

    SYS5   the DEU CONTROL PROGRAM and the CRT default formats --
           FMADEU11/12/13/21/22, DMACDFT1/2/3, VMARPLDU.  GPCIPL reads
           these off the tape during IPL and downloads them into the
           display unit.  Observed directly with YAGPC_MMUTRACE: after
           loading itself, GPCIPL issues
               read 17 block(s) from 4/4/3/8    = FMADEU13 (44308, 17)
               read  8 block(s) from 4/4/0/24   = FMADEU21 (44024,  8)
               read  8 block(s) from 4/4/4/8    = DMACDFT1 (44408,  8)
           and the block counts match the CON80 cards exactly.

    SYS8   the MASS MEMORY DIRECTORY -- MMDIR1/2/3 (44000, 44327,
           44725), one block each.  The master IPL card names it:
               IPL,PH=(10,2,13,3),SYSID=SYS1,MMDIR=44000

Absent blocks read back as ZEROS (mmumodel.c:466), so today the flight
software sees zeros where the deck says an allocation exists.

WHAT THIS CAN AND CANNOT SUPPLY

It writes each allocation at its card address, for its card block count,
filled with the card's own INIT pattern (INIT=C6C6 on every SYS5 data
allocation).  That makes the tape match what the deck DECLARES.

Two of those contents we CAN supply, and `--content` is how:

  * DMACDFT1/2/3 -- the DEU CRITICAL FORMATS, three copies of the same
    DEUCFLM image.  That image is not ground data: `CON80/CFSYSIN` names
    its sixteen members (`CRTFMTCU=`) and its layout (ORIGIN/CFITSIZE/
    CFBSIZE/PAD), every member is a `.dfg` static-format deck in the PASS
    source tree, and `dfg deucflm` links them.  Build it with
    `tools/build_deucflm.py` and pass it here.  WITHOUT IT the display
    unit's critical-format buffer is all zeros and every critical-format
    display -- GPC MEMORY among them -- draws its variable data over a
    blank background, which is the "garbage menu" symptom.

Two contents we cannot supply, and those keep the declared fill:

  * The DEU control program is the DISPLAY UNIT'S OWN firmware, not GPC
    software.  There is no DCP source under OI340600 -- searched.  It
    costs nothing here, because MEDS emulates the display unit and runs
    its own control program.
  * MMDIR1/2/3 are bare ALLOC cards with no DIRECTRY card behind them
    (unlike VMARPLA1, SMARDD2A and the rest, which do carry
    `DIRECTRY,SIZE=,ENTRIES=,DMMD=`).  Its layout is ground Mass Memory
    Build data we do not have.

So for those this changes the reads from "block absent, reads zeros" to
"block present, reads the declared fill".  That is the honest state of an
allocation that exists but was never built, and it is what the ground
build would leave behind if the DCP were not supplied.  It is NOT a
substitute for the real DEU control program.

Usage:  add_sysid_allocs.py VOLUME.mmv --con80 DIR [--sysid SYS5 --sysid SYS8]
                            [--content DMACDFT1=DEUCFLM.bin ...] [--out FILE]
"""
import argparse
import re
import struct
import sys
from pathlib import Path

HW_PER_BLOCK = 512
BLOCKS_PER_SUBFILE = 32
MAGIC = b"MMUVOL01"

# `NAME ALLOC,ADDR=fttsbb,BLKS=n` -- same shape mmbstamp matches.
_ALLOC_RE = re.compile(r"^(\S+)\s+ALLOC,ADDR=(\d{5})(?:,BLKS=(\d+))?")
_SYSID_RE = re.compile(r"SYSID=(\w+)")
_INIT_RE = re.compile(r"INIT=([0-9A-Fa-f]{4})")
_LOADBLK_RE = re.compile(r"LOADBLK=(\d+)")
# `<member> SYSTEM,SYSID=,NUMCOPY=,HWDS=xxxx` in the matching MMUSYS deck.
_SYSTEM_RE = re.compile(r"^(\S+)\s+SYSTEM,")
_HWDS_RE = re.compile(r"HWDS=([0-9A-Fa-f]+)")


def join_continuations(text):
    """CON80 continues a card with an 'X' in column 72."""
    out, acc = [], ""
    for ln in text.splitlines():
        body = ln[:71]
        if len(ln) > 71 and ln[71] == "X":
            acc += body
            continue
        out.append(acc + body)
        acc = ""
    if acc:
        out.append(acc)
    return out


def card_to_tfsb(addr):
    """A CON80 card address is FTSBB: file, track, subfile, 2-digit block.
    The same reading stamp_bootstrap_on_tape.py derives and checks."""
    f = int(addr[0]); t = int(addr[1]); s = int(addr[2]); b = int(addr[3:5])
    return t, f, s, b


def block_index(track, file, subfile, block):
    return ((((file & 7) * 8 + (track & 7)) * 8 + (subfile & 7))
            * BLOCKS_PER_SUBFILE + (block & 0x1F))


def system_hwds(con80):
    """member -> the halfword count its SYSTEM card declares.

    THIS IS THE LOAD BLOCK'S LENGTH, and it is not the allocation's.
    DMACDFT1 is an 8-block (4096 halfword) allocation carrying an
    `HWDS=E4C` (3660 halfword) load module, and `MMULDTBL.asm:196` reads
    exactly 3660: seven full blocks plus 76 halfwords.  Put the checksum
    at the end of the 4096 and the reader never sees it -- it checks the
    3660 it read, fails, and re-reads.  Four reads of `4/4/4/8` where the
    baseline had one is exactly that, and GPCIPL then never gets to the
    display at all."""
    out = {}
    for deck in sorted(Path(con80).glob("MMUSYS*")):
        for ln in join_continuations(deck.read_text(errors="replace")):
            m = _SYSTEM_RE.match(ln)
            h = _HWDS_RE.search(ln)
            if m and h:
                out[m.group(1)] = int(h.group(1), 16)
    return out


def collect(con80, sysids):
    """Every ALLOC in any MMUDAT* deck whose SYSID is one we want."""
    hwds = system_hwds(con80)
    found = []
    for deck in sorted(Path(con80).glob("MMUDAT*")):
        for ln in join_continuations(deck.read_text(errors="replace")):
            m = _ALLOC_RE.match(ln)
            if not m:
                continue
            sys_m = _SYSID_RE.search(ln)
            if not sys_m or sys_m.group(1) not in sysids:
                continue
            init_m = _INIT_RE.search(ln)
            found.append({
                "deck": deck.name,
                "member": m.group(1),
                "card": m.group(2),
                "blocks": int(m.group(3)) if m.group(3) else 1,
                "sysid": sys_m.group(1),
                "init": int(init_m.group(1), 16) if init_m else None,
                "loadblk": (int(_LOADBLK_RE.search(ln).group(1))
                            if _LOADBLK_RE.search(ln) else None),
                "hwds": hwds.get(m.group(1)),
            })
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("volume")
    ap.add_argument("--con80", required=True)
    ap.add_argument("--sysid", action="append", default=None,
                    help="SYSID to write (repeatable; default SYS5 and SYS8)")
    ap.add_argument("--out", help="output volume [default: in place]")
    ap.add_argument("--unbuilt", type=lambda v: int(v, 16), default=0xFFFF,
                    help="halfword written to an allocation whose card gives "
                         "no INIT and whose contents we cannot supply "
                         "(default FFFF, the software's own "
                         "not-mass-memory-built sentinel)")
    ap.add_argument("--fill", type=lambda v: int(v, 16), default=None,
                    help="override EVERY allocation's fill with this halfword, "
                         "ignoring the card's INIT (diagnostic: a raw INIT "
                         "pattern is not a valid load block, so this is how to "
                         "test what the reader actually rejects)")
    ap.add_argument("--no-loadblk", dest="loadblk", action="store_false",
                    help="write raw fill instead of a well-formed load block "
                         "for LOADBLK= allocations (diagnostic only)")
    ap.add_argument("--member", action="append", default=None,
                    help="write ONLY these allocations (repeatable).  The "
                         "SYSID sweep is all-or-nothing otherwise, and the "
                         "DEU control program's allocations are worth being "
                         "able to leave alone: their contents cannot be "
                         "supplied, so writing them changes what the flight "
                         "software reads without making it any more correct")
    ap.add_argument("--content", action="append", default=[],
                    metavar="MEMBER=FILE",
                    help="write FILE's halfwords at the start of MEMBER's "
                         "allocation instead of fill (repeatable).  The tail "
                         "keeps the card's fill and the LOADBLK= checksum is "
                         "computed over the result, so the block stays valid")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    sysids = set(a.sysid or ["SYS5", "SYS8"])
    content = {}
    for spec in a.content:
        if "=" not in spec:
            sys.exit("--content wants MEMBER=FILE, got %r" % spec)
        member, _, path = spec.partition("=")
        blob = Path(path).read_bytes()
        if len(blob) % 2:
            sys.exit("%s is %d bytes, not a whole number of halfwords"
                     % (path, len(blob)))
        content[member.strip()] = (
            list(struct.unpack(">%dH" % (len(blob) // 2), blob)), path)

    raw = bytearray(Path(a.volume).read_bytes())
    if raw[:8] != MAGIC:
        sys.exit("%s is not an MMUVOL01 volume" % a.volume)
    hw, entries, spare = struct.unpack(">III", raw[8:20])
    if hw != HW_PER_BLOCK:
        sys.exit("unexpected block size %d" % hw)
    dirs = [struct.unpack(">I", raw[32 + 4 * i:36 + 4 * i])[0]
            for i in range(entries)]
    data_off = 32 + 4 * entries
    blocks = {d: bytes(raw[data_off + i * HW_PER_BLOCK * 2:
                           data_off + (i + 1) * HW_PER_BLOCK * 2])
              for i, d in enumerate(dirs)}

    allocs = collect(a.con80, sysids)
    if a.member:
        want = set(a.member)
        allocs = [al for al in allocs if al["member"] in want]
        missing = want - {al["member"] for al in allocs}
        if missing:
            sys.exit("no allocation card for %s" % ", ".join(sorted(missing)))
    if not allocs:
        sys.exit("no allocations found for %s" % ", ".join(sorted(sysids)))

    added = overwritten = 0
    for al in allocs:
        t, f, s, b = card_to_tfsb(al["card"])
        first = block_index(t, f, s, b)
        # A card with INIT= states its own fill and we honour it.  A card
        # without one leaves the contents to the ground Mass Memory Build,
        # which we cannot reproduce -- so write the sentinel the flight
        # software already reads as "this was never built" rather than zeros,
        # which it cannot tell from a real, empty, VALID table.  FCMBOOT says
        # so of its own FCMPTAD areas: "THE X'FFFF' SIGNALS THAT THIS AREA HAS
        # NOT BEEN MASS MEMORY BUILT (DOESN'T EXIST)".
        pattern = (a.fill if a.fill is not None
                   else al["init"] if al["init"] is not None else a.unbuilt)
        nhw = al["blocks"] * HW_PER_BLOCK
        words = [pattern] * nhw
        supplied = content.get(al["member"])
        if supplied is not None:
            body, path = supplied
            room = (al["hwds"] or nhw) - 2
            if len(body) > room:
                sys.exit("%s holds %d halfwords, more than the %d %s's load "
                         "block has room for (HWDS %X, less the checksum pair)"
                         % (path, len(body), room, al["member"],
                            al["hwds"] or nhw))
            words[:len(body)] = body
        # L is the LOAD MODULE's length -- the SYSTEM card's HWDS= -- not the
        # allocation's.  It is the allocation only when no SYSTEM card says
        # otherwise.  See system_hwds().
        L = al["hwds"] if al["hwds"] and al["hwds"] <= nhw else nhw
        if a.loadblk and al["loadblk"] is not None and L >= 2:
            # A LOADBLK= allocation is a LOAD BLOCK, and the reader checks it.
            # Layout, from mmbstamp's writer and the SSL's own reader (which
            # does SHI R5,2, sums offsets 0..L-3 and compares offset L-1):
            #     [0 .. L-3]  content
            #     [L-2]       zero
            #     [L-1]       sum of the content, mod 2**16
            # patch_ssl_zcon.py recomputes exactly this pair after it edits a
            # block, and finds the block in the first place by the same test.
            # Raw INIT fill is NOT a valid load block: nothing makes its last
            # halfword the checksum, so the reader rejects it and re-reads --
            # which is what four repeated reads of FMADEU13 were.
            words[L - 2] = 0
            words[L - 1] = sum(words[:L - 2]) & 0xFFFF
        raw_words = b"".join(struct.pack(">H", w) for w in words)
        for i in range(al["blocks"]):
            idx = first + i
            if idx in blocks:
                overwritten += 1
            else:
                added += 1
            blocks[idx] = raw_words[i * HW_PER_BLOCK * 2:
                                    (i + 1) * HW_PER_BLOCK * 2]
        print("  %-8s %-8s card=%s  %s  %2d block(s)  fill=%04X"
              % (al["deck"], al["member"], al["card"],
                 "%d/%d/%d/%d" % (t, f, s, b), al["blocks"], pattern)
              + ("" if al["init"] is not None else "  (unbuilt sentinel)")
              + ("" if supplied is None
                 else "  content=%s (%d halfwords)"
                      % (supplied[1], len(supplied[0])))
              + ("" if not (a.loadblk and al["loadblk"] is not None)
                 else "  LOADBLK=%d HWDS=%X checksum %04X"
                      % (al["loadblk"], L, words[L - 1])))

    print("  %d block(s) added, %d overwritten; volume now holds %d"
          % (added, overwritten, len(blocks)))
    if a.dry_run:
        print("  (dry run, nothing written)")
        return

    order = sorted(blocks)
    out = bytearray(MAGIC)
    out += struct.pack(">III", HW_PER_BLOCK, len(order), spare)
    out += raw[20:32]                       # reserved, carried through
    for idx in order:
        out += struct.pack(">I", idx)
    for idx in order:
        out += blocks[idx]
    dest = a.out or a.volume
    Path(dest).write_bytes(bytes(out))
    print("  -> %s" % dest)


if __name__ == "__main__":
    main()
