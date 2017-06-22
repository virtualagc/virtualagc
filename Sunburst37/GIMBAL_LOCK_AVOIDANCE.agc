### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GIMBAL_LOCK_AVOIDANCE.agc
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
## Reference:   pp. 620-626
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-13 RSB	Transcribed.
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 620
# DETECTING GIMBAL LOCK
LOCSKIRT        DLOAD           ABS
                                COF
                DSU             BPL                             # IF (ABS(COF )-CNGL) POS, GO TO NOGIMLOC
                                CNGL                            #            0
                                NOGIMLOC
                DLOAD           DMP
                                COF
                                COF             +4
                SL1             PDDL
                                COF
                                
                DMP             SL1
                                COF             +2
                PDDL            DSQ
                                COF
                SL1             VDEF                            #           2
                STORE           K1                              # V1 = (COF  , COF COF , COF COF )      $2
                VCOMP           VAD                             #          0      0   1     0   2
                                HALFA                           # -
                STODL           K2                              # V2 = ((1-V1 ), -V1 , -V1 )            $2
                                COF             +2              #            0      1     2
                DCOMP           PDDL
                                COF             +4
                                
                PDDL            VDEF                            # -
                                NIL                             # V3 = (0, COF , -COF )
                STOVL           K3                              #             2      1
                                MIS             +6              # -    -
                STORE           IG                              # IG = MIS                              $2
                MXV             VSL1                            #         3
                                K1                              #                    -   -   -   -
                STODL           P21                             # (P21, D21, G21) = (V1, V2, V3) IG     $2
                                G21
                DSQ             PDDL
                                D21
                DSQ             DAD
                SQRT                                            #               2      2
                STORE           RAD                             # RAD = SQRT(D21 D21 + G21 G21)
                DSU             BMN
                                SNGLCD                          # IF (RAD-SNGLCD) NEG, GO TO NOGIMLOC
                                NOGIMLOC
                DLOAD           BPL
                                G21
                                OKG21
                VLOAD           VCOMP                           # IF G21 IS NEG ...
                                IG                              #    -    -
                STODL           IG                              #    IG =-IG, RAD =-RAD
                                RAD
                DCOMP
                STORE           RAD

## Page 621
OKG21           DLOAD           DAD                             # IF G21 IS POS....
                                P21
                                RAD                             #    IF (ABS(P21+RAD)-SD) NEG, GO NOGIMLOC
                BOV             ABS
                                CBMCALC
                DSU             BMN                             #    CBM = D21/RAD                      $2
                                SD
                                NOGIMLOC
                                
CBMCALC         DLOAD           SR1
                                D21
                DDV             BDSU
                                RAD
                                CAM
                BPL             DLOAD
                                NOGIMLOC
                                MFI             +12D
                PDDL            PDDL
                                MFI             +6
                                MFI                             # -
                VDEF            VSL1                            # OGF = (MFI , MFI , MFI )              $2
                STODL           OGF                             #           0     3     6
                                OGF
                DAD             BMN
                                CNGL                            # IF ((OGF ) + CNGL) NEG, GO TO ALTE
                                ALTE                            #         0
                VLOAD           VXV
                                HALFA
                                OGF
                UNIT
                STOVL           E1                              # E1 = UNIT(OGI X OGF)
                                OGF
                                
                VAD             UNIT
                                HALFA
                GOTO
                                STORE2                          # E2 = UNIT(OGI X OGF)
SETE1           VLOAD           GOTO
                                NIL             +2
                                STOREE1                         # E1 = (0,0,1)
ALTE            VLOAD           VXV
                                HALFA
                                OGF
                UNIT            BOV
                                SETE1
STOREE1         STORE           E1
                VXV
                                HALFA
                PDVL            VXV
                                OGF
                                E1
                VAD             UNIT                            # E2 = UNIT(E1 X OGI + OGF X E1)

## Page 622
STORE2          STADR                                           # -         -     -
                STORE           E2                              # E2 = UNIT(OGI + OGF)                  $2
                SETPD           DOT
                                0
                                IG                              #      -  -
                SL1             PUSH                            # PD0 K2                                $2
                DSQ             SL1
                PDVL            DOT                             # PD2 (K2 K2)                           $2
                                E1
                                IG
                SL1             PUSH                            # PD4 K1                                $2
                DSQ             SL1
                PDDL            DSU                             # PD6 (K1 K1)                           $2
                                K4SQ                            # = COS(D)COS(D)                        $2
                                
                                6
                PUSH            DSQ                             # PD8 D1                                $2
                PDDL            DMP                             # PD10 (D1 D1)                          $4
                                E2                              # (K5)
                                K3S1                            # SIN(D)                                $1
                DMP             SL2
                                0                               # K2
                PDDL            DSQ                             # PD12 2 K2 K3 K5                       $2
                                E2
                SL1             BDSU                            # K5K5 $2   PUSH UP 2 K2 K3 K5          $2
                DSU             DAD
                                2
                                6
                PUSH            DSQ                             # PD12 D2                               $2
                PDDL            DMP                             # PD14 (D2 D2)                          $4
                                E2
                                K3S1
                BDSU            PUSH
                                0                               # PD16 B1                               $2
                DMP
                                4                               # B1 K1                                 $4
                SL1             PUSH                            # PD18 B1 K1                            $2
                DSQ             PDDL                            # PD22 B1 B1 K1 K1                      $4
                
                                8D
                DMP             PUSH                            # PD22 D1 D2                            $4
                                12D
                BDSU            DSU
                                20D
                                10D                             # RSQ                                   $4
                SQRT            DMP
                                18D
                PDDL            SR1                             # PD24 RADICAL                          $8
                                14D
                PDDL            SL1                             # PD26 (D2 D2)                          $8
                                20D                             # 4(B1 B1 K1 K1)                        $8
                DAD                                             # PUSH UP FOR (D2 D2)                   $8
## Page 623
                PDDL            SR1                             # PD26 DENOMR (D2 D2)
                                22D
                BDSU            PUSH                            # PD28 NUM
                                20D
                DAD             DDV                             # NUM
                                24D                             #  + RADICAL
                                26D                             # DENOM
                BOVB            SR2
                                SIGNMPAC
                STORE           C2SQP                           #                                       $4
                SQRT
                STODL           C2PP                            #                                       $2
                                24D                             # NUM
                BDSU            DDV                             # PUSH UP FOR NUM, DENOM
                BOVB            SR2
                                SIGNMPAC
                STORE           C2SQM                           #                                       $4
                SQRT
                STODL           C2MP                            #                                       $2
                
                                QUARTA                          # 1                                     $4
                DSU             SQRT
                                C2SQP
                STODL           C1PP                            #                                       $2
                                QUARTA
                DSU             SQRT
                                C2SQM
                STORE           C1MP                            #                                       $2
                AXT,1           SSP
                                4
                                S1
                                2
NORM            SETPD           DLOAD
                                18D
                                16D                             # B1                                    $2
                DMP*            PDDL                            # PD18 = -Q                             $4
                                C2PP            +4,1
                                E2
                DSQ             DMP*
                                C2SQP           +4,1
                SL2             BDSU
                                QUARTA
                SQRT            DMP
                
                                K4                              # PD20 = -R                             $4
                PDDL            DMP*
                                4                               # K1                                    $2
                                C1PP            +4,1
                ABS             PDDL                            # PD22 AC1                              $4
                                18D                             # -Q
                DAD             DCOMP
                                20D                             # -R
## Page 624
                PDDL            DSU                             # PD24 ANSW1 = Q + R                    $4
                                18D                             # -Q
                                
                                20D                             # +R
                DCOMP           PUSH                            # PD26 ANSW2 = Q - R                    $4
                ABS             DSU
                                22D                             # AC1
                ABS             PDDL                            # PD28 ABS(ABS(ANSW2) -AC1)
                                24D                             # ANSW1
                ABS             DSU
                                22D                             # AC1
                ABS             DSU                             # ABS(ABS(ANSW1)-AC1)
                BPL             DLOAD
                                CKSGNAN2
                                24D                             # ANSW1
SIGNANSW        BPL             DLOAD
                                SAMEASK1
                                4                               # K1
                BMN             DLOAD*
                                OKC2
                                C2PP            +4,1
OPPSGNC2        DCOMP
                STORE           C2PP            +4,1
OKC2            TIX,1           GOTO
                                NORM
                                OUTCYCLE
SAMEASK1        DLOAD           BPL
                                4                               # K1
                                OKC2
                DLOAD*          GOTO
                                C2PP            +4,1
                                OPPSGNC2
CKSGNAN2        DLOAD           GOTO
                                26D                             # ANSW2
                                SIGNANSW
OUTCYCLE        SETPD           VLOAD
                                0
                                COF                             #          -   -
                DOT             PDVL                            # PD0 U1 = COF.E1
                                E1
                                COF                             #          -   -
                DOT             PUSH                            # PD2 U2 = COF.E2
                                E2
# PICK THE NEW U WHICH IS CLOSEST TO THE OLD U
                AXT,1           DMP
                                0
                                C2PP
                PDDL            DMP                             # PD4 U2 C2(0)
                                C1PP
                                0                               # U1 C1(0)
                                
                DAD             ABS
## Page 625
                PDDL            DMP                             # PD4 ABS(U1 C1(0) + U2 C2(0))
                                2
                                C2MP
                PDDL            DMP                             # PD6 U2 C2(1)
                                0
                                C1MP                            # PUSH UP U2 C2(1)
                DAD             ABS                             # ABS(U1 C1(1) + U2 C2(1))
                DSU                                             # PUSH UP 4
                
                BMN             AXC,1
                                JZERO
                                2
JZERO           DLOAD*          VXSC
                                C1PP,1
                                E1
                PDDL*           VXSC
                                C2PP,1
                                E2
                VAD
                UNIT                                            # NEW COF  -       -
                STORE           COF                             # COF = C1 E1 + C2 E2
# NEW MANEUVER ANGLE IS
                DLOAD           DSQ
                                COF
                SL1             BDSU                            #           2
                                HALFA                           # (1 - COF )                            $2
                PDDL            DSQ                             #         0
                                E2
                BDSU            DDV                             #        2
                                QUARTA                          # (1 - K5 )                             $4
                SR1             SQRT
                ARCSIN          SL1
                
                STORE           AM
                CLRGO                                           # STATE SWITCH NO. 31
                                31D                             # 0(OFF) = MANEUVER WENT THRU GIMBAL LOCK
                                WCALC                           # 1(ON) = MANEUVER DID NOT GO THRU GIMLOCK
NOGIMLOC        SET                                             
                                31D
WCALC           LXC,1           DLOAD*                          
                                RATEINDX                        # CHOOSE THE DESIRED MANEUVER RATE
                                ARATE,1                         # FROM A LIST OF FOUR
                SR4             CALL                            # COMPUTE THE INCREMENTAL ROTATION MATRIX
                                DELCOMP                         # DEL CORRESPONDING TO A 1 SEC ROTATION
                                                                # ABOUT COF
                DLOAD*          VXSC                            
                                ARATE,1                         
                                COF                             
                STODL           BRATE                           # COMPONENT MANEUVER RATES 45 DEG/SEC
                                AM                              
                DMP             DDV*                            
                                ANGLTIME                        
## Page 626
                                ARATE,1                         
                SR                                              
                                5                               
                STORE           TM                              # MANEUVER EXECUTION TIME SCALED AS T2
                SETGO                                           # STATE SWITCH NO. 32
                                32D                             # 0(OFF) = CONTINUE MANEUVER
                                NEWDELHI        +1              # 1(ON) = START MANEUVER


#          THE FOUR SELECTABLE FREE FALL MANEUVER RATES SELECTED BY
#          LOADING RATEINDX WITH 0,2,4,6, RESPECTIVELY


ARATE           2DEC            .0222222222                     # =.5 DEG/SEC        $ 22.5DEG/SEC

                2DEC            .0888888888                     # = 2 DEG/SEC        $ 22.5DEG/SEC

                2DEC            .2222222222                     # = 5 DEG/SEC        $ 22.5DEG/SEC

                2DEC            .4444444444                     # =10 DEG/SEC        $ 22.5DEG/SEC

ANGLTIME        2DEC            .0001907349                     # = 100B-19     FUDGE FACTOR TO CONVERT
#                      34,3513   04000 0                                    MANEUVER ANGLE TO MANEUVER TIME
