 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CATALOG.xpl
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
 /* PROCEDURE NAME:  CATALOG                                                */
 /* MEMBER NAME:     CATALOG                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          SYT_POINT         BIT(16)                                      */
 /*          NEW_OP            BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CATALOG_ENTRY_SIZE                                             */
 /*          CSE_INX                                                        */
 /*          NODE_BEGINNING                                                 */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_FREE_SPACE                                                 */
 /*          CATALOG_ENTRY                                                  */
 /*          SET_CATALOG_PTR                                                */
 /*          SET_VALIDITY                                                   */
 /* CALLED BY:                                                              */
 /*          GET_NODE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CATALOG <==                                                         */
 /*     ==> SET_CATALOG_PTR                                                 */
 /*     ==> SET_VALIDITY                                                    */
 /*     ==> GET_FREE_SPACE                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*     ==> CATALOG_ENTRY                                                   */
 /*         ==> GET_EON                                                     */
 /*         ==> GET_FREE_SPACE                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /***************************************************************************/
                                                                                02123000
 /********************************************************************          02124000
                                                                                02125000
                         CSE_TAB FORMATS                                        02126000
                                                                                02127000
   CATALOG ENTRY:                                                               02128000
         #1    --PTR TO FIRST NODE ENTRY IN CSE_TAB FOR THIS OPCODE             02129000
         #2    --OPTYPE                                                         02130000
         #3    --PTR TO NEXT CATALOG ENTRY FOR DIFFERENT OPCODE BUT SAME VAL_NO,02131000
                 ETC.  0 FOR LAST CATALOG ENTRY FOR THIS VAL_NO, ETC.           02132000
                                                                                02133000
   NODE ENTRY:                                                                  02134000
         #1    --PTR TO OPTYPE OF A NODE                                        02135000
         #2    --PTR TO NEXT NODE ENTRY IN CSE_TAB FOR THIS OPTYPE AND VAL_NO,  02136000
                 ETC.  0 FOR LAST ENTRY.                                        02137000
         #3    --LEVEL(5 BITS) BLOCK#(11 BITS)                                  02137010
                                                                                02138000
********************************************************************/           02139000
                                                                                02140000
 /* SETS UP AN INITIAL ENTRY IN CSE TABLES FOR VALUE NO, ETC.*/                 02141000
CATALOG:                                                                        02142000
   PROCEDURE (SYT_POINT,NEW_OP);                                                02143000
      DECLARE TEMP BIT(16);                                                     02144000
      DECLARE                                                                   02145000
         (SYT_POINT,NEW_OP) BIT(16);                                            02146000
      IF TRACE THEN DO;                                                         02147000
         OUTPUT = 'CATALOG:  SYT_POINT '||SYT_POINT||' NEW_OP '||NEW_OP;        02148000
      END;                                                                      02149000
      TEMP = GET_FREE_SPACE(CATALOG_ENTRY_SIZE);                                02150000
      IF NEW_OP = 0 THEN DO;                                                    02151000
         CALL SET_CATALOG_PTR(SYT_POINT,TEMP);                                  02152000
         CALL SET_VALIDITY(SYT_POINT,TRUE);                                     02153000
         CALL CATALOG_ENTRY(TEMP,NODE_BEGINNING);                               02154000
      END;                                                                      02155000
      ELSE DO;                                                                  02156000
         NEW_OP = 0;                                                            02157000
         CSE_TAB(CSE_INX + 2) = TEMP;                                           02158000
         CALL CATALOG_ENTRY(TEMP,NODE_BEGINNING);                               02159000
      END;                                                                      02160000
   END CATALOG;                                                                 02161000
