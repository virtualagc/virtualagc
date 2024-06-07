 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETLITER.xpl
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
 /* PROCEDURE NAME:  GET_LITERAL                                            */
 /* MEMBER NAME:     GETLITER                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LITERAL1                                                       */
 /*          LITFILE                                                        */
 /*          LITSIZ                                                         */
 /*          LIT1                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURLBLK                                                        */
 /*          LIT_PG                                                         */
 /*          LITLIM                                                         */
 /*          LITMAX                                                         */
 /*          LITORG                                                         */
 /* CALLED BY:                                                              */
 /*          COMBINED_LITERALS                                              */
 /*          COMPARE_LITERALS                                               */
 /*          FILL_DW                                                        */
 /*          GROW_TREE                                                      */
 /*          SAVE_LITERAL                                                   */
 /***************************************************************************/
                                                                                00678000
 /* GUARANTEES LITERAL IN CORE */                                               00679000
GET_LITERAL:                                                                    00680000
   PROCEDURE(PTR) FIXED;                                                        00681000
      DECLARE PTR FIXED;                                                        00682000
      IF PTR=0 THEN RETURN 0;                                                   00683000
      IF PTR >= LITORG THEN IF PTR < LITLIM                                     00684000
         THEN RETURN PTR-LITORG;                                                00685000
      FILE(LITFILE,CURLBLK)=LIT1(0);                                            00686000
      CURLBLK=PTR/LITSIZ;                                                       00687000
      LITORG=CURLBLK*LITSIZ;                                                    00688000
      LITLIM=LITORG+LITSIZ;                                                     00689000
      IF CURLBLK <= LITMAX THEN LIT1(0)=FILE(LITFILE,CURLBLK);                  00690000
      ELSE LITMAX=LITMAX + 1;                                                   00691000
      RETURN PTR-LITORG;                                                        00692000
   END GET_LITERAL;                                                             00693000
