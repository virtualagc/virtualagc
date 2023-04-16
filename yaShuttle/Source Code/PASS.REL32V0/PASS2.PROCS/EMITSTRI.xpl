 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITSTRI.xpl
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
/* PROCEDURE NAME:  EMITSTRING                                             */
/* MEMBER NAME:     EMITSTRI                                               */
/* INPUT PARAMETERS:                                                       */
/*          STRING            CHARACTER;                                   */
/*          ILEN              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          LEN               BIT(16)                                      */
/*          DEUTRANS(63)      FIXED                                        */
/*          TEMP              FIXED                                        */
/*          TEMPDESC(1)       BIT(8)                                       */
/*          TEMPSTRING(257)   BIT(8)                                       */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CSTRING                                                        */
/*          INDEXNEST                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LOCCTR                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          CS                                                             */
/*          EMITC                                                          */
/*          EMITW                                                          */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          GENERATE_CONSTANTS                                             */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMITSTRING <==                                                      */
/*     ==> CS                                                              */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/*     ==> EMITW                                                           */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/***************************************************************************/
                                                                                00734000
 /* ROUTINE TO EMIT INITIAL OR CONSTANT CHARACTER STRINGS  */                   00734500
EMITSTRING:                                                                     00735000
   PROCEDURE(STRING, ILEN);                                                     00735500
      DECLARE STRING CHARACTER, (ILEN, LEN) BIT(16), TEMP FIXED;                00736000
      DECLARE TEMPDESC(1) BIT(8), TEMPSTRING(257) BIT(8);                       00736500
      ARRAY DEUTRANS(63) FIXED INITIAL (                                        00737000
 /* 00-0F */ "001C1D1E", "1F0E0F03", "0405060A", "170D0918",                    00737500
 /* 10-1F */ "1011407F", "145C085E", "5B7B5F60", "1513127E",                    00738000
 /* 20-2F */ "0B0C191A", "1B227C7D", "5D240000", "00000000",                    00738500
 /* 30-3F */ "00000000", "00000000", "00000000", "00000000",                    00739000
 /* 40-4F */ "20000000", "00000000", "0000002E", "3C282B00",                    00739500
 /* 50-5F */ "26000000", "00000000", "00002100", "2A293B00",                    00740000
 /* 60-6F */ "2D2F0000", "00000000", "0000002C", "25163E3F",                    00740500
 /* 70-7F */ "00000000", "00000000", "00003A23", "00273D00",                    00741000
 /* 80-8F */ "00616263", "64656667", "68690000", "00000000",                    00741500
 /* 90-9F */ "006A6B6C", "6D6E6F70", "71720000", "00000000",                    00742000
 /* A0-AF */ "00007374", "75767778", "797A0000", "00020007",                    00742500
 /* B0-BF */ "00000000", "00000000", "00000000", "00010000",                    00743000
 /* C0-CF */ "00414243", "44454647", "48490000", "00000000",                    00743500
 /* D0-DF */ "004A4B4C", "4D4E4F50", "51520000", "00000000",                    00744000
 /* E0-EF */ "00005354", "55565758", "595A0000", "00000000",                    00744500
 /* F0-FF */ "30313233", "34353637", "38390000", "00000000");                   00745000
      LEN = LENGTH(STRING);                                                     00745500
      IF LEN > 0 THEN DO;                                                       00746000
         CALL INLINE("58", 1, 0, STRING);                                       00746500
         CALL INLINE("D2", 0, 255, TEMPSTRING, 1, 0);                           00747000
         TEMP = ADDR(DEUTRANS);                                                 00747500
         CALL INLINE("58", 1, 0, TEMP);                                         00748000
         CALL INLINE("DC", 0, 255, TEMPSTRING, 1, 0);                           00748500
         TEMPSTRING(LEN) = 0;                                                   00749000
         LEN = (LEN+1) & (^1);                                                  00749500
      END;                                                                      00750000
      TEMPDESC = ILEN;                                                          00750500
      TEMPDESC(1) = LENGTH(STRING);                                             00751000
      LEN = LEN + 2;                                                            00751500
      CALL EMITC(CSTRING, LEN);                                                 00752000
      TEMP = 1;                                                                 00752500
      DO WHILE LEN > 0;                                                         00753000
         IF LEN >= 4 THEN                                                       00753500
            CALL EMITW(TEMP(TEMP));                                             00754000
         ELSE DO;                                                               00754500
            CALL EMITW(TEMP(TEMP), 1);                                          00755000
            LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + CS(LEN);                    00755500
         END;                                                                   00756000
         LEN = LEN - 4;                                                         00756500
         TEMP = TEMP + 1;                                                       00757000
      END;                                                                      00763500
      ILEN = 0;                                                                 00764000
   END EMITSTRING;                                                              00764500
