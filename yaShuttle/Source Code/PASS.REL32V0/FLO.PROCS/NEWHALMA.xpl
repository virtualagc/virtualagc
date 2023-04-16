 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWHALMA.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  NEW_HALMAT_BLOCK                                       */
 /* MEMBER NAME:     NEWHALMA                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CODEFILE                                                       */
 /*          HALMAT_PTR                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK#                                                         */
 /*          CURCBLK                                                        */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ZERO_CORE                                                      */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          INITIALIZE                                                     */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> NEW_HALMAT_BLOCK <==                                                */
 /*     ==> ZERO_CORE                                                       */
 /***************************************************************************/
 /* INCLUDE VMEM DECLARES: $%VMEM1 */                                           00128200
                                                                                00128300
 /* AND $%VMEM2 */                                                              00128400
                                                                                00128500
 /* INCLUDE VMEM ROUTINES: $%VMEM3 */                                           00128600
                                                                                00128700
   BASED VMEM_B BIT(8),                                                         00128800
      VMEM_H BIT(16),                                                           00128900
      VMEM_F FIXED;                                                             00129000
                                                                                00129100
                                                                                00129200
 /* ROUTINE TO GET NEXT BLOCK OF HALMAT */                                      00129300
NEW_HALMAT_BLOCK:                                                               00129400
   PROCEDURE;                                                                   00129500
      BLOCK# = BLOCK# + 1;                                                      00129600
      OPR = FILE(CODEFILE,CURCBLK);                                             00129700
      CURCBLK = CURCBLK + 1;                                                    00129800
      CALL ZERO_CORE(ADDR(HALMAT_PTR),7200);                                    00129900
   END NEW_HALMAT_BLOCK;                                                        00130000
