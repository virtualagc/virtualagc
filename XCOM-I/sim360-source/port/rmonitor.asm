***********************************************************************         
*                                                                     *         
*                  STONY BROOK PASCAL 360 COMPILER                    *         
*                LOADER AND RUN-TIME SERVICE MONITOR                  *         
*                                                                     *         
***********************************************************************         
         SPACE 5                                                                
*                                                                               
*        COPYRIGHT (C) 1976                                                     
*        DEPARTMENT OF COMPUTER SCIENCE                                         
*        SUNY AT STONY BROOK                                                    
*                                                                               
         SPACE 5                                                                
         MACRO                                                                  
&NAME    POWERS                                                                 
         LCLA  &EXP                                                             
&EXP     SETA  0-78                                                             
&NAME    DS    0D                                                               
.CONST1  ANOP                                                                   
         DC    DE-(&EXP)'1.0'                                                   
         AGO   .NEXT                                                            
.CONST2  ANOP                                                                   
         DC    DE(&EXP)'1.0'                                                    
.NEXT    ANOP                                                                   
&EXP     SETA  &EXP+1                                                           
         AIF   (&EXP LT 0).CONST1                                               
         AIF   (&EXP LE 75).CONST2                                              
         MEND                                                                   
         SPACE 5                                                                
         MACRO                                                                  
&NAME    SRVRTNED                                                               
&NAME    CLI   TIMELEFT,0                                                       
         BE    TIMEOUT                                                          
         L     R15,PR15                                                         
         LM    R11,R8,ORGPSCLR(R15)                                             
         BR    R10                                                              
         MEND                                                                   
         SPACE 5                                                                
         MACRO                                                                  
&NAME    CHKFILE &KIND                                                          
.*                                                                              
.*       CALLS ERROR IF AN ATTEMPT IS MADE TO USE A NONSTANDARD FILE.           
.*                                                                              
.*       &KIND SHOULD BE EITHER INPUT OR OUTPUT                                 
.*                                                                              
&NAME    L     R1,PR14                                                          
         LA    R1,&KIND.@(0,R1)                                                 
         CR    R9,R1                                                            
         BH    FILEERR                                                          
         MEND                                                                   
         SPACE 5                                                                
         MACRO                                                                  
&LABEL   FPERROR &MESSAGE                                                       
&LABEL STM     R11,R12,ORGPSCLR(R15)   SAVE R11,R12 IN SAVE AREA                
         LM    R11,R12,ORGREGMN(R15)   LOAD OTHER MON BASE REGS                 
         BAL   LINKREG,ERROR                                                    
         DC    AL1(L'E&SYSNDX)                                                  
E&SYSNDX DC    C&MESSAGE                                                        
         MEND                                                                   
         SPACE 5                                                                
*        RETURN FROM STANDARD PROCEDURES SIN,COS,ARCTAN,LN,SQRT                 
         MACRO                                                                  
&LABEL   FPRETURN                                                               
&LABEL   CLI   TIMELEFT,0          CHECK IF TIMER RAN OUT DURING                
         BE    FPTIMOUT            MONITOR CALL. IF SO, GIVE ERROR.             
         LM    R13,R1,ORGPSCLR+8(R15)  OTHERWISE, RETURN TO USER.               
         BR    LINK                RETURN TO PASCAL CODE                        
         MEND                                                                   
         EJECT                                                                  
MONITOR  CSECT                                                                  
R0       EQU   0                                                                
R1       EQU   1                                                                
R2       EQU   2                                                                
R3       EQU   3                                                                
R4       EQU   4                                                                
R5       EQU   5                                                                
R6       EQU   6                                                                
R7       EQU   7                                                                
R8       EQU   8                                                                
R9       EQU   9                                                                
R10      EQU   10                                                               
R11      EQU   11                                                               
R12      EQU   12                                                               
R13      EQU   13                                                               
R14      EQU   14                                                               
R15      EQU   15                                                               
FPR      EQU   6                                                                
LINKREG  EQU   7                   SUBROUTINE LINKAGE REGISTER.                 
BASE1    EQU   13                  MONITOR BASE REGISTER.                       
BASE2    EQU   12                  MONITOR BASE REGISTER.                       
BASE3    EQU   11                  MONITOR BASE REGISTER.                       
ORGPSCLR EQU   208                 OFFSET OF PASCAL SAVE AREA IN ORG            
ORGREGMN EQU   272                 OFFSET OF MONITOR SAVE AREA IN ORG           
FREEDARL EQU   10000               AREA SIZE FOR I/O BUFFERS.                   
*        CODEMNL MUST BE A MULTIPLE OF 4                                        
CODEMNL  EQU   32768               MIN. REGION FOR POST-MORTEM PKG.             
         SPACE 5                                                                
         ENTRY RMONITOR                                                         
         DS    18F                 MONITOR SAVE AREA                            
         USING MONITOR,BASE1,BASE2,BASE3                                        
         EJECT                                                                  
*                                                                               
*        SERVICE CALLS BRANCH TABLE                                             
*                                                                               
         SPACE 5                                                                
         B     SIN                                                              
         B     COS                                                              
         B     ARCTAN                                                           
         B     EXP                                                              
         B     LN                                                               
         B     SQRT                                                             
         B     CASE6                                                            
         B     CASE7                                                            
         B     CASE8                                                            
         B     CASE9                                                            
         B     CASE10                                                           
         B     CASE11                                                           
         B     CASE12                                                           
         B     EOLN                                                             
         B     EOF                                                              
         B     NEW                                                              
         B     DISPOSE                                                          
         B     GET                                                              
         B     PUT                                                              
         B     RESET                                                            
         B     REWRITE                                                          
         B     READINT                                                          
         B     READREAL                                                         
         B     READCHAR                                                         
         B     WRITEINT                                                         
         B     WRITREAL                                                         
         B     WRITBOOL                                                         
         B     WRITCHAR                                                         
         B     WRITSTRG                                                         
         B     READLN                                                           
         B     WRITELN                                                          
         B     PAGE                                                             
         B     RANGEERR                                                         
         B     MEMOVERF                                                         
         B     RANGMASK                                                         
         B     CLOCK                                                            
         EJECT                                                                  
         DROP  BASE1,BASE2,BASE3                                                
         USING RMONITOR,R15        R15 POINTS TO RMONITOR                       
RMONITOR STM   R14,R12,12(R13)     SAVE REGISTERS                               
         S     R15,=A(RMONITOR-MONITOR) R15 POINTS TO MONITOR                   
         ST    R13,4(0,R15)                                                     
         ST    R15,8(0,R13)                                                     
         LR    BASE1,R15           BASE1 POINTS TO MONITOR                      
         LA    BASE2,4095(0,BASE1)                                              
         LA    BASE2,1(0,BASE2)    BASE2 POINTS TO MONITOR+4096                 
         LA    BASE3,4095(0,BASE2)                                              
         LA    BASE3,1(0,BASE3)    BASE3 POINTS TO MONITOR+8192                 
         DROP  R15                                                              
         USING MONITOR,BASE1,BASE2,BASE3                                        
         ST    R1,PARMPTR          SAVE ADDRESS OF PARAMETER LIST.              
         B     MONITOR1                                                         
         SPACE 3                                                                
         LTORG                                                                  
         SPACE 5                                                                
MONITOR1 DS    0H                                                               
*                                                                               
*        ALLOCATE ALL FREE STORAGE IN REGION                                    
*                                                                               
         GETMAIN VC,LA=GETVAR,A=FREEAREA                                        
         SPACE 5                                                                
*                                                                               
*        FREE AREA FOR ACCESS METHOD                                            
*                                                                               
         L     R1,FREEAREL         LENGTH OF ALLOCATED AREA                     
         L     R0,=A(FREEDARL)     AMOUNT OF CORE TO BE GIVEN BACK              
*                                  FOR I/O BUFFERS.                             
         SR    R1,R0               LENGTH OF PASCAL REGION                      
         ST    R1,FREEAREL         SAVE FOR FREEMAIN.                           
         A     R1,FREEAREA         ADDRESS OF AREA TO BE RETURNED.              
         ST    R1,CORETOP          SAVE FOR HEAP POINTER.                       
         FREEMAIN R,LV=(0),A=(1)                                                
         EJECT                                                                  
*                                                                               
*        ORG SEGMENT LOADING                                                    
*                                                                               
         OPEN  (ORGDS)             OPEN DATA SET                                
         MVC   ORGORGN,FREEAREA    FIX ORG SEGMENT ORIGIN POINTER               
         SPACE 5                                                                
*                                                                               
*        TREAT HEADER INFORMATION                                               
*                                                                               
         GET   ORGDS               READ HEADER RECORD                           
         SPACE 5                                                                
*        OBTAIN ORG LENGTH                                                      
         LA    R2,5(0,R1)                                                       
         BAL   LINKREG,CONVERT                                                  
         ST    R2,ORGSIZE          KEEP ORG SEGMENT LENGTH                      
         SPACE 5                                                                
*        OBTAIN TRANSFER VECTOR BASE RELATIVE TO ORG ORIGIN                     
         LA    R2,10(0,R1)                                                      
         BAL   LINKREG,CONVERT                                                  
         A     R2,ORGORGN          CALCULATE ABSOLUTE ADDRESS OF TV             
         ST    R2,ORGTV            KEEP TV ABSOLUTE ADDRESS                     
         SPACE 5                                                                
*        OBTAIN MAX NUMBER OF BYTES OF TEMPORARY STORAGE                        
         LA    R2,15(0,R1)         R2 POINTS TO THE VALUE IN CHARACTERS         
         BAL   LINKREG,CONVERT     CONVERT TO BINARY                            
         ST    R2,MAXTEMPS         KEEP MAX OF TEMPORARY STORAGE                
         SPACE 5                                                                
*        OBTAIN LENGTH OF GLOBAL ACTIVATION RECORD AREA                         
         LA    R2,35(0,R1)                                                      
         BAL   LINKREG,CONVERT                                                  
         ST    R2,GLBLSIZE         KEEP LENGTH OF GLBL AR                       
         EJECT                                                                  
*                                                                               
*        LOAD ORG SEGMENT                                                       
*                                                                               
         LA    R4,ORGDS            R4 POINTS TO ORGDS DCB                       
         L     R2,ORGORGN          POINTER TO ORG SEGMENT                       
         L     R3,ORGSIZE          R3<--- LENGTH OF ORG SEGMENT                 
         BAL   LINKREG,LOAD        LOAD ORG SEGMENT CODE                        
         CLOSE (ORGDS)             CLOSE DATA SET                               
         LA    R3,ORGDS            R3 POINTS TO DCB                             
         USING IHADCB,R3                                                        
         TM    DCBBUFCB+3,1        TEST IF BUFFERS FREED.                       
         BO    ORG10               IF FREED , DO BRANCH                         
         FREEPOOL (R3)             FREE BUFFERS                                 
         DROP R3                                                                
ORG10    DS    0H                                                               
         B     CODE                                                             
ORGSIZE  DS    F                   ORG SEGMENT SIZE                             
MAXTEMPS DS    F                   MAXIMUM LENGTH OF TEMPORARY STORAGE          
         EJECT                                                                  
*                                                                               
*        CODE SEGMENT LOADING                                                   
*                                                                               
CODE     OPEN  (CODEDS)            OPEN DATA SET                                
         LA    R4,CODEDS           R4 POINTS TO CODEDS DCB                      
         LA    R2,7(0,R2)          GET ON A DOUBLEWORD BOUNDARY                 
         SRL   R2,3                                                             
         SLL   R2,3                                                             
         ST    R2,CODEPNT          KEEP POINTER TO START OF CODE                
CODE2    GET   CODEDS              READ HEADER RECORD                           
         ST    R2,CODE1            KEEP POINTER IN MEMORY                       
         SPACE 5                                                                
*                                                                               
*        OBTAIN THE LENGTH OF THIS PROCEDURE'S CODE.                            
*                                                                               
         LA    R2,5(0,R1)                                                       
         BAL   LINKREG,CONVERT                                                  
         SPACE 5                                                                
*                                                                               
*        LOAD THE CODE OF THIS PROCEDURE                                        
*                                                                               
         LR    R3,R2                                                            
         L     R2,CODE1                                                         
         BAL   LINKREG,LOAD                                                     
         B     CODE2                                                            
         EJECT                                                                  
*                                                                               
*        INITIALIZE HEAP_PTR AND MAX_TOP                                        
*                                                                               
         SPACE 5                                                                
CODEEND  L     R3,CORETOP          LAST ADDR IN REGION + 1                      
         BCTR  R3,0                LAST ADDR IN REGION                          
         N     R3,=X'FFFFFFFC'     NEXT LOWER FULLWORD                          
         L     R4,ORGORGN          ADDRESS OF ORG SEGMENT                       
         ST    R3,HEAPPTR(R4)      STORE HEAP POINTER.                          
         S     R3,MAXTEMPS         (HEAP_PTR - MAX_TEMP_DISPL)                  
         N     R3,=X'FFFFFFFC'                 & "FFFFFFFC"                     
         ST    R3,MAXTOP(R4)       --->MAX_STACKTOP                             
         SPACE 5                                                                
*                                                                               
*        SET TRANSFER VECTOR                                                    
*                                                                               
         L     R4,ORGTV            R4<---TRANSFER VECTOR POINTER.               
         L     R5,CODEPNT          R5<---CODE SEGMENT POINTER.                  
CODE3    LR    R3,R5               RELOCATION FACTOR                            
         A     R3,0(0,R4)          RELOCATE TV ENTRY                            
         ST    R3,0(0,R4)          STORE IN TV                                  
         LA    R4,4(0,R4)          MOVE TO NEXT TV ENTRY                        
         CR    R4,R5               END OF TRANSFER VECTOR?                      
         BL    CODE3               NO, RELOCATE NEXT ENTRY.                     
         L     R4,ORGTV            R4 POINTS TO TRANSFER VECTOR                 
         MVC   PR12,0(R4)          SET MAIN PROCEDURE POINTER                   
         CLOSE (CODEDS)            CLOSE DATA SET                               
         LA    R3,CODEDS           R3 POINTS TO DCB                             
         USING IHADCB,R3                                                        
         TM    DCBBUFCB+3,1        TEST IF BUFFERS FREED.                       
         BO    CODE10              IF FREED , DO BRANCH                         
         FREEPOOL (R3)             FREE BUFFERS                                 
         DROP R3                                                                
CODE10   DS    0H                                                               
         B     GLBL                                                             
CODE1    DS    F                                                                
HEAPPTR  EQU   0                   DISPLACEMENT OF HEAP_PTR IN ORG SEG.         
MAXTOP   EQU   4                   DISPLACEMENT OF MAX_TOP IN ORG SEG.          
         EJECT                                                                  
*                                                                               
*        GLOBAL ACTIV. RECORD LOADING                                           
*                                                                               
GLBL     OPEN  (GLBLDS)            OPEN DATA SET                                
         AH    R2,=H'4'                                                         
         SRA   R2,2                                                             
         SLL   R2,2                R2 IS ON A        WORD BOUNDARY              
         LR    R3,R2               R2 POINTS TO END OF CODE                     
         S     R3,CODEPNT          R3 CONTAINS LENGTH OF CODE                   
         C     R3,=A(CODEMNL)      LENGTH OF CODE > MINIMUM?                    
         BNL   GLBL1               IF YES , DO BRANCH                           
         L     R2,CODEPNT                                                       
         A     R2,=A(CODEMNL)      R3 POINTS TO AREA OF GLBL ACTIV. REC         
GLBL1    ST    R2,PR14             R2 POINTS TO GLBL ACTIV. REC.AREA            
         ST    R2,PR11             INITIAL CURRENT AR POINTER                   
         LA    R4,GLBLDS            R4 POINTS TO GLBLDS DCB                     
         L     R3,GLBLSIZE         R2 CONTAINS GLBL AR SIZE                     
         BAL   LINKREG,LOAD                                                     
         CLOSE (GLBLDS)            CLOSE DATA SET                               
         LA    R3,GLBLDS           R3 POINTS TO DCB                             
         USING IHADCB,R3                                                        
         TM    DCBBUFCB+3,1        TEST IF BUFFERS FREED.                       
         BO    GLBL10              IF FREED , DO BRANCH                         
         FREEPOOL (R3)             FREE BUFFERS                                 
         DROP  R3                                                               
GLBL10   DS    0H                                                               
         EJECT                                                                  
*        SET TIMER FOR PASCAL CODE EXECUTION                                    
         SPACE 5                                                                
TIMER    L     R4,PARMPTR          ADDRESS OF PARAMETER LIST.                   
         USING PARMS,R4                                                         
         L     R3,LINKSAVE         ADDRESS OF MONITOR_LINK.                     
         L     R3,0(0,R3)          R3 CONTAINS TIME LIMIT IN SECONDS            
         C     R3,MAXTIME          MUST BE <= 24 HOURS                          
         BNH   SETTIMER                                                         
         L     R3,MAXTIME                                                       
SETTIMER MH    R3,=H'100'          R3 CONTAINS TIME LIMII IN                    
*                                  HUNDREDTHS OF SECONDS                        
         ST    R3,TIMELT           KEEP THE TIME LIMIT                          
         TTIMER CANCEL                                                          
         STIMER TASK,TIMETRAP,BINTVL=TIMELT                                     
         L     R1,16               CVT ADDR FROM ABSOLUTE LOCATION 16           
         L     R1,0(0,R1)          TCB ADDRESS POINTER FROM CVT                 
         L     R1,4(0,R1)          ADDR OF CURRENT TCB                          
         L     R1,120(0,R1)        TQE ADDR FROM TCB                            
         LA    R1,28(0,R1)         ADDRESS OF RB LINK IN TQE                    
         ST    R1,RBLINK           PLANT FOR TIMER INTERRUPT                    
         MVI   TIMELEFT,X'FF'      INDICATE CPU CLOCK STILL TICKING             
         SPACE 5                                                                
*        SET LINEST VALUE                                                       
         L     R3,LINKSAVE         ADDRESS OF MONITOR_LINK.                     
         L     R3,4(0,R3)          R3 CONTAINS LINE NUMBER LIMIT                
         ST    R3,LINEST           KEEP LINE ESTIMATE AT LINEST                 
         SPACE 5                                                                
*        TRAP PROGRAM INTERRUPTS.                                               
         SPIE  PGMCHK,((1,9),11,12,15)                                          
         ST    1,PICAADDR          ADDRESS OF OLD PICA                          
         SPACE 5                                                                
*        ESTABLISH REGISTER STORAGE CONVENTION                                  
         L     R15,PR15            R15 POINTS TO ORG SEGMENT                    
         L     R1,INPUT0           ADDRESS OF DCB FOR THE INPUT FILE.           
         USING IHADCB,R1                                                        
         NC    DCBDDNAM,DCBDDNAM   WAS EOF(INPUT) ENCOUNTERED?                  
         BZ    S1                  YES, SO BRANCH.                              
         LA    R2,=A(INPUTED)      ADDR OF OUR EODAD ROUTINE                    
         MVC   DCBEODAD+1(3),1(R2) SET EODAD FIELD IN INPUT DCB.                
         DROP  R1,R4                                                            
         BAL   LINKREG,NEXTCH      INITIALIZE INPUT                             
         B     S2                                                               
S1       MVI   ENDFILE,X'FF'       INDICATE EOF(INPUT)                          
S2       STM   BASE3,BASE1,ORGREGMN(R15) KEEP MONITOR BASE REGS IN ORG.         
         SPACE 5                                                                
*        LINK TO PASCAL CODE                                                    
         SPACE 5                                                                
         L     R10,PR11                                                         
         STM   BASE3,BASE1,8(R10)  SAVE MONITOR BASE REGISTER BASE              
*                                  IN GLOBAL BLOCK MARK                         
         LM    R11,R15,PR11        LOAD PREASSIGNED REGISTERS                   
         BALR  R10,12              START EXECUTION OF PASCAL CODE               
         SPACE 5                                                                
*        NORMAL RETURN FROM PASCAL CODE                                         
         CLI   TIMELEFT,0          TIMER ABORT?                                 
         BNE   ENDMNTR             NO, SO RETURN.                               
         LA    LINKREG,TIMEERR     YES, CALL ERROR.                             
         L     R10,ERRLINE                                                      
         B     ERROR                                                            
ENDMNTR  L     R1,PICAADDR         ADDRESS OF OLD PICA.                         
         SPIE  MF=(E,(1))          RESTORE OLD PICA                             
*                                                                               
*        CANCEL THE CPU TIMER, CALCULATE EXECUTION TIME.                        
*                                                                               
         TTIMER CANCEL                                                          
*                                                                               
*        R0 CONTAINS TIME REMAINING (IN UNITS OF 26.04166 USEC).                
*                                                                               
         SRDL  R0,32               CONVERT TO UNITS OF 0.01 SECONDS.            
         LA    R2,384              (CONVERSION FACTOR)                          
         DR    R0,R2                                                            
         L     R2,TIMELT           ORIGINAL TIMER LIMIT                         
         SR    R2,R1               ELAPSED CPU TIME.                            
         ST    R2,EXECTIME                                                      
         CLI   OUTLINEP,X'00'      IS LENGTH(OUTLINE) > 0?                      
         BE    *+8                 NO, SO BRANCH.                               
         BAL   LINKREG,PUTLN       YES, SO WRITE LAST LINE OF OUTPUT.           
         SPACE 1                                                                
         LA    R1,PR14             ADDRESS OF STATUS BLOCK, WHICH               
*                                  BEGINS AT LOCATION PR14.                     
         L     R2,PARMPTR          ADDRESS OF PARAMETER LIST                    
         USING PARMS,R2                                                         
         L     R2,LINKSAVE         ADDRESS OF MONITOR_LINK.                     
         DROP  R2                                                               
         L     R2,4*3(0,R2)        SAVE STATUS BLOCK IN AREA WHOSE              
*                                  ADDRESS IS IN MONITOR_LINK(3).               
         MVC   0(4*7,R2),0(R1)                                                  
         SPACE 1                                                                
         L     R13,4(0,R13)        R13 POINTS TO OV MONITOR SAVE AREA           
         LM    R14,12,12(R13)      RESTORE OV MONITOR REGISTERS                 
         BR    R14                 BACK TO OV MONITOR                           
         EJECT                                                                  
*                                                                               
*        TIMER COMPLETION ASYNCHRONOUS EXIT ROUTINE                             
*                                                                               
         SPACE 5                                                                
TIMETRAP DS    0H                  SYSTEM ENTERS HERE.                          
         DROP  BASE1,BASE2,BASE3                                                
         USING TIMETRAP,R15                                                     
         SAVE  (14,12)             SAVE REGISTERS.                              
         L     R3,RBLINK           ADDR OF RB LINK                              
         L     R3,0(0,R3)          ADDR OF PRB                                  
         L     R3,20(0,R3)         WORD2 OF OLD PSW                             
         LA    R3,0(0,R3)          CLEAR THE HIGH ORDER BYTE.                   
         MVI   TIMELEFT,0          INDICATE NO TIME LEFT.                       
         C     R3,CODEPNT          WAS INTERRUPT IN PASCAL CODE?                
         BL    TIMER1              NO, FINISH MONITOR ROUTINE                   
         C     R3,PR14                THEN GO TO TIMEOUT.                       
         BH    TIMER1                                                           
*                                                                               
*        INTERRUPT OCCURRED IN PASCAL CODE                                      
*                                                                               
         MVC   0(10,3),HALTBYTS    MOVE HALT INSTR. TO PASCAL CODE              
         ST    R3,ERRLINE                                                       
TIMER1   RETURN (14,12),T,RC=0     RETURN TO O.S.                               
         DROP  R15                                                              
         USING MONITOR,BASE1,BASE2,BASE3                                        
         SPACE 5                                                                
HALTBYTS STM   R11,R12,ORGPSCLR(R15)                                            
         LM    R10,R13,4(R14)                                                   
         BR    R10                                                              
         SPACE 3                                                                
TIMELEFT DS    XL1                                                              
RBLINK   DS    F                                                                
MAXTIME  DC    F'86400'            SECONDS / DAY                                
TIMELT   DS    F                   EXECUTION TIME LIMIT                         
         SPACE 3                                                                
TIMEOUT  BAL   LINKREG,ERROR                                                    
TIMEERR  DC    AL1(L'TIMEERRM)                                                  
TIMEERRM DC    C'ESTIMATED TIME EXCEEDED'                                       
         EJECT                                                                  
         PRINT NOGEN                                                            
*                                                                               
*        ORG SEGMENT DATA SET DEFINITION                                        
*                                                                               
ORGDS    DCB   DDNAME=SYSUT2,                                          X        
               DSORG=PS,                                               X        
               MACRF=GL                                                         
         SPACE 5                                                                
*                                                                               
*        CODE DATA SET DEFINITION                                               
*                                                                               
CODEDS   DCB   DDNAME=SYSUT1,                                          X        
               DSORG=PS,                                               X        
               MACRF=GL,                                               X        
               EODAD=CODEEND                                                    
         SPACE 5                                                                
*                                                                               
*        GLOBAL ACTIV. REC. DATA SET DEFINITION                                 
*                                                                               
GLBLDS   DCB   DDNAME=SYSUT3,                                          X        
               DSORG=PS,                                               X        
               MACRF=GL                                                         
         SPACE 5                                                                
         PRINT GEN                                                              
*                                                                               
*        PROTOCOL POINTERS                                                      
*                                                                               
PR11     DS    A                   POINTER TO CURRENT AR BASE                   
PR12     DS    A                   POINTER TO CODE BASE                         
PR13     DS    A                   POINTER TO STACK TOP                         
PR14     DS    A                   POINTER TO GLBL AR AREA                      
PR15     DS    A                   POINTER TO ORG                               
         SPACE 5                                                                
*                                                                               
*LOADER GLOBAL VARIABLES                                                        
*                                                                               
ORGORGN  EQU   PR15                                                             
ORGTV    DS    A                   ADDRESS OF TRANSFER VECTOR                   
CODEPNT  DS    A                   ADDRESS OF CODE SEGMENT                      
EXECTIME DS    F                   EXECUTION TIME OF PASCAL PROGRAM             
ERRLINE  DC    F'0'                SOURCE LINE OF RUN ERROR                     
CORETOP  DS    A                   INITIAL HEAP POINTER.                        
FREEAREA DS    A                   POINTER TO UNUSED AREA IN REGION             
FREEAREL DS    F                   LENGTH OF THE FREE AREA IN REGION            
GLBLSIZE DS    F                   SIZE OF GLBL AR AREA                         
GETVAR   DC    A(CODEMNL+FREEDARL+4096)                                         
         DC    A(1000000)                                                       
PARMPTR  DS    A                   ADDRESS OF PARAMETER LIST PASSED BY          
*                                  OVERLAY MONITOR, WHOSE FORMAT IS             
*                                  DEFINED BY THE DSECT "PARMS".                
         EJECT                                                                  
*                                                                               
*        CONVERT ROUTINE                                                        
*                                                                               
*        PURPOSE: TO CONVERT HEADER INFORMATION INTO BINARY FORM                
*                                                                               
*        INPUT: R2 POINTS TO INFORMATION                                        
*                                                                               
*        OUTPUT: R2 CONTAINS THE VALUE                                          
*                                                                               
CONVERT  DS    0H                                                               
         ST    R2,CONR2            KEEP POINTER                                 
CON2     CLI   0(R2),C' '          BLANK CHARACTER ?                            
         BNE   CON1                IF NOT , DO BRANCH                           
         MVI   0(R2),X'F0'         IF YES,FILL IN DECIMAL 0                     
         LA    R2,1(0,R2)          INCREMENT POINTER                            
         B     CON2                ITERATE                                      
CON1     L     R2,CONR2            RESTORE ORIGINAL POINTER                     
         MVC   COND1,=8X'00'       CLEAR COND1 WITH ZEROES                      
         PACK  COND1+5(3),0(5,R2)  PACK HEADER INFORMATION                      
         CVB   R2,COND1            CONVERT HEADER INFORMATION INTO BIN.         
         BR    LINKREG             RETURN TO CALLER                             
COND1    DS     D                  AUXILIARY                                    
CONR2    DS    F                TO KEEP ORIGINAL POINTER TO INPUT DATA          
         EJECT                                                                  
*                                                                               
*        LOAD ROUTINE                                                           
*                                                                               
*        PURPOSE: TO READ A MODULE OF CODE                                      
*                                                                               
*        INPUT: R2 POINTS TO BASE OF AREA TO BE LOADED                          
*               R3 CONTAINS LENGTH OF CODE                                      
*               R4 POINTS TO DCB OF OBJECT CODE DATASET                         
*                                                                               
*        OUTPUT: R2 POINTS TO BASE OF NEXT AREA TO BE LOADED                    
*                                                                               
LOAD     DS    0H                                                               
LOA2     GET   (R4)                OBTAIN CARD IMAGE                            
         SH    R3,=H'80'           R3<---R3-80                                  
         BNH   LOA1                IF END OF CODE, BRANCH.                      
         MVC   0(80,R2),0(R1)      MOVE CODE FROM BUFFER                        
         LA    R2,80(0,R2)         INCREMENT POINTER                            
         B     LOA2                ITERATE                                      
LOA1     LA    R3,79(0,R3)         LENGTH OF CODE - 1.                          
         EX    R3,LOADMVC          MOVE RESIDUAL BYTES OF CODE.                 
         LA    R2,1(R2,R3)         R2 POINTS TO END OF CODE.                    
         BR    LINKREG             RETURN TO CALLER                             
         SPACE 3                                                                
LOADMVC  MVC   0(1,R2),0(R1)       MOVE RESIDUAL BYTES OF CODE.                 
         EJECT                                                                  
OUTPUT@  EQU   31                  OFFSET +31 IN GLBL AR AREA                   
INPUT@   EQU   29                  OFFSET +29 IN GLBL AR AREA                   
         SPACE 5                                                                
*                                                                               
*        ROUTINE NEXTCH                                                         
*                                                                               
*        PURPOSE :  GET NEXT CHARACTER FROM INPUT STREAM AND                    
*                   PUT IT INTO INPUT@                                          
         SPACE 5                                                                
NEXTCH   STM   R14,R1,NEXTCHR0     KEEP REGISTERS                               
         STM   R1,R2,NEXTCHR1      KEEP REGISTERS                               
         ST    LINKREG,NEXTCHR2    KEEP REGISTER                                
         CLI   ENDFILE,X'FF'       TEST END OF FILE CONDITION                   
         BNE   NEXTCH1             IF NOT,DO BRANCH                             
         BAL   LINKREG,ERROR       EOF ERROR MESSAGE                            
         DC    AL1(L'NEXTCHM)      ERROR MESSAGE PREFIX                         
NEXTCHM  DC    C'ATTEMPT TO READ PAST END OF FILE'                              
NEXTCH2  BAL   LINKREG,NEXTGET     GET NEXT RECORD                              
         CLI   ENDFILE,X'FF'       END OF FILE ENCOUNTERED ?                    
         BE    NEXTCHFN            IF YES,DO BRANCH                             
         MVC   INPTR,=H'0'         ZERO CURRENT CHARACTER POINTER               
         ST    R1,INLINE           KEEP POINTER TO INPUT RECORD                 
         B     NEXTCH3             PROCEED                                      
NEXTCH4  LH    R2,=H'80'             INPTR<---80 (SIGNALS EOLN)                 
         STH   R2,INPTR                                                         
         L     R2,PR14             INPUT@<---BLANK                              
         MVI   INPUT@(R2),C' '                                                  
         B     NEXTCHFN                                                         
NEXTCH1  CLC   INPTR,=H'79'        END OF LINE INDICATED?                       
         BH    NEXTCH2             YES, GET NEXT RECORD.                        
         BE    NEXTCH4             NO, SIGNAL EOLN.                             
         LH    R1,INPTR            R1<---INPTR                                  
         LA    R1,1(0,R1)          R1<---R1+1                                   
         STH   R1,INPTR            INPTR<---R1                                  
         A     R1,INLINE           R1 POINTS TO CURRENT INPUT CHARACTER         
NEXTCH3  L     R2,PR14             R2 POINTS TO GLOBAL AR AREA                  
         MVC   INPUT@(1,R2),0(R1)  SET INPUT@ VARIABLE                          
NEXTCHFN LM    R14,R1,NEXTCHR0     RESTORE REGISTER                             
         LM    R1,R2,NEXTCHR1      RESTORE REGISTER                             
         L     LINKREG,NEXTCHR2    RESTORE REGISTER                             
         BR    LINKREG             RETURN TO CALLER                             
         EJECT                                                                  
*                                                                               
*        ROUTINE NEXTGET                                                        
*                                                                               
NEXTGET  L     R1,PARMPTR          ADDRESS OF PARAMETER LIST.                   
         USING PARMS,R1                                                         
         L     R1,INPUT0           ADDRESS OFDCB FOR THE INPUT FILE.            
         DROP  R1                                                               
         GET   (1)                 READ A RECORD                                
         BR    LINKREG             RETURN TO CALLER                             
         SPACE 5                                                                
*        FOLLOWING LOCATION ENTERED AT EODAD OF INPUT FILE                      
INPUTED  MVI   ENDFILE,X'FF'       SET EODAD FLAG TO ON                         
         L     R2,PR14             R2 POINTS TO GLOBAL A. R. AREA               
         MVI   INPUT@(R2),C' '     SET INPUT@ VARIABLE                          
         BR    LINKREG             RETURN TO CALLER OF NEXTGET                  
INPTR    DC    H'80'               POINTER TO CURRENT INPUT CHARACTER           
INLINE   DS    A                   POINTER TO CURRENT INPUT RECORD              
ENDFILE  DC    X'00'               END OF FILE FLAG.X'FF' INDICATES ON          
NEXTCHR0 DS    4F                  REGISTERS SAVE AREA                          
NEXTCHR1 DS    2F                  REGISTERS SAVE AREA                          
NEXTCHR2 DS    F                   REGISTERS SAVE AREA                          
         EJECT                                                                  
*                                                                               
*        CONCATENATION ROUTINE                                                  
*                                                                               
*        INPUT:  DESCRIPTOR FOR STRING S1, IN R1;                               
*                DESCRIPTOR FOR STRING S2, IN R2.                               
*                                                                               
*        OUTPUT: DESCRIPTOR FOR STRING S1 || S2, IN R1.                         
*                                                                               
         SPACE 5                                                                
CATENATE DS    0H                                                               
         STM   R2,R6,CATSAVE       SAVE REGISTERS.                              
         LA    R6,STRING#-1        SIZE OF LARGEST STRING - 1.                  
         LR    R4,R1               R4<---DESCRIPTOR FOR S1                      
         SRDL  R4,24               R4<---LENGTH(S1) - 1                         
         SRL   R5,8                R5<---ADDR(1ST BYTE OF S1)                   
         SR    R6,R4               R6<---MAX # CHARS TO BE MOVED                
         BNP   CATRETN             IF LENGTH(S1) >= STRING#, RETURN S1.         
         LA    R5,0(R4,R5)         ADDR(LAST BYTE OF S1).                       
         SRDL  R2,24               R2<---LENGTH(S2) - 1.                        
         SRL   R3,8                R3<---ADDR(1ST BYTE OF S2)                   
         BCTR  R6,0                R6<---(MAX# CHARS TO BE MOVED) - 1           
         CR    R2,R6               S2 TOO LONG?                                 
         BNH   CAT1                NO, SO BRANCH.                               
         LR    R2,R6               YES, SO ONLY MOVE SOME OF S2.                
CAT1     EX    R2,CATMOVE          PERFORM CONCATENATION.                       
         LA    R2,1(R2,R4)         R2<---LENGTH(S1 || S2) - 1                   
         SLL   R2,24               SHIFT TO HIGH ORDER BYTE.                    
         LA    R1,0(0,R1)          CLEAR THE HIGH ORDER BYTE.                   
         OR    R1,R2               R1<---DESCRIPTOR FOR S1 || S2.               
CATRETN  LM    R2,R6,CATSAVE       RESTORE REGISTERS                            
         BR    LINKREG             RETURN                                       
         SPACE 3                                                                
CATMOVE  MVC   1(0,R5),0(R3)       CONCATENATION MOVE                           
CATSAVE  DS    5F                  REGISTER SAVE AREA.                          
STRING#  EQU   133                 SIZE OF LARGEST STRING.                      
         EJECT                                                                  
*                                                                               
*        INTEGER - TO - STRING   CONVERSION                                     
*                                                                               
*        INPUT:  INTEGER NUMBER IN R1.                                          
*                                                                               
*        OUTPUT: XPL-TYPE STRING DESCRIPTOR IN R1.                              
*                                                                               
         SPACE 5                                                                
INT2STR  DS    0H                  INTEGER TO STRING                            
         ST    R2,I2SSAVE          SAVE R2.                                     
         CVD   R1,I2SDEC           CONVERT INTEGER TO PACKED DECIMAL.           
         MVC   I2SEDIT,I2SPATRN    PREPARE WORK AREA FOR EDMK INSTR.            
*                                                                               
*        LARGEST INTEGER VALUE HAS 10 DECIMAL DIGITS.                           
*                                                                               
         LA    R1,I2SEDIT+11       ADDR OF SIGNIFICANCE STARTER + 1             
         EDMK  I2SEDIT,I2SDEC+2    EDIT + MARK                                  
         BNM   I2S1                BRANCH IF NONNEGATIVE                        
         BCTR  R1,0                SIGN POSITION                                
         MVI   0(1),C'-'           INSERT A MINUS SIGN                          
*                                                                               
*        FORM AN XPL-LIKE STRING DESCRIPTOR:                                    
*        BYTE 0: LENGTH(STRING) - 1                                             
*        BYTES 1..3: ADDRESS OF 1ST CHARACTER                                   
*                                                                               
I2S1     LA    R2,I2SEDIT+11       ADDR OF LAST CHARACTER                       
         SR    R2,R1               MINUS ADDR OF 1ST CHARACTER                  
         SLL   R2,24               SHIFT TO HIGH ORDER BYTE                     
         LA    R1,0(0,R1)          CLEAR THE HIGH ORDER BYTE                    
         OR    R1,R2               FORM DESCRIPTOR                              
         L     R2,I2SSAVE          RESTORE R2                                   
         BR    LINKREG             RETURN TO CALLER.                            
         SPACE 5                                                                
I2SPATRN DC    X'40',9X'20',X'21',X'20' EDMK PATTERN                            
I2SEDIT  DS    CL12                WORK AREA FOR EDMK                           
I2SSAVE  DS    F                   SAVE AREA FOR R2                             
I2SDEC   DS    D                   WORK AREA FOR CVD                            
         EJECT                                                                  
*                                                                               
*        PROCEDURE I_FORMAT                                                     
*                                                                               
*        PURPOSE: TO FORMAT A BINARY INTEGER FOR PRINTING                       
*                                                                               
*        INPUT:  BINARY INTEGER TO BE PRINTED, IN R1;                           
*                MINIMUM FIELD WIDTH IN R2.  IF FEWER CHARACTERS THAN           
*                THE MINIMUM ARE NEEDED, THE NUMBER IS RIGHT-JUSTIFIED          
*                (WITH LEADING BLANKS) IN A MINIMUM WIDTH FIELD.                
*                                                                               
*        OUTPUT: XPL-TYPE STRING DESCRIPTOR IN R1.                              
*                                                                               
         SPACE 5                                                                
IFORMAT  DS    0H                                                               
         STM   R2,LINKREG,IFORSAVE SAVE REGISTERS.                              
         BAL   LINKREG,INT2STR     CONVERT NUMBER TO STRING.                    
         LR    R4,R1               R4<---STRING DESCRIPTOR                      
         SRDL  R4,24               R4<---LENGTH(STRING) - 1                     
         BCTR  R2,0                R2<--MINIMUM WIDTH - 1                       
         CR    R2,R4               ARE LEADING BLANKS NEEDED?                   
         BNH   IFORMAT1            NO, RETURN DESCRIPTOR                        
         SR    R2,R4               YES, R2 = # LEADING BLANKS                   
         LA    R1,ISTRING          ADDR OF OUTPUT STRING                        
         SRL   R5,8                ADDR OF DIGITS.                              
         EX    R2,IMOVE1           INSERT BLANKS                                
         LA    R3,0(R1,R2)         ADDR OF 1ST NONBLANK                         
         EX    R4,IMOVE2           INSERT DIGITS                                
         AR    R2,R4               R2 = MINIMUM WIDTH - 1                       
         SLL   R2,24               SHIFT TO HIGH ORDER BYTE                     
         OR    R1,R2               FORM DESCRIPTOR                              
IFORMAT1 LM    R2,LINKREG,IFORSAVE RESTORE REGISTERS                            
         BR    LINKREG             RETURN TO CALLER                             
         SPACE 3                                                                
IMOVE1   MVC   0(0,1),SPACES       MOVE SPADES TO ISTRING                       
IMOVE2   MVC   0(0,3),0(5)         MOVE DIGITS TO ISTRING                       
ISTRING  DS    CL133               STRING SPACE USED BY I_FORMAT.               
SPACES   DC    CL133' '                                                         
IFORSAVE DS    6F                                                               
         EJECT                                                                  
*                                                                               
*        PROCEDURE B_FORMAT                                                     
*                                                                               
*        PURPOSE: TO FORMAT A BOOLEAN VALUE FOR OUTPUT                          
*                                                                               
*        INPUT:  BOOLEAN VALUE TO BE PRINTED, IN R1;                            
*                FIELD WIDTH IN R2.                                             
*                                                                               
*        OUTPUT: XPL-TYPE STRING DESCRIPTOR, IN R1.                             
*                                                                               
         SPACE 5                                                                
BFORMAT  DS    0H                                                               
         STM   R2,LINKREG,BFORSAVE /* SAVE REGISTERS */                         
         LTR   R1,R1               IF BOOL_VALUE THEN                           
         BZ    BFOR1                  STRING = 'TRUE';                          
         L     R1,TRUESTR                                                       
         B     BFOR2               ELSE                                         
BFOR1    L     R1,FALSESTR            STRING = 'FALSE';                         
BFOR2    LR    R3,R1               IF LENGTH(STRING) > WIDTH THEN               
         SRL   R3,24                                                            
         LA    R3,1(0,R3)             /* R3<---LENGTH(STRING) */                
         CR    R2,R3                  /* R2<---WIDTH */                         
         BNL   BFOR3                                                            
         LA    R1,0(0,R1)             STRING = SUBSTR(STRING, 0, 1);            
         LA    R3,1                                                             
BFOR3    CR    R2,R3               IF LENGTH(STRING) < WIDTH THEN               
         BNH   BFOR4                                                            
         MVC   ISTRING,SPACES         STRING =                                  
         LA    R4,ISTRING                SUBSTR(SPACES, 0,                      
         SR    R2,R3                           WIDTH-LENGTH(STRING))            
         BCTR  R2,0                      || STRING;                             
         SLL   R2,24                                                            
         OR    R4,R2                                                            
         LR    R2,R1                                                            
         LR    R1,R4                                                            
         BAL   LINKREG,CATENATE                                                 
BFOR4    LM    R2,LINKREG,BFORSAVE RETURN STRING;                               
         BR    LINKREG                                                          
         SPACE 1                                                                
BFORSAVE DS    6F                  /* SAVE AREA FOR REGISTERS */                
         SPACE 3                                                                
*                                                                               
*        TRUESTR IS AN XPL-TYPE DESCRIPTOR FOR THE STRING 'TRUE',               
*        FALSESTR IS A DESCRIPTOR FOR 'FALSE'                                   
*                                                                               
TRUESTR  DC    AL1(L'TRUECHRS-1),AL3(TRUECHRS)                                  
FALSESTR DC    AL1(L'FLSCHRS-1),AL3(FLSCHRS)                                    
TRUECHRS DC    C'TRUE'                                                          
FLSCHRS  DC    C'FALSE'                                                         
         EJECT                                                                  
*                                                                               
*        PROCEDURE PUTLN                                                        
*                                                                               
*        PURPOSE: WRITE A LINE AND UPDATE LINEST                                
*                                                                               
         SPACE 5                                                                
PUTLN    DS    0H                                                               
         STM   R14,R1,PUTLSAVE     SAVE REGISTERS                               
         L     R1,LINEST           R1<---LINEST                                 
         LTR   R1,R1               LINE ESTIMATE EXCEEDED?                      
         BH    PUTLN1              NO, SO BRANCH.                               
         BAL   LINKREG,ERROR       YES, PRINT ERROR MESSAGE.                    
         DC    AL1(L'PUTLNM)                                                    
PUTLNM   DC    C'ESTIMATED LINES EXCEEDED'                                      
PUTLN1   BCTR  R1,0                LINEST = LINEST - 1                          
         ST    R1,LINEST                                                        
         L     R1,PARMPTR          ADDRESS OF PARAMETER LIST.                   
         USING PARMS,R1                                                         
         L     R1,OUTPUT0          ADDRESS OF DCB FOR THE OUTPUT FILE.          
         DROP  R1                                                               
*                                                                               
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT OUTPUT BUFFER IS            
*        RETURNED IN R1.                                                        
*                                                                               
         PUT   (1)                                                              
         MVC   0(133,R1),OUTLINE   MOVE LINE TO BUFFER                          
         MVC   OUTLINE,SPACES      MOVE SPACES TO LINE                          
         LA    R1,OUTLINE          RE-INITIALIZE OUTLINE DESCRIPTOR             
         ST    R1,OUTLINEP                                                      
         LM    R14,R1,PUTLSAVE     RESTORE REGISTERS                            
         BR    LINKREG             RETURN                                       
         SPACE 1                                                                
PUTLSAVE DS    4F                                                               
         TITLE 'STANDARD FUNCTIONS OF ANALYSIS'                                 
*        SIN, COS, ARCTAN, EXP, SQRT, LN ADAPTED FROM THE SUNY AT               
*        STONY BROOK BASIC COMPILER ( COURTESY OF GARRY MEYER )                 
         SPACE 3                                                                
GR0      EQU   0                   GENERAL REGISTERS USED FOR SCRATCH           
GR1      EQU   1                                                                
GR2      EQU   14                                                               
LINK     EQU   10                  LINK TO PASCAL CODE                          
FR0      EQU   0                   FLOATING POINT REGISTERS                     
FR2      EQU   2                                                                
FR4      EQU   4                                                                
FR6      EQU   6                                                                
BUFF     DS    D                   BUFFER USED FOR TEMP STORAGE                 
         SPACE                                                                  
*                                                                               
*        LINKAGE TO PASCAL CODE:                                                
*                                                                               
*          ALL SAVING OF REGISTERS IS DONE IN THE PASCAL CODE. GENERAL          
*          REGS 13..15,0,1 ARE THE ONLY GENERAL REGS SAVED, EXCEPT UPON         
*          ENTRY TO EXP, WHERE 2, 3 AND 4 ARE ALSO SAVED, SINCE EXP             
*          REQUIRES 7 SCRATCH REGS.                                             
*          REG 13 IS THE BASE REG FOR THE CODE & DATA, AND IS THE               
*          ONLY REG PRE-LOADED EXCEPT FOR FP6, THE ARGUMENT REG. R10 IS         
*          THE LINK TO THE PASCAL CODE, AND REGS 14,15,0,1 ARE USED FOR         
*          SCRATCH REGS. IF AN ERROR CONDITION OCCURS, THE REMAINING            
*          MONITOR BASE REGISTERS ARE LOADED BEFORE BRANCHING TO THE            
*          ERROR HANDLER.                                                       
       SPACE 5                                                                  
*        HANDLE TIMER RUNOUT DURING SIN..SQRT ROUTINES                          
*                                                                               
FPTIMOUT FPERROR 'ESTIMATED TIME EXCEEDED'                                      
       TITLE   'SINE-COSINE FUNCTIONS (SHORT)'                                  
*                                                                       00004270
*      CASES --- 0,1 SIN,COS (SHORT)                                            
*              1. DIVIDE MAGNITUDE OF ARG BY PI/4 TO FIND OCTANT        00004290
*                   AND FRACTION.                                       00004300
*              2. IF COSINE, CRANK OCTANT NUMBER BY 2.                  00004310
*              3. IF SINE, CRANK OCTANT NUMBER BY 0(4) FOR +ARG(-ARG).  00004320
*              4. COMPUTE SINE OR COSINE OF FRACTION*PI/4 DEPENDING     00004330
*                   ON THE OCTANT.                                      00004340
*              5. IF OCTANT NUMBER IS FOR LOWER PLANE, MAKE SIGN -.     00004350
       SPACE                                                            00004360
       SPACE                                                            00004390
ON       EQU   X'FF'                                                    00004510
OFF      EQU   X'00'                                                    00004520
       SPACE                                                            00004530
COS    EQU     *                                                                
       MVI     CRANK+3,X'02'     FOR COSINE, OCTANT CRANK IS 2          00004590
       B       MERGE                                                            
*                                  COS(X) = SIN(PI/2+X)                         
*                                          OCTANT CRANK IS 4 IF -ARG            
SIN    MVI     CRANK+3,X'00'     FOR SINE, OCTANT CRANK IS 0 IF +ARG            
       LTER    FR6,FR6             ARG IN FP6. SIN(-X) = SIN(PI+X)              
       BNM     MERGE                                                            
       MVI     CRANK+3,X'04'                                            00004720
       SPACE                                                            00004730
MERGE  LD      FR4,ONE         LOAD FR4 DOUBLE WITH ONE                 00004740
       LD      FR2,CRANK       CLEAR L.O. FR2 AND LOAD WITH CRANK       00004750
       LDR     FR0,FR2         CLEAR L.O. FR0                           00004760
     LER       FR0,FR6             GET ARG IN WORK REG                          
       LPER    FR0,FR0         CONSIDER ARGUMENT TO BE POSITIVE         00004780
       CE      FR0,MAXCOS                                                       
       BC      10,ERSNCOS      ERROR IF /X/ GRT THAN OR = PI*2**18              
       MD      FR0,FOVPI       MULTIPLY BY 4/PI (LONG FORM)             00004810
       CER     FR0,FR4                                                  00004820
       BC      4,SMALL         IF PRODUCT LESS THAN 1, JUMP             00004830
       AWR     FR0,FR2         GIVE PROD CHAR OF 46, UNNORM, ADD CRANK  00004840
       LER     FR2,FR0         INTEGER PART OF PROD TO FR2, UNNORM      00004850
       SDR     FR0,FR2         FRACTION PART OF PROD TO FR0, NORM       00004860
       SPACE                                                            00004870
SMALL  STE     FR2,OCTNT       SAVE OCTANT. LAST 3 BITS ARE MOD OCTANT  00004880
       TM      OCTNT+3,X'01'   IF ODD OCTANT, TAKE COMPLEMENT OF        00004890
       BC      8,EVEN            FRACTION TO OBTAIN THE MODIFIED        00004900
       SDR     FR0,FR4             FRACTION R                           00004910
       LPER    FR0,FR0                                                  00004920
       SPACE                                                            00004930
EVEN   LA      GR1,4           GR1 = 4 FOR COSINE POLYNOMIAL            00004940
       TM      OCTNT+3,X'03'     THIS IS FOR OCTANT 2, 3, 6, OR 7       00004950
       BC      4,*+8           GR1 = 0 FOR SINE POLYNOMIAL              00004960
       SR      GR1,GR1           THIS IS FOR OCTANT 1, 4, 5, OR 8       00004970
       LER     FR4,FR0         LOAD FR4 WITH R FOR MULTIPLICATION       00004980
       CE      FR0,UNFLO                                                00004990
       BC      2,*+6           IF R**2 LST 16**-3, SET TO 0             00005000
       SER     FR0,FR0           THIS AVOIDS IRRELEVANT UNDERFLOW       00005010
       MER     FR0,FR0         COMPUTE SINE OR COSINE OF MODIFIED       00005020
       LER     FR2,FR0           FRACTION USING PROPER CHEBYSHEV        00005030
       ME      FR0,S3(GR1)         INTERPOLATION POLYNOMIAL             00005040
       AE      FR0,SS2(GR1)                                                     
       MER     FR0,FR2                                                  00005060
       AE      FR0,SS1(GR1)                                                     
       MER     FR0,FR2                                                  00005080
       AE      FR0,S0(GR1)     SIN(R)/R OR COS(R) READY                 00005090
       MER     FR0,FR4         IF SINE POLYNOMIAL, MULTIPLY BY R        00005100
       TM      OCTNT+3,X'04'                                            00005110
       BC      8,*+6           IF MODIFIED OCTANT IS IN                 00005120
       LNER    FR0,FR0           LOWER PLANE, SIGN IS NEGATIVE          00005130
       SPACE                                                            00005140
       FPRETURN                                                                 
       SPACE                                                            00005190
ERSNCOS  FPERROR  'ARG TO SIN OR COS TOO LARGE (>PI*2**18)'                     
     SPACE                                                                      
       DS      0D                                                       00005220
OCTNT  DS      F                                                        00005230
S3     DC      X'BD25B368'    -0.00003595   SIN C3                      00005240
       DC      X'BE14F17D'    -0.00031957   COS C3                              
SS2    DC      X'3EA32F62'     0.00249001   SIN C2                              
C2     DC      X'3F40ED0F'     0.01585108   COS C2                      00005270
SS1    DC      X'C014ABBC'    -0.08074543   SIN C1                              
C1     DC      X'C04EF4EE'    -0.30842480   COS C1   +1F IN ABS         00005290
S0     DC      X'40C90FDB'     0.78539816   SIN C0                      00005300
C0     DC      X'41100000'     1.00000000   COS C0                      00005310
       DC      X'00000000'                                              00005320
ONE    EQU     C0                                                       00005330
       DS      0D                                                       00005340
CRANK  DC      X'4600000000000000'                                      00005350
FOVPI  DC      X'41145F306DC9C883'                                      00005360
UNFLO  DC      X'3E100000'                                              00005370
MAXCOS DC      X'45C90FDA'      PI*2**18                                        
         TITLE 'ARCTANGENT FUNCTION (SHORT) '                                   
*      CASE 2 --- ARCTAN                                                        
*                                                                       00000660
*              1. REDUCE THE CASE TO THE 1ST OCTANT BY USING            00000680
*                   ATAN(-X)=-ATAN(X), ATAN(1/X)=PI/2-ATAN(X)           00000690
*              2. REDUCE FURTHER TO THE CASE /X/ LESS THAN TAN(PI/12)   00000700
*                   BY ATAN(X)=PI/6+ATAN((X*SQRT3-1)/(X+SQRT3)).        00000710
*              3. FOR THE BASIC RANGE (X LESS THAN TAN(PI/12)), USE     00000720
*                   A CONTINUED FRACTION APPROXIMATION                  00000730
       SPACE                                                            00000760
         SPACE                                                          00000790
ARCTAN LER     FR0,FR6             GET ARG INTO WORK REG                        
       STE     FR0,SIGN2         SAVE ITS SIGN                                  
       LPER    FR0,FR0         FORCE SIGN POSITIVE                      00001120
       LE      FR4,ONE2                                                         
       SR      GR1,GR1         GR1 TO DENOTE THE SECTION TO WHICH       00001420
       CER     FR0,FR4           ANSWER BELONGS. BREAK POINTS ARE       00001430
       BC      12,REDUC            TAN(PI/12), TAN(PI/4), TAN(5PI/12)   00001440
       LER     FR2,FR4         IF ARG GREATER THAN 1, TAKE INVERSE      00001450
       DER     FR2,FR0           AND CRANK GR1 BY 8                     00001460
       LER     FR0,FR2                                                  00001470
       LA      GR1,8                                                    00001480
       SPACE                                                            00001490
REDUC  CE      FR0,SMALL2      IF ARG IS LESS THAN 16**-3, ANS=ARG.             
       BC      12,READY          THIS AVOIDS UNDERFLOW EXCEPTION        00001510
       CE      FR0,TAN15       IF ARG GREATER THAN TAN(PI/12), REDUCE   00001520
       BC      12,OK             THE ARG BY USING                       00001530
       LER     FR2,FR0             ATAN(X) = PI/6+ATAN(Y),              00001540
       ME      FR0,RT3M1             WHERE Y = (X*SQRT3-1)/(X+SQRT3)    00001550
       SER     FR0,FR4                                                  00001560
       AER     FR0,FR2                                                  00001570
       AE      FR2,RT3         COMPUTE X*SQRT3-1 AS X(SQRT3-1)-1+X      00001580
       DER     FR0,FR2           TO PROTECT SIGNIFICANT DIGITS          00001590
       LA      GR1,4(GR1)      CRANK GR1 BY 4                           00001600
       SPACE                                                            00001610
OK     LER     FR4,FR0         NOW MAGNITUDE OF REDUCED ARG IS          00001620
       MER     FR0,FR0           LESS THAN TAN(PI/12)=0.26795           00001630
       LER     FR2,FR0                                                  00001640
       ME      FR0,C           COMPUTE ANGLE BY                         00001650
       AE      FR2,A             ATAN(X)/X = D+C*XSQ+B/(XSQ+A)          00001660
       LE      FR6,B                                                    00001670
       DER     FR6,FR2                                                  00001680
       AER     FR0,FR6                                                  00001690
       AE      FR0,D                                                    00001700
       MER     FR0,FR4                                                  00001710
       SPACE                                                            00001720
READY  AE      FR0,ZERO(GR1)   DEPENDING ON THE SECTION TO WHICH        00001730
       LPER    FR0,FR0           THE ANSWER BELONGS, ADD OR SUBTRACT    00001740
*                                  REDUCED ANSWER FROM A BASE ANGLE             
       TM      SIGN2,X'80'      SIGN OF ANS SHOULD AGREE                        
       BC      8,*+6             WITH SIGN OF ARG                       00001810
       LCER    FR0,FR0                                                  00001820
       FPRETURN                                                                 
       SPACE                                                            00001830
       SPACE                                                            00001900
         DS    0F                                                       00001910
A      DC      X'41168A5E'     1.4087812                                00001930
B      DC      X'408F239C'     0.55913709                               00001940
C      DC      X'BFD35F49'    -0.051604543                              00001950
D      DC      X'409A6524'     0.60310579                               00001960
LIM1   DC      X'06000000'                                              00001970
LIM2   DC      X'FA000000'                                              00001980
ONE2   DC      X'41100000'                                                      
PI     DC      X'413243F7'                                              00002000
RT3    DC      X'411BB67B'     SQRT3                                    00002010
RT3M1  DC      X'40BB67AF'     SQRT3-1                                  00002020
SMALL2 DC      X'3E100000'                                                      
TAN15  DC      X'40449851'     TAN 15 DEGREES                           00002040
ZERO   DC      F'0'                                                     00002050
       DC      X'40860A92'     PI/6                                     00002060
MPIOV2 DC      X'C11921FB'    -PI/2                                     00002070
       DC      X'C110C152'    -PI/3                                     00002080
SIGN2  DS      F                                                                
       TITLE   'EXPONENTIAL FUNCTION (SHORT)'                                   
*                                                                       00002130
*        CASE 3 --- EXP (SHORT)                                                 
*              Y=X*LOG2(E)=4R-S-T, WHERE R AND S ARE INTEGERS, T        00002150
*                FRACTION AND BOTH S AND T ARE NON-NEGATIVE.            00002160
*              THEN E**X=2**Y=(16**R)(2**-S)(2**-T)                     00002170
       SPACE                                                            00002180
*      EXTRA SCRATCH REGS USED BY EXP                                           
       SPACE                                                            00002200
GR3    EQU     15                                                               
GR4      EQU   2                                                                
GR5      EQU   3                                                                
GR6      EQU   4                                                                
         SPACE 3                                                                
EXP    SDR     FR0,FR0         CLEAR FR0 DOUBLE                                 
       LER     FR0,FR6         GET ARGUMENT INTO A WORK REG                     
       CE      FR0,MAXEXP                                                       
       BC      2,ERREXP        IF TOO BIG, ERROR                                
       CE      FR0,MINEXP                                                       
       BC      12,SMALL3       IF TOO SMALL, GIVE 0                             
       SPACE                                                            00002470
       MD      FR0,LOG16E      EFFECT MPY BY LOG E BASE 16 AND SCALE            
       AW      FR0,CH46          TO B24 WITHOUT CAUSING PREMAT UNDFLO   00002490
       STD     FR0,BUFF        /R/ IN H.O. FR0, /S+T/ IN L.O. FR0       00002500
       LM      GR2,GR3,BUFF    /R/ IN GR2, /S+T/ IN GR3                 00002510
       BC      12,NEG3         IF X NON-POSITIVE, JUMP                          
       X       GR2,ALLF        IF X POSITIVE, -R = -R(R'+1) IN GR2,     00002530
       X       GR3,ALLF          S+T = 4-(S'+T') IN GR3                 00002540
       SPACE                                                            00002550
NEG3   LA      GR6,X'FC0'(GR2) SUBTRACT BASE CHARACTERISTIC FROM R              
       SLL     GR6,24                                                   00002570
       SR      GR2,GR2         CLEAR GR2 TO RECEIVE S                   00002580
       SLDL    GR2,2           S IN GR2 LOW, T IN GR3 HIGH              00002590
       SRL     GR3,4           T                         (B3)           00002600
       LR      GR1,GR3         SAVE T       IN GR3       (B3)           00002610
       MR      GR0,GR1         T*T                       (B7)           00002620
       LR      GR5,GR0                                                  00002630
       M       GR4,C3         C3*T*T        IN GR4       (B4)                   
       A       GR0,A3                                                           
       LR      GR5,GR0         A+T*T        IN GR5       (B7)           00002660
       L       GR0,B3                                                           
       DR      GR0,GR5         B/(A+T*T)    IN GR1       (B3)           00002680
       SR      GR1,GR3                                                  00002690
       SRL     GR1,1           -T+B/(A+T*T) IN GR1       (B4)           00002700
       A       GR1,D3                                                           
       AR      GR1,GR4         C*T*T+D-T+B/(A+T*T)       (B4)           00002720
       LR      GR4,GR3                                                  00002730
       SRL     GR4,2           2*T                       (B6)           00002740
       DR      GR4,GR1         2*T/(C*T*T+D-T+B/(A+T*T)) (B1)           00002750
       SRA     GR5,5                                                    00002760
       A       GR5,FXONE       2**(-T) READY             (B6)           00002770
       SRL     GR5,0(GR2)      (2**-S)(2**-T) READY      (B6)           00002780
       S       GR5,ALLF        ROUND AND                                00002790
       C       GR5,FXONE         FLOAT THIS NUMBER                      00002800
       SRL     GR5,1                                                    00002810
       BC      4,JOIN                                                   00002820
       L       GR5,ONE3                                                         
       SPACE                                                            00002840
JOIN   SR      GR5,GR6         ADJUST CHARACTERISTIC WITH -R            00002850
       ST      GR5,BUFF                                                 00002860
       LE      FR0,BUFF                                                 00002870
       SPACE                                                            00002880
EXIT3  L       R15,PR15                                                         
         CLI   TIMELEFT,0          CHECK IF TIMER RAN OUT DURING                
         BE    FPTIMOUT            EXP MONITOR CALL. IF SO, GIVE ERROR.         
         LM    R13,R4,ORGPSCLR+8(R15)  OTHERWISE, RETURN TO USER.               
       BR      LINK                                                             
SMALL3 SER     FR0,FR0                                                          
       B       EXIT3                                                            
       SPACE                                                            00002960
ERREXP FPERROR 'ARGUMENT TO EXP TOO LARGE (>174.673)'                           
      SPACE                                                                     
       DS      0D                                                               
ALLF   DC      X'FFFFFFFF'                                              00002990
A3     DC      X'576AE119'     87.4174972   (B7)                                
B3     DC      X'269F8E6B'     617.972269   (B11)                               
C3     DC      X'B9059003'    -0.034657359  (B-4)                               
D3     DC      X'B05CFCE3'    -9.95459578   (B4)                                
FXONE  DC      X'02000000'     1            (B6)                        00003040
MAXEXP DC      X'42AEAC4F'     174.673                                          
MINEXP DC      X'C2B437E0'    -180.218                                          
ONE3   DC      X'01100000'                                                      
       DS      0D                                                               
CH46   DC      X'4700000000000000'       X'46000...00' RAISED BY 1      00003090
LOG16E DC      X'415C551D94AE0BF8'       (LOG E BASE 16)*16             00003100
       TITLE   'LOGARITHMIC FUNCTION (SHORT)'                                   
*        CASE 4 --- LN                                                          
*                                                                       00003150
*              1. WRITE X = (M*2**-Q)*16**P, M MANTISSA BETWEEN 1/2     00003170
*                   AND 1, Q INTEGER BETWEEN 0 AND 3. DEFINE A=1, B=0   00003180
*                     IF M GREATER THAN SQRT2/2, OTHERWISE A=1/2, B=1.  00003190
*              2. WRITE Z = (M-A)/(M+A), THEN                           00003200
*                   LOG(X) = (4P-Q-B)LOG(2)+LOG((1+Z)/(1-Z)).           00003210
       SPACE                                                            00003220
LN     LTER    FR6,FR6         TEST SIGN OF ARGUMENT. IF ZERO OR                
       BNP     ERRORLN         NEGATIVE GIVE ERROR MESSAGE                      
       STE     FR6,BUFF        GET ARG INTO GR0                                 
       L       GR0,BUFF                                                         
       LR      GR2,GR0                                                          
       SRDL    GR0,24          MANTISSA IN HIGH GR1                     00003590
       SLL     GR0,2                                                    00003600
       STH     GR0,IPART+2     FLOAT 4*CHAR AND SAVE IT                 00003610
       SRL     GR1,29          FIRST THREE BITS OF MANTISSA IN GR1      00003620
       IC      GR1,TABLE(GR1)  NUMBER OF LEADING ZEROS (=Q) IN GR1      00003630
       SLL     GR2,0(GR1)      SHIFT MANTISSA LEFT BY Q                 00003640
       ST      GR2,BUFF                                                 00003650
       MVI     BUFF,X'40'      M=MANTISSA*2**Q IN BUFF                  00003660
       SR      GR2,GR2                                                  00003670
       LE      FR0,BUFF        PICK UP M IN FR0                         00003680
       CE      FR0,LIMIT       IF M GREATER THAN SQRT(2)/2, GR2=0       00003690
       BC      2,READY4                                                         
       LA      GR2,4           IF M LESS THAN SQRT(2)/2, GR2=4          00003710
       LA      GR1,1(GR1)        AND CRANK GR1 BY 1. Q+B IN GR1         00003720
       SPACE                                                            00003730
READY4 LD      FR2,ROUND       PRELOAD FR2 WITH ROUNDING FUDGE                  
       HER     FR4,FR0         COMPUTE 2Z=(M-A)/(0.5M+0.5A)             00003750
       SE      FR0,ONE4(GR2)      A=1 IF GR2=0, A=1/2 IF GR2=4                  
       BC      7,*+6                                                    00003770
       SDR     FR2,FR2           AVOID POSSIBLE UNDERFLOW INTERRUPT     00003780
       AE      FR4,HALF4(GR2)       WHEN ARG IS AN EXACT POWER OF 2             
       DER     FR0,FR4                                                  00003800
       LER     FR2,FR0         COMPUTE LOG((1+Z)/(1-Z)) USING A         00003810
       MER     FR0,FR0           MINIMAX APPROXIMATION OF THE FORM      00003820
       LE      FR4,B4              W+W(A*W**2/(B-W**2)), WHERE W=2Z             
       SER     FR4,FR0                                                  00003840
       ME      FR0,A4                                                           
       DER     FR0,FR4                                                  00003860
       MER     FR0,FR2                                                  00003870
       ADR     FR2,FR0           EFFECTIVE ROUNDING HERE                00003880
       SPACE                                                            00003890
       LE      FR0,IPART       4*(P+64)                                 00003900
       LA      GR1,256(GR1)    4*64+Q+B                                 00003910
       STH     GR1,IPART+2                                              00003920
       SE      FR0,IPART       4*P-Q-B                                  00003930
       ME      FR0,LOGE2                                                00003940
       ADR     FR0,FR2         NATURAL LOG READY                        00003950
       SPACE                                                            00003960
       FPRETURN                                                                 
       SPACE                                                            00004020
ERRORLN  FPERROR 'ARGUMENT TO LN 0.0 OR NEGATIVE'                               
         SPACE                                                                  
       DS      0D                                                       00004100
A4     DC      X'408D8BC7'     0.55291406                                       
B4     DC      X'416A298C'     6.63515366                                       
IPART  DC      X'46000000F0000000'   INTEGER PART + ROUNDING FUDGE      00004130
ROUND  EQU     IPART                                                    00004140
LIMIT  DC      X'40B504F3'     SQRT(2)/2                                00004150
LOGE2  DC      X'40B17219'     LOG(2) BASE E + FUDGE 1                  00004160
LOGTE  DC      X'406F2DED'     LOG(E) BASE 10 + FUDGE 1                 00004170
ONE4   DC      X'41100000'     1       THESE THREE                              
HALF4  DC      X'40800000'     1/2       CONSTANTS MUST                         
       DC      X'40400000'     1/4         BE CONSECUTIVE               00004200
TABLE  DC      X'0302010100000000'                                      00004210
       TITLE   'SQUARE ROOT FUNCTION (SHORT)'                                   
*        CASE 5 --- SQRT                                                        
*                                                                       00005430
*              1. WRITE X = M*16**(2P+Q), M MANTISSA, Q = 0 OR 1.       00005450
*              2. THEN SQRT(X) = SQRT(M*16**-Q)*16**(P+Q).              00005460
       SPACE                                                            00005470
SQRT   LER     FR0,FR6                                                          
       LTER    FR2,FR0                                                  00005680
       BZ      EXIT5           IF ARG IS 0, ANSWER IS 0. RETURN.                
       BM      ERRSQRT         NEGATIVE ARG IS A NO-NO.                         
       STE     FR2,BUFF        GET ARG INTO GR0                                 
       L       GR0,BUFF                                                         
       SRDL    GR0,25                                                   00005720
       SLL     GR0,24          CHAR OF ANSWER MINUS Q+32                00005730
       SRA     GR1,3           SIGN BIT OF GR3 = Q. SCALE Q+M TO B3     00005740
       BC      11,*+8                                                   00005750
       A       GR0,BIAS        IF Q=1, ADD 1 TO CHAR AND 4 FOR INDEXING 00005760
       LR      GR2,GR0                                                  00005770
       A       GR1,C5(GR2)      OBTAIN 1ST APPROX BY A HYPERBOLIC FIT           
       L       GR0,B5(GR2)        OF THE RESPECTIVE INTERVAL.                   
       DR      GR0,GR1             IF Q=1, INTERPRET M AS M/16 (B-1)    00005800
       A       GR1,A5(GR2)                                                      
       ALR     GR1,GR2         ADD ON CHAR-32 TO COMPLETE 1ST APPROX    00005820
       ST      GR1,BUFF                                                 00005830
       MVC     ROUND5(1),BUFF   GIVE ROUND CHARACTERISTIC OF ANSWER             
       SPACE                                                            00005850
       DE      FR0,BUFF        GIVE TWO PASSES OF NEWTON-RAPHSON        00005860
       AU      FR0,BUFF          ITERATION                              00005870
       HER     FR0,FR0                                                  00005880
       DER     FR2,FR0         (X/Y1+Y1)/2 = (Y1-X/Y1)/2+X/Y1 TO GUARD  00005890
       AU      FR0,ROUND5        LAST DIGIT-.  ADD ROUNDING FUDGE               
       SER     FR0,FR2                                                  00005910
       HER     FR0,FR0                                                  00005920
       AER     FR0,FR2                                                  00005930
       SPACE                                                            00005940
EXIT5  FPRETURN                                                                 
       SPACE                                                            00005990
ERRSQRT  FPERROR  'NEGATIVE ARGUMENT TO SQRT'                                   
       SPACE                                                                    
       DS      0D                                                               
BIAS   DC      X'01000004'                                              00006020
A5     DC      X'21AE7D00'     1.6815948    A0 (B7) + 32 (B7)                   
       DC      X'206B9F3C'     0.4203987    A1 (B7) + 32 (B7) - 4 (B31) 00006040
B5     DC      X'FFEB605E'    -1.2889728    B0 (B11)                            
       DC      X'FFFAD818'    -0.0201402    B1 (B7)                     00006060
C5     DC      X'0D73F185'     0.8408065    C0 (B3)                             
       DC      X'1D73F185'     0.0525504    C1 (B-1) + 1 (B3)           00006080
ROUND5 DC      X'00000001'                                                      
      TITLE   '     '                                                           
*                                                                               
*        CASES 6..12 ARE RESERVED FOR FUTURE USE.                               
*                                                                               
         SPACE 5                                                                
CASE6    DS    0H                                                               
CASE7    DS    0H                                                               
CASE8    DS    0H                                                               
CASE9    DS    0H                                                               
CASE10   DS    0H                                                               
CASE11   DS    0H                                                               
CASE12   DS    0H                                                               
         SRVRTNED  ,               RETURN;                                      
         EJECT                                                                  
*                                                                               
*        CASE 13 --- EOLN                                                       
*                                                                               
         SPACE 5                                                                
EOLN     DS    0H                                                               
         CHKFILE INPUT                                                          
         CLC   INPTR,=H'80'        END OF LINE REACHED?                         
         BNE   EOLN1               IF NOT,DOBRANCH                              
         LA    R9,1                INDICATE ON IN RETURN REGISTER               
         B     EOLN2               BRANCH                                       
EOLN1    LA    R9,0                INDICATE OFF                                 
EOLN2    SRVRTNED                                                               
         SPACE 5                                                                
FILEERR  BAL   LINKREG,ERROR                                                    
         DC    AL1(L'FILEERRM)                                                  
FILEERRM DC    C'NONSTANDARD FILES NOT YET IMPLEMENTED'                         
         EJECT                                                                  
*                                                                               
*        CASE 14 --- EOF                                                        
*                                                                               
         SPACE 5                                                                
EOF      DS    0H                                                               
         CHKFILE INPUT                                                          
         CLI   ENDFILE,X'FF'       END OF FILE INDICATION ON?                   
         BNE   EOF1                IF NOT,DO BRANCH                             
         LA    R9,1                INDICATE ON IN RETURN REGISTER               
         B     EOF2                BRANCH                                       
EOF1     LA    R9,0                INDICATE OFF                                 
EOF2     SRVRTNED                                                               
         EJECT                                                                  
*                                                                               
*        CASE 15 --- NEW                                                        
*                                                                               
         SPACE 5                                                                
NEW      DS    0H                  DO;                                          
         LA    R9,3(0,R9)             J = (ARG1 + 3) & "FFFFFFFC";              
         N     R9,=X'FFFFFFFC'                                                  
         L     R1,ORGORGN             HEAP_PTR = HEAP_PTR - J;                  
         L     R2,HEAPPTR(0,R1)                                                 
         SR    R2,R9                                                            
         ST    R2,HEAPPTR(0,R1)                                                 
         L     R3,MAXTOP(0,R1)        MAX_TOP = MAX_TOP - J;                    
         SR    R3,R9                                                            
         ST    R3,MAXTOP(0,R1)                                                  
         L     R4,STACKTOP(0,R1)      IF MAX_TOP < STACKTOP THEN                
         CR    R3,R4                                                            
         BNL   NEW1                                                             
         LA    LINKREG,MEMERR            CALL ERROR(MEMORY_ERROR);              
         B     ERROR                                                            
NEW1     LR    R9,R2                  RETURNS = HEAP_PTR;                       
         SRVRTNED  ,               END;                                         
         SPACE 3                                                                
STACKTOP EQU   ORGPSCLR+8          /* WHERE STACKTOP REGISTER IS STORED         
*                                     IN ORG SEGMENT. */                        
         EJECT                                                                  
*                                                                               
*        CASE 16 --- DISPOSE                                                    
*                                                                               
         SPACE 5                                                                
DISPOSE  DS    0H                  DO;                                          
*                                     /***** NOT IMPLEMENTED YET *****/         
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 17 --- GET                                                        
*                                                                               
         SPACE 5                                                                
GET      DS    0H                  DO;                                          
         CHKFILE INPUT                                                          
         BAL   LINKREG,NEXTCH         CALL NEXTCH;                              
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
OUTLINE  DC    CL133'1'            BUFFER FOR PRINTED OUTPUT.                   
OUTLINEP DC    A(OUTLINE)          DESCRIPTOR FOR CURRENT OUTPUT LINE.          
LINEST   DS    F                   ESTIMATE OF PRINTED LINES                    
         EJECT                                                                  
*                                                                               
*        CASE 18 --- PUT                                                        
*                                                                               
         SPACE 5                                                                
PUT      DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         L     R1,OUTLINEP            OUT_LINE =                                
         L     R2,PR14                   OUT_LINE || OUTPUT@;                   
         LA    R2,OUTPUT@(0,R2)                                                 
         BAL   LINKREG,CATENATE                                                 
         ST    R1,OUTLINEP                                                      
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 19 --- RESET                                                      
*                                                                               
         SPACE 5                                                                
RESET    DS    0H                  DO;                                          
*                                     /***** NOT YET IMPLEMENTED *****/         
         B     FILEERR                                                          
*        SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 20 --- REWRITE                                                    
*                                                                               
         SPACE 5                                                                
REWRITE  DS    0H                  DO;                                          
*                                     /***** NOT YET IMPLEMENTED *****/         
         B     FILEERR                                                          
*        SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        ROUTINE ERROR                                                          
*                                                                               
*        PURPOSE : WRITE AN ERROR MESSAGE                                       
*                                                                               
         SPACE 5                                                                
ERROR    STM   R13,R3,ERRORR12                                                  
         ST    LINKREG,ERRORAUX                                                 
         LA    R1,MAXINT           LINEST <--- MAXINT.                          
         ST    R1,LINEST                                                        
         L     R1,OUTLINEP         IS LENGTH(OUT_LINE) > 1?                     
         SRA   R1,24                                                            
         BZ    ERROR1              NO, SO BRANCH                                
         BAL   LINKREG,PUTLN       WRITE THE EXISTING LINE                      
ERROR1   LA    R10,0(0,R10)        CLEAR THE HIGH ORDER BYTE                    
         ST    R10,ERRLINE         ERRLINE<---SOURCE LINE OF ERROR              
         BAL   LINKREG,SRCLINE                                                  
         MVC   OUTLINE(133),ERRORC                                              
         MVI   OUTLINEP,132                                                     
         BAL   LINKREG,PUTLN       WRITE A LINE OF DASHES.                      
*                                                                               
*        PRINT THE ERROR MESSAGE                                                
*                                                                               
         MVI   OUTLINE,C' '                                                     
         MVC   OUTLINE+1(ERRORC1L),ERRORC1                                      
         LA    R1,ERRORC1L         LENGTH(OUT_LINE) - 1                         
         SLL   R1,24               SHIFT TO HIGH ORDER BYTE.                    
         LA    R2,OUTLINE                                                       
         OR    R1,R2               R1<---DESCRIPTOR FOR OUT_LINE                
         L     R3,ERRORAUX         R3<---POINTER TO ERROR MESSAGE.              
         SR    R2,R2                                                            
         IC    R2,0(0,R3)          R2<---LENGTH(ERROR MESSAGE).                 
         BCTR  R2,0                LENGTH(ERROR MESSAGE) - 1.                   
         SLL   R2,24               SHIFT TO HIGH ORDER BYTE.                    
         LA    R3,1(0,R3)          ADDR OF ERROR MESSAGE                        
         OR    R2,R3               FORM DESCRIPTOR.                             
         BAL   LINKREG,CATENATE    CONCATENATE MESSAGE ONTO LINE.               
         ST    R1,OUTLINEP                                                      
         L     R1,ERRLINE          SOURCE LINE IN R1                            
         LTR   R1,R1               SUCCESSFULLY COMPUTED?                       
         BNP   ERROR2                                                           
         BAL   LINKREG,INT2STR     CONVERT NUMBER TO STRING.                    
         LR    R2,R1               STRING DESCRIPTOR IN R2                      
         L     R1,NEARLINE         DESCRIPTOR FOR 'NEAR LINE' MESSAGE           
         BAL   LINKREG,CATENATE    CONCATENATE                                  
         LR    R2,R1               DESCRIPTOR IN R2.                            
         L     R1,OUTLINEP         DESCRIPTOR OF  MESSAGE LINE                  
         BAL   LINKREG,CATENATE    CONCATENATE LINE NUMBER INFO                 
         ST    R1,OUTLINEP                                                      
ERROR2   L     R1,OUTLINEP         DESCRIPTOR IN R1                             
         L     R2,ERROREOM         DESCRIPTOR FOR MESSAGE TRAILER CHARS         
         BAL   LINKREG,CATENATE    COMPLETES MESSAGE                            
         ST    R1,OUTLINEP         SAVE DESCRIPTOR                              
         BAL   LINKREG,PUTLN       WRITE THE MESSAGE.                           
         MVI   ERRLINE,X'FF'       INDICATE A RUN ERROR DEVELOPED               
         LM    R13,R3,ERRORR12                                                  
         B     ENDMNTR             BACK TO OV MONITOR                           
         SPACE 3                                                                
         DS    0F                  STRING DESCRIPTORS                           
ERROREOM DC    AL1(L'ERRORC2-1),AL3(ERRORC2)                                    
NEARLINE DC    AL1(L'NRLINE-1),AL3(NRLINE)                                      
         SPACE 1                                                                
ERRORC2  DC    C'. ***'            THE FIELD ERRORC2                            
ERRORC1  DC    C'*** RUN ERROR, '  THE FIELD ERRORC1                            
ERRORC1L EQU   L'ERRORC1                                                        
NRLINE   DC    C' -- NEAR LINE '                                                
ERRORC   DC    C'0',132C'-'        THE LINE ERRORC                              
ERRORR12 DS    7F                                                               
ERRORAUX DS    F                                                                
         EJECT                                                                  
*                                                                               
*        PROGRAM INTERRUPT EXIT ROUTINE                                         
*                                                                               
         SPACE 5                                                                
PGMCHK   DS    0H                  SYSTEM ENTERS HERE.                          
         DROP  BASE1,BASE2,BASE3                                                
         USING PGMCHK,R15                                                       
         STM   R11,R12,SPIESAVE    SAVE REGISTERS 11 AND 12.                    
         LM    BASE3,BASE1,SPIEBASE LOAD BASE1, BASE2, AND BASE3.               
         DROP  R15                                                              
         USING MONITOR,BASE1,BASE2,BASE3                                        
         SR    R2,R2               CLEAR REGISTER 2.                            
         L     R3,8(0,R1)          WORD 2 OF OLD PSW IN R3.                     
         SLDL  R2,3                2 * INSTRUCTION LENGTH CODE IN R2.           
         LNR   R2,R2                                                            
         SRL   R3,3                                                             
         LA    R3,0(R2,R3)         ADDRESS OF INTERRUPTED INSTRUCTION           
*                                     IN R3.                                    
         LH    R4,6(0,R1)          INTERRUPTION CODES IN R4.                    
         MVC   9(3,R1),APGMCHK1+1  RESUME EXECUTION AT PGMCHK1.                 
         BR    R14                 RETURN TO O.S.                               
PGMCHK1  DS    0H                  RESUME EXECUTION HERE.                       
         C     R3,CODEPNT          WAS INTERRUPT IN PASCAL CODE?                
         BL    PGMCHK2             NO, GO CALL ERROR.                           
         C     R3,PR14                                                          
         BNL   PGMCHK2                                                          
*                                                                               
*        PROGRAM INTERRUPT IN PASCAL CODE.                                      
*                                                                               
         LR    R10,R3              SET ERROR LOCATION.                          
         L     R2,PR15             ADDRESS OF ORG SEGMENT.                      
         MVC   ORGPSCLR(8,R2),SPIESAVE PLANT PASCAL REGS. 11, 12.               
PGMCHK2  LA    R3,X'F'                                                          
         NR    R4,R3               INTERRUPT_CODE & "F"                         
         SLL   R4,2                                                             
         L     LINKREG,SPIEERRM(R4) ADDRESS OF MESSAGE.                         
         B     ERROR               CALL ERROR.                                  
         SPACE 5                                                                
PICAADDR DS    A                   ADDRESS OF OLD PICA.                         
SPIESAVE DS    2F                  SAVE AREA FOR R11, R12.                      
SPIEBASE DC    A(MONITOR+8192),A(MONITOR+4096),A(MONITOR)                       
APGMCHK1 DC    A(PGMCHK1)                                                       
SPIEERRM DS    0F                  TABLE OF ERROR MESSAGE POINTERS.             
         DC    A(SPIE0),A(SPIE1),A(SPIE2),A(SPIE3),A(SPIE4),A(SPIE5)            
         DC    A(SPIE6),A(SPIE7),A(SPIE8),A(SPIE9),A(SPIEA),A(SPIEB)            
         DC    A(SPIEC),A(SPIED),A(SPIEE),A(SPIEF)                              
*                                                                               
*        SPIE ERROR MESSAGES.                                                   
*                                                                               
SPIE0    DC    AL1(L'SPIE0M)                                                    
SPIE0M   DC    C'IMPRECISE OR MULTIPLE-IMPRECISE PROGRAM INTERRUPTION'          
SPIE1    DC    AL1(L'SPIE1M)                                                    
SPIE1M   DC    C'OPERATION EXCEPTION'                                           
SPIE2    DC    AL1(L'SPIE2M)                                                    
SPIE2M   DC    C'PRIVILEGED-OPERATION EXCEPTION'                                
SPIE3    DC    AL1(L'SPIE3M)                                                    
SPIE3M   DC    C'EXECUTE EXCEPTION'                                             
SPIE4    DC    AL1(L'SPIE4M)                                                    
SPIE4M   DC    C'PROTECTION EXCEPTION'                                          
SPIE5    DC    AL1(L'SPIE5M)                                                    
SPIE5M   DC    C'ADDRESSING EXCEPTION'                                          
SPIE6    DC    AL1(L'SPIE6M)                                                    
SPIE6M   DC    C'SPECIFICATION EXCEPTION'                                       
SPIE7    DC    AL1(L'SPIE7M)                                                    
SPIE7M   DC    C'DATA EXCEPTION'                                                
SPIE8    DC    AL1(L'SPIE8M)                                                    
SPIE8M   DC    C'INTEGER OVERFLOW'                                              
SPIE9    DC    AL1(L'SPIE9M)                                                    
SPIE9M   DC    C'INTEGER DIVISION BY ZERO'                                      
SPIEA    DC    AL1(L'SPIEAM)                                                    
SPIEAM   DC    C'DECIMAL OVERFLOW EXCEPTION'                                    
SPIEB    DC    AL1(L'SPIEBM)                                                    
SPIEBM   DC    C'DECIMAL DIVISION EXCEPTION'                                    
SPIEC    DC    AL1(L'SPIECM)                                                    
SPIECM   DC    C'REAL EXPONENT OVERFLOW'                                        
SPIED    DC    AL1(L'SPIEDM)                                                    
SPIEDM   DC    C'REAL EXPONENT UNDERFLOW'                                       
SPIEE    DC    AL1(L'SPIEEM)                                                    
SPIEEM   DC    C'REAL SIGNIFICANCE EXCEPTION'                                   
SPIEF    DC    AL1(L'SPIEFM)                                                    
SPIEFM   DC    C'REAL DIVISION BY ZERO'                                         
         EJECT                                                                  
*                                                                               
*        PROCEDURE SOURCE_LINE                                                  
*                                                                               
*        PURPOSE: COMPUTES THE SOURCE LINE WHICH CORRESPONDS TO AN              
*                 ADDRESS IN THE PASCAL CODE SEGMENT.                           
*                                                                               
*        INPUT:  ABSOLUTE ADDRESS, IN LOCATION ERRLINE.                         
*                                                                               
*        OUTPUT: LINE NUMBER, IN LOCATION ERRLINE.                              
*                                                                               
        SPACE 5                                                                 
SRCLINE  DS    0H                                                               
         STM   R14,R4,SRCLSAVE     /* SAVE REGISTERS */                         
         SR    R3,R3               LINE# = 0;                                   
         CLC   ERRLINE,CODEPNT     IF (ERRLINE < CODE_POINTER)                  
         BL    LINE#RTN                                                         
         CLC   ERRLINE,PR14           | (ERRLINE >= GLOBAL_ARBASE) THEN         
         BNL   LINE#RTN            RETURN 0;                                    
         L     R2,ERRLINE          RELATIVE_ADDR =                              
         S     R2,CODEPNT             ERRLINE - CODE_POINTER;                   
*                                                                               
*        OPEN THE LINE NUMBER FILE, AND READ THE 1ST 80-BYTE RECORD.            
*                                                                               
         OPEN  LINE#DCB                                                         
         LA    R1,LINE#DCB         BUFFER = INPUT(LINE#_FILE);                  
         GET   (R1)                                                             
*                                                                               
*        R1 NOW POINTS TO THE 1ST RECORD OF LINE NUMBER INFORMATION.            
*        THE LAST RECORD HAS THE CHARACTERS '%END' IN COLUMNS 1..4.             
*        ALL OTHER RECORDS ARE DIVIDED INTO 20 4-COLUMN BINARY FIXED            
*        FULLWORD NUMBERS.                                                      
*                                                                               
SRCLINE1 CLI   0(1),C'%'           DO WHILE (BYTE(BUFFER) ~= BYTE('%'))         
         BE    LINE#RTN                     & (LAST_#_IN_BUFFER <=              
         C     R2,76(0,R1)                             RELATIVE_ADDR);          
         BL    SRCLINE2                                                         
         LA    R3,20(0,R3)            LINE# = LINE# + 20;                       
         LA    R1,LINE#DCB            BUFFER = INPUT(LINE#_FILE);               
         GET   (R1)                END;                                         
         B     SRCLINE1                                                         
SRCLINE2 DS    0H                  IF BYTE(BUFFER) = BYTE('%') THEN             
*                                     RETURN LINE#;                             
         LA    R4,18               I = 18;                                      
SRCLINE3 LTR   R4,R4               DO WHILE (I > 0)                             
         BM    LINE#RTN               & (ITH_#_IN_BUFFER >                      
         SLL   R4,2                         RELATIVE_ADDR);                     
         C     R2,0(R4,R1)                                                      
         SRL   R4,2                                                             
         BNL   SRCLINE4                                                         
         BCTR  R4,0                   I = I - 1;                                
         B     SRCLINE3            END;                                         
SRCLINE4 LA    R3,1(R3,R4)         RETURN LINE# + I + 1;                        
LINE#RTN ST    R3,ERRLINE                                                       
*                                                                               
*        CLOSE THE LINE NUMBER FILE                                             
*                                                                               
         CLOSE LINE#DCB                                                         
         LA    R1,LINE#DCB                                                      
         USING IHADCB,R1                                                        
         TM    DCBBUFCB+3,1                                                     
         BO    SRCLINE5                                                         
         FREEPOOL (1)                                                           
         DROP  R1                                                               
SRCLINE5 LM    R14,R4,SRCLSAVE                                                  
         BR    LINKREG                                                          
         SPACE 3                                                                
SRCLSAVE DS    7F                                                               
         PRINT NOGEN                                                            
LINE#DCB DCB   DDNAME=SYSUT4,DSORG=PS,MACRF=GL                                  
         PRINT GEN                                                              
         EJECT                                                                  
*                                                                               
*        CASE 21 --- READ_INT                                                   
*                                                                               
         SPACE 5                                                                
READINT  DS    0H                                                               
         CHKFILE INPUT                                                          
         MVI   READINTS,X'00'      INTEGER SIGN IS POSITIVE.ASSUMPTION          
         LA    R9,0                R9<---0.R9 CONTAINS THE VALUE OF THE         
*                                  READ INTO INTEGER                            
         L     R2,PR14             R2 POINTS TO GLBL AR AREA                    
         B     READINT9                                                         
READINT1 BAL   LINKREG,NEXTCH      READ NEXT CHARACTER                          
READINT9 CLI   INPUT@(R2),C' '     IS IT A BLANK?                               
         BE    READINT1            IF YES,DO BRANCH                             
         CLI   INPUT@(R2),C'-'     IS IT A '-' ?                                
         BNE   READINT2            IF NOT,DO BRANCH                             
         MVI   READINTS,X'FF'      INDICATE SIGN IS NEGATIVE                    
READINT4 BAL   LINKREG,NEXTCH      READ NEXT CHARACTER                          
         B     READINT3            PROCEED                                      
READINT2 CLI   INPUT@(R2),C'+'     IS IT A '+' ?                                
         BE    READINT4            IF YES,DO BRANCH                             
READINT3 CLI   INPUT@(R2),C'0'     IS IT A DIGIT ?                              
         BL    READINTE            IF NOT,ISSUE AN ERROR MESSAGE                
         CLI   INPUT@(R2),C'9'     IS IT A DIGIT ?                              
         BH    READINTE            IF NOT,ISSUE AN ERROR MESSAGE                
READINT6 LA    R4,0                R4<---0                                      
         IC    R4,INPUT@(R2)       R4 HOLDS THE DIGIT                           
         S     R4,=A(X'F0')        R4 HOLDS ITS BINARY VALUE                    
         C     R9,MAX10            R9<MAX10 ?                                   
         BNL   READINT5            IF NOT,DO BRANCH                             
READINT7 MH    R9,=H'10'           R9<----R9*10                                 
         AR    R9,R4               R9<---R9+R4                                  
         BAL   LINKREG,NEXTCH      READ NEXT CHARACTER                          
         CLI   INPUT@(R2),C' '     IS IT A BLANK ?                              
         BE    READINTF            IF YES,DO BRANCH                             
         CLI   INPUT@(R2),C'0'     IS IT A DIGIT ?                              
         BL    READINTF            IF NOT,DO BRANCH                             
         CLI   INPUT@(R2),C'9'     IS IT A DIGIT ?                              
         BH    READINTF            IF NOT,DO BRANCH                             
         B     READINT6            PROCEED                                      
READINT5 BH    READIE1             IF R9>MAX10 , ERROR MESSAGE                  
         C     R4,RES10            R4>RES10                                     
         BNH   READINT7            IF NOT,DO BRANCH                             
         CLI   READINTS,X'FF'      IS IT A NEGATIVE INTEGER ?                   
         BNE   READIE1             IF NOT,ISSUE AN ERROR MESSAGE                
         BCTR  R4,0                R4<---R4-1                                   
         C     R4,RES10            R4>RES10                                     
         BNE   READIE1             IF YES,ISSUE AN ERROR MESSAGE                
         L     R9,READINTC         IF NOT , SET INTEGER VALUE                   
         BAL   LINKREG,NEXTCH                                                   
         CLI   INPUT@(R2),C' '                                                  
         BE    READINT8                                                         
         CLI   INPUT@(R2),C'0'                                                  
         BL    READINT8                                                         
         CLI   INPUT@(R2),C'9'                                                  
         BH    READINT8                                                         
         B     READIE1                                                          
READINTF CLI   READINTS,X'FF'      IS THE INTEGER NEGATIVE ?                    
         BNE   READINT8            IF NOT,DO BRANCH                             
         LCR   R9,R9               R9<--- -R9                                   
READINT8 SRVRTNED                                                               
         SPACE 3                                                                
READIE1  BAL   LINKREG,ERROR                                                    
         DC    AL1(L'READIEM2)                                                  
READIEM2 DC    C'WHILE READING INTEGER CONSTANT -- VALUE OUT OF RANGE'          
READINTE BAL   LINKREG,ERROR                                                    
         DC    AL1(L'READIEM1)                                                  
READIEM1 DC    C'WHILE READING INTEGER CONSTANT - DIGIT EXPECTED'               
RES10    DC    A(7)                REMAINDER OF X'7FFFFFFF'/10                  
MAX10    DC    F'214748364'        EQUAL TO X'7FFFFFFF'/10                      
READINTC DS    0F                  MOST NEGATIVE INTEGER VALUE                  
         DC    X'80'                                                            
         DC    AL3(0)                                                           
READINTS DS    X                   SIGN OF THE INTEGER                          
         EJECT                                                                  
POWERS   POWERS                    CALL MACRO POWERS (= EXPANDS POWERS)         
         EJECT                                                                  
*                                                                               
*        CASE 22 --- READ_REAL                                                  
*                                                                               
         SPACE 5                                                                
READREAL DS    0H                                                               
         CHKFILE INPUT                                                          
         MVI   RSIGN,X'00'         ASSUME POSITIVE                              
         MVI   REXPSIGN,X'00'      ASSUME POSITIVE                              
         LA    R2,0                R2 IS NUMBER                                 
         LA    R3,0                R3 IS SCALE                                  
         LA    R4,0                R4 IS EXPONENT                               
         L     R5,PR14             R5 POINTS TO GLBL AR AREA                    
READRE2  CLI   INPUT@(R5),C' '     CURRENT INPUT CHARACTER IS ABLANK ?          
         BNE   READRE1             IF NOT,DO BRANCH                             
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         B     READRE2             LOOP                                         
READRE1  CLI   INPUT@(R5),C'-'     IS IT A MINUS ?                              
         BNE   READRE3             IF NOT,DO BRANCH                             
         MVI   RSIGN,X'FF'         IF YES,SET RSIGN TO ON                       
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         B     READRE4             PROCEED                                      
READRE3  CLI   INPUT@(R5),C'+'     IS IT A '+' ?                                
         BNE   READRE4             IF NOT,DO BRANCH                             
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
READRE4  CLI   INPUT@(R5),C'0'     IS IT A DIGIT ?                              
         BL    READREE1            IF NOT,ERROR MESSAGE                         
         CLI   INPUT@(R5),C'9'     IS IT A DIGIT ?                              
         BH    READREE1            IF NOT,ERROR MESSAGE                         
READRE7  C     R2,MAX10            NUMBER LOWER THAN MAX10 ?                    
         BNL   READRE5             IF NOT,DO BRANCH                             
         MH    R2,=H'10'           NUMBER<---NUMBER*10                          
         LA    R6,0                R6<---0                                      
         IC    R6,INPUT@(0,R5)     R6<---INPUT@                                 
         SLL   R6,28               R6<---                                       
         SRL   R6,28                       INPUT@-C'0'                          
         AR    R2,R6               NUMBER<---NUMBER+DIGIT                       
         B     READRE6             PROCEED                                      
READRE5 LA     R3,1(0,R3)          SCALE<---SCALE+1                             
READRE6  BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         CLI   INPUT@(R5),C'0'     IF NOT,DO BRANCH                             
         BL    READRE8                                                          
         CLI   INPUT@(R5),C'9'     IS IT A DIGIT ?                              
         BH    READRE8             IF NOT,DO BRANCH                             
         B     READRE7             LOOP                                         
READRE8  CLI   INPUT@(R5),C'.'     IS THE CURRENT CHARACTER A DECIMAL           
*                                  POINT                                        
         BNE   READR011            IF NOT,DO BRANCH                             
*        READ FRACTION                                                          
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         CLI   INPUT@(R5),C'0'     IS IT A DIGIT ?                              
         BL    READREE1            IF NOT,ERROR MESSAGE                         
READRE9  CLI   INPUT@(R5),C'9'     IS IT A DIGIT ?                              
         BH    READREE1            IF NOT,ERROR MESSAGE                         
READRE11 C     R2,MAX10            NUMBER LOWER THAN MAX10 ?                    
         BNL   READRE10            IF NOT,DO BRANCH                             
         MH    R2,=H'10'           NUMBER<---NUMBER*10                          
         LA    R6,0                R6<---0                                      
         IC    R6,INPUT@(0,R5)     R6<----INPUT@                                
         SLL   R6,28               R6<---                                       
         SRL   R6,28                       INPUT@-C'0'                          
         AR    R2,R6               NUMBER<---NUMBER+DIGIT VALUE                 
         SH    R3,=H'1'            SCALE<---SCALE-1                             
READRE10 BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         CLI   INPUT@(R5),C'0'     IS IT A DIGIT ?                              
         BL    READR011            IF NOT,DO BRANCH                             
         CLI   INPUT@(R5),C'9'     IS IT A DIGIT ?                              
         BH    READR011            IF NOT,DO BRANCH                             
         B     READRE11            IF YES,DO LOOP                               
READR011 CLI   INPUT@(R5),C'E'     IS CURRENT INPUT CHARACTER A 'E' ?           
         BNE   READRE12            IF NOT,DO BRANCH                             
*        READ EXPONENT                                                          
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         CLI   INPUT@(R5),C'-'     IS IT A '-' ?                                
         BNE   READRE13            IF NOT,DO BRANCH                             
         MVI   REXPSIGN,X'FF'      IF YES,SET REXPSIGN TO ON                    
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         B     READR014            PROCEED                                      
READRE13 CLI   INPUT@(R5),C'+'     IS IT A '+' ?                                
         BNE   READR014            IF NOT,DO BRANCH                             
         BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
READR014 CLI   INPUT@(R5),C'0'     IS IT A DIGIT ?                              
         BL    READREE1            IF NOT,ERROR MESSAGE                         
         CLI   INPUT@(R5),C'9'     IS IT A DIGIT ?                              
         BH    READREE1            IF NOT,ERROR MESSAGE                         
READRE17 C     R4,MAX10            EXPONENT LOWER THAN MAX10 ?                  
         BNL   READRE15            IF NOT,DO BRANCH                             
         MH    R4,=H'10'           EXPONENT<---EXPONENT*10                      
         LA    R6,0                R6<---0                                      
         IC    R6,INPUT@(R5)       R6<---INPUT@                                 
         SLL   R6,28               R6<---                                       
         SRL   R6,28                       INPUT - C'0'                         
         AR    R4,R6               EXPONENT<---EXPONENT+DIGIT VALUE             
READRE15 BAL   LINKREG,NEXTCH      READ NEXT INPUT CHARACTER                    
         CLI   INPUT@(R5),C'0'     IS IT A DIGIT ?                              
         BL    READRE16            IF NOT,DO BRANCH                             
         CLI   INPUT@(R5),C'9'     IS IT A DIGIT ?                              
         BH    READRE16            IF NOT,DO BRANCH                             
         B     READRE17            IF YES,DO LOOP                               
READRE16 CLI   REXPSIGN,X'FF'      IS THE EXPONENT SIGN NEGATIVE ?              
         BNE   READRE12            IF NOT,DO BRANCH                             
         LCR   R4,R4               EXPONENT<--- -EXPONENT                       
READRE12 ST    R2,FLOATI           PREPARE INPUT FOR FLOAT ROUTINE              
*                                  OF THE NUMBER)                               
         SRL   R6,2                                                             
         BAL   LINKREG,FLOAT       FLOAT NUMBER VALUE                           
         ST    R2,TENINTOI         PREPARE INPUT FOR TENINTO ROUTINE            
         BAL   LINKREG,TENINTO     CALCULATE THE ORDER OF MAGNITUDE OF          
*                                  NUMBER                                       
         L     R6,TENINTOI         R6<---ORDER OF MAGNITUDE OF NUMBER           
         MH    R6,=H'2'            R6<---R6*2                                   
         ST    R6,RAUX             RAUX<---R6                                   
         LA    R6,156              R6<---156                                    
         S     R6,RAUX             R6<---156-2*(ORDER OF MAGNITUDE              
         SLL   R6,2                                                             
         A     R6,=A(POWERS)       R6 POINTS TO APPROPRIATE ENTRY IN            
*                                  POWERS TABLE                                 
         MD    FPR,0(0,R6)         FPR<---FPR*(INPUT VALUE)                     
         AR    R3,R4               SCALE<---SCALE+EXPONENT                      
         A     R3,TENINTOI         SCALE<---SCALE+ORDER OF MAGNITUDE            
*                                  OF NUMBER                                    
         STE   FPR,RAUX            KEEP SHORT FPR AT RAUX                       
         L     R2,RAUX             NUMBER<---SHORT FPR                          
         C     R3,=A(0)            SCALE=0 ?                                    
         BE    READRE20            IF YES,DO BRANCH                             
         C     R3,=F'-78'          SCALE<= -78 ?                                
         BH    READRE14            IF NOT,DO BRANCH                             
         BL    READRE24                                                         
         C     R2,MINMANTS         R2<MINMANTS ?                                
         BNL   READRE14            IF NOT,DO BRANCH                             
READRE24 SER   FPR,FPR             SUBTRACT NORMALIZED SHORT                    
         B     READRE20            PROCEED                                      
READRE14 C     R3,=F'75'           R3>=75 ?                                     
         BL    READRE19            IF NOT,DO BRANCH                             
         BH    READRE23                                                         
         C     R2,MAXMANTS         NUMBER> MAXMANTS ?                           
         BNH   READRE19            IF NOT,DO BRANCH                             
READRE23 BAL   LINKREG,ERROR       IF SO, ISSUE AN ERROR MESSAGE                
         DC    AL1(L'READRE18)     ERROR MESSAGE PREFIX                         
READRE18 DC    C'WHILE READING REAL CONSTANT -- VALUE OUT OF RANGE'             
         B     READRE20            PROCEED                                      
READRE19 MH    R3,=H'2'            SCALE<---SCALE*2                             
         AH    R3,=H'156'          SCALE<---SCALE+156                           
         SLL   R3,2                                                             
         A     R3,=A(POWERS)       R3<---R3+A(POWERS)                           
         MD    FPR,0(0,R3)                                                      
READRE20 CLI   RSIGN,X'FF'         IS THE NUMBER NEGATIVE ?                     
         BNE   READRE21            IF NOT,DO BRANCH                             
         LCER  FPR,FPR             FPR<--- -FPR                                 
READRE21 SRVRTNED                                                               
         SPACE 5                                                                
RSIGN    DS    X                   MANTISSA SIGN.IF POSITIVE X'00'              
REXPSIGN DS    X                   EXPONENT SIGN.IF POSITIVE,X'00'              
RAUX     DS    F                   AUXILIARY                                    
MAXMANTS DC    X'40B9446F'                                                      
MINMANTS DC    X'408A2DC0'                                                      
         SPACE 5                                                                
READREE1 BAL   LINKREG,ERROR       BRANCH TO ERROR ROUTINE                      
         DC    AL1(L'READRE22)     ERROR MESSAGE PREFIX                         
READRE22 DC    C'WHILE READING REAL CONSTANT -- DIGIT EXPECTED'                 
         EJECT                                                                  
*                                                                               
*        ROUTINE FLOAT                                                          
*                                                                               
*        PURPOSE : CONVERT TO FLOATING POINT A FIXED PINT VALUE                 
*                                                                               
*        INPUT : FULLWORD AT LOCATION FLOATI CONTAINING FIXED POINT             
*        VALUE                                                                  
*        OUTPUT : FPR - FLOATING POINT REGISTER 6                               
*                                                                               
         SPACE 5                                                                
FLOAT    MVC   FWORK2,FLOATI       FWORK2<---FLOATI                             
         LD    FPR,FWORK           FPR<---WORK.LONG (8 BYTES )                  
*                                  OPERATION                                    
         AD    FPR,FZERO           ADD ZERO IN ORDER TO NORMALIZE               
         BR    LINKREG             RETURN TO CALLER                             
         SPACE 3                                                                
FLOATI   DS    F                   INPUT VALUE                                  
FZERO    DC      D'0'              FLOATING POINT ZERO                          
FWORK    DS    0D                                                               
FWORK1   DC    X'4E000000'                                                      
FWORK2   DC    A(0)                                                             
         EJECT                                                                  
*                                                                               
*        ROUTINE TENINTO                                                        
*                                                                               
*        PURPOSE : FIND THE ORDER OF MAGNITUDE OF A GIVEN FIXED POINT           
*        VALUE                                                                  
*        INPUT : A FULLWORD AT LOCATION TENINTOI CONTAINING POSITIVE            
*        VALUE                                                                  
*        OUTPUT : SAME LOCATION AS INPUT                                        
*                                                                               
         SPACE 5                                                                
TENINTO  STM   R2,R4,TENINTOR      KEEP REGISTERS                               
         L     R3,TENINTOI         LOAD GIVEN VALUE INTO R3                     
         LA    R4,0                LOOP COUNTER                                 
TENINTO2 C     R3,=A(0)            ZERO QUATIENT REACHED ?                      
         BE    TENINTO1            IF YES,DO BRANCH                             
         LA    R2,0                 R2<---0                                     
         D     R2,=A(10)           DIVIDE VALUE BY 10                           
         LA    R4,1(0,R4)          R4<---R4+1                                   
         B     TENINTO2            LOOP                                         
TENINTO1 ST    R4,TENINTOI                                                      
         LM    R2,R4,TENINTOR      RESTORE REGISTERS                            
         BR    LINKREG             RETURN TO CALLER                             
         SPACE 3                                                                
TENINTOI DS    F                   INPUT/OUTPUT VALUE                           
TENINTOR DS    3F                  REGISTERS' SAVE AREA                         
         EJECT                                                                  
*                                                                               
*        CASE 23 --- READ_CHAR                                                  
*                                                                               
         SPACE 5                                                                
READCHAR DS    0H                  DO;                                          
         CHKFILE INPUT                                                          
         L     R2,PR14                RETURNS = INPUT@;                         
         SR    R9,R9                                                            
         IC    R9,INPUT@(0,R2)                                                  
         BAL   LINKREG,NEXTCH         CALL NEXTCH;                              
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 24 --- WRITE_INT                                                  
*                                                                               
         SPACE 5                                                                
WRITEINT DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         LR    R1,R8                  /* R1<---NUMBER */                        
         L     R2,PR14                                                          
         L     R2,INTFLDSZ(0,R2)      /* R2<---INTFIELDSIZE */                  
         BAL   LINKREG,IFORMAT        OUT_LINE =                                
         LR    R2,R1                     OUT_LINE ||                            
         L     R1,OUTLINEP                  I_FORMAT(NUMBER,                    
         BAL   LINKREG,CATENATE                INTFIELDSIZE);                   
         ST    R1,OUTLINEP                                                      
         LR    R2,R1                  OUTPUT@ =                                 
         SRDL  R2,24                     BYTE(OUT_LINE,                         
         SRL   R3,8                         LENGTH(OUT_LINE) - 1);              
         LA    R3,0(R2,R3)                                                      
         L     R2,PR14                                                          
         MVC   OUTPUT@(1,R2),0(R3)                                              
         SRVRTNED  ,               END;                                         
         SPACE 3                                                                
INTFLDSZ EQU   32                  DISPLACEMENT OF INTFIELDSIZE IN              
*                                  GLOBAL ACTIVATION RECORD                     
         EJECT                                                                  
*                                                                               
*        CASE 25 --- WRITE_REAL                                                 
*                                                                               
         SPACE 5                                                                
WRITREAL DS    0H                                                               
         CHKFILE OUTPUT                                                         
         STE   FPR,FPRSAVER        SAVE FPR.                                    
         L     R1,PR14                                                          
         L     R1,RLFLDSZ(0,R1)    REALFIELDSIZE.                               
         STC   R1,RWIDTH           PREPARE INPUT FOR EFORMAT.                   
         STE   FPR,RNUMBER         PREPARE INPUT FOR EFORMAT.                   
         BAL   LINKREG,EFORMAT     FORMAT THE REAL VALUE                        
         LE    FPR,FPRSAVER        RESTORE FPR.                                 
         SR    R2,R2               CLEAR R2.                                    
         IC    R2,RWIDTH           REALFIELDSIZE.                               
         BCTR  R2,0                REALFIELDSIZE - 1.                           
         SLL   R2,24               SHIFT TO HIGH ORDER BYTE.                    
         O     R2,=A(EFORS)        FORM DESCRIPTOR.                             
         L     R1,OUTLINEP         DESCRIPTOR OF CURRENT LINE.                  
         BAL   LINKREG,CATENATE    CONCATENATE REAL NUMBER ONTO LINE.           
         ST    R1,OUTLINEP         SAVE UPDATED DESCRIPTOR.                     
         LR    R2,R1               OUTPUT@ =                                    
         SRDL  R2,24                  BYTE(OUT_LINE,                            
         SRL   R3,8                      LENGTH(OUT_LINE) - 1);                 
         LA    R3,0(R2,R3)                                                      
         L     R2,PR14                                                          
         MVC   OUTPUT@(1,R2),0(R3)                                              
         SRVRTNED                                                               
         SPACE 3                                                                
RLFLDSZ  EQU   40                  DISPLACEMENT OF REALFIELDSIZE IN             
*                                  GLOBAL ACTIVATION RECORD.                    
FPRSAVER DS    F                   FPR SAVE AREA                                
RNUMBER  DS    F                   REAL NUMBER                                  
RWIDTH   DS    X                                                                
         EJECT                                                                  
*                                                                               
*        ROUTINE EFORMAT                                                        
*                                                                               
*        PURPOSE : FORMATTING OF REAL NUMBER                                    
*                                                                               
*        INPUT : REAL NUMBER AT LOCATION RNUMBER                                
*                LENGTH OF FORMAT AT LOCATION RWIDTH                            
*                                                                               
*        OUTPUT : FORMAT AT LOCATION EFORS                                      
*                 END OF FORMAT POINTED BY EFORSP                               
*                                                                               
EFORMAT  STM   R2,R4,EFORR         KEEP REGISTERS                               
*        MINIMUM FIELD IS '+9.9E+99'                                            
         CLC   RWIDTH,=X'9'        RWIDTH<9 ?                                   
         BNL   EFOR1               IF NOT,DO BRANCH                             
         LA    R2,9                R2<---9                                      
         STC   R2,RWIDTH           RWIDTH<---9                                  
         B     EFOR2               PROCEED                                      
EFOR1    CLC   RWIDTH,=FL1'14'     RWIDTH>14 ?                                  
         BNH   EFOR2               IF NOT,DO BRANCH                             
         LA    R2,0                R2<---0                                      
         IC    R2,RWIDTH           R2<---RWIDTH                                 
         SH    R2,=H'13'           R2<---R2-13                                  
         LA    R3,EFORS            R3<---EFORS                                  
         AR    R3,R2               R3<---R3+R2                                  
         ST    R3,EFORSP           UPDATE EFORS POINTER                         
         BCTR  R2,0                R2<---R2-1                                   
         EX    R2,EFORM            BLANK EFORS                                  
         MVI   RWIDTH,14           RWIDTH<---14                                 
         B     EFOR3               PROCEED                                      
EFOR2    LA    R2,EFORS            R2 POINTS TO EFORS                           
         LA    R2,1(0,R2)          R2<---R2+1                                   
         ST    R2,EFORSP           UPDATE EFORS POINTER                         
         MVI   EFORS,C' '          BLANK FIRST LOCATION OF EFORS                
EFOR3    TM    RNUMBER,X'80'       IS THE REAL NUMBER NEGATIVE ?                
         BNO   EFOR4               IF NOT,DO BRANCH                             
         L     R2,EFORSP           R2 POINTS TO EFORS                           
         MVI   0(R2),C'-'          MOVE '-' INTO FIRST VACANT LOCATION          
*                                  EFORS                                        
         LA    R2,1(0,R2)          R2<---R2+1                                   
         ST    R2,EFORSP           KEEP EFORS POINTER                           
         L     R2,RNUMBER          R2 CONTAINS THE REAL NUMBER                  
         N     R2,EFORAUX1         ZERO MOST SIGNIFICANT BIT IN R2              
         ST    R2,RNUMBER          RNUMBER CONTAINS ABSOLUTE VALUE OF           
*                                  REAL NUMBER                                  
         B     EFOR5               PROCEED                                      
EFOR4    L     R2,EFORSP           R2 POINTS TO THE FIRST VACANT                
*                                  LOCATION IN EFORS                            
         MVI   0(R2),C' '          SET A BLANK INTO THIS LOCATION               
         LA    R2,1(0,R2)          R2<---R2+1                                   
         ST    R2,EFORSP           UPDATE EFORS POINTER                         
EFOR5    L     R2,RNUMBER          R2 CONTAINS ABSOLUTE REAL NUMBER             
         LA    R4,0(0,R2)          R4<---R2 & "00FFFFFF"                        
         LTR   R4,R4                                                            
         BNE   EFOR6               IF NOT,DO BRANCH                             
         L     R2,EFORSP           R2 POINTS TO FIRST VACANT LOC IN             
*                                  EFORS                                        
         LA    R3,0                R3<---0                                      
         IC    R3,RWIDTH           R3<---RWIDTH                                 
         SH    R3,=H'6'            R3<---R3-6                                   
         BCTR  R3,0                R3<---R3-1                                   
         EX    R3,EFORM1                                                        
         LA    R3,1(0,R3)          RESTORE VALUE OF R3                          
         AR    R2,R3                                                            
         MVC   0(4,R2),=C'E+00'                                                 
         LA    R2,4(0,R2)                                                       
         ST    R2,EFORSP           UPDATE EFORSP POINTER                        
         B     EFORF                                                            
EFOR6    LA    R3,POWERS+14*4                                                   
         C     R2,0(0,R3)          COMPARE REAL NUMBER VALUE WITH THE           
*                                  ENTRY IN POWERS TABLE                        
         BNL   EFOR7               IF NOT EQUAL , DO BRANCH                     
         LE    FPR,RNUMBER         FPR<---RNUMBER                               
         LA    R3,POWERS+0*4       R3 POINTS TO FIRST ENTRY IN POWERS           
*                                  TABLE                                        
         DE    FPR,0(0,R3)         DIVIDE SHORT                                 
         STE   FPR,RNUMBER         RNUMBER<---FPR                               
         MVC   EFOREXP,=FL2'-78'                                                
         B     EFOR8               PROCEED                                      
EFOR7    MVC   EFOREXP,=AL2(0)                                                  
EFOR8    MVC   EFORI,=AL2(0)      EFORI<---0                                    
         MVC   EFORJ,=AL2(306)     EFORJ<---306                                 
         MVC   EFORX,=AL2(152)     EFORX<---152                                 
EFOR16   CLC   EFORI,EFORJ         EFORI>EFORJ ?                                
         BH    EFOR9               IF YES,DO BRANCH                             
         LH    R3,EFORX            R3<---EFORX                                  
         SLL   R3,2                R3<---R3*4                                   
         A     R3,=A(POWERS)       R3 POINTS TO APPROPRIATE ENTRY IN            
*                                  POWERS TABLE                                 
         CLC   0(4,R3),RNUMBER     POWERS ENTRY>RNUMBER ?                       
         BH    EFOR10              IF YES,DO BRANCH                             
         LH    R3,EFORX            R3<---EFORX                                  
         AH    R3,=H'2'            R3<---R3*2                                   
         STH   R3,EFORI            KEEP EFORI                                   
         B     EFOR11              PROCEED                                      
EFOR10   LH    R3,EFORX            R3<---EFORX                                  
         SH    R3,=H'2'            R3<---R3-2                                   
         STH   R3,EFORJ            EFORJ<---R3                                  
EFOR11   LH    R3,EFORI            R3<---EFORI                                  
         AH    R3,EFORJ            R3<---R3+RFORJ                               
         SRL   R3,1                R3<---R3/2                                   
         N     R3,EFORCONS         ZERO LEFTMOST HALF OF R3                     
         STH   R3,EFORX            EFORX<---R3                                  
         B     EFOR16              LOOP                                         
EFOR9    LE    FPR,RNUMBER         FPR<---RNUMBER                               
         LH    R3,EFORX            R3<---EFORX                                  
         SH    R3,=H'14'           R3<---R3-14                                  
         SLL   R3,2                R3<---R3*4                                   
         A     R3,=A(POWERS)       R3 POINTS TO POWERS ENTRY                    
         DE    FPR,0(0,R3)         DIVIDE SHORT                                 
         STE   FPR,DIVQUO          DIVQUO<---FPR                                
         SDR   FPR,FPR             DOUBLE FPR<---0                              
         LE    FPR,DIVQUO          FPR<---DIVQUO                                
         AE    FPR,HALF            FPR<---FPR+HALF (ROUND)                      
         AW    FPR,RZERO           DOUBLE FPR<---DOUBLE FPR+RZERO               
         STD   FPR,RWORK           RWORK<---DOUBLE FPR                          
         MVC   EFORMANT,RWORK+4    EFORMANT<---RIGHT PART OF DOUBLE FPR         
         LH    R3,EFORX            R3<---EFORX                                  
         SRL   R3,1                R3<---R3/2                                   
         SH    R3,=H'78'           R3<---R3-78                                  
         AH    R3,EFOREXP          R3<---R3+EFOREXP                             
         STH   R3,EFOREXP          EFOREXP<---R3                                
         MVI   EFORS1,C' '         EFORS1<---' '                                
         MVC   EFORS1+1(21),EFORS1 BLANK EFORS1                                 
         L     R3,EFORMANT         R3<---EFORMANT                               
         C     R3,=F'9999999'      < 8 DIGITS?                                  
         BH    EFOR13              NO, SO BRANCH                                
         LH    R3,EFOREXP          YES, SO SET EXP = EXP - 1                    
         BCTR  R3,0                                                             
         STH   R3,EFOREXP                                                       
         B     EFOR13A                                                          
EFOR13   C     R3,=F'99999999'     > 8 DIGITS?                                  
         BNH   EFOR13A             NO, SO BRANCH                                
         LH    R3,EFOREXP          YES, SO SET EXP = EXP + 1                    
         LA    R3,1(0,R3)                                                       
         STH   R3,EFOREXP                                                       
EFOR13A  L     R3,EFORMANT         R3<---MANTISSA                               
         CVD   R3,EFORD            CONVERT R3 TO DECIMAL                        
         MVC   EFORS1(10),EFORMPAT                                              
         LA    R1,EFORS1+2                                                      
         EDMK  EFORS1(10),EFORD+3                                               
         MVC   EFORS+2(1),0(R1)                                                 
         MVI   EFORS+3,C'.'                                                     
         LA    R3,0                R3<---0                                      
         IC    R3,RWIDTH           R3<---RWIDTH                                 
         SH    R3,=H'8'            R3<---R3-8                                   
         L     R4,EFORSP           R4<---EFORSP                                 
         AR    R4,R3               R4<---R4+R3                                  
         LA    R4,2(0,R4)          R4<---R4+2                                   
         ST    R4,EFORSP           UPDATE EFORSP                                
         BCTR  R3,0                R3<---R3-1                                   
         EX    R3,EFORMVC2                                                      
         L     R3,EFORSP           R3<---EFORSP                                 
         MVI   0(R3),C'E'                                                       
         LH    R4,EFOREXP          R4<---EFOREXP                                
         TM    EFOREXP,X'80'       IS LEFTMOST BIT A ONE ?                      
         BO    EFOR14              IF YES,DO BRANCH                             
         MVI   1(R3),C'+'                                                       
         B     EFOR15              PROCEED                                      
EFOR14   MVI   1(R3),C'-'                                                       
         LCR   R4,R4               COMPLEMENT R4                                
EFOR15   CVD   R4,EFORD            CONVERT R4 TO DECIMAL                        
         MVC   EFORS1(4),EFORPAT1  PREPARE EDIT PATTERN                         
         EDMK  EFORS1(4),EFORD+6   EDIT !                                       
         MVC   2(2,R3),EFORS1+2                                                 
         LA    R3,4(0,R3)          R3<---R3+4                                   
         ST    R3,EFORSP           UPDATE EFORSP                                
EFORF    LM    R2,R4,EFORR         RESTORE REGISTERS                            
         BR    LINKREG             RETURN TO CALLER                             
         SPACE 5                                                                
EFOREXP  DS    H                   EXPONENT OF REAL NUMBER                      
EFORZERO DC    C'0.0000000'                                                     
MAXINT   DS    0F                                                               
EFORAUX1 DS    0F                                                               
         DC    X'7FFFFFFF'         ALL ONE'S EXCEPT FOR THE LEFTMOST            
EFORX70  DC    CL70' '             BLANK CONSTANT                               
EFORSP   DC    A(EFORS)            EFORS POINTER                                
EFORS    DS    CL70                OUTPUT PARAMETER                             
EFORR    DS    3F                  REGISTERS' SAVE AREA                         
EFORI    DS    H                   AUXILIARY VARIABLE                           
EFORJ    DS    H                   AUXILIARY VARIABL                            
EFORX    DS    H                   AUXILIARY VARIABL                            
EFORCONS DS    0F                                                               
         DC    X'0000FFFE'                                                      
EFORMANT DS    F                   MANTISSA OF THE REAL NUMBER                  
EFORMPAT DC    X'40',9X'20'                                                     
EFORS1   DS    CL22                                                             
EFORD    DS    D                                                                
EFORPAT1 DC    X'40',X'21',2X'20'                                               
RWORK    DS    D                                                                
RZERO    DS    0D                                                               
         DC    X'4E000000',A(0)                                                 
HALF     DC    E'0.5'              FLOATING POINT HALF                          
DIVQUO   DS    E                                                                
EFORMVC2 MVC   EFORS+4(0),1(R1)                                                 
EFORM    MVC   EFORS(0),EFORX70    BLANK EFORS                                  
EFORM1   MVC   0(0,R2),EFORZERO                                                 
         EJECT                                                                  
*                                                                               
*        CASE 26 --- WRITE_BOOL                                                 
*                                                                               
         SPACE 5                                                                
WRITBOOL DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         LR    R1,R8                  /* R1<---BOOL_VALUE */                    
         L     R2,PR14                                                          
         L     R2,BOOLFLDS(0,R2)      /* R2<---BOOLFIELDSIZE */                 
         BAL   LINKREG,BFORMAT        OUT_LINE =                                
         LR    R2,R1                     OUT_LINE ||                            
         L     R1,OUTLINEP                  B_FORMAT(BOOL_VALUE,                
         BAL   LINKREG,CATENATE                BOOLFIELDSIZE);                  
         ST    R1,OUTLINEP                                                      
         LR    R2,R1                  OUTPUT@ =                                 
         SRDL  R2,24                     BYTE(OUT_LINE,                         
         SRL   R3,8                         LENGTH(OUT_LINE) - 1);              
         LA    R3,0(R2,R3)                                                      
         L     R2,PR14                                                          
         MVC   OUTPUT@(1,R2),0(R3)                                              
         SRVRTNED  ,               END;                                         
         SPACE 3                                                                
BOOLFLDS EQU   36                  /* DISPLACEMENT OF BOOLFIELDSIZE             
*                                     IN GLOBAL ACTIVATION RECORD */            
         EJECT                                                                  
*                                                                               
*        CASE 27 --- WRITE_CHAR                                                 
*                                                                               
         SPACE 5                                                                
WRITCHAR DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         STC   R8,WRCHR                                                         
         L     R2,WRCHRA                                                        
         L     R1,OUTLINEP                                                      
         BAL   LINKREG,CATENATE       OUT_LINE = OUT_LINE || CHAR;              
         ST    R1,OUTLINEP                                                      
         L     R2,PR14                                                          
         STC   R8,OUTPUT@(R2)         OUTPUT@ = BYTE(CHAR);                     
         SRVRTNED  ,               END;                                         
         SPACE 3                                                                
WRCHR    DS    CL1                 /* CHARACTER TO BE PRINTED */                
WRCHRA   DC    A(WRCHR)            /* DESCRIPTOR FOR WRCHR */                   
         EJECT                                                                  
*                                                                               
*        CASE 28 --- WRITE_STRING                                               
*                                                                               
         SPACE 5                                                                
WRITSTRG DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         LR    R2,R8                                                            
         L     R1,OUTLINEP            OUT_LINE =                                
         BAL   LINKREG,CATENATE          OUT_LINE || STRING;                    
         ST    R1,OUTLINEP                                                      
         LR    R2,R1                  OUTPUT@ =                                 
         SRDL  R2,24                     BYTE(OUT_LINE,                         
         SRL   R3,8                         LENGTH(OUT_LINE) - 1);              
         LA    R3,0(R2,R3)                                                      
         L     R2,PR14                                                          
         MVC   OUTPUT@(1,R2),0(R3)                                              
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 29 --- READLN                                                     
*                                                                               
         SPACE 5                                                                
READLN   DS    0H                  DO;                                          
         CHKFILE INPUT                                                          
         MVC   INPTR,=H'80'           IN_PTR = 80; /* SIGNALS EOLN */           
         BAL   LINKREG,NEXTCH         CALL NEXTCH;                              
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 30 --- WRITELN                                                    
*                                                                               
         SPACE 5                                                                
WRITELN  DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         BAL   LINKREG,PUTLN          OUTPUT(1) = OUT_LINE;                     
         MVI   OUTLINE,C' '           OUT_LINE = ' ';                           
         L     R1,PR14                OUTPUT@ = BYTE(' ');                      
         MVI   OUTPUT@(R1),C' '                                                 
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 31 --- PAGE                                                       
*                                                                               
         SPACE 5                                                                
PAGE     DS    0H                  DO;                                          
         CHKFILE OUTPUT                                                         
         BAL   LINKREG,PUTLN          OUTPUT(1) = OUT_LINE;                     
         MVI   OUTLINE,C'1'           OUT_LINE = '1';                           
         L     R1,PR14                OUTPUT@ = BYTE('1');                      
         MVI   OUTPUT@(R1),C'1'                                                 
         SRVRTNED  ,               END;                                         
         EJECT                                                                  
*                                                                               
*        CASE 32 --- RANGE_ERROR                                                
*                                                                               
         SPACE 5                                                                
RANGEERR DS    0H                  CALL ERROR(RANGE_ERROR);                     
         BAL   LINKREG,ERROR                                                    
         SPACE 3                                                                
         DC    AL1(L'RANGERRM)                                                  
RANGERRM DC    C'VALUE OUT OF RANGE'                                            
         EJECT                                                                  
*                                                                               
*        CASE 33 --- MEM_OVERFLOW                                               
*                                                                               
*                                                                               
         SPACE 5                                                                
MEMOVERF DS    0H                  DO;                                          
         L     R1,ORGORGN             ERROR_LINE = CODE_BASE_REGISTER;          
         L     R10,CBR(0,R1)                                                    
         BAL   LINKREG,ERROR          CALL ERROR(MEMORY_ERROR);                 
*                                  END;                                         
         SPACE 3                                                                
MEMERR   DC    AL1(L'MEMERRM)                                                   
MEMERRM  DC    C'RUN-TIME STORAGE OVERFLOW'                                     
CBR      EQU   ORGPSCLR+4          /* WHERE CODE BASE REGISTER IS SAVED         
*                                     IN THE ORG SEGMENT */                     
         EJECT                                                                  
*        CASE 34  FORM SUBRANGE MASK                                            
*                                                                               
*                                                                               
*        PURPOSE: FORMS A MASK (& RETURNS THE ADDRESS OF THAT MASK)             
*        WHICH, WHEN OD'D INTO A SET, INSERTS THE SUBRANGE INDICATED            
*        BY THE ARGUMENTS INTO THAT SET. THE MONITOR IS ONLY CALLED             
*        UPON TO DO THIS OPERATION WHEN THE STORAGE LENGTH OF THE SET           
*        IS GREATER THAN 64.                                                    
*                                                                               
*        USES REGS 4-9                                                          
MVCINS   MVC   0(0,R5),ONES                                                     
BITORD2  EQU   9                                                                
BITORD1  EQU   7                                                                
BYTEORD2 EQU   8                                                                
BYTEORD1 EQU   6                                                                
MASK     DS    64F                                                              
ONES     DC    64F'-1'                                                          
FIRSTBYT DC    X'FF7F3F1F0F070301'                                              
*                                                                               
RANGMASK XC    MASK(256),MASK      CLEAR THE MASK                               
         CR    R9,R8               COMPARE THE ARGUMENTS.  IF THE 1ST           
*        OPERAND IS LARGER, RETURN THE MASK AS IS. WHEN OR'D INTO A             
*        SET, IT WOULD ADD THE EMPTY SET.                                       
*                                                                               
         BH    RETURNMK                                                         
*                                                                               
*        FORM BIT & BYTE ORDINALITIES                                           
*                                                                               
         LR    BYTEORD1,R9                                                      
         SRDL  BYTEORD2,3          FORM ARG2 DIV 8                              
         SRL   BITORD2,29          FORM BITORD2 = ARG2 MOD 8                    
         SRDL  BYTEORD1,3          FORM BYTEORD1 = ARG1 DIV 8                   
         SRL   BITORD1,29          FORM BITORD1 = ARG1 MOD 8                    
*                                                                               
*        WE WANT TO MOVE (BYTEORD2 - BYTEORD1 + 1) BYTES OF ONES INTO           
*        THE MASK. EX A MVC INSTRUCTION WITH LENGTH CODE IN R4                  
*                                                                               
         LR    R4,BYTEORD2                                                      
         SR    R4,BYTEORD1                                                      
         LA    R5,MASK(BYTEORD1)                                                
         EX    R4,MVCINS           MOVE IN ONES STARTING AT                     
*                                  MASK(BYTEORD1)                               
*        NOW FILL IN FIRST & LAST BYTES                                         
         IC    R4,FIRSTBYT(BITORD1)                                             
         STC   R4,MASK(BYTEORD1)   MOVE IN FIRST BYTE                           
         IC    R4,MASK(BYTEORD2)   SET LAST BYTE, LEAVING BITS                  
         LCR   R5,BITORD2          ALREADY SET UNDISTURBED.                     
         SLL   R4,7(R5)                                                         
         STC   R4,MASK(BYTEORD2)                                                
RETURNMK L     R9,=A(MASK)         RETURN THE ADDRESS OF THE MASK               
         SRVRTNED                                                               
         EJECT                                                                  
*                                                                               
*   CASE 35 --- CLOCK                                                           
*                                                                               
*   RETURNS ELAPSED CPU TIME IN UNITS OF 0.01 SECONDS.                          
*                                                                               
         SPACE 5                                                                
CLOCK    TTIMER                                                                 
*                                                                               
*        THE TIME REMAINING (IN UNITS OF 26.04166 USEC) IS                      
*        IN REGISTER R0.                                                        
*                                                                               
         SRDL  R0,32               CONVERT TO UNITS OF 0.01 SEC.                
         LA    R9,384              CONVERSION FACTOR                            
         DR    R0,R9                                                            
*                                                                               
*        SUBTRACT THE REMAINING TIME FROM THE ORIGINAL TIMER LIMIT.             
*                                                                               
         L     R9,TIMELT           INITIAL TIMER LIMIT                          
         SR    R9,R1               ELAPSED TIME                                 
         SRVRTNED                                                               
         EJECT                                                                  
*                                                                               
*        L I T E R A L S                                                        
*                                                                               
         SPACE 5                                                                
         LTORG                                                                  
         EJECT                                                                  
*                                                                               
*        DSECT WHICH DEFINES THE LIST OF PARAMETERS PASSED BY THE               
*        OVERLAY MONITOR TO THE RUN MONITOR.                                    
*                                                                               
         SPACE 5                                                                
PARMS    DSECT                                                                  
         SPACE 1                                                                
LINKSAVE DS    A                   ADDRESS OF MONITOR_LINK.                     
         SPACE 1                                                                
INPUT0   DS    A                   ADDRESS OFDCB FOR THE INPUT FILE.            
         SPACE 1                                                                
OUTPUT0  DS    A                   ADDRESS OF DCB FOR THE OUTPUT FILE.          
         EJECT                                                                  
*                                                                               
*        DUMMY  DCB  FOR  DEFINING  DCB  FIELDS                                 
*                                                                               
         SPACE 5                                                                
         PRINT NOGEN                                                            
         DCBD  DSORG=QS,DEVD=DA                                                 
         EJECT                                                                  
*                                                                               
*        T H E   E N D                                                          
*                                                                               
         SPACE 5                                                                
         END RMONITOR                                                           
