 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PTRTOBLO.xpl
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
/* PROCEDURE NAME:  PTR_TO_BLOCK                                           */
/* MEMBER NAME:     PTRTOBLO                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          PTR               FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          NODE_H            BIT(16)                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          SDF_LOCATE                                                     */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PTR_TO_BLOCK <==                                                    */
/*     ==> SDF_LOCATE                                                      */
/*         ==> SDF_PTR_LOCATE                                              */
/***************************************************************************/
                                                                                00169100
 /* MAPPING FUNCTION -- CONVERTS BLOCK DATA CELL PTRS INTO BLK #S */            00169200
                                                                                00169300
PTR_TO_BLOCK:                                                                   00169400
   PROCEDURE (PTR) BIT(16);                                                     00169500
      DECLARE PTR FIXED;                                                        00169600
      BASED NODE_H BIT(16);                                                     00169700
      IF PTR = 0 THEN RETURN 0;                                                 00169800
      CALL SDF_LOCATE(PTR,ADDR(NODE_H),0);                                      00169900
      RETURN NODE_H(13);                                                        00170000
   END PTR_TO_BLOCK;                                                            00170100
