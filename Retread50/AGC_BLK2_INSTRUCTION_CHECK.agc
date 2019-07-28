### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_BLK2_INSTRUCTION_CHECK.agc
## Purpose:     Part of the source code for AGC program Retread 50. 
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/Restoration.html
## Mod history: 2019-06-12 MAS  Recreated from Computer History Museum's
##				physical core-rope modules.

## Page 210
                SETLOC          ABORT           +1

# ADDRESSES OF ERASABLE REGISTERS
ADRS1           ADRES           KEEP1
ADRS2           ADRES           KEEP2
ADRS3           ADRES           KEEP3
ADRS4           ADRES           SELF1
ADRS5           ADRES           SELF2
ADRS6           ADRES           S+MAX
ADRS7           ADRES           SELF3

# CONSTANTS USED THROUGHOUT THE INSTRUCTIONS CHECK
SBIT1           OCTAL           00001
SBIT2           OCTAL           00002
SBIT3           OCTAL           00004
SBIT4           OCTAL           00010
SBIT5           OCTAL           00020
SBIT6           OCTAL           00040
SBIT7           OCTAL           00100
SBIT8           OCTAL           00200
SBIT9           OCTAL           00400
SBIT10          OCTAL           01000
SBIT11          OCTAL           02000
SBIT12          OCTAL           04000
SBIT13          OCTAL           10000
SBIT14          OCTAL           20000
SBIT15          OCTAL           40000

S+ZERO          OCTAL           00000
S+1             OCTAL           00001
S+2             OCTAL           00002
S+3             OCTAL           00003
S+4             OCTAL           00004
S+5             OCTAL           00005
S+6             OCTAL           00006
S+7             OCTAL           00007
S6BITS          OCTAL           00077
S7BITS          OCTAL           00177
S13BITS         OCTAL           17777
SODD            OCTAL           25252                           # SEVEN ONE BITS
S+MAX           OCTAL           37777
S-MAX           OCTAL           40000
ALARMCON        OCTAL           40400
SINOUT1         OCTAL           52500
SEVENS          OCTAL           52525                           # EIGHT ONE BITS
SINOUT2         OCTAL           52552
CYRCON          OCTAL           57761
SINOUT3         OCTAL           77725
S-15            OCTAL           77760
S-14            OCTAL           77761
S-7             OCTAL           77770
## Page 211
S-6             OCTAL           77771
S-5             OCTAL           77772
S-4             OCTAL           77773
S-3             OCTAL           77774
S-2             OCTAL           77775
S-1             OCTAL           77776
S-ZERO          OCTAL           77777

# NEXT TWO CONSTANTS ARE USED IN THE DEVIDE SUBROUTINE
DV1CON          OCTAL           14000
DV2CON          OCTAL           37776

# NEXT TWO CONSTANTS ARE ADDRESSESS USED BY EXTRACODE INDEX INSTRUCTIONS
ADRS+1          ADRES           S+1
ADRSDV1         ADRES           DV1CON

                CS              A                               
-0CHK           CCS             A                               
                TCF             ERRORS                          
                TCF             ERRORS                          
                TCF             ERRORS                          
                TC              Q                               

                CS              A                               
-1CHK           CCS             A                               
                TCF             ERRORS                          
                TCF             ERRORS                          
                CCS             A                               
                TCF             ERRORS                          
                TC              Q                               


ERRORS          XCH             Q                               
                TS              SFAIL                           # SAVE Q FOR FAILURE LOCATION
## !! START CHANGE FOR RETREAD 50 !!
                CA              FBANK
                TS              SFAIL           +1
## !! END CHANGE FOR RETREAD 50 !!
                INCR            ERCOUNT                         # KEEP TRACK OF NUMBER OF MALFUNCTIONS
                INHINT                                          # TURN ON PROGRAM ALARM LIGHT
                CS              ALARMCON
                MASK            DSPTAB          +11D
                AD              ALARMCON
                TS              DSPTAB          +11D
                RELINT

# IF C(SMODE) IS +NON-ZERO START CHECKING AGAIN AT TCCHK
# IF C(SMODE) IS + PUT +0 IN SMODE AND IDLE
                CA              SMODE
                EXTEND
                BZMF            STOPCHK
                TC              SMODECHK
STOPCHK         CA              S+ZERO
                TS              SMODE
## Page 212
                TC              CHECKNJ
SMODECHK        CCS             SMODE                           
                TC              +3
                TC              SMODECHK        -1
                TC              +1
                TC              CHECKNJ
                CAF             STRTCHK
                TC              BANKJUMP                        # TO START OF CHECKING ROUTINES
STRTCHK         CADR            TCCHK

                SETLOC          26000

                CA              S+ZERO                          # INITIALIZE COUNT REGISTER
                TS              ERCOUNT
                TS              SCOUNT

# NORMAL USE OF TC AND TCF
TCCHK           TC              +2                              
                TC              CCSCHK                          
                TCF             +2
                TC              ERRORS                          
                TC              Q
                TC              ERRORS                          

# NORMAL USE OF CA, CS, AND CCS
CCSCHK          CA              S-3
                TS              KEEP1
                CCS             KEEP1
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
## Page 213
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
                TS              KEEP1                           # 00177
                MASK            EDOP                            # 00177
                CS              A                               # 77600
                AD              KEEP1                           # 77777
                TC              -0CHK
# CHECK MASK OF AN SC REGISTER
                CA              S+1
                TS              L
                CA              S-ZERO
                MASK            L
                TC              -1CHK           -1

# NORMAL USE OF XCH, AD, AND TS
                CA              S+MAX                           # 37777
                TS              KEEP1
                AD              KEEP1                           # 01 - 37776
                TS              KEEP2                           # 37776
                TC              ERRORS
                TC              -1CHK           -1
                XCH             KEEP1                           # SKEEP1 NOW +0
                CS              A                               # 40000
                AD              A                               # 10 - 00001
                TS              KEEP3                           # 40001, C(A) = -1
                TC              ERRORS
## Page 214
                AD              KEEP3                           # C(A) = 40000
                AD              KEEP2                           # C(A) = -1
                AD              KEEP1                           # C(A) = -1
                TS              KEEP4                           # -1
                CS              KEEP4                           # +1
                TC              -1CHK           -1

# NORMAL USE OF INCR
# NOT CHECKING COUNTER INTERRUPT
                CA              S+MAX                           # 37777
                TS              KEEP1
                INCR            KEEP1                           # +0
                INCR            KEEP1                           # +1
                INCR            KEEP1                           # +2
                AD              S-MAX
                TC              -0CHK                           # CHECK C(A) HAS NOT CHANGED
                CS              KEEP1
                TS              KEEP1                           # -2
                INCR            KEEP1                           # -1
                CA              KEEP1
                TC              -1CHK
# CHECK     INCREMENT OF AN SC REGISTER
                CA              S-2
                TS              L
                INCR            L
                CA              L
                TC              -1CHK

# NORMAL USE OF ADS
                CA              SBIT13
                TS              KEEP1                           # 10000
                ADS             KEEP1                           # 20000
                ADS             KEEP1                           # OV WITH +0
                TS              KEEP2
                TC              ERRORS
                CS              KEEP1
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
## Page 215
                TS              KEEP1                           # +1
                LXCH            KEEP1                           # +1 IN L
                CS              A
                TS              KEEP2                           # -1 IN KEEP2
                LXCH            KEEP2                           # L = -1, KEEP2 = +1
                CS              KEEP2
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
                TS              KEEP1                           # 37776
                TC              +2
                TC              ERRORS
                CA              L
                TS              KEEP2                           # 40001
                TC              +2
                TC              ERRORS
                AD              KEEP1                           # -0
                TC              -0CHK

# NORMAL USE OF DXCH
                CA              S+MAX
                TS              KEEP2                           # 37777, K+1
                CS              A
                TS              L                               # 40000
                AD              S+1
                TS              KEEP1                           # 40001, K
                CS              A                               # 37776
                DXCH            KEEP1
# A = 40001, L = 37777 ....... KEEP1 = 37776, KEEP2 = 40000
                AD              L
                TC              -1CHK           -1
                CA              KEEP1
                AD              KEEP2
                TC              -1CHK

# NORMAL USE OF DAS (6 CHECKS)
# IF ADDRESS OF K DOES NOT = ZERO, C(L) = +0 AND C(A) = NET OVERFLOW
# C(A) = +0 IF NO OVERFLOW OR UNDERFLOW
# DAD++ WITH NO OVERFLOW
DAS++           CAF             S13BITS
                TS              KEEP1                           # 17777
## Page 216
                TS              KEEP2                           # 17777
                TS              L                               # 17777
                AD              S+1                             # 20000
                DAS             KEEP1
# C(KEEP1) = 37777, C(KEEP2) = 377776
                TC              -0CHK           -1
                XCH             L
                TC              -0CHK           -1
                CS              KEEP1
                AD              KEEP2
                TC              -1CHK
# DAS++ WITH OVERFLOW
DAS++OV         CA              S+MAX
                TS              KEEP1                           # 37777
                TS              KEEP2                           # 37777
                TS              L                               # 37777
                CA              S+1                             # +1
                DAS             KEEP1
# C(KEEP1) = +1, C(KEEP2) = 37776, C(A) = +1,
                TC              -1CHK           -1
                XCH             L
                TC              -0CHK           -1
                CS              KEEP1
                TC              -1CHK
                CA              S-MAX
                AD              KEEP2
                TC              -1CHK
# DAS MIXED SIGNS
DAS+--+         CA              S+MAX
                TS              KEEP1                           # 37777
                CS              A
                TS              KEEP2                           # 40000
                CS              A
                AD              S-1
                TS              L                               # 37776
                CS              A                               # 40001
                DAS             KEEP1
# C(KEEP1) = +1, C(KEEP2) = -1
                TC              -0CHK           -1
                XCH             L
                TC              -0CHK           -1
                CA              KEEP1
                TC              -1CHK           -1
                CA              KEEP2
                TC              -1CHK
# DAS-- WITH NO UNDERFLOW
DAS--           CS              S13BITS
                TS              KEEP1                           # 60000
                TS              KEEP2                           # 60000
                TS              L                               # 60000
## Page 217
                AD              S-1                             # 57777
                DAS             KEEP1
# C(KEEP1) = 40000, C(KEEP2) = 40001
                TC              -0CHK           -1
                XCH             L
                TC              -0CHK           -1
                CS              KEEP2
                AD              KEEP1
                TC              -1CHK
# DAS-- WITH UNDERFLOW
DAS--UV         CA              S-MAX
                TS              KEEP1                           # 40000
                TS              KEEP2                           # 40000
                TS              L                               # 40000
                CA              S-1                             # -1
                DAS             KEEP1
# C:KEEP1) = -1, C(KEEP2) = 40001, C(A) = -1
                TC              -1CHK
                XCH             L
                TC              -0CHK           -1
                CA              KEEP1
                TC              -1CHK
                CA              S+MAX
                AD              KEEP2
                TC              -1CHK           -1
# DAS A.  DOUBLES THE CONTENTS OF THE A REGISTER AND THE L REGISTER.
                CA              S-MAX
                TS              KEEP2                           # 40000
                TS              L                               # 40000
                CS              A
                TS              KEEP1                           # 37777
                DAS             A
# C(A) = OV 37775, C(L) = 40001
                TS              KEEP3
                TC              ERRORS
                CA              L
                AD              KEEP3
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
## Page 218
                TS              NDXKEEP2
                CA              ADRS3
                TS              NDXKEEP3
                CA              ADRS4
                TS              NDXSELF1
                CA              ADRS5
                TS              NDXSELF2
NDXCHK          NDX             NDX+MAX                         # CA S+MAX
                CA              0000                            # A = 37777
                NDX             NDXKEEP1                        # TS KEEP1
                TS              0000                            # TS WITH NO OV, UV
                NDX             NDX+0                           # CS   A
                CS              0000                            # A = 40000
                NDX             NDXKEEP1                        # XCH KEEP1
                XCH             0000                            # A = +MAX, KEEP1 = - MAX
                NDX             NDX+0                           # CCS A
                CCS             0000                            # A = 37776
                TC              +4
                TC              ERRORS
                TC              ERRORS
                TC              ERRORS
                NDX             NDXKEEP1                        # AD KEEP1
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
                NDX             NDXKEEP1                        # TS KEEP1 WITH OV
                TS              0000                            # A = +1, KEEP1 = +0
                TC              ERRORS
                AD              KEEP1                           # A = +1
                NDX             NDX+MAX                         # MASK S+MAX
                MASK            0000                            # A = +1
                TC              -1CHK           -1

# INDEX USED WITH ADS, NDX, AND INCR
                CA              S13BITS
                TS              KEEP1
                NDX             NDX+0                           # INDEX +0
                NDX             NDXKEEP1                        # ADS KEEP1
                ADS             0000                            # C(A) AND C(KEEP1) = 377776
## Page 219
                NDX             NDXKEEP1                        # INCR KEEP1
                INCR            0000                            # C(KEEP1) = 37777
                CS              A                               # 40001
                AD              KEEP1                           # A = +1
                TC              -1CHK           -1
# INDEX USED WITH LXCH, DAS, AND DXCH
                CA              S-MAX
                TS              KEEP2                           # KEEP2 HOLDS 40000, KEEP1 HOLDS 37777
                CA              S+1
                TS              KEEP3                           # +1
                NDX             NDXKEEP3                        # LXCH KEEP3
                LXCH            0000                            # C(L) = +1
                CA              S-2
                NDX             NDXKEEP1                        # DAS KEEP1
                DAS             0000
# BEFORE DAS, K = 37777   K+1 = 40000
#             A = -2      L   = +1
# AFTER  DAS, K = 37775   K+1 = 40001
#            A = +0    L  = +0
                NDX             NDXKEEP1                        # DXCH KEEP1
                DXCH            0000
                AD              L
                TC              -1CHK
                CS              KEEP1
                TC              -0CHK
                CA              KEEP2
                TC              -0CHK           -1
# INDEX INSTRUCTION USED WITH OVERFLOW
                CA              ADRS7                           # ADDRESS OF SELF3
                AD              SBIT14
                TS              KEEP7
SELF3           NDX             KEEP7
                2               0002
                TC              ERRORS
# CHECK INDEX OF AN SC REGISTER
                CA              ADRS1                           # 01371, ADDRESS OF KEEP1
                NDX             A
                TS              0000                            # PUT 01371 IN KEEP1
                CS              A
                AD              KEEP1
                TC              -0CHK

## Page 220
# START CHECKING EXTRACODE INSTRUCTIONS
# NORMAL USE OF DCA, DCS, AND SU
STRTXTRA        EXTEND
                DCA             SBIT1
# C(A) = +1, C(L) = +2
                TS              KEEP2                           # +1
                XCH             L
                TS              KEEP1                           # +2
                EXTEND
                SU              KEEP2                           # C(KEEP2) = +1
                TC              -1CHK           -1
                EXTEND
                DCS             KEEP1
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
                TS              KEEP1
                TC              ERRORS
                CA              KEEP1
                EXTEND
                SU              L
                TC              -1CHK           -1

# CHECKS DCA OF AN SC REGISTER
## !! START CHANGE FOR RETREAD 50 !!
                CA              S+MAX                           # 37777
                TS              L
                CA              S-1                             # -1
                TS              Q
                COM
                EXTEND
                DCA             L                               # -1
                TC              -1CHK
                CA              L
                TC              -1CHK                           # -1
## !! END CHANGE FOR RETREAD 50 !!

# NORMAL USE OF QXCH
                CA              QXCHCON1
                TS              KEEP1                           # STORE ADDRESS OF AUGCHK IN KEEP1
                TC              +2                              # Q NOW HOLDS ADDRESS OF QNMBR
QNMBR           TC              ERRORS
                EXTEND
                QXCH            KEEP1                           # Q NOW HOLDS ADDRESS OF AUGCHK
                TC              Q                               # SHOULD GO TO QXCHCON2 +1, NOT QNMBR
                TC              ERRORS
QXCHCON1        ADRES           QXCHCON2        +1
## Page 221
QXCHCON2        ADRES           QNMBR
                CS              KEEP1                           # CHECK THAT KEEP1 HOLDS B(Q)
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
                TS              KEEP1                           # +0
                CS              A
                TS              KEEP2                           # -0
                EXTEND
                AUG             KEEP1                           # +1
                EXTEND
                AUG             KEEP1                           # +2
                TC              -0CHK                           # CHECK C(A) HAS NOT CHANGED
                EXTEND
                AUG             KEEP2                           # -1
                EXTEND
                AUG             KEEP2                           # -2
                EXTEND
                AUG             KEEP2                           # -3
                TC              -0CHK           -1
                CA              KEEP2
                AD              KEEP1
                TC              -1CHK
# CHECKS AUG OF AN SC REGISTER
                CA              S-ZERO
                EXTEND
                AUG             A
                TC              -1CHK

# NORMAL USE OF DIM
DIMCHK          CA              S+ZERO
                TS              KEEP1                           # +0
                EXTEND
                DIM             KEEP1
                CA              KEEP1
                TC              -0CHK           -1
                CS              A
                TS              KEEP1                           # -0
## Page 222
                EXTEND
                DIM             KEEP1
                CA              KEEP1
                TC              -0CHK
                CA              S+2
                TS              KEEP1                           # +2
                EXTEND
                DIM             KEEP1                           # +1
                AD              S-1
                TC              -1CHK           -1              # CHECK C(A) HAS NOT CHANGED
                CA              KEEP1
                TC              -1CHK           -1
                EXTEND
                DIM             KEEP1
                TC              -0CHK           -1
                CA              KEEP1
                TC              -0CHK
                CS              S+2
                TS              KEEP2                           # -2
                EXTEND
                DIM             KEEP2                           # -1
                CA              KEEP2
                TC              -1CHK
                EXTEND
                DIM             KEEP2                           # -0
                TC              -0CHK           -1
                CA              KEEP2
                TC              -0CHK
# CHECKS DIM OF AN SC REGISTER
                CA              S-2
                EXTEND
                DIM             A
                TC              -1CHK

# NORMAL USE OF MSU
# MSU SAME (S+MAX AND S+MAX), RESULT +0
                CA              S+MAX
                TS              KEEP1
                EXTEND
                MSU             KEEP1
                TC              -0CHK           -1
# MSU SAME (+0 AND +0), RESULT +0
                TS              KEEP2
                EXTEND
                MSU             KEEP2
                TC              -0CHK           -1
# MSU SAME (-0 AND -0), RESULT +0
                CA              S-ZERO
                TS              KEEP3
                EXTEND
## Page 223
                MSU             KEEP3
                TC              -0CHK           -1
# MSU +0 AND 77777, RESULT = +1
                EXTEND
                MSU             KEEP3
                TC              -1CHK           -1
# MSU 77777 AND +0, RESULT = -1
                CS              A
                EXTEND
                MSU             KEEP2
                TC              -1CHK
# MSU +6 AND +7, RESULT = -1
                CA              S+7
                TS              KEEP4
                CA              S+6
                TS              KEEP5
                EXTEND
                MSU             KEEP4
                TC              -1CHK
# MSU +7 AND +6, RESULT = +1
                CA              S+7
                EXTEND
                MSU             KEEP5
                TC              -1CHK           -1
# MSU 77770 AND 77771, RESULT = -1
                CA              S-6
                TS              KEEP6
                CA              S-7
                TS              KEEP7
                EXTEND
                MSU             KEEP6
                TC              -1CHK
# MSU 77771 AND 77770, RESULT = +1
                CA              S-6
                EXTEND
                MSU             KEEP7
                TC              -1CHK           -1
# CHECKS MSU OF AN SC REGISTER ( -0 AND -0 = +0)
                CA              S-ZERO
                TS              L
                EXTEND
                MSU             L
                TC              -0CHK           -1

# NORMAL USE OF BZF
BZFCHK          TC              +2
                TC              BZMFCHK                         # CORRECT ADDRESS IN Q
                CAF             S+5
                EXTEND
                BZF             ERRORS

## Page 224
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
                TC              Q                               # SHOULD GO TO BZFCHK +1
                TC              ERRORS

BZMFCHK         TC              +2
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
                TC              Q                               # SHOULD GO TO BZMFCHK +1
                TC              ERRORS

# NORMAL USE OF MP
# 37777 X 2
MP1++           CA              S+MAX                           # 37777
                EXTEND
                MP              S+2                             # C(A) = +1, C(L. = 37776
                AD              L
                TS              KEEP1                           # 37777
MP1+-           EXTEND
                MP              S-2                             # C(A) = -1, C(L) = 40001
                AD              L
                TS              KEEP2                           # 40000
MP1-+           EXTEND
                MP              S+2                             # C(A) = -1, C(L) = 40001
                AD              L
                TS              KEEP3                           # 40000
MP1--           EXTEND
## Page 225
                MP              S-2                             # C(A) = +1, C(L) = 37776
                AD              L                               # 37777
                AD              KEEP3                           # 77777
                AD              KEEP2                           # 40000
                AD              KEEP1                           # 77777
                TC              -0CHK
# 37777 X 37777
MP2++           CA              S+MAX                           # 37777
                EXTEND                                          # CHECKS RSC PULSE
                MP              A                               # C(A) = 37776, C(L) = +1
                AD              L
                TS              KEEP1                           # 37777
MP2+-           EXTEND
                MP              S-MAX                           # C(A) = 40001, C(L) = -1
                AD              L
                TS              KEEP2                           # 40000
MP2-+           EXTEND
                MP              S+MAX                           # C(A) = 40001, C(L) = -1
                AD              L
                TS              KEEP3                           # 40000
MP2--           EXTEND
                MP              S-MAX                           # C(A) = 37776, C(L) = +1
                AD              L                               # 37777
                AD              KEEP3                           # 77777
                AD              KEEP2                           # 40000
                AD              KEEP1                           # 77777
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
## Page 226
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
                TS              KEEP1
                EXTEND
                MP              KEEP1
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

                CA              CONTINU
                TC              BANKJUMP
CONTINU         CADR            DV1++           -1              # CONTINUE WITH INSTRUCTION CHECK

                SETLOC          30000

                TC              CHECKNJ                         # CHECK FOR NEW JOB

## Page 227
# NORMAL USE OF DV ... REMAINDER HAS SIGN OF DIVIDEND
# 1/4 DIVIDED BY 3/8
# C(A) = 25252 WITH A + QUOTIENT AND 52525 WITH A - QUOTIENT.
# C(L) = REMAINDER = /100000/ WITH SIGN OF DIVIDEND.
DV1++           CA              DV1CON                          # 14000
                TS              KEEP7                           # 14000, +3/8
                TS              Q
                CS              A
                TS              KEEP6                           # 63000, -3/8
                CA              S+ZERO
                TS              L
                CA              SBIT13                          # 10000
                EXTEND
                DV              Q                               # CHECKS RSC PULSE
                TS              KEEP1                           # 25252
                CA              S+ZERO
DV1+-           LXCH            A
                EXTEND
                DV              KEEP6
                AD              KEEP1
                TC              -0CHK
                CA              S-ZERO
                LXCH            A
DV1-+           CS              A
                EXTEND
                DV              KEEP7
                TS              KEEP1                           # 52525
                CA              S-ZERO
DV1--           LXCH            A
                EXTEND
                DV              KEEP6
                AD              KEEP1
                TC              -0CHK
                CA              L
                AD              SBIT13
                TC              -0CHK
# 1/2 TO 15TH DIVIDED BY 1/2 TO 14TH
# C(A) SHOULD BE 1/2 AND CONTENTS OF L SHOULD BE ZERO
DV2++           CA              S+1
                TS              KEEP7                           # 00001, DIVISOR
                CS              A
                TS              KEEP6                           # 77776, DIVISOR
                CA              S+ZERO
                CA              SBIT14                          # 20000
                TS              L
                CA              S+ZERO
                EXTEND
                DV              KEEP7                           # C(A) = 1/2, C(L) = +0
                TS              KEEP1
DV2+-           LXCH            A
## Page 228
                EXTEND
                DV              KEEP6
                TS              KEEP2                           # -1/2
                AD              KEEP1
                TC              -0CHK
                CA              KEEP2
                LXCH            A
DV2-+           CS              A
                EXTEND
                DV              KEEP7
                TS              KEEP2
DV2--           LXCH            A
                EXTEND
                DV              KEEP6
                TS              KEEP1
                AD              KEEP2
                TC              -0CHK
                CS              KEEP1                           # MAKE SURE QUOTIENT IS 1/2
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
                DV              KEEP7
                TS              KEEP1                           # 20000
DV3+-           LXCH            A
                CS              A                               # A = -0
                EXTEND
                DV              KEEP6
                AD              KEEP1
                TC              -0CHK
                CS              SBIT14                          # -1/2
DV3-+           LXCH            A
                EXTEND
                DV              KEEP7
                TS              KEEP1
DV3--           LXCH            A
                CS              A                               # A = +0
                EXTEND
                DV              KEEP6
                AD              KEEP1
                TC              -0CHK
                CS              L
                TC              -0CHK           -1

## Page 229
# C(A) = 17777 AND C(L) = 37777.  THIS IS DIVIDED BY 20000.  THE RESULT
# SHOULD BE +-/37777/ AND THE REMAINDER +-/17777/
DV4++           CA              S+MAX
                TS              L
                CA              SBIT14
                TS              KEEP7                           # 20000
                CS              A
                TS              KEEP6                           # 57777
                CA              S13BITS                         # 17777
                EXTEND
                DV              KEEP7
                TS              KEEP1
DV4+-           LXCH            A
                EXTEND
                DV              KEEP6
                TS              KEEP2
                AD              KEEP1
                TC              -0CHK
                CA              KEEP2
                LXCH            A
DV4-+           CS              A
                EXTEND
                DV              KEEP7
                AD              KEEP1
                TC              -0CHK
                CA              KEEP2
DV4--           LXCH            A
                EXTEND
                DV              KEEP6
                TS              KEEP3
                AD              KEEP2
                TC              -0CHK
                CS              KEEP3
                AD              S+MAX
                TC              -0CHK
                CA              L
                AD              S13BITS
                TC              -0CHK
# C(A) = +-/17777/ AND C(L) = +-/37777/ WITH OPPOSITE SIGN BEFORE DEVISION
# THE QUOTIENT SHOULD BE +-/37774/ WITH THE SIGN DEPENDING ON THE SIGN OF
# A AND THE SIGN OF THE DEVISOR. THE C(L) = +-/1/ DEPENDING ON THE SIGN
# OF A.
DV5++           CS              S+MAX
                TS              L                               # 40000
                CA              S13BITS                         # 17777
                EXTEND
                DV              KEEP7
                TS              KEEP1                           # 37774
                XCH             L
                TC              -1CHK           -1

## Page 230
DV5+-           CA              S-MAX
                TS              L                               # 40000
                CA              S13BITS                         # 17777
                EXTEND
                DV              KEEP6                           # C(A) = -37774, C(L) = +1
                AD              KEEP1
                TC              -0CHK
                XCH             L
                TC              -1CHK           -1
DV5-+           CA              S+MAX
                TS              L                               # 37777
                CS              S13BITS                         # 60000
                EXTEND
                DV              KEEP7                           # C(A) = -37774, C(L) = -1
                TS              KEEP2
                AD              KEEP1
                TC              -0CHK
                XCH             L
                TC              -1CHK
DV5--           CA              S+MAX
                TS              L                               # 37777
                CS              S13BITS                         # 60000
                EXTEND
                DV              KEEP6                           # C(A) = 37774, C(L) = -1
                AD              KEEP2
                TC              -0CHK
                XCH             L
                TC              -1CHK
                CA              KEEP2                           # -37774
                AD              S-2                             # -37776
                AD              S+MAX                           # +1
                TC              -1CHK           -1              # CHECK THAT QUOTIENT IS +-/37774/

# DIVIDE SAME (37776).  THE RESULT SHOULD BE MAXIMUM AND THE REMAINDER
# SHOULD BE THE SAME VALUE AS THE DIVISOR WITH THE SAME SIGN AS THE
# DIVIDEND
DV6++           CA              S+ZERO
                TS              L
                CS              DV2CON                          # 37776
                TS              KEEP6                           # 40001
                CS              A
                TS              KEEP7                           # 37776
                EXTEND
                DV              KEEP7
                CS              A
                AD              L
                TC              -1CHK
                CA              S+ZERO
DV6+-           LXCH            A
                EXTEND
## Page 231
                DV              KEEP6
                AD              L
                TC              -1CHK
                CA              S-ZERO
DV6-+           LXCH            A
                CS              A
                EXTEND
                DV              KEEP7
                CS              A
                AD              L
                TC              -1CHK           -1
                CA              S-ZERO
DV6--           LXCH            A
                EXTEND
                DV              KEEP6
                AD              L
                TC              -1CHK           -1
                CS              L
                AD              KEEP6
                TC              -0CHK
# DIVIDE SAME (ZERO).  THE RESULT SHOULD BE MAXIMUM AND THE REMAINDER
# SHOULD BE THE SAME VALUE AS THE DIVISOR WITH THE SAME SIGN AS THE
# DIVIDEND.
DV7++           CS              S+ZERO
                TS              KEEP6                           # -0
                CS              A
                TS              KEEP7                           # +0
                TS              L
                EXTEND
                DV              KEEP7
                AD              S-MAX
                TC              -0CHK
DV7+-           LXCH            A                               # C(A) = C(L) = +0
                EXTEND
                DV              KEEP6
                AD              S+MAX
                TC              -0CHK
                CS              A
DV7-+           LXCH            A
                CS              A                               # C(A) = C(L) = -0
                EXTEND
                DV              KEEP7
                AD              S+MAX
                TC              -0CHK
                CS              A
DV7--           LXCH            A                               # C(A) = C(L) = -0
                EXTEND
                DV              KEEP6
                AD              S-MAX
                TC              -0CHK
## Page 232
                CS              L
                TC              -0CHK           -1

# DEVIDE SAME (ZERO). THE CONTENTS OF THE A REGISTER AND L REGISTER WILL
# HAVE OPPOSITE SIGNS BEFORE DEVISION. THE SIGN OF THE QUOTIENT WILL
# DEPEND ON THE SIGN OF THE L REGISTER BEFORE DEVISION AND THE SIGN OF
# THE DEVISOR. THE SIGN OF THE REMAINDER IS THE SAME SIGN AS THE SIGN OF
# THE L REGISTER BEFORE DEVISION. C(L)  REMAINS SAME
DV8++           CA              S+ZERO
                TS              KEEP7                           # +0
                TS              L
                CS              A
                TS              KEEP6                           # -0
                EXTEND                                          # A = -0, L = +0
                DV              KEEP7                           # A = L = +0
                TS              KEEP1
                CA              L                               # C(A) = C(L) = +0
                TC              -0CHK           -1
DV8+-           CS              A
                EXTEND                                          # A = -0, L = +0
                DV              KEEP6                           # A = -0, L = +0
                AD              KEEP1
                TC              -0CHK
                CS              A
                XCH             L                               # PUT -0 IN L
                TC              -0CHK           -1              # CHECK C(L)
DV8-+           EXTEND                                          # A = +0, L = -0
                DV              KEEP7                           # A = L = -0
                TS              KEEP2
                AD              KEEP1
                TC              -0CHK
                CS              A
                XCH             L                               # PUT -0 IN L
                TC              -0CHK                           # CHECK C(L)
DV8--           EXTEND                                          # A = +0, L = -0
                DV              KEEP6                           # A = +0, L = -0
                AD              KEEP2
                TC              -0CHK
                CA              S+MAX                           # CHECK QUOTIENT IS CORRECT
                AD              KEEP2
                TC              -0CHK
                XCH             L
                TC              -0CHK                           # CHECK C(L)

# INPUT-OUTPUT INSTRUCTIONS
# NORMAL USE OF READ AND WRITE
IN-OUT1         CA              S-1
## !! START CHANGE FOR RETREAD 50 !!
                INHINT
## !! END CHANGE FOR RETREAD 50 !!
                EXTEND
                WRITE           L                               # 77776
                CS              A                               # 00001
## Page 233
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
                TS              KEEP1
                TC              ERRORS
                CA              KEEP1
                AD              S+MAX
                TC              -1CHK           -1

# NORMAL USE OF RAND, RAND = READ AND MASK
RANDCHK         CA              S+ZERO
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
                XCH             Q
                CA              S-ZERO                          #  77777
                EXTEND
                RAND            Q                               #  01 - 00001
                TS              KEEP1
                TC              ERRORS
                TC              -1CHK           -1
                CS              KEEP1
                TC              -1CHK

# NORMAL USE OF WAND, WAND = WRITE AND MASK
WANDCHK         CA              S+ZERO
## Page 234
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
                XCH             Q
                CA              S-ZERO                          # 77777
                EXTEND
                WAND            Q
                TS              KEEP2
                TC              ERRORS
                CA              Q
                TS              KEEP1
                TC              ERRORS
                CS              KEEP1
                TC              -1CHK
                CS              KEEP2
                TC              -1CHK

# NORMAL USE OF ROR, READ AND SUPERIMPOSE
RORCHK          CA              S+ZERO
                TS              L
                EXTEND
                ROR             L                               # 00000, 00000
                TC              -0CHK           -1
                CA              L
                TC              -0CHK           -1
                CA              S-ZERO
                EXTEND
                ROR             L                               # 77777, 00000

## Page 235
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
                XCH             Q
                CA              S+MAX
                AD              S+1                             # 01 - 00000
                EXTEND
                ROR             Q                               # 11 - 37776
                TS              KEEP1
                TC              +2
                TC              ERRORS
                CA              KEEP1
                TC              -1CHK

# NORMAL USE OF WOR, WOR = WRITE AND SUPERIMPOSE
WORCHK          CA              S+ZERO
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
## Page 236
                CA              S-MAX
                EXTEND
                WOR             L                               # 77777, 77777
                TC              -0CHK
                CA              L
                TC              -0CHK
WOROV           CA              S-MAX
                AD              S-2                             # 10 - 37776
                XCH             Q
                CA              S+MAX
                AD              S+1                             # 01 - 00000
                EXTEND
                WOR             Q                               # 11 - 37776
                TS              KEEP2                           # SHOULD NOT SKIP
                TCF             +2
                TC              ERRORS
                XCH             Q
                TS              KEEP3
                TC              +2
                TC              ERRORS
                CA              KEEP3                           # CHECK C(Q)
                TC              -1CHK
                CA              KEEP2
                TC              -1CHK                           # CHECK C(A)

# NORMAL USE OF RXOR
RXORCHK         CA              S+ZERO
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
## Page 237
                TS              Q
RXORUV          CA              S+MAX
                AD              S+2                             # 01 - 00001
                EXTEND
                RXOR            Q                               # 10 - 37776, C(Q) = -0
                TS              KEEP1
                TC              ERRORS
                CA              KEEP1
                TC              -1CHK
## !! START CHANGE FOR RETREAD 50 !!
                RELINT
## !! END CHANGE FOR RETREAD 50 !!

                TC              CHECKNJ                         # CHECK FOR NEW JOB
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
                INDEX           ADRS+1                          # DCA S+1
                DCA             0000                            # C(A) = +1, C(L) = +2
                CS              A
                AD              L
                TC              -1CHK           -1
# INDEX INSTRUCTION USED WITH DCS
                EXTEND
                INDEX           ADRS+1                          # DCS S+1
                DCS             0000                            # C(A) = -1, C(L) = -2
                CS              A
                AD              L
                TC              -1CHK
# INDEX INSTRUCTION USED WITH MP AND SU
                CA              S+MAX                           # 37777
                EXTEND
                NDX             ADRS+1
                MP              0001                            # C(A) = 1, C(L) = 37776
## Page 238
                TC              -1CHK           -1
                CA              S+MAX                           # 37777
                EXTEND
                NDX             S+1
                SU              0000
                TC              -1CHK           -1
# INDEX INSTRUCTION USED WITH DV
NDXDV           CA              DV1CON                          # PUT 14000 (3/8) IN KEEP3
                TS              KEEP3
                CA              S+ZERO
                TS              L
                CA              SBIT13                          # 10000
                EXTEND
                NDX             ADRS3
                DV              0000                            # C(A) = 25252, C(L) = 10000
                TS              KEEP1
                CA              S-ZERO
                XCH             L
                CS              A
                EXTEND
                NDX             ADRS3
                DV              0000
                AD              KEEP1
                TC              -0CHK
# INDEX USED WITH MSU (C(A) = +0, C(K) = -0) (RESULT = -1)
NDXMSU          CA              S+ZERO
                TS              KEEP1
                CS              A
                EXTEND
                NDX             ADRS1                           # MSU KEEP1
                MSU             0000                            # C(A) = -1
                TC              -1CHK
# INDEX USED WITH QXCH
NDXQXCH         CA              ADRSQXCH
                TS              KEEP1
                TC              +2
                TC              ERRORS
                EXTEND
                NDX             ADRS1                           # QXCH KEEP1
                QXCH            0000
                TC              Q
                TC              ERRORS
# INDEX USED WITH AUG
NDXAUG          CS              S+ZERO
                TS              KEEP1                           # 00000
                EXTEND
                NDX             ADRS1                           # AUG KEEP1
                AUG             0000
                CA              KEEP1
                TC              -1CHK

## Page 239
# INDEX USED WITH DIM
NDXDIM          CA              S+2
                TS              KEEP1
                EXTEND
                NDX             ADRS1                           # DIM KEEP1
                DIM             0000
                CS              KEEP1
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
## Page 240
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
# CHECKS EXTRACODE INDEX OF AN SC REGISTER
                CA              S+2
                TS              KEEP1
                CA              ADRS1                           # ADDRESS OF KEEP1
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
                TS              KEEP5                           # COUNTDOWN REGISTER
                CA              S-MAX                           # 40000
                TS              CYR
CYRLOOP         CCS             CYR
                TC              CYRCNTDN
## Page 241
                TC              ERRORS
                TC              ENDCYR
                TC              ERRORS
CYRCNTDN        INCR            KEEP5
                TC              CYRLOOP
ENDCYR          CA              KEEP5                           # 57777
                AD              CYR                             # C(CYR) = 20000
                CCS             A                               # -0 = END OF CYCLE RIGHT CHECK
                TC              ERRORS
                TC              ERRORS
                TC              ERRORS

# NORMAL OPERATION OF CYCLE LEFT REGISTER
CYLCHK          CA              S-15                            # 77760, -15
                TS              KEEP5                           # COUNT REGISTER
                CA              S-MAX                           # 40000
                TS              CYL
CYLLOOP         CCS             CYL
                TC              CYLCNTDN
                TC              ERRORS
                TC              ENDCYL
                TC              ERRORS
CYLCNTDN        INCR            KEEP5
                TC              CYLLOOP
ENDCYL          CA              CYL                             # C(CYL) SHOULD = +1
                TC              -1CHK           -1
                CA              KEEP5
                TC              -1CHK

# NORMAL OPERATION OF SHIFT RIGHT REGISTER
SRCHK           CA              S-14                            # 77761, -14
                TS              KEEP5                           # COUNT REGISTER
                CA              S-MAX                           # 40000
                TS              SR
SRLOOP          CCS             SR
                TC              ERRORS
                TC              ERRORS
                TC              SRCNTDN
                CA              KEEP5                           # HAS SHIFTED 14 TIMES
                TC              -1CHK
                TC              EDOPCHK                         # NEXT SUBROUTINE
SRCNTDN         INCR            KEEP5                           # INCREMENT COUNT REGISTER
                TC              SRLOOP

# NORMAL OPERATION OF EDOP REGISTER.  BITS 8 - 14 OF G REGISTER GO TO
# BITS 1 - 7 OF EDOP.
EDOPCHK         CA              S-15                            # 77760, -15
                TS              KEEP5                           # COUNT REGISTER
                CA              S7BITS                          # 00177
                TS              CYL
## Page 242
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
                TS              KEEP1                           # COMPLEMEMT OF C(EDOP)
                CA              S-ZERO
                MASK            EDOP
                AD              KEEP1
                TC              -0CHK
                INCR            KEEP5                           # INCREMEMT COUNT REGISTER
                CCS             EDOP
                TC              EDOPLOOP
                TC              ENDEDOP
                TC              ERRORS
                TC              ERRORS
ENDEDOP         CA              KEEP5                           # SHOULD HAVE PERFORMED EDOPLOOP 14 TIMES
                TC              -1CHK

                INCR            SCOUNT                          # INCREMENT UPON SUCCESSFUL COMLETION

                TC              SMODECHK


