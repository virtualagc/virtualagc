*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    COUTP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'COUTP, COUT- CHARACTER OUTPUT'                         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
COUTP    AMAIN  ACALL=YES                                               00000200
*        CHARACTER PARTITIONED OUTPUT                                   00000300
         INPUT R2,            CHARACTER STRING                         X00000400
               R5,            INTEGER SP FIRST CHARACTER               X00000500
               R6             INTEGER SP LAST CHARACTER                 00000600
         OUTPUT NONE                                                    00000700
         WORK  R1,R2                                                    00000800
*                                                                       00000900
         LA    R1,IOBUF       TARGET STR FOR CASPV                      00001000
*        SOURCE STRING PARMS ARE ALREADY IN R2,R5,R6                    00001100
         ABAL  CASPV      CASPV SETS MAXLEN TO 255                      00001200
         B     CALLOUT1       GO TELL HALUCP                            00001300
         EXTRN IOBUF,IOCODE                                             00001400
COUT     AENTRY                                                         00001500
*        CHARACTER OUTPUT                                               00001600
         INPUT R2             CHARACTER STRING                          00001700
         OUTPUT NONE                                                    00001800
         LA    R1,IOBUF   R1-->DESTINATION STRING FOR CASV              00001900
         ABAL  CASV                                                     00002000
CALLOUT1 LHI   R6,13                                                    00002100
         STH   R6,IOCODE   SAVE I/O CODE                                00002200
         ACALL OUTER1   OUTER1 BRANCHES TO OUTRAP                       00002300
         AEXIT                                                          00002400
         ACLOSE                                                         00002500
