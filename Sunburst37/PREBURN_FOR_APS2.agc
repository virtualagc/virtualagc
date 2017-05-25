### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     PREBURN_FOR_APS2.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-28 HG   Transcribed
##		 2016-10-31 RSB	 Typos
##		 2016-12-06 RSB	 Comment proofing via octopus/ProoferComments
##				 performed, and changes made.

## Page 911
#      PREAPS2 IS A PROGRAM WHICH INITIALIZED **ASCENT** FOR THE 2ND APS
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
                                ENGNOM                  # LOAD NOMINAL AT,VE,TBUP
                STOVL           AT                      # STORE IN ERASE
                                PREIGN                  # LOAD NOM, 1/DV1, 1/DV2, 1/DV3.
                STODL           ATMEAS                  # STORE IN ERASE
                                DP.5
                STODL           KR                      # LOAD PITCH LIMITING PARAMETER
                                DP0                     # LOAD 0
                STOVL           KR1                     # STORE IN KR1
                                VCONOM                  # LOAD NOM. RDOTD,YDOTD,ZDOTD
                STODL           RDOTD
                                VTO-APS
                STORE           VTO
                SSP             DLOAD
                                ASCRET
                                PRAPS                   # LOAD RETURN ADD. FROM ASCENT
                                TGONOM
                STORE           TGO                     # TGO$2(-17)

## Page 912
                SR              DAD
                                11D                     # TGO$2(-28)
                                TIGNTION
                STORE           TCO                     # TCO$2(-28)
                SET             CLEAR
                                DIRECT                  # DIRECT=1
                                BAKTO4                  # BAKTO4 = 0
                SET                                     # TO AVOID CLOBBERING TCO DURING PREBURN
                                PASS
                CLEAR           SET                     # CLEAR GUESSW FOR NO COGAVAIL
                                GUESSW
                                DONESW                  # TO START LAMBERT
                CLEAR           GOTO
                                HC                      # HC=0
                                ASCENT                  # GO TO ASCENT EQUATIONS
PRAPS           VLOAD           SET
                                AXISD
                                GUESSW                  # SET GUESSW FOR COGAVAIL
                STOVL           POINTVSM                # STORE FOR CALCMANU
                                BODYVECT                # LOAD UNIT X-AXIS
                STORE           SCAXIS                  # STORE FOR CALCMANU
                SET             CLEAR
                                DONESW
                                ENGOFFSW
                EXIT
                CA              CDUFAD                  # SET UP FOR NORMAL EXIT FROM ASCENT TO
                TS              ASCRET                  # FINDCDUD
                CA              PRIO17                  # GIVE LAMBERT A LOWER PRIORITY
                TS              LAMPRIO
                EXTEND
                DCA             RRETURN                 # GO BACK TO MP13
                DXCH            Z
ENGNOM          2DEC            .00033086       B9      # AT*2(9)
                2DEC            30.3030B-7              # VE*2(-7)
                2DEC            91587.6B-17             # TBUP*2(-17)
PREIGN          2DEC            15.187B-7               # 1/DV1
                2DEC            15.157B-7               # 1/DV2
                2DEC            15.127B-7               # 1/DV3
DP.5            =               BODYVECT
DP0             =               BODYVECT        +2
                EBANK=          PAXIS1
CDUFAD          FCADR           FINDCDUD
