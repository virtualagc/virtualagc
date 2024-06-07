 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COLLECTM.xpl
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
 /* PROCEDURE NAME:  COLLECT_MATCHES                                        */
 /* MEMBER NAME:     COLLECTM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          H_PTR             BIT(16)                                      */
 /*          NPARITY0#         BIT(16)                                      */
 /*          NPARITY1#         BIT(16)                                      */
 /*          ELIMINATE_DIVIDES BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          E                 BIT(8)                                       */
 /*          GROUP             LABEL                                        */
 /*          PARITY0#          BIT(16)                                      */
 /*          PARITY1#          BIT(16)                                      */
 /*          POINT2            BIT(16)                                      */
 /*          P0                BIT(16)                                      */
 /*          P1                BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          FORWARD                                                        */
 /*          HALMAT_NODE_START                                              */
 /*          MPARITY0#                                                      */
 /*          MPARITY1#                                                      */
 /*          REVERSE                                                        */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          HALMAT_PTR                                                     */
 /*          H_INX                                                          */
 /*          INVERSE                                                        */
 /*          LAST_INX                                                       */
 /*          POINT1                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FLAG_MATCHES                                                   */
 /*          FLAG_NODE                                                      */
 /*          PRINT_SENTENCE                                                 */
 /*          SET_HALMAT_FLAG                                                */
 /*          SET_WORDS                                                      */
 /* CALLED BY:                                                              */
 /*          ELIMINATE_DIVIDES                                              */
 /*          COLLAPSE_LITERALS                                              */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COLLECT_MATCHES <==                                                 */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> SET_HALMAT_FLAG                                                 */
 /*     ==> FLAG_MATCHES                                                    */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /*         ==> FLAG_VAC_OR_LIT                                             */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> COMPARE_LITERALS                                        */
 /*                 ==> HEX                                                 */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> SET_FLAG                                                */
 /*         ==> FLAG_V_N                                                    */
 /*             ==> CATALOG_PTR                                             */
 /*             ==> VALIDITY                                                */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> SET_FLAG                                                */
 /*     ==> FLAG_NODE                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
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
 /*         ==> SET_FLAG                                                    */
 /*     ==> SET_WORDS                                                       */
 /*         ==> NEXT_FLAG                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> FORM_OPERATOR                                               */
 /*             ==> HEX                                                     */
 /*         ==> SET_VAC_REF                                                 */
 /*             ==> OPOP                                                    */
 /*             ==> ENTER                                                   */
 /*         ==> FORCE_TERMINAL                                              */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> SWITCH                                                  */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> ENTER                                               */
 /*                 ==> LAST_OP                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*         ==> PUSH_OPERAND                                                */
 /*             ==> ENTER                                                   */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*         ==> FORCE_MATCH                                                 */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> SWITCH                                                  */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> ENTER                                               */
 /*                 ==> LAST_OP                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                02981000
 /* GROUPS MATCHED OPERANDS AT THE BEGINNING OF THE NODE IN THE HALMAT*/        02982000
                                                                                02983000
 /* FORWARD = 1 FOR 2ND OCCURRENCE OF CSE; REVERSE = 1 IF (+ -), ETC., PARITY   02984000
                                                                  REVERSED*/    02985000
                                                                                02986000
COLLECT_MATCHES:                                                                02987000
   PROCEDURE(H_PTR,NPARITY0#,NPARITY1#,ELIMINATE_DIVIDES);                      02988000
      DECLARE TEMP BIT(16);                                                     02989000
      DECLARE(H_PTR,POINT2,P0,P1) BIT(16),                                      02990000
         (PARITY0#,PARITY1#) BIT(16),                                           02991000
         (E,ELIMINATE_DIVIDES) BIT(8),                                          02992000
         (NPARITY0#,NPARITY1#) BIT(16);                                         02993000
      IF TRACE THEN DO;                                                         02995000
         OUTPUT = 'COLLECT_MATCHES: '|| H_PTR;                                  02996000
      END;                                                                      02997000
      E = ELIMINATE_DIVIDES = FALSE;                                            02998000
      CALL FLAG_NODE(H_PTR);                                                    02999000
      IF E THEN CALL FLAG_MATCHES;                                              03000000
      ELSE IF WATCH THEN CALL PRINT_SENTENCE(HALMAT_NODE_START);                03001000
      LAST_INX, HALMAT_PTR, H_INX = HALMAT_NODE_START;                          03002000
      IF FORWARD & REVERSE THEN DO;                                             03003000
         PARITY0# = MPARITY1#;                                                  03004000
         PARITY1# = MPARITY0#;                                                  03005000
      END;                                                                      03006000
      ELSE DO;                                                                  03007000
         PARITY0# = MPARITY0#;                                                  03008000
         PARITY1# = MPARITY1#;                                                  03009000
      END;                                                                      03010000
      INVERSE = FALSE;                                                          03011000
                                                                                03012000
 /* COMPUTES A SUM OR PRODUCT OF LIKE PARITIED TERMS*/                          03013000
GROUP:                                                                          03014000
      PROCEDURE(PARITY#,MATCHED_OPS) BIT(16);                                   03015000
         DECLARE PARITY# BIT(16);                                               03016000
         DECLARE MATCHED_OPS BIT(8);                                            03017000
         IF PARITY# > 1 THEN DO;                                                03018000
            CALL SET_WORDS(0,MATCHED_OPS,2);                                    03019000
            DO FOR TEMP = 3 TO PARITY#;                                         03020000
               CALL SET_WORDS(0,MATCHED_OPS,1);                                 03021000
            END;                                                                03022000
         END; /* PARITY# > 1*/                                                  03023000
         RETURN LAST_INX;                                                       03024000
      END GROUP;                                                                03025000
                                                                                03026000
                                                                                03027000
      POINT1 = GROUP(PARITY0#,E);                                               03028000
      INVERSE = TRUE;                                                           03029000
      CALL GROUP(PARITY1#,E);                                                   03030000
                                                                                03031000
      IF PARITY0# > 1 THEN DO;                                                  03032000
         IF PARITY1# >= 1 THEN DO;                                              03033000
            CALL SET_WORDS(1,PARITY1# = 1 & E,PARITY1# = 1,E);                  03034000
 /* SETS MATCHED PART*/                                                         03035000
            HALMAT_PTR = LAST_INX;                                              03036000
         END;  /*  >1,>1 */                                                     03037000
         ELSE DO;                                                               03038000
            HALMAT_PTR = LAST_INX;   /* PARITY1 = 0 */                          03039000
            CALL SET_HALMAT_FLAG(HALMAT_PTR);                                   03040000
         END;   /*  >1,=0   */                                                  03041000
      END;     /* PARITY0# >1    */                                             03042000
      ELSE IF PARITY0# = 1 THEN DO;      /*  =1,>1 AND =1,=1    */              03043000
         CALL SET_WORDS(1,E,PARITY1# = 1,E,1);                                  03044000
         HALMAT_PTR = LAST_INX;                                                 03045000
      END;                                                                      03046000
      ELSE DO;                                                                  03047000
         HALMAT_PTR = LAST_INX;  /* PARITY0# = 0*/                              03048000
         CALL SET_HALMAT_FLAG(HALMAT_PTR);                                      03049000
      END;                                                                      03050000
      IF ELIMINATE_DIVIDES THEN DO;                                             03051000
         ELIMINATE_DIVIDES = FALSE;                                             03052000
         RETURN;                                                                03053000
      END;                                                                      03054000
      INVERSE = FALSE;                                                          03055000
                                                                                03056000
      P0 = NPARITY0# - PARITY0#;                                                03057000
      P1 = NPARITY1# - PARITY1#;                                                03058000
                                                                                03059000
      IF PARITY0# > 0 THEN DO;                                                  03060000
         DO FOR TEMP = PARITY0# + 1 TO NPARITY0#;                               03061000
            CALL SET_WORDS(0,0,1);                                              03062000
         END;                                                                   03063000
         POINT1 = LAST_INX;                                                     03064000
         INVERSE = TRUE;                                                        03065000
         IF P1 > 0 THEN DO;                                                     03066000
            IF P1 > 1 THEN CALL GROUP(P1,0);                                    03067000
            CALL SET_WORDS(1,0,P1 = 1);                                         03068000
         END;                                                                   03069000
      END; /* PARITY0# > 0*/                                                    03070000
                                                                                03071000
      ELSE DO;            /* PARITY0# = 0*/                                     03072000
         INVERSE = TRUE;                                                        03073000
         DO FOR TEMP = 1 TO P1;                                                 03074000
            CALL SET_WORDS(0,0,1);                                              03075000
         END;                                                                   03076000
         POINT2 = LAST_INX;                                                     03077000
         INVERSE = FALSE;                                                       03078000
         IF P0 > 1 THEN DO;                                                     03079000
            CALL GROUP(P0,0);                                                   03080000
            POINT1 = LAST_INX;                                                  03081000
            LAST_INX = POINT2;                                                  03082000
            CALL SET_WORDS(1,0,0);                                              03083000
         END;                                                                   03084000
                                                                                03085000
         ELSE CALL SET_WORDS(1,0,0,0,1); /* P0 = 1 SINCE P0 CANNOT BE 0*/       03086000
      END;                                                                      03087000
   END COLLECT_MATCHES;                                                         03088000
