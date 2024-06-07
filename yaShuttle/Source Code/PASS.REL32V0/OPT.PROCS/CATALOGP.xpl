 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CATALOGP.xpl
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
 /* PROCEDURE NAME:  CATALOG_PTR                                            */
 /* MEMBER NAME:     CATALOGP                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CAT_ARRAY                                                      */
 /*          CATALOG_ARRAY                                                  */
 /*          LEVEL                                                          */
 /*          PAR_SYM                                                        */
 /*          REL                                                            */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /* CALLED BY:                                                              */
 /*          ASSIGNMENT                                                     */
 /*          CSE_TAB_DUMP                                                   */
 /*          DUMP_VALIDS                                                    */
 /*          FLAG_V_N                                                       */
 /*          GET_NODE                                                       */
 /***************************************************************************/
                                                                                00637640
                                                                                00638000
                                                                                00638010
 /* GETS CATALOG_PTR*/                                                          00638020
CATALOG_PTR:                                                                    00638030
   PROCEDURE(PTR) BIT(16);                                                      00638040
      DECLARE PTR BIT(16);                                                      00638050
      RETURN CATALOG_ARRAY(REL(PTR));                                           00638060
   END CATALOG_PTR;                                                             00638070
