 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEXTFLAG.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  NEXT_FLAG                                              */
 /* MEMBER NAME:     NEXTFLAG                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          BIT#              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FLAG                                                           */
 /*          OPR                                                            */
 /*          XSMRK                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NUMOP_FOR_REARRANGE                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          NO_OPERANDS                                                    */
 /* CALLED BY:                                                              */
 /*          FORCE_MATCH                                                    */
 /*          FORCE_TERMINAL                                                 */
 /*          PUSH_OPERAND                                                   */
 /*          SET_WORDS                                                      */
 /*          SWITCH                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> NEXT_FLAG <==                                                       */
 /*     ==> NO_OPERANDS                                                     */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /*                                                                         */
 /* 01/29/05 TKN  32V0/ DR120263 INFINITE LOOP FOR ARRAYED CONDITIONAL      */
 /*               17V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                01628000
 /* FINDS NEXT HALMAT WORD WITH SPECIFIED FLAG*/                                01629000
NEXT_FLAG:                                                                      01630000
   PROCEDURE(PTR,BIT#);                                                         01631000
      DECLARE (PTR,BIT#) BIT (16);                                              01632000
      IF BIT# = 0 THEN DO;                                                      01633000
         DO WHILE OPR(PTR);                                                     01634000
            PTR = PTR + 1;                                                      01635000
         END;                                                                   01636000
         DO WHILE (OPR(PTR) & "FFF1") ^= XSMRK;                                 01637000
            NUMOP_FOR_REARRANGE = NO_OPERANDS(PTR);                             01638000
            IF FLAG(PTR) THEN RETURN PTR;                                       01639000
            PTR = PTR + NUMOP_FOR_REARRANGE + 1;                                01640000
         END;                                                                   01641000
      END;                                                                      01642000
      ELSE                                                                      01643000
         DO WHILE (OPR(PTR) & "FFF1") ^= XSMRK;                                 01644000
         IF SHR(FLAG(PTR),BIT#) THEN DO;                                        01645000
            BIT# = 0;                                                           01646000
            RETURN PTR;                                                         01647000
         END;                                                                   01648000
         PTR = PTR + 1;                                                         01649000
      END;                                                                      01650000
      BIT# = 0;                                                                 01651000
      CALL ERRORS(CLASS_ZO,4);   /*DR120263*/
      RETURN PTR;                                                               01652000
   END NEXT_FLAG;                                                               01653000
