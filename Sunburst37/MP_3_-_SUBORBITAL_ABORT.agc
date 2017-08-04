### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MP_3_-_SUBORBITAL_ABORT.agc
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
## Reference:   pp. 644-653
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-14 RSB	Transcribed.  Note that while the comments (date, 
##				mod no, mod by, assembly revision) identify this
##				code as being identical to that in Sunburst 120,
##				in reality it has many differences.
##              2017-06-15 HG   Fix operand BIT2 -> BIT4
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 644
                BANK            25
                EBANK=          TDEC



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

## Page 645
MP03JOB         TC              NEWMODEX                        # DISPLAY MAJOR MODE 71
                OCT             71

                TC              PHASCHNG
                OCT             47012
                DEC             1
                EBANK=          TDEC
                2CADR           SBORB1

                INHINT
                CAF             ONE                             # 10 MS. - CONTINUE UNDER WAITLIST CONTROL
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           SBORB1

                TCF             ENDOFJOB                        # AND RELINT

SBORB1          TC		PHASCHNG
		OCT		05012
		OCT		77777

		CAF             ZERO                            # INSURE RCS JETS OFF
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
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             6                               # RCS PRESSURIZE - FIRE **
## Page 646
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

		TC		FLAG2DWN			# TERMINATE ABORT COMMAND MONITOR
		OCT		00400

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

                TC              FIXDELAY                        # WAIT 500 MILLISECONDS
                DEC             50
## Page 647

	        TC              IBNKCALL			# GET VEHICLE RATE
                CADR            SETRATE                         # HOLD VEHICLE ATTITUDE RATE

                TC              2LMP+DT
                DEC             90                              # LEM/S4B SEPARATE - COMMAND **
                DEC             4                               # ED BATTERY ACTIVATION - ON *
                DEC             10                              # WAIT 100 MILLISECONDS

                TC              IBNKCALL                        # DEADBAND SELECT - MIN
                CADR            SETMINDB

		EBANK=		LEMMASS1
		CAF		EBANK5
		TS		EBANK
		
		EXTEND
		DCA		LEMMASS1
		DXCH		MASS
		
		CAF		ZERO
		TS		DELAREA
		TS		DELAREA		+1
		
		EBANK=		TDEC
		CAF		EBANK4
		TS		EBANK

                TC              FIXDELAY                        # WAIT 900 MILLISECONDS
                DEC             90

                TC		ENGINOF1			# INSURE THAT ENGINE IS OFF

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
                
                OCT             47014
                DEC             512
                EBANK=          TDEC
                2CADR           ABTSTGDM

SBORBA          TC              IBNKCALL                        # DEADBAND SELECT - MIN
## Page 648
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
                EBANK=          TDEC
                2CADR           SBORB3

                TC              FIXDELAY                        # WAIT 4 SECONDS
                DEC             400

SBORB3          TC              1LMP+DT
                DEC             8                               # LANDING GEAR DEPLOY - FIRE **
                DEC             100                             # WAIT 1 SECOND

                TC              ENGINEON			# COMMAND ENGINE - ON

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB4

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB4          TC              2LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION - SAFE *
                DEC             9                               # RESET **
                DEC             400                             # WAIT 4 SECONDS

                TC            	ENGINOFF			# COMMAND ENGINE - OFF

                TC              PHASCHNG
                OCT             47012
                DEC             500
                EBANK=          TDEC
                2CADR           SBORB5

                TC              FIXDELAY                        # WAIT 5 SECONDS
## Page 649
                DEC             500

SBORB5          TC              ENGINEON			# COMMAND ENGINE - ON

                TC              PHASCHNG
                OCT             47012
                DEC             200
                EBANK=          TDEC
                2CADR           SBORB6

                TC              FIXDELAY                        # WAIT 2 SECONDS
                DEC             200

SBORB6          TC              IBNKCALL                        # COMMAND +X TRANSLATION - OFF (4 JET)
                CADR            NOULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             1900
                EBANK=          TDEC
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
                2CADR           TRST90PC

                TC              2PHSCHNG
                OCT             40112
                OCT             07023
                OCT             30000
                EBANK=          ETHROT
                2CADR           TRST90PC

                TC              FIXDELAY                        # WAIT 4 SECONDS
                DEC             400

SBORB8          TC              1LMP+DT
                DEC             22                              # ABORT STAGE - ARM *
## Page 650
                DEC             100                             # WAIT 1 SECOND
                
                TC		1LMP+DT
                DEC		38				# ABORT STAGE - COMMAND *
                DEC		1				# WAIT 10 MS

                TC              PHASCHNG
                OCT             00002

                TCF             TASKOVER                        # ABORT STAGE DISCRETE MONITOR RUNNING


SBORBB		EXTEND
		DCA		ENDJOB2C
		DXCH		FLUSHREG

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB9
                
                EBANK=		LEMMASS2
                CAF		EBANK5
                TS		EBANK
                
                EXTEND
                DCA		LEMMASS2
                DXCH		MASS
                
                EBANK=		TDEC
                CAF		EBANK4
                TS		EBANK

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB9          TC              1LMP+DT
                DEC             151                             # ENGINE SELECT - DESC ARM OFF *
                DEC             400                             # WAIT 4 SECONDS

                TC              ENGINOFF			# COMMAND ENGINE - OFF

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB10
## Page 651

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SBORB10         TC              1LMP+DT
                DEC             39                              # ABORT STAGE - COMMAND RESET *
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

SBORB11         TC              ENGINEON			# COMMAND ENGINE - ON

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
                DEC             5800
                EBANK=          TDEC
                2CADR           SBORB13

                TC              FIXDELAY                        # WAIT 58 SECONDS
                DEC             5800

SBORB13         TC              ENGINOFF			# COMMAND ENGINE - OFF

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SBORB14
## Page 652

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


ABTSTGDM        CAF             BIT4                            # ABORT STAGE DISCRETE MONITOR
                EXTEND
                RAND            30

                EXTEND
                BZF             ABTSTG1                         # YES

                TC              FIXDELAY                        # WAIT .5 SECONDS
                DEC             50

                TCF             ABTSTGDM

ABTSTG1         TC              2PHSCHNG
                OCT             00004
                OCT             47012
                OCT             77777
                EBANK=          TDEC
                2CADR           SBORBB

                EXTEND
                DCA		SBORBB2C
                DXCH		FLUSHREG

                CAF             PRIO37                          # GENERATE RESTART IMMEDIATELY
                TC              NOVAC
                EBANK=          TDEC
                2CADR           ENEMA

                TCF             TASKOVER

## Page 653



TRST90PC        CAF             POSMAX                          # INCREASE THROTTLE 90 PERCENT
                TS              PCNTF
                EXTEND
                DCA             THRSTLOC
                DXCH            Z

		TC		PHASCHNG
		OCT		00003

                TCF             ENDOFJOB


SBORBBJB	INHINT
		CAF		BIT1
		TC		WAITLIST
		EBANK=		TDEC
		2CADR		SBORBB
		
		TCF		ENDOFJOB
		
		
		EBANK=		LST1
ENDJOB2C	2CADR		ENDOFJOB

		EBANK=		TDEC
SBORBB2C	2CADR		SBORBBJB

                EBANK=          ETHROT
THRSTLOC        2CADR           PCNTFMAX
