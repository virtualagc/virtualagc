#!/usr/bin/env python3
"""Fill the root image's UNRESOLVED cross-phase Z-CONs on a mass-memory volume.

SUPERSEDED by patch_unresolved.py, whose "zcon" group is these 18 Z-CONs and
which also fills the resident and phase-8 I/O operands that cause POLL FAIL
after OPS 201/301/801/901.  Kept because v37 was cut with it.

EXPERIMENTAL, AND A WORKAROUND FOR A BUILD DEFECT -- not a fix.  The real
repair belongs in the root link; this exists to prove what the defect costs
and to get a bootable volume in the meantime.  Compare tools/patch_ssl_zcon.py,
which does the same kind of thing for FCMB1ZCN/FCMB2ZCN.

WHAT IS WRONG

A HAL/S call to a procedure that lives in an OVERLAY phase goes through a
fullword indirect address pointer -- a Z-CON -- held in the RESIDENT root, at
a fixed low address.  The compiler emits the cell as `8000 0E00`: address
offset 0 with the sector bit set, and XC=1 C=1 CB=1 BSR=0.  Only the linker
can finish it, because only the linker knows which sector the overlay's code
landed in.

Our root link does not.  The `#C...` target sections are not in the root's
own link, so those Z-CONs stay at `8000 0E00`, and the volume ends up with
IPL fill (`C6C6C6C6`) in the cells instead.  `/tmp/claude-1000/c80boot/
PHASE02.lib` shows the unrelocated form directly.

WHY IT CRASHES THE MACHINE

Read as a pointer, `C6C6` is not inert.  Its bits say XC=0, C=1, CB=1, CD=0,
BSR=12 -- so the C=1/CB=1 rule (AP-101S PoO Fig. 2-17) REPLACES the PSW's BSR
with 12, and XC=0 asks for post-indexing.  A `SCAL` through such a cell
therefore branches to (0xC6C6 + index) in sector 12, which is unloaded fill,
and the machine stops on `invalid instruction 0xc6c6`.

Measured on OI340700-v36boot.mmv: the `DO CASE` dispatch in #CDCDDOW does
`SCAL` through #ZDCDDG9 at 0x001DE and lands at 0x648DA.  Note that EVERY
correctly-filled Z-CON here carries XC=1 -- no post-indexing -- so which cell
in the hole gets used does not change where it goes; the target depends only
on the index register.  That is why OPS 901 PRO and OPS 201 PRO, which do not
call the same routine, both die at the same address.

WHERE THE VALUES COME FROM

Two independent sources that agree, neither of them one of our tapes:

  * the eight DASS dumps in ~/workspace/PFS/mafgen (G2 G3 G8 G9 G16 P9 S2 SSW)
    agree with each other on all 18 cells;
  * our own WHOLE-MEMORY link, link/G9-symbols.json, whose relocation list
    gives the same target address for 17 of the 18.

The exception is 0x001E2.  In the whole-memory link `#ZDCDDS4` comes from
`<external-syms>` rather than from a real DCDDS4.obj, and the linker put
ACOS's Z-CON in the same cell -- a placement collision, and a second build
defect.  DASS's value is used there: it makes DS2/DS4 share an entry stub at
0x24074 exactly as DG2/DG3/DG8 share one at 0x1DDCC.

NOT PATCHED, ON PURPOSE: 0x1E8, 0x202, 0x218 and 0x22C differ from DASS too,
but they hold real values rather than fill (and all four have bit 0 clear
where DASS has it set).  That is a different defect and wants its own
diagnosis, not a hand-applied constant.
"""

import argparse
import struct
import sys

# address -> (halfword 0, halfword 1), from the DASS dumps; see the header.
ZCONS = {
    0x01d6: (0xde62, 0x0e30),   # #ZDCDDG1 -> 0x1de62
    0x01d8: (0xddcc, 0x0e30),   # #ZDCDDG2 -> 0x1ddcc
    0x01da: (0xddcc, 0x0e30),   # #ZDCDDG3 -> 0x1ddcc
    0x01dc: (0xddcc, 0x0e30),   # #ZDCDDG8 -> 0x1ddcc
    0x01de: (0x83aa, 0x0e60),   # #ZDCDDG9 -> 0x303aa   <-- the crash
    0x01e0: (0xc074, 0x0e40),   # #ZDCDDS2 -> 0x24074
    0x01e2: (0xc074, 0x0e40),   # #ZDCDDS4 -> 0x24074
    0x01e4: (0x8022, 0x0e40),   # #ZDCDDS8 -> 0x20022
    0x01f6: (0x888c, 0x0e90),   # #ZDCDGNLIG -> 0x4888c
    0x01f8: (0x80f8, 0x0e20),   # #ZDCDG9LIG -> 0x100f8
    0x0234: (0xe9f0, 0x0e30),   # #ZDCDKFCM1 -> 0x1e9f0
    0x0236: (0xe68c, 0x0e30),   # #ZDCDKFCM2 -> 0x1e68c
    0x0238: (0xe982, 0x0e30),   # #ZDCDKFCM3 -> 0x1e982
    0x023a: (0xc03a, 0x0e40),   # #ZDCDKFCM4 -> 0x2403a
    0x023c: (0xc03a, 0x0e40),   # #ZDCDKFCM5 -> 0x2403a
    0x023e: (0x85be, 0x0e40),   # #ZDCDKFCM6 -> 0x205be
    0x0240: (0xe77c, 0x0e30),   # #ZDCDKFCM8 -> 0x1e77c
    0x0242: (0xdf0c, 0x0e30),   # #ZDCDKFCM9 -> 0x1df0c
}

# Three consecutive Z-CONs immediately BEFORE the hole, used to find the load
# block and to establish its destination address without having to be told
# either.  Matching on the tree's own bytes rather than on a slot number is
# deliberate: slot numbers move between builds.
ANCHOR = (0xc878, 0x0e80, 0xe078, 0x0e80, 0xc466, 0x0e80)
ANCHOR_ADDR = 0x01d0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("volume")
    ap.add_argument("--out", help="write here instead of in place")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    raw = bytearray(open(a.volume, "rb").read())
    if raw[:8] != b"MMUVOL01":
        sys.exit("%s is not an MMUVOL01 volume" % a.volume)
    hw, entries, _ = struct.unpack(">III", raw[8:20])
    data_off = 32 + 4 * entries

    def get(slot, i):
        return struct.unpack_from(">H", raw, data_off + slot * hw * 2 + 2 * i)[0]

    def put(slot, i, v):
        struct.pack_into(">H", raw, data_off + slot * hw * 2 + 2 * i, v)

    # Find the load block: a checksum-consistent block that contains ANCHOR.
    hit = None
    for slot in range(entries):
        for j in range(hw - len(ANCHOR)):
            if all(get(slot, j + k) == ANCHOR[k] for k in range(len(ANCHOR))):
                dest = ANCHOR_ADDR - j
                for L in range(j + len(ANCHOR), hw - 1):
                    if get(slot, L) != 0:
                        continue
                    s = sum(get(slot, i) for i in range(L)) & 0xffff
                    if s == get(slot, L + 1):
                        hit = (slot, dest, L)
                        break
                break
        if hit:
            break
    if not hit:
        sys.exit("could not find the root Z-CON load block by its anchor")
    slot, dest, L = hit
    print("  load block: slot %d  dest=%#06x  content=%d halfwords "
          "(%#06x..%#06x)" % (slot, dest, L, dest, dest + L - 1))

    n = 0
    for addr in sorted(ZCONS):
        if not (dest <= addr < dest + L - 1):
            sys.exit("  %#06x is outside the block -- wrong block found" % addr)
        i = addr - dest
        was = (get(slot, i), get(slot, i + 1))
        new = ZCONS[addr]
        flag = "" if was == (0xc6c6, 0xc6c6) else "   <-- NOT FILL, check this"
        print("    %#06x  %04X %04X -> %04X %04X%s"
              % (addr, was[0], was[1], new[0], new[1], flag))
        if not a.dry_run:
            put(slot, i, new[0])
            put(slot, i + 1, new[1])
        n += 1

    if a.dry_run:
        print("  (dry run, nothing written)")
        return
    tail = sum(get(slot, i) for i in range(L)) & 0xffff
    print("  load-block checksum: %04X -> %04X" % (get(slot, L + 1), tail))
    put(slot, L, 0)
    put(slot, L + 1, tail)
    out = a.out or a.volume
    open(out, "wb").write(bytes(raw))
    print("  %d Z-CONs filled; wrote %s" % (n, out))


if __name__ == "__main__":
    main()
