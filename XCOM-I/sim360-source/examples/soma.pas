PROGRAM SOMA(OUTPUT);
 
 
   (*************************************************************************
   *                                                                        *
   *               SOLUTIONS TO THE SOMA CUBE PROBLEM                       *
   *                                                                        *
   *                     A PASCAL PROGRAM                                   *
   *                     BY RANCE DELONG                                    *
   *                     MORAVIAN COLLEGE                                   *
   *                                                                        *
   *                     PUBLISHED IN ACM SIGPLAN NOTICES                   *
   *                     VOL. 9 NO. 10 (OCTOBER 1974)                       *
   *                                                                        *
   *************************************************************************)
 
 
 
TYPE
   CUBE_SET = SET OF 1..27;
   WHERE = (TOP, BOTTOM, RIGHT, LEFT, FRONT, BACK, NOWHERE);
   PIECE_DESCRIPTION = ARRAY (.1..3.) OF WHERE;
   AXES = (TBAXIS, RLAXIS, FBAXIS);
   HASH_VALUE = 0..58;
   PLIST_PTR = @ POSN_LIST_ELEMENT;
   WHERE_SET = SET OF WHERE;
   PIECE_RANGE = 1..7;
   POSN_LIST_ELEMENT = RECORD
                          PC_POSITION : CUBE_SET;
                          NEXT_POSN : PLIST_PTR
                       END;
 
VAR
   THE_CUBE : CUBE_SET;
   PIECE : ARRAY (.1..7.) OF PIECE_DESCRIPTION;
   MAJOR_ROTATIONS : ARRAY (.0..1.) OF AXES;
   ROTATED : ARRAY (.AXES,WHERE.) OF WHERE;
   SHIFT : ARRAY (.WHERE.) OF INTEGER;
   HASH : ARRAY (.WHERE,1..2.) OF INTEGER;
   POSN_LISTHEAD, SOLUTION_PTR : ARRAY (.1..7.) OF PLIST_PTR;
   THOSE_CONSIDERED : SET OF HASH_VALUE;
   P, I, SOLUTIONS : INTEGER;
   NUMBER_USED : INTEGER;
 
 
 
FUNCTION ORD1(S:WHERE_SET) : INTEGER;
   VAR I,J : INTEGER;   W : WHERE;
   BEGIN
      I := 0; J := 1;
      FOR W := TOP TO NOWHERE DO
         BEGIN
            IF W IN S THEN I := I + J;
            J := 2*J
         END;
      ORD1 := I
   END (**** ORD1 ****) ;
 
 
PROCEDURE INITIALIZE;
   BEGIN
      PIECE(.1,1.) := RIGHT; PIECE(.1,2.) := FRONT; PIECE(.1,3.) := NOWHERE;
      PIECE(.2,1.) := RIGHT; PIECE(.2,2.) := FRONT; PIECE(.2,3.) := FRONT;
      PIECE(.3,1.) := RIGHT; PIECE(.3,2.) := FRONT; PIECE(.3,3.) := RIGHT;
      PIECE(.4,1.) := RIGHT; PIECE(.4,2.) := FRONT; PIECE(.4,3.) := RIGHT;
      PIECE(.5,1.) := RIGHT; PIECE(.5,2.) := TOP;   PIECE(.5,3.) := FRONT;
      PIECE(.6,1.) := RIGHT; PIECE(.6,2.) := FRONT; PIECE(.6,3.) := TOP;
      PIECE(.7,1.) := RIGHT; PIECE(.7,2.) := TOP;   PIECE(.7,3.) := FRONT;
      MAJOR_ROTATIONS(.0.) := FBAXIS; MAJOR_ROTATIONS(.1.) := RLAXIS;
      ROTATED(.TBAXIS,TOP.) := TOP; ROTATED(.TBAXIS,BOTTOM.) := BOTTOM;
      ROTATED(.TBAXIS,RIGHT.) := BACK; ROTATED(.TBAXIS,LEFT.) := FRONT;
      ROTATED(.TBAXIS,FRONT.) := RIGHT; ROTATED(.TBAXIS,BACK.) := LEFT;
      ROTATED(.TBAXIS,NOWHERE.) := NOWHERE;
      ROTATED(.RLAXIS,TOP.) := FRONT; ROTATED(.RLAXIS,BOTTOM.) := BACK;
      ROTATED(.RLAXIS,RIGHT.) := RIGHT; ROTATED(.RLAXIS,LEFT.) := LEFT;
      ROTATED(.RLAXIS,FRONT.) := BOTTOM; ROTATED(.RLAXIS,BACK.) := TOP;
      ROTATED(.RLAXIS,NOWHERE.) := NOWHERE;
      ROTATED(.FBAXIS,TOP.) := LEFT; ROTATED(.FBAXIS,BOTTOM.) := RIGHT;
      ROTATED(.FBAXIS,RIGHT.) := TOP; ROTATED(.FBAXIS,LEFT.) := BOTTOM;
      ROTATED(.FBAXIS,FRONT.) := FRONT; ROTATED(.FBAXIS,BACK.) := BACK;
      ROTATED(.FBAXIS,NOWHERE.) := NOWHERE;
      SHIFT(.TOP.) := 9; SHIFT(.BOTTOM.) := -9; SHIFT(.RIGHT.) := 1;
      SHIFT(.LEFT.) := -1; SHIFT(.FRONT.) := 3; SHIFT(.BACK.) := -3;
      SHIFT(.NOWHERE.) := 0;
      HASH(.TOP,1.) := 1; HASH(.TOP,2.) := 6; HASH(.BOTTOM,1.) := -1;
      HASH(.BOTTOM,2.) := -6; HASH(.RIGHT,1.) := 2; HASH(.RIGHT,2.) := 19;
      HASH(.LEFT,1.) := -2; HASH(.LEFT,2.) := -19; HASH(.FRONT,1.) := 3;
      HASH(.FRONT,2.) := 32; HASH(.BACK,1.) := -3; HASH(.BACK,2.) := -32;
      HASH(.NOWHERE,1.) := 0; HASH(.NOWHERE,2.) := 0;
      THE_CUBE := (..);
      INTFIELDSIZE := 3;
      NUMBER_USED := 0;
      SOLUTIONS := 0
   END (**** INITIALIZE ****) ;
 
 
PROCEDURE RECORD_SOLUTION;
   BEGIN
      SOLUTIONS := SOLUTIONS + 1;
      WRITELN(' SOLUTION ', SOLUTIONS);
      IF (SOLUTIONS MOD 25) = 0 THEN
         WRITELN('* * * * ELAPSED CPU TIME =', 10*CLOCK, ' MILLISECONDS.');
      FOR (* PIECES *) P := 1 TO 7 DO
         BEGIN
            WRITE(P, '   ');
            WITH SOLUTION_PTR(.P.)@ DO
               FOR I := 1 TO 27 DO IF I IN PC_POSITION THEN WRITE(I);
            WRITELN
         END;
      WRITELN
   END (**** RECORD_SOLUTION ****) ;
 
 
FUNCTION ORIENTATION(PIECE:PIECE_DESCRIPTION) : HASH_VALUE;
   VAR PC : SET OF WHERE;
   BEGIN   (* SYMMETRIC ORIENTATIONS RECEIVE SAME VALUE *)
      IF P IN (.1,2,7.) THEN
         IF ODD(ORD(PIECE(.1.))) THEN
               PC := (.PRED(PIECE(.1.)),PIECE(.2.).)
            ELSE PC := (.SUCC(PIECE(.1.)),PIECE(.2.).);
      CASE P OF
         1,2   : ORIENTATION := ORD1(PC) DIV 2
                          + 32*ORD(ORD(PIECE(.1.)) > ORD(PIECE(.3.)));
         3     : ORIENTATION := ABS(ABS(HASH(.PIECE(.1.),1.)
                          + HASH(.PIECE(.3.),1.)) + HASH(.PIECE(.2.),2.));
         4,5,6 : ORIENTATION := ABS(HASH(.PIECE(.1.),1.)
                          + HASH(.PIECE(.2.),2.) + HASH(.PIECE(.3.),1.));
         7     : ORIENTATION := ORD1(PC + (.PIECE(.3.).))
      END
   END (**** ORIENTATION ****) ;
 
 
PROCEDURE ROTATE(VAR PIECE : PIECE_DESCRIPTION; AXIS : AXES);
   BEGIN
      FOR I := 1 TO 3 DO
         PIECE(.I.) := ROTATED(.AXIS,PIECE(.I.).)
   END (**** ROTATE ****) ;
 
 
PROCEDURE GENERATE_TRANSLATIONS(PIECE : PIECE_DESCRIPTION;
                                ORIENTATION : HASH_VALUE);
   VAR RLDISP, FBDISP, DISP, J : INTEGER;
       SIZE, PART : ARRAY (.0..3.) OF INTEGER;
       CUBICLE : 1..27;
   BEGIN RLDISP := 1; FBDISP := 3; PART(.0.) := 1;
      FOR I := 0 TO 3 DO SIZE(.I.) := 3;
      THOSE_CONSIDERED := THOSE_CONSIDERED + (.ORIENTATION.);
      FOR I := 1 TO 3 DO
         BEGIN
            PART(.0.) := PART(.0.) + ORD(PIECE(.I.)) MOD 2
                        * (-SHIFT(.PIECE(.I.).));
            SIZE(.ORD(PIECE(.I.)) DIV 2.) := SIZE(.ORD(PIECE(.I.)) DIV 2.) - 1;
         END;
      IF (* PIECE *) P IN (.3,7.) THEN
         FOR I := 1 TO 3 DO
            PART(.I.) := PART(.I DIV 2.) + SHIFT(.PIECE(.I.).)
      ELSE
         FOR I := 1 TO 3 DO
            PART(.I.) := PART(.I-1.) + SHIFT(.PIECE(.I.).);
      FOR I := 1 TO SIZE(.0.)*SIZE(.1.)*SIZE(.2.) DO
         BEGIN
            WITH SOLUTION_PTR(.P.)@ DO (* ADD POSITION TO LIST *)
               BEGIN
                  PC_POSITION := (..);
                  FOR J := 0 TO 3 DO
                     BEGIN
                        CUBICLE := PART(.J.);
                        PC_POSITION := PC_POSITION + (.CUBICLE.)
                     END;
                  NEW(NEXT_POSN);
                  SOLUTION_PTR(.P.) := NEXT_POSN;
                  NEXT_POSN@.NEXT_POSN := NIL
               END;
            IF I MOD SIZE(.1.) = 0 THEN (* SHIFT TO NEW POSITION *)
               BEGIN (* FORWARD, BACKWARD OR UPWARD MOVEMENT *)
                  RLDISP := -RLDISP;
                  IF I MOD (SIZE(.1.)*SIZE(.2.)) = 0 THEN
                     BEGIN
                        FBDISP := -FBDISP;
                        DISP := 9;
                     END
                  ELSE DISP := FBDISP
               END
            ELSE DISP := RLDISP  (* RIGHT OR LEFT *) ;
           FOR J := 0 TO 3 DO PART(.J.) := PART(.J.) + DISP
         END
   END (**** GENERATE_TRANSLATIONS ****) ;
 
 
PROCEDURE GENERATE_PIECE_POSITIONS;
   VAR M, MINOR_ROTATIONS : INTEGER; THIS_ORIENTATION : HASH_VALUE;
   BEGIN
      FOR (* PIECES *) P := 1 TO 7 DO
         BEGIN
            THOSE_CONSIDERED := (..);
            NEW(POSN_LISTHEAD(.P.)); SOLUTION_PTR(.P.) := POSN_LISTHEAD(.P.);
            FOR (* MAJOR_ROTATIONS *) M := 1 TO 6 DO
               BEGIN
                  FOR MINOR_ROTATIONS := 1 TO 4 DO
                     BEGIN
                        THIS_ORIENTATION := ORIENTATION(PIECE(.P.));
                        IF NOT(THIS_ORIENTATION IN THOSE_CONSIDERED) THEN
                           GENERATE_TRANSLATIONS(PIECE(.P.),THIS_ORIENTATION)
                        ELSE
                           REPEAT
                              ROTATE(PIECE(.P.),TBAXIS);
                              MINOR_ROTATIONS := MINOR_ROTATIONS + 1
                           UNTIL MINOR_ROTATIONS > 3;
                        ROTATE(PIECE(.P.),TBAXIS);
                     END;
                  ROTATE(PIECE(.P.),MAJOR_ROTATIONS(.M MOD 3 DIV 2.))
               END
         END;
      POSN_LISTHEAD(.2.)@.NEXT_POSN@.NEXT_POSN@.NEXT_POSN := NIL
   END (**** GENERATE_PIECE_POSITIONS ****) ;
 
 
PROCEDURE GENERATE_SOLUTIONS(PC_NUM : PIECE_RANGE);
   BEGIN
      NUMBER_USED := NUMBER_USED + 1;
      SOLUTION_PTR(.PC_NUM.) := POSN_LISTHEAD(.PC_NUM.);
      WHILE SOLUTION_PTR(.PC_NUM.)@.NEXT_POSN <> NIL DO
         WITH SOLUTION_PTR(.PC_NUM.)@ DO
         BEGIN
            IF THE_CUBE * PC_POSITION = (..) THEN
               BEGIN
                  THE_CUBE := THE_CUBE + PC_POSITION;
                  IF NUMBER_USED = 7 THEN RECORD_SOLUTION
                     ELSE GENERATE_SOLUTIONS(PC_NUM MOD 7 + 1);
                  THE_CUBE := THE_CUBE - PC_POSITION
               END;
            SOLUTION_PTR(.PC_NUM.) := NEXT_POSN
         END;
      NUMBER_USED := NUMBER_USED - 1
   END (**** GENERATE_SOLUTIONS ****) ;
 
 
BEGIN
   INITIALIZE;
   GENERATE_PIECE_POSITIONS;
   GENERATE_SOLUTIONS(2)
END (**** SOMA ****) .
