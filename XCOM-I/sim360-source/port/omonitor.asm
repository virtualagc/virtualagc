PMON     TITLE 'THE PASCAL OVERLAY MONITOR'                                     
         SPACE 2                                                        XMN00010
*********************************************************************** XMN00020
*                                                                     * XMN00030
*                                                                     * XMN00040
*                                                                     * XMN00050
*        T H E   P A S C A L   O V E R L A Y   M O N I T O R          *         
*                                                                     * XMN00070
*                                                                     * XMN00080
*                                  WILLIAM BARABASH                   *         
*                                  DEPARTMENT OF COMPUTER SCIENCE     *         
*                                  S.U.N.Y. AT STONY BROOK            *         
*                                  STONY BROOK, NEW YORK 11794        *         
*                                  DECEMBER 1975                      *         
*                                                                     * XMN00120
*                                                                     * XMN00130
*********************************************************************** XMN00140
         EJECT                                                          XMN00150
         SPACE 1                                                        XMN00160
*********************************************************************** XMN00170
*                                                                     * XMN00180
*                                                                     * XMN00190
*                                                                     * XMN00200
*        DEFINE PARAMETRIC CONSTANTS FOR XPLSM                        * XMN00210
*                                                                     * XMN00220
*                                                                     * XMN00230
*********************************************************************** XMN00240
         SPACE 1                                                        XMN00250
         GBLA  &INPUTS             NUMBER OF INPUT FILES                XMN00260
         GBLA  &OUTPUTS            NUMBER OF OUTPUT FILES               XMN00270
         GBLA  &FILES              NUMBER OF DIRECT ACCESS FILES        XMN00280
         LCLA  &I,&J               VARIABLES FOR ITERATION LOOPS                
         SPACE 5                                                        XMN00300
IOPACK   CSECT                                                          XMN00310
         SPACE 2                                                        XMN00320
&INPUTS  SETA  6                   INPUT(I), I IN 0..6                          
         SPACE 1                                                        XMN00340
&OUTPUTS SETA 7                    OUTPUT(I), I IN 0..7                         
         SPACE 1                                                        XMN00360
&FILES   SETA  3                   FILE(I,*),  I = 1,2,3                XMN00370
         SPACE 1                                                        XMN00380
*********************************************************************** XMN00390
*                                                                     * XMN00400
*                                                                     * XMN00410
*        FILEBYTS DETERMINES THE BLOCKSIZE FOR DIRECT ACCESS FILE     * XMN00420
*        I/O.  IT SHOULD BE EQUAL TO THE VALUE OF THE LITERAL         * XMN00430
*        CONSTANT 'DISKBYTES' IN THE XCOM COMPILER FOR COMPILATION    * XMN00440
*        TO WORK SUCCESSFULLY.  THE VALUE OF FILEBYTS WHICH IS        * XMN00450
*        ASSEMBLED IN MAY BE OVERIDDEN BY THE 'FILE=NNNN' PARAMETER   * XMN00460
*        ON THE OS/360 EXEC CARD.                                     * XMN00470
*                                                                     * XMN00480
*                                                                     * XMN00490
*                                                                     * XMN00500
*        DEVICE       ALLOWABLE RANGE         SUGGESTED VALUE         * XMN00510
*                                                                     * XMN00520
*        2311      80 <= FILEBYTS <= 3624        3600                 * XMN00530
*                                                                     * XMN00540
*        2314      80 <= FILEBYTS <= 7294        7200                 * XMN00550
*                                                                     * XMN00560
*        2321      80 <= FILEBYTS <= 2000        2000                 * XMN00570
*                                                                     * XMN00580
*                                                                     * XMN00590
*        LARGER VALUES MAY BE USED FOR FILEBYTS IF THE SUBMONITOR     * XMN00600
*        IS REASSEMBLED WITH  RECFM=FT  SPECIFIED IN THE DCBS FOR     * XMN00610
*        THE DIRECT ACCESS FILES.                                     * XMN00620
*                                                                     * XMN00630
*                                                                     * XMN00640
*********************************************************************** XMN00650
         SPACE 2                                                        XMN00660
FILEBYTS EQU   7200                2314  DISKS                                  
         SPACE 2                                                        XMN00680
*********************************************************************** XMN00690
*                                                                     * XMN00700
*                                                                     * XMN00710
*        BLKSIZE DEFAULT FOR SOME INPUT AND OUTPUT FILES.  SEE THE    * XMN00720
*        EXIT LIST HANDLING ROUTINE GENXT.                            * XMN00730
*                                                                     * XMN00750
*********************************************************************** XMN00760
         SPACE 2                                                        XMN00770
IOFBYTS  EQU   800                                                              
         SPACE 2                                                        XMN00790
*********************************************************************** XMN00800
*                                                                     * XMN00810
*                                                                     * XMN00820
*        DEFINE THE REGISTERS USED TO PASS PARAMETERS TO THE          * XMN00830
*        SUBMONITOR FROM THE XPL PROGRAM                              * XMN00840
*                                                                     * XMN00850
*                                                                     * XMN00860
*********************************************************************** XMN00870
         SPACE 2                                                        XMN00880
SVCODE   EQU   1                   CODE INDICATING SERVICE REQUESTED    XMN00890
         SPACE 1                                                        XMN00900
PARM1    EQU   0                   FIRST PARAMETER                      XMN00910
         SPACE 1                                                        XMN00920
PARM2    EQU   2                   SECOND PARAMETER                     XMN00930
         SPACE 2                                                        XMN00940
*********************************************************************** XMN00950
*                                                                     * XMN00960
*                                                                     * XMN00970
*        DEFINE THE SERVICE CODES USED BY THE XPL PROGRAM TO          * XMN00980
*        INDICATE SERVICE REQUESTS TO THE SUBMONITOR                  * XMN00990
*                                                                     * XMN01000
*                                                                     * XMN01010
*********************************************************************** XMN01020
         SPACE 3                                                        XMN01030
GETC     EQU   4                   SEQUENTIAL INPUT                     XMN01040
         SPACE 1                                                        XMN01050
PUTC     EQU   8                   SEQUENTIAL OUTPUT                    XMN01060
         SPACE 1                                                        XMN01070
TRC      EQU   12                  INITIATE TRACING  (NOP IN XPLSM)     XMN01080
         SPACE 1                                                        XMN01090
UNTR     EQU   16                  TERMINATE TRACING (NOP IN XPLSM)     XMN01100
         SPACE 1                                                        XMN01110
EXDMP    EQU   20                  FORCE A CORE DUMP                    XMN01120
         SPACE 1                                                        XMN01130
GTIME    EQU   24                  RETURN TIME AND DATE                 XMN01140
         SPACE 1                                                        XMN01150
RSVD1    EQU   28                  REWIND SEQUENTIAL FILES                      
         SPACE 1                                                        XMN01170
RSVD2    EQU   32                 CLOCK_TRAP                                    
         SPACE 1                                                        XMN01190
RSVD3    EQU   36                 INTERRUPT_TRAP                                
         SPACE 1                                                        XMN01210
RSVD4    EQU   40                  MONITOR                                      
         SPACE 1                                                        XMN01230
RSVD5    EQU   44                  (UNUSED)                             XMN01240
         SPACE 1                                                        XMN01250
RSVD6    EQU   48                  (UNUSED)                             XMN01260
         SPACE 1                                                        XMN01270
         SPACE 2                                                        XMN01280
*********************************************************************** XMN01290
*                                                                     * XMN01300
*        GENERATE THE SERVICE CODES FOR DIRECT ACCESS FILE I/O        * XMN01310
*        BASED ON THE NUMBER OF FILES AVAILABLE  (&FILES)             * XMN01320
*                                                                     * XMN01330
*********************************************************************** XMN01340
         SPACE 2                                                        XMN01350
FILEORG  EQU   RSVD6+4             ORIGIN FOR THE FILE SERVICE CODES    XMN01360
         SPACE 1                                                        XMN01370
&I       SETA  1                                                        XMN01380
.SC1     AIF   (&I GT &FILES).SC2                                       XMN01390
RD&I     EQU   FILEORG+8*(&I-1)    CODE FOR READING FILE&I              XMN01400
WRT&I    EQU   FILEORG+8*(&I-1)+4  CODE FOR WRITING FILE&I              XMN01410
&I       SETA  &I+1                                                     XMN01420
         AGO   .SC1                                                     XMN01430
.SC2     ANOP                                                           XMN01440
         SPACE 2                                                        XMN01450
ENDSERV  EQU   FILEORG+8*(&I-1)    1ST UNUSED SERVICE CODE              XMN01460
         SPACE 2                                                        XMN01470
*********************************************************************** XMN01480
*                                                                     * XMN01490
*                                                                     * XMN01500
*        DEFINE REGISTER USAGE                                        * XMN01510
*                                                                     * XMN01520
*********************************************************************** XMN01530
         SPACE 2                                                        XMN01540
RTN      EQU   3                   REGISTER CONTAINING COMPLETION       XMN01550
*                                  CODE RETURNED BY THE PROGRAM         XMN01560
         SPACE 1                                                        XMN01570
EBR      EQU   10                  BASE REGISTER USED DURING            XMN01580
*                                  INITIALIZATION                       XMN01590
         SPACE 1                                                        XMN01600
CBR      EQU   12                  LINKAGE REGISTER USED FOR CALLS      XMN01610
*                                  TO THE SUBMONITOR                    XMN01620
         SPACE 1                                                        XMN01630
SELF     EQU   15                  REGISTER THAT ALWAYS CONTAINS        XMN01640
*                                  THE ADDRESS OF THE SUBMONITOR        XMN01650
*                                  ENTRY POINT                          XMN01660
         SPACE 1                                                        XMN01670
*********************************************************************** XMN01680
*                                                                     * XMN01690
*        BIT CONSTANTS NEEDED FOR CONVERSING WITH OS/360 DCBS         * XMN01700
*                                                                     * XMN01710
*********************************************************************** XMN01720
         SPACE 2                                                        XMN01730
OPENBIT  EQU   B'00010000'         DCBOFLGS BIT INDICATING OPEN         XMN01740
*                                  SUCCESSFULLY COMPLETED               XMN01750
         SPACE 1                                                        XMN01760
TAPEBITS EQU   B'10000001'         BITS INDICATING A MAGNETIC TAPE      XMN01770
         SPACE 1                                                        XMN01780
KEYLBIT  EQU   B'00000001'         BIT IN RECFM THAT INDICATES          XMN01790
*                                  KEYLEN WAS SET EXPLICITELY ZERO      XMN01800
         SPACE 2                                                        XMN01810
*********************************************************************** XMN01820
*                                                                     * XMN01830
*        FLAG BITS USED TO CONTROL SUBMONITOR OPERATION               * XMN01840
*                                                                     * XMN01850
*********************************************************************** XMN01860
         SPACE 2                                                        XMN01870
ALLBITS  EQU   B'11111111'         MASK                                 XMN01880
         SPACE 1                                                        XMN01920
SFILLBIT EQU   B'01000000'         1 CHARACTER OF FILL NEEDED BY        XMN01930
*                                  THE PUT ROUTINE                      XMN01940
         SPACE 1                                                        XMN01950
LFILLBIT EQU   B'00100000'         LONGER FILL NEEDED BY PUT ROUTINE    XMN01960
         SPACE 1                                                        XMN01970
DUMPBIT  EQU   B'00001000'         GIVE A CORE DUMP FOR I/O ERRORS      XMN01980
         SPACE 2                                                        XMN01990
*********************************************************************** XMN02000
*                                                                     * XMN02010
*                                                                     * XMN02020
*              DEFINE ABEND CODES ISSUED BY THE SUBMONITOR            * XMN02030
*                                                                     * XMN02040
*********************************************************************** XMN02050
         SPACE 2                                                        XMN02060
OPENABE  EQU   100                 UNABLE TO OPEN ONE OF THE FILES:     XMN02070
*                                  PROGRAM, SYSIN, OR SYSPRINT          XMN02080
         SPACE 1                                                        XMN02090
PGMEOD   EQU   200                 UNEXPECTED END OF FILE WHILE         XMN02100
*                                  READING IN THE XPL PROGRAM           XMN02110
         SPACE 1                                                        XMN02120
PGMERR   EQU   300                 SYNAD ERROR WHILE READING IN         XMN02130
*                                  THE XPL PROGRAM                      XMN02140
         SPACE 1                                                        XMN02150
COREABE  EQU   400                 XPL PROGRAM WON'T FIT IN             XMN02160
*                                  THE AMOUNT OF MEMORY AVAILABLE       XMN02170
         SPACE 1                                                        XMN02180
CODEABE  EQU   500                 INVALID SERVICE CODE FROM THE        XMN02190
*                                  XPL PROGRAM                          XMN02200
         SPACE 1                                                        XMN02210
OUTSYND  EQU   800                 SYNAD ERROR ON OUTPUT FILE           XMN02220
         SPACE 1                                                        XMN02230
PFABE    EQU   900                 INVALID OUTPUT FILE SPECIFIED        XMN02240
         SPACE 1                                                        XMN02250
INSYND   EQU   1000                SYNAD ERROR ON INPUT FILE            XMN02260
         SPACE 1                                                        XMN02270
INEODAB  EQU   1200                END OF FILE ERROR ON INPUT FILE      XMN02280
         SPACE 1                                                        XMN02290
GFABE    EQU   1400                INVALID INPUT FILE SPECIFIED         XMN02300
         SPACE 1                                                        XMN02310
FLSYND   EQU   2000                SYNAD ERROR ON DIRECT ACCESS FILE    XMN02320
         SPACE 1                                                        XMN02330
FLEOD    EQU   2200                END OF FILE ERROR ON DIRECT          XMN02340
*                                  ACCESS FILE                          XMN02350
         SPACE 1                                                        XMN02360
USERABE  EQU   4000                XPL PROGRAM CALLED EXIT TO           XMN02370
*                                  FORCE A CORE DUMP                    XMN02380
         EJECT                                                          XMN02390
         SPACE 5                                                        XMN02400
*********************************************************************** XMN02410
*                                                                     * XMN02420
*                                                                     * XMN02430
*                                                                     * XMN02440
*        SUBMONITOR  INITIALIZATION                                   * XMN02450
*                                                                     * XMN02460
*                                                                     * XMN02470
*********************************************************************** XMN02480
         SPACE 3                                                        XMN02490
         ENTRY PASCAL1             WHERE OS ENTERS THE OVERLAY MONITOR          
         SPACE 2                                                        XMN02510
         DS    0F                                                       XMN02520
         USING *,15                                                     XMN02530
         SPACE 1                                                        XMN02540
PASCAL1  SAVE  (14,12),T,*         SAVE ALL REGISTERS                           
         ST    13,SAVE+4           SAVE RETURN POINTER                  XMN02560
         LA    15,SAVE             ADDRESS OF SUBMONITOR'S OS SAVE AREA XMN02570
         ST    15,8(0,13)                                               XMN02580
         LR    13,15                                                    XMN02590
         USING SAVE,13                                                  XMN02600
         BALR  EBR,0               BASE ADDRESS FOR INITIALIZATION      XMN02610
         USING *,EBR                                                    XMN02620
BASE1    DS    0H                                                       XMN02630
         DROP  15                                                       XMN02640
         L     1,0(,1)             ADDRESS OF A POINTER TO THE PARM     XMN02650
*                                  FIELD OF THE OS EXEC CARD            XMN02660
         MVI   FLAGS,B'00000000'   RESET ALL FLAGS                      XMN02680
         LH    4,0(,1)             LENGTH OF THE PARM FIELD             XMN02690
         LA    1,2(,1)             ADDRESS OF THE PARM STRING           XMN02700
         LA    4,0(1,4)            ADDRESS OF END OF PARAMETER LIST     XMN02710
         LA    7,PARMSCAN                                               XMN02720
         SPACE 2                                                        XMN02730
PARMSCAN DS    0H                                                       XMN02740
         CR    1,4                 ARE WE DONE ?                        XMN02750
         BNL   NOPARMS             YES, SO QUIT LOOKING                 XMN02760
PS6      CLC   DMPM,0(1)           CHECK FOR 'DUMP'                     XMN03020
         BNE   PS8                 NOT FOUND                                    
         OI    FLAGS,DUMPBIT       SET DUMP ON ERROR FLAG               XMN03040
         LA    1,L'DMPM+1(,1)      INCREMENT POINTER                    XMN03050
         BR    7                   BRANCH TO TEST                       XMN03060
PS8      CLC   TIMEM,0(1)          CHECK FOR 'TIME=SSS'                         
         BNE   PS9                 NOT FOUND                                    
         BAL   CBR,DIGET           GET TIME ESTIMATE                            
         ST    3,SECONDS           STORE IT IN MONITOR_LINK                     
         BR    7                   BRANCH TO TEST                               
PS9      CLC   LINESM,0(1)         CHECK FOR 'LINES=LLLL'                       
         BNE   PS10                NOT FOUND                                    
         BAL   CBR,DIGET           GET LINES ESTIMATE                           
         ST    3,LINES             STORE IN MONITOR_LINK                        
         BR    7                   BRANCH TO TEST                               
PS10     CLC   DEBUGM,0(1)         CHECK FOR 'DEBUG=D'                          
         BNE   PSBUMP              NOT FOUND                                    
         BAL   CBR,DIGET           GET DEBUG LEVEL                              
         ST    3,DBGLVL            STORE IN MONITOR_LINK                        
         BR    7                   BRANCH TO TEST                               
PSBUMP   LA    1,1(,1)             INCREMENT POINTER TO PARM STRING     XMN03220
         BR    7                   BRANCH TO TEST                       XMN03230
NOPARMS  DS    0H                                                       XMN03240
         SPACE 2                                                                
*********************************************************************** XMN03260
*                                                                     * XMN03270
*                                                                     * XMN03280
*        OPEN THE FILES  PROGRAM, SYSIN, AND SYSPRINT                 * XMN03290
*                                                                     * XMN03300
*********************************************************************** XMN03310
         SPACE 2                                                        XMN03320
         OPEN  (INPUT0,(INPUT),OUTPUT0,(OUTPUT),PROGRAM,(INPUT))        XMN03330
         SPACE 1                                                        XMN03340
         L     3,GETDCBS           ADDRESS OF DCB FOR INPUT0            XMN03350
         USING IHADCB,3                                                 XMN03360
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING         XMN03370
         BZ    BADOPEN             INPUT0 NOT OPENED SUCCESSFULLY       XMN03380
         L     3,PUTDCBS           ADDRESS OF DCB FOR OUTPUT0           XMN03390
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING         XMN03400
         BZ    BADOPEN             OUTPUT0 NOT OPENED SUCCESSFULLY      XMN03410
         L     3,PGMDCB            ADDRESS OF DCB FOR PROGRAM           XMN03420
         TM    DCBOFLGS,OPENBIT    TEST FOR SUCCESSFUL OPENING          XMN03430
         BNZ   OPENOK              PROGRAM SUCCESSFULLY OPENED          XMN03440
         DROP  3                                                        XMN03450
         SPACE 2                                                        XMN03460
BADOPEN  LA    1,OPENABE           ABEND BECAUSE FILES DIDN'T OPEN      XMN03470
*                                  PROPERLY                             XMN03480
         B     ABEND               GO TO ABEND ROUTINE                  XMN03490
         SPACE 2                                                        XMN03500
OPENOK   DS    0H                                                       XMN03510
         SPACE 2                                                        XMN03520
*********************************************************************** XMN03530
*                                                                     * XMN03540
*                                                                     * XMN03550
*        NOW OBTAIN SPACE IN MEMORY FOR THE XPL PROGRAM AND ITS       * XMN03560
*        FREE STRING AREA.  A GETMAIN IS ISSUED TO OBTAIN AS MUCH     * XMN03570
*        MEMORY AS POSSIBLE WITHIN THE PARTITION.  THEN A FREEMAIN    * XMN03580
*        IS ISSUED TO RETURN THE AMOUNT OF MEMORY SPECIFIED BY        * XMN03590
*        THE VARIABLE 'FREEUP' TO OS/360 FOR USE AS WORK SPACE.       * XMN03600
*        OS/360 NEEDS SPACE FOR FOR DYNAMICALLY CREATING BUFFERS      * XMN03610
*        FOR THE SEQUENTIAL INPUT AND OUTPUT FILES AND FOR            * XMN03620
*        OVERLAYING I/O ROUTINES.                                     * XMN03630
*                                                                     * XMN03640
*           THE AMOUNT OF CORE REQUESTED FROM OS/360 CAN BE ALTERED   * XMN03650
*        WITH THE 'MAX=NNNN' AND 'MIN=MMMM' PARAMETERS TO THE         * XMN03660
*        SUBMONITOR.  THE AMOUNT OF CORE RETURNED TO OS/360 CAN BE    * XMN03670
*        ALTERED WITH THE 'FREE=NNNN' OR THE 'ALTER' PARAMETER        * XMN03680
*                                                                     * XMN03690
*                                                                     * XMN03700
*        MEMORY REQUEST IS DEFINED BY THE CONTROL BLOCK STARTING AT   * XMN03710
*        'COREREQ'.  THE DESCRIPTION OF THE MEMORY SPACE OBTAINED     * XMN03720
*        IS PUT INTO THE CONTROL BLOCK STARTING AT 'ACORE'.           * XMN03730
*                                                                     * XMN03740
*                                                                     * XMN03750
*********************************************************************** XMN03760
         SPACE 2                                                        XMN03770
         GETMAIN VU,LA=COREREQ,A=ACORE                                  XMN03780
         SPACE 1                                                        XMN03790
         LM    1,2,ACORE           ADDRESS OF CORE OBTAINED TO R1       XMN03800
*                                  LENGTH OF CORE AREA TO R2            XMN03810
         AR    1,2                 ADDRESS OF TOP OF CORE AREA          XMN03820
         S     1,FREEUP            LESS AMOUNT TO BE RETURNED           XMN03830
         ST    1,CORETOP           ADDRESS OF TOP OF USABLE CORE        XMN03840
*                                  (BECOMES 'FREELIMIT')                XMN03850
         S     2,FREEUP            SUBTRACT AMOUNT RETURNED             XMN03860
         ST    2,CORESIZE          SIZE OF AVAILABLE SPACE              XMN03870
         L     0,FREEUP            AMOUNT TO GIVE BACK                  XMN03880
         SPACE 1                                                        XMN03890
         FREEMAIN R,LV=(0),A=(1)   GIVE 'FREEUP' BYTES OF CORE BACK     XMN03900
         SPACE 2                                                        XMN03910
*********************************************************************** XMN03920
*                                                                     * XMN03930
*                                                                     * XMN03940
*        READ IN THE BINARY XPL PROGRAM AS SPECIFIED BY THE           * XMN03950
*                                                                     * XMN03960
*        //PASS1    DD  .....                                         * XMN03970
*                                                                     * XMN03970
*        AND                                                          * XMN03970
*                                                                     * XMN03970
*        //PASS2    DD  .....                                         * XMN03970
*                                                                     * XMN03980
*        CARDS. IT IS ASSUMED THAT THE BINARY PROGRAM IS IN STANDARD  * XMN03990
*        XPL SYSTEM FORMAT.                                           * XMN04000
*                                                                     * XMN04010
*                                                                     * XMN04020
*        THE 1ST RECORD OF THE BINARY PROGRAM FILE SHOULD BEGIN       * XMN04030
*        WITH A BLOCK OF INFORMATION DESCRIBING THE CONTENTS OF       * XMN04040
*        THE FILE.  THE FORMAT OF THIS BLOCK IS GIVEN IN THE DSECT    * XMN04050
*        'FILECTRL' AT THE END OF THIS ASSEMBLY.                      * XMN04060
*                                                                     * XMN04070
*                                                                     * XMN04080
*********************************************************************** XMN04090
         SPACE 2                                                        XMN04100
         MVI   PASS,X'1'           SIGNAL FOR LOADING OF PASS1                  
READPASS L     2,ACORE             ADDRESS OF START OF CORE AREA        XMN04110
         LR    4,2                 SAVE STARTING ADDRESS                XMN04120
         USING FILECTRL,4          ADDRESS OF CONTROL BLOCK             XMN04130
         ST    2,CODEADR           SAVE STARTING ADDRESS FOR USE        XMN04140
*                                  BY THE XPL PROGRAM                   XMN04150
         BAL   CBR,READPGM         READ IN 1ST RECORD                   XMN04160
         L     3,BYTSCODE          NUMBER OF BYTES OF CODE              XMN04170
         S     3,BYTSBLK           LESS ONE RECORD                      XMN04180
         A     3,BYTSFULL          PLUS AMOUNT IN LAST CODE RECORD      XMN04190
         A     3,BYTSDATA          PLUS SIZE OF DATA AREA               XMN04200
         C     3,CORESIZE          COMPARE WITH SPACE AVAILABLE         XMN04210
         LA    1,COREABE           ABEND CODE FOR NO ROOM IN CORE       XMN04220
         BH    ABEND               WON'T FIT, SO ABEND                  XMN04230
         L     5,BLKSCODE          NUMBER OF RECORDS OF CODE            XMN04240
         L     3,BYTSBLK           NUMBER OF BYTES PER RECORD           XMN04250
         B     LOAD1               GO TEST FOR MORE CODE RECORDS        XMN04260
         SPACE 1                                                        XMN04270
RCODE    AR    2,3                 ADDRESS TO PUT NEXT RECORD           XMN04280
         BAL   CBR,READPGM         READ IN THE BINARY XPL PROGRAM       XMN04290
LOAD1    BCT   5,RCODE             LOOP BACK TO GET NEXT RECORD         XMN04300
         SPACE 1                                                        XMN04310
         A     2,BYTSFULL          NUMBER OF BYTES ACTUALLY             XMN04320
*                                  USED IN LAST CODE RECORD             XMN04330
         ST    2,DATADR            SAVE ADDRESS OF DATA AREA            XMN04340
*                                  FOR USE BY THE XPL PROGRAM           XMN04350
         L     5,BLKSDATA          NUMBER OF RECORDS OF DATA            XMN04360
         SPACE 1                                                        XMN04370
RDATA    BAL   CBR,READPGM         READ IN THE XPL PROGRAM'S DATA AREA  XMN04380
         AR    2,3                 ADDRESS TO PUT NEXT RECORD           XMN04390
         BCT   5,RDATA             LOOP BACK FOR NEXT RECORD            XMN04400
         DROP  4                                                        XMN04410
         SPACE 2                                                        XMN04420
*********************************************************************** XMN04430
*                                                                     * XMN04440
*                                                                     * XMN04450
*        CODE TO BRANCH TO THE XPL PROGRAM                            * XMN04460
*                                                                     * XMN04470
*                                                                     * XMN04480
*********************************************************************** XMN04490
         SPACE 2                                                        XMN04500
         L     2,DATADR           FILL IN MONITOR_LINK                          
         MVC   104(16,2),LINKSAVE                                               
         LA    SELF,ENTRY          ADDRESS OF ENTRY POINT TO XPLSM      XMN04510
         LM    0,3,PGMPARMS        PARAMETERS FOR THE XPL PROGRAM       XMN04540
         DROP  EBR,13                                                   XMN04550
         USING ENTRY,SELF                                               XMN04560
         SPACE 2                                                        XMN04570
         USING FILECTRL,2          ADDRESS OF FIRST RECORD OF CODE      XMN04580
GOC      BAL   CBR,CODEBEGN        BRANCH TO HEAD OF THE XPL PROGRAM    XMN04590
         DROP  2                                                        XMN04600
         SPACE 1                                                        XMN04610
*********************************************************************** XMN04620
*                                                                     * XMN04630
*                                                                     * XMN04640
*        THE XPL PROGRAM RETURNS HERE AT THE END OF EXECUTION         * XMN04650
*                                                                     * XMN04660
*                                                                     * XMN04670
*********************************************************************** XMN04680
         SPACE 2                                                        XMN04690
         L     EBR,ABASE1          REGISTER FOR ADDRESSABILITY          XMN04700
         USING BASE1,EBR                                                XMN04710
         ST    RTN,RTNSV           SAVE COMPLETION CODE RETURNED BY     XMN04720
*                                  THE XPL PROGRAM FOR PASSING TO OS    XMN04730
         L     13,ASAVE            ADDRESS OF OS/360 SAVE AREA          XMN04760
         USING SAVE,13                                                  XMN04770
         DROP  SELF                                                     XMN04780
         SPACE 2                                                        XMN04790
***********************************************************************         
*                                                                     *         
*                                                                     *         
*        SEE IF THERE ARE OTHER PASSES TO BE LOADED                   *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         L     2,DATADR            ADDRESS OF XPL DATA SEGMENT                  
         MVC   LINKSAVE(16),104(2) SAVE MONITOR_LINK.                           
         TM    LINKSAVE,X'80'      IS INHIBIT BIT ON?                           
         BNZ   RETURN              YES, SO TERMINATE.                           
         CLI   PASS,NPASSES        LAST PASS?                                   
         BE    SMRET               YES, ENTER EXECUTION PHASE.                  
         XR    2,2                 NO -- INCREMENT PASS COUNTER                 
         IC    2,PASS                                                           
         LA    2,1(2)                                                           
         STC   2,PASS                                                           
*   CLOSE FILES INPUT2, INPUT3, ... , &INPUTS                                   
         MVI   GETDCBS+4*&INPUTS,X'80'                                          
*                                  FLAG END OF PARAMETER LIST                   
         CLOSE ,MF=(E,GETDCBS+8)                                                
         MVI   GETDCBS+4*&INPUTS,0 CLEAR FLAG                                   
*   CLOSE FILES OUTPUT3, OUTPUT4, ..., THE PROGRAM FILE, AND ALL                
*   DIRECT ACCESS FILES                                                         
         CLOSE ,MF=(E,PUTDCBS+12)                                               
         LA    4,PROGRAM           CLOSE THE PROGRAM FILE                       
         USING IHADCB,4                                                         
         IC    2,DCBDDNAM+4        CHANGE DDNAME TO THAT OF NEXT PASS           
         LA    2,1(2)                                                           
         STC   2,DCBDDNAM+4                                                     
         OPEN  (PROGRAM,(INPUT))   OPEN THE FILE CONTAINING THE NEXT   -        
                                   PASS OF THE COMPILER                         
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING                 
         BZ    BADOPEN             PROGRAM NOT OPENED SUCCESSFULLY              
         B     READPASS            PROGRAM OPENED SUCCESSFULLY                  
         DROP  4                                                                
         SPACE 2                                                                
*********************************************************************** XMN04800
*                                                                     * XMN04810
*        RELEASE THE MEMORY OCCUPPIED BY THE XPL PROGRAM              * XMN04820
*                                                                     * XMN04830
*********************************************************************** XMN04840
         SPACE 2                                                        XMN04850
SMRET    L     1,ACORE             ADDRESS OF THE BLOCK TO BE FREED     XMN04860
         L     0,CORESIZE          LENGTH OF THE BLOCK TO BE FREED      XMN04870
         SPACE 1                                                        XMN04880
         FREEMAIN R,LV=(0),A=(1)   FREEDOM NOW !                        XMN04890
         SPACE 1                                                        XMN04900
         TM    LINKSAVE,X'80'      IS INHIBIT BIT ON?                           
         BNZ   RETURN              YES, DO NOT RUN THE PASCAL PROGRAM.          
         MVI   GETDCBS+4*&INPUTS,X'80' FLAG END OF LIST                         
         CLOSE ,MF=(E,GETDCBS+8)   CLOSE SYSUT INPUT FILES                      
         MVI   GETDCBS+4*&INPUTS,X'00' CLEAR FLAG                               
         MVI   PUTDCBS+4*&OUTPUTS,X'80' FLAG END OF LIST                        
         CLOSE ,MF=(E,PUTDCBS+12)  CLOSE SYSUT OUTPUT FILES                     
         MVI   PUTDCBS+4*&OUTPUTS,X'00' CLEAR FLAG                              
         CLOSE ,MF=(E,PGMDCB)      CLOSE THE PROGRAM FILE.                      
         LA    1,STATBLK           ADDRESS OF STATUS BLOCK                      
         ST    1,LINKSAVE+4*3      STORE IN MONITOR_LINK(3).                    
*        LINK TO RUN MONITOR                                                    
         LINK  EP=RMONITOR,PARAM=(LINKSAVE,INPUT0,OUTPUT0)                      
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*        THE PASCAL RUN MONITOR RETURNS THE ADDRESS OF A BLOCK OF     *         
*        STATUS INFORMATION IN MONITOR_LINK(3).  THE FORMAT OF THIS   *         
*        BLOCK IS DEFINED BY THE DSECT 'STATUS'.                      *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         L     1,LINKSAVE+4*3      MONITOR_LINK(3) IN REG. 1                    
         USING STATUS,1            REG. 1 POINTS TO STATUS BLOCK.               
         L     2,ARBASE            ADDRESS OF GLOBAL ACTIVATION RECORD.         
         ST    2,CORETOP           BECOMES 'FREELIMIT'                          
         L     3,CODEPNT           ADDRESS OF PASCAL CODE SEGMENT.              
         ST    3,ACORE             WHERE POST-MORTEM ANALYSIS PHASE             
*                                  IS LOADED.                                   
         SR    2,3                 LENGTH OF PASCAL CODE SEGMENT.               
         ST    2,CORESIZE          BECOMES PMD REGION SIZE.                     
         DROP  1                                                                
         TM    LINKSAVE,X'80'      INHIBIT BIT SET?                             
         BNZ   RETURN              YES, FINISH UP.                              
         LA    4,PROGRAM           ADDRESS OF PROGRAM DCB.                      
         USING IHADCB,4                                                         
         MVC   DCBDDNAM,PMDCHARS   DDNAME = 'PMD'.                              
         OPEN  (PROGRAM,(INPUT))   OPEN THE PMD FILE.                           
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING.                
         BZ    BADOPEN             PROGRAM NOT OPENED SUCCESSFULLY.             
         OI    LINKSAVE,X'80'      SET THE INHIBIT BIT.                         
         B     READPASS            LOAD THE POST-MORTEM ANALYSIS PHASE.         
         DROP  4                                                                
         SPACE 1                                                                
RETURN   DS    0H                  PREPARE TO RETURN TO OS/360                  
         CLOSE (INPUT0,,OUTPUT0)                                        XMN04910
         SPACE 1                                                        XMN04920
*********************************************************************** XMN04930
*                                                                     * XMN04940
*        WARNING,  THE CLOSE OF INPUT0 AND OUTPUT0 MUST PRECEDE       * XMN04950
*        THE CLOSE WHICH USES THE GETDCBS LIST.  THE CLOSE SVC WILL   * XMN04960
*        LOOP INDEFINITELY IF THE SAME DCB ADDRESS APPEARS TWICE IN   * XMN04970
*        A CLOSE LIST.                                                * XMN04980
*                                                                     * XMN04990
*********************************************************************** XMN05000
         SPACE 1                                                        XMN05010
         CLOSE ,MF=(E,GETDCBS)     CLOSE ALL FILE KNOWN TO XPLSM        XMN05020
         SPACE 1                                                        XMN05030
         L     15,RTNSV            LOAD RETURN CODE                     XMN05040
         L     13,SAVE+4                                                XMN05050
         DROP  13                                                       XMN05060
         RETURN (14,12),RC=(15)    RETURN TO OS/360                     XMN05070
         SPACE 1                                                        XMN05080
         DROP  EBR                                                      XMN05090
         USING SAVE,13                                                  XMN05100
         EJECT                                                          XMN05110
         SPACE 5                                                        XMN05120
*********************************************************************** XMN05130
*                                                                     * XMN05140
*                                                                     * XMN05150
*                                                                     * XMN05160
*        CONSTANTS USED DURING INITIALIZATION                         * XMN05170
*                                                                     * XMN05180
*                                                                     * XMN05190
*********************************************************************** XMN05200
         SPACE 2                                                        XMN05210
SAVE     DS    18F                 SAVE AREA FOR OS/360                 XMN05220
ACORE    DS    A                   ADDRESS OF CORE FOR THE PROGRAM      XMN05230
CORESIZE DS    F                   SIZE OF CORE IN BYTES                XMN05240
COREREQ  DS    0F                  CORE REQUEST CONTROL BLOCK           XMN05270
COREMIN  DC    F'110000'           MINIMUM AMOUNT OF CORE REQUIRED      XMN05280
COREMAX  DC    F'5000000'          MAXIMUM AMOUNT OF CORE REQUESTED     XMN05290
FREEUP   DC    A(10000)            AMOUNT OF CORE TO RETURN TO OS               
LINKSAVE DS    0F                  SAVE AREA FOR MONITOR_LINK                   
SECONDS  DC    F'10'               DEFAULT IS 10 SECONDS                        
LINES    DC    F'1000'             DEFAULT IS 1000 LINES                        
DBGLVL   DC    F'2'                DEFAULT IS DEBUG LEVEL 2                     
LINKRESV DC    F'0'                WORD 4 OF MONITOR_LINK IS RESERVED           
ADDRTIOT DS    F                   ADDRESS OF TASK I/O TABLE                    
STATBLK  DS    7F                  RUN MONITOR COPIES STATUS BLOCK HERE         
NPASSES  EQU   3                   NUMBER OF COMPILER PASSES.                   
PASS     DS    X                   WHICH PASS TO EXECUTE                        
         SPACE 1                                                        XMN05320
*********************************************************************** XMN05330
*                                                                     * XMN05340
*        BLOCK OF PARAMETERS PASSED TO THE XPL PROGRAM                * XMN05350
*                                                                     * XMN05360
*********************************************************************** XMN05370
         SPACE 1                                                        XMN05380
PGMPARMS DS    F                   R0  UNUSED                           XMN05390
CORETOP  DC    A(0)                R1  ADDRESS OF TOP OF CORE           XMN05400
CODEADR  DC    F'0'                R2  ADDRESS OF START OF 1ST RECORD   XMN05410
*                                  OF THE XPL PROGRAM                   XMN05420
DATADR   DC    F'0'                R3  ADDRESS OF THE START OF THE XPL  XMN05430
*                                      PROGRAM'S DATA AREA              XMN05440
         SPACE 1                                                        XMN05450
PMDCHARS DC    CL8'PMD'            MUST BE FULLWORD-ALLIGNED                    
ALTRM    DC    CL5'ALTER'                                               XMN05470
CMNM     DC    CL4'MIN='                                                XMN05480
CMXM     DC    CL4'MAX='                                                XMN05490
FREEM    DC    CL5'FREE='                                               XMN05500
DMPM     DC    CL4'DUMP'                                                XMN05510
FILEM    DC    CL5'FILE='                                               XMN05520
TIMEM    DC    CL5'TIME='                                                       
LINESM   DC    CL6'LINES='                                                      
DEBUGM   DC    CL6'DEBUG='                                                      
         EJECT                                                          XMN05530
         SPACE 5                                                        XMN05540
*********************************************************************** XMN05550
*                                                                     * XMN05560
*                                                                     * XMN05570
*        ROUTINE TO SCAN PARAMETER STRINGS FOR DIGITS                 * XMN05580
*                                                                     * XMN05590
*                                                                     * XMN05600
*********************************************************************** XMN05610
         SPACE 2                                                        XMN05620
DIGET    DS    0H                                                       XMN05630
         SR    2,2                 CLEAR REGISTER                       XMN05640
         SR    3,3                  "                                   XMN05650
DG1      CLI   0(1),C'='           CHECK FOR '='                        XMN05660
         BE    DG2                                                      XMN05670
         LA    1,1(,1)             INCREMENT POINTER                    XMN05680
         CR    1,4                 AT END ?                             XMN05690
         BCR   B'1011',CBR        YES, SO RETURN                                
         B     DG1                 KEEP LOOKING FOR '='                 XMN05710
DG2      LA    1,1(,1)             INCREMENT POINTER                    XMN05720
         LA    5,C'0'              BINARY VALUE OF '0'                  XMN05730
DGLP     IC    2,0(,1)             FETCH A CHARACTER                    XMN05740
         SR    2,5                 NORMALIZE                            XMN05750
         BM    DGDN                NOT A DIGIT SO DONE                  XMN05760
         LR    0,3                                                      XMN05770
         SLL   3,2                 NUMBER*4                             XMN05780
         AR    3,0                 NUMBER*5                             XMN05790
         SLL   3,1                 NUMBER*10                            XMN05800
         AR    3,2                 ADD IN NEW DIGIT                     XMN05810
         LA    1,1(,1)             INCREMENT POINTER                    XMN05820
         CR    1,4                 AT END ?                             XMN05830
         BL    DGLP                NO                                   XMN05840
DGDN     LA    1,1(,1)             INCREMENT POINTER                    XMN05850
         BR    CBR                 RETURN                               XMN05860
*                                  VALUE OF NUMBER IS IN REG 3          XMN05870
         EJECT                                                          XMN05880
         SPACE 5                                                        XMN05890
*********************************************************************** XMN05900
*                                                                     * XMN05910
*                                                                     * XMN05920
*        ROUTINE TO READ IN THE BINARY IMAGE OF THE XPL PROGRAM       * XMN05930
*                                                                     * XMN05940
*                                                                     * XMN05950
*********************************************************************** XMN05960
         SPACE 2                                                        XMN05970
READPGM  DS    0H                                                       XMN05980
*                                  SHARE DECB WITH FILE READ ROUTINE    XMN05990
         SPACE 1                                                        XMN06000
         READ  RDECB,SF,PROGRAM,(2),MF=E                                XMN06010
         CHECK RDECB               WAIT FOR READ TO COMPLETE            XMN06020
         SPACE 1                                                        XMN06030
         BR    CBR                 RETURN TO CALLER                     XMN06040
         EJECT                                                          XMN06050
         SPACE 5                                                        XMN06060
*********************************************************************** XMN06070
*                                                                     * XMN06080
*                                                                     * XMN06090
*        ROUTINES TO PROVIDE DEFAULT DATASET INFORMATION IF NONE      * XMN06100
*        IS PROVIDED BY JCL OR VOLUME LABELS.  IN PARTICULAR,         * XMN06110
*        BLKSIZE, LRECL, BUFNO, AND RECFM INFORMATION.                * XMN06120
*                                                                     * XMN06130
*                                                                     * XMN06140
*        EXIT LISTS FOR DCBS                                          * XMN06150
*                                                                     * XMN06160
*********************************************************************** XMN06170
         SPACE 2                                                        XMN06180
         DS    0F                                                       XMN06190
INEXIT0  DC    X'85'               INPUT0                               XMN06200
         DC    AL3(INXT0)                                               XMN06210
         SPACE 1                                                        XMN06220
OUTEXIT0 DC    X'85'               OUTPUT0                              XMN06230
         DC    AL3(OUTXT0)                                              XMN06240
         SPACE 1                                                        XMN06250
INEXIT2  DC    X'85'               INPUT2                               XMN06260
         DC    AL3(INXT2)                                               XMN06270
         SPACE 1                                                        XMN06280
OUTEXIT2 EQU   INEXIT0             OUTPUT2                              XMN06290
         SPACE 2                                                        XMN06300
&I       SETA  3                                                        XMN06310
.IDF1    AIF   (&I GT &INPUTS).IDF2                                     XMN06320
INEXIT&I EQU   INEXIT2             INPUT&I                              XMN06330
&I       SETA  &I+1                                                     XMN06340
         AGO   .IDF1                                                    XMN06350
.IDF2    ANOP                                                           XMN06360
         SPACE 1                                                        XMN06370
&I       SETA  3                                                        XMN06380
.ODF1    AIF   (&I GT &OUTPUTS).ODF2                                    XMN06390
OUTEXIT&I EQU  INEXIT2                                                  XMN06400
&I       SETA  &I+1                                                     XMN06410
         AGO   .ODF1                                                    XMN06420
.ODF2    ANOP                                                           XMN06430
         SPACE 1                                                        XMN06440
*********************************************************************** XMN06450
*                                                                     * XMN06460
*        DCB EXIT ROUTINE ENTRY POINTS                                * XMN06470
*                                                                     * XMN06480
*********************************************************************** XMN06490
         SPACE 2                                                        XMN06500
INXT0    MVC   DEFAULTS(6),INDFLT0                                      XMN06510
         B     GENXT                                                    XMN06520
         SPACE 1                                                        XMN06530
INXT2    MVC   DEFAULTS(6),INDFLT2                                      XMN06540
         B     GENXT                                                    XMN06550
         SPACE 1                                                        XMN06560
OUTXT0   MVC   DEFAULTS(6),OUTDFLT0                                     XMN06570
         SPACE 1                                                        XMN06580
*********************************************************************** XMN06590
*                                                                     * XMN06600
*                                                                     * XMN06610
*        DCB EXIT LIST PROCESSING ROUTINE FOR OPEN EXITS              * XMN06620
*                                                                     * XMN06630
*********************************************************************** XMN06640
         SPACE 2                                                        XMN06650
GENXT    DS    0H                                                       XMN06660
         USING IHADCB,1            REGISTER 1 POINTS AT THE DCB         XMN06670
         NC    DCBBLKSI,DCBBLKSI   CHECK BLKSIZE                        XMN06680
         BNZ   GXT1                ALREADY SET                          XMN06690
         MVC   DCBBLKSI(2),DFLTBLKS                                     XMN06700
*                                  PROVIDE DEFAULT BLOCKSIZE            XMN06710
         SPACE 1                                                        XMN06720
GXT1     NC    DCBLRECL,DCBLRECL   CHECK LRECL                          XMN06730
         BNZ   GXT2                ALREADY SET                          XMN06740
         MVC   DCBLRECL(2),DFLTLREC                                     XMN06750
*                                  PROVIDE DEFAULT LRECL                XMN06760
         SPACE 1                                                        XMN06770
GXT2     CLI   DCBBUFNO,0          CHECK BUFNO                          XMN06780
         BNE   GXT3                ALREADY SPECIFIED                    XMN06790
         MVC   DCBBUFNO(1),DFLTBUFN                                     XMN06800
*                                  PROVIDE DEFAULT BUFNO                XMN06810
         SPACE 1                                                        XMN06820
GXT3     TM    DCBRECFM,ALLBITS-KEYLBIT                                 XMN06830
*                                  CHECK RECFM                          XMN06840
         BCR   B'0111',14          ALREADY SET SO RETURN                XMN06850
         OC    DCBRECFM(1),DFLTRECF                                     XMN06860
*                                  PROVIDE DEFAULT RECFM                XMN06870
         BR    14                  RETURN                               XMN06880
         DROP  1                                                        XMN06890
         SPACE 2                                                        XMN06900
*********************************************************************** XMN06910
*                                                                     * XMN06920
*        ARRAY OF DEFAULT ATTRIBUTES USED BY GENXT                    * XMN06930
*                                                                     * XMN06940
*********************************************************************** XMN06950
         SPACE 1                                                        XMN06960
DEFAULTS DS    0H                                                       XMN06970
DFLTBLKS DS    1H                  DEFAULT BLKSIZE                      XMN06980
DFLTLREC DS    1H                  DEFAULT LRECL                        XMN06990
DFLTBUFN DS    AL1                 DEFAULT BUFNO                        XMN07000
DFLTRECF DS    1BL1                DEFAULT RECFM                        XMN07010
         SPACE 1                                                        XMN07020
*********************************************************************** XMN07030
*                                                                     * XMN07040
*        DEFINE ATTRIBUTES PROVIDED FOR THE VARIOUS FILES             * XMN07050
*                                                                     * XMN07060
*        INPUT(0), INPUT(1), OUTPUT(2)                                * XMN07070
*                                                                     * XMN07080
*********************************************************************** XMN07090
         SPACE 1                                                        XMN07100
INDFLT0  DS    0H                                                       XMN07110
         DC    H'80'               BLKSIZE=80                           XMN07120
         DC    H'80'               LRECL=80                             XMN07130
         DC    AL1(2)              BUFNO=2                              XMN07140
         DC    B'10000000'         RECFM=F                              XMN07150
         SPACE 1                                                        XMN07160
*********************************************************************** XMN07170
*                                                                     * XMN07180
*        OUTPUT(0), OUTPUT(1)                                         * XMN07190
*                                                                     * XMN07200
*********************************************************************** XMN07210
         SPACE 1                                                        XMN07220
OUTDFLT0 DS    0H                                                       XMN07230
         DC    H'133'              BLKSIZE=133                          XMN07240
         DC    H'133'              LRECL=133                            XMN07250
         DC    AL1(2)              BUFNO=2                              XMN07260
         DC    B'10000100'         RECFM=FA                             XMN07270
         SPACE 1                                                        XMN07280
*********************************************************************** XMN07290
*                                                                     * XMN07300
*        INPUT(2), INPUT(3), OUTPUT(3)                                * XMN07310
*                                                                     * XMN07320
*********************************************************************** XMN07330
         SPACE 1                                                        XMN07340
INDFLT2  DS    0H                                                       XMN07350
         DC    AL2(IOFBYTS)        BLKSIZE=IOFBYTS                      XMN07360
         DC    H'80'               LRECL=80                             XMN07370
         DC    AL1(1)              BUFNO=1                              XMN07380
         DC    B'10010000'         RECFM=FB                             XMN07390
         EJECT                                                          XMN07400
         SPACE 5                                                        XMN07410
*********************************************************************** XMN07420
*                                                                     * XMN07430
*                                                                     * XMN07440
*        INPUT - OUTPUT  ERROR ROUTINES                               * XMN07450
*                                                                     * XMN07460
*                                                                     * XMN07470
*                                                                     * XMN07480
*        SYNAD AND EOD ERROR ROUTINES FOR INITIAL LOADING OF THE      * XMN07490
*        XPL PROGRAM                                                  * XMN07500
*                                                                     * XMN07510
*                                                                     * XMN07520
*********************************************************************** XMN07530
         SPACE 2                                                        XMN07540
EODPGM   STM   0,2,ABEREGS         SAVE REGISTERS                       XMN07550
         LA    1,PGMEOD            UNEXPECTED EOD WHILE READING IN      XMN07560
*                                  THE XPL PROGRAM                      XMN07570
         B     ABEND               GO TO ABEND ROUTINE                  XMN07580
         SPACE 2                                                        XMN07590
ERRPGM   STM   0,2,ABEREGS         SAVE REGISTERS                       XMN07600
         LA    1,PGMERR            SYNAD ERROR WHILE READING IN THE     XMN07610
*                                  XPL PROGRAM                          XMN07620
         B     ABEND               GO TO ABEND ROUTINE                  XMN07630
         SPACE 2                                                        XMN07640
*********************************************************************** XMN07650
*                                                                     * XMN07660
*                                                                     * XMN07670
*        SYNAD AND EOD ROUTINES FOR INPUT(I),  I = 0,1, ...  ,&INPUTS * XMN07680
*                                                                     * XMN07690
*********************************************************************** XMN07700
         SPACE 2                                                        XMN07710
INEOD    L     2,SAVREG+PARM2*4    PICK UP SUBCODE SPECIFYING WHICH     XMN07720
*                                  INPUT FILE                           XMN07730
         SLL   2,2                 SUBCODE*4                            XMN07740
         L     2,GETDCBS(2)        FETCH DCB ADDRESS                    XMN07750
         USING IHADCB,2                                                 XMN07760
         ST    2,OCDCB             STORE IT FOR THE CLOSE SVC           XMN07770
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST           XMN07780
         CLOSE ,MF=(E,OCDCB)       CLOSE THE OFFENDING FILE             XMN07790
         CLC   SAVREG+PARM2*4,F1   EOF ON SYSIN?                                
         BH    RETNEOF             NO - FILE STILL USABLE                       
         SPACE 1                                                        XMN07800
PCLOSE   DS    0H                                                       XMN07810
         XC    DCBDDNAM,DCBDDNAM   MARK THE FILE PERMANENTLY UNUSABLE   XMN07820
         DROP  2                                                        XMN07830
         B     RETNEOF             GO RETURN AN END OF FILE INDICATION  XMN07840
         SPACE 2                                                        XMN07850
INSYNAD  STM   0,2,ABEREGS         SAVE REGISTERS                       XMN07860
         LA    1,INSYND            SYNAD ERROR ON AN INPUT FILE         XMN07870
         B     INERR               BRANCH TO ERROR ROUTINE              XMN07880
         SPACE 1                                                        XMN07890
INERR    A     1,SAVREG+PARM2*4    SUBCODE INDICATING WHICH INPUT FILE  XMN07920
         B     ABEND               BRANCH TO ABEND ROUTINE              XMN07930
         SPACE 2                                                        XMN07940
*********************************************************************** XMN07950
*                                                                     * XMN07960
*                                                                     * XMN07970
*        SYNAD ERROR ROUTINES FOR OUTPUT FILES                        * XMN07980
*                                                                     * XMN07990
*                                                                     * XMN08000
*********************************************************************** XMN08010
         SPACE 2                                                        XMN08020
OUTSYNAD STM   0,2,ABEREGS         SAVE REGISTERS                       XMN08030
         LA    1,OUTSYND           SYNAD ERROR ON OUTPUT FILE           XMN08040
         B     INERR                                                    XMN08050
         SPACE 2                                                        XMN08060
*********************************************************************** XMN08070
*                                                                     * XMN08080
*        SYNAD AND EOD ROUTINES FOR DIRECT ACCESS FILE I/O            * XMN08090
*                                                                     * XMN08100
*********************************************************************** XMN08110
         SPACE 2                                                        XMN08120
FILESYND STM   0,2,ABEREGS         SAVE REGISTERS                       XMN08130
         LA    1,FLSYND            SYNAD ERROR ON DIRECT ACCESS FILE    XMN08140
         B     FILERR              GO TO ERROR ROUTINE                  XMN08150
         SPACE 1                                                        XMN08160
FILEEOD  STM   0,2,ABEREGS         SAVE REGISTERS                       XMN08170
         LA    1,FLEOD             EOD ERROR ON DIRECT ACCESS FILE      XMN08180
         SPACE 1                                                        XMN08190
FILERR   L     2,SAVREG+SVCODE*4   SERVICE CODE                         XMN08200
         LA    0,RD1-8             COMPUTE WHICH DIRECT ACCESS FILE     XMN08210
         SR    2,0                 SERVICE_CODE - 1ST SERVICE CODE      XMN08220
         SRL   2,3                 DIVIDE BY 8                          XMN08230
         AR    1,2                                                      XMN08240
*                                  FALL THROUGH TO ABEND ROUTINE        XMN08250
         SPACE 2                                                        XMN08260
*********************************************************************** XMN08270
*                                                                     * XMN08280
*                                                                     * XMN08290
*        ABEND ROUTINE FOR ALL I/O ERRORS                             * XMN08300
*                                                                     * XMN08310
*                                                                     * XMN08320
*********************************************************************** XMN08330
         SPACE 2                                                        XMN08340
ABEND    DS    0H                                                       XMN08350
         ST    1,ABESAVE           SAVE ABEND CODE                      XMN08360
         SPACE 1                                                        XMN08370
         CLOSE (INPUT0,,OUTPUT0)   THESE MUST BE CLOSED FIRST           XMN08380
         CLOSE ,MF=(E,GETDCBS)     ATTEMPT TO CLOSE ALL FILES           XMN08390
         SPACE 1                                                        XMN08400
         L     1,ABESAVE                                                XMN08410
         TM    FLAGS,DUMPBIT       IS A CORE DUMP DESIRED ?             XMN08420
         BZ    NODUMP              NO, ABEND QUIETLY                    XMN08430
         SPACE 1                                                        XMN08440
         ABEND (1),DUMP            ABEND WITH A DUMP                    XMN08450
         SPACE 1                                                        XMN08460
NODUMP   DS    0H                                                       XMN08470
         ABEND (1)                 ABEND WITHOUT A DUMP                 XMN08480
         SPACE 2                                                        XMN08490
*********************************************************************** XMN08500
*                                                                     * XMN08510
*                                                                     * XMN08520
*        ROUTINE TO FORCE AN ABEND DUMP WHEN REQUESTED BY THE         * XMN08530
*        XPL PROGRAM BY MEANS OF THE STATEMENT:                       * XMN08540
*                                                                     * XMN08550
*        CALL  EXIT  ;                                                * XMN08560
*                                                                     * XMN08570
*                                                                     * XMN08580
*********************************************************************** XMN08590
         SPACE 2                                                        XMN08600
USEREXIT DS    0H                                                       XMN08610
         STM   0,2,ABEREGS         SAVE REGISTERS                       XMN08620
         OI    FLAGS,DUMPBIT       FORCE A DUMP                         XMN08630
         LA    1,USERABE           USER ABEND CODE                      XMN08640
         B     ABEND               BRANCH TO ABEND                      XMN08650
         EJECT                                                          XMN08660
         SPACE 5                                                        XMN08670
*********************************************************************** XMN08680
*                                                                     * XMN08690
*                                                                     * XMN08700
*        DISPATCHER FOR ALL SERVICE REQUESTS FROM THE XPL PROGRAM     * XMN08710
*                                                                     * XMN08720
*                                                                     * XMN08730
*********************************************************************** XMN08740
         SPACE 2                                                        XMN08750
         DROP  13                                                       XMN08760
         USING ENTRY,SELF                                               XMN08770
ENTRY    DS    0H                  XPL PROGRAMS ENTER HERE              XMN08780
         STM   0,3,SAVREG          SAVE REGISTERS USED BY XPLSM         XMN08790
         STM   13,15,SAVREG+13*4                                        XMN08800
         L     13,ASAVE            ADDRESS OF OS SAVE AREA              XMN08810
         DROP  SELF                                                     XMN08820
         USING SAVE,13                                                  XMN08830
         SPACE 1                                                        XMN08840
         LTR   SVCODE,SVCODE       CHECK THE SERVICE CODE FOR VALIDITY  XMN08850
         BNP   BADCODE             SERVICE CODE MUST BE > 0             XMN08860
         C     SVCODE,MAXCODE      AND < ENDSERV                        XMN08870
         BH    BADCODE             GO ABEND                             XMN08880
         SPACE 1                                                        XMN08890
TABLE    B     TABLE(SVCODE)       GO DO THE SERVICE                    XMN08900
         SPACE 1                                                        XMN08910
         ORG   TABLE+GETC                                               XMN08920
         B     GET                 READ INPUT FILE                      XMN08930
         SPACE 1                                                        XMN08940
         ORG   TABLE+PUTC                                               XMN08950
         B     PUT                 WRITE OUTPUT FILE                    XMN08960
         SPACE 1                                                        XMN08970
         ORG   TABLE+TRC                                                XMN08980
         B     EXIT                INITIATE TRACING  (NOP)                      
         SPACE 1                                                        XMN09000
         ORG   TABLE+UNTR                                               XMN09010
         B     EXIT                TERMINATE TRACING (NOP)                      
         SPACE 1                                                        XMN09030
         ORG   TABLE+EXDMP                                              XMN09040
         B     USEREXIT            TERMINATE WITH A CORE DUMP           XMN09050
         SPACE 1                                                        XMN09060
         ORG   TABLE+GTIME                                              XMN09070
         B     GETIME              RETURN TIME AND DATE                 XMN09080
         SPACE 1                                                        XMN09090
         ORG   TABLE+RSVD1                                              XMN09100
         B     REWIND              REWIND SEQUENTIAL FILES                      
         SPACE 1                                                        XMN09120
         ORG   TABLE+RSVD2                                              XMN09130
         B     CPUTIMER           CLOCK_TRAP                                    
         SPACE 1                                                        XMN09150
         ORG   TABLE+RSVD3                                              XMN09160
         B     EXIT                INTERRUPT_TRAP    (NOP)              XMN09170
         SPACE 1                                                        XMN09180
         ORG   TABLE+RSVD4                                              XMN09190
         B     EXIT                MONITOR           (NOP)                      
         SPACE 1                                                        XMN09210
         ORG   TABLE+RSVD5                                              XMN09220
         B     EXIT                (UNUSED)                             XMN09230
         SPACE 1                                                        XMN09240
         ORG   TABLE+RSVD6                                              XMN09250
         B     EXIT                (UNUSED)                             XMN09260
         SPACE 2                                                        XMN09270
*********************************************************************** XMN09280
*                                                                     * XMN09290
*                                                                     * XMN09300
*        DYNAMICALLY GENERATE THE DISPATCHING TABLE ENTRIES FOR       * XMN09310
*        FILE I/O SERVICES.                                           * XMN09320
*                                                                     * XMN09330
*                                                                     * XMN09340
*********************************************************************** XMN09350
         SPACE 2                                                        XMN09360
&I       SETA  1                   LOOP INDEX                           XMN09370
.DBR1    AIF   (&I GT &FILES).DBR2                                      XMN09380
*                                  FINISHED ?                           XMN09390
         ORG   TABLE+RD&I                                               XMN09400
         B     READ                BRANCH TO FILE READ ROUTINE          XMN09410
         ORG   TABLE+WRT&I                                              XMN09420
         B     WRITE               BRANCH TO FILE WRITE ROUTINE         XMN09430
&I       SETA  &I+1                INCREMENT COUNTER                    XMN09440
         AGO   .DBR1               LOOP BACK                            XMN09450
.DBR2    ANOP                                                           XMN09460
         SPACE 2                                                        XMN09470
         ORG   TABLE+ENDSERV       RESET PROGRAM COUNTER                XMN09480
         SPACE 2                                                        XMN09490
*********************************************************************** XMN09500
*                                                                     * XMN09510
*                                                                     * XMN09520
*        COMMON EXIT ROUTINE FOR RETURN TO THE XPL PROGRAM            * XMN09530
*                                                                     * XMN09540
*                                                                     * XMN09550
*********************************************************************** XMN09560
         SPACE 2                                                        XMN09570
EXIT     DS    0H                                                       XMN09580
         LM    0,3,SAVREG          RESTORE REGISTERS                    XMN09590
         LM    13,15,SAVREG+13*4                                        XMN09600
         DROP  13                                                       XMN09610
         USING ENTRY,SELF                                               XMN09620
         SPACE 1                                                        XMN09630
         BR    CBR                 RETURN TO THE XPL PROGRAM            XMN09640
         SPACE 1                                                        XMN09650
         DROP  SELF                                                     XMN09660
         USING SAVE,13                                                  XMN09670
         SPACE 2                                                        XMN09680
*********************************************************************** XMN09690
*                                                                     * XMN09700
*        ROUTINE TO ABEND IN CASE OF BAD SERVICE CODES                * XMN09710
*                                                                     * XMN09720
*********************************************************************** XMN09730
         SPACE 2                                                        XMN09740
BADCODE  STM   0,2,ABEREGS         SAVE REGISTERS                       XMN09750
         LA    1,CODEABE           BAD SERVICE CODE ABEND               XMN09760
         B     ABEND               GO ABEND                             XMN09770
         EJECT                                                          XMN09780
         SPACE 5                                                        XMN09790
*********************************************************************** XMN09800
*                                                                     * XMN09810
*                                                                     * XMN09820
*        INPUT ROUTINE FOR READING SEQUENTIAL INPUT FILES             * XMN09830
*                                                                     * XMN09840
*                                                                     * XMN09850
*        INPUT TO THIS ROUTINE IS:                                    * XMN09860
*                                                                     * XMN09870
*      PARM1   ADDRESS OF THE NEXT AVAILABLE SPACE IN THE PROGRAMS    * XMN09880
*              DYNAMIC STRING AREA  (FREEPOINT)                       * XMN09890
*                                                                     * XMN09900
*      SVCODE  THE SERVICE CODE FOR INPUT                             * XMN09910
*                                                                     * XMN09920
*      PARM2   A SUBCODE DENOTING WHICH INPUT FILE,                   * XMN09930
*              INPUT(I),     I = 0,1, ... ,&INPUTS                    * XMN09940
*                                                                     * XMN09950
*        THE ROUTINE RETURNS:                                         * XMN09960
*                                                                     * XMN09970
*      PARM1   A STANDARD XPL STRING DESCRIPTOR POINTING AT THE INPUT * XMN09980
*              RECORD WHICH IS NOW AT THE TOP OF THE STRING AREA      * XMN09990
*                                                                     * XMN10000
*      SVCODE  THE NEW VALUE FOR FREEPOINT, UPDATED BY THE LENGTH OF  * XMN10010
*              THE RECORD JUST READ IN                                * XMN10020
*                                                                     * XMN10030
*                                                                     * XMN10040
*        A STANDARD XPL STRING DESCRIPTOR HAS:                        * XMN10050
*                                                                     * XMN10060
*        BITS  0-7                 (LENGTH - 1) OF THE STRING         * XMN10070
*        BITS  8-31                ABSOLUTE ADDRESS OF THE STRING     * XMN10080
*                                                                     * XMN10090
*                                                                     * XMN10100
*                                                                     * XMN10110
*********************************************************************** XMN10120
         SPACE 2                                                        XMN10130
GET      DS    0H                                                       XMN10140
         LA    SVCODE,&INPUTS      CHECK THAT THE SUBCODE IS VALID      XMN10150
         LTR   PARM2,PARM2         SUBCODE MUST BE >= 0                 XMN10160
         BM    BADGET                                                   XMN10170
         CR    PARM2,SVCODE        AND <= &INPUTS                       XMN10180
         BH    BADGET              ILLEGAL SUBCODE                      XMN10190
         SLL   PARM2,2             SUBCODE*4                            XMN10200
         L     3,GETDCBS(PARM2)    ADDRESS OF DCB FOR THE FILE          XMN10210
         USING IHADCB,3                                                 XMN10220
         NC    DCBDDNAM,DCBDDNAM   HAS THE FILE BEEN PERMANENTLY        XMN10230
*                                  CLOSED ?                             XMN10240
         BZ    RETNEOF             YES, SO RETURN NULL STRING                   
         SPACE 1                                                        XMN10260
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   XMN10270
         BO    GETOPEN             YES                                  XMN10280
         LA    15,4*2              IF SUBCODE > 2 THEN CLOSE OUTPUT DCB         
         CR    PARM2,15                                                         
         BL    GOPEN                                                            
         L     15,PUTDCBS+4(PARM2) ADDRESS OF DCB FOR THE FILE                  
         ST    15,OCDCB            STORE FOR CLOSE SVC                          
         MVI   OCDCB,X'80'         FLAG END OF LIST                             
         CLOSE ,MF=(E,OCDCB)                                                    
GOPEN    ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC       XMN10290
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST           XMN10300
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        XMN10310
         LR    2,3                 COPY DCB ADDRESS                     XMN10320
         TM    DCBOFLGS,OPENBIT    WAS THE FILE OPENED SUCCESSFULLY ?   XMN10330
         BZ    PCLOSE              NO, MARK FILE PERMANENTLY CLOSED AND XMN10340
*                                  RETURN EOD INDICATION TO THE PROGRAM XMN10350
         SPACE 2                                                        XMN10360
GETOPEN  DS    0H                                                       XMN10370
         GET   (3)                 LOCATE MODE GET                      XMN10380
         SPACE 1                                                        XMN10390
*********************************************************************** XMN10400
*                                                                     * XMN10410
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT INPUT BUFFER      * XMN10420
*        IS RETURNED IN R1                                            * XMN10430
*                                                                     * XMN10440
*********************************************************************** XMN10450
         SPACE 1                                                        XMN10460
         L     2,SAVREG+PARM2*4    IS THE FILE SYSIN?                           
         C     2,F1                                                             
         BH    NOTSYSIN            NO, SO BRANCH                                
         CLC   EOFCHARS,0(1)       YES, SO '%EOF' IN COLS. 1 - 4       *        
                                   SIMULATES END-OF-FILE.                       
         BE    RETNEOF                                                          
NOTSYSIN L     2,SAVREG+PARM1*4    FETCH THE STRING DESCRIPTOR                  
         LA    2,0(,2)             ADDRESS PART ONLY                    XMN10480
         LH    3,DCBLRECL          RECORD LENGTH                        XMN10490
         DROP  3                                                        XMN10500
         S     3,F1                LENGTH - 1                           XMN10510
         EX    3,GETMOVE           MOVE THE CHARACTERS                  XMN10520
         ST    2,SAVREG+PARM1*4    BUILD UP A STRING DESCRIPTOR         XMN10530
         STC   3,SAVREG+PARM1*4    LENGTH FIELD                         XMN10540
         LA    2,1(2,3)            NEW FREE POINTER                     XMN10550
         ST    2,SAVREG+SVCODE*4                                        XMN10560
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN10570
         SPACE 2                                                        XMN10580
*********************************************************************** XMN10590
*                                                                     * XMN10600
*        RETURN A NULL STRING DESCRIPTOR AS AN END OF FILE            * XMN10610
*        INDICATION THE FIRST TIME AN INPUT REQUEST FIND THE          * XMN10620
*        END OF DATA CONDITION                                        * XMN10630
*                                                                     * XMN10640
*********************************************************************** XMN10650
         SPACE 2                                                        XMN10660
RETNEOF  DS    0H                                                       XMN10670
         MVC   SAVREG+SVCODE*4(4),SAVREG+PARM1*4                        XMN10680
*                                  RETURN FREEPOINT UNTOUCHED           XMN10690
         XC    SAVREG+PARM1*4(4),SAVREG+PARM1*4                         XMN10700
*                                  RETURN A NULL STRING DESCRIPTOR      XMN10710
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN10720
         SPACE 2                                                        XMN10730
*********************************************************************** XMN10740
*                                                                     * XMN10750
*        ROUTINE TO ABEND IN CASE OF AN INVALID SUBCODE               * XMN10760
*                                                                     * XMN10770
*********************************************************************** XMN10780
         SPACE 2                                                        XMN10790
BADGET   STM   0,2,ABEREGS         SAVE REGISTERS                       XMN10800
         LA    1,GFABE             INVALID GET SUBCODE                  XMN10810
         B     INERR               GO ABEND                             XMN10820
         EJECT                                                          XMN10830
         SPACE 5                                                        XMN10840
*********************************************************************** XMN10850
*                                                                     * XMN10860
*                                                                     * XMN10870
*                                                                     * XMN10880
*        ROUTINE FOR WRITING SEQUENTIAL OUTPUT FILES                  * XMN10890
*                                                                     * XMN10900
*                                                                     * XMN10910
*        INPUT TO THIS ROUTINE:                                       * XMN10920
*                                                                     * XMN10930
*      PARM1   XPL STRING DESCRIPTOR OF THE STRING TO BE OUTPUT       * XMN10940
*                                                                     * XMN10950
*      PARM2   SUBCODE INDICATING  OUTPUT(I),  I = 0,1, ... ,&OUTPUTS * XMN10960
*                                                                     * XMN10970
*      SVCODE  THE SERVICE CODE FOR OUTPUT                            * XMN10980
*                                                                     * XMN10990
*                                                                     * XMN11000
*        THE STRING NAMED BY THE DESCRIPTOR IS PLACED IN THE NEXT     * XMN11010
*        OUTPUT BUFFER OF THE SELECTED FILE.  IF THE STRING IS        * XMN11020
*        SHORTER THAN THE RECORD LENGTH OF THE FILE THEN THE          * XMN11030
*        REMAINDER OF THE RECORD IS PADDED WITH BLANKS.  IF THE       * XMN11040
*        STRING IS LONGER THAN THE RECORD LENGTH OF THE FILE          * XMN11050
*        THEN IT IS TRUNCATED ON THE RIGHT TO FIT.  IF THE SUBCODE    * XMN11060
*        SPECIFIES OUTPUT(0) THEN A SINGLE BLANK IS CONCATENATED      * XMN11070
*        ON TO THE FRONT OF THE STRING TO SERVE AS CARRIAGE CONTROL.  * XMN11080
*                                                                     * XMN11090
*                                                                     * XMN11100
*********************************************************************** XMN11110
         SPACE 2                                                        XMN11120
PUT      DS    0H                                                       XMN11130
         LTR   PARM2,PARM2         CHECK SUBCODE FOR VALIDITY           XMN11140
         BM    BADPUT              SUBCODE MUST BE >= 0                 XMN11150
         LA    SVCODE,&OUTPUTS                                          XMN11160
         CR    PARM2,SVCODE        AND <= &OUTPUTS                      XMN11170
         BH    BADPUT                                                   XMN11180
         ST    PARM1,MOVEADR       SAVE THE STRING DESCRIPTOR           XMN11190
         SLL   PARM2,2             SUBCODE*4                            XMN11200
         L     3,PUTDCBS(PARM2)    GET THE DCB ADDRESS                  XMN11210
         USING IHADCB,3                                                 XMN11220
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   XMN11230
         BO    PUTOPEN             YES, GO DO THE OUTPUT                XMN11240
         LA    15,4*3              IF SUBCODE > 3 THEN CLOSE INPUT DCB          
         CR    PARM2,15                                                         
         BL    POPEN                                                            
         L     15,GETDCBS-4(PARM2) ADDRESS OF DCB FOR THE FILE                  
         ST    15,OCDCB            STORE FOR CLOSE SVC                          
         MVI   OCDCB,X'80'         FLAG END OF LIST                             
         CLOSE ,MF=(E,OCDCB)                                                    
POPEN    ST    3,OCDCB             STORE DCB ADDRESS FOR THE OPEN SVC   XMN11250
         MVI   OCDCB,X'8F'         FLAG END OF PARAMETER LIST AND SET   XMN11260
*                                  FLAG INDICATING OPENING FOR OUTPUT   XMN11270
         SPACE 1                                                        XMN11280
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        XMN11290
         SPACE 1                                                        XMN11300
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFULL ?           XMN11310
         BZ    OUTSYNAD            NO, OUTPUT SYNAD ERROR               XMN11320
         SPACE 1                                                        XMN11330
PUTOPEN  DS    0H                                                       XMN11340
         PUT   (3)                 LOCATE MODE PUT                      XMN11350
         SPACE 1                                                        XMN11360
*********************************************************************** XMN11370
*                                                                     * XMN11380
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT OUTPUT BUFFER     * XMN11390
*        IS RETURNED IN  R1.                                          * XMN11400
*                                                                     * XMN11410
*********************************************************************** XMN11420
         SPACE 1                                                        XMN11430
         SR    15,15               CLEAR REGISTER 15                    XMN11440
         C     15,MOVEADR          IS THE STRING NULL (DESCRIPTOR = 0)  XMN11450
         BE    NULLPUT             YES, SO PUT OUT A BLANK RECORD       XMN11460
         IC    15,MOVEADR          LENGTH-1 OF THE STRING               XMN11470
         LA    14,1(15)            REAL LENGTH OF THE STRING            XMN11480
         LH    0,DCBLRECL          RECORD LENGTH OF THE FILE            XMN11490
         LTR   PARM2,PARM2         CHECK SUBCODE FOR OUTPUT(0)          XMN11500
         BNZ   PUT1                NOT OUTPUT(0)                        XMN11510
         LA    14,1(,14)           INCREASE REAL LENGTH BY ONE FOR      XMN11520
*                                  CARRIAGE CONTROL                     XMN11530
PUT1     SR    0,14                RECORD LENGTH - REAL LENGTH          XMN11540
         BM    TOOLONG             RECORD LENGTH < REAL LENGTH          XMN11550
         BZ    MATCH               RECORD LENGTH = REAL LENGTH          XMN11560
*                                  RECORD LENGTH > REAL LENGTH          XMN11570
         OI    FLAGS,SFILLBIT+LFILLBIT                                  XMN11580
*                                  INDICATE PADDING REQUIRED            XMN11590
         S     0,F1                RECORD LENGTH - REAL LENGTH - 1      XMN11600
         BP    LONGMOVE            RECORD LENGTH - REAL LENGTH > 1      XMN11610
         NI    FLAGS,ALLBITS-LFILLBIT                                   XMN11620
*                                  RECORD LENGTH - REAL LENGTH = 1      XMN11630
*                                  IS A SPECIAL CASE                    XMN11640
LONGMOVE ST    0,FILLENG           SAVE LENGTH FOR PADDING OPERATION    XMN11650
         B     MOVEIT              GO MOVE THE STRING                   XMN11660
         SPACE 1                                                        XMN11670
TOOLONG  LH    15,DCBLRECL         REPLACE THE STRING LENGTH            XMN11680
*                                  WITH THE RECORD LENGTH               XMN11690
         S     15,F1               RECORD LENGTH - 1 FOR THE MOVE       XMN11700
MATCH    NI    FLAGS,ALLBITS-SFILLBIT-LFILLBIT                          XMN11710
*                                  INDICATE NO PADDING REQUIRED         XMN11720
         SPACE 1                                                        XMN11730
MOVEIT   LTR   PARM2,PARM2         CHECK FOR OUTPUT(0)                  XMN11740
         BNZ   MOVEIT2             OUTPUT(0) IS A SPECIAL CASE          XMN11750
         MVI   0(1),C' '           PROVIDE BLANK CARRIAGE CONTROL       XMN11760
         LA    1,1(,1)             INCREMENT BUFFER POINTER             XMN11770
MOVEIT2  L     2,MOVEADR           STRING DESCRIPTOR                    XMN11780
         LA    2,0(,2)             ADDRESS PART ONLY                    XMN11790
         EX    15,MVCSTRNG         EXECUTE A MVC INSTRUCTION            XMN11800
         TM    FLAGS,SFILLBIT      IS PADDING REQUIRED ?                XMN11810
         BZ    EXIT                NO, RETURN TO THE XPL PROGRAM        XMN11820
         SPACE 1                                                        XMN11830
         AR    1,15                ADDRESS TO START PADDING - 1         XMN11840
         MVI   1(1),C' '           START THE PAD                        XMN11850
         TM    FLAGS,LFILLBIT      IS MORE PADDING REQUIRED ?           XMN11860
         BZ    EXIT                NO, RETURN TO XPL PROGRAM            XMN11870
         L     15,FILLENG          LENGTH OF PADDING NEEDED             XMN11880
         S     15,F1               LESS ONE FOR THE MOVE                XMN11890
         EX    15,MVCBLANK         EXECUTE MVC TO FILL IN BLANKS        XMN11900
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN11910
         SPACE 1                                                        XMN11920
*********************************************************************** XMN11930
*                                                                     * XMN11940
*        FOR A NULL STRING OUTPUT A BLANK RECORD                      * XMN11950
*                                                                     * XMN11960
*********************************************************************** XMN11970
         SPACE 1                                                        XMN11980
NULLPUT  LH    15,DCBLRECL         RECORD LENGTH                        XMN11990
         S     15,F2               LESS TWO FOR THE MOVES               XMN12000
         MVI   0(1),C' '           INITIAL BLANK                        XMN12010
         EX    15,MVCNULL          EXECUTE MVC TO FILL IN THE BLANKS    XMN12020
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN12030
         SPACE 1                                                        XMN12040
         DROP  3                                                        XMN12050
         SPACE 1                                                        XMN12060
*********************************************************************** XMN12070
*                                                                     * XMN12080
*        ROUTINE TO ABEND IN CASE OF AN INVALID SERVICE CODE          * XMN12090
*                                                                     * XMN12100
*********************************************************************** XMN12110
         SPACE 1                                                        XMN12120
BADPUT   STM   0,2,ABEREGS         SAVE REGISTERS                       XMN12130
         LA    1,PFABE             INVALID PUT SUBCODE                  XMN12140
         B     INERR               GO ABEND                             XMN12150
         EJECT                                                          XMN12160
         SPACE 5                                                        XMN12170
*********************************************************************** XMN12180
*                                                                     * XMN12190
*                                                                     * XMN12200
*                                                                     * XMN12210
*        READ ROUTINE FOR DIRECT ACCESS FILE I/O                      * XMN12220
*                                                                     * XMN12230
*                                                                     * XMN12240
*        INPUT TO THIS ROUTINE IS:                                    * XMN12250
*                                                                     * XMN12260
*      PARM1   CORE ADDRESS TO READ THE RECORD INTO                   * XMN12270
*                                                                     * XMN12280
*      SVCODE  SERVICE CODE INDICATING WHICH FILE TO USE              * XMN12290
*                                                                     * XMN12300
*      PARM2   RELATIVE RECORD NUMBER   0,1,2,3,...                   * XMN12310
*                                                                     * XMN12320
*                                                                     * XMN12330
*                                                                     * XMN12340
*********************************************************************** XMN12350
         SPACE 2                                                        XMN12360
READ     DS    0H                                                       XMN12370
         ST    PARM1,RDECB+12      STORE ADDRESS                        XMN12380
         L     3,ARWDCBS-FILEORG(SVCODE)                                XMN12390
*                                  ADDRESS OF THE DCB FOR THIS FILE     XMN12400
         USING IHADCB,3                                                 XMN12410
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   XMN12420
         BO    READOPEN            YES, GO READ                         XMN12430
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC       XMN12440
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST           XMN12450
*                                  AND INDICATE OPEN FOR INPUT          XMN12460
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        XMN12470
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFUL ?            XMN12480
         BZ    FILESYND            NO, SYNAD ERROR                      XMN12490
         SPACE 1                                                        XMN12500
READOPEN DS    0H                                                       XMN12510
         TM    DCBDEVT,TAPEBITS    IS THE FILE ON MAGNETIC TAPE         XMN12520
         DROP  3                                                        XMN12530
         BO    READTP              YES, GO FORM RECORD INDEX FOR TAPE   XMN12540
         SLA   PARM2,16            FORM  TTRZ  ADDRESS                  XMN12550
         BNZ   RDN0                BLOCK ZERO IS A SPECIAL CASE         XMN12560
         LA    PARM2,1             FUNNY ADDRESS FOR BLOCK ZERO         XMN12570
         B     READTP              GO DO THE READ                       XMN12580
RDN0     O     PARM2,TTRSET        SPECIFY LOGICAL RECORD 1             XMN12590
READTP   ST    PARM2,TTR           SAVE RECORD POINTER                  XMN12600
         SPACE 1                                                        XMN12610
         POINT (3),TTR             POINT AT THE RECORD TO BE READ       XMN12620
         READ  RDECB,SF,(3),0,'S'  READ THE RECORD INTO CORE            XMN12630
         CHECK RDECB               WAIT FOR THE READ TO COMPLETE        XMN12640
         SPACE 1                                                        XMN12650
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN12660
         EJECT                                                          XMN12670
         SPACE 5                                                        XMN12680
*********************************************************************** XMN12690
*                                                                     * XMN12700
*                                                                     * XMN12710
*                                                                     * XMN12720
*        WRITE ROUTINE FOR DIRECT ACCESS FILE I/O                     * XMN12730
*                                                                     * XMN12740
*                                                                     * XMN12750
*        INPUT TO THIS ROUTINE IS:                                    * XMN12760
*                                                                     * XMN12770
*      PARM1   CORE ADDRESS TO READ THE RECORD FROM                   * XMN12780
*                                                                     * XMN12790
*      SVCODE  SERVICE CODE INDICATING WHICH FILE TO USE              * XMN12800
*                                                                     * XMN12810
*      PARM2   RELATIVE RECORD NUMBER   0,1,2, ...                    * XMN12820
*                                                                     * XMN12830
*                                                                     * XMN12840
*                                                                     * XMN12850
*********************************************************************** XMN12860
         SPACE 2                                                        XMN12870
WRITE    DS    0H                                                       XMN12880
         ST    PARM1,WDECB+12      SAVE CORE ADDRESS                    XMN12890
         L     3,ARWDCBS-FILEORG(SVCODE)                                XMN12900
*                                  GET THE DCB ADDRESS                  XMN12910
         USING IHADCB,3                                                 XMN12920
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   XMN12930
         BO    WRTOPEN             YES, GO WRITE                        XMN12940
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC       XMN12950
         MVI   OCDCB,X'8F'         FLAG END OF ARGUMENT LIST AND        XMN12960
*                                  INDICATE OPENING FOR OUTPUT          XMN12970
         SPACE 1                                                        XMN12980
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        XMN12990
         SPACE 1                                                        XMN13000
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFUL ?            XMN13010
         BZ    FILESYND            NO,SYNAD ERROR                       XMN13020
         SPACE 1                                                        XMN13030
WRTOPEN  DS    0H                                                       XMN13040
         TM    DCBDEVT,TAPEBITS    IS THE FILE ON MAGNETIC TAPE         XMN13050
         DROP  3                                                        XMN13060
         BO    WRITP               YES, GO FORM RECORD INDEX FOR TAPE   XMN13070
         SLA   PARM2,16            FORM TTRZ ADDRESS FOR DIRECT ACCESS  XMN13080
         BNZ   WRDN0               RECORD ZERO IS A SPECIAL CASE        XMN13090
         LA    PARM2,1             FUNNY ADDRESS FOR RECORD ZERO        XMN13100
         B     WRITP               GO DO THE WRITE                      XMN13110
WRDN0    O     PARM2,TTRSET        OR IN RECORD NUMBER BIT              XMN13120
WRITP    ST    PARM2,TTR           SAVE RECORD POINTER                  XMN13130
         SPACE 1                                                        XMN13140
         POINT (3),TTR             POINT AT THE DESIRED RECORD          XMN13150
         WRITE WDECB,SF,(3),0,'S'  WRITE THE RECORD OUT                 XMN13160
         CHECK WDECB               WAIT FOR THE WRITE TO FINISH         XMN13170
         SPACE 1                                                        XMN13180
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN13190
         EJECT                                                          XMN13200
         SPACE 5                                                        XMN13210
*********************************************************************** XMN13660
*                                                                     * XMN13670
*                                                                     * XMN13680
*                                                                     * XMN13690
*        TIME AND DATE FUNCTIONS                                      * XMN13700
*                                                                     * XMN13710
*                                                                     * XMN13720
*        RETURNS TIME OF DAY IN HUNDREDTHS OF A SECOND IN REGISTER    * XMN13730
*        PARM1  AND THE DATE IN THE FORM  YYDDD IN REGISTER SVCODE    * XMN13740
*                                                                     * XMN13750
*                                                                     * XMN13760
*********************************************************************** XMN13770
         SPACE 2                                                        XMN13780
GETIME   TIME  BIN                 REQUEST THE TIME                     XMN13790
         ST    0,SAVREG+PARM1*4    RETURN IN REGISTER PARM1             XMN13800
         ST    1,DTSV+4            STORE THE DATE IN PACKED DECIMAL     XMN13810
         CVB   1,DTSV              CONVERT IT TO BINARY                 XMN13820
         ST    1,SAVREG+SVCODE*4   RETURN DATE IN REGISTER SVCODE       XMN13830
         B     EXIT                RETURN TO THE XPL PROGRAM            XMN13840
         EJECT                                                                  
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        REWIND SEQUENTIAL FILES                                      *         
*                                                                     *         
*                                                                     *         
*        INPUT TO THIS ROUTINE:                                       *         
*                                                                     *         
*      PARM1 = 0   => INPUT FILE                                      *         
*            = 1   => OUTPUT FILE                                     *         
*                                                                     *         
*      PARM2       SUBCODE DENOTING FILE NUMBER I OF                  *         
*                  INPUT(I) OR OUTPUT(I), I = 0,1,2,...               *         
*                                                                     *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
REWIND   DS    0H                  REWIND A SEQUENTIAL FILE                     
         SLL   PARM2,2             SUBCODE*4                                    
         LTR   PARM1,PARM1         INPUT FILE?                                  
         BZ    INFILE              YES - SO BRANCH                              
         L     3,PUTDCBS(PARM2)    ADDRESS OF OUTPUT FILE DCB                   
         B     CLOSE                                                            
INFILE   L     3,GETDCBS(PARM2)    ADDRESS OF INPUT FILE DCB                    
         USING IHADCB,3                                                         
CLOSE    TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN?                            
         BZ    BUFFREE             NO, GO FREE ITS BUFFER SPACE                 
         ST    3,OCDCB             STORE DCB ADDRESS FOR CLOSE SVC              
         MVI   OCDCB,X'80'         FLAG END OF LIST                             
         CLOSE ,MF=(E,OCDCB)       CLOSE THE SEQUENTIAL FILE                    
BUFFREE  TM    DCBBUFCB+3,1        BUFFERS ALLOCATED?                           
         BO    EXIT                NO, RETURN TO THE XPL PROGRAM                
      FREEPOOL (3)                 RELEASE BUFFERS                              
         DROP  3                                                                
         B     EXIT                RETURN TO THE XPL PROGRAM                    
         EJECT                                                                  
***********************************************************************         
*                                                                     *         
*                                                                     *         
*                                                                     *         
*        CLOCK_TRAP                                                   *         
*                                                                     *         
*                                                                     *         
*        INPUT TO THIS ROUTINE:                                       *         
*                                                                     *         
*      PARM1 = 0        START THE CPU TIMER.                          *         
*            > 0        RETURN ELAPSED TIME IN 0.01 SECOND UNITS.     *         
*            < 0        CANCEL CPU TIMER AND RETURN ELAPSED TIME IN   *         
*                       0.01 SECOND UNITS.                            *         
*                                                                     *         
*      PARM2            USED ONLY IF PARM1 = 0;   THE ADDRESS OF AN   *         
*                       8-BYTE FULLWORD-ALLIGNED CORE AREA            *         
*                       CONTAINING:                                   *         
*                       BYTES 0 - 3    INITIAL TIMER VALUE IN .01 SEC *         
*                       BYTES 4 - 7    ADDRESS OF TIMER COMPLETION    *         
*                                      ROUTINE;  IF ZERO THEN NO      *         
*                                      ACTION IS TAKEN ON TIMER       *         
*                                      COMPLETION.                    *         
*                                                                     *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
CPUTIMER DS 0H                                                                  
         LTR   PARM1,PARM1        IS PARM1 ZERO?                                
         BP    LAPSE              NO, GO RETURN ELAPSED TIME.                   
         BM    STOPCLOC           NO, GO TO TIMER CANCEL ROUTINE.               
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        MOVE INFORMATION POINTED TO BY PARM2 INTO THE SUBMONITOR.    *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
         MVC   TIMEST(4),0(PARM2) INITIAL TIMER VALUE.                          
         MVC   TIMETRAP(4),4(PARM2) ADDR. OF XPL TIMEOUT ROUTINE                
         NC    TIMETRAP,TIMETRAP  IS TIMETRAP ZERO?                             
         BZ    NOTRAP             YES, SO NO TIMER COMPLETION ROUTINE.          
         STM   4,11,SAVREG+4*4    NO, SO PREPARE BY PLANTING XPL GPRS.          
*        SET THE ALARM AND START THE CLOCK TICKING:                             
        STIMER TASK,TIMEOUT,BINTVL=TIMEST                                       
         L     1,16               CVT ADDR FROM ABSOLUTE LOCATION 16            
         L     1,0(,1)            TCB ADDRESS POINTER FROM CVT                  
         L     1,4(,1)            ADDRESS OF CURRENT TCB                        
         L     1,120(,1)          TQE ADDR FROM TCB                             
         LA    1,28(,1)           ADDRESS OF RB LINK IN TQE                     
         ST    1,INTLOC           PLANT FOR INTERRUPT                           
         SPACE                                                                  
         B     EXIT               RETURN TO THE XPL PROGRAM.                    
         SPACE                                                                  
*        START THE CLOCK TICKING, BUT DO NOT SET THE ALARM.                     
NOTRAP  STIMER TASK,BINTVL=TIMEST                                               
         B     EXIT               RETURN TO THE XPL PROGRAM.                    
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        RETURN ELAPSED CPU TIME.  DO NOT STOP CPU TIMER.             *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
LAPSE    TTIMER                                                                 
         B     ELAPSED            GO RETURN ELAPSED TIME.                       
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        CANCEL CPU TIMER AND RETURN ELAPSED INTERVAL.                *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
STOPCLOC TTIMER CANCEL RETURNS # OF CLOCK TICKS (26.04166 USEC) IN GPR0         
ELAPSED  SRDL  0,32               CONVERT TO UNITS OF 0.01 SECONDS.             
         LA    2,384              (CONVERSION FACTOR)                           
         DR    0,2                                                              
*        SUBTRACT WHAT'S LEFT FROM ORIGINAL TIMER ESTIMATE                      
         L     2,TIMEST           ORIGINAL TIMER ESTIMATE                       
         SR    2,1                ELAPSED TIME                                  
         ST    2,SAVREG+4*PARM1   RETURN ELAPSED TIME IN REGISTER PARM1         
         B     EXIT               RETURN TO THE XPL PROGRAM.                    
         SPACE 2                                                                
***********************************************************************         
*                                                                     *         
*        BRANCH TO THE XPL TIMER COMPLETION ROUTINE                   *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
TIMEOUT  DS    0H                 SYSTEM ENTERS HERE.                           
         DROP  13                                                               
         USING TIMEOUT,SELF                                                     
         SAVE  (14,12)            SAVE REGISTERS                                
         ST    13,TIMESAVE        STORE ADDR OF SYSTEM SAVE AREA.               
         L     13,ASAVE                                                         
         DROP  SELF                                                             
         USING SAVE,13                                                          
*        WE RETURN THE ADDRESS OF THE INTERRUPTED INSTRUCTION IN GPR3.          
         L     3,INTLOC           ADDRESS OF RB LINK                            
         L     3,0(,3)            ADDRESS OF PRB                                
         L     3,20(,3)           WORD2 OF OLD PSW AT INTERRUPT                 
         LA    3,0(,3)            CLEAR THE HIGH ORDER BYTE.                    
         MVC   SAVREG+CBR*4(4),TIMETRAP PLANT ADDRESS OF TIMEOUT RTN.           
         LM    4,15,SAVREG+4*4    RESTORE THE XPL REGISTERS.                    
         DROP  13                                                               
         USING ENTRY,SELF                                                       
         BALR  CBR,CBR            CALL USER'S ROUTINE.                          
         L     13,TIMESAVE        RESTORE REGISTERS & RETURN TO SYSTEM.         
        RETURN (14,12),T,RC=0                                                   
         DROP  SELF                                                             
         USING SAVE,13                                                          
         EJECT                                                          XMN13850
         SPACE 5                                                        XMN13860
*********************************************************************** XMN14180
*                                                                     * XMN14190
*                                                                     * XMN14200
*                                                                     * XMN14210
*        DATA AREA FOR THE SUBMONITOR                                 * XMN14220
*                                                                     * XMN14230
*                                                                     * XMN14240
*********************************************************************** XMN14250
         SPACE 2                                                        XMN14260
         DS    0F                                                       XMN14270
ASAVE    DC    A(SAVE)             ADDRESS OF OS SAVE AREA              XMN14280
ABASE1   DC    A(BASE1)            BASE ADDRESS FOR INITIALIZATION      XMN14290
MAXCODE  DC    A(ENDSERV-4)        LARGEST VALID SERVICE CODE           XMN14300
RTNSV    DC    F'0'                SAVE COMPLETION CODE RETURNED        XMN14320
*                                  BY THE XPL PROGRAM                   XMN14330
ABESAVE  DS    F                   SAVE ABEND CODE DURING CLOSE         XMN14340
ABEREGS  DS    3F                  SAVE PROGRAMS REGS 0-2 BEFORE ABEND  XMN14350
TTR      DC    F'0'                TTRZ ADDRESS FOR READ AND WRITE      XMN14360
TTRSET   DC    X'00000100'         ADDRESS CONSTANT FOR TTRZ            XMN14370
FLAGS    DC    X'00'               SUBMONITOR CONTROL FLAGS             XMN14380
SAVREG   DC    16F'0'              SAVE AREA FOR THE SUBMONITOR         XMN14390
         DS    0D                                                       XMN14400
DTSV     DC    PL8'0'              WORK AREA FOR CONVERTING DATE        XMN14410
TIMEST   DS    F                  HOLDS INTERVAL VALUE FOR CPU TIMER            
TIMETRAP DS    F                  ADDRESS OF XPL TIMEOUT ROUTINE.               
INTLOC   DS F                     ADDR OF WORD2 OF OPSW IF TIMER       *        
                                  INTERRUPT OCCURS.                             
TIMESAVE DS F                     SAVES ADDR OF SYSTEM SAVE AREA FOR   *        
                                  ASYNCHRONOUS TIMER EXIT ROUTINE.              
EOFCHARS DC    CL4'%EOF'           SENTINEL SIMULATING ENDFILE IN SYSIN         
         SPACE 2                                                        XMN14490
*********************************************************************** XMN14500
*                                                                     * XMN14510
*                                                                     * XMN14520
*        DCB ADDRESS TABLE FOR ALL I/O ROUTINES                       * XMN14530
*                                                                     * XMN14540
*                                                                     * XMN14550
*        THE FOUR SETS OF DCB ADDRESSES HEADED BY  'GETDCBS',         * XMN14560
*        'PUTDCBS', 'ARWDCBS', AND 'PGMDCB' MUST BE CONTIGUOUS        * XMN14570
*        AND END WITH 'PGMDCB'.  THESE LISTS ARE USED AT JOB END      * XMN14580
*        TO CLOSE ALL FILES BEFORE RETURNING TO OS                    * XMN14590
*                                                                     * XMN14600
*                                                                     * XMN14610
*        DCB ADDRESSES FOR INPUT FILES:                               * XMN14620
*                                                                     * XMN14630
*                                                                     * XMN14640
*********************************************************************** XMN14650
         SPACE 2                                                        XMN14660
         PRINT NOGEN                                                    XMN14670
         SPACE 1                                                        XMN14680
GETDCBS  DS    0F                                                       XMN14690
&I       SETA  0                                                        XMN14700
.GD1     AIF   (&I GT &INPUTS).GD2                                      XMN14710
         DC    A(INPUT&I)                                               XMN14720
&I       SETA  &I+1                                                     XMN14730
         AGO   .GD1                                                     XMN14740
.GD2     ANOP                                                           XMN14750
         SPACE 1                                                        XMN14760
*********************************************************************** XMN14770
*                                                                     * XMN14780
*        DCB ADDRESSES FOR OUTPUT FILES                               * XMN14790
*                                                                     * XMN14800
*********************************************************************** XMN14810
         SPACE 1                                                        XMN14820
PUTDCBS  DS    0F                                                       XMN14830
         SPACE 1                                                        XMN14840
&I       SETA  0                                                        XMN14850
.PD1     AIF   (&I GT &OUTPUTS).PD2                                     XMN14860
         DC    A(OUTPUT&I)                                              XMN14870
&I       SETA  &I+1                                                     XMN14880
         AGO   .PD1                                                     XMN14890
.PD2     ANOP                                                           XMN14900
         SPACE 1                                                        XMN14910
*********************************************************************** XMN14920
*                                                                     * XMN14930
*        DCB ADDRESS FOR DIRECT ACCESS FILES                          * XMN14940
*                                                                     * XMN14950
*********************************************************************** XMN14960
         SPACE 1                                                        XMN14970
ARWDCBS  DS    0F                                                       XMN14980
         SPACE 1                                                        XMN14990
&I       SETA  1                                                        XMN15000
.DA1     AIF   (&I GT &FILES).DA2                                       XMN15010
         ORG   ARWDCBS+RD&I-FILEORG                                     XMN15020
         DC    A(FILE&I.IN)                                             XMN15030
         ORG   ARWDCBS+WRT&I-FILEORG                                    XMN15040
         DC    A(FILE&I.OUT)                                            XMN15050
&I       SETA  &I+1                                                     XMN15060
         AGO   .DA1                                                     XMN15070
.DA2     ANOP                                                           XMN15080
         ORG   ARWDCBS+ENDSERV-FILEORG                                  XMN15090
         DS    0F                                                       XMN15100
         SPACE 2                                                        XMN15110
PGMDCB   DC    X'80'               FLAG END OF PARAMETER LIST           XMN15120
         DC    AL3(PROGRAM)        ADDRESS OF PROGRAM DCB               XMN15130
         SPACE 2                                                        XMN15140
OCDCB    DS    F                   DCB ADDRESSES FOR OPEN AND CLOSE     XMN15150
MOVEADR  DS    1F                  DESCRIPTOR STORAGE FOR PUT ROUTINE   XMN15160
FILLENG  DC    F'0'                LENGTH OF PADDING NEEDED IN OUTPUT   XMN15170
F1       DC    F'1'                THE CONSTANT ONE                     XMN15180
F2       DC    F'2'                THE CONSTANT TWO                     XMN15190
GETMOVE  MVC   0(0,2),0(1)         MVC COMMAND FOR THE GET ROUTINE      XMN15200
MVCNULL  MVC   1(0,1),0(1)         MVC COMMAND FOR THE PUT ROUTINE      XMN15210
MVCBLANK MVC   2(0,1),1(1)             "                                XMN15220
MVCSTRNG MVC   0(0,1),0(2)             "                                XMN15230
         EJECT                                                          XMN15380
         SPACE 5                                                        XMN15390
*********************************************************************** XMN15400
*                                                                     * XMN15410
*                                                                     * XMN15420
*                                                                     * XMN15430
*        DEVICE  CONTROL  BLOCKS  FOR  THE  SUBMONITOR                * XMN15440
*                                                                     * XMN15450
*                                                                     * XMN15460
*********************************************************************** XMN15470
         SPACE 2                                                        XMN15480
PROGRAM  DCB   DSORG=PS,                                               XXMN15490
               MACRF=R,                                                XXMN15500
               DDNAME=PASS1,                                           X        
               DEVD=DA,                                                XXMN15520
               KEYLEN=0,                                               XXMN15530
               EODAD=EODPGM,                                           XXMN15540
               SYNAD=ERRPGM                                             XMN15550
         SPACE 2                                                        XMN15560
INPUT0   DCB   DSORG=PS,                                               XXMN15570
               DDNAME=SYSIN,                                           XXMN15580
               DEVD=DA,                                                XXMN15590
               MACRF=GL,                                               XXMN15600
               BUFNO=3,                                                XXMN15610
               EODAD=INEOD,                                            XXMN15620
               SYNAD=INSYNAD,                                          XXMN15630
               EXLST=INEXIT0,                                          XXMN15640
               EROPT=ACC                                                XMN15650
         SPACE 1                                                        XMN15660
*********************************************************************** XMN15670
*                                                                     * XMN15680
INPUT1   EQU   INPUT0              INPUT(0) & INPUT(1) ARE BOTH SYSIN * XMN15690
*                                                                     * XMN15700
*********************************************************************** XMN15710
         SPACE 2                                                        XMN15720
&I       SETA  2                                                        XMN15730
&J       SETA  1                                                                
.INP1    AIF   (&I GT &INPUTS).INP2                                     XMN15740
         SPACE 1                                                        XMN15750
INPUT&I  DCB   DSORG=PS,                                               XXMN15760
               DDNAME=SYSUT&J,                                         X        
               DEVD=DA,                                                XXMN15780
               MACRF=GL,                                               XXMN15790
               EODAD=INEOD,                                            XXMN15800
               SYNAD=INSYNAD,                                          XXMN15810
               EXLST=INEXIT&I,                                         XXMN15820
               EROPT=ACC                                                XMN15830
         SPACE 1                                                        XMN15840
&I       SETA  &I+1                                                     XMN15850
&J       SETA  &J+1                                                             
         AGO   .INP1                                                    XMN15860
.INP2    ANOP                                                           XMN15870
         SPACE 2                                                        XMN15880
OUTPUT0  DCB   DSORG=PS,                                               XXMN15890
               DDNAME=SYSPRINT,                                        XXMN15900
               DEVD=DA,                                                XXMN15910
               MACRF=PL,                                               XXMN15920
               SYNAD=OUTSYNAD,                                         XXMN15930
               EXLST=OUTEXIT0,                                         XXMN15940
               EROPT=ACC                                                XMN15950
         SPACE 1                                                        XMN15960
*********************************************************************** XMN15970
*                                                                     * XMN15980
OUTPUT1  EQU   OUTPUT0             OUTPUT(0), OUTPUT(1) BOTH SYSPRINT * XMN15990
*                                                                     * XMN16000
*********************************************************************** XMN16010
         SPACE 2                                                        XMN16020
OUTPUT2  DCB   DSORG=PS,                                               XXMN16030
               DDNAME=SYSPUNCH,                                        XXMN16040
               DEVD=DA,                                                XXMN16050
               MACRF=PL,                                               XXMN16060
               SYNAD=OUTSYNAD,                                         XXMN16070
               EXLST=OUTEXIT2,                                         XXMN16080
               EROPT=ACC                                                XMN16090
         SPACE 1                                                        XMN16100
&I       SETA  3                                                        XMN16110
&J       SETA  1                                                                
.OP1     AIF   (&I GT &OUTPUTS).OP2                                     XMN16120
         SPACE 1                                                        XMN16130
OUTPUT&I DCB   DSORG=PS,                                               XXMN16140
               DDNAME=SYSUT&J,                                         X        
               DEVD=DA,                                                XXMN16160
               MACRF=PL,                                               XXMN16170
               SYNAD=OUTSYNAD,                                         XXMN16180
               EXLST=OUTEXIT&I,                                        XXMN16190
               EROPT=ACC                                                XMN16200
         SPACE 1                                                        XMN16210
&I       SETA  &I+1                                                     XMN16220
&J       SETA  &J+1                                                             
         AGO   .OP1                                                     XMN16230
.OP2     ANOP                                                           XMN16240
         SPACE 1                                                        XMN16250
*********************************************************************** XMN16260
*                                                                     * XMN16270
*                                                                     * XMN16280
*        DCBS FOR THE DIRECT ACCESS FILES                             * XMN16290
*                                                                     * XMN16300
*                                                                     * XMN16310
*        BECAUSE OF THE MANNER IN WHICH THE FILES ARE USED,  IT IS    * XMN16320
*        NECESSARY TO HAVE TWO DCB'S FOR EACH FILE.  ONE DCB FOR      * XMN16330
*        READING AND ONE FOR WRITING.                                 * XMN16340
*                                                                     * XMN16350
*                                                                     * XMN16360
*********************************************************************** XMN16370
         SPACE 2                                                        XMN16380
&I       SETA  1                                                        XMN16390
.DD1     AIF   (&I GT &FILES).DD2                                       XMN16400
         SPACE 1                                                        XMN16410
FILE&I.IN DCB  DSORG=PS,                                               XXMN16420
               MACRF=RP,                                               XXMN16430
               DDNAME=FILE&I,                                          XXMN16440
               DEVD=DA,                                                XXMN16450
               RECFM=F,                                                XXMN16460
               LRECL=FILEBYTS,                                         XXMN16470
               BLKSIZE=FILEBYTS,                                       XXMN16480
               KEYLEN=0,                                               XXMN16490
               EODAD=FILEEOD,                                          XXMN16500
               SYNAD=FILESYND                                           XMN16510
         SPACE 2                                                        XMN16520
FILE&I.OUT DCB DSORG=PS,                                               XXMN16530
               MACRF=WP,                                               XXMN16540
               DDNAME=FILE&I,                                          XXMN16550
               DEVD=DA,                                                XXMN16560
               RECFM=F,                                                XXMN16570
               KEYLEN=0,                                               XXMN16580
               LRECL=FILEBYTS,                                         XXMN16590
               BLKSIZE=FILEBYTS,                                       XXMN16600
               SYNAD=FILESYND                                           XMN16610
         SPACE 1                                                        XMN16620
&I       SETA  &I+1                                                     XMN16630
         AGO   .DD1                                                     XMN16640
.DD2     ANOP                                                           XMN16650
         SPACE 4                                                        XMN16660
XPLSMEND DS    0H                  END  OF  THE  SUBMONITOR             XMN16670
         EJECT                                                          XMN16680
         SPACE 5                                                        XMN16690
*********************************************************************** XMN16700
*                                                                     * XMN16710
*                                                                     * XMN16720
*                                                                     * XMN16730
*        DSECT WHICH DEFINES THE FORMAT OF BINARY PROGRAM CONTROL     * XMN16740
*        INFORMATION AND THE STARTING POINT FOR PROGRAMS              * XMN16750
*                                                                     * XMN16760
*                                                                     * XMN16770
*********************************************************************** XMN16780
         SPACE 2                                                        XMN16790
FILECTRL DSECT                                                          XMN16800
         SPACE 1                                                        XMN16810
BYTSCODE DS    1F                  NUMBER OF BYTES OF CODE              XMN16820
         SPACE 1                                                        XMN16830
BYTSDATA DS    1F                  NUMBER OF BYTES OF DATA AREA         XMN16840
         SPACE 1                                                        XMN16850
BLKSCODE DS    1F                  NUMBER OF RECORDS OF CODE            XMN16860
         SPACE 1                                                        XMN16870
BLKSDATA DS    1F                  NUMBER OF RECORDS OF DATA AREA       XMN16880
         SPACE 1                                                        XMN16890
BYTSBLK  DS    1F                  BLOCKSIZE OF THE XPL PROGRAM FILE    XMN16900
         SPACE 1                                                        XMN16910
BYTSFULL DS    1F                  NUMBER OF BYTES OF CODE ACTUALLY     XMN16920
*                                  USED IN THE LAST RECORD OF CODE      XMN16930
         SPACE 1                                                        XMN16940
DATABYTS DS    1F                  NUMBER OF BYTES OF DATA ACTUALLY     XMN16950
*                                  USED IN THE LAST RECORD OF DATA      XMN16960
         SPACE 1                                                        XMN16970
         ORG   FILECTRL+60         REMAINDER OF THE CONTROL BLOCK       XMN16980
*                                  IS UNUSED                            XMN16990
         SPACE 1                                                        XMN17000
CODEBEGN DS    0H                  FIRST EXECUTABLE INSTRUCTION         XMN17010
*                                  IN THE XPL PROGRAM                   XMN17020
         EJECT                                                                  
         SPACE 5                                                                
***********************************************************************         
*                                                                     *         
*        DSECT WHICH DEFINES THE BLOCK OF STATUS INFORMATION RETURNED *         
*        BY THE PASCAL RUN MONITOR VIA MONITOR_LINK(3).               *         
*                                                                     *         
***********************************************************************         
         SPACE 2                                                                
STATUS   DSECT                                                                  
ARBASE   DS    F                   ADDRESS OF GLOBAL ACTIVATION RECORD.         
ORGORGN  DS    F                   ADDRESS OF THE ORG SEGMENT.                  
ORGTV    DS    F                   ADDRESS OF TRANSFER VECTOR.                  
CODEPNT  DS    F                   ADDRESS OF PASCAL CODE SEGMENT.              
EXECTIME DS    F                   EXECUTION TIME OF PASCAL PROGRAM.            
ERRLINE  DS    F                   SOURCE LINE OF RUN ERROR, IF ANY.            
COREEND  DS    F                   END OF PASCAL REGION.                        
         EJECT                                                          XMN17030
         SPACE 5                                                        XMN17040
*********************************************************************** XMN17050
*                                                                     * XMN17060
*                                                                     * XMN17070
*        DUMMY  DCB  FOR  DEFINING  DCB  FIELDS                       * XMN17080
*                                                                     * XMN17090
*                                                                     * XMN17100
*********************************************************************** XMN17110
         SPACE 2                                                        XMN17120
         DCBD  DSORG=QS,DEVD=DA                                         XMN17130
         EJECT                                                          XMN17140
         SPACE 5                                                        XMN17150
*********************************************************************** XMN17160
*                                                                     * XMN17170
*                                                                     * XMN17180
*        THE  END                                                     * XMN17190
*                                                                     * XMN17200
*                                                                     * XMN17210
*********************************************************************** XMN17220
         SPACE 5                                                        XMN17230
         END PASCAL1                                                            
