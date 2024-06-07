 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTSHAPI.xpl
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
 /* PROCEDURE NAME:  PUT_SHAPING_ARGS                                       */
 /* MEMBER NAME:     PUTSHAPI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          XN                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          SFAR                                                           */
 /*          SFST                                                           */
 /*          TRACE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BUMP_D_N                                                       */
 /*          LAST_OP                                                        */
 /*          OPOP                                                           */
 /*          VAC_OR_XPT                                                     */
 /*          XNEST                                                          */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUT_SHAPING_ARGS <==                                                */
 /*     ==> OPOP                                                            */
 /*     ==> XNEST                                                           */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> LAST_OP                                                         */
 /***************************************************************************/
                                                                                03339000
 /* ADDS SHAPING ARGS TO DIFF_NODE.  OPR(PTR) IS SHAPING FN*/                   03339010
PUT_SHAPING_ARGS:                                                               03339020
   PROCEDURE(PTR);                                                              03339030
      DECLARE XN FIXED,                                                         03339040
         PTR BIT(16);                                                           03339050
      IF TRACE THEN OUTPUT = 'PUT_SHAPING_ARGS:  ' || PTR;                      03339060
                                                                                03339070
      XN = XNEST(PTR);                                                          03339080
                                                                                03339090
      DO WHILE OPOP(PTR) ^= SFST OR XNEST(PTR) ^= XN;                           03339100
         IF OPOP(PTR) = SFAR AND XNEST(PTR) = XN THEN                           03339110
            IF VAC_OR_XPT(PTR + 1) THEN                                         03339120
            CALL BUMP_D_N(SHR(OPR(PTR + 1),16));                                03339130
         PTR = LAST_OP(PTR - 1);                                                03339140
      END;                                                                      03339150
      IF TRACE THEN OUTPUT = '   END PUT_SHAPING_ARGS.';                        03339160
   END PUT_SHAPING_ARGS;                                                        03339170
