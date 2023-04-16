 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TRAN.xpl
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
 /* PROCEDURE NAME:  TRAN                                                   */
 /* MEMBER NAME:     TRAN                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR1              FIXED                                        */
 /*          OFFSET1           BIT(16)                                      */
 /*          PTR2              FIXED                                        */
 /*          OFFSET2           BIT(16)                                      */
 /*          COUNT             BIT(16)                                      */
 /*          FLAGS             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADDR_TEMP         FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_ADDR                                                       */
 /*          MODF                                                           */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MOVE                                                           */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TRAN <==                                                            */
 /*     ==> MOVE                                                            */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /***************************************************************************/
                                                                                00184300
 /* MOVE 'COUNT' BYTES FROM ONE SDF LOCATION TO ANOTHER */                      00184400
                                                                                00184600
TRAN:                                                                           00184700
   PROCEDURE (PTR1,OFFSET1,PTR2,OFFSET2,COUNT,FLAGS);                           00184800
      DECLARE (PTR1,PTR2,ADDR_TEMP) FIXED, (OFFSET1,OFFSET2,COUNT) BIT(16),     00184900
         FLAGS BIT(8);                                                          00184905
      CALL P3_PTR_LOCATE(PTR1,RESV);                                            00185300
      ADDR_TEMP = LOC_ADDR;                                                     00185400
      FLAGS = FLAGS | MODF;                                                     00185500
      CALL P3_PTR_LOCATE(PTR2,FLAGS);                                           00185600
      CALL MOVE(COUNT,ADDR_TEMP+OFFSET1,LOC_ADDR+OFFSET2);                      00185700
      CALL P3_PTR_LOCATE(PTR1,RELS);                                            00185705
   END TRAN;                                                                    00187200
