 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   RESETARR.xpl
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
 /* PROCEDURE NAME:  RESET_ARRAYNESS                                        */
 /* MEMBER NAME:     RESETARR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          MISMATCH          BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAYNESS_STACK                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          AS_PTR                                                         */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /*          END_ANY_FCN                                                    */
 /*          KILL_NAME                                                      */
 /*          NAME_COMPARE                                                   */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00866400
RESET_ARRAYNESS:                                                                00866500
   PROCEDURE;                                                                   00866600
 /* COMPARE OLD AND NEW ARRAYNESS-- REPLACE THE NEW WITH THE OLD                00866700
         UNLESS THE OLD ARRAYNESS WAS ZERO.   RETURNED VALUE INDICATED          00866800
         TRUTH OF MISMATCH */                                                   00866900
      DECLARE (I,J) BIT(16), MISMATCH BIT(8);                                   00867000
      MISMATCH=0;                                                               00867100
      IF ARRAYNESS_STACK(AS_PTR)>0 THEN DO;                                     00867200
         IF CURRENT_ARRAYNESS>0 THEN DO;                                        00867300
            IF CURRENT_ARRAYNESS=ARRAYNESS_STACK(AS_PTR) THEN                   00867400
               DO I=1 TO CURRENT_ARRAYNESS;                                     00867500
               J=AS_PTR-I;                                                      00867600
               IF CURRENT_ARRAYNESS(I)>0 THEN                                   00867700
                  IF ARRAYNESS_STACK(J)>0 THEN                                  00867800
                  IF CURRENT_ARRAYNESS(I)^=ARRAYNESS_STACK(J) THEN              00867900
                  MISMATCH=3;                                                   00868000
            END;                                                                00868100
            ELSE MISMATCH=3;                                                    00868200
         END;                                                                   00868300
         ELSE MISMATCH=2;                                                       00868400
         CURRENT_ARRAYNESS=ARRAYNESS_STACK(AS_PTR);                             00868500
         DO I= 1 TO CURRENT_ARRAYNESS;                                          00868600
            J=AS_PTR-I;                                                         00868700
            CURRENT_ARRAYNESS(I)=ARRAYNESS_STACK(J);                            00868800
         END;                                                                   00868900
         AS_PTR=AS_PTR-CURRENT_ARRAYNESS;                                       00869000
      END;                                                                      00869100
      ELSE IF CURRENT_ARRAYNESS>0 THEN MISMATCH=4;                              00869200
      AS_PTR=AS_PTR-1;                                                          00869300
      RETURN MISMATCH;                                                          00869400
   END RESET_ARRAYNESS;                                                         00869500
