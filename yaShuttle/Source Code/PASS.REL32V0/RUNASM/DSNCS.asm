*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DSNCS.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'DSNCS - DOUBLE PRECISION SINE-COSINE FUNCTION'                  00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* ASSUMPTIONS:                                                          00000200
*       1) 31 BIT ACCURACY IS SUFFICIENT                                00000300
*       2) HEAVY USE OF COMBINED SINE-COSINE EVALUATIONS                00000400
*       3) INPUT IS NORMALIZED IN FLT. PT. REGS 0 & 1                   00000500
*  ALGORITHM                                                            00000600
*          SINE-COSINE OF ARGUMENT ...                                  00000700
*            .TABLE LOOK UP - A                                         00000800
*            .EVALUATION OF FUNCTION IN RANGE---PI/32 GE DEL LE PI/32   00000900
*            .COMPUTATION OF ARGUMENT A+DEL, WHERE A IS ARGUMENT OF     00001000
*                   CORRESPONDING POINT IN TABLE                        00001100
*                                                                       00001201
* REVISION HISTORY                                                      00001301
* ----------------                                                      00001401
* DATE     NAME  REL   DR NUMBER AND TITLE                              00001501
*                                                                       00001601
* 03/15/91  RAH  23V2  CR11055 RUNTIME LIBRARY CODE COMMENT CHANGES     00001701
*
* 02/11/93  PMA  24V1  DR103782 INCORRECT CONSTANTS USED IN DSNCS
*                                                                       00001801
         SPACE 2                                                        00001900
*                                                                       00002000
         MACRO                                                          00002100
         WORKAREA                                                       00002200
F6F7     DS    D              TEMP FOR FLP.REGS.  F6,F7                 00002300
SINTEMP  DS    D              TEMPORARY STORAGE FOR SINE                00002400
BUFF     DS    F                                                        00002500
         MEND                                                           00002600
*                                                                       00002700
DSNCS    AMAIN                COMBINED EVALUATION                       00002800
*                                                                       00002900
* COMPUTES BOTH THE SIN AND COS IN DOUBLE PRECISION                     00003000
*   OF THE INPUT ARGUMENT                                               00003100
*                                                                       00003200
         INPUT F0             SCALAR DP                                 00003300
         OUTPUT F0            SCALAR DP                                 00003400
         OUTPUT F2            SCALAR DP                                 00003500
         WORK  R2,R5,R6,R7,F1,F2,F3,F4,F5,F6                            00003600
         L     R5,ONE         SET R5 TO DC F'1' - LOWER REG5 =1 FOR     00003700
         B     DSIN1                                     BOTH ENTRY     00003800
DSIN     AENTRY               SINE ENTRY                                00003900
*                                                                       00004000
* COMPUTES THE SIN IN DOUBLE PRECISION OF THE INPUT ARGUMENT            00004100
*                                                                       00004200
         INPUT F0             SCALAR DP                                 00004300
         OUTPUT F0            SCALAR                                    00004400
         WORK  R2,R5,R6,R7,F1,F2,F3,F4,F5,F6                            00004500
         XR    R5,R5          ZERO REG 5                                00004600
DSIN1    LER   F0,F0          LOAD TEST REG                             00004700
         BNM   MERGE                                                    00004800
         AHI   R5,4           NEG SINE ARGUMENT                         00004900
         B     MERGE                                                    00005000
         SPACE 2                                                        00005100
DCOS     AENTRY               COSINE ENTRY                              00005200
*                                                                       00005300
* COMPUTES THE COS IN DOUBLE PRECISION OF THE INPUT ARGUMENT            00005400
*                                                                       00005500
         INPUT F0             SCALAR DP                                 00005600
         OUTPUT F0            SCALAR                                    00005700
         WORK  R2,R5,R6,R7,F1,F2,F3,F4,F5,F6                            00005800
         LA    R5,2           X'00020000'                               00005900
* POSSIBLE VALUES IN REG 5 -  SO FAR,WILL MERGE WITH REG 6              00006000
*               00000001  - DSNCS ENTRY,POS ARG                         00006100
*               00040001  - DSNCS ENTRY,NEG ARG                         00006200
*               00000000  - DSIN  ENTRY,POS ARG                         00006300
*               00040000  - DSIN  ENTRY,NEG ARG                         00006400
*               00020000  - DCOS  ENTRY                                 00006500
MERGE    STED  F6,F6F7        NEED TO SAVE/RESTORE THESE REGS           00006600
         LA    R2,DSCNCONT    ADDRESS FOR DATA CSECT                    00006700
         USING DSCNCONT,R2                                              00006800
         AE    F0,ZERO                                                  00006900
         BNM   POS                                                      00007000
         LECR  F0,F0          COMPLEMENT INPUT                          00007100
POS      LFXR  R7,F0          LOAD FIXED FOR SIZE TEST                  00007200
         SH    R7,MAX         USE SUB HALF FOR SIZE COMPARE             00007300
         BP    ERROR                                                    00007400
         AH    R7,UNFLO       ADD SUB HALF FOR TEST                     00007500
         BP    NOUNDR                                                   00007600
         SEDR  F0,F0          UNDER-FLOW PREVENTION                     00007700
         SPACE 2                                                        00007800
NOUNDR   MED   F0,RPIO32      NEED ARG* 32/PI                           00007900
         LER   F2,F0                                                    00008000
         AE    F2,SCALER      SCALE                                     00008100
         LFXR  R6,F2          SET UP TO ATTAIN BITS TO CONTROL          00008200
*                               COMPUTATION IN COMPLP LOGIG             00008300
         SLL   R6,16          NEED: NUMBER OF 2 PI IN ARC               00008400
         TRB   R6,X'0008'           OCTANT OF ARG                       00008500
         BZ    SKPSET1                                                  00008600
*                             R6 _BITS  0- 9 = # 2PI                    00008700
         AE    F2,DONE                 10-12 = OCTANT                   00008800
*                                      13-15 = PTR TO TBL ENTRY         00008900
         XHI   R6,X'0007'     R6 SET BASED  ON SERIES OF                00009000
SKPSET1  SE    F2,SCALER        TESTS ON INPUT VALUE                    00009100
         LE    F3,ZERO                                                  00009200
         SEDR  F0,F2          INPUT ARG WILL BE COMPLEMENTED            00009300
         BNM   COMPLIN          WHEN NECESSARY FOR                      00009400
         LECR  F0,F0            OCTANT OR FOR DIRECTION                 00009500
COMPLIN  LR    R7,R6          USE R7 FOR TABLE INDICES                  00009600
         SRL   R7,1                                                     00009700
         NHI   R7,X'0003'     ADJUST POINTER TO TABLE                   00009800
         TRB   R6,X'0001'     IF AGR POS SKIP TEST                      00009900
         BP    COMPLIN1                                                 00010000
         LR    R7,R7          IF TABLE ENTRY ZERO                       00010100
         BNZ   COMPLIN2                                                 00010200
         L     R7,BS          FLAG AS NEG FOT LATER TEST                00010300
         B     COMPLIN1                                                 00010400
COMPLIN2 SED   F0,DONE        REDUCE BY CONST., NEG ARG. NOT FIRST      00010500
COMPLIN1 NHI   R6,X'0038'     REMOVE EXTRANEOUS BITS                    00010600
         SRL   R6,3           BE ADDED TO REG 5 FOR CONTROL IN          00010700
         AR    R5,R6          COMPLP LOGIC                              00010800
         ST    R5,BUFF        SAVE FOR DUAL ENTRY LOGIC IN COMPLP       00010900
*  EVALUATION OF SINE/COSINE POLYNOMIAL                                 00011000
*   DEL = CONT(F0) = INPUT* RECIPROCAL PI/32                            00011100
*   IF DEL LE  UNFLO THEN,                                              00011200
*      DSIN(DEL) = F'0.0'                                               00011300
*      DCOS(DEL) = F'1.0'                                               00011400
*   ELSE                                                                00011500
*      DSIN(DEL) = DEL * (PI/32 + (B*DEL**2 + A*DEL**4))                00011600
*      DCOS(DEL) = 1.0 + 2*(B*DEL**2 + A*DEL**4)                        00011700
COMPOLY  LER   F4,F0                                                    00011800
         MER   F4,F4          DEL**2 = D2                               00011900
         LER   F6,F4          SAVE D2 FOR COS COMP                      00012000
         LER   F2,F4                                                    00012100
         ME    F2,AS          A(D2)                                     00012200
         AE    F2,BS          A(D2)+B                                   00012300
         MER   F2,F4          (A(D2)+B)*D2                              00012400
         AED   F2,PIO32       (PI/32)+(A(D2)+B)D2                       00012500
         MEDR  F2,F0          DEL*((PI/32)+(ACD2)+B)D2) = DSIN(DEL)     00012600
         ME    F4,AC          A(D2)                                     00012700
         AE    F4,BC          A(D2)+B                                   00012800
         MER   F4,F6          (A(D2)+B)*D2                              00012900
         AEDR  F4,F4          2((A(D2)+B)*D2)                           00013000
         AED   F4,DONE        1+2((A(D2)+B)*D2)  = DCOS(DEL)            00013100
         SPACE 2                                                        00013200
* NEED  SIN(TBL_ENTRY+DEL) = SIN(TBL_ENTRY)COS(DEL)+SIN(DEL)COS(TBL-EN) 00013300
*       COS(TBL_ENTRY+DEL) = COS(TBL_ENTRY)COS(DEL)-SIN(DEL)SIN(TBL-EN) 00013400
         SPACE 1                                                        00013500
COMPLP   AH    R5,HONE        USE TO DETERMINE TYPE OF ENTRY            00013600
         NHI   R5,X'0002'     ENTRY - SINE,COS OR BOTH                  00013700
         BNZ   COMPCOS        BRANCH FOR COS, ELSE DO SIN               00013800
COMPSIN  LR    R7,R7          IF FLAG IS NEG NO COMP                    00013900
         BNM   COMPSIN1                                                 00014000
         LER   F0,F2          USE POLY COMPUTED ABOVE                   00014100
         LER   F1,F3                                                    00014200
         B     COMPCMN1                                                 00014300
COMPSIN1 LED   F0,TSIN(R7)    COMPUTATION                               00014400
         LED   F6,TCOS(R7)                                              00014500
         B     COMPCMN        COMMON COMPUTATION                        00014600
COMPCOS  LR    R7,R7          IF FLAG SET NO COMPUTATION USE POLY       00014700
         BNM   COMPCOS1                                                 00014800
         LER   F0,F4          USE POLY COMPUTED ABOVE                   00014900
         LER   F1,F5                                                    00015000
         B     COMPCMN1                                                 00015100
COMPCOS1 LED   F0,TCOS(R7)    COMPUTATION                               00015200
         LED   F6,TSIN(R7)    2ND TOKEN NEGATIVE                        00015300
         LECR  F6,F6          -SIN(TBL_ENTRY)                           00015400
COMPCMN  MEDR  F0,F4          F4 = COS(DEL)                             00015500
         MEDR  F6,F2          F2 = SIN(DEL)                             00015600
         AEDR  F0,F6          EITHER SINE OR COSINE IN FO               00015700
COMPCMN1 TB    BUFF,X'0004'   MAY NEED TO COMPLEMENT                    00015800
         BZ    CKLUP                                                    00015900
         LER   F0,F0          WORKAROUND FOR BUG                        00016000
         BZ    CKLUP          IN LECR INSTRUCTION.                      00016100
         LECR  F0,F0          NEED NEG IF BIT OFF                       00016200
CKLUP    CIST  BUFF+1,X'0001' DETERMINES ENTRY TYPE                     00016300
         BC    2,STORECOS     IMMEDT LS -  COSINE PASS                  00016400
         BC    1,EXIT         IMMEDT GR  - JUST SINE OR COSINE          00016500
STORESIN STED  F0,SINTEMP                                               00016600
         LR    R5,R6                                                    00016700
         A     R5,H2H3        X'00020003'                               00016800
         ST    R5,BUFF                                                  00016900
         B     COMPLP                                                   00017000
*                                                                       00017100
ERROR    AERROR 8             ARGUMENT > 8E+5                           00017200
         LED   F0,RT2                                                   00017300
         LED   F2,RT2                                                   00017400
         B     EXIT           BIT OFF                                   00017500
STORECOS LER   F2,F0                                                    00017600
         LER   F3,F1                                                    00017700
         LED   F0,SINTEMP                                               00017800
EXIT     LED   F6,F6F7        NEED TO SAVE/RESTORE                      00017900
         AEXIT                                                          00018000
*                                                                       00018100
         SPACE 2                                                        00018200
         ADATA                                                          00018300
DSCNCONT DS    0D                                                       00018400
* CONSTANTS USED IN FUNCTION                                            00018500
DONE     DC    X'4110000000000000'                                      00018600
ZERO     EQU   *-2                                                      00018700
PIO32    DC    X'401921FB544420B9'      PI / 32 AND TEST VALUE          00018800
UNFLO    EQU   *-1                                                      00018900
RPIO32   DC    X'41A2F9836E4E45C9'      32 / PI AND TEST VALUE          00019000
MAX      EQU   *-1                                                      00019100
RT2      DC    X'40B504F333F9DE70'                                      00019200
SCALER   DC    X'46800000'                                              00019300
ONE      DC    X'00000001'                                              00019400
HONE     EQU   *-1                                                      00019500
H2H3     DC    X'00020003'                                              00019600
*                                                                       00019700
* CONSTANTS FOR POLYNOMIAL                                              00019800
AS       DC    X'3B14634A'       COEFFICIENT A FOR SINE                 00019900
BS       DC    X'BDA55DE5'       COEFFICIENT B FOR SINE                 00020000
AC       DC    X'3C2075A1'       COEFFICIENT A FOR COSINE               00020100
BC       DC    X'BE9DE9E7'       COEFFICIENT B FOR COSINE               00020200
*  TABLE_ENTRY FOR SINE/COSINE                                          00020300
*   INDEXED TO BASED UPON INPUT ARG                                     00020400
TSIN     DC    D'.09801714032875'                                       00020500
         DC    D'.290284677254'                                         00020600
         DC    D'.4713967368259'                                        00020700
         DC    D'.6343932841633'                                        00020800
TCOS     DC    D'.9951847266737'                                        00020900
         DC    D'.9569403357347'                                        00021000
         DC    D'.8819212643506'                                        00021100
         DC    D'.773010453364'                                         00021200
*                                                                       00021300
         ACLOSE                                                         00022000
