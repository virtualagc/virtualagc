*                                                                       00010007
* REGRESS:  VERS 1.0    CRAIG W. SCHULENBERG     10/30/92               00020039
*                                                                       00030007
REGRESS  CSECT                                                          00040008
         OSSAVE                                                         00050000
*                                                                       00060008
* THIS PROGRAM IS DESIGNED TO RUN IN TEST MODE AND COMPARE ONE VERSION  00070008
* OF SDFPKG WITH ANOTHER.  IT IS ASSUMED THAT THE USER WILL SET A       00080008
* BREAKPOINT AT THE BEGINNING OF THE PROGRAM AND LOAD BOTH COPIES OF    00090008
* SDFPKG INTO MEMORY.  THE VARIABLES ASDFPKG1 AND ASDFPKG2 MUST BE      00100008
* SET BY THE USER TO THE ADDRESSES OF THE OLD AND NEW SDFPKG VERSIONS,  00110008
* RESPECTIVELY.  ALS0, THE FILES SDF1 AND HALSDF MUST POINT TO THE      00120008
* SAME SDF PDS.  IN ADDITION, THE SYSPRINT FILE MUST BE ALLOCATED.      00130008
*                                                                       00140008
         B     SKIPCON                                                  00150008
         DS    0F                                                       00160008
ASDFPKG1 DC    A(0)             ADDRESS OF PREVIOUS SDFPKG VERSION      00170008
ASDFPKG2 DC    A(0)             ADDRESS OF NEW SDFPKG VERSION           00180008
SKIPCON  EQU   *                                                        00190008
         MVI   MISC+1,X'08'      SET ONE FCB MODE (TO SAVE MEMORY)      00200008
         MVC   XOMMSAVE(COMMLEN),COMMAREA                               00210027
         LA    R0,COMMAREA                                              00220005
         SR    R1,R1                                                    00230005
         L     R15,ASDFPKG1      GET THE ADDRESS OF THE OLD SDFPKG      00240008
         BALR  R14,R15           CALL IT (INITIALIZATION CALL)          00250008
         L     R1,ADDR                                                  00260011
         ST    R1,DBUFAD1        SAVE ADDRESS OF ITS DATABUF AREA       00270011
         BAL   R7,STOW1                                                 00280017
         MVC   COMMAREA(COMMLEN),XOMMSAVE                               00290027
         LA    R0,COMMAREA                                              00300008
         SR    R1,R1                                                    00310008
         L     R15,ASDFPKG2      GET THE ADDRESS OF THE NEW SDFPKG      00320008
         BALR  R14,R15           CALL IT (INITIALIZATION CALL)          00330008
         L     R1,ADDR                                                  00340011
         ST    R1,DBUFAD2        SAVE ADDRESS OF ITS DATABUF AREA       00350011
         BAL   R7,STOW2                                                 00360017
         BAL   R7,COMPCOMM                                              00370021
         BAL   R7,DATACOMM                                              00380021
*                                                                       00390008
* NOW OPEN THE SDF PDS FOR SEQUENTIAL READ (OF THE DIRECTORY) AND       00400008
* OBTAIN EACH SDF MEMBER NAME.  FOR EACH MEMBER NAME, WE WILL INVOKE    00410008
* BOTH VERSIONS OF SDFPKG TO PERFORM A "SELECT"                         00420008
*                                                                       00430008
         OPEN  (DCB1,(INPUT))                                           00440000
         LA    R12,DCB1                                                 00450000
         USING IHADCB,R12                                               00460000
         TM    DCBOFLGS,X'10'                                           00470000
         BO    OPENOK1                                                  00480000
         MVI   RETCODE+3,1                                              00490000
         B     DONE                                                     00500000
OPENOK1  OPEN  (DCB2,(OUTPUT))                                          00510008
         LA    R12,DCB2                                                 00520008
         TM    DCBOFLGS,X'10'                                           00530000
         BO    LOOP1                                                    00540000
         MVI   RETCODE+3,3                                              00550000
         B     DONE                                                     00560000
         DROP  R12                                                      00570000
LOOP1    L     R2,=A(BUF1)                                              00580000
         READ  DECB1,SF,DCB1,BUF1,'S'                                   00590000
         CHECK DECB1                                                    00600000
         LH    R3,0(R2)                                                 00610000
         AR    R3,R2                                                    00620000
         LA    R2,2(R2)                                                 00630000
LOOP2    CR    R2,R3                                                    00640000
         BNL   LOOP1                                                    00650000
         MVC   SDFNAM(8),0(R2)      MOVE THE SDF NAME INTO COMM AREA    00660008
         CLC   SDFNAM(8),=X'FFFFFFFFFFFFFFFF'                           00670009
         BE    DONE                 WE HAVE REACHED THE END OF THE PDS  00680009
         MVC   NAME(8),0(R2)        BUILD THE MESSAGE LINE              00690009
         MVC   MSG2(14),GOOD        ASSUME COMPARISON WILL BE GOOD      00700009
*                                                                       00710005
* SELECT THE SDF IN QUESTION                                            00720005
*                                                                       00730005
         MVC   XOMMSAVE(COMMLEN),COMMAREA                               00740027
         LA    R1,4                                                     00750025
         L     R15,ASDFPKG1                                             00760009
         BALR  R14,R15              CALL THE OLD SDFPKG                 00770009
         L     R10,DBUFAD1                                              00780028
         USING DATABUF,R10                                              00790028
         L     R1,CURFCB            GET THE CURRENT FCB ADDRESS         00800028
         ST    R1,FCBAD1                                                00810028
         DROP  R10                                                      00820028
         BAL   R7,STOW1                                                 00830017
         MVC   COMMAREA(COMMLEN),XOMMSAVE                               00840027
         LA    R1,4                                                     00850009
         L     R15,ASDFPKG2                                             00860009
         BALR  R14,R15              CALL THE NEW SDFPKG                 00870009
         L     R10,DBUFAD2                                              00880028
         USING DATABUF,R10                                              00890028
         L     R1,CURFCB            GET THE CURRENT FCB ADDRESS         00900028
         ST    R1,FCBAD2                                                00910028
         DROP  R10                                                      00920028
         BAL   R7,STOW2                                                 00930017
         BAL   R7,COMPCOMM                                              00940021
         MVI   FAULT,0                                                  00950032
         BAL   R7,DATACOMM                                              00960021
         BAL   R7,FCBCOMM           COMPARE THE FCBS                    00970028
         CLI   FAULT,0                                                  00980032
         BNE   SKIPLOCS                                                 00990032
*                                                                       01000032
* LOCATE ALL PAGES OF THIS SDF                                          01010032
*                                                                       01020032
         LH    R8,PAGECNT                                               01030033
         SR    R4,R4                                                    01040033
LOCLOOP  EQU   *                                                        01050033
         LR    R1,R4                                                    01051038
         SLL   R1,16           FORM A POINTER VALUE                     01060038
         ST    R1,PNTR                                                  01070038
         MVC   XOMMSAVE(COMMLEN),COMMAREA                               01080033
         LA    R1,5            DO A LOCATE                              01090033
         L     R15,ASDFPKG1                                             01100033
         BALR  R14,R15                                                  01110033
         LR    R5,R1                                                    01120036
         MVC   COMMAREA(COMMLEN),XOMMSAVE                               01130033
         LA    R1,5                                                     01140033
         L     R15,ASDFPKG2                                             01150033
         BALR  R14,R15                                                  01160033
         LA    R6,8                                                     01170034
INNERLUP CLC   0(210,R1),0(R5)  COMPARE THE TWO SDF PAGES               01180036
         BNE   ABENDE                                                   01190033
         LA    R1,210(R1)                                               01200034
         LA    R5,210(R5)                                               01210036
         BCT   R6,INNERLUP                                              01220034
         LA    R4,1(R4)                                                 01230033
         BCT   R8,LOCLOOP                                               01240033
         B     SKIPLOCS                                                 01250033
ABENDE   MVC   MSG2(14),BAD5                                            01260033
SKIPLOCS EQU   *                                                        01270032
*                                                                       01280008
* WRITE OUT A MESSAGE SHOWING THE RESULTS OF THE SDFPKG COMPARISON      01290008
*                                                                       01300008
         PUT   DCB2,MESSAGE                                             01330008
         SR    R1,R1                                                    01350026
         IC    R1,11(R2)                                                01360026
         N     R1,=X'0000001F'                                          01370026
         AR    R1,R1                                                    01380026
         LA    R1,12(R1)                                                01390026
         AR    R2,R1                                                    01400026
         B     LOOP2                                                    01410026
DONE     CLOSE (DCB1)                                                   01420000
         CLOSE (DCB2)                                                   01430008
         OSRETURN                                                       01440000
SYNAD1   LA    R1,4001                                                  01450000
         B     DOABEND                                                  01460000
SYNAD3   LA    R1,4003                                                  01470000
DOABEND  ABEND (R1),DUMP                                                01480000
*                                                                       01490017
* SERVICE SUBROUTINES (STOW AND COMPARE BUFFER AREAS)                   01500017
*                                                                       01510017
STOW1    EQU   *                                                        01520017
         L     R10,DBUFAD1                                              01530017
         MVC   DATABUF1(DATALEN),0(R10)                                 01540022
         LA    R10,DATABUF1                                             01550023
         LA    R11,COMM1                                                01560020
         B     STOWCOMM                                                 01570017
STOW2    L     R10,DBUFAD2                                              01580017
         MVC   DATABUF2(DATALEN),0(R10)                                 01590022
         LA    R10,DATABUF2                                             01600023
         LA    R11,COMM2                                                01610020
STOWCOMM EQU   *                                                        01620017
         MVC   COMMSAVE(COMMLEN),COMMAREA                               01630018
         USING DATABUF,R10                                              01640018
*                                                                       01650017
* BLANK OUT PORTIONS OF THE DATABUF AREA THAT WE CANNOT COMPARE         01660017
*                                                                       01670017
         SR    R0,R0                                                    01680017
         ST    R0,AVULN                                                 01690017
         ST    R0,CURFCB                                                01700017
         ST    R0,PADADDR                                               01710017
         ST    R0,ACURNTRY                                              01720017
         ST    R0,ROOT                                                  01730017
         ST    R0,READS                                                 01740017
         ST    R0,GETMSTK1                                              01750017
         ST    R0,GETMSTK2                                              01760017
         ST    R0,FCBSTK1                                               01770017
         ST    R0,FCBSTK2                                               01780017
         ST    R0,APGEBUFF                                              01790017
         ST    R0,ADECB                                                 01800017
         ST    R0,ECB                                                   01810022
         ST    R0,DCBADDR                                               01820017
         ST    R0,BUFLOC                                                01830017
         ST    R0,IOBADDR                                               01840017
         MVC   FIRST+1(2),=X'0000'  SPARE LOCATION                      01850022
         DROP  R10                                                      01860017
*                                                                       01870017
* BLANK OUT PORTIONS OF THE COMMUNICATION AREA THAT WE CANNOT COMPARE   01880017
*                                                                       01890017
         ST    R0,APGAREA                                               01900017
         ST    R0,AFCBBLKS                                              01910017
         ST    R0,ADDR                                                  01920017
         MVC   0(COMMLEN,R11),COMMAREA                                  01930018
         MVC   COMMAREA(COMMLEN),COMMSAVE                               01940018
         BR    R7                                                       01950017
*                                                                       01960017
COMPCOMM EQU   *                                                        01970017
         CLC   COMM1(COMMLEN),COMM2                                     01980019
         BNE   ABENDA                                                   01990017
         BR    R7                                                       02000017
ABENDA   MVC   MSG2(14),BAD2                                            02010021
         MVI   FAULT,1                                                  02020032
         BR    R7                                                       02030021
DATACOMM EQU   *                                                        02040017
         CLC   DATABUF1(DATALEN),DATABUF2                               02050018
         BNE   ABENDB                                                   02060017
         BR    R7                                                       02070017
ABENDB   MVC   MSG2(14),BAD1                                            02080021
         MVI   FAULT,2                                                  02090032
         BR    R7                                                       02100021
FCBCOMM  EQU   *                                                        02110028
         L     R10,FCBAD1                                               02120028
         L     R11,FCBAD2                                               02130028
         CLC   0(FCBLEN,R10),0(R11)                                     02140028
         BNE   ABENDC                                                   02150028
         USING FCBCELL,R10                                              02160028
         LH    R8,LSTPAGE                                               02170031
         LA    R8,1(R8)         GET THE TOTAL NUMBER OF PAGES           02180028
         STH   R8,PAGECNT                                               02190032
         SR    R4,R4                                                    02200028
FCBLOOP  L     R5,FCBTTRZ(R4)                                           02210028
         L     R10,FCBAD2                                               02220028
         L     R6,FCBTTRZ(R4)                                           02230030
         CR    R5,R6            COMPARE THE TWO TTRS                    02240030
         BNE   ABENDD                                                   02250028
         L     R10,FCBAD1                                               02260028
         LA    R4,8(R4)                                                 02270028
         BCT   R8,FCBLOOP                                               02280028
         BR    R7                                                       02290028
ABENDC   MVC   MSG2(14),BAD3                                            02300029
         MVI   FAULT,3                                                  02310032
         BR    R7                                                       02320028
ABENDD   MVC   MSG2(14),BAD4                                            02330029
         MVI   FAULT,4                                                  02340032
         BR    R7                                                       02350028
*                                                                       02360000
*        DATA AREA                                                      02370000
*                                                                       02380000
         DS    0F                                                       02390000
TTRWORD  DC    F'0'                                                     02400000
MESSAGE  DC    CL4'SDF '                                                02410000
NAME     DC    CL8' '                                                   02420000
MSG1     DC    CL4' :: '                                                02430028
MSG2     DC    CL24' '                                                  02440000
*                                                                       02450000
GOOD     DC    CL14'OK  (COMPARE) '                                     02460008
BAD1     DC    CL14'BAD1--DATABUF '                                     02470021
BAD2     DC    CL14'BAD2--COMMAREA'                                     02480021
BAD3     DC    CL14'BAD3--FCB HDR '                                     02490028
BAD4     DC    CL14'BAD4--FCB TTR '                                     02500028
BAD5     DC    CL14'BAD5--SDF PAGE'                                     02510033
FAULT    DC    CL1' '                                                   02520034
*                                                                       02530000
*        LITERAL AREA                                                   02540000
*                                                                       02550000
         LTORG                                                          02560000
*                                                                       02570000
*        DCBS                                                           02580000
*                                                                       02590000
DCB1     DCB   DSORG=PS,DDNAME=SDF1,DEVD=DA,MACRF=R,SYNAD=SYNAD1,      X02600000
               EODAD=DONE,RECFM=U                                       02610000
DCB2     DCB   DSORG=PS,DDNAME=SYSPRINT,DEVD=DA,MACRF=PM,SYNAD=SYNAD3, X02620008
               RECFM=F,LRECL=40,BLKSIZE=40                              02630000
*                                                                       02640005
         DS    0F                                                       02650005
COMMAREA EQU   *                                                        02660005
APGAREA  DC    A(0)                                                     02670005
AFCBBLKS DC    A(0)                                                     02680005
NPAGES   DC    H'0'                                                     02690005
NBYTES   DC    H'0'                                                     02700000
MISC     DC    H'0'                                                     02710005
CRETURN  DC    H'0'                                                     02720005
BLKNO    DC    H'0'                                                     02730005
SYMBNO   DC    H'0'                                                     02740005
STMTNO   DC    H'0'                                                     02750005
BLKNLEN  DC    X'00'                                                    02760005
SYMBNLEN DC    X'00'                                                    02770005
PNTR     DC    F'0'                                                     02780005
ADDR     DC    A(0)                                                     02790005
SDFNAM   DC    CL8' '                                                   02800008
CSECTNAM DC    CL8' '                                                   02810005
SREFNO   DC    CL6' '                                                   02820005
INCLCNT  DC    H'0'                                                     02830005
BLKNAM   DC    CL32' '                                                  02840005
SYMBNAM  DC    CL32' '                                                  02850005
COMMLEN  EQU   *-COMMAREA                                               02860016
         DS    0F                                                       02870017
COMMSAVE DS    (COMMLEN)X         SAVE FOR ACTUAL COMMUNICATION AREA    02880017
         DS    0F                                                       02890027
XOMMSAVE DS    (COMMLEN)X         SECOND SAVE AREA                      02900027
         DS    0F                                                       02910010
COMM1    DS    (COMMLEN)X         COMMUNICATION AREA SAVE FOR SDFPKG1   02920010
         DS    0F                                                       02930010
COMM2    DS    (COMMLEN)X         COMMUNICATION AREA SAVE FOR SDFPKG2   02940010
         DATABUF                  BRING IN DATABUF DSECT                02950011
DATALEN  EQU   *-DATABUF                                                02960016
REGRESS  CSECT                                                          02970016
         DS    0F                                                       02980011
DATABUF1 DS    (DATALEN)X         DATABUF AREA SAVE FOR SDFPKG1         02990011
         DS    0F                                                       03000011
DATABUF2 DS    (DATALEN)X         DATABUF AREA SAVE FOR SDFPKG2         03010011
DBUFAD1  DC    A(0)               ADDRESS OF REAL DATABUF 1             03020011
DBUFAD2  DC    A(0)               ADDRESS OF REAL DATABUF 2             03030012
FCBAD1   DC    A(0)               FCB ADDRESS (SDFPKG #1)               03040028
FCBAD2   DC    A(0)               FCB ADDRESS (SDFPKG #2)               03050028
PAGECNT  DC    H'0'               NUMBER OF PAGES IN THE SDF            03060035
*                                                                       03070000
*        BUFFERS                                                        03080000
*                                                                       03090000
         DS    0F                                                       03100000
BUF1     DS    64F                                                      03110000
         FCBCELL                                                        03120028
         PRINT NOGEN                                                    03130008
         DCBD  DSORG=(PO)                                               03140000
         END                                                            03150000
