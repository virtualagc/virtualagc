### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc
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
## Reference:   pp. 430-452
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-03 HG   Transcribed
##              2017-06-15 HG   Fix operator CS  -> CAF
##                                           XCH -> TS
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 430
# PROGRAM NAME-OPTIMUM PRELAUNCH ALIGNMENT CALIBRATION
# DATE- NOVEMBER 2  1966
# BY- GEORGE SCHMIDT IL 7-146 EXT. 126
# MOD NO 1
# FUNCTIONAL DESCRIPTION

# THIS LOG SECTION CONSISTS OF PRELAUNCH ALIGNMENT AND GYRO DRIFT TESTS
# INTEGRATED TOGETHER TO SAVE WORDS. IT IS COMPLETELY RESTART PROOFED.
# THE PRELAUNCH ALIGNMENT TECHNIQUE IS BASICALLY THE SAME AS IN BLOCK 1
# EXCEPT THAT IT HAS BEEN SIMPLIFIED IN THE SENSE THAT SMALL ANGLE APPROX.
# HAVE BEEN USED. THE DRIFT TESTS USE A UNIQUE IMPLEMENTATION OF THE
# OPTIMUM STATISTICAL FILTER. FOR A DESCRIPTION SEE E-1973.BOTH OF THESE
# ROUTINES USE STANDARD SYSTEM TEST LEADIN PROCEDURES. THE INITIALIZATION
# PROCEDURE FOR THE DRIFT TESTS IS IN THE JDC S. THE INITIALIZATION METHOD

# FOR GYROCOMPASS IS IN A SOON TO COME SYSTEM TEST GROUP MEMO.
# THIS LOG SECTION ALWAYS STARTS BY A CADR IN IMU PERF. TESTS 2 AND BEGINS
# AT ESTIMS. THE PIPS ARE READ EVERY .5 SEC IN COMPASS AND 1 SEC IN DRIFT
# TESTS. THEN IN BOTH CASES RELEVANT COMPUTATION IS DONE. THE KEY ERASABLE
# IS GEOCOMPS- 0 WE ARE IN A DRIFT TEST -NONZERO WE ARE IN COMPASS.
# THE GYROCOMPASS HAS THE CAPABILITY TO ALIGN TO ANY ORIENTATION,HAS THE
# CAPABILITY TO CHANGE ORIENTATIONS WHILE RUNNING,IS COMPENSATED FOR
# COMPONENT ERRORS,IS CAPABLE OF OPTICAL VERIFICATION( CSM ONLY).

# SUBROUTINES CALLED

# EARTHR, CALGTA,  OGC ZERO,ERTHRVSE,GCOMPZERO AND
# IMU COMPENSATION
# DURING OPTICAL VERIFICATION (CSM ONLY) ESSENTIALLY ALL OF INFLIGHT ALIGN
# IS CALLED IN ONE WAY OR ANOTHER. SEE THE LISTING.

# NORMAL EXIT

# DRIFT TESTS- LENGTHOT GOES TO ZERO-RETURN TO IMU PERF TEST2 CONTROL
# GYROCOMPASS-RECEIVE GUIDANCE REFERENCE RELEASE SIGNAL-TC MP2JOB
#                                                      206 IMPLEMENTATION

# ALARMS

# 1600     OVERFLOW IN DRIFT TEST
# 1601     BAD IMU TORQUE ABORT
# 1602     BAD OPTICS DURING VERIFICATION-RETURN TO COMPASS      CSM ONLY

# OUTPUT

# DRIFT TESTS- FLASHING DISPLAYS OF RESULTS-CONTROLLED IN IMU PERF TESTS 2
# COMPASS-PROGRAM MODE LIGHTS TELL YOU WHAT PHASE OF PROGRAM YOU ARE IN
#    01    INITIALIZING THE PLATFORM POSITION AND ERASABLE
#    05    ERECTION     600 SECOND SPENT ERECTING PLATFORM
#    02    GYROCOMPASSING
#    03    DOING OPTICAL VERIFICATION (CSM)

## Page 431
#    04    GRR SIGNAL RECEIVED FINISH UP TORQUE AND TC MP2JOB
#                                                       206 IMPLEMENTATION

# DEBRIS

# ALL CENTRALS -ALL OF EBANK 5 EBANK4 FROM JETSTEP TO JETSTEP +77D

## Page 432
                BANK            35
                EBANK=          XSM



# G SCHMIDT SIMPLIFIED ESTIMATION PROGRAM FOR ALIGNMENT CALIBRATION. THE
# PROGRAM IS COMPLETELY RESTART PROFED. DATA STORED IN BANK4.
ESTIMS          TC              PHASCHNG
                OCT             00075
RSTGTS1         INHINT                                  #  COMES HERE PHASE1 RESTART
                CA              TIME1
                TS              GTSWTLST
                CAF             ZERO                    # ZERO THE PIPAS
                TS              PIPAX
                TS              PIPAY
                TS              PIPAZ
                TS              DELVX           +1
                TS              DELVY           +1
                TS              DELVZ           +1
                RELINT
                TC              SETUPER
                CA              77DECML
                TS              ZERONDX
                CA              ALXXXZ
                TC              BANKCALL
                CADR            ZEROING

                TC              INTPRET
                VLOAD
                                INTVAL          +2
                STORE           ALX1S
                EXIT

                CCS             GEOCOMPS                # GEOCOMPS IN NON ZERO IF COMPASS
                TC              +2
                TC              SLEEPIE         +1
                CA              LENGTHOT                #   TIMES FIVE IS THE NUM OF SEC ERECTING
                TS              ERECTIME

                CA              ONE
                TS              PHASENUM
                TC              NEWMODEX
                OCT             05
                TC              BANKCALL
                CADR            GCOMPZER                #   ZERO COMPENSATION PROGRAM REGISTERS
                TC              ANNNNNN

## Page 433
ALLOOP          INHINT					#  TASK EVERY .5 OR 1 SEC (COMPASS-DRIFT)
                CA              TIME1
                TS              GTSWTLST                # STORE TIME TO SET UP NEXT WAITLIST
ALLOOP3         CA              ALTIM
                TS              GEOSAVED
                TC              PHASCHNG
                OCT             00115
                TC              +2

ALLOOP1         INHINT                                  # RESTARTS COME IN HERE
                CA              GEOSAVED
                TS              ALTIM
                CCS             A
                CA              A                       # SHOULD NEVER HIT THIS LOCATION
                TS              ALTIMS
                CS              A
                TS              ALTIM
                CA              PIPAX
                TS              DELVX
                CA              PIPAY
                TS              DELVY
                CA              PIPAZ
                TS              DELVZ
                CA              OCT31
                TC              NEWPHASE
                OCT             00005
PIPSTRTS        RELINT
                CAF             ZERO
                TS              PIPAX
                TS              PIPAY
                TS              PIPAZ
                TC              PHASCHNG

                OCT             00235
                RELINT
SPECSTS         CAF             PRIO20
                TC              FINDVAC
                EBANK=          XSM
                2CADR           ALFLT                   # START THE JOB

                TC              TASKOVER

## Page 434
ALFLT           TC              STOREDTA                #  STORE DATA IN CASE OF RESTART IN JOB
                TC              PHASCHNG                # THIS IS THE JOB DONE EVERY ITERATION
                OCT             00215
                RELINT                                  # INHINT IN PHASCHNG
                CCS             GEOCOMPS
                TC              +2
                TC              NORMLOP
                TC              BANKCALL                #  COMPENSATION IF IN COMPASS
                CADR            1/PIPA
                TC              NORMLOP



ALFLT1          TC              LOADSTDT                #  COMES HERE ON RESTART

NORMLOP         TC              CHKCOMED                # SEE IF GYROCOMPASS OVER

                TC              INTPRET
                DLOAD
                                INTVAL
                STORE           S1                      #  STEP REGISTERS MAY HAVE BEEN WIPED OUT
                SLOAD           BZE
                                GEOCOMPS
                                ALCGKK
                GOTO
                                ALFLT2
ALCGKK          SLOAD           BMN
                                ALTIMS
                                ALFLT2
ALKCG           AXT,2           LXA,1                   #  LOADS SLOPES AND TIME CONSTANTS AT RQST
                                12D
                                ALX1S
ALKCG2          DLOAD*          INCR,1
                                ALFDK           +144D,1
                DEC             -2
                STORE           ALDK            +10D,2
                TIX,2           SXA,1
                                ALKCG2

                                ALX1S

ALFLT2          VLOAD           VXM
                                DELVX
                                GEOMTRX
                VSL1
                DLOAD           DCOMP
                                MPAC            +3
                STODL           DPIPAY
                                MPAC            +5
                STORE           DPIPAZ

## Page 435

                SETPD           AXT,1                   # MEASUREMENT INCORPORATION ROUTINES.
                                0
                                8D
                SLOAD           BZE
                                GEOCOMPS
                                DELMLP
                GOTO
                                ALWAYSG                 # DO A QUICK COMPASS
DELMLP          DLOAD*          DMP
                                DPIPAY          +8D,1
                                PIPASC
                SLR             DAD*
                                9D
                                DELM            +8D,1
                DSU*            PDDL*
                                INTY            +8D,1
                                VLAUN           +8D,1
                DSU*            DMP
                                VLAUNS          +8D,1

                                VELSC
                SL2R
                DAD             STADR
                STORE           DELM            +8D,1
                STORE           DELM            +10D,1
                DLOAD*
                                VLAUN           +8D,1
                STORE           VLAUNS          +8D,1
                DLOAD
                                INTVAL          -2
                STORE           INTY            +8D,1
                TIX,1           AXT,2
                                DELMLP
                                4
ALILP           DLOAD*          DMPR*
                                ALK             +4,2
                                ALDK            +4,2
                STORE           ALK             +4,2
                TIX,2           AXT,2
                                ALILP
                                8D
ALKLP           LXC,1           SXA,1
                                CMPX1

                                CMPX1
                DLOAD*          DMPR*
                                ALK             +1,1
                                DELM            +8D,2
                DAD*
                                INTY            +8D,2
                STORE           INTY            +8D,2
                DLOAD*          DAD*

## Page 436
                                ALK             +12D,2
                                ALDK            +12D,2

                STORE           ALK             +12D,2
                DMPR*           DAD*
                                DELM            +8D,2
                                INTY            +16D,2
                STORE           INTY            +16D,2
                DLOAD*          DMP*
                                ALSK            +1,1
                                DELM            +8D,2
                SL1R            DAD*
                                VLAUN           +8D,2
                STORE           VLAUN           +8D,2
                TIX,2           AXT,1
                                ALKLP
                                8D


LOOSE           DLOAD*          PDDL*
                                ACCWD           +8D,1
                                VLAUN           +8D,1
                PDDL*           VDEF
                                POSNV           +8D,1
                MXV             VSL1

                                TRANSM1
                DLOAD
                                MPAC
                STORE           POSNV           +8D,1
                DLOAD
                                MPAC            +3
                STORE           VLAUN           +8D,1
                DLOAD
                                MPAC            +5
                STORE           ACCWD           +8D,1
                TIX,1
                                LOOSE



                AXT,2           AXT,1                   # EVALUATE SINES AND COSINES
                                6
                                2
BOOP            DLOAD*          DMPR
                                ANGX            +2,1
                                GEORGEJ
                SR2R
                PUSH            SIN

                SL1R            XAD,1
                                X1

## Page 437
                STORE          16D,2
                DLOAD
                COS
                STORE           22D,2                   # COSINES
                TIX,2           DLOAD
                                BOOP



                                14D
                SL2             DAD
                                INTY
                STODL           INTY
                                12D
                DMP             SL3R
                                20D
                DAD
                                INTZ
                STODL           INTZ
                                16D
                DMPR            DMPR
                                18D
                                14D
                SL2
                PDDL            DMPR
                                10D
                                12D
                DAD
                DMPR
                                WANGI
                PDDL            DMPR
                                18D

                                20D
                DMP             SL2R
                                WANGO
                BDSU
                                DRIFTO
                DSU             STADR
                STODL           WPLATO
                                16D
                DMPR            DMP
                                20D
                                WANGI
                SL2R
                PDDL            DMPR
                                WANGO
                                14D
                DAD
                                DRIFTI
                DSU

## Page 438
                PDDL            DMPR
                                WANGT
                                WANGI
                DAD             STADR
                STODL           WPLATI
                                18D
                DMP             SL1R
                                10D
                PDDL            DMPR
                                12D
                                16D
                DMP             SL1R
                                14D
                BDSU

                DMPR
                                WANGI
                PDDL            DMPR
                                12D
                                20D
                DMP             SL1R
                                WANGO
                BDSU
                                DRIFTT
                DAD                                     #  WPLATT NOW IN MPAC
                PUSH                                    # PUSH IT DOWN-X IT BY SANG +2
                DMPR            SR1R
                                12D
                PDDL            DMPR
                                WPLATO
                                18D
                DAD
                DDV
                                20D
                PUSH            DMPR
                                GEORGEK
                SRR             DAD
                                13D

                                ANGX
                STODL           ANGX
                DMPR            DAD
                                14D
                                WPLATI
                DMPR            SRR
                                GEORGEK
                                13D
                DAD
                                ANGY
                STODL           ANGY
                                18D
                DMP             SL1R                    # MULTIPLY X WPLATT -SL1- PUSH AND RELOAD

## Page 439
                PDDL            DMPR
                                12D
                                WPLATO
                BDSU
                DMPR            SRR
                                GEORGEK
                                13D
                DAD
                                ANGZ
                STORE           ANGZ
                BOVB            EXIT
                                SOMEERRR
                CCS             LENGTHOT
                TC              SLEEPIE
                TC              SETUPER1



ALWAYSG         DLOAD*          DSU*                    # COMPASS AND ERECT

                                DPIPAY          +8D,1
                                FILDELV         +8D,1
                DMPR            DAD*
                                GEOCONS1
                                FILDELV         +8D,1
                STORE           FILDELV         +8D,1
                DAD*
                                INTVEC          +8D,1
                STORE           INTVEC          +8D,1
                DMPR            DAD*
                                GEOCONS2
                                FILDELV         +8D,1
                DMPR            PUSH
                                GEOCONS1
                TIX,1           SLOAD
                                ALWAYSG
                                ERECTIME
                BZE             DLOAD
                                COMPGS                  # COMPASS
                                THETAN          +2
                DSU             STADR
                STODL           THETAN          +2
                BDSU

                                THETAN          +4
                STORE           THETAN          +4
                GOTO
                                ADDINDRF
COMPGS          DLOAD           DAD                     # COMPASS
                                THETAN
                                FILDELV
                STODL           THETAN

## Page 440
                                FILDELV
                DMPR            BDSU

                                GEOCONS3
                                THETAN          +4
                STODL           THETAN          +4
                                FILDELV         +4
                DMPR            BDSU
                                GEOCONS3
                                THETAN          +2
                PDDL            DMP
                                INTVEC          +4
                                GEOCONS4
                BDSU            STADR
                STORE           THETAN          +2
ADDINDRF        VLOAD
                                THETAN
                STORE           COMPTORK                # IN E7 FOR DOWNLINK.
                EXIT

ENDGTSAL        CCS             LENGTHOT                #  IS 5 SEC OVER-THE TIME TO TORQ PLATFORM
                TC              SLEEPIE                 #  NO-SET UP NEXT WAITLIST CALL FOR .5 SEC
                CCS             LGYRO                   #  YES BUT ARE GYROS BUSY
                TCF             ANNNNNN         +2      #  BUSY-GET THEM .5 SECONDS FROM NOW



                TC              CHKCOMED                # SEE IF LAST TIME FOR COMPASS

LASTGTS         TC              INTPRET
                VLOAD
                                ERCOMP
                STODL           THETAX
                                TMARK
                STORE           ALK
                EXIT                                    # PREVIOUS SECTION WAS FOR RESTARTS

RESTAIER        TC              PHASCHNG

                OCT             00275
                RELINT
                TC              INTPRET                 # ADD COMPASS COMMANDS INTO ERATE
                VLOAD           MXV
                                THETAN
                                GEOMTRX
                VSL1            VAD
                                THETAX
                STODL           ERCOMP
                                ALK
                STORE           TMARK

                EXIT

## Page 441
                TC              BANKCALL
                CADR            EARTHR                  # TORQUE IT ALL IN



                TC              PHASCHNG
                OCT             00155
                RELINT

RESTEST1        TC              CHECKMM                 # CHECK IF COMPASS OVER
                OCT             04
                TC              +2                      # NO, CONTINUE
                TC              PRELTERN                # COMPASS OVER



                INHINT
                CA              PREMTRXC
                EXTEND
                BZMF            NOCHORLD                # +1 -CHANGE, 0 OR -1 NO LOAD OR LOADING
                TC              LOADXSM                 # IF THERE WAS A CHANGE LOAD IT INTO XSM
                TC              PHASCHNG
                OCT             00255
RESTEST3        CA              ZERO                    # RESET CHANGE INDEX TO ZERO
                TS              PREMTRXC
                RELINT

## Page 442
                TC              INTPRET                 # HERE TO CHANGE ORIENTATOON
                AXT,1                                   # DESIRED IN XSM,PRESENT IN GEOMTRX
                                18D
                SSP
                                S1
                                6
LOADM           VLOAD*          DOT
                                XSM             +18D,1
                                GEOMTRX         +12D
                PDVL*           DOT
                                XSM             +18D,1
                                GEOMTRX         +6D
                PDVL*           DOT
                                XSM             +18D,1

                                GEOMTRX
                VDEF            UNIT
                STORE           XDC             +18D,1
                TIX,1           CALL
                                LOADM
                                CALCGTA
                EXIT
                TC              TORQINCH                # NECESSARY TORQUE NOW IN OGC



SETUPER1        TC              INTPRET
                DLOAD           PDDL                    # ANGLES FROM DRIFT TEST ONLY
                                ANGZ
                                ANGY
                PDDL            VDEF
                                ANGX
                VCOMP           VXSC
                                GEORGEJ
                MXV             VSR1
                                GEOMTRX
                STORE           OGC
                EXIT



TORQINCH        TC              PHASCHNG
                OCT             00175
                RELINT                                  # INHINT IN PHASCHNG
                CA              AINGYRO
                TC              BANKCALL
                CADR            IMUPULSE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              SOMERR2                 # BAD GYRO TORQUE-END OF TEST

## Page 443
GEOSTRT4        CCS             TORQNDX                 #  ONLY POSITIVE IF IN VERTICAL DRIFT TEST
                TC              GEOBAVR                 # VERT DRIFT TEST OVER
                TC              SETUPER                 #  SET UP ERATE FOR PIPTEST OR COMPASS
                CCS             GEOCOMPS
                TC              TQORESTM
                TC              BANKCALL                # GO TO IMU2 FOR A PIPA TEST AND DISPLAY
                CADR            TORQUE

GEOBAVR         TC              BANKCALL
                CADR            VALMIS                  #  DISPLAY VERTICAL DRIFT

## Page 444
# SET UP WAITLIST SECTION
SLEEPIE         TS              LENGTHOT                # TEST NOT OVER-DECREMENT LENGTHOT

                TC              PHASCHNG                #  CHANGE PHASE
                OCT             00135
                RELINT                                  # INHINT IN PHASCHNG
                CCS             TORQNDX                 # ARE WE DOING VERTDRIFT
                TC              EARTTPRQ                # YES,DO HOR ERATE TORQ THEN SLEEP
                TC              WTLISTNT                # GO TO SET UP NEXT WAITLIST
EARTTPRQ        TC              BANKCALL                # IN VERTDRIFT,ADD HOR ERATE AND SLEEP
                CADR            EARTHR
WTLISTNT        TC              CHKCOMED                # SEE IF GYROCOMPASS OVER

                INHINT
                CS              TIME1
                AD              GTSWTLST
                EXTEND
                BZMF            +2
                AD              NEGMAX
                AD              1SECXT                  # 1 SEC FOR CALIBRATION,.5 SEC IN COMPASS
                EXTEND
                BZMF            RIGHTGTS
WTGTSMPL        TC              WAITLIST
                EBANK=          XSM
                2CADR           ALLOOP

                RELINT
                TC              ENDOFJOB
RIGHTGTS        CAF             TWO
                TC              WTGTSMPL



SOMEERRR        TC              ALARM
                OCT             1600
                TC              +3
SOMERR2         TC              ALARM
                OCT             1601
                TC              BANKCALL
                CADR            ENDTEST

## Page 445
TQORESTM        TC              BANKCALL
                CADR            LOADGTSM                # LOAD NEW XSM MATRIX INTO GEOMTRX

NOCHORLD        RELINT                                  # AFTER CHANGEIN ORIEN OR NO CHANGE
                TC              INTPRET
                VLOAD
                                SCHZEROS
                STORE           THETAN

                EXIT
                CCS             ERECTIME
                TS              ERECTIME                #        COUNTS DOWN FOR ERECTION

ANNNNNN         CAF             NINE
                TS              LENGTHOT
                CCS             ERECTIME
                TC              SLEEPIE         +1
                TC              CHECKMM                 # IN COMPASS CHECK FOR VERIFICATION
                OCT             03
                TC              +2                      # NOT VERIFYING
                TC              SLEEPIE         +1      # YES
                TC              NEWMODEX
                OCT             02
                TC              SLEEPIE         +1      # COMPASS IS 02  -ERECTION 05
SETUPER         EXTEND                                  # SUBROUTINE CALLED IN 3 PLACES
                QXCH            QPLACES
                TC              INTPRET
                CALL
                                ERTHRVSE
                EXIT
                TC              BANKCALL
                CADR            OGCZERO

                TC              QPLACES

## Page 446
GEOBND          =               EBANK3
GEOBND1         =               EBANK5
STOREDTA        CAF             GEOBND
                TS              L
                CAF             77DECML
                TS              MPAC
                INDEX           MPAC
                CA              ALX1S
                LXCH            EBANK
                EBANK=          RESTRTCS
                INDEX           MPAC
                TS              RESTRTCS
                LXCH            EBANK
                EBANK=          XSM

                CCS             MPAC
                TCF             +2
                TC              Q
                TS              MPAC
                CAF             GEOBND
                TS              L
                TCF             STOREDTA        +4



LOADSTDT        CAF             77DECML
                TS              MPAC
                CA              GEOBND
                XCH             EBANK
                TS              L
                EBANK=          RESTRTCS
                INDEX           MPAC
                CA              RESTRTCS
                LXCH            EBANK
                EBANK=          XSM
                INDEX           MPAC
                TS              ALX1S
                CCS             MPAC

                TCF             +2
                TC              Q
                TS              MPAC
                TCF             LOADSTDT        +2

## Page 447
LOADXSM         EXTEND
                QXCH            QPLACES
                CAF             17DECML
                TS              MPAC
                INDEX           A
                CA              PRELMTRX
                INDEX           MPAC
                TS              XSM
                CCS             MPAC
                TCF             LOADXSM         +3
                TC              QPLACES
ALFDK           DEC             -28                     # SLOPES AND TIME CONSTANTS FOR FIRST 30SC
                DEC             -1
                2DEC            .91230833               # TIME CONSTANTS-PIPA OUTPUTS

                2DEC            .81193187               # TIME CONSTANT-ERECTION ANGLES

                2DEC            -.00035882              # SLOPE-AZIMUTH ANGLE


                2DEC            -.00000029              # SLOPE-VERTICAL DRIFT

                2DEC            .00013262               # SLOPE-NORTH SOUTH DRIFT



                DEC             -58                     # 31-90 SEC
                DEC             -1
                2DEC            .99122133

                2DEC            .98940595

                2DEC            -.00079010

                2DEC            -.00000265

                2DEC            .00043154



                DEC             -8                      # 91-100 SEC
                DEC             -1
                2DEC            .99971021


                2DEC            .99852047

                2DEC            .00042697

                2DEC            -.00000213

                2DEC            .00011864

## Page 448
                DEC             -98                     # 101-200 SEC
                DEC             -1

                2DEC            .99550063

                2DEC            .98992124

                2DEC            .00043452

                2DEC            -.00000401

                2DEC            -.00021980



                DEC             -248                    # 201-450 SEC
                DEC             -1
                2DEC            .99673264

                2DEC            .99365467

                2DEC            .00003767

                2DEC            -.00002317

                2DEC            -.00003305




                DEC             -338                    # 451-790 SEC
                DEC             -1
                2DEC            .99924362

                2DEC            .99888274

                2DEC            .00000064

                2DEC            -.00004012

                2DEC            -.00000195



                DEC             -408                    # 791-1200 SEC
                DEC             -1
                2DEC            .99963845

                2DEC            .99913162


                2DEC            .00000090

## Page 449
                2DEC            .00002927

                2DEC            -.00000026



                DEC             -498                    # 1201-1700 SEC
                DEC             -1

                2DEC            .99934865

                2DEC            .99868793

                2DEC            .00000055

                2DEC            .00001183

                2DEC            -.00000005



                DEC             -398                    # 1701-2100 SEC
                DEC             -1
                2DEC            .99947099

                2DEC            .99894799

                2DEC            .00000018

                2DEC            .00000300

                2DEC            -.00000001




                DEC             -598                    # 2101-2700 SEC
                DEC             -1
                2DEC            .99957801

                2DEC            .99916095

                2DEC            .00000007

                2DEC            .00000096

                2DEC            .00000000



                DEC             -698                    # 2700-3400 SEC
                DEC             -1

## Page 450
                2DEC            .99966814

                2DEC            .99933952

                2DEC            .00000002

                2DEC            .00000028

                2DEC            .00000000



                DEC             -598                    # 3401-4000 SEC
                DEC             -1

                2DEC            .99972716

                2DEC            .99945654

                2DEC            .00000001

                2DEC            .00000010

                2DEC            .00000000



SCHZEROS        2DEC            .00000000

                2DEC            .00000000

                2DEC            .00000000

INTVAL          OCT             4
                OCT             2
                DEC             144
                DEC             -1
SOUPLY          2DEC            .93505870               #  INITIAL GAINS FOR PIP OUTPUTS


                2DEC            .26266423               #  INITIAL GAINS/4 FOR ERECTION ANGLES



77DECML         DEC             77
ALXXXZ          GENADR          ALX1S           -1
AINGYRO         ECADR           OGC
PIPASC          2DEC            .13055869

VELSC           2DEC            -.52223476              #  512/980.402

ALSK            2DEC            .17329931               # SSWAY VEL GAIN X 980.402/4096

## Page 451
                2DEC            -.00835370		# SSWAY ACCEL GAIN X 980.402/4096



GEORGEJ         2DEC            .63661977

GEORGEK         2DEC            .59737013

OCT31           OCT             00031
GEOCONS1        2DEC            .1

GEOCONS2        2DEC            .005

GEOCONS3        2DEC            .025

GEOCONS4        2DEC            .00003

1/PIPAGT        OCT             06200
17DECML         DEC             17

19DECML         DEC             19
1/2SECX         DEC             50



GTSCPSS         CA              ONE
                TS              GEOCOMPS                # THIS IS THE LEAD IN FOR COMPASS
                TC              NEWMODEX
                OCT             01
                CA              1/PIPAGT
                TS              1/PIPADT
                CA              ZERO
                TS              PREMTRXC
                CAF             1/2SECX
                TS              1SECXT
                TC              BANKCALL
                CADR            GEOIMUTT



CHKCOMED        CA              FLAGWRD1                # CHECK FOR END OF COMPASS
                MASK            BIT2                    # TEST FOR GRR FLAG
                CCS             A

                TCF             PRELTERM                # YES   GRR HAS OCCURRED
                TC              Q                       # NO  CONTINUE


PRELTERM        TC              NEWMODEX
                OCT             04                      # 04 IS END OF COMPASS
                TCF             LASTGTS                 # GET LAST TORQUING

## Page 452

PRELTERN        INHINT                                  # GET TIME OF PRELAUNCH TERMINATION.
                EXTEND

                DCA             TMARK                   # TIME OF LAST EARTH RATE COMPENSATION.
                DXCH            TEMTPREL                # INTO COMMON TEMP UNTIL MP2.
                CAF             PRIO24
                TC              FINDVAC                 # SET UP MISSION PHASE 2
                EBANK=          TGRR
                2CADR           MP2JOB

                TCF             ENDOFJOB
