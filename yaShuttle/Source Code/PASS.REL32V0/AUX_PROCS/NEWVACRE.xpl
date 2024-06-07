 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWVACRE.xpl
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
/* PROCEDURE NAME:  NEW_VAC_REF_FRAME                                      */
/* MEMBER NAME:     NEWVACRE                                               */
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
/*          V_POOL                                                         */
/*          V_REF_POOL_MAP                                                 */
/*          VAC_REF_POOL_FRAME_SIZE                                        */
/*          VAC_REF_POOL_MAP                                               */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          V_MAP_VAR                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ERRORS                                                         */
/* CALLED BY:                                                              */
/*          INITIALIZE                                                     */
/*          NEW_ZERO_VAC_REF_FRAME                                         */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEW_VAC_REF_FRAME <==                                               */
/*     ==> ERRORS                                                          */
/*         ==> PRINT_PHASE_HEADER                                          */
/*             ==> PRINT_DATE_AND_TIME                                     */
/*                 ==> PRINT_TIME                                          */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
                                                                                01948000
                                                                                01950000
 /* ROUTINE TO RETURN INDEX OF A NEW VAC REFERENCE FRAME */                     01952000
                                                                                01954000
NEW_VAC_REF_FRAME:PROCEDURE BIT(16);                                            01956000
                                                                                01958000
      DECLARE (PTR1, PTR2) BIT(16);                                             01960000
      DECLARE TEMP FIXED;                                                       01961000
                                                                                01964000
      DO FOR PTR1 = 0 TO RECORD_TOP(V_MAP_VAR);                                 01966000
         DO FOR PTR2 = 0 TO 31;                                                 01968000
            IF (VAC_REF_POOL_MAP(PTR1) & MAP_INDICES(PTR2)) = 0 THEN DO;        01970000
            VAC_REF_POOL_MAP(PTR1) = VAC_REF_POOL_MAP(PTR1) | MAP_INDICES(PTR2);01972000
               GO TO ENTRY_FOUND;                                               01974000
            END;                                                                01976000
            IF (SHL(PTR1, 5) | PTR2) > POOL_SIZE THEN                           01978000
               CALL ERRORS (CLASS_BI, 401);                                     01980000
         END;                                                                   01982000
      END;                                                                      01984000
      NEXT_ELEMENT(V_MAP_VAR);                                                  01986000
      PTR2 = 0;                                                                 01986010
                                                                                01990000
ENTRY_FOUND:                                                                    01992000
                                                                                01992010
      TEMP = (SHL(PTR1,5) | (PTR2 + 1)) * (VAC_REF_POOL_FRAME_SIZE + 1);        01992020
      DO WHILE TEMP > RECORD_TOP(V_POOL);                                       01992030
         NEXT_ELEMENT(V_POOL);                                                  01992040
      END;                                                                      01992050
      RETURN (SHL(PTR1, 5) | PTR2) * (VAC_REF_POOL_FRAME_SIZE + 1);             01994000
                                                                                01996000
      CLOSE NEW_VAC_REF_FRAME;                                                  01998000
