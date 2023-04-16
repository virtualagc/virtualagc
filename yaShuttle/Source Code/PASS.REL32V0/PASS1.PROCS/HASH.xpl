 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HASH.xpl
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
 /* PROCEDURE NAME:  HASH                                                   */
 /* MEMBER NAME:     HASH                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          BCD               CHARACTER;                                   */
 /*          HASHSIZE          FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          HASH              FIXED                                        */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /* CALLED BY:                                                              */
 /*          IDENTIFY                                                       */
 /*          INTERPRET_ACCESS_FILE                                          */
 /*          STREAM                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00288000
                                                                                00288100
HASH:                                                                           00288200
   PROCEDURE (BCD, HASHSIZE);                                                   00288300
      DECLARE (HASHSIZE, HASH, I, J) FIXED, BCD CHARACTER;                      00288400
                                                                                00288500
      HASH = 0;                                                                 00288600
      J = LENGTH(BCD) - 1;                                                      00288700
      IF J > 22 THEN J = 22;   /*  AVOID OVERFLOW  */                           00288800
      DO I = 0 TO J;                                                            00288900
         HASH = BYTE(BCD,I)+SHL(HASH,1);                                        00289000
      END;                                                                      00289100
      RETURN HASH MOD HASHSIZE;                                                 00289200
   END HASH;                                                                    00289300
