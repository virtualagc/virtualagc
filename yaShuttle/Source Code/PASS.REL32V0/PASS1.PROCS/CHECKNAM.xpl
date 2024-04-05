 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKNAM.xpl
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
 /* PROCEDURE NAME:  CHECK_NAMING                                           */
 /* MEMBER NAME:     CHECKNAM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          VALUE             FIXED                                        */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          H1                FIXED                                        */
 /*          ACCESS_NAME       LABEL                                        */
 /*          H2                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACCESS_FLAG                                                    */
 /*          CLASS_A                                                        */
 /*          CLASS_EN                                                       */
 /*          DENSE_FLAG                                                     */
 /*          EXTERNAL_FLAG                                                  */
 /*          INP_OR_CONST                                                   */
 /*          MAJ_STRUC                                                      */
 /*          MISC_NAME_FLAG                                                 */
 /*          MP                                                             */
 /*          NONHAL_FLAG                                                    */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TYPE                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_TYPE                                                       */
 /*          TASK_LABEL                                                     */
 /*          TEMPORARY_FLAG                                                 */
 /*          VAL_P                                                          */
 /*          XREF_ASSIGN                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          PTR                                                            */
 /*          SYM_TAB                                                        */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          SET_XREF_RORS                                                  */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_NAMING <==                                                    */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SET_XREF_RORS                                                   */
 /*         ==> SET_XREF                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SET_OUTER_REF                                           */
 /*                 ==> COMPRESS_OUTER_REF                                  */
 /*                     ==> MAX                                             */
 /*     ==> CHECK_ASSIGN_CONTEXT                                            */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> SET_XREF_RORS                                               */
 /*             ==> SET_XREF                                                */
 /*                 ==> ENTER_XREF                                          */
 /*                 ==> SET_OUTER_REF                                       */
 /*                     ==> COMPRESS_OUTER_REF                              */
 /*                         ==> MAX                                         */
 /*         ==> STAB_VAR                                                    */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> HALMAT_FIX_PIPTAGS                                          */
 /***************************************************************************/
 /***************************************************************************/  00882100
 /*                                                                         */  00882100
 /* REVISION HISTORY:                                                       */  00882100
 /*                                                                         */  00882100
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */  00882100
 /*                                                                         */  00882100
 /* 12/16/93 LJK  26V0  109004   ILLEGAL SUBSCRIPTING OF NAME VARIABLE      */
 /*               10V0                                                      */
 /*                                                                         */  00882100
 /* 04/05/94 JAC  26V0  DR108643 INCORRECTLY LISTS 'NONHAL INSTEAD OF       */  00882100
 /*               10V0           'INCREM' IN SDFLIST                        */  00882100
 /*                                                                         */
 /* 12/08/94 TEV  27V0/ 109021   A3 ERROR NOT EMITTED FOR NAME-NAME         */
 /*               11V0           STRUCTURE NODE                             */
 /***************************************************************************/
                                                                                00882100
CHECK_NAMING:                                                                   00882300
   PROCEDURE (VALUE,LOC);                                                       00882400
      DECLARE LOC BIT(16);                                                      00882500
      DECLARE (VALUE,H1,H2) FIXED;                                              00882600
      PTR(MP)=PTR(LOC);                                                         00882700
      H2=VAL_P(PTR(MP));                                                        00882800
      VAR(MP)=VAR(LOC);                                                         00882900
      H1=SYT_FLAGS(FIXL(LOC));                                                  00883000
      DO CASE VALUE;                                                            00883100
         DO;   /*  LABEL REFERENCE  */                                          00883200
            CALL SET_XREF_RORS(LOC);                                            00883300
            IF ^SHR(H2,9) THEN DO;                                              00883400
               /* DR108643 - DISCONNECT SYT_FLAGS FROM NONHAL ***/
               IF (SYT_FLAGS2(FIXL(LOC)) & NONHAL_FLAG)^=0 THEN                 00883500
                  CALL ERROR(CLASS_EN,5,VAR(MP));
               /*** END DR108643 ***/
               ELSE IF SYT_TYPE(FIXL(LOC))<TASK_LABEL THEN                      00883600
                  IF (H1&EXTERNAL_FLAG)=0 THEN CALL ERROR(CLASS_EN,6,VAR(MP));  00883700
               /* CHECK IF VAL_P "4000" BIT IS SET. IF IT IS, THERE  */
               /* IS A NAME VARIABLE IN THE STRUCTURE REFERENCE LIST;*/
               /* THIS STRUCTURE CANNOT HAVE ITS MISC_NAME_FLAG SET. */
               IF ^SHR(H2,14) THEN    /* DR109021 */
                  SYT_FLAGS(FIXL(LOC))=H1|MISC_NAME_FLAG;                       00883800
               GO TO ACCESS_NAME;                                               00883900
            END;                                                                00884000
         END;                                                                   00884100
         DO;     /*  DATA RFEFERENCE  */                                        00884200
            IF SHR(H2,4) THEN CALL ERROR(CLASS_EN,7,VAR(MP));                   00884300
            CALL SET_XREF_RORS(LOC);                                            00884400
            IF ^SHR(H2,9) THEN DO;                                              00884500
               IF (H2&"6")="2" THEN CALL ERROR(CLASS_EN,13,VAR(MP));            00884600
               IF (H1&DENSE_FLAG)^=0 THEN IF SYT_TYPE(FIXL(LOC))<MAJ_STRUC THEN 00884700
                  CALL ERROR(CLASS_EN,8,VAR(MP));                               00884800
               IF FIXV(LOC)>0 THEN DO;                                          00884900
                  IF SYT_TYPE(FIXL(LOC))=MAJ_STRUC THEN                         00885000
                     CALL ERROR(CLASS_EN,9,VAR(MP));                            00885100
                  H1=SYT_FLAGS(FIXV(LOC));                                      00885200
                  /* CHECK IF VAL_P "4000" BIT IS SET. IF IT IS, THERE  */
                  /* IS A NAME VARIABLE IN THE STRUCTURE REFERENCE LIST;*/
                  /* THIS STRUCTURE CANNOT HAVE ITS MISC_NAME_FLAG SET. */
                  IF ^SHR(H2,14) THEN   /* DR109021 */
                     SYT_FLAGS(FIXV(LOC)) = H1|MISC_NAME_FLAG;                  00885250
               END;                                                             00885300
               /* CHECK IF VAL_P "4000" BIT IS SET. IF IT IS, THERE  */
               /* IS A NAME VARIABLE IN THE STRUCTURE REFERENCE LIST;*/
               /* THIS STRUCTURE CANNOT HAVE ITS MISC_NAME_FLAG SET. */
               ELSE IF ^SHR(H2,14) THEN   /* DR109021 */
                  SYT_FLAGS(FIXL(LOC))=H1|MISC_NAME_FLAG;                       00885400
               IF ^SHR(H2,14) THEN DO;                                          00885450
                 IF (H1&TEMPORARY_FLAG)^=0 THEN CALL ERROR(CLASS_EN,10,VAR(MP));00885500
                  IF (H1&INP_OR_CONST)^=0 THEN CALL ERROR(CLASS_EN,11,VAR(MP)); 00885600
               END;                                                             00885650
ACCESS_NAME:                                                                    00885700
               IF (H1&ACCESS_FLAG)^=0 THEN CALL ERROR(CLASS_EN,12,VAR(MP));     00885800
            END;                                                                00885900
         END;                                                                   00886000
         ;     /*  ERROR CASE  */                                               00886100
         DO;   /*  ASSIGNMENT  */                                               00886200
            IF SHR(H2,9) THEN DO;                                               00886300
               IF SHR(H2,3) THEN CALL ERROR(CLASS_A,2,VAR(MP));                 00886400
         /*****  DR109004   LJK 12/16/93   *************************/
         /*  CHECK THE BITMASK OF "24" INSTEAD OF "28" FOR ILLEGAL */
         /*  SUBSCRIPTS OF A NAME STRUCTURE                        */
               ELSE IF (H2&"24")="24" THEN CALL ERROR(CLASS_A,2,VAR(MP));       00886500
         /*****  END DR109004            ***************************/
               CALL CHECK_ASSIGN_CONTEXT(LOC);                                  00886600
            END;                                                                00886700
            ELSE DO;                                                            00886800
               CALL ERROR(CLASS_A,3,VAR(MP));                                   00886900
               CALL SET_XREF_RORS(MP,0,XREF_ASSIGN);                            00887000
            END;                                                                00887100
         END;                                                                   00887200
      END;                                                                      00887300
      FIXL(MP)=FIXL(LOC);                                                       00887400
      FIXV(MP)=FIXV(LOC);                                                       00887500
      IF SHR(H2,6) THEN CALL ERROR(CLASS_EN,14);                                00887600
   END CHECK_NAMING;                                                            00887700
