### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTEGRATION_INITIALIZATION.agc
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
## Reference:   pp. 713-722
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-13 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 713
# AVETOMID PERFORMS THE TRANSITION FROM A THRUSTING PHASE TO A COASTING PHASE.  THE ROUTINE INITIALIZES THE
# ORBITAL INTEGRATION PROGRAM AND RESCALES AND TRANSFORMS LEMS STATE VECTOR FROM THE STABLE MEMBER COORDINATE
# SYSTEM USED IN AVERAGEG TO THE REFERENCE SYSTEM USED IN ORBITAL INTEGRATION DURING COAST
# INPUT - LEM STATE VECTOR IN SM COORDINATE SYSTEM AND TIME
#    RN, POSITION IN METERS SCALED AT 2(+24)
#    VN, VELOCITY IN M/CSEC SCALED AT 2(+7)
#    PIPTIME, TIME IN CSEC CORRESPONDING TO RN, VN
#
# OUTPUT - LEM STATE VECTOR IN REF. COORDINATE SYSTEM AND TIME
#    RRECT AND RCV, POSITION IN KM SCALED AT 2(+14)
#    VRECT AND VCV, VELOCITY IN 1/SQRT(KM) SCALED AT 2(-6)
#    TET, TIME IN CSEC
#    P-MEMORY (REFRRECT TO REFRRECT + 42)
#
# AVETOMID CALLING SEQUENCE
#    L-2   EXTEND
#    L-1   DCA    (2CADR OF AVETOMID)
#    L     DXCH   Z
#          DELETE
#
# NORMAL EXIT
#    AT L+1 OF CALLING SEQUENCE

                BANK            07
                EBANK=          AMEMORY
AVETOMID        DXCH            AVMIDRTN
                TC              INTPRET
                CALL                                    # ORBITAL INTEGRATION INITIALIZATION
                                INITINT
                VLOAD
                                ZEROVEC
                STORE           TDELTAV                 # ZERO POS DEVIATIONS

                STORE           TNUV                    # ZERO VEL DEVIATIONS
                STORE           TC                      # ALSO CLEARS TET AND XKEP

SMTOREF         AXT,1           SSP                     # SET UP TIX LOOP FOR STATE VEC TRANSFORM
                                12D
                                S1
                                6
SMTOREF1        VLOAD*          VXSC*                   # TRANSFORM STATE FROM SM TO REF SYSTEM
                                RN              +12D,1
                                SCLRAVMD        +12D,1
                VXM             VSL2
                                REFSMMAT
                STORE           RRECT           +12D,1
                STORE           RCV             +12D,1

                TIX,1           EXIT
                                SMTOREF1
                EXTEND
## Page 714
                DCA             PIPTIME                 # SAVE PIPTIME
                DXCH            TET                     # PIPTIME UN TET

                TC              MOVETEMP                # TRANSFER STATE AND INIT. DATA TO P-MEM
                DXCH            AVMIDRTN
                DXCH            Z
PIPEBANK        OCT             02400                   # EBANK 05
TESTLOOP        EXIT                                    # FOR DUMP.

                TC              INTPRET

                DLOAD           BOV
                                TDEC
                                +1                      # CLEAR OVERFLOW INDICATOR

                DSU             RTB
                                TET
                                SGNAGREE
                SL              DDV
                                11D
                                EARTHTAB        +9D
                STORE           DT/2
                BOV             ABS
                                USEMAXDT
                DSU             BMN
                                DT/2MIN
                                DECISION                # INTEGRATION FINISHED-DECIDE WHERE TO GO
                DAD             DSU
                                DT/2MIN
                                DT/2MAX
                BMN
                                TIMESTEP
USEMAXDT        DLOAD           SIGN
                                DT/2MAX
                                DT/2
                STCALL          DT/2
                                TIMESTEP
SCALER          DEC             14

SCALDELT        DEC             4
SCALEDT         DEC             18
28SECS          2DEC            2800

270SECS         2DEC            27000

2SECS           2DEC            200

ZEROVEC         2DEC            0

                2DEC            0

                2DEC            0

## Page 715
# THE ORDER OF THE SIX FOLLOWING CONSTANTS CANNOT BE CHANGED

SCLRAVMD        2DEC            .512                    # METERS TO KM  1/2(1024/1000)

DT/2MIN         2DEC            .00003

SCLRMDAV        2DEC            1000            B-10    # KM TO METERS

SCLVAVMD        2DEC            .64876819               # METERS/CSEC TO 1/SQR(KM)

DT/2MAX         2DEC            .65027077       B-1     # 270 SEC MAX TIME STEP

SCLVMDAV        2DEC            .7706913                # 1/SQR(KM) TO METERS/CSEC

## Page 716
# STATEINT IS CALLED UP UNDER A JOB EVERY 539 SECONDS DURING A COASTING   PHASE BY THE MISSION SCHEDULING
# MAINTENANCE ROUTINE TO MAINTAIN THE LEMS STATE VECTOR WITHIN TWO INTEGRATION STEPS (540 SECONDS) OF THE CURRENT

# TIME (TIME2).  THE ROUTINE COMPARES TIME2 WITH TET (THAT TIME CORRESPONDING TO THE STATE VECTOR IN STORAGE).
# IF TET LAGS BY 270 SECONDS OR MORE, THE ORBITAL INTEGRATION PROGRAM IS  CALLED UP AND THE STATE IS UPDATED TO
# TIME2.  IF TET DOES NOT LAG, STATEINT IS TERMINATED BY ENDOFJOB.
#
# INPUT-STATEINT ASSUMES THAT THE COASTING IN PROGRESS WAS INITIALIZED BY
#    THE AVETOMID ROUTINE.

STATEINT        EXTEND
                DCA             TIME2                  # GET CURRENT TIME IN TDEC
                DXCH            TDEC
                TC              FLAG2UP                # SET ORBITAL INTEGRATION FLAG
                OCT             100
                TC              MOVEPERM               # BRING STATE FROM PMEMORY
                TC              INTPRET

                DLOAD           DSU                    # FORM TDEC-TET
                                TDEC
                                TET
                BMN             DSU                    # IS STATE LAGGING
                                NOINT                  # NO, TET GREATER THAN TDEC
                                270SECS
                BMN             SSP
                                NOINT                  # NO, TET GREATER THAN TDEC-270 SECS.

                                MEASMODE               # BRING TO CURRENT TIME-SET MEASMODE (-1)
                DEC             -1
                CALL
                                INITINT                # INITIALIZE BRANCH REGS
                GOTO
                                TESTLOOP               # START INTEGRATION FROM TET TO TDEC
NOINT           EXIT                                   # TEMPORARY STATEINT EXIT
                TCF             INTOUT                 # NO INTEGRATION, TERMINATE THIS JOB

## Page 717
# MOVETEMP TRANSFERS RRECT TO RRECT +42 FROM A-MEMORY TO P-MEMORY
#
# CALLING SEQUENCE
#    L   TC   MOVETEMP
#
# NORMAL EXIT AT L+1
MOVETEMP        CAF             FORTYTWO
                TS              DIFEQCNT                # INITIALIZE INDEX

                INDEX           DIFEQCNT
                CA              RRECT                   # PICK UP RRECT TO RRECT +42 FROM A-MEMORY
                INDEX           DIFEQCNT
                TS              REFRRECT                # STORE IN REFRRECT TO REFRRECT +42 IN P-M
                CCS             DIFEQCNT                # IS TRANSFER COMPLETE
                TCF             MOVETEMP        +1      # NO-LOOP AGAIN
                TC              Q                       # TRANSFER COMPLETE-RETURN

# MOVEPERM TRANSFERS REFRRECT TO REFRRECT +42 FROM PMEMORY TO A-MEMORY

MOVEPERM        CAF             FORTYTWO
                TS              DIFEQCNT
                INDEX           DIFEQCNT
                CA              REFRRECT
                INDEX           DIFEQCNT
                TS              RRECT
                CCS             DIFEQCNT
                TCF             MOVEPERM        +1
                TC              Q

INITINT         SSP             SSP
                                PBODY                   # EARTHTAB INTO PBOAY
                                EARTHTAB

                                STEPEXIT                # TESTLOOP INTO STEPEXIT
                                TESTLOOP
                CLEAR           CLEAR
                                MIDFLAG                 # ZERO ON 206
                                MOONFLAG                # ZERO ON 206
                CLEAR           RVQ
                                WMATFLAG                # W-MATRIX NOT USED ON 206

## Page 718
# MIDTOAVE PERFORMS THE STATE VECTOR TRANSITION FROM A COASTING PHASE
# USING THE ORBITAL INTEGRATION PROGRAMS TO A TRUSTING PHASE WHICH USES
# AVERAGEG INTEGRATION.  THE ROUTINE RESCALES AND TRANSFORMS THE STATE
# VECTOR AT TIGN-30, TIGN-2 AND TIGN FROM REFERENCE COORDINATES TO
# STABLE MEMBER COORDINATES AS DIRECTED BY THE DECISION ROUTINE
#
# INPUT-MIDTOAVE ASSUMES THAT THE COASTING INTEGRATION WAS INITIALIZED
#    BY THE AVETOMID ROUTINE,  STATE IN REF. COORD. IN PMEMORY.
#
#    RRECT, RCV-POSITION IN KM SCALED AT 2(+14)
#    VRECT, VCV- VELOCITY IN 1/SQRT(KM) SCALED AT 2(-6)
#    TET, TIME IN CSECS.
#
# OUTPUT-STATE IN STABLE MEMBER COORDINATES

# AT TIGN-30
#    RAVEGON, POSITION IN METERS SCALED IN 2(+24)
#    VAVEGON, VELOCITY IN METERS/CSEC SCALED AT 2(+7)
#
# AT TIGN-2
#    RIG-2SEC, POSITION IN METERS SCALED AT 2(+24)
#
# AT TIGN
#
#    RIGNTION, POSITION IN METERS SCALED AT 2(+24)
#    VIGNTION, VELOCITY IN METERS/CSEC SCALED AT 2(+7)
#
# CALLING SEQUENCE
#    (COMPUTE TDEC=TIME OF IGNITION-30 SECS.)
#    L-2   EXTEND
#    L-1   DCA    (2CADR OF MIDTOAVE)
#    L     DXCH   Z
#
# NORMAL EXIT
#    L+1 OF CALLING SEQUENCE

RVUPDATE        DXCH            AVMIDRTN
                CAF             BIT1                    # SET MEASMODE TO +1 TO INTEGRATE STATE

                TCF             MIDTOAVE        +2      # TO TDEC AND STORED IN RIGNTION ONLY

MIDTOAVE        DXCH            AVMIDRTN
                CA              NEG0
                TS              MEASMODE                # SET MEASMODE (-0) TO INTEGRATE TO IG-30
                TC              FLAG2UP                 # SET ORBITAL INTEGRATION FLAG
                OCT             100
                TC              MOVEPERM                # BRING STATE FROM PMEMORY
                TC              INTPRET
                CALL                                    # INITIALIZE ORBITAL INTEGRATION REGS
                                INITINT
                GOTO
                                TESTLOOP                # GO TO ORBITAL INTEGRATION

## Page 719
# THE DECISION ROUTINE DETERMINES THE ACTION TO BE TAKEN AFTER ORBITAL
# INTEGRATION HAS UPDATED THE STATE VECTOR TO THE TIME INDICATED
# BY TDEC.  THE ACTION TAKEN IS BASED ON THE CONTENTS OF MEASMODE,
#
# C(MEASMODE)=(-0), STATE INTEGRATED (REF. COORD.) TO TIGN-30, SET
#             MEASMODE=(+0), SET TDEC=TIGN-2SECS.
# C(MEASMODE)=(+0), POSITION VECTOR INTEGRATED TO TIGN-2, SET MEASMODE=,+1
#             SET TDEC=TIGN
# C(MEASMODE)=(+1), STATE INTEGRATED TO TIGN, TRANSFORM STATE FROM REF TO
#             SM COORD. SYSTEM AND RETURN TO MISSION PROGRAM
# C(MEASMODE)=(-1), STATE INTEGRATED TO TDEC DURING COAST PHASE, TERMINATE
#             STATEINT JOB INITIATED BY MISSION SCHEDULING PACKAGE

DECISION        EXIT
                CCS             MEASMODE
                TCF             +3                      # STATE IN REF  COOR AT IGN
                TCF             +2                      # STATE IN REF COORD AT IGN-2
                TCF             COASTINT                # COAST INTEGRATION STEP COMPLETE
                TC              INTPRET
                CALL

                                RECTIFY                 # RECTIFY AT IGN-30,IGN-2,IGN

                EXIT
                CCS             MEASMODE
                TCF             REFTOSM                 # STATE AT TIGN-FINISH UP MIDTOAVE
                TCF             IGN-2SEC                # POS AT TIGN-2, DO TIGN NEXT
FORTYTWO        DEC             41
                TCF             AVEGON                  # STATE AT TIGN-30, DO TIGN-2 NEXT

AVEGON          TC              INTPRET
                AXT,1           SSP                     # SET LOOP
                                12D
                                S1
                                6
SPECPLS1        VLOAD*          VXSC*
                                RRECT           +12D,1
                                SCLRMDAV        +12D,1  #   REF TO SM SCALE FACTOR
                MXV             VSL1
                                REFSMMAT
                STORE           RAVEGON         +12D,1
                TIX,1           DLOAD
                                SPECPLS1
                                TDEC                    # TDEC NOW=TIGN-30

                STORE           PIPTIME                 # SAVE TIGN-30 IN PIPTIME FOR AVERAGEG
                STORE           TAVEGON                 # TIME TIG-30 FOR DWNLINK IN NORMLIZE
                DAD
                                28SECS                  # TDEC + 28SECS
                STORE           TDEC                    # TDEC SET TIGN-2
                SSP             GOTO
                                MEASMODE                # SET MEASMODE=(+0)

## Page 720
                                0
                                TESTLOOP                # GO INTEGRATE STATE TO IGN-2

IGN-2SEC        TC              INTPRET
                VLOAD           VXSC                    # TRANSFORM POS AT IGN-2 FROM REF TO SM
                                RRECT
                                SCLRMDAV
                MXV             VSL1
                                REFSMMAT
                STODL           RIG-2SEC                # POS IN SM COORD. AT IGN-2
                                TDEC
                DAD
                                2SECS
                STORE           TDEC                    # TDEC SET TIGN
                SSP             GOTO
                                MEASMODE                # SET MEASMODE=(+1)
                                1
                                TESTLOOP                # GO INTEGRATE STATE TO TIGN

## Page 721

REFTOSM         TC              FLAG2DWN                # REMOVE ORBITAL INTEGRATION GLAG
                OCT             100
                TC              INTPRET
                AXT,1           SSP                     # SET UP TIX LOOP
                                12D                     # 12 IN X1
                                S1                      # 6 IN S1
                                6
REFTOSM1        VLOAD*          VXSC*                   # TRANSFORM STATE AT TIGN FROM REF TO SM

                                RRECT           +12D,1
                                SCLRMDAV        +12D,1  # REF TO SM SCALE FACTOR
                MXV             VSL1
                                REFSMMAT
                STORE           RIGNTION        +12D,1  #   STATE AT TIGN IN SM COORDINATES
                TIX,1           EXIT
                                REFTOSM1
                EXTEND                                  # PLAY SAFE WITH BASIC********************
                DCA             TET                     # ****************************************
                DXCH            TIGN                    # STATE TIME FOR DWNLINK IN VPATCHER
                DXCH            AVMIDRTN
                DXCH            Z
# THE COASTINT ROUTINE TERMINATES THE ORBITAL INTEGRATION JOB SET BY
# MISSION SCHEDULING ROUTINE EVERY 539 SECONDS DURING COASTING PHASES.
# THE ROUTINE TRANSFERS THE STATE VECTOR AND ALL OTHER ORBITAL INTEGRATION
# QUANTITIES TO P-MEMORY.  IT FORMS A TOTAL STATE VECTOR AND TRANSFORMS IT
# TO STABLE MEMBER COORDINATES AND STORES IT WITH TIME IN RN, VN AND
# STATIME FOR DOWNLINK.  THE ROUTINE THEN REMOVES THE INTEGRATION FLAG
# TO ALLOW GROUND UPDATE OF THE STATE VECTOR AND DOES ENDOFJOB.

COASTINT        TC              MOVETEMP
                TC              INTPRET
                VLOAD           VSR8                    # FORM TOTAL STATE VECTOR

                                DELTAV
                VSR2            VAD
                                REFRCV
                STOVL           RRECT
                                NUV
                VSR8            VAD
                                REFVCV
                STORE           VRECT                   # TOTAL VEL. VECTOR

                AXT,1           SSP                     # SET TIX LOOP TO TRANSFORM STATE TO SM
                                12D
                                S1
                                6
TRANTOSM        VLOAD*          VXSC*                   # TRANSFORM STATE AND RE-STORE IN RRECT
                                RRECT           +12D,1
                                SCLRMDAV        +12D,1
                MXV             VSL1
                                REFSMMAT
                STORE           RRECT           +12D,1  # STATE IN SM SYSTEM

## Page 722
                TIX,1
                                TRANTOSM
                EXIT

                INHINT                                  # INHIBIT INTERUPT TO STORE STATE IN RN
                CAF             ELEVEN                  # INITIALIZE INDEX TO DEC 11
STATORN         TS              RUPTREG1
                INDEX           RUPTREG1
                CA              RRECT                   # PICK RRECT + NEXT 11 REGS
                INDEX           RUPTREG1
                TS              RN                      # JAM IN RN TO RN+11 FOR DOWNLINK
                CCS             RUPTREG1
                TCF             STATORN
                EXTEND

                DCA             TE                      # GET STATE TIME
                DXCH            STATIME
                RELINT                                  # STATE AND TIME IN DOWNLINK REGS

INTOUT          TC              FLAG2DWN                # REMOVE ORBITAL INTEGRATION FLAG
                OCT             100

                TC              ENDOFJOB
