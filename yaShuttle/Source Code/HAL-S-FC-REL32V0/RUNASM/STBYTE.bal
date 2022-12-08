*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    STBYTE.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'STBYTE--INTRINSIC USED FOR CHARACTER MANIPULATION'      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
STBYTE   AMAIN INTSIC=INTERNAL                                          00000200
*                                                                       00000300
* STORE ONE CHARACTER INTO A CHARACTER STRING.  THIS IS USED FOR        00000400
*   CHARACTER MANIPULATION BY OTHER CHARACTER ROUTINES.                 00000500
*                                                                       00000600
         INPUT R1,            BYTE DISP INDICATOR IN LOWER HALF        X00000700
               R5             SINGLE CHARACTER                          00000800
         OUTPUT R1            HALFWORD TO STORE INTO                    00000900
         WORK  R4,F0                                                    00001000
*                                                                       00001100
*                                                                       00001200
*                                                                       00001300
         LFLR  F0,R4          SAVE RETURN ADDRESS IN F0                 00001400
         L     R4,BYTEDISP    GET WHICH BYTE POINTER                    00001500
         AR    R1,R4          INCREMENT BYTE ADDRESS PTR                00001600
         NR    R4,R1          TEST FOR WHICH BYTE                       00001700
         BZ    LOWER          IF ZERO THEN LOWER BYTE                   00001800
*                                                                       00001900
* THIS PART HANDLES STORING OF THE UPPER BYTE                           00002000
*                                                                       00002100
         ZB    1(R1),X'FF00'  ZERO OUT  CURRENTLY EXISTING CHAR         00002200
         SLL   R5,8           GET INPUT CHAR TO UPPER HALF              00002300
         AH    R5,1(R1)       MERGE TWO CHARS                           00002400
         STH   R5,1(R1)       STORE 2 CHARS                             00002500
         LFXR  R4,F0          RESTORE RETURN ADDRESS                    00002600
         AEXIT                AND RETURN                                00002700
*                                                                       00002800
* THIS PART HANDLES STORING OF THE LOWER BYTE                           00002900
*                                                                       00003000
         DS    0F                                                       00003100
BYTEDISP DC    X'00008000'                                              00003200
LOWER    ZB    0(R1),X'00FF'  ZERO OUT EXISTING LOWER CHAR              00003300
         AH    R5,0(R1)       MERGE TWO CHARS                           00003400
         STH   R5,0(R1)       STORE TWO CHARS                           00003500
         LFXR  R4,F0          RESTORE RETURN ADDRESS                    00003600
         AEXIT                AND RETURN                                00003700
         ACLOSE                                                         00003800
