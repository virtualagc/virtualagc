 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETDIRCE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  GET_DIR_CELL                                           */
 /* MEMBER NAME:     GETDIRCE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          LENGTH            BIT(16)                                      */
 /*          BVAR              FIXED                                        */
 /*          FLAGS             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_PTR                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          P3_GET_CELL                                                    */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_DIR_CELL <==                                                    */
 /*     ==> P3_GET_CELL                                                     */
 /*         ==> P3_DISP                                                     */
 /*         ==> P3_LOCATE                                                   */
 /*             ==> P3_PTR_LOCATE                                           */
 /*                 ==> HEX8                                                */
 /*                 ==> ZERO_CORE                                           */
 /*                 ==> P3_DISP                                             */
 /*                 ==> PAGING_STRATEGY                                     */
 /*         ==> PUTN                                                        */
 /*             ==> MOVE                                                    */
 /*             ==> P3_PTR_LOCATE                                           */
 /*                 ==> HEX8                                                */
 /*                 ==> ZERO_CORE                                           */
 /*                 ==> P3_DISP                                             */
 /*                 ==> PAGING_STRATEGY                                     */
 /***************************************************************************/
                                                                                00197100
 /* ROUTINE TO ALLOCATE DIRECTORY DATA CELLS */                                 00197200
                                                                                00197300
GET_DIR_CELL:                                                                   00197400
   PROCEDURE (LENGTH,BVAR,FLAGS) FIXED;                                         00197500
      DECLARE BVAR FIXED,                                                       00197600
         LENGTH BIT(16),                                                        00197700
         FLAGS BIT(8);                                                          00197800
      CALL P3_GET_CELL(0,LENGTH,BVAR,FLAGS);                                    00197900
      RETURN LOC_PTR;                                                           00198000
   END GET_DIR_CELL;                                                            00198100
