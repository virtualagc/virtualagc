 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWSYTRE.xpl
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
/* PROCEDURE NAME:  NEW_SYT_REF_FRAME                                      */
/* MEMBER NAME:     NEWSYTRE                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          PTR1              BIT(16)                                      */
/*          ENTRY_FOUND       LABEL                                        */
/*          PTR2              BIT(16)                                      */
/*          TEMP              FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          CLASS_BI                                                       */
/*          FOR                                                            */
/*          MAP_INDICES                                                    */
/*          POOL_SIZE                                                      */
/*          S_POOL                                                         */
/*          S_REF_POOL_MAP                                                 */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/*          SYT_REF_POOL_MAP                                               */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          S_MAP_VAR                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ERRORS                                                         */
/* CALLED BY:                                                              */
/*          COPY_SYT_REF_FRAME                                             */
/*          INITIALIZE                                                     */
/*          NEW_ZERO_SYT_REF_FRAME                                         */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEW_SYT_REF_FRAME <==                                               */
/*     ==> ERRORS                                                          */
/*         ==> PRINT_PHASE_HEADER                                          */
/*             ==> PRINT_DATE_AND_TIME                                     */
/*                 ==> PRINT_TIME                                          */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
                                                                                01846000
                                                                                01848000
/*******************************************************************************01850000
         M A P   H A N D L I N G   R O U T I N E S                              01852000
*******************************************************************************/01854000
                                                                                01856000
                                                                                01858000
         /* ROUTINE TO RETURN INDEX OF A NEW SYT REFERENCE MAP FRAME */         01860000
                                                                                01862000
NEW_SYT_REF_FRAME: PROCEDURE BIT(16);                                           01864000
                                                                                01866000
   DECLARE (PTR1, PTR2) BIT(16);                                                01868000
   DECLARE TEMP FIXED;                                                          01869000
                                                                                01872000
   DO FOR PTR1 = 0 TO RECORD_TOP(S_MAP_VAR);                                    01874000
      DO FOR PTR2 = 0 TO 31;                                                    01876000
         IF (SYT_REF_POOL_MAP(PTR1) & MAP_INDICES(PTR2)) = 0 THEN DO;           01878000
            SYT_REF_POOL_MAP(PTR1) = SYT_REF_POOL_MAP(PTR1) | MAP_INDICES(PTR2);01880000
            GO TO ENTRY_FOUND;                                                  01882000
         END;                                                                   01884000
         IF (SHL(PTR1, 5) | PTR2) > POOL_SIZE THEN                              01886000
            CALL ERRORS (CLASS_BI, 400);                                        01888000
      END;                                                                      01890000
   END;                                                                         01892000
  NEXT_ELEMENT(S_MAP_VAR);                                                      01894000
  PTR2 = 0;                                                                     01894010
                                                                                01898000
ENTRY_FOUND:                                                                    01900000
  TEMP = (SHL(PTR1,5) | (PTR2 + 1)) * (SYT_REF_POOL_FRAME_SIZE + 1);            01902000
  DO WHILE TEMP > RECORD_TOP(S_POOL);                                           01902010
     NEXT_ELEMENT(S_POOL);                                                      01902020
  END;                                                                          01902030
   RETURN (SHL(PTR1, 5) | PTR2) * (SYT_REF_POOL_FRAME_SIZE + 1);                01904000
                                                                                01906000
CLOSE NEW_SYT_REF_FRAME;                                                        01908000
