# Crew switches PASS reads in OPS 2

The crew-panel switches, pushbuttons and hand-controller contacts that the
PASS flight software reads as MDM discrete inputs in OPS 2 (on-orbit GNC), with
OPS 8 additions noted. For each one this gives the function, panel, positions
and contacts, the MDM word and bit, the redundancy, and the validity rule PASS
applies. The point is to say which controls a simulated panel must provide,
and what PASS expects of each, while the real panels' appearance is being
researched.

**Provenance.** This was extracted on 2026-09-30 from the OI-34.06 flight
source. OI-34.07 overrides none of the files used. Paths are under
`~/workspace/PFS/OI340600/APPLSRC/`. Supporting documents are in
`~/Desktop/sandroid.org/public_html/apollo/Shuttle/`:

- "FSSR RM" is `sts83-0010-34 - Redundancy Management.pdf`, including its
  MSID list.
- "SCOM" is the Shuttle Crew Operations Manual (OI-28).

Every row is cited. Panel locations marked *(inferred)* were not confirmed
from a document. The key citations were spot-checked against the source:
GCQORB's OPS 2 panel initialisation, GR2ORB's sense-switch inputs, and
GDPSWP's switch-field validity rule.

**Conventions.**

- HAL/S bit 1 is the most significant, so bit *n* of a 16-bit word is mask
  `0x8000 >> (n-1)`.
- "FF*k* DSCRT*n*" is `CGBB_HFF_SEG2_DSCRTn$(k;)`, the *n*th discrete word of
  forward MDM *k*.

The words come from these cards (CGBIH1.hal:555-575, 2441-2446, 2591, 2694,
2886):

| Words | Card and channels |
|---|---|
| DSCRT1/2/3 | DIH card 4, channels 0/1/2 |
| DSCRT4/5 | DIL card 6, channels 0/1 |
| DSCRT6/7/8 | DIH card 9, channels 0/1/2 |
| DSCRT9/10/11 | DIH card 12, channels 0/1/2 |
| DSCRT12/13 | DIL card 15, channels 0/1 |

**Which names to trust.** The bit names in CGBIH1's `REPLACE` statements are
pre-CR89921 legacy names. For example, DSCRT7 bit 14 is named `TRANS_X_HIGH`
but is LVLH. The function names here come from GPZORB.hal:121-151 and the FSSR
MSID list. The `C M=... N=CGBB_...$(k;)` comment lines in CGBIH1 are not in
bit order and must not be used to assign bits.

---

## Minimum set to fly the orbit DAP in AUTO (UNIV PTG)

1. **No pushbutton needs to be pressed.** On entering OPS 2 from OPS 0, or from
   G1/G3, PASS sets the DAP panel word itself (GCQORB.hal:887-888, 1613-1624):
   DAP A, RCS AUTO, discrete rotation, pulse translation, primary jets.
   - This happens on the `CGCB_OFC_RESTART` path (GCQORB:1061-1073).
   - A G8→G2 transition or a mass-memory recall keeps the mode carried in the
     MFB instead (GCQORB:1121-1166).
2. **Every DAP pushbutton and THC contact must read 0 at rest.**
   - Pushbuttons act only on a leading edge (GCQORB:1018-1025).
   - The "previous" word is cleared at initialisation (GCQORB:1189, 1630), so a
     contact stuck at 1 fires once on the second pass. A stuck INRTL would
     downmode AUTO.
   - Any THC deflection blocks translation options and cancels reboost
     (GCQORB:1037-1047).
3. **The rotational hand controllers must be in detent.** RHCs are analog (see
   [Other paths](#other-paths)). An RHC out of detent forces INRTL whenever AUTO
   is active (GCQORB:1743-1753).
4. **To get AUTO back after a downmode,** pulse **FWD DAP AUTO**:
   - Contacts: FF1 DSCRT6 `0x0080`, FF2 DSCRT6 `0x0080`, FF3 DSCRT6 `0x0020`.
   - At least two of the three must be set.
   - Hold it for at least two GR2 cycles (6.25 Hz, so 0.32 s or more), then
     release.
5. **SENSE and the ADI switches are not needed for AUTO.** They are needed to
   clear their fault messages; see the next section.

UNIV PTG itself is driven from the keyboard, by item entries, not by switches.

---

## Currently faulting: SENSE SW and DISPLAY SW L/R/A

Both appear at every OPS 2 transition in the simulator today (ledger #262),
because nothing drives these contacts and all-zero is invalid.

### SENSE SW: aft sense switch, −X / −Z (panel A6U)

**Logic** (GR2ORB.hal:418-446):

- The vote outputs are `CGRB_ORB_TRIPLE_SLOW_OUT` bit 17 (−Z, `0x00008000`) and
  bit 18 (−X, `0x00004000`).
- Both 0, or both 1, is invalid.
- For the first three invalid cycles PASS holds the last valid value. After
  that it defaults to **−Z** and sets `CGEB_FLT_LG2_FLAG1_HFE$(15)`.
- That flag raises the **SENSE SW** message (CGA2MC.hal:1809-1815, mask
  `0x0002`). It clears on the first valid pass (GR2ORB:441-444).
- The initial "past" value is −Z (GR2ORB:104-105).
- Consumers read `CGRB_SENS_SW`, which is bit 18; OFF means −Z
  (CGRRMC.hal:1769-1772).

**Contacts.** Each position has three contacts, voted 2-of-3 (DSCRT7,
CGBIH1:2626-2629; vote assembled at GR2ORB:218, 228, 238):

| Position | Contacts A / B / C | Mask | MSIDs |
|---|---|---|---|
| −Z (overhead line of sight) | FF1 / FF2 / FF3 DSCRT7 bit 2 | `0x4000` | V72K5175X / 5176X / 5177X |
| −X (aft-window line of sight) | FF1 / FF2 / FF3 DSCRT7 bit 3 | `0x2000` | V72K5180X / 5181X / 5182X |

The switch is on panel A6U (SCOM Part 2, around line 18815-18860). With −Z
selected, the aft THC and the aft roll/yaw pushbuttons are transformed
(GP0THC.hal:58-60, GPZORB:209-253).

### DISPLAY SW L / R / A: ADI switches (panels F6 = CDR, F8 = PLT, A6U = aft)

**Logic** (GDPSWP.hal:61-125, the orbit simplex switch processor, about 1 Hz):

- It reads `CGBB_MFF_SEG2_DSCRT2$(X;)` for X = 1 (CDR), 2 (PLT) and 3 (aft).
  This is FF DSCRT2, sampled at the MFE rate (CGBIM1.hal:199-217).
- Each word holds three 3-bit fields, one per switch.
- A field is valid only as `100`, `010` or `001`. All-zero and multi-bit
  patterns are invalid (GDPSWP:107-120).
- After three consecutive invalid passes, or at once on a commfault of that
  MDM (l.66-68, 101-106), the output defaults to value 2 and a bit is set in
  `CGDB_VALIDITY_FLAGS1` (l.93).

The validity-flag bits are laid out as follows:

| Bits | Switch |
|---|---|
| 1–3 | rate, L / R / A |
| 4–6 | error, L / R / A |
| 7–9 | attitude, L / R / A |

The messages test that word with these masks (CGA2MC.hal:1746-1780):

| Message | Mask on `CGDB_VALIDITY_FLAGS1` |
|---|---|
| DISPLAY SW L | `0x9210` |
| DISPLAY SW R | `0x4908` |
| DISPLAY SW A | `0x2480` |

`CGDB_VALIDITY_FLAGS2` is written only in OPS 1/3/6 (GDSSWP.hal:175-176).

These are the switches. Each has three positions, read simplex (one contact per
position) from DSCRT2 of FF1, FF2 and FF3 for L, R and A (CGBIH1:2486-2503):

| Switch | Positions (bit, mask) | Value | Default | MSIDs L / R / A |
|---|---|---|---|---|
| ATTITUDE | INRTL b1 `0x8000`, LVLH b2 `0x4000`, REF b3 `0x2000` | 1 / 2 / 3 | LVLH | V72K2015-2017X / 2065-2067X / 2101-2103X |
| RATE | HIGH b4 `0x1000`, MED b5 `0x0800`, LOW b6 `0x0400` | 1 / 2 / 3 | MED | 2008-2011 / 2060-2062 / 2093-2095 |
| ERROR | HIGH b7 `0x0200`, MED b8 `0x0100`, LOW b9 `0x0080` | 1 / 2 / 3 | MED | 8504-8506 / 8604-8606 / 2097-2099 |

The defaults are confirmed by FSSR RM Table 4.12-4.

**ADI ATT REF pushbutton.** This is a dual-contact pushbutton, and both
contacts are on the same MDM:

- LH pushbutton on FF1, RH on FF2, aft on FF3.
- Contact A is DSCRT11 bit 7, `0x0200`; contact B is bit 8, `0x0100`
  (CGBIH1:2853-2866; GR2ORB:344-351).
- MSIDs: LH V72K2051/2052X, RH 2001/2002, aft 2091/2092.
- Forward station select is LH OR RH, which goes to
  `CGRB_FWD_ATT_REF_PB_HFE` and on to GNZATT. The aft pushbutton goes to
  `CGRB_AFT_ATT_REF_PB_HFE` (GR2ORB:453-462).
- Its panel is next to the ADI switches *(inferred)*.

---

## How PASS processes these inputs

**When.** GR2 (`GR2_ORB_SWITCHES`) runs in OPS 2 and 8 at 6.25 Hz
(GR2ORB.hal:91-94). GR3, called from GR4, filters the THC contacts again, at
12.5 Hz (GR4ORB:315-327).

**Selection filter** (GR2ORB:262-312, 371-390; FSSR RM Table 4.12-2).
"Available" means the contact is neither commfaulted nor RM-failed.

| Contacts available | Triple switch | Dual switch |
|---|---|---|
| 3 | 2-of-3 vote | — |
| 2 | AND of the two | AND of the two |
| 1 | that contact | that contact |
| 0 | output 0 | output 0 |

A commfaulted MDM's contacts are masked out, bit by bit (GR2ORB:116-181).

**Fault detection** (GR4ORB:90-269):

- A triple contact that disagrees with the vote for three consecutive passes
  is declared failed. Only the first failure is handled this way.
- A further miscompare is a dilemma.
- A dual miscompare lasting three passes is also a dilemma.
- Dilemmas clear when 0, 1 or 3 contacts are available (GR2ORB:316-324,
  394-400).

**Messages from switch RM in OPS 2:**

- THC failures raise SBTC/THC L (forward, mask `0xFC00`) and SBTC/THC A (aft,
  `0x003F`) (CGA2MC:1228-1269).
- THC dilemmas raise the same messages through `CGAV_THC_DISAGREE`
  (CGA2MC:1697-1710; GABDIR.hal:241).
- No OPS 2 message was found for dilemmas on the DAP pushbuttons, the ATT REF
  pushbutton, the OMS ENG switches or the FCS CH switches. Their status goes
  only to the downlist and to `CGRB_SW_DIL` / `CGRB_SW_SF` (GR4ORB:277-312).

---

## A. Translational hand controllers, forward and aft

Each axis has three contacts per direction, voted 2-of-3.

- Fast triple bits 1-6 are the forward THC; bits 11-16 are the aft THC
  (GR2ORB:188-210; CGRRMO.hal:83-94).
- Contacts A / B / C come from FF1 / FF2 / FF3.
  - Forward THC: DSCRT4 bits 8-13 (CGBIH1:2567-2578).
  - Aft THC: DSCRT12 bits 8-13 (CGBIH1:2902-2913).
- **Validity:** + and − on the same axis at once zeroes all three axes of that
  THC (GR0ORB.hal:67-104).
- With −Z sense selected, the aft THC is transformed (GP0THC.hal:58-60).
- The aft THC is active on orbit only (SCOM Part 2, around line 18800). The
  forward THC is at the CDR station; its exact panel is *(inferred)*.

| Axis | Bit / mask | Forward MSIDs A / B / C | Aft MSIDs A / B / C |
|---|---|---|---|
| +X | 8 / `0x0100` | V72K1315X / 1335X / 1355X | V72K1435X / 1451X / 1475X |
| −X | 9 / `0x0080` | 1316 / 1336 / 1356 | 1436 / 1455 / 1476 |
| +Y | 10 / `0x0040` | 1320 / 1340 / 1360 | 1440 / 1460 / 1480 |
| −Y | 11 / `0x0020` | 1321 / 1341 / 1361 | 1441 / 1461 / 1481 |
| +Z | 12 / `0x0010` | 1325 / 1345 / 1365 | 1445 / 1465 / 1485 |
| −Z | 13 / `0x0008` | 1326 / 1346 / 1366 | 1446 / 1466 / 1486 |

---

## B. Orbital DAP pushbuttons with three contacts (forward panel C3, aft panel A6U)

The panels are given in SCOM Part 2, around lines 20252 and 20600-20663.

- Fast triple bit positions (GPZORB:128-145; GR2ORB:188-210):

  | Station | DAP A | DAP B | AUTO | INRTL | LVLH | FREE DRIFT |
  |---|---|---|---|---|---|---|
  | Forward | 7 | 8 | 9 | 10 | 27 | 28 |
  | Aft | 17 | 18 | 19 | 20 | 25 | 26 |

- Contact C sits on a *different bit* of the third MDM from contacts A and B.
- Each pushbutton is an independent momentary contact; there is no
  "exactly one" rule. The forward and aft results are ORed (GPZORB:167-208,
  267), and DAP processing acts on leading edges.

In the table below, "FF1, FF2 DSCRT6 bit 5" means contacts A and B are both
bit 5 of DSCRT6, on FF1 and FF2 respectively.

| Pushbutton | Forward contacts A, B / C (MSIDs) | Aft contacts A, B / C (MSIDs) |
|---|---|---|
| DAP SELECT A | FF1, FF2 DSCRT6 bit 5 `0x0800`; FF3 DSCRT6 bit 7 `0x0200` (V72K2801/2802/2805X) | FF3, FF4 DSCRT6 bit 5; FF1 DSCRT6 bit 7 (V72K6430/6431/6419X) |
| DAP SELECT B | FF1, FF2 bit 6 `0x0400`; FF3 bit 8 `0x0100` (2803/2804/2806) | FF3, FF4 bit 6; FF1 bit 8 (6432/6433/6420) |
| **AUTO** | FF1, FF2 bit 9 `0x0080`; FF3 bit 11 `0x0020` (2840/2841/2842) | FF3, FF4 bit 9; FF1 bit 11 (6490/6491/6492) |
| MAN INRTL (HOLD) | FF1, FF2 bit 10 `0x0040`; FF3 bit 12 `0x0010` (2845/2846/2847) | FF3, FF4 bit 10; FF1 bit 12 (6495/6496/6497) |
| MAN LVLH | FF1, FF2 DSCRT7 bit 14 `0x0004`; FF3 DSCRT11 bit 15 `0x0002` (2864/2865/2895) | FF3, FF4 DSCRT7 bit 14; FF1 DSCRT11 bit 15 (6517/6518/6415) |
| FREE DRIFT | FF1, FF2 DSCRT7 bit 15 `0x0002`; FF3 DSCRT11 bit 16 `0x0001` (2892/2893/2894) | FF3, FF4 DSCRT7 bit 15; FF1 DSCRT11 bit 16 (6412/6413/6414) |

---

## C. Orbital DAP pushbuttons with two contacts (same panels)

- Forward: contact A on FF1, contact B on FF2. Aft: A on FF3, B on FF4.
- They use DSCRT7 bits 5-16 and DSCRT8 bits 1-8 (GR2ORB:332-353; dual bit map
  GPZORB:132-151).
- The two contacts are ANDed. A miscompare lasting three passes is a dilemma,
  with no message.
- With −Z sense selected, the aft roll and yaw DISC/PULSE pushbuttons and their
  lamps are swapped (GPZORB:209-253).

| Pushbutton | Word, bit / mask | Forward MSIDs A / B | Aft MSIDs A / B |
|---|---|---|---|
| RCS JETS NORM (PRI) | DSCRT7 b5 `0x0800` | V72K2851 / 2852 | V72K6505 / 6506 |
| ROLL DISC RATE | DSCRT7 b6 `0x0400` | 2812 / 2813 | 6440 / 6441 |
| ROLL PULSE | DSCRT7 b7 `0x0200` | 2816 / 2817 | 6448 / 6449 |
| ALT (PRCS) | DSCRT7 b8 `0x0100` | 2890 / 2891 | 6410 / 6411 |
| PITCH DISC RATE | DSCRT7 b9 `0x0080` | 2822 / 2823 | 6460 / 6461 |
| PITCH PULSE | DSCRT7 b10 `0x0040` | 2826 / 2827 | 6468 / 6469 |
| VERN | DSCRT7 b11 `0x0020` | 2853 / 2854 | 6507 / 6508 |
| YAW DISC RATE | DSCRT7 b12 `0x0010` | 2832 / 2833 | 6480 / 6481 |
| YAW PULSE | DSCRT7 b13 `0x0008` | 2836 / 2837 | 6488 / 6489 |
| TRANS X NORM | DSCRT7 b16 `0x0001` | 2860 / 2861 | 6510 / 6511 |
| TRANS X PULSE | DSCRT8 b1 `0x8000` | 2862 / 2863 | 6513 / 6514 |
| (spare) | DSCRT8 b2 `0x4000` | 2898 / 2899 | 6400 / 6401 |
| TRANS Y NORM | DSCRT8 b3 `0x2000` | 2870 / 2871 | 6520 / 6521 |
| TRANS Y PULSE | DSCRT8 b4 `0x1000` | 2872 / 2873 | 6523 / 6524 |
| LOW Z | DSCRT8 b5 `0x0800` | 2874 / 2875 | 6527 / 6528 |
| TRANS Z NORM | DSCRT8 b6 `0x0400` | 2880 / 2881 | 6530 / 6531 |
| TRANS Z PULSE | DSCRT8 b7 `0x0200` | 2882 / 2883 | 6533 / 6534 |
| TRANS Z HIGH | DSCRT8 b8 `0x0100` | 2884 / 2885 | 6537 / 6538 |

---

## D. Other switches GR2 reads in OPS 2 and 8 (not needed by the RCS DAP)

**FCS CHANNEL 1-4,** OVERRIDE contact (panel C3; SCOM Part 2, around line
19724).

- Three contacts each, voted 2-of-3, as slow triple bits 13-16
  (GR2ORB:216-236). In the table, b1 is `0x8000` and b2 is `0x4000`.

  | Channel | Contact A | Contact B | Contact C | MSIDs |
  |---|---|---|---|---|
  | CH1 | FF2 DSCRT9 b1 | FF1 DSCRT9 b1 | FF3 DSCRT1 b2 | V72K3170/3171/3172X |
  | CH2 | FF2 DSCRT1 b1 | FF3 DSCRT1 b1 | FF4 DSCRT1 b2 | 3176/3178/3179 |
  | CH3 | FF4 DSCRT1 b1 | FF1 DSCRT1 b1 | FF2 DSCRT1 b2 | 3180/3182/3183 |
  | CH4 | FF4 DSCRT9 b1 | FF3 DSCRT9 b1 | FF1 DSCRT1 b2 | 3186/3188/3189 |

- Used by `CGRB_SW_SEL(1:6-9)` (GR2ORB:475). In OPS 8 they also drive
  actuator reset (VXCDCSWI.hal:49-94).

**RCS MASTER CROSSFEED,** FROM LEFT / FROM RIGHT (panel not found).

- FF1/2/3 DSCRT11 b2 `0x4000` for FROM LEFT and b3 `0x2000` for FROM RIGHT
  (V72K4510-4512X, 4515-4517X).
- Both on means hold the last valid value (GR2ORB:407-416; FSSR Table 4.12-4).

**AUTO/MAN pushbuttons.** Three contacts each, slow triple bits 22, 23 and 8
(GR2ORB:216-240, 478-480). Their panels, F2 (CDR) and F4 (PLT), are
*(inferred)*.

| Pushbutton | Contacts | MSIDs |
|---|---|---|
| LH BODY FLAP AUTO/MAN | FF1/2/3 DSCRT2 b16 `0x0001` | V72K4993-4995X |
| LH SPD BK/THROT AUTO/MAN | FF1/2/3 DSCRT3 b1 `0x8000` | V72K1570-1572X |
| RH SPD BK/THROT AUTO/MAN | FF2/3/4 DSCRT11 b1 `0x8000` | V72K1600-1602X |

On docking flights these three pushbuttons are reused as post-contact-thrusting
arm and disarm (the speed-brake pushbuttons) and activate (the body-flap
pushbutton) (GC1ORB.hal:140-142, 209-262).

**LH / RH TRIM RHC INHIBIT** (panel F3, TRIM RHC/PANEL; SCOM Part 2, around
line 19223).

- Two contacts each.
- LH: FF1/FF2 DSCRT10 b9 `0x0080` (V72K1160/1161X). RH: FF3/FF4 DSCRT10 b9
  (1210/1211).
- GR2ORB:352-353, 486-487.

**OMS ENG L / R,** ARM/PRESS, ARM, OFF (panel C3).

- Two contacts each, on the aft MDMs.
- L: FA3/FA1 DSCRT2 b7 `0x0200` for ARM/PRESS and b8 `0x0100` for ARM.
  R: FA4/FA2, same bits (CGBIH1:2167-2174).
- OFF is neither contact.
- GR2ORB:333-340, 452. FA DSCRT2 is DIH card 3, channel 1 (CGBIH1:2126-2130).

---

## Other paths

- **Rotational hand controllers are analog, not discrete.**
  - They come in on FF AID channels: `CGBV_HFF_SEG4` (LH, and the aft roll
    axis on FF1/FF4/FF3) and `SEG5` (RH) (CGBIH1:2962-2984).
  - PASS works out detent and softstop itself (GP2ORB.hal:131-340).
  - The aft RHC is transformed by the sense switch (GP2ORB:289).
  - Faults raise the RHC L/R/A and DAP DNMODE RHC messages.
- **The keyboard and CRT** carry UNIV PTG, DAP CONFIG and SPEC 25 RM ORBIT.
  In OPS 8, the RM SWITCHES display's deselect and reselect are in
  GKWRMS.hal.
- **OPS 8 additions:**
  - FCS CH override contacts for actuator reset (VXCDCSWI.hal).
  - Nose-wheel-steering switches, used for display only (VNSNWSCY.hal:85-90):
    FF2 DSCRT1 b13, FF3 DSCRT10 b2, FF1 DSCRT11 b1, FF2 DSCRT11 b14,
    FF3 DSCRT9 b16, FF4 DSCRT11 b2.
- **No OPS 2 GNC crew switch** was found that is read through a GPC's own
  discrete-input registers.

---

## The simulator today

`yaGPC2/src/mdmdev.c` (`YAGPC_MDM_DEVICES`) answers these words with every
switch contact at 0. That is correct for the DAP pushbuttons and THCs at rest,
and it is why SENSE SW and DISPLAY SW fault. The bits the device model does set
in the same words are listed below, checked against this list for overlap:

| Word | Bits set | Meaning | Mask |
|---|---|---|---|
| DSCRT1 and DSCRT9 | bit 8 | RCS manifold open | `0x0100` |
| DSCRT1 and DSCRT9, FF3 only | bit 12 | manifold 5 open | `0x0010` |
| DSCRT4 | bits 1-4 | chamber pressure | `0xF000` |
| DSCRT6 | bits 1-4 | jet driver output | `0xF000` |
| DSCRT12 | bits 1-6 | IMU discretes | `0xFC00` |

None of them is a switch contact.
