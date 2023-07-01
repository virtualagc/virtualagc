### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_PERFORMANCE_TESTS_1.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-30 MAS  Created from Aurora 12.
##              2023-07-12 MAS  Updated for Aurora 88.


                BANK    14
                EBANK=  XSM



AOTNBIMU        CAF     ONE             # AOT-NB-IMU FINE ALIGNMENT TEST
                TS      EROPTN          # ... TEST CAPABILITY ...

                TC      BANKCALL
                CADR    IMUZERO         # IMU ZERO ENCODER MODE
                TC      INTPRET
                CALL
                        LATAZCHK        # TO LOAD AZIMUTH (SM) AND LATITUDE
                CALL
                        MAKEXSMD        # TO SET UP A STABLE MEMBER DESIRED MATRIX
                SET     CALL
                        COAROFIN        # FOR COARSE OR FINE ALIGN MARKS
                        ERTHRVSE        # TO CALCULATE EARTH RATE VECTOR
                EXIT

POSLOAD         CAF     V24N30E         # R1  0000X ENTER     POSITION 1,2, OR 3
                TC      NVSBWAIT        # R2  00000 ENTER     00001 FOR LAB OPTION
                TC      ENDIDLE
                TCF     ENDTEST
                TCF     -4
                XCH     DSPTEM1         # DO NOT USE POSITION 3 WITH NAV BASE AT
                TS      POSITON         #    ZERO DEGREE TILT ANGLE. (GIMBAL LOCK)

                CCS     DSPTEM1 +1
                TCF     LEMLAB          # SPECIAL LAB TEST TO BYPASS MARKS

                TC      POSNJUMP        # SET UP STABLE MEMBER DESIRED COORDINATES

                TC      OPTDATA         # TARGETS 1,2 AZIMUTH AND ELEVATION

                TC      FINDNAVB        # COARSE ALIGN MARKS

                TC      BANKCALL
                CADR    IMUSTALL        # INSURE IMUZERO COMPLETION
                TCF     ENDTEST

                TC      PUTPOSX         # TO COARSE ALIGN STABLE MEMBER

                TC      GMLCKCHK        # CHECK FOR GIMBAL LOCK BEFORE FINE ALIGN
                TC      OGCZERO         # FOR EARTH RATE COMPENSATION

                TC      BANKCALL
                CADR    IMUFINE         # FINE ALIGN MODE
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST

                TC      FINDNAVB        # FINE ALIGN MARKS

                TC      FREEDSP         # FREE DISPLAY SYSTEM

                TC      SMDCALC         # TO FINE ALIGN STABLE MEMBER

ERFINAL         TC      BANKCALL        # LAST EARTH RATE SHOT
                CADR    EARTHR
                CCS     EROPTN          # IF DESIRED TO COMPENSATE CONTINUALLY
                TCF     MONSTART        #     CHANGE BY V21 N02 E XXXXX E 00000 E
                TCF     ERFINAL
                TCF     ENDTEST
                TS      EROPTN
                INHINT
                CAF     PRIO21          # PRIORITY 1 HIGHER THAN SXTNBIMU
                TC      FINDVAC
                2CADR   RDR37511
                RELINT
                TC      ERFINAL

MONSTART        TC      FINETIME        # TIME AT INITIAL MISALIGNMENT
                DXCH    MPAC
                RELINT
                CAF     ZERO            # ZERO PIPA COUNTERS
                TS      PIPAX
                TS      PIPAY
                TS      PIPAZ
                TS      STOREPL
                TS      NDXCTR
                TC      STORRSLT        # STORE T(INITIAL) AND PIPAI = 0

                INHINT
                CAF     60SEC           # INSURE PIPAI VARIES IN ONE DIRECTION
                TC      WAITLIST
                2CADR   PIP1

                CAF     PIP2ADR
                TC      JOBSLEEP

PIP1            CAF     PIP2ADR
                TC      JOBWAKE
                TC      TASKOVER

PIP2            CAE     PIPNDX
                TS      PIPINDEX        # POS1 PIPAY     POS2 PIPAX     POS3 PIPAX
                TC      BANKCALL
                CADR    CHECKG          # SYNC ON PIPA PULSE

                RELINT

                TC      STORRSLT        # STORE TIME AND PIPAI

                CAE     PIPNDX +1
                TS      PIPINDEX        # POS1 PIPAZ    POS2 PIPAY    POS3 PIPAZ
                TC      BANKCALL
                CADR    CHECKG          # SYNC ON PIPA PULSE

                RELINT
                TC      STORRSLT        # STORE TIME AND PIPAI

                INHINT
                CAF     30SEC           # MONITOR PIPAS AT 30 SECOND INTERVALS
                TC      WAITLIST
                2CADR   PIP1
                CAF     PIP2ADR
                TC      JOBSLEEP
PIP2ADR         CADR    PIP2

FINDNAVB        EXTEND                  # MARKS * CALC NB OR SM WRT EARTH REF
                QXCH    QPLACE

                CCS     LOTSFLAG
                TCF     +2
                TCF     +3
                TC      BANKCALL
                CADR    LOTMARKB

                TC      BANKCALL
                CADR    MKRELEAS        # RELEASE MARK SYSTEM
                CAF     ONE
                TS      DSPTEM1
                CAF     V01N30E         # DISPLAY 00001 IN R1
                TC      NVSBWAIT
                CAF     ZERO            # TO INDICATE GROUND MARKS
                TC      BANKCALL
                CADR    AOTMARK         # MARK ON TARGET 1

                TC      BANKCALL
                CADR    OPTSTALL        # INSURE SUCCESSFUL MARK
                TCF     ENDTEST
                EXTEND
                INDEX   MARKSTAT
                DCA     0
                DXCH    TMARK           # TIME(PRES) FOR EARTH RATE COMPENSATION

                TC      GIMANGS1

                TC      INTPRET
                LXC,1   CALL
                        MARKSTAT        # BASE ADDRESS VAC AREA FOR AOTNB
                        AOTNB           # OPTICS TO NAV BASE COORDINATE FRAME
                BON     CALL
                        COAROFIN        # COARSE MARKS = 0    FINE MARKS = 1
                        +2
                        NBSM            # NAV BASE DIRECT TO STABLE MEMBER
                STORE   STARAD          # TARGET 1 WRT NAV BASE OR STABLE MEMBER
                STORE   LOS1            # ...FOR K...
                EXIT

                TC      BANKCALL
                CADR    MKRELEAS        # RELEASE MARK SYSTEM
                CAF     TWO
                TS      DSPTEM1
                CAF     V01N30E         # DISPLAY 00002 IN R1
                TC      NVSBWAIT
                CAF     ZERO            # TO INDICATE GROUND MARKS
                TC      BANKCALL
                CADR    AOTMARK         # MARK ON TARGET 2

                CAF     BIT10
                MASK    STATE           # BIT10 = COAROFIN
                CCS     A
                TCF     EARRTCOM +5     # IF COARSE ALIGN MARKS

EARRTCOM        TC      BANKCALL        # EARTH RATE COMPENSATION BETWEEN MARKS
                CADR    EARTHR
                CCS     OPTCADR         # +0 IF MARK BUTTON NOT DEPRESSED
                TCF     +3
                TCF     EARRTCOM        # CONTINUE TO COMPENSATE FOR EARTH RATE
                TCF     +1
                TC      BANKCALL
                CADR    OPTSTALL        # INSURE SUCCESSFUL MARK
                TCF     ENDTEST

                TC      GIMANGS1

                TC      INTPRET
                LXC,1   CALL
                        MARKSTAT        # BASE ADDRESS VAC AREA FOR AOTNB
                        AOTNB           # OPTICS TO NAV BASE COORDINATE FRAME
                BONCLR  CALL            # SET TO ZERO FOR FINE ALIGN MARKS
                        COAROFIN        # COARSE MARKS = 0    FINE MARKS = 1
                        +2
                        NBSM            # NAV BASE DIRECT TO STABLE MEMBER
                STORE   STARAD +6       # TARGET 2 WRT NAV BASE OR STABLE MEMBER
                STORE   LOS2            # ...FOR K...

MAXDET          CALL
                        TAR/EREF        # TARGETS 1,2 WRT EARTH REF FRAME
                CALL
                        AXISGEN         # NAV BASE OR SM WRT EARTH REF FRAME
                EXIT
                TC      QPLACE



GIMANGS1        CAF     TWO             # BASE ADDRESS GIMBAL ANGLES FOR NBSM
                AD      MARKSTAT
                INDEX   FIXLOC
                TS      S1
                TC      Q

PUTPOSX         EXTEND                  # COARSE ALIGNS STABLE MEMBER
                QXCH    QPLACE

                TC      INTPRET
                CALL
                        CALCGA          # CALCULATE COARSE ALIGN GIMBAL ANGLES
                EXIT

                TC      BANKCALL
                CADR    IMUCOARS        # COARSE ALIGN MODE
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST
                TC      QPLACE




SMDCALC         EXTEND                  # FINE ALIGNS STABLE MEMBER
                QXCH    QPLACE

                TC      INTPRET
                VLOAD   MXV
                        XSM             # XSM DESIRED WRT EARTH REF FRAME
                        STARAD          # THEN TO SM PRESENT OR NAV BASE FRAME
                VSL1    BOFF
                        COAROFIN        # BIT10 FOR LEMLAB TEST
                        +3
                STCALL  32D
                        NBSM            # THEN TO SM PRESENT FRAME
                STOVL   XDC
                        YSM             # YSM DESIRED WRT EARTH REF FRAME

                MXV     VSL1
                        STARAD          # THEN TO SM PRESENT OR NAV BASE FRAME
                BOFF
                        COAROFIN        # BIT10 FOR LEMLAB TEST
                        +3
                STCALL  32D
                        NBSM            # THEN TO SM PRESENT FRAME
                STOVL   YDC
                        XDC

                VXV     VSL1
                        YDC
                STCALL  ZDC             # ZSM DESIRED WRT SM PRESENT FRAME
                        CALCGTA         # CALCULATE FINE ALIGN TORQUING ANGLES

                AXT,1   RTB

                ECADR   OGC             # X1 = BASE ADDRESS OF TORQUING ANGLES
                        PULSEIMU        # TO PUT OUT GYRO TORQUING PULSES
                EXIT

                TC      BANKCALL
                CADR    IMUSTALL        # WAIT FOR PULSES TO GET OUT
                TCF     ENDTEST
                TC      QPLACE

MAKEXSMD        EXIT                    # XSM V   YSM SW   ZSM SE
                CAF     17DEC           # ZERO XSM, YSM, AND ZSM
                TS      ZERONDX
                CAF     XSMADRX
                TC      BANKCALL
                CADR    ZEROING         #         VERT       SOUTH      EAST

                CAF     HALF            # XSM    * +1          0          0     *
                TS      XSM             #        *                              *
                TC      INTPRET         #        *                              *
                DLOAD   SIN             # YSM    *  0      +SIN(AZ)    +COS(AZ) *
                        AZIMUTH         #        *                              *
                STORE   XSM +8D         #        *                              *
                STODL   XSM +16D        # ZSM    *  0      -COS(AZ)    +SIN(AZ) *
                        AZIMUTH
                COS
                STORE   XSM +10D
                DCOMP
                STORE   XSM +14D
                RVQ



TAR/EREF        AXT,1   AXT,2           #               TARGET VECTOR
                        2               # SIN(EL)  -COS(AZ)COS(EL)  SIN(AZ)COS(EL)
                        12D
                SSP
                        S2
                        6               # TARGET 1                        TARGET 2

TAR1            SLOAD*  SR2             # X1=2  X2=12  S2=6 . X1=0  X2=6  S2=6
                        TAZEL1 +3,1
                STORE   0               # PD00           ELEVATION            PD00
                SIN
                STODL   18D,2           # PD06  ***       SIN(EL)        ***  PD12

                        0
                COS     PUSH            # PDOO            COS(EL)             PD00
                SLOAD*  RTB
                        TAZEL1 +2,1
                        CDULOGIC
                STORE   2               # PD02            AZIMUTH             PD02
                SIN     DMP
                        0
                SL1
                STODL   22D,2           # PD10  ***   +SIN(AZ)COS(EL)    ***  PD16

                        2
                COS     DMP
                SL1     DCOMP
                STORE   20D,2           # PD08  ***   -COS(AZ)COS(EL)    ***  PD14

                AXT,1   TIX,2
                        0
                        TAR1
                RVQ

ERTHRVSE        DLOAD   PDDL
                        ZERODP          # PD24 = (SIN -COS  0)(OMEG/MS)
                        LATITUDE
                COS     DCOMP
                PDDL    SIN
                        LATITUDE        # EARTH RATE = .1504 ARCSEC / 10 MSEC
                VDEF    VXSC            # 1.618 GYRO PULSES = 1 ARCSEC
                        OMEG/MS         # OMEG/MS = .243... GYRO PULSES / 10 MSEC
                STORE   ERVECTOR

                RTB
                        LOADTIME
                STORE   TMARK           # TIME FOR GYRO DRIFT - PIPA SCALE FACTOR
                RVQ





EARTHR          TC      MAKECADR        # CLACULATES AND COMPENSATES EARTH RATE
                TS      QPLACES

                TC      INTPRET
                RTB
                        LOADTIME        # T(PRESENT)
                STORE   TEMPTIME
                DSU     SL
                        TMARK           # T(PRES) - T(PREV) = DT    SCALED 10 MSEC
                        9D              # 2 TO 21ST POWER = 1 REVOLUTION
                VXSC    MXV
                        ERVECTOR        # VT = (SIN  -COS  0)(OMEG/MS)(DT)
                        XSM             # (XSM)(VT) = EARTH RATE COMPENSATION
                VAD
                        ERCOMP
                STODL   ERCOMP
                        TEMPTIME
                STORE   TMARK           # T(PREVIOUS)

                AXT,1   RTB
                ECADR   ERCOMP
                        PULSEIMU        # TO PUT OUT GYRO TORQUING PULSES
                EXIT

                TC      BANKCALL
                CADR    IMUSTALL        # WAIT FOR PULSES TO GET OUT
                TCF     ENDTEST
                CAE     QPLACES
                TCF     BANKJUMP

STORRSLT        EXTEND
                QXCH    QPLACE

                TC      INTPRET         # DP TIME IN MPAC SCALED .312(5) MSEC
                LXC,1   SL
                        NDXCTR
                        3
                DMP     RTB
                        SCALFTR
                        SGNAGREE
                STORE   GENPL,1         # STORE DP TIME
                EXIT

                XCH     STOREPL         # CONTAINS C(PIPAI)
                INDEX   NDXCTR
                TS      GENPL +2        # STORE PIPA COUNTER READING
                CS      NDXCTR
                AD      72DEC
                EXTEND
                BZMF    MISALIGN        # TO CALCULATE MISALIGNMENT
                CAF     THREE
                ADS     NDXCTR
                TC      QPLACE

OPTDATA         EXTEND                  # CALLS FOR AZIMUTH AND ELEVATION OF
                QXCH    QPLACE          #    TARGET 1, THEN TARGET 2

                CAF     BIT1            # AZIMUTH CLOCKWISE FROM NORTH TO TARGET
                ZL                      # ELEVATION MEASURED FROM HORIZONTAL
                LXCH    RUN
                TS      DSPTEM1 +2
                CAF     V05N30E         # DISPLAY TARGET NUMBER IN R3
                TC      NVSBWAIT
                INDEX   RUN
                DXCH    TAZEL1
                DXCH    DSPTEM1

                TC      CHECKLD         # R1  +- XXX.XX    AZIMUTH IN DEGREES
                OCT     00661           # R2  +- XX.XXX    ELEVATION IN DEGREES
                TCF     ENDTEST         # R3      0000X    TARGET NUMBER 1 OR 2

                DXCH    DSPTEM1         # TAZEL1        TARGET 1 AZIMUTH
                INDEX   RUN
                DXCH    TAZEL1          # TAZEL1 +2     TARGET 2 AZIMUTH
                CCS     RUN
                TCF     +4
OPTRDRIN        CAF     TWO             # SPECIAL ENTRY FOR RDR37511
                TS      L
                TCF     OPTDATA +4      # MPAC    1ST PASS = 0    2ND PASS = 2
                TC      QPLACE

LATAZCHK        DLOAD   SL2             # CALLS FOR AZIMUTH (SM) AND LATITUDE
                        LATITUDE
                STODL   DSPTEM1 +1
                        AZIMUTH         # ...NOT REALLY...

                RTB     EXIT
                        1STO2S          # FRACTION OF REVOLUTION TO 2S COMPLEMENT

                XCH     MPAC            # AZIMUTH MUST BE 135 DEGREES R1 = .13500
                TS      DSPTEM1         #    FOR SXT-NB-IMU FINE ALIGNMENT TEST
                TC      CHECKLD         # R1  +- XXX.XX    AZIMUTH IN DEGREES (SM)
                OCT     00661           # R2  +- XX.XXX    LATITUDE IN DEGREES
                TCF     ENDTEST         # R3               NOT USED

                TC      INTPRET
                SLOAD   RTB
                        DSPTEM1
                        CDULOGIC        # BACK TO FRACTION OF REVOLUTION
                STORE   AZIMUTH

                SLOAD   SR2
                        DSPTEM1 +1
                STORE   LATITUDE
                RVQ


CHECKLD         EXTEND
                QXCH    QPLAC

                INDEX   QPLAC
                CA      A
                TC      NVSUB
                TCF     CHECKLD1

                TC      FLASHON

                TC      ENDIDLE         # CHANGE R1  V21 N61 E  +- XXX.XX E
                TCF     +3              # CHANGE R2  V22 N61 E  +- XX.XXX E
                TCF     +4              # VERIFY, THEN PROCEED WITH VERB 33 ENTER
                TCF     CHECKLD +2
                INDEX   QPLAC
                TC      1
                INDEX   QPLAC
                TC      2

CHECKLD1        CAF     CHECKLD2
                TC      NVSUBUSY
CHECKLD2        CADR    CHECKLD +2

POSNJUMP        EXTEND                  # POSITIONS FOR SXTNBIMU
                QXCH    QPLACE

                INDEX   POSITON
                TCF     +1
                TCF     ENDTEST
                TCF     POS1
                TCF     POS2
                TCF     POS3
                TCF     POS4
                TCF     POS5



POS1            CAF     ONE             # XSM = V    YSM = SW    ZSM = SE
                TS      PIPNDX
                CAF     TWO
                TS      PIPNDX +1       # MONITOR PIPAY AND PIPAZ
                TC      QPLACE



POS2            TC      INTPRET         # XSM = SE   YSM = SW    ZSM = -V
                VLOAD   VCOMP
                        XSM
                PDVL
                        ZSM
                STOVL   XSM
                STADR
                STORE   ZSM
                EXIT
                CAF     ZERO
                TS      PIPNDX
                CAF     ONE
                TS      PIPNDX +1       # MONITOR PIPAX AND PIPAY
                TC      QPLACE



POS3            TC      INTPRET          # XSM = SE    YSM = V    ZSM = SW
                VLOAD   PDVL
                        XSM
                        YSM
                PDVL
                        ZSM
                STOVL   XSM

                STADR
                STOVL   ZSM

                STADR
                STORE   YSM
                EXIT
                CAF     ZERO
                TS      PIPNDX
                CAF     TWO
                TS      PIPNDX +1       # MONITOR PIPAX AND PIPAZ
                TC      QPLACE



POS4            CAF     BIT5            # OPTION TO ALIGN SM TO SPECIFIED ANGLES
                AD      FIXLOC
                INDEX   FIXLOC
                TS      S1              # BASE ADDRESS GIMBAL ANGLES
                CAF     V25N22E         # R1  +- XXX.XX   OUTER GIMBAL ANGLE
                TC      NVSBWAIT        # R2  +- XXX.XX   INNER GIMBAL ANGLE
                TC      ENDIDLE         # R3  +- XXX.XX   MIDDLE GIMBAL ANGLE
                TCF     ENDTEST
                TCF     -4
                CA      THETAD          # SET UP ANGLES FOR SMNB
                INDEX   FIXLOC
                TS      24
                CA      THETAD +1
                INDEX   FIXLOC
                TS      20
                CA      THETAD +2
                INDEX   FIXLOC
                TS      22

                TC      INTPRET
                RTB     CALL
                        TRANSPSE        # EARTH REF WRT NAV BASE
                        SMD/EREF        # STABLE MEMBER DESIRED WRT EARTH REF
                RTB
                        TRANSPSE        # BACK TO NAV BASE WRT TO EARTH REF
                EXIT
                TC      QPLACE

POS5            CA      QPLACE          # OPTION TO ALIGN SM TO ANY ORIENTATION
                TS      STOREPL         #   WRT EARTH REFERENCE FRAME

                TC      OPTDATA         # LOAD YSM AND ZSM AZIMUTH AND ELEVATION

                TC      INTPRET
                CALL
                        TAR/EREF        # CALC YSM AND ZSM WRT EARTH REF. FRAME
                VLOAD   PUSH
                        6D
                STORE   YSM
                VXV     VSL1
                        12D
                STORE   XSM             # XSM = (YSM) X (ZSM)
                VXV     VSL1
                STADR
                STORE   ZSM             # ZSM = (XSM) X (YSM)
                EXIT

                TC      STOREPL
OGCZERO         EXTEND                  # ZERO EARTH RATE TORQUING ANGLES
                QXCH    QPLACE

                TC      INTPRET
                VLOAD
                        ZERODP          # VECTOR IN THIS CASE
                STORE   ERCOMP
                EXIT
                TC      QPLACE





GMLCKCHK        CAF     BIT6            # CHECK FOR GIMBAL LOCK  (MGA GREATER 70)
                MASK    DSPTAB +11D
                EXTEND
                BZF     +2
                TCF     ENDTEST
                TC      Q





ENDTEST         CA      IMUSEFLG        # BIT8
                AD      RRUSEFLG        # BIT7
                CS      A
                INHINT
                MASK    STATE
                TS      STATE

                TC      NEWMODEX
                OCT     00000

                TC      BANKCALL
                CADR    MKRELEAS        # RELEASE MARK SYSTEM
                TC      EJFREE

LEMLAB          TC      INTPRET
                VLOAD   VCOMP
                        YUNIT

                STORE   ZNB             # XNB MATRIX USED IN CALCGA
                STOVL   STARAD +12D     # STARAD MATRIX USED IN AXISGEN * SMDCALC
                        XUNIT

                STORE   XNB             # *XNB*   *1    0    0* *V*
                STOVL   STARAD          # *   *   *           * * *
                        ZUNIT           # *YNB* = *0    0    1* *S*
                STORE   YNB             # *   *   *           * * *
                STORE   STARAD +6       # *ZNB*   *0   -1    0* *E*
                EXIT

                CS      POSITON
                AD      THREE
                EXTEND
                BZF     +2
                TCF     LEMLAB1

                TC      INTPRET
                VLOAD   VCOMP
                        XNB
                PDVL                    # *XNB*   * 0   -1    0* *V*
                        ZNB             # *   *   *            * * *
                STORE   XNB             # *YNB* = * 0    0    1* *S*
                STOVL   STARAD          # *   *   *            * * *
                STADR                   # *ZNB*   *-1    0    0* * *
                STORE   ZNB
                STORE   STARAD +12D
                EXIT

LEMLAB1         TC      BANKCALL
                CADR    IMUSTALL        # INSURE IMUZERO COMPLETION

                TCF     ENDTEST

                TC      POSNJUMP        # SET UP STABLE MEMBER DESIRED COORDINATES
                TC      FREEDSP         # FREE DISPLAY SYSTEM
                TC      PUTPOSX         # TO COARSE ALIGN STABLE MEMBER

                TC      GMLCKCHK

                TC      BANKCALL
                CADR    IMUFINE         # FINE ALIGN MODE
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST

                CA      CDUX
                INDEX   FIXLOC
                TS      24
                CA      CDUY
                INDEX   FIXLOC
                TS      20
                CA      CDUZ
                INDEX   FIXLOC
                TS      22

                CAF     BIT5
                AD      FIXLOC
                INDEX   FIXLOC
                TS      S1

                TC      SMDCALC         # TO FINE ALIGN STABLE MEMBER

                TC      INTPRET         # IF EARTH RATE COMPENSATION DESIRED
                RTB
                        LOADTIME
                STORE   TMARK
                EXIT

                CS      EROPTN
                AD      TWO
                EXTEND
                BZF     +2

                TCF     ERFINAL +2

                TC      BANKCALL
                CADR    SAMODRTN        # RETURN TO SEMI-AUTOMATIC MODING TEST

RDR37511        CAF     RDRRETN         # RENDEZVOUS RADAR AND ANTENNA TRACKING
                TS      QPLACE          # TO RETURN FROM OPTDATA

                TC      BANKCALL
                CADR    RRZERO

                TC      BANKCALL
                CADR    AURLOKON        # OPERATOR DECISION TO LOCK ON OR NOT

RDR1            TCF     OPTRDRIN        # CALL FOR AZIMUTH AND ELEVATION

                TC      BANKCALL
                CADR    RADSTALL
                TCF     ENDOFJOB

                TC      INTPRET
                AXT,1   AXT,2           # SET UP X1 AND X2 FOR TAR/EREF
                        0
                        6
                CALL
                        TAR/EREF +3     # LINE-OF-SIGHT WRT EARTH REF FRAME
                VLOAD   MXV
                        12D             # LINE-OF-SIGHT WRT EARTH REF FRAME
                        XSM             # TO STABLE MEMBER PRESENT FRAME
                VSL1
                STCALL  RRTARGET
                        RRDESSM

                TCF     37511ALM
                TC      BANKCALL
                CADR    RADSTALL
                TCF     ENDOFJOB
                TCF     ENDOFJOB





37511ALM        TC      ALARM
                OCT     524
                TCF     ENDOFJOB





RDRINIT         CS      ZERO
                TS      EROPTN
                TCF     AOTNBIMU +2

MISALIGN        TC      GRABWAIT        # DISPLAY SYSTEM WAS FREED
                CAF     ZERO
                TS      NDXCTR
BBBB            INDEX   NDXCTR
                CS      GENPL +68D
                INDEX   NDXCTR
                ADS     GENPL +74D
                CAF     63DEC
                AD      NDXCTR
                CCS     A
                CS      THREE
                ADS     NDXCTR
                TCF     BBBB
                TS      NDXCTR



CCCC            TC      INTPRET
                LXA,1   DLOAD*
                        NDXCTR
                        GENPL +72D,1
                DSU
                        GENPL
                STORE   GENPL +72D,1
                EXIT
                CS      NDXCTR
                AD      69DEC
                CCS     A
                CAF     THREE
                ADS     NDXCTR
                TCF     CCCC
                TS      RUN
                CAF     THREE
                TS      NDXCTR



DDDD            TC      INTPRET
                VLOAD
                        ZERODP
                STORE   24D
                STORE   30D
                SLOAD
                        11DEC
                STORE   32D
                EXIT

DDDD1           TC      INTPRET
                LXA,1   DLOAD*
                        NDXCTR

                        GENPL +72D,1
                DSU*    PUSH
                        GENPL +66D,1
                SR1     DAD*
                        GENPL +66D,1
                STORE   GENPL +72D,1

                SL2     DAD
                        24D
                STODL*  24D
                        GENPL +72D,1
                SL4     DSQ
                DAD
                        26D
                STORE   26D
                EXIT
                CAE     RUN
                AD      NDXCTR
                COM
                AD      63DEC
                CCS     A
                CAF     SIX
                ADS     NDXCTR
                TCF     DDDD1
                AD      RUN
                TS      NDXCTR



EEEE            TC      INTPRET
                LXC,1   SLOAD*
                        NDXCTR
                        GENPL +11D,1
                STORE   34D
                DLOAD
                PUSH    SL
                        8D
                BDDV    DAD
                        34D
                        28D
                STODL   28D
                SL      BDDV
                        6
                        34D
                PDDL*   SL4
                        GENPL +9D,1
                DMP
                DAD
                        30D
                STORE   30D

                EXIT
                CS      NDXCTR
                AD      60DEC
                AD      RUN
                CCS     A
                CAF     SIX
                ADS     NDXCTR
                TCF     EEEE



                TC      INTPRET
                DLOAD   DMP
                        24D
                        30D
                PDDL    DMP
                        26D
                        28D
                DSU
                PDDL    DSQ
                        24D
                SR1     PDDL
                        32D
                SL      DMP
                        11
                        26D
                DSU     BDDV
                DMP     SL
                        KKKK
                        3
                STORE   DSPTEM2
                EXIT

                CA      POSITON
                TS      DSPTEM2 +2

                CAF     V06N66E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDTEST
                CAF     THREE
                TS      RUN
                CAF     ZERO
                TCF     DDDD -1

# THIS REVISION REFLECTS CHANGES AS OF
#  1/31/66
# ENGINE ON/OFF NOW IN CHANNEL ELEVEN.  THE BITS FOR EACH CHANNEL GET TURNED ON ALL AT ONCE.  THEY STAY ON UNTIL
#  :ENTER:IS PUSHED.  THEN THEY ALL GO OUT AND THE NEXT CHANNEL:S BITS ARE TURNED ON.
# CHANNEL 5  BITS 1-8
# CHANNEL 6  BITS 1-8
# CHANNEL 11 BITS  13,14
# CHANNEL 12 BITS 9-14
# FOLLOWING THE CHANNEL 12 TESTS ENTER IS PRESSED.  CHANNEL 12 IS SET TO ZERO AND THE NEXT TEST BEGUN. LOW9
# GOES IN LOCATION (COUNTER) 55.
# INCREASE THROTTLE RATE DESCENT ENGINE
# :ENTER: NOW CAUSES THE CONTENTS OF 55 TO BE MADE NEGATIVE
# DECREASE THROTTLE RATE DESCENT ENGINE
# THE NEXT :ENTER: ZEROS THE REGISTER AND SENDS A PULSE TRAIN (HERE ALTERN
# ZEROS FOR CLARITY) TO THE ALTITUDE METER.
# THE NEXT :ENTER: WILL ADVANCE THE TEST TO THE ALTITUDE RATE METER TEST.
# THE NEXT :ENTER : WILL TERMINATE THE TEST.



SAUTOIFS        CA      POSMAX
                TS      NOBITS
                CA      ZERO
                TS      CHAN
                TS      TEMP
                TC      DINO
BACK1           INCR    CHAN

DINO            INDEX   CHAN
                CA      SAUTLOCS
                TCF     SWCALL
SAUTLOCS        CADR    CHAN5D
                CADR    CHAN6D
                CADR    CHAN11D
                CADR    CHAN12D
                CADR    PTITRDE
                CADR    PTDTRDE
                CADR    ALTMET
                CADR    ALTRMET
                CADR    ENDTEST
THROTADD        CADR    PTDTRDE +5
METERADD        CADR    ALTMET +3
MRATEADD        CADR    ALTRMET +3
CHAN5D          CA      FIVE
                TS      DSPTEM1
2ENTRY          CA      LOW8            # CHANNEL 6 RETURNS HERE
                TS      DSPTEM1 +1
                EXTEND
                INDEX   TEMP
                WRITE   5

3ENTRY          CA      V04N30D         # CH11,12 RETURN HERE TO USE THE DISPLAY
                TC      NVSBWAIT
4ENTRY          CAF     WAITER          # WAITER IS 03300
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      ENDTEST
                TC      BACK1

CHAN6D          INCR    TEMP
                INCR    DSPTEM1
                CAF     ZERO
                EXTEND
                WRITE   5               # GET RID OF CHANNEL 5 BITS
                TC      2ENTRY
CHAN11D         CA      OCT11
                TS      DSPTEM1
                CA      BIT13-14
                TS      DSPTEM1 +1
                EXTEND
                WOR     11              # WOR IS NON EXCLUSIVE OR
                CAF     ZERO
                EXTEND
                WRITE   6
                TC      3ENTRY
CHAN12D         CA      OCT12
                TS      DSPTEM1
                CS      BIT13-14
                EXTEND
                WAND    11
                CA      CH12BITS
                TS      DSPTEM1 +1
                EXTEND
                WOR     12
                TC      3ENTRY
PTITRDE         CS      CH12BITS
                EXTEND
                WAND    12
                CA      ZERO
                TS      DSPTEM1
                TS      DSPTEM1 +1
                TS      TEMP
                CA      BIT1
                TS      NOBITS
PIT             INHINT
                TC      WAITLIST
                2CADR   THROTASK

                RELINT
                CA      WAITER
                TC      NVSBWAIT

                TC      ENDIDLE
                TC      ENDTEST
                CA      ZERO
                TS      NOBITS
                TC      BACK1

PTDTRDE         CA      ZERO
                TS      THRUST
                CA      THROTADD
                TS      TEMPADD
                TC      JOBSLEEP        # THIS INHIBITS THE NEXT TASK UNTIL
# CURRENT TASK HAS BEEN COMPLETED
                CA      POSMAX
                TS      TEMP
                CA      BIT7
                TC      PIT
THROTASK        CCS     NOBITS          # IS THIS TASK STILL REQ
                TC      +5              # YES
                CA      TEMPADD         # NO
                TS      NOBITS
                TC      JOBWAKE
                TC      TASKOVER
                CCS     TEMP
                TC      SOMETIME
                CA      LOW11
ALWAYS          TS      THRUST
                CA      BIT4
                EXTEND                  # A SMERZH FIX.
                WOR     14
                CA      BIT6            # 320 MS.DELAY
                TC      WAITLIST
                2CADR   THROTASK
                TC      TASKOVER
SOMETIME        CS      LOW11
                TC      ALWAYS
ALTASK          CCS     NOBITS          # IS TASK STILL REQ
                TC      +5
                CA      TEMPADD         # NO
                TS      NOBITS          # ENABLES NEXT TASK
                TC      JOBWAKE
                TC      TASKOVER
                CA      ALBITS          # ACTUAL TASK STARTS HERE
                TS      ALTM
                CA      BIT3
                EXTEND
                WOR     14
                CA      BIT6            # 320 MS. DELAY
                TC      WAITLIST
                2CADR   ALTASK

                TC      TASKOVER
ALTMET          CA      METERADD
                TS      TEMPADD
                TC      JOBSLEEP
                CA      ZERO
                TS      TEMP
                CS      BIT4
                EXTEND
                WAND    14
                INHINT
                CA      ONE
                TC      WAITLIST
                2CADR   ALTASK
                RELINT
                CA      WAITER
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      ENDTEST
                CA      ZERO
                TS      NOBITS
                TC      BACK1

ALTRMET         CA      MRATEADD
                TS      TEMPADD
                TC      JOBSLEEP
                CA      ONE
                TS      TEMP            # TEMP WILL BE INDEXED TO ACQUIRE BIT2 INS
                                        # TEAD OF BIT3
                CA      BIT2
                EXTEND
                WOR     14
                TC      ALTMET +8D

#      THE AOT ANGLE CHECKING PROGRAM PROVIDES A SIMPLE VERIFICATION OF THE ACCURACY OF THE AOT,  THE IDEA IS TO
# COMPUTE THE ANGLE BETWEEN TWO LINES OF SIGHT AS INDICATED BY THE AOT, WHICH IS WHAT THIS PROGRAM DOES.
# INDEPENDENT KNOWLEDGE OF THE INCLUDED ANGLE PROVIDES A COMPARISON AND THUS A MEASURE OF THE AOT ACCURACY.
#       THE ISS NEED NOT BE ON TO RUN THIS PROGRAM.



AOTANGCK        TC      INTPRET
                SET     EXIT            # IN CASE THE ISS IS OFF.
                        COAROFIN
                TC      FINDNAVB        # FOR LOS1 AND LOS2.
                TC      INTPRET
                VLOAD   VXV
                        LOS1
                        LOS2
                ABVAL
                STOVL   SINTH           # SINTH = ABVAL (VXV ).
                        LOS1
                DOT
                        LOS2
                STCALL  COSTH           # COSTH = V.V
                        ARCTRIG
                RTB
                        1STO2S          # DP 1S COMP TO SP 2S COMP.
                STORE   THETA
                EXIT
                CAF     THETAADR
                AD      FIXLOC
                TS      MPAC +2
                CAF     V06N03E         # XXX.XX DEGREES IN R1.
                TC      NVSBWAIT
                TCF     ENDTEST

                EBANK=  1400
ZEROERAS        INHINT                  # PROGRAM BY MUNTZ TO ZERO ERASEABLE
                TCF     ZEROERS1
                TS      EBANK
ZEROLP          ZL
                INDEX   A
                LXCH    1401
                AD      TWO
                ADS     EBANK
                MASK    LOW8
                CCS     A
                TCF     ZEROLP
                CCS     EBANK
                TCF     ZEROLP1
                TC      POSTJUMP
                CADR    SLAP1
ZEROLP1         RELINT
                CS      ONE
                INHINT
                TCF     ZEROLP
OCT25           OCT     25

                EBANK=  OGC
BIT13-14        OCT     30000
V04N30D         OCT     00430
ALBITS          OCT     52525
THRSBITS        OCT     70707
OCT12           =       TEN
OCT11           =       NINE
CH12BITS        OCT     37400
V01N30D         OCT     00130
WAITER          OCT     03300





V01N30E         OCT     00130           # FOR FINDNAVB
V05N30E         OCT     00530           # FOR OPTDATA
V06N03E         OCT     00603
V06N66E         OCT     00666
V24N30E         OCT     02430           # FOR POSITION LOAD
V25N22E         OCT     02522           # FOR POS4

11DEC           DEC     11
17DEC           DEC     17
60DEC           DEC     60
63DEC           DEC     63
69DEC           DEC     69              # FOR MISALIGN
72DEC           DEC     72              # FOR STORRSLT

30SEC           DEC     3000            # 3000 X 10 MSEC
60SEC           DEC     6000            # 6000 X 10 MSEC

OGCADR          ADRES   OGC             # FOR ZEROING
GENPLAD1        ADRES   GENPL
GENPLADR        ECADR   GENPL           # FOR POS4
KKKK            2DEC    210.39 B-14     # 1230 B-14 FOR CSM

RDRRETN         ADRES   RDR1 +1         # FOR RDR37511
THETAADR        ECADR   THETA
XSMADRX         ADRES   XSM             # FOR MAKEXSMD

SCALFTR         2DEC    .64             # FOR STORRSLT

OMEG/MS         2DEC    .24339048       # GYRO PULSES / 10 MSEC

#          THE FOLLOWING ROUTINE READS THE CLOCK AND SCALAR (CHANNELS 3 AND 4) INTO A AND L, INSURING THAT THE
# DATA WAS NOT IN TRANSITION WHEN IT WAS READ.
                SETLOC  ENDFAILF
FINETIME        INHINT                  # RETURNS WITH INTERRUPT INHIBITED.
                EXTEND
                READ    LOSCALAR
                TS      L

                EXTEND                  # SEE IF 2 READINGS AGREE. IF NOT, READ
                RXOR    LOSCALAR        # LOSCALAR AGAIN.
                EXTEND
                BZF     +4

                EXTEND                  # IF CLOCK RIPPLED BEFORE, IT WONT NOW.
                READ    LOSCALAR
                TS      L

 +4             CS      POSMAX          # IF LOW PART CONTAINS SOMETHING LESS THAN
                AD      L               # POSMAX, THE HIGH PART CAN BE READ SAFELY
                EXTEND
                BZF     FINETIME +1     # TRY AGAIN - CONDITION WILL DISAPPEAR.

                EXTEND
                READ    HISCALAR
                TC      Q

ENDIMUF         =

                SETLOC  OMEG/MS +2
REDYTORK        TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST

                TC      OGCZERO

                TC      INTPRET
                CALL
                        ERTHRVSE        # SETS UP EARTHRATE ANGLES AND TIME
                EXIT
                CA      OPTNREG         # INITIALIZE CDUNDX FOR PULSE CATCHING
                AD      NEG2            # C(K) WAS 4 2 1 NOW C(A) IS 2 0 -1
                TS      GYTOBETQ        # C(K) = 2,0,-1 FOR  X,Y,Z.
                EXTEND
                BZF     +3
                CAF     TWO
                TC      +2
                CAF     ONE
                TS      CDUNDX          # C(K) = 1 FOR Y, 2 FOR Z CDU SELECT
                TC      BANKCALL
                CADR    ENABLE


## MAS 2023: The following chunk of code (down to ENDIMUS1) was added as a patch
## between Aurora 85 and Aurora 88. It was placed here at the end of the bank
## so as to not change addresses of existing symbols.

ZEROERS1        CAF     ZERO
                TS      TIME3
                CAF     OCT27
                TCF     ZEROERAS +2

OCT27           OCT     27

ENDIMUS1        EQUALS
