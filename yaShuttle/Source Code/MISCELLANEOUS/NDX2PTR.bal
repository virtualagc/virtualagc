*                                                                       00010000
* NDX2TR:  VERS 2.0     CRAIG W. SCHULENBERG     10/30/92               00020001
*                         -- BASELINED THIS VERSION (NO CHANGES HAVE    00030000
*                              OCCURRED SINCE THE 1977 REFERENCE        00040000
*                              LISTING.                                 00050000
*                                                                       00060000
         TITLE 'NDX2PTR  -  CONVERTS SDF INDICES TO SDF POINTERS'       00070000
NDX2PTR  CSECT                                                          00080000
*     UPON ENTRY, REGISTER 1 CONTAINS THE SERVICE CODE AND REGISTER     00090000
*        0 CONTAINS THE INDEX TO BE CONVERTED TO A POINTER.  UPON       00100000
*        RETURN, REGISTER 1 CONTAINS THE CORRESPONDING POINTER.         00110000
*                                                                       00120000
         USING *,15                                                     00130000
         B     *+12                                                     00140000
         DC    CL8'NDX2PTR '                                            00150000
         BALR  15,0                                                     00160000
         DROP  15                                                       00170000
         OSSAVE                                                         00180000
         USING DATABUF,R11                                              00190000
         USING FCBCELL,R12                                              00200000
         B     SERVICES(R1)   BRANCH TO SERVICE ROUTINE                 00210000
SERVICES B     BLKINX                                                   00220000
         B     SYMBINX                                                  00230000
         B     STMTINX                                                  00240000
*                                                                       00250000
BLKINX   LTR   R0,R0                                                    00260000
         BNP   ABEND1                                                   00270000
         CH    R0,NUMBLKS                                               00280000
         BH    ABEND1                                                   00290000
         L     R2,BLKPTR                                                00300000
         LA    R3,12          BLOCK NODES ARE ALWAYS 12 BYTES           00310000
         B     COMMON                                                   00320000
*                                                                       00330000
SYMBINX  LTR   R0,R0                                                    00340000
         BNP   ABEND2                                                   00350000
         CH    R0,NUMSYMBS                                              00360000
         BH    ABEND2                                                   00370000
         L     R2,SYMBPTR                                               00380000
         LA    R3,12          SYMBOL NODES ARE ALWAYS 12 BYTES          00390000
         B     COMMON                                                   00400000
*                                                                       00410000
STMTINX  CH    R0,FSTSTMT                                               00420000
         BL    BADSTMT                                                  00430000
         CH    R0,LSTSTMT                                               00440000
         BH    BADSTMT                                                  00450000
         L     R2,STMTPTR                                               00460000
         LH    R3,NODESIZE                                              00470000
         L     R4,RETARG0     GET STMT #                                00480000
         SH    R4,FSTSTMT     SUBTRACT OFF BASE STMT #                  00490000
         LA    R4,1(R4)       ADD 1 SINCE IT WILL BE SUBTRACTED         00500000
         ST    R4,RETARG0     RESTORE FIXED UP STMT INDEX               00510000
         B     COMMON                                                   00520000
*                                                                       00530000
BADSTMT  MVI   RETCODE+3,36   STMT # OUT OF LEGAL RANGE!                00540000
         B     EXIT                                                     00550000
*                                                                       00560000
COMMON   ST    R2,RETARG1                                               00570000
         STH   R3,TEMP                                                  00580000
         LH    R8,RETARG1     R8 = PAGE #                               00590000
         LH    R5,RETARG0+2   R5 = INDEX                                00600000
         BCTR  R5,R0          DECREMENT INDEX                           00610000
         MH    R5,TEMP                                                  00620000
         LA    R6,1680        BLOCK SIZE FIXED AT 1680 BYTES            00630000
         LH    R4,RETARG1+2   R4 = OFFSET                               00640000
         AR    R5,R4          R5 = TOTAL OFFSET                         00650000
         CR    R6,R5                                                    00660000
         BH    DONE                                                     00670000
         SR    R4,R4                                                    00680000
         DR    R4,R6          R4 = OFFSET                               00690000
         AH    R5,RETARG1     R5 = PAGE #                               00700000
         LR    R8,R5                                                    00710000
         LR    R5,R4                                                    00720000
DONE     STH   R5,RETARG1+2   OFFSET                                    00730000
         STH   R8,RETARG1     PAGE #                                    00740000
EXIT     EQU   *                                                        00750000
         OSRETURN                                                       00760000
*                                                                       00770000
*        ABENDS                                                         00780000
*                                                                       00790000
ABEND1   LA    R1,4006        BAD BLOCK #                               00800000
         B     DOABEND                                                  00810000
ABEND2   LA    R1,4007        BAD SYMBOL #                              00820000
         B     DOABEND                                                  00830000
*                                                                       00840000
DOABEND  ABEND (R1),DUMP                                                00850000
*                                                                       00860000
*        DATA AREA                                                      00870000
*                                                                       00880000
         DS    0H                                                       00890000
TEMP     DS    H                                                        00900000
*                                                                       00910000
*        DSECTS                                                         00920000
*                                                                       00930000
         DATABUF                                                        00940000
         FCBCELL                                                        00950000
         END                                                            00960000
