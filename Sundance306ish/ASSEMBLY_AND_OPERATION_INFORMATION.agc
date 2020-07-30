### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ASSEMBLY_AND_OPERATION_INFORMATION.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.


## This section, being entirely comments, is entirely guesswork. The noun tables reflect what is
## actually present in Sundance 306, while the remainder is based off of section 4 of the GSOP.

# THIS LGC PROGRAM IS INTENDED FOR USE IN THE LM DURING THE MANNED EARTH ORBITAL MISSION OR ANY SUBSET THEREOF.
# THE DETAILS OF IMPLEMENTATION ARE SPECIFIED IN REPORT R-557, AS AMENDED.


#                            GUIDANCE SYSTEM OPERATIONS PLAN
#                         FOR MANNED LM EARTH ORBITAL MISSIONS
#                                 USING PROGRAM SUNDANCE


# THIS PROGRAM AND R-557 HAVE BEEN PREPARED BY THE INSTRUMENTATION LABORATORY, MASSACHUSETTS INSTITUTE OF 
# TECHNOLOGY  75 CAMBRIDGE PARKWAY, CAMBRIDGE, MASSACHUSETTS UNDER PROJECT55-238-70, SPONSORED BY THE MANNED
# SPACECRAFT CENTER OF THE NATIONAL AERONAUTICS AND SPACE ADMINISTRATION, CONTRACT NAS 9-4065

# TABLE OF LOG CARDS

# ASSEMBLY AND OPERATION INFORMATION
# TAGS FOR RELATIVE SETLOC AND BLANK BANK CARDS
# INPUT/OUTPUT CHANNEL BIT DESCRIPTIONS
# SUBROUTINE CALLS


# TABLE OF SUBROUTINE LOG SECTIONS
#          LUMERASE
#                 ERASABLE ASSIGNMENTS
#          LEMONAID
#                 INTERRUPT LEAD INS
#                 T4RUPT PROGRAM
#                 RCS FAILURE MONITOR
#                 STAGE MONITOR
#                 DOWNLINK LISTS
#                 AGS INITIALIZATION
#                 FRESH START AND RESTART
#                 RESTART TABLES
#                 AOTMARK
#                 EXTENDED VERBS
#                 PINBALL NOUN TABLES
#                 LEM GEOMETRY
#                 IMU COMPENSATION PACKAGE
#                 R63
#                 ATTITUDE MANEUVER ROUTINE
#                 GIMBAL LOCK AVOIDANCE
#                 KALCMANU STEERING
#                 SYSTEM TEST STANDARD LEAD INS
#                 IMU PERFORMANCE TESTS 2
#                 IMU PERFORMANCE TESTS 4
#                 PINBALL GAMES BUTTONS AND LIGHTS
#                 R60,R62
#                 S-BAND ANTENNA FOR LM
#          LEMP10S
#                 P10,P11
#          LEMP20S
#                 RADAR LEADIN ROUTINES
#                 P20-P25
#          LEMP30S
#                 P30,P37
#                 P32-P35, P72-P75
#                 GENERAL LAMBERT AIMPOINT GUIDANCE
#          KISSING
#                 GROUND TRACKING DETERMINATION PROGRAM - P21
#                 P34-P35, P74-P75
#                 R31
#                 R32
#                 R30
#                 STABLE ORBIT - P38-P39
#          FLY
#                 BURN, BABY, BURN -- MASTER IGNITION ROUTINE
#                 P40-P47
#                 THE LUNAR LANDING
#                 R13
#                 THROTTLE CONTROL ROUTINES
#                 LUNAR LANDING GUIDANCE EQUATIONS
#                 P70-P71
#                 P12
#                 ASCENT GUIDANCE
#                 SERVICER
#                 LANDING ANALOG DISPLAYS
#                 FINDCDUW - GUIDAP INTERFACE
#          LEMP50S
#                 P51-P53
#                 LUNAR AND SOLAR EPHEMERIDES SUBROUTINES
#          SKIPPER
#                 DOWN-TELEMETRY PROGRAM
#                 INTER-BANK COMMUNICATION
#                 INTERPRETER
#                 FIXED-FIXED CONSTANT POOL
#                 INTERPRETIVE CONSTANTS
#                 SINGLE PRECISION SUBROUTINES
#                 EXECUTIVE
#                 WAITLIST
#                 LATITUDE LONGITUDE SUBROUTINES
#                 PLANETARY INERTIAL ORIENTATION
#                 MEASUREMENT INCORPORATION
#                 CONIC SUBROUTINES
#                 INTEGRATION INITIALIZATION
#                 ORBITAL INTEGRATION
#                 INFLIGHT ALIGNMENT ROUTINES
#                 POWERED FLIGHT SUBROUTINES
#                 TIME OF FREE FALL
#                 STAR TABLES
#                 AGC BLOCK TWO SELF-CHECK
#                 PHASE TABLE MAINTENANCE
#                 RESTARTS ROUTINE
#                 IMU MODE SWITCHING ROUTINES
#                 KEYRUPT, UPRUPT
#                 DISPLAY INTERFACE ROUTINES
#                 SERVICE ROUTINES
#                 ALARM AND ABORT
#                 UPDATE PROGRAM
#                 RTB OP CODES
#          LMDAP
#                 T6-RUPT PROGRAMS
#                 DAP INTERFACE SUBROUTINES
#                 DAPIDLER PROGRAM
#                 P-AXIS RCS AUTOPILOT
#                 Q,R-AXIS RCS AUTOPILOT
#                 TJET LAW
#                 KALMAN FILTER
#                 TRIM GIMBAL CONTROL SYSTEM
#                 AOSTASK AND AOSJOB
#                 SPS BACK-UP RCS CONTROL


#          SYMBOL TABLE LISTING
#          UNREFERENCED SYMBOL LISTING
#          ERASABLE & EQUALS CROSS-REFERENCE TABLE
#          SUMMARY OF SYMBOL TABLE LISTINGS
#          MEMORY TYPE & AVAILABLITY DISPLAY
#          COUNT TABLE
#          PARAGRAPHS GENERATED FOR THIS ASSEMBLY
#          OCTAL LISTING
#          OCCUPIED LOCATIONS TABLE
#          SUBROS CALLED & PROGRAM STATUS

#          VERB LIST FOR SUNDANCE

# REGULAR VERBS

# 00 NOT IN USE
# 01 DISPLAY OCTAL COMP 1 IN R1
# 02 DISPLAY OCTAL COMP 2 IN R1
# 03 DISPLAY OCTAL COMP 3 IN R1
# 04 DISPLAY OCTAL COMP 1,2 IN R1,R2
# 05 DISPLAY OCTAL COMP 1,2,3 IN R1,R2,R3
# 06 DISPLAY DECIMAL IN R1 OR R1,R2 OR R1,R2,R3
# 07 DISPLAY DP DECIMAL IN R1,R2 (TEST ONLY)
# 08
# 09
# 10
# 11 MONITOR OCTAL COMP 1 IN R1
# 12 MONITOR OCTAL COMP 2 IN R1
# 13 MONITOR OCTAL COMP 3 IN R1
# 14 MONITOR OCTAL COMP 1,2 IN R1,R2
# 15 MONITOR OCTAL COMP 1,2,3 IN R1,R2,R3
# 16 MONITOR DECIMAL IN R1 OR R1,R2 OR R1,R2,R3
# 17 MONITOR DP DECIMAL IN R1,R2 (TEST ONLY)
# 18
# 19
# 20
# 21 LOAD COMPONENT 1 INTO R1
# 22 LOAD COMPONENT 2 INTO R2
# 23 LOAD COMPONENT 3 INTO R3
# 24 LOAD COMPONENT 1,2 INTO R1,R2
# 25 LOAD COMPONENT 1,2,3 INTO R1,R2,R3
# 26
# 27 DISPLAY FIXED MEMORY
# 28
# 29
# 30 REQUEST EXECUTIVE
# 31 REQUEST WAITLIST
# 32 RECYCLE PROGRAM
# 33 PROCEED WITHOUT DSKY INPUTS
# 34 TERMINATE FUNCTION
# 35 TEST LIGHTS
# 36 REQUEST FRESH START
# 37 CHANGE PROGRAM (MAJOR MODE)
# 38
# 39

# EXTENDED VERBS

# 40 ZERO CDU-S
# 41 COARSE ALIGN CDU-S
# 42 FINE ALIGN IMU
# 43 LOAD IMU ATT ERROR METERS
# 44 TERMINATE RR CONTINUOUS DESIGNATE (V41N72 OPTION 2)
# 45 DISPLAY W MATRIX
# 46
# 47 INITIALIZE AGS (R47)
# 48 REQUEST DAP DATA LOAD ROUTINE (R03)
# 49 REQUEST CREW DEFINED MANEUVER ROUTINE (R62)
# 50 PLEASE PERFORM
# 51
# 52 MARK X-RETICLE
# 53 MARK Y-RETICLE
# 54 MARK X OR Y-RETICLE
# 55 INCREMENT AGC TIME (DECIMAL)
# 56 TERMINATE TRACKING (P20 + P25)
# 57
# 58
# 59
# 60 DISPLAY DAP FOLLOWING ATTITUDE ERRORS.
# 61 COMMAND LR TO POSITION 2.
# 62 SAMPLE RADAR ONCE PER SECOND (R04).
# 63 DISPLAY TOTAL ATTITUDE ERRORS WITH RESPECT TO NOUN 22.
# 64
# 65 DISABLE U AND V JET FIRINGS DURING DPS BURNS.
# 66 VEHICLES ARE ATTACHED.  MOVE THIS VEHICLE STATE TO OTHER VEHICLE.
# 67
# 68
# 69 CAUSE RESTART
# 70 UPDATE LIFTOFF TIME
# 71 UNIVERSAL UPDATE-BLOCK  ADR
# 72 UNIVERSAL UPDATE-SINGLE ADR
# 73 UPDATE AGC TIME (OCTAL)
# 74 INITIALIZE ERASABLE DUMP VIA DOWNLINK
# 75 ENABLE U AND V JET FIRINGS DURING DPS BURNS.
# 76 MINIMUM IMPULSE COMMAND MODE
# 77 RATE COMMAND AND ATTITUDE HOLD MODE
# 78 LR SPURIOUS RETURN TEST START (R77)
# 79 LR SPURIOUS RETURN TEST STOP
# 80 UPDATE LEM STATE VECTOR
# 81 UPDATE CSM STATE VECTOR
# 82 REQUEST ORBIT PARAM DISPLAY (R30)
# 83 REQUEST REND  PARAM DISPLAY (R31)
# 84 START TARGET DELTA V (R32)
# 85
# 86
# 87
# 88
# 89 REQUEST RENDEZVOUS FINAL ATTITUDE ROUTINE (R63)
# 90 REQUEST RENDEZVOUS OUT OF PLANE DISPLAY ROUTINE (R36)
# 91 DISPLAY BANK SUM
# 92 OPERATE IMU PERFORMANCE TEST (P07)
# 93 ENABLE W MATRIX INITIALIZATION
# 94
# 95 NO UPDATE OF EITHER STATE VECTOR (P20 OR P22)
# 96 INTERRUPT INTEGRATION AND GO TO POO
# 97
# 98
# 99 PLEASE ENABLE ENGINE

# IN THE FOLLOWING NOUN LIST THE :NO LOAD: RESTRICTION MEANS THE NOUN
# CONTAINS AT LEAST ONE COMPONENT WHICH CANNOT BE LOADED, I.E. OF
# SCALE TYPE L (MIN/SEC), PP (2 INTEGERS) OR TT (LANDING RADAR POSITION).
# IN THIS CASE VERBS 24 AND 25 ARE NOT ALLOWED, BUT VERBS 21, 22 OR 23
# MAY BE USED TO LOAD ANY OF THE NOUN:S COMPONENTS WHICH ARE NOT OF THE
# ABOVE SCALE TYPES.
# THE :DEC ONLY: RESTRICTION MEANS ONLY DECIMAL OPERATION IS ALLOWED ON
# EVERY COMPONENT IN THE NOUN. (NOTE THAT :NO LOAD: IMPLIES :DEC ONLY:.)

# NORMAL NOUNS                           COMPONENTS  SCALE AND DECIMAL POINT             RESTRICTIONS

# 00  NOT IN USE
# 01  SPECIFY MACHINE ADDRESS (FRACTIONAL)   3COMP   .XXXXX FOR EACH
# 02  SPECIFY MACHINE ADDRESS (WHOLE)        3COMP   XXXXX. FOR EACH
# 03  SPECIFY MACHINE ADDRESS (DEGREES)      3COMP   XXX.XX DEG FOR EACH
# 04  SPARE
# 05  ANGULAR ERROR/DIFFERENCE               1COMP   XXX.XX DEG
# 06  OPTION CODE                            2COMP   OCTAL ONLY FOR EACH
# LOADING NOUN 07 WILL SET OR RESET SELECTED BITS IN ANY ERASABLE REGISTER
# 07  ECADR OF WORD TO BE MODIFIED           3COMP   OCTAL ONLY FOR EACH
#     ONES FOR BITS TO BE MODIFIED
#     1 TO SET OR 0 TO RESET SELECTED BITS
# 08  ALARM DATA                             3COMP   OCTAL ONLY FOR EACH
# 09  ALARM CODES                            3COMP   OCTAL ONLY FOR EACH
# 10  CHANNEL TO BE SPECIFIED                1COMP   OCTAL ONLY
# 11  SPARE
# 12  SPARE
# 13  SPARE
# 14  CHECKLIST                              3COMP   XXXXX. FOR EACH
#      (USED BY EXTENDED VERBS ONLY)
#      (NOUN 25 IS PASTED AFTER DISPLAY)
# 15  INCREMENT MACHINE ADDRESS              1COMP   OCTAL ONLY
# 16  TIME OF EVENT                          3COMP   00XXX. HRS                          DEC ONLY
#      (USED BY EXTENDED VERBS ONLY)                 000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 17  ASTRONAUT TOTAL ATTITUDE               3COMP   XXX.XX DEG FOR EACH
# 18  AUTO MANEUVER BALL ANGLES              3COMP   XXX.XX DEG FOR EACH
# 19  BYPASS ATTITUDE TRIM MANEUVER          3COMP   XXX.XX DEG FOR EACH
# 20  ICDU ANGLES                            3COMP   XXX.XX DEG FOR EACH
# 21  PIPAS                                  3COMP   XXXXX. PULSES FOR EACH
# 22  NEW ICDU ANGLES                        3COMP   XXX.XX DEG FOR EACH
# 23  SPARE
# 24  DELTA TIME FOR AGC CLOCK               3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 25  CHECKLIST                              3COMP   XXXXX. FOR EACH
#      (USED WITH PLEASE PERFORM ONLY)
# 26  PRIORITY/DELAY, ADRES, BBCON           3COMP   OCTAL ONLY FOR EACH
# 27  SELF TEST ON/OFF SWITCH                1COMP   XXXXX.
# 28  SPARE
# 29  LANDING RADAR FLAG STATUS              1COMP   OCTAL ONLY
# 30  TIG OF CSI                             3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 31  TIG OF CDH                             3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 32  TIME FROM PERIGEE                      3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 33  TIME OF IGNITION                       3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 34  TIME OF EVENT                          3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 35  TIME FROM EVENT                        3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 36  TIME OF AGC CLOCK                      3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 37  TIG OF TPI                             3COMP   00XXX. HRS                          DEC ONLY
#                                                    000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 38  SPARE
# 39  SPARE

# MIXED NOUNS                            COMPONENTS  SCALE AND DECIMAL POINT             RESTRICTIONS

# 40  TIME FROM IGNITION/CUTOFF              3COMP   XXBXX  MIN/SEC                      NO LOAD, DEC ONLY
#     VG,                                            XXXX.X FT/SEC
#     DELTA V (ACCUMULATED)                          XXXX.X FT/SEC
# 41  TARGET  AZIMUTH,                       2COMP   XXX.XX DEG                          (FOR SYSTEM TEST)
#             ELEVATION                              XX.XXX DEG
# 42  APOGEE,                                3COMP   XXXX.X NAUT MI                      DEC ONLY
#     PERIGEE,                                       XXXX.X NAUT MI
#     DELTA V (REQUIRED)                             XXXX.X FT/SEC
# 43  LATITUDE,                              3COMP   XXX.XX DEG                          DEC ONLY
#     LONGITUDE,                                     XXX.XX DEG
#     ALTITUDE                                       XXXX.X NAUT MI
# 44  APOGEE,                                3COMP   XXXX.X NAUT MI                      NO LOAD, DEC ONLY
#     PERIGEE,                                       XXXX.X NAUT MI
#     TFF                                            XXBXX  MIN/SEC
# 45  MARKS,                                 3COMP   XXXXX.                              NO LOAD, DEC ONLY
#     TFI OF NEXT BURN                               XXBXX  MIN/SEC
#     MGA                                            XXX.XX DEG
# 46  AUTOPILOT CONFIGURATION                1COMP   OCTAL ONLY
# 47  LEM WEIGHT,                            2COMP   XXXXX. LBS                          DEC ONLY
#     CSM WEIGHT                                     XXXXX. LBS
# 48  GIMBAL PITCH TRIM,                     2COMP   XXX.XX DEG                          DEC ONLY
#     GIMBAL ROLL TRIM                               XXX.XX DEG
# 49  DELTA R,                               2COMP   XXXX.X NAUT MI                      DEC ONLY
#     DELTA V,                                       XXXX.X FT/SEC
# 50  DELTA ALTITUDE CDH                     3COMP   XXXX.X NAUT MI                      NO LOAD, DEC ONLY
#     DELTA TIME CDH-CSI                             XXBXX  MIN/SEC
#     DELTA TIME TPI-CDH                             XXBXX  MIN/SEC
# 51  S-BAND ANTENNA ANGLES PITCH            2COMP   XXX.XX DEG                          DEC ONLY
#                           YAW                      XXX.XX DEG
# 52  CENTRAL ANGLE OF ACTIVE VEHICLE        1COMP   XXX.XX DEG
# 53  DELTA V (CSI OR TPI)                   3COMP   XXXX.X FT/SEC                       DEC ONLY
#     DELTA V (CDH OR TPF)                           XXXX.X FT/SEC 
#     CROSS RANGE DISTANCE                           XXXX.X NAUT MI
# 54  RANGE,                                 3COMP   XXX.XX NAUT MI                      DEC ONLY
#     RANGE RATE,                                    XXXX.X FT/SEC
#     THETA                                          XXX.XX DEG
# 55  NO. OF APSIDAL CROSSINGS               3COMP   XXXXX.                              DEC ONLY
#     ELEVATION ANGLE                                XXX.XX DEG
#     CENTRAL ANGLE OF PASSIVE VEHICLE               XXX.XX DEG
# 56  NO. OF APSIDAL CROSSINGS               3COMP   XXXXX.                              DEC ONLY
#     ELEVATION ANGLE                                XXX.XX DEG
#     DESIRED DELTA H AT CDH                         XXXX.X NAUT MI
# 57  DELTA R                                1COMP   XXXX.X NAUT MI                      DEC ONLY
# 58  PERIGEE ALT (POST TPI)                 3COMP   XXXX.X NAUT MI                      DEC ONLY
#     DELTA V TPI                                    XXXX.X FT/SEC
#     DELTA V TPF                                    XXXX.X FT/SEC
# 59  DELTA VELOCITY LOS                     3COMP   XXXX.X FT/SEC FOR EA.               DEC ONLY
# 60  HORIZONTAL VELOCITY                    3COMP   XXXX.X FT/SEC                       DEC ONLY
#     ALTITUDE RATE                                  XXXX.X FT/SEC
#     COMPUTED ALTITUDE                              XXXXX. FEET
# 61  TIME TO GO IN BRAKING PHASE            3COMP   XXBXX  MIN/SEC                      NO LOAD, DEC ONLY
#     TIME FROM IGNITION                             XXBXX  MIN/SEC
#     CROSS RANGE DISTANCE                           XXXX.X NAUT MI
# 62  ABSOLUTE VALUE OF VELOCITY             3COMP   XXXX.X FT/SEC                       NO LOAD, DEC ONLY
#     TIME FROM IGNITION                             XXBXX  MIN/SEC
#     DELTA V (ACCUMULATED)                          XXXX.X FT/SEC
# 63  ABSOLUTE VALUE OF VELOCITY             3COMP   XXXX.X FT/SEC                       DEC ONLY
#     ALTITUDE RATE                                  XXXX.X FT/SEC
#     COMPUTED ALTITUDE                              XXXXX. FEET
# 64  TIME LEFT FOR REDESIGNATION- LPD ANGLE 3COMP   XXBXX                               NO LOAD, DEC ONLY
#     ALTITUDE RATE                                  XXXX.X FT/SEC
#     COMPUTED ALTITUDE                              XXXXX. FEET
# 65  SAMPLED AGC TIME                       3COMP   00XXX. HRS                          DEC ONLY
#      (FETCHED IN INTERRUPT)                        000XX. MIN                          MUST LOAD 3 COMPS
#                                                    0XX.XX SEC
# 66  LR RANGE                               2COMP   XXXXX. FEET                         NO LOAD, DEC ONLY
#        POSITION                                    +0000X
# 67  LRVX                                   3COMP   XXXXX. FT/SEC
#     LRVY                                           XXXXX. FT/SEC
#     LRVZ                                           XXXXX. FT/SEC
# 68  SLANT RANGE TO LANDING SITE            3COMP   XXXX.X NAUT MI                      NO LOAD, DEC ONLY
#     TIME TO GO IN BRAKING PHASE                    XXBXX  MIN/SEC
#     LR ALTITUDE - COMPUTED ALTITUDE                XXXXX. FEET
# 69  DELTA V LAST                           3COMP   XXXXX. CM/SEC                       DEC ONLY
#     DELTA V DVMON                                  XXXXX. CM/SEC 
#     DELTA V TOTAL                                  XXXX.X FT/SEC
# 70  AOT DETENT CODE/STAR CODE              3COMP   OCTAL ONLY FOR EACH
# 71  AOT DETENT CODE/STAR CODE              3COMP   OCTAL ONLY FOR EACH
# 72  RR  360 - TRUNNION ANGLE               2COMP   XXX.XX DEG
#         SHAFT ANGLE                                XXX.XX DEG
# 73  NEW RR  360 - TRUNNION ANGLE           2COMP   XXX.XX DEG
#             SHAFT ANGLE                            XXX.XX DEG
# 74  TIME FROM IGNITION                     3COMP   XXBXX  MIN/SEC                      NO LOAD, DEC ONLY
#     YAW AFTER VEHICLE RISE                         XXX.XX DEG
#     PITCH AFTER VEHICLE RISE                       XXX.XX DEG
# 75  TIME FROM IGNITION                     3COMP   XXBXX  MIN/SEC                      NO LOAD, DEC ONLY
#     DELTA V (ACCUMULATED)                          XXXX.X FT/SEC
#     COMPUTED ALTITUDE                              XXXXX. FEET
# 76  CROSS-RANGE DISTANCE                   2COMP   XXXX.X NAUT MI                      DEC ONLY
#     APOCYNTHION ALTITUDE                           XXXX.X NAUT MI
# 77  TIME TO ENGINE CUTOFF                  2COMP   XXBXX  MIN/SEC                      NO LOAD, DEC ONLY
#     VELOCITY NORMAL TO CSM PLANE                   XXXX.X FT/SEC
# 78  RR RANGE                               2COMP   XXX.XX NAUT MI    
#        RANGE RATE                                  XXXXX. FT/SEC
# 79  CURSOR ANGLE                           3COMP   XXX.XX DEG                          DEC ONLY
#     SPIRAL ANGLE                                   XXX.XX DEG
#     POSITION CODE                                  XXXXX.
# 80  DATA INDICATOR,                        2COMP   XXXXX.
#     OMEGA                                          XXX.XX DEG
# 81  DELTA V (LV)                           3COMP   XXXX.X FT/SEC FOR EACH              DEC ONLY
# 82  DELTA V (LV)                           3COMP   XXXX.X FT/SEC FOR EACH              DEC ONLY
# 83  DELTA V (BODY)                         3COMP   XXXX.X FT/SEC FOR EACH              DEC ONLY
# 84  DELTA V (OTHER VEHICLE)                3COMP   XXXX.X FT/SEC FOR EACH              DEC ONLY
# 85  VG (BODY)                              3COMP   XXXX.X FT/SEC FOR EACH              DEC ONLY
# 86  VG (LV)                                3COMP   XXXX.X FT/SEC FOR EACH              DEC ONLY
# 87  BACKUP OPTICS LOS AZIMUTH              2COMP   XXX.XX DEG
#                      ELEVATION                     XXX.XX DEG
# 88  HALF UNIT SUN OR PLANET VECTOR         3COMP   .XXXXX FOR EACH                     DEC ONLY
# 89  LANDMARK LATITUDE                      3COMP   XX.XXX DEG                          DEC ONLY
#              LONGITUDE/2                           XX.XXX DEC
#              ALTITUDE                              XXX.XX NAUT MI
# 90  Y                                      3COMP   XXX.XX NM                           DEC ONLY
#     Y DOT                                          XXXX.X FPS
#     PSI                                            XXX.XX DEG
# 91  TPI ALTITUDE                           3COMP   XXXX.X NAUT MI                      NO LOAD, DEC ONLY
#     TIME FROM LAUNCH TO TPI                        XXBXX  MIN/SEC
#     ANGLE FROM LAUNCH TO TPI                       XXXX.X DEG
# 92  SPARE COMPONENT                        3COMP   BLANK                               NO LOAD, DEC ONLY
#     TIME FROM LAUNCH TO TPF                        XXBXX  MIN/SEC
#     ANGLE FROM LAUNCH TO TPF                       XXXX.X DEG
# 93  DELTA GYRO ANGLES                      3COMP   XX.XXX DEG FOR EACH
# 94  CSI ALTITUDE                           3COMP   XXXX.X NAUT MI                      NO LOAD, DEC ONLY
#     TIME FROM LAUNCH TO CSI                        XXBXX  MIN/SEC
#     ANGLE FROM LAUNCH TO CSI                       XXXX.X DEG
# 95  PREFERRED ATTITUDE ICDU ANGLES         3COMP   XXX.XX DEG FOR EACH
# 96  +X-AXIS ATTITUDE ICDU ANGLES           3COMP   XXX.XX DEG FOR EACH
# 97  SYSTEM TEST INPUTS                     3COMP   XXXXX. FOR EACH
# 98  SYSTEM TEST RESULTS AND INPUTS         3COMP   XXXXX.
#                                                    .XXXXX
#                                                    XXXXX.
# 99  RMS IN POSITION                        2COMP   XXX.XX NAUT MI                      DEC ONLY
#     RMS IN VELOCITY                                XXXX.X FT/SEC

# REGISTERS AND SCALING FOR NORMAL NOUNS

# NOUN            REGISTER       SCALE TYPE

# 00       NOT IN USE
# 01       SPECIFY ADDRESS       B
# 02       SPECIFY ADDRESS       C
# 03       SPECIFY ADDRESS       D
# 04       SPARE
# 05              DSPTEM1        H
# 06              OPTION1        A
# 07              XREG           A
# 08              ALMCADR        A
# 09              FAILREG        A
# 10       SPECIFY CHANNEL       A
# 11       SPARE
# 12       SPARE
# 13       SPARE
# 14              DSPTEMX        C
# 15       INCREMENT ADDRESS     A
# 16              DSPTEMX        C
# 17              CPHIX          D
# 18              FDAIX          D
# 19              FDAIX          D
# 20              CDUX           D
# 21              PIPAX          C
# 22              THETAD         D
# 23       SPARE
# 24              DSPTEM2 +1     K
# 25              DSPTEM1        C
# 26              DSPTEM1        A
# 27              SMODE          C
# 28       SPARE
# 29              LRFLAGS        A
# 30              TCSI           K
# 31              TCDH           K
# 32              -TPER          K
# 33              TIG            K
# 34              DSPTEM1        K
# 35              TTOGO          K
# 36              TIME2          K
# 37              TTPI           K
# 38       SPARE
# 39       SPARE

# REGISTERS AND SCALING FOR MIXED NOUNS

# NOUN     COMP   REGISTER        SCALE TYPE

# 40       1      TTOGO            L
#          2      VGDISP           S
#          3      DVTOTAL          S
# 41       1      DSPTEM1          D
#          2      DSPTEM1 +1       E
# 42       1      HAPO             Q
#          2      HPER             Q
#          3      VGDISP           S
# 43       1      LAT              H
#          2      LONG             H
#          3      ALT              Q
# 44       1      HAPOX            Q
#          2      HPERX            Q
#          3      TFF              L
# 45       1      TRKMKCNT         C
#          2      TTOGO            L
#          3      +MGA             H
# 46       1      DAPDATR1         A
# 47       1      LEMMASS          KK
#          2      CSMMASS          KK
# 48       1      PITTIME          NN
#          2      ROLLTIME         NN
# 49       1      R22DISP          Q
#          2      R22DISP +2       S
# 50       1      DIFFALT          Q
#          2      T1TOT2           L
#          3      T2TOT3           L
# 51       1      ALPHASB          H
#          2      BETASB           H
# 52       1      ACTCENT          H
# 53       1      DELVTPI          S
#          2      DELVTPF          S
#          3      P1XMAX           Q
# 54       1      RANGE            JJ
#          2      RRATE            S
#          3      RTHETA           H
# 55       1      NN               C
#          2      ELEV             H
#          3      CENTANG          H
# 56       1      NN               C
#          2      ELEV             H
#          3      CDHDELH          Q
# 57       1      DELTAR           Q
# 58       1      POSTTPI          Q
#          2      DELVTPI          S
#          3      DELVTPF          S
# 59       1      DVLOS            S
#          2      DVLOS +2         S
#          3      DVLOS +4         S
# 60       1      VHORIZ           S
#          2      HDOTDISP         S
#          3      HCALC            RR
# 61       1      TTFDISP          L
#          2      TTOGO            L
#          3      OUTOFPLN         QQ
# 62       1      ABVEL            S
#          2      TTOGO            L
#          3      DVTOTAL          S
# 63       1      ABVEL            S
#          2      HDOTDISP         S
#          3      HCALC            RR
# 64       1      FUNNYDSP         PP
#          2      HDOTDISP         S
#          3      HCALC            RR
# 65       1      SAMPTIME         K
#          2      SAMPTIME         K
#          3      SAMPTIME         K
# 66       1      RSTACK +6        W
#          2      CHANNEL  33      TT
# 67       1      RSTACK           X
#          2      RSTACK +2        Y
#          3      RSTACK +4        Z
# 68       1      RANGEDSP         QQ
#          2      TTFDISP          L
#          3      DELTAH           RR
# 69       1      ABDELV           C
#          2      DVTHRUSH         C
#          3      DVTOTAL          S
# 70       1      AOTCODE          A
#          2      AOTCODE +1       A
#          3      AOTCODE +2       A
# 71       1      AOTCODE          A
#          2      AOTCODE +1       A
#          3      AOTCODE +2       A
# 72       1      CDUT             WW
#          2      CDUS             D
# 73       1      TANG             WW
#          2      TANG +1          D
# 74       1      TTOGO            L
#          2      YAW              H
#          3      PITCH            H
# 75       1      TTOGO            L
#          2      DVTOTAL          S
#          3      HCALC            RR
# 76       1      XRANGE           Q
#          2      APO              Q
# 77       1      TTOGO            L
#          2      YDOT             S
# 78       1      RSTACK           U
#          2      RSTACK +2        V
# 79       1      CURSOR           D
#          2      SPIRAL           D
#          3      POSCODE          C
# 80       1      DATAGOOD         C
#          2      OMEGAD           H
# 81       1      DELVLVC          S
#          2      DELVLVC +2       S
#          3      DELVLVC +4       S
# 82       1      DELVLVC          S
#          2      DELVLVC +2       S
#          3      DELVLVC +4       S
# 83       1      DELVIMU          S
#          2      DELVIMU +2       S
#          3      DELVIMU +4       S
# 84       1      DELVOV           S
#          2      DELVOV +2        S
#          3      DELVOV +4        S
# 85       1      VGBODY           S
#          2      VGBODY +2        S
#          3      VGBODY +4        S
# 86       1      DELVLVC          S
#          2      DELVLVC +2       S
#          3      DELVLVC +4       S
# 87       1      AZ               D
#          2      EL               D
# 88       1      STARAD           B
#          2      STARAD +2        B
#          3      STARAD +4        B
# 89       1      LANDLAT          G
#          2      LANDLONG         G
#          3      LANDALT          JJ
# 90       1      RANGE            JJ
#          2      RRATE            S
#          3      RTHETA           H
# 91       1      INJALT           Q
#          2      TPITIME          L
#          3      TPIANGLE         SS
# 92       2      INJTIME          L
#          3      INJANGLE         SS
# 93       1      OGC              G
#          2      OGC +2           G
#          3      OGC +4           G
# 94       1      INJALT           Q
#          2      INJTIME          L
#          3      INJANGLE         SS
# 95       1      CPHI             D
#          2      CTHETA           D
#          3      CPSI             D
# 96       1      CPHIXATT         D
#          2      CPHIXATT +1      D
#          3      CPHIXATT +2      D
# 97       1      DSPTEM1          C
#          2      DSPTEM1 +1       C
#          3      DSPTEM1 +2       C
# 98       1      DSPTEM2          C
#          2      DSPTEM2 +1       B
#          3      DSPTEM2 +2       C
# 99       1      WWPOS            XX
#          2      WWVEL            YY

# NOUN SCALES AND FORMATS

# -SCALE TYPE-                        PRECISION
# UNITS                DECIMAL FORMAT        -- AGC FORMAT
# ------------         --------------        -- ----------

# -A-
# OCTAL                XXXXX                 SP OCTAL

# -B-                                                    -14
# FRACTIONAL           .XXXXX                SP BIT 1 = 2    UNITS
#                      (MAX .99996)

# -C-
# WHOLE                XXXXX.                SP BIT 1 = 1 UNIT
#                      (MAX 16383.)

# -D-                                                        15
# CDU DEGREES          XXX.XX DEGREES        SP BIT 1 = 360/2   DEGREES
#                      (MAX 359.99)             (USES 15 BITS FOR MAGNI-
#                                                TUDE AND 2-S COMP.)

# -E-                                                       14
# ELEVATION DEGREES    XX.XXX DEGREES        SP BIT 1 = 90/2   DEGREES
#                      (MAX 89.999)

# -F-                                                        14
# DEGREES (180)        XXX.XX DEGREES        SP BIT 1 = 180/2   DEGREES
#                      (MAX 179.99)

# -G-
# DP DEGREES (90)      XX.XXX DEGREES        DP BIT 1 OF LOW REGISTER =
#                                                    28
#                                               360/2   DEGREES

# -H-
# DP DEGREES (360)     XXX.XX DEGREES        DP BIT 1 OF LOW REGISTER =
#                                                    28
#                      (MAX 359.99)             360/2   DEGREES

# -K-
# TIME (HR, MIN, SEC)  00XXX. HR             DP BIT 1 OF LOW REGISTER =
#                      000XX. MIN                 -2
#                      0XX.XX SEC               10   SEC
#                      (DECIMAL ONLY.
#                      MAX MIN COMP=59
#                      MAX SEC COMP=59.99
#                      MAX CAPACITY=745 HRS
#                                    39 MINS
#                                    14.55 SECS.
#                      WHEN LOADING, ALL 3
#                      COMPONENTS MUST BE
#                      SUPPLIED.)

# -L-
# TIME (MIN/SEC)       XXBXX MIN/SEC         DP BIT 1 OF LOW REGISTER =
#                      (B IS A BLANK              -2
#                      POSITION, DECIMAL        10   SEC
#                      ONLY, DISPLAY OR
#                      MONITOR ONLY. CANNOT
#                      BE LOADED.
#                      MAX MIN COMP=59
#                      MAX SEC COMP=59
#                      VALUES GREATER THAN
#                      59 MIN 59 SEC
#                      ARE DISPLAYED AS
#                      59 MIN 59 SEC.)

# -M-                                                     -2
# TIME (SEC)           XXX.XX SEC            SP BIT 1 = 10   SEC
#                      (MAX 163.83)

# -N-
# TIME(SEC) DP         XXX.XX SEC            DP BIT 1 OF LOW REGISTER =
#                                                 -2
#                                               10   SEC

# -P-
# VELOCITY 2           XXXXX. FEET/SEC       DP BIT 1 OF HIGH REGISTER =
#                      (MAX 41994.)              -7
#                                               2   METERS/CENTI-SEC

# -Q-
# POSITION 4           XXXX.X NAUTICAL MILES DP BIT 1 OF LOW REGISTER =
#                                               2 METERS

# -S-
# VELOCITY 3           XXXX.X FT/SEC         DP BIT 1 OF HIGH REGISTER =
#                                                -7
#                                               2   METERS/CENTI-SEC

# -T-                                                     -2
# G                    XXX.XX G              SP BIT 1 = 10   G
#                      (MAX 163.83)

# -U-
# RENDEZVOUS           XXX.XX NAUT MI        DP LOW ORDER BIT OF LOW ORDER
# RADAR RANGE                                   WORD = 9.38 FEET

# -V-
# RENDEZVOUS           XXXXX. FEET/SEC       DP LOW ORDER BIT OF LOW ORDER
# RADAR RANGE RATE                              WORD = -.6278 FEET/SEC

# -W-
# LANDING RADAR        XXXXX. FEET           DP LOW ORDER BIT OF LOW ORDER
# ALTITUDE                                      WORD = 1.079 FEET

# -X-
# LANDING RADAR        XXXXX. FEET/SEC       DP LOW ORDER BIT OF LOW ORDER
# VELX                                          WORD = -.6440 FEET/SEC

# -Y-
# LANDING RADAR        XXXXX. FEET/SEC       DP LOW ORDER BIT OF LOW ORDER
# VELY                                          WORD = 1.212  FEET/SEC

# -Z-
# LANDING RADAR        XXXXX. FEET/SEC       DP LOW ORDER BIT OF LOW ORDER
# VELZ                                          WORD = .8668  FEET/SEC

# -AA-
# INITIAL/FINAL        XXXXX. FEET           DP LOW ORDER BIT OF LOW ORDER
# ALTITUDE                                      WORD = 2.345 FEET

# -BB-
# ALTITUDE RATE        XXXXX. FEET/SEC       SP LOW ORDER BIT = .5
#                      (MAX 08191.)             FEET/SEC

# -CC-
# FORWARD/LATERAL      XXXXX. FEET/SEC       SP LOW ORDER BIT = .5571
# VELOCITY             (MAX 09126.)             FEET/SEC

# -DD-
# ROTATIONAL HAND      XXXXX. DEG/SEC        SP FRACTIONAL PART OF PI RAD
# CONTROLLER ANGULAR   (MAX 00044.)                                4  SEC
# RATES

# -EE-
# OPTICAL TRACKER      XXX.XX DEG.           DP LOW ORDER BIT OF LOW ORDER
# AZIMUTH ANGLE                                             15
#                                               WORD = 360/2   DEGREES

# -JJ-
# POSITION5            XXX.XX NAUT MI        DP BIT 1 OF LOW REGISTER =
#                                               2 METERS

# -KK-                                                              16
# WEIGHT2              XXXXX. LBS            SP FRACTIONAL PART OF 2   KG

# -NN-
# TRIM DEGREES 2       XXX.XX DEG            SP BIT 1=.01SEC(TIME)
#                      (MAX 032.76)

# -PP-
# 2 INTEGERS           +XXBYY                DP BIT 1 OF HIGH REGISTER =
#                      (B IS A BLANK             1 UNIT OF XX
#                      POSITION. DECIMAL        BIT 1 OF LOW REGISTER =
#                      ONLY, DISPLAY OR          1 UNIT OF YY
#                      MONITOR ONLY. CANNOT     (EACH REGISTER MUST 
#                      BE LOADED.)              CONTAIN A POSITIVE INTEGER
#                      (MAX 99B99)               LESS THAN 100)

# -QQ-
# POSITION7            XXXX.X NAUT MI        DP BIT 1 OF LOW REGISTER =
#                      (MAX 9058.9)              -4
#                                               2   METERS

# -RR-
# COMPUTED ALTITUDE    XXXXX. FEET           DP BIT 1 OF LOW REGISTER =
#                                                -4
#                                               2   METERS

# -SS-
# DP DEGREES           XXXX.X DEGREES        DP BIT 1 OF HIGH REGISTER =
#                                               1 DEGREE

# -TT-
# LANDING RADAR        +0000X                CHANNEL 33,BIT 6=NOT POSIT. 1
# POSITION             (DECIMAL ONLY.        CHANNEL 33,BIT 7=NOT POSIT. 2
#                      DISPLAY OR MONITOR    X = 1 FOR LR POSITION 1
#                      ONLY. CANNOT BE       X = 2 FOR LR POSITION 2
#                      LOADED.)

# -WW-                                                              15
# 360-CDU DEGREES      XXX.XX DEGREES        SP BIT 1 = 360 - (360/2  )
#                      (MAX 359.99)             DEGREES
#                                               (USES 15 BITS FOR MAGNI-
#                                                TUDE AND 2-S COMP.)

# -XX-
# POSITION 9           XXX.XX NAUT MI        DP BIT 1 OF LOW REGISTER =
#                      (MAX 283.09)              -9
#                                               2   METERS

# -YY-
# VELOCITY 4           XXXX.X FEET/SEC       DP FRACTIONAL PART OF
#                      (MAX 328.0)              METERS/CENTI-SEC
# THAT-S ALL ON THE NOUNS.

# ALARM CODES FOR SUNDANCE

# *9       *18                                       *60   COLUMN

# CODE   * TYPE                                      SET BY

# 00105    AOTMARK SYSTEM IN USE                
# 00107    MORE THAN 5 MARK PAIRS                    AOTMARK
# 00111    MARK MISSING                              AOTMARK
# 00112    MARK OR MARK REJECT NOT BEING ACCEPTED    AOTMARK
# 00113    NO INBITS                                 AOTMARK
# 00114    MARK MADE BUT NOT DESIRED                 AOTMARK
# 00115    NO MARKS IN LAST PAIR TO REJECT           AOTMARK
# 00206    ZERO ENCODE NOT ALLOWED WITH COARSE ALIGN IMU MODE SWITCHING
# 00206     + GIMBAL LOCK.
# 00207    ISS TURNON REQUEST NOT PRESENT FOR 90 SEC T4RUPT
# 00210    IMU NOT OPERATING                         IMU MODE SWITCH, IMU-2, R02, P51
# 00211    COARSE ALIGN ERROR                        IMU MODE SWITCH
# 00212    PIPA FAIL BUT PIPA IS NOT BEING USED      IMU MODE SWITCH,T4RPT
# 00213    IMU NOT OPERATING WITH TURN-ON REQUEST    T4RUPT
# 00214    PROGRAM USING IMU WHEN TURNED OFF         T4RUPT
# 00215    PREFERRED ORIENTATION SELECTED BUT        P52
# 00215     NOT SPECIFIED
# 00217    BAD RETURN STALL ROUTINES                 CURTAINS
# 00220    IMU NOT ALIGNED - NO REFSMMAT             R02,R47
# 00401  * DESIRED GIMBAL ANGLE YIELDS GIMBAL LOCK   INF ALIGN, IMU-2, R60
# 00405    TWO STARS NOT AVAILABLE                   P52
# 00421    W-MATRIX OVERFLOW                         INTEGRV
# 00501    RADAR ANTENNA BEYOND PRESENT MODE LIMITS  R23
# 00502    LOS OUTSIDE OF LIMITS OF BOTH RR ANTENNA  V41N72
# 00502     MODES
# 00503    RADAR ANTENNA DESIGNATE FAIL              R21, V41N72
# 00510    RADAR AUTO DESCRETE NOT PRESENT           R25
# 00514    RADAR GOES OUT OF AUTO MODE WHILE IN USE  R25
# 00515    RR CDU FAIL DISCRETE PRESENT              R25
# 00520    RADARUPT NOT EXPECTED AT THIS TIME        P20
# 00521    RR DATA GOOD NOT PRESENT                  P20
# 00522    LANDING RADAR POSITION CHANGE             RADAR READ
# 00523    LR ANTENNA DIDN'T ACHIEVE POSITION 2      V61
# 00525    DELTA THETA GREATER THAN 3 DEGREES        R22
# 00526    RANGE GREATER THAN 400 MILES              P20
# 00527    LOS OUTSIDE OF ANTENNA MODE LIMITS        R24
# 00600    IMAGINARY ROOTS ON FIRST ITERATION        P32
# 00601    PERICTR ALTITUDE(POST CSI) LESS THAN 85NM P32
# 00602    PERICTR ALTITUDE(POST CDH) LESS THAN 85NM P32
# 00603    CSI TO CDH TIME LESS THAN 10 MIN          P32
# 00604    CDH TO TPI TIME LESS THAN 10 MIN          P32
# 00605    NUMBER OF ITERATIONS EXCEEDS LOOP MAXIMUM P32
# 00606    DV EXCEEDS MAXIMUM                        P32
# 00611    NO GETI FOR GIVEN ELEV ANGLE              P33,P34
# 00777    PIPA FAIL CAUSED THE ISS WARNING          T4RUPT
# 01102    AGC SELF TEST ERROR                       SELF CHECK
# 01103  * UNUSED CCS BRANCH EXECUTED                ABORT
# 01104  * DELAY ROUTINE BUSY                        EXEC
# 01105    DOWNLINK TOO FAST                         T4RUPT
# 01106    UPLINK TOO FAST                           T4RUPT
# 01107    PHASE TABLE FAILURE.  ASSUME ERASABLE     RESTART
#          MEMORY IS DESTROYED.                      RESTART
# 01201  * EXECUTIVE OVERFLOW-NO VAC AREAS           EXEC
# 01202  * EXECUTIVE OVERFLOW-NO CORE SETS           EXEC
# 01203  * WAITLIST OVERFLOW-TOO MANY TASKS          WAITLIST
# 01206  * SECOND JOB ATTEMPTS TO GO TO SLEEP VIA    PINBALL
# 01206     KEYBOARD AND DISPLAY PROGRAM
# 01207  * NO VAC AREAS FOR MARKS                    AOTMARK
# 01210  * TWO PROGRAMS USING DEVICE AT SAME TIME    IMU MODE SWITCH
# 01211  * ILLEGAL INTERRUPT OF EXTENDED VERB        AOTMARK
# 01301    ARCSIN-ARCCOS ARGUMENT TOO LARGE          INTERPRETER
# 01302  * SQRT CALLED WITH NEGATIVE ARGUMENT. ABORT INTERPRETER
# 01407    VG INCREASING                             S40.8
# 01501  * KEYBOARD AND DISPLAY ALARM DURING         PINBALL
# 01501    INTERNAL USE (NVSUB).ABORT
# 01502  * ILLEGAL FLASHING DISPLAY                  GOPLAY
# 01520    V37 REQUEST NOT PERMITTED AT THIS TIME    V37
# 01600    OVERFLOW IN DRIFT TEST                    OPT PRE ALIGN CALIB
# 01600                                              IMU 4 (LEM)
# 01601    BAD IMU TORQUE                            OPT PRE ALIGN CALIB
# 01601                                              IMU 4 (LEM)
# 01703    LESS THAN 45 SECS TO IGNITION             P41, P42
# 01706    CSM DOCKED BIT SET IN ASCENT(NO SUCH DAP) R03
# 01706     P40 SELECTED WITH DESCENT UNIT STAGED
# 01706     P42 SELECTED WITHOUT DESCENT UNIT STAGED
# 01711    STATE VECTOR INTEGRATION NOT FINISHED     P40, P41, P42
# 01711     PRIOR TO TIG - 30 SECONDS.
# 02000  * DAP STILL IN PROGRESS AT NEXT TIME5 RUPT  DAP
# 02001    JET FAILURES HAVE DISABLED Y-Z TRANS.     DAP
# 02002    JET FAILURES HAVE DISABLED X TRANSLATION  DAP
# 02003    JET FAILURES HAVE DISABLED P-ROTATION     DAP
# 02004    JET FAILURES HAVE DISABLED U-V ROTATION   DAP
# 03777    ICDU FAIL CAUSED THE ISS WARNING          T4RUPT
# 04777    ICDU , PIPA FAILS CAUSED THE ISS WARNING  T4RUPT
# 07777    IMU FAIL CAUSED THE ISS WARNING           T4RUPT
# 10777    IMU , PIPA FAILS CAUSED THE ISS WARNING   T4RUPT
# 13777    IMU , ICDU  FAILS CAUSED THE ISS WARNING  T4RUPT
# 14777    IMU,ICDU,PIPA FAILS CAUSED THE ISSWNING   T4RUPT
#        * INDICATES AN ABORT TYPE. ALL OTHERS ARE NON-ABORTIVE EXCEPT
#          401 WHICH IS BOTH.

#          CHECKLIST CODES FOR SUNDANCE

# *9      *17      *26                                                    *9   COLUMN

# R1CODE          ACTION TO BE EFFECTED                                   PROGRAM

# 00011   KEY IN   AUTO OPTICS POSITIONING OPTION
# 00012   KEY IN   TARGET DATA
# 00014   KEY IN   FINE ALIGN OPTION                                      P51
# 00015   PERFORM  CELESTIAL BODY ACQUISITION                             R51,P51
# 00016   KEY IN   TERMINATE MARK OPTION
# 00017   PERFORM  ADDITIONAL SIGHTINGS
# 00031   KEY IN   ENGINE ON OPTION
# 00035   PERFORM  LGC PREPARATION
# 00036   PERFORM  THRUST TERMINATION
# 00062   SWITCH   AGC POWER DOWN                                         P06
# 00201   SWITCH   RR MODE TO AUTOMATIC                                   P20,P22,R04
# 00202   KEY IN   SIGHTING CHECK OPTION
# 00203   SWITCH   GUIDANCE CONT TO GNC, MODE TO AUTO, THR CONT TO AUTO   P40,P42
# 00204   KEY IN   ENABLE GIMBAL TRIM OPTION
# 00205   PERFORM  MANUAL ACQUISITION OF CSM WITH RR                      R23

#                    SWITCH DENOTES CHANGE POSITION OF A CONSOLE SWITCH
#                    PERFORM DENOTES START OR END OF A TASK
#                    KEY IN DENOTES KEY IN OF DATA THRU THE DSKY

#         OPTION CODES FOR SUNDANCE

# THE SPECIFIED OPTION CODES WILL BE FLASHED IN COMPONENT R1 IN
# CONJUNCTION WITH V04N06 OR V04N12 (FOR EXTENDED VERBS) TO REQUEST THE
# ASTRONAUT TO LOAD INTO COMPONENT R2 THE OPTION HE DESIRES.

# *9      *17                                *52                            *11           *25   COLUMN

# OPTION
# CODE    PURPOSE                            INPUT FOR COMPONENT 2          PROGRAM(S)    APPLICABILITY

# 00001   SPECIFY IMU ORIENTATION            1=PREF 2=NOM 3=REFSMMAT        P52           ALL
#                                            4=LAND SITE
# 00002   SPECIFY VEHICLE                    1=THIS 2=OTHER                 P21,R30       ALL
# 00003   SPECIFY TRACKING ATTITUDE          1=PREFERRED 2=OTHER            R63           ALL
# 00004   SPECIFY RADAR                      1=RR 2=LR                      R04           SUNDANCE + LUMINARY
# 00006   SPECIFY RR COARSE ALIGN OPTION     1=LOCKON 2=CONTINUOUS DESIG.   V41N72        SUNDANCE + LUMINARY

