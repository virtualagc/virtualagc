### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-20 MAS  Created from Aurora 12 (with much DAP stuff removed).
##              2017-01-15 MAS  Added TIME5 and TIME6 interrupts, and tweaked TIME4's
##                              leadin a bit.

                SETLOC          4000
                
                INHINT                                  # GO
                CAF             GOBB
                XCH             BBANK
                TCF             GOPROG
                
                DXCH            ARUPT                   # T6RUPT
                CAF             T6RPTBB
                XCH             BBANK
                TCF             T6RUPT
                
                DXCH            ARUPT                   # T5RUPT
                CAF             T5RPTBB
                XCH             BBANK
                TCF             T5RUPT
                
                DXCH            ARUPT                   # T3RUPT
                CAF             T3RPTBB
                XCH             BBANK
                TCF             T3RUPT
                
                DXCH            ARUPT                   # T4RUPT
                CAF             FOUR
                TCF             T4RUPT
T4RPTBB         BBCON           T4RUPTA

                DXCH            ARUPT                   # KEYRUPT1
                CAF             KEYRPTBB
                XCH             BBANK
                TCF             KEYRUPT1
                
                DXCH            ARUPT                   # KEYRUPT2
                CAF             MKRUPTBB
                XCH             BBANK
                TCF             MARKRUPT
                
                DXCH            ARUPT                   # UPRUPT
                CAF             UPRPTBB
                XCH             BBANK
                TCF             UPRUPT
                
                DXCH            ARUPT                   # DOWNRUPT
                CAF             DWNRPTBB
                XCH             BBANK
                TCF             DODOWNTM
                
                DXCH            ARUPT                   # RADAR RUPT
                CAF             RDRPTBB
                XCH             BBANK
                TCF             RADAREAD
                
# TRAPS 31B AND 32 SHOULD NEVER BE SET. THEREFORE-
# RUPT 10 WILL ALWAYS REFER TO THE HAND CONTROLLER LPD OR MINIMUM IMPULSE
# USE. SEE GEORGE CHERRY FOR RATIONALE REGARDING THE AFORESAID.

                DXCH            ARUPT                   # RUPT10
                CAF             RPT10BB
                XCH             BBANK
                TCF             RESUME      +3          # ***FIX LATER***
                
                EBANK=          LST1                    # RESTART USES E0, E3
GOBB            BBCON           GOPROG

                EBANK=          TIME1
T5RPTBB         BBCON           T5RUPT

                EBANK=          TIME1
T6RPTBB         BBCON           T6RUPT

                EBANK=          LST1
T3RPTBB         BBCON           T3RUPT

                EBANK=          KEYTEMP1
KEYRPTBB        BBCON           KEYRUPT1

                EBANK=          AOTAZ
MKRUPTBB        BBCON           MARKRUPT

UPRPTBB         =               KEYRPTBB

                EBANK=          DNTMBUFF
DWNRPTBB        BBCON           DODOWNTM

                EBANK=          RADMODES
RDRPTBB         BBCON           RADAREAD

                EBANK=          LST1
RPT10BB         BBCON           RESUME

ENDINTFF        EQUALS
