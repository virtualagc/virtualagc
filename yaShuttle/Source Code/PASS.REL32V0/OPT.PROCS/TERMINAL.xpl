 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TERMINAL.xpl
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
 /* PROCEDURE NAME:  TERMINAL                                               */
 /* MEMBER NAME:     TERMINAL                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          TAG               BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPTYPE                                                         */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_FLAG                                                    */
 /*          CLASSIFY                                                       */
 /*          VAC_OR_XPT                                                     */
 /* CALLED BY:                                                              */
 /*          FLAG_NODE                                                      */
 /*          FORCE_TERMINAL                                                 */
 /*          GROUP_CSE                                                      */
 /*          GROW_TREE                                                      */
 /*          PUSH_OPERAND                                                   */
 /*          PUT_NOP                                                        */
 /*          REFERENCE                                                      */
 /*          VM_DETAG                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TERMINAL <==                                                        */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /*     ==> CLASSIFY                                                        */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /***************************************************************************/
                                                                                01890050
                                                                                01890060
 /* SEE IF OPERATOR IS TERMINAL FOR THIS NODE*/                                 01890070
TERMINAL:                                                                       01890080
   PROCEDURE(PTR,TAG) BIT(8);                                                   01890090
      DECLARE PTR BIT(16);                                                      01890100
      DECLARE TAG BIT(8);                                                       01890110
      IF HALMAT_FLAG(PTR) THEN DO;                                              01890120
         TAG = 0;                                                               01890130
         RETURN 1;                                                              01890140
      END;                                                                      01890150
      IF ^VAC_OR_XPT(PTR) THEN DO;                                              01890160
         TAG = 0;                                                               01890170
         RETURN 1;                                                              01890180
      END;                                                                      01890190
      IF TAG THEN DO;                                                           01890200
         TAG = 0;                                                               01890210
         IF OPTYPE ^= CLASSIFY(SHR(OPR(PTR),16)) THEN RETURN 1;                 01890220
      END;                                                                      01890230
      RETURN 0;                                                                 01890240
   END TERMINAL;                                                                01890250
