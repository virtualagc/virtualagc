*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR0SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR0SN--SCALAR TO REMOTE VECTOR MOVE, SP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR0SN    AMAIN                                                          00000200
*                                                                       00000300
* FILLS A V OF LENGTH N, OR A SUCCESIVELY STORED PARTITION OF M OF      00000400
*   LENGTH N = R S, OR ALL OF M OF LENGTH N = R S, WITH A PARTICULAR    00000500
*   SINGLE PRECISION SCALAR, WHERE:                                     00000600
*     V IS A REMOTE SINGLE PRECISION VECTOR,                            00000700
*     M IS A REMOTE SINGLE PRECISION MATRIX,                            00000800
*     R AND S ARE THE DIMENSIONS OF M OR ITS PARTITION.                 00000900
*                                                                       00001000
         INPUT R5,            INTEGER(N) SP                            X00001100
               F0             SCALAR SP                                 00001200
         OUTPUT R2            ZCON(VECTOR(N)) SP                        00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITHM DESCRIPTION IN VR0DN                                  00001600
*                                                                       00001700
VR0SNX   STE@# F0,ARG2(R5)                                              00001800
         BCTB  R5,VR0SNX                                                00001900
         AEXIT                                                          00002000
         ACLOSE                                                         00002100
