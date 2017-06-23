### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MISSION_PHASE_11_-_DPS2_FITH_APS1.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 693-703
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-06 HG   Transcribed
##              2017-06-15 HG   Fix operator TCF -> TC
##                                  operand  IBNKCALL -> BANKCALL
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 693
                BANK            36
                EBANK=          TDEC
EMP11JOB        EQUALS          MPRETRN
# MISSION PHASE 11 DOES PROG32-PREDPS2, PROG42-DPS2 BURN BRAKING GUIDANCE,
# PROG43-APPROACH GUIDANCE, PROG43-RANDOM THROTTLE PROGRAM AND PROG74-THE
# FIRE-IN-THE-HOLE AND APS1 BURN

# THE APPROXIMATE STARTING TIME OF THESE PROG IS SHOWN BELOW

# T       PROG32
# T+187   DPS2 IGNITION (TIG11)
# TIG+26  PROG42
# TIG+705 PROG44
# TIG+757 PROG74
# TIG+792 MISSION TERMINATED



MP11JOB         EXTEND
                DCA             TIME2
                DXCH            TDEC
                TC              NEWMODEX                # SET DISPLAY
                OCT             32

                CAF             1SEC11                  # SETUP MP11 TASK-REQUIRES 75 SECS AND
                INHINT                                  # TERMINATES ITSELF
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP11TASK

                RELINT

                CAF             135SECS                 # SET TDEC =TIG-50
                TS              L
                CAF             ZERO
                DAS             TDEC

                EXTEND                                  # SET RETURN FROM MIDTOAVE TO INTRTN
                DCA             MDAVADR
                DXCH            Z                       # DO MIDTOAVE VIA RVUPDATE

INTRTN          EXTEND
                DCA             DPS2ADR                 # INTEGRATION DONE-DO PRE-DPS2
                DXCH            Z                       # STATE AT RIGNTION-TIME AT TET FOR PREDPS

#  PRE-DPS2 RETURN TO RETPREB WITH ULLAGE-ON TIME AT TULLG, (TIG-7.5).
# THE DESIRED 1/2 UNIT THRUST VECTOR AT POINTVSM.
#  STATE VECTOR IN SM COORDINATES STORED AT RN, VN WITH CORRESPONDING
#  TIME AT PIPTIME WHERE (TULLG - PIPTIME)IS BETWEEN
#  3.8 AND 6 SECS.

## Page 694

RETPREB         INHINT
                EXTEND
                DCA             TULLG                   # C(TULLG)=TIG-7.5
                DXCH            MPAC
                CS              22.5SECS
                TS              L
                CAF             ZERO
                TS              MPAC            +2
                DAS             MPAC                    # C(MPAC)=TIG-30
                EXTEND
                DCS             TIME2                   # GET CURRENT TIME
                DAS             MPAC                    # C(MPAC)=DELTA(TIG-30)
                TC              TPAGREE                 # MAKE SIGNS AGREE
                DXCH            MPAC

                TC              LONGCALL
                EBANK=          TDEC
                2CADR           TIG11-30

                RELINT

                TC              INTPRET
                VLOAD
                                RN                      # STATE STORED IN RAVEGON AND VAVEGON FOR
                STOVL           RAVEGON                 # AVERAGE G INITIALIZATION AT PIPTIME
                                VN
                STODL           VAVEGON
                                D1/2                    # JAM .5,0,0 IN SCAXIS FOR KALCMANU
                STODL           SCAXIS
                                DZERO
                STORE           SCAXIS          +2
                STODL           SCAXIS          +4
                                PIPTIME                 # THIS TIME CONSISTANT WITH STATE-RAVEGON
                STORE           DT11TEMP                # USED AFTER KALCMANU TO CALL PREREAD
                SSP             SET
                                RATEINDX                # SET KALCMANU FOR ANGULAR RATE OF 5 DEG/S
                                4
                                33D

                EXIT

                CAF             PRIO30                  # DO ATTITUDE MANEUVER JOB
                INHINT
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

                TC              BANKCALL
                CADR            ATTSTALL                # PUT MP11 TO SLEEP - KALCMANU WILL WAKE

                TC              CURTAINS                # KALCMANU HAS GIMBALOC PROBLEMS-CURTAINS
                TC              ENDOFJOB                # WAIT FOR TIG-30

## Page 695

TIG11-30        CAF             BIT11                   # SEE IF ATTITUDE MANEUVER DONE
                MASK            FLAGWRD2
                CCS             A
                TC              DOCURTN                 # KALCMANU NOT-DO CURTJOB
                TC              NEWMODEX                # SET MODE TO PROG42
                OCT             42

                EXTEND
                DCS             TIME2                   # GET PIPTIME-TIME2
                DAS             DT11TEMP
                CCS             DT11TEMP        +1
                AD              ONE                     # MAKE SURE OF POSITIVE WAITLIST CALL
                TCF             +3
                COM
                AD              POSMAX
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           PREAVEG

DPSTART         TC              ENGINOF1

                TC              1LMP+DT
                DEC             150                     # ARM DESCENT ENGINE
                DEC             1000                    # DELAY 10 SECONDS

                CAF             BIT1                    #  START UP ABORT STAGE MONITOR
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           ABMON
TIG11-20        TC              1LMP+DT
                DEC             86                      # SET MANUAL THROTTLE TO 10 %
                DEC             400                     # DELAY 4 SECONDS

TIG11-16        TC              2LMP+DT
                DEC             228                     # ENABLE DPS PQGS ARM 1
                DEC             196                     # ENABLE DPS PQGS ARM 2
                DEC             100                     # DELAY 1 SECOND

TIG11-15        TC              2LMP+DT
                DEC             244                     # DPS PQGS =1 ON
                DEC             212                     # DPS PQGS =2 ON

                DEC             750                     # DELAY 7.5 SECONDS

TIG-7.5         TC              IBNKCALL
                CADR            ULLAGE                  # CALL FOR 4 JET ULLAGE

                TC              FIXDELAY
                DEC             750                     # DELAY 7.5 SECONDS, UNTIL ENGINEON

## Page 696

TIG11           TC              ENGINEON
                TC              FIXDELAY

                DEC             50                      # DELAY HALF A SECOND

                TC              IBNKCALL
                CADR            NOULLAGE

                TC              FIXDELAY
                DEC             2550                    # WAIT 25.5 SECONDS

TIG11+26        CAF             POSMAX                  # HAVE BEEN AT 10% THROTTLE FOR 26 SECONDS
                TS              PCNTF                   # NOW CALL FOR MAXIMUM THRUST (92.5%)

                EXTEND
                DCA             PCNTFAD
                DXCH            Z

                EXTEND
                DCA             BURNADR                 # STARTING DPS2 GUIDANCE: TIG +26 SECONDS
                DXCH            AVGEXIT

                TC              TASKOVER

RETBURN         EXTEND                                  # RETURN FROM BURN GUIDANCE
                DCA             ADROFSER                # SET SERVICER EXIT TO KILL BURN GUID

                DXCH            AVGEXIT

                CAF             BIT1                    # SET TASK FOR RANDOM THROTTLE
                INHINT
                TC              WAITLIST                # PROGRAM P44
                EBANK=          TDEC
                2CADR           PROG44

                TC              ENDOFJOB                # READACCS STILL ACTIVE

## Page 697

# THE DPS2 RANDOM THROTTLE PROG44 STARTS APPROXIMATELY AT TIG+705. THE
# EXACT TIME AND THRUST LEVEL SETTING AT THE START OF PROG44 ARE COMPUTED
# BY BURN GUIDANCE PROG43.  THE SUBSEQUENT THRUST COMMANDS ARE LISTED.

# T    10 PERCENT THRUST
# T+10 50 PERCENT
# T+30 30 PERCENT
# T+40 20 PERCENT
# T+50 92.5 PERCENT FOR 2 SECS THEN FIRE-IN-THE-HOLE

PROG44          TC              NEWMODEX
                OCT             44                      # SET MODE TO RANDOM THROTTLE

                CAF             22SECS11                # DO ASCENT COOLANT VALVE TASK IN 22 SECS
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           ASWTVLON                # COOLANT VALVE CALL

INDPCT          CAF             FOUR
                TS              MPRETRN                 # INDEX

                INDEX           A                       # OFFSET POINTER
                CAF             20PCTHR                 # AMOUNT OF THROTTLE
                TS              PCNTF

                EXTEND
                DCA             PCNTFAD                 # GO TO THRUSTING ROUTINE
                DXCH            Z

                TC              FIXDELAY
10SECS11        DEC             1000                    # DELAY 10 SECS

                CCS             MPRETRN                 # DECREMENT INDEX
                TC              INDPCT          +1      # NO

                CAF             925PCTHR                # TURN ON 92.5 THRUST
                TS              PCNTF
                EXTEND
                DCA             PCNTFAD                 # GO FOR THRUSTING
                DXCH            Z

                CAF             1SEC11                  # THRUST AT MAX FOR 2 SEC, 1 SEC HERE AND
                TC              WAITLIST                # 1 MORE IN FITHCMD
                EBANK=          TDEC
                2CADR           FITHCMD

                TC              TASKOVER

# FITH/APS1 BURN PROGRAM 74

## Page 698
# WITH DETECTION OF THE ABORT STAGE DISCRETE BY THE ABORT STAGE MONITOR
# THE FOLLOWING EVENTS OCCUR BY PROGRAM OR ARE PROCESSED AUTOMATICALLY
# BY THE LEM SEQUENCER.

#  T-1.0 ABORT STAGE ARM (PROGRAMMED)
#  T     ABORT STAGE COMMAND (PROGRAMMED)
#       ATTITUDE HOLD (PROGRAMMED)
#  T+.04 ASCENT PRESSURIZED
#  T+.15 DESCENT ENGINE-OFF
#  T+.42 ASCENT ENGINE ARM
#        ASCENT/DESCENT STAGING INITIATED
#        STAGE VERIFIED
#  T+.46 INTERSTAGE BOLTS FIRED
#        ASCENT STAGE UMBILICAL ELECTRICAL DEADFACE

#  T+.50 DESCENT STAGE UMBILICAL ELEC. DEADFACE
#  T+.55 ASCENT/DESCENT STAGE UMBILICAL CUT
#  T+.78 ASCENT ENGINE REACHES 90 PC THRUST
# T+1.0 CHANGE LEM MASS (PROGRAMMED)
#       DESCENT ENGINE ARM-OFF (PROGRAMMED)
# T+5.0 ASCENT ENGINE-OFF (PROGRAMMED)

FITHCMD         TC              1LMP+DT                 # THRUST AT MAX FOR 1 MORE SEC AND ABORT
                DEC             22                      # ABORT STAGE ARM
                DEC             100                     # DELAY 1.0 SEC.

                TC              1LMP                    # INITIATE ABORT STAGE COMMAND
                DEC             38

                TC              TASKOVER                # LET ABORT MONITOR TAKE IT FROM HERE

ABMON           CAF             BIT4                    # ABORT STAGE MONITOR SAMPLES CHANNEL
                EXTEND                                  # 30 FOR ABORT STAGE DISCRETE EVERY .5 SEC
                RAND            30
                EXTEND
                BZF             FITHGCMD                # ABORT DISCRETE PRESENT-KILL MONITOR

                TC              FIXDELAY                # NO ABORT DISCRETE-CONTINUE TO MONITOR

                DEC             50                      # DELAY .5 SECS
                TCF             ABMON

FITHGCMD        TC              IBNKCALL
                CADR            STOPRATE                # SET ATTITUDE HOLD

                TC              NEWMODEX                # SET MODE TO FIRE-IN-THE-HOLE
                OCT             74                      # PROG74

                EBANK=          MASSES                  # EBANK5
                CAF             EBANK5
                TS              EBANK                   # JAM 05 IN EBANK
                EXTEND

## Page 699
                DCA             LEMMASS2                # CHANGE LEM MASS AT DPS/APS SEPARATION
                DXCH            MASS
                CAF             BIT11                   # RETURN EBANK TO 04
                TS              EBANK
                EBANK=          TDEC

                TC              FIXDELAY
                DEC             100                     # DELAY 1 SEC TO DPS ARM OFF

                TC              1LMP+DT                 # ENGINE SELECT-DESC ARM OFF-
                DEC             151                     # APS BURN FOR 5 SECS
                DEC             400                     # DELAY 4.0 SECONDS

                TC              ENGINOFF                # GO FOR ENGINE SHUTDOWN

                TC              TASKOVER



DOCURTN         TC              BANKCALL                #  GO SET UP CURTAIN JOB
                CADR            CURTJOB

MP11TERM        CAF             1SEC11                  # SET TO DO MP11 TERMINAL TASKS IN 1 SEC
                INHINT
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP11OUT

                TC              ENDOFJOB                # TERMINATE JOB SET BY DVMON

MP11OUT         TC              1LMP+DT
                DEC             39                      # INITIATE ABORT STAGE COMMAND RESET
1SEC11          DEC             100                     # DELAY 1 SEC

                TC              1LMP+DT
                DEC             183                     # LANDING RADAR POWER OFF
                DEC             800                     # DELAY 8 SECS

                TC              2LMP+DT
                DEC             245                     # DPS PQGS U AND 2 OFF
                DEC             213
                DEC             100                     # DELAY 1 SEC

                TC              2LMP+DT
                DEC             229                     # DPS PQGS ARM 1 AND 2 DISABLE
                DEC             197
                DEC             1900                    # DELAY 19 SECS TO KILL AVEG

                TC              FLAG1DWN                # KILL AVERAGE G
                OCT             1

## Page 700
                TC              IBNKCALL
                CADR            SETMAXDB

                TC              MPENTRY                 # SETUP MISSION PHASE SCHEDULING
                DEC             2                       # TIMER -2-
                DEC             13                      # MISSION PHASE -13-
                ADRES           MP11TO13
                TC              TASKOVER                # MISSION PHASE 11 COMPLETE

## Page 701
# ????????????????????????????????
# NUMERICAL AND ADDRESS CONSTANTS
# ????????????????????????????????



#                                         ** TIME CONSTANTS **

135SECS         DEC             13500
22.5SECS        DEC             2250
25.5SECS        DEC             2550
22SECS11        DEC             2200



#                                         ** THRUST LEVEL CONSTANTS **

20PCTHR         DEC             .2
                DEC             .4
                DEC             .3
                DEC             .5
                DEC             .1
925PCTHR        =               POSMAX                  # FOR MAXIMUM PERMITTED THRUST (92.5%)



#                                         ** ADDRESS CONSTANTS **

AVEG11AD        GENADR          AVERAGEG
                EBANK=          TDEC
BURNADR         2CADR           BURN


                EBANK=          TDEC
DPS2ADR         2CADR           PREBURN

                EBANK=          ETHROT                  # EBANK 5
PCNTFAD         2CADR           PCNTFMAX

                EBANK=          TDEC
MP11TMAD        2CADR           MP11TERM

                EBANK=          TDEC
MDAVADR         2CADR           RVUPDATE

                EBANK=          DVCNTR
ADROFSER        2CADR           SERVEXIT

## Page 702
# ????????????????????????????????
# TASKS CALLED ELSEWHERE IN MP11
# ????????????????????????????????



PREAVEG         CAF             BIT1                    # SET UP PREREAD FOR RIGHT NOW
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                CAF             AVEG11AD                # GENADR OF AVERAGE G
                TS              DVSELECT

                EXTEND                                  # SET SERVICER EXIT
                DCA             ADROFSER
                DXCH            AVGEXIT

                EXTEND                                  # SET MP RETURN FOR ENGINE SHUT DOWN
                DCA             MP11TMAD
                DXCH            DVMNEXIT

                TC              TASKOVER


MP11TASK        TC              1LMP+DT
                DEC             236                     # DFI T/M CALIBRATION -ON
                DEC             1200                    # DELAY 12 SECS

                TC              2LMP+DT
                DEC             237                     # DFI T/M CALIBRATE -OFF
                DEC             198                     # C+W ALARM RESET -COMMAND
2SECS11         DEC             200                     # DELAY 2 SECS

                TC              1LMP+DT
                DEC             199                     # C+W ALARM RESET-COMMAND RESET
                DEC             100                     # DELAY 1 SEC

                TC              2LMP+DT
                DEC             182                     # LR POWER -ON
                DEC             26                      # RADAR SELFTEST -ON
                DEC             6000                    # DELAY 60 SECS.

                TC              1LMP
                DEC             27                      # RADAR SELFTEST-OFF

                TC              TASKOVER

## Page 703

ASWTVLON        TC              1LMP+DT
                DEC             222                     # ASCENT WATER COOLANT VALVE - OPEN
                DEC             200                     # DELAY 2.0 SEC.

                TC              1LMP
                DEC             223                     # ASCENT WATER COOLANT VALVE - OPEN RESET

                TC              TASKOVER
