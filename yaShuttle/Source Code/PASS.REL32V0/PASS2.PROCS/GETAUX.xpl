 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETAUX.xpl
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
/* PROCEDURE NAME:  GET_AUX                                                */
/* MEMBER NAME:     GETAUX                                                 */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          CTR               FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUX_FILE                                                       */
/*          AUX_SIZ                                                        */
/*          AUX_SIZE                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          AUX_BASE                                                       */
/*          AUX_BLK                                                        */
/*          AUX_LIM                                                        */
/*          AUX                                                            */
/* CALLED BY:                                                              */
/*          AUX_LINE                                                       */
/*          AUX_OP                                                         */
/*          AUX_SYNC                                                       */
/*          GENERATE                                                       */
/***************************************************************************/
                                                                                  632520
 /* PROCEDURE TO HANDLE PAGING OF AUXILIARY HALMAT INFO FILE */                   632540
GET_AUX:                                                                          632560
   PROCEDURE(CTR) BIT(16);                                                        632580
      DECLARE CTR FIXED;                                                          632600
      IF CTR >= AUX_BASE THEN                                                     632620
         IF CTR < AUX_LIM THEN                                                    632640
         RETURN CTR - AUX_BASE;                                                   632660
      AUX_BLK = CTR / AUX_SIZE;                                                   632680
      AUX_BASE = AUX_BLK * AUX_SIZE;                                              632700
      AUX = FILE(AUX_FILE, AUX_BLK);                                              632720
      AUX_LIM = AUX_BASE + AUX_SIZE;                                              632740
      RETURN CTR - AUX_BASE;                                                      632760
   END GET_AUX;                                                                   632780
