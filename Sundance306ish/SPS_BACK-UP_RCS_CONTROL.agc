### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SPS_BACK-UP_RCS_CONTROL.agc
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



# PROGRAM NAME:  SPSRCS

# AUTHOR:  EDGAR M. OSHIKA (AC ELECTRONICS)

# MODIFIED:  TO RETURN TO ALL AXES VIA Q BY P. S. WEISSMAN, OCT 7, 1968

# FUNCTIONAL DESCRIPTION:

# THIS PROGRAM CONTROLS THE FIRING OF ALL RCS JETS IN THE DOCKED CONFIGURATION ACCORDING TO THE FOLLOWING PHASE
# PLANE LOGIC.

# 1.  OUTER RATE LIMIT (SPSRCS)

# IF MAGNITUDE OF EDOT IS GREATER THAN 1.73 DEG/SEC SET JET FIRING TIME, TJ, TO REDUCE RATE AND THEN RETURN TO
# CALLING PROGRAM (REQUESTING 4 JETS FOR P-AXIS).
# OTHERWISE, CONTINUE.

# 2.  RATE DEAD BAND TEST ( JTONTEST)

# IF JETS ARE FIRING NEGATIVE AND RATE IS GREATER THAN -0.101 DEG/SEC, LEAVE JETS ON AND RETURN,
# IF JETS ARE FIRING POSITIVE AND RATE IS LESS THAN +0.101 DEG/SEC, LEAVE JETS ON AND RETURN, OTHERWISE CONTINUE.

# 3.  COASTING TEST (SPSSTART)

# IF STATE (E,EDOT) IS BELOW LINE  E + 4 X EDOT > -1.4 DEG  AND EDOT IS LESS THAN 1.30 DEG/SEC SET JET TIME POSI-
# TIVE AND RETURN,
# IF STATE IS ABOVE LINE E + 4 X EDOT > +1.4 DEG AND EDOT IS GREATER THAN -1.30 DEG/SEC, SET JET TIME NEGATIVE
# AND RETURN,
# OTHERWISE, SET JET TIME ZERO AND RETURN.

# THE MINIMUM PULSE WIDTH OF THIS CONTROLLER IS DETERMINED BY THE REPETITION  RATE AT WHICH THIS ROUTINE IS CALLED
# AND IS NOMINALLY 100 MS FOR ALL AXES IN DRIFTING FLIGHT.   DURING POWERED FLIGHT THE MINIMUM IS 100 MS FOR THE
# P AXIS AND 200 MS FOR THE CONTROL OF THE U AND V AXES.

# CALLING SEQUENCE:

#          TC     SPSRCS          FROM Q,R AXES RCS AUTOPILOT
#                     INHINT                  FROM P-AXIS RCS AUTOPILOT
#                     TC      IBNKCALL
#                     CADR    SPSRCS


# EXIT:

#          TC     Q
# ALARM/ABORT MODE:    NONE

# SUBROUTINES CALLED:    NONE

# INPUT:      E, EDOT

#            TJP, TJV, TJU           TJ MUST NOT BE NEGATIVE ZERO

# OUTPUT:    TJP, TJV, TJU
#            NUMBERT = 6,            WHEN RATE LIMITING P AXIS.


                BANK            17
                SETLOC          DAPS2
                BANK

                COUNT*          $$/DAPBU

                EBANK=          TJU
SPSRCS          CA              EDOT
                EXTEND
                MP              RATELIM1                # OUTER RATE LIMIT = 1.73 DEG/SEC
                EXTEND
                BZF             JTONTEST

                TS              L
                CA              SIX
                TS              NUMBERT
                CCS             L
                TCF             NEGTHRST
                TC              CCSHOLE                 # **TEMP ** FILL WITH A CONSTANT
RATELIM2        =               .1AT4                   # = OCT 00632,  1.125 DEG/SEC
POSTHRST        CA              HALF

                NDX             AXISCTR
                TS              TJU
                CCS             AXISCTR
                TCF             +3
                TCF             +2
                TC              Q

                CA              FLAGWRD5
                MASK            SNUFFBIT
                EXTEND
                BZF             AFTERTJ -2
                CA              DAPBOOLS
                MASK            DRIFTBIT
                CCS             A
                TCF             AFTERTJ -2

                NDX             AXISCTR
                TS              TJU
                TCF             AFTERTJ -2

JTONTEST        NDX             AXISCTR
                CCS             TJU
                TCF             +4
                TCF             SPSSTART
                CA              EDOT
                TCF             +2

 +4             CS              EDOT
                LXCH            A
                CS              DAPBOOLS                # IF DRIFTBIT = 1, USE ZERO TARGET RATE
                MASK            DRIFTBIT                # IF DRIFTBIT = 0, USE 0.10 RATE TARGET
                CCS             A
                CA              RATEDB1
                AD              L
                EXTEND
                BZMF            +2
                TCF             POSTHRST        +3

SPSSTART        CA              EDOT
                AD              E
                EXTEND
                MP              DKDB                    # PAD LOADED DEADBAND. FRESHSTART: 1.4 DEG
                EXTEND
                BZF             TJZERO

                EXTEND
                BZMF            +7
                CA              EDOT
                AD              RATELIM2
                EXTEND
                BZMF            TJZERO
NEGTHRST        CS              HALF
                TCF             POSTHRST        +1
 +7             CS              RATELIM2
                AD              EDOT
                EXTEND
                BZMF            POSTHRST
TJZERO          CA              ZERO
                TCF             POSTHRST        +1


RATELIM1        =               CALLCODE                # = 00032, CORRESPONDING TO 1.73 DEG/SEC
RATEDB1         =               TBUILDFX                #  = 00045, CORRESPONDS TO 0.101 DEG/SEC
