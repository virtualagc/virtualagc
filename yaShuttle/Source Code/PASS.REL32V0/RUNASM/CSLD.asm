*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CSLD.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CSLD--CHARACTER SUBBIT LOAD AND STORE ROUTINES'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
MASK1    DS    F              TEMPORARY STORAGE                         00000400
MASK2    DS    F              FOR BIT STRING MASK                       00000500
         MEND                                                           00000600
CSLD     AMAIN                                                          00000700
*                                                                       00000800
* OBTAIN THE BIT PATTERN OF A CHARACTER STRING, C1.                     00000900
*                                                                       00001000
         INPUT R2             CHARACTER(C1)                             00001100
         OUTPUT R5            BIT(32)                                   00001200
         WORK  R4,R5,R6,R7                                              00001300
*                                                                       00001400
*                                                                       00001500
*                                                                       00001600
         XR    R5,R5          FIRST CHARACTER-1=0                       00001700
         LH    R6,0(R2)       LOAD DESCRIPTOR OF C1                     00001800
         NHI   R6,X'00FF'     CHARACTER WIDTH=LENGTH(STRING)            00001900
         B     CSLDPX                                                   00002000
CSLDP    AENTRY                                                         00002100
*                                                                       00002200
* OBTAIN THE BIT PATTERN OF THE K TO L PARTITION OF A CHARACTER STRING, 00002300
*   C1.                                                                 00002400
*                                                                       00002500
         INPUT R2,            CHARACTER(C1)                            X00002600
               R5,            INTEGER(K) SP                            X00002700
               R6             INTEGER(L) SP                             00002800
         OUTPUT R5            BIT(32)                                   00002900
         WORK  R1,R4,R7                                                 00003000
*                                                                       00003100
*                                                                       00003200
*                                                                       00003300
         BAL   R4,CPTEST      CHECK OF K AND L                          00003400
         LR    R6,R6          TEST CHARACTER WIDTH                      00003500
CSLDPX   BNZ   CSLDPX2                                                  00003600
RET0     ST    R6,ARG5        IF WIDTH=0,                               00003700
         B     EXIT           RETURN 0 STRING                           00003800
*                                                                       00003900
CSLDPX2  LHI   R7,4                                                     00004000
         CR    R6,R7          COMPARE CHARACTER WIDTH TO 4              00004100
         BNH   WIDTHOK                                                  00004200
         LR    R6,R7          IF >4, SET WIDTH TO 4                     00004300
*                                                                       00004400
WIDTHOK  SR    R7,R6                                                    00004500
         L     R6,=X'0000FFFF'   MASK FOR TWO CHARACTERS                00004600
         AHI   R7,2                                                     00004700
         SLL   R7,3           SHIFT COUNT=48-8*WIDTH                    00004800
         TRB   R5,X'0001'                                               00004900
         BZ    ODDCH                                                    00005000
         L     R6,=X'000000FF'   MASK FOR ONE CHARACTER                 00005100
         AHI   R7,-8          SHIFT COUNT                               00005200
*                                                                       00005300
*  GET HALFWORD ADDRESS                                                 00005400
*                                                                       00005500
ODDCH    SRL   R5,1                                                     00005600
         AR    R2,R5          GET ADDRESS - 1 OF HALFWORD CONTAINING    00005700
*                             FIRST CHARACTER                           00005800
*                                                                       00005900
*  LOAD PARTITION OF AT LEAST 6 CHARACTERS                              00006000
*                                                                       00006100
         IHL   R4,1(R2)                                                 00006200
         LH    R5,2(R2)                                                 00006300
         IHL   R5,3(R2)                                                 00006400
         NR    R4,R6          ZERO OUT UNWANTED BITS                    00006500
         SRDL  R4,0(R7)       RJUST INTO R5                             00006600
*                                                                       00006700
STORE    ST    R5,ARG5                                                  00006800
EXIT     AEXIT                AND EXIT                                  00006900
CPSLD    AENTRY                                                         00007000
*                                                                       00007100
* OBTAIN THE BIT PATTERN OF AN I TO J SUBBIT PARTITION OF A CHARACTER   00007200
*   STRING, C1.                                                         00007300
*                                                                       00007400
         INPUT R2,            CHARACTER(C1)                            X00007500
               R5,            INTEGER(I) SP                            X00007600
               R6             INTEGER(J) SP                             00007700
         OUTPUT R5            BIT(32)                                   00007800
         WORK  R1,R3,R4,R7                                              00007900
*                                                                       00008000
*                                                                       00008100
*                                                                       00008200
*                                                                       00008300
*  SET UP FOR CALL TO SPTEST                                            00008400
*                                                                       00008500
         LR    R3,R5          PLACE I IN R3                             00008600
         LR    R7,R6          PLACE J IN R7                             00008700
         LH    R6,0(R2)       GET DESCRIPTOR OF C1                      00008800
         NHI   R6,X'00FF'     WIDTH OF CHAR PARTITION IN R6             00008900
*                                                                       00009000
CPSLDX   BAL   R1,SPTEST      CHECK SUBBIT PARTITION                    00009100
CSLDLR   LR    R6,R6          TEST FOR 0 PARTITION                      00009200
         BZ    RET0           RETURN 0 STRING IF CHAR PART=0            00009300
*                                                                       00009400
*  SHIFT OFF UNWANTED BITS                                              00009500
*                                                                       00009600
         SLDL  R4,0(R3)       SHIFT OFF EXCESS HIGH-ORDER BITS          00009700
         LHI   R6,64                                                    00009800
         SR    R6,R7          (64-WIDTH)=NO. OF EXCESS LOW-ORDER BITS   00009900
*                                                                       00010000
         SRDL  R4,0(R6)                                                 00010100
         B     STORE                                                    00010200
CPSLDP   AENTRY                                                         00010300
*                                                                       00010400
* OBTAIN THE BIT PATTERN OF AN I TO J SUBBIT PARTITION OF A K TO L      00010500
*   PARTITION OF A CHARACTER STRING, C1.                                00010600
*                                                                       00010700
         INPUT R2,            CHARACTER(C1)                            X00010800
               R5,            INTEGER(K) SP                            X00010900
               R6,            INTEGER(L) SP                            X00011000
               R7             INTEGER(I || J) SP                        00011100
         OUTPUT R5            BIT(32)                                   00011200
         WORK  R1,R3,R4                                                 00011300
*                                                                       00011400
*                                                                       00011500
*                                                                       00011600
         LR    R3,R7          PLACE I || J IN R3                        00011700
         XR    R7,R7          CLEAR OUT R7                              00011800
         XUL   R7,R3          PUTS J IN R7, I IN R3                     00011900
         BAL   R4,CPTEST                                                00012000
         LA    R1,CSLDLR                                                00012100
         B     SPTEST0        TEST SUBBIT PARTITION                     00012200
CSST     AENTRY                                                         00012300
*                                                                       00012400
* STORE A BIT STRING, B1, INTO A CHARACTER STRING, C1.                  00012500
*                                                                       00012600
         INPUT R2             CHARACTER(C1)                             00012700
         OUTPUT R4            BIT(B1)                                   00012800
         WORK  R1,R3,R5,R6,R7,F0                                        00012900
*                                                                       00013000
*                                                                       00013100
*                                                                       00013200
         LFLR  F0,R4          SAVE BIT STRING                           00013300
         XR    R5,R5          FIRST CHAR-1=0                            00013400
         LH    R6,0(R2)       GET C1 DESCRIPTOR                         00013500
         NHI   R6,X'00FF'     CHARACTER WIDTH = LENGTH(STRING)          00013600
         B     CSSTPX                                                   00013700
CSSTP    AENTRY                                                         00013800
*                                                                       00013900
* STORE A BIT STRING, B1, INTO A K TO L PARTITION OF A CHARACTER        00014000
*   STRING, C1.                                                         00014100
*                                                                       00014200
         INPUT R2,            CHARACTER(C1)                            X00014300
               R5,            INTEGER(K) SP                            X00014400
               R6             INTEGER(L) SP                             00014500
         OUTPUT R4            BIT(B1)                                   00014600
         WORK  R1,R3,R7,F0                                              00014700
*                                                                       00014800
*                                                                       00014900
*                                                                       00015000
         LFLR  F0,R4          SAVE BIT STRING                           00015100
         BAL   R4,CPTEST      CHECK CHAR PARTITION                      00015200
         LR    R6,R6          IF WIDTH=0,                               00015300
CSSTPX   BZ    EXIT           EXIT IMMEDIATELY                          00015400
         LR    R7,R6          CHAR WIDTH IN R7                          00015500
         CHI   R7,4                                                     00015600
         BNH   SETBIT                                                   00015700
         LHI   R7,4           SET WIDTH TO 4 IF GREATER                 00015800
SETBIT   LHI   R3,1           RELATIVE FIRST BIT=1                      00015900
         SLL   R7,3           8*WIDTH = LAST BIT                        00016000
         LA    R1,CPSTLR                                                00016100
         B     SPTEST0                                                  00016200
CPSST    AENTRY                                                         00016300
*                                                                       00016400
* STORE A BIT STRING, B1, INTO AN I TO J SUBBIT PARTITION OF A          00016500
*   CHARACTER STRING, C1.                                               00016600
*                                                                       00016700
         INPUT R2,            CHARACTER(C1)                            X00016800
               R5,            INTEGER(I) SP                            X00016900
               R6             INTEGER(J) SP                             00017000
         OUTPUT R4            BIT(B1)                                   00017100
         WORK  R1,R3,R7,F0                                              00017200
*                                                                       00017300
*                                                                       00017400
*                                                                       00017500
         LFLR  F0,R4          SAVE BIT STRING                           00017600
         LR    R3,R5          FIRST BIT IN R3                           00017700
         LR    R7,R6          LAST BIT IN R7                            00017800
         LH    R6,0(R2)                                                 00017900
         NHI   R6,X'00FF'     CHARACTER WIDTH = LENGTH(STRING)          00018000
CPSSTX   BAL   R1,SPTEST      CHECK SUBBIT PARTITION AND SETUP          00018100
CPSTLR   LR    R6,R6          TEST CHAR PARTITION WIDTH                 00018200
         BZ    EXIT           AND EXIT IMMEDIATELY IF 0                 00018300
         LR    R1,R7          SAVE BIT WIDTH                            00018400
*                                                                       00018500
*  GET MASK OF PROPER WIDTH AND PLACEMENT                               00018600
*                                                                       00018700
         L     R7,=F'1'                                                 00018800
         SLL   R7,0(R1)                                                 00018900
         S     R7,=F'1'       MASK OF PROPER WIDTH IN R7                00019000
         AR    R1,R3          RELATIVE LAST BIT                         00019100
         LHI   R3,64                                                    00019200
         SR    R3,R1          LEFT SHIFT COUNT=64-LAST BIT              00019300
         XR    R6,R6          CLEAR R6                                  00019400
         SLDL  R6,0(R3)                                                 00019500
         ST    R6,MASK1       STORE MASK IN TEMPORARY                   00019600
         ST    R7,MASK2       FOR BIT STRING MASK.                      00019700
         X     R6,=X'FFFFFFFF'                                          00019800
         X     R7,=X'FFFFFFFF'  MASK READY IN R6-R7                     00019900
*                                                                       00020000
*  MASK OLD BITS                                                        00020100
*                                                                       00020200
         NR    R4,R6                                                    00020300
         NR    R5,R7                                                    00020400
*                                                                       00020500
*  INSERT INPUT BIT STRING                                              00020600
*                                                                       00020700
         LFXR  R7,F0          RECOVER STRING                            00020800
         XR    R6,R6                                                    00020900
         SLDL  R6,0(R3)       SHIFT INTO POSITION                       00021000
         N     R6,MASK1       MASK OUT UNWANTED BITS                    00021100
         N     R7,MASK2       IN INPUT STRING.                          00021200
         OR    R4,R6                                                    00021300
         OR    R5,R7          STRING IN                                 00021400
*                                                                       00021500
*  STORE BACK IN CHARACTER STRING                                       00021600
*                                                                       00021700
         STH   R4,1(R2)                                                 00021800
         SLL   R4,16                                                    00021900
         STH   R4,2(R2)                                                 00022000
         STH   R5,3(R2)                                                 00022100
         SLL   R5,16                                                    00022200
         STH   R5,4(R2)                                                 00022300
*                                                                       00022400
         B     EXIT                                                     00022500
CPSSTP   AENTRY                                                         00022600
*                                                                       00022700
* STORE A BIT STRING, B1, INTO AN I TO J SUBBIT PARTITION OF A K TO L   00022800
*   PARTITION OF A CHARACTER STRING, C1.                                00022900
*                                                                       00023000
         INPUT R2,            CHARACTER(C1)                            X00023100
               R5,            INTEGER(K) SP                            X00023200
               R6,            INTEGER(L) SP                            X00023300
               R7             INTEGER(I || J)                           00023400
         OUTPUT R4            BIT(B1)                                   00023500
         WORK  R1,R3,F0                                                 00023600
*                                                                       00023700
*                                                                       00023800
*                                                                       00023900
         LFLR  F0,R4          SAVE BIT STRING IN F0                     00024000
         LR    R3,R7          GET I || J IN R3                          00024100
         XR    R7,R7          CLEAR OUT R7                              00024200
         XUL   R7,R3          PLACE J IN REGISTER 7                     00024300
         BAL   R4,CPTEST      CHECK CHAR PARTITION                      00024400
         LR    R6,R6          IF WIDTH=0,                               00024500
         BZ    EXIT           EXIT IMMEDIATELY                          00024600
         LA    R1,CPSTLR                                                00024700
         B     SPTEST0                                                  00024800
**************************************************************          00024900
*  SECTION CPTEST: CHECKS CHARACTER PARTITION FOR VALIDITY.  *          00025000
*     INPUTS: R2->CHARACTER STRING,                          *          00025100
*       R5=FIRST CHARACTER, R6=LAST CHARACTER.               *          00025200
*     OUTPUTS: R5=FIRST CHARACTER-1,R6=WIDTH OF CHARACTER    *          00025300
*       PARTITION. R2,R3, AND R7 UNCHANGED.                  *          00025400
**************************************************************          00025500
CPTEST   AHI   R5,-1                                                    00025600
         BNM   FIRSTOK                                                  00025700
         AERROR 17            ERROR: FIRST CHAR<1                       00025800
         XR    R5,R5          FIXUP: FIRST CHAR=1                       00025900
*                                                                       00026000
FIRSTOK  LH    R1,0(R2)                                                 00026100
         NHI   R1,X'00FF'     LENGTH OF CHAR STRING                     00026200
         CR    R6,R1                                                    00026300
         BNH   LASTOK                                                   00026400
         AERROR 17            ERROR:LAST CHAR>CURRLEN                   00026500
         LR    R6,R1          FIXUP: LAST CHAR=CURRLEN                  00026600
*                                                                       00026700
LASTOK   SR    R6,R5          WIDTH OF CHAR PARTITION                   00026800
         BP    WPOS                                                     00026900
         AERROR 17            ERROR:WIDTH<=0                            00027000
         XR    R6,R6          FIXUP: ZERO WIDTH                         00027100
*                                                                       00027200
WPOS     BR    R4             RETURN TO CALLING SECTION                 00027300
******************************************************************      00027400
*  SECTION SPTEST: CHECKS SUBBIT PARTITION FOR VALIDITY.         *      00027500
*     INPUTS: R6=WIDTH OF CHARACTER PARTITION,                   *      00027600
*       R3=FIRST BIT,R7=LAST BIT                                 *      00027700
*     OUTPUTS: 1(R2)->4 HALFWORDS CONTAINING REQUIRED PARTITION, *      00027800
*           R3=RELATIVE FIRST BIT-1,R7=BIT WIDTH,R4-R5 CONTAIN   *      00027900
*            THE 4 HALFWORDS AT 1(R2).                           *      00028000
******************************************************************      00028100
SPTEST0  TRB   R5,X'0001'                                               00028200
         BZ    UPR2                                                     00028300
         LR    R3,R3                                                    00028400
         BP    INC                                                      00028500
         AERROR 30            ERROR: FIRST BIT<1                        00028600
         LHI   R3,1           FIXUP: FIRST BIT=1                        00028700
*                                                                       00028800
INC      AHI   R3,8           SECOND CHAR OF HALFWORD                   00028900
         AHI   R7,8           INCREASE WIDTH TO COMPENSATE              00029000
         AHI   R6,1                                                     00029100
*                                                                       00029200
UPR2     SRL   R5,1           HALFWORD COUNT                            00029300
         AR    R2,R5          POINT TO PARTITION                        00029400
*                                                                       00029500
SPTEST   SLL   R6,3           C1 LENGTH * 3                             00029600
         LR    R3,R3          SET CONDITION CODE                        00029700
         BP    B1BIG          ELSE ERROR: I <= 0                        00029800
         AERROR 30            ERROR:FIRST BIT<1                         00029900
         SR    R7,R3          ADJUST J FOR SAME WIDTH                   00030000
         AHI   R7,1           NOTE: R3 <= 0 IMPLIES NEW R7 > OLD R7     00030100
         LHI   R3,1           FIXUP: FIRST BIT=1                        00030200
         B     B1SML                                                    00030300
*                                                                       00030400
B1BIG    CR    R3,R6                                                    00030500
         BNH   B1SML                                                    00030600
         AERROR 30            ERROR: FIRST BIT>PARTITION WIDTH          00030700
         LR    R3,R6          FIXUP: FIRST BIT=PARTITION WIDTH          00030800
         BZ    SPRETN         LEAVE IF PARTITION WIDTH=0                00030900
*                                                                       00031000
B1SML    CR    R7,R6          COMPARE J WITH CURRENT LENGTH * 8         00031100
         BNH   LBSML                                                    00031200
         AERROR 30            ERROR: LAST BIT>PARTITION WIDTH           00031300
         LR    R7,R6          FIXUP: LAST BIT=PARTITION WIDTH           00031400
*                                                                       00031500
LBSML    BCTB  R3,*+1         I = I - 1                                 00031600
         SR    R7,R3          LENGTH OF PARTITION = J - I + 1           00031700
         LR    R4,R3          FIRST BIT-1 IN R4                         00031800
         SRL   R4,4           (FIRST BIT-1)/16=FIRST HALFWORD-1         00031900
         LA    R4,0(R4,3)     CLEAR BOTTOM HALF OF R4                   00032000
         AR    R2,R4          FIRST HALFWORD ADDRESS IN C1              00032100
         SLL   R4,4           GET BACK R4 WIHTOUT 4 SIGNIFICANT BITS    00032200
         SR    R3,R4          RELATIVE FIRST BIT-1                      00032300
*                                                                       00032400
*  GET 4 HALFWORDS WHICH CONTAIN THE REQUIRED                           00032500
*  PARTITION IN REGISTER PAIR R4-R5                                     00032600
*                                                                       00032700
         LH    R4,1(R2)                                                 00032800
         IHL   R4,2(R2)                                                 00032900
         LH    R5,3(R2)                                                 00033000
         IHL   R5,4(R2)                                                 00033100
*                                                                       00033200
SPRETN   BR    R1             RETURN TO CALLING SECTION                 00033300
         ACLOSE                                                         00033400
