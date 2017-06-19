### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.yul
## Purpose:     A module for revision 0 of BURST120 (Sunburst).
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##                              I've also corrected this against the Sunburst120
##                              scans, so modulo any errors of mine, should be
##                              ready to go.
##              2016-11-03 RSB  Some SBANK= workarounds.
##              2016-11-11 RSB  Converted to .yul format.
##		2017-06-17 MAS	Globally removed all SBANK= workarounds.

## Page 60
 000001          SETLOC 4000 
 000003         
 000004          INHINT                 GO
 000005          CAF    GOBB
 000006          XCH    BBANK
 000007          TCF    GOPROG
 000008 
 000009          DXCH   ARUPT           T6RUPT
 000010          EXTEND
 000011          DCA    T6ADR
 000012          DTCB
 000013         
 000014          DXCH   ARUPT           T5RUPT
 000015          EXTEND
 000016          DCA    T5ADR
 000017          DTCB
 000018
 000019          DXCH   ARUPT           T3RUPT
 000020          CAF    T3RPTBB
 000021          XCH    BBANK
 000022          TCF    T3RUPT
 000023
 000024          DXCH   ARUPT           T4RUPT
 000025          CAF    T4RPTBB
 000026          XCH    BBANK
 000027          TCF    T4RUPT
 000028 
 000029          DXCH   ARUPT           KEYRUPT1
 000030          CAF    KEYRPTBB
 000031          XCH    BBANK
 000032          TCF    KEYRUPT1
 000033 
 000034          DXCH   ARUPT           KEYRUPT2
 000035          CAF    MKRUPTBB
 000036          XCH    BBANK
 000037          TCF    MARKRUPT
 000038         
 000039          DXCH   ARUPT           UPRUPT
 000040          CAF    UPRPTBB
 000041          XCH    BBANK
 000042          TCF    UPRUPT
 000043         
 000044          DXCH   ARUPT           DOWNRUPT
 000045          CAF    DWNRPTBB
 000046          XCH    BBANK
 000047          TCF    DODOWNTM
 000048 
 000049          DXCH   ARUPT           RADAR RUPT
 000050          CAF    RDRPTBB
 000051          XCH    BBANK
## Page 61
 000052          TCF    NOQRSM  +1      WAS TCF RADAREAD (NO RADAR IN 206).
 000053         
R000054 TRAPS 31B AND 32 SHOUDL NEVER BE SET.  THEREFORE-
R000055 RUPT 10 WIL ALWAYS REFER TO THE HAND CONTROLLOER LPD OR MINIMUM IMPULSE
R000056 USE.  SEE GEORGE CHERRY FOR RATIONALE REGARDING THE AFORESAID.
 000057         
 000058          DXCH   ARUPT           RUPT10 IS USED ONLY FOR RHC MINIMP MODE ONLY.
 000059          CAF    TWO
 000060          TS     DELAYCTR
 000061          TCF    NOQBRSM
 000062
 000063          EBANK= LST1            RESTART USES E0, E3
 000064 GOBB     BBCON  GOPROG
 000065
 000066          EBANK= TIME1
 000067 T6RPTBB  BBCON  RESUME          ***FIX LATER***
 000068
 000069          EBANK= LST1            
 000070 T3RPTBB  BBCON  T3RUPT
 000071
 000072          EBANK= KEYTEMP1
 000073 KEYRPTBB BBCON  KEYRUPT1
 000074
 000075          EBANK= AOTAZ
 000076 MKRUPTBB BBCON  MARKRUPT
 000077
 000078 UPRPTBB  =      KEYRPTBB
 000079
 000080          EBANK= DNTMBUFF
 000081 DWNRPTBB BBCON  DODOWNTM
 000082
 000083          EBANK= RADMODES
 000084 RDRPTBB  BBCON  RADAREAD
 000085
 000086          EBANK= M11
 000087 T4RPTBB  BBCON  T4RUPTA
 000088
