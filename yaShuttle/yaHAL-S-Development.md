**Note:**  This file contains various notes (mostly to myself) in a blog-like form about developing a "modern" HAL/S compiler that I call yaHAL-S.  It's likely not of interest to anybody else &mdash; RSB

# 2022-11-07

Though I don't presently have any actual HAL/S code from PASS or BFS to work with, I've extracted various samples of short but complete (and presumably working) HAL/S programs from the book [Programming in HAL/S](https://www.ibiblio.org/apollo/Shuttle/Programming%20in%20HAL_S%20Sept%201978.pdf).  They've been stored [in the source tree](https://github.com/virtualagc/virtualagc/tree/master/yaShuttle/Code%20samples/Programming%20in%20HAL-S).

# 2022-11-08

A Backus-Naur Form (BNF) description of the HAL/S language appears in the contemporary documentation, in [AppendiX G of the HAL/S Language Specification](https://www.ibiblio.org/apollo/Shuttle/HAL_S%20Language%20Specification%20Nov%202005.pdf#page=209).  The link is to the latest version of the specification that's available, although as far as I can tell, the same description appears in the very earliest available version, as well as in the original source code, modulo typos.  I have converted that into a machine-readable form, namely the file

    HAL-S.bnf

with corrected typos and some reformatting.  Besides that, there were a couple of illegal constructions, 

    <OR> ::= | | OR
    <CAT> ::= || | OR

which I've changed to 

    <OR> ::= <CHAR VERTICAL BAR> | OR
    <CAT> ::= <CHAR VERTICAL BAR> <CHAR VERTICAL BAR> | CAT

The type `<CHAR VERTICAL BAR>` naturally does not exist in the original BNF, nor in HAL-S.bnf, since there's no standard way in BNF I can discern to create a rule for it.  Besides which, the documented BNF description is actually incomplete, in the sense that it is missing rules for various other types it refers to, most or all of which are elementary types, such as `<SIMPLE NUMBER>`, `<IDENTIFIER>`, and so on.  Rules for all of these need to be created, into order to get a complete description of the language.  The contemporary BNF is also buggy, in the sense that while it served as documentation both prior to and after the original coding, it was not itself subject to automated processing.  *For example*, the very first rule was `<COMPILATION> ::= <COMPILE_LIST> _|_`, where the trailing `_|_` is just garbage; my guess is that it was shorthand for the original developers that `<COMPILATION>` was the top-level BNF rule.  For us, though, it's unprocessable nonsense and has to be removed.

# 2022-11-09

Having a complete formal description of HAL/S in hand, I use the [BNF Converter (BNFC)](https://bnfc.digitalgrammars.com/) compiler-compiler to produce a HAL/S compiler frontend. BNFC does not actually take a BNF description as input, but requires an alternate form known as [Labeled BNF (LBNF) grammar](https://bnfc.readthedocs.io/en/latest/lbnf.html).  I have therefore created a script,
 
    bnf2lbnf.py

that can convert my BNF to LBNF.  Although since the script is rather simple-minded in terms of its pattern matching, the original BNF description has been massaged somewhat in HAL-S.bnf in terms of its whitespace.

# 2022-11-13

I find it more-convenient to provide the rules for the missing types mentioned earlier in LBNF form rather than BNF, because LBNF has ready means of creating various of those rules (particularly `<CHAR VERTICAL BAR>`, but others as well) by means of regular expressions.  All of those additional definitions reside in a file called
 
    extraHAL-S.lbnf

(**Important later note:**  *Do not generate HAL_S.cf as indicated in this paragraph.  This method is now deprecated.  Do not overwrite HAL_S.cf.  Instead, the existing HAL_S.cf should be preserved and edited directly if necessary.*)  In Linux or Mac OS X, the complete description of HAL/S in LBNF can be created by the following command:
 
    cat extraHAL-S.lbnf HAL-S.bnf | bnf2lbnf.py > HAL_S.cf

In Windows, I've read (though I don't vouch for it!) that you'd replace `cat` by `type`.  By the way, the filename HAL-S.cf would eventually cause our build to fail, which is the reason for the sudden switch to HAL_S.cf.
 
Assuming you've installed BNFC for your particular operating system (Linux, Windows, and Mac OS X are available, and maybe others for all I know), you're ready to build the compiler front-end.  I'd suggest you do this in a separate folder, because the process creates a lot of files.  In Linux, the process looks like this, assuming you're starting from the directory which contains HAL_S.cf:
 
    md temp
    cd temp
    bnfc --c -m ../HAL_S.cf
    make

(If you've previously performed these same steps in the same directory, you'd also be advised to do a `make distclean` prior to the `bnfc ...`, or else you're likely to find that whatever changes have been made to HAL_S.cf in the meantime won't actually appear in the front-end you create.)
 
As you may or may not be able to discern, what the `bnfc` command actually does is to create C-language source code for the HAL/S compiler front-end, and then compiles that C code.  In fact, BNFC can actually create the source code for the compiler front-end in a variety of languages, such as C++ or Java, and I've just chosen C as my personal preference.

The compiler front-end produced in this manner is called `TestHAL_S`, and it is used as follows:

    TestHAL_S SOURCE.hal

or

    TestHAL_S <SOURCE.hal

However ... there are certain features of HAL/S which are not captured by the BNF (or LBNF) description of it, and which we cannot work around if we confine ourselves to BNF/LBNF.  Specifically, I refer to the fact that while HAL/S is essentially free-form in columns 2 and rightward &mdash; i.e., it does not respect column alignment or line breaks &mdash; it nevertheless treats column 1 specially.  Column 1 is normally blank, but can also contain the special characters

* C &mdash; full-line comment.
* D &mdash; compilation directive line.
* E &mdash; exponent line.
* M &mdash; main line (in conjunction with E and S lines).
* S &mdash; subscript line.

Neither BNF nor LBNF has any provision for a column-dependent feature of this kind.  Therefore, prior to compiling HAL/S source code, it is necessary to preprocess it,

    yaHAL-preprocessor.py TRUE_HAL_SOURCE.hal > TAME_HAL_SOURCE.hal

to "tame" those column-dependent features.  It is the tamed HAL/S source which needs to be compiled.  Specifically, the multiline Exponent/Main/Subscript (E/M/S) constructs are converted to also-legal single-line form.  Moreover, full-line comments are converted to "//"-style comments.  I.e., in the tamed code, "//" anywhere in a line of code (not merely in column 1) indicates that the remainder of the line is a comment.

Thus application of the complete preprocessor plus compiler front-end might look like:

    yaHAL-preprocessor.py SOURCE.hal | TestHAL_S

Some additional major steps will be needed *after* creating the compiler front-end, in order to have a complete compiler:

1. A compiler backend has to be created which can convert the compiler frontend's output to the target form, which in this case is p-HAL/S p-code.
2. A formatter for an output listing needs to be created.
3. Modifications must be made to produce sensible compilation error messages.

# 2022-11-15

The compiler front-end is partially working, but breaks in unexpected ways.  In order to get more insight into what it's doing when it *does* work, I've a added a program which can reformat the "abstract syntax" output by the compiler into an easier-to understand hierarchical form:

    syntaxHierarchy.py

# 2022-11-16

Well, it has been a bit of work in uncovering errors in both my own misconceived LBNF for missing rules and in fixing problems in the original BNF.  For example, using the hierarchical-reformatting tool from yesterday, I found that `<ARITH VAR>` was sometimes being misidentified as `<STRUCTURE VAR>`, due to `<EMPTY>` never being accepted in the rule `<PREFIX> ::= <EMPTY> | <QUAL STRUCT> .`.  I mention this merely to illustrate a) how hard these problems are to track down, and b) the traps inherent in the non-syntactically-debugged original BNF.

But as of this morning the compiler front-end seems to at least be able to "compile" *one* of my sample HAL/S programs, specifically FACTORIAL.hal, which looks like the following:

    /* Sample from PDF p. 85 of "Programming in HAL/S". */
    
    FACTORIAL:
    PROGRAM;
       DECLARE INTEGER,
                  RESULT, N_MAX, I;
       READ(5) N_MAX;
       RESULT = 1;
       DO FOR I = 2 TO N_MAX BY 1;
          RESULT = I RESULT;
       END;
       WRITE(6) 'FACTORIAL=', RESULT;
       WRITE(6) 'I=', I; /* I ADDED THIS! */
    CLOSE FACTORIAL;

The output of the compilation is a superficially-incomprehensible lisp-like mess, though understandable if you dig into it:

    Parse Successful!
    
    [Abstract Syntax]
    (AAcompilation (AAcompile_list (AAblock_definition (AAblock_stmt (ACblock_stmt_top (AAblock_stmt_head (AAlabel_external (AAlabel_definition (FJlabel (FEidentifier "FACTORIAL"))))))) (ACblock_body (ACblock_body (ACblock_body (ACblock_body (ACblock_body (ABblock_body (AAdeclare_group (AAdeclare_element (AAdeclare_statement (ABdeclare_body (ACattributes (AAtype_and_minor_attr (ADtype_spec (ABarith_spec ABsq_dq_name)))) (ABdeclaration_list (AAdcl_list_comma (ABdeclaration_list (AAdcl_list_comma (AAdeclaration_list (AAdeclaration (AAname_id (FEidentifier "RESULT"))))) (AAdeclaration (AAname_id (FEidentifier "N_MAX"))))) (AAdeclaration (AAname_id (FEidentifier "I"))))))))) (AAany_statement (AAstatement (AQbasic_statement (AAread_phrase (AAread_key (ABnumber FXlevel)) (AAread_arg (AAvariable (AAarith_var (FFarith_id (FEidentifier "N_MAX")) (AEsubscript CGempty))))))))) (AAany_statement (AAstatement (ABbasic_statement (AAassignment (AAvariable (AAarith_var (FFarith_id (FEidentifier "RESULT")) (AEsubscript CGempty))) AAequals (AAexpression (AAarith_exp (AAterm (AAproduct (AAfactor (ADprimary (ABpre_primary (ABnumber FTlevel))))))))))))) (AAany_statement (AAstatement (AObasic_statement (AGdo_group_head (ABdo_group_head (AAfor_list (AAfor_key (AAarith_var (FFarith_id (FEidentifier "I")) (AEsubscript CGempty)) AAequals) (AAarith_exp (AAterm (AAproduct (AAfactor (ADprimary (ABpre_primary (ABnumber FUlevel))))))) (ABiteration_control (AAarith_exp (AAterm (AAproduct (AAfactor (AAprimary (AAarith_var (FFarith_id (FEidentifier "N_MAX")) (AEsubscript CGempty))))))) (AAarith_exp (AAterm (AAproduct (AAfactor (ADprimary (ABpre_primary (ABnumber FTlevel)))))))))) (AAany_statement (AAstatement (ABbasic_statement (AAassignment (AAvariable (AAarith_var (FFarith_id (FEidentifier "RESULT")) (AEsubscript CGempty))) AAequals (AAexpression (AAarith_exp (AAterm (ADproduct (AAfactor (AAprimary (AAarith_var (FFarith_id (FEidentifier "I")) (AEsubscript CGempty)))) (AAproduct (AAfactor (AAprimary (AAarith_var (FFarith_id (FEidentifier "RESULT")) (AEsubscript CGempty)))))))))))))) AAending)))) (AAany_statement (AAstatement (ASbasic_statement (ABwrite_phrase (AAwrite_phrase (AAwrite_key (ABnumber FYlevel)) (AAwrite_arg (ACexpression (AAchar_exp (ABchar_prim (AAchar_const (FOchar_string "'FACTORIAL='"))))))) (AAwrite_arg (AAexpression (AAarith_exp (AAterm (AAproduct (AAfactor (AAprimary (AAarith_var (FFarith_id (FEidentifier "RESULT")) (AEsubscript CGempty)))))))))))))) (AAany_statement (AAstatement (ASbasic_statement (ABwrite_phrase (AAwrite_phrase (AAwrite_key (ABnumber FYlevel)) (AAwrite_arg (ACexpression (AAchar_exp (ABchar_prim (AAchar_const (FOchar_string "'I='"))))))) (AAwrite_arg (AAexpression (AAarith_exp (AAterm (AAproduct (AAfactor (AAprimary (AAarith_var (FFarith_id (FEidentifier "I")) (AEsubscript CGempty)))))))))))))) (ABclosing (FJlabel (FEidentifier "FACTORIAL"))))))
    
    [Linearized Tree]
    FACTORIAL  : PROGRAM;
    DECLARE INTEGER, RESULT, N_MAX, I;
    READ ( 5)N_MAX;
    RESULT  =  1;
    DO FOR I  =  2 TO N_MAX BY  1;
    RESULT  = I RESULT;
    END;
    WRITE ( 6)'FACTORIAL=', RESULT;
    WRITE ( 6)'I=', I;
    CLOSE FACTORIAL;

I suspect there's still a lot of debugging of the BNF needed, but it's a nice little milestone anyway.

In fact, with the fixes I've made today, most of the HAL/S code samples I've provided so far will compile: CORNERS, DARTBOARD_APPROXIMATION, EXAMPLE_1, EXAMPLE_2, EXAMPLE_4A, FACTORIAL, NEWTON_SQRT, ORTHONORMAL, PARALLAX, ROOTS, ROWS, SIMPLE, XYZ_TO_POLAR.

But there are 2 problematic ones left over: TABLE and TAN_SUMS.  These won't compile because they have `REPLACE ... BY "..."` macros.  And while the compiler can parse the macro definitions &mdash; though admittedly oddly &mdash; it cannot (as of yet) actually perform the preprocessor-style replacements that the macros implement.  Thus none of the lines having macro invocations in them compile.

Amusingly, in the very last place it occurred to me to look in resolving my issues, I found a mistake in the XYZ_TO_POLAR example as it appears in *Programming in HAL/S*.  (The parentheses in the `WRITE(6)` command were not matched.)  What's amusing about that is that the document itself proudly proclaims that all of the code example are *correct*, and we don't need to worry about any errors, since the code was pasted directly from error-free compiler listings rather than manually typed into the document.  So ... I call BS on that one; errors in the sample-program listings are something that will indeed need to watched for.

Regarding completion of the compiler &mdash; some of the steps needed are listed at the end of the 2022-11-13 entry above &mdash; the way the command `bnfc --c -m ../HAL_S.cf` works &mdash; recall that it's one of the steps in building the test version (`TestHAL_S`) of the compiler &mdash; is to create a variety of C files:

* Absyn.c, Absyn.h
* Lexer.c
* Parser.c, Parser.h
* Printer.c, Printer.h
* Skeleton.c, Skeleton.h
* Test.c
* Makefile

Creating the full compiler is a matter of fleshing out Printer.c and Skeleton.c (I think), replacing Test.c (the top-level program), and fixing up the Makefile accordingly.  But I need to read more about this.

# 2022-11-19

I now have 30 code samples from "Programming in HAL/S", and while I haven't checked the output from the proof-of-concept compiler front-end in detail, I'd cautiously say that they all work except for two, and that those fail in similar ways.  Consider the following sample, which I constructed myself:

    TEST:
    PROGRAM;
        DECLARE MYBOOL BOOLEAN INITIAL(TRUE);
        DECLARE MYVECTOR ARRAY(3) BOOLEAN INITIAL(TRUE);
        DECLARE X INTEGER INITIAL(0);
        
        IF MYBOOL THEN
        	X = 1;
        IF TRUE = MYBOOL THEN
        	X = 2;
        IF TRUE = MYVECTOR$(1) THEN
        	X = 3;
        IF MYBOOL = TRUE THEN 
        	X = 4;
        IF MYVECTOR$(1) THEN
        	X = 5;
        IF MYVECTOR$(1) = TRUE THEN
        	X = 6;
    CLOSE TEST;

The former 3 `IF ... THEN ... ;` parse, while the latter 3 fail either at `TRUE` or at `THEN`.  It *appears* to me that that's because the production rules in the BNF grammar require `MYBOOL` and `MYVECTOR$(1)` to be bit variables, but that the parser incorrectly determines them to be arithmetical identifiers in the latter 3 rules.  And why is that?

Well, I've been more-or-less ignoring the warnings emitted by `bison` (the parser generator) when the compiler is built, mainly because I didn't understand them.  I notice now, though, that it complains about 673 "shift/reduce conflicts" and 420 "reduce/shift conflicts", which apparently indicate ambiguities in the grammar.  Besides which I have this:

    HAL_S.y:725.11-50: warning: rule useless in parser due to conflicts [-Wother]
      725 | CHAR_ID : IDENTIFIER { $$ = make_FIchar_id($1);  }
          |           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Which is particularly curious to me, since why `<CHAR ID>`?  Why not the identically-defined `<BIT ID>` or `<STRUCT ID>`?  Dunno!

It seems to me that one way around this is to use the preprocessor to alter the names of identifiers based on the `DECLARE` lines, for example prefixing them with 'a' for arithmeticals, 'b' for bits, etc.  In which case `<ARITH ID>` could be defined by tokens distinct from `<BIT ID>`, `<CHAR ID>`, and so on.  The extra characters on the symbol names could be removed after compilation.  I don't like that idea much, but it could be done.  I think.

I think this is the basic problem, but there must be a better way to fix it.

Thinking about how to debug this problem, it seems to me firstly that the method described earlier of creating HAL_S.cf &mdash; i.e., the LBNF input file to BNF Converter &mdash; namely,

    cat extraHAL-S.lbnf HAL-S.bnf | bnf2lbnf.py > HAL_S.cf

needs to be scrapped.  It was fine up to now, but it is cumbersome for debugging.  From now on, extraHAL-S.lbnf, HAL-S.bnf, and bnf2lbnf.py, though remaining in the repository, are frozen in their current states and are deprecated.  Instead, HAL_S.cf is the "official" language description, and it's the file that needs to be debugged on an ongoing basis.

Taking this approach, I think I've verified that the problem is LBNF rules such as the following:

    FGarith_id . ARITH_ID ::= IDENTIFIER ;
    FHbit_id   . BIT_ID   ::= IDENTIFIER ;

What I've done is to take HAL_S.hal and created a new file, Test.hal, which is the same except for the fact that I've removed all rules except those needed to parse the following function:

    TEST:
    PROGRAM;
       IF MYBOOL = TRUE THEN
     	  X = 2;
    CLOSE TEST;

(Yes, it's not legal without the `DECLARE` lines, but the parser doesn't know that.)  When I build the compiler using this truncated definition of the language, with both `ARITH_ID ::= IDENTIFIER` and `BIT_ID ::= IDENTIFIER`, Bison indicates 

    bison -t -pTest Test.y -o Parser.c
    Test.y: warning: 9 reduce/reduce conflicts [-Wconflicts-rr]

Morever, the `TEST` program compiles with a syntax error at `TRUE` (as before), while if we instead use `TRUE = MYBOOL` then (as before) it compiles fine.

However, if instead we change the rule for `BIT_ID` to instead be like an IDENTIFIER but prefixed by "b_", Bison reports no errors at all in building the compiler.  Moreover, if we change the `TEST` program to have `b_MYBOOL = TRUE`, then it compiles fine as well.  (And with `TRUE = b_MYBOOL` as well.)

From googling the issue, it's unclear to me if there's any way to handle this in the compiler front-end.  If there is, it appears to me that it involves manually creating or editing the HAL_S.y input file for bison, rather than letting BNF Converter entirely handle its creation, and that seems to me like a recipe for disaster ... particularly since everything I'm reading about the how to work with bison directly seems to be little more than a pile of expert-speak gobbledygook.  And I'm not an expert in such stuff.

The preprocessor approach I mentioned earlier seems as though it would definitely handle it.  We could have a naming convention for identifiers, such as

    b_XXXXX         BIT_ID
    c_XXXXX         CHAR_ID
    s_XXXXX         STRUCT_ID
    l_XXXXX         LABEL
    e_XXXXX         EVENT
    other           ARITH_ID

The preprocessor would handle it something like macros:  For several of these, it would use `DECLARE` statements to create a separate macro for each affected declared identifier, and that macro's scope would be the present block (or inline blocks).  For example,

    DECLARE MYBOOL BOOLEAN;
    DECLARE MYCHAR CHARACTER;
    DECLARE MYINT INTEGER;
    DECLARE MYSCALAR SCALAR;

would have the same preprocessing effect as

    REPLACE MYBOOL BY "b_MYBOOL";
    REPLACE MYCHAR BY "c_MYCHAR";
    /* No REPLACE/BY needed for INTEGER or SCALAR. */

Others (`LABEL`, `EVENT`) would have to be detected differently, since they have no `DECLARE`.

I haven't implemented it in the preprocessor yet, but simply in terms of building the compiler (using the full HAL_S.cf) it has the effect of changing 

    HAL_S.y: warning: 618 shift/reduce conflicts [-Wconflicts-sr]
    HAL_S.y: warning: 410 reduce/reduce conflicts [-Wconflicts-rr]

to

    HAL_S.y: warning: 784 shift/reduce conflicts [-Wconflicts-sr]
    HAL_S.y: warning: 129 reduce/reduce conflicts [-Wconflicts-rr]

I.e., 1028 conflicts reduced to 913.  Well ... not wonderful, but at least a step in the right direction.

# 2022-11-20

My idea of debugging this problem is to divide and conquer:  Rearrange the rules in HAL_S.cf into major groups, and comment out all of the groups except the ones already debugged and the one currently being debugged.  Fortunately, bison has a multiline comment feature to accomplish this:

    {-
    ...
    -}

On my first attempt at this, I use as the top-level group of rules the "blocks" in general, but without any contents.  For example, this would include `XXXX: PROGRAM; ... CLOSE XXXX;` but without any internal statement like declarations, assignments, etc.  

Unfortunately, even with the identifier-naming convention changes described in the preceding entry, just defining the blocks takes over half the rules, and leaves us with

    HAL_S.y: warning: 297 shift/reduce conflicts [-Wconflicts-sr]
    HAL_S.y: warning: 52 reduce/reduce conflicts [-Wconflicts-rr]

It appears to me that that *may* be because the rule for `EXPRESSION` is needed, though it's hard to understand at the 50,000-foot level why that would be so.  Let's track it down:

* `EXPRESSION`
* Which is needed by `LIST_EXP`
* Which is needed by `CALL_LIST`
* Which is needed by the following:
    * `CHAR_PRIM`, which is needed by `CHAR_EXP`.
    * `BIT_PRIM`, which is needed by `BIT_CAT`, which is needed by `BIT_FACTOR`, which is needed by `BIT_EXP`.
    * `STRUCTURE_EXP`
    * `PRE_PRIMARY`, which is needed by `PRIMARY`, which is needed by `FACTOR`, which is needed by `PRODUCT`, which is needed by `TERM`, which is needed by `ARITH_EXP`.
* `CHAR_EXP`, `BIT_EXP`, `STRUCTURE_EXP`, and `ARITH_EXP` are needed by `EXPRESSION`.

So, any time any one of these `XXXX_EXP` types is needed, *all* of them are dragged in as well.

Why is any one of the `XXXX_EXP` needed for empty blocks?  Well, it's tough to fully track down, but `ARITH_SPEC` is needed by `QUALIFIER`, which is needed by `SUBSCRIPT`, so `ARITH_SPEC` literally intrudes everywhere.

Therefore, rather than starting with debugging the rules for empty blocks, it makes more sense starting with rules for `ARITH_SPEC`, then expanding to rules other objects.  

So far I've done this for `ARITH_EXP` (without `SUBSCRIPT`) through `SUBSCRIPT`, through `BIT_EXP`, through `CHAR_EXP`, through `NAME_EXP`, through `STRUCTURE_EXP` (which completes all of `EXPRESSION`), through `ASSIGNMENT`, through `IF_STATEMENT`, and have eliminated all errors so far.  That's pretty good, since it accounts for roughly half of all the rules.

I've encountered the following basic problems that had to be fixed along the way.  Firstly &mdash; my own error, but inherited from syntactic difficulties with BNF &mdash;

    CAT ::= "CAT" ;
    CAT ::= VERTICAL_BAR VERTICAL_BAR ;
    VERTICAL_BAR ::= "|" ;

really needed to be

    CAT ::= "CAT" ;
    CAT ::= "||" ;

Second, lots of stuff like

    X ::= PREFIX Y SUBSCRIPT ;
    PREFIX ::= EMPTY ;
    PREFIX ::= prefixstuff ;
    SUBSCRIPT ::= EMPTY ;
    SUBSCRIPT ::= suffixstuff ;
    EMPTY ::= ;

seemed to really confuse it.  I think the empty `PREFIX`'s may have been more confusing than the empty `SUBSCRIPT`'s.  Whatever!  I instead systematically introduced

    X ::= Y ;
    X ::= Y suffixstuff ;
    X ::= prefixstuff Y ;
    X ::= prefixstuff Y suffixstuff ;

which it seemed to like a lot better.

Thirdly, there were a number of instances like

    MODIFIED_xxx_FUNC ::= PREFIX NO_ARG_xxx_FUNC SUBSCRIPT ;
    NO_ARG_xxx_FUNC ::= EMPTY ;

These represent (I believe) runtime-library functions with no arguments, of which there weren't any other than `NO_ARG_ARITH_FUNC`'s.  So the empty `MODIFIED_xxx_FUNC`'s were removed entirely.

This divide-and-conquer debugging method is working, and thus will be continued ....

# 2022-11-21

I've worked through the remaining LBNF problems, I think, at least insofar as the code samples I have are concerned.  There are no errors or warnings when building the compiler front-end (vs the 1000+ experienced before), and all of the code samples I've collected then compile without syntax errors.  But since I've only put together samples from a little less than half of "Programming in HAL/S" so far, there may still be a ways to go.

The LBNF changes I've made have mostly been straightforward and seemingly without the potential for causing problems.  One area of confusion, though, is the following BNF rule from p. G-3 of the Nov 2005 version of the "HAL/S Language Specification":

    <REL PRIM> :: = (1<RELATIONAL EXP>)
                    | <NOT> (1<RELATIONAL EXP>)
                    | <COMPARISON>

This rule makes no sense whatever to me, causes the parser problems (because it's ambiguous), and doesn't appear to be documented anywhere.  It does appear as-is in the program comments of SYNTHESI module of the original HAL/S compiler.  However, the 1's do *not* appear in the 1976 version of the "HAL/S Language Specification".  I think they're bogus, and have removed them.

Something that seems more-problematic is syntax such as

    DECLARE A MATRIX;
    DECLARE B MATRIX;
    ...
    [A] = [B] ** (-1) ;

This would mean to assign every element of the matrix `A` with the inverse of the corresponding element in matrix `B`.  Whereas the syntax

    A = B ** (-1) ;

would instead mean to take the matrix inverse of `B`.  However, the BNF simply omits this entirely:  There's not one reference to brackets in the entire language description. Nor are there any brackets used in SYNTHESI.  So for now at least, the LBNF and the consequent compiler front-end cannot use this bracket syntax.  In fact, the preprocessor currently removes it entirely, and simply converts `[A]` to `A`.  This needs to be fixed at some point.

# 2022-11-25

At this point, all of the code samples from "Programming in HAL/S" have been transcribed and are in the source tree, except for a couple that were just too fragmentary.  I know that there are problems with the preprocessor and compiler front-end, though, so now I want to work out the bugs in these areas by going through the samples one by one.  I guess I'll keep a record of that here.

Basically, two detailed inspections are made, of the commands

    yaHAL-preprocessor.py FILENAME.hal
    yaHAL-preprocessor.py FILENAME.hal | TestHAL_S | syntaxHierarchy.py --collapse

and any discrepancies from expectations are noted and fixed.  I don't recall if I mentioned `syntaxHierarchy.py` before, but it formats the abstract syntax tree output by the compiler front-end `TestHAL_S` in a slightly more-readable form.

## 021-SIMPLE.hal

The only things the preprocessor needs to do here are to correctly mangle the name of the program ("SIMPLE" &rarr; "l_SIMPLE") and to correctly convert full-line comments from `C` in column 1 to `//`.  Which it does.

As far as the compiler front-end is concerned (i.e., the LBNF description of the language), I notice the following:

* The `l_SIMPLE: PROGRAM;` is correctly parsed, but the LBNF labels associated with that don't allow us to easily tell what kind of block it is (i.e., program vs function vs procedure vs etc).  Changed labeling to account for that.
* In `DECLARE R SCALAR;`, the LBNF labels again didn't allow us to easily distinguish `INTEGER` vs `SCALAR` vs. etc.  Fixed that.

The front-end compilation seems fine after those fixes.

## 029-DATATYPES.hal

Preprocess output seems perfect.

Compiler front-end output:  Declarations look fine.  `S = V . V;` looks fine.  `S = V * V;` looks fine.  `V = M V;` looks fine.  `M = V V;` looks fine.  `M = M M;` looks fine.  `V = V S;` looks fine. 

I.e., all good.

## 031-DECLARE3.hal

Preprocessor fine.  Compiler front-end:  `DECLARE COUNTER INTEGER;` looks fine.  `DECLARE VECTOR, POSITION, VELOCITY, TORQUE;` looks fine.  `DECLARE NEW_CO_ORDS MATRIX, SPEED SCALAR, N INTEGER, WIND_FORCE VECTOR;` looks fine.

All good.

## 032-INITIAL_AND_CONSTANT.hal

It's pointless continually listing the lines that compiled correctly.  From now on I'll just talk about stuff that did not compile correctly.

All good.

## 037-ROOTS.hal

All good.

## 039-CORNERS.hal

All good.

## 044-ORTHONORMAL.hal

All good.

## 046-XYZ_TO_POLAR.hal

All good.

## 047-ROWS.hal

All good.

## 052-TABLE.hal

Preprocessor okay.

Compiler front-end:  Okay, I think.

## 053-PARALLAX.hal

All good.

## 071-DARTBOARD_APPROXIMATION.hal

All good.

## 072-EXAMPLE_2.hal

All good.

## 076-EXAMPLE_3.hal

All good.

## 080-EXAMPLE_4.hal and 080-EXAMPLE_4A.hal

All good.

## 085-FACTORIAL.hal

Preprocessor:  Incorrectly, does macro replacements within strings and probably comments; in this case, `'FACTORIAL=...'` &rarr; `'l_FACTORIAL=...'`.

# 2022-11-27

## 085-FACTORIAL.hal (continued)

Implementation of this is very confusing.  The problem is that as of right now, the preprocessor works on a line at a time.  There are certain exceptions, in that in processing declarations, for example, it joins together separate lines for the purpose of analysis without the hassle of line-breaks in the middle of search patterns.  But in this case, actual replacements of text are needed.  It's best to do this without worrying about line breaks ... but on the other hand, we need to keep track of those line breaks to a certain extent for printing output, positioning of error messages, and so forth, and that's really tough to do if we eliminate the line breaks and start replacing text.

Or do we?  The documentation makes a big deal about how the coder has no control whatever over the formatting of the output listing, and that the compiler formats it all automatically in a presumably better way.  I wonder if this extends to line breaks as well, and to positioning of comments?  Because if it does, then my concern over tracking the positions of the line breaks is silly:  I ought to simply reformat all of the source code right from the get-go into lines that each contain a single, complete statement ... even if they're very long lines. (After rejoining of E/M/S constructs, of course.)  And then inline comments should all be moved to the ends of those unified lines.  (And if there's a full-line comment in the midst of a statement that has been broken into multiple lines and is being rejoined?  Perhaps such full-line comments should be moved, as separate lines, to the front of the multi-line statement.)

Requires thought ....

# 2022-11-29

## 085-FACTORIAL.hal (continued)

Here's a digression from what I had been doing.  It seems as though trying to work with the source-code in free-form is just too problematic.  So after the preprocessor removes the E/M/S constructs in favor of single-line assignments, but before it does anything else, I've added code to the preprocessor that reorganizes all of the source code so that each line is everything leading up to the final semi-colon (or else is a full-line comment or a compiler directive).  Inline comments are all moved after the semicolon, and delimited from it by a tab rather than a space.

One thing I had not counted on here, and indeed had forgotten about if I ever even knew it, is the possibility of semicolons appearing in subscripts as "copy numbers" of structures.  My initial implementation of the line reorganizer just mentioned doesn't support that and needs to be fixed.

Another thing ... it appears from p. 46 of "Programming in HAL/S" that E/M/S constructs are not limited to just three lines.  It shows an example of E/M/S/S, but presumably you can have any number of E's, followed by an M, followed by any number of S's.  My preprocessor code doesn't do that at the moment, and so perhaps will need to be fixed.  Or perhaps not, since I can't imagine any sane coder actually inputting source code using such an unwieldy convention.  Perhaps that only needs to be worried about in the pretty-printing, which I'm nowhere close to considering yet anyway.

# 2022-11-30

## 085-FACTORIAL.hal (continued)

Okay, semicolons appearing in subscripts, to any depth, has now been taken care of in the line reorganization.  That required also matching of parentheses.

Finally, the new line-reorganizer code, having knowledge as it does about which portions of each line are single-quoted strings and inline comments, is able to protect those agains REPLACE macros and identifier mangling by temporarily translating them to characters not in the HAL/S character set, and then restoring them afterward.

This finally fixes the `FACTORIAL` code.

## 091-NEWTON_SQRT.hal

The preprocessor does an infinite loop on this one ... but that's just a bug in the comment-detection line reorganizer code I added yesterday; easily fixed.

All okay.

## 095-TAN_SUMS.hal

The preprocessor's new line-reorganizer code appends the multiline comment following the opening full-line comment to the full-line comment.  Fixed that.

`DO UNTIL TOTAL > 5 PI;` is misparsed as `WHILE` ... not it wasn't, but the LBNF label didn't distinguish between `WHILE` and `UNTIL`, so it was hard to read.  Fixed that.

All okay.

## 097-SAMPLE_FLOW.hal

All okay.

## 104-EXAMPLE_1.hal

All okay.

## 106-EXAMPLE_2.hal

I don't see that `TEMPORARY` is indicated in the abstract syntax tree, for `DO TEMPORARY I = 1 TO 4;` or `DO FOR TEMPORARY J = 1 TO 3;` ... but it was; the LBNF labeling in the compiler front-end just wasn't adequate to make that obvious.  Fixed now.

All okay.

## 107-EXAMPLE_3.hal and 107-EXAMPLE_4.hal

All okay.

## 108-EXAMPLE_5.hal

All okay.

## 112-EXAMPLE_6.hal

This example contains identifiers like `[ATT_RATE]`, `[GYRO_INPUT]`, and `[SCALE]`, which I had previously had the preprocessor eliminate in favor of `ATT_RATE`, `GYRO_INPUT`, and `SCALE`.  I'm convinced now that that was the wrong behavior.  So I've removed that behavior from the preprocessor and have made adjustments to the compiler front-end's LBNF to accommodate new `<ARITH VAR>` types `[ <ARITH ID> ]` and `[ <ARITH ID> ] <SUBSCRIPT>`.  It may take a while to see if those are the appropriate changes.

All okay now.

## 113-EXAMPLE_7.hal

The preprocessor code for line reorganization that protected inline comments and single-quoted strings did not properly handle occurrences of "¬" occurring outside of those contexts, incorrectly converting them them to ",".  Fixed that.

All okay now.

## 117-EXAMPLE_8.hal

All okay.

# 2022-12-01

## 119-EXAMPLE_9.hal

All okay.

## 120-EXAMPLE_A.hal

I can't distinguish things like `DATA_VALID$(I:) = FALSE;` from `DATA_VALID$(I) = FALSE;` in the abstract syntax tree.  I see now that 119-EXAMPLE_9.hal had this problem as well, but I just didn't notice it before.

All okay now.

## 127-LIMIT.hal

All okay.

## 128-MASS.hal

When a function name or procedure name is mangled via a definition of the function or procedure or a forward declaration of it, the scope of the mangled name could be the parent context, not just the interior of the function or procedure.  That fails in this example, where the function `TAU()` isn't accessible to the parent (`MASS()`).

Fixed for function/procedure definitions but not yet for forward declarations, since this example doesn't have any to test.

All okay now.

## 129-ALMOST_EQUAL.hal

All okay.

## 130-EXAMPLE_N.hal

This example has a forward definition of a function, for which the mangling of the function name as mentioned above remains to be fixed in the preprocessor.