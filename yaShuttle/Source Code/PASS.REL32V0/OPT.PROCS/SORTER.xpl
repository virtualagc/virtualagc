 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SORTER.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SORTER                                                 */
 /* MEMBER NAME:     SORTER                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          FIRST             BIT(16)                                      */
 /*          LAST              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /*          TEMP              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /* CALLED BY:                                                              */
 /*          STRIP_NODES                                                    */
 /*          GET_NODE                                                       */
 /***************************************************************************/
                                                                                01311000
                                                                                01312000
 /* SORT A NODE */                                                              01313000
SORTER:                                                                         01314000
   PROCEDURE(FIRST,LAST);                                                       01315000
      DECLARE (FIRST,LAST) BIT(16);                                             01316000
      DECLARE TEMP FIXED,                                                       01317000
         (I,K,L) BIT(16);                                                       01318000
      IF TRACE THEN OUTPUT = 'SORTER: FIRST '||FIRST||' LAST '||LAST;           01319000
      K,L=LAST;                                                                 01320000
      DO WHILE K<=L;                                                            01321000
         L = -LAST;                                                             01322000
         DO I = FIRST+1 TO K;                                                   01323000
            L = I-1;                                                            01324000
            IF NODE(L) < NODE(I) THEN DO;                                       01325000
               TEMP = NODE(L);                                                  01326000
               NODE(L) = NODE(I);                                               01327000
               NODE(I) = TEMP;                                                  01328000
               TEMP = NODE2(L);                                                 01329000
               NODE2(L) = NODE2(I);                                             01330000
               NODE2(I) = TEMP;                                                 01331000
               K = L;                                                           01332000
            END;                                                                01333000
            ELSE IF NODE(L) = NODE(I)THEN DO;                                   01334000
               IF NODE2(L) < NODE2(I) THEN DO;                                  01335000
                  TEMP = NODE2(L);                                              01336000
                  NODE2(L) = NODE2(I);                                          01337000
                  NODE2(I) = TEMP;                                              01338000
                  K = L;                                                        01339000
               END;                                                             01340000
            END;                                                                01341000
         END;                                                                   01342000
      END;                                                                      01343000
   END SORTER;                                                                  01344000
