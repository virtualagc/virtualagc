*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    RANDOM.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'RANDOM-RANDOM NUM. GENERATOR'                         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
RANDOM   AMAIN                                                          00000200
*                                                                       00000300
*  GENERATES RANDOM NUMBER WITH UNIFORM                                 00000400
*  DISTRIBUTION IN RANGE (0.0,1.0)                                      00000500
*                                                                       00000600
         INPUT NONE                                                     00000700
         OUTPUT F0            SCALAR  DP                                00000800
         WORK  R5,R6,R7,F1,F2,F3,R2                                     00000900
*                                                                       00001000
*                                                                       00001100
         BAL    R5,RANU   GENERATE RANDOM NUMBER                        00001200
EXIT     AEXIT            THEN RETURN                                   00001300
RANU     L   R6,=F'65539'                                               00001400
         M    R6,SEED   USE ONLY LEAST SIGNIF. BITS                     00001500
         SRDA  R6,1           FRACTIONAL TO INTEGER                     00001600
         LR   R6,R7     SET CONDITION CODE                              00001700
         BNM  NOFIX                                                     00001800
         S    R6,NEGMAX     IF (SEED)<0 THEN FIX UP                     00001900
NOFIX    ST   R6,SEED    SAVE UPDATED SEED                              00002000
         CVFL   F0,R6   CONVERT,THEN MULT. BY 16**4                     00002100
         MED  F0,=X'3D20000000000000'   AND BY 2**-31                   00002200
*      RANU=SEED*2**-31                                                 00002300
         BR   R5                                                        00002400
*                                                                       00002500
RANDG    AENTRY                                                         00002600
*                                                                       00002700
*  GENERATES RANDOM NUMBER FROM GAUSSIAN                                00002800
*  DISTRIBUTION MEAN ZERO,VARIANCE ONE                                  00002900
*                                                                       00003000
         INPUT NONE                                                     00003100
         OUTPUT F0            SCALAR  DP                                00003200
         WORK  R5,R6,R7                                                 00003300
*                                                                       00003400
*                                                                       00003500
         SEDR  F2,F2                                                    00003600
         LA   R2,12         LOOP TWELVE TIMES                           00003700
LOOP     BAL  R5,RANU                                                   00003800
         AEDR F2,F0     A=A+RANU                                        00003900
         BCT  R2,LOOP                                                   00004000
         SED  F2,=D'6.0' GRANDOM=A-6.0                                  00004100
         LER  F0,F2      ANSWER IN F0                                   00004200
         LER  F1,F3      FAKE D.P. LOAD                                 00004300
         B    EXIT                                                      00004400
         DS    0D                                                       00004500
NEGMAX   DC   X'80000000'                                               00004600
         ADATA                                                          00004700
         SPOFF                                                          00004800
SEED     DC   F'1435'                                                   00004900
         SPON                                                           00005000
         ACLOSE                                                         00005100
