*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    LOCATE.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

**********************************************************************
* PROCEDURE NAME:  LOCATE                                            *
**********************************************************************
*     REVISION HISTORY :                                             *
*     ------------------                                             *
*     DATE    NAME  REL    DR/CR NUMBER AND TITLE                    *
*                                                                    *
*     9/03/86 HFG   21V3   DR63474  SDFPKG ABENDS WITH U4001 ON      *
*                          PREHALSTAT FOR OF300300                   *
*                                                                    *
*     4/05/93 LJK   25V0   CR11165 IMPROVE HANDLING OF SDFPKG LOCATE *
*                   9V0    COUNTER                                   *
*                          IMPLEMENTATION OF CR11165 IS PROVIDED BY  *
*                          IBM CRAIG SCHULENBERG                     *
**********************************************************************
*
*DR63474 FIX: ASSIGN '00FFFFFF' TO R3 BEFORE ENTERING REPEAT LOOP
*  TO PREVENT 4001 ABEND WHEN LOCCNT ROLLS OVER TO 0.   HFG 9/3/86
*
         TITLE 'LOCATE  -  SDFPKG PAGING LOGIC'                         00000000
LOCATE   CSECT                                                          00000100
*     UPON ENTRY, REGISTER 1 CONTAINS A VIRTUAL MEMORY POINTER.  THE    00000200
*        HIGH ORDER HALFWORD CONTAINS A PAGE NUMBER, AND THE LOW ORDER  00000300
*        HALFWORD CONTAINS AN OFFSET.  LOCATE RETURNS THE CORRESPONDING 00000400
*        CORE ADDRESS IN REGISTER 1, AND THE ADDRESS OF THE ASSOCIATED  00000500
*        PAGING AREA DIRECTORY ENTRY IN REGISTER 0.                     00000600
*                                                                       00000700
         ENTRY COMMDATA                                                 00000800
         USING *,15                                                     00000805
         B     *+12                                                     00000810
         DC    CL8'LOCATE  '                                            00000815
         BALR  15,0                                                     00000817
         DROP  15                                                       00000820
         OSSAVE                                                         00000900
         STH   R1,OFFSET      SAVE THE OFFSET PORTION OF THE INPUT PTR  00001000
         LH    R11,RETARG1    R11 = PAGE #                              00001100
         LR    R12,R11                                                  00001200
         SLL   R12,3          R12 = PAGE # * 8                          00001300
         LM    R6,R8,COMMDATA                                           00001400
*
* CR11165 IS IMPLEMENTED TO USE A FULL 31-BIT LOCATE COUNTER. WHEN THE
* LOCATE COUNTER OVERFLOWS INTO THE SIGN BIT, SET LOCCNT BACK TO 1 AND
* RESET ALL USECOUNT IN PAGING AREA DIRECTORY.
*
         A     R6,=F'1'       R6 = NEW LOCATE COUNT
         BP    COUNTOK        WE ARE OK IF LOCCNT > 0
         LA    R6,1           RESET LOCCNT TO 1
         LH    R15,NUMOFPGS   R15 = NUMBER OF PAD ENTRY
         L     R2,PADADDR     GET ADDRESS OF PAGING AREA DIRECTORY
         USING PDENTRY,R2
         SR    R3,R3          CLEAR R3
         SR    R4,R4          USE R4 TO INDEX THROUGH THE PAD
CHEKNEXT EQU   *
         ST    R3,USECOUNT(R4) ZERO PAD ENTRY USECOUNT
         LA    R4,PDENTLEN(R4) ADVANCE TO THE NEXT PAD ENTRY
         BCT   R15,CHEKNEXT    PROCESS NEXT PAD ENTRY
COUNTOK  EQU   *
         DROP  R2
*        END CR11165
         USING FCBCELL,R8                                               00001600
         LTR   R11,R11                                                  00001700
         BM    ABEND2                                                   00001800
         CH    R11,LSTPAGE                                              00001900
         BH    ABEND2                                                   00002000
         LH    R1,OFFSET                                                00002100
         LTR   R1,R1                                                    00002200
         BM    ABEND2                                                   00002300
         CH    R1,=H'1679'                                              00002400
         BH    ABEND2                                                   00002500
         L     R10,FCBPDADR(R12)                                        00002600
         LTR   R10,R10        IS THE DESIRED PAGE IN CORE?              00002700
         BNZ   INCORE                                                   00002800
         ST    R7,FCBPDADR(R12)                                         00002900
         LR    R10,R7         CURRENT PAD SLOT IS FORMER VULN SLOT      00003000
         USING PDENTRY,R10                                              00003100
         CLI   IOFLAG,0       IS THERE A WRITE IN PROGRESS?             00003200
         BE    NOCHECK1                                                 00003300
         CHECK DECB          WAIT FOR ITS COMPLETION                    00003400
NOCHECK1 L     R5,FCBTTRZ(R12)                                          00003500
         DROP  R8                                                       00003600
         ST    R5,TTRWORD     SAVE THE REQUISITE TTR FOR POINT          00003700
         L     R5,DCBADDR     GET THE ADDRESS OF OUR DCB                00003800
         POINT (R5),TTRWORD                                             00003900
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR READ                    00004000
         READ  DECB,SF,MF=E                                             00004100
         MVI   IOFLAG,1       INDICATE A READ IS IN PROGRESS            00004200
         L     R1,READS                                                 00004205
         A     R1,=F'1'       USE A 32-BIT ADD  -- CR11165
         ST    R1,READS                                                 00004215
         L     R1,FCBADDR     R1 = FCB ADDR OF PAGE TO BE OVERWRITTEN   00004300
         LTR   R1,R1          IS THIS PAGE ACTUALLY IN USE?             00004400
         BZ    NOUPDAT        BYPASS FCB UPDATE IF THIS IS THE CASE     00004500
         USING FCBCELL,R1                                               00004600
         LH    R2,PAGENO      GET THE PAGE NUMBER (* 8)                 00004700
         SR    R0,R0                                                    00004800
         ST    R0,FCBPDADR(R2)                                          00004900
         DROP  R1                                                       00005000
NOUPDAT  ST    R8,FCBADDR                                               00005100
         STH   R12,PAGENO                                               00005200
COMMON   L     R2,PADADDR    * SEARCH PAD FOR NEW AVULN ENTRY           00005300
         DROP  R10                                                      00005400
         USING PDENTRY,R2                                               00005500
         LR    R0,R10                                                   00005600
         SR    R0,R2           * R0 = OFFSET OF OLD AVULN ENTRY         00005700
         L     R3,=X'7FFFFFFF' * INITIAL USECOUNT FOR LOOP -- CR11165
         SR    R4,R4           * R4 = OFFSET INTO PAD                   00005900
         SR    R5,R5           * R5 = 0, MEANS NOT RESERVED             00006000
         SR    R14,R14         * R14 IS NON-ZERO IF NEW AVULN FOUND     00006100
         LH    R15,NUMOFPGS                                             00006200
REPEAT   L     R7,FCBADDR(R4)  * LOOP FOR R15 = NUMOFPGS TO 0
         LTR   R7,R7           * IS THIS PAGE IN USE?
         BNZ   INUSE           * IF PAGE IS EMPTY                       00006500
         LR    R1,R4           * THEN R1 = OFFSET OF PAGE               00006600
         LR    R14,R2          *      SET R14 FLAG                      00006700
         B     SLOTFND         *      GO TO SLOT FOUND                  00006800
INUSE    CR    R4,R0           * ELSE IF OFFSET R4 /= OFFSET OF AVULN   00006900
         BE    NEXTONE                                                  00007000
         CH    R5,RESVCNT(R4)  * THEN IF ENTRY AT R4 IS NOT RESERVED    00007100
         BNE   NEXTONE                                                  00007200
         C     R3,USECOUNT(R4) *      THEN IF USECOUNT < R3             00007300
         BL    NEXTONE                                                  00007400
         L     R3,USECOUNT(R4) *           THEN R3 = USECOUNT           00007500
         LR    R1,R4           *                R1 = OFFSET IN R4       00007600
         LR    R14,R2          *                SET R14 FLAG            00007700
NEXTONE  LA    R4,PDENTLEN(R4) * INCREMENT OFFSET IN R4                 00007800
         BCT   R15,REPEAT      * REPEAT LOOP                            00007900
         LTR   R14,R14        DID WE FIND A SUITABLE PAGE?              00008000
         BZ    ABEND1                                                   00008100
         DROP  R2                                                       00008200
SLOTFND  AR    R1,R2                                                    00008300
         LR    R7,R1                                                    00008400
         CLI   IOFLAG,0       I/O IN PROGRESS?                          00008500
         BE    NOCHECK2                                                 00008600
         MVI   IOFLAG,0       TURN OFF OUR I/O INDICATOR                00008700
         CHECK DECB                                                     00008800
         USING PDENTRY,R7                                               00008900
NOCHECK2 CLI   MODFIND,0                                                00009000
         BE    INCORE                                                   00009100
         MVC   BUFLOC,APGEBUFF  SET UP DECB FOR READ                    00009200
         USING FCBCELL,R8                                               00009300
         L     R8,FCBADDR     R8 = ADDRESS OF FCB                       00009400
         LH    R1,PAGENO                                                00009500
         L     R5,FCBTTRZ(R1)                                           00009600
         DROP  R8                                                       00009700
         ST    R5,TTRWORD                                               00009800
         L     R5,DCBADDR                                               00009900
         POINT (R5),TTRWORD                                             00010000
         READ  DECB,SF,MF=E                                             00010100
         CHECK DECB                                                     00010200
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR WRITE                   00010300
         WRITE DECB,SF,MF=E                                             00010400
         MVI   IOFLAG,1       INDICATE I/O UNDERWAY!                    00010500
         L     R1,WRITES                                                00010505
         A     R1,=F'1'       USE A 32-BIT ADD -- CR11165
         ST    R1,WRITES                                                00010515
         MVI   MODFIND,0      INDICATE PAGE NO LONGER MODIFIED          00010600
         DROP  R7                                                       00010700
         USING PDENTRY,R10                                              00010800
INCORE   ST    R6,USECOUNT    UPDATE THE USAGE COUNT FOR THIS PAGE      00010900
         CR    R7,R10                                                   00011000
         BE    COMMON                                                   00011100
         L     R11,ACOMMTAB                                             00011200
         USING COMMTABL,R11                                             00011300
         MVC   PNTR,RETARG1                                             00011400
         L     R0,PAGEADDR    GET THE CORE ADDR OF LOCATED PAGE         00011500
         AH    R0,OFFSET      ADD ON THE OFFSET                         00011600
         ST    R0,RETARG1                                               00011700
         ST    R0,ADDR                                                  00011800
         ST    R10,RETARG0                                              00011900
         ST    R10,ACURNTRY                                             00012000
         STM   R6,R7,COMMDATA                                           00012100
         OSRETURN                                                       00012200
*                                                                       00012300
*        ABENDS                                                         00012400
*                                                                       00012500
ABEND1   LA    R1,4001        PAGING AREA IS DEADLOCKED                 00012600
         B     DOABEND                                                  00012700
ABEND2   LA    R1,4005        BAD POINTER INPUTTED                      00012800
         B     DOABEND                                                  00012900
*                                                                       00013000
DOABEND  ABEND (R1),DUMP                                                00013100
*                                                                       00013200
*        DATABUF AREA (FOR INTER-MODULE COMMUNICATION)                  00013300
*                                                                       00013400
         DS    0F                                                       00013500
COMMDATA EQU   *                                                        00013600
LOCCNT   DC    F'0'           CURRENT LOCATE COUNTER                    00013700
AVULN    DC    A(0)           ADDRESS OF VULNERABLE PAD ENTRY           00013800
CURFCB   DC    A(0)           ADDRESS OF CURRENT FCB                    00013900
PADADDR  DC    A(0)           STARTING ADDRESS OF PAD                   00014000
ACOMMTAB DC    A(0)           ADDRESS OF COMMUNICATION AREA             00014100
ACURNTRY DC    A(0)           ADDRESS OF CURRENT PAD ENTRY              00014200
ROOT     DC    A(0)           ADDRESS OF ROOT FCB OF FCB TREE           00014300
SAVEXTPT DC    F'0'           POINTER TO SYMBOL NODE EXTENT CELL        00014400
SAVFSYMB DC    H'0'           FIRST SYMBOL OF BLOCK                     00014500
SAVLSYMB DC    H'0'           LAST SYMBOL OF BLOCK                      00014600
NUMGETM  DC    H'0'           NUMBER OF ENTRIES IN GETMAIN STACKS       00014700
NUMOFPGS DC    H'0'           NUMBER OF PAGES IN CURRENT PAGING AREA    00014800
BASNPGS  DC    H'0'           INITIAL NUMBER OF PAGES IN PAGING AREA    00014900
FCBSTKLN DC    H'0'           NUMBER OF ENTRIES IN FCB STACKS           00015000
IOFLAG   DC    X'00'          I/O IN PROGRESS INDICATOR                 00015100
GETMFLAG DC    X'00'          > 0 IMPLIES AUTO GETMAINS FOR FCBS        00015200
GOFLAG   DC    X'00'          > 0 IMPLIES SUCCESSFUL INITIALIZATION     00015300
MODFLAG  DC    X'00'          > 0 IMPLIES UPDAT MODE ACTIVE             00015400
ONEFCB   DC    X'00'          > 0 IMPLIES ONLY ONE FCB KEPT             00015405
         DC    3X'00'         SPARE                                     00015410
TOTFCBLN DC    F'0'           TOTAL AMOUNT OF FCB SPACE IN USE          00015415
RESERVES DC    F'0'           GLOBAL (TOTAL) COUNT OF RESERVES          00015420
READS    DC    F'0'           TOTAL NUMBER OF READS                     00015425
WRITES   DC    F'0'           TOTAL NUMBER OF WRITES                    00015430
SLECTCNT DC    F'0'           TOTAL NUMBER OF 'REAL' SELECTS            00015435
FCBCNT   DC    F'0'           TOTAL NUMBER OF FCBS IN EXISTENCE         00015440
GETMSTK1 DC    A(STACK1)      ADDRESS OF GETMAIN ADDRESS STACK          00015500
GETMSTK2 DC    A(STACK2)      ADDRESS OF GETMAIN LENGTH STACK           00015600
FCBSTK1  DC    A(STACK3)      ADDRESS OF FCB AREA ADDRESS STACK         00015700
FCBSTK2  DC    A(STACK4)      ADDRESS OF FCB AREA LENGTH STACK          00015800
MAXSTACK DC    H'50'          MAXIMUM NUMBER OF STACK ENTRIES           00015900
SDFVERS  DC    H'0'           SDF VERSION NUMBER (OF SELECTED SDF)      00016000
APGEBUFF DC    A(PAGEBUFF)    ADDRESS OF PAGE BUFFER                    00016100
ADECB    DC    A(DECB)        ADDRESS OF DECB                           00016200
         READ  DECB,SF,0,0,1680,MF=L                                    00016300
DCBADDR  EQU   DECB+8         ADDRESS OF HALSDF DCB (DECB)              00016400
BUFLOC   EQU   DECB+12        ADDRESS OF BUFFER AREA (DECB)             00016500
*                                                                       00016600
*        DATA AREA                                                      00016700
*                                                                       00016800
         DS    0F                                                       00016900
TTRWORD  DS    F                                                        00017000
OFFSET   DS    H                                                        00017100
*                                                                       00017200
*        GETMAIN STACKS                                                 00017300
*                                                                       00017400
         DS    0F                                                       00017500
STACK1   DS    50F            GETMAIN ADDRESS STACK                     00017600
STACK2   DS    50F            GETMAIN LENGTH STACK                      00017700
*                                                                       00017800
*        FCB AREA STACKS                                                00017900
*                                                                       00018000
         DS    0F                                                       00018100
STACK3   DS    50F            FCB AREA ADDRESS STACK                    00018200
STACK4   DS    50F            FCB AREA LENGTH STACK                     00018300
*                                                                       00018400
*        PAGE BUFFER                                                    00018500
*                                                                       00018600
         DS    0D                                                       00018700
PAGEBUFF DS    210D                                                     00018800
*                                                                       00018900
*        DSECTS                                                         00019000
*                                                                       00019100
         PDENTRY                                                        00019200
         FCBCELL                                                        00019300
         COMMTABL                                                       00019400
         END                                                            00019500
