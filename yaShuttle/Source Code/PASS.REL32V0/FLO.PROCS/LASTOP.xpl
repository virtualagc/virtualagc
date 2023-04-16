 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LASTOP.xpl
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
 /* PROCEDURE NAME:  LAST_OP                                                */
 /* MEMBER NAME:     LASTOP                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          GET_STMT_VARS                                                  */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
                                                                                00137800
 /* RETURNS POINTER TO PREVIOUS HALMAT OPERATOR */                              00137900
LAST_OP:                                                                        00138000
   PROCEDURE (LOC) BIT(16);                                                     00138100
      DECLARE LOC BIT(16);                                                      00138200
                                                                                00138300
      LOC = LOC - 1;                                                            00138400
      DO WHILE OPR(LOC);                                                        00138500
         LOC = LOC - 1;                                                         00138600
      END;                                                                      00138700
      RETURN LOC;                                                               00138800
   END LAST_OP;                                                                 00138801
