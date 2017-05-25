### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     T6-RUPT_PROGRAMS.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-21 HG   Transcribed
##		 2016-12-05 RSB	 Comment-proofing with octopus/ProoferComments
##				 completed, changes made.

## Page 483
# PROGRAM NAMES: (1) DOT6RUPT     MOD. NO. 4  DATE: FEBRUARY 9. 1967

#                (2) T6JOBCHK

# MODIFICATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# THESE PROGRAMS ENABLE THE LM DAP TO CONTROL THE THRUST TIMES OF THE REACTION CONTROL SYSTEM JETS BY USING TIME6.
# SINCE THE LM DAP MAINTAINS EXCLUSIVE CONTROL OVER TIME6 AND ITS INTERRUPTS, THE FOLLOWING CONVENTIONS HAVE BEEN
# ESTABLISHED AND MUST NOT BE TAMPERED WITH:
#          1. NO NUMBER IS EVER PLACED INTO TIME6 EXCEPT BY LM DAP.
#          2. NO PROGRAM OTHER THAN LM DAP ENABLES THE TIME6 COUNTER.
#          3. ONLY POSITIVE NUMBERS ARE ENTERED INTO TIME6, SO IT COUNTS DOWN TO -0 (MINUS ZERO) TO INTERRUPT.
#          4. IF -0 IS NOT IN TIME6 WHEN THE INTERRUPT OCCURS, THEN THE INTERRUPT HAS ALREADY BEEN PROCESSED.
#          5. ALL PROGRAMS WHICH OPERATE IN EITHER INTERRUPT MODE OR WITH INTERRUPT INHIBITED MUST CALL T6JOBCHK
#             EVERY 6 MILLISECONDS TO PROCESS A POSSIBLE WAITING T6RUPT BEFORE IT CAN BE HONORED BY THE HARDWARE.

# DOT6RUPT CALLING SEQUENCE:

# REF   1                 4004  52 011 0           DXCH   ARUPT           T6RUPT
#                         4005  0 0006 1           EXTEND
# REF   1                 4006  3 5045 0           DCA    T6ADR
#                         4007  52 006 0           DTCB

# T6JOBCHK CALLING SEQUENCE:

# REF   0              23,1000  0 4200 1           TC     T6JOBCHK

# SUBROUTINES CALLED:   DOT6RUPT CALLS T6JOBCHK.

# NORMAL EXIT MODES:    DOT6RUPT TRANSFERS CONTROL TO RESUME.
#                       T6JOBCHK TRANSFERS CONTROL TO CALLER AT LOCATION AFTER CALL.

# ALARM/ABORT MODES:    NONE.

# INPUT: TIME6,T6NEXT REGS,T6NEXTJT REGS.

# OUTPUT: (SAME AS INPUT.)

# DEBRIS: DOT6RUPT: NONE.  T6JOBCHK: A,L
# *** NOTE: AS OF MOD. NO. 2, T6NEXT AND T6NEXTJT LISTS ARE IN UNSWITCHED ERASABLE. ***

## Page 484

                BLOCK           02
                EBANK=          T6NEXT

                EBANK=          T6NEXT
T6ADR           2CADR           DOT6RUPT                # 2CADR OF INTERRUPT PROCESSOR.

                BANK            16
                EBANK=          T6NEXT

DOT6RUPT        LXCH            BANKRUPT                # (INTERRUPT LEAD IN CONTINUED)
                EXTEND
                QXCH            QRUPT

                TC              T6JOBCHK                # CALL T6JOBCHK

                TCF             RESUME                  # END TIME6 RUPT



                BLOCK           03
                EBANK=          T6NEXT

T6JOBCHK        CCS             TIME6                   # CHECK TIME6 FOR WAITING T6RUPT:
                TC              Q                       # NONE: CLOCK COUTING DOWN.
                TC              Q                       # NONE: T6RUPT ALREADY PROCESSED.
                TC              Q                       # NONE: INVALID VALUE. (POSSIBLE ABORT.)

# CONTROL PASSES TO T6JOB ONLY WHEN C(TIME6) = -0 (I.E. WHEN A T6RUPT MUST BE PROCESSED).

T6JOB           CAF             POSMAX                  # DISABLE CLOCK: NEEDED SINCE RUPT OCCURS
                EXTEND                                  # 1 DINC AFTER T6 = 77777.  FOR 625 MUSECS
                WAND            13                      # MUST NOT HAVE T6 = +0 WITH ENABLE SET.

                CAF             ZERO                    # UPDATE ORDERED LIST OF T6NEXT REGISTERS
                XCH             T6NEXT          +1      # 1) PUSH FIRST ENTRY INTO TIME6.
                XCH             T6NEXT                  # 2) PUSH SECOND ENTRY INTO FIRST PLACE.
                TS              TIME6                   # 3) ZERO LAST (SECOND) DT IN LIST.

                CCS             TIME6                   # TIME6 EITHER POSITIVE OR PLUS ZERO:
                TCF             T6NZERO                 # (BRANCH IF TIME6 STILL ACTIVE.)

                CAE             T6NEXTJT                # THESE ARE TRANSLATION JETS (NO DT),
                TCF             WRITEJTS                # DETERMINE CHANNEL AND WRITE.

T6NZERO         CAF             BIT15                   # ENABLE TIME6 COUNTER TO START TIMING
                EXTEND                                  # THIS JET FIRING (PROPER JETS NOT YET
                WOR             13                      # WRITTEN INTO CHANNEL, BUT WILL BE SOON).

                CAF             ZERO                    # UPDATE ORDERED LIST OF JET POLICIES:
                XCH             T6NEXTJT        +2      # 1) LEAVE JETS TO GO ON NOW IN A.

## Page 485
                XCH             T6NEXTJT        +1      # 2) CYCLE LIST UP TOWARD TOP.
                XCH             T6NEXTJT                # 3) ZERO LAST ENTRY IN LIST.

## Page 486
# THE FOLLOWING JET-ON LOGIC MAY BE USED AS A SUBROUTINE (3 ENTRY POINTS):

# FIRST, LET SGN(A) DETERMINE THE JET CHANNEL:
#          POSITIVE IMPLIES P-AXIS POLICY.
#          NEGATIVE IMPLIES Q,R-AXES POLICY.

WRITEJTS        EXTEND                                  # TEST FOR CHANNEL TO WRITE POLICY IN:
                BZMF            WRITEQR                 # NEG: Q,R-AXES JETS IN CHANNEL 5

# SECOND, FOR P-AXIS JET POLICIES:

WRITEP          EXTEND                                  # POS: P-AXIS   JETS IN CHANNEL 6
                WRITE           6
                TC              Q                       # RETURN.

# THIRD, FOR Q,R-AXES JET POLICIES:

WRITEQR         EXTEND                                  # Q,R-AXES JETS IN CHANNEL 5
                WRITE           5
                TC              Q                       # RETURN.
