### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P30,P37.agc
## Filename:    P30,P37.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 620-623
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-28 HG   Transcribed
##              2016-12-07 HG   fix P00 -> POO
##		2016-12-25 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.
##		2017-03-14 RSB	Comment-text fixes noted in proofing Luminary 116.

## Page 620
# PROGRAM DESCRIPTION P30       DATE 3-6-67

# MOD.1  BY RAMA AIYAWAR
# FUNCTIONAL DESCRIPTION
#    ACCEPT ASTRONAUT INPUTS OF TIG,DELV(LV)
#    CALL IMU STATUS CHECK ROUTINE (R02)
#    DISPLAY TIME TO GO, APOGEE, PERIGEE, DELV(MAG), MGA AT IGN
#    REQUEST BURN PROGRAM

# CALLING SEQUENCE VIA JOB FROM V37

# EXIT VIA V37 CALL OR TO GOTOPOOH (V34E)

# SUBROUTINE CALLS-FLAGUP, PHASCHNG, BANKCALL, ENDOFJOB, GOFLASH, GOFLASHR
#                  GOPERF3R, INTPRET, BLANKET, GOTOPOOH, R02BOTH, S30.1,
#                  TTG/N35, MIDGIM, DISPMGA

# ERASABLE INITIALIZATION- STATE VECTOR

# OUTPUT-RINIT, VINIT, +MGA, VTIG, RTIG, DELVSIN, DELVSAB, DELVSLV, HAPO,
#        HPER, TTOGO

# DEBRIS- A, L, MPAC, PUSHLIST

                BANK            32
                SETLOC          P30S
                BANK
                EBANK=          +MGA
                COUNT*          $$/P30
P30             TC              UPFLAG                  # SET UPDATE FLAG
                ADRES           UPDATFLG
                TC              UPFLAG                  # SET TRACK FLAG
                ADRES           TRACKFLG

P30N33          CAF             V06N33                  # T OF IGN
                TC              VNPOOH                  # RETURNS ON PROCEED, POOH ON TERMINATE

                CAF             V06N81                  # DISPLAY DELTA V (LV)
                TC              VNPOOH                  #     REDISPLAY ON RECYCLE

                TC              DOWNFLAG                # RESET UPDATE FLAG
                ADRES           UPDATFLG
                TC              INTPRET
                CALL
                                S30.1
                SET             SET
                                UPDATFLG
                                XDELVFLG
                EXIT
PARAM30         CAF             V06N42                  # DISPLAY APOGEE,PERIGEE ,DELTA V

## Page 621
                TC              VNPOOH

                TC              INTPRET
                SET
                                FINALFLG
REVN1645        CALL
                                VN1645
                GOTO                                    # COMES HERE ON RECYCLE RESPONSE
                                REVN1645

V06N33          VN              0633
V06N42          VN              0642

## Page 622
# PROGRAM DESCRIPTION S30.1       DATE 9NOV66

# MOD NO 1        LOG SECTION   P30,P37
# MOD  BY  RAMA AIYAWAR **
# FUNCTIONAL DESCRIPTION
#          BASED ON STORED TARGET PARAMETERS(R OF IGNITION(RTIG),V OF
#          IGNITION(VTIG),TIME OF IGNITION (TIG)),COMPUTE PERIGEE ALTITUDE
#          APOGEE ALTITUDE AND DELTAV REQUIRED(DELVSIN).
# CALLING SEQUENCE
#     L    CALL
#     L+1  S30.1
# NORMAL EXIT MODE
#     AT L+2 OR CALLING SEQUENCE (GOTO L+2)
# SUBROUTINES CALLED
#          LEMPREC
#          PERIAPO
# ALARM OR ABORT EXIT MODES
#                 NONE
# ERASABLE INITIALIZATION REQUIRED
#          TIG       TIME OF IGNITION                   DP     B28CS
#          DELVSLV   SPECIFIED DELTA-V IN LOCAL VERT.
#                    COORDS. OF ACTIVE VEHICLE AT
#                 TIME OF IGNITION      VECTOR  B+7  METERS/CS
# OUTPUT
#          RTIG   POSITION AT TIG       VECTOR  B+29 METERS
#          VTIG   VELOCITY AT TIG       VECTOR  B+29 METERS/CS
#          PDL 4D APOGEE ALTITUDE       DP      B+29 M ,  B+27 METERS.
#          HAPO   APOGEE ALTITUDE       DP      B+29 METERS
#          PDL 8D PERIGEE ALTITUDE      DP      B+29 M ,  B+27 METERS.
#          HPER   PERIGEE ALTITUDE      DP      B+29 METERS
#          DELVSIN   SPECIFIED DELTA-V IN INERTIAL
#                    COORD. OF ACTIVE VEHICLE AT
#                 TIME OF IGNITION      VECTOR  B+7  METERS/CS
#          DELVSAB MAG. OF DELVSIN      VECTOR  B+7  METERS/CS
# DEBRIS QTEMP    TEMP. ERASABLE
#        QPRET,MPAC
#        PUSHLIST

                SETLOC          P30S1
                BANK

                COUNT*          $$/S30S

S30.1           STQ             DLOAD
                                QTEMP
                                TIG                     # TIME IGNITION SCALED AT 2(+28)CS
                STCALL          TDEC1
                                LEMPREC                 # ENCKE ROUTINE FOR LEM

                VLOAD           SXA,2

## Page 623
                                RATT
                                RTX2
                STORE           RTIG                    # RADIUS VECTOR AT IGNITION TIME
                UNIT            VCOMP
                STOVL           DELVSIN                 # ZRF/LV IN DELVSIN SCALED AT 2
                                VATT                    # VELOCITY VECTOR AT TIG, SCALED 2(7) M/CS
                STORE           VTIG
                VXV             UNIT
                                RTIG
                SETPD           SXA,1
                                0
                                RTX1
                PUSH            VXV                     # YRF/LV PDL 0   SCALED AT 2
                                DELVSIN
                VSL1            PDVL
                PDVL            PDVL                    # YRF/LV PDL 6   SCALED AT 2
                                DELVSIN                 # ZRF/LV PDL 12D SCALED AT 2
                                DELVSLV
                VXM             VSL1
                                0
                STORE           DELVSIN                 # DELTAV IN INERT. COOR. SCALED TO B+7M/CS
                ABVAL
                STOVL           DELVSAB                 # DELTA V MAG.
                                RTIG                    # (FOR PERIAPO)
                PDVL            VAD                     # VREQUIRED = VTIG + DELVSIN (FOR PERIAPO)
                                VTIG
                                DELVSIN
                CALL
                                PERIAPO1
                CALL
                                SHIFTR1                 # RESCALE IF NEEDED
                CALL                                    # LIMIT DISPLAY TO 9999.9 N. MI.
                                MAXCHK
                STODL           HPER                    # PERIGEE ALT 2(29) METERS, FOR DISPLAY
                                4D
                CALL
                                SHIFTR1                 # RESCALE IF NEEDED
                CALL                                    # LIMIT DISPLAY TO 9999.9 N. MI.
                                MAXCHK
                STCALL          HAPO                    # APOGEE ALT 2(29) METERS, FOR DISPLAY
                                QTEMP
