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
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          A                 BIT(16)                                      */
 /*          B                 BIT(16)                                      */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF_LITTAB                                               */
 /*          BUILD_SDF                                                      */
 /*          REFORMAT_HALMAT                                                */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /* -----------------                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR#     DESCRIPTION                              */
 /* -------- ---  ----- --------   ---------------------------------------- */
 /*                                                                         */
 /* 01/27/94 TEV  26V0/ DR106822   PHASE 3 INTERNAL ERROR                   */
 /*               10V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00139710
MIN:                                                                            00139720
/****** DR106822 - TEV - 1/27/94 ********/
/* CHANGE THE INPUT AND OUTPUT TO FIXED */
/* DATATYPE TO AVOID BIT(16) OVERFLOW   */
   PROCEDURE(A,B) FIXED;                                                        00139730
      DECLARE (A,B) FIXED;                                                      00139740
/****** END DR106822 ********************/
      IF A<B THEN RETURN A;                                                     00139750
      ELSE RETURN B;                                                            00139760
   END MIN;                                                                     00139770
