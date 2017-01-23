### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     MASS_CALCULATOR.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-30 MAS  Transcribed.
##		 2016-12-06 RSB	 Comment-proofing via octopus/ProoferComments;
##				 changes were made.

## Page 844
                BANK            30
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
#     (5) DELAREA = DELAREA + AREARATE DELTAT, SCALED IN UNITS OF 2(7) %
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

MASSMON         DLOAD           BOFF
                                MASS
                                SIVBGONE
                                NOMASS
                VLOAD           VXSC
                                DELV                            # DV = DELV*KPIP SCALED AT 2(+4) M/CS
                                KPIP
                PUSH            ABVAL                           # DV IN PDL
                STORE           ABDVCONV
                PUSH            DDV
                                2SEC(9)
                STORE           /AF/                            # /AF/ = MAGNITUDE DV/DT

## Page 845
                EXIT

                CA              ETHROTL
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
                TCF             MININIT
CHOICE2         EXTEND
                READ            30
                COM
                MASK            BIT2
                EXTEND
                BZF             VEXFINDD
VEXFINDA        EXTEND                                          # OTHERWISE, USE APSVEX
                DCS             APSVEX
                DXCH            NEGVEX
MININIT         EXTEND
                DCA             MINMASSA
                DXCH            MINIMASS
                TCF             ENDVEX

VEXFINDD        EXTEND
                DCA             MINMASSD
                DXCH            MINIMASS

                CA              ZERO
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

## Page 846
                EXTEND
                INDEX           VEXDEX
                MP              SLOPE
                DXCH            VEXNOM
                EXTEND
                INDEX           VEXDEX
                DCA             VEXSTEP
                DAS             VEXNOM                          # VEXNOM = VEXSTEP + (PREFORCE-FSTEP)SLOPE

                CS              -FMAX
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
                DAS             AREARATE                        # NOW SCALED IN UNITS OF 2(-2) PERCENT/CS
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
                DXCH            NEGVEX                          # RESULT IS SCALED IN UNITS OF 2(6) M/CS
                EXTEND
                DCS             VEXNOM
                DAS             NEGVEX                          # NEGVEX NOW HOLDS THE GENUINE ARTICLE

ENDVEX          CA              ZERO                            # PRECAUTIONARY

## Page 847
                TS              MODE
                TS              OVFIND

                TC              INTPRET
                DLOAD           SR2                             # RESCALING /DELV/ TO 2(6) M/CS
                DDV             DMP
                                NEGVEX
                                MASS
                DAD
                                MASS
                STORE           MASSTEMP
                DSU             BPL                             # RETURN NOW IF MASS > MINIMASS
                                MINIMASS
                                QPRET
                DLOAD                                           # OTHERWISE SET MASS = MINIMASS
                                MINIMASS
                STORE           MASSTEMP
                RVQ

NOMASS          STODL           MASSTEMP
                                DP0
                STORE           DAREATMP                        # DELAREA INITIALIZED UNTIL SIVB SEPARATES
                RVQ

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                                                # * * * * * * * * * * * * * * * * * * * *

                                                                # CONSTANTS FOR VEXFIND1

2SEC(9)         2DEC            200             B-9             # CONSTANT GUIDANCE PERIOD, SUP70S5DLY



LOWFCRIT        OCT             411                             # ABOUT 720 POUNDS, SCALED
MASSCRIT        DEC             .173031964                      # MASS OF LEM WITH DPS > MASSCRIT > MASS
                                                                #   OF LEM WITHOUT DPS

RCSVEX          2DEC            .4134375                        # EXHAUST VELOCITY FOR RCS JETS

APSVEX          2DEC            .473441550                      # EXHAUST VELOCITY FOR ASCENT ENGINE

CVEX1           DEC             +.012558840
CVEX2           DEC             -.053575066
CVEX3           DEC             -.018875329
CVEX4           DEC             +.080517427
CVEX5           DEC             +.05099460

## Page 848
MINMASSA        2DEC            2106.4833       B-15            # MASS OF APS EMPTY

MINMASSD        2DEC            6245            B-15            # DESCENT WITH NO DPS FUEL AND 405 RCS


                                                                # ADDRESSES FOR ACCESSING VEXTABLE

FSTEP           =               FSTEP1          -4
SLOPE           =               SLOPE1          -4
VEXSTEP         =               VXSTEP1         -4

                                                                # THE VEXTABLE

FSTEP1          DEC             +.0592346907                    #  25%
SLOPE1          DEC             +.3104172317
VXSTEP1         2DEC            +.4553963093                    # ABOUT 2914.53 M/S



FSTEP2          DEC             +.1184693815                    #  50%
SLOPE2          DEC             -.0413889642
VXSTEP2         2DEC            +.4529446468                    # ABOUT 2898.84 M/S



FSTEP3          DEC             +.1990285610                    #  84%
SLOPE3          DEC             +.2168355662
VXSTEP3         2DEC            +.4704127421                    # ABOUT 3010.64 M/S



FSTEP4          DEC             +.2226276618                    #  93%
SLOPE4          DEC             -.0389579859
VXSTEP4         2DEC            +.4694933687                    # ABOUT 3004.75 M/S



HIFSTEP         DEC             +.9999999999                    # JUST IN CASE, ANOMALOUSLY,
HISLOPE         DEC             +.0000000000                    #   PREFORCE APPEARS TO
HIVXSTEP        2DEC            +.4694933687                    #   EXCEED 100%.
                                                                # * * * * * * * * * * * * * * * * * * * * *

ETHROTL         ECADR           ETHROT
