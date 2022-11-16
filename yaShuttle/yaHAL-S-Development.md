**Note:**  This file contains various notes (mostly to myself) about developing a "modern" HAL/S compiler that I call yaHAL-S.  It's likely not of interest to anybody else &mdash; RSB

A Backus-Naur Form (BNF) description of the HAL/S language appears in the contemporary documentation, in [AppendiX G of the HAL/S Language Specification](https://www.ibiblio.org/apollo/Shuttle/HAL_S%20Language%20Specification%20Nov%202005.pdf#page=209).  The link is to the latest version of the specification that's available, although as far as I can tell, the same description appears in the very earliest available version, as well as in the original source code, modulo typos.  I have converted that into a machine-readable form, namely the file

    HAL-S.bnf

with corrected typos and some reformatting.  Besides that, there were a couple of illegal constructions, 

    <OR> ::= | | OR
    <CAT> ::= || | OR

which I've changed to 

    <OR> ::= <CHAR VERTICAL BAR> | OR
    <CAT> ::= <CHAR VERTICAL BAR> <CHAR VERTICAL BAR> | CAT

The type `<CHAR VERTICAL BAR>` naturally does not exist in the original BNF, nor in HAL-S.bnf, since there's no standard way in BNF I can discern to create a rule for it.  Besides which, the documented BNF description is actually incomplete, in the sense that it is missing rules for various other types it refers to, most or all of which are elementary types, such as `<SIMPLE NUMBER>`, `<IDENTIFIER>`, and so on.  Rules for all of these need to be created, into order to get a complete description of the language.  The contemporary BNF is also buggy, in the sense that while it served as documentation both prior to and after the original coding, it was not itself subject to automated processing.  *For example*, the very first rule was `<COMPILATION> ::= <COMPILE_LIST> _|_`, where the trailing `_|_` is just garbage; my guess is that it was shorthand for the original developers that `<COMPILATION>` was the top-level BNF rule.  For us, though, it's unprocessable nonsense and has to be removed.

Having a complete formal description of HAL/S in hand, I use the [BNF Converter (BNFC)](https://bnfc.digitalgrammars.com/) compiler-compiler to produce a HAL/S compiler frontend. BNFC does not actually take a BNF description as input, but requires an alternate form known as [Labeled BNF (LBNF) grammar](https://bnfc.readthedocs.io/en/latest/lbnf.html).  I have therefore created a script,
 
    bnf2lbnf.py

that can convert my BNF to LBNF.  Although since the script is rather simple-minded in terms of its pattern matching, the original BNF description has been massaged somewhat in HAL-S.bnf in terms of its whitespace.
 
I find it more-convenient to provide the rules for the missing types mentioned earlier in LBNF form rather than BNF, because LBNF has ready means of creating various of those rules (particularly <CHAR VERTICAL BAR>, but others as well) by means of regular expressions.  All of those additional definitions reside in a file called
 
    extraHAL-S.lbnf

In Linux or Mac OS X, the complete description of HAL/S in LBNF can be created by the following command:
 
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

However ... there are certain features of HAL/S which are not captured by the BNF (or LBNF) description of it, and which we cannot work around if we confine ourselves to BNF/LBNF.  Specifically, I refer to the fact that while HAL/S is essentially free-form in columns 2 and rightward &mdash; i.e., it does not respect column alignment or line breaks &mdash; it nevertheless treats column 1 specially.  Column 1 is normally blank, but can also contain the special characters

* C &mdash; full-line comment.
* D &mdash; compilation directive line.
* E &mdash; exponent line.
* M &mdash; main line (in conjunction with E and S lines).
* S &mdash; subscript line.

Neither BNF nor LBNF has any provision for a column-dependent feature of this kind.  Therefore, prior to compiling HAL/S source code, it is necessary to preprocess it,

    HAL-preprocessor.py < TRUE_HAL_SOURCE.hal > TAME_HAL_SOURCE.hal

to "tame" those column-dependent features.  It is the tamed HAL/S source which needs to be compiled.  Specifically, the multiline Exponent/Main/Subscript (E/M/S) constructs are converted to also-legal single-line form.  Moreover, full-line comments are converted to "//"-style comments.  I.e., in the tamed code, "//" anywhere in a line of code (not merely in column 1) indicates that the remainder of the line is a comment.

Some additional major steps are needed *after* creating the compiler front-end, in order to have a complete compiler:

1. A compiler backend has to be created which can convert the compiler frontend's output to the target form, which in this case is p-HAL/S p-code.
2. A formatter for an output listing needs to be created.
3. Modifications must be made to produce sensible compilation error messages.

More TBD.

