# Scriptable controls

Every control that a crew script can operate, grouped by the window it appears
in, with an example of each.  Crew scripts are the files that `simulatePASS.py
--script FILE`, the manager's SCRIPT **Play** button, or
`crewscript.send_control("play FILE", PORT_BASE)` hand to `panelO6.py`, which
carries them out.

Every example below is a complete script line.  `+N` means "N seconds after the
line before"; `+0` is used throughout so that a line can be copied as it is.
`python3 crewscript.py FILE` checks a script without running anything, and
`python3 crewscript.py --help` is the full grammar, including the commands that
are not controls (`wait`, `keygap`, `script`, `audio`, `snapshot`).

## Things that apply everywhere

* **Case does not matter**, either in command words or in positions:
  `mode run`, `MODE RUN` and `Mode Run` are the same.
* **A control can be scripted while its window is hidden.**  Apart from O6, C2
  and R11, panelO6 shows a panel's window only while an OPS that reads that
  panel is on a display.  A script works on the panel's switch state, not on
  the window, so `switch` and `press` work regardless.
* **Pushbuttons are pressed and released by themselves.**  Every pushbutton
  command holds the button for a fixed time (given with each one below) and
  then lets it go.  There is no "press and hold" command.
* **Spring-loaded positions return on their own.**  A `switch` to a
  spring-loaded position, such as a trim switch moved to UP, goes back to the
  switch's resting position after the time given in the tables below.
* **Commands do not wait for their effect.**  A line is done when the switch
  has moved, not when PASS has reacted.  To wait for PASS, use a `wait` line:
  `wait gpc N mode-tb RUN`, `wait crt N title TEXT` or
  `wait crt N new-screen`.
* **`circle FEATURE [COLOR] [DIAMETER]` / `nocircle`** draw attention to a
  control or an indicator during a demonstration.  They move nothing, and
  only one `circle` is up at a time.  The FEATURE names are listed in
  `crewscript.py --help`; for example `circle mode2` circles GPC 2's MODE
  switch.  Indicators can be circled too, though they cannot be moved:
  the GPC MODE and OUTPUT talkbacks, the ACTIVITY lamps, the caution and
  warning matrix and the rest, every one listed under "Indicators (for
  `circle` only)" below.
* **`autocircle [SECONDS] [COLOR] [DIAMETER]`** circles, from that line on,
  every O6-program control a script moves: from 1 s **before** the move, so
  the eye is there when it happens, until SECONDS (default 1) after it.  A
  move due sooner than 1 s away (at the start, just after a `wait` or typing)
  is held until its circle has been up for 1 s, and the lines after it keep
  their spacing; the log says so ("held 1.00 s so that its circle shows
  first").  While a `wait gpc N mode-tb ...` waits, GPC N's MODE talkback is
  circled until the wait ends.  COLOR and DIAMETER are as for `circle`.  It
  is independent of `circle` and `nocircle`, and a control may carry both;
  `autocircle 0` turns it off and takes its circles away.  Keys, MDU
  edgekeys, the hand controllers and `lps` are not panel O6 controls and are
  not circled.

      +0  autocircle
      +0  autocircle red 2.5
      +0  autocircle 3 #00ff00

---

## Window "O6" (panel O6, the GPC controls)

### Choosing the GPC first: `gpc N`

**The GPC POWER, OUTPUT, MODE and IPL commands act on one GPC column at a
time, and `gpc N` chooses which.**  The choice persists until the next
`gpc N` line, including through scripts called with `script FILE`.  A script
that never says `gpc N` acts on the primary column, which is GPC 1 unless
`gpcid N` has changed it.  The usual mistake is a `mode RUN` aimed at the
wrong computer because the `gpc` line was left out.

```
+0  gpc 2
+0  mode HALT
```

| Control | Command | Example | Notes |
|---|---|---|---|
| GPC POWER | `power on\|off` | `+0  power on` | Needs `gpc N` first. |
| GPC OUTPUT | `output backup\|normal\|terminate` | `+0  output normal` | Needs `gpc N` first. |
| GPC MODE | `mode halt\|standby\|run` | `+0  mode standby` | Needs `gpc N` first.  `stby` is accepted for `standby`. |
| INITIAL PROGRAM LOAD | `ipl` | `+0  ipl` | Needs `gpc N` first.  Pushbutton, held 0.25 s.  Has no effect unless that GPC's MODE is STANDBY or HALT and IPL SOURCE is set; see the IPL sequence below. |
| IPL SOURCE | `source mm1\|mm2\|off` | `+0  source MM1` | One switch, shared by every GPC.  Leave it OFF once the loads are done. |
| IDP LOAD 1-4 | `idpload N` | `+0  idpload 3` | Momentary, held 0.25 s.  **Only works during a GPC's IPL:** PASS loads a display only when the IDP asks at the IPL (GPCIPL).  Once a GPC is running an OPS it ignores the request (ledger #197).  Press it together with `ipl`, as the IPL sequence below does. |
| RHC BFC ENGAGE (commander's) | `rhcengage cdr` | `+0  rhcengage cdr` | Pushbutton, held 0.25 s. |
| RHC BFC ENGAGE (pilot's) | `rhcengage plt` | `+0  rhcengage plt` | Pushbutton, held 0.25 s. |
| BFS engage shortcut | `bfsengage on\|off` | `+0  bfsengage on` | Not one control: `on` presses the CDR RHC BFC ENGAGE pushbutton; `off` moves F6 BFC DISENGAGE to RIGHT and back. |

**The IPL sequence.**  A GPC's IPL in the order it must happen, as
`examples/ipl-one-gpc.script` does it.  The waits matter: a fixed delay in
their place fails on a slow host.

```
+0     gpc 1
+0     mode HALT
+0.02  idppower 1 on
+1     source MM1
+1     crt 1
+0.5   idpload 1
+0.5   ipl
+3     mode STANDBY
wait crt 1 new-screen timeout 300
wait crt 1 title GPCIPL timeout 300
+2     keys KB1 ITEM 1 EXEC
wait gpc 1 mode-tb RUN timeout 900
+1     crt 0
+12    mode RUN
+12    source OFF
```

* `idppower` comes first: an unpowered IDP cannot ask to be loaded.
* `crt N` (panel C3) puts the GPCIPL display on CRT N, and `idpload N` loads
  that CRT's IDP during this IPL.
* **Nothing else for 10 s either side of `mode RUN`.**  PASS Program Note
  42433 forbids GPC/CRT keys, BFC CRT SELECT changes and other moding in that
  window, because the new computer's initialisation can overwrite the data
  they produce.  Ignoring it occasionally made a fourth GPC fail the others
  (ledger #256), which is why there are 12 s gaps around `mode RUN` above.
* With several GPCs, the `wait crt N new-screen` matters: a later computer's
  `title GPCIPL` wait would otherwise be met at once by the previous
  computer's menu still on the screen.

### STAR TRACKER pane

| Control | Command | Example | Notes |
|---|---|---|---|
| POWER -Y / -Z | `switch strk_pwr_y\|strk_pwr_z ON\|OFF` | `+0  switch strk_pwr_z ON` | Off makes the tracker show BITE on SPEC 22: no data. |
| DOOR CONTROL SYS 1 / SYS 2 | `switch strk_door_sys1\|strk_door_sys2 OPEN\|OFF\|CLOSE` | `+0  switch strk_door_sys1 OPEN` | One SYS switch moves a door in 12 s, both together in 6 s. |
| DOOR POSITION -Y / -Z | none (display only) | | Talkbacks: OP, CL, or barberpole while travelling. |

* **Opening a door needs that tracker's POWER ON.** Closing does not.
* **A door that is not fully open means no stars** for that tracker.

### Not controls, but set from O6's side

| What | Command | Example | Notes |
|---|---|---|---|
| Primary GPC column | `gpcid N` | `+0  gpcid 2` | Makes GPC N the column a script acts on when it has not said `gpc N`. |
| One discrete bit, raw | `bit a\|b N on\|off` | `+0  bit a 12 on` | For tests.  A12 is I/O TERM A, A13 OUTPUT TERMINATE/NORMAL, B3-5 the BFS engage bits, B6-7 the CRT select bits.  Any other bit is sent once, raw, to the GPC chosen by `gpc N`. |

---

## Window "C2" (IDP/CRT 1, 3 and 2)

| Control | Command | Example | Notes |
|---|---|---|---|
| IDP/CRT 1-3 POWER | `idppower N on\|off` | `+0  idppower 3 on` | Until its IDP is powered, a CRT shows "MDU IS AUTONOMOUS" and its menus lack FLT INST.  With several GPCs, assign the CRT to its GPC first (on GPC/CRT, `ITEM 12`/`13`/`14 + gpc` for CRT 1/2/3).  An IDP powered before that is captured by whichever GPC is already in RUN, which then drives every display and runs slower (ledger #159). |
| IDP/CRT 1-3 MAJ FUNC | `majfunc N gnc\|sm\|pl` | `+0  majfunc 3 gnc` | |
| LEFT IDP/CRT SEL | `kybdsel left 1\|3` | `+0  kybdsel left 3` | Which IDP the commander's keyboard (KB1) talks to. |
| RIGHT IDP/CRT SEL | `kybdsel right 2\|3` | `+0  kybdsel right 3` | Which IDP the pilot's keyboard (KB2) talks to.  **To type on CRT 3 you must first move one of these to 3**, then type on that keyboard, and usually move it back afterwards (`examples/4gpc-g3-startup.script` does exactly this). |

## Window "R11" (IDP/CRT 4)

| Control | Command | Example | Notes |
|---|---|---|---|
| IDP/CRT 4 POWER | `idppower 4 on\|off` | `+0  idppower 4 on` | As for C2. |
| IDP/CRT 4 MAJ FUNC | `majfunc 4 gnc\|sm\|pl` | `+0  majfunc 4 sm` | |

---

## Window "C3" (center console)

| Control | Command | Example | Notes |
|---|---|---|---|
| BFC CRT DISPLAY | `display on\|off` | `+0  display on` | |
| BFC CRT SELECT | `select 1+2\|2+3\|3+1` | `+0  select 2+3` | |
| BFC CRT DISPLAY and SELECT together | `crt 0\|1\|2\|3` | `+0  crt 1` | `crt 0` is DISPLAY OFF; `crt 1`/`2`/`3` are DISPLAY ON with SELECT 1+2 / 2+3 / 3+1.  During an IPL this selects the CRT that GPC's IPL display goes to.  It counts as a CRT SELECT change for the 10 s rule around `mode RUN` (see the IPL sequence). |
| ORBITAL DAP SELECT A / B | `dap c3 a\|b` | `+0  dap c3 b` | Pushbutton, held 0.5 s.  The DAP reads these only in OPS 2 and 8. |
| ORBITAL DAP CONTROL | `dap c3 auto\|inrtl\|lvlh\|free` | `+0  dap c3 free` | Pushbutton, held 0.5 s.  **Press FREE before bringing IMUs to OPERATE** (SPEC 21) on a vehicle that went straight from OPS 0 to OPS 2.  Otherwise the DAP, in AUTO, treats each IMU coming up as an attitude jump and fires jets (ledger #270).  Press AUTO again afterwards. |
| ORBITAL DAP RCS jets | `dap c3 pri\|alt\|vern` | `+0  dap c3 vern` | Pushbutton, held 0.5 s. |
| ORBITAL DAP ROTATION | `dap c3 roll_disc\|roll_pulse\|pitch_disc\|pitch_pulse\|yaw_disc\|yaw_pulse` | `+0  dap c3 pitch_pulse` | Pushbutton, held 0.5 s. |
| ORBITAL DAP TRANSLATION | `dap c3 x_norm\|x_pulse\|y_norm\|y_pulse\|z_norm\|z_pulse\|low_z\|high_z` | `+0  dap c3 low_z` | Pushbutton, held 0.5 s. |
| FCS CHANNEL 1-4 | `fcs N override\|auto\|off` | `+0  fcs 2 auto` | |
| OMS ENG (left / right) | `omseng left\|right arm\|arm/press\|off` | `+0  omseng left arm/press` | yaGPC2 also needs `YAGPC_OMS_ARMED=1` in a run that has no OMS ARM contacts wired. |

C3's other controls are named controls; see "Named controls" below.

## Window "A6U" (aft station)

| Control | Command | Example | Notes |
|---|---|---|---|
| ORBITAL DAP pushbuttons (aft) | `dap a6u ...` | `+0  dap a6u inrtl` | The same buttons as on C3, written `a6u` (or `aft`). |
| SENSE | `sense -z\|-x` | `+0  sense -x` | The aft RHC/THC sense: -Z up or -X. |
| ADI ATTITUDE (aft) | `adi a att inrtl\|lvlh\|ref` | `+0  adi a att lvlh` | `attitude` is accepted for `att`. |
| ADI ERROR / RATE (aft) | `adi a err\|rate high\|med\|low` | `+0  adi a rate low` | `error` is accepted for `err`. |
| ATT REF (aft) | `attref a` | `+0  attref a` | Pushbutton, held 0.5 s. |

## Window "F6" (commander's flight instruments)

| Control | Command | Example | Notes |
|---|---|---|---|
| ADI ATTITUDE (CDR) | `adi l att inrtl\|lvlh\|ref` | `+0  adi l att inrtl` | `l` is the commander's (left) station. |
| ADI ERROR / RATE (CDR) | `adi l err\|rate high\|med\|low` | `+0  adi l err med` | |
| ATT REF (CDR) | `attref l` | `+0  attref l` | Pushbutton, held 0.5 s. |
| BFC DISENGAGE | `disengage left\|right` | `+0  disengage right` | RIGHT disengages. |

## Window "F8" (pilot's flight instruments)

| Control | Command | Example | Notes |
|---|---|---|---|
| ADI ATTITUDE (PLT) | `adi r att inrtl\|lvlh\|ref` | `+0  adi r att ref` | `r` is the pilot's (right) station. |
| ADI ERROR / RATE (PLT) | `adi r err\|rate high\|med\|low` | `+0  adi r rate high` | |
| ATT REF (PLT) | `attref r` | `+0  attref r` | Pushbutton, held 0.5 s. |

## Windows "F2" and "F4" (commander's and pilot's glareshield)

| Control | Command | Example | Notes |
|---|---|---|---|
| BODY FLAP AUTO/MAN | `bodyflap cdr\|plt` | `+0  bodyflap cdr` | Pushbutton, held 0.5 s.  `cdr` is F2, `plt` is F4. |
| SPD BK/THROT AUTO/MAN | `spdbk cdr\|plt` | `+0  spdbk plt` | Pushbutton, held 0.5 s. |

## Window "F3"

| Control | Command | Example | Notes |
|---|---|---|---|
| TRIM RHC/PNL | `trim left\|right enable\|inhibit` | `+0  trim left inhibit` | The left switch is the commander's and the right is the pilot's. |

## Window "O7"

| Control | Command | Example | Notes |
|---|---|---|---|
| MASTER RCS CROSSFEED | `xfeed left\|off\|right` | `+0  xfeed off` | LEFT and RIGHT are FEED FROM LEFT and FEED FROM RIGHT. |

O7's other controls are named controls; see below.

---

## Indicators (for `circle` only)

Indicators cannot be moved, and apart from the MODE talkbacks (`wait gpc N
mode-tb`) they cannot be waited on, but `circle` takes them by these names.

### Window "O6"

| Name | Indicator |
|---|---|
| `outputtb1` ... `outputtb5` | GPC OUTPUT talkbacks, GPC 1-5 |
| `modetb1` ... `modetb5` | GPC MODE talkbacks, GPC 1-5 |
| `activity-mm1`, `activity-mm2` | ACTIVITY lamps, MM1 and MM2 |
| `strk_door_tb_y`, `strk_door_tb_z` | STAR TRACKER DOOR POSITION talkbacks, -Y and -Z |

### Window "F6"

| Name | Indicator |
|---|---|
| `rcs_roll` | RCS COMMAND ROLL lamp |
| `rcs_yaw` | RCS COMMAND YAW lamp |
| `rcs_pitch` | RCS COMMAND PITCH lamp |

### Window "F7"

| Name | Indicator |
|---|---|
| `cw_r1c1` | O2 PRESS annunciator |
| `cw_r1c2` | H2 PRESS annunciator |
| `cw_r1c3` | FUEL CELL REAC annunciator |
| `cw_r1c4` | FUEL CELL STACK TEMP annunciator |
| `cw_r1c5` | FUEL CELL PUMP annunciator |
| `cw_r2c1` | CABIN ATM annunciator |
| `cw_r2c2` | O2 HEATER TEMP annunciator |
| `cw_r2c3` | MAIN BUS UNDERVOLT annunciator |
| `cw_r2c4` | AC VOLTAGE annunciator |
| `cw_r2c5` | AC OVERLOAD annunciator |
| `cw_r3c1` | FREON LOOP annunciator |
| `cw_r3c2` | AV BAY/ CABIN AIR annunciator |
| `cw_r3c3` | IMU annunciator |
| `cw_r3c4` | FWD RCS annunciator |
| `cw_r3c5` | RCS JET annunciator |
| `cw_r4c1` | H2O LOOP annunciator |
| `cw_r4c2` | RGA/ACCEL annunciator |
| `cw_r4c3` | AIR DATA annunciator |
| `cw_r4c4` | LEFT RCS annunciator |
| `cw_r4c5` | RIGHT RCS annunciator |
| `cw_r5c1` | (blank) annunciator |
| `cw_r5c2` | LEFT RHC annunciator |
| `cw_r5c3` | RIGHT/AFT RHC annunciator |
| `cw_r5c4` | LEFT OMS annunciator |
| `cw_r5c5` | RIGHT OMS annunciator |
| `cw_r6c1` | PAYLOAD WARNING annunciator |
| `cw_r6c2` | GPC annunciator |
| `cw_r6c3` | FCS SATURATION annunciator |
| `cw_r6c4` | OMS KIT annunciator |
| `cw_r6c5` | OMS TVC annunciator |
| `cw_r7c1` | PAYLOAD CAUTION annunciator |
| `cw_r7c2` | PRIMARY C/W annunciator |
| `cw_r7c3` | FCS CHANNEL annunciator |
| `cw_r7c4` | MPS annunciator |
| `cw_r7c5` | (blank) annunciator |
| `cw_r8c1` | BACKUP C/W ALARM annunciator |
| `cw_r8c2` | APU TEMP annunciator |
| `cw_r8c3` | APU OVERSPEED annunciator |
| `cw_r8c4` | APU UNDERSPEED annunciator |
| `cw_r8c5` | HYD PRESS annunciator |
| `mes_left` | MAIN ENGINE STATUS LEFT lamp |
| `mes_ctr` | MAIN ENGINE STATUS CTR lamp |
| `mes_right` | MAIN ENGINE STATUS RIGHT lamp |
| `sm_alert` | SM ALERT annunciator |

---

## Named controls (every panel window)

Every other switch, rotary, circuit breaker and pushbutton is reached by its
name in `panelcontrols.py`:

* `switch NAME POSITION` for anything with positions;
* `press NAME` for a pushbutton.

Using the wrong one of the two is an error, and so is a position the control
does not have; both are reported when the script is read.  A position
containing spaces is written as it is, `switch sband_pm_ant LL F`.  The
example given for each control moves it away from where it rests.

These panels' windows appear only while an OPS that reads them is displayed
(for example L12U/L12L/L11U and A8U in SM OPS 2), but as noted at the top, the
controls can be scripted whether or not the window is showing.

### Window "C3"

| Control (caption) | Positions | Example |
|---|---|---|
| `bodyflap_plt` (BODY FLAP) | UP / AUTO/OFF / DOWN (rests at AUTO/OFF); UP/DOWN spring back to AUTO/OFF after 0.5 s | `+0  switch bodyflap_plt UP` |
| `et_sep_pb` (ET SEP) | pushbutton, held 0.5 s | `+0  press et_sep_pb` |
| `et_sep_sw` (ET SEPARATION) | MAN / AUTO (rests at AUTO) | `+0  switch et_sep_sw MAN` |
| `me_limit` (MAIN ENGINE LIMIT SHUT DN) | ENABLE / AUTO / INHIBIT (rests at AUTO) | `+0  switch me_limit ENABLE` |
| `me_sd_ctr` (CTR) | pushbutton, held 0.5 s | `+0  press me_sd_ctr` |
| `me_sd_left` (LEFT) | pushbutton, held 0.5 s | `+0  press me_sd_left` |
| `me_sd_right` (RIGHT) | pushbutton, held 0.5 s | `+0  press me_sd_right` |
| `ptrim_plt` (PITCH TRIM) | DOWN / OFF / UP (rests at OFF); DOWN/UP spring back to OFF after 0.5 s | `+0  switch ptrim_plt DOWN` |
| `rtrim_plt` (ROLL TRIM) | L / OFF / R (rests at OFF); L/R spring back to OFF after 0.5 s | `+0  switch rtrim_plt L` |
| `sband_pm_ant` (S-BAND PM ANTENNA) | GPC / LL F / LL A / UL F / UL A / UR F / UR A / LR F / LR A (rests at GPC) | `+0  switch sband_pm_ant LL F` |
| `srb_sep_pb` (SRB SEP) | pushbutton, held 0.5 s | `+0  press srb_sep_pb` |
| `srb_sep_sw` (SRB SEPARATION) | MAN/AUTO / AUTO (rests at AUTO) | `+0  switch srb_sep_sw MAN/AUTO` |
| `ytrim_plt` (YAW TRIM) | L / OFF / R (rests at OFF); L/R spring back to OFF after 0.5 s | `+0  switch ytrim_plt L` |

### Window "O7"

| Control (caption) | Positions | Example |
|---|---|---|
| `tacan1` (TACAN 1 MODE) | OFF / RCV / T/R / GPC (rests at GPC) | `+0  switch tacan1 OFF` |
| `tacan2` (TACAN 2 MODE) | OFF / RCV / T/R / GPC (rests at GPC) | `+0  switch tacan2 OFF` |
| `tacan3` (TACAN 3 MODE) | OFF / RCV / T/R / GPC (rests at GPC) | `+0  switch tacan3 OFF` |

### Window "F2"

| Control (caption) | Positions | Example |
|---|---|---|
| `pitch_auto_cdr` (PITCH) | pushbutton, held 0.5 s | `+0  press pitch_auto_cdr` |
| `pitch_css_cdr` (PITCH) | pushbutton, held 0.5 s | `+0  press pitch_css_cdr` |
| `ry_auto_cdr` (ROLL/YAW) | pushbutton, held 0.5 s | `+0  press ry_auto_cdr` |
| `ry_css_cdr` (ROLL/YAW) | pushbutton, held 0.5 s | `+0  press ry_css_cdr` |

### Window "F4"

| Control (caption) | Positions | Example |
|---|---|---|
| `pitch_auto_plt` (PITCH) | pushbutton, held 0.5 s | `+0  press pitch_auto_plt` |
| `pitch_css_plt` (PITCH) | pushbutton, held 0.5 s | `+0  press pitch_css_plt` |
| `ry_auto_plt` (ROLL/YAW) | pushbutton, held 0.5 s | `+0  press ry_auto_plt` |
| `ry_css_plt` (ROLL/YAW) | pushbutton, held 0.5 s | `+0  press ry_css_plt` |

### Window "F6"

| Control (caption) | Positions | Example |
|---|---|---|
| `abort_mode` (ABORT MODE) | RTLS / OFF / ATO / TAL (rests at OFF) | `+0  switch abort_mode RTLS` |
| `abort_pb` (ABORT) | pushbutton, held 0.5 s | `+0  press abort_pb` |
| `air_data_cdr` (AIR DATA) | LEFT / NAV / RIGHT (rests at NAV) | `+0  switch air_data_cdr LEFT` |
| `hsi_mode_cdr` (HSI MODE) | ENTRY / TAEM / APPROACH (rests at ENTRY) | `+0  switch hsi_mode_cdr TAEM` |
| `hsi_source_cdr` (HSI SOURCE) | TACAN / NAV / MLS (rests at NAV) | `+0  switch hsi_source_cdr TACAN` |
| `hsi_unit_cdr` (HSI SOURCE) | 1 / 2 / 3 (rests at 1) | `+0  switch hsi_unit_cdr 2` |
| `rdr_altm_cdr` (RDR ALTM) | 1 / 2 (rests at 1) | `+0  switch rdr_altm_cdr 2` |

### Window "F8"

| Control (caption) | Positions | Example |
|---|---|---|
| `air_data_plt` (AIR DATA) | LEFT / NAV / RIGHT (rests at NAV) | `+0  switch air_data_plt LEFT` |
| `hsi_mode_plt` (HSI MODE) | ENTRY / TAEM / APPROACH (rests at ENTRY) | `+0  switch hsi_mode_plt TAEM` |
| `hsi_source_plt` (HSI SOURCE) | TACAN / NAV / MLS (rests at NAV) | `+0  switch hsi_source_plt TACAN` |
| `hsi_unit_plt` (HSI SOURCE) | 1 / 2 / 3 (rests at 1) | `+0  switch hsi_unit_plt 2` |
| `rdr_altm_plt` (RDR ALTM) | 1 / 2 (rests at 1) | `+0  switch rdr_altm_plt 2` |

### Window "L1"

| Control (caption) | Positions | Example |
|---|---|---|
| `freon_isol` (FREON ISOLATION MODE) | AUTO / MAN (rests at AUTO) | `+0  switch freon_isol MAN` |

### Window "L2"

| Control (caption) | Positions | Example |
|---|---|---|
| `bodyflap_cdr` (BODY FLAP) | UP / AUTO/OFF / DOWN (rests at AUTO/OFF); UP/DOWN spring back to AUTO/OFF after 0.5 s | `+0  switch bodyflap_cdr UP` |
| `entry_mode` (ENTRY MODE) | AUTO / LO GAIN / NO Y JET (rests at AUTO) | `+0  switch entry_mode LO GAIN` |
| `nws` (NOSE WHEEL STEERING) | 2 / 1 / OFF (rests at OFF) | `+0  switch nws 2` |
| `ptrim_cdr` (PITCH TRIM) | DOWN / OFF / UP (rests at OFF); DOWN/UP spring back to OFF after 0.5 s | `+0  switch ptrim_cdr DOWN` |
| `rtrim_cdr` (ROLL TRIM) | L / OFF / R (rests at OFF); L/R spring back to OFF after 0.5 s | `+0  switch rtrim_cdr L` |
| `ytrim_cdr` (YAW TRIM) | L / OFF / R (rests at OFF); L/R spring back to OFF after 0.5 s | `+0  switch ytrim_cdr L` |

### Window "L11U"

| Control (caption) | Positions | Example |
|---|---|---|
| `l11u_cb1` (CB1) | IN / OUT (rests at IN) | `+0  switch l11u_cb1 OUT` |
| `l11u_cb2` (CB2) | IN / OUT (rests at IN) | `+0  switch l11u_cb2 OUT` |
| `l11u_cb3` (CB3) | IN / OUT (rests at IN) | `+0  switch l11u_cb3 OUT` |
| `l11u_cb4` (CB4) | IN / OUT (rests at IN) | `+0  switch l11u_cb4 OUT` |
| `l11u_s1` (S1) | ON / OFF (rests at OFF) | `+0  switch l11u_s1 ON` |
| `l11u_s10` (S10) | ON / OFF (rests at OFF) | `+0  switch l11u_s10 ON` |
| `l11u_s11` (S11) | ON / OFF (rests at OFF) | `+0  switch l11u_s11 ON` |
| `l11u_s12` (S12) | ON / OFF (rests at OFF) | `+0  switch l11u_s12 ON` |
| `l11u_s13` (S13) | ON / OFF (rests at OFF) | `+0  switch l11u_s13 ON` |
| `l11u_s14` (S14) | ON / OFF (rests at OFF) | `+0  switch l11u_s14 ON` |
| `l11u_s15` (S15) | ON / OFF (rests at OFF) | `+0  switch l11u_s15 ON` |
| `l11u_s16` (S16) | ON / OFF (rests at OFF) | `+0  switch l11u_s16 ON` |
| `l11u_s17` (S17) | ON / OFF (rests at OFF) | `+0  switch l11u_s17 ON` |
| `l11u_s18` (S18) | ON / OFF (rests at OFF) | `+0  switch l11u_s18 ON` |
| `l11u_s19` (S19) | ON / OFF (rests at OFF) | `+0  switch l11u_s19 ON` |
| `l11u_s2` (S2) | ON / OFF (rests at OFF) | `+0  switch l11u_s2 ON` |
| `l11u_s20` (S20) | ON / OFF (rests at OFF) | `+0  switch l11u_s20 ON` |
| `l11u_s21` (S21) | ON / OFF (rests at OFF) | `+0  switch l11u_s21 ON` |
| `l11u_s22` (S22) | ON / OFF (rests at OFF) | `+0  switch l11u_s22 ON` |
| `l11u_s23` (S23) | ON / OFF (rests at OFF) | `+0  switch l11u_s23 ON` |
| `l11u_s24` (S24) | ON / OFF (rests at OFF) | `+0  switch l11u_s24 ON` |
| `l11u_s3` (S3) | ON / OFF (rests at OFF) | `+0  switch l11u_s3 ON` |
| `l11u_s4` (S4) | ON / OFF (rests at OFF) | `+0  switch l11u_s4 ON` |
| `l11u_s5` (S5) | ON / OFF (rests at OFF) | `+0  switch l11u_s5 ON` |
| `l11u_s6` (S6) | ON / OFF (rests at OFF) | `+0  switch l11u_s6 ON` |
| `l11u_s7` (S7) | ON / OFF (rests at OFF) | `+0  switch l11u_s7 ON` |
| `l11u_s8` (S8) | ON / OFF (rests at OFF) | `+0  switch l11u_s8 ON` |
| `l11u_s9` (S9) | ON / OFF (rests at OFF) | `+0  switch l11u_s9 ON` |

### Window "L12U"

| Control (caption) | Positions | Example |
|---|---|---|
| `l12u_cb1` (CB1) | IN / OUT (rests at IN) | `+0  switch l12u_cb1 OUT` |
| `l12u_cb2` (CB2) | IN / OUT (rests at IN) | `+0  switch l12u_cb2 OUT` |
| `l12u_cb3` (CB3) | IN / OUT (rests at IN) | `+0  switch l12u_cb3 OUT` |
| `l12u_cb4` (CB4) | IN / OUT (rests at IN) | `+0  switch l12u_cb4 OUT` |
| `l12u_s1` (S1) | ON / OFF (rests at OFF) | `+0  switch l12u_s1 ON` |
| `l12u_s10` (S10) | ON / OFF (rests at OFF) | `+0  switch l12u_s10 ON` |
| `l12u_s11` (S11) | ON / OFF (rests at OFF) | `+0  switch l12u_s11 ON` |
| `l12u_s12` (S12) | ON / OFF (rests at OFF) | `+0  switch l12u_s12 ON` |
| `l12u_s13` (S13) | ON / OFF (rests at OFF) | `+0  switch l12u_s13 ON` |
| `l12u_s14` (S14) | ON / OFF (rests at OFF) | `+0  switch l12u_s14 ON` |
| `l12u_s15` (S15) | ON / OFF (rests at OFF) | `+0  switch l12u_s15 ON` |
| `l12u_s16` (S16) | ON / OFF (rests at OFF) | `+0  switch l12u_s16 ON` |
| `l12u_s17` (S17) | ON / OFF (rests at OFF) | `+0  switch l12u_s17 ON` |
| `l12u_s18` (S18) | ON / OFF (rests at OFF) | `+0  switch l12u_s18 ON` |
| `l12u_s19` (S19) | ON / OFF (rests at OFF) | `+0  switch l12u_s19 ON` |
| `l12u_s2` (S2) | ON / OFF (rests at OFF) | `+0  switch l12u_s2 ON` |
| `l12u_s20` (S20) | ON / OFF (rests at OFF) | `+0  switch l12u_s20 ON` |
| `l12u_s21` (S21) | ON / OFF (rests at OFF) | `+0  switch l12u_s21 ON` |
| `l12u_s22` (S22) | ON / OFF (rests at OFF) | `+0  switch l12u_s22 ON` |
| `l12u_s23` (S23) | ON / OFF (rests at OFF) | `+0  switch l12u_s23 ON` |
| `l12u_s24` (S24) | ON / OFF (rests at OFF) | `+0  switch l12u_s24 ON` |
| `l12u_s3` (S3) | ON / OFF (rests at OFF) | `+0  switch l12u_s3 ON` |
| `l12u_s4` (S4) | ON / OFF (rests at OFF) | `+0  switch l12u_s4 ON` |
| `l12u_s5` (S5) | ON / OFF (rests at OFF) | `+0  switch l12u_s5 ON` |
| `l12u_s6` (S6) | ON / OFF (rests at OFF) | `+0  switch l12u_s6 ON` |
| `l12u_s7` (S7) | ON / OFF (rests at OFF) | `+0  switch l12u_s7 ON` |
| `l12u_s8` (S8) | ON / OFF (rests at OFF) | `+0  switch l12u_s8 ON` |
| `l12u_s9` (S9) | ON / OFF (rests at OFF) | `+0  switch l12u_s9 ON` |

### Window "L12L"

| Control (caption) | Positions | Example |
|---|---|---|
| `l12l_cb1` (CB1) | IN / OUT (rests at IN) | `+0  switch l12l_cb1 OUT` |
| `l12l_cb2` (CB2) | IN / OUT (rests at IN) | `+0  switch l12l_cb2 OUT` |
| `l12l_cb3` (CB3) | IN / OUT (rests at IN) | `+0  switch l12l_cb3 OUT` |
| `l12l_cb4` (CB4) | IN / OUT (rests at IN) | `+0  switch l12l_cb4 OUT` |
| `l12l_s1` (S1) | ON / OFF (rests at OFF) | `+0  switch l12l_s1 ON` |
| `l12l_s10` (S10) | ON / OFF (rests at OFF) | `+0  switch l12l_s10 ON` |
| `l12l_s11` (S11) | ON / OFF (rests at OFF) | `+0  switch l12l_s11 ON` |
| `l12l_s12` (S12) | ON / OFF (rests at OFF) | `+0  switch l12l_s12 ON` |
| `l12l_s13` (S13) | ON / OFF (rests at OFF) | `+0  switch l12l_s13 ON` |
| `l12l_s14` (S14) | ON / OFF (rests at OFF) | `+0  switch l12l_s14 ON` |
| `l12l_s15` (S15) | ON / OFF (rests at OFF) | `+0  switch l12l_s15 ON` |
| `l12l_s16` (S16) | ON / OFF (rests at OFF) | `+0  switch l12l_s16 ON` |
| `l12l_s17` (S17) | ON / OFF (rests at OFF) | `+0  switch l12l_s17 ON` |
| `l12l_s18` (S18) | ON / OFF (rests at OFF) | `+0  switch l12l_s18 ON` |
| `l12l_s19` (S19) | ON / OFF (rests at OFF) | `+0  switch l12l_s19 ON` |
| `l12l_s2` (S2) | ON / OFF (rests at OFF) | `+0  switch l12l_s2 ON` |
| `l12l_s20` (S20) | ON / OFF (rests at OFF) | `+0  switch l12l_s20 ON` |
| `l12l_s21` (S21) | ON / OFF (rests at OFF) | `+0  switch l12l_s21 ON` |
| `l12l_s22` (S22) | ON / OFF (rests at OFF) | `+0  switch l12l_s22 ON` |
| `l12l_s23` (S23) | ON / OFF (rests at OFF) | `+0  switch l12l_s23 ON` |
| `l12l_s24` (S24) | ON / OFF (rests at OFF) | `+0  switch l12l_s24 ON` |
| `l12l_s3` (S3) | ON / OFF (rests at OFF) | `+0  switch l12l_s3 ON` |
| `l12l_s4` (S4) | ON / OFF (rests at OFF) | `+0  switch l12l_s4 ON` |
| `l12l_s5` (S5) | ON / OFF (rests at OFF) | `+0  switch l12l_s5 ON` |
| `l12l_s6` (S6) | ON / OFF (rests at OFF) | `+0  switch l12l_s6 ON` |
| `l12l_s7` (S7) | ON / OFF (rests at OFF) | `+0  switch l12l_s7 ON` |
| `l12l_s8` (S8) | ON / OFF (rests at OFF) | `+0  switch l12l_s8 ON` |
| `l12l_s9` (S9) | ON / OFF (rests at OFF) | `+0  switch l12l_s9 ON` |

### Window "R2"

| Control (caption) | Positions | Example |
|---|---|---|
| `boiler_cntlr1` (BOILER CNTLR/HTR 1) | A / OFF / B (rests at OFF) | `+0  switch boiler_cntlr1 A` |
| `boiler_cntlr2` (BOILER CNTLR/HTR 2) | A / OFF / B (rests at OFF) | `+0  switch boiler_cntlr2 A` |
| `boiler_cntlr3` (BOILER CNTLR/HTR 3) | A / OFF / B (rests at OFF) | `+0  switch boiler_cntlr3 A` |
| `hyd_circ_pump1` (HYD CIRC PUMP 1) | ON / GPC / OFF (rests at GPC) | `+0  switch hyd_circ_pump1 ON` |
| `hyd_circ_pump2` (HYD CIRC PUMP 2) | ON / GPC / OFF (rests at GPC) | `+0  switch hyd_circ_pump2 ON` |
| `hyd_circ_pump3` (HYD CIRC PUMP 3) | ON / GPC / OFF (rests at GPC) | `+0  switch hyd_circ_pump3 ON` |
| `mps_dump_lh2` (BACKUP LH2 VLV) | OPEN / GPC / CLOSE (rests at GPC) | `+0  switch mps_dump_lh2 OPEN` |
| `mps_dump_seq` (MPS PRPLT DUMP SEQUENCE) | START / GPC / STOP (rests at GPC) | `+0  switch mps_dump_seq START` |

### Window "R11U"

| Control (caption) | Positions | Example |
|---|---|---|
| `fc_purge_htr` (PURGE HEATER) | GPC / OFF / ON (rests at GPC) | `+0  switch fc_purge_htr OFF` |
| `fc_purge_seq` (FUEL CELL GPC PURGE SEQ) | START / OFF (rests at OFF); START spring back to OFF after 0.5 s | `+0  switch fc_purge_seq START` |
| `fc_purge_vlv1` (PURGE VALVE 1) | OPEN / GPC / CLOSE (rests at GPC) | `+0  switch fc_purge_vlv1 OPEN` |
| `fc_purge_vlv2` (PURGE VALVE 2) | OPEN / GPC / CLOSE (rests at GPC) | `+0  switch fc_purge_vlv2 OPEN` |
| `fc_purge_vlv3` (PURGE VALVE 3) | OPEN / GPC / CLOSE (rests at GPC) | `+0  switch fc_purge_vlv3 OPEN` |

### Window "R13L"

| Control (caption) | Positions | Example |
|---|---|---|
| `plbd` (PAYLOAD BAY DOOR) | OPEN / STOP / CLOSE (rests at STOP) | `+0  switch plbd OPEN` |

### Window "A1R"

| Control (caption) | Positions | Example |
|---|---|---|
| `sband_fm_ant` (S-BAND FM ANTENNA) | UPPER / GPC / LOWER (rests at GPC) | `+0  switch sband_fm_ant UPPER` |

### Window "A1U"

| Control (caption) | Positions | Example |
|---|---|---|
| `ku_steering` (KU-BAND STEERING MODE) | GPC / GPC DESIG / AUTO TRACK / MAN SLEW (rests at GPC) | `+0  switch ku_steering GPC DESIG` |

### Window "A8U"

| Control (caption) | Positions | Example |
|---|---|---|
| `rms_auto_seq` (AUTO SEQ) | PROCEED / OFF / STOP (rests at OFF); PROCEED/STOP spring back to OFF after 0.5 s | `+0  switch rms_auto_seq PROCEED` |
| `rms_brakes` (BRAKES) | ON / OFF (rests at ON) | `+0  switch rms_brakes OFF` |
| `rms_drive` (SINGLE/DIRECT DRIVE) | + / OFF / - (rests at OFF); +/- spring back to OFF after 0.5 s | `+0  switch rms_drive +` |
| `rms_ee_man` (END EFF MAN CONTR) | RIGID / OFF / DERIGID (rests at OFF); RIGID/DERIGID spring back to OFF after 0.5 s | `+0  switch rms_ee_man RIGID` |
| `rms_ee_mode` (END EFF MODE) | AUTO / OFF / MAN (rests at OFF) | `+0  switch rms_ee_mode AUTO` |
| `rms_joint` (JOINT) | SHOULDER YAW / SHOULDER PITCH / ELBOW PITCH / WRIST PITCH / WRIST YAW / WRIST ROLL / EE TEMP / CRIT TEMP (rests at SHOULDER YAW) | `+0  switch rms_joint SHOULDER PITCH` |
| `rms_master_alarm` (MASTER) | pushbutton, held 0.5 s | `+0  press rms_master_alarm` |
| `rms_mode` (MODE) | TEST / AUTO 1 / AUTO 2 / AUTO 3 / AUTO 4 / OPR CMD / ORB UNL / END EFF / ORB LD / PL / SINGLE / DIRECT (rests at SINGLE) | `+0  switch rms_mode TEST` |
| `rms_mode_enter` (MODE) | pushbutton, held 0.5 s | `+0  press rms_mode_enter` |
| `rms_parameter` (PARAMETER) | TEST / POSITION / ATTITUDE / JOINT ANGLE / VELOCITY / RATE / PORT TEMP / STBD TEMP (rests at POSITION) | `+0  switch rms_parameter TEST` |
| `rms_rate` (RATE) | VERNIER / COARSE (rests at COARSE) | `+0  switch rms_rate VERNIER` |
| `rms_rate_hold` (RATE HOLD) | ON / OFF (rests at OFF) | `+0  switch rms_rate_hold ON` |
| `rms_safing` (SAFING) | SAFE / AUTO / CANCEL (rests at AUTO) | `+0  switch rms_safing SAFE` |
| `rms_shoulder_brace` (SHOULDER BRACE RELEASE) | PORT / OFF / STBD (rests at OFF) | `+0  switch rms_shoulder_brace PORT` |

### Window "A8L"

| Control (caption) | Positions | Example |
|---|---|---|
| `rms_power` (RMS POWER) | PRIMARY / OFF / BACKUP (rests at OFF) | `+0  switch rms_power PRIMARY` |
| `rms_select` (RMS SELECT) | PORT / OFF / STBD (rests at OFF) | `+0  switch rms_select PORT` |

---

## Keyboard windows "1", "2" and "3" (the DPS keyboards)

`keys` types on a keyboard, 0.35 s between keys by default (`keygap SECONDS`
on a line of its own changes that for later `keys` lines).  The next line
starts when the typing is done.

| Control | Command | Example | Notes |
|---|---|---|---|
| Any keyboard key | `keys [KB1\|KB2\|KB3] KEY ...` | `+0  keys KB1 SPEC 2 1 PRO` | KB1 (commander's, window "1") unless a `KBn` token says otherwise.  A `KBn` partway along a line switches the rest of the line.  KB3 is the aft keyboard, on IDP 4 / CRT 4. |
| ITEM entries | `keys ITEM N + VALUE ... EXEC` | `+0  keys ITEM 5 + 4 5 + 9 0 + 3 0 EXEC` | **Every digit is its own key**: `ITEM 1 8` is item 18; `ITEM 18` is an error.  One ITEM line fills consecutive items, each `+` or `-` starting the next.  A decimal point is the key `.`: `+ 5 0 . 0`. |
| The keys | | | ITEM EXEC OPS PRO SPEC RESUME CLEAR + - . 0-9 A-F FAULT_SUMM SYS_SUMM MSG_RESET ACK GPC/CRT I/O_RESET.  Names with a space on the keycap are written with `_`. |

A key reaches the IDP that keyboard is switched to (panel C2's IDP/CRT SEL,
`kybdsel`), and so the CRT that IDP drives.  KB1 starts on IDP 1, KB2 on
IDP 2.  An unpowered IDP ignores keys.

Four further names in `keys` are not keyboard keys.  They are the IDP POWER
and IDP LOAD messages that the panel switches send, and they go straight to
IDP 1, or to IDP 2 with the `2` forms:

| Message | Example | Notes |
|---|---|---|
| IDP LOAD | `+0  keys DEU_LOAD` | `DEU_LOAD2` for IDP 2.  The panel command `idpload N` is the usual way, and the only way for IDPs 3 and 4. |
| IDP POWER ON / OFF | `+0  keys IDP_POWER_ON` | `IDP_POWER_OFF`, `IDP2_POWER_ON`, `IDP2_POWER_OFF`.  `idppower N on\|off` is the usual way, and moves the switch on the panel too. |

---

## CRT windows "CRT1" to "CRT4" (MEDS2, the MDUs)

### Edgekeys

| Control | Command | Example | Notes |
|---|---|---|---|
| MDU edgekey 1-6 | `edgekey crtN K` | `+0  edgekey crt1 2` | K is the edgekey's position under the display, 1 = leftmost.  MEDS2 carries it out itself, as if the key had been clicked; the GPC is not involved. |

**What a position does depends on the menu currently on that MDU.**  The menu
is shown above the edgekeys.  A script that must work from any starting point
should go back to the MAIN menu first, by pressing 1 (UP) until it is there.
On the menus used most:

| Menu | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| MAIN MENU | (blank) | FLT INST | SUBSYS STATUS | DPS | MEDS MAINT | VIDEO |
| FLIGHT INSTRUMENT MENU | UP | A/E PFD | ORBIT PFD | DATA BUS | MEDS MSG RST | MEDS MSG ACK |
| DATA BUS SELECT MENU | UP | FC BUS 1 | FC BUS 2 | FC BUS 3 | FC BUS 4 | (blank) |
| SUBSYSTEM MENU | UP | OMS/MPS | HYD/APU | SPI | PORT SELECT | MEDS MSG ACK |
| DPS MENU | UP | (blank) | (blank) | (blank) | MEDS MSG RST | MEDS MSG ACK |
| MAINTENANCE MENU | UP | FAULT SUMM | CONFIG STATUS | CST | MEMORY MGMT | (blank) |

So the ORBIT PFD on CRT 3, from the MAIN menu, is:

```
+0  edgekey crt3 2
+1  edgekey crt3 3
```

and back to the DPS page, from the flight instrument menu:

```
+0  edgekey crt3 1
+1  edgekey crt3 4
```

* **The MDU's IDP must be powered** (`idppower N on`).  Without it the MDU
  shows "MDU IS AUTONOMOUS" and its menu has no FLT INST, so the positions
  above do not apply.  The IDP does not have to be loaded for the PFDs.
* A press on a blank position does nothing.
* The command reaches only a CRT that MEDS2 has a window for in this run
  (`simulatePASS.py --crts N`).

### Waiting on a CRT

These are not controls, but they are how a script follows what the displays
show: `wait crt N title TEXT [timeout S]` holds until TEXT appears in the top
two lines of CRT N, and `wait crt N new-screen [timeout S]` holds until the
page changes.  Example: `wait crt 1 title UNIV PTG timeout 60`.

---

## Hand-controller windows "THC FWD / RHC LH", "RHC RH" and "THC AFT / RHC AFT"

These are `handcontrollers.py`'s windows, one per station: the commander's
(the left RHC with the forward THC), the pilot's (the right RHC; there is no
THC there) and the aft station's.  A script command is carried out by the
window for its station, which deflects its own controller exactly as its
keys or a joystick would.  The window shows the deflection, and when the
command ends it returns to whatever the stick or keys are doing.

| Control | Command | Example | Notes |
|---|---|---|---|
| THC (forward / aft) | `thc fwd\|aft DIR SECONDS` | `+0  thc fwd +x 2` | Holds direction DIR (`+x -x +y -y +z -z`, orbiter axes, so `-z` is "up") for SECONDS, then releases it.  It is added to whatever the stick or keys hold, and both directions on one axis cancel. |
| RHC (left / right / aft) | `rhc lh\|rh\|aft AXIS FRACTION SECONDS` | `+0  rhc lh roll 0.5 3` | Deflects AXIS (`roll pitch yaw`) by FRACTION of full throw (-1 to 1) for SECONDS, then back to centre.  Full throw is 23.8 deg in roll, so 0.5 is about 12 deg of stick.  PASS's detent is at 0.072 of full throw in roll and pitch and 0.070 in yaw, and its softstop at 0.889 in roll and pitch and 0.822 in yaw.  So 0.1 is just out of detent, and 1 is past the softstop, hard against the stop.  It is added to the stick's own deflection. |

* **The window for that station must be running**: the manager's HAND
  CONTROLLERS buttons (CDR, PLT, Aft), or `simulatePASS.py --rhc lh|rh|aft`.
  If it is not, nothing moves, and the panel log says so
  ("... moved nothing -- no hand-controller window for that station is
  running") about half a second later.  The script carries on.
* `thc rh ...` is refused when the script is read: the pilot's station has no
  THC.
* What the controllers do depends on PASS.  In OPS 2 the orbit DAP takes RHC
  deflection only with the ORBITAL DAP in INRTL or LVLH (or with AUTO, which
  the RHC "downmodes" to INRTL), and THC translation only out of detent; see
  `crew-switches-OPS2.md`.  The aft controllers are transformed by the A6U
  SENSE switch (`sense -z|-x`).

---

## Window "Subtitles" (the caption box)

| Control | Command | Example | Notes |
|---|---|---|---|
| Caption text | `subtitle [TEXT]` | `+0  subtitle <left> GPC 1 loaded\nnow to RUN` | No TEXT clears the box.  `\n` (two characters) starts a new line, and a leading `<left>`, `<center>` or `<right>` aligns the caption.  TEXT cannot contain `#`, which starts a comment, except as a `#rrggbb` colour.  The caption box must be running (the manager's CAPTION BOX Start, or a `--layout` run). |

---

## Windows that cannot be scripted

| Window | What it has | Why not, and what to do instead |
|---|---|---|
| "O1" (`cam.py`, the CAM) | GPC lamps and failure buttons | Not wired to crew scripts.  O1's own controls, when they come, belong in `cam.py`. |
| "Manager" | SCRIPT, LAYOUT, SNAPSHOT, ... buttons | Not controls of the vehicle.  The SNAPSHOT **Save** button's script equivalent is `snapshot DIR` (see `crewscript.py --help`). |
| "Truth ADI" (`truthball.py`) | a display only | Nothing to operate. |
| Panel F7 | caution and warning lights | Only lights: every F7 entry in `panelcontrols.py` is an annunciator. |
