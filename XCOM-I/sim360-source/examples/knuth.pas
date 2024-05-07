PROGRAM KNUTH (INPUT, OUTPUT);
 
TYPE
  PTR = @TERM;
  TERM = RECORD
           COEF, ABC: INTEGER;
           LINK: PTR
         END;
  POLY = @TERM;
VAR
  PP, QQ: PTR;
  I: INTEGER;
   T_VEC: ARRAY (.1..8.) OF INTEGER;
PROCEDURE ADVANCE (VAR P: PTR);
BEGIN
  P := P@.LINK
END;
 
PROCEDURE FREE_POLY (VAR P: PTR);
 
VAR P1: PTR;
 
BEGIN
  ADVANCE (P);
  WHILE P@.ABC >= 0 DO
  BEGIN
    P1 := P;
    ADVANCE (P);
    DISPOSE (P1)
  END;
  DISPOSE (P)
END;
PROCEDURE ADDPOLY (VAR P, Q: PTR);
 
VAR
  Q1, Q2: PTR;
 
BEGIN
  (* STEP A1 *)
  Q1 := Q;
  ADVANCE (P);
  ADVANCE (Q);
  (* STEP A2 *)
  REPEAT
    IF P@.ABC < Q@.ABC THEN
    BEGIN
      Q1 := Q;
      ADVANCE (Q)
    END
    ELSE IF P@.ABC = Q@.ABC THEN
    BEGIN
      (* STEP A3 *)
      IF P@.ABC >= 0 THEN
      BEGIN
        Q@.COEF := Q@.COEF + P@.COEF;
        IF Q@.COEF = 0 THEN
        BEGIN
          (* STEP A4 *)
          Q2 := Q;
          ADVANCE (Q);
          Q1@.LINK := Q
        END
        ELSE
        BEGIN
          Q1 := Q;
          ADVANCE (Q)
        END;
        ADVANCE (P)
      END
    END
    ELSE BEGIN
      NEW (Q2);
      Q2@.COEF := P@.COEF;
      Q2@.ABC := P@.ABC;
      Q2@.LINK := Q;
      Q1@.LINK := Q2;
      Q1 := Q2;
      ADVANCE (P)
    END;
  UNTIL (P@.ABC < 0) AND (Q@.ABC < 0)
END;
 
PROCEDURE PRINTPOLY (VAR P: PTR);
 
TYPE TEXTLINE = ARRAY (.1..132.) OF CHAR;
 
VAR SUPERSCRIPTS, LINE: TEXTLINE;
    INDEX, XS, YS, ZS: INTEGER;
    COEFSIGNED, PRINT_ONE: BOOLEAN;
 
  PROCEDURE NUM (NN: INTEGER; VAR DUMMY, ACTUAL: TEXTLINE;
                 SIGNED, PRNT1: BOOLEAN);
 
  VAR N, D, I, J: INTEGER;
      VAL: ARRAY (.0..20.) OF CHAR;
      MINUS: BOOLEAN;
 
  BEGIN
    N := NN;
    I := -1;
    IF N < 0 THEN
    BEGIN
      MINUS := TRUE;
      N := -N
    END
    ELSE MINUS := FALSE;
    IF PRNT1 OR (ABS (N) <> 1) THEN
    REPEAT
      I := I + 1;
      D := N MOD 10;
      N := N DIV 10;
      VAL (.I.) := CHR (ORD ('0') + D)
    UNTIL N = 0;
    IF MINUS THEN
    BEGIN
      I := I + 1;
      VAL (.I.) := '-'                                                          
    END
    ELSE IF SIGNED THEN
    BEGIN
      I := I + 1;
      VAL (.I.) := '+'                                                          
    END;
    FOR J := 0 TO I DO
    BEGIN
      DUMMY (.INDEX + J.) := ' ';
      ACTUAL (.INDEX + J.) := VAL (.I - J.)
    END;
    INDEX := INDEX + I + 1
  END;
 
  PROCEDURE DOIT (N: INTEGER; C: CHAR);
  BEGIN
    IF N > 0 THEN
    BEGIN
      LINE (.INDEX.) := C;
      SUPERSCRIPTS (.INDEX.) := ' ';
      INDEX := INDEX + 1;
      NUM (N, LINE, SUPERSCRIPTS, FALSE, FALSE)
    END
  END;
 
BEGIN
  COEFSIGNED := FALSE;
  FOR INDEX := 1 TO 132 DO
  BEGIN
    SUPERSCRIPTS (.INDEX.) := ' ';
    LINE (.INDEX.) := ' '                                                       
  END;
  ADVANCE (P);
  INDEX := 1;
  WHILE P@.ABC >= 0 DO
  BEGIN
    WITH P@ DO
    BEGIN
      XS := ABC DIV 10000;
      YS := (ABC DIV 100) MOD 100;
      ZS := ABC MOD 100;
      PRINT_ONE := (ABC = 0);
      NUM (COEF, SUPERSCRIPTS, LINE, COEFSIGNED, PRINT_ONE);
      COEFSIGNED := TRUE;
      DOIT (XS, 'X');
      DOIT (YS, 'Y');
      DOIT (ZS, 'Z');
    END;
    ADVANCE (P)
  END;
  WRITELN;
  WRITELN (SUPERSCRIPTS);
  WRITELN (LINE)
END;
 
FUNCTION READPOLY: PTR;
 
VAR P, P1, START: PTR;
    FIRST: BOOLEAN;
 
BEGIN
  FIRST := TRUE;
  BEGIN
    REPEAT
      NEW (P);
      READ (P@.COEF, P@.ABC);
      IF FIRST THEN
      BEGIN
        FIRST := FALSE;
        START := P
      END
      ELSE P1@.LINK := P;
      P1 := P
    UNTIL P@.ABC < 0;
    P@.LINK := START;
    READPOLY := P
  END;
  READLN
END;
 
(* FINALLY - THE PROGRAM  *)
 
BEGIN
  WHILE NOT EOF(INPUT) DO
  BEGIN
    PP := READPOLY;
    QQ := READPOLY;
    PRINTPOLY (PP);
    PRINTPOLY (QQ);
    ADDPOLY (PP, QQ);
    PRINTPOLY (QQ);
    WRITELN
  END
END.
