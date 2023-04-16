 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PASS1.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  PASS1                                                  */
/* MEMBER NAME:     PASS1                                                  */
/* LOCAL DECLARATIONS:                                                     */
/*          ADD_TO_VAC_BOUNDS LABEL                                        */
/*          ADD_UVC           LABEL                                        */
/*          CLASS_0           LABEL                                        */
/*          CLASS_1(724)      LABEL                                        */
/*          CLASS_2(725)      LABEL                                        */
/*          CLASS_3(726)      LABEL                                        */
/*          CLASS_4(727)      LABEL                                        */
/*          CLASS_5(728)      LABEL                                        */
/*          CLASS_6(729)      LABEL                                        */
/*          CLASS_7(15)       LABEL                                        */
/*          CLOSE_DOWN_DONE(758)  LABEL                                    */
/*          COMPUTE_NOOSE     LABEL                                        */
/*          DECODE_HALRAND    LABEL                                        */
/*          DECODE_HALRATOR   LABEL                                        */
/*          DUMP_STACK        LABEL                                        */
/*          FLUSH_INFO        LABEL                                        */
/*          HANDLE_SIMP_NOOSE(704)  LABEL                                  */
/*          HANDLE_SIMP_OR_ASN_NOOSE(731)  LABEL                           */
/*          NUMOP             BIT(16)                                      */
/*          POP_BLOCK_FRAME(719)  LABEL                                    */
/*          POP_CASE_FRAME    LABEL                                        */
/*          POP_CB_FRAME(730) LABEL                                        */
/*          PUSH_BLOCK_FRAME(735)  LABEL                                   */
/*          PUSH_CASE_FRAME   LABEL                                        */
/*          PUSH_CB_FRAME(714)  LABEL                                      */
/*          PUSH_FIRST_CASE_FRAME  LABEL                                   */
/*          SAVE_STACK_PTR    BIT(16)                                      */
/*          SEARCH_FOR_REF    LABEL                                        */
/*          SET_ASN_NOOSE(709)  LABEL                                      */
/*          SET_DEBUG_SWITCH  LABEL                                        */
/*          SET_RAND_NOOSE    LABEL                                        */
/*          SET_SIMP_NOOSE(732)  LABEL                                     */
/*          STACK_ERROR(717)  LABEL                                        */
/*          THIS_HALMAT_BLOCK BIT(8)                                       */
/*          ZAPPER(724)       LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUXMAT_END_OPCODE                                              */
/*          AUXMAT1                                                        */
/*          AUXM1                                                          */
/*          BEYOND_CONDITIONAL_FLAG                                        */
/*          BLANK                                                          */
/*          BLOCK_TYPE                                                     */
/*          C_LIST_PTRS                                                    */
/*          CASE_LIST_PTRS                                                 */
/*          CASE_TYPE                                                      */
/*          CB_TYPE                                                        */
/*          CCURRENT                                                       */
/*          CDR_CELL                                                       */
/*          CELL_CDR                                                       */
/*          CELL1                                                          */
/*          CELL1_FLAGS                                                    */
/*          CELL2                                                          */
/*          CELL2_FLAGS                                                    */
/*          CLASS_BI                                                       */
/*          CLOSE                                                          */
/*          CURR_HALMAT_BLOCK                                              */
/*          C1                                                             */
/*          C1_FLAGS                                                       */
/*          C2                                                             */
/*          C2_FLAGS                                                       */
/*          F_BLOCK_PTR                                                    */
/*          F_BUMP_FACTOR                                                  */
/*          F_CASE_LIST                                                    */
/*          F_CB_NEST_LEVEL                                                */
/*          F_FLAGS                                                        */
/*          F_INL                                                          */
/*          F_MAP_SAVE                                                     */
/*          F_START                                                        */
/*          F_SYT_PREV_REF                                                 */
/*          F_SYT_REF                                                      */
/*          F_TYPE                                                         */
/*          F_UVCS                                                         */
/*          F_VAC_PREV_REF                                                 */
/*          F_VAC_REF                                                      */
/*          FALSE                                                          */
/*          FALSE_CASE                                                     */
/*          FIRST_CASE_TBD_FLAG                                            */
/*          FLUSH_FLAG                                                     */
/*          FOR                                                            */
/*          FRAME_BLOCK_PTR                                                */
/*          FRAME_BUMP_FACTOR                                              */
/*          FRAME_CASE_LIST                                                */
/*          FRAME_CB_NEST_LEVEL                                            */
/*          FRAME_FLAGS                                                    */
/*          FRAME_INL                                                      */
/*          FRAME_MAP_SAVE                                                 */
/*          FRAME_START                                                    */
/*          FRAME_SYT_PREV_REF                                             */
/*          FRAME_SYT_REF                                                  */
/*          FRAME_TYPE                                                     */
/*          FRAME_UVCS                                                     */
/*          FRAME_VAC_PREV_REF                                             */
/*          FRAME_VAC_REF                                                  */
/*          FUNCTION                                                       */
/*          GEN_CODE                                                       */
/*          GEN_LIST_OPCODE                                                */
/*          GENER_CODE                                                     */
/*          HALMAT_SIZE                                                    */
/*          HEADER_ISSUED                                                  */
/*          IF_THEN_ELSE_MASK                                              */
/*          M_CASE_LENGTH                                                  */
/*          MAP_INDICES                                                    */
/*          MAX_CASE_LENGTH                                                */
/*          MAX_REF_SYT_SIZE                                               */
/*          NOOSE_OPCODE                                                   */
/*          NOO                                                            */
/*          NOOSE                                                          */
/*          OFF                                                            */
/*          ON                                                             */
/*          PNTR                                                           */
/*          PNTR_TYPE                                                      */
/*          PREV_BLOCK_FLAG                                                */
/*          PTR_TYPE                                                       */
/*          PTR                                                            */
/*          RAND_CSE_FLAG                                                  */
/*          RAND_XB_FLAG                                                   */
/*          RATOR_CSE_FLAG                                                 */
/*          S_EXPAND_NDX                                                   */
/*          S_REF_POOL                                                     */
/*          S_SHRINK_NDX                                                   */
/*          SNCS_OPCODE                                                    */
/*          SNDX                                                           */
/*          SXPND                                                          */
/*          SYM_LENGTH                                                     */
/*          SYM_TAB                                                        */
/*          SYT                                                            */
/*          SYT_DIMS                                                       */
/*          SYT_EXPAND_INDEX                                               */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/*          SYT_REF_POOL                                                   */
/*          SYT_SHRINK_INDEX                                               */
/*          TAGS                                                           */
/*          TARGET                                                         */
/*          TGS                                                            */
/*          TRGT                                                           */
/*          TRUE                                                           */
/*          TRUE_CASE                                                      */
/*          TRUE_ONLY_FLAG                                                 */
/*          V_BOUNDS                                                       */
/*          V_REF_POOL                                                     */
/*          VAC                                                            */
/*          VAC_BOUNDS                                                     */
/*          VAC_REF_POOL_FRAME_SIZE                                        */
/*          VAC_REF_POOL                                                   */
/*          XREC_OPCODE                                                    */
/*          ZAP_FLAG                                                       */
/*          ZAP_OR_FLUSH                                                   */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          AUXMAT_REQUESTED                                               */
/*          AUXMATING                                                      */
/*          BLOCK_PRIME                                                    */
/*          CURRENT_STMT                                                   */
/*          HALMAT                                                         */
/*          HALMAT_PTR                                                     */
/*          HALRAND                                                        */
/*          HALRAND_QUALIFIER                                              */
/*          HALRAND_TAG1                                                   */
/*          HALRAND_TAG2                                                   */
/*          HALRATOR                                                       */
/*          HALRATOR_#RANDS                                                */
/*          HALRATOR_CLASS                                                 */
/*          HALRATOR_TAG1                                                  */
/*          HALRATOR_TAG2                                                  */
/*          LIST_STRUX                                                     */
/*          NOOSE_TRACE                                                    */
/*          OPCODE_TRACE                                                   */
/*          PRETTY_PRINT_REQUESTED                                         */
/*          REF_PTR1                                                       */
/*          REF_PTR2                                                       */
/*          S_POOL                                                         */
/*          STACK_DUMP                                                     */
/*          STACK_FRAME                                                    */
/*          STACK_PTR                                                      */
/*          STOP_COND_LIST                                                 */
/*          TARGET_TRACE                                                   */
/*          TEMP_MAT                                                       */
/*          TIME_EXIT                                                      */
/*          V_POOL                                                         */
/*          WORK_VARS                                                      */
/*          WORK1                                                          */
/*          XREC_PRIME_PTR                                                 */
/*          XREC_PTR                                                       */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          #RJUST                                                         */
/*          COPY_SYT_REF_FRAME                                             */
/*          COPY_VAC_REF_FRAME                                             */
/*          DECR_STACK_PTR                                                 */
/*          ERRORS                                                         */
/*          FREE_SYT_REF_FRAME                                             */
/*          FREE_VAC_REF_FRAME                                             */
/*          GET_FREE_CELL                                                  */
/*          HEX                                                            */
/*          INCR_STACK_PTR                                                 */
/*          LIST                                                           */
/*          NEW_HALMAT_BLOCK                                               */
/*          NEW_SYT_REF_FRAME                                              */
/*          NEW_VAC_REF_FRAME                                              */
/*          NEW_ZERO_SYT_REF_FRAME                                         */
/*          NEW_ZERO_VAC_REF_FRAME                                         */
/*          OUTPUT_LIST                                                    */
/*          OUTPUT_SYT_MAP                                                 */
/*          OUTPUT_VAC_MAP                                                 */
/*          PASS_BACK_SYT_REFS                                             */
/*          PASS_BACK_VAC_REFS                                             */
/*          PRINT_PHASE_HEADER                                             */
/*          TRACE_MSG                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PASS1 <==                                                           */
/*     ==> #RJUST                                                          */
/*     ==> HEX                                                             */
/*     ==> PRINT_PHASE_HEADER                                              */
/*         ==> PRINT_DATE_AND_TIME                                         */
/*             ==> PRINT_TIME                                              */
/*     ==> OUTPUT_LIST                                                     */
/*         ==> #RJUST                                                      */
/*         ==> HEX                                                         */
/*     ==> OUTPUT_SYT_MAP                                                  */
/*         ==> HEX                                                         */
/*     ==> OUTPUT_VAC_MAP                                                  */
/*         ==> HEX                                                         */
/*     ==> TRACE_MSG                                                       */
/*     ==> ERRORS                                                          */
/*         ==> PRINT_PHASE_HEADER                                          */
/*             ==> PRINT_DATE_AND_TIME                                     */
/*                 ==> PRINT_TIME                                          */
/*         ==> COMMON_ERRORS                                               */
/*     ==> NEW_HALMAT_BLOCK                                                */
/*         ==> PRETTY_PRINT_MAT                                            */
/*             ==> FORMAT_HALMAT                                           */
/*                 ==> #RJUST                                              */
/*                 ==> HEX                                                 */
/*             ==> FORMAT_AUXMAT                                           */
/*                 ==> #RJUST                                              */
/*                 ==> HEX                                                 */
/*     ==> NEW_SYT_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/*     ==> FREE_SYT_REF_FRAME                                              */
/*     ==> NEW_VAC_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/*     ==> FREE_VAC_REF_FRAME                                              */
/*     ==> NEW_ZERO_SYT_REF_FRAME                                          */
/*         ==> NEW_SYT_REF_FRAME                                           */
/*             ==> ERRORS                                                  */
/*                 ==> PRINT_PHASE_HEADER                                  */
/*                     ==> PRINT_DATE_AND_TIME                             */
/*                         ==> PRINT_TIME                                  */
/*                 ==> COMMON_ERRORS                                       */
/*     ==> NEW_ZERO_VAC_REF_FRAME                                          */
/*         ==> NEW_VAC_REF_FRAME                                           */
/*             ==> ERRORS                                                  */
/*                 ==> PRINT_PHASE_HEADER                                  */
/*                     ==> PRINT_DATE_AND_TIME                             */
/*                         ==> PRINT_TIME                                  */
/*                 ==> COMMON_ERRORS                                       */
/*     ==> COPY_SYT_REF_FRAME                                              */
/*         ==> NEW_SYT_REF_FRAME                                           */
/*             ==> ERRORS                                                  */
/*                 ==> PRINT_PHASE_HEADER                                  */
/*                     ==> PRINT_DATE_AND_TIME                             */
/*                         ==> PRINT_TIME                                  */
/*                 ==> COMMON_ERRORS                                       */
/*     ==> COPY_VAC_REF_FRAME                                              */
/*         ==> NEW_ZERO_VAC_REF_FRAME                                      */
/*             ==> NEW_VAC_REF_FRAME                                       */
/*                 ==> ERRORS                                              */
/*                     ==> PRINT_PHASE_HEADER                              */
/*                         ==> PRINT_DATE_AND_TIME                         */
/*                             ==> PRINT_TIME                              */
/*                     ==> COMMON_ERRORS                                   */
/*     ==> PASS_BACK_SYT_REFS                                              */
/*         ==> NEW_ZERO_SYT_REF_FRAME                                      */
/*             ==> NEW_SYT_REF_FRAME                                       */
/*                 ==> ERRORS                                              */
/*                     ==> PRINT_PHASE_HEADER                              */
/*                         ==> PRINT_DATE_AND_TIME                         */
/*                             ==> PRINT_TIME                              */
/*                     ==> COMMON_ERRORS                                   */
/*         ==> MERGE_SYT_REF_FRAMES                                        */
/*     ==> PASS_BACK_VAC_REFS                                              */
/*         ==> NEW_ZERO_VAC_REF_FRAME                                      */
/*             ==> NEW_VAC_REF_FRAME                                       */
/*                 ==> ERRORS                                              */
/*                     ==> PRINT_PHASE_HEADER                              */
/*                         ==> PRINT_DATE_AND_TIME                         */
/*                             ==> PRINT_TIME                              */
/*                     ==> COMMON_ERRORS                                   */
/*         ==> MERGE_VAC_REF_FRAMES                                        */
/*     ==> GET_FREE_CELL                                                   */
/*     ==> LIST                                                            */
/*     ==> INCR_STACK_PTR                                                  */
/*     ==> DECR_STACK_PTR                                                  */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/***************************************************************************/
/*   REVISION HISTORY:                                                     */
/*   DATE    CR/DR   DEVELOPER  DESCRIPTION                                */
/* 03/07/91  CR11109    RSJ     DELETE UNUSED VARIABLES                    */
/*                                                                         */
/***************************************************************************/
                                                                                02966000
/*******************************************************************************02968000
         F I R S T   P A S S   A T   H A L M A T                                02970000
  (THIS ROUTINE SETS UP A SET OF INTERMEDIATE LISTS FOR LATER CODE GENERATION)  02972000
*******************************************************************************/02974000
                                                                                02976000
PASS1: PROCEDURE;                                                               02978000
                                                                                02980000
   DECLARE NUMOP BIT(16);                                                       02982000
   DECLARE THIS_HALMAT_BLOCK BIT(1);                                            02984000
   DECLARE                                                                      02986000
        SAVE_STACK_PTR                 BIT(16);                                 02988000
                                                                                02990000
                                                                                02992000
         /* ROUTINE TO DECODE A HALMAT OPERATOR */                              02994000
                                                                                02996000
DECODE_HALRATOR: PROCEDURE(OP);                                                 02998000
                                                                                03000000
   DECLARE OP BIT(16);                                                          03002000
                                                                                03004000
   TEMP_MAT = HALMAT(OP);                                                       03006000
   IF (TEMP_MAT & 1) ^= 0 THEN CALL ERRORS (CLASS_BI, 403,                      03008000
       ' '||CURR_HALMAT_BLOCK - 1||':'||OP);                                    03008010
   HALRATOR_TAG2 = TEMP_MAT & "F";                                              03012000
   HALRATOR = SHR(TEMP_MAT, 4) & "FF";                                          03014000
   HALRATOR_CLASS = SHR(TEMP_MAT, 12) & "F";                                    03016000
   HALRATOR_#RANDS = SHR(TEMP_MAT, 16) & "FF";                                  03018000
   HALRATOR_TAG1 = SHR(TEMP_MAT, 24) & "FF";                                    03020000
                                                                                03022000
   IF OPCODE_TRACE THEN                                                         03024000
      OUTPUT = TRACE_MSG(                                                       03026000
         'HALRATOR =' ||                                                        03028000
         HEX(HALRATOR_CLASS, 1) ||                                              03030000
         HEX(HALRATOR, 2),                                                      03032000
         OP );                                                                  03034000
                                                                                03036000
CLOSE DECODE_HALRATOR;                                                          03038000
                                                                                03040000
                                                                                03042000
         /* ROUTINE TO DECODE A HALMAT OPERAND */                               03044000
                                                                                03046000
DECODE_HALRAND: PROCEDURE(OP);                                                  03048000
                                                                                03050000
   DECLARE OP BIT(16);                                                          03052000
                                                                                03054000
   OP = OP + HALMAT_PTR;                                                        03056000
   TEMP_MAT = HALMAT(OP);                                                       03058000
   IF (TEMP_MAT & 1) ^= 1 THEN CALL ERRORS (CLASS_BI, 404,                      03060000
       ' '||CURR_HALMAT_BLOCK - 1||':'||OP);                                    03060010
   HALRAND_TAG2 = (TEMP_MAT & "F") | (SHR(TEMP_MAT, 27) & "10");                03064000
   PTR_TYPE(OP), HALRAND_QUALIFIER = SHR(TEMP_MAT, 4) & "F";                    03066000
   HALRAND_TAG1 = SHR(TEMP_MAT, 8) & "FF";                                      03068000
   HALRAND = SHR(TEMP_MAT, 16) & "7FFF";                                        03070000
   PTR(OP) = SHR(TEMP_MAT, 16) & "FFFF";                                        03072000
                                                                                03074000
CLOSE DECODE_HALRAND;                                                           03076000
                                                                                03078000
                                                                                03080000
         /* ROUTINE TO SET DEBUG SWITCHES */                                    03082000
                                                                                03084000
SET_DEBUG_SWITCH: PROCEDURE(SWITCH);                                            03086000
                                                                                03088000
   DECLARE                                                                      03090000
        SWITCH                         BIT(8),                                  03092000
        I                              BIT(16);                                 03094000
                                                                                03096000
   IF SWITCH = 128 THEN AUXMAT_REQUESTED = ^AUXMAT_REQUESTED;                   03098000
   IF SWITCH = 129 THEN PRETTY_PRINT_REQUESTED = ^PRETTY_PRINT_REQUESTED;       03100000
   IF SWITCH = 130 THEN STACK_DUMP = ^STACK_DUMP;                               03102000
   IF SWITCH = 131 THEN OPCODE_TRACE = ^OPCODE_TRACE;                           03104000
   IF SWITCH = 132 THEN TARGET_TRACE = ^TARGET_TRACE;                           03106000
   IF SWITCH = 133 THEN NOOSE_TRACE = ^NOOSE_TRACE;                             03108000
   IF SWITCH = 134 THEN TIME_EXIT = ^TIME_EXIT;                                 03110000
                                                                                03112000
   IF SWITCH = 135 THEN DO;   /* SHRUNKEN SYMBOL TABLE INDEX DUMP */            03114000
      IF ^HEADER_ISSUED THEN                                                    03116000
         CALL PRINT_PHASE_HEADER;                                               03118000
      OUTPUT(1) = '-' || BLANK;                                                 03120000
      DO FOR I = 1 TO MAX_REF_SYT_SIZE;                                         03122000
         OUTPUT = 'SYMBOL(' || #RJUST(SYT_EXPAND_INDEX(I), 5) || ') =' ||       03124000
            #RJUST(I, 5);                                                       03126000
      END;                                                                      03128000
   END;                                                                         03130000
                                                                                03132000
CLOSE SET_DEBUG_SWITCH;                                                         03134000
                                                                                03136000
                                                                                03138000
         /* ROUTINE TO COMPUTE THE NEXT USE VALUE */                            03140000
                                                                                03142000
COMPUTE_NOOSE: PROCEDURE(HALMAT#);                                              03144000
                                                                                03146000
   DECLARE HALMAT# BIT(16);                                                     03148000
                                                                                03150000
   RETURN HALMAT# + FRAME_BUMP_FACTOR(STACK_PTR);                               03152000
                                                                                03154000
CLOSE COMPUTE_NOOSE;                                                            03156000
                                                                                03158000
                                                                                03160000
         /* ROUTINE TO ADD A UVC TO CURRENT FRAME */                            03162000
                                                                                03164000
ADD_UVC: PROCEDURE(RAND_TYPE, RAND, HALMAT_LINE);                               03166000
                                                                                03168000
   DECLARE RAND_TYPE BIT(4), (RAND, HALMAT_LINE) BIT(16);                       03170000
   DECLARE (TEMP_CELL, TEMP_PTR) BIT(16);                                       03172000
                                                                                03174000
   TEMP_PTR = STACK_PTR;                                                        03176000
                                                                                03178000
   DO WHILE TRUE;   /* SEARCH FOR FRAME TO MARK UVCS */                         03180000
      IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN                                 03182000
         GO TO EXIT_SEARCH_LOOP;                                                03184000
      IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN                                  03186000
         GO TO EXIT_SEARCH_LOOP;                                                03188000
      TEMP_PTR = TEMP_PTR - 1;                                                  03190000
   END;                                                                         03192000
EXIT_SEARCH_LOOP:                                                               03194000
                                                                                03196000
   TEMP_CELL = GET_FREE_CELL;                                                   03198000
   CELL1(TEMP_CELL) = RAND;                                                     03200000
   CELL2(TEMP_CELL) = HALMAT_LINE;                                              03202000
   CELL1_FLAGS(TEMP_CELL) = RAND_TYPE & "3F";                                   03204000
   CDR_CELL(TEMP_CELL) = FRAME_UVCS(TEMP_PTR);                                  03206000
   FRAME_UVCS(TEMP_PTR) = TEMP_CELL;                                            03208000
                                                                                03210000
CLOSE ADD_UVC;                                                                  03212000
                                                                                03214000
                                                                                03216000
         /* ROUTINE TO SEARCH FOR A REFERENCE OF PARTICULAR VAC OR SYT          03218000
            IN A LIST */                                                        03220000
                                                                                03222000
SEARCH_FOR_REF: PROCEDURE(RAND_TYPE, RAND, LIST_HEAD, PATER);                   03224000
                                                                                03226000
   DECLARE RAND_TYPE BIT(4), (RAND, LIST_HEAD, PATER) BIT(16);                  03228000
                                                                                03230000
   REF_PTR1 = PATER;                                                            03232000
   REF_PTR2 = LIST_HEAD;                                                        03234000
                                                                                03236000
   DO WHILE TRUE;                                                               03238000
      IF REF_PTR2 = 0 THEN                                                      03240000
         RETURN;                                                                03242000
      IF (CELL1(REF_PTR2) = RAND) &                                             03244000
         ((CELL1_FLAGS(REF_PTR2) & "3F") = RAND_TYPE) THEN                      03246000
         RETURN;                                                                03248000
      REF_PTR1 = REF_PTR2;                                                      03250000
      REF_PTR2 = CDR_CELL(REF_PTR1);                                            03252000
   END;                                                                         03254000
                                                                                03256000
CLOSE SEARCH_FOR_REF;                                                           03258000
                                                                                03260000
                                                                                03262000
         /* ROUTINE TO DUMP A STACK IF NECESSARY */                             03264000
                                                                                03266000
DUMP_STACK: PROCEDURE;                                                          03268000
                                                                                03270000
                                                                                03272000
   OUTPUT = '';   OUTPUT = '';                                                  03274000
   OUTPUT = 'HALMAT_PTR = ' || HALMAT_PTR;                                      03276000
   OUTPUT = 'STACK_PTR = ' || STACK_PTR;                                        03278000
   OUTPUT = 'MAX_CASE_LENGTH = ' || MAX_CASE_LENGTH(STACK_PTR);                 03280000
   OUTPUT = 'FRAME_START = ' || FRAME_START(STACK_PTR);                         03282000
   OUTPUT = 'FRAME_TYPE = ' || FRAME_TYPE(STACK_PTR);                           03284000
   OUTPUT = 'FRAME_FLAGS = ' || FRAME_FLAGS(STACK_PTR);                         03286000
   OUTPUT = 'FRAME_INL = '|| FRAME_INL(STACK_PTR);                              03288000
   OUTPUT = 'FRAME_BUMP_FACTOR = ' || FRAME_BUMP_FACTOR(STACK_PTR);             03290000
   OUTPUT = 'FRAME_BLOCK_PTR = ' || FRAME_BLOCK_PTR(STACK_PTR);                 03292000
   OUTPUT = 'FRAME_CB_NEST_LEVEL = ' || FRAME_CB_NEST_LEVEL(STACK_PTR);         03293000
   CALL OUTPUT_SYT_MAP('FRAME_SYT_REF', FRAME_SYT_REF(STACK_PTR));              03294000
   CALL OUTPUT_VAC_MAP('FRAME_VAC_REF', FRAME_VAC_REF(STACK_PTR));              03296000
   CALL OUTPUT_SYT_MAP('FRAME_SYT_PREV_REF', FRAME_SYT_PREV_REF(STACK_PTR));    03298000
   CALL OUTPUT_VAC_MAP('FRAME_VAC_PREV_REF', FRAME_VAC_PREV_REF(STACK_PTR));    03300000
   CALL OUTPUT_LIST('FRAME_UVCS', FRAME_UVCS(STACK_PTR));                       03302000
   CALL OUTPUT_LIST('FRAME_CASE_LIST', AUXMAT1(FRAME_CASE_LIST(STACK_PTR)));    03304000
   CALL OUTPUT_LIST('FRAME_MAP_SAVE', FRAME_MAP_SAVE(STACK_PTR));               03306000
   CALL OUTPUT_LIST('CASE_LIST_PTRS', CASE_LIST_PTRS(STACK_PTR));               03308000
   CALL OUTPUT_LIST('VAC_BOUNDS =', VAC_BOUNDS(FRAME_BLOCK_PTR(STACK_PTR)));    03310000
                                                                                03312000
CLOSE DUMP_STACK;                                                               03314000
                                                                                03316000
                                                                                03318000
         /* ROUTINE TO ADD TO CSE SEARCH BOUNDARIES */                          03320000
                                                                                03322000
ADD_TO_VAC_BOUNDS: PROCEDURE(START, FINISH);                                    03324000
                                                                                03326000
   DECLARE                                                                      03328000
        START                          BIT(16),                                 03330000
        FINISH                         BIT(16),                                 03332000
        VAC_BOUNDS_PTR                 BIT(16),                                 03334000
        PREV_BOUNDS_PTR                BIT(16),                                 03336000
        TEMP_CELL                      LITERALLY 'PREV_BOUNDS_PTR';             03338000
                                                                                03340000
   VAC_BOUNDS_PTR = VAC_BOUNDS(FRAME_BLOCK_PTR(STACK_PTR));                     03342000
                                                                                03344000
   IF (VAC_BOUNDS_PTR = 0) | (CELL1(VAC_BOUNDS_PTR) < START) THEN DO;           03346000
      TEMP_CELL = GET_FREE_CELL;                                                03348000
      CELL1(TEMP_CELL) = START;                                                 03350000
      CELL2(TEMP_CELL) = FINISH;                                                03352000
      CDR_CELL(TEMP_CELL) = VAC_BOUNDS_PTR;                                     03354000
   END;                                                                         03356000
   ELSE DO;                                                                     03358000
      PREV_BOUNDS_PTR = VAC_BOUNDS_PTR;                                         03360000
      VAC_BOUNDS_PTR = CDR_CELL(VAC_BOUNDS_PTR);                                03362000
                                                                                03364000
      DO WHILE TRUE;                                                            03366000
                                                                                03368000
         IF (VAC_BOUNDS_PTR = 0) | (CELL1(VAC_BOUNDS_PTR) < START) THEN         03370000
            GO TO EXIT_SEARCH_BOUNDS;                                           03372000
         ELSE DO;                                                               03374000
            PREV_BOUNDS_PTR = VAC_BOUNDS_PTR;                                   03376000
            VAC_BOUNDS_PTR = CDR_CELL(VAC_BOUNDS_PTR);                          03378000
         END;                                                                   03380000
                                                                                03382000
      END;                                                                      03384000
   EXIT_SEARCH_BOUNDS:                                                          03386000
                                                                                03388000
      CELL1(PREV_BOUNDS_PTR) = START;                                           03390000
      CELL2(PREV_BOUNDS_PTR) = FINISH;                                          03392000
                                                                                03394000
   END;                                                                         03396000
                                                                                03398000
   VAC_BOUNDS(FRAME_BLOCK_PTR(STACK_PTR)) = PREV_BOUNDS_PTR;                    03400000
                                                                                03402000
CLOSE ADD_TO_VAC_BOUNDS;                                                        03404000
                                                                                03406000
                                                                                03408000
         /* ROUTINE TO SET NEXT USE */                                          03410000
                                                                                03412000
SET_RAND_NOOSE: PROCEDURE(RAND#, VAL_CHANGE, DO_NOT_DECODE);                    03414000
                                                                                03416000
   DECLARE RAND# BIT(16), VAL_CHANGE BIT(8), DO_NOT_DECODE BIT(8);              03418000
   DECLARE (BUMP_FACTOR, TEMP_NOOSE) BIT(16);                                   03420000
   DECLARE QUAL_CASE_DECODE(15) BIT(8) INITIAL(                                 03422000
      0, 1, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);                          03424000
                                                                                03426000
                                                                                03428000
                                                                                03430000
         /* ROUTINE TO RETURN MINIMUM NEXT USE VALUE */                         03432000
                                                                                03434000
RET_MIN_NOOSE: PROCEDURE(NOOSE1, NOOSE2) BIT(16);                               03436000
                                                                                03438000
   DECLARE (NOOSE1, NOOSE2) BIT(16);                                            03440000
                                                                                03442000
   IF NOOSE1 = 0 THEN                                                           03444000
      RETURN NOOSE2;                                                            03446000
   ELSE                                                                         03448000
      IF NOOSE2 = 0 THEN                                                        03450000
         RETURN NOOSE1;                                                         03452000
      ELSE                                                                      03454000
         IF NOOSE1 < NOOSE2 THEN                                                03456000
            RETURN NOOSE1;                                                      03458000
         ELSE                                                                   03460000
            RETURN NOOSE2;                                                      03462000
                                                                                03464000
CLOSE RET_MIN_NOOSE;                                                            03466000
                                                                                03468000
                                                                                03470000
         /* ROUTINE TO SET MINIMUM NEXT USE IN THE ARRAY "NOOSE' */             03472000
                                                                                03474000
SET_MIN_NOOSE: PROCEDURE(RAND_TYPE, RAND, HALMAT_LINE, NEXT_USE);               03476000
                                                                                03478000
   DECLARE                                                                      03480000
        RAND_TYPE                      BIT(8),                                  03482000
        RAND                           BIT(16),                                 03484000
        HALMAT_LINE                    BIT(16),                                 03486000
        NEXT_USE                       BIT(16);                                 03488000
                                                                                03490000
   IF GEN_CODE(HALMAT_LINE) = SNCS_OPCODE THEN DO;                              03492000
      IF (PTR_TYPE(HALMAT_LINE) ^= RAND_TYPE) |                                 03494000
         (PTR(HALMAT_LINE) ^= RAND) THEN DO;                                    03496000
         CELL1(AUXMAT1(HALMAT_LINE)) = RET_MIN_NOOSE(                           03498000
            CELL1(AUXMAT1(HALMAT_LINE)), NEXT_USE);                             03500000
         RETURN;                                                                03502000
      END;                                                                      03504000
   END;                                                                         03506000
   NOOSE(HALMAT_LINE) = RET_MIN_NOOSE(NOOSE(HALMAT_LINE), NEXT_USE);            03508000
                                                                                03510000
CLOSE SET_MIN_NOOSE;                                                            03512000
                                                                                03514000
                                                                                03516000
         /* ROUTINE TO CHECK IF AN INTERVENING CONTROLLED BRANCH EXISTS ON      03518000
            STACK BETWEEN TWO HALMAT LINES */                                   03520000
                                                                                03522000
INTERVENING_CB: PROCEDURE(START, FINISH) BIT(1);                                03524000
                                                                                03526000
   DECLARE (START, FINISH) BIT(16);                                             03528000
   DECLARE (TEMP_PTR1, TEMP_PTR2) BIT(16);                                      03530000
                                                                                03532000
   TEMP_PTR1, TEMP_PTR2 = STACK_PTR;                                            03534000
                                                                                03536000
   DO WHILE TRUE;   /* FIND FRAME IN WHICH FINISH IS CONTAINED */               03538000
      IF FRAME_START(TEMP_PTR1) <= FINISH THEN                                  03540000
         GO TO EXIT_FF_LOOP;                                                    03542000
      TEMP_PTR1 = TEMP_PTR1 - 1;                                                03544000
   END;                                                                         03546000
EXIT_FF_LOOP:                                                                   03548000
                                                                                03550000
   DO WHILE TRUE;                                                               03552000
      IF FRAME_START(TEMP_PTR2) <= START THEN                                   03554000
         GO TO EXIT_FS_LOOP;                                                    03556000
      TEMP_PTR2 = TEMP_PTR2 - 1;                                                03558000
   END;                                                                         03560000
EXIT_FS_LOOP:                                                                   03562000
                                                                                03564000
   IF TEMP_PTR1 = TEMP_PTR2 THEN                                                03566000
      RETURN FALSE;                                                             03568000
                                                                                03570000
   WORK1 = TEMP_PTR1;                                                           03572000
                                                                                03574000
   DO WHILE TRUE;                                                               03576000
      IF FRAME_TYPE(WORK1) = CASE_TYPE THEN RETURN TRUE;                        03578000
      IF FRAME_TYPE(WORK1) = BLOCK_TYPE THEN RETURN FALSE;                      03580000
      WORK1 = WORK1 - 1;                                                        03582000
      IF WORK1 = TEMP_PTR2 THEN RETURN FALSE;                                   03584000
   END;                                                                         03586000
                                                                                03588000
CLOSE INTERVENING_CB;                                                           03590000
                                                                                03592000
                                                                                03594000
         /* ROUTINE TO ENTER ENTRY OF CASE HEADER */                            03596000
                                                                                03598000
MARK_SYT_CASE: PROCEDURE(RAND, NEXT_USE);                                       03600000
                                                                                03602000
   DECLARE (RAND, NEXT_USE) BIT(16);                                            03604000
   DECLARE (TEMP_PTR, TEMP_CELL) BIT(16);                                       03606000
                                                                                03608000
   TEMP_PTR = STACK_PTR;                                                        03610000
                                                                                03612000
   DO WHILE TRUE;                                                               03614000
                                                                                03616000
      DO WHILE TRUE;                                                            03618000
         IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN                              03620000
            RETURN;                                                             03622000
         IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN DO;                           03624000
            IF (FRAME_FLAGS(TEMP_PTR) & (ZAP_OR_FLUSH | PREV_BLOCK_FLAG)) ^= 0  03626000
               THEN                                                             03628000
               RETURN;                                                          03630000
            GO TO EXIT_CASE_LOOP;                                               03634000
         END;                                                                   03636000
         TEMP_PTR = TEMP_PTR - 1;                                               03638000
      END;                                                                      03640000
                                                                                03642000
   EXIT_CASE_LOOP:                                                              03644000
      IF ((SYT_REF_POOL(FRAME_SYT_REF(TEMP_PTR) +                               03646000
                        SHR(SYT_SHRINK_INDEX(RAND), 5) ) &                      03648000
            MAP_INDICES(SYT_SHRINK_INDEX(RAND) & "1F")) = 0) &                  03650000
         ((SYT_REF_POOL(FRAME_SYT_PREV_REF(TEMP_PTR) +                          03652000
                        SHR(SYT_SHRINK_INDEX(RAND), 5) ) &                      03654000
            MAP_INDICES(SYT_SHRINK_INDEX(RAND) & "1F")) ^= 0) THEN DO;          03656000
         CALL SEARCH_FOR_REF(SYT, RAND, AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)), -1);03658000
         IF REF_PTR2 ^= 0 THEN                                                  03660000
            CELL2(REF_PTR2) = RET_MIN_NOOSE(CELL2(REF_PTR2), NEXT_USE);         03662000
         ELSE DO;                                                               03664000
            TEMP_CELL = GET_FREE_CELL;                                          03666000
            CELL1(TEMP_CELL) = RAND;                                            03668000
            CELL2(TEMP_CELL) = NEXT_USE;                                        03670000
            CELL1_FLAGS(TEMP_CELL) = SYT;                                       03672000
            CDR_CELL(TEMP_CELL) = AUXMAT1(FRAME_CASE_LIST(TEMP_PTR));           03674000
            AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)) = TEMP_CELL;                     03676000
         END;                                                                   03678000
      END;                                                                      03680000
      ELSE                                                                      03682000
         RETURN;                                                                03684000
      TEMP_PTR = TEMP_PTR - 1;                                                  03686000
                                                                                03688000
   END;                                                                         03690000
                                                                                03692000
CLOSE MARK_SYT_CASE;                                                            03694000
                                                                                03696000
                                                                                03698000
         /* ROUTINE TO MARK SYT_REFERENCES IN SYT_REF_POOL FRAME */             03700000
                                                                                03702000
MARK_SYT_REF: PROCEDURE(RAND);                                                  03704000
                                                                                03706000
   DECLARE RAND BIT(16);                                                        03708000
   DECLARE TEMP_PTR  BIT(16);                                                   03710000
                                                                                03712000
   IF (FRAME_FLAGS(STACK_PTR) & ZAP_OR_FLUSH) ^= 0 THEN                         03714000
      RETURN;                                                                   03716000
   IF (FRAME_FLAGS(STACK_PTR) & PREV_BLOCK_FLAG) ^= 0 THEN DO;                  03718000
      IF FRAME_SYT_REF(STACK_PTR) = 0 THEN                                      03720000
         FRAME_SYT_REF(STACK_PTR) = NEW_ZERO_SYT_REF_FRAME;                     03722000
   END;                                                                         03724000
   TEMP_PTR = FRAME_SYT_REF(STACK_PTR) + SHR(SYT_SHRINK_INDEX(RAND), 5);        03726000
   SYT_REF_POOL(TEMP_PTR) = SYT_REF_POOL(TEMP_PTR) |                            03728000
      MAP_INDICES(SYT_SHRINK_INDEX(RAND) & "1F");                               03730000
                                                                                03732000
CLOSE MARK_SYT_REF;                                                             03734000
                                                                                03736000
                                                                                03738000
         /* ROUTINE TO MARK NEXT USES OF SYTS */                                03740000
                                                                                03742000
MARK_SYT_UVCS: PROCEDURE(RAND, NEXT_USE);                                       03744000
                                                                                03746000
   DECLARE (RAND, NEXT_USE) BIT(16);                                            03748000
   DECLARE (TEMP_PTR, LAST_HEAD) BIT(16);                                       03750000
   DECLARE NO_MORE BIT(1);                                                      03752000
                                                                                03754000
   TEMP_PTR = STACK_PTR;                                                        03756000
   NO_MORE = OFF;                                                               03758000
                                                                                03760000
   DO WHILE TRUE;                                                               03762000
                                                                                03764000
      DO WHILE TRUE;                                                            03766000
         IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN DO;                          03768000
            NO_MORE = ON;                                                       03770000
            GO TO EXIT_CASE_LOOP;                                               03772000
         END;                                                                   03774000
         IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN DO;                           03776000
            IF (FRAME_FLAGS(TEMP_PTR) & ZAP_OR_FLUSH) ^= 0 THEN                 03778000
               NO_MORE = ON;                                                    03780000
            GO TO EXIT_CASE_LOOP;                                               03782000
         END;                                                                   03784000
         TEMP_PTR = TEMP_PTR - 1;                                               03786000
      END;                                                                      03788000
                                                                                03790000
   EXIT_CASE_LOOP:                                                              03792000
      CALL SEARCH_FOR_REF(SYT, RAND, FRAME_UVCS(TEMP_PTR), -1);                 03794000
      IF REF_PTR2 ^= 0 THEN DO;                                                 03796000
         IF CELL2(REF_PTR2) >= FRAME_START(STACK_PTR) THEN DO;                  03798000
         MARK_AND_DELETE:                                                       03800000
            DO WHILE TRUE;                                                      03802000
               CALL SET_MIN_NOOSE(SYT, RAND, CELL2(REF_PTR2), NEXT_USE);        03804000
               IF REF_PTR1 < 0 THEN DO;                                         03806000
                  FRAME_UVCS(TEMP_PTR) = CDR_CELL(REF_PTR2);                    03808000
                  LAST_HEAD = -1;                                               03810000
               END;                                                             03812000
               ELSE DO;                                                         03814000
                  CDR_CELL(REF_PTR1) = CDR_CELL(REF_PTR2);                      03816000
                  LAST_HEAD = REF_PTR1;                                         03818000
               END;                                                             03820000
               CALL SEARCH_FOR_REF(SYT, RAND, CDR_CELL(REF_PTR2), LAST_HEAD);   03822000
               IF REF_PTR2 = 0 THEN RETURN;                                     03824000
            END;                                                                03826000
         END;                                                                   03828000
         ELSE DO;                                                               03830000
            IF ^INTERVENING_CB(CELL2(REF_PTR2), FRAME_START(STACK_PTR)) THEN    03832000
               GO TO MARK_AND_DELETE;                                           03834000
            DO WHILE TRUE;                                                      03836000
               CALL SET_MIN_NOOSE(SYT, RAND, CELL2(REF_PTR2), NEXT_USE);        03838000
               CALL SEARCH_FOR_REF(SYT, RAND, CDR_CELL(REF_PTR2), -1);          03840000
               IF REF_PTR2 = 0 THEN RETURN;                                     03842000
            END;                                                                03844000
         END;                                                                   03846000
      END;                                                                      03848000
      IF NO_MORE THEN RETURN;                                                   03850000
      TEMP_PTR = TEMP_PTR - 1;                                                  03852000
   END;                                                                         03854000
                                                                                03856000
CLOSE MARK_SYT_UVCS;                                                            03858000
                                                                                03860000
                                                                                03862000
         /* ROUTINE TO ENTER AN ENTRY INTO CASE HEADER */                       03864000
                                                                                03866000
MARK_VAC_CASE: PROCEDURE(RAND_TYPE, RAND, NEXT_USE, BUMP_FACTOR, XB_FLAG);      03868000
                                                                                03870000
   DECLARE                                                                      03872000
        RAND_TYPE                      BIT(8),                                  03874000
        RAND                           BIT(16),                                 03876000
        NEXT_USE                       BIT(16),                                 03878000
        BUMP_FACTOR                    BIT(16),                                 03880000
        XB_FLAG                        BIT(1),                                  03882000
        TEMP_PTR                       BIT(16),                                 03884000
        TEMP_CELL                      BIT(16);                                 03886000
                                                                                03888000
   TEMP_PTR = STACK_PTR;                                                        03890000
                                                                                03892000
   DO WHILE TRUE;                                                               03894000
                                                                                03896000
      DO WHILE TRUE;                                                            03898000
         IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN RETURN;                      03900000
         IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN DO;                           03902000
            IF (FRAME_FLAGS(TEMP_PTR) & (ZAP_OR_FLUSH | PREV_BLOCK_FLAG)) ^= 0  03904000
               THEN                                                             03906000
               RETURN;                                                          03908000
            GO TO EXIT_CASE_LOOP;                                               03912000
         END;                                                                   03914000
         TEMP_PTR = TEMP_PTR - 1;                                               03916000
      END;                                                                      03918000
                                                                                03920000
   EXIT_CASE_LOOP:                                                              03922000
      IF ((VAC_REF_POOL(FRAME_VAC_REF(TEMP_PTR) + SHR(RAND + BUMP_FACTOR, 5)) & 03924000
         MAP_INDICES((RAND + BUMP_FACTOR) & "1F")) = 0) &                       03926000
         ((VAC_REF_POOL(FRAME_VAC_PREV_REF(TEMP_PTR) + SHR(RAND + BUMP_FACTOR,  03928000
         5)) &                                                                  03930000
         MAP_INDICES((RAND + BUMP_FACTOR) & "1F")) ^= 0) THEN DO;               03932000
         IF FRAME_CASE_LIST(TEMP_PTR) < HALMAT_SIZE THEN                        03934000
            CALL SEARCH_FOR_REF(RAND_TYPE, RAND,                                03934500
               AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)), -1 );                        03935000
         ELSE                                                                   03935500
            CALL SEARCH_FOR_REF(RAND_TYPE, RAND | SHL(XB_FLAG, 15),             03936000
               AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)), -1 );                        03936500
         IF REF_PTR2 ^= 0 THEN                                                  03938000
            CELL2(REF_PTR2) = RET_MIN_NOOSE(CELL2(REF_PTR2), NEXT_USE);         03940000
         ELSE DO;                                                               03942000
            TEMP_CELL = GET_FREE_CELL;                                          03944000
            IF FRAME_CASE_LIST(TEMP_PTR) < HALMAT_SIZE THEN                     03946000
               CELL1(TEMP_CELL) = RAND;                                         03946500
            ELSE                                                                03947000
               CELL1(TEMP_CELL) = RAND | SHL(XB_FLAG, 15);                      03947500
            CELL2(TEMP_CELL) = NEXT_USE;                                        03948000
            CELL1_FLAGS(TEMP_CELL) = RAND_TYPE;                                 03950000
            CDR_CELL(TEMP_CELL) = AUXMAT1(FRAME_CASE_LIST(TEMP_PTR));           03952000
            AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)) = TEMP_CELL;                     03954000
         END;                                                                   03956000
      END;                                                                      03958000
      ELSE RETURN;                                                              03960000
      TEMP_PTR = TEMP_PTR - 1;                                                  03962000
   END;                                                                         03964000
                                                                                03966000
CLOSE MARK_VAC_CASE;                                                            03968000
                                                                                03970000
                                                                                03972000
         /* ROUTINE TO MARK A REFERENCE IN VAC_REF_MAP */                       03974000
                                                                                03976000
MARK_VAC_REF: PROCEDURE(RAND);                                                  03978000
                                                                                03980000
   DECLARE RAND BIT(16);                                                        03982000
   DECLARE TEMP_PTR BIT(16);                                                    03984000
                                                                                03986000
   IF (FRAME_FLAGS(STACK_PTR) & ZAP_OR_FLUSH) ^= 0 THEN                         03988000
      RETURN;                                                                   03990000
   IF (FRAME_FLAGS(STACK_PTR) & PREV_BLOCK_FLAG) ^= 0 THEN DO;                  03992000
      IF FRAME_VAC_REF(STACK_PTR) = 0 THEN                                      03994000
         FRAME_VAC_REF(STACK_PTR) = NEW_ZERO_VAC_REF_FRAME;                     03996000
   END;                                                                         03998000
   TEMP_PTR = FRAME_VAC_REF(STACK_PTR) + SHR(RAND, 5);                          04000000
   VAC_REF_POOL(TEMP_PTR) = VAC_REF_POOL(TEMP_PTR) | MAP_INDICES(RAND & "1F");  04002000
                                                                                04004000
CLOSE MARK_VAC_REF;                                                             04006000
                                                                                04008000
                                                                                04010000
         /* ROUTINE TO MARK NEXT USES OF VACS */                                04012000
                                                                                04014000
MARK_VAC_UVCS: PROCEDURE(RAND_TYPE, RAND, NEXT_USE);                            04016000
                                                                                04018000
   DECLARE                                                                      04020000
        RAND_TYPE                      BIT(8),                                  04022000
        RAND                           BIT(16),                                 04024000
        NEXT_USE                       BIT(16),                                 04026000
        TEMP_PTR                       BIT(16),                                 04028000
        LAST_HEAD                      BIT(16),                                 04030000
        NO_MORE                        BIT(1);                                  04032000
                                                                                04034000
   TEMP_PTR = STACK_PTR;                                                        04036000
   NO_MORE = OFF;                                                               04038000
                                                                                04040000
   DO WHILE TRUE;                                                               04042000
                                                                                04044000
      DO WHILE TRUE;   /* SEARCH UNTIL CASE FRAME OR BLOCK TYPE */              04046000
         IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN DO;                          04048000
            NO_MORE = ON;                                                       04050000
            GO TO EXIT_CASE_LOOP;                                               04052000
         END;                                                                   04054000
         IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN DO;                           04056000
            IF (FRAME_FLAGS(TEMP_PTR) & ZAP_OR_FLUSH) ^= 0 THEN                 04058000
               NO_MORE = ON;                                                    04060000
            GO TO EXIT_CASE_LOOP;                                               04062000
         END;                                                                   04064000
         TEMP_PTR = TEMP_PTR - 1;                                               04066000
      END;                                                                      04068000
                                                                                04070000
   EXIT_CASE_LOOP:                                                              04072000
      CALL SEARCH_FOR_REF(RAND_TYPE, RAND, FRAME_UVCS(TEMP_PTR), -1);           04074000
      IF REF_PTR2 ^= 0 THEN DO;                                                 04076000
         IF CELL2(REF_PTR2) >= FRAME_START(STACK_PTR) THEN DO;                  04078000
         MARK_AND_DELETE:                                                       04080000
            DO WHILE TRUE;                                                      04082000
               CALL SET_MIN_NOOSE(RAND_TYPE, RAND, CELL2(REF_PTR2), NEXT_USE);  04084000
               IF REF_PTR1 < 0 THEN DO;                                         04086000
                  FRAME_UVCS(TEMP_PTR) = CDR_CELL(REF_PTR2);                    04088000
                  LAST_HEAD = -1;                                               04090000
               END;                                                             04092000
               ELSE DO;                                                         04094000
                  CDR_CELL(REF_PTR1) = CDR_CELL(REF_PTR2);                      04096000
                  LAST_HEAD = REF_PTR1;                                         04098000
               END;                                                             04100000
               CALL SEARCH_FOR_REF(RAND_TYPE, RAND, CDR_CELL(REF_PTR2),         04102000
                  LAST_HEAD);                                                   04104000
               IF REF_PTR2 = 0 THEN RETURN;                                     04106000
            END;                                                                04108000
         END;                                                                   04110000
         ELSE DO;                                                               04112000
            IF ^INTERVENING_CB(CELL2(REF_PTR2), FRAME_START(STACK_PTR)) THEN    04114000
               GO TO MARK_AND_DELETE;                                           04116000
            DO WHILE TRUE;                                                      04118000
               CALL SET_MIN_NOOSE(RAND_TYPE, RAND, CELL2(REF_PTR2), NEXT_USE);  04120000
               CALL SEARCH_FOR_REF(RAND_TYPE, RAND, CDR_CELL(REF_PTR2), -1);    04122000
               IF REF_PTR2 = 0 THEN RETURN;                                     04124000
            END;                                                                04126000
         END;                                                                   04128000
      END;                                                                      04130000
      IF NO_MORE THEN RETURN;                                                   04132000
      TEMP_PTR = TEMP_PTR - 1;                                                  04134000
   END;                                                                         04136000
                                                                                04138000
CLOSE MARK_VAC_UVCS;                                                            04140000
                                                                                04142000
                                                                                04144000
         /* ROUTINE TO MARK CASE LISTS FOR REFERENCES BEYOND CB'S */            04146000
                                                                                04148000
MARK_CASE_LIST_PTRS: PROCEDURE(RAND_TYPE, RAND);                                04150000
                                                                                04152000
   DECLARE                                                                      04154000
        RAND_TYPE                      BIT(8),                                  04156000
        RAND                           BIT(16),                                 04158000
        TEMP_PTR                       BIT(16),                                 04160000
        TEMP_PTR1                      BIT(16),                                 04162000
        NO_MORE                        BIT(1);                                  04164000
                                                                                04166000
   TEMP_PTR = STACK_PTR;                                                        04168000
   NO_MORE = OFF;                                                               04170000
                                                                                04172000
   DO WHILE TRUE;                                                               04174000
                                                                                04176000
      DO WHILE TRUE;                                                            04178000
         IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN DO;                          04180000
            NO_MORE = ON;                                                       04182000
            GO TO EXIT_CASE_LOOP;                                               04184000
         END;                                                                   04186000
         IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN                               04188000
            GO TO EXIT_CASE_LOOP;                                               04190000
         TEMP_PTR = TEMP_PTR - 1;                                               04192000
      END;                                                                      04194000
   EXIT_CASE_LOOP:                                                              04196000
                                                                                04198000
      IF CASE_LIST_PTRS(TEMP_PTR) ^= 0 THEN DO;                                 04200000
         TEMP_PTR1 = CASE_LIST_PTRS(TEMP_PTR);                                  04202000
                                                                                04204000
         DO WHILE TRUE;                                                         04206000
            REF_PTR2 = AUXMAT1(CELL1(TEMP_PTR1));                               04208000
                                                                                04210000
            DO WHILE TRUE;                                                      04212000
               IF (RAND < 0) & (CELL1(TEMP_PTR1) < HALMAT_SIZE) THEN            04214000
                  CALL SEARCH_FOR_REF(RAND_TYPE, RAND & "7FFF", REF_PTR2, -1);  04214500
               ELSE                                                             04215000
                  CALL SEARCH_FOR_REF(RAND_TYPE, RAND, REF_PTR2, -1);           04215500
               IF REF_PTR2 = 0 THEN                                             04216000
                  GO TO EXIT_LIST_MARK;                                         04218000
               ELSE                                                             04220000
                  CELL2_FLAGS(REF_PTR2) = CELL2_FLAGS(REF_PTR2) |               04222000
                     BEYOND_CONDITIONAL_FLAG;                                   04224000
               REF_PTR2 = CDR_CELL(REF_PTR2);                                   04226000
            END;                                                                04228000
         EXIT_LIST_MARK:                                                        04230000
                                                                                04232000
            TEMP_PTR1 = CDR_CELL(TEMP_PTR1);                                    04234000
            IF TEMP_PTR1 = 0 THEN                                               04236000
               GO TO EXIT_LIST_LOOP;                                            04238000
         END;                                                                   04240000
      EXIT_LIST_LOOP:                                                           04242000
      END;                                                                      04244000
                                                                                04246000
      IF NO_MORE THEN                                                           04248000
         RETURN;                                                                04250000
      TEMP_PTR = TEMP_PTR - 1;   /* POINT TO PREVIOUS STACK LEVEL */            04252000
                                                                                04254000
   END;                                                                         04256000
                                                                                04258000
CLOSE MARK_CASE_LIST_PTRS;                                                      04260000
                                                                                04262000
                                                                                04264000
         /* MAIN BODY OF SET_RAND_NOOSE */                                      04266000
                                                                                04268000
   IF ^DO_NOT_DECODE THEN CALL DECODE_HALRAND(RAND#);                           04270000
   RAND# = RAND# + HALMAT_PTR;                                                  04272000
   DO CASE QUAL_CASE_DECODE(HALRAND_QUALIFIER);                                 04274000
                                                                                04276000
      ;   /* DO NOTHING */                                                      04278000
                                                                                04280000
      IF SYT_SHRINK_INDEX(HALRAND) ^= 0 THEN DO;   /* QUALIFIER IS SYT */       04282000
         IF GEN_CODE(RAND#) = 0 THEN                                            04284000
            GEN_CODE(RAND#) = NOOSE_OPCODE;                                     04286000
         IF ^VAL_CHANGE THEN TEMP_NOOSE = COMPUTE_NOOSE(RAND#);                 04288000
         ELSE TEMP_NOOSE = 0;                                                   04290000
         CALL MARK_SYT_CASE(HALRAND,TEMP_NOOSE);                                04292000
         CALL MARK_SYT_REF(HALRAND);                                            04294000
         CALL MARK_SYT_UVCS(HALRAND, TEMP_NOOSE);                               04296000
         CALL ADD_UVC(SYT, HALRAND, RAND#);                                     04298000
      END;                                                                      04300000
                                                                                04302000
      DO;   /* QUALIFIER IS VAC OR XPT */                                       04304000
         /* SAME ACTION AS LAST CASE BUT MARK IN AUXMAT1                        04306000
            IF VAC USED MORE THAN ONCE */                                       04308000
         IF (RAND# >= HALMAT_SIZE) & (HALRAND_TAG2 & RAND_XB_FLAG) = 0 THEN     04310000
            BUMP_FACTOR = HALMAT_SIZE;                                          04312000
         ELSE                                                                   04314000
            BUMP_FACTOR = 0;                                                    04316000
         TEMP_NOOSE = COMPUTE_NOOSE(RAND#);                                     04318000
         IF GEN_CODE(RAND#) = 0 THEN                                            04320000
            GEN_CODE(RAND#) = NOOSE_OPCODE;                                     04322000
         CALL MARK_VAC_CASE(HALRAND_QUALIFIER, HALRAND, TEMP_NOOSE, BUMP_FACTOR,04324000
            SHR(HALRAND_TAG2 & RAND_XB_FLAG, 4));                               04326000
         CALL MARK_VAC_REF(HALRAND + BUMP_FACTOR);                              04328000
         CALL MARK_VAC_UVCS(HALRAND_QUALIFIER, HALRAND + BUMP_FACTOR,           04330000
            TEMP_NOOSE);                                                        04332000
         IF (HALRAND_TAG2 & RAND_CSE_FLAG) ^= 0 THEN                            04334000
            CALL ADD_UVC(HALRAND_QUALIFIER, HALRAND + BUMP_FACTOR, RAND#);      04336000
         CALL MARK_CASE_LIST_PTRS(HALRAND_QUALIFIER, HALRAND |                  04338000
            SHL(HALRAND_TAG2 & RAND_XB_FLAG, 11));                              04340000
      END;                                                                      04342000
                                                                                04344000
   END;                                                                         04346000
                                                                                04348000
   DO_NOT_DECODE, VAL_CHANGE = 0;   /* RESET DEFAULTS */                        04350000
                                                                                04352000
CLOSE SET_RAND_NOOSE /* $S+ */ ;   /* $S@ */                                    04354000
                                                                                04356000
                                                                                04358000
         /* SET NEXT USES FOR ASSIGN HALMAT OPERATORS */                        04360000
                                                                                04362000
SET_ASN_NOOSE: PROCEDURE;                                                       04364000
                                                                                04366000
   CALL SET_RAND_NOOSE(1);                                                      04368000
   DO FOR NUMOP = 2 TO HALRATOR_#RANDS;                                         04370000
      CALL SET_RAND_NOOSE(NUMOP, 1);                                            04372000
   END;                                                                         04374000
                                                                                04376000
CLOSE SET_ASN_NOOSE;                                                            04378000
                                                                                04380000
                                                                                04382000
         /* SET NEXT USES FOR MOST CASES */                                     04384000
                                                                                04386000
SET_SIMP_NOOSE: PROCEDURE(START);                                               04388000
                                                                                04390000
   DECLARE START BIT(16);                                                       04392000
                                                                                04394000
   DO FOR NUMOP = START TO HALRATOR_#RANDS;                                     04396000
      CALL SET_RAND_NOOSE(NUMOP);                                               04398000
   END;                                                                         04400000
                                                                                04402000
CLOSE SET_SIMP_NOOSE;                                                           04404000
                                                                                04406000
                                                                                04406500
         /* ROUTINE TO FLUSH INFORMATION WHEN A FLUSHING OF INFORMATION         04407000
            IS REQUIRED. */                                                     04407500
                                                                                04408000
ZAPPER: PROCEDURE(ZAP_TYPE);                                                    04408500
                                                                                04409000
   DECLARE                                                                      04409500
        ZAP_TYPE                       BIT(8),                                  04410000
        TEMP_PTR                       BIT(16);                                 04410500
                                                                                04411000
   TEMP_PTR = STACK_PTR;                                                        04411500
                                                                                04412000
   DO WHILE TRUE;                                                               04412500
                                                                                04413000
      IF FRAME_TYPE(TEMP_PTR) = CB_TYPE THEN                                    04413500
         ;                                                                      04414000
      ELSE DO;                                                                  04414500
                                                                                04415000
         FRAME_UVCS(TEMP_PTR) = 0;                                              04415500
         CASE_LIST_PTRS(TEMP_PTR) = 0;                                          04416000
                                                                                04416500
         IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN                              04417000
            CALL ADD_TO_VAC_BOUNDS(FRAME_START(TEMP_PTR),                       04417500
               HALMAT_PTR + HALRATOR_#RANDS);                                   04418000
         ELSE                                                                   04418500
            FRAME_FLAGS(TEMP_PTR) = FRAME_FLAGS(TEMP_PTR) | ZAP_TYPE;           04419000
                                                                                04419500
         RETURN;                                                                04420000
      END;                                                                      04420500
                                                                                04421000
      TEMP_PTR = TEMP_PTR - 1;                                                  04421500
                                                                                04422000
   END;                                                                         04422500
                                                                                04423000
CLOSE ZAPPER;                                                                   04423500
                                                                                04424000
                                                                                04424500
                                                                                04430500
         /* ROUTINE TO FLUSH INFORMATION WHEN A FLUSHING OF INFORMATION         04431000
            OF A LOCAL NATURE IS REQUIRED.  THIS ROUTINE BASICALLY SETS A       04431500
            FLAG TO INDICATE A ZAP HAS BEEN PERFORMED FOR THIS FRAME BUT        04432000
            THAT THIS ZAP NEED NOT BE PASSED ALONG THE STACK */                 04432500
                                                                                04433000
FLUSH_INFO: PROCEDURE;                                                          04433500
                                                                                04434000
   CALL ZAPPER(FLUSH_FLAG);                                                     04434500
                                                                                04435000
CLOSE FLUSH_INFO;                                                               04435500
                                                                                04466000
                                                                                04468000
         /* ROUTINE TO HANDLE SIMPLE NEXT USES FOR CLASS2,                      04470000
            CLASS3, CLASS4, CLASS5, AND CLASS6 HALMAT OPERATORS */              04472000
                                                                                04474000
HANDLE_SIMP_NOOSE: PROCEDURE;                                                   04476000
                                                                                04478000
   PTR(HALMAT_PTR) = HALMAT_PTR MOD 1800;                                       04480000
   GEN_CODE(HALMAT_PTR) = NOOSE_OPCODE;                                         04482000
   PTR_TYPE(HALMAT_PTR) = VAC;                                                  04484000
   CALL ADD_UVC(VAC, HALMAT_PTR, HALMAT_PTR);                                   04486000
   CALL SET_SIMP_NOOSE(1);                                                      04488000
                                                                                04490000
CLOSE HANDLE_SIMP_NOOSE;                                                        04492000
                                                                                04494000
                                                                                04496000
         /* ROUTINE TO HANDLE SIMPLE NEXT USES FOR CLASS2,                      04498000
            CLASS3, CLASS4, CLASS5, AND CLASS6 HALMAT OPERATORS                 04500000
            AND TO SIFT OUT THEIR ASSIGN OPERATORS */                           04502000
                                                                                04504000
HANDLE_SIMP_OR_ASN_NOOSE: PROCEDURE;                                            04506000
                                                                                04508000
   IF HALRATOR = "01" THEN CALL SET_ASN_NOOSE;                                  04510000
      ELSE CALL HANDLE_SIMP_NOOSE;                                              04512000
                                                                                04514000
CLOSE HANDLE_SIMP_OR_ASN_NOOSE;                                                 04516000
                                                                                04518000
                                                                                04520000
         /* ROUTINE TO CRAP OUT WHEN STACK_FRAMES FAIL TO JIVE */               04522000
                                                                                04524000
STACK_ERROR: PROCEDURE(HALMAT_TYPE,FRM_TYPE,WHICH_FRAME);                       04526000
                                                                                04528000
   DECLARE (HALMAT_TYPE,WHICH_FRAME) CHARACTER, FRM_TYPE BIT(16);               04530000
                                                                                04532000
   CALL ERRORS (CLASS_BI, 405);                                                 04534000
                                                                                04540000
CLOSE STACK_ERROR;                                                              04542000
                                                                                04544000
                                                                                04546000
         /* ROUTINE TO PUSH A FRAME WHEN A CODE BLOCK HEADER IS                 04548000
            ENCOUNTERED */                                                      04550000
                                                                                04552000
PUSH_BLOCK_FRAME: PROCEDURE;                                                    04554000
                                                                                04556000
   IF STACK_DUMP THEN                                                           04558000
      CALL DUMP_STACK;                                                          04560000
                                                                                04562000
   CALL INCR_STACK_PTR;                                                         04564000
                                                                                04566000
   FRAME_BLOCK_PTR(STACK_PTR) = STACK_PTR;                                      04568000
   FRAME_START(STACK_PTR) = HALMAT_PTR;                                         04570000
   FRAME_TYPE(STACK_PTR) = BLOCK_TYPE;                                          04572000
   FRAME_FLAGS(STACK_PTR) = 0;                                                  04574000
   FRAME_UVCS(STACK_PTR) = 0;                                                   04576000
                                                                                04578000
   CALL DECODE_HALRAND(1);                                                      04580000
   FRAME_INL(STACK_PTR) = HALRAND;                                              04582000
                                                                                04584000
   FRAME_SYT_REF(STACK_PTR) = NEW_ZERO_SYT_REF_FRAME;                           04586000
   FRAME_VAC_REF(STACK_PTR) = NEW_ZERO_VAC_REF_FRAME;                           04588000
                                                                                04590000
   FRAME_SYT_PREV_REF(STACK_PTR) = 0;                                           04592000
   FRAME_VAC_PREV_REF(STACK_PTR) = 0;                                           04594000
                                                                                04596000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR - 1);             04598000
   FRAME_CASE_LIST(STACK_PTR) = 0;                                              04600000
   FRAME_MAP_SAVE(STACK_PTR) = 0;                                               04602000
   VAC_BOUNDS(STACK_PTR) = 0;                                                   04604000
   CASE_LIST_PTRS(STACK_PTR) = 0;                                               04606000
                                                                                04608000
   IF STACK_DUMP THEN                                                           04610000
      CALL DUMP_STACK;                                                          04612000
                                                                                04614000
CLOSE PUSH_BLOCK_FRAME;                                                         04616000
                                                                                04618000
                                                                                04620000
         /* ROUTINE TO POP A BLOCK TYPE FRAME */                                04622000
                                                                                04624000
POP_BLOCK_FRAME: PROCEDURE;                                                     04626000
                                                                                04628000
   IF STACK_DUMP THEN                                                           04636000
      CALL DUMP_STACK;                                                          04638000
                                                                                04640000
   CALL DECR_STACK_PTR;                                                         04642000
                                                                                04644000
   IF FRAME_TYPE(STACK_PTR + 1) ^= BLOCK_TYPE THEN                              04646000
      CALL STACK_ERROR('CLOS OR ICLOS', FRAME_TYPE(STACK_PTR + 1), CCURRENT);   04648000
                                                                                04650000
   CALL DECODE_HALRAND(1);                                                      04652000
   IF HALRAND ^= FRAME_INL(STACK_PTR + 1) THEN                                  04654000
      CALL ERRORS (CLASS_BI, 406);                                              04656000
                                                                                04658000
   CALL FREE_SYT_REF_FRAME(FRAME_SYT_REF(STACK_PTR + 1));                       04660000
   CALL FREE_VAC_REF_FRAME(FRAME_VAC_REF(STACK_PTR + 1));                       04662000
   CALL FREE_SYT_REF_FRAME(FRAME_SYT_PREV_REF(STACK_PTR + 1));                  04664000
   CALL FREE_VAC_REF_FRAME(FRAME_VAC_PREV_REF(STACK_PTR + 1));                  04666000
                                                                                04668000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR + 1);             04670000
                                                                                04672000
   CALL ADD_TO_VAC_BOUNDS(FRAME_START(STACK_PTR + 1),                           04674000
      HALMAT_PTR + HALRATOR_#RANDS);                                            04676000
                                                                                04678000
   IF STACK_DUMP THEN                                                           04680000
      CALL DUMP_STACK;                                                          04682000
                                                                                04684000
CLOSE POP_BLOCK_FRAME;                                                          04686000
                                                                                04688000
                                                                                04690000
         /* ROUTINE TO PUSH A CONTROLLED BRANCH FRAME ONTO THE STACK */         04692000
                                                                                04694000
PUSH_CB_FRAME: PROCEDURE;                                                       04696000
                                                                                04698000
   IF STACK_DUMP THEN CALL DUMP_STACK;                                          04700000
                                                                                04702000
   CALL INCR_STACK_PTR;                                                         04704000
                                                                                04706000
   FRAME_TYPE(STACK_PTR) = CB_TYPE;                                             04708000
   FRAME_FLAGS(STACK_PTR) = 0;                                                  04710000
   FRAME_START(STACK_PTR) = FRAME_START(STACK_PTR - 1);                         04712000
   FRAME_BLOCK_PTR(STACK_PTR) = FRAME_BLOCK_PTR(STACK_PTR - 1);                 04714000
   FRAME_UVCS(STACK_PTR) = 0;                                                   04716000
   FRAME_SYT_PREV_REF(STACK_PTR) = FRAME_SYT_PREV_REF(STACK_PTR - 1);           04718000
   FRAME_VAC_PREV_REF(STACK_PTR) = FRAME_VAC_PREV_REF(STACK_PTR - 1);           04720000
   FRAME_VAC_REF(STACK_PTR) = FRAME_VAC_REF(STACK_PTR - 1);                     04722000
   FRAME_SYT_REF(STACK_PTR) = FRAME_SYT_REF(STACK_PTR - 1);                     04724000
   FRAME_INL(STACK_PTR) = -1;                                                   04726000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR - 1);             04728000
   FRAME_CASE_LIST(STACK_PTR) = FRAME_CASE_LIST(STACK_PTR - 1);                 04730000
   FRAME_MAP_SAVE(STACK_PTR) = 0;                                               04732000
   CASE_LIST_PTRS(STACK_PTR) = 0;                                               04734000
                                                                                04736000
   IF STACK_DUMP THEN                                                           04738000
      CALL DUMP_STACK;                                                          04740000
                                                                                04742000
CLOSE PUSH_CB_FRAME;                                                            04744000
                                                                                04746000
                                                                                04748000
         /* ROUTINE TO POP CB FRAME OFF STACK */                                04750000
                                                                                04752000
POP_CB_FRAME: PROCEDURE;                                                        04754000
                                                                                04756000
   DECLARE                                                                      04758000
        VAC_FALSE_REF_PTR              LITERALLY 'VAC_REF_PTR',                 04760000
        VAC_TRUE_REF_PTR               LITERALLY 'SYT_REF_PTR',                 04762000
        TEMP_CELL                      BIT(16),                                 04764000
        TEMP_PTR1                      BIT(16),                                 04766000
        TEMP_PTR2                      BIT(16),                                 04768000
        TEMP_PTR3                      BIT(16),                                 04770000
        LAST_HEAD                      BIT(16),                                 04772000
        SYT_PREV_REF_PTR               BIT(16),                                 04774000
        VAC_PREV_REF_PTR               BIT(16),                                 04776000
        SYT_UNION_REF_PTR              BIT(16),                                 04778000
        VAC_UNION_REF_PTR              BIT(16),                                 04780000
        CASE_LIST_PTR                  BIT(16),                                 04782000
        SYT_REF_PTR                    BIT(16),                                 04784000
        VAC_REF_PTR                    BIT(16),                                 04786000
        WORK1                          FIXED,                                   04788000
        VAC_BOUNDS_PTR                 BIT(16),                                 04790000
        VAC_BOUNDS_START               BIT(16),                                 04792000
        VAC_BOUNDS_END                 BIT(16),                                 04794000
        MAP_INDEX                      BIT(16),                                 04796000
        PREV_MAP_INDEX                 BIT(16),                                 04798000
        WORK_MAP                       FIXED,                                   04800000
        VAC_INDEX                      BIT(16),                                 04802000
        VAC_REF                        BIT(16),                                 04804000
        GEN_ZERO_SYT                   BIT(1),                                  04806000
        GEN_ZERO_VAC                   BIT(1);                                  04808000
                                                                                04810000
   IF STACK_DUMP THEN                                                           04812000
      CALL DUMP_STACK;                                                          04814000
                                                                                04816000
   CALL DECR_STACK_PTR;                                                         04818000
                                                                                04820000
   GEN_ZERO_VAC, GEN_ZERO_SYT = OFF;                                            04822000
                                                                                04824000
   IF (FRAME_FLAGS(STACK_PTR) & PREV_BLOCK_FLAG) = 0 THEN                       04826000
      GEN_ZERO_SYT, GEN_ZERO_VAC = ON;                                          04828000
   ELSE DO;                                                                     04830000
      IF (FRAME_SYT_PREV_REF(STACK_PTR + 1) ^= 0) &                             04832000
         (FRAME_SYT_REF(STACK_PTR + 1) ^= 0) THEN                               04834000
         GEN_ZERO_SYT = ON;                                                     04836000
      IF (FRAME_VAC_PREV_REF(STACK_PTR + 1) ^= 0) &                             04838000
         (FRAME_VAC_REF(STACK_PTR + 1) ^= 0) THEN                               04840000
         GEN_ZERO_VAC = ON;                                                     04842000
   END;                                                                         04844000
                                                                                04846000
   SYT_PREV_REF_PTR = FRAME_SYT_PREV_REF(STACK_PTR + 1);                        04848000
   VAC_PREV_REF_PTR = FRAME_VAC_PREV_REF(STACK_PTR + 1);                        04850000
   SYT_UNION_REF_PTR = FRAME_SYT_REF(STACK_PTR + 1);                            04852000
   VAC_UNION_REF_PTR = FRAME_VAC_REF(STACK_PTR + 1);                            04854000
                                                                                04856000
   CALL ADD_TO_VAC_BOUNDS(FRAME_START(STACK_PTR + 1),                           04858000
      HALMAT_PTR + HALRATOR_#RANDS);                                            04860000
                                                                                04862000
   IF (FRAME_FLAGS(STACK_PTR + 1) & IF_THEN_ELSE_MASK) ^= 0 THEN DO;            04864000
                                                                                04866000
      /* GENERATE TRUE ONLY TAGS FOR REFERENCES IN IF THEN ELSE TYPE CB'S */    04868000
                                                                                04870000
      IF (FRAME_FLAGS(STACK_PTR + 1) & FALSE_CASE) ^= 0 THEN DO;                04872000
         VAC_FALSE_REF_PTR = CELL1(CDR_CELL(FRAME_MAP_SAVE(STACK_PTR + 1)));    04874000
         VAC_TRUE_REF_PTR = CELL1(CDR_CELL(CDR_CELL(CDR_CELL(FRAME_MAP_SAVE(    04876000
            STACK_PTR + 1)))));                                                 04878000
         CASE_LIST_PTR = CELL1(CDR_CELL(CDR_CELL(FRAME_MAP_SAVE(                04880000
            STACK_PTR + 1))));                                                  04882000
      END;                                                                      04884000
      ELSE DO;                                                                  04886000
         VAC_FALSE_REF_PTR = 0;                                                 04888000
         VAC_TRUE_REF_PTR = CELL1(CDR_CELL(FRAME_MAP_SAVE(STACK_PTR + 1)));     04890000
         CASE_LIST_PTR = CELL1(FRAME_MAP_SAVE(STACK_PTR + 1));                  04892000
      END;                                                                      04894000
                                                                                04896000
      VAC_BOUNDS_PTR = VAC_BOUNDS(FRAME_BLOCK_PTR(STACK_PTR));                  04898000
      IF VAC_BOUNDS_PTR = 0 THEN                                                04900000
         VAC_BOUNDS_START = FRAME_START(FRAME_BLOCK_PTR(STACK_PTR));            04902000
      ELSE                                                                      04904000
         VAC_BOUNDS_START = CELL2(VAC_BOUNDS_PTR);                              04906000
      VAC_BOUNDS_END = HALMAT_PTR;                                              04908000
                                                                                04910000
      DO WHILE TRUE;                                                            04912000
         PREV_MAP_INDEX = -1;                                                   04914000
                                                                                04916000
         DO FOR VAC_REF = VAC_BOUNDS_START + 1 TO VAC_BOUNDS_END - 1;           04918000
            MAP_INDEX = SHR(VAC_REF, 5);                                        04920000
            IF MAP_INDEX ^= PREV_MAP_INDEX THEN DO;                             04922000
               PREV_MAP_INDEX = MAP_INDEX;                                      04924000
               WORK_MAP =                                                       04926000
                  VAC_REF_POOL(VAC_PREV_REF_PTR + MAP_INDEX) &                  04928000
                  VAC_REF_POOL(VAC_TRUE_REF_PTR + MAP_INDEX) &                  04930000
                  (^VAC_REF_POOL(VAC_FALSE_REF_PTR + MAP_INDEX));               04932000
            END;                                                                04934000
            VAC_INDEX = VAC_REF & "1F";                                         04936000
            IF (MAP_INDICES(VAC_INDEX) & WORK_MAP) ^= 0 THEN DO;                04938000
               IF (VAC_REF < 1800) & (HALMAT_PTR >= 1800) THEN DO;              04940000
                  REF_PTR2 = AUXMAT1(CASE_LIST_PTR);                            04942000
                  DO WHILE TRUE;                                                04944000
                     CALL SEARCH_FOR_REF(PTR_TYPE(VAC_REF), VAC_REF | "8000",   04946000
                        REF_PTR2, -1);                                          04948000
                     IF REF_PTR2 = 0 THEN                                       04950000
                        GO TO EXIT_MARK_CROSSES;                                04952000
                     CELL2_FLAGS(REF_PTR2) = CELL2_FLAGS(REF_PTR2) |            04954000
                        TRUE_ONLY_FLAG;                                         04956000
                     REF_PTR2 = CDR_CELL(REF_PTR2);                             04958000
                  END;                                                          04960000
               END;                                                             04962000
            EXIT_MARK_CROSSES:                                                  04964000
               REF_PTR2 = AUXMAT1(CASE_LIST_PTR);                               04966000
               DO WHILE TRUE;                                                   04968000
                  CALL SEARCH_FOR_REF(PTR_TYPE(VAC_REF), VAC_REF MOD 1800,      04970000
                     REF_PTR2, -1);                                             04972000
                  IF REF_PTR2 = 0 THEN                                          04974000
                     GO TO EXIT_MARK_LOOP;                                      04976000
                  CELL2_FLAGS(REF_PTR2) = CELL2_FLAGS(REF_PTR2) |               04978000
                     TRUE_ONLY_FLAG;                                            04980000
                  REF_PTR2 = CDR_CELL(REF_PTR2);                                04982000
               END;                                                             04984000
            EXIT_MARK_LOOP:                                                     04986000
            END;                                                                04988000
         END;                                                                   04990000
                                                                                04992000
         IF VAC_BOUNDS_PTR = 0 THEN                                             04994000
            GO TO EXIT_GEN_TRUE_ONLY;                                           04996000
         IF CDR_CELL(VAC_BOUNDS_PTR) = 0 THEN DO;                               04998000
            VAC_BOUNDS_END = CELL1(VAC_BOUNDS_PTR);                             05000000
            VAC_BOUNDS_PTR = 0;                                                 05002000
            VAC_BOUNDS_START = FRAME_START(FRAME_BLOCK_PTR(STACK_PTR));         05004000
         END;                                                                   05006000
         ELSE DO;                                                               05008000
            VAC_BOUNDS_END = CELL1(VAC_BOUNDS_PTR);                             05010000
            VAC_BOUNDS_PTR = CDR_CELL(VAC_BOUNDS_PTR);                          05012000
            VAC_BOUNDS_START = CELL2(VAC_BOUNDS_PTR);                           05014000
         END;                                                                   05016000
                                                                                05018000
      END;                                                                      05020000
                                                                                05022000
   END;                                                                         05024000
EXIT_GEN_TRUE_ONLY:                                                             05026000
                                                                                05028000
   DO WHILE TRUE;   /* GENERATE APPROPRIATE ZERO NEXT USES FOR CASES */         05030000
                                                                                05032000
      IF (CELL1(FRAME_MAP_SAVE(STACK_PTR + 1)) = -1) |                          05034000
         (CDR_CELL(FRAME_MAP_SAVE(STACK_PTR + 1)) = 0) THEN                     05036000
         GO TO EXIT_GEN_LOOP;                                                   05038000
                                                                                05040000
      CASE_LIST_PTR = CELL1(FRAME_MAP_SAVE(STACK_PTR + 1));                     05042000
      SYT_REF_PTR = CELL2(FRAME_MAP_SAVE(STACK_PTR + 1));                       05044000
      VAC_REF_PTR = CELL1(CDR_CELL(FRAME_MAP_SAVE(STACK_PTR + 1)));             05046000
                                                                                05048000
      IF GEN_ZERO_SYT THEN DO;                                                  05050000
         DO FOR TEMP_PTR1 = 0 TO SYT_REF_POOL_FRAME_SIZE;                       05052000
            WORK1 = SYT_REF_POOL(SYT_UNION_REF_PTR + TEMP_PTR1) &               05054000
               SYT_REF_POOL(SYT_PREV_REF_PTR + TEMP_PTR1) &                     05056000
               (^SYT_REF_POOL(SYT_REF_PTR + TEMP_PTR1));                        05058000
            DO FOR TEMP_PTR2 = 0 TO 31;                                         05060000
               TEMP_PTR3 = SYT_EXPAND_INDEX(SHL(TEMP_PTR1, 5) | TEMP_PTR2);     05062000
               IF (WORK1 & MAP_INDICES(TEMP_PTR2)) ^= 0 THEN DO;                05064000
                  TEMP_CELL = GET_FREE_CELL;                                    05066000
                  CELL1(TEMP_CELL) = TEMP_PTR3;                                 05068000
                  CELL1_FLAGS(TEMP_CELL) = SYT;                                 05070000
                  CDR_CELL(TEMP_CELL) = AUXMAT1(CASE_LIST_PTR);                 05072000
                  AUXMAT1(CASE_LIST_PTR) = TEMP_CELL;                           05074000
               END;                                                             05076000
               IF (SHL(TEMP_PTR1, 5) | TEMP_PTR2) > MAX_REF_SYT_SIZE THEN       05078000
                  GO TO EXIT_GZS;                                               05080000
            END;                                                                05082000
         END;                                                                   05084000
      END;                                                                      05086000
   EXIT_GZS:                                                                    05088000
                                                                                05090000
      IF GEN_ZERO_VAC THEN DO;                                                  05092000
                                                                                05094000
         VAC_BOUNDS_PTR = VAC_BOUNDS(FRAME_BLOCK_PTR(STACK_PTR));               05096000
         IF VAC_BOUNDS_PTR = 0 THEN                                             05098000
            VAC_BOUNDS_START = FRAME_START(FRAME_BLOCK_PTR(STACK_PTR));         05100000
         ELSE                                                                   05102000
            VAC_BOUNDS_START = CELL2(VAC_BOUNDS_PTR);                           05104000
         VAC_BOUNDS_END = HALMAT_PTR;                                           05106000
                                                                                05108000
         DO WHILE TRUE;                                                         05110000
            PREV_MAP_INDEX = -1;                                                05112000
                                                                                05114000
            DO FOR VAC_REF = VAC_BOUNDS_START + 1 TO VAC_BOUNDS_END - 1;        05116000
               MAP_INDEX = SHR(VAC_REF, 5);                                     05118000
               IF MAP_INDEX ^= PREV_MAP_INDEX THEN DO;                          05120000
                  PREV_MAP_INDEX = MAP_INDEX;                                   05122000
                  WORK_MAP =                                                    05124000
                     VAC_REF_POOL(VAC_UNION_REF_PTR + MAP_INDEX) &              05126000
                     VAC_REF_POOL(VAC_PREV_REF_PTR + MAP_INDEX) &               05128000
                     (^VAC_REF_POOL(VAC_REF_PTR + MAP_INDEX));                  05130000
               END;                                                             05132000
               VAC_INDEX = VAC_REF & "1F";                                      05134000
               IF (MAP_INDICES(VAC_INDEX) & WORK_MAP) ^= 0 THEN DO;             05136000
                  TEMP_CELL = GET_FREE_CELL;                                    05138000
                  CELL1(TEMP_CELL) = VAC_REF MOD 1800;                          05140000
                  IF (VAC_REF < 1800) & (CASE_LIST_PTR >= 1800) THEN            05142000
                     CELL1(TEMP_CELL) = CELL1(TEMP_CELL) | "8000";              05144000
                  CELL1_FLAGS(TEMP_CELL) = PTR_TYPE(VAC_REF);                   05146000
                  CDR_CELL(TEMP_CELL) = AUXMAT1(CASE_LIST_PTR);                 05148000
                  AUXMAT1(CASE_LIST_PTR) = TEMP_CELL;                           05150000
               END;                                                             05152000
            END;                                                                05154000
                                                                                05156000
            IF VAC_BOUNDS_PTR = 0 THEN                                          05158000
               GO TO EXIT_GZV;                                                  05160000
            IF CDR_CELL(VAC_BOUNDS_PTR) = 0 THEN DO;                            05162000
               VAC_BOUNDS_END = CELL1(VAC_BOUNDS_PTR);                          05164000
               VAC_BOUNDS_PTR = 0;                                              05166000
               VAC_BOUNDS_START = FRAME_START(FRAME_BLOCK_PTR(STACK_PTR));      05168000
            END;                                                                05170000
            ELSE DO;                                                            05172000
               VAC_BOUNDS_END = CELL1(VAC_BOUNDS_PTR);                          05174000
               VAC_BOUNDS_PTR = CDR_CELL(VAC_BOUNDS_PTR);                       05176000
               VAC_BOUNDS_START = CELL2(VAC_BOUNDS_PTR);                        05178000
            END;                                                                05180000
         END;                                                                   05182000
                                                                                05184000
      END;                                                                      05186000
   EXIT_GZV:                                                                    05188000
                                                                                05190000
      CALL FREE_VAC_REF_FRAME(VAC_REF_PTR);                                     05192000
      CALL FREE_SYT_REF_FRAME(SYT_REF_PTR);                                     05194000
      FRAME_MAP_SAVE(STACK_PTR + 1) =                                           05196000
         CDR_CELL(CDR_CELL(FRAME_MAP_SAVE(STACK_PTR + 1)));                     05198000
   END;                                                                         05200000
                                                                                05202000
EXIT_GEN_LOOP:                                                                  05204000
   FRAME_MAP_SAVE(STACK_PTR + 1) = 0;                                           05206000
                                                                                05208000
   TEMP_PTR1 = STACK_PTR;                                                       05210000
                                                                                05212000
   DO WHILE TRUE;   /* SEARCH FOR LAST CASE OR BLOCK FRAME */                   05214000
      IF FRAME_TYPE(TEMP_PTR1) = CASE_TYPE THEN                                 05216000
         GO TO EXIT_SEARCH_LOOP;                                                05218000
      IF FRAME_TYPE(TEMP_PTR1) = BLOCK_TYPE THEN                                05220000
         GO TO EXIT_SEARCH_LOOP;                                                05222000
      TEMP_PTR1 = TEMP_PTR1 - 1;                                                05224000
   END;                                                                         05226000
EXIT_SEARCH_LOOP:                                                               05228000
                                                                                05230000
   DO FOR TEMP_PTR2 = 0 TO SYT_REF_POOL_FRAME_SIZE;                             05232000
      WORK1 = SYT_REF_POOL(FRAME_SYT_REF(STACK_PTR + 1) + TEMP_PTR2);           05234000
      DO FOR TEMP_PTR3 = 0 TO 31;                                               05236000
         TEMP_CELL = SYT_EXPAND_INDEX(SHL(TEMP_PTR2, 5) | TEMP_PTR3);           05238000
         IF (MAP_INDICES(TEMP_PTR3) & WORK1) ^= 0 THEN DO;                      05240000
            CALL SEARCH_FOR_REF(SYT, TEMP_CELL, FRAME_UVCS(TEMP_PTR1), -1);     05242000
            DO WHILE TRUE;                                                      05244000
               IF REF_PTR2 ^= 0 THEN DO;                                        05246000
                  IF REF_PTR1 < 0 THEN DO;                                      05248000
                     FRAME_UVCS(TEMP_PTR1) = CDR_CELL(REF_PTR2);                05250000
                     LAST_HEAD = -1;                                            05252000
                  END;                                                          05254000
                  ELSE DO;                                                      05256000
                     CDR_CELL(REF_PTR1) = CDR_CELL(REF_PTR2);                   05258000
                     LAST_HEAD = REF_PTR1;                                      05260000
                  END;                                                          05262000
               END;                                                             05264000
               ELSE                                                             05266000
                  GO TO EXIT_DEL_SYT;                                           05268000
               CALL SEARCH_FOR_REF(SYT, TEMP_CELL, CDR_CELL(REF_PTR2),          05270000
                  LAST_HEAD);                                                   05272000
            END;                                                                05274000
      EXIT_DEL_SYT:                                                             05276000
         END;                                                                   05278000
         IF (SHL(TEMP_PTR2, 5) | TEMP_PTR3) > MAX_REF_SYT_SIZE THEN             05280000
            GO TO EXIT_SYT_DEL;                                                 05282000
      END;                                                                      05284000
   END;                                                                         05286000
EXIT_SYT_DEL:                                                                   05288000
                                                                                05290000
   VAC_BOUNDS_PTR = VAC_BOUNDS(FRAME_BLOCK_PTR(STACK_PTR));                     05292000
   IF VAC_BOUNDS_PTR = 0 THEN                                                   05294000
      VAC_BOUNDS_START = FRAME_START(FRAME_BLOCK_PTR(STACK_PTR));               05296000
   ELSE                                                                         05298000
      VAC_BOUNDS_START = CELL2(VAC_BOUNDS_PTR);                                 05300000
   VAC_BOUNDS_END = HALMAT_PTR;                                                 05302000
                                                                                05304000
   DO WHILE TRUE;                                                               05306000
      PREV_MAP_INDEX = -1;                                                      05308000
                                                                                05310000
      DO FOR VAC_REF = VAC_BOUNDS_START + 1 TO VAC_BOUNDS_END - 1;              05312000
         MAP_INDEX = SHR(VAC_REF, 5);                                           05314000
         IF MAP_INDEX ^= PREV_MAP_INDEX THEN DO;                                05316000
            PREV_MAP_INDEX = MAP_INDEX;                                         05318000
            WORK_MAP = VAC_REF_POOL(FRAME_VAC_REF(STACK_PTR + 1) + MAP_INDEX);  05320000
         END;                                                                   05322000
         VAC_INDEX = VAC_REF & "1F";                                            05324000
         IF (MAP_INDICES(VAC_INDEX) & WORK_MAP) ^= 0 THEN DO;                   05326000
            CALL SEARCH_FOR_REF(PTR_TYPE(VAC_REF), VAC_REF,                     05328000
               FRAME_UVCS(TEMP_PTR1), -1);                                      05330000
            DO WHILE TRUE;                                                      05332000
               IF REF_PTR2 ^= 0 THEN DO;                                        05334000
                  IF REF_PTR1 < 0 THEN DO;                                      05336000
                     FRAME_UVCS(TEMP_PTR1) = CDR_CELL(REF_PTR2);                05338000
                     LAST_HEAD = -1;                                            05340000
                  END;                                                          05342000
                  ELSE DO;                                                      05344000
                     CDR_CELL(REF_PTR1) = CDR_CELL(REF_PTR2);                   05346000
                     LAST_HEAD = REF_PTR1;                                      05348000
                  END;                                                          05350000
               END;                                                             05352000
               ELSE                                                             05354000
                  GO TO EXIT_DEL_VAC;                                           05356000
               CALL SEARCH_FOR_REF(VAC, VAC_REF, CDR_CELL(REF_PTR2), LAST_HEAD);05358000
            END;                                                                05360000
         EXIT_DEL_VAC:                                                          05362000
         END;                                                                   05364000
      END;                                                                      05366000
                                                                                05368000
      IF VAC_BOUNDS_PTR = 0 THEN                                                05370000
         GO TO EXIT_VAC_DEL;                                                    05372000
      IF CDR_CELL(VAC_BOUNDS_PTR) = 0 THEN DO;                                  05374000
         VAC_BOUNDS_END = CELL1(VAC_BOUNDS_PTR);                                05376000
         VAC_BOUNDS_PTR = 0;                                                    05378000
         VAC_BOUNDS_START = FRAME_START(FRAME_BLOCK_PTR(STACK_PTR));            05380000
      END;                                                                      05382000
      ELSE DO;                                                                  05384000
         VAC_BOUNDS_END = CELL1(VAC_BOUNDS_PTR);                                05386000
         VAC_BOUNDS_PTR = CDR_CELL(VAC_BOUNDS_PTR);                             05388000
         VAC_BOUNDS_START = CELL2(VAC_BOUNDS_PTR);                              05390000
      END;                                                                      05392000
                                                                                05394000
   END;                                                                         05396000
EXIT_VAC_DEL:                                                                   05398000
                                                                                05400000
   FRAME_UVCS(TEMP_PTR1) = LIST(FRAME_UVCS(STACK_PTR + 1),                      05402000
      FRAME_UVCS(TEMP_PTR1));                                                   05404000
                                                                                05406000
   CASE_LIST_PTRS(TEMP_PTR1) = LIST(CASE_LIST_PTRS(STACK_PTR + 1),              05408000
      CASE_LIST_PTRS(TEMP_PTR1));                                               05410000
                                                                                05410300
   TEMP_PTR1 = STACK_PTR;                                                       05410600
                                                                                05410900
   DO WHILE TRUE;                                                               05411200
      IF FRAME_TYPE(TEMP_PTR1) = BLOCK_TYPE THEN                                05411500
         GO TO NO_NEST_PROCESSING;                                              05411800
      IF FRAME_TYPE(TEMP_PTR1) = CB_TYPE THEN                                   05412100
         GO TO NEST_PROCESSING;                                                 05412400
      TEMP_PTR1 = TEMP_PTR1 - 1;                                                05412700
   END;                                                                         05413000
                                                                                05413300
NEST_PROCESSING:                                                                05413600
   IF FRAME_CB_NEST_LEVEL(STACK_PTR + 1) >= FRAME_CB_NEST_LEVEL(TEMP_PTR1) THEN 05413900
      FRAME_CB_NEST_LEVEL(TEMP_PTR1) = FRAME_CB_NEST_LEVEL(STACK_PTR + 1) + 1;  05414200
                                                                                05414500
NO_NEST_PROCESSING:                                                             05414800
                                                                                05415100
   CALL FREE_SYT_REF_FRAME(FRAME_SYT_PREV_REF(STACK_PTR + 1));                  05415400
   CALL FREE_VAC_REF_FRAME(FRAME_VAC_PREV_REF(STACK_PTR + 1));                  05416000
                                                                                05418000
   CALL PASS_BACK_SYT_REFS;                                                     05420000
   CALL FREE_SYT_REF_FRAME(FRAME_SYT_REF(STACK_PTR + 1));                       05422000
                                                                                05424000
                                                                                05426000
   CALL PASS_BACK_VAC_REFS(1);                                                  05428000
   CALL FREE_VAC_REF_FRAME(FRAME_VAC_REF(STACK_PTR + 1));                       05430000
                                                                                05432000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR) +                05434000
      MAX_CASE_LENGTH(STACK_PTR + 1) -                                          05436000
      (HALMAT_PTR + HALRATOR_#RANDS + 1 - FRAME_START(STACK_PTR + 1));          05438000
   IF (FRAME_FLAGS(STACK_PTR + 1) & ZAP_FLAG) ^= 0 THEN                         05440000
     CALL FLUSH_INFO;                                                           05442000
                                                                                05444000
   IF AUXMAT_REQUESTED | PRETTY_PRINT_REQUESTED THEN DO;                        05446000
      OUTPUT = '';                                                              05448000
      OUTPUT = TRACE_MSG('NEW_BUMP_FACTOR =' ||                                 05450000
         #RJUST(FRAME_BUMP_FACTOR(STACK_PTR), 6), HALMAT_PTR);                  05452000
   END;                                                                         05454000
                                                                                05456000
   IF STACK_DUMP THEN                                                           05458000
      CALL DUMP_STACK;                                                          05460000
                                                                                05462000
CLOSE POP_CB_FRAME;                                                             05464000
                                                                                05466000
                                                                                05468000
         /* ROUTINE TO PUSH THE FIRST CASE FRAME.  DIFFERS FROM PUSHES OF OTHER 05470000
            SUBSEQUENT FRAMES SINCE A FIXUP OF THE CB FRAME IS PERFORMED */     05472000
                                                                                05474000
PUSH_FIRST_CASE_FRAME: PROCEDURE(PUSH_IND, PUSH_IND_FLAG);                      05476000
                                                                                05478000
   DECLARE PUSH_IND CHARACTER, PUSH_IND_FLAG BIT(8);                            05480000
   DECLARE (TEMP_PTR1, TEMP_PTR2, TEMP_PTR3) BIT(16);                           05482000
                                                                                05484000
   IF STACK_DUMP THEN                                                           05486000
      CALL DUMP_STACK;                                                          05488000
                                                                                05490000
   CALL INCR_STACK_PTR;                                                         05492000
                                                                                05494000
   IF FRAME_TYPE(STACK_PTR - 1) ^= CB_TYPE THEN                                 05496000
      CALL STACK_ERROR(PUSH_IND, FRAME_TYPE(STACK_PTR - 1), CCURRENT);          05498000
                                                                                05500000
   FRAME_TYPE(STACK_PTR) = CASE_TYPE;                                           05502000
   FRAME_FLAGS(STACK_PTR) = PUSH_IND_FLAG;                                      05504000
   MAX_CASE_LENGTH(STACK_PTR - 1) = "8000";                                     05506000
   FRAME_START(STACK_PTR) = HALMAT_PTR;                                         05508000
   FRAME_START(STACK_PTR - 1) = HALMAT_PTR;                                     05510000
   FRAME_BLOCK_PTR(STACK_PTR) = FRAME_BLOCK_PTR(STACK_PTR - 1);                 05512000
   FRAME_UVCS(STACK_PTR) = 0;                                                   05514000
   FRAME_UVCS(STACK_PTR - 1) = 0;                                               05516000
   FRAME_CB_NEST_LEVEL(STACK_PTR - 1) = 1;                                      05517000
                                                                                05518000
   IF (FRAME_FLAGS(STACK_PTR - 1) & PREV_BLOCK_FLAG) = 0 THEN DO;               05520000
      TEMP_PTR1 = NEW_SYT_REF_FRAME;                                            05522000
      TEMP_PTR2 = FRAME_SYT_PREV_REF(STACK_PTR - 1);                            05524000
      TEMP_PTR3 = FRAME_SYT_REF(STACK_PTR - 1);                                 05526000
      DO FOR WORK1 = 0 TO SYT_REF_POOL_FRAME_SIZE;                              05528000
         SYT_REF_POOL(TEMP_PTR1 + WORK1) = SYT_REF_POOL(TEMP_PTR2 + WORK1) |    05530000
            SYT_REF_POOL(TEMP_PTR3 + WORK1);                                    05532000
      END;                                                                      05534000
      FRAME_SYT_PREV_REF(STACK_PTR) = TEMP_PTR1;                                05536000
      FRAME_SYT_PREV_REF(STACK_PTR - 1) = TEMP_PTR1;                            05538000
   END;                                                                         05540000
   ELSE DO;                                                                     05542000
      IF FRAME_SYT_REF(STACK_PTR - 1) ^= 0 THEN                                 05544000
         FRAME_SYT_PREV_REF(STACK_PTR), FRAME_SYT_PREV_REF(STACK_PTR - 1) =     05546000
            COPY_SYT_REF_FRAME(FRAME_SYT_REF(STACK_PTR - 1));                   05548000
      ELSE                                                                      05550000
         FRAME_SYT_PREV_REF(STACK_PTR), FRAME_SYT_PREV_REF(STACK_PTR - 1) =     05552000
            NEW_ZERO_SYT_REF_FRAME;                                             05554000
   END;                                                                         05556000
                                                                                05558000
   IF (FRAME_FLAGS(STACK_PTR - 1) & PREV_BLOCK_FLAG) = 0 THEN DO;               05560000
      TEMP_PTR1 = NEW_VAC_REF_FRAME;   /* SET UP PREVIOUS VAC REFERENCE MAP */  05562000
      TEMP_PTR2 = FRAME_VAC_PREV_REF(STACK_PTR - 1);                            05564000
      TEMP_PTR3 = FRAME_VAC_REF(STACK_PTR - 1);                                 05566000
      DO FOR WORK1 = 0 TO VAC_REF_POOL_FRAME_SIZE;                              05568000
         VAC_REF_POOL(TEMP_PTR1 + WORK1) = VAC_REF_POOL(TEMP_PTR2 + WORK1) |    05570000
            VAC_REF_POOL(TEMP_PTR3 + WORK1);                                    05572000
      END;                                                                      05574000
      FRAME_VAC_PREV_REF(STACK_PTR) = TEMP_PTR1;                                05576000
      FRAME_VAC_PREV_REF(STACK_PTR - 1) = TEMP_PTR1;                            05578000
   END;                                                                         05580000
   ELSE DO;                                                                     05582000
      IF FRAME_VAC_REF(STACK_PTR - 1) ^= 0 THEN                                 05584000
         FRAME_VAC_PREV_REF(STACK_PTR), FRAME_VAC_PREV_REF(STACK_PTR - 1) =     05586000
            COPY_VAC_REF_FRAME(FRAME_VAC_REF(STACK_PTR - 1));                   05588000
      ELSE                                                                      05590000
         FRAME_VAC_PREV_REF(STACK_PTR), FRAME_VAC_PREV_REF(STACK_PTR - 1) =     05592000
            NEW_ZERO_VAC_REF_FRAME;                                             05594000
   END;                                                                         05596000
                                                                                05598000
   FRAME_SYT_REF(STACK_PTR - 1) = NEW_ZERO_SYT_REF_FRAME;                       05600000
   FRAME_SYT_REF(STACK_PTR) = NEW_ZERO_SYT_REF_FRAME;                           05602000
                                                                                05604000
   FRAME_VAC_REF(STACK_PTR - 1) = NEW_ZERO_VAC_REF_FRAME;                       05606000
   FRAME_VAC_REF(STACK_PTR) = NEW_ZERO_VAC_REF_FRAME;                           05608000
                                                                                05610000
   FRAME_INL(STACK_PTR) = -1;                                                   05612000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR - 1);             05614000
                                                                                05616000
   FRAME_CASE_LIST(STACK_PTR) = HALMAT_PTR;                                     05618000
   TEMP_PTR1, AUXMAT1(HALMAT_PTR) = GET_FREE_CELL;                              05620000
   CELL1(TEMP_PTR1) = -1;                                                       05622000
   GEN_CODE(HALMAT_PTR) = GEN_LIST_OPCODE;                                      05624000
                                                                                05626000
   TEMP_PTR1, FRAME_MAP_SAVE(STACK_PTR - 1) = GET_FREE_CELL;                    05628000
   CELL1(TEMP_PTR1) = -1;                                                       05630000
   FRAME_MAP_SAVE(STACK_PTR) = 0;                                               05632000
                                                                                05634000
   CASE_LIST_PTRS(STACK_PTR - 1) = 0;                                           05636000
   CASE_LIST_PTRS(STACK_PTR) = 0;                                               05638000
                                                                                05640000
   PUSH_IND_FLAG = 0;                                                           05642000
                                                                                05644000
   IF STACK_DUMP THEN                                                           05646000
      CALL DUMP_STACK;                                                          05648000
                                                                                05650000
CLOSE PUSH_FIRST_CASE_FRAME;                                                    05652000
                                                                                05654000
                                                                                05656000
         /* ROUTINE TO PUSH A CASE FRAME OTHER THAN THE FIRST */                05658000
                                                                                05660000
PUSH_CASE_FRAME: PROCEDURE(PUSH_IND, PUSH_IND_FLAG);                            05662000
                                                                                05664000
   DECLARE PUSH_IND CHARACTER, PUSH_IND_FLAG BIT(8);                            05666000
   DECLARE TEMP_PTR BIT(16);                                                    05668000
                                                                                05670000
   IF STACK_DUMP THEN                                                           05672000
      CALL DUMP_STACK;                                                          05674000
                                                                                05676000
   CALL INCR_STACK_PTR;                                                         05678000
                                                                                05680000
   IF FRAME_TYPE(STACK_PTR - 1) ^= CB_TYPE THEN                                 05682000
      CALL STACK_ERROR(PUSH_IND, FRAME_TYPE(STACK_PTR - 1), CCURRENT);          05684000
                                                                                05686000
   FRAME_TYPE(STACK_PTR) = CASE_TYPE;                                           05688000
   FRAME_FLAGS(STACK_PTR) = PUSH_IND_FLAG;                                      05690000
   FRAME_START(STACK_PTR) = HALMAT_PTR;                                         05692000
   FRAME_BLOCK_PTR(STACK_PTR) = FRAME_BLOCK_PTR(STACK_PTR - 1);                 05694000
   FRAME_UVCS(STACK_PTR) = 0;                                                   05696000
                                                                                05698000
   FRAME_SYT_PREV_REF(STACK_PTR) = FRAME_SYT_PREV_REF(STACK_PTR - 1);           05700000
   FRAME_VAC_PREV_REF(STACK_PTR) = FRAME_VAC_PREV_REF(STACK_PTR - 1);           05702000
                                                                                05704000
   FRAME_SYT_REF(STACK_PTR) = NEW_ZERO_SYT_REF_FRAME;                           05706000
                                                                                05708000
   FRAME_VAC_REF(STACK_PTR) = NEW_ZERO_VAC_REF_FRAME;                           05710000
                                                                                05712000
   FRAME_INL(STACK_PTR) = -1;                                                   05714000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR - 1);             05716000
                                                                                05718000
   FRAME_CASE_LIST(STACK_PTR) = HALMAT_PTR;                                     05720000
   TEMP_PTR, AUXMAT1(HALMAT_PTR) = GET_FREE_CELL;                               05722000
   CELL1(TEMP_PTR) = -1;                                                        05724000
   GEN_CODE(HALMAT_PTR) = GEN_LIST_OPCODE;                                      05726000
                                                                                05728000
   FRAME_MAP_SAVE(STACK_PTR) = 0;                                               05730000
                                                                                05732000
   CASE_LIST_PTRS(STACK_PTR) = 0;                                               05734000
                                                                                05736000
   PUSH_IND_FLAG = 0;                                                           05738000
                                                                                05740000
   IF STACK_DUMP THEN                                                           05742000
      CALL DUMP_STACK;                                                          05744000
                                                                                05746000
CLOSE PUSH_CASE_FRAME;                                                          05748000
                                                                                05750000
                                                                                05752000
         /* ROUTINE TO POP A CASE FRAME */                                      05754000
                                                                                05756000
POP_CASE_FRAME: PROCEDURE(POP_IND);                                             05758000
                                                                                05760000
   DECLARE POP_IND CHARACTER;                                                   05762000
   DECLARE (TEMP_PTR1, TEMP_PTR2) BIT(16);                                      05764000
                                                                                05766000
   IF STACK_DUMP THEN                                                           05768000
      CALL DUMP_STACK;                                                          05770000
                                                                                05772000
   CALL DECR_STACK_PTR;                                                         05774000
                                                                                05776000
   FRAME_FLAGS(STACK_PTR) = FRAME_FLAGS(STACK_PTR) |                            05778000
      (FRAME_FLAGS(STACK_PTR + 1) & (IF_THEN_ELSE_MASK | ZAP_FLAG));            05780000
                                                                                05782000
   IF FRAME_TYPE(STACK_PTR) ^= CB_TYPE THEN                                     05784000
      CALL STACK_ERROR(POP_IND, FRAME_TYPE(STACK_PTR), 'PREVIOUS ');            05786000
                                                                                05788000
   FRAME_UVCS(STACK_PTR) = LIST(FRAME_UVCS(STACK_PTR + 1),                      05790000
      FRAME_UVCS(STACK_PTR));                                                   05792000
                                                                                05794000
   CALL PASS_BACK_SYT_REFS;                                                     05796000
                                                                                05798000
   CALL PASS_BACK_VAC_REFS(0);                                                  05800000
                                                                                05802000
   IF (FRAME_FLAGS(STACK_PTR + 1) & IF_THEN_ELSE_MASK) ^= 0 THEN                05804000
      TEMP_PTR1 = HALMAT_PTR + HALRATOR_#RANDS + 1 - FRAME_START(STACK_PTR + 1);05806000
   ELSE                                                                         05808000
      TEMP_PTR1 = HALMAT_PTR - FRAME_START(STACK_PTR + 1);                      05810000
   TEMP_PTR2 = TEMP_PTR1 + (FRAME_BUMP_FACTOR(STACK_PTR + 1) -                  05812000
      FRAME_BUMP_FACTOR(STACK_PTR));                                            05814000
   IF TEMP_PTR2 > MAX_CASE_LENGTH(STACK_PTR) THEN                               05816000
      MAX_CASE_LENGTH(STACK_PTR) = TEMP_PTR2;                                   05818000
   FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR) - TEMP_PTR1;     05820000
                                                                                05822000
   TEMP_PTR1 = GET_FREE_CELL;                                                   05824000
   CELL1(TEMP_PTR1) = FRAME_START(STACK_PTR + 1);                               05826000
   CELL2(TEMP_PTR1) = FRAME_SYT_REF(STACK_PTR + 1);                             05828000
   TEMP_PTR2 = GET_FREE_CELL;                                                   05830000
   CELL1(TEMP_PTR2) = FRAME_VAC_REF(STACK_PTR + 1);                             05832000
   CDR_CELL(TEMP_PTR1) = TEMP_PTR2;                                             05834000
   CDR_CELL(TEMP_PTR2) = FRAME_MAP_SAVE(STACK_PTR);                             05836000
   FRAME_MAP_SAVE(STACK_PTR) = TEMP_PTR1;                                       05838000
                                                                                05840000
   IF (FRAME_FLAGS(STACK_PTR + 1) & TRUE_CASE) ^= 0 THEN DO;                    05842000
      TEMP_PTR1 = GET_FREE_CELL;                                                05844000
      CELL1(TEMP_PTR1) = FRAME_START(STACK_PTR + 1);                            05846000
      CDR_CELL(TEMP_PTR1) = CASE_LIST_PTRS(STACK_PTR + 1);                      05848000
                                                                                05848500
      IF (FRAME_FLAGS(STACK_PTR + 1) & PREV_BLOCK_FLAG) = 0 THEN                05849000
         TARGET(FRAME_START(STACK_PTR)) = FRAME_CB_NEST_LEVEL(STACK_PTR);       05849500
                                                                                05850000
   END;                                                                         05850500
   ELSE                                                                         05852000
      TEMP_PTR1 = CASE_LIST_PTRS(STACK_PTR + 1);                                05854000
   CASE_LIST_PTRS(STACK_PTR) = LIST(TEMP_PTR1, CASE_LIST_PTRS(STACK_PTR));      05856000
                                                                                05858000
   IF AUXMAT_REQUESTED | PRETTY_PRINT_REQUESTED THEN DO;                        05860000
      OUTPUT = '';                                                              05862000
      OUTPUT = TRACE_MSG('NEW BUMP_FACTOR =' ||                                 05864000
         #RJUST(FRAME_BUMP_FACTOR(STACK_PTR), 6), HALMAT_PTR);                  05866000
   END;                                                                         05868000
                                                                                05870000
   IF STACK_DUMP THEN                                                           05872000
      CALL DUMP_STACK;                                                          05874000
                                                                                05876000
CLOSE POP_CASE_FRAME;                                                           05878000
                                                                                05880000
                                                                                05882000
         /* ROUTINE TO HANDLE CLASS_0 HALMAT OPERATORS */                       05884000
                                                                                05886000
CLASS_0: PROCEDURE;                                                             05888000
                                                                                05890000
                                                                                05892000
         /* ROUTINE TO HANDLE HALMAT OPERATORS OF THE FORM "00X" */             05894000
                                                                                05896000
CLASS_00: PROCEDURE;                                                            05898000
                                                                                05900000
   DO CASE HALRATOR & "F";                                                      05902000
                                                                                05904000
      DO FOR WORK1 = 1 TO HALRATOR_#RANDS;   /* CASE 0, HALRATOR = 000 (NOP) */ 05906000
         HALMAT(HALMAT_PTR + WORK1) = 1;                                        05908000
      END;                                                                      05910000
                                                                                05912000
      DO;   /* CASE 1, HALRATOR = 001 (EXTN) */                                 05914000
         CALL DECODE_HALRAND(1);                                                05916000
         IF HALRAND_QUALIFIER = VAC THEN                                        05918000
            CALL SET_RAND_NOOSE(1, 0, 1);                                       05920000
      END;                                                                      05922000
                                                                                05924000
      DO;   /* CASE 2, HALRATOR = 002 (XREC) */                                 05926000
         IF (HALRATOR_TAG2 & RATOR_CSE_FLAG) ^= 0 THEN DO;                      05928000
            BLOCK_PRIME = ON;                                                   05930000
            XREC_PTR = HALMAT_PTR;                                              05932000
            GEN_CODE(HALMAT_PTR) = XREC_OPCODE;                                 05934000
            CALL NEW_HALMAT_BLOCK(HALMAT_SIZE, FALSE);                          05936000
            HALMAT_PTR = HALMAT_SIZE - (HALRATOR_#RANDS + 1);                   05938000
         END;                                                                   05940000
         ELSE DO;                                                               05942000
            IF HALRATOR_TAG1 THEN DO;                                           05944000
               /* IF TAG1 = 1 THEN THIS IS LAST HALMAT BLOCK */                 05946000
               AUXMATING = OFF;                                                 05948000
               GEN_CODE(HALMAT_PTR) = AUXMAT_END_OPCODE;                        05950000
            END;                                                                05952000
            ELSE GEN_CODE(HALMAT_PTR) = XREC_OPCODE;                            05954000
            IF HALMAT_PTR > HALMAT_SIZE THEN XREC_PRIME_PTR = HALMAT_PTR;       05956000
            ELSE XREC_PTR = HALMAT_PTR;                                         05958000
            THIS_HALMAT_BLOCK = OFF;                                            05960000
         END;                                                                   05962000
      END;                                                                      05964000
                                                                                05966000
      DO;   /* CASE 3, HALRATOR = 003 (IMRK) */                                 05968000
      DECODE_MRK:                                                               05970000
         IF HALRATOR_TAG1 ^= 0 THEN DO;   /* ERROR IN COMPILATION */            05972000
            THIS_HALMAT_BLOCK, AUXMATING = OFF;                                 05974000
            GEN_CODE(HALMAT_PTR) = AUXMAT_END_OPCODE;                           05976000
            IF HALMAT_PTR >= HALMAT_SIZE THEN XREC_PRIME_PTR = HALMAT_PTR;      05978000
            ELSE XREC_PTR = HALMAT_PTR;                                         05980000
         END;                                                                   05982000
         ELSE DO;                                                               05984000
            CALL DECODE_HALRAND(1);                                             05986000
            CURRENT_STMT = HALRAND;                                             05987000
            IF HALRAND_TAG1 ^= 0 THEN CALL SET_DEBUG_SWITCH(HALRAND_TAG1);      05988000
         END;                                                                   05990000
      END;                                                                      05992000
                                                                                05994000
      GO TO DECODE_MRK;   /* CASE 4, HALRATOR = 004 (SMRK) */                   05996000
                                                                                05998000
      ;   /* CASE 5, HALRATOR = 005 (PXRC) */                                   06000000
                                                                                06002000
      ;   /* CASE 6, HALRATOR = 006 */                                          06004000
                                                                                06006000
      CALL PUSH_CB_FRAME;   /* CASE 7, HALRATOR = 007 (IFHD) */                 06008000
                                                                                06010000
                                                                                06012000
      DO;   /* CASE 8, HALRATOR = 008 (LBL) */                                  06014000
         IF HALRATOR_TAG1 THEN DO;                                              06016000
            CALL POP_CASE_FRAME('LBL*');                                        06018000
            CALL POP_CB_FRAME;                                                  06020000
         END;                                                                   06022000
         ELSE DO;                                                               06024000
            CALL DECODE_HALRAND(1);                                             06026000
            IF ((HALMAT(HALMAT_PTR - 2) & "FFF0") = "0090") &                   06028000
               ((HALMAT(HALMAT_PTR - 2) & "FF000000") ^= 0) THEN                06030000
               CALL PUSH_CASE_FRAME('LBL', FALSE_CASE);                         06032000
            ELSE                                                                06034000
               IF HALRAND_QUALIFIER = SYT THEN IF SYT_DIMS(HALRAND) ^= 0 THEN   06036000
                  CALL FLUSH_INFO;                                              06038000
         END;                                                                   06040000
      END;                                                                      06042000
                                                                                06044000
      IF HALRATOR_TAG1 THEN CALL POP_CASE_FRAME('BRA*');                        06046000
         /* CASE 9, HALRATOR = 009 (BRA) */                                     06048000
                                                                                06050000
      DO;   /* CASE A, HALRATOR = 00A (FBRA) */                                 06052000
         CALL SET_RAND_NOOSE(2);                                                06054000
         CALL PUSH_FIRST_CASE_FRAME('FBRA', TRUE_CASE);                         06056000
      END;                                                                      06058000
                                                                                06060000
      DO;   /* CASE B, HALRATOR = 00B (DCAS) */                                 06062000
         CALL SET_RAND_NOOSE(2);                                                06064000
         CALL PUSH_CB_FRAME;                                                    06066000
         IF HALRATOR_TAG1 THEN   /* ELSE CLAUSE PRESENT SO                      06068000
                                       PUSH FOR FIRST CASE */                   06070000
            CALL PUSH_FIRST_CASE_FRAME('DCAS');                                 06072000
         ELSE                                                                   06074000
            FRAME_FLAGS(STACK_PTR) = FRAME_FLAGS(STACK_PTR) |                   06076000
               FIRST_CASE_TBD_FLAG;   /* NO ELSE CLAUSE SO DELAY PUSHING */     06078000
      END;                                                                      06080000
                                                                                06082000
      CALL POP_CB_FRAME;   /* CASE C, HALRATOR = 00C (ECAS) */                  06084000
                                                                                06086000
      DO;   /* CASE D, HALRATOR = 00D (CLBL) */                                 06088000
         IF (FRAME_FLAGS(STACK_PTR) & FIRST_CASE_TBD_FLAG) ^= 0 THEN DO;        06090000
            FRAME_FLAGS(STACK_PTR) = FRAME_FLAGS(STACK_PTR) &                   06092000
               ^FIRST_CASE_TBD_FLAG;                                            06094000
            CALL PUSH_FIRST_CASE_FRAME('CLBL');                                 06096000
         END;                                                                   06098000
         ELSE                                                                   06100000
            IF HALRATOR_TAG1 THEN   /* LAST CASE IN FRAME */                    06102000
               CALL POP_CASE_FRAME('CLBL*');                                    06104000
            ELSE DO;                                                            06106000
               CALL POP_CASE_FRAME('CLBL');                                     06108000
               CALL PUSH_CASE_FRAME('CLBL');                                    06110000
            END;                                                                06112000
      END;                                                                      06114000
                                                                                06116000
      ;   /* CASE E, HALRATOR = 00E (DTST) */                                   06118000
      ;   /* CASE F, HALRATOR = 00F (ETST) */                                   06120000
                                                                                06122000
   END;                                                                         06124000
                                                                                06126000
CLOSE CLASS_00 /* $S+ */ ;   /* $S@ */                                          06128000
                                                                                06130000
                                                                                06132000
         /* ROUTINE TO HANDLE HALMAT OPERATORS OF THE FORM "01X" */             06134000
                                                                                06136000
CLASS_01: PROCEDURE;                                                            06138000
                                                                                06140000
   DECLARE CASE_DECODE(15) BIT(8) INITIAL(                                      06142000
                                                                                06144000
        4,                             /* CASE 0, HALRATOR = 010 (DFOR) */      06146000
        0,                             /* CASE 1, HALRATOR = 011 (EFOR) */      06148000
        0,                             /* CASE 2, HALRATOR = 012 (CFOR) */      06150000
        0,                             /* CASE 3, HALRATOR = 013 (DSMP) */      06152000
        0,                             /* CASE 4, HALRATOR = 014 (ESMP) */      06154000
        0,                             /* CASE 5, HALRATOR = 015 (AFOR) */      06156000
        0,                             /* CASE 6, HALRATOR = 016 (CTST) */      06158000
        0,                             /* CASE 7, HALRATOR = 017 (ADLP) */      06160000
        0,                             /* CASE 8, HALRATOR = 018 (DLPE) */      06162000
        1,                             /* CASE 9, HALRATOR = 019 (DSUB) */      06164000
        0,                             /* CASE A, HALRATOR = 01A (IDLP) */      06166000
        1,                             /* CASE B, HALRATOR = 01B (TSUB) */      06168000
        0,                             /* CASE C, HALRATOR = 01C */             06170000
        2,                             /* CASE D, HALRATOR = 01D (PCAL) */      06172000
        3,                             /* CASE E, HALRATOR = 01E (FCAL) */      06174000
        2);                            /* CASE F, HALRATOR = 01F (READ) */      06176000
                                                                                06178000
   DO CASE CASE_DECODE(HALRATOR & "F");                                         06180000
                                                                                06182000
      ;   /* CASE 0, DO NOTHING */                                              06184000
                                                                                06186000
      DO;   /* CASE 1, MARK AS VAC & CHECK SUBSCRIPTS */                        06188000
         PTR_TYPE(HALMAT_PTR) = VAC;                                            06190000
         PTR(HALMAT_PTR) = HALMAT_PTR MOD 1800;                                 06192000
         GEN_CODE(HALMAT_PTR) = NOOSE_OPCODE;                                   06194000
         CALL ADD_UVC(VAC, HALMAT_PTR, HALMAT_PTR);                             06196000
         CALL SET_SIMP_NOOSE(1);                                                06198000
      END;                                                                      06200000
                                                                                06202000
     CALL FLUSH_INFO;                                                           06204000
                                                                                06206000
      DO;   /* CASE 3, MARK FCAL FOR NEXT USE */                                06208000
         PTR_TYPE(HALMAT_PTR) = VAC;                                            06210000
         PTR(HALMAT_PTR) = HALMAT_PTR MOD 1800;                                 06212000
         GEN_CODE(HALMAT_PTR) = NOOSE_OPCODE;                                   06214000
        CALL FLUSH_INFO;                                                        06216000
         CALL ADD_UVC(VAC, HALMAT_PTR, HALMAT_PTR);                             06218000
      END;                                                                      06220000
                                                                                06222000
      CALL SET_RAND_NOOSE(2);                                                   06224000
                                                                                06226000
   END;                                                                         06228000
                                                                                06230000
CLOSE CLASS_01;                                                                 06232000
                                                                                06234000
                                                                                06236000
         /* ROUTINE TO HANDLE HALMAT OPERATORS OF THE FORM "02X" */             06238000
                                                                                06240000
CLASS_02: PROCEDURE;                                                            06242000
                                                                                06244000
   DECLARE CASE_DECODE(15) BIT(8) INITIAL(                                      06246000
                                                                                06248000
        1,                             /* CASE 0, HALRATOR = 020 (RDAL) */      06250000
        0,                             /* CASE 1, HALRATOR = 021 (WRIT) */      06252000
        2,                             /* CASE 2, HALRATOR = 022 (FILE) */      06254000
        0,                             /* CASE 3, HALRATOR = 023 */             06256000
        0,                             /* CASE 4, HALRATOR = 024 */             06258000
        0,                             /* CASE 5, HALRATOR = 025 (XXST) */      06260000
        0,                             /* CASE 6, HALRATOR = 026 (XXND) */      06262000
        0,                             /* CASE 7, HALRATOR = 027 (XXAR) */      06264000
        0,                             /* CASE 8, HALRATOR = 028 */             06266000
        0,                             /* CASE 9, HALRATOR = 029 */             06268000
        3,                             /* CASE A, HALRATOR = 02A (TDEF) */      06270000
        3,                             /* CASE B, HALRATOR = 02B (MDEF) */      06272000
        3,                             /* CASE C, HALRATOR = 02C (FDEF) */      06274000
        3,                             /* CASE D, HALRATOR = 02D (PDEF) */      06276000
        3,                             /* CASE E, HALRATOR = 02E (UDEF) */      06278000
        4);                            /* CASE F, HALRATOR = 02F (CDEF) */      06280000
                                                                                06282000
   DO CASE CASE_DECODE(HALRATOR & "F");                                         06284000
                                                                                06286000
      ;   /* CASE 0, DO NOTHING */                                              06288000
                                                                                06290000
     CALL FLUSH_INFO;   /* CASE 1, (RDAL) THIS IS TIGHT AND                     06292000
                            SHOULD BE RELAXED */                                06294000
                                                                                06296000
      DO;   /* CASE 2, FILE I/O */                                              06298000
         CALL DECODE_HALRAND(2);                                                06300000
         IF (HALRAND_TAG2 & 2) = 0 THEN                                         06302000
           CALL FLUSH_INFO; /* THIS ZAP IS NOT TIGHT SINCE FILE I/O             06304000
                                   COULD WIPE OUT ALMOST ANYTHING DEPENDING     06306000
                                   ON THE DATA LAYOUT */                        06308000
      END;                                                                      06310000
                                                                                06312000
      CALL PUSH_BLOCK_FRAME;   /* CASE 3, BLOCK DEFINITION HEADERS:             06314000
                                  TDEF, MDEF, FDEF, PDEF, UDEF */               06316000
                                                                                06318000
      DO;   /* CASE 4, COMPOOL DEFINITION HEADER */                             06320000
         /* THIS IS A COMPOOL SO GO AWAY */                                     06322000
         AUXMATING = OFF;                                                       06324000
         GEN_CODE(HALMAT_PTR) = AUXMAT_END_OPCODE;                              06326000
         THIS_HALMAT_BLOCK = OFF;                                               06328000
         IF HALMAT_PTR >= HALMAT_SIZE THEN                                      06330000
            XREC_PRIME_PTR = HALMAT_PTR;                                        06332000
         ELSE                                                                   06334000
            XREC_PTR = HALMAT_PTR;                                              06336000
      END;                                                                      06338000
                                                                                06340000
   END;                                                                         06342000
                                                                                06344000
CLOSE CLASS_02;                                                                 06346000
                                                                                06348000
                                                                                06350000
         /* ROUTINE TO HANDLE HALMAT OPERATORS OF THE FORM "03X" */             06352000
                                                                                06354000
CLASS_03: PROCEDURE;                                                            06356000
                                                                                06358000
   DECLARE OPCODE_CASE_DECODE(15) BIT(8) INITIAL(                               06360000
                                                                                06362000
        1,                             /* CASE 0, HALRATOR = 030 (CLOS) */      06364000
        2,                             /* CASE 1, HALRATOR = 031 (EDCL) */      06366000
        3,                             /* CASE 2, HALRATOR = 032 (RTRN) */      06368000
        0,                             /* CASE 3, HALRATOR = 033 (TDCL) */      06370000
        0,                             /* CASE 4, HALRATOR = 034 (WAIT) */      06372000
        0,                             /* CASE 5, HALRATOR = 035 (SGNL) */      06374000
        0,                             /* CASE 6, HALRATOR = 036 (CANC) */      06376000
        0,                             /* CASE 7, HALRATOR = 037 (TERM) */      06378000
        0,                             /* CASE 8, HALRATOR = 038 (PRIO) */      06380000
        0,                             /* CASE 9, HALRATOR = 039 (SCHD) */      06382000
        0,                             /* CASE A, HALRATOR = 03A */             06384000
        0,                             /* CASE B, HALRATOR = 03B */             06386000
        0,                             /* CASE C, HALRATOR = 03C (ERON) */      06388000
        0,                             /* CASE D, HALRATOR = 03D (ERSE) */      06390000
        0,                             /* CASE E, HALRATOR = 03E */             06392000
        0),                            /* CASE F, HALRATOR = 03F */             06394000
                                                                                06396000
        TEMP_PTR                       BIT(16);                                 06398000
                                                                                06400000
                                                                                06402000
   DO CASE OPCODE_CASE_DECODE(HALRATOR & "F");                                  06404000
                                                                                06406000
      ;   /* DO NOTHING */                                                      06408000
                                                                                06410000
      CALL POP_BLOCK_FRAME;                                                     06412000
                                                                                06414000
      DO;                                                                       06416000
         IF FRAME_TYPE(STACK_PTR) ^= BLOCK_TYPE THEN                            06418000
            CALL STACK_ERROR('EDCL', FRAME_TYPE(STACK_PTR), CCURRENT);          06420000
         CALL ADD_TO_VAC_BOUNDS(FRAME_START(STACK_PTR), HALMAT_PTR);            06422000
      END;                                                                      06424000
                                                                                06424100
      DO;                                                                       06424200
         TEMP_PTR = STACK_PTR;                                                  06424300
                                                                                06424400
         DO WHILE TRUE;                                                         06424500
            IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN                            06424600
               GO TO EXIT_SEARCH_LOOP;                                          06424700
            IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN                           06424800
               RETURN;                                                          06424900
            TEMP_PTR = TEMP_PTR - 1;                                            06425000
         END;                                                                   06425100
      EXIT_SEARCH_LOOP:                                                         06425200
                                                                                06425300
         IF (FRAME_FLAGS(TEMP_PTR) & ZAP_FLAG) ^= 0 THEN                        06425400
            FRAME_FLAGS(TEMP_PTR) = (FRAME_FLAGS(TEMP_PTR) & ^ZAP_FLAG)         06425500
               | FLUSH_FLAG;                                                    06425600
                                                                                06425700
      END;                                                                      06425800
                                                                                06426000
   END;                                                                         06428000
                                                                                06430000
CLOSE CLASS_03;                                                                 06432000
                                                                                06434000
                                                                                06436000
         /* ROUTINE TO HANDLE HALMAT OPERATORS OF THE FORM "04X" */             06438000
CLASS_04: PROCEDURE;                                                            06440000
                                                                                06442000
    DECLARE OPCODE_CASE_DECODE(15) BIT(8) INITIAL(                              06444000
                                                                                06446000
        0,                             /* CASE 0, HALRATOR = 040 (MSHP) */      06448000
        0,                             /* CASE 1, HALRATOR = 041 (VSHP) */      06450000
        0,                             /* CASE 2, HALRATOR = 042 (SSHP) */      06452000
        0,                             /* CASE 3, HALRATOR = 043 (ISHP) */      06454000
        0,                             /* CASE 4, HALRATOR = 044 */             06456000
        0,                             /* CASE 5, HALRATOR = 045 (SFST) */      06458000
        0,                             /* CASE 6, HALRATOR = 046 (SFND) */      06460000
        0,                             /* CASE 7, HALRATOR = 047 (SFAR) */      06462000
        0,                             /* CASE 8, HALRATOR = 048 */             06464000
        0,                             /* CASE 9, HALRATOR = 049 */             06466000
        1,                             /* CASE A, HALRATOR = 04A (BFNC) */      06468000
        0,                             /* CASE B, HALRATOR = 04B (LFNC) */      06470000
        0,                             /* CASE C, HALRATOR = 04C */             06472000
        0,                             /* CASE D, HALRATOR = 04D (TNEQ) */      06474000
        0,                             /* CASE E, HALRATOR = 04E (TEQU) */      06476000
        2);                            /* CASE F, HALRATOR = 04F (TASN) */      06478000
                                                                                06480000
                                                                                06482000
         /* ROUTINE TO GENERATE TARGETING INFORMATION */                        06484000
                                                                                06486000
GEN_TARGET: PROCEDURE(ARG_HEAD, BFNC#, ARG#);                                   06488000
                                                                                06490000
   DECLARE                                                                      06492000
        ARG#                           BIT(8),                                  06494000
        BFNC#                          BIT(16),                                 06496000
        ARG_HEAD                       BIT(16),                                 06498000
        I                              BIT(16),                                 06500000
        MAX_STOP_LEVEL                 BIT(16),                                 06502000
        HALRAND_QUALIFIER              BIT(4),                                  06504000
        HALRAND                        BIT(16),                                 06506000
        HALRATOR                       BIT(16),                                 06508000
        HALRATOR_TAG2                  BIT(4),                                  06510000
        HALRATOR_#RANDS                BIT(8),                                  06512000
        CASSIGN                        CHARACTER INITIAL('ASSIGN'),             06514000
        CCOMPARISON                    CHARACTER INITIAL('COMPARISON'),         06516000
        CINITIALIZATION                CHARACTER INITIAL('INITIALIZATION'),     06518000
        CILLEGAL                       CHARACTER INITIAL('CILLEGAL'),           06520000
        CLASS_CASE_DECODE(15)          BIT(8) INITIAL                           06522000
           (0, 1, 1, 1, 1, 1, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4);                    06524000
                                                                                06526000
                                                                                06528000
         /* LOCAL ROUTINE TO DECODE HALMAT OPERANDS */                          06530000
                                                                                06532000
DECODE_HALRAND: PROCEDURE(RAND#);                                               06534000
                                                                                06536000
   DECLARE RAND# BIT(16);                                                       06538000
                                                                                06540000
   TEMP_MAT = HALMAT(RAND#);                                                    06542000
   IF (TEMP_MAT & 1) = 0 THEN                                                   06544000
      CALL ERRORS (CLASS_BI, 407);                                              06546000
   HALRAND_QUALIFIER = SHR(TEMP_MAT, 4) & "F";                                  06550000
   HALRAND = SHR(TEMP_MAT, 16) & "FFFF";                                        06552000
   IF (RAND# >= 1800) & (HALRAND_QUALIFIER = VAC) THEN DO;                      06554000
      IF (HALRAND & "8000") ^= 0 THEN                                           06556000
         HALRAND = HALRAND & "7FFF";                                            06558000
      ELSE                                                                      06560000
         HALRAND = HALRAND + 1800;                                              06562000
   END;                                                                         06564000
                                                                                06566000
CLOSE DECODE_HALRAND;                                                           06568000
                                                                                06570000
                                                                                06572000
         /* LOCAL ROUTINE TO DECODE HALMAT OPERATORS */                         06574000
                                                                                06576000
DECODE_HALRATOR: PROCEDURE(RATOR#);                                             06578000
                                                                                06580000
   DECLARE RATOR# BIT(16);                                                      06582000
                                                                                06584000
   TEMP_MAT = HALMAT(RATOR#);                                                   06586000
   IF (TEMP_MAT & 1) ^= 0 THEN DO;                                              06588000
      TEMP_MAT = HALMAT(RATOR# - 1);                                            06590000
      IF ((TEMP_MAT & 1) ^= 0) |                                                06592000
         ( ((SHR(TEMP_MAT, 24) & "FF") ^= "3A") &                               06594000
           ((SHR(TEMP_MAT, 24) & "FF") ^= "39") ) THEN                          06596000
         CALL ERRORS (CLASS_BI, 408);                                           06598000
   END;                                                                         06602000
   HALRATOR = SHR(TEMP_MAT, 4) & "FFF";                                         06604000
   HALRATOR_#RANDS = SHR(TEMP_MAT, 16) & "FF";                                  06606000
   HALRATOR_TAG2 = TEMP_MAT & "F";                                              06608000
                                                                                06610000
CLOSE DECODE_HALRATOR;                                                          06612000
                                                                                06614000
                                                                                06616000
         /* LOCAL ROUTINE TO ISSUE ERROR MESSAGE */                             06618000
                                                                                06620000
TARGET_ERROR: PROCEDURE(RATOR_TYPE);                                            06622000
                                                                                06624000
   DECLARE RATOR_TYPE CHARACTER;                                                06626000
                                                                                06628000
   CALL ERRORS (CLASS_BI, 409, ' '||RATOR_TYPE);                                06630000
                                                                                06632000
CLOSE TARGET_ERROR;                                                             06634000
                                                                                06636000
                                                                                06638000
         /* ROUTINE TO MARK TARGET INFORMATION */                               06640000
                                                                                06642000
MARK_TARGET: PROCEDURE(HALMAT#);                                                06644000
                                                                                06646000
   DECLARE HALMAT# BIT(16);                                                     06648000
                                                                                06650000
   IF (TAGS(HALMAT#) ^= 0) | (TARGET(HALMAT#) ^= 0) THEN                        06652000
      RETURN;                                                                   06654000
   TAGS(HALMAT#) = ARG#;                                                        06656000
   TARGET(HALMAT#) = BFNC#;                                                     06658000
                                                                                06660000
CLOSE MARK_TARGET;                                                              06662000
                                                                                06664000
                                                                                06666000
         /* ROUTINE TO DETERMINE IF SHOULD STOP TRACING DOWN                    06668000
            EXPRESSION TREES DUE TO A CSE NODE */                               06670000
                                                                                06672000
CSE_STOP: FUNCTION(HALMAT_LINE) BIT(1);                                         06674000
                                                                                06676000
   DECLARE HALMAT_LINE  BIT(16), TEMP_PTR BIT(16);                              06678000
                                                                                06680000
   TEMP_PTR = SHR(HALMAT_LINE, 5);                                              06682000
   IF ( ((VAC_REF_POOL(FRAME_VAC_REF(STACK_PTR) + TEMP_PTR) |                   06684000
        VAC_REF_POOL(FRAME_VAC_PREV_REF(STACK_PTR) + TEMP_PTR)) &               06686000
        MAP_INDICES(HALMAT_LINE & "1F")) ^= 0) &                                06688000
      ((HALMAT(HALMAT_LINE) & RATOR_CSE_FLAG) ^= 0) THEN                        06690000
      RETURN TRUE;                                                              06692000
   ELSE                                                                         06694000
      RETURN FALSE;                                                             06696000
                                                                                06698000
CLOSE CSE_STOP;                                                                 06700000
                                                                                06702000
                                                                                06704000
         /* ROUTINE TO CHECK IF A STOP CONDITION EXISTS ON                      06706000
            SOME NODE IN AN EXPRESSION TREE */                                  06708000
                                                                                06710000
STOP_THIS_RATOR: FUNCTION BIT(1);                                               06712000
                                                                                06714000
   DECLARE NEXT_RATOR BIT(16);                                                  06716000
   DECLARE CLASS_DECODE(15) BIT(8) INITIAL                                      06718000
      (0, 1, 1, 1, 1, 1, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4);                         06720000
                                                                                06722000
                                                                                06724000
         /* LOCAL ROUTINE TO GET NEXT HALMAT OPERATOR DOWN EXPRESSION TREE */   06726000
                                                                                06728000
                                                                                06730000
GET_NEXT_RATOR: FUNCTION(HALMAT_LINE) BIT(16);                                  06732000
                                                                                06734000
   DECLARE                                                                      06736000
        HALMAT_LINE                    BIT(16),                                 06736250
        TEMP_MAT                       FIXED;                                   06736500
                                                                                06736750
   TEMP_MAT = HALMAT(HALMAT_LINE);                                              06737000
                                                                                06737250
   IF (TEMP_MAT & 1) = 1 THEN                                                   06737500
      TEMP_MAT = HALMAT(HALMAT_LINE - 1);                                       06737750
                                                                                06738000
   RETURN SHR(TEMP_MAT, 4) & "FFF";                                             06740000
                                                                                06742000
CLOSE GET_NEXT_RATOR;                                                           06744000
                                                                                06746000
                                                                                06748000
         /* CHECK IF STOP DUE TO THIS HALMAT OPERATOR */                        06750000
                                                                                06752000
   DO CASE CLASS_DECODE(SHR(HALRATOR, 8) & "F");                                06754000
                                                                                06756000
      DO;   /* CASE 0, HALRATOR = 0XX */                                        06758000
         IF HALRATOR & "FF" = "19" THEN                                         06760000
            RETURN TRUE;                                                        06762000
      END;                                                                      06764000
                                                                                06766000
      DO;   /* CASE 1, HALRATOR = 1XX THRU 6XX */                               06768000
         IF HALRATOR & "FF" = "01" THEN                                         06770000
            CALL TARGET_ERROR(CASSIGN);                                         06772000
      END;                                                                      06774000
                                                                                06776000
      DO;   /* CASE 2, HALRATOR = 7XX */                                        06778000
         CALL TARGET_ERROR(CCOMPARISON);                                        06780000
      END;                                                                      06782000
                                                                                06784000
      DO;   /* CASE 3, HALRATOR = 8XX */                                        06786000
         CALL TARGET_ERROR(CINITIALIZATION);                                    06788000
      END;                                                                      06790000
                                                                                06792000
      DO;   /* CASE 4, HALRATOR = 9XX THRU FXX */                               06794000
         CALL TARGET_ERROR(CILLEGAL);                                           06796000
      END;                                                                      06798000
                                                                                06800000
   END;                                                                         06802000
                                                                                06804000
   IF CSE_STOP(HALRAND) THEN                                                    06806000
      RETURN TRUE;                                                              06808000
                                                                                06810000
                                                                                06812000
         /* CHECK IF STOP DUE TO NEXT HALMAT OPERATOR DOWN TREE */              06814000
                                                                                06816000
   NEXT_RATOR = GET_NEXT_RATOR(HALRAND);                                        06818000
                                                                                06820000
   DO CASE CLASS_DECODE(SHR(NEXT_RATOR, 8) & "F");                              06822000
                                                                                06824000
      DO;   /* CASE 0, HALRATOR = 0XX */                                        06826000
         IF (NEXT_RATOR = "01E") | (NEXT_RATOR = "040") | (NEXT_RATOR = "041") |06828000
            (NEXT_RATOR = "042") | (NEXT_RATOR = "043") | (NEXT_RATOR = "04A") |06830000
            (NEXT_RATOR = "04B") | (NEXT_RATOR = "051") THEN                    06832000
            RETURN TRUE;                                                        06834000
         ELSE                                                                   06836000
            IF NEXT_RATOR = "019" THEN                                          06838000
               RETURN FALSE;                                                    06840000
            ELSE                                                                06842000
               CALL TARGET_ERROR('CLASS0');                                     06844000
      END;                                                                      06846000
                                                                                06848000
      DO;   /* CASE 1, HALRATOR = 1XX THRU 6XX */                               06850000
         IF (NEXT_RATOR & "FF") = "01" THEN                                     06852000
            CALL TARGET_ERROR(CASSIGN);                                         06854000
         ELSE                                                                   06856000
            RETURN FALSE;                                                       06858000
      END;                                                                      06860000
                                                                                06862000
      DO;  /* CASE 2, HALRATOR = 7XX */                                         06864000
         CALL TARGET_ERROR(CCOMPARISON);                                        06866000
      END;                                                                      06868000
                                                                                06870000
      DO;   /* CASE 3, HALRATOR = 8XX */                                        06872000
         CALL TARGET_ERROR(CINITIALIZATION);                                    06874000
      END;                                                                      06876000
                                                                                06878000
      DO;   /* CASE 4, HALRATOR = 9XX THRU FXX */                               06880000
         CALL TARGET_ERROR(CILLEGAL);                                           06882000
      END;                                                                      06884000
                                                                                06886000
   END;                                                                         06888000
                                                                                06890000
CLOSE STOP_THIS_RATOR;                                                          06892000
                                                                                06894000
                                                                                06896000
         /* ROUTINE TO DETERMINE IF THERE ARE ANY STOP CONDITIONS FOR           06898000
            THIS NODE OF THE EXPRESSION TREE FOR ANY OF THE                     06900000
            ARGUMENTS OTHER THAN THE ONE CURRENTLY UNDER SCRUTINY */            06902000
                                                                                06904000
STOP_CONDS: FUNCTION(ARG_HEAD) BIT(1);                                          06906000
                                                                                06908000
   DECLARE                                                                      06910000
        ARG_HEAD                       BIT(16),                                 06912000
        HALRAND_QUALIFIER              BIT(4),                                  06914000
        HALRAND                        BIT(16),                                 06916000
        HALRATOR                       BIT(16),                                 06918000
        HALRATOR_#RANDS                BIT(16),                                 06920000
        I                              BIT(16),                                 06922000
        DO_ARGS                        BIT(1),                                  06924000
        CLASS_DECODE(15)               BIT(8) INITIAL                           06926000
           (0, 1, 1, 1, 1, 1, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4);                    06928000
                                                                                06930000
                                                                                06932000
         /* LOCAL ROUTINE TO ADD TO NODES TO BE CHECKED */                      06934000
                                                                                06936000
ADD_TO_NODES: PROCEDURE(HALMAT_LINE);                                           06938000
                                                                                06940000
   DECLARE                                                                      06942000
        HALMAT_LINE                    BIT(16),                                 06944000
        TEMP_CELL                      BIT(16);                                 06946000
                                                                                06948000
   IF STOP_COND_LIST = 0 THEN DO;                                               06950000
      STOP_COND_LIST = GET_FREE_CELL;                                           06952000
      CELL2(STOP_COND_LIST) = HALMAT_LINE;                                      06954000
   END;                                                                         06956000
   ELSE DO;                                                                     06958000
      IF CELL1(STOP_COND_LIST) = 0 THEN                                         06960000
         CELL1(STOP_COND_LIST) = HALMAT_LINE;                                   06962000
      ELSE DO;                                                                  06964000
         TEMP_CELL = GET_FREE_CELL;                                             06966000
         CDR_CELL(TEMP_CELL) = STOP_COND_LIST;                                  06968000
         CELL2(TEMP_CELL) = HALMAT_LINE;                                        06970000
         STOP_COND_LIST = TEMP_CELL;                                            06972000
      END;                                                                      06974000
   END;                                                                         06976000
                                                                                06978000
CLOSE ADD_TO_NODES;                                                             06980000
                                                                                06982000
                                                                                06984000
         /* ROUTINE TO RETRIEVE A NODE TO BE CHECKED */                         06986000
                                                                                06988000
GET_A_NODE: FUNCTION BIT(16);                                                   06990000
                                                                                06992000
   DECLARE TEMP_PTR BIT(16);                                                    06994000
                                                                                06996000
   IF STOP_COND_LIST = 0 THEN                                                   06998000
      RETURN 0;                                                                 07000000
                                                                                07002000
   IF CELL1(STOP_COND_LIST) ^= 0 THEN DO;                                       07004000
      TEMP_PTR = CELL1(STOP_COND_LIST);                                         07006000
      CELL1(STOP_COND_LIST) = 0;                                                07008000
      RETURN TEMP_PTR;                                                          07010000
   END;                                                                         07012000
                                                                                07014000
   TEMP_PTR = CELL2(STOP_COND_LIST);                                            07016000
   STOP_COND_LIST = CDR_CELL(STOP_COND_LIST);                                   07018000
   RETURN TEMP_PTR;                                                             07020000
                                                                                07022000
CLOSE GET_A_NODE;                                                               07024000
                                                                                07026000
                                                                                07028000
         /* ROUTINE TO DECODE A HALMAT OPERAND */                               07030000
                                                                                07032000
DECODE_HALRAND: PROCEDURE(HALMAT_LINE);                                         07034000
                                                                                07036000
   DECLARE HALMAT_LINE BIT(16);                                                 07038000
                                                                                07040000
   TEMP_MAT = HALMAT(HALMAT_LINE);                                              07042000
   IF (TEMP_MAT & 1) = 0 THEN                                                   07044000
      CALL ERRORS (CLASS_BI, 410);                                              07046000
   HALRAND_QUALIFIER = SHR(TEMP_MAT, 4) & "F";                                  07050000
   HALRAND = SHR(TEMP_MAT, 16) & "FFFF";                                        07052000
   IF (HALMAT_LINE >= 1800) & (HALRAND_QUALIFIER = VAC) THEN DO;                07054000
      IF (HALRAND & "8000") ^= 0 THEN                                           07056000
         HALRAND = HALRAND & "7FFF";                                            07058000
      ELSE                                                                      07060000
         HALRAND = HALRAND + 1800;                                              07062000
   END;                                                                         07064000
                                                                                07066000
CLOSE DECODE_HALRAND;                                                           07068000
                                                                                07070000
                                                                                07072000
         /* ROUTINE TO DECODE A HALMAT OPERATOR */                              07074000
                                                                                07076000
DECODE_HALRATOR: PROCEDURE(HALMAT_LINE);                                        07078000
                                                                                07080000
   DECLARE HALMAT_LINE BIT(16);                                                 07082000
                                                                                07084000
   TEMP_MAT = HALMAT(HALMAT_LINE);                                              07086000
   IF (TEMP_MAT & 1) ^= 0 THEN DO;                                              07088000
      TEMP_MAT = HALMAT(HALMAT_LINE - 1);                                       07090000
      IF ((TEMP_MAT & 1) ^= 0) |                                                07092000
         ( ((SHR(TEMP_MAT, 24) & "FF") ^= "3A") &                               07094000
           ((SHR(TEMP_MAT, 24) & "FF") ^= "39") ) THEN                          07096000
         CALL ERRORS (CLASS_BI, 411);                                           07098000
   END;                                                                         07102000
   HALRATOR = SHR(TEMP_MAT, 4) & "FFF";                                         07104000
   HALRATOR_#RANDS = SHR(TEMP_MAT, 16) & "FF";                                  07106000
                                                                                07108000
CLOSE DECODE_HALRATOR;                                                          07110000
                                                                                07112000
                                                                                07114000
         /* MAIN BODY OF STOP_CONDS */                                          07116000
                                                                                07118000
   DO WHILE TRUE;                                                               07120000
                                                                                07122000
      ARG_HEAD = GET_A_NODE;                                                    07124000
      IF ARG_HEAD = 0 THEN                                                      07126000
         RETURN FALSE;                                                          07128000
      CALL DECODE_HALRAND(ARG_HEAD);                                            07130000
      IF HALRAND_QUALIFIER = VAC THEN DO;                                       07132000
         CALL DECODE_HALRATOR(HALRAND);                                         07134000
         DO CASE CLASS_DECODE(SHR(HALRATOR, 8) & "F");                          07136000
                                                                                07138000
            DO;   /* CASE 0, HALRATOR = 0XX */                                  07140000
               IF HALRATOR ^= "19" THEN DO;                                     07142000
                  MAX_STOP_LEVEL = HALRAND;                                     07144000
                  RETURN TRUE;                                                  07146000
               END;                                                             07148000
               DO_ARGS = OFF;                                                   07150000
            END;                                                                07152000
                                                                                07154000
            DO;   /* CASE 1, HALRATOR = 1XX THRU 6XX */                         07156000
               IF HALRATOR & "FF" = "01" THEN                                   07158000
                  CALL TARGET_ERROR(CASSIGN);                                   07160000
               DO_ARGS = ON;                                                    07162000
            END;                                                                07164000
                                                                                07166000
            DO;   /* CASE 2, HALRATOR = 7XX */                                  07168000
               CALL TARGET_ERROR(CCOMPARISON);                                  07170000
            END;                                                                07172000
                                                                                07174000
            DO;   /* CASE 3, HALRATOR = 8XX */                                  07176000
               CALL TARGET_ERROR(CINITIALIZATION);                              07178000
            END;                                                                07180000
                                                                                07182000
            DO;   /* CASE 4, HALRATOR = 9XX THRU FXX */                         07184000
               CALL TARGET_ERROR(CILLEGAL);                                     07186000
            END;                                                                07188000
                                                                                07190000
         END;                                                                   07192000
         IF DO_ARGS THEN DO;                                                    07194000
            DO FOR I = 1 TO HALRATOR_#RANDS;                                    07196000
               CALL ADD_TO_NODES(HALRAND + I);                                  07198000
            END;                                                                07200000
         END;                                                                   07202000
      END;                                                                      07204000
                                                                                07206000
   END;                                                                         07208000
                                                                                07210000
CLOSE STOP_CONDS;                                                               07212000
                                                                                07214000
                                                                                07216000
         /* ROUTINE TO RETURN INDICATION OF A COMMUTATIVE HALMAT OPERATOR */    07218000
                                                                                07220000
COMMUTATIVE_RATOR: FUNCTION(RATOR) BIT(1);                                      07222000
                                                                                07224000
   DECLARE RATOR BIT(16);                                                       07226000
                                                                                07228000
   IF (RATOR = "102") | (RATOR = "103") |   /* BAND AND VOR */                  07230000
      (RATOR = "362") | (RATOR = "482") |   /* MADD AND VADD */                 07232000
      (RATOR = "5AB") | (RATOR = "5AD") |   /* SADD AND SSPR */                 07234000
      (RATOR = "6CB") | (RATOR = "6CD") THEN   /* IADD AND IIPR */              07236000
      RETURN TRUE;                                                              07238000
   ELSE                                                                         07240000
      RETURN FALSE;                                                             07242000
                                                                                07244000
CLOSE COMMUTATIVE_RATOR;                                                        07246000
                                                                                07248000
                                                                                07250000
         /* MAIN BODY OF GEN_TARGET */                                          07252000
                                                                                07254000
   MAX_STOP_LEVEL = 0;                                                          07256000
                                                                                07258000
   CALL DECODE_HALRAND(ARG_HEAD);                                               07260000
   IF HALRAND_QUALIFIER ^= VAC THEN                                             07262000
      RETURN;                                                                   07264000
   ELSE DO;                                                                     07266000
      CALL DECODE_HALRATOR(HALRAND);                                            07268000
      DO CASE CLASS_CASE_DECODE(SHR(HALRATOR, 8) & "F");                        07270000
                                                                                07272000
         DO;   /* CASE 0, HALRATOR = 0XX */                                     07274000
            IF HALRATOR = "19" THEN                                             07276000
               CALL MARK_TARGET(HALRAND);                                       07278000
            RETURN;                                                             07280000
         END;                                                                   07282000
                                                                                07284000
         DO;   /* CASE 1, HALRATOR = 1XX THRU 6XX */                            07286000
            IF (HALRATOR & "FF") = "01" THEN                                    07288000
               CALL TARGET_ERROR(CASSIGN);                                      07290000
         END;                                                                   07292000
                                                                                07294000
         DO;   /* CASE 2, HALRATOR = 7XX */                                     07296000
            CALL TARGET_ERROR(CCOMPARISON);                                     07298000
         END;                                                                   07300000
                                                                                07302000
         DO;   /* CASE 3, HALRATOR = 8XX */                                     07304000
            CALL TARGET_ERROR(CINITIALIZATION);                                 07306000
         END;                                                                   07308000
                                                                                07310000
         DO;   /* CASE 4, HALRATOR = 9XX THRU FXX */                            07312000
            CALL TARGET_ERROR(CILLEGAL);                                        07314000
         END;                                                                   07316000
                                                                                07318000
      END;                                                                      07320000
   END;                                                                         07322000
                                                                                07324000
   ARG_HEAD = HALRAND;                                                          07326000
   IF CSE_STOP(ARG_HEAD) THEN DO;                                               07328000
      CALL MARK_TARGET(ARG_HEAD);                                               07330000
      RETURN;                                                                   07332000
   END;                                                                         07334000
                                                                                07336000
   DO WHILE TRUE;                                                               07338000
                                                                                07340000
      CALL DECODE_HALRATOR(ARG_HEAD);                                           07342000
                                                                                07344000
      IF HALRATOR_#RANDS = 0 THEN DO;                                           07346000
         CALL MARK_TARGET(ARG_HEAD);                                            07348000
         RETURN;                                                                07350000
      END;                                                                      07352000
                                                                                07354000
      IF GEN_CODE(ARG_HEAD) = SNCS_OPCODE THEN                                  07356000
         CALL DECODE_HALRAND(ARG_HEAD);                                         07356500
      ELSE                                                                      07357000
         CALL DECODE_HALRAND(ARG_HEAD + 1);                                     07357500
                                                                                07358000
      IF HALRATOR_#RANDS = 1 THEN DO;                                           07360000
                                                                                07362000
         IF HALRAND_QUALIFIER = SYT THEN DO;                                    07364000
            CALL MARK_TARGET(ARG_HEAD);                                         07366000
            RETURN;                                                             07368000
         END;                                                                   07370000
                                                                                07372000
         IF HALRAND_QUALIFIER = VAC THEN DO;                                    07374000
                                                                                07376000
            IF STOP_THIS_RATOR THEN DO;                                         07378000
               CALL MARK_TARGET(ARG_HEAD);                                      07380000
               RETURN;                                                          07382000
            END;                                                                07384000
                                                                                07386000
         END;                                                                   07388000
                                                                                07390000
         ELSE DO;                                                               07392000
            CALL MARK_TARGET(ARG_HEAD);                                         07394000
            RETURN;                                                             07396000
         END;                                                                   07398000
                                                                                07400000
      END;                                                                      07402000
                                                                                07404000
      ELSE DO;                                                                  07406000
                                                                                07408000
         IF HALRAND_QUALIFIER = SYT THEN DO;                                    07410000
            IF COMMUTATIVE_RATOR(HALRATOR) THEN DO;                             07412000
               CALL DECODE_HALRAND(ARG_HEAD + 2);                               07414000
               IF HALRAND_QUALIFIER = VAC THEN                                  07416000
                  GO TO CONTINUE_ANALYSIS;                                      07418000
            END;                                                                07420000
            CALL MARK_TARGET(ARG_HEAD);                                         07422000
            RETURN;                                                             07424000
         END;                                                                   07426000
                                                                                07428000
         IF HALRAND_QUALIFIER = VAC THEN DO;                                    07430000
                                                                                07432000
            IF STOP_THIS_RATOR THEN DO;                                         07434000
               CALL MARK_TARGET(ARG_HEAD);                                      07436000
               RETURN;                                                          07438000
            END;                                                                07440000
            ELSE DO;                                                            07442000
               DO FOR I = 2 TO HALRATOR_#RANDS;                                 07444000
                  IF STOP_CONDS(ARG_HEAD + I) THEN                              07446000
                     GO TO EXIT_VAC_CHECK_LOOP;                                 07448000
               END;                                                             07450000
               GO TO CONTINUE_ANALYSIS;                                         07452000
            EXIT_VAC_CHECK_LOOP:                                                07454000
               IF MAX_STOP_LEVEL > HALRAND THEN DO;                             07456000
                  CALL MARK_TARGET(ARG_HEAD);                                   07458000
                  RETURN;                                                       07460000
               END;                                                             07462000
            END;                                                                07464000
                                                                                07466000
         END;                                                                   07468000
                                                                                07470000
         ELSE DO;                                                               07472000
            CALL MARK_TARGET(ARG_HEAD);                                         07474000
            RETURN;                                                             07476000
         END;                                                                   07478000
                                                                                07480000
      END;                                                                      07482000
                                                                                07484000
   CONTINUE_ANALYSIS:                                                           07486000
                                                                                07488000
      ARG_HEAD = HALRAND;                                                       07490000
                                                                                07492000
   END;                                                                         07494000
                                                                                07496000
CLOSE GEN_TARGET /* $S+ */ ;   /* $S@ */                                        07498000
                                                                                07500000
                                                                                07502000
         /* MAIN BODY OF CLASS_04 */                                            07504000
                                                                                07506000
   DO CASE OPCODE_CASE_DECODE(HALRATOR & "F");                                  07508000
                                                                                07510000
      ;   /* DO NOTHING */                                                      07512000
                                                                                07514000
      DO;   /* CASE A, HALRATOR = 04A (BFNC) */                                 07516000
                                                                                07518000
         IF (HALRATOR_TAG1 = "3A") | (HALRATOR_TAG1 = "39") THEN DO;            07520000
            GEN_CODE(HALMAT_PTR + 1) = SNCS_OPCODE;                             07522000
            CALL ADD_UVC(VAC, HALMAT_PTR + 1, HALMAT_PTR + 1);                  07524000
            AUXMAT1(HALMAT_PTR + 1) = GET_FREE_CELL;                            07526000
         END;                                                                   07528000
                                                                                07530000
         PTR_TYPE(HALMAT_PTR) = VAC;                                            07532000
         PTR(HALMAT_PTR) = HALMAT_PTR MOD 1800;                                 07534000
         GEN_CODE(HALMAT_PTR) = NOOSE_OPCODE;                                   07536000
         CALL ADD_UVC(VAC, HALMAT_PTR, HALMAT_PTR);                             07538000
                                                                                07540000
         DO FOR NUMOP = 1 TO HALRATOR_#RANDS;                                   07542000
            CALL GEN_TARGET(HALMAT_PTR + NUMOP, HALRATOR_TAG1, NUMOP);          07544000
            CALL SET_RAND_NOOSE(NUMOP);                                         07546000
         END;                                                                   07548000
                                                                                07550000
      END;                                                                      07552000
                                                                                07554000
      CALL SET_ASN_NOOSE;   /* CASE F, HALRATOR = 04F (TASN) */                 07556000
                                                                                07558000
   END;                                                                         07560000
                                                                                07562000
CLOSE CLASS_04;                                                                 07564000
                                                                                07566000
                                                                                07568000
         /* ROUTINE TO HANDLE HALMAT OPERATORS OF THE FORM "05X" */             07570000
                                                                                07572000
CLASS_05: PROCEDURE;                                                            07574000
                                                                                07576000
   DECLARE OPCODE_CASE_DECODE(15) BIT(8) INITIAL(                               07578000
                                                                                07580000
        0,                             /* CASE 0, HALRATOR = 050 */             07582000
        1,                             /* CASE 1, HALRATOR = 051 (IDEF) */      07584000
        2,                             /* CASE 2, HALRATOR = 052 (ICLS) */      07586000
        0,                             /* CASE 3, HALRATOR = 053 */             07588000
        0,                             /* CASE 4, HALRATOR = 054 */             07590000
        0,                             /* CASE 5, HALRATOR = 055 (NNEQ) */      07592000
        0,                             /* CASE 6, HALRATOR = 056 (NEQU) */      07594000
        3,                             /* CASE 7, HALRATOR = 057 (NASN) */      07596000
        0,                             /* CASE 8, HALRATOR = 058 */             07598000
        3,                             /* CASE 9, HALRATOR = 059 (PMHD) */      07600000
        0,                             /* CASE A, HALRATOR = 05A (PMAR) */      07602000
        0,                             /* CASE B, HALRATOR = 05B (PMIN) */      07604000
        0,                             /* CASE C, HALRATOR = 05C */             07606000
        0,                             /* CASE D, HALRATOR = 05D */             07608000
        0,                             /* CASE E, HALRATOR = 05E */             07610000
        0);                            /* CASE F, HALRATOR = 05F */             07612000
                                                                                07614000
                                                                                07616000
   DO CASE OPCODE_CASE_DECODE(HALRATOR & "F");                                  07618000
                                                                                07620000
      ;   /* DO NOTHING */                                                      07622000
                                                                                07624000
      CALL PUSH_BLOCK_FRAME;                                                    07626000
                                                                                07628000
      CALL POP_BLOCK_FRAME;                                                     07630000
                                                                                07632000
     CALL FLUSH_INFO;                                                           07634000
                                                                                07636000
   END;                                                                         07638000
                                                                                07640000
CLOSE CLASS_05;                                                                 07642000
                                                                                07644000
                                                                                07646000
         /* MAIN BODY OF CLASS_0 */                                             07648000
                                                                                07650000
   DO CASE SHR(HALRATOR, 4) & "F";                                              07652000
      CALL CLASS_00;   /* CASE 0, HALRATOR = 00X */                             07654000
      CALL CLASS_01;   /* CASE 1, HALRATOR = 01X */                             07656000
      CALL CLASS_02;   /* CASE 2, HALRATOR = 02X */                             07658000
      CALL CLASS_03;   /* CASE 3, HALRATOR = 03X */                             07660000
      CALL CLASS_04;   /* CASE 4, HALRATOR = 04X */                             07662000
      CALL CLASS_05;   /* CASE 5, HALRATOR = 05X */                             07664000
   END;                                                                         07666000
                                                                                07668000
CLOSE CLASS_0 /* $S+ */ ;   /* $S@ */                                           07670000
                                                                                07672000
                                                                                07674000
         /* ROUTINE TO HANDLE CLASS 1 (BIT) HALMAT OPERATORS */                 07676000
                                                                                07678000
CLASS_1: PROCEDURE;                                                             07680000
                                                                                07682000
   IF HALRATOR = "01" THEN CALL SET_ASN_NOOSE;   /* BASN OPERAOTR */            07684000
   ELSE IF ((HALRATOR & "F") = "02") & ((HALRATOR & "F0") ^= 0) THEN DO;        07686000
      /* CHECK IF ASSIGN CONTEXT FOR SUBBIT HALMAT OPERATORS */                 07688000
      IF HALRATOR_TAG1 THEN DO;                                                 07690000
         CALL SET_RAND_NOOSE(1, 1);                                             07692000
         CALL SET_SIMP_NOOSE(2);                                                07694000
      END;                                                                      07696000
      ELSE CALL HANDLE_SIMP_NOOSE;                                              07698000
   END;                                                                         07700000
   ELSE CALL HANDLE_SIMP_NOOSE;                                                 07702000
                                                                                07704000
CLOSE CLASS_1;                                                                  07706000
                                                                                07708000
                                                                                07710000
         /* ROUTINE TO HANDLE CLASS2 (CHARACTER) HALMAT OPERATORS */            07712000
                                                                                07714000
CLASS_2: PROCEDURE;                                                             07716000
                                                                                07718000
   CALL HANDLE_SIMP_OR_ASN_NOOSE;                                               07720000
                                                                                07722000
CLOSE CLASS_2;                                                                  07724000
                                                                                07726000
                                                                                07728000
         /* ROUTINE TO HANDLE CLASS3 (MATRIX) HALMAT OPERATORS */               07730000
                                                                                07732000
CLASS_3: PROCEDURE;                                                             07734000
                                                                                07736000
   CALL HANDLE_SIMP_OR_ASN_NOOSE;                                               07738000
                                                                                07740000
CLOSE CLASS_3;                                                                  07742000
                                                                                07744000
                                                                                07746000
         /* ROUTINE TO HANDLE CLASS4 (VECTOR) HALMAT OPERATORS */               07748000
                                                                                07750000
CLASS_4: PROCEDURE;                                                             07752000
                                                                                07754000
   CALL HANDLE_SIMP_OR_ASN_NOOSE;                                               07756000
                                                                                07758000
CLOSE CLASS_4;                                                                  07760000
                                                                                07762000
                                                                                07764000
         /* ROUTINE TO HANDLE CLASS5 (SCALAR) HALMAT OPERATORS */               07766000
                                                                                07768000
CLASS_5: PROCEDURE;                                                             07770000
                                                                                07772000
   CALL HANDLE_SIMP_OR_ASN_NOOSE;                                               07774000
                                                                                07776000
CLOSE CLASS_5;                                                                  07778000
                                                                                07780000
                                                                                07782000
         /* ROUTINE TO HANDLE CLASS6 (INTEGER) HALMAT OPERATORS */              07784000
                                                                                07786000
CLASS_6: PROCEDURE;                                                             07788000
                                                                                07790000
   CALL HANDLE_SIMP_OR_ASN_NOOSE;                                               07792000
                                                                                07794000
CLOSE CLASS_6;                                                                  07796000
                                                                                07798000
                                                                                07800000
         /* ROUTINE TO HANDLE CLASS7 (COMPARISON) HALMAT OPERATORS */           07802000
                                                                                07804000
CLASS_7: PROCEDURE;                                                             07806000
                                                                                07808000
   CALL HANDLE_SIMP_NOOSE;                                                      07810000
                                                                                07812000
CLOSE CLASS_7;                                                                  07814000
                                                                                07816000
                                                                                07818000
         /* MAIN BODY OF PASS1 */                                               07820000
                                                                                07822000
   THIS_HALMAT_BLOCK = ON;                                                      07824000
   NUMOP = 0;                                                                   07826000
                                                                                07828000
   DO WHILE THIS_HALMAT_BLOCK;                                                  07830000
      HALMAT_PTR = HALMAT_PTR + NUMOP;                                          07832000
      CALL DECODE_HALRATOR(HALMAT_PTR);                                         07834000
      DO CASE HALRATOR_CLASS;                                                   07836000
         CALL CLASS_0;                                                          07838000
         CALL CLASS_1;                                                          07840000
         CALL CLASS_2;                                                          07842000
         CALL CLASS_3;                                                          07844000
         CALL CLASS_4;                                                          07846000
         CALL CLASS_5;                                                          07848000
         CALL CLASS_6;                                                          07850000
         CALL CLASS_7;                                                          07852000
         ;   /* SKIP OVER INITIALIZATION OPERATORS */                           07854000
      END;                                                                      07856000
      NUMOP = HALRATOR_#RANDS + 1;   /* GO TO NEXT OPERATOR */                  07858000
   END;                                                                         07860000
                                                                                07862000
   SAVE_STACK_PTR = STACK_PTR;                                                  07864000
                                                                                07866000
   DO CASE FRAME_TYPE(STACK_PTR);                                               07868000
      ;   /* DO NOTHING */                                                      07870000
      GO TO CLOSE_DOWN_DONE;   /* DONE WHEN GET TO A BLOCK FRAME */             07872000
      CALL POP_CB_FRAME;   /* CLOSE DOWN CB FRAME */                            07874000
      CALL POP_CASE_FRAME('CLOSE DOWN');   /* CLOSE DOWN A CASE FRAME */        07876000
   END;                                                                         07878000
CLOSE_DOWN_DONE:                                                                07880000
                                                                                07882000
   STACK_PTR = SAVE_STACK_PTR;                                                  07884000
                                                                                07886000
CLOSE PASS1 /* $S+ */ ; /* $S@ */                                               07888000
