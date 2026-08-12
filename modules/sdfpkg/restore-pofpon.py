#!/usr/bin/env python3
"""Put back the 35 `$POF` and `$PON` cards the extraction dropped.

WHY THESE AND NOT THE OTHER MISSING INVOCATIONS.  BILDNEW5's listing holds 659
cards our extracted sources do not, and nearly all of them are macro
INVOCATIONS -- ERROR, DCHAR, PDEF, TEXT, POS, FCW2.  Those were dropped on
purpose: the extraction kept each macro's EXPANSION, which the listing prints
right underneath, so restoring the invocation would expand it a second time.

$POF and $PON are the exception, and the reason is one line of each macro:

         MACRO
         $POF
         ...
                                                      PRINT  NOGEN
&R       DS      0H        DEFINE START OF UNPROTECT
                                                      PRINT  GEN
         MEND

PRINT NOGEN kept the generated `$POFnnn DS 0H` OUT of the listing, so there
was no expansion for the extraction to keep and dropping the invocation lost
the label outright.  They are the only two macros in this build that suppress
their own output, which is why they are the only two that have to come back.

WHAT IT COSTS TO LEAVE THEM OUT.  The pairs number 57 in the original and 41
and 38 in ours; TESTING.asm carries the pre-expanded unprotect table, which
names $POF001 through $POF057, so sixteen of its entries reference labels that
were never defined.  That is 630 of BILDNEW5's intolerable lines.

PLACEMENT.  Each missing card is anchored to the nearest preceding listing
card that occurs EXACTLY ONCE across all of the members -- SRNs are not unique
between members, so a unique (SRN, text) pair is the only reliable address --
and inserted directly after it.
"""
import re, os, sys, collections

LISTING = "/mnt/STORAGE/home/rburkey/workspace/PFS/" \
          "OI301700 as received/SSSRC/BILDNEW5"
SRC = os.path.expanduser("~/workspace/PFS/OI301700/SSSRC/BILDNEW5.asm")
SRN = re.compile(r'^\d{6}[A-Z]{2}$')

def cards(path, off):
    out = []
    for i, line in enumerate(open(path, errors='replace')):
        s = "%-118s" % line.rstrip('\n')
        card = s[off:off+80]
        if SRN.match(card[72:80]):
            out.append((card[72:80], card[:71].rstrip(), i))
    return out

def main(mlib, apply):
    listing = cards(LISTING, 37)
    copies = []
    for line in open(SRC, errors='replace'):
        t = "%-71s" % line.rstrip('\n')[:71]
        if t[:1] in ("*", "."):
            continue
        f = t.split()
        if f[:1] == ["COPY"] and len(f) > 1:
            copies.append(f[1])

    files = {}
    where = collections.defaultdict(list)   # (srn,text) -> [(member, lineNo)]
    for m in copies:
        p = os.path.join(mlib, m + ".asm")
        if not os.path.exists(p):
            continue
        files[m] = open(p, errors='replace').read().split("\n")
        for srn, text, i in cards(p, 0):
            where[(srn, text)].append((m, i))

    have = collections.Counter((srn, text) for k in where
                               for (srn, text) in [k] for _ in where[k])
    present = collections.Counter()
    for k, v in where.items():
        present[k] = len(v)

    # Which listing cards are absent from our members, and are $POF/$PON.
    seen = collections.Counter()
    inserts = collections.defaultdict(list)  # member -> [(afterLine, text)]
    anchorless = []
    for idx, (srn, text, _) in enumerate(listing):
        key = (srn, text)
        seen[key] += 1
        if seen[key] <= present[key]:
            continue                       # this card is accounted for
        op = text.split()[:1]
        if op not in (["$POF"], ["$PON"]):
            continue
        # Anchor FORWARD, to the nearest FOLLOWING card that occurs exactly
        # once across all the members, and insert immediately BEFORE it.
        #
        # Anchoring backward is wrong, and PSA is the case that shows it.  The
        # card before `$POF` there is `PSA EX4`, itself a macro call, and the
        # listing prints its EXPANSION -- which emits object code -- between
        # the two.  Inserting straight after the call would put the $POF label
        # ahead of those bytes instead of after them, at an address the
        # original build never gave it.  The next real card is past the whole
        # expansion, so anchoring to it lands the card where it belongs.
        # (Only cards with a genuine six-digit SRN are candidates; generated
        # cards carry an `nn-MACRO` stamp instead and are not in `where`.)
        anchor = None
        for j in range(idx + 1, len(listing)):
            k2 = (listing[j][0], listing[j][1])
            if present[k2] == 1:
                anchor = where[k2][0]
                break
        if anchor == None:
            anchorless.append((srn, text))
            continue
        inserts[anchor[0]].append((anchor[1] - 1, srn, text))

    total = 0
    for m in sorted(inserts):
        lines = files[m]
        # Insert from the bottom up so earlier line numbers stay valid.
        for afterLine, srn, text in sorted(inserts[m], reverse=True):
            card = "%-71s %s" % (text, srn)
            lines.insert(afterLine + 1, card.rstrip())
            total += 1
        print("  %-10s %3d card(s)" % (m, len(inserts[m])))
        for afterLine, srn, text in sorted(inserts[m]):
            print("        after line %-6d %s  %s" % (afterLine + 1, srn, text.strip()))
        if apply:
            open(os.path.join(mlib, m + ".asm"), "w").write("\n".join(lines))
    print("TOTAL %d card(s)%s" % (total, "" if apply else "  (dry run)"))
    if anchorless:
        print("NO ANCHOR FOUND for %d card(s):" % len(anchorless))
        for c in anchorless:
            print("   ", c)
    return 0

if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    sys.exit(main(args[0], "--apply" in sys.argv))
