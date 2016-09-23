### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     AGC_BLOCK_TWO_SELF-CHECK.agc
# Purpose:      Part of the source code for Aurora (revision 12).
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      https://www.ibiblio.org/apollo.
# Pages:        377-403
# Mod history:  2016-09-20 JL   Created.
# Mod history:  2016-09-22 MAS  Began.

# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the private collection of 
# Don Eyles.  The digitization was performed by archive.org.

# Notations on the hardcopy document read, in part:

#       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
#       NOV 10, 1966

#       [Note that this is the date the hardcopy was made, not the
#       date of the program revision or the assembly.]

# The scan images (with suitable reduction in storage size and consequent 
# reduction in image quality) are available online at 
#       https://www.ibiblio.org/apollo.  
# The original high-quality digital images are available at archive.org:
#       https://archive.org/details/aurora00dapg

## Page 377
                BANK            20                              

SBIT1           EQUALS          BIT1                            
SBIT2           EQUALS          BIT2                            
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
S+1             EQUALS          BIT1                            
S+2             EQUALS          BIT2                            
S+3             EQUALS          THREE                           
S+4             EQUALS          FOUR                            
S+5             EQUALS          FIVE                            
S+6             EQUALS          SIX                             
S+7             EQUALS          SEVEN                           
S8BITS          EQUALS          LOW8                            # 00377
CNTRCON         OCTAL           00051                           # USED IN CNTRCHK
ERASCON1        OCTAL           00062                           # USED IN ERASCHK
ERASCON2        OCTAL           01374                           # USED IN ERASCHK
ERASCON6        OCTAL           01400                           # USED IN ERASCHK
ERASCON3        OCTAL           01462                           # USED IN ERASCHK
ERASCON4        OCTAL           01774                           # USED IN ERASCHK
S10BITS         EQUALS          LOW10                           # 01777, USED IN ERASCHK
SBNK03          EQUALS          PRIO6                           # 06000, USED IN ROPECHK
S13BITS         OCTAL           17777                           
CONC+S1         OCTAL           25252                           # USED IN CYCLSHFT
OVCON           OCTAL           37737                           # USED IN RUPTCHK
DVCON           OCTAL           37776
CONC+S2         OCTAL           52400                           # USED IN CYCLSHFT
ERASCON5        OCTAL           76777                           
S-7             OCTAL           77770                        
S-4             EQUALS          NEG4                            
S-3             EQUALS          NEG3                            
S-2             EQUALS          NEG2                            
S-1             EQUALS          NEGONE                          
S-ZERO          EQUALS          NEG0                            

                EBANK=          3                               
ADRS1           ADRES           SKEEP1                          

## Page 378
SRADRS          ADRES           SR
SELFADRS        ADRES           SELFCHK                         # SELFCHK RETURN ADDRESS.  SHOULD BE PUT
                                                                # IN SELFRET WHEN GOING FROM SELFCHK TO
                                                                # SHOWSUM AND PUT IN SKEEP1 WHEN GOING
                                                                # FROM SHOWSUM TO SELF-CHECK.

ERRORS          CA              Q                               
                TS              SFAIL                           # SAVE Q FOR FAILURE LOCATION
                INCR            ERCOUNT                         # KEEP TRACK OF NUMBER OF MALFUNCTIONS.
                TC              ALARM                           
                OCT             01102                           # SELF-CHECK MALFUNCTION INDICATOR
                CCS             SMODE                           
                CA              S+ZERO                          
                TS              SMODE                           
                TC              SELFCHK                         # GO TO IDLE LOOP
                TC              SFAIL                           # CONTINUE WITH SELF-CHECK

+0CHK           CS              A
-0CHK           CCS             A
                TCF             ERRORS
                TCF             ERRORS
                TCF             ERRORS
                TC              Q

+1CHK           CS              A
-1CHK           CCS             A                               
                TCF             ERRORS                        
                TCF             ERRORS                        
                CCS             A                               
                TCF             ERRORS                        
                TC              Q                               

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
## Page 379
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
## Page 380
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
## Page 381
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

## Page 382
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



























# SKEEP7 HOLDS LOWEST OF TWO ADDRESSES BEING CHECKED.
# SKEEP6 HOLDS B(X+1).
# SKEEP5 HOLDS B(X).
# SKEEP4 HOLDS C(EBANK) DURING ERASLOOP AND CHECKNJ
# SKEEP3 HOLDS LAST ADDRESS BEING CHECKED (HIGHEST ADDRESS).
# Page 1288
# SKEEP2 CONTROLS CHECKING OF NON-SWITCHABLE ERASABLE MEMORY WITH BANK NUMBERS IN EB.

# ERASCHK TAKES APPROXIMATELY 7 SECONDS.

ERASCHK         CA              S+1                             
                TS              SKEEP2                          
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
                CA              ERASCON4                        # 01773
                TS              SKEEP3                          # LAST ADDRESS CHECKED
                TC              ERASLOOP                        

NOEBANK         TS              SKEEP2                          # +0
                CA              ERASCON1                        # 00061
                TS              SKEEP7                          # STARTING ADDRESS
                CA              ERASCON2                        # 01373
                TS              SKEEP3                          # LAST ADDRESS CHECKED

ERASLOOP        INHINT                                          
                CA              EBANK                           # STORES C(EBANK)
                TS              SKEEP4                          
                EXTEND                                          
                NDX             SKEEP7                          
                DCA             0000                            
                DXCH            SKEEP5                          # STORES C(X) AND C(X+1) IN SKEEP6 AND 5.
                CA              SKEEP7                          
                TS              ERESTORE                        # IF RESTART, RESTORE C(X) AND C(X+1)
                TS              L                               
                INCR            L                               
                NDX             A                               
                DXCH            0000                            # PUTS OWN ADDRESS IN X AND X +1
                NDX             SKEEP7                          
                CS              0001                            # CS X+1
                NDX             SKEEP7                          
                AD              0000                            # AD X
                TC              -1CHK                           
                CA              ERESTORE                        # HAS ERASABLE BEEN RESTORED
                EXTEND                                          
# Page 1289
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
                TC              CHECKNJ                         # CHECK FOR NEW JOB
                CA              SKEEP4                          # REPLACES B(EBANK)
                TS              EBANK                           
                INCR            SKEEP7                          
                CS              SKEEP7                          
                AD              SKEEP3                          
                EXTEND                                          
                BZF             +2                              
                TC              ERASLOOP                        # GO TO NEXT ADDRESS IN SAME BANK
                CCS             SKEEP2                          
                TC              NOEBANK                         
                INCR            SKEEP2                          # PUT +1 IN SKEEP2.
                CA              EBANK                           
                AD              SBIT9                           
                TS              EBANK                           
                AD              ERASCON5                        # 76777, CHECK FOR BANK E2
                EXTEND                                          
                BZF             2EBANK                          
                CCS             EBANK                           
                TC              E134567B                        # GO TO EBANKS 1,3,4,5,6, AND 7
                CA              ERASCON6                        # END OF ERASCHK
                TS              EBANK                           

# CNTRCHK PERFORMS A CS OF ALL REGISTERS FROM OCT. 60 THROUGH OCT. 10.
# INCLUDED ARE ALL COUNTERS, T6-1, CYCLE AND SHIFT, AND ALL RUPT REGISTERS

CNTRCHK         CA              CNTRCON                         # 00050
CNTRLOOP        TS              SKEEP2                          
                AD              SBIT4                           # +10 OCTAL
                INDEX           A                               
                CS              0000                            
# Page 1290
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

# SKEEP1 HOLDS SUM
# SKEEP2 HOLDS PRESENT CONTENTS OF ADDRESS IN ROPECHK AND SHOWSUM ROUTINES
# SKEEP2 HOLDS BANK NUMBER IN LOW ORDER BITS DURING SHOWSUM DISPLAY
# SKEEP3 HOLDS PRESENT ADDRESS (00000 TO 01777 IN COMMON FIXED BANKS)
#                              (04000 TO 07777 IN FXFX BANKS)
# SKEEP3 HOLDS BUGGER WORD DURING SHOWSUM DISPLAY
# SKEEP4 HOLDS BANK NUMBER AND SUPER BANK NUMBER
# SKEEP5 COUNTS 2 SUCCESSIVE TC SELF WORDS
# SKEEP6 CONTROLS ROPECHK OR SHOWSUM OPTION
# SKEEP7 CONTROLS WHEN ROUTINE IS IN COMMON FIXED OR FIXED FIXED BANKS

ROPECHK         CA              S-ZERO                          # *
                TS              SKEEP6                          # * -0 FOR ROPECHK
STSHOSUM        CA              S+ZERO                          # * SHOULD BE ROPECHK

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
# Page 1291
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
                CA              SKEEP3                          
                MASK            LOW10                           # RELATIVE ADDRESS
                AD              -MAXADRS                        # SUBTRACT MAX RELATIVE ADDRESS = 1777.
                EXTEND                                          
                BZF             SOPTION                         # CHECKSUM FINISHED IF LAST ADDRESS.
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
# Page 1292
                TC              CONTINU         +1              # AD IN THE BUGGER WORD
CONTINU         CA              S+1                             # MAKE SURE TWO CONSECUTIVE TC SELF WORDS
                TS              SKEEP5                          
                CCS             SKEEP6                          # *
                CCS             NEWJOB                          # * +1, SHOWSUM
                TC              CHANG1                          # *
                TC              +2                              # *
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
                ADS             SKEEP4                          # ERC BIT OF TEH 37 TO 40 ADVANCE.
GONXTBNK        CCS             SKEEP7                          
                TC              COMMFX                          
                CA              S+1                             
                TC              FXFX                            
                CA              SBIT7                           # HAS TO BE LARGER THAN NO OF FXSW BANKS.
                TC              COMMFX                          

SOPTION         CA              SKEEP4                          
                MASK            HI5                             # = BANK BITS
                TC              LEFT5                           
                TS              L                               # BANK NUMBER BEFORE SUPER BANK
# Page 1293
                CA              SKEEP4                          
                MASK            S8BITS                          # = SUPER BANK BITS
                EXTEND                                          
                BZF             SOPT                            # BEFORE SUPER BANK
                TS              SR                              # SUPER BANK NECESSARY
                CA              L                               
                MASK            SEVEN                           
                AD              SR                              
                TS              L                               # BANK NUMBER WITH SUPER BANK
SOPT            CA              SKEEP6                          # *
                EXTEND                                          # *
                BZF             +2                              # * ON -0 CONTINUE WITH ROPE CHECK.
                TC              SDISPLAY                        # * ON +1 GO TO DISPLAY OF SUM.
                CCS             SKEEP1                          # FORCE SUM TO ABSOLUTE VALUE.
                TC              +2                              
                TC              +2                              
                AD              S+1                             
                TS              SKEEP1                          
BNKCHK          CS              L                               # = - BANK NUMBER
                AD              SKEEP1                          
                AD              S-1                             
                TC              -1CHK                           # CHECK SUM
                TC              NXTBNK                          

                EBANK=          NEWJOB                          
LSTBNKCH        BBCON*                                          # * CONSTANT, LAST BANK.

