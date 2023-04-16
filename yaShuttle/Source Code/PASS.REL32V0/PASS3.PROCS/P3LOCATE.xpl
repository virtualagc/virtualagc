 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   P3LOCATE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  P3_LOCATE                                              */
 /* MEMBER NAME:     P3LOCATE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          BVAR              FIXED                                        */
 /*          FLAGS             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_ADDR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF_LITTAB                                               */
 /*          BUILD_SDF                                                      */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          INITIALIZE                                                     */
 /*          OUTPUT_SDF                                                     */
 /*          PAGE_DUMP                                                      */
 /*          P3_GET_CELL                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> P3_LOCATE <==                                                       */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /***************************************************************************/
                                                                                00178000
 /* ROUTINE TO 'LOCATE' AN SDF POINTER AND ASSIGN IT TO A BASED VARIABLE */     00178100
                                                                                00178200
P3_LOCATE:                                                                      00178300
   PROCEDURE (PTR,BVAR,FLAGS);                                                  00178400
      DECLARE (PTR,BVAR) FIXED,                                                 00178500
         FLAGS BIT(8);                                                          00178600
      CALL P3_PTR_LOCATE(PTR,FLAGS);                                            00178700
      COREWORD(BVAR) = LOC_ADDR;                                                00178800
   END P3_LOCATE;                                                               00179000
