### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ASCENT_STEERING.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 853-861
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-11 HG   Transcribed
##              2017-06-15 HG   Fix value T2 2DEC 200 B-17 -> 2DEC 200
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 853
#    PROGRAM NAME--ASCENT        BY--BERMAN
#     ASCENT IS AN E-GUIDANCE SCHEME WHICH PRODUCES A DESIRED UNIT THRUST VECTOR DURING ASCENT BURNS, WITH THE
# CURRENT STATE AND ESTIMATED TGO,AND ESTIMATED VCO (VELOCITIES IN ASCENT ARE DEFINED IN LOCAL VERTICAL SYSTEMS),
# RCO IS ESTIMATED. THIS ENABLES THE LAMBERT SUBROUTINE TO SOLVE FOR A BETTER VCO. THIS AND V ALLOW US TO IMPROVE
# THE ESTIMATE OF TGO. FINALLY, TGO AND THE DESIRED CHANGES IN R AND V ARE USED TO COMPUTE UT.
#    MODING SWITCHES
#       HC--IF 0, ABVAL(RCO) IS CONSTRAINED TO A SPECIFIED VALUE-- IF 1, ABVAL(RCO) IS NOT CONSTRAINED, BUT IS
#           ESTIMATED.

#       PASS-- IF 0, USE LAMBERT TO UPDATE VCO-- IF 1, SKIP LAMBERT. PASS IS INVERTED EVERY ENTRY TO ASCENT, THUS
#           LAMBERT IS USED EVERY OTHER ENTRY.
#       DIRECT-- IF 0, SPECIFIED INJECTION CONDITIONS ARE USED AND PASS IS SET PERMANENTLY TO 1 AFTER THE FIRST
#           ENTRY-- IF 1, LAMBERT IS USED FOR TARGETING UNDER CONTROL OF            PASS.

# CALLING SEQUENCE
#    ASCENT IS ENTERED IN INTERPRETIVE BY
#                                                  GOTO
#                                                         ASCENT

# NORMAL EXIT
#    NORMAL EXIT FROM ASCENT IS BY
#                                                  GOTO
#                                                         ASCRET

# WHERE THE PREAPS PROGRAM PUTS A RETURN ADDRESS IN ASCRET FOR THE FIRST (PRE-IGNITION) ENTRY, AND THEN STORES
# FINDCDUD IN ASCRET SO THAT SUBSEQUENT EXITS WILL BE TO FINDCDUD.

# DEBRIS
#    USES 118 ERASABLE LOCATIONS CURRENTLY ASSIGNED TO  AMEMORY  THRU  AMEMORY +117. (SEE PG. 32 OF SUNBURST FOR
# VARIABLE NAMES.

# RESERVED LOCATIONS

#    THE FOLLOWING 44 LOCATIONS MUST NOT BE DISTURBED DURING MP13 OR MP4 -- PAXIS1,QAXIS,SAXIS,ATMEAS,RDOTD,YDOTD,
# ZDOTD,RCO,TGO,PCONS,PRATE,TINT,TREF,YCONS,ASCRET. THE REMAINING 74 LOCATIONS MAY BE USED BETWEEN EXIT FROM
# ASCENT AND RE-ENTRY INTO THE THRUST MAGNITUDE FILTER, ATMAG.
                BANK            32
                EBANK=          TCO
ASCENT          VLOAD           V/SC                    # FORM GRAVITY SCALED 2(10)M/CS/CS FROM
                                GDT1/2                  # GDT1/2 SCALED 2(-7)M/CS
                                2SEC(18)
                AXC,1           DOT                     # LOAD X1 WITH -5   (OLD NSHIFT CONTENTS)
                                5

                                UNITR                   # G,URX2(9)=GRX2(9)
                PDVL            VXV                     # STORE IN PDL(0)                        2
                                UNITR                   # LOAD UNITR*2(-1)
                                VN                      # UR*2(-1) X VN*2(-7)=H/R*2(-8)
                PUSH            UNIT                    # STORE H/R IN PDL (2), GET UH*2(-1)     8
                STOVL           UNNORM                  # STORE UH IN UNNORM, LOAD H/R           2
                VSQ             DDV                     # H(2)/R(2)*2(-16)
                                RMAG                    # H(2)/R(3)*2(9)
                SL1             DAD

## Page 854
                STADR

                STOVL           GEFF                    # STORE GEFFX2(9) (POS UP)
                                UNITR                   # LOAD URX2(-1)
                VXV             UNIT                    # URX2(-1)XQX2(-1)=ZAXISXSIN
                                QAXIS                   # ZAXISX2(-1)
                STORE           ZAXIS                   # STORE ZAXIS
                VXV             VCOMP                   # ZAXISX2(-1)XQAXISX2(-1)=-MAXISX2(-2)
                                QAXIS                   # MAXISX2(-2)
                VSL1            PDVL                    # MAXISX2(-1) IN PDL(0)                  6
                                UNITR                   # LOAD URX2(-1)
                DOT             SL1                     # URX2(-1).VX2(-7)=VRX2(-8)
                                VN                      # SHIFT TO VRX2(-7)
                STOVL           RDOT                    # STORE IN RDOT

                                ZAXIS                   # LOAD ZAXISX2(-1)
                DOT             SL1                     # ZAXISX2(-1).VX2(-7)=ZDOTX2(-8)        (6
                                VN                      # SHIFT TO ZDOTX2(-7)
                STOVL           ZDOT                    # STORE IN ZDOT
                                ZAXIS                   # LOAD ZAXISX2(-1)
                VXV             VSL1                    # Z*2(-1)XUR*2(-1)=LAXIS*2(-2)
                                UNITR                   # SHIFT TO LAXIS*2(-1)
                STORE           LAXIS                   # STORE
                DOT             SL1                     # LAXIS.VN=YDOT*2(-8)
                                VN                      # SHIFT TO YDOT*2(-7)

                STOVL           YDOT                    # STORE IN YDOT
                                00D                     # LOAD MAXISX2(-1)
                DOT             SL2                     # MAXISX2(-1).SX2(-1)=RZX2(-2)
                                SAXIS                   # SHIFT TO RZ
                PUSH            DSQ                     # STORE RZ IN PDL(6)                     8
                PUSH            DMP                     # STORE RZ(2) IN PDL(8)                 10
                                DP3/80                  # 3/8ORZ(2)
                DAD             DMP                     # 1/12+3/8ORZ(2)
                                1/12TH                  # RZ(2)/12+3/8ORZ(4)                     8
                DAD             DMP                     # 1/2+RZ(2)/12+3/8ORZ(4)
                                DP.5                    # RZ(...)                                6
                DMP             SL1                     # ZX2(N-31)

                                RCO                     # SHIFT TO ZX2(N-30)
                PDVL            DOT                     # STORE Z IN PDL(6)                      8
                                UNITR                   # LOAD URX2(-1)
                                QAXIS                   # URX2(-1).QX2(-1)=RYX2(-2)
                STORE           RY                      # STORE IN RY
                DSQ             DMP                     # RY(2)X2(-4)                           (8
                                DP2/3H                  # RY(2)/24
                DAD             DMP
                                DP.25                   # 1/4+RY(2)/24
                                RY                      # RY(1+RY(2)/6)/16

                DMP             SL4                     # RCORY(1+RY(2)/6)X2(N-34)=YX2(N-34)
                                RCO                     # YX2(N-30)
                PDDL            DSU                     # STORE IN PDL(8)                       10
                                TGO                     # LOAD TGO*2(-17)
                                DTASC                   # (TGO-DT)*2(-17)

## Page 855
                STORE           TGO                     # REPLACE IN TGO
                BOFF            DLOAD                   # IF HC=0, GO TO HOLDR
                                HC
                                HOLDR
                                RDOT                    # LOAD RDOT*2(-7)
                DAD             DMP                     # (RDOT+RDOTD)*2(-7)

                                RDOTD
                                TGO                     # TGO(RDOT+RDOTD)*2(-24)
                SR1             DAD                     # SHIFT TO RGO*2(-24)
                                RMAG                    # FORM RCO*2(-24)
                STORE           RCO                     # STORE IN RCO

HOLDR           BON             BON                     # IF DIRECT=1, GO TO LAMPREP
                                DIRECT
                                LAMPREP
                                PASS                    # IF PASS=1, GO TO GAIN+1
                                GAIN            +1
                SET             DLOAD                   # IF PASS=0, SET TO 1

                                PASS
                                VINJ                    # LOAD VINJ
                STODL           ZDOTD                   # ZDOTD=VINJ
                                DP0                     # CLEAR MPAC
                STORE           RDOTD                   # RDOTD=0
                GOTO                                    # GO TO GAIN WITH YDOTD=0 IN MPAC
                                GAIN
LAMPREP         BOFF            DLOAD                   # IF LAMB NOT DONE, GO TO GAIN+1
                                DONESW
                                GAIN            +1

                                YDOT                    # LOAD YDOT*2(-7)
                DMP             PDDL                    # YDOT TGO*2(-24)
                                TGO                     # PUSH DOWN                             12
                                YDOTD                   # LOAD YDOTD*2(-7)
                DMP             DAD                     # YDOTD TGO*2(-24)
                                TGO                     # TGO(YDOT+YDOTD)*2(-24)                10
                SL*             DAD                     # YGO/2*2(N-30)
                                0               -7,1    #                                        8
                STADR                                   # YCO*2(N-30)
                STODL           32D                     # STORE IN PDL(32)
                                ZDOT                    # LOAD ZDOTX2(-7)
                DAD             DMP                     # (ZDOT+ZDOTD)X2(-7)

                                ZDOTD                   # TGO(ZDOT+ZDOTD)X2(-24)
                                TGO
                SL*             DAD                     # SHIFT TO TGO(ZDOT+ZDOTD)X2(N-34)
                                0               -10D,1  # ZCOX2(N-33)                            6
                DDV             DDV                     # ZRADCO/8
                                RCO
                                PI/4                    # ZRADCO/2PI
                PUSH            COS                     # STORE IN PDL(6),TAKE 1/2COS            8
                PDDL            SIN                     # EXCH.ZRADCO/2PI WITH .5COS,TAKE .5SIN  8
                PUSH            VXSC                    # STORE 1/2SIN IN PDL(8)                10

## Page 856
                                SAXIS                   # S/4SIN
                PDDL            VXSC                    # STORE IN PDL(10),LOAD1/2COS           16

                                06D                     # P/4COS
                                PAXIS1
                VAD                                     # S/4SIN+P/4COS,                        10
                PDDL                                    # STORE IN PDL(10)                      16
                                32D                     # LOAD YCOX2(N-30)
                DSQ             PDDL                    # YCO(2)X2(2N-60),STORE IN PDL(16)      18
                                RCO                     # LOAD RCOX2(N-30)
                DSQ             DSU                     # (RCO(2)-YCO(2))X2(2N-60)              16
                SQRT            VXSC                    # (RCO(2)-YCO(2))(1/2)X2(N-30)XPDL(10)  10
                VSL1            PDDL                    # SHIFT TO ROOT*(SSIN+PCOS)*2(N-31)

                                32D                     # STORE PS TERMS IN PDL(10),LOAD YCO    16
                VXSC            VAD                     # QYCOX2(N-31)
                                QAXIS                   # ADD PS TERMS,GET RCOX2(N-31)          10
                VSL1                                    # SHIFT TO RCOV*2(N-30)
                STORE           RCOV                    # STORE CUTOFF POSITION
                UNIT                                    # GET URCO*2(-1)
                STOVL           URCO                    # STORE URCO*2(-1)
                                PAXIS1
                VXSC                                    # PSINX2(-2)                             8
                PDVL                                    # STORE IN PDL(8)                       10
                                SAXIS                   # LOAD SX2(-1)
                VXSC            VSU                     # SCOS*2(-2)

                                06D                     # (SCOS-PSIN)*2(-2)=H1*2(-2)
                VSL1            SETPD                   # SHIFT TO H1X2(-1)
                                00D                     # RESET PDC TO 0                         0
                STODL           H1                      # STORE H1
                                TINT                    # LOAD TINT*2(-28)
                DSU
                                TCO
                STORE           TFL                     # TIME (+28) FOR LAMBERT
                EXIT
                CA              LAMPRIO                 # SET PRIORITY FOR LAMBERT

                INHINT
                TC              FINDVAC                 # SET UP LAMBERT LOB
                EBANK=          SPLOC
                2CADR           LAMBSET

                RELINT
                TC              INTPRET                 # DURING PREBURN PASS,HIGH PRIO FOR LAMB
                VLOAD           PUSH                    # WILL CAUSE INTERRUPT HERE.
                                V0VEC                   # LOAD V0VEC, RESCALE FOR ASCENT
                DOT             SL1                     # V1*2(-7) IN PDL(0)
                                URCO                    # V1.URCO=RDOTD*2(-8)
                STOVL           RDOTD                   # STORE IN RDOTD

                                00D                     # LOAD V1*2(-7)
                DOT             SL1                     # V1.H1*2(-8)=ZDOTD*2(-8)
                                H1                      # SHIFT TO 2(-7)
                STOVL           ZDOTD                   # STORE IN ZDOTD,LOAD URCO*2(-1)

## Page 857
                                URCO
                VXV             DOT                     # URCOXH1*2(-2)=-UYCO*2(-2)
                                H1                      # -UYCO.V1*2(-9)=-YDOTD*2(-9)            0
                SL2             DCOMP                   # +YDOTD*2(-7)
GAIN            STORE           YDOTD                   # STORE YDOTDX2(-7)
                DLOAD           SETPD                   # LOAD YDOTD
                                YDOTD
                                00D

                DSU             PUSH                    # (YDOTD-YDOT)X2(-7)=DYDOTX2(-7)
                                YDOT                    # STORE DYDOT IN PDL(0)                  2
                STODL           32D                     # STORE DYDOT IN 32                     (2
                                ZDOTD                   # LOAD ZDOT
                DSU             PUSH                    # ZDOTD-ZDOT=DZDOT*2(-7)
                                ZDOT                    # STORE IN PDL(2)                        4
                STODL           30D                     # ALSO IN 30
                                GEFF                    # LOAD GEFF
                DMP             SL1                     # GEFF TGOX2(-8)
                                TGO                     # SHIFT TO 2(-7)

                PDDL            DSU                     # STORE IN PDL(4)                        6
                                RDOTD                   # LOAD RDOTD
                                RDOT                    # DRDOTX2(-7)
                STORE           28D                     # STORE IN 28
                DSU             VDEF                    # DRDOT-TGOGEFF,DEFINE VGX2(-7)        0,4
                ABVAL           DSU                     # GET VG(SCALAR)
                                VTO                     # SUBTRACT TAILOFF
                DMP             SL3                     # VG*2(-7)*1/VE*2(4)=VG/VE*2(-3)
                                1/VE                    # SHIFT TO VG/VE
                PUSH                                    # STORE INPDL(0)                         2
                DMP             BDSU                    # KTVG/VE
                                KT                      # 1/2-KTVG/VE

                                DP.5
                DAD             DMP                     # 1-KTVG/VE
                                DP.5                    # VG/VE(1-KTVG/VE)=TGO/TBUP              0
                PUSH            DMP                     # STORE TGO/TBUP IN PDL(0)               2
                                TBUP                    # TGOX2(-17)
                STORE           TGO                     # STORE
                DSU             BMN                     # IF TGO SMTHAN 4SEC,GO TO SET UP ENGOFF
                                2SEC(16)                # 2*2(-16)=4*2(-17)
                                ENGOFF
KEEPGOIN        BONCLR          RTB                     # DURING PRECOI, GO BACK TO MP4

                                56D
                                TKNOWN
                                LOADTIME
                STORE           TIME
                DLOAD           SR
                                TGO                     # TGO*2(-17)
                                11D                     # TGO*2(-28)
                DAD
                                TIME                    # T+TGO=TCO*2(-28)
                STODL           TCO                     # STORE TCO                             (2

## Page 858
                                T2                      # LOAD T2X2(-17)

                DSU             BPL                     # T2-TGO
                                TGO
                                AIMER                   # IF T2-TGO POS,GO TO AIMER

                DLOAD           DSU                     # LOAD T*2(-28)
                                TIME                    # SUBTRACT 100 CS, 1/2DT
                                100CS                   # (T-.5DT)*2(-28)
                STODL           TREF                    # *2(-28)
                                TGO                     # LOAD TGOX2(-17)
                DMP             DAD                     # RDOT TGO*2(-24)
                                RDOT                    # (R+RDOT TGO)*2(-24)
                                RMAG

                SR1             BDSU                    # *2(-25)
                                RCO                     # RCO-R-RDOT TGO=DR*2(-25)
                STODL           26D                     # STORE DR IN 26,LOAD TGO/TBUP
                BDSU            DAD                     # 1/2-TGO/TBUP
                                DP.5
                                DP.5                    # 1-TGO/TBUP
                CALL
                                LOGSUB                  # CALL LOG SUBROUTINE

                SL              PUSH                    # SHIFT TO -L,STORE IN PDL(0)            2

                                5
                BDDV            BDSU                    # -TGO/L*2(-17)
                                TGO
                                TBUP                    # (TBUP+TGO/L)*2(-17)=D12*2(-17)
                PDDL            DSU                     # D12 IN PDL(2)                          4
                                TGO
                                T3                      # TGO-T3
                BPL             DLOAD                   # IF TGO-T3 POS,GO TO RATE
                                RATER
                                DP0                     # SET B=0
                STORE           PRATE
                SETGO                                   # SET HC=1,GO TO CONST
                                HC
                                CONST

RATER           DLOAD           DSU                     # TGO
                                TGO
                                02D                     # TGO-D12=D21X2(-17)
                PDDL            SR1                     # D21 IN PDL(4)                          6
                                TGO                     # LOAD TGOX2(-17),SHIFT TO 1/2
                DSU             PDDL                    # 1/2TGO-D21=DX2(-17)
                                04D                     # STORE D IN PDL(6)                      8

                                28D                     # LOAD DRDOT*2(-7)
                DMP             SL*                     # DRDOT D21*2(-24)
                                04D
                                0               -6,1    # SHIFT TO 2(N-30)
                DSU             DDV                     # D21 DRDOT-DR

## Page 859
                                26D
                                TGO                     # DIVIDE BY TGO
                DDV             SETPD                   # DIVIDE BY D,GET B*2(N+4)
                                06D
                                04D                     # SET PD TO 4                            4
                STORE           PRATE                   # STORE B IN PRATE

CONST           DLOAD           DDV                     # LOAD DRDOTX2(-7)
                                28D                     # DRDOT/-LX2(-7)
                                00D
                PDDL                                    # STORE IN PDL(2),PULL D12               4
                DMP
                                PRATE                   # D12PX2(N-13)
                SR*             BDSU                    # SHIFT TO 2(-7)
                                0               -6,1    # PULL DRDOT/-L, GET A*2(-7)
                STADR
                STODL           PCONS                   # STORE A
                                32D                     # LOAD DYDOTX2(-7)
                DDV                                     # DYDOT/-LX2(-7)=CX2(-7)

                                00D
                STORE           YCONS                   # STORE CX2(-7)

AIMER           SETPD
                                00D
                DLOAD           DSU
                                TIME
                                TREF                    # (T-TO)X2(-28)
                DMP             SR*                     # B(T-TO)X2(N-24)
                                PRATE

                                0               -17D,1
                DAD             SR1                     # (A+B(T-TO))*2(-7)
                                PCONS                   # 2(-8)
                DDV             DSU                     # (A+B(T-T0))/TBUP*2(9)
                                TBUP                    # ADD GEFFX2(9)
                                GEFF                    # GET ATRX2(9)
                VXSC            PDDL                    # ATR UR*2(8)
                                UNITR                   # STORE IN PDL(0)                        6
                                YCONS                   # LOAD C*2(-7)
                SR1             DDV                     # SHIFT TO 2(-8)
                                TBUP                    # C/TBUP*2(9)=ATY*2(9)
                VXSC            VAD                     # ATY LAXIS*2(8)

                                LAXIS                   # (ATY LAXIS+ATR UR)*2(8)=AH*2(8)        0
                VSL1            PUSH                    # SHIFT TO AH*2(9),STORE IN PDL(0)       6
                ABVAL           PDDL                    # AH2X2(18) IN PDL(34),AHMAG IN MPAC
                                AT                      # STORE AHMAG IN PDL( 6),LOAD AT         8
                DSQ             DSU                     # AT(2)X2(18)
                                34D                     # (AT(2)-AH2)X2(18)=ATP2X2(18)
                PDDL            DMP                     # STORE IN PDL( 8)                      10
                                AT                      # LOAD AT X2(9)
                                KR                      # AT KRX2(8)

## Page 860
                SL1             PUSH                    # 2(9),STORE IN PDL(10)                 12
                DSQ             DSU                     # AT(2)KR(2)X2(18)

                                34D                     #  -AH2X2(18) =ATP3X2(18)
                BMN             DLOAD                   # IF ATP3 NEG,GO TO AIMING
                                AIMING
                                8D                      # LOAD ATP2X2(18)
                SQRT                                    # ATPX2(9)
                GOTO
                                AIMED

AIMING          DLOAD           BDDV                    # KR AT/AHX2(-1)=KH/2 FROM PDL(10,6)     8
                                06D

                VXSC            VSL1                    # KH AH*2(8),X2(9)
                                00D
                STODL           00D                     # STORE NEW AH IN PDL(0)
                                AT                      # LOAD ATX2(9)
                DMP                                     # AT(1-KR(2))(1/2)X2(9)=ATPX2(9)
                                KR1

AIMED           SIGN            VXSC                    # GIVE SIGN TO ATP
                                30D
                                ZAXIS                   # ATP ZAXISX2(8)
                VSL1            VAD                     # ATP ZAXISX2(9)
                                00D                     # (ATPZAXIS+AH)X2(9)

                UNIT                                    # GET UT*2(-1)
                STORE           UT
                SETPD           CALL
                                0
                                ASCRET
                EXIT
                TCF             ENDOFJOB
100CS           2DEC            100

## Remark: the label 'KT' is actually indented by 2 characters in the original listing but is referenced as operand.
## The current yaYul considers indented labels as false labels i.e. doesn't pick up the label 'KT' properly
KT              2DEC            0.34


VINJ            2DEC            76.655851       B-7

VTO             2DEC            0.5             B-7

DP3/80          2DEC            0.0375

2SEC(18)        2DEC            200             B-18

2SEC(16)        2DEC            200             B-16

T3              2DEC            0


1/12TH          2DEC            0.083333333

DP.25           2DEC            0.25


## Page 861
DP2/3H          2DEC            .666666667

DTASC           2DEC            200             B-17

T2              2DEC            200

LAMBSET         TC              INTPRET                 # CALL FOR LAMBERT SUBR.
                CALL

                                LAMBERT
ENGOFF          DLOAD           SL3                     # PUT LOW ORDER BIT OF T IN BIT1 OF MPAC
                                TGO
                EXIT
                INHINT
                CA              MPAC                    # PUT TGO INA
                TC              WAITLIST                # SET UP CALL TO APSOFF
                EBANK=          TGO
                2CADR           APSOFF

                RELINT
                TC              INTPRET
                GOTO
                                KEEPGOIN                # RETURN TO STEERING
APSOFF          TC              ENGINOFF
                TC              TASKOVER
