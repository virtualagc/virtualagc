*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    COMPOPT.bal
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

OPT      TITLE 'OPTION TABLE GENERATOR AND SCANNER'                     00000100
         MACRO                                                          00000110
         OPARM                                                          00000111
         GBLB  &PA,&BF,&H3                                              00000112
&PA      SETB  ('&SYSPARM' EQ 'PASS')                                   00000113
&BF      SETB  ('&SYSPARM' EQ 'BFS')                                    00000114
&H3      SETB  ('&SYSPARM' EQ 'H360')                                   00000115
         MEND                                                           00000120
         SPACE 3                                                        00000130
         MACRO                                                          00000200
         TYPE1OPT                                                       00000300
         LCLA  &I,&ADJ,&SW,&K,&L,&BI,&HI                                00000400
         LCLC  &CON,&D                                                  00000500
         LCLB  &B(32)                                                   00000600
OPTIONS  DC    F'0'                                                     00000700
ACON     DC    A(CON)                                                   00000800
APRO     DC    A(PRO)                                                   00000900
ADESC    DC    A(0)                                                     00001000
AVALS    DC    A(0)                                                     00001100
AMONVALS DC    A(0)                                                     00001200
&CON     SETC  'CON'                                                    00001300
&SW      SETA  1                                                        00001400
.*       GENERATE CON AND PRO LISTS                                     00001500
.CONPRO  ANOP                                                           00001600
&I       SETA  1                                                        00001700
&CON     EQU   *                                                        00001800
.LOOP1   ANOP                                                           00001900
&ADJ     SETA  1-&SW                                                    00002000
.*       FOR CON AND OFF OR PRO AND ON, ADJ=0                           00002100
         AIF   ('&SYSLIST(&I,3)' NE 'ON').OFF                           00002200
&ADJ     SETA  1+&SW                                                    00002300
.*       FOR CON AND ON OR PRO AND OFF, ADJ=2                           00002400
.OFF     ANOP                                                           00002500
&K       SETA  K'&SYSLIST(&I,1)-&ADJ+1                                  00002600
         DC    AL1(&K),AL3(TYPE1&I+5+&ADJ)                              00002700
&I       SETA  &I+1                                                     00002800
.STOPTST AIF   ('&SYSLIST(&I,2)' NE '').LOOP1                           00002900
.*       WE HIT CON AND PRO STOP MARK                                   00003000
END&CON  DC    F'0'                                                     00003100
         AIF   ('&CON' EQ 'PRO').OPTS                                   00003200
&CON     SETC  'PRO'                                                    00003300
&SW      SETA  0-1                                                      00003400
         AGO   .CONPRO                                                  00003500
.OPTS    ANOP                                                           00003600
OPTTAB   EQU   *                                                        00003700
&I       SETA  1                                                        00003800
.LOOP2   ANOP                                                           00003900
&K       SETA  K'&SYSLIST(&I,1)-1                                       00004000
&L       SETA  K'&SYSLIST(&I,4)-1                                       00004100
         AIF   (&L LT 0).NOAIL                                          00004200
TYPE1&I  DC    XL4&SYSLIST(&I,2),AL1(&K),C'NO&SYSLIST(&I,1)',AL1(&L),C'X00004300
               &SYSLIST(&I,4)'                                          00004400
         AGO   .BITGEN                                                  00004500
.NOAIL   ANOP                                                           00004600
TYPE1&I  DC    XL4&SYSLIST(&I,2),AL1(&K),C'NO&SYSLIST(&I,1)',AL1(255)   00004700
.BITGEN  ANOP                                                           00004800
&BI      SETA  1                                                        00004900
&HI      SETA  2                                                        00005000
         AIF   (K'&SYSLIST(&I,2) NE 10).BADHEX                          00005100
.HLOOP   ANOP                                                           00005200
&D       SETC  '&SYSLIST(&I,2)'(&HI,1)                                  00005300
         AIF   ('&D' EQ '0').NEXTH                                      00005400
         AIF   ('&D' EQ '8').GOTIT                                      00005500
&BI      SETA  &BI+1                                                    00005600
         AIF   ('&D' EQ '4').GOTIT                                      00005700
&BI      SETA  &BI+1                                                    00005800
         AIF   ('&D' EQ '2').GOTIT                                      00005900
&BI      SETA  &BI+1                                                    00006000
         AIF   ('&D' EQ '1').GOTIT                                      00006100
.BADHEX  MNOTE 1,'ILLEGAL HEX MASK FOR &SYSLIST(&I,1)'                  00006200
         AGO   .INCR                                                    00006300
.NEXTH   ANOP                                                           00006400
&BI      SETA  &BI+4                                                    00006500
&HI      SETA  &HI+1                                                    00006600
         AIF   (&HI LE 9).HLOOP                                         00006700
         AGO   .BADHEX                                                  00006800
.GOTIT   ANOP                                                           00006900
         AIF   ('&SYSLIST(&I,3)' NE 'ON').INCR                          00007000
&B(&BI)  SETB  1                                                        00007100
.INCR    ANOP                                                           00007200
&I       SETA  &I+1                                                     00007300
         AIF   (&I GT N'&SYSLIST).OPTEND                                00007400
.*       SKIP PRINT END MARKER                                          00007500
         AIF   ('&SYSLIST(&I,2)' NE '').LOOP2                           00007600
         AGO   .INCR                                                    00007700
.OPTEND  ANOP                                                           00007800
TYPE1END EQU   *                                                        00007900
         ORG   OPTIONS                                                  00008000
         DC    B'&B(1)&B(2)&B(3)&B(4)&B(5)&B(6)&B(7)&B(8)'              00008100
         DC    B'&B(9)&B(10)&B(11)&B(12)&B(13)&B(14)&B(15)&B(16)'       00008200
         DC    B'&B(17)&B(18)&B(19)&B(20)&B(21)&B(22)&B(23)&B(24)'      00008300
         DC    B'&B(25)&B(26)&B(27)&B(28)&B(29)&B(30)&B(31)&B(32)'      00008400
         ORG                                                            00008500
         MEND                                                           00008600
         EJECT                                                          00008700
         MACRO                                                          00008800
         TYPE2OPT                                                       00008900
         LCLA  &I,&K                                                    00009000
         ORG   ADESC                                                    00009100
         DC    A(DESC)                                                  00009200
         DC    A(VALS)                                                  00009300
         DC    A(MONVALS)                                               00009400
         ORG                                                            00009500
&I       SETA  1                                                        00009600
         DS    0F                                                       00009700
DESC     EQU   *                                                        00009800
.LOOP1   ANOP                                                           00009900
&K       SETA  K'&SYSLIST(&I,1)-1                                       00010000
         DC    AL1(&K),AL3(TYPE2&I+2)                                   00010100
.INCRD   ANOP                                                           00010200
&I       SETA  &I+1                                                     00010300
         AIF   (&I GT N'&SYSLIST).GENVALS                               00010400
         AIF   ('&SYSLIST(&I,2)' NE '').LOOP1                           00010500
         DC    F'0'                                                     00010600
         AGO   .INCRD                                                   00010700
.*       GENERATE VALUE ARRAY                                           00010800
.GENVALS ANOP                                                           00010900
&I       SETA  1                                                        00011000
VALS     EQU   *                                                        00011100
.LOOP2   ANOP                                                           00011200
VAL2&I   DC    &SYSLIST(&I,3)                                           00011300
.INCRV   ANOP                                                           00011400
&I       SETA  &I+1                                                     00011500
         AIF   (&I GT N'&SYSLIST).GENSTR                                00011600
         AIF   ('&SYSLIST(&I,2)' NE '').LOOP2                           00011700
         DC    F'0'                                                     00011800
MONVALS  EQU   *                                                        00011900
         AGO   .INCRV                                                   00012000
.*       GENERATE STRINGS                                               00012100
.GENSTR  ANOP                                                           00012200
&I       SETA  1                                                        00012300
.LOOP3   ANOP                                                           00012400
&K       SETA  K'&SYSLIST(&I,4)                                         00012500
         AIF   (&K LE 0).NOAIL                                          00012600
TYPE2&I DC     SL2(&SYSLIST(&I,2)),C'&SYSLIST(&I,1)=',AL1(&K),C'&SYSLISX00012700
               T(&I,4)='                                                00012800
         AGO   .INCRI                                                   00012900
.NOAIL   ANOP                                                           00013000
TYPE2&I  DC    SL2(&SYSLIST(&I,2)),C'&SYSLIST(&I,1)=',AL1(255)          00013100
.INCRI   ANOP                                                           00013200
&I       SETA  &I+1                                                     00013300
         AIF   ('&SYSLIST(&I,2)' NE '').LOOP3                           00013400
&I       SETA  &I+1                                                     00013500
         AIF   (&I LE N'&SYSLIST).LOOP3                                 00013600
         MEND                                                           00013700
         EJECT                                                          00013800
         GBLB  &PA,&BF,&H3                                              00013810
XXXOPT   CSECT                                                          00013900
         USING *,15                                                     00014000
         SAVE  (14,12),T                                                00014100
         ST    13,SAVE+4                                                00014200
         LA    15,SAVE                                                  00014300
         ST    15,8(0,13)                                               00014400
         LR    13,15                                                    00014500
         BALR  10,0                                                     00014600
         USING *,10                                                     00014700
         DROP  15                                                       00014800
         LH    4,0(0,1)       LENGTH OF PARM FIELD                      00014900
         LA    8,2(0,1)       ADDR OF PARM STRING                       00015000
         LA    4,0(8,4)       ADDR OF END OF STRING                     00015100
         BCTR  8,0                                                      00015200
NEXT     LA    1,1(0,8)       R1 POINTS TO NEXT CHAR                    00015300
         CR    1,4            ARE WE DONE                               00015400
         BL    COMMAS         NO, LOOK FOR NEXT COMMA                   00015500
         L     1,=V(OPTIONS)  ADDR OF OPTIONS PARAMETERS                00015600
         L     13,SAVE+4      RELOAD R13                                00015700
         ST    1,24(0,13)     SAVE FOR RETURN AS R1                     00015800
         RETURN (14,12)                                                 00015900
COMMAS   LA    8,1(0,8)                                                 00016000
         CLI   0(8),C','                                                00016100
         BE    CALLOPT                                                  00016200
         CR    8,4                                                      00016300
         BL    COMMAS                                                   00016400
CALLOPT  CR    1,8                                                      00016500
         BE    NEXT                                                     00016600
         L     15,=V(OPTPROC)                                           00016700
         BALR  14,15                                                    00016800
         B     NEXT                                                     00016900
SAVE     DS    18F                                                      00017000
         LTORG                                                          00017100
         EJECT                                                          00017200
OPTPROC  CSECT                                                          00017300
         PRINT DATA                                                     00017400
         USING *,15                                                     00017500
         ENTRY OPTIONS                                                  00017600
         STM   0,15,OPTSAVE                                             00017700
         L     0,OPTIONS      PICK UP EXISTING OPTIONS                  00017800
         SR    6,6                                                      00017900
         SR    4,4                                                      00018000
         SR    3,3                                                      00018100
         MVI   FLAGS,X'00'    START CLEAN                               00018200
         LA    2,OPTTAB       POINT TO FIRST OPTION ENTRY               00018300
         CLC   NOCHAR,0(1)    IS A "NO" PRESENT                         00018400
         BNE   NOTNO                                                    00018500
         LA    11,4           SET FOR LATER XOR USE                     00018600
         AH    1,H2           BUMP PTR OVER "NO"                        00018700
         B     SETLEN                                                   00018800
NOTNO    CLI   0(1),C'N'      SHORT FORM NO?                            00018900
         BNE   NOTN                                                     00019000
         LA    11,4           SET FOR LATER                             00019100
         LA    1,1(0,1)       SKIP OVER N                               00019200
         OI    FLAGS,ALIASN   INDICATE SHORT NO FOUND                   00019300
         B     SETLEN                                                   00019400
NOTN     SR    11,11                                                    00019500
SETLEN   SR    8,1            LENGTH OF OPTION IN PARM FIELD            00019600
         BCTR  8,0                                                      00019700
CHECK1   NI    FLAGS,X'FF'-NOALIAS RESET FOR THIS OPTION                00019800
         IC    4,4(0,2)       LENGTH OF "TRUE" CHARACTERS               00019900
         LA    12,8(4,2)      ADDR OF ALIAS LENGTH                      00020000
         CLI   0(12),X'FF'    IS THERE AN ALIAS?                        00020100
         BNE   T1AIL          YES                                       00020200
         OI    FLAGS,NOALIAS  INDICATE NO ALIAS                         00020300
         L     3,=F'-1'       FOR ADJUSTMENT OF NEXT OPTION             00020400
         B     T1NOAIL                                                  00020500
T1AIL    SR    3,3                                                      00020600
         IC    3,0(0,12)      LENGTH OF ALIAS                           00020700
T1NOAIL  TM    FLAGS,ALIASN   IF SHORT "NO" THEN                        00020800
         BO    CHECKAIL       NEED ONLY CHECK ALIAS                     00020900
         CR    8,4            ARE LENGTHS THE SAME?                     00021000
         BNE   CHECKAIL       NO, TRY AN ALIAS                          00021100
         EX    4,COMP1        COMPARE                                   00021200
         BNE   CHECKAIL       NO MATCH                                  00021300
FOUNDOPT MVC   OPTMASK,0(2)   COPY MASK TO WORD ALIGN                   00021400
         L     9,OPTMASK      PICK UP MASK                              00021500
         OR    0,9            TURN BIT ON                               00021600
         LTR   11,11          IS "NO" SPECIFIED?                        00021700
         BZ    LEAVEON        NO, LEAVE IT ON                           00021800
         XR    0,9            TURN IT OFF                               00021900
LEAVEON  C     6,ENDPRINT                                               00022000
         BNL   RETURN1        NO NEED TO MAKE DESCRIPTORS               00022100
*        BUILD DESCRIPTOR FOR TRUE OPTION                               00022200
         SLL   4,24           LENGTH FIELD TO HIGH BYTE                 00022300
         LA    5,7(0,2)       ADDR OF STRING                            00022400
         OR    4,5            MAKE DESCRIPTOR                           00022500
         EX    0,DESCSAVE(11) SAVE INTO PROPER SLOT                     00022600
         X     11,F4          SET FOR OTHER SLOT                        00022700
*        NOW MODIFY DESCRIPTOR FOR "NO" OPTION                          00022800
         AL    4,LNGTHMOD     ADD TWO TO LENGTH                         00022900
         SH    4,H2           SUBTRACT TWO FROM ADDR                    00023000
         EX    0,DESCSAVE(11) SAVE IT                                   00023100
RETURN1  ST    0,OPTIONS                                                00023200
RETURN2  LM    0,15,OPTSAVE                                             00023300
         BR    14                                                       00023400
CHECKAIL TM    FLAGS,NOALIAS  IS THERE AN ALIAS?                        00023500
         BO    NEXTOPT1       NO, SKIP                                  00023600
         CR    8,3            CHECK LENGTHS                             00023700
         BNE   NEXTOPT1       SKIP IF NOT EQUAL                         00023800
         EX    3,AILCOMP      COMPARE                                   00023900
         BE FOUNDOPT                                                    00024000
NEXTOPT1 LA    6,4(0,6)       INCREMENT DESCRIPTOR POINTER              00024100
         LA    2,2(3,12)      POINT TO NEXT OPTION ENTRY                00024200
         C     2,ENDOPT                                                 00024300
         BNL   TRYTYPE2                                                 00024400
         B     CHECK1         GO BACK FOR NEXT                          00024500
TRYTYPE2 SR    4,4                                                      00024600
         SR    6,6                                                      00024700
         LA    2,DESC         DESCRIPTOR OF FIRST TYPE2 OPTION          00024800
CHECK2   IC    4,0(0,2)       LENGTH OF OPTION                          00024900
         LA    4,1(0,4)       PLUS 1 FOR '='                            00025000
         SR    11,11                                                    00025100
         A     11,0(0,2)      DESCRIPTOR                                00025200
         BZ    NEXTOPT2       WATCH OUT FOR NULL DESC                   00025300
         CR    8,4                                                      00025400
         BL    TRYAIL2                                                  00025500
         EX    4,COMP2                                                  00025600
         BE    EVALUATE                                                 00025700
TRYAIL2  LA    12,1(4,11)     ADDR OF LENGTH OF AILIAS                  00025800
         CLI   0(12),X'FF'    IS THERE ONE?                             00025900
         BE    NEXTOPT2       SKIP IF NOT                               00026000
         IC    4,0(12)        LENGTH                                    00026100
         CR    8,4                                                      00026200
         BL    NEXTOPT2                                                 00026300
         EX    4,COMP2AIL                                               00026400
         BE    EVALUATE                                                 00026500
NEXTOPT2 LA    6,4(0,6)       NEXT DESCRIPTOR OFFSET                    00026600
         C     6,ENDOPT2                                                00026700
         BNL   RETURN2                                                  00026800
         LA    2,4(0,2)       NEXT DESCRIPTOR                           00026900
         B     CHECK2                                                   00027000
EVALUATE SH    11,H2           POINT AT SL2 ADDR IN FRONT OF STRING     00027100
         MVC   HANDLER,0(11)                                            00027200
         BAL   5,0                                                      00027300
         ORG   *-2                                                      00027400
*                                                                       00027500
*        TITLE HANDLER                                                  00027600
*                                                                       00027700
HANDLER  DC    S(0)                                                     00027800
         B     RETURN2                                                  00027900
TITLE    LA    8,1(8,1)                                                 00028000
         LA    7,1(4,1)                                                 00028100
         ST    7,VALS(6)      SAVE ADDR                                 00028200
         SR    8,7            LENGTH                                    00028300
         BZ    ZDESCR         ZERO DESC IF NO LENGTH                    00028400
         LA    11,60          60 IS MAX ALLOWED LENGTH                  00028500
         CR    8,11           IS MAX EXCEEDED                           00028600
         BNH   STLENGTH                                                 00028700
         LR    8,11                                                     00028800
STLENGTH BCTR  8,0            ONE LESS FOR DESCRIPTOR                   00028900
         STC   8,VALS(6)      PUT IN LENGTH                             00029000
         BR    5              RETURN                                    00029100
ZDESCR   ST    8,VALS(6)                                                00029200
         BR    5              RETURN                                    00029300
*                                                                       00029400
*        DECIMAL HANDLER                                                00029500
*                                                                       00029600
DECIMAL  SR    11,11                                                    00029700
         SR    10,10                                                    00029800
         LA    8,1(8,1)       ONE PAST LAST CHAR                        00029900
         LA    7,1(4,1)       FIRST CHAR AFTER =                        00030000
         LA    9,C'0'                                                   00030100
         B     DGCHECK                                                  00030200
DGLP     IC    10,0(0,7)      GET A CHAR                                00030300
         SR    10,9                                                     00030400
         BM    DGDN           WASN'T A DIGIT, SO DONE                   00030500
         LR    0,11                                                     00030600
         SLL   11,2           *4                                        00030700
         AR    11,0           *5                                        00030800
         AR    11,11          *10                                       00030900
         AR    11,10          ADD IN NEW DIGIT                          00031000
         LA    7,1(0,7)       INCR PTR                                  00031100
DGCHECK  CR    7,8                                                      00031200
         BL    DGLP                                                     00031300
DGDN     ST    11,VALS(6)                                               00031400
         BR    5                                                        00031500
FLAGS    DC    X'00'                                                    00031600
ALIASN   EQU   X'01'          LEADING "N" ON OPTION                     00031700
NOALIAS  EQU   X'02'          NO ALIAS PRESENT                          00031800
OPTSAVE  DS    16F                                                      00031900
F4       DC    F'4'                                                     00032000
NOCHAR   DC    CL2'NO'                                                  00032100
AILCOMP  CLC   1(0,12),0(1)                                             00032200
COMP1    CLC   7(0,2),0(1)                                              00032300
COMP2    CLC   0(0,11),0(1)                                             00032400
COMP2AIL CLC   1(0,12),0(1)                                             00032500
H2       DC    H'2'                                                     00032600
OPTMASK  DS    F                                                        00032700
LNGTHMOD DC    X'02000000'                                              00032800
DESCSAVE ST    4,CON(6)                                                 00032900
         ST    4,PRO(6)                                                 00033000
ENDOPT   DC    A(TYPE1END)    END OF THE OPTIONS LIST                   00033100
ENDPRINT DC    A(ENDCON-CON)  SIZE OF CON (OR PRO) DESCRIPTORS          00033200
ENDOPT2  DC    A(VALS-DESC)    END OF PRINTABLE TYPE2 OPTIONS           00033300
*                                                                       00033400
*        NOW INVOKE THE TYPE1OPT MACRO TO GENERATE THE ACTUAL TABLES    00033500
*        WITH DEFAULTS AND POSSIBLE ALIASES.                            00033600
*        THE MACRO ACCEPTS ARGUMENTS OF THE FORM:                       00033700
*              (<KEYWORD>,'<BIT PATTERN>',<DEFAULT>,<ALIAS>)            00033800
*        SEPERATED BY COMMAS WHERE                                      00033900
*              <KEYWORD>      IS THE DESIRED OPTION                     00034000
*              <BIT PATTERN>  IS AN EIGHT CHARACTER STRING              00034100
*                             OF DIGITS. THE DIGITS MUST DEFINE         00034200
*                             A ONE BIT MASK WHICH WILL BE              00034300
*                             USED TO INDICATE THE PRESENCE             00034400
*                             OF THE ASSOCIATED OPTION. THE             00034500
*                             STRING MUST CONSIST OF ONLY               00034600
*                             THE DIGITS 0, 1, 2, 4, AND 8              00034700
*                             AND ONLY ONE BIT MAY BE INDICATED.        00034800
*              <DEFAULT>      MAY BE EITHER "ON" OR "OFF"               00034900
*                             TO INDICATE THE DEFAULT STATUS            00035000
*                             OF THE ASSOCIATED OPTION.                 00035100
*              <ALIAS>        IS OPTIONAL, AND IF PRESENT INDICATES     00035200
*                             AN ALTERNATE <KEYWORD> FOR THE OPTION.    00035300
*                                                                       00035400
*        THE 3 OR 4-PART ARGUMENTS TO THE MACRO MUST BE ORGANIZED INTO  00035500
*        TWO GROUPS: (1) OPTIONS WHOSE SETTINGS ARE PRINTED BY THE      00035600
*        COMPILER. (2) INTERNAL OPTIONS WHICH ARE CHECKED, BUT          00035700
*        WHOSE SETTINGS ARE NOT PRINTED BY THE COMPILER. THE            00035800
*        PRINTABLE OPTIONS MUST BE SPECIFIED FIRST, FOLLOWED            00035900
*        BY AN ARGUMENT OF THE FORM:                                    00036000
*              'END OF PRINTABLE OPTIONS'                               00036100
*        AND THEN FOLLOWED BY THE NON-PRINTED OPTIONS.                  00036200
*                                                                       00036300
         OPARM                                                          00036310
         SPACE 1                                                        00036311
         AIF (&BF).B1                                                   00036320
         AIF (&H3).H1                                                   00036330
         TYPE1OPT (DUMP,'00000001',OFF,DP),                            X00036400
               (LISTING2,'00000002',OFF,L2),                           X00036500
               (LIST,'00000004',OFF,L),                                X00036600
               (TRACE,'00000008',ON,TR),                               X00036700
               (VARSYM,'00000040',OFF,VS),                             X00036750
               (DECK,'00400000',OFF,D),                                X00036800
               (TABLES,'00000800',ON,TBL),                             X00036900
               (TABLST,'00008000',OFF,TL),                             X00037000
               (ADDRS,'00100000',OFF,A),                               X00037100
               (SRN,'00080000',OFF),                                   X00037200
               (SDL,'00800000',OFF),                                   X00037300
               (TABDMP,'00001000',OFF,TBD),                            X00037400
               (ZCON,'00000400',ON,Z),                                 X00037500
               (HALMAT,'00040000',OFF,HM),                             X00037600
               (REGOPT,'02000000',OFF,R),                              X00037700
               (MICROCODE,'04000000',ON,MC),                           X00037800
               (SREF,'00002000',OFF,SR),                               X00037900
               (QUASI,'20000000',OFF,Q),                               X00037910
               (TEMPLATE,'00000010',OFF,TP),                           X00037920
               (HIGHOPT,'00000080',OFF,HO),                            X00038800
               'END OF TYPE1 OPTIONS TO BE PRINTED BY COMPILER',       X00038000
               (PARSE,'00010000',OFF,P),                               X00038100
               (LSTALL,'00020000',OFF,LA),                             X00038200
               (LFXI,'00200000',ON),                                   X00038300
               (X1,'00000020',OFF),                                    X00038600
               (X4,'00000100',OFF),                                    X00038900
               (X5,'00000200',OFF),                                    X00039000
               (XA,'00004000',OFF),                                    X00039100
               (X6,'01000000',OFF),                                    X00039200
               (XB,'08000000',OFF),                                    X00039300
               (XC,'10000000',OFF),                                    X00039400
               (XE,'40000000',OFF),                                    X00039500
               (XF,'80000000',OFF)                                      00039600
         AGO  .P2                                                       00039601
.B1      ANOP                                                           00039602
         TYPE1OPT (DUMP,'00000001',OFF,DP),                            X00039603
               (LISTING2,'00000002',OFF,L2),                           X00039604
               (LIST,'00000004',OFF,L),                                X00039605
               (TRACE,'00000008',ON,TR),                               X00039606
               (VARSYM,'00000040',OFF,VS),                             X00039607
               (DECK,'00400000',OFF,D),                                X00039608
               (TABLES,'00000800',ON,TBL),                             X00039609
               (TABLST,'00008000',OFF,TL),                             X00039610
               (ADDRS,'00100000',OFF,A),                               X00039611
               (SRN,'00080000',OFF),                                   X00039612
               (SDL,'00800000',OFF),                                   X00039613
               (TABDMP,'00001000',OFF,TBD),                            X00039614
               (ZCON,'00000400',ON,Z),                                 X00039615
               (HALMAT,'00040000',OFF,HM),                             X00039616
               (SCAL,'02000000',ON,SC),                                X00039617
               (MICROCODE,'04000000',ON,MC),                           X00039618
               (SREF,'00002000',OFF,SR),                               X00039619
               (QUASI,'20000000',OFF,Q),                               X00039620
               (REGOPT,'40000000',OFF,R),                              X00039621
               (TEMPLATE,'00000010',OFF,TP),                           X00039622
               (HIGHOPT,'00000080',OFF,HO),                            X00039628
               'END OF TYPE1 OPTIONS TO BE PRINTED BY COMPILER',       X00039623
               (PARSE,'00010000',OFF,P),                               X00039624
               (LSTALL,'00020000',OFF,LA),                             X00039625
               (LFXI,'00200000',ON),                                   X00039626
               (X1,'00000020',OFF),                                    X00039627
               (X4,'00000100',OFF),                                    X00039629
               (X5,'00000200',OFF),                                    X00039630
               (XA,'00004000',OFF),                                    X00039631
               (X6,'01000000',OFF),                                    X00039632
               (XB,'08000000',OFF),                                    X00039633
               (XC,'10000000',OFF),                                    X00039634
               (XF,'80000000,OFF)                                       00039635
         AGO  .P2                                                       00039636
.H1      ANOP                                                           00039637
         TYPE1OPT (DUMP,'00000001',OFF,DP),                            X00039638
               (LISTING2,'00000002',OFF,L2),                           X00039639
               (LIST,'00000004',OFF,L),                                X00039640
               (TRACE,'00000008',ON,TR),                               X00039650
               (DECK,'00400000',OFF,D),                                X00039670
               (TABLES,'00000800',ON,TBL),                             X00039680
               (TABLST,'00008000',OFF,TL),                             X00039690
               (ADDRS,'00100000',OFF,A),                               X00039691
               (SRN,'00080000',OFF),                                   X00039692
               (SDL,'00800000',OFF),                                   X00039693
               (TABDMP,'00001000',OFF,TBD),                            X00039694
               (ZCON,'00000400',ON,Z),                                 X00039695
               (FCDATA,'00040000',OFF,FD),                             X00039696
               (SCAL,'02000000',ON,SC),                                X00039697
               (MICROCODE,'04000000',ON,MC),                           X00039698
               (SREF,'00002000',OFF,SR),                               X00039699
               (QUASI,'20000000',OFF,Q),                               X00039700
               'END OF TYPE1 OPTIONS TO BE PRINTED BY COMPILER',       X00039702
               (PARSE,'00010000',OFF,P),                               X00039703
               (LSTALL,'00020000',OFF,LA),                             X00039704
               (LFXI,'00200000',ON),                                   X00039705
               (X0,'00000010',OFF),                                    X00039706
               (X1,'00000020',OFF),                                    X00039707
               (X2,'00000040',OFF),                                    X00039708
               (X3,'00000080',OFF),                                    X00039709
               (X4,'00000100',OFF),                                    X00039710
               (X5,'00000200',OFF),                                    X00039711
               (XA,'00004000',OFF),                                    X00039712
               (X6,'01000000',OFF),                                    X00039713
               (XB,'08000000',OFF),                                    X00039714
               (XC,'10000000',OFF),                                    X00039715
               (XE,'40000000',OFF),                                    X00039716
               (XF,'80000000',OFF)                                      00039717
.P2      ANOP                                                           00039718
         EJECT                                                          00039720
*                                                                       00039800
*        NOW INVOKE THE TYPE2OPT MACRO TO GENERATE THE TYPE2            00039900
*        TABLES WITH DEFAULTS.                                          00040000
*        THE MACRO ACCEPTS ARGUMENTS OF THE FORM:                       00040100
*              (<KEYWORD>,<HANDLER>,<DEFAULT>,<ALIAS>)                  00040200
*        SEPERATED BY COMMAS WHERE                                      00040300
*              <KEYWORD>      IS THE DESIRED TYPE2 OPTION (WITHOUT "=") 00040400
*              <HANDLER>      IS THE LABEL OF THE HANDLER THAT IS TO    00040500
*                             GET CONTROL WHEN <OPTION> IS ENCOUNTERED. 00040600
*              <DEFAULT>      IS A SPECIFICATION OF THE VALUE TO BE     00040700
*                             GENERATED AS THE DEFAULT VALUE.           00040800
*              <ALIAS>        IS OPTIONAL, AND IF PRESENT INDICATES     00040900
*                             AN ALTERNATE <KEYWORD> FOR THE OPTION     00041000
*                             (AGAIN SPECIFIED WITHOUT AN "=").         00041100
*                                                                       00041200
*        A SEPERATION OF PRINTED OPTIONS FROM NON-PRINTED OPTIONS IS    00041300
*        PERFORMED IN THE SAME WAY AS IN THE TYPE1OPT MACRO.            00041400
*        NOTE THAT CERTAIN OPTIONS' POSITIONS ARE DEPENDED UPON         00041500
*        IN THE MONITOR THAT CALLS THE OPTION PROCESSOR                 00041600
*                                                                       00041700
         AIF (&BF).B2                                                   00041710
         AIF (&H3).H2                                                   00041720
         TYPE2OPT (TITLE,TITLE,F'0',T),                                X00041800
               (LINECT,DECIMAL,F'59',LC),                              X00041900
               (PAGES,DECIMAL,F'2500',P),                              X00042000
               (SYMBOLS,DECIMAL,F'200',SYM),                           X00042100
               (MACROSIZE,DECIMAL,F'500',MS),                          X00042200
               (LITSTRINGS,DECIMAL,F'2000',LITS),                      X00042300
               (COMPUNIT,DECIMAL,F'0',CU),                             X00042400
               (XREFSIZE,DECIMAL,F'2000',XS),                          X00042500
               (CARDTYPE,TITLE,F'0',CT),                               X00042600
               (LABELSIZE,DECIMAL,F'1200',LBLS),                       X00042700
               (DSR,DECIMAL,F'1'),                                     X00042800
               (BLOCKSUM,DECIMAL,F'400',BS),                           X00042810
               (MFID,TITLE,F'0'),                                      X00042811
               'END OF PRINTABLE TYPE 2 OPTIONS'                        00042900
         AGO  .E                                                        00042901
.B2      ANOP                                                           00042902
         TYPE2OPT (TITLE,TITLE,F'0',T),                                X00042903
               (LINECT,DECIMAL,F'59',LC),                              X00042904
               (PAGES,DECIMAL,F'2500',P),                              X00042905
               (SYMBOLS,DECIMAL,F'200',SYM),                           X00042906
               (MACROSIZE,DECIMAL,F'500',MS),                          X00042907
               (LITSTRINGS,DECIMAL,F'2000',LITS),                      X00042908
               (COMPUNIT,DECIMAL,F'0',CU),                             X00042909
               (XREFSIZE,DECIMAL,F'2000',XS),                          X00042910
               (CARDTYPE,TITLE,F'0',CT),                               X00042911
               (LABELSIZE,DECIMAL,F'1200',LBLS),                       X00042912
               (DSR,DECIMAL,F'1'),                                     X00042913
               (BLOCKSUM,DECIMAL,F'400',BS),                           X00042914
               (OLDTPL,TITLE,F'0'),                                    X00042915
               'END OF PRINTABLE TYPE 2 OPTIONS'                        00042916
         AGO  .E                                                        00042917
.H2      ANOP                                                           00042918
         TYPE2OPT (TITLE,TITLE,F'0',T),                                X00042920
               (LINECT,DECIMAL,F'59',LC),                              X00042930
               (PAGES,DECIMAL,F'250',P),                               X00042940
               (SYMBOLS,DECIMAL,F'200',SYM),                           X00042950
               (MACROSIZE,DECIMAL,F'500',MS),                          X00042960
               (LITSTRINGS,DECIMAL,F'2000',LITS),                      X00042970
               (COMPUNIT,DECIMAL,F'0',CU),                             X00042980
               (XREFSIZE,DECIMAL,F'2000',XS),                          X00042990
               (CARDTYPE,TITLE,F'0',CT),                               X00042991
               (LABELSIZE,DECIMAL,F'1200',LBLS),                       X00042992
               (DSR,DECIMAL,F'1'),                                     X00042993
               (BLOCKSUM,DECIMAL,F'400',BS),                           X00042994
               'END OF PRINTABLE TYPE 2 OPTIONS'                        00042996
.E       ANOP                                                           00042997
         END                                                            00043000
