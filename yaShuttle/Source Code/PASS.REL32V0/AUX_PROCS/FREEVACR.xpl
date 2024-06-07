 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FREEVACR.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  FREE_VAC_REF_FRAME                                     */
/* MEMBER NAME:     FREEVACR                                               */
/* INPUT PARAMETERS:                                                       */
/*          POOL_INDEX        BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          MAP#              BIT(16)                                      */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          MAP_INDICES                                                    */
/*          V_REF_POOL_MAP                                                 */
/*          VAC_REF_POOL_FRAME_SIZE                                        */
/*          VAC_REF_POOL_MAP                                               */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          V_MAP_VAR                                                      */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                02000000
                                                                                02002000
 /* ROUTINE TO FREE A USED VAC REFERENCE MAP FRAME */                           02004000
                                                                                02006000
FREE_VAC_REF_FRAME:PROCEDURE(POOL_INDEX);                                       02008000
                                                                                02010000
      DECLARE POOL_INDEX BIT(16);                                               02012000
      DECLARE (MAP#, TEMP_PTR) BIT(16);                                         02014000
                                                                                02016000
      IF POOL_INDEX = 0 THEN                                                    02018000
         RETURN;                                                                02020000
      MAP# = POOL_INDEX / (VAC_REF_POOL_FRAME_SIZE + 1);                        02022000
      TEMP_PTR = SHR(MAP#, 5);                                                  02024000
      VAC_REF_POOL_MAP(TEMP_PTR) = VAC_REF_POOL_MAP(TEMP_PTR) &                 02026000
         (^MAP_INDICES(MAP# & "1F"));                                           02028000
                                                                                02030000
      CLOSE FREE_VAC_REF_FRAME;                                                 02032000
