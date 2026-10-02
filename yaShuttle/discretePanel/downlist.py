#!/usr/bin/env python3
"""DECODE PASS DOWNLIST FRAMES into named, scaled measurements, with the
table dltable.py generates from the flight source (downlist-OI340700.json).

    import downlist
    table = downlist.load_table()                  # downlist-OI340700.json
    for msid, name, value, units in downlist.decode(words, fmt, frame, table):
        ...
    rows = downlist.decode_full(words, fmt, frame, table)   # dicts, more detail

    python3 downlist.py FRAMES.jsonl [--match REGEX] [--frame N] [--all]
        decode a groundstation.py downlink --log file and print it

words are the frame's halfwords as received (words[0] is the EB90 sync,
HAL's DL(1)); fmt and frame come from word 2 (frame_header()).

CONVERSIONS (the item's declared type, from the SDF, then its measurement
card's, from the source):
  SCALAR (F)        IBM System/360 short hexadecimal float, 2 halfwords
  DOUBLE (D)        IBM long hexadecimal float, 4 halfwords
  INTEGER (I)       signed 16 bits;  INTEGER DOUBLE (J) signed 32
  BIT(n) (B)        unsigned, right-justified in 1 or 2 halfwords; HAL bit 1
                    is the most significant of the n
  a card T=6 B=b    discrete: bit b of the item -> 0/1 and its S0/S1 label
  a card T=7/8      field of L bits from bit B
  a card T=3/9/10   the raw word(s), unsigned
  A0, A1            engineering value = A0 + A1 x the converted value
  DL(n) = X         (flag 4) X was converted to a 16-bit INTEGER by PASS
                    before it went in the frame: the word is that integer
Words the table marks stale (written by an earlier frame) or partial (an
item cut by the end of a copy) are left out unless asked for.
"""

import argparse
import io
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_TABLE = os.path.join(HERE, "downlist-OI340700.json")

F_STALE, F_HS, F_ASSIGN, F_PARTIAL, F_UNRESOLVED = 1, 2, 4, 8, 16


# --------------------------------------------------------------------------
def from_ibm_short(h):
    w = (h[0] << 16) | h[1]
    if w & 0x7fffffff == 0:
        return 0.0
    s = -1.0 if w >> 31 else 1.0
    e = ((w >> 24) & 0x7f) - 64
    return s * (w & 0xffffff) / float(1 << 24) * 16.0 ** e


def from_ibm_long(h):
    w = (h[0] << 48) | (h[1] << 32) | (h[2] << 16) | h[3]
    if w & ((1 << 63) - 1) == 0:
        return 0.0
    s = -1.0 if w >> 63 else 1.0
    e = ((w >> 56) & 0x7f) - 64
    return s * (w & ((1 << 56) - 1)) / float(1 << 56) * 16.0 ** e


def _uint(h):
    v = 0
    for x in h:
        v = (v << 16) | x
    return v


def _sint(h):
    v = _uint(h)
    n = 16 * len(h)
    return v - (1 << n) if v >> (n - 1) else v


# --------------------------------------------------------------------------
class Table:
    """A loaded decode table: items and, per format, per frame, the word
    entries [word, item, flags, part, frame written]."""

    def __init__(self, doc):
        self.doc = doc
        self.release = doc.get("release")
        self.items = doc["items"]
        self.formats = {int(k): v for k, v in doc["formats"].items()}

    def entries(self, fmt, frame):
        f = self.formats.get(fmt)
        if f is None or not 0 <= frame < len(f["frames"]):
            return []
        return f["frames"][frame]

    def length(self, fmt):
        f = self.formats.get(fmt)
        return f["length"] if f else None

    def where(self, regex):
        """[(format, frame, word, item)] of items whose name or MSID matches."""
        r = re.compile(regex, re.I)
        hit = set(i for i, it in enumerate(self.items)
                  if r.search(it["name"]) or any(r.search(m["msid"]) for m in it.get("meas", ())))
        out = []
        for fmt, f in self.formats.items():
            for fr, ents in enumerate(f["frames"]):
                for e in ents:
                    if e[1] in hit and not e[2] & F_STALE:
                        out.append((fmt, fr, e[0], self.items[e[1]]))
        return out


_cache = {}


def load_table(path=None):
    path = path or DEFAULT_TABLE
    if path not in _cache:
        with io.open(path) as f:
            _cache[path] = Table(json.load(f))
    return _cache[path]


def frame_header(words):
    """Sync, counter, frame number, format ID; in frames 0 and 25 the IDs
    (DCDDOW 012600: CDUV_NSP_VEHICLE_ILOAD BIT(3) || GPC BIT(3) ||
    MISSION_ID BIT(8), right-justified) and the GPC time: TFCMLTQM half-hours
    and TFCMLTQH microseconds (FCMCOM's cards V91W1986C, V91W1985C)."""
    h = {'sync': bool(words) and words[0] == 0xEB90}
    if len(words) >= 2:
        h['counter'] = words[1] >> 14
        h['frame'] = (words[1] >> 8) & 0x3f
        h['format'] = words[1] & 0xff
    if len(words) >= 6 and h.get('frame') in (0, 25):
        h['vehicle'] = (words[2] >> 11) & 7
        h['gpc'] = (words[2] >> 8) & 7
        h['mission'] = words[2] & 0xff
        h['time_words'] = list(words[3:6])
        h['gpc_time_s'] = words[3] * 1800.0 + ((words[4] << 16) | words[5]) * 1e-6
    return h


# --------------------------------------------------------------------------
def _base_value(it, raw, assigned):
    """The item's own value from its halfwords."""
    t = it["type"]
    if assigned:
        if t in ("F", "D", "J", "I"):
            return _sint(raw[:1])
        return _uint(raw[:1])
    if t == "F" and len(raw) >= 2:
        return from_ibm_short(raw)
    if t == "D" and len(raw) >= 4:
        return from_ibm_long(raw)
    if t in ("I", "J"):
        return _sint(raw)
    if "shift" in it:                       # a DENSE field
        return (_uint(raw) >> it["shift"]) & ((1 << it.get("bits", 16)) - 1)
    if t == "B":
        return _uint(raw) & ((1 << it.get("bits", 16 * len(raw))) - 1)
    return _uint(raw)


def _apply_card(it, m, raw, base, assigned):
    """(value, text) of one measurement card on an item, or None if the card
    cannot be applied to these halfwords."""
    t = m.get("t")
    nbits = 16 * len(raw) if assigned or it["type"] not in ("B",) else it.get("bits", 16)
    u = _uint(raw)
    if "shift" in it and not assigned:
        u >>= it["shift"]
    u &= (1 << nbits) - 1
    text = None
    if t == 6 and "b" in m:
        b = m["b"]
        if not 1 <= b <= nbits:
            return None
        v = (u >> (nbits - b)) & 1
        text = m.get("s1" if v else "s0")
    elif t in (7, 8) and "b" in m and "l" in m:
        b, l = m["b"], m["l"]
        if l >= nbits:
            v = u
        elif b + l - 1 > nbits:
            return None
        else:
            v = (u >> (nbits - (b + l - 1))) & ((1 << l) - 1)
    elif t in (3, 9, 10):
        v = u
    elif t in (4, 5):
        v = _sint(raw) if not assigned else _sint(raw[:1])
    else:
        v = base
    if "a0" in m or "a1" in m:
        v = m.get("a0", 0.0) + m.get("a1", 1.0) * v
    return v, text


def decode_full(words, fmt, frame, table=None, stale=False, partial=False):
    """Every measurement of one frame, as dicts: msid, name, value, units,
    text (a discrete's label), word (1-based), hw, raw (the halfwords),
    flags, type."""
    table = table or load_table()
    out = []
    n = len(words)
    for e in table.entries(fmt, frame):
        w, ix, flags, part = e[0], e[1], e[2], e[3]
        if flags & F_STALE and not stale:
            continue
        if flags & F_PARTIAL and not partial:
            continue
        it = table.items[ix]
        assigned = bool(flags & F_ASSIGN)
        hw = 1 if assigned or flags & F_PARTIAL else it["hw"]
        if w - 1 + hw > n:
            continue
        raw = list(words[w - 1:w - 1 + hw])
        base = _base_value(it, raw, assigned) if not flags & F_PARTIAL else _uint(raw)
        common = {"name": it["name"], "word": w, "hw": hw, "raw": raw, "flags": flags,
                  "type": it["type"], "frame": frame, "format": fmt}
        if flags & F_PARTIAL:
            common["name"] += " (halfword %d)" % (part + 1)
        whole = False
        for m in it.get("meas", ()) if not flags & F_PARTIAL else ():
            r = _apply_card(it, m, raw, base, assigned)
            if r is None:
                continue
            v, text = r
            if m.get("t") not in (6, 7, 8) or m.get("l", 0) >= 16 * len(raw):
                whole = True
            d = dict(common, msid=m["msid"], value=v, units=m.get("u", ""), text=text,
                     card=m.get("t"))
            out.append(d)
        if not whole:
            out.append(dict(common, msid="", value=base, units="", text=None, card=None))
    return out


def decode(words, fmt, frame, table=None, stale=False, partial=False):
    """[(msid, name, value, units)] of one frame.  value is a float for
    floating-point and calibrated items, an int otherwise; a discrete's value
    is 0/1 (decode_full also gives its S0/S1 label)."""
    return [(d["msid"], d["name"], d["value"], d["units"])
            for d in decode_full(words, fmt, frame, table, stale, partial)]


def fmt_value(d):
    """A decoded value as text: floats to 9 digits, discretes as 0/1 with
    their label, raw and bit-string words in hex as well."""
    v = d["value"]
    c = d.get("card")
    if c == 6:
        return "%d %s" % (v, d["text"]) if d.get("text") else str(v)
    if isinstance(v, float):
        return ("%.15g" if d["type"] == "D" else "%.9g") % v
    if c in (3, 9, 10) or (c is None and d["type"] == "B"):
        return "X'%0*X' %d" % (max(1, 4 * d["hw"]), v, v)
    return str(v)


# --------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description="Decode a groundstation.py downlink log.")
    ap.add_argument("log", help="JSON-lines frame log (groundstation.py downlink --log)")
    ap.add_argument("--table", default=DEFAULT_TABLE)
    ap.add_argument("--match", help="only names/MSIDs matching this regex")
    ap.add_argument("--frame", type=int, action="append", help="only these frame numbers")
    ap.add_argument("--limit", type=int, default=0, help="stop after this many frames")
    ap.add_argument("--all", action="store_true", help="include stale and partial words")
    a = ap.parse_args()
    table = load_table(a.table)
    r = re.compile(a.match, re.I) if a.match else None
    k = 0
    for line in io.open(a.log):
        f = json.loads(line)
        words = [int(x, 16) for x in f["words"]]
        h = frame_header(words)
        if a.frame and h.get("frame") not in a.frame:
            continue
        print("GPC%s t=%.3f s  format %s frame %s%s" % (
            f.get("gpc"), f.get("t_us", 0) / 1e6, h.get("format"), h.get("frame"),
            "  GPC time %.3f s" % h["gpc_time_s"] if "gpc_time_s" in h else ""))
        for d in decode_full(words, h.get("format"), h.get("frame"), table, a.all, a.all):
            if r and not (r.search(d["name"]) or r.search(d["msid"])):
                continue
            print("  w%-3d %-10s %-44s %s %s%s" % (
                d["word"], d["msid"], d["name"], fmt_value(d), d["units"],
                "  [stale]" if d["flags"] & F_STALE else ""))
        k += 1
        if a.limit and k >= a.limit:
            break


if __name__ == "__main__":
    main()
