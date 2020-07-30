### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P51-P53.agc
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



# PROGRAM NAME- PROG52                                                                   DATE- JAN 9, 1967
# MOD NO- 0                                                                              LOG SECTION- P51-P53
# MODIFICATION BY- LONSKE                                                                ASSEMBLY- SUNDANCE REV 46

# FUNCTIONAL DESCRIPTION-

#      ALIGNS THE IMU TO ONE OF THREE ORIENTATIONS SELECTED BY THE ASTRONAUT. THE PRESENT IMU ORIENTATION IS KNOWN
# AND IS STORED IN REFSMMAT. THE THREE POSSIBLE ORIENTATIONS MAY BE_

#      (A) PREFERRED ORIENTATION

#       AN OPTIMUM ORIENTATION FOR A PREVIOUSLY CALCULATED MANUEVER. THIS ORIENTATION MUST BE CALCULATED AND
#      STORED BY A PREVIOUSLY SELECTED PROGRAM.

#      (B) NOMINAL ORIENTATION
#
#          X   =  UNIT ( R )
#          -SM

#          Y  =  UNIT (V X R)
#           SM

#          Z   =  UNIT (X   X  Y  )
#           SM           SM     SM

#          WHERE_
#           R = THE GEOCENTRIC RADIUS VECTOR AT TIME T(ALIGN) SELECTED BY THE ASTRONAUT
#           -

#           V = THE INERTIAL VELOCITY VECTOR AT TIME T(ALIGN) SELECTED BY THE ASTRONAUT
#           -

#      (C) REFSMMAT ORIENTATION

#          (D)  LANDING SITE - THIS IS NOT AVAILIBLE IN SUNDANCE

#       THIS SELECTION CORRECTS THE PRESENT IMU ORIENTATION. THE PRESENT ORIENTATION DIFFERS FROM THAT TO WHICH IT
#      WAS LAST ALIGNED ONLY DUE TO GYRO DRIFT(I.E. NEITHER GIMBAL LOCK NOR IMU POWER INTERRUPTION HAS OCCURED
#      SINCE THE LAST ALIGNMENT).

#      AFTER A IMU ORIENTATION HAS BEEN SELECTED ROUTINE S52.2 IS OPERATED TO COMPUTE THE GIMBAL ANGLES USING THE
# NEW ORIENTATION AND THE PRESENT VEHICLE ATTITUDE. CAL52A THEN USES THESE ANGLES, STORED IN THETAD,+1,+2, TO
# COARSE ALIGN THE IMU. THE STAR SELECTION ROUTINE, R56, IS THEN OPERATED. IF 2 STARS ARE NOT AVAILABLE AN ALARM
# IS FLASHED TO NOTIFY THE ASTRONAUT. AT THIS POINT THE ASTRONAUT WILL MANUEVER THE VEHICLE AND SELECT 2 STARS
# EITHER MANUALLY OR AUTOMATICALLY. AFTER 2 STARS HAVE BEEN SELECTED THE IMU IS FINE ALIGNED USING ROUTINE R51. IF
# THE RENDEZVOUS NAVIGATION PROCESS IS OPERATING(INDICATED BY RNDVZFLG) P20 IS DISPLAYED. OTHERWISE P00 IS
# REQUESTED.

# CALLING SEQUENCE-

#      THE PROGRAM IS CALLED BY THE ASTRONAUT BY DSKY ENTRY.

# SUBROUTINES CALLED-

#     1. FLAGDOWN      7. S52.2           13. NEWMODEX
#     2. R02BOTH       8. CAL53A          14. PRIOLARM
#     3. GOPERF4       9. FLAGUP
#     4. MATMOVE      10. R56
#     5. GOFLASH      11. R51
#     6. S52.3        12. GOPERF3

# NORMAL EXIT MODES-

#     EXITS TO ENDOFJOB

# ALARM OR ABORT EXIT MODES-

#     NONE

# OUTPUT-

#     THE FOLLOWING MAY BE FLASHED ON THE DSKY
#        1. IMU ORIENTATION CODE
#        2. ALARM CODE 215 -PREFERRED IMU ORIENTATION NOT SPECIFIED
#        3. TIME OF NEXT IGNITION
#        4. GIMBAL ANGLES
#        5. ALARM CODE 405 -TWO STARS NOT AVAILABLE
#        6. PLEASE PERFORM P00
#     THE MODE DISPLAY MAY BE CHANGED TO 20

# ERASABLE INITIALIZATION REQUIRED-

#     PFRATFLG SHOULD BE SET IF A PREFERRED ORIENTATION HAS BEEN COMPUTED.IF IT HAS BEEN COMPUTED IT IS STORED IN
#     XSMD,YSMD,ZSMD.
#     RNDVZFLG INDICATES WHETHER THE RENDEZVOUS NAVIGATION PROCESS IS OPERATING.

# DEBRIS-

#     WORK AREA
                BANK            33
                SETLOC          P50S
                BANK

                EBANK=          BESTI
                COUNT*          $$/P52
PROG52          TC              BANKCALL
                CADR            R02BOTH                 # IMU STATUS CHECK
                CAF             PFRATBIT
                MASK            FLAGWRD2                # IS PFRATFLG SET?
                CCS             A

                TC              P52A                    # YES
                CAF             BIT2                    # NO
                TC              P52A            +1
P52A            CAF             BIT1
                TS              OPTION2
P52B            CAF             BIT1
                TC              BANKCALL                # FLASH OPTION CODE AND ORIENTATION CODE
                CADR            GOPERF4R                # FLASH V04N06
                TC              GOTOPOOH
                TCF             +5                      # V33-PROCEED
                TC              P52B                    # NEW CODE - NEW ORIENTATION CODE INPUT
                TC              PHASCHNG                # DISPLAY RETURN
                OCT             00014
                TC              ENDOFJOB

                CA              OPTION2
                MASK            THREE
                INDEX           A
                TC              +1
                TC              P52T
                TC              P52J
                TC              P52T
P52E            TC              INTPRET
                GOTO
                                P52F
P52T            EXTEND
                DCA             NEG0
                DXCH            DSPTEM1
                CAF             V06N34*
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              +2
                TC              -5
                CCS             DSPTEM1
                TCF             P52V
                TCF             +2                      # IF TIME ZERO OR NEG USE TIME2
                TCF             +1
                EXTEND
                DCA             TIME2
                DXCH            DSPTEM1
P52V            CA              OPTION2
                MASK            BIT2
                CCS             A
                TC              P52W

LSDISP          CAF             V06N89*                 # DISPLAY LAT,LONG/2, ALT
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH                # VB34 TERMINATE
                TC              +2                      # VB33 PROCEED
                TC              LSDISP                  # VB32 RECYCLE

                TC              INTPRET                 # OPTION 4 - GET LS ORIENTATION
                SET             SET
                                ERADFLAG
                                LUNAFLAG
                DLOAD           CALL
                                DSPTEM1
                                LALOTORV
                VLOAD           UNIT                    # COMPUTE LANDING SITE ORIENT (XSMD)
                                ALPHAV
                STCALL          XSMD
                                LSORIENT
                GOTO
                                P52D

# START ALIGNMENT

P52W            TC              INTPRET
                DLOAD
                                DSPTEM1                 # PICK UP ALIGN TIME
                CALL                                    # COMPUTE NOMINAL IMU
                                S52.3                   #  ORIENTATION
P52D            CALL                                    # READ VEHICLE ATTITUDE AND
                                S52.2                   #  COMPUTE GIMBAL ANGLES
                EXIT
                CAF             V06N22*
                TC              BANKCALL                # DISPLAY GIMBAL ANGLES
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              REGCOARS                # V33-PROCEED, SEE IF GYRO TORQUE COARSE
                TC              INTPRET                 # RECYCLE - VEHICLE HAS BEEN MANUEVERED
                GOTO
                                P52D
REGCOARS        TC              INTPRET
                CALL                                    # DO COARSE ALIGN
                                CAL53A                  #  ROUTINE
                SET             CLEAR
                                REFSMFLG
                                PFRATFLG
P52F            CALL
                                R51
P52OUT          EXIT
                TC              GOTOPOOH
P52J            CAF             PFRATBIT
                MASK            FLAGWRD2
                CCS             A
                TC              P52H

                TC              ALARM
                OCT             215
                CAF             VB05N09
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              -4
                TC              P52B

P52H            TC              INTPRET                 # PREFERRED OPTION, GO COMPUTE GIMBALS
                GOTO
                                P52D

VB05N09         =               V05N09
V06N22*         VN              00622
V06N34*         VN              634

V06N89*         VN              0689

# NAME -S50 ALIAS  LOCSAM
# BY
# VINCENT
# FUNCTION - COMPUTE INPUTS FOR PICAPAR  AND PLANET

#          DEFINE

#
#          U    = UNIT( SUN WRT EARTH)
#           ES

#          U    =UNIT( MOON WRT EARTH)
#           EM

#          R    =POSITION VECTOR OF LEM
#           L

#          R    =MEAN DISTANCE (384402KM) BETWEEN EARTH AND MOON
#           EM

#          P    =RATIO   R   /(DISTANCE SUN TO EARTH)    >.00257125
#                          EM

#          R    =EQUATORIAL RADIUSS (6378.166KM) OF EARTH
#           E

#          LOCSAM  COMPUTES IN EARTH INFLUENCE
#

#      VSUN   =   U
#                  ES

#     VEARTH  =   -UNIT( R  )
#                         L

#     VMOON   =    UNIT(R  .U   - R  )
#                        EM  EM    L

#     CSUN    =   COS 90

#     CEARTH  =    COS(5 + ARCSIN(R /MAG(R )))
#                                  E      L

#     CMOON   =    COS 5

#
# INPUT -  TIME IN MPAC
# OUTPUT - LISTED ABOVE
# SUBROUTINES -LSPOS,LEMPREC
# DEBRIS - VAC AREA ,TSIGHT

                SETLOC          P50S1
                BANK
                EBANK=          XSM

                COUNT*          $$/LOSAM

S50             =               LOCSAM
LOCSAM          STQ
                                QMIN
                STCALL          TSIGHT
                                LSPOS
                DLOAD
                                TSIGHT
                STCALL          TDEC1
                                LEMPREC
                SSP             TIX,2
                                S2
                                0
                                MOONCNTR
EARTCNTR        VLOAD           VXSC
                                VMOON
                                RSUBEM
                VSL1            VSU
                                RATT
                UNIT
                STOVL           VMOON
                                RATT
                UNIT            VCOMP
                STODL           VEARTH
                                RSUBE
                CALL
                                OCCOS
                STODL           CEARTH
                                CSS5
                STCALL          CMOON
                                ENDSAM
MOONCNTR        VLOAD           VXSC
                                VMOON
                                ROE
                BVSU            UNIT
                                VSUN
                STOVL           VSUN
                                VMOON
                VXSC            VAD
                                RSUBEM
                                RATT
                UNIT            VCOMP
                STOVL           VEARTH
                                RATT
                UNIT            VCOMP

                STODL           VMOON
                                RSUBM
                CALL
                                OCCOS
                STODL           CMOON
                                CSS5
                STORE           CEARTH
ENDSAM          DLOAD
                                CSSUN
                STORE           CSUN
                GOTO
                                QMIN
OCCOS           DDV             SR1
                                36D
                ASIN            DAD
                                5DEGREES
                COS             SR1
                RVQ
CEARTH          =               14D
CSUN            =               16D
CMOON           =               18D
CSS5            2DEC            .2490475                # (COS 5)/4
CSSUN           2DEC            .125                    # (COS 60)/4
5DEGREES        2DEC            .013888889              #    SCALED IN REVS

ROE             2DEC            .00257125
RSUBEM          2DEC            384402000       B-29
RSUBM           2DEC            1738090         B-29
RSUBE           2DEC            6378166         B-29

# PROGRAM NAME - R56              DATE  DEC 20 66
# MOD 1                           LOG SECTION P51-P53
#                                 ASSEMBLY  SUNDISK  REV40
# BY KEN VINCENT
#
# FUNCTION
#   THIS PROGRAM READ THE IMU-CDUS AND COMPUTES THE VEHICLE ORIENTATION
# WITH RESPECT TO INERTIAL SPACE. IT THEN COMPUTES THE SHAFT AXIS (SAX)
# WITH RESPECT TO REFERENCE INERTIAL. EACH STAR IN THE CATALOG IS TESTED
# TO DETERMINE IF IT IS OCCULTED BY EITHER THE EARTH,SUN OR MOON. IF A
# STAR IS NOT OCCULTED  THEN IT IS PAIRED WITH ALL STAR OF LOWER INDEX.
# THE PAIRED STAR  IS TESTED FOR OCCULTATION. PAIRS OF STARS THAT PASS
# THE OCCULTATION TESTS ARE TESTED FOR GOOD SEPARATION.A PAIR OF STARS
# HAVE GOOD SEPERATION IF THE ANGLE BETWEEN THEM IS LESS THAN 100 DEGREES
# AND MORE THAN 50 DEGREES. THOSE PAIRS WITH GOOD SEPARATION
# ARE THEN TESTED TO SEE IF THEY LIE IN CURRENT FIELD OF VIEW.(WITHIN
# 50 DEGREESOF SAX).THE PAIR WITH MAX SEPARATION IS CHOSEN FROM
# THOSE WITH GOOD SEPARATION,AND     IN FIELD OF VIEW.
#
# CALLING SEQUENCE
# L        TC     BANKCALL
# L+1      CADR   R56
# L+2      ERROR RETURN - NO STARS IN FIELD OF VIEW
# L+3      NORMAL RETURN
#
# OUTPUT
# BESTI,BESTJ -SINGLE PREC,INTEGERS,STAR NUMBERS TIMES 6
# VFLAG - FLAG BIT  SET IMPLIES NO STARS IN FIELD OF VIEW
#
# INITIALIZATION
# 1)A CALL TO LOCSAM MUST BE MADE
#
# DEBRIS
# WORK AREA
# X,Y,ZNB
# SINCDU,COSCDU
# STARAD - STAR +5
R56             =               PICAPAR
                COUNT*          $$/R56
PICAPAR         TC              MAKECADR
                TS              QMIN
                TC              INTPRET
                CALL
                                CDUTRIG
                CALL
                                CALCSMSC
                SETPD
                                0
                SET             DLOAD                   # VFLAG = 1
                                VFLAG

                                DPZERO
                STOVL           BESTI
                                XNB
                VXSC            PDVL
                                HALFDP
                                ZNB
                AXT,1           VXSC
                                228D                    # X1 = 37 X 6 + 6
                                HALFDP
                VAD
                VXM             UNIT
                                REFSMMAT
                STORE           SAX                     # SAX = SHAFT AXIS
                SSP             SSP                     # S1=S2=6
                                S1
                                6
                                S2
                                6
PIC1            TIX,1           GOTO                    # MAJOR STAR
                                PIC2
                                PICEND
PIC2            VLOAD*          DOT
                                CATLOG,1
                                SAX
                DSU             BMN
                                CSS33
                                PIC1
                LXA,2
                                X1
PIC3            TIX,2           GOTO
                                PIC4
                                PIC1
PIC4            VLOAD*          DOT
                                CATLOG,2
                                SAX
                DSU             BMN
                                CSS33
                                PIC3
                VLOAD*          DOT*
                                CATLOG,1
                                CATLOG,2
                DSU             BPL
                                CSS40
                                PIC3
                VLOAD*          CALL
                                CATLOG,1
                                OCCULT
                BON
                                CULTFLAG
                                PIC1

                VLOAD*          CALL
                                CATLOG,2
                                OCCULT
                BON
                                CULTFLAG
                                PIC3
STRATGY         BONCLR
                                VFLAG
                                NEWPAR
                XCHX,1          XCHX,2
                                BESTI
                                BESTJ
STRAT           VLOAD*          DOT*
                                CATLOG,1
                                CATLOG,2
                PUSH            BOFINV
                                VFLAG
                                STRAT           -3
                DLOAD           DSU
                BPL
                                PIC3
NEWPAR          SXA,1           SXA,2
                                BESTI
                                BESTJ
                GOTO
                                PIC3
OCCULT          MXV             BVSU
                                CULTRIX
                                CSS
                BZE
                                CULTED
                BMN             SIGN
                                CULTED
                                MPAC            +3
                BMN             SIGN
                                CULTED
                                MPAC            +5
                BMN             CLRGO
                                CULTED
                                CULTFLAG
                                QPRET
CULTED          SETGO
                                CULTFLAG
                                QPRET
CSS             =               CEARTH
CSS40           2DEC            .16070                  # COS 50 / 4
CSS33           2DEC            .16070                  #  COS 50 / 4
PICEND          BOFF            EXIT

                                VFLAG
                                PICGXT
                TC              PICBXT
PICGXT          LXA,1           LXA,2
                                BESTI
                                BESTJ
                VLOAD           DOT*
                                SAX
                                CATLOG,1
                PDVL            DOT*
                                SAX
                                CATLOG,2
                DSU
                BPL             SXA,1
                                PICNSWP
                                BESTJ
                SXA,2
                                BESTI
PICNSWP         EXIT
                INCR            QMIN
PICBXT          CA              QMIN
                TC              SWCALL
VPD             =               0D
V0              =               6D
V1              =               12D
V2              =               18D
V3              =               24D
DP0             =               30D
DP1             =               32D

# NAME-R51  FINE ALIGN
# FUNCTION-TO ALIGN THE STABLE MEMBER TO REFSMMAT
# CALLING SEQ- CALL  R51
# INPUT -  REFSMMAT
# OUTPUT- GYRO TORQUE PULSES
# SUBROUTINES -LOCSAM,PICAPAR,R52,R53,R54,R55
                COUNT*          $$/R51
R51             STQ
                                QMAJ
R51.1           EXIT
R51C            CAF             OCT15
                TC              BANKCALL
                CADR            GOPERF1
                TC              GOTOPOOH
                TC              +2                      # V33E
                TC              R51E                    # ENTER
                TC              INTPRET
                RTB             DAD
                                LOADTIME
                                TSIGHT1
                CALL
                                LOCSAM
                EXIT
                TC              BANKCALL
                CADR            R56
                TC              R51I
R51F            TC              R51E
R51I            TC              ALARM
                OCT             405
                CAF             VB05N09
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              R51E
                TC              R51C
R51E            CAF             ZERO
                TS              STARIND
R51.2           TC              INTPRET
R51.3           EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                CALL
                                R52                     # AOP WILL MAKE CALLS TO SIGHTING
                EXIT
                TC              BANKCALL
                CADR            AOTMARK
                TC              BANKCALL
                CADR            OPTSTALL

                TC              CURTAINS
                CCS             STARIND
                TCF             +2
                TC              R51.4
                TC              INTPRET
                VLOAD
                                STARAD          +6
                STORE           STARSAV2
                EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                DLOAD           CALL
                                TSIGHT
                                PLANET
                MXV             UNIT
                                REFSMMAT
                STOVL           STARAD          +6
                                PLANVEC
                MXV             UNIT
                                REFSMMAT
                STOVL           STARAD
                                STARSAV1
                STOVL           6D
                                STARSAV2
                STCALL          12D
                                R54                     # STAR DATA TEST
                BOFF            CALL
                                FREEFLAG
                                R51K
                                AXISGEN
                CALL
                                R55                     # GYRO TORQUE
                CLEAR
                                PFRATFLG
R51K            EXIT
R51P63          CAF             OCT14
                TC              BANKCALL
                CADR            GOPERF1
                TC              GOTOPOOH
                TC              R51C
                TC              INTPRET
                GOTO
                                QMAJ
R51.4           TC              INTPRET
                VLOAD
                                STARAD          +6
                STORE           STARSAV1
                DLOAD           CALL

                                TSIGHT
                                PLANET
                STORE           PLANVEC
                SSP
                                STARIND
                                1
                GOTO
                                R51.3
TSIGHT1         2DEC            36000                   # 6 MIN TO MARKING

# R55  GYRO TORQUE
# FUNCTION-COMPUTE AND SEND GYRO PULSES
# CALLING SEQ- CALL R55
# INPUT- X,Y,ZDC- REFSMMAT WRT PRESENT STABLE MEMBER
# OUTPUT- GYRO PULSES
# SUBROUTINES- CALCGTA,GOFLASH,GODSPR,IMUFINE, IMUPULSE,GOPERF1
                COUNT*          $$/R55
R55             STQ
                                QMIN
                CALL
                                CALCGTA
PULSEM          EXIT
R55.1           CAF             V06N93
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              R55.2
                TC              R55RET
R55.2           TC              PHASCHNG
                OCT             00214
                CA              R55CDR
                TC              BANKCALL
                CADR            IMUPULSE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                TC              PHASCHNG
                OCT             05024
                OCT             13000
R55RET          TC              INTPRET
                GOTO
                                QMIN
V06N93          VN              0693
R55CDR          ECADR           OGC
R54             =               CHKSDATA
# ROUTINE NAME- CHKSDATA                                                                 DATE- JAN 9, 1967
# MOD NO- 0                                                                              LOG SECTION- P51-P53
# MODIFICATION BY- LONSKE                                                                ASSEMBLY-

# FUNCTIONAL DESCRIPTION - CHECKS THE VALIDITY OF A PAIR OF STAR SIGHTINGS. WHEN A PAIR OF STAR SIGHTINGS ARE MADE
# BY THE ASTRONAUT THIS ROUTINE OPERATES AND CHECKS THE OBSERVED SIGHTINGS AGAINST STORED STAR VECTORS IN THE
# COMPUTER TO INSURE A PROPER SIGHTING WAS MADE. THE FOLLOWING COMPUTATIONS ARE PERFORMED_

#                 OS1 = OBSERVED STAR 1 VECTOR
#                 OS2 = OBSERVED STAR 2 VECTOR
#                 SS1 = STORED STAR 1 VECTOR
#                 SS2 = STORED STAR 2 VECTOR
#                 A1  = ARCCOS(OS1 - OS2)
#                 A2  = ARCCOS(SS1 - SS2)
#                 A   = ABS(2(A1 - A2))

# THE ANGULAR DIFFERENCE IS DISPLAYED FOR ASTRONAUT ACCEPTENCE
# EXIT MODE 1. FREEFLAG SET  IMPLIES  ASTRONAUT WANTS TO PROCEED
#           2. FREEFLAG RESET IMPLIES ASTRONAUT WANTS TO RECYCLE          ERANCE)
# OUTPUT - 1.VERB 6,NOUN 3- DISPLAYS ANGULAR DIFFERENCE BETWEEN 2 SETS OF STARS.
#          2.STAR VECTORS FROM STAR CATALOG ARE LEFT IN 6D AND 12D.

# ERASABLE INITIALIZATION REQUIRED -
#          1.MARK VECTORS ARE STORED IN STARAD AND STARAD +6.
#          2.CATALOG VECTORS ARE STORED IN 6D AND 12D.
# DEBRIS -
                COUNT*          $$/R54
CHKSDATA        STQ             SET
                                QMIN
                                FREEFLAG
CHKSAB          AXC,1                                   # SET X1 TO STORE EPHEMERIS DATA
                                STARAD

CHKSB           VLOAD*          DOT*                    # CAL. ANGLE THETA
                                0,1
                                6,1
                SL1             ACOS
                STORE           THETA
                BOFF            INVERT                  # BRANCH TO CHKSD IF THIS IS 2ND PASS
                                FREEFLAG
                                CHKSD
                                FREEFLAG                # CLEAR FREEFLAG
                AXC,1           DLOAD                   # SET X1 TO MARK ANGLES
                                6D
                                THETA
                STORE           18D
                GOTO
                                CHKSB                   # RETURN TO CAL. 2ND ANGLE
CHKSD           DLOAD           DSU
                                THETA
                                18D
                ABS             RTB                     # COMPUTE POS DIFF
                                SGNAGREE
                STORE           NORMTEM1
                SET             EXIT
                                FREEFLAG
                CAF             VB6N5
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH
                TC              CHKSDA                  # PROCEED
                TC              INTPRET
                CLEAR           GOTO
                                FREEFLAG
                                QMIN
CHKSDA          TC              INTPRET

                GOTO
                                QMIN
VB6N5           VN              605
# NAME - CAL53A
# FUNCTION -COMPUTE DESIRED GIMBAL ANGLES AND COARSE ALIGN IF NECESSARY
# CALLING SEQUENCE - CALL CAL53A
# INPUT - X,Y,ZSMD ,CDUX,Y,Z
#         DESIRED GIMBAL ANGLES - THETAD,+1,+2
# OUTPUT - THE IMU COORDINATES ARE STORED IN REFSMMAT
# SUBROUTINES - S52.2, IMUCOARSE , IMUFINE
                COUNT*          $$/R50
CAL53A          STQ             CALL
                                29D
                                S52.2                   # MAKE ONE FINAL COMP OF GIMBLE ANGLES
                RTB             SSP
                                RDCDUS                  # READ CDUS
                                S1
                                1
                AXT,1           SETPD
                                3
                                4
CALOOP          DLOAD*          SR1
                                THETAD          +3D,1
                PDDL*           SR1
                                4,1
                DSU             ABS
                PUSH            DSU
                                DEGREE1
                BMN             DLOAD
                                CALOOP1
                DSU             BPL
                                DEG359
                                CALOOP1
COARFINE        CALL
                                COARSE
                CALL
                                NCOARSE
                GOTO
                                FINEONLY
CALOOP1         TIX,1
                                CALOOP
FINEONLY        AXC,1           AXC,2
                                XSM
                                REFSMMAT
                CALL
                                MATMOVE
                GOTO
                                29D
MATMOVE         VLOAD*                                  # TRANSFER MATRIX
                                0,1

                STORE           0,2
                VLOAD*
                                6D,1
                STORE           6D,2
                VLOAD*
                                12D,1
                STORE           12D,2
                RVQ
DEGREE1         DEC             46                      # 1 DEG SCALED CDU/2
DEG359          DEC             16338                   # 359 DEG SCALED CDU/2
RDCDUS          INHINT                                  # READ CDUS
                CA              CDUX
                INDEX           FIXLOC
                TS              1
                CA              CDUY
                INDEX           FIXLOC
                TS              2
                CA              CDUZ
                INDEX           FIXLOC
                TS              3
                RELINT
                TC              DANZIG                  #                                       +
                COUNT*          $$/INFLT
CALCSMSC        AXC,1
                                XNB

XNBNDX          DLOAD           DMP
                                SINCDUY
                                COSCDUZ
                DCOMP
                PDDL            SR1
                                SINCDUZ
                PDDL            DMP
                                COSCDUY
                                COSCDUZ
                VDEF            VSL1
                STORE           0,1
                DLOAD           DMP
                                SINCDUX
                                SINCDUZ
                SL1
                STORE           26D
                DMP
                                SINCDUY
                PDDL            DMP
                                COSCDUX
                                COSCDUY
                DSU
                PDDL            DMP
                                SINCDUX

                                COSCDUZ
                DCOMP
                PDDL            DMP
                                COSCDUX
                                SINCDUY
                PDDL            DMP
                                COSCDUY
                                26D
                DAD             VDEF
                VSL1
                STORE           14,1
                VXV*            VSL1
                                0,1
                STORE           6,1
                RVQ

# NAME - P51 - IMU ORIENTATION DETERMINATION
#          MOD.NO.1  23 JAN 67                                                             LOG SECTION - P51-P53
# MOD BY STURLAUGSON                                                                      ASSEMBLY SUNDANCE REV56

# FUNCTIONAL DESCRIPTION

#      DETERMINES THE INERTIAL ORIENTATION OF THE IMU. THE PROGRAM IS SELECTED BY DSKY ENTRY. THE SIGHTING
# (AOTMARK)ROUTINE IS CALLED TO COLLECT AND PROCESS MARKED-STAR DATA. AOTMARK(R53) RETURNS THE STAR NUMBER AND THE
# STAR LOS VECTOR IN STARAD+6. TWO STARS ARE THUS SIGHTED. THE ANGLE BETWEEN THE TWO STARS IS THEN CHECKED AT
# CHKSDATA(R54). REFSMMAT IS THEN COMPUTED AT AXISGEN.

# CALLING SEQUENCE

#   THE PROGRAM IS CALLED BY THE ASTRONAUT BY DSKY ENTRY.

# SUBROUTINES CALLED.

#      GOPERF3
#      GOPERF1
#      GODSPR
#      IMUCOARS
#      IMUFIN20
#      AOTMARK(R53)
#      CHKSDATA(R54)
#      MKRELEAS
#      AXISGEN
#      MATMOVE

# ALARMS

#      NONE.

# ERASABLE INITIALIZATION

#      IMU ZERO FLAG SHOULD BE SET.

# OUTPUT

#      REFSMMAT
#      REFSMFLG

# DEBRIS

#      WORK AREA
#      STARAD
#      STARIND
#      BESTI
#      BESTJ

                COUNT*          $$/P51
P51             TC              BANKCALL                # IS ISS ON - IF NOT, IMUCHK WILL SEND
                CADR            IMUCHK                  # ALARM CODE 210 AND EXIT VIA GOTOPOOH.

                CAF             PRFMSTAQ
                TC              BANKCALL
                CADR            GOPERF1
                TC              GOTOPOOH                # TERM.
                TCF             P51B                    # V33
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                CAF             P51ZERO
                TS              THETAD                  # ZERO THE GIMBALS
                TS              THETAD          +1
                TS              THETAD          +2
                CAF             V6N22
                TC              BANKCALL
                CADR            GODSPRET
                CAF             V41K                    # NOW DISPLAY COARSE ALIGN VERB 41
                TC              BANKCALL
                CADR            GODSPRET
                TC              INTPRET
                CALL
                                COARSE
                EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TCF             P51 +2

P51B            TC              PHASCHNG
                OCT             00014
                TC              INTPRET
                CALL
                                NCOARSE
                SSP             SETPD
                                STARIND                 # INDEX-STAR 1 OR 2
                                0
                                0
P51C            EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              BANKCALL
                CADR            AOTMARK                 # R53
                TC              BANKCALL
                CADR            AOTSTALL
                TC              CURTAINS
                CCS             STARIND
                TCF             P51D            +1

                TC              INTPRET
                VLOAD
                                STARAD          +6
                STORE           STARSAV1
P51D            EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                CCS             STARIND
                TCF             P51E
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                DLOAD           CALL
                                TSIGHT
                                PLANET
                STORE           PLANVEC
                EXIT
                CAF             BIT1
                TS              STARIND
                TCF             P51C            +1      # DO SECOND STAR
P51E            TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                DLOAD           CALL
                                TSIGHT
                                PLANET
                STOVL           12D
                                PLANVEC
                STOVL           6D
                                STARSAV1
                STOVL           STARAD
                                STARSAV2
                STCALL          STARAD          +6
                                CHKSDATA                # CHECK STAR ANGLES IN STARAD AND
                BON             EXIT
                                FREEFLAG
                                P51G
                TC              P51             +2
P51G            CALL
                                AXISGEN                 # COME BACK WITH REFSMMAT IN XDC
                AXC,1           AXC,2
                                XDC
                                REFSMMAT
                CALL
                                MATMOVE
                SET
                                REFSMFLG

                EXIT
                TC              GOTOPOOH                # FINIS
PRFMSTAQ        =               OCT15
P51ZERO         =               ZERO
P51FIVE         =               FIVE
V6N22           VN              0622
V41K            VN              4100
COARSE          EXIT
                TC              BANKCALL
                CADR            IMUCOARS
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                TC              BANKCALL
                CADR            IMUFINE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                TC              INTPRET
                RVQ
NCOARSE         EXIT
                CA              TIME1
                TS              1/PIPADT
                TC              INTPRET
                VLOAD
                                ZEROVEC
                STORE           GCOMP
                SET             RVQ
                                DRIFTFLG

# NAME-S52.2
# FUNCTION-COMPUTE GIMBAL ANGLES FOR DESIRED SM AND PRESENT VEHICLE
# CALL-  CALL  S52.2
# INPUT- X,Y,ZSMD
# OUTPUT- OGC,IGC,MGC,THETAD,+1,+2
# SUBROUTINES-CDUTRIG,CALCSMSC,MATMOVE,CALCGA
                COUNT*          $$/S52.1
S52.2           STQ
                                QMAJ
                CALL
                                CDUTRIG
                CALL
                                CALCSMSC
                AXT,1           SSP
                                18D
                                S1
                                6D
S52.2A          VLOAD*          VXM
                                XNB             +18D,1
                                REFSMMAT
                UNIT
                STORE           XNB             +18D,1
                TIX,1
                                S52.2A
S52.2.1         AXC,1           AXC,2
                                XSMD
                                XSM
                CALL
                                MATMOVE
                CALL
                                CALCGA
                GOTO
                                QMAJ

# NAME-S52.3
# FUNCTION  XSMD= UNIT R
#           YSMD= UNIT(V X R)
#           ZSMD= UNIT(XSMD X YSMD)
# CALL     DLOAD  CALL
#                 TALIGN
#                 S52.3
# INPUT-   TIME OF ALIGNMENT IN MPAC
# OUTPUT-  X,Y,ZSMD
# SUBROUTINES- CSMCONIC
                COUNT*          $$/S52.3
S52.3           STQ
                                QMAJ
                STCALL          TDEC1
                                LEMCONIC
                SETPD
                                0
                VLOAD           UNIT
                                RATT
                STOVL           XSMD
                                VATT
                VXV             UNIT
                                RATT
                STOVL           YSMD
                                XSMD
                VXV             UNIT
                                YSMD
                STCALL          ZSMD
                                QMAJ

# NAME    -R52 (AUTOMATIC OPTICS POSITIONING ROUTINE)

# FUNCTION-POINT THE AOT OPTIC AXIS BY MANEUVERING THE LEM TO A NAVIGATION
#          STAR SELECTED BY ALIGNMENT PROGRAMS OR DSKY INPUT

# CALLING -CALL R52

# INPUT   -BESTI AND BESTJ (STAR CODES TIMES 6)
# OUTPUT  -STAR CODE IN BITS1-6, DETENT CODE IN BITS 7-9
#          (NO CHECK IS MADE TO INSURE THE DETENT  CODE TO BE VALID)
#          POINTVSM-1/2 UNIT NAV STAR VEC IN SM
#          SCAXIS-AOT OPTIC AXIS VEC IN NB X-Z PLANE

# SUBROUT -R60LEM

                COUNT*          $$/R52
R52             STQ             EXIT
                                SAVQR52
                INDEX           STARIND
                CA              BESTI                   # PICK UP STARCODE DETERMINED BY R56
                EXTEND
                MP              1/6TH
                AD              BIT8                    # SET DETENT POSITION 2
                TS              STARCODE                # SCALE AND STORE IN STARCODE

R52A            CAF             V01N70
                TC              BANKCALL
                CADR            GOFLASH                 # DISPLAY STARCODE AND WAIT FOR RESPONSE
                TC              GOTOPOOH                # V34-TERMINATE
                TCF             R52B                    # V33-PROCEED TO ORIENT LEM
                TCF             R52A                    # ENTER-SELECT NEW STARCODE-RECYCLE

R52B            TC              DOWNFLAG
                ADRES           3AXISFLG                # BIT6 OF FLAGWRD5 ZERO TO ALLOW VECPOINT
                CA              STARCODE                # GRAB DETENT CODE
                MASK            HIGH9
                EXTEND
                BZMF            R52A                    # DONT ALLOW ZERO CODE-RECYCLE
                MASK            BIT9                    # SEE IF CODE 4 OR 5
                CCS             A
                TCF             GETAZEL                 # CODE 4 OR 5-GET CALIBRATION AZ EL
                EBANK=          XYMARK
                CA              EBANK7
                TS              EBANK
                CAF             HIGH9                   # FORWARD DETENT, INDEX DETENT AND GRAB
                MASK            STARCODE                # AZIMUTH  ANGLE AND ELV = 45 DEG
                EXTEND
                MP              BIT9                    # SHIFT DETENT TO BITS1-2 FOR INDEX
                INDEX           A
                CA              AOTAZ           -1      # PICK UP AZ CORRESPONDING TO DETENT

                TS              L
                EBANK=          XSM
                CA              EBANK5                  # CHANGE TO EBANK5 BUT DONT DISTURB L
                TS              EBANK
                CA              BIT13                   # SET ELV TO 45 DEG
                XCH             L                       # SET C(A)=AZ, C(L)=45 DEG
                TCF             AZEL                    # GO COMP OPTIC AXIS

GETAZEL         CAF             V06N87                  # CODE 4 OR 5-GET AZ AND EL FROM ASTRO
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH                # V34-TERMINATE
                TCF             +2                      # PROCEED-CALC OPTIC AXIS
                TCF             GETAZEL                 # ENTER-RECYCLE

                EXTEND
                DCA             AZ                      # PICK UP AZ AND EL IN SP 2S COMP
AZEL            INDEX           FIXLOC                  # JAM AZ AND EL IN 8 AND 9 OF VAC
                DXCH            8D
                TC              INTPRET
                CALL                                    # GO COMPUTE OPTIC AXIS AND STORE IN
                                OANB                    # SCAXIS IN NB COORDS
                RTB             CALL
                                LOADTIME
                                PLANET
                MXV             UNIT
                                REFSMMAT
                STORE           POINTVSM                # STORE FOR VECPOINT

                EXIT
                TC              BANKCALL
                CADR            R60LEM                  # GO TORQUE LEM OPTIC AXIS TO STAR LOS

                TC              INTPRET                 # RETURN FROM KALCMANU
                GOTO
                                SAVQR52                 # RETURN TO CALLER

1/6TH           DEC             .1666667
V01N70          VN              0170
V06N87          VN              687

# NAME -    PLANET
# FUNCTION -TO PROVIDE THE REFERENCE VECTOR FOR THE SIGHTED CELESTIAL
#           BODY. STARS ARE FETCHED FROM THE CATALOG,SUN,EARTH AND
#           MOON ARE COMPUTED BY LOCSAM,PLANET VECTORS ARE ENTERED
#           BY DSDY INPUT
# CALL  -  CALL
#                 PLANET
# INPUT -  TIME IN MPAC
# OUTPUT - VECTOR  IN MPAC
# SUBROUTINES - LOCSAM
# DEBRIS - VAC ,STARAD - STARAD +17

                SETLOC          P50S
                BANK
                COUNT*          $$/P51

PLANET          STORE           TSIGHT
                STQ             EXIT
                                GCTR
                CS              HIGH9
                MASK            AOTCODE
                EXTEND
                MP              REVCNT
                XCH             L
                INDEX           STARIND
                TS              BESTI
                CCS             A
                TCF             NOTPLAN
                CAF             VNPLANV
                TC              BANKCALL
                CADR            GOFLASH
                TC              -3
                TC              +2
                TC              -5
                TC              INTPRET
                VLOAD           UNIT
                                STARAD
                GOTO
                                GCTR
NOTPLAN         CS              A
                AD              DEC227
                EXTEND
                BZMF            CALSAM1
                INDEX           STARIND
                CA              BESTI
                INDEX           FIXLOC
                TS              X1
                TC              INTPRET
                VLOAD*          GOTO
                                CATLOG,1

                                GCTR
CALSAM1         TC              INTPRET
CALSAM          DLOAD           CALL
                                TSIGHT
                                LOCSAM
                LXC,1           VLOAD
                                STARIND
                                VEARTH
                STOVL           0D
                                VSUN
                STOVL           VEARTH
                                0D
                STORE           VSUN
                DLOAD*          LXC,1
                                BESTI,1
                                MPAC
                VLOAD*          GOTO
                                STARAD          -228D,1
                                GCTR
DEC227          DEC             227
VNPLANV         VN              0688
PIPSRINE        =               PIPASR          +3      # EBANK NOT 4 SO DONT LOAD PIPTIME1

# GRAVITY VECTOR DETERMINATION ROUTINE
# BY KEN VINCENT
# FOR DETAILED DESCRIPTION SEE 504GSOP 5.6.3.2.5
# THIS PROGRAM FINDS THE DIRECTION OF THE MOONS GRAVITY
# WHILE THE LM IS ON THE MOONS SURFACE. IT WILL BE USED
# FOR LUNAR SURFACE ALIGNMENT. THE GRAVITY VECTOR IS
# DETERMINED BY READING THE PIPAS WITH THE IMU AT TWO
# PARTICULAR ORIONTATIONS. THE TWO READINGS ARE AVERAGED
# AND UNITIZED AND TRANSFORMED TO NB COORDINATES. THE TWO
# ORIENTATION WERE CHOSEN TO REDUCE BIAS ERRORS IN THE
# READINGS.
#
# CALL-
#          TC     BANKCALL
#          CADR   GVDETER
# INPUTS-
#          PIPAS,CDUS
# OUTPUTS-
#          STARSAV1 = UNIT GRAVITY
#          GSAV     =   DITTO
#          GRAVBIT  = 1
# SUBROUTINES-
#          PIPASR,IMUCOARS,IMUFINE,IMUSTALL,1/PIPA,DELAYJOB,CDUTRIG,
#          *NBSM* ,*SNMB*, CALCGA,FOFLASH
# DEBRIS-
#          VAC,SAC,STARAD,XSM,XNB,THETAD,DELV,COSCDU,SINCDU
GVDETER         CS              BIT3                    # JAM 45 DEG IN DESIRED GIMBAL ANGLES
                TS              THETAD          +1
                COM
                TS              THETAD          +2
                TS              THETAD
                TC              INTPRET
                CLEAR           CALL
                                REFSMFLG
                                LUNG
# FIND  GIMBAL ANGLES WHICH ROTATE SM 180DEG  ABOUT  G VEC
#
#  DEFINE G COOR SYS
#                      -
#                      X    UNIT G
#                  *   -               -
#                  M=  Y =  UNITEZSM * X )
#                      -         -     -
#                      Z    UNIT(X   * Y )
#  THEN   ROTATED  SM WRT  PRESENT IS
#
#
#                     1,  0 , 0
#           *      *T            *          *         *
#          XSM =   M  0, -1 , 0  M  = 2  (X X ) - 1/2 I  *

#                                          I J
#                     0,  0 ,-1
#
#  ALSO   NB WRT PRES SM  IS
#
#                *      *   *
#               XNB = NBSM  I
#                            *     *
#  GIMBAL ANGLES  = CALCGA( XSM , XNB )

                SETLOC          P50S
                BANK
                COUNT*          $$/P57
                AXT,1           SSP                     # X1=18
                                18D                     # S1= 6
                                S1                      # X2, -2
                                6D
                LXC,2
                                S1
GRAVEL          VLOAD*          CALL
                                XUNIT           -6,2
                                *NBSM*                  # SIN AND COS COMPUTED IN LUNG
                STORE           XNB             +18D,1
                VLOAD
                                STAR
                LXC,2           VXSC*                   # COMPLEMENT- UNITX  ARE BACKWARD -
                                X2
                                STAR            +6,2    # OUTER PRODUCT
                VSL2            LXC,2
                                X2
                VSU*            INCR,2
                                XUNIT           -6,2
                                2D
                STORE           XSM             +18D,1
                TIX,1           CALL
                                GRAVEL
                                CALCGA
                VLOAD           VSR1
                                GOUT
                STCALL          STARAD          +12D
                                LUNG
                VLOAD           VSR1
                                GOUT
                VAD             UNIT
                                STARAD          +12D
                STORE           STARSAV1
                DOT
                                GSAV
                SL1             ACOS
                STORE           DSPTEM1

                EXIT

                CA              DISGRVER
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              PROGRAV                 # VB33-PROCEED
                TC              -5                      # VB32-RECYCLE

PROGRAV         TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                VLOAD
                                STARSAV1
                STORE           GSAV
                EXIT
                TC              P57OPT3

LUNG            STQ             VLOAD
                                QMIN
                                ZEROVEC
                STORE           GACC
                EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              BANKCALL
                CADR            IMUCOARS
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                TC              BANKCALL
                CADR            IMUFINE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                CA              T/2SEC
                TS              GCTR
                CA              PRIO31
                TS              1/PIPADT
                TC              BANKCALL
                CADR            GCOMPZER                # INITIALIZE COMPENSATION

                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              BANKCALL                #  DONT NEED TO INHINY  THIS USED TO
                CADR            PIPSRINE                # INITIALIZE PIPAS  DONT USE DATA

GREED           EXIT                                    # = MASK 7776 IN BASIC SO DONT CARE
                CAF             2SECS
                TC              BANKCALL                # SET UP 2 SEC TASK TO READ PIPAS
                CADR            DELAYJOB

                INCR            GCTR
                INHINT
                TC              BANKCALL
                CADR            PIPSRINE
                RELINT
                TC              BANKCALL
                CADR            1/PIPA
                TC              INTPRET
                VLOAD           VAD
                                DELV
                                GACC
                STORE           GACC                    # ACCUMULATE G VECTOR
                SLOAD           BMN
                                GCTR
                                GREED
                VLOAD           UNIT
                                GACC
                STCALL          STAR
                                CDUTRIG                 # TRANSFORM IN NB COOR  AND  STORE
                CALL                                    #  IN OUTPUT
                                *SMNB*
                STORE           GOUT
                EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                GOTO
                                QMIN
T/2SEC          DEC             -22
DISGRVER        VN              0605

# NAME  GYROTRIM
#
# THIS PROGRAM COMPUTES AND SENDS GYRO COMMANDS WHICH CAUSE THE CDUS
#   TO ATTAIN A PRESCRIBED SET OF ANGLES. THIS ROUTINE ASSUMES THE
#   VEHICLES ATTITUDE REMAINS STATIONARY DURING ITS OPERATION.
#
# CALL     CALL
#                 GYROTRIM
#
# INPUT    THETAD,+1,+2 = DESIRED CDU ANGLES
#          CDUX,CDUY,CDUZ
#
# OUTPUT - GYRO TORQUE PULSES
#
# SUBROUTINES- TRG*NBSM,*NBSM*,CDUTRIG,AXISGEN,CALCGTA,IMUFINE
#              IMPULSE,IMUSTALL
#            -         -        -        *           *     -
# DEBRIS -  CDUSPOT ,SINCDU ,COSCDU , STARAD ,VAC , XDC , OGC
                COUNT*          $$/P57
GYROTRIM        STQ             DLOAD
                                QMIN
                                THETAD
                PDDL            PDDL
                                THETAD          +2
                                THETAD          +1
                VDEF
                STOVL           CDUSPOT
                                XUNIT
                CALL
                                TRG*NBSM
                STOVL           STARAD
                                YUNIT
                CALL
                                *NBSM*
                STCALL          STARAD          +6
                                CDUTRIG
                CALL
                                CALCSMSC
                VLOAD
                                XNB
                STOVL           6D
                                YNB
                STCALL          12D
                                AXISGEN
                CALL
                                CALCGTA
                EXIT
JUSTTRIM        TC              BANKCALL
                CADR            IMUFINE
                TC              BANKCALL

                CADR            IMUSTALL
                TC              CURTAINS
                CA              GYRCDR
                TC              BANKCALL
                CADR            IMUPULSE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                TC              INTPRET
                GOTO
                                QMIN
GYRCDR          ECADR           OGC

V16N20          VN              1620
V06N05*         VN              0605
V06N23          VN              0623
V06N20          VN              0620

# PERFORM STAR AQUISITION AND STAR SIGHTINGS

2STARS          CAF             BIT1                    # INITALIZE STARIND
                TC              +2                      # ONE FOR 1ST STAR, ZERO FOR 2ND STAR
1STAR           CAF             ZERO
                TS              STARIND

                TC              BANKCALL                # GO TO AOTMARK FOR SIGHTING
                CADR            AOTMARK
                TC              BANKCALL
                CADR            AOTSTALL                # SLEEP TILL SIGHTING DONE
                TC              CURTAINS                # BADEND RETURN FROM AOTMARK

                CS              HIGH9                   # GRAB STARCODE FOR INDEX
                MASK            AOTCODE
                EXTEND
                MP              REVCNT                  # JUST 6
                INDEX           FIXLOC
                TS              X1                      # CODE X 6 FOR CATLOG STAR INDEX
                INDEX           STARIND
                TS              BESTI

                CCS             STARIND
                TC              ASTAR
                TC              INTPRET
                VLOAD*
                                CATLOG,1
                STOVL           VEC2                    # STORE 2ND CATALOG VEC (REF)
                                STARAD          +6
                STORE           STARSAV2                # 2ND STAR IN SM
                EXIT

                TC              SURFLINE

ASTAR           TC              INTPRET
                VLOAD*
                                CATLOG,1
                STOVL           VEC1
                                STARAD          +6
                STORE           STARSAV1                # 1ST OBSERVED STAR (SM)
                EXIT
                TC              1STAR                   # GO GET 2ND STAR SIGHTING

# DO FINE OR COARSE ALIGNMENT OF IMU

SURFLINE        CAF             ZERO
                TS              STARIND
                TC              INTPRET
                SSP             AXT,2
                                S2
                                6
                                12D
WRTDESIR        VLOAD*          RTB
                                VEC1            +12D,2  # PICK UP VEC IN REF, TRANS TO DESIRED SH
                                UPDATFRF
                BON
                                FREEFLAG
                                MFREF
WRTDSBAK        MXV             UNIT
                                XSMD
                STORE           STARAD          +12D,2  # VEC IN SM
                TIX,2
                                WRTDESIR
                AXT,2
                                12D
WRTDESR2        VLOAD*          RTB
                                STARSAV1 +12D,2
                                UPDATFRF
                BON
                                FREEFLAG
                                CALCANG
DOALIGN         STORE           18D,2
                TIX,2           CALL
                                WRTDESR2
                                R54                     # DO CHKSDATA
                CALL
                                AXISGEN
                CALL
                                CALCGTA
5DEGTEST        VLOAD           BOV                     # IF ANGLES GREATER THAN 5 DEGS, DO COARSE
                                OGC
                                SURFSUP
SURFSUP         STORE           OGCT
                V/SC            BOV
                                5DEGREES
                                COATRIM
                SSP             GOTO
                                QMIN
                                SURFDISP
                                JUSTTRIM                # ANGLES LESS THAN 5 DEG, DO GYRO TORQ

SURFDISP        EXIT
                TC              PHASCHNG
                OCT             05024                   # STORE REFSMMAT ,SET REFSMFLG   AND
                OCT             13000                   # DISPLAY ORIGINAL  TORQ ANGLES
                TC              INTPRET
                AXC,1           AXC,2
                                XSMD
                                REFSMMAT
                SET             CALL
                                REFSMFLG
                                MATMOVE
                SETPD           CALL
                                0D
                                CDUTRIG
                AXT,2           CALL
                                12D
                                CALCSMSC
REFMF           VLOAD*          VXM
                                STARAD,2
                                REFSMMAT
                UNIT
                PUSH            RTB
                                LOADTIME
                PUSH            CALL
                                R-TO-RP
                SSP
                                S2
                                6
                STORE           STARVSAV,2
                TIX,2           VLOAD
                                REFMF
                                OGCT
                STORE           OGC
                EXIT

                CAF             DISPGYRO                # DISPLAY GYRO TORQ ANGLES V 06N93
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH                # V34-TERMINATE
                TC              GOTOPOOH                # VB33-PROCEED TO COARSE OR FINE
                CS              OPTION1                 # VB32-RECYCLE, MAYBE RE-ALIGN
                MASK            BIT2
                CCS             A
                TC              GOTOPOOH                # IF OPTION ZERO DO FINISHH
                CA              OPTION1
                MASK            BIT1
                CCS             A
                TC              1STAR
                TC              2STARS

# COARSE AND FINE ALIGN IMU
COATRIM         AXC,1           AXC,2
                                XDC
                                XSM
                CALL
                                MATMOVE
                CALL
                                CDUTRIG
                CALL
                                CALCSMSC
                CALL
                                CALCGA
                CALL
                                COARSE
                CALL
                                GYROTRIM
                GOTO
                                SURFDISP

UPDATFRF        CS              FREEFBIT
                MASK            FLAGWRD0
                TS              FLAGWRD0
                
                CAF             REFSMBIT
                MASK            FLAGWRD3
                CCS             A
                CAF             BIT3
                AD              OPTION1
                INDEX           A
                CAF             BIT8
                INDEX           STARIND
                MASK            FREEFTAB
                CCS             A
                TC              +4
                CAF             FREEFBIT
                AD              FLAGWRD0
                TS              FLAGWRD0

                INCR            STARIND
                TCF             DANZIG

FREEFTAB        OCT             00052
                OCT             00077
                OCT             00042
                OCT             00063

MFREF           SETPD           PUSH
                                0
                RTB             PUSH
                                LOADTIME
                CALL
                                RP-TO-R
                GOTO
                                WRTDSBAK

CALCANG         CALL
                                CDUTRIG
                CALL
                                *NBSM*
                GOTO
                                DOALIGN

DISPGYRO        VN              0693

# LUNAR SURFACE IMU ALIGNMENT PROGRAM

P57             TC              BANKCALL                # IS ISS ON - IF NOT, IMUCHK WILL SEND
                CADR            IMUCHK                  # ALARM CODE 210 AND EXIT VIA GOTOPOOH.

                TC              INTPRET
                DLOAD           BOFF
                                ZEROVEC                 # LOAD ZERO FOR DISPLAY IF ASCNTFLG IS
                                ASCNTFLG                # NOT SET
                                P57A
                DLOAD
                                TIG                     # LOAD ASCENT TIME FOR DISPLAY
P57A            STORE           DSPTEM1
                EXIT
P57AA           CAF             V06N34                  # DISPLAY TALIGN, TALIGN : DSPTEM1
                TC              BANKCALL
                CADR            GOFLASH
                TC              P57AA                   # V34-TERMINATE
                TC              +2                      # V33-PROCEED
                TC              P57AA                   # VB32-RECYCLE

                TC              INTPRET
                DLOAD           BHIZ
                                DSPTEM1
                                P57B
                GOTO
                                P57D
P57B            RTB
                                LOADTIME                # LOAD CURRENT TIME
                STORE           DSPTEM1
P57D            STCALL          TDEC1
                                LEMPREC                 # COMPUTE DESIRED IMU ORIENTATION STORE
                VLOAD           UNIT                    # IN  X,Y,ZSMD
                                RATT
                STCALL          XSMD
                                LSORIENT
PACKOPTN        AXT,1           BOFF                    # PACK FLAG BITS FOR OPTION DISPLAY
                                0
                                REFSMFLG                # REFSMFLG
                                +3                      # CLEAR-JUST ZERO
                INCR,1                                  # SET
                                100
                BOFF            INCR,1
                                ATTFLAG                 # ATTFLG
                                +2                      # CLEAR-JUST ZERO
                                10                      # SET
                BOFF            INCR,1
                                ASCNTFLG                # ASCNTFLG
                                +2                      # CLEAR-JUST ZERO
                                1                       # SET
                SXA,1           EXIT
                                OPTION1         +1

                CAF             ZERO
                TS              OPTION1                 # JAM 00000 IN OPTION1 FOR CHECK LIST

DSPOPTN         CAF             VB04N06                 # DISPLAY OPTION CODE AND FLAG BITS
                TC              BANKCALL
                CADR            GOFLASH
                TC              DSPOPTN                 # VB34-TERMINATE
                TC              +2                      # V33-PROCEED
                TC              DSPOPTN                 # V32-RECYCLE

                TC              PHASCHNG
                OCT             05024
                OCT             13000
                CA              OPTION1                 # SEE IF OPTION 2 OR 3
                MASK            BIT2
                CCS             A
                TC              BYLMATT

                TC              INTPRET
                BON             BON
                                REFSMFLG
                                GETLMATT                # SET, GO COMPUTE LM ATTITUDE
                                ATTFLAG                 # CLEAR-CHECK ATTFLAG FOR STORED ATTITUDE.
                                P57OPT0                 # ALLFLG SET
                EXIT
BADOPTN         CAF             BADOPT
                TC              BANKCALL
                CADR            PRIOLARM
                TC              BADOPTN
                TC              BADOPTN
                TC              DSPOPTN
                TC              ENDOFJOB

# BRANCH TO ALIGNMENT OPTION

GETLMATT        CALL
                                CDUTRIG                 # GET SIN AND COS OF CDUS
                CALL
                                CALCSMSC                # GET YNB IN SM
                VLOAD           VXM
                                YNB
                                REFSMMAT                #  YNB TO REF
                UNIT
                STOVL           YNBSAV
                                ZNB
                VXM             UNIT
                                REFSMMAT                # ZNB TO REF
                STORE           ZNBSAV

P57OPT0         VLOAD
                                YNBSAV                  # Y ATTITUDE VEC
                STOVL           VEC1
                                ZNBSAV                  # Z ATTITUDE VEC
                STOVL           VEC2
                                YUNIT
                STOVL           STARSAV1
                                ZUNIT
                STORE           STARSAV2
                EXIT
                CS              OPTION1
                MASK            BIT1                    # SEE IF OPTION 1 OR 3
                CCS             A
                TC              SURFLINE

BYLMATT         CS              OPTION1                 # SEE IF OPTION 1 OR 3
                MASK            BIT1
                CCS             A
                TC              2STARS
                TC              GVDETER

# OPTION 3, GET LANDING SITE VEC AND ONE STAR SIGHTING

P57OPT3         TC              INTPRET
                VLOAD           VCOMP
                                RLS                     # LANDING SITE VEC
                UNIT
                STORE           VEC1
                EXIT
                CA              OPTION1
                MASK            BIT2
                TC              1STAR
                TC              SURFLINE

BADOPT          OCT             00701                   # **** TEMP ****
VB04N06         VN              406
V06N34          VN              634

# CHECK IMODES30 TO VARIFY IMU IS ON

IMUCHK          CS              IMODES30
                MASK            BIT9
                CCS             A                       # IS IMU ON
                TCF             +4                      # YES

                TC              ALARM                   # NO, SEND ALARM AND EXIT
                OCT             210
                TC              GOTOPOOH

                TC              UPFLAG
                ADRES           IMUSE                   # SET IMUSE FLAG

                TC              SWRETURN

LSORIENT        STQ             DLOAD
                                QMAJ
                                DSPTEM1
                STCALL          TDEC1
                                CSMPREC
                VLOAD           VXV
                                0D
                                6D
                VXV             UNIT
                                XSMD
                STORE           ZSMD
                VXV             UNIT
                                XSMD
                STCALL          YSMD
                                QMAJ
