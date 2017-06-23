### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PREBURN_FOR_APS2.agc
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
## Reference:   pp. 851-852
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-11 HG   Transcribed
##              2017-06-15 HG   Fix interpretive operator STODL -> STORE
##              2017-06-17 MAS  Split up an "E-4B9".
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 851
#      PREAPS2 IS A PROGRAM WHICH INITIALIZES **ASCENT** FOR THE 2ND APS
# BURN. IT USES RN AND VN(TIG), PROVIDED BY MIDTOAVE THROUGH MP13, TO COM-
# PUTE THE P, Q, AND S AXES FOR TRANSFORMATIONS, SETS 3 SWITCHES FOR PRO-
# PER MODING OF ASCENT, AND TRANSFERS DATA FROM FIXED TO ERASABLE FOR USE
# AS NOMINALS AT TIG.
#      IT CALLS ASCENT ONCE TO PROVIDE UT AT IGNITION, AND THEN RESETS THE

# EXIT FROM ASCENT TO GO TO FINDCDUD ON SUBSEQUENT ASCENT ENTRIES.

                BANK            32
                EBANK=          PAXIS1
PREAPS2         DXCH            RRETURN
                CA              PRIO21                  # GIVE LAMBERT A HIGHER PRIORITY THAN
                TS              LAMPRIO                 # ASCENT, SO IT WILL FINISH.
                TC              INTPRET
                CALL
                                VPATCHER
                VLOAD
                                RN                      # LOAD RN*2(N-29)

                VXV             UNIT                    # RN X VN*2(N-36)
                                VN                      # SAXIS*2(-1)
                STORE           SAXIS                   # STORE SAXIS
                VXV             VSL1                    # S X UR*2(-2)=Q1*2(-2), NORM TO S AND R
                                UNITR                   # Q1*2(-1)
                VXSC            PDVL                    # Q1* COS27*2(-1)
                                COS27                   # IN PDL(0)*2(-1)                          2
                                UNITR                   # LOAD UR*2(-1)
                VXSC            BVSU                    # UR SIN27*2(-1)
                                SIN27                   # Q1 COS27-UR SIN27 = Q

                STADR                                   #                                          0
                STORE           QAXIS                   # STORE QAXIS
                VXV             VSL1                    # Q X S*2(-2) = P*2(-2)
                                SAXIS                   # P*2(-1)
                STOVL           PAXIS1                  # STORE PAXIS
                                ENGNOM                  # LOAD NOMINAL AT, 1/VE, TBUP
                STOVL           AT                      # STORE IN ERASE
                                PREIGN                  # LOAD NOM, 1/DV2,1/DV1,KR
                STODL           ATMEAS                  # STORE IN ERASE
                                DP0                     # LOAD 0
                STOVL           KR1                     # STORE IN KR1
                                VCONOM                  # LOAD NOM. RDOTD,YDOTD,ZDOTD

                STORE           RDOTD                   # STORE IN ERASE
                SSP
                                ASCRET
                                PRAPS                   # LOAD RETURN ADD. FROM ASCENT
                SET             CLEAR
                                DIRECT                  # DIRECT=1
                                PASS                    # PASS=0
                CLEAR           SET                     # CLEAR GUESSW FOR NO COGAVAIL
                                GUESSW
                                DONESW                  # TO START LAMBERT

## Page 852
                CLEAR           GOTO
                                HC                      # HC=0

                                ASCENT                  # GO TO ASCENT EQUATIONS
PRAPS           VLOAD           SET
                                UT                      # LOAD DES. THRUST VECTOR
                                GUESSW                  # SET GUESSW FOR COGAVAIL
                STOVL           POINTVSM                # STORE FOR CALCMANU
                                BODYVECT                # LOAD UNIT X-AXIS
                STORE           SCAXIS                  # STORE FOR CALCMANU
                EXIT
                CA              CDUFAD                  # SET UP FOR NORMAL EXIT FROM ASCENT TO
                TS              ASCRET                  # FINDCDUD

                CA              PRIO17                  # GIVE LAMBERT A LOWER PRIORITY
                TS              LAMPRIO
                EXTEND
                DCA             RRETURN                 # GO BACK TO MP13
                DXCH            Z
COS27           2DEC            .89100652
SIN27           2DEC            .45399050
ENGNOM          2DEC            3.20928237      E-4 B9  # AT*2(9)
                2DEC            .0330009301     B4      # (1/VE)*2(4)

                2DEC            94420.4114      B-17    # TBUP*2(-17)
PREIGN          2DEC            0                       # NOMINAL (1/DV2)*2( )
                2DEC            0                       # NOMINAL (1/DV1)*2( )
                2DEC            .5                      # KR*2(-1) FOR APS2
VCONOM          2DEC            0                       # RDOTD*2(-7)

                2DEC            73.9            B-7
                2DEC            20              B-7
DP.5            =               BODYVECT
DP0             =               BODYVECT        +2
                EBANK=          PAXIS1
CDUFAD          FCADR           FINDCDUD
