 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CATALOGV.xpl
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
 /* PROCEDURE NAME:  CATALOG_VAC                                            */
 /* MEMBER NAME:     CATALOGV                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PREV_REF          BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PTR               BIT(16)                                      */
 /*          OPTSAVE           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CATALOG_ENTRY_SIZE                                             */
 /*          FALSE                                                          */
 /*          INVARIANT_PULLED                                               */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          PREVIOUS_NODE_PTR                                              */
 /*          TOTAL_MATCH_PREV                                               */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPTYPE                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_FREE_SPACE                                                 */
 /*          CATALOG_ENTRY                                                  */
 /* CALLED BY:                                                              */
 /*          STRIP_NODES                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CATALOG_VAC <==                                                     */
 /*     ==> GET_FREE_SPACE                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*     ==> CATALOG_ENTRY                                                   */
 /*         ==> GET_EON                                                     */
 /*         ==> GET_FREE_SPACE                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /***************************************************************************/
                                                                                02162000
 /* CATALOGS OUTER TERMINAL VACS INTO CSE_TAB (TOTALLY NEW ENTRY)*/             02163000
CATALOG_VAC:                                                                    02164000
   PROCEDURE(PREV_REF) BIT(16);                                                 02165000
      DECLARE (PREV_REF,PTR,OPTSAVE) BIT(16);                                   02166000
      IF TOTAL_MATCH_PREV THEN                                                  02167000
         IF NODE2(PREVIOUS_NODE_PTR) ^= 0 THEN RETURN NODE2(PREVIOUS_NODE_PTR); 02168000
      PTR = GET_FREE_SPACE(CATALOG_ENTRY_SIZE);                                 02169000
      OPTSAVE = OPTYPE;                                                         02170000
      OPTYPE = NODE(PREV_REF);                                                  02171000
      CALL CATALOG_ENTRY(PTR,PREV_REF,INVARIANT_PULLED = FALSE);                02172000
      OPTYPE = OPTSAVE;                                                         02173000
      RETURN PTR;                                                               02174000
   END CATALOG_VAC;                                                             02175000
