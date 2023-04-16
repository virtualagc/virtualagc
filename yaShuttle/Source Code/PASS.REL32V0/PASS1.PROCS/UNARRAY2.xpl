 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   UNARRAY2.xpl
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
 /* PROCEDURE NAME:  UNARRAYED_SCALAR                                       */
 /* MEMBER NAME:     UNARRAY2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          XITOS                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_TUPLE                                                   */
 /*          CHECK_ARRAYNESS                                                */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> UNARRAYED_SCALAR <==                                                */
 /*     ==> HALMAT_TUPLE                                                    */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*     ==> SETUP_VAC                                                       */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /***************************************************************************/
                                                                                00821500
UNARRAYED_SCALAR:                                                               00821600
   PROCEDURE (LOC);                                                             00821700
      DECLARE LOC BIT(16);                                                      00821800
      IF PSEUDO_TYPE(PTR(LOC))=INT_TYPE THEN DO;                                00821900
         CALL HALMAT_TUPLE(XITOS,0,LOC,0,0);                                    00822000
         CALL SETUP_VAC(LOC,SCALAR_TYPE);                                       00822100
      END;                                                                      00822200
      RETURN CHECK_ARRAYNESS|(PSEUDO_TYPE(PTR(LOC))^=SCALAR_TYPE);              00822300
   END UNARRAYED_SCALAR;                                                        00822400
