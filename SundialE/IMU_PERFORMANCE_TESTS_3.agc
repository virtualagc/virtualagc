### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_PERFORMANCE_TESTS_3.agc
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


                BANK    14
                EBANK=  XSM

SAMODCHK        CAF     ZERO
                TS      RUN

                TC      ZEROMODE
                TC      OPRTRDLY

                CAF     ZERO
                TC      THETADLD

                CAF     45ANG
                TC      THETADLD

                TC      FNZEROFN

                CAF     71ANG
                TC      THETADLD

                CAF     90ANG
                TC      THETADLD

                CAF     135ANG
                TC      THETADLD

                CAF     45ANG
                TC      THETADLD +2

                TC      FNZEROFN

                CS      135ANG
                TC      THETADLD

                CS      45ANG
                TC      THETADLD +2

                TC      FNZEROFN

                CS      45ANG
                TC      THETADLD

                TC      FNZEROFN

                CS      71ANG
                TC      THETADLD

                CAF     ZERO
                TC      THETADLD

                CAF     IMUADRS
                TS      IMU/OPT

                CAF     TWO
CHK2            TS      CDUNDX

                CAF     170ANG
                INDEX   CDUNDX
                TS      THETAD

                TC      BANKCALL
                CADR    IMUCOARS

                CAF     10ANG
                TC      CDURATE

                CAF     160ANG
                TC      CDURATE

                TC      CALCRATE

                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                CAF     ZERO
                INDEX   CDUNDX
                TS      THETAD

                TC      BANKCALL
                CADR    IMUCOARS

                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                EXTEND
                DIM     IMU/OPT

                CCS     CDUNDX
                TCF     CHK2

                TC      FINEZERO
                TC      FINEZERO

                CAF     ZERO
                TC      THETADLD

                CAF     OPTADRS
                TS      IMU/OPT

                CAF     ONE
CHK3            TS      CDUNDX
                
                CS      TRUNZERO
                TS      DESOPTT

                INDEX   CDUNDX
                CAF     RATECMD
                INDEX   CDUNDX
                TS      DESOPTT

                CAF     ZERO
                TS      OPTIND

                INDEX   CDUNDX
                CAF     RATEPT1
                TC      CDURATE

                CCS     CDUNDX
                TCF     CHK4

                CA      CDUREADF
                EXTEND
                MP      BIT13
                TS      CDUREADF

CHK4            INDEX   CDUNDX
                CAF     RATEPT2
                TC      CDURATE

                CCS     CDUNDX
                TCF     CHK5

                CA      CDUREADF
                EXTEND
                MP      BIT13
                TS      CDUREADF

CHK5            TC      CALCRATE
                EXTEND
                DIM     IMU/OPT
                CCS     CDUNDX
                TCF     CHK3

ENDTST03        TC      BANKCALL
                CADR    ENDTEST


RATECMD         OCT     11031
                OCT     37777

RATEPT1         OCT     62514
                OCT     01615

RATEPT2         OCT     07213
                OCT     34344


THETADLD        TS      THETAD
                TS      THETAD +1
                TS      THETAD +2

                EXTEND
                QXCH    QPLACE

                CAF     SEVEN
THLD1           TS      STOREPL

                TC      BANKCALL
                CADR    IMUCOARS
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                CCS     STOREPL
                TC      THLD1

                TC      OPRTRDLY

                TC      QPLACE


OPRTRDLY        EXTEND
                QXCH    QPLAC

                INCR    RUN
                CAF     V06N20X
                TC      NVSBWAIT
                CA      A
                CA      A
                CS      BIT5
                AD      RUN
                EXTEND
                BZMF    +3
                CAF     OPTRUN
                TCF     +2
                CA      RUN
                MASK    6LOW
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDTST03
                TCF     +2
                TCF     OPRTRDLY +3

                TC      FLASHOFF
                TC      QPLAC



CH30DSPY        EXTEND
                QXCH    QPLACE

                CAF     OCT30
                TS      MPAC +2
                CAF     V01N10X
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDTST03
                TCF     +2
                TCF     CH30DSPY +2

                TC      FLASHOFF
                TC      QPLACE



CDURATE         EXTEND
                QXCH    QPLACE

                TS      CDULIMIT

                CCS     NEWJOB
                TC      CHANG1

                CS      CDULIMIT
                INDEX   IMU/OPT
                AD      0               # CATCH FIRST PULSE
                EXTEND
                BZMF    CDURATE +3      # LOOK AGAIN

                INDEX   IMU/OPT
                CAE     0
                XCH     CDUREADF        # CDU FINAL READING
                XCH     CDUREADI        # CDU INITIAL READING

                TC      FINETIME
                DXCH    CDUTIMEF        # DP FINAL TIME
                DXCH    CDUTIMEI        # DP INITIAL READING

                RELINT
                TC      QPLACE




CALCRATE        EXTEND
                QXCH    QPLACE

                DXCH    CDUREADF
                EXTEND
                MSU     L
                TS      CDUANG

                TC      INTPRET
                DLOAD   DSU
                        CDUTIMEF
                        CDUTIMEI
                PUSH    SLOAD
                        CDUANG
                SR      DDV
                        14D
                DMP     RTB
                        DEG/SEC
                        SGNAGREE
                STORE   DSPTEM2

                EXIT

RATEDSP         CAF     V06N66X
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDTST03
                TCF     +2
                TCF     RATEDSP

                TC      QPLACE


ZEROMODE        EXTEND
                QXCH    QPLACE

                TC      BANKCALL
                CADR    IMUZERO
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                TC      QPLACE




ZEROMAIN        CS      4+6BITS
                EXTEND
                WAND    12

                CAF     BIT5
                EXTEND
                WOR     12

                TC      Q



FINEALGN        EXTEND
                QXCH    QPLACE

                TC      BANKCALL
                CADR    IMUFINE
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                TC      QPLACE



FINEZERO        EXTEND
                QXCH    QPLAC

                TC      BANKCALL
                CADR    IMUZERO

                CAF     TWO
                TS      EROPTN
                CAF     FOUR
                TS      POSITON

                INHINT
                CS      BIT10
                MASK    STATE
                AD      BIT10
                TS      STATE
                RELINT


                TC      BANKCALL
                CADR    CSMLAB

SAMODRTN        TC      GRABWAIT

                TC      ZEROMAIN
                
                CAF     BIT11
                TC      WAITLIST
                EBANK=  XSM
                2CADR   DSPY30
                
                CAF     CH30WAKE
                TC      JOBSLEEP

DSPY30          CAF     CH30WAKE
                TC      JOBWAKE
                TC      TASKOVER

DSPYCH30        TC      CH30DSPY
                TC      ZEROMODE
                
                TC      QPLAC


FNZEROFN        EXTEND
                QXCH    QPLAC

                TC      FINEALGN

                CAE     CDUX
                TS      CDUREADF
                CAE     CDUY
                TS      CDUREADI
                CAE     CDUZ
                TS      CDULIMIT

                TC      ZEROMODE

FZF2            CAE     CDUREADF
                EXTEND
                MSU     CDUX
                TS      DSPTEM1

                CAE     CDUREADI
                EXTEND
                MSU     CDUY
                TS      DSPTEM1 +1

                CAE     CDULIMIT
                EXTEND
                MSU     CDUZ
                TS      DSPTEM1 +2

FZFDSP          CAF     V05N30X
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TCF     ENDTST03
                TCF     +2
                TCF     FZFDSP

                INCR    RUN
                TC      QPLAC

TRUNZERO        OCT     16037
45ANG           OCT     10000
71ANG           OCT     14477
90ANG           OCT     20000
135ANG          OCT     30000
10ANG           OCT     01616
160ANG          OCT     34344
170ANG          OCT     36162

6LOW            OCT     77
2,4,6           OCT     00052
4,6,9           OCT     00450
BIT13-15        OCT     70000
OCT30           OCT     30
OPTRUN          OCT     55
4+6BITS         OCT     00050

V01N10X         OCT     00110
V05N30X         OCT     00530
V06N30X         OCT     00630
V06N20X         OCT     00620
V06N66X         OCT     00666
V33N00X         OCT     03300

IMUADRS         ADRES   CDUZ
OPTADRS         ADRES   OPTX

ATERWAKE        CADR    ATTERCMD
QPLACADR        GENADR  QPLAC
TAKEWAKE        CADR    TAKEOUT
NXTTWAKE        CADR    NEXTTAKE
TVCSWAKE        CADR    TVCSETUP
TVCOWAKE        CADR    TVCOUT
CH30WAKE        CADR    DSPYCH30

DEG/SEC         2DEC    576000 B-28



CTRLDISP        CAF     ZERO
                TS      RUN

                TC      ZEROMODE

                CAF     ZERO
                TC      THETADLD

                CAF     ZERO
                TS      TESTNO

ATTERROR        CS      4+6BITS
                EXTEND
                WAND    12

                CAF     FOUR
                TC      WAITLIST
                2CADR   ATTERR

                CAF     ATERWAKE
                TC      JOBSLEEP

ATTERR          CAF     ATERWAKE
                TC      JOBWAKE
                TC      TASKOVER

ATTERCMD        CS      BIT6
                AD      BIT2
                AD      TESTNO
                EXTEND
                BZMF    +2
                TCF     TAKEOVER

                TC      THETADER
                CAF     BIT6
                EXTEND
                WOR     12

                INHINT
                CAF     TWO
                TC      WAITLIST
                2CADR   FDAIOUT
                RELINT

                TC      THETADSP

                CAF     THREE
                ADS     TESTNO
                TCF     ATTERROR

TAKEOVER        CAF     ZERO
                TC      THETADLD

                CAF     ZERO
                TS      TESTNO
                TC      CH30DSPY

TAKEOVR1        CS      4,6,9
                EXTEND
                WAND    12

                INHINT
                CAF     BIT7
                TC      WAITLIST
                2CADR   TAKE

                CAF     TAKEWAKE
                TC      JOBSLEEP

TAKE            CAF     TAKEWAKE
                TC      JOBWAKE
                TC      TASKOVER

TAKEOUT         CS      BIT6
                AD      BIT2
                AD      TESTNO
                EXTEND
                BZMF    +2
                TCF     TVCTEST

                CAF     BIT9
                EXTEND
                WOR     12

                CAF     BIT5
                TC      WAITLIST
                2CADR   ICDUEN

                CAF     NXTTWAKE
                TC      JOBSLEEP

ICDUEN          CAF     BIT6
                EXTEND
                WOR     12

                TC      THETADER

                EXTEND
                INDEX   TESTNO
                DCA     IMUANGLE
                DXCH    CDUXCMD
                INDEX   TESTNO
                CAF     IMUANGLE +2
                TS      CDUZCMD

                CAF     TWO
                TC      VARDELAY

                CAF     BIT13-15
                EXTEND
                WOR     14

                CAF     NXTTWAKE
                TC      JOBWAKE
                TC      TASKOVER

NEXTTAKE        TC      THETADSP
                CAF     THREE
                ADS     TESTNO
                TCF     TAKEOVR1

TVCTEST         CAF     ZERO
                TC      THETADLD

                CAF     ZERO
                TS      TESTNO

                CAF     THREE
                TS      THETAD +2

                CAF     BIT5
                EXTEND
                RAND    33
                CCS     A
                TCF     +2
                TC      FALTON
                TC      CH30DSPY

                CAF     FOUR
                ADS     QPLACE
                INCR    MPAC +2
                TC      CH30DSPY +4

TVCENABL        CS      2,4,6
                EXTEND
                WAND    12
                
                CAF     BIT8
                EXTEND
                WOR     12
                
                CAF     BIT5
                TC      WAITLIST
                2CADR   TVCS

                CAF     TVCSWAKE
                TC      JOBSLEEP

TVCS            CAF     TVCSWAKE
                TC      JOBWAKE
                TC      TASKOVER

TVCSETUP        CS      TEN
                AD      TESTNO
                EXTEND
                BZMF    +2
                TCF     TVCOVER

                CAF     BIT2
                EXTEND
                WOR     12
                INDEX   TESTNO
                CAF     TVCANGLE
                TS      THETAD
                TS      OPTYCMD
                COM
                TS      THETAD +1
                TS      OPTXCMD

                CAF     TWO
                TC      WAITLIST
                2CADR   TVCWAIT

                CAF     TVCOWAKE
                TC      JOBSLEEP

TVCWAIT         CAF     TVCOWAKE
                TC      JOBWAKE
                TC      TASKOVER

TVCOUT          CAF     11,12
                EXTEND
                WOR     14
                TC      THETADSP
                INCR    TESTNO
                TCF     TVCENABL

TVCOVER         CS      BIT8
                EXTEND
                WAND    12
                TC      THETADSP
                TC      ENDTST03

IMUANGLE        DEC     +385
                DEC     -385
                DEC     +385

                DEC     +384
                DEC     -384
                DEC     +384

                DEC     +160
                DEC     -160
                DEC     +160

                DEC     +135
                DEC     -135
                DEC     +135

                DEC     +90
                DEC     -90
                DEC     +90

                DEC     +0
                DEC     +0
                DEC     -90

                DEC     -90
                DEC     +90
                DEC     -135

                DEC     -135
                DEC     +135
                DEC     -160

                DEC     -160
                DEC     +160
                DEC     -384

                DEC     -384
                DEC     +384
                DEC     -385

                DEC     -385
                DEC     +385
                DEC     +0

TVCANGLE        DEC     +385
                DEC     +384
                DEC     +160
                DEC     +135
                DEC     +90
                DEC     +0
                DEC     -90
                DEC     -135
                DEC     -160
                DEC     -384
                DEC     -385

THETADSP        EXTEND
                QXCH    QPLAC
                CA      THETAD
                TS      DSPTEM1
                CA      THETAD +1
                TS      DSPTEM1 +1
                CA      THETAD +2
                TS      DSPTEM1 +2
                CAF     V06N30X
                TCF     OPRTRDLY +4

THETADER        EXTEND
                INDEX   TESTNO
                DCA     IMUANGLE
                DXCH    THETAD
                INDEX   TESTNO
                CAF     IMUANGLE +2
                TS      THETAD +2
                TC      Q

FDAIOUT         CA      THETAD
                TS      CDUXCMD
                CA      THETAD +1
                TS      CDUYCMD
                CA      THETAD +2
                TS      CDUZCMD
                TC      IBNKCALL
                CADR    ATTCK3


SILVER          EXTEND
                QXCH    QPLACE          #  SHOULD BE ADDRESS OF STRTWACH

                CCS     CALCDIR         # 2F COMMAND IS POSITIVE THE MINUS TORQ
                CAF     BIT9            #  WINDING IS TO BE ENERGIZED
                TC      +2
                TC      TORK            #  COMMAND IS NEG SO USE PLUS WINDING
                EXTEND
                WOR     14C             #  SELECTS THE MINUS WINDING

TORK            CAF     POSMAX
                TS      GYROCTR         # 16383 PULSES =2.8125 DEG LESS ONE PULSE

                CCS     GYTOBETQ        # C(K)= 1 FOR X, -0 FOR Y, -1FOR Z.
                TC      SELECTX
                TC      CCSHOLE
                TC      SELECTZ
                TC      SELECTY
SELECTX         CAF     TORKX           # BBITS 7AND 10 IN CHANNEL 14 WILL
                EXTEND                  #  SELECT X GYRO AND TURN ON BCSW 1/3200
                WOR     14C             # SSEC LATER BY CHANNEL OUTPUT DESIGN.....
                TC      QPLACE

SELECTY         CAF     TORKY           # BBITS 8 AND 10 TO TORQ Y GYRO
                EXTEND
                WOR     14C
                TC      QPLACE

SELECTZ         CAF     TORKZ           # BBITS 7,8AND 10 TO TORQZ GYRO
                EXTEND
                WOR     14C
                TC      QPLACE
TORKX           OCT     01100
TORKY           OCT     01200
TORKZ           OCT     01300

REDYTORK        TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                TC      BANKCALL
                CADR    OGCZERO

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

SAUTOIFS        CA      ZERO
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

2ENTRY          CA      LOW8            # CHANNEL 6 RETURNS HERE
                EXTEND
                INDEX   TEMP
                WRITE   5
                CA      FIVE
                AD      TEMP
                TS      MPAC +2
3ENTRY          CA      V05N30D         # CH11,12 RETURN HERE TO USE THE DISPLAY
                TC      NVSBWAIT
                CAF     V01N10D
                TC      NVSBWAIT
                CAF     WAITER          # WAITER IS 03300
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      ENDTST03
                TC      BACK1
CHAN5D          CA      FIVE
                TS      DSPTEM1 +2
                TC      2ENTRY

CHAN6D          INCR    DSPTEM1 +2
                INCR    TEMP
                CAF     ZERO
                EXTEND
                WRITE   5               # GET RID OF CHANNEL 5 BITS
                TC      2ENTRY
CHAN11D         CA      OCT11
                TS      MPAC +2
                CAF     ZERO
                EXTEND
                WRITE   6
                CA      BIT13
                TS      DSPTEM1
                EXTEND
                WOR     11              # WOR IS NON EXCLUSIVE OR
                TC      3ENTRY
CHAN12D         INCR    MPAC +2
                CS      BIT13
                EXTEND
                WAND    11
                CA      CH12BITS
                TS      DSPTEM1
                EXTEND
                WOR     12
                TC      3ENTRY
PTITRDE         CS      CH12BITS
                EXTEND
                WAND    12
                TC      ENDTST03

OCT11           OCT     11
CH12BITS        OCT     30000
V01N10D         OCT     00110
V05N30D         OCT     00530
WAITER          OCT     03300


SUMERASE        CAF     SUMEBADR
                TS      MPAC +2
                CAF     V25N01E
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      ENDTST03
                TC      ENDTST03
                CAF     ZERO
                TS      ERASUM
                CA      SUMEBANK
                TS      EBANK

SUMELOOP        INDEX   SUMADDR
                CA      0
                AD      ERASUM
                TS      ERASUM
                TC      +2
                ADS     ERASUM

                CS      SUMADDR
                AD      SUMEND
                EXTEND
                BZF     SUMEDONE
                INCR    SUMADDR
                TC      SUMELOOP

SUMEDONE        CAF     ESUMADR
                TS      MPAC +2
                CAF     V01N01E
                TC      NVSBWAIT
                TC      ENDTST03

V25N01E         OCT     02501
V01N01E         OCT     00101
SUMEBADR        ADRES   SUMEBANK
ESUMADR         ADRES   ERASUM

ENDIMUS3        EQUALS
