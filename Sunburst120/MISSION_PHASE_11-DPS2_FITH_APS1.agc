### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     MISSION_PHASE_11-DPS2_FITH_APS1.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-28 MAS  Transcribed.
##		 2016-12-06 RSB	 Comments proofed using octopus/ProoferComments,
##				 changes made.

## Page 739
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



MP11JOB         CAF             BIT11
                TC              SETRSTRT                        # SET RESTART FLAG

                EXTEND
                DCA             TIME2
                DXCH            TDECTEMP

                TC              NEWMODEX                        # SET DISPLAY
                OCT             32

                CAF             1SEC11                          # SETUP MP11 TASK-REQUIRES 75 SECS AND
                INHINT                                          # TERMINATES ITSELF
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP11TASK

                TC              2PHSCHNG
                OCT             40253                           # 3.25SPOT FOR MP11TASK.
                OCT             00312                           # 2.31 SPOT TO CONTINUE MP11JOB.

11REDO1         EXTEND                                          # SET TDEC TO TIME OF START OF MP 11
                DCA             TDECTEMP                        #    PLUS 135 SECONDS.
                DXCH            TDEC
                EXTEND
                DCA             135SECS
                DAS             TDEC

                EXTEND                                          # SET RETURN FROM MIDTOAVE TO INTRTN
                DCA             MDAVADR
                DXCH            Z                               # DO MIDTOAVE VIA RVUPDATE

                TC              PHASCHNG
## Page 740
                OCT             00332

INTRTN          EXTEND
                DCA             DPS2ADR                         # INTEGRATION DONE-DO PRE-DPS2
                DXCH            Z                               # STATE AT RIGNTION-TIME AT TET FOR PREDPS

#  PRE-DPS2 RETURN TO RETPREB WITH ULLAGE-ON TIME AT TULLG, (TIG-7.5).
# THE DESIRED 1/2 UNIT THRUST VECTOR AT POINTVSM.
#  STATE VECTOR IN SM COORDINATES STORED AT RN, VN WITH CORRESPONDING
#  TIME AT PIPTIME WHERE (TULLG - PIPTIME)IS BETWEEN
#  3.8 AND 6 SECS.



RETPREB         INHINT
                EXTEND
                DCA             TULLG                           # C(TULLG)=TIG-7.5
                DXCH            MPAC
                CS              22.5SECS
                TS              L
                CAF             ZERO
                TS              MPAC            +2
                DAS             MPAC                            # C(MPAC)=TIG-30
                EXTEND
                DCS             TIME2                           # GET CURRENT TIME
                DAS             MPAC                            # C(MPAC)=DELTA(TIG-30)
                TC              TPAGREE                         # MAKE SIGNS AGREE
                EXTEND
                DCA             MPAC
                DXCH            TDECTEMP
                DXCH            MPAC
                TC              LONGCALL
                EBANK=          TDEC
                2CADR           TIG11-30

                TC              PHASCHNG
                OCT             20022

11REDO2         TC              INTPRET
                VLOAD
                                RN                              # STATE STORED IN RAVEGON AND VAVEGON FOR
                STOVL           RAVEGON                         # AVERAGE G INITIALIZATION AT PIPTIME
                                VN
                STODL           VAVEGON
                                D1/2                            # JAM .5,0,0 IN SCAXIS FOR KALCMANU
                STODL           SCAXIS
                                DZERO
                STORE           SCAXIS          +2
                STODL           SCAXIS          +4
                                PIPTIME                         # THIS TIME CONSISTANT WITH STATE-RAVEGON

## Page 741
                STORE           DT11TEMP                        # USED AFTER KALCMANU TO CALL PREREAD
                SSP             SET
                                RATEINDX                        # SET KALCMANU FOR ANGULAR RATE OF 5 DEG/S
                                4
                                33D
                EXIT

                CAF             PRIO16                          # DO ATTITUDE MANEUVER JOB.
                INHINT
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

                TC              BANKCALL
                CADR            ATTSTALL                        # PUT MP11 TO SLEEP - KALCMANU WILL WAKE

                TC              CURTAINS                        # KALCMANU HAS GIMBALOC PROBLEMS-CURTAINS
                TC              PHASCHNG
                OCT             00352

                TC              ENDOFJOB                        # WAIT FOR TIG-30

TIG11-30        CAF             BIT11                           # SEE IF ATTITUDE MANEUVER DONE
                MASK            FLAGWRD2
                CCS             A
                TC              DOCURTN                         # KALCMANU NOT-DO CURTJOB
                TC              NEWMODEX                        # SET MODE TO PROG42
                OCT             42

                CAF             AVEG11AD                        # SET UP SERVICER.
                TS              DVSELECT

                EXTEND
                DCA             ADROFSER
                DXCH            AVGEXIT

                EXTEND
                DCA             MP11TMAD
                DXCH            DVMNEXIT

                CS              TIME1
                AD              DT11TEMP        +1              # FIND DT TO PIPTIME
                CCS             A                               # CORRECT NEG DT OR NEGATIVE OVERFLOW DT.
                AD              ONE
                TCF             +5
                AD              OCT40001
                AD              MINUS1                          # ALLOWS FOR REMOTE CHANCE FO ZERO DT.
                COM
                TCF             -6
                TS              RSDTTEMP                        # SAVED FOR RESTARTS.

## Page 742
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                TC              2PHSCHNG
                OCT             40355                           # 5.35 SPOT FOR PREREAD.
                OCT             00212                           # 2.21 SPOT FOR DPSTART.

DPSTART         TC              IBNKCALL
                CADR            ENGINOF1

                TC              1LMP+DT
                DEC             150                             # ARM DESCENT ENGINE
                DEC             1000                            # DELAY 10 SECONDS

TIG11-20        TC              1LMP+DT
                DEC             86                              # SET MANUAL THROTTLE TO 10 %
                DEC             400                             # DELAY 4 SECONDS

TIG11-16        TC              2LMP+DT
                DEC             228                             # ENABLE DPS PQGS ARM 1
                DEC             196                             # ENABLE DPS PQGS ARM 2
                DEC             100                             # DELAY 1 SECOND

TIG11-15        TC              2LMP+DT
                DEC             244                             # DPS PQGS =1 ON
                DEC             212                             # DPS PQGS =2 ON
                DEC             750                             # DELAY 7.5 SECONDS

TIG-7.5         TC              IBNKCALL
                CADR            ULLAGE                          # CALL FOR 4 JET ULLAGE
                
                CAF             BIT1                            # START UP ABORT STAGE MONITOR.
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           ABMON

                TC              2PHSCHNG
                OCT             40033                           # 3.3 SPOT FOR ABMON
                OCT             40232                           # 2.23 SPOT FOR TIG11

                TC              FIXDELAY
                DEC             750                             # DELAY 7.5 SECONDS, UNTIL ENGINEON

TIG11           TC              IBNKCALL
                CADR            DPSENGON
## "DPSENGON" in the above line has a green arrow pointing to it.
                
                TC              PHASCHNG
                OCT             47012
## Page 743
                DEC             50
                EBANK=          TDEC
                2CADR           TIG11A

                TC              FIXDELAY
                DEC             50                              # DELAY HALF A SECOND

TIG11A          TC              IBNKCALL
                CADR            NOULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             2550
                EBANK=          TDEC
                2CADR           TIG11+26

                TC              FIXDELAY
                DEC             2550                            # WAIT 25.5 SECONDS

TIG11+26        CAF             POSMAX                          # HAVE BEEN AT 10% THROTTLE FOR 26 SECONDS
                TS              PCNTF                           # NOW CALL FOR MAXIMUM THRUST (92.5%)

                EXTEND
                DCA             PCNTFAD
                DXCH            Z

                EXTEND
                DCA             BURNADR                         # STARTING DPS2 GUIDANCE: TIG +26 SECONDS
                DXCH            AVGEXIT

                CA              DAPOFFDT                        # SKIP AUTOMATIC TURN-OFF OF DAP IF
                EXTEND                                          # DAPOFFDT IS NEGATIVE OR ZERO.
                BZMF            NODAPOFF

                TC              WAITLIST
                EBANK=          DNTMBUFF
                2CADR           11DAPOFF

                TC              PHASCHNG
                OCT             40116                           # 6.11 FOR 11DAPOFF TASK.

NODAPOFF        TC              2PHSCHNG
                OCT             00002
                OCT             00114                           # 4.11 SPOT FOR THRUSTING

                TC              TASKOVER

RETBURN         EXTEND                                          # RETURN FROM BURN GUIDANCE
                DCA             ADROFSER                        # SET SERVICER EXIT TO KILL BURN GUID
                DXCH            AVGEXIT

## Page 744
                TC              PHASCHNG
                OCT             45022
                OCT             20000
                
                CAF             BIT1                            # SET TASK FOR RANDOM THROTTLE
                INHINT
                TC              WAITLIST                        # PROGRAM P44
                EBANK=          TDEC
                2CADR           PROG44

                TCF             ENDOFJOB                        # READACCS STILL ACTIVE.



11DAPOFF        CA              PRIO30                          # CALL JOB TO TURN OFF DAP & START
                TC              NOVAC                           # SPECIAL CDU-ONLY DOWNLINK.
                EBANK=          DNTMBUFF
                2CADR           BEGINCDU

                TCF             TASKOVER

## Page 745
# THE DPS2 RANDOM THROTTLE PROG44 STARTS APPROXIMATELY AT TIG+705. THE
# EXACT TIME AND THRUST LEVEL SETTING AT THE START OF PROG44 ARE COMPUTED
# BY BURN GUIDANCE PROG43.  THE SUBSEQUENT THRUST COMMANDS ARE LISTED.

# T    10 PERCENT THRUST
# T+10 50 PERCENT
# T+30 30 PERCENT
# T+40 20 PERCENT
# T+50 92.5 PERCENT FOR 2 SECS THEN FIRE-IN-THE-HOLE

PROG44          TC              NEWMODEX
                OCT             44                              # SET MODE TO RANDOM THROTTLE

                TC              PHASCHNG
                OCT             05012
                OCT             77777

INDPCT          CAF             FOUR
                TS              RSDTTEMP                        # INDEX.

                INDEX           A                               # OFFSET POINTER
                CAF             20PCTHR                         # AMOUNT OF THROTTLE
                TS              PCNTF

                EXTEND
                DCA             PCNTFAD                         # GO TO THRUSTING ROUTINE
                DTCB

                CS              TWO                             # WATER VALVE DUE 22 SEC AFTER RANDOM
                AD              RSDTTEMP                        # THROTTLE PHASE BEGINS.  THAT PUTS IT
                EXTEND                                          # 2 SEC AFTER MPRETRN = 2.
                BZF             SETWATER

                TC              2PHSCHNG
                OCT             00114                           # 4.11SPOT FOR THRUSTING
                OCT             00372                           # 2.37 FOR MOVENDX TASK.

MOVENDX         CA              RSDTTEMP
                TS              MPRETRN

                TC              PHASCHNG
                OCT             40412                           # 2.41 FOR CCSMPRET TASK.

                TC              FIXDELAY
10SECS11        DEC             1000                            # DELAY 10 SECS

CCSMPRET        CCS             MPRETRN                         # DECREMENT INDEX
                TC              INDPCT          +1              # NO

                CAF             925PCTHR                        # TURN ON 92.5 THRUST

## Page 746
                TS              PCNTF
                EXTEND
                DCA             PCNTFAD                         # GO FOR THRUSTING
                DXCH            Z

                CAF             1SEC11                          # THRUST AT MAX FOR 2 SEC, 1 SEC HERE AND
                TC              WAITLIST                        # 1 MORE IN FITHCMD
                EBANK=          TDEC
                2CADR           FITHCMD

                TC              2PHSCHNG
                OCT             00114                           # 4.11SPOT FOR THRUSTING
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           FITHCMD

                TC              TASKOVER

## Page 747
# FITH/APS1 PROGRAM 74
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

FITHCMD         TC              1LMP+DT                         # THRUST AT MAX FOR 1 MORE SEC AND ABORT
                DEC             38
                DEC             100                             # DELAY 1.0 SEC.

                TC              1LMP                            # INITIATE ABORT STAGE COMMAND
                DEC             22
                TC              TASKOVER                        # LET ABORT MONITOR TAKE IT FROM HERE

ABMON           CAF             BIT2                            # ABORT STAGE MONITOR SAMPLES CHANNEL
                EXTEND                                          # 30 FOR ABORT STAGE DISCRETE EVERY .5 SEC
                RAND            30
                EXTEND
                BZF             FITHGCMD                        # ABORT DISCRETE PRESENT-KILL MONITOR

                CS              TIME1
                TS              TBASE3
                TC              FIXDELAY                        # NO ABORT DISCRETE-CONTINUE TO MONITOR
                DEC             50                              # DELAY .5 SECS
                TCF             ABMON

FITHGCMD        EXTEND                                          # BYPASS GUIDANCE, ASSURE ULLAGE OFF, AND
                DCA             ADROFSER                        # CLEAR OUT CURRENT ACTIVITY BY ENEMA - -
                DXCH            AVGEXIT                         # ALL THIS TO PROTECT IN CASE OF EARLY
                TC              IBNKCALL                        # ABORT STAGE COMMAND BY GROUND.
                CADR            NOULLAGE

                TC              2PHSCHNG
                OCT             1
## Page 748
                OCT             3

                TC              2PHSCHNG
                OCT             4
                OCT             6

                TC              PHASCHNG
                OCT             00252                           # 2.25 SPOT FOR MP11HOLD.

                CAF             PRIO37
                TC              NOVAC
                EBANK=          LST1
                2CADR           ENEMA                           # ENEMA AS SOON AS POSSIBLE.

                TC              TASKOVER

MP11HOLD        TC              IBNKCALL                        # ENEMA SHOULD PICK UP HERE.
                CADR            STOPRATE                        # SET ATTITUDE HOLD

                TC              NEWMODEX                        # SET MODE TO FIRE-IN-THE-HOLE
                OCT             74                              # PROG74

                EBANK=          LEMMASS2
                CAF             EBANK7
                TS              EBANK                           # SET  EBANK= 7
                EXTEND
                DCA             LEMMASS2                        # CHANGE LEM MASS AT DPS/APS SEPARATION
                DXCH            MASS
                CAF             BIT11                           # RETURN EBANK TO 04
                TS              EBANK
                EBANK=          TDEC

                TC              IBNKCALL                        # SET UP DAP FOR APS BURN
                CADR            APSENGON

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           ENGLECT

                TC              FIXDELAY
                DEC             100                             # DELAY 1 SEC TO DPS ARM OFF

ENGLECT         TC              1LMP+DT                         # ENGINE SELECT-DESC ARM OFF
                DEC             151                             # APS BURN FOR 5 SECS
                DEC             400                             # DELAY 4.0 SECONDS

                TC              IBNKCALL
                CADR            ENGINOFF

## Page 749
                TC              TASKOVER



DOCURTN         TC              IBNKCALL                        #  GO SET UP CURTAIN JOB
                CADR            CURTJOB

MP11TERM        CAF             1SEC11                          # SET TO DO MP11 TERMINAL TASKS IN 1 SEC
                INHINT
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP11OUT

                TC              2PHSCHNG
                OCT             35                              # 5.3 SPOT FOR SERVICER.
                OCT             40272                           # 2.27 SPOT FOR MP11OUT.

                TC              ENDOFJOB

MP11OUT         TC              1LMP+DT
                DEC             39                              # INITIATE ABORT STAGE COMMAND RESET
1SEC11          DEC             100                             # DELAY 1 SEC

                TC              1LMP+DT
                DEC             183                             # LANDING RADAR POWER OFF
                DEC             800                             # DELAY 8 SECS

                TC              2LMP+DT
                DEC             245                             # DPS PQGS U AND 2 OFF
                DEC             213
                DEC             100                             # DELAY 1 SEC

                TC              2LMP+DT
                DEC             229                             # DPS PQGS ARM 1 AND 2 DISABLE
                DEC             197
                DEC             1900                            # DELAY 19 SECS TO KILL AVEG

                TC              FLAG1DWN                        # KILL AVERAGE G
                OCT             1

                TC              IBNKCALL
                CADR            SETMAXDB

                TC              2PHSCHNG
                OCT             2
                OCT             05013                           # GROUP 3 FOR MISSION SCHEDULER.
                OCT             77777

                TC              MPENTRY                         # SETUP MISSION PHASE SCHEDULING
                DEC             2                               # TIMER -2-
## Page 750
                DEC             13                              # MISSION PHASE -13-
                ADRES           MP11TO13
                TC              TASKOVER                        # MISSION PHASE 11 COMPLETE

## Page 751
# ????????????????????????????????
# NUMERICAL AND ADDRESS CONSTANTS
# ????????????????????????????????



#                                         ** TIME CONSTANTS **

135SECS         2DEC            13500

22.5SECS        DEC             2250
25.5SECS        DEC             2550
22SECS11        DEC             2200



#                                         ** THRUST LEVEL CONSTANTS **

20PCTHR         DEC             .2
                DEC             .4
                DEC             .3
                DEC             .5
                DEC             .1
925PCTHR        =               POSMAX                          # FOR MAXIMUM PERMITTED THRUST (92.5%)



#                                         ** ADDRESS CONSTANTS **

AVEG11AD        GENADR          AVERAGEG
                EBANK=          E2DPS
BURNADR         2CADR           BURN

                EBANK=          E2DPS
DPS2ADR         2CADR           PREBURN

                EBANK=          ETHROT                          # EBANK 5
PCNTFAD         2CADR           PCNTFMAX

                EBANK=          TDEC
MP11TMAD        2CADR           MP11TERM

                EBANK=          TDEC
MDAVADR         2CADR           RVUPDATE

                EBANK=          DVCNTR
ADROFSER        2CADR           SERVEXIT

## Page 752
# ????????????????????????????????
# TASKS CALLED ELSEWHERE IN MP11
# ????????????????????????????????



MP11TASK        TC              1LMP
                DEC             236                             # DFI T/M CALIBRATION - ON

                TC              PHASCHNG
                OCT             40153

                TC              FIXDELAY
                DEC             1200

NEXLMP          TC              2LMP
                DEC             237                             # DFI T/M CALIBRATE - OFF
                DEC             198                             # C+W ALARM RESET - COMMAND

                TC              PHASCHNG
                OCT             40173

                TC              FIXDELAY
2SECS11         DEC             200

NEXLMP1         TC              1LMP
                DEC             199                             # C+W ALARM RESET - COMMAND RESET

                TC              PHASCHNG
                OCT             40213

                TC              FIXDELAY
                DEC             100

NEXLMP2         TC              2LMP
                DEC             182                             # LR POWER - ON
                DEC             26                              # RADAR SELFTEST -ON

                TC              PHASCHNG
                OCT             40233

                TC              FIXDELAY
                DEC             6000

NEXLMP3         TC              1LMP
                DEC             27                              # RADAR SELFTEST-OFF

                TC              PHASCHNG
                OCT             3

## Page 753
                TC              TASKOVER



SETWATER        TC              2PHSCHNG
                OCT             00114                           # 4.11 FOR PCNTJOB JOB.
                OCT             47012
                DEC             200
                EBANK=          TDEC
                2CADR           ASWTVLON

                TC              FIXDELAY
                DEC             200

ASWTVLON        TC              1LMP+DT
                DEC             222                             # ASCENT WATER COOLANT VALVE - OPEN
                DEC             200

                TC              1LMP+DT
                DEC             223                             # ASCENT WATER COOLANT VALVE - OPEN RESET
                DEC             600

                CA              RSDTTEMP
                TS              MPRETRN

                TCF             CCSMPRET
