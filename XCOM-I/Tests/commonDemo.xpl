/* 
  A demo of COMMON.  What you do is run the program multiple times.
  Each time it is run, it prints whatever values it already finds in
  COMMON.  It then generates a new random set of values, printing
  them and storing them to COMMON.  So every time the program runs,
  the *first* thing it prints is the *last* thing it printed on the
  prior run.  Actually, it prints two lines each time, one for COMMON
  variables and one for DECLARE'd variables.  Only the COMMON variables
  should match as described.
  
  By default, the program does not restore the data in COMMON upon
  entry, but does save the data in COMMON upon exit to a file called
  COMMON.out.  To make the program work as expected, we need to use
  different command-line switches on the 2nd and subsequent runs, to
  make sure that COMMON is restored from COMMON.out, like so:
  
        aout 
        aout --commoni=COMMON.out
        aout --commoni=COMMON.out
        ...
        aout --commoni=COMMON.out
*/

/* The random-number generator from "A Compiler Generator", Example 6.18.6,
   except that I've changed it to randomize the seed using the current
   time. */
declare rbase fixed;
rbase = TIME;
RANDOM:
  procedure(range) fixed;
    /*  Returns a random integer in the range 0 to range - 1  */
    
    declare range fixed, /* rbase fixed initial(1), */
      rmult literally '671297325';
      
    rbase = rbase * rmult;
    
    return shr(shr(rbase, 16) * range, 16);
    
  end RANDOM;

declare a fixed initial(1), b fixed initial(2), c fixed initial(3);
common (x, y, z) fixed;
declare d character initial(4), e character initial(5), f character initial(6);
common (u, v, w) character;

output = 'DECLARE: ' || a || ' ' || b || ' ' || c || ' ' 
                     || d || ' ' || e || ' ' || f;
output = 'COMMON: ' || x || ' ' || y || ' ' || z || ' ' 
                    || u || ' ' || v || ' ' || w;

a = RANDOM(1000);
b = RANDOM(1000);
c = RANDOM(1000);
d = d || '-' || RANDOM(1000);
e = e || '-' || RANDOM(1000);
f = f || '-' || RANDOM(1000);
u = u || '-' || RANDOM(1000);
v = v || '-' || RANDOM(1000);
w = w || '-' || RANDOM(1000);
x = RANDOM(1000);
y = RANDOM(1000);
z = RANDOM(1000);

output = 'DECLARE: abcdef = ' || a || ' ' || b || ' ' || c || ' ' 
                     || d || ' ' || e || ' ' || f;
output = 'COMMON: xyzuvw = ' || x || ' ' || y || ' ' || z || ' ' 
                    || u || ' ' || v || ' ' || w;

