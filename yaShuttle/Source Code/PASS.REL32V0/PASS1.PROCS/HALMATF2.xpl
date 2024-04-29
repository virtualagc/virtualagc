 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATF2.xpl
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
 /* PROCEDURE NAME:  HALMAT_FIX_POPTAG                                      */
 /* MEMBER NAME:     HALMATF2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POP_LOC           FIXED                                        */
 /*          TAG               BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          ASSOCIATE                                                      */
 /*          CHECK_EVENT_EXP                                                */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00807900
HALMAT_FIX_POPTAG:                                                              00808000
   PROCEDURE(POP_LOC,TAG);                                                      00808100
      DECLARE POP_LOC FIXED,                                                    00808200
         TAG BIT(8);                                                            00808300
      IF HALMAT_OK THEN ATOMS(POP_LOC)=(ATOMS(POP_LOC)&"FFFFFF")                00808400
         |SHL(TAG&"FF",24);                                                     00808500
   END HALMAT_FIX_POPTAG;                                                       00808600
