 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWZEROS.xpl
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
/* PROCEDURE NAME:  NEW_ZERO_SYT_REF_FRAME                                 */
/* MEMBER NAME:     NEWZEROS                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          FOR                                                            */
/*          S_REF_POOL                                                     */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/*          SYT_REF_POOL                                                   */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          S_POOL                                                         */
/*          WORK1                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEW_SYT_REF_FRAME                                              */
/* CALLED BY:                                                              */
/*          PASS_BACK_SYT_REFS                                             */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEW_ZERO_SYT_REF_FRAME <==                                          */
/*     ==> NEW_SYT_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/***************************************************************************/
                                                                                02034000
                                                                                02036000
 /* ROUTINE TO RETURN A NEW ZEROED SYT REFERENCE MAP */                         02038000
                                                                                02040000
NEW_ZERO_SYT_REF_FRAME:PROCEDURE BIT(16);                                       02042000
                                                                                02044000
      DECLARE TEMP_PTR BIT(16);                                                 02046000
                                                                                02048000
      TEMP_PTR = NEW_SYT_REF_FRAME;                                             02050000
                                                                                02052000
      DO FOR WORK1 = 0 TO SYT_REF_POOL_FRAME_SIZE;                              02054000
         SYT_REF_POOL(TEMP_PTR + WORK1) = 0;                                    02056000
      END;                                                                      02058000
                                                                                02060000
      RETURN TEMP_PTR;                                                          02062000
                                                                                02064000
      CLOSE NEW_ZERO_SYT_REF_FRAME;                                             02066000
