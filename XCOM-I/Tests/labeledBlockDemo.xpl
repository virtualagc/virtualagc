/* Tests some boundary cases related to `escape` and `repeat`. */

DECLARE I FIXED;

BLOCK1:
DO I = 1 TO 10;
    OUTPUT = I;
END;

DO I = 1 TO 10;
    OUTPUT = I;
END;

BLOCK2:
DO WHILE I = 6;
    OUTPUT = I;
END;

DO WHILE I = 6;
    OUTPUT = I;
END;

BLOCK3:
DO UNTIL I = 6;
    OUTPUT = I;
END;

DO UNTIL I = 6;
    OUTPUT = I;
END;


EOF
