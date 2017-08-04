### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LMP_COMMAND_ROUTINES.agc
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
## Reference:   pp. 746-747
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-08 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 746
#          THE FOLLOWING SUBROUTINES ALLOW MISSION PROGRAMS TO REQUEST LMP (LEM MISSION PROGRAMMER) OUTPUTS.

# THE PROPER DECIMAL CODE IS ENTERED INTO A TABLE AND FROM THENCE TO CHANNEL 10 VIA T4RUPT AND ARE INCLUDED IN
# THE DOWNLINK.

#          FOUR ROUTINES ARE PROVIDED:

#                                                  TC     1LMP            CALLED UNDER EXEC OR RUPT. DELIVERS CODE
#                                                  DEC    LMPCODE         AND RETURNS IMMEDIATELY.

#                                                  TC     2LMP            SAME AS 1LMP BUT TWO CODES ARE
#                                                  DEC    LMPCODE1        SENT.
#                                                  DEC    LMPCODE2

#                                                  TC     1LMP+DT         ASSUMES CALLED AS PART OF WAITLIST TASK.
#                                                  DEC    LMPCODE         DELIVERS LMP CODE, DOES A VARDELAY FOR
#                                                  DEC    DT              DT, AND THEN RETURNS UNDER WL CONTROL.

#                                                  TC     2LMP+DT         SAME AS 1LMP+DT BUT TWO CODES SENT.
#                                                  DEC    LMPCODE1
#                                                  DEC    LMPCODE2
#                                                  DEC    DT

# WARNING  ***** PROGRAMS UNDER EXEC WHICH CALL 1LMP + 2LMP MUST FIRST

#                INHIBIT INTERRUPT....RETURNS STILL INHIBITED.



                BLOCK           02
2LMP            INDEX           Q                       # PICK UP 1ST CODE
                CA              0
                INCR            Q
                LXCH            Q                       # SAVE 2ND CODE ADDRESS IN L

LMPGROUP        EQUALS          2
LMPTBASE        EQUALS          TBASE2

LMPPHASE        EQUALS          PHASE2

                TC              STORCOM         -1      # TO STORE IN BUFFER AND UPDATE POINTER

                LXCH            Q                       # RETREIVE 2ND CODE ADDRESS FROM L.

1LMP            INDEX           Q
                CA              0                       # GET LMP CODE
                INCR            Q                       # SET RETURN.
                AD              BIT15                   # SET SIGN TO SHOW NEW COMMAND IN BUFFER

STORCOM         INDEX           LMPIN
                TS              LMPCMD                  # INSERT IN NEXT SLOT IN BUFFER

UPLMPIN         CCS             LMPIN                   # UPDATE POINTER

## Page 747
                TCF             +2
                CAF             SEVEN
                TS              LMPIN
                TC              Q

2LMP+DT         INDEX           Q
                CA              0                       # PICK UP 1ST CODE
                INCR            Q
                LXCH            Q                       # 2ND CODE ADDRESS IN L.

                TC              STORCOM         -1      # STORE IN BUFFER AND UPDATE POINTER

                TCF             +2

1LMP+DT         EXTEND                                  # SAVE RETURN FOR RESTARTS
                QXCH            LMPRET                  # IS LXCH IF FROM ABOVE
                CA              BBANK
                TS              LMPBBANK

                EXTEND
                INDEX           LMPRET
                DCA             0                       # PICK UP CODE AND DT
                TC              STORCOM         -1      # GO TO STORE CODE AND UPDATE POINTER

                LXCH            SAVDT                   # SAVE FOR RESTART
                TC              PHASCHNG                # RESTART PROTECT DELAY
                OCT             47012
               -GENADR          SAVDT
                EBANK=          TBASE2
                2CADR           LMPRST

                CA              SAVDT                   # WAIT DT SECONDS
                TC              VARDELAY

LMPEXIT         INDEX           LMPRET
                TC              2

LMPRST          CA              LMPBBANK                # LMP+DT RESTARTS COME HERE
                TS              BBANK                   # AFTER DELAY.
                TC              LMPEXIT
