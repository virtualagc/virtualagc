 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   P3DISP.xpl
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
 /* PROCEDURE NAME:  P3_DISP                                                */
 /* MEMBER NAME:     P3DISP                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          FLAGS             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MODF                                                           */
 /*          OLD_NDX                                                        */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PAD_DISP                                                       */
 /*          RESV_CNT                                                       */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /*          BUILD_SDF                                                      */
 /*          OUTPUT_SDF                                                     */
 /*          P3_GET_CELL                                                    */
 /*          P3_PTR_LOCATE                                                  */
 /***************************************************************************/
                                                                                00163900
 /* ROUTINE TO SET SDF PAGE DISPOSITION PARAMETERS */                           00164000
                                                                                00164100
P3_DISP:                                                                        00164200
   PROCEDURE (FLAGS);                                                           00164300
      DECLARE FLAGS BIT(8);                                                     00164400
      IF (FLAGS&MODF) ^= 0 THEN                                                 00164500
         PAD_DISP(OLD_NDX) = PAD_DISP(OLD_NDX)|"4000";                          00164600
      IF (FLAGS&RESV) ^= 0 THEN DO;                                             00164700
         PAD_DISP(OLD_NDX) = PAD_DISP(OLD_NDX) + 1;                             00164800
         RESV_CNT = RESV_CNT + 1;                                               00164900
      END;                                                                      00165000
      ELSE IF (FLAGS&RELS) ^= 0 THEN DO;                                        00165100
         PAD_DISP(OLD_NDX) = PAD_DISP(OLD_NDX) - 1;                             00165200
         RESV_CNT = RESV_CNT - 1;                                               00165300
      END;                                                                      00165400
   END P3_DISP;                                                                 00165600
