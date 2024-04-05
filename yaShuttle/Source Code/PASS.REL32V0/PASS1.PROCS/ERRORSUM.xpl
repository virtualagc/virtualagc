 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORSUM.xpl
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
 /* PROCEDURE NAME:  ERROR_SUMMARY                                          */
 /* MEMBER NAME:     ERRORSUM                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ERROR_COUNT                                                    */
 /*          SAVE_LINE_#                                                    */
 /*          SAVE_SEVERITY                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /*          IND_ERR_#                                                      */
 /* CALLED BY:                                                              */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
                                                                                01554200
ERROR_SUMMARY:                                                                  01554300
   PROCEDURE;                                                                   01554400
      OUTPUT(1)='0**** SUMMARY OF ERRORS DETECTED IN PHASE 1 ****';             01554500
      DO IND_ERR_#=1 TO ERROR_COUNT;                                            01554600
         IF SAVE_LINE_#(IND_ERR_#)>0 THEN S=' AT STATEMENT '||                  01554700
            SAVE_LINE_#(IND_ERR_#);                                             01554800
         ELSE DO CASE -SAVE_LINE_#(IND_ERR_#);                                  01554900
            S=' IN PHASE 1 SET UP';                                             01555000
            S=' IN CROSS-REFERENCE';                                            01555100
            S=' IN PROGRAM LAYOUT';                                             01555200
         END;                                                                   01555300
         OUTPUT='   ERROR #'||IND_ERR_#||' OF SEVERITY '||                      01555400
            SAVE_SEVERITY(IND_ERR_#)||S;                                        01555500
      END;                                                                      01555600
   END ERROR_SUMMARY;                                                           01555700
