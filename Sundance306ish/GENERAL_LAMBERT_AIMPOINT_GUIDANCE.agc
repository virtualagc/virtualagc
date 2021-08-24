### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GENERAL_LAMBERT_AIMPOINT_GUIDANCE.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



# GENERAL LAMBERT AIMPOINT GUIDANCE **
# WRITTEN BY RAMA M AIYAWAR

# PROGRAM P-31 DESCRIPTION **
#
# 1.    TO ACCEPT TARGETING PARAMETERS OBTAINED FROM A SOURCE EXTERNAL
#       TO THE LEM AND COMPUTE THERE FROM THE REQUIRED-VELOCITY AND
#       OTHER INITIAL CONDITIONS REQUIRED BY LM FOR DESIRED MANEUVER.
#       THE TARGETING PARAMETERS ARE TIG (TIME OF IGNITION), TARGET 
#       VECTOR (RTARG), AND THE TIME FROM TIG UNTIL THE TARGET IS
#       REACHED(DELLT4), DESIRED TIME OF FLIGHT FROM RINIT TO RTARG..

# ASSUMPTIONS **
#
# 1.    THE TARGET PARAMETERS MAY HAVE BEEN LOADED PRIOR TO THE
#       EXECUTION OF THIS PROGRAM.
# 2.    THIS PROGRAM IS APPLICABLE IN EITHER EARTH OR LUNAR ORBIT.
# 3.    THIS PROGRAM IS DESIGNED FOR ONE-MAN OPERATION, AND SHOULD
#       BE SELECTED BY THE ASTRONAUT BY DSKY ENTRY V37 E31.

# SUBROUTINES USED **
# 
# MANUPARM, TTG/N35, R02BOTH, MIDGIM, DISPMGA, FLAGDOWN, BANKCALL,
# GOTOPOOH, ENDOFJOB, PHASCHNG, GOFLASHR, GOFLASH.
#
# MANUPARM      CALCULATES APOGEE, PERIGEE ALTITUDES AND DELTAV DESIRED
#               FOR THE MANEUVER.
#
# TTG/N35       CLOCKTASK - UPDATES CLOCK.
#
# MIDGIM        CALCULATES MIDDLE GIMBAL ANGLE FOR DISPLAY.
#
# R02BOTH       IMU - STATUS CHECK ROUTINE.

# DISPLAYS USED IN P-31LM **
#
# V06N33        DISPLAY SOTRED TIG (IN HRS. MINS. SECS)
# V06N42        DISPLAY APOGEE, PERIGEE, DELTAV.
# V16N35        DISPLAY TIME FROM TIG.
# V06N45        TIME FROM IGNITION AND MIDDLE GIMBAL ANGLE.

# ERASABLE INITIALIZATION REQUIRED **
#
# TIG           TIME OF IGNITION                DP      (B+28) CS.
#
# DELLT4        DESIRED TIME OF FLIGHT          DP      (B+28) CS
#               FROM RINIT TO RTARG.
# RTARG         RADIUS VECTOR OF TARGET POSITION VECTOR
#               RADIUS VECTOR   SCALED TO  (B+29)METERS IF EARTH ORBIT
#               RADIUS VECTOR SCALED TO    (B+27)METERS IF MOON ORBIT

# OUTPUT **
#
# HAPO          APOGEE ALTITUDE
# HPER          PERIGEE ALTITUDE
# VGDISP        MAG.OF DELTAV FOR DISPLAY ,SCALING      B+7 M/CS EARTH
#               MAG.OF DELTAV FOR DISPLAY, SCALING      B+5 M/CS MOON
# MIDGIM        MIDDLE GIMBAL ANGLE
# XDELVFLG      RESETS XDELVFLG FOR LAMBERT VG COMPUTATIONS

# ALARMS OR ABORTS      NONE **

# RESTARTS ARE VIA GROUP 4 **

                SETLOC  GLM
                BANK
                
                EBANK=  SUBEXIT
                
                COUNT*  $$/P31
P31LM           TC      PHASCHNG
                OCT     05024
                OCT     13000

                CAF     V06N33*         # TIG
                TC      BANKCALL
                CADR    GOFLASH
                TCF     GOTOPOOH
                TCF     +2
                TCF     -5

                TC      INTPRET
                CALL
                        P31INT
                EXIT

                CAF     V06N42*         # HAPO, HPER, VGDISP
                TC      BANKCALL
                CADR    GOFLASHR
                TCF     GOTOPOOH
                TCF     +5
                TCF     -5
                TC      PHASCHNG
                OCT     00014
                TC      ENDOFJOB

                TC      BANKCALL
                CADR    COMPTGO
                CAF     V16N35
                TC      VNPOOH2
                CAF     POSMAX
                TS      DISPDEX
                TC      P31EXIT

VNPOOH2         EXTEND
                QXCH    RTRN
                TS      VERBNOUN
                CA      VERBNOUN
                TCR     BANKCALL
                CADR    GOFLASHR
                TC      GOTOPOOH
                TC      RTRN
                TCF     -5
                TC      PHASCHNG
                OCT     00014
                TC      ENDOFJOB

P31EXIT         TC      BANKCALL
                CADR    R02BOTH
                TC      INTPRET
                VLOAD   PUSH
                        DELVEET3
                CALL
                        MIDGIM
                CALL
                        REVN1645
                EXIT
                TC      DOWNFLAG
                ADRES   XDELVFLG
                TC      GOTOPOOH

V06N33*         VN      0633
V06N42*         VN      0642
V16N35          VN      1635

P31INT          STQ     DLOAD
                        QTEMP
                        TIG
                STCALL  TDEC1           # INTEGRATE STATE VECTORS TO TIG
                        LEMPREC
                SXA,1   VLOAD
                        P30EXIT
                        VATT1
                STOVL   VINIT
                        RATT1
                STORE   RINIT
                SETPD   SLOAD
                        0D
                        P31ZERO
                PDDL    PUSH            # E4 AND NUMIT = 0
                        P31ANGLE
                CALL
                        INITVEL
                LXA,1   VLOAD
                        P30EXIT
                        DELVEET3
                ABVAL
                STOVL   VGDISP
                        VIPRIME
                STOVL   VVEC
                        RINIT
                STCALL  RVEC
                        PERIAPO
                DLOAD
                        4D
                STODL   HAPO
                        8D
                STCALL  HPER
                        QTEMP

P31ANGLE        2DEC    .0555555555
P31ZERO         =       1BITDP



