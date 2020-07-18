### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P12.agc
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

                BANK    24
                SETLOC  P12
                BANK

                EBANK=  DVCNTR
                COUNT*  $$/P12

P12LM           TC      BANKCALL
                CADR    R02BOTH         # CHECK THE STATUS OF THE IMU.

                TC      UPFLAG
                ADRES   MUNFLAG

                TC      UPFLAG
                ADRES   FLP70

                TC      UPFLAG
                ADRES   SURFFLAG

                EXTEND
                DCA     TIG(AS)
                DXCH    TIG

                CAF     V06N33A
                TC      BANKCALL        # FLASH TIG
                CADR    GOFLASH
                TCF     GOTOPOOH
                TCF     +2              # PROCEED
                TCF     -5              # ENTER

                TC      INTPRET
                VLOAD   ABVAL
                        RLS
                SL3
                STORE   /LAND/
                SSP
                        QPRET
                        P12LMB

P12INIT         DLOAD                   # INITIALIZE ENGINE DATA.  USED FOR P12 AND
                        (1/DV)A         # P71.
                STORE   1/DV3
                STORE   1/DV2
                STODL   1/DV1
                        (AT)A
                STODL   AT
                        (TBUP)A
                STODL   TBUP
                        ATDECAY*
                STODL   TTO
                        APSVEX
                STORE   VE
COMMINIT        DLOAD   DAD             # INITIALIZE TARGET DATA. USED BY P12, P70
                        HINJECT         # AND P71 IF IT DOES NOT FOLLOW P70.
                        /LAND/
                STODL   RCO
                        HI6ZEROS
                STORE   TXO
                STORE   YCO
                STORE   RDOTD
                STODL   YDOTD
                        ABTVINJ2        # TENTATIVELY STORE LOW INJECTION VELOCITY
                STOVL   ZDOTD
                        V-OTHER
                VXV     MXV
                        R-OTHER
                        REFSMMAT
                UNIT
                STORE   QAXIS

                RVQ

P12LMB          DLOAD
                        (TGO)A          # SET TGO TO AN INITIAL NOMINAL VALUE.
                STODL   TGO
                        TIG
                STCALL  TDEC1
                        LEMPREC         # ROTATE THE STATE VECTORS TO THE
                VLOAD   MXV             # IGNITION TIME.
                        VATT
                        REFSMMAT
                VSL1
                STOVL   V1S             # COMPUTE V1S = VEL(TIG)*2(-7) M/CS.
                        RATT
                MXV     VSL6
                        REFSMMAT
                STCALL  R               # COMPUTE R = POS(TIG)*2(-24) M.
                        MUNGRAV         # COMPUTE GDT1/2(TIG)*2(-7)M/CS.
                VLOAD   UNIT
                        R
                STCALL  UNIT/R/         # COMPUTE UNIT/R/ FOR YCOMP.
                        YCOMP
                SR      DCOMP
                        5D
                STODL   XRANGE          # INITIALIZE XRANGE FOR NOUN 76.
                        (APO)
                STORE   APO             # INITIALIZE APO FOR NOUN 76.
                EXIT

                TC      PHASCHNG
                OCT     04024

NEWLOAD         CAF     V06N76          # FLASH CROSS-RANGE AND APOLUNE VALUES.
                TC      BANKCALL
                CADR    GOFLASH
                TCF     GOTOPOOH
                TCF     +2              # PROCEED
                TCF     NEWLOAD         # ENTER NEW DATA.

                CAF     P12ADRES
                TS      WHICH

                TC      INTPRET
                DLOAD   SL
                        XRANGE
                        5D
                DAD
                        Y
                STODL   YCO
                        APO             # RA = APO + /LAND/
                SL
                        5D
                DAD     PUSH            # RA*2(-24) IN MPAC AND PDL
                        /LAND/
                DMP     PDDL            # 2 RA MU*2(-62) IN PDL, LOAD RA
                        MUM(-37)
                DAD     DMP             # (RA+RP)*2(-24)
                        RCO             # RP(RA+RP)*2(-48)
                        RCO
                BDDV    SQRT            # 2 MU RA/RP(RA+RP)*2(-14)=ZDOTD(2)
                STADR
                STOVL   ZDOTD
                        UNIT/R/
                VXSC    VAD
                        28.5FPS
                        V1S
                STORE   V               # V(TIPOVER) = V(IGN) + 57FPS (UNIT/R/)
                SET     SETGO
                        FLPI
                        FLVR
                        ASCENT
P12RET          EXIT
                TC      PHASCHNG
                OCT     04024

                TC      DOWNFLAG
                ADRES   FLPI

                INHINT
                TC      IBNKCALL
                CADR    PFLITEDB
                RELINT

                TC      POSTJUMP
                CADR    BURNBABY


P12ADRES        REMADR  P12TABLE        # NOT IN SAME BANK.
28.5FPS         2DEC    .08685 B-6      # EXPECTED RDOT AT TIPOVER

MUM(-37)        2DEC*   4.9027780 E8 B-37*

(APO)           2DEC    55597.5 B-29    # 30 N.M. EXPRESSED IN METERS.
