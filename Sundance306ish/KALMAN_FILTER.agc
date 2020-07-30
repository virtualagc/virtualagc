### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KALMAN_FILTER.agc
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



                EBANK=  NO.UJETS
                BANK    16
                SETLOC  DAPS1
                BANK

                COUNT*  $$/DAP

RATELOOP        CA      TWO
                TS      DAPTEMP6
                INDEX   DAPTEMP6
                CCS     TJP
                TCF     +2
                TCF     LOOPRATE
                AD      -100MST6
                EXTEND
                BZMF    SMALLTJU
                INDEX   DAPTEMP6
                CCS     TJP
                CA      -100MST6
                TCF     +2
                CS      -100MST6
                INDEX   DAPTEMP6
                ADS     TJP
                INDEX   DAPTEMP6
                CCS     TJP
                CS      -100MS          # 0.1 AT 1
                TCF     +2
                CA      -100MS
LOOPRATE        EXTEND
                INDEX   DAPTEMP6
                MP      NO.PJETS
                INDEX   DAPTEMP6
                LXCH    DAPTEMP1        # SIGNED TORQUE AT 1 JET-SEC FOR FILTER
                CCS     DAPTEMP6
                TCF     RATELOOP +1
                TCF     ROTORQUE
SMALLTJU        CA      ZERO
                INDEX   DAPTEMP6
                XCH     TJP
                EXTEND
                MP      TEN
                CA      L
                TCF     LOOPRATE
ROTORQUE        CA      DAPTEMP2
                AD      DAPTEMP3
                EXTEND
                MP      1JACCR
                TS      JETRATER
                CS      DAPTEMP3
                AD      DAPTEMP2
                EXTEND
                MP      1JACCQ
                TS      JETRATEQ
                TCF     BACKP
-100MST6        DEC     -160

