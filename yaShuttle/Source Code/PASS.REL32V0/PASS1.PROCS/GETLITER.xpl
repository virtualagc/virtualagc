 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETLITER.xpl
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
 /* PROCEDURE NAME:  GET_LITERAL                                            */
 /* MEMBER NAME:     GETLITER                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LIT_BUF_SIZE                                                   */
 /*          LITERAL1                                                       */
 /*          LITFILE                                                        */
 /*          LIT1                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURLBLK                                                        */
 /*          LIT_PG                                                         */
 /*          LITLIM                                                         */
 /*          LITMAX                                                         */
 /*          LITORG                                                         */
 /* CALLED BY:                                                              */
 /*          ARITH_LITERAL                                                  */
 /*          BIT_LITERAL                                                    */
 /*          CHAR_LITERAL                                                   */
 /*          LIT_DUMP                                                       */
 /*          MAKE_FIXED_LIT                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00262800
                                                                                00262900
GET_LITERAL:                                                                    00263000
   PROCEDURE(PTR) FIXED;                                                        00263100
      DECLARE (PTR) FIXED;                                                      00263200
      IF PTR = 0 THEN RETURN 0;                                                 00263300
      IF PTR >= LITORG THEN                                                     00263400
         IF PTR < LITLIM THEN                                                   00263500
         RETURN PTR - LITORG;                                                   00263600
      FILE(LITFILE,CURLBLK)=LIT1(0);                                            00263700
      CURLBLK=PTR/LIT_BUF_SIZE;                                                 00263800
      LITORG=CURLBLK*LIT_BUF_SIZE;                                              00263900
      LITLIM=LITORG+LIT_BUF_SIZE;                                               00264000
      IF CURLBLK<=LITMAX THEN LIT1(0)=FILE(LITFILE,CURLBLK);                    00264100
      ELSE LITMAX=LITMAX+1;                                                     00264200
      RETURN PTR - LITORG;                                                      00264300
   END GET_LITERAL;                                                             00264400
