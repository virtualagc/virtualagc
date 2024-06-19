*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ETOC.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

   TITLE 'ETOC -- SCALAR TO CHARACTER INTERNAL CONVERSION'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
* ETOC: SCALAR(SINGLE) TO CHARACTER                                     00000200
*                                                                       00000300
*        1. INPUT IN F0.                                                00000400
*        2. OUTPUT CHARACTER POINTER IN R2(PASSED AS INPUT PARM).       00000500
*                                                                       00000600
         MACRO                                                          00000700
         WORKAREA                                                       00000800
SWITCH   DS    H                                                        00000900
SAVEF6   DS    D              ADDED FOR QDED USAGE DWE                  00001000
         MEND                                                           00001100
*                                                                       00001200
ETOC     AMAIN QDED=YES                                                 00001300
*                                                                       00001400
*  CONVERTS SCALAR SP TO CHARACTER STRING                               00001500
*                                                                       00001600
         INPUT F0             SCALAR  SP                                00001700
         OUTPUT R2            CHARACTER(14)                             00001800
         WORK  R1,R3,R4,R5,R6,R7,F1,F2,F4                               00001900
*                                                                       00002000
*                                                                       00002100
*                                                                       00002200
*                                                                       00002300
*  FIRST HALFWORD                                                       00002400
*                                                                       00002500
         SER   F1,F1          CLEAR LOW HALF F0                         00002600
         ZH    SWITCH         FLAG=0 FOR SINGLE                         00002700
         LHI   R4,X'000E'     LENGTH=14                                 00002800
         B     SIGN                                                     00002900
*                                                                       00003000
DTOC     AENTRY                                                         00003100
*                                                                       00003200
* CONVERT SCALAR DP TO CHARACTER STRING                                 00003300
*                                                                       00003400
         INPUT F0             SCALAR  DP                                00003500
         OUTPUT R2            CHARACTER(23)                             00003600
         WORK  R1,R3,R4,R5,R6,R7,F1,F2,F4                               00003700
*                                                                       00003800
*                                                                       00003900
*                                                                       00004000
         ZH    SWITCH                                                   00004100
         SB    SWITCH,DPREC   INDICATE DOUBLE ENTRY                     00004200
         LHI   R4,X'0017'     LENGTH=23                                 00004300
*                                                                       00004400
*  GET SIGN                                                             00004500
*                                                                       00004600
SIGN     LH    R3,0(R2)                                                 00004700
         NHI   R3,X'FF00'     MAXLENGTH                                 00004800
         AR    R4,R3          PUT IN NEW CURRLEN                        00004900
         STH   R4,0(R2)       AND STORE IN STRING                       00005000
         LHI   R4,X'2000'     FIRST CHAR = ' ' IF X>0                   00005100
         LER   F0,F0                                                    00005200
         BZ    PUT0           OUTPUT=' 0.0' IF X=0                      00005300
         BP    GETEXP                                                   00005400
         LECR  F0,F0                                                    00005500
         LHI   R4,X'2D00'     FIRST CHAR = '-' IF X<0                   00005600
*                                                                       00005700
*  MULTIPLY BY POWERS OF 10 TO BRING EXPONENT TO X'41',                 00005800
*    MEANWHILE KEEPING TRACK OF THE POWERS FOR EXPONENT PRINTOUT        00005900
*                                                                       00006000
GETEXP   XR    R3,R3          INITIALIZE EXPONENT TO 0                  00006100
START    XR    R1,R1                                                    00006200
         LFXR  R6,F0                                                    00006300
         SRL   R6,24                                                    00006400
         S     R6,=F'65'                                                00006500
         BZ    CVDEC          EXIT                                      00006600
         BP    MUL16                                                    00006700
         LA    R1,1           R1=1 FOR <0                               00006800
         LACR  R6,R6                                                    00006900
*                                                                       00007000
MUL16    M     R6,LOG16       LOG X(BASE 10)=LOG 16*LOG X(BASE 16)      00007100
         A     R7,=F'16384'   ROUND LOG X                               00007200
         SLDL  R6,17          AND SHIFT TO TOP HALFWORD                 00007300
*                                                                       00007400
ARSR     LR    R5,R1                                                    00007500
         BZ    ADD                                                      00007600
         SR    R3,R6          ACCUMULATE EXPONENT IN R3                 00007700
         B     PWR10                                                    00007800
ADD      AR    R3,R6          ACCUMULATE EXPONENT IN R3                 00007900
*                                                                       00008000
*  DO POWERS OF 10                                                      00008100
*                                                                       00008200
PWR10    SLL   R6,16                                                    00008300
         LR    R7,R6                                                    00008400
         M     R7,TENTH                                                 00008500
         LA    R7,0(R7,3)     ZERO OUT BOTTOM HALF R7                   00008600
*  INDEX WITH R7 FOR TENS                                               00008700
         LA    R1,TENSTBL                                               00008800
         LR    R7,R7                                                    00008900
         BZ    UNITS                                                    00009000
         BCTB  R7,*+1                                                   00009100
         LR    R5,R5                                                    00009200
         BNZ   NEG1           MULTIPLY IF EXP<0                         00009300
         STED  6,SAVEF6       STORE F6                                  00009400
         LED   6,0(R7,R1)      LOAD ARG FOR QDEDR IN F6                 00009500
        QDEDR  F0,6                                                     00009600
         LED   6,SAVEF6       RESTORE F6                                00009700
         B     RESTORE                                                  00009800
NEG1     MED   F0,0(R7,R1)                                              00009900
RESTORE  AHI   R7,1                                                     00010000
         MIH   R7,F10                                                   00010100
*                                                                       00010200
UNITS    SR    R6,R7                                                    00010300
         BZ    START                                                    00010400
         BCTB  R6,*+1                                                   00010500
         LR    R5,R5                                                    00010600
         BNZ   NEG2           MULTIPLY IF EXP<0                         00010700
         STED  6,SAVEF6       STORE F6                                  00010800
         LED   6,28(R6,R1)    LOAD ARG FOR QDEDR IN F6                  00010900
        QDEDR  F0,6                                                     00011000
         LED   6,SAVEF6       RESTORE F6                                00011100
         B     START                                                    00011200
NEG2     MED   F0,28(R6,R1)                                             00011300
         B     START                                                    00011400
*                                                                       00011500
*  HERE, EXPONENT IS X'41'. NOW, MAKE SURE 1<=X<10                      00011600
*                                                                       00011700
CVDEC    SLL   R3,16                                                    00011800
         CE    F0,TEN                                                   00011900
         BL    DIGIT                                                    00012000
         MED   F0,FTENTH                                                00012100
         LA    R3,1(R3)       INCREASE EXPONENT BY 1                    00012200
*                                                                       00012300
*  CONVERT TO DECIMAL HERE. THE FIRST HEX DIGIT OF THE MANTISSA         00012400
*   IS THE DECIMAL DIGIT BEFORE THE POINT FOR BOTH SINGLE AND           00012500
*   DOUBLE PRECISION.                                                   00012600
*                                                                       00012700
DIGIT    LFXR  R7,F0                                                    00012800
         NHI   R7,X'F0'                                                 00012900
         SRL   R7,4                                                     00013000
         AHI   R7,X'30'       FIRST DIGIT IN R7                         00013100
         AR    R4,R7          R4 ALREADY CONTAINS THE SIGN, IF ANY      00013200
         STH   R4,1(R2)       STORE FIRST HALFWORD OF STRING            00013300
*                                                                       00013400
*  THE METHOD USED TO CONVERT TO DECIMAL IS TO MULTIPLY                 00013500
*  THE FRACTION BY 10 BY MULTIPLYING BY 2 AND 8, AND ADDING             00013600
*  THE RESULTS TOGETHER, THUS PRESERVING PRECISION.                     00013700
*                                                                       00013800
DOUBLE   LFLR  F2,R3          SAVE EXPONENT IN F2                       00013900
         XR    R6,R6                                                    00014000
         SPM   R6             MASK FIXED-POINT OVERFLOW                 00014100
         LA    R1,2(R2)       UPDATE AND SAVE POINTER                   00014200
         LFXR  R2,F0          GET ADJUSTED NUMBER                       00014300
         LFXR  R3,F1          IN REGISTERS R2-R3.                       00014400
         SLDL  R2,4           ELIMINATE INTEGER PART                    00014500
         ZRB   R2,X'FF00'                                               00014600
         LR    R6,R2          GET FRACTION IN                           00014700
         LR    R7,R3          REGISTERS R6-R7.                          00014800
         SLDL  R6,1           2*FRACTION                                00014900
         SLDL  R2,3           8*FRACTION                                00015000
         AR    R6,R2                                                    00015100
         AR    R7,R3                                                    00015200
         BNC   OK0            SKIP NEXT IF NO CARRY OUT OF R7           00015300
         A     R6,FONE                                                  00015400
OK0      LR    R4,R6                                                    00015500
         NHI   R4,X'0F00'     ONE DIGIT IN R4                           00015600
         SR    R6,R4          NEW FRACTION IN R6-R7                     00015700
         SRL   R4,8           SHIFT DIGIT INTO POSITION                 00015800
         AHI   R4,X'2E30'     CONVERT DIGIT TO CHARACTER                00015900
         STH   R4,0(R1)       '.D' STORED                               00016000
         LA    R1,1(R1)                                                 00016100
*                                                                       00016200
* NOW LOOP 3 TIMES FOR SINGLE, 7 TIMES FOR DOUBLE,                      00016300
*  STORING 'DD' EACH TIME.                                              00016400
*                                                                       00016500
         LA    R5,3           LOOP COUNTER                              00016600
         LR    R2,R6          GET UPDATED FRACTION IN                   00016700
         LR    R3,R7          REGISTER PAIR R2-R3.                      00016800
*                                                                       00016900
DLOOP    SLDL  R6,1           2*FRACTION                                00017000
         SLDL  R2,3           8*FRACTION                                00017100
         AR    R6,R2                                                    00017200
         AR    R7,R3                                                    00017300
         BNC   OK1                                                      00017400
         A     R6,FONE                                                  00017500
OK1      LR    R2,R6          10*FRACTION IN R6-R7                      00017600
         LR    R3,R7          AND IN R2-R3.                             00017700
         NHI   R6,X'0F00'     FIRST DIGIT IN R6                         00017800
         SR    R2,R6          FRACTION IN R2-R3                         00017900
         LR    R4,R6          ONE DIGIT IN R4                           00018000
         LR    R6,R2          FRACTION IN R6-R7                         00018100
*  REPEAT ABOVE PROCESS FOR SECOND DIGIT OF THE PAIR                    00018200
         SLDL  R6,1                                                     00018300
         SLDL  R2,3                                                     00018400
         AR    R6,R2                                                    00018500
         AR    R7,R3                                                    00018600
         BNC   OK2                                                      00018700
         A     R6,FONE                                                  00018800
OK2      LR    R2,R6                                                    00018900
         LR    R3,R7                                                    00019000
         NHI   R6,X'0F00'                                               00019100
         SR    R2,R6                                                    00019200
         SRL   R6,8                                                     00019300
         AR    R4,R6          TWO DIGITS IN R4                          00019400
         LR    R6,R2          FRACTION IN R6-R7                         00019500
*                                                                       00019600
         AHI   R4,X'3030'     CONVERT TO CHARACTER                      00019700
         STH   R4,0(R1)       AND STORE IN STRING                       00019800
         LA    R1,1(R1)                                                 00019900
         BCT   R5,DLOOP                                                 00020000
         TB    SWITCH,DPREC   IF ETOC ENTRY, GO                         00020100
         BZ    SINGLE         TO SINGLE EXPONENT SECTION                00020200
         TB    SWITCH,LOOPQ   IF FLAG IS ON, 7                          00020300
         BNZ   LDIG           DIGIT PAIRS ALREADY STORED.               00020400
         SB    SWITCH,LOOPQ   OTHERWISE, GO BACK FOR                    00020500
         LHI   R5,4           FOUR MORE LOOPS.                          00020600
         B     DLOOP                                                    00020700
*                                                                       00020800
*  LAST DIGIT BEFORE EXPONENT                                           00020900
*                                                                       00021000
LDIG     SLL   R2,7           LAST DIGIT DOES NOT                       00021100
         M     R2,F10L        DEPEND ON R3.                             00021200
         NHI   R2,X'0F00'                                               00021300
         AHI   R2,X'3045'                                               00021400
         STH   R2,0(R1)       'DE' STORED                               00021500
*                                                                       00021600
*  COMPUTE EXPONENT IN DECIMAL                                          00021700
*                                                                       00021800
         LFXR  R3,F2          RECOVER EXPONENT                          00021900
         LHI   R4,X'2B00'                                               00022000
         LR    R3,R3                                                    00022100
         BNM   XPOS                                                     00022200
         LHI   R4,X'2D00'                                               00022300
         LACR  R3,R3                                                    00022400
*                                                                       00022500
XPOS     LR    R6,R3                                                    00022600
         MH    R6,TENTH                                                 00022700
         AR    R4,R6                                                    00022800
         AHI   R4,X'0030'                                               00022900
         STH   R4,1(R1)                                                 00023000
         MIH   R6,F10                                                   00023100
         SR    R3,R6                                                    00023200
         SLL   R3,8                                                     00023300
         AHI   R3,X'3000'                                               00023400
         STH   R3,2(R1)                                                 00023500
         B     EXIT                                                     00023600
*                                                                       00023700
*  SINGLE PRECISION SECTION                                             00023800
*                                                                       00023900
SINGLE   LHI   R4,X'452B'     C'E+'                                     00024000
         LFXR  R3,F2          RECOVER EXPONENT                          00024100
         LR    R3,R3                                                    00024200
         BNM   EDIGIT                                                   00024300
MINUSX   LHI   R4,X'452D'     C'E-'                                     00024400
         LACR  R3,R3                                                    00024500
*                                                                       00024600
*  STORE 'E+' OR 'E-', THEN CONVERT EXPONENT TO DECIMAL                 00024700
*   AND STORE EXPONENT IN LAST HALFWORD                                 00024800
*                                                                       00024900
EDIGIT   STH   R4,0(R1)                                                 00025000
         LR    R6,R3                                                    00025100
         MH    R6,TENTH                                                 00025200
         LA    R4,0(R6,3)                                               00025300
         SLL   R4,8                                                     00025400
         MIH   R6,F10                                                   00025500
         SR    R3,R6                                                    00025600
         AR    R4,R3                                                    00025700
         AHI   R4,X'3030'                                               00025800
         STH   R4,1(R1)                                                 00025900
EXIT     L     R4,8(0)        RECOVER OLD PROGRAM MASK                  00026000
         SPM   R4             RESTORE INTERRUPT ENVIRONMENT             00026100
         AEXIT                AND EXIT                                  00026200
*                                                                       00026300
*  PUT0:  FOR INPUT SCALAR VALUE OF EXACTLY 0,                          00026400
*  OUTPUT=' 0.0         ' FOR SINGLE OR ' 0.0                  '        00026500
*  FOR DOUBLE PRECISION                                                 00026600
*                                                                       00026700
PUT0     LHI   R7,5                                                     00026800
         TB    SWITCH,DPREC                                             00026900
         BZ    ADDOFF                                                   00027000
         LHI   R7,10                                                    00027100
ADDOFF   A     R2,OFFSET                                                00027200
         LH    R4,STRING0                                               00027300
         STH#  R4,0(R2,3)                                               00027400
         LH    R4,STRING0+1                                             00027500
         STH#  R4,0(R2,3)                                               00027600
LOOP0    LH    R4,BLANKS                                                00027700
         STH#  R4,0(R2,3)                                               00027800
         BCT   R7,LOOP0                                                 00027900
         B     EXIT                                                     00028000
*                                                                       00028100
         DS    0F                                                       00028200
F10      DC    X'000A0000'                                              00028300
TENTH    DC    F'0.1001'                                                00028400
OFFSET   DC    X'00010001'                                              00028500
STRING0  DC    X'20302E30'    C' 0.0'                                   00028600
BLANKS   DC    X'2020'                                                  00028700
LOG16    DC    F'19728'                                                 00028800
F10L     DC    X'0A000000'                                              00028900
FONE     DC    X'00000001'                                              00029000
FTENTH   DC    D'1E-1'                                                  00029100
H78      DC    H'78'                                                    00029200
DPREC    EQU   X'8000'                                                  00029300
LOOPQ    EQU   X'4000'                                                  00029400
         ADATA                                                          00029500
TENSTBL  DC    D'1E10,1E20,1E30,1E40,1E50,1E60,1E70'                    00029600
TEN      DC    D'1E1,1E2,1E3,1E4,1E5,1E6,1E7,1E8,1E9'                   00029700
         ACLOSE                                                         00029800
