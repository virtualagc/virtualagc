 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETCODE.xpl
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
/* PROCEDURE NAME:  GET_CODE                                               */
/* MEMBER NAME:     GETCODE                                                */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          CTR               FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CODE_FILE                                                      */
/*          CODE_SIZE                                                      */
/*          CODE_SIZ                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_BASE                                                      */
/*          CODE_BLK                                                       */
/*          CODE_LIM                                                       */
/*          CODE_MAX                                                       */
/*          CODE                                                           */
/* CALLED BY:                                                              */
/*          EMITC                                                          */
/*          EMITW                                                          */
/*          GENERATE_CONSTANTS                                             */
/*          NEXT_REC                                                       */
/*          OBJECT_CONDENSER                                               */
/*          SKIP_ADDR                                                      */
/***************************************************************************/
                                                                                00654500
 /* SUBROUTINE TO POSITION INTERMEDIATE CODE OUTPUT FILE  */                    00655000
GET_CODE:                                                                       00655500
   PROCEDURE(CTR) FIXED;                                                        00656000
      DECLARE (CTR, I) FIXED;                                                   00656500
      IF CTR >= CODE_BASE THEN                                                  00657000
         IF CTR < CODE_LIM THEN                                                 00657500
         RETURN CTR - CODE_BASE;                                                00658000
      FILE(CODE_FILE, CODE_BLK) = CODE;                                         00658500
      CODE_BLK = CTR / CODE_SIZE;                                               00659000
      CODE_BASE = CODE_BLK * CODE_SIZE;                                         00659500
      CODE_LIM = CODE_BASE + CODE_SIZE;                                         00660000
      IF CODE_BLK <= CODE_MAX THEN                                              00660500
         CODE = FILE(CODE_FILE, CODE_BLK);                                      00661000
      ELSE DO;                                                                  00661500
         DO I = 0 TO CODE_SIZ;                                                  00662000
            CODE(I) = 0;                                                        00662500
         END;                                                                   00663000
         DO CODE_MAX = CODE_MAX + 1 TO CODE_BLK - 1;                            00663500
            FILE(CODE_FILE, CODE_MAX) = CODE;                                   00664000
         END;                                                                   00664500
      END;                                                                      00665000
      RETURN CTR - CODE_BASE;                                                   00665500
   END GET_CODE;                                                                00666000
