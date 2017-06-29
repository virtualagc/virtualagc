### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_BLK2_INSTRUCTION_CHECK.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-20 MAS  Imported from Retread 44 into banks 22 and 23. Tweaked
##                              to share memory with Aurora's SELF-CHECK in the process.
##                              Some labels also had an "R" attached to denote the Retread
##                              version of tests that had the same name in Aurora.


                EBANK=          LST1

                SETLOC          ENDSELFF
# Constants for retread instruction check. Some are shared between both banks.

# ADDRESSES OF ERASABLE REGISTERS
ADRS2           ADRES           SKEEP2
ADRS3           ADRES           SKEEP3
ADRS4           ADRES           SELF1
ADRS5           ADRES           SELF2
ADRS6           ADRES           S+MAX
ADRS7           ADRES           SELF3

# CONSTANTS USED THROUGHOUT THE INSTRUCTIONS CHECK

S6BITS          OCTAL           00077
S7BITS          OCTAL           00177
SODD            OCTAL           25252                           # SEVEN ONE BITS
ALARMCON        OCTAL           40400
SINOUT1         OCTAL           52500
SEVENS          OCTAL           52525                           # EIGHT ONE BITS
SINOUT2         OCTAL           52552
CYRCON          OCTAL           57761
SINOUT3         OCTAL           77725
S-15            OCTAL           77760
S-14            OCTAL           77761
S-6             OCTAL           77771
S-5             OCTAL           77772

# NEXT TWO CONSTANTS ARE USED IN THE DEVIDE SUBROUTINE
DV1CON          OCTAL           14000
DV2CON          OCTAL           37776

# NEXT TWO CONSTANTS ARE ADDRESSESS USED BY EXTRACODE INDEX INSTRUCTIONS
ADRS+1R         ADRES           S+1
ADRSDV1         ADRES           DV1CON

ENDRTRDF        EQUALS

                BANK            22

# NORMAL USE OF TC AND TCF
TCCHK           TC              +2                              
                TC              RCCSCHK                          
                TCF             +2
                TC              ERRORS                          
                TC              Q
                TC              ERRORS                          

# NORMAL USE OF CA, CS, AND CCS
RCCSCHK         CA              S-3
                TS              SKEEP1
                CCS             SKEEP1
                TC              ERRORS                          
                TC              ERRORS                          
                TC              +2                              
                TC              ERRORS                          
                CCS             A                               # C(A) =+2, RESULT OF CCS -NUMBER
                TC              +4                              
                TC              ERRORS                          
                TC              ERRORS                          
                TC              ERRORS                          
                CCS             A                               # C(A) = +1, RESULT OF CCS + NUMBER
                TC              +4
                TC              ERRORS                          
                TC              ERRORS                          
                TC              ERRORS                          
                CCS             A                               # C(A) = +0, RESULT OF CCS + NUMBER
                TC              ERRORS                          
                TC              +3                              
                TC              ERRORS                          
                TC              ERRORS                          
                CS              A
                CCS             A                               # C(A) = -0, RESULT OF CCS +0
                TC              ERRORS                          
                TC              ERRORS                          
                TC              ERRORS                          
                CCS             A                               # RESULT OF CCS -0
                TC              ERRORS                          
                TC              +3                              
                TC              ERRORS                          
                TC              ERRORS                          

# NORMAL USE OF MASK
MSKCHK          CS              S-ZERO
                MASK            S-ZERO                          # 00000, 77777
                TC              -0CHK           -1
                CS              S+ZERO
                MASK            S+ZERO                          # 77777, 00000
                TC              -0CHK           -1
                CA              S+ZERO
                MASK            S+ZERO                          # 00000, 00000
                TC              -0CHK           -1
                CA              S-ZERO
                MASK            S-ZERO                          # 77777, 77777
                TC              -0CHK
# NO EDIT FEATURE OF MASK IS CHECKED
# BITS 9-14 OF WRITE LINES GO TO BITS 1-7 OF EDOP
                CA              S-ZERO                          # 77777
                TS              EDOP                            # 00177
                MASK            EDOP                            # 00177
                TS              SKEEP1                          # 00177
                MASK            EDOP                            # 00177
                CS              A                               # 77600
                AD              SKEEP1                          # 77777
                TC              -0CHK
# CHECK MASK OF AN SC REGISTER
                CA              S+1
                TS              L
                CA              S-ZERO
                MASK            L
                TC              -1CHK           -1

# NORMAL USE OF XCH, AD, AND TS
                CA              S+MAX                           # 37777
                TS              SKEEP1
                AD              SKEEP1                          # 01 - 37776
                TS              SKEEP2                          # 37776
                TC              ERRORS
                TC              -1CHK           -1
                XCH             SKEEP1                          # SSKEEP1 NOW +0
                CS              A                               # 40000
                AD              A                               # 10 - 00001
                TS              SKEEP3                          # 40001, C(A) = -1
                TC              ERRORS
                AD              SKEEP3                          # C(A) = 40000
                AD              SKEEP2                          # C(A) = -1
                AD              SKEEP1                          # C(A) = -1
                TS              SKEEP4                          # -1
                CS              SKEEP4                          # +1
                TC              -1CHK           -1

# NORMAL USE OF INCR
# NOT CHECKING COUNTER INTERRUPT
                CA              S+MAX                           # 37777
                TS              SKEEP1
                INCR            SKEEP1                          # +0
                INCR            SKEEP1                          # +1
                INCR            SKEEP1                          # +2
                AD              S-MAX
                TC              -0CHK                           # CHECK C(A) HAS NOT CHANGED
                CS              SKEEP1
                TS              SKEEP1                          # -2
                INCR            SKEEP1                          # -1
                CA              SKEEP1
                TC              -1CHK
# CHECK     INCREMENT OF AN SC REGISTER
                CA              S-2
                TS              L
                INCR            L
                CA              L
                TC              -1CHK

# NORMAL USE OF ADS
                CA              SBIT13
                TS              SKEEP1                          # 10000
                ADS             SKEEP1                          # 20000
                ADS             SKEEP1                          # OV WITH +0
                TS              SKEEP2
                TC              ERRORS
                CS              SKEEP1
                TC              -0CHK
# CHECKS ADS OF AN SC REGISTER
                CA              S13BITS                         # 17777
                TS              L
                AD              S+1                             # C(A) = 20000
                ADS             L
                AD              S-MAX
                TC              -0CHK
                CS              L
                AD              S+MAX
                TC              -0CHK

# NORMAL USE OF LXCH
                CA              S+1
                TS              SKEEP1                          # +1
                LXCH            SKEEP1                          # +1 IN L
                CS              A
                TS              SKEEP2                          # -1 IN SKEEP2
                LXCH            SKEEP2                          # L = -1, SKEEP2 = +1
                CS              SKEEP2
                TC              -1CHK
                CA              L
                TC              -1CHK

# UNDERFLOW AND OVERFLOW IS LOST IN L REGISTER
                CA              S+MAX
                AD              A
                TS              L                               # OV WITH 37776
                TC              ERRORS
                CS              S+MAX
                AD              A                               # UV WITH 40001
                LXCH            A                               # C(A) = 37776, C(L) = 40001
                TS              SKEEP1                          # 37776
                TC              +2
                TC              ERRORS
                CA              L
                TS              SKEEP2                          # 40001
                TC              +2
                TC              ERRORS
                AD              SKEEP1                          # -0
                TC              -0CHK

# NORMAL USE OF DXCH
                CA              S+MAX
                TS              SKEEP2                          # 37777, K+1
                CS              A
                TS              L                               # 40000
                AD              S+1
                TS              SKEEP1                          # 40001, K
                CS              A                               # 37776
                DXCH            SKEEP1
# A = 40001, L = 37777 ....... SKEEP1 = 37776, SKEEP2 = 40000
                AD              L
                TC              -1CHK           -1
                CA              SKEEP1
                AD              SKEEP2
                TC              -1CHK

# NORMAL USE OF DAS (6 CHECKS)
# IF ADDRESS OF K DOES NOT = ZERO, C(L) = +0 AND C(A) = NET OVERFLOW
# C(A) = +0 IF NO OVERFLOW OR UNDERFLOW
# DAD++ WITH NO OVERFLOW
RDAS++          CAF             S13BITS
                TS              SKEEP1                          # 17777
                TS              SKEEP2                          # 17777
                TS              L                               # 17777
                AD              S+1                             # 20000
                DAS             SKEEP1
# C(SKEEP1) = 37777, C(SKEEP2) = 377776
                TC              -0CHK           -1
                XCH             L
                TC              -0CHK           -1
                CS              SKEEP1
                AD              SKEEP2
                TC              -1CHK
# DAS++ WITH OVERFLOW
DAS++OV         CA              S+MAX
                TS              SKEEP1                          # 37777
                TS              SKEEP2                          # 37777
                TS              L                               # 37777
                CA              S+1                             # +1
                DAS             SKEEP1
# C(SKEEP1) = +1, C(SKEEP2) = 37776, C(A) = +1,
                TC              -1CHK           -1
                XCH             L
                TC              -0CHK           -1
                CS              SKEEP1
                TC              -1CHK
                CA              S-MAX
                AD              SKEEP2
                TC              -1CHK
# DAS MIXED SIGNS
DAS+--+         CA              S+MAX
                TS              SKEEP1                          # 37777
                CS              A
                TS              SKEEP2                          # 40000
                CS              A
                AD              S-1
                TS              L                               # 37776
                CS              A                               # 40001
                DAS             SKEEP1
# C(SKEEP1) = +1, C(SKEEP2) = -1
                TC              -0CHK           -1
                XCH             L
                TC              -0CHK           -1
                CA              SKEEP1
                TC              -1CHK           -1
                CA              SKEEP2
                TC              -1CHK
# DAS-- WITH NO UNDERFLOW
DAS--           CS              S13BITS
                TS              SKEEP1                          # 60000
                TS              SKEEP2                          # 60000
                TS              L                               # 60000
                AD              S-1                             # 57777
                DAS             SKEEP1
# C(SKEEP1) = 40000, C(SKEEP2) = 40001
                TC              -0CHK           -1
                XCH             L
                TC              -0CHK           -1
                CS              SKEEP2
                AD              SKEEP1
                TC              -1CHK
# DAS-- WITH UNDERFLOW
DAS--UV         CA              S-MAX
                TS              SKEEP1                          # 40000
                TS              SKEEP2                          # 40000
                TS              L                               # 40000
                CA              S-1                             # -1
                DAS             SKEEP1
# C:SKEEP1) = -1, C(SKEEP2) = 40001, C(A) = -1
                TC              -1CHK
                XCH             L
                TC              -0CHK           -1
                CA              SKEEP1
                TC              -1CHK
                CA              S+MAX
                AD              SKEEP2
                TC              -1CHK           -1
# DAS A.  DOUBLES THE CONTENTS OF THE A REGISTER AND THE L REGISTER.
                CA              S-MAX
                TS              SKEEP2                          # 40000
                TS              L                               # 40000
                CS              A
                TS              SKEEP1                          # 37777
                DAS             A
# C(A) = OV 37775, C(L) = 40001
                TS              SKEEP3
                TC              ERRORS
                CA              L
                AD              SKEEP3
                TC              -1CHK

# NORMAL USE OF INDEX WITHOUT EXTRACODE.
# INSTRUCTIONS CHECKED WITH INDEX UP TO FIRST SPACE SKIPPED
# ARE CA, TS, XCH, CCS, AD, TC, TCF, TS WITH OVERFLOW, AND MASK
# FIRST INITIALIZE ERASABLE REGISTERS USED FOR INDEX INSTRUCTION
                CA              S+ZERO
                TS              NDX+0
                CA              ADRS6                           # ADDRESS OF S+MAX
                TS              NDX+MAX
                CA              ADRS1
                TS              NDXKEEP1
                CA              ADRS2
                TS              NDXKEEP2
                CA              ADRS3
                TS              NDXKEEP3
                CA              ADRS4
                TS              NDXSELF1
                CA              ADRS5
                TS              NDXSELF2
NDXCHK          NDX             NDX+MAX                         # CA S+MAX
                CA              0000                            # A = 37777
                NDX             NDXKEEP1                       # TS SKEEP1
                TS              0000                            # TS WITH NO OV, UV
                NDX             NDX+0                           # CS   A
                CS              0000                            # A = 40000
                NDX             NDXKEEP1                       # XCH SKEEP1
                XCH             0000                            # A = +MAX, SKEEP1 = - MAX
                NDX             NDX+0                           # CCS A
                CCS             0000                            # A = 37776
                TC              +4
                TC              ERRORS
                TC              ERRORS
                TC              ERRORS
                NDX             NDXKEEP1                       # AD SKEEP1
                AD              0000                            # A = -1
SELF1           NDX             NDXSELF1                        # TC +2
                TC              0003
                TC              ERRORS                          # DID NOT PERFORM A TC
                NDX             NDXSELF1                        # TC +2
                TC              0006
                TC              CNTINU                          # CHECK C(Q)
SELF2           NDX             NDXSELF2                        # TCF +2
                TCF             003
                TC              ERRORS
                TC              Q                               # SHOULD GO TO SELF1 +2
CNTINU          TC              -1CHK
                CA              S+MAX
                AD              S+1
                NDX             NDXKEEP1                       # TS SKEEP1 WITH OV
                TS              0000                            # A = +1, SKEEP1 = +0
                TC              ERRORS
                AD              SKEEP1                          # A = +1
                NDX             NDX+MAX                         # MASK S+MAX
                MASK            0000                            # A = +1
                TC              -1CHK           -1

# INDEX USED WITH ADS, NDX, AND INCR
                CA              S13BITS
                TS              SKEEP1
                NDX             NDX+0                           # INDEX +0
                NDX             NDXKEEP1                       # ADS SKEEP1
                ADS             0000                            # C(A) AND C(SKEEP1) = 377776
                NDX             NDXKEEP1                       # INCR SKEEP1
                INCR            0000                            # C(SKEEP1) = 37777
                CS              A                               # 40001
                AD              SKEEP1                          # A = +1
                TC              -1CHK           -1
# INDEX USED WITH LXCH, DAS, AND DXCH
                CA              S-MAX
                TS              SKEEP2                          # SKEEP2 HOLDS 40000, SKEEP1 HOLDS 37777
                CA              S+1
                TS              SKEEP3                          # +1
                NDX             NDXKEEP3                       # LXCH SKEEP3
                LXCH            0000                            # C(L) = +1
                CA              S-2
                NDX             NDXKEEP1                       # DAS SKEEP1
                DAS             0000
# BEFORE DAS, K = 37777   K+1 = 40000
#             A = -1      L   = +1
# AFTER  DAS, K = 37775   K+1 = 40001
#            A = +0    L  = +0
                NDX             NDXKEEP1                       # DXCH SKEEP1
                DXCH            0000
                AD              L
                TC              -1CHK
                CS              SKEEP1
                TC              -0CHK
                CA              SKEEP2
                TC              -0CHK           -1
# INDEX INSTRUCTION USED WITH OVERFLOW
                CA              ADRS7                           # ADDRESS OF SELF3
                AD              SBIT14
                TS              SKEEP7
SELF3           NDX             SKEEP7
                2               0002
                TC              ERRORS
# CHECK INDEX OF AN SC REGISTER
                CA              ADRS1                           # 01371, ADDRESS OF SKEEP1
                NDX             A
                TS              0000                            # PUT 01371 IN SKEEP1
                CS              A
                AD              SKEEP1
                TC              -0CHK

# START CHECKING EXTRACODE INSTRUCTIONS
# NORMAL USE OF DCA, DCS, AND SU
STRTXTRA        EXTEND
                DCA             SBIT1
# C(A) = +1, C(L) = +2
                TS              SKEEP2                          # +1
                XCH             L
                TS              SKEEP1                          # +2
                EXTEND
                SU              SKEEP2                          # C(SKEEP2) = +1
                TC              -1CHK           -1
                EXTEND
                DCS             SKEEP1
# C(A) = -2, C(L) = -1
                EXTEND
                SU              L
                TC              -1CHK
# COMPLEMENTING OF THE DOUBLE PRECISION ACCUMULATOR
                CA              S+MAX
                TS              L                               # 37777
                AD              A                               # OV37776
                EXTEND
                DCS             A
                TS              SKEEP1
                TC              ERRORS
                CA              SKEEP1
                EXTEND
                SU              L
                TC              -1CHK           -1

# CHECKS DCA OF AN SC REGISTER
                CA              S-2                             # -2
                TS              Q
                CA              S+1
                TS              L                               # +1
                CA              SBIT8
                EXTEND
                DCA             L
                CS              A                               # +2
                AD              L                               # -0
                TC              -0CHK

# NORMAL USE OF QXCH
                CA              QXCHCON1
                TS              SKEEP1                          # STORE ADDRESS OF AUGCHK IN SKEEP1
                TC              +2                              # Q NOW HOLDS ADDRESS OF QNMBR
QNMBR           TC              ERRORS
                EXTEND
                QXCH            SKEEP1                          # Q NOW HOLDS ADDRESS OF AUGCHK
                TC              Q                               # SHOULD GO TO QXCHCON2 +1, NOT QNMBR
                TC              ERRORS
QXCHCON1        ADRES           QXCHCON2        +1
QXCHCON2        ADRES           QNMBR
                CS              SKEEP1                          # CHECK THAT SKEEP HOLDS B(Q)
                AD              QXCHCON2
                TC              -0CHK
# CHECKS QXCH OF AN SC REGISTER
                CA              S+ZERO
                TC              +2
                TCF             +5
                EXTEND
                QXCH            A
                LXCH            Q
                TC              A
                CA              L
                TC              -0CHK           -1

# NORMAL USE OF AUG
AUGCHK          CA              S+ZERO
                TS              SKEEP1                          # +0
                CS              A
                TS              SKEEP2                          # -0
                EXTEND
                AUG             SKEEP1                          # +1
                EXTEND
                AUG             SKEEP1                          # +2
                TC              -0CHK                           # CHECK C(A) HAS NOT CHANGED
                EXTEND
                AUG             SKEEP2                          # -1
                EXTEND
                AUG             SKEEP2                          # -2
                EXTEND
                AUG             SKEEP2                          # -3
                TC              -0CHK           -1
                CA              SKEEP2
                AD              SKEEP1
                TC              -1CHK
# CHECKS AUG OF AN SC REGISTER
                CA              S-ZERO
                EXTEND
                AUG             A
                TC              -1CHK

# NORMAL USE OF DIM
DIMCHK          CA              S+ZERO
                TS              SKEEP1                          # +0
                EXTEND
                DIM             SKEEP1
                CA              SKEEP1
                TC              -0CHK           -1
                CS              A
                TS              SKEEP1                          # -0
                EXTEND
                DIM             SKEEP1
                CA              SKEEP1
                TC              -0CHK
                CA              S+2
                TS              SKEEP1                          # +2
                EXTEND
                DIM             SKEEP1                          # +1
                AD              S-1
                TC              -1CHK           -1              # CHECK C(A) HAS NOT CHANGED
                CA              SKEEP1
                TC              -1CHK           -1
                EXTEND
                DIM             SKEEP1
                TC              -0CHK           -1
                CA              SKEEP1
                TC              -0CHK
                CS              S+2
                TS              SKEEP2                          # -2
                EXTEND
                DIM             SKEEP2                          # -1
                CA              SKEEP2
                TC              -1CHK
                EXTEND
                DIM             SKEEP2                          # -0
                TC              -0CHK           -1
                CA              SKEEP2
                TC              -0CHK
# CHECKS DIM OF AN SC REGISTER
                CA              S-2
                EXTEND
                DIM             A
                TC              -1CHK

# NORMAL USE OF MSU
# MSU SAME (S+MAX AND S+MAX), RESULT +0
                CA              S+MAX
                TS              SKEEP1
                EXTEND
                MSU             SKEEP1
                TC              -0CHK           -1
# MSU SAME (+0 AND +0), RESULT +0
                TS              SKEEP2
                EXTEND
                MSU             SKEEP2
                TC              -0CHK           -1
# MSU SAME (-0 AND -0), RESULT +0
                CA              S-ZERO
                TS              SKEEP3
                EXTEND
                MSU             SKEEP3
                TC              -0CHK           -1
# MSU +0 AND 77777, RESULT = +1
                EXTEND
                MSU             SKEEP3
                TC              -1CHK           -1
# MSU 77777 AND +0, RESULT = -1
                CS              A
                EXTEND
                MSU             SKEEP2
                TC              -1CHK
# MSU +6 AND +7, RESULT = -1
                CA              S+7
                TS              SKEEP4
                CA              S+6
                TS              SKEEP5
                EXTEND
                MSU             SKEEP4
                TC              -1CHK
# MSU +7 AND +6, RESULT = +1
                CA              S+7
                EXTEND
                MSU             SKEEP5
                TC              -1CHK           -1
# MSU 77770 AND 77771, RESULT = -1
                CA              S-6
                TS              SKEEP6
                CA              S-7
                TS              SKEEP7
                EXTEND
                MSU             SKEEP6
                TC              -1CHK
# MSU 77771 AND 77770, RESULT = +1
                CA              S-6
                EXTEND
                MSU             SKEEP7
                TC              -1CHK           -1
# CHECKS MSU OF AN SC REGISTER ( -0 AND -0 = +0)
                CA              S-ZERO
                TS              L
                EXTEND
                MSU             L
                TC              -0CHK           -1

# NORMAL USE OF BZF
RBZFCHK         TC              +2
                TC              RBZMFCHK                        # CORRECT ADDRESS IN Q
                CAF             S+5
                EXTEND
                BZF             ERRORS

                CS              A
                EXTEND
                BZF             ERRORS
                CAF             S+ZERO
                EXTEND
                BZF             +2
                TC              ERRORS
                CS              A
                EXTEND
                BZF             +2
                TC              ERRORS
                TC              Q                               # SHOULD GO TO RBZFCHK +1
                TC              ERRORS

RBZMFCHK        TC              +2
                TC              MP1++                           # CORRECT ADDRESS IN Q
                CAF             SBIT9
                EXTEND
                BZMF            ERRORS
                CS              A
                EXTEND
                BZMF            +2
                TC              ERRORS
                CA              S+ZERO
                EXTEND
                BZMF            +2
                TC              ERRORS
                CS              A
                EXTEND
                BZMF            +2
                TC              ERRORS
                TC              Q                               # SHOULD GO TO RBZMFCHK +1
                TC              ERRORS

# NORMAL USE OF MP
# 37777 X 2
MP1++           CA              S+MAX                           # 37777
                EXTEND
                MP              S+2                             # C(A) = +1, C(L. = 37776
                AD              L
                TS              SKEEP1                          # 37777
MP1+-           EXTEND
                MP              S-2                             # C(A) = -1, C(L) = 40001
                AD              L
                TS              SKEEP2                          # 40000
MP1-+           EXTEND
                MP              S+2                             # C(A) = -1, C(L) = 40001
                AD              L
                TS              SKEEP3                          # 40000
MP1--           EXTEND
                MP              S-2                             # C(A) = +1, C(L) = 37776
                AD              L                               # 37777
                AD              SKEEP3                          # 77777
                AD              SKEEP2                          # 40000
                AD              SKEEP1                          # 77777
                TC              -0CHK
# 37777 X 37777
MP2++           CA              S+MAX                           # 37777
                EXTEND                                          # CHECKS RSC PULSE
                MP              A                               # C(A) = 37776, C(L) = +1
                AD              L
                TS              SKEEP1                          # 37777
MP2+-           EXTEND
                MP              S-MAX                           # C(A) = 40001, C(L) = -1
                AD              L
                TS              SKEEP2                          # 40000
MP2-+           EXTEND
                MP              S+MAX                           # C(A) = 40001, C(L) = -1
                AD              L
                TS              SKEEP3                          # 40000
MP2--           EXTEND
                MP              S-MAX                           # C(A) = 37776, C(L) = +1
                AD              L                               # 37777
                AD              SKEEP3                          # 77777
                AD              SKEEP2                          # 40000
                AD              SKEEP1                          # 77777
                TC              -0CHK
# C(A) = NON-ZERO, C(K) = ZERO
# RESULT IS ALWAYS POSITIVE ZERO
MP3++           CA              S+MAX                           # 37777
                EXTEND
                MP              S+ZERO
                AD              L
                TC              -0CHK           -1
MP3+-           CA              S+1
                EXTEND
                MP              S-ZERO
                AD              L
                TC              -0CHK           -1
MP3-+           CA              S-1
                EXTEND
                MP              S+ZERO
                AD              L
                TC              -0CHK           -1
MP3--           CA              S-ZERO
                EXTEND
                MP              S-ZERO
                AD              L
                TC              -0CHK           -1
# C(A) = ZERO, C(K) = NON-ZERO,
# RESULT IS + ZERO FOR A POSITIVE SIGN AND NEGATIVE
# ZERO FOR Z NEGATIVE SIGN
MP4++           CA              S+ZERO
                EXTEND
                MP              S+MAX
                AD              L
                TC              -0CHK           -1
MP4+-           EXTEND
                MP              S-1
                AD              L
                TC              -0CHK
MP4-+           CS              A
                EXTEND
                MP              S+5
                AD              L
                TC              -0CHK
MP4--           CS              A
                EXTEND
                MP              S-ZERO
                AD              L
                TC              -0CHK           -1
# MULTIPLY ZERO X ZERO
# RESULT IS ALWAYS PLUS ZERO
MP5++           CA              S+ZERO
                TS              SKEEP1
                EXTEND
                MP              SKEEP1
                AD              L
                TC              -0CHK           -1
MP5+-           EXTEND
                MP              S-ZERO
                AD              L
                TC              -0CHK           -1
MP5-+           CA              S-ZERO
                EXTEND
                MP              S+ZERO
                AD              L
                TC              -0CHK           -1
MP5--           CA              S-ZERO
                EXTEND
                MP              S-ZERO
                TC              -0CHK           -1

                CA              RCONTINU
                TC              BANKJUMP
RCONTINU        CADR            RDV1++                          # CONTINUE WITH INSTRUCTION CHECK

ENDINST1        EQUALS

                BANK            23

# This is dangerous; see the other commented-out CHECKNJ above.
                #TC              CHECKNJ                         # CHECK FOR NEW JOB

# NORMAL USE OF DV ... REMAINDER HAS SIGN OF DIVIDEND
# 1/4 DIVIDED BY 3/8
# C(A) = 25252 WITH A + QUOTIENT AND 52525 WITH A - QUOTIENT.
# C(L) = REMAINDER = /100000/ WITH SIGN OF DIVIDEND.
RDV1++          CA              DV1CON                          # 14000
                TS              SKEEP7                          # 14000, +3/8
                TS              Q
                CS              A
                TS              SKEEP6                          # 63000, -3/8
                CA              S+ZERO
                TS              L
                CA              SBIT13                          # 10000
                EXTEND
                DV              Q                               # CHECKS RSC PULSE
                TS              SKEEP1                          # 25252
                CA              S+ZERO
RDV1+-          LXCH            A
                EXTEND
                DV              SKEEP6
                AD              SKEEP1
                TC              -0CHK
                CA              S-ZERO
                LXCH            A
RDV1-+          CS              A
                EXTEND
                DV              SKEEP7
                TS              SKEEP1                          # 52525
                CA              S-ZERO
RDV1--          LXCH            A
                EXTEND
                DV              SKEEP6
                AD              SKEEP1
                TC              -0CHK
                CA              L
                AD              SBIT13
                TC              -0CHK
# 1/2 TO 15TH DIVIDED BY 1/2 TO 14TH
# C(A) SHOULD BE 1/D AND CONTENTS OF L SHOULD BE ZERO
DV2++           CA              S+1
                TS              SKEEP7                          # 00001, DIVISOR
                CS              A
                TS              SKEEP6                          # 77776, DIVISOR
                CA              S+ZERO
                CA              SBIT14                          # 20000
                TS              L
                CA              S+ZERO
                EXTEND
                DV              SKEEP7                          # C(A) = 1/2, C(L) = +0
                TS              SKEEP1
DV2+-           LXCH            A
                EXTEND
                DV              SKEEP6
                TS              SKEEP2                          # -1/2
                AD              SKEEP1
                TC              -0CHK
                CA              SKEEP2
                LXCH            A
DV2-+           CS              A
                EXTEND
                DV              SKEEP7
                TS              SKEEP2
DV2--           LXCH            A
                EXTEND
                DV              SKEEP6
                TS              SKEEP1
                AD              SKEEP2
                TC              -0CHK
                CS              SKEEP1                          # MAKE SURE QUOTIENT IS 1/2
                AD              SBIT14
                TC              -0CHK
                CA              L
                TC              -0CHK
# SAME AS PREVIOUS DIVISION EXCEPT A AND L WILL HAVE OPPOSITE SIGNS
# BEFORE DIVISION.  SINCE A WILL ALWAYS BE ZERO, THE SIGN OF THE QUOTIENT
# WILL DEPEND ON THE SIGN OF L AND THE SIGN OF THE DIVISOR.
DV3++           CA              SBIT14                          # 20000
                TS              L
                CA              S-ZERO
                EXTEND
                DV              SKEEP7
                TS              SKEEP1                          # 20000
DV3+-           LXCH            A
                CS              A                               # A = -0
                EXTEND
                DV              SKEEP6
                AD              SKEEP1
                TC              -0CHK
                CS              SBIT14                          # -1/2
DV3-+           LXCH            A
                EXTEND
                DV              SKEEP7
                TS              SKEEP1
DV3--           LXCH            A
                CS              A                               # A = +0
                EXTEND
                DV              SKEEP6
                AD              SKEEP1
                TC              -0CHK
                CS              L
                TC              -0CHK           -1

# C(A) = 17777 AND C(L) = 37777.  THIS IS DIVIDED BY 20000.  THE RESULT
# SHOULD BE +-/37777/ AND THE REMAINDER +-/17777/
DV4++           CA              S+MAX
                TS              L
                CA              SBIT14
                TS              SKEEP7                          # 20000
                CS              A
                TS              SKEEP6                          # 57777
                CA              S13BITS                         # 17777
                EXTEND
                DV              SKEEP7
                TS              SKEEP1
DV4+-           LXCH            A
                EXTEND
                DV              SKEEP6
                TS              SKEEP2
                AD              SKEEP1
                TC              -0CHK
                CA              SKEEP2
                LXCH            A
DV4-+           CS              A
                EXTEND
                DV              SKEEP7
                AD              SKEEP1
                TC              -0CHK
                CA              SKEEP2
DV4--           LXCH            A
                EXTEND
                DV              SKEEP6
                TS              SKEEP3
                AD              SKEEP2
                TC              -0CHK
                CS              SKEEP3
                AD              S+MAX
                TC              -0CHK
                CA              L
                AD              S13BITS
                TC              -0CHK
# C(A) = +-/17777/ AND C(L) = +-/37777/ WITH OPPOSITE SIGN BEFORE DEVISION
# THE QUOTIENT SHOULD BE +-/37774/ WITH THE SIGN DEPENDING ON THE SIGN OF
# A AND THE SIGN OF THE DEVISOR. THE C(L) = +-/1/ DEPENDING ON THE SIGN
# OF A.
RDV5++          CS              S+MAX
                TS              L                               # 40000
                CA              S13BITS                         # 17777
                EXTEND
                DV              SKEEP7
                TS              SKEEP1                          # 37774
                XCH             L
                TC              -1CHK           -1

RDV5+-          CA              S-MAX
                TS              L                               # 40000
                CA              S13BITS                         # 17777
                EXTEND
                DV              SKEEP6                          # C(A) = -37774, C(L) = +1
                AD              SKEEP1
                TC              -0CHK
                XCH             L
                TC              -1CHK           -1
RDV5-+          CA              S+MAX
                TS              L                               # 37777
                CS              S13BITS                         # 60000
                EXTEND
                DV              SKEEP7                          # C(A) = -37774, C(L) = -1
                TS              SKEEP2
                AD              SKEEP1
                TC              -0CHK
                XCH             L
                TC              -1CHK
RDV5--          CA              S+MAX
                TS              L                               # 37777
                CS              S13BITS                         # 60000
                EXTEND
                DV              SKEEP6                          # C(A) = 37774, C(L) = -1
                AD              SKEEP2
                TC              -0CHK
                XCH             L
                TC              -1CHK
                CA              SKEEP2                          # -37774
                AD              S-2                             # -37776
                AD              S+MAX                           # +1
                TC              -1CHK           -1              # CHECK THAT QUOTIENT IS +-/37774/

# DIVIDE SAME (37776).  THE RESULT SHOULD BE MAXIMUM AND THE REMAINDER
# SHOULD BE THE SAME VALUE AS THE DIVISOR WITH THE SAME SIGN AS THE
# DIVIDEND
DV6++           CA              S+ZERO
                TS              L
                CS              DV2CON                          # 37776
                TS              SKEEP6                          # 40001
                CS              A
                TS              SKEEP7                          # 37776
                EXTEND
                DV              SKEEP7
                CS              A
                AD              L
                TC              -1CHK
                CA              S+ZERO
DV6+-           LXCH            A
                EXTEND
                DV              SKEEP6
                AD              L
                TC              -1CHK
                CA              S-ZERO
DV6-+           LXCH            A
                CS              A
                EXTEND
                DV              SKEEP7
                CS              A
                AD              L
                TC              -1CHK           -1
                CA              S-ZERO
DV6--           LXCH            A
                EXTEND
                DV              SKEEP6
                AD              L
                TC              -1CHK           -1
                CS              L
                AD              SKEEP6
                TC              -0CHK
# DIVIDE SAME (ZERO).  THE RESULT SHOULD BE MAXIMUM AND THE REMAINDER
# SHOULD BE THE SAME VALUE AS THE DIVISOR WITH THE SAME SIGN AS THE
# DIVIDEND.
DV7++           CS              S+ZERO
                TS              SKEEP6                          # -0
                CS              A
                TS              SKEEP7                          # +0
                TS              L
                EXTEND
                DV              SKEEP7
                AD              S-MAX
                TC              -0CHK
DV7+-           LXCH            A                               # C(A) = C(L) = +0
                EXTEND
                DV              SKEEP6
                AD              S+MAX
                TC              -0CHK
                CS              A
DV7-+           LXCH            A
                CS              A                               # C(A) = C(L) = -0
                EXTEND
                DV              SKEEP7
                AD              S+MAX
                TC              -0CHK
                CS              A
DV7--           LXCH            A                               # C(A) = C(L) = -0
                EXTEND
                DV              SKEEP6
                AD              S-MAX
                TC              -0CHK
                CS              L
                TC              -0CHK           -1

# DEVIDE SAME (ZERO). THE CONTENTS OF THE A REGISTER AND L REGISTER WILL
# HAVE OPPOSITE SIGNS BEFORE DIVISION. THE SIGN OF THE QUOTIENT WILL
# DEPEND ON THE SIGN OF THE L REGISTER BEFORE DEVISION AND THE SIGN OF
# THE DEVISOR. THE SIGN OF THE REMAINDER IS THE SAME SIGN AS THE SIGN OF
# THE L REGISTER BEFORE DEVISION. C(L)  REMAINS SAME
DV8++           CA              S+ZERO
                TS              SKEEP7                          # +0
                TS              L
                CS              A
                TS              SKEEP6                          # -0
                EXTEND                                          # A = -0, L = +0
                DV              SKEEP7                          # A = L = +0
                TS              SKEEP1
                CA              L                               # C(A) = C(L) = +0
                TC              -0CHK           -1
DV8+-           CS              A
                EXTEND                                          # A = -0, L = +0
                DV              SKEEP6                          # A = -0, L = +0
                AD              SKEEP1
                TC              -0CHK
                CS              A
                XCH             L                               # PUT -0 IN L
                TC              -0CHK           -1              # CHECK C(L)
DV8-+           EXTEND                                          # A = +0, L = -0
                DV              SKEEP7                          # A = L = -0
                TS              SKEEP2
                AD              SKEEP1
                TC              -0CHK
                CS              A
                XCH             L                               # PUT -0 IN L
                TC              -0CHK                           # CHECK C(L)
DV8--           EXTEND                                          # A = +0, L = -0
                DV              SKEEP6                          # A = +0, L = -0
                AD              SKEEP2
                TC              -0CHK
                CA              S+MAX                           # CHECK QUOTIENT IS CORRECT
                AD              SKEEP2
                TC              -0CHK
                XCH             L
                TC              -0CHK                           # CHECK C(L)

# INPUT-OUTPUT INSTRUCTIONS
# NORMAL USE OF READ AND WRITE
IN-OUT1R        CA              S-1
                EXTEND
                WRITE           L                               # 77776
                CS              A                               # 00001
                EXTEND
                READ            L                               # 77776
                TC              -1CHK
                CA              S-MAX
                AD              S-MAX                           # C(A) = 10 - 00001
                EXTEND
                WRITE           Q
                CS              A                               # 01 - 37776
                EXTEND
                READ            Q                               #  10 - 00001
                TS              SKEEP1
                TC              ERRORS
                CA              SKEEP1
                AD              S+MAX
                TC              -1CHK           -1

# NORMAL USE OF RAND, RAND = READ AND MASK
RRANDCHK        CA              S+ZERO
                TS              L
                EXTEND
                RAND            L                               # 00000, 00000
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                RAND            L                               #  77777, 00000
                TC              -0CHK           -1
                CS              A
                TS              L
                CS              A
                EXTEND
                RAND            L                               # 00000, 77777
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                RAND            L                               # 77777, 77777
                TC              -0CHK
RANDOV          CA              S+MAX
                AD              S+2                             #  01 - 00001
                INHINT
                XCH             Q
                CA              S-ZERO                          #  77777
                EXTEND
                RAND            Q                               #  01 - 00001
                RELINT
                TS              SKEEP1
                TC              ERRORS
                TC              -1CHK           -1
                CS              SKEEP1
                TC              -1CHK

# NORMAL USE OF WAND, WAND = WRITE AND MASK
RWANDCHK        CA              S+ZERO
                TS              L
                EXTEND
                WAND            L                               # 00000, 00000
                AD              L
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                WAND            L                               # 77777, 00000
                AD              L
                TC              -0CHK           -1
                CS              A
                TS              L
                CS              A
                EXTEND
                WAND            L                               # 00000, 77777
                AD              L
                TC              -0CHK           -1
                CA              S-ZERO
                TS              L
                EXTEND
                WAND            L                               # 77777, 77777
                AD              L
                TC              -0CHK
WANDUF          CA              S+MAX
                AD              S+2                             # 01 - 00001
                INHINT                                          # This INHINT...RELINT was not present
                XCH             Q                               # in the original RETREAD, but is needed.
                CA              S-ZERO                          # 77777
                EXTEND
                WAND            Q
                RELINT
                TS              SKEEP2
                TC              ERRORS
                CA              Q
                TS              SKEEP1
                TC              ERRORS
                CS              SKEEP1
                TC              -1CHK
                CS              SKEEP2
                TC              -1CHK

# NORMAL USE OF ROR, READ AND SUPERIMPOSE
RRORCHK         CA              S+ZERO
                TS              L
                EXTEND
                ROR             L                               # 00000, 00000
                TC              -0CHK           -1
                CA              L
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                ROR             L                               # 77777, 00000
                TC              -0CHK
                CA              L
                TC              -0CHK           -1
                CS              A
                TS              L
                CS              A
                EXTEND
                ROR             L                               # 00000, 77777
                TC              -0CHK
                CA              L
                TC              -0CHK
                CA              S-ZERO
                EXTEND
                ROR             L                               # 77777, 77777
                TC              -0CHK
ROROV           CA              S-MAX
                AD              S-2                             # 10 - 37776
                INHINT
                XCH             Q
                CA              S+MAX
                AD              S+1                             # 01 - 00000
                EXTEND
                ROR             Q                               # 11 - 37776
                RELINT
                TS              SKEEP1
                TC              +2
                TC              ERRORS
                CA              SKEEP1
                TC              -1CHK

# NORMAL USE OF WOR, WOR = WRITE AND SUPERIMPOSE
RWORCHK         CA              S+ZERO
                TS              L
                EXTEND
                WOR             L                               # 00000, 00000
                TC              -0CHK           -1
                CA              L
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                WOR             L                               # 77777, 00000
                TC              -0CHK
                CA              L
                TC              -0CHK
                CS              A
                TS              L
                CS              A
                EXTEND
                WOR             L                               # 00000, 77777
                TC              -0CHK
                CA              L
                TC              -0CHK
                CA              S-MAX
                EXTEND
                WOR             L                               # 77777, 77777
                TC              -0CHK
                CA              L
                TC              -0CHK
WOROV           CA              S-MAX
                AD              S-2                             # 10 - 37776
                INHINT
                XCH             Q
                CA              S+MAX
                AD              S+1                             # 01 - 00000
                EXTEND
                WOR             Q                               # 11 - 37776
                RELINT
                TS              SKEEP2                          # SHOULD NOT SKIP
                TCF             +2
                TC              ERRORS
                XCH             Q
                TS              SKEEP3
                TC              +2
                TC              ERRORS
                CA              SKEEP3                          # CHECK C(Q)
                TC              -1CHK
                CA              SKEEP2
                TC              -1CHK                           # CHECK C(A)

# NORMAL USE OF RXOR
RRXORCHK        CA              S+ZERO
                TS              L
                EXTEND
                RXOR            L                               # 00000, 00000
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                RXOR            L                               # 77777, 00000
                TC              -0CHK
                CA              L
                TC              -0CHK           -1
                CS              A
                TS              L
                CS              A
                EXTEND
                RXOR            L                               # 00000, 77777
                TC              -0CHK
                CA              S-ZERO
                EXTEND
                RXOR            L                               # 77777, 77777
                TC              -0CHK           -1
                CA              L
                TC              -0CHK
                CS              A
                TS              Q
RXORUV          CA              S+MAX
                AD              S+2                             # 01 - 00001
                EXTEND
                RXOR            Q                               # 10 - 37776, C(Q) = -0
                TS              SKEEP1
                TC              ERRORS
                CA              SKEEP1
                TC              -1CHK

# Retread checked for a new job / fed the night watchman here. This is dangerous in Aurora;
# if a new job is found, the EXECUTIVE coding assumes that the address it returns to
# afterwards must be in the same bank as SELFCHECK, which means we'd end up jumping
# somewhere in the middle of that. It appears that the Retread instrution check executes
# quickly enough for this to be unnecessary, though, so I've simply commented it out for now.

                #TC              CHECKNJ                         # CHECK FOR NEW JOB
                TC              XTRANDX

# NEXT THREE CONSTANTS ARE ADDRESSESS USED BY EXTRACODE INSTRUCTIONS
ADRSBZMF        ADRES           NDXBZMF
ADRSDCA         ADRES           NDXDCA
ADRSQXCH        ADRES           NDXAUG

# NORMAL USE OF INDEX WITH EXTRACODE INSTRUCTIONS
# INDEX INSTRUCTION USED WITH INDEX AND BZF
XTRANDX         CA              S+ZERO
                EXTEND
                NDX             S+ZERO
                NDX             ADRSBZMF
                BZF             00000                           # BZF +2
                TC              ERRORS
# INDEX INSTRUCTION USED WITH BZMF
NDXBZMF         EXTEND
                NDX             ADRSDCA
                BZMF            0000                            # BZMF+2
                TC              ERRORS
# INDEX INSTRUCTION USED WITH DCA
NDXDCA          EXTEND
                INDEX           ADRS+1R                         # DCA S+1
                DCA             0000                            # C(A) = +1, C(L) = +2
                CS              A
                AD              L
                TC              -1CHK           -1
# INDEX INSTRUCTION USED WITH DCS
                EXTEND
                INDEX           ADRS+1R                         # DCS S+1
                DCS             0000                            # C(A) = -1, C(L) = -2
                CS              A
                AD              L
                TC              -1CHK
# INDEX INSTRUCTION USED WITH MP AND SU
                CA              S+MAX                           # 37777
                EXTEND
                NDX             ADRS+1R
                MP              0001                            # C(A) = 1, C(L) = 37776
                TC              -1CHK           -1
                CA              S+MAX                           # 37777
                EXTEND
                NDX             S+1
                SU              0000
                TC              -1CHK           -1
# INDEX INSTRUCTION USED WITH DV
NDXDV           CA              DV1CON                          # PUT 14000 (3/8) IN SKEEP3
                TS              SKEEP3
                CA              S+ZERO
                TS              L
                CA              SBIT13                          # 10000
                EXTEND
                NDX             ADRS3
                DV              0000                            # C(A) = 25252, C(L) = 10000
                TS              SKEEP1
                CA              S-ZERO
                XCH             L
                CS              A
                EXTEND
                NDX             ADRS3
                DV              0000
                AD              SKEEP1
                TC              -0CHK
# INDEX USED WITH MSU (C(A) = +0, C(K) = -0) (RESULT = -1)
NDXMSU          CA              S+ZERO
                TS              SKEEP1
                CS              A
                EXTEND
                NDX             ADRS1                           # MSU SKEEP1
                MSU             0000                            # C(A) = -1
                TC              -1CHK
# INDEX USED WITH QXCH
NDXQXCH         CA              ADRSQXCH
                TS              SKEEP1
                TC              +2
                TC              ERRORS
                EXTEND
                NDX             ADRS1                           # QCH SKEEP1
                QXCH            0000
                TC              Q
                TC              ERRORS
# INDEX USED WITH AUG
NDXAUG          CS              S+ZERO
                TS              SKEEP1                          # 00000
                EXTEND
                NDX             ADRS1                           # AUG SKEEP1
                AUG             0000
                CA              SKEEP1
                TC              -1CHK

# INDEX USED WITH DIM
NDXDIM          CA              S+2
                TS              SKEEP1
                EXTEND
                NDX             ADRS1                           # DIM SKEEP1
                DIM             0000
                CS              SKEEP1
                TC              -1CHK

# NORMAL USE OF INDEX WITH IN-OUT INSTRUCTIONS
# INDEX USED WITH WRITE AND READ
NDXINOUT        CA              S-1
                EXTEND
                NDX             S+1                             # WRITE L
                WRITE           0000
                CS              A
                EXTEND
                NDX             S+1                             # READ L
                READ            0000
                TC              -1CHK
# INDEX USED WITH RAND
                CA              S+1                             # 00001
                TS              L
                CA              S-ZERO                          # 77777
                EXTEND
                NDX             S+1                             # RAND L
                RAND            00000
                TC              -1CHK           -1
# INDEX USED WITH WAND
                CA              S-MAX                           # 40000
                AD              S+1                             # 40001
                TS              L
                CA              S+MAX                           # 37777
                EXTEND
                NDX             S+1                             # WAND L
                WAND            0000                            # C(A) = C(L) = +1
                TC              -1CHK           -1
                CS              L
                TC              -1CHK
# INDEX USED WITH ROR
                CA              S+1
                TS              Q
                CA              S+ZERO
                EXTEND
                NDX             S+2                             # ROR Q
                ROR             0000
                TC              -1CHK           -1
# INDEX USED WITH WOR
                CA              S-7
                TS              L                               # 77770
                CA              S+MAX
                AD              S-1                             # 37776
                EXTEND
                NDX             S+1                             # WOR L
                WOR             0000                            # C(A) = C(L) = -1
                TC              -1CHK
                CA              L
                TC              -1CHK
# INDEX USED WITH RXOR
                CA              S-1
                TS              L                               # 77776
                CA              S+MAX                           # 37777
                EXTEND
                NDX             S+1                             # RXOR L
                RXOR            0000                            # C(A) = 40001
                AD              S+MAX
                TC              -1CHK           -1
# CHECKS EXTRACODE OF AN SC REGISTER
                CA              S+2
                TS              SKEEP1
                CA              ADRS1                           # ADDRESS OF SKEEP1
                TS              L
                CA              S+1
                EXTEND
                NDX             L
                SU              0000
                TC              -1CHK

# CHECK OF SPECIAL AND CENTRAL REGISTERS
# CHANGE OF SIGN BY ADDING SAME NUMBER (ADDER)
ADDCHK          CA              SBIT14                          # 20000
                AD              A                               # 01 -00000
                TS              A
                TC              ERRORS
                AD              A                               # 10 - 00000
                TS              A
                TC              ERRORS
                AD              A                               # 00001
                TS              A
                TC              +2
                TC              ERRORS
                TC              -1CHK           -1

# NORMAL OPERATION OF CYCLE RIGHT REGISTER
CYRCHK          CA              CYRCON                          # 57761
                TS              SKEEP5                          # COUNTDOWN REGISTER
                CA              S-MAX                           # 40000
                TS              CYR
CYRLOOP         CCS             CYR
                TC              CYRCNTDN
                TC              ERRORS
                TC              ENDCYR
                TC              ERRORS
CYRCNTDN        INCR            SKEEP5
                TC              CYRLOOP
ENDCYR          CA              SKEEP5                          # 57777
                AD              CYR                             # C(CYR) = 20000
                CCS             A                               # -0 = END OF CYCLE RIGHT CHECK
                TC              ERRORS
                TC              ERRORS
                TC              ERRORS

# NORMAL OPERATION OF CYCLE LEFT REGISTER
CYLCHK          CA              S-15                            # 77760, -15
                TS              SKEEP5                          # COUNT REGISTER
                CA              S-MAX                           # 40000
                TS              CYL
CYLLOOP         CCS             CYL
                TC              CYLCNTDN
                TC              ERRORS
                TC              ENDCYL
                TC              ERRORS
CYLCNTDN        INCR            SKEEP5
                TC              CYLLOOP
ENDCYL          CA              CYL                             # C(CYL) SHOULD = +1
                TC              -1CHK           -1
                CA              SKEEP5
                TC              -1CHK

# NORMAL OPERATION OF SHIFT RIGHT REGISTER
SRCHK           CA              S-14                            # 77761, -14
                TS              SKEEP5                          # COUNT REGISTER
                CA              S-MAX                           # 40000
                TS              SR
SRLOOP          CCS             SR
                TC              ERRORS
                TC              ERRORS
                TC              SRCNTDN
                CA              SKEEP5                          # HAS SHIFTED 14 TIMES
                TC              -1CHK
                TC              EDOPCHK                         # NEXT SUBROUTINE
SRCNTDN         INCR            SKEEP5                          # INCREMENT COUNT REGISTER
                TC              SRLOOP

# NORMAL OPERATION OF EDOP REGISTER.  BITS 8 - 14 OF G REGISTER GO TO
# BITS 1 - 7 OF EDOP.
EDOPCHK         CA              S-15                            # 77760, -15
                TS              SKEEP5                          # COUNT REGISTER
                CA              S7BITS                          # 00177
                TS              CYL
EDOPLOOP        CA              CYL
                TS              EDOP
                TS              CYR                             # SHIFT LEFT 7 TIMES
                CA              CYR
                CA              CYR
                CA              CYR
                CA              CYR
                CA              CYR
                CA              CYR
                CA              CYR
                MASK            S7BITS
                CS              A
                TS              SKEEP1                          # COMPLEMENT OF C(EDOP)
                CA              S-ZERO
                MASK            EDOP
                AD              SKEEP1
                TC              -0CHK
                INCR            SKEEP5                          # INCREMENT COUNT REGISTER
                CCS             EDOP
                TC              EDOPLOOP
                TC              ENDEDOP
                TC              ERRORS
                TC              ERRORS
ENDEDOP         CA              SKEEP5                          # SHOULD HAVE PERFORMED EDOPLOOP 14 TIMES
                TC              -1CHK

                TC              POSTJUMP
                CADR            INSTDONE

ENDINST2        EQUALS
