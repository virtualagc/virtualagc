### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    STAGE_MONITOR.agc
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



                BANK    06
                SETLOC  STGMONT
                BANK

STAGEMON        CAF     BIT2
                EXTEND
                RAND    CHAN30
                EXTEND
                BZF     RESUME

                CS      FLAGWRD1
                MASK    APSFLBIT
                EXTEND
                BZF     RESUME
                ADS     FLAGWRD1

                CAF     PRIO27
                TC      NOVAC
                EBANK=  AOSQ
                2CADR   1/ACCJOB

                TCF     RESUME
