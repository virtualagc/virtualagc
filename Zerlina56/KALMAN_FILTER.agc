### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KALMAN_FILTER.agc
## Purpose:     A log section of Zerlina 56, the final revision of
##              Don Eyles's offline development program for the variable 
##              guidance period servicer. It also includes a new P66 with LPD 
##              (Landing Point Designator) capability, based on an idea of John 
##              Young's. Neither of these advanced features were actually flown,
##              but Zerlina was also the birthplace of other big improvements to
##              Luminary including the terrain model and new (Luminary 1E)
##              analog display programs. Zerlina was branched off of Luminary 145,
##              and revision 56 includes all changes up to and including Luminary
##              183. It is therefore quite close to the Apollo 14 program,
##              Luminary 178, where not modified with new features.
## Reference:   pp. 1458-1459
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##		2017-08-29 RSB	Transcribed.

## Page 1458
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
                ADS                     DOWNTORK        #   NOTE: NOT INITIALIZED; OVERFLOWS.

                CCS                     DAPTEMP6
                TCF                     RATELOOP +1
                TCF                     ROTORQUE
SMALLTJU        CA                      ZERO
                INDEX                   DAPTEMP6
                XCH                     TJP
                EXTEND
## Page 1459
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

