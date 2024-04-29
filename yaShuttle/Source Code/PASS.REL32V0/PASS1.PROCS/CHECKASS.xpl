 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKASS.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_ASSIGN_CONTEXT                                   */
 /* MEMBER NAME:     CHECKASS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          T                 BIT(16)                                      */
 /*          FIX               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACCESS_FLAG                                                    */
 /*          CLASS_A                                                        */
 /*          CLASS_PS                                                       */
 /*          CLASS_SQ                                                       */
 /*          CONTEXT                                                        */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          INP_OR_CONST                                                   */
 /*          INX                                                            */
 /*          PTR                                                            */
 /*          SIMULATING                                                     */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /*          VAL_P                                                          */
 /*          VAR                                                            */
 /*          XREF_ASSIGN                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYNESS_FLAG                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_FIX_PIPTAGS                                             */
 /*          SET_XREF_RORS                                                  */
 /*          STAB_VAR                                                       */
 /* CALLED BY:                                                              */
 /*          CHECK_NAMING                                                   */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_ASSIGN_CONTEXT <==                                            */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SET_XREF_RORS                                                   */
 /*         ==> SET_XREF                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SET_OUTER_REF                                           */
 /*                 ==> COMPRESS_OUTER_REF                                  */
 /*                     ==> MAX                                             */
 /*     ==> STAB_VAR                                                        */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*     ==> HALMAT_FIX_PIPTAGS                                              */
 /***************************************************************************/
                                                                                00824800
CHECK_ASSIGN_CONTEXT:                                                           00824900
   PROCEDURE (LOC);                                                             00825000
      DECLARE (LOC,T) BIT(16);                                                  00825100
      DECLARE FIX FIXED;                                                        00825200
      IF CONTEXT>0 THEN DO;                                                     00825300
         CALL SET_XREF_RORS(LOC);                                               00825400
         RETURN;                                                                00825500
      END;                                                                      00825600
      T=VAL_P(PTR(LOC));                                                        00825700
      IF FIXV(LOC)^=0 THEN FIX=FIXV(LOC);                                       00825800
      ELSE FIX = FIXL(LOC);  /* NON-STRUC NAME PTR */                           00825900
      IF (SYT_FLAGS(FIX) & INP_OR_CONST) ^= 0 THEN                              00826000
         CALL ERROR(CLASS_A,1,VAR(LOC));                                        00826100
      IF (SYT_FLAGS(FIX) & ACCESS_FLAG) ^= 0 THEN                               00826200
         CALL ERROR(CLASS_PS, 8, VAR(LOC));                                     00826300
      IF SIMULATING THEN CALL STAB_VAR(LOC);                                    00826400
      CALL SET_XREF_RORS(LOC,0,XREF_ASSIGN);                                    00826500
      IF SHR(T,5) THEN CALL HALMAT_FIX_PIPTAGS(INX(PTR(LOC)),0,1);              00826600
      IF SHR(T,6) THEN CALL ERROR(CLASS_SQ,3,VAR(LOC));                         00826700
      IF DELAY_CONTEXT_CHECK THEN RETURN;                                       00826800
      ARRAYNESS_FLAG=1;                                                         00826900
   END CHECK_ASSIGN_CONTEXT;                                                    00827000
