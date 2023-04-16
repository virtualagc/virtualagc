 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INSTRUCT.xpl
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
/* PROCEDURE NAME:  INSTRUCTION                                            */
/* MEMBER NAME:     INSTRUCT                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          OPCODE            BIT(16)                                      */
/*          TAG               BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          SUBCODE           BIT(16)                                      */
/*          DUMMY             CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          INDIRECTION                                                    */
/*          BLANK                                                          */
/*          OPER                                                           */
/*          OPNAMES                                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          CHAR_INDEX                                                     */
/*          PAD                                                            */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          OBJECT_GENERATOR                                               */
/*          PRINTSUMMARY                                                   */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> INSTRUCTION <==                                                     */
/*     ==> CHAR_INDEX                                                      */
/*     ==> PAD                                                             */
/***************************************************************************/
/* REVISION HISTORY                                                        */
/* ----------------                                                        */
/*   DATE   NAME  REL   CR/DR #  TITLE                                     */
/*                                                                         */
/* 01/05/98 DCP  29V0/  CR12940  ENHANCE COMPILER LISTING                  */
/*               14V0                                                      */
/***************************************************************************/
                                                                                00595000
 /* ROUTINE TO GENERATE INSTRUCTION MNEMONIC FROM INTERNAL CODE  */             00595500
INSTRUCTION:                                                                    00596000
   PROCEDURE(OPCODE, TAG, ASM_LST) CHARACTER;                                   00596500
      DECLARE (OPCODE, TAG, SUBCODE) BIT(16), DUMMY CHARACTER;                  00597000
      DECLARE ASM_LST BIT(1);
      SUBCODE = SHR(OPCODE,6);                                                  00598000
      DUMMY = SUBSTR(OPNAMES(SUBCODE), OPER(OPCODE), 4);                        00598500
      IF OPCODE = BCF THEN DO;                 /*CR12940*/
         IF ASM_LST THEN DO;                   /*CR12940*/
            IF (RHS & "2") = "2" THEN DO;      /*CR12940*/
               DUMMY = 'BCB ';                 /*CR12940*/
               BCB_COUNT = BCB_COUNT + 1;      /*CR12940*/
            END;                               /*CR12940*/
         END;                                  /*CR12940*/
         ELSE DUMMY = 'BC  ';                  /*CR12940*/
      END;                                     /*CR12940*/
      IF TAG > 0 THEN DO;                                                       00599000
         SUBCODE = CHAR_INDEX(DUMMY, BLANK);                                    00599500
         IF SUBCODE < 0 THEN DUMMY = DUMMY || INDIRECTION(TAG);                 00600000
         ELSE DUMMY = SUBSTR(DUMMY, 0, SUBCODE) || INDIRECTION(TAG);            00600500
      END;                                                                      00601000
      TAG = 0;                                                                  00601500
      ASM_LST = FALSE;                         /*CR12940*/
      RETURN PAD(DUMMY, 6);                    /*CR12940*/                      00602000
   END INSTRUCTION;                                                             00602500
