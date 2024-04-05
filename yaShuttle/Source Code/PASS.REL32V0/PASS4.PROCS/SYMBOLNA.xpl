 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYMBOLNA.xpl
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
/* PROCEDURE NAME:  SYMBOL_NAME                                            */
/* MEMBER NAME:     SYMBOLNA                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          SYMB#             BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          SNAME             CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          ADDRESS                                                        */
/*          COMMTABL_ADDR                                                  */
/*          COMMTABL_BYTE                                                  */
/*          COMMTABL_FULLWORD                                              */
/*          PNTR                                                           */
/*          SYMBNAM                                                        */
/*          SYMBNLEN                                                       */
/*          SYMBNO                                                         */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LOC_ADDR                                                       */
/*          COMMTABL_HALFWORD                                              */
/*          LOC_PTR                                                        */
/*          TMP                                                            */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00167500
 /* ROUTINE TO EXTRACT A SYMBOL NAME FROM A SYMBOL NODE AND DATA CELL */        00167600
                                                                                00167700
SYMBOL_NAME:                                                                    00167800
   PROCEDURE (SYMB#) CHARACTER;                                                 00167900
      DECLARE SNAME CHARACTER,                                                  00168000
         SYMB# BIT(16);                                                         00168100
                                                                                00168200
      SYMBNO = SYMB#;                                                           00168300
      CALL MONITOR(22,9);                                                       00168400
      LOC_PTR = PNTR;                                                           00168500
      LOC_ADDR = ADDRESS;                                                       00168600
      TMP = SHL((SYMBNLEN - 1),24);                                             00168700
      COREWORD(ADDR(SNAME)) = SYMBNAM + TMP;                                    00168800
      RETURN SNAME;                                                             00168900
   END SYMBOL_NAME;                                                             00169000
