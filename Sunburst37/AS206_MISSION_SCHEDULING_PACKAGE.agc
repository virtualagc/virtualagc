### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AS206_MISSION_SCHEDULING_PACKAGE.agc
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
## Reference:   pp. 748-762
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-07 MAS  Updated for Sunburst 37. There's a decent number
##                              of differences.
##              2017-06-15 HG   Fix page number 814 -> 762
##                              Add missing instruction TCF ENDUP
##                              remove operand modifier CHKUPDEX +1 -> CHKUPDEX
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 748
#          THE FOLLOWING ROUTINES IMPLEMENT THE MISSION SCHEDULING LOGIC AS DESCRIBED IN CHAPTER 4 OF THE
# AS206 OPERATIONS PLAN. THE FOLLOWING ROUTINE IS ENTERED ONCE EACH SECOND FOR MOST OF THE DURATION OF THE

# FLIGHT, ONCE LIFT-OFF HAS OCCURRED. AN EXCEPTION TO THIS IS THE TIME-CRI

# RESTART  GROUP  FOR MISSION SCHEDULING PACKAGE IS GROUP 3.

                BANK            31
                EBANK=          MTIMER4

MMAINT          CAF             THREE                           # LOOP TO PROCESS ALL FOUR TIMERS.
                TS              MINH                            # AT END OF TIMER UPDATE, THIS REGISTER
                                                                # WILL NOT BE EQUAL TO 3 IF MAINTENANCE IS

                                                                # TO CEASE.
MLOOP           TS              RUPTREG1

                INDEX           A                               # LOOK AT TIMER.
                CCS             MTIMER4
                TCF             MCOUNT                          # PNZ - ACTIVE AND COUNTING DOWN.
                TCF             MDUE                            # +0 - MISSION PHASE DUE.
                AD              ONE                             # NNZ - FREE BUT LOADED BY GROUND.
                COM                                             # -0 - FREE.
MCOUNT          INDEX           RUPTREG1                        # PLACE UPDATED TIMERS AND PHASE REGISTERS
                TS              MTIMER4T                        # INTO COPY BUFFER FOR RESTART PROTECTION.


                INDEX           RUPTREG1
                CA              MPHASE4
MENTERED        INDEX           RUPTREG1
                TS              MPHASE4T

                CCS             RUPTREG1
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

## Page 749
 -1             CAF             STATECRI
MSTATEOK        TS              STATECTR

                CA              NEWMTIME                        # COPY FOR RESTART PROTECTION
                TS              NEWTIMET

                TC              PHASCHNG                        # UPDATE RESTART
                OCT             04013

REDO3.3         CAF             SEVEN                           # COPY NEW TIMERS AND PHASE REGISTERS.
MCOPY           TS              RUPTREG1
                INDEX           A
                CA              MTIMER4T
                INDEX           RUPTREG1
                TS              MTIMER4
                CCS             RUPTREG1
                TCF             MCOPY

                CS              THREE                           # SEE IF FURTHER MAINTENCE HAS BEEN

                MASK            MINH                            # INHIBITED BY THE INITIATION OF A TIME-
                CCS             A                               # CRITICAL MISSION PHASE.
                TCF             MINHIBIT

                CAF             1SEC                            # UPDATE T1 SETTING FOR NEXT UPDATE
                ADS             NEWMTIME

                TC              PHASCHNG
                OCT             04013                           # IMMECIATE RESTART AT NEXT LOCATION

                CS              TIME1                           # GET DT FOR NEXT SCHEDULING REQUEST.
                AD              NEWTIMET

                EXTEND
                BZMF            +2                              # CORRECT FOR CLOCK OVERFLOW.
                TCF             +3

                AD              HALF
                AD              HALF
 +3             TC              WAITLIST
                EBANK=          MTIMER4
                2CADR           MMAINT


                TC              TASKOVER

MINHIBIT        TC              FLAG2DWN                        # RESET TIMERS ENABLED FLAG.
                OCT             20

                TC              PHASCHNG
                OCT             00003

                TCF             TASKOVER

## Page 750
1SEC            DEC             100

## Page 751
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

                CAF             BIT4                            # SET MRETURN  IF COUNTERS ARE TO STOP.
                MASK            RUPTREG2
                ADS             MINH

                CAF             PRIO37
                MASK            RUPTREG2
                TS              NEWPRIO
                EXTEND

                INDEX           L                               # PICK UP 2CADR AND DO FINDVAC.
                DCA             MTABLE          +1
                TC              SPVAC

                TC              2PHSCHNG
                OCT             00032                           # 2.3SPOT TO RESTART MISSION PHASE NOW DUE
                OCT             04013                           # GROUP 3 RESTART FOR MISSIN SCHEDULER

                CA              MDUETEMP
                TS              RUPTREG1                        # RUPTREG1 WAS DESTROYED BY 2PHSCHNG

                CAF             PRIO30                          # SET UP JOB TO TERMINATE ANY UPDATE

                TC              NOVAC                           # POSSIBLY IN PROGRESS & RELEASE DISPLAY.
                EBANK=          MTIMER4                         # PINBALL USES UNSWITCHED ERASABLE
                2CADR           UPDATKIL

MBYPASS         CS              ZERO
                INDEX           RUPTREG1                        # MAKE THIS TIMER/PHASE PAIR AVAILABLE.
                TS              MTIMER4T
                TCF             MENTERED                        # JOINS MAIN CODING.

## Page 752
# RESTART  ROUTIN E TO RESCHEDULE MISSION PHASE

REDOMDUE        INDEX           MDUETEMP                        # FIND PRIO AND 2CADR OF NEW MP
                CA              MPHASE4                         # IN TABLE.  MDUETEMP CONTAINS
                EXTEND                                          # THE PHASE REGISTER NUMBER OF THE
                MP              THREE                           # MISSION PHASE DUE AT THIS TIME
                INDEX           L
                CA              MTABLE
                MASK            PRIO37
                TS              NEWPRIO
                EXTEND
                INDEX           L

                DCA             MTABLE          +1
                TC              SPVAC                           # DO FINDVAC WITH 2CADR IN A +  L
                TCF             TASKOVER



# DO A PSEUDO VERB 34 ENTER TO KILL AN UPDATE IN PROGRESS, AND TO RELEASE THE DSKY.

UPDATKIL        CAF             34OCT
                TS              REQRET
                TC              BANKCALL
                CADR            UPDATVB         -1

                TC              POSTJUMP
                CADR            VBTERM                          # GOES TO ENDOFJOB WHEN DONE

## Page 753
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

## Page 754
# SUBROUTINE TO START MISSION TIMERS IF THEY ARE NOT GOING ALREADY.

MSTART          CA              FLAGWRD2                        # SEE IF TIMERS ENABLED ALREADY.
                MASK            BIT5
                CCS             A
                TCF             MDONE                           # YES - RETURN.

                TC              PHASCHNG                        # UPDATE RESTART BEFORE SETTING FLAG.
                OCT             05013
                OCT             77777

                TC              FLAG2UP                         # SHOW TIMERS ENABLED.
                OCT             20


                INHINT

                CAF             1SEC+1
                AD              TIME1
                XCH             NEWMTIME

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

## Page 755
# SUBROUTINE CALLS FOR VARIOUS UPDATE OPTIONS (SEE GSOP).  ENTER UNDER EXEC WITH INTERRUPT INHIBITED.

                BANK            31
DOV70           TC              MTIMERUP                        # VERB 70
                TCF             ENDUP

DOV72           TC              MTIMERUP                        # VERB 72
DOV71           TC              MPHASEUP                        # VERB 71
                TCF             ENDUP

#    *** C ODING  TO BE INSERTED HERE TO CLEAR OUT ALL TIMER/PHASE PAIRS
#        W HICH H AVE BEEN SET BY LGC, SINCE GROUND REQUEST WILL SUPERSEDE
#          ALL PR EVIOUSLY SCHEDULED MPS EXCEPT THOSE SET BY GROUND ITSELF

# DOV74         EQUALS          FORGETIT
ENDV73          RELINT
TCFENDUP        TCF             ENDUP

## Page 756
# INVERT INHIBIT/ENABLE SWITCH WHOSE INDEX IS IN UPINDEX (1 TO 3).  ENTER UNDER EXEC WITH INTERRUPT INHIBITED.


DOV73           CS              TWO
                AD              UPINDEX
                TC              MAGSUB                          # SEE IF INDEX LEGIT.
                DEC             -1
                TCF             UPERROR

                INDEX           UPINDEX
                CAF             BIT3            -1              # BITS IN POSITIONS 3, 2, AND 1 OF
                TS              L                               # FLAGWRD2 (SEE SWITCH ASSIGNMENTS).
                INHINT

                CA              FLAGWRD2
                EXTEND
                RXOR            L
                TS              FLAGWRD2
                TCF             ENDV73

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

## Page 757
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

                CA              UPPHASE

                INDEX           RUPTREG1
                TS              MPHASE4
                TCF             MDONE                           # RELINT & RETURN VIA MRETURN.

# MINOR SUBROUTINE TO CHECK MISSION TIMER/PHASE UPDATE INDEX AND LEAVE CORRESPONDING VALUE IN RUPTREG1.

# TO BE ENTERED WITH INTERRUPT INHIBITED:

CHKUPDEX        TS              MRETURN                         # CALLER'S RETURN ARRIVES IN A.
                CCS             UPINDEX

                TCF             +4
                TCF             UPERROR
                TCF             UPERROR
                TCF             UPERROR

 +4             MASK            NEG3
                CCS             A
                TCF             UPERROR

                CS              UPINDEX                         # MAKE INTERNAL VALUE.
## Page 758
                AD              FOUR
                TS              RUPTREG1
                TC              Q

## Page 759
#          THE FOLLOWING CODING UPDATES THE MISSION TIMER WHOSE INDEX IS IN UPINDEX BY ADDING THE CONTENTS OF UPDT
# TO IT. OUTCOMES DEPEND ON WHETHER THE TIMER WAS COUNTING AT THE TIME, AND THE SIGN OF THE RESULT (SEE GSOP).

MTIMERUP        CA              Q                               # GO TO COMMON SUBROUTINE TO SAVE RETURN
                TC              CHKUPDEX                        # AND CHECK INDEX.
                INDEX           RUPTREG1                        # SEE IF TIMER IS COUNTING NOW.

                CCS             MTIMER4
                TCF             TUPBUSY                         # POS INDICATES IT IS.
                TCF             TUPBUSY
                NOOP

                CA              UPDT                            # IF NOT BUSY, DO ADD, MAKING NO CHANGE
                INDEX           RUPTREG1                        # IN THE ENABLE FLAG.
                ADS             MTIMER4
                TCF             MDONE

TUPBUSY         CCS             UPDT                            # IF TIMER COUNTING, SEE IF DT ZERO.
                TCF             CTRAD                           # NZ - DO ADD.

                TCF             CTRABS                          # +0 - PHASE DUE NEXT MAINTENANCE CYCLE.
                TCF             CTRAD

                CS              ZERO                            # IF -0, DISABLE TIMER.
CTRABS          INDEX           RUPTREG1
                TS              MTIMER4
                TCF             MDONE

CTRAD           CA              UPDT
                INDEX           RUPTREG1

                ADS             MTIMER4
                CCS             A                               # IF RESULT NEGATIVE OR ZERO, PHASE DUE
                TCF             MDONE                           # NEXT MAINTENANCE CYCLE.
                TCF             MDONE
                CAF             ZERO
                TCF             CTRABS                          # (THIS ALONE REVERTS -0 TO +0.)

## Page 760
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

                TC              CHKUPDEX
                CA              MPAC                            # CONTAINS DT IN SECONDS.

                INDEX           RUPTREG1
                TS              MTIMER4                         # INSERT DT DIRECTLY INTO TIMER.

#          GENERAL EXIT LOCATION FOR SUCCESSFULLY COMPLETED UPDATE:

ENDUP           TCF             ENDOFJOB                        # (MORE TO BE ADDED?)

#          EXIT FOR GENERAL UPDATE ERRORS (RANGE OF DATA, ETC.)

 -1             EXIT

UPERROR         TC              FALTON
                TCF             ENDOFJOB

## The original listing reads simplye "E-2" here. A 1 has been added to conform to yaYUL's requirements.
1/100           2DEC            1 E-2

## Page 761
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

                TC              CCSHOLE                         # MP 10.  UNUSED SLOT.

                TC              CCSHOLE
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

## Page 762
BADPHASE        TC              ALARM                           # ALARM WHEN MPHASE COMES DUE BUT MPHASE

                OCT             00601                           # REGISTER IS ZERO (-0 MEANS INACTIVE).

                CAF             PRIO37
                TC              NOVAC
                EBANK=          LST1
                2CADR           FORGETIT

                TC              TASKOVER
