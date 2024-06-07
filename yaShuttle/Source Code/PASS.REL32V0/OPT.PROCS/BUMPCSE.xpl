 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPCSE.xpl
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
 /* PROCEDURE NAME:  BUMP_CSE                                               */
 /* MEMBER NAME:     BUMPCSE                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          PRTYEXPN          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LITERAL                                                        */
 /*          OPR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          CSE2                                                           */
 /*          MPARITY1#                                                      */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
                                                                                01736130
                                                                                01737000
 /* PUTS LITERAL ON CSE LIST FOR COMBINED_LITERALS*/                            01738000
BUMP_CSE:                                                                       01739000
   PROCEDURE(PTR,PRTYEXPN);                                                     01740000
      DECLARE (PTR,PRTYEXPN) BIT(16);                                           01741000
      CSE_FOUND_INX = CSE_FOUND_INX + 1;                                        01742000
      CSE(CSE_FOUND_INX) = LITERAL|SHL(PRTYEXPN,20);                            01743000
      CSE2(CSE_FOUND_INX) = SHR(OPR(PTR),16);                                   01744000
      MPARITY1# = MPARITY1# + PRTYEXPN;                                         01745000
      RETURN ;                                                                  01746000
   END BUMP_CSE;                                                                01747000
