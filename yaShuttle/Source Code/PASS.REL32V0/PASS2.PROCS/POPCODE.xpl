 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPCODE.xpl
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
/* PROCEDURE NAME:  POPCODE                                                */
/* MEMBER NAME:     POPCODE                                                */
/* INPUT PARAMETERS:                                                       */
/*          CTR               BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CONST_ATOMS                                                    */
/*          FOR_ATOMS                                                      */
/*          OPR                                                            */
/* CALLED BY:                                                              */
/*          DECODEPOP                                                      */
/*          GENERATE                                                       */
/*          OPTIMISE                                                       */
/***************************************************************************/
                                                                                  620510
 /* ROUTINES TO ISOLATE VARIOUS POP FIELDS */                                     620520
POPCODE:                                                                          620530
   PROCEDURE(CTR);                                                                620540
      DECLARE CTR BIT(16);                                                        620550
      RETURN OPR(CTR) & "FFF1";                                                   620560
   END POPCODE;                                                                   620570
