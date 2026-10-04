# Star tracker emulation: plan

**Status: DONE (phases 1-3), merged.** The device is `src/startrk.c` (its
header comment is the current description), first committed as 1dcdf8fc4,
followed by the O6 panel commit.  Verified live:
- both trackers show ST PASS on SPEC 22;
- the S TABLE fills and ALIGN ENA appears;
- a star alignment brings the platforms to within 0.017° of M50.

One departure from the interface below: threshold code 0 accepts the whole
catalog (to IDT magnitude 3.5), not the documented 3.0, because 21 catalog
stars are fainter than 3.0.  The COAS remains a separate, later item: it needs
a visual sky with non-catalog stars.  What follows is the plan as written.

Written 2026-10-03.  Prerequisite: IMU alignment torquing (branch
`review/imu-alignment`), without which a star alignment would leave PASS's
attitude wrong (GMMLAT/GX4 assume the platform moved as commanded).

## Why

In an OPS 202 census run PASS reads `FIOFFIC5` (STU, FF card 3 ch 2, 3
words) every 160 ms and today gets all zeros: SPEC 22 shows BITE, self-test
ends NO TARGET, star track never sees a star, and no star-tracker IMU
alignment is possible.  Every other GNC device PASS reads in OPS 2 is modelled
except the rendezvous radar, TACAN/RA (unused on orbit) and hydraulic
pressure.

## Interface (sources: FSSR STS 83-0014V2-34 "Star Tracker SOP"; flight source)

| | -Z tracker (ST1) | -Y tracker (ST2) |
|---|---|---|
| MDM | FF1 | FF3 |
| read | `0x24C42`, 3 words, 6.25 Hz, buffer TFIVMI16 (`CGBV_STU$(1)`) | same, TFIVMI36 (`CGBV_STU$(2)`) |
| command | `0x20C40`, 1 word, 6.25 Hz HFE (GEIORB.hal:194) | same |
| mounting | `CGYS_TNBST$(1)` (I-load, in memory) | `CGYS_TNBST$(2)` |

FSSR bit 0 = MSB.

- **Word 1:** b0 tracker good, b1 target suppressed, b2 transmission word
  good, b3 shutter closed, b4 self-test engaged, **b5 star present**, b6 = 1,
  b7 = 0, b8-15 intensity (unused by PASS).
- **Word 2:** H, a 12-bit two's-complement field in bits 0-11 (LSB
  0.0025390625 deg); b12 bit-count error, b13 Manchester invalid, b14 parity
  error, b15 pressurisation fail.
- **Word 3:** V likewise; b12 self-test angle error, b13 self-test magnitude
  error, **b14 power supply good**, **b15 bright-object alert OFF**.
- **Command word:** b0 offset scan, b1 self-test, b2 break track (edge 0->1),
  b3 shutter manual open, b4-5 threshold (0 = mag 3.0, 1 = 2.4, 2 = 2.0,
  3 = 1.0), b6-10 H offset code, b11-15 V offset code, where an offset is
  (n - 15.5) x 0.306452 deg.  Offset 0 with b0 clear is a full-field scan.

Geometry PASS inverts (GY5FOV, GY8DAT): v_ST = TNBST . v_navbase, H =
atan2(v2, v3), V = atan2(-v1, v3); the field of view is +-4.5 deg per axis in
software and a 10 deg square in hardware.

## Phase 1: the device (`src/mdmdev.c`, one new section)

1. **Sky.**
   - The two onboard catalogs, read from this tape's memory: `CGYV_2_3_STAR_TABLE`
     (IDs 11-60) and the 2/8 catalog (61-110), M50 unit vectors at epoch 2005.
     Using PASS's own vectors removes catalog error from the comparison, which
     is right for a first model.
   - Magnitudes for the threshold logic: IDs 11-60 from FPH JSC-12842 Table
     A-I.  IDs 61-110 from the 1978 catalog (JSC-14292 Table II, 149 stars),
     matched by direction; verify every match.
   - A generated table `src/startable.h`, with its generator in `tools/`.
2. **Truth line of sight.**
   - Truth attitude R(q) (not the IMU's), body to nav base through TNBBODY, then
     TNBST.
   - Add the aberration PASS removes (GY8DAT:466-470): the Earth's orbital
     velocity term (from the GMT) plus the vehicle's own velocity over c.
   - This is what makes star sightings measure the IMU's misalignment.
3. **Hardware state machine**, per tracker, on vehicle time:
   - **Full-field scan:** after 2-10 s (the raster), lock the brightest
     catalog star within the 10 deg square above threshold.
   - **Offset scan:** the 1 deg box around the commanded H/V; acquire within
     about 1 s.
   - **Track:** report H/V every read with about 10 arcsec 1-sigma noise,
     well inside TOL6 (0.15 deg) and TOL12 (0.095 deg over 3.2 s).  Lose lock
     above 0.5 deg/s body rate or when the star leaves the field.
   - **Break track:** drop the star on the 0->1 edge and exclude it from the
     next search.
   - **Self-test:** an LED star at H +4.137, V -4.137, with shutter closed,
     self-test engaged and star present.  The second pass, with H polarity
     reversed, gives tracker good = 0, as the FSSR requires.
   - **Shutter (bright-object sensor):**
     - Sun within 23 deg closes it, reopening at 29 deg.
     - The lit Earth limb within 16 deg closes it, reopening at 19 deg.
     - Manual open overrides both.
     - The Sun comes from a low-precision almanac on the GMT, and the Earth
       limb from the truth position.
4. **Command decode** in `mdmdev_output` for `0x20C40` on FF1/FF3, before the
   generic discrete path, which today stores it as a discrete.
5. **Capture/restore:** tracker modes, locked star, timers and shutter, in
   `vehdyn.json`, as for the IMUs and GPS.
6. **Unit tests** (`test/test_mdmdev.c`):
   - For random attitudes, PASS's GY8DAT decode of our words gives the true
     LOS to 1 LSB.
   - The command-code round trip.
   - The self-test sequence passes as GY1STS checks it.
   - Shutter angles.
   - Capture round trip.

## Phase 2: verification with PASS flying (OPS 201 or 202 capture, 1 GPC, vehdyn)

1. SPEC 22 items 1 and 2: both trackers show ST PASS, with no BITE.
2. REQD ID 0, items 3 and 4:
   - both trackers acquire catalog stars within 3 min;
   - S TABLE ERR under 0.08 deg;
   - SEL marks a pair, and ALIGN ENA appears on SPEC 21.
3. With `YAGPC_IMU_DRIFT` set:
   - SPEC 21's star-align torquing angles must equal the misalignment the model
     knows it introduced, within about 0.01 deg per axis;
   - EXEC must leave every platform within about 0.01 deg of M50 (compared
     from a capture against PASS's TCM50 with `pasvar`, as for the IMU/IMU
     check).
4. Re-check at a second attitude with new stars: under 0.1 deg (the flight
   rule).
5. A bright-object case: point a boresight near the Sun and see the shutter
   close (SHUTTER CL) and the track lost.

## Phase 3: crew panel (O6 STAR TRACKER group; hardwired, not GPC-commanded)

- **POWER -Y/-Z** (S4/S5):
  - Off gives all-zero words, so BITE.
  - On starts a 15 min warm-up, during which tracker good = 0.
  - PASS sees power only as data, since there is no commfault path today.
- **DOOR CONTROL SYS 1/SYS 2** (OPEN/OFF/CLOSE):
  - Door travel is 6 s with both systems, 12 s with one, and opening needs power.
  - The DOOR POSITION talkbacks go OP / CL / barberpole.
  - A closed door means no stars.
  - The -Y door's OP/CL contacts go to FF card 12 ch 2 bits 13/14 (downlist
    only).  The -Z door state needs a private panel-to-model channel.
- Scriptable verbs for each control, and an entry in `SCRIPTABLE_CONTROLS.md`.

## Decisions (the user's, 2026-10-03)

1. **Phase 3 scope: model the controls now.** These are the O6 STAR TRACKER
   POWER -Y/-Z and DOOR CONTROL SYS1/SYS2 switches and the DOOR POSITION
   talkbacks.  Checklists must be followable exactly.  Power off gates the
   tracker's signals (BITE, no data); a closed door blacks out the star field.
2. **Sky content: the onboard catalog stars only.** The trackers are
   automatic.  The user's point about "other stars" concerned the COAS, which
   a crew member looks through; that is a separate, later item needing a real
   visual sky.
3. **Bright-object shutter: modelled.** Sun 23/29°, lit horizon 16/19°.

## Known gaps carried forward

- Intensity counts versus magnitude are not documented (PASS does not use
  them).
- The self-test latch-clear time is not documented.
- The hardware configuration (image dissector or solid-state) per vehicle;
  the image-dissector bits are modelled.
- Target track (rendezvous) needs a target vehicle, which does not exist yet.
