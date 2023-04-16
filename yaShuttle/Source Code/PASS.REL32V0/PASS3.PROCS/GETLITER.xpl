 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETLITER.xpl
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
 /*          BUILD_SDF_LITTAB                                               */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 DKB  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00137400
 /* ROUTINE TO GET CURRENT LITERAL CONTENTS PAGE */                             00137404
GET_LITERAL:                                                                    00137408
   PROCEDURE(PTR) FIXED;                                                        00137412
      DECLARE (PTR,LITORG,LITLIM,CURLBLK) FIXED;                                00137416
      DECLARE LITSIZ LITERALLY '130', LITFILE LITERALLY '2';                    00137420
                                                                                00137424
      IF PTR = 0 THEN RETURN 0;                                                 00137428
      IF PTR >= LITORG THEN                                                     00137432
         IF PTR < LITLIM THEN RETURN  PTR - LITORG;                             00137436
      CURLBLK = PTR / LITSIZ;                                                   00137440
      LITORG = CURLBLK * LITSIZ;                                                00137444
      LITLIM = LITORG + LITSIZ;                                                 00137448
      LIT1(0) = FILE(LITFILE,CURLBLK);                                          00137452
      RETURN PTR - LITORG;                                                      00137456
   END GET_LITERAL;                                                             00137460
