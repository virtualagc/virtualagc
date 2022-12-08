 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SUCCESSO.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SUCCESSOR                                              */
 /* MEMBER NAME:     SUCCESSO                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_LINK2                                                      */
 /*          SYM_TYPE                                                       */
 /*          SYT_LINK2                                                      */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /*          KIN                                                            */
 /*          TEMPL_INX                                                      */
 /* CALLED BY:                                                              */
 /*          STRUCTURE_ADVANCE                                              */
 /***************************************************************************/
                                                                                00154500
 /* ROUTINE TO ADVANCE TO NEXT NODE IN A STRUCTURE TEMPLATE  */                 00154600
SUCCESSOR:                                                                      00154700
   PROCEDURE(LOC) BIT(16);                                                      00154800
      DECLARE (LOC) BIT(16);                                                    00154900
      KIN = SYT_LINK2(LOC);                                                     00155000
      IF KIN >= 0 THEN RETURN KIN;                                              00155100
      IF SYT_TYPE(-KIN) = TEMPL_NAME THEN DO;                                   00155200
         KIN = -KIN;                                                            00155300
         IF SYT_LINK2(KIN) = 0 THEN RETURN -KIN;                                00155400
         LOC = KIN;                                                             00155401
         KIN = SYT_LINK2(KIN);                                                  00155500
         SYT_LINK2(LOC) = 0;                                                    00155501
         TEMPL_INX = TEMPL_INX -1;                                              00155600
         RETURN -KIN;                                                           00155700
      END;                                                                      00155800
      RETURN KIN;                                                               00155900
   END SUCCESSOR;                                                               00156000
