 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LASTOP.xpl
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
 /* PROCEDURE NAME:  LAST_OP                                                */
 /* MEMBER NAME:     LASTOP                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          BOTTOM                                                         */
 /*          CHECK_ADJACENT_LOOPS                                           */
 /*          EXPAND_DSUB                                                    */
 /*          GET_ADLP                                                       */
 /*          GROUP_CSE                                                      */
 /*          PROCESS_LABEL                                                  */
 /*          PUSH_HALMAT                                                    */
 /*          PUT_SHAPING_ARGS                                               */
 /*          REARRANGE_HALMAT                                               */
 /*          RELOCATE_HALMAT                                                */
 /*          SETUP_REARRANGE                                                */
 /*          SWITCH                                                         */
 /***************************************************************************/
                                                                                00909000
 /* RETURNS LAST HALMAT OPERATOR*/                                              00910000
LAST_OP:                                                                        00911000
   PROCEDURE(PTR);                                                              00912000
      DECLARE PTR BIT(16);                                                      00913000
      DO WHILE OPR(PTR);                                                        00914000
         PTR = PTR - 1;                                                         00915000
      END;                                                                      00916000
      RETURN PTR;                                                               00917000
   END LAST_OP;                                                                 00918000
