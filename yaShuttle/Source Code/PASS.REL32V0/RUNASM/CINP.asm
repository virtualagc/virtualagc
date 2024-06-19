*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CINP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'CINP - PARTITIONED CHARACTER INPUT'                   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CINP     AMAIN  ACALL=YES                                               00000200
*        PARTITIONED CHARACTER INPUT                                    00000300
         INPUT R5,            FIRST CHARACTER                          X00000400
               R6             LAST CHARACTER                            00000500
         OUTPUT R2            POINTER TO RECEIVING CHARACTER STRING     00000600
         WORK  R1,R7                                                    00000700
         WORK  F0,F1          FROM ACALL CPAS                           00000800
         EXTRN IOCODE,IOBUF                                             00000900
         LHI   R7,X'FF00'                                               00001000
         STH   R7,IOBUF       SET MAX LENGTH=255                        00001100
         LHI   R7,13                                                    00001200
         STH   R7,IOCODE    SAVE I/O CODE                               00001300
         ABAL  INTRAP         GET STRING INTO IOBUF                     00001400
         LR    R1,R2          DESTINATION POINTER FOR CPAS              00001500
         LA    R2,IOBUF       SOURCE PTR                                00001600
         ACALL CPAS                                                     00001700
         AEXIT                                                          00001800
         ACLOSE                                                         00001900
