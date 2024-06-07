 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEXTOP.xpl
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
 /* PROCEDURE NAME:  NEXT_OP                                                */
 /* MEMBER NAME:     NEXTOP                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          KEEP_POINTERS                                                  */
 /*          PROCESS_HALMAT                                                 */
 /*          SCAN_INITIAL_LIST                                              */
 /*          SEARCH_EXPRESSION                                              */
 /***************************************************************************/
                                                                                00136600
 /* RETURN POINTER TO NEXT HALMAT OPERATOR */                                   00136700
NEXT_OP:                                                                        00136800
   PROCEDURE (LOC) BIT(16);                                                     00136900
      DECLARE LOC BIT(16);                                                      00137000
                                                                                00137100
      LOC = LOC + 1;                                                            00137200
      DO WHILE OPR(LOC);                                                        00137300
         LOC = LOC + 1;                                                         00137400
      END;                                                                      00137500
      RETURN LOC;                                                               00137600
   END NEXT_OP;                                                                 00137700
