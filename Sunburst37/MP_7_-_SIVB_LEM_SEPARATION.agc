### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MP_7_-_SIVB_LEM_SEPARATION.agc
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
## Reference:   pp. 669-675
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-14 RSB	Transcribed.
##              2017-06-14 HG   Fix operand EBANK -> EBANK4
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 669
                BANK            25
                EBANK=          TDEC

# PROGRAM DESCRIPTION- MISSION PHASE 7 - SIVB/LEM SEPARATION              DATE- 21 OCT 66
# MOD NO- 0                                                               LOG SECTION- MP 7 - SIVB/LEM SEPARATION
# MOD BY- GILBERT                                                         ASSEMBLY- SUNBURST REVISION 12

# FUNCTIONAL DESCRIPTION

#           SIVB/LEM SEPARATION IS STARTED 39 MIN. 56 SEC. AFTER SIVB SHUTDOWN IS DETECTED. AT 00/11/04, ONE
# MINUTE AFTER BOOST SHUTDOWN IS DETECTED, MISSION TIMER NO. 1 IS SET TO 38M 56S AND MISSION PHASE REGISTER NO. 1
# TO MP 7. MISSION PHASE 7 STARTS AT 00/50/00. THIS PROGRAM COMMANDS A SEQUENCE OF EVENTS INCLUDING RCS COLD
# FIRE PURGE, RCS PRESSURIZATION, S BAND SYSTEM ACTIVATION, +X TRANSLATION INITIATION OF LEM/SIVB SEPARATION
# SEQUENCE, AND AGS ACTIVATION. IMMEDIATELY AFTER PHYSICAL SEPARATION, 00/54/00, THE PGNCS HOLDS THE ATTITUDE RATE
# WHICH EXISTED AT SEPARATION TO MINIMIZE THE PROBABILITY OF RE-CONTACT. RCS +X TRANSLATION IS TERMINATED 15
# SECONDS AFTER SEPARATION AT 00/54/15 AT WHICH TIME AUTOMATIC ATTITUDE HOLD IS INITIATED. THIS TERMINATION
# FOLLOWS A SEQUENCE STARTING AT 00/53/55 DURING WHICH THE JETS ARE TURNED ON FOR 10 SECONDS, OFF FOR 5 SECONDS,
# AND ON FOR 5 SECONDS. THIS IS DUE TO THE POSSIBILITY OF HEAT AFFECTING THE RENDEZVOUS RADAR ANTENNAE.
# MISSION PHASE TIMER NO. 4 IS SET TO START MISSION PHASE 8 (DPS COLD SOAK) IN 08 SECONDS. MISSION PHASE TIMER
# NO. 2 IS SET TO START MISSION PHASE 9 (DPS 1) IN 3H 1M 47S. MAJOR MODE 14 IS DISPLAYED DURING THIS PHASE.

# CALLING SEQUENCE
#     SIVB/LEM SEPARATION IS CALLED BY THE MISSION SCHEDULING ROUTINE AS A JOB. THE MISSION SCHEDULING ENTRY
# ROUTINE WAS CALLED 1 MINUTE AFTER BOOST SHUTDOWN IN MISSION PHASE 6 TO SET TIMER NO. 1 TO 38 MINUTES 56 SECONDS.

# SUBROUTINES CALLED
#     NEWMODEX, WAITLIST, FIXDELAY, 1LMP+DT, 2LMP+DT, FLAG1UP, FLAG1DWN, MPENTRY, MIDTOAVE, AVETOMID, TPAGREE,
# PREREAD, READACCS, SERVICER, AVERAGEG.

# NORMAL EXIT MODE
#     TASKOVER (ENDOFJOB INITIALLY SINCE TASK IS REQUESTED)

# ALARM OR ABORT EXIT MODES
#     NONE

# INPUT
#     MISSION SCHEDULING MAINTENANCE ROUTINE MUST BE INHIBITED AT BEGINNING AND ENABLED AT END OF MISSION PHASE 7.

# OUTPUT
#     RCS COLD FIRE PURGE, RCS PRESSURIZATION, S BAND SYSTEM ACTIVATION, +X TRANSLATION, INITIATION OF LEM/SIVB
# SEPARATION SEQUENCE, AND SCHEDULING OF MISSION PHASES 8 AND 9 (DPS COLD SOAK AND DPS 1).

# ERASABLE INITIALIZATION REQUIRED
#     NORMAL MISSION SEQUENCE SETS ERASABLES PROPERLY

# DEBRIS
#     CENTRALS - A,L,Q
#     OTHER    - ERASABLES IN SUBROUTINES USED

## Page 670
MP07JOB		EXTEND
                DCA             TIME2                           # SET UP TIME FOR MIDTOAVE
                DXCH            TDEC
                EXTEND
                DCA             MP07DELT
                DAS             TDEC

                EXTEND
                DCA             TDEC
                DXCH            TIMEHOLD                        # NO RADAR ON 206

                TC              NEWMODEX                        # DISPLAY MAJOR MODE 14
                OCT             14

                EXTEND
                DCA             MIDAVE2C                        # PRIOR TO THRUST
                DXCH            Z

                TC              PHASCHNG
                OCT		05022
                OCT		20000
                
                CAF             AVRAGEG7                        # SERVICER CALLS AVERAGEG
                TS              DVSELECT

                EXTEND
                DCA             SVREXIT                         # NORMAL EXIT FROM AVERAGEG
                DXCH            AVGEXIT

                CAF             JETS+X                          # RCS COLD FIRE PURGE
                EXTEND
                WRITE           5

                TC              PHASCHNG
                OCT             47012
                DEC             4000
                EBANK=          TDEC
                2CADR           SIVBSEP
                
                
                INHINT
                CAF		40SEC
                TC		WAITLIST
                EBANK=		TDEC
                2CADR		SIVBSEP
                
                TC		ENDOFJOB			# AND RELINT
                
SIVBSEP		TC		PHASCHNG
		OCT		05012
		OCT		77777
## Page 671		
		CAF		ZERO				# TERMINATE RCS COLD FIRE PURGE
		EXTEND
		WRITE 		5
		
		TC		PHASCHNG
		OCT		47012
		DEC		400
		EBANK=		TDEC
		2CADR		SIVB1
		
                TC              FIXDELAY                        # WAIT 4 SECONDS
                DEC             400

SIVB1           TC              2LMP+DT
                DEC             188                             # RCS MAIN S/O VALVES, SYS. A - OPEN **
                DEC             190                             # RCS MAIN S/O VALVES, SYS. B - OPEN **
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                
                DEC             4                               # ED BATTERY ACTIVATION - ON
                DEC             100                             # WAIT 1 SECOND

                TC              2LMP+DT
                DEC             189                             # RESET **
                DEC             191                             # RESET **
                DEC             900                             # WAIT 9 SECONDS

                TC              1LMP+DT
                DEC             6                               # RCS PRESSURIZE - FIRE **
                DEC             200                             # WAIT 2 SECONDS

                TC              1LMP+DT
                DEC             7                               # RESET **
                DEC             2800                            # WAIT 28 SECONDS

                TC              1LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION - SAFE *
                DEC             9500                            # WAIT 95 SECONDS                              ...
                
                EXTEND
                DCA             TIMEHOLD
                DXCH            DT2TEMPD
                
                EXTEND
                DCS             TIME2                           # TIG - 28 SEC.  =  TDEC + 2 SEC.
                DAS             DT2TEMPD

                TC              PHASCHNG
                OCT             05012
                OCT             77777

## Page 672
                EXTEND
                DCA             DT2TEMPD
                
                DXCH            TIMEHOLD
                CCS             TIMEHOLD        +1              # INSURE WAITLIST TIME POSITIVE
                AD              ONE
                TCF             +3
                COM
                AD              POSMAX 
                TS		DT2TEMP
                TC		WAITLIST                        # REQUEST LASTBIAS AT TIG - 30 SECONDS
                EBANK=          TDEC
                2CADR           TIG-30

                TC              2PHSCHNG
                OCT             40052
                OCT             47014
               -GENADR          DT2TEMP
                EBANK=          TDEC
                2CADR           TIG-30

                TC              FIXDELAY                        # WAIT 55 SECONDS
                DEC             5500

SIVB2           TC              IBNKCALL                        # DEADBAND SELECT - MAX
                CADR            SETMAXDB

                CAF             JETS+X                          # COMMAND +X TRANSLATION - ON (4 JET)
                EXTEND
                WRITE           5
                TC              IBNKCALL
                CADR            ULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             100
                EBANK=          TDEC
                2CADR           SIVB3

                TC              FIXDELAY                        # WAIT 1 SECOND
                DEC             100

SIVB3           TC              1LMP+DT
                DEC             138                             # XMTR/RCVR (S-BAND) - PRIM *
                DEC             300                             # WAIT 3 SECONDS

                TC              1LMP+DT
                DEC             58                              # LEM/SIVB SEPARATE ARM - ON *
                DEC             50                              # WAIT 500 MILLISECONDS

                CS              DAPBOOLS                        # ENABLE DAP
## Page 673
                MASK            GODAPGO
                ADS             DAPBOOLS

                TC              FIXDELAY                        # WAIT 500 MILLISECONDS
                DEC             50

                TC              IBNKCALL			# GET VEHICLE RATE
                CADR            SETRATE                         # HOLD VEHICLE ATTITUDE RATE

                TC              1LMP+DT				
                DEC             90                              # LEM/SIVB SEPARATE - COMMAND **
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

                TC              1LMP+DT
                DEC             59                              # LEM/SIVB SEPARATE ARM - OFF *
                DEC             100                             # WAIT 1 SECOND

                TC              1LMP+DT
                DEC             91                              # RESET **
                DEC             300                             # WAIT 3 SECONDS

                TC              IBNKCALL                        # COMMAND +X TRANSLATION - OFF (4 JET)
                CADR            NOULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             500
                EBANK=          TDEC
## Page 674            
                2CADR           SIVB4

                TC              FIXDELAY                        # WAIT 5 SECONDS
                DEC             500

SIVB4           TC              IBNKCALL                        # COMMAND +X TRANSLATION - ON (4 JET)
                CADR            ULLAGE

                TC              PHASCHNG
                OCT             47012
                DEC             500
                EBANK=          TDEC
                2CADR           SIVB5

                TC              FIXDELAY                        # WAIT 5 SECONDS
                DEC             500

SIVB5           TC              IBNKCALL                        # COMMAND +X TRANSLATION - OFF (4 JET)
                CADR            NOULLAGE

                TC              FLAG1DWN                        # KNOCK DOWN AVERAGEG FLAG
                OCT             00001

                TC              IBNKCALL                        # HOLD LEM ATTITUDE
                CADR            STOPRATE

                TC              IBNKCALL                        # DEADBAND SELECT - MAX
                CADR            SETMAXDB

                TC              2PHSCHNG
                OCT             00002
                OCT             05013
                OCT             77777

                TC              MPENTRY                         # SCHEDULE DPS COLD SOAK
                DEC             4                               # TIMER NO. 4
                DEC             8                               # MISSION PHASE 8
                
                ADRES           MPDTO8

                TCF             TASKOVER

## Page 675
2SEC            DEC             200
40SEC           DEC             4000
MP07DELT        2DEC            20500

                EBANK=          TDEC
MIDAVE2C        2CADR           MIDTOAVE

                EBANK=          TDEC
SVREXIT         2CADR           SERVEXIT

JETS+X          OCT             00252
AVRAGEG7        GENADR          AVERAGEG



TIG-30          CAF		BIT1				# PREREAD CALLS READACCS IN 2 SECONDS
		TC		WAITLIST
		EBANK=		DVTOTAL
		
		2CADR		PREREAD
		
		TC		PHASCHNG
		OCT		40045
		
TASK4OUT	TC		PHASCHNG
		OCT		00004		

                TCF             TASKOVER
