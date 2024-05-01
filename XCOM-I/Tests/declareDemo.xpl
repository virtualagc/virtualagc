declare i literally '5', j literally '6', k literally '7', m literally '8';
declare a fixed, b(i) fixed, c fixed initial(i), 
        d(i) fixed initial(1, 2, 3, 4, 5, 6);
declare e(i+2) fixed;
declare f fixed initial(j+3);
declare g fixed initial(-2);
declare h fixed initial(-i + 2);
declare p(3) fixed initial(i+3*j, m/2, 7*16+1/2);
declare ca character;
declare cb character initial('hello');
declare cc character initial('hello' || ' this is a string ' || 'expression');
declare cd(3) character initial ('a', 'b '||'is '||'the '||'letter!', 'c');
