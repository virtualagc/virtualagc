*                                                                       00000100
* SDFOUT:  VERS 2.0     CRAIG W. SCHULENBERG     11/02/92               00000200
*                         -- ADD LOGIC TO OBTAIN TTRS BY READS AND      00000300
*                              REMOVED USE OF TRAILING TTR PAGES        00000400
*                              CR # 11097 (ELIMINATE USE OF             00000500
*                                NOTELISTS IN HAL COMPILER)             00000600
SDFOUT   CSECT                                                          00036200
         EXTRN OUTPUT5                                                  00036300
         USING *,10                                                     00036400
R0       EQU   0                                                        00036500
R1       EQU   1                                                        00036600
R2       EQU   2                                                        00036700
R3       EQU   3                                                        00036800
R4       EQU   4                                                        00036900
R5       EQU   5                                                        00037000
R6       EQU   6                                                        00037100
R7       EQU   7                                                        00037200
R8       EQU   8                                                        00037300
R9       EQU   9                                                        00037400
R10      EQU   10                                                       00037500
R11      EQU   11                                                       00037600
R12      EQU   12                                                       00037700
R13      EQU   13                                                       00037800
R14      EQU   14                                                       00037900
R15      EQU   15                                                       00038000
         B     SDFTYPE(R1)                                              00038400
SDFTYPE  B     OPENSDF        MONITOR(14,LAST_PAGE)                     00038500
         B     WRITESDF       MONITOR("4000E",BUFFER_ADDR)              00038600
         B     CLOSESDF       MONITOR("8000E",NAME)                     00038700
         SPACE 2                                                        00038800
OPENSDF  MVI   OPENFLAG,1     INDICATE THAT OPEN HAS BEEN DONE          00038900
         OPEN  (OUTPUT5,(UPDAT))                                        00039000
         L     R5,=V(OUTPUT5)                                           00039100
         USING IHADCB,R5                                                00039200
         TM    DCBOFLGS,X'10'                                           00039300
         BZ    16(R11)        BADOPEN                                   00039400
         STH   R2,LASTPAGE    SAVE THE USER DATA                        00039500
         BLDL  (R5),BLDLAREA                                            00039600
         LTR   R15,R15                                                  00039700
         BNZ   NOUPDAT                                                  00039800
         CLC   LASTPAGE(2),PGELAST                                      00039900
         BNE   NOUPDAT                                                  00040000
         MVI   UPDATFLG,1                                               00040100
         FIND  (R5),TTR,C                                               00040200
         BR    R11                                                      00040300
NOUPDAT  CLOSE (OUTPUT5)                                                00040400
         OPEN  (OUTPUT5,(OUTPUT))                                       00040500
         BR    R11                                                      00040600
         DROP  5                                                        00040700
         SPACE 2                                                        00040800
WRITESDF LR    R7,R2                                                    00040900
         L     R15,AREADBUF                                             00041000
         LTR   R15,R15                                                  00041100
         BNZ   CHECKTTR                                                 00041200
         ST    R7,AREADBUF                                              00041300
         BR    R11                                                      00041400
CHECKTTR L     R15,ATTRBUF                                              00041500
         LTR   R15,R15                                                  00041600
         BNZ   CHECKUPD                                                 00041700
         ST    R7,ATTRBUF                                               00041800
         BR    R11                                                      00041900
CHECKUPD CLI   UPDATFLG,0                                               00042000
         BE    NORMAL                                                   00042100
         MVC   BUFLOC,AREADBUF                                          00042200
         READ  UPDECB,SF,MF=E                                           00042300
         CHECK UPDECB                                                   00042400
         ST    R7,BUFLOC                                                00042500
         WRITE UPDECB,SF,MF=E                                           00042600
         CHECK UPDECB                                                   00042700
         BR    R11                                                      00042800
NORMAL   BAL   R8,WRITESET    DO WRITE - CHECK - NOTE                   00042900
         LH    R5,TTRINDEX                                              00043000
         L     R3,ATTRBUF                                               00043100
         ST    R1,0(R3,R5)    PUT TTR IN RIGHT TABLE ENTRY              00043200
         LA    R5,4(R5)       UPDATE TTR POINTERS                       00043301
         CH    R5,=H'3072'    IS IT TOO BIG?                            00043400
         BH    8(R11)         ABEND EXIT                                00043500
         STH   R5,TTRINDEX                                              00043600
         BR    R11                                                      00043700
TTRINDEX DC    H'0'                                                     00043800
WRITESET WRITE SDFDECB,SF,OUTPUT5,(R7),1680                             00043900
         CHECK SDFDECB                                                  00044000
         L     R3,=V(OUTPUT5)                                           00044100
         NOTE  (R3)                                                     00044200
         BR    R8                                                       00044300
         SPACE 3                                                        00044400
MOVE     MVC   STOWNAME(0),0(R2)                                        00044500
MOVE1    MVC   NAME(0),0(R2)                                            00044600
         SPACE 1                                                        00044700
CLOSESDF LR    R3,R2                                                    00044800
         SRL   R3,24                                                    00044900
         CLI   OPENFLAG,0                                               00045000
         BNE   REALCLOS                                                 00045100
         EX    R3,MOVE1                                                 00045200
         BR    R11                                                      00045300
REALCLOS MVI   OPENFLAG,0                                               00045400
         CLI   UPDATFLG,1                                               00045500
         BE    RETURN1                                                  00045600
         EX    R3,MOVE        MOVE THE MEMBER NAME                      00045700
         L     R7,ATTRBUF                                               00045800
         LH    R5,TTRINDEX    GET TABLE INDEX                           00045900
         LA    R9,255         GET MAX TTR PER PAGE                      00046000
         LTR   R6,R5                                                    00046100
         BZ    8(R11)         ABEND                                     00046200
         SR    R4,R4                                                    00046300
         SRL   R6,2                                                     00046400
NEXTPAGE CH    R6,=H'256'     IS THERE MORE THAN ONE PAGE?              00046500
         BL    LASTONE                                                  00046600
         BAL   R8,WRITESET    WRITE NOTE LIST                           00046700
         LA    R7,1024(R7)    UP INDICES                                00046800
         ST    R1,STOWTTR(R4)                                           00046900
         STC   R9,STOWTTR+3(R4)                                         00047000
         LA    R4,4(R4)                                                 00047100
         SH    R6,=H'256'                                               00047200
         B     NEXTPAGE       AND REPEAT                                00047300
LASTONE  BAL   R8,WRITESET    WRITE LAST TTR PAGE                       00047400
         ST    R1,STOWTTR(R4) STORE TTRN                                00047500
         STC   R6,STOWTTR+3(R4)                                         00047600
         LA    R4,4(R4)                                                 00047700
         LA    R8,7           NUM OF HALFWORDS OF USER DATA             00047800
         SLL   R4,3                                                     00047900
         OR    R4,R8                                                    00048000
         STC   R4,PAGEZERO+3  STORE C BYTE                              00048100
         L     R3,=V(OUTPUT5)                                           00048200
         STOW  (R3),STOWINFO,R                                          00048300
         B     RETCODE(R15)                                             00048400
RETCODE  B     RETURN1                                                  00048500
         B     STOWOK                                                   00048600
         B     STOWOK                                                   00048700
         B     8(R11)         DIRABEND                                  00048800
         B     12(R11)        OPDSYNAD                                  00048900
STOWOK   SR    R15,R15                                                  00049000
         B     SETRCODE                                                 00049100
RETURN1  LA    R15,1                                                    00049200
SETRCODE ST    R15,TEMP                                                 00049300
         CLOSE (OUTPUT5)                                                00049400
         L     R15,TEMP                                                 00049500
         B     24(R11)        RETURN SETTING R0                         00049600
         SPACE 3                                                        00049700
*                                                                       00049800
*        STOW AREA                                                      00049900
*                                                                       00050000
STOWINFO DS    0D                                                       00050100
STOWNAME DC    CL8' '                                                   00050200
PAGEZERO DC    F'0'                                                     00050300
STOWTTR  DC    3F'0'                                                    00050400
LASTPAGE DC    H'0'                                                     00050500
*                                                                       00050600
*        MISCELLANEOUS DATA                                             00050700
*                                                                       00050800
         DS    0F                                                       00050900
TEMP     DC    F'0'                                                     00051000
ATTRBUF  DC    A(0)                                                     00051100
AREADBUF DC    A(0)                                                     00051200
OPENFLAG DC    X'00'                                                    00051300
UPDATFLG DC    X'00'                                                    00051400
*                                                                       00051500
*        BLDL AREA                                                      00051600
*                                                                       00051700
         DS    0F                                                       00051800
BLDLAREA EQU   *                                                        00051900
FF       DC    H'1'                                                     00052000
LL       DC    H'28'                                                    00052100
NAME     DS    CL8                                                      00052200
TTR      DS    CL3                                                      00052300
K        DS    CL1                                                      00052400
Z        DS    CL1                                                      00052500
C        DS    CL1                                                      00052600
TTRN1    DS    2H                                                       00052700
TTRN2    DS    2H                                                       00052800
TTRN3    DS    2H                                                       00052900
PGELAST  DS    H                                                        00053000
*                                                                       00053100
*        DECB FOR UPDAT MODE                                            00053200
*                                                                       00053300
         READ  UPDECB,SF,OUTPUT5,0,1680,MF=L                            00053400
BUFLOC   EQU   UPDECB+12                                                00053500
         PRINT NOGEN                                                    00053600
         EJECT                                                          00053700
         DCBD  DSORG=(PS,PO),DEVD=DA                                    00054000
         END                                                            00060000
