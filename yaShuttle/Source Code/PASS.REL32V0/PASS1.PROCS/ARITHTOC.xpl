 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ARITHTOC.xpl
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
 /* PROCEDURE NAME:  ARITH_TO_CHAR                                          */
 /* MEMBER NAME:     ARITHTOC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BIT_TYPE                                                       */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_EM                                                       */
 /*          CLASS_EV                                                       */
 /*          INT_TYPE                                                       */
 /*          MAT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          XBTOC                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_TUPLE                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ARITH_TO_CHAR <==                                                   */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
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
 /***************************************************************************/
                                                                                00869600
ARITH_TO_CHAR :                                                                 00869700
   PROCEDURE (I) ;                                                              00869800
      DECLARE I BIT(16) ;                                                       00869900
      TEMP=SCALAR_TYPE;                                                         00870000
      DO CASE PSEUDO_TYPE(PTR(I))-MAT_TYPE;                                     00870100
         CALL ERROR(CLASS_EM,2);                                                00870200
         CALL ERROR(CLASS_EV,5);                                                00870300
         ;                                                                      00870400
         TEMP=INT_TYPE;                                                         00870500
      END;                                                                      00870600
      CALL HALMAT_TUPLE(XBTOC(TEMP-BIT_TYPE),0,I,0,0);                          00870700
      CALL SETUP_VAC(I,CHAR_TYPE);                                              00870800
   END ;                                                                        00870900
