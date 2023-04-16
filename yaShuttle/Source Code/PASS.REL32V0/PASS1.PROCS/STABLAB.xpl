 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STABLAB.xpl
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
 /* PROCEDURE NAME:  STAB_LAB                                               */
 /* MEMBER NAME:     STABLAB                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          VAL               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          STAB_STACKLIM                                                  */
 /*          CLASS_BT                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          STAB2_STACK                                                    */
 /*          STAB2_STACKTOP                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STAB_LAB <==                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00786100
STAB_LAB:                                                                       00786200
   PROCEDURE (VAL);                                                             00786300
      DECLARE VAL BIT(16);                                                      00786400
      IF STAB2_STACKTOP = STAB_STACKLIM THEN CALL ERROR(CLASS_BT,2);            00786500
      ELSE DO;                                                                  00786510
         STAB2_STACKTOP = STAB2_STACKTOP + 1;                                   00786520
         STAB2_STACK(STAB2_STACKTOP) = VAL & "7FFF";                            00786530
      END;                                                                      00786540
   END STAB_LAB;                                                                00786600
