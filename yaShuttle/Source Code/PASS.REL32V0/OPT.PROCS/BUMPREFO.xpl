 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPREFO.xpl
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
 /* PROCEDURE NAME:  BUMP_REF_OPS                                           */
 /* MEMBER NAME:     BUMPREFO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          ASSIGN_FLAG       BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          C_TRACE                                                        */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CA_INX                                                         */
 /*          ARRAYNESS_CONFLICT                                             */
 /*          CONF_ASSIGNS                                                   */
 /*          CONF_REFERENCES                                                */
 /*          CR_INX                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          POP_COMPARE                                                    */
 /* CALLED BY:                                                              */
 /*          CHECK_ARRAYNESS                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BUMP_REF_OPS <==                                                    */
 /*     ==> POP_COMPARE                                                     */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> NO_OPERANDS                                                 */
 /***************************************************************************/
                                                                                01893600
                                                                                01893610
 /* CHECKS IF ARRAYNESS CONFLICT ENCOUNTERED SO FAR.                            01893620
      K IS SYT OR XPT OPERAND */                                                01893630
BUMP_REF_OPS:                                                                   01893640
   PROCEDURE (PTR,ASSIGN_FLAG);                                                 01893650
      DECLARE (PTR,K) BIT(16), ASSIGN_FLAG BIT(8);                              01893660
      IF C_TRACE THEN OUTPUT = 'BUMP_REF_OPS: ' || PTR;                         01893670
      IF ARRAYNESS_CONFLICT THEN RETURN;                                        01893680
      IF ASSIGN_FLAG THEN DO;                                                   01893690
         DO FOR K = 1 TO CR_INX;                                                01893700
            IF POP_COMPARE(PTR,CONF_REFERENCES(K)) THEN                         01893710
               DO;                                                              01893720
               IF C_TRACE THEN OUTPUT = 'ARRAYNESS_CONFLICT: '||PTR;            01893730
               ARRAYNESS_CONFLICT = TRUE;                                       01893740
               RETURN;                                                          01893750
            END;                                                                01893760
         END;                                                                   01893770
         CA_INX = CA_INX + 1;                                                   01893780
         CONF_ASSIGNS(CA_INX) = PTR ; /* ADD TO STACK */                        01893790
      END;                                                                      01893800
      ELSE DO;                                                                  01893810
         DO FOR K = 1 TO CA_INX;                                                01893820
            IF POP_COMPARE(PTR,CONF_ASSIGNS(K)) THEN                            01893830
               DO;                                                              01893840
               IF C_TRACE THEN OUTPUT = 'ARRAYNESS_CONFLICT: '||PTR;            01893850
               ARRAYNESS_CONFLICT = TRUE;                                       01893860
               RETURN;                                                          01893870
            END;                                                                01893880
         END;                                                                   01893890
         CR_INX = CR_INX + 1;                                                   01893900
         CONF_REFERENCES(CR_INX) = PTR;                                         01893910
      END;                                                                      01893920
   END BUMP_REF_OPS;                                                            01893930
