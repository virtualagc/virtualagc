*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV5D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV5D3--VECTOR DIVIDED BY SCALAR, LENGTH 3, DP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV5D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* DIVIDES V1 BY A DOUBLE PRECISION SCALAR WHERE V1 IS A DOUBLE          00000400
*   PRECISION VECTOR OF LENGTH 3.                                       00000500
*                                                                       00000600
* REVISION HISTORY:                                                     00000701
*                                                                       00000801
*    DATE      NAME  DR/SSCR#   DESCRIPTION                             00000901
*    --------  ----  --------   --------------------------------------  00001001
*    12/16/89  JAC   DR103762   REPLACED QCED/QCEDR MACRO WITH          00001101
*                               CED/CEDR INSTRUCTION                    00001201
*                                                                       00001301
         INPUT R2,            VECTOR(3) DP                             X00001400
               F0,            SCALAR DP                                X00001500
               F1             SCALAR DP                                 00001600
         OUTPUT R1            VECTOR(3) DP                              00001700
         WORK  F2,F4,F3,F5,F6,F7                                        00001800
*                                                                       00001900
* ALGORITHM:                                                            00002000
*   IF F0 = 0 THEN                                                      00002100
*     SEND A DIVIDE BY ZERO ERROR                                       00002200
*   ELSE                                                                00002300
*     DO;                                                               00002400
*       F4 = 1 / F0;                                                    00002500
*       V2$(1) = V1$(1) F4;                                             00002600
*       V2$(2) = V1$(2) F4;                                             00002700
*       V2$(3) = V1$(3) F4;                                             00002800
*     END;                                                              00002900
*                                                                       00003000
         SEDR  F4,F4          CLEAR F4                                  00003100
         CEDR  F4,F0          CHECK AGAINST 0           /* DR103762 */  00003201
         LFLI  F4,1           SET F4 TO 1                               00003300
         BE    AOUT           IF F0 = 0 THEN SEND ERROR                 00003400
        IDEDR  F4,F0,F2,F6    ELSE SET F4 TO 1 / F0                     00003500
DIV      LED   F0,4(R2)       LOAD V1$(1)                               00003600
         MEDR  F0,F4          V1$(1) F4                                 00003700
         STED  F0,4(R1)       STORE V1$(1)                              00003800
         LED   F0,8(R2)       LOAD V1$(2)                               00003900
         LED   F2,12(R2)      LOAD V1$(3)                               00004000
         MEDR  F0,F4          V1$(2) F4                                 00004100
         MEDR  F2,F4          V1$(3) F4                                 00004200
         STED  F0,8(R1)       STORE V1$(2)                              00004300
         STED  F2,12(R1)      STORE V1$(3)                              00004400
         AEXIT                                                          00004500
AOUT     AERROR 25            ATTEMPT TO DIVIDE BY 0                    00004600
         B     DIV                                                      00004700
         ACLOSE                                                         00004800
