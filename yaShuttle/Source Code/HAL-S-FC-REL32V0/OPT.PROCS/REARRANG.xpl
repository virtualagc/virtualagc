 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REARRANG.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  REARRANGE_HALMAT                                       */
 /* MEMBER NAME:     REARRANG                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOOP_PULL         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FORWARD_MATCHED_MINUS  MACRO                                   */
 /*          FORWARD_MATCHED_PLUS  MACRO                                    */
 /*          FORWARD_UNMATCHED_PLUS  MACRO                                  */
 /*          HIGH              BIT(16)                                      */
 /*          NODE_PTR          BIT(16)                                      */
 /*          TAG_BIT_TEMP      FIXED                                        */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          FALSE                                                          */
 /*          FNPARITY0#                                                     */
 /*          FNPARITY1#                                                     */
 /*          IADD                                                           */
 /*          MATCHED_TAG                                                    */
 /*          MPARITY0#                                                      */
 /*          MPARITY1#                                                      */
 /*          OPTYPE                                                         */
 /*          PNPARITY0#                                                     */
 /*          PNPARITY1#                                                     */
 /*          PRESENT_HALMAT                                                 */
 /*          PRESENT_NODE_PTR                                               */
 /*          PREVIOUS_HALMAT                                                */
 /*          PREVIOUS_NODE_PTR                                              */
 /*          PREVIOUS_NODE                                                  */
 /*          REVERSE_OP                                                     */
 /*          REVERSE                                                        */
 /*          SADD                                                           */
 /*          SSPR                                                           */
 /*          TAG_BIT                                                        */
 /*          TOTAL_MATCH_PRES                                               */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          TWIN_MATCH                                                     */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FORWARD                                                        */
 /*          HALMAT_NODE_START                                              */
 /*          HALMAT_PTR                                                     */
 /*          MULTIPLE_MATCH                                                 */
 /*          N_INX                                                          */
 /*          NEW_NODE_PTR                                                   */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /*          PREVIOUS_TWIN                                                  */
 /*          TOPTAG                                                         */
 /*          TOTAL_MATCH_PREV                                               */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BOTTOM                                                         */
 /*          COLLECT_MATCHES                                                */
 /*          GET_LIT_ONE                                                    */
 /*          HALMAT_FLAG                                                    */
 /*          LAST_OP                                                        */
 /*          MOVE_LIMB                                                      */
 /*          NO_OPERANDS                                                    */
 /*          PRINT_SENTENCE                                                 */
 /*          PTR_TO_VAC                                                     */
 /*          PUT_BFNC_TWIN                                                  */
 /*          PUT_NOP                                                        */
 /*          REFERENCE                                                      */
 /*          SET_HALMAT_FLAG                                                */
 /*          SET_VAC_REF                                                    */
 /*          SWITCH                                                         */
 /*          TWIN_HALMATTED                                                 */
 /* CALLED BY:                                                              */
 /*          PULL_INVARS                                                    */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> REARRANGE_HALMAT <==                                                */
 /*     ==> GET_LIT_ONE                                                     */
 /*         ==> SAVE_LITERAL                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*     ==> LAST_OP                                                         */
 /*     ==> TWIN_HALMATTED                                                  */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*     ==> SWITCH                                                          */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*         ==> NEXT_FLAG                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*     ==> PTR_TO_VAC                                                      */
 /*     ==> REFERENCE                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> SET_HALMAT_FLAG                                                 */
 /*     ==> SET_VAC_REF                                                     */
 /*         ==> OPOP                                                        */
 /*         ==> ENTER                                                       */
 /*     ==> PUT_NOP                                                         */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> COLLECT_MATCHES                                                 */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> SET_HALMAT_FLAG                                             */
 /*         ==> FLAG_MATCHES                                                */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*             ==> FLAG_VAC_OR_LIT                                         */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> COMPARE_LITERALS                                    */
 /*                     ==> HEX                                             */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> SET_FLAG                                            */
 /*             ==> FLAG_V_N                                                */
 /*                 ==> CATALOG_PTR                                         */
 /*                 ==> VALIDITY                                            */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> SET_FLAG                                            */
 /*         ==> FLAG_NODE                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*             ==> SET_FLAG                                                */
 /*         ==> SET_WORDS                                                   */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> FORM_OPERATOR                                           */
 /*                 ==> HEX                                                 */
 /*             ==> SET_VAC_REF                                             */
 /*                 ==> OPOP                                                */
 /*                 ==> ENTER                                               */
 /*             ==> FORCE_TERMINAL                                          */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> SWITCH                                              */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*             ==> PUSH_OPERAND                                            */
 /*                 ==> ENTER                                               */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*             ==> FORCE_MATCH                                             */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> SWITCH                                              */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*     ==> BOTTOM                                                          */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*     ==> PUT_BFNC_TWIN                                                   */
 /***************************************************************************/
 /* DATE     WHO  RLS        DR/CR #  DESCRIPTION                           */
 /* 06/03/99 JAC  30V0/15V0  DR111313 BS122 ERROR FOR MULTIDIMENSIONAL      */
 /*                                   ASSIGNMENTS                           */
 /***************************************************************************/
                                                                                03123000
 /* REARRANGES HALMAT AND UPDATES TABLES WHEN A MATCH FOUND*/                   03124000
REARRANGE_HALMAT:                                                               03125000
   PROCEDURE(LOOP_PULL);                                                        03126000
      DECLARE LOOP_PULL BIT(8);                                                 03126010
      DECLARE (TEMP,HIGH) BIT(16);          /*DR111313*/                        03127000
      DECLARE NODE_PTR BIT(16);                                                 03128000
      DECLARE TAG_BIT_TEMP FIXED;                                               03128010
                                                                                03129000
                                                                                03130000
 /* FOR REVERSE AND FORWARD: */                                                 03131000
      DECLARE FORWARD_UNMATCHED_PLUS LITERALLY 'FNPARITY0# > MPARITY1#' ,       03132000
         FORWARD_MATCHED_MINUS LITERALLY 'MPARITY0# > 0',                       03133000
         FORWARD_MATCHED_PLUS LITERALLY  'MPARITY1# > 0';                       03134000
                                                                                03135000
      IF TRACE THEN OUTPUT = 'REARRANGE_HALMAT: PRESENT_HALMAT '||              03136000
         PRESENT_HALMAT||' PREVIOUS_HALMAT '||PREVIOUS_HALMAT;                  03137000
      FORWARD = FALSE;                                                          03138000
                                                                                03139000
      PREVIOUS_TWIN = TWIN_HALMATTED(LAST_OP(PREVIOUS_HALMAT));                 03140000
                                                                                03141000
      TOPTAG = HALMAT_FLAG(PREVIOUS_HALMAT) ;                                   03142000
 /* COULD BE FLAG ON OPERAND FOR TWIN*/                                         03143000
                                                                                03144000
      IF TOPTAG THEN                                                            03146000
         IF PREVIOUS_TWIN THEN                                                  03147000
         TOPTAG = ( (NODE(PREVIOUS_NODE) & MATCHED_TAG) = MATCHED_TAG);         03148000
 /* FOR SIN COS SIN CASE*/                                                      03149000
                                                                                03151000
      TOTAL_MATCH_PREV = FALSE;                                                 03152000
      IF  PNPARITY0# + PNPARITY1# = CSE_FOUND_INX - 1 THEN DO;                  03153000
         TOTAL_MATCH_PREV = TRUE;                                               03154000
         IF TWIN_MATCH THEN NEW_NODE_PTR = PRESENT_NODE_PTR;                    03155000
         ELSE                                                                   03156000
            NEW_NODE_PTR = PREVIOUS_NODE_PTR;                                   03157000
      END;                                                                      03158000
      ELSE IF TOTAL_MATCH_PRES THEN NEW_NODE_PTR = PRESENT_NODE_PTR;            03159000
                                                                                03160000
                                                                                03162000
      IF TOTAL_MATCH_PREV THEN DO;                                              03163000
         HALMAT_PTR,HALMAT_NODE_START = PREVIOUS_HALMAT;                        03164000
      END;                                                                      03166000
      ELSE DO;                                                                  03167000
         CALL COLLECT_MATCHES(PREVIOUS_HALMAT,PNPARITY0#,PNPARITY1#);           03168000
         NODE(NEW_NODE_PTR) = PTR_TO_VAC(HALMAT_PTR);                           03169000
         IF ^ TOTAL_MATCH_PRES THEN N_INX = N_INX + 1;                          03170000
      END;                                                                      03171000
                                                                                03172000
 /* NODE(NEW_NODE_PTR) MUST BE SET UP BEFORE SET_VAC_REF IS CALLED              03173000
         WITH TAG OF 1    */                                                    03174000
                                                                                03175000
                                                                                03176000
      MULTIPLE_MATCH = TOTAL_MATCH_PREV & TOPTAG  ;                             03178000
                                                                                03180000
                                                                                03181000
      IF TOTAL_MATCH_PREV THEN IF ^MULTIPLE_MATCH AND ^PREVIOUS_TWIN THEN       03182000
         CALL SET_HALMAT_FLAG(PREVIOUS_HALMAT);                                 03183000
                                                                                03184000
      IF TWIN_MATCH THEN NODE_PTR = PREVIOUS_NODE_PTR;                          03185000
      ELSE NODE_PTR = NEW_NODE_PTR;                                             03186000
                                                                                03187000
      IF ^MULTIPLE_MATCH AND ^PREVIOUS_TWIN THEN                                03188000
         CALL SET_VAC_REF(REFERENCE(HALMAT_PTR),NODE_PTR,1);                    03189000
                                                                                03190000
 /* POINTER TO "PTR_TO_VAC" WORD IN NODE LIST*/                                 03191000
                                                                                03192000
      IF TWIN_MATCH THEN CALL PUT_BFNC_TWIN(PREVIOUS_HALMAT);                   03193000
      ELSE IF ^PREVIOUS_TWIN THEN                                               03194000
         IF TOPTAG THEN CALL SET_HALMAT_FLAG(PREVIOUS_HALMAT);/*RESTORE TAG*/   03195000
                                                                                03196000
      HP = HALMAT_PTR;                                                          03197000
      IF WATCH THEN IF ^MULTIPLE_MATCH THEN                                     03198000
         CALL PRINT_SENTENCE(HALMAT_NODE_START);                                03199000
                                                                                03200000
                                                                                03200010
      IF LOOP_PULL THEN DO;                                                     03200020
         LOOP_PULL = FALSE;                                                     03200030
         RETURN;                                                                03200040
      END;                                                                      03200050
                                                                                03200060
      FORWARD = TRUE;                                                           03201000
                                                                                03202000
      IF TOTAL_MATCH_PRES THEN HALMAT_PTR = PRESENT_HALMAT;                     03203000
      ELSE DO;                                                                  03204000
         CALL COLLECT_MATCHES(PRESENT_HALMAT,FNPARITY0#,FNPARITY1#);            03205000
      END;                                                                      03206000
                                                                                03207000
                                                                                03209000
      TAG_BIT_TEMP = TAG_BIT & OPR(HALMAT_PTR);                                 03209010
      CALL PUT_NOP(HALMAT_PTR);                                                 03210000
      TEMP = REFERENCE(HALMAT_PTR);                                             03211000
      IF REVERSE THEN DO;                                                       03212000
         IF  FORWARD_UNMATCHED_PLUS | ^FORWARD_MATCHED_MINUS THEN DO;           03213000
            IF FORWARD_MATCHED_PLUS & FORWARD_MATCHED_MINUS THEN DO;            03214000
               CALL SWITCH(TEMP,TEMP + 1);                                      03215000
               CALL SET_VAC_REF(TEMP + 1,NEW_NODE_PTR,1);                       03216000
               OPR(TEMP - 1) = OPR(TEMP - 1) & "FFFF 000F" | SHL(REVERSE_OP,4); 03217000
            END;                                                                03218000
            ELSE CALL SET_VAC_REF(TEMP,NEW_NODE_PTR,1); /*MPARITY1# = 0*/       03219000
         END;                                /*FNPARITY0# > MPARITY1#*/         03220000
                                                                                03221000
         ELSE DO;             /* FNPARITY0# = MPARITY1#; THUS MPARITY1# > 0*/   03222000
 /* MUST GENERATE NEGATE OR RECIPROCAL*/                                        03223000
            IF OPTYPE = SSPR THEN DO;    /* RECIPROCAL*/                        03224000
               OPR(HALMAT_PTR) = "25AE0";                                       03225000
               OPR(HALMAT_PTR + 1) = SHL(GET_LIT_ONE,16) | "51";                03226000
               CALL SET_VAC_REF(HALMAT_PTR + 2,NEW_NODE_PTR,1,1);               03227000
            END;                                                                03228000
            ELSE DO;              /* NEGATE*/                                   03229000
               IF OPTYPE = SADD THEN OPR(HALMAT_PTR) = "15B00";                 03230000
               ELSE IF OPTYPE = IADD THEN OPR(HALMAT_PTR) = "16D00";            03231000
               ELSE      /* VECTOR/MATRIX NEGATE*/                              03232000
                  OPR(HALMAT_PTR) = "10440" | SHL(OPTYPE,4) & "F000"            03233000
                  | TAG_BIT_TEMP;  /* PASSED OUT FLAG FOR VM LOOPS*/            03233010
                                                                                03234000
               CALL SET_VAC_REF(HALMAT_PTR + 1,NEW_NODE_PTR,1,1);               03235000
            END;                                                                03236000
            TEMP = HALMAT_PTR;                                                  03237000
         END;                                                                   03238000
      END;                                                                      03239000
      ELSE DO;                                                                  03240000
         CALL SET_VAC_REF(TEMP,NEW_NODE_PTR,1);                                 03241000
      END;                                                                      03242000
      IF TEMP < (NODE(NODE_PTR) & "FFFF") THEN DO;  /* FORWARD REFERENCE*/      03243000
         HP = LAST_OP(HP);                                                      03243010
         HIGH = BOTTOM(HP,TEMP);                                                03244000
         CALL MOVE_LIMB(HALMAT_PTR,HIGH,HP + NO_OPERANDS(HP) + 1 - HIGH);       03245000
      END;                                                                      03246000
                                                                                03247000
      IF WATCH THEN CALL PRINT_SENTENCE(HALMAT_NODE_START);                     03250000
   END REARRANGE_HALMAT;                                                        03251000
