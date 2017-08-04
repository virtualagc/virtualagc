### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_BLOCK_TWO_SELF-CHECK.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-20 MAS  Created from Aurora 12 (with much DAP stuff removed).
##              2016-12-21 MAS  Shuffled some things around for multi-bank handling,
##                              and put in jumps to Retread instruction checks and back.
##              2017-01-04 MAS  Fleshed out the rest of the hardware alarm tests. Also
##                              pulled back all updates added by the time of Sunburst 120.
##                              and put in jumps to Retread instruction checks and back.
##              2017-01-15 MAS  Added transfers to and from the new extended tests.
##		2017-01-28 RSB	WTIH -> WITH.
##		2017-03-27 MAS	A few corrections for the hardware alarm tests: counter
##                              alarms are now filtered out because they can happen at
##                              random during other restarts, if counter increments had
##                              been requested. Also added testing of the Night Watchman's
##                              stretching out of its monitor output for 1.28s. Also
##                              adopted a bugfix from Sunburst 120 that stopped the AGC
##                              from crashing when running a self-test after the DSKY test.

# PROGRAM DESCRIPTION                                                         DATE  14 FEBRUARY 1967
# PROGRAM NAME - SELF-CHECK                                                   LOG SECTION AGC BLOCK TWO SELF-CHECK
# MOD NO - 0                                                                  ASSEMBLY SUNBURST REV 107
# MOD BY - GAUNTT


# FUNCTIONAL DESCRIPTION

#      PROGRAM HAS TWO MAIN PARTS. THE FIRST IS SELF-CHECK WHICH RUNS AS A ZERO PRIORITY JOB WITH NO CORE SET, AS
# PART OF THE BACK-UP IDLE LOOP. THE SECOND IS SHOW-BANKSUM WHICH RUNS AS A REGULAR EXECUTIVE JOB WITH ITS OWN
# STARTING VERB.
#      THE PURPOSE OF SELF-CHECK IS TO CHECK OUT VARIOUS PARTS OF THE COMPUTER AS OUTLINED BELOW IN THE OPTIONS.
#      THE PURPOSE OF SHOW-BANKSUM IS TO DISPLAY THE SUM OF EACH BANK, ONE AT A TIME.
#      A THIRD SECTION, DSKYCHK, LIGHTS UP ALL THE DSKY ELECTROLUMINESCENT ELEMENTS.
#      IN ALL THERE ARE 15 POSSIBLE OPTIONS IN THIS BLOCK II VERSION OF SELF-CHECK. MORE DETAIL DESCRIPTION MAY BE
# FOUND IN E-2065 BLOCK II AGC SELF-CHECK AND SHOW BANKSUM BY EDWIN D. SMALLY DECEMBER 1966.
#      THE DIFFERENT OPTIONS ARE CONTROLLED BY PUTTING DIFFERENT NUMBERS IN THE SMODE REGISTER (NOUN 27). BELOW IS
# A DESCRIPTION OF WHAT PARTS OF THE COMPUTER THAT ARE CHECKED BY THE OPTIONS, AND THE CORRESPONDING NUMBER, IN
# OCTAL, TO LOAD INTO SMODE.
# +-1  ALL PULSES POSSIBLE BY INTERNAL CONTROL OF THE COMPUTER.
# +-2  ALL THE IN-OUT INSTRUCTION PULSES.
# +-3  SPECIAL AND CENTRAL REGISTERS, ALL BIT COMBINATIONS.
# +-4  ERASABLE MEMORY
# +-5  FIXED MEMORY
# +-6,7,10  EVERYTHING IN THE PREVIOUS 5 OPTIONS.
# +-11  TURNS ON THE ELECTROLUMINESCENT DISPLAY IN THE DSKY.
# -0   SAME AS +-10 UNTIL AN ERROR IS DETECTED.
# +0   NO CHECK, PUTS COMPUTER INTO THE BACKUP IDLE LOOP.


# WARNINGS

#      SMODE LOADED WITH GREATER THAN OCTAL 11 PUTS COMPUTER INTO THE BACKUP IDLE LOOP.



# CALLING SEQUENCE

#      TO CALL SELF-CHECK KEY IN
#           V 21 N 27 E OPTION NUMBER E
#      TO CALL DSKYCHK KEY IN
#           V 21 N 27 E +-11 E
#      TO CALL SHOW-BANKSUM KEY IN
#           V 56 E         DISPLAYS FIRST BANK
#           V 33 E         PROCEED, DISPLAYS NEXT BANK

# EXIT MODES, NORMAL AND ALARM

#      SELF-CHECK NORMALLY CONTINUES INDEFINITELY UNLESS THERE IS AN ERROR DETECTED. IF SO + OPTION NUMBERS PUT
# COMPUTER INTO BACKUP IDLE LOOP, - OPTION NUMBERS RESTART THE OPTION.
#      THE -0 OPTION PROCEEDS FROM THE LINE FOLLOWING THE LINE WHERE THE ERROR WAS DETECTED.
#      COMPLETION OF DSKYCHK PUTS THE COMPUTER INTO THE BACKUP IDLE LOOP.
#      SHOW-BANKSUM PROCEEDS UNTIL A TERMINATE IS KEYED IN (V 34 E). THE COMPUTER IS PUT INTO THE BACKUP IDLE LOOP


# OUTPUT

#      SELF-CHECK UPON DETECTING AN ERROR LOADS THE SELF-CHECK ALARM CONSTANT (01102) INTO THE FAILREG SET AND
# TRIGGERS THE ALARM. THE ALARM ROUTINE DISPLAYS THE THREE FAILREGS. IF OPERATOR DESIRES FURTHER INFORMATION HE
# MAY KEY IN   V 05 N 31 E    DSKY DISPLAY IN R1 WILL BE ADDRESS +1 OF WHERE THE ERROR WAS DETECTED, IN R2 THE
# BANK NUMBER OF SELF-CHECK (37 OCTAL), AND IN R3 THE TOTAL NUMBER OF ERRORS DETECTED BY SELF-CHECK SINCE THE LAST
# FRESH START
#      DSKYCHK LIGHTS UP THE DSKY DISPLAY ELEMENTS STARTING WITH THE DIGIT9 IN ALL POSITIONS. EACH DISPLAY LASTS
# 5 SECONDS
#      SHOW-BANKSUM STARTING WITH BANK 0 DISPLAYS IN R1 +- THE BANK SUM (SHOULD EQUAL THE BANK NUMBER), IN R2 THE
# BANK NUMBER, AND IN R3 THE BUGGER WORD.


# ERASABLE INITIALIZATION REQUIRED

#      ACCOMPLISHED BY FRESH START
#           SMODE & ERESTORE SET TO +0


# DEBRIS

#      ALL EXITS FROM THE CHECK OF ERASABLE (ERASCHK) RESTORE ORIGINAL CONTENTS TO REGISTERS UNDER CHECK.
# EXCEPTION IS A RESTART. RESTART THAT OCCURS DURING ERASCHK DOES A FRESH START.

                SETLOC          ENDIMUF

SBIT1           OCT             00001                           # SBIT1 and SBIT2 must be together                          
SBIT2           OCT             00002                           
SBIT3           EQUALS          BIT3                            
SBIT4           EQUALS          BIT4                            
SBIT5           EQUALS          BIT5                            
SBIT6           EQUALS          BIT6                            
SBIT7           EQUALS          BIT7                            
SBIT8           EQUALS          BIT8                            
SBIT9           EQUALS          BIT9                            
SBIT10          EQUALS          BIT10                           
SBIT11          EQUALS          BIT11                           
SBIT12          EQUALS          BIT12                           
SBIT13          EQUALS          BIT13                           
SBIT14          EQUALS          BIT14                           
SBIT15          EQUALS          BIT15                           

S+ZERO          EQUALS          ZERO                            
S+1             EQUALS          SBIT1                            
S+2             EQUALS          SBIT2                            
S+3             EQUALS          THREE                           
S+4             EQUALS          FOUR                            
S+5             EQUALS          FIVE                            
S+6             EQUALS          SIX                             
S+7             EQUALS          SEVEN                           
S8BITS          EQUALS          LOW8                            # 00377
CNTRCON         OCTAL           00050                           # USED IN CNTRCHK
ERASCON1        OCTAL           00061                           # USED IN ERASCHK
ERASCON2        OCTAL           01374                           # USED IN ERASCHK
ERASCON6        OCTAL           01400                           # USED IN ERASCHK
ERASCON3        OCTAL           01461                           # USED IN ERASCHK
ERASCON4        OCTAL           01774                           # USED IN ERASCHK
S10BITS         EQUALS          LOW10                           # 01777, USED IN ERASCHK
SBNK03          EQUALS          PRIO6                           # 06000, USED IN ROPECHK
SIXTY           OCTAL           00060                           
SUPRCON         OCTAL           60017                           # USED IN ROPECHK
S+MAX           OCTAL           37777                           # ** S+MAX AND S-MAX MUST BE TOGETHER
S-MAX           OCTAL           40000                           # FOR DOUBLE PRECISION CHECKING.
S13BITS         OCTAL           17777                           
CONC+S1         OCTAL           25252                           # USED IN CYCLSHFT
OVCON           OCTAL           37737                           # USED IN RUPTCHK
DVCON           OCTAL           37776                           
SUPER100        EQUALS          BIT7
CONC+S2         OCTAL           52400                           # USED IN CYCLSHFT
ERASCON5        OCTAL           76777                           
S-7             OCTAL           77770                           
S-4             EQUALS          NEG4                            
S-3             EQUALS          NEG3                            
S-2             EQUALS          NEG2                            
S-1             EQUALS          NEGONE                          
S-ZERO          EQUALS          NEG0                            

                EBANK=          LST1                            
ADRS1           ADRES           SKEEP1                          

SRADRS          ADRES           SR                              

PRITYBIT        EQUALS          SBIT1
TCTRPBIT        EQUALS          SBIT3
RPTLKBIT        EQUALS          SBIT4
WATCHBIT        EQUALS          SBIT5
CTRMASK         OCT             77677
300MSEC         DEC             30
2SEC            DEC             200
0.64SEC         EQUALS          BIT7
BNK34ADR        FCADR           BANK34                          # With superbank = 100, this becomes bank 44


PRERRORS        CA              ERESTORE                        # IS IT NECESSARY TO RESTORE ERASABLE
                EXTEND                                          
                BZF             ERRORS                          # NO
                EXTEND                                          
                DCA             SKEEP5                          
                INDEX           SKEEP7                          
                DXCH            0000                            # RESTORE THE TWO ERASABLE REGISTERS
                CA              S+ZERO                          
                TS              ERESTORE                        
ERRORS          CA              Q                               
                TS              SFAIL                           # SAVE Q FOR FAILURE LOCATION
                INCR            ERCOUNT                         # KEEP TRACK OF NUMBER OF MALFUNCTIONS.
                TC              ALARM                           
                OCT             01102                           # SELF-CHECK MALFUNCTION INDICATOR
                CCS             SMODE                           
                CA              S+ZERO                          
                TS              SMODE                           
                TC              SELFIDLE                        # GO TO IDLE LOOP
                TC              SFAIL                           # CONTINUE WITH SELF-CHECK

SELFIDLE        TC              POSTJUMP
                CADR            SELFCHK

+0CHK           CS              A                               
-0CHK           CCS             A                               
                TCF             ERRORS                          
                TCF             ERRORS                          
                TCF             ERRORS                          
                TC              Q                               

+1CHK           CS              A                               
-1CHK           CCS             A                               
                TCF             PRERRORS                        
                TCF             PRERRORS                        
                CCS             A                               
                TCF             PRERRORS                        
                TC              Q                               

ENDSELFF        EQUALS

                BANK            20

SELFADRS        ADRES           SELFCHK                         # SELFCHK RETURN ADDRESS.  SHOULD BE PUT
                                                                # IN SELFRET WHEN GOING FROM SELFCHK TO
                                                                # SHOWSUM AND PUT IN SKEEP1 WHEN GOING
                                                                # FROM SHOWSUM TO SELF-CHECK.

SMODECHK        EXTEND                                          
                QXCH            SKEEP1                          
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CCS             SMODE                           
                TC              SOPTIONS                        
                TC              SMODECHK        +2              # TO BACKUP IDLE LOOP
                TC              SOPTIONS                        
                INCR            SCOUNT                          
                TC              SKEEP1                          # CONTINUE WITH SELF-CHECK

SOPTIONS        AD              S-7                             
                EXTEND                                          
                BZMF            +3                              # FOR OPTIONS BELOW NINE.
BNKOPTN         TC              POSTJUMP                        # GO TO ANOTHER BANK FOR OPTIONS ABOVE 8.
                CADR            SBNKOPTN                        
                INCR            SCOUNT                          # FOR OPTIONS BELOW NINE.
                AD              S+7                             

                INDEX           A                               
                TC              SOPTION1                        
SOPTION1        TC              TC+TCF                          
SOPTION2        TC              IN-OUT1                         
SOPTION3        TC              COUNTCHK                        
SOPTION4        TC              ERASCHK                         
SOPTION5        TC              ROPECHK                         
SOPTION6        TC              MPNMBRS                         
SOPTION7        TC              DVCHECK                         
SOPTON10        TC              SKEEP1                          # CONTINUE WITH SELF-CHECK

SELFCHK         TC              SMODECHK                        # ** CHARLEY, COME IN HERE

# TC+TCF CHECKS ALL OF THE PULSES OF TCF AND ALL OF THE PULSES OF TC
# EXCEPT ABILITY TO TC TO ERASABLE.
# ALSO FIRST TIME CS FIXED MEMORY IS USED
TC+TCF          TC              +2                              
                TC              CCSCHK                          
                TCF             +2                              # $ TCF FIXED MEMORY
                TC              ERRORS                          
                CS              S+3                             # $ CS FIXED MEMORY
                TC              Q                               # $
                TC              ERRORS                          

# CCSCHK CHECKS ALL OF CCS EXCEPT RB WG.
# ALSO CHECKS TS ERASABLE, CS SC, AND CS ERASABLE MEMORY.
CCSCHK          CCS             A                               # $ CCS SC, C(A) = -3
                TC              ERRORS                          
                TC              ERRORS                          
                TC              +2                              
                TC              ERRORS                          
                CCS             A                               # $ C(A) = +2, RESULT OF CCS -NUMBER
                TC              +4                              
                TC              ERRORS                          
                TC              ERRORS                          
                TC              ERRORS                          
                TS              SKEEP1                          # $ TS ERASABLE
                CCS             SKEEP1                          # $ CCS ERASABLE, C(A) = +1, RESULT OF
                TC              +4                              # CCS +NUMBER
                TC              ERRORS                          
                TC              ERRORS                          
                TC              ERRORS                          
                CCS             A                               # $ C(A) = +0, RESULT OF CCS +1, CHECKS CI
                TC              ERRORS                          
                TC              +3                              
                TC              ERRORS                          
                TC              ERRORS                          
                CS              A                               # $ CS SC
                CCS             A                               # $ C(A) = -0, RESULT OF CCS +0
                TC              ERRORS                          
                TC              ERRORS                          
                TC              ERRORS                          
                CCS             A                               # $ RESULT OF CCS -0
                TC              ERRORS                          
                TC              +3                              
                TC              ERRORS                          
                TC              ERRORS                          
                CS              SKEEP1                          # $ CS ERASABLE. ALSO CHECKS BACK INTO
                TC              -1CHK                           # ERASABLE SEQUENCE.

# BZMFCHK CHECKS ALL PULSES OF BZMF.
# ALSO CHECKS CA FIXED MEMORY.
BZMFCHK         CAF             SBIT9                           # $ CA FIXED MEMORY
                EXTEND                                          
                BZMF            ERRBZMF                         
                CS              A                               
                EXTEND                                          
                BZMF            +2                              # $
                TC              ERRORS                          
                CA              S+MAX                           
                AD              S+1                             
                EXTEND                                          
                BZMF            ERRBZMF2                        # $ + OVERFLOW, CHECK 01-0000
                CA              S+ZERO                          
                EXTEND                                          
                BZMF            +2                              # $
                TC              ERRORS                          
                CS              A                               
                EXTEND                                          
                BZMF            +4                              # $
                TC              ERRORS                          
ERRBZMF         TC              ERRORS                          # FROM BZMF WITH +NON-ZERO
ERRBZMF2        TC              ERRORS                          # OVERFLOW WITH +0

# RESTORE1 AND 2 CHECKS INSTRUCTIONS (WITH STAR) ABILITY TO READ BACK INTO
# ERASABLE MEMORY. NOT NORMALLY INTERESTED IN CONTENTS OF A REGISTER.
# FIRST TIME MANY INSTRUCTIONS ARE USED.
# RESTORE1 ALSO CHECKS INDEX (WITHOUT EXTRACODE) ERASABLE, CA ERASABLE,
# AND MASK ERASABLE.
RESTORE1        CAF             SRADRS                          # ADDRESS OF SR
                TS              SKEEP7                          
                CA              S8BITS                          # 00377
                NDX             SKEEP7                          # $ INDEX ERASABLE                       *
                TS              0000                            # TS SR, C(SR) = 00177
                CCS             SR                              # C(SR) = 00077                          *
                NDX             SKEEP7                          # CHECKS C(SKEEP7) CORRECT
                CS              0000                            # C(SR) = 00037
                AD              SR                              # C(SR) = 00017                          *
                EXTEND                                          
                MSU             SR                              # C(SR) = 00007                          *
                EXTEND                                          
                SU              SR                              # C(SR) = 00003                          *
                CA              SR                              # $ C(SR) = +1, C(A) = +3, CA ERASABLE   *
                MASK            SR                              # $ B(SR) = C(SR) = +1, MASK ERASABLE    *
                TC              +1CHK                           
                EXTEND                                          
                MP              SR                              
                EXTEND                                          
                DV              SR                              
                CA              SR                              # $ CA ERASABLE
                TC              +1CHK                           # MAKES SURE MASK, MP, AND DV DO NOT EDIT.

# RESTORE2 ALSO CHECKS XCH ERASABLE,INDEX (WITH EXTRACODE) ERASABLE AND
# FIXED MEMORY, DCS ERASABLE, CA SC, AND DCA ERASABLE.
RESTORE2        CAF             ADRS1                           # ADDRESS OF SKEEP1
                TS              SKEEP6                          
                CA              S-1                             
                TS              SKEEP1                          # -1
                CS              A                               
                XCH             SKEEP1                          # $ XCH ERASABLE, C(SKEEP1) = +1
                XCH             SKEEP2                          # $ XCH ERASABLE, C(SKEEP2) = -1
                EXTEND                                          
                NDX             SKEEP6                          # $ NDX ERASABLE                         *
                DCA             0000                            # DCA ERASABLE                           *
                EXTEND                                          
                NDX             ADRS1                           # $ NDX FIXED MEMORY                     *
                DCS             0000                            # $ DCS ERASABLE MEMORY                  *
                TC              -1CHK                           # MAKES SURE DCS ERASABLE OK
                CA              L                               # $ CA SC
                TC              +1CHK                           
                EXTEND                                          
                NDX             SKEEP6                          # MAKE SURE C(SKEEP6) IS STILL CORRECT
                DCA             0000                            # $ DCA ERASABLE
                TC              +1CHK                           
                CA              L                               
                TC              -1CHK                           

# RESTORE3 CHECKS ABILITY TO RESTORE INSTRUCTIONS BACK INTO ERASABLE
# MEMORY. IT IS ONLY NECESSARY TO RESTORE ONE INSTRUCTION BECAUSE THE
# G REGISTER DOES NOT CHANGE.
# ALSO CHECKS TC TO ERASABLE MEMORY.
RESTORE3        CA              SBIT15                          # CS
                TS              SKEEP1                          # 40000
                CA              S+2                             # TC Q
                TS              SKEEP2                          
                CA              S+1                             # +1
                TC              SKEEP1                          # $ TC ERASABLE
                TC              -1CHK                           # FIRST TIME BACK FROM ERASABLE.
                TC              SKEEP1                          
                TC              -0CHK                           # SECOND TIME BACK FROM ERASABLE.

# BZFCHK CHECKS ALL PULSES OF BZF.
BZFCHK          CAF             S+5                             
                EXTEND                                          
                BZF             ERRBZF1                         # $
                CS              A                               
                EXTEND                                          
                BZF             ERRBZF2                         # $
                CA              S+MAX                           
                AD              S+1                             # 01-00000
                EXTEND                                          
                BZF             ERRBZF3                         # $
                CS              A                               
                EXTEND                                          
                BZF             ERRBZF4                         # $
                CAF             S+ZERO                          
                EXTEND                                          
                BZF             +2                              # $
                TC              ERRORS                          
                CS              A                               
                EXTEND                                          
                BZF             +6                              # $
                TC              ERRORS                          
ERRBZF1         TC              ERRORS                          # +NON-ZERO
ERRBZF2         TC              ERRORS                          # -NON-ZERO
ERRBZF3         TC              ERRORS                          # 01-00000
ERRBZF4         TC              ERRORS                          # 10-37777

# DXCH+DIM CHECKS ALL PULSES OF DXCH AND DIM.
# ALSO CHECKS TS WITH OVERFLOW, TS SC, CA SC, AND AD ERASABLE.
DXCH+DIM        CA              S+MAX                           
                AD              S+2                             # OVERFLOW WITH +1
                TS              SKEEP1                          # $ TS WITH OVERFLOW, +1
                TC              ERRORS                          
                CS              A                               
                TS              SKEEP2                          
                CS              S+MAX                           
                TS              L                               # $ TS SC, 40000
                CS              A                               # 37777
                DXCH            SKEEP1                          # $ DXCH ERASABLE
                TC              +1CHK                           
                CA              L                               # $ CA SC
                TC              -1CHK                           
                EXTEND                                          
                DIM             SKEEP1                          # $ DIM ERASABLE, DIM + NUMBER, 37776
                EXTEND                                          
                DIM             SKEEP2                          # $ DIM - NUMBER, 40001
                CA              S+MAX                           # 37777
                AD              SKEEP2                          # $ AD ERASABLE, +1
                TC              +1CHK                           
                CS              S+MAX                           # 40000
                AD              SKEEP1                          # -1
                TC              -1CHK                           
                CA              S+1                             # +1
                EXTEND                                          
                DIM             A                               # $ DIM SC, DIM +1
                EXTEND                                          
                DIM             A                               # $ DIM -0
                TC              -0CHK                           
                EXTEND                                          
                DIM             A                               # $ DIM +0
                TC              +0CHK                           

# DAS+INCR CHECKS ALL PULSES OF DAS AND INCR.
# ALSO CHECKS DCA FIXED, LXCH SC, DCA ERASABLE, AD ERASABLE, DCS FIXED,
# DCS ERASABLE, AND XCH SC.
DAS+INCR        CA              S-1                             
DAS++           TS              L                               # -1
                CA              S+2                             # +2
                DAS             A                               # $ DAS SC, C(A) = +4 AND C(L) = -2
                AD              S-3                             # $ AD FIXED MEMORY
                TC              +1CHK                           
                CA              S+1                             
                AD              L                               # $ AD SC, -1
                TC              -1CHK                           
# DAS WITH INTERFLOW IN LOW ORDER AND NET OVERFLOW
DAS+-           EXTEND                                          
                DCA             S+MAX                           # $DCA FIXED MEMORY
                DXCH            SKEEP3                          # 37777, 40000
                CA              S-2                             
                TS              L                               
                CA              S+3                             # C(A) = +3, C(L) = -2
                DAS             SKEEP3                          # $ DAS ERASABLE
                LXCH            A                               # $ LXCH SC
                TC              +0CHK                           
                CA              L                               
                TC              +1CHK                           
                EXTEND                                          
                DCA             SKEEP3                          # $ DCA ERASABLE
                LXCH            A                               # C(A) = -1, C(L) = +1
                TC              -1CHK                           
                CA              L                               
                TC              +1CHK                           
# INCRCHK CHECKS ALL INCR PULSES EXCEPT WOVR.
INCRCHK         INCR            SKEEP4                          # $ INCR ERASABLE, -0
                AD              SKEEP4                          # $ AD ERASABLE
                TC              -0CHK                           
                INCR            A                               # $ INCR SC, +1
                TC              +1CHK                           
# DAS WITH OVERFLOW IN LOW ORDER AND NET UNDERFLOW
DAS-+           EXTEND                                          
                DCS             S+MAX                           # $ DCS FIXED MEMORY
                DXCH            SKEEP1                          # 40000, 37777
                CA              S+3                             # +3
                TS              L                               
                CS              A                               # -3
                DAS             SKEEP1                          # $
                TC              -1CHK                           
                EXTEND                                          
                DCS             SKEEP1                          # $ DCS ERASABLE (+1, -2)
                XCH             L                               # $ XCH SC (-2, +1)
                AD              S+1                             
                TC              -1CHK                           
                CA              L                               
                TC              +1CHK                           

# MPCHK CHECKS ALL PULSES OF MP, AUG, AND ADS.
MPCHK           CA              S+1                             
                EXTEND                                          
                AUG             A                               # $ AUG SC, +2
                TS              SKEEP5                          # +2
                CS              A                               
                TS              Q                               # -2
                CS              A                               
MP++            EXTEND                                          
                MP              S+MAX                           # $ MP FIXED MEMORY, +1, 37776
                AD              L                               # 37777
MP+-            EXTEND                                          
                MP              Q                               # $ MP SC, -1, 40001
                ADS             L                               # $ ADS SC, 40000
                AD              DVCON                           
                TC              -1CHK                           
                CA              L                               
MP-+            EXTEND                                          
                MP              SKEEP5                          # $ MP ERASABLE, -1, 40001
                TS              SKEEP6                          
                EXTEND                                          
                AUG             SKEEP6                          # $ AUG ERASABLE, -2
                AD              L                               # 40000
MP--            EXTEND                                          
                MP              SKEEP6                          # $ +1, 37776
                TC              +1CHK                           
                CS              L                               # 40001
                AD              DVCON                           
                TC              -0CHK                           
                CA              S+1                             
                ADS             SKEEP6                          # $ ADS ERASABLE, +1
                TC              -1CHK                           
                CA              SKEEP6                          
                TC              -1CHK                           

# DVCH AND DVQXCHK CHECK ALL OF PULSES OF DV AND QXCH.
# ALSO CHECKS TS WITH UNDERFLOW
DVCHK           CA              SBIT14                          # 20000
                TS              SKEEP1                          
                AD              A                               # OVERFLOW
                AD              S+1                             
                TS              L                               # $ TS SC WITH OVERFLOW, +1
                TC              ERRORS                          
                CS              A                               
                TS              SKEEP2                          # -1
                CA              S-ZERO                          # -0
                LXCH            SKEEP1                          # $ LXCH ERASABLE
DV++            EXTEND                                          
                DV              SKEEP1                          # $ DV ERASABLE, C(A) = 20000, C(L) = +0
                CS              A                               
                LXCH            A                               
                TC              +0CHK                           
DV--            EXTEND                                          
                DV              SKEEP2                          # $ 20000, +0
                TS              SKEEP4                          # 20000
                CS              A                               
                TS              SKEEP3                          # -(20000)
                AD              SBIT14                          
                TC              -0CHK                           
                CA              L                               
                TC              -0CHK                           
DV+-            CA              S+MAX                           
                TS              L                               
                CA              S13BITS                         
                EXTEND                                          
                DV              SKEEP3                          # $ -(37777), +(17777)
                XCH             L                               
                CS              A                               
DV-+            EXTEND                                          
                DV              SKEEP4                          # $ -(37777), -(17777)
                AD              DVCON                           
                TC              -1CHK                           
                CA              S+MAX                           
                XCH             L                               # ALSO PUTS 37777 IN L FOR DV-+,-
                AD              SBIT14                          
                TC              +1CHK                           
DV-+,+          CS              S13BITS                         # -(17777)
                EXTEND                                          
                DV              SKEEP4                          
                AD              L                               # -(37775)
                AD              DVCON                           
                TC              +1CHK                           
                XCH             L                               
                TC              -1CHK                           # ALSO PUTS +0 IN L FOR DVQXCH
DVQXCHK         CS              DVCON                           
                TS              Q                               # 40001
                CS              A                               
                EXTEND                                          
                DV              Q                               # $ DV SC, -(37777), +(37776)
                EXTEND                                          
                QXCH            L                               # $ QXCH SC, C(L) = 40001, C(Q) = 37776
                AD              Q                               
                TC              -1CHK                           
                CA              L                               
                AD              S+MAX                           
                TC              +1CHK                           
                EXTEND                                          
                QXCH            SKEEP1                          # $ QXCH ERAS., C(Q) = +1, C(SKEEP1) = +3
                CA              Q                               
                TC              +1CHK                           
                CS              SKEEP1                          # -3
                AD              S+2                             
                TC              -1CHK                           

# MSUCHK CHECKS ALL PULSES OF MSU EXCEPT RB WG.
MSUCHK          CA              S+ZERO                          
                TS              SKEEP1                          # +0
                CS              A                               
                TS              SKEEP2                          # -0
                EXTEND                                          
                MSU             A                               # $ MSU SC, +0
                TC              +0CHK                           
                EXTEND                                          
                MSU             SKEEP2                          # $ MSU ERASABLE, +1
                TC              +1CHK                           
                EXTEND                                          
                DCA             S+MAX                           
                EXTEND                                          
                MSU             L                               # $ CHECKS RUS WA, ALSO -1 FROM NEG. NO.
                TS              A                               
                TC              +2                              
                TC              ERRORS                          
                TC              -1CHK                           

# MASKCHK FINISHES CHECKING MASK INSTRUCTION.
MASKCHK         CA              S+7                             
                TS              L                               
                MASK            S-7                             # $ MASK FIXED MEMORY
                TC              +0CHK                           
                CA              S+1                             
                MASK            L                               # $ MASK SC
                TC              +1CHK                           

# NDX+SU FINISHES CHECKING BOTH INDEX INSTRUCTIONS. ALSO CHECKS ALL OF SU
# EXCEPT RB WG.
NDX+SU          CA              S+1                             
                TS              L                               
                TS              SKEEP1                          
                NDX             A                               # $ NDX SC
                AD              0000                            # AD L, +2
                EXTEND                                          
                SU              SKEEP1                          # $ SU ERASABLE
                TC              +1CHK                           
                EXTEND                                          
                NDX             L                               # $ NDX SC
                SU              0000                            # $ SU SC, SU L
                TC              -1CHK                           

# D--SC CHECKS DCS SC, DXCH SC, AND DCA SC.
D--SC           CA              S+2                             
                TS              L                               # +2
                CA              S+1                             
                EXTEND                                          
                DCS             A                               # $ DCS SC, C(L) = -2
                TC              -1CHK                           
# AFTER DXCH C(A) = B(Q) = +3, C(L) = B(A) = +0, C(Q) = B(L) = -1.
                DXCH            L                               # $ DXCH SC
                TS              SKEEP3                          
                AD              Q                               
                TC              +1CHK                           
                CA              L                               
                TC              +0CHK                           
                CA              S-1                             
                TS              Q                               
                CS              A                               
                EXTEND                                          
# AFTER DCA C(A) = C(L) = C(Q) = B(Q) = -1.
                DCA             L                               # $ DCA SC
                AD              Q                               
                AD              SKEEP3                          
                TC              +1CHK                           
                CA              L                               
                TC              -1CHK                           

# D--LCHK CHECKS THAT OVERFLOW IS LOST IN PROCESS OF GOING THROUGH L REG.
# ALSO CHECKS THAT Q WILL HOLD 16 BITS
D--LCHK         CA              S-2                             
                TS              Q                               
                CA              S-MAX                           
                ADS             Q                               
                CS              Q                               
                TS              A                               
                TC              ERRORS                          
                EXTEND                                          
                DCA             L                               
                TS              A                               
                TC              +2                              
                TC              ERRORS                          
                TC              -1CHK                           

# CHECKS OVERFLOW, UNDERFLOW,END-AROUND-CARRY, AND SIGN CHANGE OF ADDER.
# ALSO CHECKS ADS SC WITH OVERFLOW AND TS A WITH UNDERFLOW
ADDRCHK         CA              SBIT14                          # 20000
                TS              Q                               
                ADS             Q                               # $ ADS SC, OVERFLOW
                ADS             Q                               # UNDERFLOW
                TS              A                               # $ TS SC WITH UNDERFLOW
                TC              ERRORS                          
                ADS             Q                               
                TC              +1CHK                           

# RUPTCHK CHECKS THAT INTERRUPT DOES NOT OCCUR WHILE OVERFLOW OR UNDERFLOW
# IS IN THE A REGISTER. ALSO CHECKS THAT INHINT RELINT WORK PROPERLY.
RUPTCHK         INHINT                                          
                CA              S+ZERO                          
                TS              ZRUPT                           
                RELINT                                          
                AD              TIME4                           
                TS              SKEEP1                          
TENMS           CS              SKEEP1                          
                AD              TIME4                           # WAIT FOR NEXT TIME4 INCREMENT
                EXTEND                                          
                BZF             TENMS                           
                INHINT                                          
                CA              ZRUPT                           
                EXTEND                                          
                BZF             +2                              # NO INTERRUPT.
                TC              RUPTCHK                         # THERE WAS AN INTERRUPT. START AGAIN.
                CAF             S+1                             # 2 1/2 MS UNTILE NEXT T3 INTERRUPT.
                TC              WAITLIST                        
                EBANK=          LST1                            
                2CADR           TSKADRS                         

                CA              S+MAX                           
                AD              OVCON                           # CONTROLS TIME SPENT IN OF-UF LOOP
                RELINT                                          
WAIT            CS              A                               
                CCS             A                               
                TC              INHNTCHK                        
RUPTCON         ADRES           C(BRUPT)                        
                AD              S+2                             
                TC              WAIT                            
INHNTCHK        INHINT                                          # T3 RUPT SHOULD BE WAITING
                TS              SKEEP5                          
                TC              ERRORS                          
                RELINT                                          
C(BRUPT)        CS              ZRUPT                           # INTERRUPT SHOULD HAPPEN HERE
                EXTEND                                          
                BZF             +6                              # MAKES SURE AN INTERRUPT DID OCCUR
                TC              INSTCHK                         # AN INTERRUPT. END OF RUPTCHK
TSKADRS         CS              ZRUPT                           
                AD              RUPTCON                         
                TC              -1CHK                           
                TC              TASKOVER                        
                TC              ERRORS                          # NO INTERRUPT                        

# Go perform the (bugfixed) instruction-level tests from Retread 44.
INSTCHK         TC              CHECKNJ                         # CHECK FOR NEW JOB
                TC              POSTJUMP
                CADR            TCCHK

# Retread tests are done. Go perform custom extended tests.
INSTDONE        TC              CHECKNJ                        
                TC              POSTJUMP
                CADR            EXTTESTS

# All done checking instructions out. Move on.
EXTTDONE        TC              SMODECHK                        

# IN-OUT1 CHECKS ALL PULSES OF WRITE AND READ
IN-OUT1         CA              S-1                             
WRITECHK        EXTEND                                          
                WRITE           Q                               
                LXCH            Q                               # PUT C(Q) IN L
                TC              -1CHK                           
READCHK         EXTEND                                          # C(L) = 77776
                READ            L                               
                TC              -1CHK                           
                CA              L                               
                TC              -1CHK                           

# IN-OUT2 CHECKS ALL PULSES OF ROR AND WOR
IN-OUT2         CS              S+3                             
RORCHK          TS              L                               # 77774
                CA              DVCON                           # 37776
                EXTEND                                          
                ROR             L                               # $ ROR, -1
                TC              -1CHK                           
WORCHK          CA              DVCON                           # C(L) STILL 77774
                EXTEND                                          
                WOR             L                               # $ WOR, -1
                TC              -1CHK                           
                CA              L                               
                TC              -1CHK                           

# IN-OUT3 CHECKS ALL PULSES OF RAND, WAND, AND RXOR
IN-OUT3         CS              DVCON                           
RANDCHK         TS              L                               # 40001
                CA              S13BITS                         # 17777
                EXTEND                                          
                RAND            L                               # $ RAND, +1
                TC              +1CHK                           
WANDCHK         CA              S13BITS                         # C(L) STILL 40001
                EXTEND                                          
                WAND            L                               # $ WAND, +1
                TC              +1CHK                           
                CS              S+5                             
                XCH             L                               # ALSO PUT -5 IN L FOR RXORCHK
                TC              +1CHK                           
RXORCHK         CA              S+6                             
                EXTEND                                          
                RXOR            L                               # $ RXOR, -3
                AD              S+2                             
                TC              -1CHK                           
                CA              L                               
                AD              S+4                             
                TC              -1CHK                           

                TC              SMODECHK                        

# COUNTCHK COUNTS UP 14 BIT NUMBER WITH SIGN.
# TAKES APPROXIMATELY 8.7 SECONDS.
# ** PUT IN CCS NEWJOB FOR ROPE.
COUNTCHK        EXTEND                                          
                DCA             S+MAX                           
                DXCH            SKEEP6                          # PUT 37777 IN SKEEP6 AND 40000 IN SKEEP7
+LOOP           CA              SKEEP6                          
                XCH             Q                               
                EXTEND                                          
                DCS             L                               
                CCS             A                               
                TC              -NMBR                           
                TC              ENDCOUNT                        
                TS              SKEEP6                          
                AD              SKEEP7                          
                TC              -1CHK                           
                INCR            SKEEP7                          
                TC              +LOOP                           
-NMBR           AD              L                               
                TC              -1CHK                           
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CS              SKEEP6                          
                TC              +LOOP           +1              
ENDCOUNT        CA              SKEEP7                          # -0
                AD              SKEEP6                          # SKEEP6 SHOULD BE +0
                TC              -0CHK                           

# O-UFLOW COUNTS DOWN OVERFLOW AND UNDERFLOW NUMBERS.
# TAKES APPROXIMATELY 10.8 SECONDS
O-UFLOW         CA              S-MAX                           
                TS              SKEEP5                          # 40000
                CS              A                               
OFLOOP          INHINT                                          
                AD              S+MAX                           
                AD              S+1                             
                XCH             Q                               
                CCS             Q                               
                TC              -NMBRS                          
                TC              ERRORS                          # CAN PUT IN CONSTANT
                TS              SKEEP3                          
                TC              ERRORS                          
                CA              SKEEP3                          
                AD              SKEEP5                          
                TC              -1CHK                           
                RELINT                                          
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CA              SKEEP4                          
                EXTEND                                          
                DIM             SKEEP5                          
                TC              OFLOOP                          
-NMBRS          TS              SKEEP4                          
                TC              ENDOFUF                         
                CA              SKEEP4                          
                AD              SKEEP5                          
                TC              -1CHK                           
                CA              SKEEP5                          
                AD              S-MAX                           
                AD              S-1                             
                TC              OFLOOP          +3              
ENDOFUF         CA              SKEEP5                          
                TC              -0CHK                           
                CS              SKEEP4                          
                AD              DVCON                           
                TC              -1CHK                           
                RELINT                                          

                TC              SMODECHK                        

# SKEEP7 HOLDS LOWEST OF TWO ADDRESSES BEING CHECKED.
# SKEEP6 HOLDS B(X+1).
# SKEEP5 HOLDS B(X).
# SKEEP4 CONTROLS CHECKING OF NON-SWITCHABLE ERASABLE MEMORY WITH
# BANK NUMBERS IN EB.
# SKEEP3 HOLDS LAST ADDRESS BEING CHECKED (HIGHEST ADDRESS).
# SKEEP2 HOLDS C(EBANK) DURING CHECKNJ
# ERASCHK TAKES APPROXMATELY 7 SECONDS
ERASCHK         CA              S+1                             
                TS              SKEEP4                          
0EBANK          CA              S+ZERO                          
                TS              EBANK                           
                CA              ERASCON3                        # 01461
                TS              SKEEP7                          # STARTING ADDRESS
                CA              S10BITS                         # 01777
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP                        

E134567B        CA              ERASCON6                        # 01400
                TS              SKEEP7                          # STARTING ADDRESS
                CA              S10BITS                         # 01777
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP                        

2EBANK          CA              ERASCON6                        # 01400
                TS              SKEEP7                          # STARTING ADDRESS
                CA              ERASCON4                        # 01774
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP                        

NOEBANK         TS              SKEEP4                          # +0
                CA              ERASCON1                        # 00061
                TS              SKEEP7                          # STARTING ADDRESS
                CA              ERASCON2                        # 01374
                TS              SKEEP3                          # LAST ADDRESS CHECKED

ERASLOOP        INHINT                                          
                EXTEND                                          
                INDEX           SKEEP7                          
                DCA             0000                            
                DXCH            SKEEP5                          # STORES C(X) AND C(X-1) IN SKEEP6 AND 5.
                CA              SKEEP7                          
                TS              ERESTORE                        # IF RESTART, RESTORE C(X) AND C(X+1)
                TS              L                               
                INCR            L                               
                NDX             A                               
                DXCH            0000                            # PUTS OWN ADDRESS IN X AND X +1
                NDX             SKEEP7                          
                CS              0001                            # CS  X+1
                NDX             SKEEP7                          
                AD              0000                            # AD X
                TC              -1CHK                           
                CA              ERESTORE                        # HAS ERASABLE BEEN RESTORED
                EXTEND                                          
                BZF             ELOOPFIN                        # YES, EXIT ERASLOOP.
                EXTEND                                          
                NDX             SKEEP7                          
                DCS             0000                            # COMPLEMENT OF ADDRESS OF X AND X+1
                NDX             SKEEP7                          
                DXCH            0000                            # PUT COMPLEMENT OF ADDRESS OF X AND X+1
                NDX             SKEEP7                          
                CS              0000                            # CS X
                NDX             SKEEP7                          
                AD              0001                            # AD X+1
                TC              -1CHK                           
                CA              ERESTORE                        # HAS ERASABLE BEEN RESTORED
                EXTEND                                          
                BZF             ELOOPFIN                        # YES, EXIT ERASLOOP.
                EXTEND                                          
                DCA             SKEEP5                          
                NDX             SKEEP7                          
                DXCH            0000                            # PUT B(X) AND B(X+1) BACK INTO X AND X+1
                CA              S+ZERO                          
                TS              ERESTORE                        # IF RESTART, DO NOT RESTORE C(X), C(X+1)
ELOOPFIN        RELINT                                          
                CA              EBANK                           # STORES C(EBANK)
                TS              SKEEP2                          
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CA              SKEEP2                          # REPLACES B(EBANK)
                TS              EBANK                           
                INCR            SKEEP7                          
                CS              SKEEP7                          
                AD              SKEEP3                          
                EXTEND                                          
                BZF             +2                              
                TC              ERASLOOP                        # GO TO NEXT ADDRESS IN SAME BANK
                CCS             SKEEP4                          
                TC              NOEBANK                         
                INCR            SKEEP4                          # PUT +1 IN SKEEP4
                CA              EBANK                           
                AD              SBIT9                           
                TS              EBANK                           
                AD              ERASCON5                        # 76777, CHECK FOR BANK E3
                EXTEND                                          
                BZF             2EBANK                          
                CCS             EBANK                           
                TC              E134567B                        # GO TO EBANKS 1,3,4,5,6, AND 7
                CA              ERASCON6                        # END OF ERASCHK
                TS              EBANK                           
# CNTRCHK PERFORMS A CS OF ALL REGISTERS FROM OCT. 60 THROUGH OCT. 10.
# INCLUDED ARE ALL COUNTERS, T6-1, CYCLE AND SHIFT, AND ALL RUPT REGISTERS
CNTRCHK         CAF             CNTRCON                         # 00050
CNTRLOOP        TS              SKEEP2                          
                AD              SBIT4                           # +10 OCTAL
                INDEX           A                               
                CS              0000                            
                CCS             SKEEP2                          
                TC              CNTRLOOP                        

# CYCLSHFT CHECKS THE CYCLE AND SHIFT REGISTERS
CYCLSHFT        CA              CONC+S1                         # 25252
                TS              CYR                             # C(CYR) = 12525
                TS              CYL                             # C(CYL) = 52524
                TS              SR                              # C(SR) = 12525
                TS              EDOP                            # C(EDOP) = 00125
                AD              CYR                             # 37777         C(CYR) = 45252
                AD              CYL                             # 00-12524      C(CYL) = 25251
                AD              SR                              # 00-25251      C(SR) = 05252
                AD              EDOP                            # 00-25376      C(EDOP) = +0
                AD              CONC+S2                         # C(CONC+S2) = 52400
                TC              -1CHK                           
                AD              CYR                             # 45252
                AD              CYL                             # 72523
                AD              SR                              # 77775
                AD              EDOP                            # 77775
                AD              S+1                             # 77776
                TC              -1CHK                           

                INCR            SCOUNT          +1              
                TC              SMODECHK                        
                TC              ROPECHK                         

# SKEEP1 HOLDS SUM
# SKEEP2 HOLDS PRESENT CONTENTS OF ADDRESS IN ROPECHK AND SHOWSUM ROUTINES
# SKEEP2 HOLDS BANK NUMBER IN LOW ORDER BITS DURING SHOWSUM DISPLAY
# SKEEP3 HOLDS PRESENT ADDRESS (00000 TO 01777 IN COMMON FIXED BANKS)
#                              (04000 TO 07777 IN FXFX BANKS)
# SKEEP3 HOLDS BUGGER WORD DURING SHOWSUM DISPLAY
# SKEEP4 HOLDS BANK NUMBER AND SUPER BANK NUMBER
# SKEEP5 COUNTS 2 SUCCESSIVE TC SELF WORDS
# SKEEP6 CONTROLS ROPECHK OR SHOWSUM OPTION
# SKEEP7 CONTROLS WHEN ROUNTINE IS IN COMMON FIXED OR FIXED FIXED BANKS

STSHOSUM        TC              GRABDSP                         
                TC              PREGBSY                         
                TC              +3                              
ROPECHK         CA              S-ZERO                          
                TS              SKEEP6                          # ROPECHK OPTION
                CA              S+ZERO                          
                TS              SKEEP4                          # BANK NUMBER
                CA              S+1                             
COMMFX          TS              SKEEP7                          
                CA              S+ZERO                          
                TS              SKEEP1                          
                TS              SKEEP3                          
                CA              S+1                             
                TS              SKEEP5                          # COUNTS DOWN 2 TC SELF WORDS
COMADRS         CA              SKEEP4                          
                TS              L                               # TO SET SUPER BANK
                MASK            HI5                             
                AD              SKEEP3                          
                TC              SUPDACAL                        # SUPER DATA CALL
                TC              ADSUM                           
                AD              SBIT11                          # 02000
                TC              ADRSCHK                         

FXFX            CS              A                               
                TS              SKEEP7                          
                EXTEND                                          
                BZF             +3                              
                CA              SBIT12                          # 04000, STARTING ADDRESS OF BANK 02
                TC              +2                              
                CA              SBNK03                          # 06000, STARTING ADDRESS OF BANK 03
                TS              SKEEP3                          
                CA              S+ZERO                          
                TS              SKEEP1                          
                CA              S+1                             
                TS              SKEEP5                          # COUNTS DOWN 2 TC SELF WORDS
FXADRS          INDEX           SKEEP3                          
                CA              0000                            
                TC              ADSUM                           
                TC              ADRSCHK                         

ADSUM           TS              SKEEP2                          
                AD              SKEEP1                          
                TS              SKEEP1                          
                CAF             S+ZERO                          
                AD              SKEEP1                          
                TS              SKEEP1                          
                CS              SKEEP2                          
                AD              SKEEP3                          
                TC              Q                               

ADRSCHK         LXCH            A                               
                CCS             SKEEP5                          # IS CHECKSUM FINISHED
                TC              +3                              # NO
                TC              +2                              # NO
                TC              SOPTION                         # GO TO ROPECHK SHOWSUM OPTION
                CCS             L                               # -0 MEANS A TC SELF WORD.
                TC              CONTINU                         
                TC              CONTINU                         
                TC              CONTINU                         
                CCS             SKEEP5                          
                TC              CONTINU         +1              
                CA              S-1                             
                TC              CONTINU         +1              # AD IN THE BUGGER WORD
CONTINU         CA              S+1                             # MAKE SURE TWO CONSECUTIVE TC SELF WORDS
                TS              SKEEP5                          
                CCS             SKEEP6                          # +1 IN SKEEP6, SHOWSUM VIA EXECUTIVE
                CCS             NEWJOB                          
                TC              CHANG1                          
                TC              +2                              
                TC              CHECKNJ                         # -0 IN SKEEP6 FOR ROPECHK

ADRS+1          INCR            SKEEP3                          
                CCS             SKEEP7                          
                TC              COMADRS                         
                TC              COMADRS                         
                TC              FXADRS                          
                TC              FXADRS                          

NXTBNK          CS              SKEEP4                          
                AD              LSTBNKCH                        # LAST BANK TO BE CHECKED
                EXTEND                                          
                BZF             ENDSUMS                         # END OF SUMMING OF BANKS.
                CA              SKEEP4                          
                AD              SBIT11                          
                TS              SKEEP4                          # 37 TO 40 INCRMTS SKEEP4 BY END RND CARRY
                TC              CHKSUPR                         
17TO20          CA              SBIT15                          
                ADS             SKEEP4                          # SET FOR BANK 20
                TC              GONXTBNK                        
CHKSUPR         MASK            HI5                             
                EXTEND                                          
                BZF             NXTSUPR                         # INCREMENT SUPER BANK
27TO30          AD              S13BITS                         
                EXTEND                                          
                BZF             +2                              # BANK SET FOR 30
                TC              GONXTBNK                        
                CA              SIXTY                           # FIRST SUPER BANK
                ADS             SKEEP4                          
                TC              GONXTBNK                        
NXTSUPR         AD              SUPRCON                         # SET BNK 30 + INCR SUPR BNK AND CANCEL
                ADS             SKEEP4                          # ERC BIT OF THE 37 TO 40 ADVANCE.
GONXTBNK        CCS             SKEEP7                          
                TC              COMMFX                          
                CA              S+1                             
                TC              FXFX                            
                CA              SBIT7                           # HAS TO BE LARGER THAN NO OF FXSW BANKS.
                TC              COMMFX                          

ENDSUMS         CCS             SKEEP6                          
                TC              ROPECHK         +2              # START SHOWSUM AGAIN
                TC              ERRORS                          # Available space.
                TC              ERRORS
                TC              MPNMBRS         -1              # ROPECHK IS COMPLETED

SOPTION         CA              SKEEP4                          
                MASK            HI5                             # = BANK BITS
                TC              LEFT5                           
                TS              L                               # BANK NUMBER BEFORE SUPER BANK
                CA              SKEEP4                          
                MASK            S8BITS                          # = SUPER BANK BITS
                EXTEND                                          
                BZF             SOPT                            # BEFORE SUPER BANK
                TS              SR                              # SUPER BANK NECESSARY
                CA              L                               
                MASK            SEVEN                           
                AD              SR                              
                TS              L                               # BANK NUMBER WITH SUPER BANK
SOPT            CCS             SKEEP6                          
                TC              SDISPLAY                        
VNCON           OCTAL           00501                           # USED IN SHOWSUM. DISPLAY 3 REGISTERS.
                EBANK=          NEWJOB                          
LSTBNKCH        BBCON*                                          # * CONSTANT, LAST BANK.                

# CHANGE TO 31777 IF BANK 23 IS LAST BANK USED
BNKCHK          CCS             SKEEP1                          # WHEN C(SKEEP6) = -0
                TC              +4                              
SCADR           FCADR           NOKILL                          # * CONSTANT, USED IN SHOWSUM ONLY
                TC              +2                              
                CA              S-1                             # FOR BANK 00
                TS              SKEEP1                          
                CS              L                               # = - BANK NUMBER
                AD              SKEEP1                          
                TC              -1CHK                           
                TC              NXTBNK                          

# INITIALIZE SKEEP6 TO +1 TO PERFORM SHOWSUM
# START OF ROUTINE THAT DISPLAYS SUM OF EACH BANK
SHOWSUM         CAF             S+1                             
                TS              SKEEP6                          # SHOWSUM OPTION
                CAF             S+ZERO                          
                TS              SMODE                           # PUT SELF-CHECK TO SLEEP
                CA              SELFADRS                        # INITIALIZE SELFRET TO GO TO SELFCHK.
                TS              SELFRET                         
                INHINT                                          
                CAF             PRIO2                           
                TC              NOVAC                           
                EBANK=          SELFRET                         
                2CADR           STSHOSUM                        

                RELINT                                          
                TC              ENDOFJOB                        

SDISPLAY        CA              L                               # = BANK NUMBER
                XCH             SKEEP2                          # SKEEP2 HOLDS BANK NUMBER DURING DISPLAY
                TS              SKEEP3                          # SKEEP3 HOLDS BUGGER WORD DURING DISPLAY
NOKILL          CAF             ADRS1                           # ADDRESS OF SKEEP1
                TS              MPAC            +2              
                CAF             VNCON                           # DISPLAY 3 REGISTERS
                TC              NVSUB                           
                TC              SBUSY                           
                TC              FLASHON                         
                TC              ENDIDLE                         
                TC              +3                              # FINISHED WITH SHOWSUM
                TC              NXTBNK                          
                TC              NOKILL                          # SO CAN LOAD WITHOUT KILLING SHOWSUM
                TC              FREEDSP                         
                CA              SELFADRS                        # INITIALIZE SKEEP1 TO GO TO SELFCHK.
                TS              SKEEP1                          
                TC              ENDOFJOB                        

SBUSY           CAF             SCADR                           
                TC              NVSUBUSY                        

                TC              SMODECHK                        

# MULTIPLY SUBROUTINE TAKES APPROXIMATELY 19 SECONDS.
# (37777) X (37777 THROUGH 00001)
# C(A) COUNTS DOWN.  C(L) COUNTS UP.
MPNMBRS         CAF             S+MAX                           
                TS              SKEEP2                          
                CAF             S+MAX                           
                EXTEND                                          
                MP              SKEEP2                          
                AD              L                               # C(A) = 37777
                AD              S-MAX                           
                TC              -0CHK                           
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CCS             SKEEP2                          
                TS              SKEEP2                          
                CCS             SKEEP2                          
                TC              MPNMBRS         +2              
# (-1) X (37777 THROUGH 00001)
                CAF             S+MAX                           
                TS              SKEEP2                          
MPHIGH1         CAF             S-1                             
                EXTEND                                          
                MP              SKEEP2                          # C(A) = -0
                TC              -0CHK                           
                CA              L                               
                AD              SKEEP2                          
                TC              -0CHK                           
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CCS             SKEEP2                          
                TS              SKEEP2                          
                CCS             SKEEP2                          
                TC              MPHIGH1                         

# INTERCHANGE MULTIPLIER AND MULTIPLICAND
# (37777 THROUGH 00001) X (37777)
# C(A) COUNTS DOWN.  C(L) COUNTS UP.
                CAF             S+MAX                           
                TS              SKEEP1                          
MPAGAIN         CA              SKEEP1                          
                EXTEND                                          
                MP              S+MAX                           
                AD              L                               # C(A) = 37777
                AD              S-MAX                           
                TC              -0CHK                           
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CCS             SKEEP1                          
                TS              SKEEP1                          
                CCS             SKEEP1                          
                TC              MPAGAIN                         
# (37777 THROUGH 00001) X (-1)
                CAF             S+MAX                           
                TS              SKEEP1                          
MPHIGH2         CA              SKEEP1                          
                EXTEND                                          
                MP              S-1                             
                TC              -0CHK                           
                CA              L                               
                AD              SKEEP1                          
                TC              -0CHK                           
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CCS             SKEEP1                          
                TS              SKEEP1                          
                CCS             SKEEP1                          
                TC              MPHIGH2                         

                TC              SMODECHK                        

# ONCE THROUGH DIVIDE SUBROUTINE TAKES APPROXIMATELY 0.01 SECOND.
# TOTAL TIME SPENT IN DIVIDE SUBROUTINE IS APPROXIMATELY 21.5 SECONDS
# DIVIDE +-/17777/ +-/37777/ BY +-/20000/. THE CONTENTS OF THE A REGISTER
# AND THE L REGISTER WILL HAVE OPPOSITE SIGNS BEFORE DIVISION. THE
# QUOTIENT SHOULD BE +-/37774/ DEPENDING ON THE SIGN OF A AND THE SIGN
# OF THE DIVISOR. THE REMAINDER = +-1 DEPENDING ON THE SIGN OF A
DVCHECK         CS              SBIT12                          # -(04000)
                TS              SKEEP4                          
DVLOOP          INCR            SKEEP4                          
DV1CHK          CA              SBIT14                          # 20000
                TS              SKEEP1                          
                CS              A                               
                TS              SKEEP2                          
DV1++           CS              S+MAX                           
                TS              L                               # 40000
                CA              S13BITS                         
                EXTEND                                          
                DV              SKEEP1                          # +37774, +1
                TS              SKEEP7                          # 37774
                CA              S-MAX                           
                XCH             L                               # ALSO PUT 40000 IN L
                TC              +1CHK                           
DV1+-           CA              S13BITS                         # 17777
                EXTEND                                          
                DV              SKEEP2                          # -37774, +1
                AD              SKEEP7                          
                TC              -0CHK                           
                CA              S+MAX                           
                XCH             L                               # ALSO PUT 37777 IN L
                TC              +1CHK                           
DV1-+           CS              S13BITS                         # 60000
                EXTEND                                          
                DV              SKEEP1                          # -37774, -1
                TS              SKEEP6                          
                AD              SKEEP7                          
                TC              -0CHK                           
                CA              S+MAX                           
                XCH             L                               # ALSO PUT 37777 IN L
                TC              -1CHK                           
DV1--           CS              S13BITS                         # 60000
                EXTEND                                          
                DV              SKEEP2                          # +37774, -1
                AD              SKEEP6                          
                TC              -0CHK                           
                CA              S+MAX                           
                XCH             L                               # ALSO PUT 37777 IN L FOR DV2
                TC              -1CHK                           
                CA              SKEEP6                          # -37774
                AD              S-2                             # -37776
                AD              S+MAX                           
                TC              +1CHK                           

# DIVIDE +17777 + 37777 BY +20000.  THE RESULT SHOULD BE +37777 WITH
# +17777 REMAINDER.
DV2CHK          CA              S13BITS                         
                EXTEND                                          
                DV              SKEEP1                          
                AD              S-MAX                           
                TC              -0CHK                           
                CS              SBIT14                          # -20000
                AD              L                               
                TC              -1CHK                           

# DIVIDE +37776 BY +37776.  THE RESULT SHOULD BE +37777 AND THE
# REMAINDER SHOULD BE +37776.
DV4CHK          CA              S+ZERO                          
                TS              L                               
                CA              DVCON                           
                TS              SKEEP1                          # 37776
                EXTEND                                          
                DV              SKEEP1                          
                CS              A                               
                AD              DVCON                           
                TC              -1CHK                           
                CA              L                               # 37776
                AD              S-MAX                           
                TC              -1CHK                           

# DIVIDE SAME (ZERO).  THE CONTENTS OF THE A REGISTER AND L REGISTER WILL
# HAVE OPPOSITE SIGNS BEFORE DIVISION.  THE QUOTIENT WILL BE + OR - MAX.,
# DEPENDING UPON THE SIGN OF THE L REGISTER AND THE SIGN OF THE DIVISOR.
# C(L) REMAINS THE SAME BECAUSE IT IS THE DIVIDEND.
DV5CHK          CA              S+ZERO                          
                TS              SKEEP1                          # +0
                TS              L                               
                CS              A                               
                TS              SKEEP2                          # -0
DV5++           EXTEND                                          
                DV              SKEEP1                          # +37777, +0
                TS              SKEEP7                          # 37777
                CA              L                               
                TC              +0CHK                           
DV5+-           CS              A                               
                EXTEND                                          
                DV              SKEEP2                          # 40000, +0
                TS              SKEEP6                          # 40000
                AD              SKEEP7                          
                TC              -0CHK                           
                CS              A                               
                XCH             L                               # ALSO PUT -0 IN L
                TC              +0CHK                           
DV5-+           EXTEND                                          
                DV              SKEEP1                          # 40000, -0
                AD              SKEEP7                          
                TC              -0CHK                           
                CA              L                               
                TC              -0CHK                           
DV5--           EXTEND                                          
                DV              SKEEP2                          # 37777, -0
                AD              SKEEP6                          
                TC              -0CHK                           
                CA              L                               
                TC              -0CHK                           
                CA              SKEEP6                          # CHECK QUOTIENT
                AD              DVCON                           
                TC              -1CHK                           

                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CA              SKEEP4                          
                EXTEND                                          
                BZMF            DVLOOP                          
                INCR            SCOUNT          +2              
                TC              SELFCHK                         # START SELF-CHECK AGAIN

ENDSLFS1        EQUALS                                          

                SETLOC          ENDFAILS   

SBNKOPTN        TS              SKEEP1                          
                CS              A                               # GO TO BACKUP IDLE LOOP IF C(SMODE) IS
                AD              THREE                           # GREATER THAN OCTAL 12
                EXTEND                                          
                BZMF            TOSMODE         -2              
                CA              S+ZERO                          # ZERO SMODE FOR OPTIONS ABOVE 8.
                TS              SMODE                           
                CA              SKEEP1                          
                NDX             A                               
                TC              SOPTON11        -1              
SOPTON11        TC              DSKYCHK                         
SOPTON12        TC              RSTRTCHK

                CA              S+ZERO                          
                TS              SMODE                           
TOSMODE         TC              POSTJUMP                        
                CADR            SELFCHK

# THE FOLLOWING CONSTANTS ARE USED BY DSKYCHK.
DSKYCODE        OCTAL           05265                           # 00
                OCTAL           04143                           # 11
                OCTAL           05471                           # 22
                OCTAL           05573                           # 33
                OCTAL           04757                           # 44
                OCTAL           05736                           # 55
                OCTAL           05634                           # 66
                OCTAL           05163                           # 77
                OCTAL           05675                           # 88
                OCTAL           05777                           # 99
+-ZERO          OCTAL           07265                           
11DEC.          OCTAL           00013                           

# BITS 2 AND 6 TURN ON THE COMPUTER ACTIVITY AND VERB-NOUN FLASH.
S11CHAN         OCTAL           00042                           

DSKYCHK         CAF             TEN                             
                TS              SKEEP3                          
                INHINT                                          
                CAF             S+1                             # SET UP TEN MS INTERRUPT
                TC              WAITLIST                        
                2CADR           NXTNMBR                         

                RELINT                                          
                TC              TOSMODE                         # GO TO IDLE LOOP

SDSPTAB         TS              SKEEP3                          
                INHINT                                          
                NDX             SKEEP3                          
                CS              DSKYCODE                        
SBLANKS         TS              DSPTAB                          
                TS              DSPTAB          +1              
                TS              DSPTAB          +2              
                TS              DSPTAB          +3              
                TS              DSPTAB          +4              
                TS              DSPTAB          +5              
                TS              DSPTAB          +6              
                TS              DSPTAB          +7              
                TS              DSPTAB          +8D             
                TS              DSPTAB          +9D             
                TS              DSPTAB          +10D            
                CA              11DEC.                          
                TS              NOUT                            

DSKYWAIT        INHINT                                          
                CAF             BIT10                           # 5.12 SECOND WAIT
                TC              WAITLIST                        
                2CADR           NXTNMBR                         

                RELINT                                          
                TC              TASKOVER                        

NXTNMBR         CCS             SKEEP3                          
                TC              SDSPTAB                         # 9 THROUGH 0
                TC              -SIGN                           # -ZEROS
                TC              +SIGN                           # +ZEROS
                CCS             SKEEP2                          
                TC              NODSPLAY                        # PUTS BLANKS IN DSKY DISPLAY
                TC              LITESOUT                        # TURN OFF LIGHTS

-SIGN           CS              S+1                             
                TS              SKEEP3                          
                CA              S11CHAN                         # TURN ON VERB-NOUN FLASH
                EXTEND                                          # AND COMPUTER ACTIVITY LIGHTS.
                WOR             DSALMOUT                        
                CS              +-ZERO                          
                INHINT                                          
                TS              DSPTAB                          
                TS              DSPTAB          +3              
                TS              DSPTAB          +5              
                CAF             THREE                           
                TS              NOUT                            
                TC              DSKYWAIT                        
+SIGN           CS              ZERO                            
                TS              SKEEP3
                CA              S+1                             
                TS              SKEEP2                          
                INHINT                                          
                CS              +-ZERO                          
                TS              DSPTAB          +1              
                TS              DSPTAB          +4              
                TS              DSPTAB          +6              
                CAF             THREE                           
                TS              NOUT                            
                TC              DSKYWAIT                        

NODSPLAY        TS              SKEEP2                          # +0
                CS              BIT12                           # BLANKS
                INHINT                                          
                TC              SBLANKS                         # PUTS BLANKS IN ALL DISPLAYS

LITESOUT        CS              S11CHAN                         
                EXTEND                                          
                WAND            DSALMOUT                        # TURN OFF COMPUTER ACTIVITY LIGHT.
                TC              TASKOVER                        # END OF DSKYCHK

ALRMSTRT        INDEX           PHASE2
                TC              +0
                TC              TCTRCONT                        # Phase 1: TC trap
                TC              NOTCCONT                        # Phase 2: No TC
                TC              RPLKCONT                        # Phase 3: Rupt lock
                TC              NORPCONT                        # Phase 4: No rupts
                TC              WTCHCONT                        # Phase 5: Night watchman
                TC              PARCONT                         # Phase 6: Parity fail

RSTRTCHK        EXTEND                                          # Entry point to the hardware alarm / restart checks
                WRITE           77                              # Clear channel 77 by writing to it

# Check the TC Trap alarm -- only TC executed for too long
TCTRPCHK        TC              PHASCHNG
                OCT             00102

                INHINT
                CAF             THREE                           # Schedule a task to break out of the loop if the
                TC              WAITLIST                        # alarm doesn't work.
                2CADR           TCTRPFAL

                RELINT
                CAF             ADRS1                           # Trigger a TC Trap. We do this in erasable  memory
                TS              SKEEP1                          # so we can break out of it if the restart
                TC              SKEEP1                          # doesn't occur as expected.

TCTRPFAL        CAF             TCTRPXIT                        # It's been too long with no restart. Break the
                TS              SKEEP1                          # loop at SKEEP1.
                TC              TASKOVER
TCTRPXIT        TC              TCTRCONT

NOTCFAIL        CA              S+ZERO                          # It's been too long with no restart. Zero SKEEP2
                TS              SKEEP2                          # so the CA..ADS loop exits.
                TC              TASKOVER

TESTRBIT        EXTEND                                          # Read the restart cause from channel 77
                RXOR            77
                MASK            CTRMASK                         # Filter out counter alarms, which can be caused by
                                                                # any other type of restart if a counter request
                                                                # was interrupted.
                TCF             +0CHK                           # Make sure only the correct bit was set.

RSTRTRST        CAF             BIT10                           # Turn off the RESTART light
                EXTEND
                WOR             DSALMOUT
                CS              BIT10
                EXTEND
                WAND            DSALMOUT
                EXTEND
                WRITE           77                              # Clear the restart cause from channel 77.
                TC              Q

TCTRCONT        TC              PHASCHNG                        # Turn off the restart group so we don't come back
                OCT             00002                           # here for an unexpected reason.

                CAF             TCTRPBIT                        # Check for the TC trap bit
                TC              TESTRBIT
                TC              RSTRTRST

# Check the TC Trap alarm -- no TC executed for too long
NOTCCHK         TC              PHASCHNG
                OCT             00202

                INHINT
                CAF             THREE                           # Set up a waitlist task to break us out of the
                TC              WAITLIST                        # CA-ADS loop if the alarm doesn't occur
                2CADR           NOTCFAIL

                RELINT
                CA              S-2
                TS              SKEEP2                          # Put -2 into SKEEP2.

# There's many ways to do an infinite loop without TC or TCF. However, most of them appear to get transients
# on the TC0 and TCF0 lines during instruction changeover in T12. Since neither pulse is gated to the alarm
# circuit, these transients make the circuit think the computer executed an actual TC or TCF.
# It is unclear if this is an error in the simulator or an actual design flaw.
# Anyways, a CA and ADS loop *doesn't* generate transients on those lines, and so the alarm works as expected.
                CA              SKEEP2                          # Add -2 to Z to loop in place.
                ADS             Z
NOTCCONT        TC              PHASCHNG                        # Turn off the restart group so we don't come back
                OCT             00002                           # here for an unexpected reason.

                CAF             TCTRPBIT
                TC              TESTRBIT
                TC              RSTRTRST

# Check Rupt Lock -- execution stuck in an interrupt for ~140ms
RPTLKCHK        TC              PHASCHNG
                OCT             00302

                CAF             300MSEC                         # Set up a 300ms BUSYLOOP
                TS              SKEEP3
                CAF             ZERO
                TS              SKEEP2                          # SKEEP2 = 0 indicates that BUSYLOOP is a task
                CAF             ONE                             # SKEEP1 will be used to indicate that our task has
                TS              SKEEP1                          # exited without triggering a restart.
                INHINT
                TC              WAITLIST                        # Execute a 300ms loop as a waitlist task (inside
                2CADR           BUSYLOOP                        # the TIME3 interrupt).

                RELINT
RPTWAIT         CS              NEWJOB                          # Play hardball... check in with the night watchman
                                                                # without actually seeing if there's a job to do.
                CCS             SKEEP1                          # We just need to stay alive until a reset or
                TCF             RPTWAIT                         # BUSYLOOP exits.

RPLKCONT        TC              PHASCHNG
                OCT             00002

                CAF             RPTLKBIT
                TC              TESTRBIT
                TC              RSTRTRST

# Check Rupt Lock -- no interrupts for ~140ms
NORPTCHK        TC              PHASCHNG
                OCT             00402

                CAF             ONE                             # Configure BUSYLOOP to just return here
                TS              SKEEP2
                INHINT                                          # Lock interrupts before heading in...
                TC              BUSYLOOP
                RELINT
                
NORPCONT        TC              PHASCHNG
                OCT             00002

                CAF             RPTLKBIT
                TC              TESTRBIT
                TC              RSTRTRST

# Check the Night Watchman -- program fails to check NEWJOB for ~640ms
WATCHCHK        TC              PHASCHNG
                OCT             00502

                CA              S+ZERO                          # Indicate to WTCHCONT that entry to it is permissible
                TS              SKEEP5                          # once

                CA              2SEC                            # Set up a 2 second BUSYLOOP
                TS              SKEEP3
                TC              BUSYLOOP                        # SKEEP2 still = 1

WTCHCONT        CA              SKEEP5                          # Ensure we only get one night wachman alarm.
                TC              +0CHK                           # If this fails, the below logic caused a
                CA              ONE                             # restart when it shouldn't have.
                TS              SKEEP5

                CAF             WATCHBIT                        # Check to make sure night watchman was triggered
                TC              TESTRBIT

                TC              RSTRTRST                        # Try to clear it
                CAF             WATCHBIT                        # Check that we didn't successfully clear it -- it
                TC              TESTRBIT                        # should be asserted for 1.28 seconds

                RELINT
                CA              0.64SEC                         # Wait for 0.64 seconds (which will get us into the
                TS              SKEEP3                          # next night watchman window). Since we just aggravated
                TC              BUSYLOOP                        # it, we shouldn't get any alarms doing this.

                TC              RSTRTRST
                CAF             WATCHBIT                        # Check again that resetting the ch77 bit fails
                TC              TESTRBIT

                CS              NEWJOB                          # Appease the night watchman for this new window, and
                TC              BUSYLOOP                        # wait a further 0.64 seconds until the end of of it

                TC              RSTRTRST
                CAF             S+ZERO                          # Make sure we can actually clear it this time
                TC              TESTRBIT

# Check the parity alarm. There's a couple ways this can happen -- for example, if a scaler or prime
# power failure generating a STRT2 signal were to happen in the middle of an erasable memory cycle,
# before the loaded data was written back out, that location would contain all 0s and therefore have
# incorrect parity.
# An easier guaranteed way, which we'll use here, is to try to access memory in a bank that doesn't
# exist. The superbank bit provides a convenient means of doing this; only superbanks 40-43 exist,
# so trying to hit anything in 44-47 should trigger a parity alarm.
PARFLCHK        TC              PHASCHNG
                OCT             00602

                CS              NEWJOB
                CAF             SUPER100                        # Simply try to load data from the start of bank 44.
                TS              L
                CAF             BNK34ADR
                TC              SUPDACAL

PARCONT         TC              PHASCHNG
                OCT             00002

                CAF             PRITYBIT
                TC              TESTRBIT
                TC              RSTRTRST

ALRMDONE        TC              TOSMODE                         # All done with the hardware alarm checks.

# BUSYLOOP provides a simple means of aggravating certain hardware alarms; it fails to check NEWJOB
# and makes use of a TCF. Its inputs are:
# SKEEP2 = Run context. If positive, subroutine mode is used and control is returned to Q.
#                       If +0, waitlist task mode is used and exit is through TASKOVER. SKEEP1 is set to 0 on exit.
# SKEEP3 = Loop duration in TIME1 counts (10ms).
BUSYLOOP        CS              TIME1                           # Store the start time in SKEEP4
                TS              SKEEP4
BUSYLOP1        CA              TIME1
                AD              SKEEP4                          # Current time - start time
                AD              HALF                            # Account for possible TIME1 overflow
                AD              HALF
                XCH             L                               # Pass the (likely) overflowed value through L
                CS              SKEEP3  
                AD              L                               # Calculate time delta minus expiration duration
                EXTEND
                BZF             +2
                TCF             BUSYLOP1                        # Use a TCF to make sure we don't trigger TC trap
                CCS             SKEEP2                          # All done. Check if we're returning or exiting a
                TC              Q                               # waitlist task.
                CAF             ZERO
                TS              SKEEP1                          # Reset SKEEP1 to let the main test know we're done
                TC              TASKOVER

ENDSLFS2        EQUALS                                          
