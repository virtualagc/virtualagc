### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     AS206_MISSION_SCHEDULING_PACKAGE.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-29 MAS  Transcribed.
##		 2016-12-06 RSB	 Comments proofed using octopus/ProoferComments,
##				 changes made.

## Page 801
#          THE FOLLOWING ROUTINES IMPLEMENT THE MISSION SCHEDULING LOGIC AS DESCRIBED IN CHAPTER 4 OF THE
# AS206 OPERATIONS PLAN. THE FOLLOWING ROUTINE IS ENTERED ONCE EACH SECOND FOR MOST OF THE DURATION OF THE
# FLIGHT, ONCE LIFT-OFF HAS OCCURRED. AN EXCEPTION TO THIS IS THE TIME-CRI

# RESTART  GROUP  FOR MISSION SCHEDULING PACKAGE IS GROUP 3.

                BANK            31
                EBANK=          MTIMER4

MMAINT          CAF             THREE                           # LOOP TO PROCESS ALL FOUR TIMERS.
MLOOP           TS              RUPTREG1

                INDEX           A                               # LOOK AT TIMER.
                CCS             MTIMER4
                TCF             MCOUNT                          # PNZ - ACTIVE AND COUNTING DOWN.
                TCF             MDUE                            # +0 - MISSION PHASE DUE.
                AD              ONE                             # NNZ - FREE BUT LOADED BY GROUND.
                COM                                             # -0 - FREE.
MCOUNT          INDEX           RUPTREG1                        # PLACE UPDATED TIMERS AND PHASE REGISTERS
                TS              MTIMER4T                        # INTO COPY BUFFER FOR RESTART PROTECTION.

MDUERET         CCS             RUPTREG1
                TCF             MLOOP

MCHKST          CCS             STATECTR                        # SEE IF POSSIBLY TIME FOR INTERNAL STATE
                TCF             MSTATEOK                        # VECTOR EXTRAPOLATION.

                CAF             THREE                           # IF SO, DO UPDATE UNLESS WE ARE WITHIN 16
MSTATECK        TS              RUPTREG1                        # SECONDS OF THE INITIATION OF ANY MISSION
                CS              LOW4                            # PHASE.
                INDEX           RUPTREG1
                MASK            MTIMER4
                EXTEND
                BZF             MSTATEOK        -1              # BRANCH IF PHASE DUE WITHIN 16 SECS.

                CCS             RUPTREG1
                TCF             MSTATECK

                CAF             PRIO5
                TC              FINDVAC                         # TO DO THE INTEGRATION.
                EBANK=          TDEC
                2CADR           STATEINT

 -1             CAF             STATECRI
MSTATEOK        TS              STATECTR

                TC              PHASCHNG
                OCT             00113

REDO3.11        CAF             1SEC
## Page 802
                TC              WAITLIST
                EBANK=          MTIMER4
                2CADR           MMAINT

                EXTEND
                DCA             MTIMER4T
                DXCH            MTIMER4
                EXTEND
                DCA             MTIMER4T        +2
                DXCH            MTIMER2

                TC              PHASCHNG
                OCT             40133

                TC              TASKOVER

1SEC            DEC             100

## Page 803
#          THE FOLLOWING CODING DISPATCHES DUE MISSION PHASES VIA A TABLE OF EXECUTIVE PRIORITIES AND 2CADRS.

MDUE            CA              RUPTREG1
                TS              MDUETEMP                        # COPY FOR RESTART PROTECTION

                INDEX           RUPTREG1                        # GET NUMBER OF NEW PHASE AND MP BY NUMBER
                CA              MPHASE4                         # OF TABLE ENTRIES PER PHASE TO GET ADDRES
                EXTEND                                          # OF TABLE ENTRY FOR THIS PHASE.
                BZF             BADPHASE                        # INACTIVE MPHASE HERE IS VERY BAD.
                TS              PHASENUM                        # HOLDS CURRENT MP NUMBER FOR DOWNLINK
                EXTEND
                MP              THREE
                INDEX           L
                CA              MTABLE                          # PRIO, INHIBIT/ENABLE INFO., ETC.
                TS              RUPTREG2
                MASK            SEVEN                           # HONOR INHIBIT/ENABLE FUNCTION.
                MASK            FLAGWRD2
                CCS             A
                TCF             MBYPASS

                CAF             PRIO37
                MASK            RUPTREG2
                TS              NEWPRIO
                EXTEND
                INDEX           L                               # PICK UP 2CADR AND DO FINDVAC.
                DCA             MTABLE          +1
                TC              SPVAC

                TC              2PHSCHNG
                OCT             32                              # 2.3 SPOT FOR REDOMDUE
                OCT             3                               # GROUP 3 OFF

MTIMEDWN        TC              MTIMEFIX

                CAF             PRIO30
                TC              NOVAC
                EBANK=          MTIMER4
                2CADR           UPDATKIL

                TC              FLAG2DWN
                OCT             20

                TC              TASKOVER

MBYPASS         TC              MTIMEFIX
                TCF             MDUERET

MTIMEFIX        CS              ZERO
                INDEX           MDUETEMP                        # MAKE THIS MTIMER/MPHASE PAIR AVAILABLE.
                TS              MTIMER4

## Page 804
                INDEX           MDUETEMP
                TS              MPHASE4
                INDEX           MDUETEMP
                TS              MTIMER4T
                TC              Q

## Page 805
# RESTART  ROUTIN E TO RESCHEDULE MISSION PHASE

REDOMDUE        CA              PHASENUM                        # FIND PRIO AND 2CADR OF NEW MP IN TABLE.
                EXTEND
                MP              THREE
                INDEX           L
                CA              MTABLE
                MASK            PRIO37
                TS              NEWPRIO
                EXTEND
                INDEX           L
                DCA             MTABLE          +1
                TC              SPVAC                           # DO FINDVAC WITH 2CADR IN A +  L
                TCF             MTIMEDWN



# DO A PSEUDO VERB 34 ENTER TO KILL AN UPDATE IN PROGRESS, AND TO RELEASE THE DSKY.

UPDATKIL        CAF             34OCT
                TS              REQRET
                TC              BANKCALL
                CADR            UPDATVB         -1

                TC              POSTJUMP
                CADR            VBTERM                          # GOES TO ENDOFJOB WHEN DONE

## Page 806
#          THE FOLLOWING SUBROUTINE MAY BE USED BY MISSION PROGRAMS TO SET MISSION PHASE/TIMER PAIRS TO INITIATE
# THE VARIOUS MISSION PHASES (SEE CHAPTER 4 OF THE GSOP).

#          CALLING SEQUENCE IS AS FOLLOWS:

#                                                  TC     MPENTRY         UNDER CONTROL OF EXEC OR RUPT.
#                                                  DEC    INDEX           INDEX OF TIMER (1 TO 4).
#                                                  DEC    PHASE           MISSION PHASE NUMBER.
#                                                  ADRES  DT              DT = TIME (SECONDS) TO INITIATION.
#                                                                         (EBANK MUST ALREADY BE SET.)

                BLOCK           02
MPENTRY         INHINT
                INDEX           Q                               # MAKE INTERNAL INDEX.
                CS              0
                AD              FOUR
                TS              RUPTREG1

                INDEX           A                               # IF THIS MISSION PHASE REGISTER IS NOT
                CCS             MPHASE4                         # -0, IT HAS BEEN CHANGED BY THE GROUND,
                TCF             MENTRYT                         # SO LEAVE IT ALONE.
                TCF             MENTRYT
                TCF             MENTRYT

                INDEX           Q
                CAF             1
                INDEX           RUPTREG1
                TS              MPHASE4

MENTRYT         INDEX           RUPTREG1                        # IF THE TIMER IS -0, SET IT TO THE INPUT
                CCS             MTIMER4                         # VALUE, OTHERWISE, ASSUME IT HAS BEEN
                AD              ONE                             # SET BY THE GROUND AND JUST FORCE IT POS.
                TCF             MENTABS
                TCF             -2

                INDEX           Q
                CAF             2
                INDEX           A
                CA              0
MENTABS         INDEX           RUPTREG1
                TS              MTIMER4

                CAF             THREE                           # MAKE UP RETURN SO COMMON ROUTINE CAN BE
                AD              Q                               # USED TO INITATE TIMER COUNTING.
 -1             TS              MRETURN

## Page 807
# SUBROUTINE TO START MISSION TIMERS IF THEY ARE NOT GOING ALREADY.

MSTART          CA              FLAGWRD2                        # SEE IF TIMERS ENABLED ALREADY.
                MASK            BIT5
                CCS             A
                TCF             MDONE                           # YES - RETURN.

                TCF             +3                              # THERE USED TO BE A PHASE CHANGE HERE.
                TC              CCSHOLE
                TC              CCSHOLE

                TC              FLAG2UP                         # SHOW TIMERS ENABLED.
                OCT             20

                INHINT

                CAF             STATECRI                        # INITIALIZE STATE VECTOR EXTRAPOLATION
                TS              STATECTR                        # TIMER.

                CAF             ONE
                TC              WAITLIST
                EBANK=          MTIMER4
                2CADR           MMAINT                          # START COUNTER MAINTENANCE.

MDONE           RELINT
                TC              MRETURN

STATECRI        DEC             539                             # CALLS FOR INTEGRATION EVERY 539 SEC.
1SEC+1          DEC             101

## Page 808
# SUBROUTINE CALLS FOR VARIOUS UPDATE OPTIONS (SEE GSOP).  ENTER UNDER EXEC WITH INTERRUPT INHIBITED.

                BANK            31
DOV70           TC              MTIMERUP                        # VERB 70
                TCF             ENDUP

DOV71           TC              MPHASEUP                        # VERB 71
                TCF             DOV72           +2

DOV72           TC              MPHASEUP                        # VERB 72
                TC              MTIMERUP
 +2             CA              UPPHASE                         # FOR V72, WE DON'T ALTER THE MPHASE
                INDEX           RUPTREG1                        # REGISTER UNTIL SURE THAT TIMER CHANGE
                TS              MPHASE4                         # IS LEGAL.
TCFENDUP        TCF             ENDUP

## Page 809
# INVERT INHIBIT/ENABLE SWITCH WHOSE INDEX IS IN UPINDEX (1 TO 3).  ENTER UNDER EXEC WITH INTERRUPT INHIBITED.

DOV73           CS              TWO
                AD              UPINDEX
                TC              MAGSUB                          # SEE IF INDEX LEGIT.
                DEC             -1
                TCF             UPERROR

                INDEX           UPINDEX
                CAF             BIT3            -1              # BITS IN POSITIONS 3, 2, AND 1 OF
                TS              L                               # FLAGWRD2 (SEE SWITCH ASSIGNMENTS).
                CA              FLAGWRD2
                EXTEND
                RXOR            L
                TS              FLAGWRD2
                TCF             ENDUP

#          THE FOLLOWING CODING ISSUES THE SINGLE LMP COMMAND FOUND IN UPINDEX PROVIDED THE TIMERS ARE ENABLED
# (NON TIME CRITICAL PHASE OF MISSION).

DOV67           CS              FLAGWRD2
                MASK            BIT5
                CCS             A
                TCF             UPERROR

                CS              BIT8                            # COMMAND MUST BE BETWEEN 1 AND 255.
                AD              UPINDEX
                TC              MAGSUB
                DEC             -127
                TCF             UPERROR

                CAF             TC1LMP
                TS              UPINDEX         -1
                CAF             TCFENDUP
                TS              UPINDEX         +1
                TC              UPINDEX         -1

TC1LMP          TC              1LMP                            # FOR ERASABLE CALL.

## Page 810
#          THE FOLLOWING CODING UPDATES A MISSION PHASE NUMBER WHOSE INDEX IS IN UPINDEX TO THE VALUE FOUND
# IN UPPHASE. RETURN IS TO CALLER IF DATA OK, OR TO UPERROR IF DATA OUT OF RANGE.

MPHASEUP        CA              Q
                TC              CHKUPDEX                        # CHECK INDEX VALUE AND MAKE INTERNAL NDX.

                CCS             UPPHASE                         # CHECK ON SIZE OF PHASE.
                TCF             +4
                TCF             UPERROR
                TCF             UPERROR
                TCF             UPERROR

 +4             TC              MAGSUB
                OCT             -21                             # ALLOW PHASES 1 - 18D ONLY.
                TCF             UPERROR                         # FOR BAD RETURN FROM MAGSUB
                CS              UPPHASE                         # CHECK LEGALITY OF UPPHASE
                AD              SIX
                CCS             A
                TCF             UPERROR
MPLEGAL         OCT             72400                           # BITS 15 - 1 = 1 FOR MP 7 - 21 LEGAL
                TCF             +2
                TCF             UPERROR

                INDEX           A
                CA              BIT15
                MASK            MPLEGAL
                EXTEND
                BZF             UPERROR

                TC              MRETURN

# MINOR SUBROUTINE TO CHECK MISSION TIMER/PHASE UPDATE INDEX AND LEAVE CORRESPONDING VALUE IN RUPTREG1.

# TO BE ENTERED WITH INTERRUPT INHIBITED:

CHKUPDEX        TS              MRETURN                         # CALLER'S RETURN ARRIVES IN A.
 +1             CCS             UPINDEX
                TCF             +4
                TCF             UPERROR
                TCF             UPERROR
                TCF             UPERROR

 +4             MASK            NEG3
                CCS             A
                TCF             UPERROR

                CS              UPINDEX                         # MAKE INTERNAL VALUE.
                AD              FOUR
                TS              RUPTREG1
                TC              Q

## Page 811
#          THE FOLLOWING CODING UPDATES THE MISSION TIMER WHOSE INDEX IS IN UPINDEX BY ADDING THE CONTENTS OF UPDT
# TO IT. OUTCOMES DEPEND ON WHETHER THE TIMER WAS COUNTING AT THE TIME, AND THE SIGN OF THE RESULT (SEE GSOP).

MTIMERUP        CA              Q                               # GO TO COMMON SUBROUTINE TO SAVE RETURN
                TC              CHKUPDEX                        # AND CHECK INDEX.
                INDEX           RUPTREG1                        # SEE IF TIMER IS COUNTING NOW.
                CCS             MTIMER4
                TCF             TUPBUSY                         # POS INDICATES IT IS.
                TCF             TUPBUSY
                NOOP

                CA              UPDT                            # IF NOT BUSY, LOAD WITH DT DIRECTLY, WITH
                TCF             CTRABS                          # NO CHANGE TO THE MAINTENANCE FLAG STATE.

TUPBUSY         CCS             UPDT                            # IF TIMER COUNTING, SEE IF DT ZERO.
                TCF             CTRAD                           # NZ - DO ADD.
                TCF             CTRABS                          # +0 - PHASE DUE NEXT MAINTENANCE CYCLE.
                TCF             CTRAD

                CS              ZERO                            # IF -0, DISABLE TIMER.
CTRABS          INDEX           RUPTREG1
                TS              MTIMER4
                TC              MRETURN

CTRAD           TC              CTRADSUB
                CCS             A                               # IF RESULT NEGATIVE OR ZERO, PHASE DUE
                TC              MRETURN                         # NEXT MAINTENANCE CYCLE.
                TC              MRETURN
                CAF             ZERO
                TCF             CTRABS                          # (THIS ALONE REVERTS -0 TO +0.)



CTRADSUB        CA              UPDT
                INDEX           RUPTREG1
                AD              MTIMER4
                OVSK
                TCF             +2                              # NO OVERFLOW (NORMAL CASE).
                TC              UPERROR                         # IF OVFLO, GO TO UPERROR WITH TIMER
                INDEX           RUPTREG1                        # UNCHANGED.
                TS              MTIMER4
                TC              Q

## Page 812
#          THE FOLLOWING CODING IS THE SAME AS MTIMERUP BUT ACCEPTS DP GET IN UPGET (SEE GSOP).

MGETUP          TC              INTPRET                         # MAKE SURE THIS ENTERED WITH VAC AREA.

                RTB             BDSU                            # TIME IN CS.
                                LOADTIME
                                UPGET
                DMP             SL                              # CONVERT TO SEC & MOVE TO MAJOR PART.
                                1/100
                                14D
                BOVB            BMN
                                UPERROR
                                UPERROR         -1              # (DOES AN EXIT.)

                EXIT

                INHINT
                CA              BIT5                            # INSURE THAT MAINTENANCE IS STILL ENABLED
                MASK            FLAGWRD2
                EXTEND
                BZF             UPERROR

                TC              CHKUPDEX        +1
                CA              MPAC                            # CONTAINS DT IN SECONDS.
                INDEX           RUPTREG1
                TS              MTIMER4                         # INSERT DT DIRECTLY INTO TIMER.

#          GENERAL EXIT LOCATION FOR SUCCESSFULLY COMPLETED UPDATE:

ENDUP           CAF             ZERO                            # TURN OFF GROUP 6.
                TC              NEWPHASE
                OCT             6

                TCF             ENDOFJOB

#          EXIT FOR GENERAL UPDATE ERRORS (RANGE OF DATA, ETC.)

 -1             EXIT

UPERROR         TC              FALTON
                TCF             ENDUP                           # RELINT, & ENDOFJOB.

## Page 813
#          THE FOLLOWING TABLE SPECIFIES STARTING LOCATIONS AND PRIORITIES OF ALL 206 MISSION PHASES INITIATED BY
# THE MISSION TIMERS (S4B-LEM SEP AND BEYOND). IT ALSO CONTAINS INHIBIT/ENABLE INFORMATION, ETC. EACH ENTRY
# CONSISTS OF THREE WORDS. THE FIRST IS PACKED WITH SEVERAL PIECES OF INFORMATION, AND THE SECOND TWO CONTAIN THE
# 2CADR OF THE LOCATION AT WHICH THE PHASE IS TO BEGIN. THE INTERPRETATION OF WORD 1 IS AS FOLLOWS:

#          BIT15:         SPARE
#          BITS 14-10:    JOB PRIORITY.
#          BITS 9-5:      SPARE
#          BIT4:          1 IF TIMERS TO BE DISABLED ON PHASE INITIATION.
#          BIT3:          1 IF RCS TESTS (INHIBIT/ENABLE INFO).
#          BIT2:                  1 IF DPS COLD SOAK
#          BIT1:                  1 IF RCS COLD SOAK

# NOTE SPARES COULD BE USED FOR SWITCHING DOWNLISTS, ETC.

#          PHASES 1 - 6 ARE NOT INCLUDED SINCE THEY ARE NOT INITIATED BY THE MISSION SCHEDULING ROUTINES.
MTABLE1         OCT             20010                           # MP7
                EBANK=          TDEC
                2CADR           MP07JOB

                OCT             20012                           # MP8
                EBANK=          RATEINDX
                2CADR           MP8JOB

                OCT             20010                           # MP9
                EBANK=          TDEC
                2CADR           MP9JOB

1/100           2DEC            0.01                            # MP 10.  UNUSED SLOT.

34OCT           OCT             00034

                OCT             20010                           # MP11
                EBANK=          TDEC
                2CADR           MP11JOB

                TC              CCSHOLE                         # MP 12.  UNUSED SLOT.
                TC              CCSHOLE
                TC              CCSHOLE

                OCT             20010                           # MP13
                EBANK=          TDEC
                2CADR           MP13JOB

                TC              CCSHOLE                         # MP 14.  UNUSED SLOT.
                TC              CCSHOLE
                TC              CCSHOLE

MTABLE          EQUALS          MTABLE1         -21D            # MP 1-6 NOT ACTUALLY INCLUDED IN TABLE.

## Page 814
BADPHASE        TC              ALARM                           # ALARM WHEN MPHASE COMES DUE BUT MPHASE
                OCT             00601                           # REGISTER IS ZERO (-0 MEANS INACTIVE).

                CAF             PRIO37
                TC              NOVAC
                EBANK=          LST1
                2CADR           FORGETIT

                TC              TASKOVER
