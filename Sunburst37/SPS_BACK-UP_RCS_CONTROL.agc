### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SPS_BACK-UP_RCS_CONTROL.agc
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
## Reference:   pp. 591-594
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-03 HG   Transribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 591
                BANK            21
                EBANK=          DT

SPSRCS          CS              OMEGAQD
                AD              OMEGAQ
                TS              EDOTQ                   #  EDOT = OMEGAQ - OMEGAQD

                CAF             SLOPEMQ
                EXTEND
                MP              ER
                AD              EDOTQ
                EXTEND                                  # F = SLOPE M * E + EDOT
                BZMF            PLUSD                   # DQ NEGATIVE FOR POSITIVE F

                CAF             NEGD                    # STORE DIRECTION TO THRUST IN ITEMP3

GCOMPUTE        TS              ITEMP3
                CAE             EDOTQ
                EXTEND

                SQUARE
                EXTEND
                MP              1/2AQ
                TS              ITEMP2                  # ITEMP2 = (1/2A) EDOT**2

                AD              ER
                AD              NEGD                    # DB IS SPECIFIED BY NEGD IN SPS MODE

                EXTEND
                BZMF            UZERO

                CAE             EDOTQ                   # G WAS POSITIVE, NOW TEST EDOT

                EXTEND
                BZMF            ULOW

                AD              ITEMP2                  # EDOT WAS POSITIVE, CALCULATE HIGH U CASE
                EXTEND
                MP              SLOPEMQ
                AD              ER
                EXTEND
                MP              1/AQ
                TS              URGENCYQ

                TCF             RCALC

ULOW            EXTEND
                MP              SLOPEMQ
                AD              ER                      # EDOT WAS NEGATIVE, CALCULATE LOW U CASE
                EXTEND
                MP              1/AQ

## Page 592
                TS              URGENCYQ

                TCF             RCALC

PLUSD           CS              ER
                XCH             ER
                CS              EDOTQ
                XCH             EDOTQ
                CS              NEGD
                TCF             GCOMPUTE

UZERO           CAF             ZERO                    # G = 0, NO URGENCY
                TS              URGENCYQ

RCALC           CS              OMEGARD                 # REPEAT CALCULATIONS FOR R-AXIS
                AD              OMEGAR
                TS              EDOTR

                CAF             SLOPEMR
                EXTEND
                MP              E
                AD              EDOTR
                EXTEND
                BZMF            PLUSDR

                CAF             NEGD

GCOMPUTR        TS              ITEMP4
                CAE             EDOTR
                EXTEND
                SQUARE
                EXTEND
                MP              1/2AR
                TS              ITEMP2

                AD              E
                AD              NEGD

                EXTEND
                BZMF            UZEROR

                CAE             EDOTR

                EXTEND
                BZMF            ULOWR

                AD              ITEMP2                  # EDOT WAS POSITIVE, CALCULATE HIGH U CASE
                EXTEND
                MP              SLOPEMR
                AD              E

## Page 593
                EXTEND
                MP              1/AR
                TS              URGENCYR

                TCF             CHNLTEST

ULOWR           EXTEND                                  # EODT WAS NEGATIVE, CALCULATE LOW U CASE
                MP              SLOPEMR

                AD              E
                EXTEND
                MP              1/AR
                TS              URGENCYR

                TCF             CHNLTEST

PLUSDR          CS              E
                XCH             E
                CS              EDOTR
                XCH             EDOTR
                CS              NEGD
                TCF             GCOMPUTR

UZEROR          CAF             ZERO
CHNLTEST        EXTEND
                SU              URGENCYQ                # TEST = URGENCYR - URGENCYQ
                CCS             A
                TCF             DRTEST
                TCF             URTEST
                TCF             DQTEST
URTEST          CAE             URGENCYQ
                EXTEND

                BZF             NOJET
                TCF             DRTEST

DQTEST          CAE             ITEMP3
                EXTEND
                BZMF            NEGQ
                CAF             POSQ
                TCF             JETCMD

NEGQ            CAF             NEGQT
                TCF             JETCMD

DRTEST          CAE             ITEMP4
                EXTEND
                BZMF            NEGR
                CAF             POSR
                TCF             JETCMD

NEGR            CAF             NEGRT

## Page 594
                TCF             JETCMD

NOJET           CAF             ZERO
JETCMD          EXTEND
                WRITE           5
                TCF             RESUME


SLOPEMQ         OCT             37777
SLOPEMR         OCT             37777
1/2AR           DEC             0.2170
1/2AQ           DEC             0.217
1/AQ            DEC             0.434

1/AR            DEC             0.434			# DESCENT STAGE ACC CONST SCALED AT 16/PI
NEGQT           OCT             00011
POSQ            OCT             00006
POSR            OCT             00201
NEGRT           OCT             00102
NEGD            DEC             -0.00555
