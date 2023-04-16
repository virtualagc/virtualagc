 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SINGLEVA.xpl
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
 /* PROCEDURE NAME:  SINGLE_VALUED                                          */
 /* MEMBER NAME:     SINGLEVA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*       BIT(8)                                                            */
 /* INPUT PARAMETERS:                                                       */
 /*       PTR               BIT(16)                                         */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       FALSE                                SYM_TYPE                     */
 /*       NAME_FLAG                            SYT_ARRAY                    */
 /*       PACKTYPE                             SYT_FLAGS                    */
 /*       SYM_ARRAY                            SYT_TYPE                     */
 /*       SYM_FLAGS                            TRUE                         */
 /*       SYM_TAB                                                           */
 /* CALLED BY:                                                              */
 /*       GENERATE                                                          */
 /***************************************************************************/
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */  00350000
 /*  ------------------                                                     */  00360000
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */  00370000
 /*                                                                             00380000
 /*12/23/92 PMA    8V0  *       MERGED 7V0 AND 24V0 COMPILERS.              */
 /*                             * REFERENCE 24V0 CR/DRS                     */
 /*                                                                         */
 /**************************************************************************/   00420000
 /*#DNAME -- MOVED SINGLE_VALUED HERE FOR USE IN YCON_TO_ZCON */                 1048320
 /* ROUTINE TO DETERMINE IF SPECIFIED SYMBOL IS SINGLE VALUED */                 1048320
SINGLE_VALUED:                                                                   1048330
      PROCEDURE(PTR) BIT(1);                                                     1048340
         DECLARE PTR BIT(16);                                                    1048350
         IF (SYT_FLAGS(PTR) & NAME_FLAG) ^= 0 THEN RETURN TRUE;                  1048360
         IF PACKTYPE(SYT_TYPE(PTR)) THEN                                         1048370
            RETURN SYT_ARRAY(PTR) = 0;                                           1048380
         ELSE RETURN FALSE;                                                      1048390
      END SINGLE_VALUED;                                                         1048400
