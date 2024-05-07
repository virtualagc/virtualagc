PROGRAM QUICKSORT   (OUTPUT);
   CONST N = 1000;
    VAR   I,Z: INTEGER ;
         A: ARRAY(.1..N.) OF INTEGER ;
 
    PROCEDURE  SORT(L,R: INTEGER) ;
         VAR I,J,X,W: INTEGER ;
         BEGIN (* QUICKSORT WITH RECURSION ON BOTH PARTITIONS *)
            I := L ; J := R;  X := A(.(I+J) DIV 2.);
 
            REPEAT
               WHILE A(.I.) < X DO I := I + 1;
               WHILE X < A(.J.) DO J := J - 1;
               IF I <= J THEN
                  BEGIN
                     W := A(.I.);  A(.I.) := A(.J.);  A(.J.) := W;
                     I := I + 1;  J := J - 1;
                  END
            UNTIL I > J;
            IF L < J THEN SORT (L, J);
            IF I < R THEN SORT (I, R)
         END (* SORT *);
 
BEGIN   Z:=1729 ;  (* GENERATE RANDOM SEQUENCE *)
    FOR I:=1 TO N DO
         BEGIN Z:=(131071*Z) MOD 2147483647 ; A(.I.) := Z
         END ;
    WRITELN (CLOCK);
    SORT(1,N);
    WRITELN (CLOCK)
END .
