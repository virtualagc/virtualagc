*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SDFPKG.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'SDFPKG  -  TOP LEVEL CONTROL LOGIC OF THE ACCESS PKG'   00010000
**********************************************************************
*     REVISION HISTORY :                                             *
*     ------------------                                             *
*     DATE    NAME  REL    DR/CR NUMBER AND TITLE                    *
*                                                                    *
*    05/17/99 DAS   30V0   CR13079 ADD HAL/S INITIALIZATION DATA TO  *
*                   15V0   SDF                                       *
*                                                                    *
**********************************************************************
         MACRO                                                          00010100
         BLK2PTR                                                        00010200
         SR    R1,R1                                                    00010300
         CALL  NDX2PTR                                                  00010400
         MEND                                                           00010500
         MACRO                                                          00010600
         SYMB2PTR                                                       00010700
         LA    R1,4                                                     00010800
         CALL  NDX2PTR                                                  00010900
         MEND                                                           00011000
         MACRO                                                          00011100
         STMT2PTR                                                       00011200
         LA    R1,8                                                     00011300
         CALL  NDX2PTR                                                  00011400
         MEND                                                           00011500
SDFPKG   CSECT                                                          00011600
*                                                                       00011700
*       INPUT:   R0    ADDRESS OF COMMUNICATION AREA (MODE 0 ONLY)      00011800
*                R1    BIT 0  (1 --> AUTO-SELECT OPTION)                00011900
*                      BIT 1  (1 --> MODIFICATION)                      00012000
*                      BIT 2  (1 --> RELEASE)                           00012100
*                      BIT 3  (1 --> RESERVE)                           00012200
*                R13   ADDRESS OF USER'S SAVE AREA                      00012300
*                R14   RETURN ADDRESS TO USER                           00012400
*                R15   SDFPKG ENTRY ADDRESS                             00012500
*                                                                       00012600
*       OUTPUT:  R1    ADDRESS OF 'LOCATED' ITEM                        00012700
*                R15   RETURN CODE                                      00012800
*                R0    UNCHANGED                                        00012900
*                R2 - R14  UNCHANGED                                    00013000
*                                                                       00013100
         USING *,15                                                     00013110
         B     *+12                                                     00013120
         DC    CL8'SDFPKG  '                                            00013130
         BALR  15,0                                                     00013132
         DROP  15                                                       00013140
         OSSAVE                                                         00013200
         USING COMMTABL,R10                                             00013300
         USING DATABUF,R11                                              00013400
         USING FCBCELL,R12                                              00013500
*                                                                       00013600
*        CHECK VALIDITY OF THE SERVICE CODE                             00013700
*                                                                       00013800
         LM    R10,R11,ADCONS INITIALIZE BASE REGS                      00013900
         L     R12,CURFCB                                               00014000
         LH    R2,RETARG1+2   R2 = SDFPKG MODE #                        00014100
         STC   R2,MODE        SAVE THE MODE NUMBER                      00014200
         LTR   R2,R2                                                    00014300
         BM    ABEND1         CODE < 0                                  00014400
         BZ    INIT           CALL INITIALIZATION DIRECTLY              00014500
         STC   R2,MODE        SAVE THE MODE NUMBER
         CLI   SDFVERS+1,33   CR13079 - ALLOW NEW MODE 18
         BH    NEWCHECK       CR13079
         CH    R2,=H'17'      IS THE CODE TOO LARGE?                    00014600
         BH    ABEND1                                                   00014700
NEWCHECK CH    R2,=H'18'      CR13079
         BH    ABEND1         CR13079
         CLI   GOFLAG,0       ARE WE INITIALIZED?                       00014800
         BE    ABEND2                                                   00014900
         CH    R2,=H'5'       SEE IF THE ROUTINE CAN HAVE AUTO-SELECT   00015000
         BL    FANOUT                                                   00015100
         MVC   SAVPTR,PNTR                                              00015200
         LTR   R1,R1          TEST FOR THE AUTO-SELECT OPTION           00015300
         BNM   CHKFCB                                                   00015400
         CALL  SELECT                                                   00015500
         ST    R15,RETCODE                                              00015600
         LTR   R15,R15                                                  00015700
         BNZ   COMEXT                                                   00015800
         SR    R2,R2                                                    00015900
         IC    R2,MODE        SET UP THE MODE NUMBER AGAIN              00016000
CHKFCB   L     R12,CURFCB     RELOAD R12 (SUCCESSFUL SELECT)            00016100
         LTR   R12,R12                                                  00016200
         BZ    ABEND7                                                   00016300
FANOUT   SLL   R2,2                                                     00016400
         B     SERVICES(R2)   BRANCH TO SERVICE ROUTINE                 00016500
SERVICES B     SERVICES       INITIALIZE IS CALLED ABOVE                00016600
         B     TERM           TERMINATE SDFPKG                          00016700
         B     AUGMENT        AUGMENT PAGING AREA OR FCB AREA           00016800
         B     RESCIND        RESCIND AUGMENTED PAGING AREA             00016900
         B     DOSELECT       SELECT FILE                               00017000
         B     LOCATEP        LOCATE VIRTUAL MEMORY POINTER             00017100
         B     SETDISPS       SET DISPOSITION PARAMETERS                00017200
         B     LROOT          LOCATE ROOT CELL                          00017300
         B     BLOCK          FIND BLOCK CELL GIVEN #                   00017400
         B     SYMB           FIND SYMBOL CELL GIVEN #                  00017500
         B     STMT           FIND STMT CELL GIVEN #                    00017600
         B     BNAME          FIND BLOCK CELL GIVEN NAME                00017700
         B     BNAME          FIND SYMBOL CELL GIVEN BLK NAME/SYMB NAME 00017800
         B     SYMBSRCH       FIND SYMB CELL GIVEN NAME (& LST BLK)     00017900
         B     FINDSRN        FIND STMT CELL GIVEN SRN                  00018000
         B     BLOCK          FIND BLOCK NODE GIVEN #                   00018100
         B     SYMB           FIND SYMBOL NODE GIVEN #                  00018200
         B     STMT           FIND STMT NODE GIVEN #                    00018300
         B     INITDATA       FIND INIT DATA AT GIVEN # -CR13079
*                                                                       00018400
INIT     CLI   GOFLAG,0       CHECK FOR MULTIPLE INIT                   00018500
         BNE   ABEND3                                                   00018600
         ST    R0,ADCONS      INITIALIZE LOCAL COPY OF COMMTABL ADDR    00018700
         LR    R10,R0                                                   00018710
         TM    MISC+1,X'10'   SEE IF FIRST SYMBOL MODE                  00018800
         BNO   INITA                                                    00018900
         MVI   FIRST,X'01'    SET FIRST FLAG                            00019000
INITA    TM    MISC+1,X'08'   SEE IF ONLY ONE FCB IS TO BE KEPT         00019100
         BNO   INITB                                                    00019200
         MVI   ONEFCB,X'01'   SET ONE-FCB FLAG                          00019300
INITB    SR    R1,R1                                                    00019500
         CALL  PAGMOD                                                   00019600
         ST    R15,RETCODE                                              00019700
         ST    R11,ADDR       RETURN ADDRESS OF DATABUF TO CALLER       00019800
         B     COMEXTA                                                  00019900
*                                                                       00020000
TERM     LA    R1,4                                                     00020100
         CALL  PAGMOD                                                   00020200
         B     COMEXT                                                   00020300
*                                                                       00020400
AUGMENT  LA    R1,8                                                     00020500
         CALL  PAGMOD                                                   00020600
         B     COMEXT                                                   00020700
*                                                                       00020800
RESCIND  LA    R1,12                                                    00020900
         CALL  PAGMOD                                                   00021000
         B     COMEXT                                                   00021100
*                                                                       00021200
DOSELECT CALL  SELECT                                                   00021300
         ST    R15,RETCODE                                              00021400
         B     COMEXT                                                   00021500
*                                                                       00021600
LOCATEP  L     R1,SAVPTR      PICK UP ORIGINAL POINTER                  00021700
         CALL  LOCATE                                                   00021800
         B     SETDISPS                                                 00021900
*                                                                       00022000
LROOT    SR    R1,R1          LOCATE POINTER 0                          00022100
         CALL  LOCATE                                                   00022200
         USING PAGEZERO,R1                                              00022300
         L     R1,DROOTPTR    PICK UP THE ROOT POINTER                  00022400
         DROP  R1                                                       00022500
         CALL  LOCATE         FIND THE ROOT CELL                        00022600
         USING DROOTCEL,R1    CR13079
         L     R1,DINITPTR    CR13079
         ST    R1,INITPTR     CR13079 - SAVE INITIAL DATA POINTER
         DROP  R1             CR13079
         B     SETDISPS                                                 00022700
*                                                                       00022800
BNAME    XC    BLKNO,BLKNO    ZERO BLOCK NUMBER IN CASE UNSUCCESSFUL    00022900
         L     R1,TREEPTR     R1 = ROOT OF THE BLOCK TREE               00023000
LOCLOOP  CALL  LOCATE         LOCATE POINTER IN R1                      00023100
         USING BLKTCELL,R1                                              00023200
         SR    R2,R2                                                    00023300
         IC    R2,BLKNLEN     R2 = LENGTH OF NAME BEING SOUGHT          00023400
         BCTR  R2,0                                                     00023500
         SR    R3,R3                                                    00023600
         IC    R3,BNAMELEN    R3 = LENGTH OF NAME UNDER SCRUTINY        00023700
         BCTR  R3,0                                                     00023800
         CR    R2,R3          SEE WHICH NAME IS SHORTER                 00023900
         BH    USE3                                                     00024000
         EX    R2,BCOMP       COMPARE BLOCK NAMES                       00024100
         B     BLKCOMM                                                  00024200
BCOMP    CLC   BLKNAM(0),BLKNAME                                        00024300
USE3     EX    R3,BCOMP                                                 00024400
BLKCOMM  BE    MATCH                                                    00024500
         BH    RIGHT                                                    00024600
LEFT     L     R1,LTREEPTR    NAME SOUGHT IS < -- GO LEFT               00024700
CHECK    LTR   R1,R1          CAN WE CONTINUE?                          00024800
         BZ    NOBLOCK                                                  00024900
         B     LOCLOOP                                                  00025000
RIGHT    L     R1,RTREEPTR    NAME SOUGHT IS > -- GO RIGHT              00025100
         B     CHECK                                                    00025200
MATCH    CR    R2,R3          WERE THE LENGTHS EQUAL?                   00025300
         BE    BLKFOUND                                                 00025400
         BH    RIGHT                                                    00025500
         B     LEFT                                                     00025600
NOBLOCK  MVI   RETCODE+3,16   INDICATE BLOCK NOT FOUND                  00025700
         XC    SAVEXTPT(8),SAVEXTPT INVALIDATE OLD BLOCK INFO           00025800
         B     COMEXT                                                   00025900
BLKFOUND LH    R0,BLKNDX      GET BLOCK INDEX FROM BLOCK CELL           00026000
         STH   R0,BLKNO       STORE BLOCK INDEX IN COMMUNICATION AREA   00026100
         DROP  R1                                                       00026200
*                                                                       00026300
BLOCK    XC    SAVEXTPT(8),SAVEXTPT INVALIDATE OLD BLOCK INFO           00026400
         LH    R0,BLKNO       GET THE DESIRED BLOCK #                   00026500
         BLK2PTR                                                        00026600
         CALL  LOCATE                                                   00026700
         USING BLCKNODE,R1                                              00026800
         MVC   CSECTNAM(8),CSCTNAME                                     00026900
         CLI   MODE,15                                                  00027000
         BE    SETDISPS                                                 00027100
         L     R1,BLOCKPTR                                              00027200
         CALL  LOCATE                                                   00027300
         CLI   MODE,11                                                  00027400
         BE    BLKDATA                                                  00027500
         USING BLKTCELL,R1                                              00027600
         SR    R2,R2                                                    00027700
         IC    R2,BNAMELEN                                              00027800
         STC   R2,BLKNLEN                                               00027900
         BCTR  R2,R0                                                    00028000
         MVC   BLKNAM,BLANKS                                            00028100
         EX    R2,BMOVE                                                 00028200
         B     BLKDATA                                                  00028300
BMOVE    MVC   BLKNAM(0),BLKNAME                                        00028400
*                                                                       00028500
*        EXTRACT ALL DATA NECESSARY FOR SYMBOL SEARCHES                 00028600
*                                                                       00028700
BLKDATA  MVC   SAVEXTPT,EXTPTR  POINTER TO SYMBOL NODE EXTENT CELL      00028800
         MVC   SAVFSYMB,FSYMB#  SYMBOL # OF FIRST SYMBOL OF BLOCK       00028900
         MVC   SAVLSYMB,LSYMB#  SYMBOL # OF LAST SYMBOL IN BLOCK        00029000
         CLI   MODE,8                                                   00029100
         BE    SETDISPS                                                 00029200
         CLI   MODE,11                                                  00029300
         BE    SETDISPS                                                 00029400
         DROP  R1                                                       00029500
*                                                                       00029600
*        PERFORM SEARCH FOR SYMBOL GIVEN ITS NAME                       00029700
*                                                                       00029800
SYMBSRCH XC    SYMBNO,SYMBNO  ZERO SYMBOL NUMBER IN CASE UNSUCCESSFUL   00029900
         LH    R0,SAVFSYMB                                              00030000
         LTR   R0,R0                                                    00030100
         BZ    ABEND8         BLOCK NOT PREVIOUSLY SPECIFIED            00030200
         MVC   SRCHARG(8),BLANKS  BLANK OUT 8 CHAR SEARCH ARGUMENT      00030300
         SR    R2,R2          ZERO R2 FOR IC TO FOLLOW                  00030400
         IC    R2,SYMBNLEN    R2 = LENGTH OF INPUTTED SYMBOL NAME       00030500
         BCTR  R2,0           SUBTRACT 1 FOR EXECUTED MVC               00030600
         EX    R2,SMOVE1      INITIALIZE SEARCH ARGUMENT                00030700
         B     BINIT                                                    00030800
SMOVE1   MVC   SRCHARG(0),SYMBNAM                                       00030900
*                                                                       00031000
*        INITIALIZE THE BINARY SEARCH ALGORITHM                         00031100
*                                                                       00031200
BINIT    LH    R0,SAVFSYMB    R0 = 1ST SYMBOL #                         00031300
         STH   R0,SYMBBASE    SAVE THE VALUE                            00031400
         L     R1,SAVEXTPT    R1 = POINTER TO SYMBOL NODE EXTENT CELL   00031500
         LTR   R1,R1          DOES SUCH A CELL EXIST?                   00031600
         BNZ   EXTCELL        PROCESS DIRECTORY INFORMATION             00031700
         SYMB2PTR             CONVERT TO A POINTER                      00031800
         LR    R6,R1          R6 = POINTER TO 1ST SYMBOL                00031900
         N     R6,=X'0000FFFF'  R6 = OFFSET TO 1ST SYMBOL               00032000
         STH   R6,OFFBASE     SAVE THE OFFSET ALSO                      00032100
         N     R1,=X'FFFF0000'  R1 = POINTER TO THE PAGE ITSELF         00032200
         CALL  LOCATE                                                   00032300
         ST    R1,PAGEBASE    PAGEBASE = ADDRESS OF THE PAGE            00032400
         LH    R0,SAVLSYMB    R0 = LAST SYMBOL #                        00032500
         SYMB2PTR             CONVERT TO A POINTER                      00032600
         LR    R7,R1          R7 = POINTER TO LAST SYMBOL               00032700
         N     R7,=X'0000FFFF'  R7 = OFFSET TO LAST SYMBOL              00032800
*                                                                       00032900
*        BINARY SEARCH ALGORITHM                                        00033000
*                                                                       00033100
BINSRCH  CR    R6,R7          SEE IF LOWER LIMIT > UPPER                00033200
         BH    NOSYMBOL                                                 00033300
         LR    R5,R6                                                    00033400
         AR    R5,R7                                                    00033500
         SR    R4,R4          ZERO R4 FOR DIVIDE TO FOLLOW              00033600
         D     R4,=F'24'                                                00033700
         MH    R5,=H'12'                                                00033800
         L     R1,PAGEBASE                                              00033900
         AR    R1,R5                                                    00034000
         USING SYMBNODE,R1                                              00034100
         CLC   SRCHARG(8),SYMBNAME  COMPARE 8 CHAR NAMES                00034200
         BE    LINSRCH                                                  00034300
         BH    ADJSTLO        SEE IF LOW LIMIT TO BE ADJUSTED           00034400
ADJSTHI  LR    R7,R5                                                    00034500
         SH    R7,=H'12'                                                00034600
         B     BINSRCH                                                  00034700
ADJSTLO  LR    R6,R5                                                    00034800
         LA    R6,12(R6)                                                00034900
         B     BINSRCH                                                  00035000
*                                                                       00035100
*        SYMBOL NODE EXTENT CELL PROCESSING LOGIC                       00035200
*                                                                       00035300
EXTCELL  CALL  LOCATE         LOCATE THE SYMBOL NODE EXTENT CELL        00035400
         LR    R4,R1          R4 = ADDR OF FIXED PART OF CELL           00035500
         USING SYMEXTF,R4                                               00035600
         LH    R8,NEXTNTRY    R8 = # OF ENTRIES IN THE CELL             00035700
         LH    R2,FSTPAGE     R2 = FIRST PAGE #                         00035800
         LA    R3,8(R4)       R3 = ADDR OF VARIABLE PART OF CELL        00035900
         USING SYMEXTV,R3                                               00036000
EXTLOOP  CLC   FSTSYMB(8),SRCHARG                                       00036100
         BH    NOSYMBOL                                                 00036200
         CLC   LSTSYMB(8),SRCHARG                                       00036300
         BNL   THISPAGE                                                 00036400
*                                                                       00036500
*        CHECK THE NEXT ENTRY (IF ONE EXISTS)                           00036600
*                                                                       00036700
         LH    R1,LSTOFF      R1 = LAST OFFSET ON PAGE                  00036800
         SH    R1,FSTOFF                                                00036900
         SR    R0,R0          ZERO R0 FOR DIVIDE TO FOLLOW              00037000
         D     R0,=F'12'      DIVIDE BY SIZE OF SYMBOL NODES            00037100
         AH    R1,SYMBBASE    ADD ON THE BASE SYMBOL #                  00037200
         LA    R1,1(R1)       ADD 1                                     00037300
         STH   R1,SYMBBASE    UPDATE THE BASE SYMBOL #                  00037400
         LA    R2,1(R2)       INCREMENT THE PAGE #                      00037500
         LA    R3,20(R3)      ADVANCE TO NEXT VARIABLE ENTRY            00037600
         BCT   R8,EXTLOOP     LOOP AGAIN IF THERE ARE MORE              00037700
         L     R1,SUCCPTR     R1 = POINTER TO NEXT EXTENT CELL          00037800
         LTR   R1,R1                                                    00037900
         BZ    NOSYMBOL                                                 00038000
         B     EXTCELL                                                  00038100
*                                                                       00038200
*        THE SYMBOL MUST BE ON THIS PAGE -- SET UP FOR SEARCH           00038300
*                                                                       00038400
THISPAGE LH    R6,FSTOFF      R6 = OFFSET ON PAGE TO 1ST SYMBOL         00038500
         STH   R6,OFFBASE     SAVE THE OFFSET                           00038600
         LR    R5,R6                                                    00038700
         LH    R7,LSTOFF      R7 = OFFSET ON PAGE TO LAST SYMBOL        00038800
         LR    R1,R2          GET THE PAGE NUMBER                       00038900
         SLL   R1,16          MAKE INTO A POINTER                       00039000
         CALL  LOCATE         LOCATE THE PAGE                           00039100
         ST    R1,PAGEBASE    SAVE THE BASE ADDRESS                     00039200
         B     BINSRCH                                                  00039300
*                                                                       00039400
*        TWO-WAY LINEAR SEARCH                                          00039500
*                                                                       00039600
LINSRCH  SH    R5,OFFBASE     R5 = CURRENT OFFSET - ORIGINAL            00039700
         SR    R4,R4          ZERO R4 FOR DIVIDE                        00039800
         D     R4,=F'12'                                                00039900
         AH    R5,SYMBBASE    R5 = CURRENT SYMBOL NUMBER                00040000
         STH   R5,SYMBBASE    SAVE CURRENT SYMBOL #                     00040100
         LA    R15,CHKMATCH                                             00040200
         BALR  R14,R15        SEE IF CURRENT CELL IS GOOD               00040300
         LTR   R15,R15                                                  00040400
         BNP   SRCHUP                                                   00040500
LINSRCHA LH    R5,SYMBBASE                                              00040600
         B     LOOPCNTA                                                 00040700
SRCHUP   BCTR  R5,0           RETREAT 1 SYMBOL #                        00040800
         CH    R5,SAVFSYMB    DONT LEAVE CURRENT BLOCK                  00040900
         BL    LINSRCHA       TRY TO GO DOWN                            00041000
         LR    R0,R5          R0 = CURRENT SYMBOL #                     00041100
         SYMB2PTR             CONVERT TO A POINTER                      00041200
         CALL  LOCATE         LOCATE SYMBOL NODE                        00041300
         USING SYMBNODE,R1                                              00041400
         CLC   SRCHARG(8),SYMBNAME  SEE IF WE MATCH TO 8 CHARS          00041500
         BNE   LINSRCHA       TRY TO GO DOWN                            00041600
         LA    R15,CHKMATCH                                             00041700
         BALR  R14,R15                                                  00041800
         LTR   R15,R15                                                  00041900
         BP    LINSRCHA                                                 00042000
         B     SRCHUP                                                   00042100
SRCHDOWN LR    R0,R5          R0 = CURRENT SYMBOL #                     00042200
         SYMB2PTR             CONVERT TO A POINTER                      00042300
         CALL  LOCATE         LOCATE SYMBOL NODE                        00042400
         USING SYMBNODE,R1                                              00042500
         CLC   SRCHARG(8),SYMBNAME  SEE IF WE MATCH TO 8 CHARS          00042600
         BNE   NOSYMBOL                                                 00042700
         LA    R15,CHKMATCH                                             00042800
         BALR  R14,R15                                                  00042900
         LTR   R15,R15                                                  00043000
         BM    NOSYMBOL                                                 00043100
LOOPCNTA LA    R5,1(R5)       ADVANCE TO NEXT SYMBOL                    00043200
         CH    R5,SAVLSYMB    DONT LEAVE THE CURRENT BLOCK!             00043300
         BH    NOSYMBOL                                                 00043400
         B     SRCHDOWN                                                 00043500
*                                                                       00043600
*        WE HAVE A POSSIBLE MATCH                                       00043700
*                                                                       00043800
         USING SYMBNODE,R1                                              00043900
CHKMATCH ST    R14,SAVR14     SAVE THE RETURN ADDRESS (LOCATE CLOBBERS) 00044000
         MVC   NAMEBUF(8),SYMBNAME                                      00044100
         L     R1,SDCPTR      R1 = POINTER TO SYMBOL DATA CELL          00044200
         CALL  LOCATE         LOCATE SYMBOL DATA CELL                   00044300
         USING SYMBDC,R1                                                00044400
         L     R14,SAVR14     RESTORE THE RETURN ADDRESS                00044500
         SR    R2,R2          ZERO R2 FOR IC TO FOLLOW                  00044600
         IC    R2,SYMBNLEN    R2 = LENGTH OF SYMBOL NAME SOUGHT         00044700
         BCTR  R2,0           DECREMENT FOR EXECUTED CLC                00044800
         SR    R4,R4          ZERO R4 FOR IC TO FOLLOW                  00044900
         IC    R4,SYMBLEN     R4 = LENGTH OF SYMBOL NAME FOUND          00045000
         BCTR  R4,0           DECREMENT FOR EXECUTED CLC                00045100
         LR    R3,R4                                                    00045200
         SH    R4,=H'8'       R4 = LENGTH OF NAME CONTINUATION (-1)     00045300
         BM    CHKLEN                                                   00045400
         EX    R4,SMOVE2                                                00045500
         CR    R2,R3          SEE WHICH NAME IS SHORTER                 00045600
BRNCH    BH    USE3A                                                    00045700
         EX    R2,SCOMP                                                 00045800
         B     SYMBCOMM                                                 00045900
SCOMP    CLC   SYMBNAM(0),NAMEBUF                                       00046000
SMOVE2   MVC   NAMEBUF+8(0),NAMECONT                                    00046100
USE3A    EX    R3,SCOMP                                                 00046200
SYMBCOMM BE    MATCHA                                                   00046300
         BH    GODOWN                                                   00046400
GOUP     LH    R15,=H'-1'                                               00046500
         BR    R14                                                      00046600
GODOWN   LA    R15,1                                                    00046700
         BR    R14                                                      00046800
MATCHA   CR    R2,R3          WERE THE LENGTHS EQUAL?                   00046900
         BE    CHKTYPE                                                  00047000
         BH    GODOWN                                                   00047100
         B     GOUP                                                     00047200
CHKLEN   CR    R2,R3          LENGTH FOUND WAS <= 8. EQUAL?             00047300
         BNE   BRNCH                                                    00047400
CHKTYPE  CLI   FIRST,1        IF IN FIRST MODE, TAKE IT AND GO          00047500
         BE    SYMFOUND                                                 00047600
         CLI   CLASS,2                                                  00047610
         BNE   NOT2                                                     00047620
         CLI   TYPE,8                                                   00047630
         BE    SKIPIT         EQUATE EXTERNAL                           00047640
NOT2     CLI   CLASS,3        NO PROBLEMS IF CLASSES 1,2 OR 3           00047700
         BNH   SYMFOUND                                                 00047800
         TM    FLAG1,X'03'    IS IT AN UNQUALIFIED STRUC TERMINAL?      00047900
         BC    5,SYMFOUND     OR A TEMPLATE HEADER???                   00048000
SKIPIT   SR    R15,R15        ZERO R15 TO SHOW NO CHANGE OF DIRECTION   00048100
         BR    R14                                                      00048200
SYMFOUND STH   R5,SYMBNO      STORE SYMBOL INDEX IN COMMUNICATION AREA  00048300
         B     SETDISPS       APPLY DISPOSITION PARAMETERS              00048400
         DROP  R1                                                       00048500
*                                                                       00048600
NOSYMBOL MVI   RETCODE+3,20   INDICATE SYMBOL NOT FOUND                 00048700
         B     COMEXT                                                   00048800
*                                                                       00048900
SYMB     LH    R0,SYMBNO      PICK UP THE SYMBOL #                      00049000
         SYMB2PTR                                                       00049100
         CALL  LOCATE                                                   00049200
         CLI   MODE,16                                                  00049300
         BE    SETDISPS                                                 00049400
         USING SYMBNODE,R1                                              00049500
         MVC   SYMBNAM,BLANKS                                           00049600
         MVC   SYMBNAM(8),SYMBNAME                                      00049700
         L     R1,SDCPTR                                                00049800
         CALL  LOCATE                                                   00049900
         USING SYMBDC,R1                                                00050000
         LH    R2,BLOCKNUM                                              00050100
         STH   R2,BLKNO       STORE THE BLOCK #                         00050200
         SR    R2,R2                                                    00050300
         IC    R2,SYMBLEN                                               00050400
         STC   R2,SYMBNLEN                                              00050500
         CH    R2,=H'8'                                                 00050600
         BNH   COMPLETE                                                 00050700
         SH    R2,=H'9'                                                 00050800
         EX    R2,SMOVE                                                 00050900
COMPLETE L     R4,SYMBLEN     CR13079 - RELADDR IN LOWER HALFWORD IS
         CLI   MODE,18        CR13079 - FOR USE IN MODE 18 CALL
         BE    GETINIT        CR13079
         B     SETDISPS
SMOVE    MVC   SYMBNAM+8(0),NAMECONT                                    00051100
         DROP  R1                                                       00051200
*                                                                       00051300
FINDSRN  XC    STMTNO,STMTNO  ZERO STMT NUMBER IN CASE UNSUCCESSFUL     00051400
         L     R1,STMTEXPT    R1 = POINTER TO STMT EXTENT CELL          00051500
         LTR   R1,R1          ARE THERE SRNS IN THIS FILE?              00051600
         BNZ   SRNOK                                                    00051700
         MVI   RETCODE+3,28   FILE HAS NO SRNS                          00051800
         B     COMEXT                                                   00051900
SRNOK    TM    FLAGS,X'04'    ARE THE SRNS MONOTONIC?                   00052000
         BNO   SRNOK1                                                   00052100
         MVI   RETCODE+3,32   SRNS ARE NOT MONOTONIC!                   00052200
         B     COMEXT                                                   00052300
SRNOK1   LH    R0,FSTSTMT     R0 = 1ST STMT #                           00052400
         STH   R0,STMTBASE    SAVE THE VALUE                            00052500
*                                                                       00052600
*        STATEMENT NODE EXTENT CELL PROCESSING LOGIC                    00052700
*                                                                       00052800
EXTCELL1 CALL  LOCATE         LOCATE THE STMT NODE EXTENT CELL          00052900
         LR    R4,R1          R4 = ADDR OF FIXED PART OF CELL           00053000
         USING STMTEXTF,R4                                              00053100
         LH    R8,NXNTRY      R8 = # OF ENTRIES IN THE CELL             00053200
         LH    R2,FSTPAGE1    R2 = FIRST PAGE #                         00053300
         LA    R3,8(R4)       R3 = ADDR OF VARIABLE PART OF CELL        00053400
         USING STMTEXTV,R3                                              00053500
EXTLOOP1 CLC   FSTSRN(8),SREFNO                                         00053600
         BH    NOSTMT                                                   00053700
         CLC   LSTSRN(8),SREFNO                                         00053800
         BNL   THISPGE1                                                 00053900
*                                                                       00054000
*        CHECK THE NEXT ENTRY (IF ONE EXISTS)                           00054100
*                                                                       00054200
         LH    R1,LSTOFF1     R1 = LAST OFFSET ON PAGE                  00054300
         SH    R1,FSTOFF1                                               00054400
         SR    R0,R0          ZERO R0 FOR DIVIDE TO FOLLOW              00054500
         D     R0,=F'12'      DIVIDE BY SIZE OF STMT NODES              00054600
         AH    R1,STMTBASE    ADD ON THE BASE STATEMENT #               00054700
         LA    R1,1(R1)       ADD 1                                     00054800
         STH   R1,STMTBASE    UPDATE THE BASE STATEMENT #               00054900
         LA    R2,1(R2)       INCREMENT THE PAGE #                      00055000
         LA    R3,20(R3)      ADVANCE TO NEXT VARIABLE ENTRY            00055100
         BCT   R8,EXTLOOP1    LOOP AGAIN IF THERE ARE MORE              00055200
         L     R1,SUCCPTR1    R1 = POINTER TO NEXT EXTENT CELL          00055300
         LTR   R1,R1          ARE THERE MORE?                           00055400
         BZ    NOSTMT                                                   00055500
         B     EXTCELL1                                                 00055600
*                                                                       00055700
*        THE STATEMENT MUST BE ON THIS PAGE -- SET UP FOR SEARCH        00055800
*                                                                       00055900
THISPGE1 LH    R6,FSTOFF1     R6 = OFFSET ON PAGE TO 1ST SRN            00056000
         STH   R6,OFFBASE     SAVE THE OFFSET                           00056100
         LR    R5,R6                                                    00056200
         LH    R7,LSTOFF1     R7 = OFFSET ON PAGE TO LAST SRN           00056300
         LR    R1,R2          GET THE PAGE #                            00056400
         SLL   R1,16          MAKE IT INTO A POINTER                    00056500
         CALL  LOCATE         LOCATE THE PAGE                           00056600
         ST    R1,PAGEBASE    SAVE THE BASE ADDRESS                     00056700
*                                                                       00056800
*        BINARY SEARCH ALGORITHM FOR SRNS                               00056900
*                                                                       00057000
BINSRCH1 CR    R6,R7          SEE IF LOWER LIMIT > UPPER                00057100
         BH    NOSTMT                                                   00057200
         LR    R5,R6                                                    00057300
         AR    R5,R7                                                    00057400
         SR    R4,R4          ZERO R4 FOR DIVIDE TO FOLLOW              00057500
         D     R4,=F'24'                                                00057600
         MH    R5,=H'12'                                                00057700
         L     R1,PAGEBASE                                              00057800
         AR    R1,R5                                                    00057900
         USING STMTNOD1,R1                                              00058000
         CLC   SREFNO(8),SRN                                            00058100
         BE    SRNMATCH                                                 00058200
         BH    ADJSTLO1                                                 00058300
ADJSTHI1 LR    R7,R5                                                    00058400
         SH    R7,=H'12'                                                00058500
         B     BINSRCH1                                                 00058600
ADJSTLO1 LR    R6,R5                                                    00058700
         LA    R6,12(R6)                                                00058800
         B     BINSRCH1                                                 00058900
*                                                                       00059000
*        MATCH FOUND ON THE SRN SEARCH                                  00059100
*                                                                       00059200
SRNMATCH LR    R7,R5          SET R7 TO CURRENT OFFSET                  00059205
SRNLOOP  SH    R7,=H'12'      BACK UP ONE ENTRY                         00059210
         CH    R7,OFFBASE     ENSURE THAT WE DONT FALL OFF              00059215
         BL    SRNFOUND                                                 00059220
         L     R1,PAGEBASE    R1 = ADDR OF PAGE START                   00059225
         AR    R1,R7          ADD IN THE OFFSET                         00059230
         CLC   SREFNO(8),SRN  ARE THE SRNS STILL EQUAL?                 00059235
         BNE   SRNFOUND       GET OUT IF NOT                            00059240
         LR    R5,R7          THEY ARE EQUAL - UPDATE R5                00059245
         B     SRNLOOP        CONTINUE THE BACK SCAN                    00059250
SRNFOUND L     R1,PAGEBASE    RELOAD R1 SINCE WE MAY HAVE CLOBBERED IT  00059255
         AR    R1,R5                                                    00059260
         SH    R5,OFFBASE     R5 = CURRENT OFFSET - ORIGINAL            00059300
         SR    R4,R4          ZERO R4 FOR DIVIDE TO FOLLOW              00059400
         D     R4,=F'12'                                                00059500
         AH    R5,STMTBASE    R5 = CURRENT STATEMENT #                  00059600
         L     R1,STDCPTR1    R1 = POINTER TO STATEMENT DATA CELL       00059800
         LTR   R1,R1                                                    00059900
         BP    STMTCOMM                                                 00060000
         MVI   RETCODE+3,24   SRN MATCH BUT NOT EXECUTABLE              00060100
         LPR   R1,R1     IS IT A DECLARE STMT?                          00060101
         BNZ   STMTCOMM                                                 00060102
         B     COMEXT                                                   00060200
NOSTMT   MVI   RETCODE+3,20   NO SRN MATCH                              00060300
         B     COMEXT                                                   00060400
*                                                                       00060500
STMT     LH    R0,STMTNO      PICK UP THE STMT #                        00060600
         STMT2PTR                                                       00060700
         ST    R15,RETCODE    STORE THE RETURN CODE                     00060800
         LTR   R15,R15        SEE IF THE STMT # WAS LEGAL               00060900
         BNZ   COMEXT                                                   00061000
         CALL  LOCATE                                                   00061100
         TM    FLAGS,X'80'    ARE THERE SRNS?                           00061200
         BNO   NOSRNS                                                   00061300
         USING STMTNOD1,R1                                              00061400
         MVC   SREFNO(8),SRN                                            00061500
         L     R1,STDCPTR1                                              00061600
         B     COMMON                                                   00061700
         USING STMTNOD0,R1                                              00061800
NOSRNS   L     R1,STDCPTR                                               00061900
COMMON   CLI   MODE,17                                                  00062000
         BE    SETDISPS                                                 00062100
         LTR   R1,R1          IS THIS AN EXECUTABLE STMT?               00062200
         BP   EXECLBLE                                                  00062300
         MVI   RETCODE+3,24                                             00062400
         LPR   R1,R1   IS IT A DECLARE STMT?                            00062401
         BNZ   EXECLBLE                                                 00062402
         B     COMEXT                                                   00062500
STMTCOMM STH   R5,STMTNO      UPDATE STATEMENT # IN COMM AREA           00062600
EXECLBLE CALL  LOCATE                                                   00062700
         USING STMTDC,R1                                                00062800
         LH    R2,BNUM                                                  00062900
         STH   R2,BLKNO       STORE THE BLOCK #                         00063000
         B     SETDISPS       SET DISPOSITION PARMS                     00063100
         DROP  R1,R12                                                   00063200
INITDATA B     SYMB           CR13079 - GET SYMBOL RELADDR IN R4
GETINIT  L     R1,INITPTR     CR13079 - R1 = INITIAL DATA POINTER
         N     R4,=X'00FFFFFF' CR13079 - MASK TO GET RELADDR FIELD
         AR    R4,R4          CR13079 - MULTIPLY BY 2 FOR BYTE OFFSET
         LA    R6,1680        CR13079 - BLOCK SIZE FIXED AT 1680 BYTES
         CR    R6,R4          CR13079 - POINTER FORMAT OK?
         BH    DONE           CR13079 - OFFSET < PAGESIZE
         LR    R5,R4          CR13079 - R5 = OFFSET
         SR    R4,R4          CR13079 - OFFSET > PAGESIZE, CONVERT
         DR    R4,R6          CR13079 - R4 = OFFSET, R5 = PAGE# TO ADD
         SLL   R5,16          CR13079 - GET PAGE# IN UPPER HALFWORD
         AR    R1,R5          CR13079 - ADD IN PAGE#
DONE     AR    R1,R4          CR13079 - ADD IN OFFSET
         CALL  LOCATE         CR13079
         B     SETDISPS       CR13079
*                                                                       00063300
*        COMMON EXIT POINT IF DISPOSTION PARAMETERS ARE NOT TO BE SET   00063400
*                                                                       00063500
COMEXT   XC    ADDR,ADDR                                                00063600
COMEXTA  XC    PNTR,PNTR                                                00063700
         XC    ACURNTRY,ACURNTRY                                        00063800
         B     EXIT                                                     00063900
*                                                                       00064000
SETDISPS L     R12,ACURNTRY                                             00064100
         LTR   R12,R12                                                  00064200
         BZ    ABEND6                                                   00064300
         USING PDENTRY,R12                                              00064400
CHKMODF  TM    RETARG1,X'40'  SEE IF MODF                               00064500
         BNO   CHKRELS                                                  00064600
         CLI   MODFLAG,1      IS UPDAT MODE ACTIVE?                     00064700
         BNE   ABEND9                                                   00064800
         MVI   MODFIND,X'80'                                            00064900
CHKRELS  TM    RETARG1,X'20'  SEE IF RELS                               00065000
         BNO   CHKRESV                                                  00065100
         LH    R1,RESVCNT                                               00065200
         LTR   R1,R1                                                    00065300
         BZ    ABEND5                                                   00065400
         BCTR  R1,0                                                     00065500
         STH   R1,RESVCNT                                               00065600
         L     R1,RESERVES                                              00065700
         BCTR  R1,0                                                     00065800
         ST    R1,RESERVES                                              00065900
CHKRESV  TM    RETARG1,X'10'  SEE IF RESV                               00066000
         BNO   EXIT                                                     00066100
         LH    R1,RESVCNT                                               00066200
         CH    R1,=X'7FFF'                                              00066300
         BE    ABEND4                                                   00066400
         LA    R1,1(R1)                                                 00066500
         STH   R1,RESVCNT                                               00066600
         L     R1,RESERVES                                              00066700
         LA    R1,1(R1)                                                 00066800
         ST    R1,RESERVES                                              00066900
EXIT     MVC   RETARG1,ADDR                                             00067000
         MVC   CRETURN,RETCODE+2                                        00067100
         OSRETURN                                                       00067200
*                                                                       00067300
*        ABENDS                                                         00067400
*                                                                       00067500
ABEND1   LA    R1,4016        BAD SERVICE CODE                          00067600
         B     DOABEND                                                  00067700
ABEND2   LA    R1,4009        FIRST CALL TO SDFPKG NOT INIT             00067800
         B     DOABEND                                                  00067900
ABEND3   LA    R1,4017        MULTIPLE CALL TO INIT                     00068000
         B     DOABEND                                                  00068100
ABEND4   LA    R1,4003        TOO MANY RESERVES FOR ONE PAGE            00068200
         B     DOABEND                                                  00068300
ABEND5   LA    R1,4004        TOO MANY RELEASES FOR ONE PAGE            00068400
         B     DOABEND                                                  00068500
ABEND6   LA    R1,4014        SETDISPS CALLED BEFORE ANY LOCATES        00068600
         B     DOABEND                                                  00068700
ABEND7   LA    R1,4010        SELECT DEPENDENT ROUTINE CALLED AND       00068800
         B     DOABEND        SELECT WAS NOT CURRENTLY IN FORCE!        00068900
ABEND8   LA    R1,4020        BLOCK NOT PREVIOUSLY SPECIFIED            00069000
         B     DOABEND                                                  00069100
ABEND9   LA    R1,4008        MODF NOT LEGAL UNLESS UPDAT MODE          00069200
         B     DOABEND                                                  00069300
*                                                                       00069400
DOABEND  ABEND (R1),DUMP                                                00069500
*                                                                       00069600
*        DATA BASES                                                     00069700
*                                                                       00069800
         DS    0F                                                       00069900
ADCONS   EQU   *                                                        00070000
         DS    A              ADDRESS OF COMMUNICATION AREA             00070100
         DC    V(COMMDATA)                                              00070200
*                                                                       00070300
STMTBASE EQU   *              STARTING STATEMENT #                      00070400
SYMBBASE DS    H              STARTING SYMBOL #                         00070500
OFFBASE  DS    H              STARTING OFFSET                           00070600
*                                                                       00070700
         DS    0F                                                       00070800
SAVPTR   DS    F                                                        00070900
SAVR14   DS    F              SAVE LOCATION FOR REGISTER 14             00071000
PAGEBASE DS    A              BASE ADDRESS OF PAGE                      00071100
BLANKS   DC    32CL1' '                                                 00071200
*                                                                       00071300
*        NOTE:  THE VARIABLE NAMEBUF SHOULD IMMEDIATELY FOLLOW          00071400
*        SRCHARG SINCE UP TO 32 CHARACTERS ARE ACTUALLY DEPOSITED       00071500
*        INTO THIS 8 BYTE LOCATION!!                                    00071600
*                                                                       00071700
INITPTR  DS    A              CR13079 - INITIAL DATA PTR FROM ROOT CELL
SRCHARG  DS    CL8            SYMBOL NODE SEARCH ARGUMENT               00071800
NAMEBUF  DS    CL32           NAME FROM SYMBOL NODE AND DATA CELL       00071900
*                                                                       00072000
MODE     DS    CL1            SDFPKG MODE NUMBER                        00072100
         DATABUF                                                        00072200
         FCBCELL                                                        00072300
         COMMTABL                                                       00072400
         PDENTRY                                                        00072500
         PAGEZERO                                                       00072600
         DROOTCEL                                                       00072700
         SYMBDC                                                         00072800
         STMTDC                                                         00072900
         BLKTCELL                                                       00073000
         BLCKNODE                                                       00073100
         SYMBNODE                                                       00073200
         STMTNOD0                                                       00073300
         STMTNOD1                                                       00073400
         SYMEXTF                                                        00073500
         SYMEXTV                                                        00073600
         STMTEXTF                                                       00073700
         STMTEXTV                                                       00073800
         END                                                            00073900
