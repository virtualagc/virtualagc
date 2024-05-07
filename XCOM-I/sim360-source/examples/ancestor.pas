PROGRAM     ANCESTOR(OUTPUT);
 (* R.W.FLOYD: 'ANCESTOR' , COMM.ACM 6-62 AND 3-63  ,ALG.96 *)
   CONST N = 100;
  VAR I,J,K: INTEGER;
      R: ARRAY (.1..N,1..N.) OF BOOLEAN ;
BEGIN (* R(I,J)="I IS A PARENT OF J" *)
     FOR I:=1 TO N DO
        FOR J:=1 TO N DO R(I,J):=FALSE ;
     FOR I:=1 TO N DO
      IF I MOD 10 <>0 THEN R(I,I+1):=TRUE;
      WRITELN (CLOCK);
    FOR I:=1 TO N DO
       FOR J:=1 TO N DO
          IF R(J,I) THEN
             FOR K:=1 TO N DO
                IF R(I,K) THEN R(J,K):=TRUE;
      WRITELN (CLOCK);
       FOR I:=1 TO N DO
        BEGIN WRITE(' ') ;
          FOR J:=1 TO N DO WRITE(CHR(ORD(R(I,J))+ORD('0')));
    WRITELN
   END;
    WRITELN (CLOCK)
END.
