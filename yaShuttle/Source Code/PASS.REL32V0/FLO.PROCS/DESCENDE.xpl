 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DESCENDE.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  DESCENDENT                                             */
 /* MEMBER NAME:     DESCENDE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EVIL_FLAGS                                                     */
 /*          CLASS_BI                                                       */
 /*          NAME_FLAG                                                      */
 /*          STRUCTURE                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_TYPE                                                       */
 /*          SYT_DIMS                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          KIN                                                            */
 /*          SYM_TAB                                                        */
 /*          TEMPL_INX                                                      */
 /*          TEMPL_LIST                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /* CALLED BY:                                                              */
 /*          STRUCTURE_ADVANCE                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DESCENDENT <==                                                      */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /***************************************************************************/
                                                                                00152600
 /* ROUTINE TO CHECK FOR LEVEL DESCENT IN STRUCTURE TEMPLATE  */                00152700
DESCENDENT:                                                                     00152800
   PROCEDURE(LOC) BIT(16);                                                      00152900
      DECLARE (LOC) BIT(16);                                                    00153000
      IF SYT_TYPE(LOC) = STRUCTURE | SYT_TYPE(LOC) = TEMPL_NAME THEN DO;        00153100
         IF (SYT_FLAGS(LOC) & EVIL_FLAGS) = EVIL_FLAGS THEN                     00153200
            CALL ERRORS (CLASS_BI, 201);                                        00153300
         IF (SYT_FLAGS(LOC) & NAME_FLAG) ^= 0 THEN RETURN 0;                    00153400
         KIN = SYT_LINK1(LOC);                                                  00153500
         IF KIN > 0 THEN RETURN KIN;                                            00153600
         KIN = SYT_DIMS(LOC);                                                   00153700
         SYT_LINK2(KIN) = LOC;                                                  00153800
         TEMPL_INX = TEMPL_INX + 1;                                             00153900
         TEMPL_LIST(TEMPL_INX) = LOC;                                           00154000
         RETURN KIN;                                                            00154100
      END;                                                                      00154200
      RETURN 0;                                                                 00154300
   END DESCENDENT;                                                              00154400
