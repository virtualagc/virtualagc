***Important note:***  This folder contains my original development for HAL_S_FC.py, a Python 3 port of PASS1 of HAL/S-FC, the Intermetrics compiler for the HAL/S language.  But neither the port itself, nor the stream-of-consciousness notes in this README are really very suited for easy dissemination.  Refer to the HALSFC/ folder instead for the production/distribution version of this software.

# Table of Contents

  * [Introduction](#Introduction)
  * [Some Bookkeeping Details](#Bookkeeping)
  * [EBCDIC vs ASCII vs UTF-8](#EBCDIC)
  * [Changes to Parameter Values Within Procedures](#Parameters)
  * [Persistence and Initialization of Local Variables Within Their Parent Procedures](#Persistence)
  * [Absence and Persistence of Parameters of Procedures](#Absence)
  * [Dynamic Memory Allocation: BASED and its Macros](#BASED)
  * [PASS vs BFS Conditionals](#PASSvBFS)
  * [TIME, DATE, and other XPL Built-In Functions](#Builtins)
  * [Semicolons](#Semicolons)
  * [Partitioned Data Sets (PDS)](#PDS)
  * [Equivalence of Arrays and Non-Arrays](#Equivalence)
  * [More Conditional Code in XPL](#Conditionals)
  * [The Vocabulary, States, and Tokens](#Vocabulary)
    * [Background](#Background)
    * [VOCAB, VOCAB_INDEX, and V_INDEX](#VOCAB)
    * [Digression: BNF Rules for Nonterminals, and "Productions"](#BNF)
    * [STATE_NAME](#STATE_NAME)
    * [#PRODUCE_NAME (Ported as pPRODUCE_NAME)](#PRODUCE_NAME)
    * [READ1 and READ2](#READx)
    * [LOOK1 and LOOK2](#LOOKx)
    * [APPLY1 and APPLY2](#APPLYx)
    * [INDEX1 and INDEX2](#INDEXx)
    * [CHARTYPE](#CHARTYPE)
    * [TX](#TX)
    * [LETTER_OR_DIGIT](#LETTER_OR_DIGIT)
    * [SET_CONTEXT](#SET_CONTEXT)
    * [SPACE_FLAGS, TOKEN_FLAGS, and LAST_SPACE](#SPACE_FLAGS)
    * [Literal Data](#Literal)
    * [Compatible Datatypes, Automatic Conversions](#Autoconvert)
  * [The Boolean Conditional Trap of Death!](#Death)
  * [LINE_COUNT](#LINE_COUNT)
  * [Value of Loop Counter After a For-Loop](#ForLoop)
  * [Virtual Memory](#VirtualMemory)
    * [Virtual Memory Modules](#Modules)
    * [Virtual Memory Framework](#Framework)
    * [Virtual Memory User Guide](#VUser)
  * [Sample HAL/S Source Code](#Samples)
  * [FINDER(), MONITOR(8), D INCLUDE, and Related Puzzles](#FINDER)
  * [Version Management for the Template Library](#TemplateVersioning)
  * [OPTIONS_CODE](#OPTIONS_CODE)
  * [Compile-Time Computation of "Built-In" Functions](#Computation)
  * [Some Features Not Supported in the Original Compiler](#NotSupported)
  * [Roster of Remaining Problems with the Port](#Problems)
  * [Optimizing Sub-Passes](#Optimizing)

# <a name="Introduction"></a>Introduction

My plan for this folder (ported/) is to port a portion of the original Intermetrics HAL/S-FC compiler from its XPL language form to the Python 3 language.

This port will be of just the original compiler's PASS1 and PASS2, and the optimizing passes OPT, FLO, and AUX between pass 1 and pass 2.  PASS1 parses HAL/S source code and produces output in the form of the HALMAT intermediate language.  PASS2 produces executable object code for either the IBM 360 or for the GPC.  Since only 20% of HALMAT's documentation has survived over the intervening decades, HALMAT has been rendered basically unusable.  PASS 3 and PASS 4 of the compiler are not intended to be ported at the present time, since they relate to simulations for which none of the supporting software is believed to have survived.

This README is primarily about PASS1, though issues in porting PASS2 are essentially the same.  The intention is for the port to be very direct, without any "reimaginings" to make the compiler better or more efficient.  The idea is that if the XPL and the Python versions of the compiler source code were placed side-by-side, then a competent auditor should be able to easily determine that the port was correct, at least superficially.

As far as this "README" is concerned, some involves factual background material or else descriptions of implementation decisions I've made in the course of this porting effort.  But it has turned out that quite a lot of this README is devoted to what may be called "inferences and mysteries": i.e., to trying to puzzle out details about how the Intermetrics "enhancements" to XPL may have functioned or to how the original XPL code of the HAL/S compiler worked.  Obviously, that's a work in progress and subject to my own temporary or permanent misunderstanding.

> **Aside**:  Since the object of the HAL/S compiler that is being ported from XPL to Python is to process HAL/S source code, and since &mdash; superficially! &mdash; XPL and HAL/S seem rather similar, it's easy to become confused when thinking about these issues or reading my descriptions of them to think statements being made about XPL are really about HAL/S or vice-versa.  Don't fall into that trap!
> 
> An example is integer datatypes.  XPL has integer datatypes of `FIXED` (32-bit), `BIT(16)` (16-bit), `BIT(8)` (8-bit), and `BIT(1)` (1-bit), the latter of which doubles as a boolean datatype.  The only integer datatype in HAL/S, on the other hand, is `INTEGER`.  But to confuse the matter, HAL/S also has `BIT(n)` datatypes (where `n` is a positive integer).  However, in HAL/S `BIT(n)` is an array of `n` booleans and can only be considered as an integer with quite a bit of imagination; `BIT(n)` isn't *used* as an integer.  And whereas the HAL/S documentation *speaks* of a `FIXED` datatype, it is *not supported* by the Intermetrics HAL/S compiler, and rather than being an integer would be a fixed-point datatype rather than an integer type.

**Note:**  I discovered belatedly, after the vast majority of this README was written, that Section 13 of document IR-182-1 ("HAL/S-FC & HAL/S-360 Compiler Program Description") covers differences between standard XPL and the Intermetrics version of XPL.  Very few of the issues puzzed about in this README are covered there, and where there is overlap, I have not necessarily bothered subsequently to alter my sometimes-pithy musings.

# <a name="Bookkeeping"></a>Some Bookkeeping Details

File hierarchy and file naming:  The *original* hierarchy of XPL modules looked like so:

  * ...
  * HALINCL/
  * PASS1.PROCS/
  * PASS2.PROCS/
  * PASS3.PROCS/
  * ...

The port of the compiler duplicates this hierarchy, placing it under yaShuttle/ported/ in the source tree, with some provisos:

  * Folders and files not yet needed won't necessarily appear in the new file hierarchy.
  * If the "main program" in any given folder is named "##DRIVER.xpl", then its ported version is renamed "HAL_S_FC.py".  Besides that, though, these ##DRIVER.xpl files tend to be filled with many DECLARE statements defining constants or variables intended to be globally accessible.  Those global declarations are removed from HAL_S_FC.py and placed instead in a extra file called g.py, with one such file for each separae ##DRIVER.xpl.
  * Otherwise, the original filenames are retained except that the filename extension ".xpl" is replaced by ".py".

Besides these ported files, the XPL language also has a variety of built-in functions which are always available but not represented by any of the compiler's XPL source code.  These built-ins are implemented in a file called xplBuiltins.xpl, which resides in the parent folder that contains all of the file hierarchy just mentioned.

The ##DRIVER.xpl/HAL_S_FC.py files just mentioned represent "main programs" (vs merely modules used in programs):

  * PASS1.PROCS/ &mdash; PASS 1 of the compiler
  * OPT.PROCS/ &mdash; The original HALMAT optimizer ("phase 1.5" of the compiler)
  * AUX_PROCS/ &mdash; An additional optimization program added later.
  * FLO.PROCS/ &mdash; An additional optimization program added later.
  * PASS2.PROCS/ &mdash; PASS 2 (object-code generation) of the compiler
  * PASS3.PROCS/ &mdash; PASS 3 of the compiler
  * PASS4.PROCS/ &mdash; PASS 4 of the compiler

Whereas HALINCL/ merely contains modules imported by some of these nominally standalone programs.  The standalone programs were originally invoked by a separate assembly-language program, MONITOR.  I may or may not create corresponding scripts MONITOR.bat (batch file for Windows) and MONITOR (BASH shell script for Linux/Mac OS).

Python likes to import modules only from the base folder &mdash; i.e., the folder containing the top-level Python program being executed &mdash; or from its subfolders, and not from folders with other relationships to the base folder. Consequently, the first actions of any of the HAL_S_FC.py files are to:

  * Copy xplBuiltins.py
  * Copy HALINCL/

This allows each of the standalone programs ##DRIVER.xpl/HAL_S_FC.py to have its own private copies of xplBuiltins.xpl and HALINCL/*.xpl, while at the same time insuring that each copy uses identical source code.

In most of the ported compiler files you can find lines like the following:
<pre>
    from xplBuiltins import * 
    import g
</pre>
These are often supplemented by:
</pre>
    import HALINCL.COMMON as h
    import HALINCL.CERRDECL as d
    from ERROR import ERROR
</pre>
Built-in functions (and in the above common example, ERROR) are used without any name changes, whereas the global variables and constants from g.py have "`g.`" prefixed to their names.  For example, if you had a global function (say, `MONITOR`, defined in xplBuiltins.py) and a global variable (say, `CURRENT_CARD`, defined in g.py), you could access them as:
<pre>
    from xplBuiltins import *
    import g
    ...
    MONITOR(...)
    ...
    g.CURRENT_CARD = ...
</pre>
It's important *not* to import g.py with `from g import *`, because assignments to variables defined in g.py won't change the values of those variables in other files importing g.py if they're not in the `g.` namespace.  However, assignments in the `g.` namespace do affect all files that import g.py.  Other commonly used namespaces for global variables and constants (as in the example above) are "d." and "h.".

In addition to the usual alphanumeric and underline characters, identifiers in XPL can include the characters '@', '#', and '$', which are not allowed in Python identifiers.  However, it so happens that all of the original HAL/S-FC source code contained only upper-case characters when alphabetic.  Therefore, I use the uniform system of replacing disallowed characters in identifiers by lower-case alphabetic characters as follows:

  * '@' -> 'a'
  * '#' -> 'p'
  * '$' -> 'd'

For example, the global variable `MAXR#` becomes `g.MAXRp`.  But that's a worst case.  Any local variables not containing these funny characters would simply retain the same names in Python as they originally had in XML.

# <a name="EBCDIC"></a>EBCDIC vs ASCII vs UTF-8

All PASS and BFS HAL/S source code, to my belief, was originally character-encoded using EBCDIC.  Before any of this HAL/S source code ever reached me &mdash; well, as I write this, *none* of it has yet reached me &mdash; somebody recoded it in UTF-8.  Actually, except for two special characters, "¬" and "¢", it is all 7-bit ASCII.  This hybrid existence is troublesome, so I have adopted the following conventions for external storage of the source code vs internal storage in the compiler:

  * All HAL/S source code is nominally 7-bit ASCII.  If the UTF-8 characters logical-not (¬) and cent (¢) are found, they are transparently converted to tilde (&#126;) and backtick (&#96;) respectively.  Carat (^), which should never be present, is also transparently converted to tilde.  Put a different way, ¬ &#126; ^ are now all equivalent, but &#126; is the preferred form used internally; similarly, ¢ &#96; are equivalent but &#96; is the preferred form used internally.
  * All TAB characters are transparently expanded as if there were tab stops every 8 columns.

However, the original XPL form of the compiler *relied* upon the storage format being EBCDIC, because in processing (such as tokenization) it used the byte-codes of the characters, and it expected those byte codes to be EBCDIC.  Therefore, my approach is simply to make sure that any processing which converts between characters and byte codes, or vice-versa, correctly translates between ASCII and EBCDIC.  The pre-existing conversion function that the compiler originally used for taking a character and converting it to a byte code is the built-in `BYTE()` function of XPL.  In our recreation of that built-in `BYTE()` function, therefore, I've contrived for it to transparently convert between ASCII and EBCDIC as needed.  For example, `BYTE('a')` returns 0x81 (the EBCDIC code for 'a') rather than 0x61 (the ASCII code for 'a').  Similarly, a usage like `BYTE(s, 2, b)` that replaces the string character `s[2]` by the character with byte-value `b`, expects `b` to be an EBCDIC code.  For example `BYTE('hello', 2, 0x81)` returns `'healo'`.


# <a name="Parameters"></a>Changes to Parameter Values Within Procedures

XPL documentation explicitly states [McKeeman section 6.14]:

> All parameters are called by value in XPL, hence assignments to the corresponding formal perameter with the procedure definition have no effect outside the procedure.  To pass values out of a procedure, one must either use the <return statement> or make an assignment to a global variable.

Alas, the creators of XPL didn't reckon with the ability of the Shuttle's coders to exploit undocumented holes (or perhaps deliberate divergence from the definition of XPL) in the XPL compiler.  Formal parameters which are strings are apparently passed by reference in the Intermetrics/United Space Alliance version of the XPL compiler, and the source code for HAL/S-FC exploits this by allowing strings passed by formal parameters into a procedure to be altered by the procedure, and for those changes to be visible by the calling code.  An example is the PASS1.PROCS/PRINT2 module, which alters its formal string parameter `LINE`.

In fact, most (or all) calls to `PRINT2` pass `LINE` parameters that are string expressions or literals, rather than strings stored in variables, so the adjustments to `LINE` made by `PRINT2` are *not* changing strings stored in variables, but rather changing strings that had better not be changed.

But see also the next two sections.

# <a name="Persistence"></a>Persistence and Initialization of Local Variables Within Their Parent Procedures

It appears to me (undocumented!) that local variables in XPL procedures are not initialized at all, unless they have `INITIAL` clauses in their `DECLARE` statements.  *Moreover*, if such initialization occurs, it only does so at program start (or more reasonably, upon the first call to the procedure).

The upshot of this is that local variables within procedures *retain their values* between calls to the procedures.  There's no magical way to do this easily in Python (like the `static` clause in C), so we have to resort to a bit of trickery.

The particular trickery I use is to associate each ported XPL procedure with a class whose sole function is to hold the procedure's local variables and to initialize them.  The class has the same name as the associated function, except with the prefix "`c`".  There's a single instance of each such class, with a name the same as the function, except having the prefix "`l`".  For example, consider the following XPL procedure:
<pre> 
MYFUNC: PROCEDURE;
    DECLARE I FIXED INITIAL(5);    
    DECLARE S CHARACTER;
    ...
    S = STRING(I)
    ...
</pre>
It might translate into Python as follows:
<pre>
class cMYFUNC:
    def __init__(self):
        self.I = 5
        self.S = ''
lMYFUNC = cMYFUNC()
def MYFUNC():
    l = lMYFUNC     # A convenient namespace for locals
    ...
    l.S = STRING(l.I)
    ...
</pre>
Note that *every* variable in the Python port that comes directly from a variable in XPL will therefore have an associated namespace, usually "`l.`" for locals and "`g.`" for globals, although some globals may come elsewhere than from g.py, and may therefore sometimes have other namespaces than "`g.`".  For consistency, I typically try to use the following additional namespace conventions:
<pre>
import HALINCL.COMMON as h
import HALINCL.CERRORS as c
import HALINCL.CERRDECL as d
import HALINCL.DWNTABLE as t
</pre>
Moreover, it's not always possible to have "`l.`" as the namespace for variables local to a procedure, because parent namespaces are within scope as well.  What I mean is that if you have procedure definition embedded within a procedure definition, the outermost procedure will have "`l.`" as a local namespace, so the inner procedure can't use "`l.`" without losing access to its parent's local variables, and thus it might use "`ll.`" instead.  Similarly, if the embedded procedure also had an embedded procedure definition, the embedded procedure of the embedded procedure might use "`lll.`".  And so on.

The point, however, is that any variable &mdash; particularly since I tend to use camel case in my own variable names, any all-upper-case variable &mdash; unaccompanied by an explicit namespace had better be some variable I introduced for the purposes of the port, and not any variable being taken over essentially as-is from XPL.  Well ... there are some exceptions:  Variables immediately assigned a new value at the top of a procedure obviously don't need to be persistent, and if those are the only types of locals in a given procedure, there's no need for the class rigamarole described above.

# <a name="Absence"></a>Absence and Persistence of Parameters of Procedures

It further appears to me, as usual undocumented, that parameters of functions are expected to be persistent, in the sense that if parameters are omitted from function calls, they are expected to retain the values they had on prior calls to the procedure! 

An example is the `EMIT_SMRK` procedure, shown here in the entirety of its original XPL form:
<pre>
EMIT_SMRK:
   PROCEDURE (T);
      DECLARE T BIT(16) INITIAL(3);
      IF INLINE_LEVEL=0 THEN DO;
         CALL HALMAT_POP(XSMRK,1,XCO_N,STATEMENT_SEVERITY);
         CALL HALMAT_PIP(STMT_NUM, 0, SMRK_FLAG, T>1);
         IF HALMAT_RELOCATE_FLAG THEN CALL HALMAT_RELOCATE;
         ATOM#_FAULT=NEXT_ATOM#;
      END;
      ELSE IF T<5 THEN DO;
         CALL HALMAT_POP(XIMRK,1,XCO_N,STATEMENT_SEVERITY);
         CALL HALMAT_PIP(STMT_NUM, 0, SMRK_FLAG, T>1);
      END;
      STATEMENT_SEVERITY=0;
      IF SIMULATING THEN IF T=3 THEN CALL STAB_HDR;
      IF SRN_PRESENT THEN IF T THEN SRN_FLAG=TRUE;
      IF INLINE_STMT_RESET>0 THEN DO;
         STMT_NUM=INLINE_STMT_RESET;
         INLINE_STMT_RESET=0;
      END;
      ELSE IF T THEN STMT_NUM=STMT_NUM+1;
      T=3;
      SMRK_FLAG = 0;
   END EMIT_SMRK;
</pre>
If parameters aren't omittable in the way I infer, then the line `DECLARE T BIT(16) INITIAL(3);` makes no sense, since the `INITIAL(3)` would overwrite the value assigned by a `CALL EMIT_SMRK(x)` to the procedure.  But in fact, `EMIT_SMRK` is sometimes called with a parameter, and sometimes with no parameters, so presumably the idea is that the `INITIAL(3)` must have an effect only when the parameter `T` is omitted from the call.

But that can't be entirely true.  At the same time, near the bottom of the function we see the line `T=3;`, which also makes no sense if the parameters aren't persistent, since `T` is never used within the procedure after its final assignment, and can't have an effect outside of the procedure (if the bland assurances of the documentation are to be trusted).  No, the final assignment of `T` only makes sense if it's there to insure that `T` is returned to its default value prior the next call to the procedure.  But it also must mean that the initial value specified in `DECLARE T INITIAL(3)` is only the default for the *very first* call to the procedure, and isn't the default for subsequent calls!

Since `EMIT_SMRK` always returns with `T` having the same value as specified by its `INITIAL` clause, we could handle it in Python very simply just by defining the procedure as `def EMIT_SMRK(T=3): ...`.  But what about more-complex cases in which parameters don't end up with the same values they had upon entry?  Such cases can be handled within the persistent-local-variable framework described in the preceding section.  Let's discuss it using `EMIT_SMRK`, even though we've already agreed that `EMIT_SMRK` doesn't really need any special consideration.

Using the persistent-local-variable framework, our Python port of `EMIT_SMRK` might look something like the following:
<pre>
class cEMIT_SMRK: # Local variables *and* procedure parameters.
    def __init__(self):
        self.T = 3
lEMIT_SMRK = cEMIT_SMRK()

def EMIT_SMRK(T=None):
    l = lEMIT_SMRK
    if T != None:
        l.T = T
    # Hereafter, wherever T would appear in the XPL code, l.T is used in the Python code.
    ...
</pre>
Thus, the procedure parameter acts exactly like any other local variable, with the exception that its otherwise-persistent value can optionally be overridden by the value provide in the call to the procedure. 

If `T` had been declared *without* an `INITIAL` clause, we could just have used `self.T = None`.  That way, if the *first* call to `EMIT_SMRK` didn't include any value for the parameter `T`, there would likely be a runtime error, exactly as we'd desire.

# <a name="BASED"></a>Dynamic Memory Allocation: `BASED` and its Macros

I believe that constructs such as

<pre>
BASED MACRO_TEXTS RECORD DYNAMIC:
     MAC_TXT BIT(8),
END;
</pre>

would define a dynamically-allocated object in memory with the name "`MACRO_TEXTS`".  The records of this object have a fixed size, determined by whatever declarations appear within the `BASED ... END` block.  In this example, the records are each one byte long.

Space for the object is allocated using `ALLOCATE_SPACE(identifier, size)`.  I presume that `size` is the number of records.

Individual records can be accessed randomly by record index, such as `MACRO_TEXTS(n)`.  These records act like structures, so individual fields are accessed via dot-notation, as in

<pre>
MACRO_TEXTS(52).MAC_TXT = 69;
X = MACRO_TEXTS(25).MAC_TXT;
</pre>

These kinds of constructs are often accompanied by declarations like the following:

<pre>
DECLARE MACRO_TEXT(1) LITERALLY 'MACRO_TEXTS(%1%).MAC_TXT';
</pre>

I presume this declares a macro (called MACRO_TEXT) with a single argument, and that wherever `MACRO_TEXT(arg)` is encountered, it would be replaced by `MACRO_TEXTS(arg).MAC_TXT`, as in

<pre>
MACRO_TEXT(52) = 69;
X = MACRO_TEXT(25);
</pre>

To preserve the dotted notation, I implement `BASED ... END` blocks as arrays of Python class objects.  Unfortunately, this requires both a `class` name and a separate array name, so I use the lower-case form of the identifier as the `class` name:

<pre>
class macro_texts:
    def __init__(self):
        self.MAC_TXT = 0
</pre>

A function like `ALLOCATE_SPACE(MACRO_TEXTS, n)` would produce a python list like:

MACRO_TEXTS = [macro_texts(), macro_texts(), ...]

Meanwhile, I implement macros like `MACRO_TEXT(n)` as Python functions:

<pre>
def MACRO_TEXT(n, value=None):
    global MACRO_TEXTS
    if value == None:
        return MACRO_TEXTS[n].MAC_TXT
    MACRO_TEXTS[n].MAC_TXT = value
</pre>

This preserves syntax like `X = MACRO_TEXT(25)`, but XPL syntax like `MACRO_TEXT(52) = 69` has to be replaced by Python syntax like

<pre>
MACRO_TEXT(52, 69)
</pre>

# <a name="PASSvBFS"></a>PASS vs BFS Conditionals

It appears as though there must have been some parameter supplied to the compiler to determine whether compilation was for PASS (PFS) or whether it was for BFS, and there were conditionals that looked like this:
<pre>
/?P
    ... include whatever's in here if compiling for PASS ...
?/
/?B
    ... include whatever's in here if compiling for BFS ...
?/
</pre>

I handle this with CLI switch `--bfs`.  If used, then the internal variable `g.pfs=False`, but by default `g.pfs=True`.  These facts are used to create the conditional Python code corresponding to the conditional XPL code.

# <a name="Builtins"></a>TIME, DATE, and other XPL Built-In Functions

There are XPL "implicitly declared" functions and variables that are always available (see Table 6.9.1 in "A Compiler Generator").
To the extent needed, these are replaced by Python functions and variables of the same name.

However, some of these implicit "variables", such as `TIME` and `DATE`, are supposed to have different values every time they are accessed.  For example, `TIME` is the number of centiseconds elapsed since midnight (timezone unspecified).  I don't think there's any satisfactory way to implement this in Python while retaining the same syntax, so `TIME`, `DATE`, and presumably other such "variables", are instead implemented as Python functions:  in this case, `g.TIME()` and `g.DATE()`.

# <a name="Semicolons"></a>Semicolons

XPL requires semicolons at the ends of statements.  Python does not, but it *allows* semicolons to delimit multiple statements written on a single line, and thus is tolerant of them.  I didn't know that, and removed many in the porting process before discovering it.  The upshot is that I've tended to leave the semicolons in place, just because it's easier for me.  I may end up eventually removing them after all, simply because it's not really a Python thing to keep them, and indeed some Python lint/prettyprinter software annoyingly (if appropriately) goes out of its way to produce warnings upon finding them.  Since in our case there are 10's of thousands of such warnings, it's *very* irritating.

# <a name="PDS"></a>Partitioned Data Sets (PDS)

There seems to be a concept of three different types of files used by the compiler system, handled by different mechanisms:  "sequential files", "random access files", and "partitioned data sets" (PDS).  The former two are just what they sound like, and it's only the PDS that needs discussion.

A PDS apparently consists of member chunks, of variable sizes, with each chunk accessible via a unique member name that's exactly 8 characters long (padded with spaces if necessary).  This is a concept built into IBM's z/OS operating system.  Each such PDS must therefore have an associated index that can match member names with offsets into the PDS.  Chunks can be read, written, or replaced, and are presumably therefore capable of dynamic changes in size.

How IBM chose to implement the PDS concept is irrelevant to us, and I can implement it however I choose.  Because whatever concerns IBM originally had about execution speed and efficient disk storage are essentially meaningless 50+ years later, I can use whatever method I deem quickest in getting me to workable, maintainable code.  If you don't like it ... tough!

My choice is this:

  * While in use, each PDS is fully buffered in compiler memory, in the form of a Python dictionary.  The dictionary keys are the member names, and the values associated with the keys are whatever is convenient for the purpose of porting the specific PDS.
  * The storage of the PDS as a file is in the form of a JSON representation of the dictionary.

As far as reading from a PDS is concerned, the technique is first to find the member of the PDS you're interested in via `MONITOR(2,DEV,MEMBER)`.  You then read that member line-by-line using INPUT(DEV).  Evenually INPUT(DEV) returns an empty string to indicate the end of the member.

# <a name="Equivalence"></a>Equivalence of Arrays and Non-Arrays

XPL, as documented according to my understanding, has the basic datatypes of 32-bit integer (**FIXED**) and string (**CHARACTER**), as well as bit-arrays (**BIT**).  Besides which, you can have 1-dimensional arrays of these basic datatypes.

> Fun fact:  If you want, say, a 10-elmement array called `MYARRAY` of integers, you'd define it with the statement `DECLARE MYARRAY(9) FIXED;`.  Notice that you use a 9 rather than a 10.  You'll be particularly amused the 50th time you've had to correct the size of a declared array. I presume that what you're specifying here is not the size of the array, but the maximum subscript, which is one less than the size, since the indices start at 0.  I presume this feature was inherited from PL/I, in which you can declare both the starting and ending indices of an array, using a syntax like `DCL MYARRAY(0:9)`, which makes sense *in PL/I* because the starting index isn't always fixed at 0 the way it is in XPL. But I digress!

Another fun fact that isn't documented in XPL, but which may be an innovation by the XPL compiler-writers that the authors of XPL itself didn't intend, is that you can completely ignore the array bounds, using negative indices or positive indices greater than the declared maximum to just access whatever happens to be nearby in memory.  Not only that, but you can even ignore whether or not the variable was declared as an array or not!  Consider the following declarations:
<pre>
    DECLARE A FIXED;
    DECLARE B(5) FIXED;
</pre>
If you like, you can just use `B` in your code, without an index even though it's declared as an array, and it will automatically be interpreted as `B(0)`.  In this example, the XPL expression `B(-1)` would access `A`.  Or you can use `A` *with* an index even though it's not an array.  In this example, `A(1)` would access `B(0)`, `A[2]` would access `B(1)`, and so on. 

And make no mistake, whoever coded the HAL/S compiler in XPL *did* like to do this, though fortunately not too often.  Mostly just when you don't expect it and spend a while tearing your hair out trying to figure out what's going on.

A ghastly construction (or a fun one, depending on your perspective) relates to the following declarations
<pre>
   DECLARE N_DIM_LIM LITERALLY '3';
    ...
   DECLARE (TYPE,
      BIT_LENGTH,
      CHAR_LENGTH,
      MAT_LENGTH,
      VEC_LENGTH,
      ATTRIBUTES,
      ATTRIBUTES2,
      ATTR_MASK,
      STRUC_PTR,
      STRUC_DIM,
      CLASS,
      NONHAL,
      LOCK#,
      IC_PTR,
      IC_FND,
      N_DIM) FIXED,
      S_ARRAY(N_DIM_LIM) FIXED;
</pre>
found in the PASS 1 monitor module, `##DRIVER`.  The construction in question is
<pre>
    TYPE(TYPE)
</pre>
If `TYPE` has the value 0, then in array terms `TYPE(TYPE)` would refer to `TYPE` itself; i.e., `TYPE(TYPE)` would be 0.  Whereas if `TYPE==1`, then `TYPE(TYPE)` would be `BIT_LENGTH`.  If `TYPE==2`, then `TYPE(TYPE)` would be `CHAR_LENGTH`.  And so on, right up to `TYPE==19`, where `TYPE(TYPE)` corresponds to `S_ARRAY(3)`.  It's hard to deal with slapdash stuff such as this in a uniform way in Python.  In this case, I introduce a function I call `TYPEf()`, used solely as `TYPEf(TYPE)`.  Other absurdities involving `TYPE` and its kissing-cousin `FACTORED_TYPE` are handled using other methods.

*Finally*, I'd note that this "enhanced" XPL has a keyword, `ARRAY` which seems to be interchangeable with the keyword `DECLARE`.  If objects declared with `ARRAY` are distinguishable in any way from those declared with `DECLARE`, it isn't obvious to me.

# <a name="Conditionals"></a>More Conditional Code in XPL

I already discussed [PFS-specific vs BFS-specific conditional compilation](#PASSvBFS) above.  But there's more to it than just those cases.

In the XPL, you occasionally find code enclosed between an opening delimiter like "`/?X`" and a closing delimiter like "`?/`", where `X` represents one `A`, `B`, `C`, or `P`.  I interpret this as being conditionally-included code, and `X` as representing some particular condition for inclusion.

  * `/?A ... ?/` &mdash; TBD.  This is used only within the module HALINCL/SPACELIB, and the conditional code often (perhaps always) appears to relate to the printing of certain kinds of messages.  But I don't understand SPACELIB, so it's hard to be sure.
  * `/?B ... ?/` &mdash; For conditional code exclusive to the backup flight software.
  * `/?C ... ?/` &mdash; TBD.  This is used only within the `COMPACTIFY` procedure in the module HALINCL/SPACELIB, and the conditional code only appears to be the printing of certain messages possibly useful in debugging.
  * `/?P ... ?/` &mdash; For conditional code exclusive to the primary flight software.

Besides those, there seem to be the following constructs:
  * `/%INCLUDE module-name %/`
  * `/* $%module-name - function-name */`

I think that the former may indicate that source code from a particular module is supposed to be included, and that the latter may indicate that a particular external function resides in a particular module.  On the other hand, constructs like this appear only in the STREAM module, and in the particular uses there I don't find that they seem to have any obvservable effect.  In other words, my approach to them is simply to ignore them.

# <a name="Vocabulary"></a>The Vocabulary, States, and Tokens

## <a name="Background"></a>Background

If you attempt to understand the XPL code of the original compiler by starting at the beginning, you immediately run into very-confusing and seemingly-intractible details.  The "beginning" is the top-level file, the XPL module called "##DRIVER". (Though everything we discuss in *this* section is ported into our Python file g.py rather than into ##DRIVER.py).

The difficulty is that ##DRIVER (and consequently g.py) begin with declaration of a series of arrays relating to the behavior of the compiler as a state machine, and these arrays are incomprehensible to a greater or lesser degree because they are mostly large collections of hard-coded integers which are nowhere explained, and whose method of generation and interpretation are unknown.  So my intention here is to document whatever explanation I've been able to tease out of them by my own observations.  The arrays in question are:

  * `VOCAB`
  * `VOCAB_INDEX`
  * `V_INDEX`
  * `STATE_NAME`
  * `#PRODUCE_NAME` (ported as `pPRODUCE_NAME`)
  * `READ1`
  * `LOOK1`
  * `APPLY1`
  * `READ2`
  * `LOOK2`
  * `APPLY2`
  * `INDEX1`
  * `INDEX2`
  * `CHARTYPE`
  * `TX`
  * `LETTER_OR_DIGIT`
  * `SET_CONTEXT`

## <a name="VOCAB"></a>VOCAB, VOCAB_INDEX, and V_INDEX

The first array we encounter, `VOCAB` is the least-incomprehensible.  In the code it is an array of 12 long strings.  However, in principle, it could just as easily be presented as a single very-long string formed just by concatenating the 12 entries of the array.  The reason this is not done in the actual code is presumably that such a very-long string would exceed the apparent limit (255 characters) of XPL strings.

`VOCAB` consists of all of the symbols, reserved words, HAL/S BNF terminals, and HAL/S BNF nonterminals, concatenated.  I'll just call all of these "vocabulary strings".
<pre>
   DECLARE VOCAB(11) CHARACTER INITIAL ('.&lt;(+|&$*);...SCALARSIGNALSINGLESTATIC...&lt;MODIFIED STRUCT FUNC&gt;&lt;DOUBLY QUAL NAME HEAD&gt;');
</pre>

The next array we encounter is `VOCAB_INDEX`, which looks something like this:
<pre>
   ARRAY VOCAB_INDEX(NSY) FIXED INITIAL ( 0, 16777216, 16777472, ... , 352370187, 369152779, 385935627);
</pre>
Fortunately, it's possible with enough effort to figure out what these entries mean.  Each 32-bit integer entry consists of bit-fields, as follows:
  * D31-D24: Length in characters of the associated vocabulary string.
  * D23-D8: Offset into the particular entry of `VOCAB` specifying holding the vocabulary string.
  * D7-D0: Index (0-11) into the `VOCAB` array, giving the specific entry that holds the vocabulary string.

One of the first actions of the compiler, in ##DRIVER is to call the `INITIALIZE()` function, and one of the actions of the `INITIALIZE()` function is to use these entries in `VOCAB_INDEX` along with the concatenated strings in `VOCAB` to actually create a stand-alone string for each symbol, reserved word, or BNF nonterminal.  It then stores the pointers to those strings directly in `VOCAB_INDEX`, overwriting the confusing integer data initially stored there.

In other words, *after* calling `INITIALIZE()`, `VOCAB_INDEX` is no longer an array of integers but rather an array of strings, one for each symbol, reserved word, or BNF nonterminal.  This process immediately renders the original `VOCAB` array useless: it is never used again in the remainder of the compiler.  One can't help but wonder why the compiler source code didn't simply omit `VOCAB` entirely and declare `VOCAB_INDEX` directly as a list of strings?  Why all of this seemingly-pointless rigamarole?  

It is worth noting that `VOCAB_INDEX` contains 312 elements, but entry 0 is not used, so there are in fact 311 strings defined in it, numbered 1 through 311.

The vocabulary strings in `VOCAB_INDEX` appear to be ordered primarily by string length, and secondarily by the (EBCDIC) order of the leading character of the string.

For whatever reason, efficient binary searches or `VOCAB_INDEX` are not used, nor are inefficient linear searches.  Rather, a method of intermediate efficiency is used, via the `V_INDEX`: It indicates the range of strings in `VOCAB_INDEX` that are 1 character long, those that are 2 characters long, those that are 3 characters long, and so forth.  Here's what `V_INDEX` looks like, in full:
<pre>
     V_INDEX = (1, 20, 31, 45, 63, 76, 97, 110, 116, 126, 129, 130, 132, 134, 136, 137, 137, 140, 141, 142, 143)
</pre>
Thus strings 1-19 in `VOCAB_INDEX` are each a single character, strings 20-30 have two characters, strings 31-44 have three characters, and so on.  And there is one weird exception, namely `VOCAB_INDEX[76]='END_OF_FILE'`, which is the first string in the 3-character region.  Presumably that's because it was at some point `EOF`.

As noted above, string 0 is not used.  The values 1-142 are the potential values for the "tokens" that result from the tokenization of the source code.  Strings 143 and beyond are BNF nonterminals, and thus don't need to appear in `V_INDEX` because no searches are ever conducted for them during tokenizaton.  But BNF terminals do appear in the range 1-142.  For example, the BNF terminal `<IDENTIFIER>` can be recognized by the tokenizer with the regular expression \b[A-Z]([A-Z0-9_]*[A-Z0-9])?\b and doesn't require any other means of recognition. (I don't claim that the compiler uses regular expressions; it doesn't.)

Of the BNF nonterminals, there are precisely 169, so we'd expect there to be 142+169=311 vocabulary strings in `VOCAB_INDEX`, which as noted earlier, is the correct number.

## <a name="BNF"></a>Digression:  BNF Rules for Nonterminals, and "Productions"

The facts about the BNF rules for nonterminals that were mentioned in the preceding section can be deduced from a complete listing of the BNF nonterminals which appears in the comments at the beginning of the file ##DRIVER.xpl.  Each rule recognized by the HAL/S compiler developers &mdash; I daresay that this set of rules is not formally correct in a theoretical context, for a variety of reasons &mdash; is accompanied in those comments by a somewhat-unique identifying number called the "production number" (formally `PRODUCTION_NUMBER` in the SYNTHESI module).  Here's a partial listing:
<pre>
 /*      1   &lt;COMPILATION> ::= &lt;COMPILE LIST> _|_                     */

 /*      2   &lt;COMPILE LIST> ::= &lt;BLOCK DEFINITION>                    */
 /*      3                    | &lt;COMPILE LIST> &lt;BLOCK DEFINITION>     */

 /*      4   &lt;ARITH EXP> ::= &lt;TERM>                                   */
 /*      5                 | + &lt;TERM>                                 */
 /*      6                 | - &lt;TERM>                                 */
 /*      7                 | &lt;ARITH EXP> + &lt;TERM>                     */
 /*      8                 | &lt;ARITH EXP> - &lt;TERM>                     */
                            .
                            .
                            .
 /*    451   &lt;REPEAT> ::= , REPEAT                                    */

 /*    452   &lt;STOPPING> ::= &lt;WHILE KEY> &lt;ARITH EXP>                   */
 /*    453                | &lt;WHILE KEY> &lt;BIT EXP>                     */
</pre>
These production numbers come into effect when a some substring of the source code has been sufficiently identified by the compiler to generate HALMAT for it, and the precise type of HALMAT to be generated for it (*sans* things such as the precise variable names or numeric constants to be used) is the production number.

As you can see, there are precisely 453 types of productions.  I presently think there's no way to programmatically recover descriptive names of these productions, though descriptive names for all of them are in fact listed in comments of the SYNTHESI module source code.

## <a name="STATE_NAME"></a>STATE_NAME

The compiler's syntax analyzer, implemented by the modules STREAM and SCAN, is a state-machine, and in the course of determining that any given production of HALMAT needs to be produced, SCAN may pass through a number of intermediate states.  I believe that there are 810 (0 through `g.MAXPp`) possible states, though only the first 442 (0 through `g.MAXRp`) of them actualy have names, due to being meaningfully-related to specific BNF rules.

`STATE_NAME` seems to be primarily used for programmatic recovery of names of SCAN states for diagnostic messages, though there are some rare uses in the syntax analysis as well.  The state names are programmatically recoverable:
<pre>
    g.VOCAB_INDEX[g.STATE_NAME[state number]]
</pre>
The current state, I believe, is always given by `g.STATE`, and the pending states are kept in the `g.STATE_STACK[]` array, with `g.STATE_STACK[g.SP]` being the more-recent state pushed onto the stack.

The description above covers only states 0-441.  For the sake of completeness, here's the categorization of the full range of possible states:

  * 0 through 441 (`g.MAXRp`) &mdash; named states that can be associated with specific BNF rules.
  * 442 through 666 (`g.MAXLp`) &mdash; a "look-ahead" state.  In these states, we know the next token we need within the input stream, but we haven't yet found it.
  * 667 through 810 (`g.MAXPp`) &mdash; TBD
  * 811 through 1263 (`g.MAXPp+g.Pp`) &mdash; "production" states.  These are states temporarily entered into in order to generated HALMAT, thence to return to one of the named states.  (See `#PRODUCE_NAME` below.  The `PRODUCTION_NUMBER` is `g.STATE-g.MAXPp`.)

## <a name="PRODUCE_NAME"></a>#PRODUCE_NAME (Ported as pPRODUCE_NAME)

It appears to me that `#PRODUCE_NAME` returns a state number for any given production number.  (See above.)  In general, I think, any given state may give rise to several possible BNF productions, due the fact that any given BNF nonterminal rule may represent several different alternative rules.  For example, in the example given earlier, we saw that nonterminal &lt;ARITH EXP> (state 190) may give rise to production 4 (&lt;ARITH EXP> ::= &lt;TERM>), production 5 (&lt;ARITH EXP> ::= + &lt;TERM>), production 6 (&lt;ARITH EXP> ::= - &lt;TERM>), production 7 (&lt;ARITH EXP> ::= &lt;ARITH EXP> + &lt;TERM>), or production 8 (&lt;ARITH EXP> ::= &lt;ARITH EXP> - &lt;TERM>).  This we'd expect each of `pPRODUCE_NAME[5]` through `pPRODUCE_NAME[8]` to give us 190 ... which in fact it does.

Thus in spite of being called `pPRODUCE_NAME`, this array *cannot* in fact be used to get a descriptive name of the BNF rule associated with the production.  It can, of course, be used to recover the name of the associated nonterminal:
<pre>
g.VOCAB_INDEX[g.pPRODUCE_NAME[PRODUCTION_NUMBER]]
</pre>

## <a name="READx"></a>READ1 and READ2

The `READ1` and `READ2` arrays are the same size, and are organized in the same way.  Each consists of a sequence of blocks of variable size, and each block corresponds to information specific to one of the states (`g.STATE`) of the scanner state machine.  The blocks have corresponding positions and lengths in the the two arrays.  (See `INDEX1` and `INDEX2` below to understand how to locate the blocks in `READ1` and `READ2` that correspond to specific states.)

For any given state, `READ1` provides a list of the tokens which can legally be found next in the input stream in the given state.  For example, suppose the statement being parsed is "`DECLARE INTEGER INITIAL(1), A, B;`", and that the comma after `A` has just been parsed.  At this point, the scanning state machine will be in state `g.STATE==58`.  It will turn out (again, see `INDEX1` and `INDEX2`) that the block of entries in `READ1` consists just of `READ1[904]`, which happens to be the token 131 (`g.ID_TOKEN`).  Thus the only item we can legally encounter next in the input stream is an `<IDENTIFIER>`.

Meanwhile, `READ2` provides the next scanning state that we'll enter when the specific token found in `READ1` has been found in the input stream.  In the example from the preceding paragraph, for example, once token 131 (`READ1[904]`) has been identified in the input stream while we're in state 58, the next state we'll enter is `g.STATE=g.READ2[904]`, which happens to be 538.

## <a name="LOOKx"></a>LOOK1 and LOOK2

The `LOOK1` and `LOOK2` arrays are the same size as each other, and are organized in the same way.  Each consists of a sequence of blocks of variable size, and each block corresponds to information specific to one of the states (`g.STATE`) of the scanner state machine.  The blocks have corresponding positions and lengths in the the two arrays.  (See `INDEX1` and `INDEX2` below to understand how to locate the blocks in `LOOK1` and `LOOK2` that correspond to specific states.)

So far, the descriptions of `LOOK1`/`LOOK2` are entirely analogous to those of `READ1`/`READ2` in the preceding section.  One difference, though, is that blocks of tokens in `LOOK1` always terminate with the same illegal token-code (0), so there's never any need to explicitly know the lengths of these blocks.

The other difference is that `LOOK1` and `LOOK2` perform the same roles for "look-ahead" states (see the `STATE_NAMES` section above) that `READ1` and `READ2` do for "named" states.  Thus, `LOOK1` provides blocks of the allowed next input tokens for any given look-ahead state, while `LOOK2` provides the next state corresponding to those allowed tokens.

## <a name="APPLYx"></a>APPLY1 and APPLY2

TBD

## <a name="INDEXx"></a>INDEX1 and INDEX2

The `INDEX1` and `INDEX2` arrays provide a way to gain access to the information encoded in the `READ1`/`READ2` or `LOOK1`/`LOOK1` arrays (see above).  

The index in both the `INDEX1` and `INDEX2` arrays is a state number (via `g.STATE`, for example).  

If the state number is in the range 0 through 441 (`g.MAXRp`), then `INDEX1[state number]` provides the offset of the state within the `READ1`/`READ2` arrays, while `INDEX2[state number]` tells us the number of consecutive entries in the `READ1`/`READ2` arrays that are devoted to the state.

Similarly, if the state number is in the range 442 through 666 (`g.MAXLp`), then `INDEX1[state number]` provides the offset of the state within the `LOOK1`/`LOOK2` arrays, while `INDEX2[state number]` tells us the number of consecutive entries in the `LOOK1`/`LOOK2` arrays that are devoted to the state.

> **Aside:** `INDEX2` isn't actually *needed* (or indeed, used) for lookups in `LOOK1` and `LOOK2`, because it turns out that each block of tokens in `LOOK1` ends with a token equal to zero.  Hence it's not necessary to explictly know the lengths of blocks in `LOOK1`, but merely to continue searches until reaching a terminating 0.

For example, suppose that we are in the scanning state identified as `g.STATE==59`.  We find that `g.INDEX1[59]==939` and `g.INDEX2[59]==3`.  Therefore, only `READ1[939]`/`READ2[939]`, `READ1[940]`/`READ2[940]`, and `READ1[940]`/`READ2[940]` are all applicable to scanning state 59.

## <a name="CHARTYPE"></a>CHARTYPE

The `CHARTYPE` array has 256 entries, one for each possible EBCDIC characters (including even those that aren't in the legal HAL/S character set).  Given an EBCDIC character, it characterizes the type of character it is, in terms of 14 different classifications (0 through 13).  Those categories are:

  * 0 &mdash; illegal characters
  * 1 &mdash; digits
  * 2 &mdash; letters
  * 3 &mdash; special single characters
  * 4 &mdash; period (.)
  * 5 &mdash; single-quote (')
  * 6 &mdash; blank
  * 7 &mdash; vertical bar (|)
  * 8 &mdash; asterisk (*)
  * 9 &mdash; EOF (end of file)
  * 10 &mdash; special characters treated as blanks
  * 11 &mdash; double-quote (")
  * 12 &mdash; percent (%)
  * 13 &mdash; cent (¢)

There is no actual EOF character in EBCDIC, but the original HAL/S developers appropriated an otherwise-unused code (0xFE) for that purpose.  In our ported program, that code is not available in 7-bit ASCII, so a different code (0x04) is used instead.  However, this is all handled transparently by the built-in XPL `BYTE` function, which in all cases reports the same numerical code (0xFE) originally expected.

Similar comments apply to the special characters ¢ and ¬ as have already been discussed:  The `BYTE` function always returns the numerical code expected by the original XPL version of the compiler.

## <a name="TX"></a>TX

The `TX` array provides translations from EBCDIC character codes to token codes ... but only for those EBCDIC characters comprising an entire token by themselves.  All other characters (such as alphanumerics) will simply have an entry in `TX` of 0.  (Recall that 0 is not a legal identifying code for a token.)

For example, the period character is an entire token by itself, having a token code of 1 (since `VOCAB_INDEX[1]=='.'`).  However, considered as an EBCDIC character, a period is encoded numerically as 75 (decimal). Thus `TX[75]==1` is the translation from the EBCDIC code to the token code.  

Similarly, the less-than sign has a token code of 2 (`VOCAB_INDEX[2]=='&lt;'`), and the EBCDIC less-than sign is encoded numerically as 76 (decimal), so `TX[76]==2`.

## <a name="LETTER_OR_DIGIT"></a>LETTER_OR_DIGIT

The `LETTER_OR_DIGIT` array is a cruder form of the `CHARTYPE` array described earlier.  Like `CHARTYPE`, it has 256 entries, one for each possible EBCDIC characters (including even those that aren't in the legal HAL/S character set).  The array has an entry of 1 (`g.TRUE`) wherever the character is alphanumeric, and 0 (`g.FALSE`) where it is not.  For example,
<pre>
    g.LETTER_OR_DIGIT(BYTE('M')) == 1
    g.LETTER_OR_DIGIT(BYTE('7')) == 1
    g.LETTER_OR_DIGIT(BYTE('=')) == 0
</pre>
Note that:
<pre>
    g.LETTER_OR_DIGIT(BYTE('_')) == 1
</pre>
Thus there are 26+26+10+1=63 entries altogether that are `g.TRUE`.

## <a name="SET_CONTEXT"></a>SET_CONTEXT

> **Aside**: The process of scanning and tokenizing the HAL/S source code is not context-free, which is one reason why the BNF formalism &mdash; which in principle describes context-free grammars &mdash; is not an adequate description of HAL/S grammar.  

In principle, here are 12 possible contexts recognized by the compiler, any one of which may be in effect at any given point in the analysis of the HAL/S source code.  The context affects how the analysis proceeds.  These contexts are identified by number, 0 through 11, and the current context is given by the global variable `g.CONTEXT`.  Sometimes these contexts have symbolic names, used in place of hard-coded numerical identification.  Here's what I've been able to learn about them so far:

  * -1 &mdash; *presumably*, "not yet assigned"
  * 0 &mdash; "ordinary"
  * `EXPRESSION_CONTEXT = 1`
  * 2 &mdash; "GO TO"
  * 3 &mdash; "CALL"
  * 4 &mdash; "SCHEDULE"
  * `DECLARE_CONTEXT = 5`
  * `PARM_CONTEXT = 6`
  * `ASSIGN_CONTEXT = 7`
  * `REPL_CONTEXT = 8`
  * 9 &mdash; "CLOSE"
  * `REPLACE_PARM_CONTEXT = 10`
  * `EQUATE_CONTEXT = 11`

For example, upon encountering an &lt;IDENTIFIER> (say, "MYVAR"), the compiler will react differently in the "DECLARE" context than in the "EXPRESSION" context.

The array `SET_CONTEXT` has an entry for each possible token &mdash; i.e., it has entries `SET_CONTEXT[1]` through `SET_CONTEXT[142]`, with `SET_CONTEXT[0]` being unused, and appears to provide a context for each of these tokens.  For example, if `g.TOKEN` is 25 (`g.VOCAB_INDEX[25] == 'GO'`), we find that `g.SET_CONTEXT[25] == 2` ("GO TO").

## <a name="SPACE_FLAGS"></a>SPACE_FLAGS, TOKEN_FLAGS, and LAST_SPACE

Herein I try to figure out how spacing in lines of source code printed by the `OUTPUT_WRITER` module works, because it's not always working for me.

Tokens are printed out one by one by the `OUTPUT_WRITER` module, with the function `ATTACH` figuring out the spacing between the tokens.  The current token in a `CALL ATTACH(PNTR)` is indicated by `PNTR`, with `STATE_STACK[PNTR]` being the token itself, `SAVE_BCD[PNTR]` being the text of the token (if it's something like an identifier or a literal that has a variable textual value), and `TOKEN_FLAGS[PNTR]` representing ... well, some flags associated with the specific instance of the token.  (As opposed to `GRAMMAR_FLAGS[]`, which would give flags generically associated with the token type rather than the specific instance of the token.)

Each type of token has both a possible "pre-spacing" and a possible "post-spacing" for printing.  The post-spacing is computed by `ATTACH` and temporarily stored in a global variable called `LAST_SPACE` for use during the *next* call to `ATTACH`.  So when a call to `ATTACH` is made for a given token, `ATTACH` determines what the pre-spacing for the token should be *sans* `LAST_SPACE`, then combines that computed pre-spacing with `LAST_SPACE` in some manner to obtain the spacing it actually uses in front of the token.

The theoretical pre-spacing *sans* `LAST_SPACE` comes from a global array of constants called `SPACE_FLAGS`, which has an entry for each token type.  (Actually, it's more complex than that:  entry 0 is unused, entries 1-142 are the flags for tokens appearing on the M-line, and entries 143-244 are the flags for the tokens appearing on the S- or E-lines.)

Each 8-bit entry in `SPACE_FLAGS` encodes two separate 4-bit values.  The high-order nibble is the theoretical pre-spacing, while the low-order nibble is the theoretical post-spacing.  The *documentation* describes the nibble values as:

 0. "Always wants a space, if not overridden by the other token."
 1. "Only wants a space if the "other token" wants one too."
 2. "Never wants a space."
 3. "Always gets a space."

(**Note:** The list above should be numbered 0, 1, 2, 3; but I found out belatedly that not all markdown implementations support that numbering, so it may appear *incorrectly* to be numbered as 1, 2, 3, 4.)

In point of fact, though, if you examine the values in `SPACE_FLAGS`, we find that the nibbles are always 0, 1, 2, or 5.  There are no 3's.  It appears to me as though the 5's may originally have been 3's, but were replaced when somebody noticed that it would enable processing the pairwise cases by simple arithmetic rather than by complicated lookups or DO CASE statements.  Well, it's a working hypothesis.

The `TOKEN_FLAGS` array contains 16-bit values with, as I said, each entry corresponding to a token in the current line.  Each entry is parsed into bit-fields, as follows:

  * Bits 4-0 is a token type.
  * Bit 5 is a "no space" flag.  (This is the only field relevant to the present discussion.)
  * Bits 16-6 is an index into the `SAVE_BCD` array, giving the text of the token.

`ATTACH` computes the post-spacing to be stored in `LAST_SPACE` and passed along to the *next* call to `ATTACH` by using 2 (never wants a space) if the "no space" flag is set in the token's entry in `TOKEN_FLAGS`, but otherwise just uses the post-spacing field from the entry in `SPACE_FLAGS`.

Pre-spacing is trickier.  `ATTACH` performs the pre-spacing computation (which it stores in a local variable called `SPACE_NEEDED`, which gives the actual number of spaces to add, like so:

  * Defaults to 0 for the first token in the line, and to 1 for the succeding tokens.
  * However, it may be changed to 0 under several conditions:
       * If the preceding token was the name of a macro having no parameter list.
       * If the theoretical pre-spacing code (from `SPACE_FLAGS`), *added* to `LAST_SPACE` (the post-spacing code of the preceding token), has a value of 2, 3, or 4.

It's the final calculation that's tricky to understand, so let's go through it in detail in terms of the values for both the preceding and current tokens, on the assumption about the meaning of pre- or post-spacing codes of 5 that I advanced above.  I've bolded the ones that change `SPACE_NEEDED` to 0: 
  
  * preceding conditionally wants, current conditionally wants:  0 + 0 = 0
  * preceding conditionally wants, current conditionally doesn't want:  0 + 1 = 1
  * **preceding conditionally wants, current never wants:  0 + 2 = 2**
  * preceding conditionally wants, current always gets:  0 + 5 = 5 
  * preceding conditionally doesn't want, current conditionally wants:  1 + 0 = 1
  * **preceding conditionally doesn't want, current conditionally doesn't want:  1 + 1 = 2**
  * **preceding conditionally doesn't want, current never wants:  1 + 2 = 3**
  * preceding conditionally doesn't want, current always gets:  1 + 5 = 6
  * **preceding never wants, current conditionally wants:  2 + 0 = 2**
  * **preceding never wants, current conditionally doesn't want:  2 + 1 = 3**
  * **preceding never wants, current never wants:  2 + 2 = 4**
  * preceding never wants, current always gets:  2 + 5 = 7
  * preceding always gets, current conditionally wants:  5 + 0 = 5
  * preceding always gets, current conditionally doesn't want:  5 + 1 = 6
  * preceding always gets, current never wants:  5 + 2 = 7
  * preceding always gets, current always gets:  5 + 5 = 10

Some of these are debatable, I suppose, but they generally make sense according to my expectations as to where spaces would be inserted.

## <a name="Literal"></a>Literal Data

Literal data and some(?) constant data is passed from one compiler phase to the next via an external file, some of which is paged into memory at any given time.  Naively, this sounds like an insignificant fact, given that we implement only Phase 1 of the compiler.  But in fact, it's very important, because Phase 1 not only writes out data to this memory buffer and file, but also reads it back.  And without the ability to read back the literal data, the compiler cannot function.

By literal data, I am referring to the numbers (and bit values and character strings) used in ways like the following:
<pre>
    DECLARE A INTEGER CONSTANT(5), C CHARACTER(19) CONSTANT("HELLO"), B BIT(1) CONSTANT(TRUE), V VECTOR(A), S SCALAR;
    S = 2 7 + 6;
</pre>
The values 5, "HELLO", `TRUE`, 2, 7, and 6 (or at least some of them) must be known at compile-time, because the compiler will try to use 2, 7, and 6 to compute the value of `S` at compile time (rather than run time), and it will need the (constant) value of `A` in order to allocate space for vector `V` at compile time.

The compiler deals with these constants by dumping them out into the literal file or its associated memory buffer as soon as it finds out about them, and then forgetting them in all other respects.  So when it later has to perform the compile-time calculations or allocations just mentioned, it has to read all of those values back from the literal table.

In the original XPL version of the compiler, this worked conceptually (but not in detail) as follows:  There were 3 arrays, each of 32-bit integers, called `LIT1`, `LIT2`, and `LIT3`.  For each literal, there was an entry in each of these 3 arrays.  The `LIT1` array gave the *type* of the literal:  Either character-string (0), numerical (1), or bit (2).

For character-string literals, `LIT3` was ignored, but `LIT2` encoded the length of the string (minus 1) as the bits 31-24, and a pointer to the string as bits 23-0.  Obviously, therefore, literal character strings are between 1 and 256 bytes in length.  The 24-bit pointer was an offset into yet a 4th array, which was a byte-array called `LIT_CHAR`.  `LIT_CHAR` simply holds all of the literal character-strings, concatenated.

Supposedly `LIT_CHAR` has a maximum size, which according to some of the documentation is given by the variable `LITCHARS`, which is in turn set by a compiler option.  Other of the documentation would lead us to believe that the size of `LIT_CHAR` is instead limited by the compiler option `LITSTRINGS`, which defaults to 2500.  Neither claim has any obvious connection to the XPL code that I can detect.  So I suspect that the fixed size of `LIT_CHAR` and the use of the `LITSTRINGS` or `LITCHARS` option to allocate it, has something to do with the operating system and that the sizing is effected by the JCL rather than by anything we can see in the compiler source code.  Thus none of that sizing nonsense seems to have any relevance beyond the System/360 environment, and we can just ignore it. So for us, `LIT_CHAR` can be any size we like, with no fixed limit.  It's unclear why 24-bit addresses would be needed for an array that only contains 2500 bytes.

For numerical literals, IBM double-precision floating-point format was used.  `LIT1` held the more-significant 32-bit portion (which is an IBM single-precision floating-point value, though not necessarily with the same rounding in the least-significant bit that you'd get by converting a double-precision value to a single-precision value) and `LIT2` held the less-significan 32-bit portion..

The IBM documentation I've seen for System/360 floating-point numbers is pretty opaque.  Fortunately, wikipedia explains it                 very simply.  Here are the bits of a single-precision number:
<pre>
S EEEEEEE FFFFFFFF FFFFFFFF FFFFFFFF
</pre>
S is the sign, E is the exponent, and F is the fraction.  The exponent is a power of 16, biased by 64, and thus represents                 16<sup>-64</sup> through 16<sup>+63</sup>. The fraction is an unsigned number, of which the leftmost bit represents 1/2, the next bit represents 1/4, and so on.  Double-precision is the same, except that there are 32 additional bits in 4 extra `FFFFFFFF` groups.

For bit literals, `LIT2` was a 32-bit pattern giving the actual data bits.  Thus for a `BIT(1)` literal, only one bit was used, for a `BIT(2)` literal, two bits were used, and so on.  `LIT3` have the number of bits; i.e., 1 for `BIT(1)`, 2 for `BIT(2)`, etc.  The documentation does not explain the packing of this data within `LIT1` and `LIT2`; my assumption is that they were packed to the right.

As I mentioned above, this discription is conceptual but is not correct in detail.  The point which is incorrect is in treating each of `LIT1`, `LIT2`, and `LIT3` as arrays.  In fact, apparently due to the need or perceived need to page this data into memory from an external file, these 3 conceptual arrays were packed into an array of pages, `LIT_PG`, according to the following scheme:
<pre>
COMMON   BASED LIT_PG RECORD DYNAMIC:
         LITERAL1(129)               FIXED,
         LITERAL2(129)               FIXED,
         LITERAL3(129)               FIXED,
END;
</pre>
In other words `LIT_PG(0)` contained the entries 0-129 of `LIT1`, `LIT1`, and `LIT3`, while `LIT_PG(1)` contained entries 130-259, and so on.

I've chosen to preserve this arrangement, which we don't need in any memory-conservation sense and don't really like in terms of maintainability, because it helps us to more-easily preserve the external file format used in the literal file.

## <a name="Autoconvert"></a>Compatible Datatypes, Automatic Conversions

IR-182-1 describes (sort of; see p. 352) how to determine data type compatibility &mdash; i.e., which data types on the right-hand side of an assignment can be auto-converted to which data types on the left-hand side &mdash; in terms of various quantities with names like `ASSIGN_xxx`.  While it's true that some quantities with names of that pattern still exist in the compiler's source code, any connection to the description in IR-182-1 (or vice-versa) is long gone.  Presumably the framework was pretty-substantially reworked at some point.  Nor is there much other surviving documentation for the current framework that I know of.  So here my own inferences concerning how it works.

Each of the several datatypes that can appear on the LHS or RHS of an assignment is associated with a numerical value, as follows.  The numerical types marked n/a are present (or absent, depending on the point of view) because this classification also applies to various things like function parameters, procedure names, and so forth, that can't appear on the LHS or RHS of assignments.  

 1. BIT(...)
 2. CHARACTER(...)
 3. MATRIX
 4. VECTOR
 5. SCALAR
 6. INTEGER
 7. (n/a)
 8. (n/a>
 9. EVENT
 10. STRUCTURE
 11. (and beyond, n/a)

Any given identifier will have its entry in the global `SYM_TAB` array (defined in HALINCL/COMMON).  The entries in this array are class objects, and the specific field called `SYM_TYPE` will have a numerical value from the list above to indicate type of the associated identifier.  `SYM_TAB(n).SYM_TYPE` is accessed in the code as `SYT_TYPE(n)` (via an alias), and the discussion of SYT_TYPE in IR-182-1 provides additional info I haven't reproduced here.

The array `ASSIGN_TYPE` has these same 11 entries (plus 0, which isn't used), and the entry for a data type is a collection of bit-flags telling which data types are compatible with it.  In general, it will always be true that bit `1<<X` is set for `ASSIGN_TYPE(X)`, since that doesn't require any conversion at all; in some cases, those are the only allowed types.

Consider, for example, `ASSIGN_TYPE(6)`.  Type 6 is "INTEGER", so `ASSIGN_TYPE(6)` tells us which data types can be auto-converted *to* an integer.  The value of `ASSIGN_TYPE(6)` is binary 1100001, so bits 0, 5, and 6 are set.  I can't explain about bit 0, because that's a mystery, 5 and 6 are "SCALAR" and "INTEGER", so both scalars and integers can be converted to integers.

Actually, if you go through the settings implied by `ASSIGN_TYPE`, you see that they follow these rules:

  * Only BIT, CHARACTER, MATRIX, VECTOR, SCALAR, INTEGER, and STRUCTURE can appear on the LHS of an assignment.
  * Each of these can receive a value on the RHS of the same type.
  * Also, INTEGERs and SCALARs can appear on the RHS for any of the following LHS:  INTEGER, SCALAR, or CHARACTER.
  * And the mystery type 0 can be on the RHS for any of the following LHS:  CHARACTER, MATRIX, VECTOR, SCALAR, INTEGER.

In particular, INTEGER and SCALAR can be auto-converted to a CHARACTER string, but not vice-versa, and BIT *cannot* be auto-converted to or from INTEGER.  I guess I'm confused, because I thought they could be.  And indeed, my claims about `ASSIGN_TYPE` directly contradict the "HAL/S Programmer's Guide, Appendix A" (2005) for REL32V17, which says this (contradictions in **bold**):

  * **Bit strings**, scalars, and character strings (if they represent signed whole numbers) can be converted to INTEGER.
  * Integers, **bit strings**, and character strings can be converted to SCALAR.
  * **Integers**, **scalars**, and **character** strings (if consisting only of 0's and 1's) can be converted to BIT.
  * Integers, scalars, and **bit strings** can be converted to CHARACTER.

Is it possible that some of these conversions were added between REV32V0 (for which we have the compiler source code) and REV32V17 (to which the programmer's guide just mentioned applies)?  As it happens, No!  The next-most-current document we have that describes the conversions, "HAL/S Language Specification, Appendix D" (1980), lists the same conversions, in seemingly-identical language.  

> **Aside:**  Some other differences between the 1980 and 2005 document are interesting:  The 1980 document further considers conversions to and from a data type it calls `FIXED`, which it says "are used when the computer provides relatively inefficient support for SCALARS".  In other words, an implementation of HAL/S would have had either a `SCALAR` type or a `FIXED` type, but I think there wouldn't have been much reason to have both in any single implementation.  In any case, the compiler version we're working with doesn't seem to have had a `FIXED` type.

So there's clearly some misunderstanding on my part about what auto-conversions were allowed.

## <a name="Death"></a>The Boolean Conditional Trap of Death!

*Like* Python or C++, booleans in XPL can be treated as having numerical values, namely 0 for "false" and 1 for "true".  Thus if you have statements such as
<pre>
DECLARE I FIXED;
...
I = (A &lt;= B);
</pre>
then you'll find that I has either a value of 0 or of 1.

*Unlike* Python, C, C++, or any other language I recall, when you have conditionals in XPL like
<pre>
DECLARE I FIXED;
...
IF I THEN;
    ... come here for "true" ...
ELSE
    ... come here for "false" ...
</pre>
it is *not* the case the "true" branch is taken when `I ^= 0` and the "false" branch is taken when `I = 0`.  

Rather, **the "true" branch is taken when `I & 1 ^= 0` and the "false" branch is taken when `I & 1 = 0`**.

I have found several instances in which not knowing this &mdash; and how would you know it? &mdash; leads to a problem.  Those instances have fortunately been detectable once you know the secret, because they involve the pattern
<pre>
IF SHR(V, N) THEN; ...;
</pre>
where `V` is a value consisting of bit fields and the purpose of the shift operation is to isolate bit `N`.  But there are likely other cases in there's no `SHR` present to flag the potential problem.  (The `SHR` itself is mysterious anyway, since surely a test like `IF V & MASK THEN;` is more economical than a shift!  Well, it's best not dwell too much on that.)

Regarding the origin of this behavior, I thought perhaps XPL had inherited it from PL/I.  However, IBM's Enterprise PL/I for z/OS Language Reference, Version 5 Release 1, p.244, explicitly states that in a statement of the form 
<pre>
IF expression THEN unit1 ELSE unit2
</pre>
`unit1` will be executed if *any* bit in `expression` is 1, while `unit2` will be executed if *every* bit in `expression` is 0 ... so that's not what XPL is doing.

I thought this was some quirk of the Intermetrics version of XPL, but it's not.  If you dig deeply enough in McKeeman *et al.* (*A Compiler Generator*), on p. 139 you do find in converting a "numeric" to a "conditional" that "the low-order bit is tested; 1 yields true, 0 yields false".  So apparently this is a standard feature of XPL.

Note that this same consideration applies whenever an integer is assigned to a `BIT(1)` variable as well ... which is something that I've been ignoring so far (treating XPL `FIXED`, `BIT(16)`, `BIT(8)`, and `BIT(1)` all as integers), so I guess that's something I'll have to look into.  This as far as assignments are concerned, vs conditionals, that should have been obvious anyway, and I have nobody to blaim but myself.

# <a name="LINE_COUNT"></a>LINE_COUNT

The apparent global variable `LINE_COUNT` is never declared nor assigned a value, and yet is used in a couple of comparisons (in the OUTPUTWR and STREAM modules).  Nor is it a built-in of standard XML.  I have no explanation, unless it's a built-in of Intermetrics "enhancement" of XPL.

The comparisons seem to relate to the maximum number of lines per printed page, so presumably `LINE_COUNT` is should somehow be set to zero at the start of each printed page, and then incremented for each printed line.  My workaround is to have the `OUTPUT` built-in function treat it in that manner.

# <a name="ForLoop"></a>Value of Loop Counter After a For-Loop

Naively, an XPL for-loop such as
<pre>
    DO I = A TO B [BY C];
        ...
    END;
</pre>
would be implemented in Python (assuming that the step C is positive) as:
<pre>
    for I in range(A, B+1 [, C]):
        ...
</pre>
This takes into account that in XPL `I<=B`, whereas in Python `I<B`.

Unfortunately, that's not the end of it, since in some cases the code tests the value of the loop counter (`I`) after the loop terminates, but XPL and Python don't leave identical values in the loop counter.

I haven't found the documentation &mdash; I'm sure it exists &mdash; for Python that tells me what the terminating value of the loop counter *should* be.  However, what I find empirically is that:

  * The last in-range value of the loop is used.
  * If there were no in-range values, the counter continues to hold whatever value it had before the loop ... which could be `None` if the loop counter had never been previously assigned a value.

For example:
<pre>
    # If i never assigned a value at all:
    for i in range(2, 1):
        pass
    # i == None
    ...
    i = 12
    for i in range(2,1):
        pass
    # i == 2
    ...
    for i in range(1, 100):
        pass
    # i == 99
</pre>

For XPL, as far as I can tell (as usual!) it's simply not documentated at all what the post-loop value is.  It *is* documented in HAL/S, however, and for HAL/S the loop counter is always assigned a value, and on termination of the loop it still contains the value at which the loop *failed*.  This appears to be the case for PL/I as well, though I could easily be wrong.  Assuming these are the same as in XPL (which agrees with my observation of what the compiler's source code seems to expect), the equivalent loops in XPL to the ones we just saw would instead result in:
<pre>
    /* If i never assigned a value at all: */
    DO I = 2 TO 0;
        ;
    END;
    # I = 2
    ...
    I = 12;
    DO I = 2 to 0;
        ;
    END;
    # I == 12
    ...
    DO I = 1 TO 99;
        ;
    END;
    # I = 100
</pre>

In the case of either language, if the loop is broken prematurely, the loop counter will simply retain whatever value it had when the loop was broken.

It's difficult to see any reasonably-elegant way to systematically handle this difference as look as a Python for-loop is used to model the XPL for-loop, nor does a Python while-loop fit the bill perfectly.  

At this point,  I'm handling the situation simply by examining each for-loop and determining what kinds of tests of the loop counter are performed after the loop terminates, and to implement whatever's needed on a case-by-case basis.  Unfortunately, even this isn't necessarily a perfect solution, because global variables are often chosen as loop counters, and there's no good way to know what tests could conceivably be performed on such global variables.

The problem doesn't seem to extend to XPL `DO WHILE` loops implemented as Python `while` loops.

# <a name="VirtualMemory"></a>Virtual Memory

## <a name="Modules"></a>Virtual Memory Modules

The "virtual memory" system used by the HAL/S compiler is implemented by the VMEM\* modules in the HALINCL/ folder.  Almost all of pass 1 of the compiler doesn't seem to depend on this system in any way ... but eventually you reach a point in the implementation where it's unclear if you can do without it or not.  Unfortunately, as usual, there is no explanation at all provided in the program comments as to what any of this system is supposed to do.  Moreover, it apparently came after the documentation provided by IR-182-1, so there is no *written* documentation available to me that describes it or even mentions it.  Which means it simply has to be figured out from the source code.  That's what I'm going to try to do here.

The starting point, I reckon, is the two modules VMEM1 and VMEM2, which are nothing but declarations, and as far as I can see, every compiler pass uses both of these.  

The remaining modules, VMEM3, VMEM3A, VMEM3F, and VMEM5A are not truly different, but rather differ primarily in terms of which mix of functions they contain:

  * VMEM3 contains all of the functions contained in the other 3 modules.
  * VMEM3A removes the function `HEX1()`, and modifies functions that call it.  Perhaps more importantly, the error response in VMEM3A is simplified (or at least changed) from that of VMEM3.  Whereas VMEM3 relies on the global `ERROR()`, VMEM3A generally just prints an error message and then exits. 
  * VMEM3F removes a variety of additional functions &mdash; `DUMP_VMEM_STATUS()`, `GET_CELL()`, `MISC_ALLOCATE()`, ..., `VMEM_INIT()`, `VMEM_AUGMENT()` &mdash; as well has having a simplified error-response.
  * VMEM5A removes everything *except* the `GET_CELL()` function.

Regarding which combinations of these various modules are *actually* supposed to be used, the only clue I can find is in occasional statements of the form:
<pre>
    /* INCLUDE ...: $%... */
</pre>
I'm not sure how reliable these are, since they sometimes appear in obscure modules where you wouldn't expect them (such as MIN vs ##DRIVER), but here's what I find:

  * PASS1:  VMEM3
  * FLO:    VMEM3
  * OPT:    (None?)
  * AUX:    (None?)
  * PASS2:  VMEM3F + VMEM5A
  * PASS3:  VMEM3A
  * PASS4:  (None?)

This is reasonable in terms of what little I know.  In summary, it would appear to me that insofar as pass 1 of the compiler is concerned, only VMEM1, VMEM2, and VMEM3 need to be ported.

## <a name="Framework"></a>Virtual Memory Framework

The "physical" virtual memory is a random-access file &mdash; i.e., not something in physical memory &mdash; which for our purposes is always file number `VMEM_FILEp` (== 6), accessed via the built-in function `FILE()`.  For us, this translates to the file with filename "FILE6.bin".  The physical virtual memory consists of `VMEM_TOTAL_PAGES+1` (== 400) "pages" of `VMEM_PAGE_SIZE` (== 3360) bytes each.

At any given time, `VMEM_LIM_PAGES+1` (== 3) page buffers in memory may buffer pages from the physical virtual memory.  Those memory-buffered pages are maintained by (among other things), the following variables:

  * The list `VMEM_PAD_PAGE[]`, which contains the page numbers (0 through `VMEM_LIM_PAGES`) of the corresponding "physical" pages.
  * The list `VMEM_PAD_ADDR[]`, which contains the "addresses" of the buffered pages.  The "addresses" were originally absolute numerical addresses in core memory, but that's a concept which is now (and I suspect forever) of no value.  We use it instead to contain references to the Python `bytearray` objects we use to represent the buffers, with each `bytearray` being `VMEM_PAGE_SIZE` bytes in size.

There is a procedure (defined in VMEM3 *et al.*) called `MOVE(LENGTH, FROM, INTO)`, which originally was supposed to copy `LENGTH` bytes from the absolute numerical address `FROM` to the absolute numerical address `INTO` in core memory.  (Actually, it uses `LEGNTH`, but let's not concern ourselves with that novelty.)  None of those concepts are relevant to the current situation.  However, in our Python port we still need to copy a "certain amount" of data from "somewhere" to "somewhere else" &mdash; usually from a Python string or `bytearray` or list of some type into a virtual memory page buffer, or vice versa &mdash; so we need to adapt the `MOVE()` function to that purpose.  The adaptations are of several kinds:

  * The `FROM` and `INTO` parameters may now take a variety of forms:
       * They are integers for sources or destinations that are virtual-memory buffers.  Consider byte `A` within virtual-memory buffer `N`. It will be given the address `A + VMEM_PAGE_SIZE &times; N`.  This allows external code calling `MOVE()` to continue to perform simple arithmetic in Python on the absolute addresses in the manner the XPL was wont to.
       * For a source or destination that's a Python list, string, or bytearray, the `FROM` or `INTO` can instead be the Python ordered pair `(OBJECT, INDEX)`, where `OBJECT` is the reference to the list, `bytearray`, or string, and `INDEX` is the starting index into the list for the transfer. 
       * Or alternatively, `FROM` or `INTO` can just be a list, string, or bytearray reference, in which case it is assumed that the starting offset into it is 0.
  * `LENGTH` remains the number of bytes to transfer, but *only* in the case of a transfer from a location in a string or virtual-memory buffer to another string or virtual-memory-buffer location.  In the case of an list-to-list, list-to-buffer, or buffer-to-list transfer, it is instead the number of list elements to transfer.
  * In XPL, `MOVE()` is completely agnostic as to the nature of the data being transferred.  This is no longer the case in Python, since Python data must be converted to or from IBM data codings, or at least data codings of the proper size in bytes, and it may as well be to the IBM coding.  This means that when `MOVE()` is given a reference to a list, it must *recognize* that list in order to know how to perform the necessary data conversions, or even how to extract data from the list elements at all.  As a result, only a specific set of Python lists hardcoded into the `MOVE()` function can participate.
  * In the Python version of `MOVE()`, only integral numbers of list elements, aligned on list-element boundaries, can be transferred.
  * In the case of `INTO` referring to a string, whatever string is referred to cannot be changed in place, since strings in Python are immutable.  Instead, the `MOVE()` function returns the address of a new string (of the same length as the original) which the calling code should use to replace the original one.

In principle, in XPL `MOVE()` could also be used to transfer non-list data, or data not aligned on the obvious boundaries.  If this situation needs to be supported, some rethinking may become necessary.

# <a name="VUser"></a>Virtual Memory User Guide

In porting FLOWGEN (and I presume, OPT, AUX, and PASS2), it is becoming important that the virtual memory system actually *works*, whereas for PASS1 I basically just needed it not to do anything bad.  I'm realizing belatedly that that means I need some way to actually verify that it's working.  And to do that, I need to write test code, for which I need an understanding of how the thing is actually used.  Which given that there's no documentation of it, and no helpful advice about it likely to appear from external sources, I need to first contrive a user guide for it on my own initiative.

First, the basic underlying theory of what it's doing ... I think.  Some of this will be a reprise of statements already made above.  The virtual memory consists of the following two entities:

 1. Physically it's random-access file FILE6(.bin), arranged as up to 400 (`VMEM_TOTAL_PAGES+1`) "pages" of 3360 (`VMEM_PAGE_SIZE`) bytes each.  Each page has a unique index number from 0 through `VMEM_TOTAL_PAGES+1`.  The index number -1 is used to mean "no page", while `VMEM_LAST_PAGE` is the index of the highest page actually present in the file.
 2. There are 3 (`VMEM_LIM_PAGES+1`) pages buffered in memory at any given time.  The 3-element array `VMEM_PAD_PAGE[]` lists the page numbers that are currently memory-resident.  The array `VMEM_PAD_ADDR[]` lists the "addresses" at which the 3 memory buffers reside in memory.

> It is in `VMEM_PAD_ADDR[]` that things start to go wrong on us in a straightforward port of the HAL/S compiler's code from XPL to Python, because these addresses are not fixed, but rather change in the course of operation.  That's because rather than *copying* information to or from the virtual-memory buffers when we want to get data into or out of virtual memory, you instead just change the pointers.  And since we neither have "pointers" in Python, nor would the organization of data in memory match what we need for storage in virtual memory, the use of`VMEM_PAD_ADDR[]` to store pointers to data simply doesn't work for us.

Of the 3 pages potentially in memory buffers at in given moment, these are not selected by the user, but rather by the virtual-memory system according to some strategy.  Each of the three pages has one of the following three interpretations, and these are shuffled around during operation as buffered pages are released or new pages become buffered:

  * `VMEM_LAST_PAGE` &mdash; the most-recently used page.
  * `VMEM_PRIOR_PAGE` &mdash; the next-most-recently used page.
  * `VMEM_LOOK_AHEAD_PAGE` &mdash; the "look-ahead" page, buffered automatically by the virtual-memory system on the assumption it's the next one that will be needed.

 

TBD

# <a name="Samples"></a>Sample HAL/S Source Code

Most available samples of HAL/S source code &mdash; in lieu of actual Shuttle flight software source code &mdash; has been taken from Ryer's 1978 book, *Programming in HAL/S*.  Ryer tells us on his p. 2-9 (PDF p. 29) that

> Any HAL/S code which appears in a box ... is extracted from an actual listing: it has not been re-typed and is therefore free of any syntax errors.

This "error-free" characteristic is somewhat imaginary, since there are lot of problems with the ~100 boxes of sample code provided in the book.  Though perhaps some of those problems are due to differences between JPL's HAL/S compiler and Intermetrics's HAL/S compiler.  In particular, since the output listing from the compiler contains various kinds of markup not normally present in HAL/S source code as actually written by programmers, there's not any guarantee that such marked-up source code output by the compiler will necessarily be legal HAL/S source code according to the notions of whatever compiler uses it as input.  That means often had to edit the sample source code provided by Ryer, in order to make it legal for our compiler.  Besides which, my version of the compiler may sometimes accept Ryer syntax that the original Intermetrics compiler did not ... or vice versa.  

Here are some problems I've noted in this respect, in the code from Ryer's book:

  * The sample code does not necessarily respect the Intermetrics compiler's line-length limit of 80 characters max.
  * The original Intermetrics compiler does not accept some of the overpunch characters (for example, it will accept the overpunch '-' for a vector, but not '+' for a structure, even though it adds these to the output listing when not present initially).  These are all decorations without any syntactic meaning, of course, and so can be removed without penalty.
  * The original Intermetrics compiler does not accept enclosing brackets for array variables (such as `[A]`), nor I assume enclosing braces for structure variables (such as `{S}`), even though Ryer strongly implies that they are acceptable.  Enclosing brackets and braces therefore need to be removed.

# <a name="FINDER"></a>FINDER(), MONITOR(8), D INCLUDE, and Related Puzzles

The seemingly-unrelated topics listed in the heading are addressed together in this section due to the fact that I encountered them all at once when trying to work through inclusion of so-called "templates".

Templates are imported via the "`D INCLUDE TEMPLATE name`" compiler directive.  The compiler has several possible sources, all of them PDS files, and prioritizes searches for the member `name` among these files.  (Actually, a mangled form of `name` is sought, but that's not immediately relevant to the issues I'm confronting, so I'll ignore that.)  The prioritized PDS files searched, in descending order, are:

 0. The file attached to `OUTPUT8`.  Originally, this dataset was temporary, having no filename as such.   For us, it will be a file called "&&TMPINC.json".  It pertains to a different but related set of compiler directives (than "`D INCLUDE TEMPLATE name`"), namely "`D DEFINE name`", "`D CLOSE name`", and "`D INCLUDE name`".  The first two store (without compiling) the arbitrary block of code enclosed by them on OUTPUT8, while the latter imports that named block of code at whatever point the directive appears.  
 1. The file attached to `INPUT4`, which I think may be called "TEMPLIB" (for "template library" rather than "temporary library"; for us, "TEMPLIB.json").  This would be a permanent, persistent template library.
 2. The file attached to `OUTPUT6`, which is called "&&TEMPLIB" (for us, "&&TEMPLIB.json"). It is the "&&" prefix that indicates the temporary nature of the file, so this would stand for "temporary template library".  This is the temporary file to which the compiler outputs templates it has itself constructed during compilation of the current compilation unit. 

I'm speaking here only of pass 1 of the compiler.  It appears to be the case that in later passes, additional PDS files may be searched as well.

> **Note:** The item-numbering in the list above is 0, 1, 2.  Not all markdown systems support a starting number of 0, so this may show up incorrectly as 1, 2, 3 when viewed.

> **Aside**:  The associations described above between the logical units (OUTPUT8, INPUT4, OUTPUT6) and the filenames on the physical disk ("&&TEMPINC", "TEMPLIB", "&&TEMPLIB", respectively) are more-or-less hardcoded into the Python port of the compiler.  But for the original XPL version of the compiler, these nominal filenames weren't necessarily the ones used on any given compiler run, because alternate filenames could be coded using the DD cards of the JCL. One thing you could do in particular is to use the same file (perhaps "TEMPLIB") for both INPUT4 and OUTPUT6.  That allowed any new templates defined by the compiler run, or else changes to existing templates, to directly update the template-library file.  The nominal filename associations hardcoded into the Python version don't accomplish that: rather, new or changed templates are stored in file "&&TEMPLIB", but the "permanent" template-library file "TEMPLIB" would remain unchanged.  But you can work around this by adding the switch `--templib` to the compiler's command line.  When `--templib` is present, *both* INPUT4 and OUTPUT6 are assigned to file "TEMPLIB".

The searching itself is handled by the `FINDER` procedure in the module of the same name, as assisted by a call to `MONITOR(8, ...)`, which according to our best documentation (IR-182-1), is "Not in use. If called, produces ABEND 3000".  However, our best documentation is apparently out of date and wrong.  

I infer that what `MONITOR(8, fileno, filenum)` does is to associate a `filenum` with a `fileno`.  What that apparently means is that if thereafter you use commands like `INPUT(fileno, ...)` what you'll *actually* achieve instead is `INPUT(filenum, ...)`.  Upon reflection, I'm guessing that this redirection applies only upon *input*.  At the very least, if it was able to affect outputs, there are no instances of that in the compiler's source code.  In other words, `OUTPUT(...)` is unaffected.  Moreover, In addition to `INPUT` statements, the redirection also appears from the compiler's source code to affect `MONITOR(2, fileno)` (find PDS file member name) and `MONITOR(2, fileno, name)` (close input file) calls, which are all of the `MONITOR` calls directly related to input files.  HAL/S source code does not check for return codes from `MONITOR(8, ...)`, so I'm guessing it doesn't have one.

`FINDER(fileno, name, start)` then works as follows.  It searches the list of files I mentioned above (0, 1, 2) for the specified PDS-file member `name`.  The PDS file found also seeks to the start of member `name`.  *And*, the PDS file is also associated via `MONITOR(8)` with `fileno`, so that subsequent `INPUT(fileno)` statements operate on that PDS file.  It returns `FALSE` upon success and `TRUE` upon failure.  The `start` parameter is used to restrict the starting pointing in the file-search list; if 0, the entire list is searched; if 1, the search starts at index 1; and so on.

However ... you'll notice that two of the files on the search list are *output* files, whereas the explanation above is really only relevant to *input* files.  So this leaves us with a bit of a mystery as to how to input from an output-file.  One clue may be provided by the construction of the search list `FINDER()` uses.  The search list (for the 3 file types) hardcoded into the `FINDER` module has entries of one of following the two forms:

  * `filenum` (1-9) for files believed to be permanent input files.
  * `0x80000000+filenum` for file believed to be temporary output files.

More explicitly, the search list is:

        (0x80000008, 0x4, 0x80000006)

I don't understand the code in MONITOR.asm, but the code for `MONITOR(8, ...)` definitely allows for the possibility of either input-files or output-files, seemingly by selecting either a an "INPUT PDS WORK AREA" or an "OUTPUT PDS WORK AREA".  So in terms of the Python port, I guess that would correspond to using memory buffer for the file, whether input or output.  In particular, device INPUT6 is used for inputting access rights, and thus if `FINDER()` finds 0x80000006, it must definitely be interpreted in such a way as to input from OUTPUT6 rather than from INPUT6.

However, that leaves another puzzle:  How do you output to a PDS file anyway?  (Which is something I've not yet had cause to think about, let alone implement.)  Naively, it would seem as though you must use `MONITOR(2, ...)` to select a member name, just as you would for a PDS input file, and then to `OUTPUT(...)` to it, in place of the `INPUT(...)` for an input file.  *But*, the documentation in IR-182-1, the comments in MONITOR.asm, and the code in MONITOR.asm (to the extent I can understand it) all seem to be clear that `MONITOR(2, ...)` applies to *input* PDS files rather than to output files.

The necessary clue, I think, is provided if you look at `OUTPUT(8, ...)` statements in the compiler source code, which occur only in the `STREAM` module.  It appears to me that they work like this:

  * When `OUTPUT(8, ...)` is processed, it does not immediately perform any output, but simply buffers the output text in memory.
  * Eventually, a `CALL MONITOR(1, 8, name)` appears, and this "stows" the buffered data in the PDS file in the selected member name.  Presumably the member `name` is created if it doesn't already exist, the data already in it is is discarded if it does exist`, and the memory buffer is cleared.

More specifically, output begins to be buffered when "`D DEFINE name`" (see above) is encountered, and the "stow" occurs when "`D CLOSE name`" is encountered.  Thus the member `name` is immediately available thereafter.

`OUTPUT(6, ...)` is a bit trickier to understand, because it operates on a compilation-unit by compilation-unit basis.  In other words, each member in the PDS file is associated with an entire compilation unit:

  * Again, `OUTPUT(6, ...)` (which occurs only in the `EMIT_EXTERNAL()` function) stores text in a memory buffer.
  * `CALL MONITOR(1, 6, name)` (which occurs only once, optionally, at the end, in `PRINT_SUMMARY()`) "stows" the data using a name somehow related to the compilation unit.

# <a name="TemplateVersioning"></a>Version Management for the Template Library

*What I describe in this section is so weird that I may be misinterpreting in some grotesque way what's actually going on.
*
Related but distinct from the preceding section's issues is an unfortunate issue related to how the original compiler manages the version stamps for the templates in the template library.  Each member in the template library has a version stamp, which *logically* is an integer from 1 to 255 that begins with 1 on the first version of the template, increases every time the template is altered, and rolls around from 255 to 1 if perchance the number of saved versions is very large.  (This statement isn't necessarily true:  Only *one* version of the template is stored in any given template library, so to manually preserve more than one version of a template, more than one template library must be manually saved as well.)  Version numbers are normally automatically generated by the compiler, but can also be set manually within the HAL/S source code with a compiler directive of the form "`D VERSION code`".  Whether auto-generated or set manually, since the template-library files are themselves textual in nature, the version codes also appear in the template library files in that same form: i.e., "`D VERSION code`".

The issue is that although embedded in (from our standpoint) ASCII strings, these version codes are treated as numeric bytes rather than as "characters", and most of them are neither *valid* ASCII nore even printable EBCDIC.  For example, version 1 is encoded for `code` in the string "`D VERSION code`" not as "1" but as 0x01.  The collateral damage from this is that the Python version of the compiler can only encode the version codes as multibyte UTF-8 codes rather than single-byte ASCII codes, causing them to be misinterpreted or even corrupted in the `bytearray` representation we need to use to accommodate ASCII vs. EBCDIC.

HAL/S-FC (see PASS1's function EMITEXTE module) also does another peculiar thing, in that when it writes out templates to the PDS containing the template library, the final line of each compool is a `D VERSION code`, but as written out to the PDS, the version code is the single EBCDIC byte described above followed immediately by a human-readable version of the code!  When PASS1 reads in a template from the library, it uses the single-byte EBCDIC, but discards the human-readable part, except in the printout.  Because the EBCDIC code is *usually* a non-printable control code (for small versions), you don't see it in the printout but instead see the human-readable code, but you would see it if the version code became large enough to correspond to a printable character.
  
I don't see any way to handle these peculiarities other than to alter the compiler functionally, and just accept some degree of incompatibility.  So that in "`D VERSION code`", `code` will now be a two-character hexadecimal string representation of the version code, rather than a single-byte non-character representation of it.  For example, version 1 would now appear as "`D VERSION 01`".  In terms of auto-generated codes within the eco-system of the Python port of the compiler, this is transparent.  However, leaving that eco-system and allowing original HAL/S source code file and template-library files, some incompatibilities would require fixing:

  * Any compiler directives such as "`D VERSION code`" appearing in HAL/S source code files.
  * Or similarly, any such lines appearing in a template-library file.

At present, this is no problem since we have only a single original flight-software source-code file so far, and it contains no such lines.  But if we were to obtain any files of the problematic type in the future, fixing these problems could turn out to be impossible.  That's because all such source files would have been "converted" by some unknown method from EBCDIC to ASCII long before we ever received them, and there's no knowing how EBCDIC representations of these single-byte version codes may have been treated by the conversion process:  How did some unknown software convert some unprintable EBCDIC code to some irrelevant ASCII code?  Most likely the version codes are all very small numbers, and most likely were left as-is, but who really knows?


# <a name="OPTIONS_CODE"></a>OPTIONS_CODE

There is a variable called `OPTIONS_CODE` which conveys so-called "type 1" options, in the form of bit-flags, from the PARM field of the JCL to the compiler.  Unfortunately, while IR-182-1 lists some of these, it seems neither up-to-date, nor does it explain how of the bits in `OPTIONS_CODE` actually get set.  There's no code in the compiler to set them, so they just magically appear.  There are many more of them in IR-182-1 than there are known parameters (at least in compiler pass 1).

By looking at the compiler code, we can find the following actually being *checked*:

  * 0x00000002 &mdash; LISTING2
  * 0x00000010 &mdash; X0, NO TEMP (or "TPL_FLAG=0")
  * 0x00000800 &mdash; TABLES (or "SIMULATING")
  * 0x00002000 &mdash; X9 (or "SREF")
  * 0x00010000 &mdash; PARSE(?) (or "PARTIAL_PARSE")
  * 0x00040000 &mdash; FCDATA (or "HMAT_OPT")
  * 0x00080000 &mdash; SRN
  * 0x00100000 &mdash; ADDRS (or "ADDR")
  * 0x00200000 &mdash; LXFI
  * 0x00800000 &mdash; SDL

The interpretations of some of these are clear ... of others, not so much.  For example, all of the switches which IR-182-1 claims are relevant to pass 1 (vs 2, 3, 4) are in this list, but not all of the ones in this list are claimed to be relevant to pass 1.

The particulare irritation to me at the moment is that the compiler seemingly only auto-generates templates if 0x10 is set, which some of IR-182-1 claims is true as well, but which the "NO TEMP" notation in the list above (from IR-182-1 p. 3-18) seemingly says the opposite.

# <a name="Computation"></a>Compile-Time Computation of "Built-In" Functions

Compile-time computation of built-in HAL/S functions (like `ABS`, `MOD`, and so forth) is performed in the compiler by use of the `MONITOR(9)` call.  As far as I know right now, this is undocumented, as the only documentation I've found so far for `MONITOR(9)` pertains to its ability to perform floating-point operations like `sin` and `cos`.  In fact, `MONITOR(9)` causes an ABEND in the source code MONITOR.bal, so I suppose that MONITOR.bal must not belong with the compiler at all.  However, in the `END_ANY_FCN()` function of the compiler's ENDANYFC module, there's an inline function called `BI_COMPILE_TIME()` that I think performs *some* of the built-in function computations, and it indeed calls `MONITOR(9)`.

TBD

# <a name="NotSupported"></a>Some Features *Not* Supported in the Original Compiler

The principal source for the prospective HAL/S programmer, in my view, is Ryer's *Programming in HAL/S* (1978), and most of my samples of HAL/S code were extracted from that book.  However, not all features discussed (sometimes at length) in Ryer were supported by the actual HAL/S compiler used for the Shuttle's flight software.  I intend to list them here as I discover them ... or more accurately, perhaps, as I retire laboriously typed source-code samples now revealed to be irrelevant.

  * No `FIXED` datatype is supported, rendering all of Ryer's Chapter 14 useless.  (See Section 2.3.3 of the 2005 revision of the "HAL/S Language Specification".)

TBD

# <a name="Problems"></a>Roster of Remaining Problems with the Port

As of 2023-11-05, the number of compiler errors generated during compilation of the sample HAL/S source code scraped from Ryer (i.e., from the book *Programming in HAL/S*) has reached a pleasingly-small but unfortunately non-zero number.  As a consequence, it has become useful to categorize and discuss my attempts to address these issues individually.  That's done in the succeeding subsections.

If run (under **bash** in Linux) from the folder "yaShuttle/Source Code/ Programming in HAL-S" in the Virtual AGC source tree, the following command summarizes the errors found:
<pre>
rm report.log ; \
for f in &ast;.hal; \
do \
    echo $f >>report.log ; \
    HAL_S_FC.py SRN --hal=$f >$f.lst 2>>report.log ; \
done ; \
egrep '^\&ast;\&ast;\&ast;\&ast;\&ast; [^ ]+  +ERROR' &ast;.hal.lst --only-matching --no-filename | \
sort | \
uniq -c | \
sort -n --key=1 ; \
echo "" ; \
egrep --after-context=3 '^\&ast;\&ast;\&ast;\&ast;\&ast; [^ ]+  +ERROR' &ast;.hal.lst | \
grep --only-matching '^.&ast;lst:' | \
sort -u
</pre>

Folders in the publicly-available source tree that contain HAL/S source-code files (vs private caches of flight-software source-code files) are:

  * yaShuttle/ported/
  * yaShuttle/Source Code/Programming in HAL-S/
  * yaShuttle/Source Code/HAL-S-360 Users Manual/

At this writing (2023-11-07), there are presently no HAL/S sample files or *available* actual flight software which produce any compile-time error messages.

# <a name="Optimizing"></a>Optimizing Sub-Passes

This README and the port of compiler PASS1 were originally undertaken under the assumption that there was no reason to implement compiler passes beyond PASS1, since the IBM 360 or AP-101S object code generated by PASS2 seemed to be of little use to us.  However, recent events have made it clear to me that the object code is useful after all, and so PASS2 should be implemented.  In order to do that, however, it is also necessary to port the 3 optimizing passes that occur *between* PASS1 and PASS2.  Thus even though I've completely ignored these issues before now, I now have to start learning about them and keeping notes on what I find out.

The later documentation barely refers to optimization at all.  Whereas the early documentation (in particular IR-182-1, Section 6) does discuss optimization, but doesn't refer to the optimizing passes by name, apparently because at that time there was only a single optimizing pass anyway.  From the detailed descriptions in IR-182-1 section 6.3 and beyond, in comparison to the compiler's XPL code, it is clear that IR-182-1 is documenting just to the compiler code in OPT.PROCS/.  In other words, we can identify OPT.PROCS = "Phase 1.5".

Referring to the XPL source code, the messages printed by another of the optimizing sub-passes, FLO.PROCS, lead us to the identification FLO.PROCS = "Phase 1.3".  "Phase 1.3" is undocumented, but nevertheless the numbering seems to imply that FLO.PROCS was executed *before* OPT.PROCS.

But what about the remaining optimization sub-pass, AUX_PROCS?  I presently have no clue as to when it executed relative to FLO.PROCS and OPT.PROCS.  In particular, while it's attractive imagine that AUX_PROC was "phase 1.4", it seems equally likely that a gap would have been left in the phase numbering for possible future uses.  

I'm informed that the ordering can be obtained from the file yaShuttle/Source Code/TOOLS.COMPILER.CLIST/AUDIT:

 1. PASS1
 2. FLO (FLOWGEN)
 3. OPT (OPTIMIZER)
 4. AUX (AUXMAT)
 5. PASS2
 6. PASS3
 7. PASS4

The inference is that *perhaps* AUX = "Phase 1.7".  Perhaps.  Though it hardly matters now, I expect.  The comments in CLIST AUDIT say that it is to "BUILD A COMPILER DATASET FROM THE INDIVIDUAL OBJECT MODULES OF EACH COMPILER PHASE".  Though it doesn't affect us, I think, I am further informed that the CLIST XPLZAP in the same directory was used to (as its comments say) "INVOKE THE XPLZAP PROGRAM FOR AN XPL OBJECT MODULE; USED TO PUT A RELEASE VERSION STAMP INTO A COMPILER".

Thus the next program which must be ported to Python 3 is FLO.PROCS (FLOWGEN) ... *assuming* that it actually alters the HALMAT, as opposed to merely performing some kind of analysis.  That's TBD.

In the meantime, I'm trying to understand has PASS1 passes data to the optimizing passes (or to PASS2 in their absence).  As far as data passed in files is concerned &mdash; apparently only the random-access files, FILE1 through FILE6 &mdash; I've found the following, insofar as data output by PASS1 is concerned:

  * FILE1 (which in the Python port is FILE1.bin) passes the HALMAT.  I've written a program called unHALMAT.py to parse this file, insofar as it is possible to do so in the absence of most of the documentation about HALMAT.  It actually works pretty well, though obviously is not complete, so it's what should be consulted for more detail.
  * FILE2 (.bin) passes the "literal table".  However ... while numerical-constant data was included in FILE2, string data was not.  Rather, if there were a string literal, the data for it in FILE2 consists merely of a memory pointer to the string data, and of course that memory point works only in memory.  For the Python port (see the section below on reverse engineering the literal-table file), I export the string data in a dedicated file (LIT_CHAR.bin), and the "pointers" in FILE2.bin become simply offsets into the LIT_CHAR.bin file.  Thus in the Python port, the *entire* literal data table is passed by files.

Section 2.2.5 of IR-182-1 says this about the data passed from PASS1 to the optimizer passes or to PASS2,

> The data passed via a common memory area includes all symbol table and cross reference table information. These tables contain complete descriptions of all user-defined symbols and the HAL/S statements in which they are used. Since this table data is tied to HAL/S source code it is in a machine-independent form. Additional data passed in memory includes status information, special request information, error condition data detected in Phase 1, and some literal data information.

and goes on to say that the only *files* passed are the "numeric literal data" (presumably FILE1) and the HALMAT (presumably FILE2).  Deconstructing the statements about what is passed in memory is trickier.  Presumably, the "some literal data information" mentioned at the end is the string data which we do pass in a file (LIT_CHAR.bin).  The memory data that leaves us to worry about are:

  * Symbol table.
  * Cross reference table Information.
  * Status information,
  * Special request information.
  * Error condition data detected in Phase 1.

As far as symbol-table information is concerned, I would reason that this is some subset of the information used by PASS1's `SYT_DUMP()` procedure.  The question is "which subset"?  Upon inspection of SYTDUMP, it seems to me that it's every variable having a name of the form `SYT_xxx`.  Those in turn all come from the following in HALINCL/COMMON:
<pre>
    /* SYMBOL    TABLE  */
    COMMON   BASED SYM_TAB RECORD DYNAMIC:
             SYM_NAME                    CHARACTER,
             SYM_ADDR                    FIXED,
             SYM_FLAGS                   FIXED,
             XTNT                        FIXED,
             SYM_XREF                    BIT(16),
             SYM_LENGTH                  BIT(16),
             SYM_ARRAY                   BIT(16),
             SYM_PTR                     BIT(16),
             SYM_LINK1                   BIT(16),
             SYM_LINK2                   BIT(16),
             SYM_NEST                    BIT(8),
             SYM_SCOPE                   BIT(8),
             SYM_CLASS                   BIT(8),
             SYM_LOCK#                   BIT(8),
             SYM_TYPE                    BIT(8),
             SYM_FLAGS2                  BIT(8),
    END;
</pre>
PASS2, FLO, OPT, and AUX (and PASS3 too) do indeed use `SYM_TAB`, and continue to use the associated `SYT_xxx` macros.  It appears to me that they simply use HALINCL/COMMON.  It appears that the only field in `SYM_TAB` that refers to an external object outside of `SYM_TAB` is the `SYM_XREF` field.

`SYM_XREF` points to an entry in the `CROSS_REF` array, defined also in HALINCL/COMMON as:
<pre>
/* CROSS REFERENCE TABLE */
COMMON   BASED CROSS_REF RECORD DYNAMIC:
         CR_REF                      FIXED,
END;
</pre>
Meanwhile, the entries in `CROSS_REF`, while including pointers, are completely internal to `CROSS_REF` itself.  

Consequently, it would appear that we can pass both the symbol-table and cross-reference info between compiler passes simply by saving the `SYM_TAB` and `CROSS_REF` objects to files.  I do this by saving those objects in JSON form, in the files SYM_TAB.json and CROSS_REF.json, respectively.

As far as "error condition data detected in Phase 1" is concerned, it *could*  refer to the `ADVISE` array defined in HALINCL/COMMON, but ... I don't know; seems funny.

TBD

## Reverse engineering the literal-table file

The file's (FILE2.bin) block size is 1560 (0x618) bytes.

The area 0x000-0x203 seems to be a table of 32-bit records that describe the characteristics of the literals.  There is room for 0x204/4 = 130 entries, but entry 0 seems to be unused (or used for some other purpose), so there are actually only 129 usable entries.  The literals appear in the same order (and indexing) as the optional literal-table dump of the compiler's output listing.  The entries seem to be fields of bit-flags, as follows:

  * Bit 0:  Indicates an arithmetical value (INTEGER or SCALAR, with no distinction between them).
  * Bit 1:  Indicates a BIT value.
  * Bit 2:  Indicates precision (0=SP, 1=DP) for arithmetical values.

The area 0x204-0x407 is a table of the most-significant 32-bits of the literal values (or at least for the arithmetical ones).

The area 0x408-0x60B is a table of the least-significant 32-bits of the literal values.

In retrospect, I see that this info is consistent with the description in section 3.1 of IR-182-1, except that the description in IR-182-1 doesn't include some of the info above.  Specifically, each block of the file would correspond to an image of the `LIT_PG` array from HALINCL/COMMON. 

Besides what was said above, the entries for `CHARACTER` constants are of the form (hexadecimal) XXYYYYYY, where XX is the length of the constant string minus 1, and YYYYYY is a pointer into the `LIT_CHAR` array that holds the actual string data.  `LIT_CHAR` was apparently *not* passed to later compilation passes via a file for unknown reasons &mdash; IR-182-1 simply says that "LIT_CHAR cannot be kept on an intermediate file" &mdash; and thus it must have been passed in memory.  We, however, must pass it in a file, which we'll call LIT_CHAR.bin.  It's a binary file rather than a text file because it is a byte array of EBCDIC data rather than ASCII.

## Pass-to-Pass FILEx Usage, Continued

I already talked about FILE1 and FILE2 as output by PASS1 above.  Let's look at FILEx more generally, in the broader context of the entire sequence of passes (including optimization) described earlier:

  * PASS1:
    * Outputs:
        * FILE1 (`HALMAT_FILE`) = HALMAT
        * FILE2 (`LITFILE`) = Literal table (*sans* data for literal strings, passed in memory/LIT_CHAR.bin).
        * FILE3 (`IC_FILE`) = I/C queue.  HALMAT(?) for `INITIAL`/`CONSTANT` attributes in `DECLARE` statements.
        * FILE6 (`VMEM_FILE#`) = Virtual memory
  * FLOWGEN:
    * Inputs:
        * FILE1 (`CODEFILE`) = HALMAT
        * FILE2 (`LITFILE`) = Literal table.
        * FILE6 (`VMEM_FILE#`) = Virtual memory
    * Outputs:
        * FILE6(?) (`VMEM_FILE#`) = Virtual memory
  * OPT:
    * Inputs:
        * FILE1 (`CODEFILE`) = HALMAT
        * FILE2 (`LITFILE`) = Literal table.
    * Outputs:
        * FILE2 (`LITFILE`) = Literal table.
        * FILE4 (`CODE_OUTFILE`) = HALMAT
  * AUX:
    * Inputs:
        * FILE4 (`HALMAT_FILE`) = HALMAT
    * Outputs:
        * FILE1 (`AUXMAT_FILE`) = Auxiliary HALMAT
  * PASS2:
    * Inputs:
        * FILE1 (`AUX_FILE`) = Auxiliary HALMAT
        * FILE2 (`LITFILE`) = Literal table.
        * FILE3 (`CODE_FILE`) = 
        * FILE4 (`CODEFILE`) = HALMAT
        * FILE6(?) (`VMEM_FILE#`) = Virtual memory
    * Outputs:
        * FILE2 (`LITFILE`) = Literal table.
        * FILE3 (`CODE_FILE`) = 
        * FILE6(?) (`VMEM_FILE#`) = Virtual memory
  * PASS3:
    * Inputs:
        * FILE2 (`LITFILE`) = Literal table.
        * FILE5 = SDF(?)
        * FILE6(?) (`VMEM_FILE#`) = Virtual memory
    * Outputs:
        * FILE5 = SDF(?)
  * PASS4:
    * Inputs:
        * (None)
    * Outputs:
        * (None)
