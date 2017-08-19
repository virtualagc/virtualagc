### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P70-P71.agc
## Purpose:     A log section of Zerlina 56, the final revision of
##              Don Eyles's offline development program for the variable 
##              guidance period servicer. It also includes a new P66 with LPD 
##              (Landing Point Designator) capability, based on an idea of John 
##              Young's. Neither of these advanced features were actually flown,
##              but Zerlina was also the birthplace of other big improvements to
##              Luminary including the terrain model and new (Luminary 1E)
##              analog display programs. Zerlina was branched off of Luminary 145,
##              and revision 56 includes all changes up to and including Luminary
##              183. It is therefore quite close to the Apollo 14 program,
##              Luminary 178, where not modified with new features.
## Reference:   pp. 822-828
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##              2017-08-19 MAS  Updated for Zerlina 56.

## Page 822
                BANK    21
                SETLOC  R11
                BANK

                EBANK=  PHSNAME5

                COUNT*  $$/P70

P70             TC      LEGAL?
P70A            CS      ZERO            # COME HERE FROM QUARTASK
                TCF     +3
P71             TC      LEGAL?
P71A            CAF     TWO             # COME HERE FROM QUARTASK
   +3           TS      Q
                INHINT
                CS      DAPBITS         # DAPBITS = OCT 40640 = BITS 6, 8, 9, 15
                MASK    DAPBOOLS        #   WHICH RESET ULLAGE, DRIFT, XOVRIINH,
                TS      DAPBOOLS        #   AND PULSES FLAGS

                CAF     1DEGDB          # INSURE DAP DEADBAND IS SET TO 1 DEGREE
                TS      DB

                CAF     BIT15           # TREATING FLAGWORDS THUS IS BAD PRACTICE
                TS      FLGWRD11

                EXTEND
                DCA     CNTABTAD
                DTCB

                EBANK=  PHSNAME5
CNTABTAD        2CADR   CONTABRT

DAPBITS         OCT     40640
1DEGDB          OCT     00554
1DEC70          DEC     70
1DEC71          DEC     71

                BANK    05
                SETLOC  ABORTS1
                BANK
                COUNT*  $$/P70

CONTABRT        CAF     ABRTJADR
                TS      BRUPT
                RESUME

ABRTJADR        TCF     ABRTJASK

ABRTJASK        CAF     OCTAL27
                AD      Q
## Page 823
                TS      L
                COM
                DXCH    -PHASE4
                INDEX   Q
                CAF     MODE70
                TS      MODREG

                TS      DISPDEX         # INSURE DISPDEX IS POSITIVE.

                CCS     Q               # SET APSFLAG IF P71.
                CS      FLGWRD10        # SET APSFLAG PRIOR TO THE ENEMA.
                MASK    APSFLBIT
                ADS     FLGWRD10

                CS      FLAGWRD5        # SET ENGONFLG.
                MASK    ENGONBIT
                ADS     FLAGWRD5

                CS      PRIO30          # INSURE THAT THE ENGINE IS ON, IF ARMED.
                EXTEND
                RAND    DSALMOUT
                AD      BIT13
                EXTEND
                WRITE   DSALMOUT

                CS      ALW66BIT        # DISALLOW P66 SELECTION
                MASK    FLAGWRD1
                TS      FLAGWRD1

                CS      FLAGWRD0        # SIGNAL THE LAD TO DISPLAY LATVEL IN
                MASK    R10FLBIT        #   INERTIAL COORDINATES AND FORVEL ZERO
                ADS     FLAGWRD0

                EXTEND                  # LOAD TEVENT FOR THE DOWNLINK.
                DCA     TIME2
                DXCH    TEVENT

                EXTEND
                DCA     ATMAGAD         # CONNECT ASCENT GUIDANCE
                DXCH    AVGEXIT

                TC      ABTKLEAN        # KILL GROUPS 1,3, AND 6.
                
                CAF     THREE           # SET UP 4.3SPOT FOR GOABORT
                TS      L
                COM
                DXCH    -PHASE4

                CA      FLAGWRD2        # IS GUIDANCE IN PROGRESS?
                MASK    SEROVBIT
## Page 824
                EXTEND
                BZF     GOENEMA         # NO

                EXTEND                  # YES:  RESET PHSNAME5 FOR PIPCYCLE
                DCA     PIPCYCAD
                DXCH    PHSNAME5

GOENEMA         TC      POSTJUMP
                CADR    ENEMA

                EBANK=  DVCNTR
PIPCYCAD        2CADR   PIPCYCLE

MODE70          DEC     70
OCTAL27         OCT     27
MODE71          DEC     71

                EBANK=  DVCNTR
ATMAGAD         2CADR   ATMAG



                BANK    32
                SETLOC  ABORTS
                BANK

                COUNT*  $$/P70

                EBANK=  DVCNTR
GOABORT         CAF     FOUR
                TS      DVCNTR

                CAF     WHICHADR
                TS      WHICH

                TC      INTPRET
                CLEAR   CLEAR
                        FLRCS
                        FLUNDISP
                CLEAR   SET
                        IDLEFLAG
                        ACC4-2FL
                SET     CALL
                        P7071FLG
                        INITCDUW
                EXIT

                TC      CHECKMM
70DEC           DEC     70
                TCF     P71RET

## Page 825
P70INIT         TC      INTPRET
                CALL
                        TGOCOMP
                DLOAD   SL
                        MDOTDPS
                        4D
                BDDV
                        MASS
                STODL   TBUP
                        MASS
                DDV     SR1
                        K(1/DV)
                STORE   1/DV1
                STORE   1/DV2
                STORE   1/DV3
                BDDV
                        K(AT)
                STODL   AT
                        100PCTTO
                STORE   TTO
                SLOAD   DCOMP
                        DPSVEX
                SR2
                STCALL  VE
                        COMMINIT
INJTARG         DLOAD
                        ABTRDOT
                STCALL  RDOTD           # INITIALIZE RDOTD.
                        YCOMP           # COMPUTE Y
                ABS     DSU
                        YLIM            # /Y/-DYMAX
                BMN     SIGN            # IF <0, XR<.5DEG, LEAVE YCO AT 0
                        YOK             # IF >0, FIX SIGN OF DEFICIT, THIS IS YCO.
                        Y
                STORE   YCO
YOK             DLOAD   DSU
                        YCO
                        Y
                SR
                        5D
                STORE   XRANGE
                SET     CALL
                        FLVR
                        THETCOMP
                DSU     BPL
                        THETCRIT
                        +4
                VLOAD   GOTO
                        J1PARM
                        STORPARM
## Page 826
  +4            VLOAD   SET             # IF J2 IS USED, SET THE
                        J2PARM          # ABORT TARGETING FLAG
                        ABTTGFLG
STORPARM        STODL   JPARM
                        RCO
                STORE   RP
                SET     EXIT
                        ROTFLAG

UPTHROT         TC      THROTUP

                TC      PHASCHNG
                OCT     04024

                TC      UPFLAG
                ADRES   FLAP

UPTHROT1        TC      BANKCALL        # VERIFY THAT THE PANEL SWITCHES
                CADR    P40AUTO         # ARE PROPERLY SET.

                TC      THROTUP

GRP4OFF         TC      PHASCHNG        # TERMINATE USE OF GROUP 4.
                OCT     00004

                TCF     ENDOFJOB

P71RET          TC      DOWNFLAG
                ADRES   LETABORT

                CAF     THRESH2         # SET DVMON THRESHOLD TO THE ASCENT VALUE.
                TS      DVTHRUSH

                TC      INTPRET
                CALL
                        P12INIT
                BON     CALL
                        FLAP
                        OLDTIME
                        TGOCOMP         # IF FLAP=0, TGO=T-TIG
                GOTO
                        INJTARG
OLDTIME         DLOAD   SL1             # IF FLAP=1,TGO=2 TGO
                        TGO
                STORE   TGO1
                EXIT

                TC      PHASCHNG
                OCT     04024

## Page 827
                EXTEND
                DCA     TGO1
                DXCH    TGO
                TCF     UPTHROT1

# ************************************************************************

                BANK    21
                SETLOC  R11
                BANK
                
                COUNT*  $$/P70

LEGAL?          CS      MMNUMBER        # IS THE DESIRED PGM ALREADY IN PROGRESS?
                AD      MODREG
                EXTEND
                BZF     ABORTALM

                CS      FLAGWRD9        # ARE THE ABORTS ENABLED?
                MASK    LETABBIT
                CCS     A
                TCF     ABORTALM

                CA      FLAGWRD7        # IS SERVICER ON THE AIR?
                MASK    AVEGFBIT
                CCS     A
                TC      Q               # YES.  ALL IS WELL.
ABORTALM        TC      FALTON
                TC      RELDSP
                TC      POSTJUMP
                CADR    PINBRNCH

                BANK    32
                SETLOC  ABORTS
                BANK

                COUNT*  $$/P70

# ************************************************************************

TGOCOMP         RTB     DSU
                        LOADTIME
                        TIG
                SL
                        11D
                STORE   TGO
                RVQ

# ************************************************************************

## Page 828
THROTUP         CAF     BIT13
                TS      THRUST
                CAF     BIT4
                EXTEND
                WOR     CHAN14
                TC      Q

# ************************************************************************

10SECS          2DEC    1000

HINJECT         2DEC    18288 B-24      # 60,000 FEET EXPRESSED IN METERS.

(TGO)A          2DEC    37000 B-17

K(AT)           2DEC    .02             # SCALING CONSTANT

WHICHADR        REMADR  ABRTABLE

# ************************************************************************
