 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EXTRACT4.xpl
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
 /* PROCEDURE NAME:  EXTRACT4                                               */
 /* MEMBER NAME:     EXTRACT4                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          OFFSET            BIT(16)                                      */
 /*          FLAGS             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FULL_TEMP         FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_ADDR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EXTRACT4 <==                                                        */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /***************************************************************************/
                                                                                00179100
 /* FUNCTION TO EXTRACT A FULL WORD FROM AN SDF LOCATION */                     00179200
                                                                                00179300
EXTRACT4:                                                                       00179400
   PROCEDURE (PTR,OFFSET,FLAGS) FIXED;                                          00179500
      DECLARE (PTR,FULL_TEMP) FIXED,                                            00179600
         OFFSET BIT(16),                                                        00179700
         FLAGS BIT(8);                                                          00179800
      CALL P3_PTR_LOCATE(PTR,FLAGS);                                            00179900
      FULL_TEMP = COREWORD(LOC_ADDR+OFFSET);                                    00180000
      RETURN FULL_TEMP;                                                         00180100
   END EXTRACT4;                                                                00180200
