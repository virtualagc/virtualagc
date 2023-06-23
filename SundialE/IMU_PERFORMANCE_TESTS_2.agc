### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_PERFORMANCE_TESTS_2.agc
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


                BANK    17
                EBANK=  XSM



IMUTEST         CA      ZERO
                TS      DRIFTT
                TS      GEOCOMPS
                TS      SINGAZ
                TS      SINGAZ +1
                TS      COSGAZ +1
                CAF     HALF
                TS      COSGAZ
GEOIMUTT        TC      INTPRET         # OPTIMUM COMPASS COMES IN HERE
                CALL
                        LATAZCHK
                EXIT
                CA      ONE
                TS      POSITON

                TS      DSPTEM2 +2
                CA      ZERO
                TS      THETAD +2
                TC      BANKCALL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
IMUBACK         CA      ZERO
                TS      DSPTEM2 +1
                TS      NDXCTR
                TS      TORQNDX
                TS      TORQNDX +1
                CAF     TESTTIME
                TS      DSPTEM2
                CAF     ZERO
                TS      THETAD +2
                TC      BANKCALL        # ISS RETURNS IN COARSE ALIGN MODE TO
                CADR    IMUCOARS        # ENABLE OPERATOR TO DECIDE WHAT TO DO
# ABOUT GIMBAL LOCK

                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
                TC      SHOWLD
                TC      SHOW
                TC      NBPOSPL
                TC      POSGMBL
                TC      PIPACHK         # IF MGA IS 60DEG+ PROG WILL STAY IN COARS
                                        # ALIGN AND MEASURE VERITCAL PIPA RATE
                TC      FALNE
                TC      BANKCALL

                CADR    IMUSTALL
                TCF     ENDTEST1

GUESS           TC      INTPRET         # CALCULATE -COS LATITUDE AND SIN LATITUDE
                DLOAD   COS             # FOR ESTIMATE
                        LATITUDE
                DCOMP   SL1
                STODL   WANGI
                        LATITUDE
                SIN     SL1
                STORE   WANGO           # LOAD TRANSITION MATRIX INTO ERASABLE
                EXIT
JUMPLOAD        TC      LOADGTSM
                TC      BANKCALL
                CADR    ESTIMS
TORQUE          TC      PHASCHNG        # FILTER TORQUES PLTFM AND SETS UP ERATE
                OCT     00000

                TC      INTPRET
                CALL
                        ERTHRVSE
                EXIT

                TC      BANKCALL
                CADR    OGCZERO

                CA      ZERO
                TS      DSPTEM2
                CA      DRIFTI
                TS      DSPTEM2 +1
                INDEX   POSITON
                TS      SOUTHDR -1
                TC      SHOW

PIPACHK         INDEX   NDXCTR          # TORQUE PLATFORM TO CORRECT  LEVELING ERR
                TC      +1              # IN PREPARATION TO MEASURING VERTICAL
                TC      BANKCALL        # PIPA OUTPUT PULSE RATE
                CADR    EARTHR

                CA      BIT10           # IN THE ALLOTED TIME INTERVAL
                TS      LENGTHOT
                CA      ONE
                TS      RESULTCT
                CA      ZERO            # ZERO PIPA COUNTER INITIALLY
                INDEX   PIPINDEX
                TS      PIPAX
                TS      DATAPL
                TS      DATAPL +4
                CA      DEC18           #  LOOP 18 TIMES 5.12 SEC "ACH. EACH INCR.
                TC      WAITLOOP        # WILL ALSO CORRECT EARTH RATE
                INDEX   RESULTCT
                TC      +1
                CA      A
                INHINT
                TC      CHECKG
                RELINT
                TC      DATALD
                CA      FIVE
                TS      RESULTCT
                INDEX   NDXCTR
                TC      +1
                TC      BANKCALL
                CADR    EARTHR
                CCS     COUNTPL
                TC      WAITLP2
                INHINT
                TC      CHECKG
                RELINT
                TC      DATALD
                EXTEND
                DCS     DATAPL
                DAS     DATAPL +4

                TC      INTPRET
                DLOAD   DSU
                        DATAPL +6
                        DATAPL +2
                PDDL    DDV
                        DATAPL +4
                SL4
                PDDL    DMP
                        DEC585
                RTB
                        SGNAGREE
                STORE   DSPTEM2
                EXIT
                TC      SHOW
VERTDRFT        CA      3998DEC         # NUMBER OF SECONDS TO SPEND ESTIMATING
                TS      LENGTHOT
                INDEX   POSITON
                CS      SOUTHDR -2
                TS      DRIFTT
                TC      LOADGTSM
                TC      BANKCALL        # THIS WILL CORRECT FOR EARTH RATE DURING
                CADR    EARTHR          # TIME SPENT IN SHOW ABOVE*
                CA      CDUX            # STOORE AXIS  FOR LAB CALC OF DRIFT
                TS      LOSVEC
                CA      ZERO            # ALLOW ONLY SOUTH GYRO EARTH RATE COMPENS
                TS      XSM
                TS      XSM +1
                TS      XSM +4
                TS      XSM +5
                TS      YSM
                TS      YSM +1

                TS      YSM +4
                TS      YSM +5
                TS      ZSM
                TS      ZSM +1
                TS      ZSM +4
                TS      ZSM +5
GUESS1          CAF     POSMAX
                TS      TORQNDX
                TS      TORQNDX +1
                TC      BANKCALL
                CADR    ESTIMS
                TC      VALMIS

OPCHK           CAF     DELYOFF         # AUTOMATIC TEST FOR SYSTEM OPERATION
                EXTEND
                RAND    30              # CHECK TO SEE IF IMU IS ON
                CCS     A
                TC      ALARMS
                CAF     V16N20S
                TC      NVSBWAIT

                TC      FREEDSP
                TC      BANKCALL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL

                TCF     ENDTEST1
                CA      BIT8            # ZERO ALL ERASEABLE USED IN TEST
                TS      ZERONDX
                CA      GENPLAD
                TC      ZEROING
                TC      NBPOSPL         # ALIGN ANGLE COMPUTATION

                TC      POSGMBL         # COARSE ALIGN THOSE GIMBALS NOW
                TC      ABORT

                TC      FALNE           # FINE ALIGN PLATFORM BY TORQUING GYROS

                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
                CA      TWO
CDUCHECK        TS      CDUNDX          # THIS LOOP CHECKS FOR NO ERROR BETWEEN
                INDEX   CDUNDX          # DESIRED CDU ANGLES AND THE ACTUAL ANGLES
                CS      THETAD
                INDEX   CDUNDX
                AD      CDUX
                TS      STOREPL
                CCS     STOREPL
                TC      ERRMASK
                TC      NOERR
                TC      ERRMASK
NOERR           CCS     CDUNDX
                TC      CDUCHECK
                TC      LOADIC
ERRMASK         MASK    LOWTWO          # ALLOW THREE BIT ERRORS
                CCS     A
                TC      ALARMS
                TC      NOERR
LOADIC          CA      ONE
                TS      RESULTCT
                CS      ONE

                TS      MASKREG         # SETS UP AZIMUTH AND VERTICAL VECTORS FOR

                CA      ZERO
                TS      PIPAX
                TS      PIPAY
                TS      PIPAZ

                CA      BIT13
                TS      LENGTHOT        # VECTOR IN PIPA COUNTERS
                CA      ONE
                TC      WAITLOOP
                CCS     COUNTPL
                TC      WAITLP2
                CA      DEC13
                TC      WAITLOOP
OPCHK1          CA      TWO
OPCHK2          TS      PIPINDEX
                INHINT
                TC      CHECKG
                RELINT
                CA      ZERO
                INDEX   PIPINDEX
                TS      PIPAX
                TC      DATALD          # LOAD PIPA DATA AND TIME IN DATAPL
                XCH     RESULTCT
                AD      FOUR
                TS      RESULTCT
                CCS     PIPINDEX
                TC      OPCHK2
READOUT         CS      FOUR
                AD      RESULTCT
                TS      RESULTCT
                ZL
                INDEX   RESULTCT
                CA      DATAPL
                LXCH    A
                INDEX   RESULTCT
                DAS     GENPL +1
                CA      RESULTCT
                MASK    MASKREG
                CCS     A
                TC      READOUT
                CA      TEN
                AD      THREE
                TS      RESULTCT
                CS      A
                TS      MASKREG
                CCS     COUNTPL
                TC      WAITLP2
                TC      COMPUT
RADCK           TCF     ENDTEST1        # NO RADAR IN CM

ALARMS          XCH     Q
                TS      QPLACE
                TC      ALARM
                OCT     1411
                TC      QPLACE

GYRSFTST        TC      INTPRET         # START ADRESS FOR IRIG SF TEST
                CALL
                        LATAZCHK        # LOAD AZ AND LAT
                EXIT
TESTCALL        CAF     V21N30E
                TC      NVSBWAIT        # LOAD + OR - 1 FOR + OR - X TEST (+00001)
                TC      ENDIDLE         # LOAD + OR - 2 FOR + OR - Y TEST
                TCF     ENDTEST1        # LOAD + OR - 3 FOR + OR - Z TEST
                TC      TESTCALL
                XCH     DSPTEM1
                TS      CALCDIR
                EXTEND                  # THIS ROUTINE LOOKS AT THE SIZE OF THE
                BZMF    NEGSIZ          # ENTRY MADE BY THE OPERATOR, IF HE DID NO
SIZLOOK         MASK    NEG3            # T ENTER TEST NO THAT IS W/I PERMISSIBLE
                EXTEND                  # RANGE- HE WILL BE ASKED TO LOAD AGAIN.
                BZF     GUDENT1         #   THIS IS CONSIDERED NECESSARY BECAUSE
                TC      TESTCALL        # OF FOLLOWING INDEXED TC WHICH COULD

NEGSIZ          COM                     # SEND THE COMPUTER OFF INTO THE BOONDOCKS
                TC      SIZLOOK         # TO PLAY WITH ITSELF IF THE OPERATOR
GUDENTRY        CA      CALCDIR         # MAKES ABAD ENTRY******
                AD      FOUR
                INDEX   A
                TC      +1
                TC      TESTCALL
                TC      +6              # C(A)=+00001 FOR -Z
                TC      +4              # C(A)=+00002 FOR -Y
                TC      +2              # C(A)=+00003 FOR -X
                TC      -4              # C(A)=+00004   ERROR
                TC      +3              # C(A)=+00005 FOR +X
                TC      +6
                TC      +10
                CAF     FOUR
                TS      POSITON         # 4 IS FOR A.L. POSN 4 USED FOR X SF TEST
                TC      +7
                TC      +6
                CAF     TWO
                TS      POSITON         # +2 IS A.L. POS 2 USED FOR Y SF TEST
                TC      +3
                CAF     ONE
                TS      POSITON         # +1 IS A.L. POS 1 USED FOR Z SF TEST
                TS      OPTNREG         # C(K) = (4,2,1) FOR X,Y,Z
                TS      SAVE +1
                TC      FREEDSP
                CAF     ZERO
                TS      NBPOS           # SET UP NB COORD TO Z NORTH, X UP
                TS      SAVE +2         # INITIALIZE FOR EARTHR DESIGNATE USAGE
                TS      TESTNO          # INITIALIZE FOR TEST ABORT ROUTINE
                TS      CDUFLAG         # ZEROS FOR STRTWACH USE
                CAF     SFCONST

                TS      SFCONST1        # FOR DIVISION DURING CALCFSE

                TC      BANKCALL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
                TC      NBPOSPL
                TC      POSGMBL
                TCF     ENDTEST1
                TC      FALNE
                TC      BANKCALL
                CADR    REDYTORK
WAITFIVE        TS      SOUTHDR
                CAF     BIT6            # THIS SECTION CALLS FOR 2-32 MSEC WAITS
                TC      DIRECTN -5
ENABLE          CAF     BIT6
                EXTEND                  # ENABLE GYRO TORQUING LOOP BY TURNING
                WOR     14C             # ON CAL MODULE RELAY

                INHINT
                CS      TWO             # SETS UP EXEC SWITCH SO IMUPULSE WILL
                MASK    IMODES33        # NOT TURN OFF GYRO TORQ ENABLE RELAY
                AD      TWO
                TS      IMODES33
                CAF     TWO
                TS      SOUTHDR
                TS      LENGTHOT        #  20 MSEC DELAY FOR GYRO LOOP STABILIZAT.
                CA      ONE
                TC      WAITLOOP
                CCS     COUNTPL
                TC      WAITLP2
DIRECTN         TC      BANKCALL        #  TORQUING ROUTINE IN IMU PERFORMANCE
                CADR    SILVER          #    BANK 3
                CCS     SOUTHDR         # A ONE FIRST TIME THROUGH, THEN ZERO
                TC      WAITFIVE

STRTWACH        CCS     CDUFLAG         #  RETURNS HERE VIA QPLACE FROM SILVER
                TC      CDUZOTST        # BEEN CAUGHT AND CDU THROUGH ZERO IS
                CCS     SAVE +1
                TC      LOOKCDUP -4
                TC      LOOKCDUP
CORRECT         CAF     ZERO
                TS      LGYRO           #  RELEASES GYROS FOR IMUPULSE USAGE
                TC      BANKCALL        # EARTHRATE CORRECTION TO GYROS NOT EAST
                CADR    EARTHR          # OR WEST
                CAF     ONE
                TS      LGYRO           # RESERVES GYROS FOR S.F. TEST TORQUING
                TS      SAVE +2         # INITIALIZES TO INSURE 5.6 DEG OF TORQ)
                ADS     TESTNO          # INCR THE BURST COUNTER, WHICH IS USED TO

                CS      TESTNO          # COUNT THE NO. OF ITMES THE GYRO COUNTER
                MASK    FIVE            # IS LOADED, IF A TENTH LOAD IS REQUESTED
                EXTEND                  # THE SFE IS TOO LARGE TO BE MEANINGFULL
                BZF     STOPTEST        # OR THE CDU,S ARE NOT WORKING.
                TC      DIRECTN

                CAF     ZERO            # ZEROS CDU REG WHICH WILL BE USED TO
                TS      SAVE +1
                INDEX   CDUNDX          # MEASURE ANGLE.
                TS      CDUX
LOOKCDUP        INHINT
                CAF     BIT5
STILLOOK        TS      TIMER
                INDEX   CDUNDX          # LOOKS FOR FIRST CDU PULSE AFTER TORQUING
                CCS     CDUX            # STARTS
                TC      OUTPLUS         # HERE IS PLUS PULSE
                TC      TIMEWACH
                TC      ALARMS          # TTELL OPERATOR FIRST CDU PULSE WAS MISSD
                TC      OUTNEG          # HERE IS MINUS PULSE
TIMEWACH        CCS     TIMER           # WATCHES TIME IN INHINT SO COPS WILL NOT
                TC      STILLOOK        # CATCH US
                RELINT

                CCS     NEWJOB
                TC      CHANG1
                TC      LOOKCDUP        # KEEP WATCHING IF THE PULSE IS NOT HERE

OUTPLUS         CS      DESANGLE        # -2047 CDU PULSES ADDED TO CDU REG SO
                INDEX   CDUNDX          # ZERO CROSSOVER CAN BE DETECTED
                TS      CDUX
LOADFLAG        CAF     ONE
                TS      CDUFLAG
                CA      GYROCTR         # GYRO TORQ CMDS LEFT OUT OF FIRST 5.625
                TS      SAVE            # DEG COMMANDED WHEN CDU PULSE ARRIVED
                RELINT
                TC      CDUZOTST

OUTNEG          CA      DESANGLE
                INDEX   CDUNDX
                TS      CDUX
                TC      LOADFLAG

CDUZOTST        INDEX   CDUNDX
                CCS     CDUX
                TC      +4
                TC      ENDWATCH
                TC      +2
                TC      ENDWATCH
                CAF     BIT10           # RAND WITH BIT 10 TO SEE IF STILL TORQ.
                EXTEND

                RAND    14C
                CCS     A
                TC      +6

                CCS     SAVE +2         # SEE IF 2.8DEG OR 5.6 DEG SINCE LAST
                TC      +2              #EEARTHR USE, IF 2.8 DEG, DO 2.8 MORE
                TC      CORRECT         #  THEN GO TO CORRECT
                TS      SAVE +2
                TC      DIRECTN
                CCS     NEWJOB
                TC      CHANG1
                TC      CDUZOTST

ENDWATCH        INHINT                  # WWILL STOR GYROCTR AT END OF 2048 CDU
                CAF     ZERO            # PULSES AND STOP TORQ BY ZEROING REQUESTS
                TS      LGYRO           #  RELEASE GYROS FOR OTHERS USAGE
                XCH     GYROCTR
                TS      SAVE +1         # AND STOPS TORQUING BY ZEROING TORQ
                CS      TWO
                MASK    IMODES33        # THIS TURNS OFF EXEC SWITCH SO THE GYRO
                TS      IMODES33        # TORQ. ENABLE RELAY CAN BE TURNED OFF.
                RELINT
CALCSFE         CA      SAVE            # GYROCTR AT TEST START
                EXTEND
                SU      SAVE +1         # GYROCTR AT TEST END
                TS      SAVE +2
                EXTEND
                BZMF    ARITH           # SEE IF IT IS NEG OR ZERO,IF NEG,SFE IS +
                MASK    SIZCHK
                EXTEND                  # THIS ROUTINE TESTS SAVE-(SAVE+1) TO SEE
                BZF     NEGSFE          # IF THE RESULT IS WITHIN PERMISSIBLE SIZE
                CS      SAVE +2         # AND DETERMINES POLARITY OF SFE USING THE
                MASK    SIZCHK          # PRESENCE OR ABSENCE OF BITS 12,13,14.
                EXTEND                  # IF BITS ARE PRESENT IN POSITIVE SAVE +2
                BZF     POSSFE          # THEN THE SFE MUST BE POS. IF DIFFERENCE
                TC      STOPTEST        # IS GREATER THAN 2047 PULSES FROM THE
NEGSFE          CAE     SAVE +2         # IDEAL NO OF PULSES, THE SFE EXCEEDS
                TC      ARITH           # 15600 PPM, THE TEST IS NOT VALID AND

# THEREFORE ABORTS AND TURNS ON PROGRAM ALARM
POSSFE          CAF     POSMAX          # POS SFE DEFINITION = IRIG SF IN SEC OF
                EXTEND                  # ARC PER PULSE IS GREATER THAN
                SU      SAVE +2         # .61798095703125  SEC OF ARC/ PULSE
                TC      ARITH +1

ARITH           COM
                ZL
                EXTEND
                DV      SFCONST1
LOADIT          TS      DSPTEM2

                TC      DATADSP

DATADSP         TC      GRABDSP
                TC      PREGBSY
                CA      CALCDIR
                TS      DSPTEM2 +2      # DISPLAYS TEST NO JUST PERFORMED
                CAF     VB06N66         #  R3 = TEST NO JUST PERFORMED
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE         # TO END TEST DO V34E
                TC      +2
                TC      TESTCALL        # TO CONTINUE TEST DO V33E
STOPTST1        TC      BANKCALL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
                TCF     ENDTEST1

STOPTEST        TC      ALARM
                OCT     1604
                CAF     ZERO
                TS      LGYRO           # **** RELEASE GYROS FOR OTHERS USAGE*****
                TC      STOPTST1
                TC      BANKCALL
                CADR    ENDTEST1

CHECKG          EXTEND                  # PIP PULSE CATCHING ROUTINE
                QXCH    QPLACE          # RECORDS TIME AT OCCURRENCE OF A DELTA V
CHECKG1         RELINT                  # KEEPS CONTENT OF PIPA REG INTACT
                CCS     NEWJOB
                TC      CHANG1
                INHINT
                CAF     ZERO
                INDEX   PIPINDEX
                XCH     PIPAX
                TS      STOREPL
                CCS     STOREPL
                TC      CHECKP
                TC      RESTOREA
                TC      CHECKM
                TC      RESTOREA
CHECKP          CAF     BIT6            # LOOKS FOR ONE MORE PLUS PULSE
                TS      PIPANO
                INDEX   PIPINDEX
                CCS     PIPAX
                TC      CHECKG3
                TC      +3
                TC      RESTOREA
                TC      +1
                CCS     PIPANO
                TC      CHECKP +1
                TC      RESTOREA
CHECKM          CAF     BIT6            # LOOKS FOR ONE MORE MINUS PULSE
                TS      PIPANO
                INDEX   PIPINDEX
                CCS     PIPAX
                TC      RESTOREA
                TC      +3
                TC      CHECKG3
                TC      +1
                CCS     PIPANO
                TC      CHECKM +1
                TC      RESTOREA
CHECKG3         TC      FINETIME        # TIME IN DOUBLE PRECISION LEFT IN MPAC

                DXCH    MPAC
                CAF     BIT4
CHECKG5         TS      PIPANO
                INDEX   PIPINDEX
                CCS     PIPAX
                TC      +4
                TC      RESTOREA
                TC      +2
                TC      RESTOREA
                CCS     PIPANO
                TC      CHECKG5

NREAD           TC      RESTORE
                TS      STOREPL
                TC      QPLACE
RESTORE         XCH     STOREPL         # A WILL CONTAIN PREVIOUS PIPA CNTR CONTEN
                INDEX   PIPINDEX        # STOREPL WILL CONTAIN ZERO
                AD      PIPAX
                INDEX   PIPINDEX
                TS      PIPAX
                TC      Q

RESTOREA        TC      RESTORE
                TC      CHECKG1
DATALD          CA      STOREPL
                INDEX   RESULTCT
                TS      DATAPL
                CA      MPAC
                INDEX   RESULTCT
                TS      DATAPL +1
                CA      MPAC +1
                INDEX   RESULTCT
                TS      DATAPL +2
                TC      Q





POSGMBL         EXTEND                  # COARSE ALIGNING SUBROUTINE
                QXCH    QPLACE

                TC      INTPRET
                CALL
                        CALCGA
                EXIT

                TC      BANKCALL
                CADR    IMUCOARS
                CA      GMLOCKCK        # IF FAILREG CONTAINS 401 WILL RETURN TO
                MASK    FAILREG
                CCS     A               # L +1, OTHERWISE TO L +2.
                TC      LOCK
                INCR    QPLACE
                TC      +3
LOCK            CA      TWO
                TS      NDXCTR
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
                TC      QPLACE
GMLOCKCK        OCT     00401

FALNE           EXTEND                  # TORQUES GYROS TO NULL OVT DIFFERENCE
                QXCH    QPLACE          # BETWEEN DESIRED SM ORIENTATION WITH RESP
                TC      BANKCALL        # TO NBASE AND ACTUAL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
                TC      BANKCALL
                CADR    IMUFINE
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTEST1
FALNE1          CA      CDUX
                INDEX   FIXLOC
                TS      24
                CA      CDUY
                INDEX   FIXLOC
                TS      20
                CA      CDUZ
                INDEX   FIXLOC
                TS      22
                CA      BIT5
                AD      FIXLOC
                INDEX   FIXLOC
                TS      S1
                TC      INTPRET
                VLOAD   MXV
                        XSM
                        STARAD
                VSL1
                STCALL  32D
                        NBSM
                STOVL   XDC
                        YSM
                MXV     VSL1
                        STARAD
                STCALL  32D
                        NBSM
                STOVL   YDC
                        XDC
                VXV     VSL1
                        YDC
                STCALL  ZDC
                        CALCGTA
                EXIT
                CA      OGCPL
                TC      BANKCALL
                CADR    IMUPULSE
                TC      QPLACE

WAITLOOP        EXTEND                  # LOOPS IN X SEC INCREMENTS FOR NUMBER OF
                QXCH    QPLAC
                TS      COUNTPL         # NUMBER PUT INTO LENGTHOT
WAITLP1         CCS     COUNTPL
                TC      +2
                TC      QPLAC
                INHINT
                CAE     LENGTHOT
                TC      WAITLIST
                2CADR   WAITLP3
                RELINT
                TC      QPLAC

WAITLP2         TS      COUNTPL         # ENTER HERE AFTER DOING CALLING JOB
                CAF     WTLPCADR
                TC      JOBSLEEP
WTLPCADR        CADR    WAITLP1
WAITLP3         CAF     WTLPCADR
                TC      JOBWAKE
                TC      TASKOVER





ZEROING         TS      L
                TCF     +2
ZEROING1        TS      ZERONDX
                CAF     ZERO
                INDEX   L
                TS      0
                INCR    L
                CCS     ZERONDX
                TCF     ZEROING1
                TC      Q
COMPUT          TC      INTPRET         # CALCULATE LENGTH OF GRAVITY VECTOR AS
                AXT,1   AXT,2           # MEASURED BY ACCELEROMETERS
                        22D
                        10D
                SSP
                        S1
                        4
                SSP
                        S2
                        4

LOPDELOP        DLOAD*  DSU*
                        DATAPL +24D,2
                        DATAPL +24D,1
                PDDL*   DMP
                        GENPL +24D,2
                        DEC585
                DDV     SL4
                TIX,2   VDEF
                        NEXT
                ABVAL   RTB
                        SGNAGREE
                STCALL  DSPTEM2
                        KODU
NEXT            PUSH    TIX,1
                        LOPDELOP
KODU            EXIT
                TC      GRABWAIT
                TC      SHOW
                TC      INTPRET
                SLOAD   PUSH
                        DATAPL +1
                SLOAD   PUSH
                        DATAPL +5
                SLOAD   VDEF
                        DATAPL +11
                UNIT    VSL1
                PUSH
                SLOAD   PUSH
                        DATAPL +15
                SLOAD   PUSH
                        DATAPL +21
                SLOAD   VDEF
                        DATAPL +25
                UNIT    VSL1
                PDDL    DSU
                        DATAPL +26
                        DATAPL +12
                SL4
                SL3
                STOVL   LENGTHOT
                VXV     ABVAL
                DMP     DDV
                        ERUNITS
                        LENGTHOT
                RTB
                        SGNAGREE
                STORE   DSPTEM2
                EXIT
                TC      SHOW
                TCF     RADCK

NBPOSPL         EXTEND                  # SETS UP AZIMUTH AND VERTICAL VECTORS FOR
                QXCH    QPLACE          # AXISGEN,RESULTS TO BE USED IN CALCGA TO
                TC      INTPRET
                AXC,1   XSU,1           # AZIMUTH IN NB COORDS
                        SCNBAZ
                        NBPOS
                VLOAD*
                        0,1
                STORE   STARAD

                AXC,1   XSU,1           # VERITCAL IN NB COORDS
                        SCNBVER
                        NBPOS
                VLOAD*
                        0,1
                STODL   STARAD +6
                        ZERODP
                STODL   6D
                        AZIMUTH
                COS     DCOMP
                STODL   8D
                        AZIMUTH
                SIN
                STORE   10D             # VERTICAL IN CER
                VLOAD
                        SCNBVER
                STCALL  12D
                        AXISGEN
                EXIT

SELPOSN         CA      DEC17
                TS      ZERONDX
                CA      XSMADR
                TC      ZEROING

                INDEX   POSITON
                TC      +1
                TC      OPCHKPOS        # OPCHK WILL PUT ZERO IN POSITON
                TC      POSN1
                TC      POSN2
                TC      POSN3
                TC      POSN4
                TC      POSN5
                TC      POSN6
                TC      POSN7
                TC      POSN8
                TC      POSN9
                TC      POSN10
                TC      POSN11
                TC      POSN12
                TC      POSN13
                TC      POSN14
                TC      POSN15
                TC      POSN16

# WE WILL DENOTE THE FLASHING DISPLAY OF A HORIZONTAL TEST BY DH
# (XXX.XX MERU) AND A VERTICAL TEST BY DV (XXX.XX MERU) EACH POSITION TELL
# HOW THE DISPLAYS ARE RELATED TO TTHE DRIFT COEFFICIENTS BEING MEASURED.
# NOTE THAT IT IS ILLEGAL TO RUN VERTICAL IN POS 6,4, OR 2 WITHOUT FIRST
# RUNNING HORIZONTAL OF POS 5,3, OR1. THIS IS BECAUSE THE HORIZ DRIFT CALC
# IN 1,3, OR 5 IS USED AS EAST DRIFFFT FOR VERTICAL TEST. THIS IS DONE BY
# THE MACHINE AUTOMATICALLY EXCEPT FOR VERTICAL POSITION 6 WHICH THE
# OPERATOR MUST DO. (SEE POSITION 6 BELOW)
POSN1           CA      HALF            # X UP, Y SOUTH, Z EAST
                TS      XSM
                TS      YSM +2          #   NBDY = DH
                TS      ZSM +4
NGUBGH          CA      ZERO
                TS      PIPINDEX
                TC      QPLACE



POSN2           CS      HALF            # X DOWN, Y WEST, Z NORTH
                TS      XSM
                TS      YSM +4          #  NBDZ =DH ,NBDX -ADIAX= -DV
                TS      ZSM +2
                TC      NGUBGH



POSN3           CA      HALF            # Z UP, Y WEST ,X NORTH
                TS      ZSM
                COM                     #  NBDX = -DH
                TS      XSM +2
                TS      YSM +4
NSFLAGD         CA      TWO
                TS      PIPINDEX
NSBUGD          CA      ZERO
                TS      DRIFTT
                TC      QPLACE



POSN4           CS      HALF            # Y SOUTH, X EAST, Z DOWN
                TS      ZSM             #  NBDY +ADSRAY=DH
                TC      INTPRET         #  NBDZ +ADIAZ =DV
                DLOAD
                        SINGAZ
                STORE   YSM +4
                DCOMP
                STODL   XSM +2
                        COSGAZ
                STORE   YSM +2
                STORE   XSM +4
                EXIT
NSFLAG          CA      TWO
                TS      PIPINDEX
                TC      QPLACE

POSN5           CA      HALF            # Y UP, Z NORTH, X WEST
                TS      YSM
                COM                     #  NBDZ-ADSRAZ =DH
                TS      XSM +4
                TS      ZSM +2
                CA      ONE
                TS      PIPINDEX
                TC      NSBUGD



# TO RUN POSITION 6 VERTICAL AFTER PIP TEST POS 6 IS DISPLAYED THE OPERATR
# MUST CALCULATE FROM 2.5 -NBDZ-ADSRAZ  (XXX.XX)MERU.    WHEN PI
# IP DATA FLASHES DO VERB 33 ENTER. THIS STARTS VERTICAL TEST. THEN THE
# DATA XXX.XX MERU AS CALCULATED MUST BE ENTERED INTO DRIFTT. IE VERB 21
# ENTER NOUN 01 ENTER LOCATION OF DRIFTT ENTER + (OR -) XXXXX ENTER
POSN6           CA      HALF            # Y DOWN, Z EAST, X SOUTH
                TS      XSM +2
                TS      ZSM +4
                COM                     #  NBDX +ADSRAX = DH, NBDY -ADIAY = -DV
                TS      YSM
NGFLAG          CA      ONE
                TS      PIPINDEX
                TC      QPLACE



POSN7           CS      HALF            # Z UP-EAST,Y UP-WEST,X NORTH.THIS POSITON
                TS      XSM +2
                CA      ROOT1/2
                TS      YSM             #  NBDX - .707 ADSRAX = -DH
                TS      ZSM
                TS      ZSM +4
                COM
                TS      YSM +4
GEORGES         CA      ZERO
                TS      FAILREG
                TC      NSBUGD



POSN8           CA      HALF            # Z UP-SOUTH,Y UP-NORTH,X EAST.THIS POSITN
                TS      XSM +4
                CA      ROOT1/2         #  .707(-NBDZ-NBDY) +.5(ADIAZ-ADIAY)
                TS      YSM             # +.5(ADSRAY +ADSRAZ)=DH
                TS      ZSM +2
                TS      ZSM
                COM
                TS      YSM +2
                TC      NSBUGD

OPCHKPOS        CA      ROOT1SQ         # OG=+45DEG,IG=-45DEG,MG=+45DEG.
                TS      XSM
                TS      YSM +2
                TS      YSM +4
                TS      ZSM
                CA      ROOT1/2
                TS      YSM
                CA      ROOT3SQ
                TS      XSM +2
                TS      ZSM +4
                CS      ROOT2SQ
                TS      XSM +4
                TS      ZSM +2
                TC      QPLACE

POSN9           CA      HALF            # X UP EAST,Y UP WEST,Z SOUTH.THIS POSITON
                TS      ZSM +2
                CA      ROOT1/2         #  -NBDZ +.707 SRAZ =DH
                TS      XSM
                TS      XSM +4
                TS      YSM
                COM
                TS      YSM +4
                TC      NSBUGD



POSN10          CA      HALF            # X UP NORTH, Y UP SOUTH,Z EAST.THIS POSITN
                TS      ZSM +4
                CA      ROOT1/2         #   .707(NBDY -NBDX) +.5(ADIAY -ADIAX)
                TS      XSM             #  +.5(ADSRAX) = DH
                TS      YSM
                TS      YSM +2
                COM
                TS      XSM +2
                TC      NSBUGD



POSN11          CA      HALF            # X NORTH, Y WEST, Z DOWN
                TS      XSM +2
                COM
                TS      YSM +4
                TS      ZSM
                TC      NSFLAGD

POSN12          CS      HALF            # X DOWN, Y NORTH, Z WEST
                TS      XSM
                TS      ZSM +4
                COM
                TS      YSM +2
                TC      NGUBGH

POSN13          CS      HALF            # X UP, Y EAST, Z SOUTH
                TS      ZSM +2
                COM
                TS      XSM
                TS      YSM +4
                TC      NGUBGH

POSN14          CS      HALF            # X EAST, Y DOWN, Z SOUTH
                TS      YSM
                TS      ZSM +2
                COM
                TS      XSM +4
                TC      NGFLAG

POSN15          CS      HALF            # X NORTH, Y UP, Z WEST
                TS      ZSM +4
                COM
                TS      YSM
                TS      XSM +2
                TC      NGFLAG

POSN16          CS      HALF            # X WEST, Y NORTH, Z UP
                TS      XSM +4
                COM
                TS      YSM +2
                TS      ZSM
                TC      NSFLAG

SHOWLD          CA      DSPTEM2
                TS      LENGTHOT
                CA      DSPTEM2 +1
                TS      NBPOS
                CA      DSPTEM2 +2

                TS      POSITON
                TC      Q

SHOW            EXTEND
                QXCH    QPLACE
SHOW1           CA      POSITON
                TS      DSPTEM2 +2
                CA      VB06N66
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      FINISH
                TC      QPLACE
                TC      SHOWLD
                TCF     SHOW1



LOADGTSM        EXTEND                  # THIS LOADS XSM INTO GEOMATRX
                QXCH    QPLACE
                TC      INTPRET
                VLOAD
                        XSM
                STOVL   GEOMTRX
                        YSM
                STOVL   GEOMTRX +6
                        ZSM
                STORE   GEOMTRX +12D
                EXIT
                TC      QPLACE

14C             EQUALS  0014
V21N30E         OCT     02130
DESANGLE        DEC     2048
SFCONST         DEC     .13107
SIZCHK          OCT     34000
180DEC          DEC     180
3998DEC         DEC     3998
VB06N66         OCT     00666
TESTTIME        DEC     900
V16N20S         OCT     01620
V16N40S         OCT     01640
DEC17           DEC     17
DEC585          2DEC    585 B+15
DELYOFF         OCT     00400
ERUNITS         2DEC    342844 B-28
GENPLAD         GENADR  AZIMUTH
GYRODPL         ECADR   GYROD
OGCPL           ECADR   OGC
LOWTWO          OCT     77774
DEC18           DEC     18
45DEG           OCT     10000
ROOT1/2         DEC     .353553
ROOT1SQ         DEC     .250000
ROOT2SQ         DEC     .426776
ROOT3SQ         DEC     .073223
XSMADR          GENADR  XSM

SCNBAZ          2DEC    0
                2DEC    0
                2DEC    .50

LABNBAZ         2DEC    .27232
                2DEC    0
                2DEC    .4194335

SCNBVER         2DEC    .5
                2DEC    0
                2DEC    0

LABNBVER        2DEC    .4194335
                2DEC    0
                2DEC    -.27232

DEC13           DEC     13

## MAS 2023: The following two functions are unreferenced, and appear
## to be broken. It is unclear what their original purpose was.
U17,3706        CAF     BIT11
                TS      EBANK
                INDEX   QCSI
                TC      QCSI

U17,3712        CAF     BIT11
                AD      BIT9
                TS      EBANK
                INDEX   GENPL
                TC      GENPL

VALMIS          TC      PHASCHNG
                OCT     00000
                CA      DRIFTO
                TS      DSPTEM2 +1
                CA      CDUX            # STORE OG ANGLE FOR LAB CALC OF DRIFT**
                TS      LOSVEC +1
                CA      ZERO
                TS      DSPTEM2
                TC      SHOW



FINISH          CA      ONE
                AD      POSITON
                TS      DSPTEM2 +2
                CA      TWO
                TS      QPLACE
                TC      BANKCALL
                CADR    TSELECT -6
ENDTEST1        TC      BANKCALL
                CADR    ENDTEST

GUDENT1         CA      ZERO
                TS      SINGAZ
                TS      SINGAZ +1
                TS      COSGAZ +1
                CAF     HALF
                TS      COSGAZ
                TCF     GUDENTRY

ENDIMUS2        =
