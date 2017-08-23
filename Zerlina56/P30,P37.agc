### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P30,P37.agc
## Purpose:     A log section of Zerlina 56, the final revision of
##              Don Eyles's offline development program for the variable 
##              guidance period servicer. It also includes a new P66 with LPD 
##              (Landing Point Designator) capability, based on an idea of John 
##              Young's. Neither of these advanced features were actually flown,
##              but Zerlina was also the birthplace of other big improvements to
##              Luminary including the terrain model and new (Luminary 1E)
##              analog display programs. Zerlina was branched off of Luminary 145,
##              and revision 56 includes all changes up to and including Luminary
##              183. It is therefore quite close to the Apollo 14 program,
##              Luminary 178, where not modified with new features.
## Reference:   pp. 612-615
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##		2017-08-23 RSB	Transcribed.

## Page 612
# PROGRAM DESCRIPTION  P30    DATE 3-6-67

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

## Page 613
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

## Page 614
# PROGRAM DESCRIPTION S30.1      DATE 9NOV66

# MOD NO 1        LOG SECTION  P30,P37
# MOD  BY  RAMA AIYAWAR **
# FUNCTIONAL DESCRIPTION
#          BASED ON STORED TARGET PARAMETERS(R OF IGNITION(RTIG),V OF
#          IGNITION(VTIG),TIME OF IGNITION (TIG)),COMPUTE PERIGEE ALTITUDE
#          APOGEE ALTITUDE AND DELTAV REQUIRED(DELVSIN).
# CALLING SEQUENCE
#     L    CALL
#     L+1         S30.1
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

## Page 615
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
                PUSH            VXV                     # YRF/LV PDL 0  SCALED AT 2
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
                STCALL          HAPO                    # APOGEE  ALT 2(29) METERS, FOR DISPLAY
                                QTEMP
