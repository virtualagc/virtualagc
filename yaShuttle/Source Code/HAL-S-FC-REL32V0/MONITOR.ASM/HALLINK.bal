*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    HALLINK.bal
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

LINK     TITLE 'HAL/S LINK EDITOR DRIVER PROGRAM'                       00000100
         MACRO                                                          00000200
&L       OPT   &C,&D                                                    00000300
         GBLA  &NUM,&X                                                  00000400
         AIF   (T'&C EQ 'O').END                                        00000500
&L       DC    AL1(L'QQ&SYSNDX-1)                                       00000600
QQ&SYSNDX      DC             C&C                                       00000700
         AIF   (T'&D EQ 'O').NOEQU                                      00000800
&D       EQU   &NUM                                                     00000900
.NOEQU   ANOP                                                           00001000
&NUM     SETA  &NUM+1                                                   00001100
         SPACE 2                                                        00001200
         MEXIT                                                          00001300
.END     AIF   (&X EQ 1).LAST                                           00001400
&X       SETA  1                                                        00001500
NUMOPT   EQU   &NUM                                                     00001600
         SPACE 2                                                        00001700
         MEXIT                                                          00001800
.LAST    ANOP                                                           00001900
NUMOPT2  EQU   &NUM                                                     00002000
         SPACE 3                                                        00002100
         MEND                                                           00002200
         SPACE 5                                                        00002300
         MACRO                                                          00002400
         PCRMSG &M                                                      00002500
         LA    7,&M               GET ADDRESS OF MESSAGE                00002600
         IC    5,&M               GET BYTE COUNT-1                      00002700
         EX    5,PCRMVCH          MOVE MESSAGE TO I/O BUFFER            00002800
         MEND                                                           00002900
         SPACE 5                                                        00003000
         MACRO                                                          00003100
         MSG   &N,&C                                                    00003200
MSG&N    DC    AL1(L'MSG&N.#-1)    LENGTH-1 OF MESSAGE                  00003300
MSG&N.#  DC    C&C                                                      00003400
         SPACE 2                                                        00003500
         MEND                                                           00003600
         EJECT                                                          00003700
         GBLA  &PCR                                                     00003800
         GBLA  &TALK          SET TO 0 FOR LACK OF VERBIAGE             00003900
&PCR     SETA  1                   SET TO 0 FOR OLD HALLINK             00004000
&TALK    SETA  0                                                        00004100
         SPACE 5                                                        00004200
HALLINK  CSECT                                                          00004300
         USING HALLINK,12                                               00004400
         SAVE  (14,12),T,*                                              00004500
         LR    12,15                                                    00004600
         ST    13,SAVE+4 SAVE AREAS SET UP                              00004700
         LA    14,SAVE                                                  00004800
         ST    14,8(0,13)                                               00004900
         LR    13,14                                                    00005000
         SPACE 3                                                        00005100
         LTR   1,1 ANY PARM FIELD / DDLIST?                             00005200
         BZ    INVOKE NONE, SKIP OUT                                    00005300
         L     2,0(0,1) PICK UP PARM PTR                                00005400
         LA    2,0(0,2) ZERO HI BYTE                                    00005500
         LTR   2,2 PARM FIELD?                                          00005600
         BZ    DDLIST NO, LOOK FOR DDLIST                               00005700
         LH    3,0(0,2) LENGTH OF PARM FIELD                            00005800
         LTR   11,3           ANY PARM FIELD                            00005900
         BZ    DDLIST                                                   00006000
         AIF   (&PCR EQ 0).A1                                           00006100
         LA    4,2(0,2)       PICK UP PTR TO PARM LIST                  00006200
         ST    4,LISTADDR                                               00006300
         STH   3,LISTLEN                                                00006400
.A1      ANOP                                                           00006500
         LR    5,3                                                      00006600
         LR    4,2                                                      00006700
AA       CLI   2(4),C'/'      LOOK FOR DELIMITER                        00006800
         BE    SLASH                                                    00006900
         LA    4,1(0,4)                                                 00007000
         BCT   5,AA                                                     00007100
         B     MOVEPARM                                                 00007200
SLASH    LR    11,4                                                     00007300
         SR    11,2           NUMBER OF CHAR BEFORE /                   00007400
         BCT   5,*+8          IF SLASH WAS LAST CHARACTER               00007500
         B     MOVEPARM                                                 00007600
C1       LA    10,NUMOPT2                                               00007700
         LA    9,OPTABL                                                 00007800
         SR    8,8                                                      00007900
C2       IC    8,0(0,9)       PICK UP LENGTH-1                          00008000
         EX    8,CLC          IS IT AN OPTION?                          00008100
         BE    FOUND          GOT VALID OPTION                          00008200
         LA    9,2(8,9)       POINT TO NEXT VALID OPT                   00008300
         BCT   10,C2          RIPPLE THRU ALL OPTS                      00008400
         LA    4,1(0,4) NEXT MIGHT BE VALID IF NOT THIS CHAR            00008500
         BCT   5,C1                                                     00008600
         B     MOVEPARM                                                 00008700
FOUND    LA    15,NUMOPT                                                00008800
         CR    10,15                                                    00008900
         BNH   *+8                                                      00009000
         SH    10,FOUND+2                                               00009100
         LCR   10,10                                                    00009200
         STC   10,OPTIONS+NUMOPT(10)                                    00009300
         LA    4,2(8,4)       POINT PAST VALID OPTION                   00009400
         BCTR  5,0                                                      00009500
         SR    5,8            NUMBER OF CHAR LEFT                       00009600
         BH    C1                                                       00009700
MOVEPARM CLI   OPTIONS+TEST,0                                           00009800
         BNE   QT1            SDL MODE SPECIFIED IF BRANCH TAKEN        00009900
         LA    8,PARMFLD1+2+L'TESTP                                     00010000
         CLI   OPTIONS+BOTH,0                                           00010100
         BE    P2                                                       00010200
         LTR   14,11 MOVE PARM FLD TO FIRST IEWL IF ANY PRESENT         00010300
         BZ    P2                                                       00010400
         BCTR  14,0                                                     00010500
         EX    14,MVCP1                                                 00010600
         LA    14,L'TESTP+1(0,14)                                       00010700
         STH   14,PARMFLD1                                              00010800
         B     P2                                                       00010900
QT1      LA    8,PARMFLD1+2                                             00011000
         XC    PARMFLD1(2),PARMFLD1                                     00011100
         CLI   OPTIONS+BOTH,0                                           00011200
         BE    P2                                                       00011300
         LTR   14,11                                                    00011400
         BZ    P2                                                       00011500
         BCTR  14,0                                                     00011600
         EX    14,MVCP1                                                 00011700
         STH   11,PARMFLD1                                              00011800
P2       LTR   14,11                                                    00011900
         BZ    DDLIST                                                   00012000
         BCTR  14,0                                                     00012100
         EX    14,MVCP3                                                 00012200
         LA    14,L'NCAL+1(0,14)                                        00012300
         STH   14,PARMFLD3                                              00012400
         EJECT                                                          00012500
DDLIST   TM    0(1),X'80' ANY DDLIST?                                   00012600
         BO    INVOKE NO                                                00012700
         L     2,4(0,1) PICK UP DDLIST PTR                              00012800
         LA    2,0(0,2)                                                 00012900
         LTR   2,2                                                      00013000
         BZ    INVOKE                                                   00013100
         LH    3,0(0,2) LENGTH OF DDLIST                                00013200
         AIF   (&PCR EQ 0).QQQ                                          00013300
         MVI   DDLISTPR,1                                               00013400
         STH   3,DDLISTLN                                               00013500
         LA    8,2(0,2)                                                 00013600
         ST    8,DDLISTAD                                               00013700
.QQQ     ANOP                                                           00013800
         LTR   3,3                                                      00013900
         BNH   INVOKE                                                   00014000
*         AIF   (&PCR EQ 0).QQ1                                         00014100
*         MVI   DDLISTPR,1                                              00014200
*.QQ1     ANOP                                                          00014300
         SPACE 3                                                        00014400
*DDLIST BEING PASSED, DISSEMINATE THE INFORMATION TO                    00014500
*THE APPROPRIATE PEOPLE                                                 00014600
*         AIF   (&PCR EQ 0).A2                                          00014700
*         LA    8,2(0,2)           POINTER TO DDLIST                    00014800
*         ST    8,DDLISTAD                                              00014900
*         STH   3,DDLISTLN                                              00015000
*.A2      ANOP                                                          00015100
         LA    8,8 PUT CONSTANT INTO R 8                                00015200
         LA    2,2(0,2) POINT TO FIRST BYTE OF INFO                     00015300
         OC    0(8,2),0(2)                                              00015400
         BZ    *+10                                                     00015500
         MVC   SYSLIN1(8),0(2) MOVE SYSLIN INFO                         00015600
         SR    3,8                                                      00015700
         BNH   INVOKE SKIP OUT IF ONLY ENTRY                            00015800
         OC    8(8,2),8(2) WAS FINAL LOAD MODULE NAME OVERRIDDEN        00015900
         BZ    *+10 SKIP IF NOT                                         00016000
         MVC   MEMBR3(8),8(2) REPLACE                                   00016100
         SR    3,8                                                      00016200
         BNH   INVOKE                                                   00016300
         OC    16(8,2),16(2)  OUTPUT LOAD MODULE DD NAME?               00016400
         BZ    *+10                                                     00016500
         MVC   SYSLMOD3(8),16(2)                                        00016600
         SR    3,8                                                      00016700
         BNH   INVOKE                                                   00016800
         OC    24(8,2),24(2) SYSLIB DD?                                 00016900
         BZ    *+22                                                     00017000
         MVC   SYSLIB1(8),24(2)                                         00017100
         MVC   SYSLIB2(8),24(2)                                         00017200
         MVC   SYSLIB3(8),24(2)                                         00017300
         SR    3,8                                                      00017400
         SR    3,8 NEXT ENTRY IGNORED BY LKED                           00017500
         BNH   INVOKE                                                   00017600
         OC    40(8,2),40(2) SYSPRINT                                   00017700
         AIF   (&PCR NE 0).B1                                           00017800
         BZ    *+22                                                     00017900
         AGO   .B3                                                      00018000
.B1      ANOP                                                           00018100
         BZ    *+28                                                     00018200
         MVC   SYSPRINT+X'28'(8),40(2)                                  00018300
.B3      ANOP                                                           00018400
         MVC   SYSPRNT1(8),40(2)                                        00018500
         MVC   SYSPRNT2(8),40(2)                                        00018600
         MVC   SYSPRNT3(8),40(2)                                        00018700
         SR    3,8                                                      00018800
         SR    3,8 NEXT ENTRY ALSO IGNORED                              00018900
         BNH   INVOKE                                                   00019000
         OC    56(8,2),56(2) SYSUT1                                     00019100
         BZ    *+16                                                     00019200
         MVC   SYSUT11(8),56(2)                                         00019300
         MVC   SYSUT13(8),56(2)                                         00019400
         SR    3,8                                                      00019500
         SR    3,8                                                      00019600
         SR    3,8                                                      00019700
         SR    3,8                                                      00019800
         BNH   INVOKE                                                   00019900
         OC    88(8,2),88(2) SYSTERM                                    00020000
         BZ    *+16                                                     00020100
         MVC   SYSTERM1(8),88(2)                                        00020200
         MVC   SYSTERM3(8),88(2)                                        00020300
         SR    3,8                                                      00020400
         BNH   INVOKE                                                   00020500
         OC    96(8,2),96(2) TEMP OBJECT DECK FILE DDNAME?              00020600
         BZ    *+16                                                     00020700
         MVC   SYSOBJ2(8),96(2)                                         00020800
         MVC   SYSLIN3(8),96(2)                                         00020900
         SR    3,8                                                      00021000
         BNH   INVOKE                                                   00021100
         OC    104(8,2),104(2) TEMP LOAD FILE DDNAME                    00021200
         BZ    *+16                                                     00021300
         MVC   SYSLMOD1(8),104(2)                                       00021400
         MVC   SYSLMOD2(8),104(2)                                       00021500
         SR    3,8                                                      00021600
         BNH   INVOKE                                                   00021700
         OC    112(8,2),112(2) TEMP LOAD MODULE MEMBER NAME             00021800
         BZ    *+22                                                     00021900
         MVC   MEMBR1(8),112(2)                                         00022000
         MVC   MEMBR2(8),112(2)                                         00022100
         MVC   MEMBR3(8),112(2)                                         00022200
         SR    3,8                                                      00022300
         BNH   INVOKE                                                   00022400
         OC    120(8,2),120(2)                                          00022500
         BZ    *+10                                                     00022600
         MVC   LINKLIB+X'28'(8),120(2) REPLACE LINKLIB DD NAME          00022700
         SR    3,8                                                      00022800
         BNH   INVOKE                                                   00022900
         OC    128(8,2),128(2)                                          00023000
         BZ    *+10                                                     00023100
         MVC   SYSPRNT3(8),128(2)                                       00023200
         SR    3,8                                                      00023300
         BNH   INVOKE                                                   00023400
         OC    136(8,2),136(2)                                          00023500
         BZ    *+16                                                     00023600
         MVC   NAME1(8),136(2)                                          00023700
         MVC   NAME3(8),136(2)                                          00023800
         SR    3,8                                                      00023900
         BNH   INVOKE                                                   00024000
         OC    144(8,2),144(2)                                          00024100
         BZ    *+10                                                     00024200
         MVC   NAME2(8),144(2)                                          00024300
         SR    3,8                                                      00024400
         BNH   INVOKE                                                   00024500
         OC    152(8,2),152(2)                                          00024600
         BZ    *+10                                                     00024700
         MVC   NAME3(8),152(2)                                          00024800
         SR    3,8                                                      00024900
         BNH   INVOKE                                                   00025000
         OC    160(8,2),160(2)                                          00025100
         BZ    *+10                                                     00025200
         MVC   LINKIN(8),160(2)                                         00025300
         EJECT                                                          00025400
INVOKE   DC    0H'0'                                                    00025500
         AIF   (&PCR EQ 0).C1                                           00025600
*         CLI   OPTIONS+PRINTALL,0                                      00025700
*         BE    PCR                                                     00025800
*         MVI   DDLISTPR,1                                              00025900
         B     PCR                GO TO PRINT PARM FIELDS               00026000
PCRRET   DC    0H'0'                                                    00026100
.C1      ANOP                                                           00026200
         CLI   OPTIONS+PRIVLIB,0                                        00026300
         BE    SR                                                       00026400
         OPEN  (LINKLIB,INPUT)                                          00026500
         TM    LINKLIB+48,16 OPENED                                     00026600
         LA    2,LINKLIB                                                00026700
         BO    *+6                                                      00026800
SR       SR    2,2                                                      00026900
         ST    2,DCBADDR                                                00027000
         AIF   (&PCR NE 0).X1                                           00027100
         CLI   OPTIONS+NOGO,0 USINGHALLINK TO CONSTRUCT LOAD LIB?       00027200
         BE    INVOKE2 SKIP IF NOT                                      00027300
         MVC   SYSLMOD1(8),SYSLMOD3 SYSLMOD IS OUTPUT FILE              00027400
         MVC   PARMFLD1(LPNOGO),PNOGO MOVE 'TEST,NCAL'                  00027500
.X1      ANOP                                                           00027600
INVOKE2  DC    0H'0'                                                    00027700
         LINK  EPLOC=NAME1,PARAM=(PARMFLD1,DDLIST1),VL=1,DCB=(2)        00027800
         LA    14,12 CHECK RETURN CODE. IF >= 12 ABORT HERE             00027900
         CR    14,15                                                    00028000
         BNH   RETURN                                                   00028100
         CLI   OPTIONS+NOGO,0                                           00028200
         BNE   RETURN                                                   00028300
         SPACE 3                                                        00028400
         L     2,DCBADDR                                                00028500
         LINK  EPLOC=NAME2,PARAM=(ZERO,DDLIST2),VL=1,DCB=(2)            00028600
         LA    14,4                                                     00028700
         CR    14,15                                                    00028800
         BL    RETURN                                                   00028900
         SRA   15,2                                                     00029000
         ST    15,RCODE                                                 00029100
         L     2,DCBADDR                                                00029200
*         OC    MEMBR2(8),MEMBR2                                        00029300
*         BZ    *+10                                                    00029400
*         MVC   MEMBR3(8),MEMBR2                                        00029500
         SPACE 3                                                        00029600
         LINK  EPLOC=NAME3,PARAM=(PARMFLD3,DDLIST3),VL=1,DCB=(2)        00029700
         SPACE                                                          00029800
RETURN   L     2,DCBADDR                                                00029900
         LTR   2,2                                                      00030000
         BZ    RETURN2                                                  00030100
         LR    2,15                                                     00030200
         CLOSE (LINKLIB)                                                00030300
         LR    15,2                                                     00030400
RETURN2  L     13,SAVE+4                                                00030500
         A     15,RCODE                                                 00030600
         RETURN (14,12),RC=(15)                                         00030700
         EJECT                                                          00030800
RCODE    DC    A(0)                                                     00030900
MVCP1    MVC   0(0,8),2(2)                                              00031000
MVCP3    MVC   NCAL+L'NCAL(0),2(2)                                      00031100
CLC      CLC   3(0,4),1(9)                                              00031200
         SPACE                                                          00031300
PNOGO    DC    AL2(LPNOGO-2)                                            00031400
         DC    C'TEST,NCAL'                                             00031500
LPNOGO   EQU   *-PNOGO                                                  00031600
         SPACE                                                          00031700
         DC    0H'0'                                                    00031800
PARMFLD1 DC    AL2(L'TESTP-1)                                           00031900
TESTP    DC    C'TEST,',CL128' '                                        00032000
PARMFLD3 DC    0H'0',AL2(L'NCAL-1)                                      00032100
NCAL     DC    C'NCAL,',CL128' '                                        00032200
SAVE     DS    18F                                                      00032300
DDLIST1  DC    AL2(LIST1END-*-2)                                        00032400
SYSLIN1  DC    CL8'SYSLIN'                                              00032500
MEMBR1   DC    XL8'00'                                                  00032600
SYSLMOD1 DC    CL8'TEMPLOAD'                                            00032700
SYSLIB1  DC    CL8'SYSLIB'                                              00032800
         DC    XL8'00'                                                  00032900
SYSPRNT1 DC    CL8'SYSPRINT'                                            00033000
         DC    XL8'00'                                                  00033100
SYSUT11  DC    CL8'SYSUT1'                                              00033200
         DC    3XL8'00' UNUSED                                          00033300
SYSTERM1 DC    CL8'SYSTERM'                                             00033400
LIST1END EQU   *                                                        00033500
         SPACE 3                                                        00033600
ZERO     DC    AL2(DDLIST2-*-2) PARM FIELD                              00033700
OPTIONS  DC    XL16'00'                                                 00033800
DDLIST2  DC    AL2(LIST2END-*-2)                                        00033900
SYSOBJ2  DC    CL8'STACKOBJ'                                            00034000
SYSLMOD2 DC    CL8'TEMPLOAD'                                            00034100
SYSPRNT2 DC    CL8'SYSPRINT'                                            00034200
MEMBR2   DC    XL8'00'                                                  00034300
SYSLIB2  DC    CL8'SYSLIB'                                              00034400
LINKIN   DC    CL8'LINKIN  '                                            00034500
LIST2END EQU   *                                                        00034600
         SPACE 3                                                        00034700
DDLIST3  DC    AL2(LIST3END-*-2)                                        00034800
SYSLIN3  DC    CL8'STACKOBJ'                                            00034900
MEMBR3   DC    XL8'00'                                                  00035000
SYSLMOD3 DC    CL8'SYSLMOD'                                             00035100
SYSLIB3  DC    CL8'SYSLIB' SHOULD NEVER BE OPENED DUE TO NCAL OPTION    00035200
         DC    XL8'00'                                                  00035300
SYSPRNT3 DC    CL8'SYSPRINT'                                            00035400
         DC    XL8'00'                                                  00035500
SYSUT13  DC    CL8'SYSUT1'                                              00035600
         DC    3XL8'00'                                                 00035700
SYSTERM3 DC    CL8'SYSTERM'                                             00035800
LIST3END EQU   *                                                        00035900
         DC    0D'0'                                                    00036000
NAME1    DC    CL8'IEWL'                                                00036100
NAME2    DC    CL8'HALLKED'                                             00036200
NAME3    DC    CL8'IEWL'                                                00036300
         EJECT                                                          00036400
OPT1     DC    0X'0'                                                    00036500
OPTABL   OPT   'TREE'                                                   00036600
         OPT   'HALSTART'                                               00036700
         OPT   'NOHALMAP'                                               00036800
         OPT   'NOREC'                                                  00036900
         OPT   'BOTH',BOTH                                              00037000
         OPT   'PRIVLIB',PRIVLIB                                        00037100
         OPT   'SDL',TEST                                               00037200
         OPT   'XREF'                                                   00037300
         OPT   'NOGO',NOGO                                              00037400
         SPACE 2                                                        00037500
         AIF   (&PCR EQ 0).NN1                                          00037600
         OPT   'DDLIST',PRINTALL                                        00037700
         OPT   'NOMSG',NOMSG                                            00037800
         AIF   (&TALK EQ 0).NT                                          00037900
         OPT   'TELL',TOOMUCH                                           00038000
.NT      ANOP                                                           00038100
.NN1     ANOP                                                           00038200
         SPACE 2                                                        00038300
         OPT                                                            00038400
         EJECT                                                          00038500
OPT2     DC    0X'0'                                                    00038600
         OPT   'TREE'                                                   00038700
         OPT   'HS'                                                     00038800
         OPT   'NM'                                                     00038900
         OPT   'NR'                                                     00039000
         OPT   'BOTH'                                                   00039100
         OPT   'LIB'                                                    00039200
         OPT   'SDL'                                                    00039300
         OPT   'XREF'                                                   00039400
         OPT   'OSLOAD'                                                 00039500
         SPACE 2                                                        00039600
         AIF   (&PCR EQ 0).NN2                                          00039700
         OPT   'ALTLIST'                                                00039800
         OPT   'NOMSG'                                                  00039900
         AIF   (&TALK EQ 0).NT2                                         00040000
         OPT   'TELL'                                                   00040100
.NT2     ANOP                                                           00040200
.NN2     ANOP                                                           00040300
         SPACE 2                                                        00040400
         OPT                                                            00040500
         EJECT                                                          00040600
LINKLIB  DCB   DDNAME=LINKLIB,DSORG=PO,MACRF=(R)                        00040700
DCBADDR  DS    A                                                        00040800
         AIF   (&PCR EQ 0).END                                          00040900
         EJECT                                                          00041000
SYSPRINT DCB   DDNAME=SYSPRINT,DSORG=PS,LRECL=121,BLKSIZE=605,         X00041100
               RECFM=FBM,MACRF=(PL)                                     00041200
         EJECT                                                          00041300
PCR      DC    0H'0'              FOR ALL YOU DUMMIES                   00041400
         CLI   OPTIONS+NOGO,0     NOGO OPTION??                         00041410
         BZ    PCRGO              NO, DON'T MODIFY THE DDLISTS          00041420
         MVC   SYSLMOD1(8),SYSLMOD3                                     00041430
         MVC   PARMFLD1(LPNOGO),PNOGO                                   00041440
PCRGO    DC    0H'0'                                                    00041450
         CLI   OPTIONS+NOMSG,0                                          00041500
         BNE   PCRRET                                                   00041600
         OPEN  (SYSPRINT,(OUTPUT))                                      00041700
         TM    SYSPRINT+48,16     OPENED OK                             00041800
         BZ    PCRRET                                                   00041900
         BALR  9,0                                                      00042000
         USING *,9                                                      00042100
         BAL   10,PRINT           EJECT A PAGE                          00042200
         BAL   10,PRINT           GET BLANK LINE FOR HEADING            00042300
         PCRMSG MSG0              PRINT HEADING                         00042400
         AIF   (&TALK EQ 0).NOTALK                                      00042500
         CLI   OPTIONS+TOOMUCH,0                                        00042600
         BZ    ENOUGH                                                   00042700
         BAL   10,PRINT                                                 00042800
         BAL   10,PRINT                                                 00042900
         PCRMSG MSGT1                                                   00043000
         BAL   10,PRINT                                                 00043100
         PCRMSG MSGT2                                                   00043200
         BAL   10,PRINT                                                 00043300
         PCRMSG MSGT3                                                   00043400
         BAL   10,PRINT                                                 00043500
         BAL   10,PRINT                                                 00043600
         PCRMSG MSGT4                                                   00043700
         BAL   10,PRINT                                                 00043800
         PCRMSG MSGT5                                                   00043900
         BAL   10,PRINT                                                 00044000
         PCRMSG MSGT0                                                   00044100
         BAL   10,PRINT                                                 00044200
         PCRMSG MSGT6                                                   00044300
         BAL   10,PRINT                                                 00044400
         PCRMSG MSGT7                                                   00044500
ENOUGH   DC    0H'0'                                                    00044600
.NOTALK  ANOP                                                           00044700
         BAL   10,PRINT           SKIP A LINE                           00044800
         BAL   10,PRINT           GET A BUFFER                          00044900
**********PRINT OUT THE PARM FIELD                                      00045000
         PCRMSG MSG8              PRINT PARM FIELD                      00045100
         LH    5,LISTLEN          LENGTH OF FIELD                       00045200
         L     7,LISTADDR         ADDRESS OF PARM FIELD                 00045300
         BAL   11,PCRPARM         PRINT IT                              00045400
**********PRINT OUT ALT DDLIST FOR HALLINK                              00045500
PCRB     DC    0H'0'                                                    00045600
         CLI   DDLISTPR,0                                               00045700
         BE    PCRBEND                                                  00045800
         BAL   10,PRINT           BUFFER                                00045900
         PCRMSG MSG1              ALT DDLIST HEADING                    00046000
         LH    5,DDLISTLN         CHECK FOR ALT DDLIST                  00046100
         LTR   5,5                ANY?                                  00046200
         BH    PCRB1              SKIP IF YES                           00046300
         BAL   10,PRINT                                                 00046400
         MVC   15(L'NONE,1),NONE  NO ALT DD LIST                        00046500
         B     PCRBEND            SKIP TO END OF THIS PHASE             00046600
PCRB1    DC    0H'0'                                                    00046700
         L     7,DDLISTAD         ADDRESS OF DDLIST                     00046800
         BAL   11,PCRDDLST        PRINT LIST                            00046900
PCRBEND  DC    0H'0'                                                    00047000
         BAL   10,PRINT           HEADING                               00047100
**********PRINT OUT OPTIONS IN EFFECT                                   00047200
         BAL   10,PRINT                                                 00047300
         PCRMSG MSG2              OPTIONS IN EFFECT                     00047400
         BAL   11,PCROPTS         PRINT OUT OPTIONS                     00047500
         BAL   10,PRINT           SKIP A LINE                           00047600
         PCRMSG MSG3              OPTIONS NOT IN EFFECT                 00047700
         MVI   PCROPTB+1,X'70'       HOOOOW UGLY                        00047800
         BAL   11,PCROPTS         GET THE NON OPTIONS TOO               00047900
         BAL   10,PRINT           SKIP A LINE                           00048000
         SPACE 2                                                        00048100
**********PRINT LE1 PARM FIELD                                          00048700
         CLI   OPTIONS+PRINTALL,0                                       00048800
         BE    SEENOGO                                                  00048900
*         CLI   DDLISTPR,0                                              00049000
*         BE    SEENOGO                                                 00049100
PCRGO0   DC    0H'0'                                                    00049200
         PCRMSG MSG4              LE1 PARM FIELD                        00049300
         LH    5,PARMFLD1         LENGTH OF PARM FIELD                  00049400
         LA    7,PARMFLD1+2                                             00049500
         BAL   11,PCRPARM                                               00049600
**********PRINT LE1 ALT DDLIST                                          00049700
         BAL   10,PRINT           SKIP A LINE                           00049800
         PCRMSG MSG5              ALT DD LIST FOR LE1                   00049900
         LH    5,DDLIST1                                                00050000
         LA    7,DDLIST1+2                                              00050100
         BAL   11,PCRDDLST                                              00050200
         BAL   10,PRINT                                                 00050300
**********SEE IF NOGO SPECIFIED                                         00050400
SEENOGO  DC    0H'0'                                                    00050500
         CLI   OPTIONS+NOGO,0                                           00050600
         BZ    PCRGO1             NO                                    00050700
**********PRINT MSG ABOUT ONLY ONE LINK EDIT                            00050800
         BAL   10,PRINT                                                 00050900
         PCRMSG MSG6                                                    00051000
         B     ENDPCR                                                   00051100
PCRGO1   DC    0H'0'                                                    00051200
***********PRINT OUT HALLKED DDLIST                                     00051300
         CLI   OPTIONS+PRINTALL,0                                       00051400
         BE    ENDPCR                                                   00051500
*         CLI   DDLISTPR,0     DYNAM INVOKED?                           00051600
*         BE    ENDPCR         NO, STOP                                 00051700
*PCRGO2   DC    0H'0'                                                   00051800
         BAL   10,PRINT                                                 00051900
         PCRMSG MSG7                                                    00052000
         LH    5,DDLIST2                                                00052100
         LA    7,DDLIST2+2                                              00052200
         BAL   11,PCRDDLST                                              00052300
         CLI   OPTIONS+PRINTALL,0   PRINT ALL?                          00052400
         BZ    ENDPCR             NO                                    00052500
         BAL   10,PRINT                                                 00052600
**********PRINT OUT LE2 PARM FIELD                                      00052700
         MVI   MSG4#+L'MSG4#-1,C'2' CHANGE LE1 TO LE2                   00052800
         PCRMSG MSG4              PRINT IT OUT                          00052900
         LH    5,PARMFLD3                                               00053000
         LA    7,PARMFLD3+2                                             00053100
         BAL   11,PCRPARM                                               00053200
**********PRINT LE2 ALT DDLIST                                          00053300
         BAL   10,PRINT                                                 00053400
         MVI   MSG5#+L'MSG5#-1,C'2'                                     00053500
         PCRMSG MSG5                                                    00053600
         LH    5,DDLIST3                                                00053700
         LA    7,DDLIST3+2                                              00053800
         BAL   11,PRDDLIST                                              00053900
ENDPCR   DC    0H'0'                                                    00054000
         CLOSE (SYSPRINT)                                               00054100
         FREEPOOL SYSPRINT                                              00054200
         B     PCRRET                                                   00054300
         EJECT                                                          00054400
PRINT    DC    0H'0'              PROVIDES A BUFFER                     00054500
         PUT SYSPRINT                                                   00054600
         MVI   0(1),X'8B'         SKIP TO 1 IMMED                       00054700
         MVI   *-3,9              SKIP ONE LINE                         00054800
         MVI   1(1),C' '                                                00054900
         MVC   2(119,1),1(1)                                            00055000
         BR    10                 FUCK ME, ASSHOLE                      00055100
         SPACE 5                                                        00055200
PRDDLIST DC    0H'0'              PRINTS ALT DDLISTS                    00055300
PCRDDLST DC    0H'0'                                                    00055400
         SRL   5,3                                                      00055500
         SR    6,6                DISP                                  00055600
PRLIST1  DC    0H'0'                                                    00055700
         BAL   10,PRINT                                                 00055800
         STH   6,PCRBUFF1                                               00055900
ALPHA    UNPK  PCRBUFF2(3),PCRBUFF1+1(2)                                00056000
         MVI   PCRBUFF2+2,C' '                                          00056100
         MVC   PCRBUFF2+5(8),0(7)                                       00056200
         CLI   PCRBUFF2+5,0                                             00056300
         BNE   *+10                                                     00056400
         MVC   PCRBUFF2+5(8),AST                                        00056500
         MVC   15(L'PCRBUFF2,1),PCRBUFF2                                00056600
         LA    6,8(0,6)                                                 00056700
         LA    7,8(0,7)                                                 00056800
         BCT   5,PRLIST1                                                00056900
         BAL   10,PRINT                                                 00057000
         BR    11                                                       00057100
         SPACE 5                                                        00057200
PCRPARM  DC    0H'0'              PRINTS PARM FIELDS                    00057300
PRPARM   DC    0H'0'                                                    00057400
         BAL   10,PRINT       GET A NEW LINE                            00057500
         CH    5,PRPARM3+2                                              00057600
         BH    PRPARM2                                                  00057700
PRPARM1  DC    0H'0'                                                    00057800
         BCTR  5,0                                                      00057900
         EX    5,PCRMVCA                                                00058000
         BAL   10,PRINT                                                 00058100
         BR    11                                                       00058200
PRPARM2  DC    0H'0'                                                    00058300
         LH    6,=H'99'                                                 00058400
         EX    6,PCRMVCA                                                00058500
         SH    5,PRPARM3+2                                              00058600
PRPARM3  DC    0H'0'                                                    00058700
         LA    7,100(7,0)                                               00058800
         BAL   10,PRINT                                                 00058900
         B     PRPARM                                                   00059000
         SPACE 5                                                        00059100
PCROPTS  DC    0H'0'              PRINTS OUT HALLINK OPTIONS IN EFFECT  00059200
         BAL   10,PRINT                                                 00059300
         SR    2,2                                                      00059400
         LA    3,OPT1                                                   00059500
         LA    4,OPT2                                                   00059600
         LA    5,ZERO+L'ZERO                                            00059700
         LA    6,NUMOPT                                                 00059800
         SR    7,7                                                      00059900
         SR    8,8                                                      00060000
PCROPTS1 DC    0H'0'                                                    00060100
         IC    7,0(0,3)                                                 00060200
         IC    8,0(0,4)                                                 00060300
         CLI   0(5),0                                                   00060400
PCROPTB  DC    0H'0'                                                    00060500
         BC    8,PCRPRM3                                                00060600
         LA    2,1                                                      00060700
         EX    7,PCRMVCPP                                               00060800
         EX    7,PCRCLC                                                 00060900
         BE    PCRPRM2                                                  00061000
         MVC   20(2,1),=C'OR'                                           00061100
         EX    8,PCRMVCPS                                               00061200
PCRPRM2  DC    0H'0'                                                    00061300
         BAL   10,PRINT                                                 00061400
PCRPRM3  DC    0H'0'                                                    00061500
         LA    3,2(7,3)           POINT TO NEXT OPTION                  00061600
         LA    4,2(8,4)                                                 00061700
         LA    5,1(0,5)                                                 00061800
         BCT   6,PCROPTS1                                               00061900
         LTR   2,2                                                      00062000
         BNZ   *+10                                                     00062100
         MVC   10(L'NONE,1),NONE                                        00062200
         BAL   10,PRINT                                                 00062300
         BR    11                                                       00062400
         EJECT                                                          00062500
LISTADDR DC    A(NONE)                                                  00062600
DDLISTAD DC    A(0)                                                     00062700
LISTLEN  DC    AL2(L'NONE)                                              00062800
DDLISTLN DC    AL2(0)                                                   00062900
         SPACE 3                                                        00063000
PCRMVCA  MVC   10(0,1),0(7)        MOVE PARM                            00063100
PCRMVCPP MVC   10(0,1),1(3)       MOVE PRIMARY OPTION                   00063200
PCRMVCPS MVC   25(0,1),1(4)       MOVE SECONDARY OPTION                 00063300
PCRCLC   CLC   1(0,3),1(4)        COMPARE OPTIONS                       00063400
PCRMVCH  MVC   1(0,1),1(7)    MOVE HEADING                              00063500
         SPACE 3                                                        00063600
PCRBUFF1 DC    H'0'                                                     00063700
PCRBUFF2 DC    C'00   XXXXXXXX'                                         00063800
NONE     DC    C'**NONE**'                                              00063900
AST      DC    C'********'                                              00064000
DDLISTPR DC    X'0'                                                     00064100
         EJECT                                                          00064200
 MSG 0,'HALLINK VERSION 6.1 DATED 6 OCTOBER 1975'                       00064300
 MSG 1,'ALTERNATE DDLIST PASSED TO HALLINK (******** INDICATES OMITTED X00064400
               ENTRIES)'                                                00064500
 MSG 2,'HALLINK OPTIONS IN EFFECT'                                      00064600
 MSG 3,'HALLINK OPTIONS NOT IN EFFECT'                                  00064700
 MSG 4,'PARM FIELD PASSED TO LINK EDIT STEP 1'                          00064800
 MSG 5,'ALTERNATE DDLIST PASSED TO LINK EDIT STEP 1'                    00064900
 MSG 6,'HALLINK TERMINATING AFTER LINK EDIT 1 DUE TO OPTION NOGO OR OSLX00065000
               OAD'                                                     00065100
 MSG 7,'ALTERNATE DDLIST PASSED TO HALLKED'                             00065200
 MSG 8,'PARM FIELD PASSED TO HALLINK'                                   00065300
         AIF   (&TALK EQ 0).NOTALK1                                     00065400
 MSG    T1,'**NOTE** THIS IS AN EXPERIMENTAL VERSION OF THE HALLINK PROX00065500
               GRAM;  SEND COMMENTS TO AQV1840 (SANDY, 661-1840)'       00065600
 MSG    T2,'**NOTE** THESE INSTRUCTIONS WILL DISAPPEAR AS OF THE NEXT RX00065700
               ELEASE'                                                  00065800
 MSG    T3,'IF HALLINK OPTION "NOMSG" IS PASSED, NONE OF THE FOLLOWING X00065900
               WILL APPLY'                                              00066000
 MSG    T4,'THE FOLLOWING IS ALWAYS PRINTED: PARM FIELD, OPTIONS IN EFFX00066100
               ECT, AND OPTIONS NOT IN EFFECT'                          00066200
 MSG    T5,'IF INVOKED BY JCL, AND "DDLIST" WAS NOT PASSED, THEN ONLY TX00066300
               HE ABOVE FIELDS WILL BE LISTED'                          00066400
 MSG    T0,'IF HOWEVER, "DDLIST" WAS PASSED, THEN ALL ALTERNATE DDLISTSX00066500
                AND PARM FIELDS WILL BE LISTED'                         00066600
 MSG    T6,'IF DYNAMICALLY INVOKED AND "DDLIST" NOT PASSED, THEN THE ALX00066700
               TERNATE DDLIST PASSED TO HALLINK WILL BE LISTED'         00066800
 MSG    T7,'IF HOWEVER, "DDLIST" WAS PASSED, YOU GET EVERYTHING YOU EVER00066900
               R WANTED TO KNOW (AND PROBABLY MORE!)'                   00067000
.NOTALK1 ANOP                                                           00067100
         EJECT                                                          00067200
.END     ANOP                                                           00067300
PATCH    DC    10D'0'             PATCH HERE                            00067400
         END                                                            00067500
