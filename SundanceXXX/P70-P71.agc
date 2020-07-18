### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P70-P71.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 292

                BANK    21
                SETLOC  R11
                BANK

                EBANK=  DVCNTR
                COUNT*  $$/R11

ROSEN           TC      FIXDELAY
 CRANTZ         DEC     50

                CS      FLAGWRD6
                MASK    KILLRBIT
                EXTEND
                BZF     TASKOVER

P71NOW?         CS      MODREG          # YES.  ARE WE IN P71 NOW?
                AD      MODE71
                EXTEND
                BZF     TASKOVER        # YES.  EXIT.
                
                EXTEND                  # NO.  IS AN ABORT STAGE COMMANDED?
                READ    CHAN30
                TS      L
                MASK    BIT4
                CCS     A
                TCF     P70NOW?         # NO.

                TC      NEWMODEX
MODE71          DEC     71

STRTABRT        CAF     PRIO25
                TC      FINDVAC
                EBANK=  WHICH
                2CADR   ABORTJOB

                TCF     ROSEN

P70NOW?         CS      MODREG          # NO. ARE WE IN P70 NOW?
                AD      MODE70
                EXTEND
                BZF     ROSEN           # YES.  CHECK AGAIN IN 50MS.

                CS      L               # NO.  IS AN ABORT COMMANDED?
                MASK    BIT1
                EXTEND
                BZF     ROSEN           # NO.

                TC      NEWMODEX        # YES.
MODE70          DEC     70
                TCF     STRTABRT

		BANK	32
		SETLOC	ABORTS
		BANK

		COUNT*	$$/P70


P70             TC      LEGAL?
                TC      NEWMODEX
                DEC     70

ABORTJOB        EXTEND                  # LOAD TEVENT FOR THE DOWNLINK.
                DCA     TIME2
                DXCH    TEVENT

                TC      2PHSCHNG
                OCT     00001
                OCT     00002

                TC      2PHSCHNG
                OCT     00003
                OCT     00006

                TC      PHASCHNG
                OCT     07024
                OCT     25000
                EBANK=  WHICH
                2CADR   GOABORT

                INHINT
                TC      POSTJUMP
                CADR    GOPROG2

GOABORT         TC      PHASCHNG
                OCT     04024

                CAF     SIX             # SET UP R60 FOR A 10 DEG/SEC MANUV. RATE.
                TS      RATEINDX

                CAF     LRBYBIT
                TS      LRSTAT

                EXTEND
                DCA     SVEXITAD
                DXCH    AVEGEXIT

                CAF     THREE           # INITIALIZE FOR POWERED DOWNLIST.
                TS      DNLSTCOD
                TS      AGSWORD

                TC      DOWNFLAG
                ADRES   SWANDISP
                TC      UPFLAG
                ADRES   FLP70
                TC      DOWNFLAG
                CADR    XOVINFLG
                
                TC      CHECKMM
                DEC     70
                TCF     P71RET

P70INIT         CAF     P70ADR
                TS      WHICH

                TC      INTPRET
                CALL
                        TGOCOMP
                DLOAD   
                        MASS
                PUSH    DDV
                        MDOTDPS*
                STODL   TBUP
                DDV     SR1
                        K(1/DV)
                STORE   1/DV1
                STORE   1/DV2
                STORE   1/DV3
                BDDV
                        K(AT)
                STODL   AT
                        DTDECAY*
                STODL   TTO
                        DPSVEX
                STORE   VE              # INITIALIZE DPS EXHAUST VELOCITY
                SET     CALL
                        FLAP
                        COMMINIT

INJTARG         DLOAD   DSU
                        TGO
                        50SECS
                BPL     EXIT
                        UPTHROT

                INHINT
                TC      IBNKCALL
                CADR    ENGINOF1
                RELINT

                TC      ZONEZERO

ABRTGUID        TC      INTPRET
                SET     CALL
                        FLIC
                        ASCENT

ABORTIGN        VLOAD
                        UNFC/2
                STOVL   POINTVSM
                        UNITX
                STORE   SCAXIS
                CLEAR   EXIT
                        NOTHROTL

                TC      PHASCHNG
                OCT     04024

                TC      DOWNFLAG
                ADRES   3AXISFLG

                INHINT
                TC      IBNKCALL
                CADR    SETMINDB

                TC      DOWNFLAG
                ADRES   FLIC

                TC      BANKCALL
                CADR    R60LEM

                TC      BANKCALL
                CADR    P40AUTO
                
                CAF     ZERO
                TS      DVTOTAL
                TS      DVTOTAL +1

                TC      INTPRET
                CALL
                        INITCDUW
                EXIT

                CAF     6.5SEC
                INHINT
                TC      WAITLIST
                EBANK=  DVCNTR
                2CADR   ULLGTASK

                CAF     5.0SEC
                TC      WAITLIST
                EBANK=  TTOGO
                2CADR   TIG-5

                EXTEND
                DCA     TIME2
                DXCH    TIG
                EXTEND
                DCA     10SECS
                DAS     TIG
                TC      BANKCALL
                CADR    STCLOK3

                TCF     UPTHROT1

UPTHROT         SET     EXIT
                        FLVR
                
                INHINT
                CAF     ONE
                TC      WAITLIST
                EBANK=  DVCNTR
                2CADR   ZOOM

  -2            TC      BANKCALL        # VERIFY THAT THE PANEL SWITCHES 
                CADR    P40AUTO         # ARE PROPERLY SET.
                
UPTHROT1        EXTEND                  # SET SERVICER TO CALL ASCENT GUIDANCE.
                DCA     ATMAGAD
                DXCH    AVGEXIT

                TCF     ENDOFJOB


ZONEZERO        TC      INTPRET
                SSP
                        OUTROUTE
                CADR    ZONE0RET
                CLEAR   EXIT
                        AVEGFLAG
                
                TC      PHASCHNG
                OCT     00004
                
                TCF     ENDOFJOB

ZONE0RET        TC      PHASCHNG
                OCT     05024
                OCT     20000
                
                TC      INTPRET
                RTB     DAD
                        LOADTIME
                        80SEC
                STORE   PIPTIME1        # STORE TEMPORARILY IN PIPTIME1.
                STCALL  TDEC1
                        LEMPREC
                VLOAD
                        VATT
                STORE   VN1             # STORE VTIG TEMPORARILY IN VN1.
                MXV     VSL1
                        REFSMMAT
                STOVL   V
                        RATT
                STORE   RN1             # STORE RTIG TEMPORARILY IN RN1.
                MXV     VSL6
                        REFSMMAT
                STCALL  R
                        MUNGRAV
                SET     CALL
                        FLZONE0
                        ASCENT
PREBRET1        EXIT
                TC      PHASCHNG
                OCT     04024
                TC      INTPRET
                VXM     VSL1
                        REFSMMAT
                STORE   DELVSIN
                ABVAL
                STOVL   DELVSAB
                        RN1
                STOVL   RTIG
                        VN1
                STODL   VTIG
                        PIPTIME1
                STORE   TIG
                SET     CLEAR
                        XDELVFLG
                        MUNFLAG
                EXIT

                TC      NEWMODEX
                DEC     40
                TC      POSTJUMP
                CADR    P40LM

P71             TC      LEGAL?
                TC      NEWMODEX
                DEC     71
                TCF     ABORTJOB

P71RET          CAF     P71ADR
                TS      WHICH

                TC      UPFLAG
                ADRES   KILLROSE

                TC      INTPRET
                CALL
                        P12INIT
                EXIT

                EXTEND
                READ    CHAN30
                COM
                MASK    BIT4
                CCS     A
                TCF     ABRTSTAG

                INHINT
                TC      IBNKCALL
                CADR    ENGINOF1
                RELINT

                CAF     BIT2
                EXTEND
                RAND    CHAN30
                CCS     A
                TCF     STAGED  

                CAF     OCT206
                TC      BANKCALL
                CADR    GOPERF1
                TCF     GOTOPOOH
                TCF     STAGED
                TCF     -5

STAGED          CAF     OCT207
                TC      BANKCALL
                CADR    GOPERF1
                TCF     GOTOPOOH
                TCF     +2
                TCF     ABRTGUID

                INHINT
                CAF     ONE
                TC      WAITLIST
                EBANK=  DVCNTR
                2CADR   IGNITION

                TCF     UPTHROT1

ABRTSTAG        TC      INTPRET
                BOFF
                        FLAP
                        NEWTIME
                DLOAD   SL1
                        TGO
                STORE   TGO
                RTB
                        UPTHROT1 -2

NEWTIME         CALL
                        TGOCOMP         # IF FLAP=0, TGO=T-TIG
                GOTO
                        INJTARG

# ************************************************************************

LEGAL?          CS      FLAGWRD9        # ARE THE ABORTS ENABLED?
                MASK    LETABBIT
                CCS     A
                TCF     ABORTALM

                CS      FLAGWRD7        # IS SERVICER ON THE AIR?
                MASK    AVEGFBIT
                CCS     A
                TCF     ABORTALM
                TC      Q               # YES. ALL IS WELL.

ABORTALM        TC      POSTJUMP
                CADR    P40ALM

# ************************************************************************

TGOCOMP         RTB     DSU
                        LOADTIME
                        TIG
                SL
                        11D
                STORE   TGO
                RVQ

# ************************************************************************

5.0SEC          DEC     500

6.5SEC          DEC     650

10SECS          2DEC    1000

80SEC           2DEC    8000

50SECS          2DEC    5000 B-17

HINJECT         2DEC    18288 B-24      # 60,000 FEET EXPRESSED IN METERS.

ABTVINJ2        2DEC    +16.77924013 B-7

MDOTDPS*        2DEC    0.1425 B1


(1/DV)A         2DEC    16.20 B-7       # 2 SECONDS WORTH OF INITIAL ASCENT

                                        # STAGE ACCELERATION -- INVERTED (M/CS)
                                        # 1) PREDICATED ON A LIFTOFF MASS OF
                                        #    4869.9 KG (SNA-8-D-027  7/11/68)
                                        # 2) PREDICATED ON A CONTRIBUTION TO VEH-
                                        #    ICLE ACCELERATION FROM RCS THRUSTERS
                                        #    EQUIV. TO 1 JET ON CONTINUOUSLY.
K(1/DV)         2DEC    432.67 B-9      # DPS ENGINE THRUST IN NEWTONS / 100 CS.

(AT)A           2DEC    3.086 E-4 B9    # INITIAL ASC. STG. ACCELERATION ** M/CS.
                                        # ASSUMPTIONS SAME AS FOR (1/DV)A.

K(AT)           2DEC    .02             # SCALING CONSTANT

(TBUP)A         2DEC    98279 B-17      # ESTIMATED BURN-UP TIME OF THE ASCENT STG
                                        # ASSUMPTIONS SAME AS FOR (1/DV)A WITH THE
                                        # ADDITIONAL ASSUMPTION THAT NET MASS-FLOW
                                        # RATE = 5.299 KG/SEC = 5.135 (APS) +
                                        # .164 (1 RCS JET).

# *** THE ORDER OF THE FOLLOWING TWO CONSTANTS MUST NOT BE CHANGED *******

DPSVEX          2DEC    2943.96 E-2 B-7 # 9942 FT/SEC IN M/CS.

APSVEX          2DEC    3003.78 E-2 B-7 # 9684 FT/SEC IN M/CS.

DTDECAY*        2DEC    36.5 B-17

ATDECAY*        2DEC    12.3 B-17

(TGO)A          2DEC    45000 B-17

P70ADR          REMADR  P70TABLE
P71ADR          REMADR  P71TABLE

OCT206          OCT     206
OCT207          OCT     207

# ************************************************************************
                EBANK=  DVCNTR
ATMAGAD         2CADR   ATMAG

                EBANK=  DVCNTR
SVEXITAD        2CADR   SERVEXIT
