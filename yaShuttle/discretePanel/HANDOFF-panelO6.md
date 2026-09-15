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
ACTIVITY pane, and, in a right-hand column of its own, the **IDP controls**
(panel C2, O6's IDP LOAD inset, and IDP/CRT 4's switches from panel R11).
Window title "Panels O6, C3, F6, C2, R11  —  GPC / BFC / IDP".

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
python3 panelO6.py --geometry 1684x1300+80+20
python3 panelO6.py --port-base 6900 --gpc-id 2
python3 panelO6.py --script examples/4gpc-startup.script --show --wait-user
```

- `--size N`: scale the window and contents.  **768 is full size** (the
  design window 1684×1300, `FULL_SIZE = 768`); 512 is two-thirds
  (1123×867); 384 is half (842×650).  Contents scale with the window.  stsKeyboard.py uses the
  same 768 unit; cam.py uses 512; MEDS2.py's `--size` is pixels.
- `--geometry SPEC`: exact Tk geometry; **overrides `--size`**.
- `NSTS_O6_GEOMETRY` is the env-var equivalent of `--geometry`.
- `--port-base N`: the emulator's `--port-base`.
- `--gpc-id N` (default 1): the **primary** column -- marked `(primary)` in
  the startup dump, and the column a script drives until `gpc <n>` moves it.
  It no longer limits what is published: every column is.
- `--script FILE`: plays a crew script (see "Scripted playback").  A
  scripted run keeps the window unmapped unless `--show`, `--wait-user` or a
  `wait user` line in the script asks for it.
- `--wait-user`: an implied `wait user` before the script's first line, and
  the window shown.
- `--quit-after MS`: exit after that many **milliseconds** (script times are
  seconds).
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
- **IDP controls:** DPS Workbook USA005350 Rev B figure 2-31 (PDF p.54), and
  Crew Software Interface USA006083 Rev B §2.3-2.6 and figure 2-3 (R11).

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
| 2 | OUTPUT **talkbacks** (not switches) | GRAY = may transmit on the FC buses; barberpole = may not.  Driven by the GPC (DO bit 7), see Talkbacks |
| 3 | OUTPUT, 3-position toggle | BACKUP / NORMAL / TERMINATE |
| 4 | INITIAL PROGRAM LOAD, momentary pushbuttons | ON while held, OFF on release |
| 5 | MODE **talkbacks** (not switches) | IPL (GPC DO bit 31), RUN (DO bit 9, load complete), else barberpole.  Driven by the GPC, see Talkbacks |
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

### The IDP column

Right of everything above (`REF_W` 948 → 1684; `REF_H` 1250 then, 1300 since the MODE talkbacks moved down),
top to bottom:

| Inset | Controls |
|---|---|
| C2 | IDP/CRT **1, 3, 2** (that order, left to right), each POWER ON/OFF and MAJ FUNC GNC / SM / PL.  Below them LEFT IDP/CRT SEL (1 / 3) and RIGHT IDP/CRT SEL (3 / 2), horizontal toggles |
| O6 **INTEGRATED DISPLAY PROCESSOR** | LOAD 1-4, momentary |
| R11 | IDP/CRT 4 POWER and MAJ FUNC (beside the aft keyboard in the orbiter).  No IDP/CRT SEL: the aft keyboard reaches only IDP 4 |

MAJ FUNC value 3 (ILLEGAL) is kept, not coerced, and drawn as an end-on
centred paddle ringed in red (`MF_RING`).  C2's per-set drawing is
`_idp_rows` / `_idp_set`, shared by `_draw_r11`.

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

**Publishing has its own thread** (`_pub_loop`).  The Tk side only hands it
the columns; the thread sends the RESET/SET pairs on every change and every
`REPUBLISH_MS`.  Before that, a Tk thread waiting on a saturated X server
silenced the bus for longer than yaGPC2's 1.5 s staleness limit and halted
every running GPC at once (yaGPC2 ledger #147; yaGPC2 now also rides
through a quiet panel).  `_tick` logs `Tk tick N ms late` when a tick is
more than 200 ms past its period.  Test hook:
`NSTS_PANEL_STALL=<start s>,<seconds>` holds the Tk thread once.

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

`--script FILE` plays a **crew script**: one file for everything the crew
does in a scripted run -- the panel verbs below, keystrokes
(`keys [KB1|KB2|KB3] KEY ...`), captions (`subtitle TEXT`) and waits.  The
language, the parser and the player are `crewscript.py`'s
(`crewscript.parse`, `crewscript.Player`); panelO6.py hosts the one player
on its Tk loop (`root.after`), so switches and keystrokes share one clock.
`crewscript.HELP` is the full command list, printed at the end of
`panelO6.py --help` and `simulatePASS.py --help`, and
`python3 crewscript.py FILE ...` checks scripts without running anything.

`<seconds> <command>` per line, decimals allowed, `#` comments (so a caption
cannot contain `#`).  Times count from the start, or from the moment the last
wait was met; lines run in file order, and a time may not go backwards
between waits.  The whole file is checked when it is read.  Times were
milliseconds until f1f6d064c; a time over `MAX_SCRIPT_SECONDS` (36000) is
refused as a probable old millisecond script, and discretePanel.py has the
same guard.  The panel verbs move the controls, so the window, the log and
the bus agree.  They act on the primary column until `gpc <n>` moves them,
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
| `idppower N on\|off` | IDP/CRT N POWER (N 1-3 on C2, 4 on R11) |
| `majfunc N GNC\|SM\|PL` | IDP/CRT N MAJ FUNC (N 1-3 on C2, 4 on R11) |
| `kybdsel left 1\|3`, `kybdsel right 2\|3` | LEFT / RIGHT IDP/CRT SEL |
| `idpload N` | O6 IDP N LOAD (N 1-4), held `IPL_HOLD_MS` |

`_dump_state` lists every IDP switch too.

Verified at wiring time: the same 20-command script through panelO6.py and
discretePanel.py on port base 17900, the bus sampled at +120 / +700 ms, gave
identical registers from `source MM1` on except where intended (startup
positions; `bfsengage on` also raises TERM B; a mid-script `gpcid 2` takes
column 2's own MODE).

**Waits.**  `wait gpc N mode-tb RUN|IPL|BP [timeout S]`, with no time in
front, holds the script until GPC N's MODE talkback shows that state (see
Talkbacks; polled every `WAIT_POLL_MS` = 100 ms, default timeout 600 s).  A
timeout is logged and stops the script rather than carrying on as if the
GPC were ready.  `wait user` holds until a click in the window: the cursor
becomes `WAIT_CURSOR` ("target") and stays so across `<Leave>` and motion,
and the click is consumed, moving no control.  `--wait-user` inserts one
before the first line.  The window is mapped when there is no script, or
with `--show`, `--wait-user`, or a `wait user` in the script; an unattended
script stays hidden.  Test hook: `NSTS_PANEL_AUTOCLICK=<s>` clicks once after
that many seconds.

**Keys and captions.**  `keys` sends DPS scan codes on the keyboard buses
(IDP POWER / DEU LOAD messages on the IDP buses for those key names),
`KEY_GAP_S` = 0.35 s apart, and the next line starts when the typing is
done.  `subtitle` sends one UTF-8 datagram to port base + 90 for
`subtitles.py`; nothing starts that box (see Related files).

**Verified (2026-09-15):** `examples/4gpc-startup.script` with
`simulatePASS --gpcs 1-4 --crts 2` brought four GPCs to OPS 2, each IPL
gated on `wait gpc N mode-tb RUN` (met 25-28 s after its ITEM 1 EXEC), with
no CAM lamp and MM1 at 239 commands / 2045 blocks read.  As two files with
waits, OPS 2 was typed about 570 s after the panel started, against 840 s
with fixed times.

---

## The IDP buses

The IDP controls talk to the **IDPs** (MEDS2.py), not the GPCs.  UDP to
group 239.255.1.1, port base + 40 + n for IDP n (`IDP_BUS_OFFSET`),
big-endian 16-bit words, word 0 the tag:

| Tag | Words | From |
|---|---|---|
| `SET_MAJOR_FUNC` 0x0001 | [mf]: 0 PL, 1 GNC, 2 SM, 3 ILLEGAL | MAJ FUNC |
| `IDP_LOAD` 0x0002 (MEDS2's `DEU_LOAD`) | none | IDP LOAD, once when thrown |
| `IDP_POWER` 0x0003 | [1 on / 0 off] | POWER |
| `KYBD_SEL` 0x0004 | [mask]: bit 0 left keyboard selected to this IDP, bit 1 right | IDP/CRT SEL |

KYBD_SEL masks: IDP1 1 if LEFT=1; IDP2 2 if RIGHT=2; IDP3 bit 0 if LEFT=3,
bit 1 if RIGHT=3 (`kybd_mask`).  POWER and MAJ FUNC for IDPs 1-4
(`N_IDP_SW = 4`) and KYBD_SEL for IDPs 1-3 (`N_IDP_C2 = 3`) are sent on
change and re-asserted every `IDP_REPUBLISH_MS` = 1000.

**The panel follows the bus.**  `_listen_idp` (a thread on base + 41..44)
takes the same three tags from anyone else -- simulatePASS `--keys` tokens,
a MEDS2 window's Shift+M, MEDS2 `--pane` -- into `_idp_rx` under `_rx_lock`;
`_idp_adopt`, on the Tk side, moves the switches and logs "(heard)".  The
panel's own echoes are dropped by matching IDP and payload within
`ECHO_WINDOW_S` = 0.5 s; each send is noted before `sendto`, and the
sockets are bound before the first publish.  A KYBD_SEL **set** bit moves
a SEL switch; clear bits alone move nothing.

Defaults: POWER OFF; MAJ FUNC from env `NSTS_MAJOR_FUNC` (0 PL, 1 GNC, 2 SM,
3 ILLEGAL, as MEDS2 reads it), else GNC; LEFT SEL 1, RIGHT SEL 2.

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

## Talkbacks (driven by the GPCs)

Both rows are GPC output discretes, as on the vehicle (DPS Workbook
USA005350 Rev B 2.x: "driven directly from GPC output discretes"), read from
each GPC's DO register (`REG_OUT`, 3) on that GPC's channel.  `_listen_out`
keeps a socket per channel and REQUESTs the register at start-up, so a GPC
already running shows at once; `gpc_out[i]` is None until that GPC is
heard.  Bit numbers are IBM (bit n = 0x80000000 >> n), names from
`SSSRC/BILDNEW5.asm`.

- **OUTPUT** (`output_tb`): GRAY while DO bit 7, I/O ACTIVE TALKBACK, is
  set; otherwise barberpole.  The Workbook: gray if output is enabled,
  barberpole with I/O TERM B set or the GPC not in RUN.  PASS set it 2.4 s
  after the switch reached RUN (yaGPC2 run verify-tb).
- **MODE** (`mode_tb`): IPL while DO bit 31, IPL (HDWR), is set -- yaGPC2
  drives it from a successful firmware IPL until the HALT → STBY release
  (`run.c` `ipl_talkback`, f421b0573); else RUN while bit 9, RUN(READY)
  TALKBACK, is set, which FCMSWMON sets when the load completes ("When the
  talkback goes to RUN, the IPL is complete", Workbook 3.x); else
  barberpole.  A GPC never heard is barberpole, as an unpowered one is.

Changes are logged as `GPCn MODE tb  A -> B` and `GPCn OUTPUT tb  A -> B`
(`_talkbacks_follow`); `wait gpc N mode-tb` follows the same state, and
simulatePASS's keys-file `WAIT` lines follow those log lines.  The SCOM MODE
window is silk-screened RUN; that word, or IPL, is drawn at `TB_WORD_SIZE`
(9 pt) over the flag, centred on its ink rather than its em box.  The MODE
talkbacks sit `IPL_TO_MODE_TB_GAP` (50, one IPL pushbutton's height) below
the IPL buttons, which is why `REF_H` went from 1250 to 1300.

Barberpole is a `PhotoImage` of diagonal cream/black stripes, cached by
pixel size.

Other sources: DPS Overview Workbook 3-6/3-7, DPS Console Handbook
SCP 5.18.

---

## Startup defaults (typical pre-flight)

- All POWER **OFF** (user request).  POWER drives no discrete and, since the
  talkbacks became GPC-driven, nothing else: it is drawn only.
- OUTPUT NORMAL on GPC1–4, **BACKUP on GPC5** (BFS)
- All MODE HALT
- IPL SOURCE OFF
- BFC CRT DISPLAY OFF, SELECT 1+2
- BFC DISENGAGE LEFT
- RHC BFC ENGAGE both released
- ACTIVITY lamps OFF (grey) until a mass memory is heard
- All talkbacks barberpole until a GPC is heard
- IDP/CRT 1-4 POWER OFF; MAJ FUNC `NSTS_MAJOR_FUNC` or GNC; LEFT IDP/CRT
  SEL 1, RIGHT 2; IDP LOAD all released

Every change, and a full dump at startup, prints to stdout.

---

## Running several GPCs (simulatePASS.py, and what a manual run showed)

`simulatePASS.py --gpcs 1,2` (up to `1-4`) starts yaGPC2 with both mass
memories, two MEDS2.py CRTs with a keyboard each (KYBD1 → CRT1, KYBD2 →
CRT2), panelO6.py, and cam.py; `--crts 3` / `4` add IDPs.
`simulatePASS --instructions` prints the steps for a configuration.
`--yagpc-extra "ARGS"` appends options to yaGPC2's command line
(shlex-split), e.g. `--yagpc-extra "--barrier-spin-us 50 --rt-idle-poll-ms 2"`.
`--script FILE` hands panelO6 a crew script (see "Scripted playback");
`--show-panel` and `--wait-user` pass `--show` / `--wait-user` for
demonstrations, and `--duration` should be left off with a wait user, since
it counts from start-up.  The older split still works: `--keys FILE` with
`<seconds> KEY ...` lines, and `WAIT gpc N mode-tb ...` lines that follow
panel.log.  simulatePASS does not start `subtitles.py` (no default size or
place suits a recording); when a script captions, it logs the command.

**The two-CRT procedure:** GPC1 on CRT1 (BFC CRT SELECT 1+2, left
keyboard); each later GPC on CRT2 (SELECT 2+3, **O6 IDP 2 LOAD** before its
IPL, right keyboard).

- Every computer IPLs from **MMU 1**, one after the other.  IPL SOURCE and
  the BFC CRT switches are single switches shared by every column, so the
  IPLs cannot overlap; which computer IPLs is only which column's IPL
  button is pressed.
- Before any IPL the instructions turn the O6 GENERAL PURPOSE COMPUTER
  POWER switches ON (as the vehicle procedure does; they drive nothing
  yet), then IDP/CRT POWER, IDP/CRT SEL, and MODE HALT.
- Each IPL follows PASS User's Guide Table 2-2's order: **RUN comes after
  the load**.  An earlier version of the instructions said "STBY, then about
  15 s later RUN", copied from the scripted runs (which went to RUN before
  ITEM 1 EXEC and still worked); `retest-crt2.sh` and `headless-gpcmem.sh`
  both use the documented order, and a two-GPC run in that order reached
  OPS 2 (2026-09-14).
- GPC1: SOURCE MMU 1, SELECT 1+2, DISPLAY ON, IPL, STBY; GPCIPL menu on
  CRT1; ITEM 1 EXEC on keyboard 1; when the MM1 lamp stays green, DISPLAY
  OFF, then RUN, then SOURCE OFF.
- Later GPC: SOURCE MMU 1, SELECT **2+3**, DISPLAY ON, **IDP 2 LOAD**, IPL
  on that GPC's column, STBY.  "GPCIPL MENU (1) n" appears on CRT2;
  ITEM 1 EXEC on **keyboard 2**; when the MM1 lamp stays green, DISPLAY
  OFF, then RUN, then SOURCE OFF.
- **The IDP LOAD is required** once PASS has loaded its display software
  into a CRT.  Without it GPCIPL draws over the leftover PASS page: the old
  "GPC MEMORY" title plus GPCIPL's "(1) n" header, with the GPCIPL text
  squashed into the upper right because MEDS2.py keeps PASS's screen
  geometry.  ITEM 1 EXEC still reaches the computer.
- While DISPLAY is ON, GPC1's PASS gives up the selected CRT (the BFS mask
  above); after DISPLAY OFF it takes the CRT back after three cycles
  (`ARAGPCSW.hal` forces a major-function change on that DK bus).  So
  before any NBAT both CRTs show GPC1's pages, even while GPC2 is still in
  STBY.
- `OPS 2 0 1 PRO` **without entering the NBAT** brought UNIV PTG up with
  CRT1's header digit 1 and CRT2's 2.

**Verified (2026-09-14):** a full `simulatePASS --gpcs 1,2` run through
OPS 2 driven only by the panel's script verbs: CRT1 "UNIV PTG 1" with box 1
and red left bar, CRT2 "UNIV PTG 2" with box 2 and yellow right bar.  A
`--gpcs 1 --crts 4` run with all four IDPs powered from the panel; after
`kybdsel left 3` the bars were CRT1 none, CRT2 yellow right, CRT3 red left,
CRT4 none.  Also bus-listener tests (tags, words, 1 s re-assert, external
moves, IDP 4 has no KYBD_SEL) and screenshots at `--size` 384 / 512 / 768.

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

**Reference coordinates.**  Layout lives in a 1684×1300 design space
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

**Threads.**  The bus listeners must never touch Tk; they record under
`_rx_lock` and `_tick` / `_idp_tick` apply.

**R11 inset margins.**  The set's box is 5 units from the inset's left,
5 + 4 from its right, bottom margin equal to top.  `_rect_panel`'s dark
right-hand bevel covers the panel face while the light left one reads as
panel, so equal numbers looked lopsided.  Measured light gaps: 4/4 px at
`--size 512`, 6/7 px at 768.

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

### 12. IDP controls (2026-09-14)

C2 and O6 IDP LOAD, wired to the IDP buses and following them (6976ba4c0);
IDP/CRT 4 on R11 (4ba71a40c); R11 margins matched to C2 (5c1d5a79d,
81d4b5570).

### 13. Publishing thread (2026-09-14)

Discretes published from `_pub_loop`, so a stalled Tk thread cannot silence
the bus (bca2581d5).

### 14. GPC-driven talkbacks and crew scripts (2026-09-15)

MODE and OUTPUT talkbacks from the GPC DO register, the gap above the MODE
talkbacks, and `wait gpc N mode-tb` (1efb8a53e; yaGPC2's IPL output,
f421b0573).  Script times in seconds (f1f6d064c).  One crew script for
switches, keys, captions and waits (b2e0b94c3); `wait user`, `--show` and
`--wait-user` for demonstrations (d93266cde, c7b2d5ddb, 9715d8310).  The
command list moved into `crewscript.HELP`, printed by `--help`, and
crewscript.py became a checker (4ef0faac0, 064b84ffa).  Alongside:
`subtitles.py` (c88b8e649 … 5712ccece), scripted key presses shown on
stsKeyboard.py (f7888f861, 3a5485c8b, ca287722d), and simulatePASS no longer
starting subtitles.py (239062faa).

---

## What is still open

- **MDM power switches** on the left of physical O6: not drawn.
- **MODE lever lock** (pull to leave RUN): not simulated; a click in the
  RUN third is enough.
- The panel is not wired to `stsKeyboard.py` or `MEDS2.py` directly; they
  meet only through the emulator's buses.
- A command heard between `_idp_adopt` and `_idp_publish` in one tick can
  be reverted by the re-assertion for up to a second.
- What real hardware resets the CAM diagonal latch is unknown; yaGPC2
  clears it on that GPC's HALT.

---

## Related files in this directory (not this handoff’s subject)

- `stsKeyboard.py` — 8×4 black DPS keyboard, same Canvas / `--size` (unit
  768) / no-focus habits; sends scan codes on keyboard bus `--kybd N`.
  See HANDOFF-stsKeyboard.md.  Since 2026-09-15 (not yet in that handoff)
  it also listens on its own bus: a key sent by anyone else (a crew script,
  `--keys`) shows pressed for `FLASH_S` (0.3 s), the same look as a mouse
  press -- mid-grey face `C_KEY_PRESSED` #787878, dark inset edge, legend
  sunk `PRESS_SINK` (3% of key size).  Echoes of its own clicks, within
  `ECHO_S` (1 s), are skipped.  Near-white was tried and looked like a lamp.
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
- `crewscript.py` — the crew script language, parser and player (see
  "Scripted playback").  Run directly it is only a checker:
  `python3 crewscript.py FILE ...`, and `--help` for the commands.
  `examples/4gpc-startup.script` is the worked example.
- `subtitles.py` — caption box for demonstration videos.  Captions are UTF-8
  datagrams on the discrete bus group at port base + 90; empty clears, the
  two characters `\n` break a line, and a leading `<left>`, `<center>` or
  `<right>` aligns that caption (else `--align`, default center).  A managed,
  undecorated window: `_MOTIF_WM_HINTS` "2, 0, 0, 0, 0" is set on Tk's
  wrapper (the parent of `winfo_id()`) before the first map, since Marco
  reads it only then, so it is listed in the taskbar without a title bar;
  `--no-taskbar` gives the old overrideredirect window.  The box keeps its
  width and TOP edge and grows downward to fit wrapped text (growing upward
  covered what the caption was about), never below the `--geometry` height,
  moving up only to stay on the screen.  `--edit` takes typing (Enter,
  Backspace, Escape), Ctrl +/- font size, Ctrl L/E/R alignment, drag to move
  and Shift-drag for width and minimum height, and prints
  `--geometry WxH+X+Y --font-size N --align A` after each change; a drag
  first re-reads the window's real position, as the window manager may have
  placed it elsewhere.  Nothing starts it: run it with the same `--port-base`.
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
6976ba4c0 2026-09-14  IDP switches on panelO6 (C2, O6 IDP LOAD); MEDS2 pane hidden, IDP box real
4ba71a40c 2026-09-14  panelO6: IDP/CRT 4 POWER and MAJ FUNC, panel R11
5c1d5a79d 2026-09-14  simulatePASS: --crts 3 and 4; panelO6: R11 inset margins match C2
81d4b5570 2026-09-14  Keyboard windows titled 1, 2, 3; R11 inset's right margin matches its left
3b435dc19 2026-09-14  Documentation sync: MEDS2, panelO6 and stsKeyboard handoffs
bca2581d5 2026-09-14  Running GPCs ride through a silent crew panel; panelO6 publishes from its own thread
1efb8a53e 2026-09-15  panelO6: GPC-driven talkbacks, and scripts that wait for them
c88b8e649 2026-09-15  subtitles.py: a caption box for demonstration videos, driven from the scripts
83f671d2d 2026-09-15  subtitles.py: align a caption on its own with a leading <left>, <center> or <right>
f1f6d064c 2026-09-15  Panel scripts count in seconds, as keys files do
b2e0b94c3 2026-09-15  crewscript.py: one crew script for switches, keys, captions and waits, played on one clock
d93266cde 2026-09-15  Crew scripts for demonstrations: show the panel, and 'wait user' before starting
c7b2d5ddb 2026-09-15  --wait-user: the demonstration pause without editing the script
9715d8310 2026-09-15  panelO6: keep the 'wait user' cursor when the pointer leaves and returns
4ef0faac0 2026-09-15  panelO6.py: --help lists every crew-script command
064b84ffa 2026-09-15  Crew-script commands in one place; --help names only what a user can run
```

cam.py (voting.py until 0399e250c): 5b22c9a46 … 0399e250c (2026-09-12),
9a4d06181 and 46538bfba (2026-09-13).  simulatePASS.py: bc5c3e473.
