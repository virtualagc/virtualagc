 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYMBTOPT.xpl
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
/* PROCEDURE NAME:  SYMB_TO_PTR                                            */
/* MEMBER NAME:     SYMBTOPT                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          SYMB              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          OFFSET            FIXED                                        */
/*          PAGE              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          #SYMBOLS                                                       */
/*          BAIL_OUT                                                       */
/*          BASE_SYMB_OFFSET                                               */
/*          BASE_SYMB_PAGE                                                 */
/*          PAGE_SIZE                                                      */
/*          SDFLIST_ERR                                                    */
/*          SYMB_NODE_SIZE                                                 */
/*          X1                                                             */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00148800
 /* MAPPING FUNCTION -- MAPS SYMBOL NUMBERS INTO SDF POINTERS */                00148900
                                                                                00149000
SYMB_TO_PTR:                                                                    00149100
   PROCEDURE (SYMB) FIXED;                                                      00149200
      DECLARE  OFFSET FIXED,                                                    00149300
         (SYMB,PAGE) BIT(16);                                                   00149400
      IF (SYMB < 1) | (SYMB > #SYMBOLS) THEN DO;                                00149500
         OUTPUT = X1;                                                           00149600
         OUTPUT = SDFLIST_ERR || 'BAD SYMBOL # (' ||                            00149700
            SYMB || ') DETECTED BY SYMB_TO_PTR ROUTINE ***';                    00149800
         GO TO BAIL_OUT;                                                        00149900
      END;                                                                      00150000
      OFFSET = (SYMB - 1) * SYMB_NODE_SIZE + BASE_SYMB_OFFSET;                  00150100
      PAGE = BASE_SYMB_PAGE;                                                    00150200
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00150300
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00150400
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00150500
      END;                                                                      00150600
      RETURN (SHL(PAGE,16) + OFFSET);                                           00150700
   END SYMB_TO_PTR;                                                             00150800
