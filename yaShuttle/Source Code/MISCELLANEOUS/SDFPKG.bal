*                                                                       00010000
* SDFPKG:  VERS 2.0     CRAIG W. SCHULENBERG     10/30/92               00020001
*                         -- BASELINED THIS VERSION (NO CHANGES)        00030000
*                         -- TOTAL CHANGES SINCE 1977 LISTING:          00040000
*                            1) ADDITION OF DECLARE STMT SUPPORT        00050000
*                                                                       00060000
         TITLE 'SDFPKG  -  TOP LEVEL CONTROL LOGIC OF THE ACCESS PKG'   00070000
         MACRO                                                          00080000
         BLK2PTR                                                        00090000
         SR    R1,R1                                                    00100000
         CALL  NDX2PTR                                                  00110000
         MEND                                                           00120000
         MACRO                                                          00130000
         SYMB2PTR                                                       00140000
         LA    R1,4                                                     00150000
         CALL  NDX2PTR                                                  00160000
         MEND                                                           00170000
         MACRO                                                          00180000
         STMT2PTR                                                       00190000
         LA    R1,8                                                     00200000
         CALL  NDX2PTR                                                  00210000
         MEND                                                           00220000
SDFPKG   CSECT                                                          00230000
*                                                                       00240000
*       INPUT:   R0    ADDRESS OF COMMUNICATION AREA (MODE 0 ONLY)      00250000
*                R1    BIT 0  (1 --> AUTO-SELECT OPTION)                00260000
*                      BIT 1  (1 --> MODIFICATION)                      00270000
*                      BIT 2  (1 --> RELEASE)                           00280000
*                      BIT 3  (1 --> RESERVE)                           00290000
*                R13   ADDRESS OF USER'S SAVE AREA                      00300000
*                R14   RETURN ADDRESS TO USER                           00310000
*                R15   SDFPKG ENTRY ADDRESS                             00320000
*                                                                       00330000
*       OUTPUT:  R1    ADDRESS OF 'LOCATED' ITEM                        00340000
*                R15   RETURN CODE                                      00350000
*                R0    UNCHANGED                                        00360000
*                R2 - R14  UNCHANGED                                    00370000
*                                                                       00380000
         USING *,15                                                     00390000
         B     *+12                                                     00400000
         DC    CL8'SDFPKG  '                                            00410000
         BALR  15,0                                                     00420000
         DROP  15                                                       00430000
         OSSAVE                                                         00440000
         USING COMMTABL,R10                                             00450000
         USING DATABUF,R11                                              00460000
         USING FCBCELL,R12                                              00470000
*                                                                       00480000
*        CHECK VALIDITY OF THE SERVICE CODE                             00490000
*                                                                       00500000
         LM    R10,R11,ADCONS INITIALIZE BASE REGS                      00510000
         L     R12,CURFCB                                               00520000
         LH    R2,RETARG1+2   R2 = SDFPKG MODE #                        00530000
         STC   R2,MODE        SAVE THE MODE NUMBER                      00540000
         LTR   R2,R2                                                    00550000
         BM    ABEND1         CODE < 0                                  00560000
         BZ    INIT           CALL INITIALIZATION DIRECTLY              00570000
         CH    R2,=H'17'      IS THE CODE TOO LARGE?                    00580000
         BH    ABEND1                                                   00590000
         CLI   GOFLAG,0       ARE WE INITIALIZED?                       00600000
         BE    ABEND2                                                   00610000
         CH    R2,=H'5'       SEE IF THE ROUTINE CAN HAVE AUTO-SELECT   00620000
         BL    FANOUT                                                   00630000
         MVC   SAVPTR,PNTR                                              00640000
         LTR   R1,R1          TEST FOR THE AUTO-SELECT OPTION           00650000
         BNM   CHKFCB                                                   00660000
         CALL  SELECT                                                   00670000
         ST    R15,RETCODE                                              00680000
         LTR   R15,R15                                                  00690000
         BNZ   COMEXT                                                   00700000
         SR    R2,R2                                                    00710000
         IC    R2,MODE        SET UP THE MODE NUMBER AGAIN              00720000
CHKFCB   L     R12,CURFCB     RELOAD R12 (SUCCESSFUL SELECT)            00730000
         LTR   R12,R12                                                  00740000
         BZ    ABEND7                                                   00750000
FANOUT   SLL   R2,2                                                     00760000
         B     SERVICES(R2)   BRANCH TO SERVICE ROUTINE                 00770000
SERVICES B     SERVICES       INITIALIZE IS CALLED ABOVE                00780000
         B     TERM           TERMINATE SDFPKG                          00790000
         B     AUGMENT        AUGMENT PAGING AREA OR FCB AREA           00800000
         B     RESCIND        RESCIND AUGMENTED PAGING AREA             00810000
         B     DOSELECT       SELECT FILE                               00820000
         B     LOCATEP        LOCATE VIRTUAL MEMORY POINTER             00830000
         B     SETDISPS       SET DISPOSITION PARAMETERS                00840000
         B     LROOT          LOCATE ROOT CELL                          00850000
         B     BLOCK          FIND BLOCK CELL GIVEN #                   00860000
         B     SYMB           FIND SYMBOL CELL GIVEN #                  00870000
         B     STMT           FIND STMT CELL GIVEN #                    00880000
         B     BNAME          FIND BLOCK CELL GIVEN NAME                00890000
         B     BNAME          FIND SYMBOL CELL GIVEN BLK NAME/SYMB NAME 00900000
         B     SYMBSRCH       FIND SYMB CELL GIVEN NAME (& LST BLK)     00910000
         B     FINDSRN        FIND STMT CELL GIVEN SRN                  00920000
         B     BLOCK          FIND BLOCK NODE GIVEN #                   00930000
         B     SYMB           FIND SYMBOL NODE GIVEN #                  00940000
         B     STMT           FIND STMT NODE GIVEN #                    00950000
*                                                                       00960000
INIT     CLI   GOFLAG,0       CHECK FOR MULTIPLE INIT                   00970000
         BNE   ABEND3                                                   00980000
         ST    R0,ADCONS      INITIALIZE LOCAL COPY OF COMMTABL ADDR    00990000
         LR    R10,R0                                                   01000000
         TM    MISC+1,X'10'   SEE IF FIRST SYMBOL MODE                  01010000
         BNO   INITA                                                    01020000
         MVI   FIRST,X'01'    SET FIRST FLAG                            01030000
INITA    TM    MISC+1,X'08'   SEE IF ONLY ONE FCB IS TO BE KEPT         01040000
         BNO   INITB                                                    01050000
         MVI   ONEFCB,X'01'   SET ONE-FCB FLAG                          01060000
INITB    SR    R1,R1                                                    01070000
         CALL  PAGMOD                                                   01080000
         ST    R15,RETCODE                                              01090000
         ST    R11,ADDR       RETURN ADDRESS OF DATABUF TO CALLER       01100000
         B     COMEXTA                                                  01110000
*                                                                       01120000
TERM     LA    R1,4                                                     01130000
         CALL  PAGMOD                                                   01140000
         B     COMEXT                                                   01150000
*                                                                       01160000
AUGMENT  LA    R1,8                                                     01170000
         CALL  PAGMOD                                                   01180000
         B     COMEXT                                                   01190000
*                                                                       01200000
RESCIND  LA    R1,12                                                    01210000
         CALL  PAGMOD                                                   01220000
         B     COMEXT                                                   01230000
*                                                                       01240000
DOSELECT CALL  SELECT                                                   01250000
         ST    R15,RETCODE                                              01260000
         B     COMEXT                                                   01270000
*                                                                       01280000
LOCATEP  L     R1,SAVPTR      PICK UP ORIGINAL POINTER                  01290000
         CALL  LOCATE                                                   01300000
         B     SETDISPS                                                 01310000
*                                                                       01320000
LROOT    SR    R1,R1          LOCATE POINTER 0                          01330000
         CALL  LOCATE                                                   01340000
         USING PAGEZERO,R1                                              01350000
         L     R1,DROOTPTR    PICK UP THE ROOT POINTER                  01360000
         DROP  R1                                                       01370000
         CALL  LOCATE         FIND THE ROOT CELL                        01380000
         B     SETDISPS                                                 01390000
*                                                                       01400000
BNAME    XC    BLKNO,BLKNO    ZERO BLOCK NUMBER IN CASE UNSUCCESSFUL    01410000
         L     R1,TREEPTR     R1 = ROOT OF THE BLOCK TREE               01420000
LOCLOOP  CALL  LOCATE         LOCATE POINTER IN R1                      01430000
         USING BLKTCELL,R1                                              01440000
         SR    R2,R2                                                    01450000
         IC    R2,BLKNLEN     R2 = LENGTH OF NAME BEING SOUGHT          01460000
         BCTR  R2,0                                                     01470000
         SR    R3,R3                                                    01480000
         IC    R3,BNAMELEN    R3 = LENGTH OF NAME UNDER SCRUTINY        01490000
         BCTR  R3,0                                                     01500000
         CR    R2,R3          SEE WHICH NAME IS SHORTER                 01510000
         BH    USE3                                                     01520000
         EX    R2,BCOMP       COMPARE BLOCK NAMES                       01530000
         B     BLKCOMM                                                  01540000
BCOMP    CLC   BLKNAM(0),BLKNAME                                        01550000
USE3     EX    R3,BCOMP                                                 01560000
BLKCOMM  BE    MATCH                                                    01570000
         BH    RIGHT                                                    01580000
LEFT     L     R1,LTREEPTR    NAME SOUGHT IS < -- GO LEFT               01590000
CHECK    LTR   R1,R1          CAN WE CONTINUE?                          01600000
         BZ    NOBLOCK                                                  01610000
         B     LOCLOOP                                                  01620000
RIGHT    L     R1,RTREEPTR    NAME SOUGHT IS > -- GO RIGHT              01630000
         B     CHECK                                                    01640000
MATCH    CR    R2,R3          WERE THE LENGTHS EQUAL?                   01650000
         BE    BLKFOUND                                                 01660000
         BH    RIGHT                                                    01670000
         B     LEFT                                                     01680000
NOBLOCK  MVI   RETCODE+3,16   INDICATE BLOCK NOT FOUND                  01690000
         XC    SAVEXTPT(8),SAVEXTPT INVALIDATE OLD BLOCK INFO           01700000
         B     COMEXT                                                   01710000
BLKFOUND LH    R0,BLKNDX      GET BLOCK INDEX FROM BLOCK CELL           01720000
         STH   R0,BLKNO       STORE BLOCK INDEX IN COMMUNICATION AREA   01730000
         DROP  R1                                                       01740000
*                                                                       01750000
BLOCK    XC    SAVEXTPT(8),SAVEXTPT INVALIDATE OLD BLOCK INFO           01760000
         LH    R0,BLKNO       GET THE DESIRED BLOCK #                   01770000
         BLK2PTR                                                        01780000
         CALL  LOCATE                                                   01790000
         USING BLCKNODE,R1                                              01800000
         MVC   CSECTNAM(8),CSCTNAME                                     01810000
         CLI   MODE,15                                                  01820000
         BE    SETDISPS                                                 01830000
         L     R1,BLOCKPTR                                              01840000
         CALL  LOCATE                                                   01850000
         CLI   MODE,11                                                  01860000
         BE    BLKDATA                                                  01870000
         USING BLKTCELL,R1                                              01880000
         SR    R2,R2                                                    01890000
         IC    R2,BNAMELEN                                              01900000
         STC   R2,BLKNLEN                                               01910000
         BCTR  R2,R0                                                    01920000
         MVC   BLKNAM,BLANKS                                            01930000
         EX    R2,BMOVE                                                 01940000
         B     BLKDATA                                                  01950000
BMOVE    MVC   BLKNAM(0),BLKNAME                                        01960000
*                                                                       01970000
*        EXTRACT ALL DATA NECESSARY FOR SYMBOL SEARCHES                 01980000
*                                                                       01990000
BLKDATA  MVC   SAVEXTPT,EXTPTR  POINTER TO SYMBOL NODE EXTENT CELL      02000000
         MVC   SAVFSYMB,FSYMB#  SYMBOL # OF FIRST SYMBOL OF BLOCK       02010000
         MVC   SAVLSYMB,LSYMB#  SYMBOL # OF LAST SYMBOL IN BLOCK        02020000
         CLI   MODE,8                                                   02030000
         BE    SETDISPS                                                 02040000
         CLI   MODE,11                                                  02050000
         BE    SETDISPS                                                 02060000
         DROP  R1                                                       02070000
*                                                                       02080000
*        PERFORM SEARCH FOR SYMBOL GIVEN ITS NAME                       02090000
*                                                                       02100000
SYMBSRCH XC    SYMBNO,SYMBNO  ZERO SYMBOL NUMBER IN CASE UNSUCCESSFUL   02110000
         LH    R0,SAVFSYMB                                              02120000
         LTR   R0,R0                                                    02130000
         BZ    ABEND8         BLOCK NOT PREVIOUSLY SPECIFIED            02140000
         MVC   SRCHARG(8),BLANKS  BLANK OUT 8 CHAR SEARCH ARGUMENT      02150000
         SR    R2,R2          ZERO R2 FOR IC TO FOLLOW                  02160000
         IC    R2,SYMBNLEN    R2 = LENGTH OF INPUTTED SYMBOL NAME       02170000
         BCTR  R2,0           SUBTRACT 1 FOR EXECUTED MVC               02180000
         EX    R2,SMOVE1      INITIALIZE SEARCH ARGUMENT                02190000
         B     BINIT                                                    02200000
SMOVE1   MVC   SRCHARG(0),SYMBNAM                                       02210000
*                                                                       02220000
*        INITIALIZE THE BINARY SEARCH ALGORITHM                         02230000
*                                                                       02240000
BINIT    LH    R0,SAVFSYMB    R0 = 1ST SYMBOL #                         02250000
         STH   R0,SYMBBASE    SAVE THE VALUE                            02260000
         L     R1,SAVEXTPT    R1 = POINTER TO SYMBOL NODE EXTENT CELL   02270000
         LTR   R1,R1          DOES SUCH A CELL EXIST?                   02280000
         BNZ   EXTCELL        PROCESS DIRECTORY INFORMATION             02290000
         SYMB2PTR             CONVERT TO A POINTER                      02300000
         LR    R6,R1          R6 = POINTER TO 1ST SYMBOL                02310000
         N     R6,=X'0000FFFF'  R6 = OFFSET TO 1ST SYMBOL               02320000
         STH   R6,OFFBASE     SAVE THE OFFSET ALSO                      02330000
         N     R1,=X'FFFF0000'  R1 = POINTER TO THE PAGE ITSELF         02340000
         CALL  LOCATE                                                   02350000
         ST    R1,PAGEBASE    PAGEBASE = ADDRESS OF THE PAGE            02360000
         LH    R0,SAVLSYMB    R0 = LAST SYMBOL #                        02370000
         SYMB2PTR             CONVERT TO A POINTER                      02380000
         LR    R7,R1          R7 = POINTER TO LAST SYMBOL               02390000
         N     R7,=X'0000FFFF'  R7 = OFFSET TO LAST SYMBOL              02400000
*                                                                       02410000
*        BINARY SEARCH ALGORITHM                                        02420000
*                                                                       02430000
BINSRCH  CR    R6,R7          SEE IF LOWER LIMIT > UPPER                02440000
         BH    NOSYMBOL                                                 02450000
         LR    R5,R6                                                    02460000
         AR    R5,R7                                                    02470000
         SR    R4,R4          ZERO R4 FOR DIVIDE TO FOLLOW              02480000
         D     R4,=F'24'                                                02490000
         MH    R5,=H'12'                                                02500000
         L     R1,PAGEBASE                                              02510000
         AR    R1,R5                                                    02520000
         USING SYMBNODE,R1                                              02530000
         CLC   SRCHARG(8),SYMBNAME  COMPARE 8 CHAR NAMES                02540000
         BE    LINSRCH                                                  02550000
         BH    ADJSTLO        SEE IF LOW LIMIT TO BE ADJUSTED           02560000
ADJSTHI  LR    R7,R5                                                    02570000
         SH    R7,=H'12'                                                02580000
         B     BINSRCH                                                  02590000
ADJSTLO  LR    R6,R5                                                    02600000
         LA    R6,12(R6)                                                02610000
         B     BINSRCH                                                  02620000
*                                                                       02630000
*        SYMBOL NODE EXTENT CELL PROCESSING LOGIC                       02640000
*                                                                       02650000
EXTCELL  CALL  LOCATE         LOCATE THE SYMBOL NODE EXTENT CELL        02660000
         LR    R4,R1          R4 = ADDR OF FIXED PART OF CELL           02670000
         USING SYMEXTF,R4                                               02680000
         LH    R8,NEXTNTRY    R8 = # OF ENTRIES IN THE CELL             02690000
         LH    R2,FSTPAGE     R2 = FIRST PAGE #                         02700000
         LA    R3,8(R4)       R3 = ADDR OF VARIABLE PART OF CELL        02710000
         USING SYMEXTV,R3                                               02720000
EXTLOOP  CLC   FSTSYMB(8),SRCHARG                                       02730000
         BH    NOSYMBOL                                                 02740000
         CLC   LSTSYMB(8),SRCHARG                                       02750000
         BNL   THISPAGE                                                 02760000
*                                                                       02770000
*        CHECK THE NEXT ENTRY (IF ONE EXISTS)                           02780000
*                                                                       02790000
         LH    R1,LSTOFF      R1 = LAST OFFSET ON PAGE                  02800000
         SH    R1,FSTOFF                                                02810000
         SR    R0,R0          ZERO R0 FOR DIVIDE TO FOLLOW              02820000
         D     R0,=F'12'      DIVIDE BY SIZE OF SYMBOL NODES            02830000
         AH    R1,SYMBBASE    ADD ON THE BASE SYMBOL #                  02840000
         LA    R1,1(R1)       ADD 1                                     02850000
         STH   R1,SYMBBASE    UPDATE THE BASE SYMBOL #                  02860000
         LA    R2,1(R2)       INCREMENT THE PAGE #                      02870000
         LA    R3,20(R3)      ADVANCE TO NEXT VARIABLE ENTRY            02880000
         BCT   R8,EXTLOOP     LOOP AGAIN IF THERE ARE MORE              02890000
         L     R1,SUCCPTR     R1 = POINTER TO NEXT EXTENT CELL          02900000
         LTR   R1,R1                                                    02910000
         BZ    NOSYMBOL                                                 02920000
         B     EXTCELL                                                  02930000
*                                                                       02940000
*        THE SYMBOL MUST BE ON THIS PAGE -- SET UP FOR SEARCH           02950000
*                                                                       02960000
THISPAGE LH    R6,FSTOFF      R6 = OFFSET ON PAGE TO 1ST SYMBOL         02970000
         STH   R6,OFFBASE     SAVE THE OFFSET                           02980000
         LR    R5,R6                                                    02990000
         LH    R7,LSTOFF      R7 = OFFSET ON PAGE TO LAST SYMBOL        03000000
         LR    R1,R2          GET THE PAGE NUMBER                       03010000
         SLL   R1,16          MAKE INTO A POINTER                       03020000
         CALL  LOCATE         LOCATE THE PAGE                           03030000
         ST    R1,PAGEBASE    SAVE THE BASE ADDRESS                     03040000
         B     BINSRCH                                                  03050000
*                                                                       03060000
*        TWO-WAY LINEAR SEARCH                                          03070000
*                                                                       03080000
LINSRCH  SH    R5,OFFBASE     R5 = CURRENT OFFSET - ORIGINAL            03090000
         SR    R4,R4          ZERO R4 FOR DIVIDE                        03100000
         D     R4,=F'12'                                                03110000
         AH    R5,SYMBBASE    R5 = CURRENT SYMBOL NUMBER                03120000
         STH   R5,SYMBBASE    SAVE CURRENT SYMBOL #                     03130000
         LA    R15,CHKMATCH                                             03140000
         BALR  R14,R15        SEE IF CURRENT CELL IS GOOD               03150000
         LTR   R15,R15                                                  03160000
         BNP   SRCHUP                                                   03170000
LINSRCHA LH    R5,SYMBBASE                                              03180000
         B     LOOPCNTA                                                 03190000
SRCHUP   BCTR  R5,0           RETREAT 1 SYMBOL #                        03200000
         CH    R5,SAVFSYMB    DONT LEAVE CURRENT BLOCK                  03210000
         BL    LINSRCHA       TRY TO GO DOWN                            03220000
         LR    R0,R5          R0 = CURRENT SYMBOL #                     03230000
         SYMB2PTR             CONVERT TO A POINTER                      03240000
         CALL  LOCATE         LOCATE SYMBOL NODE                        03250000
         USING SYMBNODE,R1                                              03260000
         CLC   SRCHARG(8),SYMBNAME  SEE IF WE MATCH TO 8 CHARS          03270000
         BNE   LINSRCHA       TRY TO GO DOWN                            03280000
         LA    R15,CHKMATCH                                             03290000
         BALR  R14,R15                                                  03300000
         LTR   R15,R15                                                  03310000
         BP    LINSRCHA                                                 03320000
         B     SRCHUP                                                   03330000
SRCHDOWN LR    R0,R5          R0 = CURRENT SYMBOL #                     03340000
         SYMB2PTR             CONVERT TO A POINTER                      03350000
         CALL  LOCATE         LOCATE SYMBOL NODE                        03360000
         USING SYMBNODE,R1                                              03370000
         CLC   SRCHARG(8),SYMBNAME  SEE IF WE MATCH TO 8 CHARS          03380000
         BNE   NOSYMBOL                                                 03390000
         LA    R15,CHKMATCH                                             03400000
         BALR  R14,R15                                                  03410000
         LTR   R15,R15                                                  03420000
         BM    NOSYMBOL                                                 03430000
LOOPCNTA LA    R5,1(R5)       ADVANCE TO NEXT SYMBOL                    03440000
         CH    R5,SAVLSYMB    DONT LEAVE THE CURRENT BLOCK!             03450000
         BH    NOSYMBOL                                                 03460000
         B     SRCHDOWN                                                 03470000
*                                                                       03480000
*        WE HAVE A POSSIBLE MATCH                                       03490000
*                                                                       03500000
         USING SYMBNODE,R1                                              03510000
CHKMATCH ST    R14,SAVR14     SAVE THE RETURN ADDRESS (LOCATE CLOBBERS) 03520000
         MVC   NAMEBUF(8),SYMBNAME                                      03530000
         L     R1,SDCPTR      R1 = POINTER TO SYMBOL DATA CELL          03540000
         CALL  LOCATE         LOCATE SYMBOL DATA CELL                   03550000
         USING SYMBDC,R1                                                03560000
         L     R14,SAVR14     RESTORE THE RETURN ADDRESS                03570000
         SR    R2,R2          ZERO R2 FOR IC TO FOLLOW                  03580000
         IC    R2,SYMBNLEN    R2 = LENGTH OF SYMBOL NAME SOUGHT         03590000
         BCTR  R2,0           DECREMENT FOR EXECUTED CLC                03600000
         SR    R4,R4          ZERO R4 FOR IC TO FOLLOW                  03610000
         IC    R4,SYMBLEN     R4 = LENGTH OF SYMBOL NAME FOUND          03620000
         BCTR  R4,0           DECREMENT FOR EXECUTED CLC                03630000
         LR    R3,R4                                                    03640000
         SH    R4,=H'8'       R4 = LENGTH OF NAME CONTINUATION (-1)     03650000
         BM    CHKLEN                                                   03660000
         EX    R4,SMOVE2                                                03670000
         CR    R2,R3          SEE WHICH NAME IS SHORTER                 03680000
BRNCH    BH    USE3A                                                    03690000
         EX    R2,SCOMP                                                 03700000
         B     SYMBCOMM                                                 03710000
SCOMP    CLC   SYMBNAM(0),NAMEBUF                                       03720000
SMOVE2   MVC   NAMEBUF+8(0),NAMECONT                                    03730000
USE3A    EX    R3,SCOMP                                                 03740000
SYMBCOMM BE    MATCHA                                                   03750000
         BH    GODOWN                                                   03760000
GOUP     LH    R15,=H'-1'                                               03770000
         BR    R14                                                      03780000
GODOWN   LA    R15,1                                                    03790000
         BR    R14                                                      03800000
MATCHA   CR    R2,R3          WERE THE LENGTHS EQUAL?                   03810000
         BE    CHKTYPE                                                  03820000
         BH    GODOWN                                                   03830000
         B     GOUP                                                     03840000
CHKLEN   CR    R2,R3          LENGTH FOUND WAS <= 8. EQUAL?             03850000
         BNE   BRNCH                                                    03860000
CHKTYPE  CLI   FIRST,1        IF IN FIRST MODE, TAKE IT AND GO          03870000
         BE    SYMFOUND                                                 03880000
         CLI   CLASS,2                                                  03890000
         BNE   NOT2                                                     03900000
         CLI   TYPE,8                                                   03910000
         BE    SKIPIT         EQUATE EXTERNAL                           03920000
NOT2     CLI   CLASS,3        NO PROBLEMS IF CLASSES 1,2 OR 3           03930000
         BNH   SYMFOUND                                                 03940000
         TM    FLAG1,X'03'    IS IT AN UNQUALIFIED STRUC TERMINAL?      03950000
         BC    5,SYMFOUND     OR A TEMPLATE HEADER???                   03960000
SKIPIT   SR    R15,R15        ZERO R15 TO SHOW NO CHANGE OF DIRECTION   03970000
         BR    R14                                                      03980000
SYMFOUND STH   R5,SYMBNO      STORE SYMBOL INDEX IN COMMUNICATION AREA  03990000
         B     SETDISPS       APPLY DISPOSITION PARAMETERS              04000000
         DROP  R1                                                       04010000
*                                                                       04020000
NOSYMBOL MVI   RETCODE+3,20   INDICATE SYMBOL NOT FOUND                 04030000
         B     COMEXT                                                   04040000
*                                                                       04050000
SYMB     LH    R0,SYMBNO      PICK UP THE SYMBOL #                      04060000
         SYMB2PTR                                                       04070000
         CALL  LOCATE                                                   04080000
         CLI   MODE,16                                                  04090000
         BE    SETDISPS                                                 04100000
         USING SYMBNODE,R1                                              04110000
         MVC   SYMBNAM,BLANKS                                           04120000
         MVC   SYMBNAM(8),SYMBNAME                                      04130000
         L     R1,SDCPTR                                                04140000
         CALL  LOCATE                                                   04150000
         USING SYMBDC,R1                                                04160000
         LH    R2,BLOCKNUM                                              04170000
         STH   R2,BLKNO       STORE THE BLOCK #                         04180000
         SR    R2,R2                                                    04190000
         IC    R2,SYMBLEN                                               04200000
         STC   R2,SYMBNLEN                                              04210000
         CH    R2,=H'8'                                                 04220000
         BNH   COMPLETE                                                 04230000
         SH    R2,=H'9'                                                 04240000
         EX    R2,SMOVE                                                 04250000
COMPLETE B     SETDISPS                                                 04260000
SMOVE    MVC   SYMBNAM+8(0),NAMECONT                                    04270000
         DROP  R1                                                       04280000
*                                                                       04290000
FINDSRN  XC    STMTNO,STMTNO  ZERO STMT NUMBER IN CASE UNSUCCESSFUL     04300000
         L     R1,STMTEXPT    R1 = POINTER TO STMT EXTENT CELL          04310000
         LTR   R1,R1          ARE THERE SRNS IN THIS FILE?              04320000
         BNZ   SRNOK                                                    04330000
         MVI   RETCODE+3,28   FILE HAS NO SRNS                          04340000
         B     COMEXT                                                   04350000
SRNOK    TM    FLAGS,X'04'    ARE THE SRNS MONOTONIC?                   04360000
         BNO   SRNOK1                                                   04370000
         MVI   RETCODE+3,32   SRNS ARE NOT MONOTONIC!                   04380000
         B     COMEXT                                                   04390000
SRNOK1   LH    R0,FSTSTMT     R0 = 1ST STMT #                           04400000
         STH   R0,STMTBASE    SAVE THE VALUE                            04410000
*                                                                       04420000
*        STATEMENT NODE EXTENT CELL PROCESSING LOGIC                    04430000
*                                                                       04440000
EXTCELL1 CALL  LOCATE         LOCATE THE STMT NODE EXTENT CELL          04450000
         LR    R4,R1          R4 = ADDR OF FIXED PART OF CELL           04460000
         USING STMTEXTF,R4                                              04470000
         LH    R8,NXNTRY      R8 = # OF ENTRIES IN THE CELL             04480000
         LH    R2,FSTPAGE1    R2 = FIRST PAGE #                         04490000
         LA    R3,8(R4)       R3 = ADDR OF VARIABLE PART OF CELL        04500000
         USING STMTEXTV,R3                                              04510000
EXTLOOP1 CLC   FSTSRN(8),SREFNO                                         04520000
         BH    NOSTMT                                                   04530000
         CLC   LSTSRN(8),SREFNO                                         04540000
         BNL   THISPGE1                                                 04550000
*                                                                       04560000
*        CHECK THE NEXT ENTRY (IF ONE EXISTS)                           04570000
*                                                                       04580000
         LH    R1,LSTOFF1     R1 = LAST OFFSET ON PAGE                  04590000
         SH    R1,FSTOFF1                                               04600000
         SR    R0,R0          ZERO R0 FOR DIVIDE TO FOLLOW              04610000
         D     R0,=F'12'      DIVIDE BY SIZE OF STMT NODES              04620000
         AH    R1,STMTBASE    ADD ON THE BASE STATEMENT #               04630000
         LA    R1,1(R1)       ADD 1                                     04640000
         STH   R1,STMTBASE    UPDATE THE BASE STATEMENT #               04650000
         LA    R2,1(R2)       INCREMENT THE PAGE #                      04660000
         LA    R3,20(R3)      ADVANCE TO NEXT VARIABLE ENTRY            04670000
         BCT   R8,EXTLOOP1    LOOP AGAIN IF THERE ARE MORE              04680000
         L     R1,SUCCPTR1    R1 = POINTER TO NEXT EXTENT CELL          04690000
         LTR   R1,R1          ARE THERE MORE?                           04700000
         BZ    NOSTMT                                                   04710000
         B     EXTCELL1                                                 04720000
*                                                                       04730000
*        THE STATEMENT MUST BE ON THIS PAGE -- SET UP FOR SEARCH        04740000
*                                                                       04750000
THISPGE1 LH    R6,FSTOFF1     R6 = OFFSET ON PAGE TO 1ST SRN            04760000
         STH   R6,OFFBASE     SAVE THE OFFSET                           04770000
         LR    R5,R6                                                    04780000
         LH    R7,LSTOFF1     R7 = OFFSET ON PAGE TO LAST SRN           04790000
         LR    R1,R2          GET THE PAGE #                            04800000
         SLL   R1,16          MAKE IT INTO A POINTER                    04810000
         CALL  LOCATE         LOCATE THE PAGE                           04820000
         ST    R1,PAGEBASE    SAVE THE BASE ADDRESS                     04830000
*                                                                       04840000
*        BINARY SEARCH ALGORITHM FOR SRNS                               04850000
*                                                                       04860000
BINSRCH1 CR    R6,R7          SEE IF LOWER LIMIT > UPPER                04870000
         BH    NOSTMT                                                   04880000
         LR    R5,R6                                                    04890000
         AR    R5,R7                                                    04900000
         SR    R4,R4          ZERO R4 FOR DIVIDE TO FOLLOW              04910000
         D     R4,=F'24'                                                04920000
         MH    R5,=H'12'                                                04930000
         L     R1,PAGEBASE                                              04940000
         AR    R1,R5                                                    04950000
         USING STMTNOD1,R1                                              04960000
         CLC   SREFNO(8),SRN                                            04970000
         BE    SRNMATCH                                                 04980000
         BH    ADJSTLO1                                                 04990000
ADJSTHI1 LR    R7,R5                                                    05000000
         SH    R7,=H'12'                                                05010000
         B     BINSRCH1                                                 05020000
ADJSTLO1 LR    R6,R5                                                    05030000
         LA    R6,12(R6)                                                05040000
         B     BINSRCH1                                                 05050000
*                                                                       05060000
*        MATCH FOUND ON THE SRN SEARCH                                  05070000
*                                                                       05080000
SRNMATCH LR    R7,R5          SET R7 TO CURRENT OFFSET                  05090000
SRNLOOP  SH    R7,=H'12'      BACK UP ONE ENTRY                         05100000
         CH    R7,OFFBASE     ENSURE THAT WE DONT FALL OFF              05110000
         BL    SRNFOUND                                                 05120000
         L     R1,PAGEBASE    R1 = ADDR OF PAGE START                   05130000
         AR    R1,R7          ADD IN THE OFFSET                         05140000
         CLC   SREFNO(8),SRN  ARE THE SRNS STILL EQUAL?                 05150000
         BNE   SRNFOUND       GET OUT IF NOT                            05160000
         LR    R5,R7          THEY ARE EQUAL - UPDATE R5                05170000
         B     SRNLOOP        CONTINUE THE BACK SCAN                    05180000
SRNFOUND L     R1,PAGEBASE    RELOAD R1 SINCE WE MAY HAVE CLOBBERED IT  05190000
         AR    R1,R5                                                    05200000
         SH    R5,OFFBASE     R5 = CURRENT OFFSET - ORIGINAL            05210000
         SR    R4,R4          ZERO R4 FOR DIVIDE TO FOLLOW              05220000
         D     R4,=F'12'                                                05230000
         AH    R5,STMTBASE    R5 = CURRENT STATEMENT #                  05240000
         L     R1,STDCPTR1    R1 = POINTER TO STATEMENT DATA CELL       05250000
         LTR   R1,R1                                                    05260000
         BP    STMTCOMM                                                 05270000
         MVI   RETCODE+3,24   SRN MATCH BUT NOT EXECUTABLE              05280000
         LPR   R1,R1     IS IT A DECLARE STMT?                          05290000
         BNZ   STMTCOMM                                                 05300000
         B     COMEXT                                                   05310000
NOSTMT   MVI   RETCODE+3,20   NO SRN MATCH                              05320000
         B     COMEXT                                                   05330000
*                                                                       05340000
STMT     LH    R0,STMTNO      PICK UP THE STMT #                        05350000
         STMT2PTR                                                       05360000
         ST    R15,RETCODE    STORE THE RETURN CODE                     05370000
         LTR   R15,R15        SEE IF THE STMT # WAS LEGAL               05380000
         BNZ   COMEXT                                                   05390000
         CALL  LOCATE                                                   05400000
         TM    FLAGS,X'80'    ARE THERE SRNS?                           05410000
         BNO   NOSRNS                                                   05420000
         USING STMTNOD1,R1                                              05430000
         MVC   SREFNO(8),SRN                                            05440000
         L     R1,STDCPTR1                                              05450000
         B     COMMON                                                   05460000
         USING STMTNOD0,R1                                              05470000
NOSRNS   L     R1,STDCPTR                                               05480000
COMMON   CLI   MODE,17                                                  05490000
         BE    SETDISPS                                                 05500000
         LTR   R1,R1          IS THIS AN EXECUTABLE STMT?               05510000
         BP   EXECLBLE                                                  05520000
         MVI   RETCODE+3,24                                             05530000
         LPR   R1,R1   IS IT A DECLARE STMT?                            05540000
         BNZ   EXECLBLE                                                 05550000
         B     COMEXT                                                   05560000
STMTCOMM STH   R5,STMTNO      UPDATE STATEMENT # IN COMM AREA           05570000
EXECLBLE CALL  LOCATE                                                   05580000
         USING STMTDC,R1                                                05590000
         LH    R2,BNUM                                                  05600000
         STH   R2,BLKNO       STORE THE BLOCK #                         05610000
         B     SETDISPS       SET DISPOSITION PARMS                     05620000
         DROP  R1,R12                                                   05630000
*                                                                       05640000
*        COMMON EXIT POINT IF DISPOSTION PARAMETERS ARE NOT TO BE SET   05650000
*                                                                       05660000
COMEXT   XC    ADDR,ADDR                                                05670000
COMEXTA  XC    PNTR,PNTR                                                05680000
         XC    ACURNTRY,ACURNTRY                                        05690000
         B     EXIT                                                     05700000
*                                                                       05710000
SETDISPS L     R12,ACURNTRY                                             05720000
         LTR   R12,R12                                                  05730000
         BZ    ABEND6                                                   05740000
         USING PDENTRY,R12                                              05750000
CHKMODF  TM    RETARG1,X'40'  SEE IF MODF                               05760000
         BNO   CHKRELS                                                  05770000
         CLI   MODFLAG,1      IS UPDAT MODE ACTIVE?                     05780000
         BNE   ABEND9                                                   05790000
         MVI   MODFIND,X'80'                                            05800000
CHKRELS  TM    RETARG1,X'20'  SEE IF RELS                               05810000
         BNO   CHKRESV                                                  05820000
         LH    R1,RESVCNT                                               05830000
         LTR   R1,R1                                                    05840000
         BZ    ABEND5                                                   05850000
         BCTR  R1,0                                                     05860000
         STH   R1,RESVCNT                                               05870000
         L     R1,RESERVES                                              05880000
         BCTR  R1,0                                                     05890000
         ST    R1,RESERVES                                              05900000
CHKRESV  TM    RETARG1,X'10'  SEE IF RESV                               05910000
         BNO   EXIT                                                     05920000
         LH    R1,RESVCNT                                               05930000
         CH    R1,=X'7FFF'                                              05940000
         BE    ABEND4                                                   05950000
         LA    R1,1(R1)                                                 05960000
         STH   R1,RESVCNT                                               05970000
         L     R1,RESERVES                                              05980000
         LA    R1,1(R1)                                                 05990000
         ST    R1,RESERVES                                              06000000
EXIT     MVC   RETARG1,ADDR                                             06010000
         MVC   CRETURN,RETCODE+2                                        06020000
         OSRETURN                                                       06030000
*                                                                       06040000
*        ABENDS                                                         06050000
*                                                                       06060000
ABEND1   LA    R1,4016        BAD SERVICE CODE                          06070000
         B     DOABEND                                                  06080000
ABEND2   LA    R1,4009        FIRST CALL TO SDFPKG NOT INIT             06090000
         B     DOABEND                                                  06100000
ABEND3   LA    R1,4017        MULTIPLE CALL TO INIT                     06110000
         B     DOABEND                                                  06120000
ABEND4   LA    R1,4003        TOO MANY RESERVES FOR ONE PAGE            06130000
         B     DOABEND                                                  06140000
ABEND5   LA    R1,4004        TOO MANY RELEASES FOR ONE PAGE            06150000
         B     DOABEND                                                  06160000
ABEND6   LA    R1,4014        SETDISPS CALLED BEFORE ANY LOCATES        06170000
         B     DOABEND                                                  06180000
ABEND7   LA    R1,4010        SELECT DEPENDENT ROUTINE CALLED AND       06190000
         B     DOABEND        SELECT WAS NOT CURRENTLY IN FORCE!        06200000
ABEND8   LA    R1,4020        BLOCK NOT PREVIOUSLY SPECIFIED            06210000
         B     DOABEND                                                  06220000
ABEND9   LA    R1,4008        MODF NOT LEGAL UNLESS UPDAT MODE          06230000
         B     DOABEND                                                  06240000
*                                                                       06250000
DOABEND  ABEND (R1),DUMP                                                06260000
*                                                                       06270000
*        DATA BASES                                                     06280000
*                                                                       06290000
         DS    0F                                                       06300000
ADCONS   EQU   *                                                        06310000
         DS    A              ADDRESS OF COMMUNICATION AREA             06320000
         DC    V(COMMDATA)                                              06330000
*                                                                       06340000
STMTBASE EQU   *              STARTING STATEMENT #                      06350000
SYMBBASE DS    H              STARTING SYMBOL #                         06360000
OFFBASE  DS    H              STARTING OFFSET                           06370000
*                                                                       06380000
         DS    0F                                                       06390000
SAVPTR   DS    F                                                        06400000
SAVR14   DS    F              SAVE LOCATION FOR REGISTER 14             06410000
PAGEBASE DS    A              BASE ADDRESS OF PAGE                      06420000
BLANKS   DC    32CL1' '                                                 06430000
*                                                                       06440000
*        NOTE:  THE VARIABLE NAMEBUF SHOULD IMMEDIATELY FOLLOW          06450000
*        SRCHARG SINCE UP TO 32 CHARACTERS ARE ACTUALLY DEPOSITED       06460000
*        INTO THIS 8 BYTE LOCATION!!                                    06470000
*                                                                       06480000
SRCHARG  DS    CL8            SYMBOL NODE SEARCH ARGUMENT               06490000
NAMEBUF  DS    CL32           NAME FROM SYMBOL NODE AND DATA CELL       06500000
*                                                                       06510000
MODE     DS    CL1            SDFPKG MODE NUMBER                        06520000
         DATABUF                                                        06530000
         FCBCELL                                                        06540000
         COMMTABL                                                       06550000
         PDENTRY                                                        06560000
         PAGEZERO                                                       06570000
         DROOTCEL                                                       06580000
         SYMBDC                                                         06590000
         STMTDC                                                         06600000
         BLKTCELL                                                       06610000
         BLCKNODE                                                       06620000
         SYMBNODE                                                       06630000
         STMTNOD0                                                       06640000
         STMTNOD1                                                       06650000
         SYMEXTF                                                        06660000
         SYMEXTV                                                        06670000
         STMTEXTF                                                       06680000
         STMTEXTV                                                       06690000
         END                                                            06700000
