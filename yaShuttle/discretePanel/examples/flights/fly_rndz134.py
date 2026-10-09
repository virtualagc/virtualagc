#!/usr/bin/env python3
"""FLY STS-134'S RENDEZVOUS, FROM NCC - 10 MIN: one GPC in OPS 201 on FD3,
the Orbiter on its real final approach to the real ISS, PASS navigating and
targeting the Ti burn and the midcourses MC1-MC4 and pointing the overhead
windows at the station (RENDEZVOUS_PLAN.md, M1 and Stages 1 and 2).

    python3 examples/flights/fly_rndz134.py --logs DIR [--port-base N]
            [--tape VOLUME] [--from STAGE] [--to STAGE] [--rate X]

It starts simulatePASS.py at 2011-05-18 06:30:00 UTC -- Ti - 68 min, ten
minutes before NCC -- with the ISS flown from its May 2011 TLE
(YAGPC_VEHDYN_TARGETS) and the Orbiter put on the checklist's nominal NC
transfer toward the Ti point (YAGPC_VEHDYN_START_REL, worked out by
yaGPC2/tools/rndz_start.py), and MET counting from STS-134's liftoff
(YAGPC_MTU_MET_EPOCH) so that the crew keys the burn pads' own times.  Then,
phase by phase, with a capture (sts134r-<phase>) after each:

  IPL      one GPC IPL'd and taken straight to OPS 201 (GPC MEMORY
           configuration 2), DAP FREE, SPEC 21 IMUs 1-3 to OPERATE, DAP
           A/AUTO (examples/1gpc-ops201-imu.script); then RNDZ OPS
           INITIALIZATION [5A]'s "Config DAP A,B to A7,B7" (p. 4-5) on SPEC
           20 -- DAP A ITEM 1 +7, DAP B ITEM 2 +7 -- with this tape's A7/B7
           brought to p. 6-2's values first (DAP EDIT, LOAD - ITEM 5)
  UPLINK   the ground (RNDZ timeline p. 4-5, "MCC UPLINK ORB SV, TGT SV"):
           the RNP epoch 2011/136 (message 59), the Orbiter's state
           (message 9) and the ISS's (message 10), both from the truth
  RNDZNAV  ENABLE RENDEZVOUS NAV [7A] (p. 4-7): SPEC 33 RNDZ NAV ENA - ITEM
           1; SV SEL PROP and S TRK checked; SPEC 34 TGT NO 1, BASE TIME = Ti
           TIG, LOAD - ITEM 26
  TRACK    -Z AXIS TARGET TRACK [12A] (p. 4-12): UNIV PTG CNCL - ITEM 21,
           TGT ID +1, BODY VECT +3, OM +0, DAP B/AUTO/ALT, TRK - ITEM 19;
           when the maneuver is complete DAP A/AUTO/VERN
  STRKNAV  STAR TRACKER NAV [10A] (p. 4-10): SPEC 21 IMU DES; SPEC 33 SV SEL
           PROP, INH Angles, S TRK; SPEC 22 THOLD +3 both, -Z TGT TRK - ITEM
           6; when S PRES, the initial residuals watched (BREAK TRK - ITEM 8
           if they jump or exceed 0.6); AUTO Angles - ITEM 23; when SV UPDATE
           POS < 1.0 kft with Angle ACPT > 9, SV SEL - ITEM 4 (FLTR).  The
           pass then runs on -- PASS takes a mark about every 8 s -- through
           Ti targeting (--no-strk: none of this, the M1 baseline)
  TI       TARGET Ti BURN [13A] (p. 4-13) at PET -0:55 (and, with --to TI,
           the final [15A] at TIG - 17 min, in OPS 201): SPEC 34 TGT NO
           +10; the set checked against the checklist (DT 76.9, DX -0.9,
           DY 0, DZ +1.8, EL 0, T1 TIG = BASE TIME) and, this tape's
           I-loads being zero, keyed and LOADed; COMPUTE T1 - ITEM 28.  The
           solution and the states it came from are read out of PASS's
           memory (a capture) and set beside rndz_start.py's independent
           Lambert from the same states and from the truth
  RRNAV    the Ku-band rendezvous radar (Stage 3): AFT FLT STATION CONFIG
           [4A]'s A1U (KU PWR STBY, MAN SLEW, RDR PASSIVE, RADAR OUTPUT HI);
           the KU OPS cue card at NAV RNG < 150 kft (PWR ON, sel GPC, CNTL
           CMD; SPEC 33 KU ANT ENA - ITEM 2); at RR RNG < 135 kft END S TRK
           NAV [10B] and RR NAVIGATION [13B]: SPEC 33 FLTR TO PROP and SV SEL
           PROP, RR - ITEM 13, AUTO RNG/RDOT/Angles - ITEM 17/20/23; SV SEL
           FLTR when SV UPDATE POS < 1.0 kft with RNG ACPT > 9.  The radar
           then serves every pass after it (POST Ti NAV [16A] keeps it; no
           second star tracker pass; RADAR OUTPUT LOW at 700 ft).  --no-rr:
           none of this, the Stage 2 star-tracker-only run
  STRKEND  END S TRK NAV [10B] (p. 4-10): INH Angles - ITEM 24; IMU DES -
           ITEM 7 again (the IMU reselected) -- done already by RRNAV
  TIBURN   (M1b) [15A] in OPS 202 and RNDZ OMS BURN (p. 5-4): SPEC 20 A7/B7
           checked; L OMS, the OMS 2/ORBIT OMS BURNS card's one-engine trims,
           WT, COMPUTE T1, PROP or the ground (truth) solution by the
           final-ground limits, LOAD, TIMER, MNVR, DAP TRANS NORM, EXEC at
           TIG - 15 s; the residuals trimmed with the THC to < 0.2 ft/s each
           axis; DAP B/INRTL/ALT, PULSE/PULSE/PULSE, RCS SEL
  POSTTI   OPS 201, -Z target track again; TARGET MC1 BURN [17A]
           (Preliminary); POST Ti NAV [16A] (FLTR TO PROP) and STAR TRACKER
           NAV [10A] again (SV SEL PROP, marks, FLTR when converged); [17A]
           (Intermediate) if there is time
  MC1      [17A] (Final) in OPS 202 and RCS BURN (CC 9-3): RCS SEL, LOAD,
           TIMER, DAP A/AUTO/PRI and TRANS NORM at TIG - 30 s, VGO nulled
           with the THC at TIG (Z,X,Y if VGO Z is negative, else X,Y,Z; < 0.2
           ft/s), DAP ALT and PULSE, OPS 201 and the -Z track; TARGET MC2
           [17B] (Preliminary); MANUAL OUT-OF-PLANE NULL [19A] when Y = 0
  MC2      [18A] (Intermediate), [18B] (Final: EL 29.07 deg, GWR iterating
           the TIG; outside the -3/+7 min slip limits, TGT 19), FLTR TO PROP,
           RCS BURN; END S TRK NAV [18C]
  MC3      [19B] with BASE TIME = MC2 TIG keyed and LOADed; RCS BURN
  MC4      [20A] (TGT 14: T2 offset 0, 0, +0.6 kft); RCS BURN -- on the
           radar's FLTR state (with --no-rr, the star tracker's)
  ARRIVAL  the truth's relative state every 30 s to MC4 + 13 min (TGT 14's
           T2: the R-bar, 600 ft below the ISS) and the burns' table, PASS's
           solutions beside the truth's Lambert and the checklist's MEAN and
           3 SIGMA (rndz-check.log, burns.json)
  RBAR, RPM, TORVA, VBAR, HOLD
           the manual phase (rndz_manual.py, Stage 5): a scripted pilot on
           the crew's instruments (rndz_instruments.py, Stage 4) from the
           R-bar through the R-bar pitch maneuver and the fly-around to
           station-keeping 100 ft out on the +V-bar, where docking would
           pick up (RENDEZVOUS_PLAN.md 5f; manual.json)

--no-mc flies the M1b baseline instead: after Ti, OPS 201, the -Z track and
the coast to T2 (TIG + 76.9 min).  --zero-sensor-bias is the sensor bias
experiment (RENDEZVOUS_PLAN.md 5b, 5d): this tape's GLQREN bias INITs --
S TRK and RR angles 1.0 rad, RR range and range rate 1.0 ft and ft/s, COAS
-- set to 0.0 in the capture the run resumes from, pending Ron's decision on
the real I-loads, never the tape's value.

Each step that keys an entry is checked in PASS's memory before the next
(probe captures, sts134r-tgt10-*), since an entry can be lost.  Throughout
it logs, every --check-every s of vehicle time (rndz-check.log): PASS's
relative range and rate (from its own Orbiter and target states in the
downlist, format 22) against the truth's (TRU1/TGT1) at the same instant,
the Orbiter's navigation error in LVLH, and the angle between the body -Z
axis -- the -Z star tracker's and COAS's line of sight; the overhead
windows look 5 deg aft of it -- and the ISS.

--rate 2 works: the IDP transfers that broke at rate 2 with SPEC 33 up, and
lost every key after it (2026-10-08), were macOS App Nap throttling MEDS2;
fixed in b4eb048 (macdock.py opts the GUI programs out, MEDS2's bus pump
yields between buses).

Unlike fly_sts134.py this is not the flight from liftoff: the start skips
FD1-FD3's phasing (RENDEZVOUS_PLAN.md, Stage 7), and one GPC flies where the
flight rules want two GNC GPCs for Ti.
"""
import argparse
import calendar
import datetime
import json
import math
import os
import re
import socket
import struct
import subprocess
import sys
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
YAGPC2 = os.path.join(os.path.dirname(PANEL), "yaGPC2")
sys.path.insert(0, PANEL)
sys.path.insert(0, HERE)
import downlist      # noqa: E402
import fly_sts134    # noqa: E402
import groundstation  # noqa: E402
from rndz_manual import ManualPhase  # noqa: E402

FT = 0.3048
EPOCH = "2011-05-18T06:30:00"
TI_TIG = "2011-05-18T07:38:00"            # STS-134's Ti, as flown (left OMS, ~8.4 ft/s)
# MET ZERO: SRB ignition, 136/12:56:27.994 (fly_sts134.T0)
MET_ZERO_UNIX = calendar.timegm((2011, 5, 16, 12, 56, 27)) + 0.994
NORAD_ISS = 25544
RNP = (2011, 136)                          # the flight's RNP epoch, launch day
ORBITER_KG = 121912                        # fly_sts134.FL; see the note in main()
PHASES = ["IPL", "UPLINK", "RNDZNAV", "TRACK", "STRKNAV", "TI", "RRNAV", "STRKEND", "TIBURN", "POSTTI",
          "MC1", "MC2", "MC3", "MC4", "ARRIVAL",
          # the manual phase (rndz_manual.py, Stage 5), to 100 ft station-keeping
          "RBAR", "RPM", "TORVA", "VBAR", "HOLD"]
# TGT 10 as JSC-48072-134 lists it (TARGET Ti BURN [13A], [15A]):
TGT10 = {"T1": 0.0, "EL": 0.0, "DT": 76.9, "DX": -0.9, "DY": 0.0, "DZ": 1.8}
# The midcourse sets, as JSC-48072-134's timeline (pp. 4-17 to 4-20) and
# TARGETING DATA (p. 6-4, the TGT ALTITUDE 210 rows, which the timeline
# pages print; TGT 10 above is the same row's) list them: T1 in minutes after BASE
# TIME (Ti TIG for 11 and 12; "BASETIME = MC2 TIG" for 13 and 14; 19 is the
# slipped MC2's, T1 = BASE TIME), EL in degrees, DT in minutes, the T2 offset
# in kft (target LVLH, +Z down).  MC2's T1 is only GWR's first guess: its EL
# of 29.07 deg makes GWR iterate the TIG to that elevation.
TGT_SETS = {10: TGT10,
            11: {"T1": 20.0, "EL": 0.0, "DT": 56.9, "DX": -0.9, "DY": 0.0, "DZ": 1.8},
            12: {"T1": 49.9, "EL": 29.07, "DT": 27.0, "DX": -0.9, "DY": 0.0, "DZ": 1.8},
            13: {"T1": 17.0, "EL": 0.0, "DT": 10.0, "DX": -0.9, "DY": 0.0, "DZ": 1.8},
            14: {"T1": 27.0, "EL": 0.0, "DT": 13.0, "DX": 0.0, "DY": 0.0, "DZ": 0.6},
            19: {"T1": 0.0, "EL": 0.0, "DT": 27.0, "DX": -0.9, "DY": 0.0, "DZ": 1.8}}
# MC1-MC4 BURN SOLUTION blocks (pp. 4-17 to 4-20): each axis's MEAN and 3
# SIGMA VARIATION, ft/s, LVLH
MC_DISPERSIONS = {11: ((-0.1, 0.6), (-0.1, 0.7), (0.5, 1.2)),
                  12: ((0.0, 0.4), (0.0, 0.2), (0.9, 2.5)),
                  13: ((0.9, 1.3), (0.0, 0.5), (1.1, 2.6)),
                  14: ((1.3, 1.3), (-0.1, 0.6), (0.9, 2.2))}
MC2_TIG_NOMINAL_MIN = 49.9          # Ti + 0:49:54, the TGT 12 row's T1

# THE RENDEZVOUS DAP, A7 and B7: JSC-48072-134 p. 6-2, ISS RNDZ OPS DAP
# CONFIGURATIONS, the RNDZ column, by SPEC 20 item (A 10-28, B 30-48).  The
# timeline configures them in RNDZ OPS INITIALIZATION [5A] (p. 4-5, "Config
# DAP A,B to A7,B7", about PET -2:45, before this run starts) and they stand
# -- "A7(B7)" in the margin of every page -- through NC, NCC, Ti and the
# midcourses (pp. 4-9 to 4-18); RNDZ OMS BURN step 1 (p. 5-4) checks them
# again ("GNC 20 DAP CONFIG ... DAP config A7,B7").  Options are the display's
# words; the rest are numbers.  CNTL ACC (28, 48) is 0 in both.
DAP_RNDZ = {
    "A": {10: 0.200, 11: 2.00, 12: 0.20, 13: 0.10, 14: 0.0, 15: "ALL", 16: "ALL", 17: 0.10,
          18: 0.10, 19: "ALL", 20: 2, 21: 0.08, 22: 0.00,
          23: 0.016, 24: 1.00, 25: 0.020, 26: 0.010, 27: 0.0, 28: 0},
    "B": {30: 0.500, 31: 2.00, 32: 0.20, 33: 0.04, 34: 0.0, 35: "ALL", 36: "ALL", 37: 0.05,
          38: 0.10, 39: "ALL", 40: 2, 41: 0.08, 42: 0.00,
          43: 0.200, 44: 1.00, 45: 0.020, 46: 0.002, 47: 0.0, 48: 0},
}
# SPEC 20's rows, 0-18 down the page (A item = 10 + row, B = 30 + row, DAP
# EDIT = 50 + row), each with the format it is keyed in
DAP_ROWS = ["PRI ROT RATE", "PRI ATT DB", "PRI RATE DB", "PRI ROT PLS", "PRI COMP", "PRI P OPTION",
            "PRI Y OPTION", "PRI TRAN PLS", "ALT RATE DB", "ALT JET OPT", "ALT # JETS", "ALT ON TIME",
            "ALT DELAY", "VERN ROT RATE", "VERN ATT DB", "VERN RATE DB", "VERN ROT PLS", "VERN COMP",
            "VERN CNTL ACC"]
DAP_FMT = {0: "%.4f", 1: "%.2f", 2: "%.2f", 3: "%.3f", 4: "%.3f", 7: "%.3f", 8: "%.3f", 10: "%d",
           11: "%.2f", 12: "%.2f", 13: "%.4f", 14: "%.3f", 15: "%.3f", 16: "%.3f", 17: "%.3f", 18: "%d"}

# THE OMS BURN, per the STS-134 Ascent Checklist's cue card OMS 2/ORBIT OMS
# BURNS (ASC-6a/134/A,O/A, p. 4-3 of JSC-48005-134), which RNDZ OMS BURN step
# 3 (p. 5-4) has the crew perform: "GMBL TRIM ... 1 engine: P = +0.4 LY =
# +5.2 RY = -5.2" and, at cutoff, "Trim Residuals: ... Orbit: All axes < 0.2
# fps".  The rendezvous book's own RCS BURN card (CC 9-3, RNDZ-1a/134/O/A,
# step 5) gives the order -- "If VGO Z is neg, Z,X,Y seq; otherwise, X,Y,Z.
# THC: Trim VGOs < 0.2 fps" -- and the OMS card gives none, so that order is
# used.  The THC's acceleration: the checklist's one figure is +X in A7 with
# DAP TRANS NORM, "THC: +X (up) for 6 sec (1.5 fps)" (VBAR BREAKOUT, p. 5-15),
# 0.25 ft/s^2; for Y and Z there is none, so each axis starts from that and
# is then measured from its own response.
OMS_1ENG_TRIMS = {"P": 0.4, "LY": 5.2, "RY": -5.2}
# GLQREN's GLQ_ST_ANGLES_BIAS_INIT ARRAY(2), this tape's 1.0, 1.0 RADIAN
# (RENDEZVOUS_PLAN.md 5b, THE BLOCKER): #DGLQREN X'0B45C' + X'22', two IBM
# short floats.  --zero-sensor-bias writes 0.0 there in a capture before it is
# resumed -- strk-run2's experiment, made an option.
ST_BIAS_INIT_HW = 0xB47E
IBM_ONE = (0x4110, 0x0000)
# ... and the three before it, in GLQREN's order (GLQREN.hal 62-65), all
# INITIAL(1.0, 1.0) on this tape: COAS angles (rad), RR angles (rad), RR
# range and range rate (ft, ft/s), S TRK angles (rad).  The radar's go into
# CGNV_SENSOR_BIAS$(1-4) when RR is selected (GLARRD, GLBRRA add them to
# the predicted measurements): a 1 rad shaft/trunnion bias is the star
# tracker's blocker again, and 1 ft/s on the range rate is three times the
# radar's noise.  --zero-sensor-bias zeroes all four.
SENSOR_BIAS_INIT = (("GLQ_COAS_ANGLES_BIAS_INIT", 0xB472), ("GLQ_RR_ANGLES_BIAS_INIT", 0xB476),
                    ("GLQ_RRDOT_BIAS_INIT", 0xB47A), ("GLQ_ST_ANGLES_BIAS_INIT", ST_BIAS_INIT_HW))
# The range and range rate set is set up once, at the first GLQREN pass
# after RNDZ NAV ENA (GLQREN.hal step 10: CGNB_DO_RRDOT_NAV_LAST_B6 OFF),
# whichever sensor is selected; so a capture taken after that already holds
# the 1.0 ft and 1.0 ft/s in CGNV_SENSOR_BIAS$(3), $(4) (CGNMC2.hal 312;
# at X'0E7A2' on this tape, beside SENSOR_BIAS_TLM, TAU_SENS and VAR_SENS,
# which read 1300 1300 600 600 and 1E-6 1E-6 711 0.11).  rr-run1: the 1.0
# ft/s, with its 0.33 ft/s sigma, pulled PASS's FLTR range rate 1.0 ft/s off
# the truth.  --zero-sensor-bias zeroes those two as well, when they hold
# exactly 1.0, 1.0.
CGNV_SENSOR_BIAS_HW = 0xE7A2
# CGZB_LAMB_ILOAD ARRAY(40) BIT(1) (CGZMC2.hal:288, one halfword each): which
# target sets GK3 solves with Lambert (GWR), the rest going to the
# non-Lambert GWG.  This tape has the source's INITIAL(10#ON, 30#OFF), so
# MC1-MC4's sets 11-14, and 19, are not Lambert -- and only GWR does MC2's
# elevation-angle TIG search (GWS).  --lambert-mc turns them on in a capture.
LAMB_ILOAD_HW = 0xE34E
LAMBERT_MC_SETS = (11, 12, 13, 14, 19)
# THE FLIGHT'S OWN I-LOADS.  PFS/mafgen/DASS_G2.ASC is the MAFGEN listing of
# STS-134's own GNC2 load ("STS134/OI034/C2 MDD 134.09 DASS GNC2", 13 Dec
# 2010).  Its PATCH SUMMARY lists, word by word, every halfword the flight's
# I-loads changed from the load module: ADDR, CSECT+OFFSET, LM (the load
# module's, the source's INITIAL) and MM (the flight's, on mass memory).
# This tape's G2 holds the LM column almost everywhere (2026-10-09: 2026 of
# the 2919 words LM, 853 MM, all of those in the system's #PFCMGPT and
# #PCDCPHA), so its rendezvous I-loads are the source's placeholders.  The
# ones that bit, LM -> MM:
#   GLQREN's sensor bias INITs, all four pairs  1.0 -> 0.0   (5b, 5d)
#   CGZB_LAMB_ILOAD   sets 1-10 ON -> 9-14, 19, 25-27, 29-40 ON  (5c)
#   GL5_VEL_THRESH    0.9 -> 0.06 ft/s: the smallest burn GL5NAV keeps (5c)
#   CGZV_DEL_X_GUESS  500, 500 -> 100, 100 s   GWQ's first step
#   CGZV_DEL_X_TOL    1E7, 1E7 -> 1E-2, 1E-8   GWQ's secant guard (5e)
#   CGZV_ICMAX        50 -> 10                 GWS/GWQ iterations
#   GWS's EL_DH_TOL 500 -> 100 ft, EL_TOL 1E-3 -> 5E-3 rad; GWX's
#   DEL_T_MAX 500 -> 300 s; and the target sets 9-39 themselves (the
#   p. 6-4 TARGETING DATA, TGT 12's EL 29.072)
# --dass-iloads applies the MM column, in the capture resumed from, to the
# csects of the groups named; only words still holding LM are written.
DASS_G2 = os.path.expanduser("~/workspace/PFS/mafgen/DASS_G2.ASC")
# the same values made permanent on a volume (yaGPC2/tools/sites/
# sts134-rndz-iloads.json through tools/mission_reconfig.py, 2026-10-09)
RNDZ_VOLUME = os.path.expanduser("~/sts134-runs/rendezvous/OI340700-v44boot-sts134-ksc6-rndz.mmv")
DASS_GROUPS = {
    # orbit targeting (CGZ compools, GW*) and relative navigation (CGN
    # compools, GL*): what SPEC 33 and 34 run on
    "rndz": ("#PCGZ", "#DGW", "#PCGN", "#DGL"),
    # every GNC application csect the summary lists (not the system's
    # #PFCMGPT or the display/uplink #PCD, #DD ones)
    "all": ("#PCG", "#DG"),
}
DASS_PATCH = re.compile(r"^ (0[0-9A-F]{5})    ([#$]?[A-Z0-9]+)\+([0-9A-F]{4})    ([0-9A-F]{4})    ([0-9A-F]{4})\s*$")


def dass_patches(path):
    """[(halfword address, csect, LM, MM)] from a MAFGEN listing's PATCH
    SUMMARY."""
    out, on = [], False
    for ln in open(path, errors="replace"):
        if "P A T C H   S U M M A R Y" in ln:
            on = True
        m = on and DASS_PATCH.match(ln.rstrip("\n"))
        if m:
            out.append((int(m.group(1), 16), m.group(2), int(m.group(4), 16), int(m.group(5), 16)))
    return out
TRIM_TOL_FPS = 0.2
THC_X_ACC_FPS2 = 1.5 / 6.0
# Each THC direction's acceleration with DAP A7, PRI, TRANS NORM, as the
# VGO-nulling holds measured it (mc-run1, 2026-10-08; ft/s^2, the change in
# VGO over the hold): the checklist's +X figure (0.25) proved low, and -Z,
# whose jets give the most, was 5x it -- a first -Z hold from 0.25 overshot
# 0.8 ft/s by 3.9.  The holds go on measuring and replace these.
THC_ACC_SEED = {"+x": 0.43, "-x": 0.42, "+y": 0.44, "-y": 0.38, "+z": 0.65, "-z": 1.22}


def unix(when):
    d = datetime.datetime.fromisoformat(when)
    return calendar.timegm(d.timetuple()) + d.microsecond * 1e-6


def gmt_of_unix(u):
    t = time.gmtime(u)
    return (t.tm_yday * 86400 + t.tm_hour * 3600 + t.tm_min * 60 + t.tm_sec) + (u - math.floor(u))


def dhms(sec):
    d, r = divmod(int(round(sec)), 86400)
    h, r = divmod(r, 3600)
    m, s = divmod(r, 60)
    return d, h, m, s


def keys_num(x, fmt):
    t = fmt % abs(x)
    return ("- " if x < 0 else "+ ") + " ".join(t)


def keys_short(x, fmt):
    """As keys_num, but without the digits that say nothing (0.0160 is
    keyed + . 0 1 6): an entry field takes only so many keystrokes."""
    t = fmt % abs(x)
    if "." in t:
        t = t.rstrip("0").rstrip(".") or "0"
        if t.startswith("0."):
            t = t[1:]
    return ("- " if x < 0 else "+ ") + " ".join(t)


SPEC20_PAIR = re.compile(r"(?<![\d.])(\d{2}) +(_*-?\d*\.?\d+|ALL|TAIL|NOSE|_+)(?=\s|$)")


def parse_spec20(text):
    """SPEC 20 DAP CONFIG's text: {'A': 'nn', 'B': 'nn'} (the configurations
    selected, '__' once edited) and {item: value} for items 10-68 (floats,
    or the option word; None for an empty field)."""
    sel = {}
    for k, ab in (("A", "1 DAP A"), ("B", "2 DAP B")):
        m = re.search(re.escape(ab) + r"(\S\S)", text)
        sel[k] = m.group(1) if m else None
    vals = {}
    for line in text.splitlines():
        for m in SPEC20_PAIR.finditer(line):
            i, v = int(m.group(1)), m.group(2)
            if not 10 <= i <= 68:
                continue
            if v.strip("_") == "":
                vals[i] = None
            elif v in ("ALL", "TAIL", "NOSE"):
                vals[i] = v
            else:
                vals[i] = float(v.replace("_", ""))
    return sel, vals


def dap_mismatch(vals, side):
    """Items of the active DAP A or B column that differ from p. 6-2's."""
    bad = {}
    for i, want in DAP_RNDZ[side].items():
        got = vals.get(i)
        if isinstance(want, str) or got is None or isinstance(got, str):
            if got != want:
                bad[i] = (got, want)
        elif abs(got - want) > 0.0006:
            bad[i] = (got, want)
    return bad


# --- what the ground hears: truth, the downlist, the displays ----------------
def _listen(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    if hasattr(socket, "SO_REUSEPORT"):
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    s.bind(("", port))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 socket.inet_aton("239.255.1.1") + socket.inet_aton(os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")))
    s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1 << 20)
    s.settimeout(1.0)
    return s


class Ears(object):
    """Threads that keep the latest truth (TRU1), the ISS (TGT1), the
    decoded format-22 downlist values and each display's full text."""

    def __init__(self, base):
        self.lock = threading.Lock()
        self.tru = None
        self.tgt = None
        self.hist_o, self.hist_t = [], []      # (gmt, r, v), the last couple of minutes
        self.dl = {}
        self.dl_t = {}
        self.cycle, self._cyc = None, {}       # PASS's two states from one downlist cycle
        self.screens = {}
        self.table = downlist.load_table(None)
        for fn, port in ((self._truth, base + 98), (self._target, base + 109),
                         (self._downlist, base + 88), (self._screen, base + 91)):
            threading.Thread(target=fn, args=(_listen(port),), daemon=True).start()

    def _truth(self, s):
        while True:
            try:
                d = s.recv(512)
            except socket.timeout:
                continue
            if d[:4] == b"TRU1" and len(d) >= 4 + 8 * 15:
                n = (len(d) - 4) // 8
                v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
                with self.lock:
                    self.tru = {"t": v[0], "gmt": v[1], "q": v[2:6], "w": v[6:9], "r": v[9:12], "v": v[12:15],
                                "cg": v[27:30] if n >= 30 else (0.0, 0.0, 0.0)}
                    self.hist_o.append((v[1], v[9:12], v[12:15]))
                    del self.hist_o[:-3000]

    def _target(self, s):
        while True:
            try:
                d = s.recv(512)
            except socket.timeout:
                continue
            if d[:4] == b"TGT1" and len(d) >= 4 + 8 * 8:
                n = (len(d) - 4) // 8
                v = struct.unpack(">%dd" % n, d[4:4 + 8 * n])
                with self.lock:
                    g = (self.tru["gmt"] - self.tru["t"] + v[0]) if self.tru else None
                    self.tgt = {"t": v[0], "gmt": g, "norad": int(v[1]), "r": v[2:5], "v": v[5:8],
                                "q": v[8:12] if n >= 12 else (1.0, 0.0, 0.0, 0.0)}
                    if g is not None:
                        self.hist_t.append((g, v[2:5], v[5:8]))
                        del self.hist_t[:-3000]

    def _downlist(self, s):
        while True:
            try:
                d = s.recv(1024)
            except socket.timeout:
                continue
            f = groundstation.parse_downlist(d)
            if f is None:
                continue
            h = groundstation.frame_header(f["words"])
            fmt, fr = h.get("format"), h.get("frame")
            if fmt not in self.table.formats:
                continue
            try:
                vals = downlist.decode_full(f["words"], fmt, fr, self.table)
            except Exception:
                continue
            with self.lock:
                for x in vals:
                    self.dl[x["name"]] = x["value"]
                    self.dl_t[x["name"]] = f["t_us"] / 1e6
                # THE ORBITER'S STATE AND THE TARGET'S, KEPT TOGETHER: frame 0
                # (25) carries T_STATE and R/V_AVGG, staged at the frame's start;
                # frame 5 (30), 0.2 s on, R/V_TARGET (format 22, DCDDG2)
                g = lambda n: self.dl.get(n)
                if fmt == 22 and fr in (0, 25):
                    self._cyc = {"t_state": g("CGGV_T_STATE_HFE"),
                                 "ro": [g("CGGV_R_AVGG_HFE$%d" % i) for i in (1, 2, 3)],
                                 "vo": [g("CGGV_V_AVGG_HFE$%d" % i) for i in (1, 2, 3)]}
                elif fmt == 22 and fr in (5, 30) and self._cyc:
                    self._cyc["rt"] = [g("CGGV_R_TARGET$%d" % i) for i in (1, 2, 3)]
                    self._cyc["vt"] = [g("CGGV_V_TARGET$%d" % i) for i in (1, 2, 3)]
                    if all(isinstance(x, float) for k in ("ro", "vo", "rt", "vt") for x in self._cyc[k]):
                        self.cycle = self._cyc
                    self._cyc = {}

    def _screen(self, s):
        while True:
            try:
                d = s.recv(8192)
            except socket.timeout:
                continue
            name, _, body = d.decode("utf-8", "replace").partition("\n")
            with self.lock:
                self.screens[name.strip().lower()] = body

    def truth_at(self, which, gmt):
        """A vehicle's truth (r, v, m and m/s) at a GMT of the last minutes,
        linearly interpolated between the 20 Hz samples (millimetres)."""
        with self.lock:
            h = list(self.hist_o if which == "orbiter" else self.hist_t)
        for k in range(len(h) - 1, 0, -1):
            if h[k - 1][0] <= gmt <= h[k][0]:
                a, b = h[k - 1], h[k]
                f = (gmt - a[0]) / (b[0] - a[0]) if b[0] > a[0] else 0.0
                return ([a[1][i] + f * (b[1][i] - a[1][i]) for i in range(3)],
                        [a[2][i] + f * (b[2][i] - a[2][i]) for i in range(3)])
        return None

    def snap(self):
        with self.lock:
            return (dict(self.tru) if self.tru else None, dict(self.tgt) if self.tgt else None,
                    dict(self.dl))

    def screen(self, name="crt1"):
        with self.lock:
            return self.screens.get(name, "")


def vsub(a, b): return [a[i] - b[i] for i in range(3)]
def vdot(a, b): return sum(a[i] * b[i] for i in range(3))
def vnorm(a): return math.sqrt(vdot(a, a))


def range_rate(ro, vo, rt, vt):
    d, dv = vsub(rt, ro), vsub(vt, vo)
    rng = vnorm(d)
    return rng, vdot(d, dv) / rng


def body_axis(q, k):
    """Body axis k (0 X, 1 Y, 2 Z) in M50 from the body -> M50 quaternion."""
    w, x, y, z = q
    R = [[1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
         [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
         [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]]
    return [R[0][k], R[1][k], R[2][k]]


def dhms_f(sec):
    d, r = divmod(sec, 86400.0)
    h, r = divmod(r, 3600.0)
    m, sx = divmod(r, 60.0)
    return int(d), int(h), int(m), sx


class PassMemory(object):
    """PASS's own variables, read from a capture's memory image (gpcN.mem.bin:
    main storage as big-endian halfwords, the address the halfword index).

    THE ADDRESSES are the OPS 2 (G2) memory configuration's, from the OI-34
    GNC2 DASS memory map (PFS/mafgen/DASS_G2.ASC, MAFGEN REL 26.020): the
    compools CGZ_MC2 (#PCGZMC2, orbit targeting) and CGN_MC2.  The tape's
    links pin these compools to the same addresses (yaGPC2/tools/pasvar.py
    explains the pinning), and check() confirms it on the image at hand: the
    Lambert flags' INITIAL(10#ON,30#OFF) (CGZMC2.hal:288) must read back."""
    A = {"PROX_TGT_SET_NO": 0xDE24, "COMP_PROX_DT": 0xDE26, "COMP_T2_OFF": 0xDE18,
         "ORB_TGT_EL_ANG": 0xDDF8, "DISP_DV_LVLH": 0xDE34, "DV_MAG": 0xDE3A,
         "TOTAL_SECS": (0xDE6C, 0xDE78, 0xDE84), "BASE_MET": 0xDEA0, "TIME_PROX": 0xDE9C,
         "RS_T1TIG": 0xDEA4, "VS_T1TIG": 0xDEB0, "VS_REQUIRED": 0xDED0,
         "T1_ILOAD": 0xDEDC, "DT_ILOAD": 0xDF2C, "EL_ILOAD": 0xDF7C, "ROFF_ILOAD": 0xDFCC,
         "SHUTTLE_M50": 0xE1F0, "TARGET_M50": 0xE214, "LAMB_ILOAD": 0xE34E,
         "DISP_MISS": 0xE376, "ALARM_KILL": 0xE386,
         "TARGET_MASS": 0xE7DE, "TARGET_CD": 0xE7E0, "TARGET_AREA": 0xE7E2,
         # the ORBIT MNVR EXEC display's VGO, body axes (CGZ123; read 9.36
         # -0.68 -0.34 before the Ti burn and 0.04 -2.15 +1.01 after it in
         # m1b-run2, as the display would), and PASS's one-engine OMS trims,
         # pitch then the left and right yaw (CGGC02 I-loads, -0.1, +5.21,
         # -5.21 on this tape)
         "VGO_BODY": 0xF0C2, "ONE_ENG_TRIM_P": 0xF10C, "ONE_ENG_TRIM_Y": 0xF10E,
         # THE DAP CONFIGURATION IN USE (SPEC 20).  Bases found, not taken
         # from a map: the downlist table (downlist-OI340700.json) gives the
         # offsets -- CGCV_DAP_LOAD_SEL_A/B at CGCCOM +258/+259, and CGCFL2's
         # CGCV_TRANS_PULSE_SIZE +6, MAG_MNVR_RATE +8, ROT_PULSE_SIZE +10,
         # DEADBAND +100, SEL_ALT_ON_TIME +438, SEL_ALT_RATE_LIMIT +440,
         # SEL_ALT_MAX_JETS +442, SEL_ALT_JET_OPTION +443 -- and keying ITEM
         # 1 +7, ITEM 2 +7 and the 6-2 edits changed exactly these words
         # (1 -> 7 at 0x4DA8/9; 0.2 -> 0.1 at 0xECF2, 0.2 -> 0.016 at 0xEB42),
         # agreeing with the downlist's own values (2026-10-08): CGCCOM at
         # 0x4CA6, CGCFL2 at 0xEB3A.
         "DAP_LOAD_SEL_A": 0x4DA8, "DAP_LOAD_SEL_B": 0x4DA9,
         "SEL_TRANS_PULSE": 0xEB40, "SEL_MNVR_RATE": 0xEB42, "SEL_ROT_PULSE": 0xEB44,
         "SEL_DEADBAND": 0xEB9E, "SEL_ALT_ON_TIME": 0xECF0, "SEL_ALT_RATE_LIMIT": 0xECF2,
         "SEL_ALT_MAX_JETS": 0xECF4, "SEL_ALT_JET_OPTION": 0xECF5}

    def dap_selected(self):
        A = self.A
        return {"A": self.hw(A["DAP_LOAD_SEL_A"])[0], "B": self.hw(A["DAP_LOAD_SEL_B"])[0],
                "TRANS_PULSE": self.sp(A["SEL_TRANS_PULSE"]), "MNVR_RATE": self.sp(A["SEL_MNVR_RATE"]),
                "ROT_PULSE": self.sp(A["SEL_ROT_PULSE"]), "DEADBAND": self.svec(A["SEL_DEADBAND"]),
                "ALT_ON_TIME": self.sp(A["SEL_ALT_ON_TIME"]),
                "ALT_RATE_LIMIT": self.sp(A["SEL_ALT_RATE_LIMIT"]),
                "ALT_MAX_JETS": self.hw(A["SEL_ALT_MAX_JETS"])[0],
                "ALT_JET_OPTION": self.hw(A["SEL_ALT_JET_OPTION"])[0]}

    def __init__(self, path):
        self.m = open(path, "rb").read()
        self.path = path

    @classmethod
    def from_capture(cls, *dirs):
        for d in dirs:
            p = os.path.join(d, "gpc1.mem.bin")
            if os.path.exists(p):
                mem = cls(p)
                if mem.check():
                    return mem
        return None

    def hw(self, a, n=1):
        return list(struct.unpack(">%dH" % n, self.m[2 * a:2 * a + 2 * n]))

    def ibm(self, a, n):
        return groundstation.from_ibm_long(self.hw(a, 4)) if n == 4 else groundstation.from_ibm_short(self.hw(a, 2))

    def fault_summary(self):
        """CDL_FAULT_SUMMARY_PAGE (X'1D02'): its lines, oldest first, each
        16 halfwords of two 7-bit characters and a 32-bit time."""
        out = []
        for i in range(15):
            w = self.hw(FAULT_SUMMARY_HW + 18 * i, 18)
            txt = "".join(chr(c) if 32 <= c < 127 else "" for x in w[:16] for c in ((x >> 7) & 0x7f, x & 0x7f))
            if txt.strip():
                out.append("%s %d" % (" ".join(txt.split()), w[16] << 16 | w[17]))
        return out

    def sp(self, a): return self.ibm(a, 2)
    def dp(self, a): return self.ibm(a, 4)
    def dvec(self, a): return [self.dp(a + 4 * i) for i in range(3)]
    def svec(self, a): return [self.sp(a + 2 * i) for i in range(3)]

    def check(self):
        # sets 9 and 10 ON: the tape's INITIAL(10#ON, 30#OFF) and the
        # flight's own (DASS: 9-14, 19, 25-27, 29-40) both have them; the
        # rest differ (--lambert-mc, --dass-iloads)
        return self.hw(self.A["LAMB_ILOAD"] + 8, 2) == [1, 1]

    def iload(self, k):
        i = k - 1
        roff = self.dvec(self.A["ROFF_ILOAD"] + 12 * i)
        return {"T1": self.sp(self.A["T1_ILOAD"] + 2 * i), "DT": self.sp(self.A["DT_ILOAD"] + 2 * i),
                "EL": self.sp(self.A["EL_ILOAD"] + 2 * i),
                "DX": roff[0] / 1000.0, "DY": roff[1] / 1000.0, "DZ": roff[2] / 1000.0}

    def orbit_tgt(self):
        A = self.A
        base = self.dp(A["BASE_MET"])
        t = [self.dp(a) for a in A["TOTAL_SECS"]]
        tm = A["TARGET_M50"]
        return {"TGT_NO": struct.unpack(">h", self.m[2 * A["PROX_TGT_SET_NO"]:2 * A["PROX_TGT_SET_NO"] + 2])[0],
                "DISP_DV_LVLH": self.svec(A["DISP_DV_LVLH"]), "DV_MAG": self.sp(A["DV_MAG"]),
                "BASE_MET": base, "T1_TIG_MET": t[0], "T2_TIG_MET": t[1], "BASE_TIME_MET": t[2],
                "T1_TIG_GMT": t[0] + base, "COMP_PROX_DT": self.sp(A["COMP_PROX_DT"]),
                "COMP_T2_OFF": self.dvec(A["COMP_T2_OFF"]), "EL": self.sp(A["ORB_TGT_EL_ANG"]),
                "RS_T1TIG": self.dvec(A["RS_T1TIG"]), "VS_T1TIG": self.dvec(A["VS_T1TIG"]),
                "VS_REQUIRED": self.dvec(A["VS_REQUIRED"]),
                "TARGET_R_FIN": self.dvec(tm), "TARGET_V_FIN": self.dvec(tm + 12),
                "TARGET_T_IN": self.dp(tm + 24), "TARGET_T_FIN": self.dp(tm + 28),
                "DISP_MISS": self.sp(A["DISP_MISS"]), "ALARM_KILL": self.hw(A["ALARM_KILL"])[0],
                "TARGET_MASS_CD_AREA": [self.sp(A["TARGET_MASS"]), self.sp(A["TARGET_CD"]),
                                        self.sp(A["TARGET_AREA"])]}


class StarTrackerNav(object):
    """STAR TRACKER NAV [10A] and END S TRK NAV [10B] (JSC-48072-134 p. 4-10;
    the S TRK NAV contingencies p. 5-8, 5-9): the crew's side of the -Z star
    tracker's target track (RENDEZVOUS_PLAN.md, Stage 1), and the record of
    what PASS made of the marks.  A mixin for Rendezvous, its own phases.

    The item numbers are the checklist's: SPEC 21 IMU DES - ITEM 7(8,9);
    SPEC 33 SV SEL - ITEM 4, FLTR TO PROP - ITEM 8, S TRK - ITEM 12, AUTO /
    INH Angles - ITEM 23 / 24; SPEC 22 -Z(-Y) TGT TRK - ITEM 6(5), BREAK TRK
    - ITEM 8(7), -Y / -Z THOLD - ITEM 13 / 14.  In PASS: GKVREL (SPEC 33),
    GYZSTS (SPEC 22's TGT TRK sets CGYB_MODE_CMD 3), GY3STT (the search),
    GY8DAT (21-sample marks), GL3REN / GLCSTA / GLZANG (the filter)."""

    def strk_watch(self):
        if getattr(self, "_strkw", None) is None:
            self._strkw = StrkWatch(self.base)
        return self._strkw

    def run(self):
        threading.Thread(target=self.strk_monitor, daemon=True).start()
        return super().run()

    def strk_keys(self, script, name, timeout=120):
        self.play(script, name)
        self.script_done(name, timeout)

    def strknav(self, again=False, until_gmt=None):
        """[10A].  again: the pass after Ti (POST Ti NAV [16A], p. 4-16:
        "IF SV SEL = FLTR: FLTR TO PROP - ITEM 8", then STAR TRACKER NAV
        [10A] once in -Z TGT TRK attitude), which starts by putting SV SEL
        back to PROP -- [10A]'s "SV SEL PROP" -- as the first pass found it.
        until_gmt: the pass gives up waiting for convergence then (the next
        burn's targeting comes first)."""
        if self.a.no_strk:
            self.say("STRKNAV: --no-strk, no star tracker pass (the M1 baseline)")
            return
        self.strk_ended = False
        w = self.strk_watch()
        w.wait_ready(60)
        self.say("STAR TRACKER NAV [10A]%s at Ti %+.1f min; before it: %s"
                 % (" (after Ti)" if again else "", (self.truth()["gmt"] - self.ti_gmt) / 60.0, w.summary()))
        if again and w.sv_sel_bit() == 1:
            # SV SEL toggles (GKVREL case 14), FLTR TO PROP copies (case 8)
            self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                           "+5     keys ITEM 8 EXEC\n"
                           "+4     keys ITEM 4 EXEC\n", "strk-fltr-to-prop")
            self.wait_sim(8)
            self.say("POST Ti NAV [16A]: FLTR TO PROP - ITEM 8, SV SEL - ITEM 4 (PROP): bit %s; %s"
                     % (w.sv_sel_bit(), w.summary()))
        sv_prop = w.sv_sel_bit()
        # 1. CONFIG FOR STRK NAV.  DAP A/AUTO/VERN is TRACK's.  The IMU for
        # deselect is MCC's call ("if no comm, use IMU 1"): IMU 1.
        self.imu1_select(False, "strk-des")
        self.cw_known = getattr(self, "cw_known", set()) | {"IMU"}    # the deselect's IMU caution
        self.wait_sim(6)
        self.cw_ack("[10A] IMU deselect")
        # SPEC 33: SV SEL PROP (the first NAV pass) checked; INH Angles and
        # S TRK keyed -- both set rather than toggle (GKVREL cases 12 and 8),
        # so keying a checked item is harmless; SV SEL toggles (case 14), so
        # it is only checked
        self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                       "+5     keys ITEM 2 4 EXEC\n"
                       "+3     keys ITEM 1 2 EXEC\n", "strk-rel-nav")
        self.wait_sim(5)
        self.say("SPEC 33: SV SEL bit %s (as RNDZNAV left it: PROP), angles AIF %s; %s"
                 % (sv_prop, w.get("CGNV_NAV_ANGLES_AIF_TLM"), w.summary()))
        # SPEC 22: -Y THOLD - ITEM 13 + 3, -Z THOLD - ITEM 14 + 3, -Z TGT TRK - ITEM 6
        self.strk_keys("+1     keys SPEC 2 2 PRO\n"
                       "+5     keys ITEM 1 3 + 3 EXEC\n"
                       "+3     keys ITEM 1 4 + 3 EXEC\n"
                       "+3     keys ITEM 6 EXEC\n", "strk-tgt-trk")
        # GY3STT's first passes break the track and put the box on the
        # target's predicted place: an S PRES of the star the full-field
        # star mode was holding is not the target's (run strk-run1)
        self.wait_sim(5)
        # 2. INITIAL MEASUREMENT EVALUATION: when S PRES, RESID V and H each
        # NAV cycle for four cycles; BREAK TRK (ITEM 8) if they move more
        # than 0.05 a cycle or exceed 0.6
        for attempt in range(4):
            if not self.strk_wait(lambda: w.s_pres(), 90):
                self.say("STRK: no S PRES in 90 s; %s" % w.summary())
                if attempt < 3:
                    self.strk_keys("+1     keys ITEM 8 EXEC\n", "strk-break-%d" % attempt, 60)
                    continue
                self.say("STRK: the pass is abandoned -- no target")
                self.strk_keys("+1     keys RESUME\n", "strk-resume", 60)
                return
            self.say("STRK: S PRES at Ti %+.1f min; %s"
                     % ((self.truth()["gmt"] - self.ti_gmt) / 60.0, w.summary()))
            res = []
            for k in range(5):
                self.wait_sim(3.84)
                res.append(w.resid())
            self.say("STRK: RESID H/V each NAV cycle: %s" % ", ".join("%+.3f/%+.3f" % r for r in res))
            jump = max(max(abs(res[i][0] - res[i - 1][0]), abs(res[i][1] - res[i - 1][1]))
                       for i in range(1, len(res)))
            big = max(max(abs(r[0]), abs(r[1])) for r in res)
            if jump <= 0.05 and big <= 0.6:
                break
            self.say("STRK: RESID %s (jump %.3f, largest %.3f): -Z BREAK TRK - ITEM 8"
                     % ("jumping" if jump > 0.05 else "high", jump, big))
            self.strk_keys("+1     keys ITEM 8 EXEC\n", "strk-break-%d" % attempt, 60)
        else:
            self.say("STRK: residuals never steady: S TRK NAV - HIGH INITIAL RESID (5-8) would follow; "
                     "going on with the pass")
        # 3. INCORPORATE DATA INTO NAV (SV SEL = PROP): AUTO Angles - ITEM 23
        self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                       "+5     keys ITEM 2 3 EXEC\n", "strk-auto-angles")
        acc0 = w.accepts()
        self.pass_acc0 = acc0
        self.strk_wait(lambda: w.accepts()[0] > acc0[0] or w.accepts()[1] > acc0[1], 120)
        self.say("STRK: AUTO Angles; 1st SV UPDATE POS %s kft; %s" % (_f(w.get("CGNV_R_MEAS_RSS")), w.summary()))
        # "When SV UPDATE POS < 1.0 and Angle ACPT > 9: SV SEL - ITEM 4 (FLTR)"
        # -- the marks of this pass: SPEC 33's counts run on from the last
        limit = 900.0
        if until_gmt is not None:
            limit = max(0.0, min(limit, until_gmt - self.truth()["gmt"]))
        ok = self.strk_wait(lambda: min(w.accepts()[i] - acc0[i] for i in (0, 1)) > 9
                            and (w.get("CGNV_R_MEAS_RSS") or 9e9) < 1.0, limit)
        if not ok:
            self.say("STRK: SV UPDATE POS < 1.0 with ACPT > 9 not reached in %.0f min; SV SEL left PROP; %s"
                     % (limit / 60.0, w.summary()))
        else:
            self.strk_keys("+1     keys ITEM 4 EXEC\n", "strk-sv-sel-fltr")
            self.wait_sim(8)
            self.say("STRK: SV SEL - ITEM 4 (FLTR) at Ti %+.1f min: bit %s (was %s); %s"
                     % ((self.truth()["gmt"] - self.ti_gmt) / 60.0, w.sv_sel_bit(), sv_prop, w.summary()))
        self.strk_keys("+1     keys RESUME\n", "strk-resume", 60)

    def strkend(self):
        """END S TRK NAV [10B]: INH Angles; the deselected IMU back.  Once
        (RRNAV does it before RR NAVIGATION [13B], when the radar is on)."""
        if self.a.no_strk or getattr(self, "strk_ended", False):
            return
        self.strk_ended = True
        self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                       "+5     keys ITEM 2 4 EXEC\n"
                       "+3     keys RESUME\n", "strk-end")
        self.imu1_select(True, "strk-end")
        self.say("END S TRK NAV: %s" % self.strk_watch().summary())

    def strk_wait(self, cond, sim_seconds):
        t0 = self.truth()["t"]
        while self.truth()["t"] < t0 + sim_seconds:
            try:
                if cond():
                    return True
            except (TypeError, ValueError):
                pass
            time.sleep(1.0)
        return False

    def strk_monitor(self):
        """Every --check-every s of vehicle time: the pass as SPEC 33 shows
        it, and PASS's relative state, FLTR and PROP, against the truth's
        (ft; the truth target's LVLH, x ahead, y = -orbit normal, z down)."""
        while getattr(self, "ears", None) is None:
            time.sleep(1.0)
        w = self.strk_watch()
        last = -1e9
        while True:
            time.sleep(2.0)
            try:
                rel = w.rel_errors(self.ears)
                if rel is None or rel["t"] - last < self.a.check_every:
                    continue
                last = rel["t"]
                self.say("strk: T_STATE %.1f (Ti %+.1f min): %s\n"
                         "      relative state error, ft (LVLH x y z |r|): FLTR %+.0f %+.0f %+.0f |%.0f|, "
                         "PROP %+.0f %+.0f %+.0f |%.0f|; rate error ft/s FLTR %.3f PROP %.3f; truth range %.0f ft"
                         % (rel["t"], (rel["t"] - self.ti_gmt) / 60.0, w.summary(), *rel["fltr"], rel["fltr_n"],
                            *rel["prop"], rel["prop_n"], rel["fltr_vn"], rel["prop_vn"], rel["range"]))
                if getattr(self, "rr_active", False) or w.get("CGYV_RR_RNG_LFE"):
                    self.say("rr: %s; truth range %.0f ft" % (self.rr_summary(), rel["range"]))
                self.rr_watch_output(rel)
            except Exception as e:     # never let the log take the flight down
                self.say("strk monitor: %r" % e)


class StrkWatch(object):
    """THE PASS AS THE GROUND SAW IT: format 22 (the OPS 2 GNC downlist,
    DCDDG2) carries all of it -- the -Z tracker's three words (CGBV_STU),
    PASS's display status for each tracker, the rel nav's mark count,
    accept/reject counts and residuals (SPEC 33's ACPT, REJ, RESID), the
    last SV update (SV UPDATE POS, CGNV_R_MEAS_RSS, kft), FLTR MINUS PROP
    (CGNV_R_FMP_DISP), and, staged together at frames 0 and 25 and sent in
    frames 15-24 (40-49), the FLTR, PROP and target states at one T_STATE
    (CGNV_R_FILT_DL, CGNV_R_PROP_TLM, CGNV_R_TV_TLM; ft, M50)."""

    def __init__(self, base):
        self.lock = threading.Lock()
        self.v = {}
        self.rel = None
        self._st = {}
        self.table = downlist.load_table(None)
        threading.Thread(target=self._run, args=(_listen(base + 88),), daemon=True).start()

    def _run(self, s):
        while True:
            try:
                d = s.recv(1024)
            except socket.timeout:
                continue
            f = groundstation.parse_downlist(d)
            if f is None:
                continue
            h = groundstation.frame_header(f["words"])
            if h.get("format") != 22:
                continue
            fr = h.get("frame")
            try:
                vals = downlist.decode_full(f["words"], 22, fr, self.table)
            except Exception:
                continue
            with self.lock:
                for x in vals:
                    if x.get("card") not in (6, 7, 8):      # the whole item, not one bit of it
                        self.v[x["name"]] = x["value"]
                g = self.v.get

                def vec(n):
                    return [g("%s$%d" % (n, i)) for i in (1, 2, 3)]
                if fr in (15, 40):
                    self._st = {"t": g("CGGV_T_STATE_DL"), "rf": vec("CGNV_R_FILT_DL"),
                                "vf": vec("CGNV_V_FILT_DL")}
                elif fr in (20, 45) and self._st:
                    self._st.update(rt=vec("CGNV_R_TV_TLM"), vt=vec("CGNV_V_TV_TLM"))
                elif fr in (24, 49) and "rt" in self._st:
                    self._st.update(rp=vec("CGNV_R_PROP_TLM"), vp=vec("CGNV_V_PROP_TLM"))
                    if all(isinstance(x, float) for k in ("rf", "vf", "rt", "vt", "rp", "vp")
                           for x in self._st[k]) and isinstance(self._st["t"], float):
                        self.rel = self._st
                    self._st = {}

    def get(self, name):
        with self.lock:
            return self.v.get(name)

    def wait_ready(self, secs):
        t0 = time.time()
        while time.time() - t0 < secs and self.get("CGNV_ST_MARK_NUM") is None:
            time.sleep(1.0)

    def s_pres(self):
        w1 = self.get("CGBV_STU$(1;1)")
        return isinstance(w1, int) and (w1 & 0x0400) != 0

    def resid(self):
        return (self.get("CGNV_DISP_DELQ$1") or 0.0, self.get("CGNV_DISP_DELQ$2") or 0.0)

    def accepts(self):
        return (self.get("CGNV_N_ACCEPT$1") or 0, self.get("CGNV_N_ACCEPT$2") or 0)

    def sv_sel_bit(self):
        f = self.get("CGZB_REL_NAV_FLG_WD1_LFE")
        return None if not isinstance(f, int) else int((f & 0x0040) != 0)

    def summary(self):
        g = self.get
        w1, w2, w3 = g("CGBV_STU$(1;1)"), g("CGBV_STU$(1;2)"), g("CGBV_STU$(1;3)")
        hv = ""
        if isinstance(w2, int) and isinstance(w3, int):
            def sx(x):
                return ((x >> 4) & 0xFFF) - (0x1000 if x & 0x8000 else 0)
            hv = " H %+.3f V %+.3f" % (sx(w2) * 0.0025390625, sx(w3) * 0.0025390625)
        fl = g("CGYB_ST_TARG_FLAGS_LFE")
        return ("-Z ST word1 %s%s%s, status %s, flags %s; marks %s, ACPT %s/%s REJ %s/%s, RESID H %s V %s, "
                "SV UPDATE POS %s kft, FLTR-PROP %s kft, AIF %s, SV SEL bit %s"
                % ("%04X" % w1 if isinstance(w1, int) else w1, " S PRES" if self.s_pres() else "", hv,
                   g("CGYB_DISP_STAT_DL$1"), "%04X" % fl if isinstance(fl, int) else fl,
                   g("CGNV_ST_MARK_NUM"), g("CGNV_N_ACCEPT$1"), g("CGNV_N_ACCEPT$2"), g("CGNV_N_REJECT$1"),
                   g("CGNV_N_REJECT$2"), _f(g("CGNV_DISP_DELQ$1")), _f(g("CGNV_DISP_DELQ$2")),
                   _f(g("CGNV_R_MEAS_RSS")), _f(g("CGNV_R_FMP_DISP")), g("CGNV_NAV_ANGLES_AIF_TLM"),
                   self.sv_sel_bit()))

    def rel_errors(self, ears):
        """PASS's relative states (the FLTR and PROP Orbiter less the target,
        at one T_STATE) against the truth's then, in the truth target's LVLH."""
        with self.lock:
            st = self.rel
        if st is None:
            return None
        ts = st["t"]
        to, tt = ears.truth_at("orbiter", ts), ears.truth_at("target", ts)
        if not to or not tt:
            return None
        ro, vo = [x / FT for x in to[0]], [x / FT for x in to[1]]
        rt, vt = [x / FT for x in tt[0]], [x / FT for x in tt[1]]
        dr_true, dv_true = vsub(ro, rt), vsub(vo, vt)
        ez = [-x / vnorm(rt) for x in rt]
        hh = [rt[1] * vt[2] - rt[2] * vt[1], rt[2] * vt[0] - rt[0] * vt[2], rt[0] * vt[1] - rt[1] * vt[0]]
        ey = [-x / vnorm(hh) for x in hh]
        ex = [ey[1] * ez[2] - ey[2] * ez[1], ey[2] * ez[0] - ey[0] * ez[2], ey[0] * ez[1] - ey[1] * ez[0]]
        out = {"t": ts, "range": vnorm(dr_true)}
        for k, rk, vk in (("fltr", "rf", "vf"), ("prop", "rp", "vp")):
            er = vsub(vsub(st[rk], st["rt"]), dr_true)
            ev = vsub(vsub(st[vk], st["vt"]), dv_true)
            out[k] = [vdot(er, e) for e in (ex, ey, ez)]
            out[k + "_n"] = vnorm(er)
            out[k + "_vn"] = vnorm(ev)
        return out


def _f(x):
    return "%.3f" % x if isinstance(x, float) else str(x)


class RadarNav(object):
    """THE KU-BAND RENDEZVOUS RADAR (RENDEZVOUS_PLAN.md Stage 3): AFT FLT
    STATION CONFIG [4A]'s A1U, the KU OPS cue card at NAV RNG < 150 kft,
    RR NAVIGATION [13B] at RR RNG < 135 kft, RADAR OUTPUT LOW at about 700
    ft.  The radar is yaGPC2's kuradar.c, its panel word panelO6's A1U
    controls; PASS reads it on FF3 card 3 channel 3 (GYNRRP) and takes its
    range, range rate and angles (GLARRD, GLBRRA) into the same filter as
    the star tracker's marks.  A mixin for Rendezvous.

    SPEC 33 (GKVREL): KU ANT ENA - ITEM 2 (case 4: CGZB_KU_ANT_CMD, to the
    SM computer, which is not here); S TRK / RR / COAS - ITEM 12 / 13 / 14
    (case 8: CGZV_ST_RR_COAS); RNG AUT/INH/FOR - ITEM 17-19, RDOT 20-22,
    Angles 23-25 (cases 10-12); FLTR TO PROP - ITEM 8; SV SEL - ITEM 4.
    The counts: CGNV_N_ACCEPT$1-2 angles, $3 range, $4 range rate."""

    RR_START_FT = 135000.0
    KU_OPS_FT = 150000.0

    def rr_on(self):
        return not self.a.no_rr

    def rr_summary(self):
        w = self.strk_watch()
        g = w.get
        return ("RR RNG %s ft RDOT %s ft/s ROLL %s PITCH %s; ACPT ang %s/%s rng %s rdot %s, REJ rng %s rdot %s; "
                "RESID rng %s rdot %s; SV UPDATE POS %s kft; sensor %s, SV SEL bit %s"
                % (_f(g("CGYV_RR_RNG_LFE")), _f(g("CGYV_RR_RNGR_LFE")), _f(g("CGYV_RR_ROLL_LFE")),
                   _f(g("CGYV_RR_PITCH_LFE")), g("CGNV_N_ACCEPT$1"), g("CGNV_N_ACCEPT$2"), g("CGNV_N_ACCEPT$3"),
                   g("CGNV_N_ACCEPT$4"), g("CGNV_N_REJECT$3"), g("CGNV_N_REJECT$4"), _f(g("CGNV_DISP_DELQ$3")),
                   _f(g("CGNV_DISP_DELQ$4")), _f(g("CGNV_R_MEAS_RSS")), g("CGZV_ST_RR_COAS_LFE"),
                   w.sv_sel_bit()))

    def ku_switches(self, name, **pos):
        self.play("".join("+1     switch ku_%s %s\n" % (k, v) for k, v in pos.items()), name)
        self.script_done(name, 60)

    def pass_range_ft(self):
        """NAV RNG: PASS's own range, |FLTR - target| or |PROP - target| as
        SV SEL has it (the downlist's staged states), else None."""
        w = self.strk_watch()
        with w.lock:
            st = w.rel
        if not st:
            return None
        rk = "rf" if w.sv_sel_bit() == 1 else "rp"
        return vnorm(vsub(st[rk], st["rt"]))

    def rrnav(self):
        """KU OPS and RR NAVIGATION [13B], between Ti's preliminary and final
        targeting (the radar's 135 kft comes at about Ti - 40 min)."""
        if not self.rr_on():
            self.say("RRNAV: --no-rr, no rendezvous radar (the Stage 2 baseline)")
            return
        w = self.strk_watch()
        # AFT FLT STATION CONFIG [4A]: A1U
        self.ku_switches("ku-config", power="STBY", steering="MAN SLEW", mode="RDR PASSIVE",
                         radar_output="HIGH", control="PNL")
        self.say("[4A] A1U: KU PWR STBY, sel MAN SLEW, MODE RDR PASSIVE, RADAR OUTPUT HI, CNTL PNL")
        # KU OPS at NAV RNG < 150 kft
        limit = self.ti_gmt - 20 * 60.0
        while self.truth()["gmt"] < limit:
            r = self.pass_range_ft()
            if r is not None and r < self.KU_OPS_FT:
                break
            time.sleep(2.0)
        self.say("KU OPS at Ti %+.1f min: NAV RNG %s kft" % (self.ti_min(), _f((self.pass_range_ft() or 0) / 1e3)))
        self.ku_switches("ku-ops", power="ON", steering="GPC", control="CMD")
        self.play("+1     keys SPEC 3 3 PRO\n+5     keys ITEM 2 EXEC\n+3     keys RESUME\n", "ku-ant-ena")
        self.script_done("ku-ant-ena", 60)
        # RR RNG < 135 kft: data on SPEC 33
        while self.truth()["gmt"] < limit:
            rr = w.get("CGYV_RR_RNG_LFE")
            if isinstance(rr, float) and 1.0 < rr < self.RR_START_FT:
                break
            time.sleep(2.0)
        else:
            self.say("RRNAV: no radar range under 135 kft by Ti - 20 min; %s" % self.rr_summary())
            return
        self.say("RR RNG < 135 kft at Ti %+.1f min: %s" % (self.ti_min(), self.rr_summary()))
        # END S TRK NAV [10B] first, if a star tracker pass is on
        if not self.a.no_strk and not getattr(self, "strk_ended", False):
            self.strkend()
        self.rr_start_pass("rr-nav")
        self.rr_active = True
        self.save_state()
        self.rr_converge("RR NAV", self.ti_gmt - 19 * 60.0)

    def rr_start_pass(self, name):
        """[13B]'s keys: FLTR TO PROP and SV SEL PROP if FLTR is selected;
        RR; AUTO RNG, RDOT, Angles."""
        w = self.strk_watch()
        if w.sv_sel_bit() == 1:
            self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                           "+5     keys ITEM 8 EXEC\n"
                           "+4     keys ITEM 4 EXEC\n", name + "-prop")
            self.wait_sim(8)
        self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                       "+5     keys ITEM 1 3 EXEC\n"
                       "+3     keys ITEM 1 7 EXEC\n"
                       "+3     keys ITEM 2 0 EXEC\n"
                       "+3     keys ITEM 2 3 EXEC\n", name)
        self.wait_sim(10)
        self.rr_acc0 = (w.get("CGNV_N_ACCEPT$3") or 0, w.get("CGNV_N_ACCEPT$4") or 0)
        self.say("RR NAVIGATION [13B]: RR - ITEM 13, AUTO RNG/RDOT/Angles - ITEM 17/20/23 (SV SEL PROP); %s"
                 % self.rr_summary())

    def rr_converged(self):
        w = self.strk_watch()
        acc0 = getattr(self, "rr_acc0", (0, 0))
        n = (w.get("CGNV_N_ACCEPT$3") or 0) - acc0[0]
        pos = w.get("CGNV_R_MEAS_RSS")
        return n > 9 and isinstance(pos, float) and pos < 1.0, n, pos

    def rr_converge(self, what, until_gmt):
        """SV SEL - ITEM 4 (FLTR) when SV UPDATE POS < 1.0 kft with RNG ACPT
        > 9 -- [10A]'s rule, applied to the radar's marks."""
        w = self.strk_watch()
        while self.truth()["gmt"] < until_gmt:
            ok, n, pos = self.rr_converged()
            if ok:
                self.strk_keys("+1     keys SPEC 3 3 PRO\n+5     keys ITEM 4 EXEC\n+3     keys RESUME\n",
                               "rr-sv-sel-fltr-%s" % what.replace(" ", "-").lower())
                self.wait_sim(8)
                self.say("%s: converged (RNG ACPT %d this pass, SV UPDATE POS %.3f kft) at Ti %+.1f min -- SV SEL "
                         "- ITEM 4 (FLTR): bit %s; %s" % (what, n, pos, self.ti_min(), w.sv_sel_bit(),
                                                          self.rr_summary()))
                return True
            time.sleep(3.0)
        self.say("%s: not converged by its deadline; SV SEL left %s; %s"
                 % (what, w.sv_sel_bit(), self.rr_summary()))
        return False

    def rr_again(self, until_gmt):
        """POST Ti NAV [16A] with the radar: FLTR TO PROP, SV SEL PROP; the
        radar stays selected and AUTO; FLTR again when converged."""
        self.say("POST Ti NAV [16A] (radar) at Ti %+.1f min" % self.ti_min())
        self.rr_start_pass("rr-post-ti")
        self.rr_converge("POST Ti RR NAV", until_gmt)

    def rr_watch_output(self, rel):
        """RADAR OUTPUT LOW at about 700 ft."""
        if (self.rr_on() and getattr(self, "rr_active", False) and not getattr(self, "ku_low", False)
                and rel and rel.get("range", 9e9) < 700.0):
            self.ku_low = True
            self.ku_switches("ku-output-low", radar_output="LOW")
            self.say("RADAR OUTPUT LOW at %.0f ft" % rel["range"])



# THE IMUs.  CGUB_IMU_SEL_MFE (X'59DC'): the IMUs PASS's RM has selected, IMU
# 1 the 4 bit (7 all three).  SPEC 21's ITEM 7(8, 9) TOGGLES an IMU's
# deselect (GKUIMU.hal 203-212), so a deselect or a reselect is checked here
# before and after.  And PASS's IMU attitude RM thresholds, X'566E'-X'5679'
# (CGRV_A_CONS(1,2), A_RAMP(1,2), 2A_CONS_2, 2A_RAMP_2), are set only by
# GRS_IMU_RM_INIT after MM101 or an onboard alignment, which a run started
# in OPS 2 never does: they are zero in every capture from IPL, so with
# three IMUs every IMU miscompares unseen, and with two selected the RM
# dilemma fires within four passes (RM DLMA IMU: the IMU caution and the
# backup C&W).  They are seeded in the capture flown on from (DASS_G2.ASC's
# addresses; the pairings #CGRSIMU+9D..C5): single-precision pairs copied
# source -> target.  CGRV_OPS_TR_TIME stays 0; the MM101 init flag is not set.
IMU_SEL_HW = 0x59DC
IMU_RM_SEED = ((0x563C, 0x566E, "A_CONS_5 -> A_CONS(1)"), (0x5638, 0x5670, "A_CONS_1 -> A_CONS(2)"),
               (0x564C, 0x5672, "A_RAMP_5 -> A_RAMP(1)"), (0x5648, 0x5674, "A_RAMP_2 -> A_RAMP(2)"),
               (0x5644, 0x5676, "A_CONS_9 -> 2A_CONS_2"), (0x5650, 0x5678, "A_RAMP_8 -> 2A_RAMP_2"))
FAULT_SUMMARY_HW = 0x1D02          # CDL_FAULT_SUMMARY_PAGE


class Rendezvous(ManualPhase, RadarNav, StarTrackerNav, fly_sts134.Flight):
    def __init__(self, a):
        super().__init__(a)
        self.checklog = open(os.path.join(a.logs, "rndz-check.log"), "a")
        self.ti_unix = unix(TI_TIG)
        self.ti_gmt = gmt_of_unix(self.ti_unix)
        self.ti_met = self.ti_unix - MET_ZERO_UNIX
        # what the MC phases learn, kept so that --from MC2 (say) goes on
        # with MC1's TIGs, solutions and THC accelerations
        self.burns, self.mc_tig = {}, {}
        try:
            st = json.load(open(os.path.join(a.logs, "mc-state.json")))
            self.burns = st.get("burns", {})
            self.mc_tig = {int(k): v for k, v in st.get("mc_tig", {}).items()}
            if st.get("thc_acc"):
                self.thc_acc = st["thc_acc"]
            if st.get("pass_acc0"):
                self.pass_acc0 = tuple(st["pass_acc0"])
            self.rr_active = bool(st.get("rr_active"))
            self.strk_ended = bool(st.get("strk_ended"))
            if st.get("rr_acc0"):
                self.rr_acc0 = tuple(st["rr_acc0"])
        except (OSError, ValueError):
            pass

    def save_state(self):
        json.dump({"burns": self.burns, "mc_tig": self.mc_tig, "thc_acc": getattr(self, "thc_acc", None),
                   "pass_acc0": getattr(self, "pass_acc0", None), "rr_active": getattr(self, "rr_active", False),
                   "strk_ended": getattr(self, "strk_ended", False), "rr_acc0": getattr(self, "rr_acc0", None)},
                  open(os.path.join(self.a.logs, "mc-state.json"), "w"), indent=1)

    def say(self, text):
        print("fly_rndz134: %s" % text, flush=True)
        self.checklog.write("%s %s\n" % (time.strftime("%H:%M:%S"), text))
        self.checklog.flush()

    # --- the vehicle ------------------------------------------------------
    def start(self, resume=None):
        rel = os.environ.get("YAGPC_VEHDYN_START_REL")
        if not rel:
            out = subprocess.run([sys.executable, os.path.join(YAGPC2, "tools", "rndz_start.py"), "start",
                                  "--targets", self.a.targets, "--ti", TI_TIG, "--start", EPOCH],
                                 check=True, capture_output=True, text=True).stdout
            open(os.path.join(self.a.logs, "rndz-start.txt"), "w").write(out)
            rel = re.search(r"YAGPC_VEHDYN_START_REL=(\S+)", out).group(1)
            for line in out.strip().splitlines():
                self.say("start: " + line)
        env = dict(os.environ, YAGPC_MDM_DEVICES="1", YAGPC_VEHDYN="1",
                   YAGPC_VEHDYN_ORBITER_KG=str(ORBITER_KG), YAGPC_OMS_ARMED="1",
                   YAGPC_RNP="%d,%d" % RNP, YAGPC_VEHDYN_STATELOG="10",
                   YAGPC_VEHDYN_TARGETS=self.a.targets, YAGPC_VEHDYN_START_REL=rel,
                   YAGPC_MTU_MET_EPOCH="%.3f" % MET_ZERO_UNIX,
                   # every row of the DPS page, not just the title (MEDS2's
                   # announceScreen): SPEC 20's values are checked from the
                   # page itself, and dump_screen shows whole pages
                   NSTS_ANNOUNCE_ROWS="all",
                   PYTHONUNBUFFERED="1")
        cmd = [sys.executable, "-u", os.path.join(PANEL, "simulatePASS.py"), "--gpcs", "1",
               "--crts", str(self.a.crts), "--tape", self.a.tape, "--no-wait-user", "--size", "384",
               "--port-base", str(self.base), "--logs", os.path.join(self.a.logs, "logs"),
               "--snapshot-dir", self.a.logs, "--duration", "20000",
               # the commander's station, for the THC that trims the Ti burn's
               # residuals: without a hand-controller window a script's `thc`
               # moves nothing (m1b-run3, 2026-10-08: "no hand-controller
               # window for that station is running")
               "--rhc", self.a.rhc]
        if resume and self.a.zero_sensor_bias:
            self.zero_sensor_bias(resume)
        if resume and self.a.lambert_mc:
            self.lambert_mc(resume)
        if resume and self.a.dass_iloads:
            self.dass_iloads(resume)
        if resume:
            self.seed_imu_rm(resume)
        cmd +=["--snapshot-resume", resume] if resume else ["--date-time-epoch", EPOCH]
        if self.a.rate != 1.0:
            cmd += ["--rt-factor", "%g" % self.a.rate]
        if not self.a.portview:
            cmd += ["--no-portview"]
        elif self.a.views:
            cmd += ["--portview-views", self.a.views]
        if self.a.hold_start:
            cmd += ["--hold-start"]
        if self.a.station != "all":
            cmd += ["--station", self.a.station]
        if self.a.input:
            cmd += ["--input", self.a.input]
        if self.a.layout:
            cmd += ["--layout", os.path.abspath(os.path.expanduser(self.a.layout))]
        os.makedirs(self.a.logs, exist_ok=True)
        outp = os.path.join(self.a.logs, "simulatePASS.out")
        if os.path.exists(outp):
            os.replace(outp, outp + ".%d" % int(time.time()))
        self.out = open(outp, "w")
        self.ears = Ears(self.base)
        self.proc = subprocess.Popen(cmd, env=env, stdout=self.out, stderr=subprocess.STDOUT,
                                     stdin=subprocess.DEVNULL, cwd=PANEL)
        self.wait_file(outp, "session commands on port", 180)
        if self.a.hold_start:
            # --hold-start: every window up and placed, the vehicle not yet
            # started -- the person watching arranges the windows, then says go
            self.wait_file(outp, "HELD:", 180)
            # Enter here, or the manager's Start (which sends 'go' itself)
            print("\n*** The windows are up and the vehicle is HELD.  Arrange them, then "
                  "press Enter here, or Start in the manager. ***", flush=True)
            interactive = sys.stdin is not None and sys.stdin.isatty()
            if not interactive:
                fly_sts134.crewscript.send_session("go", self.base)   # nobody to ask
            while True:
                with open(outp, errors="replace") as fh:
                    if "released: the vehicle is running" in fh.read():
                        break
                if not interactive:
                    time.sleep(1.0)
                elif os.name == "nt":
                    import msvcrt
                    if msvcrt.kbhit() and msvcrt.getwch() in "\r\n":
                        fly_sts134.crewscript.send_session("go", self.base)
                    time.sleep(0.2)
                else:
                    import select
                    if select.select([sys.stdin], [], [], 1.0)[0]:
                        sys.stdin.readline()
                        fly_sts134.crewscript.send_session("go", self.base)
            self.wait_file(outp, "released: the vehicle is running", 120)
            self.say("released by the user; the vehicle is running")
        time.sleep(5)
        threading.Thread(target=self.monitor, daemon=True).start()
        self.cw_start()

    def zero_sensor_bias(self, capdir):
        """--zero-sensor-bias: GLQREN's four sensor bias INITs -- COAS, RR
        angles, RR range/range rate, S TRK -- set to 0.0 in a capture's
        memory image -- AN EXPERIMENT, pending Ron's decision on the real
        I-loads (RENDEZVOUS_PLAN.md 5b, 5d); the tape is not touched.  Only
        the INIT cells: a sensor whose set has already come in holds the 1.0
        in CGNV_SENSOR_BIAS too, which this does not reach."""
        p = os.path.join(capdir, "gpc1.mem.bin")
        m = bytearray(open(p, "rb").read())
        done, already, odd = [], [], []
        for name, hw in SENSOR_BIAS_INIT:
            a = 2 * hw
            was = struct.unpack(">4H", bytes(m[a:a + 8]))
            if was == (0, 0, 0, 0):
                already.append(name)
            elif was == IBM_ONE * 2:
                m[a:a + 8] = bytes(8)
                done.append(name)
            else:
                odd.append("%s %s" % (name, " ".join("%04X" % x for x in was)))
        if odd:
            self.say("zero-sensor-bias: %s holds %s, not this tape's 1.0, 1.0 -- NOT patched (another tape's map?)"
                     % (capdir, "; ".join(odd)))
            return
        a = 2 * (CGNV_SENSOR_BIAS_HW + 4)
        if struct.unpack(">4H", bytes(m[a:a + 8])) == IBM_ONE * 2:
            m[a:a + 8] = bytes(8)
            done.append("CGNV_SENSOR_BIAS$(3,4) (the range set already in)")
        if done:
            open(p, "wb").write(m)
            self.say("zero-sensor-bias: %s 1.0, 1.0 -> 0.0, 0.0 in %s -- an EXPERIMENT pending the I-load "
                     "decision, not the tape's value%s" % (", ".join(done), capdir,
                                                          "; already 0: " + ", ".join(already) if already else ""))
        else:
            self.say("zero-sensor-bias: %s already holds 0.0 in all four (%s)" % (capdir, ", ".join(already)))
        self.bias_zeroed = True

    def lambert_mc(self, capdir):
        """--lambert-mc: CGZB_LAMB_ILOAD set ON for TGT 11-14 and 19 in a
        capture's memory image -- AN EXPERIMENT, pending Ron's decision on
        the flight's I-loads (that the flight's were ON is inferred: MC2's
        elevation angle only works in GWR); the tape is not touched."""
        p = os.path.join(capdir, "gpc1.mem.bin")
        m = bytearray(open(p, "rb").read())
        was = {}
        for n in LAMBERT_MC_SETS:
            a = 2 * (LAMB_ILOAD_HW + n - 1)
            was[n] = struct.unpack(">H", bytes(m[a:a + 2]))[0]
            m[a:a + 2] = struct.pack(">H", 1)
        if struct.unpack(">10H", bytes(m[2 * LAMB_ILOAD_HW:2 * LAMB_ILOAD_HW + 20])) != (1,) * 10:
            self.say("lambert-mc: %s does not hold sets 1-10 ON at X'%05X' -- NOT patched (another tape's map?)"
                     % (capdir, LAMB_ILOAD_HW))
            return
        open(p, "wb").write(m)
        self.say("lambert-mc: CGZB_LAMB_ILOAD for TGT %s, was %s, now ON at X'%05X' in %s -- an EXPERIMENT "
                 "pending the I-load decision, not the tape's value"
                 % (", ".join(str(n) for n in LAMBERT_MC_SETS), [was[n] for n in LAMBERT_MC_SETS],
                    LAMB_ILOAD_HW, capdir))
        self.lambert_patched = True

    def dass_iloads(self, capdir):
        """--dass-iloads: STS-134's own I-loads (DASS_G2.ASC's PATCH SUMMARY,
        the MM column) written into a capture's memory image, for the csects
        of the groups named (DASS_GROUPS) -- only words that still hold the
        load module's LM value, so a cell the run has since changed is left
        alone.  The tape is not touched.  A range/range-rate bias pair
        already copied into CGNV_SENSOR_BIAS (RNDZ NAV ENA) as the LM's 1.0,
        1.0 goes to the MM's 0 with it, as --zero-sensor-bias does."""
        prefixes = []
        for g in self.a.dass_iloads.split(","):
            prefixes += DASS_GROUPS.get(g, (g if g.startswith("#") else "#" + g,))
        p = os.path.join(capdir, "gpc1.mem.bin")
        m = bytearray(open(p, "rb").read())
        n_set, n_mm, odd, by = 0, 0, [], {}
        rrdot_init = 2 * 0xB47A
        rrdot_was = bytes(m[rrdot_init:rrdot_init + 8])
        for a, cs, lm, mm in dass_patches(self.a.dass):
            if not any(cs.startswith(x) for x in prefixes):
                continue
            t = struct.unpack(">H", bytes(m[2 * a:2 * a + 2]))[0]
            if t == mm:
                n_mm += 1
            elif t == lm:
                m[2 * a:2 * a + 2] = struct.pack(">H", mm)
                n_set += 1
                by[cs] = by.get(cs, 0) + 1
            else:
                odd.append("%s X'%05X' %04X (LM %04X MM %04X)" % (cs, a, t, lm, mm))
        a = 2 * (CGNV_SENSOR_BIAS_HW + 4)
        if (rrdot_was == struct.pack(">4H", *(IBM_ONE * 2)) and bytes(m[rrdot_init:rrdot_init + 8]) == bytes(8)
                and struct.unpack(">4H", bytes(m[a:a + 8])) == IBM_ONE * 2):
            m[a:a + 8] = bytes(8)
            n_set += 2
            by["CGNV_SENSOR_BIAS$(3,4)"] = 2
        open(p, "wb").write(m)
        self.say("dass-iloads %s: %d halfwords LM -> MM in %s (%s); %d already MM; %d changed by the run, "
                 "left%s -- STS-134's own I-loads (%s), not the tape's"
                 % (self.a.dass_iloads, n_set, capdir, ", ".join("%s %d" % kv for kv in sorted(by.items())),
                    n_mm, len(odd), (": " + "; ".join(odd[:12])) if odd else "", os.path.basename(self.a.dass)))
        self.dass_patched = True
        if any(cs.startswith(("#DGLQREN",)) for cs in by) or "CGNV_SENSOR_BIAS$(3,4)" in by:
            self.bias_zeroed = True
        if "#PCGZMC2" in by:
            self.lambert_patched = True

    # --- CAUTION AND WARNING ------------------------------------------------
    # The C&W lights PASS drives (dap_lamps.CW: the GNC class-2 lights, BACKUP
    # C/W ALARM, the SM alert tone bit), watched from the MDM words: every
    # change logged (driver.out and rndz-check.log), so an unexpected caution
    # shows; and the tone acknowledged -- MASTER ALARM, and MSG RESET for the
    # class-2 lights -- when every light on is one the flight expects
    # (self.cw_known: IMU once [10A] has deselected one).  The pressing is
    # done between steps (wait_sim, the manual pilot's loop), never from the
    # watcher's thread: a play stops the one under way.  The simulator runs
    # with its audio on, so an unexpected alarm is heard.
    def cw_start(self):
        try:
            from dap_lamps import CwLamps
        except ImportError:
            return
        if not hasattr(self, "cw_known"):
            self.cw_known = set()
            # resumed past [10A]: its IMU caution (the deselect, and the RM
            # dilemma of captures flown before the thresholds were seeded)
            fr = getattr(self.a, "from_", None)
            if fr in PHASES and "STRKNAV" in PHASES and PHASES.index(fr) > PHASES.index("STRKNAV"):
                self.cw_known.add("IMU")
        self.cw_pending = False
        if getattr(self, "cw", None) is None:
            self.cw = CwLamps(self.base)
            threading.Thread(target=self.cw_watch, daemon=True).start()

    def cw_log(self, text):
        self.say(text)
        try:
            self.checklog.write("%s %s\n" % (time.strftime("%H:%M:%S"), text))
            self.checklog.flush()
        except (AttributeError, OSError, ValueError):
            pass

    def cw_watch(self):
        from dap_lamps import TONES
        last, tone_was = None, False
        while True:
            time.sleep(2.0)
            try:
                on = set(self.cw.lit())
            except Exception:
                continue
            if last is None or on != last:
                gmt = ""
                try:
                    gmt = " (GMT %.0f)" % self.ears.snap()[0]["gmt"]
                except Exception:
                    pass
                self.cw_log("C&W: lit %s%s%s" % (", ".join(sorted(on)) or "nothing", gmt,
                                                  "" if last is None else "; +%s -%s" % (
                                                      ", ".join(sorted(on - last)) or "0",
                                                      ", ".join(sorted(last - on)) or "0")))
            tone = any(t in on for t in TONES)
            cautions = on - set(TONES)
            if tone and not tone_was:
                unknown = cautions - self.cw_known
                if unknown:
                    self.cw_log("C&W: ALARM, NOT ACKNOWLEDGED -- unexpected: %s" % ", ".join(sorted(unknown)))
                else:
                    self.cw_pending = True
            tone_was = tone
            last = on

    def cw_ack(self, why=""):
        """MASTER ALARM (and MSG RESET for latched class-2 lights) if the
        watcher has a known alarm waiting, or always if why is given."""
        if not (getattr(self, "cw_pending", False) or why):
            return
        self.cw_pending = False
        on = set(self.cw.lit()) if getattr(self, "cw", None) else set()
        # MSG RESET twice when latched lights are to be reset: a pending
        # class-5 message (ILLEGAL ENTRY) absorbs the first (DMTERR.hal:766-788)
        script = "+1     press master_alarm\n" + ("+2     keys MSG_RESET\n+3     keys MSG_RESET\n"
                                                  if on - {"BACKUP C/W ALARM", "SM ALERT TONE"} else "")
        n = getattr(self, "_cw_n", 0) + 1
        self._cw_n = n
        self.play(script, "cw-ack-%d" % n)
        self.script_done("cw-ack-%d" % n, 60)
        self.cw_log("crew: MASTER ALARM%s%s (lit: %s)" % (", MSG RESET" if "MSG_RESET" in script else "",
                                                           " -- " + why if why else "",
                                                           ", ".join(sorted(on)) or "nothing"))
        try:
            mem = self.probe("cw-ack-%d" % n)
            if mem:
                self.cw_log("fault summary: " + " | ".join(mem.fault_summary()[-4:]))
        except Exception as e:
            self.cw_log("fault summary: unreadable (%s)" % e)

    def wait_sim(self, dt):
        self.cw_ack()
        fly_sts134.Flight.wait_sim(self, dt)

    def seed_imu_rm(self, capdir):
        """PASS's IMU attitude RM thresholds seeded in a capture's memory
        image where they are still zero (IMU_RM_SEED); the tape untouched."""
        p = os.path.join(capdir, "gpc1.mem.bin")
        m = bytearray(open(p, "rb").read())
        done, have = [], []
        for src, dst, what in IMU_RM_SEED:
            if bytes(m[2 * dst:2 * dst + 4]) != bytes(4):
                have.append(what)
                continue
            m[2 * dst:2 * dst + 4] = m[2 * src:2 * src + 4]
            done.append("%s %.3g" % (what, groundstation.from_ibm_short(
                list(struct.unpack(">2H", bytes(m[2 * dst:2 * dst + 4]))))))
        if done:
            open(p, "wb").write(m)
        self.say("IMU RM thresholds: %s%s" % ("seeded in %s: %s" % (os.path.basename(capdir), "; ".join(done))
                                              if done else "already set",
                                              "" if not have or not done else " (already set: %s)" % ", ".join(have)))
        self.imu_rm_seeded = True

    def imu_sel(self, label):
        """CGUB_IMU_SEL_MFE now (a probe capture), or None."""
        mem = self.probe("imu-%s" % label)
        return mem.hw(IMU_SEL_HW)[0] if mem else None

    def imu1_select(self, want, label):
        """IMU 1 selected (want True) or deselected, by SPEC 21 ITEM 7 -- a
        TOGGLE -- keyed only while CGUB_IMU_SEL_MFE disagrees, and checked."""
        for attempt in range(3):
            sel = self.imu_sel("%s-%d" % (label, attempt))
            if sel is None:
                self.say("IMU 1 (%s): CGUB_IMU_SEL_MFE unreadable -- ITEM 7 keyed blind" % label)
            elif bool(sel & 4) == want:
                self.say("IMU 1 (%s): %s (CGUB_IMU_SEL_MFE %d)" % (label, "selected" if want else "deselected",
                                                                 sel))
                return True
            self.strk_keys("+1     keys SPEC 2 1 PRO\n"
                           "+5     keys ITEM 7 EXEC\n"
                           "+3     keys RESUME\n", "imu1-%s-%d" % (label, attempt))
            self.wait_sim(6)
            if sel is None:
                return None
        self.say("IMU 1 (%s): STILL NOT %s" % (label, "selected" if want else "deselected"))
        return False

    def restart_from(self, name):
        """The simulation ended and started again from one of its own
        captures (for --zero-sensor-bias on a fresh run: the UPLINK one,
        patched)."""
        fly_sts134.crewscript.send_session("quit", self.base)
        try:
            self.proc.wait(timeout=180)
        except subprocess.TimeoutExpired:
            self.proc.kill()
            self.proc.wait()
        self.say("restarting from sts134r-%s" % name)
        self.start(os.path.join(self.a.logs, "sts134r-" + name))
        self.wait_sim(20)

    def met_now(self):
        return self.truth()["gmt"] - (gmt_of_unix(MET_ZERO_UNIX))

    def wait_unix(self, u):
        self.wait_gmt(gmt_of_unix(u))

    # --- the checks, all through the run -------------------------------------
    def compare(self):
        """PASS's relative state and the truth's, now; and the -Z axis to
        the ISS.  None until both feeds and the downlist have spoken."""
        tru, tgt, dl = self.ears.snap()
        if not tru or not tgt:
            return None
        out = {"gmt": tru["gmt"]}
        rng, rdot = range_rate(tru["r"], tru["v"], tgt["r"], tgt["v"])
        out["true_rng_ft"], out["true_rdot_fts"] = rng / FT, rdot / FT
        los = vsub(tgt["r"], tru["r"])
        mz = [-c for c in body_axis(tru["q"], 2)]
        out["minusZ_to_iss_deg"] = math.degrees(math.acos(max(-1, min(1, vdot(mz, los) / vnorm(los)))))
        cyc = self.ears.cycle
        if cyc and cyc.get("t_state"):
            ts = cyc["t_state"]
            ro, vo, rt, vt = cyc["ro"], cyc["vo"], cyc["rt"], cyc["vt"]
            prng, prdot = range_rate(ro, vo, rt, vt)
            out.update(pass_rng_ft=prng, pass_rdot_fts=prdot, pass_t_state=ts,
                       pass_states=(ro, vo, rt, vt))
            to, tt = self.ears.truth_at("orbiter", ts), self.ears.truth_at("target", ts)
            # R/V_TARGET ride in frame 5, 0.2 s after frame 0's T_STATE; when
            # the navigation's cycle turns over between them the two states
            # are of different times (seen: a 24 kft "error", ~1 s of orbital
            # speed).  Such a cycle is not a comparison; keep the last good one.
            # The TARGET's error is the test: R/V_TARGET are the ones that
            # come late, and PASS's target state stays within a few hundred
            # feet of the truth, while a turnover moves it ~24 kft.  The
            # Orbiter's own error is no test -- it grew past 2 kft by Ti - 29
            # min in m1-run4, and from there every comparison was refused and
            # the log repeated the last good one for the rest of the run.
            if to and tt and vnorm(vsub(rt, [x / FT for x in tt[0]])) > 8000.0:
                for k in [k for k in out if k.startswith("pass_")]:
                    del out[k]
                out.update(getattr(self, "_last_good", {}))
                return out
            if to and tt:
                trng, trdot = range_rate(to[0], to[1], tt[0], tt[1])
                out.update(truth_rng_at_ts_ft=trng / FT, truth_rdot_at_ts_fts=trdot / FT,
                           orb_err_ft=vnorm(vsub(ro, [x / FT for x in to[0]])),
                           tgt_err_ft=vnorm(vsub(rt, [x / FT for x in tt[0]])),
                           truth_states_at_ts=([x / FT for x in to[0]], [x / FT for x in to[1]],
                                               [x / FT for x in tt[0]], [x / FT for x in tt[1]]))
                # the Orbiter's navigation error in its own LVLH (x along, y
                # -orbit normal, z down): ft and ft/s
                tr_, tv_ = [x / FT for x in to[0]], [x / FT for x in to[1]]
                ez = [-x / vnorm(tr_) for x in tr_]
                h = [tr_[1] * tv_[2] - tr_[2] * tv_[1], tr_[2] * tv_[0] - tr_[0] * tv_[2],
                     tr_[0] * tv_[1] - tr_[1] * tv_[0]]
                ey = [-x / vnorm(h) for x in h]
                ex = [ey[1] * ez[2] - ey[2] * ez[1], ey[2] * ez[0] - ey[0] * ez[2], ey[0] * ez[1] - ey[1] * ez[0]]
                dr, dvv = vsub(ro, tr_), vsub(vo, tv_)
                out.update(orb_dr_lvlh=[vdot(dr, e) for e in (ex, ey, ez)],
                           orb_dv_lvlh=[vdot(dvv, e) for e in (ex, ey, ez)])
                self._last_good = {k: v for k, v in out.items() if k not in ("gmt", "true_rng_ft",
                                   "true_rdot_fts", "minusZ_to_iss_deg")}
        return out

    def monitor(self):
        last = -1e9
        while True:
            time.sleep(2.0)
            try:
                c = self.compare()
            except Exception as e:      # never let the log take the flight down
                self.say("monitor: %s" % e)
                continue
            if not c or c["gmt"] - last < self.a.check_every:
                continue
            last = c["gmt"]
            line = ("GMT %.0f (Ti %+.1f min): truth RNG %.1f ft RDOT %+.3f ft/s; -Z to ISS %.2f deg"
                    % (c["gmt"], (c["gmt"] - self.ti_gmt) / 60.0, c["true_rng_ft"], c["true_rdot_fts"],
                       c["minusZ_to_iss_deg"]))
            if "truth_rng_at_ts_ft" in c:
                line += ("\n      at PASS's T_STATE %.2f: PASS RNG %.1f RDOT %+.4f, truth RNG %.1f RDOT %+.4f "
                         "(diff %+.1f ft %+.4f ft/s); |PASS - truth| orbiter %.0f ft, target %.0f ft"
                         % (c["pass_t_state"], c["pass_rng_ft"], c["pass_rdot_fts"], c["truth_rng_at_ts_ft"],
                            c["truth_rdot_at_ts_fts"], c["pass_rng_ft"] - c["truth_rng_at_ts_ft"],
                            c["pass_rdot_fts"] - c["truth_rdot_at_ts_fts"], c["orb_err_ft"], c["tgt_err_ft"]))
                line += ("\n      orbiter nav error LVLH: %+.1f %+.1f %+.1f ft, %+.4f %+.4f %+.4f ft/s"
                         % tuple(c["orb_dr_lvlh"] + c["orb_dv_lvlh"]))
            self.say("check: " + line)

    def snapshot(self, name):
        if name == "hold" and getattr(self, "_hold_captured", False):
            # HOLD takes its own capture during the steady hold
            # (rndz_manual.hold); the run loop's later one would be of an
            # unpiloted vehicle
            self._hold_captured = False
            return None
        if name.upper() in PHASES:
            self.save_state()
        return self._snapshot(name)

    def ground_check(self, name, sol):
        """The onboard solution against the ground's -- the precision
        Lambert from the truth at COMPUTE T1, standing in for MCC's tracking
        -- by the final-ground limits Ti uses (DVX 1.3, DVY 1.3, DVZ 1.1
        ft/s, p. 4-14).  p. 1-3 has MC1-MC4 fly the onboard solution; that
        presumes converged navigation, which here, without the rendezvous
        radar, the star tracker's angles alone do not give after a
        midcourse (RENDEZVOUS_PLAN.md 5c), so with --mc-rule limits (the
        default) MCC's solution is burned when the onboard one is outside
        the limits: its EXT DVs keyed on ORBIT MNVR EXEC (TIG, ITEMs 10-13;
        DVX/Y/Z, ITEMs 19-21) before LOAD.  --mc-rule onboard: always the
        onboard one, as the book has it.  Returns the keys (or "")."""
        prop, gnd = sol.get("DISP_DV_LVLH"), (sol.get("lambert") or {}).get("truth")
        sol["flown"] = "onboard"
        if sol.get("ALARM_KILL"):
            # GWR stopped (CGZB_ALARM_KILL; the display's PRED MATCH 999999):
            # the DVs shown are the previous solution's, and the MNVR display
            # gets nothing new -- there is no onboard solution to burn
            if not gnd or self.a.mc_rule != "limits":
                self.say("%s FINAL: COMPUTE T1 ended in ALARM KILL -- no onboard solution%s; no burn"
                         % (name, "" if gnd else " and no ground one"))
                sol["flown"] = "none (ALARM KILL)"
                return None
            self.say("%s FINAL: COMPUTE T1 ended in ALARM KILL -- no onboard solution; the ground's %+.2f %+.2f "
                     "%+.2f ft/s burned as EXT DVs" % (name, *gnd))
            within = False
        elif not prop or not gnd:
            self.say("%s: no ground solution to compare; onboard flown" % name)
            return ""
        else:
            within = None
        if within is None:
            diff = [prop[i] - gnd[i] for i in range(3)]
            within = all(abs(diff[i]) <= lim for i, lim in enumerate((1.3, 1.3, 1.1)))
            self.say("%s FINAL: onboard (SV SEL %s) %+.2f %+.2f %+.2f, ground %+.2f %+.2f %+.2f ft/s: %s"
                 % (name, {0: "PROP", 1: "FLTR"}.get(self.strk_watch().sv_sel_bit(), "?"), *prop, *gnd,
                        "onboard within the limits -- burn onboard" if within else
                        ("onboard outside the limits -- %s" % ("burn the ground solution's EXT DVs"
                                                               if self.a.mc_rule == "limits" else
                                                               "burned anyway (--mc-rule onboard)"))))
        if within or self.a.mc_rule != "limits":
            return ""
        sol["flown"] = "ground"
        d, h, m_, sx = dhms_f(sol["T1_TIG_MET"])
        return ("+3     keys ITEM 1 0 + %d + %s + %s + %s EXEC\n"
                "+4     keys ITEM 1 9 %s %s %s EXEC\n"
                % (d, " ".join("%d" % h), " ".join("%d" % m_), " ".join("%.1f" % sx),
                   keys_num(gnd[0], "%.1f"), keys_num(gnd[1], "%.1f"), keys_num(gnd[2], "%.1f")))

    def _snapshot(self, name):
        """A capture, as fly_sts134's -- but one that does not come is not
        the end of the flight: tried twice, then noted and flown on."""
        import shutil
        old = os.path.join(self.a.logs, "sts134r-" + name)
        if os.path.isdir(old):            # a capture of that name is replaced, never read stale
            shutil.rmtree(old)
        for attempt in (1, 2):
            try:
                return super().snapshot(name)
            except SystemExit as e:
                self.say("capture %s failed (attempt %d): %s" % (name, attempt, e))
        self.say("NO CAPTURE for %s; flying on" % name)

    def dump_screen(self, what):
        txt = self.ears.screen("crt1")
        self.say("CRT 1, %s:\n%s" % (what, "\n".join("    | " + l for l in txt.splitlines() if l.strip())))
        return txt

    # --- the phases ---------------------------------------------------------
    IPL_SCRIPT = """
+0     gpc 1
+0     mode HALT
+0.02  idppower 1 on
+0.01  script {panel}/examples/ipl-one-gpc.script gpc=1 crt=1 idp=1 kb=KB1
+11    keys ITEM 1 + 2 EXEC
+8     keys ITEM 2 + 1 EXEC
+8     keys ITEM 7 + 1 EXEC
+8     keys ITEM 8 + 1 EXEC
+8     keys ITEM 9 + 1 EXEC
+8     keys ITEM 1 0 + 1 EXEC
+8     keys ITEM 1 1 + 1 EXEC
+8     keys ITEM 1 2 + 1 EXEC
+8     keys ITEM 1 8 + 1 EXEC
+8     keys ITEM 1 9 + 1 EXEC
+21    keys OPS 2 0 1 PRO
wait crt 1 title 2011/ timeout 600
+20    dap c3 free
+10    keys SPEC 2 1 PRO
+5     keys ITEM 4 EXEC
+3     keys ITEM 5 EXEC
+3     keys ITEM 6 EXEC
+15    keys RESUME
+5     dap c3 a
+2     dap c3 auto
+2     dap c3 vern
"""

    def ipl(self):
        self.play(self.IPL_SCRIPT.format(panel=PANEL), "ipl")
        self.script_done("ipl", 1500)
        self.say("OPS 201, IMUs in OPERATE, DAP A/AUTO/VERN")
        self.wait_sim(10)
        # RNDZ OPS INITIALIZATION [5A] (p. 4-5) comes at PET -2:45, before
        # this run's start; its "Config DAP A,B to A7,B7" is done here
        self.dap_config("[5A]")

    def spec20_page(self, name):
        """SPEC 20 up and its page read (two looks a few seconds apart, so a
        page still being drawn is not taken for the values)."""
        self.play("+1     keys SPEC 2 0 PRO\n"
                  "wait crt 1 title /020/ timeout 120\n", name)
        self.script_done(name, 180)
        last = None
        for _ in range(10):
            self.wait_sim(4)
            page = self.ears.screen("crt1")
            if "DAP CONFIG" in page and page == last:
                break
            last = page
        return page

    def dap_config(self, label):
        """"Config DAP A,B to A7,B7" on SPEC 20 DAP CONFIG: DAP A - ITEM 1
        +7, DAP B - ITEM 2 +7, and the page checked against p. 6-2.

        THIS TAPE'S A7 AND B7 ARE NOT THE FLIGHT'S.  Its 15 + 15 stored
        configurations are generic I-loads (read off the format-22 downlist's
        rotating CGCV_DAP_DL_PRM, 2026-10-08): A7 has ALT RATE DB 0.200 and
        VERN ROT RATE 0.2000 where 6-2 has 0.10 and 0.016, B7 ALT RATE DB
        0.200 where 6-2 has 0.10; the rest agree.  The flight's I-loads held
        6-2's values, so as with TGT 10 the crew keys the difference -- into
        the stored configuration (DAP EDIT: DAP A - ITEM 3 +7, the edit
        column's item 50 + row, LOAD - ITEM 5; the same with DAP B - ITEM 4),
        so that A7 and B7 themselves are 6-2's and any later "Config DAP A,B
        to A7,B7" gives them -- and then selects them.  A deviation, logged."""
        page = self.spec20_page("dap-spec20-%s" % label.strip("[]"))
        sel, vals = parse_spec20(page)
        self.dump_screen("SPEC 20 DAP CONFIG (%s), as found" % label)
        keys = ""
        if sel != {"A": "07", "B": "07"}:
            keys += "+3     keys ITEM 1 + 7 EXEC\n+3     keys ITEM 2 + 7 EXEC\n"
        if keys:
            self.play("+1" + keys[2:], "dap-select-%s" % label.strip("[]"))
            self.script_done("dap-select-%s" % label.strip("[]"), 120)
            # script_done means the last line STARTED: its keystrokes are
            # still being typed, and the next SPEC 20 PRO cut ITEM 2 + 7 off
            # (m1c-run1's first try, B left at B01)
            self.wait_sim(6)
            page = self.spec20_page("dap-spec20b-%s" % label.strip("[]"))
            sel, vals = parse_spec20(page)
        edits = ""
        for side, item, edit in (("A", 1, 3), ("B", 2, 4)):
            bad = dap_mismatch(vals, side)
            if not bad:
                continue
            base = 10 if side == "A" else 30
            self.say("DAP %s7 on this tape differs from 6-2: %s -- keyed (DAP EDIT, LOAD)"
                     % (side, "; ".join("%s (item %d) %s, 6-2 %s" % (DAP_ROWS[i - base], i, g, w)
                                        for i, (g, w) in sorted(bad.items()))))
            edits += "+3     keys ITEM %d + 7 EXEC\n" % edit
            for i, (got, want) in sorted(bad.items()):
                row = i - base
                if isinstance(want, str):
                    self.say("DAP %s7 %s: the option %s is not keyed (an option item cycles); left %s"
                             % (side, DAP_ROWS[row], want, got))
                    continue
                edits += "+3     keys ITEM %s %s EXEC\n" % (" ".join(str(50 + row)),
                                                           keys_short(want, DAP_FMT[row]))
            edits += "+3     keys ITEM 5 EXEC\n"
        if edits:
            edits += "+3     keys ITEM 1 + 7 EXEC\n+3     keys ITEM 2 + 7 EXEC\n"
            self.play("+1" + edits[2:], "dap-edit-%s" % label.strip("[]"))
            self.script_done("dap-edit-%s" % label.strip("[]"), 300)
            self.wait_sim(6)
            page = self.spec20_page("dap-spec20c-%s" % label.strip("[]"))
            sel, vals = parse_spec20(page)
        # a keystroke can be lost: the selection checked and keyed again
        for attempt in range(3):
            if sel == {"A": "07", "B": "07"}:
                break
            self.say("DAP CONFIG (%s): SPEC 20 shows A%s B%s; DAP A/B - ITEM 1/2 +7 keyed again"
                     % (label, sel.get("A"), sel.get("B")))
            name = "dap-reselect-%s-%d" % (label.strip("[]"), attempt)
            self.play("+1     keys ITEM 1 + 7 EXEC\n+3     keys ITEM 2 + 7 EXEC\n", name)
            self.script_done(name, 120)
            self.wait_sim(6)
            page = self.spec20_page(name + "-page")
            sel, vals = parse_spec20(page)
        self.dump_screen("SPEC 20 DAP CONFIG (%s), A7/B7" % label)
        bad = {s: dap_mismatch(vals, s) for s in ("A", "B")}
        mem = self.probe("dap-%s" % label.strip("[]").lower())
        ds = mem.dap_selected() if mem else None
        _, _, dl = self.ears.snap()
        self.say("DAP CONFIG (%s): SPEC 20 shows DAP A%s B%s, %s; PASS's memory: DAP_LOAD_SEL A %s B %s, "
                 "selected DAP's MAG_MNVR_RATE %s, ALT RATE DB %s, ALT jets %s, ALT ON TIME %s; downlist "
                 "LOAD_SEL A %s B %s, SEL_ALT_RATE_LIMIT %s"
                 % (label, sel.get("A"), sel.get("B"),
                    "every item as p. 6-2" if not (bad["A"] or bad["B"]) else "STILL DIFFERENT: %s" % bad,
                    *((ds["A"], ds["B"], "%.4f" % ds["MNVR_RATE"], "%.3f" % ds["ALT_RATE_LIMIT"],
                       ds["ALT_MAX_JETS"], "%.2f" % ds["ALT_ON_TIME"]) if ds else ("?",) * 6),
                    dl.get("CGCV_DAP_LOAD_SEL_A"), dl.get("CGCV_DAP_LOAD_SEL_B"),
                    dl.get("CGCV_SEL_ALT_RATE_LIMIT")))
        self.play("+1     keys RESUME\n", "dap-resume-%s" % label.strip("[]"))
        self.script_done("dap-resume-%s" % label.strip("[]"), 60)

    @property
    def iloads(self):
        """TGT sets 1-14 as this tape's I-loads hold them (the IPL capture)."""
        if not hasattr(self, "_iloads"):
            mem = PassMemory.from_capture(os.path.join(self.a.logs, "sts134r-ipl"))
            self._iloads = {k: mem.iload(k) for k in range(1, 15)} if mem else {}
            if mem:
                self.say("this tape's orbit-targeting I-loads (IPL capture): TGT 9 %s; TGT 10 %s; "
                         "target mass/CD/area %s" % (self._iloads[9], self._iloads[10],
                                                     mem.orbit_tgt()["TARGET_MASS_CD_AREA"]))
        return self._iloads

    def uplink(self):
        link = groundstation.Link(self.base)
        link.send_message(groundstation.two_stage(groundstation.OP_RNP, list(RNP)))
        self.say("ground: RNP epoch %d day %d (message 59)" % RNP)
        time.sleep(5)
        for verb in ("sv", "tsv"):
            out = subprocess.run([sys.executable, os.path.join(PANEL, "groundstation.py"), "--port-base",
                                  str(self.base), verb], check=True, capture_output=True, text=True).stdout
            self.say("ground: " + out.strip().splitlines()[0 if verb == "sv" else 1])
            time.sleep(5)
        self.wait_sim(20)

    def rndznav(self):
        if ((self.a.zero_sensor_bias and not getattr(self, "bias_zeroed", False))
                or (self.a.lambert_mc and not getattr(self, "lambert_patched", False))
                or (self.a.dass_iloads and not getattr(self, "dass_patched", False))
                or not getattr(self, "imu_rm_seeded", False)):
            if self.a.attach:
                self.say("zero-sensor-bias: attached to a running vehicle -- its memory cannot be patched here")
            else:
                # the UPLINK capture, just taken, patched and flown on from
                self.restart_from("uplink")
        # ENABLE RENDEZVOUS NAV [7A]
        self.play("+1     keys SPEC 3 3 PRO\n+5     keys ITEM 1 EXEC\n", "rndz-nav-ena")
        self.script_done("rndz-nav-ena", 120)
        self.wait_sim(10)
        self.dump_screen("SPEC 33 after RNDZ NAV ENA")
        d, h, m, s = dhms(self.ti_met)
        script = ("+1     keys SPEC 3 4 PRO\n"
                  "+5     keys ITEM 1 + 1 EXEC\n"
                  "+4     keys ITEM 2 1 + %d + %s + %s + %s EXEC\n"
                  "+4     keys ITEM 2 6 EXEC\n"
                  % (d, " ".join("%d" % h), " ".join("%d" % m), " ".join("%d" % s)))
        self.play(script, "tgt1-base")
        self.script_done("tgt1-base", 120)
        self.wait_sim(5)
        self.dump_screen("SPEC 34, TGT 1, BASE TIME %03d/%02d:%02d:%02d MET loaded" % (d, h, m, s))

    def track(self):
        # -Z AXIS TARGET TRACK [12A] (and LOAD TARGET TRACK [9A]'s CNCL first)
        script = ("+1     keys RESUME\n"
                  "+3     keys ITEM 2 1 EXEC\n"
                  "+3     keys ITEM 8 + 1 EXEC\n"
                  "+3     keys ITEM 1 4 + 3 EXEC\n"
                  "+3     keys ITEM 1 7 + 0 EXEC\n"
                  "+3     dap c3 b\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 1 9 EXEC\n")
        self.play(script, "target-track")
        self.script_done("target-track", 120)
        self.wait_sim(5)
        self.dump_screen("UNIV PTG, TRK")
        self.track_complete("dap-a-vern")

    def track_complete(self, name, limit=1200.0):
        """[12A] "When MNVR cmplt, DAP: A/AUTO/VERN(ALT)": the -Z axis on the
        ISS, then the verniers hold it."""
        t0 = self.truth()["t"]
        still = 0
        while True:
            c = self.compare()
            if c and c["minusZ_to_iss_deg"] < 2.0:
                break
            # PASS points -Z where ITS state puts the ISS: with the state
            # kilofeet off (mc-run2 after MC3: 34 deg) the truth angle never
            # comes down, so the maneuver is also complete when the vehicle
            # is no longer maneuvering -- body rate under 0.1 deg/s for ~15 s
            # (the maneuver rates are A7's 0.2 and B7's 0.5 deg/s; the track
            # itself turns at about orbital rate, 0.06 deg/s, so "stopped"
            # at 0.02 never came: mc-run6's MC4 waited 20 min and missed TIG)
            tru = self.ears.snap()[0]
            el = self.truth()["t"] - t0
            if tru and el > 60 and math.degrees(vnorm(tru["w"])) < 0.1:
                still += 1
                if still >= 3:
                    self.say("TRACK: the vehicle has stopped turning with -Z %.2f deg from the ISS (PASS's own "
                             "state of the ISS is that far off)" % (c or {}).get("minusZ_to_iss_deg", -1))
                    break
            else:
                still = 0
            if el > limit:
                self.say("TRACK: the maneuver did not complete in %.0f min" % (limit / 60.0))
                break
            time.sleep(5)
        self.play("+1     dap c3 a\n+2     dap c3 auto\n+2     dap c3 vern\n", name)
        self.script_done(name, 60)
        self.say("crew: MNVR complete (-Z %.2f deg from the ISS); DAP A/AUTO/VERN"
                 % (self.compare() or {}).get("minusZ_to_iss_deg", -1))

    def probe(self, name):
        """PASS's memory now: a capture, read (the IDP's part of it is not
        needed, so a capture the IDP fails to join still serves)."""
        self.snapshot(name)
        return PassMemory.from_capture(os.path.join(self.a.logs, "sts134r-" + name),
                                       os.path.join(self.a.logs, "logs", "snapshot-staging"))

    def tgt10(self, label):
        return self.target(10, label)

    def target(self, n, label, base_met=None):
        """TARGET <burn>: SPEC 34 TGT NO n; the set checked against the
        checklist's (TGT_SETS) and, where it differs, keyed and LOADed;
        COMPUTE T1; then the solution, and the states it was computed from,
        read out of PASS's memory and set beside the independent Lambert.
        base_met: first a new BASE TIME (MET s, whole seconds) keyed and
        LOADed -- "BASETIME = MC2 TIG" for TGT 13 and 14 (p. 4-19), and the
        slipped MC2's TGT 19.  Each step is checked in memory before the
        next: an item entry can be lost (one TGT NO 10, keyed five seconds
        after SPEC 34 was called from UNIV PTG, never arrived, and COMPUTE T1
        then solved TGT 1's empty set).

        THE T1 TIG OF A SET is an I-load in minutes after BASE TIME
        (GKQORB case 1: T1 TIG = BASE + 60 T1_ILOAD); keying T1 TIG (items
        2-5) and LOAD stores T1 TIG - BASE back into it (case 2, step 155),
        so the set's own T1 survives a later reselection, as an I-load
        would."""
        want = TGT_SETS[n]
        tag = "tgt%d-%s" % (n, label)
        if n != 10:
            self.sv_sel_check(tag)
        if base_met is not None:
            d, h, m, s_ = dhms(base_met)
            self.play("+1     keys SPEC 3 4 PRO\n"
                      "wait crt 1 title /034/ timeout 120\n"
                      "+3     keys ITEM 2 1 + %d + %s + %s + %s EXEC\n"
                      "+4     keys ITEM 2 6 EXEC\n"
                      % (d, " ".join("%d" % h), " ".join("%d" % m), " ".join("%d" % s_)), tag + "-base")
            self.script_done(tag + "-base", 180)
            self.wait_sim(5)
        for attempt in range(3):
            self.play("+1     keys SPEC 3 4 PRO\n"
                      "wait crt 1 title /034/ timeout 120\n"
                      "+3     keys ITEM 1 + %s EXEC\n" % " ".join(str(n)), "%s-%d" % (tag, attempt))
            self.script_done("%s-%d" % (tag, attempt), 180)
            self.wait_sim(5)
            mem = self.probe(tag)
            if mem and mem.orbit_tgt()["TGT_NO"] == n:
                break
            self.say("TGT NO %d not taken (attempt %d); keying it again" % (n, attempt + 1))
        else:
            self.say("TGT NO %d was never taken; no COMPUTE T1 (%s)" % (n, label))
            return None
        ot = mem.orbit_tgt()
        if base_met is not None:
            self.say("BASE TIME for TGT %d (%s): keyed MET %03d/%02d:%02d:%02d; PASS has %03d/%02d:%02d:%06.3f"
                     % (n, label, *dhms(base_met), *dhms_f(ot["BASE_TIME_MET"])))
        il = mem.iload(n)
        el_deg = math.degrees(il["EL"])
        # an elevation-angle set's T1 is GWR's to change: its search puts
        # BASE TIME and T1 TIG at the time it finds and zeroes the set's T1
        # I-load (GWRORB step 140) -- the "BASETIME = MC2 TIG" that TGT 13
        # and 14 then count from -- so a zero there is PASS's, not a lost set
        t1_ok = abs(il["T1"] - want["T1"]) < 0.01 or (want["EL"] != 0.0 and abs(il["T1"]) < 1e-6
                                                       and abs(el_deg - want["EL"]) < 0.005)
        ok = (abs(il["DT"] - want["DT"]) < 0.05 and abs(el_deg - want["EL"]) < 0.005 and t1_ok
              and all(abs(il[k] - want[k]) < 0.005 for k in ("DX", "DY", "DZ")))
        self.say("TGT %d as selected (%s): T1 %+.2f min after BASE, EL %.2f deg, DT %.1f, DX %+.2f DY %+.2f "
                 "DZ %+.2f kft -- %s" % (n, label, il["T1"], el_deg, il["DT"], il["DX"], il["DY"], il["DZ"],
                                         "as the checklist" if ok else
                 "NOT the checklist's (T1 %+.2f, EL %.2f, DT %.1f, DX %+.1f DY %+.1f DZ %+.1f); the crew keys the "
                 "set and LOADs it -- a deviation: the flight's I-loads held it"
                 % (want["T1"], want["EL"], want["DT"], want["DX"], want["DY"], want["DZ"])))
        for attempt in range(3):
            if ok:
                break
            t1 = ot["BASE_TIME_MET"] + 60.0 * want["T1"]
            d, h, m, s_ = dhms(t1)
            script = ("+1     keys ITEM 2 + %d + %s + %s + %s EXEC\n"
                      % (d, " ".join("%d" % h), " ".join("%d" % m), " ".join("%d" % s_))
                      if not t1_ok else "")
            script += ("+4     keys ITEM 6 %s EXEC\n"
                       "+4     keys ITEM 1 7 %s EXEC\n"
                       "+4     keys ITEM 1 8 %s %s %s EXEC\n"
                       "+4     keys ITEM 2 6 EXEC\n"
                       % (keys_num(want["EL"], "%.2f"), keys_num(want["DT"], "%.1f"),
                          keys_num(want["DX"], "%.2f"), keys_num(want["DY"], "%.2f"),
                          keys_num(want["DZ"], "%.2f")))
            self.play("+1" + script[2:], "%s-set-%d" % (tag, attempt))
            self.script_done("%s-set-%d" % (tag, attempt), 120)
            self.wait_sim(5)
            mem = self.probe(tag + "-loaded")
            il = mem.iload(n)
            el_deg = math.degrees(il["EL"])
            t1_ok = abs(il["T1"] - want["T1"]) < 0.01 or (want["EL"] != 0.0 and abs(il["T1"]) < 1e-6
                                                           and abs(el_deg - want["EL"]) < 0.005)
            ok = (t1_ok and abs(il["DT"] - want["DT"]) < 0.05 and abs(el_deg - want["EL"]) < 0.005
                  and all(abs(il[k] - want[k]) < 0.005 for k in ("DX", "DY", "DZ")))
            self.say("TGT %d after LOAD (%s, attempt %d): T1 %+.2f min, EL %.2f, DT %.1f, DX %+.2f DY %+.2f DZ %+.2f; "
                     "T1 TIG MET %03d/%02d:%02d:%06.3f%s"
                     % (n, label, attempt + 1, il["T1"], el_deg, il["DT"], il["DX"], il["DY"], il["DZ"],
                        *dhms_f(mem.orbit_tgt()["T1_TIG_MET"]), "" if ok else " -- an entry was lost; keyed again"))
        before = self.compare()
        old = mem.orbit_tgt()
        old_sig = (tuple(old["DISP_DV_LVLH"]), old["DISP_MISS"], old["T1_TIG_MET"], old["T2_TIG_MET"])
        self.play("+1     keys ITEM 2 8 EXEC\n", "compute-t1-%s" % tag)
        self.script_done("compute-t1-%s" % tag, 60)
        for wait in range(16):
            self.wait_sim(8)
            mem = self.probe("sol-" + tag)
            # done when GK3 is no longer queued or active
            # (CGZB_COMP_QUEUED_ACTIVE_GK3) AND the solution has changed.
            # CGZV_MAN_TGT_NO is no test (it stayed 11 through every later
            # Lambert set, mc-run3, and each COMPUTE waited out all its
            # looks), and the flag alone is not either: mc-run5's TGT 19 was
            # taken as done 8 s after COMPUTE with MC1's DVs still shown
            new = mem.orbit_tgt()
            sig = (tuple(new["DISP_DV_LVLH"]), new["DISP_MISS"], new["T1_TIG_MET"], new["T2_TIG_MET"])
            if not mem.hw(0xDE16)[0] and (sig != old_sig or
                                          struct.unpack(">h", mem.m[2 * 0xDE32:2 * 0xDE32 + 2])[0] == n):
                break
            if wait == 7 and not mem.hw(0xDE16)[0]:
                # neither working nor changed after a minute: the ITEM 28
                # was lost -- keyed again
                self.say("COMPUTE T1 (TGT %d, %s): nothing changed in a minute; ITEM 28 keyed again" % (n, label))
                self.play("+1     keys ITEM 2 8 EXEC\n", "compute-t1-%s-again" % tag)
                self.script_done("compute-t1-%s-again" % tag, 60)
        else:
            self.say("COMPUTE T1 (TGT %d, %s): no new solution seen -- the display's is a previous one's" % (n, label))
        self.dump_screen("after COMPUTE T1 (TGT %d, %s)" % (n, label))
        sol = mem.orbit_tgt()
        dv = sol["DISP_DV_LVLH"]
        tig = sol["T1_TIG_MET"]
        self.say("PASS's COMPUTE T1, TGT %d (%s): T1 TIG MET %03d/%02d:%02d:%06.3f (GMT %.3f, Ti %+.2f min), "
                 "DT %.2f min, T2 offset %+.3f %+.3f %+.3f kft, EL %.3f deg;\n"
                 "      DVX %+.2f DVY %+.2f DVZ %+.2f DVT %.2f ft/s  (alarm kill %s, miss %.1f; SV SEL %s)"
                 % (sol["TGT_NO"], label, *dhms_f(tig), sol["T1_TIG_GMT"],
                    (sol["T1_TIG_GMT"] - self.ti_gmt) / 60.0, sol["COMP_PROX_DT"] / 60.0,
                    *(x / 1000.0 for x in sol["COMP_T2_OFF"]), math.degrees(sol["EL"]),
                    dv[0], dv[1], dv[2], sol["DV_MAG"], sol["ALARM_KILL"], sol["DISP_MISS"],
                    {0: "PROP", 1: "FLTR"}.get(self.strk_watch().sv_sel_bit(), "?")))
        sol["lambert"] = self.lambert_check(label, before, sol)
        json.dump(sol, open(os.path.join(self.a.logs, "%s.json" % tag), "w"), indent=1)
        if n == 10:
            json.dump(sol, open(os.path.join(self.a.logs, "ti-%s.json" % label), "w"), indent=1)
        return sol

    def lambert_check(self, label, c, sol):
        """rndz_start.py lambert from PASS's own states -- the Orbiter at T1
        TIG (CGZV_RS/VS_T1TIG) and the target at T2 (CGZV_TARGET_M50) as GWR
        left them -- and from the truth when COMPUTE T1 was keyed."""
        runs = [("PASS's own (GWR's RS/VS_T1TIG, TARGET_M50 at T2)",
                 sol["T1_TIG_GMT"], sol["RS_T1TIG"] + sol["VS_T1TIG"],
                 sol["TARGET_T_FIN"], sol["TARGET_R_FIN"] + sol["TARGET_V_FIN"])]
        if c and "truth_states_at_ts" in c:
            ro, vo, rt, vt = c["truth_states_at_ts"]
            runs.append(("the truth at COMPUTE T1", c["pass_t_state"], ro + vo, c["pass_t_state"], rt + vt))
        offset = [x / 1000.0 for x in sol["COMP_T2_OFF"]]
        res = {}
        for name, go, so, gt, stt in runs:
            args = [sys.executable, os.path.join(YAGPC2, "tools", "rndz_start.py"), "lambert",
                    "--orb", "%.4f" % go] + ["%.4f" % x for x in so] + \
                   ["--tgt", "%.4f" % gt] + ["%.4f" % x for x in stt] + \
                   ["--tig", "%.3f" % sol["T1_TIG_GMT"], "--dt", "%.6f" % (sol["COMP_PROX_DT"] / 60.0),
                    "--offset", "%.6f,%.6f,%.6f" % tuple(offset)]
            out = subprocess.run(args, capture_output=True, text=True)
            self.say("independent Lambert from %s (%s):\n%s%s"
                     % (name, label, out.stdout.rstrip(), out.stderr.rstrip()))
            m = re.search(r"precision.*DVX\s+([-+\d.]+)\s+DVY\s+([-+\d.]+)\s+DVZ\s+([-+\d.]+)", out.stdout)
            if m:
                res["PASS" if name.startswith("PASS") else "truth"] = [float(x) for x in m.groups()]
        return res

    def ti(self):
        # [13A] Preliminary at PET -0:55; [15A] Final at TIG - 17 min -- in
        # OPS 201 when the burn is not to be flown (M1); otherwise the final
        # targeting is TIBURN's, in OPS 202, as the checklist has it
        burn = not self.a.to or PHASES.index(self.a.to) >= PHASES.index("TIBURN")
        for label, before in (("preliminary", 55 * 60.0),) + ((() if burn else (("final", 17 * 60.0),))):
            if self.truth()["gmt"] < self.ti_gmt - before:
                self.wait_gmt(self.ti_gmt - before)
            self.say("== TARGET Ti BURN (%s), Ti %+.1f min" % (label, (self.truth()["gmt"] - self.ti_gmt) / 60.0))
            self.tgt10(label)

    def orbiter_lb(self):
        """The truth's mass, for the burn pad's WT (lb): the newest
        vehdyn-state line."""
        for line in reversed(self.log_text().splitlines()):
            m = re.search(r"vehdyn-state:.*mass_kg=([\d.]+)", line)
            if m:
                return float(m.group(1)) / 0.45359237
        return ORBITER_KG / 0.45359237

    def tiburn(self):
        """TARGET Ti BURN [15A] (Final) and RNDZ OMS BURN (CONTINGENCY OPS
        5-4), the burn the checklist calls for when DVT > 6 ft/s (p. 4-15):
        step 1, SPEC 20 "DAP config A7,B7" checked, then at TIG - 17 min OPS
        202 PRO; step 2, ORBIT MNVR EXEC: L OMS (ITEM 2), the trims (ITEMs
        6-8) and WT (ITEM 9) "per Burn Pad" -- the pad (p. 3-7) is filled in
        by MCC and blank in the book, so the trims are the OMS 2/ORBIT OMS
        BURNS card's one-engine values and TV ROLL is left at PASS's own --
        LOAD (ITEM 22); SPEC 34 TGT 10, COMPUTE T1, which in MM 202 hands its
        PEG 7 solution to the MNVR display; LOAD, TIMER, DAP A/AUTO/ALT, MNVR
        (ITEM 27); step 3, the card: DAP TRANS NORM, EXEC at TIG - 15 s, at
        cutoff the residuals trimmed (trim_residuals); step 4, post-burn: DAP
        B/INRTL/ALT, DAP TRANS PULSE/PULSE/PULSE, RCS SEL - ITEM 4; then
        coast() for OPS 201 and step 5.  Not modelled, so not done: FLT
        CNTLR PWR, the He PRESS/VAP ISOL valves, the OMS TVC gimbal check."""
        tig = self.ti_gmt
        if self.truth()["gmt"] < tig - 19 * 60.0:
            self.wait_gmt(tig - 19 * 60.0)
        # 5-4 step 1: "1: GNC 20 DAP CONFIG / CRT1 DAP config A7,B7"
        self.dap_config("5-4")
        if self.truth()["gmt"] < tig - 17 * 60.0:
            self.wait_gmt(tig - 17 * 60.0)
        wt = self.orbiter_lb()
        trims = self.one_engine_trims()
        self.play("+1     keys OPS 2 0 2 PRO\n"
                  "wait crt 1 title 2021/ timeout 180\n"
                  "+3     keys ITEM 2 EXEC\n" + trims +
                  "+4     keys ITEM 9 + %s EXEC\n"
                  "+4     keys ITEM 2 2 EXEC\n" % " ".join("%d" % round(wt)), "ops202")
        self.script_done("ops202", 300)
        self.say("crew: OPS 202, L OMS, trims, WT %d lb, LOAD" % round(wt))
        sol = self.tgt10("final") or {}
        self.burns["Ti final"] = sol or None
        # FINAL SOLUTION (p. 4-15 and the burn solution rules, p. 1-3): with
        # no sensor pass there is no FLTR solution; burn PROP if it is within
        # the final-ground limits (DVX 1.3, DVY 1.3, DVZ 1.1 ft/s, p. 4-14) of
        # the ground's -- here the precision Lambert from the truth, standing
        # in for MCC's tracking -- else the ground solution's EXT DVs
        prop, gnd = sol.get("DISP_DV_LVLH"), (sol.get("lambert") or {}).get("truth")
        keyed = ""
        if prop and gnd:
            diff = [prop[i] - gnd[i] for i in range(3)]
            within = all(abs(diff[i]) <= lim for i, lim in enumerate((1.3, 1.3, 1.1)))
            self.say("FINAL Ti: onboard (SV SEL %s) %+.2f %+.2f %+.2f, ground %+.2f %+.2f %+.2f ft/s: %s"
                     % ({0: "PROP", 1: "FLTR"}.get(self.strk_watch().sv_sel_bit(), "?"), *prop, *gnd,
                        "onboard within the limits -- burn onboard" if within else
                        "onboard outside the limits -- burn the ground solution's EXT DVs"))
            if not within:
                d, h, m_, sx = dhms_f(self.ti_met)
                keyed = ("+3     keys ITEM 1 0 + %d + %s + %s + %s EXEC\n"
                         "+4     keys ITEM 1 9 %s %s %s EXEC\n"
                         % (d, " ".join("%d" % h), " ".join("%d" % m_), " ".join("%.1f" % sx),
                            keys_num(gnd[0], "%.1f"), keys_num(gnd[1], "%.1f"), keys_num(gnd[2], "%.1f")))
        self.play("+1     keys RESUME\n"
                  "wait crt 1 title 2021/ timeout 60\n"
                  # 5-4 step 2, "Eng sel ... per Burn Pad": checked again after
                  # COMPUTE T1, which in MM 202 re-initialises the MNVR display
                  # -- the first run's L OMS did not survive it, and both
                  # engines burned (2026-10-08)
                  "+3     keys ITEM 2 EXEC\n" + trims +
                  "+4     keys ITEM 9 + %s EXEC\n" % " ".join("%d" % round(wt)) + keyed +
                  "+3     keys ITEM 2 2 EXEC\n"
                  "+4     keys ITEM 2 3 EXEC\n"
                  "+3     dap c3 a\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 2 7 EXEC\n"
                  # the OMS 2/ORBIT OMS BURNS card: "DAP TRANS - NORM (MM202)"
                  "+3     dap c3 x_norm\n"
                  "+2     dap c3 y_norm\n"
                  "+2     dap c3 z_norm\n", "ti-mnvr")
        self.script_done("ti-mnvr", 180)
        mem = self.probe("ti-loaded")
        self.say("crew: Ti burn LOADed, TIMER, MNVR to burn attitude")
        self.wait_gmt(tig - 15.0)
        tr0 = self.truth()
        self.play("+0     keys EXEC\n", "ti-exec")
        self.say("crew: EXEC at TIG-15 s (TIG GMT %.1f)" % tig)
        self.wait_gmt(tig + 60.0)
        after = self.probe("ti-cutoff")
        v0, v1 = self.vehdyn_capture("ti-loaded"), self.vehdyn_capture("ti-cutoff")
        if v0 and v1:
            dv = [(v1["sensed"][i] - v0["sensed"][i]) / FT for i in range(3)]
            self.say("Ti burn: the truth's sensed delta-V %.2f ft/s (M50 %+.2f %+.2f %+.2f); OMS on "
                     "L %.2f s, R %.2f s" % (vnorm(dv), *dv, v1["oms_s"][0] - v0["oms_s"][0],
                                            v1["oms_s"][1] - v0["oms_s"][1]))
        if after:
            self.say("Ti burn: residuals VGO %+.2f %+.2f %+.2f ft/s (body)" % tuple(after.svec(after.A["VGO_BODY"])))
        self.trim_residuals()
        # 5-4 step 4, OMS POST BURN RECONFIGURATION
        self.play("+1     dap c3 b\n"
                  "+2     dap c3 inrtl\n"
                  "+2     dap c3 alt\n"
                  "+2     dap c3 x_pulse\n"
                  "+2     dap c3 y_pulse\n"
                  "+2     dap c3 z_pulse\n"
                  "+3     keys ITEM 4 EXEC\n", "ti-postburn")
        self.script_done("ti-postburn", 120)
        self.say("crew: post burn -- DAP B/INRTL/ALT, DAP TRANS PULSE/PULSE/PULSE, RCS SEL - ITEM 4")
        del mem, tr0

    def one_engine_trims(self):
        """The trims for a single-engine burn, ITEMs 6-8 (5-4 step 2, "TRIM
        LOAD ... per Burn Pad"; the pad, p. 3-7, is MCC's and blank in the
        book): the OMS 2/ORBIT OMS BURNS card's "1 engine: P = +0.4 LY = +5.2
        RY = -5.2" (ASC-6a/134/A,O/A), which the crew checks before every
        orbit OMS burn ("GMBL TRIM").  PASS's own one-engine I-loads on this
        tape (CGGC02) differ in pitch -- P -0.1, LY +5.21 -- and are logged
        beside them.  Without one-engine trims at all m1b-run2 burned the
        left engine on the two-engine ones (P +0.4, LY -5.75), and the burn
        ended with VGO Y -2.15 and Z +1.01 ft/s."""
        mem = PassMemory.from_capture(os.path.join(self.a.logs, "sts134r-ti"),
                                      os.path.join(self.a.logs, "sts134r-ipl"))
        if mem:
            self.say("one-engine trims: the card's P %+.1f LY %+.1f RY %+.1f; PASS's I-loads P %+.2f Y %+.2f"
                     % (OMS_1ENG_TRIMS["P"], OMS_1ENG_TRIMS["LY"], OMS_1ENG_TRIMS["RY"],
                        mem.sp(mem.A["ONE_ENG_TRIM_P"]), mem.sp(mem.A["ONE_ENG_TRIM_Y"])))
        return "+4     keys ITEM 6 %s %s %s EXEC\n" % tuple(keys_num(OMS_1ENG_TRIMS[k], "%.1f")
                                                         for k in ("P", "LY", "RY"))

    def vehdyn_capture(self, name):
        """The truth in a capture: the sensed delta-V (m/s, M50) and each OMS
        engine's burning seconds (vehdyn_save's order)."""
        try:
            b = json.load(open(os.path.join(self.a.logs, "sts134r-" + name, "vehdyn.json")))["vehdyn"]
        except (OSError, ValueError, KeyError):
            return None
        i = 3 + 3 + 3 + 4 + 3 + 5                # version, have, t, r, v, q, w, propellant
        sensed = b[i:i + 3]
        i += 3 + 2 * 44                           # on[], onSec[]
        return {"sensed": sensed, "oms_s": (b[i + 6], b[i + 13])}

    def trim_residuals(self):
        return self.null_vgo("ti", 6)

    def null_vgo(self, label, passes):
        """Null VGO with the THC, DAP TRANS NORM: the Ti burn's residuals
        ("Trim Residuals: ... Orbit: All axes < 0.2 fps", OMS 2/ORBIT OMS
        BURNS) and the whole of a multi-axis RCS burn (RCS BURN, CC 9-3, step
        5: "If VGO Z is neg, Z,X,Y seq; otherwise, X,Y,Z.  THC: Trim VGOs <
        0.2 fps").  VGO is the MNVR display's, body axes (CGZV_VGO, CGZ123),
        from the format-22 downlist; the THC's directions are the orbiter's
        (+z down), so each VGO is flown in its own sign.

        ONE CONTINUOUS MANEUVER.  Each pass flies every axis still over 0.2
        ft/s, in the card's order, back to back in one script -- each hold the
        VGO over the direction's acceleration (THC_ACC_SEED, then what the
        last hold did to VGO, kept from burn to burn in self.thc_acc) -- then
        VGO is read again and the next pass follows at once.  The gaps matter:
        PASS's navigation (GL5NAV steps 7-9C) sums the sensed velocity over a
        "maneuver" -- jets fired in every 3.84 s cycle -- and when a cycle
        passes without jets, a sum under 0.9 ft/s is REMOVED from the state.
        mc-run1's first MC1 (2026-10-08) nulled one axis at a time with a
        capture between holds; each hold, 0.2-0.6 ft/s, was its own maneuver,
        all were removed, and the FLTR state, the burn missing from it, was
        walked off 8 kft by the marks that followed.  Returns the last VGO."""
        acc = getattr(self, "thc_acc", None) or dict(THC_ACC_SEED)
        self.thc_acc = acc
        w = self.strk_watch()
        measured = {}
        count0 = w.get("CGNV_DV_COUNT")

        def read_vgo():
            v = [w.get("CGZV_VGO$%d" % i) for i in (1, 2, 3)]
            if all(isinstance(x, float) for x in v):
                return dict(zip("xyz", v))
            mem = self.probe("%s-vgo" % label)
            return dict(zip("xyz", mem.svec(mem.A["VGO_BODY"]))) if mem else None

        vgo = read_vgo()
        if vgo is None:
            self.say("VGO NULL (%s): VGO not readable; nothing flown" % label)
            return None
        for n in range(passes + 1):
            if all(abs(v) < TRIM_TOL_FPS for v in vgo.values()):
                break
            if n == passes:
                self.say("VGO NULL (%s): VGO %+.2f %+.2f %+.2f -- not all < %.1f fps after %d passes"
                         % (label, vgo["x"], vgo["y"], vgo["z"], TRIM_TOL_FPS, passes))
                break
            order = "zxy" if vgo["z"] < 0 else "xyz"
            holds = []
            for ax in order:
                v = vgo[ax]
                if abs(v) < TRIM_TOL_FPS:
                    continue
                key = ("+" if v > 0 else "-") + ax
                holds.append((ax, key, v, min(max(abs(v) / acc[key], 0.1), 12.0)))
            lines, gap = [], 0.0
            for ax, key, v, hold in holds:
                lines.append("+%.2f   thc fwd %s %.2f" % (gap, key, hold))
                gap = hold + 0.3
            self.say("VGO NULL (%s) pass %d: VGO %+.2f %+.2f %+.2f ft/s; THC %s"
                     % (label, n, vgo["x"], vgo["y"], vgo["z"],
                        ", ".join("%s %.2f s (%.3f ft/s^2)" % (k.upper(), h, acc[k]) for _, k, _, h in holds)))
            name = "%s-null-%d" % (label, n)
            self.play("\n".join(lines) + "\n", name)
            self.script_done(name, 120)
            self.wait_sim(holds[-1][3] + 1.5)       # the last hold runs on after the script ends
            new = read_vgo() or vgo
            for ax, key, v, hold in holds:
                dv = abs(v - new[ax])
                if dv > 0.03:
                    measured.setdefault(key, []).append(dv / hold)
                    acc[key] = min(max(dv / hold, 0.05), 3.0)
            vgo = new
        if label != "ti" and self.a.pulse_trim > 0 and vgo and all(abs(v) < TRIM_TOL_FPS for v in vgo.values()):
            vgo = self.pulse_trim(label, vgo, read_vgo)
        count1 = w.get("CGNV_DV_COUNT")
        self.say("VGO NULL (%s): VGO %+.2f %+.2f %+.2f ft/s%s; THC acceleration measured (ft/s^2): %s; PASS's "
                 "accepted maneuvers (CGNV_DV_COUNT) %s -> %s"
                 % (label, vgo["x"], vgo["y"], vgo["z"],
                    " -- all axes < %.1f fps" % TRIM_TOL_FPS if all(abs(v) < TRIM_TOL_FPS for v in vgo.values())
                    else "", {k: ["%.3f" % x for x in v] for k, v in measured.items()}, count0, count1))
        return vgo

    def pulse_trim(self, label, vgo, read_vgo):
        """A midcourse's last residuals in DAP TRANS PULSE: one A7 pulse
        (PRI TRAN PLS, 0.10 ft/s) per THC deflection, for each axis still at
        --pulse-trim ft/s or more, all axes back to back (one GL5NAV
        maneuver); up to three passes.  The card's "Trim VGOs < 0.2 fps"
        is met before this starts; a midcourse is itself only 0.3-2 ft/s,
        and rr-run3's MC4 left -0.14 ft/s of body X that the card allowed --
        0.13 ft/s along the V-bar, 85 ft of the arrival's 228 ft shortfall
        over its 13-minute transfer (RENDEZVOUS_PLAN.md 5e)."""
        tol = self.a.pulse_trim
        pulse = DAP_RNDZ["A"][17]
        self.play("+1     dap c3 x_pulse\n+2     dap c3 y_pulse\n+2     dap c3 z_pulse\n", label + "-pulse")
        self.script_done(label + "-pulse", 60)
        for n in range(3):
            todo = [(ax, vgo[ax]) for ax in "xyz" if abs(vgo[ax]) >= tol]
            if not todo:
                break
            lines, plan = [], []
            for ax, v in todo:
                k = max(1, int(round(abs(v) / pulse)))
                plan.append("%s%s x%d" % ("+" if v > 0 else "-", ax.upper(), k))
                for _ in range(k):
                    lines.append("+1.0   thc fwd %s%s 0.30" % ("+" if v > 0 else "-", ax))
            self.say("PULSE TRIM (%s) pass %d: VGO %+.2f %+.2f %+.2f ft/s; THC pulses %s"
                     % (label, n, vgo["x"], vgo["y"], vgo["z"], ", ".join(plan)))
            name = "%s-pulse-%d" % (label, n)
            self.play("\n".join(lines) + "\n", name)
            self.script_done(name, 120)
            self.wait_sim(2.0)
            vgo = read_vgo() or vgo
        self.say("PULSE TRIM (%s): VGO %+.2f %+.2f %+.2f ft/s" % (label, vgo["x"], vgo["y"], vgo["z"]))
        return vgo

    TRACK_KEYS = ("+3     keys ITEM 2 1 EXEC\n"
                  "+3     keys ITEM 8 + 1 EXEC\n"
                  "+3     keys ITEM 1 4 + 3 EXEC\n"
                  "+3     keys ITEM 1 7 + 0 EXEC\n"
                  "+3     dap c3 b\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 alt\n"
                  "+3     keys ITEM 1 9 EXEC\n")

    def ops201_track(self, name, limit=1200.0):
        """OPS 201 PRO and the -Z target track again ([12A], [18D]): UNIV
        PTG TGT ID 1, BODY VECT 3, OM 0, DAP B/AUTO/ALT, TRK; then, the -Z
        axis on the ISS, DAP A/AUTO/VERN.  The verniers matter: the first
        M1b run left DAP B/ALT holding the track with the primaries for the
        whole coast, which [12A] does not, and whose translations move the
        truth itself."""
        self.play("+1     keys OPS 2 0 1 PRO\n"
                  "wait crt 1 title 2011/ timeout 180\n" + self.TRACK_KEYS, name)
        self.script_done(name, 300)
        self.say("crew: OPS 201, -Z target track")
        self.track_complete(name + "-vern", limit)

    def coast(self):
        """After Ti with --no-mc: OPS 201, the -Z target track again, and the
        coast toward the MC4 region, T2 = TIG + 76.9 min, MC1-MC4 not flown
        (the M1b baseline).  Where the truth arrives is logged against TGT
        10's aim point (-0.9 kft behind, 1.8 kft below)."""
        self.ops201_track("post-ti-track")
        t2 = self.ti_gmt + TGT10["DT"] * 60.0
        stop = min(t2, self.ti_gmt + self.a.coast_min * 60.0)
        self.log_rel_until(stop, "coast")
        self.say("coast: ended at Ti %+.1f min" % ((self.truth()["gmt"] - self.ti_gmt) / 60.0))

    def log_rel_until(self, stop_gmt, what, every=30.0):
        last = None
        while self.truth()["gmt"] < stop_gmt:
            time.sleep(every / max(self.a.rate, 1.0))
            tru, tgt, _ = self.ears.snap()
            if tru and tgt:
                last = self.rel_now(tru, tgt, what)
        return last

    # --- MC1-MC4 (RENDEZVOUS_PLAN.md, Stage 2) -------------------------------
    def postti(self):
        """After the Ti burn (p. 4-16, 4-17): OPS 201 and -Z target track;
        TARGET MC1 BURN [17A] (Preliminary) "when MNVR to att cmplt"; POST Ti
        NAV [16A] and STAR TRACKER NAV [10A] again, the pass running on until
        MC1's final targeting; [17A] (Intermediate) "when NAV converged".
        --no-mc: the old COAST instead."""
        if self.a.no_mc:
            self.coast()
            return
        self.ops201_track("post-ti-track")
        self.mc_tig[11] = self.ti_gmt + TGT_SETS[11]["T1"] * 60.0
        self.say("== TARGET MC1 BURN [17A] (preliminary), Ti %+.1f min" % self.ti_min())
        self.burns["MC1 preliminary"] = self.target(11, "preliminary")
        if getattr(self, "rr_active", False):
            self.rr_again(self.mc_tig[11] - 9 * 60.0)
        else:
            self.strknav(again=True, until_gmt=self.mc_tig[11] - 9 * 60.0)
        if self.truth()["gmt"] < self.mc_tig[11] - 9 * 60.0:
            self.say("== TARGET MC1 BURN [17A] (intermediate), Ti %+.1f min" % self.ti_min())
            self.burns["MC1 intermediate"] = self.target(11, "intermediate")

    def sv_sel_check(self, what):
        """"CRT \u221aSV SEL correct" (every TARGET block, pp. 4-17 to 4-20):
        the post-Ti star tracker pass ([10A]) starts on PROP and goes to
        FLTR "when SV UPDATE POS < 1.0 and Angle ACPT > 9" -- which, the
        targeting coming soon after Ti, is usually reached between TARGET
        blocks rather than while [10A] waits; so each block checks it."""
        w = self.strk_watch()
        if getattr(self, "rr_active", False):
            if w.sv_sel_bit() != 0:
                return
            ok, n, pos = self.rr_converged()
            if ok:
                self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                               "+5     keys ITEM 4 EXEC\n", "sv-sel-fltr-%s" % what)
                self.wait_sim(8)
            self.say("SV SEL check (%s, radar): RNG ACPT %d this pass, SV UPDATE POS %s kft -- %s"
                     % (what, n, _f(pos), "SV SEL - ITEM 4 (FLTR): bit %s" % w.sv_sel_bit() if ok else "PROP"))
            return
        acc0 = getattr(self, "pass_acc0", None)
        if acc0 is None or w.sv_sel_bit() != 0:
            return
        acc = w.accepts()
        pos = w.get("CGNV_R_MEAS_RSS")
        if min(acc[i] - acc0[i] for i in (0, 1)) > 9 and isinstance(pos, float) and pos < 1.0:
            self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                           "+5     keys ITEM 4 EXEC\n", "sv-sel-fltr-%s" % what)
            self.wait_sim(8)
            self.say("SV SEL check (%s): converged (ACPT %d/%d this pass, SV UPDATE POS %.3f kft) -- SV SEL - "
                     "ITEM 4 (FLTR): bit %s" % (what, acc[0] - acc0[0], acc[1] - acc0[1], pos, w.sv_sel_bit()))
        else:
            self.say("SV SEL check (%s): PROP, the pass not yet converged (ACPT %d/%d this pass, SV UPDATE POS "
                     "%s kft)" % (what, acc[0] - acc0[0], acc[1] - acc0[1], _f(pos)))

    def ti_min(self):
        return (self.truth()["gmt"] - self.ti_gmt) / 60.0

    def mc1(self):
        """MC1: [17A] (Final) and RCS BURN; then TARGET MC2 [17B]
        (Preliminary), and MANUAL OUT-OF-PLANE NULL [19A] "when Y = 0"."""
        if self.a.no_mc:
            return
        self.rcs_burn(11, "MC1", self.mc_tig[11])
        self.say("== TARGET MC2 [17B] (preliminary), Ti %+.1f min" % self.ti_min())
        sol = self.target(12, "preliminary")
        self.burns["MC2 preliminary"] = sol
        self.mc_tig[12] = self.mc2_tig_slip(sol)
        self.oop_null(self.mc_tig[12] - 14 * 60.0)

    def mc2_tig_slip(self, sol):
        """MC2's TIG for the schedule: PASS's, within the slip limits of
        [18B] ("IF TIG CHANGE < -3 OR > +7 MIN": nominal -3 or +7 min, which
        TGT 19 then flies); the elevation search can land a revolution or
        more away (mc-run3: Ti + 466.6 min)."""
        nominal = self.ti_gmt + MC2_TIG_NOMINAL_MIN * 60.0
        if not sol:
            return nominal
        slip = (sol["T1_TIG_GMT"] - nominal) / 60.0
        if -3.0 <= slip <= 7.0:
            return sol["T1_TIG_GMT"]
        self.say("MC2 TIG change %+.2f min from nominal: outside -3/+7 -- scheduled at nominal %+d min"
                 % (slip, -3 if slip < -3.0 else 7))
        return nominal + (-3.0 if slip < -3.0 else 7.0) * 60.0

    def mc2(self):
        """MC2: [18A] (Intermediate) when NAV converged, [18B] (Final) at
        about TIG - 5 min -- EL 29.07 deg, GWR iterating the TIG; the TIG
        slip limits (-3, +7 min from nominal: TGT 19, T1 = BASE TIME =
        nominal -3 or +7); FLTR TO PROP; RCS BURN.  Then END S TRK NAV [18C]
        (the ISS sets into the Earth's shadow before MC2; nothing more to
        mark) and [18D] -Z target track."""
        if self.a.no_mc:
            return
        tig = self.mc_tig[12]
        if self.truth()["gmt"] < tig - 12 * 60.0:
            self.wait_gmt(tig - 12 * 60.0)
            self.say("== TARGET MC2 BURN [18A] (intermediate), Ti %+.1f min" % self.ti_min())
            sol = self.target(12, "intermediate")
            self.burns["MC2 intermediate"] = sol
            self.mc_tig[12] = tig = self.mc2_tig_slip(sol)

        def after_final(sol):
            nominal = self.ti_gmt + MC2_TIG_NOMINAL_MIN * 60.0
            slip = (sol["T1_TIG_GMT"] - nominal) / 60.0
            self.say("MC2 TIG change %+.2f min from nominal (Ti + %.2f min)" % (slip, MC2_TIG_NOMINAL_MIN))
            if -3.0 <= slip <= 7.0:
                return sol
            base = nominal + (-3.0 if slip < -3.0 else 7.0) * 60.0
            self.say("MC2: TIG change outside -3/+7 min -- BASE TIME = nominal %+d min, TGT 19"
                     % (-3 if slip < -3.0 else 7))
            return self.target(19, "final", base_met=round(base - gmt_of_unix(MET_ZERO_UNIX)))

        def before_burn(sol):
            # [18B]: "GNC 33 REL NAV: FLTR TO PROP - ITEM 8 EXEC"
            self.strk_keys("+1     keys SPEC 3 3 PRO\n"
                           "+5     keys ITEM 8 EXEC\n"
                           "+3     keys RESUME\n", "mc2-fltr-to-prop")
            self.say("[18B]: FLTR TO PROP - ITEM 8")
        # the slip decided from the latest solution (preliminary or
        # intermediate): a far elevation search re-seeds the next from the
        # BASE TIME it moved (GWRORB step 140), so each later TGT 12 COMPUTE
        # lands further out (mc-run3: +466, +883, +1300 min) -- the final
        # goes straight to TGT 19 rather than through TGT 12 first
        last = self.burns.get("MC2 intermediate") or self.burns.get("MC2 preliminary")
        nominal = self.ti_gmt + MC2_TIG_NOMINAL_MIN * 60.0
        if last and not -3.0 <= (last["T1_TIG_GMT"] - nominal) / 60.0 <= 7.0:
            k = -3.0 if last["T1_TIG_GMT"] < nominal else 7.0
            self.say("MC2: the last solution's TIG change %+.2f min is outside -3/+7 -- [18B] with BASE TIME = "
                     "nominal %+d min and TGT 19" % ((last["T1_TIG_GMT"] - nominal) / 60.0, k))
            sol = self.rcs_burn(19, "MC2", nominal + k * 60.0, before_burn=before_burn,
                                base_met=round(nominal + k * 60.0 - gmt_of_unix(MET_ZERO_UNIX)))
        else:
            sol = self.rcs_burn(12, "MC2", tig, after_final=after_final, before_burn=before_burn)
        self.mc_tig[12] = sol["T1_TIG_GMT"] if sol else tig
        if getattr(self, "rr_active", False):
            self.say("[18C] END S TRK NAV: the star tracker pass ended at RR NAV [13B]; the radar goes on")
        else:
            self.say("== END S TRK NAV [18C], Ti %+.1f min" % self.ti_min())
            self.strkend()

    def mc_base_met(self):
        """"BASETIME = MC2 TIG" (TGT 13, 14), as MET to the whole second."""
        return round(self.mc_tig[12] - gmt_of_unix(MET_ZERO_UNIX))

    def mc3(self):
        """MC3: [19B] (Preliminary), with BASE TIME = MC2 TIG keyed and
        LOADed; (Final) "at MC2 TIG + 14:00 (MC3 TIG - 3:00)"; RCS BURN."""
        if self.a.no_mc:
            return
        base = self.mc_base_met()
        self.mc_tig[13] = base + gmt_of_unix(MET_ZERO_UNIX) + TGT_SETS[13]["T1"] * 60.0
        if self.truth()["gmt"] < self.mc_tig[13] - 12 * 60.0:
            self.say("== TARGET MC3 [19B] (preliminary), Ti %+.1f min; BASE TIME = MC2 TIG" % self.ti_min())
            self.burns["MC3 preliminary"] = self.target(13, "preliminary", base_met=base)
            self.rcs_burn(13, "MC3", self.mc_tig[13])
        else:
            # MC3 comes 17 min after MC2: with MC2's burn, OPS 201 and the
            # track between, the preliminary is dropped when the final is due
            self.say("MC3: no time for the preliminary (Ti %+.1f, TIG Ti %+.1f min); BASE TIME = MC2 TIG "
                     "keyed with the final" % (self.ti_min(), (self.mc_tig[13] - self.ti_gmt) / 60.0))
            self.rcs_burn(13, "MC3", self.mc_tig[13], base_met=base)

    def mc4(self):
        """MC4: [20A] (Preliminary) and (Final); RCS BURN.  The flight
        targeted MC4 on radar navigation (LATE RADAR NAV [20E]); with no
        radar here (Stage 3) it is the star tracker pass's FLTR state,
        propagated since the ISS set -- a deviation, logged."""
        if self.a.no_mc:
            return
        self.mc_tig[14] = self.mc_base_met() + gmt_of_unix(MET_ZERO_UNIX) + TGT_SETS[14]["T1"] * 60.0
        self.say("== TARGET MC4 [20A], Ti %+.1f min (%s)"
                 % (self.ti_min(), "on the radar's FLTR state" if getattr(self, "rr_active", False)
                    else "no rendezvous radar: FLTR state without radar marks -- a deviation"))
        if self.truth()["gmt"] < self.mc_tig[14] - 12 * 60.0:
            self.burns["MC4 preliminary"] = self.target(14, "preliminary")
        else:
            self.say("MC4: no time for the preliminary (TIG Ti %+.1f min)" % ((self.mc_tig[14] - self.ti_gmt) / 60.0))
        self.rcs_burn(14, "MC4", self.mc_tig[14])

    def arrival(self):
        """MC4's T2, TIG + 13 min: "the R-bar, about 600 ft below the ISS".
        The truth's relative state every 30 s to then, the arrival against
        TGT 14's aim point (0, 0, +0.6 kft), and the burns' table."""
        if self.a.no_mc:
            return
        t2 = self.mc_tig[14] + TGT_SETS[14]["DT"] * 60.0
        rel = self.log_rel_until(t2, "arrival", 30.0)
        if rel is None:                     # T2 already past (a late MC4)
            tru, tgt, _ = self.ears.snap()
            rel = self.rel_now(tru, tgt, "arrival") if tru and tgt else None
        if rel:
            sys.path.insert(0, os.path.join(YAGPC2, "tools"))
            import rndz_start
            self.say("ARRIVAL at MC4 + %.1f min: truth %s; TGT 14 aims at X 0, Y 0, Z +600 ft"
                     % ((self.truth()["gmt"] - self.mc_tig[14]) / 60.0, rndz_start.fmt_rel(rel)))
            self.arrival_rel = rel
        self.burn_table()
        self.log_rel_until(t2 + 120.0, "after arrival", 30.0)

    def burn_table(self):
        lines = ["THE BURNS (ft/s, LVLH):",
                 "  %-22s %-24s %-24s %-24s %s" % ("burn", "PASS (onboard)", "Lambert, truth", "checklist mean +-3s",
                                                  "PASS within")]
        for name, sol in self.burns.items():
            if not sol:
                lines.append("  %-22s (no solution)" % name)
                continue
            dv = sol["DISP_DV_LVLH"]
            if sol.get("ALARM_KILL"):
                dv = [float("nan")] * 3          # ALARM KILL: the shown DVs are a previous solution's
            tr = (sol.get("lambert") or {}).get("truth")
            disp = MC_DISPERSIONS.get(sol["TGT_NO"] if sol["TGT_NO"] != 19 else 12)
            within = ("yes" if all(abs(dv[i] - disp[i][0]) <= disp[i][1] for i in range(3)) else "NO") if disp else ""
            if sol.get("ALARM_KILL"):
                within = "ALARM KILL"
            lines.append("  %-22s %+6.2f %+6.2f %+6.2f %-3s %-24s %-24s %s"
                         % (name, dv[0], dv[1], dv[2], "", ("%+6.2f %+6.2f %+6.2f" % tuple(tr)) if tr else "--",
                            ("%+.1f(%.1f) %+.1f(%.1f) %+.1f(%.1f)" % (disp[0] + disp[1] + disp[2])) if disp else "",
                            within))
            sensed = sol.get("sensed_lvlh")
            if sensed:
                lines.append("  %-22s burned the %s solution: truth sensed (LVLH) %+6.2f %+6.2f %+6.2f; VGO left %s"
                             % ("", sol.get("flown", "onboard"), *sensed, sol.get("vgo_left")))
        self.say("\n".join(lines))
        json.dump(self.burns, open(os.path.join(self.a.logs, "burns.json"), "w"), indent=1)

    def rcs_burn(self, n, name, tig_gmt, after_final=None, before_burn=None, base_met=None):
        """RCS BURN (+X, -X, Multi-axis), CC 9-3, for a midcourse: step 1,
        OPS 202 PRO, RCS SEL - ITEM 4; step 2, "If onboard computed burn: TIG
        and TGT PEG 7 Vs per Final solution", the final targeting done in MM
        202 so that COMPUTE T1 hands its solution to the MNVR display (as the
        Ti burn's, which found it so), WT, LOAD - ITEM 22, TIMER - ITEM 23;
        no MNVR (multi-axis: the burn is flown in the -Z track attitude);
        step 4 at TIG - 0:30, DAP A/AUTO/PRI, DAP TRANS NORM; step 5 at TIG,
        "If VGO Z is neg, Z,X,Y seq; otherwise, X,Y,Z / THC: Trim VGOs < 0.2
        fps" (null_vgo), then DAP ALT, DAP TRANS PULSE/PULSE/PULSE, OPS 201
        PRO; steps 6-7, the -Z track and DAP A/AUTO/VERN.  FLT CNTLR PWR is
        not modelled.  The burn solution rules (p. 1-3): MC1-MC4 fly the
        onboard solution; RCS multi-axis below 4 ft/s."""
        # the final targeting -- TGT NO, the set checked, COMPUTE T1, each
        # step confirmed in a capture -- takes 3-6 min of vehicle time at
        # rate 2, and a slipped MC2 two targetings
        lead = 8 * 60.0
        if self.truth()["gmt"] < tig_gmt - lead:
            self.wait_gmt(tig_gmt - lead)
        self.say("== %s: RCS BURN, Ti %+.1f min (TIG Ti %+.2f min)"
                 % (name, self.ti_min(), (tig_gmt - self.ti_gmt) / 60.0))
        wt = self.orbiter_lb()
        wtk = "+4     keys ITEM 9 + %s EXEC\n" % " ".join("%d" % round(wt))
        self.play("+1     keys OPS 2 0 2 PRO\n"
                  "wait crt 1 title 2021/ timeout 180\n"
                  "+3     keys ITEM 4 EXEC\n" + wtk, name.lower() + "-ops202")
        self.script_done(name.lower() + "-ops202", 300)
        self.say("crew: OPS 202, RCS SEL, WT %d lb" % round(wt))
        sol = self.target(n, "final", base_met=base_met)
        if sol and after_final:
            sol = after_final(sol) or sol
        if sol and sol["T1_TIG_GMT"] < self.truth()["gmt"] + 45.0:
            # mc-run2's MC4: its TIG passed while the -Z track waited, and
            # GWR then solved from the minimum TIG over a transfer of -0.6
            # min (52 ft/s)
            self.say("%s: TIG Ti %+.2f min is past or too near (now Ti %+.2f) -- no burn"
                     % (name, (sol["T1_TIG_GMT"] - self.ti_gmt) / 60.0, self.ti_min()))
            self.burns["%s final" % name] = sol
            sol["flown"] = "none (TIG passed)"
            self.ops201_track(name.lower() + "-post")
            return sol
        if not sol:
            self.say("%s: no final solution -- no burn" % name)
            self.ops201_track(name.lower() + "-post")
            return None
        self.burns["%s final" % name] = sol
        dvt = sol["DV_MAG"]
        if dvt >= 4.0:
            self.say("%s: DVT %.2f ft/s -- p. 1-3 would have a +X burn (4-6) or an OMS burn (> 6); flown "
                     "multi-axis here (a deviation)" % (name, dvt))
        if before_burn:
            before_burn(sol)
        keyed = self.ground_check(name, sol)
        if keyed is None:
            self.ops201_track(name.lower() + "-post")
            return sol
        self.play("+1     keys RESUME\n"
                  "wait crt 1 title 2021/ timeout 60\n"
                  "+3     keys ITEM 4 EXEC\n" + wtk + keyed +
                  "+3     keys ITEM 2 2 EXEC\n"
                  "+4     keys ITEM 2 3 EXEC\n", name.lower() + "-load")
        self.script_done(name.lower() + "-load", 180)
        tig = sol["T1_TIG_GMT"]
        mem = self.probe(name.lower() + "-loaded")
        if mem:
            self.say("%s LOADed, TIMER: VGO %+.2f %+.2f %+.2f ft/s (body); TIG Ti %+.2f min"
                     % ((name,) + tuple(mem.svec(mem.A["VGO_BODY"])) + ((tig - self.ti_gmt) / 60.0,)))
        if self.truth()["gmt"] < tig - 30.0:
            self.wait_gmt(tig - 30.0)
        self.play("+1     dap c3 a\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 pri\n"
                  "+2     dap c3 x_norm\n"
                  "+2     dap c3 y_norm\n"
                  "+2     dap c3 z_norm\n", name.lower() + "-tig30")
        self.script_done(name.lower() + "-tig30", 60)
        self.wait_gmt(tig)
        self.say("%s: TIG" % name)
        mark = self.probe(name.lower() + "-tig")
        vgo = self.null_vgo(name.lower(), 6)
        sol["vgo_left"] = ("%+.2f %+.2f %+.2f" % (vgo["x"], vgo["y"], vgo["z"])) if vgo else None
        self.wait_sim(5)
        after = self.probe(name.lower() + "-done")
        v0 = self.vehdyn_capture(name.lower() + "-tig")
        v1 = self.vehdyn_capture(name.lower() + "-done")
        del mark, after
        tru = self.truth()
        if v0 and v1 and tru:
            dv = [(v1["sensed"][i] - v0["sensed"][i]) / FT for i in range(3)]
            ex, ey, ez = self.lvlh_axes(tru["r"], tru["v"])
            sol["sensed_lvlh"] = [vdot(dv, e) for e in (ex, ey, ez)]
            self.say("%s: the truth's sensed delta-V %.2f ft/s, Orbiter LVLH %+.2f %+.2f %+.2f; PASS's "
                     "solution %+.2f %+.2f %+.2f" % (name, vnorm(dv), *sol["sensed_lvlh"], *sol["DISP_DV_LVLH"]))
        self.play("+1     dap c3 alt\n"
                  "+2     dap c3 x_pulse\n"
                  "+2     dap c3 y_pulse\n"
                  "+2     dap c3 z_pulse\n", name.lower() + "-post")
        self.script_done(name.lower() + "-post", 60)
        # after a midcourse the attitude is already near the track's: 5 min
        self.ops201_track(name.lower() + "-track", 300.0)
        return sol

    @staticmethod
    def lvlh_axes(r, v):
        """An orbit's LVLH unit vectors (x along, y -orbit normal, z down)."""
        ez = [-x / vnorm(r) for x in r]
        h = [r[1] * v[2] - r[2] * v[1], r[2] * v[0] - r[0] * v[2], r[0] * v[1] - r[1] * v[0]]
        ey = [-x / vnorm(h) for x in h]
        ex = [ey[1] * ez[2] - ey[2] * ez[1], ey[2] * ez[0] - ey[0] * ez[2], ey[0] * ez[1] - ey[1] * ez[0]]
        return ex, ey, ez

    def oop_null(self, deadline_gmt):
        """MANUAL OUT-OF-PLANE NULL [19A] (p. 4-19): "When Y = 0", from
        PASS's relative state (SPEC 33's Y; here the FLTR state from the
        downlist), DAP A/AUTO/PRI, DAP TRANS as reqd (NORM), "THC: Null YDOT"
        -- one hold along the body axis nearest the orbit normal, for PASS's
        YDOT over that axis's measured acceleration -- then DAP A/AUTO/ALT
        and VERN.  One hold, not a loop: in OPS 201 PASS takes no
        translation under 0.9 ft/s into its state (GL5NAV), so its YDOT does
        not show the null; the marks bring it in.  The truth's YDOT is
        logged before and after."""
        w = self.strk_watch()

        def pass_y():
            with w.lock:
                st = w.rel
            if not st:
                return None
            ex, ey, ez = self.lvlh_axes(st["rt"], st["vt"])
            dr, dv = vsub(st["rf"], st["rt"]), vsub(st["vf"], st["vt"])
            return st["t"], vdot(dr, ey), vdot(dv, ey), ey

        first = pass_y()
        if not first:
            self.say("[19A]: no PASS relative state on the downlist; no out-of-plane null")
            return
        sign0 = first[1] > 0
        self.say("[19A]: waiting for Y = 0 (PASS's FLTR Y %+.0f ft, YDOT %+.3f ft/s) until Ti %+.1f min"
                 % (first[1], first[2], (deadline_gmt - self.ti_gmt) / 60.0))
        cur = first
        while self.truth()["gmt"] < deadline_gmt:
            time.sleep(4.0 / max(self.a.rate, 1.0))
            cur = pass_y() or cur
            if (cur[1] > 0) != sign0:
                break
        else:
            self.say("[19A]: Y did not cross 0 by Ti %+.1f min (Y %+.0f ft, YDOT %+.3f); no null"
                     % ((deadline_gmt - self.ti_gmt) / 60.0, cur[1], cur[2]))
            return
        t, y, ydot, ey = cur
        tru = self.ears.snap()[0]                       # with the attitude
        tgt = self.ears.truth_at("target", tru["gmt"])
        ty = None
        if tgt:
            _, tey, _ = self.lvlh_axes([x / FT for x in tgt[0]], [x / FT for x in tgt[1]])
            ty = vdot(vsub([x / FT for x in tru["v"]], [x / FT for x in tgt[1]]), tey)
        need = [-ydot * c for c in ey]                       # ft/s, M50
        comp = [vdot(need, body_axis(tru["q"], k)) for k in range(3)]
        k = max(range(3), key=lambda i: abs(comp[i]))
        key = ("+" if comp[k] > 0 else "-") + "xyz"[k]
        acc = (getattr(self, "thc_acc", None) or THC_ACC_SEED).get(key, THC_ACC_SEED[key])
        hold = min(max(abs(comp[k]) / acc, 0.1), 10.0)
        self.say("[19A] at Ti %+.1f min: PASS's Y %+.0f ft, YDOT %+.3f ft/s (truth YDOT %s); body %+.3f %+.3f "
                 "%+.3f ft/s wanted; THC %s %.2f s (at %.3f ft/s^2)"
                 % (self.ti_min(), y, ydot, "%+.3f" % ty if ty is not None else "?", *comp, key.upper(), hold, acc))
        if abs(ydot) < 0.05:
            self.say("[19A]: YDOT under 0.05 ft/s -- nothing to null")
            return
        self.play("+1     dap c3 a\n"
                  "+2     dap c3 auto\n"
                  "+2     dap c3 pri\n"
                  "+2     dap c3 x_norm\n"
                  "+2     dap c3 y_norm\n"
                  "+2     dap c3 z_norm\n"
                  "+2     thc fwd %s %.2f\n" % (key, hold), "oop-null")
        self.script_done("oop-null", 120)
        self.wait_sim(hold + 4.0)
        self.play("+1     dap c3 alt\n"
                  "+2     dap c3 x_pulse\n"
                  "+2     dap c3 y_pulse\n"
                  "+2     dap c3 z_pulse\n"
                  "+20    dap c3 vern\n", "oop-null-end")
        self.script_done("oop-null-end", 120)
        tru = self.truth()
        tgt = self.ears.truth_at("target", tru["gmt"])
        if tgt:
            _, tey, _ = self.lvlh_axes([x / FT for x in tgt[0]], [x / FT for x in tgt[1]])
            self.say("[19A]: done; truth YDOT now %+.3f ft/s; PASS's %s"
                     % (vdot(vsub([x / FT for x in tru["v"]], [x / FT for x in tgt[1]]), tey),
                        "%+.3f" % (pass_y() or (0, 0, float("nan")))[2]))

    def rel_now(self, tru, tgt, what):
        """The truth's relative state, in PASS's curvilinear target LVLH."""
        sys.path.insert(0, os.path.join(YAGPC2, "tools"))
        import rndz_start
        # the target at the truth's own instant (the two feeds are sampled
        # apart; a second's difference is a mile of orbit)
        at = self.ears.truth_at("target", tru["gmt"])
        rt, vt = (at if at else (list(tgt["r"]), list(tgt["v"])))
        rel = rndz_start.m50_to_lvc(list(rt), list(vt), list(tru["r"]), list(tru["v"]))
        self.say("%s: truth at Ti %+.1f min: %s" % (what, (tru["gmt"] - self.ti_gmt) / 60.0,
                                                    rndz_start.fmt_rel(rel)))
        return rel


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--logs", required=True)
    ap.add_argument("--port-base", type=int, default=48600)
    ap.add_argument("--rate", type=float, default=1.0)
    ap.add_argument("--tape", default=os.path.expanduser(
        "~/dropbox-copy/sts134-ksc6-entry/OI340700-v44boot-sts134-ksc6.mmv"),
                    help="the mass-memory volume (default %(default)s); for STS-134's own rendezvous I-loads "
                         "from the IPL on, a copy with yaGPC2/tools/sites/sts134-rndz-iloads.json applied "
                         "(tools/mission_reconfig.py), e.g. " + RNDZ_VOLUME + " -- then no --dass-iloads, "
                         "--zero-sensor-bias or --lambert-mc is needed on a fresh run")
    ap.add_argument("--targets", default=os.path.expanduser("~/sts134-runs/rendezvous/sts134-targets.txt"))
    ap.add_argument("--portview", action="store_true", help="start portview's window views")
    ap.add_argument("--views", default=None, metavar="LIST",
                    help="with --portview: portview's views, from front, up, left, right, aft, cl "
                         "(default front)")
    ap.add_argument("--rhc", choices=("lh", "aft", "rh"), default="lh",
                    help="the station whose hand controllers are started (default lh, the "
                         "CDR's; dock_autopilot.py uses aft)")
    ap.add_argument("--layout", default=None, metavar="FILE",
                    help="simulatePASS --layout: where to place the windows (a file saved from "
                         "the manager's LAYOUT row); it wins over the capture's own layout")
    ap.add_argument("--input", choices=("auto", "joystick", "virtual"), default=None,
                    help="the hand controllers' input (simulatePASS --input): auto uses a "
                         "joystick if one is plugged in, and then draws no virtual controllers; "
                         "dock_autopilot.py uses virtual, so the THC's movements can be watched")
    ap.add_argument("--station", choices=("fwd", "aft", "all"), default="all",
                    help="the flight station whose windows are shown (simulatePASS --station; "
                         "dock_autopilot.py uses aft)")
    ap.add_argument("--hold-start", action="store_true",
                    help="bring the windows up with the vehicle held, and start it when Enter "
                         "is pressed here -- time to arrange the windows first")
    ap.add_argument("--to", choices=PHASES)
    ap.add_argument("--from", dest="from_", choices=PHASES[1:])
    ap.add_argument("--crts", type=int, default=1)
    ap.add_argument("--coast-min", type=float, default=76.9,
                    help="COAST: minutes after Ti to fly before stopping (default 76.9, to T2)")
    ap.add_argument("--attach", dest="attach_running", action="store_true",
                    help="with --from: drive the vehicle already running on --port-base")
    ap.add_argument("--start-utc", help="the run's start, UTC (default %s, Ti - 68 min); any time after "
                    "NC (06:06) -- 06:10, PET -1:28, gives STAR TRACKER NAV [10A] its whole sunlit pass, "
                    "the ISS going into the Earth's shadow at 06:43" % EPOCH)
    ap.add_argument("--no-strk", action="store_true",
                    help="no star tracker pass (STRKNAV, STRKEND do nothing): the M1 baseline")
    ap.add_argument("--no-mc", action="store_true",
                    help="after the Ti burn, no MC1-MC4: POSTTI coasts to T2 (--coast-min) and the MC "
                         "phases do nothing (the M1b baseline)")
    ap.add_argument("--lambert-mc", action="store_true",
                    help="LEGACY (superseded by --dass-iloads, or a volume with yaGPC2/tools/sites/sts134-rndz-iloads.json "
                         "applied): CGZB_LAMB_ILOAD "
                         "(this tape: Lambert for TGT 1-10 only, the source's INITIAL) set ON for TGT 11-14 "
                         "and 19 in the capture the run resumes from (or, on a fresh run, the UPLINK "
                         "capture), so that MC1-MC4 are Lambert-targeted (GWR) and MC2's 29.07 deg "
                         "elevation angle sets its TIG; without it they go to the non-Lambert GWG")
    ap.add_argument("--mc-rule", choices=("limits", "onboard"), default="limits",
                    help="MC1-MC4: 'limits' (default) burns the onboard solution when it is within the "
                         "final-ground limits of the ground's (the truth's Lambert, for MCC), else the "
                         "ground's EXT DVs; 'onboard' always the onboard one (p. 1-3)")
    ap.add_argument("--zero-sensor-bias", action="store_true",
                    help="LEGACY (superseded by --dass-iloads, or a volume with yaGPC2/tools/sites/sts134-rndz-iloads.json "
                         "applied; STS-134's own values are 0.0): GLQREN's sensor bias INITs "
                         "-- S TRK and RR angles (this tape's 1.0, 1.0 RADIAN, RENDEZVOUS_PLAN.md 5b, 5d), RR "
                         "range and range rate (1.0 ft, 1.0 ft/s), COAS -- set to 0.0 in the capture the "
                         "run resumes from, or, on a fresh run, in the UPLINK capture, which the run then "
                         "restarts from before RNDZ NAV ENA.  The tape and volume are untouched")
    ap.add_argument("--dass-iloads", metavar="GROUPS",
                    help="STS-134's OWN I-LOADS, from its DASS listing (--dass): the PATCH SUMMARY's MM values "
                         "written, in the capture the run resumes from (or, on a fresh run, the UPLINK "
                         "capture), over the load module's LM values this tape holds, for the csects of "
                         "GROUPS, comma-separated: 'rndz' (CGZ/GW targeting, CGN/GL navigation), 'all' "
                         "(every GNC #PCG/#DG csect), or csect names.  The flight's bias INITs (0), Lambert "
                         "flags (9-14, 19 ON), GL5NAV's 0.06 ft/s and the GWS/GWQ iteration constants among "
                         "them (RENDEZVOUS_PLAN.md 5e).  The tape and volume are untouched")
    ap.add_argument("--pulse-trim", type=float, default=0.08, metavar="FPS",
                    help="after a midcourse's VGO null (TRANS NORM, every axis < 0.2 ft/s, the card's), trim "
                         "each axis still at FPS or more with single TRANS PULSE pulses (0.10 ft/s, DAP A7); "
                         "0 for the card's 0.2 alone (default %(default)s)")
    ap.add_argument("--dass", default=DASS_G2,
                    help="the MAFGEN DASS listing for --dass-iloads (default %(default)s)")
    ap.add_argument("--no-rr", action="store_true",
                    help="no Ku-band rendezvous radar (RRNAV does nothing; the star tracker pass goes on "
                         "after Ti, as in Stage 2)")
    ap.add_argument("--low-z", action="store_true",
                    help="RBAR: press LOW Z, as the APPROACH card does inside 1,000 ft.  Off by default: "
                         "vehdyn models the RCS jets without their cant, and LOW Z's +Z translation, "
                         "which the aft-firing jets' cant makes, came out -Z (RENDEZVOUS_PLAN.md 5f)")
    ap.add_argument("--hold-min", type=float, default=20.0,
                    help="HOLD: minutes of station-keeping 100 ft out on the +V-bar (default %(default)s)")
    ap.add_argument("--check-every", type=float, default=30.0,
                    help="seconds of vehicle time between rndz-check.log comparisons (default 30)")
    a = ap.parse_args()
    if a.start_utc:
        globals()["EPOCH"] = a.start_utc
    a.attach = a.attach_running
    fly_sts134.FL["name"] = "sts134r"
    f = Rendezvous(a)
    if a.attach:
        f.ears = Ears(a.port_base)
        threading.Thread(target=f.monitor, daemon=True).start()
    fly_sts134.PHASES[:] = PHASES     # the base class's run() walks these
    f.run()


if __name__ == "__main__":
    main()
