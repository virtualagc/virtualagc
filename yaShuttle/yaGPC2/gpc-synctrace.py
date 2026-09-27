#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   gpc-synctrace.py
Purpose:    Decode the flight software's OWN sync trace (FCMTRACE's cyclic
            table, FCMTRCLG) out of a captured memory image, for every
            computer in a capture, side by side.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      gpc-synctrace.py CAPTURE-DIR [augmented-XX.json]
            gpc-synctrace.py yaGPC2.log  [augmented-XX.json]

CAPTURE-DIR holds gpcN.mem.bin (big-endian halfwords, as the emulator dumps
them).  A log is read for the FCMTRACE lines the emulator writes into its
failure record, which are the same table taken at the moment of the failure.
The second argument names the memory configuration's CSECT map; the default
is ~/workspace/PFS/mafgen/augmented-G2.json.

WHY THIS EXISTS.  FCMTRACE logs every SVC, I/O completion and timer interrupt
that goes through a sync point -- time, old PSW, detail, and the SVC number --
into a table of 50 entries, and FCMSFAIL STOPS THE TRACE when a computer fails
another (it zeroes the address-modification word at TPSATENT+1, so the entry
pointer no longer advances).  A capture taken at any time afterwards therefore
still holds the 50 events that led to the failure, in each computer, in the
flight software's own words.  That is what showed that a failed computer had
executed one SVC twice and was one SVC behind its neighbours (ledger #253),
which no amount of bus tracing could have.

The table's address comes from the image itself: TPSATENT, TPSATBGN and
TPSATEND at PSA 0008, 000A and 000B.  They are 16-bit addresses in sector 3,
so the table is at 0x10000 + address (FCMTRCLG, 1c99c in OI-34 G2 and G9).
An entry's time is the 30-minute portion of the software clock, in
microseconds; its old PSW gives the return address as NIA in the upper half
and the BSR in bits 24-27.
'''
import sys, os, struct, json

SECTOR = 0x10000
KIND = {1: 'SVC', 2: 'I/O', 3: 'PC2'}

def load_map(path):
    aug = json.load(open(path))
    return sorted((v['start'], v['end'], n) for n, v in aug.items()
                  if isinstance(v, dict) and v.get('start') is not None)

def where(spans, a):
    for s, e, n in spans:
        if s <= a <= e:
            return "%s+%04x" % (n, a - s)
    return "%05x" % a

def phys(psw1):
    nia = psw1 >> 16
    bsr = (psw1 >> 4) & 0xf
    return nia if nia < 0x8000 else bsr * 0x8000 + (nia - 0x8000)

def table(path):
    raw = open(path, 'rb').read()
    hw = lambda a: struct.unpack('>H', raw[2 * a:2 * a + 2])[0]
    ent, mod, bgn, end = hw(8), hw(9), hw(10), hw(11)
    rows = []
    for a in range(bgn, end, 8):
        w = [hw(SECTOR + a + i) for i in range(8)]
        rows.append((a, (w[0] << 16) | w[1], (w[2] << 16) | w[3],
                     (w[4] << 16) | w[5], w[6], w[7]))
    return ent, mod, rows

def tables_from_log(path):
    import re
    out = {}
    head = re.compile(r'FCMTRACE GPC(\d) table \w+-\w+ sector \d+ next (\w+) (\w+)')
    row = re.compile(r'FCMTRACE GPC(\d) (\w{4}) t=(\d+) psw1=(\w{8}) detail=(\w{8}) id=(\d+) svc=(\d+)')
    for l in open(path, errors='replace'):
        m = head.match(l)
        if m:
            out[int(m.group(1))] = [int(m.group(2), 16), 0 if m.group(3) == 'STOPPED' else 8, []]
            continue
        m = row.match(l)
        if m and int(m.group(1)) in out:
            out[int(m.group(1))][2].append((int(m.group(2), 16), int(m.group(3)),
                                            int(m.group(4), 16), int(m.group(5), 16),
                                            int(m.group(6)), int(m.group(7))))
    return out

def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    d = sys.argv[1]
    spans = load_map(sys.argv[2] if len(sys.argv) > 2 else
                     os.path.expanduser('~/workspace/PFS/mafgen/augmented-G2.json'))
    logged = tables_from_log(d) if os.path.isfile(d) else None
    for g in range(1, 6):
        if logged is not None:
            if g not in logged:
                continue
            ent, mod, rows = logged[g]
        else:
            p = os.path.join(d, "gpc%d.mem.bin" % g)
            if not os.path.exists(p):
                continue
            ent, mod, rows = table(p)
        state = "STOPPED (a failure froze it)" if mod == 0 else "running"
        print("--- GPC%d: trace %s, next entry %04x" % (g, state, ent))
        # Oldest first.  A stopped trace keeps overwriting the entry at the
        # pointer, so that one is the latest event and not part of the story.
        order = [r for r in rows if r[0] > ent] + [r for r in rows if r[0] < ent]
        if mod != 0:
            order = [r for r in rows if r[0] >= ent] + [r for r in rows if r[0] < ent]
        ssip = [i for i, r in enumerate(order) if r[4] == 3 and (r[3] & 0xffff) == 1]
        base = order[ssip[-1]][1] if ssip else order[-1][1]
        for a, t, psw1, det, tid, svc in order:
            kind = KIND.get(tid, '?%d' % tid)
            if tid == 1:
                kind = 'SVC%3d' % svc
            print("   %10.2f ms  %-6s %-20s psw1=%08x detail=%08x"
                  % ((t - base) / 1e3, kind, where(spans, phys(psw1)), psw1, det))

if __name__ == '__main__':
    main()
