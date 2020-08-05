### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ALARM_AND_ABORT.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



#          THE FOLLOWING SUBROUTINE MAY BE CALLED TO DISPLAY A NON-ABORTIVE ALARM CONDITION. IT MAY BE CALLED
# EITHER IN INTERRUPT OR UNDER EXECUTIVE CONTROL.
#
# CALLING SEQUENCE IS AS FOLLOWS:
#               TC      ALARM
#               OCT     AAANN           ALARM NO. NN IN GENERAL AREA AAA.
#                                       (RETURNS HERE)

                BLOCK   02
                SETLOC  FFTAG7
                BANK

                EBANK=  FAILREG

                COUNT*  $$/ALARM
# ALARM TURNS ON THE PROGRAM ALARM LIGHT, BUT DOES NOT DISPLAY.

ALARM           INHINT

                CA      Q
                TS      ALMCADR
ALARM2          INDEX   Q
                CA      0
BORTENT         TS      L

PRIOENT         CA      BBANK
 +1             EXTEND
                ROR     SUPERBNK        # ADD SUPER BITS.
                TS      ALMCADR +1

LARMENT         CA      Q               # STORE RETURN FOR ALARM
                TS      ITEMP1

CHKFAIL1        CCS     FAILREG         # IS ANYTHING IN FAILREG
                TCF     CHKFAIL2        # YES TRY NEXT REG
                LXCH    FAILREG
                TCF     PROGLARM        # TURN ALARM LIGHT ON FOR FIRST ALARM

CHKFAIL2        CCS     FAILREG +1
                TCF     FAIL3
                LXCH    FAILREG +1
                TCF     MULTEXIT

FAIL3           CA      FAILREG +2
                MASK    POSMAX
                CCS     A
                TCF     MULTFAIL
                LXCH    FAILREG +2
                TCF     MULTEXIT


PROGLARM        CS      DSPTAB +11D
                MASK    OCT40400
                ADS     DSPTAB +11D

MULTEXIT        XCH     ITEMP1          # OBTAIN RETURN ADDRESS IN A
                RELINT
                INDEX   A
                TC      1

MULTFAIL        CA      L
                AD      BIT15
                TS      FAILREG +2

                TCF     MULTEXIT


# PRIOLARM DISPLAYS V05N09 VIA PRIODSPR WITH 3 RETURNS TO THE USER FROM THE ASTRONAUT AT CALL LOC +1,+2,+3 AND
# AN IMMEDIATE RETURN TO THE USER AT CALL LOC +4.  EXAMPLE FOLLOWS,
#               CAF     OCTXX           ALARM CODE
#               TC      BANKCALL
#               CADR    PRIOLARM
#
#               ...     ...
#               ...     ...
#               ...     ...             ASTRONAUT RETURN
#               TC      PHASCHNG        IMMEDIATE RETURN TO USER.  RESTART
#               OCT     X.1             PHASE CHANGE FOR PRIO DISPLAY

                BANK    10
                SETLOC  DISPLAYS
                BANK

                COUNT*  $$/DSPLA
PRIOLARM        INHINT                  # * * * KEEP IN DISPLAY ROUTINES BANK
                TS      L               # SAVE ALARM CODE

                CA      BUF2            # 2 CADR OF PRIOLARM USER
                TS      ALMCADR
                CA      BUF2 +1
                TC      PRIOENT +1      # * LEAVE L ALONE
-5SEC           DEC     -500            # *** DONT MOVE
                CAF     V05N09
                TCF     PRIODSPR


                BLOCK   02
                SETLOC  FFTAG7
                BANK

                COUNT*  $$/ALARM
ABORT           INHINT
                CA      Q
                TS      ALMCADR

ABORT2          INDEX   Q
                CAF     0
                TC      BORTENT
OCT40400        OCT     40400
WHIMPER         TC      WHIMPER

CCSHOLE         INHINT
                CA      Q
                TS      ALMCADR

                TC      ABORT2
                OCT     1103

CURTAINS        INHINT
                CA      Q
                TS      ALMCADR
                TC      ALARM2
OCT217          OCT     00217
                TC      ALMCADR         # RETURN TO USER

# CALLING SEQUENCE FOR VARALARM
#               CAF     (ALARM)
#               TC      VARALARM
#
# VARALARM TURNS ON PROGRAM ALARM LIGHT BUT DOES NOT DISPLAY

VARALARM        INHINT

                TS      L               # SAVE USERS ALARM CODE

                CA      Q               # SAVE USERS Q
                TS      ALMCADR

                TC      PRIOENT
OCT14           OCT     14              # DONT MOVE

                TC      ALMCADR         # RETURN TO USER
