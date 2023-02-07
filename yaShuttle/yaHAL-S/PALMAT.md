# Introduction

The "modern" HAL/S compiler's first phase (preprocessing + tokenizating + parsing) concludes with the generation of code in a target-independent intermediate language I call *PALMAT*.  Subsquent compiler phases may then perform machine-independent optimizations on the generated PALMAT and/or convert it to some efficient form for execution (such as a C-language program), or an emulator in the form of a PALMAT virtual machine may directly execute it as-is.

The original HAL/S compilers of the Space Shuttle development effort, HAL/S-360 and HAL/S-FC, had this same overall structure, except with an intermediate language they called *HALMAT*.  I would be happy to be using HALMAT as the intermediate language for the modern assembler, except that (at this writing) there's simply not enough surviving detailed documentation of HALMAT to do so.  My attempt to reconstruct HALMAT from the surviving documentation ultimately failed, but you can read about it [here](HALMAT.md).

So unfortunately, I'm left to reinvent the wheel.  On a positive note, what I was able to learn about HALMAT didn't seem all that user-friendly, and perhaps *PAL*MAT will be slightly friendlier.

# Some Basic Principles

Because of the limitations of memory and CPU speed back in the day, HALMAT was designed with certain contraints aimed at efficiencies we no longer have to worry about as much.  All HALMAT instructions ("operand words") were exactly 32 bits wide, as were all HALMAT "operand words", and each of them consisted of an elaborate collection of bit-fields.  Data, except for certain small datatypes like 16-bit integers or 16-bit bit-arrays, were of necessity stored in tables which the operand words accessed via pointers.

Since the PALMAT-generation portion of the modern HAL/S compiler, which will include an optional interactive PALMAT interpreter, are in the Python language, PALMAT instructions can be considered instead as relatively-friendly Python objects ("dictionaries"), and data can be included directly within PALMAT instructions in many cases rather than being separated from them.  

But these abstract points will probably become clearer when details of PALMAT are discussed below.

# PALMAT Character Set

Because of the difficulty of dealing with non-ASCII character sets in the preprocessor and compiler software, as well as certain discrepancies between the theoretical specification for HAL/S and its actual usage, some characters in the extended HAL/S character set are automatically translated to 7-bit ASCII characters for internal usage in the preprocessor, compiler, interpreter, and external-file representations of PALMAT.  Those translations are:

    ¬   &rarr;   ~
    ^   &rarr;   ~
    ¢   $rarr;   `

The reverse translations (~ &rarr; ¬ and ` &rarr; ¢) may be performed for printouts or other display purposes, if desired. 

Internally within PALMAT, the ^ character is used for quoting all text strings, resulting in there being three flavors of text strings (^...^, ^'...'^, and ^"..."^) used for different purposes.  Moreover, the backslash character (\) does not appear in the PALMAT character set, but is used in most modern software for test escape sequences, hence it would be awkward to allow it as a PALMAT character.

The net result of all this is that the PALMAT character set is entirely 7-bit ASCII (with no *printable* characters left over aside from the backslash).  However, this is transparent to the user, and any legal HAL/S extended characters (in UTF-8 where necessary) can continue to appear in HAL/S source code.  However, the alternatives ~ and ` may be used in source code as well.

# PALMAT File Format

A PALMAT dataset comprising the compiled form of a HAL/S program or portions of HAL/S programs is, as mentioned, stored in the modern compiler and/or interpreter, which are written in Python, as a Python "dictionary".  

For example, the dictionary might have the name `MyProgram`, and might be almost empty, perhaps:

    MyProgram = {
        "SymbolTable" : {},
        "Instructions" : []
    }

(This is just an illustration, written in advance of implementation to demonstrate file formatting, so I don't claim that this is *actually* what the structure would look like.  In fact, as you will see in the next section, it certainly is *not*.  But that doesn't affect the principles being discussed here.)

Since JSON is a common format for exchanging complex data of this nature, `MyProgram` would be saved to an external file (say, "MyProgram.palmat") by the simple expedient of converting it to JSON (which is a text string), and then saving the JSON to the file:

    import json
    f = open("MyProgram.palmat", "w")
    print(json.dumps(MyProgram), file=f)
    f.close()

The result of this operation would be a file MyProgram.palmat that (surprise!) looks like:

    {"SymbolTable": {}, "Instructions": []}

MyProgram.palmat could subsequently be read by some other Python program, and the associated dictionary (say `SavedProgram`) could be constructed by commands like:

    import json
    f = open("MyProgram.palmat", "r")
    SavedProgram = json.loads(f.readline())
    f.close()

While the steps for reading in this file would differ in detail in program languages other than Python, it would still be simplicity itself in any programming language having an available library for reading JSON.  Certainly that's true in C or JavaScript, but I suppose it's probably true of a great many programming languages.  On the other hand, the internal data structures one might wish to use in a C emulator are undoubtedly very different than those provided by whatever library reads the JSON description, whereas in Python the internal data structures and the as-saved data structures are identical.

# Structure of a PALMAT Dictionary

Throughout this section, I'll assume that the Python dictionary generated by compiling our HAL/S source code is simply called `PALMAT`.  All indexes into lists start from 0.

Here is the essential layout of a PALMAT dictionary:

    PALMAT = {
        "scopes" : [ ... ],
        ... less-essential items ...
    }

## The Scopes

The "scopes" array is the memory model, incompassing all identifiers used by the code, such as variables and user-defined function names, as well as the code itself. Each individual scope in the array is the memory model for a specific HAL/S block.  Those include:  

* Top-level blocks (i.e., those which end with a `CLOSE` statement), such as `PROGRAM`, `FUNCTION`, `PROCEDURE`, ....
* `DO ... END` blocks, including not only simple blocks of statements, but also `DO WHILE`, `DO UNTIL`, and `DO FOR` blocks.
* `IF THEN` and `IF THEN ELSE` statements.

The compiler assigns these scopes unique sequence numbers, starting from 0, as it encounters them, and then appends the scope for that block to `PALMAT["scopes"]`.  `PALMAT["scopes"][0]` is the top-level scope.

Each individual scope is itself a dictionary, and provides links to both the scope of its parent block and to any immediate child blocks.  The code within any HAL/S block has access to the objects declared within its own scope, including temporaries, as well as the objects of the parent, grandparent, and so on, but not the child blocks.

    anyIndividualScope = {
        "type": "...",              # A string describing the "type" of scope.
        "parent" : ...,             # The integer index of the parent scope within PALMAT["scopes"], or else None if top level.
        "self" : ...,               # The integer index of this scope within PALMAT["scopes"].
        "children" : [ ... ],       # List of integer indices of immediate child scopes within PALMAT["scopes"]
        "identifiers" : { ... },    # The identifiers declared in the current block, keyed by their names.
        "instructions" : [ ... ]    # The PALMAT instructions for the block.
    }

The `type` can be things like "root", "unknown", "if", or "do", but the significant types are really "do while", "do until", and "do for".  That's because the *raison d'être* of the `type` key is enabling searches starting from a given scope upward in the scope hierarchy to determine if the scope is contained within a loop.  Thus, a search is made upward, by means of the `parent` keys, until a "do while", "do until", or "do for" is reached.  That *that's* important for code-generation of HAL/S statements like `EXIT` and `REPEAT` that break out of blocks.

Other keys may be present as well for various *ad hoc* purposes, but these are the common ones.

Note that the entire `PALMAT` object, including `PALMAT["scopes"]`, is formed at compile time.  The logical memory model is not dynamic.  Its structure does not change at runtime.  Only *values* stored in variables (in the "identifiers" dictionary) change at runtime, but the structure of the model is unalterable.

By the way, notice that because the code ("instructions") for a block such as a `DO FOR` are segregated in a different scope from that of the block containing it, the PALMAT code in the parent block treats the code in such a sub-block much like a procedure call, in that it has an instruction to jump to the sub-block, and the exit from the sub-block is going to be a jump back to the parent block.  Yes, there's a slight inefficiency associated with this scheme, though it can be removed in optimization if desired.

Regarding the elements of the identifiers dictionary, i.e. the variables, constants, nested function definitions, and so on, their most important properties vary by type.  For variables, these are the descriptions of their datatypes and their stored values.  Other, lesser, characteristics may appear in their dictionaries as well.

Consider the following simple HAL/S code:

    MYPROGRAM: PROGRAM;
        DECLARE I INTEGER INITIAL(1), X SCALAR;

        MYFUNCTION: FUNCTION(A, B);
            DECLARE INTEGER A, B;
            DECLARE Y SCALAR;

            ...

        END MYFUNCTION;

        ...

    CLOSE MYPROGRAM;

I'm writing this in advance of implementation, so I'm speculating a bit, but here's what `PALMAT["scopes"]` might look like for this code:

    PALMAT["scopes"] = [
        {
            "parent" : None,        # This is the top level, so there is no parent scope.
            "self" : 0,             # Own index into PALMAT["scopes"].
            "children" : [1],       # There is a single child, the MYPROGRAM program.
            "identifiers" : { 
                "MYPROGRAM" : {
                    "program" : True,
                    "index" : 0,    # Index of its starting location in the "code" array
                }
            }
            "instructions" : [ ]    # There are no global PALMAT instructions ... maybe.
        },
        {                       # This is MYPROGRAM.
            "parent" : 0,
            "self" : 1,
            "children" : [2],   # The only child is MYFUNCTION.
            "identifiers" : {
                "I" : {
                    "integer" : True,
                    "value" : 1
                },
                "X" : {
                    "scalar" : True,
                    "value" : None 
                },
                "MYFUNCTION" : {
                    "function" : True,
                    "index" : ...,
                    "parameters" : ["A", "B"]
                }
            }
            "instructions" : [ ... ]
        },
        {                       # This is MYFUNCTION
            "parent" : 1,
            "self" : 2,
            "children" : [],
            "identifiers" : {
                "A" : {
                    "integer" : True,
                    "value" : None,
                    "parameter" : True
                },
                "B" : {
                    "integer" : True,
                    "value" : None,
                    "parameter" : True
                },
                "Y" : {
                    "scalar" : True,
                    "value" : None
                }
            }
            "instructions" : [ ... ]
        }
    ]

Notice the extra keys `"parameter"` for variables `B` and `Y`.  I don't know whether these will exist after implementation, but I've thrown them in here as examples of additional metadata that can be provide by the memory model.  In this case, they're intended to indicate that the variables in question are parameters of the `MYFUNCTION` function, and hence there may be limitations on what can be done with them that wouldn't apply to normal declarations.

As an example of usage, imagine that `MYFUNCTION()` were called during code emulation, there would be a PALMAT instruction upon entry to the `MYFUNCTION` block that set the current block number to 2, perhaps setting some variable in the emulator virtual machine like so: `scope = PALMAT["scopes"]`.  Once `scope` is available, the entire hierarchical memory model accessible by the block is not fully set up.  

Actually, that's not *entirely* true, since in a HAL/S declaration like 

    DECLARE I INTEGER INITIAL(1);

the initialization is performed only the first time that position in the code is reached, and not on each occasion the block containing the declaration is entered.  In analogy to the C language, all variables declared in functions or procedures are by default `static`, and retain their last values from one invocation of the function or procedure to the next.  In HAL/S, if you wanted the initialization to occur upon each entry (to be non-`static` in a C sense), you'd instead say

    DECLARE I INTEGER INITIAL(1) AUTOMATIC;

Thus the emulator would have to perform a little more work upon entry to such a block than just setting `scope` properly.

**Note:** Regarding the so-called `TEMPORARY` variables:  Although the documentation fusses over them as if they were something special, to the point of making it seem tricky to implement them, in fact at execution time `TEMPORARY` is just a drop-in replacement for `DECLARE`.  The distinction is entirely syntactical, in that you can only use `DECLARE` in blocks that end with `CLOSE`, whereas you can only use `TEMPORARY` in blocks that end with `END`.  (Well, and there's an extra way to declare temporary integer variables with `FOR TEMPORARY I=... END` vs `FOR I=... END`.)  However, given our underlying model of scopes, there's actually no distinction at all between temporary and non-temporary variables at runtime.  A `TEMPORARY` variable is merely a variable whose scope happens to be a `DO ... END` block rather than (say) a `PROGRAM` or `FUNCTION` block.

## Automated Labels Within Scopes

For maneuvering within and between scopes, certain types of symbolic labels for certain roles within the scopes are very-commonly needed, and it is necessary for the code-generator to be able to create them systematically on the fly in order to effectively use the scopes.  The techique for doing so is to create labels is usually according to the following pattern,

    xx_N

where `xx` is a prefix that defines the role in a way which is in common among all the scopes, and `N` is the scope index.  There are, however, a couple of exceptions in which the pattern is instead

    xx_N_M

where `N` and `M` are two different scope indices.

This is all transparent to the HAL/S coder, of course, since these labels appear only in PALMAT and not in HAL/S source code.

All of the `xx` prefixes are lower-case alphabetic, which make the generated labels unlikely to be coincide with labels in actual HAL/S flight software ... but not *impossible*.  I may later change the pattern to something for which collisions are actually impossible to being syntactically impossible in HAL/S, such as `N_xx`; but that would have the disadvantage (for debugging purposes) of not being able  explicitly use these labels in the HAL/S interactive interpreter, so I'll leave them this way for now.  Later that may be changed.

The patterns currently in use are:

* `ue_N`.  This is the entry point (i.e., the very first PALMAT instruction) of scope `N`, at which the code generator typically places a `NOOP` instruction (see the PALMAT instructions as defined below) with this label.  The identifier, however, is defined in the namespace of the parent scope rather than in scope `N` itself.
* `ur_N`.  This is the label (in namespace of the parent scope) of the automatic return to the parent when the end of scope `N` is reached.
* `ux_N`.  This is the label (in the namespace of scope `N`) of the end of the scope, at which the code-generator typically places a `NOOP` PALMAT instruction with this label.  In looking at this, it seems to me that I could always just leave out this label and this `NOOP` instruction, and instead just jump directly to `ur_N` (see the `ur_N` entry above); well, I'll leave that for the future.
* `up_N`.  In a loop (`DO WHILE`, `DO UNTIL`, `DO FOR`) this is the label near the top of the block to which the block jumps to start the next iteration, after having reached the end of the block.
* `uf_N`.  In an `IF THEN ELSE`, this is the label of the `ELSE`, to which we jump when `IF`'s conditional is false.

These labels will not all necessarily be present in the identifier list, since they won't all necessarily be used in any given scope.

## PALMAT Instructions and the Computation Stack

In the final implementation, PALMAT instructions will very likely be encoded numerically in some format intended to efficiently reduce the storage required for storage of the executable and decoding of the instructions by the PALMAT virtual machine executing the code.  However, I don't want to get ahead of myself:  Let's just get it working logically correctly before worrying about efficient storage formats, shall we?

Since the bulk of my HAL/S compiler is in Python and the file-format being used is a JSON version of the Python structures, for *now* PALMAT instructions will be represented as Python dictionaries.

Also, any of the PALMAT instructions listed below optionally have a key `label` whose value is a unique string, and indicates that the instruction is the target of some kind of control-transfer instruction. 

Before presenting any actual PALMAT instructions, let me add that for computation of expressions (arithmetical, boolean, or otherwise), the PALMAT virtual machine implements an computation-stack based model, such as found in a Reverse Polish Notation (RPN) calculator or in the FORTH computer language.  Therefore, the behavior of PALMAT instructions is often to pop values from this computation stack, perform some computation on them (such as addition), and then to push the result back on the computation stack.  Each entry of the computation stack can thus hold values of various types.

Regarding the format of entries on the computation stack, this can (and for efficiency *should*) be implementation-dependent.  But as for the Python-based emulator that executes PALMAT instructions directly, we can take advantage of Python's ability to determine the datatype by its own examination of the values, rather than having to invent some (likely more-efficient) implementation at the cost of efficient execution.  So what's on the computation stack in this specific implementation can be:

* Any Python integer or floating-point number.
* Any Python character string.
* A tuple embedded in a list, `[(value, numbits)]`, where both `value` and `numbits` are integers, is used to represent a HAL/S bit array.  The special case of `numbits`=1 is for a HAL/S `BOOLEAN`.  In computation, bit arrays act basically like integers, but without a `numbits` to determine the array size, `NOT` operations cannot work correctly.
* Any Python list of floats or integers (for HAL/S `VECTOR` types) or rectangular list of lists of floats or integers (for HAL/S `MATRIX` types).
* Any Python dictionary for HAL/S `STRUCTURE`s.
* Any Python rectangular tuple of tuples of ... tuples, other than the special case for bit arrays listed above, for an `ARRAY`.  The carve-out for bit arrays means that this implementation doesn't fully allow an `ARRAY` of dimension 1&times;2.
* The Python `None` is for an unitialized value in a PALMAT instruction `fetch`, `store`, or `storep`.  It is not supported in arithmetical operations.
* Python sets, to which there's no corresponding datatype in HAL/S can appear on the computation stack as well:
    * `{ 'sentinel' }` is used to mark the beginning of a variable-length list of operands.  (There is rarely any need for such a thing, but it is used to begin a list of subscripts.)
    * `{ 'fill' }` can appear, under certain circumstances, as the final operand in a flattened list of values such as is generated for an `INITIAL` or `CONSTANT` clause in a `DECLARE` statement, or in a "shaping function" like `VECTOR()` or `MATRIX()`.  It indicates that the remaining items in the composite object being created are uninitialized.

### PALMAT Instructions 1: Arithmetic

With that in mind, here's a description of some of the available PALMAT instructions.

* `{'number': string}`, where `string` is a stringified version of a number such as 1.35E13B2.  (At some point, I may change this so that `string` is replaced by the actual Python representation of the number, but for now I don't go that far because this method preserves exact values.)  **Recall** that in HAL/S, the minus sign is an operator, and not a character that can prefix a number token, so these numbers are all non-negative.  The action of this instruction at runtime is push the number (*as* a number and no longer as a string) onto the computation stack
* `{'operator': '+'}`.  The action of this instruction at runtime is to pop the last two numbers from the computation stack, add them, and then to push the result back onto the computation stack.  The computation stack is thus shortened by one element.
* `{'operator': '-'}`.  This is a binary minus operator, as opposed to a unary negation operator.  The action at runtime is to pop the final two elements from the computation stack, subtracting the 2nd-to-last value from the last value, and then to push the result back onto the computation stack.
* `{'operator': 'U-'}`.  This is unary negation operator.  The action at runtime is to arithmetically negate the last value on the computation stack.  Thus the computation stack does not change in size.
* `{'operator': ''}`.  This is the multiplication operator.  The action at runtime is to pop the last two values from the computation stack, multiply them, and then push the result back onto the computation stack.
* `{'operator': '/'}`.  This is the division operator.  The action at runtime is to pop the final two elements from the computation stack, dividing the last value by the 2nd-to-last value from the last value, and then pushing the result back onto the computation stack.
* `{'operator': '**'}`.  This is the exponentiation operator.  The action at runtime is to pop the final two elements from the computation stack, raising the last value to the power of the 2nd-to-last value, and then pushing the result back onto the computation stack.
* `{'fetch': (index, identifier)}`, where `identifier` is the identifier (*sans* carat quotes), typically a variable or constant, and `index` is the index (in `PALMAT["scopes"]`) of the scope in which the identifier was found.  If `index`==-1, it means that the variable is in the `ASSIGN` list of the enclosing `PROCEDURE` and must be replaced by the corresponding variable from the `ASSIGN` list of the `CALL`. The action at runtime is to fetch the value of the variable or constant identified and push it onto the computation stack.
* `{'store': (index, variable)}`, where `variable` is the name of a variable (*sans* carat quotes) and `index` is the index (in `PALMAT["scopes"]`) of the scope in which the variable was found.  The value to store is at the top of the computation stack, and it is *not* automatically popped.  Thus allows multiple `store`s of the same value.  See the `pop` and `storepop` instructions later.  See also the `substore` and `substorepop` instructions later, for use when the variable being stored is subscripted.
* `{'pop': number}`.  Pops `number` of elements from the computation stack and discards them.

More PALMAT instructions will be defined below, but first let's consider a couple of example.  Look at the following HAL/S code:

    DECLARE SCALAR, A, B, C;
    A, B, C = 6 ( 2 / (3 + 5) - 7 );

The PALMAT instructions generated from the latter statement are shown below, accompanied by the runtime evolution of the computation stack (growing rightward) as each PALMAT instruction is executed.

    PALMAT Instruction                  computation stack Afterward
    ──────────────────                  ─────────────────────────
                                        (empty)
    {'number': '7'}                     7
    {'number': '5'}                     7, 5
    {'number': '3'}                     7, 5, 3
    {'operator': '+'}                   7, 8
    {'number': '2'}                     7, 8, 2
    {'operator': '/'}                   7, 0.25
    {'operator': '-'}                   -6.75
    {'number': '6'}                     -6.75, 6
    {'operator': ''}                    -40.5
    {'store': 'C'}                      -40.5
    {'store': 'B'}                      -40.5
    {'store': 'A'}                      -40.5
    {'pop': 1}                          (empty)

The final result is thus that each of the `SCALAR` variables `A`, `B`, and `C` is assigned the numerical value -40.5.

Or consider this example:

    DECLARE SCALAR, A, B, C;
    B = 2;
    C = 5;
    A = 12 C**2 + 3 B + 1;

    PALMAT Instruction                  computation stack Afterward
    ──────────────────                  ─────────────────────────
                                        (empty)
    {'number': '2'}                     2
    {'store': 'B'}                      2
    {'pop': 1}                          (empty)
    {'number': '5'}                     5
    {'store': 'C'}                      5
    {'pop': 1}                          (empty)
    {'number': '1'}                     1
    {'fetch': 'B'}                      1, 2
    {'number': '3'}                     1, 2, 3
    {'operator': ''}                    1, 6
    {'number': '2'}                     1, 6, 2
    {'fetch': 'C'}                      1, 6, 2, 5
    {'operator': '**'}                  1, 6, 25
    {'number': '12'}                    1, 6, 25, 12
    {'operator': ''}                    1, 6, 300
    {'operator': '+'}                   1, 306
    {'operator': '+'}                   307
    {'store': 'A'}                      307
    {'pop': 1}                          (empty)

Thus we end up with `B=2`, `C=5`, `A=307`.

### PALMAT Instructions 2: Output

Here's another PALMAT instruction pertaining to output:

  * `{'write': lun}` marks the *end* of the PALMAT corresponding to a HAL/S statement of the form `WRITE(lun) ...`.  The only logical unit number understood by the interpreter is `lun=6`, which is output to the console from which the interpreter commands and HAL/S statements are being input.  The instruction outputs every value on the computation stack, in FIFO order (not LIFO stack order), and then clears the stack.  If there is nothing at all on the computation stack, then just a line-feed is printed.

The full form of a HAL/S `WRITE` statment is

    WRITE(lun) Expression1, Expression2, ..., ExpressionN;

where the expressions can be of any sort:  arithmetical, character, boolean.  *Preceding* the PALMAT `write` instruction will be PALMAT instructions of the kind we've already seen for computing the values of expressions, as well as any other PALMAT instructions we haven't already defined for computing boolean or character expressions.  The result of all of these computations is to leave a sequence of values (arithmetical, boolean, or character) on the expression stack, one for each of the expressions in the HAL/S statement, with the value of the first expression being the last pushed onto the stack and the final expression being the first value pushed onto the stack.  The `write` PALMAT instruction just pops these values off of the expression stack one-by-one and prints them all on the same line of the terminal, with a trailing newline, leaving the expression stack empty at the end of the operation.

For example, here are some PALMAT instructions appropriate for `WRITE(6) A+5, A**2+1, 12 A;`:

	{'fetch': 'A'}
	{'number': '12'}
	{'operator': ''}
	{'number': '1'}
	{'number': '2'}
	{'fetch': 'A'}
	{'operator': '**'}
	{'operator': '+'}
	{'number': '5'}
	{'fetch': 'A'}
	{'operator': '+'}
	{'write': '6'}

### PALMAT Instructions 3: Character Expressions and Built-In Functions

* `{'string': s}` pushes string `s` onto the expression stack.  Note that a string, however many characters it contains, is an atomic object occupying a single position on the stack.  (It does *not*, for example, require a separate stack position for each character.)  Strings placed on the stack in this manner can then subsequently be used (for example) in `WRITE` operations, can be stored in variables, etc.
* `{'operator': 'C||'}` is the string-concatenation operator.  It pops the top two elements from the stack, which must be strings.  The string that had been the 2nd-from-the-top is concatenated to the end of the string that had been at the top of the stack, and then the full string is pushed back onto the top of the stack. 
* `{'function': f}` calls the HAL/S built-in function called `f`.  For example, `{'function': 'ABS'}` or `{'function': 'RANDOM'}`.  These functions are outlined in Appendix A of the HAL/S Language Specification.  Here are some notes about the PALMAT implementation of specific built-in functions which the documentation describes as implementation-dependent:
    * `CLOCKTIME`.  TBD
    * `DATE`.  TBD
    * `RUNTIME`.  This is the elapsed floating-point number of seconds, nominally with nanosecond resolution,from the point at which the software run began.  (This is consistent with the statements on p. 13-15, PDF p. 170, of the 2005 version of the HAL/S Programmer's Guide.)

### PALMAT Instructions 4: Transfer of Control

* `{'goto': [index,n]}` or `{'goto': (index,s)}` transfers control to integer position `n` in the PALMAT-instruction list for the scope with integer index `index`, or else to the accessible (scope-wise) PALMAT instruction having a `"label" : s` key-value pair in scope `index`. It is expected that the latter form is the as-compiled form, but that for efficiency purposes, the virtual machine executing PALMAT code would replace the latter form by the former, either upon start or else progressively as execution proceeds.
* `{'boolean': t}` where t is True or False.  This instruction pushes the indicated boolean value onto the expression stack.
* `{'operator': 'NOT'}`. Logically negates the top of the stack.
* `{'operator': 'AND'}`. Pops the top two elements from the stack, logically ANDs them, and pushes the result onto the stack.
* `{'operator': 'OR'}`. Pops the top two elements from the stack, logically ORs them, and pushes the result onto the stack.
* `{'operator': 'B||'}`. Pops the top two elements from the stack, logically concatenates them, and pushes the result onto the stack.
* `{'operator': 'ORNOT'}`. Pops the top two elements from the stack, logically OR's the top of the stack with the negation of the next-to-top, and pushes the result onto the stack.
* `{'operator': '=='}`. Pops the top two elements from the stack, tests for equality, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '!='}`. Pops the top two elements from the stack, tests for inequality, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '<'}`. Pops the top two elements from the stack, tests if the top is less than the next-to-top, and pushes the boolean result of the comparison onto the stack. 
* `{'operator': '>'}`. Pops the top two elements from the stack, tests if the top is greater than the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '<='}`. Pops the top two elements from the stack, tests if the top is less than or equal to the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '>='}`. Pops the top two elements from the stack, tests if the top is greater than or equal to the next-to-top, and pushes the boolean result of the comparison onto the stack.
boolean result of the comparison onto the stack.
* `{'noop': True }`.  A no-op.  It is used primarily for forward-defining the location of a label when the compiler isn't yet aware of the actual PALMAT instruction at that location due to lack of lookahead.  This occurs primarily for unique labels generated by the compiler itself to mark the ends of `IF ... THEN ... ELSE`, `DO WHILE ... END`, and so on.  Machine-independent optimization of the PALMAT instructions can therefore remove the `noop` and transfer the `noop`'s `"label"` key to the next instruction.
* `{'iffalse': (index,s)}`.  Pops entry from expression stack and if False performs equivalent of a `{'goto': (index,s)}`.
* `{'iftrue': (index,s)}`.  Pops entry from expression stack and if True performs equivalent of a `{'goto': (index,s)}`.
* `{'debug': string}`.  These instructions are ignored during execution, and are useful for inserting debugging information.
* `{''+><': (index, X)}`.  In contrast to all of the PALMAT instructions discussed so far, which are intended to be used as simple building-blocks for more-complex operations, the present instruction is provided for use with HAL/S code of the form `DO FOR [TEMPORARY] X = Y TO Z BY T; ... END;`.  It is used to perform the update `X = X + T` and then to determine whether this new value of `X` has "exceeded" `Z`.  The latter is tricky because it's equivalent to `X + T > Z` if `T` is itself positive, but it's equivalent to `X + T < Z` when `T` is negative.  Of course, this *could* all be programmed using the simple building-block instead, but it's quite cumbersome to do so.  Specifically, how the `+><` instruction works is as follows:  It assumes that Z is the 2nd entry from the top of the stack, while `T` is at the top of the stack.  It performs the equivalent of the PALMAT instructions `{'fetch': X}`, `{'operator': '+'}`, and `{'store': (index,X)}`. Recall that this would leave `Z` and `X`+`T` at the top of the stack.  Depending on whether `T` had been positive or negative, it then performs the equivalent of either the PALMAT instruction `{'operator': '>'}` or `{'operator': '<'}`, respectively.

## PALMAT Instructions 5: Subroutine Linkage

* `{ 'call': (index, label), 'assignments': {...} }`.  Calls a subroutine (`FUNCTION` or `PROCEDURE`) supplied as PALMAT (i.e., compiled from HAL/S source code), as opposed to a built-in library function.  The details of subroutine linkage are described in the text below.  The `assignments` appears only for `PROCEDURE`s
* `{ 'return': N }`, returns from a `PROCEDURE` (`N`=1) or a `FUNCTION` (`N`=2).
* `{ 'run': (index, label) }`.  Runs a `PROGRAM`. 
* `{ 'storepop': (index, variable) }`.  Combines a PALMAT `{ 'store': (index, variable) }` instruction with a `{ 'pop': 1 }` instruction.  Thus it not only stores the value at the top of the computations stack into the identified variable, but also pops the value from the computation stack afterward.  See also the `substorepop` instruction later.

For `CALL`s, the return address of the subroutine being called is stored in the `RETURN` key of the subroutine's scope.  This is done automatically by the `CALL` instruction itself, and is not of concern for PALMAT code generation.  Similarly, the `RETURN` instruction uses this return address and pops the `RETURN` key from the scope.  This scheme by itself supports only single-threaded operation (recall that HAL/S does not allow recursivity); refer to the section on reentrancy and multiprocessing for an explanation of how this method of handling return addresses relates to that topic.

### `FUNCTION` Specifics

Regarding the passage of input parameters and return values, suppose that a `FUNCTION has `N` parameters `X`<sub>1</sub> through `X`<sub>`N`</sub>.  Recall that a child scope of the parent scope in which the `FUNCTION` is defined is created to hold the `FUNCTION`'s PALMAT code and identifiers. 

When a `FUNCTION` is called at runtime, the expression stack is arranged as follows upon entry to the `FUNCTION`:

* `X`<sub>`1`</sub> is the top element of the stack.
* ...
* `X`<sub>`N`</sub> is the `N`*th* element on the stack.

This is identical to the setup for the so-called "built-in" functions like `ARCTAN2` called using the PALMAT `function` instruction.

When the `FUNCTION` executes, it pops all `N` of the parameters from the expression stack upon entry to the `FUNCTION`, storing them in local variables.  Upon exit from the `FUNCTION`, the return value is pushed onto the computation stack.  Again, this is the same as for built-in functions. 

For example, suppose we have an `INTEGER` `FUNCTION`, `F(X,Y,Z)`, whose definition begins in scope `K`, but whose own scope is `L`; suppose further that the function is being called from code in scope `M`.  `FUNCTION F` will be accessible to scope `K` or any of its descendent scopes: i.e., scope `M` must be scope `K` itself or else some descendent.

In scope `K`, showing just the aspects relevant to this example, we have

    PALMAT["scopes"][K] = {
        "parent": ...,
        "self": K,
        "children": [..., L],
        "identifiers": {
            ... ,
            "^l_F^": {
                "scope": L,
                "function": True,
                "integer": True,
                "parameters": ["X", "Y", "Z"],
                ...
            },
            ...
        },
        "instructions": [ ... ],
        ...
    }

(Recall that certain types of identifier names are mangled by the preprocessor: in the case of `SCALAR` or `INTEGER` `FUNCTION`s, the mangling is an added prefix "l_".  Thus "F" becomes "l_F".  But beyond that, in the identifier list, identifiers are additionally quoted using carat characters; thus `F` becomes "^l_F^".)

Whereas scope `L`, containing the identifier list and PALMAT instructions for the `F FUNCTION` itself, has no unusual features on which to remark:

    PALMAT["scopes"][L] = {
        "parent": K,
        "self": L,
        "children": [...],
        "identifiers": { ... },
        "instructions": [ ... ],
        ...
    }

Nor do specific changes need to occur in scope `M`, other than that the PALMAT instructions have to perform the subroutine linkage properly.  The PALMAT instructions generated from a HAL/S statement like

    X = F(X, Y, Z);

would thus result in an expression stack at entry to the `FUNCTION` `F` (i.e., just after the `{ 'call': 'l_F'}` instruction is executed) of

    ... stuff already on the stack (if any) ..., Z, Y, X

While `F` is executing, the expression stack looks like

    ... stuff already on the stack (if any) ..., ... temporary values pushed by F ...

And finally, after returning from `F`, 

    ... stuff already on the stack (if any) ..., returnValue

### `PROCEDURE` Specifics

`PROCEDURE`s are similar to `FUNCTION`s in many ways (the PALMAT `call` instruction continues to be used, for example), but they also differ in some obviously-necessary ways and in come stupidly-unnecessary ways.

As far as the obvious ways are concerned:

* There is no `returnValue` left on the expression stack.
* `PROCEDURE` definitions and `CALL`s to them have an `ASSIGN` clause, which causes the PALMAT `call` instructions to have an extra field, `assignment`.  The value of the `assignment` field, in the Python implementation, is a Python dictionary which has a key for each `ASSIGN` variable in the `PROCEDURE`'s definition.  The value associated with that key is an ordered pair that specifies the corresponding variable from the `ASSIGN` clause of the HAL/S `CALL` to the `PROCEDURE`.  The ordered pair contains the scope in which the identifier for the variable is defined and the string form of the identifier itself.

Consider the following sample HAL/S code:

    DECLARE Z INTEGER;
    .
    .
    .
    P: PROCEDURE(X) ASSIGN(Y);
        DECLARE INTEGER, X, Y;
        Y = X;
    CLOSE P;
    .
    .
    .
    CALL P(25) ASSIGN(Z);

In this example, `PROCEDURE P` nominally sets the variable `Y`.  However, when the `CALL P` occurs, the symbol `Y` within `P` is aliases to the variable `Z` outside of `P`.  Therefore the `CALL P` actually ends up setting the variable `Z` to the same value as the `X` parameter of `P`.  In other words, the result is to set `Z` equal to 25.

In terms of the specifics of the PALMAT `call` instruction, it looks like the following in the Python implementation:

    { 'call': (scopeOfIndexOfP, 'l_P'), 'assignments': { 'Y': (scopeOfIndexOfZ, 'Z' } }

(The suffix 'l_' in 'l_P' is due to the name mangling performed by the compiler, and is thus the procedure name used internally.)

As far as stupid, unnecessary differences between `PROCEDURE` and `FUNCTION` calls are concerned, the input parameters for the call to a `PROCEDURE` are in the opposite order on the computation stack as the parameters for a `FUNCTION`.  Thus,"

* `X`<sub>`N`</sub> is the top element of the stack.
* ...
* `X`<sub>`1`</sub> is the `N`*th* element on the stack.

This has to do with the order in which the compiler's code generator builds the PALMAT instruction list, so I'm afraid it's not exactly a simple fix even if a non-Python implementation of the emulator is created.  This annoys me, but I can't see that it makes any difference other than aesthetically, so I have no current plans to fix it.

## PALMAT Instructions 6: Other

* `{ 'fetchp': (index, identifier) }` causes a "pointer" to an variable to be pushed onto the computation stack.  These are useful as variables for a HAL/S `READ`, and for all I know at this moment, other purposes as well.  The "pointer" is just the given `index, identifier` pair, but with an additional tuple envelope of the form `((index,identifier), 0)`.  (This rather silly form was chosen to be distinguishable from an `ARRAY` type.)
* `{ 'read': LUN }`, causes a "read" from the unit identified by the Logical Unit Number (LUN).  Only `LUN`=5 is presently understood by the interpreter, and it is the stdin keyboard.  This instruction causes all variable-pointer values (placed on the computation stack by `fetchp`) to be popped from the stack.  A sequence of values consistent in number with the variable-pointers that have been popped from the computation stack.  The values read from the keyboard are stored in the variables.  The variables are processed in FIFO order rather than the usual LIFO order of a stack.
* `{ 'bitarray': N, 'len': L }` causes a bit string to be pushed onto the computation stack.  The `len` key is optional, and indicates the number of valid bits in the string; i.e., it allows you to know how many otherwise-undetectable more-significant bits of 0 there are.  If the field is missing, infinite precision is assumed.  However, when such values are stored in a `BIT(N)` variable, they are always truncated to `N` bits.  In the Python implementation I simply treat bit arrays as identical to integers, bit position 0 corresponding to the least-significant bit, and I allow integers to be assigned to bit-array variables.  Other implementations may treat them differently.
* `{ 'operator': 'subscripts' }` indicates that the elements at the top of the computation stack (see also `sentinel` below) form subscripts for the *next* PALMAT instruction encountered, which should be a `fetch`, `fetchp`, or `shaping`.  The top element of the computation stack is the first subscript, the next-to-top is the 2nd subscript, and so on; the next element on the computation stack below the subscripts themselves is a `sentinel` element.  Upon execution, the `subscripts` instruction pops all of these from the instruction stack and stores them in some implementation-dependent way to be applied to the succeeding `fetch` or `fetchp` instruction.
* `{ 'sentinel': s }` places a "sentinel" value on the computation stack.  (This is used in those rare cases where there is some PALMAT instruction, such as the `subscript` operator, which operates on a variable number of operands.  The `sentinel` instruction marks the beginning of an operand list, and the instruction for the problematic operator marks the end of the operant list.)  The value `s` is arbitrary, but for human-readability of the PALMAT it's reasonable for it to be some indicator of the PALMAT instruction to which it corresponds.  For example, the code-generator creates a `{ 'sentinel': 'subscripts' }` for an `{ 'operator': 'subscripts' }`.  However, the sentinel marker placed on the computation stack is the same regardless.
* `{ 'vector': [...] }` pushes a constant vector onto the computation stack.
* `{ 'matrix': [[...],...] }` pushes a constant matrix onto the computation stack.
* `{ 'array': ((...),...) } ` pushes a constant array onto the computation stack.
* `{ 'shaping': s }`, where s is 'integer', 'scalar', 'vector', or 'matrix'.  What these "shaping functions do is basically to recast the data type of a value on the computation stack, or to rearrange the geometry of a composite datatype.  The explanation of the configuration of the computation stack is rather complex, and so is given later on in this section.  Here are all of the possibilities for `s`:
    * `integer`:  Converts a value or values on the computation stack into an `INTEGER` or `ARRAY` of `INTEGER`. 
    * `scalar`:  Converts a value or values on the computation stack into a `SCALAR` or `ARRAY` of `SCALAR`.
    * `vector`:  Converts values on the computation stack into a `VECTOR`.
    * `matrix`:  Converts values on the computation stack into a `MATRIX`.
    * `doubleinteger`, `doublescalar`, `doublevector`, `doublematrix`:  These are double-precision variants of the shaping functions listed above.  But note that all `INTEGER` are double-precision in our Python implementation anyway, so the code generator won't necessarily generate any PALMAT `doubleXXXXX` instructions, and even if it does, their behaviors won't differ from the single-precision versions.
* `{ 'operator': '#' }`, is the repetition operator.  It has a variable number of operands.  The operand at the top of the computation stack is the repetition factor.  The other operands on the computation stack, down to the first `{'sentinel'}` encountered, comprise the sequence to be replicated.  Any operands among these latter which are composites &mdash; i.e., `VECTOR`, `MATRIX`, or `ARRAY` &mdash; are flattened to their constituent simple values in the process.  (I have no idea how or if `STRUCTURE`s are handled in this scenario, so at least for the present they are not allowed.)  The Python value `None` is also an allowed operand, and indicated an unused position in the sequence.  If the repetition factor is immediately followed by the `{'sentinel'}` without intervening operands to be replicated, it means that the value `None` is being replicated.  The value `{'fill'}` can also be present as the final operand preceding `{'sentinel'}`; this item cannot be replicated.  All of the operands, including the `{'sentinel'}`, are popped from the computation stack, and replaced with the desired replicated sequence of operands (and no added `{'sentinel'}`s).  An example appears below.
* `{'fill': True }` is an instruction to fill out a repetition list (with None) to the length implied by the geometry of the shaping function.
* `{ 'empty': True }` pushes a value of `None` onto the computation stack.
* `{ 'unravel': (index, identifier }` is like the PALMAT `fetch` instruction, but it unravels composited values (`VECTOR`, `MATRIX`, `ARRAY`) after fetching them.  **Note:** I thought I needed this instruction type, but I don't believe it is actually used at all, though the code to handle it has not been removed.
* `{ 'substore': (index, identifier }` and `{ 'substorepop': (index, identifier) }` are like the PALMAT `store` and `storepop` instructions, except that they allow the variable to which we're storing to be subscripted.  Note that this only handles the case in which the subscripting picks out a single element of the composite data element, without any cognizance of the HAL/S indexing constructs `AT`, `TO`, or `*`.  The computation stack is set up for using these instructions as follows:
    ..., VALUE_TO_STORE, {"sentinel"}, FINAL_SUBSCRIPT, ..., INITIAL_SUBSCRIPT

Regarding the internal representation of values associated with identifiers `DECLARE`'d as `BIT(N)` or `BOOLEAN`, on the computation stack these are stored as tuples `(N, V)`, where `V` is an integer representation of the value with all bits packed into the least-significant `N` positions.  In particular, `TRUE` and `FALSE` are stored as `(1,1)` and `(1,0)`.

Regarding the shaping functions and how the computation stack is configured for them, there are two possibilities.  If the shaping function (`INTEGER`, `SCALAR`, etc.) has no subscript(s), then we have a computation stack (growing to the right) like:

    {'sentinel'}, ValueN, ..., Value1

where the `Value1` through `ValueN` are the arguments of the shaping function with all repitition factors all applied.  If there are subscripts on the shaping function, as for example `INTEGER$(K,...,M)`, then the computation stack is instead:

    {'sentinel'}, ValueN, ..., Value1, {'sentinel'}, M, ..., K, {'subscripts'}

The interpretation of this data varies somewhat as well.  Here's a complete description of the many possible cases:

* The `INTEGER` shaping function:
    * HAL/S source code `INTEGER(VALUES)`:  There are a few sub-cases:
        1. Suppose that `VALUES` is a single `INTEGER`, `BIT`, `SCALAR`, or `CHARACTER`.  The result is a single `INTEGER`.  `SCALAR`-to-`INTEGER` conversions are via rounding.  `CHARACTER`-to-`INTEGER` conversion assumes that the character string holds a human-readable representation of a number; this is first turned into a floating-poing value, which is then rounded to an integer.
        2. Suppose that `VALUES` is a single `VECTOR`, `MATRIX`, or an `ARRAY` of type `INTEGER`/`SCALAR`/`BIT`/`CHARACTER`.  The converted value remains a `VECTOR`, `MATRIX`, or `ARRAY` of the original geometry, but *each element* of the `VECTOR`, `MATRIX`, or `ARRAY` is converted to an `INTEGER`; this is one of the two exceptions to the rule already mentioned that all of the arguments to the shaping function are unraveled.
        3. Suppose that `VALUES` are multiple values of any of the types just mentioned, or a mixture thereof.  The result is an `ARRAY(N)` of type `INTEGER`, with `N` being the total number of items after `VALUES` is unraveled.
    * HAL/S source code `INTEGER$(N,...,M)(VALUES)`.  The result is an `ARRAY` of `INTEGER` with a geometry as specified by the subscripts `N`,...,`M`.  There must be exactly `N`&times;...&times;`M` `VALUES` after unraveling (though there could be less if the final "value" is `*`).
* The `SCALAR` shaping function:  It just like the `INTEGER` shaping function as just described, except that the conversion is to `SCALAR` values rather than `INTEGER` values.  The case `SCALAR(VALUE)` where `VALUE` is a single `VECTOR`, `MATRIX`, `ARRAY` is the second of the two exceptions to the rule that all `VALUES` are unraveled.
* The `VECTOR` shaping function:
    * HAL/S source code `VECTOR(VALUES)`:  The result is a `VECTOR(3)`.  There must be exactly 3 `VALUES` (after unraveling).
    * HAL/S source code `VECTOR$N(VALUES)`:  The result is `VECTOR(N)`.  There must be exactly `N` `VALUES` (after unraveling).
* The `MATRIX` shaping function:
    * HAL/S source code `MATRIX(VALUES)`:  The result is a `MATRIX(3,3)`.  There must be exactly 9 `VALUES` (after unraveling).
    * HAL/S source code `MATRIX$(N,M)(VALUES)`:  The result is a `MATRIX(N,M)`.  There must be exactly `N`&times;`M` `VALUES` (after unraveling).

Regarding the repetition operator (`#`), consider the following sequence of PALMAT instructions, which could correspond, say, to the `CONSTANT` clause in the HAL/S code `DECLARE V VECTOR(32) CONSTANT(16, 5#(3#5, 2#6, 62), 1)`, shown with the contents of the computation stack (at the right, and growing to the right) after each PALMAT instruction is executed:

    {'number': '1'}         [1]
    {'sentinel': 'repeat'}  [1, {'sentinel'}]
    {'number': '62'}        [1, {'sentinel'}, 62]
    {'sentinel': 'repeat'}  [1, {'sentinel'}, 62, {'sentinel'}]
    {'number': '6'}         [1, {'sentinel'}, 62, {'sentinel'}, 6]
    {'number': '2'}         [1, {'sentinel'}, 62, {'sentinel'}, 6, 2]
    {'operator': '#'}       [1, {'sentinel'}, 62, 6, 6]
    {'sentinel': 'repeat'}  [1, {'sentinel'}, 62, 6, 6, {'sentinel'}]
    {'number': '5'}         [1, {'sentinel'}, 62, 6, 6, {'sentinel'}, 5]
    {'number': '3'}         [1, {'sentinel'}, 62, 6, 6, {'sentinel'}, 5, 3]
    {'operator': '#'}       [1, {'sentinel'}, 62, 6, 6, 5, 5, 5]
    {'number': '5'}         [1, {'sentinel'}, 62, 6, 6, 5, 5, 5, 5]
    {'operator': '#'}       [1, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5]
    {'number': '16'}]       [1, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 62, 6, 6, 5, 5, 5, 16]
    
The elements on the computation stack (in LIFO order) form the constant value(s) for vector `V`, which hopefully are obvious by inspection to correspond to `CONSTANT(16, 5#(3#5, 2#6, 62), 1)`.

## Multiprocessing and Reentrancy

So far I've just been considering single-threaded program execution.  The memory model described above will need modification for the conditions in which code in a given scope might have two or more instantiations simultaneously, and I haven't given any consideration as of yet to that problem.  I'll worry about that once support for single-threaded operation is correct and reasonably comprehensive.  However, here are a few notes of thoughts I've had.

Python offers both multithreading (the `concurrent` module) and multiprocessing (the `multiprocessing` module), and I'm not sure which is better for our purposes.  Execution would undoubtedly be a lot faster with multiprocessing, but I'm not sure how the choice affects the memory model as discussed below.  So more research is needed.  For future implementations of the emulator in (say) C or C++ rather than Python, the choice could obviously be different.

It seems to me that when any given HAL/S subroutine is instantiated, the following facts are true:

* It is given its own unique computation stack.
* It is given its own unique PALMAT structure, some of which is specific to the instantiation and some of which is identical to the global PALMAT.

Each process (or thread as the case may be) is started from a separate invocation of `executePALMAT`, and since the computation stack is a local variable of `executePALMAT`, that takes care of the unique computation stacks.

Each invocation of `executePALMAT` has a parameter called `newInstantiation`, which defaults to `False`, which means that it's just supposed to use the global PALMAT and be part of instantiation 0.  This is good for single-threaded operation at emulation time, or use of `executePALMAT` by the compiler in trying to compute constant expressions at compile-time.

When (say) a second process/thread is started, it is done with `executePALMAT` having `newInstantiation=True`.  This causes `executePALMAT` to create the partial clone of PALMAT that I've mentioned.

Regarding this partial clone of PALMAT, it seems to me that it has to have the following properties:

* All `instructions` lists in all scopes are simply links to the `instructions` lists in the global PALMAT.
* All `identifiers` dictionaries in all scopes *except `COMPOOL`s* are "deep copies" of the `identifiers` dictionaries in the global PALMAT.  I.e., they are clones at instantiation time but the values stored in them can diverge after that point.
* `COMPOOL` scopes are instead shared by all instantiations, and are thus links to the same object (or objects if there is more than one `COMPOOL`).

## Optimizations

I think there are a lot of target-independent optimizations that can be performed at the PALMAT level.  While I presently don't do any optimizations at all, since it's premature given the relatively-primitive state of code generation, but I have noticed some things which I might as well point out.

### Optimization: Multiple Symbolic Labels for a Given Address

It sometimes happens that the code generator doesn't know that a symbolic label has already been autogenerated for an address, and so it generates another one.  As you may recall from the discussion above, an "address" is an integer offset into a integer scope number.

Here's an example of what I mean that started with the following code:

    DECLARE I INTEGER INITIAL(0); 
    DO UNTIL I >= 10; 
        I = I + 1; 
        WRITE(6) I; 
    END;

The identifiers after compiling this code were

    Scope 0:
    	I: {'integer': True, 'initial': 0, 'value': 0}
    	ue_1343: {'label': [1, 0]}
    	ue_1359: {'label': [1, 0]}
    Scope 1:
    	ue_1343: {'label': [1, 0]}
    	ue_1346: {'label': [1, 15]}
    	ue_1360: {'label': [1, 1]}
    	ue_1361: {'label': [1, 6]}
    	ue_1631: {'label': [0, 1]}
        
where the symbol-names prefixed by `ue_` were all autogenerated.  In this example, scope 0 is the parent of scope 1.  And here are the PALMAT instructions for the same:

    Scope 0:
    	0: {'goto': '^ue_1359^'}
    	1: {'noop': True, 'label': '^ue_1631^'}
    Scope 1:
    	0: {'label': '^ue_1343^', 'goto': '^ue_1361^'}
    	1: {'noop': True, 'label': '^ue_1360^'}
    	2: {'fetch': 'I'}
    	3: {'number': '10'}
    	4: {'operator': '>='}
    	5: {'iftrue': '^ue_1346^'}
    	6: {'noop': True, 'label': '^ue_1361^'}
    	7: {'number': '1'}
    	8: {'fetch': 'I'}
    	9: {'operator': '+'}
    	10: {'store': 'I'}
    	11: {'pop': 1}
    	12: {'fetch': 'I'}
    	13: {'write': '6'}
    	14: {'goto': '^ue_1360^'}
    	15: {'noop': True, 'label': '^ue_1346^'}
    	16: {'goto': '^ue_1631^'}
    
First, note that any identifier in the parent scope is accessible to the descendent scopes.  Thus `ue_1343` in scope 1 is redundant to `ue_1343` in scope 0, given that they refer to the same address (namely, scope 1 offset 0).  Therefore, `ue_1343` can simply be removed from the identifiers of scope 1.  Second, though, even in scope 0 by itself, the two labels `ue_1343` and `ue_1359` refer to the same address.

Thus one optimization which could be made is to remove `ue_1343` from scope 1 and `ue_1359` from scope 0, leaving just `ue_1343` in scope 0, and then changing all references to `ue_1359` in the PALMAT instructions to `ue_1343`.  

This doesn't save any resources per se, since no PALMAT instructions are removed or even changed in any substantive way, but it does seem as though removal of the redundancy would make other optimizations less cumbersome.

### Optimization:  Useless noop

Continuing with the example from the preceding section, notice that the code generator has inserted a number of no-ops (the PALMAT `noop` opcode) that can be removed, since they serve no purpose.  Originally, they would have been added as placeholders for other instructions which never ended up being added, or as holders for symbolic labels that are targets of PALMAT instructions like `goto`, `iffalse`, and `iftrue`.

For example, consider PALMAT instructions 15 and 16 of scope 1:

    	15: {'noop': True, 'label': '^ue_1346^'}
    	16: {'goto': '^ue_1631^'}

Why not just get rid of the `noop`, as follows:

    	15': {'goto': '^ue_1631^', 'label': '^ue_1346^'}

(Of course, in doing this, it's also necessary to go through the identifier list, for all scopes, and adjust all `label` identifiers referencing scope 1 and offsets >15 by decrementing the offsets by 1.  In this case there aren't any.)

Similar scenarios hold for the scope 1 at offsets 6 & 7 and at offsets 1 & 2.

### Optimization:  Useless goto Instructions

Considering the example optimization in the preceding section in which a `noop` instruction was removed at scope 1 offset 15, after that optimization occurs we would then have the following situation:

    	14:  {'goto': '^ue_1360^'}
    	15': {'goto': '^ue_1631^', 'label': '^ue_1346^'}

At instruction 15', we now have a `goto` instruction that can only be reached by other `goto` (or `iftrue` or `iffalse`) instruction.  So why not just find every `{'goto': '^ue_1646^'}` instruction and replace it by `{'goto': '^ue_1321^'}` instead?  This saves one instruction for each of them, as well as allowing us to eliminate the instruction at offset 15' completely (while adjusting the identifier offsets, of course, though in this case there don't happen to be any).

### Optimization:  Extensions to PALMAT Instruction Set

I've made no real effort to optimize the PALMAT instruction set itself, but in general, the larger (and more complex) the PALMAT instruction set, the faster the code is going to run.

With this in mind, we note that there are certain combinations of PALMAT instructions generated very frequently by the compiler's code generator.  Here are some examples:

* `{'store': identifier}`, `{'pop': 1}`.  This combination looks at the top of the computation stack, saves the value it finds there to a variable identified by its `identifier`, and then pops the value from the stack.  But why not extend the PALMAT instruction set with a single `{'storepop': identifier}` instruction that combines both actions?
* `{'number': n}`, `{'store': identifier}`, `{'pop': 1}`.  This sequence stores a constant number `n` on the stack, then saves it at `identifier`, and `pop`s it from the stack.  Why not just have a `{'storeconstant': identifier, 'value': n}` PALMAT instruction that saves `n` directly to `identifier`, and bypasses the stack completely?

Well, I won't continue pointing out the very, very obvious here, but there's obviously a lot of potential for reducing the total number of PALMAT instructions needed.

## Speculation ...

All of the subsections below are pure speculation at this point, as constrasted with the material above, that all relates to stuff already implemented.

### The Source-Code File List

The source-code file list,

    PALMAT["SourceCodeFiles"]

is a one-dimensional array listing all of the filenames of source-code file read into the processor.  They appear in the order encountered, but there is no logical need for them to do so.

### The StructureTemplate List

The structure-template list,

    PALMAT["StructureTemplates"]

is a list of all templates needed from the structure-template library.  The format of the entries is TBD.

### The Raw Source-Code List

The raw source-code list,

    PALMAT["RawSourceCode"]

is a one-dimensional array of all HAL/S source code lines, unpreprocessed, in the order the preprocessor encounters them.  Each entry in the array is a dictionary with the following fields:

    {
        "code" : ...,       # The source-code line, as a string, exactly as 
                            # read from its file.
        "fileNum" : ...,    # The numerical index of the source-code file 
                            # within PALMAT["SourceCodeFiles"].
        "index" : ...,      # The line-number within the source file, 
                            # starting from 1.
        "template" : ...,   # (Usually not present.) For "D INCLUDE STRUCTURE"
                            # directives, index into PALMAT["StructureTemplates"]
        TBD
    }

### The Preprocessed Source-Code List

This list,

    PALMAT["PreprocessedSource"]

is a one-dimensional array of all source-code emitted from the preprocessor and input into the compiler.  Note that any given preprocessed line may correspond to a single raw line, a combination of several raw lines, a portion of a raw line, a line generated entirely by the preprocessor, etc.  Each entry in the array is a dictionary with the following fields:

    {
        "code" : ...,       # The full text of the line of code.
        TBD
    }

