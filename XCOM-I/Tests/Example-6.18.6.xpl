/* This is example XPL program 6.18.6 from McKeeman p. 157.
   The book only provides PROCEDURE RANDOM, which is transcribed as-is.
   The top-level code that exercises RANDOM is new. */
   
RANDOM:
  procedure(range) fixed;
    /*  Returns a random integer in the range 0 to range - 1  */
    
    declare range fixed, rbase fixed initial(1),
      rmult literally '671297325';
      
    rbase = rbase * rmult;
    
    return shr(shr(rbase, 16) * range, 16);
    
  end RANDOM;

declare i fixed;

do i = 1 to 100;
  output = RANDOM(100000);
end;

output = '';

eof
