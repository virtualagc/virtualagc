*                                                                       00010000
* PAGMOD:  VERS 2.0     CRAIG W. SCHULENBERG     10/30/92               00020001
*                         -- BASELINED THIS VERSION.  NO CHANGES        00030000
*                              HAVE OCCURRED SINCE THE 1977 REFERENCE   00040000
*                              LISTING.                                 00050000
*                                                                       00060000
         TITLE 'PAGMOD  -  PAGING AREA AND FCB AREA DATA MANAGER'       00070000
         GBLA  &PAG1                                                    00080000
         GBLA  &PAG2                                                    00090000
         GBLA  &FCBPRIM                                                 00100000
&PAG1    SETA  2                                                        00110000
&PAG2    SETA  250                                                      00120000
&FCBPRIM SETA  1024           SIZE OF FCB PRIMARY ALLOCATION            00130000
PAGMOD   CSECT                                                          00140000
*                                                                       00150000
*     UPON ENTRY, REGISTER 1 CONTAINS A SERVICE CODE.                   00160000
*                                                                       00170000
         USING *,15                                                     00180000
         B     *+12                                                     00190000
         DC    CL8'PAGMOD  '                                            00200000
         BALR  15,0                                                     00210000
         DROP  15                                                       00220000
         OSSAVE                                                         00230000
         USING COMMTABL,R10                                             00240000
         USING DATABUF,R11                                              00250000
         B     SERVICES(R1)                                             00260000
SERVICES B     INIT           INITIALIZE                                00270000
         B     TERM           TERMINATE                                 00280000
         B     AUGMENT        AUGMENT PAGING AREA OR FCB AREA           00290000
         B     RESCIND        RESCIND AUGMENTED PAGING AREA             00300000
*                                                                       00310000
INIT     EQU   *                                                        00320000
         TM    MISC+1,X'04'   ALTERNATE DDNAME SPECIFIED?               00330000
         BNO   NOALTDD                                                  00340000
         LA    R1,PDSFILE     POINT AT THE DCB                          00350000
         USING IHADCB,R1                                                00360000
         MVC   DCBDDNAM(8),SDFDDNAM                                     00370000
         DROP  R1                                                       00380000
NOALTDD  TM    MISC+1,X'02'   IS UPDAT MODE SPECIFIED?                  00390000
         BO    UPDATM                                                   00400000
         OPEN  (PDSFILE,(INPUT))                                        00410000
         B     CHKOPEN                                                  00420000
UPDATM   OPEN  (PDSFILE,(UPDAT))                                        00430000
         MVI   MODFLAG,1      INDICATE UPDAT MODE ACTIVE                00440000
CHKOPEN  LA    R12,PDSFILE                                              00450000
         USING IHADCB,R12                                               00460000
         TM    DCBOFLGS,X'10'                                           00470000
         DROP  R12                                                      00480000
         BO    OPENOK                                                   00490000
         MVI   RETCODE+3,4                                              00500000
         B     EXIT                                                     00510000
*                                                                       00520000
*        ALLOCATE AND INITIALIZE PAGING AREA                            00530000
*                                                                       00540000
OPENOK   TM    MISC+1,X'20'   TEST FOR ALTERNATE PAD                    00550000
         BNO   OPENOK1                                                  00560000
         LH    R0,LPAD        NUMBER OF 16-BYTE PAD SLOTS               00570000
         SLL   R0,4           CONVERT TO BYTES                          00580000
         L     R1,APAD        GET ADDRESS OF ORIGINAL PAD               00590000
         L     R6,FCBSTK1     ADDRESS OF ADDRESS STACK                  00600000
         L     R7,FCBSTK2     ADDRESS OF LENGTH STACK                   00610000
         ST    R1,0(R6)                                                 00620000
         ST    R0,0(R7)                                                 00630000
         LA    R5,1                                                     00640000
         STH   R5,FCBSTKLN                                              00650000
         L     R1,ADDR        GET ADDRESS OF USER-SUPPLIED PAD          00660000
         ST    R1,APAD                                                  00670000
         L     R1,PNTR        GET # OF BYTES IN USER-SUPPLIED PAD       00680000
         SRL   R1,4           CONVERT TO A 16-BYTE COUNT                00690000
         STH   R1,LPAD                                                  00700000
         SR    R0,R0                                                    00710000
         ST    R0,ADDR                                                  00720000
         ST    R0,PNTR                                                  00730000
OPENOK1  LH    R0,NPAGES                                                00740000
         LH    R8,LPAD                                                  00750000
         CR    R0,R8                                                    00760000
         BH    ABEND2         NPAGES MUST BE <= &PAG2                   00770000
         LTR   R0,R0                                                    00780000
         BM    ABEND2         NPAGES MUST BE >= 0                       00790000
         BNZ   USEHIS1                                                  00800000
         L     R1,APGAREA                                               00810000
         LTR   R1,R1                                                    00820000
         BNZ   ABEND2                                                   00830000
         LA    R0,&PAG1       ALLOCATE A MINIMAL AMOUNT                 00840000
USEHIS1  STH   R0,BASNPGS     SAVE BASE NUMBER OF PAGES                 00850000
         L     R1,APGAREA                                               00860000
         ST    R1,AREATEMP    PAGING AREA ADDRESS (IF SUPPLED)          00870000
         LTR   R1,R1                                                    00880000
         BM    ABEND2                                                   00890000
         BNZ   EXTRNPGS                                                 00900000
         L     R2,GETMSTK1    ADDRESS OF GETMAIN ADDRESS STACK          00910000
         L     R3,GETMSTK2    ADDRESS OF GETMAIN LENGTH STACK           00920000
         MH    R0,=H'1680'    CONVERT # OF PAGES TO BYTES               00930000
         ST    R0,BYTETEMP                                              00940000
         GETMAIN R,LV=(0)                                               00950000
         LTR   R15,R15                                                  00960000
         BNZ   ABEND4                                                   00970000
         ST    R1,AREATEMP    SAVE ADDRESS OF GETMAIN'D AREA            00980000
         ST    R1,0(R2)       INSERT INTO GETMAIN ADDRESS STACK         00990000
         L     R0,BYTETEMP                                              01000000
         ST    R0,0(R3)       INSERT INTO GETMAIN LENGTH STACK          01010000
         LA    R0,1                                                     01020000
         STH   R0,NUMGETM     INDICATE ONE GETMAIN TO DATE              01030000
EXTRNPGS LH    R0,BASNPGS                                               01040000
         STH   R0,NUMOFPGS    SIZE OF CURRENT PAGING AREA               01050000
         LH    R1,LPAD        R1 = MAX PAGES THAT WE CAN HANDLE         01060000
         SR    R1,R0                                                    01070000
         STH   R1,NPAGES      TELL THE USER HOW MUCH IS LEFT            01080000
*                                                                       01090000
*        INITIALIZE THE PAGING AREA DIRECTORY                           01100000
*                                                                       01110000
         USING PDENTRY,R8                                               01120000
         L     R8,APAD        R8 = START OF PAGING AREA DIRECTORY       01130000
         SR    R7,R7                                                    01140000
         LH    R6,BASNPGS                                               01150000
         L     R5,AREATEMP                                              01160000
INITLOOP ST    R5,PAGEADDR(R7)                                          01170000
         LA    R5,1680(R5)                                              01180000
         LA    R7,PDENTLEN(R7)                                          01190000
         BCT   R6,INITLOOP                                              01200000
         DROP  R8                                                       01210000
*                                                                       01220000
*        ALLOCATE AND INITIALIZE THE FCB AREA                           01230000
*                                                                       01240000
         LH    R0,NBYTES                                                01250000
         LTR   R0,R0                                                    01260000
         BM    SHIFT7         IF NEG, SHIFT COMPLEMENT BY 7             01270000
         BNZ   USEHIS2                                                  01280000
         L     R1,AFCBAREA                                              01290000
         LTR   R1,R1                                                    01300000
         BNZ   ABEND3                                                   01310000
         LA    R0,&FCBPRIM    ALLOCATE A SUITABLE AMOUNT                01320000
USEHIS2  ST    R0,BYTETEMP    SAVE # OF BYTES ALLOCATED                 01330000
         L     R1,AFCBAREA                                              01340000
         ST    R1,AREATEMP    FCB AREA ADDRESS (IF SUPPLIED)            01350000
         LTR   R1,R1                                                    01360000
         BM    ABEND3                                                   01370000
         BZ    INTRNFCB                                                 01380000
         TM    MISC+1,X'01'   IS THE AUTO-GETMAIN OPTION SET?           01390000
         BNO   EXTRNFCB                                                 01400000
         MVI   GETMFLAG,1                                               01410000
         B     EXTRNFCB                                                 01420000
INTRNFCB MVI   GETMFLAG,1     INDICATE AUTO GETMAINS ALLOWED (FOR FCBS) 01430000
         L     R2,GETMSTK1    ADDRESS OF GETMAIN ADDRESS STACK          01440000
         L     R3,GETMSTK2    ADDRESS OF GETMAIN LENGTH STACK           01450000
         LH    R4,NUMGETM                                               01460000
         SLL   R4,2                                                     01470000
         GETMAIN R,LV=(0)                                               01480000
         LTR   R15,R15                                                  01490000
         BNZ   ABEND4                                                   01500000
         ST    R1,AREATEMP    SAVE ADDRESS OF GETMAIN'D AREA            01510000
         ST    R1,0(R4,R2)    INSERT INTO GETMAIN ADDRESS STACK         01520000
         L     R0,BYTETEMP                                              01530000
         ST    R0,0(R4,R3)    INSERT INTO GETMAIN LENGTH STACK          01540000
         LH    R4,NUMGETM                                               01550000
         LA    R4,1(R4)       INCREMENT COUNT OF GETMAINS               01560000
         STH   R4,NUMGETM                                               01570000
EXTRNFCB L     R2,FCBSTK1     ADDRESS OF FCB AREA ADDRESS STACK         01580000
         L     R3,FCBSTK2     ADDRESS OF FCB AREA LENGTH STACK          01590000
         LH    R5,FCBSTKLN                                              01600000
         SLL   R5,2                                                     01610000
         L     R0,AREATEMP    GET FCB BASE ADDRESS                      01620000
         ST    R0,0(R5,R2)                                              01630000
         L     R0,BYTETEMP                                              01640000
         ST    R0,0(R5,R3)                                              01650000
         LH    R5,FCBSTKLN                                              01660000
         LA    R5,1(R5)                                                 01670000
         STH   R5,FCBSTKLN                                              01680000
         ST    R10,ACOMMTAB                                             01690000
         ST    R12,DCBADDR                                              01700000
         L     R0,APAD                                                  01710000
         ST    R0,PADADDR                                               01720000
         ST    R0,AVULN                                                 01730000
         ST    R0,ACURNTRY                                              01740000
         MVI   GOFLAG,1       INDICATE INITIALIZATION SUCCESSFUL        01750000
COMEXT   SR    R0,R0                                                    01760000
         ST    R0,APGAREA                                               01770000
         ST    R0,AFCBAREA                                              01780000
         STH   R0,NBYTES                                                01790000
         B     EXIT                                                     01800000
*                                                                       01810000
SHIFT7   LCR   R0,R0          CONVERT TO A POS VALUE                    01820000
         SLL   R0,7           MULTIPLY BY 128                           01830000
         B     USEHIS2                                                  01840000
*                                                                       01850000
TERM     EQU   *                                                        01860000
*                                                                       01870000
*        WRITE OUT ALL MODIFIED PAGES                                   01880000
*                                                                       01890000
         L     R4,ADECB       R4 = ADDRESS OF THE DECB                  01900000
         CLI   IOFLAG,0       IS THERE A WRITE IN PROGRESS?             01910000
         BE    NOCHECK                                                  01920000
         CHECK (R4)           WAIT FOR IT TO COMPLETE                   01930000
         USING PDENTRY,R6                                               01940000
NOCHECK  L     R6,PADADDR                                               01950000
         LH    R5,NUMOFPGS                                              01960000
         USING FCBCELL,R12                                              01970000
TERMLOOP L     R12,FCBADDR                                              01980000
         LTR   R12,R12       IS THIS PAGE IN USE?                       01990000
         BZ    NOWRITE                                                  02000000
         CLI   MODFIND,0      IS IT MODIFIED?                           02010000
         BE    NOWRITE                                                  02020000
         MVC   BUFLOC,APGEBUFF  SET UP DECB FOR READ                    02030000
         LH    R1,PAGENO      R1 = PAGE # * 8                           02040000
         L     R2,FCBTTRZ(R1)                                           02050000
         DROP  R12                                                      02060000
         ST    R2,TTRWORD                                               02070000
         POINT PDSFILE,TTRWORD                                          02080000
         READ  (R4),SF,MF=E                                             02090000
         CHECK (R4)                                                     02100000
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR WRITE                   02110000
         WRITE (R4),SF,MF=E                                             02120000
         CHECK (R4)                                                     02130000
NOWRITE  XC    PAGEADDR(16),PAGEADDR                                    02140000
         LA    R6,PDENTLEN(R6)                                          02150000
         BCT   R5,TERMLOOP                                              02160000
         DROP  R6                                                       02170000
*                                                                       02180000
*        FREE ALL GETMAIN'D AREAS                                       02190000
*                                                                       02200000
         LH    R5,NUMGETM                                               02210000
         LTR   R5,R5          HAVE WE DONE ANY GETMAINS?                02220000
         BZ    SKIPFREE                                                 02230000
         L     R2,GETMSTK1                                              02240000
         L     R3,GETMSTK2                                              02250000
         SR    R4,R4                                                    02260000
FREELOOP L     R0,0(R4,R3)    R0 = LENGTH                               02270000
         L     R1,0(R4,R2)    R1 = ADDRESS                              02280000
         FREEMAIN R,LV=(0),A=(1)                                        02290000
         LA    R4,4(R4)                                                 02300000
         BCT   R5,FREELOOP                                              02310000
*                                                                       02320000
*        RESET ALL OTHER GLOBAL PARAMETERS                              02330000
*                                                                       02340000
SKIPFREE XC    LOCCNT(76),LOCCNT                                        02350000
*                                                                       02360000
*        CLOSE THE HALSDF DCB                                           02370000
*                                                                       02380000
         CLOSE (PDSFILE)                                                02390000
*                                                                       02400000
*        FINISH RESET OF THE PAD                                        02410000
*                                                                       02420000
         LA    R6,PADBASE                                               02430000
         C     R6,APAD                                                  02440000
         BE    DOCLOSE                                                  02450000
         LA    R5,&PAG2                                                 02460000
         STH   R5,LPAD                                                  02470000
         ST    R6,APAD                                                  02480000
         USING PDENTRY,R6                                               02490000
CLSLOOP  XC    PAGEADDR(16),PAGEADDR                                    02500000
         LA    R6,PDENTLEN(R6)                                          02510000
         BCT   R5,CLSLOOP                                               02520000
         DROP  R6                                                       02530000
DOCLOSE  LH    R1,LPAD                                                  02540000
         STH   R1,NPAGES                                                02550000
         B     COMEXT                                                   02560000
*                                                                       02570000
AUGMENT  LH    R0,NPAGES      GET # OF PAGES TO AUGMENT                 02580000
         LTR   R0,R0                                                    02590000
         BM    ABEND2                                                   02600000
         BZ    CHKFCB                                                   02610000
         LH    R8,LPAD        R8 = MAX # OF PAGES ALLOWED               02620000
         LH    R7,NUMOFPGS    R7 = CURRENT # OF PAGES                   02630000
         AR    R7,R0          R7 = PROPOSED # OF PAGES                  02640000
         CR    R7,R8                                                    02650000
         BH    ABEND2         ENSURE THAT WE DONT EXCEED MAX            02660000
         SR    R8,R7                                                    02670000
         STH   R8,NPAGES      NUMBER OF PAGES STILL POSSIBLE            02680000
         LR    R6,R0          R6 = COUNTER                              02690000
         L     R1,APGAREA                                               02700000
         ST    R1,AREATEMP                                              02710000
         LTR   R1,R1                                                    02720000
         BNP   ABEND2                                                   02730000
*                                                                       02740000
*        INITIALIZE THE PAGING AREA DIRECTORY EXTENSION                 02750000
*                                                                       02760000
         USING PDENTRY,R8                                               02770000
         L     R8,APAD                                                  02780000
         LH    R5,NUMOFPGS    R5 = OLD # OF PAGES                       02790000
         STH   R7,NUMOFPGS    UPDATE NUMOFPGS                           02800000
         MH    R5,=AL2(PDENTLEN)                                        02810000
         AR    R8,R5          R8 POINTS TO FIRST UNUSED PDENTRY         02820000
         L     R5,AREATEMP                                              02830000
AUGLOOP  ST    R5,PAGEADDR                                              02840000
         LA    R5,1680(R5)                                              02850000
         LA    R8,PDENTLEN(R8)                                          02860000
         BCT   R6,AUGLOOP                                               02870000
         DROP  R8                                                       02880000
*                                                                       02890000
*        SEE IF FCB AREA IS TO BE AUGMENTED                             02900000
*                                                                       02910000
CHKFCB   LH    R0,NBYTES                                                02920000
         LTR   R0,R0                                                    02930000
         BM    ABEND3         NBYTES MUST BE >= 0                       02940000
         BZ    COMEXT                                                   02950000
         L     R1,AFCBAREA                                              02960000
         LTR   R1,R1                                                    02970000
         BNP   ABEND3         MUST BE > 0                               02980000
         LH    R5,FCBSTKLN    R5 = # OF FCB AREAS TO DATE               02990000
         CH    R5,MAXSTACK    SEE IF WE STILL HAVE STACK SPACE          03000000
         BE    ABEND7                                                   03010000
         SLL   R5,2                                                     03020000
         L     R6,FCBSTK1     ADDRESS OF FCB ADDRESS STACK              03030000
         L     R7,FCBSTK2     ADDRESS OF FCB LENGTH STACK               03040000
         ST    R1,0(R5,R6)                                              03050000
         ST    R0,0(R5,R7)                                              03060000
         LH    R5,FCBSTKLN                                              03070000
         LA    R5,1(R5)                                                 03080000
         STH   R5,FCBSTKLN                                              03090000
         B     COMEXT                                                   03100000
*                                                                       03110000
RESCIND  L     R4,ADECB       R4 = ADDRESS OF THE DECB                  03120000
         CLI   IOFLAG,0       IS THERE A WRITE IN PROGRESS?             03130000
         BNE   NOCHECK1                                                 03140000
         CHECK (R4)                                                     03150000
         MVI   IOFLAG,0                                                 03160000
NOCHECK1 LH    R6,NUMOFPGS                                              03170000
         SH    R6,BASNPGS                                               03180000
         BNP   ABEND5                                                   03190000
         USING PDENTRY,R8                                               03200000
         L     R8,APAD                                                  03210000
         LH    R5,BASNPGS                                               03220000
         STH   R5,NUMOFPGS                                              03230000
         MH    R5,=AL2(PDENTLEN)                                        03240000
         AR    R8,R5                                                    03250000
         USING FCBCELL,R12                                              03260000
RESCLOOP L     R12,FCBADDR                                              03270000
         LTR   R12,R12        IS THIS PAGE IN USE?                      03280000
         BZ    NOWRITE1                                                 03290000
         LH    R1,RESVCNT     IS IT RESERVED?                           03300000
         LTR   R1,R1                                                    03310000
         BP    ABEND6                                                   03320000
         LH    R1,PAGENO                                                03330000
         SR    R0,R0                                                    03340000
         ST    R0,FCBPDADR(R1)                                          03350000
         CLI   MODFIND,0      IS THE PAGE MODIFIED?                     03360000
         BE    NOWRITE1                                                 03370000
         MVC   BUFLOC,APGEBUFF  SET UP DECB FOR READ                    03380000
         L     R2,FCBTTRZ(R1)                                           03390000
         ST    R2,TTRWORD                                               03400000
         POINT PDSFILE,TTRWORD                                          03410000
         READ  (R4),SF,MF=E                                             03420000
         CHECK (R4)                                                     03430000
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR WRITE                   03440000
         WRITE (R4),SF,MF=E                                             03450000
         CHECK (R8)                                                     03460000
NOWRITE1 XC    PAGEADDR(16),PAGEADDR                                    03470000
         LA    R8,PDENTLEN(R8)                                          03480000
         BCT   R6,RESCLOOP                                              03490000
         LH    R1,LPAD        R1 = MAX # OF PAGES                       03500000
         SH    R1,BASNPGS                                               03510000
         STH   R1,NPAGES      TELL THE USER HOW MUCH IS LEFT            03520000
         B     COMEXT                                                   03530000
         DROP  R8,R12                                                   03540000
*                                                                       03550000
EXIT     EQU   *                                                        03560000
         OSRETURN                                                       03570000
*                                                                       03580000
*        ABENDS                                                         03590000
*                                                                       03600000
         USING *,R15                                                    03610000
ABEND1   LA    R1,4002        SYNAD ERROR                               03620000
         B     DOABEND                                                  03630000
         DROP  R15                                                      03640000
ABEND2   LA    R1,4013        BAD PAGING AREA SPECIFICATION             03650000
         B     DOABEND                                                  03660000
ABEND3   LA    R1,4015        BAD FCB AREA SPECIFICATION                03670000
         B     DOABEND                                                  03680000
ABEND4   LA    R1,4019        GETMAIN FAILURE IN INIT                   03690000
         B     DOABEND                                                  03700000
ABEND5   LA    R1,4012        RESCIND (NO EXTERNAL AREA ALLOCATED)      03710000
         B     DOABEND                                                  03720000
ABEND6   LA    R1,4011        RESCIND (1 OR MORE PAGES RESERVED)        03730000
         B     DOABEND                                                  03740000
ABEND7   LA    R1,4021        EXHAUSTION OF INTERNAL STACKS             03750000
         B     DOABEND                                                  03760000
*                                                                       03770000
DOABEND  ABEND (R1),DUMP                                                03780000
*                                                                       03790000
*        DCB OPEN EXIT LOGIC                                            03800000
*                                                                       03810000
         DS    0F                                                       03820000
EXITLST  DC    X'85',AL3(OUTEXIT)                                       03830000
*                                                                       03840000
         USING IHADCB,R1                                                03850000
OUTEXIT  NC    DCBBLKSI,DCBBLKSI  CHECK BLKSIZE                         03860000
         BNZ   OUTEXIT1           ALREADY SET                           03870000
         MVC   DCBBLKSI(2),DFLTBLKS                                     03880000
*                                 PROVIDE DEFAULT BLOCK SIZE            03890000
OUTEXIT1 NC    DCBLRECL,DCBLRECL  CHECK LRECL                           03900000
         BNZ   OUTEXIT2           ALREADY SET                           03910000
         MVC   DCBLRECL(2),DFLTLREC                                     03920000
*                                 PROVIDE DEFAULT LRECL                 03930000
OUTEXIT2 TM    DCBRECFM,B'11111110' CHECK RECFM                         03940000
         BCR   B'0111',14         ALREADY SET SO RETURN                 03950000
         OC    DCBRECFM(1),DFLTRECF                                     03960000
*                                 PROVIDE DEFAULT RECFM                 03970000
         BR     R14               RETURN                                03980000
         DROP   R1                                                      03990000
*                                                                       04000000
         DS     0H                                                      04010000
DFLTBLKS DC    H'1680'        BLKSIZE = 1680 BYTES                      04020000
DFLTLREC DC    H'1680'        LRECL = 1680 BYTES                        04030000
DFLTRECF DC    B'10000000'    RECFM = F                                 04040000
*                                                                       04050000
*        DATA  AREA                                                     04060000
*                                                                       04070000
         DS    0F                                                       04080000
AREATEMP DS    F                                                        04090000
BYTETEMP DS    F                                                        04100000
TTRWORD  DS    F                                                        04110000
*                                                                       04120000
*        LITERAL POOL                                                   04130000
*                                                                       04140000
         LTORG                                                          04150000
*                                                                       04160000
*        DCB FOR SDF I/O                                                04170000
*                                                                       04180000
PDSFILE  DCB   DSORG=PO,                                               X04190000
               DEVD=DA,                                                X04200000
               EXLST=EXITLST,                                          X04210000
               MACRF=(R,W),                                            X04220000
               DDNAME=HALSDF,                                          X04230000
               SYNAD=ABEND1                                             04240000
*                                                                       04250000
*        PAGING AREA DIRECTORY                                          04260000
*                                                                       04270000
         DS    0D                                                       04280000
APAD     DC    A(PADBASE)                                               04290000
LPAD     DC    H'&PAG2'                                                 04300000
         DC    H'0'                                                     04310000
PADBASE  DC    (4*&PAG2)F'0'                                            04320000
*                                                                       04330000
*        DSECTS                                                         04340000
*                                                                       04350000
         DATABUF                                                        04360000
         COMMTABL                                                       04370000
         PDENTRY                                                        04380000
         FCBCELL                                                        04390000
         PRINT NOGEN                                                    04400000
         DCBD  DSORG=(PO)                                               04410000
         END                                                            04420000
