### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     MISSION_PHASE_16-RCS_COLD_SOAK.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-29 MAS  Transcribed.
##		 2016-12-06 RSB	 Comments proofed using octopus/ProoferComments,
##				 no changes made.

## Page 764
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

MP16JOB         TC              NEWMODEX                        # UPDATE PROGRAM NUMBER
                OCT             16                              # ON DSKY

                TC              COLDSOAK                        # CALCULATE CDU ANGLES REQUIRED
                CAF             PRIOKM                          # SCHEDULE KALCMANU
                INHINT
                TC              FINDVAC
                EBANK=          EDOT
                2CADR           KALCMAN3

                RELINT
                CCS             NEWJOB                          # FORCE KALCMANU JOB ON
                TC              CHANG1

## Page 765
                TC              BANKCALL                        # PUT JOB TO SLEEP TILL
                CADR            ATTSTALL                        # MANEUVER COMPLETED
                NOOP                                            # TC   BADATT-SICK RETURN- ***FIX THIS***

                CAF             DEC1000                         # GOOD RETURN--MAN. COMPLETED
                INHINT
                TC              WAITLIST                        # WAIT 10 SECONDS
                EBANK=          EDOT
                2CADR           PHAS16A

                RELINT
                CAF             P16WAKE                         # PUT THIS JOB
                TC              JOBSLEEP                        # TO SLEEP
P16WAKE         CADR            PHAS16B
DEC1000         DEC             1000
PHAS16A         CAF             P16WAKE                         # REACTIVATE THE JOB
                TC              JOBWAKE                         # THAT WAS PUT TO SLEEP
                TC              IBNKCALL                        # DO DFI T/M CALIBRATION ROUTINE
                CADR            DFITMCAL

                TC              TASKOVER

#                                         WAIT FOR COMPLETION OF CALIBRATION + 1 SECOND

PHAS16B         CAF             DEC1300                         # 13 SECONDS
                INHINT
                TC              WAITLIST
                EBANK=          EDOT
                2CADR           P16MXDB

                TC              ENDOFJOB
P16MXDB         CAF             BIT13                           # SELECT MAX DEADBAND FOR DAP-
                ADS             DAPBOOLS                        # SET BIT 13 OF DAPBOOLS =1
                TC              1LMP                            # THRUSTER ISOL VALVES PR 3A CLOSE
                DEC             94
                TC              1LMP                            # THRUSTER ISOL VALVES 3B CLOSE
                DEC             110
                CAF             DEC200                          # WAIT 2 SECS
                TC              WAITLIST
                EBANK=          EDOT
                2CADR           P16CLS

                TC              TASKOVER
DEC200          DEC             200
P16CLS          TC              1LMP                            # THRUSTER ISOL VALVES PR 3A-
                DEC             95                              # CLOSE RESET
                TC              1LMP                            # THRUSTER ISOL VALVES PR 3B-
                DEC             111                             # CLOSE RESET
                TC              TASKOVER
DEC1300         DEC             1300

