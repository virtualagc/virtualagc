# Test file for Visual Studio Code highlighting.

## Page 1
A		EQUALS	0
NEWJOB		ERASE
		SETLOC	67
SGNOFF		=	VBUF	+1
RR-ELEV		EQUALS	RR-AZ +2
Y		EQUALS	/LAND/ +2
W		ERASE	+161D
ENDW		EQUALS	W +162D
L,PVT-CG	ERASE
1/ANET1		=	BLOCKTOP +16D
/AFC/		EQUALS	NORMEX
-PHASE1		ERASE
L*WCR*T		=	BUF
		BANK    25
		EBANK=  AOSQ
		CAE     KCOEFCTR
		EXTEND
		BZF     ZEROCOEF
		BZMF     +2
		AD      DEC-399
		TCF     KONENOW
		CAF     0.0014
		MP      KCOEFCTR
		AD      L
		TS      ITEMP1
		COM
		AD      POSMAX
		TS      (1-K)QR
		MP      .05AT.5
		AD      .1AT.5
## Invalid opcode!
		CSS     AOSQ
