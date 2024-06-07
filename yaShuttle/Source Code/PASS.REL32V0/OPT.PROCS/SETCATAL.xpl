 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETCATAL.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_CATALOG_PTR                                        */
 /* MEMBER NAME:     SETCATAL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          VAL               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CAT_ARRAY                                                      */
 /*          CATALOG_ARRAY                                                  */
 /*          LEVEL                                                          */
 /*          REL                                                            */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PAR_SYM                                                        */
 /* CALLED BY:                                                              */
 /*          ASSIGNMENT                                                     */
 /*          CATALOG                                                        */
 /***************************************************************************/
                                                                                00638080
 /* SETS CATALOG_PTR*/                                                          00638090
SET_CATALOG_PTR:                                                                00638100
   PROCEDURE(PTR,VAL);                                                          00638110
      DECLARE (PTR,VAL) BIT(16);                                                00638120
      CATALOG_ARRAY(REL(PTR)) = VAL;                                            00638130
   END SET_CATALOG_PTR;                                                         00638140
