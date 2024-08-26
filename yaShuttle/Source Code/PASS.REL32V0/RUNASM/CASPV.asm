*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CASPV.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time
*/              library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/              2024-08-22 RSB  Corrected header to respect margin.
*/ Note:        Comments beginning */ in column 1 are from the
*/              Virtual AGC Project. Comments beginning merely with
*/              * are from the original Space Shuttle development.

         TITLE 'CASPV - CHARACTER ASSIGN,PARTITIONED INPUT'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
**********************************************                          00000200
**** CHARACTER ASSIGN - PARTITIONED INPUT ****                          00000300
**********************************************                          00000400
*                                                                       00000500
*                                                                       00000600
CASPV    AMAIN INTSIC=YES                                               00000700
* ASSIGNS A PARTITION OF A CHARACTER STRING TO A                        00000800
* TEMPORARY                                                             00000900
         INPUT R2,            ADDRESS OF CHARACTER STRING              X00001000
               R5,            FIRST ELT. OF PARTITION                  X00001100
               R6             LAST ELT. OF PARTITION                    00001200
         OUTPUT R1            DESTINATION FOR STRING                    00001300
         WORK  R3                                                       00001400
         SHW   0(R1)          SET MAXLEN OF VAC TO 255                  00001500
*                                                                       00001600
*CHECK THE 1ST CHAR (I) SPECIFIED.IF IT'S LESS THAN 1                   00001700
*THEN IT'S AN ERROR.CALL ERROR ROUTINE AND THEN SET                     00001800
*I TO 1                                                                 00001900
*                                                                       00002000
CASP     AENTRY                                                         00002100
* ASSIGNS A PARTITION STRING TO A RECIEVER STRING                       00002200
         INPUT R2,            ADDRESS OF CHARACTER STRING              X00002300
               R5,            FIRST ELT. OF PARTITION                  X00002400
               R6             LAST ELT. OF PARTITION                    00002500
         OUTPUT R1            DESTINATION FOR STRING                    00002600
         WORK  R3                                                       00002700
         LR    R5,R5                                                    00002800
         BP    L1                                                       00002900
         LA    R5,1                                                     00003000
         AERROR 17            INDICES OUT-OF-BOUNDS FOR INPUT STRING    00003100
*                                                                       00003200
*CHECK THE LAST CHAR (J) SPECIFIED.IF IT'S GREATER THAN                 00003300
*THE CURRLENGTH OF THE INPUT STRING THEN THAT'S AN ERROR                00003400
*ALSO.CALL ERROR ROUTINE AND REDUCE J TO THE CURRLENGTH                 00003500
*                                                                       00003600
L1       LH    R3,0(R2)                                                 00003700
         NHI   R3,X'00FF'                                               00003800
         CR    R6,R3                                                    00003900
         BLE   L2                                                       00004000
         LR    R6,R3                                                    00004100
         AERROR 17            INDICES OUT-OF-BOUNDS FOR INPUT STRING    00004200
*                                                                       00004300
*CHECK TO SEE IF J<I-1. IF SO THEN THIS IS AN ERROR ALSO                00004400
*CALL ERROR ROUTINE AND GIVE THE FIXUP AS A NULL STRING                 00004500
*                                                                       00004600
*IF J<I AND THE INPUT STRING IS A NULL STRING THEN                      00004700
*DO NOT GENERATE AN ERROR                                               00004800
*                                                                       00004900
L2       SR    R6,R5                                                    00005000
         AHI   R6,X'0001'                                               00005100
         BNM   L3                                                       00005200
         SR    R6,R6                                                    00005300
         LR    R3,R3                                                    00005400
         BZ    L3                                                       00005500
         AERROR 17            INDICES OUT-OF-BOUNDS FOR INPUT STRING    00005600
*                                                                       00005700
*MAKE SURE PARTITION LENGTH DOES NOT EXCEED THE MAXLENGTH               00005800
*OF THE DESTINATION STRING.IF IT DOES,TRUNCATE IT                       00005900
*                                                                       00006000
L3       LH    R3,0(R1)                                                 00006100
         SRL   R3,8                                                     00006200
         NHI   R3,X'00FF'                                               00006300
         CR    R6,R3                                                    00006400
         BLE   L4                                                       00006500
         LR    R6,R3                                                    00006600
L4       SLL   R3,8           RESTORE MAXLEN OF DESTINATION             00006700
         OR    R3,R6          WITH NEW CURRLEN                          00006800
         STH   R3,0(R1)                                                 00006900
*                                                                       00007000
*INCREMENT CHAR COUNT BEFORE DIVIDING BY TWO TO ROUND                   00007100
*OFF RESULTING 1/2WD COUNT TO THE NEXT HIGHEST 1/2WD                    00007200
*                                                                       00007300
         AHI   R6,X'0001'                                               00007400
         CHI   R6,X'0001'     EXIT IF NULL PARTITION                    00007500
         BE    EXIT                                                     00007600
         SRL   R6,1                                                     00007700
*                                                                       00007800
*IF I IS ODD THEN ALL THAT IS INVOLVED IS A STRAIGHT                    00007900
*1/2WD TO 1/2WD TRANSFER                                                00008000
*                                                                       00008100
*IF NOT THEN YOU HAVE TO DEAL WITH ALIGNMENT PROBLEMS                   00008200
*SIMILARLY TO THE SECOND MOVEMENT IN CONCATENATE(CATV)                  00008300
*                                                                       00008400
         TRB   R5,X'0001'                                               00008500
         SRL   R5,1                                                     00008600
         BO    L6                                                       00008700
         AR    R2,R5                                                    00008800
         LH    R5,0(R2)                                                 00008900
L5       IHL   R5,1(R2)                                                 00009000
         SLL   R5,8                                                     00009100
         STH   R5,1(R1)                                                 00009200
         LA    R1,1(R1)                                                 00009300
         LA    R2,1(R2)                                                 00009400
         SLL   R5,8                                                     00009500
         BCTB  R6,L5                                                    00009600
         B     EXIT                                                     00009700
L6       AR    R2,R5                                                    00009800
L7       LH   R5,1(R2)                                                  00009900
         STH   R5,1(R1)                                                 00010000
         LA    R1,1(R1)                                                 00010100
         LA    R2,1(R2)                                                 00010200
         BCTB  R6,L7                                                    00010300
EXIT     AEXIT                                                          00010400
         ACLOSE                                                         00010500
