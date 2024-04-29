/* A demo of how XPL/I ignores the distinction between subscripted 
   variables and non-subscripted variables, and (unlike XPL) does 
   not enforce subscript bounds. Both output lines should be the 
   same, namely "-2 -1 0 1 2". */

declare v fixed, w fixed, x fixed, y fixed, z fixed;
x(-2) = -2;
x(-1) = -1;
x(0) = 0;
x(1) = 1;
x(2) = 2;
output = x(-2) || ' ' || x(-1) || ' ' || x(0) || ' ' || x(1) || ' ' || x(2);
output = v || ' ' || w || ' ' || x || ' ' || y || ' ' || z;

