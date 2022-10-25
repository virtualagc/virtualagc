### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     PINBALL_GAME__BUTTONS_AND_LIGHTS.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Hartmuth Gutsche Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        289-355
## Mod history:  2016-09-20 JL   Created.
##               2016-10-19 HG   Transcribed
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed the errors found.
##		2017-01-28 RSB	WTIH -> WITH.
##		2017-02-08 RSB	Comment-text fixes noted while proofing Artemis 72.
##		2017-03-08 RSB	Changed DSPOCTWO to DSPOCTWD.
##		2017-03-08 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-03-17 RSB	Comment-text fixes identified in diff'ing
##				Luminary 99 vs Comanche 55.
##		2021-05-30 ABS	Removed ENDSPF symbol not present in scans.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent
## reduction in image quality) are available online at
##       https://www.ibiblio.org/apollo.
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 289
# KEYBOARD AND DISPLAY PROGRAM



# THE FOLLOWING QUOTATION IS PROVIDED THROUGH THE COUTESY OF THE AUTHORS.

#       ::IT WILL BE PROVED TO THY FACE THAT THOU HAST MEN ABOUT THEE THAT
# USUALLY TALK OF A NOUN AND A VERB, AND SUCH ABOMINABLE WORDS AS NO
# CHRISTIAN EAR CAN ENDURE TO HEAR.::

#                      HENRY 6, ACT 2, SCENE 4
## Actually, this quotation is from <i>Henry VI</i>, Part 2, Act IV, Scene VII.
## <small>&mdash;Ron Burkey, 07/2009</small>



# THE FOLLOWING ASSIGNMENTS FOR PINBALL ARE MADE ELSEWHERE



# RESERVED FOR PINBALL EXECUTIVE ACTION
#
# DSPCOUNT      ERASE                   DISPLAY POSITION INDICATOR
# DECBRNCH      ERASE                   +DEC, -DEC, OCT INDICATOR
# VERBREG       ERASE                   VERB CODE
# NOUNREG       ERASE                   NOUN CODE
# XREG          ERASE                   R1 INPUT BUFFER
# YREG          ERASE                   R2 INPUT BUFFER
# ZREG          ERASE                   R3 INPUT BUFFER
# XREGLP        ERASE                   LO PART OF XREG (FOR DEC CONV ONLY)
# YREGLP        ERASE                   LO PART OF YREG (FOR DEC CONV ONLY)
# ZREGLP        ERASE                   LO PART OF ZREG (FOR DEC CONV ONLY)
# MODREG        ERASE                   MODE CODE
# DSPLOCK       ERASE                   KEYBOARD/SUBROUTINE CALL INTERLOCK
# REQRET        ERASE                   RETURN REGISTER FOR LOAD
# LOADSTAT      ERASE                   STATUS INDICATOR FOR LOADTST
# CLPASS        ERASE                   PASS INDICATOR CLEAR
# NOUT          ERASE                   ACTIVITY COUNTER FOR DSPTAB
# NOUNCADR      ERASE                   MACHINE CADR FOR NOUN
# MONSAVE       ERASE                   N/V CODE FOR MONITOR. (= MONSAVE1-1)
# MONSAVE1      ERASE                   NOUNCADR FOR MONITOR(MATBS) =MONSAVE +1
# DSPTAB        ERASE           +13D    0-10,DISPLAY PANEL BUFFER.11-13,C RELAYS
# CADRSTOR      ERASE                   ENDIDLE STORAGE
# GRABLOCK      ERASE                   INTERNAL INTERLOCK FOR DISPLAY SYSTEM
# NVQTEM        ERASE                   NVSUB STORAGE FOR CALLING ADDRESS
#                                       MUST = NVBNKTEM-1
# NVBNKTEM      ERASE                   NVSUB STORAGE FOR CALLING BANK
#                                       MUST = NVQTEM+1
# DSPLIST       ERASE           +2      WAITING LIST FOR DSP SYST INTERNAL USE
# EXTVBACT      REASE                   EXTENDED VERB ACTIVITY INTERLOCK
# DSPTEM1       ERASE           +2      BUFFER STORAGE AREA 1 (MOSTLY FOR TIME)
# DSPTEM2       ERASE           +2      BUFFER STORAGE AREA 2 (MOSTLY FOR DEG)


## Page 290
# END OF ERASABLES RESERVED FOR PINBALL EXECUTIVE ACTION



# TEMPORARIES FOR PINBALL EXECUTIVE ACTION

# DSEXIT   =      INTB15+         RETURN FOR DSPIN
# EXITEM   =      INTB15+         RETURN FOR SCALE FACTOR ROUTINE SELECT
# BLANKRET =      INTB15+         RETURN FOR 2BLANK

# WRDRET   =      INTBIT15        RETURN FOR 5BLANK
# WDRET    =      INTBIT15        RETURN FOR DSPWD
# DECRET   =      INTBIT15        RETURN FOR PUTCOM(DEC LOAD)
# 21/22REG =      INTBIT15        TEMP FOR CHARIN

# UPDATRET =      POLISH          RETURN FOR UPDATNN, UPDATVB
# CHAR     =      POLISH          TEMP FOR CHARIN
# ERCNT    =      POLISH          COUNTER FOR ERROR LIGHT RESET
# DECOUNT  =      POLISH          COUNTER FOR SCALING AND DISPLAY (DEC)

# SGNON    =      VBUF            TEMP FOR +,- ON
# NOUNTEM  =      VBUF            COUNTER FOR MIXNOUN FETCH
# DISTEM   =      VBUF            COUNTER FOR OCTAL DISPLAY VERBS
# DECTEM   =      VBUF            COUNTER FOR FETCH (DEC DISPLAY VERBS)

# SGNOFF   =       VBUF   +1      TEMP FOR +,- ON
# NVTEMP   =       VBUF   +1      TEMP FOR NVSUB
# SFTEMP1  =       VBUF   +1      STORAGE FOR SF CONST HI PART (=SFTEMP2-1)

# CODE     =       VBUF   +2      FOR DSPIN
# SFTEMP2  =       VBUF   +2      STORAGE FOR SF CONST LO PART (=SFTEMP1+1)

# MIXTEMP  =       VBUF   +3      FOR MIXNOUN DATA
# SIGNRET  =       VBUF   +3      RETURN FOR +,- ON

# ALSO MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5.

# ENTRET   =       DOTINC          EXIT FROM ENTER

# WDCNT    =       DOTRET          CHAR COUNTER FOR DSPWD
# INREL    =       DOTRET          INPUT BUFFER SELECTOR ( X, Y, Z, REG )

# DSPMMTEM =       MATINC          DSPCOUNT SAVE FOR DSPMM
# MIXBR    =       MATINC          INDICATOR FOR MIXED OR NORMAL NOUN

# TEM1     ERASE                   EXEC TEMP
# DSREL    =       TEM1            REL ADDRESS FOR DSPIN

# TEM2     ERASE                   EXEC TEMP
# DSMAG    =       TEM2            MAGNITUDE STORE FOR DSPIN

## Page 291
# IDADDTEM =       TEM2            MIXNOUN INDIRECT ADDRESS STORAGE

# TEM3     ERASE                   EXEC TEMP
# COUNT    =       TEM3            FOR DSPIN

# TEM4     ERASE                   EXEC TEMP
# LSTPTR   =       TEM4            LIST POINTER FOR GRABUSY
# RELRET   =       TEM4            RETURN FOR RELDSP
# FREERET  =       TEM4            RETURN FOR FREEDSP

# TEM5     ERASE                   EXEC TEMP
# NOUNADD  =       TEM5            TEMP STORAGE FOR NOUN ADDRESS

# NNADTEM  ERASE                   TEMP FOR NOUN ADDRESS TABLE ENTRY
# NNTYPTEM ERASE                   TEMP FOR NOUN TYPE TABLE ENTRY
# IDAD1TEM ERASE                   TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
#                                  MUST = IDAD2TEM-1, = IDAD3TEM-2.
# IDAD2TEM ERASE                   TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
#                                  MUST = IDAD1TEM+1, = IDAD3TEM-1.
# IDAD3TEM ERASE                   TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
#                                  MUST = IDAD1TEM+2,  = IDAD2TEM+1.
# RUTMXTEM ERASE                   TEMP FOR SF ROUT TABLE ENTRY(MIXNN ONLY)
# END OF TEMPORARIES FOR PINBALL EXECUTIVE ACTION



# RESERVED FOR PINBALL INTERRUPT ACTION

# DSPCNT   ERASE                   COUNTER FOR DSPOUT
# UPLOCK   ERASE                   BIT1 = UPLINK INTERLOCK (ACTIVATED BY
#                                                                           RECEPTION OF A BAD MESSAGE IN UPLINK)
# END OF ERASABLES RESERVED FOR PINBALL INTERRUPT ACTION



# TEMPORARIES FOR PINBALL INTERRUPT ACTION

# KEYTEMP1 =       WAITEXIT        TEMP FOR KEYRUPT, UPRUPT
# DSRUPTEM =       WAITEXIT        TEMP FOR DSPOUT
# KEYTEMP2 =       RUPTAGN         TEMP FOR KEYRUPT, UPRUPT
# END OF TEMPORARIES FOR PINBALL INTERRUPT ACTION


## Page 292
# THE INPUT CODES ASSUMED FOR THE KEYBOARD ARE,
# 0        10000
# 1        00001
# 9        01001
# VERB     10001
# ERROR RES10010
# KEY RLSE 11001
# +        11010
# -        11011
# ENTER    11100
# CLEAR    11110
# NOUN     11111



# OUTPUT FORMAT FOR DISPLAY PANEL. SET OUT0 TO AAAABCCCCCDDDDD.
# A-S SELECT A RELAYWORD. THIS DETERMINES WHICH PAIR OF CHARACTERS ARE
# ENERGIZED.
# B FOR SPECIAL RELAYS SUCH AS SIGNS ETC.
# C-S  5 BIT RELAY CODE FOR LEFT CHAR OF PAIR SELECTED BY RELAYWORD
# D-S  5 BIT RELAY CODE FOR RIGHT CHAR OF PAIR SELECTED BY RELAYWORD.

# THE PANEL APPEARS AS FOLLOWS,
# MD1    MD2                         (MAJOR MODE)
# VD1    VD2 (VERB)    ND1    ND2    (NOUN)
# R1D1   R1D2   R1D3   R1D4   R1D5   (R1)
# R2D1   R2D2   R2D3   R2D4   R2D5   (R2)
# R3D1   R3D2   R3D3   R3D4   R3D5   (R3)

# EACH OF THESE IS GIVEN A DSPCOUNT NUMBER FOR USE WITHIN COMPUTATION ONLY
# MD1   25     R2D1  11         ALL ARE OCTAL
# MD2   24     R2D2  10
# VD1   23     R2D3   7
# VD2   22     R2D4   6
# ND1   21     R2D5   5
# ND2   20     R3D1   4
# R1D1  16     R3D2   3
# R1D2  15     R3D3   2
# R1D3  14     R3D4   1
# R1D4  13     R3D5   0
# R1D5  12



# THERE IS AN 11 REGISTER TABLE (DSPTAB) FOR THE DISPLAY PANEL.

# DSPTAB RELAYWD       BIT11     BITS 10-6     BITS 5-1
# RELADD
# 10     1011                    MD1 (25)      MD2 (24)
# 9      1010                    VD1 (23)      VD2 (22)

## Page 293
# 8      1001                    ND1 (21)      ND2 (20)
# 7      1000                                  R1D1 (16)
# 6      0111          +R1       R1D2 (15)     R1D3 (14)
# 5      0110          -R1       R1D4 (13)     R1D5 (12)
# 4      0101          +R2       R2D1 (11)     R2D2 (10)
# 3      0100          -R2       R2D3 (7)      R2D4 (6)
# 2      0011                    R2D5 (5)      R3D1 (4)
# 1      0010          +R3       R3D2 (3)      R3D3 (2)
# 0      0001          -R3       R3D4 (1)      R3D5 (0)
#        0000   NO RELAYWORD



# THE 5 BIT RELAY CODES ARE,
# BLANK      00000
# 0          10101
# 1          00011
# 2          11001
# 3          11011
# 4          01111
# 5          11110
# 6          11100
# 7          10011
# 8          11101
# 9          11111


## Page 294
# START OF EXECUTIVE SECTION OF PINBALL



                SETLOC          20000

GRABUSYB        TC              GRABUSY1                # STANDARD LEAD INS. DONT MOVE.
NVSUBSYB        TC              NVSUBSY1

CHARIN          CAF             ONE                     # BLOCK DISPLAY SYST
                XCH             DSPLOCK                 # MAKE DSP SYST BUSY, BUT SAVE OLD
                TS              21/22REG                # C(DSPLOCK) FOR ERROR LIGHT RESET.
                XCH             MPAC
                TS              CHAR
                INDEX           A
                TC              +1                      # INPUT CODE     FUNCTION
                TC              CHARALRM                # 0
                TC              NUM                     # 1
                TC              NUM                     # 2
                TC              NUM                     # 3
                TC              NUM                     # 4
                TC              NUM                     # 5
                TC              NUM                     # 6
                TC              NUM                     # 7
                TC              89TEST                  # 10                 8
                TC              89TEST                  # 11                 9
                TC              CHARALRM                # 12
                TC              CHARALRM                # 13
                TC              CHARALRM                # 14
                TC              CHARALRM                # 15
                TC              CHARALRM                # 16
                TC              CHARALRM                # 17
                TC              NUM             -2      # 20                 0
                TC              VERB                    # 21                 VERB
                TC              ERROR                   # 22                 ERROR LIGHT RESET
                TC              CHARALRM                # 23
                TC              CHARALRM                # 24
                TC              CHARALRM                # 25
                TC              CHARALRM                # 26
                TC              CHARALRM                # 27
                TC              CHARALRM                # 30
                TC              VBRELDSP                # 31                 KEY RELEASE
                TC              POSGN                   # 32                 +
                TC              NEGSGN                  # 33                 -
                TC              ENTERJMP                # 34                 ENTER
                TC              CHARALRM                # 35
                TC              CLEAR                   # 36                 CLEAR
                TC              NOUN                    # 37                 NOUN

## Page 295
ENTERJMP        TC              POSTJUMP
                CADR            ENTER

89TEST          CAF             THREE
                MASK            DECBRNCH
                CCS             A
                TC              NUM                     # IF DECBRNCH IS +, 8 OR 9 OK
                TC              CHARALRM                # IF DECBRNCH IS +0, REJECT 8 OR 9



# NUM ASSEMBLES OCTAL 3 BITS AT A TIME. FOR DECIMAL IT CONVERTS INCOMING
# WORD AS A FRACTION, KEEPING RESULTS TO DP.
# OCTAL RESULTS ARE LEFT IN XREG, YREG, OR ZREG. HI PART OF DEC IN XREG,
# YREG, ZREG. THE LOW PARTS IN XREGLP, YREGLP, OR ZREGLP)
# DECBRNCH IS LEFT AT +0 FOR OCT, +1 FOR + DEC, +2 FOR - DEC.
# IF DSPCOUNT WAS LEFT -, NO MORE DATA IS ACCEPTED.

                CAF             ZERO
                TS              CHAR
NUM             CCS             DSPCOUNT
                TC              +4                      # +
                TC              +3                      # +0
                TC              +1                      # -BLOCK DATA IN IF DSPCOUNT IS -
                TC              ENDOFJOB                # -0
                TC              GETINREL
                CCS             CLPASS                  # IF CLPASS IS + OR +0, MAKE IT +0.
                CAF             ZERO
                TS              CLPASS
                TC              +1
                INDEX           CHAR
                CAF             RELTAB
                MASK            LOW5
                TS              CODE
                CA              DSPCOUNT
                TS              COUNT
                TC              DSPIN
                CAF             THREE
                MASK            DECBRNCH
                CCS             A                       # +0, OCTAL.  +1, + DEC.  +2, - DEC.
                TC              DECTOBIN                # +
                INDEX           INREL                   # +0 OCTAL
                XCH             VERBREG
                TS              CYL
                CS              CYL
                CS              CYL
                XCH             CYL
                AD              CHAR
                TC              ENDNMTST
DECTOBIN        INDEX           INREL


## Page 296
                XCH             VERBREG
                TS              MPAC                    # SUM X 2EXP-14 IN MPAC
                CAF             ZERO
                TS              MPAC            +1
                CAF             TEN                     # 10 X 2EXP-14
                TC              SHORTMP                 # 10SUM X 2EXP-28 IN MPAC, MPAC+1
                XCH             MPAC            +1
                AD              CHAR
                TS              MPAC            +1
                TC              ENDNMTST                # NO OF
                ADS             MPAC                    # OF MUST BE 5TH CHAR
                TC              DECEND
ENDNMTST        INDEX           INREL
                TS              VERBREG
                CS              DSPCOUNT
                INDEX           INREL
                AD              CRITCON
                EXTEND
                BZF             ENDNUM                  # -0, DSPCOUNT = CRITCON
                TC              MORNUM                  # - , DSPCOUNT G/ CRITCON
ENDNUM          CAF             THREE
                MASK            DECBRNCH
                CCS             A
                TC              DECEND
ENDALL          CS              DSPCOUNT                # BLOCK NUMIN BY PLACING DSPCOUNT
                TC              MORNUM          +1      # NEGATIVELY
DECEND          TC              DMP                     # MULT SUM X 2EXP-28 IN MPAC, MPAC+1 BY
                ADRES           DECON                   # 2EXP14/10EXP5. GIVES(SUM/10EXP5)X2EXP-14
                CAF             THREE                   # IN MPAC, +1, +2.
                MASK            DECBRNCH
                INDEX           A
                TC              +0
                TC              +DECSGN
                EXTEND                                  # - CASE
                DCS             MPAC            +1
                DXCH            MPAC            +1
+DECSGN         XCH             MPAC            +2
                INDEX           INREL
                TS              XREGLP          -2
                XCH             MPAC            +1
                INDEX           INREL
                TS              VERBREG
                TC              ENDALL
MORNUM          CCS             DSPCOUNT                # DECREMENT DSPCOUNT
                TS              DSPCOUNT
                TC              ENDOFJOB

CRITCON         OCT             22                      # (DEC 18)
                OCT             20                      # (DEC 16)
                OCT             12                      # (DEC 10)

## Page 297
                OCT             5
                OCT             0

DECON           2DEC            E-5 B14                 # 2EXP14/10EXP5 = .16384 DEC


# GETINREL GETS PROPER DATA REG REL ADDRESS FOR CURRENT C(DSPCOUNT) AND
# PUTS IN INTO INREL. +0 VERBREG, 1 NOUNREG, 2 XREG, 3 YREG, 4 ZREG.

GETINREL        INDEX           DSPCOUNT
                CAF             INRELTAB
                TS              INREL                   # (A TEMP, REG)
                TC              Q

INRELTAB        OCT             4                       # R3D5 (DSPCOUNT = 0)
                OCT             4                       # R3D4           =(1)
                OCT             4                       # R3D3           =(2)
                OCT             4                       # R3D2           =(3)
                OCT             4                       # R3D1           =(4)
                OCT             3                       # R2D5           =(5)
                OCT             3                       # R2D4           =(6)
                OCT             3                       # R2D3           =(7)
                OCT             3                       # R2D2           =(8D)
                OCT             3                       # R2D1           =(9D)
                OCT             2                       # R1D5           =(10D)
                OCT             2                       # R1D4           =(11D)
                OCT             2                       # R1D3           =(12D)
                OCT             2                       # R1D2           =(13D)
                OCT             2                       # R1D1           =(14D)
                TC              CCSHOLE                 # NO DSPCOUNT NUMBER = 15D
                OCT             1                       # ND2            =(16D)
                OCT             1                       # ND1            =(17D)
                OCT             0                       # VD2            =(18D)
                OCT             0                       # VD1            =(19D)

VERB            CAF             ZERO
                TS              VERBREG
                CAF             VD1
NVCOM           TS              DSPCOUNT
                TC              2BLANK
                CAF             ZERO
                TS              DECBRNCH
                TS              REQRET                  # SET FOR ENTPAS0
                CAF             ENDINST                 # IF DSPALARM OCCURS BEFORE FIRST ENTPAS0
                TS              ENTRET                  # OR NVSUB, ENTRET MUST ALREADY BE SET
                                                        # TO TC ENDOFJOB
                TC              ENDOFJOB

## Page 298
NOUN            CAF             ZERO
                TS              NOUNREG
                CAF             ND1                     # ND1, OCT 21 (DEC 17)
                TC              NVCOM



NEGSGN          TC              SIGNTEST
                TC              -ON
                CAF             TWO
BOTHSGN         INDEX           INREL                   # SET DEC COMP BIT TO 1 (IN DECBRNCH)
                AD              BIT7                    # BIT 5 FOR R1, BIT 4 FOR R2,
                ADS             DECBRNCH                # BIT 3 FOR R3.
FIXCLPAS        CCS             CLPASS                  # IF CLPASS IS + OR +0, MAKE IT +0.
                CAF             ZERO
                TS              CLPASS
                TC              +1
                TC              ENDOFJOB

POSGN           TC              SIGNTEST
                TC              +ON
                CAF             ONE
                TC              BOTHSGN

+ON             LXCH            Q
                TC              GETINREL
                INDEX           INREL
                CAF             SGNTAB          -2
                TS              SGNOFF
                AD              ONE
                TS              SGNON
SGNCOM          CAF             ZERO
                TS              CODE
                XCH             SGNOFF
                TC              11DSPIN
                CAF             BIT11
                TS              CODE
                XCH             SGNON
                TC              11DSPIN
                TC              L
-ON             LXCH            Q
                TC              GETINREL
                INDEX           INREL
                CAF             SGNTAB          -2
                TS              SGNON
                AD              ONE
                TS              SGNOFF
                TC              SGNCOM

SGNTAB          OCT             5                       # -R1

## Page 299
                OCT             3                       # -R2
                OCT             0                       # -R3



SIGNTEST        LXCH            Q                       # ALLOWS +,- ONLY WHEN DSPCOUNT=R1D1,
                CS              R1D1                    # R2D1, OR R3D1.
                TC              SGNTST1
                CS              R2D1
                TC              SGNTST1
                CS              R3D1
                TC              SGNTST1
                TC              ENDOFJOB                # NO MATCH FOUND. SIGN ILLEGAL
SGNTST1         AD              DSPCOUNT
                EXTEND
                BZF             +2                      # MATCH FOUND
                TC              Q
                TC              L                       # SIGN LEGAL



# ERROR LIGHT RESET (RSET) TURNS OFF,
# UPLINK ACTIVITY, AUTO, HOLD, FREE, NO ATT, OPERATOR ERROR,
# PROG ALM, TRACKER FAIL.
# LEAVES GIMBAL LOCK ALONE.
# IT ALSO ZEROES THE :TEST ALARM: OUT BIT, WHICH TURNS OFF STBY,RESTART.
# IT ALSO SETS :CAUTION RESET: TO 1.
# IT ALSO FORCES BIT 12 OF ALL DSPTAB ENTRIES TO 1.

ERROR           XCH             21/22REG                # RESTORE ORIGINAL C(DSPLOCK). THUS ERROR
                TS              DSPLOCK                 # LIGHT RESET LEAVES DSPLOCK UNCHANGED.
                INHINT
                CAF             BIT10                   # TURN ON :CAUTION RESET: OUTBIT
                EXTEND
                WOR             DSALMOUT                # BIT10 CHAN 11
                CAF             BIT6                    # LEAVE GIMBAL LOCK LAMP INTACT,
                MASK            DSPTAB           +11D   # TURNING OFF, AUTO, HOLD, FREE, NO ATT.,
                AD              BIT15                   # PROG ALARM, AND TRACKER.
                TS              DSPTAB           +11D
                CS              PRIO16                  # RESET FAIL BITS WHICH GENERATE PROG
                MASK            IMODES33                # ALARM SO THAT IF THE FAILURE STILL
                AD              PRIO16                  # EXISTS, THE ALARM WILL COME BACK.
                TS              IMODES33
                CS              BIT10
                MASK            IMODES30
                AD              BIT10
                TS              IMODES30

                CS              RFAILS
                MASK            RADMODES


## Page 300
                AD              BIT7
                TS              RADMODES

                CS              BIT10                   # TURN OFF :TEST ALARM: OUTBIT.
                EXTEND
                WAND            CHAN13
                CS              ERCON                   # TURN OFF UPLINK ACTIVITY,
                EXTEND                                  # OPERATOR ERROR.
                WAND            DSALMOUT
TSTAB           CAF             BINCON                  # (DEC 10)
                TS              ERCNT                   # ERCNT = COUNT
                INHINT
                INDEX           ERCNT
                CCS             DSPTAB
                AD              ONE
                TC              ERPLUS
                AD              ONE
ERMINUS         CS              A
                MASK            NOTBIT12
                TC              ERCOM
ERPLUS          CS              A
                MASK            NOTBIT12
                CS              A                       # MIGHT WANT TO RESET CLPASS, DECBRNCH,
ERCOM           INDEX           ERCNT                   # ETC.
                TS              DSPTAB
                RELINT
                CCS             ERCNT
                TC              TSTAB           +1
                CAF             ZERO
                TS              FAILREG
                TS              SFAIL
                TC              ENDOFJOB

ERCON           OCT             104                     # CHAN 11 BITS 3,7.
                                                        # UPLINK ACTIVITY, AND OPERATOR ERROR.
RFAILS          OCT             330                     # RADAR CDU AND DATA FAIL FLAGS.
NOTBIT12        OCT             73777



# CLEAR BLANKS WHICH R1, R2, R3 IS CURRENT OR LAST TO BE DISPLAYED(PERTINE
# NT XREG,YREG,ZREG IS CLEARED). SUCCESSIVE CLEARS TAKE CARE OF EACH RX
# L/ RC UNTIL R1 IS DONE. THEN NO FURTHER ACTION

# THE SINGLE COMPONENT LOAD VERBS ALLOW ONLY THE SINGLE RC THAT IS
# APPROPRIATE TO BE CLEARED.

# CLPASS      +0 PASS0, CAN BE BACKED UP
#             +NZ HIPASS, CAN BE BACKED UP
#             -NZ PASS0, CANNOT BE BACKED UP


## Page 301
CLEAR           CCS             DSPCOUNT
                AD              ONE
                TC              +2
                AD              ONE
                TS              DSPCOUNT                # MAG OF DSPCOUNT
                TC              GETINREL                # MUST SET INREL, EVEN FOR HIPASS
                CCS             CLPASS
                TC              CLPASHI                 # +
                TC              +2                      # +0    IF CLPASS IS +0 OR -, IT IS PASS0
                TC              +1                      # -
                CA              INREL
                TC              LEGALTST
                TC              CLEAR1
CLPASHI         CCS             INREL
                TS              INREL
                TC              LEGALTST
                CAF             DOUBLK          +2       # +3 TO - NUMBER. BACKS DATA REQUESTS.
                ADS             REQRET
                CA              INREL
                TS              MIXTEMP                 # TEMP STORAGE FOR INREL
                EXTEND
                DIM             VERBREG                 # DECREMENT VERB AND RE-DISPLAY
                TC              BANKCALL
                CADR            UPDATVB
                CA              MIXTEMP
                TS              INREL                   # RESTORE INREL
CLEAR1          TC              CLR5
                INCR            CLPASS                  # ONLY IF CLPASS IS + OR +0,
                TC              ENDOFJOB                # SET FOR HIGHER PASS.
CLR5            LXCH            Q                       # USES 5BLANK BUT AVOIDS ITS TC GETINREL
                TC              5BLANK          +2
LEGALTST        AD              NEG2
                CCS             A
                TC              Q                       # LEGAL         INREL G/ 2
                TC              CCSHOLE
                TC              ENDOFJOB                # ILLEGAL       INREL= 0,1
                TC              Q                       # LEGAL        INREL = 2



# 5BLANK BLANKS 5 CHAR DISPLAY WORD IN R1, R2, OR R3. IT ALSO ZEROES XREG,
# YREG, OR ZREG.PLACE ANY + DSPCOUNT NUMBER FOR PERTINENT RC INTO DSPCOUNT
# DSPCOUNT IS LEFT SET TO LEFT MOST DSP NUMB FOR RC JUST BLANKED.

5BLANK          LXCH            Q
                TC              GETINREL
                CAF             ZERO
                INDEX           INREL
                TS              VERBREG                 # ZERO X, Y, Z REG.
                INDEX           INREL


## Page 302
                TS              XREGLP          -2
                TS              CODE
                INDEX           INREL                   # ZERO PERTINENT DEC COMP BIT.
                CS              BIT7                    # PROTECT OTHERS
                MASK            DECBRNCH
                MASK            BRNCHCON                # ZERO LOW 2 BITS.
                TS              DECBRNCH
                INDEX           INREL
                CAF             SINBLANK        -2      # BLANK ISOLATED CHAR SEPARATELY
                TS              COUNT
                TC              DSPIN
5BLANK1         INDEX           INREL
                CAF             DOUBLK          -2
                TS              DSPCOUNT
                TC              2BLANK
                CS              TWO
                ADS             DSPCOUNT
                TC              2BLANK
                INDEX           INREL
                CAF             R1D1            -2
                TS              DSPCOUNT                # SET DSPCOUNT TO LEFT MOST DSP NUMBER
                TC              L                       # OF REG. JUST BLANKED

SINBLANK        OCT             16                      # DEC 14
                OCT             5
                OCT             4
DOUBLK          OCT             15                      # DEC 13
                OCT             11                      # DEC 9
                OCT             3

BRNCHCON        OCT             77774

# 2BLANK BLANKS TWO CHAR. PLACE DSP NUMBER OF LEFT CHAR  OF THE PAIR INTO
# DSPCOUNT. THIS NUMBER IS LEFT IN DSPCOUNT

2BLANK          CA              DSPCOUNT
                TS              SR
                CS              BLANKCON
                INHINT
                INDEX           SR
                XCH             DSPTAB
                EXTEND
                BZMF            +2                      # IF OLD CONTENTS -, NOUT OK
                INCR            NOUT                    # IF OLD CONTENTS +, +1 TO NOUT
                RELINT                                  # IF -, NOUT OK
                TC              Q
BLANKCON        OCT             4000


## Page 303
# ENTER PASS 0 IS THE EXECUTE FUNCTION. HIGHER ORDER ENTERS ARE TO LOAD
# DATA. THE SIGN OF REQRET DETERMINES THE PASS, + FOR PASS 0,- FOR HIGHER
# PASSES.



# MACHINE CADR TO BE SPECIFIED (MCTBS) NOUNS DESIRE AN ECADR TO BE LOADED
# WHEN USED WITH LOAD VERBS, MONITOR VERBS, OR DISPLAY VERBS (EXCEPT
# VERB = FIXED MEMORY DISPLAY, WHICH REQUIRES AN FCADR).



                SETLOC          22000

NVSUBB          TC              NVSUB1                  # STANDARD LEAD INS. DONT MOVE.
DSPMM           TCF             DSPMM1
LOADLV1         TC              LOADLV
                                                        # END OF STANDARD LEAD INS.



ENTER           CAF             ZERO
                TS              CLPASS
                CAF             ENDINST
                TS              ENTRET
                CCS             REQRET
                TC              ENTPAS0                 # IF +, PASS 0
                TC              ENTPAS0                 # IF +, PASS 0
                TC              +1                      # IF -, NOT PASS 0
                CAF             THREE                   # IF DEC, ALARM IF LESS THAN 5 CHAR IN,
                MASK            DECBRNCH                # BUT LEAVE REQRET - AND FLASH ON, SO
                CCS             A                       # OPERATOR CAN SUPPLY MISSING NUMERICAL
                TC              +2                      # CHARACTERS AND CONTINUE.
                TC              ACCEPTWD                # OCTAL. ANY NUMBER OF CHAR OK.
                CCS             DSPCOUNT
                TC              GODSPALM                # LESS THAN 5 CHAR DEC(DSPCOUNT IS +)
                TC              GODSPALM                # LESS THAN 5 CHAR DEC(DSPCOUNT IS +)
                TC              +1                      # 5 CHAR IN (DSPCOUNT IS -)
ACCEPTWD        CS              REQRET                  # 5 CHAR IN (DSPCOUNT IS -)
                TS              REQRET                  # SET REQRET +.
                TC              FLASHOFF
                TC              REQRET

ENTEXIT         =               ENTRET

LOWVERB         OCT             30                      # LOWER VERB THAT AVOIDS NOUN TEST

ENTPAS0         CAF             ZERO                    #  NOUN VERB SUB ENTERS HERE
                TS              DECBRNCH
TESTVB          CS              VERBREG                 # IF VERB IS 30-77, SKIP NOUN TEST


## Page 304
                AD              LOWVERB                 # 30-VB
                EXTEND
                BZMF            VERBFAN                 # VERB G/ E 30
TESTNN          EXTEND                                  # VERB L/ 30
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                INDEX           MIXBR
                TC              +0
                TC              +2                      # NORMAL
                TC              MIXNOUN                 # MIXED
                CCS             NNADTEM                 # NORMAL
                TC              VERBFAN         -2      #       NORMAL  IF +
                TC              GODSPALM                # NOT IN USE     IF +0
                TC              REQADD                  # SPECIFY MACHINE CADR IF -
                INCR            NOUNCADR                # AUGMENT MACHINE CADR IF -0
                TC              SETNADD                 # ECADR FROM NOUNCADR. SETS EB, NOUNADD.
                TC              INTMCTBS        +2
REQADD          CAF             BIT15                   # SET CLPASS FOR PASS0 ONLY
                TS              CLPASS
                CS              ENDINST                 # TEST IF REACHED HERE FROM INTERNAL OR
                AD              ENTEXIT                 #             FROM EXTERNAL
                EXTEND
                BZF             +2                      # EXTERNAL MACH CADR TO BE SPECIFIED
                TC              INTMCTBS
                TC              REQDATZ                 # EXTERNAL MACH CADR TO BE SPECIFIED
                CCS             DECBRNCH
                TC              GODSPALM                # ALARM IF DECIMAL USED FOR MCTBS
                XCH             ZREG                    # OCTAL USED    OK
                TC              SETNCADR                # ECADR INTO NOUNCADR. SET EB, NOUNADD.
                EXTEND
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                TC              VERBFAN

                EBANK=          DSPCOUNT
LODNNLOC        2CADR           LODNNTAB

NEG5            OCT             77772

INTMCTBS        CA              MPAC            +2      # INTERNAL MACH CADR TO BE SPECIFIED.
                TC              SETNCADR                # ECADR INTO NOUNCADR. SET EB, NOUNADD.
                CS              BIT4                    # NVSUB CALL LEFT CADR IN MPAC+2 FOR MACH
                MASK            VERBREG                 # CADR TO BE SPECIFIED.
                AD              NEG5                    # MASKING MAKES VB15 LOOK LIKE VB05.
                EXTEND
                BZF             VERBFAN                 # VB = 05 OR 15, DO NOT DISPLAY CADR.
                CAF             R3D1                    # VB NOT = 05 OR 15, DISPLAY CADR.
                TS              DSPCOUNT
                CA              NOUNCADR
                TC              DSPOCTWD


## Page 305
                TC              VERBFAN

                AD              ONE
                TC              SETNCADR                # ECADR INTO NOUNCADR. SETS EB, NOUNADD.
VERBFAN         CS              LST2CON
                AD              VERBREG                 # VERB-LST2CON
                CCS             A
                AD              ONE                     # VERB G/ LST2CON
                TC              +2
                TC              VBFANDIR                # VERB L/ LST2CON
                TS              MPAC
                TC              RELDSP                  # RELEASE DISPLAY SYST
                XCH             MPAC                    # ALSO TURN OFF RELEASE DISPLAY SYST LIGHT
                AD              LST2CADR
                TC              BANKJUMP
LST2CON         OCT             40                      # FIRST LST2 VERB
LST2CADR        CADR            LST2FAN

VBFANDIR        INDEX           VERBREG
                CAF             VERBTAB
                TC              BANKJUMP

VERBTAB         CADR            GODSPALM                # VB00 ILLEGAL
                CADR            DSPA                    # VB01 DISPLAY OCT COMP 1 (R1)
                CADR            DSPB                    # VB02 DISPLAY OCT COMP 2 (R1)
                CADR            DSPC                    # VB03 DISPLAY OCT COMP 3 (R1)
                CADR            DSPAB                   # VB04 DISPLAY OCT COMP 1,2 (R1,R2)
                CADR            DSPABC                  # VB05 DISPLAY OCT COMP 1,2,3 (R1,R2,R3)
                CADR            DECDSP                  # VB06 DECIMAL DISPLAY
                CADR            DSPDPDEC                # VB07 DP DECIMAL DISPLAY (R1,R2)
                CADR            DSPALARM                # VB10 SPARE
                CADR            MONITOR                 # VB11 MONITOR OCT COMP 1 (R1)
                CADR            MONITOR                 # VB12 MONITOR OCT COMP 2 (R1)
                CADR            MONITOR                 # VB13 MONITOR OCT COMP 3 (R1)
                CADR            MONITOR                 # VB14 MONITOR OCT COMP 1,2 (R1,R2)
                CADR            MONITOR                 # VB15 MONITOR OCT COMP 1,2,3 (R1,R2,R3)
                CADR            MONITOR                 # VB16 MONITOR DECIMAL
                CADR            MONITOR                 # VB17 MONITOR DP DEC (R1,R2)
                CADR            GODSPALM                # VB20 SPARE
                CADR            ALOAD                   # VB21 LOAD COMP 1 (R1)
                CADR            BLOAD                   # VB22 LOAD COMP 2 (R2)
                CADR            CLOAD                   # VB23 LOAD COMP 3 (R3)
                CADR            ABLOAD                  # VB24 LOAD COMP 1,2 (R1,R2)
                CADR            ABCLOAD                 # VB25 LOAD COMP 1,2,3 (R1,R2,R3)
                CADR            GODSPALM                # VB26 SPARE
                CADR            DSPFMEM                 # VB27 FIXED MEMORY DISPLAY
                                                        # THE FOLLOWING VERBS MAKE NO NOUN TEST
REQEXLOC        CADR            VBRQEXEC                # VB30 REQUEST EXECUTIVE
                CADR            VBRQWAIT                # VB31 REQUEST WAITLIST
                CADR            BUMP                    # VB32 C(R2) INTO R3, C(R1) INTO R2


## Page 306
                CADR            VBPROC                  # VB33 PROCEED WITHOUT DATA
                CADR            VBTERM                  # VB34 TERMINATE CURRENT TEST OR LOAD REQ
                CADR            VBTSTLTS                # VB35 TEST LIGHTS
                CADR            SLAP1                   # VB36 FRESH START
ENDVBFAN        CADR            MMCHANG                 # VB37 CHANGE MAJOR MODE



# THE LIST2 VERBFAN IS LOCATED IN THE EXTENDED VERB BANK.



## Page 307
# NNADTAB CONTAINS A RELATIVE ADDRESS, IDADDREL(IN LOW 10 BITS), REFERRING
# TO WHERE 3 CONSECUTIVE ADDRESSES ARE STORED (IN IDADDTAB).
# MIXNOUN GETS DATA AND STORES IN MIXTEMP,+1,+2. IT SETS NOUNADD FOR
#  MIXTEMP.

MIXNOUN         CCS             NNADTEM
                TC              +4                      # + IN USE
                TC              GODSPALM                # +0 NOT IN USE
                TC              +2                      # - IN USE
                TC              +1                      # -0 IN USE
                CS              SIX
                AD              VERBREG
                EXTEND
                BZMF            +2                      # VERB L/E 6
                TC              VERBFAN                 # AVOID MIXNOUN SWAP IF VB NOT = DISPLAY
                CAF             TWO
MIXNN1          TS              DECOUNT
                AD              MIXAD
                TS              NOUNADD                 # SET NOUNADD TO MIXTEMP + K
                INDEX           DECOUNT                 # GET IDADDTAB ENTRY FOR COMPONENT K
                CA              IDAD1TEM                # OF NOUN.
                TS              NOUNTEM
                                                        # TEST FOR DP (FOR OCT DISPLAY). IF SO, GET
                                                        #   MINOR PART ONLY.
                TC              SFRUTMIX                # GET SF ROUT NUMBER IN A
                TC              DPTEST
                TC              MIXNN2                  # NO DP
                INCR            NOUNTEM                 # DP GET MINOR PART
MIXNN2          CA              NOUNTEM
                MASK            LOW11                   # ESUBK (NO DP) OR (ESUBK)+1     FOR DP
                TC              SETEBANK                # SET EBANK, LEAVE EADRES IN A.
                INDEX           A                       # PICK UP C(ESUBK)  NOT DP
                CA              0                       # OR C((ESUBK)+1)  FOR DP MINOR PART
                INDEX           NOUNADD
                XCH             0                       # STORE IN MIXTEM + K
                CCS             DECOUNT
                TC              MIXNN1
                TC              VERBFAN

MIXAD           TC              MIXTEMP



# DPTEST   ENTER WITH SF ROUT NUMBER IN A.
#          RETURNS TO L+1 IF NO DP.
#          RETURNS TO L+2 IF DP.

DPTEST          INDEX           A
                TCF             +1
                TC              Q                       # OCTAL ONLY NO DP


## Page 308
                TC              Q                       # FRACT NO DP
                TC              Q                       # DEG  NO DP
                TC              Q                       # ARITH  NO DP
                TCF             DPTEST1                 # DP1OUT
                TCF             DPTEST1                 # DP2OUT
                TC              Q                       # OPDEG  NO DP
                TCF             DPTEST1                 # DP3OUT
DPTEST1         INDEX           Q
                TC              1                       # RETURN TO L+2



REQDATX         CAF             R1D1
                TCF             REQCOM
REQDATY         CAF             R2D1
                TCF             REQCOM
REQDATZ         CAF             R3D1
REQCOM          TS              DSPCOUNT
                CS              Q
                TS              REQRET
                TC              BANKCALL
                CADR            5BLANK
                TC              FLASHON
                CS              ENDINST
                AD              ENTEXIT
                EXTEND
                BZF             ENDRQDAT                # ENTEXIT = ENDOFJOB. EXTERNALLY INITIATED
                CS              ZERO                    # ENTEXIT NOT ENDOFJOB. NVSUB INITIATED
                TS              CADRSTOR                # NVSUB INITIATED LOAD. SET CADRSTOR TO -0
ENDRQDAT        TC              ENTEXIT

# IF NVSUB INITIATED LOAD, SET CADRSTOR TO -0 TO TELL RECALTST TO RELEASE
# DISPLAY IF ENDIDLE WAS NOT USED. (NECESSARY FOR DATAWAIT)


                TS              NOUNREG
UPDATNN         XCH             Q
                TS              UPDATRET
                EXTEND
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                CCS             NNADTEM
                AD              ONE                     # NORMAL
                TCF             PUTADD
                TCF             PUTADD          +1      # MCTBS  DONT CHANGE NOUNADD
                TCF             PUTADD          +1      # MCTBI  DONT CHANGE NOUNADD
PUTADD          TC              SETNCADR                # ECADR INTO NOUNCADR. SETS EB, NOUNADD.
                CAF             ND1
                TS              DSPCOUNT


## Page 309
                CA              NOUNREG
                TCF             UPDAT1

                TS              VERBREG
UPDATVB         XCH             Q
                TS              UPDATRET
                CAF             VD1
                TS              DSPCOUNT
                CA              VERBREG
UPDAT1          TC              DSP2BIT
                TC              UPDATRET



GODSPALM        TC              POSTJUMP
                CADR            DSPALARM


## Page 310
#          NOUN TABLES
# NOUN CODE L/55, NORMAL CASE.  NOUN CODE G/E 55, MIXED NOUN CASE.
# FOR NORMAL CASE, NNADTAB CONTAINS ONE       ECADR    FOR EACH NOUN.
# +0 INDICATES NOUN NOT USED.   - ENTRY INDICATES MACHINE CADR(E OR F) TO
# BE SPECIFIED. -1 INDICATES CHANNEL TO BE SPECIFIED. -0 INDICATES AUGMENT
# OF LAST MACHINE CADR SUPPLIED.

# FOR MIXED CASE, NNADTAB CONTAINS ONE INDIRECT ADDRESS(IDADDREL) IN LOW
# 10 BITS, AND THE COMPONENT CODE NUMBER IN THE HIGH 5 BITS.

# NNTYPTAB IS A PACKED TABLE OF THE FORM MMMMMNNNNNPPPPP.

# FOR THE NORMAL CASE, M-S ARE THE COMPONENT CODE NUMBER.
#                      N-S ARE THE SF ROUTINE CODE NUMBER.
#                      P-S ARE THE SF CONSTANT CODE NUMBER.

# MIXED CASE,M-S ARE THE SF CONSTANT3 CODE NUMBER     3 COMPONENT CASE
#            N-S ARE THE SF CONSTANT2 CODE NUMBER
#            P-S ARE THE SF CONSTANT1 CODE NUMBER
#            N-S ARE THE SF CONSTANT2 CODE NUMBER     2 COMPONENT CASE
#            P-S ARE THE SF CONSTANT1 CODE NUMBER
#            P-S ARE THE SF CONSTANT1 CODE NUMBER      1 COMPONENT CASE

# THERE IS ALSO AN INDIRECT ADDRESS TABLE(IDADDTAB) FOR MIXED CASE ONLY.
# EACH ENTRY CONTAINS ONE ECADR.    IDADDREL IS THE RELATIVE ADDRESS OF
# THE FIRST OF THESE ENTRIES.
# THERE IS ONE ENTRY IN THIS TABLE FOR EACH COMPONENT OF A MIXED NOUN
# THEY ARE LISTED IN ORDER OF ASCENDING K.

# THERE IS ALSO A SCALE FACTOR ROUTINE NUMBER TABLE( RUTMXTAB ) FOR MIXED
# CASE ONLY. THERE IS ONE ENTRY PER MIXED NOUN. THE FORM IS,
#       QQQQQRRRRRSSSSS
# Q-S ARE THE SF ROUTINE 3 CODE NUMBER     3 COMPONENT CASE
# R-S ARE THE SF ROUTINE 2 CODE NUMBER
# S-S ARE THE SF ROUTINE 1 CODE NUMBER
# R-S ARE THE SF ROUTINE 2 CODE NUMBER     2 COMPONENT CASE
# S-S ARE THE SF ROUTINE 1 CODE NUMBER
#
# IN OCTAL DISPLAY AND LOAD (OCT OR DEC) VERBS, EXCLUDE USE OF VERBS WHOSE
# COMPONENT NUMBER IS GREATER THAN THE NUMBER OF COMPONENTS IN NOUN.
# ALL MACHINE ADDRESS TO BE SPECIFIED NOUNS ARE 1 COMPONENT.
# ONLY EXCEPTION IS NOUN 01 TO ALLOW OCTAL DISPLAYS AND LOADS OF
# AN UNCONTOLLED NUMBER OF COMPONENTS.



# IN MULTI-COMPONENT LOAD VERBS, NO MIXING OF OCTAL AND DECIMAL DATA
# COMPONENT WORDS IS ALLOWED. ALARM IF VIOLATION.


## Page 311
# IN DECIMAL LOADS OF DATA, 5 NUMERICAL CHARACTERS MUST BE KEYED IN
# BEFORE EACH ENTER. IF NOT, ALARM.


## Page 312
#          DISPLAY VERBS
DSPABC          CS              TWO
                TC              COMPTEST
                INDEX           NOUNADD
                CS              2
                XCH             BUF             +2
DSPAB           CS              ONE
                TC              COMPTEST
                INDEX           NOUNADD
                CS              1
                XCH             BUF             +1
DSPA            TC              TSTFORDP
                INDEX           NOUNADD
                CS              0
DSPCOM1         XCH             BUF
                TC              DSPCOM2
DSPB            CS              ONE
                TC              COMPTEST
                INDEX           NOUNADD
                CS              1
                TC              DSPCOM1
DSPC            CS              TWO
                TC              COMPTEST
                INDEX           NOUNADD
                CS              2
                TC              DSPCOM1
DSPCOM2         CS              TWO                     # A  B  C  AB ABC
                AD              VERBREG                 # -1 -0 +1 +2 +3   IN A
                CCS             A                       # +0 +0 +0 +1 +2    IN A AFTER CCS
                TC              DSPCOM3
                TC              ENTEXIT
                TC              +1
DSPCOM3         TS              DISTEM                  # +0,+1,+2 INTO DISTEM
                INDEX           A
                CAF             R1D1
                TS              DSPCOUNT
                INDEX           DISTEM
                CS              BUF
                TC              DSPOCTWD
                XCH             DISTEM
                TC              DSPCOM2         +2

# COMPTEST ALARMS IF COMPONENT NUMBER OF VERB(LOAD OR OCT DISPLAY) IS
# GREATER THAN THE HIGHEST COMPONENT NUMBER OF NOUN.
# NOUN 01 IS EXCLUDED FROM TEST.
COMPTEST        TS              SFTEMP1                 # - VERB COMP
                LXCH            Q
COMPTST1        CS              ONE
                AD              NOUNREG
                EXTEND


## Page 313
                BZF             NDCMPTST                # NOUN = 01, ANY COMP OK
                INDEX           MIXBR                   # NOUN NOT = 01.
                CAF             COMPICK         -1
                INDEX           A
                CA              0
                MASK            HI5
                TC              LEFT5                   # NOUN COMP
                AD              SFTEMP1                 # NOUN COMP - VERB COMP
                CCS             A
                TC              L                       # NOUN COMP G/ VERB COMP
                TC              CCSHOLE
                TC              GODSPALM                # NOUN COMP L/ VERB COMP
NDCMPTST        TC              L                       # NOUN COMP = VERB COMP



TSTFORDP        LXCH            Q                       # TEST FOR DP. IF SO, GET MINOR PART ONLY.
                CA              NNADTEM
                AD              ONE                     # IF NNADTEM = -1, CHANNEL TO BE SPECIFIED
                EXTEND
                BZF             CHANDSP
                INDEX           MIXBR
                TC              +0
                TC              +2                      # NORMAL
                TC              L                       # MIXED CASE ALREADY HANDLED IN MIXNOUN
                TC              SFRUTNOR
                TC              DPTEST
                TC              L                       # NO DP
                INCR            NOUNADD                 # DP    E+1 INTO NOUNADD FOR MINOR PART.
                TC              L



CHANDSP         EXTEND
                INDEX           NOUNCADR
                READ            0
                CS              A
                TCF             DSPCOM1



COMPICK         ADRES           NNTYPTEM
                ADRES           NNADTEM

DECDSP          INDEX           MIXBR                   # NORMAL                MIXED
                CAF             COMPICK         -1      # ADRES NNTYPTEM        ADRES NNADTEM
                INDEX           A
                CA              0                       # C(NNTYPTEM)           C(NNADTEM)
                MASK            HI5                     # GET HI5 OF NNTYPTAB(NORM)OF NNADTAB(MIX)
                TC              LEFT5


## Page 314
                TS              DECOUNT                 # COMP NUMBER INTO DECOUNT
DSPDCGET        TS              DECTEM                  # PICKS UP DATA
                AD              NOUNADD                 # DECTEM 1COMP +0, 2COMP +1, 3COMP +2
                INDEX           A
                CS              0
                INDEX           DECTEM
                XCH             XREG                    # CANT USE BUF SINCE DMP USES IT.
                CCS             DECTEM
                TC              DSPDCGET                # MORE TO GET
DSPDCPUT        CAF             ZERO                    # DISPLAYS DATA
                TS              MPAC            +1      # DECOUNT 1COMP +0, 2COMP +1, 3COMP +2
                TS              MPAC            +2
                INDEX           DECOUNT
                CAF             R1D1
                TS              DSPCOUNT
                INDEX           DECOUNT
                CS              XREG
                TS              MPAC
                TC              SFCONUM                 # 2X ( SF CON NUMB ) IN A
                TS              SFTEMP1
                EXTEND                                  # SWITCH BANKS TO SF CONSTANT TABLE
                DCA             GTSFOUTL                #    READING ROUTINE.
                DXCH            Z                       # LOADS SFTEMP1, SFTEMP2.
                INDEX           MIXBR
                TC              +0
                TC              DSPSFNOR
                TC              SFRUTMIX
                TC              DECDSP3

DSPSFNOR        TC              SFRUTNOR
                TC              DECDSP3

                EBANK=          DSPCOUNT
GTSFOUTL        2CADR           GTSFOUT

DSPDCEND        TC              BANKCALL                # ALL SFOUT ROUTINES END HERE
                CADR            DSPDECWD
                CCS             DECOUNT
                TC              +2
                TC              ENTEXIT
                TS              DECOUNT
                TC              DSPDCPUT                # MORE TO DISPLAY

DECDSP3         INDEX           A
                CAF             SFOUTABR
                TC              BANKJUMP


## Page 315
SFOUTABR        CADR            DSPALARM                # ALARM IF DEC DISP WITH OCTAL ONLY NOUN
                CADR            DSPDCEND
                CADR            DEGOUTSF
                CADR            ARTOUTSF
                CADR            DP1OUTSF
                CADR            DP2OUTSF
                CADR            OPDEGOUT
                CADR            DP3OUTSF
ENDRTOUT        EQUALS



#         THE FOLLOWING IS ATYPICAL SF ROUTINE. IT USES MPAC. LEAVES RESU
# LTS IN MPAC, MPAC+1. ENDS WITH TC DSPDCEND



                SETLOC          BLANKCON +1

#    DEGOUTSF SCALES BY .18 THE LOW 14 BITS OF ANGLE, ADDING .18 FOR
# NUMBERS IN THE NEGATIVE (AGC) RANGE.

DEGOUTSF        CAF             ZERO
                TS              MPAC            +2      # SET INDEX FOR FULL SCALE
                TC              FIXRANGE
                TC              +2                      # NO AUGMENT NEEDED (SFTEMP1 AND 2 ARE 0)
                TC              SETAUG                  # SET AUGMENTER ACCORDING TO C(MPAC +2)
                TC              DEGCOM

# OPDEGOUT SCALES BY .45 (THE RANGE IS 90 DEGREES) AND ADDS A 20 DEG BIAS.

OPDEGOUT        CCS             MPAC                    # RANGE IS 90 DEG
                XCH             MPAC                    # IF POS OR POS 0 THEN ADD BIAS AND
                TC              +3                      # CORRECT FOR POSSIBLE OVERFLOW
                TC              NEGOPT                  # IF NEG NON ZERO
                AD              NEG1                    # IF NEG ZERO SUBTRACT 1
                AD              20BIAS
BIASCOM         TS              MPAC                    # TEST FOR OVERFLOW
                TC              +3                      # NO OVFLOW
                CAF             BIT15                   # IF OVFLOW
                ADS             MPAC
                CAF             TWO                     # SET MULTIPLIER TO .45
                TC              DEGOUTSF        +1

NEGOPT          XCH             MPAC                    # NEGATIVE CASE
                AD              20BIAS
                CCS             A
                TC              BIASCOM                 # IF POS THEN SUBTRACT 1 BECAUSE OF 2SCOM
                TC              CCSHOLE
                AD              ONE                     # IF NEG RESTORE SUM


## Page 316
                COM                                     # IF NEG 0 LEAVE NEG 0
                TC              BIASCOM

SETAUG          EXTEND                                  # LOADS SFTEMP1 AND SFTEMP2 WITH THE
                INDEX           MPAC            +2      # DP AUGMENTER CONSTANT
                DCA             DEGTAB
                DXCH            SFTEMP1
                TC              Q

FIXRANGE        CCS             MPAC                    # IF MPAC IS + RETURN TO L+1
                TC              Q                       # IF MPAC IS - RETURN TO L+2 AFTER
                TC              Q                       # MASKING OUT THE SIGN BIT
                TCF             +1
                CS              BIT15
                MASK            MPAC
                TS              MPAC
                INDEX           Q
                TC              1

DEGCOM          EXTEND                                  # LOADS MULTIPLIER, DOES SHORTMP, AND
                INDEX           MPAC +2                 # ADDS AUGMENTER.
                DCA             DEGTAB
                DXCH            MPAC                    # ADJUSTED ANGLE IN A
                TC              SHORTMP
                DXCH            SFTEMP1
                DAS             MPAC
                TC              SCOUTEND

DEGTAB          OCT             05605                   # HI PART OF    .18
                OCT             03656                   # LOW PART OF   .18
                OCT             16314                   # HI PART OF    .45
                OCT             31463                   # LO PART OF    .45

20BIAS          OCT             16040                   # 20 DEG BIAS FOR OPTICS

ARTOUTSF        DXCH            SFTEMP1                 # ASSUMES POINT AT LEFT OF DP SFCON
                DXCH            MPAC
                TC              SHORTMP
SCOUTEND        TC              POSTJUMP
                CADR            DSPDCEND

DP1OUTSF        TC              DPOUT                   # SCALES MPAC, MPAC +1 BY DP SCALE FACTOR
                XCH             MPAC            +2      # IN SFTEMP1, SFTEMP2.  THEN SCALE RESULT
                XCH             MPAC            +1      # BY B14.
                TS              MPAC
                TC              SCOUTEND


## Page 317
DP2OUTSF        TC              DPOUT                   # SCALES MPAC, MPAC +1 BY DP SCALE FACTOR
                TC              SCOUTEND



DP3OUTSF        TC              DPOUT                   # ASSUMES POINT BETWEEN BITS 7-8 OF HIGH
                TC              TPLEFT7                 # PART OF SFCON. SHIFTS RESULTS LEFT 7.
                TC              SCOUTEND



# DPOUT PICKS UP FRESH DATA FOR BOTH HI AND LO COMPONENTS.
# THIS IS NEEDED FOR TIME DISPLAY.

DPOUT           XCH             Q
                TS              OVFIND
                INDEX           MIXBR
                TC              +0
                TC              DPOUTNOR
                INDEX           DECOUNT                 # GET IDADDTAB ENTRY FOR COMPONENT K
                CA              IDAD1TEM                #     OF NOUN.
                MASK            LOW11                   # E SUBK
                TC              SETEBANK                # SET EB, LEAVE EADRES IN A.
DPOUTCOM        EXTEND
                INDEX           A                       # MIXED         NORMAL
                DCA             0                       # C(ESUBK)      C(E)
                DXCH            MPAC                    # C((E SUBK)+1)      C(E+1)
                TC              TPAGREE
                TC              DMP
                ADRES           SFTEMP1
                TC              OVFIND

DPOUTNOR        CA              NOUNADD                 # E
                TC              DPOUTCOM



# THIS IS A SPECIAL PURPOSE VERB FOR DISPLAYING A DOUBLE PRECISION AGC
# WORD AS 10 DECIMAL DIGITS ON THE AGC DISPLAY PANEL.  IT CAN BE USED WITH
# ANY NOUN, EXCEPT MIXED NOUNS. IT DISPLAYS THE CONTENTS
# OF THE REGISTER NOUNADD IS POINTING TO .  IF USED WITH NOUNS WHICH ARE
# INHERENTLY NOT DP SUCH AS THE CDU COUNTERS THE DISPLAY WILL BE GARBAGE.
# DISPLAY IS IN R1 AND R2 ONLY WITH THE SIGN IN R1.



DSPDPDEC        INDEX           MIXBR
                TC              +0
                TC              +2                      # NORMAL NOUN
                TC              DSPALARM

## Page 318
                EXTEND
                INDEX           NOUNADD
                DCA             0
                DXCH            MPAC
                CAF             R1D1
                TS              DSPCOUNT
                CAF             ZERO
                TS              MPAC            +2
                TC              TPAGREE
                TC              DSP2DEC
ENDDPDEC        TC              ENTEXIT

## Page 319
#          LOAD VERBS



                SETLOC          ENDRTOUT

ABCLOAD         CS              TWO
                TC              COMPTEST
                CAF             VBSP1LD
                TC              UPDATVB         -1
                TC              REQDATX
                CAF             VBSP2LD
                TC              UPDATVB         -1
                TC              REQDATY
                CAF             VBSP3LD
                TC              UPDATVB         -1
                TC              REQDATZ



PUTXYZ          CS              SIX                     # TEST THAT THE 3 DATA WORDS LOADED ARE
                TC              ALLDC/OC                # ALL DEC OR ALL OCT.
                EXTEND
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                CAF             ZERO                    # X COMP
                TC              PUTCOM
                INDEX           NOUNADD
                TS              0
                CAF             ONE                     # Y COMP
                TC              PUTCOM
                INDEX           NOUNADD
                TS              1
                CAF             TWO                     # Z COMP
                TC              PUTCOM
                INDEX           NOUNADD
                TS              2
                TC              LOADLV

ABLOAD          CS              ONE
                TC              COMPTEST
                CAF             VBSP1LD
                TC              UPDATVB         -1
                TC              REQDATX
                CAF             VBSP2LD
                TC              UPDATVB         -1
                TC              REQDATY
PUTXY           CS              FIVE                    # TEST THAT THE 2 DATA WORDS LOADED ARE
                TC              ALLDC/OC                # ALL DEC OR ALL OCT.
                EXTEND

## Page 320
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                CAF             ZERO                    # X COMP
                TC              PUTCOM
                INDEX           NOUNADD
                TS              0
                CAF             ONE                     # Y COMP
                TC              PUTCOM
                INDEX           NOUNADD
                TS              1
                TC              LOADLV

ALOAD           TC              REQDATX
                EXTEND
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                CAF             ZERO                    # X COMP
                TC              PUTCOM
                INDEX           NOUNADD
                TS              0
                TC              LOADLV

BLOAD           CS              ONE
                TC              COMPTEST
                CAF             BIT15                   # SET CLPASS FOR PASS0 ONLY
                TS              CLPASS
                TC              REQDATY
                EXTEND
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                CAF             ONE
                TC              PUTCOM
                INDEX           NOUNADD
                TS              1
                TC              LOADLV

CLOAD           CS              TWO
                TC              COMPTEST
                CAF             BIT15                   # SET CLPASS FOR PASS0 ONLY
                TS              CLPASS
                TC              REQDATZ
                EXTEND
                DCA             LODNNLOC                # SWITCH BANKS TO NOUN TABLE READING
                DXCH            Z                       # ROUTINE.
                CAF             TWO
                TC              PUTCOM
                INDEX           NOUNADD
                TS              2
                TC              LOADLV

## Page 321
LOADLV          CAF             ZERO
                TS              DECBRNCH
                CS              ZERO
                TS              LOADSTAT
                CS              VD1                     # TO BLOCK NUMERICAL CHARACTERS AND
                TS              DSPCOUNT                # CLEARS AFTER A COMPLETED LOAD
                TC              POSTJUMP                # AFTER COMPLETED LOAD, GO TO RECALTST
                CADR            RECALTST                # TO SEE IF THERE IS RECALL FROM ENDIDLE.

VBSP1LD         OCT             21                      # VB21 = ALOAD
VBSP2LD         OCT             22                      # VB22 = BLOAD
VBSP3LD         OCT             23                      # VB23 = CLOAD



ALLDC/OC        TS              DECOUNT                 # TESTS THAT DATA WORDS LOADED ARE EITHER
                CS              DECBRNCH                # ALL DEC OR ALL OCT. ALARMS IF NOT.
                TS              SR
                CS              SR
                CS              SR                      # SHIFTED RIGHT 2
                CCS             A                       # DEC COMP BITS IN LOW 3
                TCF             +2                      # SOME ONES IN LOW 3
                TC              Q                       # ALL ZEROS. ALL OCTAL.  OK
                AD              DECOUNT                 # DEC COMP = 7 FOR 3COMP, =6 FOR 2COMP
                EXTEND                                  # (BUT IT HAS BEEN DECREMENTED BY CCS)
                BZF             +2                      # MUST MATCH 6 FOR 3COMP, 5 FOR 2COMP.
                TC              GODSPALM
GOQ             TC              Q                       # ALL REQUIRED ARE DEC. OK



SFRUTNOR        XCH             Q                       # GETS SF ROUTINE NUMBER FOR NORMAL CASE
                TS              EXITEM                  # CANT USE L FOR RETURN. TSTFORDP USES L.
                CAF             MID5
                MASK            NNTYPTEM
                TC              RIGHT5
                TC              EXITEM                  # SF ROUTINE NUMBER IN A

SFRUTMIX        XCH             Q                       # GETS SF ROUTINE NUMBER FOR MIXED CASE
                TS              EXITEM
                INDEX           DECOUNT
                CAF             DISPLACE                # PUT TC GOQ, TC RIGHT5, OR TC LEFT5 IN L
                TS              L
                INDEX           DECOUNT
                CAF             LOW5                    # LOW5, MID5, OR HI5 IN A
                MASK            RUTMXTEM                # GET HI5, MID5, OR LOW5 OF RUTMXTAB ENTRY
                INDEX           L
                TC              0
# DO TC GOQ(DECOUNT=0), DO TC RIGHT5(DECOUNT=1), DO TC LEFT5(DECOUNT=2).
SFRET1          TC              EXITEM                  # SF ROUTINE NUMBER IN A

## Page 322
SFCONUM         XCH             Q                       # GETS 2X( SF CONSTANT NUMBER)
                TS              EXITEM
                INDEX           MIXBR
                TC              +0
                TC              CONUMNOR                # NORMAL NOUN
                INDEX           DECOUNT                 # MIXED NOUN
                CAF             DISPLACE
                TS              L                       # PUT TC GOQ, TC RIGHT5, OR TC LEFT5 IN L
                INDEX           DECOUNT
                CAF             LOW5
                MASK            NNTYPTEM
                INDEX           L
                TC              0
# DO TC GOQ(DECOUNT=0), DO TC RIGHT5(DECOUNT=1), DO TC LEFT5(DECOUNT=2).
SFRET           DOUBLE                                  # 2X(SF CONSTANT NUMBER ) IN A
                TC              EXITEM

DISPLACE        TC              GOQ
                TC              RIGHT5
                TC              LEFT5

CONUMNOR        CAF             LOW5                    # NORMAL NOUN ALWAYS GETS LOW 5 OF
                MASK            NNTYPTEM                # NNTYPTAB FOR SF CONUM.
                DOUBLE
                TC              EXITEM                  # 2X( SF CONSTANT NUMBER) IN A



PUTCOM          TS              DECOUNT
                XCH             Q
                TS              DECRET
                CAF             ZERO
                TS              OVFIND
                INDEX           DECOUNT
                XCH             XREGLP
                TS              MPAC            +1
                INDEX           DECOUNT
                XCH             XREG
                TS              MPAC
                INDEX           MIXBR
                TC              +0
                TC              PUTNORM                 # NORMAL NOUN
# IF MIXNOUN, PLACE ADDRESS FOR COMPONENT K INTO NOUNADD, SET EBANK BITS.
                INDEX           DECOUNT                 # GET IDADDTAB ENTRY FOR COMPONENT K
                CA              IDAD1TEM                #         OF NOUN.
                MASK            LOW11                   # (ECADR)SUBK FOR CURRENT COMP OF NOUN
                TC              SETNCADR                # ECADR INTO NOUNCADR. SETS EB, NOUNADD.
                EXTEND                                  # C(NOUNADD) IN A UPON RETURN
                SU              DECOUNT                 # PLACE (ESUBK)-K INTO NOUNADD
                TS              NOUNADD

## Page 323
                CCS             DECBRNCH
                TC              PUTDECSF                # +  DEC
                TC              SFRUTMIX                # +0  OCTAL
                TC              DPTEST
                TC              PUTCOM2                 # NO DP
                                                        # TEST FOR DP SCALE FOR OCT LOAD. IF SO,
                                                        # +0 INTO MAJOR PART. SET NOUNADD FOR
                                                        # LOADING OCTAL WORD INTO MINOR PART.
PUTDPCOM        INCR            NOUNADD                 # DP  (ESUBK)-K+1  OR  E+1
                CA              NOUNADD                 # NOUNADD NOW SET FOR MINOR PART
                ADS             DECOUNT                 # (ESUBK)+1  OR  E+1  INTO DECOUNT
                CAF             ZERO                    # NOUNADD SET FOR MINOR PART
                INDEX           DECOUNT
                TS              0               -1      # ZERO MAJOR PART(ESUBK OR E)
                TC              PUTCOM2

PUTNORM         TC              SETNADD                 # ECADR FROM NOUNCADR. SETS EB, NOUNADD.
                CCS             DECBRNCH
                TC              PUTDECSF                # +  DEC
                TC              SFRUTNOR                # +0  OCTAL
                TC              DPTEST
                TC              PUTCOM2         -4      # NO DP
                CAF             ZERO                    # DP
                TS              DECOUNT
                TC              PUTDPCOM

                CA              NNADTEM
                AD              ONE                     # IF NNADTEM = -1, CHANNEL TO BE SPECIFIED
                EXTEND
                BZF             CHANLOAD
PUTCOM2         XCH             MPAC
                TC              DECRET

                EBANK=          DSPCOUNT
GTSFINLC        2CADR           GTSFIN

CHANLOAD        XCH             MPAC
                EXTEND
                INDEX           NOUNCADR
                WRITE           0
                TC              LOADLV



# PUTDECSF FINDS MIXBR AND DECOUNT STILL SET FROM PUTCOM

PUTDECSF        TC              SFCONUM                 # 2X(SF CON NUMB) IN A
                TS              SFTEMP1

## Page 324
                EXTEND                                  # SWITCH BANKS TO SF CONSTANT TABLE
                DCA             GTSFINLC                # READING ROUTINE.
                DXCH            Z                       # LOADS SFTEMP1, SFTEMP2.
                INDEX           MIXBR
                TC              +0
                TC              PUTSFNOR
                TC              SFRUTMIX
                TC              PUTDCSF2
PUTSFNOR        TC              SFRUTNOR

PUTDCSF2        INDEX           A
                CAF             SFINTABR
                TC              BANKJUMP                # SWITCH BANKS FOR EXPANSHION ROOM
SFINTABR        CADR            DSPALARM                # ALARM IF DEC LOAD WITH OCTAL ONLY NOUN

                CADR            BINROUND
                CADR            DEGINSF
                CADR            ARTHINSF
                CADR            DPINSF
                CADR            DPINSF2
                CADR            OPTDEGIN
                CADR            DPINSF                  # SAME AS ARITHDP1
ENDRUTIN        EQUALS



# SCALE FACTORS FOR THOSE ROUTINES NEEDING THEM ARE AVAILABLE IN SFTEMP1.
# ALL SFIN ROUTINES USE MPAC MPAC+1. LEAVE RESULT IN A. END WITH TC DECRET



                SETLOC          ENDDPDEC +1

# DEGINSF APPLIES 1000/180 = 5.55555(10) = 5.43434(8)

DEGINSF         TC              DMP                     # SF ROUTINE FOR DEC DEGREES
                ADRES           DEGCON1                 # MULT BY 5.5 5(10)X2EXP-3
                CCS             MPAC            +1      # THIS ROUNDS OFF MPAC+1 BEFORE SHIFT
                CAF             BIT11                   # LEFT 3, AND CAUSES 360.00 TO OF/UF
                TC              +2                      # WHEN SHIFTED LEFT AND ALARM.
                CS              BIT11
                AD              MPAC            +1
                TC              2ROUND          +2
                TC              TPSL1                   # LEFT 1
DEGINSF2        TC              TPSL1                   # LEFT 2
                TC              TESTOFUF
                TC              TPSL1                   # RETURNS IF NO OF/UF (LEFT3)
                CCS             MPAC
                TC              SIGNFIX                 # IF +, GO TO SIGNFIX
                TC              SIGNFIX                 # IF +0, GO TO SIGNFIX
                COM                                     # IF -, USE -MAGNITUDE +1

## Page 325
                TS              MPAC                    # IF -0, USE +0
SIGNFIX         CCS             OVFIND
                TC              SGNTO1                  # IF OVERFLOW
                TC              ENDSCALE                # NO OVERFLOW/UNDERFLOW
                CCS             MPAC                    # IF UF FORCE SIGN TO 0 EXCEPT -180
                TC              CCSHOLE
                TC              NEG180
                TC              +1
                XCH             MPAC
                MASK            POSMAX
                TS              MPAC
ENDSCALE        TC              POSTJUMP
                CADR            PUTCOM2

NEG180          CS              POSMAX
                TC              ENDSCALE        -1

SGNTO1          CS              MPAC                    # IF OF FORCE SIGN TO 1
                MASK            POSMAX
                CS              A
                TC              ENDSCALE        -1

DEGCON1         2DEC            5.555555555 B-3

DEGCON2         2DEC            2.222222222 B-2

NEG.2           OCT             -06250                  # = .197753906  I.E. THE BIAS SCALED

ARTHINSF        TC              DMP                     # SCALES MPAC, +1 BY SFTEMP1, SFTEMP2.
                ADRES           SFTEMP1                 # ASSUMES POINT BETWEEN HI AND LO PARTS
                XCH             MPAC            +2      # OF SFCON. SHIFTS RESULTS LEFT BY 14.
                XCH             MPAC            +1      # (BY TAKING RESULTS FROM MPAC+1, MPAC+2)
                XCH             MPAC
                EXTEND
                BZF             BINROUND
                TC              DSPALARM                # TOO LARGE A LOAD
BINROUND        TC              2ROUND
                TC              TESTOFUF
                TC              ENDSCALE                # RETURNS IF NO OF/UF



OPTDEGIN        CCS             MPAC                    # OPTICS SCALING ROUTINE
                TC              +4
                TC              +3
                TC              DSPALARM                # REJECT NEGATIVE INPUT
                TC              DSPALARM                #         DITTO
OPDEGIN2        CAF             NEG.2                   # RANGE IS 90 DEG
                ADS             MPAC                    # SUBTRACT BIAS
                TC              DMP                     # MULT BY 100 / 45  B-2

## Page 326
                ADRES           DEGCON2
                CAF             BIT12                   # ROUND AS IN DEGINSF
                AD              MPAC            +1
                TC              2ROUND          +2
                TC              DEGINSF2

DPINSF          TC              DMP                     # SCALES MPAC, MPAC +1 BY SFTEMP1,
                ADRES           SFTEMP1                 # SFTEMP2.  STORES LOW PART OF RESULT
                XCH             MPAC            +2      # IN (E SUBK) +1 OR E+1
                DOUBLE
                TS              MPAC            +2
                CAF             ZERO
                AD              MPAC            +1
                TC              2ROUND          +2
                TC              TESTOFUF
                INDEX           MIXBR                   # RETURNS IF NO OF/UF
                TC              +0
                TC              DPINORM
                CA              DECOUNT                 # MIXEDNOUN
DPINCOM         AD              NOUNADD                 #     MIXED                NORMAL
                TS              Q                       #   E SUBK             E
                XCH             MPAC            +1
                INDEX           Q
                TS              1                       # PLACE LOW PART IN
                TC              ENDSCALE                # (E SUBK) +1    MIXED
DPINORM         CAF             ZERO                    # E +1         NORMAL
                TC              DPINCOM



DPINSF2         TC              DMP                     # ASSUMES POINT BETWEEN BITS 7-8 OF HIGH
                ADRES           SFTEMP1                 # PART OF SF CONST. DPINSF2 SHIFTS RESULTS
                TC              TPLEFT7                 # LEFT BY 7, ROUNDS MPAC+2 INTO MPAC+1.
                TC              DPINSF          +2



TPLEFT7         XCH             Q                       # OPERATES ON MPAC, MPAC+1, MPAC+2
                TS              SFTEMP2                 # CANT USE L FOR RETURN. TPSL1 USES L.
                CAF             SIX                     # LEFT BY 7
LEFT7COM        TS              SFTEMP1
                TC              TPSL1
                CCS             SFTEMP1
                TC              LEFT7COM
                TC              SFTEMP2

2ROUND          XCH             MPAC            +1
                DOUBLE

## Page 327
                TS              MPAC            +1
                TC              Q                       # IF MPAC+1 DOES NOT OF/UF
                AD              MPAC
                TS              MPAC
                TC              Q                       # IF MPAC DOES NOT OF/UF
                TS              OVFIND
2RNDEND         TC              Q



TESTOFUF        CCS             OVFIND                  # RETURNS IF NO OF/UF
                TC              DSPALARM                # OF
                TC              Q
                TC              DSPALARM                # UF

## Page 328
# MONITOR ALLOWS OTHER KEYBOARD ACTIVITY. IT IS ENDED BY VERB TERMINATE,
# ANY NVSUB CALL THAT PASSES THE DSPLOCK, OR ANOTHER MONITOR.

# MONITOR ACTION IS SUSPENDED, BUT NOT ENDED, BY ANY KEYBOARD ACTION,
# EXCEPT ERROR LIGHT RESET. IT BEGINS AGAIN WHEN KEY RELEASE IS PERFORMED.
# MONITOR SAVES THE NOUN AND APPROPRIATE DISPLAY VERB IN MONSAVE. IT SAVES
# NOUNCADR IN MONSAVE1, IF NOUN = MACHINE CADR TO BE SPECIFIED. BIT 15 OF
# MONSAVE1 IS THE KILL MONITOR SIGNAL (KILLER BIT).

# MONSAVE INDICATES IF MONITOR IS ON (+=ON, +0=OFF)
# IF MONSAVE IS +, MONITOR ENTERS NO REQUEST, BUT TURNS KILLER BIT OFF.
# IF MONSAVE IS +0, MONITOR ENTERS REQUEST AND TURNS KILLER BIT OFF.

# NVSUB  AND VB=TERMINATE TURN KILL MONITOR BIT ON.

# IF KILLER BIT IS ON, MONREQ ENTERS NO FURTHER REQUESTS, ZEROS MONSAVE
# AND MONSAVE1 (TURNING OFF KILLER BIT).

# MONITOR DOSENT TEST FOR MATBS SINCE NVSUB CAN HANDLE INTERNAL MATBS NOW
                SETLOC          ENDRUTIN

MONITOR         CS              BIT15
                MASK            NOUNCADR
MONIT1          TS              MPAC            +1      # TEMP STORAGE
                CAF             LOW6
                MASK            VERBREG
                TC              LEFT5
                TS              CYL
                XCH             CYL
                AD              NOUNREG
                TS              MPAC                    # TEMP STORAGE
                CS              GRABLOCK                # NEITHER CASE SEARCHES LIST.
                AD              TWO
                CCS             A
                TC              RELDSP1                 # GRABLOCK=0,1, +0 INTO DSPLOCK AND
                TC              +4                      # TURN OFF KEY RLSE LIGHT.
                TC              CCSHOLE
                CAF             ZERO                    # GRABLOCK=2, +0 INTO DSPLOCK AND
                TS              DSPLOCK                 # LEAVE KEY RLSE LIGHT ALONE
                INHINT
                CCS             MONSAVE
                TC              +5                      # IF MONSAVE WAS +, NO REQUEST
                CAF             ONE                     # IF MONSAVE WAS 0, REQUEST MONREQ
                TC              WAITLIST
                EBANK=          DSPCOUNT
                2CADR           MONREQ

                DXCH            MPAC                    # PLACE MONITOR VERB AND NOUN INTO MONSAVE

## Page 329
                DXCH            MONSAVE                 # ZERO THE KILL MONITOR BIT
                RELINT
                TC              ENTRET



MONREQ          TC              LODSAMPT                # CALLED BY WAITLIST
                CCS             MONSAVE1                # TIME IS SNATCHED IN RUPT FOR NOUN 65
                TC              +4                      # IF KILLER BIT = 0, ENTER REQUESTS
                TC              +3                      # IF KILLER BIT = 0, ENTER REQUESTS
                TC              KILLMON                 # IF KILLER BIT = 1, NO REQUESTS
                TC              KILLMON                 # IF KILLER BIT = 1, NO REQUESTS
                CAF             MONDEL
                TC              WAITLIST                # ENTER WAITLIST REQUEST FOR MONREQ
                EBANK=          DSPCOUNT
                2CADR           MONREQ
                CAF             CHRPRIO
                TC              NOVAC                   # ENTER EXEC REQUEST FOR MONDO
                EBANK=          DSPCOUNT
                2CADR           MONDO

                TC              TASKOVER

KILLMON         CAF             ZERO                    # ZERO MONSAVE AND TURN KILLER BIT OFF
                TS              MONSAVE
                TS              MONSAVE1                # TURN OFF KILL MONITOR BIT.
                TC              TASKOVER



MONDEL          OCT             144                     # FOR 1 SEC MONITOR INTERVALS



MONDO           CCS             MONSAVE1                # CALLED BY EXEC
                TC              +4                      # IF KILLER BIT = 0, CONTINUE
                TC              +3                      # IF KILLER BIT = 0, CONTINUE
                TC              ENDOFJOB                # IN CASE TERMINATE CAME SINCE LAST MONREQ
                TC              ENDOFJOB                # IN CASE TERMINATE CAME SINCE LAST MONREQ
                CCS             DSPLOCK
                TC              MONBUSY                 # NVSUB IS BUSY
                CAF             LOW6                    # NVSUB IS AVAILABLE
                MASK            MONSAVE
                TS              NVTEMP
                TC              NVSUBMON                # PLACE NOUN INTO NOUNREG AND DISPLAY IT
                TC              ENDOFJOB                # IN CASE OF ALARM DURING DISPLAY
                CAF             MONMASK
                MASK            MONSAVE                 # CHANGE MONITOR VERB TO DISPLAY VERB
                TC              RIGHT5

## Page 330
                TS              CYR
                XCH             CYR
                TS              VERBREG
                CAF             MONBACK                 # SET RETURN TO PASTEVB AFTER DATA DISPLAY
                TS              ENTRET
                CS              BIT15
                MASK            MONSAVE1                # PUT ECADR INTO MPAC +2.  INTMCTBS WILL
                TS              MPAC            +2      # DISPLAY IT AND SET NOUNCADR, NOUNADD,
ENDMONDO        TC              TESTNN                  # EBANK.

                SETLOC          ENDRMODF

PASTEVB         CAF             MIDSIX
                MASK            MONSAVE
                TS              NVTEMP                  # PLACE MONITOR VERB INTO VERBREG AND
                TC              NVSUBMON                #      DISPLAY IT.
                TC              +1                      # IN CASE OF ALARM DURING DISPLAY
ENDPASTE        TC              ENDOFJOB

MIDSIX          OCT             07700



                SETLOC          ENDMONDO        +1
MONMASK         OCT             700
MONBACK         ADRES           PASTEVB

MONBUSY         TC              RELDSPON                # TURN KEY RELEASE LIGHT
                TC              ENDOFJOB



# DSPFMEM IS USED TO DISPLAY (IN OCTAL) ANY FIXED REGISTER.
# IT IS USED WITH NOUN = MACHINE CADR TO BE SPECIFIED. THE FCADR OF THE
# DESIRED LOCATION IS THEN PUNCHED IN. IT HANDLES F/F ( FCADR 4000-7777)

DSPFMEM         CAF             R1D1                    # IF F/F, DATACALL USES BANK 02 OR 03.
                TS              DSPCOUNT
                CA              NOUNCADR                # ORIGINAL FCADR LOADED STILL IN NOUNCADR.
                TC              DATACALL
                TC              DSPOCTWD
                TC              ENDOFJOB

## Page 331
#  DSPDECWD CONVERTS C(MPAC) AND C(MPAC+1) TO A SIGN AND 5 CHAR DECIMAL
# STARTING IN LOC SPECIFIED IN DSPCOUNT

                SETLOC          TESTOFUF        +4
DSPDECWD        XCH             Q                       # USES SHORTMP THROUGHOUT
                TS              WDRET                   # CANT USE L FOR RETURN.+ON USES L.
                CCS             MPAC
                TC              +7
                TC              +6
                AD              ONE
                TS              MPAC
                TC              -ON
                CS              MPAC            +1
                TC              +3
                TC              +ON
                XCH             MPAC            +1
                AD              DECROUND
                TS              MPAC            +1
                CAF             ZERO
                AD              MPAC
                TS              MPAC
                TC              +4
                CAF             POSMAX
                TS              MPAC
                TS              MPAC            +1
                CAF             FOUR
DSPDCWD1        TS              WDCNT
                CAF             BINCON
                TC              SHORTMP
TRACE1          INDEX           MPAC
                CAF             RELTAB
                MASK            LOW5
                TS              CODE
                CAF             ZERO
                XCH             MPAC            +2
                XCH             MPAC            +1
                TS              MPAC
                XCH             DSPCOUNT
TRACE1S         TS              COUNT
                CCS             A                       # DECREMENT DSPCOUNT EXCEPT AT +0
                TS              DSPCOUNT
                TC              DSPIN
                CCS             WDCNT
                TC              DSPDCWD1
                CS              VD1
                TS              DSPCOUNT
                TC              WDRET

DECROUND        OCT             02476

## Page 332
# DSP2DEC CONVERTS C(MPAC) AND C(MPAC+1) INTO A SIGN AND 10 CHAR DECIMAL
# STARTING IN THE LOC SPECIFIED IN DSPCOUNT.

DSP2DEC         XCH             Q                       # MUST USE SAME RETURN AS DSPDECWD
                TS              WDRET
                CAF             ZERO
                TS              CODE
                CAF             THREE
                TC              11DSPIN                 # -R2 OFF
                CAF             FOUR
                TC              11DSPIN                 # +R2 OFF
                CCS             MPAC
                TC              +8D
                TC              +7
                AD              ONE
                TS              MPAC
                TC              -ON
                CS              MPAC            +1
                TS              MPAC            +1
                TC              +2
                TC              +ON
                CAF             R2D1
END2DEC         TC              DSPDCWD1



                SETLOC          DSPFMEM         +6
# DSPOCTWD DISPLAYS C(A) UPON ENTRY AS A 5 CHAR OCT STARTING IN THE DSP
# CHAR SPECIFIED IN DSPCOUNT. IT STOPS AFTER 5 CHAR HAVE BEEN DISPLAYED.

DSPOCTWD        TS              CYL
                XCH             Q
                TS              WDRET                   # MUST USE SAME RETURN AS DSP2BIT.
                CAF             BIT14                   # TO BLANK SIGNS
                ADS             DSPCOUNT
                CAF             FOUR
WDAGAIN         TS              WDCNT
                CS              CYL
                CS              CYL
                CS              CYL
                CS              A
                MASK            DSPMSK
                INDEX           A
                CAF             RELTAB
                MASK            LOW5
                TS              CODE
                XCH             DSPCOUNT
                TS              COUNT
                CCS             A                       # DECREMENT DSPCOUNT EXCEPT AT +0
                TS              DSPCOUNT

## Page 333
                TC              POSTJUMP
                CADR            DSPOCTIN
OCTBACK         CCS             WDCNT
                TC              WDAGAIN                 # +
DSPLV           CS              VD1                     # TO BLOCK NUMERICAL CHARACTERS, CLEARS,
                TS              DSPCOUNT                # AND SIGNS AFTER A COMPLETED DISPLAY.
                TC              WDRET

DSPMSK          =               SEVEN



# DSP2BIT DISPLAYS C(A) UPON ENTRY AS A 2 CHAR OCT BEGINNING IN THE DSP
# LOC SPECIFIED IN DSPCOUNT BY PRE CYCLING RIGHT C(A) AND USING THE LOGIC
# OF THE 5 CHAR OCTAL DISPLAY

DSP2BIT         TS              CYR
                XCH             Q
                TS              WDRET                   # CANT USE L AS RETURN. UPDATNN USES L.
                CAF             ONE
                TS              WDCNT
                CS              CYR
                CS              CYR
                XCH             CYR
                TS              CYL
                TC              WDAGAIN         +5



# FOR DSPIN PLACE 0/25 OCT INTO COUNT, 5 BIT RELAY CODE INTO CODE. BOTH
# ARE DESTROYED. IF BIT14 OF COUNT IS 1, SIGN IS BLANKED WITH LEFT CHAR.
# FOR DSPIN1 PLACE 0,1 INTO BIT11 OF CODE, 2 INTO COUNT, REL ADDRESS OF
# DSPTAB ENTRY INTO DSREL.

                SETLOC          END2DEC         +1

DSPIN           XCH             Q                       # CANT USE L FOR RETURN, SINCE MANY OF THE
                TS              DSEXIT                  # ROUTINES CALLING DSPIN USE L AS RETURN.
                CAF             LOW5
                MASK            COUNT
                TS              SR
                XCH             SR
                TS              DSREL
                CAF             BIT1
                MASK            COUNT
                CCS             A
                TC              +2                      # LEFT IF COUNT IS ODD
                TC              DSPIN1          -1      # RIGHT IF COUNT IS EVEN
                XCH             CODE
                TC              SLEFT5                  # DOES NOT USE CYL

## Page 334
                TS              CODE
                CAF             BIT14
                MASK            COUNT
                CCS             A
                CAF             TWO                     # BIT14 = 1, BLANK SIGN
                AD              ONE                     # BIT14 = 0, LEAVE SIGN ALONE
                TS              COUNT                   # +0 INTO COUNT FOR RIGHT
                                                        # +1 INTO COUNT FOR LEFT (SIGN LEFT ALONE)
                                                        # +3 INTO COUNT FOR LEFT (TO BLANK SIGN)
DSPIN1          INHINT
                INDEX           DSREL
                CCS             DSPTAB
                TC              +2                      # IF +
                TC              CCSHOLE
                AD              ONE                     # IF -
                TS              DSMAG
                INDEX           COUNT
                MASK            DSMSK
                EXTEND
                SU              CODE
                EXTEND
                BZF             DSLV                    # SAME
DFRNT           INDEX           COUNT
                CS              DSMSK                   # MASK WITH 77740,76037, OR 75777
                MASK            DSMAG
                AD              CODE
                CS              A
                INDEX           DSREL
                XCH             DSPTAB
                EXTEND
                BZMF            DSLV                    # DSPTAB ENTRY WAS -
                INCR            NOUT                    # DSPTAB ENTRY WAS +
DSLV            RELINT
                TC              DSEXIT

DSMSK           OCT             37
                OCT             1740
                OCT             2000
                OCT             3740



# FOR 11DSPIN, PUT REL ADDRESSS OF DSPTAB ENTRY INTO A, 1 IN BIT11 OR 0 IN
# BIT11 OF CODE.

11DSPIN         TS              DSREL
                CAF             TWO
                TS              COUNT
                XCH             Q                       # MUST USE SAME RETURN AS DSPIN
                TS              DSEXIT

## Page 335
                TC      DSPIN1



DSPOCTIN        TC              DSPIN                   # SO DSPOCTWD DOESNT USE SWCALL
                CAF             +2
                TC              BANKJUMP
ENDSPOCT        CADR            OCTBACK



# DSPALARM FINDS TC NVSUBEND IN ENTRET FOR NVSUB INITIATED ROUTINES.
# ABORT WITH 01501.
# DSPALARM FINDS TC ENDOFJOB IN ENTRET FOR KEYBOARD INITIATED ROUTINES.
# DO TC ENTRET.

CHARALRM        CAF             ENDINST                 # ALARMS WHICH MUST DO ENDOFJOBS COME
                TS              ENTRET                  # HERE. ALLOWS ENTRET TO BE TEMP ERASABLE

DSPALARM        TC              FALTON                  # TURN ON OPERATOR ERROR LIGHT
                CS              NVSBENDL
                AD              ENTEXIT
                EXTEND
                BZF             +2                      # NVSUB INITIATED. ABORT
                TC              ENTEXIT                 # NOT NVSUB INITIATED.
                TC              ABORT
                OCT             01501
NVSBENDL        TC              NVSUBEND



# MMCHANG USES NOUN DISPLAY UNTIL ENTER. THEN IT USES MODE DISP.
# IT GOES TO MODROUT WITH THE NEW M M CODE IN A, BUT NOT DISPLAYED IN
# M M LIGHTS.

                SETLOC          DSP2BIT         +10D

MMCHANG         TC              REQMM
                CAF             ZERO
                XCH             NOUNREG
                TS              MPAC
                CAF             ND1
                TS              DSPCOUNT
                TC              BANKCALL
                CADR            2BLANK
                CA              MPAC
                TC              POSTJUMP
                CADR            MODROUTB                # GO THRU STANDARD LOC.

## Page 336
MODROUTB        =               DSPALARM		# **FIX LATER**
REQMM           CS              Q
                TS              REQRET
                CAF             ND1
                TS              DSPCOUNT
                CAF             ZERO
                TS              NOUNREG
                TC              BANKCALL
                CADR            2BLANK
                TC              FLASHON
                TC              ENTEXIT



# VBRQEXEC ENTERS REQUEST TO EXEC     FOR ANY ADDRESS WITH ANY PRIORITY.
# IT DOES ENDOFJOB AFTER ENTERING REQUEST. DISPLAY SYST IS RELEASED.
# IT ASSUMES NOUN 26 HAS BEEN PRELOADED WITH
# COMPONENT 1  PRIORITY(BITS 10-14) BIT1=0 FOR NOVAC, BIT1=1 FOR FINDVAC.
# COMPONENT 2  JOB ADRES (12 BIT )
# COMPONENT 3  BBCON

VBRQEXEC        CAF             BIT1
                MASK            DSPTEM1
                CCS             A
                TC              SETVAC                  # IF BIT1 = 1, FINDVAC
                CAF             TCNOVAC                 # IF BIT1 = 0, NOVAC
REQEX1          TS              MPAC                    # TC NOVAC OR TC FINDVAC INTO MPAC
                CS              BIT1
                MASK            DSPTEM1
                TS              MPAC            +4      # PRIO INTO MPAC+4 AS A TEMP
REQUESTC        TC              RELDSP
                CA              ENDINST
                TS              MPAC            +3      # TC ENDOFJOB INTO MPAC+3
                EXTEND
                DCA             DSPTEM1         +1      # JOB ADRES INTO MPAC+1
                DXCH            MPAC            +1      # BBCON INTO MPAC+2
                CA              MPAC            +4      # PRIO IN A
                INHINT
                TC              MPAC

SETVAC          CAF             TCFINDVC
                TC              REQEX1

# VBRQWAIT ENTERS REQUEST TO WAITLIST FOR ANY ADDRESS WITH ANY DELAY.
# IT DOES ENDOFJOB AFTER ENTERING REQUEST.DISPLAY SYST IS RELEASED.
# IT ASSUMES NOUN 26 HAS BEEN PRELOADED WITH
# COMPONENT 1  DELAY (LOW BITS)
# COMPONENT 2  TASK ADRES (12 BIT)
# COMPONENT 3  BBCON

## Page 337
VBRQWAIT        CAF             TCWAIT
                TS              MPAC                    # TC WAITLIST INTO MPAC
                CA              DSPTEM1                 # TIME DELAY
ENDRQWT         TC              REQUESTC        -1

# REQUESTC WILL PUT TASK ADRES INTO MPAC+1, BBCON INTO MPAC+2,
# TC ENDOFJOB INTO MPAC+3. IT WILL TAKE TIME DELAY OUT OF MPAC+4 AND
# LEAVE IT IN A, INHINT AND TC MPAC.



                SETLOC          NVSBENDL        +1
VBPROC          CAF             ONE                     # PROCEED WITHOUT DATA
                TS              LOADSTAT
                TC              RELDSP
                TC              FLASHOFF
                TC              RECALTST                # SEE IF THERE IS ANY RECALL FROM ENDIDLE



VBTERM          TC              KILMONON                # TURN ON KILL MONITOR BIT
                CS              ONE
                TC              VBPROC          +1      # TERM VERB SETS LOADSTAT NEG



# FLASH IS TURNED OFF ONLY BY PROCEED WITHOUT DATA, TERMINATE, END OF LOAD



# VBRELDSP TURNS OFF RELEASE DISPLAY SYSTEM LIGHT(AND SEARCHES LIST ONLY
# IF THIS LIGHT WAS TURNED ON BY NVSUBUSY), AND TURNS OFF UPACT LIGHT.

VBRELDSP        CS              BIT3
                EXTEND
                WAND            DSALMOUT                # TURN OFF UPACT LIGHT
                TC              RELDSP                  # SEARCHES LIST
                TC              ENDOFJOB



# BUMP SHIFTS WORD DISPLAYED IN R2 TO R3, R1 TO R2. IT BLANKS R1.

BUMP            CAF             FIVE                    # R2D5
                TS              DSPCOUNT
                TS              COUNT
                CAF             ONE                     # SHIFT DATA OF R2 TO R3, R1 TO R2
                MASK            COUNT
                XCH             COUNT                   # +0 INTO COUNT IF EVEN (RIGHT)
                TS              SR                      # +1 INTO COUNT IF ODD (LEFT)

## Page 338
                XCH             SR                      # DSREL IN A
                INDEX           A
                CCS             DSPTAB
                TC              +2
                TC              CCSHOLE
                AD              ONE                     # DSMAG IN A
                INDEX           COUNT
                MASK            DSMSK
                INDEX           COUNT
                TC              +1
                TC              +2                      # EVEN(RIGHT)  OK
                TC              RIGHT5                  # ODD(LEFT)  SHIFT RIGHT
                TS              CODE
                CS              FIVE
                AD              DSPCOUNT                # DSPCOUNT-5
                CCS             A                       # TO PREVENT -0
                AD              ONE
                TC              +2
                TC              CCSHOLE
                TS              COUNT
                TC              DSPIN                   # CODE ALREADY IN CODE
                CS              DSPCOUNT
                AD              R1D1                    # OCT 16
                CCS             A
                XCH             DSPCOUNT                # +, DSPCOUNT L/ OCT 16
                AD              ONE                     # INCREMENT DSPCOUNT
                TC              BUMP            +1

SWSGN           CAF             ZERO                    # -0, DSPCOUNT= OCT 16. DO SIGN SHIFT
                TS              DSPCOUNT
                AD              SWTAB           +2      # OCT 3
                INDEX           A                       # PICKUP ORDER , DSREL=3,4,5,6.
                CCS             DSPTAB                  #                  (-R2,+R2,-R1,+R1)
                TC              +2
                TC              CCSHOLE
                AD              ONE
                MASK            BIT11
                TS              CODE
                INDEX           DSPCOUNT
                CAF             SWTAB                   # PUT AWAY ORDER, DSREL= 0,1,3,4.
                TC              11DSPIN                 #                  (-R3,+R3,-R2,+R2.)
                CS              DSPCOUNT
                AD              SWTAB           +2      # OCT 3
                CCS             A
                XCH             DSPCOUNT                # +, DSPCOUNT L/ 3
                AD              ONE                     # INCREMENT DSPCOUNT
                TC              SWSGN           +1
                CAF             R1D1                    # -0,       DSPCOUNT = 3
                TS              DSPCOUNT
                TC              5BLANK                  # BLANKS R1

## Page 339
                TC              ENTEXIT

SWTAB           OCT             0                       # -R3
                OCT             1                       # +R3
                OCT             3                       # -R2
                OCT             4                       # +R2

## Page 340
# NVSUB IS USED FOR SUBROUTINE CALLS FROM WITHIN COMPUTER. IT CAN BE
# USED TO DO ANY THING THE KEYBOARD CAN CALL. PLACE ...VVVVVVNNNNNN
# INTO A.      V-S ARE 6BIT VERB CODE. N-S , 6 BIT NOUN CODE.

# NVSUB CAN BE USED WITH MACH CADR TO BE SPEC BY PLACING THE CADR INTO
# MPAC+2 BEFORE THE STANDARD NVSUB CALL.

#  NVSUB RETURNS TO 2+ CALLING LOC AFTER PERFORMING TASK, IF DISPLAY
# SYSTEM IS AVAILABLE. THE NEW NOUN AND VERB CODES ARE DISPLAYED.
# IF V:S =0, THE NEW NOUN CODE IS DISPLAYED ONLY(RETURN WITH NO FURTHER
# ACTION). IF N-S =0, THE NEW VERB CODE IS DISPLAYED ONLY(RETURN WITH NO
# FURTHER ACTION).

# IT RETURNS TO 1+ CALLING LOC WITHOUT PERFORMING TASK, IF DISPLAY
# SYSTEM IS BLOCKED (NOTHING IS DISPLAYED IN THIS CASE).
# IT DOES TC ABORT (WITH OCT 01501) IF IT ENCOUNTERS A DISPLAY PROGRAM
# ALARM CONDITION BEFORE RETURN TO CALLER.

# THE DISPLAY SYSTEM IS BLOCKED BY THE DEPRESSION OF ANY
# KEY, EXCEPT ERROR LIGHT RESET. ALSO BY ENDIDLE.
#      IT IS RELEASED BY SPECIAL VERB = RELEASE DISPLAY, ALL GO TO VERBS.
# PROCEED WITHOUT DATA, TERMINATE, INITIALIZE EXECUTIVE,
# RECALL PART OF RECALTST IF ENDIDLE WAS USED,
# IN RECALTST IF NVSUB INITIATED LOAD AND ENDIDLE WAS NOT USED,
# VB = REQUEST EXECUTIVE, VB = REQUEST WAITLIST,
# MONITOR SET UP.

# A NVSUB CALL THAT PASSES DSPLOCK ENDS OLD MONITOR.

# DSPLOCK IS THE INTERLOCK FOR USE OF KEYBOARD AND DISPLAY SYSTEM WHICH
# LOCKS OUT INTERNAL USE WHENEVER THERE IS EXTERNAL KEYBOARD ACTION.

# NVSUB IN FIXED-FIXED PLACES 2+CALLING LOC INTO NVQTEM, TC NVSUBEND INTO
# ENTRET. (THIS WILL RESTORE OLD CALLING BANK BITS)

                SETLOC          MIDSIX          +1
NVSUB           TS              NVTEMP                  # IN FIXED FIXED
                CCS             DSPLOCK
                TC              Q                       # DSP SYST BLOCKED. RET TO 1+ CALLING LOC
                CA              Q                       # DSP SYST AVAILABLE
                AD              ONE
                TS              NVQTEM                  # 2+ CALLING LOC INTO NVQTEM
                TC              KILMONON                # TURN ON KILL MONITOR BIT
NVSUBCOM        CAF             NVSBBBNK

                XCH             BBANK
                TS              NVBNKTEM
                TC              NVSUBB                  # GO TO NVSUB1 THRU STANDARD LOC
                EBANK=          DSPCOUNT
NVSBBBNK        BBCON           NVSUB1

## Page 341
NVSUBMON        CA              Q                       # MONDO COMES HERE
                AD              ONE
                TS              NVQTEM                  # 2 + CALLING LOC INTO NVQTEM
                TC              NVSUBCOM

NVSUBEND        DXCH            NVQTEM                  # NVBNKTEM MUST = NVQTEM+1
                DXCH            Z                       # DTCB

                SETLOC          ENDRQWT         +1

NVSUB1          CAF             ENTSET                  # IN BANK
                TS              ENTRET                  # SET RETURN TO NVSUBEND
                CAF             LOW6
                MASK            NVTEMP
                TS              MPAC                    # TEMP STORAGE
                CAF             MID6
                MASK            NVTEMP
                TC              RIGHT5
                TS              CYR
                XCH             CYR
                TS              MPAC            +1      # TEMP STORAGE
                CCS             MPAC                    # TEST NOUN
                TC              +4                      # IF NOUN NOT +0, GO ON
                XCH             MPAC            +1
                TC              UPDATVB         -1      # IF NOUN = +0, DISPLAY VERB, THEN RETURN
ENTSET          TC              NVSUBEND
                CCS             MPAC            +1      # TEST VERB
                TC              +4                      # IF VERB NOT +0, GO ON
                XCH             MPAC
                TC              UPDATNN         -1      # IF VERB = +0, DISPLAY NOUN. THEN RETURN
                TC              NVSUBEND
                XCH             MPAC            +1
                TC              UPDATVB         -1      # IF BOTH NOUN AND VERB NOT +0, DISPLAY
                XCH             MPAC                    # BOTH AND GO TO ENTPAS0
                TC              UPDATNN         -1
                CAF             ZERO
                TS              LOADSTAT                # SET FOR WAITING FOR DATA CONDITION
                TS              CLPASS
                TC              ENTPAS0

# IF INTERNAL MACH CADR TO BE SPECIFIED, MPAC+2 WILL BE PLACED INTO
# NOUNCADR IN ENTPAS0 (INTMCTBS ).



LOW6            OCT             77
MID6            OCT             7700

## Page 342
                SETLOC          NVSUBEND        +2
KILMONON        CS              BIT15                   # FORCE BIT 15 OF MONSAVE1 TO 1.
                INHINT                                  #         THIS IS THE KILL MONITOR BIT.
                MASK            MONSAVE1
                AD              BIT15
                TS              MONSAVE1
                RELINT
                TC              Q



# LOADSTAT  +0 INACTIVE (WAITING FOR DATA). SET BY NVSUB
#           +1  PROCEED NO DATA. SET BY SPECIAL VERB
#          -1 TERMINATE   SET BY SPECIAL VERB
#          -0 DATA IN   SET BY END OF LOAD ROUTINE



# L  TC ENDIDLE  (FIXED FIXED)
# ROUTINES THAT REQUEST LOADS THROUGH NVSUB SHOULD USE ENDIDLE WHILE
# WAITING FOR THE DATA TO BE LOADED. ENDIDLE PUTS CURRENT JOB TO SLEEP.
# ENDIDLE CANNOT BE CALLED FROM ERASABLE MEMORY, SINCE JOBSLEEP AND
# JOBWAKE CAN HANDLE ONLY FIXED MEMORY.
# RECALTST TESTS LOADSTAT AND WAKES JOB UP TO,
# L+1      FOR TERMINATE
# L+2      FOR PROCEED WITHOUT DATA
# L+3      FOR DATA IN
# IT DOES NOTHING     IF LOADSTAT INDICATES WAITING FOR DATA.

ENDIDLE         CAF             ONE
                TS              DSPLOCK
                LXCH            FBANK
                XCH             Q
                DXCH            BUF2
                TC              MAKECADR
                TS              CADRSTOR
                TC              JOBSLEEP



ENDINST         TC              ENDOFJOB

# DATAWAIT IS AN ALTERNATIVE TO ENDIDLE, IT RETURNS IMMEDIATELY IF
# LOADSTAT INDICATES THAT DATA IS ALREADY IN, OR PROCEED OR TERMINATE HAS
# BEEN EXECUTED. RETURN FORMAT IS SAME AS FOR ENDIDLE.
# DATAWAIT CANNOT BE CALLED FROM ERASABLE MEMORY, SINCE JOBSLEEP
# AND JOBWAKE CAN HANDLE ONLY FIXED MEMORY.
# DATAWAIT SHOULD BE USED ONLY AFTER REQUESTING A LOAD VERB.

DATAWAIT        CCS             LOADSTAT

## Page 343
                TCF             DATWAIT1                # PROCEED. RETURN TO L+2.
                TCF             ENDIDLE                 # STILL WAITING. GO TO SLEEP.
                TC              Q                       # TERMINATE. RETURN TO L+1.
                INDEX           Q                       # DATA IN. RETURN TO L+3.
                TC              2
DATWAIT1        INDEX           Q                       # RETURN TO L+2.
                TC              1

# DATAWAIT DOES NOT RELEASE DISPLAY SYST. IT IS RELEASED AT END OF NVSUB
# INITIATED LOAD, IF ENDIDLE WAS NOT USED.



                SETLOC          MID6            +1
# DSPMM PLACE MAJOR MODE CODE INTO MODREG

DSPMM1          CAF             MD1                     # GETS HERE THRU DSPMM (STANDARD LEAD IN)
                XCH             DSPCOUNT
                TS              DSPMMTEM                # SAVE DSPCOUNT
                CA              MODREG
                LXCH            Q
                TC              DSP2BIT
                XCH             DSPMMTEM                # RESTORE DSPCOUNT
                TS              DSPCOUNT
DSPMMEND        TC              L



# RECALTST IS ENTERED DIRECTLY AFTER DATA IS
# LOADED, TERMINATE VERB IS EXECUTED, OR THE PROCEED WITHOUT DATA VERB IS
# EXECUTED. IT WAKES UP JOB THAT DID TC ENDIDLE.

# IF NVSUB INITIATED LOAD, AND ENDIDLE WAS NOT USED, THEN IT RELEASES
# DISPLAY SYST. (NEEDED FOR DATAWAIT)

                SETLOC          SWTAB           +4

RECALTST        CCS             CADRSTOR
                TC              RECAL1
                TC              ENDOFJOB                # NORMAL EXIT IF KEYBOARD INITIATED
                TC              RECAL1
                TS              CADRSTOR                # -0. CONCLUSION OF NVSUB INITIATED LOAD.
                TC              RECAL3                  # +0 INTO CADRSTOR. RELEASE DISPLAY,
                                                        #    AND ENDOFJOB. NEEDED FOR DATAWAIT.
RECAL1          CAF             ZERO
                XCH             CADRSTOR
                INHINT
                TC              JOBWAKE
                CCS             LOADSTAT
                TC              DOPROC                  # + PROCEED WITHOUT DATA

## Page 344
                TC              ENDOFJOB                # PATHALOGICAL CASE EXIT
                TC              DOTERM                  # -   TERMINATE
                CAF             TWO
RECAL2          INDEX           LOCCTR
                AD              LOC                     # LOC IS + FOR BASIC JOBS
                INDEX           LOCCTR
                TS              LOC
                RELINT
RECAL3          TC              RELDSP1                 # DOES NOT SEARCH LIST
                TC              ENDOFJOB

DOTERM          CAF             ZERO
                TC              RECAL2

DOPROC          CAF             ONE
                TC              RECAL2

## Page 345
# THE FOLLOWING REFERS TO THE NOUN TABLES



# COMPONENT CODE NUMBER           INTERPRETATION
#
# 00000                           1 COMPONENT
# 00001                           2 COMPONENT (EACH S P)
# 00010                           3 COMPONENT (EACH SP)



# SF ROUTINE CODE NUMBER          INTERPRETATION
#
# 00000    OCTAL ONLY
# 00001    STRAIGHT FRACTIONAL
# 00010    DEGREES (XXX.XX)
# 00011    ARITHMETIC SF
# 00100    ARITH DP1   OUT(MULT BY 2/14 AT END)     IN (STRAIGHT)
# 00101    ARITH DP2   OUT (STRAIGHT)               IN (SL 7 AT END)
# 00110    OPTICS DEGREES(XX.XXX MAX 89.999) OR (XXX.XX MAX 179.99)
# 00111    ARITH DP3   OUT (SL 7 AT END)        IN ( STRAIGHT)
# END OF SF ROUTINE CODE NUMBERS

# SF CONSTANT CODE NUMBER         INTERPRETATION

# 00000                           WHOLE
# 00000                           TIME SEC(XXX.XX)SAME AS WHOLE(ARITH DP1)
# 00001                           TIME HOURS(XXX.XX) USE ARITH DP2
# 00010                           DEGREES
# 00010                           OPTICS DEGREES
# 00011                           GYRO DEGREES (XX.XXX)  USE ARITHDP3
# 00100                           GYRO BIAS DRIFT .BBXXXXX MILLIRAD/SEC
# 00101                           GYRO AXIS ACCEL. DRIFT
#                                 .BBXXXXX (MILLIRAD/SEC) / (CM/SEC SEC)
# 00110                           PIPA BIAS X.XXXX CM/SEC SEC
# 00111                           PIPA SCALE FACTOR ERROR
#                                     XXXXX. PARTS/MILLION
# 01000                           POSITION(XXXX.X KILOMETERS) USE ARITHDP3
# 01001                           VELOCITY(XXXX.X METERS/SEC) USE ARITHDP2
# 01010                           TIME HOURS(XXX.XX)WEEKS INSIDE(ARITHDP2)
# 01011                           ELEVATION DEGREES(89.999MAX) USE ARITH
# 01100                           RENDEZVOUS RADAR RANGE(XXXXXB.FEET)
#                                                             USE ARITHDP1
#01101                            RENDEZVOUS RADAR RANGE RATE(XXXXX.FT/SEC
#                                                             USE ARITHDP1
#01110                            LANDING RADAR ALTITUDE(XXXXX.FEET)
#                                                              USE ARITHDP1

## Page 346
# 01111                           INITIAL/FINAL ALTITUDE(XXXXX.FEET)
#                                                             USE ARITHDP1
# 10000                           ALTITUDE RATE(XXXXX.FEET)      USE ARITH
# 10001                           FORWARD/LATERAL VELOCITY(XXXXX.FEET/SEC)
#                                                                USE ARITH
# 10010                           ROTATIONAL HAND CONTROLLER ANGLE RATES
#                                       XXXXX.DEG/SEC            USE ARITH
# 10011                           LANDING RADAR VELX(XXXXX.FEET/SEC)
#                                                             USE ARITHDP1
# 10100                           LANDING RADAR VELY(XXXXX.FEET/SEC)
#                                                             USE ARITHDP1
# 10101                           LANDING RADAR VELZ(XXXXX.FEET/SEC)
#                                                             USE ARITHDP1
# 10110                           OPTICAL TRACKER AZIMUTH ANGLE(XXX.XXDEG)
#                                                             USE ARITHDP1
# END OF SF CONSTANT CODE NUMBERS



# FOR GREATER THAN SINGLE PRECISION SCALES, PUT ADDRESS OF MAJOR PART INTO
# NOUN TABLES.
# OCTAL LOADS PLACE +0 INTO MAJOR PART, DATA INTO MINOR PART.
# OCTAL DISPLAYS SHOW MINOR PART ONLY.
# TO GET AT BOTH MAJOR AND MINOR PARTS (IN OCTAL), USE NOUN 01.

## Page 347
# THE FOLLOWING ROUTINES ARE FOR READING THE NOUN TABLES AND THE SF TABLES
# (WHICH ARE IN A SEPARATE BANK FROM THE REST OF PINBALL). THESE READING
# ROUTINES ARE IN THE SAME BANK AS THE TABLES. THEY ARE CALLED BY DXCH Z.



# LODNNTAB LOADS NNADTEM WITH THE NNADTAB ENTRY, NNTYPTEM WITH THE
# NNTYPTAB ENTRY. IF THE NOUN IS MIXED, IDAD1TEM IS LOADED WITH THE FIRST
# IDADDTAB ENTRY, IDAD2TEM THE SECOND IDADDTAB ENTRY, IDAD3TEM THE THIRD
# IDADDTAB ENTRY, RUTMXTEM WITH THE RUTMXTAB ENTRY. MIXBR IS SET FOR
# MIXED OR NORMAL NOUN.

                BANK            16

LODNNTAB        DXCH            IDAD2TEM                # SAVE RETURN INFO IN IDAD2TEM, IDAD3TEM.
                INDEX           NOUNREG
                CAF             NNADTAB
                TS              NNADTEM
                INDEX           NOUNREG
                CAF             NNTYPTAB
                TS              NNTYPTEM
                CS              NOUNREG
                AD              MIXCON
                EXTEND
                BZMF            LODMIXNN                # NOUN NUMBER G/E FIRST MIXED NOUN
                CAF             ONE                     # NOUN NUMBER L/ FIRST MIXED NOUN
                TS              MIXBR                   # NORMAL.  +1 INTO MIXBR.
                TC              LODNLV
LODMIXNN        CAF             TWO                     # MIXED.  +2 INTO MIXBR.
                TS              MIXBR
                INDEX           NOUNREG
                CAF             RUTMXTAB        -55
                TS              RUTMXTEM
                CAF             LOW10
                MASK            NNADTEM
                TS              Q                       # TEMP
                INDEX           A
                CAF             IDADDTAB
                TS              IDAD1TEM                # LOAD IDAD1TEM WITH FIRST IDADDTAB ENTRY
                EXTEND
                INDEX           Q                       # LOAD IDAD2TEM WITH 2ND IDADDTAB ENTRY
                DCA             IDADDTAB        +1      # LOAD IDAD3TEM WITH 3RD IDADDTAB ENTRY.
LODNLV          DXCH            IDAD2TEM                # PUT RETURN INFO INTO A, L.
                DXCH            Z

MIXCON          OCT             55                      # FIRST MIXED NOUN = 55.



# GTSFOUT LOADS SFTEMP1, SFTEMP2 WITH THE DP SFOUTAB ENTRIES.

## Page 348
GTSFOUT         DXCH            SFTEMP1                 # 2X(SFCONUM) ARRIVES IN SFTEMP1.
                EXTEND
                INDEX           A
                DCA             SFOUTAB
SFCOM           DXCH            SFTEMP1
                DXCH            Z



# GTSFIN LOADS SFTEMP1, SFTEMP2 WITH THE DP SFINTAB ENTRIES.

GTSFIN          DXCH            SFTEMP1                 # 2X(SFCONUM) ARRIVES IN SFTEMP1.
                EXTEND
                INDEX           A
                DCA             SFINTAB
                TCF             SFCOM



                                                        # NN  NORMAL NOUNS
NNADTAB         OCT             00000                   # 00 NOT IN USE
                OCT             40000                   # 01 SPECIFY MACHINE ADDRESS (FRACTIONAL)
                OCT             40000                   # 02 SPECIFY MACHINE ADDRESS (WHOLE)
                OCT             40000                   # 03 SPECIFY MACHINE ADDRESS (DEGREES)
                OCT             40000                   # 04 SPECIFY MACHINE ADDRESS (HOURS)
                OCT             40000                   # 05 SPECIFY MACHINE ADDRESS (SECONDS)
                OCT             40000                   # 06 SPECIFY MACHINE ADDRESS (GYRO DEG)
                OCT             00000                   # 07 SPARE
                OCT             77776                   # 10 CHANNEL TO BE SPECIFIED
                OCT             00000                   # 11 SPARE
                OCT             00000                   # 12 SPARE
                OCT             00000                   # 13 SPARE
                OCT             00000                   # 14 SPARE
                OCT             77777                   # 15 INCREMENT MACHINE ADDRESS
                ECADR           TIME2                   # 16 TIME SECONDS
                ECADR           TIME2                   # 17 TIME HOURS
                ECADR           CDUX                    # 20 ICDU
                ECADR           PIPAX                   # 21 PIPAS
                ECADR           THETAD                  # 22 NEW ANGLES I
                ECADR           DSPTEM2                 # 23 DELTA ANGLES I
                ECADR           DSPTEM1                 # 24 DELTA TIME (SEC)
                ECADR           DSPTEM1                 # 25 CHECKLIST
                ECADR           DSPTEM1                 # 26 PRIO/DELAY, ADRES, BBCON
                ECADR           SMODE                   # 27 SELF TEST ON/OFF SWITCH
                ECADR           DSPTEM1                 # 30 STAR NUMBERS
                ECADR           FAILREG                 # 31 FAILREG
                ECADR           TDEC                    # 32 DECISION TIME (MIDCOURSE)
                ECADR           TET                     # 33 EPHEMERIS TIME (MIDCOURSE)
                ECADR           MEASQ                   # 34 MEASURED QUANTITY (MIDCOURSE)
                ECADR           DSPTEM1                 # 35 INBIT MESSAGE

## Page 349
                ECADR           LANDMARK                # 36 LANDMARK DATA 1
                ECADR           LANDMARK        +3      # 37 LANDMARK DATA 2
                ECADR           OPTY                    # 40 RENDEZVOUS RADAR ANGLES (TRUN, SHAFT)
                ECADR           TANG                    # 41 NEW REND. RADAR ANGLES (TRUN, SHAFT)
                ECADR           DSPTEM2                 # 42 AOT ROTATION ANGLES
                ECADR           XYMARK                  # 43 AOT DETENT CODE
                ECADR           FORVEL                  # 44 FORWARD VELOCITY, LATERAL VELOCITY
                ECADR           PCOM                    # 45 ROTATIONAL HAND CONTROLLER ANGLE RATE
                OCT             00000                   # 46 SPARE
                OCT             00000                   # 47 SPARE
                OCT             00000                   # 50 SPARE
                OCT             00000                   # 51 SPARE
                ECADR           GBIASX                  # 52 GYRO BIAS DRIFT
                ECADR           ADIAX                   # 53 GYRO INPUT AXIS ACCELERATION DRIFT
                ECADR           ADSRAX                  # 54 GYRO SPIN AXIS ACCELERATION DRIFT

                                                        # NN  MIXED NOUNS
                OCT             02000                   # 55 LANDING RADAR ALTITUDE, TIME(SEC)
                OCT             02002                   # 56 LANDING RADAR VELX, TIME(SEC)
                OCT             02004                   # 57 LANDING RADAR VELY, TIME(SEC)
                OCT             02006                   # 60 LANDING RADAR VELZ, TIME(SEC)
                OCT             02010                   # 61 TARGET AZIMUTH AND ELEVATION
                OCT             04012                   # 62 RENDEZVOUS RADAR RANGE, TRUN, SHAFT
                OCT             04015                   # 63 REND. RADAR RANGE RATE, TRUN, SHAFT
                OCT             04020                   # 64 INITIAL ALT, FINAL ALT, ALT RATE
                OCT             02023                   # 65 SAMPLED TIME (HOURS AND SECONDS)
                                                        #      (FETCHED IN INTERRUPT)
                OCT             04025                   # 66 SYSTEM TEST RESULTS
                OCT             04030                   # 67 DELTA GYRO ANGLES
                OCT             02033                   # 70 OPTICAL TRACKER ANGLES (AZIMUTH,ELEV)
                OCT             02035                   # 71 DESIRED OPT. TRACK. ANGLES (AZ, ELEV)
                OCT             04037                   # 72 DELTA POSITION
                OCT             04042                   # 73 DELTA VELOCITY
                OCT             04045                   # 74 MEASUREMENT DATA (MIDCOURSE)
                OCT             04050                   # 75 MEASUREMENT DEVIATIONS (MIDCOURSE)
                OCT             04053                   # 76 POSITION VECTOR
                OCT             04056                   # 77 VELOCITY VECTOR



                                                        # NN        NORMAL NOUNS
NNTYPTAB        OCT             00000                   # 00 NOT IN USE
                OCT             00040                   # 01 1COMP FRACTIONAL
                OCT             00140                   # 02 1COMP WHOLE
                OCT             00102                   # 03 1COMP DEGREES
                OCT             00241                   # 04 1COMP HOURS
                OCT             00200                   # 05 1COMP SECONDS
                OCT             00343                   # 06 1COMP GYRO DEGREES
                OCT             00000                   # 07       SPARE
                OCT             00000                   # 10 1COMP OCTAL ONLY

## Page 350
                OCT             00000                   # 11        SPARE
                OCT             00000                   # 12        SPARE
                OCT             00000                   # 13        SPARE
                OCT             00000                   # 14        SPARE
                OCT             00000                   # 15 1COMP  OCTAL ONLY
                OCT             00200                   # 16 1COMP  SECONDS
                OCT             00241                   # 17 1COMP  HOURS
                OCT             04102                   # 20 3COMP  DEGREES
                OCT             04140                   # 21 3COMP  WHOLE
                OCT             04102                   # 22 3COMP  DEGREES
                OCT             04102                   # 23 3COMP  DEGREES
                OCT             00200                   # 24 1COMP  SECONDS
                OCT             00140                   # 25 1COMP  WHOLE
                OCT             04000                   # 26 3COMP  OCTAL ONLY
                OCT             00140                   # 27 1COMP  WHOLE
                OCT             04140                   # 30 3COMP  WHOLE
                OCT             04000                   # 31 3COMP  OCTAL ONLY
                OCT             00252                   # 32 1COMP  TIME WEEKS
                OCT             00252                   # 33 1COMP  TIME WEEKS
                OCT             00350                   # 34 1COMP  POISTION
                OCT             04000                   # 35 3COMP  OCTAL ONLY
                OCT             04000                   # 36 3COMP  OCTAL ONLY
                OCT             04000                   # 37 3COMP  OCTAL ONLY
                OCT             02102                   # 40 2COMP  DEGREES
                OCT             02102                   # 41 2COMP  DEGREES
                OCT             02102                   # 42 2COMP  DEGREES
                OCT             00140                   # 43 1COMP  WHOLE
                OCT             02161                   # 44 2COMP  FORWARD/LATERAL VELOCITY
                OCT             04162                   # 45 3COMP  ROT HAND CONT ANGLE RATE
                OCT             00000                   # 46        SPARE
                OCT             00000                   # 47        SPARE
                OCT             00000                   # 50        SPARE
                OCT             00000                   # 51        SPARE
                OCT             04144                   # 52 3COMP  GYRO BIAS DRIFT
                OCT             04145                   # 53 3COMP  GYRO AXIS ACCEL. DRIFT
                OCT             04145                   # 54 3COMP  GYRO AXIS ACCEL. DRIFT

                                                        # NN        MIXED NOUNS
                OCT             00016                   # 55 2COMP  LANDING RADAR ALT, SECONDS
                OCT             00023                   # 56 2COMP  LANDING RADAR VELX, SECONDS
                OCT             00024                   # 57 2COMP  LANDING RADAR VELY, SECONDS
                OCT             00025                   # 60 2COMP  LANDING RADAR VELZ, SECONDS
                OCT             00542                   # 61 2COMP  DEGREES, ELEVATION DEGREES
                OCT             04114                   # 62 3COMP  REND. RADAR RANGE, DEG, DEG
                OCT             04115                   # 63 3COMP  REND. RAD. RANGE RATE, DEG,DEG
                OCT             40757                   # 64 3COMP  IN/FN ALT, IN/FN ALT, ALT RATE
                OCT             00001                   # 65 2COMP  HOURS, SECONDS
                OCT             00000                   # 66 3COMP  WHOLE, FRACTIONAL, WHOLE
                OCT             06143                   # 67 3COMP  GYRO DEGREES FOR EACH
                OCT             00126                   # 70 2COMP  OPT TRACK AZIMUTH, DEGREES

## Page 351
                OCT             00126                   # 71 2COMP  OPT TRACK AZIMUTH, DEGREES
                OCT             20410                   # 72 3COMP  POSITION FOR EACH
                OCT             22451                   # 73 3COMP  VELOCITY FOR EACH
                OCT             00412                   # 74 3COMP  TIME WEEKS, POSITION, WHOLE
                OCT             20450                   # 75 3COMP  POSITION, VELOCITY, POSITION
                OCT             20410                   # 76 3COMP  POSITION FOR EACH
                OCT             22451                   # 77 3COMP  VELOCITY FOR EACH



SFINTAB         OCT             00006                   # WHOLE,TIME(SEC)
                OCT             03240
                OCT             00253                   # TIME HOURS ( = 1.3..... )
                OCT             25124                   #   (POINT BETWEEN BITS 7-8 )
                OCT             0                       # DEGREES (SFCON IN DEGINSF)
                OCT             0
                OCT             10707                   # GYRO DEGREES
                OCT             03435                   #             UPPED BY 1
                OCT             00001                   # GYRO BIAS DRIFT
                OCT             02133
                OCT             00011                   # GYRO AXIS ACCEL. DRIFT
                OCT             30322
                OCT             00004                   # PIPA BIAS
                OCT             14021
                OCT             00314                   # PIPA SCALE ERROR.
                OCT             31463
                OCT             23420                   # POSITION
                OCT             00000
                OCT             00201                   # VELOCITY
                OCT             30327                   # ( POINT BETWEEN BITS 7-8 )
                OCT             01371                   # TIME WEEKS
                OCT             34750                   # ( POINT BETWEEN BITS 7-8 )
                OCT             00001                   # ELEVATION DEGREES
                OCT             03434
                OCT             00006                   # RENDEZVOUS RADAR RANGE
                OCT             20162
                OCT             00011                   # RENDEZVOUS RADAR RANGE RATE
                OCT             27066
                OCT             00016                   # LANDING RADAR ALTITUDE
                OCT             04245
                OCT             00002                   # INITIAL/FINAL ALTITUDE
                OCT             23224
                OCT             00014                   # ALTITUDE RATE
                OCT             06500
                OCT             00012                   # FORWARD/LATERAL VELOCITY
                OCT             36455
                OCT             04256                   # ROT HAND CONT ANGLE RATE
                OCT             07071
                OCT             77766                   # LANDING RADAR VELX (NEG TO SWITCH SIGNS)
                OCT             60044

## Page 352
                OCT             00004                   # LANDING RADAR VELY
                OCT             34055
                OCT             00007                   # LANDING RADAR VELZ
                OCT             04147
                OCT             00005                   # OPTICAL AZIMUTH TRACKER ANGLE
                OCT             21616
                                                        # END OF SFINTAB



SFOUTAB         OCT             05174                   # WHOLE, TIME(SEC)
                OCT             13261
                OCT             27670                   # TIME HOURS
                OCT             31357
                OCT             0                       # DEGREES
                OCT             0
                OCT             00714                   # GYRO DEGREES
                OCT             31463                   # (POINT BETWEEN BITS 7-8)
                OCT             35753                   # GYRO BIAS DRIFT
                OCT             32323
                OCT             03216                   # GYRO AXIS ACCEL. DRIFT
                OCT             06400
                OCT             07237                   # PIPA BIAS
                OCT             37776
                OCT             00120                   # PIPA SCALE ERROR
                OCT             00000
                OCT             00321                   # POSITION
                OCT             26706                   # ( POINT BETWEEN BITS 7-8 )
                OCT             37441                   # VELOCITY
                OCT             14247
                OCT             05300                   # TIME WEEKS
                OCT             20305
                OCT             34631                   # ELEVATION DEGREES
                OCT             23146
                OCT             04725                   # RENDEZVOUS RADAR RANGE
                OCT             35454
                OCT             03225                   # RENDEZVOUS RADAR RANGE RATE
                OCT             07470
                OCT             02207                   # LANDING RADAR ALTITUDE
                OCT             03255
                OCT             14226                   # INITIAL/FINAL ALTITUDE
                OCT             31757
                OCT             02476                   # ALTITUDE RATE
                OCT             05531
                OCT             02727                   # FORWARD/LATERAL VELOCITY
                OCT             16415
                OCT             00007                   # ROT HAND CONT ANGLE RATE
                OCT             13734
                OCT             74502                   # LANDING RADAR VELX (NEG TO SWITCH SIGNS)
                OCT             76401

## Page 353
                OCT             06436                   # LANDING RADAR VELY
                OCT             35664
                OCT             04371                   # LANDING RADAR VELZ
                OCT             17420
                OCT             05605                   # OPTICAL TRACKER AZIMUTH ANGLE
                OCT             03656
                                                        # END OF SFOUTAB


                                                        # MIXNOUN   SF ROUT
IDADDTAB        ECADR           RSTACK          +18D    # 01        LANDING RADAR ALTITUDE
                ECADR           RSTACK          +22D    # 01        SECONDS
                ECADR           RSTACK                  # 02        LANDING RADAR VELX
                ECADR           RSTACK          +4      # 02        SECONDS
                ECADR           RSTACK          +6      # 03        LANDING RADAR VELY
                ECADR           RSTACK          +10D    # 03        SECONDS
                ECADR           RSTACK          +12D    # 04        LANDING RADAR VELY
                ECADR           RSTACK          +16D    # 04        SECONDS
                ECADR           DSPTEM1                 # 05        DEGREES
                ECADR           DSPTEM1         +1      # 05        ELEVATION DEGREES
                ECADR           RSTACK                  # 06        RENDEZVOUS RADAR RANGE
                ECADR           RSTACK          +2      # 06        DEGREES
                ECADR           RSTACK          +3      # 06        DEGREES
                ECADR           RSTACK          +6      # 07        RENDEZVOUS RADAR RANGE RATE
                ECADR           RSTACK          +8D     # 07        DEGREES
                ECADR           RSTACK          +9D     # 07        DEGREES
                ECADR           ALT                     # 10        INITIAL/FINAL ALTITUDE
                ECADR           FINALT                  # 10        INITIAL/FINAL ALTITUDE
                ECADR           ALTRATE                 # 10        ALTITUDE RATE
                ECADR           SAMPTIME                # 11        HOURS
                ECADR           SAMPTIME                # 11        SECONDS
                ECADR           DSPTEM2                 # 11        WHOLE
                ECADR           DSPTEM2         +1      # 12        FRACTIONAL
                ECADR           DSPTEM2         +2      # 12        WHOLE
                ECADR           DELVX                   # 13        GYRO DEGREES
                ECADR           DELVX           +2      # 13        GYRO DEGREES
                ECADR           DELVX           +4      # 13        GYRO DEGREES
                ECADR           AZANG                   # 14        OPT TRACK AZIMUTH ANGLE
                ECADR           ELANG                   # 14        DEGREES
                ECADR           DESLOTSY                # 15        OPT TRACK AZIMUTH ANGLE
                ECADR           DESLOTSX                # 15        DEGREES
                ECADR           DELR                    # 16        POSITION
                ECADR           DELR            +2      # 16        POSITION
                ECADR           DELR            +4      # 16        POSITION
                ECADR           DELVEL                  # 17        VELOCITY
                ECADR           DELVEL          +2      # 17        VELOCITY
                ECADR           DELVEL          +4      # 17        VELOCITY
                ECADR           TDEC                    # 20        TIME WEEKS
                ECADR           MEASQ                   # 20        POSITION

## Page 354
                ECADR           MEASMODE                # 20        WHOLE
                ECADR           DSPTEM1                 # 21        POSITION
                ECADR           DSPTEM1         +2      # 21        VELOCITY
                ECADR           DELTAQ                  # 21        POSITION
                ECADR           DSPTEM1                 # 22        POSITION
                ECADR           DSPTEM1         +2      # 22        POSITION
                ECADR           DSPTEM1         +4      # 22        POSITION
                ECADR           DSPTEM1                 # 23        VELOCITY
                ECADR           DSPTEM1         +2      # 23        VELOCITY
                ECADR           DSPTEM1         +4      # 23        VELOCITY
                OCT             00000                   #           SPARE
                OCT             00000                   #           SPARE
                OCT             00000                   #           SPARE
                OCT             00000                   #           SPARE
                OCT             00000                   #           SPARE
                OCT             00000                   #           SPARE
                                                        # END OF IDADDTAB



                                                        # MIXNOUN  SF ROUT
RUTMXTAB        OCT             00204                   # 01  LANDING RADAR ALTITUDE, SECONDS
                OCT             00204                   # 02  LANDING RADAR VELX, SECONDS
                OCT             00204                   # 03  LANDING RADAR VELY, SECONDS
                OCT             00204                   # 04  LANDING RADAR VELZ, SECONDS
                OCT             00142                   # 05  DEGREES, ELEVATION DEGREES
                OCT             04104                   # 06  RENDEZVOUS RADAR RANGE, DEG, DEG
                OCT             04104                   # 07  REND. RADAR RANGE RATE, DEG, DEG
                OCT             06204                   # 10  INIT/FIN ALT, INIT/FIN ALT, ALT RATE
                OCT             00205                   # 11  HOURS, SECONDS
                OCT             06043                   # 12  WHOLE, FRACTIONAL, WHOLE
                OCT             16347                   # 13  GYRO DEGREES (FOR EACH)
                OCT             00104                   # 14  OPT TRACK AZIMUTH ANGLE, DEGREES
                OCT             00104                   # 15  OPT TRACK AZIMUTH ANGLE, DEGREES
                OCT             16347                   # 16  POSITION (FOR EACH)
                OCT             12245                   # 17  VELOCITY (FOR EACH)
                OCT             06345                   # 20  TIME WEEKS, POSITION, WHOLE
                OCT             16247                   # 21  POSITION , VELOCITY, POSITION
                OCT             16347                   # 22  POSITION (FOR EACH)
                OCT             12245                   # 23  VELOCITY (FOR EACH)
                                                        # END OF RUTMXTAB



ENDPINS3        EQUALS

## Page 355

# MISCELLANEOUS SERVICE ROUTINES IN FIXED/FIXED



                SETLOC          DATWAIT1        +2

# SETNCADR      E CADR ARRIVES IN A. IT IS STORED IN NOUNCADR. EBANK BITS
#               ARE SET.  E ADRES IS DERIVED AND PUT INTO NOUNADD.

SETNCADR        TS              NOUNCADR                # STORE ECADR
                TS              EBANK                   # SET EBANK BITS
                MASK            LOW8
                AD              OCT1400
                TS              NOUNADD                 # PUT E ADRES INTO NOUNADD
                TC              Q



# SETNADD       GETS E CADR FROM NOUNCADR, SETS EBANK BITS, DERIVES
#               E ADRES AND PUTS IT INTO NOUNADD.

SETNADD         CA              NOUNCADR
                TCF             SETNCADR        +1



# SETEBANK      E CADR ARRIVES IN A. EBANK BITS ARE SET. E ADRES IS
#               DERIVED AND LEFT IN A.

SETEBANK        TS              EBANK           # SET EBANK BITS
                MASK            LOW8
                AD              OCT1400         # E ADRES LEFT IN A
                TC              Q



R1D1            OCT             16
R2D1            OCT             11
R3D1            OCT             4

RIGHT5          TS              CYR
                CS              CYR
                CS              CYR
                CS              CYR
                CS              CYR
                XCH             CYR
                TC              Q

LEFT5           TS              CYL
                CS              CYL

## Page 356
                CS              CYL
                CS              CYL
                CS              CYL
                XCH             CYL
                TC              Q

SLEFT5          DOUBLE
                DOUBLE
                DOUBLE
                DOUBLE
                DOUBLE
                TC              Q



LOW5            OCT             37
MID5            OCT             1740
HI5             OCT             76000                   # MUST STAY HERE

TCNOVAC         TC              NOVAC
TCWAIT          TC              WAITLIST
TCTSKOVR        TC              TASKOVER
TCFINDVC        TC              FINDVAC



CHRPRIO         OCT             30000                   # EXEC PRIORITY OF CHARIN



LOW11           OCT             3777
B12-1           EQUALS          LOW11
LOW8            OCT             377
OCT1400         OCT             1400



VD1             OCT             23
ND1             OCT             21
MD1             OCT             25

BINCON          DEC             10

FALTON          CA              BIT7                    # TURN ON OPERATOR ERROR LIGHT
                EXTEND
                WOR             DSALMOUT                # BIT 7 OF CHANNEL 11
                TC              Q

FALTOF          CS              BIT7                    # TURN OFF OPERATOR ERROR LIGHT
                EXTEND

## Page 357
                WAND            DSALMOUT                # BIT 7 OF CHANNEL 11
                TC              Q

RELDSPON        CAF             BIT5                    # TURN ON KEY RELEASE LIGHT
                EXTEND
                WOR             DSALMOUT                # BIT 5 OF CHANNEL 11
                TC              Q

LODSAMPT        EXTEND
                DCA             TIME2
                DXCH            SAMPTIME
                TC              Q



TPSL1           EXTEND                                  # SHIFTS MPAC, +1, +2 LEFT 1
                DCA             MPAC    +1              # LEAVES OVFIND SET TO +/- 1 FOR OF/UF
                DAS             MPAC    +1
                AD              MPAC
                ADS             MPAC
                TS              7                       # TS A DOES NOT CHANGE A ON OF/UF.
                TC              Q                       # NO NET OF/UF
                TS              OVFIND                  # OVFIND SET TO +/- 1 FOR OF/UF
                TC              Q



FLASHON         CAF             BIT6                    # TURN ON V/N FLASH
                EXTEND                                  # BIT 6 OF CHANNEL 11
                WOR             DSALMOUT
                TC              Q



FLASHOFF        CS              BIT6                    # TURN OFF V/N FLASH
                EXTEND
                WAND            DSALMOUT                # BIT 6 OF CHANNEL 11
                TC              Q

## Page 358
# INTERNAL ROUTINES THAT USE THE KEYBOARD AND DISPLAY SYSTEM(THRU
# NVSUB) MUST  TC GRABDSP  BEFOREHAND , TO GRAB THE DISPLAY SYSTEM AND
# MAKE IT BUSY TO OTHER INTERNAL USERS.

#       WHEN FINISHED , THERE MUST BE A TC FREEDSP , TO RELEASE THE
# SYSTEM FOR OTHER INTERNAL USERS.
#
#       THE CALLING SEQUENCES ARE
# L        TC     GRABDSP
# L+1      RETURN HERE WHEN SYSTEM IS ALREADY GRABBED
# L+2      RETURN HERE MEANS YOU HAVE IT

# L        TC     NVSUB
# L+1      RETURN HERE IF OPERATOR HAS INTERVENED
# L+2      RETURN HERE AFTER EXECUTION



#       A ROUTINE CALLED GRABUSY IS PROVIDED (USE IS OPTIONAL) TO PUT YOUR
# JOB TO SLEEP UNTIL THE SYSTEM IS FREED BY THE JOB HOLDING IT.
# GRABUSY CANNOT BE CALLED FROM E MEMORY, SINCE JOBSLEEP AND JOBWAKE
# HANDLE ONLY FIXED MEMORY.
# YOUR CADR IS PUT AT FIRST AVAILABLE SLOT IN A WAITING LIST (FIFO).

#       THE CALLING SEQUENCE IS
#          CAF    WAKEFCADR
#          TC     GRABUSY

#       A ROUTINE CALLED NVSUBUSY IS PROVIDED (USE IS OPTIONAL)  TO PUT
# YOUR JOB TO SLEEP UNTIL THE OPERATOR RELEASES IT.
# NVSUBUSY CANNOT BE CALLED FROM E MEMORY, SINCE JOBSLEEP AND JOBWAKE
# HANDLE ONLY FIXED MEMORY.
#                                             YOUR CADR IS PUT
# ON TOP OF A WAITING LIST (FIFO). IT ALSO TURNS ON KEY RELEASE LIGHT.

#        THE CALLING SEQUENCE IS
#          CAF    WAKEFCADR
#          TC     NVSUBUSY


# AFTER A TC FREEDSP, THE INTERNAL INTERLOCK IS KEPT BUSY FOR 10 SECONDS,
# AFTER WHICH A CADR IS CALLED FROM THE LIST. THIS INSURES THAT ALL
# DISPLAYS WAITING WILL BE VISIBLE.



# GRABLOCK IS THE INTERNAL INTERLOCK FOR THE USE OF THE KEYBOARD
# AND DISPLAY SYSTEM.
# +0  FREE

## Page 359
# +1  SOME INTERNAL ROUTINE HAS GRABBED DSP SYST
# +2  SOME INTERNAL ROUTINE HAS GONE TO NVSUBUSY



GRABDSP         CCS             GRABLOCK
                TC              Q                       # ALREADY GRABBED, RETURN TO L+1
                CAF             ONE                     # NOT GRABBED, SET TO +1
                TS              GRABLOCK                # AND RETURN TO L+2
                INDEX           Q
                TC              1



PREGBSY         CAF             LOW10                   # SPECIAL ENTRANCE FOR ROUTINES IN FIXED
                MASK            Q                       # BANKS ONLY DESIRING THE FCADR OF
                AD              FBANK                   # 1 + (LOC FROM WHICH TC PREGBSY WAS DONE)
GRABUSY         TC              POSTJUMP                # TO BE ENTERED.
                CADR            GRABUSYB
                SETLOC          DOPROC          +2
GRABUSY1        TS              L
                CCS             GRABLOCK
                TC              +3                      # STILL GRABBED
                CA              L                       # NOT GRABBED SO DO DIRECT CALL
                TC              BANKJUMP
                CAF             TWO
                TS              LSTPTR
                INDEX           LSTPTR                  # SEARCH LIST FOR FIRST AVAILABLE SPACE
                CCS             DSPLIST                 # FROM BOTTOM.
                TC              +2
                TC              PUTINLST                # SPACE FOUND
                CCS             LSTPTR                  # DECREMENT POINTER
                TC              -6
                TC              LSTFULL
PUTINLST        CA              L
                INDEX           LSTPTR
                TS              DSPLIST
                TC              JOBSLEEP


# GRABWAIT IS A SPECIAL ENTRANCE FOR ROUTINES IN FIXED BANKS ONLY. IF
# SYSTEM IS NOT GRABBED, IT GRABS IT AND RETURNS TO L+1 ( L = LOC FROM
# WHICH THE TC GRABWAIT WAS DONE). IF SYSTEM IS GRABBED, IT PUTS CALLING
# JOB TO SLEEP WITH L+1 GOING INTO LIST FOR EVENTUAL WAKING UP WHEN
# SYSTEM IS FREED.
#
                SETLOC          GRABUSY         +2
GRABWAIT        CCS             GRABLOCK
                TCF             PREGBSY                 # GRABBED. PUT L+1 INTO LIST. GO TO SLEEP.

## Page 360
                CAF             ONE                     # NOT GRABBED. GRAB AND RETURN TO L+1.
                TS              GRABLOCK
                TC              Q



PRENVBSY        CS              2K+3                    # SPECIAL ENTRANCE FOR ROUTINES IN FIXED
                AD              Q                       # BANKS ONLY DESIRING THE FCADR OF(LOC
                AD              FBANK                   # FROM WHICH THE TC PRENVBSY WAS DONE) -2
NVSUBUSY        TC              POSTJUMP                # TO BE ENTERED.
                CADR            NVSUBSYB
2K+3            OCT             2003

                SETLOC          PUTINLST        +4
NVSUBSY1        TS              L
                CCS             DSPLOCK                 # TEST IF REALLY LOCKED OUT
                TC              +3                      # STILL BUSY
                CA              L                       # DSPLOCK = +0 SO RETURN DIRECTLY
                TC              BANKJUMP
                CAF             TWO                     # SET FOR GRABBED STATE AND NVSUBUSY USE
                TS              GRABLOCK
                CA              L
                XCH             DSPLIST         +2      # ENTER CADR INTO FIRST POSITION OF LIST
                XCH             DSPLIST         +1      #         (BOTTOM)
                XCH             DSPLIST
                CCS             A
                TC              LSTFULL
                TC              +2
                TC              LSTFULL
                TC              RELDSPON
                CA              L
ENDNVBSY        TC              JOBSLEEP



# NVSBWAIT IS A SPECIAL ENTRANCE FOR ROUTINES IN FIXED BANKS ONLY. IF
# SYSTEM IS NOT BUSY, IT EXECUTES V/N AND RETURNS TO L+1 (L= LOC FROM
# WHICH THE TC NVSBWAIT WAS DONE). IF SYSTEM IS BUSY, IT PUTS CALLING JOB
# TO SLEEP WITH L-1 GOING INTO LIST FOR EVENTUAL WAKING UP WHEN SYSTEM
# IS NOT BUSY.

                SETLOC          NVSUBUSY        +3
NVSBWAIT        TS              NVTEMP
                CCS             DSPLOCK
                TCF             NVSBWT1                 # BUSY
                CA              Q                       # FREE. NVSUB WILL SAVE L+1 FOR RETURN
                TCF             NVSUB           +5      # AFTER EXECUTION.
NVSBWT1         INCR            Q                       # L+2. PRENVBSY WILL PUT L-1 INTO LIST AND
                TCF             PRENVBSY                # GO TO SLEEP.

## Page 361
RELDSP          XCH             Q                       # SET DSPLOCK TO +0, TURN RELDSP LIGHT
                TS              RELRET                  # OFF, SEARCH DSPLIST
                CAF             NEG1
                AD              GRABLOCK
                EXTEND                                  # SEARCH LIST ONLY IF GRABLOCK = +2
                BZMF            RELDSP2                 #   (SOMEONE USED NVSUBUSY)
                TC              WKSEARCH
                TC              RELDSP2                 # LIST EMPTY
                TC              JOBWAKE                 # LIST NOT EMPTY
                CAF             ONE
                TS              GRABLOCK
RELDSP2         INHINT
                CS              BIT5                    # TURN OFF KEY RELEASE LIGHT
                EXTEND                                  # (BIT 5 OF CHANNEL 11)
                WAND            DSALMOUT
                CAF             ZERO
                TS              DSPLOCK
                RELINT
                TC              RELRET
RELDSP1         XCH             Q                       # SET DSPLOCK TO +0. RELDSP LIGHT OFF.
                TS              RELRET                  # NO LIST SEARCH
                TC              RELDSP2



WKSEARCH        CAF             ZERO                    # SEARCHES LIST. LEAVES RESULT IN A.
                XCH             DSPLIST                 # IF EMPTY, RETURN TO L+1.
                XCH             DSPLIST         +1      # IF NOT EMPTY, INHINT AND RETURN TO L+2.
                XCH             DSPLIST         +2
                EXTEND
                BZF             +4                      # EMPTY
                INHINT                                  # NOT EMPTY
                INDEX           Q                       # RETURN TO L+2
                TC              1
                TC              Q                       # RETURN TO L+1



FREEDSP         XCH             Q
                TS              FREERET
                INHINT
                CAF             SHOTIME
                TC              WAITLIST
                EBANK=          DSPCOUNT
                2CADR           FREEWAIT
                RELINT
                TC              FREERET

SHOTIME         DEC             600                     # 6 SECOND WAITING PERIOD.

## Page 362
ENDPINBF        EQUALS

                SETLOC          ENDNVBSY        +1

FREEWAIT        CAF             CHRPRIO                 # CALLED BY T3RUPT
                TC              NOVAC
                EBANK=          DSPCOUNT
                2CADR           FREDSPD0
                TC              TASKOVER



FREDSPD0        TC              WKSEARCH                # CALLED BY EXECUTIVE
                TC              LSTEMPTY                # LIST EMPTY
                TC              JOBWAKE                 # LIST NOT EMPTY
                RELINT
                CAF             ONE                     # SET FOR GRABBED CONDITION
                TS              GRABLOCK
                TC              ENDOFJOB
LSTEMPTY        CAF             ZERO                    # SET FOR FREE CONDITION
                TC              -3



LSTFULL         TC              ABORT
                OCT             01206                   # PINBALL WAITING LINE FULL.

ENDPINS1        EQUALS

## Page 363
# VBTSTLTS TURNS ON ALL DISPLAY PANEL LIGHTS. AFTER 5 SEC, IT TURNS
# OFF THE CAUTION AND STATUS LIGHTS.

                SETLOC          DSPMMEND        +1

VBTSTLTS        INHINT
                CS              BIT1                    # SET BIT 1 OF IMODES33 SO IMUMON WONT
                MASK            IMODES33                # TURN OUT ANY LAMPS.
                AD              BIT1
                TS              IMODES33

                CAF             TSTCON1                 # TURN ON UPLINK ACTIVITY, TEMP, KEY RLSE,
                EXTEND                                  # V/N FLASH, OPERATOR ERROR.
                WOR             DSALMOUT
                CAF             TSTCON2                 # TURN ON NO ATT, GIMBAL LOCK, TRACKER,
                TS              DSPTAB          +11D    # PROG ALM.
                CAF             BIT10                   # TURN ON TEST ALARM OUTBIT
                EXTEND
                WOR             CHAN13
                CAF             TEN
TSTLTS1         TS              ERCNT
                CS              FULLDSP
                INDEX           ERCNT
                TS              DSPTAB
                CCS             ERCNT
                TC              TSTLTS1
                CS              FULLDSP1
                TS              DSPTAB          +1       # TURN ON 3 PLUS SIGNS
                TS              DSPTAB          +4
                TS              DSPTAB          +6
                CAF             ELEVEN
                TS              NOUT
                RELINT
                CAF             SHOLTS
                INHINT
                TC              WAITLIST
                EBANK=          DSPTAB
                2CADR           TSTLTS2

                TC              ENDOFJOB                # DSPLOCK IS LEFT BUSY (FROM KEYBOARD
                                                        # ACTION) UNTIL TSTLTS3 TO INSURE THAT
                                                        # LIGHTS TEST WILL BE SEEN.



FULLDSP         OCT             05675                   # DISPLAY ALL 8:S
FULLDSP1        OCT             07675                   # DISPLAY ALL 8:S AND +
TSTCON1         OCT             00175
                                                        # UPLINK ACTIVITY, TEMP, KEY RLSE,
                                                        # V/N FLASH, OPERATOR ERROR.

## Page 364
TSTCON2         OCT             40650                   # DSPTAB+11D BITS 4,6,8,9.
                                                        # NO ATT, GIMBAL LOCK, TRACKER, PROG ALM.
TSTCON3         OCT             00115                   # CHAN 11 BITS 1, 3, 4, 7.
                                                        # UPLINK ACTIVITY, TEMP, OPERATOR ERROR.
SHOLTS          OCT             764                     # 5 SEC



TSTLTS2         CAF             CHRPRIO                 # CALLED BY WAITLIST
                TC              NOVAC
                EBANK=          DSPTAB
                2CADR           TSTLTS3

                TC              TASKOVER



TSTLTS3         CS              TSTCON3                 # CALLED BY EXECUTIVE
                INHINT
                EXTEND                                  # TURN OFF  UPLINK ACTIVITY, TEMP,
                WAND            DSALMOUT                # OPERATOR ERROR.
                CS              BIT10                   # TURN OFF  TEST ALARM OUTBIT
                EXTEND
                WAND            CHAN13
                CAF             BIT15                   # TURN OFF AUTO, HOLD, FREE, NO ATT, SPARE
                TS              DSPTAB +11D             # GIMBAL LOCK, SPARE, TRACKER, PROG ALM
                CS              13-11,1                 # SET BITS TO INDICATE ALL LAMPS OUT. TEST
                MASK            IMODES33                # LIGHTS COMPLETE.
                AD              PRIO16
                TS              IMODES33

                CS              OCT55000
                MASK            IMODES30
                AD              PRIO15                  # 15000.
                TS              IMODES30

                CS              RFAILS2
                MASK            RADMODES
                AD              BIT7
                TS              RADMODES

                RELINT

                TC              DSPMM                   # REDISPLAY C(MODREG)
                TC              POSTJUMP                # TURN OFF KEY RLSE LIGHT ( AND SEARCH LIST
                CADR            VBTERM                  # IF APPROPRIATE).
                                                        # TURN OFF V/N FLASH, SET LOADSTAT FOR
                                                        # FOR TERMINATE CONDITION, AND GO TO
                                                        # RECALTST. FINALLY DO TC ENDOFJOB.

## Page 365
13-11,1         OCT             16001
RFAILS2         OCT             330                     # RADAR CDU AND DATA FAIL FLAGS.
OCT55000        OCT             55000
ENDPINS2        EQUALS
