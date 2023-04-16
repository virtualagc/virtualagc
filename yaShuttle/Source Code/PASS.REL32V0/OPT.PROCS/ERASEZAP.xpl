 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERASEZAP.xpl
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
 /* PROCEDURE NAME:  ERASE_ZAPS                                             */
 /* MEMBER NAME:     ERASEZAP                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          STACK_TRACE                                                    */
 /*          STT#                                                           */
 /*          TSAPS                                                          */
 /*          VAL_SIZE                                                       */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OBPS                                                           */
 /* CALLED BY:                                                              */
 /*          EXIT_CHECK                                                     */
 /*          CHICKEN_OUT                                                    */
 /*          PUSH_ZAP_STACK                                                 */
 /***************************************************************************/
                                                                                02206280
 /* ERASES ALL ZAPS FOR THIS LEVEL*/                                            02206290
ERASE_ZAPS:                                                                     02206300
   PROCEDURE;                                                                   02206310
      DECLARE K BIT(16);                                                        02206320
      IF STACK_TRACE THEN OUTPUT = 'ERASE_ZAPS:  '||STT#;                       02206330
      DO FOR K = 0 TO VAL_SIZE - 1;                                             02206340
         ZAPS(K) = 0;                                                           02206350
      END;                                                                      02206360
   END ERASE_ZAPS;                                                              02206370
