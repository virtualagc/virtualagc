PROGRAM EIGHTQUEENS(OUTPUT) ;
VAR I : INTEGER ;
    A : ARRAY(.1..8.) OF BOOLEAN ;
    B : ARRAY(.2..16.) OF BOOLEAN ;
    C : ARRAY(.-7..7.) OF BOOLEAN ;
    X : ARRAY(.1..8.) OF INTEGER ;
    SAFE : BOOLEAN ;
    PROCEDURE PRINT ;
    VAR K : INTEGER ;
    BEGIN WRITE(' ') ;
        FOR K:=1 TO 8 DO WRITE(X(K));
         WRITELN
    END ;
PROCEDURE TRYCOL(J : INTEGER ) ;
         VAR I : INTEGER ;
         PROCEDURE SETQUEEN ;
         BEGIN A(I):=FALSE ; B(I+J):=FALSE ; C(I-J):=FALSE
         END ;
         PROCEDURE REMOVEQUEEN ;
         BEGIN A(I):=TRUE ; B(I+J):=TRUE ; C(I-J):=TRUE
         END ;
              BEGIN
                    I:=0      ;
                   REPEAT I:=I+1 ; SAFE:=A(I) AND B(I+J) AND C(I-J) ;
                        IF SAFE THEN
                        BEGIN SETQUEEN ; X(J):=I ;
                             IF J<8 THEN TRYCOL(J+1) ELSE PRINT ;
                             REMOVEQUEEN
                        END
                   UNTIL I=8
              END ;
              BEGIN FOR I:=1 TO 8 DO A(I):=TRUE ;
                    FOR I:=2 TO 16 DO B(I):=TRUE ;
                    FOR I:=-7  TO 7 DO C(I):=TRUE ;
   WRITELN (CLOCK);
   INTFIELDSIZE := 2;
   TRYCOL (1);
   INTFIELDSIZE := 12;
   WRITELN (CLOCK)
END.
