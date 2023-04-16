 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPUTE2.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  COMPUTE_DIMENSIONS                                     */
 /* MEMBER NAME:     COMPUTE2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          FOR                                                            */
 /*          MAT_VAR                                                        */
 /*          SUB_TRACE                                                      */
 /*          SYM_ARRAY                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          SYT_DIMS                                                       */
 /*          VAR                                                            */
 /*          VAR_TYPE                                                       */
 /*          VEC_VAR                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAY_DIMENSIONS                                               */
 /*          COMPONENT_SIZE                                                 */
 /*          DIMENSIONS                                                     */
 /*          MSG1                                                           */
 /* CALLED BY:                                                              */
 /*          GENERATE_DSUB_COMPUTATION                                      */
 /*          GET_LOOP_DIMENSION                                             */
 /***************************************************************************/
                                                                                02369730
                                                                                02369740
 /* ROUTINE TO GET COMBINED DIMENSIONS IN DIMENSION ARRAY*/                     02369750
COMPUTE_DIMENSIONS:                                                             02369760
   PROCEDURE;                                                                   02369770
      DECLARE (I,TEMP) BIT(16);                                                 02369780
      TEMP = SYT_ARRAY(VAR);                                                    02369790
      IF TEMP = 0 THEN DIMENSIONS,ARRAY_DIMENSIONS = 0;                         02369800
 /* NO ARRAYNESS*/                                                              02369810
      ELSE IF TEMP < 0 THEN DO;                                                 02369820
         DIMENSIONS,ARRAY_DIMENSIONS = 1;          /* * ARRAYNESS*/             02369830
         COMPONENT_SIZE(1) = 0;                                                 02369840
      END;                                                                      02369850
      ELSE DO;                                                                  02369860
         DIMENSIONS,ARRAY_DIMENSIONS = EXT_ARRAY(TEMP);                         02369870
                                                                                02369880
         DO FOR I = 1 TO DIMENSIONS;                                            02369890
                                                                                02369900
            COMPONENT_SIZE(I) = EXT_ARRAY(TEMP + I);                            02369910
                                                                                02369920
         END;                                                                   02369930
                                                                                02369940
      END;                                                                      02369950
                                                                                02369960
      IF VAR_TYPE = MAT_VAR THEN DO;                                            02369970
         COMPONENT_SIZE(DIMENSIONS + 1) = SHR(SYT_DIMS(VAR),8);                 02369980
         COMPONENT_SIZE(DIMENSIONS + 2) = SYT_DIMS(VAR) & "FF";                 02369990
         DIMENSIONS = DIMENSIONS + 2;                                           02370000
      END;                                                                      02370010
      ELSE IF VAR_TYPE = VEC_VAR THEN DO;                                       02370020
         COMPONENT_SIZE(DIMENSIONS + 1) = SYT_DIMS(VAR);                        02370030
         DIMENSIONS = DIMENSIONS + 1;                                           02370040
      END;                                                                      02370050
                                                                                02370060
      IF SUB_TRACE THEN DO;                                                     02370070
         OUTPUT = 'COMPUTE_DIMENSIONS:  COMPONENT_SIZE = ';                     02370080
         MSG1 = '';                                                             02370090
         DO FOR I = 1 TO DIMENSIONS;                                            02370100
            MSG1 = MSG1 || COMPONENT_SIZE(I) || ',';                            02370110
         END;                                                                   02370120
         OUTPUT = '   ' || MSG1;                                                02370130
      END;                                                                      02370140
   END COMPUTE_DIMENSIONS;                                                      02370150
