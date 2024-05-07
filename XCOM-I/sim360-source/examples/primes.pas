PROGRAM   PRIMES(OUTPUT);
CONST N=1000; N1=33;    (* N1=SQRT(N) *)
VAR   I,K,X,INC,LIM,SQUARE,L: INTEGER ;
       PRIM: BOOLEAN;
      P,V: ARRAY(.1..N1.) OF INTEGER ;
BEGIN WRITELN (CLOCK);
   INTFIELDSIZE := 6;
   WRITE (2, 3);  L := 2;
   X:=1; INC:=4; LIM:=1; SQUARE:=9;
   FOR I:=3 TO N DO
  BEGIN (* FIND NEXT PRIME *)
      REPEAT X:=X+INC ; INC:=6-INC ;
         IF SQUARE <= X THEN
            BEGIN LIM:=LIM+1 ;
              V(LIM):=SQUARE ; SQUARE:=SQR(P(LIM+1))
            END ;
         K:=2 ; PRIM:=TRUE ;
         WHILE PRIM AND (K<LIM) DO
         BEGIN K:=K+1 ;
            IF V(K)<X THEN V(K):=V(K)+2*P(K) ;
            PRIM:=X<> V(K)
         END
     UNTIL PRIM ;
     IF I<=N1 THEN P(I):=X ;
   WRITE (X);  L := L + 1;
     IF L=20 THEN
        BEGIN WRITELN ; L:=0
        END
   END;
WRITELN;  WRITELN (CLOCK)
END.
