*                                                                       00010000
* SDFOUT:  VERS 2.0     CRAIG W. SCHULENBERG     11/02/92               00020000
*                         -- ADD LOGIC TO OBTAIN TTRS BY READS AND      00030000
*                              REMOVED USE OF TRAILING TTR PAGES        00040000
*                              CR # 11097 (ELIMINATE USE OF             00050000
*                                NOTELISTS IN HAL COMPILER)             00060000
*                                                                       00070004
*  NOTE 1!!! - THIS VERSION OF SDFOUT ASSUMES THAT PHASE 3 OF THE       00080005
*  HAL COMPILER CONTINUES TO PASS A TTR BUFFER ADDRESS WITH A           00090004
*  MODE 14 CALL:   CALL MONITOR(14,4,TTRBUFAD)                          00100004
*                                                                       00110004
*  IF PHASE 3 CEASES TO DO THIS, THEN THE CORRESPONDING LOGIC           00120004
*  "MUST BE" REMOVED FROM SDFOUT OR WE WILL MISS THE FIRST ACTUAL       00130004
*  WRITE OF SDF DATA!                                                   00140004
*                                                                       00150004
*  NOTE 2 - THE REMOVAL OF THE TTR LOGIC ALSO CIRCUMVENTS AN EXISTING   00160005
*  BUG IN THE PHASE 3 TO SDFOUT INTERFACE; NAMELY, PHASE 3 ONLY         00170005
*  GUARANTEES A SINGLE 1680 BYTE PAGE FOR THE RECORDING OF TTRS.        00180005
*  SDFOUT WILL EXCEED THIS LIMIT OF 410 TTRS AND WRITE INTO UNKNOWN     00190005
*  STUFF IN THE FREE STRING AREA.                                       00200005
*                                                                       00210005
SDFOUT   CSECT                                                          00220000
         EXTRN OUTPUT5                                                  00230000
R0       EQU   0                                                        00240000
R1       EQU   1                                                        00250000
R2       EQU   2                                                        00260000
R3       EQU   3                                                        00270000
R4       EQU   4                                                        00280000
R5       EQU   5                                                        00290000
R6       EQU   6                                                        00300000
R7       EQU   7                                                        00310000
R8       EQU   8                                                        00320000
R9       EQU   9                                                        00330000
R10      EQU   10                                                       00340000
R11      EQU   11                                                       00350000
R12      EQU   12                                                       00360000
R13      EQU   13                                                       00370000
R14      EQU   14                                                       00380000
R15      EQU   15                                                       00390000
         USING *,R10                                                    00400004
         B     SDFTYPE(R1)                                              00410000
SDFTYPE  B     OPENSDF        MONITOR(14,0,LAST_PAGE)                   00420004
         B     WRITESDF       MONITOR(14,4,BUFFER_ADDR)                 00430004
         B     CLOSESDF       MONITOR(14,8,SDFNAME)                     00440004
         SPACE 2                                                        00450000
OPENSDF  MVI   OPENFLAG,1     INDICATE THAT OPEN HAS BEEN DONE          00460000
         OPEN  (OUTPUT5,(UPDAT)) INITIALLY OPEN IN UPDAT MODE           00470004
         L     R5,=V(OUTPUT5) GET DCB ADDRESS                           00480004
         USING IHADCB,R5                                                00490000
         TM    DCBOFLGS,X'10' SUCCESSFUL OPEN?                          00500002
         BZ    16(R11)        NO -- RETURN TO BADOPEN EXIT LOC          00510002
         STH   R2,LASTPAGE    SAVE THE USER DATA (# OF LAST SDF PAGE)   00520004
         BLDL  (R5),BLDLAREA  SEE IF THE MEMBER ALREADY EXISTS          00530002
         LTR   R15,R15                                                  00540000
         BNZ   NOUPDAT         IF NOT, OPEN FOR OUTPUT ONLY             00550002
         CLC   LASTPAGE(2),PGELAST  MEMBER ALREADY EXISTS; CHECK SIZES  00560002
         BNE   NOUPDAT         IF SIZES DIFFER, OPEN FOR OUTPUT ONLY    00570002
         MVI   UPDATFLG,1      SAME SIZE SDF -- USE UPDAT MODE          00580002
         FIND  (R5),TTR,C      POSITION TO THE FIRST PAGE OF MEMBER     00590002
         BR    R11             RETURN TO CALLER                         00600002
NOUPDAT  CLOSE (OUTPUT5)       CLOSE OUTPUT DCB FOR UPDAT MODE          00610002
         OPEN  (OUTPUT5,(OUTPUT))  REOPEN FOR WRITES ONLY               00620002
         BR    R11             RETURN TO CALLER                         00630002
         DROP  R5                                                       00640002
         SPACE 2                                                        00650000
*                                                                       00660004
* NOTE:  WRITESDF GETS 3 TYPES OF CALLS                                 00670004
*                                                                       00680004
*   TYPE 1 (AREADBUF = 0, ATTRBUF = 0)                                  00690004
*     THIS IS THE FIRST CALL AND IS USED TO SET THE ADDRESS OF          00700004
*     READBUF, A GENERAL PURPOSE 1680 BYTE BUFFER LOCATION              00710004
*     PROVIDED BY PHASE 3 IN THE EVENT THAT THE SDF IS BEING            00720004
*     PROCESSED IN UPDAT MODE                                           00730004
*                                                                       00740004
*   TYPE 2 (AREADBUF > 0, ATTRBUF = 0)                                  00750004
*     THIS IS THE SECOND CALL.  IT NO LONGER HAS A PURPOSE AND          00760004
*     CAN BE DELETED (BUT ONLY IF IT IS REMOVED FROM BOTH SDFOUT        00770004
*     AND PHASE 3 !!!).  ITS ORIGINAL PURPOSE WAS FOR PHASE 3           00780004
*     TO PASS THE ADDRESS OF A 1680 BYTE BUFFER WHICH COULD             00790004
*     BE USED TO RECORD UP TO 410 TTRS)                                 00800004
*                                                                       00810004
*   TYPE 3 (AREADBUF > 0, ATTRBUF > 0)                                  00820004
*     THIS IS THE NORMAL WRITE CALL.  THE BUFFER ADDRESS PROVIDED       00830004
*     POINTS TO A 1680 BYTE SDF PAGE.                                   00840004
*                                                                       00850004
WRITESDF LR    R7,R2           GET THE ADDRESS PASSED FROM PHASE 3      00860004
         L     R15,AREADBUF    SEE IF WE HAVE A BUFFER ADDRESS          00870004
         LTR   R15,R15                                                  00880000
         BNZ   CHECKTTR        YES --SEE IF USER IS GIVING TTR BUFF     00890004
         ST    R7,AREADBUF     NO -- STORE BUFFER ADDRESS               00900004
         BR    R11             EXIT (NEXT CALL WILL BE TTR ADDRESS)     00910004
CHECKTTR L     R15,ATTRBUF     SEE IF WE HAVE A TTR ADDRESS             00920004
         LTR   R15,R15                                                  00930000
         BNZ   CHECKUPD        YES -- THIS MUST BE A REAL WRITE         00940004
         ST    R7,ATTRBUF      NO -- STORE TTR ADDRESS (UNUSED)         00950004
         BR    R11             EXIT (NEXT CALL WILL BE A WRITE)         00960004
CHECKUPD CLI   UPDATFLG,0      ARE WE IN UPDAT MODE?                    00970004
         BE    NORMAL          NO -- GO TO NORMAL                       00980004
         MVC   BUFLOC,AREADBUF UPDAT MODE                               00990004
         READ  UPDECB,SF,MF=E  READ THE OLD PAGE                        01000005
         CHECK UPDECB          WAIT FOR I/O TO COMPLETE                 01010005
         ST    R7,BUFLOC       POINT THE DECB AT THE NEW PAGE           01020005
         WRITE UPDECB,SF,MF=E  WRITE OUT THE NEW PAGE                   01030005
         CHECK UPDECB          WAIT FOR I/O COMPLETION                  01040005
         BR    R11                                                      01050000
NORMAL   WRITE SDFDECB,SF,OUTPUT5,(R7),1680                             01060005
         CHECK SDFDECB        WAIT FOR I/O COMPLETION                   01070005
         BR    R11                                                      01080000
         SPACE 3                                                        01090000
MOVE     MVC   STOWNAME(0),0(R2)                                        01100000
MOVE1    MVC   NAME(0),0(R2)                                            01110000
         SPACE 1                                                        01120000
CLOSESDF LR    R3,R2          R2 IS XPL STRING DESCRIPTOR OF SDF NAME   01130003
         SRL   R3,24          OBTAIN THE LENGTH OF THE STRING (-1)      01140003
         CLI   OPENFLAG,0     IS THE SDF IN FACT OPENED?                01150003
         BNE   REALCLOS       IS YES, GO CLOSE IT AND DO THE STOW       01160003
         EX    R3,MOVE1       IF NOT, MOVE THE PROSPECTIVE SDF MEMBER   01170003
         BR    R11               NAME INTO 'NAME' AND EXIT              01180003
REALCLOS MVI   OPENFLAG,0     SHOW THAT THE SDF IS NO LONGER OPEN       01190003
         CLI   UPDATFLG,1     ARE WE IN UPDAT MODE?                     01200003
         BE    RETURN1        IF YES, WE ARE DONE                       01210003
         EX    R3,MOVE        NO --MOVE THE MEMBER NAME INTO STOW AREA  01220003
         LA    R4,7           NUM OF HALFWORDS OF USER DATA             01230003
         STC   R4,PAGEZERO+3  STORE C BYTE (NO TTRS)                    01240003
         L     R3,=V(OUTPUT5) GET DCB ADDRESS                           01250003
         STOW  (R3),STOWINFO,R  STOW THE MEMBER NAME (R=REPLACE!)       01260004
         B     RETCODE(R15)   FAN OUT BASED ON STOW RETURN CODE         01270004
RETCODE  B     RETURN1        SDF MEMBER IS REPLACED                    01280004
         B     STOWOK         (... FOR SAFETY ...)                      01290004
         B     STOWOK         SDF MEMBER IS NEW (CREATED)               01300004
         B     8(R11)         DIRABEND (DIRECTORY IS FULL)              01310003
         B     12(R11)        OPDSYNAD (I/O ERROR)                      01320003
STOWOK   SR    R15,R15        RETURN A 0 TO INDICATE SDF CREATED        01330004
         B     SETRCODE                                                 01340000
RETURN1  LA    R15,1          RETURN A 1 TO INDICATE SDF REPLACED       01350004
SETRCODE ST    R15,TEMP       SAVE THE RETURN CODE AROUND THE CLOSE     01360003
         CLOSE (OUTPUT5)      CLOSE OUR DCB                             01370003
         L     R15,TEMP       LOAD RETURN CODE                          01380003
         B     24(R11)        RETURN SETTING R0                         01390000
         SPACE 3                                                        01400000
*                                                                       01410000
*        STOW AREA                                                      01420000
*                                                                       01430000
STOWINFO DS    0D                                                       01440000
STOWNAME DC    CL8' '         NAME OF SDF MEMBER BEING CREATED/UPDATED  01450003
PAGEZERO DC    F'0'           TTR OF PAGE 0 OF THE SDF (PLUS 'C' BYTE)  01460003
STOWTTR  DC    3F'0'          THESE LOCATIONS WILL STAY '0' (NO TTRS)   01470003
LASTPAGE DC    H'0'           NUMBER OF LAST SDF PAGE                   01480003
*                                                                       01490000
*        MISCELLANEOUS DATA                                             01500000
*                                                                       01510000
         DS    0F                                                       01520000
TEMP     DC    F'0'           SAVE LOC FOR RETURN CODE AROUND CLOSE     01530003
AREADBUF DC    A(0)           SCRATCH BUFFER LOCATION (PROVIDED BY      01540004
*                               PHASE 3 IN CASE WE ARE IN UPDAT MODE)   01550006
ATTRBUF  DC    A(0)           (UNUSED EXCEPT TO RECOGNIZE TTR BUFFER    01560004
*                               CALL FROM PHASE 3)                      01570004
OPENFLAG DC    X'00'          1 --> SDF IS OPEN                         01580004
UPDATFLG DC    X'00'          1 --> UPDAT MODE (SDF ALREADY EXISTS ...  01590004
*                                    ... AND HAS THE SAME # OF PAGES    01600004
*                                                                       01610000
*        BLDL AREA                                                      01620000
*                                                                       01630000
         DS    0F                                                       01640000
BLDLAREA EQU   *                                                        01650000
FF       DC    H'1'                                                     01660000
LL       DC    H'28'                                                    01670000
NAME     DS    CL8                                                      01680000
TTR      DS    CL3                                                      01690000
K        DS    CL1                                                      01700000
Z        DS    CL1                                                      01710000
C        DS    CL1           SHOW 7 HALFWORDS OF USER DATA              01720003
TTRN1    DS    2H            NO LONGER USED (0)  <PMF WILL USE THE      01730003
*                               UPPER HALFWORD FOR REVISION LVL>        01740003
TTRN2    DS    2H            NO LONGER USED (0)                         01750003
TTRN3    DS    2H            NO LONGER USED (0)                         01760003
PGELAST  DS    H             NUMBER OF LAST PAGE IN SDF                 01770003
*                                                                       01780000
*        DECB FOR UPDAT MODE                                            01790000
*                                                                       01800000
         READ  UPDECB,SF,OUTPUT5,0,1680,MF=L                            01810000
BUFLOC   EQU   UPDECB+12                                                01820000
         PRINT NOGEN                                                    01830000
         EJECT                                                          01840000
         DCBD  DSORG=(PS,PO),DEVD=DA                                    01850000
         END                                                            01860000
