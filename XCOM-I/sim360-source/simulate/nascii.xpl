/*
** This program is used to convert the EBCDIC XPL compiler to an ASCII compiler.
** The compiler in the EBCDIC directory will not run on an ASCII machine because
** it has hard coded EBCDIC characters within the source.  For some reason
** EBCDIC programmers like to assume that numbers always start at "F0".
** The compiler in the PORT directory has been modified to run on both ASCII
** and EBCDIC machines.
** This program will read the compiler from the PORT directory and convert
** most of it to EBCDIC.  Only the character strings are left unchanged.
** This modified source is then compiled by the EBCDIC compiler and the
** resulting binary will be an ASCII compiler.  The ASCII compiler must
** compile itself again to squeeze out the last EBCDIC character references.
**
** This program is a prime example of: "Perfect is the enemy of good enough."
**
** Turn off $Listing and $Dump
*/

DECLARE EBCDIC(255) BIT(8) INITIAL(
  "00", "01", "02", "03", "37", "2D", "2E", "2F", "16", "05", "25", "0B", "0C", "0D", "0E", "0F",
  "10", "11", "12", "13", "3C", "3D", "32", "26", "18", "19", "3F", "27", "1C", "1D", "1E", "1F",
  "40", "5A", "7F", "7B", "5B", "6C", "50", "7D", "4D", "5D", "5C", "4E", "6B", "60", "4B", "61",
  "F0", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "7A", "5E", "4C", "7E", "6E", "6F",
  "7C", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "D1", "D2", "D3", "D4", "D5", "D6",
  "D7", "D8", "D9", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "BA", "E0", "BB", "A1", "6D",
  "79", "81", "82", "83", "84", "85", "86", "87", "88", "89", "91", "92", "93", "94", "95", "96",
  "97", "98", "99", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "C0", "4F", "D0", "5F", "07",
  "20", "21", "22", "23", "24", "15", "06", "17", "28", "29", "2A", "2B", "2C", "09", "0A", "1B",
  "30", "31", "1A", "33", "34", "35", "36", "08", "38", "39", "3A", "3B", "04", "14", "3E", "FF",
  "41", "AA", "4A", "B1", "9F", "B2", "6A", "B5", "BD", "B4", "9A", "8A", "B0", "CA", "AF", "BC",
  "90", "8F", "EA", "FA", "BE", "A0", "B6", "B3", "9D", "DA", "9B", "8B", "B7", "B8", "B9", "AB",
  "64", "65", "62", "66", "63", "67", "9E", "68", "74", "71", "72", "73", "78", "75", "76", "77",
  "AC", "69", "ED", "EE", "EB", "EF", "EC", "BF", "80", "FD", "FE", "FB", "FC", "AD", "AE", "59",
  "44", "45", "42", "46", "43", "47", "9C", "48", "54", "51", "52", "53", "58", "55", "56", "57",
  "8C", "49", "CD", "CE", "CB", "CF", "CC", "E1", "70", "DD", "DE", "DB", "DC", "8D", "8E", "DF"
);

DECLARE (TEXT, BUFFER) CHARACTER;
DECLARE STATE FIXED;
DECLARE (COMMENT, C1, C2, LITERAL, SYTSIZE) FIXED;
DECLARE QUOTE LITERALLY '"27"';

CHR: PROCEDURE(C);
    DECLARE C FIXED;

    TEXT = TEXT || 'Y';
    BYTE(TEXT, LENGTH(TEXT) - 1) = C;
END CHR;

TRANSLATE: PROCEDURE;
    DECLARE (I, CH) FIXED;

    LITERAL, SYTSIZE = 0;
    TEXT = 'X';
    DO I = 0 TO LENGTH(BUFFER) - 1;
        CH = BYTE(BUFFER, I);
        C1 = C2;
        C2 = CH;
        IF C1 = "2F" & C2 = "2A" THEN COMMENT = 1;
        IF C1 = "2A" & C2 = "2F" THEN COMMENT = 0;
        IF CH = QUOTE & COMMENT = 0 & LITERAL = 0 THEN DO;
           IF STATE = 0 THEN DO;
              CH = EBCDIC(CH);
              STATE = 1;
           END;
           ELSE DO;
              CH = BYTE(BUFFER, I + 1);
              IF CH = QUOTE THEN DO;
                 I = I + 1;
              END;
              ELSE DO;
                 CH = EBCDIC(C2);
                 STATE = 0;
              END;
           END;
        END;
        ELSE IF STATE = 0 THEN CH = EBCDIC(CH);
        CALL CHR(CH);
        IF I > 8 THEN
           IF SUBSTR(TEXT, LENGTH(TEXT) - 8, 8) = 'SYTSIZE ' THEN
              SYTSIZE = 1;
        IF I > 10 THEN
           IF SUBSTR(TEXT, LENGTH(TEXT) - 10, 10) = 'LITERALLY ' THEN
              IF SYTSIZE = 0 THEN LITERAL = 1;
              ELSE
                 DO;
                    /* REDUCE THE SYMBOL TABLE SIZE */
                    TEXT = TEXT || '''440''';
                    I = I + 5;
                 END;
    END;
    IF LENGTH(TEXT) = 1 THEN OUTPUT = '';
    ELSE OUTPUT = SUBSTR(TEXT, 1);
END TRANSLATE;

STATE, COMMENT, C1, C2 = 0;
BUFFER = INPUT;
DO WHILE LENGTH(BUFFER) > 0;
    CALL TRANSLATE;
    BUFFER = INPUT;
END;

EOF;
