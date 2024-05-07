/* Demos FILE(...) operations. */

DECLARE RECSIZE LITERALLY '3600';
DECLARE BUFFER(3599) BIT(8);
DECLARE I FIXED, J FIXED, ERROR_COUNT FIXED INITIAL(0);

DO I = 0 TO RECSIZE*5-1;
    J = I / RECSIZE;
    BUFFER(I MOD RECSIZE) = I + J;
    IF (I MOD RECSIZE) = (RECSIZE - 1) THEN
        FILE(1, J) = BUFFER;
END;

DO I = 0 TO RECSIZE*5-1;
    IF 0 = I MOD RECSIZE THEN
    DO;
        J = I / RECSIZE;
        BUFFER = FILE(1, J);
    END;
    IF BUFFER(I MOD RECSIZE) ~= ((I + J) & "FF") THEN
    DO;
        ERROR_COUNT = ERROR_COUNT + 1;
        OUTPUT = 'B: ' || I || ': ' || BUFFER(I MOD RECSIZE) || ' ~= ' 
                || ((I + J) & "FF");
    END;
END;
OUTPUT = 'ERRORS: ' || ERROR_COUNT;

EOF
