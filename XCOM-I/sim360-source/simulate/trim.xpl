
/* Copy a file from input(0) to output(0), trim trailing blanks */

DECLARE TEXT CHARACTER;

TRIM:
PROCEDURE CHARACTER;
    DECLARE I FIXED;

    I = LENGTH(TEXT) - 1;
    DO WHILE I >= 0 & BYTE(TEXT, I) = BYTE(' ');
        I = I - 1;
    END;
    IF I < 0 THEN RETURN '';
    IF BYTE(TEXT, I) = BYTE('''') THEN RETURN TEXT;
    IF I = 74 THEN  /* Special case for pass2.xpl */
       IF SUBSTR(TEXT, 70, 5) = 'OWNER' THEN RETURN TEXT;
    RETURN SUBSTR(TEXT, 0, I + 1);
END TRIM;

TEXT = INPUT;
DO WHILE LENGTH(TEXT) > 0;
    OUTPUT = TRIM;
    TEXT = INPUT;
END;

EOF;
