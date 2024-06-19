*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    IMOD.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'IMOD - MOD FUNCTION,DBL PREC INTEGER'                   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
IMOD     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPUTES THE MOD INSTRACTION :                                        00000400
*                                                                       00000500
*    MOD ( A , B )                                                      00000600
*                                                                       00000700
*  WHERE A & B ARE INTEGERS AND AT LEAST ONE OF THEM IS DP              00000800
*                                                                       00000900
         INPUT R5,            INTEGER  DP                              X00001000
               R6             INTEGER  DP                               00001100
         OUTPUT R5            INTEGER  DP                               00001200
         WORK  R2,R7                                                    00001300
*                                                                       00001400
*                                                                       00001500
*                                                                       00001600
*                                                                       00001700
HMOD     AENTRY                                                         00001800
*                                                                       00001900
* COMPUTES THE MOD INSTRACTION :                                        00002000
*                                                                       00002100
*    MOD ( A , B )                                                      00002200
*                                                                       00002300
*  WHERE A & B ARE INTEGERS SP                                          00002400
*                                                                       00002500
*                                                                       00002600
         INPUT R5,            INTEGER  SP                              X00002700
               R6             INTEGER  SP                               00002800
         OUTPUT R5            INTEGER  SP                               00002900
         WORK  R2,R7                                                    00003000
*                                                                       00003100
*                                                                       00003200
* A PROBLEM WAS FOUND IN THE INTEGER DIVISION ALGORITHM FOR BOTH
* DR103760 AND DR107722.  BOTH OF THESE DRS WERE CAUSED BY
* THE "SRDA R,31" INSTRUCTION USED IN THE DIVIDE ALGORITHM.  IF
* THE REGISTER (R+1) IS NOT CLEARED BEFORE THE SHIFT, THE DIVIDE
* INSTRUCTION CAN RETURN A RESULT 1 GREATER THAN THE EXPECTED RESULT.
* A SIMILAR DIVIDE IS ALSO USED HERE. HOWEVER, ANY INCORRECT RESULT
* WILL BE CORRECTED BEFORE IT LEAVES THE RTL ROUTINE BY THE
* "AR R2,R5" INSTRUCTION THAT IS EXECUTED IF THE INTERMEDIATE
* RESULT OF THE MOD WAS NEGATIVE.
*
*                                                                       00003300
         LR    R2,R5                                                    00003400
         LR    R5,R6      PUT ARG2 IN R5                                00003500
         BP    L1             MAKE DENOMINATOR POSITIVE                 00003600
         BZ    ERRCHK        DEMONINATOR ZERO, THEN POSSIBLE ERROR      00003700
         LCR   R5,R5                                                    00003800
L1       LR    R6,R2      ARG1 IN R6                                    00003900
         SRDA  R6,31          SET UP TO GET REMAINDER                   00004000
         DR    R6,R5                                                    00004100
         MR    R6,R5                                                    00004200
         SRDA  R6,1                                                     00004300
         SR    R2,R7          NOW HAVE REMAINDER=A-(B*(A/B))            00004400
         BNM   EXIT             IF MINUS,MOD IS DENOM+REMAIN            00004500
         AR    R2,R5                                                    00004600
EXIT     LR    R5,R2                                                    00004700
         AEXIT                                                          00004800
ERRCHK    LR   R2,R2   B=0, SO CHECK A                                  00004900
          BNM   EXIT   B=0,A>=0; RETURN A                               00005000
          AERROR  19   B=0,A<0 -> ERROR                                 00005100
          B     EXIT                                                    00005200
          ACLOSE                                                        00005300
