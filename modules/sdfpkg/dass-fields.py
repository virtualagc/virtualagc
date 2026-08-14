#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   dass-fields.py
Purpose:    Recover the addresses of FIELDS INSIDE HAL/S COMPOOLs from HALSTAT,
            and add them to a CSECT index so lnk101 can resolve them.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      dass-fields.py --config=XXX [--base=F.json] [--out=F.json]
                           [--halstat=F.ASC] [--report] [--verify=F.json:F.fcm]

THE PROBLEM, which is dass-syms.py's problem one level finer.  That script
recovers a COMPOOL's CSECT ADDRESS.  augmented-XXX.json then indexes the
COMPOOL as a single span, and a reference to a FIELD inside it -- which is what
the FCOS assembly actually makes -- still resolves to nothing.  lnk101 reports
the symbol undefined, compileLinkCompare falls back to a forced link, and every
such reference is left as the assembled 0000 while the dump holds a real
address.  FCMBMTG9 alone has 117 of them and they are 116 of its 117 differing
halfwords.

    This is not a small tail.  A forced link is also the reason a whole module
    is reported FAIL rather than compared, so these references cost far more
    than their own count.

THE SOURCE, AND IT IS NOT THE DUMP.  HALSTAT gives every EQUATEd label its
CSECT and its offset within it:

     31879  TFIVMI12                 EQUATE      LABEL    C O M P O O L   ...
                (EQUATED TO: CGBV_MFF_SEG1   UNIT/BLOCK: ...)
                (CSECT: #PCGBIM1 OFFSET: 00002A) PHASE 2 ADDR: 003C50 ...

An EQUATE LABEL is exactly the mechanism by which a HAL/S COMPOOL field gets an
eight-character name an assembly EXTRN can name, so this is the right record
and not an approximation of one.

    RECOVERING FROM THE DUMP INSTEAD WOULD PROVE NOTHING.  The obvious
    alternative is to read the value the original build left at each reference
    site and call that the symbol's address.  It is mechanical, every site
    carries a relocation pointing at it, and IT IS CIRCULAR: the site then
    matches the dump by construction, and the comparison that is supposed to
    be evidence has been fitted to its own answer.  HALSTAT is a compiler
    artifact and owes the dump nothing, which is what makes the agreement
    below worth quoting.

PHASE LABELS ARE NOT USED.  HALSTAT also prints a per-phase ADDR, but a phase
is not a configuration -- dass-syms.py's header sets out why the mapping is
approximate and several phases serve more than one configuration.  None of
that is needed here: the CSECT's start address IN THIS CONFIGURATION is
already in the index, so

        field address = index[CSECT].start + HALSTAT offset

is computed entirely within the configuration being built and never consults a
phase.  Where the CSECT is absent from this configuration the field is skipped,
which is correct -- the COMPOOL is not in this build.

MEASURED, G9, against FCMBMTG9's 117 unresolved relocations: 81 are EQUATE
LABELs HALSTAT carries, 80 of those name a CSECT the configuration has, and ALL
80 PREDICT THE DUMP'S OWN VALUE EXACTLY.  Zero disagree.  Use --verify to
re-run that check for any configuration and module.

    The other 36 are FIOBY* -- assembly entry points, not COMPOOL fields, and
    a different gap that this script does not address and does not pretend to.
'''

import sys, os, re, json, collections
from pathlib import Path

DEFAULT_HALSTAT = Path("~/workspace/PFS/HALSTAT.ASC").expanduser()
DEFAULT_MAFGEN = Path("~/workspace/PFS/mafgen").expanduser()

# `31879  TFIVMI12   EQUATE   LABEL   C O M P O O L  ...`, the header line of a
# symbol's block.  The number is HALSTAT's own symbol index and is not used.
SYMBOL_LINE = re.compile(r'^\s*\d+\s+([A-Z0-9#$@]{1,8})\s+EQUATE\s+LABEL\b')
# `(CSECT: #PCGBIM1 OFFSET: 00002A)`, which may be followed on the same line by
# SIZE and any number of PHASE n ADDR fields.  Only the first two are read.
CSECT_LINE = re.compile(r'\(CSECT:\s+(\S+)\s+OFFSET:\s+([0-9A-Fa-f]+)\)')
# A blank-ish continuation belongs to the symbol above it; a new symbol header
# ends the block.  Nothing else in the block is needed.


def scanHalstat(path):
    '''Every EQUATE LABEL that carries a CSECT and an offset, as
    {name: (csect, offset)}.  HALSTAT is ~100MB and is read once, in one pass,
    holding no more than the current symbol name.

    A NAME MAY APPEAR MORE THAN ONCE and that is ordinary rather than a fault:
    the same label is EQUATEd in several compilations, against the COMPOOL that
    the build in question actually carries.  So EVERY candidate is kept and the
    CONFIGURATION resolves them -- see `resolve` -- instead of the last one
    read winning by accident.  TFIVAN11-14 and TFIVPF12 are of this kind, and
    taking the last would have been right only by luck.'''
    out = collections.defaultdict(set)
    current = None
    with open(path, errors="replace") as f:
        for line in f:
            m = SYMBOL_LINE.match(line)
            if m:
                current = m.group(1)
                continue
            if current is None:
                continue
            m2 = CSECT_LINE.search(line)
            if m2:
                out[current].add((m2.group(1), int(m2.group(2), 16)))
                current = None
    return out


def resolve(name, candidates, index):
    '''Which of a name's EQUATE records applies to THIS configuration, as
    (csect, offset), or None with a reason.

    The configuration is the discriminator.  A label EQUATEd in five
    compilations names five COMPOOLs, and at most one of them is in this
    build; where exactly one is, there is nothing to choose.  Where more than
    one is, they are accepted only if they land on the SAME ADDRESS, which
    happens when a COMPOOL is indexed under more than one name.  Anything left
    genuinely ambiguous is skipped and reported, never guessed.'''
    live = [(c, o) for c, o in candidates
            if c in index and "start" in index[c]]
    if not live:
        return None, "CSECT absent from this configuration"
    if len(live) == 1:
        return live[0], None
    addresses = {index[c]["start"] + o for c, o in live}
    if len(addresses) == 1:
        return sorted(live)[0], None
    return None, "ambiguous: %s" % ", ".join(
        "%s+%X" % (c, o) for c, o in sorted(live))


def main():
    config = None
    base = out = None
    halstat = DEFAULT_HALSTAT
    report = False
    verify = None
    for p in sys.argv[1:]:
        if p.startswith("--config="): config = p.partition("=")[2]
        elif p.startswith("--base="): base = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--out="): out = Path(p.partition("=")[2]).expanduser()
        elif p.startswith("--halstat="): halstat = Path(p.partition("=")[2]).expanduser()
        elif p == "--report": report = True
        elif p.startswith("--verify="): verify = p.partition("=")[2]
        elif p in ("--help", "-h"):
            print(__doc__)
            return 0
        else:
            sys.exit("unknown parameter %s" % p)
    if not config:
        print(__doc__)
        return 1
    if base is None:
        base = DEFAULT_MAFGEN / ("augmented-%s.json" % config)
    if not base.is_file():
        sys.exit("missing %s" % base)
    if not Path(halstat).is_file():
        sys.exit("missing %s" % halstat)

    index = json.load(open(base))
    fields = scanHalstat(halstat)
    multi = sum(1 for v in fields.values() if len(v) > 1)
    print("%s: %d EQUATE LABEL(s) in HALSTAT carry a CSECT and offset "
          "(%d of them EQUATEd in more than one compilation)"
          % (config, len(fields), multi), file=sys.stderr)

    added = skippedNoCsect = ambiguous = 0
    alreadyAgree = alreadyDiffer = 0
    differing = []
    for name, candidates in sorted(fields.items()):
        chosen, why = resolve(name, candidates, index)
        if chosen is None:
            if why.startswith("ambiguous"):
                ambiguous += 1
                if report:
                    print("   ambiguous, skipped: %-9s %s"
                          % (name, why[11:]), file=sys.stderr)
            else:
                skippedNoCsect += 1
            continue
        csect, offset = chosen
        entry = index[csect]
        contents = entry.setdefault("contents", {})
        if name in contents:
            # THE INDEX WINS AND THE DISAGREEMENT IS REPORTED.  Where MAFGEN
            # already recovered this name, that is a reading of the build we
            # are comparing against; HALSTAT is the fallback, exactly as it is
            # in dass-syms.py.  A disagreement is worth seeing rather than
            # resolving quietly, because it means one of the two is describing
            # a different build.
            if contents[name] == offset:
                alreadyAgree += 1
            else:
                alreadyDiffer += 1
                differing.append((name, csect, contents[name], offset))
            continue
        contents[name] = offset
        added += 1

    print("   added %d field symbol(s); %d already indexed and agreeing, "
          "%d already indexed and DIFFERING; %d skipped, CSECT not in %s; "
          "%d left ambiguous" % (added, alreadyAgree, alreadyDiffer,
                                 skippedNoCsect, config, ambiguous),
          file=sys.stderr)
    for name, csect, was, now in differing[:20]:
        print("      %-9s %-9s index %06X vs HALSTAT %06X"
              % (name, csect, was, now), file=sys.stderr)

    if verify:
        rc = doVerify(verify, index, fields)
        if rc:
            return rc

    if out:
        json.dump(index, open(out, "w"), indent=1)
        print("-> %s" % out, file=sys.stderr)
    elif report:
        pass
    else:
        print("(no --out given; nothing written)", file=sys.stderr)
    return 0


def doVerify(spec, index, fields):
    '''--verify=LINK.json:IMAGE.fcm -- for every unresolved relocation in a
    link, compare the address this recovery gives against the value the
    ORIGINAL build left at that site.  This is the check that makes the
    recovery evidence rather than assertion, and it is the reason the offsets
    are taken from HALSTAT and not from the image being compared against.'''
    linkPath, _, imagePath = spec.partition(":")
    if not imagePath:
        sys.exit("--verify needs LINK.json:IMAGE.fcm")
    link = json.load(open(linkPath))
    image = open(imagePath, "rb").read()
    tally = collections.Counter()
    wrong = []
    for u in link.get("unresolvedRelocations", []):
        name = u["symbol"]
        hw = u["imageOffsetHW"]
        if hw * 2 + 2 > len(image):
            tally["site beyond the image"] += 1
            continue
        want = int.from_bytes(image[hw * 2:hw * 2 + 2], "big")
        if name not in fields:
            tally["not an EQUATE LABEL in HALSTAT"] += 1
            continue
        chosen, why = resolve(name, fields[name], index)
        if chosen is None:
            tally[why if why.startswith("CSECT") else "left ambiguous"] += 1
            continue
        csect, offset = chosen
        got = index[csect]["start"] + offset
        if want == 0:
            # THE ORIGINAL LEFT IT UNRESOLVED TOO.  Nothing to check against,
            # and emitting an address here would be a NEW disagreement rather
            # than a fix; see the TFIVMCI1 case in the handoff.
            tally["dump holds 0000; original did not resolve it either"] += 1
        elif got == want:
            tally["PREDICTS THE DUMP EXACTLY"] += 1
        else:
            tally["DISAGREES WITH THE DUMP"] += 1
            wrong.append((name, csect, got, want))
    print("\nverify %s" % linkPath, file=sys.stderr)
    for k, v in tally.most_common():
        print("   %-46s %d" % (k, v), file=sys.stderr)
    for name, csect, got, want in wrong[:20]:
        print("      %-9s %-9s recovered %05X but the dump holds %05X"
              % (name, csect, got, want), file=sys.stderr)
    return 1 if wrong else 0


if __name__ == "__main__":
    sys.exit(main())
