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

Internally within PALMAT, the ^ character is used for quoting all text strings, resulting in there being three flavors of text strings (^...^, ^'...'^, and ^"..."^) used for different purposes.  Moreover, the backslach character (\) does not appear in the PALMAT character set, but is used in most modern software for test escape sequences, hence it would be awkward to allow it as a PALMAT character.

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

The "scopes" array is the memory model, incompassing all identifiers used by the code, such as variables and user-defined function names, as well as the code itself. Each individual scope in the array is the memory model for a specific HAL/S block (such as PROGRAM, FUNCTION, PROCEDURE, ...).  The compiler assigns these blocks unique sequence numbers, starting from 0, as it encounters them, and then appends the scope for that block to `PALMAT["scopes"]`.  `PALMAT["scopes"][0]` is the top-level scope.

Each individual scope is itself a dictionary, and provides links to both the scope of its parent block and to any immediate child blocks.  The code within any HAL/S block has access to the objects declared within its own scope, including temporaries, as well as the objects of the parent, grandparent, and so on, but not the child blocks.

    anyIndividualScope = {
        "parent" : ...,             # The integer index of the parent scope within PALMAT["scopes"], or else None if top level.
        "self" : ...,               # The integer index of this scope within PALMAT["scopes"].
        "children" : [ ... ],       # List of integer indices of immediate child scopes within PALMAT["scopes"]
        "identifiers" : { ... },    # The identifiers declared in the current block, keyed by their names.
        "instructions" : [ ... ]    # The PALMAT instructions for the block.
    }

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

## PALMAT Instructions

In the final implementation, PALMAT instructions will very likely be encoded numerically in some format intended to efficiently reduce the storage required for storage of the executable and decoding of the instructions by the PALMAT virtual machine executing the code.  However, I don't want to get ahead of myself:  Let's just get it working logically correctly before worrying about efficient storage formats, shall we?

Since the bulk of my HAL/S compiler is in Python and the file-format being used is a JSON version of the Python structures, for *now* PALMAT instructions will be represented as Python dictionaries.

Before presenting any actual instructions, let me add that for computation of expressions (arithmetical, boolean, or otherwise), the PALMAT virtual machine implements an execution-stack based model, such as found in a Reverse Polish Notation (RPN) calculator or in the FORTH computer language.  Therefore, the behavior of PALMAT instructions is often to pop values from this execution stack, perform some computation on them (such as addition), and then to push the result back on the execution stack.  Each entry of the execution stack can thus hold values of various types.

Also, any of the PALMAT instructions listed below optionally have a key `label` whose value is a unique string, and indicates that the instruction is the target of some kind of control-transfer instruction. 

### PALMAT Instructions 1: Arithmetic

With that in mind, here's a description of some of the available PALMAT instructions.

* `{'number': string}`, where `string` is a stringified version of a number such as 1.35E13B2.  (At some point, I may change this so that `string` is replaced by the actual Python representation of the number, but for now I don't go that far because this method preserves exact values.)  **Recall** that in HAL/S, the minus sign is an operator, and not a character that can prefix a number token, so these numbers are all non-negative.  The action of this instruction at runtime is push the number (*as* a number and no longer as a string) onto the execution stack
* `{'operator': '+'}`.  The action of this instruction at runtime is to pop the last two numbers from the execution stack, add them, and then to push the result back onto the execution stack.  The execution stack is thus shortened by one element.
* `{'operator': '-'}`.  This is a binary minus operator, as opposed to a unary negation operator.  The action at runtime is to pop the final two elements from the execution stack, subtracting the 2nd-to-last value from the last value, and then to push the result back onto the execution stack.
* `{'operator': 'U-'}`.  This is unary negation operator.  The action at runtime is to arithmetically negate the last value on the execution stack.  Thus the execution stack does not change in size.
* `{'operator': ''}`.  This is the multiplication operator.  The action at runtime is to pop the last two values from the execution stack, multiply them, and then push the result back onto the execution stack.
* `{'operator': '/'}`.  This is the division operator.  The action at runtime is to pop the final two elements from the execution stack, dividing the last value by the 2nd-to-last value from the last value, and then pushing the result back onto the execution stack.
* `{'operator': '**'}`.  This is the exponentiation operator.  The action at runtime is to pop the final two elements from the execution stack, raising the last value to the power of the 2nd-to-last value, and then pushing the result back onto the execution stack.
* `{'fetch': identifier}`, where `identifier` is the name of a variable.  It must correspond to an identifier already in `PALMAT["identifiers"]`, except that the surrounding carats (if any) used as string quotes in the identifier dictionary will not be present.  The action at runtime is to fetch the value of the variable or constant identified and push it onto the execution stack.  (I haven't given any thought as of yet as to how to handle vectors, matrices, arrays, or structures as of yet, while booleans vs bits is somewhat tricky.  So temporarily at least, just think of variables or constants storing numbers or character strings.)
* `{'store': identifier}`, where `identifier` is the name of a variable.  It must correspond to an identifier already in `PALMAT["identifiers"]`, except that the surrounding carats (if any) used as string quotes in the identifier dictionary will not be present.  The action at runtime is to store the last value in the execution stack (without popping it from the stack) into the variable identified.  The value is stored in the variable's "value" attribute.
* `{'pop': number}`.  Pops `number` of elements from the execution stack and discards them.

More PALMAT instructions will be defined below, but first let's consider a couple of example.  Look at the following HAL/S code:

    DECLARE SCALAR, A, B, C;
    A, B, C = 6 ( 2 / (3 + 5) - 7 );

The PALMAT instructions generated from the latter statement are shown below, accompanied by the runtime evolution of the execution stack (growing rightward) as each PALMAT instruction is executed.

    PALMAT Instruction                  Execution Stack Afterward
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

    PALMAT Instruction                  Execution Stack Afterward
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

  * `{'write': lun}` marks the *end* of the PALMAT corresponding to a HAL/S statement of the form `WRITE(lun) ...`.  The only logical unit number understood by the interpreter is `lun=6`, which is output to the console from which the interpreter commands and HAL/S statements are being input.  The instruction outputs every value on the expression stack, in FIFO order (not LIFO stack order), and then clears the stack.

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

* `{'goto': [i,n]}` or `{'goto': s}` transfers control to integer position `n` in the PALMAT-instruction list for the scope with integer index `i`, or else to the accessible (scope-wise) PALMAT instruction having a `"label" : s` key-value pair. It is expected that the latter form is the as-compiled form, but that for efficiency purposes, the virtual machine executing PALMAT code would replace the latter form by the former, either upon start or else progressively as execution proceeds.
* `{'boolean': t}` where t is True or False.  This instructin pushes the indicated boolean value onto the expression stack.
* `{'operator': 'NOT'}`. Logically negates the top of the stack.
* `{'operator': 'AND'}`. Pops the top two elements from the stack, logically ANDs them, and pushes the result onto the stack.
* `{'operator': 'OR'}`. Pops the top two elements from the stack, logically ORs them, and pushes the result onto the stack.
* `{'operator': 'B||'}`. Pops the top two elements from the stack, logically concatenates them, and pushes the result onto the stack.
* `{'operator': 'B||N'}`. Pops the top two elements from the stack, logically OR's the top of the stack with the negation of the next-to-top, and pushes the result onto the stack.
* `{'operator': '=='}`. Pops the top two elements from the stack, tests for equality, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '!='}`. Pops the top two elements from the stack, tests for inequality, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '<'}`. Pops the top two elements from the stack, tests if the top is less than the next-to-top, and pushes the boolean result of the comparison onto the stack. 
* `{'operator': '>'}`. Pops the top two elements from the stack, tests if the top is greater than the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '<='}`. Pops the top two elements from the stack, tests if the top is less than or equal to the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '>='}`. Pops the top two elements from the stack, tests if the top is greater than or equal to the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '!<'}`. Pops the top two elements from the stack, tests if the top is not less than the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'operator': '!>'}`. Pops the top two elements from the stack, tests if the top is not greater than the next-to-top, and pushes the boolean result of the comparison onto the stack.
* `{'noop': True }`.  A no-op.  It is used primarily for forward-defining the location of a label when the compiler isn't yet aware of the actual PALMAT instruction at that location due to lack of lookahead.  This occurs primarily for unique labels generated by the compiler itself to mark the ends of `IF ... THEN ... ELSE`, `DO WHILE ... END`, and so on.  Machine-independent optimization of the PALMAT instructions can therefore remove the `noop` and transfer the `noop`'s `"label"` key to the next instruction.
* `{'iffalse': s}`.  Pops entry from expression stack and if False performs equivalent of a `{'goto': s}`.
* `{'iftrue': s}`.  Pops entry from expression stack and if True performs equivalent of a `{'goto': s}`.

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

* `{'store': identifier}`, `{'pop': 1}`.  This combination looks at the top of the execution stack, saves the value it finds there to a variable identified by its `identifier`, and then pops the value from the stack.  But why not extend the PALMAT instruction set with a single `{'storepop': identifier}` instruction that combines both actions?
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

