### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P12.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 839-843
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 839
                BANK    24
                SETLOC  P12
                BANK

                EBANK=  DVCNTR
                COUNT*  $$/P12

P12LM           TC      PHASCHNG
                OCT     04024

                TC      BANKCALL
                CADR    R02BOTH         # CHECK THE STATUS OF THE IMU.

                TC      UPFLAG
                ADRES   MUNFLAG

                TC      UPFLAG          # INSURE 4-JET TRANSLATION CAPABILITY.
                ADRES   ACC4-2FL

                TC      UPFLAG          # PREVENT R10 FROM ISSUING CROSS-POINTER
                ADRES   R10FLAG         # OUTPUTS.

                TC      DOWNFLAG        # CLEAR RENDEZVOUS FLAG  FOR P22
                ADRES   RNDVZFLG

                CAF     THRESH2         # INITIALIZE DVMON
                TS      DVTHRUSH
                CAF     FOUR
                TS      DVCNTR

                CA      ZERO
                TS      TRKMKCNT        # SHOW THAT R29 DOWNLINK DATA ISN'T READY.
                CAF     V06N33A
                TC      BANKCALL        # FLASH TIG
                CADR    GOFLASH
                TCF     GOTOPOOH
                TCF     +2              # PROCEED
                TCF     -5              # ENTER

                TC      PHASCHNG
                OCT     04024

                TC      INTPRET
                CALL                    # INITIALIZE WM AND /LAND/
                        GUIDINIT
                SET     CALL
                        FLPI
                        P12INIT

P12LMB          DLOAD
                        (TGO)A          # SET TGO TO AN INITIAL NOMINAL VALUE.
## Page 840
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

                TC      PHASCHNG
                OCT     04024

                TC      INTPRET
                DLOAD   SL
                        XRANGE
                        5D
                DAD
                        Y
                STODL   YCO
                        APO		# RA = APO + /LAND/
                SL
## Page 841
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
                        49FPS
                        V1S
                STORE   V               # V(TIPOVER) = V(IGN) + 57FPS (UNIT/R/)
                SETGO
                        FLVR
                        ASCENT
P12RET          DLOAD
                        ATP             # ATP(2)*2(18)
                DSQ     PDDL
                        ATY             # ATY(2)*2(18)
                DSQ     DAD
                BZE     SQRT
                        YAWDUN
                SL1     BDDV
                        ATY
                ARCSIN
YAWDUN          STOVL   YAW
                        UNFC/2
                UNIT    DOT
                        UNIT/R/
                SL1     ARCCOS
                DCOMP
                STORE   PITCH
                EXIT
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
## Page 842
P12INIT         DLOAD                   # INITIALIZE ENGINE DATA.  USED FOR P12 AND
                        (1/DV)A         # P71.
                STORE   1/DV3
                STORE   1/DV2
                STODL   1/DV1
                        (AT)A
                STODL   AT
                        (TBUP)A
                STODL   TBUP
                        ATDECAY
                DCOMP   SL
                        11D
                STORE   TTO
                SLOAD   DCOMP
                        APSVEX
                SR2
                STORE   VE
                BOFF    RVQ
                        FLAP
                        COMMINIT
COMMINIT        DLOAD   DAD             # INITIALIZE TARGET DATA. USED BY P12, P70
                        HINJECT         # AND P71 IF IT DOES NOT FOLLOW P70.
                        /LAND/
                STODL   RCO
                        HI6ZEROS
                STORE   TXO
                STORE   YCO
                STORE   RDOTD
                STOVL   YDOTD
                        VRECTCSM
                VXV     MXV
                        RRECTCSM
                        REFSMMAT
                UNIT
                STODL   QAXIS
                        ABTVINJ2        # TENTATIVELY STORE LOW INJECTION VELOCITY
                STORE   ZDOTD
                BON
                        FLPI
                        LOVEL
                SLOAD   DSU
                        TBRKPNT         # TBRKPNT-TGO
                        TGO
                BMN     DLOAD           # IF TGO>TBRKPNT,LOW VINJECT IS OK;RETURN
                        LOVEL
                        ABTVINJ1	# FOR TGO.TBRKPNT USE HI VELOCITY.
                STORE   ZDOTD
LOVEL           RVQ
GUIDINIT        STQ     SETPD
                        TEMPR60
## Page 843
                        0D
                VLOAD   PUSH
                        UNITZ
                RTB     PUSH
                        LOADTIME
                SLOAD   CALL
                        (APO)
                        RP-TO-R
                MXV     VXSC
                        REFSMMAT
                        MOONRATE
                STOVL   WM
                        RLS
                ABVAL   SL3
                STCALL  /LAND/
                        TEMPR60

P12ADRES        REMADR  P12TABLE        # NOT IN SAME BANK.
49FPS           2DEC    .149352 B-6     # EXPECTED RDOT AT TIPOVER

(APO)           2DEC    55597.5 B-29    # 30 N.M. EXPRESSED IN METERS.
