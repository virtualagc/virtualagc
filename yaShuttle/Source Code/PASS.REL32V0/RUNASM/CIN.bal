*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CIN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'CIN - CHARACTER INPUT'                                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CIN      AMAIN                                                          00000200
*        CHARACTER INPUT                                                00000300
         INPUT NONE                                                     00000400
         OUTPUT R2            POINTER TO RECEIVING CHARACTER STRING     00000500
         WORK  R1,R6                                                    00000600
         EXTRN IOCODE,IOBUF                                             00000700
         LH    R6,0(R2)       GET MAX AND CURRENT LENGTHS               00000800
         STH   R6,IOBUF       PASS LENGTHS TO HALUCP                    00000900
         LHI   R6,13                                                    00001000
         STH   R6,IOCODE    SAVE I/O CODE                               00001100
         ABAL  INTRAP         GET STRING INTO IOBUF                     00001200
         LR    R1,R2          DESTINATION POINTER FOR CAS               00001300
         LA    R2,IOBUF       SOURCE PTR                                00001400
         ABAL  CAS                                                      00001500
         AEXIT                                                          00001600
         ACLOSE                                                         00001700
