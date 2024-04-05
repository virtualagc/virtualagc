 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINT2.xpl
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
 /* PROCEDURE NAME:  PRINT2                                                 */
 /* MEMBER NAME:     PRINT2                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          LINE              CHARACTER;                                   */
 /*          SPACE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE_NUM          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LINE_LIM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LISTING2_COUNT                                                 */
 /* CALLED BY:                                                              */
 /*          OUTPUT_GROUP                                                   */
 /*          STREAM                                                         */
 /***************************************************************************/
                                                                                00277100
PRINT2:                                                                         00277200
   PROCEDURE(LINE, SPACE);                                                      00277300
      DECLARE LINE CHARACTER, SPACE BIT(16);                                    00277400
      DECLARE PAGE_NUM BIT(16);                                                 00277500
      LISTING2_COUNT = LISTING2_COUNT + SPACE;                                  00277600
      IF LISTING2_COUNT > LINE_LIM THEN                                         00277700
         DO;                                                                    00277800
         PAGE_NUM = PAGE_NUM + 1;                                               00277900
         OUTPUT(2) =    '1  H A L   C O M P I L A T I O N   --   P H A S E   1  00278000
 --   U N F O R M A T T E D   S O U R C E   L I S T I N G             PAGE '    00278100
            || PAGE_NUM;                                                        00278200
         BYTE(LINE) = BYTE('-');                                                00278300
         LISTING2_COUNT = 4;                                                    00278400
      END;                                                                      00278500
      OUTPUT(2) = LINE;                                                         00278600
   END PRINT2;                                                                  00278700
