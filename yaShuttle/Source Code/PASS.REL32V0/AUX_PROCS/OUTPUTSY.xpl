 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OUTPUTSY.xpl
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
/* PROCEDURE NAME:  OUTPUT_SYT_MAP                                         */
/* MEMBER NAME:     OUTPUTSY                                               */
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
/*          LEFT_PAREN                                                     */
/*          RIGHT_PAREN                                                    */
/*          S_POOL                                                         */
/*          S_REF_POOL                                                     */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/*          SYT_REF_POOL                                                   */
/*          TRUE                                                           */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          HEX                                                            */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> OUTPUT_SYT_MAP <==                                                  */
/*     ==> HEX                                                             */
/***************************************************************************/
                                                                                01544000
                                                                                01546000
 /* ROUTINE TO OUTPUT A SYT BIT MAP */                                          01548000
                                                                                01550000
OUTPUT_SYT_MAP:PROCEDURE(MAP_ID, MAP#);                                         01552000
                                                                                01554000
      DECLARE                                                                   01556000
         MAP_ID                         CHARACTER,                              01558000
         MAP#                           BIT(16),                                01560000
         WORK                           BIT(16),                                01562000
         LINE_INDEX                     BIT(16),                                01564000
         MESSAGE                        CHARACTER,                              01566000
         PAD_CHARS                      CHARACTER INITIAL('    ');              01568000
                                                                                01570000
      WORK = 0;                                                                 01572000
      OUTPUT = MAP_ID || BLANK || LEFT_PAREN || MAP# || RIGHT_PAREN || EQUAL;   01574000
                                                                                01576000
      DO WHILE TRUE;                                                            01578000
                                                                                01580000
         MESSAGE = '';                                                          01582000
                                                                                01584000
         DO FOR LINE_INDEX = 1 TO 10;                                           01586000
                                                                                01588000
            MESSAGE =                                                           01590000
               MESSAGE ||                                                       01592000
               HEX(SHR(SYT_REF_POOL(MAP# + WORK), 16) & "FFFF", 4) ||           01594000
               HEX(SYT_REF_POOL(MAP# + WORK) & "FFFF", 4) ||                    01596000
               PAD_CHARS;                                                       01598000
                                                                                01600000
            WORK = WORK + 1;                                                    01602000
                                                                                01604000
            IF WORK > SYT_REF_POOL_FRAME_SIZE THEN DO;                          01606000
               OUTPUT = MESSAGE;                                                01608000
               RETURN;                                                          01610000
            END;                                                                01612000
                                                                                01614000
         END;                                                                   01616000
                                                                                01618000
         OUTPUT = MESSAGE;                                                      01620000
                                                                                01622000
      END;                                                                      01624000
                                                                                01626000
      CLOSE OUTPUT_SYT_MAP;                                                     01628000
