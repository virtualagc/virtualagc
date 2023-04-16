 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  INITIALIZE                                             */
 /* MEMBER NAME:     INITIALI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       #CELLS            BIT(16)            M                 BIT(16)    */
 /*       #INCL_CELLS       BIT(16)            NCLUDE            RECORD     */
 /*       #PAGES            BIT(16)            NDECSY            BIT(16)    */
 /*       #PAGES_PER_CELL   BIT(16)            NO_DELETIONS      LABEL      */
 /*       ADDR_TEMP         FIXED              NO_PURGE          LABEL      */
 /*       BASE_PTR          FIXED              NODE_B            BIT(8)     */
 /*       BLK_DEX1          BIT(16)            NODE_F            FIXED      */
 /*       BLK_DEX2          BIT(16)            NODE_H            BIT(16)    */
 /*       BLOCK_SUB         LABEL              OFFSET            BIT(16)    */
 /*       BTEMP             BIT(8)             OLD_SDF_INCLUDE_PTR  FIXED   */
 /*       BUILD_BLOCK_TABLES  LABEL            PAGE              BIT(16)    */
 /*       CARDTYPE          CHARACTER          PROCPOINT         BIT(16)    */
 /*       CELLSIZE          BIT(16)            PTR               FIXED      */
 /*       CHECK_COMP_UNIT_NAME  LABEL          PTR_TEMP          FIXED      */
 /*       CUR_PTR           FIXED              PTR_TEMP1         FIXED      */
 /*       DIR_SIZE          FIXED              SAVE_I            BIT(16)    */
 /*       DPRINT            LABEL              SAVELIMIT         FIXED      */
 /*       END_SCAN          LABEL              SDF_INCLUDE_PTR   FIXED      */
 /*       EXCHANGES         BIT(8)             SRN_ADDR          FIXED      */
 /*       FILE_SIZE         FIXED              STACK_ID          BIT(16)    */
 /*       FTEMP             FIXED              START_PAGE        BIT(16)    */
 /*       GET_CODE_HWM      LABEL              STRING_BASE       FIXED      */
 /*       GOT_DEX           LABEL              STRING_I          CHARACTER  */
 /*       I                 BIT(16)            STRING_J          CHARACTER  */
 /*       INCL_COUNT(1)     MACRO              SYMB_SUB          LABEL      */
 /*       INCL_INX          BIT(16)            SYT_DUMP          LABEL      */
 /*       INCL_NAME(1)      MACRO              TASK#             BIT(16)    */
 /*       INCL_PTR(1)       MACRO              TEMP1             FIXED      */
 /*       INCL_SORT(1)      MACRO              TEMP2             FIXED      */
 /*       INVALID_SYMBOL    LABEL              TEMP3             FIXED      */
 /*       J                 BIT(16)            TEMP4             FIXED      */
 /*       K                 BIT(16)            TITLE             CHARACTER  */
 /*       KI                BIT(16)            TRAVERSE          LABEL      */
 /*       KL                BIT(16)            TS(1)             CHARACTER  */
 /*       L                 BIT(16)            USED              LABEL      */
 /*       LEN               BIT(16)            VAR_CLASS         LABEL      */
 /*       LMX               LABEL              VMEM_INCLUDE_PTR  FIXED      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       #EXECS                               SYM_ARRAY                    */
 /*                                            SYM_CLASS                    */
 /*       ACCESS_FLAG                          SYM_FLAGS                    */
 /*       ACTUAL_SYMBOLS                       SYM_LENGTH                   */
 /*       BITMASK_FLAG                         SYM_LINK1                    */
 /*       BLOCK_NODE_SIZE                      SYM_LINK2                    */
 /*       BLOCK_SRN_DATA                       SYM_LOCK#                    */
 /*       CODEHWM_HEAD                         SYM_NAME                     */
 /*       COMMON_ERROR                         SYM_NEST                     */
 /*       COMPOOL_LABEL                        SYM_NUM                      */
 /*       COMSUB_END                           SYM_PTR                      */
 /*       CR_REF                               SYM_SCOPE                    */
 /*       CROSS_REF                            SYM_SORT1                    */
 /*       DATA_REMOTE                          SYM_SORT2                    */
 /*       DEL_TAB                              SYM_SORT3                    */
 /*       DIR_ALOC_SZ                          SYM_SORT4                    */
 /*       DIR_MARGIN                           SYM_SORT5                    */
 /*       EMITTED_CNT                          SYM_TYPE                     */
 /*       EQUATE_FLAG                          SYM_VPTR                     */
 /*       EXCLUSIVE_FLAG                       SYM_XREF                     */
 /*       EXTERNAL_FLAG                        SYMB_NODE_SIZE               */
 /*       FALSE                                SYT_ADDR                     */
 /*       FC                                   SYT_ARRAY                    */
 /*       FIRST_STMT                           SYT_CLASS                    */
 /*       FOREVER                              SYT_DIMS                     */
 /*       HWMCELL                              SYT_FLAGS                    */
 /*       IGNORE_FLAG                          SYT_LINK1                    */
 /*       IMPL_T_FLAG                          SYT_LINK2                    */
 /*       INCLUDE_LIST_HEAD                    SYT_LOCK#                    */
 /*       LABEL_CLASS                          SYT_NAME                     */
 /*       LENGTH                               SYT_NEST                     */
 /*       LIM_PAGE                             SYT_NUM                      */
 /*       LIT_CHAR_USED                        SYT_PTR                      */
 /*       LIT_TOP                              SYT_SCOPE                    */
 /*       LOC_ADDR                             SYT_SORT1                    */
 /*       MACRO_BYTES                          SYT_SORT2                    */
 /*       MACRO_USED                           SYT_SORT3                    */
 /*       MAX_CELL                             SYT_SORT4                    */
 /*       MAX_SCOPE#                           SYT_SORT5                    */
 /*       MODF                                 SYT_TYPE                     */
 /*       NAME_FLAG                            SYT_VPTR                     */
 /*       NEXT_CELL_PTR                        SYT_VPTR_FLAG                */
 /*       NO_CORE                              SYT_XREF                     */
 /*       NONHAL_FLAG                          TAB_DEL                      */
 /*       OBJECT_MACHINE                       TOTAL_HMAT_BYTES             */
 /*       OPTIONS_CODE                         TRUE                         */
 /*       PAGE_SIZE                            UNMOVEABLE                   */
 /*       PGAREA                               VALS                         */
 /*       PROC_MAX                             VAR_EXTENT                   */
 /*       P3ERR                                VERSION#                     */
 /*       REENTRANT_FLAG                       VMEM_LOC_ADDR                */
 /*       RELS                                 XREF_USED                    */
 /*       REPL_ARG_CLASS                       XREF                         */
 /*       RESV                                 XREF_MASK                    */
 /*       RIGID_FLAG                           XTNT                         */
 /*       ROOT_DIR_SZ                          X1                           */
 /*       SDF_SIZE                             X2                           */
 /*       SRN_BLOCK_RECORD                     X3                           */
 /*       STMT_NUM                             X4                           */
 /*       STRUC_NEST                           X52                          */
 /*       STRUCTURE                            X6                           */
 /*       SYM_ADDR                             X72                          */
 /*       SYM_ADD                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       #_BLOCK_BYTES                        LAST_SYMB_PTR                */
 /*       #_STMT_BYTES                         MAX_PAGE                     */
 /*       #_SYMB_BYTES                         MAX_PAGE_PRED                */
 /*       #COMPOOLS                            NOTRACE_FLAG                 */
 /*       #DEL_SYMBOLS                         OLD_INT_BLOCK#               */
 /*       #DEL_TPLS                            OP1                          */
 /*       #EXTERNALS                           OP2                          */
 /*       #PROCS                               OP3                          */
 /*       #STMTS                               OP4                          */
 /*       #SYMBOLS                             PAD_ADDR                     */
 /*       #TPLS1                               PAD_PAGE                     */
 /*       #TPLS2                               PAGE_TO_LREC                 */
 /*       ADDR_FLAG                            PAGE_TO_NDX                  */
 /*       BASE_BLOCK_OFFSET                    PGAREA_LIMIT                 */
 /*       BASE_BLOCK_PAGE                      PRINTLINE                    */
 /*       BASE_STMT_OFFSET                     PROC_TAB1                    */
 /*       BASE_STMT_PAGE                       PROC_TAB2                    */
 /*       BASE_SYMB_OFFSET                     PROC_TAB3                    */
 /*       BASE_SYMB_PAGE                       PROC_TAB4                    */
 /*       BIAS                                 PROC_TAB5                    */
 /*       BLOCK_NODES_PER_PAGE                 PROC_TAB6                    */
 /*       CLOCK                                PROC_TAB7                    */
 /*       COMM                                 PROC_TAB8                    */
 /*       COMPOOL_FLAG                         PSEUDO_TPL_FLAG              */
 /*       DEBUG                                REF_STMT                     */
 /*       DLIST                                ROOT_PTR                     */
 /*       FCDATA_FLAG                          SAVE_NDECSY                  */
 /*       FIRST_BLOCK_PTR                      SDF_SUMMARY                  */
 /*       FIRST_DATA_PAGE                      SDL_FLAG                     */
 /*       FIRST_DATA_PTR                       SELFNAMELOC                  */
 /*       FIRST_FREE_PAGE                      SORTING                      */
 /*       FIRST_FREE_PTR                       SRN_FLAG                     */
 /*       FIRST_STMT_PTR                       STMT_NODE_SIZE               */
 /*       FIRST_SYMB_PTR                       STMT_NODES_PER_PAGE          */
 /*       FREE_CHAIN                           STRING_MARGIN                */
 /*       HEX_DUMP_FLAG                        SYM_TAB                      */
 /*       HMAT_OPT                             SYMB_NODES_PER_PAGE          */
 /*       K#PROCS                              SYT_SIZE                     */
 /*       LAST_BLOCK_PTR                       TMP                          */
 /*       LAST_DIR_PAGE                        TPL_STACK                    */
 /*       LAST_DIR_PTR                         TPL_TAB1                     */
 /*       LAST_STMT                            TPL_TAB2                     */
 /*       LAST_STMT_PTR                        UNIT_ID                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       BLOCK_TO_PTR                         PAD                          */
 /*       CSECT_NAME                           PTR_FIX                      */
 /*       FORMAT                               PTR_LOCATE                   */
 /*       GET_CELL                             PUTN                         */
 /*       GET_DATA_CELL                        P3_DISP                      */
 /*       GET_DIR_CELL                         P3_LOCATE                    */
 /*       HEX                                  P3_PTR_LOCATE                */
 /*       HEX8                                 STMT_TO_PTR                  */
 /*       LOCATE                               SYMB_TO_PTR                  */
 /*       MOVE                                 ZERON                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INITIALIZE <==                                                      */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /*     ==> HEX8                                                            */
 /*     ==> MOVE                                                            */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> LOCATE                                                          */
 /*     ==> CSECT_NAME                                                      */
 /*         ==> CHAR_INDEX                                                  */
 /*     ==> PAD                                                             */
 /*     ==> PTR_FIX                                                         */
 /*     ==> STMT_TO_PTR                                                     */
 /*     ==> SYMB_TO_PTR                                                     */
 /*     ==> BLOCK_TO_PTR                                                    */
 /*     ==> P3_DISP                                                         */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /*     ==> P3_LOCATE                                                       */
 /*         ==> P3_PTR_LOCATE ****                                          */
 /*     ==> PUTN                                                            */
 /*         ==> MOVE                                                        */
 /*         ==> P3_PTR_LOCATE ****                                          */
 /*     ==> ZERON                                                           */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_PTR_LOCATE ****                                          */
 /*     ==> GET_DIR_CELL                                                    */
 /*         ==> P3_GET_CELL                                                 */
 /*             ==> P3_DISP                                                 */
 /*             ==> P3_LOCATE                                               */
 /*                 ==> P3_PTR_LOCATE ****                                  */
 /*             ==> PUTN ****                                               */
 /*     ==> GET_DATA_CELL                                                   */
 /*         ==> P3_GET_CELL ****                                            */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*10/05/90 RPC   23V1  102963 PHASE 3 INTERNAL ERROR                       */
 /*                                                                         */
 /*01/21/91 DKB   23V2  CR11098 DELETE SPILL CODE FROM COMPILER             */
 /*                                                                         */
 /*03/07/91 DKB   23V2  CR11109 CLEAN UP OF COMPILER SOURCE CODE            */
 /*                                                                         */
 /*04/09/91 RSJ   24V0  CR11096 SET DATA_REMOTE FIELD IN THE SDF HEADER     */
 /*                             FOR #D COMPILATIONS                         */
 /*                                                                         */
 /*06/20/91 DKB   7V0   CR11114 MERGE BFS/PASS COMPILERS WITH DR FIXES      */
 /*                                                                         */
 /*12/23/92 PMA   8V0   *       MERGE 7V0 AND 24V0 COMPILERS.               */
 /*                             * REFERENCE 24V0 CR/DRS                     */
 /*                                                                         */
 /*04/06/94 JAC  26V0   D108643 INCORRECTLY LISTS 'NONHAL' INSTEAD OF       */
 /*              10V0           'INCREM' IN SDFLIST                         */
 /*                                                                         */
 /* 03/15/95 DAS  27V0  DR103787 WRONG VALUE LOADED FROM REGISTER FOR A     */  01520000
 /*               11V0           STRUCTURE NODE REFERENCE                   */  01530000
 /*                                                                         */  01540000
 /* 06/04/99 SMR  30V0  CR13079  ADD HAL/S INITIALIZATION DATA TO SDF       */
 /*               15V0                                                      */
 /*                                                                         */
 /* 03/02/04 DCP  32V0  CR13811  ELIMINATE STACK WALKBACK CAPABILITY        */
 /*               17V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00299700
 /* SUBROUTINE FOR SYMBOL TABLE PRE-PROCESSING  */                              00299800
INITIALIZE:                                                                     00299900
   PROCEDURE;                                                                   00300000
      DECLARE  (PTR,ADDR_TEMP,DIR_SIZE,PTR_TEMP,BASE_PTR,CUR_PTR) FIXED,        00300100
         (PTR_TEMP1) FIXED,                                                     00300105
         (FILE_SIZE,TEMP1,TEMP2,TEMP3,TEMP4,FTEMP) FIXED,                       00300200
         (VMEM_INCLUDE_PTR,SDF_INCLUDE_PTR) FIXED,                              00300210
         (OLD_SDF_INCLUDE_PTR,SAVELIMIT,STRING_BASE) FIXED,                     00300220
         (STRING_I,STRING_J) CHARACTER,                                         00300230
         SRN_ADDR FIXED,                                                        00300240
         (SAVE_I,#INCL_CELLS,INCL_INX,CELLSIZE) BIT(16),                        00300250
         (I,PAGE,OFFSET,#CELLS,#PAGES,#PAGES_PER_CELL) BIT(16),                 00300300
         (STACK_ID,PROCPOINT,NDECSY,J,K,L,M,KL,KI) BIT(16),                     00300400
         (TITLE,CARDTYPE) CHARACTER,                                            00300700
         (START_PAGE,LEN,BLK_DEX1,BLK_DEX2,TASK#) BIT(16),                      00300800
         (BTEMP) BIT(8),                                                        00300900
         (EXCHANGES) BIT(1);                                                    00301000
      BASED    NODE_B BIT(8),                                                   00301100
         NODE_H BIT(16),                                                        00301200
         NODE_F FIXED;                                                          00301300
      BASED NCLUDE RECORD:                                                      00301310
            NAME_INCL      FIXED,                                               00301311
            NAME2          FIXED,                                               00301312
            PTR_INCL       FIXED,                                               00301313
            SORT_INCL      BIT(16),                                             00301314
            COUNT_INCL     BIT(8),                                              00301315
         END;                                                                   00301316
      DECLARE  INCL_NAME(1) LITERALLY 'NCLUDE(%1%).NAME_INCL',                  00301317
         INCL_PTR(1) LITERALLY 'NCLUDE(%1%).PTR_INCL',                          00301318
         INCL_SORT(1) LITERALLY 'NCLUDE(%1%).SORT_INCL',                        00301319
         INCL_COUNT(1) LITERALLY 'NCLUDE(%1%).COUNT_INCL';                      00301320
      DECLARE TS(1) CHARACTER;                                                  00301400
                                                                                00301500
SYT_DUMP:                                                                       00301600
      PROCEDURE;                                                                00301700
         DECLARE (TS,S1,S2,S3,S4) CHARACTER;                                    00301800
         OUTPUT(1) = '1';                                                       00301900
         OUTPUT = X1;                                                           00302000
       OUTPUT ='SYT#            SYT_NAME                CL  TP  SCP  NST   PTR  00302100
LNK1  LNK2  DIMS  XREF  ARRA    FLAGS    ADDR     LK';                          00302200
         OUTPUT = X1;                                                           00302300
         DO OP1 = 1 TO 16384;                                                   00302400
            IF SYT_CLASS(OP1) = 0 THEN DO;                                      00302500
               OUTPUT(1) = '1';                                                 00302600
               RETURN;                                                          00302700
            END;                                                                00302800
            S1 = SYT_NAME(OP1);                                                 00302900
            TMP = LENGTH(S1);                                                   00303000
            IF TMP < 32 THEN S1 = S1||SUBSTR(X72,0,32-TMP);                     00303100
            S2 = FORMAT(OP1,4);                                                 00303200
            S3 = HEX(SYT_CLASS(OP1),2);                                         00303300
            S4 = HEX(SYT_TYPE(OP1),2);                                          00303400
            TS = S2||X2||S1||X2||S3||X2||S4||X2;                                00303500
            S1 = FORMAT(SYT_SCOPE(OP1),3);                                      00303600
            S2 = FORMAT(SYT_NEST(OP1),3);                                       00303700
            S3 = FORMAT(SYT_PTR(OP1),4);                                        00303800
            S4 = FORMAT(SYT_LINK1(OP1),4);                                      00303900
            TS = TS||S1||X2||S2||X2||S3||X2||S4||X2;                            00304000
            S1 = FORMAT(SYT_LINK2(OP1),4);                                      00304100
            S2 = HEX(SYT_DIMS(OP1),4);                                          00304200
            S3 = FORMAT(SYT_XREF(OP1),4);                                       00304300
            S4 = FORMAT(SYT_ARRAY(OP1),4);                                      00304400
            TS = TS||S1||X2||S2||X2||S3||X2||S4||X2;                            00304500
            S1 = HEX8(SYT_FLAGS(OP1));                                          00304600
            S2 = HEX8(SYT_ADDR(OP1));                                           00304700
            S3 = HEX(SYT_LOCK#(OP1),2);                                         00304800
            OUTPUT = TS||S1||X2||S2||X2||S3;                                    00304900
         END;                                                                   00305000
      END SYT_DUMP;                                                             00305100
                                                                                00305200
 /* PHASE 3 INITIALIZATION CODE */                                              00305300
                                                                                00305400
USED:                                                                           00305500
      PROCEDURE BIT(1);                                                         00305600
         OP4 = SYT_XREF(OP1);                                                   00305700
         DO WHILE OP4 ^= 0;                                                     00305800
            TMP = XREF(OP4)&"FFFF";                                             00305900
            IF ((TMP&XREF_MASK)^=0)&((TMP&"1FFF")>=REF_STMT) THEN               00306000
               RETURN TRUE;                                                     00306100
            OP4 = SHR(XREF(OP4),16);                                            00306200
         END;                                                                   00306300
         RETURN FALSE;                                                          00306400
      END USED;                                                                 00306500
GET_CODE_HWM:PROCEDURE BIT(16);                                                 00306505
         DECLARE CELL_PTR FIXED;                                                00306510
         DECLARE C CHARACTER;                                                   00306515
         CELL_PTR = CODEHWM_HEAD;                                               00306520
         DO WHILE CELL_PTR ^= -1;                                               00306525
            CALL LOCATE(CELL_PTR,ADDR(HWMCELL),0);                              00306530
            COREWORD(ADDR(C)) = "0700 0000" | (VMEM_LOC_ADDR +6);               00306535
            IF TS = C                                                           00306540
               THEN RETURN HWMCELL.LENGTH;                                      00306545
            CELL_PTR = HWMCELL.NEXT_CELL_PTR;                                   00306550
         END;                                                                   00306555
         RETURN 0;                                                              00306560
      END GET_CODE_HWM;                                                         00306565
                                                                                00306600
INVALID_SYMBOL:                                                                 00306700
      PROCEDURE;                                                                00306800
         #DEL_SYMBOLS = #DEL_SYMBOLS + 1;                                       00306900
         DEL_TAB(#DEL_SYMBOLS) = OP2;                                           00307000
         PROC_TAB3(PROCPOINT) = PROC_TAB3(PROCPOINT) - 1;                       00307100
         SYT_NAME(OP1) = '';                                                    00307200
      END INVALID_SYMBOL;                                                       00307400
                                                                                00307500
SYMB_SUB:                                                                       00307600
      PROCEDURE;                                                                00307700
         #SYMBOLS = #SYMBOLS + 1;                                               00307800
         IF PROC_TAB2(PROCPOINT) = 0 THEN PROC_TAB2(PROCPOINT) = OP2;           00307900
         PROC_TAB3(PROCPOINT) = PROC_TAB3(PROCPOINT) + 1;                       00308000
      END SYMB_SUB;                                                             00308200
                                                                                00308300
BLOCK_SUB:                                                                      00308400
      PROCEDURE;                                                                00308500
         IF (SYT_FLAGS(OP1)&NAME_FLAG) ^= 0 THEN GO TO NO_BLOCK;                00308600
         IF (SYT_FLAGS(OP1)&EXTERNAL_FLAG)^=0 THEN #EXTERNALS = #EXTERNALS + 1; 00308700
         PROC_TAB1(PROCPOINT) = OP2;                                            00308800
         #PROCS = #PROCS + 1;                                                   00308900
         IF #PROCS > PROC_MAX THEN DO;                                          00309000
            OUTPUT = X1;                                                        00309100
            OUTPUT = P3ERR || 'BLOCK TABLE LIMIT EXCEEDED ***';                 00309200
            GO TO COMMON_ERROR;                                                 00309300
         END;                                                                   00309400
NO_BLOCK:                                                                       00309500
         CALL SYMB_SUB;                                                         00309600
      END BLOCK_SUB;                                                            00309800
                                                                                00309900
 /* THE TRAVERSE ROUTINE TRAVERSES A STRUCTURE AND ENSURES THAT */              00310000
 /* ALL TEMPLATES ENCOUNTERED ARE PROTECTED FROM DELETION       */              00310100
                                                                                00310200
TRAVERSE:                                                                       00310300
      PROCEDURE;                                                                00310400
         DECLARE (TEMP,I,LINK,STACK_INX) BIT(16);                               00310500
         LINK = OP1;                                                            00310600
         STACK_INX = 0;                                                         00310800
         IF PSEUDO_TPL_FLAG THEN DO;                                            00310802
            TEMP = LINK;                                                        00310804
            GO TO ALT_ENTRY;                                                    00310806
         END;                                                                   00310808
         ELSE SYT_LINK1(LINK) = 0;                                              00310810
         DO FOREVER;                                                            00310900
            IF SYT_LINK1(LINK) ^= 0 THEN                                        00311000
               LINK = SYT_LINK1(LINK);                                          00311100
            ELSE IF SYT_TYPE(LINK) = STRUCTURE THEN DO;                         00311200
               TEMP = SYT_DIMS(LINK);                                           00311300
ALT_ENTRY:                                                                      00311302
               DO I = 0 TO #TPLS2 - 1;                                          00311400
                  IF TPL_TAB2(I) = TEMP THEN DO;                                00311500
                     IF STACK_INX = 0 THEN RETURN;                              00311600
                     ELSE GO TO BROTHER;                                        00311700
                  END;                                                          00311800
               END;                                                             00311900
               TPL_STACK(STACK_INX) = LINK;                                     00312000
               STACK_INX = STACK_INX + 1;                                       00312100
               IF STACK_INX > STRUC_NEST THEN DO;                               00312200
                  OUTPUT = X1;                                                  00312300
               OUTPUT = P3ERR || 'STRUCTURE TRAVERSAL STACK LIMIT EXCEEDED ***';00312400
                  OUTPUT = X1;                                                  00312500
                  OUTPUT = '  TPL_STACK CONTENTS:';                             00312600
                  OUTPUT = X1;                                                  00312700
                  DO I = 0 TO STRUC_NEST;                                       00312800
                     OUTPUT = I || X3 || TPL_STACK(I) || X3 ||                  00312900
                        SYT_NAME(TPL_STACK(I));                                 00313000
                  END;                                                          00313100
                  GO TO COMMON_ERROR;                                           00313200
               END;                                                             00313300
               LINK = TEMP;                                                     00313400
               TPL_TAB2(#TPLS2) = LINK;                                         00313500
               #TPLS2 = #TPLS2 + 1;                                             00313600
            END;                                                                00313700
            ELSE DO;                                                            00313800
BROTHER:                                                                        00313900
               LINK = SYT_LINK2(LINK);                                          00314000
               DO WHILE LINK < 0;                                               00314100
                  LINK = SYT_LINK2(-LINK);                                      00314200
               END;                                                             00314300
            END;                                                                00314400
            DO WHILE LINK = 0;                                                  00314500
               IF STACK_INX = 1 THEN RETURN;                                    00314600
               ELSE DO;                                                         00314700
                  STACK_INX = STACK_INX - 1;                                    00314800
                  LINK = SYT_LINK2(TPL_STACK(STACK_INX));                       00314900
                  DO WHILE LINK < 0;                                            00315000
                     LINK = SYT_LINK2(-LINK);                                   00315100
                  END;                                                          00315200
               END;                                                             00315300
            END;                                                                00315400
         END;                                                                   00315500
      END TRAVERSE;                                                             00315600
                                                                                00315700
BUILD_BLOCK_TABLES:                                                             00315800
      PROCEDURE;                                                                00315900
         DECLARE FIRST_CALL BIT(16) INITIAL(1);                                 00315910
         #SYMBOLS, #PROCS, #COMPOOLS, #EXTERNALS = 0;                           00316000
         DO OP2 = 1 TO NDECSY;                                                  00316100
            OP1 = SYT_SORT2(OP2);                                               00316200
            PROCPOINT = SYT_SCOPE(OP1);                                         00316300
            DO CASE SYT_CLASS(OP1);                                             00316700
               DO;            /* SCAN COMPLETED */                              00316800
               END;                                                             00316900
               DO;            /* VARIABLE CLASS */                              00317000
                  CALL SYMB_SUB;                                                00317100
               END;                                                             00317200
               DO;            /* LABEL CLASS */                                 00317300
                  DO CASE SYT_TYPE(OP1) & "F";                                  00317400
                     DO;      /* MB STMT LABEL */                               00317500
                        CALL SYMB_SUB;                                          00317600
                     END;                                                       00317700
                     DO;      /* IND STMT LABEL */                              00317800
                        CALL SYMB_SUB;                                          00317900
                     END;                                                       00318000
                     DO;      /* STATEMENT LABEL */                             00318100
                        IF (SYT_DIMS(OP1) = 1)|(SYT_DIMS(OP1) = 2) THEN         00318200
                           CALL BLOCK_SUB;                                      00318300
                        ELSE CALL SYMB_SUB;                                     00318400
                     END;                                                       00318500
                     DO;      /* UNSPEC LABEL */                                00318600
                        CALL SYMB_SUB;                                          00318700
                     END;                                                       00318800
                     DO;      /* MB CALL LABEL */                               00318900
                        CALL SYMB_SUB;                                          00319000
                     END;                                                       00319100
                     DO;      /* IND CALL LABEL */                              00319200
                        CALL SYMB_SUB;                                          00319300
                     END;                                                       00319400
                     DO;      /* CALLED LABEL */                                00319500
                        CALL SYMB_SUB;                                          00319600
                     END;                                                       00319700
                     DO;      /* PROCEDURE LABEL */                             00319800
                        CALL BLOCK_SUB;                                         00319900
                     END;                                                       00320000
                     DO;      /* TASK LABEL */                                  00320100
                        CALL BLOCK_SUB;                                         00320200
                     END;                                                       00320300
                     DO;      /* PROGRAM LABEL */                               00320400
                        CALL BLOCK_SUB;                                         00320500
                     END;                                                       00320600
                     DO;      /* COMPOOL LABEL */                               00320700
                        CALL BLOCK_SUB;                                         00320800
                        IF (SYT_FLAGS(OP1)&EXTERNAL_FLAG)^=0 THEN               00320900
                           #COMPOOLS = #COMPOOLS + 1;                           00321000
                     END;                                                       00321100
                     DO;      /* EQUATE LABEL */                                00321200
                        SYT_FLAGS(SYT_PTR(OP1)) = SYT_FLAGS(SYT_PTR(OP1))|      00321300
                           EQUATE_FLAG;                                         00321400
                        CALL SYMB_SUB;                                          00321500
                     END;                                                       00321600
                  END;                                                          00321700
               END;                                                             00321800
               DO;            /* FUNCTION */                                    00321900
                  CALL BLOCK_SUB;                                               00322000
               END;                                                             00322100
               DO;            /* UNUSED */                                      00322200
                  CALL SYMB_SUB;                                                00322300
               END;                                                             00322400
               DO;            /* REPL_ARG_CLASS */                              00322500
                  CALL SYMB_SUB;                                                00322600
               END;                                                             00322700
               DO;            /* REPL CLASS */                                  00322800
                  CALL SYMB_SUB;                                                00322900
                  IF FIRST_CALL THEN IF (VAR_EXTENT(OP1) & "80000000") ^= 0 THEN00322902
                   IF (XREF(SYT_XREF(OP1)) & "1FFF") >= REF_STMT | USED THEN DO;00322904
                     PTR_TEMP = VAR_EXTENT(OP1) & "7FFFFFFF";                   00322906
                     I = OP1 + 1;                                               00322908
                     IF SYT_CLASS(I) = REPL_ARG_CLASS THEN DO;                  00322910
                        J = 0;                                                  00322912
                        CELLSIZE = 12;                                          00322914
                        CALL PTR_LOCATE(PTR_TEMP,RESV);                         00322916
                        ADDR_TEMP = VMEM_LOC_ADDR;                              00322918
                        DO WHILE SYT_CLASS(I) = REPL_ARG_CLASS;                 00322920
                           J = J + 1;                                           00322922
                           CELLSIZE = CELLSIZE+LENGTH(SYT_NAME(I))+4;           00322924
                           I = I + 1;                                           00322926
                        END;                                                    00322928
                        PTR = GET_CELL(CELLSIZE,ADDR(NODE_F),0);                00322930
                        CALL MOVE(8,ADDR_TEMP,VMEM_LOC_ADDR);                   00322932
                        NODE_F(2) = CELLSIZE;                                   00322934
                        OFFSET = SHL(J+2,2);                                    00322936
                        DO I = OP1+1 TO OP1+J;                                  00322938
                           LEN = LENGTH(SYT_NAME(I));                           00322940
                           NODE_F(I-OP1+2)=SHL(LEN-1,24)+OFFSET;                00322942
                           CALL MOVE(LEN,SYT_NAME(I),VMEM_LOC_ADDR+OFFSET+4);   00322944
                           OFFSET = OFFSET + LEN;                               00322946
                        END;                                                    00322948
                        COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;                 00322950
                        NODE_H(2) = -(J+1);                                     00322952
                        CALL PTR_LOCATE(PTR_TEMP,RELS);                         00322954
                        VAR_EXTENT(OP1) = PTR | "80000000";                     00322956
                     END;                                                       00322958
                  END;                                                          00322960
               END;                                                             00323000
               DO;            /* TEMPLATE CLASS */                              00323100
                  CALL SYMB_SUB;                                                00323200
               END;                                                             00323300
               DO;            /* TPL_LAB_CLASS */                               00323400
                  CALL SYMB_SUB;                                                00323500
               END;                                                             00323600
               DO;            /* TPL_FUNC_CLASS */                              00323700
                  CALL SYMB_SUB;                                                00323800
               END;                                                             00323900
            END;                                                                00324000
         END;                                                                   00324100
         FIRST_CALL = 0;                                                        00324110
      END BUILD_BLOCK_TABLES;                                                   00324300
                                                                                00324400
CHECK_COMP_UNIT_NAME:                                                           00324500
      PROCEDURE;                                                                00324600
 /**********************  DR102963  BOB CHEREWATY  *****************/
 /* ONLY ADD A NEW SCOPE WHEN THE SYMBOL IS ACTUALLY A PROGRAM     */           00178900
 /* LABEL AND NOT A NAME VARIABLE OF A PROGRAM. THE NONHAL FLAG    */           00179000
 /* IS ALSO USED AS THE INCLUDED_REMOTE FLAG AND MAY BE SET FOR    */           00179100
 /* VARIABLES OTHER THAN LABELS.                                   */           00179200
         IF ((SYT_FLAGS2(OP1) & NONHAL_FLAG) ^= 0) &   /* DR108643 */           00179300
            (NAME_FLAG = 0) THEN DO;                                            00179400
 /**********************  DR102963  END  ***************************/

            MAX_SCOPE# = MAX_SCOPE# + 1;                                        00324702
            SYT_SCOPE(OP1) = MAX_SCOPE#;                                        00324704
         END;                                                                   00324706
         IF SELFNAMELOC = 0 THEN DO;                                            00324900
            IF (SYT_FLAGS(OP1) & "10100000") = 0 THEN DO;                       00325000
               SELFNAMELOC = OP1;                                               00325100
               REF_STMT = XREF(SYT_XREF(OP1))&"1FFF";                           00325200
               IF SYT_TYPE(OP1) = COMPOOL_LABEL THEN COMPOOL_FLAG = TRUE;       00325300
            END;                                                                00325400
            ELSE IF (SYT_FLAGS(OP1) & NAME_FLAG) = 0 THEN                       00325410
               SYT_FLAGS(OP1) = SYT_FLAGS(OP1) & "FFFFE7FF";                    00325420
         END;                                                                   00325500
      END CHECK_COMP_UNIT_NAME;                                                 00325700
                                                                                00325800
DPRINT:                                                                         00327500
      PROCEDURE(REASON#);                                                       00327600
         DECLARE (REASON#,K) BIT(16),                                           00327700
            HDR_FLAG BIT(1);                                                    00327800
         DECLARE (S1,S2,S3,S4) CHARACTER;                                       00327900
         DECLARE REASONS(17) CHARACTER INITIAL(                                 00328000
            'UNUSED EXTERNAL COMPOOL LABEL',                                    00328100
            'UNREFERENCED EXTERNAL COMPOOL VARIABLE',                           00328200
            'UNUSED STRUCTURE TEMPLATE',                                        00328300
            'UNUSED EXTERNAL BLOCK LABEL', 'EXTERNAL PARAMETER',                00328400
            'UNUSED EXTERNAL EQUATE LABEL', 'UNUSED EXTERNAL REPLACE NAME',     00328500
            'REPLACE ARGUMENT NAME',                                            00328600
            'IMPL_T_FLAG', 'IGNORE_FLAG', 'MB_STMT_LABEL', 'IND_STMT_LABEL',    00328700
            'UNSPEC_LABEL', 'MB_CALL_LABEL', 'IND_CALL_LABEL',                  00328800
            'CALLED_LABEL', 'UNUSED', '');                                      00328900
         IF DLIST THEN DO;                                                      00329000
            S1 = FORMAT((#DEL_SYMBOLS + 1),4);                                  00329100
            S2 = FORMAT(REASON#,2);                                             00329200
            S3 = SYT_NAME(OP1);                                                 00329300
            K = LENGTH(S3);                                                     00329400
            IF K < 32 THEN S3 = S3 || SUBSTR(X72,0,32-K);                       00329500
            S4 = REASONS(REASON#);                                              00329600
            OUTPUT = X2||'#: '||S1||X2||'REASON: '||S2||X4||S3||X4||S4;         00329700
         END;                                                                   00329800
         ELSE IF (REASON#=0)|(REASON#=3) THEN DO;                               00329900
            IF ^HDR_FLAG THEN DO;                                               00330000
               HDR_FLAG = TRUE;                                                 00330100
               OUTPUT = X1;                                                     00330200
            OUTPUT='*** THE FOLLOWING COMPILATION TEMPLATES WERE INCLUDED BUT MA00330210
Y NOT HAVE BEEN USED ***';                                                      00330220
               OUTPUT = X1;                                                     00330500
            END;                                                                00330600
            OUTPUT = X6||SYT_NAME(OP1);                                         00330700
         END;                                                                   00330800
      END DPRINT;                                                               00331000
                                                                                00331100
 /* SYMBOL TABLE PASS 1 */                                                      00331200
                                                                                00331300
      PRINTLINE = X72||X52;                                                     00331400
      IF (OPTIONS_CODE & "08000000") ^= 0 THEN DLIST = TRUE;  /* XB */          00331500
      IF (OPTIONS_CODE & "10000000") ^= 0 THEN DEBUG = TRUE;  /* XC */          00331600
      IF (OPTIONS_CODE & "00040000") ^= 0                                       00331630
         THEN HMAT_OPT = TRUE;   /* HM */                                       00331640
      IF DEBUG THEN CALL SYT_DUMP;                                              00331700
      TMP = MONITOR(13,0);                                                      00331800
      COREWORD(ADDR(VALS)) = COREWORD(TMP+16);                                  00331900
      TITLE = STRING(VALS(0));                                                  00332000
      CARDTYPE = STRING(VALS(8));                                               00332005
      SYT_SIZE = VALS(3);                                                       00332100
      UNIT_ID = VALS(6);                                                        00332200
      RECORD_CONSTANT(SORTING,ACTUAL_SYMBOLS+2,UNMOVEABLE);                     00332300
      RECORD_USED(SORTING) = RECORD_ALLOC(SORTING);                             00332400
      OP1,TASK# = 0;                                                            00332700
      DO FOREVER;                                                               00332800
         OP1 = OP1 + 1;                                                         00332900
         SYT_SORT3(OP1) = OP1;                                                  00333000
         SYT_SORT4(OP1) = OP1;                                                  00333100
         SYT_SORT5(OP1) = OP1;                                                  00333200
         SYT_FLAGS(OP1)=SYT_FLAGS(OP1)&"FFFFBFE7";  /* EQUATE,LINK,SYT_VPTR */  00333300
         DO CASE SYT_CLASS(OP1);                                                00333600
            DO;            /* SCAN COMPLETED */                                 00333700
               GO TO END_SCAN;                                                  00333800
            END;                                                                00333900
            DO;            /* VARIABLE CLASS */                                 00334000
            END;                                                                00334100
            DO;            /* LABEL CLASS */                                    00334200
               DO CASE SYT_TYPE(OP1)&"F";                                       00334300
                  DO;      /* MB STMT LABEL */                                  00334400
                  END;                                                          00334500
                  DO;      /* IND STMT LABEL */                                 00334600
                  END;                                                          00334700
                  DO;      /* STATEMENT LABEL */                                00334800
                  END;                                                          00334900
                  DO;      /* UNSPEC LABEL */                                   00335000
                  END;                                                          00335100
                  DO;      /* MB CALL LABEL */                                  00335200
                  END;                                                          00335300
                  DO;      /* IND CALL LABEL */                                 00335400
                  END;                                                          00335500
                  DO;      /* CALLED LABEL */                                   00335600
                  END;                                                          00335700
                  DO;      /* PROCEDURE LABEL */                                00335800
                     CALL CHECK_COMP_UNIT_NAME;                                 00335900
                  END;                                                          00336000
                  DO;      /* TASK LABEL */                                     00336100
                     IF (SYT_FLAGS(OP1)&NAME_FLAG) = 0 THEN DO;                 00336200
                        TASK# = TASK# + 1;                                      00336300
                        SYT_DIMS(OP1) = TASK#;                                  00336400
                     END;                                                       00336500
                  END;                                                          00336600
                  DO;      /* PROGRAM LABEL */                                  00336700
                     CALL CHECK_COMP_UNIT_NAME;                                 00336800
                  END;                                                          00336900
                  DO;      /* COMPOOL LABEL */                                  00337000
                     CALL CHECK_COMP_UNIT_NAME;                                 00337100
                  END;                                                          00337200
                  DO;      /* EQUATE LABEL */                                   00337300
                  END;                                                          00337400
               END;                                                             00337500
            END;                                                                00337600
            DO;            /* FUNCTION CLASS */                                 00337700
               CALL CHECK_COMP_UNIT_NAME;                                       00337800
            END;                                                                00337900
            DO;            /* UNUSED */                                         00338000
            END;                                                                00338100
            DO;            /* REPL_ARG_CLASS */                                 00338200
            END;                                                                00338300
            DO;            /* REPL CLASS */                                     00338400
            END;                                                                00338500
            DO;            /* TEMPLATE CLASS */                                 00338600
               IF (SYT_TYPE(OP1) = STRUCTURE) &                                 00338700
                  ((SYT_LOCK#(OP1)&"80")^=0) THEN                               00338800
                  SYT_LINK2(OP1) = 0;                                           00338900
            END;                                                                00339000
            DO;            /* TPL_LAB_CLASS */                                  00339100
            END;                                                                00339200
            DO;            /* TPL_FUNC_CLASS */                                 00339300
            END;                                                                00339400
         END;                                                                   00339500
      END;                                                                      00339600
END_SCAN:                                                                       00339700
      SAVE_NDECSY,NDECSY = OP1 - 1;                                             00339800
                                                                                00339810
 /* SET THE SYT_VPTR FLAGS */                                                   00339820
                                                                                00339830
      DO M = 1 TO SYT_VPTR(0);                                                  00339840
         SYT_FLAGS(SYT_NUM(M)) = SYT_FLAGS(SYT_NUM(M)) | SYT_VPTR_FLAG;         00339850
      END;                                                                      00339860
                                                                                00340000
 /* SORT THE SYMBOL TABLE BY SCOPE AND NAME (ALPHABETICAL) */                   00340100
                                                                                00340200
      M = SHR(NDECSY,1);                                                        00340300
      DO WHILE M > 0;                                                           00340400
         DO J = 1 TO NDECSY - M;                                                00340500
            I = J;                                                              00340600
            DO WHILE STRING_GT(SYT_NAME(SYT_SORT5(I)),                          00340700
                  SYT_NAME(SYT_SORT5(I+M)));                                    00340800
               L = SYT_SORT5(I);                                                00340900
               SYT_SORT5(I) = SYT_SORT5(I+M);                                   00341000
               SYT_SORT5(I+M) = L;                                              00341100
               I = I - M;                                                       00341200
               IF I < 1 THEN GO TO LMX;                                         00341300
            END;                                                                00341400
LMX:                                                                            00341500
         END;                                                                   00341600
         M = SHR(M,1);                                                          00341700
      END;                                                                      00341800
                                                                                00341900
      IF MAX_SCOPE# = 1 THEN DO;                                                00342000
         DO I = 1 TO NDECSY;                                                    00342100
            SYT_SORT2(I) = SYT_SORT5(I);                                        00342200
         END;                                                                   00342300
      END;                                                                      00342400
      ELSE DO;                                                                  00342500
         L = 1;                                                                 00342600
         DO I = 1 TO MAX_SCOPE#;                                                00342700
            DO J = 1 TO NDECSY;                                                 00342800
               IF SYT_SCOPE(SYT_SORT5(J)) = I THEN DO;                          00342900
                  SYT_SORT2(L) = SYT_SORT5(J);                                  00343000
                  SYT_SORT3(L) = J;                                             00343100
                  SYT_SORT4(J) = L;                                             00343200
                  L = L + 1;                                                    00343300
               END;                                                             00343400
            END;                                                                00343500
         END;                                                                   00343600
      END;                                                                      00343700
                                                                                00343800
 /* SYMBOL TABLE PASS 2 -- ESTABLISH BLOCK BOUNDARIES */                        00343900
                                                                                00344000
      CALL BUILD_BLOCK_TABLES;                                                  00344100
      K#PROCS = #PROCS;                                                         00344200
                                                                                00344400
 /* SYMBOL TABLE PASS 3 -- DELETE ALL UNDESIRED SYMBOL TABLE ENTRIES */         00344500
                                                                                00344600
      #TPLS1,#TPLS2 = 0;                                                        00344700
      DO OP2 = 1 TO NDECSY;                                                     00344800
         OP1 = SYT_SORT2(OP2);                                                  00344900
         PROCPOINT = SYT_SCOPE(OP1);                                            00345000
         OP3 = SYT_SORT2(PROC_TAB1(PROCPOINT));                                 00345100
         IF (SYT_FLAGS(OP1)&IGNORE_FLAG) ^= 0 THEN DO;                          00345200
            CALL DPRINT(9);                                                     00345300
            CALL INVALID_SYMBOL;                                                00345400
         END;                                                                   00345500
         ELSE DO CASE SYT_CLASS(OP1);                                           00345600
            DO;             /* SCAN COMPLETED */                                00345700
            END;                                                                00345800
            DO;             /* VARIABLE CLASS */                                00345900
VAR_CLASS:                                                                      00346000
               IF ((SYT_FLAGS(OP3)&EXTERNAL_FLAG)=0) &                          00346100
                  (SYT_TYPE(OP1)=STRUCTURE) THEN DO;                            00346200
                  PSEUDO_TPL_FLAG = FALSE;                                      00346210
                  CALL TRAVERSE;                                                00346220
               END;                                                             00346230
               IF (SYT_CLASS(OP3) = LABEL_CLASS) & (SYT_TYPE(OP3) =             00346300
                  COMPOOL_LABEL) & (SYT_FLAGS(OP3)&EXTERNAL_FLAG) ^= 0 THEN DO; 00346400
                  IF ^USED THEN DO;                                             00346500
                     IF SYT_TYPE(OP1) = STRUCTURE THEN DO;                      00346600
                        OP4 = SYT_DIMS(OP1);                                    00346700
                        IF SYT_PTR(OP4) = OP1 THEN SYT_PTR(OP4) = 0;            00346800
                     END;                                                       00346900
                     CALL DPRINT(1);                                            00347000
                     CALL INVALID_SYMBOL;                                       00347100
                  END;                                                          00347200
                  ELSE IF (SYT_TYPE(OP1) = STRUCTURE) THEN DO;                  00347300
                     PSEUDO_TPL_FLAG = FALSE;                                   00347310
                     CALL TRAVERSE;                                             00347320
                  END;                                                          00347330
               END;                                                             00347400
               ELSE IF (SYT_FLAGS(OP3)&EXTERNAL_FLAG) ^= 0 THEN DO;             00347500
                  CALL DPRINT(4);                                               00347600
                  CALL INVALID_SYMBOL;                                          00347700
               END;                                                             00347800
               ELSE IF (SYT_FLAGS(OP1)&IMPL_T_FLAG) ^= 0 THEN DO;               00347900
                  CALL DPRINT(8);                                               00348000
                  CALL INVALID_SYMBOL;                                          00348100
               END;                                                             00348200
            END;                                                                00348300
            DO;             /* LABEL CLASS */                                   00348400
               DO CASE SYT_TYPE(OP1) & "F";                                     00348500
                  DO;       /* MB STMT LABEL */                                 00348600
                     CALL DPRINT(10);                                           00348700
                     CALL INVALID_SYMBOL;                                       00348800
                  END;                                                          00348900
                  DO;       /* IND STMT LABEL */                                00349000
                     CALL DPRINT(11);                                           00349100
                     CALL INVALID_SYMBOL;                                       00349200
                  END;                                                          00349300
                  DO;       /* STATEMENT LABEL */                               00349400
                  END;                                                          00349500
                  DO;       /* UNSPEC LABEL */                                  00349600
                     CALL DPRINT(12);                                           00349700
                     CALL INVALID_SYMBOL;                                       00349800
                  END;                                                          00349900
                  DO;       /* MB CALL LABEL */                                 00350000
                     CALL DPRINT(13);                                           00350100
                     CALL INVALID_SYMBOL;                                       00350200
                  END;                                                          00350300
                  DO;       /* IND CALL LABEL */                                00350400
                     CALL DPRINT(14);                                           00350500
                     CALL INVALID_SYMBOL;                                       00350600
                  END;                                                          00350700
                  DO;       /* CALLED LABEL */                                  00350800
                     CALL DPRINT(15);                                           00350900
                     CALL INVALID_SYMBOL;                                       00351000
                  END;                                                          00351100
                  DO;       /* PROCEDURE LABEL */                               00351200
                     IF (SYT_FLAGS(OP1) & EXTERNAL_FLAG) ^= 0 THEN DO;          00351300
                        IF ^USED THEN DO;                                       00351400
                           CALL DPRINT(3);                                      00351500
                           CALL INVALID_SYMBOL;                                 00351600
                        END;                                                    00351700
                     END;                                                       00351800
                  END;                                                          00351900
                  DO;       /* TASK LABEL */                                    00352000
                     IF (SYT_FLAGS(OP1) & NAME_FLAG) ^= 0 THEN GO TO VAR_CLASS; 00352100
                  END;                                                          00352200
                  DO;       /* PROGRAM LABEL */                                 00352300
                     IF (SYT_FLAGS(OP1) & NAME_FLAG) ^= 0 THEN GO TO VAR_CLASS; 00352400
                     IF (SYT_FLAGS(OP1) & EXTERNAL_FLAG) ^= 0 THEN DO;          00352500
                        IF ^USED THEN DO;                                       00352600
                           CALL DPRINT(3);                                      00352700
                           CALL INVALID_SYMBOL;                                 00352800
                        END;                                                    00352900
                     END;                                                       00353000
                  END;                                                          00353100
                  DO;       /* COMPOOL LABEL */                                 00353200
                  END;                                                          00353300
                  DO;       /* EQUATE LABEL */                                  00353400
                     IF (SYT_FLAGS(OP1)&EXTERNAL_FLAG) ^= 0 THEN DO;            00353500
                        IF ^USED THEN DO;                                       00353600
                           CALL DPRINT(5);                                      00353700
                           CALL INVALID_SYMBOL;                                 00353800
                        END;                                                    00353900
                     END;                                                       00354000
                  END;                                                          00354100
               END;                                                             00354200
            END;                                                                00354300
            DO;             /* FUNCTION CLASS */                                00354400
               IF (SYT_FLAGS(OP1) & EXTERNAL_FLAG) ^= 0 THEN DO;                00354500
                  IF ^USED THEN DO;                                             00354600
                     CALL DPRINT(3);                                            00354700
                     CALL INVALID_SYMBOL;                                       00354800
                  END;                                                          00354900
               END;                                                             00355000
            END;                                                                00355100
            DO;             /* UNUSED */                                        00355200
               CALL DPRINT(16);                                                 00355300
               CALL INVALID_SYMBOL;                                             00355400
            END;                                                                00355500
            DO;             /* REPL_ARG_CLASS */                                00355600
               CALL DPRINT(7);                                                  00355700
               CALL INVALID_SYMBOL;                                             00355800
            END;                                                                00355900
            DO;             /* REPL CLASS */                                    00356000
               IF (SYT_FLAGS(OP3)&EXTERNAL_FLAG)^= 0 THEN DO;                   00356100
                  IF ^USED THEN DO;                                             00356200
                     CALL DPRINT(6);                                            00356300
                     CALL INVALID_SYMBOL;                                       00356400
                  END;                                                          00356500
               END;                                                             00356600
            END;                                                                00356700
            DO;             /* TEMPLATE CLASS */                                00356800
               IF (SYT_TYPE(OP1)=STRUCTURE)&((SYT_LOCK#(OP1)&"80")^=0) THEN DO; 00356900
                  IF (SYT_FLAGS(OP3)&EXTERNAL_FLAG) ^= 0 THEN DO;               00356905
                     TPL_TAB1(#TPLS1) = OP1;                                    00357000
                     #TPLS1 = #TPLS1 + 1;                                       00357100
                  END;                                                          00357105
                  ELSE DO;                                                      00357115
                     PSEUDO_TPL_FLAG = TRUE;                                    00357117
                     CALL TRAVERSE;                                             00357119
                  END;                                                          00357121
               END;                                                             00357200
            END;                                                                00357300
            DO;             /* TPL_LAB_CLASS */                                 00357400
            END;                                                                00357500
            DO;             /* TPL_FUNC_CLASS */                                00357600
            END;                                                                00357700
         END;                                                                   00357800
      END;                                                                      00357900
                                                                                00358000
 /* CONSTRUCT THE SYT_SORT1 ARRAY FROM THE SYT_SORT2 ARRAY. */                  00358100
 /* SYT_SORT1 MAPS THE ORIGINAL SYMBOL TABLE INDICES INTO   */                  00358200
 /* PHASE 3 ASSIGNED SYMBOL NUMBERS.                        */                  00358300
                                                                                00358400
      IF #TPLS1 > 0 THEN DO;                                                    00358500
         DO I = 1 TO #SYMBOLS;                                                  00358600
            SYT_SORT1(SYT_SORT2(I)) = I;                                        00358700
         END;                                                                   00358800
      END;                                                                      00358900
                                                                                00359000
 /*DELETE ALL UNUSED STRUCTURE TEMPLATES */                                     00359100
                                                                                00359200
      DO I = 0 TO #TPLS1 - 1;                                                   00359300
         OP1 = TPL_TAB1(I);                                                     00359400
         DO J = 0 TO #TPLS2 - 1;                                                00359500
            IF TPL_TAB2(J) = OP1 THEN GO TO NO_PURGE;                           00359600
         END;                                                                   00359700
         #DEL_TPLS = #DEL_TPLS + 1;                                             00359800
         DO WHILE OP1 ^= 0;                                                     00359900
            OP2 = SYT_SORT1(OP1);                                               00360000
            PROCPOINT = SYT_SCOPE(OP1);                                         00360100
            CALL DPRINT(2);                                                     00360200
            CALL INVALID_SYMBOL;                                                00360300
            IF SYT_LINK1(OP1) ^= 0 THEN                                         00360400
               OP1 = SYT_LINK1(OP1);                                            00360500
            ELSE DO;                                                            00360600
               OP1 = SYT_LINK2(OP1);                                            00360700
               DO WHILE OP1 < 0;                                                00360800
                  OP1 = SYT_LINK2(-OP1);                                        00360900
               END;                                                             00361000
            END;                                                                00361100
         END;                                                                   00361200
NO_PURGE:                                                                       00361300
      END;                                                                      00361400
                                                                                00361500
      IF #DEL_SYMBOLS = 0 THEN GO TO NO_DELETIONS;                              00361600
                                                                                00361700
 /* IF WE HAVE INCLUDED (EXTERNAL) COMPOOLS, FLUSH OUT THE COMPOOL */           00361800
 /* NAME IF ALL OF ITS VARIABLES HAVE BEEN DELETED.                */           00361900
                                                                                00362000
      IF #COMPOOLS > 0 THEN DO;                                                 00362100
         DO I = 1 TO #PROCS;                                                    00362200
            IF PROC_TAB3(I) = 1 THEN DO;                                        00362300
               OP2 = PROC_TAB1(I);                                              00362400
               OP1 = SYT_SORT2(OP2);                                            00362500
               IF (SYT_CLASS(OP1) = LABEL_CLASS) &                              00362600
                  (SYT_TYPE(OP1) = COMPOOL_LABEL) &                             00362700
                  (SYT_FLAGS(OP1) & EXTERNAL_FLAG) ^= 0 THEN DO;                00362800
                  CALL DPRINT(0);                                               00362900
                  #DEL_SYMBOLS = #DEL_SYMBOLS + 1;                              00363000
                  DEL_TAB(#DEL_SYMBOLS) = OP2;                                  00363100
               END;                                                             00363200
            END;                                                                00363300
         END;                                                                   00363400
      END;                                                                      00363500
                                                                                00363600
 /* ZERO OUT SYT_SORT2/SYT_SORT4 ENTRIES FOR ALL DELETED SYMBOLS */             00363700
                                                                                00363800
      DO I = 1 TO #DEL_SYMBOLS;                                                 00363900
         SYT_SORT2(DEL_TAB(I)) = 0;                                             00364000
         SYT_SORT4(SYT_SORT3(DEL_TAB(I))) = 0;                                  00364100
      END;                                                                      00364200
                                                                                00364300
 /* COMPRESS THE SYT_SORT2/SYT_SORT4 ARRAYS -- ELIMINATE ZERO ENTRIES */        00364400
                                                                                00364500
      J = 1;                                                                    00364600
      DO I = 1 TO NDECSY;                                                       00364700
         IF SYT_SORT2(I) ^= 0 THEN DO;                                          00364800
            SYT_SORT2(J) = SYT_SORT2(I);                                        00364900
            SYT_SORT4(SYT_SORT3(I)) = J;                                        00365000
            J = J + 1;                                                          00365100
         END;                                                                   00365200
      END;                                                                      00365300
      J = 1;                                                                    00365400
      DO I = 1 TO NDECSY;                                                       00365500
         IF SYT_SORT4(I) ^= 0 THEN DO;                                          00365600
            SYT_SORT4(J) = SYT_SORT4(I);                                        00365700
            J = J + 1;                                                          00365800
         END;                                                                   00365900
      END;                                                                      00366000
      NDECSY = J - 1;                                                           00366100
                                                                                00366200
NO_DELETIONS:                                                                   00366300
                                                                                00366400
 /* SYMBOL TABLE PASS 4 -- REESTABLISH BLOCK BOUNDARIES */                      00366500
                                                                                00366600
      IF #DEL_SYMBOLS > 0 THEN DO;                                              00366700
         DO I = 1 TO #PROCS;                                                    00366800
            PROC_TAB1(I),PROC_TAB2(I) = 0;                                      00366900
            PROC_TAB3(I) = 0;                                                   00367000
         END;                                                                   00367100
         CALL BUILD_BLOCK_TABLES;                                               00367200
      END;                                                                      00367300
                                                                                00367400
 /* INITIALIZE PROC_TAB5 AND PROC_TAB6 ARRAYS FOR BLOCK SORTING */              00367500
                                                                                00367600
      DO I = 1 TO #PROCS;                                                       00367700
         PROC_TAB5(I),PROC_TAB6(I) = I;                                         00367800
      END;                                                                      00367900
                                                                                00368000
 /* IF WE HAVE DELETED ANY BLOCKS, THEN OUR PROC_TAB1 ARRAY IS SPARSE AND */    00368100
 /* THUS NOT VERY SUITABLE TO DO SORTS ON.  THEREFORE CREATE A PACKED     */    00368200
 /* ARRAY (PROC_TAB8).                                                    */    00368300
                                                                                00368400
      J = 1;                                                                    00368500
      DO I = 1 TO K#PROCS;                                                      00368600
         IF PROC_TAB1(I) ^= 0 THEN DO;                                          00368700
            PROC_TAB8(J) = I;                                                   00368800
            J = J + 1;                                                          00368900
         END;                                                                   00369000
      END;                                                                      00369100
                                                                                00369200
 /* SORT ALL HAL BLOCKS (I.E., PROCEDURES, TASKS, ETC.) ALPHABETICALLY */       00369300
                                                                                00369400
      EXCHANGES = TRUE;                                                         00369500
      K = #PROCS - 1;                                                           00369600
      DO WHILE EXCHANGES;                                                       00369700
         EXCHANGES = FALSE;                                                     00369800
         DO J = 0 TO K - 1;                                                     00369900
            I = #PROCS - J;                                                     00370000
            L = I - 1;                                                          00370100
            KL = PROC_TAB8(PROC_TAB5(L));                                       00370200
            KI = PROC_TAB8(PROC_TAB5(I));                                       00370300
            KL = SYT_SORT2(PROC_TAB1(KL));                                      00370400
            KI = SYT_SORT2(PROC_TAB1(KI));                                      00370500
            IF STRING_GT(SYT_NAME(KL), SYT_NAME(KI)) THEN DO;                   00370600
               M = PROC_TAB5(I);                                                00370700
               PROC_TAB5(I) = PROC_TAB5(L);                                     00370800
               PROC_TAB5(L) = M;                                                00370900
               EXCHANGES = TRUE;                                                00371000
               K = J;                                                           00371100
            END;                                                                00371200
         END;                                                                   00371300
      END;                                                                      00371400
                                                                                00371500
 /* SORT ALL HAL BLOCKS BY THE NUMBER OF DECLARED SYMBOLS THAT THEY HAVE */     00371600
                                                                                00371700
      EXCHANGES = TRUE;                                                         00371800
      K = #PROCS - 1;                                                           00371900
      DO WHILE EXCHANGES;                                                       00372000
         EXCHANGES = FALSE;                                                     00372100
         DO J = 0 TO K - 1;                                                     00372200
            I = #PROCS - J;                                                     00372300
            L = I - 1;                                                          00372400
            KL = PROC_TAB8(PROC_TAB6(L));                                       00372500
            KI = PROC_TAB8(PROC_TAB6(I));                                       00372600
            IF PROC_TAB3(KL) < PROC_TAB3(KI) THEN DO;                           00372700
               M = PROC_TAB6(I);                                                00372800
               PROC_TAB6(I) = PROC_TAB6(L);                                     00372900
               PROC_TAB6(L) = M;                                                00373000
               EXCHANGES = TRUE;                                                00373100
               K = J;                                                           00373200
            END;                                                                00373300
         END;                                                                   00373400
      END;                                                                      00373500
                                                                                00373600
 /* ESTABLISH A CORRESPONDENCE BETWEEN THE TWO ORDERINGS OF THE HAL BLOCKS */   00373700
                                                                                00373800
      DO I = 1 TO #PROCS;                                                       00373900
         J = PROC_TAB6(I);                                                      00374000
         DO K = 1 TO #PROCS;                                                    00374100
            IF J = PROC_TAB5(K) THEN DO;                                        00374200
               PROC_TAB7(I) = K;                                                00374300
               GO TO GOT_DEX;                                                   00374400
            END;                                                                00374500
         END;                                                                   00374600
GOT_DEX:                                                                        00374700
      END;                                                                      00374800
                                                                                00374900
                                                                                00375000
 /* CONSTRUCT MAPPING FROM LABEL INDICES TO BLOCK NUMBERS */                    00375100
                                                                                00375200
      DO I = 1 TO #PROCS;                                                       00375300
         L = PROC_TAB8(PROC_TAB5(I));                                           00375400
         L = SYT_SORT2(PROC_TAB1(L));                                           00375500
         SYT_SORT3(L) = I;                                                      00375600
      END;                                                                      00375700
                                                                                00375800
 /* CONSTRUCT THE SYT_SORT1 ARRAY FROM THE SYT_SORT2 ARRAY */                   00375900
 /* SYT_SORT1 MAPS THE ORIGINAL SYMBOL TABLE INDICES INTO  */                   00376000
 /* SYMBOL NUMBERS.  THESE IN TURN MAP INTO POINTERS VIA   */                   00376100
 /* THE SYMB_TO_PTR ROUTINE.                               */                   00376200
                                                                                00376300
      DO I = 1 TO ACTUAL_SYMBOLS+1;                                             00376310
         SYT_SORT1(I) = 0;                                                      00376320
      END;                                                                      00376330
      DO I = 1 TO #SYMBOLS;                                                     00376400
         SYT_SORT1(SYT_SORT2(I)) = I;                                           00376500
      END;                                                                      00376600
                                                                                00376700
 /* SET OUR INTERNAL FLAGS */                                                   00376800
                                                                                00376900
      IF (OPTIONS_CODE & "1000") ^= 0 THEN                                      00377000
         HEX_DUMP_FLAG = TRUE;                                                  00377100
      IF (((OPTIONS_CODE & "00000008")=0)&(^(FC))) THEN                         00377200
         NOTRACE_FLAG = TRUE;                                                   00377300
      IF (OPTIONS_CODE&"008000") ^= 0 THEN DO;                                  00377400
         SDF_SUMMARY = TRUE;                                                    00377500
      END;                                                                      00377700
      STRING_MARGIN = 30000;                                                    00377800
      TEMP1 = SHR(FREELIMIT - FREEPOINT,1);                                     00377900
      IF STRING_MARGIN > TEMP1 THEN STRING_MARGIN = TEMP1;                      00378000
      IF (OPTIONS_CODE&"880000") ^=0 THEN SRN_FLAG=TRUE;                        00378100
      IF (OPTIONS_CODE&"100000") ^= 0 THEN ADDR_FLAG = TRUE;                    00378200
      IF (OPTIONS_CODE & "00800000") ^= 0 THEN SDL_FLAG = TRUE;                 00378300
      IF ((OPTIONS_CODE&"40000")^=0)&(^(FC)) THEN FCDATA_FLAG = TRUE;           00378310
      IF (OPTIONS_CODE & "00000080") ^= 0 THEN HIGHOPT = TRUE; /* DR103787 */   00378300
                                                                                00378400
 /* COMPUTE THE NUMBER OF PAGES REQUIRED FOR THE SDF DIRECTORY */               00378500
                                                                                00378600
      IF SRN_FLAG THEN DO;                                                      00378800
         STMT_NODE_SIZE = 12;                                                   00378900
         BIAS = 2;                                                              00379000
      END;                                                                      00379100
      ELSE DO;                                                                  00379200
         STMT_NODE_SIZE = 4;                                                    00379300
         BIAS = 0;                                                              00379400
      END;                                                                      00379500
      LAST_STMT = STMT_NUM - 1;                                                 00379700
      #STMTS = LAST_STMT - FIRST_STMT + 1;                                      00379800
      #_STMT_BYTES = #STMTS * STMT_NODE_SIZE;                                   00379900
      STMT_NODES_PER_PAGE = PAGE_SIZE / STMT_NODE_SIZE;                         00380000
      #_SYMB_BYTES = #SYMBOLS * SYMB_NODE_SIZE;                                 00380500
      SYMB_NODES_PER_PAGE = PAGE_SIZE / SYMB_NODE_SIZE;                         00380600
      #_BLOCK_BYTES = #PROCS * BLOCK_NODE_SIZE;                                 00380700
      BLOCK_NODES_PER_PAGE = PAGE_SIZE / BLOCK_NODE_SIZE;                       00380800
      DIR_SIZE = DIR_ALOC_SZ + 61 * #PROCS + LENGTH(TITLE);                     00380900
      IF SRN_FLAG THEN DO;                                                      00381100
         #PAGES = 1 + (#STMTS / STMT_NODES_PER_PAGE);                           00381200
         #PAGES_PER_CELL = (MAX_CELL - 8)/20;                                   00381300
         #CELLS = #PAGES / #PAGES_PER_CELL;                                     00381400
         DIR_SIZE = DIR_SIZE + 8 * #CELLS + 20 * #PAGES;                        00381500
      END;                                                                      00381600
      #PAGES = 1 + (#SYMBOLS / SYMB_NODES_PER_PAGE);                            00381800
      DIR_SIZE = DIR_SIZE + 20 * #PAGES * #PAGES;                               00381900
      #PAGES = 1 + DIR_SIZE / PAGE_SIZE;                                        00382000
      DIR_SIZE = DIR_SIZE + #PAGES * (PAGE_SIZE / DIR_MARGIN);                  00382100
      PAGE = DIR_SIZE/PAGE_SIZE;                                                00382200
      OFFSET = DIR_SIZE MOD PAGE_SIZE;                                          00382300
      OFFSET = 12 * (OFFSET / 12);                                              00382400
      IF OFFSET = 0 THEN DO;                                                    00382500
         PAGE = PAGE - 1;                                                       00382600
         OFFSET = PAGE_SIZE - 12;                                               00382700
      END;                                                                      00382800
      LAST_DIR_PTR,FIRST_DATA_PTR = SHL(PAGE,16)+OFFSET;                        00382900
      LAST_DIR_PAGE,FIRST_DATA_PAGE = SHR(LAST_DIR_PTR,16);                     00383000
                                                                                00383100
 /* FORM A GUESS OF THE ULTIMATE SIZE OF THE SIMULATION DATA FILE */            00383200
                                                                                00383300
      IF (ADDR_FLAG) & (FC) THEN TEMP1 = 16;                                    00383400
      ELSE TEMP1 = 10;                                                          00383500
      TEMP2 = #EXECS/5 + #EXECS * TEMP1;                                        00383600
      IF COMPOOL_FLAG THEN TEMP3 = 40;                                          00383700
      ELSE TEMP3 = 54;                                                          00383800
      TEMP4 = SHL(#SYMBOLS/5,2) + #SYMBOLS * TEMP3;                             00383900
      TEMP4 = 6 * (#SYMBOLS/10) + TEMP4;                                        00384000
      FILE_SIZE = DIR_SIZE + #_BLOCK_BYTES + #_SYMB_BYTES + #_STMT_BYTES +      00384100
         TEMP2+TEMP4+MACRO_BYTES+LIT_CHAR_USED+(12*LIT_TOP)+TOTAL_HMAT_BYTES;   00384200
      FILE_SIZE = 5 * SHR(FILE_SIZE,2);                                         00384300
      MAX_PAGE_PRED = FILE_SIZE/PAGE_SIZE +                 /*CR13079*/         00384400
      (RECORD_USED(INIT_TAB)*2/PAGE_SIZE);                  /*CR13079*/         00384500
      IF (RECORD_USED(INIT_TAB)*2) MOD PAGE_SIZE > 0 THEN   /*CR13079*/
         MAX_PAGE_PRED = MAX_PAGE_PRED + 1;                 /*CR13079*/

      PGAREA_LIMIT = ((FREELIMIT + 512) & "FFFFFFF8") - 1; /* DBL WRD BNDRY */  00384600
                                                                                00384700
 /* SEE HOW MANY PAGES WE CAN GET OUT OF THE FREE STRING AREA AS IS */          00384800
                                                                                00384900
      MAX_PAGE = (PGAREA_LIMIT - FREEPOINT - STRING_MARGIN - 512)/PAGE_SIZE - 1;00385000
                                                                                00385100
 /* IF THERE IS NOT ENOUGH, PERFORM A COMPACTIFY */                             00385200
                                                                                00385300
      IF MAX_PAGE < MAX_PAGE_PRED THEN DO;                                      00385400
                                                                                00385500
 /* THE FOLLOWING LOGIC HAS ONE FUNCTION: TO DETERMINE THE ADDRESS OF */        00385600
 /* THE COMMON STRING (SYMBOL NAME) THAT IS LOWEST IN MEMORY.  FREEBASE */      00385700
 /* IS SET TO THIS VALUE SO THAT THE COMPACTIFY SUBSEQUENTLY PERFORMED */       00385800
 /* WILL OPERATE ON THE COMMON STRING AREA */                                   00385900
                                                                                00386000
         FREEBASE = 0;                                                          00386100
         DO I = 1 TO ACTUAL_SYMBOLS;                                            00386200
            ADDR_TEMP = COREWORD(ADDR(SYT_NAME(I))) & "00FFFFFF";               00386300
            IF FREEBASE = 0 THEN FREEBASE = ADDR_TEMP;                          00386400
            ELSE IF FREEBASE > ADDR_TEMP THEN                                   00386500
               IF ADDR_TEMP ^= 0 THEN FREEBASE = ADDR_TEMP;                     00386600
         END;                                                                   00386700
                                                                                00386800
 /* NOW DO A COMPACTIFY TO TAKE ADVANTAGE OF ALL OF THE FREE STRING SPACE */    00386900
 /* LIBERATED BY THE DELETION OF THE NAMES ASSOCIATED WITH UNDESIRED */         00387000
 /* SYMBOLS */                                                                  00387100
                                                                                00387200
         CALL COMPACTIFY;                                                       00387300
         FREEBASE = FREEPOINT;   /* NO FURTHER COMPRESSION POSSIBLE */          00387400
      END;                                                                      00387500
                                                                                00387600
 /* ALLOCATE A PAGING AREA FROM THE FREE STRING AREA */                         00387700
                                                                                00387800
      MAX_PAGE = (PGAREA_LIMIT - (FREEPOINT+STRING_MARGIN + 512))/PAGE_SIZE - 1;00387900
      IF MAX_PAGE < 0 THEN MAX_PAGE = -1;                                       00388100
      IF MAX_PAGE > LIM_PAGE THEN MAX_PAGE = LIM_PAGE;                          00388200
                                                                                00388500
 /* INITIALIZE THE PAGING AREA DIRECTORY */                                     00388600
      RECORD_CONSTANT(PGAREA,MAX_PAGE,UNMOVEABLE);                              00388700
      RECORD_USED(PGAREA) = RECORD_ALLOC(PGAREA);                               00388710
      ADDR_TEMP = ADDR(PGAREA(0));                                              00388720
      DO I = 0 TO MAX_PAGE;                                                     00388900
         PAD_PAGE(I) = -1;                                                      00389000
         PAD_ADDR(I) = ADDR_TEMP;                                               00389100
         ADDR_TEMP = ADDR_TEMP + RECORD_WIDTH(PGAREA);                          00389200
      END;                                                                      00389300
                                                                                00389400
 /* STEAL THE LAST TWO AVAILABLE PAGES FOR THE 'SDFOUT' BUFFERS */              00389500
                                                                                00389600
      MAX_PAGE = MAX_PAGE - 2;                                                  00389700
                                                                                00389800
      IF MAX_PAGE < 3 THEN GO TO NO_CORE;                                       00389900
                                                                                00390000
 /* INITIALIZE THE REMAINING ARRAYS */                                          00390100
                                                                                00390200
      DO I = 0 TO SDF_SIZE;                                                     00390300
         PAGE_TO_LREC(I) = -1;                                                  00390400
         PAGE_TO_NDX(I) = -1;                                                   00390500
      END;                                                                      00390600
                                                                                00390700
 /* SET THE PROPER BLOCK SIZE FOR DIRECT ACCESS FILE 5 */                       00390800
                                                                                00390900
      CALL MONITOR(4, 5, PAGE_SIZE);                                            00391000
                                                                                00391100
 /* DECLARE INITIALIZATION OFFICIALLY OVER */                                   00391200
                                                                                00391300
      CLOCK(1) = MONITOR(18);                                                   00391400
                                                                                00391500
 /* ALLOCATE SDF SPACE FOR THE SDF DIRECTORY */                                 00391600
                                                                                00391700
      DO PAGE = 0 TO LAST_DIR_PAGE;                                             00391800
         PTR = SHL(PAGE,16);                                                    00391900
         CALL P3_PTR_LOCATE(PTR,0);                                             00392000
      END;                                                                      00392100
                                                                                00392200
 /* ALLOCATE SDF SPACE FOR ALL OF THE FIXED-LENGTH NODES */                     00392300
                                                                                00392400
      FIRST_BLOCK_PTR = PTR_FIX(FIRST_DATA_PTR + 12);                           00392500
      BASE_BLOCK_PAGE = SHR(FIRST_BLOCK_PTR,16) & "FFFF";                       00392600
      BASE_BLOCK_OFFSET = FIRST_BLOCK_PTR & "FFFF";                             00392700
      LAST_BLOCK_PTR = BLOCK_TO_PTR(#PROCS);                                    00392800
      FIRST_SYMB_PTR = PTR_FIX(LAST_BLOCK_PTR + BLOCK_NODE_SIZE);               00392900
      BASE_SYMB_PAGE = SHR(FIRST_SYMB_PTR,16) & "FFFF";                         00393000
      BASE_SYMB_OFFSET = FIRST_SYMB_PTR & "FFFF";                               00393100
      LAST_SYMB_PTR = SYMB_TO_PTR(#SYMBOLS);                                    00393200
      FIRST_FREE_PTR = PTR_FIX(LAST_SYMB_PTR + SYMB_NODE_SIZE);                 00393300
      FIRST_STMT_PTR = FIRST_FREE_PTR;                                          00393500
      BASE_STMT_PAGE = SHR(FIRST_STMT_PTR,16) & "FFFF";                         00393600
      BASE_STMT_OFFSET = FIRST_STMT_PTR & "FFFF";                               00393700
      LAST_STMT_PTR = STMT_TO_PTR(LAST_STMT);                                   00393800
      PAGE = SHR(LAST_STMT_PTR,16) & "FFFF";                                    00393900
      OFFSET = LAST_STMT_PTR & "FFFF";                                          00394000
      OFFSET = OFFSET + STMT_NODE_SIZE;                                         00394100
      OFFSET = 12*((OFFSET + 11)/12);                                           00394200
      FIRST_FREE_PTR = PTR_FIX(SHL(PAGE,16) + OFFSET);                          00394300
      FIRST_FREE_PAGE = SHR(FIRST_FREE_PTR,16) & "FFFF";                        00394500
      FREE_CHAIN = FIRST_DATA_PTR;                                              00394600
                                                                                00394700
      START_PAGE = FIRST_DATA_PAGE + 1;                                         00394800
      DO PAGE = START_PAGE TO FIRST_FREE_PAGE;                                  00394900
         PTR = SHL(PAGE,16);                                                    00395000
         CALL ZERON(PTR,0,8,0);                                                 00395100
      END;                                                                      00395200
                                                                                00395300
 /* ESTABLISH THE DIRECTORY FREE CELL CHAIN */                                  00395400
                                                                                00395500
      CALL P3_LOCATE(0,ADDR(NODE_F),MODF);                                      00395600
      NODE_F(0) = 0;                                                            00395700
      IF LAST_DIR_PAGE = 0 THEN NODE_F(5) = 0;                                  00395800
      ELSE NODE_F(5) = "00010000";                                              00395900
      NODE_F(1) = 16;                                                           00396000
      NODE_F(3) = FREE_CHAIN;                                                   00396100
      IF LAST_DIR_PAGE = 0 THEN                                                 00396200
         NODE_F(4) = (FIRST_DATA_PTR & "FFFF") - 16;                            00396300
      ELSE NODE_F(4) = PAGE_SIZE - 16;                                          00396400
                                                                                00396500
      IF LAST_DIR_PAGE ^= 0 THEN DO;                                            00396600
         PTR = SHL(LAST_DIR_PAGE,16);                                           00396700
         CALL P3_LOCATE(PTR,ADDR(NODE_F),MODF);                                 00396800
         NODE_F(0) = LAST_DIR_PTR & "FFFF";                                     00396900
         NODE_F(1) = 0;                                                         00397000
      END;                                                                      00397100
                                                                                00397200
 /* ESTABLISH THE DATA FREE CELL CHAIN */                                       00397300
                                                                                00397400
      CALL P3_LOCATE(FREE_CHAIN,ADDR(NODE_F),MODF);                             00397500
      NODE_F(0) = 0;                                                            00397600
      NODE_F(1) = FIRST_FREE_PTR;                                               00397700
                                                                                00397800
      OFFSET = FIRST_FREE_PTR & "FFFF";                                         00397900
      PAGE = SHR(FIRST_FREE_PTR,16) & "FFFF";                                   00398000
      CALL P3_LOCATE(FIRST_FREE_PTR,ADDR(NODE_F),MODF);                         00398100
      NODE_F(0) = PAGE_SIZE - OFFSET;                                           00398200
      NODE_F(1) = SHL(PAGE + 1,16);                                             00398300
                                                                                00398400
 /* CREATE THE TITLE CELL (IF TITLE HAS BEEN SPECIFIED) */                      00398500
                                                                                00398600
      PTR_TEMP = 0;                                                             00398700
      K = LENGTH(TITLE);                                                        00398800
      IF K > 0 THEN DO;                                                         00398900
         PTR_TEMP = GET_DIR_CELL(K+1,ADDR(NODE_B),MODF);                        00399000
         NODE_B(0) = K;                                                         00399100
         ADDR_TEMP = COREWORD(ADDR(TITLE)) & "FFFFFF";                          00399200
         CALL PUTN(PTR_TEMP,1,ADDR_TEMP,K,0);                                   00399300
      END;                                                                      00399400
                                                                                00399405
 /* CREATE THE CARDTYPE CELL (IF CARDTYPE HAS BEEN SPECIFIED)  */               00399410
                                                                                00399415
      PTR_TEMP1 = 0;                                                            00399420
      K = LENGTH(CARDTYPE);                                                     00399425
      IF K > 0 THEN DO;                                                         00399430
         PTR_TEMP1 = GET_DIR_CELL(K+1,ADDR(NODE_B),MODF);                       00399435
         NODE_B(0) = K;                                                         00399440
         ADDR_TEMP = COREWORD(ADDR(CARDTYPE)) & "FFFFFF";                       00399445
         CALL PUTN(PTR_TEMP1,1,ADDR_TEMP,K,0);                                  00399450
      END;                                                                      00399455
                                                                                00399500
                                                                                00399501
 /* SORT THE INCLUDE LIST ALPHABETICALLY, COMBINE ENTRIES REFERING TO           00399502
      THE SAME BLOCK, AND MOVE THE LIST INTO THE SDF */                         00399503
                                                                                00399504
      IF VERSION#>= 25 & INCLUDE_LIST_HEAD ^= -1 THEN DO;                       00399505
         CALL LOCATE(INCLUDE_LIST_HEAD,ADDR(NODE_H),0);                         00399507
         #INCL_CELLS = NODE_H(12);                                              00399508
         RECORD_CONSTANT(NCLUDE,#INCL_CELLS+1,UNMOVEABLE);                      00399509
         RECORD_USED(NCLUDE) = RECORD_ALLOC(NCLUDE);                            00399510
         VMEM_INCLUDE_PTR = INCLUDE_LIST_HEAD;                                  00399511
         DO WHILE VMEM_INCLUDE_PTR ^= -1;                                       00399512
            INCL_INX = INCL_INX + 1;                                            00399513
            DO WHILE INCL_INX >= RECORD_TOP(NCLUDE);                            00399514
               NEXT_ELEMENT(NCLUDE);                                            00399515
            END;                                                                00399516
            CALL LOCATE(VMEM_INCLUDE_PTR,ADDR(NODE_F),0);                       00399517
            INCL_SORT(INCL_INX) = INCL_INX;                                     00399518
            INCL_PTR(INCL_INX) = VMEM_INCLUDE_PTR;                              00399519
            CALL MOVE(8,VMEM_LOC_ADDR + 4,ADDR(INCL_NAME(INCL_INX)));           00399520
            VMEM_INCLUDE_PTR = NODE_F(0);                                       00399521
         END;                                                                   00399522
         STRING_BASE = "07000000";                                              00399523
         DO I = 2 TO INCL_INX;                                                  00399524
            COREWORD(ADDR(STRING_I))=STRING_BASE+ADDR(INCL_NAME(INCL_SORT(I))); 00399525
           COREWORD(ADDR(STRING_J))=STRING_BASE+ADDR(INCL_NAME(INCL_SORT(I-1)));00399526
            IF STRING_GT(STRING_I,STRING_J) THEN DO;                            00399527
               SAVE_I = INCL_SORT(I);                                           00399528
               INCL_SORT(I) = INCL_SORT(I-1);                                   00399529
               J = I-2;                                                         00399530
               COREWORD(ADDR(STRING_J))=STRING_BASE +                           00399531
                  ADDR(INCL_NAME(INCL_SORT(J)));                                00399532
               DO WHILE STRING_GT(STRING_I,STRING_J) & J>0;                     00399533
                  INCL_SORT(J+1) = INCL_SORT(J);                                00399534
                  J = J-1;                                                      00399535
                  COREWORD(ADDR(STRING_J))=STRING_BASE +                        00399536
                     ADDR(INCL_NAME(INCL_SORT(J)));                             00399537
               END;                                                             00399538
               INCL_SORT(J+1) = SAVE_I;                                         00399539
            END;                                                                00399540
         END;                                                                   00399541
         DO J = 1 TO INCL_INX-1;                                                00399542
            I = INCL_INX - J;                                                   00399543
            COREWORD(ADDR(TS))=STRING_BASE+ADDR(INCL_NAME(INCL_SORT(I)));       00399544
            COREWORD(ADDR(TS(1)))=STRING_BASE+ADDR(INCL_NAME(INCL_SORT(I+1)));  00399545
            IF TS = TS(1) THEN                                                  00399546
               INCL_COUNT(INCL_SORT(I)) = INCL_COUNT(INCL_SORT(I+1)) +1;        00399547
         END;                                                                   00399548
         I = 1;                                                                 00399549
         DO WHILE I<= INCL_INX;                                                 00399550
            J = INCL_SORT(I);                                                   00399551
            CALL LOCATE(INCL_PTR(J),ADDR(NODE_B),0);                            00399552
            CELLSIZE = 24 + 6*INCL_COUNT(J);                                    00399553
            SDF_INCLUDE_PTR = GET_DATA_CELL(CELLSIZE,ADDR(NODE_F),0);           00399554
            COREWORD(ADDR(NODE_B)) = LOC_ADDR;                                  00399555
            NODE_F(0) = OLD_SDF_INCLUDE_PTR;                                    00399556
            OLD_SDF_INCLUDE_PTR = SDF_INCLUDE_PTR;                              00399557
            CALL MOVE(20,VMEM_LOC_ADDR+4,LOC_ADDR+4);                           00399558
            NODE_B(17) = INCL_COUNT(J) + 1;                                     00399559
            SRN_ADDR = LOC_ADDR + 24;                                           00399560
            I = I + 1;                                                          00399561
            IF INCL_COUNT(J) >0 THEN                                            00399562
               DO K = 1 TO INCL_COUNT(J);                                       00399563
               CALL PTR_LOCATE(INCL_PTR(INCL_SORT(I)),0);                       00399564
               CALL MOVE(6,VMEM_LOC_ADDR+18,SRN_ADDR);                          00399565
               SRN_ADDR = SRN_ADDR + 6;                                         00399566
               I = I + 1;                                                       00399567
            END;                                                                00399568
         END;                                                                   00399569
         RECORD_FREE(NCLUDE);                                                   00399570
      END;                                                                      00399571
                                                                                00399572
 /* CREATE THE SDF DIRECTORY NODE */                                            00399600
                                                                                00399700
      ROOT_PTR = GET_DIR_CELL(ROOT_DIR_SZ,ADDR(NODE_F),MODF);                   00399710
      COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                        00399900
      NODE_F(5) = FIRST_BLOCK_PTR;                                              00400000
      NODE_F(6) = EMITTED_CNT;                                                  00400100
      NODE_F(9) = FIRST_SYMB_PTR;                                               00400200
      NODE_F(15) = FIRST_STMT_PTR;                                              00400300
      NODE_H(1) = 0;                                                            00400400
      NODE_H(6) = LAST_DIR_PAGE;                                                00400500
      NODE_H(7) = #EXTERNALS;                                                   00400600
      NODE_H(8) = #PROCS;                                                       00400700
      NODE_H(9) = #SYMBOLS;                                                     00400800
      NODE_H(14) = SYT_SORT1(SELFNAMELOC);                                      00400900
      /* REPRESENTS THE NUMBER OF STACK WALKBACKS WHICH IS ALWAYS 0./*CR13811*/
      NODE_H(20) = 0;                                               /*CR13811*/ 00401000
      NODE_H(26) = FIRST_STMT;                                                  00401100
      NODE_H(27) = LAST_STMT;                                                   00401200
      NODE_H(29) = #STMTS;                                                      00401300
      NODE_F(16) = OLD_SDF_INCLUDE_PTR;                                         00401350
      NODE_H(45) = UNIT_ID;                                                     00401400
      NODE_F(23) = PTR_TEMP;                                                    00401500
      NODE_F(26) = SAVE_NDECSY;                                                 00401600
      NODE_F(27) = MACRO_USED;                                                  00401700
      NODE_F(28) = LIT_CHAR_USED;                                               00401800
      IF COMSUB_END = 0 THEN NODE_H(59) = 0;                                    00401810
      ELSE DO;                                                                  00401820
         DO WHILE SYT_SORT1(COMSUB_END) = 0;                                    00401830
            COMSUB_END = COMSUB_END - 1;                                        00401840
         END;                                                                   00401850
         NODE_H(59) = SYT_SORT1(COMSUB_END);                                    00401860
      END;                                                                      00401870
      NODE_F(30) = XREF_USED;                                                   00401900
      NODE_F(31) = VALS(3);   /* SYMBOLS = */                                   00402000
      NODE_F(32) = VALS(4);   /* MACROSIZE = */                                 00402100
      NODE_F(33) = VALS(5);   /* LITSTRINGS = */                                00402200
      NODE_F(34) = VALS(7);   /* XREFSIZE = */                                  00402300
      NODE_H(78), NODE_H(79) = 0;   /* ZERO SPILL-DATA HEADS; NOT   */          00402310
 /* DELETED FOR CR-11098 SINCE   */
 /* NODE_H USED IN NON-SPILL CODE*/
      NODE_H(80) = COMM(23);        /* DATA HIGH WATER MARK */                  00402320
      NODE_H(81) = COMM(24);        /* REMOTE HIGH WATER MARK */                00402330
      NODE_H(82) = COMM(25);        /* OVERFLOW LIT START */                    00402340
      NODE_H(83) = COMM(26);        /* OVERFLOW LIT END   */                    00402350
      NODE_H(84) = COMM(27);        /* PRIMARY LIT START   */                   00402360
      NODE_H(85) = COMM(28);        /* PRIMARY LIT END   */                     00402370
      IF SRN_FLAG THEN NODE_H(0) = "8000";                                      00402400
      ELSE NODE_H(0) = 0;                                                       00402500
      NODE_H(0) = NODE_H(0) | "0002";   /* FOR IBM */                           00402600
      NODE_H(0) = NODE_H(0) | "0001";     /* SET THE NEW FLAG */                00402700
      IF (ADDR_FLAG) & (FC) THEN NODE_H(0) = NODE_H(0)|"4000";                  00402900
      IF COMPOOL_FLAG THEN NODE_H(0) = NODE_H(0)|"2000";                        00403000
      IF FC THEN NODE_H(0) = NODE_H(0)|"1000";                                  00403100
      IF NOTRACE_FLAG THEN NODE_H(0) = NODE_H(0)|"0100";                        00403200
      IF HIGHOPT THEN NODE_H(0) = NODE_H(0)|"0080"; /* DR103787 */              00403200
      IF FCDATA_FLAG THEN NODE_H(0) = NODE_H(0)|"0010";                         00403205
      IF SDL_FLAG THEN NODE_H(0) = NODE_H(0)|"0008";                            00403300
 /* -RSJ------CR11096-----------#DFLAG--------------------------------*/
 /*    FOR #D COMPILATIONS, SET BIT 13 OF THE FLAG FIELD OF THE       */
 /*    SDF HEADER                                                     */
 /*    NODE_H(0) IS A POINTER WH1CH POINTS TO THE 2 BYTE FIELD.       */
 /*    BIT 13 WILL INDICATE A #D COMPILATION OCCURED                  */
      IF DATA_REMOTE THEN NODE_H(0) = NODE_H(0)  | "0004";
 /* ------------------------------------------------------------------*/
      IF (SYT_FLAGS(SELFNAMELOC) & BITMASK_FLAG) ^= 0                           00403320
         THEN NODE_H(0) = NODE_H(0) | "0040";                                   00403330
      IF HMAT_OPT THEN NODE_H(0) = NODE_H(0) | "0020";                          00403340
      TS = STRING(MONITOR(23));                                                 00403400
      TS = PAD(TS,12);                                                          00403405
      ADDR_TEMP = COREWORD(ADDR(TS)) & "FFFFFF";                                00403500
      CALL PUTN(ROOT_PTR,140,ADDR_TEMP,12,0);                                   00403600
      NODE_F(38) = PTR_TEMP1;                                                   00403605
                                                                                00403700
 /* INSTALL A POINTER TO THE DIRECTORY ROOT NODE IN THE PAGE 0 HEADER */        00403800
                                                                                00403900
      CALL PUTN(0,8,ADDR(ROOT_PTR),4,0);                                        00404000
                                                                                00404100
 /* ALLOCATE THE BLOCK LIST CELLS AND INITIALIZE THEM */                        00404200
      CALL LOCATE(BLOCK_SRN_DATA,ADDR(SRN_BLOCK_RECORD),RESV);                  00404210
      OLD_INT_BLOCK# = SRN_BLOCK_RECORD(0) - 1;                                 00404220
                                                                                00404300
      DO M = 1 TO #PROCS;                                                       00404400
         PROCPOINT  = PROC_TAB8(PROC_TAB6(M));                                  00404500
         BLK_DEX2 = PROC_TAB7(M);                                               00404600
         OP3 = SYT_SORT2(PROC_TAB1(PROCPOINT));                                 00404700
         STACK_ID = SYT_SCOPE(OP3);                                             00404800
         K = LENGTH(SYT_NAME(OP3));                                             00404900
         LEN = 45 + K;                                                          00405000
         PTR_TEMP = GET_DIR_CELL(LEN,ADDR(NODE_F),0);                           00405100
         COREWORD(ADDR(NODE_B)),COREWORD(ADDR(NODE_H)) = LOC_ADDR;              00405200
         PROC_TAB4(BLK_DEX2) = PTR_TEMP;                                        00405300
         NODE_F(0),NODE_F(1) = 0;                                               00405400
         FTEMP = SYT_FLAGS(OP3);                                                00405500
         IF (FTEMP & REENTRANT_FLAG) ^= 0 THEN                                  00405600
            BTEMP = "80";                                                       00405700
         ELSE BTEMP = 0;                                                        00405800
         IF (FTEMP & EXCLUSIVE_FLAG) ^= 0 THEN                                  00405900
            BTEMP = BTEMP | "40";                                               00406000
         IF (FTEMP & ACCESS_FLAG) ^= 0 THEN                                     00406100
            BTEMP = BTEMP | "20";                                               00406200
         IF (FTEMP & RIGID_FLAG) ^= 0 THEN                                      00406300
            BTEMP = BTEMP | "10";                                               00406400
         IF (FTEMP & EXTERNAL_FLAG) ^= 0 THEN                                   00406500
            BTEMP = BTEMP | "08";                                               00406600
         IF (SYT_FLAGS2(OP3) & NONHAL_FLAG) ^= 0 THEN     /* DR108643 */        00406700
            BTEMP = BTEMP | "04";                                               00406800
         NODE_B(24) = BTEMP;                                                    00406900
 /?B     /* CR11114 -- BFS/PASS INTERFACE; ADD VERSION TO SDF */
         NODE_B(25) = SYT_LOCK#(OP3);
 ?/
         NODE_H(13) = BLK_DEX2;                                                 00407000
         NODE_B(44) = K;                                                        00407100
         ADDR_TEMP = COREWORD(ADDR(SYT_NAME(OP3))) & "FFFFFF";                  00407200
         CALL PUTN(PTR_TEMP,45,ADDR_TEMP,K,0);                                  00407300
         NODE_H(16) = PROC_TAB2(PROCPOINT);                                     00407400
         NODE_H(17) = NODE_H(16) + PROC_TAB3(PROCPOINT) - 1;                    00407500
                                                                                00407600
         IF SYT_CLASS(OP3) = LABEL_CLASS THEN                                   00407700
            DO CASE SYT_TYPE(OP3)&"F";                                          00407800
            DO;                   /* MB STMT LABEL */                           00407900
            END;                                                                00408000
            DO;                   /* IND STMT LABEL */                          00408100
            END;                                                                00408200
            DO;                   /* STATEMENT LABEL */                         00408300
               NODE_B(30) = 6;    /* UPDATE BLOCK */                            00408400
               TS = CSECT_NAME(SELFNAMELOC,7,STACK_ID);                         00408500
            END;                                                                00408600
            DO;                   /* UNSPEC LABEL */                            00408700
            END;                                                                00408800
            DO;                   /* MB CALL LABEL */                           00408900
            END;                                                                00409000
            DO;                   /* IND CALL LABEL */                          00409100
            END;                                                                00409200
            DO;                   /* CALLED LABEL */                            00409300
            END;                                                                00409400
            DO;                   /* PROCEDURE LABEL */                         00409500
               NODE_B(30) = 2;                                                  00409600
               /*** DR108643 ***/
               IF (SYT_FLAGS2(OP3) & NONHAL_FLAG) ^= 0 THEN DO;                 00409700
               /*** END DR108643 ***/
                  TS = PAD(SYT_NAME(OP3),8);                                    00409800
               END;                                                             00409900
               ELSE IF (OP3 = SELFNAMELOC)|((FTEMP&EXTERNAL_FLAG)^=0) THEN      00410000
                  DO;                                                           00410100
                  TS = CSECT_NAME(OP3,1,0);                                     00410200
                  STACK_ID = 0;                                                 00410300
               END;                                                             00410400
               ELSE TS = CSECT_NAME(SELFNAMELOC,7,STACK_ID);                    00410500
            END;                                                                00410600
            DO;                   /* TASK LABEL */                              00410700
               NODE_B(30) = 5;                                                  00410800
 /?P           /* CR11114 -- BFS/PASS INTERFACE; CSECT NAMING  */
               /*            CONVENTION                        */
               TS = CSECT_NAME(SELFNAMELOC,0,SYT_DIMS(OP3));                    00410900
 ?/
 /?B              /* CR11114 -- BFS/PASS INTERFACE; CSECT NAMING */
                  /*            CONVENTION                       */
                  IF FC THEN TS=CSECT_NAME(OP3, 0, 0);
                  ELSE TS = CSECT_NAME(SELFNAMELOC,0,SYT_DIMS(OP3));
 ?/
            END;                                                                00411000
            DO;                   /* PROGRAM LABEL */                           00411100
               NODE_B(30) = 1;                                                  00411200
               TS = CSECT_NAME(OP3,0,0);                                        00411300
            END;                                                                00411400
            DO;                   /* COMPOOL LABEL */                           00411500
               NODE_B(30) = 4;                                                  00411600
               TS = CSECT_NAME(OP3,3,0);                                        00411700
            END;                                                                00411800
            DO;                   /* EQUATE LABEL */                            00411900
            END;                                                                00412000
         END;                                                                   00412100
         ELSE DO;                    /* FUNCTION LABEL */                       00412200
            NODE_B(30) = 3;                                                     00412300
            NODE_B(31) = SYT_TYPE(OP3);                                         00412400
            /*** DR108643 ***/
            IF (SYT_FLAGS2(OP3) & NONHAL_FLAG) ^= 0 THEN DO;                    00412500
            /*** END DR108643 ***/
               TS = PAD(SYT_NAME(OP3),8);                                       00412600
            END;                                                                00412700
            ELSE IF (OP3 = SELFNAMELOC)|((FTEMP&EXTERNAL_FLAG)^=0) THEN DO;     00412800
               TS = CSECT_NAME(OP3,1,0);                                        00412900
               STACK_ID = 0;                                                    00413000
            END;                                                                00413100
            ELSE TS = CSECT_NAME(SELFNAMELOC,7,STACK_ID);                       00413200
         END;                                                                   00413300
                                                                                00413400
         NODE_H(14) = STACK_ID;                                                 00413500
         ADDR_TEMP = COREWORD(ADDR(TS)) & "FFFFFF";                             00413600
         PTR = BLOCK_TO_PTR(BLK_DEX2);                                          00413700
         CALL PUTN(PTR,0,ADDR_TEMP,8,0);                                        00413800
         CALL PUTN(PTR,8,ADDR(PTR_TEMP),4,0);                                   00413900
      END;                                                                      00414000
      CALL PTR_LOCATE(BLOCK_SRN_DATA,RELS);                                     00414010
                                                                                00414100
                                                                                00414200
 /* LINK THE BLOCK CELLS INTO A BINARY TREE (ORDERED BY NAME) */                00414300
                                                                                00414400
      CALL P3_LOCATE(ROOT_PTR,ADDR(NODE_H),MODF);                               00414500
      COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                        00414600
      I = SYT_SORT3(SELFNAMELOC);                                               00414700
      NODE_F(11) = PROC_TAB4(I);                                                00414800
      NODE_F(12),BASE_PTR = PROC_TAB4(PROC_TAB7(1));                            00414900
      NODE_H(44) = I;                                                           00415000
                                                                                00415100
      DO I = 2 TO #PROCS;                                                       00415200
         BLK_DEX1 = PROC_TAB7(I);                                               00415300
         PTR_TEMP = PROC_TAB4(BLK_DEX1);                                        00415400
         CUR_PTR = BASE_PTR;                                                    00415500
         DO WHILE CUR_PTR ^= 0;;                                                00415600
               CALL P3_LOCATE(CUR_PTR,ADDR(NODE_H),0);                          00415700
            COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                  00415800
            BLK_DEX2 = NODE_H(13);                                              00415900
            IF BLK_DEX1 > BLK_DEX2 THEN DO;                                     00416000
               CUR_PTR = NODE_F(0);                                             00416100
               IF CUR_PTR = 0 THEN NODE_F(0) = PTR_TEMP;                        00416200
            END;                                                                00416300
            ELSE DO;                                                            00416400
               CUR_PTR = NODE_F(1);                                             00416500
               IF CUR_PTR = 0 THEN NODE_F(1) = PTR_TEMP;                        00416600
            END;                                                                00416700
         END;                                                                   00416800
         CALL P3_DISP(MODF);                                                    00416900
      END;                                                                      00417000
                                                                                00417100
   END INITIALIZE   /*  $S  */  ;   /*  $S  */                                  00417300
