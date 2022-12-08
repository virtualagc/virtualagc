*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ROUND.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

    TITLE 'ROUND -- ROUND, DTOI, TRUNCATE, CEIL, AND FLOOR'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000200
*        CSECT NAME IS #0ROUND TO INSURE LOCATION IN SECTOR ZERO        00000300
*                                                                       00000400
*   REVISION HISTORY:                                                   00000502
*                                                                       00000602
*   DATE       NAME  DR/SSCR#    DESCRIPTION                            00000702
*   --------   ----  --------    ------------------------------------   00000802
*   12/16/89   JAC   DR103762    REPLACED QCED/QCEDR MACRO WITH         00000902
*                                CED/CEDR INSTRUCTION                   00001002
*                                                                       00001102
ROUND    AMAIN INTSIC=YES,SECTOR=0                                      00001200
*                                                                       00001300
*                                                                       00001400
*  CONVERTS SINGLE  PRECISION SCALAR                                    00001500
*                                                                       00001600
*  TO FULLWORD INTEGER                                                  00001700
*                                                                       00001800
         INPUT F0             SCALAR  SP                                00001900
         OUTPUT R5            INTEGER  DP                               00002000
         WORK  F1,R4                                                    00002100
*                                                                       00002200
*                                                                       00002300
*                                                                       00002400
*                                                                       00002500
ETOI     AENTRY                                                         00002600
*                                                                       00002700
*  CONVERTS SCALAR SP TO INTEGER DP                                     00002800
*                                                                       00002900
*                                                                       00003000
*                                                                       00003100
*                                                                       00003200
         INPUT F0             SCALAR  SP                                00003300
         OUTPUT R5            INTEGER  DP                               00003400
         WORK  F1,R4                                                    00003500
*                                                                       00003600
*                                                                       00003700
*                                                                       00003800
         LE    F1,SCALER1+2                                             00003900
         B     DFLFX                                                    00004000
*                                                                       00004100
*  TRUNCATE: SINGLE PRECISION                                           00004200
*                                                                       00004300
TRUNC    AENTRY                                                         00004400
*                                                                       00004500
* RETURN THE LARGEST INTEGER THAT <= TO                                 00004600
*      THE ABSOLUTE VALUE OF THE ARGUMENT                               00004700
*                                                                       00004800
         INPUT F0             SCALAR  SP                                00004900
         OUTPUT R5            INTEGER  DP                               00005000
         WORK  F1,R4                                                    00005100
*                                                                       00005200
*                                                                       00005300
         LE    F1,SCALER1+2   CLEAR LOW HALF F0                         00005400
         B     TRUNCX         AND USE DOUBLE TRUNCATE.                  00005500
*                                                                       00005600
*  FLOOR: SINGLE PRECISION                                              00005700
*                                                                       00005800
FLOOR    AENTRY                                                         00005900
*   FLOOR(X) = |TRUNC(X) IF X>=0                                        00006000
*              |TRUNC(X-(1-)) IF X<0                                    00006100
*                                                                       00006200
*                                                                       00006300
*                                                                       00006400
         INPUT F0             SCALAR SP                                 00006500
         OUTPUT R5            INTEGER  DP                               00006600
         WORK  F1,R4                                                    00006700
*                                                                       00006800
*                                                                       00006900
         LE    F1,SCALER1+2   CLEAR LOW HALF F0                         00007000
         B     FLOORX         AND USE DOUBLE FLOOR.                     00007100
*                                                                       00007200
* CEIL:  SINGLE PRECISION                                               00007300
*                                                                       00007400
CEIL     AENTRY                                                         00007500
*  CEIL(X) = |TRUNC(X)  IF X<=0                                         00007600
*            |TRUNC(X+(1-)) IF X>0                                      00007700
*                                                                       00007800
*                                                                       00007900
         INPUT F0             SCALAR SP                                 00008000
         OUTPUT R5            INTEGER DP                                00008100
         WORK  F1,R4                                                    00008200
*                                                                       00008300
*                                                                       00008400
         LE    F1,SCALER1+2   CLEAR LOW HALF F0                         00008500
         B     CEILX          AND USE DOUBLE CEIL.                      00008600
*                                                                       00008700
*  TRUNCATE: DOUBLE PRECISION                                           00008800
*                                                                       00008900
DTRUNC   AENTRY                                                         00009000
*                                                                       00009100
* RETURN THE LARGEST INTEGER THAT <= TO                                 00009200
*      THE ABSOLUTE VALUE OF THE ARGUMENT                               00009300
*                                                                       00009400
*                                                                       00009500
         INPUT F0             SCALAR DP                                 00009600
         OUTPUT R5            INTEGER DP                                00009700
         WORK  F1,R4                                                    00009800
*                                                                       00009900
*                                                                       00010000
TRUNCX   LER   F0,F0          TEST SIGN OF X                            00010100
         BNM   POSCHK                                                   00010200
         B     NEGCHK                                                   00010300
*                                                                       00010400
*  FLOOR: DOUBLE PRECISION                                              00010500
*                                                                       00010600
DFLOOR   AENTRY                                                         00010700
*   FLOOR(X) = |TRUNC(X) IF X>=0                                        00010800
*              |TRUNC(X-(1-)) IF X<0                                    00010900
*                                                                       00011000
*                                                                       00011100
*                                                                       00011200
         INPUT F0             SCALAR  DP                                00011300
         OUTPUT R5            INTEGER  DP                               00011400
         WORK  F1,R4                                                    00011500
*                                                                       00011600
*                                                                       00011700
FLOORX   LER   F0,F0                                                    00011800
         BNM   POSCHK                                                   00011900
         SED   F0,ONEMINUS                                              00012000
         B     NEGCHK                                                   00012100
*                                                                       00012200
*  CEIL: DOUBLE PRECISION                                               00012300
*                                                                       00012400
DCEIL    AENTRY                                                         00012500
*  CEIL(X) = |TRUNC(X)  IF X<=0                                         00012600
*            |TRUNC(X+(1-)) IF X>0                                      00012700
*                                                                       00012800
*                                                                       00012900
         INPUT F0             SCALAR   DP                               00013000
         OUTPUT R5            INTEGER  DP                               00013100
         WORK  F1,R4                                                    00013200
*                                                                       00013300
*                                                                       00013400
CEILX    LER   F0,F0                                                    00013500
         BNP   NEGCHK                                                   00013600
         AED   F0,ONEMINUS                                              00013700
         B     POSCHK                                                   00013800
*                                                                       00013900
*  ROUND: DOUBLE PRECISION                                              00014000
*                                                                       00014100
*  THIS IS THE MAIN SECTION                                             00014200
*                                                                       00014300
DROUND   AENTRY                                                         00014400
*                                                                       00014500
*  ROUNDS SCALAR DP TO FULLWORD INTEGER                                 00014600
*                                                                       00014700
*                                                                       00014800
*                                                                       00014900
         INPUT F0             SCALAR  DP                                00015000
         OUTPUT R5            INTEGER  DP                               00015100
         WORK  F1,R4                                                    00015200
*                                                                       00015300
*                                                                       00015400
*                                                                       00015500
DTOI     AENTRY                                                         00015600
*                                                                       00015700
*  CONVERTS SCALAR DP TO INTEGER DP                                     00015800
*                                                                       00015900
*                                                                       00016000
*                                                                       00016100
*                                                                       00016200
         INPUT F0             SCALAR  DP                                00016300
         OUTPUT R5            INTEGER  DP                               00016400
         WORK  F1,R4                                                    00016500
*                                                                       00016600
*                                                                       00016700
DFLFX    LER   F0,F0                                                    00016800
         BM    NEGFX                                                    00016900
         AED   F0,ROUNDER                                               00017000
POSCHK   CED   F0,MAXPOS                                /* DR103762 */  00017103
         BNH   TRUNCP                                                   00017200
         AERROR 15            ERROR: POSITIVE ARGUMENT TOO LARGE        00017300
         L     R5,POSMAX      FIXUP: LARGEST POSITIVE NUMBER            00017400
         B     EXIT                                                     00017500
*                                                                       00017600
NEGFX    SED   F0,ROUNDER                                               00017700
NEGCHK   CED   F0,MAXNEG                                /* DR103762 */  00017803
         BNL   TRUNCM                                                   00017900
         AERROR 15            ERROR: NEGATIVE ARGUMENT TOO LARGE        00018000
         L     R5,NEGMAX      FIXUP: LARGEST NEGATIVE NUMBER            00018100
         B     EXIT                                                     00018200
*                                                                       00018300
* CONVERT TO FIXED-POINT BY TRUNCATING. SLIGHTLY                        00018400
*  DIFFERENT METHODS MUST BE USED FOR POSITIVE AND FOR                  00018500
*   NEGATIVE ARGUMENTS, BUT IN EITHER CASE THE ANSWER                   00018600
*   IS LEFT IN F1.                                                      00018700
*                                                                       00018800
*                            * (DR63479 FIX 8/86 HFG) *                 00018900
TRUNCM   SED   F0,SCALER1    * USE SED INSTEAD OF 'AED F0,SCALER2'      00019000
         LFXR  R5,F1         * |X| IN R5                                00019100
         LCR   R5,R5         * GET NEGATIVE X                           00019200
         AEXIT                                                          00019300
*                                                                       00019400
TRUNCP   AED   F0,SCALER1                                               00019500
         LFXR  R5,F1                                                    00019600
EXIT     AEXIT                                                          00019700
*                                                                       00019800
         DS    0F                                                       00019900
SCALER1  DC    X'4E10000000000000'                                      00020000
ONEMINUS DC    X'40FFFFFFFFFFFFFF'                                      00020100
ROUNDER  DC    X'407FFFFFFFFFFFFF'                                      00020200
MAXNEG   DC    X'C880000000FFFFFF'                                      00020300
MAXPOS   DC    X'487FFFFFFFFFFFFF'                                      00020400
NEGMAX   DC    X'80000000'                                              00020500
POSMAX   DC    X'7FFFFFFF'                                              00021000
         ACLOSE                                                         00030000
