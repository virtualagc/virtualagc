 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PROCESSE.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PROCESS_EXTN                                           */
 /* MEMBER NAME:     PROCESSE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          CLASS_BI                                                       */
 /*          HALMAT_PTR                                                     */
 /*          PROC_TRACE                                                     */
 /*          VAC                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXP_VARS                                                       */
 /*          EXP_PTRS                                                       */
 /*          PTR_INX                                                        */
 /*          VAR_INX                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          POPNUM                                                         */
 /*          POPVAL                                                         */
 /*          TYPE_BITS                                                      */
 /*          X_BITS                                                         */
 /* CALLED BY:                                                              */
 /*          GET_VAR_REF_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          SEARCH_EXPRESSION                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PROCESS_EXTN <==                                                    */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> POPNUM                                                          */
 /*     ==> POPVAL                                                          */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> X_BITS                                                          */
 /***************************************************************************/
                                                                                00163400
 /* GETS A VAR REF CELL FOR AN EXTN OPERATOR */                                 00163500
PROCESS_EXTN:                                                                   00163600
   PROCEDURE (CTR);                                                             00163700
      DECLARE (CTR,J,K) BIT(16);                                                00163800
                                                                                00163900
      IF PROC_TRACE THEN OUTPUT='PROCESS_EXTN('||BLOCK#||':'||CTR||')';         00163901
      IF HALMAT_PTR(CTR) ^= 0 THEN DO;                                          00164000
         PTR_INX = PTR_INX + 1;                                                 00164100
         EXP_PTRS(PTR_INX) = HALMAT_PTR(CTR);                                   00164200
      END;                                                                      00164300
      ELSE IF TYPE_BITS(CTR+1) = VAC THEN                                       00164400
         CALL ERRORS (CLASS_BI, 202, ' '||BLOCK#||':'||CTR);                    00164500
      ELSE DO;                                                                  00164700
         VAR_INX = VAR_INX + 1;                                                 00164800
         K = X_BITS(CTR+POPNUM(CTR)-1);                                         00164801
         EXP_VARS(VAR_INX) = -POPNUM(CTR) + K;                                  00164900
         DO J = 1 TO POPNUM(CTR)-K;                                             00165000
            VAR_INX = VAR_INX + 1;                                              00165100
            EXP_VARS(VAR_INX) = POPVAL(CTR+J);                                  00165200
         END;                                                                   00165300
      END;                                                                      00165400
   END PROCESS_EXTN;                                                            00165500
