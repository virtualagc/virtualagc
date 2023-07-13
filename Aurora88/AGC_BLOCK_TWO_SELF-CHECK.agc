### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_BLOCK_TWO_SELF-CHECK.agc
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

                BANK    20

SBIT1           EQUALS  BIT1
SBIT2           EQUALS  BIT2
SBIT3           EQUALS  BIT3
SBIT4           EQUALS  BIT4
SBIT5           EQUALS  BIT5
SBIT6           EQUALS  BIT6
SBIT7           EQUALS  BIT7
SBIT8           EQUALS  BIT8
SBIT9           EQUALS  BIT9
SBIT10          EQUALS  BIT10
SBIT11          EQUALS  BIT11
SBIT12          EQUALS  BIT12
SBIT13          EQUALS  BIT13
SBIT14          EQUALS  BIT14
SBIT15          EQUALS  BIT15

S+ZERO          EQUALS  ZERO
S+1             EQUALS  BIT1
S+2             EQUALS  BIT2
S+3             EQUALS  THREE
S+4             EQUALS  FOUR
S+5             EQUALS  FIVE
S+6             EQUALS  SIX
S+7             EQUALS  SEVEN
S8BITS          EQUALS  LOW8            # 00377
CNTRCON         OCTAL   00051           # USED IN CNTRCHK
ERASCON1        OCTAL   00062           # USED IN ERASCHK
ERASCON2        OCTAL   01374           # USED IN ERASCHK
ERASCON6        OCTAL   01400           # USED IN ERASCHK
ERASCON3        OCTAL   01462           # USED IN ERASCHK
ERASCON4        OCTAL   01774           # USED IN ERASCHK
S10BITS         EQUALS  LOW10           # 01777, USED IN ERASCHK
SBNK03          EQUALS  PRIO6           # 06000, USED IN ROPECHK
S13BITS         OCTAL   17777
CONC+S1         OCTAL   25252           # USED IN CYCLSHFT
OVCON           OCTAL   37737           # USED IN RUPTCHK
DVCON           OCTAL   37776
CONC+S2         OCTAL   52400           # USED IN CYCLSHFT
ERASCON5        OCTAL   76777
S-7             OCTAL   77770
S-4             EQUALS  NEG4
S-3             EQUALS  NEG3
S-2             EQUALS  NEG2
S-1             EQUALS  NEGONE
S-ZERO          EQUALS  NEG0

                EBANK=  3
ADRS1           ADRES   SKEEP1

SRADRS          ADRES   SR

ERRORS          CA      Q
                TS      SFAIL           # SAVE Q FOR FAILURE LOCATION
                INCR    ERCOUNT         # KEEP TRACK OF NUMBER OF MALFUNCTIONS.
                TC      ALARM
                OCT     01102           # SELF-CHECK MALFUNCTION INDICATOR
                CCS     SMODE
                CA      S+ZERO
                TS      SMODE
                TC      SELFCHK         # GO TO IDLE LOOP
                TC      SFAIL           # CONTINUE WITH SELF-CHECK

+0CHK           CS      A
-0CHK           CCS     A
                TCF     ERRORS
                TCF     ERRORS
                TCF     ERRORS
                TC      Q

+1CHK           CS      A
-1CHK           CCS     A
                TCF     ERRORS
                TCF     ERRORS
                CCS     A
                TCF     ERRORS
                TC      Q

SMODECHK        EXTEND
                QXCH    SKEEP1
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CCS     SMODE
                TC      SOPTIONS
                TC      SMODECHK +2     # TO BACKUP IDLE LOOP
                TC      SOPTIONS
                INCR    SCOUNT
                TC      SKEEP1          # CONTINUE WITH SELF-CHECK

SOPTIONS        AD      S-7
                EXTEND
                BZMF    +3              # FOR OPTIONS BELOW NINE.
BNKOPTN         TC      POSTJUMP        # GO TO ANOTHER BANK FOR OPTIONS ABOVE 8.
                CADR    SBNKOPTN
                INCR    SCOUNT          # FOR OPTIONS BELOW NINE.
                AD      S+7
                INDEX   A
                TC      SOPTION1
SOPTION1        TC      TC+TCF
SOPTION2        TC      IN-OUT1
SOPTION3        TC      COUNTCHK
SOPTION4        TC      ERASCHK
SOPTION5        TC      ROPECHK
SOPTION6        TC      MPNMBRS
SOPTION7        TC      DVCHECK
SOPTON10        TC      SKEEP1          # CONTINUE WITH SELF-CHECK

SELFCHK         TC      SMODECHK        # ** CHARLEY, COME IN HERE

# TC+TCF CHECKS ALL OF THE PULSES OF TCF AND ALL OF THE PULSES OF TC
# EXCEPT ABILITY TO TC TO ERASABLE.
# ALSO FIRST TIME CS FIXED MEMORY IS USED
TC+TCF          TC      +2
                TC      CCSCHK
                TCF     +2              # $ TCF FIXED MEMORY
                TC      ERRORS
                CS      S+3             # $ CS FIXED MEMORY
                TC      Q               # $
                TC      ERRORS

# CCSCHK CHECKS ALL OF CCS EXCEPT RB WG.
# ALSO CHECKS TS ERASABLE, CS SC, AND CS ERASABLE MEMORY.
CCSCHK          CCS     A               # $ CCS SC, C(A) = -3
                TC      ERRORS
                TC      ERRORS
                TC      +2
                TC      ERRORS
                CCS     A               # $ C(A) = +2, RESULT OF CCS -NUMBER
                TC      +4
                TC      ERRORS
                TC      ERRORS
                TC      ERRORS
                TS      SKEEP1          # $ TS ERASABLE
                CCS     SKEEP1          # $ CCS ERASABLE, C(A) = +1, RESULT OF
                TC      +4              # CCS +NUMBER
                TC      ERRORS
                TC      ERRORS
                TC      ERRORS
                CCS     A               # $ C(A) = +0, RESULT OF CCS +1, CHECKS CI
                TC      ERRORS
                TC      +3
                TC      ERRORS
                TC      ERRORS
                CS      A               # $ CS SC
                CCS     A               # $ C(A) = -0, RESULT OF CCS +0
                TC      ERRORS
                TC      ERRORS
                TC      ERRORS
                CCS     A               # $ RESULT OF CCS -0
                TC      ERRORS
                TC      +3
                TC      ERRORS
                TC      ERRORS
                CS      SKEEP1          # $ CS ERASABLE. ALSO CHECKS BACK INTO
                TC      -1CHK           # ERASABLE SEQUENCE.

# BZMFCHK CHECKS ALL PULSES OF BZMF.
# ALSO CHECKS CA FIXED MEMORY.
BZMFCHK         CAF     SBIT9           # $ CA FIXED MEMORY
                EXTEND
                BZMF    ERRBZMF
                CS      A
                EXTEND
                BZMF    +2              # $
                TC      ERRORS
                CA      S+MAX
                AD      S+1
                EXTEND
                BZMF    ERRBZMF2        # $ + OVERFLOW, CHECK 01-0000
                CA      S+ZERO
                EXTEND
                BZMF    +2              # $
                TC      ERRORS
                CS      A
                EXTEND
                BZMF    +4              # $
                TC      ERRORS
ERRBZMF         TC      ERRORS          # FROM BZMF WITH +NON-ZERO
ERRBZMF2        TC      ERRORS          # OVERFLOW WITH +0

# RESTORE1 AND 2 CHECKS INSTRUCTIONS (WITH STAR) ABILITY TO READ BACK INTO
# ERASABLE MEMORY. NOT NORMALLY INTERESTED IN CONTENTS OF A REGISTER.
# FIRST TIME MANY INSTRUCTIONS ARE USED.
# RESTORE1 ALSO CHECKS INDEX (WITHOUT EXTRACODE) ERASABLE, CA ERASABLE,
# AND MASK ERASABLE.
RESTORE1        CAF     SRADRS          # ADDRESS OF SR
                TS      SKEEP7
                CA      S8BITS          # 00377
                NDX     SKEEP7          # $ INDEX ERASABLE                       *
                TS      0000            # TS SR, C(SR) = 00177
                CCS     SR              # C(SR) = 00077                          *
                NDX     SKEEP7          # CHECKS C(SKEEP7) CORRECT
                CS      0000            # C(SR) = 00037
                AD      SR              # C(SR) = 00017                          *
                EXTEND
                MSU     SR              # C(SR) = 00007                          *
                EXTEND
                SU      SR              # C(SR) = 00003                          *
                CA      SR              # $ C(SR) = +1, C(A) = +3, CA ERASABLE   *
                MASK    SR              # $ B(SR) = C(SR) = +1, MASK ERASABLE    *
                TC      +1CHK
                EXTEND
                MP      SR
                EXTEND
                DV      SR
                CA      SR              # $ CA ERASABLE
                TC      +1CHK           # MAKES SURE MASK, MP, AND DV DO NOT EDIT.

# RESTORE2 ALSO CHECKS XCH ERASABLE,INDEX (WITH EXTRACODE) ERASABLE AND
# FIXED MEMORY, DCS ERASABLE, CA SC, AND DCA ERASABLE.
RESTORE2        CAF     ADRS1           # ADDRESS OF SKEEP1
                TS      SKEEP6
                CA      S-1
                TS      SKEEP1          # -1
                CS      A
                XCH     SKEEP1          # $ XCH ERASABLE, C(SKEEP1) = +1
                XCH     SKEEP2          # $ XCH ERASABLE, C(SKEEP2) = -1
                EXTEND
                NDX     SKEEP6          # $ NDX ERASABLE                         *
                DCA     0000            # DCA ERASABLE                           *
                EXTEND
                NDX     ADRS1           # $ NDX FIXED MEMORY                     *
                DCS     0000            # $ DCS ERASABLE MEMORY                  *
                TC      -1CHK           # MAKES SURE DCS ERASABLE OK
                CA      L               # $ CA SC
                TC      +1CHK
                EXTEND
                NDX     SKEEP6          # MAKE SURE C(SKEEP6) IS STILL CORRECT
                DCA     0000            # $ DCA ERASABLE
                TC      +1CHK
                CA      L
                TC      -1CHK

# RESTORE3 CHECKS ABILITY TO RESTORE INSTRUCTIONS BACK INTO ERASABLE
# MEMORY. IT IS ONLY NECESSARY TO RESTORE ONE INSTRUCTION BECAUSE THE
# G REGISTER DOES NOT CHANGE.
# ALSO CHECKS TC TO ERASABLE MEMORY.
RESTORE3        CA      SBIT15          # CS
                TS      SKEEP1          # 40000
                CA      S+2             # TC Q
                TS      SKEEP2
                CA      S+1             # +1
                TC      SKEEP1          # $ TC ERASABLE
                TC      -1CHK           # FIRST TIME BACK FROM ERASABLE.
                TC      SKEEP1
                TC      -0CHK           # SECOND TIME BACK FROM ERASABLE.

# BZFCHK CHECKS ALL PULSES OF BZF.
BZFCHK          CAF     S+5
                EXTEND
                BZF     ERRBZF1         # $
                CS      A
                EXTEND
                BZF     ERRBZF2         # $
                CA      S+MAX
                AD      S+1             # 01-00000
                EXTEND
                BZF     ERRBZF3         # $
                CS      A
                EXTEND
                BZF     ERRBZF4         # $
                CAF     S+ZERO
                EXTEND
                BZF     +2              # $
                TC      ERRORS
                CS      A
                EXTEND
                BZF     +6              # $
                TC      ERRORS
ERRBZF1         TC      ERRORS          # +NON-ZERO
ERRBZF2         TC      ERRORS          # -NON-ZERO
ERRBZF3         TC      ERRORS          # 01-00000
ERRBZF4         TC      ERRORS          # 10-37777

# DXCH+DIM CHECKS ALL PULSES OF DXCH AND DIM.
# ALSO CHECKS TS WITH OVERFLOW, TS SC, CA SC, AND AD ERASABLE.
DXCH+DIM        CA      S+MAX
                AD      S+2             # OVERFLOW WITH +1
                TS      SKEEP1          # $ TS WITH OVERFLOW, +1
                TC      ERRORS
                CS      A
                TS      SKEEP2
                CS      S+MAX
                TS      L               # $ TS SC, 40000
                CS      A               # 37777
                DXCH    SKEEP1          # $ DXCH ERASABLE
                TC      +1CHK
                CA      L               # $ CA SC
                TC      -1CHK
                EXTEND
                DIM     SKEEP1          # $ DIM ERASABLE, DIM + NUMBER, 37776
                EXTEND
                DIM     SKEEP2          # $ DIM - NUMBER, 40001
                CA      S+MAX           # 37777
                AD      SKEEP2          # $ AD ERASABLE, +1
                TC      +1CHK
                CS      S+MAX           # 40000
                AD      SKEEP1          # -1
                TC      -1CHK
                CA      S+1             # +1
                EXTEND
                DIM     A               # $ DIM SC, DIM +1
                EXTEND
                DIM     A               # $ DIM -0
                TC      -0CHK
                EXTEND
                DIM     A               # $ DIM +0
                TC      +0CHK

# DAS+INCR CHECKS ALL PULSES OF DAS AND INCR.
# ALSO CHECKS DCA FIXED, LXCH SC, DCA ERASABLE, AD ERASABLE, DCS FIXED,
# DCS ERASABLE, AND XCH SC.
DAS+INCR        CA      S-1
DAS++           TS      L               # -1
                CA      S+2             # +2
                DAS     A               # $ DAS SC, C(A) = +4 AND C(L) = -2
                AD      S-3             # $ AD FIXED MEMORY
                TC      +1CHK
                CA      S+1
                AD      L               # $ AD SC, -1
                TC      -1CHK
# DAS WITH INTERFLOW IN LOW ORDER AND NET OVERFLOW
DAS+-           EXTEND
                DCA     S+MAX           # $DCA FIXED MEMORY
                DXCH    SKEEP3          # 37777, 40000
                CA      S-2
                TS      L
                CA      S+3             # C(A) = +3, C(L) = -2
                DAS     SKEEP3          # $ DAS ERASABLE
                LXCH    A               # $ LXCH SC
                TC      +0CHK
                CA      L
                TC      +1CHK
                EXTEND
                DCA     SKEEP3          # $ DCA ERASABLE
                LXCH    A               # C(A) = -1, C(L) = +1
                TC      -1CHK
                CA      L
                TC      +1CHK
# INCRCHK CHECKS ALL INCR PULSES EXCEPT WOVR.
INCRCHK         INCR    SKEEP4          # $ INCR ERASABLE, -0
                AD      SKEEP4          # $ AD ERASABLE
                TC      -0CHK
                INCR    A               # $ INCR SC, +1
                TC      +1CHK
# DAS WITH OVERFLOW IN LOW ORDER AND NET UNDERFLOW
DAS-+           EXTEND
                DCS     S+MAX           # $ DCS FIXED MEMORY
                DXCH    SKEEP1          # 40000, 37777
                CA      S+3             # +3
                TS      L
                CS      A               # -3
                DAS     SKEEP1          # $
                TC      -1CHK
                EXTEND
                DCS     SKEEP1          # $ DCS ERASABLE (+1, -2)
                XCH     L               # $ XCH SC (-2, +1)
                AD      S+1
                TC      -1CHK
                CA      L
                TC      +1CHK

# MPCHK CHECKS ALL PULSES OF MP, AUG, AND ADS.
MPCHK           CA      S+1
                EXTEND
                AUG     A               # $ AUG SC, +2
                TS      SKEEP5          # +2
                CS      A
                TS      Q               # -2
                CS      A
MP++            EXTEND
                MP      S+MAX           # $ MP FIXED MEMORY, +1, 37776
                AD      L               # 37777
MP+-            EXTEND
                MP      Q               # $ MP SC, -1, 40001
                ADS     L               # $ ADS SC, 40000
                AD      DVCON
                TC      -1CHK
                CA      L
MP-+            EXTEND
                MP      SKEEP5          # $ MP ERASABLE, -1, 40001
                TS      SKEEP6
                EXTEND
                AUG     SKEEP6          # $ AUG ERASABLE, -2
                AD      L               # 40000
MP--            EXTEND
                MP      SKEEP6          # $ +1, 37776
                TC      +1CHK
                CS      L               # 40001
                AD      DVCON
                TC      -0CHK
                CA      S+1
                ADS     SKEEP6          # $ ADS ERASABLE, +1
                TC      -1CHK
                CA      SKEEP6
                TC      -1CHK

# DVCH AND DVQXCHK CHECK ALL OF PULSES OF DV AND QXCH.
# ALSO CHECKS TS WITH UNDERFLOW
DVCHK           CA      SBIT14          # 20000
                TS      SKEEP1
                AD      A               # OVERFLOW
                AD      S+1
                TS      L               # $ TS SC WITH OVERFLOW, +1
                TC      ERRORS
                CS      A
                TS      SKEEP2          # -1
                CA      S-ZERO          # -0
                LXCH    SKEEP1          # $ LXCH ERASABLE
DV++            EXTEND
                DV      SKEEP1          # $ DV ERASABLE, C(A) = 20000, C(L) = +0
                CS      A
                LXCH    A
                TC      +0CHK
DV--            EXTEND
                DV      SKEEP2          # $ 20000, +0
                TS      SKEEP4          # 20000
                CS      A
                TS      SKEEP3          # -(20000)
                AD      SBIT14
                TC      -0CHK
                CA      L
                TC      -0CHK
DV+-            CA      S+MAX
                TS      L
                CA      S13BITS
                EXTEND
                DV      SKEEP3          # $ -(37777), +(17777)
                XCH     L
                CS      A
DV-+            EXTEND
                DV      SKEEP4          # $ -(37777), -(17777)
                AD      DVCON
                TC      -1CHK
                CA      S+MAX
                XCH     L               # ALSO PUTS 37777 IN L FOR DV-+,-
                AD      SBIT14
                TC      +1CHK
DV-+,+          CS      S13BITS         # -(17777)
                EXTEND
                DV      SKEEP4
                AD      L               # -(37775)
                AD      DVCON
                TC      +1CHK
                XCH     L
                TC      -1CHK           # ALSO PUTS +0 IN L FOR DVQXCH
DVQXCHK         CS      DVCON
                TS      Q               # 40001
                CS      A
                EXTEND
                DV      Q               # $ DV SC, -(37777), +(37776)
                EXTEND
                QXCH    L               # $ QXCH SC, C(L) = 40001, C(Q) = 37776
                AD      Q
                TC      -1CHK
                CA      L
                AD      S+MAX
                TC      +1CHK
                EXTEND
                QXCH    SKEEP1          # $ QXCH ERAS., C(Q) = +1, C(SKEEP1) = +3
                CA      Q
                TC      +1CHK
                CS      SKEEP1          # -3
                AD      S+2
                TC      -1CHK

# MSUCHK CHECKS ALL PULSES OF MSU EXCEPT RB WG.
MSUCHK          CA      S+ZERO
                TS      SKEEP1          # +0
                CS      A
                TS      SKEEP2          # -0
                EXTEND
                MSU     A               # $ MSU SC, +0
                TC      +0CHK
                EXTEND
                MSU     SKEEP2          # $ MSU ERASABLE, +1
                TC      +1CHK
                EXTEND
                DCA     S+MAX
                EXTEND
                MSU     L               # $ CHECKS RUS WA, ALSO -1 FROM NEG. NO.
                TS      A
                TC      +2
                TC      ERRORS
                TC      -1CHK

# MASKCHK FINISHES CHECKING MASK INSTRUCTION.
MASKCHK         CA      S+7
                TS      L
                MASK    S-7             # $ MASK FIXED MEMORY
                TC      +0CHK
                CA      S+1
                MASK    L               # $ MASK SC
                TC      +1CHK

# NDX+SU FINISHES CHECKING BOTH INDEX INSTRUCTIONS. ALSO CHECKS ALL OF SU
# EXCEPT RB WG.
NDX+SU          CA      S+1
                TS      L
                TS      SKEEP1
                NDX     A               # $ NDX SC
                AD      0000            # AD L, +2
                EXTEND
                SU      SKEEP1          # $ SU ERASABLE
                TC      +1CHK
                EXTEND
                NDX     L               # $ NDX SC
                SU      0000            # $ SU SC, SU L
                TC      -1CHK

# D--SC CHECKS DCS SC, DXCH SC, AND DCA SC.
D--SC           CA      S+2
                TS      L               # +2
                CA      S+1
                EXTEND
                DCS     A               # $ DCS SC, C(L) = -2
                TC      -1CHK
# AFTER DXCH C(A) = B(Q) = +3, C(L) = B(A) = +0, C(Q) = B(L) = -1.
                DXCH    L               # $ DXCH SC
                TS      SKEEP3
                AD      Q
                TC      +1CHK
                CA      L
                TC      +0CHK
                CA      S-1
                TS      Q
                CS      A
                EXTEND
# AFTER DCA C(A) = C(L) = C(Q) = B(Q) = -1.
                DCA     L               # $ DCA SC
                AD      Q
                AD      SKEEP3
                TC      +1CHK
                CA      L
                TC      -1CHK

# D--LCHK CHECKS THAT OVERFLOW IS LOST IN PROCESS OF GOING THROUGH L REG.
# ALSO CHECKS THAT Q WILL HOLD 16 BITS
D--LCHK         CA      S-2
                TS      Q
                CA      S-MAX
                ADS     Q
                CS      Q
                TS      A
                TC      ERRORS
                EXTEND
                DCA     L
                TS      A
                TC      +2
                TC      ERRORS
                TC      -1CHK

# CHECKS OVERFLOW, UNDERFLOW,END-AROUND-CARRY, AND SIGN CHANGE OF ADDER.
# ALSO CHECKS ADS SC WITH OVERFLOW AND TS A WITH UNDERFLOW
ADDRCHK         CA      SBIT14          # 20000
                TS      Q
                ADS     Q               # $ ADS SC, OVERFLOW
                ADS     Q               # UNDERFLOW
                TS      A               # $ TS SC WITH UNDERFLOW
                TC      ERRORS
                ADS     Q
                TC      +1CHK

# RUPTCHK CHECKS THAT INTERRUPT DOES NOT OCCUR WHILE OVERFLOW OR UNDERFLOW
# IS IN THE A REGISTER. ALSO CHECKS THAT INHINT RELINT WORK PROPERLY.
RUPTCHK         INHINT
                CA      S+ZERO
                TS      ZRUPT
                RELINT
                AD      TIME4
                TS      SKEEP1
TENMS           CS      SKEEP1
                AD      TIME4           # WAIT FOR NEXT TIME4 INCREMENT
                EXTEND
                BZF     TENMS
                INHINT
                CA      ZRUPT
                EXTEND
                BZF     +2              # NO INTERRUPT.
                TC      RUPTCHK         # THERE WAS AN INTERRUPT. START AGAIN.
                CAF     S+1             # 2 1/2 MS UNTILE NEXT T3 INTERRUPT.
                TC      WAITLIST
                EBANK=  LST1
                2CADR   TSKADRS

                CA      S+MAX
                AD      OVCON           # CONTROLS TIME SPENT IN OF-UF LOOP
                RELINT
WAIT            CS      A
                CCS     A
                TC      INHNTCHK
RUPTCON         ADRES   C(BRUPT)
                AD      S+2
                TC      WAIT
INHNTCHK        INHINT                  # T3 RUPT SHOULD BE WAITING
                TS      SKEEP5
                TC      ERRORS
                RELINT
C(BRUPT)        CS      ZRUPT           # INTERRUPT SHOULD HAPPEN HERE
                EXTEND
                BZF     ERRORS          # MAKES SURE AN INTERRUPT DID HAPPEN
                TC      +5              # END OF RUPTCHK
TSKADRS         CS      ZRUPT
                AD      RUPTCON
                TC      -1CHK
                TC      TASKOVER

                TC      SMODECHK

# IN-OUT1 CHECKS ALL PULSES OF WRITE AND READ
IN-OUT1         CA      S-1
WRITECHK        EXTEND
                WRITE   Q
                LXCH    Q               # PUT C(Q) IN L
                TC      -1CHK
READCHK         EXTEND                  # C(L) = 77776
                READ    L
                TC      -1CHK
                CA      L
                TC      -1CHK

# IN-OUT2 CHECKS ALL PULSES OF ROR AND WOR
IN-OUT2         CS      S+3
RORCHK          TS      L               # 77774
                CA      DVCON           # 37776
                EXTEND
                ROR     L               # $ ROR, -1
                TC      -1CHK
WORCHK          CA      DVCON           # C(L) STILL 77774
                EXTEND
                WOR     L               # $ WOR, -1
                TC      -1CHK
                CA      L
                TC      -1CHK

# IN-OUT3 CHECKS ALL PULSES OF RAND, WAND, AND RXOR
IN-OUT3         CS      DVCON
RANDCHK         TS      L               # 40001
                CA      S13BITS         # 17777
                EXTEND
                RAND    L               # $ RAND, +1
                TC      +1CHK
WANDCHK         CA      S13BITS         # C(L) STILL 40001
                EXTEND
                WAND    L               # $ WAND, +1
                TC      +1CHK
                CS      S+5
                XCH     L               # ALSO PUT -5 IN L FOR RXORCHK
                TC      +1CHK
RXORCHK         CA      S+6
                EXTEND
                RXOR    L               # $ RXOR, -3
                AD      S+2
                TC      -1CHK
                CA      L
                AD      S+4
                TC      -1CHK

                TC      SMODECHK

# COUNTCHK COUNTS UP 14 BIT NUMBER WITH SIGN.
# TAKES APPROXIMATELY 8.7 SECONDS.
# ** PUT IN CCS NEWJOB FOR ROPE.
COUNTCHK        EXTEND
                DCA     S+MAX
                DXCH    SKEEP6          # PUT 37777 IN SKEEP6 AND 40000 IN SKEEP7
+LOOP           CA      SKEEP6
                XCH     Q
                EXTEND
                DCS     L
                CCS     A
                TC      -NMBR
                TC      ENDCOUNT
                TS      SKEEP6
                AD      SKEEP7
                TC      -1CHK
                INCR    SKEEP7
                TC      +LOOP
-NMBR           AD      L
                TC      -1CHK
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CS      SKEEP6
                TC      +LOOP +1
ENDCOUNT        CA      SKEEP7          # -0
                AD      SKEEP6          # SKEEP6 SHOULD BE +0
                TC      -0CHK

# O-UFLOW COUNTS DOWN OVERFLOW AND UNDERFLOW NUMBERS.
# TAKES APPROXIMATELY 10.8 SECONDS
O-UFLOW         CA      S-MAX
                TS      SKEEP5          # 40000
                CS      A
OFLOOP          INHINT
                AD      S+MAX
                AD      S+1
                XCH     Q
                CCS     Q
                TC      -NMBRS
                TC      ERRORS          # CAN PUT IN CONSTANT
                TS      SKEEP3
                TC      ERRORS
                CA      SKEEP3
                AD      SKEEP5
                TC      -1CHK
                RELINT
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CA      SKEEP4
                EXTEND
                DIM     SKEEP5
                TC      OFLOOP
-NMBRS          TS      SKEEP4
                TC      ENDOFUF
                CA      SKEEP4
                AD      SKEEP5
                TC      -1CHK
                CA      SKEEP5
                AD      S-MAX
                AD      S-1
                TC      OFLOOP +3
ENDOFUF         CA      SKEEP5
                TC      -0CHK
                CS      SKEEP4
                AD      DVCON
                TC      -1CHK
                RELINT

                TC      SMODECHK

# SKEEP7 HOLDS LOWEST OF TWO ADDRESSES BEING CHECKED.
# SKEEP6 HOLDS B(X+1).
# SKEEP5 HOLDS B(X).
# SKEEP4 CONTROLS CHECKING OF NON-SWITCHABLE ERASABLE MEMORY WITH
# BANK NUMBERS IN EB.
# SKEEP3 HOLDS LAST ADDRESS BEING CHECKED (HIGHEST ADDRESS).
# SKEEP2 HOLDS C(EBANK) DURING CHECKNJ
# ERASCHK TAKES APPROXMATELY 7 SECONDS
ERASCHK         CA      S+1
                TS      SKEEP4
0EBANK          CA      S+ZERO
                TS      EBANK
                CA      ERASCON3        # 01462
                TS      SKEEP7          # STARTING ADDRESS
                CA      S10BITS         # 01777
                TS      SKEEP3          # LAST ADDRESS CHECKED
                TC      ERASLOOP

E134567B        CA      ERASCON6        # 01400
                TS      SKEEP7          # STARTING ADDRESS
                CA      S10BITS         # 01777
                TS      SKEEP3          # LAST ADDRESS CHECKED
                TC      ERASLOOP

2EBANK          CA      ERASCON6        # 01400
                TS      SKEEP7          # STARTING ADDRESS
                CA      ERASCON4        # 01774
                TS      SKEEP3          # LAST ADDRESS CHECKED
                TC      ERASLOOP

NOEBANK         TS      SKEEP4          # +0
                CA      ERASCON1        # 00062
                TS      SKEEP7          # STARTING ADDRESS
                CA      ERASCON2        # 01374
                TS      SKEEP3          # LAST ADDRESS CHECKED

ERASLOOP        TC      ERASLP1
ERASLP2         TS      ERESTORE        # IF RESTART, RESTORE C(X) AND C(X+1)
                TS      L
                INCR    L
                NDX     A
                DXCH    0000            # PUTS OWN ADDRESS IN X AND X +1
                NOOP
                NDX     SKEEP7
                CS      0001            # CS X+1
                NDX     SKEEP7
                AD      0000            # AD X
                TC      -1CHK
                EXTEND
                NDX     SKEEP7
                DCS     0000            # COMPLEMENT OF ADDRESS OF X AND X+1
                NDX     SKEEP7
                DXCH    0000            # PUT COMPLEMENT OF ADDRESS OF X AND X+1
                NDX     SKEEP7
                CS      0000            # CS X
                NDX     SKEEP7
                AD      0001            # AD X+1
                TC      -1CHK
                EXTEND
                DCA     SKEEP5
                TC      ERASLP3
ERASLP4         RELINT
                CA      EBANK           # STORES C(EBANK)
                TS      SKEEP2
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CA      SKEEP2          # REPLACES B(EBANK)
                TS      EBANK
                INCR    SKEEP7
                CS      SKEEP7
                AD      SKEEP3
                EXTEND
                BZF     +2
                TC      ERASLOOP        # GO TO NEXT ADDRESS IN SAME BANK
                CCS     SKEEP4
                TC      NOEBANK
                INCR    SKEEP4          # PUT +1 IN SKEEP4
                CA      EBANK
                AD      SBIT9
                TS      EBANK
                AD      ERASCON5        # 76377 CHECK FOR BANK E3
                EXTEND
                BZF     2EBANK
                CCS     EBANK
                TC      E134567B        # GO TO EBANKS 1,3,4,5,6, AND 7
                CA      ERASCON6        # END OF ERASCHK
                TS      EBANK
# CNTRCHK PERFORMS A CS OF ALL REGISTERS FROM OCT. 61 THROUGH OCT. 10.
# INCLUDED ARE ALL COUNTERS, T6-1, CYCLE AND SHIFT, AND ALL RUPT REGISTERS
CNTRCHK         CAF     CNTRCON         # 00051
CNTRLOOP        TS      SKEEP2
                AD      SBIT4           # +10 OCTAL
                INDEX   A
                CS      0000
                CCS     SKEEP2
                TC      CNTRLOOP

# CYCLSHFT CHECKS THE CYCLE AND SHIFT REGISTERS
CYCLSHFT        CA      CONC+S1         # 25252
                TS      CYR             # C(CYR) = 12525
                TS      CYL             # C(CYL) = 52524
                TS      SR              # C(SR) = 12525
                TS      EDOP            # C(EDOP) = 00125
                AD      CYR             # 37777         C(CYR) = 45252
                AD      CYL             # 00-12524      C(CYL) = 25251
                AD      SR              # 00-25251      C(SR) = 05252
                AD      EDOP            # 00-25376      C(EDOP) = +0
                AD      CONC+S2         # C(CONC+S2) = 52400
                TC      -1CHK
                AD      CYR             # 45252
                AD      CYL             # 72523
                AD      SR              # 77775
                AD      EDOP            # 77775
                AD      S+1             # 77776
                TC      -1CHK

                INCR    SCOUNT +1
                TC      SMODECHK
                TC      ROPECHK

# SKEEP1 HOLDS SUM
# SKEEP2 HOLDS PRESENT CONTENTS OF ADDRESS IN ROPECHK AND SHOWSUM ROUTINES
# SKEEP2 HOLDS BANK NUMBER IN LOW ORDER BITS DURING SHOWSUM DISPLAY
# SKEEP3 HOLDS PRESENT ADDRESS (00000 TO 01777 IN COMMON FIXED BANKS)
#                              (04000 TO 07777 IN FXFX BANKS)
# SKEEP3 HOLDS BUGGER WORD DURING SHOWSUM DISPLAY
# SKEEP4 HOLDS BANK NUMBER
# SKEEP5 COUNTS 2 SUCCESSIVE TC SELF WORDS
# SKEEP6 CONTROLS ROPECHK OR SHOWSUM OPTION
# SKEEP7 CONTROLS WHEN ROUNTINE IS IN COMMON FIXED OR FIXED FIXED BANKS

STSHOSUM        TC      GRABDSP
                TC      PREGBSY
                TC      +3
ROPECHK         CA      S-ZERO
                TS      SKEEP6          # ROPECHK OPTION
                CA      S+ZERO
                TS      SKEEP4          # BANK NUMBER
                CA      S+1
COMMFX          TS      SKEEP7
                CA      S+ZERO
                TS      SKEEP1
                TS      SKEEP3
                CA      S+1
                TS      SKEEP5          # COUNTS DOWN 2 TC SELF WORDS
COMADRS         CA      SKEEP3
                AD      SKEEP4
                TC      DATACALL
                TC      ADSUM
                AD      SBIT11          # 02000
                TC      ADRSCHK

FXFX            CS      A
                TS      SKEEP7
                EXTEND
                BZF     +3
                CA      SBIT12          # 04000, STARTING ADDRESS OF BANK 02
                TC      +2
                CA      SBNK03          # 06000, STARTING ADDRESS OF BANK 03
                TS      SKEEP3
                CA      S+ZERO
                TS      SKEEP1
                CA      S+1
                TS      SKEEP5          # COUNTS DOWN 2 TC SELF WORDS
FXADRS          EXTEND
                NDX     SKEEP3
                DCA     0000
                TC      ADSUM
                TC      ADRSCHK

ADSUM           TS      SKEEP2
                AD      SKEEP1
                TS      SKEEP1
                CAF     S+ZERO
                AD      SKEEP1
                TS      SKEEP1
                CS      SKEEP2
                AD      SKEEP3
                TC      Q

ADRSCHK         CCS     A
                TC      CONTINU
                TC      CONTINU
                TC      CONTINU
                CCS     SKEEP5
                TC      CONTINU +1
                CA      L
                TC      ADSUM
                TC      SOPTION         # GO TO ROPECHK SHOSUM OPTION
CONTINU         CA      S+1             # MAKE SURE TWO CONSECUTIVE TC SELF WORDS
                TS      SKEEP5
                CCS     SKEEP6          # +1 IN SKEEP6, SHOWSUM VIA EXECUTIVE
                CCS     NEWJOB
                TC      CHANG1
                TC      +2
                TC      CHECKNJ         # -0 IN SKEEP6 FOR ROPECHK

ADRS+1          INCR    SKEEP3
                CCS     SKEEP7
                TC      COMADRS
                TC      COMADRS
                TC      FXADRS
                TC      FXADRS

NXTBNK          CA      SKEEP4
                AD      SBIT11
                TS      SKEEP4
                TC      +3
                CA      SBIT15
                TS      SKEEP4
                AD      NOBANKNO        # FIRST BANK NOT USED.
                EXTEND
                BZF     ENDSUMS
                CCS     SKEEP7
                TC      COMMFX
                CA      S+1
                TC      FXFX
                CA      SBIT7           # CAN BE ANY NUMBER LARGER THAN 36 DECIMAL
                TC      COMMFX

ENDSUMS         CCS     SKEEP6
                TC      ROPECHK +2      # START SHOWSUM AGAIN
S+MAX           OCTAL   37777           # ** S+MAX AND S-MAX MUST BE TOGETHER
S-MAX           OCTAL   40000           # FOR DOUBLE PRECISION CHECKING.
                TC      MPNMBRS -1      # ROPECHK IS COMPLETED

SOPTION         CCS     SKEEP6          # DECIDE ON ROPECHK OR SHOWSUM OPTION
                TC      SDISPLAY
VNCON           OCTAL   00501           # USED IN SHOWSUM. DISPLAY 3 REGISTERS.
NOBANKNO        OCTAL   33777           # * CONSTANT, COMPLEMENT OF LAST BANK +1.
# CHANGE TO 33777 IF BANK 21 IS LAST BANK USED
BNKCHK          CCS     SKEEP1          # WHEN C(SKEEP6) = -0
                TC      +4
SCADR           FCADR   SDISPLAY        # * CONSTANT, USED IN SHOWSUM ONLY
                TC      +2
                CA      S-1             # FOR BANK 00
                TS      SKEEP1
                CA      SKEEP4
                TC      LEFT5
                CS      A
                AD      SKEEP1
                TC      -1CHK
                TC      NXTBNK

# INITIALIZE SKEEP6 TO +1 TO PERFORM SHOWSUM
# START OF ROUTINE THAT DISPLAYS SUM OF EACH BANK
SHOWSUM         CAF     S+1
                TS      SKEEP6          # SHOWSUM OPTION
                CAF     S+ZERO
                TC      SHOWSUM1
SHOWSUM3        INHINT
                CAF     PRIO2
                TC      NOVAC
                EBANK=  SELFRET
                2CADR   STSHOSUM

                RELINT
                TC      ENDOFJOB

SDISPLAY        CA      SKEEP4
                TC      LEFT5           # CYCLES LEFT 5 PLACES
                XCH     SKEEP2          # SKEEP2 HOLDS BANK NUMBER DURING DISPLAY
                TS      SKEEP3          # SKEEP3 HOLDS BUGGER WORD DURING DISPLAY
NOKILL          CAF     ADRS1           # ADDRESS OF SKEEP1
                TS      MPAC +2
                CAF     VNCON           # DISPLAY 3 REGISTERS
                TC      NVSUB
                TC      SBUSY
                TC      FLASHON
                TC      ENDIDLE
                TC      +3              # FINISHED WITH SHOWSUM
                TC      NXTBNK
                TC      NOKILL          # SO CAN LOAD WITHOUT KILLING SHOWSUM
                TC      SDISPLY1
SDISPLY2        TC      ENDOFJOB

SBUSY           CAF     SCADR
                TC      NVSUBUSY

                TC      SMODECHK

# MULTIPLY SUBROUTINE TAKES APPROXIMATELY 19 SECONDS.
# (37777) X (37777 THROUGH 00001)
# C(A) COUNTS DOWN.  C(L) COUNTS UP.
MPNMBRS         CAF     S+MAX
                TS      SKEEP2
                CAF     S+MAX
                EXTEND
                MP      SKEEP2
                AD      L               # C(A) = 37777
                AD      S-MAX
                TC      -0CHK
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CCS     SKEEP2
                TS      SKEEP2
                CCS     SKEEP2
                TC      MPNMBRS +2
# (-1) X (37777 THROUGH 00001)
                CAF     S+MAX
                TS      SKEEP2
MPHIGH1         CAF     S-1
                EXTEND
                MP      SKEEP2          # C(A) = -0
                TC      -0CHK
                CA      L
                AD      SKEEP2
                TC      -0CHK
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CCS     SKEEP2
                TS      SKEEP2
                CCS     SKEEP2
                TC      MPHIGH1

# INTERCHANGE MULTIPLIER AND MULTIPLICAND
# (37777 THROUGH 00001) X (37777)
# C(A) COUNTS DOWN.  C(L) COUNTS UP.
                CAF     S+MAX
                TS      SKEEP1
MPAGAIN         CA      SKEEP1
                EXTEND
                MP      S+MAX
                AD      L               # C(A) = 37777
                AD      S-MAX
                TC      -0CHK
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CCS     SKEEP1
                TS      SKEEP1
                CCS     SKEEP1
                TC      MPAGAIN
# (37777 THROUGH 00001) X (-1)
                CAF     S+MAX
                TS      SKEEP1
MPHIGH2         CA      SKEEP1
                EXTEND
                MP      S-1
                TC      -0CHK
                CA      L
                AD      SKEEP1
                TC      -0CHK
                TC      CHECKNJ         # CHECK FOR NEW JOB
                CCS     SKEEP1
                TS      SKEEP1
                CCS     SKEEP1
                TC      MPHIGH2

                TC      SMODECHK

# ONCE THROUGH DIVIDE SUBROUTINE TAKES APPROXIMATELY 0.01 SECOND.
# TOTAL TIME SPENT IN DIVIDE SUBROUTINE IS APPROXIMATELY 21.5 SECONDS
# DIVIDE +-/17777/ +-/37777/ BY +-/20000/. THE CONTENTS OF THE A REGISTER
# AND THE L REGISTER WILL HAVE OPPOSITE SIGNS BEFORE DIVISION. THE
# QUOTIENT SHOULD BE +-/37774/ DEPENDING ON THE SIGN OF A AND THE SIGN
# OF THE DIVISOR. THE REMAINDER = +-1 DEPENDING ON THE SIGN OF A
DVCHECK         CS      SBIT12          # -(04000)
                TS      SKEEP4
DVLOOP          INCR    SKEEP4
DV1CHK          CA      SBIT14          # 20000
                TS      SKEEP1
                CS      A
                TS      SKEEP2
DV1++           CS      S+MAX
                TS      L               # 40000
                CA      S13BITS
                EXTEND
                DV      SKEEP1          # +37774, +1
                TS      SKEEP7          # 37774
                CA      S-MAX
                XCH     L               # ALSO PUT 40000 IN L
                TC      +1CHK
DV1+-           CA      S13BITS         # 17777
                EXTEND
                DV      SKEEP2          # -37774, +1
                AD      SKEEP7
                TC      -0CHK
                CA      S+MAX
                XCH     L               # ALSO PUT 37777 IN L
                TC      +1CHK
DV1-+           CS      S13BITS         # 60000
                EXTEND
                DV      SKEEP1          # -37774, -1
                TS      SKEEP6
                AD      SKEEP7
                TC      -0CHK
                CA      S+MAX
                XCH     L               # ALSO PUT 37777 IN L
                TC      -1CHK
DV1--           CS      S13BITS         # 60000
                EXTEND
                DV      SKEEP2          # +37774, -1
                AD      SKEEP6
                TC      -0CHK
                CA      S+MAX
                XCH     L               # ALSO PUT 37777 IN L FOR DV2
                TC      -1CHK
                CA      SKEEP6          # -37774
                AD      S-2             # -37776
                AD      S+MAX
                TC      +1CHK

# DIVIDE +17777 + 37777 BY +20000.  THE RESULT SHOULD BE +37777 WITH
# +17777 REMAINDER.
DV2CHK          CA      S13BITS
                EXTEND
                DV      SKEEP1
                AD      S-MAX
                TC      -0CHK
                CS      SBIT14          # -20000
                AD      L
                TC      -1CHK

# DIVIDE +37776 BY +37776.  THE RESULT SHOULD BE +37777 AND THE
# REMAINDER SHOULD BE +37776.
DV4CHK          CA      S+ZERO
                TS      L
                CA      DVCON
                TS      SKEEP1          # 37776
                EXTEND
                DV      SKEEP1
                CS      A
                AD      DVCON
                TC      -1CHK
                CA      L               # 37776
                AD      S-MAX
                TC      -1CHK

# DIVIDE SAME (ZERO).  THE CONTENTS OF THE A REGISTER AND L REGISTER WILL
# HAVE OPPOSITE SIGNS BEFORE DIVISION.  THE QUOTIENT WILL BE + OR - MAX.,
# DEPENDING UPON THE SIGN OF THE L REGISTER AND THE SIGN OF THE DIVISOR.
# C(L) REMAINS THE SAME BECAUSE IT IS THE DIVIDEND.
DV5CHK          CA      S+ZERO
                TS      SKEEP1          # +0
                TS      L
                CS      A
                TS      SKEEP2          # -0
DV5++           EXTEND
                DV      SKEEP1          # +37777, +0
                TS      SKEEP7          # 37777
                CA      L
                TC      +0CHK
DV5+-           CS      A
                EXTEND
                DV      SKEEP2          # 40000, +0
                TS      SKEEP6          # 40000
                AD      SKEEP7
                TC      -0CHK
                CS      A
                XCH     L               # ALSO PUT -0 IN L
                TC      +0CHK
DV5-+           EXTEND
                DV      SKEEP1          # 40000, -0
                AD      SKEEP7
                TC      -0CHK
                CA      L
                TC      -0CHK
DV5--           EXTEND
                DV      SKEEP2          # 37777, -0
                AD      SKEEP6
                TC      -0CHK
                CA      L
                TC      -0CHK
                CA      SKEEP6          # CHECK QUOTIENT
                AD      DVCON
                TC      -1CHK

                TC      CHECKNJ         # CHECK FOR NEW JOB
                CA      SKEEP4
                EXTEND
                BZMF    DVLOOP
                INCR    SCOUNT +2
                TC      SELFCHK         # START SELF-CHECK AGAIN


## MAS 2023: The following chunks of code (down to ENDSLFS1) were added as patches
## between Aurora 85 and Aurora 88. They were placed here at the end of the bank
## so as to not change addresses of existing symbols.

ERASLP1         INHINT
                EXTEND
                INDEX   SKEEP7
                DCA     0000
                DXCH    SKEEP5          # STORES C(X) AND C(X-1) IN SKEEP6 AND 5.
                CA      SKEEP7
                TC      ERASLP2

ERASLP3         NDX     SKEEP7
                DXCH    0000            # PUT B(X) AND B(X+1) BACK INTO X AND X+1
                CA      S+ZERO
                TS      ERESTORE        # IF RESTART, DO NOT RESTORE C(X), C(X+1)
                TC      ERASLP4



SELFADRS        GENADR  SELFCHK         # SELFCHK RETURN ADDRESS.  SHOULD BE PUT
                                        # IN SELFRET WHEN GOING FROM SELFCHK TO
                                        # SHOWSUM AND PUT IN SKEEP1 WHEN GOING
                                        # FROM SHOWSUM TO SELF-CHECK.



SHOWSUM1        TC      POSTJUMP
                CADR    SHOWSUM2



SDISPLY1        TC      FREEDSP
                CA      SELFADRS        # INITIALIZE SKEEP1 TO GO TO SELFCHK.
                TS      SKEEP1
                TC      SDISPLY2

ENDSLFS1        EQUALS

                SETLOC  ENDFAILS

SBNKOPTN        TS      SKEEP1
                CS      A               # GO TO BACKUP IDLE LOOP IF C(SMODE) IS
                AD      OCT11           # GREATER THAN OCTAL 11
                EXTEND
                BZMF    TOSMODE -2
                CA      S+ZERO          # ZERO SMODE FOR OPTIONS ABOVE 8.
                TS      SMODE
                CA      SKEEP1
                NDX     A
                TC      SOPTON11 -1
SOPTON11        TC      DSKYCHK

                CA      S+ZERO
                TS      SMODE
TOSMODE         TC      POSTJUMP
                CADR    SMODECHK

# THE FOLLOWING CONSTANTS ARE USED BY DSKYCHK.
DSKYCODE        OCTAL   05265           # 00
                OCTAL   04143           # 11
                OCTAL   05471           # 22
                OCTAL   05573           # 33
                OCTAL   04757           # 44
                OCTAL   05736           # 55
                OCTAL   05634           # 66
                OCTAL   05163           # 77
                OCTAL   05675           # 88
                OCTAL   05777           # 99
+-ZERO          OCTAL   07265
11DEC.          OCTAL   00013

# BITS 2 AND 6 TURN ON THE COMPUTER ACTIVITY AND VERB-NOUN FLASH.
S11CHAN         OCTAL   00042

DSKYCHK         CAF     TEN
                TS      SKEEP3
                INHINT
                CAF     S+1             # SET UP TEN MS INTERRUPT
                TC      WAITLIST
                2CADR   NXTNMBR

                RELINT
                TC      TOSMODE         # GO TO IDLE LOOP

SDSPTAB         TS      SKEEP3
                INHINT
                NDX     SKEEP3
                CS      DSKYCODE
SBLANKS         TS      DSPTAB
                TS      DSPTAB +1
                TS      DSPTAB +2
                TS      DSPTAB +3
                TS      DSPTAB +4
                TS      DSPTAB +5
                TS      DSPTAB +6
                TS      DSPTAB +7
                TS      DSPTAB +8D
                TS      DSPTAB +9D
                TS      DSPTAB +10D
                CA      11DEC.
                TS      NOUT

DSKYWAIT        INHINT
                CAF     BIT10           # 5.12 SECOND WAIT
                TC      WAITLIST
                2CADR   NXTNMBR

                RELINT
                TC      TASKOVER

NXTNMBR         CCS     SKEEP3
                TC      SDSPTAB         # 9 THROUGH 0
                TC      -SIGN           # -ZEROS
                TC      +SIGN           # +ZEROS
                CCS     SKEEP2
                TC      NODSPLAY        # PUTS BLANKS IN DSKY DISPLAY
                TC      LITESOUT        # TURN OFF LIGHTS

-SIGN           CS      S+1
                TS      SKEEP3
                CA      S11CHAN         # TURN ON VERB-NOUN FLASH
                EXTEND                  # AND COMPUTER ACTIVITY LIGHTS.
                WOR     DSALMOUT
                CS      +-ZERO
                INHINT
                TS      DSPTAB
                TS      DSPTAB +3
                TS      DSPTAB +5
                CAF     THREE
                TS      NOUT
                TC      DSKYWAIT
+SIGN           CS      ZERO
                TS      SKEEP3
                CA      S+1
                TS      SKEEP2
                INHINT
                CS      +-ZERO
                TS      DSPTAB +1
                TS      DSPTAB +4
                TS      DSPTAB +6
                CAF     THREE
                TS      NOUT
                TC      DSKYWAIT

NODSPLAY        TS      SKEEP2          # +0
                CS      BIT12           # BLANKS
                INHINT
                TC      SBLANKS         # PUTS BLANKS IN ALL DISPLAYS

LITESOUT        CS      S11CHAN
                EXTEND
                WAND    DSALMOUT        # TURN OFF COMPUTER ACTIVITY LIGHT.
                TC      TASKOVER        # END OF DSKYCHK

ENDSLFS2        EQUALS
