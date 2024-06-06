/* Tests the case of a label (LABEL:) within a case statement. */

DECLARE I FIXED INITIAL(5);

DO CASE I;
    OUTPUT = 0;
    OUTPUT = 1;
    MYLABEL2: OUTPUT = 2;
    DO;
        MYLABEL3: OUTPUT = 3;
    END;
    OUTPUT = 4;
    OUTPUT = 5;
    OUTPUT = 6;
END;
