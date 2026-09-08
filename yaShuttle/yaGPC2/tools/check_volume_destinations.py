#!/usr/bin/env python3
"""Reject a mass-memory volume whose load blocks write over resident memory.

    check_volume_destinations.py <volume.mmv> [--mafgen DIR] [--phase T/F/S:N]
                                [--verbose]

WHAT THIS CATCHES, AND WHY IT IS WORTH A TOOL.

Memory configuration G9 never came up, and a session went into finding out
why.  The answer was that phase 8 on our volume carries two load blocks whose
bodies are ENTIRELY FILL -- 0 of 508 non-fill halfwords each -- declaring
destinations 0x080F8 and 0x081F8 for 0x0E20 halfwords apiece.  Both spans are
resident memory.  FCMCBLKS (0x0811A-0x08B89) is inside the first, and with it
FCMMGIOS and FCMMGEVT, the I/O SVC parameter list and the completion event.
Loading phase 8 therefore DMA'd 7232 halfwords of filler over live FCOS,
destroying the event while FCMMGPOV was blocked in `SVC FCMMGWAT` waiting on
it.  The visible symptom, three layers up, was "phase 18 is never requested".

The blocks have no correct destination because they have no content.  They are
lnk101's hole fill: `dass-phases.sh` links each phase with `--external-syms
--allow-undefined`, which produces a COMPLETE IMAGE rather than a load module,
so what the phase does not supply is filled and becomes indistinguishable from
what it does.  `mmu2mmv` then writes the filler to tape and the flight software
faithfully loads it.  See HANDOFF-OI340600 on con80build for the real fix; this
is the cheap check that says a volume has the problem without booting it.

HOW RESIDENT MEMORY IS DECIDED, without needing a memory map.

Not from a list anyone maintains: from the eight DASS images themselves.  A
halfword that is identical in SSW, G9, G8, G2, G3, G16, P9 and S2 is one no
configuration overlays -- 36.4% of memory, against 63.6% that varies.  Every
module in the overlay chain lands in the invariant set with ZERO varying
halfwords: FCMCBLKS, FCMMGPOV, FCMMGBOV, FIOSVC, FIOMGCMP, FIOMGMTR, FPMIHPC2,
FCMPSA.  That is the design -- the loader and its control blocks live where no
phase writes -- and it makes "destination inside the invariant set" a sound
rejection rule rather than a heuristic.

SCOPE, STATED PLAINLY.  This recognises ONE load-block header form, the one
that appears at the head of an MM block as (dest, length, 0, dest+length).
Blocks in other forms are counted and skipped, not interpreted: a clean report
means "nothing of the recognised kind is aimed at resident memory", not "this
volume is correct".  Widening it needs the load-block format settled, which it
is not.
"""

import argparse
import os
import struct
import sys

import numpy as np

CFGS = ("SSW", "G9", "G8", "G2", "G3", "G16", "P9", "S2")
FILL = (0x0000, 0xC6C6, 0xC9FB)
HW_PER_BLOCK = 512


def resident_mask(mafgen):
    """Halfwords identical across all eight configurations."""
    imgs = []
    for c in CFGS:
        p = os.path.join(mafgen, "%s.fcm" % c)
        if not os.path.exists(p):
            sys.exit("%s is missing; --mafgen must name the mafgen directory "
                     "holding the eight <cfg>.fcm images" % p)
        imgs.append(np.fromfile(p, dtype=">u2"))
    n = min(len(a) for a in imgs)
    varies = np.zeros(n, dtype=bool)
    for a in imgs[1:]:
        varies |= (a[:n] != imgs[0][:n])
    return ~varies


def load_volume(path):
    raw = open(path, "rb").read()
    if raw[:8] != b"MMUVOL01":
        sys.exit("%s is not an MMUVOL01 volume" % path)
    hw, entries, _ = struct.unpack(">III", raw[8:20])
    if hw != HW_PER_BLOCK:
        sys.exit("%s: unexpected block size %d" % (path, hw))
    dirs = struct.unpack(">%dI" % entries, raw[32:32 + 4 * entries])
    return raw, {v: i for i, v in enumerate(dirs)}, 32 + 4 * entries


def block(raw, slot, data_off, idx):
    if idx not in slot:
        return None
    o = data_off + slot[idx] * HW_PER_BLOCK * 2
    return np.frombuffer(raw, dtype=">u2", count=HW_PER_BLOCK,
                         offset=o).astype(np.uint32)


def parse_tfsb(spec):
    """'T/F/S:N' -> (linear first block, count)."""
    try:
        addr, count = spec.split(":")
        t, f, s = (int(x) for x in addr.split("/"))
    except ValueError:
        sys.exit("--phase wants T/F/S:N, e.g. 2/5/4:110")
    return ((((f & 7) * 8 + (t & 7)) * 8 + (s & 7)) * 32, int(count))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("volume")
    ap.add_argument("--mafgen", default=os.path.expanduser(
        "~/workspace/PFS/mafgen"))
    ap.add_argument("--phase", action="append", default=[], metavar="T/F/S:N",
                    help="a phase's first block and block count; repeatable.  "
                         "With none given, every block on the volume is "
                         "examined.")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()

    resident = resident_mask(a.mafgen)
    print("resident (never-varying) halfwords: %d of %d (%.1f%%)"
          % (int(resident.sum()), len(resident),
             100.0 * resident.sum() / len(resident)))

    raw, slot, data_off = load_volume(a.volume)
    if a.phase:
        spans = [parse_tfsb(s) for s in a.phase]
    else:
        spans = [(min(slot), max(slot) - min(slot) + 1)]

    examined = recognised = fillonly = 0
    findings = []
    for first, count in spans:
        for b in range(count):
            x = block(raw, slot, data_off, first + b)
            if x is None:
                continue
            examined += 1
            dest, ln, zero, cks = (int(v) for v in x[:4])
            # The one header form this tool claims to understand.
            if zero != 0 or ln == 0 or ((dest + ln) & 0xFFFF) != cks:
                continue
            if dest in FILL:
                continue
            recognised += 1
            body = x[4:]
            empty = not np.isin(body, FILL, invert=True).any()
            if empty:
                fillonly += 1
            hi = min(dest + ln, len(resident))
            if dest >= len(resident):
                continue
            res = int(resident[dest:hi].sum())
            if res:
                findings.append((first + b, dest, ln, res, hi - dest, empty))
            elif a.verbose:
                print("   ok   block %-6d dest %05X len %04X" % (first + b,
                                                                 dest, ln))

    print("blocks examined %d, headers recognised %d, of which fill-only %d"
          % (examined, recognised, fillonly))
    if not findings:
        print("\nNo recognised load block is aimed at resident memory.")
        return 0
    print("\n%d LOAD BLOCK(S) WRITE INTO RESIDENT MEMORY:" % len(findings))
    for blk, dest, ln, res, tot, empty in findings:
        print("   block %-6d dest %05X len %04X   resident %d/%d%s"
              % (blk, dest, ln, res, tot,
                 "   BODY IS ENTIRELY FILL" if empty else ""))
    print("\nA block whose body is entirely fill has no correct destination: "
          "it has no content.\nIt is link-editor hole fill that reached the "
          "tape because the phase was cut\nfrom a whole-image link rather than "
          "built as a load module.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
