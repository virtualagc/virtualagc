 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORCETER.xpl
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
 /* PROCEDURE NAME:  FORCE_TERMINAL                                         */
 /* MEMBER NAME:     FORCETER                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ORIG              BIT(16)                                      */
 /*          INVERSE           BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FLAG                                                           */
 /*          HALMAT_NODE_END                                                */
 /*          OPR                                                            */
 /*          TRACE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          NEXT_FLAG                                                      */
 /*          SWITCH                                                         */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          SET_WORDS                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORCE_TERMINAL <==                                                  */
 /*     ==> NEXT_FLAG                                                       */
 /*         ==> NO_OPERANDS                                                 */
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
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                02855000
 /* FORCES TERMINAL OPERAND TO ORIG*/                                           02856000
FORCE_TERMINAL:                                                                 02857000
   PROCEDURE(ORIG,INVERSE);                                                     02858000
      DECLARE (ORIG,PTR) BIT(16),                                               02859000
         INVERSE BIT(8);                                                        02860000
      IF TRACE THEN OUTPUT = 'FORCE_TERMINAL: '||ORIG||','||INVERSE;            02861000
      PTR = ORIG;                                                               02862000
      DO WHILE PTR <= HALMAT_NODE_END;                                          02863000
         IF ^OPR(PTR) THEN PTR = NEXT_FLAG(PTR) + 1;                            02864000
         DO CASE INVERSE;                                                       02865000
            DO;                                                                 02866000
               IF (FLAG(PTR) & "4") = 0 THEN DO;                                02867000
                  IF TERMINAL(PTR,1) THEN DO;                                   02868000
                     CALL SWITCH(ORIG,PTR);                                     02869000
                     RETURN;                                                    02870000
                  END;                                                          02871000
               END;                                                             02872000
               PTR = PTR + 1;                                                   02873000
            END;                                                                02874000
            DO ;                                                                02875000
               PTR = NEXT_FLAG(PTR,2);                                          02876000
               IF OPR(PTR) THEN IF TERMINAL(PTR,1) THEN DO;                     02877000
                  CALL SWITCH(ORIG,PTR);                                        02878000
                  INVERSE = 0;                                                  02879000
                  RETURN;                                                       02880000
               END;                                                             02881000
               PTR = PTR + 1;                                                   02882000
            END;                                                                02883000
         END; /* DO CASE*/                                                      02884000
      END; /* DO WHILE*/                                                        02885000
   END FORCE_TERMINAL;                                                          02886000
