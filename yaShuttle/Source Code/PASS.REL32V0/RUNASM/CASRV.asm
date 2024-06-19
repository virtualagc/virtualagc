*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CASRV.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CASRV--CHARACTER ASSIGN, REMOTE'                        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CASRV    AMAIN                                                          00000200
*                                                                       00000300
* ASSIGN C1 TO C2 WHERE C1 IS A TEMPORARY CHARACTER STRING AND          00000400
*   C2 IS A REMOTE CHARACTER STRING.                                    00000500
*                                                                       00000600
         INPUT R4             ZCON(CHARACTER) C1                        00000700
         OUTPUT R2            ZCON(CHARACTER) C2                        00000800
         WORK  R3,R5,R7                                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   DESCRIPTOR(C2) = 255 || 255;                                        00001200
*   GO TO CASR;                                                         00001300
*                                                                       00001400
         XR    R7,R7          CLEAR R7                                  00001500
         SHW@# ARG2(R7)       SET THE DESCRIPTOR FIELD OF C2            00001600
*                             TO ALL ONES                               00001700
         B     MERG                                                     00001800
CASR     AENTRY                                                         00001900
*                                                                       00002000
* ASSIGN C1 TO C2 WHERE C1 AND C2 ARE CHARACTER STRINGS, AT LEAST       00002100
*   ONE OF WHICH IS REMOTE.                                             00002200
*                                                                       00002300
         INPUT R4             ZCON(CHARACTER) C1                        00002400
         OUTPUT R2            ZCON(CHARACTER) C2                        00002500
         WORK R3,R5,R7                                                  00002600
*                                                                       00002700
* ALGORITHM:                                                            00002800
*   TEMP = MIN(CURRENT_LENGTH(C1), MAXIMUM_LENGTH(C2));                 00002900
*   DESCRIPTOR(C2) = MAXIMUM_LENGTH(C2) || TEMP;                        00003000
*   IF TEMP = 0 THEN                                                    00003100
*     RETURN;                                                           00003200
*   DO FOR I = 1 TO (TEMP + 1) / 2 BY 2;                                00003300
*     C2$(2 AT I) = C1$(2 AT I);                                        00003400
*   END;                                                                00003500
*                                                                       00003600
MERG     XR    R7,R7          CLEAR R7 (TO BE USED IN INDEXED FORM)     00003700
         LH@#  R3,ARG4(R7)    GET C1 DESCRIPTOR HALFOWRD                00003800
         NHI   R3,X'00FF'     MASK OFF MAXLENGTH                        00003900
         LH@#  R5,ARG2(R7)    GET C2 DESCRIPTOR HALFWORD                00004000
         SRL   R5,8           SHIFT MAXLEN TO LOWER BYTE                00004100
         NHI   R5,X'00FF'     MASK (ALSO CLEARS LOWER HALF OF REGISTER) 00004200
         CR    R3,R5          COMPARE CURRLEN TO MAXLEN                 00004300
         BLE   L1             IF CURRLEN > MAXLEN THEN                  00004400
         LR    R3,R5          MOVE MAXLEN TO CURRLEN                    00004500
L1       SLL   R5,8           REMIX MAXLEN                              00004600
         OR    R5,R3          WITH CURRENT LENGTH                       00004700
         STH@# R5,ARG2(R7)    SET DESCRIPTOR OF C2                      00004800
         LA    R3,1(R3)       ADD 1 TO R3 (CURRENT LENGTH)              00004900
         CHI   R3,X'0001'     IF NULL STRING EXIT                       00005000
         BE    EXIT                                                     00005100
         SRL   R3,1           GET # OF HALFWORDS TO BE MOVED            00005200
L2       LH@#  R5,ARG4(R3)    GET HALFWORD FROM C1                      00005300
         STH@# R5,ARG2(R3)    STORE IN HALFWORD OF C2                   00005400
         BCTB  R3,L2                                                    00005500
EXIT     AEXIT                                                          00005600
         ACLOSE                                                         00005700
