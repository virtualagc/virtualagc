## Test file for SublimeText syntax highlighting.
## This is just a file of meaningless random AGC statements to be used for
## verifying that Sublime Text syntax highlighting for AGC code is valid
## (or as near as I can get it).

# COMMENT
## Page 7
A		EQUALS	0
L		EQUALS	1		# L AND Q ARE BOTH CHANNELS AND REGISTERS.
NEWJOB		ERASE
LVSQUARE	EQUALS	34D	# SQUARE OF VECTOR INPUT TO ABVAL AND UNIT
STATE		ERASE	+3		# 60 SWITCHES PRESENTLY.
LOKONSW		EQUALS	10D
WAITEXIT	EQUALS	ITEMP1
		SETLOC	67
SGNOFF		=	VBUF	+1	# TEMP FOR +,- ON
BUF		ERASE	+2		# TEMPORARY SCALAR STORAGE.
SWBIT		EQUALS	BUF +1		# SWITCH BIT WITHIN SWITCH WORD
MPTEMP		ERASE			# TEMPORARY USED IN MULTIPLY AND SHIFT.
		ERASE	+71D		# SEVEN SETS OF 12 REGISTERS EACH.
ALT		ERASE	+1
ALTRATE		ERASE
FINALT		ERASE	+1		# (MAY NOT BE REQUIRED FOR FLIGHTS).
AOTCADR		EQUALS	MODECADR +1
SELFERAS	ERASE	1357 - 1377	# *** MUST NOT BE MOVED ***
SFAIL		EQUALS	SELFERAS	# B(1)
ERESTORE	EQUALS	SFAIL +1	# B(1)
		SETLOC	1400
LST1		ERASE	+7		# B(8D)PRM DELTA T'S.
LST2		ERASE	+17D		# B(18D)PRM TASK 2CADR ADDRESSES.
ALFDK		=	TRANSM1 +18D
UNP36		EQUALS	RPASS36 +6	# I(6) S-S
RR-ELEV		EQUALS	RR-AZ +2	# I(2) ANGLE BETWEEN LOS AND Y-Z PLANE
Y		EQUALS	/LAND/ +2	# I(2)TMP OUT-OF-PLANE DIST *2(24)M
W		ERASE	+161D
ENDW		EQUALS	W +162D
VBRFG*		EQUALS	ABRFG +6	# I(2)                PARAMETERS:
L,PVT-CG	ERASE
1/ANET1		=	BLOCKTOP +16D	# THESE 8 PARAMETERS ARE SET UP BY 1/ACCS
/AFC/		EQUALS	NORMEX		# B(2)TMP THROTTLE
FCODD		EQUALS	/AFC/ +2	# B(2)TMP THROTTLE
SAVET-30	EQUALS	TTFDISP +2	# B(2)TMP TIG-30 RESTART
-PHASE1		ERASE
L*WCR*T		=	BUF
H*GHCR*T	=	BUF	+1
                BANK    25
                EBANK=  AOSQ
                CAE     KCOEFCTR        # TEST KCOEFCTR FOR INITIAL PASS
                EXTEND
                EXTEND                  # ON BOTH K AND COEFFA
                BZF     ZEROCOEF        # DISCONTINUITY SECTION FOR COEFFA
                BZMF     +2
                AD      DEC-399         # TEST KCOEFCTR FOR CONSTANT RANGE
                TCF     KONENOW
                CAF     0.0014          # K = 0.0014(T) + 0.44
                CAF     0.44
                MP      KCOEFCTR
                AD      L
                TS      ITEMP1
                COM                     # (1-K),QR SCALED AT 1
                AD      POSMAX          # (1 BIT ERROR DOES NOT COMPOUND)
                TS      (1-K)QR
                TS      (1-K)/8
                MP      10AT16WL        # DT = .1 SECS
                MP      .05AT.5         # IS TO BE SCALED AT 1/2, THE TWO
                AD      .1AT.5          # CONSTANTS REFLECT THAT SCALE FACTOR
## Invalid opcode!
                CSS     AOSQ            # FORM ABSOLUTE VALUE OF AOS
                AD      -.02R/S2        # -.02 RADIANS/SECOND(2) SCALED AT PI/2
                AD      +.02R/S2
                TS      .5ACCMNQ        # SCALED AT 2(+8)/PI
                TCF      +2
                CAF     .75             # SET COEFFA = .75
                CAF     0.30680

## Need interpetive codes...
