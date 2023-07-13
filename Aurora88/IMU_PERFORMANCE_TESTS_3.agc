### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_PERFORMANCE_TESTS_3.agc
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


                SETLOC  ENDPREL1
                EBANK=  XSM



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


SAMODCHK        CAF     ZERO
                TS      TESTNO
                TS      RUN

                TC      ZEROMODE
                TC      OPRTRDLY

                TC      COARZERO

                TC      ZEROMAIN
                TC      OPRTRDLY

                TC      ZEROMODE

                CAF     ZERO
                TC      THETADLD

                CAF     45ANG
                TC      THETADLD

                TC      FNZEROFN

                CAF     90ANG
                TC      THETADLD

                CAF     135ANG
                TC      THETADLD

                CAF     ZERO
                TC      THETADLD +2

                TC      FNZEROFN

                CAF     180ANG
                TS      THETAD
                TS      THETAD +1
                CAF     71ANG
                TC      THETADLD +2

                CAF     225ANG
                TC      THETADLD

                CAF     ZERO
                TC      THETADLD

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

                TC      COARZERO

                CCS     CDUNDX
                TCF     CHK2

                CS      45ANG
                TC      THETADLD

                TC      FNZEROFN

                CS      135ANG
                TS      THETAD
                TS      THETAD +1
                CS      71ANG
                TC      CHK3

                TC      FNZEROFN

                TC      COARZERO

                TC      FINEZERO
                TC      FINEZERO

CHK5            CS      4+6BITS
                EXTEND
                WAND    12
                CAF     FOUR
                TC      WAITLIST
                2CADR   ECE1

                CAF     ECE2CADR
                TC      JOBSLEEP


ECE1            CAF     ECE2CADR
                TC      JOBWAKE
                TC      TASKOVER

ECE2            CS      SIX
                AD      TESTNO
                EXTEND
                BZMF    +2
                TCF     CHKX

                INDEX   TESTNO
                CAF     ERCTRANG
                TS      THETAD
                TS      THETAD +1
                TS      THETAD +2

                CAF     BIT6
                EXTEND
                WOR     12

                INHINT
                CAF     TWO
                TC      WAITLIST
                2CADR   ATTCK2

                RELINT

                TC      OPRTRDLY

                INCR    TESTNO

                TCF     CHK5

CHKX            TC      COARZERO

                CAF     ZERO
                TS      TESTNO

                TC      BANKCALL
                CADR    RRZERO
                TC      BANKCALL
                CADR    RADSTALL
                TCF     ENDTST03

CHK6            INDEX   TESTNO
                CAF     RADECNTR
                TS      TANG +1
                TS      TANG

                TC      INTPRET


                CALL
                        RRDESNB

                TC      BANKCALL
                CADR    RADSTALL
                TCF     ENDTST03

                TC      RROPRDLY

                INCR    TESTNO

                CS      FOUR
                AD      TESTNO
                EXTEND
                BZMF    CHK6

                CAF     ZERO
                TS      TESTNO
                TS      ALTRATE
                TS      ALT
                TS      ALT +1

                CS      ONE
                TS      DIDFLG

CHK7            INDEX   TESTNO
                CAF     RRRATFPS
                TS      FORVEL
                TS      LATVEL

                TC      RROPRDLY

                INCR    TESTNO

                CS      BIT5
                AD      TWO
                AD      TESTNO
                EXTEND
                BZMF    CHK7

ENDTST03        TC      BANKCALL
                CADR    ENDTEST





ERCTRANG        OCT     03013
                OCT     02660
                OCT     01042


                OCT     00000
                OCT     76736
                OCT     75120
                OCT     74765





RADECNTR        OCT     01463
                OCT     01042
                OCT     00000
                OCT     76736
                OCT     76315





RRRATFPS        OCT     00000
                OCT     00001
                OCT     00002
                OCT     00004
                OCT     00010
                OCT     00020
                OCT     00040
                OCT     00100
                OCT     00200
                OCT     00237
                OCT     00400
                OCT     00545
                OCT     00544
                OCT     77540
                OCT     77232


CDURATE         EXTEND
                QXCH    QPLACE

                TS      CDULIMIT

                CCS     NEWJOB
                TC      CHANG1

                CS      CDULIMIT
                INDEX   CDUNDX
                AD      CDUX            # CATCH FIRST PULSE
                EXTEND
                BZMF    CDURATE +3      # LOOK AGAIN

                INDEX   CDUNDX
                CAE     CDUX
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

                INCR    RUN
                TC      QPLACE


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




FINEALGN        EXTEND
                QXCH    QPLACE

                TC      BANKCALL
                CADR    IMUFINE
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                TC      QPLACE


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
                INCR    RUN
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


RROPRDLY        EXTEND
                QXCH    QPLAC

                INCR    RUN

                CAF     V06N40X
                TCF     OPRTRDLY +4




OPRTRDLY        EXTEND
                QXCH    QPLAC

                INCR    RUN
                CAF     V06N20X
                TC      NVSBWAIT
                CAF     V33N00X
                TC      NVSBWAIT
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
                CADR    LEMLAB

SAMODRTN        TC      GRABWAIT

                TCF     +2
                TC      NVSBWAIT

                TC      DSPY30WT

DSPYCH30        TC      CH30DSPY
                TC      ZEROMODE

                TC      QPLAC



COARZERO        CAF     ZERO
                TS      THETAD
                TS      THETAD +1
                TS      THETAD +2

                EXTEND
                QXCH    QPLACE

                TC      BANKCALL
                CADR    IMUCOARS
                TC      BANKCALL
                CADR    IMUSTALL
                TCF     ENDTST03

                TC      QPLACE


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

                TCF     FZF2
                TC      WAITLIST
                2CADR   FZF1

                CAF     FZF2CADR
                TC      JOBSLEEP

FZF1            CAF     FZF2CADR
                TC      JOBWAKE
                TC      TASKOVER

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


1ANG            OCT     00133
33.75ANG        OCT     06000
45ANG           OCT     10000
71ANG           OCT     14477
90ANG           OCT     20000
135ANG          OCT     30000
10ANG           OCT     01616
160ANG          OCT     34344
180ANG          OCT     40000
225ANG          OCT     50000
170ANG          OCT     36162

6LOW            OCT     77
OCT30           OCT     30
3SEC            DEC     300
4+6BITS         OCT     00050

V01N10X         OCT     00110
V05N30X         OCT     00530
V06N20X         OCT     00620
V06N40X         OCT     00640
V06N66X         OCT     00666
V33N00X         OCT     03300

ECE2CADR        CADR    ECE2
FZF2CADR        CADR    FZF2
OGCECADR        ECADR   OGC

DEG/SEC         2DEC    576000 B-28

## MAS 2023: The following chunks of code (down to ENDIMUS3) were added as patches
## between Aurora 85 and Aurora 88. They were placed here at the end of the bank
## so as to not change addresses of existing symbols.

DSPY30WT        TC      ZEROMAIN
                CAF     BIT11
                TC      WAITLIST
                EBANK=  XSM
                2CADR   DSPY30

                CAF     CH30WAKE
                TC      JOBSLEEP

DSPY30          CAF     CH30WAKE
                TC      JOBWAKE
                TC      TASKOVER

CH30WAKE        CADR    DSPYCH30



CHK3            EXTEND
                QXCH    QPLACES

                TC      THETADLD +2

                CAF     ZERO
                TC      THETADLD +2

                TC      QPLACES

ENDIMUS3        EQUALS
