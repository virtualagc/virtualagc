### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P30,P37.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 292

# PROGRAM DESCRIPTION P30       DATE 3-6-67
#
# MOD.1 BY RAMA AIYAWAR
# FUNCTIONAL DESCRIPTION
#       ACCEPT ASTRONAUT INPUTS OF TIG,DELV(LV)
#       CALL IMU STATUS CHECK ROUTINE (R02)
#       DISPLAY TIME TO GO, APOGEE, PERIGEE, DELV(MAG), MGA AT IGN
#       REQUEST BURN PROGRAM
#
# CALLING SEQUENCE VIA JOB FROM V37
#
# EXIT VIA V37 CALL OR TO GOTOPOOH (V34E)
#
# SUBROUTINE CALLS -    FLAGUP, PHASCHNG, BANKCALL, ENDOFJOB, GOFLASH, GOFLASHR
#                       GOPERF3R, INTPRET, BLANKET, GOTOPOOH, R02BOTH, S30.1,
#                       TTG/N35, MIDGIM, DISPMGA
#
# ERASABLE INITIALIZATION - STATE VECTOR
#
# OUTPUT-RINIT, VINIT, +MGA, VTIG, RTIG, DELVSIN, DELVSAB, DELVSLV, HAPO,
#        HPER, TTOGO
#
# DEBRIS- A,L, MPAC, PUSHLIST

                BANK    32
                SETLOC  P30S
                BANK
                EBANK=  +MGA
                COUNT*  $$/P30

REVN1645        STQ     EXIT            # TRKMKCNT, TTOGO, +MGA
                        QTEMP1
                
                TC      COMPTGO
                CAF     V16N45
                TC      BANKCALL
                CADR    GOFLASHR
                TC      GOTOPOOH
                TC      +5
                TC      -5
                TC      PHASCHNG
                OCT     00014
                TC      ENDOFJOB

                CAF     ONE
                TS      DISPDEX
                TC      INTPRET
                GOTO
                        QTEMP1

P30             TC      UPFLAG          # SET UPDATE FLAG
                ADRES   UPDATFLG
                TC      UPFLAG          # SET TRACK FLAG
                ADRES   TRACKFLG
                
P30N33          CAF     V06N33          # T OF IGN
                TC      BANKCALL
                CADR    GOFLASHR
                TCF     GOTOPOOH
                TCF     +5
                TCF     -5
                TC      PHASCHNG
                OCT     00014
                TC      ENDOFJOB
                
                CAF     V06N82          # DISPLAY DELTA V (LV)
                TC      BANKCALL
                CADR    GOFLASH
                TCF     GOTOPOOH
                TCF     +2
                TCF     -5
                                        
                TC      DOWNFLAG        # RESET UPDATE FLAG
                ADRES   UPDATFLG
                TC      INTPRET
                CALL
                        S30.1
                DLOAD
                        4D
                STODL   HAPO
                        8D
                STORE   HPER
                SET     EXIT
                        UPDATFLG
PARAM30         CAF     V06N42          # DISPLAY APOGEE,PERIGEE ,DELTA V
                TC      BANKCALL
                CADR    GOFLASH
                TC      GOTOPOOH
                TCF     +2
                TCF     PARAM30

                CAF     REFSMBIT
                MASK    FLAGWRD3
                EXTEND
                BZF     MINMGA

                TC      INTPRET
                SET     VLOAD
                        AVFLAG
                        DELVSIN
                PUSH    CALL
                        MIDGIM
                GOTO
                        DISPMANV

MINMGA          TC      INTPRET
                DLOAD   DAD
                        DP-.01
                        DP-.01
                STORE   +MGA
DISPMANV        CALL
                        REVN1645
                SET     EXIT
                        XDELVFLG

                TC      GOTOPOOH
                
V06N33          VN      0633
V06N82          VN      0682
V06N42          VN      0642
V06N45          VN      0645

# PROGRAM DESCRIPTION S30.1     DATE 9NOV66
#
# MOD NO 1                      LOG SECTION P30,P37
# MOD BY RAMA AIYAWAR **
#
# FUNCTIONAL DESCRIPTION
#       BASED ON STORED TARGET PARAMETERS(R OF IGNITION (RTIG), V OF
#       IGNITION(VTIG), TIME OF IGNITION (TIG)),COMPUTE PERIGEE ALTITUDE
#       APOGEE ALTITUDE AND DELTAV REQUIRED(DELVSIN).
#
# CALLING SEQUENCE
#       L       CALL
#       L+1             S30.1
#
# NORMAL EXIT MODE
#       AT L+2 OR CALLING SEQUENCE (GOTO L+2)
#
# SUBROUTINES CALLED
#       LEMPREC
#       PERIAPO
#
# ALARM OR ABORT EXIT MODES
#               NONE
#
# ERASABLE INITIALIZATION REQUIRED
#       TIG             TIME OF IGNITION                DP B28CS
#       DELVSLV         SPECIFIED DELTA-V IN LOCAL VERT.
#                       COORDS. OF ACTIVE VEHICLE AT
#               TIME OF IGNITION        VECTOR B+7 METERS/CS
#
# OUTPUT
#       RTIG    POSITION AT TIG         VECTOR  B+29 METERS
#       VTIG    VELOCITY AT TIG         VECTOR  B+29 METERS/CS
#       PDL 4D  APOGEE ALTITUDE         DP      B+29 M ,  B+27 METERS.
#       HAPO    APOGEE ALTITUDE         DP      B+29 METERS
#       PDL 8D  PERIGEE ALTITUDE        DP      B+29 M ,  B+27 METERS.
#       HPER    PERIGEE ALTITUDE        DP      B+29 METERS
#       DELVSIN    SPECIFIED DELTA-V IN INERTIAL
#                  COORD. OF ACTIVE VEHICLE AT
#               TIME OF IGNITION        VECTOR  B+7 METERS/CS
#       DELVSAB MAG. OF DELVSIN         VECTOR  B+7 METERS/CS
#
# DEBRIS        QTEMP   TEMP.ERASABLE
#               QPRET, MPAC
#               PUSHLIST

                SETLOC  P30S1
                BANK
                
                COUNT*  $$/S30S
                
S30.1           STQ     DLOAD
                        QTEMP
                        TIG             # TIME IGNITION SCALED AT 2(+28)CS
                STCALL  TDEC1
                        LEMPREC         # ENCKE ROUTINE FOR LEM
                        
                VLOAD
                        RATT1
                STORE   RVEC
                STORE   RTIG            # RADIUS VECTOR AT IGNITION TIME
                UNIT    VCOMP
                STOVL   DELVSIN         # ZRF/LV IN DELVSIN SCALED AT 2
                        VATT1           # VELOCITY VECTOR AT TIG, SCALED 2(7) M/CS
                STORE   VTIG
                VXV     UNIT
                        RTIG
                SETPD
                        0
                PUSH    VXV             # YRF/LV PDL 0 SCALED AT 2
                        DELVSIN
                VSL1    PDVL
                PDVL    PDVL            # YRF/LV PDL 6 SCALED AT 2
                        DELVSIN         # ZRF/LV PDL 12D SCALED AT 2
                        DELVSLV
                VXM     VSL1
                        0
                STORE   DELVSIN         # DELTAV IN INERT. COOR. SCALED TO B+7M/CS
                ABVAL
                STOVL   DELVSAB         # DELTA V MAG.
                        VTIG            # (FOR PERIAPO)
                VAD                     # VREQUIRED = VTIG + DELVSIN (FOR PERIAPO)
                        DELVSIN
                STCALL  VVEC
                        PERIAPO
                GOTO
                        QTEMP


