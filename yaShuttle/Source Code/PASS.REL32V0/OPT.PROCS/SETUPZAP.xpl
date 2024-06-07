 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPZAP.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SETUP_ZAP_BY_TYPE                                      */
 /* MEMBER NAME:     SETUPZAP                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BIT_PTR           BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          MAT_BASE          BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          SCAL_BASE         BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /*          VEC_BASE          BIT(16)                                      */
 /*          WD#               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          COMM                                                           */
 /*          FOR                                                            */
 /*          INT_VAR                                                        */
 /*          REL                                                            */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TYPE_ZAP                                                       */
 /*          VAL_SIZE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ZAPIT                                                          */
 /* CALLED BY:                                                              */
 /*          INITIALISE                                                     */
 /***************************************************************************/
                                                                                00858130
                                                                                00859000
 /* SETS UP ARRAYS USED FOR ASSIGNMENT TO A NAME OR ASSIGN PARM*/               00859010
SETUP_ZAP_BY_TYPE:                                                              00859020
   PROCEDURE;                                                                   00859030
      DECLARE (K,TYPE,PTR,WD#,BIT_PTR,MAT_BASE,VEC_BASE,SCAL_BASE) BIT(16);     00859040
                                                                                00859050
      DO FOR K = 2 TO COMM(10);                                                 00859060
                                                                                00859070
         PTR = REL(K);                                                          00859080
         IF PTR > 1 THEN DO;    /* USED*/                                       00859090
            TYPE = SYT_TYPE(K);                                                 00859100
            IF TYPE > 0 AND TYPE <= INT_VAR THEN DO;                            00859110
               BIT_PTR = PTR & "1F";                                            00859130
               ZAPIT(TYPE-1).TYPE_ZAP(SHR(PTR,5)) =                             00859140
                  ZAPIT(TYPE-1).TYPE_ZAP(SHR(PTR,5)) | SHL(1,BIT_PTR);          00859142
            END;                                                                00859150
         END;                                                                   00859160
                                                                                00859170
      END; /* DO FOR*/                                                          00859180
                                                                                00859190
      MAT_BASE = VAL_SIZE + VAL_SIZE;                                           00859200
      MAT_BASE = 2;                                                             00859210
      VEC_BASE = 3;                                                             00859220
      SCAL_BASE = 4;                                                            00859230
      DO FOR K = 0 TO VAL_SIZE - 1;                                             00859240
                                                                                00859250
         ZAPIT(VEC_BASE).TYPE_ZAP(K) = ZAPIT(VEC_BASE).TYPE_ZAP(K) |            00859260
            ZAPIT(MAT_BASE).TYPE_ZAP(K);                                        00859270
         ZAPIT(SCAL_BASE).TYPE_ZAP(K) = ZAPIT(SCAL_BASE).TYPE_ZAP(K) |          00859280
            ZAPIT(VEC_BASE).TYPE_ZAP(K);                                        00859290
                                                                                00859300
      END;  /* AN ASSIGN TO A NAME OF A VECTOR ALSO ZAPS MATRIX.                00859310
            AN ASSIGN TO A SCALAR ZAPS ALL 3. */                                00859320
                                                                                00859330
   END SETUP_ZAP_BY_TYPE;                                                       00859340
