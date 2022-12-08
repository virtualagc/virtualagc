*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    IPWRI.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

  TITLE 'IPWRI -- EXPONENTIATION OF AN INTEGER TO AN INTEGRAL POWER'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* IPWRI: INTEGER TO AN INTEGRAL POWER                                   00000200
*                                                                       00000300
*        1. INPUTS: BASE IN R5 FULLWORD, EXPONENT IN R6 FULLWORD.       00000400
*        2. OUTPUT IN R5 FULLWORD.                                      00000500
*        3. SUCCESSIVELY TAKE FIRST, SECOND, FOURTH, ETC.,              00000600
*           POWERS OF BASE, SIMULTANEOUSLY SHIFTING EXPONENT RIGHT.     00000700
*        4. MULTIPLY POWER OF BASE INTO ANSWER WHEN '1' IS SHIFTED OUT. 00000800
*        5. ERROR GIVEN WHEN BASE=0 AND EXPONENT<=0.                    00000900
*                                                                       00001000
IPWRI    AMAIN                                                          00001100
* COMPUTES DOUBLE PRECISION INTEGER TO                                  00001200
* POSITIVE DOUBLE PRECISION INTEGER POWER                               00001300
         INPUT R5,            INTEGER DP                               X00001400
               R6             INTEGER DP                                00001500
         OUTPUT R5            INTEGER DP                                00001600
         WORK  R1,R2,R4,R7                                              00001700
         XR    R1,R1          CLEAR FLAG TO INDICATE FULLWORD           00001800
         B     MERGE          AND CONTINUE                              00001900
*                                                                       00002000
IPWRH    AENTRY                                                         00002100
* COMPUTES DOUBLE PRECISION INTEGER TO                                  00002200
* POSITIVE SINGLE PRECISION INTEGER POWER                               00002300
         INPUT R5,            INTEGER DP                               X00002400
               R6             INTEGER SP                                00002500
         OUTPUT R5            INTEGER DP                                00002600
         WORK  R1,R2,R4,R7                                              00002700
         XR    R1,R1          CLEAR FLAG FOR FULLWORD RESULT            00002800
         SRA   R6,16          GET FULLWORD EXPONENT                     00002900
         B     MERGE          AND CONTINUE                              00003000
*                                                                       00003100
*                                                                       00003200
HPWRH    AENTRY                                                         00003300
* COMPUTES SINGLE PRECISION INTEGER TO                                  00003400
* POSITIVE SINGLE PRECISION INTEGER POWER                               00003500
         INPUT R5,            INTEGER SP                               X00003600
               R6             INTEGER SP                                00003700
         OUTPUT R5            INTEGER SP                                00003800
         WORK  R1,R2,R4,R7                                              00003900
         LA    R1,1           SET FLAG FOR HALFWORD RESULT              00004000
         SRA   R5,16          GET FULLWORD BASE                         00004100
         SRA   R6,16          GET FULLWORD EXPONENT                     00004200
*                                                                       00004300
MERGE    LR    R2,R5          BASE IN R2                                00004400
         BNZ   NOTZERO                                                  00004500
         LR    R6,R6          GIVE ERROR IF BASE=0                      00004600
         BNP   ERROR          AND EXPONENT<=0.                          00004700
*                                                                       00004800
*  RETURN 0 IF BASE=0 AND EXPONENT>0,                                   00004900
*  OR IF BASE^=0 AND EXPONENT<0                                         00005000
*                                                                       00005100
ZERO     SR    R5,R5                                                    00005200
         ST    R5,ARG5                                                  00005300
         B     EXIT                                                     00005400
*                                                                       00005500
* MAIN COMPUTATION SECTION                                              00005600
*                                                                       00005700
NOTZERO  LR    R6,R6                                                    00005800
         BM    ZERO           RETURN ZERO IF EXPONENT<0                 00005900
         LFXI  R4,1                                                     00006000
         SRL   R4,16                                                    00006100
         BZ    OUT            RETURN 1 IF EXPONENT=0                    00006200
*                                                                       00006300
ILOOP    SRDL  R6,1                                                     00006400
         LR    R7,R7          CHECK FOR 1 SHIFTED OUT                   00006500
         BNM   NOMULT         AND DON'T MULTIPLY IF NOT                 00006600
         MR    R4,R2                                                    00006700
         SLDL  R4,31                                                    00006800
*                                                                       00006900
NOMULT   LR    R6,R6          EXIT WHEN REMAINING                       00007000
         BZ    OUT            EXPONENT GOES TO 0.                       00007100
         MR    R2,R2          OTHERWISE, DO INTEGER                     00007200
         SLDL  R2,31          MULTIPLY AND CONTINUE                     00007300
         B     ILOOP          THROUGH LOOP.                             00007400
*                                                                       00007500
*  GET PROPER PRECISION IN ANSWER                                       00007600
*                                                                       00007700
OUT      LR    R1,R1          STORE IMMEDIATELY IF                      00007800
         BZ    STORE          HALFWORD FLAG=0,                          00007900
         SLL   R4,16          OTHERWISE SHIFT TO HALFWORD POSITION.     00008000
STORE    ST    R4,ARG5                                                  00008100
*                                                                       00008200
EXIT     AEXIT                                                          00008300
*                                                                       00008400
ERROR    AERROR 4             ZERO RAISED TO POWER <= 0                 00008500
         B     ZERO           FIXUP RETURNS 0                           00008600
         ACLOSE                                                         00008700
