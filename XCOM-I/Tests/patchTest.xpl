/* Test of XCOM-I facility for patching CALL INLINEs.  There are some 
   associated patches:  */
   
output = 'this is the first line';
output = 'this is the second line';
call inline(1, 2, 3);
call inline(2, 3, 4);
call inline(3, 4, 5, 6);
call inline(4, 5, 6, 7, 8);
output = 'this is the penultimate line';
output = 'this is the last line';
output = '';

eof
