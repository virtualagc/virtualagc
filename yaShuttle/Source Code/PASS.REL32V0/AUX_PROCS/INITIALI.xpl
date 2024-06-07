 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  INITIALIZE                                             */
/* MEMBER NAME:     INITIALI                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 FIXED                                        */
/*          J                 FIXED                                        */
/*          SHRINK_SYT_SIZE   LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CELL_SIZE                                                      */
/*          CLOSE                                                          */
/*          COMM                                                           */
/*          CR_REF                                                         */
/*          CROSS_REF                                                      */
/*          DOUBLE_BLOCK_SIZE                                              */
/*          F_INL                                                          */
/*          F_SYT_REF                                                      */
/*          F_VAC_REF                                                      */
/*          FALSE                                                          */
/*          FOR                                                            */
/*          FRAME_INL                                                      */
/*          FRAME_SYT_REF                                                  */
/*          FRAME_VAC_REF                                                  */
/*          FUNCTION                                                       */
/*          LIST_STRUX                                                     */
/*          MOVEABLE                                                       */
/*          OPTION_BITS                                                    */
/*          POOL_SIZE                                                      */
/*          S_EXPAND_NDX                                                   */
/*          S_MAP_VAR                                                      */
/*          S_POOL                                                         */
/*          S_SHRINK_NDX                                                   */
/*          STACK_SIZE                                                     */
/*          SYM_TAB                                                        */
/*          SYM_XREF                                                       */
/*          SYT_EXPAND_INDEX                                               */
/*          SYT_SHRINK_INDEX                                               */
/*          SYT_SIZE                                                       */
/*          SYT_XREF                                                       */
/*          TRUE                                                           */
/*          V_MAP_VAR                                                      */
/*          V_POOL                                                         */
/*          VAC_REF_POOL_FRAME_SIZE                                        */
/*          WORK_VARS                                                      */
/*          XREF                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          REF_POOL_MAP_SIZE                                              */
/*          MAX_REF_SYT_SIZE                                               */
/*          SNDX                                                           */
/*          STACK_FRAME                                                    */
/*          STATISTICS                                                     */
/*          SXPND                                                          */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEW_SYT_REF_FRAME                                              */
/*          LINK_CELL_AREA                                                 */
/*          NEW_VAC_REF_FRAME                                              */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> INITIALIZE <==                                                      */
/*     ==> NEW_SYT_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/*     ==> NEW_VAC_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/*     ==> LINK_CELL_AREA                                                  */
/***************************************************************************/
                                                                                02644000
                                                                                02646000
 /* ROUTINE TO DO MUCKING AROUND BEFORE ANALYZING HALMAT */                     02648000
                                                                                02650000
INITIALIZE:PROCEDURE;                                                           02652000
                                                                                02654000
                                                                                02656000
                                                                                02698000
                                                                                02700000
 /* ROUTINE TO SHRINK SYT MAP SIZE REQUIREMENTS */                              02702000
                                                                                02704000
SHRINK_SYT_SIZE:FUNCTION BIT(16);                                               02706000
                                                                                02708000
      DECLARE                                                                   02710000
         MAX_REF_NO                     BIT(16),                                02712000
         I                              BIT(16),                                02714000
         J                              BIT(16);                                02716000
                                                                                02718000
                                                                                02720000
 /* ROUTINE TO CHECK WHETHER A SYT REFERENCE ENTRY IS                           02722000
               REFERENCED OR NOT FOR NEXT USE PURPOSES */                       02724000
                                                                                02726000
REFERENCED:FUNCTION(SYT_INDEX) BIT(1);                                          02728000
                                                                                02730000
      DECLARE                                                                   02732000
         SYT_INDEX                      BIT(16),                                02734000
         XREF_LINK_PTR                  LITERALLY 'SYT_INDEX',                  02736000
         TEMP_XREF                      FIXED;                                  02738000
                                                                                02740000
      XREF_LINK_PTR = SYT_XREF(SYT_INDEX);                                      02742000
                                                                                02744000
      DO WHILE XREF_LINK_PTR ^= 0;                                              02746000
         TEMP_XREF = XREF(XREF_LINK_PTR);                                       02748000
         IF (TEMP_XREF & "6000") ^= 0 THEN                                      02750000
            RETURN TRUE;                                                        02752000
         XREF_LINK_PTR = SHR(TEMP_XREF, 16);                                    02754000
      END;                                                                      02756000
                                                                                02758000
      RETURN FALSE;                                                             02760000
                                                                                02762000
      CLOSE REFERENCED;                                                         02764000
                                                                                02766000
                                                                                02768000
 /* MAIN BODY OF SHRINK_SYT_SIZE */                                             02770000
                                                                                02772000
      RECORD_CONSTANT(SNDX,SYT_SIZE+1,MOVEABLE);                                02774000
      RECORD_USED(SNDX) = RECORD_ALLOC(SNDX);                                   02774100
                                                                                02776000
      MAX_REF_NO = 0;                                                           02778000
                                                                                02780000
      DO FOR I = 1 TO SYT_SIZE;                                                 02782000
                                                                                02784000
         IF REFERENCED(I) THEN DO;                                              02786000
            MAX_REF_NO = MAX_REF_NO + 1;                                        02788000
            SYT_SHRINK_INDEX(I) = MAX_REF_NO;                                   02790000
         END;                                                                   02792000
                                                                                02794000
      END;                                                                      02796000
                                                                                02798000
      RECORD_CONSTANT(SXPND,MAX_REF_NO+1,MOVEABLE);                             02800000
      RECORD_USED(SXPND) = RECORD_ALLOC(SXPND);                                 02800100
                                                                                02802000
      DO FOR I = 1 TO SYT_SIZE;                                                 02804000
         J = SYT_SHRINK_INDEX(I);                                               02806000
         IF J ^= 0 THEN                                                         02808000
            SYT_EXPAND_INDEX(J) = I;                                            02810000
      END;                                                                      02812000
                                                                                02814000
      RETURN MAX_REF_NO;                                                        02816000
                                                                                02818000
      CLOSE SHRINK_SYT_SIZE;                                                    02820000
                                                                                02822000
                                                                                02824000
 /* MAIN BODY OF INITIALIZE */                                                  02826000
                                                                                02828000
      STATISTICS = (OPTION_BITS & "0100 0000") ^= 0;   /* X6 SWITCH */          02830000
                                                                                02834000
      ALLOCATE_SPACE(LIST_STRUX,CELL_SIZE +1);                                  02836000
      NEXT_ELEMENT(LIST_STRUX);                                                 02837000
      NEXT_ELEMENT(LIST_STRUX);  /* IGNORE 0-TH ELEMENT */                      02837010
                                                                                02838000
      ALLOCATE_SPACE(STACK_FRAME,STACK_SIZE+1);                                 02839000
      NEXT_ELEMENT(STACK_FRAME);                                                02840000
                                                                                02841000
      RECORD_CONSTANT(WORK_VARS,DOUBLE_BLOCK_SIZE+1,MOVEABLE);                  02842000
      RECORD_USED(WORK_VARS) = RECORD_ALLOC(WORK_VARS);                         02843000
                                                                                02844000
      DECLARE (I,J)   FIXED;                                                    02845000
      I = ((POOL_SIZE+1)*(VAC_REF_POOL_FRAME_SIZE+1));                          02846000
      ALLOCATE_SPACE(V_POOL,I);                                                 02847000
      MAX_REF_SYT_SIZE = SHRINK_SYT_SIZE;                                       02870000
      SYT_REF_POOL_FRAME_SIZE = SHR(MAX_REF_SYT_SIZE, 5);                       02872000
      J = ((SYT_REF_POOL_FRAME_SIZE+1)*(POOL_SIZE+1));                          02874000
      ALLOCATE_SPACE(S_POOL,J);                                                 02874010
      REF_POOL_MAP_SIZE = SHR(POOL_SIZE, 5);                                    02878000
      ALLOCATE_SPACE(V_MAP_VAR,(SHL(REF_POOL_MAP_SIZE+1,2)));                   02880000
      NEXT_ELEMENT(V_MAP_VAR);                                                  02880100
      ALLOCATE_SPACE(S_MAP_VAR,(SHL(REF_POOL_MAP_SIZE+1,2)));                   02880200
      NEXT_ELEMENT(S_MAP_VAR);                                                  02880300
                                                                                02888000
                                                                                02890000
 /* INITIALIZE STACK */                                                         02892000
                                                                                02894000
      FRAME_INL(0) = -1;                                                        02896000
      FRAME_SYT_REF(0) = NEW_SYT_REF_FRAME;                                     02896010
      FRAME_VAC_REF(0) = NEW_VAC_REF_FRAME;                                     02896020
                                                                                02902000
      CALL LINK_CELL_AREA;                                                      02904000
                                                                                02906000
      CLOSE INITIALIZE;                                                         02908000
