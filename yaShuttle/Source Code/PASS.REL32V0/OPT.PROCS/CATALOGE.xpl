 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CATALOGE.xpl
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
 /* PROCEDURE NAME:  CATALOG_ENTRY                                          */
 /* MEMBER NAME:     CATALOGE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          TEMP              BIT(16)                                      */
 /*          NODE_BEGINNING    BIT(16)                                      */
 /*          PREVIOUS_LEVEL    BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NODE_PTR          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          FALSE                                                          */
 /*          LEVEL                                                          */
 /*          NODE_ENTRY_SIZE                                                */
 /*          NODE2                                                          */
 /*          OPTYPE                                                         */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_EON                                                        */
 /*          GET_FREE_SPACE                                                 */
 /* CALLED BY:                                                              */
 /*          CATALOG                                                        */
 /*          CATALOG_VAC                                                    */
 /*          TABLE_NODE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CATALOG_ENTRY <==                                                   */
 /*     ==> GET_EON                                                         */
 /*     ==> GET_FREE_SPACE                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /***************************************************************************/
                                                                                02111000
 /* PUT NODE ENTRY INTO CSE_TAB*/                                               02112000
CATALOG_ENTRY:                                                                  02113000
   PROCEDURE(TEMP,NODE_BEGINNING,PREVIOUS_LEVEL);                               02114000
      DECLARE PREVIOUS_LEVEL BIT(8);                                            02114010
      DECLARE (TEMP,NODE_PTR,NODE_BEGINNING) BIT(16);                           02115000
      NODE_PTR,CSE_TAB(TEMP) = GET_FREE_SPACE(NODE_ENTRY_SIZE); /* SETS UP      02116000
                                          CATALOG ENTRY*/                       02117000
                                                                                02118000
      CSE_TAB(TEMP + 1) = OPTYPE;                                               02119000
      CSE_TAB(TEMP + 2),CSE_TAB(NODE_PTR + 1) = 0;                              02120000
      CSE_TAB(NODE_PTR) = NODE_BEGINNING; /*SETS UP FIRST NODE PTR TO OPTYPE*/  02121000
      IF PREVIOUS_LEVEL THEN                                                    02121010
         CSE_TAB(NODE_PTR + 2) = NODE2(GET_EON(NODE_BEGINNING,1));              02121020
 /* LEVEL & BLOCK# FROM THIS NODE*/                                             02121023
      ELSE                                                                      02121030
         CSE_TAB(NODE_PTR + 2) = SHL(LEVEL,11) | BLOCK#;                        02121040
      PREVIOUS_LEVEL = FALSE;                                                   02121050
   END CATALOG_ENTRY;                                                           02122000
