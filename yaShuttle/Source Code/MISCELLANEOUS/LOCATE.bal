*                                                                       00010002
* LOCATE:  VERS 2.0     CRAIG W. SCHULENBERG     10/30/92               00020005
*                         -- USE FULLWORD ADD FOR LOCATE COUNTER        00030002
*                              MAINTENANCE                              00040002
*                         -- CHANGE MASK TO '7FFFFFFF'                  00050002
*                         -- RESET PAGING AREA COUNTERS WHEN LOCCNT     00050106
*                              ROLLS OVER                               00050206
*                         -- PREVIOUS CHANGES (SINCE 1977 VERSION)      00051004
*                            1) FIX FOR DR63474 (LOCCNT)                00052004
*                                                                       00060002
*DR63474 FIX: ASSIGN '00FFFFFF' TO R3 BEFORE ENTERING REPEAT LOOP       00070002
*  TO PREVENT 4001 ABEND WHEN LOCCNT ROLLS OVER TO 0.   HFG 9/3/86      00080002
*                                                                       00090002
         TITLE 'LOCATE  -  SDFPKG PAGING LOGIC'                         00100000
LOCATE   CSECT                                                          00110000
*     UPON ENTRY, REGISTER 1 CONTAINS A VIRTUAL MEMORY POINTER.  THE    00120000
*        HIGH ORDER HALFWORD CONTAINS A PAGE NUMBER, AND THE LOW ORDER  00130000
*        HALFWORD CONTAINS AN OFFSET.  LOCATE RETURNS THE CORRESPONDING 00140000
*        CORE ADDRESS IN REGISTER 1, AND THE ADDRESS OF THE ASSOCIATED  00150000
*        PAGING AREA DIRECTORY ENTRY IN REGISTER 0.                     00160000
*                                                                       00170000
         ENTRY COMMDATA                                                 00180000
         USING *,15                                                     00190002
         B     *+12                                                     00200002
         DC    CL8'LOCATE  '                                            00210002
         BALR  15,0                                                     00220002
         DROP  15                                                       00230002
         OSSAVE                                                         00240000
         STH   R1,OFFSET      SAVE THE OFFSET PORTION OF THE INPUT PTR  00250000
         LH    R11,RETARG1    R11 = PAGE #                              00260000
         LR    R12,R11                                                  00270000
         SLL   R12,3          R12 = PAGE # * 8                          00280000
         LM    R6,R8,COMMDATA                                           00290000
         A     R6,=F'1'       R6 = NEW LOCATE COUNT                     00300007
*                                                                       00301007
* DETECT AN OVERFLOW CONDITION THAT WOULD CAUSE R6 TO GO NEGATIVE       00302007
*                                                                       00303007
         BP    COUNTOK        WE ARE OK IF THE COUNTER > 0              00304007
         LA    R6,1           RESET LOCCNT TO A VALUE OF 1              00304107
         LH    R15,NUMOFPGS   SET R15 TO NUMBER OF PAD ENTRIES          00304207
         L     R2,PADADDR     GET ADDRESS OF PAGING AREA DIRECTORY      00304307
         USING PDENTRY,R2                                               00304408
         SR    R3,R3          MAKE R3 ZERO FOR STORES TO FOLLOW         00304507
         SR    R4,R4          USE R4 TO INDEX THROUGH THE PAD           00304608
CHEKNEXT EQU   *                                                        00304707
         ST    R3,USECOUNT(R4) ZERO THE PAD ENTRY LOCATE COUNTER        00304808
         LA    R4,PDENTLEN(R4) ADVANCE TO THE NEXT PAD ENTRY            00304908
         BCT   R15,CHEKNEXT                                             00305007
COUNTOK  EQU   *                                                        00306007
         DROP  R2                                                       00307008
         USING FCBCELL,R8                                               00310000
         LTR   R11,R11                                                  00320000
         BM    ABEND2                                                   00330000
         CH    R11,LSTPAGE                                              00340000
         BH    ABEND2                                                   00350000
         LH    R1,OFFSET                                                00360000
         LTR   R1,R1                                                    00370000
         BM    ABEND2                                                   00380000
         CH    R1,=H'1679'                                              00390000
         BH    ABEND2                                                   00400000
         L     R10,FCBPDADR(R12)                                        00410000
         LTR   R10,R10        IS THE DESIRED PAGE IN CORE?              00420000
         BNZ   INCORE                                                   00430000
         ST    R7,FCBPDADR(R12)                                         00440000
         LR    R10,R7         CURRENT PAD SLOT IS FORMER VULN SLOT      00450000
         USING PDENTRY,R10                                              00460000
         CLI   IOFLAG,0       IS THERE A WRITE IN PROGRESS?             00470000
         BE    NOCHECK1                                                 00480000
         CHECK DECB          WAIT FOR ITS COMPLETION                    00490000
NOCHECK1 L     R5,FCBTTRZ(R12)                                          00500000
         DROP  R8                                                       00510000
         ST    R5,TTRWORD     SAVE THE REQUISITE TTR FOR POINT          00520000
         L     R5,DCBADDR     GET THE ADDRESS OF OUR DCB                00530000
         POINT (R5),TTRWORD                                             00540000
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR READ                    00550000
         READ  DECB,SF,MF=E                                             00560000
         MVI   IOFLAG,1       INDICATE A READ IS IN PROGRESS            00570000
         L     R1,READS                                                 00580002
         A     R1,=F'1'                                                 00590002
         ST    R1,READS                                                 00600002
         L     R1,FCBADDR     R1 = FCB ADDR OF PAGE TO BE OVERWRITTEN   00610000
         LTR   R1,R1          IS THIS PAGE ACTUALLY IN USE?             00620000
         BZ    NOUPDAT        BYPASS FCB UPDATE IF THIS IS THE CASE     00630000
         USING FCBCELL,R1                                               00640000
         LH    R2,PAGENO      GET THE PAGE NUMBER (* 8)                 00650000
         SR    R0,R0                                                    00660000
         ST    R0,FCBPDADR(R2)                                          00670000
         DROP  R1                                                       00680000
NOUPDAT  ST    R8,FCBADDR                                               00690000
         STH   R12,PAGENO                                               00700000
COMMON   L     R2,PADADDR    * SEARCH PAD FOR NEW AVULN ENTRY           00710000
         DROP  R10                                                      00720000
         USING PDENTRY,R2                                               00730000
         LR    R0,R10                                                   00740000
         SR    R0,R2           * R0 = OFFSET OF OLD AVULN ENTRY         00750000
         L     R3,=X'7FFFFFFF' * INITIAL USECOUNT FOR LOOP              00760000
         SR    R4,R4           * R4 = OFFSET INTO PAD                   00770000
         SR    R5,R5           * R5 = 0, MEANS NOT RESERVED             00780000
         SR    R14,R14         * R14 IS NON-ZERO IF NEW AVULN FOUND     00790000
         LH    R15,NUMOFPGS                                             00800000
REPEAT   L     R7,FCBADDR(R4)  * LOOP FOR R15 = NUMOFPGS TO 0           00810007
         LTR   R7,R7           * IS THIS PAGE IN USE?                   00820007
         BNZ   INUSE           * IF PAGE IS EMPTY                       00830000
         LR    R1,R4           * THEN R1 = OFFSET OF PAGE               00840000
         LR    R14,R2          *      SET R14 FLAG                      00850000
         B     SLOTFND         *      GO TO SLOT FOUND                  00860000
INUSE    CR    R4,R0           * ELSE IF OFFSET R4 /= OFFSET OF AVULN   00870000
         BE    NEXTONE                                                  00880000
         CH    R5,RESVCNT(R4)  * THEN IF ENTRY AT R4 IS NOT RESERVED    00890000
         BNE   NEXTONE                                                  00900000
         C     R3,USECOUNT(R4) *      THEN IF USECOUNT < R3             00910000
         BL    NEXTONE                                                  00920000
         L     R3,USECOUNT(R4) *           THEN R3 = USECOUNT           00930000
         LR    R1,R4           *                R1 = OFFSET IN R4       00940000
         LR    R14,R2          *                SET R14 FLAG            00950000
NEXTONE  LA    R4,PDENTLEN(R4) * INCREMENT OFFSET IN R4                 00960000
         BCT   R15,REPEAT      * REPEAT LOOP                            00970000
         LTR   R14,R14        DID WE FIND A SUITABLE PAGE?              00980000
         BZ    ABEND1                                                   00990000
         DROP  R2                                                       01000000
SLOTFND  AR    R1,R2                                                    01010000
         LR    R7,R1                                                    01020000
         CLI   IOFLAG,0       I/O IN PROGRESS?                          01030000
         BE    NOCHECK2                                                 01040000
         MVI   IOFLAG,0       TURN OFF OUR I/O INDICATOR                01050000
         CHECK DECB                                                     01060000
         USING PDENTRY,R7                                               01070000
NOCHECK2 CLI   MODFIND,0                                                01080000
         BE    INCORE                                                   01090000
         MVC   BUFLOC,APGEBUFF  SET UP DECB FOR READ                    01100000
         USING FCBCELL,R8                                               01110000
         L     R8,FCBADDR     R8 = ADDRESS OF FCB                       01120000
         LH    R1,PAGENO                                                01130000
         L     R5,FCBTTRZ(R1)                                           01140000
         DROP  R8                                                       01150000
         ST    R5,TTRWORD                                               01160000
         L     R5,DCBADDR                                               01170000
         POINT (R5),TTRWORD                                             01180000
         READ  DECB,SF,MF=E                                             01190000
         CHECK DECB                                                     01200000
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR WRITE                   01210000
         WRITE DECB,SF,MF=E                                             01220000
         MVI   IOFLAG,1       INDICATE I/O UNDERWAY!                    01230000
         L     R1,WRITES                                                01240002
         A     R1,=F'1'                                                 01250002
         ST    R1,WRITES                                                01260002
         MVI   MODFIND,0      INDICATE PAGE NO LONGER MODIFIED          01270000
         DROP  R7                                                       01280000
         USING PDENTRY,R10                                              01290000
INCORE   ST    R6,USECOUNT    UPDATE THE USAGE COUNT FOR THIS PAGE      01300000
         CR    R7,R10                                                   01310000
         BE    COMMON                                                   01320000
         L     R11,ACOMMTAB                                             01330000
         USING COMMTABL,R11                                             01340000
         MVC   PNTR,RETARG1                                             01350000
         L     R0,PAGEADDR    GET THE CORE ADDR OF LOCATED PAGE         01360000
         AH    R0,OFFSET      ADD ON THE OFFSET                         01370000
         ST    R0,RETARG1                                               01380000
         ST    R0,ADDR                                                  01390000
         ST    R10,RETARG0                                              01400000
         ST    R10,ACURNTRY                                             01410000
         STM   R6,R7,COMMDATA                                           01420000
         OSRETURN                                                       01430000
*                                                                       01440000
*        ABENDS                                                         01450000
*                                                                       01460000
ABEND1   LA    R1,4001        PAGING AREA IS DEADLOCKED                 01470000
         B     DOABEND                                                  01480000
ABEND2   LA    R1,4005        BAD POINTER INPUTTED                      01490000
         B     DOABEND                                                  01500000
*                                                                       01510000
DOABEND  ABEND (R1),DUMP                                                01520000
*                                                                       01530000
*        DATABUF AREA (FOR INTER-MODULE COMMUNICATION)                  01540000
*                                                                       01550000
         DS    0F                                                       01560000
COMMDATA EQU   *                                                        01570000
LOCCNT   DC    F'0'           CURRENT LOCATE COUNTER                    01580000
AVULN    DC    A(0)           ADDRESS OF VULNERABLE PAD ENTRY           01590000
CURFCB   DC    A(0)           ADDRESS OF CURRENT FCB                    01600000
PADADDR  DC    A(0)           STARTING ADDRESS OF PAD                   01610000
ACOMMTAB DC    A(0)           ADDRESS OF COMMUNICATION AREA             01620000
ACURNTRY DC    A(0)           ADDRESS OF CURRENT PAD ENTRY              01630000
ROOT     DC    A(0)           ADDRESS OF ROOT FCB OF FCB TREE           01640000
SAVEXTPT DC    F'0'           POINTER TO SYMBOL NODE EXTENT CELL        01650000
SAVFSYMB DC    H'0'           FIRST SYMBOL OF BLOCK                     01660000
SAVLSYMB DC    H'0'           LAST SYMBOL OF BLOCK                      01670000
NUMGETM  DC    H'0'           NUMBER OF ENTRIES IN GETMAIN STACKS       01680000
NUMOFPGS DC    H'0'           NUMBER OF PAGES IN CURRENT PAGING AREA    01690000
BASNPGS  DC    H'0'           INITIAL NUMBER OF PAGES IN PAGING AREA    01700000
FCBSTKLN DC    H'0'           NUMBER OF ENTRIES IN FCB STACKS           01710000
IOFLAG   DC    X'00'          I/O IN PROGRESS INDICATOR                 01720000
GETMFLAG DC    X'00'          > 0 IMPLIES AUTO GETMAINS FOR FCBS        01730000
GOFLAG   DC    X'00'          > 0 IMPLIES SUCCESSFUL INITIALIZATION     01740000
MODFLAG  DC    X'00'          > 0 IMPLIES UPDAT MODE ACTIVE             01750000
ONEFCB   DC    X'00'          > 0 IMPLIES ONLY ONE FCB KEPT             01760002
         DC    3X'00'         SPARE                                     01770002
TOTFCBLN DC    F'0'           TOTAL AMOUNT OF FCB SPACE IN USE          01780002
RESERVES DC    F'0'           GLOBAL (TOTAL) COUNT OF RESERVES          01790002
READS    DC    F'0'           TOTAL NUMBER OF READS                     01800002
WRITES   DC    F'0'           TOTAL NUMBER OF WRITES                    01810002
SLECTCNT DC    F'0'           TOTAL NUMBER OF 'REAL' SELECTS            01820002
FCBCNT   DC    F'0'           TOTAL NUMBER OF FCBS IN EXISTENCE         01830002
GETMSTK1 DC    A(STACK1)      ADDRESS OF GETMAIN ADDRESS STACK          01840000
GETMSTK2 DC    A(STACK2)      ADDRESS OF GETMAIN LENGTH STACK           01850000
FCBSTK1  DC    A(STACK3)      ADDRESS OF FCB AREA ADDRESS STACK         01860000
FCBSTK2  DC    A(STACK4)      ADDRESS OF FCB AREA LENGTH STACK          01870000
MAXSTACK DC    H'50'          MAXIMUM NUMBER OF STACK ENTRIES           01880000
SDFVERS  DC    H'0'           SDF VERSION NUMBER (OF SELECTED SDF)      01890000
APGEBUFF DC    A(PAGEBUFF)    ADDRESS OF PAGE BUFFER                    01900000
ADECB    DC    A(DECB)        ADDRESS OF DECB                           01910000
         READ  DECB,SF,0,0,1680,MF=L                                    01920000
DCBADDR  EQU   DECB+8         ADDRESS OF HALSDF DCB (DECB)              01930000
BUFLOC   EQU   DECB+12        ADDRESS OF BUFFER AREA (DECB)             01940000
*                                                                       01950000
*        DATA AREA                                                      01960000
*                                                                       01970000
         DS    0F                                                       01980000
TTRWORD  DS    F                                                        01990000
OFFSET   DS    H                                                        02000000
*                                                                       02010000
*        GETMAIN STACKS                                                 02020000
*                                                                       02030000
         DS    0F                                                       02040000
STACK1   DS    50F            GETMAIN ADDRESS STACK                     02050000
STACK2   DS    50F            GETMAIN LENGTH STACK                      02060000
*                                                                       02070000
*        FCB AREA STACKS                                                02080000
*                                                                       02090000
         DS    0F                                                       02100000
STACK3   DS    50F            FCB AREA ADDRESS STACK                    02110000
STACK4   DS    50F            FCB AREA LENGTH STACK                     02120000
*                                                                       02130000
*        PAGE BUFFER                                                    02140000
*                                                                       02150000
         DS    0D                                                       02160000
PAGEBUFF DS    210D                                                     02170000
*                                                                       02180000
*        DSECTS                                                         02190000
*                                                                       02200000
         PDENTRY                                                        02210000
         FCBCELL                                                        02220000
         COMMTABL                                                       02230000
         END                                                            02240000
