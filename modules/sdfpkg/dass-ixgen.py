#!/usr/bin/env python3
"""Rebuild an OI340700 payload-index compool from a DASS memory dump.

    dass-ixgen.py CS2IX3 CS2IX7 ...      write OI340700/APPLSRC/<stem>.hal
    dass-ixgen.py --report CS2IX3 ...    resolve only; write nothing

WHAT THESE FILES ARE, AND WHY THEY CANNOT SIMPLY BE COPIED

CS2IX2..CS2IX7 and CS2IXP are payload indexes: a compool holding nothing but
an array of NAME pointers, each aimed at one field of one payload data table.
The payload set is MISSION-DEPENDENT, and OI340700's differs from OI340600's,
so both the length of each index and the target of every entry change between
the releases.  Compiling OI340600's copy under OI340700 fails, because it
names payloads that release does not declare.

HOW THE DUMP ANSWERS IT

The dump lists every halfword with the CSECT, structure and field it belongs
to, so the index can be read straight out of memory:

    1.  Walk #P<stem> in offset order.  Each entry is a NAME whose printed
        value IS the address it points at:

  0048F0   #PCS2IX3+0000  CSAS_IXP_PDT_PTR   C49C   NAME  BIT STRING TERMINAL

    2.  Look that address up.  Two lines cover it -- the STRUCTURE line gives
        the payload, the TERMINAL line at that exact halfword gives the field:

  00C49C-00C49E  #PCSAPDT+145C  CSAS_PDT_451145         STRUCTURE  VARIABLE
  00C49C         #PCSAPDT+145C  CSAS_PDTA_STAT   4109   BIT STRING TERMINAL

    3.  Those two names are the initializer:
        NAME(CSAS_PDT_451145.CSAS_PDTA_STAT)

Everything outside the initializer list -- the preamble, the DECLARE, the
change-history block -- is taken from OI340600 unchanged.

THREE THINGS THAT ARE NOT OBVIOUS FROM THE DUMP, ALL LEARNED BY GETTING THEM
WRONG FIRST

Payload structures are NOT all CSAS_PDT_<digits>.  Fourteen carry a trailing
letter (CSAS_PDT_450120C) and one a suffix (CSAS_PDT_742622_A).  What must be
excluded is the sub-structures, and those are exactly the _FDA and _LIM
forms -- 755 and 553 of them -- so PAYLOAD matches by excluding that pair of
words rather than by guessing a shape.  A pattern of ^CSAS_PDT_\\d+$ silently
drops real entries.

A pointer value of 0000 is a GENUINE NULL, not a pointer to CSAS_PDT_DUMMY.
The dummy has a real address and appears as an ordinary target elsewhere in
the same lists.  Trailing nulls are emitted as n#(NULL), the form OI340600
uses for its own.

The grouping comments OI340600 interleaves through the list ("*** HALF HERTZ
- CYCLE 3 ***", rows of dashes) are NOT RECOVERABLE.  The dump records values,
not comments.  They are omitted, and each generated header says so."""

import io, re, sys, os, collections

from dasspfs import pfsDir

HERE = pfsDir()
DUMP = os.path.join(HERE, "mafgen", "DASS_S2.ASC")
SRC6 = os.path.join(HERE, "OI340600", "APPLSRC", "%s.hal")
DST7 = os.path.join(HERE, "OI340700", "APPLSRC", "%s.hal")

LINE = re.compile(r'^\s*([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+#P(\S+?)\+([0-9A-F]{4})\s+(\S+)\s*(.*)$')
HEAD = re.compile(r'^ ([0-9A-F]{6})-([0-9A-F]{6})\s+#P(\S+)\s+\*\*\*\*')
INIT = re.compile(r'^ \((\d+)\)\s+INITIAL\(\s*$')
PAYLOAD = re.compile(r'^CSAS_PDT_(?!.*_(FDA|LIM)$)\w+$')


# MAFGEN paginates the listing, and a page break can fall INSIDE a structure --
# between an ARRAY member and the two continuation lines carrying its values.
# Any lookahead by line offset then lands on the banner instead of the data.
# Strip the furniture once, at load, so no parser has to know about it.
FURNITURE = re.compile(r'^(\+\s*$|1M A F G E N|[0-9A-F]*\s+M E M O R Y   M A P|\s*$)')


def dump_lines(path=DUMP):
    return [x for x in (l.rstrip("\r\n") for l in io.open(path, errors="replace"))
            if not FURNITURE.match(x)]



def load(path=DUMP):
    """(terminals by address, structure ranges, CSECT extents) from a dump."""
    terms = collections.defaultdict(list)
    strus, ext = [], {}
    for l in dump_lines(path):
        h = HEAD.match(l)
        if h:
            ext.setdefault(h.group(3), "%s-%s" % (h.group(1), h.group(2)))
        m = LINE.match(l)
        if not m:
            continue
        a1, a2, cs, off, name, tail = m.groups()
        if "STRUCTURE" in tail and a2:
            strus.append((int(a1, 16), int(a2, 16), name, cs))
        else:
            v = re.match(r'\s*([0-9A-F]{4})\b', tail)
            terms[int(a1, 16)].append(
                (name, cs, int(v.group(1), 16) if v else None, " NAME " in tail))
    return terms, strus, ext


def members(terms, csect):
    """The CSECT's NAME pointers, in offset order."""
    out = []
    for a, lst in terms.items():
        for name, cs, val, isname in lst:
            if cs == csect and isname and val is not None:
                out.append((a, name, val))
    return sorted(out)


def resolve(terms, strus, ptr):
    """(payload, field, offending sub-structure) a pointer value designates."""
    field = terms.get(ptr, [(None,) * 4])[0][0]
    cover = [s for s in strus if s[0] <= ptr <= s[1]]
    cands = [s for s in cover if PAYLOAD.match(s[2])]
    if not cands:
        # A pointer need not aim at a payload at all: CSAPCT's SOL_BLOCK
        # entries point into the CS2_IPT compool, and OI340600 writes those
        # the same way -- NAME(CSAS_IPT_920601.CSAS_IPT_STATUS).  Fall back to
        # the innermost structure covering the address, whatever it belongs to.
        cands = cover
    subs = [s for s in cover
            if s[2].startswith("CSAS_PDT_") and not PAYLOAD.match(s[2])]
    return (min(cands, key=lambda s: s[1] - s[0])[2] if cands else None,
            field, subs[0][2] if subs else None)


def card(text, srn, code):
    if len(text) > 72:
        raise SystemExit("card overflows column 72: %r" % text)
    return text.ljust(72) + "%06d" % srn + code


def build(stem, terms, strus):
    """(new lines, old count, resolved count, trailing nulls)."""
    inits = []
    for a, name, ptr in members(terms, stem):
        if ptr == 0:
            inits.append(None)
            continue
        st, f, sub = resolve(terms, strus, ptr)
        if sub:
            raise SystemExit("%s: pointer %04X lands inside sub-structure %s; "
                             "payload.field is not enough qualification"
                             % (stem, ptr, sub))
        if not (st and f):
            raise SystemExit("%s: pointer %04X at %06X does not resolve "
                             "(structure=%s field=%s)" % (stem, ptr, a, st, f))
        inits.append("NAME(%s.%s)" % (st, f))
    if not inits:
        raise SystemExit("%s: no NAME pointers found in the dump" % stem)

    ntrail = 0
    while inits and inits[-1] is None:
        inits.pop()
        ntrail += 1
    if None in inits:
        raise SystemExit("%s: a null pointer appears mid-list; not handled"
                         % stem)

    src = io.open(SRC6 % stem, errors="strict").read().split("\n")
    try:
        ii = next(i for i, l in enumerate(src) if INIT.match(l[:72].rstrip()))
    except StopIteration:
        raise SystemExit("%s: no '(N)   INITIAL(' card in the OI340600 source"
                         % stem)
    ci = next(i for i in range(ii, len(src)) if ");" in src[i])
    old = int(INIT.match(src[ii][:72].rstrip()).group(1))
    srn, code = int(src[ii][72:78]), src[ii][78:80]

    body = [card(" (%d)   INITIAL(" % (len(inits) + ntrail), srn, code)]
    for k, t in enumerate(inits):
        srn += 2
        last = (k == len(inits) - 1) and ntrail == 0
        body.append(card(" %s%s" % (t, " );" if last else ","), srn, code))
    if ntrail:
        srn += 2
        body.append(card("   %d#(NULL) );" % ntrail, srn, code))
    return src[:ii] + body + src[ci + 1:], old, len(inits), ntrail



# ---------------------------------------------------------------------------
# CS2PX2: a run of individually DECLAREd 4-halfword CSAS_PXT_<parmid> entries,
# not a flat pointer array.  Six bit-packed flags, a 24-bit PARMID, and two
# NAME pointers.  Two templates are in play and the members say which:
# CSAS_PXT_ANA_EU carries PARM_PTR/CONC_PTR, CSAS_PXT_DISC carries
# PARENT_PTR/DISC_PTR.
#
# DISC_PTR is the reason a plain payload.field resolver reports these as
# unresolved: it aims at a _FDA SUB-STRUCTURE AS A WHOLE, and OI340600 writes
# it with no field at all -- NAME(CSAS_PDT_612557_FDA).

PXT_STRU = re.compile(r'^ ([0-9A-F]{6})-([0-9A-F]{6})\s+#P%s\+([0-9A-F]{4})\s+(CSAS_PXT_\w+)\s+STRUCTURE')
PXT_MEMB = re.compile(r'^ ([0-9A-F]{6})(?:-[0-9A-F]{6})?\s+#P%s\+([0-9A-F]{4})\s+(CSAS_\S+)\s+(.*)$')
PXT_CONT = re.compile(r"^ [0-9A-F]{6}(?:-[0-9A-F]{6})?\s+#P\S+\+[0-9A-F]{4}\s+[0-9A-F ]+\s+(BIN'[01]+')")
FLAGS = ["CSAS_PXT_INTERPROCESS", "CSAS_PXT_GPCF", "CSAS_PXT_FDA",
         "CSAS_PXT_CONCURRENT", "CSAS_PXT_DISCRETE", "CSAS_PXT_OPS_UNIQUE"]


def pxt_entries(stem, path=DUMP):
    """The CSECT's CSAS_PXT_* structures, in address order, with member values."""
    stru = re.compile(PXT_STRU.pattern % stem)
    memb = re.compile(PXT_MEMB.pattern % stem)
    L = dump_lines(path)
    copy = re.compile(r'^ ([0-9A-F]{6})(?:-[0-9A-F]{6})?\s+\+\+\+ COPY \d+ OF (\d+)')
    ents, cur = [], None
    for i, l in enumerate(L):
        m = stru.match(l)
        if m:
            cur = {"name": m.group(4), "m": {}, "copies": 1,
                   "lo": int(m.group(1), 16),
                   "hi": int(m.group(2) or m.group(1), 16)}
            ents.append(cur)
            continue
        c = copy.match(l)
        # A COPY marker carries no CSECT name, so it must be bounded by the
        # structure's own address range -- otherwise the last structure of the
        # CSECT collects a marker from somewhere else entirely in the dump.
        if c and cur is not None and cur["lo"] <= int(c.group(1), 16) <= cur["hi"]:
            cur["copies"] = int(c.group(1 + 1))
            continue
        m = memb.match(l)
        if not (m and cur is not None):
            continue
        nm, tail = m.group(3), m.group(4)
        if nm.endswith("_PTR"):
            v = re.match(r'\s*([0-9A-F]{4})\s', tail)
            cur["m"][nm] = ("PTR", int(v.group(1), 16) if v else None)
        else:
            d = re.search(r"BIN'([01]+)'|(\bTRUE\b)|(\bFALSE\b)", tail)
            if d:
                val = d.group(1) if d.group(1) is not None else ("TRUE" if d.group(2) else "FALSE")
            else:                      # long BIN spills onto a continuation line
                c = PXT_CONT.match(L[i + 1] if i + 1 < len(L) else "")
                val = c.group(1)[4:-1] if c else None
            cur["m"][nm] = ("VAL", val)
    return ents


def pxt_pointer(terms, strus, ptr, whole):
    """Render one NAME initializer.  `whole` asks for the sub-structure itself."""
    if ptr == 0:
        return "NULL"
    st, f, sub = resolve(terms, strus, ptr)
    if whole:
        if not sub:
            raise SystemExit("DISC_PTR %04X does not land in a sub-structure" % ptr)
        start = min((s for s in strus if s[2] == sub), key=lambda s: s[0])[0]
        if start != ptr:
            raise SystemExit("DISC_PTR %04X is not the start of %s" % (ptr, sub))
        return "NAME(%s)" % sub
    if not (st and f):
        raise SystemExit("pointer %04X does not resolve (structure=%s field=%s)"
                         % (ptr, st, f))
    return "NAME(%s.%s)" % (st, f)



def pxt_scalar(stem, name, path=DUMP):
    """A named SP INTEGER terminal of #P<stem>, as the dump prints it."""
    pat = re.compile(r'^ [0-9A-F]{6}\s+#P%s\+[0-9A-F]{4}\s+%s\s+[0-9A-F]{4}\s+(\d+)\s'
                     % (stem, name))
    for l in io.open(path, errors="replace"):
        m = pat.match(l.rstrip("\r\n"))
        if m:
            return int(m.group(1))
    return None


def build_pxt(stem, terms, strus):
    """(new lines, old declare count, new declare count)."""
    ents = pxt_entries(stem)
    if not ents:
        raise SystemExit("%s: no CSAS_PXT_ structures in the dump" % stem)

    src = io.open(SRC6 % stem, errors="strict").read().split("\n")
    di = [i for i, l in enumerate(src) if l.startswith(" DECLARE CSAS_PXT_")]
    if not di:
        raise SystemExit("%s: no ' DECLARE CSAS_PXT_' cards in the OI340600 source"
                         % stem)
    first = di[0]
    last = next(i for i in range(di[-1], len(src)) if ");" in src[i])
    srn, code = int(src[first][72:78]), src[first][78:80]

    # OI340600's own padding declares, reused verbatim once the dump confirms
    # the size is unchanged.  A pad's PARMID is all zero, so the dump prints no
    # decoded value for it and it cannot go through the ordinary path.
    pads = {}
    for i in di:
        nm = src[i].split()[1]
        mm = re.search(r'-STRUCTURE\((\d+)\)', src[i][:72])
        if mm:
            end = next(j for j in range(i, len(src)) if ");" in src[j])
            pads[nm] = (int(mm.group(1)),
                        [x[:72].rstrip() for x in src[i:end + 1]])

    body = []
    for e in ents:
        m = e["m"]
        if e["name"] in pads:
            n, txt = pads[e["name"]]
            if n != e["copies"]:
                raise SystemExit("%s: pad %s is %d in OI340600 but %d in the "
                                 "dump" % (stem, e["name"], n, e["copies"]))
            for t in txt:
                body.append(card(t, srn, code)); srn += 2
            continue
        disc = "CSAS_PXT_DISC_PTR" in m
        tmpl = "CSAS_PXT_DISC" if disc else "CSAS_PXT_ANA_EU"
        p1 = "CSAS_PXT_PARENT_PTR" if disc else "CSAS_PXT_PARM_PTR"
        p2 = "CSAS_PXT_DISC_PTR" if disc else "CSAS_PXT_CONC_PTR"
        missing = [f for f in FLAGS + ["CSAS_PXT_PARMID", p1, p2] if f not in m]
        if missing:
            raise SystemExit("%s %s: members absent from the dump: %s"
                             % (stem, e["name"], " ".join(missing)))

        parmid = int(m["CSAS_PXT_PARMID"][1], 2)
        if e["name"] != "CSAS_PXT_%d" % parmid:
            raise SystemExit("%s: PARMID %d contradicts structure name %s"
                             % (stem, parmid, e["name"]))
        inter = m["CSAS_PXT_INTERPROCESS"][1].lstrip("0") or "0"
        gpcf = "1" if m["CSAS_PXT_GPCF"][1] == "TRUE" else "0"
        onoff = ["ON" if m[f][1] == "TRUE" else "OFF" for f in FLAGS[2:]]

        body.append(card(" DECLARE %s %s-STRUCTURE" % (e["name"], tmpl), srn, code))
        body.append(card("     INITIAL( BIN(3)'%s', BIN'%s', %s, DEC'%d',"
                         % (inter, gpcf, ", ".join(onoff), parmid), srn + 2, code))
        body.append(card("              %s,"
                         % pxt_pointer(terms, strus, m[p1][1], False), srn + 4, code))
        body.append(card("              %s );"
                         % pxt_pointer(terms, strus, m[p2][1], disc), srn + 6, code))
        srn += 8
    out = src[:first] + body + src[last + 1:]

    # CSAS_PXT_NUM_ENTRIES sits OUTSIDE the generated body (its card is
    # "DECLARE  " with two spaces, so it is not one of the DECLAREs replaced)
    # and it is a COUNT -- carrying OI340600's value over would compile
    # perfectly well and be wrong.  The dump holds the release's own value.
    want = pxt_scalar(stem, "CSAS_PXT_NUM_ENTRIES")
    if want is not None:
        for i, l in enumerate(out):
            if l.startswith(" DECLARE  CSAS_PXT_NUM_ENTRIES"):
                j = next(k for k in range(i, len(out)) if ");" in out[k])
                mm = re.match(r'^(\s*)(\d+)\);$', out[j][:72].rstrip())
                if not mm:
                    raise SystemExit("%s: cannot read the NUM_ENTRIES literal "
                                     "from %r" % (stem, out[j][:40]))
                if int(mm.group(2)) != want:
                    out[j] = card("%s%d);" % (mm.group(1), want),
                                  int(out[j][72:78]), out[j][78:80])
                break
        else:
            raise SystemExit("%s: the dump has CSAS_PXT_NUM_ENTRIES=%d but the "
                             "source has no such DECLARE" % (stem, want))
    return out, len(di), len(ents)


# ---------------------------------------------------------------------------
# CS2PCT: a third shape again -- three templates interleaved, each followed by
# a padding array.  CSAS_PCT_INFO_BLOCK (an ARRAY(3) then packed counters),
# CSAS_PCT_SOL_BLOCK (a NAME then seven packed flags), and CSAS_PGT (two
# NAMEs).  The padding arrays are carried over from OI340600 verbatim, their
# sizes checked against the dump's COPY markers.
#
# The DMST_POS pointer of a CSAS_PGT entry aims at an _FDA SUB-STRUCTURE, the
# same case as CS2PX2's DISC_PTR, and is written NAME(CSAS_PDT_6504440_FDA).

PCT_STRU = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+#P%s\+([0-9A-F]{4})\s+(\S+)\s+STRUCTURE')
PCT_MEMB = re.compile(r'^ ([0-9A-F]{6})(?:-[0-9A-F]{6})?\s+#P%s\+([0-9A-F]{4})\s+(\w+)\s+(.*)$')
PCT_COPY = re.compile(r'^ ([0-9A-F]{6})(?:-[0-9A-F]{6})?\s+\+\+\+ COPY (\d+) OF (\d+)')

# member, bit width -- the packed halfwords, used to prove the dump's decoded
# values reassemble into the raw halfword it also prints
PACKED = {
    "info3": [("CSAS_PCT_NUM_PARMS_IN_GROUP", 6), ("CSAS_PCT_GROUP_INDEX", 10)],
    "info4": [("CSAS_PCT_LAST_SOLUTION", 2), ("CSAS_PCT_PARM_SET_INDEX", 14)],
    "sol1":  [(None, 5), ("CSAS_PCT_TYPE", 1), ("CSAS_PCT_POSITION", 5),
              ("CSAS_PCT_GROUPING", 1), ("CSAS_PCT_FIRST_PARM", 1),
              ("CSAS_PCT_LAST_PARM", 1), ("CSAS_PCT_PARM_OP_CODE", 1),
              ("CSAS_PCT_LOG_COMB_OP_CODE", 1)],
}


def pct_entries(stem, extent, path=DUMP):
    """Structures of #P<stem>, with member values, array size and raw words."""
    stru = re.compile(PCT_STRU.pattern % stem)
    memb = re.compile(PCT_MEMB.pattern % stem)
    lo, hi = (int(x, 16) for x in extent.split("-"))
    L = dump_lines(path)
    ents, cur = [], None
    for i, l in enumerate(L):
        m = stru.match(l)
        if m and lo <= int(m.group(1), 16) <= hi:
            cur = {"name": m.group(4), "m": {}, "raw": {}, "copies": 1}
            ents.append(cur)
            continue
        c = PCT_COPY.match(l)
        if c and cur is not None and lo <= int(c.group(1), 16) <= hi:
            cur["copies"] = int(c.group(3))
            continue
        m = memb.match(l)
        if not (m and cur is not None and lo <= int(m.group(1), 16) <= hi):
            continue
        nm, tail = m.group(3), m.group(4)
        raw = re.match(r'\s*([0-9A-F]{4})\s', tail)
        if raw:
            cur["raw"][nm] = int(raw.group(1), 16)
        if "ARRAY" in tail:                       # values two lines down
            cur["m"][nm] = ("ARRAY", (L[i + 2].split() if i + 2 < len(L) else []))
        elif " NAME " in tail:
            cur["m"][nm] = ("PTR", int(raw.group(1), 16) if raw else None)
        else:
            d = re.search(r"BIN'([01]+)'", tail)
            if d:
                cur["m"][nm] = ("BITS", d.group(1))
            elif re.search(r'\bTRUE\b', tail):
                cur["m"][nm] = ("BITS", "1")
            elif re.search(r'\bFALSE\b', tail):
                cur["m"][nm] = ("BITS", "0")
            else:
                d = re.match(r'\s*[0-9A-F]{4}\s+(-?\d+)\s', tail)
                cur["m"][nm] = ("INT", int(d.group(1)) if d else None)
    return ents


def pct_check_packed(stem, e, which, word):
    """Reassemble a packed halfword from the decoded fields and compare."""
    bits = ""
    for nm, w in PACKED[which]:
        if nm is None:
            bits += "0" * w
            continue
        kind, v = e["m"][nm]
        bits += v.rjust(w, "0")
    if len(bits) != 16:
        raise SystemExit("%s %s: %s is %d bits, not 16"
                         % (stem, e["name"], which, len(bits)))
    if int(bits, 2) != word:
        raise SystemExit("%s %s: %s reassembles to %04X but the dump prints "
                         "%04X" % (stem, e["name"], which, int(bits, 2), word))


def build_pct(stem, terms, strus, extent):
    ents = pct_entries(stem, extent)
    if not ents:
        raise SystemExit("%s: no structures in the dump" % stem)

    src = io.open(SRC6 % stem, errors="strict").read().split("\n")
    di = [i for i, l in enumerate(src) if l.startswith(" DECLARE ")]
    if not di:
        raise SystemExit("%s: no ' DECLARE ' cards in the OI340600 source" % stem)
    # OI340600's own pad declares, reused verbatim once their size is checked
    pads = {}
    for i in di:
        nm = src[i].split()[1]
        if "PAD" in nm:
            n = int(re.search(r'-STRUCTURE\((\d+)\)', src[i][:72]).group(1))
            pads[nm] = (n, [src[i][:72].rstrip(), src[i + 1][:72].rstrip()])
    # End at the closing ");" of the LAST GENERATED declare.  Walking backwards
    # for "INITIAL" instead steps over the F END and lands on a declare that is
    # NOT part of the generated set -- CSAPCT's "  DECLARE DUMMY_INTEGER" has
    # two spaces -- and silently drops both.
    first = di[0]
    last = next(i for i in range(di[-1], len(src)) if ");" in src[i])
    srn, code = int(src[first][72:78]), src[first][78:80]

    body, counts = [], collections.Counter()
    for e in ents:
        nm, m = e["name"], e["m"]
        if "PAD" in nm:
            if nm not in pads:
                raise SystemExit("%s: no OI340600 declare for pad %s" % (stem, nm))
            n, txt = pads[nm]
            if n != e["copies"]:
                raise SystemExit("%s: pad %s is %d in OI340600 but %d in the dump"
                                 % (stem, nm, n, e["copies"]))
            counts["pad"] += 1
            for k, t in enumerate(txt):
                body.append(card(t[:72].rstrip(), srn, code)); srn += 2
            continue

        if "CSAS_PCT_NUMPARMS_INSET" in m:                       # INFO_BLOCK
            counts["info"] += 1
            pct_check_packed(stem, e, "info3", e["raw"]["CSAS_PCT_NUM_PARMS_IN_GROUP"])
            pct_check_packed(stem, e, "info4", e["raw"]["CSAS_PCT_LAST_SOLUTION"])
            arr = m["CSAS_PCT_NUMPARMS_INSET"][1]
            body.append(card(" DECLARE %s     CSAS_PCT_INFO_BLOCK-STRUCTURE" % nm, srn, code))
            body.append(card("     INITIAL(%s," % ",".join(arr), srn + 2, code))
            body.append(card("     DEC'%d',DEC'%d',BIN'%s',DEC'%d',%d,%d);"
                             % (int(m["CSAS_PCT_NUM_PARMS_IN_GROUP"][1], 2),
                                int(m["CSAS_PCT_GROUP_INDEX"][1], 2),
                                m["CSAS_PCT_LAST_SOLUTION"][1],
                                int(m["CSAS_PCT_PARM_SET_INDEX"][1], 2),
                                m["CSAS_PCT_MAX_WARMUP"][1],
                                m["CSAS_PCT_WARMUP_COUNT"][1]), srn + 4, code))
            srn += 6
        elif "CSAS_PCT_TYPE" in m:                                # SOL_BLOCK
            counts["sol"] += 1
            pct_check_packed(stem, e, "sol1", e["raw"]["CSAS_PCT_TYPE"])
            body.append(card(" DECLARE %s %s" % (nm.ljust(20), "CSAS_PCT_SOL_BLOCK-STRUCTURE"), srn, code))
            body.append(card("     INITIAL(%s,"
                             % pxt_pointer(terms, strus, m["CSAS_PCT_PARM_PTR"][1], False),
                             srn + 2, code))
            body.append(card("          BIN'%s',DEC'%02d',BIN'%s',"
                             % (m["CSAS_PCT_TYPE"][1],
                                int(m["CSAS_PCT_POSITION"][1], 2),
                                m["CSAS_PCT_GROUPING"][1]), srn + 4, code))
            body.append(card("          BIN'%s',BIN'%s',BIN'%s',BIN'%s');"
                             % (m["CSAS_PCT_FIRST_PARM"][1], m["CSAS_PCT_LAST_PARM"][1],
                                m["CSAS_PCT_PARM_OP_CODE"][1],
                                m["CSAS_PCT_LOG_COMB_OP_CODE"][1]), srn + 6, code))
            srn += 8
        elif "DMST_POS" in m:                                     # CSAS_PGT
            counts["pgt"] += 1
            dm = m["DMST_POS"][1]
            # The declare's own name embeds the payload DMST_POS aims at, so
            # the two must agree; a misresolved pointer cannot pass silently.
            want = re.match(r'CSAS_PGT_(\d+)_', nm)
            if want and dm:
                got = pxt_pointer(terms, strus, dm, True)
                if want.group(1) not in got:
                    raise SystemExit("%s %s: DMST_POS resolves to %s, which "
                                     "contradicts the declare name"
                                     % (stem, nm, got))
            body.append(card(" DECLARE %s     CSAS_PGT-STRUCTURE" % nm, srn, code))
            body.append(card("     INITIAL(%s,"
                             % pxt_pointer(terms, strus, m["PARM_PTR"][1], False),
                             srn + 2, code))
            body.append(card("          %s);"
                             % ("NAME(NULL)" if dm == 0
                                else pxt_pointer(terms, strus, dm, True)), srn + 4, code))
            srn += 6
        else:
            raise SystemExit("%s: %s matches no known template (members %s)"
                             % (stem, nm, " ".join(sorted(m))))
    return src[:first] + body + src[last + 1:], len(di), len(ents), counts


# ---------------------------------------------------------------------------
# CS2IFT: 44 entries of three NAME pointers each, plus a five-copy pad.  Two
# things here appear nowhere else.
#
# A pointer can aim at an ARRAY ELEMENT.  The dump gives the array's extent, so
# the element index is the offset from its start, and OI340600 writes it
# NAME(CSQB_APU_FUEL_STAT$(1:)).  It can also aim at a PLAIN VARIABLE that is
# inside no structure at all, written NAME(CSAS_DUMMY_STAT) with no
# qualification.  A resolver that only knows structure.field handles neither.
#
# The TEMPLATE is not in the dump -- all three templates have identical member
# names -- but it is derivable, because they differ only in the type of
# CSAS_IFT_PARM_VAL: SCALAR is CSAS_IFT, INTEGER CSAS_IFT_INT, BIT(16)
# CSAS_IFT_DIS, BIT(3) CSAS_IFT_DIS_3.  So the type of whatever PARM_VAL POINTS
# AT names the template.

ARRAY_LINE = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+#P(\S+?)\+[0-9A-F]{4}\s+(\w+)\s+.*\bARRAY\b')
TYPE_LINE = re.compile(r'^ ([0-9A-F]{6})(?:-([0-9A-F]{6}))?\s+#P\S+\+[0-9A-F]{4}\s+(\w+)\s+(.*)$')
IFT_TEMPLATE = {"SCALAR": "CSAS_IFT", "INTEGER": "CSAS_IFT_INT",
                "BIT(16)": "CSAS_IFT_DIS", "BIT(3)": "CSAS_IFT_DIS_3"}


# Halfwords per element, by the dump's own type wording.  A SCALAR array
# prints no value line, so the element count cannot be read off; the width has
# to come from the type, and the extent must divide by it exactly.
ELEM_HALFWORDS = [("DP SCALAR", 4), ("SP SCALAR", 2), ("DP INTEGER", 2),
                  ("SP INTEGER", 1), ("BIT STRING", 1)]


def array_index(path=DUMP):
    """(start, end, name, halfwords-per-element) for every ARRAY."""
    out = []
    for l in dump_lines(path):
        m = ARRAY_LINE.match(l)
        if not (m and m.group(2)):
            continue
        lo, hi = int(m.group(1), 16), int(m.group(2), 16)
        w = next((n for t, n in ELEM_HALFWORDS if t in l), 1)
        if (hi - lo + 1) % w:
            continue                      # extent inconsistent with the type
        out.append((lo, hi, m.group(4), w))
    return out


def array_styles(stem):
    """How OI340600 subscripted each array in THIS file: "$%d" or "$(%d:)".

    Both forms appear, for arrays whose declarations are identical
    (ARRAY(3) SCALAR and ARRAY(4) SCALAR), so the difference is that source's
    own style rather than anything semantic.  Preserving it per array keeps the
    reconstruction as close to the original as the dump allows."""
    txt = io.open(SRC6 % stem, errors="replace").read()
    st = {}
    # A subscript that opens with "(" closes with its own ")"; a bare one is
    # just digits.  Matching ")?" loosely swallows NAME's closing paren and
    # yields "$1)", which renders as NAME(X$1)).
    for name, sub in re.findall(r'NAME\((\w+)\$(\(\d+:?\)|\d+)', txt):
        st[name] = "$" + re.sub(r'\d+', "%d", sub)
    return st


def type_index(path=DUMP):
    """address -> 'SCALAR' | 'INTEGER' | 'BIT(n)', for template selection."""
    typ = {}
    for l in dump_lines(path):
        m = TYPE_LINE.match(l)
        if not m:
            continue
        tail = m.group(4)
        if "SCALAR" in tail:
            d = "SCALAR"
        elif "INTEGER" in tail:
            d = "INTEGER"
        elif "BIT STRING" in tail:
            b = re.search(r"BIN'([01]+)'", tail)
            d = "BIT(%d)" % len(b.group(1)) if b else None
        else:
            d = None
        if d:
            for a in range(int(m.group(1), 16),
                           int(m.group(2) or m.group(1), 16) + 1):
                typ.setdefault(a, d)
    return typ


def ift_pointer(terms, strus, arrays, styles, ptr):
    """Render one NAME initializer: structure.field, array element, or plain."""
    if ptr == 0:
        return "NULL"
    st, f, sub = resolve(terms, strus, ptr)
    if st and f and st != f:
        return "NAME(%s.%s)" % (st, f)
    for lo, hi, name, w in arrays:
        if lo <= ptr <= hi:
            if (ptr - lo) % w:
                raise SystemExit("pointer %04X is not on an element boundary "
                                 "of %s (%d halfwords each)" % (ptr, name, w))
            return "NAME(%s%s)" % (name, (styles.get(name, "$(%d:)")
                                          % ((ptr - lo) // w + 1)))
    if f:
        return "NAME(%s)" % f
    raise SystemExit("CS2IFT: pointer %04X resolves to nothing" % ptr)


def build_ift(stem, terms, strus, extent):
    arrays, types = array_index(), type_index()
    styles = array_styles(stem)
    ents = pct_entries(stem, extent)          # same walker; members are NAMEs
    if not ents:
        raise SystemExit("%s: no structures in the dump" % stem)

    src = io.open(SRC6 % stem, errors="strict").read().split("\n")
    di = [i for i, l in enumerate(src)
          if re.match(r'^ DECLARE CSAS_IFT_(\d+|PAD)\b', l)]
    if not di:
        raise SystemExit("%s: no ' DECLARE CSAS_IFT_' cards in OI340600" % stem)
    pads = {}
    for i in di:
        nm = src[i].split()[1]
        mm = re.search(r'-STRUCTURE\((\d+)\)', src[i][:72])
        if mm:
            end = next(j for j in range(i, len(src)) if ");" in src[j])
            pads[nm] = (int(mm.group(1)), [x[:72].rstrip() for x in src[i:end + 1]])
    first = di[0]
    last = next(i for i in range(di[-1], len(src)) if ");" in src[i])
    srn, code = int(src[first][72:78]), src[first][78:80]

    body, counts = [], collections.Counter()
    for e in ents:
        nm, m = e["name"], e["m"]
        if nm in pads:
            n, txt = pads[nm]
            if n != e["copies"]:
                raise SystemExit("%s: pad %s is %d in OI340600 but %d in the dump"
                                 % (stem, nm, n, e["copies"]))
            counts["pad"] += 1
            for t in txt:
                body.append(card(t, srn, code)); srn += 2
            continue
        need = ["CSAS_IFT_PARM_STAT", "CSAS_IFT_PARM_VAL", "CSAS_IFT_PDT_PTR"]
        missing = [k for k in need if k not in m]
        if missing:
            raise SystemExit("%s %s: members absent from the dump: %s"
                             % (stem, nm, " ".join(missing)))
        pv = m["CSAS_IFT_PARM_VAL"][1]
        t = types.get(pv)
        if t not in IFT_TEMPLATE:
            raise SystemExit("%s %s: PARM_VAL points at %04X whose type is %r, "
                             "which names no template" % (stem, nm, pv, t))
        tmpl = IFT_TEMPLATE[t]
        counts[tmpl] += 1
        p = [ift_pointer(terms, strus, arrays, styles, m[k][1]) for k in need]
        body.append(card(" DECLARE %s %s-STRUCTURE" % (nm, tmpl), srn, code))
        body.append(card("     INITIAL(%s," % p[0], srn + 2, code))
        body.append(card("          %s," % p[1], srn + 4, code))
        body.append(card("          %s );" % p[2], srn + 6, code))
        srn += 8
    out = src[:first] + body + src[last + 1:]
    want = pxt_scalar(stem, "CSAS_IFT_NUM_ENTRIES")
    if want is not None:
        for i, l in enumerate(out):
            if l.startswith(" DECLARE CSAS_IFT_NUM_ENTRIES"):
                j = next(k for k in range(i, len(out)) if ");" in out[k])
                mm = re.match(r'^(\s*)(\d+)\);$', out[j][:72].rstrip())
                if not mm:
                    raise SystemExit("%s: cannot read the NUM_ENTRIES literal"
                                     % stem)
                if int(mm.group(2)) != want:
                    out[j] = card("%s%d);" % (mm.group(1), want),
                                  int(out[j][72:78]), out[j][78:80])
                break
        else:
            raise SystemExit("%s: dump has CSAS_IFT_NUM_ENTRIES=%d but the "
                             "source has no such DECLARE" % (stem, want))
    return out, len(di), len(ents), counts


OLD_PURPOSE = ["C/ Purpose:     This is part of the original source code for the ",
               "C/              Space Shuttle's flight software."]


def header(L, stem, old, nres, ntrail, addr):
    if L[5:7] != OLD_PURPOSE:
        raise SystemExit("%s: unexpected Purpose block: %r" % (stem, L[5:7]))
    tail = ("C/              The %d trailing null pointers are written\n"
            "C/              %d#(NULL), exactly as OI340600 wrote its own.\n"
            % (ntrail, ntrail)) if ntrail else \
           "C/              This compool has no trailing null entries.\n"
    L[5:7] = ("""\
C/ Purpose:     This is the OI340700 form of part of the original
C/              source code for the Space Shuttle's flight software.
C/              The initializer list was RECOVERED BY REVERSE
C/              ENGINEERING the compool #P{stem} out of the DASS
C/              memory dump of OI340700.  Everything else -- the
C/              preamble, the DECLARE, and the whole change-history
C/              block -- is OI340600's, carried over untouched.
C/              It is generated by dass-ixgen.py, whose commentary
C/              gives the method in full; do not hand edit it.
C/ Note A:      WHY.  This is a payload index: every entry is a NAME
C/              pointer into a payload data table.  OI340700 carries
C/              a DIFFERENT payload set from OI340600 -- these tables
C/              are mission-dependent -- so both the length of the
C/              index and the target of every entry change.  Compiled
C/              as it stood, the module referenced payloads OI340700
C/              does not declare.
C/ Note B:      HOW.  #P{stem} occupies {addr} in the dump and
C/              holds {total} NAME pointers.  Each was taken in offset
C/              order, its value read as an address, and that address
C/              looked up in the dump, which names the structure
C/              covering it and the field at that exact halfword.
C/              Those two names are the initializer.  For example, a
C/              pointer holding C49C resolves against
C/              00C49C-00C49E CSAS_PDT_451145 STRUCTURE with
C/              CSAS_PDTA_STAT at 00C49C, giving
C/              NAME(CSAS_PDT_451145.CSAS_PDTA_STAT).
C/ Note C:      The count falls from {old} to {total}.  Every payload
C/              named here is declared in OI340700's tables; none was
C/              guessed, and none is left over from OI340600.
{tail}\
C/ Note D:      WHAT IS NOT RECOVERABLE.  OI340600 interleaved the
C/              list with comment cards marking cycle groupings.  The
C/              dump records values, not comments, so where those
C/              divisions fall in OI340700 is unknown and they are
C/              omitted rather than guessed at.""").format(
        stem=stem, addr=addr or "(range not found)",
        total=nres + ntrail, old=old, tail=tail).split("\n")
    for i, l in enumerate(L):
        if l.startswith("C/ History:"):
            L.insert(i + 1, "C/              2026-09-04 RSB  OI340700 form: initializer list")
            L.insert(i + 2, "C/                              rebuilt from the DASS dump.")
            return L
    raise SystemExit("%s: no History line to append to" % stem)



def header_pxt(L, stem, old, new, addr):
    """Header for the CSAS_PXT_ shape (individually DECLAREd entries)."""
    if L[5:7] != OLD_PURPOSE:
        raise SystemExit("%s: unexpected Purpose block: %r" % (stem, L[5:7]))
    L[5:7] = ("""\
C/ Purpose:     This is the OI340700 form of part of the original
C/              source code for the Space Shuttle's flight software.
C/              Every DECLARE between the preamble and the closing
C/              F END was RECOVERED BY REVERSE ENGINEERING the
C/              compool #P{stem} out of the DASS memory dump of
C/              OI340700.  The preamble, the F END and the CLOSE are
C/              OI340600's, carried over untouched.
C/              It is generated by dass-ixgen.py, whose commentary
C/              gives the method in full; do not hand edit it.
C/ Note A:      WHY.  Each entry describes one telemetry parameter
C/              and points into the payload data tables.  OI340700
C/              carries a DIFFERENT payload set from OI340600 --
C/              these tables are mission-dependent -- so entries
C/              appear, vanish and change target between releases.
C/              The count falls from {old} to {new}.
C/ Note B:      HOW.  #P{stem} occupies {addr} in the dump.  Each
C/              entry is four halfwords: six bit-packed flags, a
C/              24-bit PARMID, and two NAME pointers.  The dump
C/              prints every one of those by name with its decoded
C/              value, so each DECLARE is transcribed rather than
C/              inferred.  A NAME's printed value IS the address it
C/              points at, and looking that address up gives the
C/              structure covering it and the field at that exact
C/              halfword.
C/ Note C:      WHICH TEMPLATE.  The members say so: an entry with
C/              PARM_PTR and CONC_PTR is CSAS_PXT_ANA_EU, one with
C/              PARENT_PTR and DISC_PTR is CSAS_PXT_DISC.  DISC_PTR
C/              aims at an _FDA SUB-STRUCTURE AS A WHOLE and is
C/              written with no field -- NAME(CSAS_PDT_612557_FDA) --
C/              which is exactly why a payload.field resolver reports
C/              those pointers as unresolvable.
C/ Note D:      SELF-CHECK.  PARMID decodes to the entry's own
C/              number: CSAS_PXT_460305 holds
C/              BIN'000001110000011000010001', which is 460305.
C/              The generator asserts this for every entry, so a
C/              misparse cannot pass silently.
C/ Note E:      A pointer value of 0000 is a genuine NULL, not a
C/              pointer to CSAS_PDT_DUMMY.""").format(
        stem=stem, addr=addr or "(range not found)", old=old, new=new).split("\n")
    for i, l in enumerate(L):
        if l.startswith("C/ History:"):
            L.insert(i + 1, "C/              2026-09-04 RSB  OI340700 form: entries rebuilt")
            L.insert(i + 2, "C/                              from the DASS dump.")
            return L
    raise SystemExit("%s: no History line to append to" % stem)



def header_pct(L, stem, old, new, counts, addr):
    if L[5:7] != OLD_PURPOSE:
        raise SystemExit("%s: unexpected Purpose block: %r" % (stem, L[5:7]))
    L[5:7] = ("""\
C/ Purpose:     This is the OI340700 form of part of the original
C/              source code for the Space Shuttle's flight software.
C/              Every DECLARE was RECOVERED BY REVERSE ENGINEERING
C/              the compool #P{stem} out of the DASS memory dump of
C/              OI340700.  The preamble, the F END and the CLOSE are
C/              OI340600's, carried over untouched.
C/              It is generated by dass-ixgen.py, whose commentary
C/              gives the method in full; do not hand edit it.
C/ Note A:      WHY.  These entries describe parameter groups and
C/              point into the payload data tables.  OI340700 carries
C/              a DIFFERENT payload set from OI340600 -- these tables
C/              are mission-dependent -- so the entries change with
C/              it.  The declare count falls from {old} to {new}:
C/              {info} CSAS_PCT_INFO_BLOCK, {sol} CSAS_PCT_SOL_BLOCK,
C/              {pgt} CSAS_PGT, and {pad} padding arrays.
C/ Note B:      HOW.  #P{stem} occupies {addr} in the dump, which
C/              prints every member by name with its decoded value.
C/              Each DECLARE is transcribed from those values rather
C/              than inferred.  A NAME's printed value IS the address
C/              it points at; looking it up gives the structure and
C/              the field at that halfword.  DMST_POS aims at an _FDA
C/              SUB-STRUCTURE as a whole and so is written with no
C/              field -- NAME(CSAS_PDT_6504440_FDA).
C/ Note C:      SELF-CHECK.  The packed halfwords are reassembled
C/              from the decoded fields and compared with the raw
C/              value the dump also prints, so a misreading cannot
C/              pass silently.  For CSAS_PCT_SOL_1_1_2001_11 that is
C/              five pad bits, TYPE 1, POSITION 01000 and five flags,
C/              which is 0502 -- the word the dump shows.
C/ Note D:      The three padding arrays are OI340600's own DECLAREs
C/              reused verbatim, after checking their sizes against
C/              the dump's COPY markers (5, 25 and 10).""").format(
        stem=stem, addr=addr or "(range not found)", old=old, new=new,
        info=counts["info"], sol=counts["sol"], pgt=counts["pgt"],
        pad=counts["pad"]).split("\n")
    for i, l in enumerate(L):
        if l.startswith("C/ History:"):
            L.insert(i + 1, "C/              2026-09-04 RSB  OI340700 form: entries rebuilt")
            L.insert(i + 2, "C/                              from the DASS dump.")
            return L
    raise SystemExit("%s: no History line to append to" % stem)



def header_ift(L, stem, old, new, counts, addr):
    if L[5:7] != OLD_PURPOSE:
        raise SystemExit("%s: unexpected Purpose block: %r" % (stem, L[5:7]))
    L[5:7] = ("""\
C/ Purpose:     This is the OI340700 form of part of the original
C/              source code for the Space Shuttle's flight software.
C/              Every DECLARE was RECOVERED BY REVERSE ENGINEERING
C/              the compool #P{stem} out of the DASS memory dump of
C/              OI340700.  The preamble -- including the structure
C/              templates -- the F END and the CLOSE are OI340600's,
C/              carried over untouched.
C/              It is generated by dass-ixgen.py, whose commentary
C/              gives the method in full; do not hand edit it.
C/ Note A:      WHY.  Each entry is three NAME pointers describing one
C/              parameter.  OI340700 carries a different payload set
C/              from OI340600 -- these tables are mission-dependent --
C/              so entries appear, vanish and change target.  The
C/              declare count goes from {old} to {new}.
C/ Note B:      THREE KINDS OF TARGET, and #P{stem} is the only
C/              compool here that uses all three.  A pointer may aim
C/              at a field of a structure, NAME(payload.field); at an
C/              ARRAY ELEMENT, where the dump gives the array's extent
C/              so the index is the offset from its start, written
C/              NAME(CSQB_APU_FUEL_STAT$(1:)); or at a PLAIN VARIABLE
C/              inside no structure at all, written NAME(name) with no
C/              qualification.
C/ Note C:      HOW THE TEMPLATE IS KNOWN.  It is NOT in the dump --
C/              all the templates have identical member names.  They
C/              differ only in the type of CSAS_IFT_PARM_VAL, so the
C/              type of whatever that pointer POINTS AT names the
C/              template: SCALAR is CSAS_IFT, INTEGER CSAS_IFT_INT,
C/              BIT(16) CSAS_IFT_DIS, BIT(3) CSAS_IFT_DIS_3.  Here
C/              that gives {ift} CSAS_IFT and {dis} CSAS_IFT_DIS.
C/ Note D:      NO ENTRY USES CSAS_IFT_DIS_3, and that is a result
C/              rather than an accident: OI340600's sole DIS_3 entry
C/              was CSAS_IFT_920313, and #P{stem} runs
C/              ...920109, 920315, 920318..., skipping it.  The
C/              template census and the missing entry agree.""").format(
        stem=stem, addr=addr, old=old, new=new,
        ift=counts.get("CSAS_IFT",0), dis=counts.get("CSAS_IFT_DIS",0)).split("\n")
    for i, l in enumerate(L):
        if l.startswith("C/ History:"):
            L.insert(i + 1, "C/              2026-09-04 RSB  OI340700 form: entries rebuilt")
            L.insert(i + 2, "C/                              from the DASS dump.")
            return L
    raise SystemExit("%s: no History line to append to" % stem)



# ---------------------------------------------------------------------------
# CS2PAT: two declares, each a count and three pointers naming the FIRST entry
# of one PCT table -- COMMON points into CSAPCT, UNIQUE into CS2PCT.  The
# pointers aim at STRUCTURES rather than fields, so they are written NAME(x)
# with no qualification, and this file can only be built after those two
# tables, since every target must be an entry they declare.

def build_pat(stem, terms, strus, extent):
    ents = pct_entries(stem, extent)
    if not ents:
        raise SystemExit("%s: no structures in the dump" % stem)
    src = io.open(SRC6 % stem, errors="strict").read().split("\n")
    di = [i for i, l in enumerate(src) if l.startswith(" DECLARE CSAS_PAT_")]
    if not di:
        raise SystemExit("%s: no ' DECLARE CSAS_PAT_' cards in OI340600" % stem)
    first = di[0]
    last = next(i for i in range(di[-1], len(src)) if ");" in src[i])
    srn, code = int(src[first][72:78]), src[first][78:80]

    body = []
    for e in ents:
        m = e["m"]
        need = ["NUM_PRECOND", "INFO_BLOCK", "SOL_BLOCK", "PGT"]
        missing = [k for k in need if k not in m]
        if missing:
            raise SystemExit("%s %s: members absent from the dump: %s"
                             % (stem, e["name"], " ".join(missing)))
        def target(k):
            v = m[k][1]
            if v == 0:
                return "NULL"
            cover = [x for x in strus if x[0] <= v <= x[1]]
            if not cover:
                raise SystemExit("%s %s: %s -> %04X is in no structure"
                                 % (stem, e["name"], k, v))
            return "NAME(%s)" % min(cover, key=lambda x: x[1] - x[0])[2]
        body.append(card(" DECLARE %s  CSAS_PAT-STRUCTURE" % e["name"], srn, code))
        body.append(card("     INITIAL(%d,%s," % (m["NUM_PRECOND"][1],
                                                  target("INFO_BLOCK")), srn + 2, code))
        body.append(card("          %s,%s);" % (target("SOL_BLOCK"),
                                                target("PGT")), srn + 4, code))
        srn += 6
    return src[:first] + body + src[last + 1:], len(di), len(ents)


def header_pat(L, stem, old, new):
    if L[5:7] != OLD_PURPOSE:
        raise SystemExit("%s: unexpected Purpose block: %r" % (stem, L[5:7]))
    L[5:7] = ("""\
C/ Purpose:     This is the OI340700 form of part of the original
C/              source code for the Space Shuttle's flight software.
C/              Both DECLAREs were RECOVERED BY REVERSE ENGINEERING
C/              the compool #PCS2PAT out of the DASS memory dump of
C/              OI340700.  Everything else is OI340600's, untouched.
C/              It is generated by dass-ixgen.py; do not hand edit it.
C/ Note A:      WHY.  Each declare holds a count and three pointers
C/              naming the FIRST entry of one precondition table --
C/              CSAS_PAT_COMMON points into CSAPCT, CSAS_PAT_UNIQUE
C/              into CS2PCT.  Both tables are rebuilt for OI340700
C/              with different entries, so the old names no longer
C/              exist and the counts have changed: 70 -> 63 for
C/              COMMON and 29 -> 4 for UNIQUE.
C/ Note B:      The pointers aim at STRUCTURES, not fields, so they
C/              are written NAME(x) with no qualification.
C/ Note C:      CONSISTENCY.  Every target here is an entry that this
C/              release's own CSAPCT.hal and CS2PCT.hal declare, and
C/              each is the first of its kind in its file.  Those two
C/              were reconstructed separately from this one, so their
C/              agreeing is a check rather than a restatement.""").split("\n")
    for i, l in enumerate(L):
        if l.startswith("C/ History:"):
            L.insert(i + 1, "C/              2026-09-04 RSB  OI340700 form: both entries")
            L.insert(i + 2, "C/                              rebuilt from the DASS dump.")
            return L
    raise SystemExit("%s: no History line" % stem)


def main(argv):
    report = "--report" in argv
    stems = [a for a in argv if not a.startswith("-")]
    if not stems:
        raise SystemExit(__doc__)
    terms, strus, ext = load()
    for stem in stems:
        # Dispatch on the shape the dump shows: a flat array of NAME pointers
        # (CS2IX*) or a run of individually DECLAREd CSAS_PXT_ entries.
        if pxt_entries(stem):
            out, old, new = build_pxt(stem, terms, strus)
            what = "%-7s %3d -> %3d DECLAREs" % (stem, old, new)
            if not report:
                out = header_pxt(out, stem, old, new, ext.get(stem))
        elif any(e["name"].startswith("CSAS_PAT_")
                 for e in pct_entries(stem, ext.get(stem, "0-0"))):
            out, old, new = build_pat(stem, terms, strus, ext[stem])
            what = "%-7s %3d -> %3d DECLAREs" % (stem, old, new)
            if not report:
                out = header_pat(out, stem, old, new)
        elif any(e["name"].startswith("CSAS_IFT_")
                 for e in pct_entries(stem, ext.get(stem, "0-0"))):
            out, old, new, counts = build_ift(stem, terms, strus, ext[stem])
            what = ("%-7s %3d -> %3d DECLAREs (%d IFT, %d DIS, %d pad)"
                    % (stem, old, new, counts.get("CSAS_IFT",0),
                       counts.get("CSAS_IFT_DIS",0), counts.get("pad",0)))
            if not report:
                out = header_ift(out, stem, old, new, counts, ext.get(stem))
        elif any(e["name"].startswith(("CSAS_PCT_", "CSAS_PGT"))
                 for e in pct_entries(stem, ext.get(stem, "0-0"))):
            out, old, new, counts = build_pct(stem, terms, strus, ext[stem])
            what = ("%-7s %3d -> %3d DECLAREs (%d info, %d sol, %d pgt, %d pad)"
                    % (stem, old, new, counts["info"], counts["sol"],
                       counts["pgt"], counts["pad"]))
            if not report:
                out = header_pct(out, stem, old, new, counts, ext.get(stem))
        else:
            out, old, nres, ntrail = build(stem, terms, strus)
            what = ("%-7s %3d -> %3d entries (%d resolved + %d null)"
                    % (stem, old, nres + ntrail, nres, ntrail))
            if not report:
                out = header(out, stem, old, nres, ntrail, ext.get(stem))
        if report:
            print(what)
            continue
        io.open(DST7 % stem, "w").write("\n".join(out))
        print("%s  wrote %s" % (what, DST7 % stem))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
