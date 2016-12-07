### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RCS_FAILURE_MONITOR.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-30 HG   Transcribed
##		2016-10-31 RSB	 Typos.
##		2016-12-06 RSB	Comment proofing via octopus/ProoferComments
##				performed, and changes made.

## Page 569
# PROGRAM DESCRIPTION                                     DATE: 7 JAN 67 

#          AUTHOR:  J S MILLER    (MIT INSTRUMENTATION LAB)

#          THIS ROUTINE IS ATTACHED TO T4RUPT, AND IS ENTERED EVERY 960 MS.  ITS FUNCTION IS TO EXAMINE THE STATE
# OF THE LOW 8 BITS OF CHAN 32 TO SEE IF RCS-JET FAILURE BITS HAVE APPEARED OR DISAPPEARED.  WHEN A STATE CHANGE
# IS DETECTED WHICH PERSISTS FOR 2 SAMPLES (TO FILTER OUT NOISY SIGNALS), AN LMP COMMAND IS SENT (BUT AT MOST ONE
# SUCH COMMAND PER SAMPLE) TO ISOLATE THE APPROPRIATE JET PAIR IF THE FAILURE SIGNAL HAS JUST APPEARED.  IF, ON
# THE OTHER HAND, THE DISAPPEARANCE OF A FAIL-BIT IS DETECTED, THE EVENT IS PRESUMED TO BE THE RESULT OF THE
# GROUND HAVING SENT AN LMP COMMAND TO OPEN THE ISOLATION VALVE AND NO SUBSEQUENT FAILURE HAVING BEEN DETECTED BY
# THE DETECTION CIRCUITRY.  IN EITHER CASE, THIS FAILURE-MONITOR PROGRAM RESPONDS BY UPDATING ITS RECORD OF THE
# STATE OF THE ISOLATION VALVES, AND ALSO THE PAIR OF WORDS IT MAINTAINS FOR USE BY THE DAP IN THE JET-POLICY
# SELECTION LOGIC.

#          A FEW WORDS ABOUT LMP-RESET COMMANDS:  IN THE CYCLE IN WHICH A VALVE-CLOSURE COMMAND IS ISSUED, THE
# CORRESPONDING RESET COMMAND IS STORED IN THE REGISTER "JETRESET".  THIS REGISTER IS EXAMINED AT THE BEGINNING OF
# EACH RCSMONIT CYCLE, AND IF A COMMAND IS WAITING, IT IS SENT IMMEDIATELY.  THIS CAUSES RESET COMMANDS TO BE
# ISSUED AT ABOUT 960 MS AFTER THE SET COMMANDS.  THIS TECHNIQUE ASSURES THAT NO MORE THAN ONE UN-RESET SET-
# COMMAND IS ON AT ANY TIME (ALTHOUGH GROUND ACTIONS WILL BE SUPERIMPOSED ON THIS, HOWEVER).

# CALLING SEQUENCE:

#          TC     RCSMONIT        (IN INTERRUPT MODE, EVERY 960 MS.)
# EXIT:

#          TCF    RCSMONEX    (ALL PATHS EXIT VIA SUCH AN INSTRUCTION.  RCSMONEX IS PRESENTLY EQUATED TO RESUME.)

# ERASABLE INITIALIZATION REQUIRED:

#          VIA SLAP1:  JETRESET          = -0  (RESET-CMD BUFFER EMPTY)
#                      THISCH32          = +0  (NO FAILURES SENSED YET)
#                      CH5MASK, CH6MASK  = +0  (0'S IF JETS ARE OK)
#                      LMPJFAIL          = +0  (ISOLATION VALVES ALL OPEN)

# OUTPUT:

#          CH5MASK & CH6MASK UPDATED  (1'S WHERE JETS NOT TO BE USED)
#          THISCH32 SET TO INVERTED LOW 8 BITS OF CHAN 32 (HIGH 7 = 0)
#          LMPJFAIL UPDATED  (1'S WHEN ISOLATION COMMANDS HAVE BEEN SENT)
#          JETRESET CONTAINS RESET-COMMANDS TO BE SENT NEXT CYCLE THRU.

# DEBRIS:

#          A, L, Q, & RCSMONT1 - 4  (PRESENTLY EQUATED TO RUPTREG1 - 4)

# SUBROUTINES CALLED:

#          STORCOM  (PART OF 1LMP ROUTINE)

## Page 570
                BANK            12
                EBANK=          STATE                   # NO SWITCHED ERASABLE USED.

RCSMONIT        CCS             JETRESET                # CHECK WHETHER A RESET IS WAITING.
                TC              STORCOM         -1      # THERE IS A RESET TO SEND.  DO IT.
                CS              ZERO
                TS              JETRESET                # DEACTIVATE THE BUFFER.

AFTRESET        CS              ZERO
                EXTEND                                  # PICK UP & INVERT INVERTED CHANNEL 32.
                RXOR            32
                MASK            LOW8                    # KEEP JET-FAIL BITS ONLY.
                XCH             THISCH32
                TS              RCSMONT2                # HANG ON TO PREVIOUS CH32 STATE.

                MASK            THISCH32                #        -   --
                TS              L                       # FORM PTL + PTL.
                CS              LMPJFAIL                #   (  P = PREVIOUS CH 32 STATE,
                MASK            L                       #      T = THIS CH 32 STATE,
                TS              RCSMONT3                #      L = LMP ISOLATION VALVE CMD STATE )
                CS              RCSMONT2
                TS              L
                CS              THISCH32
                MASK            L
                MASK            LMPJFAIL
                ADS             RCSMONT3                # BITS HERE NZ IF ACTION IS DUE NOW.

                EXTEND
                BZF             RCSMONEX                # QUIT NOW IF NO ACTION REQUIRED.

                EXTEND
                DCA             RCSMONAD
                DTCB



                EBANK=          STATE                   # NO SWITCHED ERASABLE USED.
RCSMONAD        2CADR           RCSMON

## Page 571
                BANK            26

RCSMON          CA              RCSMONT3
                EXTEND
                MP              BIT7                    # MOVE BITS 8 - 1 OF A TO 14 - 7 OF L.
                XCH             L                       # ZERO TO L IN THE PROCESS.

 -3             INCR            L
                DOUBLE                                  # BOUND TO GET AN OVERFLOW, SINCE WE
                OVSK                                    # ASSURED INITIAL NZ IN A.
                TCF             -3

                CCS             L                       # PICK UP C(L)-1.
                DOUBLE
                TS              RCSMONT4                # STORE FOR LATER.

                INDEX           L
                CA              BIT8            -1
                TS              RCSMONT3                # SAVE THE RELEVANT BIT (8 - 1)
                MASK            LMPJFAIL
                CCS             A
                TCF             LMPBIT=1

                EXTEND                                  # LMPBIT = 0.
                INDEX           RCSMONT4
                DCA             KILLPAIR                # COMMAND TO ISOLATE A PAIR, & ITS RESET.
                LXCH            JETRESET                # PUT THE RESET COMMAND AWAY FOR NEXT TIME
                TC              STORCOM                 # SEND THE ISOLATION COMMAND.

                CA              RCSMONT3
                ADS             LMPJFAIL                # SET THE BIT SHOWING COMMAND SENT.

                CS              CH5MASK                 # SET THE JET-FAIL BITS IN CH5MASK &
                INDEX           RCSMONT4                # CH6MASK.
                MASK            FAILTABL
                ADS             CH5MASK

                CS              CH6MASK
                INDEX           RCSMONT4
                MASK            FAILTABL        +1
                ADS             CH6MASK

                TCF             RCSMONEX                # DONE.

## Page 572
LMPBIT=1        CS              RCSMONT3                # THE GROUND HAS RE-ENABLED A PAIR.
                MASK            LMPJFAIL                # DON'T USE ADS BECAUSE OF THE -0 CASE.
                TS              LMPJFAIL

                INDEX           RCSMONT4                # TURN OFF THE JET-FAIL BITS IN CH5MASK &
                CS              FAILTABL                # CH6MASK.
                MASK            CH5MASK
                TS              CH5MASK

                INDEX           RCSMONT4
                CS              FAILTABL        +1
                MASK            CH6MASK
                TS              CH6MASK
                TCF             RCSMONEX                # DONE.



RCSMONEX        EQUALS          RESUME                  # CHANGE THIS TO ATTACH SOMETHING ON.

## Page 573
#          IN THE UPPER WORD OF EACH ENTRY OF THE KILLPAIR TABLE IS THE LMP COMMAND CODE TO ISOLATE A JET-PAIR.
# BIT 15 = 1 TO ALLOW USE OF THE "STORCOM" LMP ROUTINE.  THE LOWER WORD OF EACH ENTRY CONTAINS THE RESET-COMMAND
# CODE PLUS ONE, WHICH CORRESPONDS TO THE UPPER WORD.  (THE EXTRA +1 IS REMOVED BY THE CCS AT RCSMONIT.)

KILLPAIR        2OCT            40250           00252   # 2A. JETS 10 & 11.  CMDS 168 & 169.
                2OCT            40170           00172   # 2B. JETS  9 & 12.  CMDS 120 & 121.
                2OCT            40134           00136   # 1A. JETS 13 & 15.  CMDS  92 &  93.
                2OCT            40154           00156   # 1B. JETS 14 & 16.  CMDS 108 & 109.
                2OCT            40156           00160   # 3B. JETS  6 &  7.  CMDS 110 & 111.
                2OCT            40310           00312   # 4B. JETS  1 &  3.  CMDS 200 & 201.
                2OCT            40136           00140   # 3A. JETS  5 &  8.  CMDS  94 &  95.
                2OCT            40350           00352   # 4A. JETS  2 &  4.  CMDS 232 & 233.

#          FAILTABL ENTRIES CONTAIN THE BIT FOR CH5MASK IN THE UPPER WORD, AND THE BIT FOR CH6MASK IN THE LOWER.

FAILTABL        2OCT            00040           00010
                2OCT            00020           00020
                2OCT            00100           00004
                2OCT            00200           00200
                2OCT            00010           00001
                2OCT            00001           00002
                2OCT            00004           00040
                2OCT            00002           00100
