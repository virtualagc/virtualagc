### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RCS_FAILURE_MONITOR.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-19 MAS  Created from Luminary 69.

## Sundance 302

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
