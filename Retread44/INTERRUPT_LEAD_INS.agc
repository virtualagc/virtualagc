### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     INTERRUPT_LEAD_INS.agc
## Purpose:      Part of the source code for Retread 44 (revision 0). It was
##               the very first program for the Block II AGC, created as an
##               extensive rewrite of the Block I program Sunrise.
##               This file is intended to be a faithful transcription, except
##               that the code format has been changed to conform to the
##               requirements of the yaYUL assembler rather than the
##               original YUL assembler.
## Reference:    pp. 15-16
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-12-13 MAS  Created from Aurora 12 version.

## NOTE: Page numbers below have not yet been updated to reflect Retread 44.

## Page 27
                SETLOC          4000
                
                INHINT                                  # GO
                CAF             GOBB
                XCH             BBANK
                TCF             GOPROG
                
                DXCH            ARUPT                   # HERE ON A T6RUPT
                EXTEND
                QXCH            QRUPT
                TCF             DOT6RUPT                # DOT6RUPT IS IN FIX-FIXED.(INTR-BANK COM)
                
                DXCH            ARUPT                   # T5RUPT
                EXTEND
                DCA             T5LOC                   # T5LOC EQUALS T5ADR
                DTCB
                
                DXCH            ARUPT                   # T3RUPT
                CAF             T3RPTBB
                XCH             BBANK
                TCF             T3RUPT
                
                DXCH            ARUPT                   # T4RUPT
                CAF             ZERO
                TCF             T4RUPT
                EBANK=          M11
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
## Page 28
                XCH             BBANK
                TCF             RADAREAD
                
# TRAPS 31B AND 32 SHOULD NEVER BE SET. THEREFORE-
# RUPT 10 WILL ALWAYS REFER TO THE HAND CONTROLLER LPD OR MINIMUM IMPULSE
# USE. SEE GEORGE CHERRY FOR RATIONALE REGARDING THE AFORESAID.

                DXCH            ARUPT                   # RUPT 10 USED FOR RHC MINIMP MODE ONLY.
                CAF             TWO
                TS              DELAYCTR
                TCF             NOQRSM
                
                EBANK=          LST1                    # RESTART USES E0, E3
GOBB            BBCON           GOPROG

                EBANK=          TIME1
T6RPTBB         BBCON           RESUME                  # ***FIX LATER***

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

ENDINTFF        EQUALS
