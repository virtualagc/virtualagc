### [2026-09-11] Target: HANDOFF-meds2-py.md
- §1 flags: add `--scale X` (text size only). Per-LRU config key `textScale` does the same; the CLI value overrides it for every launched MDU. `CharGen.scaleGlyphs` scales each font's strokes at load time about that font's digit ink centre (meds 1.368,0.330 = GXC/GYC; deu 1.524,0.509). Advances, anchors, vectors and stroke weight (px) are unchanged; ADI ball labels (`_ballText` reads `medsFont.chars`) follow automatically. Verified by screenshots of DPS and AE_PFD at 1 and 0.85. Side effect: glyph-built rules (rows of `-`, `|`) open gaps below 1.0.

### [2026-09-11] Target: HANDOFF-meds2-py.md
- §1 flags: add `--stroke-scale X` (text stroke width only; config key `textStrokeScale`). Text strokes are `lineWidthPx × X`; halos keep their px border either side of the thinner core. `VectorDisplay.lines` gained `widthScale`, with scaled materials cached in `wMats`; at 1 the palette's own materials are used. ADI ball labels moved from bucket `d` into a new `dt` bucket, created right after `d`, so the draw order at 1 is unchanged. Verified: at 1 both DPS and AE_PFD are pixel-identical to the pre-change build; at 0.6 every changed pixel lies in the text mask (from a `--scale 0.01` render), 0 outside.

### [2026-09-11] Target: HANDOFF-panelO6.md
- Now describes `discretePanel/panelO6.py` (the former `panelO6-paddle.py`, moved; the old capsule `panelO6.py` is discontinued). New ACTIVITY pane: F6's size and column, bottom on O6's bottom edge (below the IPL SOURCE tab, ~146 ref px clear). Title 10 pt like F6; MM1 / MM2 captions 10 pt, each lamp right of its caption, pair centred on the pane's quarter points. Lamp = disk of diameter cap height, thin black rim, fill C_PANEL (OFF) / green READY / red BUSY. Cap height: Tk has no such metric and its ascent is not one (Nimbus Sans ascent ~= caps, Arial 1/4 taller), so em = measure("0123456789") / 5.56 and cap = 0.72 em (Helvetica metric family). Centred on the caps' ink, not the em box. Indicators only: `set_activity(i, state)` logs and redraws; not clickable, not driven by anything yet. Verified by screenshot: disk 20 px vs caps 20 px at --size 1024; correct at 512.

### [2026-09-11] Target: HANDOFF-panelO6.md
- panelO6.py is now WIRED to the discrete bus (discretes.py; replaces discretePanel.py). One GPC wired: `--gpc-id N` (default 1) = column N's MODE/IPL/OUTPUT + shared IPL SOURCE, BFC CRT, F6 DISENGAGE, RHC ENGAGE; published ID = N. Other columns drawn/operable, publish nothing (bus has no GPC address; multi-GPC needs a protocol change). Owned bits republished every 250 ms as one RESET + one SET per register (break before make); log prints `GPCn discretes A=.. B=..` on every change.
- Mapping (authority: BFS.SRC/MLIB80/ENTRYS.asm DIA table; DPS Workbook USA005351C §1.1.2, 8.2, 13.2): A0-2 MODE HALT/STBY/RUN; A3 IPL only while held AND in HALT; A4/A5 IPL SOURCE MMU1/MMU2 (OFF neither); A12 I/O TERM A held 0 ("FROM HDWR=0", "CLAMPED TO ZERO"; STM0 ERROR 129 if set) — script `bit A 12` still sets it; A13 I/O TERM B = BFC logic; B0-2 GPC ID; B3-5 BFS ENGAGE = that GPC's BFC latches; B6-7 CRT field = 0 if BFC CRT DISPLAY OFF, else 2+3→1, 3+1→2, 1+2→3 (user correction 2026-09-11; NOT the workbook-8.2 "first number" reading, which was the first wiring).
- BFC module model (Workbook 13.2.1): BFC GPC SELECT = TERMINATE or highest-numbered BACKUP GPC; SELECT OFF = TERMINATE or no GPC in BACKUP; latch set by either RHC ENGAGE pb unless SELECT OFF or F6 DISENGAGE RIGHT (clear dominates); TERM B = latch XOR GPC SELECT. One latch per module stands for the 3-contact / 3-of-3 voting (no failures simulated). OUTPUT talkback now GRAY iff POWER ON and RUN and not TERM B, so an engage turns PASS tbs barberpole and the BFS tb grey. MODE tb shows IPL only when the IPL press is live (HALT).
- New pane RHC BFC ENGAGE (two lines "RHC"/"BFC ENGAGE", CDR + PLT momentary pbs, 40 px, IPL grey — user rejected red: it competes with the lamps) directly above ACTIVITY; ACTIVITY shortened to one caption line under the title. 40 px chosen by measuring clearance under the IPL SOURCE tab: ≥15 px at --size 300..2000 (50 px left ~5 px at 300/700).
- ACTIVITY lamps are driven by observed MM READY A6/A7: grey (OFF) until the unit is first heard, then SET green / RESET red for good — no staleness timeout (user request: a quiet unit keeps its last state). Listener thread only records; Tk-side `_tick` (250 ms) applies — no Tk calls from the thread.
- `--script`/`--quit-after`/`--port-base`/`--gpc-id` as discretePanel.py; scripted runs never map the window. Verbs: mode HALT|STANDBY|STBY|RUN, ipl, source MM1|MM2|OFF, crt 0-3, bfsengage on (CDR press/release) | off (DISENGAGE RIGHT then LEFT), gpcid N (rewires the column), bit A|B N on|off (A12 TERM A, A13 → OUTPUT TERMINATE/NORMAL, B3-5 engage, B6-7 fold into crt, else raw once).
- Startup positions deliberately kept (user choice): IPL SOURCE OFF, BFC CRT DISPLAY OFF → default-option IPL. discretePanel.py started MM1 + CRT 1 (menu IPL).
- Verified: same 20-command script through both panels on port base 17900, bus sampled at +120/+700 ms: identical from `source MM1` on except by design (startup positions; `bfsengage on` also raises TERM B; mid-script `gpcid 2` takes column 2's own MODE).

### [2026-09-11] Target: README.md
- panelO6.py line: it is now the working replacement for discretePanel.py on the discrete bus (GPC 1 or --gpc-id N, both MMUs' READY shown as ACTIVITY lamps). Note its switches start at IPL SOURCE OFF / BFC CRT DISPLAY OFF, unlike discretePanel.py.

### [2026-09-11] Target: ../yaGPC2/RUNBOOK-IPL-MEDS.md
- C.3/C.5: with panelO6.py instead of discretePanel.py, set IPL SOURCE to MMU 1 and BFC CRT DISPLAY ON with SELECT 2+3 (field value 1, what discretePanel.py called CRT 1) before moving MODE to STBY — panelO6 starts with both OFF (default-option IPL); discretePanel.py started at MM1 + CRT 1 (menu-option IPL), which C.5 assumes.

### [2026-09-11] Target: HANDOFF-panelO6.md
- "Startup defaults": all five POWER switches now start OFF (user request), not ON. POWER drives no discrete, so the bus is unchanged; the only effect is that OUTPUT talkbacks stay barberpole until a GPC is powered (output_tb requires POWER ON).

### [2026-09-11] Target: HANDOFF-panelO6.md
- `--size N`: the unit is now 768, not 1024 (FULL_SIZE = 768; user request). 768 = the design window 948x1250 (still the default); 512 = 2/3 (632x833); 384 = half. Replace every "1024 is full size" / "512 is half" in the handoff. stsKeyboard.py still uses 1024.

### [2026-09-11] Target: HANDOFF-stsKeyboard.md
- The keyboard is wired: a button press sends the key's scan code (`SCAN`, copied from MEDS2.py `KYBD.DEUKey`, cross-checked 32/32) as one big-endian halfword to 239.255.1.1:6931+N-1 (`--kybd N`, default 1; `NSTS_BUS_IFACE` honoured). Sent on press, not release, like the MDU window's keydown. Which MDUs echo each bus: KYBD1 crt1 crt3 cdr1 cdr2 plt2 mfd2; KYBD2 crt2 plt1 mfd1; KYBD3 crt4 afd1. Verified end to end against `MEDS2.py crt1 idp1`: IDP1 queued [SPEC,1,2,PRO] and crt1 drew "SPEC 12 PRO"; a KYBD2 key did not reach either.

### [2026-09-11] Target: HANDOFF-meds2-py.md
- §10 departures: `KYBD.recvKYBD` (the MDU's own keyboard-bus listener) now echoes keys from OTHER senders on its bus onto the scratch pad; the original only printed them. Needed for stsKeyboard.py, because the IDP never sends typed keys back to the MDU (only RESET_SPL). The window's own sends are dropped as self-echo, so nothing echoes twice (verified). Side effect: two MDUs on one keyboard bus now both echo, as both of their IDPs hear the key. Limitation: an MDU echoes only the FIRST `_KYBDn` of its primary IDP, so KYBD2 keys reach IDP3 but don't echo on crt3/cdr1/plt2.

### [2026-09-11] Target: HANDOFF-meds2-py.md
- `--size N` is no longer pixels: the window is the config size × N/768 (`SIZE_UNIT = 768`, the same unit as panelO6.py). 768 = full size (1024 px as shipped; the default), 512 = 2/3 (683 px), 384 = half (512 px); `displayPx` = jsround(width × N/768). §1 flag list: say so. §10: "A window dragged to 512 is bit-identical to `--size 512`": the matching flag is now `--size 384`. Sizes larger than the screen are capped by the window manager (at 1920×1080 logical, `--size 1024` asks for 1365 px and gets 1056).

### [2026-09-11] Target: HANDOFF-meds2-py.md
- SUPERSEDES the `--size N` entry just above: that change was reverted (1967e38d3) at the user's request. MEDS2.py's `--size` is pixels again, 1024 = full size, so HANDOFF-meds2-py.md needs no `--size` change.

### [2026-09-11] Target: HANDOFF-stsKeyboard.md
- `--size N`: the unit is now 768, not 1024 (FULL_SIZE = 768; user request, matching panelO6.py). 768 = the design window 509×1004 (still the default); 512 = 2/3 (339×669); 384 = half (254×502); 1024 = 4/3 (679×1339). Replace every "1024 is full size" / "512 is half" / "default `--size 1024`" in the handoff. This supersedes "stsKeyboard.py still uses 1024" in the HANDOFF-panelO6.md entry above. MEDS2.py keeps pixels (1024 = full).

### [2026-09-11] Target: HANDOFF-meds2-py.md
- §12's "page blank but the clock updates -> a DISPLAY_FILL was dropped at the socket" is not the usual cause. With rmem_max at 8 MB, the IDP received every fill; the GPCIPL page went blank because the IDP answered GPCIPL's polls LATE (its event loop also draws the MDU; replies up to ~65 ms late against a 5 ms window). GPCIPL then re-IPLs the unit (two zero-fill loads in the log, sometimes an "unheadered fill of 8 halfwords") and after a second failure never sends the menu. Fixed on the GPC side (yaGPC2 bcenet_framer_peer_wait, gpc-causes #85); signature to add to the table: "load started" twice in the IDP log, then no 509-halfword fill at 0x19ee.
- stsKeyboard.py -> MEDS2.py verified in a namespace run: KYBD1 scan codes logged as "KYBD1: _KYBD1 recv ITEM/1/EXEC" by IDP1, and the next poll reply carries KYBD_MSG. (HANDOFF-stsKeyboard.md still says nothing is sent and that 1024 is full size; both are out of date.)

### [2026-09-11] Target: HANDOFF-meds2-py.md
- New in 1b8f7f3c0: the IDP pane (class IDPPane, before MDUWindow) -- IDP POWER, IDP MAJ FUNC, DEU LOAD down the right of each MDU window, panelO6.py styling, 150 per 1024 of canvas; --no-pane / NSTS_MDU_PANE=0. New MDU->IDP tags DEU_LOAD 0x0002, IDP_POWER 0x0003 (DEUUnit.requestLoad/powerUp, IDP.setPower/deuLoad). MDUWindow lays canvas+pane out as one block (_layoutBox, paneBox). Re-IPL needs DEU LOAD (Table 2-2 step 9). Also: _drawPasses now clears the DFG background when BACKGROUND_TOP loses its BRANCH (it used to stay drawn). Testing recipe that needs no desktop: unshare -rn + Xephyr + QT_XCB_GL_INTEGRATION=xcb_egl LIBGL_ALWAYS_SOFTWARE=1; QT_QPA_PLATFORM=offscreen cannot host the MDU (no QOpenGLWidget) but can render IDPPane alone.

### [2026-09-12] Target: README.md
- New `voting.py`: GPC STATUS / FAILED GPC 5×5 lamp matrix (diagonal absent; yellow GPC numbers there; lamps white ON, slightly darker than the pane OFF). Digit pairs 1-5 toggle row/column; click also toggles. Same gull-grey panelO6/stsKeyboard styling; `--size` unit 768, `--geometry` / `NSTS_VOTING_GEOMETRY`. Unlike the other two, this window takes the keyboard.

### [2026-09-12] Target: README.md
- voting.py layout now follows DPS Workbook USA005350 Rev B Fig. 3-27 (pdf p. 95) / Fig. 3-19: dimension-ruled GPC STATUS/FAILED GPC with end ticks, wider cell gaps, inner lamp ~0.42 of the cell. VOTING GPC left labels kept from the original sketch (Fig. 3-19).

### [2026-09-12] Target: README.md
- voting.py now follows ~/Desktop/voting2.png: mesh lamps in the upper half of each cell, large yellow diagonal numbers, dimension-ruled GPC STATUS/FAILED GPC sitting right of centre, VOTING vs GPC letter groups, panel fastener at top-left.

### [2026-09-12] Target: [yaShuttle/discretePanel/README.md]
- `voting.py` is now `cam.py`: the panel is the Computer Annunciation Matrix,
  and CAM is what the flight software calls it (FCMSFCAM, SETCAMEX). Window
  title "CAM". `--size` unit is now 512, not 768 -- this is a small annunciator
  beside panelO6/stsKeyboard's full-height panels, and at their unit the
  natural window came out tiny; `--size 384` is now 3/4, `--size 768` is 1.5x.
  The env override is `NSTS_CAM_GEOMETRY` and the class is `CamPanel`.
- What drives the lamps, now that yaGPC2 publishes it: discrete register 4,
  `DISCRETES_REG_FAILVOTE`, five bits per GPC on that GPC's own channel -- one
  ROW of the matrix, which computers that one has voted out. The bits are
  ROTATED relative to the emitting GPC (FCMSFAIL's FCMCVTM), so a consumer
  must un-rotate for absolute columns, and the exact bit order is read from
  the assembly and NOT yet confirmed against a run.

### [2026-09-13] Target: [HANDOFF-panelO6.md]
- `cam.py` corrected per the user: every CAM lamp fills its cell (no small centred square); the diagonal cells are lamps too, lit YELLOW with the GPC number as a BLACK legend (off-diagonal lamps light WHITE); the diagonal shows each GPC's vote against ITSELF, so keystroke pairs 11..55 and clicks toggle it. yaGPC2's fail-vote register already names that bit "fail vote N+0 (self)" (bit 27, src/discretes.c). cam.py is still keystroke/click driven, not wired to the discrete bus.

### [2026-09-13] Target: [HANDOFF-panelO6.md]
- `cam.py` now follows the computers: listens on all five GPC discrete channels (--port-base, --no-bus), rows from each GPC's raw fail-discrete register un-rotated (0x08..0x01 = N+1..N+4, 0x10 inhibits the row), diagonal from the new register REG_CFAIL (5, bit 31, discretes.py CFAIL_LIT) that yaGPC2 composes for the lamp; REQUESTs both registers at start-up; a lit lamp stays lit at least HOLD_MIN_S = 40 ms. Verified in yaGPC2 runs cf-short-0 and cf-g3-0 (ledger #141).

### [2026-09-13] Target: [HANDOFF-meds2-py.md]
- MEDS2.py: Screen_DPS.setClock redraws the header clock only when its text changes (tracked in _clockDrawn, reset when geo_dps_time is rebuilt). GPCIPL time-fills every poll, twice a second, so half the redraws repainted unchanged digits and the clock looked like it ran 1.5-2x fast; the user confirmed it looks right now. New diagnostic NSTS_CLOCK_LOG=<file>: wall-stamped "send" (IDP forwards a time fill) and "draw" (MDU draws it) lines.
