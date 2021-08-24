### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ASCENT_GUIDANCE.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



                BANK            30
                SETLOC          ASENT
                BANK
                COUNT*          $$/ASENT

                EBANK=          DVCNTR

ATMAG           TC              INTPRET
                SETPD           BON
                                0
                                FLRCS
                                ASCENT
                BOFF            DLOAD
                                ENGONFLG
                                ASCTERM2
                                ABDVCONV
                DSU             BMN
                                MINABDV
                                ASCTERM1
                CLEAR           SLOAD
                                SURFFLAG
                                BIT4H
                DDV             EXIT
                                ABDVCONV
                DXCH            MPAC
                DXCH            1/DV3
                DXCH            1/DV2
                DXCH            1/DV1
                DXCH            MPAC
                TC              PHASCHNG
                OCT             10035
                TC              INTPRET
                DAD
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

                STODL           TBUP
                                VE
                SR1             DDV
                                TBUP
                STORE           AT

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
                MXV             VSL1                    # GET VGBODY FOR N85 DISPLAY
                                XNBPIP
                STORE           VGBODY
                BON             DLOAD
                                FLRCS
                                ASCTERM2
                                TGO
                DSU
                                2SEC(17)
                STORE           TGO
                DMP             VXSC                    # TGO GEFF
                                GEFF
                                UNIT/R/                 # TGO GEFF UR
                VSL1            BVSU
                                VGVECT                  # COMPENSATED FOR GEFF
                ABVAL           DDV
                                VE
                PUSH            DMP                     # VG/VE IN PDL(0)                       (2)
                                KT1
                BDSU            DMP                     # 1-KT VG/VE
                                NEARONE
                DMP             DSU                     # TBUP VG(1-KT VG/VE)/VE                (0)
                                TBUP                    #  = TGO
                                TTO                     # COMPENSATE FOR TAILOFF
                STORE           TGO
                SR              DCOMP

                                11D
                STODL           TTOGO                   # TGO*2(-28)CS
                                TGO
                BON             BON
                                ENGOFFSW
                                T2TEST
                                FLIC
                                T2TEST
                DSU             BMN
                                4SEC(17)                # ( TGO - 4 )*2(-17)CS.
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
CHKBMAG         SR4             DDV                     # B*2(4)
                                TBUP                    # (B / TAU) * 2(21)
                DSU             BMN
                                PRLIMIT                 # ( B/ TAU) * 2(21) MAX.
                                PROK
                DLOAD           DMP
                                PRLIMIT
                                TBUP                    # B MAX. * 2(4)
                SL4             SIGN                    # BMAX*2(8)
                                PRATE
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

                DMP             PDDL                    # D12 D,EXCH WITH -L IN PDL(0)          (2,2)
                BDDV            SR2                     # -DYDOT/L*2(-9)
                                DYDOT
                DSU                                     # (-DYDOT/L-D12 D)=C*2(-9)
                                00D
                STORE           YCONS
CMPONENT        SETPD           DLOAD
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

                                HI6ZEROS
AIMER           SIGN
                                DZDOT
                STORE           ATP
                VXSC
                                ZAXIS1                  # ATP ZAXIS *2(8).
                VSL1            VAD                     # AT*2(9)
                                00D
                UNIT
                STORE           UNFC/2                  # WILL BE OVERWRITTEN IF IN VERT. RISE.
                SETPD           DLOAD
                                00D
                                ATP                     # ATP(2)*2(18)
                DSQ             PDDL
                                ATY                     # ATY(2)*2(18)
                DSQ             DAD
                SQRT            SL1
                BDDV            ARCSIN
                                ATY
                STOVL           YAW
                                UNIT/R/
                DOT             SL1
                                UNFC/2
                ARCCOS          DCOMP
                STORE           PITCH
                BON             BON
                                FLPI
                                P12RET
                                FLIC
                                ABORTIGN
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
                RTB
                                CLRXFLAG                # ALLOW X-AXIS OVERRIDE
ASCTERM         BON             CALL
                                FLRCS
                                ASCTERM2
                                FINDCDUW        -2
ASCTERM1        EXIT
ABRTDISP        CA              FLAGWRD9                # INSURE THAT THE NOUN 63 DISPLAY IS
                MASK            FLRCSBIT                # BYPASSED IF WE ARE IN THE RCS TRIMMING
                CCS             A                       # MODE OF OPERATION
                TCF             ASCTERM3
                CA              FLAGWRD8                # BYPASS DISPLAYS IF ENGINE FAILURE IS
                MASK            FLUNDBIT                # INDICATED.
                CCS             A

                TCF             ASCTERM3
                CAF             V06N63*
                TC              BANKCALL
                CADR            GODSPR
                TCF             ASCTERM3
ASCTERM2        EXIT
ASCTERM3        TC              PHASCHNG
                OCT             00035
                TCF             ENDOFJOB

CHECKALT        DLOAD           DSU
                                /R/MAG
                                /LAND/
                DSU             BMN                     # IF H LT 25K CHECK Z AXIS ORIENTATION.
                                25KFT
                                CHECKYAW
                DLOAD           DAD
                                PIPTIME
                                10SECS
                STORE           TXO
EXITVR          CLRGO
                                FLVR
                                MAINLINE

CHECKYAW        RTB
                                SETXFLAG                # PROHIBIT X-AXIS OVERRIDE
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
                                50FPS
                                EXITVR

KEEPVR          VLOAD           STADR                   # RECALL LOSVEC FROM PUSHLIST
                STOVL           UNWC/2
                                UNIT/R/
                STCALL          UNFC/2
                                ASCTERM

ENGOFF          RTB             DSU
                                LOADTIME
                                PIPTIME
                DAD             DCOMP
                                TTOGO
                EXIT
                TC              TPAGREE                 # FORCE SIGN AGREEMENT ON MPAC, MPAC +1.
                CAF             EBANK7
                TS              EBANK
                EBANK=          TGO
                INHINT                                  # USED AS A CONSTANT
                CCS             MPAC            +1
                TCF             +3                      # C(A) = DT - 1 BIT
                TCF             +2                      # C(A) = 0
                CAF             ZERO                    # C(A) = 0
                AD              BIT1                    # C(A) = 1 BIT OR DT.
                TS              ENGOFFDT
                TC              TWIDDLE
                ADRES           ENGOFF1
                TC              PHASCHNG
                OCT             47016
                -GENADR         ENGOFFDT
                EBANK=          TGO
                2CADR           ENGOFF1

                TC              INTPRET
                SET             GOTO
                                ENGOFFSW                # DISABLE DELTA-V MONITOR
                                T2TEST

ENGOFF1         TC              IBNKCALL                # SHUT OFF THE ENGINE.
                CADR            ENGINOF1

                CAF             PRIO21                  # SET UP A JOB FOR THE ASCENT GUIDANCE
                TC              FINDVAC                 # POSTBURN LOGIC.
                EBANK=          WHICH
                2CADR           CUTOFF
                TC              PHASCHNG
                OCT             07026
                OCT             21000
                EBANK=          TGO
                2CADR           CUTOFF
                TCF             TASKOVER

CUTOFF          TC              UPFLAG                  # SET FLRCS FLAG.
                ADRES           FLRCS

  -5            CAF             V16N63
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH
                TCF             CUTOFF1
                TCF             -5

CUTOFF1         INHINT
                TC              IBNKCALL
                CADR            SETMINDB
                TC              PHASCHNG
                OCT             04026

   -5           CAF             V16N85C
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH
                TCF             GOTOPOOH                # PROCEED
                TCF             -5

SETXFLAG        TC              UPFLAG
                CADR            XOVINFLG
                TCF             DANZIG

CLRXFLAG        TC              DOWNFLAG
                CADR            XOVINFLG
                TCF             DANZIG

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

# THE LOGARITHM SUBROUTINE

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

# ASCENT GUIDANCE CONSTANTS

100CS           EQUALS          2SEC(18)
T2A             EQUALS          2SEC(17)
4SEC(17)        2DEC            400             B-17
2SEC(17)        2DEC            200             B-17
T3              2DEC            1000            B-17
50FPS           2DEC            .1524           B-7     # 40 FT/SEC EXPRESSED IN M/CS.
6SEC(18)        2DEC            600             B-18
CLOG2/32        2DEC            .0216608494
BIT4H           OCT             10
2SEC(9)         2DEC            200             B-9
V16N85C         VN              1685
V16N63          VN              1663
V06N63*         VN              0663
V06N76          VN              0676
V06N33A         VN              0633

KT1             2DEC            0.5000
PRLIMIT         2DEC            .25                     # (B/TBUP)MIN=-.1FT.SEC(-3)
SIN5DEG         2DEC            .08716          B-2
MINABDV         2DEC            .0625           B-5     # 10 PERCENT BIGGER THAN GRAVITY

