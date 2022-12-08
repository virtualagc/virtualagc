XMON     TITLE 'XPLSM SUBMONITOR FOR THE XPL COMPILER SYSTEM'                   
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        XPLSM    SUBMONITOR FOR THE XPL COMPILER GENERATOR SYSTEM    *         
*                                                                     *         
*                                                                     *         
*                                  DAVID B. WORTMAN                   *         
*                                  STANFORD UNIVERSITY                *         
*                                  MARCH  1969                        *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         EJECT                                                                  
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        DEFINE PARAMETRIC CONSTANTS FOR XPLSM                        *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         GBLA  &INPUTS             NUMBER OF INPUT FILES                        
         GBLA  &OUTPUTS            NUMBER OF OUTPUT FILES                       
         GBLA  &FILES              NUMBER OF DIRECT ACCESS FILES                
         LCLA  &I                  VARIABLE FOR ITERATION LOOPS                 
         SPACE 5                                                                
IOPACK   CSECT                                                                  
         SPACE 2                                                                
&INPUTS  SETA  3                   INPUT(I),   I = 0,1,2,3                      
         SPACE 1                                                                
&OUTPUTS SETA  3                   OUTPUT(I),  I = 0,1,2,3                      
         SPACE 1                                                                
&FILES   SETA  3                   FILE(I,*),  I = 1,2,3                        
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        FILEBYTS DETERMINES THE BLOCKSIZE FOR DIRECT ACCESS FILE     *         
*        I/O.  IT SHOULD BE EQUAL TO THE VALUE OF THE LITERAL         *         
*        CONSTANT 'DISKBYTES' IN THE XCOM COMPILER FOR COMPILATION    *         
*        TO WORK SUCCESSFULLY.  THE VALUE OF FILEBYTS WHICH IS        *         
*        ASSEMBLED IN MAY BE OVERIDDEN BY THE 'FILE=NNNN' PARAMETER   *         
*        ON THE OS/360 EXEC CARD.                                     *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        DEVICE       ALLOWABLE RANGE         SUGGESTED VALUE         *         
*                                                                     *         
*        2311      80 <= FILEBYTS <= 3624        3600                 *         
*                                                                     *         
*        2314      80 <= FILEBYTS <= 7294        7200                 *         
*                                                                     *         
*        2321      80 <= FILEBYTS <= 2000        2000                 *         
*                                                                     *         
*                                                                     *         
*        LARGER VALUES MAY BE USED FOR FILEBYTS IF THE SUBMONITOR     *         
*        IS REASSEMBLED WITH  RECFM=FT  SPECIFIED IN THE DCBS FOR     *         
*        THE DIRECT ACCESS FILES.                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
FILEBYTS EQU   3600                2311  DISKS                                  
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        BLKSIZE DEFAULT FOR SOME INPUT AND OUTPUT FILES.  SEE THE    *         
*        EXIT LIST HANDLING ROUTINE GENXT.  SHOULD BE THE LARGEST     *         
*        MULTIPLE OF 80 THAT IS LESS THAN OR EQUAL TO FILEBYTS        *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
IOFBYTS  EQU   80*(FILEBYTS/80)                                                 
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DEFINE THE REGISTERS USED TO PASS PARAMETERS TO THE          *         
*        SUBMONITOR FROM THE XPL PROGRAM                              *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
SVCODE   EQU   1                   CODE INDICATING SERVICE REQUESTED            
         SPACE 1                                                                
PARM1    EQU   0                   FIRST PARAMETER                              
         SPACE 1                                                                
PARM2    EQU   2                   SECOND PARAMETER                             
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DEFINE THE SERVICE CODES USED BY THE XPL PROGRAM TO          *         
*        INDICATE SERVICE REQUESTS TO THE SUBMONITOR                  *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 3                                                                
GETC     EQU   4                   SEQUENTIAL INPUT                             
         SPACE 1                                                                
PUTC     EQU   8                   SEQUENTIAL OUTPUT                            
         SPACE 1                                                                
TRC      EQU   12                  INITIATE TRACING                             
         SPACE 1                                                                
UNTR     EQU   16                  TERMINATE TRACING                            
         SPACE 1                                                                
EXDMP    EQU   20                  FORCE A CORE DUMP                            
         SPACE 1                                                                
GTIME    EQU   24                  RETURN TIME AND DATE                         
         SPACE 1                                                                
RSVD1    EQU   28                  (UNUSED)                                     
         SPACE 1                                                                
RSVD2    EQU   32                  CLOCK_TRAP        (NOP IN XPLSM)             
         SPACE 1                                                                
RSVD3    EQU   36                  INTERRUPT_TRAP    (NOP IN XPLSM)             
         SPACE 1                                                                
RSVD4    EQU   40                  MONITOR           (NOP IN XPLSM)             
         SPACE 1                                                                
RSVD5    EQU   44                  (UNUSED)                                     
         SPACE 1                                                                
RSVD6    EQU   48                  (UNUSED)                                     
         SPACE 1                                                                
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        GENERATE THE SERVICE CODES FOR DIRECT ACCESS FILE I/O        *         
*        BASED ON THE NUMBER OF FILES AVAILABLE  (&FILES)             *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
FILEORG  EQU   RSVD6+4             ORIGIN FOR THE FILE SERVICE CODES            
         SPACE 1                                                                
&I       SETA  1                                                                
.SC1     AIF   (&I GT &FILES).SC2                                               
RD&I     EQU   FILEORG+8*(&I-1)    CODE FOR READING FILE&I                      
WRT&I    EQU   FILEORG+8*(&I-1)+4  CODE FOR WRITING FILE&I                      
&I       SETA  &I+1                                                             
         AGO   .SC1                                                             
.SC2     ANOP                                                                   
         SPACE 2                                                                
ENDSERV  EQU   FILEORG+8*(&I-1)    1ST UNUSED SERVICE CODE                      
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DEFINE REGISTER USAGE                                        *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
RTN      EQU   3                   REGISTER CONTAINING COMPLETION               
*                                  CODE RETURNED BY THE PROGRAM                 
         SPACE 1                                                                
EBR      EQU   10                  BASE REGISTER USED DURING                    
*                                  INITIALIZATION                               
         SPACE 1                                                                
CBR      EQU   12                  LINKAGE REGISTER USED FOR CALLS              
*                                  TO THE SUBMONITOR                            
         SPACE 1                                                                
SELF     EQU   15                  REGISTER THAT ALWAYS CONTAINS                
*                                  THE ADDRESS OF THE SUBMONITOR                
*                                  ENTRY POINT                                  
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        BIT CONSTANTS NEEDED FOR CONVERSING WITH OS/360 DCBS         *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
OPENBIT  EQU   B'00010000'         DCBOFLGS BIT INDICATING OPEN                 
*                                  SUCCESSFULLY COMPLETED                       
         SPACE 1                                                                
TAPEBITS EQU   B'10000001'         BITS INDICATING A MAGNETIC TAPE              
         SPACE 1                                                                
KEYLBIT  EQU   B'00000001'         BIT IN RECFM THAT INDICATES                  
*                                  KEYLEN WAS SET EXPLICITELY ZERO              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        FLAG BITS USED TO CONTROL SUBMONITOR OPERATION               *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
ALLBITS  EQU   B'11111111'         MASK                                         
         SPACE 1                                                                
TRACEBIT EQU   B'10000000'         BEGIN EXECUTION OF THE PROGRAM               
*                                  IN TRACE MODE                                
         SPACE 1                                                                
SFILLBIT EQU   B'01000000'         1 CHARACTER OF FILL NEEDED BY                
*                                  THE PUT ROUTINE                              
         SPACE 1                                                                
LFILLBIT EQU   B'00100000'         LONGER FILL NEEDED BY PUT ROUTINE            
         SPACE 1                                                                
DUMPBIT  EQU   B'00001000'         GIVE A CORE DUMP FOR I/O ERRORS              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*              DEFINE ABEND CODES ISSUED BY THE SUBMONITOR            *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
OPENABE  EQU   100                 UNABLE TO OPEN ONE OF THE FILES:             
*                                  PROGRAM, SYSIN, OR SYSPRINT                  
         SPACE 1                                                                
PGMEOD   EQU   200                 UNEXPECTED END OF FILE WHILE                 
*                                  READING IN THE XPL PROGRAM                   
         SPACE 1                                                                
PGMERR   EQU   300                 SYNAD ERROR WHILE READING IN                 
*                                  THE XPL PROGRAM                              
         SPACE 1                                                                
COREABE  EQU   400                 XPL PROGRAM WON'T FIT IN                     
*                                  THE AMOUNT OF MEMORY AVAILABLE               
         SPACE 1                                                                
CODEABE  EQU   500                 INVALID SERVICE CODE FROM THE                
*                                  XPL PROGRAM                                  
         SPACE 1                                                                
OUTSYND  EQU   800                 SYNAD ERROR ON OUTPUT FILE                   
         SPACE 1                                                                
PFABE    EQU   900                 INVALID OUTPUT FILE SPECIFIED                
         SPACE 1                                                                
INSYND   EQU   1000                SYNAD ERROR ON INPUT FILE                    
         SPACE 1                                                                
INEODAB  EQU   1200                END OF FILE ERROR ON INPUT FILE              
         SPACE 1                                                                
GFABE    EQU   1400                INVALID INPUT FILE SPECIFIED                 
         SPACE 1                                                                
FLSYND   EQU   2000                SYNAD ERROR ON DIRECT ACCESS FILE            
         SPACE 1                                                                
FLEOD    EQU   2200                END OF FILE ERROR ON DIRECT                  
*                                  ACCESS FILE                                  
         SPACE 1                                                                
USERABE  EQU   4000                XPL PROGRAM CALLED EXIT TO                   
*                                  FORCE A CORE DUMP                            
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        SUBMONITOR  INITIALIZATION                                   *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 3                                                                
         ENTRY XPLSM               WHERE OS ENTERS THE SUBMONITOR               
         SPACE 2                                                                
         DS    0F                                                               
         USING *,15                                                             
         SPACE 1                                                                
XPLSM    SAVE  (14,12),T,*         SAVE ALL REGISTERS                           
         ST    13,SAVE+4           SAVE RETURN POINTER                          
         LA    15,SAVE             ADDRESS OF SUBMONITOR'S OS SAVE AREA         
         ST    15,8(0,13)                                                       
         LR    13,15                                                            
         USING SAVE,13                                                          
         BALR  EBR,0               BASE ADDRESS FOR INITIALIZATION              
         USING *,EBR                                                            
BASE1    DS    0H                                                               
         DROP  15                                                               
         L     1,0(,1)             ADDRESS OF A POINTER TO THE PARM             
*                                  FIELD OF THE OS EXEC CARD                    
         ST    1,CONTROL           SAVE ADDRESS FOR THE TRACE ROUTINE           
         MVI   FLAGS,B'00000000'   RESET ALL FLAGS                              
         LH    4,0(,1)             LENGTH OF THE PARM FIELD                     
         LA    1,2(,1)             ADDRESS OF THE PARM STRING                   
         LA    4,0(1,4)            ADDRESS OF END OF PARAMETER LIST             
         LA    7,PARMSCAN                                                       
         SPACE 2                                                                
PARMSCAN DS    0H                                                               
         CR    1,4                 ARE WE DONE ?                                
         BNL   NOPARMS             YES, SO QUIT LOOKING                         
         CLC   TRCM,0(1)           LOOK FOR 'TRACE'                             
         BNE   PS2                 NOT FOUND                                    
         OI    FLAGS,TRACEBIT      SET FLAG TO BEGIN IN TRACE MODE              
         LA    1,L'TRCM+1(,1)      INCREMENT POINTER                            
         BR    7                   BRANCH BACK TO TEST                          
PS2      CLC   ALTRM,0(1)          TEST FOR 'ALTER'                             
         BNE   PS3                 NOT FOUND                                    
         MVC   FREEUP,ALTFREE      MAKE MORE ROOM FOR ALTER                     
         LA    1,L'ALTRM+1(,1)     INCREMENT POINTER                            
         BR    7                   BRANCH BACK TO TEST                          
PS3      CLC   CMNM,0(1)           LOOK FOR 'MIN=NNNN'                          
         BNE   PS4                 NOT FOUND                                    
         BAL   CBR,DIGET           GO GET THE NUMBER                            
         ST    3,COREMIN           SET NEW MINIMUM VALUE                        
         BR    7                   BRANCH TO TEST                               
PS4      CLC   CMXM,0(1)           CHECK FOR 'MAX=MMMM'                         
         BNE   PS5                 NOT FOUND                                    
         BAL   CBR,DIGET           GO GET THE VALUE                             
         ST    3,COREMAX           SET NEW MAXIMUM VALUE                        
         BR    7                   BRANCH TO TEST                               
PS5      CLC   FREEM,0(1)          CHECK FOR 'FREE=NNNN'                        
         BNE   PS6                 NOT FOUND                                    
         BAL   CBR,DIGET           GO GET THE VALUE                             
         ST    3,FREEUP            SET NEW AMOUNT FREED                         
         BR    7                   BRANCH TO TEST                               
PS6      CLC   DMPM,0(1)           CHECK FOR 'DUMP'                             
         BNE   PS7                 NOT FOUND                                    
         OI    FLAGS,DUMPBIT       SET DUMP ON ERROR FLAG                       
         LA    1,L'DMPM+1(,1)      INCREMENT POINTER                            
         BR    7                   BRANCH TO TEST                               
PS7      CLC   FILEM,0(1)          CHECK FOR 'FILE=MMMM'                        
         BNE   PSBUMP              NOT FOUND                                    
         BAL   CBR,DIGET           GET THE BLKSIZE VALUE                        
         LA    2,&FILES*2          NUMBER OF DCB FOR FILES                      
         LA    5,ARWDCBS           ADDRESS OF DCB LIST                          
FLOOP    L     6,0(,5)             ADDRESS OF A DCB                             
         USING IHADCB,6                                                         
         STH   3,DCBLRECL          SET NEW RECORD LENGTH                        
         STH   3,DCBBLKSI          SET NEW BLOCKSIZE                            
         DROP  6                                                                
         LA    5,4(,5)             INCREMENT ADDRESS                            
         BCT   2,FLOOP             LOOP BACK                                    
         SLL   3,2                 (NEW BLOCKSIZE)*4                            
         ST    3,ALTFREE           ALTER PARAMETER                              
         BR    7                   GO TO SCAN LOOP                              
PSBUMP   LA    1,1(,1)             INCREMENT POINTER TO PARM STRING             
         BR    7                   BRANCH TO TEST                               
NOPARMS  DS    0H                                                               
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        OPEN THE FILES  PROGRAM, SYSIN, AND SYSPRINT                 *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         OPEN  (INPUT0,(INPUT),OUTPUT0,(OUTPUT),PROGRAM,(INPUT))                
         SPACE 1                                                                
         L     3,GETDCBS           ADDRESS OF DCB FOR INPUT0                    
         USING IHADCB,3                                                         
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING                 
         BZ    BADOPEN             INPUT0 NOT OPENED SUCCESSFULLY               
         L     3,PUTDCBS           ADDRESS OF DCB FOR OUTPUT0                   
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING                 
         BZ    BADOPEN             OUTPUT0 NOT OPENED SUCCESSFULLY              
         L     3,PGMDCB            ADDRESS OF DCB FOR PROGRAM                   
         TM    DCBOFLGS,OPENBIT    TEST FOR SUCCESSFUL OPENING                  
         BNZ   OPENOK              PROGRAM SUCCESSFULLY OPENED                  
         DROP  3                                                                
         SPACE 2                                                                
BADOPEN  LA    1,OPENABE           ABEND BECAUSE FILES DIDN'T OPEN              
*                                  PROPERLY                                     
         B     ABEND               GO TO ABEND ROUTINE                          
         SPACE 2                                                                
OPENOK   DS    0H                                                               
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        NOW OBTAIN SPACE IN MEMORY FOR THE XPL PROGRAM AND ITS       *         
*        FREE STRING AREA.  A GETMAIN IS ISSUED TO OBTAIN AS MUCH     *         
*        MEMORY AS POSSIBLE WITHIN THE PARTITION.  THEN A FREEMAIN    *         
*        IS ISSUED TO RETURN THE AMOUNT OF MEMORY SPECIFIED BY        *         
*        THE VARIABLE 'FREEUP' TO OS/360 FOR USE AS WORK SPACE.       *         
*        OS/360 NEEDS SPACE FOR FOR DYNAMICALLY CREATING BUFFERS      *         
*        FOR THE SEQUENTIAL INPUT AND OUTPUT FILES AND FOR            *         
*        OVERLAYING I/O ROUTINES.                                     *         
*                                                                     *         
*           THE AMOUNT OF CORE REQUESTED FROM OS/360 CAN BE ALTERED   *         
*        WITH THE 'MAX=NNNN' AND 'MIN=MMMM' PARAMETERS TO THE         *         
*        SUBMONITOR.  THE AMOUNT OF CORE RETURNED TO OS/360 CAN BE    *         
*        ALTERED WITH THE 'FREE=NNNN' OR THE 'ALTER' PARAMETER        *         
*                                                                     *         
*                                                                     *         
*        MEMORY REQUEST IS DEFINED BY THE CONTROL BLOCK STARTING AT   *         
*        'COREREQ'.  THE DESCRIPTION OF THE MEMORY SPACE OBTAINED     *         
*        IS PUT INTO THE CONTROL BLOCK STARTING AT 'ACORE'.           *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         GETMAIN VU,LA=COREREQ,A=ACORE                                          
         SPACE 1                                                                
         LM    1,2,ACORE           ADDRESS OF CORE OBTAINED TO R1               
*                                  LENGTH OF CORE AREA TO R2                    
         AR    1,2                 ADDRESS OF TOP OF CORE AREA                  
         S     1,FREEUP            LESS AMOUNT TO BE RETURNED                   
         ST    1,CORETOP           ADDRESS OF TOP OF USABLE CORE                
*                                  (BECOMES 'FREELIMIT')                        
         S     2,FREEUP            SUBTRACT AMOUNT RETURNED                     
         ST    2,CORESIZE          SIZE OF AVAILABLE SPACE                      
         L     0,FREEUP            AMOUNT TO GIVE BACK                          
         SPACE 1                                                                
         FREEMAIN R,LV=(0),A=(1)   GIVE 'FREEUP' BYTES OF CORE BACK             
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        READ IN THE BINARY XPL PROGRAM AS SPECIFIED BY THE           *         
*                                                                     *         
*        //PROGRAM  DD  .....                                         *         
*                                                                     *         
*        CARD.  IT IS ASSUMED THAT THE BINARY PROGRAM IS IN STANDARD  *         
*        XPL SYSTEM FORMAT.                                           *         
*                                                                     *         
*                                                                     *         
*        THE 1ST RECORD OF THE BINARY PROGRAM FILE SHOULD BEGIN       *         
*        WITH A BLOCK OF INFORMATION DESCRIBING THE CONTENTS OF       *         
*        THE FILE.  THE FORMAT OF THIS BLOCK IS GIVEN IN THE DSECT    *         
*        'FILECTRL' AT THE END OF THIS ASSEMBLY.                      *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         L     2,ACORE             ADDRESS OF START OF CORE AREA                
         LR    4,2                 SAVE STARTING ADDRESS                        
         USING FILECTRL,4          ADDRESS OF CONTROL BLOCK                     
         ST    2,CODEADR           SAVE STARTING ADDRESS FOR USE                
*                                  BY THE XPL PROGRAM                           
         BAL   CBR,READPGM         READ IN 1ST RECORD                           
         L     3,BYTSCODE          NUMBER OF BYTES OF CODE                      
         S     3,BYTSBLK           LESS ONE RECORD                              
         A     3,BYTSFULL          PLUS AMOUNT IN LAST CODE RECORD              
         A     3,BYTSDATA          PLUS SIZE OF DATA AREA                       
         C     3,CORESIZE          COMPARE WITH SPACE AVAILABLE                 
         LA    1,COREABE           ABEND CODE FOR NO ROOM IN CORE               
         BH    ABEND               WON'T FIT, SO ABEND                          
         L     5,BLKSCODE          NUMBER OF RECORDS OF CODE                    
         L     3,BYTSBLK           NUMBER OF BYTES PER RECORD                   
         B     LOAD1               GO TEST FOR MORE CODE RECORDS                
         SPACE 1                                                                
RCODE    AR    2,3                 ADDRESS TO PUT NEXT RECORD                   
         BAL   CBR,READPGM         READ IN THE BINARY XPL PROGRAM               
LOAD1    BCT   5,RCODE             LOOP BACK TO GET NEXT RECORD                 
         SPACE 1                                                                
         A     2,BYTSFULL          NUMBER OF BYTES ACTUALLY                     
*                                  USED IN LAST CODE RECORD                     
         ST    2,DATADR            SAVE ADDRESS OF DATA AREA                    
*                                  FOR USE BY THE XPL PROGRAM                   
         L     5,BLKSDATA          NUMBER OF RECORDS OF DATA                    
         SPACE 1                                                                
RDATA    BAL   CBR,READPGM         READ IN THE XPL PROGRAM'S DATA AREA          
         AR    2,3                 ADDRESS TO PUT NEXT RECORD                   
         BCT   5,RDATA             LOOP BACK FOR NEXT RECORD                    
         DROP  4                                                                
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        CODE TO BRANCH TO THE XPL PROGRAM                            *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         LA    SELF,ENTRY          ADDRESS OF ENTRY POINT TO XPLSM              
         TM    FLAGS,TRACEBIT      START IN TRACE MODE ?                        
         BO    BEGTRC              YES, BEGIN TRACING                           
         LM    0,3,PGMPARMS        PARAMETERS FOR THE XPL PROGRAM               
         DROP  EBR,13                                                           
         USING ENTRY,SELF                                                       
         SPACE 2                                                                
         USING FILECTRL,2          ADDRESS OF FIRST RECORD OF CODE              
GOC      BAL   CBR,CODEBEGN        BRANCH TO HEAD OF THE XPL PROGRAM            
         DROP  2                                                                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        THE XPL PROGRAM RETURNS HERE AT THE END OF EXECUTION         *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         L     EBR,ABASE1          REGISTER FOR ADDRESSABILITY                  
         USING BASE1,EBR                                                        
         ST    RTN,RTNSV           SAVE COMPLETION CODE RETURNED BY             
*                                  THE XPL PROGRAM FOR PASSING TO OS            
         LA    1,UNTR              TURN OFF POSSIBLE TRACE                      
         BALR  CBR,SELF            CALL THE SERVICE ROUTINES                    
         L     13,ASAVE            ADDRESS OF OS/360 SAVE AREA                  
         USING SAVE,13                                                          
         DROP  SELF                                                             
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        RELEASE THE MEMORY OCCUPPIED BY THE XPL PROGRAM              *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
SMRET    L     1,ACORE             ADDRESS OF THE BLOCK TO BE FREED             
         L     0,CORESIZE          LENGTH OF THE BLOCK TO BE FREED              
         SPACE 1                                                                
         FREEMAIN R,LV=(0),A=(1)   FREEDOM NOW !                                
         SPACE 1                                                                
         CLOSE (INPUT0,,OUTPUT0)                                                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        WARNING,  THE CLOSE OF INPUT0 AND OUTPUT0 MUST PRECEDE       *         
*        THE CLOSE WHICH USES THE GETDCBS LIST.  THE CLOSE SVC WILL   *         
*        LOOP INDEFINITELY IF THE SAME DCB ADDRESS APPEARS TWICE IN   *         
*        A CLOSE LIST.                                                *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         CLOSE ,MF=(E,GETDCBS)     CLOSE ALL FILE KNOWN TO XPLSM                
         SPACE 1                                                                
         L     15,RTNSV            LOAD RETURN CODE                             
         L     13,SAVE+4                                                        
         DROP  13                                                               
         RETURN (14,12),RC=(15)    RETURN TO OS/360                             
         SPACE 1                                                                
         DROP  EBR                                                              
         USING SAVE,13                                                          
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        CONSTANTS USED DURING INITIALIZATION                         *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
SAVE     DS    18F                 SAVE AREA FOR OS/360                         
ACORE    DS    A                   ADDRESS OF CORE FOR THE PROGRAM              
CORESIZE DS    F                   SIZE OF CORE IN BYTES                        
CONTROL  DS    A                   ADDRESS OF PARAMETER STRING PASSED           
*                                  TO THE SUBMONITOR BY OS/360                  
COREREQ  DS    0F                  CORE REQUEST CONTROL BLOCK                   
COREMIN  DC    F'110000'           MINIMUM AMOUNT OF CORE REQUIRED              
COREMAX  DC    F'5000000'          MAXIMUM AMOUNT OF CORE REQUESTED             
FREEUP   DC    A(2*FILEBYTS)       AMOUNT OF CORE TO RETURN TO OS               
ALTFREE  DC    A(4*FILEBYTS)       AMOUNT OF CORE FREED FOR ALTER               
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        BLOCK OF PARAMETERS PASSED TO THE XPL PROGRAM                *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
PGMPARMS DS    F                   R0  UNUSED                                   
CORETOP  DC    A(0)                R1  ADDRESS OF TOP OF CORE                   
CODEADR  DC    F'0'                R2  ADDRESS OF START OF 1ST RECORD           
*                                  OF THE XPL PROGRAM                           
DATADR   DC    F'0'                R3  ADDRESS OF THE START OF THE XPL          
*                                      PROGRAM'S DATA AREA                      
         SPACE 1                                                                
TRCM     DC    CL5'TRACE'                                                       
ALTRM    DC    CL5'ALTER'                                                       
CMNM     DC    CL4'MIN='                                                        
CMXM     DC    CL4'MAX='                                                        
FREEM    DC    CL5'FREE='                                                       
DMPM     DC    CL4'DUMP'                                                        
FILEM    DC    CL5'FILE='                                                       
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        ROUTINE TO SCAN PARAMETER STRINGS FOR DIGITS                 *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
DIGET    DS    0H                                                               
         SR    2,2                 CLEAR REGISTER                               
         SR    3,3                  "                                           
DG1      CLI   0(1),C'='           CHECK FOR '='                                
         BE    DG2                                                              
         LA    1,1(,1)             INCREMENT POINTER                            
         CR    1,4                 AT END ?                                     
         BCR   B'0100',CBR         YES, SO RETURN                               
         B     DG1                 KEEP LOOKING FOR '='                         
DG2      LA    1,1(,1)             INCREMENT POINTER                            
         LA    5,C'0'              BINARY VALUE OF '0'                          
DGLP     IC    2,0(,1)             FETCH A CHARACTER                            
         SR    2,5                 NORMALIZE                                    
         BM    DGDN                NOT A DIGIT SO DONE                          
         LR    0,3                                                              
         SLL   3,2                 NUMBER*4                                     
         AR    3,0                 NUMBER*5                                     
         SLL   3,1                 NUMBER*10                                    
         AR    3,2                 ADD IN NEW DIGIT                             
         LA    1,1(,1)             INCREMENT POINTER                            
         CR    1,4                 AT END ?                                     
         BL    DGLP                NO                                           
DGDN     LA    1,1(,1)             INCREMENT POINTER                            
         BR    CBR                 RETURN                                       
*                                  VALUE OF NUMBER IS IN REG 3                  
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        ROUTINE TO READ IN THE BINARY IMAGE OF THE XPL PROGRAM       *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
READPGM  DS    0H                                                               
*                                  SHARE DECB WITH FILE READ ROUTINE            
         SPACE 1                                                                
         READ  RDECB,SF,PROGRAM,(2),MF=E                                        
         CHECK RDECB               WAIT FOR READ TO COMPLETE                    
         SPACE 1                                                                
         BR    CBR                 RETURN TO CALLER                             
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        ROUTINES TO PROVIDE DEFAULT DATASET INFORMATION IF NONE      *         
*        IS PROVIDED BY JCL OR VOLUME LABELS.  IN PARTICULAR,         *         
*        BLKSIZE, LRECL, BUFNO, AND RECFM INFORMATION.                *         
*                                                                     *         
*                                                                     *         
*        EXIT LISTS FOR DCBS                                          *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         DS    0F                                                               
INEXIT0  DC    X'85'               INPUT0                                       
         DC    AL3(INXT0)                                                       
         SPACE 1                                                                
OUTEXIT0 DC    X'85'               OUTPUT0                                      
         DC    AL3(OUTXT0)                                                      
         SPACE 1                                                                
INEXIT2  DC    X'85'               INPUT2                                       
         DC    AL3(INXT2)                                                       
         SPACE 1                                                                
OUTEXIT2 EQU   INEXIT0             OUTPUT2                                      
         SPACE 2                                                                
&I       SETA  3                                                                
.IDF1    AIF   (&I GT &INPUTS).IDF2                                             
INEXIT&I EQU   INEXIT2             INPUT&I                                      
&I       SETA  &I+1                                                             
         AGO   .IDF1                                                            
.IDF2    ANOP                                                                   
         SPACE 1                                                                
&I       SETA  3                                                                
.ODF1    AIF   (&I GT &OUTPUTS).ODF2                                            
OUTEXIT&I EQU  INEXIT2                                                          
&I       SETA  &I+1                                                             
         AGO   .ODF1                                                            
.ODF2    ANOP                                                                   
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        DCB EXIT ROUTINE ENTRY POINTS                                *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
INXT0    MVC   DEFAULTS(6),INDFLT0                                              
         B     GENXT                                                            
         SPACE 1                                                                
INXT2    MVC   DEFAULTS(6),INDFLT2                                              
         B     GENXT                                                            
         SPACE 1                                                                
OUTXT0   MVC   DEFAULTS(6),OUTDFLT0                                             
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DCB EXIT LIST PROCESSING ROUTINE FOR OPEN EXITS              *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
GENXT    DS    0H                                                               
         USING IHADCB,1            REGISTER 1 POINTS AT THE DCB                 
         NC    DCBBLKSI,DCBBLKSI   CHECK BLKSIZE                                
         BNZ   GXT1                ALREADY SET                                  
         MVC   DCBBLKSI(2),DFLTBLKS                                             
*                                  PROVIDE DEFAULT BLOCKSIZE                    
         SPACE 1                                                                
GXT1     NC    DCBLRECL,DCBLRECL   CHECK LRECL                                  
         BNZ   GXT2                ALREADY SET                                  
         MVC   DCBLRECL(2),DFLTLREC                                             
*                                  PROVIDE DEFAULT LRECL                        
         SPACE 1                                                                
GXT2     CLI   DCBBUFNO,0          CHECK BUFNO                                  
         BNE   GXT3                ALREADY SPECIFIED                            
         MVC   DCBBUFNO(1),DFLTBUFN                                             
*                                  PROVIDE DEFAULT BUFNO                        
         SPACE 1                                                                
GXT3     TM    DCBRECFM,ALLBITS-KEYLBIT                                         
*                                  CHECK RECFM                                  
         BCR   B'0111',14          ALREADY SET SO RETURN                        
         OC    DCBRECFM(1),DFLTRECF                                             
*                                  PROVIDE DEFAULT RECFM                        
         BR    14                  RETURN                                       
         DROP  1                                                                
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        ARRAY OF DEFAULT ATTRIBUTES USED BY GENXT                    *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
DEFAULTS DS    0H                                                               
DFLTBLKS DS    1H                  DEFAULT BLKSIZE                              
DFLTLREC DS    1H                  DEFAULT LRECL                                
DFLTBUFN DS    AL1                 DEFAULT BUFNO                                
DFLTRECF DS    1BL1                DEFAULT RECFM                                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        DEFINE ATTRIBUTES PROVIDED FOR THE VARIOUS FILES             *         
*                                                                     *         
*        INPUT(0), INPUT(1), OUTPUT(2)                                *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
INDFLT0  DS    0H                                                               
         DC    H'80'               BLKSIZE=80                                   
         DC    H'80'               LRECL=80                                     
         DC    AL1(2)              BUFNO=2                                      
         DC    B'10000000'         RECFM=F                                      
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        OUTPUT(0), OUTPUT(1)                                         *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
OUTDFLT0 DS    0H                                                               
         DC    H'133'              BLKSIZE=133                                  
         DC    H'133'              LRECL=133                                    
         DC    AL1(2)              BUFNO=2                                      
         DC    B'10000100'         RECFM=FA                                     
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        INPUT(2), INPUT(3), OUTPUT(3)                                *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
INDFLT2  DS    0H                                                               
         DC    AL2(IOFBYTS)        BLKSIZE=IOFBYTS                              
         DC    H'80'               LRECL=80                                     
         DC    AL1(1)              BUFNO=1                                      
         DC    B'10010000'         RECFM=FB                                     
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        INPUT - OUTPUT  ERROR ROUTINES                               *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        SYNAD AND EOD ERROR ROUTINES FOR INITIAL LOADING OF THE      *         
*        XPL PROGRAM                                                  *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
EODPGM   STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,PGMEOD            UNEXPECTED EOD WHILE READING IN              
*                                  THE XPL PROGRAM                              
         B     ABEND               GO TO ABEND ROUTINE                          
         SPACE 2                                                                
ERRPGM   STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,PGMERR            SYNAD ERROR WHILE READING IN THE             
*                                  XPL PROGRAM                                  
         B     ABEND               GO TO ABEND ROUTINE                          
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        SYNAD AND EOD ROUTINES FOR INPUT(I),  I = 0,1, ...  ,&INPUTS *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
INEOD    L     2,SAVREG+PARM2*4    PICK UP SUBCODE SPECIFYING WHICH             
*                                  INPUT FILE                                   
         SLL   2,2                 SUBCODE*4                                    
         L     2,GETDCBS(2)        FETCH DCB ADDRESS                            
         USING IHADCB,2                                                         
         ST    2,OCDCB             STORE IT FOR THE CLOSE SVC                   
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST                   
         CLOSE ,MF=(E,OCDCB)       CLOSE THE OFFENDING FILE                     
         SPACE 1                                                                
PCLOSE   DS    0H                                                               
         XC    DCBDDNAM,DCBDDNAM   MARK THE FILE PERMANENTLY UNUSABLE           
         DROP  2                                                                
         B     RETNEOF             GO RETURN AN END OF FILE INDICATION          
         SPACE 2                                                                
INSYNAD  STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,INSYND            SYNAD ERROR ON AN INPUT FILE                 
         B     INERR               BRANCH TO ERROR ROUTINE                      
         SPACE 1                                                                
INEOD2   LA    1,INEODAB           EOD ON AN INPUT FILE                         
*                                  ATTEMPT TO READ AFTER AN EOD SIGNAL          
INERR    A     1,SAVREG+PARM2*4    SUBCODE INDICATING WHICH INPUT FILE          
         B     ABEND               BRANCH TO ABEND ROUTINE                      
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        SYNAD ERROR ROUTINES FOR OUTPUT FILES                        *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
OUTSYNAD STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,OUTSYND           SYNAD ERROR ON OUTPUT FILE                   
         B     INERR                                                            
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        SYNAD AND EOD ROUTINES FOR DIRECT ACCESS FILE I/O            *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
FILESYND STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,FLSYND            SYNAD ERROR ON DIRECT ACCESS FILE            
         B     FILERR              GO TO ERROR ROUTINE                          
         SPACE 1                                                                
FILEEOD  STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,FLEOD             EOD ERROR ON DIRECT ACCESS FILE              
         SPACE 1                                                                
FILERR   L     2,SAVREG+SVCODE*4   SERVICE CODE                                 
         LA    0,RD1-8             COMPUTE WHICH DIRECT ACCESS FILE             
         SR    2,0                 SERVICE_CODE - 1ST SERVICE CODE              
         SRL   2,3                 DIVIDE BY 8                                  
         AR    1,2                                                              
*                                  FALL THROUGH TO ABEND ROUTINE                
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        ABEND ROUTINE FOR ALL I/O ERRORS                             *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
ABEND    DS    0H                                                               
         ST    1,ABESAVE           SAVE ABEND CODE                              
         SPACE 1                                                                
         CLOSE (INPUT0,,OUTPUT0)   THESE MUST BE CLOSED FIRST                   
         CLOSE ,MF=(E,GETDCBS)     ATTEMPT TO CLOSE ALL FILES                   
         SPACE 1                                                                
         L     1,ABESAVE                                                        
         TM    FLAGS,DUMPBIT       IS A CORE DUMP DESIRED ?                     
         BZ    NODUMP              NO, ABEND QUIETLY                            
         SPACE 1                                                                
         ABEND (1),DUMP            ABEND WITH A DUMP                            
         SPACE 1                                                                
NODUMP   DS    0H                                                               
         ABEND (1)                 ABEND WITHOUT A DUMP                         
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        ROUTINE TO FORCE AN ABEND DUMP WHEN REQUESTED BY THE         *         
*        XPL PROGRAM BY MEANS OF THE STATEMENT:                       *         
*                                                                     *         
*        CALL  EXIT  ;                                                *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
USEREXIT DS    0H                                                               
         STM   0,2,ABEREGS         SAVE REGISTERS                               
         OI    FLAGS,DUMPBIT       FORCE A DUMP                                 
         LA    1,USERABE           USER ABEND CODE                              
         B     ABEND               BRANCH TO ABEND                              
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DISPATCHER FOR ALL SERVICE REQUESTS FROM THE XPL PROGRAM     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         DROP  13                                                               
         USING ENTRY,SELF                                                       
ENTRY    DS    0H                  XPL PROGRAMS ENTER HERE                      
         STM   0,3,SAVREG          SAVE REGISTERS USED BY XPLSM                 
         STM   13,15,SAVREG+13*4                                                
         L     13,ASAVE            ADDRESS OF OS SAVE AREA                      
         DROP  SELF                                                             
         USING SAVE,13                                                          
         SPACE 1                                                                
         LTR   SVCODE,SVCODE       CHECK THE SERVICE CODE FOR VALIDITY          
         BNP   BADCODE             SERVICE CODE MUST BE > 0                     
         C     SVCODE,MAXCODE      AND < ENDSERV                                
         BH    BADCODE             GO ABEND                                     
         SPACE 1                                                                
TABLE    B     TABLE(SVCODE)       GO DO THE SERVICE                            
         SPACE 1                                                                
         ORG   TABLE+GETC                                                       
         B     GET                 READ INPUT FILE                              
         SPACE 1                                                                
         ORG   TABLE+PUTC                                                       
         B     PUT                 WRITE OUTPUT FILE                            
         SPACE 1                                                                
         ORG   TABLE+TRC                                                        
         B     TRACE               INITIATE TRACING OF THE PROGRAM              
         SPACE 1                                                                
         ORG   TABLE+UNTR                                                       
         B     UNTRACE             TERMINATE TRACING                            
         SPACE 1                                                                
         ORG   TABLE+EXDMP                                                      
         B     USEREXIT            TERMINATE WITH A CORE DUMP                   
         SPACE 1                                                                
         ORG   TABLE+GTIME                                                      
         B     GETIME              RETURN TIME AND DATE                         
         SPACE 1                                                                
         ORG   TABLE+RSVD1                                                      
         B     EXIT                (UNUSED)                                     
         SPACE 1                                                                
         ORG   TABLE+RSVD2                                                      
         B     EXIT                CLOCK_TRAP        (NOP)                      
         SPACE 1                                                                
         ORG   TABLE+RSVD3                                                      
         B     EXIT                INTERRUPT_TRAP    (NOP)                      
         SPACE 1                                                                
         ORG   TABLE+RSVD4                                                      
         B     EXIT                MONITOR           (NOP)                      
         SPACE 1                                                                
         ORG   TABLE+RSVD5                                                      
         B     EXIT                (UNUSED)                                     
         SPACE 1                                                                
         ORG   TABLE+RSVD6                                                      
         B     EXIT                (UNUSED)                                     
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DYNAMICALLY GENERATE THE DISPATCHING TABLE ENTRIES FOR       *         
*        FILE I/O SERVICES.                                           *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
&I       SETA  1                   LOOP INDEX                                   
.DBR1    AIF   (&I GT &FILES).DBR2                                              
*                                  FINISHED ?                                   
         ORG   TABLE+RD&I                                                       
         B     READ                BRANCH TO FILE READ ROUTINE                  
         ORG   TABLE+WRT&I                                                      
         B     WRITE               BRANCH TO FILE WRITE ROUTINE                 
&I       SETA  &I+1                INCREMENT COUNTER                            
         AGO   .DBR1               LOOP BACK                                    
.DBR2    ANOP                                                                   
         SPACE 2                                                                
         ORG   TABLE+ENDSERV       RESET PROGRAM COUNTER                        
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        COMMON EXIT ROUTINE FOR RETURN TO THE XPL PROGRAM            *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
EXIT     DS    0H                                                               
         LM    0,3,SAVREG          RESTORE REGISTERS                            
         LM    13,15,SAVREG+13*4                                                
         DROP  13                                                               
         USING ENTRY,SELF                                                       
         SPACE 1                                                                
         BR    CBR                 RETURN TO THE XPL PROGRAM                    
         SPACE 1                                                                
         DROP  SELF                                                             
         USING SAVE,13                                                          
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        ROUTINE TO ABEND IN CASE OF BAD SERVICE CODES                *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BADCODE  STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,CODEABE           BAD SERVICE CODE ABEND                       
         B     ABEND               GO ABEND                                     
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        INPUT ROUTINE FOR READING SEQUENTIAL INPUT FILES             *         
*                                                                     *         
*                                                                     *         
*        INPUT TO THIS ROUTINE IS:                                    *         
*                                                                     *         
*      PARM1   ADDRESS OF THE NEXT AVAILABLE SPACE IN THE PROGRAMS    *         
*              DYNAMIC STRING AREA  (FREEPOINT)                       *         
*                                                                     *         
*      SVCODE  THE SERVICE CODE FOR INPUT                             *         
*                                                                     *         
*      PARM2   A SUBCODE DENOTING WHICH INPUT FILE,                   *         
*              INPUT(I),     I = 0,1, ... ,&INPUTS                    *         
*                                                                     *         
*        THE ROUTINE RETURNS:                                         *         
*                                                                     *         
*      PARM1   A STANDARD XPL STRING DESCRIPTOR POINTING AT THE INPUT *         
*              RECORD WHICH IS NOW AT THE TOP OF THE STRING AREA      *         
*                                                                     *         
*      SVCODE  THE NEW VALUE FOR FREEPOINT, UPDATED BY THE LENGTH OF  *         
*              THE RECORD JUST READ IN                                *         
*                                                                     *         
*                                                                     *         
*        A STANDARD XPL STRING DESCRIPTOR HAS:                        *         
*                                                                     *         
*        BITS  0-7                 (LENGTH - 1) OF THE STRING         *         
*        BITS  8-31                ABSOLUTE ADDRESS OF THE STRING     *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
GET      DS    0H                                                               
         LA    SVCODE,&INPUTS      CHECK THAT THE SUBCODE IS VALID              
         LTR   PARM2,PARM2         SUBCODE MUST BE >= 0                         
         BM    BADGET                                                           
         CR    PARM2,SVCODE        AND <= &INPUTS                               
         BH    BADGET              ILLEGAL SUBCODE                              
         SLL   PARM2,2             SUBCODE*4                                    
         L     3,GETDCBS(PARM2)    ADDRESS OF DCB FOR THE FILE                  
         USING IHADCB,3                                                         
         NC    DCBDDNAM,DCBDDNAM   HAS THE FILE BEEN PERMANENTLY                
*                                  CLOSED ?                                     
         BZ    INEOD2              YES, SO TERMINATE THE JOB                    
         SPACE 1                                                                
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                           
         BO    GETOPEN             YES                                          
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC               
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST                   
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                                
         LR    2,3                 COPY DCB ADDRESS                             
         TM    DCBOFLGS,OPENBIT    WAS THE FILE OPENED SUCCESSFULLY ?           
         BZ    PCLOSE              NO, MARK FILE PERMANENTLY CLOSED AND         
*                                  RETURN EOD INDICATION TO THE PROGRAM         
         SPACE 2                                                                
GETOPEN  DS    0H                                                               
         GET   (3)                 LOCATE MODE GET                              
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT INPUT BUFFER      *         
*        IS RETURNED IN R1                                            *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         L     2,SAVREG+PARM1*4    FETCH THE STRING DESCRIPTOR                  
         LA    2,0(,2)             ADDRESS PART ONLY                            
         LH    3,DCBLRECL          RECORD LENGTH                                
         DROP  3                                                                
         S     3,F1                LENGTH - 1                                   
         EX    3,GETMOVE           MOVE THE CHARACTERS                          
         ST    2,SAVREG+PARM1*4    BUILD UP A STRING DESCRIPTOR                 
         STC   3,SAVREG+PARM1*4    LENGTH FIELD                                 
         LA    2,1(2,3)            NEW FREE POINTER                             
         ST    2,SAVREG+SVCODE*4                                                
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        RETURN A NULL STRING DESCRIPTOR AS AN END OF FILE            *         
*        INDICATION THE FIRST TIME AN INPUT REQUEST FIND THE          *         
*        END OF DATA CONDITION                                        *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
RETNEOF  DS    0H                                                               
         MVC   SAVREG+SVCODE*4(4),SAVREG+PARM1*4                                
*                                  RETURN FREEPOINT UNTOUCHED                   
         XC    SAVREG+PARM1*4(4),SAVREG+PARM1*4                                 
*                                  RETURN A NULL STRING DESCRIPTOR              
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        ROUTINE TO ABEND IN CASE OF AN INVALID SUBCODE               *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
BADGET   STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,GFABE             INVALID GET SUBCODE                          
         B     INERR               GO ABEND                                     
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        ROUTINE FOR WRITING SEQUENTIAL OUTPUT FILES                  *         
*                                                                     *         
*                                                                     *         
*        INPUT TO THIS ROUTINE:                                       *         
*                                                                     *         
*      PARM1   XPL STRING DESCRIPTOR OF THE STRING TO BE OUTPUT       *         
*                                                                     *         
*      PARM2   SUBCODE INDICATING  OUTPUT(I),  I = 0,1, ... ,&OUTPUTS *         
*                                                                     *         
*      SVCODE  THE SERVICE CODE FOR OUTPUT                            *         
*                                                                     *         
*                                                                     *         
*        THE STRING NAMED BY THE DESCRIPTOR IS PLACED IN THE NEXT     *         
*        OUTPUT BUFFER OF THE SELECTED FILE.  IF THE STRING IS        *         
*        SHORTER THAN THE RECORD LENGTH OF THE FILE THEN THE          *         
*        REMAINDER OF THE RECORD IS PADDED WITH BLANKS.  IF THE       *         
*        STRING IS LONGER THAN THE RECORD LENGTH OF THE FILE          *         
*        THEN IT IS TRUNCATED ON THE RIGHT TO FIT.  IF THE SUBCODE    *         
*        SPECIFIES OUTPUT(0) THEN A SINGLE BLANK IS CONCATENATED      *         
*        ON TO THE FRONT OF THE STRING TO SERVE AS CARRIAGE CONTROL.  *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PUT      DS    0H                                                               
         LTR   PARM2,PARM2         CHECK SUBCODE FOR VALIDITY                   
         BM    BADPUT              SUBCODE MUST BE >= 0                         
         LA    SVCODE,&OUTPUTS                                                  
         CR    PARM2,SVCODE        AND <= &OUTPUTS                              
         BH    BADPUT                                                           
         ST    PARM1,MOVEADR       SAVE THE STRING DESCRIPTOR                   
         SLL   PARM2,2             SUBCODE*4                                    
         L     3,PUTDCBS(PARM2)    GET THE DCB ADDRESS                          
         USING IHADCB,3                                                         
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                           
         BO    PUTOPEN             YES, GO DO THE OUTPUT                        
         ST    3,OCDCB             STORE DCB ADDRESS FOR THE OPEN SVC           
         MVI   OCDCB,X'8F'         FLAG END OF PARAMETER LIST AND SET           
*                                  FLAG INDICATING OPENING FOR OUTPUT           
         SPACE 1                                                                
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                                
         SPACE 1                                                                
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFULL ?                   
         BZ    OUTSYNAD            NO, OUTPUT SYNAD ERROR                       
         SPACE 1                                                                
PUTOPEN  DS    0H                                                               
         PUT   (3)                 LOCATE MODE PUT                              
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT OUTPUT BUFFER     *         
*        IS RETURNED IN  R1.                                          *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
         SR    15,15               CLEAR REGISTER 15                            
         C     15,MOVEADR          IS THE STRING NULL (DESCRIPTOR = 0)          
         BE    NULLPUT             YES, SO PUT OUT A BLANK RECORD               
         IC    15,MOVEADR          LENGTH-1 OF THE STRING                       
         LA    14,1(15)            REAL LENGTH OF THE STRING                    
         LH    0,DCBLRECL          RECORD LENGTH OF THE FILE                    
         LTR   PARM2,PARM2         CHECK SUBCODE FOR OUTPUT(0)                  
         BNZ   PUT1                NOT OUTPUT(0)                                
         LA    14,1(,14)           INCREASE REAL LENGTH BY ONE FOR              
*                                  CARRIAGE CONTROL                             
PUT1     SR    0,14                RECORD LENGTH - REAL LENGTH                  
         BM    TOOLONG             RECORD LENGTH < REAL LENGTH                  
         BZ    MATCH               RECORD LENGTH = REAL LENGTH                  
*                                  RECORD LENGTH > REAL LENGTH                  
         OI    FLAGS,SFILLBIT+LFILLBIT                                          
*                                  INDICATE PADDING REQUIRED                    
         S     0,F1                RECORD LENGTH - REAL LENGTH - 1              
         BP    LONGMOVE            RECORD LENGTH - REAL LENGTH > 1              
         NI    FLAGS,ALLBITS-LFILLBIT                                           
*                                  RECORD LENGTH - REAL LENGTH = 1              
*                                  IS A SPECIAL CASE                            
LONGMOVE ST    0,FILLENG           SAVE LENGTH FOR PADDING OPERATION            
         B     MOVEIT              GO MOVE THE STRING                           
         SPACE 1                                                                
TOOLONG  LH    15,DCBLRECL         REPLACE THE STRING LENGTH                    
*                                  WITH THE RECORD LENGTH                       
         S     15,F1               RECORD LENGTH - 1 FOR THE MOVE               
MATCH    NI    FLAGS,ALLBITS-SFILLBIT-LFILLBIT                                  
*                                  INDICATE NO PADDING REQUIRED                 
         SPACE 1                                                                
MOVEIT   LTR   PARM2,PARM2         CHECK FOR OUTPUT(0)                          
         BNZ   MOVEIT2             OUTPUT(0) IS A SPECIAL CASE                  
         MVI   0(1),C' '           PROVIDE BLANK CARRIAGE CONTROL               
         LA    1,1(,1)             INCREMENT BUFFER POINTER                     
MOVEIT2  L     2,MOVEADR           STRING DESCRIPTOR                            
         LA    2,0(,2)             ADDRESS PART ONLY                            
         EX    15,MVCSTRNG         EXECUTE A MVC INSTRUCTION                    
         TM    FLAGS,SFILLBIT      IS PADDING REQUIRED ?                        
         BZ    EXIT                NO, RETURN TO THE XPL PROGRAM                
         SPACE 1                                                                
         AR    1,15                ADDRESS TO START PADDING - 1                 
         MVI   1(1),C' '           START THE PAD                                
         TM    FLAGS,LFILLBIT      IS MORE PADDING REQUIRED ?                   
         BZ    EXIT                NO, RETURN TO XPL PROGRAM                    
         L     15,FILLENG          LENGTH OF PADDING NEEDED                     
         S     15,F1               LESS ONE FOR THE MOVE                        
         EX    15,MVCBLANK         EXECUTE MVC TO FILL IN BLANKS                
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        FOR A NULL STRING OUTPUT A BLANK RECORD                      *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
NULLPUT  LH    15,DCBLRECL         RECORD LENGTH                                
         S     15,F2               LESS TWO FOR THE MOVES                       
         MVI   0(1),C' '           INITIAL BLANK                                
         EX    15,MVCNULL          EXECUTE MVC TO FILL IN THE BLANKS            
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         SPACE 1                                                                
         DROP  3                                                                
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        ROUTINE TO ABEND IN CASE OF AN INVALID SERVICE CODE          *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
BADPUT   STM   0,2,ABEREGS         SAVE REGISTERS                               
         LA    1,PFABE             INVALID PUT SUBCODE                          
         B     INERR               GO ABEND                                     
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        READ ROUTINE FOR DIRECT ACCESS FILE I/O                      *         
*                                                                     *         
*                                                                     *         
*        INPUT TO THIS ROUTINE IS:                                    *         
*                                                                     *         
*      PARM1   CORE ADDRESS TO READ THE RECORD INTO                   *         
*                                                                     *         
*      SVCODE  SERVICE CODE INDICATING WHICH FILE TO USE              *         
*                                                                     *         
*      PARM2   RELATIVE RECORD NUMBER   0,1,2,3,...                   *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
READ     DS    0H                                                               
         ST    PARM1,RDECB+12      STORE ADDRESS                                
         L     3,ARWDCBS-FILEORG(SVCODE)                                        
*                                  ADDRESS OF THE DCB FOR THIS FILE             
         USING IHADCB,3                                                         
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                           
         BO    READOPEN            YES, GO READ                                 
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC               
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST                   
*                                  AND INDICATE OPEN FOR INPUT                  
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                                
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFUL ?                    
         BZ    FILESYND            NO, SYNAD ERROR                              
         SPACE 1                                                                
READOPEN DS    0H                                                               
         TM    DCBDEVT,TAPEBITS    IS THE FILE ON MAGNETIC TAPE                 
         DROP  3                                                                
         BO    READTP              YES, GO FORM RECORD INDEX FOR TAPE           
         SLA   PARM2,16            FORM  TTRZ  ADDRESS                          
         BNZ   RDN0                BLOCK ZERO IS A SPECIAL CASE                 
         LA    PARM2,1             FUNNY ADDRESS FOR BLOCK ZERO                 
         B     READTP              GO DO THE READ                               
RDN0     O     PARM2,TTRSET        SPECIFY LOGICAL RECORD 1                     
READTP   ST    PARM2,TTR           SAVE RECORD POINTER                          
         SPACE 1                                                                
         POINT (3),TTR             POINT AT THE RECORD TO BE READ               
         READ  RDECB,SF,(3),0,'S'  READ THE RECORD INTO CORE                    
         CHECK RDECB               WAIT FOR THE READ TO COMPLETE                
         SPACE 1                                                                
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        WRITE ROUTINE FOR DIRECT ACCESS FILE I/O                     *         
*                                                                     *         
*                                                                     *         
*        INPUT TO THIS ROUTINE IS:                                    *         
*                                                                     *         
*      PARM1   CORE ADDRESS TO READ THE RECORD FROM                   *         
*                                                                     *         
*      SVCODE  SERVICE CODE INDICATING WHICH FILE TO USE              *         
*                                                                     *         
*      PARM2   RELATIVE RECORD NUMBER   0,1,2, ...                    *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
WRITE    DS    0H                                                               
         ST    PARM1,WDECB+12      SAVE CORE ADDRESS                            
         L     3,ARWDCBS-FILEORG(SVCODE)                                        
*                                  GET THE DCB ADDRESS                          
         USING IHADCB,3                                                         
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                           
         BO    WRTOPEN             YES, GO WRITE                                
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC               
         MVI   OCDCB,X'8F'         FLAG END OF ARGUMENT LIST AND                
*                                  INDICATE OPENING FOR OUTPUT                  
         SPACE 1                                                                
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                                
         SPACE 1                                                                
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFUL ?                    
         BZ    FILESYND            NO,SYNAD ERROR                               
         SPACE 1                                                                
WRTOPEN  DS    0H                                                               
         TM    DCBDEVT,TAPEBITS    IS THE FILE ON MAGNETIC TAPE                 
         DROP  3                                                                
         BO    WRITP               YES, GO FORM RECORD INDEX FOR TAPE           
         SLA   PARM2,16            FORM TTRZ ADDRESS FOR DIRECT ACCESS          
         BNZ   WRDN0               RECORD ZERO IS A SPECIAL CASE                
         LA    PARM2,1             FUNNY ADDRESS FOR RECORD ZERO                
         B     WRITP               GO DO THE WRITE                              
WRDN0    O     PARM2,TTRSET        OR IN RECORD NUMBER BIT                      
WRITP    ST    PARM2,TTR           SAVE RECORD POINTER                          
         SPACE 1                                                                
         POINT (3),TTR             POINT AT THE DESIRED RECORD                  
         WRITE WDECB,SF,(3),0,'S'  WRITE THE RECORD OUT                         
         CHECK WDECB               WAIT FOR THE WRITE TO FINISH                 
         SPACE 1                                                                
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        TRACE  AND  UNTRACE                                          *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
TRACE    DS    0H                                                               
         STM   3,12,SAVREG+3*4     SAVE REGISTERS NOT SAVED AT ENTRY            
         L     2,SAVREG+4*CBR      GET ADDRESS OF THE NEXT INSTRUCTION          
         LA    2,0(,2)             ADDRESS PART ONLY                            
         ST    2,ILC               SAVE IT FOR THE TRACE ROUTINE                
         LA    SELF,ENTRY          ADDRESS OF ENTRY POINT                       
         B     TRCALL              GO CALL THE TRACE ROUTINE                    
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        COME HERE TO BEGIN XPL PROGRAM EXECUTION IN TRACE MODE       *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
BEGTRC   DS    0H                                                               
         LM    0,3,PGMPARMS        INITIAL PARAMETERS FOR XPL PROGRAM           
         STM   0,3,SAVREG          PLACE IN PSEUDO REGISTERS                    
         ST    SELF,SAVREG+4*SELF  STORE MONITOR ADDRESS                        
         SPACE 1                                                                
TRCALL   DS    0H                                                               
         LM    0,4,TPACK           PARAMETERS FOR THE TRACE ROUTINE             
         BALR  CBR,3               CALL THE TRACE ROUTINE                       
         L     CBR,ASMR            ADDRESS OF XPLSM RETURN TO OS                
         BR    CBR                 GO RETURN TO OS                              
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        UNTRACE REQUEST IS DETECTED BY THE TRACE ROUTINE IF TRACING  *         
*        IS ACTUALLY BEING DONE.  IT IS A NOP HERE                    *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
UNTRACE  B     EXIT                RETURN TO THE XPL PROGRAM                    
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        TIME AND DATE FUNCTIONS                                      *         
*                                                                     *         
*                                                                     *         
*        RETURNS TIME OF DAY IN HUNDREDTHS OF A SECOND IN REGISTER    *         
*        PARM1  AND THE DATE IN THE FORM  YYDDD IN REGISTER SVCODE    *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
GETIME   TIME  BIN                 REQUEST THE TIME                             
         ST    0,SAVREG+PARM1*4    RETURN IN REGISTER PARM1                     
         ST    1,DTSV+4            STORE THE DATE IN PACKED DECIMAL             
         CVB   1,DTSV              CONVERT IT TO BINARY                         
         ST    1,SAVREG+SVCODE*4   RETURN DATE IN REGISTER SVCODE               
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        EXECUTE ROUTINE FOR USE BY THE TRACE ROUTINE                 *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         DROP  13                                                               
         USING ENTRY,SELF                                                       
         SPACE 1                                                                
EXEC     DS    0H                                                               
         STM   0,3,XCELL           SAVE THE PARAMETERS PASSED IN                
         LM    0,4,0(2)            LOAD THE REST OF THE TRACED                  
*                                  PROGRAM'S REGISTERS                          
         EX    0,XCELL             EXECUTE ONE INSTRUCTION                      
         STM   14,15,EXSV          SAVE REGISTERS TEMPORARILY                   
         L     14,XCELL+8          ADDRESS OF TRACE ROUTINE'S                   
*                                  REGISTER TABLE                               
         STM   0,13,0(14)          STORE REGISTERS IN THE TABLE                 
         LM    0,1,EXSV            PICK UP REGISTERS 14 & 15 AGAIN              
         STM   0,1,14*4(14)        STORE THEM IN THE TABLE                      
         LM    0,3,XCELL           RESTORE INITIAL REGISTERS                    
         BALR  1,3                 RETURN WITH THE CONDITION CODE               
*                                  IN REGISTER 1                                
         SPACE 1                                                                
         DROP  SELF                                                             
         USING SAVE,13                                                          
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        DATA AREA FOR THE SUBMONITOR                                 *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         DS    0F                                                               
ASAVE    DC    A(SAVE)             ADDRESS OF OS SAVE AREA                      
ABASE1   DC    A(BASE1)            BASE ADDRESS FOR INITIALIZATION              
MAXCODE  DC    A(ENDSERV-4)        LARGEST VALID SERVICE CODE                   
ASMR     DC    A(SMRET)            ADDRESS OF SUBMONITOR RETURN TO OS           
RTNSV    DC    F'0'                SAVE COMPLETION CODE RETURNED                
*                                  BY THE XPL PROGRAM                           
ABESAVE  DS    F                   SAVE ABEND CODE DURING CLOSE                 
ABEREGS  DS    3F                  SAVE PROGRAMS REGS 0-2 BEFORE ABEND          
TTR      DC    F'0'                TTRZ ADDRESS FOR READ AND WRITE              
TTRSET   DC    X'00000100'         ADDRESS CONSTANT FOR TTRZ                    
FLAGS    DC    X'00'               SUBMONITOR CONTROL FLAGS                     
SAVREG   DC    16F'0'              SAVE AREA FOR THE SUBMONITOR                 
         DS    0D                                                               
DTSV     DC    PL8'0'              WORK AREA FOR CONVERTING DATE                
TPACK    DS    0H                  PARAMETERS FOR THE TRACE ROUTINE             
         DC    A(CONTROL)          POINTER TO THE PARM FIELD OF                 
*                                  THE OS  EXEC  CARD                           
         DC    A(SAVREG)           ADDRESS OF THE REGISTER TABLE                
ILC      DC    A(GOC)              ADDRESS TO BEGIN TRACING                     
         DC    V(TRACE)            ADDRESS OF THE TRACE ROUTINE                 
         DC    A(EXEC)             ADDRESS OF THE EXECUTE ROUTINE               
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DCB ADDRESS TABLE FOR ALL I/O ROUTINES                       *         
*                                                                     *         
*                                                                     *         
*        THE FOUR SETS OF DCB ADDRESSES HEADED BY  'GETDCBS',         *         
*        'PUTDCBS', 'ARWDCBS', AND 'PGMDCB' MUST BE CONTIGUOUS        *         
*        AND END WITH 'PGMDCB'.  THESE LISTS ARE USED AT JOB END      *         
*        TO CLOSE ALL FILES BEFORE RETURNING TO OS                    *         
*                                                                     *         
*                                                                     *         
*        DCB ADDRESSES FOR INPUT FILES:                               *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         PRINT NOGEN                                                            
         SPACE 1                                                                
GETDCBS  DS    0F                                                               
&I       SETA  0                                                                
.GD1     AIF   (&I GT &INPUTS).GD2                                              
         DC    A(INPUT&I)                                                       
&I       SETA  &I+1                                                             
         AGO   .GD1                                                             
.GD2     ANOP                                                                   
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        DCB ADDRESSES FOR OUTPUT FILES                               *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
PUTDCBS  DS    0F                                                               
         SPACE 1                                                                
&I       SETA  0                                                                
.PD1     AIF   (&I GT &OUTPUTS).PD2                                             
         DC    A(OUTPUT&I)                                                      
&I       SETA  &I+1                                                             
         AGO   .PD1                                                             
.PD2     ANOP                                                                   
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        DCB ADDRESS FOR DIRECT ACCESS FILES                          *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
ARWDCBS  DS    0F                                                               
         SPACE 1                                                                
&I       SETA  1                                                                
.DA1     AIF   (&I GT &FILES).DA2                                               
         ORG   ARWDCBS+RD&I-FILEORG                                             
         DC    A(FILE&I.IN)                                                     
         ORG   ARWDCBS+WRT&I-FILEORG                                            
         DC    A(FILE&I.OUT)                                                    
&I       SETA  &I+1                                                             
         AGO   .DA1                                                             
.DA2     ANOP                                                                   
         ORG   ARWDCBS+ENDSERV-FILEORG                                          
         DS    0F                                                               
         SPACE 2                                                                
PGMDCB   DC    X'80'               FLAG END OF PARAMETER LIST                   
         DC    AL3(PROGRAM)        ADDRESS OF PROGRAM DCB                       
         SPACE 2                                                                
OCDCB    DS    F                   DCB ADDRESSES FOR OPEN AND CLOSE             
MOVEADR  DS    1F                  DESCRIPTOR STORAGE FOR PUT ROUTINE           
FILLENG  DC    F'0'                LENGTH OF PADDING NEEDED IN OUTPUT           
F1       DC    F'1'                THE CONSTANT ONE                             
F2       DC    F'2'                THE CONSTANT TWO                             
GETMOVE  MVC   0(0,2),0(1)         MVC COMMAND FOR THE GET ROUTINE              
MVCNULL  MVC   1(0,1),0(1)         MVC COMMAND FOR THE PUT ROUTINE              
MVCBLANK MVC   2(0,1),1(1)             "                                        
MVCSTRNG MVC   0(0,1),0(2)             "                                        
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*        DATA AREA FOR THE EXECUTE ROUTINE                            *         
*                                                                     *         
***********************************************************************         
         SPACE 1                                                                
XCELL    DS    1F                  INSTRUCTION TO BE EXECUTED                   
         DS    1F                  MORE INSTRUCTION                             
         DS    1F                  ADDRESS OF TRACE ROUTINE REGISTER            
*                                  TABLE                                        
         DS    1F                  RETURN ADDRESS TO THE TRACE ROUTINE          
*                                  ADDRESS OF EXEC IS IN REGISTER FOUR          
EXSV     DS    2F                  WORK AREA FOR THE EXECUTE ROUTINE            
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        DEVICE  CONTROL  BLOCKS  FOR  THE  SUBMONITOR                *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
PROGRAM  DCB   DSORG=PS,                                               X        
               MACRF=R,                                                X        
               DDNAME=PROGRAM,                                         X        
               DEVD=DA,                                                X        
               KEYLEN=0,                                               X        
               EODAD=EODPGM,                                           X        
               SYNAD=ERRPGM                                                     
         SPACE 2                                                                
INPUT0   DCB   DSORG=PS,                                               X        
               DDNAME=SYSIN,                                           X        
               DEVD=DA,                                                X        
               MACRF=GL,                                               X        
               BUFNO=3,                                                X        
               EODAD=INEOD,                                            X        
               SYNAD=INSYNAD,                                          X        
               EXLST=INEXIT0,                                          X        
               EROPT=ACC                                                        
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
INPUT1   EQU   INPUT0              INPUT(0) & INPUT(1) ARE BOTH SYSIN *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
&I       SETA  2                                                                
.INP1    AIF   (&I GT &INPUTS).INP2                                             
         SPACE 1                                                                
INPUT&I  DCB   DSORG=PS,                                               X        
               DDNAME=INPUT&I,                                         X        
               DEVD=DA,                                                X        
               MACRF=GL,                                               X        
               EODAD=INEOD,                                            X        
               SYNAD=INSYNAD,                                          X        
               EXLST=INEXIT&I,                                         X        
               EROPT=ACC                                                        
         SPACE 1                                                                
&I       SETA  &I+1                                                             
         AGO   .INP1                                                            
.INP2    ANOP                                                                   
         SPACE 2                                                                
OUTPUT0  DCB   DSORG=PS,                                               X        
               DDNAME=SYSPRINT,                                        X        
               DEVD=DA,                                                X        
               MACRF=PL,                                               X        
               SYNAD=OUTSYNAD,                                         X        
               EXLST=OUTEXIT0,                                         X        
               EROPT=ACC                                                        
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
OUTPUT1  EQU   OUTPUT0             OUTPUT(0), OUTPUT(1) BOTH SYSPRINT *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
OUTPUT2  DCB   DSORG=PS,                                               X        
               DDNAME=SYSPUNCH,                                        X        
               DEVD=DA,                                                X        
               MACRF=PL,                                               X        
               SYNAD=OUTSYNAD,                                         X        
               EXLST=OUTEXIT2,                                         X        
               EROPT=ACC                                                        
         SPACE 1                                                                
&I       SETA  3                                                                
.OP1     AIF   (&I GT &OUTPUTS).OP2                                             
         SPACE 1                                                                
OUTPUT&I DCB   DSORG=PS,                                               X        
               DDNAME=OUTPUT&I,                                        X        
               DEVD=DA,                                                X        
               MACRF=PL,                                               X        
               SYNAD=OUTSYNAD,                                         X        
               EXLST=OUTEXIT&I,                                        X        
               EROPT=ACC                                                        
         SPACE 1                                                                
&I       SETA  &I+1                                                             
         AGO   .OP1                                                             
.OP2     ANOP                                                                   
         SPACE 1                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DCBS FOR THE DIRECT ACCESS FILES                             *         
*                                                                     *         
*                                                                     *         
*        BECAUSE OF THE MANNER IN WHICH THE FILES ARE USED,  IT IS    *         
*        NECESSARY TO HAVE TWO DCB'S FOR EACH FILE.  ONE DCB FOR      *         
*        READING AND ONE FOR WRITING.                                 *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
&I       SETA  1                                                                
.DD1     AIF   (&I GT &FILES).DD2                                               
         SPACE 1                                                                
FILE&I.IN DCB  DSORG=PS,                                               X        
               MACRF=RP,                                               X        
               DDNAME=FILE&I,                                          X        
               DEVD=DA,                                                X        
               RECFM=F,                                                X        
               LRECL=FILEBYTS,                                         X        
               BLKSIZE=FILEBYTS,                                       X        
               KEYLEN=0,                                               X        
               EODAD=FILEEOD,                                          X        
               SYNAD=FILESYND                                                   
         SPACE 2                                                                
FILE&I.OUT DCB DSORG=PS,                                               X        
               MACRF=WP,                                               X        
               DDNAME=FILE&I,                                          X        
               DEVD=DA,                                                X        
               RECFM=F,                                                X        
               KEYLEN=0,                                               X        
               LRECL=FILEBYTS,                                         X        
               BLKSIZE=FILEBYTS,                                       X        
               SYNAD=FILESYND                                                   
         SPACE 1                                                                
&I       SETA  &I+1                                                             
         AGO   .DD1                                                             
.DD2     ANOP                                                                   
         SPACE 4                                                                
XPLSMEND DS    0H                  END  OF  THE  SUBMONITOR                     
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        DSECT WHICH DEFINES THE FORMAT OF BINARY PROGRAM CONTROL     *         
*        INFORMATION AND THE STARTING POINT FOR PROGRAMS              *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
FILECTRL DSECT                                                                  
         SPACE 1                                                                
BYTSCODE DS    1F                  NUMBER OF BYTES OF CODE                      
         SPACE 1                                                                
BYTSDATA DS    1F                  NUMBER OF BYTES OF DATA AREA                 
         SPACE 1                                                                
BLKSCODE DS    1F                  NUMBER OF RECORDS OF CODE                    
         SPACE 1                                                                
BLKSDATA DS    1F                  NUMBER OF RECORDS OF DATA AREA               
         SPACE 1                                                                
BYTSBLK  DS    1F                  BLOCKSIZE OF THE XPL PROGRAM FILE            
         SPACE 1                                                                
BYTSFULL DS    1F                  NUMBER OF BYTES OF CODE ACTUALLY             
*                                  USED IN THE LAST RECORD OF CODE              
         SPACE 1                                                                
DATABYTS DS    1F                  NUMBER OF BYTES OF DATA ACTUALLY             
*                                  USED IN THE LAST RECORD OF DATA              
         SPACE 1                                                                
         ORG   FILECTRL+60         REMAINDER OF THE CONTROL BLOCK               
*                                  IS UNUSED                                    
         SPACE 1                                                                
CODEBEGN DS    0H                  FIRST EXECUTABLE INSTRUCTION                 
*                                  IN THE XPL PROGRAM                           
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        DUMMY  DCB  FOR  DEFINING  DCB  FIELDS                       *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         DCBD  DSORG=QS,DEVD=DA                                                 
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        THE  END                                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 5                                                                
         END                                                                    