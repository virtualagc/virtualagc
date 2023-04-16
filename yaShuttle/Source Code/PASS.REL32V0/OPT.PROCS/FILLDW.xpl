 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FILLDW.xpl
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
 /* PROCEDURE NAME:  FILL_DW                                                */
 /* MEMBER NAME:     FILLDW                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LPTR              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          COMBINED_LITERALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FILL_DW <==                                                         */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
                                                                                00716000
FILL_DW:                                                                        00717000
   PROCEDURE(LOC);                                                              00718000
      DECLARE (LOC,LPTR) BIT(16);                                               00719000
      LPTR=GET_LITERAL(LOC);                                                    00720000
      DW(2)=LIT2(LPTR);                                                         00721000
      DW(3)=LIT3(LPTR);                                                         00722000
   END FILL_DW;                                                                 00723000
