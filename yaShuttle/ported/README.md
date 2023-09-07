# Introduction

My plan for this folder (ported/) is to explore the idea of porting a portion of the original HAL/S-FC compiler from its XPL language form to the Python 3 language.

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

Additionally, many variables, constants, and macros defined in PASS1.PROCS/##DRIVER.xpl are expected to be within scope for other XPL source-code files.  These definitions (and presumably some from files other than ##DRIVER.xpl) are collected in a Python module ported/g.py that must be imported by all other Python files partaking of that scope.  Those global objects, originally having names like `NAME` would thus be accessed in Python with names like `g.NAME`.

In addition to the usual alphanumeric and underline characters, identifiers in XPL can include the characters '@', '#', and '$', which are not allowed in Python identifiers.  However, it so happens that all of the original HAL/S-FC source code contained only upper-case characters when alphabetic.  Therefore, I use the uniform system of replacing disallowed characters in identifiers as follows:

  * '@' -> 'a'
  * '#' -> 'p'
  * '$' -> 'd'

For example, the global variable `MAXR#` becomes `g.MAXRp`.  But that's a worst case.  Any local variables not containing these funny characters would simply retain the same names in Python as they originally had in XML.

# Mysteries and Inferences

There's a reasonably-significant amount of syntax in the XPL source code that's not documented (as far as I can tell) in XPL, HAL/S, or PL/I documentation, most of which is pretty easy to figure out.  Some is not that obvious, and my guesses are quite suspect.  It's those suspicious cases I'll cover here.

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

To preserve the dotted notation, I implement `BASED ... END` blocks as an array of Python class objects.  Unfortunately, this requires both a `class` name and a separate array name, so I use the lower-case form of the identifier as the `class` name:

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

However, some of these implicte "variables", such as `TIME` and `DATE`, are supposed to have different values every time they are accessed.  For example, `TIME` is the number of centiseconds elapsed since midnight (timezone unspecified).  I don't think there's any satisfactory way to implement this in Python while retaining the same syntax, so `TIME`, `DATE`, and presumably other such "variables", are instead implemented as Python functions:  in this case, `g.TIME()` and `g.DATE()`.

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

## Negative Array Indices

What do they mean?  There are a few of them.  No explanations.  I'm at a loss.
