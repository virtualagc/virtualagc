*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    AUTHORIZ.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'AUTHORIZ - CREATES TIME, DATE, AUTHOR USER DATA IN PDS X00000100
               DIRECTORY MEMBER'                                        00000200
*                                                                       00000300
* INPUT: PARM='MEMBER' OR 'MEMBER,AUTHOR'                               00000400
*        MEMBER MUST EXIST IN PDS DEFINED BY AUTHORIZ DD OR             00000500
*        DDNAME SUPPLIED VIA OVERRIDE LIST                              00000600
*        IF PARM FIELD IS NULL, THE DCB IS CLOSED                       00000700
*        IF CALLED MULTIPLE TIMES AS A REUSABLE  ROUTINE, IT WILL       00000800
*        AVOID CLOSING AND REOPENING THE DCB IF DDNAME IS SAME          00000900
*                                                                       00001000
AUTHORIZ CSECT                                                          00001100
         USING *,15               *                                     00001200
         SAVE  (14,12)            *                                     00001300
         ST    13,SAVE+4          *                                     00001400
         CNOP  0,4                *                                     00001500
         BAL   13,START           * BOOKKEEPING STUFF                   00001600
         USING *,13               *                                     00001700
SAVE     DS    18F                                                      00001800
*                                                                       00001900
*        EXTRACT MEMBER, AUTHOR FROM PARM FIELD                         00002000
*                                                                       00002100
START    L     2,0(1)             GET PARM FIELD PTR                    00002200
         LTR   2,2                TEST FOR OVERRIDE LIST SUPPLIED       00002300
         BM    NOOVER             BR IF NOT SUPPLIED                    00002400
         L     3,4(1)             GET ADR OF DD OVERRIDE                00002500
         CLC   DDNAME,2(3)        IS DDNAME SAME AS LAST TIME?          00002600
         BE    NOOVER             BR IF SO                              00002700
*        OVERRIDING DDNAME SUPPLIED. CLOSE AND REOPEN DCB IF NECESSARY  00002800
         TM    PDS+(DCBOFLGS-IHADCB),DCBOFOPN TEST IF DCB OPEN          00002900
         BZ    OVERRIDE           BR IF NOT                             00003000
         CLOSE (PDS)                                                    00003100
OVERRIDE MVC   DDNAME,2(3)        SAVE DDNAME                           00003200
         MVC   PDS+(DCBDDNAM-IHADCB)(8),2(3) SET DCB DDNAME             00003300
         OPEN  (PDS,(UPDAT))                                            00003400
NOOVER   EQU   *                                                        00003500
         LH    5,0(2)             GET LENGTH                            00003600
         LTR   4,5                IF LENGTH IS ZERO, QUIT               00003700
         BNP   NOPARM                                                   00003800
         LA    1,2(2)             POINT TO 1ST CHAR                     00003900
*        LOOP TO FIND COMMA                                             00004000
COMMATST CLI   0(1),C','          TEST FOR COMMA                        00004100
         BE    GOTCOMM            BR IF FOUND                           00004200
         LA    1,1(1)             SKIP TO NEXT CHAR                     00004300
         BCT   4,COMMATST         LOOP TILL COMMA OR END OF FIELD       00004400
*        COMPUTE LENGTH OF MEMBER FIELD                                 00004500
GOTCOMM  SR    5,4                LENGTH OF MEMBER PORTION              00004600
         BNP   NOMEM              BR IF NO MEMBER PORTION               00004700
         LA    0,7                MAX MEMBER LENGTH-1                   00004800
         BCTR  5,0                MEMBER LENGTH-1                       00004900
         NR    5,0                INSURE MEMBER<=8                      00005000
         EX    5,MOVEMEM          COPY MEMBER NAME TO FIND, STOW AREA   00005100
         LA    0,1                                                      00005200
         SR    4,0                COMPUTE LENGTH OF AUTHOR FIELD        00005300
         BNP   NOAUTHOR           BR IF NONE                            00005400
*        COPY AUTHOR                                                    00005500
         LA    0,L'AUTHOR         MAX LENGTH OF AUTHOR FIELD            00005600
         CR    0,4                IF LENGTH OF SUPPLIED AUTHOR IS       00005700
         BNL   *+6                GREATER THAN MAX THEN                 00005800
         LR    4,0                TRUNCATE TO MAX                       00005900
         BCT   4,AUTHEX           -1 FOR EXECUTE                        00006000
*        1 CHARACTER AUTHOR FIELD IS SPECIAL CASE:                      00006100
*        NO AUTHOR FIELD IN USER DATA FIELD                             00006200
         MVI   USERLEN,3          3 HALFWORDS OF USER DATA              00006300
AUTHEX   EX    4,MOVEAUTH         COPY TO STOW AREA                     00006400
         B     GETTIME            GO GET DATE, TIME                     00006500
MOVEMEM  MVC   MEMBER(0),2(2)                                           00006600
MOVEAUTH MVC   AUTHOR(0),1(1)                                           00006700
*                                                                       00006800
*        NO AUTHOR WAS SUPPLIED IN PARM FIELD. USE JOBNAME OR TSO ID    00006900
*                                                                       00007000
NOAUTHOR EXTRACT   TIOT,FIELDS=(TIOT,PSB)                               00007100
*        ASSUME TSO                                                     00007200
         MVC   AUTHOR(6),=C' TSO: '                                     00007300
         L     1,PSB              GET ADR OF PROTECTED STORAGE BLOCK    00007400
         LTR   1,1                =0 IF NOT TSO                         00007500
         BNZ   TSO                BR IF ASSUMPTION CORRECT              00007600
         MVC   AUTHOR(6),=C' JOB: '                                     00007700
TSO      L     1,TIOT             TIOT HAS JOBNAME (AND TSO ID)         00007800
         MVC   AUTHOR+6(8),0(1)                                         00007900
*                                                                       00008000
*        GET DATE, TIME IN SAME FORM AS XPL                             00008100
*                                                                       00008200
GETTIME  TIME  BIN                                                      00008300
         ST    1,DATE             SAVE FOR CONVERT                      00008400
         ST    0,TIME                                                   00008500
         CVB   1,DBLWRD           CONVERT DATE TO BINARY                00008600
         ST    1,DATE                                                   00008700
*        ONLY LOW ORDER 3 BYTES OF DATE AND TIME NEEDED                 00008800
         MVC   USERDATE,DATE+1                                          00008900
         MVC   USERTIME,TIME+1                                          00009000
*                                                                       00009100
*        OPEN PDS FOR FIND, STOW                                        00009200
*                                                                       00009300
         SR    10,10              ASSUME DCB ALREADY OPEN               00009400
         TM    PDS+DCBOFLGS-IHADCB,DCBOFOPN IS IT?                      00009500
         BO    FIND               BR IF ALREADY OPEN                    00009600
         BCTR  10,0               -1  CAUSES CLOSE BELOW                00009700
         OPEN  (PDS,(UPDAT))                                            00009800
         TM    PDS+(DCBOFLGS-IHADCB),DCBOFOPN                           00009900
         BZ    NODD               BR IF DD CARD MISSING                 00010000
*                                                                       00010100
*        FIND MEMBER                                                    00010200
*                                                                       00010300
FIND     FIND  PDS,MEMBER,D       MEMBER MUST BE THERE                  00010400
         LTR   15,15                                                    00010500
         BNZ   NOFIND             QUIT IF MEMBER NOT THERE              00010600
         STOW  PDS,MEMBER,R       REPLACE MEMBER WITH UISER DATA        00010700
         LTR   15,15                                                    00010800
         BNZ   NOSTOW             BR IF BAD STOW                        00010900
*                                                                       00011000
*        CLOSE DCB UNLESS IN MULTIPLE USE MODE                          00011100
*                                                                       00011200
         LTR   10,10                                                    00011300
         BZ    RET                SKIP CLOSE IF MULT CALLS FOR 1 DDN    00011400
NOPARM   CLOSE (PDS)              CLOSE PDS                             00011500
*                                                                       00011600
RET      L     13,4(13)                                                 00011700
         RETURN (14,12),RC=0                                            00011800
*                                                                       00011900
*        ERROR CONDITIONS                                               00012000
*                                                                       00012100
NOMEM    XPLABEND 92,'NO MEMBER NAME SUPPLIED'                          00012200
NODD     XPLABEND 93,NODDMSG                                            00012300
NODDMSG  DC    AL1(NODDMSGL-1)                                          00012400
DDNAME   DC    CL8'AUTHORIZ'                                            00012500
         DC    C' DD CARD MISSING'                                      00012600
NODDMSGL EQU   *-DDNAME                                                 00012700
NOFIND   LA    0,4                                                      00012800
         CR    0,15                                                     00012900
         BNE   IOERR                                                    00013000
         MVC   BADMEM,MEMBER                                            00013100
         XPLABEND 94,BADMSG-1                                           00013200
         DC    AL1(L'BADMSG-1)                                          00013300
BADMSG   DC    C'MEMBER 12345678 NOT FOUND'                             00013400
         ORG   BADMSG+7                                                 00013500
BADMEM   DS    CL8                                                      00013600
         ORG                                                            00013700
NOSTOW   LA    0,12                                                     00013800
         CR    0,15                                                     00013900
         BNE   IOERR                                                    00014000
         XPLABEND 95,'NO SPACE LEFT IN DIRECTORY'                       00014100
IOERR    XPLABEND 96,'I/O ERROR IN DIRECTORY'                           00014200
*                                                                       00014300
*        DATA AREAS                                                     00014400
TIOT     DS    F                                                        00014500
PSB      DS    F                                                        00014600
DBLWRD   DC    D'0'                                                     00014700
         ORG   *-4                                                      00014800
DATE     DS    F                                                        00014900
MEMBER   DC    CL8' '                                                   00015000
         DS    XL3                TTR                                   00015100
USERLEN  DC    AL1(10)            COUNT OF USER DATA HALFWORDS          00015200
USERDATE DS    XL3                                                      00015300
USERTIME DS    XL3                                                      00015400
AUTHOR   DC    CL14' '                                                  00015500
TIME     DS    F                                                        00015600
PDS      DCB   DDNAME=AUTHORIZ,DSORG=PO,MACRF=(R,W),BUFNO=0             00015700
         PRINT NOGEN                                                    00015800
         DCBD  DSORG=PO                                                 00015900
         END                                                            00016000
