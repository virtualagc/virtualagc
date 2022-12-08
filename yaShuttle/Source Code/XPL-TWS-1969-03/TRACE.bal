TRCR     TITLE 'TRACE ROUTINE FOR THE XPL COMPILER GENERATOR SYSTEM'            
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*              THIS PROGRAM PROVIDES A MACHINE LEVEL TRACE OF PROGRAM *         
*              EXECUTION.  IT IS ACTIVATED BY THE XPL STATEMENT:      *         
*                                                                     *         
*              CALL  TRACE ;                                          *         
*                                                                     *         
*              AND TERMINATED BY THE XPL STATEMENT:                   *         
*                                                                     *         
*              CALL UNTRACE ;                                         *         
*                                                                     *         
*              THIS ROUTINE PRINTS ONE LINE FOR EACH MACHINE LANGUAGE *         
*              INSTRUCTION EXECUTED.                                  *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*                                      DAVID B. WORTMAN               *         
*                                      STANFORD UNIVERSITY            *         
*                                      MARCH  1968                    *         
*                                                                     *         
***********************************************************************         
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              DEFINE  REGISTER  USAGE                                *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
SCR0     EQU   0                       SCRATCH REGISTER                         
         SPACE 1                                                                
SCR1     EQU   SCR0+1                  SCRATCH  REGISTER                        
         SPACE 1                                                                
SCR2     EQU   2                       SCRATCH  REGISTER                        
         SPACE 1                                                                
SCR3     EQU   3                       SCRATCH  REGISTER                        
         SPACE 1                                                                
FLDPT    EQU   3                       POINTER FOR PLINOP                       
         SPACE 1                                                                
INITLR   EQU   3                       BASE REGISTER FOR INITIALIZATION         
         SPACE 1                                                                
EXEC     EQU   4                       ADDRESS OF EXECUTE ROUTINE               
         SPACE 1                                                                
*              5                       (UNUSED)                                 
         SPACE 1                                                                
*              6                       (UNUSED)                                 
         SPACE 1                                                                
*              7                       (UNUSED)                                 
         SPACE 1                                                                
*              8                       (UNUSED)                                 
         SPACE 1                                                                
DATA     EQU   9                       BASE FOR DATA AREA                       
         SPACE 1                                                                
HEX2EBC  EQU   10                      ADDRESS OF CONVERT ROUTINE               
         SPACE 1                                                                
ILCR     EQU   11                      PSEUDO LOCATION COUNTER                  
         SPACE 1                                                                
CBR      EQU   12                      SUBMONITOR BRANCH REGISTER               
         SPACE 1                                                                
BRFROM   EQU   12                      BRANCH REGISTER                          
         SPACE 1                                                                
OSAVE    EQU   13                      ADDRESS OF OS SAVE AREA                  
         SPACE 1                                                                
*              14                      OS                                       
         SPACE 1                                                                
SELF     EQU   15                      ADDRESS OF XPL SUBMONITOR                
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              SPECIFY LENGTH OF PRINTED LINE                         *         
*                                                                     *         
*              THE VALUE OF 'LPL' SHOULD NOT BE CHANGED WITHOUT       *         
*              CAREFULLY CONSIDERING THE ORGANIZATION OF THE          *         
*              PRINTED OUTPUT.                                        *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
LPL      EQU   132                     LENGTH OF THE PRINT LINE                 
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              DEFINE SERVICE CODES USED TO COMMUNICATE WITH THE      *         
*              XPL SUBMONITOR                                         *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PRNT     EQU   8                       SERVICE CODE FOR PRINTING                
         SPACE 1                                                                
TRACEC   EQU   12                      SERVICE CODE TO BEGIN TRACING            
         SPACE 1                                                                
UNTRACE  EQU   16                      SERVICE CODE TO END TRACING              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              DEFINE REGISTERS USED TO PASS PARAMETERS TO THE        *         
*              XPL SUBMONITOR                                         *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PR1      EQU   0                       1ST PARAMETER REGISTER                   
         SPACE 1                                                                
PR2      EQU   1                       2ND PARAMETER REGISTER                   
         SPACE 1                                                                
SVCR     EQU   1                       SERVICE CODE REGISTER                    
         SPACE 1                                                                
PR3      EQU   2                       3RD PARAMETER REGISTER                   
         SPACE 1                                                                
SMBR     EQU   12                      RETURN ADDRESS REGISTER                  
*                                      FOR SUBMONITOR CALLS                     
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              DEFINE FLAG BITS USED THROUGHOUT THE TRACE PACKAGE     *         
*              TO SPECIFY THE ATTRIBUTES OF THE MACHINE INSTRUCTIONS  *         
*                                                                     *         
*                                                                     *         
*              FOR EACH MACHINE LANGUAGE INSTRUCTION BEING CONSIDERED *         
*              BY THE TRACE ROUTINE, A HALF WORD OF ATTRIBUTE         *         
*              INFORMATION IS STORED IN THE LOCATION 'FLAGS'.         *         
*              THIS INFORMATION DETERMINES THE WAY IN WHICH           *         
*              THE TRACE ROUTINE HANDLES THE INSTRUCTION              *         
*                                                                     *         
*                                                                     *         
*              ATTRIBUTES WHICH MAY OCCUR IN THE FIRST BYTE           *         
*              OF 'FLAGS'                                             *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
ILGLBIT  EQU   B'10000000'             ILLEGAL INSTRUCTION                      
         SPACE 1                                                                
CCBIT    EQU   B'01000000'             INSTRUCTION SETS CONDITION CODE          
         SPACE 1                                                                
BRBIT    EQU   B'00100000'             INSTRUCTION IS BRANCH OR EXECUTE         
         SPACE 1                                                                
HALFBIT  EQU   B'00010000'             HALF WORD INSTRUCTION                    
         SPACE 1                                                                
FULLBIT  EQU   B'00001000'             FULL WORD INSTRUCTION                    
         SPACE 1                                                                
DBLBIT   EQU   B'00000100'             DOUBLE WORD INSTRUCTION                  
         SPACE 1                                                                
FLOATBIT EQU   B'00000010'             FLOATING POINT INSTRUCTION               
         SPACE 1                                                                
SHIFTBIT EQU   B'00000001'             SHIFT INSTRUCTION                        
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              ATTRIBUTES WHICH MAY OCCUR IN THE SECOND BYTE          *         
*              OF 'FLAGS'                                             *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
RRBIT    EQU   B'10000000'             TYPE RR INSTRUCTION                      
         SPACE 1                                                                
RXBIT    EQU   B'01000000'             TYPE RX INSTRUCTION                      
         SPACE 1                                                                
RSBIT    EQU   B'00100000'             TYPE RS INSTRUCTION                      
         SPACE 1                                                                
SIBIT    EQU   B'00010000'             TYPE SI INSTRUCTION                      
         SPACE 1                                                                
SSBIT    EQU   B'00001000'             TYPE SS INSTRUCTION                      
         SPACE 1                                                                
IMDFBIT  EQU   B'00000100'             INSTRUCTION CONTAINS 8-BIT               
*                                      IMMEDIATE FIELD                          
         SPACE 1                                                                
LMSTMBIT EQU   B'00000010'             INSTRUCTION IS LM OR STM                 
         SPACE 1                                                                
EXBIT    EQU   B'00000001'             INSTRUCTION IS EXECUTE (EX)              
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              TRACE ROUTINE INITIALIZATION                           *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*              WHEN THE TRACE ROUTINE IS CALLED BY THE XPL SUBMONITOR *         
*              THE GENERAL REGISTERS SHOULD CONTAIN:                  *         
*                                                                     *         
*                                                                     *         
*        R0    ADDRESS OF THE PARAMETER FIELD OF THE EXECUTE CARD     *         
*              AS PASSED TO THE SUBMONITOR BY OS/360                  *         
*              (UNUSED IN THIS VERSION OF THE TRACE ROUTINE)          *         
*                                                                     *         
*        R1    ADDRESS OF THE BLOCK WHERE R0 - R15 WERE SAVED PRIOR   *         
*              TO THE CALL OF THE TRACE ROUTINE                       *         
*                                                                     *         
*              F0-F6 ARE ASSUMED TO BE IN PLACE                       *         
*                                                                     *         
*        R2    ADDRESS AT WHICH TRACED EXECUTION SHOULD BEGIN         *         
*                                                                     *         
*        R3    ADDRESS OF THE TRACE ROUTINE ENTRY POINT  'TRACE'      *         
*                                                                     *         
*        R4    ADDRESS OF THE EXECUTE ROUTINE IN THE SUBMONITOR       *         
*                                                                     *         
*        R13   ADDRESS OF THE SUBMONITORS OS SAVE AREA                *         
*                                                                     *         
*        R15   ADDRESS OF THE ENTRY POINT TO THE XPL SUBMONITOR       *         
*                                                                     *         
*              NOTE THAT THE TRACE ROUTINE CRITICALLY DEPENDS ON THE  *         
*              CONDITION THAT THE XPL PROGRAM BEING TRACED DOES NOT   *         
*              CHANGE THE CONTENTS OF REGISTER 15.  THIS REGISTER IS  *         
*              NEEDED TO MAINTAIN ADDRESSABILITY OF THE EXECUTE       *         
*              ROUTINE IN THE SUBMONITOR                              *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*              NOTE THAT TRACE CANNOT USE THE SAVE AREA OF THE        *         
*              CALLING PROGRAM (XPLSM) SINCE IT MAY ENTER XPLSM       *         
*              RECURSIVELY AND CAUSE OS ROUTINES TO ALSO USE XPLSM'S  *         
*              SAVE AREA.  NOTE FURTHER THAT TRACE DOES NOT NEED AN   *         
*              OS SAVE AREA SINCE IT DOES NOT CALL ANY EXTERNAL       *         
*              ROUTINES EXCEPT XPLSM.                                 *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
TRACEP   CSECT                                                                  
         SPACE 2                                                                
         ENTRY TRACE                   ENTRY TO THE TRACE ROUTINE               
         SPACE 2                                                                
         USING *,INITLR                                                         
         SPACE 1                                                                
TRACE    DS    0H                                                               
         SPACE 1                                                                
         B     TRACEB                                                           
         DC    AL1(6)                  CSECT IDENTIFIER                         
         DC    CL6'TRACE '                                                      
         SPACE 1                                                                
TRACEB   STM   0,15,SAVE               SAVE ALL REGISTERS                       
         LA    OSAVE,SAVE              BASE ADDRESS                             
         USING SAVE,OSAVE                                                       
         B     BEGN                                                             
         DROP  INITLR                                                           
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              SAVE  AREA                                             *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
SAVE     DC    16F'0'                  SAVE AREA                                
ADATA    DC    A(DATAREA)              ADDRESS OF TRACE ROUTINE DATA            
AHEX     DC    A(HEXTOEBC)             ADDRESS OF CONVERT ROUTINE               
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  HEXTOEBC    BINARY TO EBCDIC CONVERSION ROUTINE                    *         
*                                                                     *         
*                                                                     *         
*              CONVERTS THE WORD IN SCR0 INTO 8 EBCDIC HEX            *         
*              CHARACTERS SUITABLE FOR PRINTING                       *         
*              RETURNS THE 8 CHARACTERS IN SCR0,SCR1                  *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         USING *,HEX2EBC                                                        
HEXTOEBC ST    SCR0,HEXTABLE+16        STORE THE WORD TO BE CONVERTED           
         L     SCR1,HEXTABLE-4         NORMALIZED ADDRESS OF CONVERT            
*                                      TABLE                                    
         UNPK  HEXTABLE+16(9),HEXTABLE+16(5)                                    
*                                      SPREAD THE HEX DIGITS                    
         TR    HEXTABLE+16(8),0(1)     TRANSLATE DIGITS TO                      
*                                      CORRESPONDING CHARACTERS                 
         LM    SCR0,SCR1,HEXTABLE+16   LOAD RESULT                              
         BR    BRFROM                  RETURN                                   
         DROP  HEX2EBC                                                          
         SPACE 1                                                                
         DC    A(HEXTABLE-240)         NORMALIZED ADDRESS CONSTANT              
HEXTABLE DC    CL25'0123456789ABCDEF'                                           
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  BEGN        INITIALIZATION OF THE TRACE ROUTINE                    *         
*                                                                     *         
*              THE PARAMETERS PASSED TO THE TRACE ROUTINE ARE         *         
*              DESCRIBED IN THE COMMENT ABOVE                         *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BEGN     L     DATA,ADATA              ADDRESS OF THE DATA AREA                 
         USING DATAREA,DATA                                                     
         ST    SELF,AENTRY             SAVE ADDRESS OF THE SUBMONITOR           
*                                      ENTRY POINT                              
         ST    0,ACONTRL               ADDRESS OF PARM FIELD                    
         LR    ILCR,2                  ADDRESS OF 1ST INSTRUCTION               
*                                      TO BE TRACED                             
         LR    EXEC,4                  EXECUTE ROUTINE ADDRESS                  
         L     HEX2EBC,AHEX            CONVERSION ROUTINE ADDRESS               
         USING HEXTOEBC,HEX2EBC                                                 
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              COPY THE REGISTERS OF THE TRACED PROGRAM INTO REGTBL   *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         LA    SCR2,16                 16 REGISTERS                             
         SR    SCR3,SCR3               INDEX                                    
PICKUP   L     SCR0,0(SCR3,SCR1)       FETCH A REGISTER                         
         ST    SCR0,REGTBL(SCR3)       STORE IT AWAY                            
         LA    SCR3,4(0,SCR3)          INCREMENT INDEX                          
         BCT   SCR2,PICKUP             LOOP BACK TO GET NEXT REGISTER           
         SPACE 1                                                                
         BAL   BRFROM,WRITE            WRITE 1 BLANK LINE                       
         SPACE 1                                                                
         BAL   BRFROM,RDUMP            DUMP THE INITIAL                         
*                                      GENERAL REGISTERS                        
         SPACE 1                                                                
         STD   0,F0                    SAVE THE INITIAL VALUES                  
         STD   2,F2                    OF THE FLOATING POINT                    
         STD   4,F4                    REGISTERS                                
         STD   6,F6                                                             
         SPACE 1                                                                
         BAL   BRFROM,FDUMP            DUMP THE FLOATING POINT                  
*                                      REGISTERS                                
         BAL   BRFROM,WRITE            WRITE 1 BLANK LINE                       
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  MAINLOOP    THE MAJOR CYCLE OF THE TRACE ROUTINE                   *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
MAINLOOP DS    0H                                                               
         MVC   OLDREG(4*16),REGTBL     SAVE OLD REGISTERS FOR EVALXBD           
         C     ILCR,AENTRY             HAVE WE REACHED THE ENTRY TO THE         
*                                      XPL SUBMONITOR ?                         
         BE    GOIO                    YES, GO PROCESS THE REQUEST              
         SPACE 1                                                                
         MVC   XCELL(6),0(ILCR)        FETCH THE NEXT 6 BYTES OF                
*                                      THE INSTRUCTION IMAGE                    
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,XCELL              THE INSTRUCTION CODE                     
         IC    SCR1,OPINDEX(SCR1)      THE INSTRUCTION INDEX                    
         LH    SCR1,OPFLAGS(SCR1)      THE INSTRUCTION ATTRIBUTE FLAGS          
         STH   SCR1,FLAGS              SAVE THE FLAGS                           
         TM    FLAGS,ILGLBIT           IN THE INSTRUCTION ILLEGAL ?             
         BO    ILGLOP                  YES, GO PRINT MESSAGE AND QUIT           
         TM    FLAGS,BRBIT             IS THE INSTRUCTION                       
*                                      A BRANCH OR EXECUTE ?                    
         BO    BROP                    YES, GO TO THE BRANCH PROCESSOR          
         STM   0,15,SAVREG             SAVE THE TRACE ROUTINE'S                 
*                                      REGISTERS                                
         LM    0,2,XCELL               PARAMETERS FOR EXECUTE ROUTINE           
         LM    5,15,REGTBL+4*5         LOAD SOME OF THE PSEUDO                  
*                                      REGISTERS (REGISTERS OF THE              
*                                      TRACED PROGRAM)                          
         DROP  DATA,HEX2EBC,OSAVE                                               
         SPACE 1                                                                
         BALR  3,4                     CALL THE EXECUTE ROUTINE IN THE          
*                                      XPL SUBMONITOR                           
         USING *,3                                                              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              THE EXECUTE ROUTINE IN THE SUBMONITOR RETURNS HERE     *         
*              WITH A  BALR 1,3  THUS LEAVING THE POSSIBLY MODIFIED   *         
*              CONDITION CODE IN REGISTER 1                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         TM    FLAGS,CCBIT             COULD THE INSTRUCTION HAVE               
*                                      CHANGED THE CONDITION CODE ?             
         BZ    NOCC                    NO, NOT A POSSIBILITY                    
         SPACE 1                                                                
         SR    SCR0,SCR0               CLEAR SCR0                               
         SLL   SCR1,2                  SHIFT OFF LENGTH CODE                    
         SLDL  SCR0,2                  CONDITION CODE IN SCR0                   
         STC   SCR0,REALCC             SAVE CONDITION CODE IN REALCC            
         SPACE 1                                                                
NOCC     DS    0H                                                               
         LM    0,15,SAVREG             RESTORE TRACE ROUTINE'S                  
*                                      REGISTERS                                
         USING DATAREA,DATA                                                     
         USING HEXTOEBC,HEX2EBC                                                 
         USING SAVE,OSAVE                                                       
         DROP  3                                                                
         SPACE 1                                                                
         TM    FLAGS,FLOATBIT          FLOATING POINT INSTRUCTION ?             
         BZ    BRETN                   NO, FLOATING REGISTERS                   
*                                      ARE UNCHANGED                            
         SPACE 1                                                                
         STD   0,F0                    SAVE THE POSSIBLY MODIFIED               
         STD   2,F2                    FLOATING POINT REGISTERS                 
         STD   4,F4                    FOR THE PRINT ROUTINES                   
         STD   6,F6                                                             
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*  BRETN       THE BRANCH AND EXECUTE INSTRUCTION PROCESSORS          *         
*              RETURN TO THE MAIN LOOP HERE                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BRETN    DS    0H                                                               
         TM    PRINTING,X'FF'          IS PRINTING ENABLED                      
         BZ    NOPRTS                  NO, SO SKIP PRINT PHASE                  
         SPACE 1                                                                
         BAL   BRFROM,PRINTSUP         CALL THE PRINT SUPERVISOR                
*                                      TO PRINT WHAT HAPPENED                   
         SPACE 1                                                                
NOPRTS   DS    0H                                                               
         TM    NOBUMP,X'FF'            SHOULD THE PSEUDO LOCATION               
*                                      COUNTER BE INCREMENTED ?                 
         BZ    INCR                    YES, GO INCREMENT                        
         MVI   NOBUMP,X'00'            RESET FLAG                               
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              FETCH THE NEW VALUE FOR THE PSEUDO LOCATION COUNTER    *         
*              THAT WAS PREPARED BY THE BRANCH PROCESSOR              *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         L     ILCR,NEWILC                                                      
         B     CTEST                   GO TO END OF MAIN LOOP                   
         SPACE 1                                                                
INCR     DS    0H                      INCREMENT THE PSEUDO LOCATION            
*                                      COUNTER                                  
         LA    ILCR,2(0,ILCR)          PLUS 2                                   
         TM    FLAGS+1,RRBIT           TYPE RR INSTRUCTION ?                    
         BO    CTEST                   YES, SO DONE INCREMENTING                
         LA    ILCR,2(0,ILCR)          PLUS 2 MORE                              
         TM    FLAGS+1,SSBIT           TYPE SS INSTRUCTION ?                    
         BZ    CTEST                   NO, SO DONE INCREMENTING                 
         LA    ILCR,2(0,ILCR)          PLUS 2 MORE FOR TYPE SS                  
         SPACE 1                                                                
CTEST    DS    0H                                                               
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*  CTEST       HERE WOULD BE A GOOD PLACE TO INSERT AN INCREMENT      *         
*              AND TEST ROUTINE IF IT BECOMES NECESSARY TO            *         
*              LIMIT THE NUMBER OF INSTRUCTIONS THAT ARE TRACED.      *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         B     MAINLOOP                AROUND THE LOOP AGAIN                    
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  ILGLOP      ILLEGAL  INSTRUCTION  HANDLING                         *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
ILGLOP   DS    0H                                                               
         MVC   PLINE+4(40),ILGMSG      '****  ILLEGAL  INSTRUCTION  '           
         BAL   BRFROM,WRITE            PRINT THE MESSAGE                        
         BAL   BRFROM,PRINTSUP         PRINT THE ILLEGAL INSTRUCTION            
         BAL   BRFROM,RDUMP            DUMP THE GENERAL REGISTERS               
         BAL   BRFROM,FDUMP            DUMP THE FLOATING REGISTERS              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              RETURN TO THE SUBMONITOR AT THE POINT FROM WHICH TRACE *         
*              WAS CALLED.  USED BY ILGLOP TO TERMINATE THE JOB       *         
*              AFTER AN ILLEGAL INSTRUCTION                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         LM    0,15,SAVE               RESTORE ALL REGISTERS                    
         BR    CBR                     RETURN TO THE XPLSM SUBMONITOR           
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  GOIO        ROUTINE TO PROCESS CALLS TO THE SUBMONITOR             *         
*              WHICH ARE MADE FROM THE PROGRAM BEING TRACED.          *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
GOIO     DS    0H                                                               
         L     SCR0,REGTBL+4*SMBR      GET THE RETURN ADDRESS IN THE            
*                                      TRACED PROGRAM                           
         ST    SCR0,IOFROM             SAVE RETURN ADDRESS                      
         CLI   REGTBL+4*SVCR+3,TRACEC  IS THE CALL A REQUEST TO                 
*                                      BEGIN TRACING ?                          
         BE    RETRACE                 YES, GO TO RETRACE                       
         CLI   REGTBL+4*SVCR+3,UNTRACE                                          
*                                      IS THE CALL A REQUEST TO                 
*                                      TERMINATE TRACING ?                      
         BE    ENDTRACE                YES, GO TO ENDTRACE                      
         TM    PRINTING,X'FF'          IS PRINTING ENABLED ?                    
         BZ    NOPRIO                  NO, SO REMAIN MUTE                       
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         MVC   PLINE+4(24),IORQM       '       I/O   REQUEST     '              
         L     SCR0,REGTBL+4*PR1       1ST PARAMETER REGISTER                   
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,PLINE+28      PLACE IN PRINT LINE                      
         L     SCR0,REGTBL+4*PR2       SECOND PARAMETER REGISTER                
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,PLINE+40      PLACE IN PRINT LINE                      
         L     SCR0,REGTBL+4*PR3       3RD PARAMETER REGISTER                   
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,PLINE+52      PLACE IN PRINT LINE                      
         L     SCR0,REGTBL+4*SMBR      RETURN ADDRESS REGISTER                  
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,PLINE+64      PLACE IN PRINT LINE                      
         BAL   BRFROM,WRITE            PRINT THE LINE                           
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         SPACE 1                                                                
NOPRIO   DS    0H                                                               
         STM   0,15,SAVREG             SAVE THE TRACE ROUTINE'S                 
*                                      REGISTERS                                
         LM    0,15,REGTBL             LOAD THE REGISTERS OF THE                
*                                      TRACED PROGRAM                           
         DROP  DATA,OSAVE,HEX2EBC                                               
         BALR  SMBR,SELF               CALL THE SUBMONITOR                      
         SPACE 1                                                                
         USING *,SMBR                                                           
         STM   0,15,REGTBL             SAVE REGISTERS IN THE                    
*                                      PSEUDO REGISTER TABLE                    
         LM    0,15,SAVREG             RESTORE TRACE ROUTINE'S                  
*                                      REGISTERS                                
         USING DATAREA,DATA                                                     
         USING HEXTOEBC,HEX2EBC                                                 
         USING SAVE,OSAVE                                                       
         DROP  SMBR                                                             
         L     ILCR,IOFROM             RETURN ADDRESS IN PROGRAM                
         ST    ILCR,REGTBL+4*SMBR      RESTORE RETURN REGISTER ENTRY            
*                                      IN REGTBL                                
         B     CTEST                   RETURN TO END OF THE MAIN LOOP           
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  ENDTRACE    ROUTINE TO TERMINATE TRACING AND RESUME EXECUTION      *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
ENDTRACE DS    0H                                                               
         TM    PRINTING,X'FF'          IS PRINTING ENABLED ?                    
         BZ    GOEXEC                  NO, SO SKIP PRINTING                     
         L     SCR0,IOFROM             RETURN ADDRESS FOR THE                   
*                                      SUBMONITOR CALL                          
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,ENDADR        PLACE IN MESSAGE                         
         MVC   ENDADR(2),BLANKS        TRIM TO SIX HEX DIGITS                   
         BAL   BRFROM,RDUMP            DUMP GENERAL REGISTERS                   
         BAL   BRFROM,FDUMP            DUMP FLOATING REGISTERS                  
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         MVC   PLINE+4(48),ENDTM       '  RESUME EXECUTION AT:  HHHHHH'         
         BAL   BRFROM,WRITE            PRINT THE MESSAGE                        
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         SPACE 1                                                                
GOEXEC   DS    0H                                                               
         LM    0,15,REGTBL             LOAD THE GENERAL REGISTERS               
*                                      OF THE TRACED PROGRAM                    
         BR    CBR                     RESUME EXECUTION OF THE PROGRAM          
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  RETRACE     ROUTINE TO PROCESS TRACE REQUESTS ENCOUNTERED WHILE    *         
*              TRACING                                                *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
RETRACE  DS    0H                                                               
         TM    PRINTING,X'FF'          IS PRINTING ENABLED ?                    
         BZ    RTR2                    NO, SO SKIP PRINTING                     
         MVC   PLINE+80(26),RTRM       ' RECURSIVE TRACE REQUEST '              
         BAL   BRFROM,WRITE            PRINT THE MESSAGE                        
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         BAL   BRFROM,RDUMP            DUMP THE GENERAL REGISTERS               
         BAL   BRFROM,FDUMP            DUMP THE FLOATING REGISTERS              
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         SPACE 1                                                                
RTR2     DS    0H                                                               
         L     ILCR,IOFROM             GET RETURN ADDRESS                       
         B     CTEST                   GO TO THE END OF THE MAIN LOOP           
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  BROP        ROUTINE TO HANDLE BRANCH AND EXECUTE INSTRUCTIONS      *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BROP     DS    0H                                                               
         TM    FLAGS+1,EXBIT           EXECUTE INSTRUCTION ?                    
         BO    EXOP                    YES, GO TO EXECUTE PROCESSOR             
         BAL   BRFROM,BRPROC           CALL THE BRANCH PROCESSOR                
         B     BRETN                   RETURN TO THE MAIN LOOP                  
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  BRPROC      BRANCH INSTRUCTION PROCESSOR                           *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BRPROC   DS    0H                                                               
         ST    BRFROM,BRSV             SAVE RETURN ADDRESS                      
         TM    FLAGS+1,RSBIT           BXH OR BXLE ?                            
         BO    BXHBXLE                 YES, GO PROCESS                          
         TM    XCELL,X'07'             BC ("47")  OR  BCR ("07") ?              
         BO    BCBCR                   YES, GO PROCESS                          
         TM    XCELL,X'02'             BCT ("46")  OR  BCTR ("06") ?            
         BO    BCTBCTR                 YES, GO PROCESS                          
*                                      BY DEFAULT THE INSTRUCTION IS            
*                                      BAL ("45")  OR  BALR ("05")              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              BAL AND BALR                                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         LA    SCR1,2                  COMPUTE INCREMENT TO ILCR                
         TM    FLAGS+1,RRBIT           BALR ?                                   
         BO    BAL1                    YES, SO INCREMENT IS 2                   
         AR    SCR1,SCR1               BAL, SO INCREMENT IS 4                   
BAL1     AR    SCR1,ILCR               RETURN ADDRESS FOR BRANCH                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              BUILD UP COMPLETE RETURN REGISTER IN SCR1              *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         BALR  SCR0,SCR0               GET PROGRAM MASK BITS                    
         N     SCR0,OFOOOOOO           PROGRAM MASK BITS ONLY                   
         OR    SCR1,SCR0               INSERT IN THE RETURN                     
         L     SCR0,ILC1               GET INSTRUCTION LENGTH BITS              
         TM    FLAGS+1,RXBIT+EXBIT     BAL OR EXECUTE OF A BRANCH ?             
         BZ    BAL2                    NO, BALR SO LENGTH IS 2                  
         SLL   SCR0,1                  BAL OR EXECUTED BRANCH                   
*                                      LENGTH IS 4                              
BAL2     OR    SCR1,SCR0               OR IN INSTRUCTION LENGTH CODE            
         SR    SCR0,SCR0               CLEAR SCR0                               
         IC    SCR0,REALCC             GET THE CORRECT CONDITION CODE           
         SLL   SCR0,28                 POSITION IT PROPERLY                     
         OR    SCR1,SCR0               OR IN CONDITION CODE BITS                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              SCR1 NOW CONTAINS THE RETURN REGISTER THAT WOULD HAVE  *         
*              RESULTED IN ACTUAL EXECUTION FROM STORING THE RIGHT    *         
*              HALF OF THE PSW                                        *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         IC    SCR2,XCELL+1            RR                                       
         N     SCR2,OOOOOOFO           R0                                       
         SRL   SCR2,2                  R*4                                      
         ST    SCR1,REGTBL(SCR2)       STORE RETURN IN PSEUDO REGISTER          
         TM    FLAGS+1,RXBIT           BAL ?                                    
         BO    BRXGO                   BAL ALWAYS TRANSFERS                     
*                                      GO CALCULATE ADDRESS                     
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*  BRRGO       COMPUTATION OF THE BRANCH ADDRESS                      *         
*  BRXGO                                                              *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BRRGO    DS    0H                      TYPE RR,  BRANCH IS TAKEN                
*                                      COMPUTE EFFECTIVE ADDRESS                
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOOF           0R                                       
         BZ    BRTN1                   NO BRANCH IF REGISTER ZERO               
*                                      IS SPECIFIED                             
         SLL   SCR1,2                  R*4                                      
         L     SCR0,OLDREG(SCR1)       GET ADDRESS FROM REGISTER                
         SPACE 1                                                                
BRTN     DS    0H                      SUCCESSFUL BRANCH EXIT                   
         ST    SCR0,NEWILC             SAVE BRANCH ADDRESS                      
*                                      FOR LOADING AT END OF MAIN LOOP          
         MVI   NOBUMP,X'FF'            SET BRANCH FLAG                          
         SPACE 1                                                                
BRTN1    DS    0H                      UNSUCCESSFUL BRANCH EXIT                 
         L     BRFROM,BRSV             RESTORE RETURN ADDRESS                   
         BR    BRFROM                  RETURN                                   
         SPACE 1                                                                
BRXGO    DS    0H                      TYPE RX,  BRANCH TAKEN                   
         LA    SCR2,XCELL+2            POINT AT BASE,DISPLACEMENT FIELD         
         BAL   BRFROM,EVALXBD          GO EVALUATE EFFECTIVE ADDRESS            
         B     BRTN                                                             
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*  BCBCR       BC AND BCR                                             *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BCBCR    DS    0H                      CONDITIONAL BRANCH PROCESSOR             
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOFO           R0                                       
         SR    SCR2,SCR2               CLEAR SCR2                               
         IC    SCR2,REALCC             ACTUAL CONDITION CODE                    
         SLL   SCR2,2                  (CONDITION CODE)*4                       
         N     SCR1,CCBITS(SCR2)       MASK BITS CORESPONDING TO                
*                                      THE CONDITION CODE                       
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              IF THE MASK SPECIFIED BY THE R1 FIELD OF THE           *         
*              INSTRUCTION DOES NOT HAVE A ONE BIT THAT CORESPONDS    *         
*              TO THE ONE BIT IN THE MASK REPRESENTING THE CONDITION  *         
*              CODE THEN THE BRANCH IS NOT TAKEN                      *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         BZ    BRTN1                   BRANCH IS NOT TAKEN                      
         TM    FLAGS+1,RXBIT           BC INSTRUCTION ?                         
         BO    BRXGO                   YES, GO EVALUATE ADDRESS                 
         B     BRRGO                   BCR, GO EVALUATE ADDRESS                 
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*  BXHBXLE     BXH AND BXLE                                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BXHBXLE  DS    0H                      BXH  BXLE  INSTRUCTION PROCESSOR         
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOOF           0R                                       
         SLL   SCR1,2                  R3*4                                     
         L     SCR0,REGTBL(SCR1)       VALUE OF THE INCREMENT                   
         SR    SCR2,SCR2               CLEAR SCR2                               
         IC    SCR2,XCELL+1            RR                                       
         N     SCR2,OOOOOOFO           R0                                       
         SRL   SCR2,2                  R1*4                                     
         A     SCR0,REGTBL(SCR2)       1ST OPERAND + INCREMENT                  
         ST    SCR0,REGTBL(SCR2)       STORE SUM BACK IN R1                     
         TM    XCELL+1,X'01'           IS R3 ODD ?                              
         BO    CR3                     YES, SO IT IS THE COMPARAND              
         LA    SCR1,4(SCR1)            (R3+1)*4                                 
         N     SCR1,OOOOOO3C           MODULO 16                                
CR3      C     SCR0,REGTBL(SCR1)       COMPARE NEW VALUE AND COMPARAND          
         BH    BHGO                    NEW VALUE IS GREATER                     
*                                      NEW VALUE IS LESS THAN OR EQUAL          
         SPACE 1                                                                
BLEGO    TM    XCELL,X'01'             IS THE INSTRUCTION BXLE ("87") ?         
         BO    BRXGO                   YES, BXLE SO BRANCH IS TAKEN             
         B     BRTN1                   NO, BXH SO BRANCH IS NOT TAKEN           
         SPACE 1                                                                
BHGO     TM    XCELL,X'01'             IS THE INSTRUCTION BXH ("86") ?          
         BZ    BRXGO                   BXH, SO BRANCH IS TAKEN                  
         B     BRTN1                   BXLE,  BRANCH IS NOT TAKEN               
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*  BCTBCTR     BCT AND BCTR                                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BCTBCTR  DS    0H                      BCT AND BCTR PROCESSOR                   
         IC    SCR2,XCELL+1            RR                                       
         N     SCR2,OOOOOOFO           R0                                       
         SRL   SCR2,2                  R1*4                                     
         L     SCR1,REGTBL(SCR2)       VALUE OF THE INDEX                       
         S     SCR1,F1                 SUBTRACT ONE                             
         ST    SCR1,REGTBL(SCR2)       STORE NEW VALUE BACK                     
         BZ    BRTN1                   NO BRANCH IF NEW VALUE IS ZERO           
         TM    FLAGS+1,RXBIT           BCT OR BCTR ?                            
         BO    BRXGO                   BCT, GO EVALUATE ADDRESS                 
         B     BRRGO                   BCTR, GO EVALUATE ADDRESS                
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  EXOP        EXECUTE INSTRUCTION PROCESSOR                          *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
EXOP     DS    0H                                                               
         LA    SCR2,XCELL+2            POINT TO BASE AND DISPLACEMENT           
         BAL   BRFROM,EVALXBD          EVALUATE THE EFFECTIVE ADDRESS           
*                                      OF THE EXECUTE INSTRUCTION               
         LR    SCR1,SCR0               ADDRESS IS IN SCR0, MOVE IT              
         MVC   PSXCELL(6),0(SCR1)      FETCH 6 BYTES OF THE SUBJECT             
*                                      INSTRUCTION                              
         IC    SCR1,XCELL+1            RR  OF THE EXECUTE INSTRUCTION           
         N     SCR1,OOOOOOFO           R0                                       
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              IF THE R1 FIELD OF THE EXECUTE INSTRUCTION IS ZERO     *         
*              THEN THE SUBJECT INSTRUCTION IS EXECUTED AS IS.        *         
*              OTHERWISE THE RIGHT HAND BYTE OF THE REGISTER          *         
*              SPECIFIED BY THE R1 FIELD IS OR'ED INTO THE SECOND     *         
*              BYTE OF THE SUBJECT INSTRUCTION                        *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         BZ    NOOR                    NOTHING TO OR IN                         
         SRL   SCR1,2                  R1*4                                     
         L     SCR2,REGTBL(SCR1)       GET THE BITS TO OR IN                    
         EX    SCR2,ORI                OR INTO THE SUBJECT INSTRUCTION          
         SPACE 1                                                                
NOOR     DS    0H                                                               
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,PSXCELL            INSTRUCTION CODE OF THE SUBJECT          
*                                      INSTRUCTION                              
         IC    SCR1,OPINDEX(SCR1)      INSTRUCTION CODE INDEX                   
         LH    SCR1,OPFLAGS(SCR1)      INSTRUCTION CODE ATTRIBUTE FLAGS         
         STH   SCR1,PSFLAGS            SAVE THE FLAGS                           
         TM    PSFLAGS,ILGLBIT         IS THE SUBJECT INSTRUCTION               
*                                      ILLEGAL ?                                
         BO    ILGLOP                  YES, PRINT MESSAGE AND TERMINATE         
         TM    PSFLAGS,BRBIT           IS THE SUBJECT INSTRUCTION               
*                                      A BRANCH ?                               
         BO    EXBR                    YES, GO SIMULATE AN EXECUTED             
*                                      BRANCH INSTRUCTION                       
         SPACE 1                                                                
         STM   0,15,SAVREG             SAVE TRACE ROUTINE REGISTERS             
         LM    0,2,PSXCELL             PARAMETERS FOR EXECUTE ROUTINE           
         LM    5,15,REGTBL+4*5         LOAD TRACED PROGRAM'S REGISTERS          
         DROP  DATA,HEX2EBC,OSAVE                                               
         BALR  3,4                     CALL THE EXECUTE ROUTINE IN              
*                                      THE XPLSM SUBMONITOR                     
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              EXECUTE ROUTINE RETURNS HERE VIA A BALR 1,3 THUS       *         
*              LEAVING THE POSSIBLY MODIFIED CONDITION CODE IN        *         
*              REGISTER 1                                             *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         USING *,3                                                              
         TM    PSFLAGS,CCBIT           WAS THE CONDITION CODE POSSIBLY          
*                                      CHANGED ?                                
         BZ    NXCC                    NO, NOT A POSSIBILITY                    
         SPACE 1                                                                
         SR    SCR0,SCR0               CLEAR SCR0                               
         SLL   SCR1,2                  DELETE INSTRUCTION LENGTH CODE           
         SLDL  SCR0,2                  CONDITION CODE TO SCR0                   
         STC   SCR0,REALCC             SAVE CONDITION CODE IN REALCC            
         SPACE 1                                                                
NXCC     DS    0H                                                               
         LM    0,15,SAVREG             RESTORE TRACE ROUTINE REGISTERS          
         USING DATAREA,DATA                                                     
         USING HEXTOEBC,HEX2EBC                                                 
         USING SAVE,OSAVE                                                       
         DROP  3                                                                
         B     BRETN                   RETURN TO THE MAIN LOOP                  
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*  EXBR        ROUTINE TO HANDLE EXECUTED BRANCHES                    *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
EXBR     DS    0H                                                               
         TM    PSFLAGS+1,EXBIT         IS THE SUBJECT INSTRUCTION               
*                                      REALLY AN EXECUTE INSTRUCTION ?          
         BO    ILGLOP                  EXECUTED EXECUTES ARE ILLEGAL            
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              MOVE THINGS AROUND TO FOOL THE BRANCH PROCESSOR        *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         LH    SCR1,FLAGS              SWAP FLAGS AND PSFLAGS                   
         LH    SCR2,PSFLAGS                                                     
         STH   SCR1,PSFLAGS                                                     
         STH   SCR2,FLAGS                                                       
         LM    SCR0,SCR1,XCELL         SWAP XCELL AND PSXCELL                   
         LM    SCR2,SCR3,PSXCELL                                                
         STM   SCR0,SCR1,PSXCELL                                                
         STM   SCR2,SCR3,XCELL                                                  
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              SIGNAL AN EXECUTED BRANCH SO THAT THE INSTRUCTION      *         
*              LENGTH CODE COMES OUT RIGHT FOR BAL AND BALR           *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         OI    FLAGS+1,EXBIT           SET EXECUTED BRANCH FLAG                 
         BAL   BRFROM,BRPROC           CALL THE BRANCH PROCESSOR                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              PUT THINGS BACK THE WAY THEY WERE SO THAT THE EXECUTE  *         
*              INSTRUCTION GETS PRINTED                               *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         LH    SCR1,FLAGS              SWAP FLAGS AND PSFLAGS                   
         LH    SCR2,PSFLAGS                                                     
         STH   SCR1,PSFLAGS                                                     
         STH   SCR2,FLAGS                                                       
         LM    SCR0,SCR1,XCELL         SWAP XCELL AND PSXCELL                   
         LM    SCR2,SCR3,PSXCELL                                                
         STM   SCR0,SCR1,PSXCELL                                                
         STM   SCR2,SCR3,XCELL                                                  
         B     BRETN                   RETURN TO THE MAIN LOOP                  
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  PRINTSUP    PRINT SUPERVISOR                                       *         
*                                                                     *         
*              THIS ROUTINE CONTROLS THE FABRICATION AND PRINTING     *         
*              OF THE PRINT LINE DESCRIBING EACH INSTRUCTION          *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PRINTSUP DS    0H                                                               
         ST    BRFROM,PRTS             SAVE RETURN                              
         SPACE 1                                                                
         BAL   BRFROM,PLINE1           CALL PLINE1                              
         SPACE 1                                                                
         BAL   BRFROM,PLINOP           CALL PLINOP                              
         SPACE 1                                                                
         BAL   BRFROM,PLINREG          CALL PLINREG                             
         SPACE 1                                                                
         BAL   BRFROM,PLINEFA          CALL PLINEFA                             
         SPACE 1                                                                
         BAL   BRFROM,WRITE            PRINT THE LINE                           
         SPACE 1                                                                
         TM    FLAGS+1,LMSTMBIT        LM OR STM INSTRUCTION ?                  
         BZ    NORDMP                  NO                                       
         SPACE 1                                                                
         BAL   BRFROM,RDUMP            YES, SO DUMP GENERAL REGISTERS           
         SPACE 1                                                                
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         SPACE 1                                                                
NORDMP   DS    0H                                                               
         L     BRFROM,PRTS             LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  PLINE1      ROUTINE TO PLACE THE PSEUDO LOCATION COUNTER, THE      *         
*              HEXADECIMAL INSTRUCTION IMAGE, AND THE CONDITION CODE  *         
*              IN THE PRINT LINE                                      *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PLINE1   DS    0H                                                               
         ST    BRFROM,P1S              SAVE RETURN ADDRESS                      
         LR    SCR0,ILCR               COPY THE PSEUDO LOCATION COUNTER         
         BALR  BRFROM,HEX2EBC          CONVERT IT FOR PRINTING                  
         STM   SCR0,SCR1,ILC           PLACE IT IN THE PRINT LINE               
         MVC   ILC(2),BLANKS           DELETE LEADING ZEROS                     
         L     SCR0,XCELL              GET THE INSTRUCTION IMAGE                
         BALR  BRFROM,HEX2EBC          CONVERT 1ST FOUR BYTES                   
         ST    SCR0,INSTR              PLACE 1ST 2 BYTES IN PRINT LINE          
         TM    FLAGS+1,RRBIT           TYPE RR INSTRUCTION ?                    
         BO    P1CC                    YES, ONLY PRINT TWO BYTES                
         ST    SCR1,INSTR+4            PLACE 2ND 2 BYTES OF THE                 
*                                      INSTRUCTION IN THE PRINT LINE            
         TM    FLAGS+1,SSBIT           TYPE SS INSTRUCTION ?                    
         BZ    P1CC                    NO, ONLY PRINT 4 BYTES                   
         L     SCR0,XCELL+4            GET LAST 2 BYTES OF INSTRUCTION          
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         ST    SCR0,INSTR+8            PLACE LAST 2 BYTES IN PRINT LINE         
P1CC     DS    0H                      PLACE THE CONDITION CODE IN THE          
*                                      PRINT LINE                               
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,REALCC             ACTUAL CONDITION CODE                    
         IC    SCR0,EBDCC(SCR1)        GET CORRESPONDING CHARACTER              
         STC   SCR0,CC                 PLACE CHARACTER IN PRINT LINE            
         L     BRFROM,P1S              LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  PLINOP      ROUTINE TO PLACE THE SYMBOLIC INSTRUCTION CODE AND THE *         
*              INSTRUCTION FIELDS IN ASSEMBLY FORMAT INTO THE         *         
*              PRINT LINE.                                            *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PLINOP   DS    0H                                                               
         ST    BRFROM,P2S              SAVE RETURN ADDRESS                      
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,XCELL              INSTRUCTION CODE                         
         SLL   SCR1,2                  (INSTRUCTION CODE)*4                     
         L     SCR0,BCDOP(SCR1)        SYMBOLIC INSTRUCTION CODE                
         ST    SCR0,OP                 PLACE IN PRINT LINE                      
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              PREPARE THE INSTRUCTION FIELDS IN ASSEMBLY FORMAT      *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         LA    FLDPT,FIELDS            POINTER TO THE INSTRUCTION               
*                                      FIELDS IN THE PRINT LINE                 
         TM    FLAGS+1,IMDFBIT         DOES THE INSTRUCTION CONTAIN             
*                                      AN IMMEDIATE FIELD ?                     
         BZ    SPLT                    NO, SO SPLIT THE FIELD INTO R,X          
         SR    SCR1,SCR1               SIGNAL NO INDEX                          
         LH    SCR0,XCELL+2            BDDD                                     
         BAL   BRFROM,BDPROC           'DDD(B)'                                 
         TM    FLAGS+1,SSBIT           TYPE SS INSTRUCTION ?                    
         BZ    FSI                     NO, MUST BE TYPE SI INSTRUCTION          
         S     FLDPT,F3                BACK UP THE FIELD POINTER                
         MVC   4(2,FLDPT),1(FLDPT)     'DDD(   B)'                              
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,XCELL+1            LL        LENGTH FIELD                   
         SRL   SCR1,4                  L                                        
         IC    SCR1,HEXCHAR(SCR1)      'L'                                      
         STC   SCR1,1(FLDPT)           'DDD(L  B)'                              
         IC    SCR1,XCELL+1            LL                                       
         N     SCR1,OOOOOOOF            L                                       
         IC    SCR1,HEXCHAR(SCR1)      'L'                                      
         STC   SCR1,2(FLDPT)           'DDD(LL B)'                              
         MVI   3(FLDPT),C','           'DDD(LL,B)'                              
         LA    FLDPT,6(FLDPT)          ADJUST THE FIELD POINTER                 
         B     FSS                     GO FINISH TYPE SS INSTRUCTION            
         SPACE 1                                                                
FSI      MVI   0(FLDPT),C','           'DDD(B),'                                
         SR    SCR1,SCR1               CLEAR SCR1                               
         IC    SCR1,XCELL+1            II        IMMEDIATE FIELD                
         SRL   SCR1,4                  I                                        
         IC    SCR1,HEXCHAR(SCR1)      'I'                                      
         STC   SCR1,1(FLDPT)           'DDD(B),I'                               
         IC    SCR1,XCELL+1            II                                       
         N     SCR1,OOOOOOOF            I                                       
         IC    SCR1,HEXCHAR(SCR1)      'I'                                      
         STC   SCR1,2(FLDPT)           'DDD(B),II'                              
         B     POPDONE                 FINISHED, SO RETURN                      
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              SPLIT THE SECOND BYTE OF THE INSTRUCTION INTO          *         
*              R,X OR R,R                                             *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
SPLT     IC    SCR1,XCELL+1            RX        REGISTER SPECIFIERS            
         N     SCR1,OOOOOOFO           R0                                       
         SRL   SCR1,4                  R                                        
         IC    SCR0,HEXCHAR(SCR1)      'R'                                      
         STC   SCR0,0(0,FLDPT)         'R'                                      
         MVI   1(FLDPT),C','           'R,'                                     
         LA    FLDPT,2(FLDPT)          ADJUST FIELD POINTER                     
         TM    FLAGS+1,RRBIT+LMSTMBIT                                           
*                                      IS THE INSTRUCTION TYPE RR OR            
*                                      LM OR STM ?                              
         BZ    NOTRR                   NO                                       
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOOF           0R                                       
         IC    SCR0,HEXCHAR(SCR1)      'R'                                      
         STC   SCR0,0(0,FLDPT)         'R,R'                                    
         TM    FLAGS+1,RRBIT           IS THE INSTRUCTION TYPE RR ?             
         BO    POPDONE                 YES, SO FINISHED                         
         SR    SCR1,SCR1               NO INDEX FOR LM OR STM                   
         MVI   1(FLDPT),C','           'R,R,'                                   
         LA    FLDPT,2(FLDPT)          ADJUST THE FIELD POINTER                 
         B     NOTRR2                  GO EVALUATE BASE, DISPLACEMENT           
         SPACE 1                                                                
NOTRR    IC    SCR1,XCELL+1            RX                                       
         N     SCR1,OOOOOOOF           0X                                       
NOTRR2   LH    SCR0,XCELL+2            BDDD      BASE AND DISPLACEMENT          
         BAL   BRFROM,BDPROC           'R,DDD(X,B)'  OR    'R,DDD(B)'           
         B     POPDONE                 FINISHED  SO RETURN                      
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              FINISH UP TYPE  SS INSTRUCTION                         *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
FSS      MVI   0(FLDPT),C','           'DDD(LL,B),'                             
         LA    FLDPT,1(FLDPT)          ADJUST FIELD POINTER                     
         LH    SCR0,XCELL+4            BDDD      2ND BASE,DISPLACEMENT          
         SR    SCR1,SCR1               INDICATE NO INDEX                        
         BAL   BRFROM,BDPROC           'DDD(LL,B),DDD(B)'                       
         SPACE 1                                                                
POPDONE  L     BRFROM,P2S              LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  BDPROC      ROUTINE TO FORMAT THE BASE, DISPLACEMENT, AND INDEX    *         
*              FIELDS INTO ASSEMBLY FORMAT FOR PRINTING               *         
*              INPUT IS A BASE,DISPLACEMENT HALF-WORD IN SCR0 AND THE *         
*              NUMBER OF THE INDEX REGISTER IN SCR1                   *         
*                                                                     *         
*              PLACES EITHER  'DDD(B)' OR 'DDD(X,B)' INTO THE         *         
*              INSTRUCTION IMAGE AT THE POINT SPECIFIED BY FLDPT      *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BDPROC   ST    BRFROM,BDS              SAVE RETURN ADDRESS                      
         ST    SCR0,BDT                SAVE  BDDD                               
         ST    SCR1,BDT2               SAVE INDEX SPECIFIER                     
         N     SCR0,OOOOOFFF           DDD       DISPLACEMENT                   
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         L     SCR0,BDT2               X         INDEX REGISTER                 
         ST    SCR1,BDT2               '0DDD'                                   
         MVC   0(3,FLDPT),BDT2+1       'DDD'                                    
         MVI   3(FLDPT),C'('           'DDD('                                   
         LTR   SCR1,SCR0               IS AN INDEX SPECIFIED ?                  
         BZ    BDPNX                   NO, ZERO SPECIFIES NO INDEX              
         IC    SCR1,HEXCHAR(SCR1)      'X'                                      
         STC   SCR1,4(FLDPT)           'DDD(X'                                  
         MVI   5(FLDPT),C','           'DDD(X,'                                 
         LA    FLDPT,2(FLDPT)          ADJUST POINTER FOR THE INDEX             
BDPNX    L     SCR1,BDT                BDDD      BASE, DISPLACEMENT             
         N     SCR1,OOOOFOOO           B000                                     
         SRL   SCR1,12                 B         BASE REGISTER                  
         IC    SCR1,HEXCHAR(SCR1)      'B'                                      
         STC   SCR1,4(FLDPT)           'DDD(X,B'     OR    'DDD(B'              
         MVI   5(FLDPT),C')'           'DDD(X,B)'    OR    'DDD(B)'             
         LA    FLDPT,6(FLDPT)          ADJUST FIELD POINTER                     
         L     BRFROM,BDS              LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  PLINREG     ROUTINE TO PLACE THE OPERAND REGISTERS REFERENCED      *         
*              BY THE INSTRUCTION INTO THE PRINT LINE                 *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PLINREG  DS    0H                                                               
         TM    FLAGS+1,RRBIT+RXBIT+RSBIT                                        
*                                      DOES THE INSTRUCTION REFERENCE           
*                                      REGISTERS ?                              
         BCR   B'1000',BRFROM          NO, SO RETURN                            
         ST    BRFROM,P3S              SAVE RETURN ADDRESS                      
         TM    FLAGS,BRBIT             BRANCH INSTRUCTION ?                     
         BZ    GR1                     NO                                       
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              INSTRUCTION IS A BRANCH, SO TEST TO SEE IF IT IS       *         
*              A BRANCH CONDITIONAL, IN WHICH CASE THE R1 FIELD       *         
*              IS USED AS A MASK AGAINST THE CONDITION CODE           *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         CLI   XCELL,X'47'             IS THE INSTRUCTION BC ?                  
         BE    R1MASK                  YES                                      
         CLI   XCELL,X'07'             IS THE INSTRUCTION BCR ?                 
         BNE   GR1                     NO                                       
         SPACE 1                                                                
R1MASK   DS    0H                                                               
         IC    SCR0,FIELDS             R IN EBCDIC                              
         STC   SCR0,R1+7               STORE IN REGISTER FIELD                  
         LA    SCR2,REGTBL             ADDRESS OF REGISTER TABLE                
         B     RGRR                    GO TEST FOR TYPE RR INSTRUCTION          
         SPACE 1                                                                
GR1      DS    0H                                                               
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOFO           R0                                       
         SRL   SCR1,2                  R*4                                      
         LA    SCR2,REGTBL             ADDRESS OF REGISTER TABLE                
         TM    FLAGS,FLOATBIT          FLOATING POINT INSTRUCTION ?             
         BZ    FIXD                    NO, USE GENERAL REGISTERS                
         LA    SCR2,F0                 YES, USE FLOATING REGISTERS              
         SPACE 1                                                                
FIXD     DS    0H                                                               
         L     SCR0,0(SCR1,SCR2)       GET THE VALUE OF THE REGISTER            
         ST    SCR1,PRT                SAVE REGISTER NUMBER                     
         BALR  BRFROM,HEX2EBC          CONVERT VALUE FOR PRINTING               
         STM   SCR0,SCR1,R1            PLACE IN PRINT LINE                      
         TM    FLAGS,DBLBIT            DOUBLE WORD INSTRUCTION ?                
         BZ    RGRR                    NO                                       
         L     SCR1,PRT                R*4  AGAIN                               
         LA    SCR1,4(0,SCR1)          (R+1)*4   SECOND REGISTER NUMBER         
         L     SCR0,0(SCR1,SCR2)       VALUE OF SECOND REGISTER                 
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,DR1           PLACE IN PRINT LINE                      
         TM    FLAGS+1,RRBIT           TYPE RR INSTRUCTION ?                    
         BZ    PRDONE                  NO, SO FINISHED                          
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              GET THE VALUE OF THE 2ND DOUBLE WORD REGISTER          *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOOF           0R                                       
         SLL   SCR1,2                  R*4                                      
         L     SCR0,0(SCR1,SCR2)       GET REGISTER VALUE                       
         ST    SCR1,PRT                SAVE REGISTER NUMBER                     
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,DR2A          PLACE IN PRINT LINE                      
         L     SCR1,PRT                R*4  AGAIN                               
         L     SCR0,4(SCR1,SCR2)       GET 2ND HALF OF VALUE                    
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,DR2B          PLACE IN PRINT LINE                      
         B     PRDONE                  FINISHED                                 
         SPACE 1                                                                
RGRR     DS    0H                                                               
         TM    FLAGS+1,RRBIT           TYPE RR INSTRUCTION ?                    
         BZ    PRDONE                  NO, SO DONE                              
         IC    SCR1,XCELL+1            RR                                       
         N     SCR1,OOOOOOOF           0R                                       
         SLL   SCR1,2                  R*4                                      
         L     SCR0,0(SCR1,SCR2)       VALUE OF THE REGISTER                    
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,R2            PLACE IN PRINT LINE                      
         SPACE 1                                                                
PRDONE   DS    0H                                                               
         L     BRFROM,P3S              LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  PLINEFA     ROUTINE TO PLACE THE EFFECTIVE ADDRESS OF THE          *         
*              INSTRUCTION AND THE CONTENTS OF THE MEMORY LOCATION    *         
*              REFERENCED BY THE INSTRUCTION INTO THE PRINT LINE      *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PLINEFA  DS    0H                                                               
         TM    FLAGS+1,RRBIT           TYPE RR INSTRUCTION ?                    
         BCR   B'0001',BRFROM          YES, SO NO MEMORY REFERENCE              
         SPACE 1                                                                
         ST    BRFROM,P4S              SAVE RETURN ADDRESS                      
         LA    SCR2,XCELL+2            ADDRESS OF BASE, DISPLACEMENT            
         TM    FLAGS+1,RXBIT           TYPE RX INSTRUCTION ?                    
         BZ    NOTRX                   NO                                       
         BAL   BRFROM,EVALXBD          GO EVALUATE ADDRESS WITH INDEX           
         B     PEFA                    GO PLACE IN PRINT LINE                   
         SPACE 1                                                                
NOTRX    BAL   BRFROM,EVALBD           GO EVALUATE ADDRESS, NO INDEX            
PEFA     ST    SCR0,EFAT0              SAVE EFFECTIVE ADDRESS                   
         BALR  BRFROM,HEX2EBC          CONVERT ADDRESS FOR PRINTING             
         STM   SCR0,SCR1,EFA1          PLACE ADDRESS IN PRINT LINE              
         MVC   EFA1(2),BLANKS          DELETE LEADING ZEROS                     
         TM    FLAGS,SHIFTBIT          SHIFT INSTRUCTION ?                      
         BO    PEFADONE                YES, SO NO MEMORY REFERENCE              
         CLI   XCELL,X'41'             LOAD ADDRESS INSTRUCTION ?               
         BE    PEFADONE                YES, SO NO MEMORY REFERENCE              
         L     SCR2,EFAT0              EFFECTIVE ADDRESS AGAIN                  
         MVC   EFAT0(4),0(SCR2)        CONTENTS OF MEMORY REFERENCED            
         L     SCR0,EFAT0              PLACE CONTENTS IN SCR0                   
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,EFA1+12       PLACE CONTENTS IN PRINT LINE             
         TM    FLAGS,HALFBIT           HALF WORD INSTRUCTION ?                  
         BZ    PEFA1                   NO                                       
         MVC   EFA1+16(4),BLANKS       YES, ONLY PRINT HALF WORD                
         B     PEFADONE                FINISHED                                 
         SPACE 1                                                                
PEFA1    DS    0H                                                               
         TM    FLAGS+1,SIBIT           TYPE SI INSTRUCTION ?                    
         BZ    PEFA2                   NO                                       
         MVC   EFA1+14(6),BLANKS       ONLY PRINT ONE BYTE                      
         B     PEFADONE                FINISHED                                 
         SPACE 1                                                                
PEFA2    DS    0H                                                               
         TM    FLAGS,DBLBIT            DOUBLE WORD RX INSTRUCTION ?             
         BZ    PEFA3                   NO                                       
         MVC   EFAT0(4),4(SCR2)        CONTENTS OF SECOND WORD                  
         L     SCR0,EFAT0              PLACE IN SCR0                            
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,EFA1+20       PLACE IN THE PRINT LINE                  
         B     PEFADONE                FINISHED                                 
         SPACE 1                                                                
PEFA3    DS    0H                                                               
         TM    FLAGS+1,SSBIT           TYPE SS INSTRUCTION ?                    
         BZ    PEFADONE                NO, SO FINISHED                          
         LA    SCR2,XCELL+4            ADDRESS OF 2ND BASE,DISPLACEMENT         
         BAL   BRFROM,EVALBD           EVALUATE ADDRESS                         
         ST    SCR0,EFAT0              SAVE EFFECTIVE ADDRESS                   
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,EFA2          PLACE IN PRINT LINE                      
         MVC   EFA2(2),BLANKS          DELETE LEADING BLANKS                    
         L     SCR1,EFAT0              EFFECTIVE ADDRESS AGAIN                  
         MVC   EFAT0(4),0(SCR1)        GET CONTENTS OF MEMORY                   
         L     SCR0,EFAT0              LOAD CONTENTS INTO SCR0                  
         BALR  BRFROM,HEX2EBC          CONVERT FOR PRINTING                     
         STM   SCR0,SCR1,EFA2+12       PLACE IN PRINT LINE                      
         SPACE 1                                                                
PEFADONE DS    0H                                                               
         L     BRFROM,P4S              LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  EVALBD      ROUTINE TO EVALUATE THE MEMORY ADDRESSES OF MEMORY     *         
*  EVALXBD     REFERENCE INSTRUCTIONS                                 *         
*                                                                     *         
*              INPUT IS THE ADDRESS OF A HALF WORD CONTAINING THE     *         
*              BASE AND DISPLACEMENT FIELDS IN SCR2                   *         
*                                                                     *         
*              OUTPUT IS THE EFFECTIVE ADDRESS IN SCR0                *         
*                                                                     *         
*              EVALBD        ASSUMES THAT THERE IS NO INDEX           *         
*                                                                     *         
*              EVALXBD       USES THE INDEX FIELD OF THE INSTRUCTION  *         
*                            IN CALCULATING THE EFFECTIVE ADDRESS     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
EVALBD   DS    0H                                                               
         SR    SCR0,SCR0     VALUE OF THE INDEX IS ZERO                         
         B     NOX                     GO EVALUATE BASE, DISPLACEMENT           
         SPACE 2                                                                
EVALXBD  DS    0H                                                               
         SR    SCR0,SCR0               CLEAR SCR0                               
         IC    SCR1,XCELL+1            RX                                       
         N     SCR1,OOOOOOOF           0X                                       
         BZ    NOX                     REGISTER ZERO IMPLIES NO INDEX           
         SLL   SCR1,2                  X*4                                      
         L     SCR0,OLDREG(SCR1)       VALUE OF THE INDEX                       
         SPACE 1                                                                
NOX      DS    0H                      AT THIS POINT, SCR0 CONTAINS             
*                                      THE VALUE OF THE INDEX                   
         IC    SCR1,0(SCR2)            BD                                       
         N     SCR1,OOOOOOFO           B0        BASE REGISTER                  
         BZ    NOB                     REGISTER ZERO IMPLIES NO BASE            
         SRL   SCR1,2                  B*4                                      
         A     SCR0,OLDREG(SCR1)       INDEX + BASE                             
         SPACE 1                                                                
NOB      DS    0H                                                               
         LH    SCR1,0(0,SCR2)          BDDD      BASE, DISPLACEMENT             
         N     SCR1,OOOOOFFF           0DDD      DISPLACEMENT                   
         AR    SCR0,SCR1               INDEX + BASE + DISPLACEMENT              
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  RDUMP       REGISTER DUMP ROUTINES                                 *         
*  FDUMP                                                              *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
RDUMP    DS    0H                      DUMP GENERAL REGISTERS                   
         ST    BRFROM,RDSV             SAVE RETURN ADDRESS                      
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         LA    SCR2,REGTBL             ADDRESS OF 1ST 8 REGISTERS               
         BAL   BRFROM,RPUT             PLACE THEM IN PRINT LINE                 
         MVC   PLINE(10),RM0           ' R0-R7    '                             
         BAL   BRFROM,WRITE            PRINT THE LINE                           
         LA    SCR2,REGTBL+32          ADDRESS OF 2ND 8 REGISTERS               
         BAL   BRFROM,RPUT             PLACE THEM IN PRINT LINE                 
         MVC   PLINE(10),RM8           ' R8-R15   '                             
         BAL   BRFROM,WRITE            PRINT THE LINE                           
         L     BRFROM,RDSV             LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         SPACE 4                                                                
FDUMP    DS    0H                      DUMP FLOATING POINT REGISTERS            
         ST    BRFROM,FDSV             SAVE RETURN ADDRESS                      
         BAL   BRFROM,WRITE            PRINT 1 BLANK LINE                       
         MVC   PLINE(10),FM0           ' F0-F6   '                              
         LA    SCR2,F0                 ADDRESS OF FLOATING REGISTER             
*                                      TABLE                                    
         BAL   BRFROM,RPUT             PLACE THEM IN PRINT LINE                 
         BAL   BRFROM,WRITE            PRINT THE LINE                           
         L     BRFROM,FDSV             LOAD RETURN ADDRESS                      
         BR    BRFROM                  RETURN                                   
         SPACE 4                                                                
RPUT     DS    0H                      PLACE EIGHT REGISTERS INTO               
*                                      THE PRINT LINE                           
         ST    BRFROM,RPSV             SAVE RETURN ADDRESS                      
         LA    SCR3,PLINE+16           STARTING POINT IN PRINT LINE             
RNX      L     SCR0,0(SCR2)            GET THE VALUE OF A REGISTER              
         BALR  BRFROM,HEX2EBC          CONVERT IT FOR PRINTING                  
         STM   SCR0,SCR1,0(SCR3)       PLACE IN PRINT LINE                      
         LA    SCR2,4(0,SCR2)          POINT AT NEXT REGISTER                   
         LA    SCR3,12(0,SCR3)         NEXT SPACE IN PRINT LINE                 
         C     SCR3,EOL                END OF PRINT LINE ?                      
         BL    RNX                     NO, GO GET NEXT REGISTER                 
         L     BRFROM,RPSV             YES, LOAD RETURN ADDRESS                 
         BR    BRFROM                  RETURN                                   
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*  WRITE       ROUTINE TO OUTPUT THE PRINT LINE                       *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
WRITE    DS    0H                                                               
         ST    SMBR,WTR                SAVE BRANCH REGISTER                     
         STM   PR1,PR3,WTS             SAVE PARAMETER REGISTERS                 
         L     PR1,PDESC               DESCRIPTOR FOR PRINT LINE                
         LA    SVCR,PRNT               SERVICE CODE FOR PRINTING                
         SR    PR3,PR3                 SPECIFY  OUTPUT(0)                       
         SPACE 1                                                                
         BALR  SMBR,SELF               CALL THE XPL SUBMONITOR                  
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              BLANK THE PRINT LINE                                   *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         MVI   PLINE,C' '              ONE BLANK TO START                       
         MVC   PLINE+1(LPL-1),PLINE    PROPAGATE THE BLANK                      
         LM    PR1,PR3,WTS             RESTORE REGISTERS                        
         L     SMBR,WTR                RESTORE BRANCH REGISTER                  
         BR    BRFROM                  RETURN                                   
         SPACE 5                                                                
CODEND   DS    0H                      END OF THE TRACE ROUTINE CODE            
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              DATA AREA FOR THE TRACE ROUTINE                        *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
DATAREA  DS    0H                      ORIGIN OF THE DATA AREA                  
         SPACE 1                                                                
FLAGS    DC    H'0'                    ATTRIBUTE FLAGS DESCRIBING THE           
*                                      CURRENT INSTRUCTION                      
HEXCHAR  DC    C'0123456789ABCDEF'     CHARACTER CONSTANT                       
NOBUMP   DC    X'00'                   BRANCH INSTRUCTION FLAG                  
PRINTING DC    X'FF'                   PRINTING ENABLED FLAG                    
*                                      (NOT USED IN THIS VERSION)               
REALCC   DC    X'0'                    ACTUAL CONDITION CODE                    
XCELL    DC    F'0'                    A COPY OF THE INSTRUCTION                
         DC    F'0'                    CURRENTLY BEING TRACED                   
         DC    A(REGTBL)               ADDRESS OF PSEUDO REGISTER               
*                                      TABLE                                    
SAVREG   DC    16F'0'                  SAVE REGISTERS HERE WHILE                
*                                      CALLING EXECUTE ROUTINE IN XPLSM         
REGTBL   DC    16F'0'                  REGISTERS OF THE TRACED PROGRAM          
F0       DC    D'0'                    FLOATING POINT REGISTERS                 
F2       DC    D'0'                    OF THE TRACED PROGRAM                    
F4       DC    D'0'                                                             
F6       DC    D'0'                                                             
OLDREG   DC    16F'0'                  COPY REGISTER TABLE HERE BEFORE          
*                                      EXECUTING THE INSTRUCTION                
AENTRY   DC    F'0'                    ADDRESS OF XPLSM ENTRY POINT             
ACONTRL  DC    A(0)                    ADDRESS OF CONTROL PARAMETERS            
NEWILC   DC    F'0'                    NEW VALUE FOR THE LOCATION               
*                                      COUNTER FOR SUCCESSFUL BRANCHES          
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              MASKING CONSTANTS                                      *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         DS    0F                      INSURE ALLIGNMENT                        
OOOOOOOF DC    X'0000000F'                                                      
OOOOOOFO DC    X'000000F0'                                                      
OOOOOFFF DC    X'00000FFF'                                                      
OOOOFOOO DC    X'0000F000'                                                      
OFOOOOOO DC    X'0F000000'                                                      
OOOOOO3C DC    X'0000003C'                                                      
         DS    0F                                                               
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              TEMPORARY STORAGE USED BY THE VARIOUS ROUTINES         *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
*                                      BY PRINTSUP                              
         SPACE 1                                                                
PRTS     DC    F'0'                    RETURN ADDRESS                           
         SPACE 1                                                                
*                                      BY PLINE1                                
         SPACE 1                                                                
P1S      DC    F'0'                    RETURN ADDRESS                           
EBDCC    DC    C'8421'                 CHARACTERS FOR CONDITION CODE            
         DS    0F                                                               
         SPACE 1                                                                
*                                      BY PLINOP                                
         SPACE 1                                                                
F3       DC    F'3'                    THE CONSTANT 3                           
P2S      DC    F'0'                    RETURN ADDRESS                           
         SPACE 1                                                                
*                                      BY BDPROC                                
         SPACE 1                                                                
BDS      DC    F'0'                    RETURN ADDRESS                           
BDT      DC    F'0'                                                             
BDT2     DS    F                                                                
         SPACE 1                                                                
*                                      BY PLINREG                               
         SPACE 1                                                                
P3S      DC    F'0'                    RETURN ADDRESS                           
PRT      DC    F'0'                                                             
         SPACE 1                                                                
*                                      BY PLINEFA                               
         SPACE 1                                                                
P4S      DC    F'0'                    RETURN ADDRESS                           
EFAT0    DC    F'0'                                                             
         SPACE 1                                                                
*                                      BY BRPROC                                
         SPACE 1                                                                
CCBITS   DC    X'00000080'             BITS CORESPONDING TO THE                 
         DC    X'00000040'             CONDITION CODE                           
         DC    X'00000020'                                                      
         DC    X'00000010'                                                      
ILC1     DC    X'40000000'             INSTRUCTION LENGTH CODE                  
*                                      FOR BAL AND BALR                         
F1       DC    F'1'                    THE CONSTANT 1                           
BRSV     DC    F'0'                    RETURN ADDRESS                           
         SPACE 1                                                                
*                                      BY WRITE                                 
         SPACE 1                                                                
WTS      DC    3F'0'                                                            
WTR      DC    F'0'                    RETURN ADDRESS                           
         DS    0F                      INSURE ALIGNMENT                         
PDESC    DC    AL1(LPL-1)              XPL TYPE STRING DESCRIPTOR               
         DC    AL3(PLINE)              FOR THE PRINT LINE                       
         SPACE 1                                                                
*                                      BY RDUMP                                 
         SPACE 1                                                                
RDSV     DC    F'0'                    RETURN ADDRESS                           
         SPACE 1                                                                
*                                      BY FDUMP                                 
         SPACE 1                                                                
FDSV     DC    F'0'                    RETURN ADDRESS                           
         SPACE 1                                                                
*                                      BY RPUT                                  
         SPACE 1                                                                
RPSV     DC    F'0'                    RETURN ADDRESS                           
EOL      DC    A(PLINE+16+8*12)        ADDRESS OF END OF PRINT LINE             
         SPACE 1                                                                
*                                      BY EXOP                                  
ORI      OI    PSXCELL+1,0             INSTRUCTION TO OR ONE BYTE               
*                                      INTO THE SUBJECT INSTRUCTION             
*                                      OF AN EXECUTE INSTRUCTION                
PSXCELL  DC    F'0'                    COPY OF THE SUBJECT                      
         DC    F'0'                    INSTRUCTION                              
         DC    A(REGTBL)               ADDRESS OF THE REGISTER TABLE            
PSFLAGS  DC    H'0'                    ATTRIBUTE FLAGS FOR THE SUBJECT          
*                                      INSTRUCTION                              
         SPACE 1                                                                
*                                      BY GOIO                                  
         SPACE 1                                                                
IOFROM   DC    F'0'                    RETURN ADDRESS FOR SUBMONITOR            
*                                      CALL                                     
         SPACE 2                                                                
*                                      CHARACTER CONSTANTS                      
         SPACE 2                                                                
BLANKS   DC    CL8' '                                                           
FM0      DC    CL10' F0-F6    '                                                 
RM0      DC    C' R0-R7    '                                                    
RM8      DC    C' R8-R15   '                                                    
ILGMSG   DC    CL40' ****    ILLEGAL  INSTRUCTION  ****'                        
IORQM    DC    CL24'       I/O  REQUEST   '                                     
RTRM     DC    CL26'    RECURSIVE  TRACE  CALL'                                 
         DS    0F                      INSURE ALIGNMENT                         
ENDTM    DC    CL24'  RESUME EXECUTION AT: '                                    
ENDADR   DC    CL24' '                                                          
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              THE PRINT LINE                                         *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         DS    0F                      INSURE ALIGNMENT                         
PLINE    DC    CL(LPL)' '                                                       
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*              DEFINE SUBFIELDS WITHIN THE PRINT LINE FOR USE         *         
*              BY THE PRINT ROUTINES                                  *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
ILC      EQU   PLINE+4                 LOCATION COUNTER                         
INSTR    EQU   PLINE+16                INSTRUCTION IMAGE                        
CC       EQU   PLINE+31                CONDITION CODE                           
OP       EQU   PLINE+36                SYMBOLIC INSTRUCTION CODE                
FIELDS   EQU   PLINE+44                INSTRUCTION FIELDS                       
R1       EQU   PLINE+64                FIRST OPERAND REGISTER                   
DR1      EQU   R1+8                    2ND HALF OF 1ST DOUBLE REGISTER          
DR2A     EQU   DR1+12                  2ND DOUBLE REGISTER                      
DR2B     EQU   DR2A+8                  2ND HALF OF 2ND DOUBLE REGISTER          
R2       EQU   PLINE+76                SECOND SINGLE REGISTER                   
EFA1     EQU   PLINE+88                1ST EFFECTIVE ADDRESS                    
EFA2     EQU   PLINE+112               2ND EFFECTIVE ADDRESS                    
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              DEFINE TO INSTRUCTION CODE FLAG FIELDS USED TO         *         
*              GENERATE THE ATTRIBUTE FLAG TABLE                      *         
*                                                                     *         
*                                                                     *         
*              SHIFTING CONSTANTS FOR FIELD DEFINITIONS               *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
LEFT     EQU   B'100000000'            PLACE IN LEFT HALF OF FLAGS              
         SPACE 1                                                                
RIGHT    EQU   B'000000001'            PLACE IN RIGHT HALF OF FLAGS             
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              LEFT HALF FIELD DEFINITIONS                            *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
B0       EQU   ILGLBIT*LEFT            ILLEGAL INSTRUCTION                      
B1       EQU   CCBIT*LEFT              CONDITION CODE SET                       
B2       EQU   BRBIT*LEFT              BRANCH INSTRUCTION                       
B3       EQU   HALFBIT*LEFT            HALF WORD INSTRUCTION                    
B4       EQU   FULLBIT*LEFT            FULL WORD INSTRUCTION                    
B5       EQU   DBLBIT*LEFT             DOUBLE WORD INSTRUCTION                  
B6       EQU   FLOATBIT*LEFT           FLOATING POINT INSTRUCTION               
B7       EQU   SHIFTBIT*LEFT           SHIFT INSTRUCTION                        
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*              RIGHT HALF FIELD DEFINITIONS                           *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
B8       EQU   RRBIT*RIGHT             TYPE RR INSTRUCTION                      
B9       EQU   RXBIT*RIGHT             TYPE RX INSTRUCTION                      
BA       EQU   RSBIT*RIGHT             TYPE RS INSTRUCTION                      
BB       EQU   SIBIT*RIGHT             TYPE SI INSTRUCTION                      
BC       EQU   SSBIT*RIGHT             TYPE SS INSTRUCTION                      
BD       EQU   IMDFBIT*RIGHT           INSTRUCTION CONTAINS 8-BIT FIELD         
BE       EQU   LMSTMBIT*RIGHT          INSTRUCTION IS LM OR STM                 
BF       EQU   EXBIT*RIGHT             EXECUTE INSTRUCTION                      
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              INSTRUCTION CODE FLAGS                                 *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*                                  B B B B B B B B B B B B B B B B    *         
*                                  0 1 2 3 4 5 6 7 8 9 A B C D E F    *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
OPFLAGS  DS    0H                                                               
         DC    AL2(B0+B8)          X               X                 00         
         DC    AL2(B2+B8)              X           X                 02         
         DC    AL2(B1+B4+B8)         X     X       X                 04         
         DC    AL2(B4+B8)                  X       X                 06         
         DC    AL2(B1+B5+B8)         X       X     X                 08         
         DC    AL2(B1+B5+B6+B8)      X       X X   X                 0A         
         DC    AL2(B5+B6+B8)                 X X   X                 0C         
         DC    AL2(B1+B4+B6+B8)      X     X   X   X                 0E         
         DC    AL2(B4+B6+B8)               X   X   X                 10         
         DC    AL2(B3+B9)                X           X               12         
         DC    AL2(B4+B9)                  X         X               14         
         DC    AL2(B2+B4+B9+BF)        X   X         X           X   16         
         DC    AL2(B2+B9)              X             X               18         
         DC    AL2(B1+B3+B9)         X   X           X               1A         
         DC    AL2(B0+B9)          X                 X               1C         
         DC    AL2(B1+B4+B9)         X     X         X               1E         
         DC    AL2(B5+B6+B9)                 X X     X               20         
         DC    AL2(B1+B5+B6+B9)      X       X X     X               22         
         DC    AL2(B4+B6+B9)               X   X     X               24         
         DC    AL2(B1+B4+B6+B9)      X     X   X     X               26         
         DC    AL2(B0+BB)          X                     X           28         
         DC    AL2(B2+B4+B6+BA)        X   X   X       X             2A         
         DC    AL2(B4+B7+BA)               X     X     X             2C         
         DC    AL2(B1+B4+B7+BA)      X     X     X     X             2E         
         DC    AL2(BA+BE)                              X       X     30         
         DC    AL2(B1+BB+BD)         X                   X   X       32         
         DC    AL2(BB+BD)                                X   X       34         
         DC    AL2(B0+BB+BD)       X                     X   X       36         
         DC    AL2(B0+BB)          X                     X           38         
         DC    AL2(B0+BC)          X                       X         3A         
         DC    AL2(BC+BD)                                  X X       3C         
         DC    AL2(B1+BC+BD)         X                     X X       3E         
         DC    AL2(BC)                                     X         40         
         DC    AL2(B1+BC)            X                     X         42         
         DC    AL2(B5+B7+BA)                 X   X     X             44         
         DC    AL2(B1+B5+B7+BA)      X       X   X     X             46         
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              TABLES OF INDICES FOR EACH POSSIBLE INSTRUCTION        *         
*              CODE INTO THE OPFLAGS TABLE                            *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
OPINDEX  DS    0H                                                               
         DC    X'00000000'  RR00   ...     ...     ...     ...       00         
         DC    X'06020202'    04   SPM     BALR    BCTR    BCR       01         
         DC    X'00000000'    08  *SSK    *ISK    *SVC     ...       02         
         DC    X'00000000'    0C   ...     ...     ...     ...       03         
         DC    X'04040404'    10   LPR     LNR     LTR     LCR       04         
         DC    X'04040404'    14   NR      CLR     0R      XR        05         
         DC    X'06040404'    18   LR      CR      AR      SR        06         
         DC    X'06060404'    1C   MR      DR      ALR     SLR       07         
         DC    X'0A0A0A0A'    20   LPDR    LNDR    LTDR    LCDR      08         
         DC    X'0C000000'    24   HDR     ...     ...     ...       09         
         DC    X'0C0A0A0A'    28   LDR     CDR     ADR     SDR       10         
         DC    X'0C0C0A0A'    2C   MDR     DDR     AWR     SWR       11         
         DC    X'0E0E0E0E'    30   LPER    LNER    LTER    LCER      12         
         DC    X'10000000'    34   HER     ...     ...     ...       13         
         DC    X'100E0E0E'    38   LER     CER     ALR     SER       14         
         DC    X'10100E0E'    3C   MER     DER     AUR     SUR       15         
         DC    X'12141414'  RX4O   STH     LA      STC     IC        16         
         DC    X'16181818'    44   EX      BAL     BCT     BC        17         
         DC    X'121A1A1A'    48   LH      CH      AH      SH        18         
         DC    X'12121414'    4C   MH      ...     CVD     CVB       19         
         DC    X'141C1C1C'    50   ST      ...     ...     ...       20         
         DC    X'1E1E1E1E'    54   N       CL      O       X         21         
         DC    X'141E1E1E'    58   L       C       A       S         22         
         DC    X'14141E1E'    5C   M       D       AL      SL        23         
         DC    X'201C1C1C'    60   STD     ...     ...     ...       24         
         DC    X'1C1C1C1C'    64   ...     ...     ...     ...       25         
         DC    X'20222222'    68   LD      CD      AD      SD        26         
         DC    X'20202222'    6C   MD      DD      AW      SW        27         
         DC    X'241C1C1C'    70   STE     ...     ...     ...       28         
         DC    X'1C1C1C1C'    74   ...     ...     ...     ...       29         
         DC    X'24262626'    78   LE      CE      AE      SE        30         
         DC    X'24242626'    7C   ME      DE      AU      SU        31         
         DC    X'28282828'  RS80  *SSM     ...    *LPSW    ...       32         
         DC    X'28282A2A'    84  *WRD    *RDD     BXH     BXLE      33         
         DC    X'2C2C2E2E'    88   SRL     SLL     SRA     SLA       34         
         DC    X'44444646'    8C   SRDL    SLDL    SRDA    SLDA      35         
         DC    X'30323436'  SI90   STM     TM      MVI    *TS        36         
         DC    X'32323232'    94   NI      CLI     0I      XI        37         
         DC    X'30383838'    98   LM      ...     ...     ...       38         
         DC    X'38383838'    9C  *SI0    *TI0    *HI0    *TCH       39         
         DC    X'38383838'    A0   ...     ...     ...     ...       40         
         DC    X'38383838'    A4   ...     ...     ...     ...       41         
         DC    X'38383838'    A8   ...     ...     ...     ...       42         
         DC    X'38383838'    AC   ...     ...     ...     ...       43         
         DC    X'38383838'    B0   ...     ...     ...     ...       44         
         DC    X'38383838'    B4   ...     ...     ...     ...       45         
         DC    X'38383838'    B8   ...     ...     ...     ...       46         
         DC    X'38383838'    BC   ...     ...     ...     ...       47         
         DC    X'3A3A3A3A'  SSC0   ...     ...     ...     ...       48         
         DC    X'3A3A3A3A'    C4   ...     ...     ...     ...       49         
         DC    X'3A3A3A3A'    C8   ...     ...     ...     ...       50         
         DC    X'3A3A3A3A'    CC   ...     ...     ...     ...       51         
         DC    X'3A3C3C3C'    D0   ...     MVN     MVC     MVZ       52         
         DC    X'3E3E3E3E'    D4   NC      CLC     0C      XC        53         
         DC    X'3A3A3A3A'    D8   ...     ...     ...     ...       54         
         DC    X'3E3E3E3E'    DC   TR      TRT     ED      EDMK      55         
         DC    X'3A3A3A3A'    E0   ...     ...     ...     ...       56         
         DC    X'3A3A3A3A'    E4   ...     ...     ...     ...       57         
         DC    X'3A3A3A3A'    E8   ...     ...     ...     ...       58         
         DC    X'3A3A3A3A'    EC   ...     ...     ...     ...       59         
         DC    X'3A404040'    F0   ...     MVO     PACK    UNPK      60         
         DC    X'3A3A3A3A'    F4   ...     ...     ...     ...       61         
         DC    X'42424242'    F8   ZAP     CP      AP      SP        62         
         DC    X'40403A3A'    FC   MP      DP      ...     ...       63         
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              *   INDICATES A PRIVLEDGED INSTRUCTION                 *         
*                                                                     *         
*              ... INDICATES A NON-EXISTENT INSTRUCTION               *         
*                                                                     *         
***********************************************************************         
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              SYMBOLIC INSTRUCTION CODES FOR PRINTING                *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BCDOP    DS    0F                                                               
         DC    C'                SPM BALRBCTRBCR '                  000         
         DC    C'SSK ISK SVC                     '                  020         
         DC    C'LPR LNR LTR LCR NR  CLR OR  XR  '                  040         
         DC    C'LR  CR  AR  SR  MR  DR  ALR SLR '                  060         
         DC    C'LPDRLNDRLTDRLCDRHDR             '                  080         
         DC    C'LDR CDR ADR SDR MDR DDR AWR SWR '                  0A0         
         DC    C'LPERLNERLTERLCERHER             '                  0C0         
         DC    C'LER CER AER SER MER DER AUR SUR '                  0E0         
         DC    C'STH LA  STC IC  EX  BAL BCT BC  '                  100         
         DC    C'LH  CH  AH  SH  MH      CVD CVB '                  120         
         DC    C'ST              N   CL  O   X   '                  140         
         DC    C'L   C   A   S   M   D   AL  SL  '                  160         
         DC    C'STD                             '                  180         
         DC    C'LD  CD  AD  SD  MD  DD  AW  SW  '                  1A0         
         DC    C'STE                             '                  1C0         
         DC    C'LE  CE  AE  SE  ME  DE  AU  SU  '                  1E0         
         DC    C'SSM     LPSW    WRD RDD BXH BXLE'                  200         
         DC    C'SRL SLL SRA SLA SRDLSLDLSRDASLDA'                  220         
         DC    C'STM TM  MVI TS  NI  CLI OI  XI  '                  240         
         DC    C'LM              SIO TIO HIO TCH '                  260         
         DC    C'                                '                  280         
         DC    C'                                '                  2A0         
         DC    C'                                '                  2C0         
         DC    C'                                '                  2E0         
         DC    C'                                '                  300         
         DC    C'                                '                  320         
         DC    C'    MVN MVC MVZ NC  CLC OC  XC  '                  340         
         DC    C'                TR  TRT ED  EDMK'                  360         
         DC    C'                                '                  380         
         DC    C'                                '                  3A0         
         DC    C'    MVO PACKUNPK                '                  3C0         
         DC    C'ZAP CP  AP  SP  MP  DP          '                  3E0         
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              THE  END                                               *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 5                                                                
DATAEND  DS    0H                      END OF TRACE ROUTINE DATA AREA           
         SPACE 4                                                                
         END                                                                    