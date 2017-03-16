### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MAIN.agc
## Purpose:     Part of the source code for SUPER JOB, a program developed
##              at Raytheon to exercise the Auxiliary Memory for the AGC.
##              It appears to have been developed from scratch, and shares
##              no heritage with any programs from MIT. It was also built
##              with a Raytheon assembler rather than YUL or GAP.
## Reference:   pp. D-4 - D-35
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     https://www.ibiblio.org/apollo/index.html
## Page Scans:  http://www.ibiblio.org/apollo/Documents/R68-4125-Volume2.pdf
## Mod history: 2017-01-27 MAS  Created and transcribed, then corrected
##                              errors until assembly succeeded. Octals
##                              have not yet been extracted, so errors
##                              almost certainly remain.
##              2017-01-28 MAS  Corrected errors found by counting lines
##                              on each page (there should be 58).
##              2017-01-29 MAS  Fixed a few errors identified during
##                              octal transcription.
##              2017-01-30 MAS  Fixed a transcription error in the octals
##                              noticed while transcribing the inline
##                              assembled octals. There are probably more
##                              of those left, but for now the assembly
##                              matches the binsource.
##              2017-02-02 MAS  Did a quick visual proofing pass over the
##                              comments and fixed a few errors.
##              2017-03-14 MAS  Fixed a comment text typo.

## Page D-4 (continued)
                SETLOC  FF024000
GOJAM           INHINT                  # 4000
                TC      GOJAMPR         # 4001
VBCDEL          OCT     00021           # VERB CODE
ONE             OCT     00001
T6RUPT          RESUME                  # 4004
ZERO            OCT     00000
D520            OCT     01010
VBB             OCT     50000           # CODE TO BLANK DSKY VERB
T5RUPT          RESUME                  # 4010
THIRTY          OCT     00030
FIRST5          OCT     00037
ENTRCDEL        OCT     00034           # ENTER CODE
## Page D-5
T3RUPT          TCF     T3RPTPR         # 4014
TWO             OCT     00002
HGHTST+1        OCT     00032           # HIGHEST TEST +1
BLANKNRL        OCT     00360
T4RUPT          TCF     T4RPTPR         # 4020
OC17            OCT     00017
D10             OCT     00012
CENTERL         OCT     01740
K1RUPT          TCF     KYPROC1L        # 4024
OPERCDL         OCT     00100           # CODE FOR OPERATOR ERROR
FLASHL          OCT     00040
NOFLASHL        OCT     77737
K2RUPT          TCF     KYPROC2L        # 4030
MDISPLA         TC      UPDISPLA        # XFER TO DISPLAY FOR MIKE
JMPTBL          TC      V01             # TURN ON ACM AND ATM
                TC      V02             # TURN ON ACM
                TC      V03             # TURN OFF ACM AND ATM
                TC      V04             # TURN OFF ATM
                TC      V05             # TURN ATM FROM ON TO STANDBY
                TC      V0607           # DSKY  DEMONSTRATION  NO ERRORS
                TC      V0607           # DSKY  DEMONSTRATION  CORRECTABLE
                TC      V08             # UNCORRECTABLE ERROR LOCATION 3000
                TC      V09             # 4 BANKS WITH SUM CHECK
                TC      V10             # CORRECTABLE ERRORS
                TC      V11             # SHORT TAPE BANK
                TC      V12             # LONG TAPE BANK
                TC      V13             # NONEXISTENT TAPE BANK
                TC      V14             # SINGLE BANK TRIPLEX
                TC      V15             # SINGLE BANK SIMPLEX
                TC      V16             # 4 BK XFER WITH 1 BK REWRITE
                TC      V17             # AM PARITY GOJAM
                TC      V18             # GENERATE TC TRAP GOJAM
                TC      V19             # GENERATE RUPTLOC GOJAM
                TC      V20             # GENERATE NWATCH  GOJAM
                TC      V21             # MU 4  4000 WORD PROGRAM
                TC      V22             # PAC TO MU4 TO MU5 TO ATM TO MU5 CHK
                TC      +0              #       V23
                TC      +0              #       V24
                TC      +0              #       V25
VB0F            OCT     52025           # CODE FOR 0 LEAST SIG DIGIT
                OCT     52003           # CODE FOR 1 LEAST SIG DIGIT
                OCT     52031           # CODE FOR 2 LEAST SIG DIGIT
                OCT     52033           # CODE FOR 3 LEAST SIG DIGIT
                OCT     52017           # CODE FOR 4 LEAST SIG DIGIT
                OCT     52036           # CODE FOR 5 LEAST SIG DIGIT
                OCT     52034           # CODE FOR 6 LEAST SIG DIGIT
                OCT     52023           # CODE FOR 7 LEAST SIG DIGIT
                OCT     52035           # CODE FOR 8 LEAST SIG DIGIT
                OCT     52037           # CODE FOR 9 LEAST SIG DIGIT
V0BF            OCT     53240           # CODE FOR 0 MOST SIG DIGIT
                OCT     52140           # CODE FOR 1 MOST SIG DIGIT
                OCT     53440           # CODE FOR 2 MOST SIG DIGIT
                OCT     53540           # CODE FOR 3 MOST SIG DIGIT
                OCT     52740           # CODE FOR 4 MOST SIG DIGIT
                OCT     53700           # CODE FOR 5 MOST SIG DIGIT
                OCT     53600           # CODE FOR 6 MOST SIG DIGIT
                OCT     53140           # CODE FOR 7 MOST SIG DIGIT
                OCT     53640           # CODE FOR 8 MOST SIG DIGIT
## Page D-6
                OCT     53740           # CODE FOR 9 MOST SIG DIGIT
KYPROC1L        DXCH    ARUPT           # START PROCESSING MAIN DSKY
                EXTEND
                QXCH    QRUPT
                EXTEND
                READ    CH15
                TC      PROCL
KYPROC2L        DXCH    ARUPT           # START PROCESSING NAV DSKY
                EXTEND
                QXCH    QRUPT
                EXTEND
                READ    CH16
PROCL           MSK     FIRST5
                TS      TEMP1L          # STORE DSKY OUTPUT CODE
                CS      TEMP1L
                AD      ERRSTL          # ERROR RESET CODE
                CCS     A               # WAS ERROR RESET HIT+
                TC      +6              # NO
                TC      MERR
                TC      +4              # NO
                CA      ZEROS           # YES
                TS      SWITCH
                TC      PRERSTL
                CS      TEMP1L
                AD      VBCDEL          # VERB CODE
                CCS     A               # WAS VERB HIT
                TC      NONVERBL        # NO
                TC      MERR            # NO
                TC      NONVERBL        # NO
                CA      ZEROS           # YES
                TS      SWITCH
                EXTEND
                READ    CH27            # CLEAR CONIN
                CA      FEXTA           # LOAD BITS 7 AND 6 IN FEXT
                EXTEND
                WRITE   CH7
                CA      ONE
                TS      VERBFFL
                CA      ZERO
                TS      VERBREGL        # CLEAR TEST NO
                TS      ZZTAG
                TS      DCNTL           # CLEAR DIGIT COUNTER
VBBLNK          CA      VBB
                EXTEND
                WRITE   CH10            # BLANKS VERB ON DSKY
CH10RST         CA      D520            # START OF 20MS DELAY TO CLEAR CH 10
                CCS     A
                TC      -1              # ACC IS NOT ZERO
                EXTEND                  # ACC IS ZERO
                WRITE   CH10            # CLEAR CH 10
                TC      RETURNL
PRERSTL         CA      ZERO            # ERROR RESET FROM DSKY
                TS      VERBREGL
                TS      VERBFFL
                TS      DCNTL
                TS      ZZTAG
                EXTEND                  # TURNS FLASH OFF
                READ    CH11
## Page D-7
                MSK     OUTCOML
                EXTEND
                WRITE   CH11
                TC      VBBLNK
NONVERBL        CS      ONE
                AD      ZZTAG
                CCS     A
                TC      +4
                TC      +3
                TC      +2
                TC      ZZPROC
                CCS     VERBFFL         # HAD VERB PREVIOUSLY BEEN HIT
                TC      +4              # YES
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                CS      TEMP1L
                MSK     THIRTY
                CCS     A               # WAS A DIGIT HIT+
                TC      PROCDIGT        # YES
                CS      TEMP1L          # NO
                AD      ENTRCDEL
                CCS     A               # WAS ENTER HIT+
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                CS      DCNTL           # YES
                AD      TWO
                CCS     A               # WERE TWO DIGITS PREVIOUSLY HIT+
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                CCS     VERBREGL        # YES   WAS V00 HIT
                TC      +3              #       NO
                INCR    ZZTAG           #       YES
                TC      V00PROC
                CS      HGHTST+1
                AD      VERBREGL
                CCS     A               # IS VERB CODE LEGAL+
                TC      OPERROR         # NO
                TC      MERR
                TC      +2              # YES
                TC      OPERROR         # NO
                EXTEND
                READ    CH11
                MASK    NOFLASHL
                EXTEND
                WRITE   CH11            # TURNS FLASH OFF
                CA      ZERO
                TS      DCNTL
                TS      VERBFFL
                CA      BLANKNRL
                TS      STATUS
                NDX     VERBREGL
                CA      JMPTBL  -1
                TS      BRUPT
                TC      AMSTAT
                INDEX   VERBREGL
## Page D-8
                CA      STARTBLE -6
                TS      IDSTARTL        # GET IDSTART
                INDEX   VERBREGL
                CA      STOPTBLE -6
                TS      IDSTOPL         # GET IDSTOP
                INDEX   VERBREGL
                CA      CH25TBLE -6
                TS      CH25LOAD        # GET CONOUT TO BE LOADED IN REGISTER
                RESUME
STARTBLE        OCT     00024           # START TABLE   V06
                OCT     04025           #               V07
                OCT     10026           #               V08
                OCT     14124           #               V09
                OCT     20024           #               V10
                OCT     24025           #               V11
                OCT     30026           #               V12
                OCT     34127
                OCT     40001           #               V14
                OCT     50000           #               V15
                OCT     40001           #               V16
4TOGO           OCT     37774
50TOGO          OCT     37716
OUTCOML         OCT     00400
ERRSTL          OCT     00022           # ERROR RESET CODE
                OCT     14020           #               V21
                OCT     51005           #               V22
STOPTBLE        OCT     00000           # STOP TABLE    V06
                OCT     00000           #               V07
                OCT     00000           #               V08
                OCT     00030           #               V09
                OCT     00000           #               V10
                OCT     00000           #               V11
                OCT     00000           #               V12
                OCT     00000           #               V13
                OCT     00006           #               V14
                OCT     00006           #               V15
                OCT     00000           #               V16
ALL7SL          OCT     77777
ALL6SL          OCT     66666
MASKAA          OCT     37
NUMAA           OCT     12
                OCT     00024           #               V21
                OCT     00000           #               V22
CH25TBLE        OCT     02000           # CH 25 LOAD TABLE   V06
                OCT     02000           #               V07
                OCT     02000           #               V08
                OCT     02000           #               V09
                OCT     02000           #               V10
                OCT     02000           #               V11
                OCT     02000           #               V12
                OCT     02000           #               V13
                OCT     03000           #               V14
                OCT     03400           #               V15
                OCT     03000           #               V16
MASKBA          OCT     7
MASKCA          OCT     1740
TIMAA           OCT     1053
TIMBA           OCT     4254
## Page D-9
                OCT     02000           #               V21
                OCT     03000           #               V22
PROCDIGT        CS      ONE
                AD      DCNTL
                CCS     A               # HOW MANY DIGITS HAVE BEEN HIT
                TC      OPERROR         # 3
                TC      MERR
                TC      FRSTDIG         # 1
                INCR    DCNTL           # 2
                CA      TEMP1L
                MSK     OC17
                TS      VERBREGL        # STORE 2ND DIGIT
                NDX     A
                CA      VB0F
                AD      TEMP2L
                EXTEND
                WRITE   CH10            # SENDS BOTH DIGITS TO DSKY
                TS      TEMP4L
                CA      TEMP3L
                EXTEND
                MP      D10
                CA      L
                ADS     VERBREGL
                TC      CH10RST
FRSTDIG         CA      TEMP1L
                MSK     OC17
                TS      TEMP3L
                NDX     A
                CA      V0BF
                EXTEND
                WRITE   CH10
                MSK     CENTERL
                TS      TEMP2L
                INCR    DCNTL
                EXTEND                  # TURNS FLASH ON
                READ    CH11
                MSK     NOFLASHL
                AD      FLASHL
                EXTEND
                WRITE   CH11
                TC      CH10RST
OPERROR         CA      COMOUT
                EXTEND
                RAND    CH11
                AD      OPERCDL
                EXTEND
                WRITE   CH11
                TC      RETURNL
T3RPTPR         DXCH    ARUPT
                EXTEND
                QXCH    QRUPT
                CA      4TOGO
                TS      TIME3
                TS      TIME6
                CA      ZERO
                TS      TIME5
RETURNL         DXCH    ARUPT
                EXTEND
## Page D-10
                QXCH    QRUPT
                RESUME
IDLE            TC      AMSTAT
                TC      -1
T4RPTPR         DXCH    ARUPT
                EXTEND
                QXCH    QRUPT
                CA      50TOGO
                TS      TIME4
                CA      NWATCH
                TC      RETURNL
V18             TC      DISPLAY         # GENERATES TC TRAP GOJAM
                CA      ZERO
                TC      A
                TC      A
V19             TC      DISPLAY         # GENERATES RUPTLOC GOJAM
                INHINT
                CA      A
                TC      -1
V20             TC      DISPLAY         # GENERATES NWATCH GOJAM
                CA      ZERO
                TS      TIME4
                CA      A
                TC      -1
# *               STATUS WORD FOR DISPLAY
# *     9       8       7       6       5       4       3       2       1
# *         BLK NOUN BLK R1    R2      R3 UPDATE NOUN  R1      R2      R3
DISPLAY         CA      Q
                TS      QSTORE
                CA      STATUS
                MASK    MASKA
                CCS     A
                TC      BLANKNA         # BLANK NOUN
                CA      MASKA
                TS      CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      BLANKR1A        # BLANK R1
                CA      TMASKA          # TMASKA CONTAINS LAST CONTENTS OF CYR
                TS      CYR             # RESTORE CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      BLANKR2A        # BLANK R2
                CA      TMASKA          # TMASKA CONTAINS LAST CONTENTS OF CYR
                TS      CYR             # RESTORE CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      BLANKR3A        # BLANK R3
                CA      TMASKA          # TMASKA CONTAINS LAST CONTENTS OF CYR
## Page D-11
                TS      CYR             # RESTORE CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      UPDATENA        # UPDATE NOUN
                CA      TMASKA          # TMASKA CONTAINS LAST CONTENTS OF CYR
                TS      CYR             # RESTORE CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      UPDATE1A        # UPDATE R1
                CA      TMASKA          # TMASKA CONTAINS LAST CONTENTS OF CYR
                TS      CYR             # RESTORE CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      UPDATE2A        # UPDATE R2
                CA      TMASKA          # TMASKA CONTAINS LAST CONTENTS OF CYR
                TS      CYR             # RESTORE CYR
                CA      CYR
                TS      TMASKA
                CA      STATUS
                MASK    TMASKA
                CCS     A
                TC      UPDATE3A        # UPDATE R3
                TC      QSTORE
BLANKNA         CA      Q
                TS      RESUMEA
                CA      ZEROS
                AD      ADDRESSA
                TC      WRITEBA
                TC      RESUMEA
BLANKR1A        CA      Q
                TS      RESUMEA
                CA      ZEROS
                AD      ADDRESSA +1
                TC      WRITEBA
                AD      ADDRESSA +2
                TC      WRITEBA
                AD      ADDRESSA +3
                TC      WRITEBA
                TC      RESUMEA
BLANKR2A        CA      Q
                TS      RESUMEA
                CA      ZEROS
                AD      ADDRESSA +4
                TC      WRITEBA
                AD      ADDRESSA +5
                TC      WRITEBA
                CA      R3
                TS      CYR
                CA      NUMAA
## Page D-12
AAA             TS      NUMA            # SET NUMA EQUAL TO NUMAA FOR CCS E
                CA      CYR             # SHIFT ONCE PLUS NUMA TIMES
                CCS     NUMA
                TC      AAA
                CA      CYR             # SHIFT ONE POSITION
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKAA
                AD      ADDRESSA +6
                TC      WRITEBA
                TC      RESUMEA
BLANKR3A        CA      Q
                TS      RESUMEA
                CA      STATUS
                MASK    MASKR2CA        # IS R2 BLANK
                CCS     A
                TC      BLKR2R3A        # R2 IS BLANK
                CA      R2              # R2 IS NOT BLANK
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKCA
CCA             AD      ADDRESSA +6     # 14000
                TC      WRITEBA
                AD      ADDRESSA +7
                TC      WRITEBA
                AD      ADDRESSA +8
                TC      WRITEBA
                TC      RESUMEA
BLKR2R3A        CA      ZEROS           # BOTH BLANK
                TC      CCA
WRITEBA         EXTEND
                WRITE   CH10
                CA      TIMAA           # 20MS DELAY
                CCS     A
                TCF     -1
                EXTEND
                WRITE   CH10
                CA      TIMBA           # 100MS DELAY
                CCS     A
                TCF     -1
                TC      Q
MASKA           OCT     200
ADDRESSA        OCT     44000
                OCT     40000
                OCT     34000
                OCT     30000
                OCT     24000
                OCT     20000
                OCT     14000
                OCT     10000
                OCT     4000
LOOKUPA         OCT     1265            # 00
                OCT     143             # 11
                OCT     1471            # 22
                OCT     1573            # 33
                OCT     757             # 44
## Page D-13
                OCT     1736            # 55
                OCT     1634            # 66
                OCT     1163            # 77
                OCT     1675            # 88
                OCT     1777            # 99
UPDATENA        CA      Q
                TS      RESUMEA
                CA      NOUN
                TS      ITA
                CA      ADDRESSA
                TS      ADDERA
                TC      ROUTINA
                TC      RESUMEA
UPDATE1A        CA      Q
                TS      RESUMEA
                CA      R1
                TS      ITA
                CA      ADDRESSA +3
                TS      ADDERA
                TC      ROUTINA
                CA      CYR
                CA      CYR
                CA      CYR
                TS      ITA
                CA      ADDRESSA +2
                TS      ADDERA
                TC      ROUTINA
                CA      CYR
                CA      CYR
                CA      CYR
                TS      ITA
                CA      ADDRESSA +1
                TS      ADDERA
                TC      ROUTINA
                TC      RESUMEA
UPDATE2A        CA      Q
                TS      RESUMEA
                CA      ZEROS
                TS      TEMPA
                CA      STATUS
                MASK    MASKR3CA        # IS R3 BLANK+
                CCS     A
                TC      PART2A
                CA      R3
                TS      CYR
                CA      NUMAA
BBA             TS      NUMA            # SET NUMA EQUAL TO NUMAA FOR CCS E
                CA      CYR             # SHIFT ONCE PLUS NUMA TIMES
                CCS     NUMA
                TC      BBA
                CA      CYR             # SHIFT ONE POSITION
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKAA
                TS      TEMPA
PART2A          CA      R2
                MASK    MASKBA
## Page D-14
                INDEX   A
                CA      LOOKUPA
                MASK    MASKCA
                AD      TEMPA
                AD      ADDRESSA +6
                TC      WRITEBA
                CA      R2
                TS      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                TS      ITA
                CA      ADDRESSA +5
                TS      ADDERA
                TC      ROUTINA
                CA      CYR
                CA      CYR
                CA      CYR
                TS      ITA
                CA      ADDRESSA +4
                TS      ADDERA
                TC      ROUTINA
                TC      RESUMEA
UPDATE3A        CA      Q
                TS      RESUMEA
                CA      R3
                TS      ITA
                CA      ADDRESSA +8
                TS      ADDERA
                TC      ROUTINA
                CA      CYR
                CA      CYR
                CA      CYR
                TS      ITA
                CA      ADDRESSA +7
                TS      ADDERA
                TC      ROUTINA
                CA      CYR
                CA      CYR
                CA      CYR
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKAA
                TS      TEMPA
                CA      STATUS
                MASK    MASKR2CA        # IS R2 BLANK+
                CCS     A
                TC      PARTCONA
                CA      R2
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKCA
3CONT           AD      TEMPA
                AD      ADDRESSA +6
                TC      WRITEBA
                TC      RESUMEA
## Page D-15
PARTCONA        CA      ZEROS
                TC      3CONT
ROUTINA         CA      Q               # STANDARD LOOKUP ROUTINE
                TS      GOBAKA
                CA      ITA
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKAA
                TS      TEMPA
                CA      ITA
                TS      CYR
                CA      CYR
                CA      CYR             # SHIFT
                CA      CYR
                MASK    MASKBA
                INDEX   A
                CA      LOOKUPA
                MASK    MASKCA
                AD      TEMPA
                AD      ADDERA
                TC      WRITEBA
                TC      GOBAKA
MASKR3CA        OCT     20
MASKR2CA        OCT     40
AMSTAT          CA      Q
                TS      QSTORE
                CA      BB              # FOR W PICKUP
                TS      A
                EXTEND
                READ    CONOUT
                MASK    MASK1A
                TS      TEMPA
                CS      SUBA
                AD      TEMPA
                CCS     A
                TC      BOTHONA
                TC      MERR
                TC      NOTONA
                TC      ACMONA
BOTHONA         CA      BOTHN1A         # 11
                TC      WRITE1A
NOTONA          CA      NOTON1A         # 00
WRITE1A         TC      WRITEBA
                TC      QSTORE
ACMONA          CA      ACMON1A         # 10
                TC      WRITE1A
TERR            TC      AMSTAT
                EXTEND
                READ    CONOUT
                TS      R2
                CA      MASKA
                EXTEND
                WRITE   CH25
                EXTEND
                READ    CONIN
                TS      R3
                TC      DISPLAY
## Page D-16
                CA      SUPIMPA
                EXTEND
                ROR     CH11
                EXTEND
                WRITE   CH11
                TC      IDLE
V00BK           OCT     34000
SUPIMPA         OCT     40
NOTON1A         OCT     55265           # 00  NOUN
BOTHN1A         OCT     54143           # 11  NOUN
ACMON1A         OCT     54165           # 10  NOUN
MASK1A          OCT     24000
SUBA            OCT     20000
V01             TC      DISPLAY         # TURN ON ACM AND ATM
                CA      COMOUT
                EXTEND
                WRITE   CH11            # SET OUTCOM
                CA      STATUS1A
                TS      STATUS
                CA      C1A
                TS      ACMSTAT
                CA      TIME1A          # 8MSEC
                CCS     A
                TC      -1
                EXTEND
                READ    CONOUT          # CH25
                MASK    BOTEOT6A        # ELIMINATE BITS 5 AND 6
                TS      TEMPA
                CS      OUTCONAA
                AD      TEMPA
                CCS     A
                TC      CONT1A
                TC      CONT1A
                TC      CONT1A
                TC      SUCCESAA
CONT1A          CA      C1A             # ERROR N1 N0 20010
                TS      NOUN
                TC      TERR
SUCCESAA        CA      OC10
                TS      ACMSTAT
                EXTEND
                READ    CH27            # CLEAR VFAIL
                EXTEND
                READ    CH26
                CCS     A
                TC      CONT2A
                TC      SUCCESBA
                TC      CONT2A
                TC      CONT2A
CONT2A          CA      C2A             # ERROR N2 N0 00000
                TS      NOUN
                TC      TERR
SUCCESBA        CA      OUTCONBA
                EXTEND
                WRITE   CONOUT          # CH25
                CA      TIME2A          # 500MSEC
                CCS     A
                TC      -1
## Page D-17
                EXTEND
                READ    CONOUT          # CH25
                MASK    BOTEOT6A        # ELIMINATE BITS 5 AND 6
                TS      TEMPA
                CS      OUTCONCA
                AD      TEMPA
                CCS     A
                TC      CONT3A
                TC      CONT3A
                TC      CONT3A
                TC      SUCCESCA
CONT3A          CA      C3A             # ERROR N3 N0 74000
                TS      NOUN
                TC      TERR
SUCCESCA        TC      AMSTAT
                TC      SUCCESS
V02             TC      DISPLAY         # TURN ON ACM
                CA      COMOUT
                EXTEND
                WRITE   CH11            # SET OUTCOM
                CA      STATUS1A
                TS      STATUS
                CA      C1A
                TS      ACMSTAT
                CA      TIME1A          # 8MSEC
                CCS     A
                TC      -1
                EXTEND
                READ    CONOUT          # CH25
                MASK    BOTEOT6A        # ELIMINATE BITS 5 AND 6
                TS      TEMPA
                CS      OUTCONAA
                AD      TEMPA
                CCS     A
                TC      CONT1A          # ERROR N1 N0 20010
                TC      CONT1A
                TC      CONT1A
                TC      SUCCESDA
SUCCESDA        CA      OC10
                TS      ACMSTAT
                EXTEND
                READ    CH27            # CLEAR VFAIL
                EXTEND
                READ    CH26
                CCS     A
                TC      CONT2A
                TC      SUCCESCA
                TC      CONT2A
                TC      CONT2A          # ERROR N2 N0 0000
V03             TC      DISPLAY         # TURN OFF ACM AND ATM
                CA      ZEROS
                EXTEND
                WRITE   CH11            # OUTCOM OFF
                CA      STATUS2A
                TS      STATUS
                CA      TIME2A          # 1/2 OF 1 SEC.
                CCS     A
                TC      -1
## Page D-18
                CA      TIME2A          # 1/2 OF 1 SEC.
                CCS     A
                TC      -1
                EXTEND
                READ    CONOUT          # CH25
                MASK    BOTEOT6A        # ELIMINATE BITS 5 AND 6
                CCS     A
                TC      TERR
                TC      DDA
                TC      TERR
                TC      TERR
DDA             CA      ZEROS
                TS      ACMSTAT
                TC      SUCCESCA
V04             TC      DISPLAY         # TURN OFF ATM
                CA      OUTCONDA
                EXTEND
                WRITE   CONOUT          # CH25
                CA      STATUS2A
                TS      STATUS
                CA      TIME4A          # 50MSEC
                CCS     A
                TC      -1
                EXTEND
                READ    CONOUT          # CH25
                MASK    BOTEOT6A        # ELIMINATE BITS 5 AND 6
                TS      TEMPA
                CS      OUTCONEA
                AD      TEMPA
                CCS     A
                TC      TERR
                TC      TERR
                TC      TERR
                TC      SUCCESCA
V05             TC      DISPLAY         # TURN ATM TO STANBY
                CA      OUTCONFA
                EXTEND
                WRITE   CONOUT          # CH25
                CA      STATUS2A
                TS      STATUS
                CA      TIME5A          # 200USEC
                CCS     A
                TC      -1
                EXTEND
                READ    CONOUT          # CH25
                MASK    BOTEOT6A        # ELIMINATE BITS 5 AND 6
                TS      TEMPA
                CS      OUTCONGA
                AD      TEMPA
                CCS     A
                TC      TERR
                TC      TERR
                TC      TERR
                TC      SUCCESCA
BOTEOT6A        OCT     77717
COMOUT          OCT     400
STATUS1A        OCT     113
TIME1A          OCT     350             # 8MSEC
## Page D-19
OUTCONAA        OCT     20010
OUTCONBA        OCT     50000
OUTCONCA        OCT     74000
TIME2A          OCT     34000           # 500MSEC
C1A             OCT     1
C2A             OCT     2
C3A             OCT     3
STATUS2A        OCT     303             # R2,R3 UPDATE
OC10            OCT     10
TIME4A          OCT     2640            # 50MSEC
OUTCONDA        OCT     24000
OUTCONEA        OCT     20010
OUTCONFA        OCT     04000
OUTCONGA        OCT     60000
TIME5A          OCT     6
V0607           TC      DISPLAY
                TC      TPTRAN
                TC      2001
                TC      SUCCESS
V08             TC      DISPLAY
                TC      TPTRAN          # GO TO READ TAPE
MU530A          OCT     00030
MU531A          OCT     00031
MU532A          OCT     00032
MU533A          OCT     00033
OCT10A          OCT     00010
AMTOGOA         OCT     00400
STATUS4A        OCT     00207
LAST4A          OCT     07777
BANK536A        OCT     74000
V09             TC      DISPLAY
                TC      TPTRAN
                TC      SUCCESS
V11             TC      DISPLAY
                TC      TPTRAN
                TC      SUCCESS
V12             TC      DISPLAY
                TC      TPTRAN
                TC      SUCCESS
V13             TC      DISPLAY
                TC      TPTRAN
                TC      SUCCESS
V17             TC      DISPLAY
                CA      STATU17A
                TS      STATUS          # LOAD STATUS
                CA      OUTCONGA        # GET FIRST FIXED BANK REG LOAD
STARTBKA        TS      BANKNUMA
                TS      R1              # LOAD R1 WITH BANK REG LOAD
                TS      FB
                CA      OCT77A
                TS      DISYES          # DISPLAY ADDRESS EVERY 100 LOCATIONS
                CA      ZEROS           # START ADDRESS WITH ZEROS
                TS      LOCA
GOA             INDEX   LOCA
                CA      2000            # READ ALL LOCATIONS
                INCR    LOCA
                CA      LOCA            # ADDRESS 2000 IN L
                TS      L
## Page D-20
                CS      STOPA
                AD      LOCA
                CCS     A               # IS IT THE END OF THE BANK
                TC      MERR
                TC      MERR
                TC      GOBAA           # NOT THE END OF THE BANK
                TC      ENDFBA          # THE END OF THE FIXED BANK
GOBAA           CCS     DISYES          # IS IT TIME TO UPDATE DSKY DISPLAY
                TC      GOBBA           # NO
                CA      OCT77A          # YES
                TS      DISYES          # SET DISYES EQUAL TO 77
                CA      LOCA            # GET LOCATION ADDRESS
                TS      R2              # LOAD IT INTO R2
                TC      DISPLAY         # GO TO UPDATE DISPLAY
                TC      GOA             # GO TO READ
GOBBA           TS      DISYES          # DIMINISH DISYES
                TC      GOA             # GO TO READ
ENDFBA          CS      LASTBKA         # END OF FIXED BANK ROUTINE
                AD      BANKNUMA
                CCS     A               # IS THE LAST BANK DONE
                TC      MERR
                TC      MERR
                TC      GETNXBA         # NO GET NEXT BANK REG LOAD
                TC      SUCCESS         # YES ALL DONE
GETNXBA         CA      BANKNUMA
                AD      INCRBKA         # INCREMENT TO NEXT BANK
                TC      STARTBKA        # START NEXT BANK
FIRSTBKA        OCT     70000
STOPA           OCT     02000
STATU17A        OCT     00226
LASTBKA         OCT     76000
INCRBKA         OCT     02000
OCT77A          OCT     00077
SUCCESS         CA      OC17            # LOAD NOUN R1 R2 R3 WITH ALL 7S
                TS      STATUS          # INDICATES TEST SUCCESS
                CA      ALL7SL
                TS      R1
                TS      R2
                TS      R3
                TS      NOUN
                TC      DISPLAY
                TC      IDLE
FXDPR           CA      BANKNO
                TS      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                TS      BANKNO
                TS      R1
                TC      UPDISPLA
SHIFT3L         TS      1STBNKNO
                CA      HOLDIT
                AD      HOLDBKDG
                TS      CYL
                CA      CYL
                CA      CYL
## Page D-21
                CA      CYL
                TS      HOLDBKDG
                TC      RETURNL
BIT4            OCT     00010
BIT13           OCT     10000
BIT14           OCT     20000
BIT15           OCT     40000
BNK3A           OCT     16000
FOUR1S          OCT     11110
FOUR2S          OCT     22220
FOUR3S          OCT     33330
FOUR4S          OCT     44440
FOUR5S          OCT     55550
FOUR6S          OCT     66660
LOW5            OCT     00037
HIGH10          OCT     77740
LOW11           OCT     03777
WAIT2L          OCT     00124
PFS             OCT     37777
BIT8            OCT     00200
ABORTL          OCT     07700
WAIT1L          OCT     31145
GOATTRNS        OCT     02200
ABORTCER        OCT     07740
WDATAL          OCT     01000
BNK3            OCT     06000
BNK34           OCT     70000
HIGHLOC         OCT     01776
LASTBNK         OCT     00003
BNK5            OCT     00005
INCRFB          OCT     02000
NOUN76          OCT     00076
NOUN75          OCT     00075
NOUN74          OCT     00074
NOUN73          OCT     00073
NOUN72          OCT     00072
NOUN71          OCT     00071
NOUN70          OCT     00070
NOUN67          OCT     00067
NOUN65          OCT     00065
NOUN64          OCT     00064
NOUN63          OCT     00063
NOUN62          OCT     00062
NOUN61          OCT     00061
EBKEQUIV        OCT     11400
                OCT     13400
                OCT     15400
                OCT     17400
OC14            OCT     00014
VERB8           OCT     77767
READK14         OCT     41001
READK15         OCT     51005
EBFULL          OCT     00400
FBFULL          OCT     02000
ACMFBKA         OCT     72000
NOUN57          OCT     00057
READKC25        OCT     02000
NOUN56          OCT     00056
## Page D-22
BBKAA           OCT     10024           # PAC BANK 4
BBKBA           OCT     22024           # PAC BANK 11
FULLESS2        OCT     01776
1STBKA          OCT     12020           # FBANK  5 EBANK 20
2NDBKA          OCT     14024           #        6       24
3RDBKA          OCT     16030           #        7       30
4THBKA          OCT     20034           #       10       34
BBKCA           OCT     24100           # F BANK 12 EBANK 100
BBKDA           OCT     26104           # F BANK 13 EBANK 104
BBKEA           OCT     30010           # F BANK 14 EBANK  10
BBKFA           OCT     32014           # F BANK 15 EBANK  14
BBKGA           OCT     60020           # FEXT 6 F BANK 30 EBANK 20
BBKHA           OCT     62024           # FEXT 6 F BANK 31 EBANK 24
BBKIA           OCT     64030           # FEXT 6 F BANK 32 EBANK 30
BBKJA           OCT     66034           # FEXT 6 F BANK 33 EBANK 34
OCT51010        OCT     51010
MINUS20         OCT     77757
MINUS6          OCT     77771
NOUN66          OCT     00066
                SETLOC  FF036000
MERR            CA      OC17            # LOAD NOUN R1 R2 WITH ALL 6S
                TS      STATUS          # INDICATES MACHINE ERROR
                CA      ALL6SL          # R3 HAS LOCATION WHERE ERROR OCCURED
                TS      R1
                TS      R2
                TS      NOUN
                CA      Q
                TS      R3
                TC      DISPLAY
                CA      FLASHL
                EXTEND
                ROR     CH11
                EXTEND
                WRITE   CH11
                TC      IDLE
GOJAMPR         CA      4TOGO
                TS      TIME3
                TS      TIME6
                CA      50TOGO
                TS      TIME4
                CA      ZERO
                TS      TIME5
                TS      R1ADD
                CA      OUTCOML
                EXTEND
                RAND    CH11
                CCS     A               # WAS OUTCOM ON
                INCR    R1ADD           # YES
                CA      BIT13           # NO
                EXTEND
                RAND    CH26
                CCS     A               # WAS GOJAM CAUSED BY E PARITY FAIL
                TC      EPARPRO         # YES
                CA      BIT14           # NO
                EXTEND
                RAND    CH26
                CCS     A               # WAS GOJAM CAUSED BY F PARITY FAIL
                TC      FPARPRO         # YES
## Page D-23
                CA      BIT15           # NO
                EXTEND
                RAND    CH26
                CCS     A               # WAS GOJAM CAUSED BY ECHO CHECK
                TC      ECHCKPRO        # YES
                CA      ACMSTAT         # NO
                MSK     BIT4
                CCS     A               # WAS ACM SUPPOSED TO BE ON
                TC      REQCHK          # YES
                CA      ACMSTAT         # NO
                MSK     ONE
                CCS     A               # WAS ACM REQUESTED TO TURN ON
                TC      +5
                CA      FOUR4S
                AD      R1ADD
                TS      R1
                TC      GETOUT
                CA      ZERO
                TS      ACMSTAT
                CA      FOUR6S
                AD      R1ADD
                TS      R1
                TC      GETOUT
OUTCMSET        CA      OUTCOML
                EXTEND
                ROR     CH11
                EXTEND
                WRITE   CH11
GETOUT          RELINT
                CA      ACMSTAT
                TS      NOUN            # 01 REQ   10 ON   00 OFF
                CA      OC17
                TS      STATUS
                TC      TERR
FEXTA           OCT     00140
EPARPRO         CA      FOUR1S
                AD      R1ADD
                TS      R1
                TC      OUTCMSET
FPARPRO         CA      FOUR2S
                AD      R1ADD
                TS      R1
                TC      OUTCMSET
ECHCKPRO        CA      FOUR3S
                AD      R1ADD
                TS      R1
                TC      OUTCMSET
REQCHK          CA      BIT14
                EXTEND
                RAND    CH25
                CCS     A               # IS CH 25 ACM-ON BIT ON
                TC      AGCFAULT        # YES
                CA      FOUR5S          # NO
                AD      R1ADD
                TS      R1
                TC      GETOUT
AGCFAULT        CA      FOUR4S
                AD      R1ADD
## Page D-24
                TS      R1
                TC      OUTCMSET
TPTRAN          CA      Q
                TS      QSTORL
                CA      COMOUT
                TS      LSTCNT
                TS      OLDID
                CA      CH25LOAD
                MASK    WDATAL          # 01000
                CCS     A               # WILL THE XFER BE READ OR WRITE TAPE
                TC      SUMIT           # WRITE
BEGINL          CA      IDSTARTL        # READ
                EXTEND
                WRITE   CH21            # LOAD ID START
                CA      IDSTOPL         # LOAD LAST BANK OF AM DATA TRANSFER
                EXTEND
                WRITE   CH23            # LOAD ID STOP
                EXTEND                  # CHECK ID STOP
                RAND    CH20
                CS      A
                EXTEND
                RAND    CH20
                MASK    LOW5
                CCS     A               # IS ID STOP OK
                TC      IDSTPERR        # NO
                EXTEND                  # YES    CHECK ID START
                READ    CH20
                MSK     HIGH10
                TS      JUNK1L          # STORE CH20 IDSTART BITS 6 TO 15
                EXTEND
                READ    CH21
                TS      TPBNKL          # STORE CH21
                TS      SR
                CA      SR              # SHIFT THREE PLACES RIGHT
                CA      SR
                CA      SR
                TS      EDOP            # SHIFT SEVEN PLACES RIGHT
                CA      EDOP
                MASK    MASKAA          # MASK LOW 5
                ADS     JUNK1L          # COMPLETE ID START WORD
                CS      A
                AD      IDSTARTL
                CCS     A               # IS ID START OK
                TC      IDSTAERR        # NO
                TC      IDSTAERR        # NO
                TC      IDSTAERR        # NO
CONOTCHK        EXTEND                  # YES
                READ    CH25            # CONOUT
                MASK    BOTEOT6A
                AD      LOW11
                CCS     A               # IS CONOUT OK
                TC      CONOUTER        # NO
                TC      CONOUTER        # NO
                TC      CONOUTER        # NO
                EXTEND                  # YES
                READ    CH27
                EXTEND
                READ    CH26
# Page D-25
                CCS     A               # IS CONIN OK
                TC      CONINERR        # NO
                TC      +3              # YES
                TC      CONINERR        # NO
                TC      CONINERR        # NO
                CA      IDSTARTL
                MASK    BIT15
                CCS     A
                TC      MERR
                TC      PROG
                TC      OKNDATA
                TC      MERR
PROG            CA      IDSTOPL
                MASK    LOW5
                CCS     A
                TC      CHECK
                TC      OKNDATA
                TC      MERR
                TC      MERR
CHECK           AD      MINUS20
                CCS     A
                TC      CHECKAG
                TC      MERR
                TC      IDSTPERR
                TC      OKNDATA
CHECKAG         AD      MINUS6
                CCS     A
                TC      IDSTPERR
                TC      MERR
                TC      +1
OKNDATA         CA      CH25LOAD
                EXTEND                  # LOAD CONOUT
                WRITE   CH25
                EXTEND
                RAND    CH25
                CS      A
                AD      CH25LOAD
                CCS     A               # DID CH25 LOAD CORRECTLY
                TC      CH25ERR         # NO
                TC      CH25ERR         # NO
                TC      CH25ERR         # NO
                CA      ZERO            # YES
                TS      CORERCNT        # CLEAR CORRECTABLE ERROR COUNT
                CA      WAIT2L
                TS      CNTDWN2L
LOOKAGAN        CA      PFS
                TS      CNTDWN1L
FNDTRNSP        EXTEND                  # LOOK FOR TRNSIP
                READ    CH25
                MSK     BIT8
                CCS     A               # HAS TRNSIP APPEARED
                TC      DATATRAN        # YES
                CA      CNTDWN1L        # NO
                CCS     A               # IS FIRST COUNTDOWN OVER
                TC      +2              # NO
                TC      +3              # YES
                TS      CNTDWN1L
                TC      LISTID
## Page D-26
                CA      CNTDWN2L
                CCS     A               # HAVE 7 MINUTES PASSED
                TC      +2              # NO
                TC      7MINERR         # YES
                TS      CNTDWN2L
                EXTEND
                READ    CH26
                MSK     ABORTL
                CCS     A               # HAS AN ABORT BIT APPEARED
                TC      ABORTER1        # YES
                TC      LOOKAGAN        # NO
DATATRAN        CA      ONE             # AM DATA TRANSFER IS IN PROGRESS
                TS      CNTDWN2L
STARTCNT        CA      WAIT1L
                TS      CNTDWN1L
DEVIDES         EXTEND
                DV      JUNK1L
                EXTEND
                DV      JUNK1L
                EXTEND
                DV      JUNK1L
                EXTEND
                MP      JUNK1L
                CA      GOATTRNS
                EXTEND
                RAND    CH25
                EXTEND
                BZF     BOTHGONE        # HAVE BOTH GOATM AND TRNSIP GONE
                CS      A               # NO
                AD      GOATTRNS
                EXTEND
                BZF     +2              # HAVE EITHER GOATM OR TRNSIP GONE
                TC      ONEUPERR        # YES
                CA      CNTDWN1L
                CCS     A               # IS FIRST COUNTDOWN OVER
                TC      CONTINUE        # NO
                CA      CNTDWN2L        # YES
                CCS     A               # HAVE 16 SECONDS PASSED
                TC      +2              # NO
                TC      TRANSERR        # YES
                TS      CNTDWN2L
                TC      STARTCNT
CONTINUE        TS      CNTDWN1L
                CA      ABORTCER
                EXTEND
                RAND    CH26
                EXTEND
                BZF     DEVIDES         # HAS AN ABORT OR CORRECTABLE ERROR
                MSK     ABORTL          # OCCURED   YES
                EXTEND
                BZF     UPERRCNT        # HAS AN ABORT OCCURED
                TC      ABORTER2        # YES
UPERRCNT        INCR    CORERCNT
                EXTEND                  # CLEAR CONIN
                READ    CH27
                TC      DEVIDES
BOTHGONE        CA      ABORTCER
                EXTEND
## Page D-27
                RAND    CH26
                EXTEND
                BZF     RDORWRTL        # HAS AN ABORT OR CORRECTABLE ERROR
                MSK     ABORTL          # OCCURED    YES
                EXTEND
                BZF     INCRERRC        # HAS AN ABORT OCCURED
                TC      ABORTER3        # YES
INCRERRC        INCR    CORERCNT
                EXTEND                  # CLEAR CHANNEL 27
                READ    CH27
RDORWRTL        CA      CH25LOAD
                MASK    WDATAL
                CCS     A               # WAS THE DATA XFER READ OR WRITE TAPE
                TC      7SCHKA          # WRITE
                CA      TPBNKL          # READ CH21
                MASK    BNK3A           # BITS 11, 12, AND 13
                AD      OUTCONGA        # BITS 14 AND 15
                TS      TEMPAA          # STORE
                EXTEND
                WRITE   CH1             # STORE IN L
                CA      JUNK1L          # CH20
                MASK    BIT15           # BIT 15 DATA
                CCS     A               # DATA OR PROG
                TC      MERR            # ERROR
                TC      +3              # PROG
                TC      +5              # DATA
                TC      MERR            # ERROR
                CA      TEMPAA          # PROG O.K.
                TS      FB              # LOAD FB
                TC      +5              # CONTINUE
                CA      BIT13           #     ADD
                EXTEND                  #     BIT
                ROR     CH1             #      13
                TS      FB              # LOAD FB
STARTADD        CA      ZERO
                TS      SUML
                TS      OVFLOL
                CA      HIGHLOC
                TS      CNTDWN1L
LOCCNTDN        CCS     CNTDWN1L        # HAS BANK BEEN SUMMED
                TC      CONTSUM         # NO
                CS      FXDSUM          # YES
                AD      SUML
                CCS     A               # WAS SUM OK
                TC      SUMERR          # NO
                TC      SUMERR          # NO
                TC      SUMERR          # NO
                CS      FXDOVFLO        # YES
                AD      OVFLOL
                CCS     A               # WAS OVERFLOW OK
                TC      OVFLOERR        # NO
                TC      OVFLOERR        # NO
                TC      OVFLOERR        # NO
                EXTEND                  # YES
                READ    CH20
                MASK    LOW5
                CCS     A               # WAS ID STOP ZERO
                TC      +2              # NO
## Page D-28
                TC      QSTORL          # YES
                TS      TEMPA           # IDSTOP-1
                CA      TPBNKL
                MASK    LASTBKA
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CS      A
                AD      TEMPA
                CCS     A               # WAS LAST BANK OF TRANSFER SUMMED
                TC      +4              # NO
                TC      +3              # NO
                TC      +2              # NO
                TC      QSTORL          # YES
                CA      TPBNKL
                AD      INCRFB
                TS      TPBNKL
                CS      LASTBKA
                AD      FB
                CCS     A
                TC      INKFB
                TC      INKFB
                TC      INKFB
                CA      BNK34
                TS      FB
                TC      STARTADD
INKFB           CA      FB              # INCREMENT FIXED BANK REGISTER
                AD      INCRFB
                TS      FB
                TC      STARTADD
CONTSUM         TS      CNTDWN1L
                TS      L               # ADDRESS 2000 IN L
                NDX     A
                CA      2000
                AD      SUML
                TS      SUML
                TC      LOCCNTDN
                INCR    OVFLOL
                TC      LOCCNTDN
R1STATLD        EXTEND                  # LOAD R1 WITH ID READ AND STATUS 17
                READ    CH23
                TS      R1
IDSERRA         CA      OC17
                TS      STATUS
                TC      TERR
ABORTER1        CA      NOUN70          # LOAD NOUN WITH 70
                TS      NOUN            # INDICATES ABORT WAS DETECTED BEFORE
                TC      V8CHK
ONEUPERR        CA      NOUN67          # LOAD NOUN WITH 67
                TS      NOUN            # INDICATES EITHER GOATM OR TRNSIP
                TC      V8CHK
TRANSERR        CA      NOUN65          # LOAD NOUN WITH 65
                TS      NOUN            # INDICATES DATA TRANSFER HAS NOT
                TC      R1STATLD        # ENDED AFTER 16 SECONDS
ABORTER2        CA      NOUN64          # LAOD NOUN WITH 64
## Page D-29
                TS      NOUN            # INDICATES AN ABORT WAS DETECTED
                TC      V8CHK
IDSTPERR        CA      NOUN76          # LOAD NOUN WITH 76
                TS      NOUN            # INDICATES ID STOP IN CH 20 DID
                EXTEND                  # NOT VERIFIED
                READ    CH20
                TS      R1
                TC      IDSERRA
IDSTAERR        CA      NOUN75          # LOAD NOUN WITH 75
                TS      NOUN            # INDICATES ID START IN CHS 20 AND 21
                CA      JUNK1L          # DID NOT VERIFY
                TS      R1
                TC      IDSERRA
IDSTAERA        CA      NOUN66
                TS      NOUN
                CA      2000
                TS      R1
                TC      IDSERRA
CONOUTER        CA      BIT8
                EXTEND
                RAND    CH25
                CCS     A
                TC      RESTRNSP
                CA      NOUN74          # LOAD NOUN WITH 74
                TS      NOUN            # INDICATES CONOUT CH 25 DID NOT
                TC      R1STATLD        # VERIFY
RESTRNSP        CA      BIT8
                EXTEND
                WRITE   CH25
                TC      CONOTCHK
CONINERR        CA      NOUN73          # LOAD NOUN WITH 73
                TS      NOUN            # INDICATES CONIN CH 26 IS NOT ZERO
                TC      R1STATLD
CH25ERR         CA      NOUN72          # LOAD NOUN WITH 72
                TS      NOUN            # INDICATES CONOUT CH 25 DID NOT
                TC      R1STATLD        # LOAD CORRECTLY
7MINERR         CA      NOUN71          # LOAD NOUN WITH 71
                TS      NOUN            # INDICATES TRNSIP HAS NOT APPEARED
                CA      ZEROS
                EXTEND
                WRITE   CH25
                TC      R1STATLD        # WITHIN 7 MIN AFTER GOATM WAS LOADED
ABORTER3        CA      NOUN63          # LOAD NOUN WITH 63
                TS      NOUN            # INDICATES ABORT WAS DETECTED AFTER
                TC      V8CHK
SUMERR          CA      NOUN62          # LOAD NOUN WITH 62
                TS      NOUN            # INDICATES SUM CHECK NOT CORRECT
                CA      SUML            # LOAD R1 WITH SUM
                TS      R1
                CA      OC17
                TS      STATUS
                TC      TERR
OVFLOERR        CA      NOUN61          # LOAD NOUN WITH 61
                TS      NOUN            # INDICATES OVERFLOW COUNT NOT CORRECT
                CA      OVFLOL          # LOAD R1 WITH OVERFLOW COUNT
                TS      R1
                CA      OC17
                TS      STATUS
## Page D-30
                TC      TERR
SUMIT           CA      IDSTOPL         # GET BANK SUM + LOAD LAST 2 LOC IN BK
                MSK     OC14            # 00014
                TS      CYR
                CA      CYR
                CA      CYR
                TS      HOLD1STB        # STORE FIRST BANK OF TRANSFER
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                AD      BNK34
                TS      FB
STARTSUM        CA      ZERO
                TS      SUML
                TS      OVFLOL
                CA      HIGHLOC
                TS      CNTDWN1L
CHKCNTDN        CCS     CNTDWN1L        # HAS BANK BEEN SUMMED
                TC      GETSUM          # NO
                CA      HOLD1STB        # YES
                NDX     A
                CA      EBKEQUIV
                TS      EB
                CS      2000
                AD      IDSTARTL
                CCS     A
                TC      IDSTAERA
                TC      IDSTAERA
                TC      SOMEA
                TC      IDSTAERA
SOMEA           CA      CH25LOAD
                MASK    COMOUT
                TS      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                CA      CYR
                TS      HOLD
                CA      2000
                MASK    BIT3
                AD      HOLD
                MASK    BIT3
                CCS     A
                TC      IDSTAERA
                CA      SUML
                TS      1776
                CA      OVFLOL
                TS      1777
## Page D-31
                CA      HOLD1STB
                INCR    A
                MSK     LASTBNK
                TS      HOLD1STB
                CA      IDSTOPL
                MSK     LASTBNK
                CS      A
                AD      HOLD1STB
                CCS     A
                TC      +4
                TC      +3
                TC      +2
                TC      BEGINL
                CA      FB
                AD      INCRFB
                TS      FB
                TC      STARTSUM
GETSUM          TS      CNTDWN1L
                TS      L               # ADDRESS 2000 IN L
                NDX     A
                CA      2000
                AD      SUML
                TS      SUML
                TC      CHKCNTDN        # NO OVERFLOW
                INCR    OVFLOL          # OVERFLOW
                TC      CHKCNTDN
V8CHK           CA      VERBREGL
                AD      VERB8
                CCS     A
                TC      R1STATLD
                TC      R1STATLD
                TC      R1STATLD
                EXTEND
                READ    CH21
                TS      R1
                TC      IDSERRA
V14             TC      DISPLAY
                CA      READK14
                TS      READKSTA
                CA      BBKAA
                TS      BBK
                TC      COMROUTN
V15             TC      DISPLAY
                CA      READK15
                TS      READKSTA
                CA      BBKBA
                TS      BBK
COMROUTN        CA      BBK             # TRANSFER DATA FROM PAC TO ACM
                TS      BB
                CA      ACMFBKA
                TS      ACMFBK
                CA      ZERO
                TS      EBCOUNT
                TS      FBCOUNT
                TC      PACTRNS
                TC      TPTRAN
                TC      CLRACM
                TC      CRTNAFT
## Page D-32
PACTRNS         CA      Q
                TS      QSTORL
CONTTRNS        NDX     FBCOUNT
                CA      2000
                NDX     EBCOUNT
                TS      1400
                INCR    FBCOUNT
                INCR    EBCOUNT
                CA      FBCOUNT
                TS      L               # ADDRESS 1400 IN L
                CS      EBFULL
                AD      EBCOUNT
                CCS     A               # IS AN ACM EBANK FULL
                TC      MERR            # ERROR
                TC      MERR            # ERROR
                TC      CONTTRNS        # NO
                CS      FBFULL          # YES
                AD      FBCOUNT
                CCS     A               # HAS A COMPLETE PAC BANK BEEN TRANSFD
                TC      MERR            # ERROR
                TC      MERR            # ERROR
                TC      INCREB          # NO
                TC      QSTORL          # YES GO TO SUBROUTINE WHICH XFERS
#  DATA FROM ACM TO ATM
CLRACM          CA      BBK             # CLEAR ACM
                TS      BB
                CA      ZERO
                TS      FBCOUNT
                TS      EBCOUNT
                CA      Q
                TS      QSTORE
CONTCLR         CA      FBCOUNT
                TS      TEMPA
                CA      ZEROS
                NDX     EBCOUNT
                TS      1400
                INCR    EBCOUNT
                INCR    FBCOUNT
                CS      EBFULL
                AD      EBCOUNT
                CCS     A               # HAS AN ACM EBANK BEEN CLEARED
                TC      MERR            # ERROR
                TC      MERR            # ERROR
                TC      ZEROA           # NO
                CS      FBFULL          # YES
                AD      FBCOUNT
                CCS     A               # HAVE 4 ACM EBANKS BEEN CLEARED
                TC      MERR            # ERROR
                TC      MERR            # ERROR
                TC      INCREBA         # NO
                CA      TEMPA
                TS      FBCOUNT
                CA      ACMFBK
                TS      FB
CONTZCHK        NDX     FBCOUNT
                CA      2000
                CCS     A               # IS ACM WORD CLARED
                TC      CLRERROR        # NO
## Page D-33
                TC      +3              # YES
                TC      CLRERROR        # NO
                TC      CLRERROR        # NO
                INCR    FBCOUNT
                CS      FBFULL
                AD      FBCOUNT
                CCS     A               # HAS EVERY ACM WORD BEEN CHECKED
                TC      MERR            # ERROR
                TC      MERR            # ERROR
                TC      CONTZCHK        # NO
                TC      QSTORE          # YES
CRTNAFT         CA      READKC25        # CONTINUE
                TS      CH25LOAD
                CA      READKSTA
                TS      IDSTARTL
                CA      ZERO
                TS      IDSTOPL
                TC      TPTRAN
AMCHKLA         CA      ZEROS           # CHECK ACM AGAINST PAC
                TS      FBCOUNT
                TS      ERRCOUNT
                TC      +2
                TC      ERRCHKAA
                CA      Q
                TS      QSTORL
CONTWDCK        CA      BBK
                TS      BB
                NDX     FBCOUNT
                CA      2000
                TS      HOLD
                CA      ACMFBK
                TS      FB
                NDX     FBCOUNT
                CS      2000
                AD      HOLD
                CCS     A               # DOES ACM WORD AGREE WITH PAC WORD
                TC      UPERCNT         # NO
                TC      UPERCNT         # NO
                TC      UPERCNT         # NO
CONTINU         INCR    FBCOUNT
                CS      FBCOUNT
                AD      FULLESS2
                CCS     A               # HAS EVERY WORD BEEN CHECKED
                TC      CONTWDCK        # NO
                TC      CONTWDCK        # NO
                TC      CONTWDCK        # NO
                TC      QSTORL
ERRCHKAA        CA      ERRCOUNT
                CCS     A               # WERE THERE ANY ERRORS
                TC      IDLE            # YES
                TC      SUCCESS         # NO
UPERCNT         INCR    ERRCOUNT
                CA      NOUN56
                TS      NOUN
                CA      FBFULL
                AD      FBCOUNT
                TS      R1              # LOAD R1 WITH ADDRESS OF ERROR
                NDX     A
## Page D-34
                CA      A
                TS      R2              # LOAD R2 WITH ACM DATA
                CA      BBK
                TS      BB
                CA      R1
                NDX     A
                CA      A
                TS      R3              # LOAD R3 WITH PAC DATA
                CA      OC17
                TS      STATUS
                TC      DISPLAY         # DISPLAY NOUN R1 R2 AND R3
                TC      CONTINU         # CHECK NEXT WORD
INCREB          CA      ZERO            # PAC DATA XFER NOT COMPLETE UPDATE
                TS      EBCOUNT         # ACM EBANK
                INCR    BB
                TC      CONTTRNS
ZEROA           CA      ZERO
                TC      CONTCLR
INCREBA         INCR    BB
                CA      ZERO
                TS      EBCOUNT
                TC      CONTCLR
CLRERROR        CA      FBFULL          # LOAD NOUN WITH 57
                AD      FBCOUNT         # INDICATES ACM DID NOT CLEAR AFTER
                TS      R1              # DATA WAS SENT TO ATM
                CA      OC17            # LOAD R1 WITH FIRST ACM ADDRESS THAT
                TS      STATUS          # WAS NOT CLEARED
                CA      NOUN57
                TS      NOUN
                TC      TERR
V16             TC      DISPLAY
                CA      1STBKA
                TS      BNKNUMAA
                CA      2NDBKA
                TS      BNKNUMBA
                TC      TRFRA
                CA      3RDBKA
                TS      BNKNUMAA
                CA      4THBKA
                TS      BNKNUMBA
                TC      TRFRA
                TC      NARTCAPA
TRFRA           CA      Q
                TS      QSTORE
                CA      BNKNUMAA
                TS      BB
                CA      2000            # LOAD ID FOR EBANK
                TS      1400            # ENDING ZERO
                CA      OC10
                TS      EBCOUNT
                TS      FBCOUNT
                TC      PACTRNS
                CA      BNKNUMBA
                TS      BB
                CA      ZEROS
                TS      EBCOUNT
                TS      FBCOUNT
                TC      PACTRNS
## Page D-35
                TC      QSTORE
NARTCAPA        TC      TPTRAN
                CA      STARTBLE +8
                TS      IDSTARTL
                CA      STOPTBLE +8
                TS      IDSTOPL
                CA      CH25TBLE +8
                TS      CH25LOAD
                TC      V14
V10             TC      DISPLAY
                TC      TPTRAN
                CA      CORERCNT
                TS      R1
                CA      ALL7SL
                TS      R2
                TS      R3
                TS      NOUN
                CA      OC17
                TS      STATUS
                TC      DISPLAY
                TC      IDLE
BIT3            OCT     00004
V00PROC         CA      ZERO
                TS      READX
                TS      BANKNO
                TS      DATAHOLD
                TS      ADDHOLD
                TS      BNKSHFT
                TS      HOLDBKDG
                CA      BNK5
                TS      GETDATA
                TS      GETADD
                CA      TWO
                TS      1STBNKNO
                AD      ONE
                TS      BNKPR
                CA      ONE
                TS      1STDIGPR
                TC      RETURNL
ZZPROC          CA      SWITCH
                CCS     A
                TC      2000
                CS      TEMP1L
                MSK     THIRTY
                CCS     A               # WAS A DIGIT HIT
                TC      +2              # YES
                TC      OPERROR         # NO
                CA      TEMP1L
                MSK     OC10
                CCS     A               # WAS 8 OR 9 HIT
                TC      OPERROR         # YES
                CA      TEMP1L          # NO
                MSK     MASKBA
                TS      HOLDIT
                CCS     1STDIGPR        # IS THIS FIRST DIGIT HIT
                TC      MODESEL         # YES
                CCS     BNKPR           # NO IS THIS THE 2ND OR 3RD DIGIT
                TC      LDBNKL          # YES
## Page D-36
                CCS     GETADD          # NO IS THE ADDRESS COMPLETE
                TC      ADDPROC         # NO
                CCS     READX           # YES IS THIS A LOAD
                TC      DATALD          # YES
                CA      BANKNO          # NO
                TS      BB
                CCS     HOLDIT
                TC      +2
                TC      TRANSC
                CA      ADDHOLD
                TS      R2              # DISPLAY ADDRESS IN R2
                NDX     A
                CA      A
                TS      R3              # DISPLAY DATA IN R3
                INCR    ADDHOLD
UPDISPLA        CA      GODISP          # UPDATE DISPLAY WITH BRUPT
                TS      BRUPT
                RESUME
GODISP          TC      +1
                TC      DISPLAY
                TC      IDLE
TOSUCCL         TC      SUCCESS
TRANSC          CA      TOSUCCL
                TS      QSTORE
                TS      QSTORL
                CA      ADDHOLD
                TS      BRUPT
                RESUME
MODESEL         TS      1STDIGPR
                CA      HOLDIT
                TS      NOUN
                CA      OC17
                TS      STATUS
                CA      ZEROS
                TS      R1
                TS      R2
                TS      R3
                CCS     HOLDIT          # WILL THE OP BE READ FXD
                TC      CONTMODE        # NO
                CA      ONE             # YES
                TS      BNKSHFT
                TC      UPDISPLA
CONTMODE        CCS     A               # WILL THE OP BE LOAD OR READ ERR
                TC      ENDOP
                TC      UPDISPLA
ENDOP           CCS     A
                TC      MIKEB
                TC      LOADSET
LOADSET         CA      ONE
                TS      READX
                TC      UPDISPLA
MIKEB           CA      V00BK
                TS      FB
                TC      2001
LDBNKL          TS      BNKPR
                CCS     1STBNKNO        # IS THIS THE 1ST BNK NO
                TC      SHIFT3L         # YES
                CA      HOLDIT          # NO
## Page D-37
                AD      HOLDBKDG
                TS      BANKNO
                CCS     BNKSHFT         # IS THE ADDRESS FXD OR ERR
                TC      FXDPR
                CA      BANKNO
                TS      R1
                TC      UPDISPLA
ADDPROC         TS      GETADD
                CA      ADDHOLD
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                AD      HOLDIT
                TS      ADDHOLD
                TS      R2
                TC      UPDISPLA
DATALD          CCS     GETDATA         # IS DATA COMPLETE
                TC      CONTDATA        # NO
                CA      BANKNO          # YES
                TS      BB
                CA      ADDHOLD
                TS      R2
                CA      BNK5
                TS      GETDATA
                CA      DATAHOLD
                NDX     ADDHOLD
                TS      A
                NDX     ADDHOLD
                CA      A
                TS      R1
                INCR    ADDHOLD
                CA      ZERO
                TS      DATAHOLD
                CA      GODISP
                TS      BRUPT
                RESUME
                TC      IDLE
CONTDATA        TS      GETDATA
                CA      DATAHOLD
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                AD      HOLDIT
                TS      DATAHOLD
                TS      R3
                TC      UPDISPLA
7SCHKA          EXTEND
                READ    CH23
                CCS     A
                TC      QSTORL
                TC      QSTORL
                TC      QSTORL
                CA      OC177
                EXTEND
                WRITE   CH11
                CA      NOUN60
## Page D-38
                TS      NOUN
                TC      R1STATLD
OC177           OCT     00177
NOUN60          OCT     00060
V21             TC      DISPLAY
                TC      TPTRAN
                TC      2001
                TC      SUCCESS
V22             TC      DISPLAY
                CA      BBKCA           # ...........
                TS      BNKNUMAA        #           .
                CA      BBKDA           #           .
                TS      BNKNUMBA        #           .
                TC      TRFRA           #      PAC TO MU4
                CA      BBKEA           #           .
                TS      BNKNUMAA        #           .
                CA      BBKFA           #           .
                TS      BNKNUMBA        #           .
                TC      TRFRA           # ...........
                CA      BBKGA           #           .
                TS      BNKNUMAA        #           .
                CA      BBKHA           #           .
                TS      BNKNUMBA        #           .
                TC      TRFRA           #      MU4 TO MU5
                CA      BBKIA           #           .
                TS      BNKNUMAA        #           .
                CA      BBKJA           #           .
                TS      BNKNUMBA        #           .
                TC      TRFRA           # ...........
                TC      TPTRAN          # MU5 TO ATM
                CA      BBKGA
                TS      BB
                CA      BNK34           # 70000
                TS      ACMFBK
                CA      OC10
                TS      FBCOUNT
                TS      EBCOUNT
                TC      CONTCLR -2
                CA      BBKHA
                TS      BBK
                CA      ACMFBKA         # 72000
                TS      ACMFBK
                TC      CLRACM          # CLEAR ACM MU5 BK35
                CA      BBKIA
                TS      BB
                CA      OUTCONCA        # 74000
                TS      ACMFBK
                CA      OC10
                TS      FBCOUNT
                TS      EBCOUNT
                TC      CONTCLR -2
                CA      BBKJA
                TS      BBK
                CA      LASTBKA         # 76000
                TS      ACMFBK
                TC      CLRACM          # CLEAR ACM MU5 BK37
                CA      STOPA           # ...........
                TS      CH25LOAD        #           .
## Page D-39
                CA      OCT51010
                TS      IDSTARTL        #       SET UP TPTRAN
                CA      OC14
                TS      IDSTOPL         #           .
                TC      TPTRAN          # ...........
                CA      ZEROS
                TS      ERRCOUNT        # SET ERROR COUNT TO ZERO
                CA      OC10
                TS      FBCOUNT         # START 1ST BANK AT 2010
                CA      BBKGA           # MU4 FBANK 30 R3 IF ERROR
                TS      BBK
                CA      BNK34           # MU5 FBANK 34 R2 IF ERROR
                TS      ACMFBK
                TC      CONTWDCK -2
                CA      ZEROS
                TS      FBCOUNT         # START 2ND BANK AT 2000
                CA      BBKHA           # MU4 FBANK 31 R3 IF ERROR
                TS      BBK
                CA      ACMFBKA         # MU5 FBANK 35 R2 IF ERROR
                TS      ACMFBK
                TC      CONTWDCK -2
                CA      OC10
                TS      FBCOUNT         # START 3RD BANK AT 2010
                CA      BBKIA           # MU4 FBANK 32 R3 IF ERROR
                TS      BBK
                CA      OUTCONCA        # MU5 FBANK 36 R2 IF ERROR
                TS      ACMFBK
                TC      CONTWDCK -2
                CA      ZEROS
                TS      FBCOUNT         # START 4TH BANK AT 2000
                CA      BBKJA           # MU4 FBANK 33 R3 IF ERROR
                TS      BBK
                CA      LASTBKA         # MU5 FBANK 37 R2 IF ERROR
                TS      ACMFBK
                TC      CONTWDCK -2
                TC      ERRCHKAA
LISTID          EXTEND
                READ    CH23
                TS      NEWID
                CS      A
                AD      OLDID
                CCS     A               # IS NEWID EQUAL TO OLDID
                TC      +4              # STORE NEWID
                TC      +3              # STORE NEWID
                TC      +2              # STORE NEWID
                TC      FNDTRNSP        # YES GO BACK TO ROUTINE
                CA      NEWID
                TS      OLDID
                INDEX   LSTCNT
                TS      A               # LOAD LIST
                INCR    LSTCNT
                CA      COMOUT
                INDEX   LSTCNT
                TS      A
                TC      FNDTRNSP
                SETLOC  CF162000
                TC      STDATTR
                CA      FIVE
## Page D-40
                TS      ONETO5
                CA      ZERO
                TS      SIXTH
                TS      SEVENTH
                TS      EIGHTH
                TS      PUNCH5
                TS      PUNCH6
                CA      OC17
                TS      STATUS
                CA      C2A
                TS      LDFBLL
                CA      LASTBNK
                TS      LDEBLL
                NDX     HOLDIT
                TC      WHCHMBD
WHCHMBD         TC      OPERROR
                TC      OPERROR
                TC      OPERROR
                TC      RLRD            # THREE READ
                TC      RLLD            # FOUR LOAD
                TC      LDPN5
                TC      AMCHKL
                TC      OPERROR
AMCHKL          CA      ONE
                TS      PUNCH6
                TS      PUNCH5
                TC      SETSW
RLRD            CA      ONE
                TS      RDLD
                TC      +3
RLLD            CA      ZERO
                TS      RDLD
                CA      ZERO
                TS      HOLDIT
SETSW           CA      ONE
                TS      SWITCH
                TC      UPDISPLA
STDATTR         CCS     PUNCH5
                TC      TRPACBNK
                CS      TEMP1L
                MSK     THIRTY
                CCS     A               # DIGIT
                TC      +2              # YES
                TC      ENTCHK          # NO
                CA      TEMP1L
                MSK     OC10
                CCS     A               # 8 OR 9
                TC      OPERROR         # YES
                TC      ENTROK          # NO
ENTCHK          CS      TEMP1L
                AD      ENTRCDEL
                CCS     A               # ENTER
                TC      OPERROR         # NO
                TC      OPERROR         # NO
                TC      OPERROR         # NO
ENTROK          CA      TEMP1L
                MSK     MASKBA
                TS      HOLDNO
## Page D-41
                CA      ONETO5
                CCS     A
                TC      +2
                TC      SMPXTPX
                TS      ONETO5
                CA      HOLDNO
                ADS     HOLDIT
                CA      ONETO5
                CCS     A
                TC      +2
                TC      DISPITL
                CA      HOLDIT
                TS      R1
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                TS      HOLDIT
                TC      UPDISPLA
DISPITL         CA      HOLDIT
                TS      R1
                CA      ZERO
                TS      R2
                TS      R3
                TC      UPDISPLA
SMPXTPX         CA      SIXTH
                CCS     A
                TC      NOBNKS
                CA      HOLDNO
                CCS     A               #  ZERO TRIPLEX
                CA      OUTCOML         #  ONE SIMPLEX
                AD      CH25TBLE
                TS      HOLDIT
                CCS     RDLD
                TC      +2              # ONE READ TAPE
                CA      WDATAL          # ZERO WRITE TAPE
                AD      HOLDIT
                TS      R3
                CA      ONE
                TS      SIXTH
                TC      UPDISPLA
NOBNKS          CA      SEVENTH
                CCS     A
                TC      KEEPGNG
                CA      HOLDNO
                TS      NOOFBNKS
                NDX     A
                TC      BNKNOOK
BNKNOOK         TC      OPERROR
                TC      ONEBNK
                TC      BNKGD
                TC      BNKGD
                TC      BNKGD
                TC      OPERROR
                TC      OPERROR
                TC      OPERROR
ONEBNK          CA      ZERO
                TS      R2
## Page D-42
                CA      ONE
                TS      SEVENTH
                TC      UPDISPLA
BNKGD           CA      R1
                MSK     FIRST5
                AD      HOLDNO
                MSK     FIRST5
                TS      R2
                CA      ONE
                TS      SEVENTH
                TC      UPDISPLA
KEEPGNG         CA      EIGHTH
                CCS     A
                TC      WRITEIT
                CS      TEMP1L
                AD      ENTRCDEL
                CCS     A               # WAS ENTER HIT
                TC      WRITTPL         # NO
                TC      WRITTPL         # NO
                TC      WRITTPL         # NO
                CCS     RDLD            # YES WAS A READ REQUESTED
                TC      +2              # YES
                TC      OPERROR         # NO
EXITLLL         CA      R1
                TS      IDSTARTL
                CA      R2
                TS      IDSTOPL
                CA      R3
                TS      CH25LOAD
                CA      ZERO
                TS      ZZTAG
                CA      GOL
                TS      BRUPT
                RESUME
WRITTPL         CCS     RDLD
                TC      OPERROR
                CA      HOLDNO
                CCS     A
                CCS     A
                CCS     A
                CA      A
                CCS     A
                TC      OPERROR
                CA      HOLDNO
                TS      CYL
                CA      CYL
                CA      CYL
                TS      R2
                CA      NOOFBNKS
                AD      HOLDNO
                MSK     C3A
                AD      R2
                TS      R2
                CA      ONE
                TS      EIGHTH
                TC      UPDISPLA
WRITEIT         CS      TEMP1L
                AD      ENTRCDEL
## Page D-43
                CCS     A
                TC      OPERROR
                TC      OPERROR
                TC      OPERROR
                TC      EXITLLL
LDPN5           CA      ONE
                TS      PUNCH5
                TC      SETSW
TRPACBNK        CA      TEMP1L
                MSK     MASKBA
                TS      HOLDNO
                CA      LDFBLL
                CCS     A
                TC      FBKPR
                TC      EBKPR
FBKPR           TS      LDFBLL
                CA      HOLDNO
                AD      SIXTH
                TS      SIXTH
                CCS     LDFBLL
                TC      SHFBNK
                TC      TWOSH
SHFBNK          CA      SIXTH
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                TS      SIXTH
                TC      UPDISPLA
TWOSH           CA      SIXTH
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                TS      SIXTH
                CCS     PUNCH6
                TC      GTNXTBK
                TC      UPDISPLA
EBKPR           CCS     PUNCH6
                TC      GOTRPAC
                CA      LDEBLL
                CCS     A
                TC      EBKPRA
                TC      GOTRPAC
EBKPRA          TS      LDEBLL
                CA      HOLDNO
                AD      SEVENTH
                TS      SEVENTH
                CCS     LDEBLL
                TC      SHEBNK
                TC      TWOSHE
## Page D-44
SHEBNK          CA      SEVENTH
                TS      CYL
                CA      CYL
                CA      CYL
                CA      CYL
                TS      SEVENTH
                TC      UPDISPLA
TWOSHE          CA      SIXTH
                AD      SEVENTH
                TS      R1
                TS      BBK
                TC      UPDISPLA
GOTRPAC         CS      TEMP1L
                AD      ENTRCDEL
                CCS     A
                TC      OPERROR
                TC      OPERROR
                TC      OPERROR
                CCS     PUNCH6
                TC      BLOBA
                CA      GOTOERR
                TS      TRXYB
                CA      GOTOSUC
                TS      TRYXB
                CA      XXX
                TS      TRXXB
                CA      YYY
                TS      TRYYB
                CA      ZZZ
                TS      BRUPT
                CA      SEVENTH
                MASK    MASKBA
                CCS     A
                TC      +5
                CA      OC10
                TS      EBCOUNT
                TS      FBCOUNT
                RESUME
                CA      ZEROS
                TC      -4
GOTOERR         CA      BBK
GOTOSUC         TS      BB
XXX             TC      PACTRNS
YYY             TC      SUCCESS
FIVE            OCT     00005
GOL             TC      V11
ZZZ             TC      TRXYB
GTNXTBK         CCS     ONETO5
                TC      +5
                CA      SIXTH
                TS      ACMFBK
                TS      R2
                TC      UPDISPLA
                CA      SIXTH
                TS      BBK
                TS      R1
                CA      ZEROS
                TS      ONETO5
## Page D-45
                CA      C2A
                TS      LDFBLL
## The note preceding this listing suggests that the following word be replaced with 12453, or "TCF 2453", if certain
## functionalities are to be executed. This transfers control to just past the end of this program at FINKBKA.
                TC      UPDISPLA
BLOBA           CA      FINKBKA
                TS      BRUPT
                RESUME
FINKBKA         TC      AMCHKLA
## As above, three extra words are required to be added here in order to execute a particular function. The words, and their
## associated disassemblies, are: <br />
## 30007    CA   ZEROS <br/>
## 54173    TS   SIXTH <br/>
## 07446    TC   UPDISPLA <br/>
