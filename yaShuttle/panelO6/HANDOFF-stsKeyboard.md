# HANDOFF: stsKeyboard.py

Working notes for a later session.  `stsKeyboard.py` is the Space Shuttle
DPS keyboard simulator in `yaShuttle/panelO6/`.  It is finished as a
visual, mouse-driven 8×4 keypad that prints every press and release to
stdout.  It does **not** yet send keystrokes to `yaGPC2` or `MEDS2.py`.

Built in the same 2026-09-04 session as `panelO6.py`, after the C3/F6
blocks were accepted and before `--size` / the paddle variant.  Styling
and window habits were copied from `panelO6.py`; the key layout matches
`yaShuttle/shuttleCrewInterface.py` (and the commander/pilot keyboards
in the SCOM).

323 lines at the time of this handoff.

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
cd yaShuttle/panelO6
python3 stsKeyboard.py
python3 stsKeyboard.py --size 512
python3 stsKeyboard.py --geometry 520x1020+80+20
```

- `--size N`: scale the window and contents.  **1024 is full size**
  (the design default).  512 is half.  Same convention as `panelO6.py`.
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

Examples: `stsKeyboard: FAULT SUMM  down` then `stsKeyboard: FAULT SUMM  up`.

Cursor is `hand2` over a key.  Nothing is sent to `yaGPC2`, the IDP
keyboard bus, or `MEDS2.py`.  `MEDS2.py` already listens for scan codes
on `_KYBD1` so this keyboard can feed it later; that wire does not
exist yet.

---

## Implementation notes that are easy to break

**Layout is computed from the live canvas, not from REF_W/H.**
`_layout()` picks the largest square key `k` that fits
`NCOL` keys and `NCOL+1` gaps (same for rows) in the current window,
then centres the grid.  `REF_W`/`REF_H` (509×1004 at `KEY_REF=110`)
only set the default `--size 1024` window.  Resize keeps squares and
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

`--size N` with 1024 = current full size, on both apps.  Then the user
noticed fonts not shrinking at small sizes.  Cause: `max(6, …)` in both
programs.  Floor became 1 pt.  Commits `7389164a0`, `d0732f754`.

No further stsKeyboard-only changes after that.  The paddle work and
`MEDS2.py` did not touch this file.

---

## What is still open

- **yaGPC2 / IDP / MEDS2 keystrokes.**  Intentionally unwired.  `MEDS2.py`
  already accepts scan codes on `_KYBD1`; `stsKeyboard.py` would be the
  natural source once someone maps `key_id` to those scans.
- Multiple keyboards (CDR vs PLT) as in `shuttleCrewInterface.py`: this
  app is one window.
- The period key logs as `.` (`key_id` of `(".",)`), even though it is
  drawn as a disc.

---

## Related files

- `panelO6.py` / `panelO6-paddle.py` — same session, same `--size` and
  no-focus habits.  See `HANDOFF-panelO6.md`.
- `yaShuttle/shuttleCrewInterface.py` — older OpenCV keyboard; same 8×4
  captions, different look (photo of the hardware), already queues
  `pressed` / `released` strings.
- `MEDS2.py` — MDU/IDP runner that can consume keyboard scans later.

---

## Git (this file)

```
60c3b2f22 2026-09-04  stsKeyboard: shuttle DPS keyboard, 8x4 black square keys
a7bac10dc 2026-09-04  stsKeyboard: one size for function keys, larger hex keypad, disc for '.'
ead5b55ca 2026-09-04  stsKeyboard: smaller RESUME face, tighter caption margins
7389164a0 2026-09-04  panelO6, stsKeyboard: --size N scales the window (1024 is full)
d0732f754 2026-09-04  panelO6, stsKeyboard: let fonts scale below 6 pt
```
