*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CATV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CATV - CONCATENATE'                                     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
*********************                                                   00000200
**** CONCATENATE ****                                                   00000300
*********************                                                   00000400
*                                                                       00000500
*                                                                       00000600
*ARGUMENTS:                                                             00000700
*        R1    ADDRESS OF DESTINATION STRING                            00000800
*        R2    ADDRESS OF 1ST SOURCE STRING                             00000900
*        R3    ADDRESS OF 2ND SOURCE STRING                             00001000
*                                                                       00001100
*CONCATENATION IS ESSENTIALLY TWO CONSECUTIVE CHARACTER                 00001200
*ASSIGNMENTS.THE SECOND ONE PICKING UP WHERE THE FIRST ONE              00001300
*LEFT OFF.HOWEVER THERE IS ONE IMPORTANT CONSIDERATION                  00001400
*NOT TO BE OVERLOOKED                                                   00001500
*IF THE FIRST CHAR STRING HAS AN ODD CURRLEN THEN THE                   00001600
*SECOND ASSINGMENT MUST BEGIN AT THE LOWER BYTE OF THE LAST HALFWORD    00001700
*OF THE FIRST STRING,AND FURTHERMORE MUST TAKE *EVERY* HALFWORD FROM    00001800
*THE SECOND STRING AND PUT THE UPPER BYTE IN THE LOWER BYTE OF A        00001900
*HALFWORD IN THE DESTINATION,AND EVERY LOWER BYTE GOES INTO THE UPPER   00002000
*BYTE OF THE NEXT CORRESPONDING HALFWORD IN THE DESTINATION,AND IF      00002100
*YOU HAVEN'T GOTTEN THE DRIFT OF WHAT I'M SAYING YET,I CAN              00002200
*UNDERSTAND WHY.IMAGINE WHAT I MUST HAVE GONE THROUGH TO WRITE          00002300
*THE STUPID ROUTINE                                                     00002400
*                                                                       00002500
*                                                                       00002600
*CONCATENATES TWO STRINGS AND STORES IN TEMPORARY                       00002700
CATV     AMAIN INTSIC=YES                                               00002800
* CATENATES TWO CHARACTER STRINGS AND STORES INTO A TEMPORARY           00002900
         INPUT R2,            ADDRESS OF FIRST SOURCE STRING           X00003000
               R3             ADDRESS OF SECOND SOURCE STRING           00003100
         OUTPUT R1            ADDRESS OF DESTINATION STRING             00003200
         WORK  R5,R6,R7,F0,F1                                           00003300
*                                                                       00003400
*SET MAXLENGTH OF VAC TO 255 AND FALL INTO REGULAR ROUTINE              00003500
*                                                                       00003600
         SB    0(R1),X'FF00'  CURRENT LENGTH IS NOT DISTURBED           00003700
*                                                                       00003800
*GET CURRLENGTH OF 1ST SOURCE STRING AND MAXLENGTH                      00003900
*OF DESTINATION AND TAKE THE MIN OF THE TWO AS                          00004000
*THE NUMBER OF CHARS TO MOVE IN THE FIRST ASSIGNMENT                    00004100
*                                                                       00004200
*CONCATENATES TWO STRINGS AND STORES IN A THIRD                         00004300
CAT      AENTRY                                                         00004400
* CATENATES TWO CHARACTER STRINGS AND STORES INTO A THIRD STRING        00004500
         INPUT R2,            ADDRESS OF FIRST SOURCE STRING           X00004600
               R3             ADDRESS OF SECOND SOURCE STRING           00004700
         OUTPUT R1            ADDRESS OF DESTINATION STRING             00004800
         WORK  R5,R6,R7,F0,F1                                           00004900
         LH    R5,0(R2)       DESCRIPTOR HALFWORD OF 1ST SOURCE         00005000
         NHI   R5,X'00FF'     MASK OFF CURRLEN BYTE                     00005100
         LH    R6,0(R1)       DESCRIPTOR HALFWORD OF DESTINATION        00005200
         SRL   R6,8           SHIFT MAXLENGTH TO LOWER BYTE             00005300
         NHI   R6,X'00FF'     MASK                                      00005400
         CR    R5,R6          COMPARE CURRLENGTH TO MAXLENGTH           00005500
         BLE   L1             IF FORMER>LATTER THEN                     00005600
         LR    R5,R6          MOVE LATTER TO FORMER                     00005700
L1       LR    R7,R5          SAVE R5 FOR LATER USE                     00005800
*                                                                       00005900
*INCREMENT THE CHAR COUNT IN R7 BEFORE DIVIDING BY 2                    00006000
*SO THAT THE RESULTING COUNT OF HALFWORDS TO MOVE                       00006100
*ROUNDS UP TO THE NEXT HIGHEST HALFWORD IF THE                          00006200
*CHAR COUNT IS ODD                                                      00006300
*                                                                       00006400
         AHI   R7,X'0001'                                               00006500
         SRL   R7,1           SHIFT RIGHT ONE TO DIVIDE BY TWO          00006600
         LFLR  F1,R1          SAVE DESTINATION POINTER                  00006700
         LR    R5,R5          IF STR1 IS NULL - SKIP MOVE               00006800
         BZ    L3                                                       00006900
         LFLR  F0,R6          SAVE R6 TEMPORARILY                       00007000
*                                                                       00007100
*IF THE 1ST SOURCE STRING AND THE DESTINATION STRING ARE                00007200
*THE SAME STRING THEN DON'T MOVE ANYTHING BECAUSE THE                   00007300
*DATA IS ALREADY THERE.JUST UPDATE THE POINTER AND GO                   00007400
*ON TO MOVE THE SECOND STRING                                           00007500
*                                                                       00007600
         CR    R1,R2          COMPARE ADDRESS OF STRINGS                00007700
         BNE   L2             NOT EQ - DO MOVE                          00007800
         AR    R1,R7          ADD HALFWORD COUNT TO ADDRESS POINTER     00007900
         SLL   R7,16          CLEAR CHAR COUNT,BUT SAVE ODD CHAR BIT    00008000
         B     L3                                                       00008100
*                                                                       00008200
*MOVE THE FIRST STRING HALFWORD BY HALFWORD IGNORING ANY                00008300
*GARBAGE THAT MAY BE IN THE LOW ORDER BYTE OF THE LAST                  00008400
*HALFWORD IF THE CHAR COUNT IS ODD                                      00008500
*IT WILL BE TAKEN CARE OF LATER                                         00008600
*                                                                       00008700
L2       LH    R6,1(R2)                                                 00008800
         STH   R6,1(R1)                                                 00008900
         LA    R1,1(R1)       UPDATE POINTERS                           00009000
         LA    R2,1(R2)                                                 00009100
         BCTB  R7,L2                                                    00009200
         LFXR  R6,F0          RESTORE R6                                00009300
*                                                                       00009400
*GET THE CURRLENGTH OF THE SECOND SOURCE STRING AND                     00009500
*ADD IT TO THE CHAR COUNT OF THE FIRST MOVE AND TAKE THE                00009600
*MIN OF THAT AND THE MAXLENGTH OF THE DESTINATION AS THE                00009700
*NEW CURRLENGTH OF THE DESTINATION                                      00009800
*                                                                       00009900
*IF THE SUM OF THE TWO CURRLENGTHS EXCEED THE MAXLENGTH                 00010000
*THEN FIXUP BY SUBTRACTING THE MAXLENGTH FROM THE SUM                   00010100
*AND TAKING THAT DIFFERENCE AND SUBTRACTING THAT FROM                   00010200
*THE CURRLENGTH OF THE 2ND SOURCE STRING,TAKING THAT                    00010300
*VALUE AS THE NUMBER OF CHARS TO MOVE.THEN TAKE THE                     00010400
*MAXLENGTH OF THE DESTINATION AS ITS NEW CURRLENGTH                     00010500
*                                                                       00010600
L3       LH    R2,0(R3)       DESCRIPTOR HALFWORD OF 2ND SOURCE         00010700
         NHI   R2,X'00FF'     MASK OFF CURRLENGTH BYTE                  00010800
         LA    R5,0(R5,R2)    ADD CURRLENGTH TO CHAR COUNT OF 1ST MOVE  00010900
         CR    R5,R6          COMPARE SUM TO MAXLENGTH                  00011000
         BLE   L4             IF FORMER>LATTER THEN                     00011100
         SR    R5,R6          FORMER=FORMER-LATTER                      00011200
         SR    R2,R5          AND CURRLEN(STR2)=ITSELF-THAT DIFFERENCE  00011300
         LR    R5,R6          AND THE NEW DEST CURRLENGTH=ITS MAXLENGTH 00011400
L4       SLL   R6,8           REMIX NEW CURRLEN WITH MAXLEN AND STORE   00011500
         OR    R6,R5                                                    00011600
*                                                                       00011700
*INCREMENT THE CHAR COUNT HERE WHILE WE MOVE IT TO MAKE ROOM            00011800
*FOR AN ADDRESS POINTER WHICH NEEDS THIS REGISTER WHILE R5 IS FREE      00011900
*                                                                       00012000
         LA    R5,1(R2)                                                 00012100
         LFXR  R2,F1          RESTORE DESTINATION POINTER               00012200
         STH   R6,0(R2)       STORE UPDATED DESCRIPTOR                  00012300
         LR    R2,R3          MOVE R3 FOR ADDRESSING CONSIDERATIONS     00012400
         CHI   R5,X'0001'     IF THE 2ND STRING IS NULL THEN WE'RE DONE 00012500
         BE    EXIT           EXIT                                      00012600
         SRL   R5,1           DIVIDE CHAR COUNT BY TWO                  00012700
         LR    R7,R7          SEE IF LAST CHAR OF STR1 WAS ODD          00012800
         BNZ   L6             IF NOT MOVE STR2 HALFWORD BY HALFWORD     00012900
*                                                                       00013000
*IF THE IS AN ODD CHAR SITTING AT THE END OF THE LAST STRING            00013100
*THEN FETCH THAT LAST HALFWORD BACK,SHIFT RIGHT 8 BIT TO                00013200
*PUT THE LAST CHAR INTO THE LOWER BYTE OF THE UPPER HALFWORD            00013300
*OF THE REGISTER.THEN INSERT THE NEXT HALFORD TO BE STORED              00013400
*INTO THE LOWER HALFWORD OF THE REGISTER LEAVING YOU WITH               00013500
*THREE CONTIGUOUS CHARS IN THE REGISTER                                 00013600
*THEN SHIFT THE ENTIRE THING LEFT 8 BITS TO TAKE THE FIRST              00013700
*TWO OF THOSE AND STORE THEM BACK INTO THE LAST HALFWORD                00013800
*OF THE PREVIOUS STRING                                                 00013900
*                                                                       00014000
*FROM THERE YOU ESSENTIALLY REPEAT THE ENTIRE PROCESS FOR EVERY         00014100
*HALFWORD YOU FETCH FROM THE 2ND SOURCE STRING IN ORDER THAT            00014200
*EVERY THING COMES OUT ALIGNED PROPERLY                                 00014300
*                                                                       00014400
         LH    R6,0(R1)       LAST HALFWORD OF 1ST SOURCE               00014500
         SRL   R6,8                                                     00014600
L5       IHL   R6,1(R2)                                                 00014700
         SLL   R6,8                                                     00014800
         STH   R6,0(R1)                                                 00014900
         LA    R1,1(R1)       UPDATE POINTERS                           00015000
         LA    R2,1(R2)                                                 00015100
         SLL   R6,8                                                     00015200
         BCTB  R5,L5                                                    00015300
*                                                                       00015400
*IF THERE'S ANOTHER ODD CHAR LEFT GET IT OUT OF THE LOWER HALFWORD      00015500
*OF R6 AND STORE IT AS IS                                               00015600
*                                                                       00015700
         LR    R5,R5                                                    00015800
         BZ    EXIT                                                     00015900
         SLL   R6,8                                                     00016000
         STH   R6,0(R1)                                                 00016100
         B     EXIT           RETURN                                    00016200
*                                                                       00016300
*THIS IS WHERE THE ROUTINE GOES IF THERE'S NO ODD CHAR                  00016400
*TO WORRY ABOUT                                                         00016500
*MOVEMENT IS A SIMPLE HALFWORD BY HALFWORD TRANSFER                     00016600
*                                                                       00016700
L6       LH    R6,1(R2)                                                 00016800
         STH   R6,1(R1)                                                 00016900
         LA    R1,1(R1)                                                 00017000
         LA    R2,1(R2)                                                 00017100
         BCTB  R5,L6                                                    00017200
EXIT     AEXIT                                                          00017300
         ACLOSE                                                         00017400
