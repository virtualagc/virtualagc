 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPVAC.xpl
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
 /* PROCEDURE NAME:  SETUP_VAC                                              */
 /* MEMBER NAME:     SETUPVAC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /*          SIZE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR                                                            */
 /*          LAST_POP#                                                      */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          ARITH_TO_CHAR                                                  */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          MATCH_SIMPLES                                                  */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          PREC_SCALE                                                     */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /*          UNARRAYED_INTEGER                                              */
 /*          UNARRAYED_SCALAR                                               */
 /***************************************************************************/
                                                                                00817400
SETUP_VAC:                                                                      00817500
   PROCEDURE (LOC,TYPE,SIZE);                                                   00817600
      DECLARE (LOC,TYPE) BIT(16), SIZE BIT(16) INITIAL(-1);                     00817700
      LOC_P(PTR(LOC))=LAST_POP#;                                                00817800
      PSEUDO_FORM(PTR(LOC))=XVAC;                                               00817900
      PSEUDO_TYPE(PTR(LOC))=TYPE;                                               00818000
      IF SIZE > 0 THEN PSEUDO_LENGTH(PTR(LOC)) = SIZE;                          00818100
      SIZE = -1;                                                                00818200
   END SETUP_VAC;                                                               00818300
