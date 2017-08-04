### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MP_3_SUBORBITAL_ABORT.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-23 MAS  Transcribed.
##		2016-10-31 RSB	Typos.
##		2016-12-06 RSB	Comments proofed using octopus/ProoferComments,
##				changes made.
##		2017-06-14 RSB	Added a ##-comment about the difference between
##				this code and SUNBURST 37.

## Page 686
                BANK            25
                EBANK=          TDEC


## Note that while the following comments identify this code as being precisely identical
## to the corresponding code in SUNBURST 37, there are in fact significant non-trivial
## changes between the two revisions. &mdash; RSB
# PROGRAM DESCRIPTION- MISSION PHASE 3 - SUBORBITAL ABORT                 DATE- 28 OCT 66
# MOD NO- 0                                                               LOG SECTION- MP 3 - SUBORBITAL ABORT
# MOD BY- GILBERT                                                         ASSEMBLY- SUNBURST REVISION 17

# FUNCTIONAL DESCRIPTION
#          IN THE FIRST 10 SECONDS OF THIS PHASE, THE GROUND IS CAUSING THE NOSECONE TO BE JETTISONED AND THE SLA
# PANELS TO BE DEPLOYED. 10 SECONDS AFTER RECEIPT OF THE ABORT COMMAND, MP3 CHECKS TUMBLING AND PROCEEDS ONLY
# WHEN THE INDICATED TUMBLING RATES ARE LESS THAN 3 DEGREES PER SECOND. MP3 THEN STARTS +X TRANSLATION AND
# COMMANDS SIVB/LEM SEPARATION. 13 SECONDS AFTER SEPARATION THE DESCENT ENGINE IS TURNED ON FOR 5 SECONDS, THEN
# IGNITED AGAIN AFTER A 5 SECOND COAST AND LEFT ON THROUGH THE ABORT STAGE COMMAND WHICH IS SENT/RECEIVED 31
# SECONDS LATER. THE APS ENGINE IS TURNED OFF 5 SECONDS AFTER ABORT STAGE, THEN IGNITED AGAIN AFTER A 30 SECOND
# COAST FOR A FINAL 60 SECOND BURN. IMU COMPENSATION CONTINUES THROUGHOUT THIS MISSION PHASE.

# CALLING SEQUENCE
#     SUBORBITAL ABORT IS STARTED AT THE DISCRETION OF THE GROUND IN THE EVENT OF AN ABORT DURING THE EARLIER PART
# OF BOOST. KEY CODE 23 IS SENT VIA UPLINK.

# SUBROUTINES CALLED
#    NEWMODEX, WAITLIST, FIXDELAY, 1LMP, 2LMP, 1LMP+DT, 2LMP+DT, FLAG1DWN, ENGINEON, ENGINOFF, ENGINOF1, PREREAD,
# READACCS, SERVICER, AVERAGEG.

# NORMAL EXIT MODES
#     TASKOVER.

# ALARM OR ABORT EXIT MODES
#     MAJOR MODE 71.

# INPUT
#     DVSELECT SET FOR READACCS AND SERVICER

# OUTPUT
#     ''LAST RITES''

# ERASABLE INITIALIZATION REQUIRED
#     KEY CODE 23 SENT VIA UPLINK.

# DEBRIS
#     CENTRALS - A,L,Q
#     OTHER    - ERASABLES IN SUBROUTINES USED

## Page 687
MP03JOB         TC              NEWMODEX                        # DISPLAY MAJOR MODE 71
                OCT             71

                CAF             THREE
                TS              PHASENUM

                TC              PHASCHNG
                OCT             47012
                DEC             1
                EBANK=          TDEC
                2CADR           SBORB1

                CAF             BIT3
                TC              SETRSTRT                        # SET RESTART FLAG

                INHINT
                CAF             ONE                             # 10 MS. - CONTINUE UNDER WAITLIST CONTROL
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           SBORB1

                TCF             ENDOFJOB                        # AND RELINT

SBORB1          CAF             ZERO                            # INSURE RCS JETS OFF
                EXTEND
                WRITE           6
                EXTEND
                WRITE           5

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB2

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB2          TC              2LMP+DT
                DEC             188                             # RCS MAIN S/O VALVES, SYS. A - OPEN **
                DEC             190                             # RCS MAIN S/O VALVES, SYS. B - OPEN **
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION - ON *
                DEC             100                             # WAIT 1 SECOND

                TC              2LMP+DT
                DEC             189                             # RESET **
                DEC             191                             # RESET **
## Page 688
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             6                               # RCS PRESSURIZE - FIRE **
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION - SAFE *
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             7                               # RESET **
                DEC             400                             # WAIT 4 SECONDS

TUMBCHK         CS              FLAGWRD1                        # IS VEHICLE RATE LESS THAN 3 DEG/SEC
                MASK            BIT13
                CCS             A
                TCF             TUMB1                           # YES

                TC              FIXDELAY                        # WAIT .5 SECONDS
                DEC             50

                TCF             TUMBCHK

TUMB1           TC              PHASCHNG
                OCT             05012
                OCT             77777

                TC              FLAG1DWN                        # TERMINATE TUMBLE MONITOR
                OCT             20000

                CAF             JETS+X                          # COMMAND +X TRANSLATION - ON (4 JET)
                EXTEND
                WRITE           5
                TC              IBNKCALL
                CADR            ULLAGE                          # USE LATER

                TC              1LMP+DT
                DEC             58                              # LEM/S4B SEPARATE ARM - ON *
                DEC             50                              # WAIT 500 MILLISECONDS

                CS              DAPBOOLS                        # ENABLE DAP
                MASK            GODAPGO
                ADS             DAPBOOLS

                TC              IBNKCALL                        # DEADBAND SELECT - MAX
                CADR            SETMAXDB

                TC              PHASCHNG
                OCT             47012
## Page 689
                DEC             50
                EBANK=          TDEC
                2CADR           TUMB2

                TC              FIXDELAY                        # WAIT 500 MILLISECONDS
                DEC             50

TUMB2           TC              IBNKCALL
                CADR            SETRATE                         # HOLD VEHICLE ATTITUDE RATE

                TC              2LMP+DT
                DEC             90                              # LEM/S4B SEPARATE - COMMAND **
                DEC             4                               # ED BATTERY ACTIVATION - ON *
                DEC             10                              # WAIT 100 MILLISECONDS

                TC              IBNKCALL                        # DEADBAND SELECT - MIN
                CADR            SETMINDB

                CS              FLAGWRD1                        # SETS SIVBGONE TO 1
                MASK            BIT4
                ADS             FLAGWRD1

                TC              PHASCHNG
                OCT             47012
                DEC             90
                EBANK=          TDEC
                2CADR           TUMB3

                TC              FIXDELAY                        # WAIT 900 MILLISECONDS
                DEC             90

TUMB3           TC              IBNKCALL
                CADR            ENGINOF1

                TC              2LMP+DT
                DEC             59                              # LEM/S4B SEPARATE ARM - OFF *
                DEC             150                             # ENGINE SELECT - DESC ARM *
                DEC             1                               # WAIT 10 MILLISECONDS

                CAF             BIT10                           # START ABORT STAGE DISCRETE MONITOR
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           ABTSTGDM

                TC              2PHSCHNG
                OCT             40072
                OCT             47016
                DEC             512
                EBANK=          TDEC
                2CADR           ABTSTGDM

## Page 690
SBORBA          TC              IBNKCALL                        # DEADBAND SELECT - MIN
                CADR            SETMINDB

                TC              1LMP+DT
                DEC             86                              # MANUAL THROTTLE - ON (10 PC) *
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             91                              # RESET **
                DEC             600                             # WAIT 6 SECONDS

                TC              IBNKCALL                        # HOLD LEM ATTITUDE
                CADR            STOPRATE
                TC              PHASCHNG
                OCT             47012
                DEC             400
                EBANK=          DVCNTR
                2CADR           SBORB3

                TC              FIXDELAY                        # WAIT 4 SECONDS
                DEC             400

                EBANK=          DVCNTR

SBORB3          CA              EBANK5
                TS              EBANK

                TC              1LMP+DT
                DEC             8                               # LANDING GEAR DEPLOY - FIRE **
                DEC             100                             # WAIT 1 SECOND

                TC              IBNKCALL
                CADR            DPSENGON
## DPSENGON in the above line has a green arrow pointing to it.

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          DVCNTR
                2CADR           SBORB4

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB4          TC              2LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION - SAFE *
                DEC             9                               # RESET **
                DEC             400                             # WAIT 4 SECONDS

                CA              ZERO                            # WE WANT TO DETECT ENGINOFF QUICKLY SO IT
                TS              SETDVCNT                        # WON'T INTERFERE WITH NEXT ENG ON.

## Page 691
                CA              ONE                             # DITTO.
                TS              DVCNTR

                TC              IBNKCALL
                CADR            ENGINOFF

                TC              PHASCHNG
                OCT             47012
                DEC             500
                EBANK=          DVCNTR
                2CADR           SBORB5

                TC              FIXDELAY                        # WAIT 5 SECONDS
                DEC             500

SBORB5          TC              IBNKCALL
                CADR            DPSENGON                        # DPSENGON WILL REFRESH SETDVCNT
## DPSENGON in the above line has a green arrow pointing to it.

                TC              PHASCHNG
                OCT             47012
                DEC             200
                EBANK=          DVCNTR
                2CADR           SBORB6

                TC              FIXDELAY                        # WAIT 2 SECONDS
                DEC             200

SBORB6          TC              IBNKCALL                        # COMMAND +X TRANSLATION - OFF (4 JET)
                CADR            NOULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             1900
                EBANK=          DVCNTR
                2CADR           SBORB7

                TC              FIXDELAY                        # WAIT 19 SECONDS
                DEC             1900

SBORB7          TC              1LMP+DT
                DEC             222                             # ASCENT WATER COOLANT VALVE - OPEN **
                DEC             200                             # WAIT 2 SECONDS

                TC              1LMP+DT
                DEC             223                             # RESET **
                DEC             300                             # WAIT 3 SECONDS

                CAF             PRIO30                          # THRUST REQUEST DURING JOB
                TC              FINDVAC
                EBANK=          ETHROT
## Page 692
                2CADR           TRST90PC

                TC              2PHSCHNG
                OCT             40112
                OCT             07024
                OCT             30000
                EBANK=          ETHROT
                2CADR           TRST90PC

                TC              FIXDELAY                        # WAIT 4 SECONDS
                DEC             400

SBORB8          TC              1LMP+DT
                DEC             38                              # ABORT STAGE - ARM *
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             22                              # ABORT STAGE - COMMAND *
                DEC             1                               # WAIT 10 MS

                TC              PHASCHNG
                OCT             00002

                TCF             TASKOVER                        # ABORT STAGE DISCRETE MONITOR RUNNING



                EBANK=          LEMMASS2
SBORBB          CAF             EBANK7
                TS              EBANK

                EXTEND
                DCA             LEMMASS2
                DXCH            MASS

                TC              IBNKCALL                        # SET UP DAP FOR APS BURN
                CADR            APSENGON

                EBANK=          TDEC
                CAF             EBANK4
                TS              EBANK

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB9

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

## Page 693
SBORB9          TC              1LMP+DT
                DEC             151                             # ENGINE SELECT - DESC ARM OFF *
                DEC             400                             # WAIT 4 SECONDS

                TC              IBNKCALL
                CADR            ENGINOFF

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB10

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB10         TC              2LMP+DT
                DEC             39                              # ABORT STAGE - COMMAND RESET *
                DEC             134                             # ENGINE SELECT - ASC ARM *
                DEC             2700                            # WAIT 27 SECONDS

                TC              IBNKCALL                        # COMMAND +X TRANSLATION - ON (4 JET)
                CADR            ULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             200
                EBANK=          TDEC
                2CADR           SBORB11

                TC              FIXDELAY                        # WAIT 2 SECONDS
                DEC             200

SBORB11         TC              IBNKCALL
                CADR            APSENGON

                TC              PHASCHNG
                OCT             47012
                DEC             200
                EBANK=          TDEC
                2CADR           SBORB12

                TC              FIXDELAY                        # WAIT 2 SECONDS
                DEC             200

SBORB12         TC              IBNKCALL                        # COMMAND +X TRANSLATION - OFF (4 JET)
                CADR            NOULLAGE

                TC              PHASCHNG
                OCT             47012
## Page 694
                DEC             5800
                EBANK=          TDEC
                2CADR           SBORB13

                TC              FIXDELAY                        # WAIT 58 SECONDS
                DEC             5800

SBORB13         TC              IBNKCALL
                CADR            ENGINOFF

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB14

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB14         TC              1LMP+DT
                DEC             135                             # ENGINE SELECT - ASC ARM OFF *
                DEC             2900                            # WAIT 29 SECONDS

                TC              FLAG1DWN                        # KNOCK DOWN AVERAGEG FLAG
                OCT             00001

                TC              IBNKCALL                        # DEADBAND SELECT - MAX
                CADR            SETMAXDB

                TC              PHASCHNG
                OCT             00002

                TC              TASKOVER



ABTSTGDM        CAF             BIT2                            # ABORT STAGE DISCRETE MONITOR
                EXTEND
                RAND            30

                EXTEND
                BZF             ABTSTG1                         # YES

                TC              FIXDELAY                        # WAIT .5 SECONDS
                DEC             50

                TCF             ABTSTGDM

ABTSTG1         TC              2PHSCHNG
                OCT             00004
## Page 695
                OCT             47012
                OCT             77777
                EBANK=          TDEC
                2CADR           SBORBB

                TC              2PHSCHNG
                OCT             00006
                OCT             00003

                CAF             PRIO37                          # GENERATE RESTART IMMEDIATELY
                TC              NOVAC
                EBANK=          LST1
                2CADR           ENEMA

                TCF             TASKOVER





TRST90PC        CAF             POSMAX                          # INCREASE THROTTLE 90 PERCENT
                TS              PCNTF
                EXTEND
                DCA             THRSTLOC
                DXCH            Z

                TCF             ENDOFJOB





                EBANK=          ETHROT
THRSTLOC        2CADR           PCNTFMAX
