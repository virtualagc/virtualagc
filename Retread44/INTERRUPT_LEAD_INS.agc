### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     Part of the source code for Retread 44 (revision 0). It was
##              the very first program for the Block II AGC, created as an
##              extensive rewrite of the Block I program Sunrise.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 15-16
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Aurora 12 version.
##              2016-12-16 MAS  Transcribed.
## 		2016-12-26 RSB	Proofed comment text using octopus/ProoferComments,
##				but no errors found.

## Page 15
## The log section name, INTERRUPT LEAD INS, is circled in red.

                SETLOC          4000
                
                INHINT                                  # GO
                CAF             GOBB
                XCH             BBANK
                TCF             GOPROG
                
                DXCH            ARUPT                   # T6RUPT
                CAF             T6RPTBB
                XCH             BBANK
                TCF             RESUME      +3          # ***FIX LATER***

                DXCH            ARUPT                   # T5RUPT
                CAF             T5RPTBB
                XCH             BBANK
                TCF             RESUME      +3          # ***FIX LATER***
                
                DXCH            ARUPT                   # T3RUPT
                CAF             T3RPTBB
                XCH             BBANK
                TCF             T3RUPT
                
                DXCH            ARUPT                   # T4RUPT
                CAF             T4RPTBB
                XCH             BBANK
                TCF             T4RUPT

                DXCH            ARUPT                   # KEYRUPT1
                CAF             KEYRPTBB
                XCH             BBANK
                TCF             KEYRUPT1
                
                DXCH            ARUPT                   # KEYRUPT2
                CAF             KEYRPTBB
                XCH             BBANK
                TCF             KEYRUPT2
                
                DXCH            ARUPT                   # UPRUPT
                CAF             UPRPTBB
                XCH             BBANK
                TCF             UPRUPT
                
                DXCH            ARUPT                   # DOWNRUPT
                CAF             DWNRPTBB
                XCH             BBANK
                TCF             RESUME      +3          # ***FIX LATER***
                
                RESUME                                  # RADAR RUPT    ****FIX LATER******

                SETLOC          4050
## Page 16
                RESUME                                  # HAND CONTROL RUPT   ***FIX LATER****



                SETLOC          4054

                
                EBANK=          LST1                    # RESTART USES E0, E3
GOBB            BBCON           GOPROG

                EBANK=          TIME1
T6RPTBB         BBCON           RESUME                  # ***FIX LATER***

                EBANK=          TIME1
T5RPTBB         BBCON           RESUME                  # ***FIX LATER***

                EBANK=          LST1
T3RPTBB         BBCON           T3RUPT

                EBANK=          DSRUPTSW
T4RPTBB         BBCON           T4RUPT

                EBANK=          KEYTEMP1
KEYRPTBB        BBCON           KEYRUPT1

UPRPTBB         =               KEYRPTBB

                EBANK=          TIME1
DWNRPTBB        BBCON           RESUME                  # ***FIX LATER ***

ENDINTFF        EQUALS
