 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETARRAY.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  GET_ARRAYNESS                                          */
 /* MEMBER NAME:     GETARRAY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          MP                                                             */
 /*          NAME_FLAG                                                      */
 /*          PTR                                                            */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          VAL_P                                                          */
 /*          VAR_ARRAYNESS                                                  */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /***************************************************************************/
                                                                                00871000
GET_ARRAYNESS:                                                                  00871100
   PROCEDURE BIT(16);                                                           00871200
      DECLARE (I,J,K) BIT(16);                                                  00871300
      IF SYT_ARRAY(FIXV(MP))^=0 THEN DO;                                        00871400
         VAR_ARRAYNESS=1;                                                       00871500
         VAR_ARRAYNESS(1)=SYT_ARRAY(FIXV(MP));                                  00871600
         K=2;                                                                   00871700
      END;                                                                      00871800
      ELSE K,VAR_ARRAYNESS=0;                                                   00871900
      I=SYT_ARRAY(FIXL(MP));                                                    00872000
      IF I>0 THEN DO;                                                           00872100
         DO J=1 TO EXT_ARRAY(I);                                                00872200
            VAR_ARRAYNESS(VAR_ARRAYNESS+J)=EXT_ARRAY(I+J);                      00872300
         END;                                                                   00872400
         VAR_ARRAYNESS=VAR_ARRAYNESS+EXT_ARRAY(I);                              00872500
         K=K|1;                                                                 00872600
      END;                                                                      00872700
      I=FIXL(MP);                                                               00872800
      IF (SYT_FLAGS(I)&NAME_FLAG)^=0 THEN K=K|"200";                            00872900
      VAL_P(PTR(MP))=VAL_P(PTR(MP))|K;                                          00873000
      RETURN SHR(K,9);                                                          00873100
   END GET_ARRAYNESS;                                                           00873200
