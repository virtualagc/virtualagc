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
/*          FLAG              BIT(8)                                       */
/* LOCAL DECLARATIONS:                                                     */
/*          LITMAX            FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          LITERAL1                                                       */
/*          LITFILE                                                        */
/*          LITSIZ                                                         */
/*          LIT1                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CURLBLK                                                        */
/*          COUNT#GETL                                                     */
/*          LIT_PG                                                         */
/*          LITLIM                                                         */
/*          LITORG                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          MAX                                                            */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> GET_LITERAL <==                                                     */
/*     ==> MAX                                                             */
/***************************************************************************/
                                                                                00643000
 /* SUBROUTINE TO GET CURRENT LITERAL CONTENTS PAGE  */                         00643500
GET_LITERAL:                                                                    00644000
   PROCEDURE(PTR, FLAG) FIXED;                                                  00644500
      DECLARE (PTR, LITMAX) FIXED, FLAG BIT(1);                                 00645000
      IF PTR = 0 THEN RETURN 0;                                                 00645500
      IF PTR >= LITORG THEN                                                     00646000
         IF PTR < LITLIM THEN                                                   00646500
         RETURN PTR - LITORG;                                                   00647000
      COUNT#GETL = COUNT#GETL + 1;                                              00647500
      IF FLAG THEN                                                              00648000
         FILE(LITFILE,CURLBLK)=LIT1(0);                                         00648500
      CURLBLK = PTR / LITSIZ;                                                   00649000
      LITORG = CURLBLK * LITSIZ;                                                00649500
      LITLIM = LITORG + LITSIZ;                                                 00650000
      IF ^FLAG | CURLBLK <= LITMAX THEN                                         00650500
         LIT1(0)=FILE(LITFILE,CURLBLK);                                         00650510
      LITMAX = MAX(LITMAX, CURLBLK);                                            00650520
      RETURN PTR - LITORG;                                                      00653500
   END GET_LITERAL;                                                             00654000
