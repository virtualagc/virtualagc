### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AVERAGE_G_INTEGRATOR.agc
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
## Reference:   pp. 788-794
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-13 MAS  Updated for Sunburst 37 (this includes 
##                              Sunburst 120's MASS CALCULATOR too).
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 788
# *************************************************************************************************************


#          ROUTINE CALCRVG INTEGRATES THE EQUATIONS OF MOTION BY AVERAGING THE THRUST AND GRAVITATIONAL
# ACCELERATIONS OVER A TIME INTERVAL OF 2 SECONDS.

#          FOR THE EARTH-CENTERED GRAVITATIONAL FIELD, THE PERTURBATION DUE TO OBLATENESS IS COMPUTED TO THE FIRST
# HARMONIC COEFFICIENT J.

#          ROUTINE CALCRVG REQUIRES...
#                 1) THRUST ACCELERATION INCREMENTS IN DELV SCALED SAME AS PIPAX,Y,Z
#                 2) VN SCALED 2(+7)M/CS.
#                 3) PUSHDOWN COUNTER SET TO ZERO.

# IT LEAVES RN1 UPDATED (SCALED AT 2(+24)M, VN1 (SCALED AT 2(+7)M/CS), ANDGDT1/2 (SCALED AT 2(+7)M/CS).


                BANK            30
                EBANK=          EVEX

CALCGRAV        UNIT                                            # ENTER WITH RN AT 2(+24)M IN VAC
                STORE           UNITR                           
                DOT             PUSH                            
                                UNITW                           
                DSQ             DDV                            
                                DP1/10                          

                BDSU            PDDL                            
                                DP1/8TH
                                36D
                STODL           RMAG
                                J(RE)SQ
                DDV
                                34D
                STORE           32D
                DMP
                VXSC            PDDL                            

                                UNITR                           
                DMP             VXSC                            
                                32D                             
                                UNITW
                VAD             VAD                             
                                UNITR                           
                PDDL            DDV
                                -MUDT
                                34D
                VXSC            STADR
                STORE           GDT1/2


                RVQ

CALCRVG         VLOAD           VXSC                            
                                DELV                            
## Page 789
                                KPIP1                           
                PUSH            STQ                             # DV/2 TO PD SCALED AT 2(+7)M/CS
                                31D
                VAD             PUSH                            # (DV-OLDGDT)/2 TO PD SCALED AT 2(+7)M/CS
                                GDT/2                           
                VAD             VXSC                            
                                VN                              
                                2SEC(17)                        

                VAD
                                RN                              
                STCALL          RN1                             # TEMP STORAGE OF RN SCALED 2(+24)M
                                CALCGRAV                        

                VAD             VAD                             
                VAD                                             
                                VN                              
                STCALL          VN1                             # TEMP STORAGE OF VN SCALED 2(+7)M/CS
                                31D                             

KPIP            2DEC            .1024                           # SCALES DELV TO 2(+4)

KPIP1           2DEC            0.0064

DP1/8TH         2DEC            0.125

DP1/10          2DEC            0.1

J(RE)SQ         2DEC            0.060066630     B-5             #      SCALED AT 2(+45)

-MUDT           2DEC*           -7.9720645      E+12 B-55*   

2SEC(17)        2DEC            200             B-17

DP2(-3)         2DEC            0.125

MUEARTH         2DEC            0.009063188                     # 3.98603223 E14 SCALED AT 2(42)M(3)/CS(2)

MUMOON          2DEC            0.007134481                     # 4.90277800 E12 SCALED AT 2(36)M(3)/CS(2)

## Page 790
#

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#     THE MASS UPDATE ROUTINE EXTENDS FROM APPROXIMATELY HERE TO THE NEXT
# ROW OF ASTERISKS.   COMPUTATIONS ARE AS FOLLOWS:-
#     (1) /AF/ = MAGNITUDE DV/DT, SCALED IN UNITS OF 2(-5) M/CS/CS.
#     (2) PREFORCE = /AF/ MASS, APPROXIMATE PRESENT THRUST, SCALED AT
#         SOME 3.3 POUNDS PER BIT; PREFORCE LATER BECOMES PREFORCE/2FMAX.
#     (3) NOMINAL EXHAUST VELOCITY, VEXNOM = VEXSTEP + (PREFORCE-FSTEP)
#         SLOPE, WHERE VEXSTEP, FSTEP, AND SLOPE ARE SELECTED FROM THE
#         'VEXTABLE' BY THE ROUTINE BEGINNING AT VEXFINDD; THE FSTEPS
#         AND VXSTEPS DEFINE CERTAIN DISCRETE POINTS ON THE CURVE OF
#         EXHAUST VELOCITY VERSUS THRUST; THE ASSOCIATED SLOPE IS ALWAYS

#         THAT FOR THE SEGMENT JUST PRECEEDING THOSE POINTS.   (UNITS
#         FOR VEXNOM, AS FOR NEGVEX, ARE 2(6) M/CS.)
#     (4) AREARATE, A MODERATELY ABSTRUSE (NOT TO SAY ABSURD) FUNCTION
#         OF DELAREA (EROSION) AND PREFORCE.   (THE AREA IN QUESTION IS
#         THAT OF THE THROAT OF THE ENGINE.)
#     (5) DELAREA = DELAREA + AREARATE DELTAT.
#     (6) NEGVEX = -(VEXNOM - CVEX5 DELAREA).
#     (7) MASS = MASS + (/DELV//NEGVEX) MASS, SCALED IN UNITS OF 2(15)
#         KILOGRAMS.

#     THE FOLLOWING INITIALIZATIONS MUST BE MADE BEFORE LAUNCH:
# C(MASS) = 0, C(LEMMASS1) = SCALED MASS OF LEM CUM DPS, C(LEMMASS2) =
# SCALED MASS OF LEM WITHOUT DPS.   UPON LEM-SIVB SEPARATION MASS MUST
# BE REINITIALIZED USING LEMMASS1 AND DELAREA MUST BE SET TO DP ZERO.
# LATER, WHEN THE DPS PARTS COMPANY, MASS MUST BE INITIALIZED STILL
# AGAIN USING LEMMASS2.
#     THE FOLLOWING IS AN INELEGANT SUPERFLUITY:-   INPUTS: MASS, DELAREA,
# DELV, DELTAT, EMANATIONS FROM THE VEXTABLE, A TABLESPOON OF SALT AND
# SEVEN BYZANTINE DODO EGGS.   OUTPUTS: /AF/ AND MASS.   DEBRIS: PREFORCE,
# NEGVEX, AND AREARATE (TO LEARN MORE ABOUT THESE GEMS, SEE ABOVE).
# SUBROUTINES CALLED: MASSMULT (A PART OF THROTTLE CONTROL) AND THE
# INTERPRETER.   ERASABLES: BANK 5 AT PRESENT.   EYLES WROTE THIS STUFF;
# HIS LAST MODIFICATION THEREOF (NUMBER N+2) WENT INTO AGC REVISION 20.

MASSMON         DLOAD           BHIZ
                                MASS
                                NOMASS
                VLOAD           VXSC
                                DELV                            # DV = DELV*KPIP SCALED AT 2(+4) M/CS
                                KPIP
                PUSH            ABVAL                           # DV IN PDL
                STORE           ABDVCONV
                PUSH            DDV
                                2SEC(9)

                STORE           /AF/                            # /AF/ = MAGNITUDE DV/DT
                EXIT

                CA              ETHROTL
## Page 791
                TS              EBANK                           # JUST TO INSURE HAVING THE PROPER EBANK
                EBANK=          ETHROT

                EXTEND
                DCA             /AF/
                TC              MASSMULT                        # WHICH PRODUCES DP FORCE IN A AND L

                DXCH            PREFORCE

CHOICE1         CS              PREFORCE                        # TEST PREFORCE TO SEE IF
                AD              LOWFCRIT                        #   EITHER BIG ENGINE IS ON
                EXTEND
                BZMF            CHOICE2                         # BRANCH IF PREFORCE > LOWFCRIT = 720 LBS.

VEXFINDR        EXTEND                                          # OTHERWISE, USE RCSVEX
                DCS             RCSVEX
                DXCH            NEGVEX
                TCF             ENDVEX


CHOICE2         CS              MASS                            # TEST MASS TO SEE IF THE
                AD              MASSCRIT                        #   DPS HAS PARTED COMPANY
                EXTEND
                BZMF            VEXFINDD                        # BRANCH IF MASS > MASSCRIT = 5682 KGS.

VEXFINDA        EXTEND                                          # OTHERWISE, USE APSVEX
                DCS             APSVEX
                DXCH            NEGVEX
                TCF             ENDVEX

VEXFINDD        CA              ZERO
                TS              VEXDEX
VEXLOOP         CA              FOUR
                ADS             VEXDEX                          # INCREMENTING VEXDEX BY FOUR
                CS              PREFORCE
                INDEX           VEXDEX
                AD              FSTEP                           # FSTEP - PREFORCE IN A AND L
                EXTEND
                BZMF            VEXLOOP                         # BRANCH IF PREFORCE > OR = FSTEP.  EMERGE
                                                                #   FROM LOOP WITH INDEX PROPERLY SET AS
                                                                #   SOON AS FSTEP > PREFORCE.
                COM                                             # PREFORCE-FSTEP (ALWAYS MINUS) IN A AND L
                EXTEND

                INDEX           VEXDEX
                MP              SLOPE
                DXCH            VEXNOM
                EXTEND
                INDEX           VEXDEX
                DCA             VEXSTEP
                DAS             VEXNOM                          # VEXNOM = VEXSTEP + (PREFORCE-FSTEP)SLOPE

                CS              -FMAX
## Page 792
                DOUBLE
                XCH             Q

                EXTEND
                DCA             PREFORCE
                EXTEND
                DV              Q
                TS              PREFORCE                        # PREFORCE = PREFORCE/2FMAX

                CA              CVEX4
                EXTEND
                MP              DELAREA
                AD              CVEX3

                EXTEND
                MP              PREFORCE
                EXTEND                                          #               MUMBO
                MP              PREFORCE                        #               JUMBO
                DXCH            AREARATE
                CA              CVEX2
                EXTEND
                MP              DELAREA
                AD              CVEX1
                EXTEND
                MP              PREFORCE
                DAS             AREARATE                        # SCALED IN UNITS OF 2(-4) PERCENT/CS


                CA              AREARATE
                EXTEND
                MP              2SEC(9)
                DXCH            DAREATMP
                EXTEND
                DCA             DELAREA
                DAS             DAREATMP                        # DAREATMP NOW CONTAINS NEW DELAREA
                CA              DAREATMP
                EXTEND

                MP              CVEX5
                DXCH            NEGVEX
                EXTEND
                DCS             VEXNOM
                DAS             NEGVEX                          # NEGVEX NOW HOLDS THE GENUINE ARTICLE

                TS              MODE
ENDVEX          CA              ZERO                            # PRECAUTIONARY
                TS              OVFIND

                TC              INTPRET
                DLOAD           SR2                             # RESCALING /DELV/ TO 2(6) M/CS

                DDV             DMP
                                NEGVEX
                                MASS
                DAD
## Page 793
                                MASS
NOMASS          STORE           MASSTEMP
                RVQ

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                                                # * * * * * * * * * * * * * * * * * * * *

                                                                # CONSTANTS FOR VEXFIND1

2SEC(9)         2DEC            200             B-9             # CONSTANT GUIDANCE PERIOD, SUP70S5DLY



LOWFCRIT        DEC             .01336                          # MAXIMUM THRUST OF THE RCS JETS

MASSCRIT        DEC             .173031964                      # MASS OF LEM WITH DPS > MASSCRIT > MASS
                                                                #   OF LEM WITHOUT DPS

RCSVEX          2DEC            .4134375                        # EXHAUST VELOCITY FOR RCS JETS

APSVEX          2DEC            .473441550                      # EXHAUST VELOCITY FOR ASCENT ENGINE

CVEX1           DEC             -.14438400
CVEX2           DEC             +.00493568
CVEX3           DEC             +.96256000
CVEX4           DEC             -.03297280
CVEX5           DEC             +.01274865

                                                                # ADDRESSES FOR ACCESSING VEXTABLE

FSTEP           =               FSTEP1          -4

SLOPE           =               SLOPE1          -4
VEXSTEP         =               VXSTEP1         -4

                                                                # THE VEXTABLE

FSTEP1          DEC             .046875
SLOPE1          DEC             .603681848
VXSTEP1         2DEC            .45615938

FSTEP2          DEC             .095703125

SLOPE2          DEC             -.128576102
VXSTEP2         2DEC            .44988125

FSTEP3          DEC             .164062500
SLOPE3          DEC             .29568000
VXSTEP3         2DEC            .470093750

FSTEP4          DEC             .19531250
SLOPE4          DEC             -.171499840
## Page 794
VXSTEP4         2DEC            .46473438


HIFSTEP         DEC             .390625000                      # JUST IN CASE, ANOMALOUSLY,
HISLOPE         DEC             0                               #   PREFORCE APPEARS TO EXCEED
HIVXSTEP        2DEC            .464734380                      #   100 PERCENT FMAX.
                                                                # * * * * * * * * * * * * * * * * * * * * *

ETHROTL         ECADR           ETHROT
