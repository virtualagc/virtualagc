 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPRESS.xpl
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
 /* PROCEDURE NAME:  COMPRESS_OUTER_REF                                     */
 /* MEMBER NAME:     COMPRESS                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          TMP               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NEST                                                           */
 /*          OUT_REF                                                        */
 /*          OUT_REF_FLAGS                                                  */
 /*          OUTER_REF_PTR                                                  */
 /*          OUTER_REF                                                      */
 /*          OUTER_REF_FLAGS                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OUTER_REF_INDEX                                                */
 /*          OUTER_REF_MAX                                                  */
 /*          OUTER_REF_TABLE                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MAX                                                            */
 /* CALLED BY:                                                              */
 /*          BLOCK_SUMMARY                                                  */
 /*          SET_OUTER_REF                                                  */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMPRESS_OUTER_REF <==                                              */
 /*     ==> MAX                                                             */
 /***************************************************************************/
 /*     REVISION HISTORY:                                                   */
 /*     -----------------                                                   */
 /*     DATE    NAME  REL    DR NAME AND TITLE                              */
 /*                                                                         */
 /*    01/25/05 JAC   32V0/  120267 BLOCKSUM'S USED VALUE INCORRECT         */
 /*                   17V0                                                  */
 /***************************************************************************/
                                                                                00532800
                                                                                00532900
COMPRESS_OUTER_REF:                                                             00533000
   PROCEDURE;                                                                   00533100
      DECLARE (I, J, TMP) BIT(16);                                              00533200
      J = OUTER_REF_PTR(NEST) & "7FFF";                                         00533300
      IF J ^< OUTER_REF_INDEX THEN RETURN;                                      00533400
      DO I = J TO OUTER_REF_INDEX - 1;                                          00533500
         IF OUTER_REF(I) ^= -1 THEN DO;                                         00533600
            TMP = OUTER_REF(I);                                                 00533700
            DO J = I + 1 TO OUTER_REF_INDEX;                                    00533800
               IF TMP = OUTER_REF(J) THEN                                       00533900
                  IF OUTER_REF_FLAGS(I) = OUTER_REF_FLAGS(J) THEN               00534000
                  OUTER_REF(J) = -1;                                            00534010
            END;                                                                00534100
         END;                                                                   00534200
      END;                                                                      00534300
      TMP = (OUTER_REF_PTR(NEST) & "7FFF") - 1;                                 00534400
      DO I = TMP + 1 TO OUTER_REF_INDEX;                                        00534500
         IF OUTER_REF(I) ^= -1 THEN DO;                                         00534600
            TMP = TMP + 1;                                                      00534700
            OUTER_REF(TMP) = OUTER_REF(I);                                      00534800
            OUTER_REF_FLAGS(TMP) = OUTER_REF_FLAGS(I);                          00534810
         END;                                                                   00534900
      END;                                                                      00535000
      OUTER_REF_INDEX = TMP;                                                    00535100
   END COMPRESS_OUTER_REF;                                                      00535200
