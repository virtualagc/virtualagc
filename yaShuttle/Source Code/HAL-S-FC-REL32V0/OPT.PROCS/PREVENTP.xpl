 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PREVENTP.xpl
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
 /* PROCEDURE NAME:  PREVENT_PULLS                                          */
 /* MEMBER NAME:     PREVENTP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          XSYT                                                           */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADD                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /*          BUMP_ADD                                                       */
 /*          SET_VALIDITY                                                   */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          PRESCAN                                                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PREVENT_PULLS <==                                                   */
 /*     ==> SET_VALIDITY                                                    */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> BUMP_ADD                                                        */
 /***************************************************************************/
                                                                                02226010
                                                                                02226020
                                                                                02226030
 /* ROUTINES FOR LOOP OPTIMIZATION*/                                            02226040
                                                                                02226050
 /* PREVENTS PULLS FROM LOOP BY SETTING ZAPS*/                                  02226060
PREVENT_PULLS:                                                                  02226070
   PROCEDURE(PTR);                                                              02226080
      DECLARE (PTR,K,TYPE) BIT(16);                                             02226090
      A_INX = 1;                                                                02226100
      ADD(1) = PTR;                                                             02226110
                                                                                02226120
      DO WHILE A_INX > 0;                                                       02226130
         ADD = ADD(A_INX);                                                      02226140
         A_INX = A_INX - 1;                                                     02226150
                                                                                02226160
         DO FOR K = ADD + 1 TO LAST_OPERAND(ADD);                               02226170
            TYPE = XHALMAT_QUAL(K);                                             02226180
            PTR = SHR(OPR(K),16);                                               02226190
                                                                                02226200
            IF TYPE = XVAC OR TYPE = XXPT THEN                                  02226210
               CALL BUMP_ADD(PTR);                                              02226220
            ELSE IF TYPE = XSYT THEN                                            02226230
               CALL SET_VALIDITY(PTR,0,1);                                      02226240
         END;                                                                   02226250
      END;                                                                      02226260
   END PREVENT_PULLS;                                                           02226270
