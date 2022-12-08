 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CATALOGS.xpl
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
 /* PROCEDURE NAME:  CATALOG_SRCH                                           */
 /* MEMBER NAME:     CATALOGS                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          TWIN_FLAG         BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          OP                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CSE_TAB                                                        */
 /*          FALSE                                                          */
 /*          OPTYPE                                                         */
 /*          REVERSE_OP                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE_INX                                                        */
 /* CALLED BY:                                                              */
 /*          CSE_MATCH_FOUND                                                */
 /*          GET_NODE                                                       */
 /*          STRIP_NODES                                                    */
 /*          TABLE_NODE                                                     */
 /***************************************************************************/
                                                                                02084000
 /* CHECKS TO SEE IF IN CSE_TABLE */                                            02085000
CATALOG_SRCH:                                                                   02086000
   PROCEDURE(PTR,TWIN_FLAG) BIT(16);                                            02087000
      DECLARE TWIN_FLAG BIT(8),                                                 02088000
         OP BIT(16);                                                            02089000
      DECLARE PTR BIT(16);                                                      02090000
                                                                                02091000
      IF TWIN_FLAG THEN DO;                                                     02092000
         OP = REVERSE_OP;                                                       02093000
         TWIN_FLAG = FALSE;                                                     02094000
      END;                                                                      02095000
      ELSE OP = OPTYPE;                                                         02096000
      DO WHILE PTR ^= 0;                                                        02097000
         IF OP = CSE_TAB(PTR + 1) THEN DO;   /* OPTYPE IN CATALOG*/             02098000
            CSE_INX = CSE_TAB(PTR);               /* CSE_INX POINTS TO 1ST      02099000
               CSE_TAB NODE ENTRY WHICH POINTS TO GIVEN (VALUE_NO,OPERATION)    02100000
               NODE */                                                          02101000
            RETURN PTR;                                                         02102000
         END;                                                                   02103000
         CSE_INX = PTR;                                                         02104000
 /* CSE_INX POINTS TO LAST CSE_TAB CATALOG ENTRY FOR THIS VALUE_NO              02105000
                  (WHICH POINTS TO A DIFFERENT OPERATION NODE)  */              02106000
         PTR = CSE_TAB(PTR + 2);                                                02107000
      END;                                                                      02108000
      RETURN 0;                                                                 02109000
   END CATALOG_SRCH;                                                            02110000
