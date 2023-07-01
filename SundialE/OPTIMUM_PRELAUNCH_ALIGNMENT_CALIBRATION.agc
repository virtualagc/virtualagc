### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-22 MAS  Created from Aurora 12.
##              2023-06-30 MAS  Updated for Sundial E.


# THIS PROGRAM USES A VERTICAL,SOUTH,EAST COORDINATE SYSTEM FOR PIPAS
                BANK    16
                EBANK=  XSM

# G SCHMIDT SIMPLIFIED ESTIMATION PROGRAM FOR ALIGNMENT CALIBRATION. THE
# PROGRAM IS COMPLETELY RESTART PROFED. DATA STORED IN BANK4.
ESTIMS          CA      GEOCOMPS
                TS      GEOSAVED
                EXTEND
                BZMF    ESTIMS1
                TC      BANKCALL
                CADR    EARTHR

ESTIMS1         TC      PHASCHNG
                OCT     00101

RSTGTS1         INHINT                  #  COMES HERE PHASE1 RESTART
                CA      GEOSAVED
                TS      GEOCOMPS

                CAF     1SEC
                TC      WAITLIST
                2CADR   ALLOOP

                CAF     ZERO            # ZERO THE PIPAS
                TS      PIPAX
                TS      PIPAY
                TS      PIPAZ
                TS      ALTIM

                CAF     13DECML
                TS      ZERONDX
                CAF     LINTY
                TC      BANKCALL
                CADR    ZEROING

                RELINT
                CAF     BIT6
                TS      ZERONDX
                CAF     LVLAUN
                TC      BANKCALL
                CADR    ZEROING
                CAF     SEVEN
                TS      ZERONDX
                CAF     LALK4
                TC      BANKCALL
                CADR    ZEROING
                TC      INTPRET
                DLOAD
                        INTVAL
                STOVL   S1
                        INTVAL +2
                STOVL   ALX1S
                        GEORGED
                STOVL   TRANSM1
                        GEORGEC
                STOVL   TRANSM1 +6
                        GEORGEB
                STORE   TRANSM1 +12D
                EXIT

                CCS     GEOCOMPS
                TC      SETUPALK
                TC      NOCHORLD

                CAF     ONE
                TS      GEOCOMPS

                TC      INTPRET
SETDRIFT        SLOAD   DCOMP
                        SPDRIFT +2
                PUSH
                SLOAD   PUSH
                        SPDRIFT +1
                SLOAD   VDEF
                        SPDRIFT
                VXM     VSL1
                        XSM
                STORE   DRIFTO
                EXIT

                TC      BANKCALL
                CADR    LOADGTSM

                CCS     PREMTRXC
                TC      NOCHORLD
                TC      INTPRET
                GOTO
                        BOOP -3

NOCHORLD        TC      PHASCHNG
                OCT     00301
                TC      ENDOFJOB

LINTY           GENADR  INTY
LVLAUN          GENADR  VLAUN -1

PIPASC          2DEC    .76376833

VELSC           2DEC    -.52223476      # 512/980.402

ALSK            2DEC    .17329931       # SSWAY VEL GAIN X 980.402/4096

                2DEC    -.00835370      # SSWAY ACCEL GAIN X 980.402/4096

GEORGED         2DEC    -.75079894

                2DEC    -.13613567

                2DEC    -.12721382

GEORGEC         2DEC    .94817689

                2DEC    .46251787

                2DEC    .29123377

GEORGEB         2DEC    -.33613492

                2DEC    .31165878
                
                2DEC    -.49757417

GEORGEJ         2DEC    .63661977

GEORGEK         2DEC    .59737013

PI/4.0          2DEC    .78539816

AINGYRO         ECADR   GYROD

ALX1S1          DEC     60
                DEC     -1
                2DEC    .00473468
                2DEC    .000004839

ALK1            2DEC    -.00016228
                2DEC    -.00211173
                2DEC    .00001489

SETUPALK        CAF     150DECML
                TS      LENGTHOT

                TC      INTPRET
                VLOAD
                        ALX1S1
                STOVL   ALX1S
                        ALK1
                STORE   ALK +4
                GOTO
                        SETDRIFT

ALLOOP          INHINT
                CS      PHASE1
                AD      THREE
                EXTEND
                BZF     +2
                TC      SOMEERRR

                CA      ALTIM
                TS      GEOSAVED
                TC      PHASCHNG
                OCT     00201
                TC      +2

ALLOOP1         INHINT                  # RESTARTS COME IN HERE
                CA      GEOSAVED
                TS      ALTIM
                CCS     A
                TC      SOMEERRR        # SHOULD NEVER HIT THIS LOCATION
                TS      ALTIMS
                CS      A
                TS      ALTIM
                CA      LENGTHOT
                EXTEND
                BZMF    ALLOOP2
                CAF     1SEC
                TC      WAITLIST
                2CADR   ALLOOP

ALLOOP2         CAF     ZERO
                TS      FILDELVX +1
                TS      FILDELVY +1
                TS      FILDELVZ +1
                XCH     PIPAX
                TS      FILDELVX
                CAF     ZERO
                XCH     PIPAY
                TS      FILDELVY
                CAF     ZERO
                XCH     PIPAZ
                TS      FILDELVZ
                RELINT
SPECSTS         CAF     PRIO20
                TC      FINDVAC
                2CADR   ALFLT           # START THE JOB

                TC      TASKOVER

ALKCG           AXT,2   LXA,1           # LOADS SLOPES AND TIME CONSTANTS AT RQST
                        12D
                        ALX1S
ALKCG2          DLOAD*  INCR,1
                        ALFDK +156D,1
                DEC     -2
                STORE   ALDK +10D,2
                TIX,2   SXA,1
                        ALKCG2
                        ALX1S
                GOTO
                        ALFLT2

ALFLT           TC      STOREDTA        #  STORE DATA IN CASE OF RESTART IN JOB
                CA      LENGTHOT
                TS      LTHOTSAV
                TC      PHASCHNG        # THIS IS THE JOB DONE EVERY ITERATION
                OCT     01101
                TC      NORMLOP
REALFLT         CA      GEOBND1
                TS      EBANK

ALFLT1          TC      LOADSTDT        # COMES HERE ON RESTART

                CA      LTHOTSAV
                TS      LENGTHOT
                EXTEND
                BZMF    NORMLOP
                INHINT
                CAF     BIT7
                TC      WAITLIST
                2CADR   ALLOOP

                RELINT

NORMLOP         TC      INTPRET
                DLOAD
                        INTVAL
                STORE   S1              # STEP REGISTERS MAY HAVE BEEN WIPED OUT
                SLOAD   BZE
                        ALTIMS
                        ALKCG

ALFLT2          VLOAD   VXM
                        FILDELVX
                        GEOMTRX
                STORE   FILDELVX
                DLOAD   DCOMP
                        FILDELVY
                STODL   DPIPAY
                        FILDELVZ
                STORE   DPIPAZ

                SETPD   AXT,1           # MEASUREMENT INCORPORATION ROUTINES.
                        0
                        8D

DELMLP          DLOAD*  DMP
                        DPIPAY +8D,1
                        PIPASC
                SLR     BOVB
                        10D
                        SOMERR1
                BDSU*
                        INTY +8D,1
                STORE   INTY +8D,1
                PDDL    DMP*
                        VELSC
                        VLAUN +8D,1
                SL2R
                DSU     STADR
                STORE   DELM +8D,1
                STORE   DELM +10D,1
                TIX,1   AXT,2
                        DELMLP
                        4
ALILP           DLOAD*  DMPR*
                        ALK +4,2
                        ALDK +4,2
                STORE   ALK  +4,2
                TIX,2   AXT,2
                        ALILP
                        8D
ALKLP           LXC,1   SXA,1
                        CMPX1
                        CMPX1
                DLOAD*  DMPR*
                        ALK +1,1
                        DELM +8D,2
                DAD*
                        INTY +8D,2
                STODL*  INTY +8D,2
                        ALK +12D,2
                DAD*
                        ALDK +12D,2
                STORE   ALK +12D,2
                DMPR*   DAD*
                        DELM +8D,2
                        INTY +16D,2
                STODL*  INTY +16D,2
                        ALSK +1,1
                DMP*    SL1R
                        DELM +8D,2
                DAD*
                        VLAUN +8D,2
                STORE   VLAUN +8D,2
                TIX,2   AXT,1
                        ALKLP
                        8D


LOOSE           DLOAD*  DMPR
                        VLAUN +8D,1
                        TRANSM1
                SL1
                PDDL*   DMPR
                        POSNV +8D,1
                        TRANSM1 +2
                PDDL*   DMPR
                        POSNV +8D,1
                        TRANSM1 +4
                PDDL*   DMPR
                        POSNV +8D,1
                        TRANSM1 +6
                PDDL*   DMPR
                        VLAUN +8D,1
                        TRANSM1 +8D
                DAD
                PDDL*   DMPR
                        ACCWD +8D,1
                        TRANSM1 +10D
                DAD     STADR
                STODL*  POSNV +8D,1
                        VLAUN +8D,1
                DMPR
                        TRANSM1 +12D
                DAD
                PDDL*   DMPR
                        ACCWD +8D,1
                        TRANSM1 +14D
                DAD     STADR
                STODL*  VLAUN +8D,1
                        ACCWD +8D,1
                DMPR
                        TRANSM1 +16D
                DAD
                DAD     STADR
                STORE   ACCWD +8D,1
                TIX,1
                        LOOSE


                AXT,2   AXT,1           # EVALUATE SINES AND COSINES
                        6
                        2
BOOP            DLOAD*  DMPR
                        ANGX +2,1
                        GEORGEJ
                SR2R
                PUSH    SIN
                SL1R    XAD,1
                        X1
                STODL   BPLAC +6,2
                COS
                STORE   WPLATO,2        # COSINES
                TIX,2
                        BOOP
                DLOAD   SL2
                        BPLAC +4
                DAD
                        INTY
                STODL   INTY
                        BPLAC +2
                DMP     SL3R
                        BPLAC +10D
                DAD
                        INTZ
                STODL   INTZ
                        BPLAC +6
                DMPR    DMPR
                        BPLAC +8D
                        BPLAC +4
                SL2
                PDDL    DMPR
                        BPLAC
                        BPLAC +2
                DAD
                DMPR
                        WANGI
                PDDL    DMPR
                        BPLAC +8D
                        BPLAC +10D
                DMP     SL2R
                        WANGO
                BDSU
                        DRIFTO
                DSU     STADR
                STODL   WPLATO
                        BPLAC +6
                DMPR    DMP
                        BPLAC +10D
                        WANGI
                SL2R
                PDDL    DMPR
                        WANGO
                        BPLAC +4
                DAD
                        DRIFTI
                DSU
                PDDL    DMPR
                        WANGT
                        WANGI
                DAD     STADR
                STODL   WPLATI
                        BPLAC +8D
                DMP     SL1R
                        BPLAC
                PDDL    DMPR
                        BPLAC +2
                        BPLAC +6
                DMP     SL1R
                        BPLAC +4
                BDSU
                DMPR
                        WANGI
                PDDL    DMPR
                        BPLAC +2
                        BPLAC +10D
                DMP     SL1R
                        WANGO
                BDSU
                        DRIFTT
                DAD     STADR           #  WPLATT NOW IN MPAC
                STORE   WPLATT          # PUSH IT DOWN-X IT BY SANG +2
                DMPR    SR1R
                        BPLAC +2
                PDDL    DMPR
                        WPLATO
                        BPLAC +8D
                DAD
                DDV
                        BPLAC +10D
                PUSH    DMPR
                        GEORGEK
                SRR     DAD
                        13D
                        ANGX
                STODL   ANGX
                DMPR    DAD
                        BPLAC +4
                        WPLATI
                DMPR    SRR
                        GEORGEK
                        13D
                DAD
                        ANGY
                STODL   ANGY
                        BPLAC +8D
                DMP     SL1R            # MULTIPLY X WPLATT -SL1- PUSH AND RELOAD
                        WPLATT
                PDDL    DMPR
                        BPLAC +2
                        WPLATO
                BDSU
                DMPR    SRR
                        GEORGEK
                        13D
                DAD
                        ANGZ
                STORE   ANGZ
                EXIT

ONCEMORE        CCS     LENGTHOT
                TC      SLEEPIE
                TC      SETUPER

                CCS     GEOCOMPS
                TC      SAVEST
                
                CCS     TORQNDX
                TC      +2
                TC      GOAGAIN
                TC      BANKCALL
                CADR    VALMIS

SLEEPIE         TS      LENGTHOT        # TEST NOT OVER-DECREMENT LENGTHOT
                TC      PHASCHNG        #  CHANGE PHASE
                OCT     00301
                CCS     TORQNDX         # ARE WE DOING VERTDRIFT
                TC      EARTTPRQ        # YES,DO HOR ERATE TORQ THEN SLEEP
                TC      ENDOFJOB

SAVEST          TC      INTPRET
                DLOAD
                        ANGX
                STODL   ANGXSAV
                        GAZ1
                STORE   GAZ1SAV
                EXIT
                TC      GOAGAIN

EARTTPRQ        TC      BANKCALL        # IN VERTDRIFT,ADD HOR ERATE AND SLEEP
                CADR    EARTHR
                TC      ENDOFJOB

ALFDK           DEC     -28             # SLOPES AND TIME CONSTANTS FOR FIRST 30SC
                DEC     -1
                2DEC    .91230833       # TIME CONSTANTS-PIPA OUTPUTS

                2DEC    .81193187       # TIME CONSTANT-ERECTION ANGLES

                2DEC    -.00035882      # SLOPE-AZIMUTH ANGLE

                2DEC    -.00000029      # SLOPE-VERTICAL DRIFT

                2DEC    .00013262       # SLOPE-NORTH SOUTH DRIFT


                DEC     -58             # 31-90 SEC
                DEC     -1
                2DEC    .99122133

                2DEC    .98940595

                2DEC    -.00079010

                2DEC    -.00000265

                2DEC    .00043154


                DEC     -8              # 91-100 SEC
                DEC     -1
                2DEC    .99971021

                2DEC    .99852047

                2DEC    .00042697

                2DEC    -.00000213

                2DEC    .00011864

                DEC     -98             # 101-200 SEC
                DEC     -1
                2DEC    .99550063

                2DEC    .98992124

                2DEC    .00043452

                2DEC    -.00000401

                2DEC    -.00021980


                DEC     -248            # 201-450 SEC
                DEC     -1
                2DEC    .99673264

                2DEC    .99365467

                2DEC    .00003767

                2DEC    -.00002317

                2DEC    -.00003305


                DEC     -338            # 451-790 SEC
                DEC     -1
                2DEC    .99924362

                2DEC    .99888274

                2DEC    .00000064

                2DEC    -.00004012

                2DEC    -.00000195


                DEC     -408            # 791-1200 SEC
                DEC     -1
                2DEC    .99963845

                2DEC    .99913162

                2DEC    .00000090

                2DEC    .00002927

                2DEC    -.00000026


                DEC     -498            # 1201-1700 SEC
                DEC     -1
                2DEC    .99934865

                2DEC    .99868793

                2DEC    .00000055

                2DEC    .00001183

                2DEC    -.00000005


                DEC     -398            # 1701-2100 SEC
                DEC     -1
                2DEC    .99947099

                2DEC    .99894799

                2DEC    .00000018

                2DEC    .00000300

                2DEC    -.00000001


                DEC     -598            # 2101-2700 SEC
                DEC     -1
                2DEC    .99957801

                2DEC    .99916095

                2DEC    .00000007

                2DEC    .00000096

                2DEC    .00000000


                DEC     -698            # 2700-3400 SEC
                DEC     -1
                2DEC    .99966814

                2DEC    .99933952

                2DEC    .00000002

                2DEC    .00000028

                2DEC    .00000000


                DEC     -598            # 3401-4000 SEC
                DEC     -1
                2DEC    .99972716

                2DEC    .99945654

                2DEC    .00000001

                2DEC    .00000010

                2DEC    .00000000


                DEC     -16000          # 4001- SEC
                DEC     -1
                2DEC    .99999999

                2DEC    .99999999

                2DEC    .00000000

                2DEC    .00000000

                2DEC    .00000000


INTVAL          OCT     4
                OCT     2
                DEC     156
                DEC     -1
SOUPLY          2DEC    .93505870       # INITIAL GAINS FOR PIP OUTPUTS
                2DEC    .26266423       # INITIAL GAINS/4 FOR ERECTION ANGLES


GTSCPSS         CS      ONE
                TS      GEOCOMPS        # THIS IS THE LEAD IN FOR COMPASS
                CA      ZERO
                TS      GTSOPNDZ
                TS      PREMTRXC
                TC      CALCXSM
                TC      BANKCALL
                CADR    GEOIMUTT        # TO IMU PERF TESTS 2

LALK4           GENADR  ALK +4D
GBIT10          OCT     01000
13DECML         DEC     13
1SEC            DEC     100
150DECML        DEC     150

GOAGAIN         TC      PHASCHNG
                OCT     00401

                CA      GEOCOMPS
                TS      GEOSAVED
                CCS     A
                TC      +4
                TC      SETUPER1
                TC      SOMERR2
                TC      GOAGAIN1

                TC      INTPRET
                DLOAD
                        ANGXSAV
                STODL   ANGX
                        GAZ1SAV
                STORE   GAZ1

                DSU     DMP
                        GAZIMUTH
                        PI/4.0
                SL3R    DAD
                        ANGX
                STORE   ANGX
                EXIT

GOAGAIN1        TC      CALCXSM
                        
SETUPER1        TC      INTPRET
                DLOAD   PDDL            # ANGLES FROM DRIFT TEST ONLY
                        ANGZ
                        ANGY
                PDDL    VDEF
                        ANGX
                VCOMP   VXSC
                        GEORGEJ
                MXV     VSR1
                        GEOMTRX
                STORE   GYROD
                EXIT


TORQINCH        TC      PHASCHNG
                OCT     00501
                CA      AINGYRO
                TC      BANKCALL
                CADR    IMUPULSE
                TC      BANKCALL
                CADR    IMUSTALL
                TC      SOMERR2         # BAD GYRO TORQUE-END OF TEST

RETORQIN        CCS     GEOSAVED
                TC      GCSTART
                TC      BANKCALL
                CADR    TORQUE

                TC      GOGAZCHK

SOMEERRR        RELINT
                TC      ALARM
                OCT     1600
                TC      ONCEMORE

SOMERR1         TC      ALARM
                OCT     1601
                TC      ONCEMORE

SOMERR2         TC      ALARM
                OCT     1602
                TC      BANKCALL
                CADR    ENDTEST

CALCXSM         EXTEND
                QXCH    QPLACES
                TC      INTPRET
                DLOAD
                        GAZIMUTH
                STORE   GAZ1    
                PUSH    SIN
                STODL   SINGAZ
                COS
                STORE   COSGAZ
                STORE   YSM +2
                STODL   XSM +4
                        SINGAZ
                STORE   YSM +4
                VCOMP
                STORE   XSM +2
                EXIT
                TC      QPLACES

GCSTART         CCS     GTSOPNDZ
                TC      +2
                TC      ESTIMS
                TC      SETUPER

                INHINT
                CAF     ZERO
                TS      FILDELVX
                TS      FILDELVY
                TS      FILDELVZ

                CAF     1SEC
                TC      WAITLIST
                2CADR   GAZCHECK

                RELINT
                TC      PHASCHNG
                OCT     00601
                TC      ENDOFJOB

GAZCHECK        CS      GAZ1
                AD      GAZIMUTH
                EXTEND
                BZF     GAZCHK2

GAZCHK1         CA      ONE
                TS      FILDELVZ
                TC      GCHKOUT

GAZCHK2         CS      GAZ1 +1
                CA      GAZIMUTH +1
                EXTEND
                BZF     +2
                TC      GAZCHK1

                CCS     FILDELVX
                TC      GAZCHK3
                INHINT
                CAF     1SEC
                TC      WAITLIST
                2CADR   GAZCHECK

                RELINT

GCHKOUT         CAF     PRIO20
                TC      FINDVAC
                2CADR   GTSPHAS7

                TC      TASKOVER

GAZCHK3         CAF     ONE
                TS      FILDELVY
                TC      GCHKOUT

GTSPHAS7        TC      PHASCHNG
                OCT     00701
                
                TC      BANKCALL
                CADR    EARTHR
CALCANGX        CCS     FILDELVZ
                TC      +2
                TC      ENDGCHK

                TC      INTPRET
                DLOAD   DSU
                        GAZ1
                        GAZIMUTH
                DMP     SL3R
                        PI/4.0
                STORE   ANGX
                EXIT

                TC      PHASCHNG
                OCT     01001

RESETGTS        CAF     ZERO
                TS      ANGY
                TS      ANGY +1
                TS      ANGZ
                TS      ANGZ +1
                TS      SAVE
                CS      A
                TS      GEOCOMPS
                TC      GOAGAIN

GOGAZCHK        TC      SETUPER
                INHINT
                CAF     ONE
                TS      GEOCOMPS
                CAF     1SEC
                TC      WAITLIST
                2CADR   GAZCHECK

                RELINT
                TC      +3

ENDGCHK         CCS     FILDELVY
                TC      +4
                TC      PHASCHNG
                OCT     00601
                TC      ENDOFJOB

                CAF     ZERO
                TS      GTSOPNDZ
                TC      ESTIMS

RECALCAX        CCS     FILDELVY
                TC      CALCANGX
                CCS     FILDELVZ
                TC      CALCANGX
                TC      SETUPER
                INHINT
                CAF     1SEC
                TC      WAITLIST
                2CADR   GAZCHECK

                RELINT
                TC      CALCANGX

SETUPER         EXTEND                  # SUBROUTINE CALLED IN 3 PLACES
                QXCH    QPLACES
                TC      INTPRET
                CALL
                        ERTHRVSE
                EXIT
                TC      BANKCALL
                CADR    OGCZERO
                TC      QPLACES

OPTMSTRT        INDEX   PHASE1
                TC      +0
                TC      GTSGTS1
                TC      GTSGTS2
                TC      GTSGTS3
                TC      GTSGTS4
                TC      GTSGTS5
                TC      GTSGTS6
                TC      GTSGTS7
                TC      GTSGTS10
                TC      GTSGTS11


GTSGTS1         CAF     PRIO20
                TC      FINDVAC
                2CADR   RSTGTS1

                TC      SWRETURN
GTSGTS2         CAF     ONE
                TC      WAITLIST
                2CADR   ALLOOP1

                TC      SWRETURN
GTSGTS3         CAF     ONE
                TC      WAITLIST
                2CADR   ALLOOP

                TC      SWRETURN
GTSGTS4         CAF     PRIO20
                TC      FINDVAC
                2CADR   GOAGAIN

                TC      SWRETURN
GTSGTS5         CAF     PRIO20
                TC      FINDVAC
                2CADR   RETORQIN

                TC      SWRETURN
GTSGTS6         CAF     ONE
                TC      WAITLIST
                2CADR   GAZCHECK

                TC      SWRETURN

GTSGTS7         CAF     PRIO20
                TC      FINDVAC
                2CADR   RECALCAX

                TC      SWRETURN
GTSGTS10        CAF     PRIO20
                TC      FINDVAC
                2CADR   RESETGTS

                TC      SWRETURN
GTSGTS11        CAF     PRIO20
                TC      FINDVAC
                2CADR   REALFLT

                TC      SWRETURN

GEOBND          OCT     02000           #  BANK 4  -THIS IS THE STORE DTA SECTION
GEOBND1         OCT     02400           # BANK NUMBER 5


STOREDTA        CAF     GEOBND
                TS      L
                CAF     BIT7
                TS      MPAC
                INDEX   MPAC
                CA      ALX1S
                LXCH    EBANK
                EBANK=  JETSTEP
                INDEX   MPAC
                TS      JETSTEP
                LXCH    EBANK
                EBANK=  XSM
                CCS     MPAC
                TCF     +2
                TC      Q
                TS      MPAC
                CAF     GEOBND
                TS      L
                TCF     STOREDTA +4


LOADSTDT        CAF     BIT7
                TS      MPAC
                CA      GEOBND
                XCH     EBANK
                TS      L
                EBANK=  JETSTEP
                INDEX   MPAC
                CA      JETSTEP
                LXCH    EBANK
                EBANK=  XSM
                INDEX   MPAC
                TS      ALX1S
                CCS     MPAC
                TCF     +2
                TC      Q
                TS      MPAC
                TCF     LOADSTDT +2

# OPTICAL VERIFICATION ROUTINES FOR GYROCOMPASS

GCOMPVER        TC      NEWMODEX
                OCT     10
                TC      BANKCALL
                CADR    MKRELEAS
                CAF     ONE
                TS      GTSOPNDZ

                TC      BANKCALL
                CADR    OPTDATA2

                CAF     ONE
                TS      LENGTHOT
                INHINT
                CAF     10SECS
                TC      WAITLIST
                2CADR   GCOMP2

                RELINT
                CAF     LGCOMP3
                TC      JOBSLEEP

GCOMP2          CAF     LGCOMP3
                TC      JOBWAKE
                TC      TASKOVER

GCOMP3          CAF     ONE
                TS      DSPTEM1
                CAF     TWO
                TS      DSPTEM1 +1
                CAF     V06N30E
                TC      NVSBWAIT
                CAF     TWO
                TC      BANKCALL
                CADR    SXTMARK
                TC      BANKCALL
                CADR    OPTSTALL
                TC      GTSOPTCS

                TC      INTPRET
                CALL
                        TAR/EREF
                VLOAD   MXV
                        6
                        XSM
                VSL1
                STOVL   STARAD
                        12D
                MXV     VSL1
                        XSM
                STORE   STARAD +6D
                LXC,1   AXT,2
                        MARKSTAT
                        2
                XSU,2   SXA,2
                        X1
                        S1
                CALL
                        SXTNB
                CALL
                        NBSM
                STORE   LOSVEC

                LXC,1   INCR,1
                        MARKSTAT
                DEC     -7
                AXT,2   XSU,2
                        2
                        X1
                SXA,2   CALL
                        S1
                        SXTNB
                CALL
                        NBSM
                STOVL   12D
                        LOSVEC
                STCALL  6D
                        AXISGEN
                CALL
                        CALCGTA
                EXIT

GCOMP4          CAF     V06N60E
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      GCOMP5
                TCF     +2
                TCF     GCOMP4

                TC      INTPRET
                VLOAD   VAD
                        OGC
                        ERCOMP
                STORE   ERCOMP
                EXIT

GCOMP5          CAF     ONE
                TS      FILDELVX
                TC      BANKCALL
                CADR    MKRELEAS
                TC      NEWMODEX
                OCT     07
                TC      ENDOFJOB

GTSOPTCS        TC      ALARM
                OCT     01603
                TC      GCOMP5

LGCOMP3         CADR    GCOMP3
V06N30E         OCT     00630
V06N60E         OCT     00660
10SECS          DEC     1000

ENDPREL1        EQUALS
