/* Filename: foldingText.xpl.  In 1970's XPL, every one of the expressions
   in the INITIAL clause would be a syntax error.  In Intermetrics XPL,
   at least the -8 would have been legal, but I don't know about the others. */

DECLARE R(5+5) BIT(32) INITIAL(1+1, 3-1, 3*4, 10/2, 7 MOD 4, -8, ~1);
DECLARE X FIXED INITIAL( 2*(1+3)/2 - 7*((8/2)+1) );
DECLARE I FIXED;

DO I = 0 TO 10;
    OUTPUT = 'R(' || I || ') = ' || R(I);
END;

OUTPUT = 'X = ' || X;

EOF EOF EOF