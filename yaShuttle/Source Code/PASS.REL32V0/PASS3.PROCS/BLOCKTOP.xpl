 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BLOCKTOP.xpl
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
 /* PROCEDURE NAME:  BLOCK_TO_PTR                                           */
 /* MEMBER NAME:     BLOCKTOP                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          BLOCK             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE              BIT(16)                                      */
 /*          OFFSET            FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #PROCS                                                         */
 /*          BASE_BLOCK_OFFSET                                              */
 /*          BASE_BLOCK_PAGE                                                */
 /*          BLOCK_NODE_SIZE                                                */
 /*          PAGE_SIZE                                                      */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          X1                                                             */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          BUILD_SDF                                                      */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
                                                                                00161800
 /* MAPPING FUNCTION -- MAPS BLOCK NUMBERS INTO SDF POINTERS */                 00161900
                                                                                00162000
BLOCK_TO_PTR:                                                                   00162100
   PROCEDURE (BLOCK) FIXED;                                                     00162200
      DECLARE (BLOCK,PAGE) BIT(16),                                             00162300
         (OFFSET) FIXED;                                                        00162400
      IF (BLOCK < 1) | (BLOCK > #PROCS) THEN DO;                                00162500
         OUTPUT = X1;                                                           00162600
         OUTPUT = P3ERR || 'BAD BLOCK # (' ||                                   00162700
            BLOCK || ') DETECTED BY BLOCK_TO_PTR ROUTINE ***';                  00162800
         GO TO PHASE3_ERROR;                                                    00162900
      END;                                                                      00163000
      OFFSET = (BLOCK - 1)*BLOCK_NODE_SIZE + BASE_BLOCK_OFFSET;                 00163100
      PAGE = BASE_BLOCK_PAGE;                                                   00163200
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00163300
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00163400
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00163500
      END;                                                                      00163600
      RETURN (SHL(PAGE,16) + OFFSET);                                           00163700
   END BLOCK_TO_PTR;                                                            00163800
