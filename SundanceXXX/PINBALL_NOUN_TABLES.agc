### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PINBALL_NOUN_TABLES.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 306

# THE FOLLOWING REFERS TO THE NOUN TABLES


# COMPONENT CODE NUMBER           INTERPRETATION

# 00000                           1 COMPONENT
# 00001                           2 COMPONENT
# 00010                           3 COMPONENT
# X1XXX                           BIT 4 = 1. DECIMAL ONLY
# 1XXXX                           BIT 5 = 1. NO LOAD
# END OF COMPONENT CODE NUMBERS


# SF ROUTINE CODE NUMBER          INTERPRETATION

# 00000    OCTAL ONLY
# 00001    STRAIGHT FRACTIONAL
# 00010    CDU DEGREES (XXX.XX)
# 00011    ARITHMETIC SF
# 00100    ARITH DP1   OUT (MULT BY 2EXP14 AT END)   IN (STRAIGHT)
# 00101    ARITH DP2   OUT (STRAIGHT)                IN (SL 7 AT END)
# 00110    LANDING RADAR POSITION (+0000X)
# 00111    ARITH DP3   OUT (SL 7 AT END)        IN ( STRAIGHT)
# 01000    WHOLE HOURS IN R1, WHOLE MINUTES (MOD 60) IN R2,
#             SECONDS (MOD 60) 0XX.XX IN R3. *** ALARMS IF USED WITH OCTAL
# 01001    MINUTES (MOD 60) IN D1D2, D3 BLANK, SECONDS (MOD 60) IN D4D5
#                         LIMITS TO 59B59 IF MAG EXCEEDS THIS VALUE.
#                         ALARMS IF USED WITH OCTAL  ********  IN (ALARM)
# 01010    ARITH DP4   OUT (STRAIGHT)                  IN (SL 3 AT END)
# 01011    ARITH1 SF   OUT(MULT BY 2EXP14 AT END)    IN(STRAIGHT)
# 01100    2 INTEGERS IN D1D2, D4D5, D3 BLANK.
#                         ALARMS IF USED WITH OCTAL  ********  IN (ALARM)
# 01101    360-CDU DEGREES (XXX.XX)
# END OF SF ROUTINE CODE NUMBERS


# SF CONSTANT CODE NUMBER         INTERPRETATION

# 00000                           WHOLE                       USE ARITH
# 00000                           DP TIME SEC (XXX.XX SEC)    USE ARITHDP1
# 00000                           LR POSITION (+0000X)     USE LR POSITION
# 00001                           SPARE
# 00010                           CDU DEGREES              USE CDU DEGREES
# 00010                           360-CDU DEGREES      USE 360-CDU DEGREES
# 00011                           DP DEGREES (90) XX.XXX DEG  USE ARITHDP3
# 00100                           DP DEGREES (360) XXX.XX DEG USE ARITHDP4
# 00101                           DEGREES (180) XXX.XX DEG    USE ARITH
# 00101                           OPTICAL TRACKER AZIMUTH ANGLE(XXX.XXDEG)
#                                                             USE ARITHDP1
# 00110                           WEIGHT2 (XXXXX. LBS)        USE ARITH1

# 00111                           POSITION5 (XXX.XX NAUTICAL MILES)
#                                                             USE ARITHDP3
# 01000                           POSITION4 (XXXX.X NAUTICAL MILES)
#                                                             USE ARITHDP3
# 01001                           VELOCITY2 (XXXXX. FT/SEC)   USE ARITHDP4
# 01010                           VELOCITY3 (XXXX.X FT/SEC)   USE ARITHDP3
# 01011                           ELEVATION DEGREES(89.999MAX) USE ARITH
# 01100                           RENDEZVOUS RADAR RANGE (XXX.XX NAUT MI)
#                                                             USE ARITHDP1
# 01101                           RENDEZVOUS RADAR RANGE RATE(XXXXX.FT/SEC
#                                                             USE ARITHDP1
# 01110                           LANDING RADAR ALTITUDE(XXXXX.FEET)
#                                                             USE ARITHDP1
# 01111                           INITIAL/FINAL ALTITUDE(XXXXX.FEET)
#                                                             USE ARITHDP1
# 10000                           ALTITUDE RATE(XXXXX.FT/SEC)    USE ARITH
# 10001                           FORWARD/LATERAL VELOCITY(XXXXX.FEET/SEC)
#                                                                USE ARITH
# 10010                           ROTATIONAL HAND CONTROLLER ANGLE RATES
#                                       XXXXX.DEG/SEC            USE ARITH
# 10011                           LANDING RADAR VELX(XXXXX.FEET/SEC)
#                                                             USE ARITHDP1
# 10100                           LANDING RADAR VELY(XXXXX.FEET/SEC)
#                                                             USE ARITHDP1
# 10101                           LANDING RADAR VELZ(XXXXX.FEET/SEC)
#                                                             USE ARITHDP1
# 10110                           POSITION7 (XXXX.X NAUT MI)  USE ARITHDP4
# 10111                           TRIM DEGREES2 (XXX.XX DEG)  USE ARITH
# 11000                           COMPUTED ALTITUDE (XXXXX. FEET)
#                                                             USE ARITHDP1
# 11001                           DP DEGREES (XXXX.X DEG)     USE ARITHDP3
# 11010                           POSITION9 (XXX.XX NAUT MI)  USE ARITHDP4
# 11011                           VELOCITY4 (XXXX.X FT/SEC)   USE ARITHDP2
# END OF SF CONSTANT CODE NUMBERS


# FOR GREATER THAN SINGLE PRECISION SCALES, PUT ADDRESS OF MAJOR PART INTO
# NOUN TABLES.
# OCTAL LOADS PLACE +0 INTO MAJOR PART, DATA INTO MINOR PART.
# OCTAL DISPLAYS SHOW MINOR PART ONLY.
# TO GET AT BOTH MAJOR AND MINOR PARTS(IN OCTAL), USE NOUN 01.


# A NOUN MAY BE DECLARED :DECIMAL ONLY: BY MAKING BIT4=1 OF ITS COMPONENT
# CODE NUMBER. IF THIS NOUN IS USED WITH ANY OCTAL DISPLAY VERB, OR IF
# DATA IS LOADED IN OCTAL, IT ALARMS.

# IN LOADING AN :HOURS, MINUTES, SECONDS: NOUN, ALL 3 WORDS MUST BE
# LOADED, OR ALARM.
# ALARM IF AN ATTEMPT IS MADE TO LOAD :SPLIT MINUTES/SECONDS: (MMBSS).

# THIS IS USED FOR DISPLAY ONLY.

# THE FOLLOWING ROUTINES ARE FOR READING THE NOUN TABLES AND THE SF TABLES
# (WHICH ARE IN A SEPARATE BANK FROM THE REST OF PINBALL). THESE READING
# ROUTINES ARE IN THE SAME BANK AS THE TABLES. THEY ARE CALLED BY DXCH Z.


# LODNNTAB LOADS NNADTEM WITH THE NNADTAB ENTRY, NNTYPTEM WITH THE
# NNTYPTAB ENTRY. IF THE NOUN IS MIXED, IDAD1TEM IS LOADED WITH THE FIRST
# IDADDTAB ENTRY, IDAD2TEM THE SECOND IDADDTAB ENTRY, IDAD3TEM THE THIRD
# IDADDTAB ENTRY, RUTMXTEM WITH THE RUTMXTAB ENTRY. MIXBR IS SET FOR
# MIXED OR NORMAL NOUN.

                BANK            6
                SETLOC          PINBALL3
                BANK
                COUNT*          $$/NOUNS
LODNNTAB        DXCH            IDAD2TEM                # SAVE RETURN INFO IN IDAD2TEM, IDAD3TEM.
                INDEX           NOUNREG
                CAF             NNADTAB
                TS              NNADTEM
                INDEX           NOUNREG
                CAF             NNTYPTAB
                TS              NNTYPTEM
                CS              NOUNREG
                AD              MIXCON
                EXTEND
                BZMF            LODMIXNN                # NOUN NUMBER G/E FIRST MIXED NOUN
                CAF             ONE                     # NOUN NUMBER L/ FIRST MIXED NOUN
                TS              MIXBR                   # NORMAL.  +1 INTO MIXBR.
                TC              LODNLV
LODMIXNN        CAF             TWO                     # MIXED.  +2 INTO MIXBR.
                TS              MIXBR
                INDEX           NOUNREG
                CAF             RUTMXTAB        -40D    # FIRST MIXED NOUN = 40.
                TS              RUTMXTEM
                CAF             LOW10
                MASK            NNADTEM
                TS              Q                       # TEMP
                INDEX           A
                CAF             IDADDTAB
                TS              IDAD1TEM                # LOAD IDAD1TEM WITH FIRST IDADDTAB ENTRY
                EXTEND
                INDEX           Q                       # LOAD IDAD2TEM WITH 2ND IDADDTAB ENTRY
                DCA             IDADDTAB        +1      # LOAD IDAD3TEM WITH 3RD IDADDTAB ENTRY.
LODNLV          DXCH            IDAD2TEM                # PUT RETURN INFO INTO A, L.
                DXCH            Z

MIXCON          =               OCT50                   # (DEC 40)
# GTSFOUT LOADS SFTEMP1, SFTEMP2 WITH THE DP SFOUTAB ENTRIES.

GTSFOUT         DXCH            SFTEMP1                 # 2X(SFCONUM) ARRIVES IN SFTEMP1.

                EXTEND
                INDEX           A
                DCA             SFOUTAB
SFCOM           DXCH            SFTEMP1
                DXCH            Z


# GTSFIN LOADS SFTEMP1, SFTEMP2 WITH THE DP SFINTAB ENTRIES.

GTSFIN          DXCH            SFTEMP1                 # 2X(SFCONUM) ARRIVES IN SFTEMP1.
                EXTEND
                INDEX           A
                DCA             SFINTAB
                TCF             SFCOM

                                                        # NN  NORMAL NOUNS
NNADTAB         OCT             00000                   # 00 NOT IN USE
                OCT             40000                   # 01 SPECIFY MACHINE ADDRESS (FRACTIONAL)
                OCT             40000                   # 02 SPECIFY MACHINE ADDRESS (WHOLE)
                OCT             40000                   # 03 SPECIFY MACHINE ADDRESS (DEGREES)
                OCT             0                       # 04 SPARE
                ECADR           DSPTEM1                 # 05 ANGULAR ERROR/DIFFERENCE
                ECADR           OPTION1                 # 06 OPTION CODE
                ECADR           XREG                    # 07 ECADR OF WORD TO BE MODIFIED
                                                        #    ONES FOR BITS TO BE MODIFIED
                                                        #    1 TO SET OR 0 TO RESET SELECTED BITS
                ECADR           ALMCADR                 # 08 ALARM DATA
                ECADR           FAILREG                 # 09 ALARM CODES
                OCT             77776                   # 10 CHANNEL TO BE SPECIFIED
                OCT             00000                   # 11 SPARE
                OCT             00000                   # 12 SPARE
                OCT             00000                   # 13 SPARE
                ECADR           DSPTEMX                 # 14 CHECKLIST
                                                        #       (USED BY EXTENDED VERBS ONLY)
                OCT             77777                   # 15 INCREMENT MACHINE ADDRESS
                ECADR           DSPTEMX                 # 16 TIME OF EVENT (HRS,MIN,SEC)
                ECADR           CPHIX                   # 17 ASTRONAUT TOTAL ATTITUDE
                ECADR           FDAIX                   # 18 AUTO MANEUVER BALL ANGLES
                ECADR           FDAIX                   # 19 BYPASS ATTITUDE TRIM MANEUVER
                ECADR           CDUX                    # 20 ICDU ANGLES
                ECADR           PIPAX                   # 21 PIPAS
                ECADR           THETAD                  # 22 NEW ICDU ANGLES
                OCT             00000                   # 23 SPARE
                ECADR           DSPTEM2         +1      # 24 DELTA TIME FOR AGC CLOCK(HRS,MIN,SEC)
                ECADR           DSPTEM1                 # 25 CHECKLIST
                                                        #       (USED WITH PLEASE PERFORM ONLY)
                ECADR           DSPTEM1                 # 26 PRIO/DELAY, ADRES, BBCON
                ECADR           SMODE                   # 27 SELF TEST ON/OFF SWITCH
                OCT             00000                   # 28 SPARE
                ECADR           LRFLAGS                 # 29 LANDING RADAR FLAG STATUS
                ECADR           TCSI                    # 30 TIG OF CSI (HRS,MIN,SEC)
                ECADR           TCDH                    # 31 TIG OF CDH (HRS,MIN,SEC)
                ECADR           -TPER                   # 32 TIME TO PERIGEE (HRS,MIN,SEC)
                ECADR           TIG                     # 33 TIME OF IGNITION (HRS,MIN(SEC)
                ECADR           DSPTEM1                 # 34 TIME OF EVENT (HRS,MIN,SEC)
                ECADR           TTOGO                   # 35 TIME TO GO TO EVENT (HRS,MIN,SEC)
                ECADR           TIME2                   # 36 TIME OF AGC CLOCK (HRS,MIN,SEC)
                ECADR           TTPI                    # 37 TIG OF TPI (HRS,MIN,SEC)
                OCT             00000                   # 38 SPARE
                OCT             00000                   # 39 SPARE
# END OF NNADTAB FOR NORMAL NOUNS


                                                        # NN  MIXED NOUNS
                OCT             64000                   # 40 TIME TO IGNITION/CUTOFF
                                                        #    VG
                                                        #    DELTA V (ACCUMULATED)
                OCT             02003                   # 41 TARGET  AZIMUTH
                                                        #            ELEVATION
                OCT             24006                   # 42 APOGEE
                                                        #    PERIGEE
                                                        #    DELTA V (REQUIRED)
                OCT             24011                   # 43 LATITUDE
                                                        #    LONGITUDE
                                                        #    ALTITUDE
                OCT             64014                   # 44 APOGEE
                                                        #    PERIGEE
                                                        #    TFF
                OCT             64017                   # 45 MARKS
                                                        #    TTI OF NEXT BURN
                                                        #    MGA
                OCT             00022                   # 46 AUTOPILOT CONFIGURATION
                OCT             22025                   # 47 LEM WEIGHT
                                                        #    CSM WEIGHT
                OCT             22030                   # 48 GIMBAL PITCH TRIM
                                                        #    GIMBAL ROLL TRIM
                OCT             22033                   # 49 DELTA R
                                                        #    DELTA V
                OCT             64036                   # 50 DELTA ALTITUDE CDH
                                                        #    DELTA TIME CDH-CSI
                                                        #    DELTA TIME TPI-CDH
                OCT             22041                   # 51 S-BAND ANTENNA PITCH
                                                        #                   YAW
                OCT             00044                   # 52 CENTRAL ANGLE OF ACTIVE VEHICLE
                OCT             24047                   # 53 DELTA V (CSI OR TPI)
                                                        #    DELTA V (CDH OR TPF)
                                                        #    CROSS RANGE
                OCT             24052                   # 54 RANGE
                                                        #    RANGE RATE
                                                        #    THETA
                OCT             24055                   # 55 NO. OF APSIDAL CROSSINGS
                                                        #    ELEVATION ANGLE
                                                        #    CENTRAL ANGLE
                OCT             24060                   # 56 NO. OF APSIDAL CROSSINGS
                                                        #    ELEVATION ANGLE
                                                        #    DELTA H CDH
                OCT             20063                   # 57 DELTA R
                OCT             24066                   # 58 PERIGEE ALT
                                                        #    DELTA V TPI
                                                        #    DELTA V TPF
                OCT             24071                   # 59 DELTA VELOCITY LOS
                OCT             24074                   # 60 HORIZONTAL VELOCITY
                                                        #    ALTITUDE RATE
                                                        #    COMPUTED ALTITUDE
                OCT             64077                   # 61 TIME TO GO IN BRAKING PHASE
                                                        #    TIME TO IGNITION
                                                        #    CROSS RANGE DISTANCE
                OCT             64102                   # 62 ABSOLUTE VALUE OF VELOCITY
                                                        #    TIME TO IGNITION
                                                        #    DELTA V (ACCUMULATED)
                OCT             24105                   # 63 ABSOLUTE VALUE OF VELOCITY
                                                        #    ALTITUDE RATE
                                                        #    COMPUTED ALTITUDE
                OCT             64110                   # 64 TIME LEFT FOR REDESIGNATION-LPD ANGLE
                                                        #    ALTITUDE RATE
                                                        #    COMPUTED ALTITUDE
                OCT             24113                   # 65 SAMPLED AGC TIME (HRS,MIN,SEC)
                                                        #    (FETCHED IN INTERRUPT)
                OCT             62116                   # 66 LR RANGE
                                                        #       POSITION
                OCT             04121                   # 67 LRVX
                                                        #    LRVY
                                                        #    LRVZ
                OCT             64124                   # 68 SLANT RANGE TO LANDING SIGHT
                                                        #    TIME TO GO IN BRAKING PHASE
                                                        #    LR ALTITUDE - COMPUTED ALTITUDE
                OCT             24127                   # 69 DELTA V LAST
                                                        #    DELTA V DVMON
                                                        #    DELTA V TOTAL
                OCT             04132                   # 70 AOT DETENT CODE/STAR CODE
                OCT             04135                   # 71 AOT DETENT CODE/STAR CODE
                OCT             02140                   # 72 RR  360 - TRUNNION ANGLE
                                                        #        SHAFT ANGLE
                OCT             02143                   # 73 NEW RR  360 - TRUNNION ANGLE
                                                        #            SHAFT ANGLE
                OCT             64146                   # 74 TIME TO IGNITION
                                                        #    YAWAFTER VEHICLE RISE
                                                        #    PITCH AFTER VEHICLE RISE
                OCT             64151                   # 75 TIME TO IGNITION
                                                        #    DELTA V (ACCUMULATED)
                                                        #    COMPUTED ALTITUDE
                OCT             22154                   # 76 CROSS-RANGE DISTANCE
                                                        #    APOCYNTHION ALTITUDE
                OCT             62157                   # 77 TIME TO ENGINE CUTOFF
                                                        #    VELOCITY NORMAL TO CSM PLANE

                OCT             02162                   # 78 RR RANGE
                                                        #       RANGE RATE
                OCT             24165                   # 79 CURSOR ANGLE
                                                        #    SPIRAL ANGLE
                                                        #    POSITION CODE
                OCT             02170                   # 80 DATA INDICATOR
                                                        #    OMEGA
                OCT             24173                   # 81 DELTA V (LV)
                OCT             24176                   # 82 DELTA V (LV)
                OCT             24201                   # 83 DELTA V (BODY)
                OCT             24204                   # 84 DELTA V (OTHER VEHICLE)
                OCT             24207                   # 85 VG (BODY)
                OCT             24212                   # 86 VG (LV)
                OCT             02215                   # 87 BACKUP OPTICS LOS AZIMUTH
                                                        #                      ELEVATION
                OCT             24220                   # 88 HALF UNIT SUN OR PLANET VECTOR
                OCT             24223                   # 89 LANDMARK LATITUDE
                                                        #             LONGITUDE/2
                                                        #             ALTITUDE
                OCT             24226                   # 90 Y
                                                        #    Y DOT
                                                        #    PSI
                OCT             64231                   # 91 TPI ALTITUDE
                                                        #    TIME FROM LAUNCH TO TPI
                                                        #    ANGLE FROM LAUNCH TO TPI
                OCT             64234                   # 92 TIME FROM LAUNCH TO TPF
                                                        #    ANGLE FROM LAUNCH TO TPF
                OCT             04237                   # 93 DELTA GYRO ANGLES
                OCT             64242                   # 94 CSI ALTITUDE
                                                        #    TIME FROM LAUNCH TO CSI
                                                        #    ANGLE FROM LAUNCH TO CSI
                OCT             04245                   # 95 PREFERRED ATTITUDE ICDU ANGLES
                OCT             04250                   # 96 +X-AXIS ATTITUDE ICDU ANGLES
                OCT             04253                   # 97 SYSTEM TEST INPUTS
                OCT             04256                   # 98 SYSTEM TEST RESULTS
                OCT             22261                   # 99 RMS IN POSITION
                                                        #    RMS IN VELOCITY
# END OF NNADTAB FOR MIXED NOUNS


                                                        # NN        NORMAL NOUNS
NNTYPTAB        OCT             00000                   # 00 NOT IN USE
                OCT             04040                   # 01 3COMP  FRACTIONAL
                OCT             04140                   # 02 3COMP  WHOLE
                OCT             04102                   # 03 3COMP  CDU DEGREES
                OCT             00000                   # 04        SPARE
                OCT             00504                   # 05 1COMP  DPDEG(360)
                OCT             02000                   # 06 2COMP  OCTAL ONLY
                OCT             04000                   # 07 3COMP  OCTAL ONLY
                OCT             04000                   # 08 3COMP  OCTAL ONLY
                OCT             04000                   # 09 3COMP  OCTAL ONLY
                OCT             00000                   # 10 1COMP  OCTAL ONLY
                OCT             00000                   # 11        SPARE
                OCT             00000                   # 12        SPARE
                OCT             00000                   # 13        SPARE

                OCT             04140                   # 14 3COMP  WHOLE
                OCT             00000                   # 15 1COMP  OCTAL ONLY
                OCT             24400                   # 16 3COMP  HMS (DEC ONLY)
                OCT             04102                   # 17 3COMP  CDU DEG
                OCT             04102                   # 18 3COMP  CDU DEG
                OCT             04102                   # 19 3COMP  CDU DEG
                OCT             04102                   # 20 3COMP  CDU DEGREES
                OCT             04140                   # 21 3COMP  WHOLE
                OCT             04102                   # 22 3COMP  CDU DEGREES
                OCT             00000                   # 23        SPARE
                OCT             24400                   # 24 3COMP  HMS (DEC ONLY)
                OCT             04140                   # 25 3COMP  WHOLE
                OCT             04000                   # 26 3COMP  OCTAL ONLY
                OCT             00140                   # 27 1COMP  WHOLE
                OCT             00000                   # 28        SPARE
                OCT             00000                   # 29 1COMP  OCTAL ONLY
                OCT             24400                   # 30 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 31 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 32 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 33 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 34 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 35 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 36 3COMP  HMS (DEC ONLY)
                OCT             24400                   # 37 3COMP  HMS (DEC ONLY)
                OCT             00000                   # 38        SPARE
                OCT             00000                   # 39        SPARE
# END OF NNTYPTAB FOR NORMAL NOUNS


                                                        # NN   MIXED NOUNS
                OCT             24500                   # 40 3COMP  MIN/SEC, VEL3, VEL3
                                                        #           (NO LOAD, DEC ONLY)
                OCT             00542                   # 41 2COMP  CDU DEG, ELEV DEG
                OCT             24410                   # 42 3COMP  POS4, POS4, VEL3
                                                        #           (DEC ONLY)
                OCT             20204                   # 43 3COMP  DPDEG(360), DPDEG(360), POS4
                                                        #           (DEC ONLY)
                OCT             00410                   # 44 3COMP  POS4, POS4, MIN/SEC
                                                        #           (NO LOAD, DEC ONLY)
                OCT             10000                   # 45 3COMP  WHOLE, MIN/SEC, DPDEG(360)
                                                        #           (NO LOAD, DEC ONLY)
                OCT             00000                   # 46 1COMP  OCTAL ONLY
                OCT             00306                   # 47 2COMP WEIGHT2 FOR EACH
                                                        #           (DEC ONLY)
                OCT             01367                   # 48 2COMP  TRIM DEG2 FOR EACH
                                                        #           (DEC ONLY)
                OCT             00510                   # 49 2COMP  POS4, VEL3
                                                        #           (DEC ONLY)
                OCT             00010                   # 50 3COMP  POS4, MIN/SEC, MIN/SEC
                                                        #           (NO LOAD, DEC ONLY)
                OCT             00204                   # 51 2COMP  DPDEG(360), DPDEG(360)
                                                        #           (DEC ONLY)
                OCT             00004                   # 52 1COMP  DPDEG(360)
                OCT             20512                   # 53 3COMP  VEL3, VEL3, POS4
                                                        #           (DEC ONLY)
                OCT             10507                   # 54 3COMP  POS5, VEL3, DPDEG(360)
                                                        #           (DEC ONLY)
                OCT             10200                   # 55 3COMP  WHOLE, DPDEG(360), DPDEG(360)
                                                        #           (DEC ONLY)
                OCT             20200                   # 56 3COMP  WHOLE, DPDEG(360), POS4
                                                        #           (DEC ONLY)
                OCT             00010                   # 57 1COMP  POS4
                                                        #           (DEC ONLY)
                OCT             24510                   # 58 3COMP  POS4, VEL3, VEL3
                                                        #           (DEC ONLY)
                OCT             24512                   # 59 3COMP  VEL3 FOR EACH
                                                        #           (DEC ONLY)
                OCT             60512                   # 60 3COMP  VEL3, VEL3, COMP ALT
                                                        #           (DEC ONLY)
                OCT             54000                   # 61 3COMP  MIN/SEC, MIN/SEC, POS7
                                                        #           (NO LOAD, DEC ONLY)
                OCT             24012                   # 62 3COMP  VEL3, MIN/SEC, VEL3
                                                        #           (NO LOAD, DEC ONLY)
                OCT             60512                   # 63 3COMP  VEL3, VEL3, COMP ALT
                                                        #           (DEC ONLY)
                OCT             60500                   # 64 3COMP  2INT, VEL3, COMP ALT
                                                        #           (NO LOAD, DEC ONLY)
                OCT             00000                   # 65 3COMP  HMS (DEC ONLY)
                OCT             00016                   # 66 2COMP  LANDING RADAR ALT, POSITION
                                                        #           (NO LOAD, DEC ONLY)
                OCT             53223                   # 67 3COMP LANDING RADAR VELX, Y, Z
                OCT             60026                   # 68 3COMP  POS7, MIN/SEC, COMP ALT
                                                        #           (NO LOAD, DEC ONLY)
                OCT             24000                   # 69 3COMP  WHOLE, WHOLE, VEL3
                                                        #           (DEC ONLY)
                OCT             0                       # 70 3COMP  OCTAL ONLY FOR EACH
                OCT             0                       # 71 3COMP  OCTAL ONLY FOR EACH
                OCT             00102                   # 72 2COMP  360-CDU DEG, CDU DEG
                OCT             00102                   # 73 2COMP  360-CDU DEG, CDU DEG
                OCT             10200                   # 74 3COMP  MIN/SEC, DPDEG(360), DPDEG(360)
                                                        #           (NO LOAD, DEC ONLY)
                OCT             60500                   # 75 3COMP  MIN/SEC, VEL3, COMP ALT
                                                        #           (NO LOAD, DEC ONLY)
                OCT             00410                   # 76 3COMP  POS4, POS4
                                                        #           (DEC ONLY)
                OCT             00500                   # 77 2COMP  MIN/SEC, VEL3
                                                        #           (NO LOAD, DEC ONLY)
                OCT             00654                   # 78 2 COMP  RR RANGE, RR RANGE RATE
                OCT             00102                   # 79 3COMP  CDU DEG, CDU DEG, WHOLE
                                                        #           (DEC ONLY)
                OCT             00200                   # 80 2COMP  WHOLE, DPDEG(360)
                OCT             24512                   # 81 3COMP  VEL3 FOR EACH
                                                        #           (DEC ONLY)
                OCT             24512                   # 82 3COMP  VEL3 FOR EACH

                                                        #           (DEC ONLY)
                OCT             24512                   # 83 3COMP  VEL3 FOR EACH
                                                        #           (DEC ONLY)
                OCT             24512                   # 84 3COMP  VEL3 FOR EACH
                                                        #           (DEC ONLY)
                OCT             24512                   # 85 3COMP  VEL3 FOR EACH
                                                        #           (DEC ONLY)
                OCT             24512                   # 86 3COMP  VEL3 FOR EACH
                                                        #           (DEC ONLY)
                OCT             00102                   # 87 2COMP  CDU DEG FOR EACH
                OCT             0                       # 88 3COMP  FRAC FOR EACH
                                                        #            (DEC ONLY)
                OCT             16143                   # 89 3COMP  DPDEG(90), DPDEG(90), POS5
                                                        #           (DEC ONLY)
                OCT             10507                   # 90 3COMP  POS5, VEL3, DPDEG(360)
                                                        #           (DEC ONLY)
                OCT             62010                   # 91 3COMP  POS4, MIN/SEC, DPDEG(XXXX.X)
                                                        #           (NO LOAD, DEC ONLY)
                OCT             62000                   # 92 3COMP  SPARE, MIN/SEC, DPDEG(XXXX.X)
                                                        #           (NO LOAD, DEC ONLY)
                OCT             06143                   # 93 3COMP  DPDEG(90) FOR EACH
                OCT             62010                   # 94 3COMP  POS4, MIN/SEC, DPDEG(XXXX.X)
                                                        #           (NO LOAD, DEC ONLY)
                OCT             04102                   # 95 3COMP  CDU DEG FOR EACH
                OCT             04102                   # 96 3COMP  CDU DEG FOR EACH
                OCT             00000                   # 97 3COMP  WHOLE FOR EACH
                OCT             00000                   # 98 3COMP  WHOLE, FRAC, WHOLE
                OCT             01572                   # 99 3COMP  POS9, VEL4
                                                        #           (DEC ONLY)
# END OF NNTYPTAB FOR MIXED NOUNS


SFINTAB         OCT             00006                   # WHOLE, DP TIME (SEC)
                OCT             03240
                OCT             00000                   # SPARE
                OCT             00000
                OCT             00000                   # CDU DEGREES, 360-CDU DEGREES
                OCT             00000                   #     (SFCONS IN DEGINSF)
                OCT             10707                   # DP DEGREES (90)
                OCT             03435                   #         UPPED BY 1
                OCT             13070                   # DP DEGREES (360) (POINT BETWN BITS 11-12)
                OCT             34345                   #         UPPED BY 1
                OCT             00005                   # DEGREES (180)
                OCT             21616
                OCT             26113                   # WEIGHT2
                OCT             31713
                OCT             00070                   # POSITION5
                OCT             20460
                OCT             01065                   # POSITION4
                OCT             05740
                OCT             11414                   # VELOCITY2       (POINT BETWN BITS 11-12)
                OCT             31463
                OCT             07475                   # VELOCITY3

                OCT             16051
                OCT             00001                   # ELEVATION DEGREES
                OCT             03434
                OCT             00047                   # RENDEZVOUS RADAR RANGE
                OCT             21135
                OCT             77766                   # RENDEZVOUS RADAR RANGE RATE
                OCT             50711
                OCT             00005                   # LANDING RADAR ALTITUDE
                OCT             24733
                OCT             00002                   # INITIAL/FINAL ALTITUDE
                OCT             23224
                OCT             00014                   # ALTITUDE RATE
                OCT             06500
                OCT             00012                   # FORWARD/LATERAL VELOCITY
                OCT             36455
                OCT             04256                   # ROT HAND CONT ANGLE RATE
                OCT             07071
                2DEC*           -1.552795030    E5 B-28*# LANDING RADAR VELX
                2DEC*           .8250825087     E5 B-28*# LANDING RADAR VELY
                2DEC*           1.153668673     E5 B-28*# LANDING RADAR VELZ
                OCT             04324                   # POSITION7
                OCT             27600
                OCT             00036                   # TRIM DEGREES2
                OCT             20440
                OCT             00035                   # COMPUTED ALTITUDE
                OCT             30400
                OCT             23420                   # DP DEGREES
                OCT             00000
                2DEC            1852            E3 B-22 # POSITION 9
                2DEC            30.48 B-7               # VELOCITY4

                                                        # END OF SFINTAB


SFOUTAB         OCT             05174                   # WHOLE, DP TIME (SEC)
                OCT             13261
                OCT             00000                   # SPARE
                OCT             00000
                OCT             00000                   # CDU DEGREES, 360-CDU DEGREES
                OCT             00000                   #     (SFCONS IN DEGOUTSF, 360-CDUO)
                OCT             00714                   # DP DEGREES (90) (POINT BETWN BITS 7-8)
                OCT             31463
                OCT             13412                   # DP DEGREES (360)
                OCT             07534
                OCT             05605                   # DEGREES (180)
                OCT             03656

                OCT             00001                   # WEIGHT2
                OCT             16170
                OCT             00441                   # POSITION5
                OCT             34306
                OCT             07176                   # POSITION4       (POINT BETWN BITS 7-8)
                OCT             21603
                OCT             15340                   # VELOCITY2
                OCT             15340
                OCT             01031                   # VELOCITY3       (POINT BETWN BITS 7-8)
                OCT             21032
                OCT             34631                   # ELEVATION DEGREES
                OCT             23146
                OCT             00636                   # RENDEZVOUS RADAR RANGE
                OCT             14552
                OCT             74552                   # RENDEZVOUS RADAR RANGE RATE
                OCT             70307
                OCT             05521                   # LANDING RADAR ALTITUDE
                OCT             30260
                OCT             14226                   # INITIAL/FINAL ALTITUDE
                OCT             31757
                OCT             02476                   # ALTITUDE RATE
                OCT             05531
                OCT             02727                   # FORWARD/LATERAL VELOCITY
                OCT             16415
                OCT             00007                   # ROT HAND CONT ANGLE RATE
                OCT             13734
                2DEC            -.6440          E-5 B14 # LANDING RADAR VELX
                2DEC            1.212           E-5 B14 # LANDING RADAR VELY
                2DEC            .8668           E-5 B14 # LANDING RADAR VELZ
                OCT             34772                   # POSITION7
                OCT             07016
                OCT             01030                   # TRIM DEGREES2
                OCT             33675
                OCT             01046                   # COMPUTED ALTITUDE
                OCT             15700
                OCT             00321                   # DP DEGREES
                OCT             26706
                2DEC            .283092873              # POSITION 9
                2DEC            .032808399              # VELOCITY4
                                                        # END OF SFOUTAB


                                                        # NN    SF CONSTANT             SF ROUTINE

IDADDTAB        ECADR           TTOGO                   # 40 MIN/SEC                          M/S

                ECADR           VGDISP                  # 40 VEL3                             DP3
                ECADR           DVTOTAL                 # 40 VEL3                             DP3
                ECADR           DSPTEM1                 # 41 CDU DEG                          CDU
                ECADR           DSPTEM1         +1      # 41 ELEV DEG                         ARTH
                OCT             0                       # 41 SPARE COMPONENT
                ECADR           HAPO                    # 42 POS4                             DP3
                ECADR           HPER                    # 42 POS4                             DP3
                ECADR           VGDISP                  # 42 VEL3                             DP3
                ECADR           LAT                     # 43 DPDEG(360)                       DP4
                ECADR           LONG                    # 43 DPDEG(360)                       DP4
                ECADR           ALT                     # 43 POS4                             DP3
                ECADR           HAPOX                   # 44 POS4                             DP3
                ECADR           HPERX                   # 44 POS4                             DP3
                ECADR           TFF                     # 44 MIN/SEC                          M/S
                ECADR           TRKMKCNT                # 45 WHOLE                            ARTH
                ECADR           TTOGO                   # 45 MIN/SEC                          M/S
                ECADR           +MGA                    # 45 DPDEG(360)                       DP4
                ECADR           DAPDATR1                # 46 OCTAL ONLY                       OCT
                OCT             0                       # 46 SPARE COMPONENT
                OCT             0                       # 46 SPARE COMPONENT
                ECADR           LEMMASS                 # 47 WEIGHT2                         ARTH1
                ECADR           CSMMASS                 # 47 WEIGHT2                         ARTH1
                OCT             0                       # 47 SPARE COMPONENT
                ECADR           PITTIME                 # 48 TRIM DEG2                        ARTH
                ECADR           ROLLTIME                # 48 TRIM DEG2                        ARTH
                OCT             0                       # 48 SPARE COMPONENT
                ECADR           R22DISP                 # 49 POS4                             DP3
                ECADR           R22DISP         +2      # 49 VEL3                             DP3
                OCT             00000                   # 49 SPARE COMPONENT
                ECADR           DIFFALT                 # 50 POS4                             DP3
                ECADR           T1TOT2                  # 50 MIN/SEC                          M/S
                ECADR           T2TOT3                  # 50 MIN/SEC                          M/S
                ECADR           ALPHASB                 # 51 DPDEG(360)                       DP4
                ECADR           BETASB                  # 51 DPDEG(360)                       DP4
                OCT             0                       # 51 SPARE COMPONENT
                ECADR           ACTCENT                 # 52 DPDEG(360)                       DP4
                OCT             00000                   # 52 SPARE COMPONENT
                OCT             00000                   # 52 SPARE COMPONENT
                ECADR           DELVTPI                 # 53 VEL3                             DP3
                ECADR           DELVTPF                 # 53 VEL3                             DP3
                ECADR           P1XMAX                  # 53 POS4                             DP3
                ECADR           RANGE                   # 54 POS5                             DP1
                ECADR           RRATE                   # 54 VEL3                             DP3
                ECADR           RTHETA                  # 54 DPDEG(360)                       DP4
                ECADR           NN                      # 55 WHOLE                            ARTH
                ECADR           ELEV                    # 55 DPDEG(360)                       DP4
                ECADR           CENTANG                 # 55 DPDEG(360)                       DP4
                ECADR           NN                      # 56 WHOLE                            ARTH
                ECADR           ELEV                    # 56 DPDEG(360)                       DP4
                ECADR           CDHDELH                 # 56 POS4                             DP3
                ECADR           DELTAR                  # 57 POS4                             DP3
                OCT             0                       # 57 SPARE COMPONENT
                OCT             0                       # 57 SPARE COMPONENT
                ECADR           POSTTPI                 # 58 POS4                             DP3
                ECADR           DELVTPI                 # 58 VEL3                             DP3
                ECADR           DELVTPF                 # 58 VEL3                             DP3
                ECADR           DVLOS                   # 59 VEL3                             DP3
                ECADR           DVLOS           +2      # 59 VEL3                             DP3
                ECADR           DVLOS           +4      # 59 VEL3                             DP3
                ECADR           VHORIZ                  # 60 VEL3                             DP3
                ECADR           HDOTDISP                # 60 VEL3                             DP3
                ECADR           HCALC                   # 60 COMP ALT                         DP1
                ECADR           TTFDISP                 # 61 MIN/SEC                          M/S
                ECADR           TTOGO                   # 61 MIN/SEC                          M/S
                ECADR           OUTOFPLN                # 61 POS7                             DP4
                ECADR           ABVEL                   # 62 VEL3                             DP3
                ECADR           TTOGO                   # 62 MIN/SEC                          M/S
                ECADR           DVTOTAL                 # 62 VEL3                             DP3
                ECADR           ABVEL                   # 63 VEL3                             DP3
                ECADR           HDOTDISP                # 63 VEL3                             DP3
                ECADR           HCALC                   # 63 COMP ALT                         DP1
                ECADR           FUNNYDSP                # 64 2INT                             2INT
                ECADR           HDOTDISP                # 64 VEL3                             DP3
                ECADR           HCALC                   # 64 COMP ALT                         DP1
                ECADR           SAMPTIME                # 65 HMS (MIXED ONLY TO KEEP CODE 65) HMS
                ECADR           SAMPTIME                # 65 HMS                              HMS
                ECADR           SAMPTIME                # 65 HMS                              HMS
                ECADR           RSTACK          +6      # 66 LANDING RADAR ALT                DP1
                OCT             0                       # 66 LR POSITION                     LRPOS
                OCT             0                       # 66 SPARE COMPONENT
                ECADR           RSTACK                  # 67 LANDING RADAR VELX               DP1
                ECADR           RSTACK          +2      # 67 LANDING RADAR VELY               DP1
                ECADR           RSTACK          +4      # 67 LANDING RADAR VELZ               DP1
                ECADR           RANGEDSP                # 68 POS7                             DP4
                ECADR           TTFDISP                 # 68 MIN/SEC                          M/S
                ECADR           DELTAH                  # 68 COMP ALT                         DP1
                ECADR           ABDELV                  # 69 WHOLE                            ARTH
                ECADR           DVTHRUSH                # 69 WHOLE                            ARTH
                ECADR           DVTOTAL                 # 69 VEL3                             DP3
                ECADR           AOTCODE                 # 70 OCTAL ONLY                       OCT
                ECADR           AOTCODE         +1      # 70 OCTAL ONLY                       OCT
                ECADR           AOTCODE         +2      # 70 OCTAL ONLY                       OCT
                ECADR           AOTCODE                 # 71 OCTAL ONLY                       OCT
                ECADR           AOTCODE         +1      # 71 OCTAL ONLY                       OCT
                ECADR           AOTCODE         +2      # 71 OCTAL ONLY                       OCT
                ECADR           CDUT                    # 72 360-CDU DEG                   360-CDU
                ECADR           CDUS                    # 72 CDU DEG                          CDU
                OCT             0                       # 72 SPARE COMPONENT
                ECADR           TANG                    # 73 360-CDU DEG                   360-CDU
                ECADR           TANG            +1      # 73 CDU DEG                          CDU
                OCT             0                       # 73 SPARE COMPONENT
                ECADR           TTOGO                   # 74 MIN/SEC                          M/S
                ECADR           YAW                     # 74 DPDEG(360)                       DP4
                ECADR           PITCH                   # 74 DPDEG(360)                       DP4
                ECADR           TTOGO                   # 75 MIN/SEC                          M/S
                ECADR           DVTOTAL                 # 75 VEL3                             DP3
                ECADR           HCALC                   # 75 COMP ALT                         DP1
                ECADR           XRANGE                  # 76 POS4                             DP3
                ECADR           APO                     # 76 POS4                             DP3
                OCT             0                       # 76 SPARE COMPONENT
                ECADR           TTOGO                   # 77 MIN/SEC                          M/S
                ECADR           YDOT                    # 77 VEL3                             DP3
                OCT             0                       # 77 SPARE COMPONENT
                ECADR           RSTACK                  # 78 RR RANGE                         DP1
                ECADR           RSTACK          +2      # 78 RR RANGE RATE                    DP1
                OCT             00000                   # 78 SPARE COMPONENT
                ECADR           CURSOR                  # 79 CDU DEG                          CDU
                ECADR           SPIRAL                  # 79 CDU DEG                          CDU
                ECADR           POSCODE                 # 79 WHOLE                            ARTH
                ECADR           DATAGOOD                # 80 WHOLE                            ARTH
                ECADR           OMEGAD                  # 80 DPDEG(360)                       DP4
                OCT             0                       # 80 SPARE COMPONENT
                ECADR           DELVLVC                 # 81 VEL3                             DP3
                ECADR           DELVLVC         +2      # 81 VEL3                             DP3
                ECADR           DELVLVC         +4      # 81 VEL3                             DP3
                ECADR           DELVLVC                 # 82 VEL3                             DP3
                ECADR           DELVLVC         +2      # 82 VEL3                             DP3
                ECADR           DELVLVC         +4      # 82 VEL3                             DP3
                ECADR           DELVIMU                 # 83 VEL3                             DP3
                ECADR           DELVIMU         +2      # 83 VEL3                             DP3
                ECADR           DELVIMU         +4      # 83 VEL3                             DP3
                ECADR           DELVOV                  # 84 VEL3                             DP3
                ECADR           DELVOV          +2      # 84 VEL3                             DP3
                ECADR           DELVOV          +4      # 84 VEL3                             DP3
                ECADR           VGBODY                  # 85 VEL3                             DP3
                ECADR           VGBODY          +2      # 85 VEL3                             DP3
                ECADR           VGBODY          +4      # 85 VEL3                             DP3
                ECADR           DELVLVC                 # 86 VEL3                             DP3
                ECADR           DELVLVC         +2      # 86 VEL3                             DP3
                ECADR           DELVLVC         +4      # 86 VEL3                             DP3
                ECADR           AZ                      # 87 CDU DEG                          CDU
                ECADR           EL                      # 87 CDU DEG                          CDU
                OCT             0                       # 87 SPARE COMPONENT
                ECADR           STARAD                  # 88 FRAC                             FRAC
                ECADR           STARAD          +2      # 88 FRAC                             FRAC
                ECADR           STARAD          +4      # 88 FRAC                             FRAC
                ECADR           LANDLAT                 # 89 DPDEG(90)                        DP3
                ECADR           LANDLONG                # 89 DPDEG(90)                        DP3
                ECADR           LANDALT                 # 89 POS5                             DP1
                ECADR           RANGE                   # 90 POS5                             DP1
                ECADR           RRATE                   # 90 VEL3                             DP3
                ECADR           RTHETA                  # 90 DPDEG(360)                       DP4
                ECADR           INJALT                  # 91 POS4                             DP3
                ECADR           TPITIME                 # 91 MIN/SEC                          M/S
                ECADR           TPIANGLE                # 91 DPDEG(XXXX.X)                    DP3
                ECADR           SPARE                   # 92 SPARE COMPONENT
                ECADR           INJTIME                 # 92 MIN/SEC                          M/S
                ECADR           INJANGLE                # 92 DPDEG(XXXX.X)                    DP3
                ECADR           OGC                     # 93 DPDEG(90)                        DP3
                ECADR           OGC             +2      # 93 DPDEG(90)                        DP3
                ECADR           OGC             +4      # 93 DPDEG(90)                        DP3
                ECADR           INJALT                  # 94 POS4                             DP3
                ECADR           INJTIME                 # 94 MIN/SEC                          M/S
                ECADR           INJANGLE                # 94 DPDEG(XXXX.X)                    DP3
                ECADR           CPHI                    # 95 CDU DEG                          CDU
                ECADR           CTHETA                  # 95 CDU DEG                          CDU
                ECADR           CPSI                    # 95 CDU DEG                          CDU
                ECADR           CPHIXATT                # 96 CDU DEG                          CDU
                ECADR           CPHIXATT        +1      # 96 CDU DEG                          CDU
                ECADR           CPHIXATT        +2      # 96 CDU DEG                          CDU
                ECADR           DSPTEM1                 # 97 WHOLE                            ARTH
                ECADR           DSPTEM1         +1      # 97 WHOLE                            ARTH
                ECADR           DSPTEM1         +2      # 97 WHOLE                            ARTH
                ECADR           DSPTEM2                 # 98 WHOLE                            ARTH
                ECADR           DSPTEM2         +1      # 98 FRAC                             FRAC
                ECADR           DSPTEM2         +2      # 98 WHOLE                            ARTH
                ECADR           WWPOS                   # 99 POS9                             DP4
                ECADR           WWVEL                   # 99 VEL4                             DP2
                OCT             0                       # 99 SPARE COMPONENT
# END OF IDADDTAB

                                                        # NN  SF ROUTINES

RUTMXTAB        OCT             16351                   # 40 M/S, DP3, DP3
                OCT             00142                   # 41 CDU, ARTH
                OCT             16347                   # 42 DP3, DP3, DP3
                OCT             16512                   # 43 DP4, DP4, DP3
                OCT             22347                   # 44 DP3, DP3, M/S
                OCT             24443                   # 45 ARTH, M/S, DP4
                OCT             00000                   # 46 OCT
                OCT             00553                   # 47 ARITH1, ARITH1
                OCT             00143                   # 48 ARTH, ARTH
                OCT             00347                   # 49 DP3, DP3
                OCT             22447                   # 50 DP3, M/S, M/S
                OCT             00512                   # 51 DP4, DP4
                OCT             00012                   # 52 DP4
                OCT             16347                   # 53 DP3, DP3, DP3
                OCT             24344                   # 54 DP1, DP3, DP4
                OCT             24503                   # 55 ARTH, DP4, DP4
                OCT             16503                   # 56 ARTH, DP4, DP3
                OCT             00007                   # 57 DP3
                OCT             16347                   # 58 DP3, DP3, DP3
                OCT             16347                   # 59 DP3, DP3, DP3
                OCT             10347                   # 60 DP3, DP3, DP1
                OCT             24451                   # 61 M/S, M/S, DP4
                OCT             16447                   # 62 DP3, M/S, DP3
                OCT             10347                   # 63 DP3, DP3, DP1
                OCT             10354                   # 64 2INT, DP3, DP1
                OCT             20410                   # 65 HMS, HMS, HMS
                OCT             00304                   # 66 DP1, LRPOS
                OCT             10204                   # 67 DP1, DP1, DP1
                OCT             10452                   # 68 DP4, M/S, DP1
                OCT             16143                   # 69 ARTH, ARTH, DP3
                OCT             0                       # 70 OCT, OCT, OCT
                OCT             0                       # 71 OCT, OCT, OCT
                OCT             00115                   # 72 360-CDU, CDU
                OCT             00115                   # 73 360-CDU, CDU
                OCT             24511                   # 74M/S, DP4, DP4
                OCT             10351                   # 75 M/S, DP3, DP1
                OCT             00347                   # 76 DP3, DP3
                OCT             00351                   # 77 M/S, DP3
                OCT             00204                   # 78 DP1, DP1
                OCT             06102                   # 79 CDU, CDU, ARTH
                OCT             00503                   # 80 ARTH, DP4
                OCT             16347                   # 81 DP3, DP3, DP3
                OCT             16347                   # 82 DP3, DP3, DP3
                OCT             16347                   # 83 DP3, DP3, DP3
                OCT             16347                   # 84 DP3, DP3, DP3
                OCT             16347                   # 85 DP3, DP3, DP3
                OCT             16347                   # 86 DP3, DP3, DP3
                OCT             00102                   # 87 CDU, CDU
                OCT             02041                   # 88 FRAC FOR EACH
                OCT             10347                   # 89 DP3, DP3, DP1
                OCT             24344                   # 90 DP1, DP3, DP4
                OCT             16447                   # 91 DP3, M/S, DP3
                OCT             16441                   # 92 M/S, DP3
                OCT             16347                   # 93 DP3, DP3, DP3
                OCT             16447                   # 94 DP3, M/S, DP3
                OCT             04102                   # 95 CDU, CDU, CDU
                OCT             04102                   # 96 CDU, CDU, CDU
                OCT             06143                   # 97 ARTH, ARTH, ARTH
                OCT             06043                   # 98 ARTH, FRAC, ARTH
                OCT             00252                   # 99 DP4, DP2
# END OF RUTMXTAB


                SBANK=          LOWSUPER

