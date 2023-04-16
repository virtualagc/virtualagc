 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STMTTOPT.xpl
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
 /* PROCEDURE NAME:  STMT_TO_PTR                                            */
 /* MEMBER NAME:     STMTTOPT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          STMT              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE              BIT(16)                                      */
 /*          OFFSET            FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BASE_STMT_OFFSET                                               */
 /*          BASE_STMT_PAGE                                                 */
 /*          COMM                                                           */
 /*          FIRST_STMT                                                     */
 /*          LAST_STMT                                                      */
 /*          PAGE_SIZE                                                      */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          STMT_NODE_SIZE                                                 */
 /*          X1                                                             */
 /* CALLED BY:                                                              */
 /*          EMIT_KEY_SDF_INFO                                              */
 /*          BUILD_SDF                                                      */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
                                                                                00157600
 /* MAPPING FUNCTION -- MAPS STATEMENT NUMBERS INTO SDF POINTERS */             00157700
                                                                                00157800
STMT_TO_PTR:                                                                    00157900
   PROCEDURE (STMT) FIXED;                                                      00158000
      DECLARE (STMT,PAGE) BIT(16),                                              00158100
         (OFFSET) FIXED;                                                        00158200
      IF (STMT < FIRST_STMT) | (STMT > LAST_STMT) THEN DO;                      00158300
         OUTPUT = X1;                                                           00158400
         OUTPUT = P3ERR || 'BAD STMT # (' ||                                    00158500
            STMT || ') DETECTED BY STMT_TO_PTR ROUTINE ***';                    00158600
         GO TO PHASE3_ERROR;                                                    00158700
      END;                                                                      00158800
      OFFSET = (STMT - FIRST_STMT)*STMT_NODE_SIZE + BASE_STMT_OFFSET;           00158900
      PAGE = BASE_STMT_PAGE;                                                    00159000
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00159100
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00159200
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00159300
      END;                                                                      00159400
      RETURN (SHL(PAGE,16) + OFFSET);                                           00159500
   END STMT_TO_PTR;                                                             00159600
