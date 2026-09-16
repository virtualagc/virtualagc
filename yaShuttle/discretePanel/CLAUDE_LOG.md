### [2026-09-15] Target: HANDOFF-panelO6.md
- Script times may be written +N: N seconds after the line before was due (or after the start / the last wait), resolved when the file is read, so inserting a line needs no renumbering; plain N still means from the start or last wait, and the two mix. In crewscript.parse (crew scripts, panelO6/simulatePASS --script), discretePanel.py _parse_script (relative to the previous line in file order, before its sort), and simulatePASS --keys files (reset after WAIT). crewscript.HELP example now uses +N.

### [2026-09-15] Target: HANDOFF-panelO6.md
- Every panelO6 control now has a crew-script command, by legend, acting on the gpc N column where per-GPC: power on|off, output backup|normal|terminate, display on|off (C3), select 1+2|2+3|3+1, disengage left|right (F6), rhcengage cdr|plt (held IPL_HOLD_MS); crt and bfsengage stay as shortcuts. crewscript.PANEL_ARGS/PANEL_USAGE check every panel command's arguments when a script is read (case-insensitive), so crewscript.py FILE reports a bad value with the allowed ones. HELP's panel section is now grouped by panel (O6 per GPC, O6 shared, C3, F6/RHC, C2/R11).

### [2026-09-15] Target: HANDOFF-panelO6.md, HANDOFF-meds2-py.md
- Screen waits: crew scripts may `wait crt N title TEXT [timeout S]` (TEXT anywhere in the top two lines, spaces squeezed, case ignored, quotes optional) and `wait crt N new-screen [timeout S]` (top two lines differ from those on show when the wait began, clocks masked; a page on a silent/blank CRT counts). MEDS2.py Screen_DPS collects each frame's glyphs by row/col (_frameRows, filled at the GLYPH site), and after both passes _announceTopLines sends "<mdu name>\n<line1>\n<line2>" to the bus group at port base + 91 (SCREEN_OFFSET) on a change held for two refreshes or at least every SCREEN_REANNOUNCE_S 1 s (only when refreshes happen: --dev refreshes once, so it is silent there). mduName is set from CONFIG config.lru lowercased when the screen is created. crewscript.ScreenWatch listens; Player(screens=) polls; panelO6 passes one. Verified one-GPC run: new-screen met on "GPCIPL MENU (1) 1 PASS1 1 PASS5 9", title GPC MEMORY met 1.1 s after RUN. simulatePASS --keys WAIT lines do not have these.

### [2026-09-15] Target: HANDOFF-panelO6.md
- simulatePASS.py now parses a --script with crewscript.parse before starting anything, and exits with the script error ("-- nothing started"); before, a bad script silently stopped panelO6 at start-up while yaGPC2, MEDS2 and the keyboards ran on without a panel.

### [2026-09-15] Target: HANDOFF-panelO6.md
- crewscript HELP now says [timeout S] is the literal word timeout plus seconds (default WAIT_TIMEOUT_S 600); a wait ending in a bare number after mode-tb STATE or new-screen gets the error "a timeout is written with the word timeout". A title may still end in a number.

### [2026-09-15] Target: HANDOFF-panelO6.md
- subtitles.py --edit: the typing cursor shows only while the box has keyboard focus (FocusIn/FocusOut), so clicking another window hides it for a recording; Ctrl H toggles it (cursor_wanted). In --help, the docstring and the start-up line.

### [2026-09-15] Target: HANDOFF-panelO6.md
- examples/4gpc-startup.script now waits for the GPCIPL menu (`wait crt N title GPCIPL timeout 150`) instead of the fixed 67/65 s STBY-to-ITEM-1-EXEC delays; 8 waits, no guessed delay left. Verified 2026-09-15: four GPCs to OPS 2, no CAM lamp, mmu1 239 commands / 2045 blocks read; menus at 13.5 s after each STANDBY, loads 25.2/27.3/28.0/28.5 s, OPS 2 typed about 363 s after the panel started (570 s with talkback waits only, 840 s with fixed times).
