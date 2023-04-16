 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REINITIA.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  REINITIALIZE                                           */
/* MEMBER NAME:     REINITIA                                               */
/* INPUT PARAMETERS:                                                       */
/*          WORK_POINT1       BIT(16)                                      */
/*          WORK_POINT2       BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          WORK              FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          C_LIST_PTRS                                                    */
/*          CASE_LIST_PTRS                                                 */
/*          CELL_SIZE                                                      */
/*          CLOSE                                                          */
/*          F_BUMP_FACTOR                                                  */
/*          F_CASE_LIST                                                    */
/*          F_FLAGS                                                        */
/*          F_MAP_SAVE                                                     */
/*          F_START                                                        */
/*          F_SYT_PREV_REF                                                 */
/*          F_SYT_REF                                                      */
/*          F_UVCS                                                         */
/*          F_VAC_PREV_REF                                                 */
/*          F_VAC_REF                                                      */
/*          FOR                                                            */
/*          FRAME_BUMP_FACTOR                                              */
/*          FRAME_CASE_LIST                                                */
/*          FRAME_FLAGS                                                    */
/*          FRAME_MAP_SAVE                                                 */
/*          FRAME_START                                                    */
/*          FRAME_SYT_PREV_REF                                             */
/*          FRAME_SYT_REF                                                  */
/*          FRAME_UVCS                                                     */
/*          FRAME_VAC_PREV_REF                                             */
/*          FRAME_VAC_REF                                                  */
/*          FREE_CELL_PTR                                                  */
/*          M_CASE_LENGTH                                                  */
/*          MAX_CASE_LENGTH                                                */
/*          OFF                                                            */
/*          PREV_BLOCK_FLAG                                                */
/*          S_REF_POOL_MAP                                                 */
/*          SYT_REF_POOL_MAP                                               */
/*          V_BOUNDS                                                       */
/*          V_REF_POOL_MAP                                                 */
/*          VAC_BOUNDS                                                     */
/*          VAC_REF_POOL_MAP                                               */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          BLOCK_PRIME                                                    */
/*          MAX_USED_CELLS                                                 */
/*          S_MAP_VAR                                                      */
/*          STACK_FRAME                                                    */
/*          V_MAP_VAR                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          LINK_CELL_AREA                                                 */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> REINITIALIZE <==                                                    */
/*     ==> LINK_CELL_AREA                                                  */
/***************************************************************************/
                                                                                02554000
                                                                                02556000
/*******************************************************************************02558000
         I N I T I A L I Z A T I O N   R O U T I N E S                          02560000
*******************************************************************************/02562000
                                                                                02564000
                                                                                02566000
         /* ROUTINE TO REINITIALIZE BETWEEN HALMAT BLOCKS */                    02568000
                                                                                02570000
REINITIALIZE: PROCEDURE(WORK_POINT1, WORK_POINT2);                              02572000
                                                                                02574000
   DECLARE (WORK_POINT1, WORK_POINT2) BIT(16);                                  02576000
   DECLARE WORK FIXED;                                                          02578000
                                                                                02580000
   BLOCK_PRIME = OFF;                                                           02582000
                                                                                02584000
                                                                                02586000
  DO FOR WORK  = 1 TO RECORD_TOP(STACK_FRAME);                                  02588000
      MAX_CASE_LENGTH(WORK), FRAME_START(WORK) = 0;                             02590000
      FRAME_FLAGS(WORK) = FRAME_FLAGS(WORK) | PREV_BLOCK_FLAG;                  02592000
      FRAME_UVCS(WORK) = 0;                                                     02594000
      CASE_LIST_PTRS(WORK) = 0;                                                 02596000
      FRAME_VAC_REF(WORK) = 0;                                                  02598000
      FRAME_SYT_REF(WORK) = 0;                                                  02600000
      FRAME_VAC_PREV_REF(WORK) = 0;                                             02602000
      FRAME_SYT_PREV_REF(WORK) = 0;                                             02604000
      FRAME_BUMP_FACTOR(WORK) = 0;                                              02606000
      FRAME_MAP_SAVE(WORK) = 0;                                                 02608000
      VAC_BOUNDS(WORK) = 0;                                                     02610000
      FRAME_CASE_LIST(WORK) = 0;                                                02612000
   END;                                                                         02614000
                                                                                02616000
   WORK = CELL_SIZE - FREE_CELL_PTR;                                            02618000
   IF WORK > MAX_USED_CELLS THEN                                                02620000
      MAX_USED_CELLS = WORK;                                                    02622000
                                                                                02624000
   CALL LINK_CELL_AREA;                                                         02626000
                                                                                02628000
   SYT_REF_POOL_MAP(0), VAC_REF_POOL_MAP(0) = "80000000";                       02630000
                                                                                02632000
   DO FOR WORK = 1 TO RECORD_TOP(S_MAP_VAR);                                    02634000
      SYT_REF_POOL_MAP(WORK) = 0;                                               02634010
   END;                                                                         02634020
   DO FOR WORK = 1 TO RECORD_TOP(V_MAP_VAR);                                    02634030
      VAC_REF_POOL_MAP(WORK) = 0;                                               02637000
   END;                                                                         02638000
                                                                                02640000
CLOSE REINITIALIZE;                                                             02642000
