 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETSYTVP.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_SYT_VPTR                                           */
 /* MEMBER NAME:     GETSYTVP                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMB#             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_ADD                                                        */
 /*          CLASS_BI                                                       */
 /*          SYM_NAME                                                       */
 /*          SYM_NUM                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_VPTR                                                       */
 /*          SYT_NAME                                                       */
 /*          SYT_NUM                                                        */
 /*          SYT_VPTR                                                       */
 /*          VPTR_INX                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /* CALLED BY:                                                              */
 /*          GET_P_F_INV_CELL                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_SYT_VPTR <==                                                    */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /***************************************************************************/
                                                                                00140680
 /* RETRIEVES THE VMEM PTR ASSOCIATED WITH A SYMBOL */                          00140690
GET_SYT_VPTR:                                                                   00140700
   PROCEDURE (SYMB#) FIXED;                                                     00140710
      DECLARE (SYMB#,J) BIT(16);                                                00140720
                                                                                00140730
      DO J = 1 TO VPTR_INX;                                                     00140740
         IF SYT_NUM(J) = SYMB# THEN RETURN SYT_VPTR(J);                         00140750
      END;                                                                      00140800
      CALL ERRORS (CLASS_BI, 200, ' '||SYT_NAME(SYMB#));                        00140900
      RETURN 0;                                                                 00141000
   END GET_SYT_VPTR;                                                            00141100
