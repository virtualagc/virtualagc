### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KALMAN_FILTER.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 1468 - 1469
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-23 AS   Transcribed
##		2016-12-26 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.

## Page 1468
                EBANK=                  NO.UJETS
                BANK                    16
                SETLOC	                DAPS1
                BANK

                COUNT*	                $$/DAP

RATELOOP        CA                      TWO
                TS                      DAPTEMP6
                DOUBLE
                TS                      Q
                INDEX                   DAPTEMP6
                CCS                     TJP
                TCF                     +2
                TCF                     LOOPRATE
                AD                      -100MST6
                EXTEND
                BZMF                    SMALLTJU
                INDEX                   DAPTEMP6
                CCS                     TJP
                CA                      -100MST6
                TCF                     +2
                CS                      -100MST6
                INDEX                   DAPTEMP6
                ADS                     TJP
                INDEX                   DAPTEMP6
                CCS                     TJP
                CS                      -100MS		# 0.1 AT 1
                TCF                     +2
                CA                      -100MS
LOOPRATE	EXTEND
		INDEX                   DAPTEMP6
		MP                      NO.PJETS
		CA                      L
		INDEX                   DAPTEMP6
                TS                      DAPTEMP1        # SIGNED TORQUE AT 1 JET-SEC FOR FILTER
		EXTEND
                MP                      BIT10           # RESCALE TO 32; ONE BIT ABOUT 2 JET-MSEC
		EXTEND
                BZMF                    NEGTORK
STORTORK        INDEX                   Q               # INCREMENT DOWNLIST REGISTER.
                ADS                     DOWNTORK        #  NOTE:  NOT INITIALIZED; OVERFLOWS.

                CCS                     DAPTEMP6
                TCF                     RATELOOP +1
                TCF                     ROTORQUE
SMALLTJU        CA                      ZERO
                INDEX                   DAPTEMP6
                XCH                     TJP
                EXTEND
## Page 1469
                MP                      ELEVEN          # 10.24 PLUS
                CA                      L
                TCF                     LOOPRATE
ROTORQUE        CA                      DAPTEMP2
                AD                      DAPTEMP3
                EXTEND
                MP                      1JACCR
                TS                      JETRATER
                CS                      DAPTEMP3
                AD                      DAPTEMP2
                EXTEND
                MP                      1JACCQ
                TS                      JETRATEQ
                TCF                     BACKP
-100MST6        DEC                     -160

NEGTORK         COM
                INCR                    Q
                TCF                     STORTORK

