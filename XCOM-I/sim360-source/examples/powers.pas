PROGRAM  POWERSOFTWO(OUTPUT);
CONST M=30; N=90;   (* M>= N*LOG(2)   *)
VAR EXP,I,J,L: INTEGER ;
     C,R,T:INTEGER ;
    D:ARRAY(.0..M.) OF INTEGER ; (*POSITIVE POWERS*)
    F: ARRAY (.1..N.) OF INTEGER ;    (*NEGATIVE POWERS*)
BEGIN L:=0 ; R:=1; D(0):=1;
    WRITELN (CLOCK);
    INTFIELDSIZE := 1;
    FOR EXP:=1 TO N DO
    BEGIN  (*COMPUTE AND PRINT 2**EXP  *)   C:=0;
         FOR I:=0 TO L DO
         BEGIN T:=2*D(I)+C ;
              IF T>=10 THEN
                   BEGIN D(I):=T-10; C:=1
                   END
              ELSE
                   BEGIN D(I):=T; C:=0
                   END
         END;
         IF C>0 THEN
              BEGIN L:=L+1 ; D(L):=1
              END;
         FOR I:=M DOWNTO L DO WRITE(' ') ;
         FOR I:=L DOWNTO 0 DO WRITE(D(I));
         INTFIELDSIZE := 5;
         WRITE (EXP, '  .');
         INTFIELDSIZE:= 1;
         (* COMPUTE AND PRINT 2**(-EXP)    *)
         FOR J:=1 TO EXP-1 DO
         BEGIN R:=10*R+F(J) ;
              F(J):=R DIV 2; R:=R-2*F(J) ;  WRITE(F(J))
         END ;
         F(EXP):=5 ; WRITELN('5'); R:=0
    END ;
    WRITELN (CLOCK)
END .
