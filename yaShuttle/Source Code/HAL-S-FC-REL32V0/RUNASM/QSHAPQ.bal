*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    QSHAPQ.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'QSHAPQ - GENERALIZED SHAPING FUNCTION'                  00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
QSHAPQ   AMAIN ACALL=YES                                                00000200
*                                                                       00000300
*                                                                       00000400
* SHAPES DATA OF A GIVEN TYPE AND PRECISION                             00000500
* TO DATA OF AN EXPLICIT TYPE AND PRECISION                             00000600
*                                                                       00000700
*                                                                       00000800
         INPUT R4,            INT. SCA.  SP/DP                         X00000900
               R6,            INTEGER                                  X00001000
               R5             INTEGER(COUNT)                            00001100
         OUTPUT R2            INT. SCA.  SP/DP                          00001200
         WORK  R1,R3,R7,F0,F1                                           00001300
*                                                                       00001400
*                                                                       00001500
*                                                                       00001600
*                                                                       00001700
*ARGUMENTS:                                                             00001800
*        R1 - DESTINATION POINTER                                       00001900
*        R2 - SOURCE POINTER                                            00002000
*        R6 - FLAG TO INDICATE TYPE OF TRANSFER                         00002100
*              0 - HALFWORD INTEGER                                     00002200
*              1 - FULLWORD INTEGER                                     00002300
*              2 - FULLWORD SCALAR                                      00002400
*              3 - DOUBLEWORD SCALAR                                    00002500
*              (UPPER 8 BITS OF R6 IS INPUT DATATYPE,LOWER IS OUTPUT)   00002600
*        R5 - NUMBER OF ITEMS TO BE TRANSFERRED                         00002700
*                                                                       00002800
*                                                                       00002900
         LR    R1,R2                                                    00003000
         LR    R2,R4                                                    00003100
         LR    R7,R5          SAVE ITEM COUNT                           00003200
         LR    R5,R6                                                    00003300
         SRL   R5,8           INPUT TYPE                                00003400
         NHI   R6,X'00FF'     OUTPUT TYPE                               00003500
         LA    R3,INTAB                                                 00003600
         AR    R3,R5          INPUT BRANCH POINTER                      00003700
         NHI   R5,X'0002'     INPUT IS SCALAR FLAG                      00003800
         SLL   R5,1                                                     00003900
         AR    R5,R6          COMBINE INPUT CLASS AND OUTPUT TYPE       00004000
         LA    R6,OUTTAB                                                00004100
         AR    R6,R5          OUTPUT BRANCH POINTER                     00004200
         AHI   R7,1           ALLOW AT LEAST ONE PASS THROUGH           00004300
SHAPLOOP BCTR  R7,R3          GO IF DATA TO CONVERT                     00004400
         AEXIT                                                          00004500
         SPACE 3                                                        00004600
INTAB    B     LOADH                                                    00004700
         B     LOADI                                                    00004800
         B     LOADE                                                    00004900
         B     LOADD                                                    00005000
OUTTAB   B     STOREH                                                   00005100
         B     STOREI                                                   00005200
         B     CVITOE                                                   00005300
         B     CVITOD                                                   00005400
         B     CVSTOH                                                   00005500
         B     CVSTOI                                                   00005600
         B     STOREE                                                   00005700
         B     STORED                                                   00005800
         SPACE 3                                                        00005900
LOADH    LH    R5,0(R2)                                                 00006000
         SRA   R5,16                                                    00006100
         LA    R2,1(R2)                                                 00006200
         BR    R6                                                       00006300
         SPACE                                                          00006400
LOADI    L     R5,0(R2)                                                 00006500
         LA    R2,2(R2)                                                 00006600
         BR    R6                                                       00006700
         SPACE                                                          00006800
LOADE    LE    F0,0(R2)                                                 00006900
         SER   F1,F1                                                    00007000
         LA    R2,2(R2)                                                 00007100
         BR    R6                                                       00007200
         SPACE                                                          00007300
LOADD    LED   F0,0(R2)                                                 00007400
         LA    R2,4(R2)                                                 00007500
         BR    R6                                                       00007600
         SPACE 2                                                        00007700
CVSTOH   ABAL DTOH,BANK=0                                               00007800
         B     CVSTH                                                    00007900
STOREH   SLL   R5,16                                                    00008000
CVSTH    STH   R5,0(R1)                                                 00008100
         LA    R1,1(R1)                                                 00008200
         B     SHAPLOOP                                                 00008300
         SPACE                                                          00008400
CVSTOI   ABAL DTOI,BANK=0                                               00008500
STOREI   ST    R5,0(R1)                                                 00008600
         LA    R1,2(R1)                                                 00008700
         B     SHAPLOOP                                                 00008800
         SPACE                                                          00008900
CVITOE   ABAL ITOE,BANK=0                                               00009000
STOREE   STE   F0,0(R1)                                                 00009100
         LA    R1,2(R1)                                                 00009200
         B     SHAPLOOP                                                 00009300
         SPACE                                                          00009400
CVITOD   ABAL ITOD,BANK=0                                               00009500
STORED   STED  F0,0(R1)                                                 00009600
         LA    R1,4(R1)                                                 00009700
         B     SHAPLOOP                                                 00009800
         SPACE 2                                                        00009900
         ACLOSE                                                         00010000
