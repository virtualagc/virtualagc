 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYMBTOPT.xpl
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
 /* PROCEDURE NAME:  SYMB_TO_PTR                                            */
 /* MEMBER NAME:     SYMBTOPT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMB              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE              BIT(16)                                      */
 /*          OFFSET            FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #SYMBOLS                                                       */
 /*          BASE_SYMB_OFFSET                                               */
 /*          BASE_SYMB_PAGE                                                 */
 /*          PAGE_SIZE                                                      */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          SYMB_NODE_SIZE                                                 */
 /*          X1                                                             */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          BUILD_SDF                                                      */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
                                                                                00159700
 /* MAPPING FUNCTION -- MAPS SYMBOL NUMBERS INTO SDF POINTERS */                00159800
                                                                                00159900
SYMB_TO_PTR:                                                                    00160000
   PROCEDURE (SYMB) FIXED;                                                      00160100
      DECLARE (SYMB,PAGE) BIT(16),                                              00160200
         (OFFSET) FIXED;                                                        00160300
      IF (SYMB < 1) | (SYMB > #SYMBOLS) THEN DO;                                00160400
         OUTPUT = X1;                                                           00160500
         OUTPUT = P3ERR || 'BAD SYMBOL # (' ||                                  00160600
            SYMB || ') DETECTED BY SYMB_TO_PTR ROUTINE ***';                    00160700
         GO TO PHASE3_ERROR;                                                    00160800
      END;                                                                      00160900
      OFFSET = (SYMB - 1)*SYMB_NODE_SIZE + BASE_SYMB_OFFSET;                    00161000
      PAGE = BASE_SYMB_PAGE;                                                    00161100
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00161200
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00161300
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00161400
      END;                                                                      00161500
      RETURN (SHL(PAGE,16) + OFFSET);                                           00161600
   END SYMB_TO_PTR;                                                             00161700
