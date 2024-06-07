 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTSYTVP.xpl
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
 /* PROCEDURE NAME:  PUT_SYT_VPTR                                           */
 /* MEMBER NAME:     PUTSYTVP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMB#             BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_NUM                                                        */
 /*          SYM_VPTR                                                       */
 /*          SYT_NUM                                                        */
 /*          SYT_VPTR                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_ADD                                                        */
 /*          VPTR_INX                                                       */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /***************************************************************************/
                                                                                00140550
 /* SAVES SYM# : VMEM PTR PAIR FOR PHASE 3 */                                   00140560
PUT_SYT_VPTR:                                                                   00140570
   PROCEDURE (SYMB#,PTR);                                                       00140580
      DECLARE SYMB# BIT(16), PTR FIXED;                                         00140590
                                                                                00140600
      VPTR_INX = VPTR_INX + 1;                                                  00140610
      DO WHILE VPTR_INX>RECORD_TOP(SYM_ADD);                                    00140620
         NEXT_ELEMENT(SYM_ADD);                                                 00140630
      END;                                                                      00140640
      SYT_NUM(VPTR_INX) = SYMB#;                                                00140650
      SYT_VPTR(VPTR_INX) = PTR;                                                 00140660
   END PUT_SYT_VPTR;                                                            00140670
