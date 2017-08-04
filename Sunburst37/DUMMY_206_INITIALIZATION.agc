### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    DUMMY_206_INITIALIZATION.agc
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
## Reference:   pp. 812-813
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-06 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 812
# PROGRAM NAME - BEGIN206
# MOD. NO. 3

# MOD BY - D. LICKLY AND J. SAMPSON
# DATE - NOV. 22, 1966
# LOG SECTION - DUMMY 206 INITIALIZATION
# ASSEMBLY - SUNBURST REVISION 36

# FUNCTIONAL DESCRIPTION - START UP TO TWO DELAYED JOBS OR TASKS AFTER SLAP1 FOR SIMULATION PURPOSES.

# FIXED INITIALIZATION REQUIRED - PATCH STARTDT1 AND STARTDT2 TO REPRESENT THE TIME2,TIME1 VALUE AT THE TIME AT
#                                   WHICH THE JOBS OR TASKS ARE TO BEGIN
#                                 PATCH CADR1 AND CADR2 IF SOME OTHER TASKS THAN TASK1 AND TASK2 ARE TO BE USED
#                                 PATCH CADR3 AND CADR4 TO THE 2CADR OF THE JOBS TO BE STARTED
#                                 PATCH 206BEGIN TO TC ENDOFJOB IF ONLY ONLY ONE TASK OR JOB IS TO BE STARTED
#                                 PATCH TASK1 AND TASK2 WITH DIFFERENT PRIORITIES IF DESIRED
# SUBROUTINES CALLED - FINDVAC, WAITLIST

# NORMAL EXIT MODES - ENDOFJOB, TASKOVER

# ALARM OR ABORT EXIT MODES - NONE

# OUTPUT - 2 WAITLIST OR FINDVAC CALLS FOR THE 2CADRS PATCHED IN

# ERASABLE INITIALIZATION REQUIRED - NONE

# DEBRIS - ITEMP1, CENTRALS, ERASABLES IN SUBROUTINES CALLED

# NOTES - SINCE ONLY THE LOW ORDER PART OF STARTDT1 AND STARTDT2 ARE USED OT COMPUTE THE DELTAT FOR WAITLIST, THE
#   REQUIRED TASKS AND JOBS WILL BE CALLED WITHIN 163.84 SECONDS


                BANK            35

BEGIN206        INHINT

                CS              TIME1                   # PATCH SLAP1 TO COME HERE TO START UP TWO
                AD              STARTDT1        +1      #   DELAYED TASKS OR JOBS FOR SIMULATIONS
                AD              BIT14
                AD              BIT14
                XCH             ITEMP1

                CA              ITEMP1
                TC              WAITLIST
                EBANK=          ITEMP1
CADR1           2CADR           TASK1                   # MAY BE PATCHED FOR ANOTHER TASK

206BEGIN        CS              TIME1                   # PATCH TO TC ENDOFJOB TO START 1 TASK
                AD              STARTDT2        +1
                AD              BIT14

## Page 813
                AD              BIT14
                XCH             ITEMP1

                CA              ITEMP1
                TC              WAITLIST
                EBANK=          ITEMP1
CADR2           2CADR           TASK2                   # COULD BE PATCHED

                TC              ENDOFJOB


STARTDT1        2DEC            600                     # PATCH

STARTDT2        2DEC            200                     # PATCH

TASK1           CAF             PRIO15                  # ..OR YOUR OWN PRIORITY..
                TC              FINDVAC
CADR3           OCT             77777                   # BETTER PATCH A 2CADR HERE
                OCT             77777
                TC              TASKOVER

TASK2           CAF             PRIO20
                TC              FINDVAC
CADR4           OCT             77777                   # ..HERE ALSO..
                OCT             77777
                TC              TASKOVER
