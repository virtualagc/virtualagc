Contents
--------

The zipfile yaHAL-S-FC.zip contains:

 * The source code for Virtual AGC's so-called "modern" HAL/S compiler.
   Recall that HAL/S is the language in which Space Shuttle flight
   software was written.
 * Executable forms of the compiler that (hopefully) will work
   as-is on Windows (64-bit), Mac OS X, or Linux Mint/Ubuntu 64-bit.
 * A few additional helpful resources.
 
 Note, that the compiler presently generates code only in an
 intermediate-language format known as "PALMAT", and that to run the 
 compiled HAL/S program it's necessary to have a PALMAT virtual machine.
 
 However, the compiler does have an interactive mode in which you can
 compile and execute HAL/S source code, one statement at a time.
   
Setup
-----

Expand the zipfile, creating a single folder.  Add this folder to your
PATH.   

The Python 3 language must also be installed.

The compiler consists of a completely-portable portion written in 
Python 3, plus a portion written in C that must itself be compiled
before being usable.

As I said earlier, the C-language component of the compiler has been
pre-built and will hopefully work on Windows, Mac, and some Ubuntu-based
versions of Linux.  If you have another type of system, or else if the
pre-built executable *doesn't* work for you, then you'll have to rebuild
it from source ... which, fortunately, is quite easy.

Here's how to test if the executable for the C-language component works
as-is or not.  From a command-line, use one of the following commands:

	modernHAL-S-FC --help				(in Linux)
		or
	modernHAL-S-FC.exe --help			(in Windows)
		or
	modernHAL-S-FC-macosx --help			(in Mac OS X)

If you see a short menu of options appear, then the executable works.
The short menu might look something like this:

	Usage:
		modernHAL-S-FC [OPTIONS] SOURCEFILE | <SOURCEFILE
	
	The available OPTIONS are:
		--help            Print this message and quit.
		--trace           Enable parser tracing.

If not, here's how to rebuild the C-language component for your system.  
First, you have to have a C compiler installed, and to know the name 
by which it's invoked from the command line.  Here are typical compiler 
names or operator-system aliases:

	cc
	gcc
	clang
	cl

(Disclaimer: I'm only confident of gcc, or in clang insofar as it is
a drop-in replacement for gcc.  And since they're available for free
on most systems, or else come with them, I'm not inclined to explore
or vouch for the use of compilers like cl.  Take anything I say about
compilers other than gcc or clang with a grain of salt.)

I also typically use command-line options instructing the compiler to
optimize for execution speed, though no options are really necessary.
Anyway, here are some examples of the commands you might use to build
from source:

	gcc -O3 -o modernHAL-S-FC *.c			(in Linux)
		or
	cl /O2 /out modernHAL-S-FC.exe *.c		(in Windows)
		or
	clang -O3 -o modernHAL-S-FC-macosx *.c		(in Mac OS X)

Invocation
----------

The compiler can be invoked either in a "batch" mode, in which it processes
whatever HAL/S source files are fed into it for generation of a PALMAT
output file, or else in "interactive" mode.  In interactive mode, the 
user can type in HAL/S statements at the keyboard, and those are compiled
and executed immediately.

In batch mode, the compiler is invoked as follows:

	yaHAL-S-FC.py [OPTIONS] SOURCE_FILES

The PALMAT file produced is always yaHAL-S-FC.palmat.  You can see the 
available options with

	yaHAL-S-FC.py --help
	
Probably the most-important option at the current development stage is

	yaHAL-S-FC.py --interactive

which invokes the compiler as an interpreter, which accepts input on a
HAL/S statement-by-statement basis from the keyboard, and executes each 
statement immediately, as well as having a number of facilities useful
for understanding how the HAL/S language is processed by the compiler.

Interpreter Usage
-----------------

Upon running the HAL/S interpreter the first time, you're greeted with

	FYI: Structure-template library file yaHAL-default.templates 
	     doesn't exist yet.
	[HELP] > 

The FYI isn't important, and you can ignore it.  At the prompt, you 
typically input HAL/S "statements", though statements can span
multiple lines, or multiple statements can be packed on a single line.
The interpreter will accept as many lines as you wish to input, but
will only process them when it encounters an input line for which the
final character (including spaces) is a semicolon.

For example, you might enter the HAL/S statements:

	[HELP] > DECLARE I INTEGER; I = 1;

The interpreter will remember any declarations you make, as well as the
values of any variables, so if you were subsequently to use the variable
I in some other expression, it would recall that I is an INTEGER and
has the value 1.

In pure HAL/S, column 1 has a special interpretation, and must contain
one of the characters ' ', 'C', 'D', 'E', 'M', or 'S'.  This would be
very inconvenient in the interpreter, since if you're like me you'd
always be forgetting to start each line with a space, so the treatment
of column 1 is somewhat different.  If a line begins with "C " or "D "
it is still treated as a comment or a compiler directive, just as in
pure HAL/S.  However, E/M/S (exponent/main/subscript) lines are not
allowed at all. 

Thus in general, the interpreter will accept any lines other that
full-line comments or compiler directives as regular HAL/S source
code, and will automatically prepend a single space to them before
compilation.  If you want to enter code like "C = 1;" or "D = C + 5",
I'm afraid you still have to be careful to put a space in front of 
yourself, rather than beginning them in column 1.

Moreover, in addition to HAL/S code, you can also input commands for
the interpreter itself, such as "HELP" to get a list of the commands
recognized by the interpreter.  In fact, if you do that, you might
see something like this:

	[HELP] > HELP
	
	Here are the interpreter commands you can use:
	    HELP     Show this menu.
	    QUIT     Quit this interpreter program.
	    WINE     Run Windows compiler in Linux.
	    NOWINE   Run native compiler version (default).
	    TRACE    Turn on parser tracing.
	    NOTRACE  Turn off parser tracing.
	    LBNF     Show abstract syntax trees in LBNF.
	    BNF      Show abstract syntax trees in BNF.
	    NOAST    Don't show abstract syntax trees.
	    EXEC     Execute the HAL/S code.
	    NOEXEC   Don't execute the HAL/S code.
	    STATUS   Show the current VM state.
	    RECENT   Show recent lines of code, numbered.
	    RERUN    Re-run last line of code.
	    RERUN D  Re-run numbered line D (from RECENT).
	[HELP] > 

Many of these are things more helpful to me (for debugging the 
compiler) than to you, I expect.  

Debugging
---------

I would, however, like to make some special note of the interpreter
commands TRACE/NOTRACE and LBNF/BNF/NOAST.  

The compiler processes the HAL/S language in terms of what's known 
as the "grammar" of the language, which is something typically 
expressed in a language called BNF (Backus Naur Form).  Unfortunately, 
BNF, if intendend as a *full* description, applies only what are called 
"context-free" grammars.  And as originally defined by the team 
that designed HAL/S back in the 1970's, HAL/S is *not* context-free.

Our modern compiler works around this difficulty by having a 
preprocessor that "mangles" HAL/S into a slightly-different language
called "Preprocessed HAL/S" that is context-free.  This mangling
does several things, but where it will probably be most obvious 
is that identifiers (i.e., the symbolic names of variables, function,
procedures, etc.) are modified to indicate just what type of objects
the identifiers refer to.  You won't see this in numerical variables,
so for example, the variable I in "DECLARE I INTEGER;" remains as-is,
unmangled.  But various other datatypes *are* mangled, as follows:

 * BOOLEAN or BIT variables:  IDENTIFIER -> b_IDENTIFIER.
 * CHARACTER variables: IDENTIFIER -> c_IDENTIFIER.
 * and so on.
 
This is generally transparent to you, unless you happen to see 
error messages or reports generated by the compiler.  For example, 
if you input

	[HELP] > DECLARE X BOOLEAN;

the preprocessor will turn this into "DECLARE b_X BOOLEAN;" and 
statments like "IF X THEN A=1;" will turn into "IF b_X THEN A=1;",
none of which you normally have to think about.

Besides the BNF grammar of Preprocessed HAL/S, there also exists a 
description of the grammer in the LBNF language.  LBNF stands for
"labelled" BNF.  In fact, we use LBNF throughout, but also provided
some documentation in BNF, just because it's more familiar to most
programmers.  If you're so-inclined, you can compare these
various grammars at the following links:

 * Original BNF grammar of Shuttle developers.  (Necessarily 
   incomplete since the original HAL/S language isn't context-free):
   https://www.ibiblio.org/apollo/Shuttle/HAL_S%20Language%20Specification%20Nov%202005.pdf#page=209
 * Exact BNF grammar for Preprocessed HAL/S:  File "HAL-S BNF.pdf"
   in this zipfile.
 * Exact LBNF grammar for Preprocessed HAL/S:  File "HAL_S.cf"
   in this zipfile.
   
The reason I'm making a big deal of this right now, when you may
(and probably do) think that it's not even worth a big yawn, is 
that the interpreter gives you special facilities for understanding 
how each statement of HAL/S is parsed or fails to parse
according to these BNF/LBNF grammars.

By default, you see no such analysis when you input a HAL/S statement.
But if you use the interpreter's BNF command, you'll see the
BNF analysis for each statement.  For example:

	[HELP] > BNF
	Display abstract syntax trees (AST) in BNF.
	[HELP] > DECLARE I INTEGER;
	0 preprocessor warnings
	0 preprocessor errors
	Compiler pass 1 successful.
	
	Abstract Syntax Tree (AST) in BNF
	----------------------------------
	<COMPILATION> :
	░<DECLARE STATEMENT> :
	░ <DECLARE BODY> :
	░ ░<DECLARATION LIST> :
	░ ░ <DECLARATION> :
	░ ░ ░<NAME ID> :
	░ ░ ░ <IDENTIFIER> : ^I^
	░ ░ ░<ATTRIBUTES> :
	░ ░ ░ <TYPE AND MINOR ATTR> :
	░ ░ ░ ░<TYPE SPEC> :
	░ ░ ░ ░ <ARITH SPEC> :
	░ ░ ░ ░ ░<SQ DQ NAME> : <ARITH CONV>
	[HELP] > 

Or if you use the interpreter's LBNF command:

	[HELP] > lbnf
	Display abstract syntax trees (AST) in LBNF.
	[HELP] > DECLARE I INTEGER;
	0 preprocessor warnings
	0 preprocessor errors
	Compiler pass 1 successful.
	
	Abstract Syntax Tree (AST) in LBNF
	----------------------------------
	ACcompilation :
	░AAdeclare_statement :
	░ AAdeclare_body :
	░ ░AAdeclaration_list :
	░ ░ ABdeclarationNameWithAttributes :
	░ ░ ░AAname_id :
	░ ░ ░ FFidentifier : ^I^
	░ ░ ░ACattributes :
	░ ░ ░ AAtype_and_minor_attr :
	░ ░ ░ ░ADtypeSpecArith :
	░ ░ ░ ░ ABarith_spec :
	░ ░ ░ ░ ░ABsq_dq_name : AAarithConvInteger
	[HELP] > 

If you look closely at these, you'll see why the LBNF grammar may be a
bit more useful than the BNF grammar in some ways.  The BNF grammar
tree tells us that I has been declared as an <ARITH CONV> but it 
doesn't tell us which kind of <ARITH CONV> it may be:  INTEGER?
SCALAR? VECTOR? MATRIX?  Whereas the LBNF grammar is specific that 
I has been declared as AAarithConvInteger; i.e., INTEGER.  But 
I digress!

Or you can just use the NOAST interpreter command to turn of the printouts
for these BNF/LBNF analyses.

What's particularly useful if a statement *won't* parse, due to some
bug in the preprocessor or compiler, or I guess, in whatever HAL/S syntax
you've used, is the interpreter's TRACE command.  This command traces the
parsing up to the very point of failure, so you can see why the parser
failed.  For example, suppose we were to try the following:

	[HELP] > IF I THEN A=1;
	0 preprocessor warnings
	0 preprocessor errors
	Error: 1,7: syntax error at THEN
	 IF I THEN A=1;
	       ^
	Compiler pass 1 failure.
	[HELP] > 

It fails, but why did it fail?  

	[HELP] > TRACE
	TRACE on.
	[HELP] > IF I THEN A=1;
	0 preprocessor warnings
	0 preprocessor errors
	Starting parse
	Entering state 0
	...
	Entering state 293
	Stack now 0 67 293
	Reducing stack by rule 1 (line 645):
	   $1 = nterm TERM (1.5: )
	-> $$ = nterm ARITH_EXP (1.5: )
	Entering state 375
	Stack now 0 67 375
	Next token is token THEN (1.7-10: )
	Error: 1,7: syntax error at THEN
	 IF I THEN A=1;
	       ^
	Error: popping nterm ARITH_EXP (1.5: )
	Stack now 0 67
	Error: popping nterm IF (1.2-3: )
	Stack now 0
	Cleanup: discarding lookahead token THEN (1.7-10: )
	Stack now 0
	Compiler pass 1 failure.
	[HELP] > 

As you can see, the trace is very long, so I've had to cut out a bunch of 
it in the middle.  Even so, the trace isn't exactly easy to read.
However, I think that you can see that the parser got as far as 
determining that we have an "IF", followed by an "ARITH_EXP" (which is
its way of referring to the BNF type <ARITH-EXP>), followed by the token
"THEN, before bailing out. 

So why did it fail?  Because if you look in the BNF grammar, you find
that there's no rule for a token "IF" followed by an <ARITH-EXP> 
followed by a token "THEN".  You do find that "IF" can be followed 
by a <RELATIONAL-EXP> or a <BIT-EXP> ... and aha!  This clues us into
the fact that any expression following the "IF" is going to have to
evaluate to a BOOLEAN or BIT, so that it can reduce ultimately to TRUE 
or FALSE.  Whereas I is numerical and not boolean.  This reminds us that
HAL/s enforces the distinction between arithmeticals and booleans, and 
*won't* just automatically say that 0 is the same as FALSE and non-zero 
is the same as TRUE as many of us are used to.

If we instead did the following:

	[HELP] > NOTRACE
	TRACE off.
	[HELP] > DECLARE I BOOLEAN;
	0 preprocessor warnings
	0 preprocessor errors
	Compiler pass 1 successful.
	[HELP] > BNF
	Display abstract syntax trees (AST) in BNF.
	[HELP] > IF I THEN A=1;
	0 preprocessor warnings
	0 preprocessor errors
	Compiler pass 1 successful.
	
	Abstract Syntax Tree (AST) in BNF
	----------------------------------
	<COMPILATION> :
	░<ANY STATEMENT> :
	░ <STATEMENT> :
	░ ░<OTHER STATEMENT> :
	░ ░ <IF STATEMENT> :
	░ ░ ░<IF CLAUSE> : <IF>
	░ ░ ░ <BIT EXP> :
	░ ░ ░ ░<BIT FACTOR> :
	░ ░ ░ ░ <BIT CAT> :
	░ ░ ░ ░ ░<BIT PRIM> :
	░ ░ ░ ░ ░ <BIT VAR> :
	░ ░ ░ ░ ░ ░<BIT ID> : ^b_I^
	░ ░ ░<STATEMENT> :
	░ ░ ░ <BASIC STATEMENT> :
	░ ░ ░ ░<ASSIGNMENT> :
	░ ░ ░ ░ <VARIABLE> :
	░ ░ ░ ░ ░<ARITH VAR> :
	░ ░ ░ ░ ░ <ARITH ID> :
	░ ░ ░ ░ ░ ░<IDENTIFIER> : ^A^
	░ ░ ░ ░ <EQUALS>
	░ ░ ░ ░ <EXPRESSION> :
	░ ░ ░ ░ ░<ARITH EXP> :
	░ ░ ░ ░ ░ <TERM> :
	░ ░ ░ ░ ░ ░<PRODUCT> :
	░ ░ ░ ░ ░ ░ <FACTOR> :
	░ ░ ░ ░ ░ ░ ░<PRIMARY> :
	░ ░ ░ ░ ░ ░ ░ <PRE PRIMARY> :
	░ ░ ░ ░ ░ ░ ░ ░<NUMBER> :
	░ ░ ░ ░ ░ ░ ░ ░ <LEVEL> : ^1^
	[HELP] > 

Now it works, because I is declared as a BOOLEAN rather than an INTEGER.  
And as a side note, if you glance through the BNF that was printed out, 
you'll notice that even though we referred to "I" in the HAL/S source
code we typed in, internally the preprocessor has mangled "I" to "b_I"
to indicate that it is a BOOLEAN.


