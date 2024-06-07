 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMPTYARR.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  EMPTY_ARRAY                                            */
 /* MEMBER NAME:     EMPTYARR                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADLP_PTR          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          DLPE                                                           */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          NOP                                                            */
 /*          SUB_TRACE                                                      */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          OPOP                                                           */
 /*          LAST_OPERAND                                                   */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMPTY_ARRAY <==                                                     */
 /*     ==> OPOP                                                            */
 /*     ==> LAST_OPERAND                                                    */
 /***************************************************************************/
                                                                                01898571
                                                                                01898572
 /* IF EMPTH ARRAY LOOP, REMOVES IT & RETURNS TRUE*/                            01898573
EMPTY_ARRAY:                                                                    01898574
   PROCEDURE(PTR) BIT(8);                                                       01898575
      DECLARE (PTR, ADLP_PTR) BIT(16);                                          01898576
      ADLP_PTR = PTR;                                                           01898577
      DO UNTIL OPOP(PTR) ^= NOP AND OPOP(PTR) ^= EXTN;                          01898578
         PTR = LAST_OPERAND(PTR) + 1;                                           01898579
      END;                                                                      01898580
                                                                                01898581
      IF OPOP(PTR) ^= DLPE THEN RETURN FALSE;   /* REAL LOOP*/                  01898582
                                                                                01898583
      OPR(PTR) = 0;                                                             01898584
      OPR(ADLP_PTR) = OPR(ADLP_PTR) & "FF 0000";                                01898585
      DO FOR PTR = ADLP_PTR TO LAST_OPERAND(ADLP_PTR);                          01898586
         OPR(PTR) = 0;                                                          01898587
      END;                                                                      01898588
      IF SUB_TRACE THEN                                                         01898589
         OUTPUT = 'EMPTY_ARRAY REMOVED:  ' || ADLP_PTR;                         01898590
      RETURN TRUE;                                                              01898591
   END EMPTY_ARRAY;                                                             01898592
