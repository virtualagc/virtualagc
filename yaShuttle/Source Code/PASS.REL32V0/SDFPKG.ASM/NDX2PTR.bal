*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    NDX2PTR.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'NDX2PTR  -  CONVERTS SDF INDICES TO SDF POINTERS'       00000000
NDX2PTR  CSECT                                                          00000100
*     UPON ENTRY, REGISTER 1 CONTAINS THE SERVICE CODE AND REGISTER     00000200
*        0 CONTAINS THE INDEX TO BE CONVERTED TO A POINTER.  UPON       00000300
*        RETURN, REGISTER 1 CONTAINS THE CORRESPONDING POINTER.         00000400
*                                                                       00000500
         USING *,15                                                     00000505
         B     *+12                                                     00000510
         DC    CL8'NDX2PTR '                                            00000515
         BALR  15,0                                                     00000517
         DROP  15                                                       00000520
         OSSAVE                                                         00000600
         USING DATABUF,R11                                              00000700
         USING FCBCELL,R12                                              00000800
         B     SERVICES(R1)   BRANCH TO SERVICE ROUTINE                 00000900
SERVICES B     BLKINX                                                   00001000
         B     SYMBINX                                                  00001100
         B     STMTINX                                                  00001200
*                                                                       00001300
BLKINX   LTR   R0,R0                                                    00001400
         BNP   ABEND1                                                   00001500
         CH    R0,NUMBLKS                                               00001600
         BH    ABEND1                                                   00001700
         L     R2,BLKPTR                                                00001800
         LA    R3,12          BLOCK NODES ARE ALWAYS 12 BYTES           00001900
         B     COMMON                                                   00002000
*                                                                       00002100
SYMBINX  LTR   R0,R0                                                    00002200
         BNP   ABEND2                                                   00002300
         CH    R0,NUMSYMBS                                              00002400
         BH    ABEND2                                                   00002500
         L     R2,SYMBPTR                                               00002600
         LA    R3,12          SYMBOL NODES ARE ALWAYS 12 BYTES          00002700
         B     COMMON                                                   00002800
*                                                                       00002900
STMTINX  CH    R0,FSTSTMT                                               00003000
         BL    BADSTMT                                                  00003100
         CH    R0,LSTSTMT                                               00003200
         BH    BADSTMT                                                  00003300
         L     R2,STMTPTR                                               00003400
         LH    R3,NODESIZE                                              00003500
         L     R4,RETARG0     GET STMT #                                00003600
         SH    R4,FSTSTMT     SUBTRACT OFF BASE STMT #                  00003700
         LA    R4,1(R4)       ADD 1 SINCE IT WILL BE SUBTRACTED         00003800
         ST    R4,RETARG0     RESTORE FIXED UP STMT INDEX               00003900
         B     COMMON                                                   00004000
*                                                                       00004100
BADSTMT  MVI   RETCODE+3,36   STMT # OUT OF LEGAL RANGE!                00004200
         B     EXIT                                                     00004300
*                                                                       00004400
COMMON   ST    R2,RETARG1                                               00004500
         STH   R3,TEMP                                                  00004600
         LH    R8,RETARG1     R8 = PAGE #                               00004700
         LH    R5,RETARG0+2   R5 = INDEX                                00004800
         BCTR  R5,R0          DECREMENT INDEX                           00004900
         MH    R5,TEMP                                                  00005000
         LA    R6,1680        BLOCK SIZE FIXED AT 1680 BYTES            00005100
         LH    R4,RETARG1+2   R4 = OFFSET                               00005200
         AR    R5,R4          R5 = TOTAL OFFSET                         00005300
         CR    R6,R5                                                    00005400
         BH    DONE                                                     00005500
         SR    R4,R4                                                    00005600
         DR    R4,R6          R4 = OFFSET                               00005700
         AH    R5,RETARG1     R5 = PAGE #                               00005800
         LR    R8,R5                                                    00005900
         LR    R5,R4                                                    00006000
DONE     STH   R5,RETARG1+2   OFFSET                                    00006100
         STH   R8,RETARG1     PAGE #                                    00006200
EXIT     EQU   *                                                        00006300
         OSRETURN                                                       00006400
*                                                                       00006500
*        ABENDS                                                         00006600
*                                                                       00006700
ABEND1   LA    R1,4006        BAD BLOCK #                               00006800
         B     DOABEND                                                  00006900
ABEND2   LA    R1,4007        BAD SYMBOL #                              00007000
         B     DOABEND                                                  00007100
*                                                                       00007200
DOABEND  ABEND (R1),DUMP                                                00007300
*                                                                       00007400
*        DATA AREA                                                      00007500
*                                                                       00007600
         DS    0H                                                       00007700
TEMP     DS    H                                                        00007800
*                                                                       00007900
*        DSECTS                                                         00008000
*                                                                       00008100
         DATABUF                                                        00008200
         FCBCELL                                                        00008300
         END                                                            00008400
