 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ZERON.xpl
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
 /* PROCEDURE NAME:  ZERON                                                  */
 /* MEMBER NAME:     ZERON                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          OFFSET            BIT(16)                                      */
 /*          COUNT             BIT(16)                                      */
 /*          FLAGS             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_ADDR                                                       */
 /*          MODF                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ZERO_CORE                                                      */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ZERON <==                                                           */
 /*     ==> ZERO_CORE                                                       */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /***************************************************************************/
                                                                                00182900
 /* ZERO 'COUNT' BYTES OF THE SDF STARTING AT A SPECIFIED SDF LOCATION */       00183000
                                                                                00183200
ZERON:                                                                          00183300
   PROCEDURE (PTR,OFFSET,COUNT,FLAGS);                                          00183400
      DECLARE PTR FIXED,                                                        00183500
         (OFFSET,COUNT) BIT(16),                                                00183600
         FLAGS BIT(8);                                                          00183700
      FLAGS = FLAGS | MODF;                                                     00183800
      CALL P3_PTR_LOCATE(PTR,FLAGS);                                            00183900
      CALL ZERO_CORE(LOC_ADDR+OFFSET,COUNT);                                    00184000
   END ZERON;                                                                   00184200
