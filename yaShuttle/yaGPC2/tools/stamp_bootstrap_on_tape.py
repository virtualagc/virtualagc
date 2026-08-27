#!/usr/bin/env python3
"""Write the IPL bootstrap (FCMBOOT) onto a mass-memory volume.

The firmware IPL -- PASS User's Guide Table 2-2 step 10, "GPC IPL - P/R
... Bootstrap loader read in from MMU" -- reads FCMBOOT off the tape
before any software runs.  A volume built from the PASS phase manifest
alone does not carry it: the phase list holds PASS phases, and nothing
ever writes the bootstrap.  Until it does, there is nothing for the
firmware IPL to read and `--no-fcm` cannot boot.

WHERE IT GOES is not a choice.  CON80's own MMUDAT1 allocates it:

    FMAIPL2  ALOCDESC,'GPC IPL BOOTSTRAP COPY';
    FMAIPL2  ALLOC,ADDR=44500,BLKS=72,INIT=C6C6,SYSID=SYS1;

A CON80 card address is FTSBB -- FILE, TRACK, subfile, then a two-digit
block.  The phase manifest fixes the order: card 43000 is address
3/4/0/0 and card 42300 is 2/4/3/0, where the manifest's own address is
track/file/subfile/block (the reading under which all 1085 blocks of a
built volume are accounted for, and no other).  So 43000 is file 4,
track 3 -- the first card digit is the file.

44500 is therefore file 4, track 4, subfile 5, block 0, with 72 blocks
reserved.  Both digits being 4 here, this happens not to depend on
getting that order right; other allocations very much do.

Usage:  stamp_bootstrap_on_tape.py VOLUME.mmv BOOT.fcm [--out FILE]
"""
import argparse
import struct
import sys

TRACKS = FILES = SUBFILES = 8
BLOCKS_PER_SUBFILE = 32
HALFWORDS_PER_BLOCK = 512

# MMUDAT1's FMAIPL2 allocation, decoded.
BOOT_TRACK, BOOT_FILE, BOOT_SUBFILE, BOOT_BLOCK = 4, 4, 5, 0
BOOT_ALLOC_BLOCKS = 72


def block_index(track, file, subfile, block):
    """mmumodel.c's block_index(), verbatim."""
    return ((((file & 7) * TRACKS + (track & 7)) * SUBFILES + (subfile & 7))
            * BLOCKS_PER_SUBFILE + (block & 0x1f))


def read_volume(path):
    with open(path, "rb") as f:
        raw = f.read()
    if raw[:8] != b"MMUVOL01":
        sys.exit("%s is not an MMUVOL01 volume" % path)
    hw_per_block, entries, flags = struct.unpack(">III", raw[8:20])
    if hw_per_block != HALFWORDS_PER_BLOCK:
        sys.exit("%s has %d halfwords per block, expected %d"
                 % (path, hw_per_block, HALFWORDS_PER_BLOCK))
    header = raw[:32]
    dirs = [struct.unpack(">I", raw[32 + 4 * i:36 + 4 * i])[0]
            for i in range(entries)]
    data_off = 32 + 4 * entries
    stride = HALFWORDS_PER_BLOCK * 2
    blocks = {idx: raw[data_off + i * stride:data_off + (i + 1) * stride]
              for i, idx in enumerate(dirs)}
    if any(len(b) != stride for b in blocks.values()):
        sys.exit("%s: short block data" % path)
    return header, flags, blocks


def write_volume(path, header, blocks):
    order = sorted(blocks)
    out = bytearray(header)
    struct.pack_into(">I", out, 12, len(order))
    for idx in order:
        out += struct.pack(">I", idx)
    for idx in order:
        out += blocks[idx]
    with open(path, "wb") as f:
        f.write(bytes(out))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("volume")
    ap.add_argument("image")
    ap.add_argument("--out", help="write here instead of in place")
    args = ap.parse_args()

    header, flags, blocks = read_volume(args.volume)
    with open(args.image, "rb") as f:
        img = f.read()
    if len(img) % 2:
        sys.exit("%s has an odd byte count" % args.image)

    stride = HALFWORDS_PER_BLOCK * 2
    used = (len(img) + stride - 1) // stride
    if used > BOOT_ALLOC_BLOCKS:
        sys.exit("%s needs %d blocks, but FMAIPL2 reserves only %d"
                 % (args.image, used, BOOT_ALLOC_BLOCKS))

    first = block_index(BOOT_TRACK, BOOT_FILE, BOOT_SUBFILE, BOOT_BLOCK)
    # THE WHOLE ALLOCATION IS WRITTEN, not just the blocks the image fills.
    # A reader on the bus asks for a fixed block count and cannot be told
    # which blocks were ever recorded -- an unwritten one simply reads back
    # as zeros.  The allocation says what belongs in the rest: INIT=C6C6.
    # Writing it makes the tape say the same thing a real one would, and
    # keeps the emulator from depositing a block of zeros into store.
    padded = img + b"\xc6\xc6" * (
        (BOOT_ALLOC_BLOCKS * stride - len(img)) // 2)
    for i in range(BOOT_ALLOC_BLOCKS):
        blocks[first + i] = padded[i * stride:(i + 1) * stride]

    out = args.out or args.volume
    write_volume(out, header, blocks)
    print("stamped %s (%d halfwords) at file %d/track %d/subfile %d/block %d"
          % (args.image, len(img) // 2, BOOT_FILE, BOOT_TRACK, BOOT_SUBFILE,
             BOOT_BLOCK))
    print("  blocks %d..%d, the whole %d-block FMAIPL2 reservation "
          "(%d carry the image, the rest C6C6); volume now holds %d"
          % (first, first + BOOT_ALLOC_BLOCKS - 1, BOOT_ALLOC_BLOCKS,
             used, len(blocks)))
    print("  -> %s" % out)


if __name__ == "__main__":
    main()
