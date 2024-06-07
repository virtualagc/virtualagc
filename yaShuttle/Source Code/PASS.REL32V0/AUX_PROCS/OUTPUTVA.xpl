 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OUTPUTVA.xpl
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
/* PROCEDURE NAME:  OUTPUT_VAC_MAP                                         */
/* MEMBER NAME:     OUTPUTVA                                               */
/* INPUT PARAMETERS:                                                       */
/*          MAP_ID            CHARACTER;                                   */
/*          MAP#              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          LINE_INDEX        BIT(16)                                      */
/*          MESSAGE           CHARACTER;                                   */
/*          PAD_CHARS         CHARACTER;                                   */
/*          WORK              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BLANK                                                          */
/*          CLOSE                                                          */
/*          EQUAL                                                          */
/*          FOR                                                            */
/*          HALMAT_PTR                                                     */
/*          LEFT_PAREN                                                     */
/*          RIGHT_PAREN                                                    */
/*          TRUE                                                           */
/*          V_POOL                                                         */
/*          V_REF_POOL                                                     */
/*          VAC_REF_POOL_FRAME_SIZE                                        */
/*          VAC_REF_POOL                                                   */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          HEX                                                            */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> OUTPUT_VAC_MAP <==                                                  */
/*     ==> HEX                                                             */
/***************************************************************************/
                                                                                01630000
                                                                                01632000
 /* ROUTINE TO OUTPUT A VAC BIT MAP */                                          01634000
                                                                                01636000
OUTPUT_VAC_MAP:PROCEDURE(MAP_ID, MAP#);                                         01638000
                                                                                01640000
      DECLARE                                                                   01642000
         MAP#                           BIT(16),                                01644000
         MAP_ID                         CHARACTER,                              01646000
         WORK                           BIT(16),                                01648000
         LINE_INDEX                     BIT(16),                                01650000
         MESSAGE                        CHARACTER,                              01652000
         PAD_CHARS                      CHARACTER INITIAL('    ');              01654000
                                                                                01656000
      WORK = 0;                                                                 01658000
      OUTPUT = MAP_ID || BLANK || LEFT_PAREN || MAP# || RIGHT_PAREN || EQUAL;   01660000
                                                                                01662000
      DO WHILE TRUE;                                                            01664000
                                                                                01666000
         MESSAGE = '';                                                          01668000
                                                                                01670000
         DO FOR LINE_INDEX = 1 TO 10;                                           01672000
                                                                                01674000
            MESSAGE =                                                           01676000
               MESSAGE ||                                                       01678000
               HEX(SHR(VAC_REF_POOL(MAP# + WORK), 16) & "FFFF", 4) ||           01680000
               HEX(VAC_REF_POOL(MAP# + WORK) & "FFFF", 4) ||                    01682000
               PAD_CHARS;                                                       01684000
                                                                                01686000
            WORK = WORK + 1;                                                    01688000
                                                                                01690000
            IF (SHL(WORK, 5) > HALMAT_PTR) |                                    01692000
               (WORK > VAC_REF_POOL_FRAME_SIZE) THEN DO;                        01694000
               OUTPUT = MESSAGE;                                                01696000
               RETURN;                                                          01698000
            END;                                                                01700000
                                                                                01702000
         END;                                                                   01704000
                                                                                01706000
         OUTPUT = MESSAGE;                                                      01708000
                                                                                01710000
      END;                                                                      01712000
                                                                                01714000
      CLOSE OUTPUT_VAC_MAP;                                                     01716000
