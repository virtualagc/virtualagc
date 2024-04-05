 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   KOREWORD.xpl
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
 /* PROCEDURE NAME:  KOREWORD                                               */
 /* MEMBER NAME:     KOREWORD                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          MEM_ADDR          FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TMP               FIXED                                        */
 /*          NODE_B            BIT(8)                                       */
 /* CALLED BY:                                                              */
 /*          OUTPUT_SDF                                                     */
 /***************************************************************************/
KOREWORD:                                                                       00134410
   PROCEDURE (MEM_ADDR) FIXED;                                                  00134415
      DECLARE (MEM_ADDR,TMP) FIXED;                                             00134420
      BASED NODE_B BIT(8);                                                      00134425
      COREWORD(ADDR(NODE_B)) = ADDR(TMP);                                       00134430
      NODE_B(0) = COREBYTE(MEM_ADDR);                                           00134435
      NODE_B(1) = COREBYTE(MEM_ADDR + 1);                                       00134440
      NODE_B(2) = COREBYTE(MEM_ADDR + 2);                                       00134445
      NODE_B(3) = COREBYTE(MEM_ADDR + 3);                                       00134450
      RETURN TMP;                                                               00134455
   END KOREWORD;                                                                00134460
