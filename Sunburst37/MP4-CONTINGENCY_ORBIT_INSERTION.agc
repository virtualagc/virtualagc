### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MP4-CONTINGENCY_ORBIT_INSERTION.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-24 MAS  Transcribed.
##              2016-10-31 RSB  Typos.
##              2016-11-01 RSB  Correction for overprinted area (p. 707).
##              2016-11-06 MAS  Removed workaround for overprinted area.
##		2016-12-06 RSB	Comments proofed using octopus/ProoferComments,
##				changes made.

## Page 696
                BANK            33

                EBANK=          TDEC
# PROGRAM NAME-                   DATE-
#          MISSION PHASE 4                 14 DECEMBER 1966
# MOD NO- 21                      LOG SECTION-
# MOD BY- SCHULENBERG                      MP4-CONTINGENCY ORBIT INSERTION

# FUNCTIONAL DESCRIPTION-
#          CONTINGENCY ORBIT INSERTION IS CALLED BY GROUND IN EVENT OF PREMATURE SIVB SHUTDOWN AND ATTEMPTS TO
# EFFECT AN ORBITAL INSERTION USING THE DPS ENGINE AND THE GUIDANCE EQUATIONS USED FOR THE APS BURNS. THE
# PROGRAM LEAVES MISSION PHASE TIMERS INHIBITED AND LEAVES FURTHER CONTROLTO THE GROUND VIA UPLINK.
# CALLING SEQUENCE-               SUBROUTINES CALLED-
#          START MP4 WHEN ABORT            FLAG1UP          FLAG1DWN
# COMMAND MONITOR DETECTS MP4              FIXDELAY         WAITLIST
# COMMAND VIA LGC UPLINK.                  VPATCHER         KALCMANU
#                                          ASCENT           UL4JETON
# NORMAL EXIT MODES-                       LMP              UL4JETOF
#          TASKOVER (AWAITS                EXECUTIVE        ENGINEON
# FURTHER COMMANDS FROM GROUND)            MIDTOAVE         ENGINOFF
# ALARM EXIT MODES-                        BANKCALL         ENGINOF1
#          NONE                            IBNKCALL         LASTBIAS

# ERASABLE INITIALIZATION REQUIRED-
#          RINJECT = INJECTION RADIUS DESIRED IN METERS * 2(-25)
#          VINJECT = ORBITAL VELOCITY DESIRED IN METERS/CENTISECOND * 2(-7

# OUTPUT- SAME AS FOR KALCMANU
# DEBRIS- SAME AS FOR KALCMANU

MP4JOB          TC              PHASCHNG
                OCT             05022
                OCT             27000

                CAF             BIT4
                TC              SETRSTRT                        # SET RESTART FLAG

                TC              FLAG1UP
                OCT             00040                           # POOH FLAG ON

                TC              NEWMODEX                        # START CONTINGENCY ORBIT INSERTION
                OCT             72

                CAF             FOUR                            # SIGNAL START OF MISSION PHASE 4
                TS              PHASENUM

                TC              FLAG1DWN                        # TERMINATE AVEG AND DO AUTO AVETOMID
                OCT             1

                INHINT

## Page 697
                CAF             BIT1
                TC              WAITLIST                        # SHORT WAITLIST TO INITIALIZE LMP COMMAND
                EBANK=          TDEC
                2CADR           ABORTPRR

                TCF             ENDOFJOB                        # END MP4JOB

# RCS ABORT PRESSURIZATION ROUTINE

ABORTPRR        CAF             ZERO                            # INSURE RCS JETS OFF
                EXTEND
                WRITE           6
                EXTEND
                WRITE           5

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           OPESYS

                TC              FIXDELAY
                DEC             100                             # DELAY ONE SECOND

OPESYS          TC              2LMP+DT
                DEC             188                             # RCS MAIN S/O VALVES, SYS A-OPEN**
                DEC             190                             # RCS MAIN S/O VALVES, SYS B-OPEN**
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION-ON
                DEC             100                             # DELAY ONE SECOND

                TC              2LMP+DT
                DEC             189                             # RCS MAIN S/O VALVES, SYS A-OPEN RESET
                DEC             191                             # RCS MAIN S/O VALVES, SYS B-OPEN RESET
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             6                               # RCS PRESSURE-FIRE**
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION-SAFE
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             7                               # RCS PRESSURE - FIRE RESET
                DEC             400                             # DELAY FOUR SECONDS

## Page 698
# END RCS ABORT PRESSURIZATION ROUTINE

TUMBLCHK        CA              FLAGWRD1
                MASK            BIT13
                EXTEND
                BZF             NOTUMBL

                TC              PHASCHNG
                OCT             47012
                DEC             50
                EBANK=          TDEC
                2CADR           TUMBLCHK

                TC              FIXDELAY
                DEC             50                              # DELAY .5 SECS AND CHECK AGAIN
                TCF             TUMBLCHK

NOTUMBL         TC              FLAG1DWN                        # IF NO TUMBLING-TERMINATE MONITOR
                OCT             20000                           # TERMINATE TUMBLE MONITOR

TIG4-51         EXTEND
                DCA             TIME2                           # GET CURRENT TIME
                DXCH            TDECTEMP

                CAF             021CEK                          # UPDATE STATE TO TIG4-30
                TS              L
                CAF             ZERO
                DAS             TDECTEMP

                EXTEND
                DCA             TDECTEMP
                DXCH            TIGN
                CAF             030CEK
                XCH             L
                CAF             ZERO
                DAS             TIGN                            # FOR DOWNLINK USE - NOMINAL TIGN
# BEGIN ABORT LEM/S4B SEPARATION PROCEDURE

MP4SEP          CS              FLAGWRD1
                MASK            BIT4
                ADS             FLAGWRD1
                
                CAF             XTRANSON                        # +X TRANSLATION- ON (PRE-DAP)
                EXTEND
                WRITE           5

                TC              IBNKCALL                        # +X TRANSLATION-ON (4JET)
                CADR            ULLAGE
                
                TC              1LMP+DT
## Page 699
                DEC             58                              # LEM/SIVB SEPARATE - ARM ON
                DEC             50                              # DELAY 500 MS.
                
                CS              DAPBOOLS
                MASK            GODAPGO                         # TURN ON THE DAP
                ADS             DAPBOOLS

                TC              IBNKCALL
                CADR            SETMAXDB

                TC              PHASCHNG
                OCT             47012
                DEC             50
                EBANK=          TDEC
                2CADR           MP4HOLD

                TC              FIXDELAY                        # WAIT FOR 300 MS.
                DEC             50                              # DELAY 500 MS.

MP4HOLD         TC              IBNKCALL
                CADR            HOLDRATE

                TC              1LMP+DT
                DEC             90                              # LEM/SIVB SEPARATE- COMMAND
                DEC             10                              # DELAY 100 MS.

                TC              IBNKCALL
                CADR            SETMINDB

                TC              PHASCHNG
                OCT             47012
                DEC             90
                EBANK=          TDEC
                2CADR           TIG4-49

                TC              FIXDELAY
                DEC             90                              # DELAY 900 MS.

TIG4-49         TC              1LMP+DT
                DEC             59                              # LEM/S4B SEPARATE-ARM-OFF
                DEC             100                             # DELAY ONE SECOND

TIG4-48         TC              1LMP
                DEC             91                              # LEM/S4B SEPARATE-COMMAND RESET

# END LEM/S4B SEPARATION ROUTINE

                CAF             007CEK
                TC              WAITLIST
                EBANK=          TDEC
## Page 700
                2CADR           TIG4-41

                TC              2PHSCHNG
                OCT             40152                           # TABLES RESTART FOR TIG4-41
                OCT             05014
                OCT             77777

                CAF             PRIO27                          # START NEW JOB FOR CALCULATIONS
                TC              FINDVAC
                EBANK=          TDEC
                2CADR           LONGJOB

                TCF             TASKOVER                        # END TIG4-48 TASK

LONGJOB         TC              INTPRET                         # SET INTEGRSW SO THAT THE THIRD TESTLOOP
                SET             EXIT                            # OF MIDTOAVE WILL GENERATE IGN+28 STATES
                                INTEGRSW                        # INSTEAD OF IGNITION STATES.

                EXTEND                                          # RESET TDEC IN CASE OF A RESTART
                DCA             TDECTEMP
                DXCH            TDEC

                EXTEND
                DCA             ORBINTAD                        # DO ORBITAL INTEGRATION
                DXCH            Z

                TC              PHASCHNG
                OCT             05024
                OCT             27000

PRECOI          CAF             KALC4AD
                TS              ASCRET
                TC              INTPRET
                CALL
                                VPATCHER                        # RESCALE AND LOAD IGN STATES IN RN AND VN
                EXIT

                TC              PHASCHNG                        # BECAUSE PAXIS1 & QAXIS TIME-SHARE
                OCT             04024                           # LOCATIONS WITH RN & VN.

                TC              INTPRET
                VLOAD
                                VN                              # VN FROM VPATCHER=VIGNTION*2(-7) M/CS
                VXV             UNIT
                                RN                              # RN FROM VPATCHER=RIGNTION*2(N-29) M
                STOVL           QAXIS                           # UNIT HORIZONTAL VECTOR NORMAL TO ORBIT
                                UNITR                           # UNITR FROM AVEG=UNIT(RIGNTION)*2(-1) M
                STORE           PAXIS1
                VXV             VSL1
                                QAXIS
## Page 701
                STOVL           SAXIS                           # UNIT HORIZONTAL VECTOR PARALLEL TO ORBIT
                                ABLOCK
                STOVL           AT
                                BBLOCK
                STOVL           ATMEAS
                                CBLOCK
                STODL           RDOTD                           # RDOTD, YDOTD.  ZDOTD FIXED LATER.
                                KR1EST
                STODL           KR1                             # LOAD ATTITUDE LIMITING PARAMETER
                                TGOEST
                STODL           TGO
                                VTO-DPS
                STODL           VTO                             # LOAD DPS TAILOFF VELOCITY FOR ASCENT
                                RINJECT
                STODL           RCO                             # LOAD INJECTION RADIUS FOR ASCENT
                                VINJECT
                STODL           ZDOTD                           # LOAD INJECTION VELOCITY FOR ASCENT
                                KREST
                STORE           KR
                CLEAR
                                DIRECT
                VLOAD           DOT
                                SAXIS
                                VN                              # ZDOT*2(-8)
                SL1                                             #  *2(-7)
                STOVL           ZDOT
                                PAXIS1
                DOT             SL1                             # RDOT*2(-8)
                                VN                              #  *2(-7)
                STODL           RDOT
                                DP0
                STORE           YDOT                            # YDOT = 0
                SET             GOTO
                                BAKTO4
                                ASCENT                          # GO TO USE GEFF SECTION OF ASCENT
GFKNOWN         SR1                                             # LET AVG GEFF = .5 GEFF
                STORE           GEFF
                GOTO
                                GAIN
TKNOWN          DLOAD           DAD
                                RDOTD
                                RDOT                            # (RDOT+RDOTD)*2(-7)
                SR1             DMP                             #  .5RDOTAVE*2(-7)
                                TGO                             # RGO*2(-24),SINCE TGO IS *2(-17)
                DAD             SR1                             # RFREE IS RCO FOR NO R-CONTROL,*2(-24)
                                RMAG                            #  *2(-25)
                DSU             BPL
                                RCO
                                FREE-R
                CLEAR           GOTO                            # IF RFREE SMTHAN RCO, CONSTRAIN RCO
## Page 702
                                HC
                                ASCENT
FREE-R          SET             GOTO
                                HC                              # IF RFREE GRTHAN RCO, FREE RCO
                                ASCENT
PREKALC4        VLOAD           CLEAR
                                AXISD
                                ENGOFFSW                        # TO AVOID MULTIPLE ENGINOFF COMMANDS
                STOVL           POINTVSM                        # KALCMANU INPUT REGISTER
                                BODYVECT                        # LOAD BODY AXES VECTOR IN SM COORDS
                STORE           SCAXIS                          # KALCMANU INPUT VECTOR
                SET             SSP
                                33D

                                RATEINDX
                                6                               # 10 DEGREE/SEC MANEUVERING RATE
                EXIT

                TC              PHASCHNG
                OCT             00004                           # DEACTIVATE GR 4

                TCF             ENDOFJOB                        # END LONGJOB

TIG4-41         CAF             AVGENADR                        # GENADR OF AVERAGEG
                TS              DVSELECT

                EXTEND
                DCA             EXITADR                         # SET AVEG TO EXIT TO END OF JOB UNTIL
                DXCH            AVGEXIT                         # IT IS RESET TO ATMAG

                EXTEND
                DCA             MP4TM1AD                        # SET MONITOR EXIT
                DXCH            DVMNEXIT

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION-ON
                DEC             400                             # DELAY 4 SECONDS

TIG4-37         TC              IBNKCALL                        # +X TRANSLATION- OFF
                CADR            NOULLAGE

                TC              IBNKCALL
                CADR            STOPRATE                        # HOLD VEHICLE ATTITUDE

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           TIG4-36

## Page 703
                TC              FIXDELAY
                DEC             100                             # DELAY ONE SECOND

TIG4-36         TC              1LMP
                DEC             8                               # LANDING GEAR DEPLOY-FIRE

                CAF             002CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           TIG4-34

                TC              2PHSCHNG
                OCT             40172
                OCT             05013                           # GR 3 FOR KALCMANU
                OCT             77777

                CAF             PRIO16                          # CALL KALCMANU.
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

                TCF             TASKOVER                        # END TIG4-36 TASK

TIG4-34         CAF             004CEK                          # SET PREREAD CALL (AUTO LASTBIAS)
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                TC              2PHSCHNG
                OCT             40275                           # 5.27 SPOT FOR PREREAD
                OCT             05012                           # GR 2 CONTINUES HERE
                OCT             77777

                TC              1LMP+DT
                DEC             9                               # LANDING GEAR DEPLOY- FIRE RESET
                DEC             402                             # DELAY 4 SECONDS

TIG4-30         TC              IBNKCALL
                CADR            ENGINOF1

                TC              2LMP+DT
                DEC             150                             # ENGINE SELECT- DESC ARM
                DEC             86                              # MANUAL THROTTLE- ON 10 PERCENT
                DEC             1398                            # DELAY 14 SECONDS

TIG4-16         TC              2LMP+DT
                DEC             228                             # DPS PQGS ARM NO 1 - ENABLE
                DEC             196                             # DPS PQGS ARM NO 2- ENABLE
                DEC             100

## Page 704
TIG4-15         TC              2LMP+DT
                DEC             244                             # DPS PQGS NO 1- ON
                DEC             212                             # DPS PQGS NO 2- ON
                DEC             750                             # DELAY 7.5 SECONDS

TIG4-7.5        TC              IBNKCALL                        # +X TRANSLATION- ON
                CADR            ULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             750
                EBANK=          TDEC
                2CADR           TIG4TST
                
                TC              FIXDELAY
                DEC             750                             # DELAY 7.5 SECONDS

TIG4TST         CAF             PRIO17
                TC              NOVAC
                EBANK=          TDEC
                2CADR           IGNTEST

                TCF             TASKOVER

IGNTEST         TC              BANKCALL                        # WAIT UNTIL MANEUVER IS FINISHED
                CADR            ATTSTALL
                TC              CURTAINS

MP4IGN          INHINT
                TC              IBNKCALL
                CADR            DPSENGON
## DPSENGON in the above line has a green arrow pointing to it.

                CAF             003CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP4IGN+3

                TC              2PHSCHNG
                OCT             00003
                OCT             47012
                DEC             300
                EBANK=          TDEC
                2CADR           MP4IGN+3

                TCF             ENDOFJOB

MP4IGN+3        TC              IBNKCALL                        # +X TRANSLATION- OFF
                CADR            NOULLAGE

                TC              1LMP+DT
## Page 705
                DEC             5                               # ED BATTERY ACTIVATION- SAFE
                DEC             2300                            # DELAY 23 SECONDS

MAXTHRST        CAF             POSMAX                          # CALL FOR 92.5 PERCENT THRUST
                TS              PCNTF
                EXTEND
                DCA             PCNTFMAD
                DTCB

                TC              2PHSCHNG                        # PROTECT CALL FOR MAXIMUM THRUST
                OCT             00114
                OCT             47012
                DEC             300
                EBANK=          TDEC
                2CADR           GUIDANCE

                TC              FIXDELAY
                DEC             300                             # WAIT 3 SECS BEFORE CALLING THRUST FILTER

GUIDANCE        EXTEND                                          # TUNE IN ASCENT GUIDANCE
                DCA             ATMAG4
                DXCH            AVGEXIT

                CAF             CDUJOBAD
                TS              ASCRET

                TC              PHASCHNG
                OCT             00002                           # DEACTIVATE GR 2

                TCF             TASKOVER

MP4TERM1        INHINT
                CAF             005CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           TCO+5

                TC              PHASCHNG
                OCT             47012
                DEC             500
                EBANK=          TDEC
                2CADR           TCO+5

                TC              POSTJUMP
                CADR            SERVEXIT

TCO+5           TC              2LMP+DT
                DEC             151                             # ENGINE SELECT-DESC ARM-OFF
                DEC             87                              # MANUAL THROTTLE-RESET (30 PERCENT)
                DEC             100                             # DELAY ONE SECOND

## Page 706
                TC              IBNKCALL                        # SET MAXIMUM DEADBAND
                CADR            SETMAXDB

                TC              PHASCHNG
                OCT             47012
                DEC             900
                EBANK=          TDEC
                2CADR           TCO+15

                TC              FIXDELAY
                DEC             900                             # DELAY NINE SECONDS

TCO+15          TC              2LMP+DT
                DEC             245                             # DPS PQGS NO 1- OFF
                DEC             213                             # DPS PQGS NO 2- OFF
                DEC             100

                TC              2LMP+DT
                DEC             229                             # DPS PQGS ARM NO 1- DISABLE
                DEC             197                             # DPS PQGS ARM NO 2- DISABLE
                DEC             1400                            # DELAY 14 SECONDS

                TC              FLAG1DWN                        # TERMINATE AVEG AND DO AUTO AVETOMID
                OCT             00041                           # ALSO KNOCK DOWN THE POOH FLAG

                TC              PHASCHNG                        # DEACTIVATE GROUP 2
                OCT             00002

                TCF             TASKOVER

# ************************************************************************
# TIME INCREMENTS FOR WAITLISTS IN MP4 - XXXXXCEK = DEC XXXXX00 CS
# ************************************************************************	   4
002CEK          DEC             200
## The two above lines were printed on top of each other. Luckily the first is all asterisks so it's easy
## to tell what should have happened.

003CEK          DEC             300

004CEK          DEC             400

005CEK          DEC             500

007CEK          DEC             700

021CEK          DEC             2100

030CEK          DEC             3000

XTRANSON        OCT             00252                           # CHANNEL 5 CODE FOR 4-JET TRANSLATION

## Page 707
## The following four lines are printed on two. Luckily that puts one line of asterisks on both
## erroneous lines, making it not too difficult to tease them apart. They may not be completely
## perfect, though. It also looks like the lines of asterisks, which seem to be causing the problems,
## are accompanied by random 4s. The placement of them makes it seem like they were probably not in
## the original program, and are only appearing due to the printer errors.
# ************************************************************************                     4
# CONSTANTS FOR PRECOI CALCULATIONS AND FOR INITIALIZATION OF ASCENT EO.
# ************************************************************************
ABLOCK          2DEC            0.30893         E-3 B+9         # ANTICIPATED INITIAL ACCELERATION M/CS/CS

                2DEC            0.2990          E+2 B-7         # INITIAL EXHAUST VELOCITY  M/CS

                2DEC            0.9678          E+5 B-17        # ESTIMATED BURNUP TIME IN CENTISECONDS

BBLOCK          2DEC            0.1642                          # 1/DV1

                2DEC            0.1642                          # 1/DV2

                2DEC            0.1642                          # 1/DV3

KREST           2DEC            0.4750                          # LIMITS MAXIMUM PITCH TO 72 DEGREES

KR1EST          2DEC            0.3122

TGOEST          2DEC            25000           B-17

BODYVECT        2DEC            .5

CBLOCK          2DEC            0                               # RDOTD

                2DEC            0                               # YDOTD

## There's a physical page break after the following line, brought on by more printer errors.
## It appears as though a couple of lines are missing, but there's presently no way to 
## regenerate them.
# ************************************************************************            4   4
# GENADRS, ECADRS, AND 2CADRS USED IN MP4
# ************************************************************************

AVGENADR        GENADR          AVERAGEG

                EBANK=          TDEC
MP4TM1AD        2CADR           MP4TERM1

                EBANK=          TDEC
EXITADR         2CADR           SERVEXIT

                EBANK=          AMEMORY
ORBINTAD        2CADR           MIDTOAVE

                EBANK=          ETHROT
PCNTFMAD        2CADR           PCNTFMAX

                EBANK=          TDEC
ATMAG4          2CADR           ATMAG

KALC4AD         FCADR           PREKALC4

## Page 708
CDUJOBAD        FCADR           FINDCDUD

# ************************************************************************
# TASKSETR SUBROUTINE - SETS UP WAITLISTS REFERENCED TO VALUE OF TDEC
# ************************************************************************

## An empty page follows, and instructions continue on the page after that.

TASKSETR        EXTEND
                QXCH            ITEMP1
                TS              L
                CAF             ZERO
                DXCH            MPAC
                DXCH            ITEMP3
                CAF             ZERO
                XCH             MPAC            +2
                TS              ITEMP5
                EXTEND
                DCS             TIME2
                DAS             MPAC
                CAF             EBANK4
                XCH             EBANK
                TS              ITEMP2
                EXTEND
                DCA             TDEC
                DAS             MPAC
                TC              TPAGREE
                CA              ITEMP5
                TS              MPAC            +2
                DXCH            ITEMP3
                DXCH            MPAC
                EXTEND
                BZF             +3
                TC              ABORT
                OCT             00404
                XCH             L
                EXTEND
                BZMF            -4
                LXCH            ITEMP2
                LXCH            EBANK
                TC              ITEMP1
# ************************************************************************              4
