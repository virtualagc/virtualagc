# HANDOFF: stsKeyboard.py

Working notes for a later session.  `stsKeyboard.py` is the Space Shuttle
DPS keyboard simulator, now in `yaShuttle/discretePanel/` (moved from
`yaShuttle/panelO6/` in `a14cf8ba6`).  It is a mouse-driven 8×4 keypad
that sends each key's scan code to `MEDS2.py` on a MEDS keyboard bus
(`--kybd N`) and prints every press and release to stdout.  It does not
talk to `yaGPC2` directly: the IDP in `MEDS2.py` forwards keys to the
GPC.

Built in the same 2026-09-04 session as `panelO6.py`, after the C3/F6
blocks were accepted and before `--size` / the paddle variant.  Styling
and window habits were copied from `panelO6.py`; the key layout matches
`yaShuttle/shuttleCrewInterface.py` (and the commander/pilot keyboards
in the SCOM).

323 lines at the time of this handoff; 438 after the bus wiring,
`--port-base` and `--title`; 435 with the numeric caption.

---

## What it is

A Python 3 tkinter Canvas app: eight rows of four **equal square**
momentary pushbuttons, black with white Helvetica legends, on the same
gull-grey pane as O6 (`#c6c3b6`).  The gap between keys equals the
margin from the outer keys to the window edge (`GAP_RATIO = 1/8` of the
key).

Every key is the same size.  Captions differ.

---

## How to run

```bash
cd yaShuttle/discretePanel
python3 stsKeyboard.py
python3 stsKeyboard.py --kybd 2
python3 stsKeyboard.py --size 512
python3 stsKeyboard.py --geometry 520x1020+80+20
```

- `--size N`: scale the window and contents.  **768 is full size**
  (`FULL_SIZE = 768`, the design window 509×1004, and the default);
  512 is 2/3 (339×669), 384 is half (254×502), 1024 is 4/3 (679×1339).
  Same unit as `panelO6.py`.  `MEDS2.py` keeps pixels (1024 = full).
- `--kybd N`: the MEDS keyboard bus to send on, 1-3 (default 1).
- `--port-base N`: the bus port base (default 6900, or
  `NSTS_BUS_PORT_BASE`); the keyboard buses are base+31..base+33.  Same
  option as `yaGPC2`, `MEDS2.py` and `panelO6.py`.
- `--title TEXT`: window caption; default just the keyboard number,
  `1`, `2` or `3` (1 left/CDR, 2 right/PLT, 3 aft).  Longer captions
  (`KYBD1`) truncated at the small `--size` values many-CRT runs use, and
  which keyboard it is is all the caption must say.  Help: "window
  caption (default the keyboard number, 1..3: 1 left, 2 right, 3 aft)".
- `--geometry SPEC`: exact Tk geometry; **overrides `--size`**.
- `NSTS_KEYBOARD_GEOMETRY` is the env-var equivalent of `--geometry`.
- Logging prefix is `stsKeyboard:`.
- The window tries not to steal keyboard focus (`_dont_steal_focus`,
  same `xprop` / `wmctrl` trick as `panelO6.py`).
- Tk font sizes are points, floored at **1 pt** so legends keep shrinking
  with `--size`.  There used to be a 6 pt floor (and the first draft
  fitted type down to 6 pt per key); that froze legends around
  `--size 512` and was dropped in the same commit as `panelO6.py`.

---

## Key grid (row-major)

User-given captions, stored as one- or two-line tuples.  Two-line keys
are stacked and centred as a block.

```
FAULT/SUMM    SYS/SUMM    MSG/RESET    ACK
GPC/CRT       A           B            C
I/O RESET     D           E            F
ITEM          1           2            3
EXEC          4           5            6
OPS           7           8            9
SPEC          -           0            +
RESUME        CLEAR       .            PRO
```

This is the same 8×4 as `shuttleCrewInterface.py`’s `buttons` array
(there the two-line labels are single strings `"FAULT SUMM"`,
`"GPC/CRT"`, …).  `stsKeyboard.py` splits them so they can draw on two
lines inside the square.

### Terminology the user defined (keep it)

- **Hex keypad**: captions `0`–`9`, `A`–`F`, `-`, `+`.
  (`HEX_CAPTIONS` in the source.  The user also said “numeric keypad”
  for the 1.6× size; that is this set, not a separate pad.)
- **Other keys**: everything else, including EXEC, RESUME, ACK, ITEM,
  OPS, SPEC, PRO, CLEAR, the two-line function keys, and the period
  key’s *face* (the period itself is not a glyph).

The period is **not** in the hex keypad.

---

## Typography (do not “improve”)

Measured against EXEC on the original 88 px keys, which fitted at
**10 pt** on this display (`OTHER_PTS_REF = 10`).  All three sizes
scale with key pixel size `k / KEY_REF`.

| Kind | Size |
|---|---|
| Other keys | 10 pt at design size (`k == KEY_REF`) |
| Hex keypad | **1.6×** other (`HEX_FONT_SCALE`) |
| RESUME | **0.75×** other (`RESUME_FONT_SCALE`) |
| Period | not text: a filled white disc, diameter = width of a lowercase **o** in the *other-keys* font, centred on the button |

`KEY_REF = 110` is the design key in reference pixels.  It was chosen so
that at 10 pt the remaining other-key legends (CLEAR is the widest once
RESUME is reduced) sit about **half a character** in from the edge.

The first draft auto-fitted a font per key (`_legend_font`, inner 86% of
the key, floor 6 pt), so EXEC was smaller than RESUME and hex digits
were small.  The user locked other keys to EXEC, grew the squares, and
drew `.` as a disc.  Do not go back to per-key fitting.

---

## Behaviour

Momentary: mouse-down logs `down` and redraws the key depressed (1 px
nudge, inverted bevel, fill `#000000`); mouse-up logs `up` and restores
it.  Release anywhere counts; `_held` is not cancelled by leaving the
key.

Log names (`key_id`):

- One line: the caption (`A`, `EXEC`, `PRO`).
- Two lines whose first ends in `/`: concatenated (`GPC/` + `CRT` →
  `GPC/CRT`).
- Other two-line: joined with a space (`FAULT SUMM`, `I/O RESET`).

Examples: `stsKeyboard: FAULT SUMM  down -> KYBD1 0xFFE1` then
`stsKeyboard: FAULT SUMM  up` (the `-> KYBDn 0x....` suffix appears only
when the send succeeded).

Cursor is `hand2` over a key.

### The keyboard bus

A key is sent on **press**, not release, as the MDU window's keydown
does.  Each keystroke is one UDP multicast datagram to 239.255.1.1,
port 6931+N-1 at the default base (`KYBD_PORT`), holding the key's
**scan code** as a single big-endian halfword.  The socket is pinned
to `NSTS_BUS_IFACE` (default 127.0.0.1), the interface `MEDS2.py`'s
buses use; without that the datagram leaves by the default route and
no listener sees it.

`SCAN` is copied from `KYBD.DEUKey` in `MEDS2.py` (where the IDP looks
keys up, `KYBD.byScan`), cross-checked 32/32.  These are the row/column
strobe patterns the keyboard puts on the bus, not the 5-bit code the
GPC is eventually given.

Which IDPs are wired to each bus (`MEDSConf` in `MEDS2.py`): KYBD1 ->
IDP1, IDP3; KYBD2 -> IDP2, IDP3; KYBD3 -> IDP4 only.  MEDS's table also
wired IDP2 to KYBD3; that was removed, since the aft keyboard "can
communicate only with IDP 4" (Crew Software Interface USA006083 Rev B
§2.6).  Which IDP a forward keyboard actually reaches is `panelO6.py`'s
panel C2 IDP/CRT SEL switches, not the window: left -> IDP 1 or 3,
right -> IDP 2 or 3.  The IDP takes `_KYBD1`/`_KYBD2` keys only while
selected (the `KYBD_SEL` message; `kybdSel`, all wired buses heard
until one arrives); `_KYBD3` has no switch.  An MDU echoes the scratch
pad for the first keyboard its primary IDP is wired to, and only while
its primary IDP's heartbeat says that keyboard is selected
(`kybdMask`):

```
KYBD1  crt1 crt3 cdr1 cdr2 plt2 mfd2
KYBD2  crt2 plt1 mfd1
KYBD3  crt4 afd1
```

The echo depends on a `MEDS2.py` departure (`KYBD.recvKYBD` echoes keys
from other senders; see `HANDOFF-meds2-py.md` §10), because the IDP
never sends typed keys back to the MDU.

Verified end to end against `MEDS2.py crt1 idp1`: IDP1 queued
[SPEC,1,2,PRO] and crt1 drew "SPEC 12 PRO"; a KYBD2 key reached
neither.  Also in a namespace run: IDP1 logged
"KYBD1: _KYBD1 recv ITEM/1/EXEC" and its next poll reply carried
KYBD_MSG.

`simulatePASS.py` starts **three keyboards** by default (`--keyboards
0-3`, default 3: left, right, aft; 2 the forward pair; 1 the left;
`--no-keyboard` = 0): keyboard k is `stsKeyboard.py --kybd k --title k`
with the run's `--port-base`, `--size` and a stacked or side-by-side
`--geometry`.

---

## Implementation notes that are easy to break

**Layout is computed from the live canvas, not from REF_W/H.**
`_layout()` picks the largest square key `k` that fits
`NCOL` keys and `NCOL+1` gaps (same for rows) in the current window,
then centres the grid.  `REF_W`/`REF_H` (509×1004 at `KEY_REF=110`)
only set the default `--size 768` window.  Resize keeps squares and
equal gaps.

**Window background is the pane grey**, not `C_WINDOW`.  `C_WINDOW` is
defined (same `#2a2a2a` as O6) but unused; `root` and the canvas are
`C_PANEL`.

**Depressed bevel** swaps highlight and shadow.  Keys have a 1 px black
outline plus inner hi/lo lines.

**Two-line stacking** uses the font’s `linespace`, centred as a block on
the key.  Do not add extra leading; the first draft’s tighter/looser
experiments lived on O6 side captions, not here.

**Font floor is 1 pt.**  `_tkfont` and `_pts_for` both `max(1, …)`.  The
6 pt clamp was shared with `panelO6.py` and dropped together.

---

## Creation process

### 1. Original request (2026-09-04)

After O6 + C3/F6 was “Excellent, thanks!”, the user asked for a new
Python 3 program `stsKeyboard.py` with the same rationale, sizing, and
styling as `panelO6.py`, but:

- square pushbuttons, all the same size
- small gap between keys, **the same gap** between outer keys and the
  window edge
- 8 rows × 4 columns
- black keys, white lettering, captions centred
- the 32 captions listed above, some two-line

First draft fitted type per key on `KEY_REF = 88` px squares.  Press and
release printed to stdout.  Commit `60c3b2f22` *stsKeyboard: shuttle DPS
keyboard, 8x4 black square keys*.

### 2. Hex vs other, period disc

User defined **hex keypad** vs **other keys**.  Other keys must use the
font size EXEC currently had; grow the buttons if legends overflow.  Hex
(the user said “numeric keypad” here) about **1.6×**.  The `.` key is a
disc the size of a lowercase `o` in the other-keys face, not the
character `"."`.

EXEC at the original 88 px key was 10 pt.  Buttons grew to `KEY_REF =
140` so RESUME and CLEAR (then the widest other-keys) stayed inside at
10 pt.  Hex became 16 pt.  Commit `a7bac10dc` *stsKeyboard: one size for
function keys, larger hex keypad, disc for '.'*.

### 3. RESUME 75%, tighter margins

User: RESUME about **75%** of the other-keys face; reduce the caption-to-
edge margin to about **half a character**.  Hex stayed 1.6× (not scaled
with the RESUME shrink).  `KEY_REF` dropped **140 → 110** because CLEAR
is now the widest other-key.  Commit `ead5b55ca`.

User: “Excellent, thanks!”

### 4. `--size` and the 6 pt floor (same day, shared with panelO6)

`--size N` with 1024 = current full size, on both apps (the unit later
became 768; see 6).  Then the user
noticed fonts not shrinking at small sizes.  Cause: `max(6, …)` in both
programs.  Floor became 1 pt.  Commits `7389164a0`, `d0732f754`.

No further stsKeyboard-only changes that day.  The paddle work and
`MEDS2.py` did not touch this file.

### 5. Wired to the MEDS keyboard bus (2026-09-11)

Keys go to `MEDS2.py` as scan codes on `_KYBDn` (`--kybd N`), sent on
press; see "The keyboard bus" above.  Commit `3a07fa351`.  The file
moved to `yaShuttle/discretePanel/` with the other peripherals
(`a14cf8ba6`).

### 6. `--size` unit 768 (2026-09-11)

At the user's request, `FULL_SIZE = 768` to match `panelO6.py`, so
`--size 512` is two-thirds.  `MEDS2.py` kept pixels.  Commit `718801b04`.

### 7. `--port-base` and a short caption (2026-09-12)

`--port-base` (and `NSTS_BUS_PORT_BASE`) so two simulations can run side
by side (`57e82b497`).  Caption `KYBD1` rather than a truncated
"STS Key..." and `--title` to override it (`6212e7b6d`).

### 8. Caption is the keyboard number (2026-09-14)

`KYBD1` also truncated at the small `--size` values of many-CRT runs, so
the default caption became `1`/`2`/`3`; `simulatePASS.py` passes the
same.  Verified: a `--kybd 2` window is titled "2".  Commit `81d4b5570`.

---

## What is still open

- A keyboard stays on its `--kybd` bus; which IDP hears it is decided
  in `MEDS2.py` by panel C2's IDP/CRT SEL, not here.
- An MDU echoes only the first `_KYBDn` its primary IDP is wired to, so
  KYBD2 keys reach IDP3 but do not echo on crt3/cdr1/plt2.
- Several keyboards are several processes, one bus each.
- The period key logs as `.` (`key_id` of `(".",)`), even though it is
  drawn as a disc.

---

## Related files

- `panelO6.py` / `panelO6-paddle.py` — same session, same `--size` and
  no-focus habits.  See `HANDOFF-panelO6.md`.
- `yaShuttle/shuttleCrewInterface.py` — older OpenCV keyboard; same 8×4
  captions, different look (photo of the hardware), already queues
  `pressed` / `released` strings.
- `MEDS2.py` — MDU/IDP runner; its IDPs consume these scan codes
  (`KYBD.DEUKey`, `MEDSConf`).  See `HANDOFF-meds2-py.md`.
- `simulatePASS.py` — launcher; starts three keyboards by default.
- `panelO6.py` panel C2 — IDP/CRT SEL, which IDP each forward keyboard
  reaches.

---

## Git (this file)

```
60c3b2f22 2026-09-04  stsKeyboard: shuttle DPS keyboard, 8x4 black square keys
a7bac10dc 2026-09-04  stsKeyboard: one size for function keys, larger hex keypad, disc for '.'
ead5b55ca 2026-09-04  stsKeyboard: smaller RESUME face, tighter caption margins
7389164a0 2026-09-04  panelO6, stsKeyboard: --size N scales the window (1024 is full)
d0732f754 2026-09-04  panelO6, stsKeyboard: let fonts scale below 6 pt
a14cf8ba6 2026-09-11  Rationalized and collected Shuttle peripherals into discretePanel/.
3a07fa351 2026-09-11  stsKeyboard: send its keys to MEDS2.py on a MEDS keyboard bus
718801b04 2026-09-11  stsKeyboard: --size unit is 768, so --size 512 is two-thirds size
57e82b497 2026-09-12  MEDS2.py, stsKeyboard.py: --port-base, so two simulations can run side by side
6212e7b6d 2026-09-12  stsKeyboard.py: caption "KYBD1", not "STS Key..."
81d4b5570 2026-09-14  Keyboard windows titled 1, 2, 3; R11 inset's right margin matches its left
```
