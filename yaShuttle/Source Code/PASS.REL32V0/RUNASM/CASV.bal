*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CASV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CASV - CHARACTER ASSIGN'                                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
**************************                                              00000200
**** CHARACTER ASSIGN ****                                              00000300
**************************                                              00000400
*                                                                       00000500
*ARGUMENTS:                                                             00000600
*        R4    ADDRESS OF DESTINATION STRING                            00000700
*        R2    ADDRESS OF SOURCE STRING                                 00000800
*                                                                       00000900
*                                                                       00001000
*CHARACTER VALUES ARE PACKED TWO BYTES PER HALFWORD AND ARE             00001100
*ALWAYS ALIGNED ON HALFWORD BOUNDARIES                                  00001200
*                                                                       00001300
*THE FIRST HALFWORD ALWAYS CONTAINS TWO BYTES  GIVING THE               00001400
*MAXLEN AND CURRLEN INFORMATION. GREATEST POSSIBLE MAXLEN               00001500
*IS 255 AND ALL VAC'S HAVE THAT MAXLEN.                                 00001600
*                                                                       00001700
*IN THIS STRAIGHT CHARACTER STRING TO STRING ASSIGNMENT                 00001800
*MOVEMENT IS MADE HALFWORD BY HALFWORD AND IF THE                       00001900
*LOWER BYTE OF THE LAST HALFWORD IS NOT SIGNIFICANT IN                  00002000
*THE STRING IT IS MOVED ANYWAY SINCE IT IS IGNORED                      00002100
*I.E. IF THE CURRLEN OF ANY STRING IS ODD,THEN THE                      00002200
*LOWER BYTE OF THE LAST HALFWORD IS GARBAGE AND HAS NO                  00002300
*PARTICULAR VALUE                                                       00002400
*                                                                       00002500
*                                                                       00002600
CASV     AMAIN INTSIC=YES                                               00002700
* CHARACTER ASSIGN FOR OUTPUT;ASSIGN A                                  00002800
* CHARACTER STRING FROM DATA TO I/O                                     00002900
* BUFFER AREA                                                           00003000
         INPUT R2             ADDRESS OF SOURCE STRING                  00003100
         OUTPUT R1            ADDRESS OF DESTINATION STRING             00003200
         WORK  R3,R5                                                    00003300
*                                                                       00003400
*SET MAXLENGTH OF VAC TO 255 AND FALL INTO REGULAR ROUTINE              00003500
*                                                                       00003600
         SHW   0(R1)                                                    00003700
*                                                                       00003800
*FETCH CURRLENGTH OF SOURCE AND MAXLENGTH OF DESTINATION                00003900
*AND TAKE THE MIN OF THE TWO AS THE NEW CURRLENGTH                      00004000
*OF THE DESTINATION                                                     00004100
*                                                                       00004200
CAS      AENTRY                                                         00004300
* CHARACTER ASSIGN FOR OUTPUT;ASSIGN A CHARACTER STRING                 00004400
* FROM DATA TO I/O BUFFER AREA                                          00004500
         INPUT R2             ADDRESS OF SOURCE STRING                  00004600
         OUTPUT R1            ADDRESS OF DESTINATION ADDRESS            00004700
         WORK  R3,R5                                                    00004800
         LH    R3,0(R2)       SOURCE DESCRIPTOR HALFWORD                00004900
         NHI   R3,X'00FF'     MASK                                      00005000
         LH    R5,0(R1)       DESTINATION DESCRIPTOR                    00005100
         SRL   R5,8           SHIFT MAXLEN TO LOWER BYTE                00005200
         NHI   R5,X'00FF'     MASK                                      00005300
         CR    R3,R5          COMPARE CURRLEN TO MAXLEN                 00005400
         BLE   L1             IF FORMER > LATTER THEN                   00005500
         LR    R3,R5          MOVE LATTER TO FORMER                     00005600
L1       SLL   R5,8           REMIX WITH MAXLEN AND STORE               00005700
         OR    R5,R3                                                    00005800
         STH   R5,0(R1)                                                 00005900
*                                                                       00006000
*INCREMENT THE CHARACTER COUNT BEFORE SHIFTING RIGHT ONE                00006100
*TO DIVIDE BY TWO AND GET THE NUMBER OF HALFWORDS TO MOVE               00006200
*THE INCREMENT FORCES THE HALFWORD COUNT TO THE NEXT HIGHEST            00006300
*HALFWORD,IF THE CHAR COUNT WAS ODD                                     00006400
*                                                                       00006500
         LA    R3,1(R3)                                                 00006600
         CHI   R3,X'0001'     IF NULL STRING EXIT                       00006700
         BE    EXIT                                                     00006800
         SRL   R3,1                                                     00006900
*                                                                       00007000
*NOW LOAD AND STORE HALFWORD BY HALFWORD                                00007100
*                                                                       00007200
L2       LH    R5,1(R2)                                                 00007300
         STH   R5,1(R1)                                                 00007400
         LA    R1,1(R1)       UPDATE POINTERS                           00007500
         LA    R2,1(R2)                                                 00007600
         BCTB  R3,L2                                                    00007700
EXIT     AEXIT                                                          00007800
         ACLOSE                                                         00007900
