 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTN.xpl
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
 /* PROCEDURE NAME:  PUTN                                                   */
 /* MEMBER NAME:     PUTN                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          OFFSET            BIT(16)                                      */
 /*          CORE_ADDR         FIXED                                        */
 /*          COUNT             BIT(16)                                      */
 /*          FLAGS             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_ADDR                                                       */
 /*          MODF                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MOVE                                                           */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /*          BUILD_SDF                                                      */
 /*          P3_GET_CELL                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUTN <==                                                            */
 /*     ==> MOVE                                                            */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /***************************************************************************/
                                                                                00180300
 /* MOVE 'COUNT' BYTES FROM XPL VARIABLES TO SDF LOCATIONS */                   00180400
                                                                                00180600
PUTN:                                                                           00180700
   PROCEDURE (PTR,OFFSET,CORE_ADDR,COUNT,FLAGS);                                00180800
      DECLARE (PTR,CORE_ADDR) FIXED, (OFFSET,COUNT) BIT(16), FLAGS BIT(8);      00180900
      FLAGS = FLAGS | MODF;                                                     00181300
      CALL P3_PTR_LOCATE(PTR,FLAGS);                                            00181400
      CALL MOVE(COUNT,CORE_ADDR,LOC_ADDR+OFFSET);                               00181500
   END PUTN;                                                                    00182800
