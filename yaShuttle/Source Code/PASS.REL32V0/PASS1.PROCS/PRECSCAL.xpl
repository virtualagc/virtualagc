 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRECSCAL.xpl
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
 /* PROCEDURE NAME:  PREC_SCALE                                             */
 /* MEMBER NAME:     PRECSCAL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PP                BIT(16)                                      */
 /*          P_TYPE            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DIV_ERROR(1587)   LABEL                                        */
 /*          DIV_SCALE(1585)   LABEL                                        */
 /*          P_TEMP            FIXED                                        */
 /*          P1                FIXED                                        */
 /*          P2                FIXED                                        */
 /*          SCALE_FAIL(1582)  LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          CLASS_SQ                                                       */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          INT_TYPE                                                       */
 /*          INX                                                            */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          OPTIONS_CODE                                                   */
 /*          PSEUDO_FORM                                                    */
 /*          SCALAR_TYPE                                                    */
 /*          XBFNC                                                          */
 /*          XITOS                                                          */
 /*          XMTOM                                                          */
 /*          XSTOI                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /*          LOC_P                                                          */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          ARITH_LITERAL                                                  */
 /*          FLOATING                                                       */
 /*          HALMAT_TUPLE                                                   */
 /*          MAKE_FIXED_LIT                                                 */
 /*          SAVE_LITERAL                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PREC_SCALE <==                                                      */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> MAKE_FIXED_LIT                                                  */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> FLOATING                                                        */
 /*     ==> SAVE_LITERAL                                                    */
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
 /*     ==> ARITH_LITERAL                                                   */
 /*         ==> GET_LITERAL                                                 */
 /***************************************************************************/
 /***************************************************************************/
 /*    REVISION HISTORY :                                                   */
 /*    ------------------                                                   */
 /*   DATE    NAME  REL   DR NUMBER AND TITLE                               */
 /* --------  ---- -----  ------------------------------------------------- */
 /* 04/20/04  DCP  32V0/  CR13832  REMOVE UNPRINTED TYPE 1 HAL/S COMPILER   */
 /*                17V0            OPTIONS                                  */
 /*                                                                         */
 /***************************************************************************/
                                                                                00844902
PREC_SCALE:                                                                     00844904
   PROCEDURE (PP,P_TYPE);                                                       00844906
      DECLARE PP BIT(16), P_TYPE BIT(8);                                        00844908
      DECLARE (P_TEMP,P1,P2) FIXED;                                             00844910
      P_TEMP=PSEUDO_FORM(PTR(PP));                                              00844912
      PTR(PP)=PTR(PP)+1;                                                        00844914
      IF (P_TEMP&"F")^=0 THEN DO;                                               00844916
         CALL HALMAT_TUPLE(XMTOM(P_TYPE-MAT_TYPE),0,MP,0,                       00844918
            P_TEMP&"F");                                                        00844920
         CALL SETUP_VAC(MP,P_TYPE);                                             00844922
      END;                                                                      00844924
   END PREC_SCALE;                                                              00845018
