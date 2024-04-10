# Introduction

First, let me get some terminology out of the way:

  * "McKeeman":  This is how I refer to the book *A Compiler Generator* by McKeeman *et al*.  
  * "XPL":  This is how I refer to the computer language defined in McKeeman.
  * "XCOM":  This is what the original compiler for XPL was called.  The source code for this compiler appears in McKeeman.
  * "XPL/I":  This is how I refer to the *extended* form of the XPL language created by Intermetrics, as coupled to the IBM System/360 computing environment, but alas without adequate known-surviving documentation.  My belief is that Intermetrics referred to this language simply as "XPL", without making the (in my opinion necessary) distinction between it and XPL-I.  I believe similarly that they continued to use the name "XCOM" for their compiler for XPL/I, for which the source code, to the best of my knowledge, has not survived.
  * "HAL/S-FC": The Intermetrics compiler for the HAL/S computer language in which Space Shuttle flight software was written.  HAL/S-FC is written in XPL/I, along with some portions in IBM's Basic Assembly Language (BAL).  The source code for it is in the Virtual AGC source-code repository.
  * "p-HAL-S-FC":  A hypothetical form of HAL/S-FC, ported into a form which can be executed in a modern computing environment.
  * "PASS" (or "PFS") and "BFS" are the top-level Space Shuttle flight-software programs, written in HAL/S-FC.

`XCOM-I.py` is my XPL/I compiler, a work in progress, written from scratch without any reference to the original XCOM compiler(s).  Its ultimate goal, upon completion, is to be capable of compiling the source code for HAL/S-FC, producing `p-HAL-S-FC`, and thence using `p-HAL-S-FC` to compile PASS and BFS.

Because of the nature of the extensions to XPL within XPL/I, the lack of documentation, and the very close ties to the IBM System/360 computing environment, this goal for `XCOM-I.py` is not likely to be 100% achievable.  In lieu of the attainability of the ideal, the following more-practical roadmap are envisaged:

 1. 100% correctness in compiling XPL source code.
 2. 100% correctness in compiling XPL/I code *sans* any inline BAL.
 3. Compiling with included BAL as well.

Presently, I have increasing confidence that milestones #1 and #2 are achievable, and that fairly-satisfactory workarounds can be achieved for milestone #3.

With that said, in the (I think unlikely) event that somebody would want to use `XCOM-I.py` to compile a "pure" XPL program, it should perhaps be noted that XPL/I is not a 100% drop-in replacement for XPL:  I.e., XPL/I does not merely add new features to XPL, but sometimes also changes the behavior of existing features of XPL, so that those features don't operate as they did previously.  Therefore, it's possible that compiling an XPL program using an XPL/I compiler would result in a compilation failure or in a compiled program that didn't operate as intended.  The significant language features impacted, so far as I'm aware, are:

  * Macros.  Syntactically these are the same as variables `DECLARE`'d with the attribute `LITERALLY`, but in fact that are used for preprocessing only, and result in literal substitutions of the "variable" by replacement strings.  The difference between XPL and XPL/I is that in XPL the scope of such macros is the entire remainder of the compilation, whereas in XPL/I the scope is confined to the block (such as a `PROCEDURE`) in which the macros are defined plus the sub-blocks thereof.  For example, in XPL/I you could have multiple declarations of macros of the same name but within different scopes, whereas the same apparent declarations in XPL would apply to different sections of code. Or perhaps would be disallowed entirely.

# Output of XCOM-I.py

Rather than calling `XCOM-I.py` a "compiler", it would perhaps be more accurate to call it a "translator":  It does not produce executable code.  Rather, it converts now-obsoleted XPL/I to some more-standard, more-accessible high-level computer language.

The target output language is presently undecided, but hopefully `XCOM-I.py` will be modular enough that the code-generator module for the target output language could be swapped with another if there were some desire to do so.  For historical reasons, some sections of this README discuss the possibility that the target language could be Python, but it is currently almost certain that the target language in fact will be C.

A significant problem posed by modern high-level languages with respect to XPL/I translation is that XPL/I code (at least the code for XCOM and HAL/S-FC) makes heavy use of the GOTO statement.  Furthermore, this GOTO allows jumping into possibly-deeply-nested statement hierarchies, such as `DO...END` blocks.  Implications of this fact are covered in the Appendix.

# Source Code of XPL or XPL/I Programs

XPL source code accepted by `XCOM-I.py` is assumed to be encoded in 7-bit ASCII (as opposed to EBCDIC or UTF-8).  The XPL logical-not character ('¬'), which does not exist in 7-bit ASCII, is assumed to be represented instead by the ASCII carat ('^') or tilde ('&tilde;') character.  I've seen examples of both in existing XPL or XPL/I code.  With that said, on my (Linux) computer at least, XPL/I source code containing the logical-not compiles fine. Internally, `XCOM-I.py` transparently converts all of these characters to '&tilde;'.

# Some Inferred Characteristics of XPL/I

Unfortunately, while some differences between XPL/I and XPL are noted in contemporary documentation, I don't think there's a complete list of such differences in enough technical detail to answer all of my concerns.  [Section 13.0 of document IR-182-1](https://www.ibiblio.org/apollo/Shuttle/19760020796.pdf#page=822) (beginning on PDF p. 822) does have at least a partial list.

Besides which, I don't regard McKeeman as being a complete description of XPL in the first place ... although part of that is that the book is so poorly indexed (and not available at this time in digital form for searching) that it may well describe features of the language that I think it has not.  McKeeman tells us that "XPL ... [is] a dialect of PL/I, ... [chosen because it] will probably be the next dominant programming language."  Ha!  Even in 1970, when the book was written, I wonder how many folks would have agreed with that statement.  Well, that's neither here nor there.  The point is that PL/I is certainly a *much* better documented language than XPL, so when information about XPL is lacking, it can perhaps instead be inferred from documentation about PL/I.

Here are some of my own inferences in that regard:

  * Reserved words, built-in functions, and user-defined identifiers are *case-insensitive*, although quoted strings are case-sensitive.
  * Although the principal numeric datatype (`FIXED`) is an unsigned integer, XPL doesn't allow negative numeric constants such as -6.  Rather, '-' is a unary operator, so -6 is the unary operator '-' operating on the numeric constant 6.  Moreover, mathematical expressions such as `X + -1` or `X - -1` or `X + -Y` are not syntactically correct either, and if you want to have computations like this, you have to employ parentheses, such as `X + (-1)`.  Or at least, that's what the BNF in McKeeman implies, as far as I can tell, because possible rules for &lt;arithmetic expression> include &lt;arithmetic expression> + &lt;term> and &lt;arithmetic expression> + ( &lt;arithmetic expression> ), but *do not* include &lt;arithmetic expression> + &lt;arithmetic expression>.  Of course, it's possible I'm reading McKeeman wrong.  However, among the differences between XPL/I and XPL, IR-182-1 (p. 13-3) mentions explicitly that the `INITIAL` attribute in `DECLARE` statements do not allow negative constants in XPL but do allow them in XPL/I, which seems to be related to this oddity; it remains TBD as of this writing whether XPL/I removes this oddity in any larger sense.

# Source-Code File Inclusions

There are several types of comments or comment-like constructs in the XPL/I source code for HAL/S-FC that seem to me to be directives for including other source-code files within the XPL/I file being compiled.  This is almost-entirely undocumented, so I'm guessing.

Here are some from PASS1.PROCS/##DRIVER.xpl:
<pre>
 /%INCLUDE COMMON %/
 /* INCLUDE COMMON DECLS FOR REL19:  $%COMDEC19 */
 /* INCLUDE TABLE FOR DOWNGRADES:    $%DWNTABLE */
 /* INCLUDE ERROR DECLARATIONS:      $%CERRDECL */
 /* INCLUDE DOWNGRADE SUMMARY:       $%DOWNSUM  */
</pre>
In spite of the varying syntax, I would interpret all of these the same way:  to include the files HALINCL/COMMON.xpl, HALINCL/COMDEC19.xpl, HALINCL/DWNTABLE.xpl, HALINCL/CERRDECL.xpl, and HALINCL/DOWNSUM.xpl, respectively.  Why are these files in the HALINCL/ folder?  Perhaps that's specified in the JCL.  Who knows?

Why the varying syntax?  Perhaps the `/*...*/` form provides for the additional commenting associated with the inclusion, while the `/%...%/` form doesn't.  Again, who knows?  I don't believe that McKeeman et al mentions the `/%...%/` construct, so I suppose it's specific to XPL/I and absent from XPL.  McKeeman et al (p. 147) does explain that the '$' character in a comment is an escape code, causing the next character encountered to be treated as a compiler directive, and lists the interpretations of various of these compiler-directive characters.  Unfortunately, '%' is not among the compiler directives explained, so I suppose it's some innovation of XPL/I.  I.e., I suppose it's the "$%filename" which causes the file to be included, and that the presence of the word "INCLUDE" in `/* INCLUDE ... $%filename */` is irrelevant.

Furthermore, all or almost all of the XPL/I source-code files for HAL/S-FC reference global variables declared in ##DRIVER.xpl, but do not have any INCLUDE directives for that file.  I therefore suppose that the declarations in ##DRIVER.xpl are available (in XPL/I only) to all of the other XPL/I source-code files comprising the same program.  The reason for this may perhaps be found within ##DRIVER.xpl itself, in a sequence of inline comments appearing between the declaration section the the active code section of ##DRIVER.xpl:
<pre>
 /**MERGE PAD          PAD                             */
 /**MERGE CHARINDE     CHAR_INDEX                      */
 /**MERGE ERRORS       ERRORS                          */
 ...
 /**MERGE COMPILAT     COMPILATION_LOOP                */
 /**MERGE ERRORSUM     ERROR_SUMMARY                   */
 /**MERGE PRINTSUM     PRINT_SUMMARY                   */
</pre>
If instead of interpreting these lines as comments, we instead pretend they are inclusion directives interpreted as
<pre>
    /**MERGE filename procedure_name */
</pre>
where the files being included are within the same folder as ##DRIVER.xpl, then all of the included procedures would indeed have access to all of the declarations made within ##DRIVER.xpl, as well as determining the compilation order.

> **Note:** Recall (or be informed) that the source-code files of the HAL/S-FC program, other than those devoted to making global declarations, generally contain nothing but a single procedure, and that the names of the files are normalized from those procedure names by eliminating underscores, reducing to 8 characters, and so on.  That's how the source file for a procedure like `SET_SYT_ENTRIES` ends up with a filename like "SETSYTEN".

I doubt that my interpretations here are all 100% correct.  For example, I wouldn't be surprised if the `/**MERGE...*/` comments were originally inserted into the printout for documentation purposes by the original XPL/I compiler rather than actively doing anything themselves.  But if they produce the desired effect for *us*, I don't see any reason not to stick with them.  If the original XPL/I compiler writers wish to complain about that, they're free to send me the original stuff rather than leaving me to speculate about it.

# Pseudo-Statements

'XCOM-I.py' internally treats the XPL/I source code as a sequence of what I call *pseudo-statements*, which often but not always correspond to actual XPL/I simple statements like `A=5;` or `DECLARE A FIXED, B BIT(16);`, but not to more-complex statements like `IF A=5 THEN DO; B=1; C=2; END;`.  The distinction is that pseudo-statements correspond (hopefully!) to strings of code that I find convenient to process, while actual XPL/I statements may be less so.  The distinction is thus somewhat subjective.

While the actual `XCOM-I.py` source code may differ slightly from my description here, basically a pseudo-statement is determined as follows, ignoring all XPL inline comments:

  * It ends in an unquoted semicolon; or
  * It ends in an unquoted colon; or
  * It ends in the unquoted word "THEN" or "ELSE" (as delimited by non-word characters or the boundary of the string).

# Top-Level Program

The top-level file of `XCOM-I.py` is relatively simple.  

> Note: XPL/I source code is assumed to be in 7-bit ASCII.

It first performs simple normalizing of the input XPL/I source code to:

  * Remove punch-card sequence numbers.
  * Assure that each line of code is 80 characters in width (*sans* the sequence numbers).
  * Parse those lines sufficiently to reformat into a form in which there is precisely one pseudo-statement (see the preceding section) per line.  I.e., no pseudo-statement is split across lines and no line contains more than one pseudo-statement.
  * Remove all XPL/I comments ("/*...*/", "/%...%/").
  * Remove or retain XPL/I code within blocks "/?P ... ?/" or "/?B ... ?/" as appropriate.

For the most part, the normalized form of the code remains functionally-identical valid XPL/I, except for certain notable (but mostly reversible) changes:

  * Within single-quoted strings:
    * Space characters (" ") are replaced by the tilde ("&tilde;") character, which is otherwise unused.
    * Pairs of successive single-quote characters ("''") are replaced by the backtick ("`") character, which is otherwise unused.
  * Outside of single-quoted strings:
    * The XPL/I string-concatenation operator ("||") is replaced by the Python string-concatenation operator ("+").
    * Hexadecimal XPL literals (which are double-quoted strings of hexadecimal characters) are replaced by Python 0x... literals.
    * Binary XPL literals (which double-quoted strings beginning with "(1)" followed by binary digits) are replaced by Python 0b... literals.
    * Octal XPL literals (`LITERALLY "(8) ..."`) are replaced by Python 0o... literal constants.  However, there are no instances of such octals in any XPL/I or XPL code I've seen.  It's supported merely because it's essentially free.
    * Base-4 XPL literals(`LITERALLY "(2) ..."`) are replaced by 0q....  The latter construct is not something available in Python 3, so when Python code generation occurs, `int(...,4)` is used instead of a literal constant.  Base-4 literals do not appear in PFS or BFS XPL/I source code, but do appear in the XPL source code of the standard XPL compiler (`XCOM`), and this is supported because it has occurred to me that it might be useful to be able to port XCOM merely as a test of `XCOM-I.py`.

Once normalized, the normalized code is parsed pseudo-statement by pseudo-statement, by Python modules imported by the top-level program.  For example, if the pseudo-statement is an XPL/I `DECLARE`, then XCOM-I feeds it to the `DECLARE()` function of the DECLARE.py module.  But such simplified computing schemes are seldom perfect, so some departures from this idealized description need to be expected.  For example, an XPL/I `BASED` statement is a kind of declaration, yet the code-normalization process described above will split a `BASED ... RECORD ...` statement into two successive pseudo-statements, neither of which is a `DECLARE` pseudo-statement as such.  Thus, you'll find workarounds in XCOM-I to deal with such departures from the ideal.

A Python dictionary called `globalScope` is maintained to hold the parsed program, and the analysis of each successive pseudo-statement updates the `globalModel` or the dictionaries for its sub-scopes.  For example, these dictionaries have fields related to the variables defined by the XPL/I code, and calling `DECLARE()` will add one or more variables.  All of the datatypes, initializations, and ordering of the variables are maintained in these dictionaries for later use.

# Macros and Compiler Passes

`XCOM-I.py` is a single-pass compiler.

The principal difficulty in achieving single-pass operation is the existence in XPL of the with the macro facility, in which declarations of the form
<pre>
    DECLARE symbol LITERALLY 'string';
</pre>
cause the compiler to replace all subsequent occurrences of the `symbol` by the specified `string`.  But these replacement strings are completely arbitrary, syntactically, as well as being potentially recursive and possessing other potentially inconvenient properties.  You can't really normalize the XPL/I source code without first parsing the source code, and you can't parse the source code until the macros have been expanded, but you can't know what the macros are defined until you've parsed the source code.  It's Catch 22.  `XCOM-I.py` uses a separate, simplified parser for DECLARE statements to get around this circularity, as well as imposing the following

> **Requirement:** Macro-replacement strings contain *at most* the contents of a single pseudo-statement.

As far as I've seen *so far*, all actually-existing XPL or XPL/I code does conform to this requirement.  But there's no reason to suppose that it is universally satisfied in existing code, and thus some adjustments may be needed in the future to account for problematic macros.  For example, a macro like the following would logically expand a pseudo-statement into two pseudo-statements without actually doing so in the normalized code:
<pre>
    DECLARE TEST_A LITERALLY 'IF A = FALSE THEN RETURN"
    .
    .
    .
    TEST_A;
</pre>
# An Example of Normalization Of XPL/I Statements Into Pseudo-Statements

As an example, consider the following XPL/I code taken from the source code of the actual HAL/S-FC compiler:
<pre>
     /* COMM EQUAIVALENCES */                                                       00154400
       DECLARE LIT_CHAR_AD   LITERALLY 'COMM(0)',
          LIT_CHAR_USED LITERALLY 'COMM(1)',                                        00154600
          LIT_TOP       LITERALLY 'COMM(2)',                                        00154700
          STMT_NUM      LITERALLY 'COMM(3)',                                        00154800
          FL_NO         LITERALLY 'COMM(4)',                                        00154900
          MAX_SCOPE#    LITERALLY 'COMM(5)',                                        00155000
          TOGGLE        LITERALLY 'COMM(6)',                                        00155100
          OPTIONS_CODE  LITERALLY 'COMM(7)',                                        00155200
          XREF_INDEX    LITERALLY 'COMM(8)',                                        00155300
          FIRST_FREE    LITERALLY 'COMM(9)',                                        00155400
          NDECSY        LITERALLY 'COMM(10)',                                       00155410
          FIRST_STMT    LITERALLY 'COMM(11)',                                       00155420
          TIME_OF_COMPILATION LITERALLY 'COMM(12)',                                 00155430
          DATE_OF_COMPILATION LITERALLY 'COMM(13)';                                 00155440
    .
    .
    .
       DECLARE TRUE LITERALLY '1', FALSE LITERALLY '0', FOREVER LITERALLY 'WHILE 1';00169100
    .
    .
    .
       IF (COMPILING&"80")^=0 THEN             /*  HALMAT COMPLETE FLAG  */         01564400
          IF MAX_SEVERITY<2 THEN                                                    01564500
          IF CONTROL(1)=FALSE THEN DO;                                              01564600
     TOGGLE=(CONTROL(2)&"80")|(CONTROL(5)&"40")|(CONTROL(9)&"10")|(CONTROL(6)&"20");01564700
          IF MAX_SEVERITY>0 THEN TOGGLE=TOGGLE|"08";                                01564800
          CALL RECORD_LINK;                                                         01565000
       END;                                                                         01565100
</pre>
The single compound `IF` statement at the end would have its macros (`FALSE` and `TOGGLE`) expanded and would be split by XCOM-I's normalizing process into 9 pseudo-statements like the following:
<pre>
    IF (COMPILING&0x80)~=0 THEN
    IF MAX_SEVERITY<2 THEN
    IF CONTROL(1)=0 THEN
    DO;
    COMM(6)=(CONTROL(2)&0x80)|(CONTROL(5)&0x40)|(CONTROL(9)&0x10)|(CONTROL(6)&0x20);
    IF MAX_SEVERITY>0 THEN
    COMM(6)=COMM(6)|0x08;
    CALL RECORD_LINK;
    END;
</pre>
# pfs-HAL-S-FC.py and bfs-HAL-S-FC.py

In the introduction above, I referred to the ported form of HAL/S-FC as p-HAL-S-FC.py.  Actually, it's slightly more complex than that.  The original HAL/S-FC actually used slightly different algorithms for compiling the HAL/S source code of PFS (PASS) versus BFS.  There were options selectable in the Job Control Language (JCL) that determined whether PFS source code was being compiled or whether BFS source code was being compiled.  From my perspective, this is similar to saying that p-HAL-S-FC.py should have command-line switches (say, --pfs versus --bfs) to select the target.

However, in working with `XCOM-I.py`, I find it more convenient to make this PFS vs BFS selection in `XCOM-I.py` rather than in p-HAL-S-FC.py.  Thus, there is no single ported compiler called "p-HAL-S-FC.py", but rather two separate ported compilers as determined by command-line switches (--pfs and --bfs) in XPLtoPython.py, namely:  pfs-HAL-S-FC.py and bfs-HAL-S-FC.py.

For conciseness, I'll continue to pretend below that there's a single ported compiler called p-HAL-S-FC.py, but keep in mind that wherever I mention p-HAL-S-FC.py, I'm really referring equally to pfs-HAL-S-FC.py and bfs-HAL-S-FC.py.

> **Aside**:  XPL/I code handles the distinction between PFS vs BFS by having two kinds of conditional blocks, one of them delimited by "/?P" and "?/", and the other delimited by "/?B" and "?/".  XPL/I code within this blocks is conditionally either included or discarded depending on whether PFS is desired or BFS is desired.  While such conditionals *could* be handled by Python `if` statements in the ported code, it would be a lot of error-prone effort on my part, since these blocks can begin or end in the interiors of statements and/or can include multiple statements.  This greatly complicates parsing the XPL/I code, so I've chosen the least complicated method of dealing with the problem.

# Memory Space of Compiled Programs

The variables found in the XPL/I source-code programs are *not* usually represented in the compiled program as variables of the target language (such as C).  That's because variables in the target language are generally either in the native format of the CPU (as in C) or in some idealized format (as in Python), whereas XPL/I programs &mdash; in particular, the XPL/I source code for HAL/S-FC &mdash; depend strongly on variables being stored in memory both in the order *and* the format expected by IBM System/360.  Many types of operations in the XPL/I programs will succeed if C or Python data formats are used, but some quite important operations will fail; these failures are quite difficult to work around.

There are two main reasons this is important:  Firstly, XPL/I does not respect array boundaries nor the destinction between arrayed and non-arrayed data; thus, data adjacent in memory to a given variable can be accessed by using array indices that are out of bounds, or using array subscripts with non-arrayed variables.  If the data is in the wrong order or wrongly formatted, it usually won't be accessible in this way.  Secondly, the XPL/I source code for the HAL/S-FC implements a "virtual memory" model in which memory is accessed directly and/or swapped blockwise to operating-system files.  Again, if the data is not in the expected format and arrangement in memory, this virtual-memory system fails completely.

Therefore, the memory space of the compiled programs is instead treated as contiguous array of byte (8-bit), halfword (16-bit), word (32-bit) values without holes.  All individual values stored in the formats expected by IBM System/360.  Regarding those formats, the ones which concern us in XPL/I are:

  * `CHARACTER`: 32-bit "descriptor".  McKeeman and Intermetrics documentation contradict each other on the format of this descriptor.  The Intermetrics description doesn't support the empty string (i.e., '' of zero length); meanwhile, McKeeman's description is internally contradictory, in that it says the maximum length of strings is 256 but its described format doesn't support that length.  I follow the McKeeman description for `CHARACTER` but assume the maximum string length is 255:
    * The most-significant byte of the descriptor represents the character-count of the string, from 0 to 255.
    * The least-significant 3 bytes, in big-endian order, represent a 24-bit pointer to the string-data itself.  It's unclear to me how XPL was supposed to handle the fact that in an assignment of a `CHARACTER` variable, the string being assigned to it could be longer than the string previously in the variable.  `XCOM-I.py` handles this simply by allocating 256 bytes for each `CHARACTER` value stored in memory.  (Note that in the XPL source code of the `HAL/S-FC` program, I find on the order of &tilde;2000 `CHARACTER` variables.  Consequently, even with the maximum amount of memory allocated for every string, however short, it still means that less than 3% of memory is used for `CHARACTER` storage.)
    * The individual characters of the string are encoded in EBCDIC.
  * `FIXED`: 32-bit 2's-complement integers, with bytes stored in big-endian order.
  * `BIT(n)`:
    * `BIT(1)` through `BIT(32)`:  Unsigned 32-bit value.
    * `BIT(33)` through `BIT(2048)`:  32-bit "descriptor", supposedly the same as `CHARACTER`.  Note that this contradicts statements in McKeeman that the maximum number of bits in the string is 2048.  Moreover, unlike `CHARACTER`, a 0-length bit-string makes no sense.  Therefore, my best guess is that in this case the length field of the descriptor is actually the bit-string's length *minus 1*.  
    * In the actual XPL/I source code for `HAL/S-FC`, I find no bit-strings of length greater than 32.  I have no motivation to implement them.
  * `BASED`: In McKeeman, this was a 24-bit (embedded within 32 bits) of *pointer* to what might be thought of as an array of structures.  The pointer could be &mdash; had to be &mdash; changed at runtime to initialize or change the association of a particular section of memory (such as a buffer) to the `BASED` variable.  All accesses to the variable were thus indirect, via the pointer.  The approach in XCOM-I is similar, in that this is still a 32-bit value, but is implemented in a somewhat more-complex manner as described in the extended discussion that follows.

> **Note:** For the original Intermetrics XPL/I compiler, a variable declared as an `ARRAY` (versus `DECLARE`) also used the same indirect references as `BASED`, with the difference that the pointer associated with a `BASED` could be  &mdash; *had* to be &mdash; assigned at runtime, whereas the pointer associated with an `ARRAY` was fixed at compile-time.  The reason for this, I infer from IR-182-1, was technical:  The amount of memory set aside for declarations via `DECLARE` was limited compared to the amount of space needed for the large arrays, therefore these were allocated in a different section of memory and mere pointers were stored in the tables used for `DECLARE`.  Since XCOM-I is not structured internally the same way Intermetrics's XCOM, there's no point in this distinction, so `ARRAY`s are simply treated like `DECLARE`s.  If necessary, I can revisit this later.



Similarly, mathematical operations such as addition, subtraction, multiplication, and so on, do not use built-in operators of the C or Python target language, but instead rely on custom functions that accept IBM System/360 operands and output IBM System/360 values.

# SPACELIB Hell

HAL/S-FC source code uses a couple of entities defined in the file HALINCL/SPACELIB.xpl.

The SPACELIB library is quite problematic.  For one thing, in distinction to all other XPL source-code files, I don't see how any of its contents become available to the remainder of HAL/S-FC, as it's not included or merged by any of the other files.  Moreover, SPACELIB itself uses entities which don't seem to be defined in any way.  Then too, whatever SPACELIB is doing is so obtuse in terms of functionality and syntactical features that are used nowhere else, I despair of making it actually work in any meaningful way.

With that said, I believe that SPACELIB's purpose is managing dynamic memory elements such a CHARACTER data and BASED RECORD DYNAMIC, which insofar as they were conceived in Intermetrics XCOM required runtime allocation of new memory, and reallocation and/or garbage collection of old memory.  If true, that functionality is either obsolete or else has a SPACELIB implementation that irrelevant to XCOM-I.  

*Therefore*, SPACELIB should not be included among the files compiled along with HAL/S-FC, and those few items from it that are used directly have been added to the list of XPL/I built-in functions, where they are implemented very differently that as in SPACELIB.  Instead, the built-in `COMPACTIFY` provided by XCOM-I's runtime library should be used instead.

# The Problem of Inline Basic Assembly Language (BAL) Code

Basic Assembly Language is the assembly language of the IBM System/360 mainframe computer.  The XPL/I source code for the HAL/S-FC program is strewn with inline BAL code which has been inserted into the stream of XPL/I statements.  Sometimes this insertion is to perform computational tasks not achievable directly by the XPL/I language, sometimes to speed up operations which could otherwise be performed more slowly in XPL/I, and sometimes for reasons I have not yet discerned.  This inclusion of BAL obviously is a severe problem unlikely to be accomplished *unaided* by `XCOM-I.py`, execution of those BAL instructions is unlikely to be possible.

The method of inclusion is calls to a built-in procedure called `INLINE`.  Each call to `INLINE` inserts a single BAL instruction, in its assembled (i.e., numerical) machine-language form rather than in symbolic (assembly-language) form, though fortunately most or all `CALL INLINE`'s are also accompanied by the assembly-language instruction in the form of a program comment.

> **Aside**: In XCOM-I, `CALL INLINE(string)` has a second use, not available in the original compilers, but consistent with (and inspired by) Daniel Weaver's XPL-to-C translator.  In this case, the `string` is treated as if it were valid C code and is inserted into the C output as-is.  Its primary use, as I envisage it, is to be able to persistently embed calls to C-language diagnostic functions while debugging XCOM-I itself.  An example would be `CALL INLINE('printMemoryMap("Memory Map:");')`.  (FYI:  `printMemoryMap` is a diagnostic function from XCOM-I's runtime library that accesses an array called `memoryMap`, which in turn lists all variables declared in the XPL/I program by name, address, datatype, and array size; this information isn't needed by the compiled XPL program or by the runtime library, but could obviously be useful for debugging purposes, if the alternative would be just viewing raw memory.)  I suppose that other (perhaps ill-advised) uses for this functionality could be found if one were sufficiently ambitious.

Working around this BAL problem has two aspects.  First, how to determine what the BAL code is *trying* to accomplish, and ascertaining how to accomplish that thing in some other manner?  Second, how to implement such an alternate method without having to alter the XPL/I source-code files?

I have no insight to offer with respect to the first aspect, except to note that it was possible in my older, manual port of PASS1 of `HAL/S-FC` to Python.  So undoubtedly it remains possible now, albeit with significant effort.

As far as the second aspect, however, I have an approach which should work.  Consider, for example, the following block of `INLINE`s from the HAL/S-FC source-code file HALMATIN.xpl:
<pre>
         CALL INLINE("58", 3, 0, DW_AD);           /* L    3,DW_AD            */
/*LOAD DOUBLE FROM STACK SPACE 3 TO REGISTER 0*/
         CALL INLINE("68", 0, 0, 3, 0);            /* LD   0,0(0,3)           */
/*LOAD POSITIVE VALUE OF REGISTER 0 INTO REGISTER 0*/
         CALL INLINE("20", 0, 0);                  /* LPDR 0,0                */
/*LOAD ROUNDING VALUE INTO STACK 1 THEN ADD TO REGISTER 0*/
         CALL INLINE("58", 1, 0, ADDR_ROUNDER);    /* L    1,ADDR_ROUNDER     */
         CALL INLINE("6A", 0, 0, 1, 0);            /* AD   0,0(0,1)           */
         CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);/* L    1,ADDR_FIXED_LIMIT */
         CALL INLINE("58", 2, 0, PTR);             /* L    2,PTR              */
/*COMPARE REGISTER 0 TO THE POSITIVE INTEGER LIMIT*/
         CALL INLINE("69", 0, 0, 1, 0);            /* CD   0,0(0,1)           */
/*BRANCH TO 'LIMIT_OK' IF REGISTER 0 IS LESS THAN OR EQUAL TO THE LIMIT       */
         CALL INLINE("07",12, 2);                  /* BNHR 2                  */
</pre>
Having determined what this code is supposed to accomplish:

  * One would create a C source-code file that accomplishes the same thing.
  * In some manner TBD, `XCOM-I.py` would be able to associate this C source-code file with the specific location in the XPL source code at which this block of `INLINE` instructions occurs.
  * During compilation, whenever a pre-written C-language source-code patch was available, `XCOM-I.py` would simply delete the corresponding block of `INLINE`s, and would instead insert the contents of the C source-code file directly at the corresponding location in the C translation of the XPL/I.

The XPL/I source code thus remains unchanged, but the C translation of it nevertheless ends up with C-language workarounds for the BAL `INLINE`s.  There is a cost, of course, in writing the C-language replacement patches for the BAL `INLINES`.

# Appendix: Implementation of Spaghetti Code

The XPL/I source code, in many places, is a bewildering mass of spaghetti code, in which sometimes large numbers of "GO TO" statements and target labels are strewn throughout the source code.  In this Appendix, I discuss workarounds for that in the output language(s), or hypothetical output language(s), of `XCOM-I.py`.

## For C Output-Target Language

C already has support, in the form of its `goto` statement, for jumps within the same function.  This is the vast majority of XPL `GOTO` statements found in available XPL source code.

Regarding XPL `GOTO` statements targeting labels not in the current `PROCEDURE` but rather in calling code, there is a mechanism in C that can support that activity, namely the `setjmp` and `longjmp` functions of setjmp.h.  The way this works is that at the jump-target locations where XPL would have had a target label, there will instead be a call to the `setjmp` function; and at the locations where XPL would have had a `GOTO label` statement, there would instead be a call in C to the `longjmp` function.  But there's a problem, in that the `setjmp` must have been executed prior to the `longjmp` being executed, and in the normal control flow of the XPL program there's no reason to believe that would have happened.  The common usage for this feature would be to jump from anywhere in the program to an error handler, and of course the error handler would *not* have been previously executed, so its `setjmp` would not have set up the call to `longjmp`.

But there's a workaround, on a `PROCEDURE` by `PROCEDURE` basis.  First, suppose that all of the XPL labels for the target locations are left in place in the C function that translates the XPL `PROCEDURE`, even though not needed as such by `setjmp`/`longjmp`.  For concreteness, imagine we have this XPL:
<pre>
    A: PROCEDURE;
        ...
        LAB1:
        ...
        LAB2:
        ...
        LAB3:
        ...
    END A;
</pre>
Recall that under the identifier-mangling system discussed earlier, this `PROCEDURE` would translate to the C function `xA`, which might look something like this:
<pre>
    #include &lt;setjmp.h&gt;
    ...
    jmp_buf xAtLAB1, xAtLAB2, xAtLAB3;
    void xA()
    {
        static int initial = 1;
        if (initial)
        {
            goto LAB1; 
            returnToInitial: initial = 0;
        }
        ...
        if (0) {
            LAB1: 
            if (initial) setjmp(xAtLAB1);
            if (initial) goto LAB2;
        }
        ...
        if (0) {
            LAB2: 
            if (initial) setjmp(xAtLAB2);
            if (initial) goto LAB3;
        }

        ...
        if (0) {
            LAB3: 
            if (initial) setjmp(xAtLAB3);
            if (initial) goto returnToInitial;
        }
        ...
    }
</pre>
Thus, the first time the function is executed, it successively chain-jumps to each of the target labels, executes a `setjmp`, and then finally resumes executing from the beginning of the function.  As each of the target labels is reached while executing the function, it bypasses the code inserted there, just as it would ignore a target label.  And an XPL statement like `GOTO LAB1`, if not local to `PROCEDURE A`, would then be just `longjmp(xAtLAB1, 1)`.  If local to `PROCEDURE A`, of course, it could instead be the simpler `goto A` (though the `longjmp` would work as well).


## For Hypothetical Python Output-Target Language

These jumps are often into the interior of deeply nested DO...END blocks that would be inaccessible in well-structured code supported by languages like Python.  The need to support such spaghetti code is one of the principal difficulties in trying to port XPL/I programs into Python, or indeed most modern languages, and any implementation in Python is bound to be somewhat inefficient.

First, any target label of an XPL/I `GOTO` statement must be within the same PROCEDURE as the GO TO statement itself. 

> **Note:** There are GO TO statements in HAL/S-FC source code which do not obey this same-PROCEDURE restriction, but they are exceedingly rare in my experience.  (I have seen them only in jumping from deeply-nested code to one of several top-level error exits.)  Because those cases are rare, I'm leaving them to be handled by the programmer rather than building them into the compiler.  I may rethink this later.

Second, *every* XPL/I DO...END block or procedure body is translated into Python using prototypical Python runtime code of the form:
<pre>
    while CONDITION:
        ... Python translation of the DO...END block
</pre>
The CONDITION relates to the target labels appearing within the block and to the GO TO (if any) currently requested at the time the CONDITION is evaluated.  For DO blocks or procedure bodies that don't actually have any explicit condition for entry, there actually is a hidden condition, namely that the block has to be executed at least once.  In that case, the `while CONDITION` needs to change slightly to something like
<pre>
    ONCE = True
    while ONCE or CONDITION:
        ONCE = FALSE
        ... Python translation of the DO...END block
</pre>
Third, *each* DO...END block, however deeply nested, has an associated Python set object which lists the target labels present within the block.  Such a set may be empty if there are no such target labels.

Fourth, since at most one GO TO request may be active at any given time, there is a global variable which either contains the target label or else some indication that there is no request.  The CONDITION mentioned above is thus a Python set operation that tests whether the requested target is in the set of target labels for the block or is not.  The CONDITION is True if:

  * There is *no* requested target, but the block's native conditions for entry are satisfied; or
  * The requested target label is within the set of targets for the block, irrespective of whether or not the block's native conditions for entry are satisfied.

Otherwise, the CONDITION is False.

Fifth, at the location of the target label itself, the global variable requesting the jump is cleared to indicate that no jump is requested.

Sixth, GO TO statements are implemented so as to:

  * Set the global request variable with the proper target name.
  * If the requested target is within the same DO...END block (at the same level) as the GO TO, then code equivalent to Python `continue` returns control back to the `while CONDITION` beginning the block.  Otherwise code equivalent to Python `break` exits from the `while CONDITION` block.

Seventh, code immediately following each of the `while CONDITION` blocks described above examines the global request and either falls through, issues a `continue`, or issues a `break`, depending on whether the requested GO TO global is empty or else requests a target label above or below.

Eighth, and finally, the translation every *other* line of XPL/I code is formulated basically as:

    if there is no requested jump:
        ... Python translation of the XPL/I statement ...

Of course, typically there will be multiple successive lines of XPL/I code in this category, so they be "optimized" to each fall under the same "`if there is no requested jump`" rather than to each have their own conditional.

That's all pretty complicated, so let's see some examples.  It's helpful to keep in mind that as I'm writing this I have *not* yet implemented it and am simply working through it in my head, so the final implementation may not look quite like these examples.
<pre>
    /* XPL/I code for example #1 */
    EXAMPLE1: PROCEDURE;
        DECLARE X FIXED;
        X = 1;
        GO TO ALABEL;
        BLABEL: 
        X = X + 1;
        ALABEL: 
        X = X + 1;
        IF X < 10 THEN
            GO TO BLABEL;
        RETURN X;
    END EXAMPLE1;
</pre>
What this does is to set `X=1`, then jump to `ALABEL` where it sets `X=2`, and then to keep looping back to `BLABEL`, incrementing `X` by 2 on each loop, so it finally returns `X=11`.  
<pre>
    # Python translation of example #1
    def EXAMPLE1():
        REQUESTED = None
        LABELS_IN_EXAMPLE1 = set('ALABEL', 'BLABEL')
        ONCE = True
        while ONCE or REQUESTED in LABELS_IN_EXAMPLE1:
            ONCE = False
            if REQUESTED == None:
                X = 1
            if REQUESTED == None:
                REQUESTED = 'ALABEL' # Since ALABEL is below, can just fall through.
            if REQUESTED == 'BLABEL':
                REQUESTED = None
            if REQUESTED == None:
                X = X + 1
            if REQUESTED == 'ALABEL':
                REQUESTED = None
            if REQUESTED == None:
                X = X + 1
            if REQUESTED == None:
                if X < 10:
                    if REQUESTED == None:
                        REQUESTED = 'BLABEL' # Since BLABEL is above, must loop back to intial WHILE
                        continue
            if REQUESTED == None:
                return X
</pre>
This can be optimized &mdash; during code generation, fortunately, without needing another compiler pass &mdash; as:
<pre>
    # Optimized Python translation of example #1
    def EXAMPLE1():
        REQUESTED = None
        LABELS_IN_EXAMPLE1 = set('ALABEL', 'BLABEL')
        ONCE = True
        while ONCE or REQUESTED in LABELS_IN_EXAMPLE1:
            ONCE = False
            if REQUESTED == None:
                X = 1
                REQUESTED = 'ALABEL' # Since ALABEL is below, can just fall through.
            if REQUESTED == 'BLABEL':
                REQUESTED = None
            if REQUESTED == None:
                X = X + 1
            if REQUESTED == 'ALABEL':
                REQUESTED = None
            if REQUESTED == None:
                X = X + 1
                if X < 10:
                    REQUESTED = 'BLABEL' # Since BLABEL is above, must loop back to intial WHILE
                    continue
                return X
</pre>


