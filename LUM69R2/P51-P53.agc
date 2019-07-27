### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P51-P53.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 925-978
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 925
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

## Page 926
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

## Page 927
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
                TC              P52H
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
                DXCH            DSPTEM1
                EXTEND
                BZMF            +2                      # IF TIME ZERO OR NEG USE TIME2
                TCF             +3
                EXTEND
                DCA             TIME2
                DXCH            TALIGN
P52V            CA              OPTION2
                MASK            BIT2
                CCS             A
                TC              P52W
                TC              INTPRET                 # OPTION 4 - GET LS ORIENTATION
                GOTO
                                P52LS

## Page 928
# START ALIGNMENT

P52W            TC              INTPRET
                DLOAD
                                TALIGN                  # PICK UP ALIGN TIME
                CALL                                    # COMPUTE NOMINAL IMU
                                S52.3                   #  ORIENTATION
P52D            CALL                                    # READ VEHICLE ATTITUDE AND
                                S52.2                   #  COMPUTE GIMBAL ANGLES
                EXIT
                CAF             V06N22*
                TC              BANKCALL                # DISPLAY GIMBAL ANGLES
                CADR            GOFLASH
                TC              GOTOPOOH
                TCF             COARSTYP                # V33-PROCEED, SEE IF GYRO TORQUE COARSE
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
P52H            TC              INTPRET                 # PREFERRED OPTION, GO COMPUTE GIMBALS
                GOTO
                                P52D

VB05N09         =               V05N09
V06N22*         VN              00622
V06N34*         VN              634

V06N89*         VN              0689

## Page 929
# CHECK FOR GRRO TORQUE COARSE ALIGNMENT
COARSTYP        CAF             OCT13
                TC              BANKCALL                # DISPLAY V 50N25 WITH COARSE ALIGN OPTION
                CADR            GOPERF1
                TCF             GOTOPOOH                # V34-TERMIN&OE
                TCF             REGCOARS                # V33-NORMAL COARSE
                TC              INTPRET                 # V32-GYRO TORQUE COARSE
                VLOAD           MXV
                                XSMD                    # GET SM(DESIRED) WRT SM(PRESENT)
                                REFSMMAT
                UNIT
                STOVL           XDC
                                YSMD
                MXV             UNIT
                                REFSMMAT
                STOVL           YDC
                                ZSMD
                MXV             UNIT
                                REFSMMAT
                STCALL          ZDC
                                GYCOARS
                GOTO
                                P52OUT
OCT13           OCT             13

## Page 930
# COMPUTE LANDING ORIENTATION FOR OPTION 4
P52LS           SET             CLEAR                   # GET LANDING SITE ORIENTATION
                                LUNAFLAG
                                ERADFLAG                # TO PICK UP RLS
                SETPD           VLOAD
                                0
                                RLS                     # PICK UP LANDING SITE VEC IN MF
                PDDL            PUSH                    # RLS PD 0-5
                                TALIGN
                CALL
                                RP-TO-R                 # TRANS RLS TO REF
                VSR2
                STODL           ALPHAV                  # INPUT TO LAT-LONG
                                TALIGN
                CALL
                                LAT-LONG                # GET LAT, LONG, AND ALT
                DLOAD           SR1                     # RESCALE LONG TO DEGREES/2
                                LONG
                STODL           LANDLONG
                                ALT
                STODL           LANDALT                 # ALT ALREADY AT 2(29) METERS
                                LAT
                STORE           LANDLAT
                EXIT

LSDISP          CAF             V06N89*                 # DISPLAY LAT,LONG/2, ALT
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH                # VB34 TERMINATE
                TCF             +2                      # VB33 PROCEED
                TCF             LSDISP                  # VB32 RECYCLE

                TC              INTPRET
                DLOAD           SL1
                                LANDLONG
                STODL           LONG
                                LANDALT
                STODL           ALT
                                LANDLAT
                STODL           LAT
                                TALIGN
                CALL
                                LALOTORV
                VLOAD           UNIT                    # COMPUTE LANDING SITE ORIENT (XSMD)
                                ALPHAV
                STCALL          XSMD
                                LSORIENT
                GOTO
                                P52D                    # NOW GO COMPUTE GIMBAL ANGLES

## Page 931
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

## Page 932
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

## Page 933
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

## Page 934
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

## Page 935
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

## Page 936
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

## Page 937
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

## Page 938
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

## Page 939
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

## Page 940
                                TSIGHT
                                PLANET
                STORE           PLANVEC
                SSP
                                STARIND
                                1
                GOTO
                                R51.3
TSIGHT1         2DEC            36000                   # 6 MIN TO MARKING

## Page 941
# GYRO TORQUE COARSE ALIGNMENT
GYCOARS         STQ             CALL
                                QMAJ
                                CALCGTA
                CLEAR           CLEAR
                                DRIFTFLG
                                REFSMFLG
                EXIT
                CAF             V16N20                  # MONITOR GIMBALS
                TC              BANKCALL
                CADR            GODSPR
                CA              R55CDR
                TC              BANKCALL
                CADR            IMUPULSE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              CURTAINS
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                AXC,1           AXC,2
                                XSMD
                                REFSMMAT
                CALL                                    # STORE DESIRED REFSMMAT
                                MATMOVE
                CLEAR           SET
                                PFRATFLG
                                REFSMFLG
                CALL
                                NCOARSE                 # SET DRIFT AND INITIALIZE 1/PIPADT
                GOTO
                                R51K
V16N20          VN              1620

## Page 942
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

## Page 943
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

## Page 944
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

## Page 945
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
                TC              DANZIG			#					+
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

## Page 946
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

## Page 947
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
## Page 948
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

## Page 949
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

## Page 950
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

## Page 951
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

## Page 952
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

## Page 953
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

## Page 954
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

## Page 955
# LUNAR SURFACE STAR AQUISITION

                BANK            15
                SETLOC          P50S
                BANK
                COUNT*          $$/R59

R59             CS              FLAGWRD3
                MASK            REFSMBIT                # IF REFSMMAT FLAG CLEAR BYPASS STAR AQUIR
                CCS             A
                TCF             R59OUT                  # NO REFSMMAT GO TO AOTMARK

                CAF             V01N70*                 # SELECT STAR CODE FOR ACQUISITION
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH                # V34-TERMINATE
                TCF             R59A                    # V33-PROCEED
                TCF             R59                     # V32-RECYCLE

R59A            CS              HIGH9                   # GRAB STARCODE FOR INDEX
                MASK            AOTCODE
                EXTEND
                MP              REVCNT                  # JUST 6
                XCH             L
                INDEX           STARIND
                TS              BESTI
                INDEX           FIXLOC
                TS              X1                      # CODE X 6 FOR CATLOG STAR INDEX
                EXTEND
                BZF             R59OUT                  # BYPASS AQUISITION IF NOT CATLOG STAR
                COM
                AD              DEC227
                EXTEND
                BZMF            R59OUT

                TC              INTPRET
                CALL
                                CDUTRIG                 # GET CDU JAZZ FOR SMNB
                VLOAD*          MXV
                                CATLOG,1                # GRAB STAR VECTOR
                                REFSMMAT                # TRANSFORM TO SM
                UNIT            CALL
                                *SMNB*			# TRANSFORM TO NB
                STORE           STAR                    # TEMP STORE STAR VEC(NB)
                EXIT

                CAF             BIT1                    # INITIALIZE POS TO ONE
                TS              POSCODE
                CS              DEG60                   # AS(N) TO -60 DEG
                TS              QMIN

## Page 956


STORPOS         TS              A                       # DETECT OVF AZ = -120
                TCF             +3                      # NO OVF
                CAF             BIT15                   # OVF SKIP-ADD NEGMAX TO OVF CORRECT QMIN
                ADS             QMIN
                CAF             BIT13                   # ELV=45 DEG
                TS              L
                CA              QMIN
                INDEX           FIXLOC
                DXCH            8D                      # JAM AZ IN 8D, 45 DEG IN 9D FOR OANB

                TC              INTPRET
                CALL
                                OANB                    # GO CALC OPTIC AXIS WRT NB
                VLOAD           DOT
                                STAR                    # DOT STAR WITH OA
                                SCAXIS
                SL1             ARCCOS
                STORE           24D                     # TEMP STORE ARCCOS(STAR.OPTAXIS)

                DSU             BPL
                                DEG30                   # SEE IF STAR IN AOT FIELD-OF-VIEW
                                NXAX                    # NOT IN FIELD - TRY NEXT POSITION
                DLOAD           DSU                     # SEE IF STAR AT FIELD CENTER
                                24D
                                DEG.5
                BMN             DLOAD                   # CALC SPIRAL AND CURSOR
                                ZSPCR                   # GO ZERO CURSOR AND SPIRAL
                                24D                     # GET SPIRAL
                DMP             SL4
                                3/4                     # 12 SCALED AT 16
                STOVL           24D                     # 12(ARCCOS(AO.STAR)) SCALED IN REVS

                                SCAXIS                  # OA
                VXV             UNIT
                                XUNIT
                PUSH            VXV                     #  OA X UNITX   PD 0-5
                                SCAXIS
                VCOMP
                UNIT            PDVL                    # UNIT(OA X(OA X UNITX))  PD 6-11
                                SCAXIS
                VXV             UNIT
                                STAR
                PUSH            DOT                     # 1/2(OA X STAR)   PD 12-17
                                0                       # DOT WITH 1/2(OA X UNITX)  FOR YROT
                SL1             ARCCOS
                STOVL           26D                     # STORE THET SCALED IN REVS

                DOT                                     # UP 12-17, UP 6-11 FOR C2
                BPL             DLOAD                   # IF THET NEG-GET 360-THET
                                R59D

## Page 957
                                ABOUTONE
                DSU
                                26D
                STORE           26D                     # 360-THET SCALED IN REVS

R59D            SLOAD           SR1
                                QMIN                    # RESCALE AZ(N) TO REVS
                DAD             PUSH                    # PUSH YROT + AZ(N) REVS
                                26D
                RTB
                                1STO2S
                STODL           CURSOR                  # YROT IN 1/2 REVS
                                24D                     # LOAD SROT IN REVS
                DAD                                     # 12(SEP) + YROT
                RTB
                                1STO2S
                STORE           SPIRAL                  # SROT IN 1/2 REVS
                EXIT
                TCF             79DISP                  # GO DISPLAY CURSOR-SPIRAL-POS CODE

ZSPCR           EXIT
                CAF             ZERO                    # STAR ALMOST OPTIC AXIS,ZERO CURSOR
                TS              CURSOR                  # AND SPIRAL ANGLES
                TS              SPIRAL
                TCF             79DISP

NXAX            EXIT
                INCR            POSCODE
                CS              POSCODE
                AD              SEVEN
                EXTEND
                BZMF            R59ALM                  # THIS STAR NOT AT ANY POSITION
                CAF             DEG60                   # ADVANCE AZ(N) BY 60 DEG
                ADS             QMIN                    # IF OVF, QMIN CONTAINS OVF CORRECTED
                TCF             STORPOS
R59ALM          TC              ALARM                   # THIS STAR CANT BE LOCATED IN AOT FIELD
                OCT             404
                CAF             VB05N09                 # DISPLAY ALARM
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH                # VB34-TERMINATE
                TCF             R59OUT                  # VB33-PROCEED, GO WITHOUT AQUIRE
                TCF             R59                     # VB32-RECYCLE AND TRY ANOTHER STAR

79DISP          CAF             V06N79                  # DISPLAY CURSOR, SPIRAL AND POS CODE
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH                # V34-TERMINATE
                TCF             R59E                    # V33-PROCEED TO MARK ROUTINE
                TCF             R59                     # V32-RECYCLE TO TOP OF R59 AGAIN

## Page 958
R59E            CAF             BIT3                    # GET DETENT CORRESPONDING TO POSITION COD
                MASK            POSCODE                 # KEYED IN POS CODE
                EXTEND
                BZF             +2                      # FORWARD DETENT
                TCF             +3                      # ITS REAR DETENT, 4 ALREADY IN (A)
                CAF             SEVEN                   # GET FORWARD DETENT
                MASK            POSCODE
                EXTEND
                MP              BIT7
                XCH             L
                TS              QMIN
                CS              HIGH9
                MASK            AOTCODE
                AD              QMIN
                TS              AOTCODE                 # STORE DETENT IN 7-9

R59OUT          TC              BANKCALL                # GO TO AOTMARK FOR SIGHTING
                CADR            AOTMARK
                TC              BANKCALL
                CADR            AOTSTALL                # SLEEP TILL SIGHTING DONE
                TC              CURTAINS                # BADEND RETURN FROM AOTMARK
                TCF             R59RET                  # RETURN TO 1 STAR OR 2STAR

V01N70*         VN              170
V06N79          VN              679
DEG30           2DEC            .083333333              # 30 DEGRESS
DEG.5           2DEC            .00138888               # .5 DEGRESS SCALED IN REVS
DEG60           OCT             12525                   # 60 DEG CDU SCALING
CURSOR          EQUALS          DSPTEM1
SPIRAL          EQUALS          DSPTEM1         +1
POSCODE         EQUALS          DSPTEM2         +2

## Page 959
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

## Page 960
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

## Page 961
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
GVDETER         CS              BIT13			# JAM 45 DEG IN DESIRED GIMBAL ANGLES
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

## Page 962
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

## Page 963
                EXIT
                TC              DOWNFLAG                # CLEAR FREEFLAG IN CASE OF RECYCLE
                ADRES           FREEFLAG

                CA              DISGRVER
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TCF             PROGRAV                 # VB33-PROCEED
                TC              UPFLAG                  # VB32-RECYCLE-STORE GRAV AND DO IT AGAIN
                ADRES           FREEFLAG                # AND SET FREEFLAG TO SHOW RECYCLE

PROGRAV         TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              INTPRET
                VLOAD
                                STARSAV1
                STORE           GSAV
                EXIT
                CAF             FREEFBIT                # IF FREEFLAG SET, RE-COMPUTE GRAVITY.
                MASK            FLAGWRD0
                CCS             A
                TCF             GVDETER                 # SET
                TCF             ATTCHK                  # EXIT FROM GVDETER

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

## Page 964
                TC              PHASCHNG
                OCT             05024
                OCT             13000
                TC              BANKCALL                #  DONT NEED TO INHINY  THIS USED TO
                CADR            PIPSRINE                # INITIALIZE PIPAS  DONT USE DATA
                TC              INTPRET
GREED           EXIT                                    # = MASK 7776 IN BASIC SO DONT CARE
                CAF             2SECS
                TC              TWIDDLE                 # SET UP 2 SEC TASK TO READ PIPAS
                ADRES           GRABGRAV

                TC              ENDOFJOB

GRABGRAV        TC              IBNKCALL
                CADR            PIPSRINE
                CAF             PRIO13                  # RE-ESTABLISH MAINLINE JOB
                TC              FINDVAC
                EBANK=          STARAD
                2CADR           ADDGRAV

                TC              TASKOVER

ADDGRAV         TC              BANKCALL
                CADR            1/PIPA
                INCR            GCTR
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
DISGRVER        VN              0604

## Page 965
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
JUSTTRIM        EXIT
                TC              BANKCALL
                CADR            IMUFINE
                TC              BANKCALL

## Page 966
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

## Page 967
# PERFORM STAR AQUISITION AND STAR SIGHTINGS

2STARS          CAF             ZERO                    # INITALIZE STARIND
                TCF             +2                      # ZERO FOR 1ST STAR, ONE FOR 2ND STAR
1STAR           CAF             BIT1
                TS              STARIND

                TC              PHASCHNG
                OCT             04024

                TCF             R59                     # GO DO STAR AQUIRE AND AOTMARK

R59RET          CA              STARIND                 # BACK FROM SURFACE MARKING
                EXTEND
                BZF             ASTAR                   # 1ST STAR MARKED

                TC              INTPRET                 # 2ND STAR MARKED
                VLOAD
                                STARAD          +6
                STORE           STARSAV2                # 2ND STAR IN SM

                EXIT
                TC              PHASCHNG
                OCT             05024
                OCT             13000

                TC              INTPRET
                DLOAD           CALL
                                TSIGHT                  # TIME OF 2ND MARK
                                PLANET
                STCALL          VEC2                    # STORE 2ND CATALOG VEC (REF)
                                SURFLINE

ASTAR           TC              INTPRET
                VLOAD
                                STARAD          +6
                STORE           STARSAV1                # 1ST OBSERVED STAR (SM)
                DLOAD           CALL
                                TSIGHT                  # TIME OF 1ST MARK
                                PLANET
                STORE           VEC1                    # STORE 1ST CATALOG VEC (REF)
                EXIT
                TCF             1STAR                   # GO GET 2ND STAR SIGHTING

## Page 968
# DO FINE OR COARSE ALIGNMENT OF IMU

SURFLINE        SSP             AXT,2
                                S2
                                6
                                12D
WRTDESIR        VLOAD*          MXV
                                VEC1            +12D,2  # PICK UP VEC IN REF, TRANS TO DESIRED SH
                                XSMD
                UNIT
                STORE           STARAD          +12D,2  # VEC IN SM
                VLOAD*
                                STARSAV1        +12D,2  # PICK UP VEC IN PRESENT SM
                STORE           18D,2
                TIX,2           BON
                                WRTDESIR
                                INITALGN                # IF INITIAL PASS (OPTION 0) BYPASS R54
                                INITBY
DOALIGN         CALL
                                R54                     # DO CHKSDATA
                BOFF
                                FREEFLAG
                                P57POST                 # ASTRO DOES NOT LIKE DATA TEST RESULTS
INITBY          CALL
                                AXISGEN                 # GET DESIRED ORIENT WRT PRES.XDC,YDC,ZDC
                CALL
                                CALCGTA                 # GET GYRO TORQ ANGLES, OGC,IGC,MGC
                EXIT
                CAF             INITABIT                # IF INITIAL PASS BYPASS NOUN 93 DISPLAY
                MASK            FLAGWRD8
                CCS             A
                TCF             5DEGTEST
                CAF             DISPGYRO                # DISPLAY GYRO TORQ ANGLES V 06N93
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH                # V34-TERMINATE
                TCF             5DEGTEST                # VB33-PROCEED TO COARSE OR FINE
                TCF             P57POST         +1      # VB32-RECYCLE, MAYBE RE-ALIGN

5DEGTEST        TC              INTPRET                 # IF ANGLES GREATER THAN 5 DEGS, DO COARSE
                VLOAD           BOV
                                OGC
                                SURFSUP
SURFSUP         STORE           OGCT
                V/SC            BOV
                                5DEGREES
                                COATRIM
                SSP             GOTO
                                QMIN
                                SURFDISP

## Page 969
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
                EXIT
                CCS             OPTION2                 # IF OPTION ZERO DO FINISH
                TCF             B2F8
                TCF             P57POST         +1

B2F8            CAF             INITABIT                # IF INITIAL FLAG SET, RE-CYCLE.
                MASK            FLAGWRD8
                CCS             A
                TCF             P57JUMP                 # ITS SET
                TC              INTPRET
                CALL
                                REFMF                   # GO GET ATTITUDE VEC IN MF(YNBSAV,XNBSAV)
P57POST         EXIT
                CAF             OCT14                   # DISPLAY V50N25 CHK CODE 14
                TC              BANKCALL
                CADR            GOPERF1
                TCF             GOTOPOOH                # VB34-TERMINATE
                TCF             P57JUMP                 # VB33-PROCEED TO RE-ALIGN
                TCF             GOTOPOOH                # VB32-R59 DONE-GO TO PROG 00

## Page 970
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
                                NCOARSE
                CALL
                                GYROTRIM
                GOTO
                                SURFDISP
DISPGYRO        VN              0693

## Page 971
# LUNAR SURFACE IMU ALIGNMENT PROGRAM

P57             TC              BANKCALL                # IS ISS ON - IF NOT, IMUCHK WILL SEND
                CADR            IMUCHK                  # ALARM CODE 210 AND EXIT VIA GOTOPOOH.

                TC              INTPRET
                DLOAD
                                TIG                     # LOAD ASCENT TIME FOR DISPLAY
P57A            STORE           DSPTEM1
                EXIT
P57AA           CAF             V06N34*                 # DISPLAY TALIGN, TALIGN : DSPTEM1
                TC              BANKCALL
                CADR            GOFLASHR
                TCF             GOTOPOOH                # V34-TERMINATE
                TCF             +5
                TCF             P57AA                   # VB32-RECYCLE

                TC              PHASCHNG
                OCT             00014
                TC              ENDOFJOB

                TC              INTPRET
                DLOAD           BMN
                                DSPTEM1
                                PACKOPTN        -1      # NEG TIME-PREF ORIENT IN XSMD MATRIX
                RTB             PDDL
                                LOADTIME                # PUSH CURRENT TIME AND PICK UP KEY IN
                                DSPTEM1
                BZE             PDDL
                                P57C                    # IF KEY IN TIME ZERO-TALIGN=CURRENT TIME
                DSU             BPL                     # NOT ZERO SO EXCHANGE PD WITH DSPTEM1
                                DSPTEM1
                                P57C
                DLOAD           STADR                   # IF KEYIN TIME GREATER THAN CURRENT TIME
                STORE           TIG                     # STORE IT IN TIG
                STCALL          TALIGN
                                P57D
P57C            DLOAD           STADR
                STORE           TALIGN
P57D            STCALL          TDEC1
                                LEMPREC                 # COMPUTE DESIRED IMU ORIENTATION STORE
                VLOAD           UNIT                    # IN  X,Y,ZSMD
                                RATT
                STCALL          XSMD
                                LSORIENT
                EXIT
PACKOPTN        CAF             ZERO                    # PACK FLAG BITS FOR OPTION DISPLAY
                TS              OPTION1         +1      # JAM ZERO IN ALIGNMENT OPTION
                TS              OPTION1         +2      # INITIALIZE FLAG BIT CONFIGURATION
                CAF             REFSMBIT

## Page 972
                MASK            FLAGWRD3                # REFSMFLG
                CCS             A
                CAF             BIT7                    # SET
                ADS             OPTION1         +2      # CLEAR-JUST ZERO
                CAF             ATTFLBIT
                MASK            FLAGWRD6                # ATTFLG
                CCS             A
                CAF             BIT4                    # SET
                ADS             OPTION1         +2      # CLEAR-ZERO IN A
                CAF             BIT4
                TS              OPTION1                 # JAM 00010 IN OPTION1 FOR CHECK LIST

DSPOPTN         CAF             VB05N06                 # DISPLAY OPTION CODE AND FLAG BITS
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH                # VB34-TERMINATE
                TCF             +2                      # V33-PROCEED
                TCF             DSPOPTN                 # V32-RECYCLE

                TC              PHASCHNG
                OCT             05024
                OCT             13000
                CAF             REFSMBIT
                MASK            FLAGWRD3
                CCS             A
                TCF             GETLMATT                # SET, GO COMPUTE LM ATTITUDE
                CAF             ATTFLBIT                # CLEAR-CHECK ATTFLAG FOR STORED ATTITUDE.
                MASK            FLAGWRD6
                CCS             A
                TCF             BYLMATT                 # ALLFLG SET, CHK OPTION FOR GRAVITY COMP
                CAF             BIT2                    # SEE IF OPTION 2 OR 3
                MASK            OPTION2
                CCS             A
                TCF             BYLMATT                 # OPTION 2 OR 3 BUT DONT HAVE ATTITUDE
                TC              ALARM                   # OPTION INCONSISTANT WITH FLAGS-ALARM 701
                OCT             701
                CAF             VB05N09                 # DISPLAY ALARM FOR ACTION
                TC              BANKCALL
                CADR            GOFLASH
                TCF             GOTOPOOH                # VB34-TERMINATE
                TCF             DSPOPTN                 # V33-PROCEED   ********TEMPORARY
                TCF             DSPOPTN                 # VB32-RECYCLE TO OPTION DISPLAY V 05N06

## Page 973
# TRANSFORM VEC1,2 FROM MOON FIXED TO REF AND JAM BACK IN VEC1,2

MFREF           STQ             SETPD
                                QMAJ
                                0
                RTB
                                LOADTIME
                STOVL           TSIGHT
                                VEC1
                PDDL            PUSH
                                TSIGHT
                CALL
                                RP-TO-R
                STOVL           VEC1
                                VEC2
                SETPD           PDDL
                                0
                                TSIGHT
                PUSH            CALL
                                RP-TO-R
                STCALL          VEC2
                                QMAJ

## Page 974
# COMPUTE LM ATTITUDE IN MOON FIXED COORDINATES USING REFSMMAT AND
# STORE IN YNBSAV AND ZNBSAV

REFMF           STQ             CALL
                                QMAJ
                                CDUTRIG                 # GET SIN AND COS OF CDUS
                RTB             SETPD
                                LOADTIME
                                0
                STCALL          TSIGHT
                                CALCSMSC                # GET YNB IN SM
                VLOAD           VXM
                                YNB
                                REFSMMAT                #  YNB TO REF
                UNIT            PDDL
                                TSIGHT
                PUSH            CALL
                                R-TO-RP
                STOVL           YNBSAV                  # YNB TO MF
                                ZNB
                VXM             UNIT
                                REFSMMAT                # ZNB TO REF
                PDDL            PUSH
                                TSIGHT
                CALL
                                R-TO-RP                 # ZNB TO MF
                STORE           ZNBSAV
                SETGO
                                ATTFLAG
                                QMAJ

## Page 975
# BRANCH TO ALIGNMENT OPTION

GETLMATT        TC              INTPRET
                CALL
                                REFMF                   # GO TRANSFORM TO MF IN YNBSAV,ZNBSAV
                EXIT

BYLMATT         TC              UPFLAG                  # SET INITIAL ALIGN FLAG
                ADRES           INITALGN
                CAF             BIT1
                MASK            OPTION2                 # SEE IF OPTION 1 OR 3
                CCS             A
                TCF             GVDETER                 # OPTION 1 OR 2, GET GRAVITY

ATTCHK          TC              PHASCHNG
                OCT             04024

                CAF             ATTFLBIT                # NOT 1 OR 3, CHECK ATTFLAG
                MASK            FLAGWRD6
                CCS             A
                TCF             P57OPT0                 # GET ALIGNMENT VECS FOR OPTION 0
P57JUMP         TC              PHASCHNG
                OCT             04024

                TC              DOWNFLAG                # ATTFLG CLEAR-RESET INTALIGN FLAG
                ADRES           INITALGN
                CAF             THREE
                MASK            OPTION2                 # BRANCH ON OPTION CODE
                INDEX           A
                TCF             +1
                TCF             P57OPT0                 # OPTION IS 0
                TCF             P57OPT1                 # OPTION IS 1
                TCF             P57OPT2                 # OPTION IS 2
                TCF             P57OPT3                 # OPTION IS 3

## Page 976
# OPTION 0, GET TWO ATTITUDE VECS

P57OPT0         TC              INTPRET
                VLOAD
                                YNBSAV                  # Y AND Z ATTITUDE WILL BE PUT IN REF
                STOVL           VEC1
                                ZNBSAV
                STCALL          VEC2
                                CDUTRIG
                CALL
                                CALCSMSC                # COMPUTE SC AXIS WRT PRESENT SM
                VLOAD
                                YNB
SAMETYP         STOVL           STARSAV1                # Y SC AXIS WRT PRESENT SM
                                ZNB
                STCALL          STARSAV2                # Z SC AXIS WRT PRESENT SM
                                MFREF                   # TRANSFORM VEC1,2 FROM MF TO REF
                GOTO
                                SURFLINE

# OPTION 1, GET LANDING SITE AND Z-ATTITUDE VEC

P57OPT1         TC              INTPRET
                VLOAD           UNIT
                                RLS                     # LANDING SITE VEC
                STOVL           VEC1
                                ZNBSAV                  # Z ATTITUDE VEC
                STCALL          VEC2
                                CDUTRIG
                CALL
                                CALCSMSC                # GET ZNB AXIS WRT PRES SM FOR STARSAV2
                VLOAD           CALL
                                GSAV                    # TRANS GSAV FROM NB TO SM FOR STARSAV1
                                CDU*NBSM
                GOTO
                                SAMETYP                 # NOW DO SAME AS OPTION 0

## Page 977
# OPTION 2, GET TWO STAR SIGHTINGS

P57OPT2         TCF             2STARS                  # DO SIGHTING ON 2 STARS

# OPTION 3, GET LANDING SITE VEC AND ONE STAR SIGHTING

P57OPT3         TC              INTPRET
                VLOAD           UNIT
                                RLS                     # LANDING SITE VEC
                STORE           VEC1
                STOVL           VEC2                    # DUMMY VEC2 FOR 2ND CATALOG STAR
                                GSAV                    # GRAVITY VEC NB
                CALL
                                CDU*NBSM                # TRANS GSAV FROM NB TO SM FOR STARSAV1
                STCALL          STARSAV1
                                MFREF                   # STARSAV2 IS STORED AS 2ND OBSERVED STAR
                EXIT
                TCF             1STAR                   # 1STAR GET VEC2,STARSAV2,GOES TO SURFLINE

BADOPT          OCT             00701                   # **** TEMP ****
VB05N06         VN              506

## Page 978
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

LSORIENT        STQ             VLOAD
                                QMAJ
                                RRECTCSM
                VXV             VXV
                                VRECTCSM
                                XSMD
                UNIT
                STORE           ZSMD
                VXV             UNIT
                                XSMD
                STCALL          YSMD
                                QMAJ
