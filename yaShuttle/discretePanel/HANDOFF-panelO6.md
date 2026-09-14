# HANDOFF: panelO6.py (and the frozen panelO6-paddle.py lineage)

Working notes for a later session.  The program is the GPC / BFC
hardware-control simulator `yaShuttle/discretePanel/panelO6.py`.  It draws
the panel, prints every control change to stdout, and **drives the yaGPC2
discrete bus**: every GPC column publishes its own computer's discretes.

`discretePanel/panelO6.py` is the former `panelO6-paddle.py` (bat-handle
paddle switches), moved here.  The old sliding-capsule `panelO6.py` is
discontinued.  Both older files still sit, unwired and frozen, in
`yaShuttle/panelO6/`; do not edit those.

The filename is `panelO6` (letter O, not digit 0).

---

## What it is

A Python 3 tkinter Canvas app that draws the GPC half of Space Shuttle
overhead panel **O6**, plus the BFC CRT block from panel **C3**, the BFC
DISENGAGE block from panel **F6**, an RHC BFC ENGAGE pane and a mass-memory
ACTIVITY pane.

History of the two looks (both were wanted at the time):

| File (in `yaShuttle/panelO6/`) | What it draws for 2- and 3-position switches |
|---|---|
| `panelO6.py` | Sliding cream capsules in a rectangular black well inside a grey guard (discontinued) |
| `panelO6-paddle.py` | Bat-handle paddles on a circular well; thrown positions tilt, a 3-position middle faces the camera (now `discretePanel/panelO6.py`) |

Layout, click handling, talkback logic, logging, `--size`, and
`--geometry` were the same in both; the paddle file was copied from the
capsule file and only the switch bodies were replaced.  The capsule
helpers `_vbar` / `_hbar` exist only in the discontinued file.

---

## How to run

```bash
cd yaShuttle/discretePanel
python3 panelO6.py
python3 panelO6.py --size 512
python3 panelO6.py --geometry 948x1250+80+20
python3 panelO6.py --port-base 6900 --gpc-id 2
python3 panelO6.py --script seq.txt --quit-after 60
```

- `--size N`: scale the window and contents.  **768 is full size** (the
  design window 948×1250, `FULL_SIZE = 768`); 512 is two-thirds (632×833);
  384 is half.  Contents scale with the window.  stsKeyboard.py uses the
  same 768 unit; cam.py uses 512; MEDS2.py's `--size` is pixels.
- `--geometry SPEC`: exact Tk geometry; **overrides `--size`**.
- `NSTS_O6_GEOMETRY` is the env-var equivalent of `--geometry`.
- `--port-base N`: the emulator's `--port-base`.
- `--gpc-id N` (default 1): the **primary** column -- marked `(primary)` in
  the startup dump, and the column a script drives until `gpc <n>` moves it.
  It no longer limits what is published: every column is.
- `--script FILE` / `--quit-after S`: timed playback, as discretePanel.py;
  a scripted run never maps the window.
- Logging prefix is `panelO6:`.
- The window tries not to steal keyboard focus (`_dont_steal_focus`, copied
  from `discretePanel.py`: `takefocus=0`, `_NET_WM_USER_TIME=0`, then
  `wmctrl` back to the previous active window).

Tk font sizes are points, floored at **1 pt** so legends keep shrinking
with `--size`.  There used to be a 6 pt floor; it froze type around small
sizes and was dropped.

Usually you do not start it by hand: `simulatePASS.py` launches it with
MEDS2.py, stsKeyboard.py, cam.py and yaGPC2 (see "Running several GPCs"
below).

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
- **DPS Familiarization Workbook** (USA005351C),
  `~/Desktop/sandroid.org/public_html/apollo/Shuttle/Crew Training/DPS Familiarization Workbook.pdf`
  — used to settle talkbacks vs switches (row 2 and row 5), the discretes
  (§1.1.2, 8.2) and the BFC module (13.2, 13.2.1).
- `yaShuttle/discretePanel/discretes.py` is the **yaGPC2 discrete
  protocol**.  The old `discretePanel.py` is **not** the visual reference.
  The user said so on day one: ttk look is wrong; match the SCOM hardware.

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
| 5 | MODE **talkbacks** (not switches) | RUN, or IPL while a live IPL press is held, else barberpole |
| 6 | MODE, 3-position toggle | RUN / STBY / HALT.  Real hardware is lever-locked in RUN; this sim does not require pulling a lock |
| Right tab | IPL SOURCE, 3-position toggle | MMU 1 (up) / OFF (middle) / MMU 2 (down) |

C3 and F6 sit in the O6 concave cutout, above the IPL SOURCE tab, so the
window can be narrower than “O6 plus a column to the right of everything”.

| Block | Controls |
|---|---|
| C3 **BFC CRT** | DISPLAY ON/OFF (2-pos vertical); SELECT 1+2 / 2+3 / 3+1 (3-pos vertical).  `2+3` is a stacked side caption, nudged `SETTING_SIZE * 2/3` right of the SELECT guard so it clears the decorative box |
| F6 **BFC DISENGAGE** | One horizontal 2-position toggle, unlabeled.  RIGHT disengages the BFS; LEFT is the rest position |
| **RHC BFC ENGAGE** | Two lines "RHC" / "BFC ENGAGE"; CDR and PLT momentary pushbuttons, 40 px, IPL grey (the user rejected red: it competes with the lamps).  Directly above ACTIVITY |
| **ACTIVITY** | MM1 and MM2 lamps: F6's size and column, bottom on O6's bottom edge, below the IPL SOURCE tab |

Click the upper / middle / lower (or left / right) third of a toggle to
put it there.  Cursor becomes `hand2` over a hit.  IPL and the ENGAGE
buttons are press-and-hold.

**RHC pane size.**  40 px was chosen by measuring clearance under the IPL
SOURCE tab: at least 15 px at every `--size` from 300 to 2000 (50 px left
only ~5 px at 300 and 700).

**ACTIVITY pane.**  Title 10 pt like F6, one caption line under it; MM1 /
MM2 captions 10 pt, each lamp right of its caption, the pair centred on
the pane's quarter points.  A lamp is a disk the diameter of the caption's
cap height, thin black rim, fill `C_PANEL` (OFF) / green READY / red BUSY.
Tk has no cap-height metric and its ascent is not one (Nimbus Sans ascent
is about the caps, Arial's a quarter taller), so em =
measure("0123456789") / 5.56 and cap = 0.72 em (Helvetica metric family);
the lamp is centred on the caps' ink, not the em box.  Verified by
screenshot: disk 20 px vs caps 20 px at the old full size, correct at 512.

The lamps show the mass memories' READY lines as heard on the bus
(register A bits 6/7, from any channel): grey (OFF) until the unit is first
heard, then SET → green READY / RESET → red BUSY, for good.  There is no
staleness timeout (user request: a quiet unit keeps its last state).  The
listener thread only records; the Tk-side `_tick` (every 250 ms) applies
them -- no Tk calls from the thread.  yaGPC2 publishes READY on every
running computer's channel (commit cd4319576); before that only the last
GPC's channel carried it and the lamps stayed dark in multi-GPC runs.

---

## The discrete bus

`discretes.py`: UDP multicast set/reset messages on 239.255.1.1, **one
channel per GPC** at port base + 80 + N (6981-6985 at the default 6900).
The startup log says "publishing all 5 GPCs' discretes on
239.255.1.1:6981-6985 every 250 ms".  Every column is published on its own
channel on every change and re-asserted every `REPUBLISH_MS` (250 ms) as one
RESET then one SET per register (break before make), because a discrete is
a level and UDP has no replay for a late joiner.  The log prints
`GPCn discretes A=.. B=..` on every change.

Per-GPC state (MODE, IPL, BFC latch, I/O TERM B, GPC ID) differs by column;
the panel-wide switches (IPL SOURCE, I/O TERM A, BFC CRT) are the same wire
feeding all five.  Only the owned bits (`OWNED_A` / `OWNED_B`) mean
anything; the rest belong to other devices.

Mapping (authority: `BFS.SRC/MLIB80/ENTRYS.asm` DIA table; DPS Workbook
§1.1.2, 8.2, 13.2):

| Bits | Meaning |
|---|---|
| A0-2 | MODE HALT / STBY / RUN |
| A3 | IPL, only while held **and** in HALT |
| A4 / A5 | IPL SOURCE MMU 1 / MMU 2 (OFF drives neither) |
| A12 | I/O TERM A: held 0 -- "FROM HDWR=0", "CLAMPED TO ZERO" (STM0 ERROR 129 if set).  Script `bit A 12` still sets it |
| A13 | I/O TERM B: the BFC module's output |
| B0-2 | GPC ID (the column number) |
| B3-5 | BFS ENGAGE: that GPC's BFC engage latches, one field, all or none |
| B6-7 | BFC CRT field, bit 6 the 2s place: 0 if DISPLAY OFF, else SELECT **1+2 → 1, 2+3 → 2, 3+1 → 3** |

**BFC CRT SELECT sends the first CRT of its legend.**  This was the first
wiring (Workbook 8.2: "the CRT specified by the first number of each of the
switch positions"), was rotated to 2+3=1 / 3+1=2 / 1+2=3 in 83bc4301d, and
was restored in 3c9a7b454.  The flight software settles it twice:

- `ARAGPCSW.hal` `ARAB_MASK_ARRAY`, indexed by this value, hands the BFS
  DK1 / DK2 / DK3 for 1 / 2 / 3 before engage and DK1+2 / DK2+3 / DK3+1
  after.  So PASS lets go of the first-named CRT while DISPLAY is ON, even
  without an engage.
- GPCIPL (`GPCRTOPT.asm`, CM4POLL) takes the value itself as the DEU to
  drive: DKBUS = value + 5.  Value 0 (DISPLAY OFF) with an IPL SOURCE
  selected is the "IPL DEFAULT LOAD -- NO DEU SELECTED" path (`POLL45`): no
  menu, straight load from mass memory.

Verified: a one-GPC run sending 2 put the GPCIPL menu on CRT2 and left CRT1
alone.  83bc4301d changed only the label table, so the value on the wire was
1 both before and after it; the CRT1 failure that prompted it was not the
discrete.  Script `crt N` is by value and unaffected.

Startup positions deliberately kept (user choice): IPL SOURCE OFF, BFC CRT
DISPLAY OFF, which gives a default-option IPL; the old discretePanel.py
started at MM1 + CRT 1 (menu IPL).

### Scripted playback

`--script FILE`: `<ms> <command>` per line, times from startup, `#`
comments.  The commands move the controls, so the window, the log and the
bus agree.  Commands act on the primary column until `gpc <n>` moves them,
which is how one script brings up more than one computer.

| Verb | Effect |
|---|---|
| `gpc N` | later commands act on column N |
| `mode HALT\|STANDBY\|STBY\|RUN` | that column's MODE |
| `ipl` | its IPL pushbutton, held `IPL_HOLD_MS` (250) |
| `source MM1\|MM2\|OFF` | IPL SOURCE |
| `crt 0\|1\|2\|3` | 0 = DISPLAY OFF, else DISPLAY ON and SELECT 1+2 / 2+3 / 3+1 |
| `bfsengage on\|off` | on: CDR ENGAGE pressed and released; off: DISENGAGE RIGHT then LEFT.  Latches only if some GPC is in BACKUP |
| `gpcid N` | rewire the primary column |
| `bit A\|B N on\|off` | one bit.  A12 TERM A; A13 moves OUTPUT to TERMINATE / NORMAL; B3-5 fold into bfsengage; B6-7 fold into crt; anything else is sent once, raw |

Verified at wiring time: the same 20-command script through panelO6.py and
discretePanel.py on port base 17900, the bus sampled at +120 / +700 ms, gave
identical registers from `source MM1` on except where intended (startup
positions; `bfsengage on` also raises TERM B; a mid-script `gpcid 2` takes
column 2's own MODE).

---

## The BFC modules

Workbook 13.2.1.  The OUTPUT switches set two inputs of each GPC's BFC
module:

- **BFC GPC SELECT** = that GPC in TERMINATE, or it is the highest-numbered
  GPC in BACKUP (the BFS computer).
- **BFC SELECT OFF** = that GPC in TERMINATE, or no GPC is in BACKUP.

Either RHC ENGAGE pushbutton sets a module's latch unless SELECT OFF or F6
DISENGAGE RIGHT is clearing it (clear dominates).  The latch is the GPC's
three ENGAGE discretes (B3-5), and **I/O TERM B = latch XOR BFC GPC
SELECT**.  So before an engage a PASS GPC in NORMAL may transmit and the
BFS in BACKUP may not; after one it is the other way round; a GPC in
TERMINATE never may.  One latch per module stands for the workbook's three
contacts per button and 3-of-3 voting, since failed electronics are not
simulated.

---

## Talkbacks (local stand-in until a GPC drives them)

OUTPUT talkback for GPC *i* is GRAY only if POWER is ON **and** MODE is RUN
**and** I/O TERM B is off; otherwise barberpole.  So an engage turns the
PASS talkbacks barberpole and the BFS talkback grey.

MODE talkback is IPL only while that GPC's IPL press is live (held, in
HALT), else RUN if MODE is RUN, else barberpole.  The SCOM MODE window is
silk-screened RUN; that word is shown in the RUN state and replaced by IPL /
stripes.

Barberpole is a `PhotoImage` of diagonal cream/black stripes, cached by
pixel size.

These are **approximations**.  On the vehicle the talkbacks are GPC
output discretes, not a function of the crew switches alone.

---

## Startup defaults (typical pre-flight)

- All POWER **OFF** (user request).  POWER drives no discrete, so the bus is
  unaffected; the only effect is that OUTPUT talkbacks stay barberpole until
  a GPC is powered.
- OUTPUT NORMAL on GPC1–4, **BACKUP on GPC5** (BFS)
- All MODE HALT
- IPL SOURCE OFF
- BFC CRT DISPLAY OFF, SELECT 1+2
- BFC DISENGAGE LEFT
- RHC BFC ENGAGE both released
- ACTIVITY lamps OFF (grey) until a mass memory is heard
- All talkbacks barberpole

Every change, and a full dump at startup, prints to stdout.

---

## Running several GPCs (simulatePASS.py, and what a manual run showed)

`simulatePASS.py --gpcs 1,2` (up to `1-4`) starts yaGPC2 with both mass
memories, two MEDS2.py CRTs with a keyboard each (KYBD1 → CRT1, KYBD2 →
CRT2), panelO6.py, and cam.py.  `--procedure` prints the steps.

**Observed in the user's manual two-GPC run, 2026-09-13** (not yet a
scripted, repeatable test):

- Both computers IPL from **MMU 1**, one after the other.  IPL SOURCE and
  the BFC CRT switches are single switches shared by every column, so the
  IPLs cannot overlap; which computer IPLs is only which column's IPL
  button is pressed.
- GPC1: SOURCE MMU 1, SELECT 1+2, DISPLAY ON, IPL, STBY, RUN; GPCIPL menu on
  CRT1; ITEM 1 EXEC on keyboard 1; when the MM1 lamp stays green, DISPLAY
  OFF then SOURCE OFF.
- GPC2: SOURCE MMU 1, SELECT **2+3**, DISPLAY ON, **DEU LOAD on CRT2's IDP
  pane**, IPL on GPC2's column, STBY, RUN.  "GPCIPL MENU (1) 2" appears on
  CRT2; ITEM 1 EXEC on **keyboard 2**; then DISPLAY OFF, SOURCE OFF.
- **DEU LOAD is required** once PASS has loaded its display software into a
  CRT.  Without it the second computer's GPCIPL either shows nothing (1+2
  onto CRT1) or draws over the leftover PASS page (2+3 onto CRT2): the old
  "GPC MEMORY" title plus GPCIPL's "(1) 2" header, with the GPCIPL text
  squashed into the upper right because MEDS2.py keeps PASS's screen
  geometry.  ITEM 1 EXEC still reaches the computer.
- While DISPLAY is ON, GPC1's PASS gives up the selected CRT (the BFS mask
  above); after DISPLAY OFF it takes the CRT back after three cycles
  (`ARAGPCSW.hal` forces a major-function change on that DK bus).  So
  before any NBAT both CRTs show GPC1's pages, even while GPC2 is still in
  STBY.
- `OPS 2 0 1 PRO` **without entering the NBAT** brought UNIV PTG up with
  CRT1's header digit 1 and CRT2's 2.
- The simulatePASS procedure text still says to IPL later computers through
  CRT1 with 1+2 plus DEU LOAD on CRT1.  That worked in scripted runs, but
  the 2+3 / CRT2 path above is cleaner and should replace it once
  scripted-verified.

**Reading the displays:**

- The digit after a PASS page title is the **ID of the GPC driving that
  CRT** (`DCICYC.asm`, from FCOS `TFCMID`).  GPCIPL's header "(1) n" also
  ends in the GPC ID.
- The large boxed number at the bottom of a MEDS2.py screen is **not** the
  GPC number: it is `gpcNo`, default 1, and `setGPCNo()` is never called.
  The red line beside it is MEDS2's keyboard-select indicator.
- SPEC 6 GPC/BUS STATUS (`CD0060.dfg`): no literal UP/DOWN.  An asterisk in
  a GPC's column means that GPC is actively commanding the network
  (`CZ2B_ACT_XMITR`, gathered from each GPC over the intercomputer bus per
  `AIESIP.hal`); a down arrow (`CDJ_BRDNAROW`) marks the network failed or
  masked for that GPC.  In OPS 0 before any NBAT, GPC1 had asterisks on
  every network except CRT3 and CRT4 (no displays there), and GPC2 had no
  asterisks and a down arrow everywhere -- consistent with GPC2 owning no
  networks yet, though the display's test logic has not been traced line by
  line.

---

## Implementation notes that are easy to break

**Reference coordinates.**  Layout lives in a 948×1250 design space
(`REF_W` × `REF_H`).  `FULL_SIZE = 768` is the `--size` unit for “the
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

**Focus.**  This window is meant to sit beside a terminal / GPC run
without grabbing keys.  That is why `_dont_steal_focus` exists.

**Threads.**  The bus listener must never touch Tk; it records under
`_rx_lock` and `_tick` applies.

**Paddle switch body.**  No rectangular guard.

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

**Capsule switch body (discontinued file only).**  Rectangular grey guard,
inset black well, cream rounded bar (`_vbar` / `_hbar`) with a groove.
Two-position bars were taller (or wider) than three-position so they stayed
bars, not discs.

---

## Creation process

The panel was built in one conversation (2026-09-02 through 2026-09-09) in
`yaShuttle/panelO6/`, which started empty, then moved and wired in
`yaShuttle/discretePanel/` (2026-09-11 onward).

### 1. Original request (2026-09-02)

Python 3 `panelO6.py`: emulate O6 appearance, cross-platform, workable
controls, print changes to the terminal.  Eventually send discretes to
`yaGPC2`; not then.  The user supplied a six-row textual reading of the
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
between — see below).  1024 was then full size (since changed to 768, see
§9).  Then: fonts were not shrinking at small sizes because of a **6 pt Tk
floor**; dropped to 1 pt.

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

### 8. Moved, ACTIVITY, wired (2026-09-11)

The paddle file became `discretePanel/panelO6.py` (a14cf8ba6); the capsule
variant was discontinued.  ACTIVITY pane added (b9d585258).  Wired to the
discrete bus as the replacement for discretePanel.py, with the BFC module
model and the RHC BFC ENGAGE pane (16541c376).  BFC CRT SELECT rotated at
the user's request (83bc4301d; restored in 3c9a7b454, §11).

### 9. POWER OFF, --size 768 (2026-09-11)

All POWER switches start OFF (4d91240fa).  `--size` unit 768, so 512 is
two-thirds (41cc7be8d).

### 10. Every column drives its own GPC (2026-09-12)

discretes.py gained a channel per GPC and REQUEST/VALUE, following
nsts-sim-gpc 7946bc1 (57d3bb950).  Every column now publishes its own
computer (08e9d0bef), and a script names its column with `gpc <n>`
(5184ed5a2).

### 11. BFC CRT SELECT restored (2026-09-13)

1+2 = 1 again, from the flight source (3c9a7b454); see "The discrete bus".

---

## What is still open

- **MDM power switches** on the left of physical O6: not drawn.
- **MODE lever lock** (pull to leave RUN): not simulated; a click in the
  RUN third is enough.
- Talkbacks are a local function of the switches and the BFC model, not
  GPC output discretes.
- The panel is not wired to `stsKeyboard.py` or `MEDS2.py` directly; they
  meet only through the emulator's buses.
- The simulatePASS procedure for later GPCs should move to the 2+3 / CRT2
  path once a scripted run verifies it.
- What real hardware resets the CAM diagonal latch is unknown; yaGPC2
  clears it on that GPC's HALT.

---

## Related files in this directory (not this handoff’s subject)

- `stsKeyboard.py` — 8×4 black DPS keyboard, same Canvas / `--size` (unit
  768) / no-focus habits; sends scan codes on keyboard bus `--kybd N`.
  See HANDOFF-stsKeyboard.md.
- `MEDS2.py` — Python port of `~/workspace/MEDS2/`.  See
  HANDOFF-meds2-py.md; do not mix it into the panel programs.
- `cam.py` — the **Computer Annunciation Matrix** (formerly `voting.py`;
  CAM is the flight software's name, FCMSFCAM / SETCAMEX).  5×5 lamps, rows
  the voting GPC, columns the failed GPC, window title "CAM", `--size` unit
  512, `NSTS_CAM_GEOMETRY`.  Every lamp fills its cell; off-diagonal lamps
  light white; diagonal lamps light yellow with the GPC number as a black
  legend.  **Driven by the bus** unless `--no-bus`: it listens on all five
  GPC channels (`--port-base`), takes row N from GPC N's fail-discrete
  register (FAILVOTE, register 4) un-rotated -- 0x08 votes against N+1 …
  0x01 against N+4, 0x10 inhibits the row -- and diagonal cell N from
  register REG_CFAIL (5, bit 31, `CFAIL_LIT`), which yaGPC2 composes for the
  lamp from its latch of two or more votes against that computer.  It
  REQUESTs both registers at start-up, takes messages one at a time, and
  holds a lit lamp at least `HOLD_MIN_S` = 40 ms so a sub-millisecond vote
  still shows on video.  Keys (digit pairs 11..55) and clicks still toggle
  lamps by hand until that computer's next message.  Unlike the panels it
  takes the keyboard.  Verified in yaGPC2 runs cf-short-0 and cf-g3-0
  (gpc-causes #141).
- `simulatePASS.py` — the launcher; see README.md.

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
a14cf8ba6 2026-09-11  Rationalized and collected Shuttle peripherals into discretePanel/.
b9d585258 2026-09-11  panelO6: ACTIVITY pane with MM1 / MM2 lamps
16541c376 2026-09-11  panelO6: wire GPC 1 to the discrete bus, replacing discretePanel.py
83bc4301d 2026-09-11  panelO6: BFC CRT SELECT positions send 2+3=1, 3+1=2, 1+2=3
4d91240fa 2026-09-11  panelO6: GPC POWER switches start OFF
41cc7be8d 2026-09-11  panelO6: --size unit is 768, so --size 512 is two-thirds size
57d3bb950 2026-09-12  discretes: a channel per GPC, and REQUEST/VALUE, per nsts-sim-gpc 7946bc1
08e9d0bef 2026-09-12  panelO6.py: every column drives its own GPC
5184ed5a2 2026-09-12  panelO6.py: let a script say which GPC it means
3c9a7b454 2026-09-13  panelO6: BFC CRT SELECT sends the first CRT of its legend again (1+2=1)
```

cam.py (voting.py until 0399e250c): 5b22c9a46 … 0399e250c (2026-09-12),
9a4d06181 and 46538bfba (2026-09-13).  simulatePASS.py: bc5c3e473.
