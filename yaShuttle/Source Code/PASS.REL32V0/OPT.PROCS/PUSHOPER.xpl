 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHOPER.xpl
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
 /* PROCEDURE NAME:  PUSH_OPERAND                                           */
 /* MEMBER NAME:     PUSHOPER                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ORIG              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HALMAT_NODE_END                                                */
 /*          TRACE                                                          */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FLAG                                                           */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER                                                          */
 /*          HALMAT_FLAG                                                    */
 /*          NEXT_FLAG                                                      */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          SET_WORDS                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_OPERAND <==                                                    */
 /*     ==> ENTER                                                           */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /*     ==> NEXT_FLAG                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /***************************************************************************/
                                                                                02887000
 /* FORCES OPERAND FORWARD TO NON_TERMINAL OPERAND*/                            02888000
PUSH_OPERAND:                                                                   02889000
   PROCEDURE(ORIG);                                                             02890000
      DECLARE (ORIG,PTR) BIT(16);                                               02891000
      IF ^TERMINAL(ORIG,1) THEN DO;                                             02892000
         IF TRACE THEN OUTPUT = 'PUSH_OPERAND: '||ORIG||' GOES TO '||ORIG;      02893000
         RETURN;                                                                02894000
      END;                                                                      02895000
      PTR = ORIG + 1;                                                           02896000
      DO WHILE PTR <= HALMAT_NODE_END;                                          02897000
         IF ^OPR(PTR) THEN PTR=NEXT_FLAG(PTR) + 1;                              02898000
         IF ^TERMINAL(PTR,1) THEN DO; /* INNER VAC*/                            02899000
            OPR(PTR) = OPR(ORIG);                                               02900000
            FLAG(PTR) = FLAG(ORIG);                                             02901000
            IF HALMAT_FLAG(PTR) THEN CALL ENTER(PTR);                           02902000
            IF TRACE THEN OUTPUT = 'PUSH_OPERAND: '||ORIG|| ' GOES TO '||PTR;   02903000
            RETURN;                                                             02904000
         END;                                                                   02905000
         ELSE PTR = PTR + 1;                                                    02906000
      END;                                                                      02907000
      IF WATCH THEN OUTPUT = 'PUSH_OPERAND: '||ORIG|| 'FAILED';                 02908000
   END PUSH_OPERAND;                                                            02909000
