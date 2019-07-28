### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     Part of the source code for AGC program Retread 50. 
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/Restoration.html
## Mod history: 2019-06-12 MAS  Recreated from Computer History Museum's
##				physical core-rope modules.

## Page 15

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
