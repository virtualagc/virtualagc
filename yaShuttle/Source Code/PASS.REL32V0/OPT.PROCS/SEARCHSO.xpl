 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SEARCHSO.xpl
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
 /* PROCEDURE NAME:  SEARCH_SORTER                                          */
 /* MEMBER NAME:     SEARCHSO                                               */
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
 /*          SEARCH                                                         */
 /*          SEARCH2                                                        */
 /* CALLED BY:                                                              */
 /*          GET_NODE                                                       */
 /***************************************************************************/
                                                                                01345000
 /* SORT A NODE */                                                              01346000
SEARCH_SORTER:                                                                  01347000
   PROCEDURE(FIRST,LAST);                                                       01348000
      DECLARE (FIRST,LAST) BIT(16);                                             01349000
      DECLARE TEMP FIXED,                                                       01350000
         (I,K,L) BIT(16);                                                       01351000
      IF TRACE THEN OUTPUT = 'SEARCH_SORTER: FIRST '||FIRST||' LAST '||LAST;    01352000
      K,L=LAST;                                                                 01353000
      DO WHILE K<=L;                                                            01354000
         L = -LAST;                                                             01355000
         DO I = FIRST+1 TO K;                                                   01356000
            L = I-1;                                                            01357000
            IF SEARCH(L) > SEARCH(I) THEN DO;                                   01358000
               TEMP = SEARCH(L);                                                01359000
               SEARCH(L) = SEARCH(I);                                           01360000
               SEARCH(I) = TEMP;                                                01361000
               TEMP = SEARCH2(L);                                               01362000
               SEARCH2(L) = SEARCH2(I);                                         01363000
               SEARCH2(I) = TEMP;                                               01364000
               K = L;                                                           01365000
            END;                                                                01366000
            ELSE IF SEARCH(L) = SEARCH(I)THEN DO;                               01367000
               IF SEARCH2(L) > SEARCH2(I) THEN DO;                              01368000
                  TEMP = SEARCH2(L);                                            01369000
                  SEARCH2(L) = SEARCH2(I);                                      01370000
                  SEARCH2(I) = TEMP;                                            01371000
                  K = L;                                                        01372000
               END;                                                             01373000
            END;                                                                01374000
         END;                                                                   01375000
      END;                                                                      01376000
   END SEARCH_SORTER;                                                           01377000
