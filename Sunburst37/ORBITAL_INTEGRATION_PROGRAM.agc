### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ORBITAL_INTEGRATION_PROGRAM.agc
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
## Reference:   pp. 723-745
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-07-12 MAS  Updated for Sunburst 37.
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 723
# FBR3 SETS UP A TIMESTEP CALL TO KEPLER.



FBR3            DLOAD           SR3
                                H
                SR3R            DAD
                                TC
                STODL           TAU

                                EARTHTAB        +9D
                DMP             SRR
                                DT/2
                                12D
                DAD
                                TET
                STORE           TET

## Page 724
# THIS ORBITAL KEPLER SUBROUTINE FINDS THE POSITION AND VELOCITY OF THE VEHICLE AFTER TIME FOUND IN GIVENT
# SINCE RECTIFICATION TO POSITION RRECT AND VELOCITY VRECT. THE RESULTING POSITION AND VELOCITY ARE LEFT IN

# FOUNDR AND FOUNDV, RESPECTIVELY.



KEPLER          VLOAD           SETPD                   # UNIT OF RECTIFICATION POSITION TO 0
                                RRECT
                                0
                UNIT            PDDL                    # AND LENGTH OF ORIGINAL IN 6
                                36D
                PDVL                                    # LENGTH OF POSITION AT RECTIFICATION.
                                VRECT
                VSQ             ROUND
                DMP             DSU
                                6                       # LENGTH OF POSITION AT RECTIFICATION
                                DP1/4
                SL2R            PUSH                    # A4 TO REGISTER 8
                SR2             DCOMP
                DAD             DDV
                                DP1/4
                                6
                PDVL            DOT                     # ALPHA TO REGISTER 10
                                RRECT
                                VRECT

                ROUND           PDVL                    # A1 TO REGISTER 12
                                RCV
                UNIT            DOT
                                VCV
                PDDL                                    # IR/2.VC IN 14D.
                                36D
                STODL           ALPHAM                  # RC IN ALPHAM
                                DT/2
                SR3             SR3R
                DDV             AXT,2
                                ALPHAM
                                10D                     # MAX ITERATION COUNT IS 10

## Page 725
                PDDL            DDV                     # Q IN 16
                                DP1/4
                                ALPHAM
                DSU             DMPR
                                10D                     # 1/4RC : ALPHA
                                16D                     # Q(  )
                DMPR            DMPR
                                16D                     # QQ(  )

                                DP1/3
                SL3             SL3
                PDDL            DMPR
                                14D
                                16D
                SL4             PUSH                    # 16(UR/2.VC)Q IN 20
                BDSU            DMPR
                                DP1/2
                BDSU            DSU
                                DP1/2
                DMP             SL1R
                DAD             SSP
                                XKEP
                                S2
                                1
                STORE           XKEP

## Page 726
# ITERATING EQUATIONS - GIVEN X IN MPAC, FIND TIME OF FLIGHT.



KTIMEN+1        DSQ             ROUND                   # FORM ALPHA X-SQUARED AND CALL S AND C
                DMP             SL2R
                                10D
                SETPD           CALL                    # SET PD INDICATOR TO 16
                                16D
                                S(X)C(X)
                DMP             SL4
                                XKEP
                DMP             SL1
                                XKEP

                DMP             SL1R
                                XKEP
                STORE           23D                     # A3
                DMPR            PDDL
                                8D
                                XKEP
                DMP             SL4
                                16D                     # VALUE OF C
                SL1             DMP
                                XKEP
                SL2R
                STORE           21D                     # A2
                DMP             SR1R
                                12D                     # A1
                DAD
                PDDL            DMPR
                                6
                                XKEP
                DAD
                PUSH            BDSU                    # COMPARE WITH GIVEN TIME OF FLIGHT
                                GIVENT
                STORE           16D                     # DIFFERENCE TO REGISTER 16
                EXIT

## Page 727
DUMPDUMP        TC              INTPRET                 # FOR DUMP ONLY *******
                ABS             DSU
                                KEPSILON                # SEE IF WITHIN EPSILON OF GIVEN TIME.
                BMN             TIX,2                   # IF SO, GET R AND V AND EXIT.
                                GETRANDV
                                GETNEWX
                GOTO
                                GETRANDV
GETNEWX         DLOAD           DMP
                                10D                     # ALPHA
                                23D                     # A3
                SL2R            BDSU
                                XKEP
                DMP             SL4R
                                12D                     # A1
                STODL           18D
                                21D			# A2
                DMP             SL1R
                                8D                      # A4

                DAD
                DAD             PDDL
                                6                       # R0
                                16D
                DDV             DAD
                                18D
                                XKEP
                STCALL          XKEP
                                KTIMEN+1

## Page 728
# SUBROUTINE FOR COMPUTING THE UNIVERSAL CONIC FUNCTIONS S(X) AND C(X). THE ACTUAL OUTPUT OF THIS ROUTINE
# CONSISTS OF SCALED VERSIONS DEFINED AS FOLLOWS -

#           S (X) = S(64X)              C (X) = C(64X)/4
#            S                           S

# IT IS ASSUMED THAT THE INPUT ARRIVES IN MPAC,MPAC+1 AND THAT IT LIES BETWEEN -30/64 AND 40/64. UPON EXIT,
# S(X) WILL BE LEFT IN MPAC,MPAC+1 AND C(X) ON TOP OF THE PUSHDOWN LIST.



S(X)C(X)        STORE           34D                     # X TO 34D
                RTB             DSQ
                                A(X)
                ROUND           PUSH
                STORE           36D                     # A SQUARED TO 36D
                DMP             SL1R
                                34D                     #          2          2
                BDSU            DMPR                    # C (X) = A (.25 - 2XA ) TO PD LIST
                                POS1/4                  #  S
                                36D
                PDDL            SR2R                    #  2
                PDDL            RTB                     # A /4 TO PD LIST
                                34D
                                B(X)
                DSQ             ROUND

                PDDL            DMPR                    # B SQUARED TO PD LIST
                                34D
                                36D
                BDSU            DMPR                    #               2        2    2
                                POS1/16                 # LEAVES S (X)=B (.0625-A X)+A /4 IN MPAC
                DAD             ITCQ                    #         S
-1/12           2DEC            -.1                     # DONT MOVE.

## Page 729
# A AND B POLYNOMIALS WHOSE COEFFICIENTS WERE OBTAINED WITH THE *AUTOCURVEFIT* PROGRAM.
A(X)            TC              POLY
                DEC             4
                2DEC             7.071067810    E-1

                2DEC            -4.714045180    E-1

                2DEC             9.42808914     E-2

                2DEC            -8.9791893      E-3

                2DEC             4.989987       E-4

                2DEC            -1.79357        E-5

                TC              DANZIG
B(X)            TC              POLY
                DEC             4
                2DEC             8.164965793    E-1

                2DEC            -3.265986572    E-1

                2DEC             5.90988980     E-2

                2DEC            -4.0085592      E-3

                2DEC             2.781528       E-4

                2DEC            -1.25610        E-5

                TC              DANZIG

## Page 730
# ROUTINE FOR OBTAINING R AND V, NOW THAT THE PROPER X HAS BEEN FOUND.



GETRANDV        DLOAD           SETPD
                                21D                     # A2 FROM LAST ITERATION
                                25D
                DCOMP           VXSC
                                0                       # UNIT OF GIVEN POSITION VECTOR
                PDDL            DSU
                                18D                     # LAST VALUE OF T
                                23D                     # LAST VALUE OF A3
                SL2             VXSC
                                VRECT

                VAD             VSL1                    # ADDITION MUST BE DONE IN THIS ORDER
                PUSH            VAD
                                RRECT
                VAD             STADR
                STORE           FOUNDR                  # RESULTING CONIC POSITION
                ABVAL
                STODL           16D
                                10D                     # ALPHA
                DMP             SL2R
                                23D                     # A3

                DSU             DDV
                                XKEP
                                16D                     # LENGTH OF FOUND POSITION
                VXSC            VSL2
                                0                       # UNIT OF RECTIFICATION POSITION
                PDDL            SR1
                                16D
                DSU             DDV
                                21D
                                16D
                VXSC            VAD
                                VRECT

                VSL1
                STCALL          FOUNDV                  # THIS COMPLETES THE CALCULATION
                                HBRANCH

## Page 731
# THE POSTRUE ROUTINES SET UP THE BETA VECTOR AND OTHER INITIAL CONDITIONS FOR THE NEXT ACCOMP.
POSTRUE         SSP             VLOAD                   # TIME STEP CALLS TO KEPLER RETURN HERE
                                SCALEA
                                4
                                ALPHAV
                VSR             VAD

                                10D
                                RCV                     # POSITION OUTPUT OF KEPLER
                LXA,2           BOF
                                DIFEQCNT
                                WMATFLAG
                                NOSAVE1
                STORE           VECTAB,2
NOSAVE1         SSP             SSP                     # SETS UP SCALE B AND GMODE
                                SCALEB
                                14D
                                GMODE
                                2

                STORE           BETAV

## Page 732
# AGC ROUTINE TO COMPUTE ACCELERATION COMPONENTS.



ACCOMP          VLOAD           UNIT
                                ALPHAV
                STODL           ALPHAV
                                36D
                STORE           ALPHAM
                BOV
                                ACCOMP2                 # TURN OFF OVERFLOW INDICATOR
ACCOMP2         VLOAD           VSR1
                                BETAV
                VSQ             SETPD
                                0
                NORM            ROUND
                                S1
                PDDL            NORM                    # NORMED B SQUARED TO PD LIST
                                ALPHAM                  # NORMALIZE (LESS ONE) LENGTH OF ALPHA
                                X1                      # SAVING NORM SCALE FACTOR IN X1
                SR1             PDVL
                                BETAV                   # C(PDL+2) = ALMOST NORMED ALPHA
                UNIT
                STODL           BETAV
                                36D
                STORE           BETAM
                NORM            BDDV                    # FORM NORMALIZED QUOTIENT ALPHAM/BETAM
                                X2
                SR1R            PUSH                    # C(PDL+2) = ALMOST NORMALIZED RHO.
                LXC,2           XAD,2
                                X2                      # C(X2) = -SCALE(RHO) + 1
                                SCALEA                  #       = -S(B)-N(B)+S(A)+N(A)+1
                XAD,2           XSU,2
                                X1
                                SCALEB
                INCR,2          SR*

                                2
                                0,2
                PUSH            SR2R                    # RHO/4 PD+6
                PDVL            DOT
                                ALPHAV
                                BETAV
                SL1R            BDSU                    # (RHO/4) - 2(ALPHAV/2.BETAV/2)
                PUSH            DMPR                    # TO PDL+6
                                4

## Page 733
                PUSH            DAD                     # Q/4 = RHO(C(PDL+4)) TO PD+8D
                                DQUARTER                # (Q+1)/4 TO PD+10D
                PUSH            SQRT                    #          3/2
                DMPR            PUSH                    # ((Q+1)/4)    TO PD+12D
                                10D
                SL1             DAD
                                DQUARTER                #                 3/2
                PDDL            DAD                     # (1/4)+2((Q+1)/4)    TO PD+14D

                                10D
                                DP1/2
                DMPR            SL1
                                8D
                DAD             DDV
                                THREE/8
                                14D
                DMPR            VXSC
                                6
                                BETAV                   #               -
                PDVL            VSR3                    # (G/2)(C(PD+4))B/2 TO PD+16D
                                ALPHAV
                VAD             PUSH                    # A12 + C(PD+16D) TO PD+16D
                DLOAD           DMP
                                0
                                12D                     # -
                NORM            ROUND                   # GAMMA TO PD+22D
                                S2                      # - SCALE(GAMMA)-1 TO X1
                BDDV            LXC,1
                                2
                                X2                      # C(X2) = SCALE(RHO)
                XAD,1           XAD,1
                                S2                      # C(S2) = N((B.B/4)(....)3/2)

                                S1                      # C(S1) = N(B.B/4)
                XAD,1           XAD,1
                                SCALEB
                                SCALEB
                DCOMP           VXSC
                                16D                     # RESULT OF PRECEDING EQUATION
                PUSH            CGOTO
                                GMODE
                                GTABLE
GTABLE          CADR            GMODE10

                CADR            GMODE11
                CADR            GMODE12

## Page 734
# THE GMODE12 ROUTINE SETS UP THE SECONDARY BODY DISTURBING ACCELERATION FOR ACCOMP.

GMODE12         VSL*                                    # -SCALE(GAMMA)-1 IS LEFT IN X1.
                                31D,1                   # ADJUST GAMMA TO SCALE OF -32
                STOVL           FV
                                BETAV
                STODL           ALPHAV                  # BETA VECTOR INTO ALPHA FOR NEXT ACCOMP
                                BETAM
                STORE           ALPHAM
                BOFF            CALL
                                MIDFLAG
                                OBLATEST
                                MOONPOS
                STORE           BETAV                   # MOON(EARTH) POSITION WILL BE BETA NEXT

                LXA,1           BOF
                                DIFEQCNT                # SAVE R/QV IN VECTAB FOR W-MATRIX UPDATE
                                WMATFLAG
                                NOSAVE2
                STORE           VECTAB          +6,1
NOSAVE2         AXT,2           XCHX,2                  # SETUP ALPHAM AND SCALEA
                                19D                     # SCALE FOR R/QV
                                SCALEB                  # SWAP SCALEB AND X2
                SXA,2           GOTO
                                SCALEA
                                ACCOMP2                 # ENTRY IF UNIT(ALPHAV) AVAILABLE

## Page 735
# THE GMODE11 ROUTINE SETS UP THE SUNS DISTURBING ACCELERATION.



GMODE11         LXC,2           CALL                    # SET X2 TO TABLE OF PROPER CONSTANTS
                                PBODY

                                ADDTOFV
                CALL                                    # BARICENTER-TO-SUN POSITION VECTOR.
                                SUNPOS                  # LEAVES VECTOR IN PDL
                LXA,1           VLOAD*                  # COMPUTE R/PS USING CORRECT TABLE FOR
                                DIFEQCNT                # MASS RATIO, ETC.
                                VECTAB          +6,1
                VXSC*           VAD
                                6,2                     # USE SCALAR AT ENTRY 6 IN THE TABLE
                AXT,1           SXA,1
                                28D
                                SCALEB                  # SET SCALEB AND RETURN TO ACCOMP
                STCALL          BETAV

                                ACCOMP2

# THE GMODE10 ROUTINE ADDS IN THE SUNS PERTURBING ACCELERATION AND COMPUTES THE OBLATENESS CONTRIBUTION
GMODE10         LXC,2           INCR,2
                                PBODY
                DEC             -3
                CALL
                                ADDTOFV
OBLATEST        BON
                                MOONFLAG

                                NBRANCH

## Page 736
# THE OBLATE ROUTINE COMPUTES THE ACCELERATION DUE TO THE EARTHS OBLATENESS. 2T USES THE UNIT OF THE VEHICLE
# POSITION VECTOR FOUND IN ALPHAV AND THE DISTANCE TO THE CENTER IN ALPHAM. THIS IS ADDED TO THE SUM OF THE

# DISTURBING ACCELERATIONS IN FV AND THE PROPER DIFEQ STAGE IS CALLED VIA X1.
OBLATE          DLOAD
                                ALPHAV          +4      # Z COMPONENT OF POSITION IS COS PHI
                SETPD           DMPR
                                0
                                3/4
                PDDL            DSQ                     # P2:/8 TO REGISTER 0
                                ALPHAV          +4
                SL3             DMPR
                                15/16
                DSU             PUSH                    # P3:/4 TO REGISTER 2
                                3/8
                DMPR            DMPR
                                ALPHAV          +4
                                7/12
                SL1             PDDL                    # P4:/16 TO REGISTER 4
                                0
                DMPR            BDSU
                                2/3
                PUSH            DMPR                    # BEGIN COMPUTING P5:/128
                                ALPHAV          +4
                DMPR            PDDL
                                9/16

                                2
                DMPR            BDSU                    # FINISH P5:/128 AND TERM USING UNIT
                                5/128                   # POSITION VECTOR AT ALPHA
                DMP             SL2
                                J4REQ/J3
                DDV             DAD
                                ALPHAM
                                4
                DMPR            DDV
                                2J3RE/J2

                                ALPHAM
                DAD             VXSC
                                2
                                ALPHAV
                STODL           ALPHAV

## Page 737
                DMP             SL1                     # COMPUTE TERM USING IZ
                                J4REQ/J3
                DDV             DAD
                                ALPHAM
                PDDL            SR3
                                2J3RE/J2
                DMPR
                DDV             DAD

                                ALPHAM
                BDSU
                                ALPHAV          +4
                STODL           ALPHAV          +4
                                ALPHAM
                DSQ             DSQ
                NORM            BDDV
                                X1
                                J2REQSQ
                VXSC            INCR,1

                                ALPHAV
                                4
                VSL*            VAD                     # SHIFTS LEFT ON +, RIGHT ON -.
                                0,1
                                FV
                STORE           FV
NBRANCH         SLOAD           LXA,1
                                DIFEQCNT
                                MPAC
                DMP             CGOTO
                                -1/12
                                MPAC

                                DIFEQTAB
DIFEQTAB        CADR            DIFEQ+0
                CADR            DIFEQ+1
                CADR            DIFEQ+2
ADDTOFV         DLOAD*                                  # SETS UP S1 AND S2 PER PRIMARY BODY TABLE
                                0,2
                STOVL           S1
                                22D
                XAD,1           VXSC*
                                S1

                                1,2
                VSL*            VAD
                                31D,1
                                FV
                STORE           FV
                ITCQ

## Page 738
 # BEGIN INTEGRATION STEP WITH RECTIFICATION TEST.



TIMESTEP        VLOAD                                   # MOVE TEMPORARY DELTA AND NU VECTORS
                                TNUV                    # TO WORKING STORAGE
                STOVL           ZV
                                TDELTAV
                STORE           YV
                ABVAL           DSU                     # RECTIFICATION REQUIRED IF THE LENGTH
                                DP1/2                   # OF DELTA IS GREATER THAN .5 (8KM).
                BMN             CALL
                                INTGRATE
                                RECTIFY

INTGRATE        SSP             SSP                     # INITIALIZE INDICES AND SWITCHES
                                FBRANCH                 # EXIT FROM DIFEQCOM
                CADR            FBR3
                                HBRANCH                 # EXIT FROM KEPLER
                CADR            POSTRUE
                CLEAR
                                JSWITCH                 # 1 FOR W MATRIX EXTRAPOLATE, 0 OTHERWISE.
DIFEQ0          VLOAD                                   # POSITION DEVIATION INTO ALPHA
                                YV
                STODL           ALPHAV
                                DPZERO
                STORE           H                       # START H AT ZERO. GOES O(DELT/2)DELT.
                STCALL          DIFEQCNT                # ZERO DIFEQCNT AND REGISTER FOLLOWING.
                                HBRANCH                 # GOES 0(-12D)(-24D).

## Page 739
# THE RECTIFY SUBROUTINE IS CALLED BY THE INTEGRATION PROGRAM AND OCCASIONALLY BY THE MEASUREMENT INCORPORATION
# ROUTINES TO ESTABLISH A NEW CONIC.



RECTIFY         VLOAD           VSR8                    # RECTIFY - FORM TOTAL POSITION AND VEL.
                                TDELTAV                 # ADJUST SCALE DIFFERENCE (ASSUMED
                VSR2            VAD                     #       CONSTANT HERE.)
                                RCV
                STORE           RRECT
                STOVL           RCV                     # SET UP CONIC ,ANSWER, FOR TIMESTEP
                                TNUV
                VSR8            VAD                     # SAME FOR VELOCITY.
                                VCV
                STORE           VRECT
                AXT,1           SSP
                                12D                     # ZERO DELTA, NU, AND TIME SINCE RECT.
                                S1
                                2

                STODL           VCV
                                DPZERO
                STORE           TC
                STORE           XKEP                    # ZERO X.
ZEROLOOP        STORE           YV              +12D,1  # INDICES CAUSE LOOP TO ZERO 6 CONSECUTIVE
                STORE           TDELTAV         +12D,1  # DP NUMBERS (DELTA AND NU ARE ADJACENT).
                TIX,1           ITCQ                    # LOOP OR START INTEGRATION STEP IF DONE.
                                ZEROLOOP

## Page 740
# THE THREE DIFEQ ROUTINES - DIFEQ+0, DIFEQ+12, AND DIFEQ+24 - ARE ENTEREDTO PROCESS THE CONTRIBUTIONS AT THE
# BEGINNING, MIDDLE, AND END OF THE TIMESTEP, RESPECTIVELY. THE UPDATING IS DONE BY THE NYSTROM METHOD.

DIFEQ+0         VLOAD           VSR3
                                FV
                STCALL          PHIV
                                DIFEQCOM
DIFEQ+1         VLOAD           VSR1
                                FV
                PUSH            VAD
                                PHIV
                STOVL           PSIV
                VSR1            VAD

                                PHIV
                STCALL          PHIV
                                DIFEQCOM
DIFEQ+2         DLOAD           DMPR
                                H
                                DP2/3
                PUSH            VXSC
                                PHIV
                VSL1            VAD
                                ZV
                VXSC            VAD
                                H

                                YV
                STOVL           YV
                                FV
                VSR3            VAD
                                PSIV
                VXSC            VSL1
                VAD             BOFF                    # SEE IF THIS IS STATE VECTOR OR W COLUMN.
                                ZV
                                JSWITCH
                                ENDSTATE
                AXT,1
                                0
                STORE           W               +72D,2  # VELOCITY COLUMN VECTOR
                DLOAD
                                YV
                STORE           W               +36D,2  # POSITION COLUMN VECTOR
                TIX,2           GOTO                    # **********
                                NEXTCOL
                                STEPEXIT

## Page 741
NEXTCOL         VLOAD*                                  # SET UP NEXT COLUMNS OF W MATRIX
                                W               +36D,2
                STOVL*          YV
                                W               +72D,2
                STCALL          ZV
                                DIFEQ0
ENDSTATE        STOVL           TNUV
                                YV

                STODL           TDELTAV
                                H
                SR4             SR2R
                DAD
                                TC
                STORE           TC
                BOFF            AXT,2
                                WMATFLAG
                                STEPEXIT
                                36D

                SSP             AXT,1
                                S2
                                6
                                DOW..
                SXA,1           SXA,1
                                FBRANCH
                                HBRANCH
                INVERT          AXT,1
                                JSWITCH
                                0
                GOTO
                                NEXTCOL

## Page 742
# COMES HERE TO FINISH FIRST TWO DIFEQ COMPUTATIONS.



DIFEQCOM        DLOAD           DAD                     # INCREMENT H AND DIFEQCNT.
                                DT/2
                                H
                INCR,1          SXA,1
                DEC             -12
                                DIFEQCNT                # DIFEQCNT SET FOR NEXT ENTRY.
                STORE           H
                VXSC            VSR1
                                FV
                VAD             VXSC

                                ZV
                                H
                VAD
                                YV
                STCALL          ALPHAV
                                FBRANCH

## Page 743
# ORBITAL ROUTINE FOR EXTRAPOLATION OF THE W MATRIX. IT COMPUTES THE SECOND DERIVATIVE OF EACH COLUMN POSITION
# VECTOR OF THE MATRIX AND CALLS THE NYSTROM INTEGRATION ROUTINES TO SOLVETHE DIFFERENTIAL EQUATIONS. THE PROGRAM
# USES A TABLE OF VEHICLE POSITION VECTORS COMPUTED DURING THE INTEGRATION OF THE VEHICLES POSITION AND VELOCITY.
DOW..           VLOAD           VSR6
                                ALPHAV
                PDVL*           UNIT

                                VECTAB,1
                PDVL            VPROJ
                                ALPHAV
                VXSC            VSU
                                3/16
                PDDL            DMP
                                34D
                                36D
                V/SC            STADR
                STCALL          FV
                                NBRANCH

## Page 744
# CONSTANTS



KEPSILON        OCT             00000
                OCT             00002
THREE/8         2DEC            .375

3/16            2DEC            3               B -4

DP1/4           2DEC            .25

DP1/3           2DEC            .333333333

DQUARTER        EQUALS          DP1/4
POS1/16         2DEC            .0625

POS1/4          EQUALS          DP1/4
3/8             EQUALS          THREE/8
15/16           2DEC            15.             B -4

3/4             2DEC            3.0             B -2

J2REQSQ         2DEC            .335914874              # SECOND HARMONIC TIMES SQUARE OF RADIUS.

7/12            2DEC            .5833333333


9/16            2DEC            9               B -4

5/128           2DEC            5               B -7

2J3RE/J2        2DEC            -.003309146

J4REQ/J3        2DEC            .60932709

DP1/2           2DEC            .5

DPZERO          2DEC            0.0

DP2/3           2DEC            .6666666667

2/3             EQUALS          DP2/3

## Page 745
# DUMMYMOON POSITION ROUTINE, SUN POSITION ROUTINE, AND PBODY TABLE FOR CHECKOUT OF EARTH-ORBITAL ONLY.
MOONPOS         VLOAD           ITCQ                    # LOAD CONSTANT VECTOR INTO A AND EXIT.
                                MOONVEC

SUNPOS          SETPD           VLOAD                   # RETURNS WITH VECTOR IN VAC AND IN PDL.
                                0
                                SUNVEC
                ITCQ



EARTHTAB        DEC             6
                2DEC            0.0

                DEC             10
                2DEC            0.0

                2DEC            0.0


                DEC             -28                     #  28                        3/2
                2DEC            .6335627                # 400/SQRT(MU)

MOONVEC         EQUALS          EARTHTAB
SUNVEC          EQUALS          EARTHTAB        +3      # ******
