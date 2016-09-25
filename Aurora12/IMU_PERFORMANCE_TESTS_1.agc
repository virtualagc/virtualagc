### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     IMU_PERFORMANCE_TESTS_1.agc
# Purpose:      Part of the source code for Aurora (revision 12).
# Assembler:    yaYUL
# Contact:      Hartmuth Gutsche <hgutsche@xplornet.com>.
# Website:      https://www.ibiblio.org/apollo.
# Pages:        444-474
# Mod history:  2016-09-20 JL   Created.
#               2016-09-25 HG   Start transfer from scan

# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the private collection of
# Don Eyles.  The digitization was performed by archive.org.

# Notations on the hardcopy document read, in part:

#       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
#       NOV 10, 1966

#       [Note that this is the date the hardcopy was made, not the
#       date of the program revision or the assembly.]

# The scan images (with suitable reduction in storage size and consequent
# reduction in image quality) are available online at
#       https://www.ibiblio.org/apollo.
# The original high-quality digital images are available at archive.org:
#       https://archive.org/details/aurora00dapg

## Page 444
                BANK            14
                EBANK=          XSM


AOTNBIMU        CAF             ONE                     # AOT-NB-IMU FINE ALIGNMENT TEST
                TS              EROPTN                  # ... TEST CAPABILITY ...

                TC              BANKCALL
                CADR            IMUZERO                 # IMU ZERO ENCODER MODE
                TC              INPRET
                CALL
                                LATAZCHK                # TO LOAD AZIMUTH (SM) AND LATITUDE
                CALL
                                MAKEXSMD                # TO SET UP A STABLE MEMBER DESIRED MATRIX
                SET             CALL
                                COAROFIN                # FOR COARSE OR FINE ALIGN MARKS
                                ERTHRVSE                # TO CALCULATE EARTH RATE VECTOR
                EXIT

POSLOAD         CAF             V24N30E                 # R1  000X ENTER     POSITION 1,2, OR 3
                TC              NVSBWAIT                # R2  0000 ENTER     00001 FOR LAB OPTION
                TC              ENDIDLE
                TCF             ENDTEST
                TCF             -4
                XCH             DSPTEM1                 # DO NOT USE POSITION 3 WITH NAV BASE AT
                TS              POSITION                #    ZERO DEGREE TILT ANGLE. (GIMBAL LOCK)

                CCS             DSPTEM1         +1
                TCF             LEMLAB                  # SPECIAL LAB TEST TO BYPASS MARKS

                TC              POSNJUMP                # SET UP STABLE MEMBER DESIRED COORDINATES

                TC              OPTDATA                 # TARGETS 1,2 AZIMUTH AND ELEVATION

                TC              FINDNAVB                # COARSE ALIGN MARKS

                TC              BANKCALL
                CADR            IMUSTALL                # INSURE IMUZERO COMPLETION
                TCF             ENDTEST

                TC              PUTPOSX                 # TO COARSE ALIGN STABLE MEMBER

                TC              GMLCKCHK                # CHECK FOR GIMABL LOCK BEFORE FINE ALIGN
                TC              OGZERO                  # FOR EARTH RATE COMPENSATION

                TC              BANKCALL
                CADR            IMUFINE                 # FINE ALIGN MODE
                TC              BANKCALL
                CADR            IMUSTALL
                TCF             ENDTEST

## Page 445
                TC              FINDNAVB                # FINE ALIGN MARKS

                TC              FREEDSP                 # FREE DISPLAY SYSTEM

                TC              SMDCALC                 # TO FINEL ALIGN STABLE MEMBER

ERFINAL         TC              BANKCALL                # LAST EARTH RATE SHOT
                CADR            EARTHR
                CCS             EROPTN                  # IF DESIRED TO COMPENSATE CONTINUALLY
                TCF             MONSTART                #     CHANGE BY V21 NO2 E XXXXX E 00000 E
                TCF             ERFINAL
                TCF             ENDTEST
                TS              EROPTN
                INHINT
                CAF             PRIO21                  # PRIORITY 1 HIGHER THAN SXTNBIMU
                TC              FINDVAC
                2CADR           RDR37511
                RELINT
                TC              ERFINAL

MONSTART        TC              FINETIME                # TIME AT INITIAL MISALIGNMENT
                DXCH            MPAC
                RELINT
                CAF             ZERO                    # ZERO PIPA COUNTERS
                TS              PIPAX
                TS              PIPAY
                TS              PIPZ
                TS              STOREPL
                TS              NDXCTR
                TC              STORRLST                # STORE T(INITIAL) AND PIPAI = 0

                INHINT
                CAF             60SEC                   # INSURE PIPAI VARIES IN ONE DIRECTION
                TC              WAITLIST
                2CADR           PIP1

                CAF             PIP2ADR
                TC              JOBSLEEP

PIP1            CAF             PIP2ADR
                TC              JOBWAKE
                TC              TASKOVER

PIP2            CAE             PIPNDX
                TS              PIPINDEX                # POS1 PIPAY     POS2 PIPAX     POS3 PIPAX
                TC              BANKCALL
                CADR            CHECKG                  # SYNC ON PIPA PULSE

                RELINT

## Page 446
                TC              STORRSLT                # STORE TIME ANP PIPAI

                CAE             PIPNDX          +1
                TS              PIPINDEX                # POS1 PIPAZ    POS2 PIPAY    POS3 PIPAZ
                TC              BANKCALL
                CADR            CHECKG                  # SYNC PIPA PULSE

                RELINT
                TC              STORRSLT                # STORE TIME AND PIPAI

                INHINT
                CAF             30SEC                   # MONITOR PIPAS AT 30 SECOND INTERVALS
                TC              WAITLIST
                2CADR           PIP1
                CAF             PIP2ADR
                TC              JOBSLEEP
PIP2ADR         CADR            PIP2

## Page 447
FINDNAVB        EXTEND                                  # MARKS * CLAC NB OR SM WRT EARTH REF
                QXCH            QPLACE

                TC              BANKCALL
                CADR            MKRELEAS                # RELEASE MARK SYSTEM
                CAF             ONE
                TS              DSPTEM1
                CAF             V01N30E                 # DIAPLY 00001 IN R1
                TC              NVSBWAIT
                CAF             ZERO                    # TO INDICATE GROUND MARKS
                TC              BANKCALL
                CADR            AOTMARK                 # MARK ON TARGET 1

                TC              BANKCALL
                CADR            OPTSTALL                # INSURE SUCCESSFUL MARK
                TCF             ENDTEST
                EXTEND
                INDEX           MARKSTAT
                DCA             0
                DXCH            TMARK                   # TIME(PRES) FOR EARTH RATE COMPENSATION

                TC              GIMANGS1

                TC              INTPRET
                LXC,1           CALL
                                MARKSTAT                # BASE ADDRESS VAR AREA FOR AOTNB
                                AOTNB                   # OPTICS TO NAV BASE COORDINATE FRAME
                BON             CALL
                                COAROFIN                # COARSE MARKS = 0    FINE MARKS = 1
                                +2
                                NBSM                    # NAV BASE DIRECT TO STABLE MEMBER
                STORE           STARAD                  # TARGET 1 WRT NAV BASE OR STABLE MEMBER
                STORE           LOS1                    # ...FOR K...
                EXIT

                TC              BANKCALL
                CADR            MKRELEAS                # RELEASE MARK SYSTEM
                CAF             TWO
                TS              DSPTEM1
                CAF             V01N30E                 # DISPLAY 00002 IN R1
                TC              NVSBWAIT
                CAF             ZERO                    # TO INDICATE GROUND MARKS
                TC              BANKCALL
                CADR            AOTMARK                 # MARK ON TARGET 2

                CAF             BIT10
                MASK            STATE                   # BIT10 = COAROFIN
                CCS             A
                TCF             EARRTCOM        +5      # IF COARSE ALIGN MARKS

## Page 448
EARRTCOM        TC              BANKCALL                # EARTH RATE COMPENSATION BEWTEEN MARKS
                CADR            EARTHR
                CCS             OPTCADR                 # +0 IF MARK BUTTON NOT DEPRESSED
                TCF             +3
                TCF             EARRTCOM                # CONTINUE TO COMPENSATE FOR EARTH RATE
                TCF             +1
                TC              BANKCALL
                CADR            OPTSTALL                # INSURE SUCCESFUL MARK
                TCF             ENDTEST

                TC              GIMANGS1

                TC              INTPRET
                LXC,1           CALL
                                MARKSTAT                # BASE ADDRESS VAC AREA FOR AOTNB
                                AOTNB                   # OPTICS TO NAV BASE COORDINATE FRAME
                BONCLR          CALL                    # SET TO ZERO FOR FINE ALIGN MARKS
                                COAROFIN                # COARSE MARKS = 0    FINE MARKS = 1
                                +2
                                NBSM                    # NAV BASE DIRECT TO STABLE MEMBER
                STORE           STARAD          +6      # TARGET 2 WRT NAV BASE OR STABLE MEMBER
                STORE           LOS2                    # ...FOR K...
MAXDET          CALL
                                TAR/EREF                # TARGETS 1,2 WRT EARTH REF FRAME
                CALL
                                AXISGEN                 # NAV BASE OR SM WRT EARTH REF FRAME
                EXIT
                TC              QPLACE



GIMANGS1        CAF             TWO                     # BASE ADDRESS GIMBAL ANGLES FOR NBSM
                AD              MARKSTAT
                INDEX           FIXLOC
                TS              S1
                TC              Q

## Page 449
PUTPOSX         EXTEND                                  # COARSE ALIGNS STABLE MEMBER
                QXCH            QPLACE
                TC              INTPRET
                CALL
                                CALCGA                  # CALCULATE COARSE ALIGN GIMBAL ANGLES
                EXIT

                TC              BANKCALL
                CADR            IMUCOARS                # COARSE ALIGN MODE
                TC              BANKCALL
                CADR            IMUSTALL
                TCF             ENDTEST
                TC              QPLACE




SMDCALC         EXTEND                                  # FINE ALIGNS STABLE MEBER
                QXCH            QPLACE

                TC              INTPRET
                VLOAD           MXV
                                XSM                     # XSM DESIRED WRT EARTH REF FRAME
                                STARAD                  # THEN TO SM PRESENT OR NAV BASE FRAME
                VSL1            BOFF
                                COAROFIN                # BIT10 FOR LEMLAB TEST
                                +3
                STCALL          32D
                                NBSM                    # THEN TO SM PRESENT FRAME
                STOVL           XDC                     # YSM DESIRED WRT EARTH REF FRAME
                                YSM

                MXV             VSL1
                                STARAD                  # THEN TO SM PRESENT OR NAV BASE FRAME
                BOFF
                                COAROFIN                # BIT10 FOR LEMLAB TEST
                                +3
                STCALL          32D
                                NBSM                    # TEH TO SM PRESENT FRAME
                STOVL           YDC
                                XDC

                VXV             VSL1
                                YDC
                STCALL          ZDC                     # ZSM DESIRED WRT SM PRESENT FRAME
                                CALCGTA                 # CALCULATE FINE ALIGN TORQUING ANGLES

                AXT,1           RTB

## Page 450
                ECADR           OGC                     # X1 = BASE ADDRESS OF TORQUING ANGLES
                                PULSEIMU                # TO PUT OUT GYRO TORQUING PUSES
                EXIT

                TC              BANKCALL
                CADR            IMUSTALL                # WAIT FOR PULSES TO GET OUT
                TCF             ENDTEST
                TC              QPLACE

## Page 451
MAKEXSMD        EXIT                                    # XSM V   YSM SW   ZSM SE
                CAF             17DEC                   # ZERO XSM, YSM, AND ZSM
                TS              ZERONDX
                CAF             XSMADRX
                TC              BANKCALL
                CADR            ZEROING                 #         VERT       SOUTH      EAST

                CAF             HALF                    # XSM    * +1          0          0     *
                TS              XSM                     #        *                              *
                TC              INTPRET                 #        *                              *
                DLOAD           SIN                     # YSM    *  0      +SIN(AZ)    +COS(AZ) *
                                AZIMUTH                 #        *                              *
                STORE           XSM             +8D     #        *                              *
                STODL           XSM             +16D    # ZSM    *  0      -COS(AZ)    +SIN(AZ) *
                                AZIMUTH
                COS
                STORE           XSM             +10D
                DCOMP
                STORE           XSM             +14D
                RVQ


TAR/EREF        AXT,1           AXT,2                   #               TARGET VECTOR
                                2                       # SIN(EL)  -COS(AZ)COS(EL)  SIN(AZ)COS(EL)
                                12D
                SSP
                                S2
                                6                       # TARGET 1                        TARGET 2

TAR1            SLOAD*          SR2                     # X1=2  X2=12  S2=6 . X1=0  X2=6  S2=6
                                TAZEL1          +3,1
                STORE           0                       # PD00           ELEVATION            PD00
                SIN
                STODL           18D,2                   # PD06  ***       SIN(EL)        ***  PD12

                                0
                COS             PUSH                    # PDOO            COS(EL)             PD00
                SLOAD*          RTB
                                TAZEL           +2,1
                                CDULOGIC
                STORE           2                       # PD02            AZIMUTH             PD02
                SIN             DMP
                                0
                SL1
                STODL           22D,2                   # PD10  ***   +SIN(AZ)COS(EL)    ***  PD16

                                2
                COS             DMP
## Page 452
                SL1             DCOMP
                STORE           20D,2                   # PD08  ***   -COS(AZ)COS(EL)    ***  PD14

                AXT,1           TIX,2
                                0
                                TAR1
                RVQ

## Page 453


