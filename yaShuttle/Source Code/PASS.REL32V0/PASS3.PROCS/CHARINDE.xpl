 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARINDE.xpl
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
 /* PROCEDURE NAME:  CHAR_INDEX                                             */
 /* MEMBER NAME:     CHARINDE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          STRING1           CHARACTER;                                   */
 /*          STRING2           CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L1                FIXED                                        */
 /*          I                 FIXED                                        */
 /*          L2                FIXED                                        */
 /* CALLED BY:                                                              */
 /*          SDF_NAME                                                       */
 /*          CSECT_NAME                                                     */
 /***************************************************************************/
                                                                                00134500
 /*  SUBROUTINE TO FIND OCCURANCE OF ONE CHAR STRING IN ANOTHER.   */           00134600
CHAR_INDEX:                                                                     00134700
   PROCEDURE (STRING1,STRING2) BIT(16) ;                                        00134800
      DECLARE (STRING1,STRING2) CHARACTER, (L1,L2,I) FIXED;                     00134900
      L1 = LENGTH(STRING1);                                                     00135000
      L2 = LENGTH(STRING2);                                                     00135100
      IF L2>L1 THEN RETURN -1;                                                  00135200
      DO I = 0 TO L1-L2;                                                        00135300
         IF SUBSTR(STRING1,I,L2) = STRING2 THEN RETURN I;                       00135400
      END;                                                                      00135500
      RETURN -1;                                                                00135600
   END CHAR_INDEX;                                                              00135700
