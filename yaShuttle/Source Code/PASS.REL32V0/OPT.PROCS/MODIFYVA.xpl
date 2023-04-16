 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MODIFYVA.xpl
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
 /* PROCEDURE NAME:  MODIFY_VALIDITY                                        */
 /* MEMBER NAME:     MODIFYVA                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          OBPS                                                           */
 /*          SYT_USED                                                       */
 /*          SYT_WORDS                                                      */
 /*          TSAPS                                                          */
 /*          VAL_ARRAY                                                      */
 /*          VALIDITY_ARRAY                                                 */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          VAL_TABLE                                                      */
 /* CALLED BY:                                                              */
 /*          POP_STACK                                                      */
 /***************************************************************************/
                                                                                02206040
                                                                                02206050
                                                                                02206060
                                                                                02206070
 /* ROUTINES FOR STACK MANAGEMENT*/                                             02206080
                                                                                02206090
                                                                                02206100
 /****************************************************************/             02206110
                                                                                02206120
 /* CHANGES CURRENT!! INDEX VALIDITY BY CURRENT!!INDEX ZAPS*/                   02206130
MODIFY_VALIDITY:                                                                02206140
   PROCEDURE;                                                                   02206150
      DECLARE K BIT(16);                                                        02206160
      IF ^ZAPS(0) THEN DO FOR K = 0 TO SYT_WORDS;                               02206170
                                                                                02206180
 /* ZAP ENCOUNTERED.  ALL INVALID*/                                             02206190
                                                                                02206200
         VALIDITY_ARRAY(K) = VALIDITY_ARRAY(K) & ^ZAPS(K);                      02206210
      END;                                                                      02206220
                                                                                02206230
      ELSE DO FOR K = 0 TO SYT_WORDS;                                           02206240
         VALIDITY_ARRAY(K) = 0;                                                 02206250
      END;                                                                      02206260
   END MODIFY_VALIDITY;                                                         02206270
