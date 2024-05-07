PROGRAM COUNTCHARACTERS(INPUT,OUTPUT) ;
    VAR CH: CHAR ;
        C0,C1,C2,C3,C4,C5: INTEGER ;   (* COUNTERS *)
BEGIN
    WRITELN (CLOCK);
    C0:=0 ;C1:=0 ;C2:=0 ;C3:=0 ;C4:=0 ;C5:=0 ;
    WHILE NOT EOF(INPUT) DO
    BEGIN WRITE(' ') ; C0:=C0+1 ;
        WHILE NOT EOLN(INPUT) DO
        BEGIN READ(CH) ;
              WRITE(CH) ;
              IF CH=' ' THEN C1:=C1+1 ELSE
              IF CH IN (.'a'..'z'.) THEN C2:=C2+1 ELSE
              IF CH IN (.'A'..'Z'.) THEN C3:=C3+1 ELSE
              IF CH IN (.'0'..'9'.) THEN C4:=C4+1 ELSE C5:=C5+1
        END ;
        READLN ; WRITELN ;
    END ;
    WRITELN (CLOCK);
    WRITELN(C0,' LINES') ;
    WRITELN(C1,' BLANKS') ;
    WRITELN(C2,' Lower case letters') ;
    WRITELN(C3,' UPPER CASE LETTERS') ;
    WRITELN(C4,' DIGITS') ;
    WRITELN(C5,' SPECIAL CHARACTERS') ;
END.
