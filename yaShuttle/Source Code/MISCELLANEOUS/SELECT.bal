*                                                                       00010016
* SELECT:  VERS 2.0     CRAIG W. SCHULENBERG     10/30/92               00020022
*                         -- ADD LOGIC TO OBTAIN TTRS BY READS AND      00030016
*                              REMOVED USE OF TRAILING TTR PAGES        00040016
*                              CR # 11097 (ELIMINATE USE OF             00050027
*                                NOTELISTS IN HAL COMPILER)             00060027
*                         -- USE FULLWORD ADD FOR SELECT COUNTER        00070016
*                              MAINTENANCE                              00080016
*                         -- FIX DR# XXXXXX: INCORRECT PMF REVISION     00090026
*                              LEVEL RETURNED TO CALLER WHEN THE        00100026
*                              SDF HAS MORE THAN ONE NOTELIST PAGE.     00110026
*                              *** ALSO FETCH REV. LVL FROM FIRST       00120027
*                              TTRN POSITION IF THERE ARE 'NO'          00130028
*                              NOTELISTS.                               00140028
*                         -- PREVIOUS CHANGES (SINCE 1977 VERSION)      00150018
*                            1) ADDITION OF LOGIC TO RETURN REVISION    00160018
*                               LEVEL INFO (FOR COMPILER PURPOSES?)     00170018
*                                                                       00180016
         TITLE 'SELECT  -  SELECTS A DESIRED SDF MEMBER'                00190000
         GBLA  &FCBEXT                                                  00200000
&FCBEXT  SETA  512            SIZE OF FCB SECONDARY ALLOCATIONS         00210000
SELECT   CSECT                                                          00220000
*                                                                       00230000
         USING *,15                                                     00240010
         B     *+12                                                     00250016
         DC    CL8'SELECT  '                                            00260016
         BALR  15,0                                                     00270016
         DROP  15                                                       00280016
         OSSAVE                                                         00290000
         USING COMMTABL,R10                                             00300000
         USING DATABUF,R11                                              00310000
         USING FCBCELL,R12                                              00320000
         XC    SAVEXTPT(8),SAVEXTPT INVALIDATE INFO FOR LAST BLOCK      00330000
         LTR   R12,R12        DO WE HAVE AN FCB?                        00340000
         BZ    DOSELECT                                                 00350000
         CLC   SDFNAM,FILENAME  SEE IF ALREADY SELECTED                 00360000
         BE    EXIT           SELECT ALREADY PERFORMED                  00370000
         XC    CURFCB,CURFCB  INDICATE NO SELECTION YET!                00380000
*                                                                       00390000
DOSELECT L     R1,SLECTCNT                                              00400010
         A     R1,=F'1'       USE A 32-BIT ADD                          00410016
         ST    R1,SLECTCNT                                              00420016
         L     R12,ROOT                                                 00430000
         LTR   R12,R12        HAVE WE DONE ANY SELECTS YET?             00440000
         BNZ   COMPARE                                                  00450000
         MVI   MODE,0                                                   00460000
         B     BUILDFCB                                                 00470000
COMPARE  CLC   SDFNAM,FILENAME                                          00480000
         BE    FOUND                                                    00490000
         BH    RIGHT                                                    00500000
LEFT     L     R8,LTTREEPT                                              00510000
         LTR   R8,R8                                                    00520000
         BNZ   GOLEFT                                                   00530000
         MVI   MODE,1                                                   00540000
         B     BUILDFCB                                                 00550000
GOLEFT   LR    R12,R8                                                   00560000
         B     COMPARE                                                  00570000
RIGHT    L     R8,GTTREEPT                                              00580000
         LTR   R8,R8                                                    00590000
         BNZ   GORIGHT                                                  00600000
         MVI   MODE,2                                                   00610000
         B     BUILDFCB                                                 00620000
GORIGHT  LR    R12,R8                                                   00630000
         B     COMPARE                                                  00640000
*                                                                       00650000
FOUND    ST    R12,CURFCB                                               00660000
         MVC   SDFVERS,VERSIONX                                         00670010
         BAL   R7,DOFIND     PERFORM A FIND FOR THE MEMBER              00680000
         B     EXIT                                                     00690000
*                                                                       00700000
BUILDFCB EQU   *                                                        00710000
         MVC   NAME,SDFNAM                                              00720000
*                                                                       00730000
*        ENSURE THAT ANY PREVIOUS WRITE HAS COMPLETED                   00740000
*                                                                       00750000
         L     R6,ADECB       R6 = ADDRESS OF THE DECB                  00760000
         CLI   IOFLAG,0       WRITE IN PROGRESS?                        00770000
         BE    NOCHECK                                                  00780000
         CHECK (R6)           WAIT FOR COMPLETION                       00790000
         MVI   IOFLAG,0       INDICATE COMPLETED                        00800000
NOCHECK  L     R8,DCBADDR                                               00810000
         BLDL  (R8),BLDLAREA                                            00820000
         LTR   R15,R15                                                  00830000
         BZ    GETRVL                                                   00840000
         MVI   RETCODE+3,8    INDICATE BLDL FAILURE                     00850000
         B     EXIT                                                     00860000
*                                                                       00870000
*        GET REVISION LEVEL                                             00880003
*                                                                       00890006
GETRVL   SR    R4,R4          ZERO R4 FOR IC TO FOLLOW                  00900027
         STH   R4,BLKNO       SHOW NO REVISION LEVEL OBTAINED           00910027
         IC    R4,C           GET C BYTE IN LOWEST BYTE OF R4           00920027
         SRL   R4,3           GET NUMBER OF BYTES OF USER TTRS          00930027
         N     R4,=X'0000000C' R4 WILL BE 0, 4, 8, OR 12                00940027
         CH    R4,=H'8'       ONLY ACCEPT UP TO 8 TTR BYTES             00950027
         BH    GETCAT         SKIP THE STORING OF REVISION LEVEL        00960027
         LH    R1,TTRN1(R4)   FETCH REVISION LEVEL (TTRN1,2,OR 3)       00970027
         STH   R1,BLKNO       STORE REVISION LEVEL (2 EBCDIC CHARS)     00980027
GETCAT   SR    R2,R2          ZERO R2 FOR IC TO FOLLOW                  00990027
         IC    R2,K           PICK UP THE 'K' BYTE (CATENATION LEVEL)   01000026
         LA    R2,1(R2)       INCREMENT BY 1 (CAT LVLS GO 1,2,3...)     01010027
         STH   R2,SYMBNO      RETURN TO THE USER IN SYMBNO              01020025
*                                                                       01030016
*        ALLOCATE AN FCB                                                01040000
*                                                                       01050000
BLDLOK   LH    R1,PGELAST                                               01060000
         LA    R1,1(R1)       R1 = TOTAL # OF PAGES                     01070000
         SLL   R1,3                                                     01080000
         AH    R1,=AL2(FCBLEN)                                          01090000
         ST    R1,SIZE        SAVE # OF BYTES NEEDED                    01100000
*                                                                       01110000
*        SET UP BASE ADDRESSES FOR FCB STACKS                           01120000
*                                                                       01130000
         L     R6,FCBSTK1     R6 = ADDR OF FCB ADDRESS STACK            01140000
         L     R7,FCBSTK2     R7 = ADDR OF FCB LENGTH STACK             01150000
*                                                                       01160000
*        SEE IF WE HAVE ENOUGH SPACE ON HAND                            01170000
*                                                                       01180000
         LH    R2,FCBSTKLN    R2 = # OF STACK ENTRIES                   01190000
         SR    R5,R5          R5 = STACK ENTRY COUNTER                  01200000
DOCOMP   C     R1,0(R5,R7)    COMPARE DESIRED LENGTH WITH STACK LENGTH  01210000
         BH    CONTINUE                                                 01220000
         L     R1,0(R5,R6)                                              01230000
         ST    R1,NEXTFCB                                               01240000
         B     SPACEOK                                                  01250000
CONTINUE LA    R5,4(R5)                                                 01260000
         BCT   R2,DOCOMP                                                01270000
         CLI   GETMFLAG,0     CAN WE DO A GETMAIN?                      01280000
         BNE   DOGETM         YES!                                      01290000
         MVI   RETCODE+3,12   NO. INDICATE SELECT HAS FAILED.           01300000
         STH   R1,NBYTES      TELL THE CALLER WHAT IS NEEDED            01310000
         B     EXIT                                                     01320000
DOGETM   LH    R4,NUMGETM     R4 = # OF GETMAINS TO DATE                01330000
         CH    R4,MAXSTACK    SEE IF WE STILL HAVE STACK SPACE          01340000
         BE    ABEND2                                                   01350000
         SLL   R4,2                                                     01360000
         LH    R5,FCBSTKLN    R5 = # OF FCB AREAS TO DATE               01370000
         CH    R5,MAXSTACK    SEE IF WE STILL HAVE STACK SPACE          01380000
         BE    ABEND2                                                   01390000
         SLL   R5,2                                                     01400000
         LA    R0,&FCBEXT     GET SECONDARY EXTENT SIZE                 01410000
         C     R0,SIZE        SEE IF IT WILL BE SUFFICIENT              01420000
         BNL   ENOUGH                                                   01430000
         L     R0,SIZE        GET EXACTLY WHAT IS NEEDED                01440000
ENOUGH   L     R2,GETMSTK2                                              01450000
         ST    R0,0(R4,R2)    UPDATE LENGTH STACK (GETMAIN)             01460000
         ST    R0,0(R5,R7)    UPDATE LENGTH STACK (FCB AREA)            01470000
         GETMAIN R,LV=(0)                                               01480000
         LTR   R15,R15        SEE IF GETMAIN SUCCESSFUL                 01490000
         BNZ   ABEND1         GETMAIN FAILURE!                          01500000
         ST    R1,NEXTFCB     SET UP NEXTFCB FOR THIS SELECT            01510000
         L     R2,GETMSTK1                                              01520000
         ST    R1,0(R4,R2)    UPDATE ADDRESS STACK (GETMAIN)            01530000
         ST    R1,0(R5,R6)    UPDATE ADDRESS STACK (FCB AREA)           01540000
         LH    R4,FCBSTKLN                                              01550000
         LA    R4,1(R4)       UPDATE FCB AREA COUNTER                   01560000
         STH   R4,FCBSTKLN                                              01570000
         LH    R4,NUMGETM                                               01580000
         LA    R4,1(R4)       INCREMENT GETMAIN COUNTER                 01590000
         STH   R4,NUMGETM                                               01600000
*                                                                       01610002
SPACEOK  CLI   ONEFCB,0       ARE WE IN THE ONE FCB MODE?               01620004
         BE    CHECK0                                                   01630006
         L     R1,RESERVES    YES. THE GLOBAL RESV CNT MUST BE 0        01640008
         LTR   R1,R1                                                    01650010
         BNZ   ABEND3                                                   01660012
*                                                                       01670014
*        LIBERATE THE ENTIRE PAGING AREA (DISCONNECT FROM FCB)          01680016
*                                                                       01690016
         L     R4,ADECB                                                 01700016
         L     R3,PADADDR                                               01710016
         USING PDENTRY,R3                                               01720016
         LH    R2,NUMOFPGS                                              01730016
FLUSH    L     R12,FCBADDR                                              01740016
         LTR   R12,R12        IS THIS PAGE IN USE?                      01750016
         BZ    NOWRITE                                                  01760016
         CLI   MODFIND,0      IS IT IN A MODIFIED STATE?                01770016
         BE    NOWRITE                                                  01780016
         MVC   BUFLOC,APGEBUFF                                          01790016
         LH    R1,PAGENO      R1 = PAGE # * 8                           01800016
         L     R0,FCBTTRZ(R1)                                           01810016
         ST    R0,TTRWORD                                               01820016
         POINT (R8),TTRWORD                                             01830016
         READ  (R4),SF,MF=E                                             01840016
         CHECK (R4)                                                     01850016
         MVC   BUFLOC,PAGEADDR                                          01860016
         WRITE (R4),SF,MF=E                                             01870016
         CHECK (R4)                                                     01880016
NOWRITE  XC    FCBADDR(12),FCBADDR                                      01890016
         LA    R3,PDENTLEN(R3)                                          01900016
         BCT   R2,FLUSH                                                 01910016
         DROP  R3                                                       01920016
         L     R1,SIZE                                                  01930016
         ST    R1,TOTFCBLN                                              01940016
         MVI   FCBCNT+3,1                                               01950016
         B     CONT                                                     01960016
CHECK0   CLI   MODE,0                                                   01970000
         BE    FIRSTX                                                   01980000
         CLI   MODE,1                                                   01990000
         BE    XLEFT                                                    02000000
XRIGHT   MVC   GTTREEPT,NEXTFCB                                         02010000
         B     COMMON                                                   02020000
XLEFT    MVC   LTTREEPT,NEXTFCB                                         02030000
         B     COMMON                                                   02040000
FIRSTX   MVC   ROOT,NEXTFCB                                             02050000
*                                                                       02060000
*        UPDATE FCB AREA STACKS AND STATISTICS                          02070000
*                                                                       02080000
COMMON   L     R1,SIZE                                                  02090002
         A     R1,TOTFCBLN                                              02100008
         ST    R1,TOTFCBLN    SAVE TOTAL SIZE OF FCBS                   02110010
         L     R1,FCBCNT                                                02120012
         LA    R1,1(R1)                                                 02130014
         ST    R1,FCBCNT                                                02140016
         L     R0,0(R5,R6)    GET CURRENT ADDRESS                       02150000
         A     R0,SIZE        INCREMENT BY AMOUNT OF SPACE TAKEN        02160000
         ST    R0,0(R5,R6)    UPDATE STACK ADDRESS                      02170000
         L     R0,0(R5,R7)    GET CURRENT LENGTH                        02180000
         S     R0,SIZE        DECREASE BY AMOUNT OF SPACE TAKEN         02190000
         ST    R0,0(R5,R7)    UPDATE STACK LENGTH                       02200000
CONT     L     R12,NEXTFCB                                              02210013
         ST    R12,CURFCB                                               02220016
*                                                                       02230000
*        ZERO OUT THE NEW FCB                                           02240000
*                                                                       02250000
         SR    R0,R0                                                    02260000
         L     R1,SIZE        R1 = # OF BYTES IN NEW FCB                02270000
         SRL   R1,2           GET # OF WORDS                            02280000
         SR    R2,R2                                                    02290000
ZERLOOP  ST    R0,0(R2,R12)                                             02300000
         LA    R2,4(R2)                                                 02310000
         BCT   R1,ZERLOOP                                               02320000
*                                                                       02330000
*        BEGIN FCB INITIALIZATION                                       02340000
*                                                                       02350000
         MVC   TTRK(4),TTR       INSERT INFO FOR FIND MACRO IN FCB      02360000
         MVC   FILENAME,SDFNAM   INSERT FILE NAME IN THE FCB            02370000
*                                                                       02380000
*        PERFORM A FIND MACRO IN CASE WE ARE IN A CATENATION LEVEL      02390000
*                                                                       02400000
         BAL   R7,DOFIND         LEAVES R6 POINTING AT THE DECB         02410000
*                                                                       02420016
*        SET UP TTR FOR PAGE 0; SET UP R7 COUNTER FOR ALL SDF PAGES     02430016
*                                                                       02440016
         SR    R3,R3             USE R3 TO DISPLACE INTO FCB TTR AREA   02450016
         MVC   TTRWORD(4),TTR    GET THE TTR OF PAGE 0                  02460016
         MVI   TTRWORD+3,0       ZERO OUT THE LOW-ORDER BYTE            02470016
         LH    R7,PGELAST        GET THE PAGE NUMBER OF THE LAST PAGE   02480016
         LA    R7,1(R7)          R7 = TOTAL NUMBER OF PAGES             02490016
*                                                                       02500021
*        INCREMENT THE GLOBAL READ COUNTER                              02510021
*                                                                       02520021
         L     R1,READS          GET THE CURRENT NUMBER OF SDF READS    02530021
         AR    R1,R7             32-BIT ADD (NO 'LA' FOR US!)           02540021
         ST    R1,READS          INCREMENT BY THE NUMBER OF SDF PAGES   02550021
*                                                                       02560016
*        READ ALL PAGES SEQUENTIALLY AND DO A 'NOTE' MACRO TO OBTAIN    02570016
*        THE TTRS (AS OPPOSED TO FETCHING THEM FROM THE TTR PAGE!)      02580016
*                                                                       02590016
         POINT (R8),TTRWORD      R8 = DCB ADDRESS; POINT TO PAGE 0      02600020
         MVC   BUFLOC,APGEBUFF   ENSURE DECB SET UP FOR READ            02610016
READPAGE READ  (R6),SF,MF=E      READ THE SDF PAGE                      02620016
         CHECK (R6)              WAIT FOR I/O COMPLETION                02630016
         NOTE  (R8)              USE THE NOTE MACRO TO GET THE TTR      02640016
         IC    R1,=X'00'         ZERO OUT THE LOW-ORDER BYTE            02650016
         ST    R1,FCBTTRZ(R3)    SAVE THE NEW TTR                       02660020
         LA    R3,8(R3)          POINT TO THE NEXT FCB TTR SLOT         02670020
         BCT   R7,READPAGE       READ ALL DATA PAGES IN TURN            02680016
*                                                                       02690016
*        NOW READ IN PAGE 0 AND FINISH THE NEW FCB                      02700016
*                                                                       02710000
         SR    R1,R1                                                    02720020
         CALL  LOCATE         LOCATE PAGE 0                             02730000
         USING PAGEZERO,R1                                              02740000
         MVC   VERSIONX,VERSION                                         02750010
         MVC   SDFVERS,VERSIONX                                         02760016
         AH    R1,DROOTPTR+2                                            02770000
         USING DROOTCEL,R1                                              02780000
         CLC   LASTPAGE,PGELAST                                         02790004
         BH    ABEND4                                                   02800008
         MVC   NUMBLKS,BLKNODES                                         02810000
         MVC   NUMSYMBS,SYMNODES                                        02820000
         MVC   FSTSTMT,FSTMTNUM                                         02830000
         MVC   LSTSTMT,LSTMTNUM                                         02840000
         MVC   LSTPAGE,LASTPAGE                                         02850000
         MVC   FLAGS,SDFFLAGS                                           02860000
         MVI   NODESIZE+1,4                                             02870000
         TM    FLAGS,X'80'                                              02880000
         BNO   NOSRNS                                                   02890000
         MVI   NODESIZE+1,12                                            02900000
NOSRNS   MVC   BLKPTR,FBNPTR                                            02910000
         MVC   SYMBPTR,FSNPTR                                           02920000
         MVC   STMTPTR,FSTNPTR                                          02930000
         MVC   TREEPTR,BTREEPTR                                         02940000
         MVC   STMTEXPT,SNELPTR                                         02950000
         DROP  R1                                                       02960000
*                                                                       02970000
EXIT     EQU   *                                                        02980000
         OSRETURN                                                       02990000
*                                                                       03000000
*        ROUTINE TO PERFORM FIND MACRO FOR NEWLY SELECTED MEMBER        03010000
*                                                                       03020000
DOFIND   L     R6,ADECB      R6 = ADDRESS OF DECB                       03030000
         CLI   IOFLAG,0      IS THERE A WRITE IN PROGRESS?              03040000
         BE    NOCHECK1                                                 03050000
         CHECK (R6)          WAIT FOR COMPLETION                        03060000
         MVI   IOFLAG,0      INDICATE NO I/O ACTIVE                     03070000
NOCHECK1 L     R8,DCBADDR    R8 = ADDRESS OF DCB                        03080000
         FIND  (R8),(R12),C                                             03090000
         BR    R7                                                       03100000
*                                                                       03110000
*        ABENDS                                                         03120000
*                                                                       03130000
ABEND1   LA    R1,4018        FCB AREA EXHAUSTED AND GETMAIN FAILED!    03140000
         B     DOABEND                                                  03150000
ABEND2   LA    R1,4021        EXHAUSTION OF INTERNAL STACKS             03160000
         B     DOABEND                                                  03170000
ABEND3   LA    R1,4022        SELECT INVOKED WHILE PAGES RESERVED       03180002
         B     DOABEND        (ONEFCB MODE ONLY)                        03190004
ABEND4   LA    R1,4023        SDF LENGTH MISMATCH (USER DATA FIELD BAD) 03200008
         B     DOABEND                                                  03210012
*                                                                       03220000
DOABEND  ABEND (R1),DUMP                                                03230000
*                                                                       03240000
*        DATA AREA                                                      03250000
*                                                                       03260000
         DS    0F                                                       03270000
NEXTFCB  DS    A              ADDRESS OF NEW FCB                        03280000
SIZE     DS    F              SIZE OF NEW FCB (BYTES)                   03290000
TTRWORD  DS    F              CURRENT TTR                               03300000
MODE     DS    CL1                                                      03310024
*                                                                       03320000
*        BLDL AREA                                                      03330000
*                                                                       03340000
         DS    0H                                                       03350000
BLDLAREA EQU   *                                                        03360000
FF       DC    H'1'                                                     03370000
LL       DC    H'28'                                                    03380027
NAME     DS    CL8                                                      03390000
TTR      DS    CL3                                                      03400000
K        DS    CL1                                                      03410000
Z        DS    CL1                                                      03420000
C        DS    CL1                                                      03430000
TTRN1    DS    2H                                                       03440000
TTRN2    DS    2H                                                       03450000
TTRN3    DS    2H                                                       03460000
PGELAST  DS    H                                                        03470000
*                                                                       03480000
*        LITERAL POOL                                                   03490000
*                                                                       03500000
         LTORG                                                          03510000
*                                                                       03520000
*        DSECTS                                                         03530000
*                                                                       03540000
         DATABUF                                                        03550000
         COMMTABL                                                       03560000
         PDENTRY                                                        03570000
         FCBCELL                                                        03580000
         PAGEZERO                                                       03590000
         DROOTCEL                                                       03600000
         END                                                            03610000
