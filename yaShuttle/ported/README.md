# Introduction

My plan for this folder (ported/) is to port a portion of the original HAL/S-FC compiler from its XPL language form to the Python 3 language.

This port will be of just the original compiler's PASS1 (or "phase 1"), which parses HAL/S source code and produces output in the form of the HALMAT intermediate language.  Since only 20% of HALMAT's documentation has survived, the output-code generator will have to be augmented to additionally produce my own intermediate language, PALMAT.  PALMAT is directly executable on my emulator.

Other than the addition of PALMAT generation, the intention is for the port to be very direct, without any "reimaginings" to make the compiler better or more efficient.  The idea is that the XPL and the Python should correspond very directly and obviously in a side-by-side comparison.

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

  * All HAL/S source code is nominally 7-bit ASCII.  If the UTF-8 characters "¬" and "¢" are found, they are transparently converted to "~" and "`" respectively.  ("^", which should never be present, is also transparently converted to "~".)
  * All TAB characters are transparently expanded as if there were tab stops every 8 columns.

However, the original XPL form of the compiler *relied* upon the storage format being EBCDIC, because in processing (such as tokenization) it used the byte-codes of the characters, and it expected those byte codes to be EBCDIC.  Therefore, my approach is simply to make sure that any processing which converts between characters and byte codes, or vice-versa, correctly translates between ASCII and EBCDIC.  The conversion function that takes a character and converts it to a byte code is the built-in `BYTE()` function of XPL.  In our recreation of the `BYTE()` function, therefore, it converts between ASCII and EBCDIC as needed.  For example, `BYTE('a')` returns 0x81 (the EBCDIC code for 'a') rather than 0x61 (the ASCII code for 'a').  Similarly, a usage like `BYTE(s, 2, b)` that replaces the string character `s[2]` by the character with byte-value `b`, expects `b` to be an EBCDIC code.  For example `BYTE('hello', 2, 0x81)` returns `'healo'`.

# Mysteries and Inferences

There's a reasonably-significant amount of syntax in the XPL source code that's not documented (as far as I can tell).  Some is not that obvious, and my guesses are quite suspect.  It's those suspicious cases I'll cover here.

## Changes to Parameter Values Within Procedures

XPL documentation explicitly states [McKeeman section 6.14]:

> All parameters are called by value in XPL, hence assignments to the corresponding formal perameter with the procedure definition have no effect outside the procedure.  To pass values out of a procedure, one must either use the <return statement> or make an assignment to a global variable.

Alas, the creators of XPL didn't reckon with the ability of the Shuttle's coders to exploit undocumented holes (or perhaps deliberate divergence from the definition of XPL) in the XPL compiler.  Formal parameters which are strings are apparently passed by reference in the Intermetrics/United Space Alliance version of the XPL compiler, and the source code for HAL/S-FC exploits this by allowing strings passed by formal parameters into a procedure to be altered by the procedure, and for those changes to be visible by the calling code.  An example is the PASS1.PROCS/PRINT2 module, which alters its formal string parameter `LINE`.

In fact, most (or all) calls to `PRINT2` pass `LINE` parameters that are string expressions or literals, rather than strings stored in variables, so the adjustments to `LINE` made by `PRINT2` are *not* changing strings stored in variables, but rather changing strings that had better not be changed.

But see also the next two sections.

## Persistence and Initialization of Local Variables Within Their Parent Procedures

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

## Absence and Persistence of Parameters of Procedures

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

## Dynamic Memory Allocation: `BASED` and its Macros

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

A function like `ALLOCATE_SPACE(MACRO_TEXTS, n)` would produce a python list like:

MACRO_TEXTS = [macro_texts(0), macro_texts(0), ...]

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

## PASS vs BFS Conditionals

It appears as though there must have been some parameter supplied to the compiler to determine whether compilation was for PASS (PFS) or whether it was for BFS, and there were conditionals that looked like this:
<pre>
/?P
    ... include whatever's in here if compiling for PASS ...
?/
/?B
    ... include whatever's in here if compiling for BFS ...
?/
</pre>

I handle this with CLI switch `--bfs`.  If used, then the internal variable `pfs=False`, but by default `pfs=True`.  These facts are used to create the conditional Python code corresponding to the conditional XPL code.

## TIME, DATE, etc.

There are XPL "implicitly declared" functions and variables that are always available (see Table 6.9.1 in "A Compiler Generator").
To the extent needed, these are replaced by Python functions and variables of the same name.

However, some of these implicit "variables", such as `TIME` and `DATE`, are supposed to have different values every time they are accessed.  For example, `TIME` is the number of centiseconds elapsed since midnight (timezone unspecified).  I don't think there's any satisfactory way to implement this in Python while retaining the same syntax, so `TIME`, `DATE`, and presumably other such "variables", are instead implemented as Python functions:  in this case, `g.TIME()` and `g.DATE()`.

## Semicolons

XPL requires semicolons at the ends of statements.  Python does not, but it *allows* semicolons to delimit multiple statements written on a single line, and thus is tolerant of them.  I didn't know that, and removed many in the porting process before discovering it.  The upshot is that I've tended to leave the semicolons in place, just because it's easier for me, but I did remove a number of them before realizing it was legal in Python to keep them.  I may end up eventually removing them after all, simply because it's not really a Python thing to keep them.

## Partitioned Data Set (PDS)

There seems to be a concept of two different types of files used by the compiler system:  "sequential files" and "partitioned data sets" (PDS).  The sequential file is just what it sounds like. 

A PDS apparently consists of member chunks, of variable sizes, with each chunk accessible via a unique member name that's exactly 8 characters long (padded with spaces if necessary).  This is a concept built into IBM's z/OS operating system.  Each such PDS must therefore have an associated index that can associate member names with offsets into the PDS.  Chunks can be read, written, or replaced, presumably therefore capable of dynamic changes in size.

How IBM chose to implement the PDS concept is irrelevant to us, and I can implement it however I choose.  Because whatever concerns IBM originally had about execution speed and efficient disk storage are essentially meaningless 50+ years later, I can use whatever method I deem quickest in getting me to workable, maintainable code.  If you don't like it ... tough!

My choice is this:

  * While in use, each PDS is fully buffered in compiler memory, in the form of a Python dictionary.  The dictionary keys are the member names, and the values associated with the keys are whatever is convenient for the purpose of porting the specific PDS.
  * The storage of the PDS as a file is in the form of a JSON representation of the dictionary.

As far as reading from a PDS is concerned, the technique is first to find the member of the PDS you're interested in via `MONITOR(2,DEV,MEMBER)`.  You then read that member line-by-line using INPUT(DEV).  Evenually INPUT(DEV) returns an empty string to indicate the end of the member.  (That can't be right, since the member could actually contain some empty lines, presumably, but I haven't been able to find anything to indicate a different approach.)

## Equivalence of Arrays and Non-Arrays

XPL, as documented according to my understanding, has the basic datatypes of 32-bit integer (**FIXED**) and string (**CHARACTER**), as well as bit-arrays (**BIT**).  Besides which, you can have 1-dimensional arrays of these basic datatypes.

> Fun fact:  If you want, say, a 10-elmement array called `MYARRAY` of integers, you'd define it with the statement `DECLARE MYARRAY(9) FIXED;`.  Notice that you use a 9 rather than a 10.  You'll be particularly amused the 50th time you've had to correct the size of a declared array. I presume that what you're specifying here is not the size of the array, but the maximum subscript, which is one less than the size, since the indices start at 0.  I presume this feature was inherited from PL/I, in which you can declare both the starting and ending indices of an array, using a syntax like `DCL MYARRAY(0:9)`, which makes sense *in PL/I* because the starting index isn't always fixed at 0 the way it is in XPL. But I digress!

Another fun fact that isn't documented in XPL, but which may be an innovation by the XPL compiler-writers that the authors of XPL itself didn't intend, is that you can completely ignore the array bounds, using negative indices or positive indices greater than the declared maximum to just access whatever happens to be nearby in memory.  Not only that, but you can even ignore whether or not the variable was declared as an array or not!  Consider the following declarations:
<pre>
    DECLARE A FIXED;
    DECLARE B(5) FIXED;
</pre>
If you like, you can just use `B` in your code, without an index even though it's declared as an array, and it will automatically be interpreted as `B(0)`.  In this example, `B[-1]` would access `A`.  Or you can use `A` *with* an index even though it's not an array.  In this example, `A[1]` would access `B[0]`, `A[2]` would access `B[1]`, and so on. 

And make no mistake, whoever coded the HAL/S compiler in XPL *did* like to do this, though fortunately not too often.  Mostly just when you don't expect it and spend a while tearing your hair out trying to figure out what's going on.



