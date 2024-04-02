/*
    This is sample XPL program 6.18.4 from McKeeman p. 156,
    transcribed as-is, with the potential exception that from the 
    typography of the book it's impossible to tell how wide quoted
    strings of blank characters supposed to be.  
    
    Note that this sample program contains a single UTF-8 character
    (namely the logical-NOT symbol in line 27).  This should not
    be a problem.  Nevertheless, if for some reason XCOM-I fails to 
    compile this program, replace the logical-NOT by the ASCII ~ 
    character and try again.
    
    The function of the program (as described in the comment following
    this one) is to provide counts of the distinct words in input text.
    Note that the sample program's algorithm can lead to unexpected results.
    For one thing, input will terminate on any blank line.  For another,
    any character which is non-blank is treated as the start of a 
    "word".  The word continues with subsequent characters A-Z (not a-z), 
    0-9, {, }, or \ (but not any other punctuation).   Thus you get 
    expected words like RON, IS, or GREAT.  Whereas a string like "But" 
    would consist of 3 separate words: "B", "u", and "t".  And then you'd 
    have bogus words like "={\NORM\}=".
    
    With that said, if you use a file of test data consisting of all
    upper-case alphabetic words and spaces, without numbers or punctuation
    or blank lines, it appears to me that the program does produce a 
    correct result.
*/
    
/*  This program reads and lists cards until an end of file, counting
    the frequency of occurrence of each word on the cards.
*/

declare (buffer, temp, word) character, (i, cp, #entries) fixed,
  table (500) character, count (500) fixed,
  blanks character initial('


                                           ');
#entries = -1;
output = 'Input cards';
output, buffer = input;         /*  Get a card.  */

do while length(buffer) > 0;    /*  Until end of file.  */
  temp = buffer || ' ';
  do while substr(blanks,0,length(temp)) ¬= temp;
    /*  Until remainder of card is blank.  */
    do while byte(temp) = byte(' ');    /*  Discard blanks.  */
      temp = substr(temp, 1);
    end;
    cp = 1;
    
    do while byte(temp, cp) >= byte('A');
      cp = cp + 1;
    end;        /*  of a word  */
    
    word = substr(temp, 0, cp);
    temp = substr(temp, cp);    /*  Rest of card.  */
    
    do i = 0 to #entries;
      if word = table(i) then
        go to found;
    end;
    
    i, #entries = #entries + 1;
    table(i) = word;
    count(i) = 0;
    
  found:
    count(i) = count(i) + 1;
  end;
    
  output, buffer = input;     /*  Get a new card.  */
end;          /*  of do while length(buffer)  */
  
output = 'Frequency counts:';
do i = 0 to #entries;
  output = table(i) || '                ' || count(i);
end;
