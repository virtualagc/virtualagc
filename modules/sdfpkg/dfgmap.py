#!/usr/bin/env python3
'''
Map a display compool's halfwords back to the .dfg statements that produced
them, and say what a DASS dump holds at each one.

DFG annotates everything it emits: a "C -- TEXT" line names the deck
statement the following halfwords come from, and "C - TEXT" lines explain
the individual field.  That mapping is the whole point of this script -- it
turns "these halfwords differ" into "this statement differs".

    dfgmap.py GEN.hal                        the annotated map
    dfgmap.py GEN.hal --at N [--count M]     just that window
    dfgmap.py GEN.hal --find HHHH,HHHH,...   where that sequence occurs
    dfgmap.py GEN.hal --dump F.fcm --address HEX
                                             compare against a memory image
                                             and name the differing statements
    dfgmap.py x --corpus DIR --find HHHH,...  which statement in ANY deck
                                             emits that sequence

TWO WORKFLOWS.  Going forwards, --dump says which of OUR statements the dump
disagrees with.  Going backwards -- the harder direction, and the reason this
exists -- --corpus --find takes halfwords FROM the dump and names the deck
statement that produces them, even when the deck they came from is one we do
not have.  DFG's output is regular enough for that to work: the same STAT
preamble, coordinate pairs and CHAR runs recur across every display, so a
sequence lifted from an unknown display is usually identifiable from the
decks we do have.

    $ dfgmap.py x --corpus hal/ --find 8471,9102
    CV1060    @41    XC = 5 | YC = 4
    $ dfgmap.py x --corpus hal/ --find E349,E945
    CS2020    @175   CHAR = (FIRE CMD)
'''
import re, sys, argparse, pathlib, pathlib

HEXV = re.compile(r"HEX'([0-9A-Fa-f]{1,4})'")

# The DEU character set: all 128 codes, from USA-003090 p.104 via
# deucharset.ts beside this script.  It is NOT ASCII, which is what an
# earlier version of this file assumed after inferring the set from the
# corpus alone: 0x22 is ~ not ", 0x24 a radical not $, 0x40 gamma not @,
# 0x5C theta, 0x5E pi, 0x7B/0x7E/0x7F sigma/lambda/delta.  Codes the corpus
# never exercises were invisible to that inference altogether, and two it did
# exercise were misread from the deck keyword that emits them: 0x10 and 0x14
# are alpha and epsilon, not the "SPCHAR"/"ALTCHAR" the statements are named.
def _load_charset():
    for cand in (pathlib.Path(__file__).with_name("deucharset.ts"),
                 pathlib.Path.home() / "ipl-demo" / "deucharset.ts"):
        if cand.exists():
            t = {}
            for line in cand.read_text(encoding="utf-8").splitlines():
                m = re.match(r"""\s*0x([0-9a-fA-F]{2})\s*:\s*('([^']*)'|"([^"]*)")""", line)
                if m:
                    t[int(m.group(1), 16)] = m.group(3) if m.group(3) is not None else m.group(4)
            if len(t) >= 128:
                return t
    return None

DEUSET = _load_charset()

def glyph(c):
    """One screen cell's worth of character, or None if the code is not one."""
    if DEUSET is None:
        return chr(c) if 32 <= c < 127 else None
    g = DEUSET.get(c)
    if g is None or g in ("\\0", "\\b", "\\r"):
        return None                       # absent, or a control written as an escape
    if g == "":
        return "_"                        # 0x7d, the full-cell underscore
    return g if len(g) == 1 else None     # 'SELF TEST' is a legend, not a cell

# Cursor FCWs.  Both axes are raster positions with a fixed pitch -- 19
# raster units per column, 27 per row -- and each axis has two bases exactly
# 0x600 apart, the low one covering the top-left of the screen and the high
# one the rest.  Solved from the corpus and checked against it: the rule below
# reproduces all 4051 annotated XC=/YC= statements with no exceptions, and the
# largest column it yields is 51, which is the screen width.
X_BASES, X_PITCH = (0x8412, 0x7E12), 19
Y_BASES, Y_PITCH = (0x916E, 0x976E), 27
SCREEN_COLS, SCREEN_ROWS = 51, 26

def xc_of(hw):
    """The character column a cursor FCW selects, or None.

    An exact multiple of the pitch is a character cell.  DFG also emits
    absolute raster coordinates -- the deck writes them as XC = 195A -- which
    fall BETWEEN cells: 0x84C3 is 0x8400 + 195, and (195 - 18) / 19 is 9.3.
    Rejecting those outright left the cursor stale wherever one occurred, so
    they are rounded to the nearest column instead."""
    for b in X_BASES:
        d = hw - b
        if d > 0 and d % X_PITCH == 0 and 1 <= d // X_PITCH <= SCREEN_COLS:
            return d // X_PITCH
    for b in (X_BASES[0] - 0x12, X_BASES[1] - 0x12):
        r = hw - b
        if 0 < r <= (SCREEN_COLS + 1) * X_PITCH:
            col = round((r - 18) / X_PITCH)
            if 1 <= col <= SCREEN_COLS:
                return col

def yc_of(hw):
    """The character row a cursor FCW selects, or None.  See xc_of."""
    for b in Y_BASES:
        d = b - hw
        if d > 0 and d % Y_PITCH == 0 and 1 <= d // Y_PITCH <= SCREEN_ROWS:
            return d // Y_PITCH
    for b in Y_BASES:
        d = b - hw
        if 0 < d <= (SCREEN_ROWS + 1) * Y_PITCH:
            row = round(d / Y_PITCH)
            if 1 <= row <= SCREEN_ROWS:
                return row

AMTNAME = re.compile(r"COMPOOL NAME:\s*(\S*_AMT)\b")

def amt_of(path):
    """The moding-table compool name, if this deck is one.

    PMF=/AMTx= decks are not displays at all: DFG turns them into a
    CDA_Pnn_AMT table telling FCOS which memory configuration a SPEC is valid
    in.  They carry no CHAR, XC or YC statement, so drawing one as a screen
    decodes table entries as text and produces nonsense -- CDAP15 came out
    with a spurious %A1G=M and an F down column 1 of fifteen rows.  All eight
    CDAPnn decks in OI340600 are of this kind."""
    try:
        head = pathlib.Path(path).read_text(errors="replace")[:4000]
    except OSError:
        return None
    m = AMTNAME.search(head)
    return m.group(1) if m else None

def twin(path):
    """The background deck for a foreground one.

    Display definitions come in pairs with the same name but a leading X or
    C: X is the background -- the fixed labels and item numbers -- and C is
    the foreground painted over it.  Rendering a C deck alone therefore looks
    far emptier than the real screen, because everything permanent about the
    display lives in its X twin."""
    p = pathlib.Path(path)
    if not p.name.startswith("C"):
        return None
    t = p.with_name("X" + p.name[1:])
    return t if t.exists() else None

def render_annotated(rows, grid=None):
    """Render from a generated .hal using DFG's own annotations.

    For a compool we have the source of, this beats decoding cursor FCWs out
    of the halfword stream: the statement text says XC = 18 outright, and only
    halfwords belonging to a CHAR/XC/YC/CARRTN statement are drawn at all, so
    the header, KVT, DDT and item tables cannot paint noise.  The FCW route
    below is for memory images, where there are no annotations."""
    if grid is None:
        grid = [[" "] * SCREEN_COLS for _ in range(SCREEN_ROWS)]
    x = y = home = 1
    for _off, val, stmt, _d in rows:
        if val is None:
            continue
        st = (stmt or "").strip()
        m = re.match(r"XC = (\d+)", st)
        if m: x = home = int(m.group(1)); continue
        m = re.match(r"YC = (\d+)", st)
        if m: y = int(m.group(1)); x = home; continue
        if st.startswith("CARRTN"):
            y += 1; x = home; continue
        if not st.startswith("CHAR = ("):
            # A cursor move need not be annotated "XC = n": DFG also emits
            # them inside its IMMEDIATE UPDATE blocks, where the statement
            # comment names the instruction rather than the coordinate.  So
            # decode any halfword that is a cursor FCW, wherever it sits.
            v = xc_of(val) if (val & 0xF000) == 0x8000 else None
            if v: x = home = v; continue
            v = yc_of(val) if (val & 0xF000) == 0x9000 else None
            if v: y = v; x = home
            continue
        for ch in decode_text([val]):
            if len(ch) != 1:
                continue                              # a control, not a cell
            if 1 <= y <= SCREEN_ROWS and 1 <= x <= SCREEN_COLS:
                grid[y - 1][x - 1] = ch
            x += 1
    return grid

def display_list(hws):
    """The static display list, per the DFT header.

    +3 is the displacement to the background and +4 to the DDT.  Bounding the
    render between them removes the noise the header, KVT and tables paint
    when the whole section goes through the decoder.

    IT IS LOSSY, and measurably so: over the 120 generated compools, only 18
    have every one of their CHAR halfwords inside this range.  Text routinely
    lies beyond the DDT -- CG0200's runs to 1566 with the DDT at 800 -- so a
    bounded view can silently drop real labels.  CS0620's ORB C&W ISS is the
    example that caught this.  Hence a view, offered alongside the full one,
    rather than the default."""
    if len(hws) < 5:
        return hws
    bg, ddt = hws[3], hws[4]
    if 0 < bg < ddt <= len(hws):
        return hws[bg:ddt]
    return hws

def render(hws):
    """Lay a halfword stream onto the 51x26 character screen.

    The stream is a display list: cursor FCWs move the cursor, text halfwords
    paint at it, and CARRTN returns to the column the last XC set and steps
    down a row -- which is what makes multi-line labels come out under each
    other rather than running on."""
    grid = [[" "] * SCREEN_COLS for _ in range(SCREEN_ROWS)]
    x = y = 1
    home = 1
    for hw in hws:
        if hw is None:
            continue
        if (hw & 0xF000) == 0x8000:
            v = xc_of(hw)
            if v: x = home = v
            continue
        if (hw & 0xF000) == 0x9000:
            v = yc_of(hw)
            # A row move returns to the home column, the one the last XC set,
            # exactly as CARRTN does.  Leaving x where the previous row's text
            # ended put CS2120's "AD PD BUS LOCK" 14 columns right of where a
            # 2008 crew training workbook shows it, so a later group landed on
            # top of it and it read "B B W FK".
            if v: y = v; x = home
            continue
        if (hw & 0xC000) != 0xC000:
            continue                                  # some other FCW
        hi, lo = hw >> 8, hw & 0xFF
        for c in (((hi & 0x3F) << 1) | (lo >> 7), lo & 0x7F):
            if c == 0:
                continue
            if c == 0x0D:                             # carriage return
                y += 1; x = home; continue
            ch = glyph(c)
            if ch is None:
                continue                              # a control, not a cell
            if 1 <= y <= SCREEN_ROWS and 1 <= x <= SCREEN_COLS:
                grid[y - 1][x - 1] = ch
            x += 1
    return grid

def show_screen(grid):
    print("     " + "".join(str(((c + 1) // 10) % 10) or " " for c in range(SCREEN_COLS)))
    print("     " + "".join(str((c + 1) % 10) for c in range(SCREEN_COLS)))
    print("    +" + "-" * SCREEN_COLS + "+")
    for i, row in enumerate(grid, 1):
        print(f" {i:2d} |" + "".join(row) + "|")
    print("    +" + "-" * SCREEN_COLS + "+")

def decode_text(hws):
    """Characters from a CHAR run.

    Two 7-bit characters per halfword, with the FIRST character's low bit
    displaced into the top bit of the second byte:

        hi = (c1 >> 1) | 0xC0        lo = ((c1 & 1) << 7) | c2

    so hi & 0xC0 == 0xC0 identifies a text halfword and distinguishes it from
    the FCWs and control words that share a CHAR run.  A trailing 0 pads an
    odd-length string.  Derived from the corpus, not from a document: it
    reproduces the deck's own text for 4016 of 4172 CHAR runs, and every
    remaining run differs only by the 0x16 glyph above."""
    out = []
    for x in hws:
        if x is None:
            continue
        hi, lo = x >> 8, x & 0xFF
        if (hi & 0xC0) != 0xC0:
            continue
        for c in (((hi & 0x3F) << 1) | (lo >> 7), lo & 0x7F):
            if c == 0:
                continue
            g = glyph(c)
            out.append(g if g is not None else f"<{c:02X}>")
    return "".join(out)

def parse(path):
    """[(offset, value, statement, detail)] in declaration order.

    Declaration order is memory order within the COMPOOL, so the running
    count of emitted halfwords IS the offset into the CSECT."""
    # A NAME declaration occupies a halfword but emits no HEX literal: it is
    # a relocated address, filled in by the linker.  Missing them silently
    # shifted every later offset -- CV1000 parsed as 716 halfwords against a
    # section of 800, and it has exactly 84 of them.  Carried as a None value,
    # which is also the honest answer for what they hold.
    NAMEDECL = re.compile(r"^\s*DECLARE\s+\S+\s+NAME\b")
    stmt, detail, out, off = None, [], [], 0
    for raw in open(path, errors="replace"):
        line = raw.rstrip("\n")
        if line.startswith("C -- "):
            stmt, detail = line[5:].strip(), []      # a deck statement
            continue
        if line.startswith("C - "):
            detail.append(line[4:].strip())          # a field explanation
            continue
        if line.startswith("C ") or line.startswith("D "):
            # continuation of a wrapped statement comment, e.g. a long VPARM
            if stmt is not None and line[2:].strip() and not line[2:].strip().startswith("*"):
                stmt += " " + line[2:].strip()
            continue
        if NAMEDECL.match(line):
            out.append((off, None, stmt, tuple(detail)))
            off += 1
            continue
        for m in HEXV.finditer(line):
            out.append((off, int(m.group(1), 16), stmt, tuple(detail)))
            off += 1
    return out

def hw_image(path):
    b = pathlib.Path(path).read_bytes()
    return [(b[i] << 8) | b[i + 1] for i in range(0, len(b) - 1, 2)]

def show(rows, dump=None, base=None, only_diff=False):
    last = None
    for off, val, stmt, detail in rows:
        if stmt != last:
            print(f"\n  {stmt or '(no statement)'}")
            for d in detail:
                print(f"      . {d}")
            last = stmt
        if dump is None:
            print(f"      +{off:<5} " + ("addr" if val is None else f"{val:04X}"))
        else:
            i = base + off
            theirs = dump[i] if 0 <= i < len(dump) else None
            if val is None:
                t = "----" if theirs is None else f"{theirs:04X}"
                print(f"      +{off:<5} ours=addr dump={t}   (relocated address)")
                continue
            mark = "" if theirs == val else "   <-- DIFFERS"
            if only_diff and not mark:
                continue
            t = "----" if theirs is None else f"{theirs:04X}"
            print(f"      +{off:<5} ours={val:04X} dump={t}{mark}")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("hal", nargs="?",
                   help="generated .hal; not needed with --decode/--corpus")
    p.add_argument("--at", type=int)
    p.add_argument("--count", type=int, default=16)
    p.add_argument("--find")
    p.add_argument("--dump")
    p.add_argument("--address")
    p.add_argument("--only-diff", action="store_true")
    p.add_argument("--corpus", help="directory of generated .hal to search "
                                    "with --find, instead of one file")
    p.add_argument("--decode", help="decode a comma-separated halfword "
                                    "sequence as DEU text")
    p.add_argument("--over", help="background deck to composite under this one")
    p.add_argument("--no-pair", action="store_true",
                   help="do not look for the X background twin")
    p.add_argument("--bounded", action="store_true",
                   help="render only [background, DDT) from the DFT header: "
                        "far less noise, but provably drops text in most "
                        "decks -- see display_list()")
    p.add_argument("--whole", action="store_true",
                   help="with --screen: render every halfword, not just the "
                        "display list the DFT header delimits")
    p.add_argument("--screen", action="store_true",
                   help="render the halfwords as the 51x26 character screen")
    p.add_argument("--text", action="store_true",
                   help="with --dump: decode the dump's halfwords as text")
    a = p.parse_args()
    if a.decode:
        hws = [int(x, 16) for x in re.split(r"[ ,]+", a.decode.strip()) if x]
        print(decode_text(hws))
        return
    if a.screen:
        amt = amt_of(a.hal) if a.hal else None
        if amt and not a.dump:
            print(f"{pathlib.Path(a.hal).name} is not a display: it is the "
                  f"moding table {amt}.")
            print("It has no CHAR/XC/YC statements, so there is no screen to "
                  "draw.  Use --at/--find to read it as data.")
            return
        if a.dump:
            dump = hw_image(a.dump)
            base = int(a.address, 16)
            hws = dump[base:base + a.count]
        else:
            grid = None
            bg = None if a.no_pair else (pathlib.Path(a.over) if a.over else twin(a.hal))
            if bg:
                grid = render_annotated(parse(bg))
                print(f"    background: {pathlib.Path(bg).name}   "
                      f"foreground: {pathlib.Path(a.hal).name}")
            show_screen(render_annotated(parse(a.hal), grid))
            return
        show_screen(render(hws))
        return
    if a.dump and a.text:
        dump = hw_image(a.dump)
        base = int(a.address, 16)
        w = dump[base:base + a.count]
        print(f"{a.count} halfwords at {base:X}:")
        if a.hal:
            print(f"   ours: {decode_text([r[1] for r in parse(a.hal)][:a.count])}")
        print(f"   dump: {decode_text(w)}")
        return
    if a.corpus and a.find:
        want = [int(x, 16) for x in re.split(r"[ ,]+", a.find.strip()) if x]
        found = 0
        for f in sorted(pathlib.Path(a.corpus).glob("*.hal")):
            rows = parse(f)
            vals = [r[1] for r in rows]
            for i in range(len(vals) - len(want) + 1):
                if vals[i:i + len(want)] == want:
                    stmts = []
                    for r in rows[i:i + len(want)]:
                        if not stmts or stmts[-1] != r[2]:
                            stmts.append(r[2])
                    print(f"{f.stem:<9} @{i:<5} {' | '.join(str(x) for x in stmts)}")
                    found += 1
        print(f"\n{found} occurrence(s) of the {len(want)}-halfword sequence")
        return
    rows = parse(a.hal)
    if a.find:
        want = [int(x, 16) for x in re.split(r"[ ,]+", a.find.strip()) if x]
        vals = [r[1] for r in rows]
        hits = [i for i in range(len(vals) - len(want) + 1)
                if vals[i:i + len(want)] == want]
        if not hits:
            print(f"{len(want)} halfword(s) not found in {a.hal}")
            return
        for h in hits:
            print(f"=== match at offset {h} ===")
            show(rows[h:h + len(want)])
        return
    if a.at is not None:
        rows = [r for r in rows if a.at <= r[0] < a.at + a.count]
    dump = base = None
    if a.dump:
        dump = hw_image(a.dump)
        base = int(a.address, 16)
    show(rows, dump, base, a.only_diff)

main()
