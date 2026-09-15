### [2026-09-14] Target: README.md (simulatePASS)
- simulatePASS --yagpc-extra "ARGS" appends options to the yaGPC2 command line (shlex-split), e.g. --yagpc-extra "--barrier-spin-us 50 --rt-idle-poll-ms 2".

### [2026-09-14] Target: HANDOFF-meds2-py.md
- EDGEKEY PUSHBUTTONS. Each MDU window now has six clickable edgekeys in a grey bezel strip under the display, as on the orbiter (DPS Workbook USA005350 Rev B fig. 2-26 p. 2-33; yaShuttle/MDU.jpg): square keys between seven rounded ribs, each centred under its legend box (centres from MDUMenuArea.menuBoxX mapped through CAM_L/CAM_R; the photo's key pitch 0.149 of display width matches the boxes' 7.75/52.24). Class MDUEdgeKeyStrip (before MDUWindow); strip height EDGE_STRIP_K = 0.09 of canvas width; MDUWindow.setEdgeStrip/stripBox/_stripK, and _layoutBox/_snapToAspect include the strip, so the window grows by exactly its height and the canvas keeps every pixel. MDUEdgeKeys gained press(i)/release(i), used by both F1-F6 and clicks, so a key held STUCK_MS (2 s) by mouse fails exactly as by F-key. On by default; --no-edgekeys or NSTS_MDU_EDGEKEYS=0 hides it (=1 forces it on). NSTS_MDU_FRAMELESS=1 window grabs now include the strip below the display. VERIFIED: offscreen widget test (click key 4 -> handler 3; 2.3 s hold fails key 2, later clicks on it ignored; bezel click ignored) and a full --dev crt1 MDU in Xephyr (synthetic press/release on key 4 took MAIN menu to DPS; window 508x554 = 508 canvas + 46 strip at --size 512, dpr 2). Test note: QT_SCALE_FACTOR=2 is set in this desktop's environment, so a Xephyr screen must be about twice the window's logical size or a root capture shows only its top-left.

### [2026-09-14] Target: README.md
- MEDS2.py draws the MDU edgekeys as clickable pushbuttons under each display (F1-F6 still work); --no-edgekeys or NSTS_MDU_EDGEKEYS=0 hides them. simulatePASS.py counts the strip (0.09 x --size) in its fits-on-screen height check.

### [2026-09-14] Target: HANDOFF-panelO6.md
- panelO6.py publishes its discretes from its own thread (_pub_loop): the Tk side only hands it the columns, the thread sends RESET then SET per register on every change and every REPUBLISH_MS, so a Tk thread waiting on a busy X server no longer silences the bus (with Xorg pegged it had gone quiet for more than yaGPC2's 1.5 s staleness limit and halted every running GPC; yaGPC2 ledger #147). _tick logs 'Tk tick N ms late' past 200 ms. Test hook NSTS_PANEL_STALL=<start s>,<seconds> holds the Tk thread once.

### [2026-09-15] Target: README.md
- panelO6 talkbacks are now GPC-driven: OUTPUT row from each GPC DO bit 7 (I/O ACTIVE), MODE row IPL from DO bit 31 and RUN from DO bit 9 (RUN(READY), set by FCMSWMON when a load completes), barberpole otherwise; per-GPC OUT listeners with a REQUEST at start; changes logged as "GPCn MODE tb  A -> B" / "GPCn OUTPUT tb  A -> B". Sources: DPS Workbook USA005350 Rev B 2.x/3.x, DPS Overview Workbook 3-6/3-7, DPS Console Handbook SCP 5.18.
- panelO6 layout: IPL_TO_MODE_TB_GAP 50 px (one pushbutton) above the MODE talkbacks; REF_H 1250 -> 1300; talkback word size 9, centred on its ink.
- --script `wait gpc N mode-tb RUN|IPL|BP [timeout S]`; later times count from when it is met; a timeout stops the script.
- simulatePASS --keys `WAIT gpc N mode-tb ... [timeout S]` (follows panel.log); panel height 1300 in window layout. Verified one GPC (run talkback-test: wait met 24.8 s after ITEM 1 EXEC).

### [2026-09-15] Target: README.md
- New subtitles.py: borderless always-on-top caption box for demo videos; captions are UTF-8 datagrams on the discrete bus group at port base + 90 (empty clears, \n = new line); drag to move, right-click Clear/Quit, Ctrl+Q; --geometry, --font/--font-size, --fg/--bg, --opacity, --hide-when-empty, --text.
- Script command: panelO6 --script `<ms> subtitle TEXT`; simulatePASS --keys `<seconds> SUBTITLE TEXT`; simulatePASS starts subtitles.py (bottom centre) when either script has one, --subtitles / --no-subtitles override.
