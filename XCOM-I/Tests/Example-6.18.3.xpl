/*  This is example XPL program 6.18.3 from McKeeman p. 155,
    transcribed as-is. */
    
/*  This program reads n cards (n = 100), sorts them in
    alphabetical (collating) order, and prints them.  */

declare n literally '100';
declare cards(n) character, (i,k,l) fixed, temp character;

output = 'Input cards:';
do i = 1 to n;
   output, cards(i) = input;       /*  read and list  */
end;

k,l = n;
do while k <= l;                   /* bubble sort loop  */
   l = - n;
   
   do i = 1 to k;
      l = i - 1;
      if cards(l) > cards(i) then
         do;
            temp = cards(l);
            cards(l) = cards(i);
            cards(i) = temp;
            k = l;
         end;
   end;
end;                               /* of sort loop  */

output = 'Sorted cards:';
do i = l to n;
   output = cards(i);
end;

eof
