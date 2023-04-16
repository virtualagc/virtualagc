 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETFCNPA.xpl
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
 /* PROCEDURE NAME:  GET_FCN_PARM                                           */
 /* MEMBER NAME:     GETFCNPA                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ENDSCOPE_FLAG                                                  */
 /*          FCN_LOC                                                        */
 /*          FCN_LV                                                         */
 /*          INPUT_PARM                                                     */
 /*          NAME_FLAG                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /*          SYT_PTR                                                        */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FCN_ARG                                                        */
 /*          NAME_PSEUDOS                                                   */
 /*          VAL_P                                                          */
 /* CALLED BY:                                                              */
 /*          SETUP_CALL_ARG                                                 */
 /*          END_ANY_FCN                                                    */
 /***************************************************************************/
                                                                                00901800
GET_FCN_PARM:                                                                   00901900
   PROCEDURE;                                                                   00902000
      DECLARE L BIT(16);                                                        00902100
 /*  CANT GET IN HERE WITH FCN_ARG(.) ALREADY -1  */                            00902200
      L=SYT_PTR(FCN_LOC(FCN_LV));                                               00902300
      IF FCN_ARG(FCN_LV)>0 THEN DO;                                             00902400
         L=L+FCN_ARG(FCN_LV);                                                   00902500
         IF (SYT_FLAGS(L-1)&ENDSCOPE_FLAG)^=0|(SYT_FLAGS(L)&INPUT_PARM)=0       00902600
            THEN L=0;                                                           00902700
      END;                                                                      00902800
      IF L>0 THEN DO;                                                           00902900
         IF (SYT_FLAGS(L)&NAME_FLAG)^=0 THEN DO;                                00903000
            VAL_P="300";                                                        00903100
            NAME_PSEUDOS=TRUE;                                                  00903200
         END;                                                                   00903300
         ELSE VAL_P=0;                                                          00903400
         FCN_ARG(FCN_LV)=FCN_ARG(FCN_LV)+1;                                     00903500
      END;                                                                      00903600
      ELSE FCN_ARG(FCN_LV)=-1;                                                  00903700
      RETURN L;                                                                 00903800
   END GET_FCN_PARM;                                                            00903900
