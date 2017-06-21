### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
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
## Reference:   pp. 54-55
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-27 HG   Transcribed
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.


## Page 54
                SETLOC          4000

                INHINT                                  # GO
                CAF             GOBB
                XCH             BBANK
                TCF             GOPROG

                DXCH            ARUPT                   # T6RUPT
                EXTEND
                DCA             T6ADR
                DTCB

                DXCH            ARUPT                   # T5RUPT
                EXTEND
                DCA             T5ADR
                DTCB

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


## Page 55
                TCF             NOQRSM          +1      # WAS TCF RADAREAD (NO RADAR IN 206).

# TRAPS 31B AND 32 SHOULD NEVER BE SET. THEREFORE-
# RUPT 10 WILL ALWAYS REFER TO THE HAND CONTROLLER LPD OR MINIMUM IMPULSE
# USE. SEE GEORGE CHERRY FOR RATIONALE REGARDING THE AFORESAID.

                DXCH            ARUPT                   # RUPT10 USED FOR RHC MINIMP MODE ONLY.
                CAF             TWO
                TS              DELAYCTR
                TCF             NOQBRSM

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

                EBANK=          M11
T4RPTBB         BBCON           T4RUPTA
