### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-22 MAS  Created from Aurora 12.
##              2023-06-30 MAS  Updated for Sundial E.

                SETLOC  4000

                INHINT                  # GO
                CAF     GOBB
                XCH     BBANK
                TCF     GOPROG

                DXCH    ARUPT           # T6RUPT
                CAF     T6RPTBB
                XCH     BBANK
                TCF     RESUME +3       # ***FIX LATER***

                DXCH    ARUPT           # T5RUPT
                EXTEND
                DCA     T5LOC           # T5LOC EQUALS T5ADR
                DTCB

                DXCH    ARUPT           # T3RUPT
                CAF     T3RPTBB
                XCH     BBANK
                TCF     T3RUPT

                DXCH    ARUPT           # T4RUPT
                CAF     ZERO
                TCF     T4RUPT
                EBANK=  DSRUPTSW
T4RPTBB         BBCON   T4RUPTA

                DXCH    ARUPT           # KEYRUPT1
                CAF     KEYRPTBB
                XCH     BBANK
                TCF     KEYRUPT1

                DXCH    ARUPT           # KEYRUPT2
                CAF     MKRUPTBB
                XCH     BBANK
                TCF     MARKRUPT

                DXCH    ARUPT           # UPRUPT
                CAF     UPRPTBB
                XCH     BBANK
                TCF     UPRUPT

                DXCH    ARUPT           # DOWNRUPT
                CAF     DWNRPTBB
                XCH     BBANK
                TCF     DODOWNTM

                DXCH    ARUPT           # RADAR RUPT
                CAF     RDRPTBB
                XCH     BBANK
                TCF     RESUME +3       # NOT USED

                DXCH    ARUPT           # HAND CONTROL RUPT
                CA      HCRUPTBB
                XCH     BBANK
                TCF     RESUME +3       # NOT USED

                EBANK=  LST1            # RESTART USES E0, E3
GOBB            BBCON   GOPROG

                EBANK=  TIME1
T6RPTBB         BBCON   RESUME          # ***FIX LATER***

                EBANK=  LST1
T3RPTBB         BBCON   T3RUPT

                EBANK=  KEYTEMP1
KEYRPTBB        BBCON   KEYRUPT1

                EBANK=  MARKSTAT
MKRUPTBB        BBCON   MARKRUPT

UPRPTBB         =       KEYRPTBB

                EBANK=  DNTMBUFF
DWNRPTBB        BBCON   DODOWNTM

                EBANK=  TIME1
RDRPTBB         BBCON   RESUME          # NOT USED

                EBANK=  TIME1
HCRUPTBB        BBCON   RESUME          # NOT USED

ENDINTFF        EQUALS
