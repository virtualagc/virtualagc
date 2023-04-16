 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETARRA2.xpl
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
 /* PROCEDURE NAME:  GETARRAY#                                              */
 /* MEMBER NAME:     GETARRA2                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
                                                                                00144800
 /*  SUBROUTINE FOR FINDING THE NUMBER OF ARRAY DIMENSIONS  */                  00144900
GETARRAY#:                                                                      00145000
   PROCEDURE (OP) BIT(8);                                                       00145100
      DECLARE OP BIT(16);                                                       00145200
      IF SYT_ARRAY(OP)=0 THEN RETURN 0;                                         00145300
      ELSE RETURN EXT_ARRAY(SYT_ARRAY(OP));                                     00145400
   END GETARRAY#;                                                               00145500
