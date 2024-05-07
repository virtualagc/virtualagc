PROGRAM PALINDROMES(OUTPUT) ;
    VAR I,J,L,N,R,S: INTEGER ;
         P: BOOLEAN ;
         D: ARRAY (.1..10.) OF INTEGER ;
BEGIN N:=0 ;   WRITELN (CLOCK);
    REPEAT N:=N+1 ; S:=N*N ; L:=0 ;
         REPEAT L:=L+1 ; R:=S DIV 10 ;
              D(.L.) := S - 10*R;  S := R
         UNTIL S=0 ;
         I:=1 ; J:=L ;
         REPEAT
            P := D(.I.) = D(.J.);
            I := I + 1;  J := J - 1
         UNTIL (I>=J) OR NOT P ;
         IF P THEN
            BEGIN
               INTFIELDSIZE := 10;  WRITE (N);
               INTFIELDSIZE := 50;  WRITELN (N*N)
               END
    UNTIL N= 10000 ;
    INTFIELDSIZE := 12;
    WRITELN (CLOCK)
END .
