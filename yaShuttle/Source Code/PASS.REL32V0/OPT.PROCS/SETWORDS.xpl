 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETWORDS.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_WORDS                                              */
 /* MEMBER NAME:     SETWORDS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OPPARITY          BIT(8)                                       */
 /*          MATCHED_OPS       BIT(8)                                       */
 /*          TERMINAL#         BIT(16)                                      */
 /*          TAG               BIT(8)                                       */
 /*          SPECIAL           BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INVERSE                                                        */
 /*          POINT1                                                         */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          H_INX                                                          */
 /*          FLAG                                                           */
 /*          LAST_INX                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORCE_TERMINAL                                                 */
 /*          FORCE_MATCH                                                    */
 /*          FORM_OPERATOR                                                  */
 /*          NEXT_FLAG                                                      */
 /*          PUSH_OPERAND                                                   */
 /*          SET_VAC_REF                                                    */
 /* CALLED BY:                                                              */
 /*          COLLECT_MATCHES                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_WORDS <==                                                       */
 /*     ==> NEXT_FLAG                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*     ==> FORM_OPERATOR                                                   */
 /*         ==> HEX                                                         */
 /*     ==> SET_VAC_REF                                                     */
 /*         ==> OPOP                                                        */
 /*         ==> ENTER                                                       */
 /*     ==> FORCE_TERMINAL                                                  */
 /*         ==> NEXT_FLAG                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> SWITCH                                                      */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> ENTER                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> PUSH_OPERAND                                                    */
 /*         ==> ENTER                                                       */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> NEXT_FLAG                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> FORCE_MATCH                                                     */
 /*         ==> NEXT_FLAG                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> SWITCH                                                      */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> ENTER                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /* 11/21/95 JMP  27V1  DR106732 FIX UNEXPECTED BS122 ERROR PROBLEM         */
 /*                                                                         */
 /***************************************************************************/
                                                                                02926000
 /*REPLACES HALMAT OPERATOR AND OPERAND WORDS*/                                 02927000
SET_WORDS:                                                                      02928000
   PROCEDURE(OPPARITY,MATCHED_OPS,TERMINAL#,TAG,SPECIAL);                       02929000
      DECLARE TERMINAL# BIT(16),                                                02930000
         (OPPARITY,MATCHED_OPS,TAG,SPECIAL) BIT(8);                             02931000
      DECLARE SAVE_INX BIT(16);                                   /* DR106732 */
      IF TRACE THEN DO;                                                         02932000
         OUTPUT = 'SET_WORDS:  H_INX '||H_INX||' OPPARITY '||OPPARITY||         02933000
            ' MATCHED_OPS ' ||MATCHED_OPS;                                      02934000
         OUTPUT = '            TERMINAL# '||TERMINAL#||' TAG '||TAG||' SPECIAL '02935000
            ||SPECIAL;                                                          02936000
      END;                                                                      02937000
      H_INX = NEXT_FLAG(H_INX);                                                 02938000
      CALL FORM_OPERATOR(H_INX,OPPARITY,TAG);                                   02939000
      IF SPECIAL THEN DO;                                                       02940000
         SAVE_INX = LAST_INX;                                     /* DR106732 */
         IF MATCHED_OPS THEN CALL FORCE_MATCH(H_INX + 1,0);                     02941000
         ELSE CALL FORCE_TERMINAL(H_INX + 1,0);                                 02942000
         IF TERMINAL# THEN DO;   /* ONE PARITY1 OPERAND*/                       02943000
            IF MATCHED_OPS THEN CALL FORCE_MATCH(H_INX + 2,1);                  02944000
            ELSE CALL FORCE_TERMINAL(H_INX + 2,1);                              02945000
         END;                                                                   02946000
         ELSE DO;                                                               02947000
            CALL PUSH_OPERAND(H_INX + 2);                                       02948000
            CALL SET_VAC_REF(H_INX + 2,SAVE_INX);                 /* DR106732 */02949000
         END;                                                                   02950000
      END; /*SPECIAL*/                                                          02951000
      ELSE DO CASE TERMINAL#;                                                   02952000
         DO;     /* NO TERMINALS*/                                              02953000
            CALL PUSH_OPERAND(H_INX + 1);                                       02954000
            CALL PUSH_OPERAND(H_INX + 2);                                       02955000
            CALL SET_VAC_REF(H_INX + 1,POINT1);                                 02956000
            CALL SET_VAC_REF(H_INX + 2,LAST_INX);                               02957000
         END; /* NO TERMINALS*/                                                 02958000
         DO;  /* ONE TERMINAL*/                                                 02959000
            CALL PUSH_OPERAND(H_INX + 1);                                       02960000
            CALL SET_VAC_REF(H_INX + 1,LAST_INX);                               02961000
            IF MATCHED_OPS THEN CALL FORCE_MATCH(H_INX + 2,INVERSE);            02962000
            ELSE CALL FORCE_TERMINAL(H_INX + 2,INVERSE);                        02963000
         END;    /* 1 TERM*/                                                    02964000
         DO;     /* 2 TERM*/                                                    02965000
            IF MATCHED_OPS THEN DO;                                             02966000
               CALL FORCE_MATCH(H_INX + 1,INVERSE);                             02967000
               CALL FORCE_MATCH(H_INX + 2,INVERSE);                             02968000
            END;                                                                02969000
            ELSE DO;                                                            02970000
               CALL FORCE_TERMINAL(H_INX + 1,INVERSE);                          02971000
               CALL FORCE_TERMINAL(H_INX + 2,INVERSE);                          02972000
            END;                                                                02973000
         END;     /* 2 TERM*/                                                   02974000
      END;  /* DO CASE*/                                                        02975000
      LAST_INX = H_INX;                                                         02976000
      FLAG(H_INX), FLAG(H_INX + 1),FLAG(H_INX + 2) = 0;                         02977000
      TAG,SPECIAL = 0;                                                          02978000
      H_INX = H_INX + 3;                                                        02979000
   END SET_WORDS;                                                               02980000
