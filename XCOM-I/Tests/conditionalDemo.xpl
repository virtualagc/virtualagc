/*
  This is actually intended as a demo for XCOM (from A Compiler Generator)
  rather than a demo of XCOM-I.  What I'm trying to figure out is the extent
  to which XCOM short-circuits evaluations of logical expressions of the form
  
        expression1 & expression2
  
  I have reason to believe that short circuiting occurs only in the conditionals
  of statements similar to
  
        IF conditional THEN
                statement;
  
  $E
*/

DECLARE I FIXED;

DO I = 1 TO 10;
    IF (I * I) & (100 - I * I) THEN OUTPUT = 'hello';
END;

DO I = 1 TO 10;
    IF 0 & (100 - I * I) THEN OUTPUT = 'hello';
END;

EOF