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

# 2022-12-02

## 130-EXAMPLE_N.hal (continued)

Fixed the forward-declaration stuff mentioned yesterday, and a typo in the code sample itself.

All okay now.

## 134-DOTS.hal and 134-ROLL.hal

All okay.

## 136-DOTS.hal

All okay.

## 137-STATISTICS.hal

In the LBNF grammar, some RTL functions that I now think should be `<ARITH FUNC>` type had been set (by me, as they were opmitted from the original BNF grammar) as `<STRUCT FUNC>`, causing the compilation to fail.  (In particular, `SUM()`.)  I've changed that.

All okay.

## 138-FILTER.hal

All okay.

## 140-STATISTICS.hal

All okay.

## 141-VSUM.hal

All okay.

## 154-ADD.hal

Couldn't tell from abstract syntax tree which minor attribute (`AUTOMATIC`) was in the declaration `DECLARE TOTAL SCALAR INITIAL(0) AUTOMATIC;`.  Fixed the labeling in the LBNF grammar to allow it.

All okay now.

## 158-STATE.hal

Fixed a typo in the sample code, but otherwise okay.

## 159-AGE.hal

Preprocessor problem with the scope for name mangling: It doesn't allow for redeclaration of an identifier that the parent scope is mangling.  In this example, the problem is that it's for a program called `AGE`, which at the top-level scope is being mangled as `l_AGE`.  However, within the `AGE` program itself, there's also a declaration for `AGE` as a local variable.  *Within* the scope of the `l_AGE` program itself, `AGE` should not be mangled.

Besides which the `INTEGER()` RTL function (if that's what it actually is) was not recognised as such.

Having fixed those things in the preprocessor and LBNF grammer, all is okay.

## 160-REFORMAT.hal

Same situation as in section above:  `CHARACTER()` not recognized as an RTL function in the LBNF grammar.

Plus it appears as though the RTL functions `LENGTH()` and (perhaps) `INDEX()` are miscategorized in the LBNF grammar as `<CHAR FUNC>` rather than `<ARITH FUNC>`.  (Again, these were absent from the documented BNF grammar, so I had invented them myself.)

Even with that fix, `INTEGER$(@DOUBLE)()` is not parsed correctly ... or wait, maybe it is parsed okay after all.  Well, it's hard to tell from the abstract syntax tree.   Yes, it's okay, because it does have an `<ARITH FUNC HEAD>` that I was too daft to see.

Looks good to me.

## 164-OUTER.hal

"Programming in HAL/S" has a misprint here, which I faithfully transcribed into the source file and have now needed to correct.  Specifically, in place of `DECLARE VNAME CHARACTER(8);`, the document instead had `DECLARE V NAME CHARACTER(8);`.  As it happens, the latter is indeed something that can be parsed, so that added to the confusion.  Nevertheless, parsable or not, it doesn't seem to match what's happening in the remainder of the code.

The labeling in the LBNF grammar didn't let me easily distinguish the differen i/o controls in `READ` (i.e., `SKIP`, `COLUMN`, and so on).  Now fixed.

All okay now.

## 167-ASSORTEDIO.hal

Syntax error at `IOPARM` in `STRUCT IOPARM: ...;` ... oh, that's a typo in the sample code:  `STRUCT` should have been `STRUCTURE`.

# 2022-12-03

## 167-ASSORTEDIO.hal (continued)

Well, the syntax error remains after fixing that.  It may be because while I mangle several types of identifiers (labels, booleans, boolean functions, ...), I never go around to mangling structure identifiers.  It looks like there are three places where the preprocessor has to deal with mangling of structure IDs (not to mention structure functions, which I haven't gotten to):

    STRUCT ID1: ...;
    DECLARE ID2 ID1-STRUCTURE ...;

This needs to become:

    STRUCT s_ID1: ...;
    DECLARE s_ID2 s_ID1-STRUCTURE ...;

Even having done this in the preprocessor, the line `DECLARE IO PROCEDURE NONHAL(1);` fails; and it's not the `NONHAL` part that's failing.  Apparently, the reason is that the preprocessor mangles `IO` &rarr; `l_IO` (as I intendeded), but the LBNF grammar expects the procedure name in a forward declaration to be just any old identifier, and not the mangled form, whereas in the actual `CALL` to the procedure we need the mangled name.  That requires a replacement rule in the LBNF grammar for forward procedure declarations.

With that, there's a failure at "`)`" in line `CALL l_IO(s_FWDSENSORS);`.  In these cases, we'd usually suspect that the parser thinks `l_IO` is a variable rather than a procedure or function, but we know that's not happening because if we replace `l_IO` by just `IO`, the error occurs at `IO` rather than at "`)`".  I think this must be a failure in the `CALL` parsing rules, since I notice that while preceding code samples do have procedure definitions, they actually have no `CALL`s to the procedures they define ... so this sample actually has the very first usage of `CALL`.  The answer appears to be that structure IDs are not accepted in the procedure's parameter list.  I've added that to the LBNF grammar (at `<LIST EXP>`), though it's unclear if that's the best place to do so.

With that, there's now a failure at `DO_NAV_READ` in the line `SIGNAL DO_NAV_READ;`.  That would appear to be because I haven't yet added mangling of event names to the preprocessor.  Having added that, the declaration `DECLARE e_DO_NAV_READ EVENT;` fails because the LBNF grammar doesn't expect a mangled event name here. Fixed that.  I'm not sure that all possible declarations of events are covered, though, so problems may recur with more-complicated declarations.

Now compiles without error, but it's difficult to understand the parsing of `INITIAL(NAME(NULL))` from the abstract syntax tree.  Changed some LBNF labels to handle that.

After all of that stuff, seems okay, though admittedly the example contains so much stuff I've never seen before (in almost every line) that it's tough to be sure.  At least I'll say it's okay for now.

## 169-OUTER.hal

Looks good.

## 170-OUTER.hal

In

    STRUCTURE UTIL_PARM:
        1 V VECTOR,
        1 S1 SCALAR,
        1 C INTEGER,
        1 S2 SCALAR,
        1 E BOOLEAN;

it seems to me that it should be `1 s_E BOOLEAN`.  It doesn't cause any problem in *this* example, so for the moment I'm going to ignore it.

Another thing which doesn't cause me any problem in this example but which is wrong is that 

      UTIL:
      FUNCTION(X) VECTOR;
         DECLARE X UTIL_PARM-STRUCTURE;
         RETURN X.V;
      CLOSE UTIL;

preprocesses to

      l_UTIL:
      FUNCTION(X) VECTOR;
         DECLARE s_X UTIL_PARM-STRUCTURE;
         RETURN s_X.V;
      CLOSE l_UTIL;

I.e., the mangling of `X` to `s_X` has no way to work backwards into the parameter list as `FUNCTION(s_X)`.  This definitely needs to be fixed.

# 2022-12-04

## 170-OUTER.hal (continued)

Changed the preprocessor to apply name-manglings associated with `DECLARE` statements to the immediately enclosing `FUNCTION` or `PROCEDURE` definition parameter lists.

However, it nows gives an error at the now-properly-mangled line `l_UTIL: FUNCTION(s_X) VECTOR;`.  The problem is that only `<IDENTIFIER>` (i.e., unmangled) tokens can appear in parameter lists of `FUNCTION` or `PROCEDURE` definitions.  I've fixed this in the LBNF grammer to allowed mangled tokens as well. I don't know for sure if function/procedure names can be passed as parameters or not, but I think not, so I haven't allowed mangled tokens for those to be used.

After those changes, the abstract syntax tree looks good to me.

## 172-OUTER.hal

There's a syntax error at "`;`" in `READ(5) s_ARG;`.  That's because the `<READ ARG>` type can be a `<VARIABLE>`, but I haven't allowed `<VARIABLE>` to be a mangled structure-ID token.  I've added it to the LBNF grammar; I'm not sure that's the best place for it, as opposed to in `<READ ARG>` directly, but that's what I've done.

Next, there's a syntax error at the 2nd "`,`" in `WRITE(6) 'UTIL OF', s_ARG, '=', l_UTIL(s_ARG);` for obviously similar but not identical reasons.  This is hard to fix in the LBNF grammar, because several places I added mangled struct-ID names caused conflicts in building parser.  I've at least temporarily added it as a special type of `<WRITE ARG>`.  Perhaps it's adequate.

With those changes, looks good to me.

## 176-P.hal

There's a syntax error at `INTEGRATE` in line `CALL INTEGRATE(s_STATE2.s_STATE.ACCEL) ASSIGN(s_STATE2,s_STATE.VELOCITY);`.  It seems to me that there *ought* to be an error there, since there's no forward declation of `INTEGRATE`, so the name of the procedure isn't properly mangled to `l_INTEGRATE`.  In other words, this appears to me to be an error in the code sample, though in reviewing the original (p. 176 of "Programming in HAL/S"), I seem to have transcribed it correctly.  

I've "fixed" this by adding the forward declaration `DECLARE INTEGRATE PROCEDURE;`.  However, this statement itself causes a syntax error, because the LBNF grammar apparently expects this forward declaration to have a non-empty `<MINOR ATTR LIST>` at the end.  (Or perhaps `<MINOR ATTR LIST>`s used to have an `EMPTY` option that I've long since had to get rid of.  Whatever.)  I've fixed this in the LBNF grammar.

There's a syntax error at "`;`" in the line `FILE(1, CYCLE) = s_STATE2.s_STATE;`.  This appears to be because `s_STATE` is mangled.

TBD1

Moreover, I've seen that structure fields of structure templates are not mangled by the preprocessor.  TBD2

And here's a really big problem!  What a field name of a structure coincides with another identifier that isn't supposed to be mangled; or vice-versa?  The stupid preprocessor depends only on pattern matching, so it doesn't know the difference.  Mangle one, mangle all!  This appears to me to be an almost unvolvable problem without the preprocessor being able to fully parse the source rather than relying on pattern matching.  Or at least having some metadata that latches onto the identfiers somehow in determining if they should be mangled.  Yikes!  TBD3

# 2022-12-05

## 176-P.hal (continued)

Regarding TBD1 from yesterday, it's still pretty mysterious to my why that file expression wasn't working, but I did eventually find a way to finagle it into the LBNF rules, and it did compile without conflicts, and that did eliminate the syntax error.

Regarding TBD3, the truth is that I don't even know if this problem occurs.  I'm inclined to simply say that the modern compiler doesn't support that kind of name duplication, and perhaps add code to detect it and emit a fatal error.  At any rate, **I don't intend to solve it *right now*, so it's deferred.**

That leaves TBD2, which is something that affects this very code sample. 

With TBD2 fixed in the preprocessor, we now have a syntax error at "`=`" in line `s_STATE2.s_STATE.s_ACCEL = READ_ACC(17);`.  This would seem to be because there is no declaration of the function `READ_ACC`, so the preprocessor cannot mangle the name.  I'd call this a bug in the code sample.  Unfortunately, I don't actually understand how to make either a forward declaration or an actual function that fits the bill.  Nor do I think the LBNF grammer has "structure functions" built into it correctly yet; and `READ_ACC` *must* be a structure function, because the multiline annotation for it (in the exponent line) is "`+`" (just as it is for `s_ACCEL`).  So this needs a lot more thought.

# 2022-12-06

## Issue "TBD3"

Regarding issue TBD3, first mentioned 2 days ago, and disposed of yesterday as being "deferred" due to the wishful thinking that perhaps it's something that never arises in practice, I have additional thoughts.

Firstly, it *nearly* happens even in code sample 176-P.hal, since in the declarations

    DECLARE STATE STATEVEC-STRUCTURE;
    STRUCTURE S2:
        1 STATE STATEVEC-STRUCTURE,
        1 ATTITUDE_INFO ARRAY(3) VECTOR DOUBLE;
    DECLARE STATE2 S2-STRUCTURE;

we see `STATE` is declared both as a top-level variable and as the structer-field `STATE2.STATE`.  The fact that both declarations of `STATE` just happen to be of the same type, `STATEVEC-STRUCTURE`, and therefore just happen to be mangled correctly in the same way, is luck.  They could just as easily have had different types.  So this problem *will* occur in practice, and there's no point pretending that it mightn't.  I'm afraid the pretense that it might turn out not to be a problem was based more on my inability to think of any way to work around it in the current framework than anything else.

Secondly, I think there *is* a way to work around it in within the existing preprocessor framework after all, and it goes something like the following.  In the first place, all mangling of top-level variables (i.e., not structure fields) remains identical to before:

  * Top-level variable:
    * Arithmetical (`INTEGER`, `SCALAR`, `VECTOR`, `MATRIX`) &mdash; no mangling
    * Boolean &mdash; prefix "b_" added.
    * Character &mdash; prefix "c_" added.
    * Structure &mdash; prefix "s_" added.

For structure fields, however, an additional step is needed.  Every structure field is declared as part of a structure template, and is therefore associated with the following metadata:  The name of the structure template, and the tree-position within the structure template.  As an example, consider the following arbitrarily-chosen structure template:

    STRUCTURE A:
        1 B ...,
        1 C ...,
            2 D ...,
                3 E ...,
            2 F ...,
        1 G ...;

By the tree-position within the structure template, speaking loosely, I mean that `B` is at the 0 position, `C` is at the 1 position, `G` is at the 2 position, while D is at the 1.0 position, F is at the 1.1 position, and E is at the 1.0.0 position.

Though I've shown all of the identifiers here as if they were different, realize that many of them could actually be duplicates.  Thus while we cannot have B==C, C==G, B==G, or D==F, we could have A==B, A==C, A==D, B==D, D==E, etc.  The mangling scheme has to account for all of those possibilities.  It does that by including the path within the mangling scheme.

Specifically, imagine this.  From the metadata for each field (structure-template name and path into the structure template), construct some kind of unique numerical hashcode, or at least a hashcode that's extremely unlikely to repeat.  For example, for field E, we might first form the string

    path + "_" + structureTemplateName = "1.0.0_A"

and then take a 32-bit CRC of "1.0.0._A", say *NNNN* (in decimal form, not hexadecimal).  If, say, `E` were of type `BOOLEAN`, the fully mangled name for field `E` would be

    b_*NNNN*_E

(By the way, this is written in advance of implementation, so I'm merely presenting a concept here.  I don't claim that the actual implementation will faithfully follow the exact details of what I just showed you.)

This scheme works even for separately-compiled units, since the hashing depends on the name of the structure *template* and not on the declared name of the structure using that template.  Recall too that when the output listing is created, the compiler must reverse all mangling that the preprocessor had previously added.  Suffixes of the type

    *lowerCase*_*NNNN*_

are always removable, since the PFS/BFS source code never uses lower-case and never allows digits as the leading character of identifier names. 

By the way, reversability of the mangling (as well as the desire to keep mangled identfiers from becoming very, very long) is the reason for choosing a decimal-numerical hashcode rather than simply using an unhashed string like "1.0.0_A" as the "hashcode" or a hexadecimal hashcode.

So finally, here is the full mangling scheme:

  * Top-level variables and structure-template names:
    * Arithmetical (`INTEGER`, `SCALAR`, `VECTOR`, `MATRIX`) &mdash; no mangling.
    * Boolean &mdash; prefix "b_" added.
    * Character &mdash; prefix "c_" added.
    * Structure &mdash; prefix "s_" added.
  * Structure fields:
    * Arithmetical (`INTEGER`, `SCALAR`, `VECTOR`, `MATRIX`) &mdash; "a_*HASHCODE*_" added.
    * Boolean &mdash; prefix "b_*HASHCODE*_" added.
    * Character &mdash; prefix "c_*HASHCODE*_" added.
    * Structure &mdash; prefix "s_*HASHCODE*_" added.

Note that except for arithmetical fields, the structure-field mangled names are legal top-level mangled names as well, so they do not require any changes to the LBNF grammer over those previously made for the weaker mangling scheme.  Whereas the arithmetical structure fields require merely a minor addition to the LBNF grammer.  I think.

## Issue "TBD3" Revisited

The scheme presented in the preceding section for working around issue TBD3 is too clever ... which is a polite way of saying that in this case means "not very good".  It overlooks a couple of important points.  One it overlooks is a possibility like:

    STRUCTURE A: 1 B type, ...;
    STRUCTURE C: 1 C A-STRUCTURE, ...;
    DECLARE E C-STRUCTURE;

since in actual use you could then find references like

    X = E.C.B;

where field `B` doesn't have any readily accessible tree-position in `E`; rather you have to navigate through both `E`'s and `C`'s tree structure to find field B.  The other thing is that the scheme isn't easy to apply to structure references you find, *regardless* of whether or not there are these multiple redirections to different structure templates.

The truth, it appears to me, is that there isn't going to be any adequate scheme based on pattern searches for the field names alone, *regardless* of how they're mangled.

So here's a very different idea:

1. Only *top-level* identifiers (i.e., not fields in structures) get added to the macro list.
2. Every `STRUCTURE` statement encountered to define a structure template results in construction of a tree describing that structure template, and all of these trees are stored in a dictionary of structure templates.
3. Keep track of all the datatypes of top-level variables, specifically of those declared as structures.
4. For the macro replacements, the input lines are no longer regex-scanned for identifiers.  Rather, they are scanned for regular expressions that (loosely speaking) are of the form "IDENTIFIER(\s&#42;\\.\s&#42;IDENTIFIER)*".  In other words, complete paths to structure fields.  If the match contains no periods, then it's just a plain identifier and a regular macro-style replacement can be done on it.
5. If the matches contain periods, then they have to be analyzed vs the existing structure templates to determine how each field must be mangled.  The mangling, in all cases, is just the old-style mangling with "b_", "c_", and "s_" prefixes; no "hashcodes" or any other additions are needed.

Two points.  First, you might suppose that some structure-template fields might have a type that's an array of structures, in which case you'd have to worry about awful cases like A.B.C$(1,2).D.  However, if you look at the BNF grammar, I don't think there's any allowance for subscripts in the middle like this ... only at the end.  Which is queer, since `STRUCTURE` statements seem to allow fields to be arrays of structures, and since it seems like it would be very useful.  At any rate, it would make the parsing the preprocessor would have to do extremely problematic; you couldn't do it with regular expressions.  So for my purposes, good riddance!

Regardless of what I think I'm reading in the BNF grammar, "Programming in HAL/S" has some clarifications and confusions:

* PDF p. 101: "HAL/S allows arrays of any data type;" however, it makes this claim 3 chapters prior to introducing structures, so it's unclear to me that "any data type" includes structures (or `NAME`, or `EVENT`, or anything other than `INTEGER`, `SCALAR`, `CHARACTER`, `BOOLEAN`, `VECTOR`, and `MATRIX`).  For that matter, does HAL/S consider structures to be a "datatype" at all? (The BNF grammar *does*.)
* PDF p. 180:  A whole subsection (9.3) introduces the concept of "multi-copied structures" ... which have very little difference from one-dimensional arrays of structures, except for a few restrictions.  They're used the same way.  What's the point of having this entirely new concept of multi-copied structures if you can already have arrays of structures, and arrays of structures have less restrictions on them?
* PDF p. 185: "Arrays may be used as structure components, but multi-copied structures may not."

Well, this is hard to resolve at this remove.  It appears to me that arrays of structures aren't allowed, but that multi-copied structures exist in their place, and that they can't be used as structure components even though arrays of simpler datatypes can be.  I'm going to go with that until I encounter counter-examples.

Secondly, if you look at it superficially, it would seem that if you had a structure path of a form like A.B.C.D.E, then all of the leading identifiers would have to mangle with "s_", since they must all be structures, and thus the only questionable mangling is for the final field.  Alas, this is not so.  The reason is that "." can be a dot-product operator too, so if you have an expression like this it could also represent dot products in a variety of ways:

    (A) . (B.C.D.E)
    (A.B) . (C.D.E)
    ...
    (A.B.C.D) . (E)

So unfortunately, there's no choice to to analyze these expressions enough using the trees for the structure templates to determine if any of the dot-product cases applies.  Nevertheless, once you've done that, the remaining structure expressions do have the property that only the final field can have a mangling other than "s_".

In spite of this little quirk, this scheme does seem to me to be very workable.  I'll think on it a bit more before trying to act on it, though.

# 2022-12-13

I've spent the last few days reworking the fundamental structure of this software.  Here are the main differences:

 1. The compiler front-end has been fixed up, so that there are now two executables built:  TestHAL_S, which is exactly the same as the BNF Converter demo I've been using up to now, and modernHAL-S-FC.  The two are almost the same, but the latter one quotes strings in its abstract syntax output using carats rather than double-quotes ... which makes those strings parsable easily rather than messes that aren't guaranteed consistent.  The latter program also omits some outputs that we don't care about.  Finally, it would not normally be called independently, but rather would be invoked normally by the preprocessor.
 2. The preprocessor program (yaHAL-preprocessor.py) has been replaced by yaHAL-S-FC.py, which is calls the compiler front-end directly rather than via some explicit pipe in the shell.  It also parses the "abstract syntax" output by the compiler front-end, both for subsequent processing and for human inspection.  The latter point obsoletes syntaxHierarchy.py.
 3. Changes to the LBNF grammar have been made to allow the new preprocessor yaHAL-S-FC.py to call the compiler front-end modernHAL-S-FC not only for the compilation of the full source file, but also to compile several types of individual source lines, in particular:  `STRUCTURE`, `DECLARE`, and `REPLACE` lines.  This will allow various types of *ad hoc* but not-fully-correct parsing that the preprocessor does now to be pulled out in favor of simply allowing modernHAL-S-FC to parse those lines correctly according to the grammar.  I've not yet taken advantage of that in the preprocessor, but it opens the door to much-better maintainability and syntactical correctness and completeness in the preprocessor.
 4. A top-level Makefile handles building all this weird stuff automatically (specifically, the hacked version of TestHAL_S that is modernHAL-S-FC).

On the downside, modernHAL-S-FC *is* a hack of TestHAL_S, and relies on the (undocumented) internal structure of the Printer.c files generated automatically by BNF Converter remaining similar to the way it is now.  I think that's actually a fair seems to be a very primitive function unlikely to change.  Plus, the hack is only necessary until I've completely finalized the LBNF grammer, after which point there's no longer a need to regenerated any of the C source files.  But still ....

There are certain drawbacks to the way the preprocessor invokes the compiler front end, in that in the C version of the code, source code can only be passed to the compiler via a file.  Thus to compile a single `STRUCTURE` statement (for example), the preprocessor needs to create a file containing it, run the modernHAL-S-FC program while capturing the textual output, and then finally parse the textual output of the front-end to get a Python structure for the AST.  That's pretty inefficient.  It would be lots better if the compiler front-end could simply be invoked as a library function and the source line passed as a memory buffer.  But the structure of the C code simply doesn't allow it.  I *think* that using Java or Haskell framework for the compiler front-end, rather than C, might let me get around this.  But it's a huge learning curve, particularly for Haskell, since I'd likely want to convert the preprocessor to those languages as well.  Given the hassle, that's something I'm going to put off considering indefinitely.  At least until the Python/C compiler is fully working!

On the other hand, perhaps there's a way to partially do what I was talking about in the preceding paragraph.  At any rate, there's a function `fmemopen()` which associates a file descriptor with a block of memory, and then file operations occur to that block of memory rather than to a file, so the function that would have to be fooled into doing this (`pCOMPILATION(FILE *fp)`) probably would work with it.  It still looks like a lot of work to somehow get Python and C working together.  I suppose that what might be easier, once the proprocessor is perfected, is to rewrite the preprocessor in C.

# 2022-12-14

## 176-P.hal (concluded)

Even after all of the above, there were a number of problems.  For one thing, in `STATE2.STATE.ACCEL = READ_ACC(17);`, there had been no forward declation of `READ_ACC()`, which as far as I know is not a built-in function, so it couldn't be mangled properly.  I've added in the forward declaration.

Next, `<QUAL STRUCT> <EQUALS> <EXPRESSION> ;` was not allowed in the grammar, yet if I added it, it conflicted with `<VARIABLE> <EQUALS> <EXPRESSION> ;`, even though `<QUAL STRUCT>` is not an allowed type of `<VARIABLE>`.  The problem was that the grammar has been allowing assignments with the left-hand side of `<VARIABLE> . <STRUCT_ID>` for some reason, that that caused the conflight.  I've resolved that in the grammar.

Next, `<QUAL STRUCT>` wasn't allowed in a `<CALL ASSIGN LIST>`, which I've I've fixed.

Well ... and probably more stuff of a similar nature that I've forgotten.  At any rate, 176-P.hal now parses without error and the abstract syntax produced looks good to me.

## 177-P.hal

Looks good!

## 180-EXAMPLE_N.hal

The `READ_IMU` procedure has no forward declaration, so I'm adding that.  Similarly for procedures `SELECT_BEST`, `GUIDANCE`, and `OTHER_SW`.

Incidentally, I notice that there may be a grammar bug, because while the parser accepts declarations like

    DECLARE A PROCEDURE, B PROCEDURE;

it nevertheless rejects declarations like

    DECLARE PROCEDURE, A, B;

even though the preprocessor properly mangles both.  And indeed, I find nothing in the grammar that would allow the latter, neither as shown nor with `FUNCTION` in place of `PROCEDURE`.  In contrast, simple datatypes like `SCALAR` or `INTEGER` are allowed, with or without minor attributes.  Logically it would seem to be perfectly proper to allow `FUNCTION` or `PROCEDURE`, but perhaps there's a good reason not to.  At any rate, until I find supposedly-correct code samples that require it, I'm going to assume that the BNF is correct and that they're not allowed.

Also fixed a missing semicolon in my transcription of the code sample.  

After all that, parsing looks good!

## 184-EXAMPLE_N.hal

Lacks necessary forward declarations of `READ_IMU`, `SELECT_BEST`, `GUIDANCE`, and `OTHER_SW`, which I've added.

Additions I had speculatively added to the grammar previously to handle cases like `{ ... }` in analogy to `[ ... ]` had been done incorrectly.  Hopefully fixed now.

Found a spurious `END;` in my transcription of the code sample, which I've removed.

After all that, it compiles.  

I'm going to change my strategy here a little bit, because I'm just going to check now that code samples compiler rather than check the abstract syntax trees in detail.  That's because it has been quite a long time now since I found any that compiled *wrong*, while at the same time, the code samples have become longer and checking the abstract syntax trees in detail takes so much longer.  I'm afraid that this may be slowing down the process of completing/tweaking the preprocessor and grammar so much that I can't complete it, without (at the same time) it being very helpful.  It's certainly draining my enthusiasm, anyway!

## 186-P.hal

This fails at `FLAGS` of `STRUCTURE FLAGS DENSE: ...`.  The preprocessor hasn't mangled `FLAGS` or any of the names of the structure's fields.  That's because my regex for recognizing `STRUCTURE` statements was too restrictive, and was thrown off by the `DENSE` attribute (or any other attribute that could appear there).  Fixed that.

While this compiles as-is, I notice that the preprocessor doesn't mangle the `C` field in `STRUCTURE ..., 1 C CHARACTER(5);`.  The `(5)` is throwing it off.  Fixed that.

Now, though, I see that this is overwriting the `FLAGS` structure template in the library file on every run, with identical definitions.  Whereas it never did that with the other structure templates in the file.  That's once again because of the `DENSE` (or other) minor attribute.  Fixed that.

Compiles now.

## 193-TEST_X.hal

The code sample has no forward declaration for the procedure `X`.  Fixed that.

Fails on the 2nd `WRITE(6) ...`.  Another problem with it is that when I print out the error message, it shows the string literals as encoded for some reason, even though they're not encoded in the mangled source file passed to the compiler front end.  Ah!  The error message is encoded, because the source line comes from the source code buffered in the preprocessor (as it should) ratehr than from the compiler front-end, and I forgot to unencode it.  That's fixed now.

As for why it fails, though, I think that's because the string includes the '¬' characters.  I think there must be some mixup between the encoding of that character (i.e., UTF-8 vs ISO 8859-15) in the code sample file vs the tokens recognized by the LBNF grammar, in which case it ends up not being in the HAL/S character set.

In the discussion earlier (or perhaps it was elsewhere), I went to great lengths to come to the conclusion that encoding ¬ as ISO 8859-15 (or -1) was the correct decision, vs UTF-8.  What I failed to recognize is that when BNFC reads the LBNF grammar for HAL/S, it's not going to play nice with an ISO 8859-15 encoding, and in fact simply bails.  So the notion of using an ISO 8859-15 encoding for ¬ (and for the cent symbol) is increasingly cumbersome.  So that is all being reversed. 

Plus, the string literal doesn't *really* use the ¬ character anyway.  There's something wrong with my encoding/decoding routines in reorganizer.py, in which translating and then untranslating a comma turns it into a ¬.  Fixed them.

With everything consistently UTF-8 now, and all instances of ¬ and ¢ fixed (including in the original HAL/S-FC source.  I hope!), compiles okay.

## 194-TEST_X.hal

Compiles.

## 197-P.hal

Compiles.

## 198-P.hal

Fixed a bad semicolon (should have been a comma) in the transcribed code sample.  Compiles okay now.

## 199-P.hal

Fails at `ERROR` in `ON ERROR DO;`.  This appears to be because `ERROR` has no subscript.  This is a grammar error I caused a while back when I couldn't make empty subscripts work generically in the grammar, and so began handling the empty-subscript case separately.  It affects `ON ERROR`, `OFF ERROR`, and `SEND ERROR`, now all fixed.

Now fails at the colon in `LAST_CARD: CLOSE l_P;`.  The preprocessor wasn't mangling `LAST_CARD` because I had failed to consider that `CLOSE` might have a label preceding it as well as following it.  Fixed.

Now compiles.

# 2022-12-15

## 200-A.hal

The code sample lacked forward declarations for procedures `B` and `C`, as well as having a transcriptions typo (":" in place of ";").  Fixed.

Compiles now.

## 203-A.hal

The code sample lacked forward declaration for procedure `B`. 

Compiles now.

## 205-LOG10.hal

Fixed a transcription typo.  Compiles now.

## 213-GNC_POOL.hal

The proprocessor wasn't mangling names of `COMPOOL`s.  Fixed.

Compiles now.

## 219-P.hal

Fixed a transcription typo.  Also, the proprocessor wasn't mangling names of `TASK`s.  Fixed.

Compiles now.

## 222-P.hal and 222-MULTI.hal

Both compile.

## 224-GNC_POOL.hal

The preprocessor wasn't mangling names of `UPDATE`s.  Fixed.

Compiles now.

## 225-MEAN.hal

Compiles.

## 230-STARTUP.hal

Fixed transcription typo.  Compiles now.

## 234-X.hal

Compiles.

## 237-STARTUP.hal

Fixed a couple of transcription typos.  Compiles now.

## 238-P.hal

Fixed a transcription typo.

Now fails at `LATCHED` in `DECLARE ORBIT EVENT LATCHED INITIAL(FALSE);`.  That's because the grammar's rule for `<DECLARATION>`, there was no choice like `EVENT <MINOR ATTR LIST>`, so the presence of the `LATCHED` (or the `INITIAL(FALSE)`) causes the failure.  Fixed in the grammar.

Compiles now.

## 239-STARTUP.hal

Fixed a pair of transcription typos.  Compiles now.

## 241-P.hal

Fails at the 2nd comma in `DECLARE EVENT, ENGINE_OFF, ORBIT LATCHED;`.  There are two issues:

 1. The preprocessor does not mangle `ORBIT`, even though it mangles `ENGINE_OFF`.  Fixed that.
 2. The compiler front-end doesn't like it whether or not `ORBIT` is mangled.  Made a couple of additions to the grammar to fix that.

Fixed a transcription typo (`RE_IGNITE` vs `RE-IGNITE`).  Fails now at `RE_IGNITE` in `SCHEDULE RE_IGNITE PRIORITY(999);`.  This is because the preprocessor wasn't mangling the identifiers found in `SCHEDULE` statements.  Fixed that.

I notice too that in `WAIT FOR ENGINE_OFF & ¬ORBIT;`, the preprocessor was converting "`¬`" to "`,`".  That's because when the proprocessor encodes inline comments and string literals to prevent them from participating in matches it encodes only the content of the comments and strings, but when it unencodes it does so on the entire line (not just inline comments and string literals).  That's going to have the side effect in Python 3 that "¬"=chr(172) &rarr; chr(172-128)=",".  (It will also convert the cent sign, the only other funky character, to a double-quote if found outside of comments or string literals. However, the cent symbol appears *only* in string literals in HAL/S, so that's not a problem.)  Fixed this by treating ¬ specially in the translation and untranslation functions in reorganizer.py.

I notice that the grammar has a problem in that the declaration lists it uses in the two forms of the `DECLARE` statement, i.e. the 
simple and compound declarations vs the factored declaration (see "Programming in HAL/S" section 2.3), are the same.  Because of this, abominations like the following are syntactically allowed by the parser:

    DECLARE INTEGER, X SCALAR;
    DECLARE e_MYEVENT;

The first of these allows `X` to be declared as an `INTEGER SCALAR`, whereas the second allows an event to be declared as a `SCALAR`.  Of course, this isn't a disaster, since the next compiler phase catches these errors and rejects them.  It may not be fixable in the grammar anyway, and may just be a side-effect of using a BNF description for a non-context-free grammar that has to be tolerated.

Anyway, compiles now.

## 242-P.hal

Compiles.

## 245-P.hal

Compiles.

## 250-BITS.hal

Fails at `HEX` in `IF B = HEX'00' THEN DO;`. That's because the proprocessor didn't mangle type `BIT(...)` as a boolean, which I've now fixed it to do.

Compiles now.

## 253-TEST0.hal

Compiles now.

## 254-TEST1.hal and 254-TEST2.hal

Fails on

    E       .
    M    IF B  THEN
    S        #

This appears to be because the proprocess flattens this as `IF b_B$# THEN ...` rather than as `IF b_B$(#) THEN ...`.  Fixed that.

Compiles now.

## 255-TEST3.hal

    Error: 9,22: syntax error at HEX
     WRITE(6) CHARACTER$(@HEX) (b_B);
                          ^
The grammar lacked a rule like `<QUALIFIER> ::= $ ( @ <RADIX> ) ;` that would have allowed the syntax above.  Fixed it.

Compiles now.

## 257-TEST4.hal

Fixed three transcription typos.

    Error: 4,42: syntax error at b_DATA
     b_AVERAGE = BIT$(5 AT #-4) (SUM(INTEGER([b_DATA]$(*:1 TO 5) )) / 3) || ... ;
                                              ^
This is because while I added constructs like `[ <ARITH VAR> ]` to the grammar, I didn't do so for `<BIT VAR>`.  Fixed that.

The error then becomes:

    Error: 4,116: syntax error at )
     b_AVERAGE = BIT$(5 AT #-4) (SUM(INTEGER([b_DATA]$(*:1 TO 5) )) / 3) || BIT$(5 AT #-4) (SUM(INTEGER([b_DATA]$(*:5 AT) $6 )) ... ;
                                                                                                                        ^
This is because the preprocessor hasn't flattened the multiline E/M/S correctly.  Here's the original:

    E       .                                .                                               .
    M    AVERAGE = BIT        (SUM(INTEGER([DATA]        )) / 3) || BIT        (SUM(INTEGER([DATA]
    S                 5 AT #-4                   *:1 TO 5              5 AT #-4                   *:5 AT
    
    E                                          .                       .            .          .
    M     )) / 3) || BIT        (SUM(INTEGER([DATA]         )) / 3) || DATA     AND DATA     & DATA     ;
    S    6              5 AT #-4                   *:5 AT 11               1:16         2:16       3:16

What should have been `$(*:5 AT 6)` instead became the bogus `$(*:5 at) $6`.  Presumably the problem is that the preprocessor first flattens each group of E/M/S lines separately and then concatenates them, whereas what should be done is to concatenate the E lines, concatenate the M lines, concatenate the S lines, and *then* flatten.

This is really difficult to fix, since it's completely against the way the preprocessor is structured.  And is it even worth it, considering that the code is supposedly rarely input in E/M/S form? E/M/S is good for outputting a listing, not for code entry.  

I think I'm just going to let this one slide, and move the 6 at the beginning of the 2nd S line to the end of the first S line.  It's not as if the code sample is trying to demonstrate that this is a good way of entering code!  It's for demonstrating the value of operations on bit arrays.

With that understanding, it compiles now.

## 260-TEST5.hal and 260-TEST6.hal

The 260-TEST5.hal code sample lacks a forward declaration of the procedure `XTRA`, as well as any `STRUCTURE` statement for `IMU_DATA`.  I've added the former, and for that latter have added a compiler directive

    D INCLUDE TEMPLATE IMU_DATA

since the template is already in the template library from earlier compilation runs on code sample 260-TEST6.hal, in which it is defined.

However, the template included from this compiler directive is not mangled by the preprocessor, because it is mistaken for a compiler directive.  Fixed that, so it's mangled properly.  But now the compiler fails there:

    Error: 2,1: syntax error at STRUCTURE
     STRUCTURE s_IMU_DATA: 1 DELTA_V ARRAY(3) INTEGER DOUBLE, 1 ATTITUDE ARRAY(3) INTEGER, 1 b_STATUS BIT(16);
     ^
Apparently that's because the fixup to the `<COMPILATION>` rules I made earlier accidentally excluded `<STRUCTURE STMT>`, which had previously been allowed.  Fixed that.

The error now moves to:

    Error: 8,21: syntax error at (
     PITCH_ANGLE = SCALAR(s_BEST_IMU.ATTITUDE$1 );
                         ^
That's because I hadn't included `SCALAR` among the `<ARITH FUNC>` rules of the grammar in the way I had done with `INTEGER` and `CHARACTER`.  Fixed that.

The error now moves to:

    Error: 19,6: syntax error at TBD
     CALL TBD ASSIGN(BEST);
          ^
That's because there's no forward declaration of the procedure `TBD` in the code sample.  I've added it.

Compiles now.

## 262-TEST7.hal

Compiles.

## 264-TEST8.hal and 269-PROCESS_CONTROL.hal

Failure in 264-TEST8.hal:

    Error: 3,75: syntax error at PROCESS_CONTROL
     STRUCTURE s_TQE: 1 TIME SCALAR, 1 ACTION INTEGER, 1 AFFECTED_PROCESS NAME PROCESS_CONTROL-STRUCTURE, 1 NEXT NAME s_TQE-STRUCTURE;
                                                                               ^
I think the problem here is mangling.  Should there be special name mangling for `AFFECTED_PROCESS`?  Or should it be mangled as a structure?  Whatever ... the preprocessor does neither of those things; there's no mangling.

No!  The problem is that `PROCESS_CONTROL` isn't mangled to `s_PROCESS_CONTROL` for some reason, whereas `TQE` (the next field after that) *is* properly mangled as `s_TQE`.  Ah! `TQE` is mangled properly because that happens to be the name of the structure template as well:  `STRUCTURE TQE: ...`.  I wonder if that could be a problem too (but not *this* problem)?  Probably not, in any rational world, since it would require some nut to define a field of a structure template with the same name as the template, but *not* of a structure type; that would be pretty weird.  

Anyway, the presence of `NAME` is clearly confusing the preprocess enough that it doesn't notice the `-STRUCTURE` that's there also.

But no!  That's not it.  The problem is simply that the structure template `PROCESS_CONTROL` is undefined, so naturally it's not mangled.  It's actually defined in the code sample on page 269 ... which I hadn't bothered to transcribe because I thought it was pointless.  And similarly for the code samples on subsequent pages.  Sigh!  Anyway, I'm transcribing them now.

269-PROCESS_CONTROL.hal compiles fine, and I've added a compiler directive 

    D INCLUDE TEMPLATE PROCESS_CONTROL

in 264-TEST8.hal.  And 264-TEST8.hal now compiles.

## 264-INITIALIZE.hal

Various compiler directives and `DECLARE`s missing, I assume because the assumption is that this file is really part of 264-TEST8.hal.  At any rate, once those things are include, compiles okay.

## 265-ENQUEUE.hal

Requires missing compiler directives

    D INCLUDE TEMPLATE PROCESS_CONTROL
    D INCLUDE TEMPLATE TQE

However, requires several additional undefined structure templates: `FREE_Q`, `ENT`, maybe others.

(To be continued.)

# 2022-12-16

While I haven't 100% completed pass 1 of the compiler, it's clear now that the preprocessor+compiler is working mostly, and that there aren't likely to be any unstoppable barriers to completing it.  But I'm bored with it, so I'm going to shift focus for a while.

What I'm going to do is to turn the preprocessor+compiler into an interpreter.  I'll create two Python modules for the preprocessor.  One of those modules will generate p-code from the AST.  The other will execute sequences of p-code.  The preprocessor itself will have the 