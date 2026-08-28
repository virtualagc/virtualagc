#!/usr/bin/env python3
"""Patch FCMB1ZCN and FCMB2ZCN, the SSL's temp-buffer Z-CONs, into a volume.

EXPERIMENTAL, AND A WORKAROUND FOR A BUILD DEFECT -- not a fix.

FCMINSSL.asm declares its 16K MM I/O buffer as

    FCMBFZCN DS 0F                      SOURCE ADDRESSES Z-CON ARRAY
    FCMB1ZCN DC Z(,FIOMUWB2,0)          BUFFER 1 ADDRESS Z-CON
    FCMB2ZCN DC Z(,FIOMUWB2+8192,0)     BUFFER 2 ADDRESS Z-CON

There are TWO of them, and patching only the first is not enough.  The 16K
buffer is used as two 8K halves: FCMMOVE moves the primary half with one MVH
and, on the sequential path, the alternate half with a second.  With only
FCMB1ZCN patched, the second MVH sourced from the UNRESOLVED FCMB2ZCN --
FIOMUWB2 = 0, so FIOMUWB2+8192 encodes as A000/0000, which MVH's R2 arm
resolves to 02000 -- and moved 7,654 halfwords of sector-0 rubbish into the
destination.  The load block then failed its checksum, and FCMINSSL, having
failed three times, executed `SSM FCMWAIT` and stopped the GPC.  Measured:
the destination matched the tape in exactly its first 7,168 halfwords (the
primary half) and was zero after.

and our IPL link leaves FIOMUWB2 UNDEFINED (it is the only undefined symbol
in IPL.map), so the Z-CON resolves to zero.  The SSL then builds its buffer
table with a base of 0, FCMMOVE is handed src=0/dest=0/count=4096, the move
stores into protected low memory, and the resulting violation traps through
a PSA vector into memory PASS phase 2 has just overlaid.

FIOMUWB2 is not an assembly symbol at all.  HALSTAT.ASC:384169 has it as a
HAL/S compool equate:

    FIOMUWB2  EQUATE LABEL  C O M P O O L  CVN_MM_UTILITY
    (EQUATED TO: CDHV_BLOCKS  UNIT/BLOCK: CVN_MM_UTILITY) RESERVED
    (CSECT: #PCVNMMU OFFSET: 000008)  PHASE 2 ADDR: 03032A

so the real link resolves it from the compool.  The proper repair is to
make the IPL link do that.  This only writes the value the link should
have produced, so the rest of the boot can be exercised meanwhile.

Z-CON FORMAT, derived from the code that consumes it (FCMINSSL.asm:526-530)
and checked against the HALSTAT address:

    halfword 0 = 0x8000 | (addr & 0x7FFF)   the MSB is a marker the
                                            consumer shifts out (SLL 1)
    halfword 1 = addr >> 15                 the sector

    LH R5,FCMBFZCN / SLL R5,1 / LH R4,FCMBFZCN+1 / SRL R4,16 / SRDL R4,17
    with 832A/0006 reconstructs 0x0003032A exactly.
"""
import argparse
import struct
import sys

HW_PER_BLOCK = 512
FCMB1ZCN = 0x735e          # from the link map / IPL.sym.json


def block_index(track, file, subfile, block):
    return ((((file & 7) * 8 + (track & 7)) * 8 + (subfile & 7)) * 32
            + (block & 0x1f))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("volume")
    ap.add_argument("--addr", type=lambda s: int(s, 16), default=0x03032a,
                    help="18-bit address FIOMUWB2 should resolve to "
                         "(default 03032A, HALSTAT's PHASE 2 ADDR)")
    ap.add_argument("--zcon", type=lambda s: int(s, 16), default=FCMB1ZCN)
    ap.add_argument("--lb-addr", type=lambda s: int(s, 16), default=0x6fbc)
    ap.add_argument("--lb-len", type=int, default=994)
    ap.add_argument("--phase", default="2,4,3,55",
                    help="track,file,subfile,blocks of the phase holding it")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    track, file, subfile, nblocks = (int(x) for x in a.phase.split(","))
    raw = bytearray(open(a.volume, "rb").read())
    if raw[:8] != b"MMUVOL01":
        sys.exit("%s is not an MMUVOL01 volume" % a.volume)
    hw, entries, _ = struct.unpack(">III", raw[8:20])
    dirs = [struct.unpack(">I", raw[32 + 4 * i:36 + 4 * i])[0] for i in range(entries)]
    slot = {d: i for i, d in enumerate(dirs)}
    data_off = 32 + 4 * entries
    first = block_index(track, file, subfile, 0)

    pos = []
    for i in range(nblocks):
        base = data_off + slot[first + i] * HW_PER_BLOCK * 2
        pos.extend(base + 2 * h for h in range(HW_PER_BLOCK))
    def get(k): return (raw[pos[k]] << 8) | raw[pos[k] + 1]
    def put(k, v):
        raw[pos[k]] = (v >> 8) & 0xff
        raw[pos[k] + 1] = v & 0xff

    content = a.lb_len - 2
    lb = None
    for k in range(0, len(pos) - a.lb_len):
        if (sum(get(k + i) for i in range(content)) & 0xffff) == get(k + content + 1):
            lb = k
            break
    if lb is None:
        sys.exit("could not find the SSL load block by its checksum tail")

    print("  FIOMUWB2 -> %#07x  (sector %d, offset %#06x)"
          % (a.addr, a.addr >> 15, a.addr & 0x7fff))
    # Both halves of the 16K buffer.  FCMB2ZCN is the fullword after
    # FCMB1ZCN, and addresses FIOMUWB2 + 8192.
    writes = []
    for i, (name, addr) in enumerate((("FCMB1ZCN", a.addr),
                                      ("FCMB2ZCN", a.addr + 8192))):
        off = lb + (a.zcon + 2 * i - a.lb_addr)
        hw0 = 0x8000 | (addr & 0x7fff)
        hw1 = addr >> 15
        print("  %s %#07x : %04X %04X -> %04X %04X"
              % (name, a.zcon + 2 * i, get(off), get(off + 1), hw0, hw1))
        writes.append((off, hw0, hw1))
    if a.dry_run:
        print("  (dry run, nothing written)")
        return
    for off, hw0, hw1 in writes:
        put(off, hw0)
        put(off + 1, hw1)
    tail = sum(get(lb + i) for i in range(content)) & 0xffff
    print("  load-block checksum tail: %04X -> %04X" % (get(lb + content + 1), tail))
    put(lb + content, 0)
    put(lb + content + 1, tail)
    open(a.volume, "wb").write(bytes(raw))
    print("  wrote %s" % a.volume)


if __name__ == "__main__":
    main()
