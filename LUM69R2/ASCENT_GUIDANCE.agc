### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ASCENT_GUIDANCE.agc
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
## Reference:   pp. 844-857
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 844
                BANK            34
                SETLOC          ASCFILT
                BANK

                EBANK=          DVCNTR

                COUNT*          $$/ASENT

ATMAG           TC              PHASCHNG
                OCT             00035
                TC              PHASCHNG
                OCT             05023
                OCT             21000
                TC              INTPRET
                BON
                                FLRCS
                                ASCENT
                DLOAD           DSU
                                ABDVCONV
                                MINABDV
                BMN             CLEAR
                                ASCTERM4
                                SURFFLAG
                CLEAR           SLOAD
                                RENDWFLG
                                BIT3H
                DDV             EXIT
                                ABDVCONV
                DXCH            MPAC
                DXCH            1/DV3
                DXCH            1/DV2
                DXCH            1/DV1
                DXCH            1/DV0
                TC              PHASCHNG
                OCT             04023
                TC              INTPRET
                DLOAD           DAD
                                1/DV0
                                1/DV1
                DAD             DAD
                                1/DV2
                                1/DV3
                DMP             DMP
                                VE
                                2SEC(9)
                SL3             PDDL
                                TBUP
                SR1             DAD
                DSU
                                6SEC(18)

## Page 845
                STODL           TBUP
                                VE
                SR1             DDV
                                TBUP
                STCALL          AT
                                ASCENT

## Page 846
                BANK            30
                SETLOC          ASENT
                BANK
                COUNT*          $$/ASENT


ASCENT          VLOAD           ABVAL
                                R
                STOVL           /R/MAG
                                UNIT/R/                 # UR*2(-1)
                VXV             UNIT
                                QAXIS
                STORE           ZAXIS1
                DOT             SL1
                                V                       # Z.V = ZDOT*2(-8).
                STOVL           ZDOT                    # ZDOT*2(-7)
                                ZAXIS1
                VXV             VSL1
                                UNIT/R/                 # Z X UR = LAXIS*2(-2)
                STORE           LAXIS                   # LAXIS*2(-1)
                DOT             SL1
                                V                       # L.V = YDOT*2(-8).
                STOVL           YDOT                    # YDOT * 2(-7)
                                UNIT/R/
                DOT             SL1
                                V
                STCALL          RDOT                    # RDOT*2(-7)
                                YCOMP
                VLOAD
                                GDT1/2                  # LOAD GDT1/2*2(-7) M/CS.
                V/SC            DOT
                                2SEC(18)
                                UNIT/R/                 # G.UR*2(9) = GR*2(9).
                PDVL            VXV                     # STORE IN PDL(0)                       (2)
                                UNIT/R/                 # LOAD UNIT/R/ *2(-1).
                                V                       # UR*2(-1) X V*2(-7) = H/R*2(-8).
                VSQ             DDV                     # H(2)/R(2)*2(-16).
                                /R/MAG                  # H(2)/R(3)*2(9).
                SL1             DAD
                STADR
                STODL           GEFF                    # GEFF*2(10)M/CS/CS.
                                ZDOTD
                DSU
                                ZDOT
                STORE           DZDOT                   # DZDOT = (ZDOTD - ZDOT) * 2(7)M/CS.
                VXSC            PDDL
                                ZAXIS1

## Page 847
                                YDOTD
                DSU
                                YDOT
                STORE           DYDOT                   # DYDOT = (YDOTD - YDOT)*2(7)M/CS.
                VXSC            PDDL
                                LAXIS
                                RDOTD
                DSU
                                RDOT
                STORE           DRDOT                   # DRDOT = (RDOTD - RDOT)*2(7)M/CS.
                VXSC            VAD
                                UNIT/R/
                VAD             VSL1
                STADR
                STORE           VGVECT                  # VG = (DRDOT)R + (DYDOT)L + (DZDOT)Z.
                BON
                                FLZONE0
                                PREBRET1
                CALL
                                ASCRSTRT
                DLOAD           DMP                     # LOAD TGO
                                TGO                     # TGO GEFF
                                GEFF
                VXSC            VSL1
                                UNIT/R/                 # TGO GEFF UR
                BVSU
                                VGVECT                  # COMPENSATED FOR GEFF
                STORE           VGVECT                  # STORE FOR DOWNLINK
                MXV             VSL1                    # GET VGBODY FOR N85 DISPLAY
                                XNBPIP
                STOVL           VGBODY
                                VGVECT
                ABVAL           BOFF                    # MAGNITUDE OF VGVECT
                                FLRCS                   # IF FLRCS=0,DO NORMAL GUIDANCE
                                MAINENG
                DDV                                     # USE TGO=VG/AT  WITH RCS
                                AT/RCS
                STCALL          TGO                     # THIS WILL BE USED ON NEXT CYCLE
                                ASCTERM2
MAINENG         DDV             PUSH                    # VG/VE IN PDL(0)                       (2)
                                VE
                DMP             BDSU                    # 1-KT VG/VE
                                KT1
                                NEARONE
                DMP             DMP                     # TBUP VG(1-KT VG/VE)/VE                (0)
                                TBUP                    #  = TGO
                DSU                                     # COMPENSATE FOR TAILOFF
                                TTO
                STORE           TGO
                SR              DCOMP

## Page 848
                                11D
                STODL           TTOGO                   # TGO*2(-28)CS
                                TGO
                BON             DSU
                                IDLEFLAG
                                T2TEST
                                4SEC(17)                # ( TGO - 4 )*2(-17)CS.
                BMN
                                ENGOFF
T2TEST          DLOAD
                                TGO
                DSU             BMN                     # IF TGO - T2 NEG., GO TO CMPONENT
                                T2A
                                CMPONENT
                DLOAD           DSU
                                TBUP
                                TGO
                DDV             CALL                    # 1-TGO/TBUP
                                TBUP
                                LOGSUB
                SL              PUSH                    # -L IN PDL(0)                          (2)
                                5
                BDDV            BDSU                    # -TGO/L*2(-17)
                                TGO
                                TBUP                    # TBUP + TGO/L = D12*2(-17)
                PUSH            BON                     # STORE IN PDL(2)                        (4)
                                FLPC                    # IF FLPC = 1, GO TO CONST
                                NORATES
                DLOAD           DSU
                                TGO
                                T3
                BPL             SET                     # FLPC=1
                                RATES
                                FLPC
NORATES         DLOAD
                                HI6ZEROS
                STORE           PRATE                   # B = 0
                STORE           YRATE                   # D = 0
                GOTO
                                CONST                   # GO TO CONST
RATES           DLOAD           DSU
                                TGO
                                02D                     # TGO - D12 = D21*2(-17)
                PUSH            SL1                     # IN PDL(4)                              (6)
                BDSU            SL3                     # (1/2TGO - D21)*2(-13) = E * 2(-13)
                                TGO                     #                                        (8)
                PDDL            DMP                     # IN PDL(6)
                                TGO
                                RDOT                    # RDOT TGO * 2(-24)
                DAD             DSU                     # R + RDOT TGO

## Page 849
                                /R/MAG                  # R + RDOT TGO - RCO
                                RCO                     # MPAC = -DR*2(-24).
                PDDL            DMP                     # -DR IN PDL(8)                         (10)
                                DRDOT
                                04D                     # D21 DRDOT*2(-24)
                DAD             SL2                     # (D21 DRDOT-DR)*2(-22)                  (8)
                DDV             DDV
                                06D                     # (D21 DRDOT-DR)/E*2(-9)
                                TGO
                STORE           PRATE                   # B * 2(8)
                BMN             DLOAD                   # B>0 NOT PERMITTED
                                CHKBMAG
                                HI6ZEROS
                STCALL          PRATE
                                PROK
CHKBMAG         SR4             DDV                     # B*2(4)
                                TBUP                    # (B / TAU) * 2(21)
                DSU             BPL
                                PRLIMIT                 # ( B/ TAU) * 2(21) MAX.
                                PROK
                DLOAD           DMP
                                PRLIMIT
                                TBUP                    # B MAX. * 2(4)
                SL4                                     # BMAX*2(8)
                STORE           PRATE
PROK            DLOAD
                                TGO
                DMP             DAD                     # YDOT TGO
                                YDOT
                                Y                       # Y + YDOT TGO
                DSU             PDDL                    # Y + YDOT TGO - YCO
                                YCO                     # MPAC = - DY*2(-24.) IN PDL(8)         (10)
                                DYDOT
                DMP             DAD                     # D21 DYDOT - DY                         (8)
                                04D
                DDV             DDV
                                TGO                     # (D21 DYDOT - DY)/ E TGO*2(6)            (6)
                SL2             SETPD                   # MPAC = D*2(8)
                                04D                     #                                        (4)
                STORE           YRATE
CONST           DLOAD           DMP                     # LOAD B*2(8)
                                PRATE                   # B D12*2(-9)
                                02D
                PDDL            DDV                     # D12 B IN PDL(4)                        (6)
                                DRDOT                   # LOAD DRDOT*2(-7)
                                00D                     # -DRDOT/L*2(-7)
                SR2             DSU                     # (-DRDOT/L-D12 B)=A*2(-9)                (4)
                STADR
                STODL           PCONS
                                YRATE                   # D*2(8)

## Page 850
                DMP             PDDL                    # D12 D,EXCH WITH -L IN PDL(0)          (2,2)
                BDDV            SR2                     # -DYDOT/L*2(-9)
                                DYDOT
                DSU                                     # (-DYDOT/L-D12 D)=C*2(-9)
                                00D
                STORE           YCONS
CMPONENT        CALL
                                ASCRSTRT
                SETPD           DLOAD
                                00D
                                100CS
                DMP
                                PRATE                   # B(T-T0)*2(-9)
                DAD             DDV                     # (A+B(T-T0))*2(-9)
                                PCONS                   # (A+B(T-T0))/TBUP*2(8)
                                TBUP
                SL1             DSU
                                GEFF                    # ATR*2(9)
                STODL           ATR
                                100CS
                DMP             DAD
                                YRATE
                                YCONS                   # (C+D(T-T0))*2(-9)
                DDV             SL1
                                TBUP
                STORE           ATY                     # ATY*2(9)
                VXSC            PDDL                    # ATY UY*2(8)                             (6)
                                LAXIS
                                ATR
                VXSC            VAD                     #                                         (0)
                                UNIT/R/
                VSL1            PUSH                    # AH*2(9) IN PDL(0)                       (6)
                ABVAL           PDDL                    # AH(2) IN PDL(34)
                                AT                      # AHMAG IN PDL(6)                         (8)
                DSQ             DSU                     # (AT(2)-AH(2))*2(18)
                                34D                     # =ATP2*2(18)
                PDDL            PUSH                    #                                          (12)
                                AT
                DSQ             DSU                     # (AT(2)KR(2)-AH(2))*2(18)                 (10)
                                34D                     # =ATP3*2(18)
                BMN             DLOAD                   # IF ATP3 NEG,GO TO NO-ATP
                                NO-ATP                  # LOAD ATP2, IF ATP3 POS
                                8D
                SQRT            GOTO                    # ATP*2(9)
                                AIMER
NO-ATP          DLOAD           BDDV                    # KR AT/AH = KH                           (8)
                                6D
                VXSC                                    # KH AH*2(9)
                                00D
                STODL           00D                     # STORE NEW AH IN PDL(0)

## Page 851
                                HI6ZEROS
AIMER           SIGN
                                DZDOT
                STORE           ATP
                VXSC
                                ZAXIS1                  # ATP ZAXIS *2(8).
                VSL1            VAD                     # AT*2(9)
                                00D
                STORE           UNFC/2                  # WILL BE OVERWRITTEN IF IN VERT. RISE.
                SETPD           BON
                                00D
                                FLPI
                                P12RET
                CALL
                                ASCRSTRT
                BON
                                FLVR
                                CHECKALT
MAINLINE        VLOAD           VCOMP
                                UNIT/R/
                STODL           UNWC/2
                                TXO
                DSU             BPL
                                PIPTIME
                                ASCTERM
CLRXFLAG        CLEAR           CLEAR
                                NOR29FLG                # START R29 IN ASCENT PHASE.
                                XOVINFLG                # ALLOW X-AXIS OVERRIDE
ASCTERM         EXIT
                EXTEND
                DCA             NEG0
                DXCH            -PHASE3
                CA              FLAGWRD9
                MASK            FLRCSBIT
                CCS             A
                TCF             ASCTERM3
                TC              INTPRET
                CALL
                                FINDCDUW        -2
ASCTERM1        EXIT
   +1           EXTEND
                DCA             NEG0
                DXCH            -PHASE3
ABRTDISP        CA              FLAGWRD9                # INSURE THAT THE NOUN 63 DISPLAY IS
                MASK            FLRCSBIT                # BYPASSED IF WE ARE IN THE RCS TRIMMING
                CCS             A                       # MODE OF OPERATION
                TCF             ASCTERM3
                CA              FLAGWRD8                # BYPASS DISPLAYS IF ENGINE FAILURE IS
                MASK            FLUNDBIT                # INDICATED.
                CCS             A

## Page 852
                TCF             ASCTERM3
                CAF             V06N63*
                TC              BANKCALL
                CADR            GODSPR
                TCF             ASCTERM3
ASCTERM2        EXIT
                TC              PHASCHNG
                OCT             00003
ASCTERM3        TCF             ENDOFJOB
ASCTERM4        EXIT
                INHINT
                TC              IBNKCALL                # NO GUIDANCE THIS CYCLE -- HENCE ZERO
                CADR            ZATTEROR                # THE DAP ATTITUDE ERRORS.
                TCF             ASCTERM1        +1

CHECKALT        DLOAD           DSU
                                /R/MAG
                                /LAND/
                DSU             BMN                     # IF H LT 25K CHECK Z AXIS ORIENTATION.
                                25KFT
                                CHECKYAW
EXITVR          DLOAD           DAD
                                PIPTIME
                                10SECS
                STORE           TXO
                CLRGO
                                FLVR
                                MAINLINE

ASCRSTRT        STQ             EXIT
                                TEMPR60
                CA              FLPIBIT
                AD              FLZONBIT
                MASK            FLAGWRD9
                CCS             A
                TCF             +3
                TC              PHASCHNG
                OCT             04023
    +3          TC              INTPRET
                GOTO
                                TEMPR60

                BANK            27
                SETLOC          ASENT1
                BANK

SETXFLAG        =               CHECKYAW

CHECKYAW        SET
                                XOVINFLG                # PROHIBIT X-AXIS OVERRIDE

## Page 853
                DLOAD           VXSC
                                ATY
                                LAXIS
                PDDL            VXSC
                                ATP
                                ZAXIS1
                VAD             UNIT
                PUSH            DOT
                                YNBPIP
                ABS             DSU
                                SIN5DEG
                BPL             DLOAD
                                KEEPVR
                                RDOT
                DSU             BPL
                                40FPS
                                EXITVR

KEEPVR          VLOAD           STADR                   # RECALL LOSVEC FROM PUSHLIST
                STOVL           UNWC/2
                                UNIT/R/
                STCALL          UNFC/2
                                ASCTERM

ENGOFF          RTB
                                LOADTIME
                DSU             DAD
                                PIPTIME
                                TTOGO
                DCOMP           EXIT
                TC              TPAGREE                 # FORCE SIGN AGREEMENT ON MPAC, MPAC +1.
                CAF             EBANK7
                TS              EBANK
                EBANK=          TGO
BIT3H           INHINT                                  # USED AS A CONSTANT
                CCS             MPAC            +1
                TCF             +3                      # C(A) = DT - 1 BIT
                TCF             +2                      # C(A) = 0
                CAF             ZERO                    # C(A) = 0
                AD              BIT1                    # C(A) = 1 BIT OR DT.
                TS              ENGOFFDT
                TC              TWIDDLE
                ADRES           ENGOFF1
                TC              PHASCHNG
                OCT             47014
                -GENADR         ENGOFFDT
                EBANK=          TGO
                2CADR           ENGOFF1

## Page 854
                TC              INTPRET
                SET             GOTO
                                IDLEFLAG                # DISABLE DELTA-V MONITOR
                                T2TEST

ENGOFF1         TC              IBNKCALL                # SHUT OFF THE ENGINE.
                CADR            ENGINOF2

                CAF             PRIO17                  # SET UP A JOB FOR THE ASCENT GUIDANCE
                TC              FINDVAC                 # POSTBURN LOGIC.
                EBANK=          WHICH
                2CADR           CUTOFF
                TC              PHASCHNG
                OCT             07024
                OCT             17000
                EBANK=          TGO
                2CADR           CUTOFF
                TCF             TASKOVER

CUTOFF          TC              UPFLAG                  # SET FLRCS FLAG.
                ADRES           FLRCS

  -5            CAF             V16N63
                TC              BANKCALL
                CADR            GOFLASH
                TCF             TERMASC
                TCF             CUTOFF1
                TCF             -5

CUTOFF1         INHINT
                TC              IBNKCALL                # ZERO ATTITUDE ERRORS BEFORE REDUCING DB.
                CADR            ZATTEROR
                TC              IBNKCALL
                CADR            SETMINDB
                TC              PHASCHNG
                OCT             04024

   -5           CAF             V16N85C
                TC              BANKCALL
                CADR            GOFLASH
                TCF             TERMASC
                TCF             +2                      # PROCEED
                TCF             -5

TERMASC         TC              PHASCHNG
                OCT             04024

                INHINT                                  # RESTORE DEADBAND DESIRED BY ASTRONAUT.

## Page 855
                TC              IBNKCALL
                CADR            RESTORDB
                TC              DOWNFLAG                # DISALLOW ABORTS AT THIS TIME.
                ADRES           LETABORT
                TCF             GOTOPOOH

YCOMP           VLOAD           DOT
                                UNIT/R/
                                QAXIS
                SL1             ARCSIN
                DMP             DMP
                                RCO
                                2PI/8
                SL3
                STORE           Y
                RVQ

V16N63          VN              1663
V16N85C         VN              1685

                BANK            30
                SETLOC          ASENT
                BANK

## Page 856
# ASCENT GUIDANCE CONSTANTS

100CS           EQUALS          2SEC(18)
T2A             EQUALS          2SEC(17)
4SEC(17)        2DEC            400             B-17
2SEC(17)        2DEC            200             B-17
T3              2DEC            1000            B-17
40FPS           2DEC            .12192          B-7     # 40 FT/SEC EXPRESSED IN M/CS.
6SEC(18)        2DEC            600             B-18
BIT4H           OCT             10
2SEC(9)         2DEC            200             B-9
V06N63*         VN              0663
V06N76          VN              0676
V06N33A         VN              0633

KT1             2DEC            0.5000
PRLIMIT         2DEC            -.0639                  # (B/TBUP)MIN=-.1FT.SEC(-3)
SIN5DEG         2DEC            .08716          B-2
MINABDV         2DEC            .0356           B-5     # 10 PERCENT BIGGER THAN GRAVITY
1/DV0           =               MASS1

## Page 857
# THE LOGARITHM SUBROUTINE

                BANK            24
                SETLOC          FLOGSUB
                BANK

# INPUT ..... X IN MPAC
# OUTPUT ..... -LOG(X) IN MPAC

LOGSUB          NORM            BDSU
                                MPAC            +6
                                NEARONE
                EXIT
                TC              POLY
                DEC             6
                2DEC            .0000000060
                2DEC            -.0312514377
                2DEC            -.0155686771
                2DEC            -.0112502068
                2DEC            -.0018545108
                2DEC            -.0286607906
                2DEC            .0385598563
                2DEC            -.0419361902

                CAF             ZERO
                TS              MPAC            +2
                EXTEND
                DCA             CLOG2/32
                DXCH            MPAC
                DXCH            BUF             +1
                CA              MPAC            +6
                TC              SHORTMP
                DXCH            MPAC            +1
                DXCH            MPAC
                DXCH            BUF             +1
                DAS             MPAC
                TC              INTPRET
                DCOMP           RVQ

CLOG2/32        2DEC            .0216608494
