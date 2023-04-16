 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   AUXLINE.xpl
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
/* PROCEDURE NAME:  AUX_LINE                                               */
/* MEMBER NAME:     AUXLINE                                                */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          CTR               FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUX                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          GET_AUX                                                        */
/* CALLED BY:                                                              */
/*          AUX_SYNC                                                       */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> AUX_LINE <==                                                        */
/*     ==> GET_AUX                                                         */
/***************************************************************************/
                                                                                  632800
 /* ROUTINE TO FETCH HALMAT REFERENCE NUMBER FROM AUX LINE */                     632820
AUX_LINE:                                                                         632840
   PROCEDURE(CTR) BIT(16);                                                        632860
      DECLARE CTR FIXED;                                                          632880
      RETURN SHR(AUX(GET_AUX(CTR)), 16);                                          632900
   END AUX_LINE;                                                                  632920
