# Introduction

My plan for this folder (ported/) is to port a portion of the original HAL/S-FC compiler from its XPL language form to the Python 3 language.

This port will be of just the original compiler's PASS1 (or "phase 1"), which parses HAL/S source code and produces output in the form of the HALMAT intermediate language.  Since only 20% of HALMAT's documentation has survived, the output-code generator will have to be augmented to additionally produce my own intermediate language, PALMAT.  PALMAT is directly executable on my emulator.

Other than the addition of PALMAT generation, the intention is for the port to be very direct, without any "reimaginings" to make the compiler better or more efficient.  The idea is that the XPL and the Python should correspond very directly and obviously in a side-by-side comparison.

As far as this "README" is concerned, some involves factual background material or else descriptions of implementation decisions I've made.  However, quite a lot of it is devoted to what may be called "inferences and mysteries": i.e., to trying to puzzle out details about how the Intermetrics "enhancements" to XPL may have functioned or to how the original XPL code of the HAL/S compiler worked.  Obviously, that's a work in progress and subject to my own temporary or permanent misunderstanding.

# Some Bookkeeping Details

File hierarchy:  The original hierarchy of XPL modules looked like so:

  * ...
  * HALINCL/
  * PASS1.PROCS/
  * PASS2.PROCS/
  * PASS3.PROCS/
  * ...

Each XPL file *needed* for PASS 1 of the compiler is ported to Python, but files not needed won't be given any Python equivalents.  Filenames are retained, other than file extensions being replaced by ".py".  However, the file hierarchy isn't maintained in the same form, because Python wants to import modules only from the current folder or from subfolders, and *not* from folders with other relationships to the current folder.  Therefore, the following hierarchy is used for the ported files:

  * ported/                 Files from PASS1.PROCS/
      * HALINCL/            Other folders ...
      * ...

For example, the "main program", originally named "PASS1.PROCS/##DRIVER" or "PASS1.PROCS/##DRIVER.xpl", thus becomes "ported/##DRIVER.py" in Python.  Whereas the original file "HALINCL/COMMON.xpl" would become "ported/HALINCL/COMMON.py".

Additionally, many variables, constants, functions, and macros defined in PASS1.PROCS/##DRIVER.xpl, as well as some which are always present and don't need to be defined in any XPL source file, are expected to be within scope for other XPL source-code files.  I've adopted the following convention:

  * Definitions of global variables and constants, as well as some python functions having the same names as the original XPL variables and are intended to workaround some goofy behavior of the originals, are collected in the file g.py.
  * Definitions of global functions and macros such as `MONITOR()`, `OUTPUT()`, `BYTE()`, and so on are collected in the file xplBuiltins.py

Therefore, in any of our other files ported from XPL to Python, these can be accessed by including the line:
<pre>
    from xplBuiltins import *
    import g
</pre>
Those functions and macros are then used just as-is, without any name changes, whereas the global variables and constant have "`g.`" prefixed to their names.  For example, if you had a global function (say, `MONITOR`, defined in xplBuiltins.py) and a global variable (say, `CURRENT_CARD`, defined in g.py), you could access them as:
<pre>
    from xplBuiltins import *
    import g
    ...
    MONITOR(...)
    ...
    g.CURRENT_CARD = ...
</pre>
It's important *not* to import g.py with `from g import *`, because assignments to variables defined in g.py won't change the values of those variables in other files importing g.py if they're not in the `g.` namespace.  However, assignments in the `g.` namespace do affect all files that import g.py.

In addition to the usual alphanumeric and underline characters, identifiers in XPL can include the characters '@', '#', and '$', which are not allowed in Python identifiers.  However, it so happens that all of the original HAL/S-FC source code contained only upper-case characters when alphabetic.  Therefore, I use the uniform system of replacing disallowed characters in identifiers as follows:

  * '@' -> 'a'
  * '#' -> 'p'
  * '$' -> 'd'

For example, the global variable `MAXR#` becomes `g.MAXRp`.  But that's a worst case.  Any local variables not containing these funny characters would simply retain the same names in Python as they originally had in XML.

# EBCDIC vs ASCII vs UTF-8

All PASS and BFS HAL/S source code, to my belief, was originally character-encoded using EBCDIC.  Before any of this HAL/S source code ever reached me &mdash; well, as I write this, *none* of it has yet reached me &mdash; somebody recoded it in UTF-8.  Actually, except for two special characters, "¬" and "¢", it is all 7-bit ASCII.  This hybrid existence is troublesome, so I have adopted the following conventions for external storage of the source code vs internal storage in the compiler:

  * All HAL/S source code is nominally 7-bit ASCII.  If the UTF-8 characters logical-not (¬) and cent (¢) are found, they are transparently converted to tilde (&#126;) and backtick (&#96;) respectively.  Carat (^), which should never be present, is also transparently converted to tilde.  Put a different way, ¬ &#126; ^ are now all equivalent, but &#126; is the preferred form used internally; similarly, ¢ &#96; are equivalent but &#96; is the preferred form used internally.
  * All TAB characters are transparently expanded as if there were tab stops every 8 columns.

However, the original XPL form of the compiler *relied* upon the storage format being EBCDIC, because in processing (such as tokenization) it used the byte-codes of the characters, and it expected those byte codes to be EBCDIC.  Therefore, my approach is simply to make sure that any processing which converts between characters and byte codes, or vice-versa, correctly translates between ASCII and EBCDIC.  The conversion function that takes a character and converts it to a byte code is the built-in `BYTE()` function of XPL.  In our recreation of the `BYTE()` function, therefore, it converts between ASCII and EBCDIC as needed.  For example, `BYTE('a')` returns 0x81 (the EBCDIC code for 'a') rather than 0x61 (the ASCII code for 'a').  Similarly, a usage like `BYTE(s, 2, b)` that replaces the string character `s[2]` by the character with byte-value `b`, expects `b` to be an EBCDIC code.  For example `BYTE('hello', 2, 0x81)` returns `'healo'`.

# Changes to Parameter Values Within Procedures

XPL documentation explicitly states [McKeeman section 6.14]:

> All parameters are called by value in XPL, hence assignments to the corresponding formal perameter with the procedure definition have no effect outside the procedure.  To pass values out of a procedure, one must either use the <return statement> or make an assignment to a global variable.

Alas, the creators of XPL didn't reckon with the ability of the Shuttle's coders to exploit undocumented holes (or perhaps deliberate divergence from the definition of XPL) in the XPL compiler.  Formal parameters which are strings are apparently passed by reference in the Intermetrics/United Space Alliance version of the XPL compiler, and the source code for HAL/S-FC exploits this by allowing strings passed by formal parameters into a procedure to be altered by the procedure, and for those changes to be visible by the calling code.  An example is the PASS1.PROCS/PRINT2 module, which alters its formal string parameter `LINE`.

In fact, most (or all) calls to `PRINT2` pass `LINE` parameters that are string expressions or literals, rather than strings stored in variables, so the adjustments to `LINE` made by `PRINT2` are *not* changing strings stored in variables, but rather changing strings that had better not be changed.

But see also the next two sections.

# Persistence and Initialization of Local Variables Within Their Parent Procedures

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

# Absence and Persistence of Parameters of Procedures

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

# Dynamic Memory Allocation: `BASED` and its Macros

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

# PASS vs BFS Conditionals

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

# TIME, DATE, and other XPL Built-In Functions

There are XPL "implicitly declared" functions and variables that are always available (see Table 6.9.1 in "A Compiler Generator").
To the extent needed, these are replaced by Python functions and variables of the same name.

However, some of these implicit "variables", such as `TIME` and `DATE`, are supposed to have different values every time they are accessed.  For example, `TIME` is the number of centiseconds elapsed since midnight (timezone unspecified).  I don't think there's any satisfactory way to implement this in Python while retaining the same syntax, so `TIME`, `DATE`, and presumably other such "variables", are instead implemented as Python functions:  in this case, `g.TIME()` and `g.DATE()`.

# Semicolons

XPL requires semicolons at the ends of statements.  Python does not, but it *allows* semicolons to delimit multiple statements written on a single line, and thus is tolerant of them.  I didn't know that, and removed many in the porting process before discovering it.  The upshot is that I've tended to leave the semicolons in place, just because it's easier for me.  I may end up eventually removing them after all, simply because it's not really a Python thing to keep them, and indeed some Python lint/prettyprinter software annoyingly (if appropriately) goes out of its way to produce warnings upon finding them.  Since in our case there are 10's of thousands of such warnings, it's *very* irritating.

# Partitioned Data Sets (PDS)

There seems to be a concept of three different types of files used by the compiler system, handled by different mechanisms:  "sequential files", "random access files", and "partitioned data sets" (PDS).  The former two are just what they sound like, and it's only the PDS that needs discussion.

A PDS apparently consists of member chunks, of variable sizes, with each chunk accessible via a unique member name that's exactly 8 characters long (padded with spaces if necessary).  This is a concept built into IBM's z/OS operating system.  Each such PDS must therefore have an associated index that can match member names with offsets into the PDS.  Chunks can be read, written, or replaced, and are presumably therefore capable of dynamic changes in size.

How IBM chose to implement the PDS concept is irrelevant to us, and I can implement it however I choose.  Because whatever concerns IBM originally had about execution speed and efficient disk storage are essentially meaningless 50+ years later, I can use whatever method I deem quickest in getting me to workable, maintainable code.  If you don't like it ... tough!

My choice is this:

  * While in use, each PDS is fully buffered in compiler memory, in the form of a Python dictionary.  The dictionary keys are the member names, and the values associated with the keys are whatever is convenient for the purpose of porting the specific PDS.
  * The storage of the PDS as a file is in the form of a JSON representation of the dictionary.

As far as reading from a PDS is concerned, the technique is first to find the member of the PDS you're interested in via `MONITOR(2,DEV,MEMBER)`.  You then read that member line-by-line using INPUT(DEV).  Evenually INPUT(DEV) returns an empty string to indicate the end of the member.

# Equivalence of Arrays and Non-Arrays

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

# More Conditional Code in XPL

I already discussed PFS-specific vs BFS-specific conditional compilation above.  But there's more to it than just those cases.

In the XPL, you occasionally find code enclosed between an opening delimiter like "`/?X`" and a closing delimiter like "`?/`", where `X` represents one `A`, `B`, `C`, or `P`.  I interpret this as being conditionally-included code, and `X` as representing some particular condition for inclusion.

  * `/?A ... ?/` &mdash; TBD.  This is used only within the module HALINCL/SPACELIB, and the conditional code often (perhaps always) appears to relate to the printing of certain kinds of messages.  But I don't understand SPACELIB, so it's hard to be sure.
  * `/?B ... ?/` &mdash; For conditional code exclusive to the backup flight software.
  * `/?C ... ?/` &mdash; TBD.  This is used only within the `COMPACTIFY` procedure in the module HALINCL/SPACELIB, and the conditional code only appears to be the printing of certain messages possibly useful in debugging.
  * `/?P ... ?/` &mdash; For conditional code exclusive to the primary flight software.

# The Vocabulary, States, and Tokens

## Background

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

## `VOCAB`, `VOCAB_INDEX`, and `V_INDEX`

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

## Digression:  BNF Rules for Nonterminals, and "Productions"

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

## `STATE_NAME`

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

## `#PRODUCE_NAME` (Ported as `pPRODUCE_NAME`)

It appears to me that `#PRODUCE_NAME` returns a state number for any given production number.  (See above.)  In general, I think, any given state may give rise to several possible BNF productions, due the fact that any given BNF nonterminal rule may represent several different alternative rules.  For example, in the example given earlier, we saw that nonterminal &lt;ARITH EXP> (state 190) may give rise to production 4 (&lt;ARITH EXP> ::= &lt;TERM>), production 5 (&lt;ARITH EXP> ::= + &lt;TERM>), production 6 (&lt;ARITH EXP> ::= - &lt;TERM>), production 7 (&lt;ARITH EXP> ::= &lt;ARITH EXP> + &lt;TERM>), or production 8 (&lt;ARITH EXP> ::= &lt;ARITH EXP> - &lt;TERM>).  This we'd expect each of `pPRODUCE_NAME[5]` through `pPRODUCE_NAME[8]` to give us 190 ... which in fact it does.

Thus in spite of being called `pPRODUCE_NAME`, this array *cannot* in fact be used to get a descriptive name of the BNF rule associated with the production.  It can, of course, be used to recover the name of the associated nonterminal:
<pre>
g.VOCAB_INDEX[g.pPRODUCE_NAME[PRODUCTION_NUMBER]]
</pre>

## `READ1` and `READ2`

The `READ1` and `READ2` arrays are the same size, and are organized in the same way.  Each consists of a sequence of blocks of variable size, and each block corresponds to information specific to one of the states (`g.STATE`) of the scanner state machine.  The blocks have corresponding positions and lengths in the the two arrays.  (See `INDEX1` and `INDEX2` below to understand how to locate the blocks in `READ1` and `READ2` that correspond to specific states.)

For any given state, `READ1` provides a list of the tokens which can legally be found next in the input stream in the given state.  For example, suppose the statement being parsed is "`DECLARE INTEGER INITIAL(1), A, B;`", and that the comma after `A` has just been parsed.  At this point, the scanning state machine will be in state `g.STATE==58`.  It will turn out (again, see `INDEX1` and `INDEX2`) that the block of entries in `READ1` consists just of `READ1[904]`, which happens to be the token 131 (`g.ID_TOKEN`).  Thus the only item we can legally encounter next in the input stream is an `<IDENTIFIER>`.

Meanwhile, `READ2` provides the next scanning state that we'll enter when the specific token found in `READ1` has been found in the input stream.  In the example from the preceding paragraph, for example, once token 131 (`READ1[904]`) has been identified in the input stream while we're in state 58, the next state we'll enter is `g.STATE=g.READ2[904]`, which happens to be 538.

## `LOOK1` and `LOOK2`

The `LOOK1` and `LOOK2` arrays are the same size as each other, and are organized in the same way.  Each consists of a sequence of blocks of variable size, and each block corresponds to information specific to one of the states (`g.STATE`) of the scanner state machine.  The blocks have corresponding positions and lengths in the the two arrays.  (See `INDEX1` and `INDEX2` below to understand how to locate the blocks in `LOOK1` and `LOOK2` that correspond to specific states.)

So far, the descriptions of `LOOK1`/`LOOK2` are entirely analogous to those of `READ1`/`READ2` in the preceding section.  One difference, though, is that blocks of tokens in `LOOK1` always terminate with the same illegal token-code (0), so there's never any need to explicitly know the lengths of these blocks.

The other difference is that `LOOK1` and `LOOK2` perform the same roles for "look-ahead" states (see the `STATE_NAMES` section above) that `READ1` and `READ2` do for "named" states.  Thus, `LOOK1` provides blocks of the allowed next input tokens for any given look-ahead state, while `LOOK2` provides the next state corresponding to those allowed tokens.

## `APPLY1` and `APPLY2`

TBD

## `INDEX1` and `INDEX2`

The `INDEX1` and `INDEX2` arrays provide a way to gain access to the information encoded in the `READ1`/`READ2` or `LOOK1`/`LOOK1` arrays (see above).  

The index in both the `INDEX1` and `INDEX2` arrays is a state number (via `g.STATE`, for example).  

If the state number is in the range 0 through 441 (`g.MAXRp`), then `INDEX1[state number]` provides the offset of the state within the `READ1`/`READ2` arrays, while `INDEX2[state number]` tells us the number of consecutive entries in the `READ1`/`READ2` arrays that are devoted to the state.

Similarly, if the state number is in the range 442 through 666 (`g.MAXLp`), then `INDEX1[state number]` provides the offset of the state within the `LOOK1`/`LOOK2` arrays, while `INDEX2[state number]` tells us the number of consecutive entries in the `LOOK1`/`LOOK2` arrays that are devoted to the state.

> **Aside:** `INDEX2` isn't actually *needed* (or indeed, used) for lookups in `LOOK1` and `LOOK2`, because it turns out that each block of tokens in `LOOK1` ends with a token equal to zero.  Hence it's not necessary to explictly know the lengths of blocks in `LOOK1`, but merely to continue searches until reaching a terminating 0.

For example, suppose that we are in the scanning state identified as `g.STATE==59`.  We find that `g.INDEX1[59]==939` and `g.INDEX2[59]==3`.  Therefore, only `READ1[939]`/`READ2[939]`, `READ1[940]`/`READ2[940]`, and `READ1[940]`/`READ2[940]` are all applicable to scanning state 59.

## `CHARTYPE`

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

## `TX`

The `TX` array provides translations from EBCDIC character codes to token codes ... but only for those EBCDIC characters comprising an entire token by themselves.  All other characters (such as alphanumerics) will simply have an entry in `TX` of 0.  (Recall that 0 is not a legal identifying code for a token.)

For example, the period character is an entire token by itself, having a token code of 1 (since `VOCAB_INDEX[1]=='.'`).  However, considered as an EBCDIC character, a period is encoded numerically as 75 (decimal). Thus `TX[75]==1` is the translation from the EBCDIC code to the token code.  

Similarly, the less-than sign has a token code of 2 (`VOCAB_INDEX[2]=='&lt;'`), and the EBCDIC less-than sign is encoded numerically as 76 (decimal), so `TX[76]==2`.

## `LETTER_OR_DIGIT`

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

## `SET_CONTEXT`

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

The array `SET_CONTEXT` has an entry for each possible token &mdash; i.e., it has entries `SET_CONTEXT[1]` through `SET_CONTEXT[142]`, with `SET_CONTEXT[0]` being unused, and appears to provide a context for each of these tokens.  For example, if `g.TOKEN` is 25 (`g.VOCAB_INDEX[25] == 'GO'), we find that `g.SET_CONTEXT[25] == 2` ("GO TO").


