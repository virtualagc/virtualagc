 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COPYSYTR.xpl
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
/* PROCEDURE NAME:  COPY_SYT_REF_FRAME                                     */
/* MEMBER NAME:     COPYSYTR                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          FRAME             BIT(16)                                      */
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
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> COPY_SYT_REF_FRAME <==                                              */
/*     ==> NEW_SYT_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/***************************************************************************/
                                                                                02170000
                                                                                02172000
 /* ROUTINE TO GET A NEW COPY OF A SYT REFERENCE MAP AND                        02174000
            SET IT TO A SPECIFIED MAP VALUE */                                  02176000
                                                                                02178000
COPY_SYT_REF_FRAME:PROCEDURE(FRAME) BIT(16);                                    02180000
                                                                                02182000
      DECLARE FRAME BIT(16);                                                    02184000
      DECLARE TEMP_PTR BIT(16);                                                 02186000
                                                                                02188000
      TEMP_PTR = NEW_SYT_REF_FRAME;                                             02190000
      DO FOR WORK1 = 0 TO SYT_REF_POOL_FRAME_SIZE;                              02192000
         SYT_REF_POOL(TEMP_PTR + WORK1) = SYT_REF_POOL(FRAME + WORK1);          02194000
      END;                                                                      02196000
                                                                                02198000
      RETURN TEMP_PTR;                                                          02200000
                                                                                02202000
      CLOSE COPY_SYT_REF_FRAME;                                                 02204000
