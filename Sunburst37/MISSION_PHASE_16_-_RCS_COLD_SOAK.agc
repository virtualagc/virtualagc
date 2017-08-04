### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MISSION_PHASE_16_-_RCS_COLD_SOAK.agc
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
## Reference:   pp. 711-712
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-08 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 711
                BANK            27
                EBANK=          EDOT
# PROGRAM DESCRIPTION
# MOD NO- 0                                           LOG SECTION-
# ******** NOTE-     MP16 NOT UP TO DATE ********
#                                                     RCS COLD SOAK
# FUNCTIONAL DESCRIPTION-
#          CHANGE ATTITUDE OF SPACECRAFT TO REQUIRED
#          ATTITUDE FOR COLD SOAK PHASES.
#          ISSUE LMP COMMANDS, ETC.
#          ACCORDING TO GSOP.
# CALLING SEQUENCE-
#          START MP 16 WHEN MISSION TIMER 4
#          COUNTS TO ZERO.
# SUBROUTINES CALLED-
#          BANKCALL
#          DFI T/M CAL. ROUTINE
#          EXECUTIVE
#          LEM MISSION PROGRAMMER
#          KALCMANU
#          WAITLIST
# NORMAL EXIT MODES-
#          TC    ENDOFJOB/TASKOVER
# ALARM OR ABORT EXIT MODES-   NONE
# OUTPUT- (INTERFACE, DISPLAYS, MEANINGFUL INFORMATIONLEFT IN ERASABLE).
#          SAME AS FOR KALCMANU EXCEPT-
#          BIT 13 OF DAPBOOLS IS SET TO 1 BEFORE EXIT.
# ERASABLE INITIALIZATION REQUIRED-
#          TEPHEM   IN CENTISECONDS TRIPLE PRECISION
# DEBRIS- (ERASABLE LOCATIONS DESTROYED BY THIS PROGRAM)
#          SAME AS FOR KALCMANU
# ORIENT THE LEM TO RCS COLD SOAK ATTITUDE
# (S/C X-AXIS NORMAL TO THE ECLIPTIC AND BISECTOR
# OF +Z/-Y AXES TOWARD THE SUN)

# START MISSION PHASE 16 WHEN MP TIMER 4 COUNTS TO ZERO

MP16JOB         TC              NEWMODEX                # UPDATE PROGRAM NUMBER
                OCT             16                      # ON DSKY

                TC              COLDSOAK                # CALCULATE CDU ANGLES REQUIRED
                CAF             PRIOKM                  # SCHEDULE KALCMANU
                INHINT
                TC              FINDVAC
                EBANK=          EDOT
                2CADR           KALCMAN3

                RELINT
                CCS             NEWJOB                  # FORCE KALCMANU JOB ON
                TC              CHANG1

## Page 712
                TC              BANKCALL                # PUT JOB TO SLEEP TILL
                CADR            ATTSTALL                # MANEUVER COMPLETED
                NOOP                                    # TC   BADATT-SICK RETURN- ***FIX THIS***

                CAF             DEC1000                 # GOOD RETURN--MAN. COMPLETED
                INHINT
                TC              WAITLIST                # WAIT 10 SECONDS
                EBANK=          EDOT
                2CADR           PHAS16A

                RELINT
                CAF             P16WAKE                 # PUT THIS JOB
                TC              JOBSLEEP                # TO SLEEP
P16WAKE         CADR            PHAS16B
DEC1000         DEC             1000
PHAS16A         CAF             P16WAKE                 # REACTIVATE THE JOB
                TC              JOBWAKE                 # THAT WAS PUT TO SLEEP
                TC              IBNKCALL                # DO DFI T/M CALIBRATION ROUTINE
                CADR            DFITMCAL

                TC              TASKOVER

#                                         WAIT FOR COMPLETION OF CALIBRATION + 1 SECOND

PHAS16B         CAF             DEC1300                 # 13 SECONDS
                INHINT

                TC              WAITLIST
                EBANK=          EDOT
                2CADR           P16MXDB

                TC              ENDOFJOB
P16MXDB         CAF             BIT13                   # SELECT MAX DEADBAND FOR DAP-
                ADS             DAPBOOLS                # SET BIT 13 OF DAPBOOLS =1
                TC              1LMP                    # THRUSTER ISOL VALVES PR 3A CLOSE
                DEC             94
                TC              1LMP                    # THRUSTER ISOL VALVES 3B CLOSE
                DEC             110
                CAF             DEC200                  # WAIT 2 SECS
                TC              WAITLIST
                EBANK=          EDOT
                2CADR           P16CLS

                TC              TASKOVER
DEC200          DEC             200
P16CLS          TC              1LMP                    # THRUSTER ISOL VALVES PR 3A-
                DEC             95                      # CLOSE RESET
                TC              1LMP                    # THRUSTER ISOL VALVES PR 3B-
                DEC             111                     # CLOSE RESET
                TC              TASKOVER
DEC1300         DEC             1300
