# HANDOFF: panelO6.py and panelO6-paddle.py

Working notes for a later session.  These two programs are the GPC / BFC
hardware-control simulators in `yaShuttle/panelO6/`.  They are finished as
visual, mouse-driven panels that print every control change to stdout.
They do **not** yet send discretes to `yaGPC2`.

The filename is `panelO6-paddle.py` (letter O, not digit 0).

---

## What they are

Two Python 3 tkinter Canvas apps that draw the GPC half of Space Shuttle
overhead panel **O6**, plus the BFC CRT block from panel **C3** and the BFC
DISENGAGE block from panel **F6**.

| File | What it draws for 2- and 3-position switches |
|---|---|
| `panelO6.py` | Sliding cream capsules in a rectangular black well inside a grey guard |
| `panelO6-paddle.py` | Bat-handle paddles on a circular well; thrown positions tilt, a 3-position middle faces the camera |

Layout, click handling, talkback logic, logging, `--size`, and
`--geometry` are the same.  `panelO6-paddle.py` was copied from
`panelO6.py` and only the switch bodies were replaced.

Line counts at the time of this handoff: `panelO6.py` 1011,
`panelO6-paddle.py` 1027.  The diff is almost entirely `_guarded_toggle`,
`_draw_paddle` / `_draw_paddle_h`, and the bat-handle helpers.  Paddle
does not use `_vbar` / `_hbar` (those exist only in `panelO6.py`).

---

## How to run

```bash
cd yaShuttle/panelO6
python3 panelO6.py
python3 panelO6.py --size 512
python3 panelO6.py --geometry 948x1250+80+20

python3 panelO6-paddle.py
python3 panelO6-paddle.py --size 512
```

- `--size N`: scale the window and contents.  **1024 is full size**
  (the design default).  512 is half.  Contents scale with the window.
- `--geometry SPEC`: exact Tk geometry; **overrides `--size`**.
- `NSTS_O6_GEOMETRY` is the env-var equivalent of `--geometry`.
- Logging prefix is `panelO6:` in both programs.
- Windows try not to steal keyboard focus (`_dont_steal_focus`, copied
  from `discretePanel.py`: `takefocus=0`, `_NET_WM_USER_TIME=0`, then
  `wmctrl` back to the previous active window).

Tk font sizes are points, floored at **1 pt** so legends keep shrinking
with `--size`.  There used to be a 6 pt floor; it froze type around
`--size 512` and was dropped.

---

## Sources of the layout

Do not trust PDF page numbers from memory.  Measure:

- **SCOM** USA007587 Rev A,
  `~/Desktop/sandroid.org/public_html/apollo/Shuttle/Space Shuttle Crew Operations Manual.pdf`
  - Figure **GENERAL PURPOSE COMPUTER Hardware Controls**, printed
    page **2.6-4**, PDF page **228**.  The original request said PDF 223;
    that page is crew systems, not O6.
  - BFC insets: printed page **2.6-25**, PDF page **249**, the thick-black
    highlighted blocks titled **BFC CRT** (C3) and **BFC DISENGAGE** (F6).
- **DPS Familiarization Workbook**,
  `~/Desktop/sandroid.org/public_html/apollo/Shuttle/Crew Training/DPS Familiarization Workbook.pdf`
  — used to settle talkbacks vs switches (row 2 and row 5).
- `yaShuttle/discretePanel/` is the **yaGPC2 discrete protocol** to reuse
  later.  It is **not** the visual reference.  The user said so on day
  one: ttk look is wrong; match the SCOM hardware.

The physical O6 also has MDM power switches on the left.  Those are
**not drawn**.  Only the GPC half plus the C3/F6 BFC blocks.

---

## What is on the panel

O6 is an L-shaped light-gull-grey pane (`#c6c3b6`): a main rectangle of
five GPC columns, plus a right-hand tab for IPL SOURCE.  Columns are
GPC1 … GPC5 left to right.

| Row | What | Positions / states |
|---|---|---|
| 1 | POWER, 2-position toggle | ON (up), OFF (down) |
| 2 | OUTPUT **talkbacks** (not switches) | GRAY = may transmit on the FC buses; barberpole = may not |
| 3 | OUTPUT, 3-position toggle | BACKUP / NORMAL / TERMINATE |
| 4 | INITIAL PROGRAM LOAD, momentary pushbuttons | ON while held, OFF on release |
| 5 | MODE **talkbacks** (not switches) | RUN, or IPL while the IPL button is held, else barberpole |
| 6 | MODE, 3-position toggle | RUN / STBY / HALT.  Real hardware is lever-locked in RUN; this sim does not require pulling a lock |
| Right tab | IPL SOURCE, 3-position toggle | MMU 1 (up) / OFF (middle) / MMU 2 (down) |

C3 and F6 sit in the O6 concave cutout, above the IPL SOURCE tab, so the
window can be narrower than “O6 plus a column to the right of everything”.

| Block | Controls |
|---|---|
| C3 **BFC CRT** | DISPLAY ON/OFF (2-pos vertical); SELECT 1+2 / 2+3 / 3+1 (3-pos vertical).  `2+3` is a stacked side caption, nudged `SETTING_SIZE * 2/3` right of the SELECT guard so it clears the decorative box |
| F6 **BFC DISENGAGE** | One horizontal 2-position toggle, unlabeled.  RIGHT disengages the BFS; LEFT is the rest position |

Click the upper / middle / lower (or left / right) third of a toggle to
put it there.  Cursor becomes `hand2` over a hit.  IPL is press-and-hold.

---

## Talkbacks (local stand-in until a GPC is attached)

OUTPUT talkback for GPC *i* is GRAY only if POWER is ON **and** OUTPUT is
NORMAL **and** MODE is RUN; otherwise barberpole.

MODE talkback is IPL while that GPC’s IPL button is down, else RUN if
MODE is RUN, else barberpole.  The SCOM MODE window is silk-screened
RUN; that word is shown in the RUN state and replaced by IPL / stripes.

Barberpole is a `PhotoImage` of diagonal cream/black stripes, cached by
pixel size.

These are **approximations**.  On the vehicle the talkbacks are GPC
output discretes, not a function of the crew switches alone.

---

## Startup defaults (typical pre-flight)

- All POWER ON
- OUTPUT NORMAL on GPC1–4, **BACKUP on GPC5** (BFS)
- All MODE HALT
- IPL SOURCE OFF
- BFC CRT DISPLAY OFF, SELECT 1+2
- BFC DISENGAGE LEFT
- All talkbacks barberpole (nothing is in RUN)

Every change, and a full dump at startup, prints to stdout.

---

## Implementation notes that are easy to break

**Reference coordinates.**  Layout lives in a 948×1250 design space
(`REF_W` × `REF_H`).  `FULL_SIZE = 1024` is the `--size` unit for “the
window as designed”, not 948.  On resize, `s = min(cw/REF_W, ch/REF_H)`
and the drawing is centred.  All drawing helpers (`X`, `Y`, `_text`,
`_rect`, …) go through that scale.

**Vertical rhythm is from glyph bounds, not centre-to-centre steps.**
`_layout()` accumulates `th = half linespace / s` plus `pad = 10` around
every caption.  Centre-anchored text previously ate the gaps, so OUTPUT
numbers sat on the talkbacks and MODE overwrote the GPC numbers.  Do not
go back to packing from caption centres.

**Setting captions** (ON/OFF, BACKUP/TERMINATE, RUN/HALT, MMU 1/2) are
all `SETTING_SIZE = 8` pt, the same as the stacked side captions
(NORMAL, STBY, OFF, 2+3).  Group titles (POWER, OUTPUT, MODE, …) stay
larger.  ON/OFF, BACKUP/TERMINATE, RUN/HALT sit on the GPC3 column
(`self.mid`).  Side captions sit 14 px past the guard edge, equally on
left and right.

**IPL button digits.**  `create_text` anchor `c` uses the full em box, so
digits sat high.  `_pushbutton` shifts down by half the font descent so
the ink is centred on the inner face.

**Fonts.**  `_font()` must pass **points** to `create_text`.  An early
version used `Font.actual("size")`, which is pixels on this Tk, and
every label blew up.  `_tkfont()` is metrics only.

**Focus.**  These windows are meant to sit beside a terminal / GPC run
without grabbing keys.  That is why `_dont_steal_focus` exists.

**panelO6.py switch body.**  Rectangular grey guard, inset black well,
cream rounded bar (`_vbar` / `_hbar`) with a groove.  Two-position bars
are taller (or wider) than three-position so they stay bars, not discs.

**panelO6-paddle.py switch body.**  No rectangular guard.

- Circular well centred on the mid-throw (the pivot).  Diameter started
  at twice paddle width, then **10% smaller**: `paddle_w * 0.90` with
  `paddle_w = thick * 0.60`.
- Well fill `C_WELL = #d9d6cb`, midway between pane `#c6c3b6` and paddle
  cream `#eceadf`.  (An intermediate step used a grey between black and
  cream; the user then asked for pane-to-paddle.)
- Bushing (mounting nut) at the pivot.
- Thrown handle: polygon shaft plus an **oval** cap, flattened to **70%**
  along the shaft (`along = tip_h * 0.70`).  Sign −1 is up/left, +1 is
  down/right.  Thrown paddles still reach past the disk.
- Three-position **middle** is end-on (`_bat_face`): ellipse pointing at
  the camera, specular blob, rim groove.
- F6 uses the same geometry on axis `"x"`.

Hit boxes are still the original rectangular guard extents, so clicking
still uses `_zone` thirds even though the art is a disk.

---

## Creation process

All of this was built in one conversation (2026-09-02 through 2026-09-09)
in `yaShuttle/panelO6/`, which started empty.

### 1. Original request (2026-09-02)

Python 3 `panelO6.py`: emulate O6 appearance, cross-platform, workable
controls, print changes to the terminal.  Eventually send discretes to
`yaGPC2`; not now.  The user supplied a six-row textual reading of the
SCOM figure, including a misreading of row 2 as two-position OUTPUT
slide switches (unlabeled ON/OFF) and uncertainty about row 5 (“RUN”).

### 2. Finding the real figure

PDF page 223 is not O6.  The GPC figure is printed 2.6-4 / PDF 228.
`discretePanel/` was read and then set aside as protocol-only after the
user said its ttk look is not the styling wanted.

The DPS Familiarization Workbook’s Panel O6 section settled the
misreadings:

- Row 2 hatched windows are **OUTPUT talkbacks**, driven by GPC
  discretes, not a crew switch.
- The OUTPUT **switch** is row 3 (BACKUP / NORMAL / TERMINATE).
- Row 5 is the **MODE talkback** (RUN / IPL / barberpole), not a lamp
  and not a control.

First commit: `52a78c49d` *panelO6: visual simulator for the GPC
hardware-controls half of overhead panel O6*.

Early drawing bugs: paddles collapsing into circles; POWER/MODE labels
covering GPC 3.

### 3. Caption and spacing iterations (same day)

User: side captions unreadable (letters overlapping); above/below
setting fonts larger than the side fonts — they must match.

Then: drop the simulated Phillips-head screws; stacked side-caption
leading was now too loose (cut ~80%); pull left-side captions in to
match the right; regularize vertical white space (HALT sat on the MODE
switches while RUN sat on the MODE title, and MODE overwrote GPC numbers
`1 2 MODE 4 5`); split `IPL SOURCE` onto two lines so it does not run
off the tab.

Then: centre the IPL SOURCE cluster in the tab; put ON/OFF,
BACKUP/TERMINATE, RUN/HALT on GPC3; add real whitespace above and below
**all** text (OUTPUT numbers overlapping the talkbacks was the worst
case).  That is when `_layout()` switched to glyph-bound padding.

`Font.actual("size")` pixel/point mix-up happened in this stretch and
was undone.

User: “That'll work, thanks!”

Commits `8de9ec8cf`, `74e92c9be`, `32208fea5`.

### 4. C3 and F6 (2026-09-04)

User pointed at SCOM PDF 249, the highlighted **BFC CRT** and **BFC
DISENGAGE** insets.  Widen the window to the right; C3 block on top, F6
below; same pane grey, same control sizes.

Then: `2+3` overlapped SELECT and should be a vertical side caption;
dead space to the right of SELECT.  Then a further nudge of `2+3` by
two-thirds of a character off the decorative box.

User: “Excellent, thanks!”

Commits `dc6a5df2d`, `bd138a239`, `48c9250a2`.

### 5. MODE style, cutout, margins, IPL digits (2026-09-04)

MODE row had a different switch-control look (hex / distinct body).
User asked for the same guarded-toggle style as OUTPUT.  Also: slide C3
and F6 **into the O6 concave cutout** to save width; use the top pane-to-
window gap on the sides and bottom too; centre IPL button numbers
vertically.

Commit `ac3277e42`.

### 6. `--size` (2026-09-04)

Asked for both `panelO6.py` and `stsKeyboard.py` (a sibling built in
between — see below).  1024 = current full size.  Then: fonts were not
shrinking at small sizes because of a **6 pt Tk floor**; dropped to 1 pt.

Commits `7389164a0`, `d0732f754`.

### 7. panelO6-paddle.py (2026-09-09)

User: “qit”, then: a program `panelO6-paddle.py` functionally identical
to `panelO6.py`, but with the stylized slide switches replaced by more
realistic paddle switches.

Started as a copy.  Thrown paddles tilt up/down (F6 left/right); a
3-position middle faces the camera.

Then, in order, all on the paddle file only:

1. Rectangular black-inside-grey wells → circular disks at the pivot,
   diameter ~ twice paddle width.  (`b6e1ab8fe`)
2. Disks ~10% smaller; fill a grey between black and paddle cream;
   thrown heads ovals 70% along the shaft.  (`237153248`)
3. Well colour between **pane grey and paddle cream**, not black-to-cream.
   (`8e593abe0`, `C_WELL = #d9d6cb`)

User: “That's quite nice, thanks!”

`panelO6.py` was left with the sliding capsules on purpose.  Both looks
are wanted.

---

## What is still open

- **yaGPC2 discretes.**  Intentionally unwired.  When wanted, extend the
  protocol in `yaShuttle/discretePanel/` rather than inventing a new one.
- **MDM power switches** on the left of physical O6: not drawn.
- **MODE lever lock** (pull to leave RUN): not simulated; a click in the
  RUN third is enough.
- Talkbacks are a local function of POWER/OUTPUT/MODE/IPL, not GPC
  output discretes.
- The two panel programs are **not** wired to `stsKeyboard.py` or
  `MEDS2.py`.  Those are separate windows from the same session.

---

## Related files in this directory (not this handoff’s subject)

Built in the same session, after O6 was “good enough” and before / after
the paddle variant:

- `stsKeyboard.py` — 8×4 black DPS keyboard, same Canvas / `--size` /
  no-focus habits.  Hex keys 1.6× the EXEC face; period is a disc;
  RESUME 75%.
- `MEDS2.py` — Python port of `~/workspace/MEDS2/` (the `meds2` branch;
  not older `MEDS`).  DPS/IDP runner, DEU SVG stroke font.  See that
  file’s docstring; do not mix it into these panel programs.

---

## Git (panel files only)

```
52a78c49d 2026-09-02  panelO6: visual simulator for the GPC hardware-controls half of panel O6
8de9ec8cf 2026-09-02  panelO6: space stacked setting captions and use one type size
74e92c9be 2026-09-02  panelO6: drop screws, tighten side legends, even out vertical space
32208fea5 2026-09-02  panelO6: pad captions from glyph bounds, centre settings on GPC3
dc6a5df2d 2026-09-04  panelO6: add BFC CRT (C3) and BFC DISENGAGE (F6) blocks
bd138a239 2026-09-04  panelO6: stand 2+3 up and trim the C3 block
48c9250a2 2026-09-04  panelO6: nudge 2+3 off the SELECT bezel
ac3277e42 2026-09-04  panelO6: MODE matches other toggles, C3/F6 in the O6 cutout
7389164a0 2026-09-04  panelO6, stsKeyboard: --size N scales the window (1024 is full)
d0732f754 2026-09-04  panelO6, stsKeyboard: let fonts scale below 6 pt
698ea2aa8 2026-09-09  panelO6-paddle: same panel with bat-handle paddle switches
b6e1ab8fe 2026-09-09  panelO6-paddle: circular wells instead of rectangular switch bezels
237153248 2026-09-09  panelO6-paddle: smaller grey wells, oval paddle heads
8e593abe0 2026-09-09  panelO6-paddle: well grey between the pane and the paddle cream
```
