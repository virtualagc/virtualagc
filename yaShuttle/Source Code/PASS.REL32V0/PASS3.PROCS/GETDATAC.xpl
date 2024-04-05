 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETDATAC.xpl
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
 /* PROCEDURE NAME:  GET_DATA_CELL                                          */
 /* MEMBER NAME:     GETDATAC                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          LENGTH            BIT(16)                                      */
 /*          BVAR              FIXED                                        */
 /*          FLAGS             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_PTR                                                        */
 /*          FREE_CHAIN                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          P3_GET_CELL                                                    */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF_LITTAB                                               */
 /*          BUILD_SDF                                                      */
 /*          INITIALIZE                                                     */
 /*          REFORMAT_HALMAT                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_DATA_CELL <==                                                   */
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
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /* -----------------                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR#     DESCRIPTION                              */
 /* -------- ---  ----- --------   ---------------------------------------- */
 /*                                                                         */
 /* 01/27/94 TEV  26V0/ DR106822   PHASE 3 INTERNAL ERROR                   */
 /*               10V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00198200
 /* ROUTINE TO ALLOCATE NON-DIRECTORY DATA CELLS */                             00198300
                                                                                00198400
GET_DATA_CELL:                                                                  00198500
   PROCEDURE (LENGTH,BVAR,FLAGS) FIXED;                                         00198600
      DECLARE BVAR FIXED,                                                       00198700
/******* DR106822 - TEV - 1/27/94 ***********/
/* CHANGE LENGTH TO A FIXED (SIGNED 32-BIT) */
/* DATATYPE TO AVOID BIT(16) OVERFLOW.      */
         LENGTH FIXED,                                                          00198800
/******* END DR106822 **********************/
         FLAGS BIT(8);                                                          00198900
      CALL P3_GET_CELL(FREE_CHAIN,LENGTH,BVAR,FLAGS);                           00199000
      RETURN LOC_PTR;                                                           00199100
   END GET_DATA_CELL;                                                           00199200
