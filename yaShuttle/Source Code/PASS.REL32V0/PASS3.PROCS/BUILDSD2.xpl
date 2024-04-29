 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUILDSD2.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  BUILD_SDF                                              */
 /* MEMBER NAME:     BUILDSD2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #DIMS             BIT(16)                                      */
 /*          #ELTS             FIXED                                        */
 /*          #PAGES            BIT(16)                                      */
 /*          #XREF             BIT(16)                                      */
 /*          #XREF_TO_GO       BIT(16)                                      */
 /*          AAA               LABEL                                        */
 /*          ADDR_TEMP         FIXED                                        */
 /*          ADDRESS           FIXED                                        */
 /*          ARRAY_FACT        FIXED                                        */
 /*          BAD_SRN           LABEL                                        */
 /*          BASE_NO           BIT(16)                                      */
 /*          BLANK_BYTES       BIT(16)                                      */
 /*          BLK_EXT_NODE      FIXED                                        */
 /*          BLK_EXT_PTR       FIXED                                        */
 /*          BLK_INX           BIT(16)                                      */
 /*          BLK_INX_LIM       BIT(16)                                      */
 /*          BLK_LIST_NODE     BIT(16)                                      */
 /*          BLK_NUM           BIT(16)                                      */
 /*          BTEMP             BIT(8)                                       */
 /*          BUILD_XREF_FUNC_TAB  LABEL                                     */
 /*          CELL_TYPE         BIT(16)                                      */
 /*          CLASS             BIT(8)                                       */
 /*          CMPL_FLAG         BIT(8)                                       */
 /*          COEF              FIXED                                        */
 /*          COMPRESS          BIT(8)                                       */
 /*          DEX               BIT(16)                                      */
 /*          DIM_BIAS          BIT(16)                                      */
 /*          EXT_BIAS          BIT(16)                                      */
 /*          EXT_FLAG          BIT(8)                                       */
 /*          EXTENT            FIXED                                        */
 /*          FIRST_OFFSET      BIT(16)                                      */
 /*          FTEMP             FIXED                                        */
 /*          FULL_TEMP         FIXED                                        */
 /*          GET_SDF_CELL      LABEL                                        */
 /*          GET_SYT_VPTR      LABEL                                        */
 /*          GET_XREFS         LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          INX_TO_PTR        LABEL                                        */
 /*          ITEM              BIT(16)                                      */
 /*          IX                BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          J1                BIT(16)                                      */
 /*          J2                BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /*          LAST_CNT          BIT(16)                                      */
 /*          LAST_OFFSET       BIT(16)                                      */
 /*          LAST_SRN          CHARACTER;                                   */
 /*          LEN               BIT(16)                                      */
 /*          LEVEL             BIT(16)                                      */
 /*          LINK              BIT(16)                                      */
 /*          LINK0             BIT(16)                                      */
 /*          LINK1             BIT(16)                                      */
 /*          LINK2             BIT(16)                                      */
 /*          LIT_FLAG          BIT(8)                                       */
 /*          LIT_PTR           BIT(16)                                      */
 /*          LIT_TYPE(17)      BIT(8)                                       */
 /*          LITERAL_DATA_CELL FIXED                                        */
 /*          LOCK_VAL          BIT(8)                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /*          M                 BIT(16)                                      */
 /*          MACROSIZE         FIXED                                        */
 /*          MAX_#PAGES        BIT(16)                                      */
 /*          MAX_#XREF         BIT(16)                                      */
 /*          MAX_CELLS         MACRO                                        */
 /*          MOVE_CELL_TREE    LABEL                                        */
 /*          MOVE_NAME_TERM_CELLS  LABEL                                    */
 /*          N                 BIT(16)                                      */
 /*          NAME_FLG          BIT(8)                                       */
 /*          NAME_LEN          BIT(16)                                      */
 /*          NEXT_CELL         FIXED                                        */
 /*          NEXT_PTR          FIXED                                        */
 /*          NODE_B            BIT(8)                                       */
 /*          NODE_F            FIXED                                        */
 /*          NODE_F1           FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          NODE_H1           BIT(16)                                      */
 /*          NOMATCH           BIT(8)                                       */
 /*          OFFSET            BIT(16)                                      */
 /*          OLD_ADDR          FIXED                                        */
 /*          OLD_LEVEL         BIT(16)                                      */
 /*          OLD_SDF_PTR       FIXED                                        */
 /*          ORIG_SRN          BIT(8)                                       */
 /*          PAGE              BIT(16)                                      */
 /*          PAGE_F            BIT(16)                                      */
 /*          PAGE_L            BIT(16)                                      */
 /*          PREV_PAGE         BIT(16)                                      */
 /*          PREV_PTR          FIXED                                        */
 /*          PROCPOINT         BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /*          PTR_INX           BIT(16)                                      */
 /*          PTR_TEMP          FIXED                                        */
 /*          PTR_TYPE          BIT(16)                                      */
 /*          PTRS(400)         FIXED                                        */
 /*          REENT_FLAG        BIT(8)                                       */
 /*          REPL_LINK         FIXED                                        */
 /*          REPL_TEXT_PTR     FIXED                                        */
 /*          RGD_FLAG          BIT(8)                                       */
 /*          SAVE_PTR          FIXED                                        */
 /*          SDF_REPL_TEXT_PTR FIXED                                        */
 /*          SEARCH_AND_ENQUEUE  LABEL                                      */
 /*          SRN_BUFF(1)       FIXED                                        */
 /*          STACK_ID          BIT(16)                                      */
 /*          STMT_DATA_END     LABEL                                        */
 /*          STMT_EXT_NODE     BIT(16)                                      */
 /*          STMT_EXT_PTR      FIXED                                        */
 /*          STMT_NODE         BIT(16)                                      */
 /*          STMT_PAGE         FIXED                                        */
 /*          STMT_PTR          FIXED                                        */
 /*          STMT_TYPE         BIT(16)                                      */
 /*          STMT#             BIT(16)                                      */
 /*          STRUC_BIAS        BIT(16)                                      */
 /*          STRUC_LINK        BIT(16)                                      */
 /*          SYMB_EXT_NODE     BIT(16)                                      */
 /*          SYMB_EXT_PTR      FIXED                                        */
 /*          SYMB_NODE         BIT(16)                                      */
 /*          SYMB_PTR          FIXED                                        */
 /*          TEMPL_LINK        BIT(16)                                      */
 /*          TEXT_LENGTH       BIT(16)                                      */
 /*          TEXT_PTR          FIXED                                        */
 /*          THIS_CNT          BIT(16)                                      */
 /*          THIS_SRN          CHARACTER;                                   */
 /*          TPL_PTR           FIXED                                        */
 /*          TS                CHARACTER;                                   */
 /*          TYPE              BIT(8)                                       */
 /*          VAR_LENGTH        BIT(16)                                      */
 /*          VAR_OFFSET        FIXED                                        */
 /*          XREF_ADDR         FIXED                                        */
 /*          XREF_BIAS         BIT(16)                                      */
 /*          XREF_CELL         BIT(16)                                      */
 /*          XREF_CNT          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #PROCS                                                         */
 /*          #SYMBOLS                                                       */
 /*          ACCESS_FLAG                                                    */
 /*          ACTUAL_SYMBOLS                                                 */
 /*          ADDR_FLAG                                                      */
 /*          ASSIGN_FLAG                                                    */
 /*          AUTO_FLAG                                                      */
 /*          BIAS                                                           */
 /*          BITMASK_FLAG                                                   */
 /*          COMM                                                           */
 /*          COMPOOL_FLAG                                                   */
 /*          COMPOOL_LABEL                                                  */
 /*          CONST_FLAG                                                     */
 /*          CR_REF                                                         */
 /*          CROSS_REF                                                      */
 /*          DECL_EXP_PTR                                                   */
 /*          DECL_STMT_TYPE                                                 */
 /*          DENSE_FLAG                                                     */
 /*          DMATRIX                                                        */
 /*          DOUBLE_FLAG                                                    */
 /*          DVECTOR                                                        */
 /*          EQUATE_FLAG                                                    */
 /*          EQUATE_LABEL                                                   */
 /*          EQUATE_TYPE                                                    */
 /*          EXCLUSIVE_FLAG                                                 */
 /*          EXTERNAL_FLAG                                                  */
 /*          FALSE                                                          */
 /*          FC                                                             */
 /*          FCDATA_FLAG                                                    */
 /*          FIRST_STMT                                                     */
 /*          FIRST_STMT_PTR                                                 */
 /*          FOREVER                                                        */
 /*          FUNC_CLASS                                                     */
 /*          HALMAT_CELL                                                    */
 /*          HMAT_OPT                                                       */
 /*          INDIRECT_FLAG                                                  */
 /*          INIT_FLAG                                                      */
 /*          INPUT_PARM                                                     */
 /*          INTEGER                                                        */
 /*          LABEL_CLASS                                                    */
 /*          LABEL_TAB                                                      */
 /*          LAST_STMT_PTR                                                  */
 /*          LATCH_FLAG                                                     */
 /*          LHS_PTR                                                        */
 /*          LINK_FLAG                                                      */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          LOC_ADDR                                                       */
 /*          LOCK_FLAG                                                      */
 /*          MATRIX                                                         */
 /*          MAX_CELL                                                       */
 /*          MISC_NAME_FLAG                                                 */
 /*          MODF                                                           */
 /*          NAME_FLAG                                                      */
 /*          NILL                                                           */
 /*          NONHAL_FLAG                                                    */
 /*          OBJECT_MACHINE                                                 */
 /*          OVERFLOW                                                       */
 /*          PAGE_SIZE                                                      */
 /*          PHASE3_ERROR                                                   */
 /*          POINTER_PREFIX                                                 */
 /*          PROC_LABEL                                                     */
 /*          PROC_TAB1                                                      */
 /*          PROC_TAB2                                                      */
 /*          PROC_TAB3                                                      */
 /*          PROC_TAB4                                                      */
 /*          PROC_TAB5                                                      */
 /*          PROC_TAB8                                                      */
 /*          PROG_LABEL                                                     */
 /*          P3ERR                                                          */
 /*          REENTRANT_FLAG                                                 */
 /*          REF_STMT                                                       */
 /*          RELS                                                           */
 /*          REMOTE_FLAG                                                    */
 /*          REPL_CLASS                                                     */
 /*          RESV                                                           */
 /*          RHS_PTR                                                        */
 /*          RIGID_FLAG                                                     */
 /*          ROOT_PTR                                                       */
 /*          SAVE_NDECSY                                                    */
 /*          SCALAR                                                         */
 /*          SDC_FLAGS                                                      */
 /*          SELFNAMELOC                                                    */
 /*          SORTING                                                        */
 /*          SRN_FLAG                                                       */
 /*          STMT_DATA_HEAD                                                 */
 /*          STMT_NODE_SIZE                                                 */
 /*          STRUCTURE                                                      */
 /*          SYM_ADDR                                                       */
 /*          SYM_ADD                                                        */
 /*          SYM_ARRAY                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_LOCK#                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_NUM                                                        */
 /*          SYM_PTR                                                        */
 /*          SYM_SCOPE                                                      */
 /*          SYM_SORT1                                                      */
 /*          SYM_SORT2                                                      */
 /*          SYM_SORT3                                                      */
 /*          SYM_SORT4                                                      */
 /*          SYM_TYPE                                                       */
 /*          SYM_VPTR                                                       */
 /*          SYM_XREF                                                       */
 /*          SYMB_NODE_SIZE                                                 */
 /*          SYT_ADDR                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_CLASS                                                      */
 /*          SYT_DIMS                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_LOCK#                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_NUM                                                        */
 /*          SYT_PTR                                                        */
 /*          SYT_SCOPE                                                      */
 /*          SYT_SORT1                                                      */
 /*          SYT_SORT2                                                      */
 /*          SYT_SORT3                                                      */
 /*          SYT_SORT4                                                      */
 /*          SYT_TYPE                                                       */
 /*          SYT_VPTR                                                       */
 /*          SYT_VPTR_FLAG                                                  */
 /*          SYT_XREF                                                       */
 /*          TASK_LABEL                                                     */
 /*          TEMP_TYPE                                                      */
 /*          TEMPLATE_CLASS                                                 */
 /*          TEMPORARY_FLAG                                                 */
 /*          TPL_FUNC_CLASS                                                 */
 /*          TPL_LAB_CLASS                                                  */
 /*          TRUE                                                           */
 /*          VAR_CLASS                                                      */
 /*          VAR_EXTENT                                                     */
 /*          VECTOR                                                         */
 /*          VMEM_LOC_ADDR                                                  */
 /*          VMEM_LOC_PTR                                                   */
 /*          XREF_MAX                                                       */
 /*          XREF                                                           */
 /*          XTNT                                                           */
 /*          X1                                                             */
 /*          X10                                                            */
 /*          X2                                                             */
 /*          X4                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          #EXECS                                                         */
 /*          #LABELS                                                        */
 /*          #LHS                                                           */
 /*          #TPLS2                                                         */
 /*          #UNQUAL                                                        */
 /*          DATA_CELL_PTR                                                  */
 /*          LHS_TAB                                                        */
 /*          LIT_ADDR                                                       */
 /*          OP3                                                            */
 /*          PROC_FLAGS                                                     */
 /*          PROC_TAB9                                                      */
 /*          RIGID_CPL_FLAG                                                 */
 /*          SRN_FLAG1                                                      */
 /*          SRN_FLAG2                                                      */
 /*          STAB_FIXED_LEN                                                 */
 /*          STMT_DATA                                                      */
 /*          SYM_TAB                                                        */
 /*          TPL_TAB1                                                       */
 /*          TPL_TAB2                                                       */
 /*          XREF_TAB                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLOCK_TO_PTR                                                   */
 /*          BUILD_SDF_LITTAB                                               */
 /*          EXTRACT4                                                       */
 /*          GET_DATA_CELL                                                  */
 /*          GET_DIR_CELL                                                   */
 /*          GET_LITERAL                                                    */
 /*          GET_STMT_DATA                                                  */
 /*          GETARRAY#                                                      */
 /*          GETARRAYDIM                                                    */
 /*          HEX                                                            */
 /*          LOCATE                                                         */
 /*          MIN                                                            */
 /*          MOVE                                                           */
 /*          PTR_LOCATE                                                     */
 /*          PUTN                                                           */
 /*          P3_DISP                                                        */
 /*          P3_LOCATE                                                      */
 /*          P3_PTR_LOCATE                                                  */
 /*          STMT_TO_PTR                                                    */
 /*          SYMB_TO_PTR                                                    */
 /*          TRAN                                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BUILD_SDF <==                                                       */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> HEX                                                             */
 /*     ==> MIN                                                             */
 /*     ==> MOVE                                                            */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> LOCATE                                                          */
 /*     ==> GETARRAYDIM                                                     */
 /*     ==> GETARRAY#                                                       */
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
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*     ==> EXTRACT4                                                        */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*     ==> PUTN                                                            */
 /*         ==> MOVE                                                        */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*     ==> TRAN                                                            */
 /*         ==> MOVE                                                        */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*     ==> GET_DIR_CELL                                                    */
 /*         ==> P3_GET_CELL                                                 */
 /*             ==> P3_DISP                                                 */
 /*             ==> P3_LOCATE                                               */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /*             ==> PUTN                                                    */
 /*                 ==> MOVE                                                */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /*     ==> GET_DATA_CELL                                                   */
 /*         ==> P3_GET_CELL                                                 */
 /*             ==> P3_DISP                                                 */
 /*             ==> P3_LOCATE                                               */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /*             ==> PUTN                                                    */
 /*                 ==> MOVE                                                */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /*     ==> BUILD_SDF_LITTAB                                                */
 /*         ==> GET_LITERAL                                                 */
 /*         ==> MIN                                                         */
 /*         ==> MOVE                                                        */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*         ==> P3_LOCATE                                                   */
 /*             ==> P3_PTR_LOCATE                                           */
 /*                 ==> HEX8                                                */
 /*                 ==> ZERO_CORE                                           */
 /*                 ==> P3_DISP                                             */
 /*                 ==> PAGING_STRATEGY                                     */
 /*         ==> GET_DATA_CELL                                               */
 /*             ==> P3_GET_CELL                                             */
 /*                 ==> P3_DISP                                             */
 /*                 ==> P3_LOCATE                                           */
 /*                     ==> P3_PTR_LOCATE                                   */
 /*                         ==> HEX8                                        */
 /*                         ==> ZERO_CORE                                   */
 /*                         ==> P3_DISP                                     */
 /*                         ==> PAGING_STRATEGY                             */
 /*                 ==> PUTN                                                */
 /*                     ==> MOVE                                            */
 /*                     ==> P3_PTR_LOCATE                                   */
 /*                         ==> HEX8                                        */
 /*                         ==> ZERO_CORE                                   */
 /*                         ==> P3_DISP                                     */
 /*                         ==> PAGING_STRATEGY                             */
 /*     ==> GET_STMT_DATA                                                   */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> LOCATE                                                      */
 /*         ==> CHECK_COMPOUND                                              */
 /*         ==> LHS_CHECK                                                   */
 /*         ==> REFORMAT_HALMAT                                             */
 /*             ==> MIN                                                     */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> LOCATE                                                  */
 /*             ==> P3_PTR_LOCATE                                           */
 /*                 ==> HEX8                                                */
 /*                 ==> ZERO_CORE                                           */
 /*                 ==> P3_DISP                                             */
 /*                 ==> PAGING_STRATEGY                                     */
 /*             ==> GET_DATA_CELL                                           */
 /*                 ==> P3_GET_CELL                                         */
 /*                     ==> P3_DISP                                         */
 /*                     ==> P3_LOCATE                                       */
 /*                         ==> P3_PTR_LOCATE                               */
 /*                             ==> HEX8                                    */
 /*                             ==> ZERO_CORE                               */
 /*                             ==> P3_DISP                                 */
 /*                             ==> PAGING_STRATEGY                         */
 /*                     ==> PUTN                                            */
 /*                         ==> MOVE                                        */
 /*                         ==> P3_PTR_LOCATE                               */
 /*                             ==> HEX8                                    */
 /*                             ==> ZERO_CORE                               */
 /*                             ==> P3_DISP                                 */
 /*                             ==> PAGING_STRATEGY                         */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*10/05/90 RPC   23V1  102963 PHASE 3 INTERNAL ERROR                       */
 /*                                                                         */
 /*01/21/91 DKB   23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /*05/24/93 RAH   25V0  105709 STATEMENT ENTRY TABLE IN SDF CONTAINS        */
 /*                9V0         INCORRECT REFERENCES TO SRNS                 */
 /*                                                                         */
 /*04/05/94 JAC   26V0  108643 INCORRECTLY LISTS 'NONHAL' INSTEAD OF        */
 /*               10V0         'INCREM' IN SDFLIST                          */
 /*                                                                         */
 /*02/18/98 SMR   29V0 CR12940 ENHANCE COMPILER LISTING                     */
 /*               14V0                                                      */
 /*                                                                         */
 /*07/14/99 DCP   30V0 CR12214 USE THE SAFEST %MACRO THAT WORKS             */
 /*               15V0                                                      */
 /*                                                                         */
 /*04/08/99 SMR   30V0 CR13079 ADD HAL/S INITIALIZATION DATA TO SDF         */
 /*               15V0                                                      */
 /*                                                                         */
 /*02/14/01 TKN   31V0 DR111357 SYMBOL # OF THE BLOCK NAME INCORRECT        */
 /*               16V0          IN THE BLOCK DATA CELL                      */
 /*                                                                         */
 /*03/02/01 DAS   31V0 CR13353 ADD SIZE OF BUILTIN FUNCTIONS XREF TABLE     */
 /*               16V0         INTO SDF                                     */
 /*                                                                         */
 /***************************************************************************/
                                                                                00417400
 /* SDF CONSTRUCTION LOGIC */                                                   00417500
                                                                                00417600
BUILD_SDF:                                                                      00417700
   PROCEDURE;                                                                   00417800
      DECLARE  (STMT_PTR,STMT_EXT_PTR,PTR,BLK_EXT_PTR,PREV_PTR,FTEMP) FIXED,    00417900
         (OLD_ADDR,ADDR_TEMP,SYMB_PTR,SYMB_EXT_PTR,SAVE_PTR) FIXED,             00418000
         (VAR_OFFSET,ADDRESS,PTR_TEMP,FULL_TEMP,EXTENT) FIXED,                  00418100
         (NEXT_PTR,TPL_PTR,XREF_ADDR,COEF,#ELTS,ARRAY_FACT) FIXED,              00418200
         SRN_BUFF(1) FIXED, (CLASS, TYPE, BTEMP,LOCK_VAL) BIT(8),               00418300
         LIT_TYPE(17) BIT(8) INITIAL(0,1,2,0,0,3,3,0,0,1,1,0,0,3,3,0,0,0),      00418310
         (LITERAL_DATA_CELL,TEXT_PTR) FIXED, LIT_PTR BIT(16),                   00418320
         (LIT_FLAG,EXT_FLAG,COMPRESS,NOMATCH,CMPL_FLAG,REENT_FLAG) BIT(1),      00418400
         (ORIG_SRN,RGD_FLAG,NAME_FLG) BIT(1),                                   00418500
         (PAGE_F,PAGE_L,BLK_INX,BLK_INX_LIM,#PAGES,LEN,NAME_LEN) BIT(16),       00418600
         (BASE_NO,MAX_#PAGES,FIRST_OFFSET,LAST_OFFSET,LOC1,LOC2) BIT(16),       00418700
         (EXT_BIAS,VAR_LENGTH,MAX_#XREF,XREF_CNT,#XREF_TO_GO) BIT(16),          00418800
         (#DIMS,#XREF,DIM_BIAS,LINK0,LINK1,LINK2,BLK_NUM) BIT(16),              00418900
         (STACK_ID,PREV_PAGE,STRUC_BIAS,XREF_BIAS,PROCPOINT) BIT(16),           00419000
         (IX,LINK,TEMPL_LINK,STRUC_LINK,LEVEL,OLD_LEVEL,DEX) BIT(16),           00419100
         (CELL_TYPE,ITEM,THIS_CNT,LAST_CNT) BIT(16),                            00419200
         (OLD_SDF_PTR,NEXT_CELL,REPL_TEXT_PTR,SDF_REPL_TEXT_PTR) FIXED,         00419210
         MACROSIZE FIXED,                                                       00419220
         (BLANK_BYTES,TEXT_LENGTH) BIT(16),                                     00419230
         (I,J,J1,J2,K,L,M,N,STMT#,STMT_TYPE,PAGE,OFFSET) BIT(16);               00419300
      DECLARE (PTR_INX,PTR_TYPE) BIT(16),                                       00419310
         MAX_CELLS LITERALLY '400',                                             00419320
         PTRS(MAX_CELLS) FIXED;  /* SHOULD PROBABLY MAKE THIS SPACE             00419330
                              MANAGED RATHER THAN A SIMPLE ARRAY */             00419340
      DECLARE  (TS,THIS_SRN,LAST_SRN) CHARACTER;                                00419400
      BASED    (NODE_H,STMT_NODE,STMT_EXT_NODE,SYMB_NODE,SYMB_EXT_NODE) BIT(16);00419500
      BASED    (BLK_LIST_NODE,XREF_CELL) BIT(16), NODE_B BIT(8),                00419600
         (STMT_PAGE,BLK_EXT_NODE,NODE_F,NODE_F1,REPL_LINK) FIXED;               00419610
      BASED    NODE_H1 BIT(16);                                                 00419620
                                                                                00419800
SEARCH_AND_ENQUEUE:                                                             00419900
      PROCEDURE(PREV_SYMB,SUBJ_SYMB,REL_ADDR,TYPE);                             00420000
         DECLARE (SUBJ_PTR,PREV_SYMB,REL_ADDR,TYPE) FIXED,                      00420100
            (SUBJ_SYMB,NEXT_SYMB) BIT(16);                                      00420200
                                                                                00420300
         PTR_TEMP = SYMB_TO_PTR(SUBJ_SYMB);                                     00420400
         SUBJ_PTR = EXTRACT4(PTR_TEMP,8,0) - 2;                                 00420500
         DO CASE TYPE;                                                          00420600
            PREV_PTR = ROOT_PTR + 32;     /* CASE 0: #D#P  */                   00420820
         PREV_PTR = ROOT_PTR + 32;     /* CASE 1:#D(FC ONLY--LOCAL BLOCK DATA)*/00421120
            PREV_PTR = ROOT_PTR + 34;     /* CASE 2: #R */                      00421420
            PREV_PTR = PROC_TAB4(I) + 42; /* CASE 3: STACK DATA */              00421700
            PREV_PTR = PREV_SYMB - 2;     /* CASE 4: TEMPLATE DATA */           00422000
         END;                                                                   00422200
         CALL P3_LOCATE(PREV_PTR,ADDR(NODE_H),0);                               00422300
         NEXT_SYMB = NODE_H(0);                                                 00422400
         DO WHILE NEXT_SYMB ^= 0;                                               00422500
            PTR_TEMP = SYMB_TO_PTR(NEXT_SYMB);                                  00422600
            NEXT_PTR = EXTRACT4(PTR_TEMP,8,0) - 2;                              00422700
            CALL P3_LOCATE(NEXT_PTR+2,ADDR(NODE_F),0);                          00422800
            COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                  00422900
            IF (NODE_F(2) & "00000200") ^= 0 THEN DO;                           00423000
               IF NODE_H(10) > REL_ADDR THEN GO TO INSERT;                      00423100
            END;                                                                00423200
            ELSE IF (NODE_F(3) & "FFFFFF") > REL_ADDR THEN                      00423300
               GO TO INSERT;                                                    00423400
            NEXT_SYMB = NODE_F(-1) & "FFFF";                                    00423500
            PREV_PTR = NEXT_PTR;                                                00423600
         END;                                                                   00423700
         IF (CMPL_FLAG=FALSE)&((TYPE=0)|(TYPE=1)) THEN                          00423705
            LIT_ADDR = REL_ADDR + EXTENT;                                       00423710
INSERT:                                                                         00423800
         CALL PUTN(PREV_PTR,0,ADDR(SUBJ_SYMB),2,0);                             00423900
         IF (TYPE = 4) | (NEXT_SYMB ^= 0) THEN                                  00424000
            CALL PUTN(SUBJ_PTR,0,ADDR(NEXT_SYMB),2,0);                          00424100
      END SEARCH_AND_ENQUEUE;                                                   00424300
                                                                                00424400
GET_SDF_CELL:                                                                   00424401
      PROCEDURE (VMEM_PTR) FIXED;                                               00424402
         DECLARE (VMEM_PTR,SDF_PTR) FIXED;                                      00424403
         BASED NODE_H BIT(16), NODE_F FIXED;                                    00424404
                                                                                00424405
         PTR_TYPE = SHR(VMEM_PTR,30) & 3;                                       00424406
         CALL LOCATE(VMEM_PTR & "3FFFFFFF",ADDR(NODE_H),0);                     00424407
         SDF_PTR = GET_DATA_CELL(NODE_H(0),ADDR(NODE_F),0) | SHL(PTR_TYPE,30);  00424408
         CALL MOVE(NODE_H(0),VMEM_LOC_ADDR,LOC_ADDR);                           00424409
         PTR_INX = PTR_INX + 1;                                                 00424410
         IF PTR_INX > 400 THEN DO;                                              00424411
            OUTPUT = X1;                                                        00424412
            OUTPUT = P3ERR || 'CELL PTR STACK OVERFLOW ***';                    00424413
            GO TO PHASE3_ERROR;                                                 00424414
         END;                                                                   00424415
         PTRS(PTR_INX) = SDF_PTR;                                               00424416
         RETURN SDF_PTR;                                                        00424417
      END GET_SDF_CELL;                                                         00424418
                                                                                00424419
 /* ROUTINE TO MOVE VMEM CELL TREES INTO THE SDF AND CHANGE PH1 SYMBOL          00424420
      NUMBERS TO PH3 SYMBOL INDICES */                                          00424421
MOVE_CELL_TREE:                                                                 00424422
      PROCEDURE (PTR,DOING_NAMETERMS) FIXED;                                    00424423
         DECLARE (PTR,RETURN_PTR) FIXED, (J,DOING_NAMETERMS) BIT(16);           00424424
         BASED NODE_H BIT(16), NODE_F FIXED;                                    00424425
                                                                                00424426
DO_VAR_REF_CELL:                                                                00424427
         PROCEDURE;                                                             00424428
            CALL P3_LOCATE(PTR,ADDR(NODE_H),MODF|RESV);                         00424429
            COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                  00424430
            DO J = 4 TO (NODE_H(1) & "7FFF") + 3;                               00424431
               NODE_H(J) = SYT_SORT1(NODE_H(J));                                00424432
            END;                                                                00424433
            IF NODE_F(1) ^= 0 THEN                                              00424434
               NODE_F(1)=GET_SDF_CELL(NODE_F(1)|"80000000") & "3FFFFFFF";       00424435
            CALL P3_PTR_LOCATE(PTR,RELS);                                       00424436
         END DO_VAR_REF_CELL;                                                   00424437
                                                                                00424438
DO_PF_INV_CELL:                                                                 00424439
         PROCEDURE;                                                             00424440
            DECLARE XTERNAL BIT(8);                                             00424441
                                                                                00424442
            CALL P3_LOCATE(PTR,ADDR(NODE_H),MODF|RESV);                         00424443
            COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                  00424444
            IF (SYT_FLAGS(NODE_H(3)) & EXTERNAL_FLAG) ^= 0 THEN DO;             00424445
               XTERNAL = TRUE;                                                  00424446
               NODE_H(0) = SHL(NODE_H(1)+2,2);                                  00424447
            END;                                                                00424448
            ELSE XTERNAL = FALSE;                                               00424449
            NODE_H(3) = SYT_SORT1(NODE_H(3));                                   00424450
            DO J = 2 TO NODE_H(1) + 1;                                          00424451
               IF NODE_F(J) ^= 0 THEN DO;                                       00424452
                  IF (NODE_F(J) & "C0000000") = "C0000000" THEN                 00424453
                     NODE_H(J+J+1) = SYT_SORT1(NODE_H(J+J+1));                  00424454
                  ELSE NODE_F(J) = GET_SDF_CELL(NODE_F(J));                     00424455
               END;                                                             00424456
            END;                                                                00424457
            IF ^XTERNAL THEN                                                    00424458
            DO J = SHL(NODE_H(1) + 2,1) TO SHL(NODE_H(1) + 2,1) + NODE_H(1) - 1;00424459
               NODE_H(J) = SYT_SORT1(NODE_H(J));                                00424460
            END;                                                                00424461
            CALL P3_PTR_LOCATE(PTR,RELS);                                       00424462
         END DO_PF_INV_CELL;                                                    00424463
                                                                                00424464
DO_EXP_VARS_CELL:                                                               00424465
         PROCEDURE;                                                             00424466
            CALL P3_LOCATE(PTR,ADDR(NODE_H),MODF|RESV);                         00424467
            COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                  00424468
            DO J = 2 TO NODE_H(1) + 1;                                          00424469
               IF NODE_H(J) > 0 THEN NODE_H(J) = SYT_SORT1(NODE_H(J));          00424470
            END;                                                                00424471
            DO J = SHR(NODE_H(1) + 3,1) TO SHR(NODE_H(0),2) - 1;                00424472
               IF (NODE_F(J) & "C0000000") ^= "C0000000" THEN                   00424473
                  NODE_F(J) = GET_SDF_CELL(NODE_F(J));                          00424474
            END;                                                                00424475
            CALL P3_PTR_LOCATE(PTR,RELS);                                       00424476
         END DO_EXP_VARS_CELL;                                                  00424477
                                                                                00424478
                                                                                00424479
         IF ^DOING_NAMETERMS THEN DO;                                           00424480
            PTR_INX = 0;                                                        00424481
            RETURN_PTR = GET_SDF_CELL(PTR);                                     00424482
            PTRS(PTR_INX) = PTRS(PTR_INX) | "80000000";                         00424483
         END;                                                                   00424484
         ELSE DOING_NAMETERMS = FALSE;                                          00424485
         DO WHILE PTR_INX > 0;                                                  00424486
            PTR = PTRS(PTR_INX);                                                00424487
            PTR_INX = PTR_INX - 1;                                              00424488
            PTR_TYPE = SHR(PTR,30) & 3;                                         00424489
            PTR = PTR & "3FFFFFFF";                                             00424490
            DO CASE PTR_TYPE;                                                   00424491
               CALL DO_VAR_REF_CELL;                                            00424492
               CALL DO_PF_INV_CELL;                                             00424493
               CALL DO_EXP_VARS_CELL;                                           00424494
               ;                                                                00424495
            END;                                                                00424496
         END;                                                                   00424497
         RETURN RETURN_PTR;                                                     00424498
      END MOVE_CELL_TREE;                                                       00424499
                                                                                00424500
MOVE_NAME_TERM_CELLS:                                                           00424501
      PROCEDURE(VPTR);                                                          00424502
         DECLARE (J,VR_INX,K) BIT(16), (CELL_PTR,VPTR) FIXED,                   00424503
            VAR_REF_CELL(MAX_CELLS) FIXED; /* SAME SIZE AS 'PTRS' */            00424504
         BASED NODE_H BIT(16), NODE_F FIXED;                                    00424505
                                                                                00424506
         PREV_PTR = 0;                                                          00424507
         DO WHILE VPTR ^= 0;                                                    00424508
            CALL LOCATE(VPTR,ADDR(NODE_H),0);                                   00424509
            LEN = NODE_H(0);                                                    00424510
            PTR = GET_DATA_CELL(LEN,ADDR(NODE_F),0);                            00424511
            CALL MOVE(LEN,VMEM_LOC_ADDR,LOC_ADDR);                              00424512
            VPTR = NODE_F(1);                                                   00424513
            NODE_F(1) = PREV_PTR;                                               00424514
            PREV_PTR = PTR;                                                     00424515
            COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                  00424516
            DO J = 4 TO NODE_H(1) + 3;                                          00424517
               NODE_H(J) = SYT_SORT1(NODE_H(J));                                00424518
            END;                                                                00424519
            J = (NODE_H(1)+5) & "FFFE";                                         00424520
DO_EXTENSION_CELL:PTR_INX, VR_INX = 0;                                          00424521
            DO WHILE J < SHR(NODE_H(0),1);                                      00424522
               IF (NODE_H(J) & "FFFC") ^= 0 THEN DO;                            00424523
                OUTPUT = P3ERR ||'MALFORMED NAME TERM CELL:'||HEX(VMEM_LOC_PTR);00424524
                  PREV_PTR = NODE_F(1);                                         00424525
                  GO TO SKIP_THIS_CELL;                                         00424526
               END;                                                             00424527
               DO CASE NODE_H(J);                                               00424528
                  DO;                                                           00424529
                     CELL_PTR = NODE_F(SHR(J+2,1));                             00424530
                     IF CELL_PTR > 0 THEN DO;                                   00424531
                        DO K = 1 TO VR_INX;                                     00424532
                           IF VAR_REF_CELL(K) = CELL_PTR THEN DO;               00424533
                              NODE_F(SHR(J+2,1)) = PTRS(K);                     00424534
                              GO TO PTR_FOUND;                                  00424535
                           END;                                                 00424536
                        END;                                                    00424537
                        NODE_F(SHR(J+2,1)) = GET_SDF_CELL(CELL_PTR);            00424538
                        VR_INX = PTR_INX;                                       00424539
                        VAR_REF_CELL(VR_INX) = CELL_PTR;                        00424540
                     END;                                                       00424541
                     ELSE NODE_H(J+3) = SYT_SORT1(NODE_H(J+3));                 00424542
PTR_FOUND:                                                                      00424543
                     J = J + 4;                                                 00424544
                  END;                                                          00424545
                  J = J + 4;                                                    00424546
                  J = J + 2;                                                    00424547
                  IF NODE_H(J+1)=0 THEN J = J + 2;                              00424548
                  ELSE DO;                                                      00424549
                     CALL MOVE_CELL_TREE(0,1);                                  00424550
                     NODE_F(SHR(J+2,1)) = GET_SDF_CELL(NODE_F(SHR(J+2,1)));     00424551
                     COREWORD(ADDR(NODE_H)), COREWORD(ADDR(NODE_F)) = LOC_ADDR; 00424552
                     J = 2;                                                     00424553
                     GO TO DO_EXTENSION_CELL;                                   00424554
                  END;                                                          00424555
               END;                                                             00424556
            END;                                                                00424557
            CALL MOVE_CELL_TREE(0,1);                                           00424558
SKIP_THIS_CELL:                                                                 00424559
         END;                                                                   00424560
      END MOVE_NAME_TERM_CELLS;                                                 00424561
                                                                                00424562
GET_SYT_VPTR:                                                                   00424563
      PROCEDURE (SYMB) FIXED;                                                   00424564
         DECLARE (SYMB,I,J,K) BIT(16);                                          00424565
                                                                                00424566
         IF EXT_FLAG THEN RETURN 0;                                             00424567
         I = 1;                                                                 00424568
         K = SYT_VPTR(0);                                                       00424569
         DO FOREVER;                                                            00424570
            J = SHR(I+K,1);                                                     00424571
            IF SYT_NUM(J) = SYMB THEN RETURN SYT_VPTR(J);                       00424572
            IF SYT_NUM(J) < SYMB THEN DO;                                       00424573
               IF J = K THEN RETURN 0;                                          00424574
               ELSE I = J + 1;                                                  00424575
            END;                                                                00424576
            ELSE DO;                                                            00424577
               IF J = I THEN RETURN 0;                                          00424578
               ELSE K = J - 1;                                                  00424579
            END;                                                                00424580
         END;                                                                   00424581
      END GET_SYT_VPTR;                                                         00424582
                                                                                00424583
BASED DIR_H BIT(16); /*CR13353*/

BUILD_XREF_FUNC_TAB:                                                            00424593
      PROCEDURE FIXED;                                                          00424603
         DECLARE TAB_SZ LITERALLY '(BI_XREF#(0)*8)',                            00424613
            BI# LITERALLY '63',                                                 00424623
            BI_XREF_CELL LITERALLY 'COMM(29)';                                  00424633
         DECLARE (I,TAB_NDX) BIT(16),                                           00424643
            XREF_FUNC_TAB FIXED;                                                00424653
         BASED NODE_F FIXED;                                                    00424663
         DECLARE BI_XREF(BI#) BIT(16);                                          00424673
         DECLARE BI_XREF#(BI#) BIT(16);                                         00424683
                                                                                00424693
FUNC_DATA_CELL:                                                                 00424703
         PROCEDURE(LOC) FIXED;                                                  00424713
            DECLARE (LOC,INDEX,I) BIT(16),                                      00424723
               (RCELL,CELL,PTR,LINK) FIXED;                                     00424733
            BASED NODE_H BIT(16);                                               00424743
            DECLARE NEXT_TO_LAST LITERALLY '837',                               00424753
               CELL_SZ(1) LITERALLY 'MIN(2*%1%,PAGE_SIZE)';                     00424763
                                                                                00424773
            RCELL,CELL = GET_DATA_CELL(CELL_SZ(BI_XREF#(LOC)+1),ADDR(NODE_H),   00424783
               MODF|RESV);                                                      00424793
            NODE_H(0) = BI_XREF#(LOC);                                          00424803
            INDEX = 1;                                                          00424813
            PTR = BI_XREF(LOC);                                                 00424823
            DO I = 1 TO NODE_H(0);                                              00424833
               IF (INDEX = NEXT_TO_LAST) & (I < (NODE_H(0)-3))                  00424843
                  THEN DO;  /* EXTENSION BLOCK NEEDED */                        00424853
                  NODE_H(INDEX) = POINTER_PREFIX;                               00424863
                  LINK = ADDR(NODE_H(INDEX+1));                                 00424873
                  CALL P3_PTR_LOCATE(CELL,RELS);                                00424883
                  CELL,COREWORD(LINK)=GET_DATA_CELL(CELL_SZ(BI_XREF#(LOC)-I),   00424893
                     ADDR(NODE_H),MODF|RESV);                                   00424903
                  INDEX = 0;                                                    00424913
               END;                                                             00424923
               NODE_H(INDEX) = (XREF(PTR) & "FFFF");                            00424933
               PTR = SHR(XREF(PTR),16);                                         00424943
               INDEX = INDEX+1;                                                 00424953
            END;                                                                00424963
            CALL P3_PTR_LOCATE(CELL,RELS);                                      00424973
            RETURN RCELL;                                                       00424983
         END FUNC_DATA_CELL;                                                    00424993
                                                                                00425003
 /* READ IN BI_XREF ARRAYS FROM VMEM */                                         00425013
         CALL LOCATE(BI_XREF_CELL,ADDR(NODE_F),0);                              00425023
         IF SHR(NODE_F(0),16) = 0 THEN RETURN NILL; /* NO BI XREF DATA */       00425033
         DO I = 0 TO BI#;                                                       00425043
            BI_XREF#(I) = SHR(NODE_F(I),16);                                    00425053
            BI_XREF(I) = (NODE_F(I) & "FFFF");                                  00425063
         END;                                                                   00425073
                                                                                00425083
         XREF_FUNC_TAB = GET_DATA_CELL(TAB_SZ,ADDR(NODE_F),MODF|RESV);          00425093
         TAB_NDX = 0;                                                           00425103
         DO I = 1 TO BI#;                                                       00425113
            IF BI_XREF(I) ^= 0                                                  00425123
               THEN DO;                                                         00425133
               NODE_F(TAB_NDX) = I;  /* CODE OF FUNCTION TYPE */                00425143
               NODE_F(TAB_NDX+1) = FUNC_DATA_CELL(I);                           00425153
               TAB_NDX = TAB_NDX+2;                                             00425163
            END;                                                                00425173
         END;                                                                   00425183
         DIR_H(92) = TAB_NDX/2; /*CR13353 - # OF FUNCTION XREF TABLE ENTRIES */
         CALL P3_PTR_LOCATE(XREF_FUNC_TAB,RELS);                                00425193
         RETURN XREF_FUNC_TAB;                                                  00425203
      END BUILD_XREF_FUNC_TAB;                                                  00425213
                                                                                00425223
                                                                                00425233
                                                                                00425243
 /* CREATE FUNCTION XREF CELL AND CORRESPONDING DATA CELLS */                   00425253
      CALL P3_LOCATE(ROOT_PTR,ADDR(NODE_F),MODF);                               00425263
      COREWORD(ADDR(DIR_H)) = COREWORD(ADDR(NODE_F)); /*CR13353*/
      NODE_F(45) = BUILD_XREF_FUNC_TAB;                                         00425273
                                                                                00425283
                                                                                00425293
 /* IF HMAT_OPT, THEN READ IN THE LIT TABLE AND LITCHAR TABLE */                00425303
      IF HMAT_OPT THEN CALL BUILD_SDF_LITTAB;                                   00425313
 /* ALLOCATE THE SYMBOL NODES AND THEIR CORRESPONDING DATA CELLS */             00425323
                                                                                00425333
      #TPLS2 = 0;                                                               00425343
      DO I = 1 TO #PROCS;                                                       00425353
         PTR_TEMP = PROC_TAB4(I);                                               00425363
         CALL P3_LOCATE(PTR_TEMP,ADDR(NODE_H),0);                               00425373
         STACK_ID = NODE_H(14);                                                 00425383
         PROCPOINT = PROC_TAB8(PROC_TAB5(I));                                   00425393
         BASE_NO,OP3 = SYT_SORT2(PROC_TAB1(PROCPOINT));                         00425403
         CMPL_FLAG = FALSE;                                                     00425413
         IF SYT_TYPE(OP3) = COMPOOL_LABEL THEN CMPL_FLAG = TRUE;                00425500
         REENT_FLAG = FALSE;                                                    00425600
         IF (SYT_FLAGS(OP3) & REENTRANT_FLAG) ^= 0 THEN REENT_FLAG = TRUE;      00425700
         EXT_FLAG = FALSE;                                                      00425800
         IF (SYT_FLAGS(OP3) & EXTERNAL_FLAG) ^= 0 THEN EXT_FLAG = TRUE;         00425900
         RGD_FLAG = FALSE;                                                      00426000
         IF ((SYT_FLAGS(OP3)&RIGID_FLAG)^=0)&(OP3=SELFNAMELOC)&                 00426100
            (CMPL_FLAG=TRUE) THEN DO;                                           00426200
            RGD_FLAG = TRUE;                                                    00426300
            RIGID_CPL_FLAG = TRUE;                                              00426400
         END;                                                                   00426500
         J1 = PROC_TAB2(PROCPOINT);                                             00426600
         J2 = J1 + PROC_TAB3(PROCPOINT) - 1;                                    00426700
         BLK_INX = 0;                                                           00426800
         PAGE_F = SHR(SYMB_TO_PTR(J1),16);                                      00426900
         PAGE_L = SHR(SYMB_TO_PTR(J2),16);                                      00427000
         PREV_PAGE = PAGE_F;                                                    00427100
         IF PAGE_F ^= PAGE_L THEN DO;                                           00427200
            #PAGES = PAGE_L - PAGE_F + 1;                                       00427300
            LEN = 8 + 20*#PAGES;                                                00427400
            BLK_INX = 2;                                                        00427500
            LOC1 = -1;                                                          00427600
            BLK_EXT_PTR = GET_DIR_CELL(LEN,ADDR(BLK_EXT_NODE),RESV);            00427700
            BLK_EXT_NODE(0) = 0;                                                00427800
            BLK_EXT_NODE(1) = SHL(#PAGES,16) + PAGE_F;                          00427900
            PTR_TEMP = PROC_TAB4(I);                                            00428000
            CALL PUTN(PTR_TEMP,16,ADDR(BLK_EXT_PTR),4,0);                       00428100
         END;                                                                   00428200
         DO J = J1 TO J2;                                                       00428300
            SYMB_PTR = SYMB_TO_PTR(J);                                          00428400
            K = SYT_SORT2(J);                                                   00428500
            TS = SYT_NAME(K);                                                   00428600
            NAME_LEN = LENGTH(TS);                                              00428700
            IF NAME_LEN < 8 THEN                                                00428800
               TS = TS || SUBSTR(X10, 2+NAME_LEN);                              00428900
            ADDR_TEMP = COREWORD(ADDR(TS)) & "FFFFFF";                          00429000
            CALL PUTN(SYMB_PTR,0,ADDR_TEMP,8,RESV);                             00429100
            COREWORD(ADDR(SYMB_NODE)) = LOC_ADDR;                               00429200
            IF BLK_INX ^= 0 THEN DO;                                            00429300
               PAGE = SHR(SYMB_PTR,16) & "FFFF";                                00429400
               OFFSET = SYMB_PTR & "FFFF";                                      00429500
               IF LOC1 < 0 THEN DO;                                             00429600
                  LOC1 = 0;                                                     00429700
                  BLK_EXT_NODE(BLK_INX) = SHL(OFFSET,16);                       00429800
                  LOC2 = SHL(BLK_INX + 1,2);                                    00429900
                  CALL PUTN(BLK_EXT_PTR,LOC2,ADDR_TEMP,8,0);                    00430000
               END;                                                             00430100
               IF PAGE ^= PREV_PAGE THEN DO;                                    00430200
                  PREV_PAGE = PAGE;                                             00430300
                  BLK_EXT_NODE(BLK_INX) = BLK_EXT_NODE(BLK_INX) +               00430400
                     PAGE_SIZE - SYMB_NODE_SIZE;                                00430500
                  LOC2 = SHL(BLK_INX + 3,2);                                    00430600
                  CALL PUTN(BLK_EXT_PTR,LOC2,OLD_ADDR,8,0);                     00430700
                  BLK_INX = BLK_INX + 5;                                        00430800
                  LOC2 = SHL(BLK_INX + 1,2);                                    00430900
                  CALL PUTN(BLK_EXT_PTR,LOC2,ADDR_TEMP,8,0);                    00431000
               END;                                                             00431100
               OLD_ADDR = ADDR_TEMP;                                            00431200
            END;                                                                00431300
            CLASS = SYT_CLASS(K);                                               00431400
            TYPE = SYT_TYPE(K);                                                 00431500
            ADDRESS = SYT_ADDR(K) & "FFFFFF";                                   00431600
            VAR_LENGTH = SYT_DIMS(K);                                           00431700
            EXTENT = VAR_EXTENT(K) & "FFFFFF";                                  00431800
            LEN = 24;                                                           00431900
            IF NAME_LEN > 8 THEN LEN = LEN + NAME_LEN - 8;                      00432000
            LEN = (LEN + 1)&"FFFFFFFE";                                         00432100
            EXT_BIAS,VAR_OFFSET = 0;                                            00432200
            CELL_TYPE = -1;                                                     00432300
            IF (CLASS=VAR_CLASS)|(CLASS=TEMPLATE_CLASS) THEN DO;                00432400
               IF TYPE = SCALAR | TYPE = INTEGER THEN                           00432410
                  IF (SYT_FLAGS(K) & DOUBLE_FLAG) ^= 0 THEN                     00432420
                  TYPE = TYPE | "8";                                            00432430
               #ELTS = VAR_LENGTH & "FF";                                       00432700
               IF TYPE = MATRIX THEN DO;                                        00432800
                  #ELTS = SHR(VAR_LENGTH,8) * #ELTS;                            00432900
                  IF FC THEN VAR_OFFSET = 2;                                    00433000
                  ELSE VAR_OFFSET = 4;                                          00433100
               END;                                                             00433200
               ELSE IF TYPE = DMATRIX THEN DO;                                  00433300
                  #ELTS = SHR(VAR_LENGTH,8) * #ELTS;                            00433400
                  IF FC THEN VAR_OFFSET = 4;                                    00433500
                  ELSE VAR_OFFSET = 8;                                          00433600
               END;                                                             00433700
               ELSE IF TYPE = VECTOR THEN DO;                                   00433800
                  IF FC THEN VAR_OFFSET = 2;                                    00433900
                  ELSE VAR_OFFSET = 4;                                          00434000
               END;                                                             00434100
               ELSE IF TYPE = DVECTOR THEN DO;                                  00434200
                  IF FC THEN VAR_OFFSET = 4;                                    00434300
                  ELSE VAR_OFFSET = 8;                                          00434400
               END;                                                             00434500
               ELSE IF TYPE = STRUCTURE THEN DO;                                00434600
                  #DIMS,#ELTS = SYT_ARRAY(K);                                   00434700
                  IF #DIMS ^= 0 THEN #DIMS = 1;                                 00434800
               END;                                                             00434900
               IF TYPE ^= STRUCTURE THEN #DIMS = GETARRAY#(K);                  00435000
               IF #DIMS > 0 THEN DO;                                            00435100
                  ARRAY_FACT = 1;                                               00435200
                  COEF = 0;                                                     00435300
                  DO IX = 2 TO #DIMS;                                           00435400
                     ARRAY_FACT = ARRAY_FACT * GETARRAYDIM(IX,K) + 1;           00435500
                  END;                                                          00435600
                  DO CASE TYPE;                                                 00435700
                     DO;         /* TYPE  0 -- NOT DEFINED */                   00435800
                     END;                                                       00435900
                     DO;         /* TYPE  1 -- BIT(16) */                       00436000
                        IF FC THEN COEF = 1;                                    00436100
                        ELSE COEF = 2;                                          00436200
                     END;                                                       00436300
                     DO;         /* TYPE  2 -- CHARACTER */                     00436400
                        IF VAR_LENGTH > 0 THEN DO;                              00436500
                           COEF = 2 + VAR_LENGTH;                               00436600
                           IF FC THEN COEF = SHR(COEF + 1,1);                   00436700
                           ELSE IF FCDATA_FLAG THEN                             00436710
                              COEF = (COEF + 1)&"FFFFFFFE";                     00436720
                        END;                                                    00436800
                        ELSE COEF = 1;                                          00436900
                     END;                                                       00437000
                     DO;         /* TYPE  3 -- SP MATRIX */                     00437100
                        IF FC THEN COEF = SHL(#ELTS,1);                         00437200
                        ELSE COEF = SHL(#ELTS,2);                               00437300
                     END;                                                       00437400
                     DO;         /* TYPE  4 -- SP VECTOR */                     00437500
                        IF FC THEN COEF = SHL(#ELTS,1);                         00437600
                        ELSE COEF = SHL(#ELTS,2);                               00437700
                     END;                                                       00437800
                     DO;         /* TYPE  5 -- SP SCALAR */                     00437900
                        IF FC THEN COEF = 2;                                    00438000
                        ELSE COEF = 4;                                          00438100
                     END;                                                       00438200
                     DO;         /* TYPE  6 -- SP INTEGER */                    00438300
                        IF FC THEN COEF = 1;                                    00438400
                        ELSE COEF = 2;                                          00438500
                     END;                                                       00438600
                     DO;         /* TYPE  7 -- NOT DEFINED */                   00438700
                     END;                                                       00438800
                     DO;         /* TYPE  8 -- NOT DEFINED */                   00438900
                     END;                                                       00439000
                     DO;         /* TYPE  9 -- BIT(32) */                       00439100
                        IF FC THEN COEF = 2;                                    00439200
                        ELSE COEF = 4;                                          00439300
                     END;                                                       00439400
                     DO;         /* TYPE 10 -- BOOLEAN */                       00439500
                        IF FC THEN COEF = 1;                                    00439510
                        ELSE DO;                                                00439520
                           IF FCDATA_FLAG THEN COEF = 2;                        00439530
                           ELSE COEF = 1;                                       00439540
                        END;                                                    00439550
                     END;                                                       00439700
                     DO;         /* TYPE 11 -- DP MATRIX */                     00439800
                        IF FC THEN COEF = SHL(#ELTS,2);                         00439900
                        ELSE COEF = 8 * #ELTS;                                  00440000
                     END;                                                       00440100
                     DO;         /* TYPE 12 -- DP VECTOR */                     00440200
                        IF FC THEN COEF = SHL(#ELTS,2);                         00440300
                        ELSE COEF = 8 * #ELTS;                                  00440400
                     END;                                                       00440500
                     DO;         /* TYPE 13 -- DP SCALAR */                     00440600
                        IF FC THEN COEF = 4;                                    00440700
                        ELSE COEF = 8;                                          00440800
                     END;                                                       00440900
                     DO;         /* TYPE 14 -- DP INTEGER */                    00441000
                        IF FC THEN COEF = 2;                                    00441100
                        ELSE COEF = 4;                                          00441200
                     END;                                                       00441300
                     DO;         /* TYPE 15 -- NOT DEFINED */                   00441400
                     END;                                                       00441500
                     DO;         /* TYPE 16 -- STRUCTURE */                     00441600
                        IF #ELTS < 0 THEN COEF = EXTENT;                        00441700
                        ELSE COEF = EXTENT/#ELTS;                               00441800
                     END;                                                       00441900
                     DO;         /* TYPE 17 -- EVENT VAR */                     00442000
                        IF FC THEN COEF = 1;                                    00442010
                        ELSE DO;                                                00442020
                           IF FCDATA_FLAG THEN COEF = 2;                        00442030
                           ELSE COEF = 1;                                       00442040
                        END;                                                    00442050
                     END;                                                       00442200
                  END;                                                          00442300
                  VAR_OFFSET = VAR_OFFSET + COEF * ARRAY_FACT;                  00442400
               END;                                                             00442500
               IF VAR_OFFSET > 0 THEN DO;                                       00442600
                  LEN = (LEN + 3)&"FFFFFFFC";                                   00442700
                  EXT_BIAS = SHR(LEN,1);                                        00442800
                  LEN = LEN + 4;                                                00442900
               END;                                                             00443000
            END;                                                                00443200
            STRUC_BIAS = 0;                                                     00443300
            IF CLASS >= TEMPLATE_CLASS THEN DO;                                 00443400
               STRUC_BIAS = SHR(LEN,1);                                         00443500
               LEN = LEN + 6;                                                   00443600
               LINK1 = SYT_SORT1(SYT_LINK1(K));                                 00443700
               IF CLASS = TEMPLATE_CLASS THEN CLASS = 4;                        00443800
               ELSE IF CLASS = TPL_LAB_CLASS THEN DO;                           00443900
                  CLASS = 5;                                                    00444000
                  IF TYPE = PROG_LABEL THEN TYPE = 1;                           00444100
                  ELSE IF TYPE = PROC_LABEL THEN TYPE = 2;                      00444200
                  ELSE IF TYPE = TASK_LABEL THEN TYPE = 5;                      00444300
               END;                                                             00444400
               ELSE IF CLASS = TPL_FUNC_CLASS THEN CLASS = 6;                   00444500
               LINK0 = 0;                                                       00444600
               LINK2 = SYT_LINK2(K);                                            00444700
               IF (CLASS = 4) & (TYPE = STRUCTURE) THEN DO;                     00444800
                  IF ((SYT_LOCK#(K)&"80") ^= 0) THEN DO;                        00444900
                     #TPLS2 = #TPLS2 + 1;                                       00445000
                     TPL_TAB2(#TPLS2) = J;                                      00445100
                     LINK0 = SYT_SORT1(SYT_PTR(K));                             00445200
                     IF LINK0 ^= 0 THEN DO;                                     00445300
                        #UNQUAL = #UNQUAL + 1;                                  00445400
                        TPL_TAB1(#UNQUAL) = J;                                  00445500
                     END;                                                       00445600
                     LINK2,VAR_LENGTH = 0;                                      00445700
                  END;                                                          00445800
                  ELSE DO;                                                      00445900
                     IF LINK1 ^= 0 THEN VAR_LENGTH = 0;                         00446000
                     ELSE VAR_LENGTH = SYT_SORT1(VAR_LENGTH);                   00446100
                  END;                                                          00446200
               END;                                                             00446300
               IF LINK2 < 0 THEN LINK2 = - SYT_SORT1(-LINK2);                   00446400
               ELSE LINK2 = SYT_SORT1(LINK2);                                   00446500
            END;                                                                00446600
            DIM_BIAS = 0;                                                       00446700
            IF ((CLASS=VAR_CLASS)|(CLASS=FUNC_CLASS)) & (TYPE = STRUCTURE) THEN 00446800
               DO;                                                              00446900
               #DIMS = 1;                                                       00447000
               VAR_LENGTH = SYT_SORT1(VAR_LENGTH);                              00447100
            END;                                                                00447200
            ELSE #DIMS = GETARRAY#(K);                                          00447300
 /**********************  DR102963  BOB CHEREWATY  *****************/
 /* ONLY SET THE VARIABLE'S DIMENSION TO 0 IF IT IS ACTUALLY A     */           00341000
 /* PROGRAM LABEL, PROCEDURE LABEL, OR FUNCTION LABEL.  THE        */           00341100
 /* NONHAL FLAG IS ALSO USED AS THE INCLUDED_REMOTE FLAG AND MAY   */           00341200
 /* BE SET FOR VARIABLES OTHER THAN LABELS.                        */           00341300
            IF ((SYT_FLAGS2(K) & NONHAL_FLAG) ^= 0) & /* DR108643 */            00341400
               (CLASS = LABEL_CLASS)              &                             00341500
               (NAME_FLAG = 0) THEN #DIMS = 0 ;                                 00341600
 /**********************  DR102963  END  ***************************/
            IF #DIMS ^= 0 THEN DO;                                              00447500
               DIM_BIAS = SHR(LEN,1);                                           00447600
               LEN = LEN + SHL(#DIMS + 1,1);                                    00447700
            END;                                                                00447800
            #XREF,XREF_BIAS = 0;                                                00447900
            N = SYT_XREF(K);                                                    00448000
GET_XREFS:  DO WHILE N ^= 0;                                                    00448100
               IF ((XREF(N)&"1FFF")>=REF_STMT)|((CLASS=LABEL_CLASS)&            00448200
                  (TYPE=COMPOOL_LABEL)) THEN DO;                                00448300
                  IF #XREF >= XREF_MAX THEN DO;                                 00448310
                     OUTPUT = '***  WARNING: INCOMPLETE XREF INFO FOR: ' ||     00448320
                        SYT_NAME(K);                                            00448330
                     ESCAPE GET_XREFS;                                          00448340
                  END;                                                          00448350
                  #XREF = #XREF + 1;                                            00448400
                  XREF_TAB(#XREF) = XREF(N) & "FFFF";                           00448500
               END;                                                             00448600
               N = SHR(XREF(N),16);                                             00448700
            END;                                                                00448800
            IF #XREF > 0 THEN DO;                                               00448900
               LEN = LEN + 2;  /* SAVE SPACE FOR REL. BLK # */                  00449000
               XREF_BIAS = SHR(LEN,1);                                          00449100
               MAX_#XREF = SHR(MAX_CELL - LEN,1) - 4;                           00449200
               IF #XREF <= MAX_#XREF THEN DO;                                   00449300
                  LEN = LEN + SHL(#XREF + 1,1);                                 00449400
               END;                                                             00449500
               ELSE IF #XREF <= MAX_#XREF +3 THEN DO;                           00449600
                  MAX_#XREF = #XREF;                                            00449700
                  LEN = LEN + SHL(#XREF + 1,1);                                 00449800
               END;                                                             00449900
               ELSE LEN = LEN + SHL(MAX_#XREF + 4,1);                           00450000
            END;                                                                00450100
            IF (SYT_FLAGS(K) & SYT_VPTR_FLAG) ^= 0 THEN                         00450105
               PTR_TEMP = GET_SYT_VPTR(K);                                      00450110
            ELSE PTR_TEMP = 0;                                                  00450115
            IF PTR_TEMP = 0 THEN N = 4;                                         00450120
            ELSE N = 8;                                                         00450125
            IF ^EXT_FLAG THEN DO;                                               00450130
               L = K + 1;                                                       00450135
               DO WHILE (SYT_SORT1(L)=0 & L<=ACTUAL_SYMBOLS) |                  00450140
                     ((SYT_FLAGS(L) & EXTERNAL_FLAG)^=0);                       00450142
                  L = L + 1;                                                    00450145
               END;                                                             00450150
               L = SYT_SORT1(L);                                                00450155
               N = 12;                                                          00450160
            END;                                                                00450165
            SYMB_EXT_PTR = GET_DATA_CELL(LEN+N,ADDR(NODE_H),RESV);              00450200
            SYMB_EXT_PTR = SYMB_EXT_PTR + N;                                    00450210
            COREWORD(ADDR(NODE_H)) = LOC_ADDR + N;                              00450220
            COREWORD(ADDR(NODE_F)),COREWORD(ADDR(NODE_B)) = LOC_ADDR + N;       00450230
            SYMB_NODE(4) = SHR(SYMB_EXT_PTR,16) & "FFFF";                       00450600
            SYMB_NODE(5) = SYMB_EXT_PTR & "FFFF";                               00450700
            CALL P3_PTR_LOCATE(SYMB_PTR,RELS);                                  00450800
            IF NAME_LEN > 8 THEN DO;                                            00450900
               ADDR_TEMP = ADDR_TEMP + 8;                                       00451000
               CALL PUTN(SYMB_EXT_PTR,24,ADDR_TEMP,NAME_LEN - 8,0);             00451100
            END;                                                                00451200
            IF ^EXT_FLAG THEN NODE_H(-5) = L;                                   00451210
            IF PTR_TEMP ^= 0 THEN DO;                                           00451220
               PTR = 0;                                                         00451230
               IF (SYT_FLAGS(K) & NAME_FLAG) = 0 THEN                           00451240
                  IF SYT_TYPE(K) = STRUCTURE THEN                               00451250
                  IF SYT_CLASS(K) = VAR_CLASS THEN                              00451260
                  CALL MOVE_NAME_TERM_CELLS(PTR_TEMP);                          00451270
               IF PTR = 0 THEN DO;                                              00451280
                  CALL LOCATE(PTR_TEMP,ADDR(NODE_H1),0);                        00451290
                  LEN = NODE_H1(0);                                             00451300
                  PTR = GET_DATA_CELL(LEN,ADDR(NODE_H1),0);                     00451310
                  CALL MOVE(LEN,VMEM_LOC_ADDR,LOC_ADDR);                        00451320
                  IF (SYT_FLAGS(K) & NAME_FLAG) ^= 0 |                          00451330
                     SYT_TYPE(K) = EQUATE_LABEL THEN DO;                        00451335
                     L = 4;                                                     00451340
                     M = (NODE_H1(1) & "7FFF") + 3;                             00451350
                  END;                                                          00451360
                  ELSE DO;                                                      00451370
                     L = 2;                                                     00451380
                     M = SHR(NODE_H1(1),8) + 1;                                 00451390
                  END;                                                          00451400
                  DO N = L TO M;                                                00451410
                     NODE_H1(N) = SYT_SORT1(NODE_H1(N));                        00451420
                  END;                                                          00451430
               END;                                                             00451440
               NODE_F(-2) = PTR;                                                00451450
            END;                                                                00451460
            NODE_F(-1),NODE_F(0) = 0;                                           00451470
            NODE_H(0) = I;                                                      00451500
            NODE_B(2) = SHL(EXT_BIAS,1);                                        00451600
            NODE_B(3) = SHL(XREF_BIAS,1);                                       00451700
            NODE_B(4) = SHL(DIM_BIAS,1);                                        00451800
            NODE_B(5) = SHL(STRUC_BIAS,1);                                      00451900
            IF CLASS = REPL_CLASS THEN DO;                                      00452000
               CLASS = LABEL_CLASS;                                             00452100
               TYPE = 9;                                                        00452200
            END;                                                                00452300
            ELSE IF CLASS = LABEL_CLASS THEN DO;                                00452400
               DO CASE TYPE & "F";                                              00452500
                  DO;               /* MB STMT LABEL */                         00452600
                  END;                                                          00452700
                  DO;               /* IND STMT LABEL */                        00452800
                  END;                                                          00452900
                  DO;               /* UPDATE OR STMT LABEL */                  00453000
                     IF (VAR_LENGTH = 1)|(VAR_LENGTH = 2) THEN TYPE = 6;        00453100
                     ELSE TYPE = 7;                                             00453200
                  END;                                                          00453300
                  DO;               /* UNSPEC LABEL */                          00453400
                  END;                                                          00453500
                  DO;               /* MB CALL LABEL */                         00453600
                  END;                                                          00453700
                  DO;               /* IND CALL LABEL */                        00453800
                  END;                                                          00453900
                  DO;               /* CALLED LABEL */                          00454000
                  END;                                                          00454100
                  DO;               /* PROCEDURE LABEL */                       00454200
                     TYPE = 2;                                                  00454300
                  END;                                                          00454400
                  DO;               /* TASK LABEL */                            00454500
                     TYPE = 5;                                                  00454600
                  END;                                                          00454700
                  DO;               /* PROGRAM LABEL */                         00454800
                     TYPE = 1;                                                  00454900
                  END;                                                          00455000
                  DO;               /* COMPOOL LABEL */                         00455100
                     TYPE = 4;                                                  00455200
                  END;                                                          00455300
                  DO;               /* EQUATE LABEL */                          00455400
                     TYPE = 8;                                                  00455500
                  END;                                                          00455600
               END;                                                             00455700
            END;                                                                00455800
            NODE_B(6) = CLASS;                                                  00455900
            NODE_B(7) = TYPE;                                                   00456000
            IF CMPL_FLAG THEN BTEMP = "80";                                     00456100
            ELSE BTEMP = 0;                                                     00456200
            FTEMP = SYT_FLAGS(K);                                               00456300
            IF (FTEMP & INPUT_PARM) ^= 0 THEN                                   00456400
               BTEMP = BTEMP | "40";                                            00456500
            IF (FTEMP & ASSIGN_FLAG) ^= 0 THEN                                  00456600
               BTEMP = BTEMP | "20";                                            00456700
            IF (FTEMP & TEMPORARY_FLAG) ^= 0 THEN                               00456800
               BTEMP = BTEMP | "10";                                            00456900
            IF (FTEMP & AUTO_FLAG) ^= 0 THEN                                    00457000
               BTEMP = BTEMP | "08";                                            00457100
            IF (FTEMP & NAME_FLAG) ^= 0 THEN                                    00457200
               DO;                                                              00457300
               BTEMP = BTEMP | "04";                                            00457310
               NAME_FLG = TRUE;                                                 00457320
            END;                                                                00457330
            ELSE NAME_FLG = FALSE;                                              00457340
            IF ((SYT_LOCK#(K)&"80") ^= 0) & (CLASS = 4) THEN                    00457400
               BTEMP = BTEMP | "02";                                            00457500
            NODE_B(8) = BTEMP;                                                  00457600
            IF REENT_FLAG THEN BTEMP = "80";                                    00457700
            ELSE BTEMP = 0;                                                     00457800
            IF (FTEMP & DENSE_FLAG) ^= 0 THEN                                   00457900
               BTEMP = BTEMP | "40";                                            00458000
            IF (FTEMP & CONST_FLAG) ^= 0 THEN                                   00458100
               BTEMP = BTEMP | "20";                                            00458200
            IF (FTEMP & ACCESS_FLAG) ^= 0 THEN                                  00458300
               BTEMP = BTEMP | "10";                                            00458400
            IF (FTEMP & INDIRECT_FLAG) ^= 0 THEN                                00458500
               BTEMP = BTEMP | "08";                                            00458600
            IF (FTEMP & LATCH_FLAG) ^= 0 THEN                                   00458700
               BTEMP = BTEMP | "04";                                            00458800
            IF (FTEMP & LOCK_FLAG) ^= 0 THEN                                    00458900
               BTEMP = BTEMP | "02";                                            00459000
            IF (FTEMP & REMOTE_FLAG) ^= 0 THEN                                  00459100
               BTEMP = BTEMP | "01";                                            00459200
            NODE_B(9) = BTEMP;                                                  00459300
            IF VAR_OFFSET > 0 THEN BTEMP = "80";                                00459400
            ELSE BTEMP = 0;                                                     00459500
            IF (FTEMP & INIT_FLAG) ^= 0 THEN                                    00459600
               BTEMP = BTEMP | "40";                                            00459700
            IF (FTEMP & RIGID_FLAG) ^= 0 THEN                                   00459800
               BTEMP = BTEMP | "20";                                            00459900
            LIT_FLAG = FALSE;                                                   00460000
            IF ((FTEMP & CONST_FLAG) ^= 0) & (SYT_PTR(K) < 0) THEN DO;          00460100
               LIT_FLAG = TRUE;                                                 00460200
               BTEMP = BTEMP | "10";                                            00460300
               LIT_PTR = GET_LITERAL(-SYT_PTR(K));                              00460302
               DO CASE LIT_TYPE(TYPE);                                          00460304
                  DO;   /* SHOULDNT GET HERE */                                 00460306
                     OUTPUT = P3ERR || 'LITERAL HAS ILLEGAL SYMBOL TYPE ***';   00460308
                     LITERAL_DATA_CELL = 0;                                     00460310
                  END;                                                          00460312
                  DO;   /* BIT LITERALS */                                      00460314
                     LITERAL_DATA_CELL = GET_DATA_CELL(8,ADDR(NODE_F1),0);      00460316
                     NODE_F1(0) = LIT2(LIT_PTR);                                00460318
                     NODE_F1(1) = LIT3(LIT_PTR);                                00460320
                  END;                                                          00460322
                  DO;   /* CHARACTER LITERALS */                                00460324
                     TEXT_PTR = LIT2(LIT_PTR);                                  00460326
                     IF TEXT_PTR = 0 THEN LITERAL_DATA_CELL = 0;                00460328
                     ELSE DO;                                                   00460330
                        TEXT_LENGTH = SHR(TEXT_PTR,24) & "FF";                  00460332
                        LITERAL_DATA_CELL = GET_DATA_CELL(TEXT_LENGTH+2,        00460334
                           ADDR(NODE_F1),0);                                    00460336
                        NODE_F1(0) = SHL(TEXT_LENGTH,24);                       00460338
                        CALL MOVE(TEXT_LENGTH+1,TEXT_PTR,LOC_ADDR+1);           00460340
                     END;                                                       00460342
                  END;                                                          00460344
                  DO;   /* SCALAR, INTEGER LITERALS */                          00460346
                     LITERAL_DATA_CELL = GET_DATA_CELL(8,ADDR(NODE_F1),0);      00460348
                     NODE_F1(0) = LIT2(LIT_PTR);                                00460350
                     NODE_F1(1) = LIT3(LIT_PTR);                                00460352
                  END;                                                          00460354
               END;                                                             00460356
            END;                                                                00460400
            IF EXT_FLAG THEN BTEMP = BTEMP | "08";                              00460500
            IF ((FTEMP & ASSIGN_FLAG) ^= 0) | ((FTEMP & INPUT_PARM) ^= 0)       00460600
               | ((FTEMP & TEMPORARY_FLAG) ^= 0) |                              00460700
               (((FTEMP & AUTO_FLAG) ^= 0) & (REENT_FLAG = TRUE)) THEN DO;      00460800
               BTEMP = BTEMP | "04";                                            00460900
               CELL_TYPE = 3;                                                   00461000
            END;                                                                00461100
            IF (FTEMP & EQUATE_FLAG) ^= 0 THEN                                  00461200
               BTEMP = BTEMP | "01";                                            00461300
            NODE_B(10) = BTEMP;                                                 00461400
            /* DR108643 CHANGED NONHAL_FLAG TO INCLUDED_REMOTE */
            IF (FTEMP & INCLUDED_REMOTE) ^= 0 THEN BTEMP = "80";                00461500
            /***** END DR108643 *****/
            ELSE BTEMP = 0;                                                     00461600
            IF (FTEMP & EXCLUSIVE_FLAG) ^= 0 THEN                               00461700
               BTEMP = BTEMP | "40";                                            00461800
            IF FCDATA_FLAG THEN BTEMP = BTEMP|"20";                             00461805
            IF (FTEMP & MISC_NAME_FLAG) ^= 0 THEN BTEMP = BTEMP | "10";         00461810
            IF PTR_TEMP ^= 0 THEN BTEMP = BTEMP | "04";                         00461820
            IF (FTEMP & BITMASK_FLAG) ^= 0                                      00461850
               THEN BTEMP = BTEMP | "01";                                       00461860
            NODE_B(11) = BTEMP;                                                 00461900
            IF (CLASS = LABEL_CLASS) | (CLASS = FUNC_CLASS) THEN DO;            00462000
               EXTENT = 0;                                                      00462100
               IF CLASS ^= FUNC_CLASS THEN VAR_LENGTH = 0;                      00462200
               IF (CLASS = LABEL_CLASS)&(TYPE = 8) THEN DO;                     00462300
                  IF EXT_FLAG = FALSE THEN CELL_TYPE = 0;                       00462400
                  VAR_LENGTH = SYT_SORT1(SYT_PTR(K));                           00462500
               END;                                                             00462600
               ELSE IF (FTEMP & NAME_FLAG) ^= 0 THEN DO;                        00462700
                  IF CELL_TYPE = -1 THEN                                        00462800
                     IF ^LIT_FLAG THEN                                          00462900
                     IF ^EXT_FLAG THEN CELL_TYPE = 0;                           00463000
               END;                                                             00463100
               ELSE DO;                                                         00463200
                  ADDRESS = 0;                                                  00463300
                  IF CLASS = LABEL_CLASS THEN DO;                               00463400
                     IF (FC)&(EXT_FLAG=FALSE) THEN DO;                          00463500
                        IF ^((TYPE = 4) | (TYPE >= 7)) THEN DO;                 00463600
                           CELL_TYPE = 1;                                       00463700
                           NODE_B(10) = NODE_B(10) | "02";                      00463800
                           IF (TYPE = 6) | ((FTEMP & EXCLUSIVE_FLAG)^=0) THEN   00463900
                              EXTENT = 5;                                       00464000
                           ELSE EXTENT = 2;                                     00464100
                        END;                                                    00464200
                     END;                                                       00464300
                  END;                                                          00464400
                  ELSE IF (FC)&(EXT_FLAG=FALSE) THEN DO;                        00464500
                     CELL_TYPE = 1;                                             00464600
                     NODE_B(10) = NODE_B(10) | "02";                            00464700
                     IF (FTEMP & EXCLUSIVE_FLAG) ^= 0 THEN EXTENT = 5;          00464800
                     ELSE EXTENT = 2;                                           00464900
                  END;                                                          00465000
               END;                                                             00465100
            END;                                                                00465200
            IF ((CLASS=FUNC_CLASS) | ((CLASS=LABEL_CLASS)&(TYPE<=6)))           00465210
              & (SYT_FLAGS(K) & NAME_FLAG) = 0 THEN DO;   /*DR111357*/
               CALL P3_LOCATE(BLOCK_TO_PTR(I),ADDR(NODE_F1),0);                 00465220
               PTR_TEMP = NODE_F1(2);                                           00465230
               CALL P3_LOCATE(PTR_TEMP,ADDR(BLK_LIST_NODE),0);                  00465240
               BLK_LIST_NODE(10) = J;                                           00465250
               IF (EXT_FLAG & ^NAME_FLG) | OP3=SELFNAMELOC THEN                 00465260
                  BLK_LIST_NODE(12) = BLK_LIST_NODE(12) | SYT_LOCK#(K);         00465270
            END;                                                                00465280
            IF (CLASS = VAR_CLASS) & (^LIT_FLAG) THEN DO;                       00465300
               LOCK_VAL = SYT_LOCK#(K);                                         00465400
               IF CELL_TYPE = -1 THEN DO;                                       00465500
                  IF ^EXT_FLAG THEN DO;                                         00465600
                     IF FC THEN DO;                                             00465700
                        IF ((FTEMP&REMOTE_FLAG)^=0)&((FTEMP&NAME_FLAG)=0) THEN  00465800
                           CELL_TYPE = 2;                                       00465900
                        ELSE CELL_TYPE = 0;                                     00466000
                     END;                                                       00466100
                     ELSE IF ^LIT_FLAG THEN CELL_TYPE = 0;                      00466200
                  END;                                                          00466300
               END;                                                             00466400
            END;                                                                00466500
            ELSE LOCK_VAL = 0;                                                  00466600
            IF LIT_FLAG THEN DO;                                                00466700
               ADDRESS,EXTENT = 0;                                              00466800
            END;                                                                00466900
            NODE_F(3) = SHL(NAME_LEN,24) + ADDRESS;                             00467000
            NODE_H(8) = STACK_ID;                                               00467100
            NODE_H(9) = VAR_LENGTH;                                             00467200
            NODE_F(5) = SHL(LOCK_VAL,24) + EXTENT;                              00467300
            IF LIT_FLAG THEN NODE_F(5) = LITERAL_DATA_CELL;                     00467310
            IF CELL_TYPE = 1 THEN DO;                                           00467400
               ADDRESS = SYT_ADDR(K) & "FFFF";                                  00467500
               NODE_H(10) = ADDRESS;                                            00467600
            END;                                                                00467700
            IF CLASS=LABEL_CLASS & TYPE=9 THEN DO;                              00467702
               REPL_TEXT_PTR = VAR_EXTENT(K);                                   00467704
               IF REPL_TEXT_PTR ^= -1 THEN DO;                                  00467706
                  IF (REPL_TEXT_PTR&"80000000")^=0 THEN                         00467708
                     NODE_B(11) = NODE_B(11) | "8";                             00467710
                  REPL_TEXT_PTR = REPL_TEXT_PTR & "7FFFFFFF";                   00467712
               END;                                                             00467714
               MACROSIZE,OLD_SDF_PTR = 0;                                       00467716
               COREWORD(ADDR(REPL_LINK)) = ADDR(NODE_F(5));                     00467718
               DO WHILE REPL_TEXT_PTR ^= -1;                                    00467720
                  CALL LOCATE(REPL_TEXT_PTR,ADDR(NODE_F1),RESV);                00467722
                  TEXT_LENGTH = SHR(NODE_F1(1),16);                             00467724
                  IF (TEXT_LENGTH & "FF00") = "FF00" THEN DO;                   00467726
                     NEXT_CELL = NODE_F1(0);                                    00467727
                     BLANK_BYTES = NODE_F1(1) & "FFFF";                         00467728
                     IF TEXT_LENGTH = -1 THEN L = 8;                            00467729
                     ELSE L = NODE_F1(2) - 4;                                   00467730
                     OLD_SDF_PTR,REPL_LINK = GET_DATA_CELL(L,ADDR(NODE_F1),     00467731
                        MODF + RESV);                                           00467732
                     CALL MOVE(4,VMEM_LOC_ADDR+4,LOC_ADDR+4);                   00467733
                     IF TEXT_LENGTH ^= -1 THEN                                  00467734
                        CALL MOVE(L-8,VMEM_LOC_ADDR+12,LOC_ADDR+8);             00467735
                     COREWORD(ADDR(REPL_LINK)) = LOC_ADDR;                      00467736
                     CALL PTR_LOCATE(REPL_TEXT_PTR,RELS);                       00467737
                     REPL_TEXT_PTR = NEXT_CELL;                                 00467738
                  END;                                                          00467739
                  ELSE DO;                                                      00467740
                     MACROSIZE = MACROSIZE + TEXT_LENGTH;                       00467741
                     NEXT_CELL = NODE_F1(0);                                    00467742
                     SDF_REPL_TEXT_PTR = GET_DATA_CELL(TEXT_LENGTH+6,           00467743
                        ADDR(NODE_F1),MODF + RESV);                             00467744
                     REPL_LINK = SDF_REPL_TEXT_PTR;                             00467746
                     COREWORD(ADDR(REPL_LINK)) = LOC_ADDR;                      00467748
                     CALL MOVE(TEXT_LENGTH+2,VMEM_LOC_ADDR+4,LOC_ADDR+4);       00467750
                    IF OLD_SDF_PTR^=0 THEN CALL P3_PTR_LOCATE(OLD_SDF_PTR,RELS);00467752
                     OLD_SDF_PTR = SDF_REPL_TEXT_PTR;                           00467754
                     CALL PTR_LOCATE(REPL_TEXT_PTR,RELS);                       00467756
                     REPL_TEXT_PTR = NEXT_CELL;                                 00467758
                  END;                                                          00467760
               END;                                                             00467762
               NODE_F1(0) = 0;                                                  00467764
               NODE_F(3) = (NODE_F(3) & "FF000000") + MACROSIZE + BLANK_BYTES;  00467766
               CALL P3_PTR_LOCATE(OLD_SDF_PTR,RELS);                            00467768
            END;                                                                00467770
            IF EXT_BIAS ^= 0 THEN NODE_F(SHR(EXT_BIAS,1)) = VAR_OFFSET;         00467800
            IF STRUC_BIAS ^= 0 THEN DO;                                         00467900
               NODE_H(STRUC_BIAS) = LINK0;                                      00468000
               NODE_H(STRUC_BIAS + 1) = LINK1;                                  00468100
               NODE_H(STRUC_BIAS + 2) = LINK2;                                  00468200
            END;                                                                00468300
            IF DIM_BIAS ^= 0 THEN DO;                                           00468400
               IF TYPE = STRUCTURE THEN DO;                                     00468500
                  NODE_H(DIM_BIAS) = #DIMS;                                     00468600
                  NODE_H(DIM_BIAS + 1) = SYT_ARRAY(K);                          00468700
                  IF NODE_H(DIM_BIAS + 1) < 0 THEN NODE_H(DIM_BIAS + 1) = -1;   00468800
                  IF NODE_H(DIM_BIAS + 1) = 0 THEN NODE_H(DIM_BIAS + 1) = 1;    00468900
               END;                                                             00469000
               ELSE DO;                                                         00469100
                  NODE_H(DIM_BIAS) = #DIMS;                                     00469200
                  DO N = 1 TO #DIMS;                                            00469300
                     NODE_H(DIM_BIAS + N) = GETARRAYDIM(N,K);                   00469400
                     IF NODE_H(DIM_BIAS + N) < 0 THEN NODE_H(DIM_BIAS + N) = -1;00469500
                  END;                                                          00469600
               END;                                                             00469700
            END;                                                                00469800
            IF #XREF > 0 THEN DO;                                               00469900
               NODE_H(XREF_BIAS - 1) = K - BASE_NO;                             00470000
               XREF_ADDR = COREWORD(ADDR(NODE_F)) + SHL(XREF_BIAS,1);           00470100
               COREWORD(ADDR(XREF_CELL)) = XREF_ADDR;                           00470200
               SAVE_PTR = SYMB_EXT_PTR;                                         00470300
               XREF_CELL(0) = #XREF;                                            00470400
               XREF_BIAS = 1;                                                   00470500
               XREF_CNT = 1;                                                    00470600
               IF (XREF_ADDR&3) ^= 0 THEN DO;                                   00470700
                  COREWORD(ADDR(XREF_CELL)) = XREF_ADDR - 2;                    00470800
                  XREF_BIAS = 2;                                                00470900
               END;                                                             00471000
               DO N = 1 TO #XREF;                                               00471100
                  IF XREF_CNT <= MAX_#XREF THEN DO;                             00471200
                     XREF_CELL(XREF_BIAS) = XREF_TAB(N);                        00471300
                     XREF_BIAS = XREF_BIAS + 1;                                 00471400
                     XREF_CNT = XREF_CNT + 1;                                   00471500
                  END;                                                          00471600
                  ELSE DO;                                                      00471700
                     #XREF_TO_GO = #XREF - N + 1;                               00471800
                     MAX_#XREF = SHR(MAX_CELL,1) - 4;                           00471900
                     IF #XREF_TO_GO <= MAX_#XREF THEN                           00472000
                        LEN = SHL(#XREF_TO_GO,1);                               00472100
                     ELSE IF #XREF_TO_GO <= MAX_#XREF + 3 THEN DO;              00472200
                        MAX_#XREF = #XREF_TO_GO;                                00472300
                        LEN = SHL(#XREF_TO_GO,1);                               00472400
                     END;                                                       00472500
                     ELSE LEN = SHL(MAX_#XREF + 4,1);                           00472600
                     XREF_CELL(XREF_BIAS) = "FFFF";                             00472700
                     XREF_CELL(XREF_BIAS + 1) = "FFFF";                         00472800
                     CALL P3_PTR_LOCATE(SAVE_PTR,MODF+RESV);                    00472900
                     PTR_TEMP = GET_DATA_CELL(LEN,ADDR(NODE_F),0);              00473000
                     XREF_ADDR = LOC_ADDR;                                      00473100
                     M = (XREF_BIAS + 2)&"FFFFFFFE";                            00473200
                     XREF_CELL(M) = SHR(PTR_TEMP,16) & "FFFF";                  00473300
                     XREF_CELL(M + 1) = PTR_TEMP & "FFFF";                      00473400
                     CALL P3_PTR_LOCATE(SAVE_PTR,RELS);                         00473500
                     SAVE_PTR = PTR_TEMP;                                       00473600
                     COREWORD(ADDR(XREF_CELL)) = XREF_ADDR;                     00473700
                     XREF_CELL(0) = XREF_TAB(N);                                00473800
                     XREF_BIAS = 1;                                             00473900
                     XREF_CNT = 1;                                              00474000
                  END;                                                          00474100
               END;                                                             00474200
            END;                                                                00474300
            CALL P3_PTR_LOCATE(SYMB_EXT_PTR,MODF+RELS);                         00474310
            IF CELL_TYPE ^= -1 THEN DO;                                         00474400
               IF (RGD_FLAG=TRUE)&(CELL_TYPE=0) THEN                            00474500
                  SYT_FLAGS(K) = SYT_FLAGS(K)|LINK_FLAG;                        00474600
               ELSE CALL SEARCH_AND_ENQUEUE(I,J,ADDRESS,CELL_TYPE);             00474700
            END;                                                                00474800
         END;                                                                   00474900
         IF BLK_INX ^= 0 THEN DO;                                               00475000
            BLK_EXT_NODE(BLK_INX) = BLK_EXT_NODE(BLK_INX) + OFFSET;             00475100
            LOC2 = SHL(BLK_INX + 3,2);                                          00475200
            CALL PUTN(BLK_EXT_PTR,LOC2,OLD_ADDR,8,RELS);                        00475300
         END;                                                                   00475400
      END;                                                                      00475500
                                                                                00475600
 /* IF THERE ARE ANY UNQUALIFIED STRUCTURES, FIX UP LINK0 OF ALL TEMPLATE */    00475700
 /* TERMINALS TO POINT BACK TO THE STRUCTURE DECLARATION.                 */    00475800
                                                                                00475900
      DO I = 1 TO #UNQUAL;                                                      00476000
         TEMPL_LINK = TPL_TAB1(I);                                              00476100
         PTR_TEMP = SYMB_TO_PTR(TEMPL_LINK);                                    00476200
         SYMB_EXT_PTR = EXTRACT4(PTR_TEMP,8,0);                                 00476300
         CALL P3_LOCATE(SYMB_EXT_PTR,ADDR(NODE_H),MODF);                        00476400
         COREWORD(ADDR(NODE_B)) = LOC_ADDR;                                     00476500
         STRUC_BIAS = SHR(NODE_B(5),1);                                         00476600
         STRUC_LINK = NODE_H(STRUC_BIAS);                                       00476700
         LINK = NODE_H(STRUC_BIAS + 1);                                         00476800
         NODE_B(8) = NODE_B(8)|"01";                                            00476900
         PTR_TEMP = SYMB_TO_PTR(STRUC_LINK);                                    00477000
         SYMB_EXT_PTR = EXTRACT4(PTR_TEMP,8,0);                                 00477100
         CALL P3_LOCATE(SYMB_EXT_PTR,ADDR(NODE_B),MODF);                        00477200
         NODE_B(8) = NODE_B(8)|"01";                                            00477300
         DO WHILE LINK ^= TEMPL_LINK;                                           00477400
            PTR_TEMP = SYMB_TO_PTR(LINK);                                       00477500
            SYMB_EXT_PTR = EXTRACT4(PTR_TEMP,8,0);                              00477600
            CALL P3_LOCATE(SYMB_EXT_PTR,ADDR(NODE_H),0);                        00477700
            COREWORD(ADDR(NODE_B)) = LOC_ADDR;                                  00477800
            STRUC_BIAS = SHR(NODE_B(5),1);                                      00477900
            IF NODE_H(STRUC_BIAS) = 0 THEN DO;                                  00478000
               NODE_H(STRUC_BIAS) = STRUC_LINK;                                 00478100
               NODE_B(8) = NODE_B(8)|"01";                                      00478200
               CALL P3_DISP(MODF);                                              00478300
               IF NODE_H(STRUC_BIAS + 1) ^= 0 THEN                              00478400
                  LINK = NODE_H(STRUC_BIAS + 1);                                00478500
               ELSE DO;                                                         00478600
                  LINK = NODE_H(STRUC_BIAS + 2);                                00478700
                  IF LINK < 0 THEN LINK = - LINK;                               00478800
               END;                                                             00478900
            END;                                                                00479000
            ELSE DO;                                                            00479100
               LINK = NODE_H(STRUC_BIAS + 2);                                   00479200
               IF LINK < 0 THEN LINK = - LINK;                                  00479300
            END;                                                                00479400
         END;                                                                   00479500
      END;                                                                      00479600
                                                                                00479700
 /* LINK ALL TEMPLATE TERMINALS ACCORDING TO RELATIVE ADDRESS */                00479800
                                                                                00479900
      DO I = 1 TO #TPLS2;                                                       00480000
         PTR_TEMP = SYMB_TO_PTR(TPL_TAB2(I));                                   00480100
         TPL_PTR = EXTRACT4(PTR_TEMP,8,0);                                      00480200
         CALL P3_LOCATE(TPL_PTR,ADDR(NODE_H),0);                                00480300
         COREWORD(ADDR(NODE_B)) = LOC_ADDR;                                     00480400
         STRUC_BIAS = SHR(NODE_B(5),1);                                         00480500
         LINK = NODE_H(STRUC_BIAS + 1);                                         00480600
         DO WHILE LINK ^= 0;                                                    00480700
            PTR_TEMP = SYMB_TO_PTR(LINK);                                       00480800
            SYMB_EXT_PTR = EXTRACT4(PTR_TEMP,8,0);                              00480900
            CALL P3_LOCATE(SYMB_EXT_PTR,ADDR(NODE_F),0);                        00481000
            ADDRESS = NODE_F(3) & "FFFFFF";                                     00481100
            CALL SEARCH_AND_ENQUEUE(TPL_PTR,LINK,ADDRESS,4);                    00481200
            COREWORD(ADDR(NODE_H)) = LOC_ADDR + 2;                              00481300
            COREWORD(ADDR(NODE_B)) = LOC_ADDR + 2;                              00481400
            STRUC_BIAS = SHR(NODE_B(5),1);                                      00481500
            IF NODE_H(STRUC_BIAS + 1) ^= 0 THEN                                 00481600
               LINK = NODE_H(STRUC_BIAS + 1);                                   00481700
            ELSE DO;                                                            00481800
               LINK = NODE_H(STRUC_BIAS + 2);                                   00481900
               DO WHILE LINK < 0;                                               00482000
                  PTR_TEMP = SYMB_TO_PTR(-LINK);                                00482100
                  SYMB_EXT_PTR = EXTRACT4(PTR_TEMP,8,0);                        00482200
                  CALL P3_LOCATE(SYMB_EXT_PTR,ADDR(NODE_H),0);                  00482300
                  COREWORD(ADDR(NODE_B)) = LOC_ADDR;                            00482400
                  STRUC_BIAS = SHR(NODE_B(5),1);                                00482500
                  LINK = NODE_H(STRUC_BIAS + 2);                                00482600
               END;                                                             00482700
            END;                                                                00482800
         END;                                                                   00482900
      END;                                                                      00483000
                                                                                00483100
 /* LINK ALL INTERNAL SYMBOL ENTRIES TOGETHER IN ALPHABETIC ORDER */            00483200
                                                                                00483300
      PREV_PTR = ROOT_PTR + 30;                                                 00483400
      DO I = 1 TO #SYMBOLS;                                                     00483500
         J = SYT_SORT4(I);                                                      00483600
         K = SYT_SCOPE(SYT_SORT2(J));                                           00483700
         L = SYT_SORT2(PROC_TAB1(K));                                           00483800
         IF (SYT_FLAGS(L)&EXTERNAL_FLAG) = 0 THEN DO;                           00483900
            CALL PUTN(PREV_PTR,0,ADDR(J),2,0);                                  00484000
            PREV_PTR = EXTRACT4(SYMB_TO_PTR(J),8,0) - 4;                        00484100
         END;                                                                   00484200
      END;                                                                      00484300
                                                                                00484400
 /* IF WE HAVE A RIGID COMPOOL, LINK ALL #P DATA TOGETHER BY ADDRESS  */        00484500
                                                                                00484600
      IF RIGID_CPL_FLAG THEN DO;                                                00484700
         PREV_PTR = ROOT_PTR + 32;                                              00484800
         DO I = SELFNAMELOC TO SAVE_NDECSY;                                     00484900
            IF (SYT_FLAGS(I)&LINK_FLAG)^=0 THEN DO;                             00485000
               J = SYT_SORT1(I);                                                00485100
               CALL PUTN(PREV_PTR,0,ADDR(J),2,0);                               00485200
               PREV_PTR = EXTRACT4(SYMB_TO_PTR(J),8,0) - 2;                     00485300
            END;                                                                00485400
         END;                                                                   00485500
         PREV_PTR = ROOT_PTR + 156;   /* SWITCH TO OVERFLOW POINTER */          00485510
         DO I = I TO SAVE_NDECSY;                                               00485520
            IF  (SYT_FLAGS(I) &LINK_FLAG)^=0 THEN DO;                           00485530
               J = SYT_SORT1(I);                                                00485540
               CALL PUTN(PREV_PTR,0,ADDR(J),2,0);                               00485550
               PREV_PTR = EXTRACT4(SYMB_TO_PTR(J),8,0)-2;                       00485560
            END;                                                                00485570
         END;                                                                   00485580
      END;                                                                      00485600
                                                                                00485700
                                                                                00486100
 /* ESTABLISH THE LENGTH OF THE FIXED PORTION OF THE STAB ENTRIES */            00486200
                                                                                00486300
      IF ADDR_FLAG  THEN STAB_FIXED_LEN = 10;                                   00486400
      ELSE STAB_FIXED_LEN = 2;                                                  00486500
      IF SRN_FLAG THEN STAB_FIXED_LEN = STAB_FIXED_LEN + 5;  /*CR12214*/        00486600
      DATA_CELL_PTR = STMT_DATA_HEAD;                                           00486610
                                                                                00486700
 /* READ AND PROCESS THE STATEMENT DATA OF FILE 6 */                            00486800
                                                                                00486900
      DO FOREVER;                                                               00487000
         IF DATA_CELL_PTR = -1 THEN GO TO STMT_DATA_END;                        00487010
         STMT# = GET_STMT_DATA;                                                 00487100
         IF STMT# = -1 THEN GO TO STMT_DATA_END;                                00487200
         STMT_PTR = STMT_TO_PTR(STMT#);                                         00487300
         ORIG_SRN = STMT_DATA(0) < 0;                                           00487310
         CALL P3_LOCATE(STMT_PTR,ADDR(STMT_NODE),RESV|MODF);                    00487400
         STMT_TYPE = (STMT_DATA(0) & "00FF");                                   00487410
/********* DR105709, RAH, 5/28/92 *************************************/
         IF ((STMT_TYPE^=DECL_STMT_TYPE)&(STMT_TYPE^=EQUATE_TYPE)&
           (STMT_TYPE^=TEMP_TYPE)&(STMT_TYPE^=REPLACE_STMT_TYPE)&
           (STMT_TYPE^=STRUC_STMT_TYPE)) THEN DO;
/********* END DR105709 ***********************************************/
            IF COMPOOL_FLAG THEN DO;                                            00487440
               CALL P3_PTR_LOCATE(STMT_PTR,RELS);                               00487450
               GO TO AAA;                                                       00487460
            END;                                                                00487470
                                                                                00487500
 /* REMOVE DUPLICATE LEFT-HAND-SIDE ENTRIES */                                  00487600
                                                                                00487700
            COMPRESS = FALSE;                                                   00487800
            I = 0;                                                              00487900
            DO WHILE I <= #LHS - 2;                                             00488000
               ITEM = LHS_TAB(I);                                               00488100
               IF ITEM < 0 THEN DO;                                             00488200
                  J = I - ITEM + 1;                                             00488300
                  DO WHILE J <= #LHS + ITEM - 1;                                00488400
                     IF LHS_TAB(J) < 0 THEN DO;                                 00488500
                        IF LHS_TAB(J) = ITEM THEN DO;                           00488600
                           NOMATCH = FALSE;                                     00488700
                           DO K = 1 TO -ITEM;                                   00488800
                              IF LHS_TAB(J+K) ^= LHS_TAB(I+K) THEN              00488900
                                 NOMATCH = TRUE;                                00489000
                           END;                                                 00489100
                           IF NOMATCH = FALSE THEN DO;                          00489200
                              COMPRESS = TRUE;                                  00489300
                              DO K = 0 TO -ITEM;                                00489400
                                 LHS_TAB(J+K) = 0;                              00489500
                              END;                                              00489600
                           END;                                                 00489700
                           J = J - ITEM;                                        00489800
                        END;                                                    00489900
                        ELSE J = J - LHS_TAB(J);                                00490000
                     END;                                                       00490100
                     J = J + 1;                                                 00490200
                  END;                                                          00490300
                  I = I - ITEM;                                                 00490400
               END;                                                             00490500
               ELSE IF ITEM > 0 THEN DO;                                        00490600
                  J = I + 1;                                                    00490700
                  DO WHILE J <= #LHS - 1;                                       00490800
                     IF LHS_TAB(J) < 0 THEN J = J - LHS_TAB(J);                 00490900
                     ELSE IF LHS_TAB(J) = ITEM THEN DO;                         00491000
                        COMPRESS = TRUE;                                        00491100
                        LHS_TAB(J) = 0;                                         00491200
                     END;                                                       00491300
                     J = J + 1;                                                 00491400
                  END;                                                          00491500
               END;                                                             00491600
               I = I + 1;                                                       00491700
            END;                                                                00491800
            IF COMPRESS THEN DO;                                                00491900
               I = 0;                                                           00492000
               DO J = 0 TO #LHS - 1;                                            00492100
                  IF LHS_TAB(J) ^= 0 THEN DO;                                   00492200
                     LHS_TAB(I) = LHS_TAB(J);                                   00492300
                     I = I + 1;                                                 00492400
                  END;                                                          00492500
               END;                                                             00492600
               #LHS = I;                                                        00492700
            END;                                                                00492800
                                                                                00492900
 /* ALLOCATE A STATEMENT EXTENSION NODE FOR THIS STATEMENT */                   00493000
                                                                                00493100
            IF (ADDR_FLAG) & (FC) THEN LEN = 12;                                00493200
            ELSE LEN = 6;                                                       00493300
            LEN = LEN + SHL(#LABELS + #LHS,1);                                  00493400
            IF ORIG_SRN THEN LEN = LEN + 6;                                     00493410
            IF OVERFLOW THEN LEN = LEN + 6;                                     00493420
            IF LHS_PTR ^= 0 THEN N = 8;                                         00493500
            ELSE IF RHS_PTR ^= 0 THEN N = 4;                                    00493510
            ELSE N = 0;                                                         00493520
            N = N+8;      /*  SPACE FOR FLAGS AND OFFSET FIELDS */              00493525
            STMT_EXT_PTR = GET_DATA_CELL(LEN+N,ADDR(STMT_EXT_NODE),RESV);       00493530
            COREWORD(ADDR(NODE_F)),COREWORD(ADDR(STMT_EXT_NODE)) = LOC_ADDR + N;00493540
            STMT_EXT_PTR = STMT_EXT_PTR + N;                                    00493550
                                                                                00493600
            PAGE = SHR(STMT_EXT_PTR,16) & "FFFF";                               00493700
            OFFSET = STMT_EXT_PTR & "FFFF";                                     00493800
         END;  /* OF EXECUTABLE STMT CASE */                                    00493810
         ELSE DO;                                                               00493820
            LEN = 4;                                                            00493830
            IF ORIG_SRN THEN N=14;                                              00493840
            ELSE IF HMAT_OPT THEN N=8;                                          00493850
            ELSE IF DECL_EXP_PTR ^= -1 THEN N=4;                                00493890
            ELSE N=0;                                                           00493900
            STMT_EXT_PTR = GET_DATA_CELL(LEN+N,ADDR(STMT_EXT_NODE),RESV);       00493910
            COREWORD(ADDR(NODE_F)),COREWORD(ADDR(STMT_EXT_NODE)) = LOC_ADDR;    00493920
            PAGE = SHR((-STMT_EXT_PTR),16) & "FFFF";                            00493930
            OFFSET = (-STMT_EXT_PTR) & "FFFF";                                  00493940
         END;                                                                   00493950
                                                                                00493960
 /* FILL IN THE STATEMENT NODE */                                               00494000
                                                                                00494100
         IF SRN_FLAG THEN DO;                                                   00494200
            J = 4;                                                              00494300
            IF ADDR_FLAG THEN I = 11;                                           00494400
            ELSE I = 3;                                                         00494500
            DO K = 0 TO 3;                                                      00494600
               STMT_NODE(K) = STMT_DATA(I + K);                                 00494700
            END;                                                                00494800
         END;                                                                   00494900
         ELSE J = 0;                                                            00495000
         STMT_NODE(J) = PAGE;                                                   00495100
         STMT_NODE(J + 1) = OFFSET;                                             00495200
                                                                                00495300
 /* WE ARE NOW DONE WITH THE STATEMENT NODE -- THEREFORE RELEASE IT */          00495400
                                                                                00495500
         CALL P3_PTR_LOCATE(STMT_PTR,RELS);                                     00495600
                                                                                00495700
 /* FILL IN THE STATEMENT EXTENSION NODE */                                     00495800
         COREWORD(ADDR(NODE_H)) = COREWORD(ADDR(NODE_F));                       00495805
/********* DR105709, RAH, 5/28/92 *************************************/
         IF ((STMT_TYPE=DECL_STMT_TYPE)|(STMT_TYPE=EQUATE_TYPE)|
           (STMT_TYPE=TEMP_TYPE)|(STMT_TYPE=REPLACE_STMT_TYPE)|
           (STMT_TYPE=STRUC_STMT_TYPE)) THEN DO;
/********* END DR105709 ***********************************************/
            STMT_EXT_NODE(0) = STMT_DATA(2);                                    00495835
            IF ORIG_SRN THEN DO;                                                00495845
               STMT_EXT_NODE(1) = "2000";                                       00495855
               DO J=1 TO 3;                                                     00495865
                 IF SRN_FLAG THEN                                   /*CR12214*/
                  STMT_EXT_NODE(5+J)=STMT_DATA(STAB_FIXED_LEN+J-1); /*CR12214*/
                 ELSE                                               /*CR12214*/
                  STMT_EXT_NODE(5+J)=STMT_DATA(STAB_FIXED_LEN+J);               00495875
               END;                                                             00495885
            END;                                                                00495895
            IF DECL_EXP_PTR ^= NILL THEN DO;                                    00495905
               NODE_F(1) = MOVE_CELL_TREE(DECL_EXP_PTR);                        00495915
               STMT_EXT_NODE(1) = STMT_EXT_NODE(1) | "8000";                    00495925
            END;                                                                00495935
            IF HMAT_OPT THEN DO;                                                00495945
               NODE_F(2) = HALMAT_CELL;                                         00495955
               STMT_EXT_NODE(1) = STMT_EXT_NODE(1) | "4000";                    00495965
            END;                                                                00495985
            STMT_EXT_NODE(1) = ((STMT_EXT_NODE(1)&"FF00") | (STMT_TYPE&"00FF"));00495995
         END;                                                                   00496005
         ELSE DO;                                                               00496015
            NODE_H(-4) = SDC_FLAGS;   /*  PUT IN FLAG BITS  */                  00496025
                                                                                00496035
            IF LHS_PTR ^= 0 THEN DO;                                            00496045
               NODE_F(-4) = MOVE_CELL_TREE(LHS_PTR);                            00496055
               STMT_DATA = STMT_DATA | "4000";                                  00496065
            END;                                                                00496075
            IF RHS_PTR ^= 0 THEN DO;                                            00496085
               NODE_F(-3) = MOVE_CELL_TREE(RHS_PTR);                            00496095
               STMT_DATA = STMT_DATA | "2000";                                  00496105
            END;                                                                00496115
            IF HMAT_OPT                                                         00496125
               THEN NODE_F(-1) = HALMAT_CELL;                                   00496135
            STMT_EXT_NODE(0) = STMT_DATA(2);                                    00496145
            STMT_EXT_NODE(1) = STMT_DATA(0);   /* STATEMENT TYPE */             00496155
            STMT_EXT_NODE(2) = SHL(#LABELS,8) + #LHS;                           00496200
            I = 3;                                                              00496300
            DO J = 0 TO #LABELS - 1;                                            00496400
               STMT_EXT_NODE(I) = LABEL_TAB(J);                                 00496500
               I = I + 1;                                                       00496600
            END;                                                                00496700
            DO J = 0 TO #LHS - 1;                                               00496800
               STMT_EXT_NODE(I) = LHS_TAB(J);                                   00496900
               I = I + 1;                                                       00497000
            END;                                                                00497100
            IF (ADDR_FLAG) & (FC) THEN DO;                                      00497200
               FULL_TEMP = SHL(STMT_DATA(3),16) + STMT_DATA(4);                 00497300
               FULL_TEMP = SHL(FULL_TEMP,8);                                    00497400
               STMT_EXT_NODE(I) = SHR(FULL_TEMP,16) & "FFFF";                   00497500
               STMT_EXT_NODE(I + 1) = FULL_TEMP & "FFFF";                       00497600
               FULL_TEMP = SHL(STMT_DATA(5),16) + STMT_DATA(6);                 00497700
               STMT_EXT_NODE(I + 2) = FULL_TEMP & "FFFF";                       00497800
               STMT_EXT_NODE(I + 1) = STMT_EXT_NODE(I + 1) |                    00497900
                  (SHR(FULL_TEMP,16) & "FFFF");                                 00498000
               I = I + 3;                                                       00498100
            END;                                                                00498105
            IF ORIG_SRN THEN DO;                                                00498110
               DO J = 1 TO 3;                                                   00498115
                 IF SRN_FLAG THEN                                   /*CR12214*/
                  STMT_EXT_NODE(I+J-1) = STMT_DATA(STAB_FIXED_LEN+J-1); /* " */
                 ELSE                                               /*CR12214*/
                  STMT_EXT_NODE(I+J-1) = STMT_DATA(STAB_FIXED_LEN+J);           00498120
               END;                                                             00498125
               I = I + 3;                                                       00498126
            END;                                                                00498130
            IF OVERFLOW THEN DO;                                                00498135
 /* FILL IN OVERFLOW ADDRESS FIELDS */                                          00498140
               FULL_TEMP = SHL(STMT_DATA(7),16) + STMT_DATA(8);                 00498145
               FULL_TEMP = SHL(FULL_TEMP,8);                                    00498150
               STMT_EXT_NODE(I) = SHR(FULL_TEMP,16) & "FFFF";                   00498155
               STMT_EXT_NODE(I+1) = FULL_TEMP & "FFFF";                         00498160
               FULL_TEMP = SHL(STMT_DATA(9) , 16) + STMT_DATA(10);              00498165
               STMT_EXT_NODE(I+2) = FULL_TEMP & "FFFF";                         00498170
               STMT_EXT_NODE(I+1) = STMT_EXT_NODE(I+1) |                        00498175
                  (SHR(FULL_TEMP,16) & "FFFF");                                 00498180
               NODE_H(-3) = 2*I;  /*  USE BYTE OFFSET  */                       00498185
               I = I+3;                                                         00498190
            END;                                                                00498195
            ELSE NODE_H(-3) = 0;                                                00498200
         END;                                                                   00498210
 /* WE ARE NOW DONE WITH THE STATEMENT EXTENSION NODE --- THEREFORE   */        00498300
 /* RELEASE IT!                                                       */        00498400
                                                                                00498500
         CALL P3_PTR_LOCATE(STMT_EXT_PTR,RELS);                                 00498600
AAA:                                                                            00498602
      END;                                                                      00498700
STMT_DATA_END:                                                                  00498800
                                                                                00498900
 /* CONVERT ALL OF THE SYMBOL TABLE INDICES IN THE STATEMENT EXTENSION */       00499000
 /* NODES TO SYMBOL TABLE POINTERS.  ALSO, IF STATEMENT REFERENCE NOS  */       00499100
 /* (SRNS) ARE PRESENT, CONSTRUCT THE REQUISITE DIRECTORY STRUCTURES.  */       00499200
                                                                                00499300
INX_TO_PTR:                                                                     00499400
      PROCEDURE;                                                                00499500
         K = STMT_EXT_NODE(I);                                                  00499600
         IF K > 0 THEN DO;                                                      00499700
            M = SYT_SORT1(K);                                                   00499800
            STMT_EXT_NODE(I) = M;                                               00499900
         END;                                                                   00500000
         I = I + 1;                                                             00500100
      END INX_TO_PTR;                                                           00500300
                                                                                00500400
BAD_SRN:                                                                        00500500
      PROCEDURE;                                                                00500600
         SRN_FLAG1 = TRUE;                                                      00500700
         OUTPUT = '*** BAD SRN DETECTED AT STMT ' || STMT# || X4                00500800
            || 'SRN/COUNT:       ' || THIS_SRN || X2 || THIS_CNT;               00500900
         RETURN;                                                                00501000
      END BAD_SRN;                                                              00501100
                                                                                00501200
      PAGE_F = SHR(FIRST_STMT_PTR,16);                                          00501300
      PAGE_L = SHR(LAST_STMT_PTR,16);                                           00501400
      STMT# = FIRST_STMT - 1;                                                   00501500
                                                                                00501600
      IF SRN_FLAG THEN DO;                                                      00501700
         COREWORD(ADDR(LAST_SRN)) = "05000000" + ADDR(SRN_BUFF);                00501800
         SRN_BUFF(0) = "40404040";                                              00501900
         SRN_BUFF(1) = "4040FFFF";                                              00502000
         LAST_CNT = -1;                                                         00502100
         MAX_#PAGES = (MAX_CELL - 8)/20;                                        00502200
         PREV_PTR = ROOT_PTR + 68;                                              00502300
         CALL TRAN(FIRST_STMT_PTR,0,ROOT_PTR,72,8,0);                           00502400
         CALL TRAN(LAST_STMT_PTR,0,ROOT_PTR,80,8,RESV);                         00502500
         BLK_INX_LIM = -1;                                                      00502600
      END;                                                                      00502700
                                                                                00502800
      DO PAGE = PAGE_F TO PAGE_L;                                               00502900
         IF SRN_FLAG THEN DO;                                                   00503000
            IF BLK_INX >= BLK_INX_LIM THEN DO;                                  00503100
               #PAGES = PAGE_L - PAGE + 1;                                      00503200
               LEN = 8 + #PAGES * 20;                                           00503300
               IF #PAGES > MAX_#PAGES THEN DO;                                  00503400
                  LEN = 8 + MAX_#PAGES * 20;                                    00503500
                  #PAGES = MAX_#PAGES;                                          00503600
               END;                                                             00503700
               BLK_INX_LIM = SHR(LEN,2);                                        00503800
               BLK_INX = 2;                                                     00503900
               BLK_EXT_PTR = GET_DIR_CELL(LEN,ADDR(BLK_EXT_NODE),RESV);         00504000
               BLK_EXT_NODE(0) = 0;                                             00504100
               BLK_EXT_NODE(1) = SHL(#PAGES,16) + PAGE;                         00504200
               CALL PUTN(PREV_PTR,0,ADDR(BLK_EXT_PTR),4,RELS);                  00504300
               PREV_PTR = BLK_EXT_PTR;                                          00504400
            END;                                                                00504500
         END;                                                                   00504600
         PTR = SHL(PAGE,16);                                                    00504700
         LOC1 = 0;                                                              00504800
         IF PAGE = PAGE_F THEN LOC1 = FIRST_STMT_PTR&"FFFF";                    00504805
         LOC1,FIRST_OFFSET = SHR(LOC1,2);                                       00504810
         LOC2 = PAGE_SIZE - STMT_NODE_SIZE;                                     00504815
         IF PAGE = PAGE_L THEN LOC2 = LAST_STMT_PTR&"FFFF";                     00504820
         LOC2,LAST_OFFSET = SHR(LOC2,2);                                        00504825
         CALL P3_LOCATE(PTR,ADDR(STMT_PAGE),RESV);                              00504830
         DO OFFSET = FIRST_OFFSET TO LAST_OFFSET BY BIAS + 1;                   00505600
            STMT# = STMT# + 1;                                                  00505700
            STMT_EXT_PTR = STMT_PAGE(OFFSET + BIAS);                            00505800
            IF STMT_EXT_PTR ^= 0 THEN DO;                                       00505900
               CALL P3_LOCATE(ABS(STMT_EXT_PTR),ADDR(STMT_EXT_NODE),MODF);      00506100
               K = STMT_EXT_NODE(0);                                            00506200
               BLK_NUM = SYT_SORT3(K);                                          00506300
               STMT_EXT_NODE(0) = BLK_NUM;                                      00506400
               IF STMT_EXT_PTR > 0 THEN DO;                                     00506410
                  #EXECS = #EXECS + 1;                                          00506420
                  IF (STMT_EXT_NODE(1)&"00FF") = "0016" THEN DO;                00506500
                     PTR_TEMP = PROC_TAB4(BLK_NUM);                             00506600
                     CALL P3_LOCATE(PTR_TEMP,ADDR(BLK_LIST_NODE),MODF);         00506700
                     BLK_LIST_NODE(18) = STMT#;                                 00506800
                     COREWORD(ADDR(NODE_F)) = LOC_ADDR;                         00506900
                     I = PROC_TAB8(PROC_TAB5(BLK_LIST_NODE(13)));               00507000
                     LEVEL = SYT_NEST(SYT_SORT2(PROC_TAB1(I)));                 00507100
                     IF LEVEL > 1 THEN DO;                                      00507200
                        DEX = PROC_TAB9(LEVEL - 1);                             00507300
                        NODE_F(3) = - PROC_TAB4(DEX);                           00507400
                        IF LEVEL <= OLD_LEVEL THEN DO;                          00507500
                           DEX = PROC_TAB9(LEVEL);                              00507600
                           CALL PUTN(PROC_TAB4(DEX),12,ADDR(PTR_TEMP),4,0);     00507700
                        END;                                                    00507800
                        ELSE CALL PUTN(PROC_TAB4(DEX),8,ADDR(PTR_TEMP),4,0);    00507900
                     END;                                                       00508000
                     OLD_LEVEL = LEVEL;                                         00508100
                     PROC_TAB9(LEVEL) = BLK_NUM;                                00508200
                  END;                                                          00508300
                  ELSE IF (STMT_EXT_NODE(1)&"00FF") = "0006" THEN DO;           00508400
                     PTR_TEMP = PROC_TAB4(BLK_NUM);                             00508500
                     CALL P3_LOCATE(PTR_TEMP,ADDR(BLK_LIST_NODE),MODF);         00508600
                     BLK_LIST_NODE(19) = STMT#;                                 00508700
                     IF (PROC_FLAGS(BLK_NUM) & "0001") = 0 THEN                 00508800
                        BLK_LIST_NODE(20) = STMT#;                              00508900
                  END;                                                          00509000
                  ELSE IF (PROC_FLAGS(BLK_NUM) & "0001") = 0 THEN DO;           00509100
                     PROC_FLAGS(BLK_NUM) = PROC_FLAGS(BLK_NUM) | "0001";        00509200
                     PTR_TEMP = PROC_TAB4(BLK_NUM);                             00509300
                     CALL P3_LOCATE(PTR_TEMP,ADDR(BLK_LIST_NODE),MODF);         00509400
                     BLK_LIST_NODE(20) = STMT#;                                 00509500
                  END;                                                          00509600
                  #LABELS = SHR(STMT_EXT_NODE(2),8);                            00509700
                  #LHS = STMT_EXT_NODE(2) & "FF";                               00509800
                  I = 3;                                                        00509900
                  DO J = 0 TO #LABELS - 1;                                      00510000
                     CALL INX_TO_PTR;                                           00510100
                     PTR_TEMP = SYMB_TO_PTR(M);                                 00510200
                     SYMB_EXT_PTR = EXTRACT4(PTR_TEMP,8,0);                     00510300
                     CALL P3_LOCATE(SYMB_EXT_PTR,ADDR(SYMB_EXT_NODE),MODF);     00510400
                     SYMB_EXT_NODE(7) = STMT#;                                  00510500
                  END;                                                          00510600
                  DO J = 0 TO #LHS - 1;                                         00510700
                     CALL INX_TO_PTR;                                           00510800
                  END;                                                          00510900
               END;                                                             00510910
               IF SRN_FLAG THEN DO;                                             00511000
                  COREWORD(ADDR(THIS_SRN)) = "05000000" +                       00511300
                     COREWORD(ADDR(STMT_PAGE)) + SHL(OFFSET,2);                 00511400
                  THIS_CNT = STMT_PAGE(OFFSET + 1) & "FFFF";                    00511500
                  IF THIS_SRN = LAST_SRN THEN DO;                               00511600
                     IF THIS_CNT < LAST_CNT THEN CALL BAD_SRN;                  00511700
                     ELSE IF THIS_CNT = LAST_CNT THEN DO;                       00511800
                        SRN_FLAG2 = TRUE;                                       00511900
                        /*CR12940 - REMOVED DUPLICATE SRN MESSAGE*/
                     END;                                                       00512400
                  END;                                                          00512500
                  ELSE IF THIS_SRN < LAST_SRN THEN CALL BAD_SRN;                00512600
                  SRN_BUFF(0) = STMT_PAGE(OFFSET);                              00512700
                  SRN_BUFF(1) = STMT_PAGE(OFFSET + 1);                          00512800
                  LAST_CNT = THIS_CNT;                                          00512900
               END;                                                             00513000
            END;                                                                00513100
            ELSE IF SRN_FLAG THEN DO;                                           00513200
               STMT_PAGE(OFFSET) = SRN_BUFF(0);                                 00513300
               LAST_CNT = LAST_CNT + 1;                                         00513400
               STMT_PAGE(OFFSET + 1) = (SRN_BUFF(1) & "FFFF0000") | LAST_CNT;   00513500
            END;                                                                00513600
         END;                                                                   00513700
         IF SRN_FLAG THEN DO;                                                   00513800
            BLK_EXT_NODE(BLK_INX) = SHL(LOC1,18) + SHL(LOC2,2);                 00513900
            BLK_EXT_NODE(BLK_INX + 1) = STMT_PAGE(LOC1);                        00514000
            BLK_EXT_NODE(BLK_INX + 2) = STMT_PAGE(LOC1 + 1);                    00514100
            BLK_EXT_NODE(BLK_INX + 3) = STMT_PAGE(LOC2);                        00514200
            BLK_EXT_NODE(BLK_INX + 4) = STMT_PAGE(LOC2 + 1);                    00514300
            BLK_INX = BLK_INX + 5;                                              00514400
         END;                                                                   00514500
         CALL P3_PTR_LOCATE(PTR,RELS);                                          00514600
      END;                                                                      00514700
      IF SRN_FLAG THEN CALL P3_PTR_LOCATE(BLK_EXT_PTR,RELS);                    00514800
/*PUT INITIAL VALUES INTO SDF*/
      CALL BUILD_INITTAB;    /*CR13079*/
                                                                                00514900
   END BUILD_SDF   /*  $S  */  ;  /*  $S  */                                    00515100
