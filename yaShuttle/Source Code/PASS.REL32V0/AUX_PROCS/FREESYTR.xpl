 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FREESYTR.xpl
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
/* PROCEDURE NAME:  FREE_SYT_REF_FRAME                                     */
/* MEMBER NAME:     FREESYTR                                               */
/* INPUT PARAMETERS:                                                       */
/*          POOL_INDEX        BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_PTR          BIT(16)                                      */
/*          MAP#              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          MAP_INDICES                                                    */
/*          S_REF_POOL_MAP                                                 */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/*          SYT_REF_POOL_MAP                                               */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          S_MAP_VAR                                                      */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                01910000
                                                                                01912000
 /* ROUTINE TO FREE A USED SYT REFERENCE MAP FRAME */                           01914000
                                                                                01916000
FREE_SYT_REF_FRAME:PROCEDURE(POOL_INDEX);                                       01918000
                                                                                01920000
      DECLARE POOL_INDEX BIT(16);                                               01922000
      DECLARE (TEMP_PTR, MAP#) BIT(16);                                         01924000
                                                                                01926000
      IF POOL_INDEX = 0 THEN                                                    01928000
         RETURN;                                                                01930000
                                                                                01932000
      MAP# = POOL_INDEX / (SYT_REF_POOL_FRAME_SIZE + 1);                        01934000
                                                                                01936000
      TEMP_PTR = SHR(MAP#, 5);                                                  01938000
      SYT_REF_POOL_MAP(TEMP_PTR) = SYT_REF_POOL_MAP(TEMP_PTR) &                 01940000
         (^MAP_INDICES(MAP# & "1F"));                                           01942000
                                                                                01944000
      CLOSE FREE_SYT_REF_FRAME;                                                 01946000
