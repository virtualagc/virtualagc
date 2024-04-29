 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COPINESS.xpl
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
 /* PROCEDURE NAME:  COPINESS                                               */
 /* MEMBER NAME:     COPINESS                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          L                 BIT(16)                                      */
 /*          R                 BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          T                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXT_P                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00879200
COPINESS:                                                                       00879300
   PROCEDURE (L,R) BIT(8);                                                      00879400
      DECLARE (L,R,T) BIT(16);                                                  00879500
      L=EXT_P(PTR(L));                                                          00879600
      T=EXT_P(PTR(R));                                                          00879700
      IF T=0 THEN  DO;                                                          00879800
         IF L=0 THEN RETURN 0;                                                  00879900
         ELSE DO;                                                               00880000
            EXT_P(PTR(R))=L;                                                    00880100
            RETURN 2;                                                           00880200
         END;                                                                   00880300
      END;                                                                      00880400
      IF L=0 THEN RETURN 4;                                                     00880500
      IF L^=T THEN DO;                                                          00880600
         EXT_P(PTR(R))=L;                                                       00880700
         RETURN 3;                                                              00880800
      END;                                                                      00880900
      RETURN 0;                                                                 00881000
   END COPINESS;                                                                00881100
