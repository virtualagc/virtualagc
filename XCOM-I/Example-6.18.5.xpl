/* This is example XPL program 6.18.5 from McKeeman p. 157.
   The book only provides PROCEDURE FIX, which is transcribed as-is.
   The top-level code that exercises FIX is new. */
   
FIX:
  procedure(s) fixed;
    /*  Convert the string to an integer.  */
    declare s character, negative bit(1), (i, nval) fixed;
    
    negative = byte(s) = byte('-');
    nval = 0;
    
    do i = negative to length(s) - 1;
      nval = nval * 10 + byte(s,i) - byte('0');
    end;
    
    if negative then
      return -nval;
    else
      return nval;
      
  end FIX;

TBD
