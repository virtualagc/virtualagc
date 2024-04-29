 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MIN.xpl
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
 /* PROCEDURE NAME:  MIN                                                    */
 /* MEMBER NAME:     MIN                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /* CALLED BY:                                                              */
 /*          OUTPUT_WRITER                                                  */
 /*          INITIALIZATION                                                 */
 /*          SCAN                                                           */
 /*          STREAM                                                         */
 /***************************************************************************/
                                                                                00261629
                                                                                00261630
 /* INCLUDE VMEM DECLARES:  $%VMEM1  */                                         00261631
 /* AND $%VMEM2   */                                                            00261632
                                                                                00261633
 /*        P R O C E D U R E S                             */                   00261634
                                                                                00261635
 /*   INCLUDE VMEM ROUTINES:  $%VMEM3   */                                      00261636
                                                                                00261637
MIN:PROCEDURE(I,J) FIXED;                                                       00261700
      DECLARE (I,J) FIXED;                                                      00261800
      IF I<J THEN RETURN I;                                                     00261900
      RETURN J;                                                                 00262000
   END MIN;                                                                     00262100
