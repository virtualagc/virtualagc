*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    HALLKED.bal
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

*        PRINT OFF                                                      00000100
LKED     TITLE 'HALLKED ---- CONSTRUCT TREE AND EMIT OBJECT DECKS'      00000200
         MACRO                                                          00000300
&L       MYGET &A                                                       00000400
&L       BAL   15,GETRECRD BRANCH TO GET ROUTINE                        00000500
         MEND                                                           00000600
         EJECT                                                          00000700
         SPACE 3                                                        00000800
HALLKED  CSECT                                                          00000900
         USING *,15                                                     00001000
         SAVE  (14,12),T,*                                              00001100
         LA    14,OSSAVE CHAIN SAVE AREAS NICELY                        00001200
         ST    14,8(0,13)                                               00001300
         ST    13,4(0,14)                                               00001400
         SR    13,13                                                    00001500
         ST    13,8(0,14) MY FORWARD PTR                                00001600
         LR    13,14 FOR THEM GETS 'N PUTS                              00001700
         LM    11,12,BASES                                              00001800
         DROP  15                                                       00001900
         USING HALLKED,12,11                                            00002000
         LTR   1,1 ANY PARM / DDLIST                                    00002100
         BZ    OPEN1                                                    00002200
         L     2,0(0,1) PARM PRT                                        00002300
         LH    3,0(0,2) LENGTH                                          00002400
         LTR   3,3 ANY FIELD                                            00002500
         BZ    HALLKED1                                                 00002600
         CLI   3(2),0    ALLOW HALSTART                                 00002700
         BNE   *+8                                                      00002800
         MVI   NOP2+1,240                                               00002900
         CLI   4(2),0 SUPRESS HALMAP                                    00003000
         BE    *+8                                                      00003100
         MVI   NOP3+1,240                                               00003200
         CLI   5(2),0 PERMIT RECURSION?                                 00003300
         BE    *+8                                                      00003400
         MVI   BRANCH3+1,0                                              00003500
         CLI   9(2),0 XREF OF CSECT NAME/PROGRAMMER NAME?               00003600
         BE    *+20                                                     00003700
         MVI   MOVE+1,0                                                 00003800
         MVI   ALLOPEN3+3,ESDLENTH+NAMELEN                              00003900
         MVI   NOXREF+1,0                                               00004000
         MVI   NOXREFP+1,0                                              00004100
         CLI   2(2),0 PRINT SUPRESSED                                   00004200
         BNE   *+12                                                     00004300
         MVI   NOP9+1,240                                               00004400
         MVI   PHASE3+1,X'F0'                                           00004500
HALLKED1 DC    0H'0'                                                    00004600
         TM    0(1),X'80' PARM                                          00004700
         BO    OPEN1                                                    00004800
         L     2,4(0,1) PTR TO DDLIST                                   00004900
         LH    3,0(0,2) LENGTH OF DDLIST                                00005000
         LTR   3,3                                                      00005100
         BNH   OPEN SKIP IF NONE                                        00005200
         LA    8,8 FOR FUTURE REF                                       00005300
         LA    2,2(0,2) POINT TO DDLIST                                 00005400
         OC    0(8,2),0(2)                                              00005500
         BZ    *+10                                                     00005600
         MVC   SYSGO+X'28'(8),0(2) REPLACE SYSGO DD NAME                00005700
         SR    3,8                                                      00005800
         BNH   OPEN                                                     00005900
         OC    8(8,2),8(2)                                              00006000
         BZ    *+22                                                     00006100
         MVC   SYSLINP+X'28'(8),8(2)                                    00006200
         MVC   SYSLIN+X'28'(8),8(2) REPLACE SYSLIN NAME                 00006300
         MVC   FILENAME(8),8(2) AND FILE NAME ON INCLUDE CARD           00006400
         SR    3,8                                                      00006500
         BNH   OPEN                                                     00006600
         OC    16(8,2),16(2) SYSPRINT?                                  00006700
         BZ    *+10                                                     00006800
         MVC   SYSPRINT+X'28'(8),16(2)                                  00006900
         SR    3,8                                                      00007000
         BNH   OPEN                                                     00007100
         OC    24(8,2),24(2)                                            00007200
         BZ    *+10                                                     00007300
         MVC   MEMBR(8),24(2)                                           00007400
         SR    3,8                                                      00007500
         BNH   OPEN                                                     00007600
         OC    32(8,2),32(2) SYSLIB                                     00007700
         BZ    *+10                                                     00007800
         MVC   SYSLIB(8),32(2)                                          00007900
         SR    3,8                                                      00008000
         BNH   OPEN                                                     00008100
         OC    40(8,2),40(2)                                            00008200
         BZ    *+10                                                     00008300
         MVC   LINKIN+X'28'(8),40(2)                                    00008400
         SPACE 3                                                        00008500
OPEN     DC    0H'0'                                                    00008600
         OC    MEMBR(8),MEMBR                                           00008700
         BNZ   OPENDSEQ YES, DO NOT OPEN SEQUENTIAL SYSLIN              00008800
         SPACE 3                                                        00008900
OPEN1    OPEN  (SYSLIN,INPUT)                                           00009000
         TM    SYSLIN+48,16 OPENED OK?                                  00009100
         BNO   NOOPEN                                                   00009200
         GET   SYSLIN                                                   00009300
         MVC   FINDNAME(8),2(1) MOVE FIRST MEMBER'S NAME                00009400
         MVC   MEMBR(8),2(1)                                            00009500
*         CLC   FINDNAME(8),=CL8'TEMPNAME' IF TEMPNAME, DO NOT          00009600
*         BE    *+10 PASS IT BACK FOR LINK EDIT 2                       00009700
*         MVC   24(8,2),FINDNAME IF NOT, NAME CARD GIVEN TO LINK 1      00009800
*              AND SHOULD BE PASSED TO LINK 2                           00009900
         CLOSE (SYSLIN)                                                 00010000
         FREEPOOL SYSLIN                                                00010100
         B     OPENED                                                   00010200
OPENDSEQ MVC   FINDNAME(8),MEMBR                                        00010300
*         MVC   MEMBR(8),24(2)                                          00010400
OPENED   OPEN  (SYSLINP,INPUT)                                          00010500
         TM    SYSLINP+48,16 OPENED OK?                                 00010600
         BNO   NOOPEN                                                   00010700
         LH    0,SYSLINP+X'3E' PICKUP BLKSIZE                           00010800
         ST    0,SYSLINBL SAVE LENGTH FOR FREEMAIN                      00010900
         GETMAIN R,LV=(0) GET CORE FOR BUFFER                           00011000
         ST    1,SYSLINBA SAVE ADDRESS                                  00011100
         FIND  SYSLINP,FINDNAME,D                                       00011200
         LTR   15,15 CHECK RETURN CODE                                  00011300
         LA    15,FINDERR(0,15) RETURN CODE=FINDERR+FIND RC IF NOT ZERO 00011400
         BNZ   NOOPEN                                                   00011500
         OPEN  (SYSGO,(OUTPUT),SYSPRINT,(OUTPUT))                       00011600
         TM    SYSGO+48,16 SYSGO OPENED                                 00011700
         BNO   NOOPEN                                                   00011800
         TM    SYSPRINT+48,16 SYSPRINT OK                               00011900
         BO    ALLOPEN OK IF BRANCHES                                   00012000
         SPACE 3                                                        00012100
NOOPEN   DC    0H'0'                                                    00012200
         LA    15,FILEBAD                                               00012300
         B     RETURN                                                   00012400
         SPACE 3                                                        00012500
FILEBAD  EQU   108                                                      00012600
FINDERR  EQU   120                                                      00012700
RECFOUND EQU   100                                                      00012800
NOSPACE  EQU   104                                                      00012900
TWOVER   EQU   140                                                      00013000
SYMUNDEF EQU   TWOVER+4                                                 00013100
SYMERROR EQU   SYMUNDEF+4                                               00013200
         SPACE 3                                                        00013300
BASES    DC    A(HALLKED+4096,HALLKED) KEEP NEAR TOP FOR ADDRESSABILITY 00013400
OSSAVE   DS    18F                                                      00013500
         EJECT                                                          00013600
SYSLIN   DCB   DDNAME=TEMPLOAD,DSORG=PS,MACRF=(GL)                      00013700
         EJECT                                                          00013800
SYSLINP  DCB   DDNAME=TEMPLOAD,DSORG=PO,MACRF=(R)                       00013900
FINDNAME DC    D'0' MEMBER OF PDS                                       00014000
SYSLINBL DC    A(0)                                                     00014100
SYSLINBA DC    A(0)                                                     00014200
         EJECT                                                          00014300
SYSPRINT DCB   DDNAME=SYSPRINT,DSORG=PS,MACRF=(PL),                    *00014400
               RECFM=FBM,LRECL=121                                      00014500
         EJECT                                                          00014600
SYSGO    DCB   DDNAME=STACKOBJ,DSORG=PS,MACRF=(PL),                    *00014700
               RECFM=FB,LRECL=80,BLKSIZE=400                            00014800
         EJECT                                                          00014900
LINKIN   DCB   DDNAME=LINKIN,DSORG=PS,MACRF=(GL),EODAD=LINKEOD          00015000
         EJECT                                                          00015100
ALLOPEN  LA 6,5                                                         00015200
ALLOPEN1 GETMAIN VC,A=ABUFF,LA=SIZES                                    00015300
         B     *+4(15)                                                  00015400
         B     ALLOPEN2                                                 00015500
         LM    0,1,SIZES                                                00015600
         SRDL  0,1                                                      00015700
         STM   0,1,SIZES                                                00015800
         BCT   6,ALLOPEN1                                               00015900
*        PRINT  ON                                                      00016000
         B     SPACE                                                    00016100
ALLOPEN2 DC    0H'0'                                                    00016200
         OPEN  (LINKIN,INPUT)                                           00016300
         TM    LINKIN+48,16   OPENED UP?                                00016400
         BNO   LINKEND        NO LINKIN FILE                            00016500
GETLINK  GET   LINKIN         COPY CONTENTS TO STACKOBJ                 00016600
         LR    2,1                                                      00016700
         PUT   SYSGO                                                    00016800
         MVC   0(80,1),0(2)                                             00016900
         B     GETLINK                                                  00017000
LINKEOD  CLOSE (LINKIN)       END OF DATA                               00017100
         FREEPOOL LINKIN      FREE BUFFER SPACE                         00017200
LINKEND  DC    0H'0'                                                    00017300
         L     10,ABUFF ********R10 SHOULD ALWAYS POINT THERE           00017400
ALLOPEN3 LA    2,ESDLENTH COMPUTE MAX # ESDID'S                         00017500
         L     1,ABUFF+4 SIZE RECEIVED                                  00017600
         SR    0,0                                                      00017700
         DR    0,2                                                      00017800
         STH   1,MAXESDID                                               00017900
         LA    2,SYMLEN ALLOCCATE SPACE FOR SYMBOL TABLE                00018000
         L     1,ABUFF+4                                                00018100
         SR    0,0                                                      00018200
         DR    0,2                                                      00018300
         STH   1,SYMMAX                                                 00018400
         ST    10,SYMNA                                                 00018500
         SPACE 5                                                        00018600
FINDSYM  MYGET SYSLIN                                                   00018700
         CLC   0(2,1),=XL2'4000'                                        00018800
         BE    SYM1           SYM RECORD FOUND                          00018900
         CLI   0(1),X'20'     CESD RECORD                               00019000
         BNE   GETRECRD                                                 00019100
         ST    1,SIZES                                                  00019200
         SPACE 3                                                        00019300
*CHECK FOR COMPLETE AND CONSTISTENT INFORMATION IN TABLES               00019400
         LR    9,10           BUFFER ADDRESS                            00019500
         LH    8,SYMCOUNT     NUMBER OF SYM ENTRIES+1                   00019600
         B     SYM150                                                   00019700
SYM100   CLI   (FP-SYMCELL)(9),1      DEFINE/REFERENCE/UNDEFINED?       00019800
         BH    SYM145         SKIP IF REFERENCE                         00019900
         BL    SYM200E        SKIP IF UNDEFINED                         00020000
         LR    7,9                                                      00020100
SYM101   L     6,(BP-SYMCELL)(0,7) PTR TO NEXT                          00020200
         LA    6,0(0,6) CLEAR HI ORDER                                  00020300
         LTR   7,6 MORE OR LAST (IF ZERO)                               00020400
         BZ    SYM145 LAST, SKIP OUT OF LOOP                            00020500
         CLC   (BP-SYMCELL)(1,7),(BP-SYMCELL)(9) SAME VERSIONS?         00020600
         BE    SYM101 SAME, GO TO NEXT                                  00020700
SYM102E  DC   0H'0'                                                     00020800
         STM   2,9,DOUBLE SAVE NEEDED REGS                              00020900
         BAL   9,PRINTER GET LINE IN BUFFER                             00021000
         LM    2,9,DOUBLE RESTORE                                       00021100
         SR    6,6                                                      00021200
         IC    6,(BP-SYMCELL)(0,9) VERSION NUMBER                       00021300
         CVD   6,DOUBLE CONVERT TO PRINTABLE DECIMAL CHARACTERS         00021400
         UNPK  SYMV1(3),DOUBLE+6(2)                                     00021500
         OI    SYMV1+2,240                                              00021600
         IC    6,(BP-SYMCELL)(0,7)                                      00021700
         CVD   6,DOUBLE                                                 00021800
         UNPK  SYMV2(3),DOUBLE+6(2)                                     00021900
         OI    SYMV2+2,240                                              00022000
         MVC   SYMN1(8),(SN-SYMCELL)(9)                                 00022100
         L     6,(FP-SYMCELL)(0,7)                                      00022200
         MVC   SYMN2(8),(SN-SYMCELL)(6) MOVE NAMES                      00022300
         MVC   1(SYM2EL,1),SYM2E                                        00022400
SYM103E  OI    SYMS,SYMERROR                                            00022500
         B     SYM101                                                   00022600
SYM200E  DC    0H'0'                                                    00022700
         STM   2,9,DOUBLE                                               00022800
         BAL   9,PRINTER                                                00022900
         LM    2,9,DOUBLE                                               00023000
         MVC   1(L'SYME1,1),SYME1 MOVE MESSAGE NUMBER                   00023100
         MVC   2+L'SYME1(8,1),(SN-SYMCELL)(9)                           00023200
SYM201E  OI    SYMS,SYMUNDEF                                            00023300
SYM145   LA    9,SYMLEN(9,0)                                            00023400
SYM150   BCT   8,SYM100                                                 00023500
         MVI   PAGECT+3,1                                               00023600
         L     1,SIZES                                                  00023700
         B     CESD2                                                    00023800
         SPACE 3                                                        00023900
SYM1     LH    2,2(0,1)                                                 00024000
         LA    1,4(0,1)                                                 00024100
SYM2     CLC   0(4,1),O2SYM IS IT A SYM CARD                            00024200
         BE    SYM4                                                     00024300
SYM3     LA    1,80(1,0)                                                00024400
         SH    2,SYM3+2                                                 00024500
         BH    SYM2                                                     00024600
         B     GETRECRD                                                 00024700
         SPACE 3                                                        00024800
SYM4     TM    SYMS,SEARCH                                              00024900
         BZ    SYM5                                                     00025000
         CLC   16(10,1),SYMSTART ANDY DID IT OR NOT                     00025100
         BNE   SYM3 GUESS NOT                                           00025200
         LA    3,26(0,1)                                                00025300
         LH    4,10(0,1)                                                00025400
         SH    4,SYM5+2  NUMBER OF BYTES REMAINING                      00025500
         B     SYM10                                                    00025600
         SPACE 3                                                        00025700
SYM5     LH    4,10(1,0)                                                00025800
         LA    3,16(0,1) PTR TO DATA ITEM                               00025900
         SPACE 3                                                        00026000
SYM10    SR    5,5                                                      00026100
         IC    5,0(0,3) COUNT OF CHARS IN NAME -1                       00026200
         LA    14,7                                                     00026300
         NR    5,14                                                     00026400
         LA    5,1(0,5)                                                 00026500
         MVC   SYMBUFFN(8),BLANKS                                       00026600
         EX    5,SYMMVC MOVE NAME, VERSION NUMVER                       00026700
         LA    5,4(0,5)                                                 00026800
         SR    4,5  NUMBER OF BYTES LEFT                                00026900
         AR    3,5  NEXT ADDRESS                                        00027000
         CLC   SYMBUFFN(6),=CL6'HALS/E' END OF THE ROAD?                00027100
         BNE   SYM11                                                    00027200
         OI    SYMS,SEARCH RESET TO SEARCH MODE                         00027300
         B     SYM3                                                     00027400
SYM11    BAL   14,SYMBUILD                                              00027500
         LTR   5,4                                                      00027600
         BH    SYM10+2                                                  00027700
         B     SYM3                                                     00027800
         SPACE 3                                                        00027900
*SET UP CELL FOR DEFINITION OF VERSION NUMBER                           00028000
SYMBUILD DC    0H'0'                                                    00028100
         TM    SYMS,SEARCH                                              00028200
         BZ    SYM50                                                    00028300
         XI    SYMS,SEARCH RESET FLAG                                   00028400
         LH    8,SYMCOUNT                                               00028500
         LR    9,10                                                     00028600
         B     SYM13 LOOK FOR PREVIOUS DEFINITION                       00028700
SYM12    CLC   (SN-SYMCELL)(8,9),SYMBUFFN                               00028800
         BE    SYM20 IF ALREADY THERE, CHECK IF UNDEFINED               00028900
SYM12A   LA    9,SYMLEN(9,0)                                            00029000
SYM13    BCT   8,SYM12                                                  00029100
         L     9,SYMNA NO DEF FOUND, MUST CREATE                        00029200
         ST    9,SYMCA SAVE ADDRESS FOR ALMOST ALL POSTERITY            00029300
         LA    8,SYMLEN(0,9)                                            00029400
         ST    8,SYMNA                                                  00029500
         LH    8,SYMCOUNT                                               00029600
         LA    8,1(0,8)                                                 00029700
         CH    8,SYMMAX                                                 00029800
         BH    SPACE                                                    00029900
         STH   8,SYMCOUNT                                               00030000
         XC    0(SYMLEN,9),0(9)                                         00030100
         MVC   (SN-SYMCELL)(8,9),SYMBUFFN                               00030200
         MVI   (FP-SYMCELL)(9),1 CREATE CELL, MARK AS DEFINITION        00030300
         MVC   (BP-SYMCELL)(1,9),SYMBUFFV VERSION NUMBER                00030400
         BR    14                                                       00030500
         SPACE 3                                                        00030600
SYM20    CLI   (FP-SYMCELL)(9),1 DEFINED                                00030700
         BH    SYM12A         NO, JUST REFERENCED                       00030800
         ST    9,SYMCA SAVE                                             00030900
         BE    SYM21          MAKE SURE SAME VERSION NUMBERS            00031000
         MVC   (BP-SYMCELL)(1,9),SYMBUFFV  MOVE VERSION NUMBERT         00031100
         MVI   (FP-SYMCELL)(9),1 INDICATE DEFINITION TAKEN PLACE        00031200
         BR 14                                                          00031300
SYM21    CLC   (BP-SYMCELL)(1,9),SYMBUFFV                               00031400
         BCR   8,14 SAVE                                                00031500
         STM   2,15,DOUBLE ERROR....DIFFERENT VERSIONS PRESENT          00031600
         BAL   9,PRINTER                                                00031700
         LM    2,15,DOUBLE                                              00031800
         MVC   1(8,1),(SN-SYMCELL)(9) MOVE CSECT NAME                   00031900
         SR    6,6                                                      00032000
         IC    6,(BP-SYMCELL)(0,9)                                      00032100
         CVD   6,DOUBLE                                                 00032200
         UNPK  SYMDUPV1(3),DOUBLE+6(2)                                  00032300
         OI    SYMDUPV1+2,240  CONSTRUCT TWO VERSION NUMBERS            00032400
         IC    6,SYMBUFFV                                               00032500
         CVD   6,DOUBLE                                                 00032600
         UNPK  SYMDUPV2(3),DOUBLE+6(2)                                  00032700
         OI    SYMDUPV2+2,240                                           00032800
         MVC   11(SYMDUPL,1),SYMDUP                                     00032900
         OI    SYMS,SYM2VER                                             00033000
         BR    14                                                       00033100
         SPACE 5                                                        00033200
*SET UP CELL FOR REFERENCE (AND POSSIBLY, UNDEFINED DEFINITION)         00033300
SYM50    L     9,SYMNA                                                  00033400
         LA    8,SYMLEN(0,9)                                            00033500
         ST    8,SYMNA                                                  00033600
         XC    0(SYMLEN,9),0(9)                                         00033700
         MVC   (SN-SYMCELL)(8,9),SYMBUFFN                               00033800
         L     8,SYMCA                                                  00033900
         ST    8,(FP-SYMCELL)(0,9) LOCATE FATHER                        00034000
         MVI   (FP-SYMCELL)(9),2 REF                                    00034100
         MVC   (BP-SYMCELL)(1,9),SYMBUFFV MOVE VERSION NUMBER           00034200
         LH    8,SYMCOUNT                                               00034300
         LA    7,1(0,8)                                                 00034400
         CH    7,SYMMAX                                                 00034500
         BH    SPACE                                                    00034600
         STH   7,SYMCOUNT                                               00034700
         LR    7,8                                                      00034800
         LR    8,10                                                     00034900
         B     SYM53                                                    00035000
SYM52    CLC   (SN-SYMCELL)(8,8),SYMBUFFN LOOK FOR DEF OF SAME          00035100
         BE    SYM55 FOUND IT                                           00035200
         LA    8,SYMLEN(0,8)                                            00035300
SYM53    BCT   7,SYM52                                                  00035400
         LH    7,SYMCOUNT                                               00035500
         LA    7,1(0,7)                                                 00035600
         CH    7,SYMMAX                                                 00035700
         BH    SPACE                                                    00035800
         STH   7,SYMCOUNT                                               00035900
         L     8,SYMNA MUST CREATE DEF                                  00036000
         LA    7,SYMLEN(0,8)                                            00036100
         ST    7,SYMNA                                                  00036200
         MVC   0(SYMLEN,8),0(9)                                         00036300
         MVI   (FP-SYMCELL)(8),0 UNDEF                                  00036400
         ST    9,(BP-SYMCELL)(0,8) COPY BP                              00036500
         BR    14                                                       00036600
         SPACE 5                                                        00036700
SYM55    DC    0H'0' FOUND BROTHER, DO SOME DELINKING                   00036800
         L     7,(BP-SYMCELL)(0,8)                                      00036900
         IC    6,(BP-SYMCELL)(0,8)                                      00037000
         ST    9,(BP-SYMCELL)(0,8)                                      00037100
         STC   6,(BP-SYMCELL)(0,8)                                      00037200
         IC    6,(BP-SYMCELL)(0,9)                                      00037300
         ST    7,(BP-SYMCELL)(0,9)                                      00037400
         STC   6,(BP-SYMCELL)(0,9)                                      00037500
         BR    14                                                       00037600
*FIND AND READ CESD DATA                                                00037700
*        PRINT OFF                                                      00037800
CESD1    MYGET SYSLIN                                                   00037900
         CLI   0(1),X'20' CESD                                          00038000
         BNE   GETRECRD NO                                              00038100
CESD2    LH    2,4(0,1) ESDID OF FIRST                                  00038200
         LH    3,6(0,1) # OF BYTES OF DATA                              00038300
         SRL   3,4 #/16 = BCT COUNT                                     00038400
         LA    1,8(0,1) POINT TO FIRST ITEM                             00038500
         SPACE 5                                                        00038600
ESDLOOP  CH    2,MAXESD SET MAXESD=MAX ESD #                            00038700
         BNH   *+8                                                      00038800
         STH   2,MAXESD                                                 00038900
         CH    2,MAXESDID TOO MANY                                      00039000
         BH    SPACE                                                    00039100
         LR    4,2                                                      00039200
         BCTR  4,0 COMPUTE ADDRESS OF TABLE                             00039300
         MH    4,ESDLEN                                                 00039400
         AR    4,10                                                     00039500
         SPACE 3                                                        00039600
         XC    0(ESDLENTH,4),0(4) ZERO ENTRY                            00039700
         MVI   (S0-ESD)(4),NULL+NOTHAL                                  00039800
         CLI   8(1),7 NULL                                              00039900
         BE    ESDLEND                                                  00040000
         TM    8(1),3 SD OR PC                                          00040100
         BE    ESDMOVE                                                  00040200
         BNO   ESDLEND IF NOT 000 OR 111, WANT TO IGNORE                00040300
         CLI   8(1),3 LD                                                00040400
         BNE   ESDLEND                                                  00040500
*FOR LR, LENGTH FIELD CONTAINS SD'S ESDID                               00040600
         MVC   (LEN-ESD)(2,4),14(1) MOVE THE ID OF THE SD               00040700
         MVI   (S0-ESD)(4),LD INDICATE LR                               00040800
         SPACE 3                                                        00040900
ESDMOVE  MVC   (NM-ESD)(8,4),0(1) MOVE CSECT NAME                       00041000
         CLC   0(8,1),HEADER+16                                         00041100
         BNE   *+8                                                      00041200
         MVI   NOP3+1,0                                                 00041300
         MVC   (ADDR-ESD+1)(3,4),9(1) AND LENGTH OF CSECT               00041400
         NI    (S0-ESD)(4),255-NULL                                     00041500
         CLI   (NM-ESD)(4),C'$' HAL PROCEDURE                           00041600
         BNE   *+12                                                     00041700
         OI    (S0-ESD)(4),$T                                           00041800
         B     ESDLEND                                                  00041900
         CLI   (NM-ESD)(4),C'@'                                         00042000
         BNE   *+8                                                      00042100
         OI    (S0-ESD)(4),@T                                           00042200
         SPACE 3                                                        00042300
ESDLEND  LA    1,16(0,1) NEXT CSECT                                     00042400
         LA    2,1(0,2) ESDID                                           00042500
         BCT   3,ESDLOOP                                                00042600
         SPACE 3                                                        00042700
         MYGET SYSLIN                                                   00042800
         CLI   0(1),X'20'                                               00042900
         BE    CESD2                                                    00043000
         SPACE 3                                                        00043100
*END OF CESD'S                                                          00043200
         LA    3,ESDLENTH                                               00043300
         MH    3,MAXESD                                                 00043400
         AR    3,10 ALLOCATE SPACE FOR RLD ITEMS                        00043500
NOXREF   B     *+18                                                     00043600
         ST    3,ACHARS                                                 00043700
         LA    4,NAMELEN                                                00043800
         MH    4,MAXESD                                                 00043900
         AR    3,4                                                      00044000
         ST    3,ARLD                                                   00044100
         SR    3,10           TOTAL BYTES OCCUPIED BY TABLES            00044200
         S     3,ABUFF+4            COMPUTE FREE SPACE LEFT             00044300
         LCR   3,3                                                      00044400
         SRA   3,2 /4=# OF ENTRIES                                      00044500
         STH   3,MAXRLD                                                 00044600
         BH    FINDX                                                    00044700
         SPACE 3                                                        00044800
SPACE    LA    15,NOSPACE                                               00044900
         B     RETURN                                                   00045000
         SPACE 3                                                        00045100
FINDX    DC    0H'0'                                                    00045200
*FIND THE ESDID FOR TERMPCB, EVENTPRO AND TIMECANC                      00045300
         LH    4,MAXESD                                                 00045400
         LR    9,10                                                     00045500
         LA    8,1 ESDID #                                              00045600
         SPACE                                                          00045700
FINDTHEM DC    0H'0'                                                    00045800
         CLC   0(8,9),=CL8'PROGINT'                                     00045900
         BNE   *+12                                                     00046000
         STH   8,#PROGINT                                               00046100
         B     FINDEND                                                  00046200
         CLC   0(8,9),=CL8'TIMEINT '                                    00046300
         BNE   *+8                                                      00046400
         STH   8,#TIME                                                  00046500
FINDEND  DC    0H'0'                                                    00046600
         LA    8,1(0,8)                                                 00046700
         LA    9,ESDLENTH(0,9)                                          00046800
         BCT   4,FINDTHEM                                               00046900
         B     READREC1                                                 00047000
         EJECT                                                          00047100
TEXTPROC MYGET SYSLIN PROCESS THE TEXT CARDS                            00047200
         LH    8,#CTL # OF ENTRIES FROM CTL REC                         00047300
         SRL   8,2                                                      00047400
         LA    7,CTLTABLE                                               00047500
         L     15,CCW ADDRESS OF FIRST BYTE OF TEXT                     00047600
         LR    14,1 ADDRESS OF BUFFER                                   00047700
         SPACE 3                                                        00047800
CTLPROC  LH    4,0(0,7)                                                 00047900
         BCTR  4,0                                                      00048000
         LR    1,4 SAVE FOR LATER USE                                   00048100
         MH    4,ESDLEN DISP INTO TABLE                                 00048200
         AR    4,10                                                     00048300
         C     15,(ADDR-ESD)(0,4) ARE WE AT FIRST BYTE OF CSECT         00048400
         BNE   CTLPROC1 NO, IGNORE                                      00048500
         TM    (S0-ESD)(4),@T PROCESS OR NOT                            00048600
         BNZ   NOPROC                                                   00048700
         SPACE 3                                                        00048800
*VALIDATA DATA.  IF VALID PLACE INTO TABLES, ELSE MARK CSECT AS NOTHAL  00048900
*        PRINT ON                                                       00049000
         CLC   0(3,14),=X'47F0F0' BRANCH AROUND                         00049100
         BNE   NOPROC                                                   00049200
         CLI   10(14),32 CHAR LENGTH <=32 AND >0                        00049300
         BH    NOPROC                                                   00049400
         SR    6,6                                                      00049500
         IC    6,10(0,14)                                               00049600
         LTR   6,6                                                      00049700
         BZ    NOPROC                                                   00049800
         BCTR  6,0                                                      00049900
         EX    6,TRTTEST ALL CHARS VALID                                00050000
         BNZ   NOPROC                                                   00050100
         LA    6,12(0,6) CHECK BRANCH DESTINATION                       00050200
         TM    10(14),1                                                 00050300
         BO    *+8                                                      00050400
         LA    6,1(0,6)                                                 00050500
         EX    6,CLITEST                                                00050600
         BNE   NOPROC                                                   00050700
         CH    6,2(0,7) CSECT LENGTH > BRNACH ADDR                      00050800
         BNL   NOPROC                                                   00050900
         SPACE 3                                                        00051000
*REASONABLY SURE THIS IS A VAILD HAL PROGRAM OR SUBR                    00051100
         LH    6,8(0,14) STACK LENGTH                                   00051200
         LTR   6,6                                                      00051300
         BNH   NOPROC                                                   00051400
         LA    6,7(0,6) ENSURE DOUBLE WORD LENGTH STACKS                00051500
         N     6,=X'0000FFF8'                                           00051600
         CLI   (NM-ESD)(4),C'#'                                         00051700
         BNE   CLI1                                                     00051800
         CLI   (NM-ESD+1)(4),C'C'                                       00051900
         BNE   NOPROC                                                   00052000
         B     MOVE                                                     00052100
CLI1     DC    0H'0'                                                    00052200
         CLI   (NM-ESD)(4),C'A'                                         00052300
         BL    MOVE                                                     00052400
         CLI   (NM-ESD+1)(4),240                                        00052500
         BL    MOVE                                                     00052600
         CLI   (NM-ESD+2)(4),240                                        00052700
         BNL   MOVE                                                     00052800
         OI    (S0-ESD)(4),INTPROC                                      00052900
MOVE     DC    0H'0'                                                    00053000
         B     *+18                                                     00053100
         MH    1,CHARLEN                                                00053200
         A     1,ACHARS                                                 00053300
         MVC   0(33,1),10(14)                                           00053400
         STH   6,(LEN-ESD)(0,4)                                         00053500
         NI    (S0-ESD)(4),255-NOTHAL                                   00053600
         L     6,4(0,14) IF ZERO, LIBRARY; NON ZERO THEN HAL            00053700
         LTR   6,6                                                      00053800
         BNZ   *+8                                                      00053900
         OI    (S1-ESD)(4),LIBRARY                                      00054000
         B     CTLPROC1                                                 00054100
*        PRINT OFF                                                      00054200
         SPACE 3                                                        00054300
NOPROC   OI    (S0-ESD)(4),NOTHAL+PROC MARK AS UNUSEABLE                00054400
         SPACE 3                                                        00054500
CTLPROC1 AH    14,2(0,7) LENGTH OF CESCT ADDED TO ORIGIN AND            00054600
         AH    15,2(0,7) BUFFER ADDRESS                                 00054700
         LA    7,4(0,7) BUMP ADDR OF CTL TABLE ENTRY                    00054800
         BCT   8,CTLPROC                                                00054900
         EJECT                                                          00055000
READREC  TM    S,STOPSW END OF ROAD                                     00055100
         BO    PHASE2                                                   00055200
         MYGET SYSLIN                                                   00055300
READREC1 CLI   0(1),1 CHECK TYPES: CTL                                  00055400
         BE    CTLREC                                                   00055500
         CLI   0(1),13 CTL EOM                                          00055600
         BNE   *+12                                                     00055700
         OI    S,STOPSW                                                 00055800
         B     CTLREC                                                   00055900
         CLI   0(1),2 RLD                                               00056000
         BE    RLDREC                                                   00056100
         CLI   0(1),14 RLD EOM                                          00056200
         BNE   *+12                                                     00056300
         OI    S,STOPSW                                                 00056400
         B     RLDREC                                                   00056500
         CLI   0(1),3 CTL RLD                                           00056600
         BE    CTLRLD                                                   00056700
         CLI   0(1),15 CTL RLD EOM                                      00056800
         BNE   READREC                                                  00056900
         OI    S,STOPSW                                                 00057000
         EJECT                                                          00057100
CTLRLD   LH    5,4(0,1) # BYTES CTL                                     00057200
         STH   5,#CTL                                                   00057300
         LH    6,6(0,1) # BYTES RLD                                     00057400
         STH   6,#RLD                                                   00057500
         LA    7,16(6,1) A(CTL INFO)                                    00057600
         BCTR  5,0                                                      00057700
         EX    5,CTLMVC MOVE CTL INFO TO TABLE                          00057800
         BCTR  6,0                                                      00057900
         EX    6,RLDMVC AND THE RLD                                     00058000
         MVC   CCW+1(3),9(1) ORIGIN OF TEXT                             00058100
         BAL   15,RLDPROC PROCESS RLD INFO                              00058200
         B     TEXTPROC PROCESS TEXT CARD                               00058300
         EJECT                                                          00058400
CTLREC   LH    6,4(0,1) # BYTES CTL INFO                                00058500
         LA    7,16(0,1)                                                00058600
         STH   6,#CTL                                                   00058700
         BCTR  6,0                                                      00058800
         EX    6,CTLMVC                                                 00058900
         MVC   CCW+1(3),9(1)                                            00059000
         B     TEXTPROC                                                 00059100
         EJECT                                                          00059200
RLDREC   LH    6,6(0,1)                                                 00059300
         STH   6,#RLD                                                   00059400
         BCTR  6,0                                                      00059500
         EX    6,RLDMVC                                                 00059600
         BAL   15,RLDPROC                                               00059700
         B     READREC                                                  00059800
         EJECT                                                          00059900
RLDPROC  LH    9,#RLD BYTE COUNT                                        00060000
         LA    8,RLDTABLE                                               00060100
RLDREC1  TM    FLAGS,1 SAME ID AS LAST                                  00060200
         BNO   RLDREC2                                                  00060300
H4       LA    7,4 ENTRY LENGTH = 4                                     00060400
         TM    0(8),16 V TYPE                                           00060500
         BZ    RLDREC5 NO, IGNORE                                       00060600
         B     RLDREC5 IGNORE ALL V TYPES                               00060700
         LH    5,OLDRP                                                  00060800
         LH    6,OLDRP+2 IF V TYPE, PROCESS (BUT RECURSIVE)             00060900
         BAL   1,CHASE CHASE DOWN ANY LR TYPES                          00061000
         B     RLDREC2A                                                 00061100
RLDREC2  LA    7,8 IF NOT SAME AS LAST, ENTRY LEN=8                     00061200
         LH    6,2(0,8) POS                                             00061300
         LH    5,0(0,8) REF                                             00061400
         BAL   1,CHASE CHASE DOWN ALL LR TYPES AGIN                     00061500
         CR    5,6 INTERNAL                                             00061600
         BNE   RLDREC2A                                                 00061700
         TM    4(8),16 CHECK FLAG FOR V TYPE                            00061800
         BZ    RLDREC5 IF V TYPE, PROCESS ANYWAY                        00061900
         B     RLDREC5 KLUDGE BYPASSING IT ALL                          00062000
RLDREC2A DC    0H'0'                                                    00062100
RLDREC2B DC    0H'0'                                                    00062200
         LR    14,5                                                     00062300
         BCTR  14,0                                                     00062400
         MH    14,ESDLEN                                                00062500
         AR    14,10                                                    00062600
         TM    (S0-ESD)(14),@T+NULL                                     00062700
         BNZ   RLDREC5 IF SPECIAL, DO NOT INCLUDE                       00062800
         BCTR  6,0                                                      00062900
         MH    6,ESDLEN                                                 00063000
         LA    6,(CHAIN-ESD)(6,10)                                      00063100
         SPACE 3                                                        00063200
RLDREC3  CH    5,2(0,6) SAME REF                                        00063300
         BE    RLDREC5                                                  00063400
         LH    14,0(0,6) GET CHAIN PTR                                  00063500
         SLA   14,2                                                     00063600
         BZ    RLDREC4 IF NOT CHAINED, ADD TO TABLE                     00063700
         A     14,ARLD FOLLOW CHAIN                                     00063800
         LR    6,14                                                     00063900
         B     RLDREC3                                                  00064000
         SPACE 3                                                        00064100
RLDREC4  LA    14,1 PUT NEW ENTRY ONTO CHAIN                            00064200
         AH    14,NEXTRLD                                               00064300
         STH   14,NEXTRLD                                               00064400
         CH    14,MAXRLD                                                00064500
         BNL   SPACE TOO MANY --> DIE                                   00064600
         STH   14,0(0,6) CHAIN NEX ENTRY ONTO OLD                       00064700
         SLL   14,2                                                     00064800
         A     14,ARLD                                                  00064900
         ST    5,0(0,14) SAVE REF, SET CHAIN=0                          00065000
         SPACE 3                                                        00065100
RLDREC5  DC    0H'0'                                                    00065200
         CH    7,H4+2                                                   00065300
         BNE   NOTSHORT                                                 00065400
         MVC   FLAGS(1),0(8)                                            00065500
         B     COMMON                                                   00065600
NOTSHORT DC    0H'0'                                                    00065700
         MVC   OLDRP(4),0(8)                                            00065800
         MVC   FLAGS(1),4(8)                                            00065900
COMMON   DC    0H'0'                                                    00066000
         AR    8,7                                                      00066100
         SR    9,7 7 HAS LENGTH IN IT, REMEMBER                         00066200
         BH    RLDREC1 MORE??                                           00066300
         BR    15 NO,RETURN                                             00066400
         SPACE 3                                                        00066500
CHASE    LR    14,5 CHASE DOWN ANY LR'S TO THE SD                       00066600
         BCTR  14,0                                                     00066700
         MH    14,ESDLEN                                                00066800
         AR    14,10                                                    00066900
         TM    (S0-ESD)(14),LD                                          00067000
         BCR   14,1 RETURN ON NOT ONE ---> NOT LR TYPE                  00067100
         LH    5,(LEN-ESD)(0,14) YUP, POINT TO SD                       00067200
         BR    1                                                        00067300
         EJECT                                                          00067400
PHASE2   LH    0,MAXESD                                                 00067500
         OI    S,COMP+NC INDICATE COMPLETE + NO CHANGE                  00067600
         LR    1,10                                                     00067700
         SPACE 3                                                        00067800
L1       TM    (S0-ESD)(1),PROC+NOTHAL NEED WE CONSIDER                 00067900
         BNZ   L1END                                                    00068000
         SR    3,3 SET MAX CALLED LENGTH=0                              00068100
         LH    2,(CHAIN-ESD)(0,1) IDOES HE CALL ANYONE                  00068200
         LTR   2,2                                                      00068300
         BH    L1A                                                      00068400
         OI    (S0-ESD)(1),PROC TERMINAL NODE, MARK AS DONE             00068500
         NI    S,255-NC INDICATE CHANGE                                 00068600
         B     L1END NOTE THAT THE LENGTH VALUE IN TABLE IS VALID       00068700
         SPACE 3                                                        00068800
L1A      SLL   2,2 FOLLOW CHAIN                                         00068900
         LR    4,2                                                      00069000
         A     4,ARLD                                                   00069100
         LH    2,0(0,4) NEXT CHAIN                                      00069200
         LH    4,2(0,4) ESDID                                           00069300
         SPACE 3                                                        00069400
L1B      BCTR  4,0                                                      00069500
         MH    4,ESDLEN                                                 00069600
         AR    4,10                                                     00069700
         TM    (S0-ESD)(4),LD IS LEN FIELD ACTUALLY A PTR               00069800
         BNO   L1C                                                      00069900
         LH    4,(LEN-ESD)(0,4) REFER TO SD                             00070000
         B     L1B                                                      00070100
         SPACE 3                                                        00070200
L1C      TM    (S0-ESD)(4),NOTHAL+$T+@T SHOULD WE PROCESS               00070300
         BNZ   L1E                                                      00070400
         TM    (S0-ESD)(4),PROC LENGTH FIELD VALID                      00070500
         BO    L1D YES                                                  00070600
         NI    S,255-COMP MARK SCAN AS INCOMPLETE                       00070700
         B     L1END                                                    00070800
         SPACE 3                                                        00070900
L1D      CH    3,(LEN-ESD)(0,4) COMPUTE MAX(OLDMAX,LENGTH)              00071000
         BNL   *+8                                                      00071100
         LH    3,(LEN-ESD)(0,4)                                         00071200
         SPACE 3                                                        00071300
L1E      SLA   2,2 CHAINED                                              00071400
         BNZ   L1A+4 YUP, FOLLOW....                                    00071500
         SPACE 3                                                        00071600
         AH    3,(LEN-ESD)(0,1) ADD MAX TO REAL LENGTH                  00071700
         STH   3,(LEN-ESD)(0,1)                                         00071800
         OI    (S0-ESD)(1),PROC MARK                                    00071900
         NI    S,255-NC INDICATE A CHANGE HAS OCCURED                   00072000
         SPACE 3                                                        00072100
L1END    LA    1,ESDLENTH(0,1) NEXT ESD                                 00072200
         BCT   0,L1                                                     00072300
         EJECT                                                          00072400
*PASS COMPLETE, CHECK STUFF                                             00072500
         TM    S,COMP COMPLETED EVERYTHING                              00072600
         BO    PHASE3 YES, AND NO RECURSION                             00072700
         TM    S,NC NO CHANGE --> RECURSION                             00072800
         BZ    PHASE2                                                   00072900
         EJECT                                                          00073000
RC1      LR    4,10 ASSIGN TO ALL RECURSIVE FELLOWS A STACK             00073100
         LH    7,MAXESD LENGTH OF 32760 AND PRINT THEM OUT              00073200
         SPACE 3                                                        00073300
RC2      TM    (S0-ESD)(4),PROC                                         00073400
         BO    RCEND                                                    00073500
         TM    (S0-ESD)(4),$T                                           00073600
         BNO   RCEND                                                    00073700
         SPACE 3                                                        00073800
         OI    S,REALREC                                                00073900
RC2A     DC    0H'0'                                                    00074000
         BAL   9,PRINTER                                                00074100
         MVC   1(L'RECMSG,1),RECMSG                                     00074200
         BAL   9,PRINTER                                                00074300
         SPACE 3                                                        00074400
RC3      LR    2,4                                                      00074500
RC3A     MVC   (LEN-ESD)(2,2),RECLEN                                    00074600
RC3B     DC    0H'0'                                                    00074700
         BAL   8,PCALLED                                                00074800
RC3C     TM    (S0-ESD)(2),RECURSIV                                     00074900
         BNO   *+16                                                     00075000
         L     1,PADDR                                                  00075100
         MVI   0(1),25 WRITE,SKIP 3 AFTER                               00075200
         B     RCEND                                                    00075300
         OI    (S0-ESD)(2),PROC+RECURSIV                                00075400
         LH    6,(CHAIN-ESD)(0,2) FIND FIRST CALLED WHICH IS RECURSIVE  00075500
RC6      SLL   6,2 NOT RECURSIVE, TRY NEXT                              00075600
         A     6,ARLD                                                   00075700
         SPACE 3                                                        00075800
RC4      LH    5,2(0,6)                                                 00075900
         LH    6,0(0,6)                                                 00076000
RC4A     BCTR  5,0                                                      00076100
         MH    5,ESDLEN                                                 00076200
         AR    5,10                                                     00076300
         TM    (S0-ESD)(5),LD                                           00076400
         BNO   RC5                                                      00076500
         LH    5,(LEN-ESD)(0,5)                                         00076600
         B     RC4A                                                     00076700
         SPACE 3                                                        00076800
RC5      LR    2,5                                                      00076900
         TM    (S0-ESD)(2),RECURSIV                                     00077000
         BO    RC3B                                                     00077100
         TM    (S0-ESD)(2),PROC                                         00077200
         BZ    RC3A                                                     00077300
         B     RC6                                                      00077400
         SPACE 3                                                        00077500
         SPACE 3                                                        00077600
RCEND    LA    4,ESDLENTH(0,4)                                          00077700
         BCT   7,RC2                                                    00077800
         SPACE 3                                                        00077900
         EJECT                                                          00078000
PHASE3   NOP   PHASE4                                                   00078100
         LR    2,10                                                     00078200
         LH    6,MAXESD PRINT OUT TREE                                  00078300
         SPACE 3                                                        00078400
PHASE3A  TM    (S0-ESD)(2),@T+LD+NULL DON'T PRINT THESE                 00078500
         BNZ   PHASE3E                                                  00078600
         LR    7,2                                                      00078700
         TRT   (NM-ESD)(8,2),VALIDCHR                                   00078800
         BNZ   PHASE3C                                                  00078900
         CLC   (NM-ESD)(8,2),BLANKS OR BLANKS                           00079000
         BE    PHASE3C                                                  00079100
         BAL   8,PCALLER PRINT OUT CALLER'S NAME                        00079200
         LH    4,(CHAIN-ESD)(0,2) CALLS ANYONE                          00079300
         BALR  8,0 THINK ABOUT IT A WHILE                               00079400
         SPACE 3                                                        00079500
PHASE3B  SLA   4,2                                                      00079600
         BZ    PHASE3C END OF LIST OF CALLED                            00079700
         A     4,ARLD                                                   00079800
         LH    2,2(0,4)                                                 00079900
         LH    4,0(0,4)                                                 00080000
         BCTR  2,0                                                      00080100
         MH    2,ESDLEN                                                 00080200
         AR    2,10                                                     00080300
         TRT   (NM-ESD)(8,2),VALIDCHR                                   00080400
         BCR   7,8                                                      00080500
         B     PCALLED PRINT OUT CALLED                                 00080600
         SPACE 3                                                        00080700
PHASE3C  LR    2,7                                                      00080800
PHASE3E  LA    2,ESDLENTH(2,0) NEXT CSECT                               00080900
ESDLEN   EQU   PHASE3E+2                                                00081000
         BCT   6,PHASE3A                                                00081100
         EJECT                                                          00081200
PHASE4   DC    0H'0'                                                    00081300
         SR    0,0 COMPUTE SIZE TO BE ADDED                             00081400
PHASE4A1 LH    1,#TIME =MAX(PROGINT,TIMEENQ)                            00081500
         LTR   1,1                                                      00081600
         BNH   PHASE4A2                                                 00081700
         BCTR  1,0                                                      00081800
         MH    1,ESDLEN                                                 00081900
         AR    1,10                                                     00082000
         LH    0,(LEN-ESD)(0,1)                                         00082100
PHASE4A2 LH    1,#PROGINT                                               00082200
         LTR   1,1                                                      00082300
         BNH   PHASE4A3                                                 00082400
         BCTR  1,0                                                      00082500
         MH    1,ESDLEN                                                 00082600
         AR    1,10                                                     00082700
         CH    0,(LEN-ESD)(0,1)                                         00082800
         BNL   *+8                                                      00082900
         LH    0,(LEN-ESD)(0,1)                                         00083000
PHASE4A3 DC    0H'0'                                                    00083100
         STH   0,ADDED                                                  00083200
         SPACE 3                                                        00083300
PHASE4C  EQU   *                                                        00083400
NOP2     NOP   NOP3                                                     00083500
         PUT   SYSGO                                                    00083600
         MVC   0(80,1),INCLUDE                                          00083700
         MVC   (FILENAME-INCLUDE)(20,1),(FILENAME-INCLUDE-1)(1)         00083800
         MVC   9(8,1),SYSLIB                                            00083900
CLI2     CLI   10(1),C' '                                               00084000
         BE    MOVEMBR                                                  00084100
         LA    1,1(0,1)                                                 00084200
         B     CLI2                                                     00084300
MOVEMBR  MVC   10(10,1),=CL10'(HALSTART)'                               00084400
NOP3     NOP   PHASE4C1  PUNCH OUT HALMAP                               00084500
         PUT   SYSGO                                                    00084600
         MVC   0(LHEADER,1),HEADER                                      00084700
         MVC   LHEADER(80-LHEADER,1),LHEADER-1(1)                       00084800
         LA    5,4 CSECT ADDRESS                                        00084900
         SR    6,6                                                      00085000
         SR    7,7                                                      00085100
         LA    3,2 ESDID                                                00085200
         LH    4,MAXESD                                                 00085300
         LR    9,10                                                     00085400
HALCLI   TM    (S0-ESD)(9),$T                                           00085500
         BNO   HALCLI2                                                  00085600
         LA    6,1(0,6) NUMBER OF PCBS                                  00085700
         CLI   (NM-ESD+1)(9),C'0'                                       00085800
         BNE   ESDBCT                                                   00085900
         LA    8,1                                                      00086000
         B     PUTESD                                                   00086100
HALCLI2  DC    0H'0'                                                    00086200
         SR    8,8                                                      00086300
         CLC   (NM-ESD)(2,9),=CL2'#P'                                   00086400
         BE    PUTESD                                                   00086500
         CLC   (NM-ESD)(2,9),=CL2'#C'                                   00086600
         LA    8,3                                                      00086700
         BNE   ESDBCT                                                   00086800
PUTESD   PUT   SYSGO                                                    00086900
         MVC   0(LHALESD,1),HALESD                                      00087000
         MVC   LHALESD(80-LHALESD,1),LHALESD-1(1)                       00087100
         MVC   16(8,1),(NM-ESD)(9)                                      00087200
         STH   3,14(0,1)                                                00087300
         MVI   24(1),2                                                  00087400
         PUT   SYSGO                                                    00087500
         MVC   0(LHALTXT,1),HALTXT                                      00087600
         MVC   LHALTXT(80-LHALTXT,1),LHALTXT-1(1)                       00087700
         MVC   22(6,1),(NM-ESD+2)(9)                                    00087800
         MVC   20(2,1),=CL2'##'                                         00087900
         ST    5,4(0,1)                                                 00088000
         MVI   4(1),C' '                                                00088100
STORTYPE STC   8,16(0,1)                                                00088200
         PUT   SYSGO                                                    00088300
         MVC   0(LHALRLD,1),HALRLD                                      00088400
         MVC   LHALRLD(80-LHALRLD,1),LHALRLD-1(1)                       00088500
         STH   3,16(0,1)                                                00088600
         ST    5,20(0,1)                                                00088700
         OI    23(1),1                                                  00088800
         MVI   20(1),X'18'                                              00088900
         LA    5,12(0,5)                                                00089000
         LA    3,1(0,3)                                                 00089100
         LA    7,1(0,7) NUMBER OF ENTRIES IN HALMAP                     00089200
ESDBCT   LA    9,ESDLENTH(0,9)                                          00089300
         BCT   4,HALCLI                                                 00089400
HLEND    PUT   SYSGO                                                    00089500
         MVC   0(LHALTXT,1),HALTXT                                      00089600
         MVC   LHALTXT(80-LHALTXT,1),LHALTXT-1(1)                       00089700
         MVI   11(1),4                                                  00089800
         ST    6,16(0,1)                                                00089900
         STH   7,16(0,1)                                                00090000
         SR    6,6                                                      00090100
         ST    6,4(0,1)                                                 00090200
         MVI   4(1),C' '                                                00090300
         PUT   SYSGO                                                    00090400
         MVC   0(LENDCARD,1),ENDCARD                                    00090500
         MVC   LENDCARD(80-LENDCARD,1),LENDCARD-1(1)                    00090600
         ST    5,28(0,1)                                                00090700
         SPACE 3                                                        00090800
PHASE4C1 LH    7,MAXESD                                                 00090900
         LR    6,10                                                     00091000
         LH    5,ADDED                                                  00091100
         LA    3,1 ESDID                                                00091200
         SR    4,4 ADDRESS                                              00091300
         SPACE 3                                                        00091400
PHASE4D  DC    0H'0'                                                    00091500
         TM    (S0-ESD)(6),$T                                           00091600
         BNO   PHASE4F                                                  00091700
PHASE4E  DC    0H'0'                                                    00091800
         LH    2,(LEN-ESD)(0,6)                                         00091900
         AR    2,5 ADD IN PROGINT BUMP COUNT                            00092000
         STH   3,ESDCARD+14 ESDID                                       00092100
         MVC   ESDCARD+17(7),(NM+1-ESD)(6)  MOVE CSECT NAME             00092200
         MVI   ESDCARD+16,C'@' MARK AS STACK                            00092300
         ST    4,ESDCARD+16+8 ADDRESS                                   00092400
         ST    2,ESDCARD+16+8+4 LENGTH                                  00092500
         MVI   ESDCARD+16+8+4,C' '                                      00092600
         AR    4,2 NEXT CSECT ADDRESS                                   00092700
H1       LA    3,1(3,0)                                                 00092800
         PUT   SYSGO                                                    00092900
         MVC   0(80,1),ESDCARD                                          00093000
         SPACE 3                                                        00093100
PHASE4F  LA    6,ESDLENTH(0,6)                                          00093200
         BCT   7,PHASE4D                                                00093300
         SPACE 3                                                        00093400
         SRA   3,1                                                      00093500
         BZ    A## IF NO CSECT EMITTED, NO END CARD                     00093600
         PUT   SYSGO                                                    00093700
         MVC   0(LENDCARD,1),ENDCARD                                    00093800
         MVC   LENDCARD(80-LENDCARD,1),LENDCARD-1(1)                    00093900
         SPACE 3                                                        00094000
*EMIT INCLUDE CARD FOR THE FILE AND MEMBER SPACIFIED                    00094100
A##      LA    1,FILENAME+1                                             00094200
A#       CLI   0(1),C' '                                                00094300
         BE    B#                                                       00094400
         LA    1,1(0,1)                                                 00094500
         B     A#                                                       00094600
B#       MVI   0(1),C'('                                                00094700
         MVC   1(8,1),MEMBR                                             00094800
C#       CLI   2(1),C' '                                                00094900
         BE    D#                                                       00095000
         LA    1,1(0,1)                                                 00095100
         B     C#                                                       00095200
D#       MVI   2(1),C')'                                                00095300
         PUT   SYSGO                                                    00095400
         MVC   0(80,1),INCLUDE                                          00095500
         PUT   SYSGO                                                    00095600
         MVC   0(16,1),=CL16' ENTRY HALSTART '                          00095700
         MVC   16(64,1),15(1) BLANK OUT REST OF CARD                    00095800
         CLC   MEMBR(8),=CL8'TEMPNAME' EMIT NAME(R) CARD IF MEMBR NOT   00095900
         BE    LAST TEMPNAME                                            00096000
         PUT   SYSGO                                                    00096100
         MVC   0(6,1),=CL6' NAME '                                      00096200
         MVC   6(74,1),5(1) BLANK REST OUT                              00096300
         MVC   6(8,1),MEMBR                                             00096400
         LA    2,8                                                      00096500
E#       CLI   7(1),C' ' LOOK FOR BLANK, REPLACE WITH (R)               00096600
         BE    F#                                                       00096700
         LA    1,1(0,1)                                                 00096800
         BCT   2,E#                                                     00096900
         BCTR  1,0                                                      00097000
F#       MVC   7(3,1),=C'(R)'                                           00097100
         EJECT                                                          00097200
LAST     DC    0H'0'                                                    00097300
NOP9     NOP   NOXREFP                                                  00097400
         MVC   DOUBLE(ESDLENTH),0(10)                                   00097500
         MVI   (S0-ESD)(10),0                                           00097600
         MVC   (NM-ESD)(8,10),=CL8'***ADDED'                            00097700
         MVC   (LEN-ESD)(2,10),ADDED                                    00097800
         LR    2,10                                                     00097900
         BAL   8,PCALLER                                                00098000
         MVC   0(ESDLENTH,10),DOUBLE                                    00098100
         EJECT                                                          00098200
NOXREFP  DC    0H'0'                                                    00098300
         B     NOXREFE                                                  00098400
         MVC   HEADING(L'HEADING),XREFH                                 00098500
         MVI   PAGECT+3,1                                               00098600
         LR    5,10                                                     00098700
         L     8,ACHARS                                                 00098800
         LH    6,MAXESD                                                 00098900
         LA    4,=CL10'(HALSTART)'                                      00099000
NOXREF1  TM    (S0-ESD)(5),NOTHAL+LD                                    00099100
         BNZ   NOXREF2                                                  00099200
         TM    (S1-ESD)(5),LIBRARY                                      00099300
         BNZ   NOXREF2                                                  00099400
         CLC   (NM-ESD)(8,5),1(4) IF HALSTART, DONT PRINT               00099500
         BE    NOXREF2                                                  00099600
         BAL   9,PRINTER                                                00099700
         MVC   2(8,1),(NM-ESD)(5)                                       00099800
         IC    7,(CHARLENX-NAMES)(0,8)                                  00099900
         BCTR  7,0                                                      00100000
         EX    7,XREFMVC                                                00100100
NOXREF2  LA    5,ESDLENTH(0,5)                                          00100200
NOXREF3  LA    8,NAMELEN(8,0)                                           00100300
CHARLEN  EQU   NOXREF3+2                                                00100400
         BCT   6,NOXREF1                                                00100500
NOXREFE  DC    0H'0'                                                    00100600
         EJECT                                                          00100700
PHASE5   TM    SYMS,ERRORSYM                                            00100800
         LA    15,SYMERROR                                              00100900
         BO    RETURN                                                   00101000
         TM    SYMS,UNDEFSYM                                            00101100
         LA    15,SYMUNDEF                                              00101200
         BO    RETURN                                                   00101300
         TM    SYMS,SYM2VER                                             00101400
         LA    15,TWOVER                                                00101500
         BO    RETURN                                                   00101600
         TM    S,REALREC                                                00101700
         LA    15,RECFOUND                                              00101800
BRANCH3  BO    RETURN                                                   00101900
         LA    15,0                                                     00102000
         BZ    *+8                                                      00102100
         LA    15,4                                                     00102200
RETURN   ST    15,RCODE                                                 00102300
         SPACE 3                                                        00102400
         TM    SYSPRINT+48,16                                           00102500
         BZ    PHASE5A                                                  00102600
         CLOSE (SYSPRINT)                                               00102700
         FREEPOOL SYSPRINT                                              00102800
PHASE5A  TM    SYSGO+48,16                                              00102900
         BZ    PHASE5B                                                  00103000
         CLOSE (SYSGO)                                                  00103100
         FREEPOOL SYSGO                                                 00103200
PHASE5B  TM    SYSLINP+48,16                                            00103300
         BZ    PHASE5C                                                  00103400
         CLOSE (SYSLINP)                                                00103500
         LM    0,1,SYSLINBL                                             00103600
         FREEMAIN R,LV=(0),A=(1)                                        00103700
PHASE5C  LM    0,1,ABUFF                                                00103800
         XR    1,0                                                      00103900
         XR    0,1                                                      00104000
         XR    1,0                                                      00104100
         LA    1,0(0,1)                                                 00104200
         BZ    PHASE5D                                                  00104300
         FREEMAIN R,LV=(0),A=(1)                                        00104400
PHASE5D  L     15,RCODE                                                 00104500
         L     13,OSSAVE+4                                              00104600
         RETURN (14,12),RC=(15)                                         00104700
         EJECT                                                          00104800
PCALLER  BAL   9,PRINTER GET NEXT LINE                                  00104900
         MVC   2(8,1),(NM-ESD)(2) MOVE CSECT NAME                       00105000
         TM    (S0-ESD)(2),INTPROC                                      00105100
         BZ    *+8                                                      00105200
         MVI   1(1),C'*'                                                00105300
         TM    (S0-ESD)(2),LD+NOTHAL                                    00105400
         BNZ   *+16                                                     00105500
         UNPK  11(5,1),(LEN-ESD)(3,2) SUPPLY HEX LENGTH ALSO            00105600
         TR    11(4,1),TRCHAR-240                                       00105700
         MVI   15(1),C' '                                               00105800
         BR    8                                                        00105900
         SPACE 3                                                        00106000
PCALLED  DC    0H'0'                                                    00106100
PCALLED2 DC    0H'0'                                                    00106200
         TRT   (NM-ESD)(8,2),VALIDCHR                                   00106300
         BCR   7,8                                                      00106400
         CLC   (NM-ESD)(8,2),BLANKS                                     00106500
         BCR   8,8                                                      00106600
         L     3,LINECT                                                 00106700
         BCT   3,*+8                                                    00106800
         BAL   9,PRINTER IF MORE THAN 9 CALLED                          00106900
         ST    3,LINECT                                                 00107000
         L     1,PADDR A(PRINT BUFFER)                                  00107100
         MVC   22(8,1),(NM-ESD)(2)                                      00107200
         TM    (S0-ESD)(2),INTPROC                                      00107300
         BNO   *+8                                                      00107400
         MVI   21(1),C'*'                                               00107500
         LA    1,10(0,1) UP BUFFER ADDRESS                              00107600
         ST    1,PADDR                                                  00107700
         BR    8                                                        00107800
         SPACE 3                                                        00107900
PRINTER  PUT   SYSPRINT                                                 00108000
         L     3,PAGECT SKIP TO TOP IF NEEDED                           00108100
         BCT   3,PRINTER1                                               00108200
G##      MVI   0(1),X'8B' SKIP TO CHANNEL 1 IMMED                       00108300
         MVI   G##+1,X'89'                                              00108400
         MVI   1(1),C' ' BLANK OUT REST OF LINE                         00108500
         MVC   2(119,1),1(1) BLANK OUT LINE                             00108600
H##      DC    0H'0'                                                    00108700
         PUT   SYSPRINT                                                 00108800
         MVC   0(1+L'HEADING,1),SKIPTWO                                 00108900
         MVC   1+L'HEADING(121-1-L'HEADING,1),L'HEADING(1) BLANK REST   00109000
         MVI   PAGECT+3,50                                              00109100
         B     PRINTER                                                  00109200
PRINTER1 ST    1,PADDR                                                  00109300
         ST    3,PAGECT                                                 00109400
         MVI   LINECT+3,10                                              00109500
         LA    3,9                                                      00109600
         MVC   0(2,1),=X'0940' WRITE, SKIP ONE AFTER AND A BLANK        00109700
         MVC   2(119,1),1(1) BLANK REST                                 00109800
         BR    9                                                        00109900
GETRECRD ST    2,REG2                                                   00110000
         ST    15,RETADDRF                                              00110100
         L     2,SYSLINBA                                               00110200
         READ  DECB,SF,SYSLINP,(2),'S'                                  00110300
         CHECK DECB                                                     00110400
         LR    1,2 BUFFER ADDRESS                                       00110500
         L     15,RETADDRF                                              00110600
         BR    15                                                       00110700
RETADDRF DC    A(0)                                                     00110800
REG2     DC    A(0)                                                     00110900
         EJECT                                                          00111000
NMMVC    MVC   (NM-ESD)(0,4),11(14)                                     00111100
XREFMVC  MVC   22(0,1),(CHARNAME-NAMES)(8)                              00111200
TRTTEST  TRT   11(0,14),VALIDCHR                                        00111300
CLITEST  CLI   3(14),0                                                  00111400
CTLMVC   MVC   CTLTABLE(0),0(7)                                         00111500
RLDMVC   MVC   RLDTABLE(0),16(1)                                        00111600
SYMMVC   MVC   SYMBUFFV(0),3(3)                                         00111700
         EJECT                                                          00111800
DOUBLE   DC    7D'0'                                                    00111900
SYMNA    DC    A(0)                                                     00112000
SYMCA    DC    A(0)                                                     00112100
RCODE    DC    F'0'                                                     00112200
PADDR    DC    A(0)                                                     00112300
ARLD     DC    A(0)                                                     00112400
ABUFF    DC    A(0,0)                                                   00112500
ACHARS   DC    A(0)                                                     00112600
OLDRP    DC    A(0)                                                     00112700
SIZES    DC    A(64*1024,128*1024) 16K MIN TO 64K MAX                   00112800
CCW      DC    A(0)                                                     00112900
PAGECT   DC    A(1)                                                     00113000
LINECT   DC    A(0)                                                     00113100
MAXESD   DC    H'0'                                                     00113200
SYMCOUNT DC    H'1'                                                     00113300
SYMMAX   DC    H'0'                                                     00113400
#CTL     DC    H'0'                                                     00113500
#RLD     DC    H'0'                                                     00113600
NEXTRLD  DC    H'0'                                                     00113700
ADDED    DC    H'0'                                                     00113800
RECLEN   DC    0H'0',XL2'7FF8'                                          00113900
#TIME    DC    H'-1'                                                    00114000
#PROGINT DC    H'-1'                                                    00114100
MAXESDID DC    H'0'                                                     00114200
MAXRLD   DC    H'0'                                                     00114300
S        DC    X'00'                                                    00114400
STOPSW   EQU   X'80'                                                    00114500
COMP     EQU   X'40'                                                    00114600
NC       EQU   X'20'                                                    00114700
REALREC  EQU   X'10'                                                    00114800
FLAGS    DC    X'00'                                                    00114900
BLANKS   DC    CL8' '                                                   00115000
CTLTABLE DC    0F'0',XL236'00'                                          00115100
RLDTABLE DC    0F'0',XL256'00'                                          00115200
TRCHAR   DC    C'0123456789ABCDEF'                                      00115300
SYSLIB   DC    CL8'SYSLIB'                                              00115400
         DC    0F'0'                                                    00115500
ESDCARD  DC    X'02',C'ESD',CL6' '                                      00115600
         DC    AL2(16),CL2' ' # BYTES ESD DATA                          00115700
         DC    AL2(0) ESDID FIRST ITEM                                  00115800
         DC    CL64' '                                                  00115900
ENDCARD  DC    X'02',CL4'END'                                           00116000
LENDCARD EQU   *-ENDCARD                                                00116100
INCLUDE  DC    CL80' '                                                  00116200
         ORG   INCLUDE                                                  00116300
         DC    C' INCLUDE '                                             00116400
FILENAME DC    C'TEMPLOAD '                                             00116500
         ORG                                                            00116600
MEMBR    DC    XL8'00'                                                  00116700
HEADER   DC    X'02',CL9'ESD'                                           00116800
         DC    AL2(16),CL2'  ',AL2(1)                                   00116900
         DC    CL8'HALMAP',AL4(0),C' '                                  00117000
         DC    AL3(0),C' '                                              00117100
LHEADER  EQU   *-HEADER                                                 00117200
HALESD   DC    X'02',CL9'ESD'                                           00117300
         DC    AL2(16),C' '                                             00117400
LHALESD  EQU   *-HALESD                                                 00117500
HALTXT   DC    X'02',CL9'TXT'                                           00117600
         DC    AL2(12),CL2' '                                           00117700
         DC    AL2(1),C' '                                              00117800
LHALTXT  EQU   *-HALTXT                                                 00117900
HALRLD   DC    X'02',CL9'RLD'                                           00118000
         DC    AL2(8),CL4' '                                            00118100
         DC    AL2(0,1),C' '                                            00118200
LHALRLD  EQU   *-HALRLD                                                 00118300
         ORG                                                            00118400
RECMSG DC  C'ERROR ---- RECURSIVE CALLS INVOLVING THE FOLLOWING CSECTS' 00118500
SKIPTWO  DC    AL1(17) SKIP TWO AFTER PRINT                             00118600
HEADING  DC    C' CSECT   STACK       REFERENCED CSECTS   (* DENOTES IN*00118700
               TERNAL PROCEDURES) '                                     00118800
XREFH    DC    CL(L'HEADING)' CSECT NAME          PROGRAMMER SUPPLIED N*00118900
               AME'                                                     00119000
VALIDCHR DC    256X'01'                                                 00119100
         ORG   VALIDCHR+C'#'                                            00119200
         DC    X'00'                                                    00119300
         ORG   VALIDCHR+C' '                                            00119400
         DC    X'00'                                                    00119500
         ORG   VALIDCHR+C'$'                                            00119600
         DC    X'00'                                                    00119700
         ORG   VALIDCHR+C'_'                                            00119800
         DC    X'00'                                                    00119900
         ORG   VALIDCHR+C'A'                                            00120000
         DC    9X'00'                                                   00120100
         ORG   VALIDCHR+C'J'                                            00120200
         DC    9X'00'                                                   00120300
         ORG   VALIDCHR+C'S'                                            00120400
         DC    8X'00'                                                   00120500
         ORG   VALIDCHR+C'0'                                            00120600
         DC    10X'00'                                                  00120700
*        JUST FOR YOU ARRA                                              00120800
         ORG   VALIDCHR+X'81' LOWER CASE A                              00120900
         DC    9X'00'                                                   00121000
         ORG   VALIDCHR+X'91' LOWER CASE J                              00121100
         DC    9X'00'                                                   00121200
         ORG   VALIDCHR+X'A2' LOWER CASE S                              00121300
         DC    8X'00'                                                   00121400
         ORG                                                            00121500
         EJECT                                                          00121600
O2SYM    DC    X'02',C'SYM'                                             00121700
SYMSTART DC    X'25000000',C'HALS/S'                                    00121800
SYMS     DC    AL1(SEARCH)                                              00121900
SEARCH   EQU   X'80'                                                    00122000
ERRORSYM EQU   X'20'                                                    00122100
UNDEFSYM EQU   X'10'                                                    00122200
SYM2VER  EQU   X'08'                                                    00122300
SYMBUFFV DC    X'00'                                                    00122400
SYMBUFFN DC    CL8' '                                                   00122500
SYME1    DC    C'NO VERSION DEFINED FOR'                                00122600
SYME2    DC    CL8' ',C' COMPILED AS VERSION '                          00122700
SYMV1    DC    C'000 BUT REFERENCED BY '                                00122800
SYME2A   DC    CL8' ',C' AS VERSION '                                   00122900
SYMV2    DC    C'000'                                                   00123000
SYME2L   EQU   *-SYME2                                                  00123100
SYM2E    EQU   SYME2                                                    00123200
SYMN1    EQU   SYME2                                                    00123300
SYMN2    EQU   SYME2A                                                   00123400
SYM2EL   EQU   SYME2L                                                   00123500
SYMDUP   DC    C'DEFINED AS VERSIONS '                                  00123600
SYMDUPV1 DC    C'000 AND '                                              00123700
SYMDUPV2 DC    C'000.  SECOND IS IGNORED'                               00123800
SYMDUPL  EQU   *-SYMDUP                                                 00123900
         EJECT                                                          00124000
SYMCELL  DSECT                                                          00124100
SN       DS    CL8                                                      00124200
FP       DS    A                                                        00124300
BP       DS    A                                                        00124400
SYMLEN   EQU   *-SYMCELL                                                00124500
         SPACE 5                                                        00124600
NAMES    DSECT                                                          00124700
CHARLENX DS    X                                                        00124800
CHARNAME DS    CL32                                                     00124900
         DS    0F                                                       00125000
NAMELEN  EQU   *-NAMES                                                  00125100
         EJECT                                                          00125200
ESD      DSECT                                                          00125300
NM       DS    CL8                                                      00125400
ADDR     DS    A                                                        00125500
CHAIN    DS    H                                                        00125600
REFRLD   DS    H                                                        00125700
LEN      DS    H                                                        00125800
S0       DS    X                                                        00125900
PROC     EQU   X'80'                                                    00126000
@T       EQU   X'40'                                                    00126100
$T       EQU   X'20'                                                    00126200
NOTHAL   EQU   X'10'                                                    00126300
LD       EQU   X'08'                                                    00126400
NULL     EQU   X'04'                                                    00126500
RECURSIV EQU   X'02'                                                    00126600
INTPROC  EQU   X'01'                                                    00126700
S1       DS    X                                                        00126800
LIBRARY  EQU   X'80'                                                    00126900
         DS    0F                                                       00127000
ESDLENTH EQU   *-ESD                                                    00127100
         SPACE 3                                                        00127200
HALLKED  CSECT                                                          00127250
PATCH    DC    10D'0' MAKE PATCHES TO CODE HERE                         00127300
         SPACE 3                                                        00127400
         END   HALLKED                                                  00127500
