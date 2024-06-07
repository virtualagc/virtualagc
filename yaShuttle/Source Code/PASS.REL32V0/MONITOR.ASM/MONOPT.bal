*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MONOPT.bal
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
.INCRI   ANOP                                                           00013110
&I       SETA  &I+1                                                     00013200
         AIF   ('&SYSLIST(&I,2)' NE '').LOOP3                           00013300
&I       SETA  &I+1                                                     00013400
         AIF   (&I LE N'&SYSLIST).LOOP3                                 00013500
         MEND                                                           00013600
         EJECT                                                          00013700
XXXOPT   CSECT                                                          00013800
         USING *,15                                                     00013900
         SAVE  (14,12),T                                                00014000
         ST    13,SAVE+4                                                00014100
         LA    15,SAVE                                                  00014200
         ST    15,8(0,13)                                               00014300
         LR    13,15                                                    00014400
         BALR  10,0                                                     00014500
         USING *,10                                                     00014600
         DROP  15                                                       00014700
         LH    4,0(0,1)       LENGTH OF PARM FIELD                      00014800
         LA    8,2(0,1)       ADDR OF PARM STRING                       00014900
         LA    4,0(8,4)       ADDR OF END OF STRING                     00015000
         BCTR  8,0                                                      00015100
NEXT     LA    1,1(0,8)       R1 POINTS TO NEXT CHAR                    00015200
         CR    1,4            ARE WE DONE                               00015300
         BL    COMMAS         NO, LOOK FOR NEXT COMMA                   00015400
         L     1,=V(OPTIONS)  ADDR OF OPTIONS PARAMETERS                00015410
         L     13,SAVE+4      RELOAD R13                                00015500
         ST    1,24(0,13)     SAVE FOR RETURN AS R1                     00015510
         RETURN (14,12)                                                 00015600
COMMAS   LA    8,1(0,8)                                                 00015700
         CLI   0(8),C','                                                00015800
         BE    CALLOPT                                                  00015900
         CR    8,4                                                      00016000
         BL    COMMAS                                                   00016100
CALLOPT  CR    1,8                                                      00016200
         BE    NEXT                                                     00016300
         L     15,=V(OPTPROC)                                           00016400
         BALR  14,15                                                    00016500
         B     NEXT                                                     00016600
SAVE     DS    18F                                                      00016700
         LTORG                                                          00016800
         EJECT                                                          00016900
OPTPROC  CSECT                                                          00017000
         PRINT DATA                                                     00017100
         USING *,15                                                     00017200
         ENTRY OPTIONS                                                  00017300
         STM   0,15,OPTSAVE                                             00017400
         L     0,OPTIONS      PICK UP EXISTING OPTIONS                  00017500
         SR    6,6                                                      00017600
         SR    4,4                                                      00017700
         SR    3,3                                                      00017800
         MVI   FLAGS,X'00'    START CLEAN                               00017900
         LA    2,OPTTAB       POINT TO FIRST OPTION ENTRY               00018000
         CLC   NOCHAR,0(1)    IS A "NO" PRESENT                         00018100
         BNE   NOTNO                                                    00018200
         LA    11,4           SET FOR LATER XOR USE                     00018300
         AH    1,H2           BUMP PTR OVER "NO"                        00018400
         B     SETLEN                                                   00018500
NOTNO    CLI   0(1),C'N'      SHORT FORM NO?                            00018600
         BNE   NOTN                                                     00018700
         LA    11,4           SET FOR LATER                             00018800
         LA    1,1(0,1)       SKIP OVER N                               00018900
         OI    FLAGS,ALIASN   INDICATE SHORT NO FOUND                   00019000
         B     SETLEN                                                   00019010
NOTN     SR    11,11                                                    00019100
SETLEN   SR    8,1            LENGTH OF OPTION IN PARM FIELD            00019200
         BCTR  8,0                                                      00019300
CHECK1   NI    FLAGS,X'FF'-NOALIAS RESET FOR THIS OPTION                00019310
         IC    4,4(0,2)       LENGTH OF "TRUE" CHARACTERS               00019400
         LA    12,8(4,2)      ADDR OF ALIAS LENGTH                      00019500
         CLI   0(12),X'FF'    IS THERE AN ALIAS?                        00019600
         BNE   T1AIL          YES                                       00019700
         OI    FLAGS,NOALIAS  INDICATE NO ALIAS                         00019800
         L     3,=F'-1'       FOR ADJUSTMENT OF NEXT OPTION             00019900
         B     T1NOAIL                                                  00020000
T1AIL    SR    3,3                                                      00020010
         IC    3,0(0,12)      LENGTH OF ALIAS                           00020100
T1NOAIL  TM    FLAGS,ALIASN   IF SHORT "NO" THEN                        00020200
         BO    CHECKAIL       NEED ONLY CHECK ALIAS                     00020300
         CR    8,4            ARE LENGTHS THE SAME?                     00020400
         BNE   CHECKAIL       NO, TRY AN ALIAS                          00020500
         EX    4,COMP1        COMPARE                                   00020600
         BNE   CHECKAIL       NO MATCH                                  00020700
FOUNDOPT MVC   OPTMASK,0(2)   COPY MASK TO WORD ALIGN                   00020800
         L     9,OPTMASK      PICK UP MASK                              00020900
         OR    0,9            TURN BIT ON                               00021000
         LTR   11,11          IS "NO" SPECIFIED?                        00021100
         BZ    LEAVEON        NO, LEAVE IT ON                           00021200
         XR    0,9            TURN IT OFF                               00021300
LEAVEON  C     6,ENDPRINT                                               00021400
         BNL   RETURN1        NO NEED TO MAKE DESCRIPTORS               00021500
*        BUILD DESCRIPTOR FOR TRUE OPTION                               00021600
         SLL   4,24           LENGTH FIELD TO HIGH BYTE                 00021700
         LA    5,7(0,2)       ADDR OF STRING                            00021800
         OR    4,5            MAKE DESCRIPTOR                           00021900
         EX    0,DESCSAVE(11) SAVE INTO PROPER SLOT                     00022000
         X     11,F4          SET FOR OTHER SLOT                        00022100
*        NOW MODIFY DESCRIPTOR FOR "NO" OPTION                          00022200
         AL    4,LNGTHMOD     ADD TWO TO LENGTH                         00022300
         SH    4,H2           SUBTRACT TWO FROM ADDR                    00022400
         EX    0,DESCSAVE(11) SAVE IT                                   00022500
RETURN1  ST    0,OPTIONS                                                00022600
RETURN2  LM    0,15,OPTSAVE                                             00022700
         BR    14                                                       00022800
CHECKAIL TM    FLAGS,NOALIAS  IS THERE AN ALIAS?                        00022810
         BO    NEXTOPT1       NO, SKIP                                  00022820
         CR    8,3            CHECK LENGTHS                             00022830
         BNE   NEXTOPT1       SKIP IF NOT EQUAL                         00022840
         EX    3,AILCOMP      COMPARE                                   00022850
         BE FOUNDOPT                                                    00022860
NEXTOPT1 LA    6,4(0,6)       INCREMENT DESCRIPTOR POINTER              00022900
         LA    2,2(3,12)      POINT TO NEXT OPTION ENTRY                00023000
         C     2,ENDOPT                                                 00023100
         BNL   TRYTYPE2                                                 00023200
         B     CHECK1         GO BACK FOR NEXT                          00023300
TRYTYPE2 SR    4,4                                                      00023400
         SR    6,6                                                      00023500
         LA    2,DESC         DESCRIPTOR OF FIRST TYPE2 OPTION          00023600
CHECK2   IC    4,0(0,2)       LENGTH OF OPTION                          00023700
         LA    4,1(0,4)       PLUS 1 FOR '='                            00023800
         SR    11,11                                                    00023810
         A     11,0(0,2)      DESCRIPTOR                                00023820
         BZ    NEXTOPT2       WATCH OUT FOR NULL DESC                   00023830
         CR    8,4                                                      00023840
         BL    TRYAIL2                                                  00023850
         EX    4,COMP2                                                  00024400
         BE    EVALUATE                                                 00024500
TRYAIL2  LA    12,1(4,11)     ADDR OF LENGTH OF AILIAS                  00024510
         CLI   0(12),X'FF'    IS THERE ONE?                             00024520
         BE    NEXTOPT2       SKIP IF NOT                               00024530
         IC    4,0(12)        LENGTH                                    00024540
         CR    8,4                                                      00024550
         BL    NEXTOPT2                                                 00024560
         EX    4,COMP2AIL                                               00024570
         BE    EVALUATE                                                 00024580
NEXTOPT2 LA    6,4(0,6)       NEXT DESCRIPTOR OFFSET                    00024600
         C     6,ENDOPT2                                                00024700
         BNL   RETURN2                                                  00024800
         LA    2,4(0,2)       NEXT DESCRIPTOR                           00024900
         B     CHECK2                                                   00025000
EVALUATE SH    11,H2           POINT AT SL2 ADDR IN FRONT OF STRING     00025100
         MVC   HANDLER,0(11)                                            00025200
         BAL   5,0                                                      00025300
         ORG   *-2                                                      00025400
*                                                                       00025500
*        TITLE HANDLER                                                  00025600
*                                                                       00025700
HANDLER  DC    S(0)                                                     00025800
         B     RETURN2                                                  00025900
TITLE    LA    8,1(8,1)                                                 00026000
         LA    7,1(4,1)                                                 00026100
         ST    7,VALS(6)      SAVE ADDR                                 00026200
         SR    8,7            LENGTH                                    00026300
         BZ    ZDESCR         ZERO DESC IF NO LENGTH                    00026400
         LA    11,60          60 IS MAX ALLOWED LENGTH                  00026500
         CR    8,11           IS MAX EXCEEDED                           00026600
         BNH   STLENGTH                                                 00026700
         LR    8,11                                                     00026800
STLENGTH BCTR  8,0            ONE LESS FOR DESCRIPTOR                   00026900
         STC   8,VALS(6)      PUT IN LENGTH                             00027000
         BR    5              RETURN                                    00027100
ZDESCR   ST    8,VALS(6)                                                00027200
         BR    5              RETURN                                    00027300
*                                                                       00027400
*        DECIMAL HANDLER                                                00027500
*                                                                       00027600
DECIMAL  SR    11,11                                                    00027700
         SR    10,10                                                    00027800
         LA    8,1(8,1)       ONE PAST LAST CHAR                        00027900
         LA    7,1(4,1)       FIRST CHAR AFTER =                        00028000
         LA    9,C'0'                                                   00028100
         B     DGCHECK                                                  00028200
DGLP     IC    10,0(0,7)      GET A CHAR                                00028300
         SR    10,9                                                     00028400
         BM    DGDN           WASN'T A DIGIT, SO DONE                   00028500
         LR    0,11                                                     00028600
         SLL   11,2           *4                                        00028700
         AR    11,0           *5                                        00028800
         AR    11,11          *10                                       00028900
         AR    11,10          ADD IN NEW DIGIT                          00029000
         LA    7,1(0,7)       INCR PTR                                  00029100
DGCHECK  CR    7,8                                                      00029200
         BL    DGLP                                                     00029300
DGDN     ST    11,VALS(6)                                               00029400
         BR    5                                                        00029500
FLAGS    DC    X'00'                                                    00029510
ALIASN   EQU   X'01'          LEADING "N" ON OPTION                     00029520
NOALIAS  EQU   X'02'          NO ALIAS PRESENT                          00029530
OPTSAVE  DS    16F                                                      00029600
F4       DC    F'4'                                                     00029700
NOCHAR   DC    CL2'NO'                                                  00029800
AILCOMP  CLC   1(0,12),0(1)                                             00029810
COMP1    CLC   7(0,2),0(1)                                              00029900
COMP2    CLC   0(0,11),0(1)                                             00030000
COMP2AIL CLC   1(0,12),0(1)                                             00030010
H2       DC    H'2'                                                     00030100
OPTMASK  DS    F                                                        00030200
LNGTHMOD DC    X'02000000'                                              00030300
DESCSAVE ST    4,CON(6)                                                 00030400
         ST    4,PRO(6)                                                 00030500
ENDOPT   DC    A(TYPE1END)    END OF THE OPTIONS LIST                   00030600
ENDPRINT DC    A(ENDCON-CON)  SIZE OF CON (OR PRO) DESCRIPTORS          00030700
ENDOPT2  DC    A(VALS-DESC)    END OF PRINTABLE TYPE2 OPTIONS           00030800
*                                                                       00030900
*        NOW INVOKE THE TYPE1OPT MACRO TO GENERATE THE ACTUAL TABLES    00031000
*        WITH DEFAULTS AND POSSIBLE ALIASES.                            00031100
*        THE MACRO ACCEPTS ARGUMENTS OF THE FORM:                       00031200
*              (<KEYWORD>,'<BIT PATTERN>',<DEFAULT>,<ALIAS>)            00031300
*        SEPERATED BY COMMAS WHERE                                      00031400
*              <KEYWORD>      IS THE DESIRED OPTION                     00031500
*              <BIT PATTERN>  IS AN EIGHT CHARACTER STRING              00031600
*                             OF DIGITS. THE DIGITS MUST DEFINE         00031700
*                             A ONE BIT MASK WHICH WILL BE              00031800
*                             USED TO INDICATE THE PRESENCE             00031900
*                             OF THE ASSOCIATED OPTION. THE             00032000
*                             STRING MUST CONSIST OF ONLY               00032100
*                             THE DIGITS 0, 1, 2, 4, AND 8              00032200
*                             AND ONLY ONE BIT MAY BE INDICATED.        00032300
*              <DEFAULT>      MAY BE EITHER "ON" OR "OFF"               00032400
*                             TO INDICATE THE DEFAULT STATUS            00032500
*                             OF THE ASSOCIATED OPTION.                 00032600
*              <ALIAS>        IS OPTIONAL, AND IF PRESENT INDICATES     00032610
*                             AN ALTERNATE <KEYWORD> FOR THE OPTION.    00032620
*                                                                       00032630
*        THE 3 OR 4-PART ARGUMENTS TO THE MACRO MUST BE ORGANIZED INTO  00032700
*        TWO GROUPS: (1) OPTIONS WHOSE SETTINGS ARE PRINTED BY THE      00032800
*        COMPILER. (2) INTERNAL OPTIONS WHICH ARE CHECKED, BUT          00032900
*        WHOSE SETTINGS ARE NOT PRINTED BY THE COMPILER. THE            00033000
*        PRINTABLE OPTIONS MUST BE SPECIFIED FIRST, FOLLOWED            00033100
*        BY AN ARGUMENT OF THE FORM:                                    00033200
*              'END OF PRINTABLE OPTIONS'                               00033300
*        AND THEN FOLLOWED BY THE NON-PRINTED OPTIONS.                  00033400
*                                                                       00033500
         TYPE1OPT (DUMP,'00000001',OFF,DP),                            X00033600
               (LISTING2,'00000002',OFF,L2),                           X00033700
               (ALTER,'00000004',OFF),                                 X00033710
               'END OF PRINTABLE TYPE 1 OPTIONS'                        00033810
         EJECT                                                          00036900
*                                                                       00037000
*        NOW INVOKE THE TYPE2OPT MACRO TO GENERATE THE TYPE2            00037100
*        TABLES WITH DEFAULTS.                                          00037200
*        THE MACRO ACCEPTS ARGUMENTS OF THE FORM:                       00037300
*              (<KEYWORD>,<HANDLER>,<DEFAULT>,<ALIAS>)                  00037400
*        SEPERATED BY COMMAS WHERE                                      00037500
*              <KEYWORD>      IS THE DESIRED TYPE2 OPTION (WITHOUT "=") 00037600
*              <HANDLER>      IS THE LABEL OF THE HANDLER THAT IS TO    00037700
*                             GET CONTROL WHEN <OPTION> IS ENCOUNTERED. 00037800
*              <DEFAULT>      IS A SPECIFICATION OF THE VALUE TO BE     00037900
*                             GENERATED AS THE DEFAULT VALUE.           00038000
*              <ALIAS>        IS OPTIONAL, AND IF PRESENT INDICATES     00038010
*                             AN ALTERNATE <KEYWORD> FOR THE OPTION     00038020
*                             (AGAIN SPECIFIED WITHOUT AN "=").         00038030
*                                                                       00038040
*        A SEPERATION OF PRINTED OPTIONS FROM NON-PRINTED OPTIONS IS    00038100
*        PERFORMED IN THE SAME WAY AS IN THE TYPE1OPT MACRO.            00038200
*        NOTE THAT CERTAIN OPTIONS' POSITIONS ARE DEPENDED UPON         00038300
*        IN THE MONITOR THAT CALLS THE OPTION PROCESSOR                 00038400
*                                                                       00038500
         TYPE2OPT (LINECT,DECIMAL,F'59',LC), ***LOCATION DEPENDENT***  X00038600
               (PAGES,DECIMAL,F'250',P), ***LOCATION DEPENDENT***      X00038800
               (MIN,DECIMAL,F'50000'), ***LOCATION DEPENDENT***        X00039700
               (MAX,DECIMAL,F'5000000'), ***LOCATION DEPENDENT***      X00039800
               (FREE,DECIMAL,A(14*1024)), ***LOCATION DEPENDENT***     X00039900
               'END OF PRINTABLE TYPE 2 OPTIONS'                        00039910
         END                                                            00040500
