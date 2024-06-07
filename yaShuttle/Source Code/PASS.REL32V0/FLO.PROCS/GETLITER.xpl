 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETLITER.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
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
 /* LOCAL DECLARATIONS:                                                     */
 /*          CURLBLK           FIXED                                        */
 /*          LITFILE           MACRO                                        */
 /*          LITLIM            FIXED                                        */
 /*          LITORG            FIXED                                        */
 /*          LITSIZ            MACRO                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LITERAL1                                                       */
 /*          LIT1                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LIT_PG                                                         */
 /* CALLED BY:                                                              */
 /*          INTEGER_LIT                                                    */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00141200
 /* ROUTINE TO GET CURRENT LITERAL CONTENTS PAGE */                             00141300
GET_LITERAL:                                                                    00141400
   PROCEDURE(PTR) FIXED;                                                        00141500
      DECLARE (PTR,LITORG,LITLIM,CURLBLK) FIXED;                                00141600
      DECLARE LITSIZ LITERALLY '130', LITFILE LITERALLY '2';                    00141700
                                                                                00141800
      IF PTR = 0 THEN RETURN 0;                                                 00141900
      IF PTR >= LITORG THEN                                                     00142000
         IF PTR < LITLIM THEN RETURN  PTR - LITORG;                             00142100
      CURLBLK = PTR / LITSIZ;                                                   00142200
      LITORG = CURLBLK * LITSIZ;                                                00142300
      LITLIM = LITORG + LITSIZ;                                                 00142400
      LIT1(0) = FILE(LITFILE,CURLBLK);                                          00142500
      RETURN PTR - LITORG;                                                      00142600
   END GET_LITERAL;                                                             00142700
