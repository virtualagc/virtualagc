*This folder is work in progress and is not presently useful for anything ... beginning with the fact that Space Shuttle software is not presently available.  The same comment applies to the Space Shuttle web-pages mentioned below.*

# What's This?

This folder contains software associated with the Virtual AGC web-pages devoted to [Space Shuttle software](https://www.ibiblio.org/apollo/Shuttle.html) and the associated [Space Shuttle library](https://www.ibiblio.org/apollo/links-shuttle.html).  The concept is handling of Space Shuttle software in a manner analogous to our handling of AGC, AGS, LVDC, and Gemini OBC software.  Specifically:

* Presentation of Space Shuttle software source code, to the extent permitted by ITAR.
* Presentation of contemporary support software, such as the original Shuttle-era compiler.
* Presentation of a "modern" compiler and other development tools suitable for use on personal computers
* Presentation of means of emulating execution of Space Shuttle software and certain of its peripheral devices.
* Presentation of means of integrating such emulation with existing spaceflight simulators such as [Orbiter+SSU (Space Shuttle Ultra)](https://sourceforge.net/projects/shuttleultra/) or [FlightGear](https://wiki.flightgear.org/Space_Shuttle).

# Some Background

(For more information, please consult our [Space Shuttle web page](https://www.ibiblio.org/apollo/Shuttle.html).)

The original Space Shuttle flight software included the following components:

* The Primary Avionics Software Subsystem (PASS), consisting of:
  * The Primary Flight Software (PFS), written in a high-level language called HAL/S.
  * The Runtime Library (RTL), written in IBM AP-101S assembly language.
  * The Flight Control Operating System (FCOS), written in IBM AP-101S assembly language.
* The Backup Flight Software (BFS), written in HAL/S
* ... additional software components running on dedicated less-powerful processors ...

Whereas the original development software included:

* HAL/S-360, the HAL/S compiler, written in a language called XPL, targeting the IBM 360 mainframe.  
* HAL/S-FC, the HAL/S compiler, written in XPL, but targeting the IBM AP-101S avionics computer used on the Shuttle.
* ... others ...

# Roadmap

Aside from attempting to acquire Space Shuttle source code, original development-tool source code, and documentation, which is an ongoing process, the intent is to produce "modern" software in a phased development.

## Phase 1

1. Creation of a p-code format (p-HAL/S), suitable for distributing emulation-ready but unmodifiable Shuttle Software, from which source code is not recoverable.  This is seen as an ITAR-compatible method of open distribution, since the distributed p-code contains neither targeting capabilities, nor the means to add such capabilities.
2. Creation of a "modern" compiler (yaHAL-S) for the HAL/S language, producing p-HAL/S p-code.
3. Creation of an emulator (yaPASS.py) for executing p-HAL/S p-code and emulating certain Shuttle crew-interface peripherals, specifically the multifunction displays and keyboards.  This emulation is not required to be time-efficient or suitable for integration into a spaceflight-simulation system.

## Phase 1.1

1. Creation of a fast emulation subroutine (yaGPC.c) for executing p-HAL/S p-code, but with no direct means of emulating peripherals.  Instead, there will be some method for developers to interface to their own peripheral devices and/or databuses.  This is intended to be an efficient means of integration for spaceflight-simulation systems.

## Phase 2 and Beyond

This is an open area, as many additional developments are possible.  Here's a list of some of the possibilities:

* The original compiler, HAL/S-360 (HAL/S-FC) ran on an IBM System/360 mainframe.  The [open source Hercules System/370 emulator](http://www.hercules-390.org/) is available, as is the [MVS operating system](http://www.ibiblio.org/jmaynard/), as is the [XPL compiler for MVS](https://www.jaymoseley.com/hercules/compilers/list_of.htm#XPL), so it's possible at least in principal to run the original HAL/S compiler.
* Exploiting the original compiler to produce p-code.
* Using a modern [XPL-to-C preprocessor](https://sourceforge.net/projects/xpl-compiler/) to run the original compiler on modern computers.
* Writing an emulator for the IBM AP-101S avionics computer

But I'm sure there are many other things that could be done as well.

# The Modern HAL/S Compiler: yaHAL/S

Here's my current progress and plan.

A Backus-Naur Form (BNF) description of the HAL/S language appears in the contemporary documentation, in (AppendiX G of the HAL/S Language Specification](https://www.ibiblio.org/apollo/Shuttle/HAL_S%20Language%20Specification%20Nov%202005.pdf#page=209).  The link is to the latest version of the specification that's available, although as far as I can tell, the same description appears in the very earliest available version, as well as in the original source code, modulo typos.  I have converted that into a machine-readable form, namely the file

    HAL-S.bnf

with corrected typos and some reformatting.  Besides that, there were a couple of illegal constructions, 

    <OR> ::= | | OR
    <CAT> ::= || | OR

which I've changed to 

    <OR> ::= <CHAR VERTICAL BAR> | OR
    <CAT> ::= <CHAR VERTICAL BAR> <CHAR VERTICAL BAR> | CAT

The type <CHAR VERTICAL BAR> naturally does not exist in the original BNF, nor in HAL-S.bnf, since there's no standard way in BNF I can discern to create a rule for it.  Besides which, the documented BNF description is actually incomplete, in the sense that it is missing rules for various other types it refers to, most or all of which are elementary types, such as <SIMPLE NUMBER>, <IDENTIFIER>, and so on.  Rules for all of these need to be created, into order to get a complete description of the language.  

Having a complete formal description of HAL/S in hand, I use the [BNF Converter (BNFC)](https://bnfc.digitalgrammars.com/) compiler-compiler to produce a HAL/S compiler frontend. BNFC does not actually take a BNF description as input, but requires an alternate form known as [Labeled BNF (LBNF) grammar](https://bnfc.readthedocs.io/en/latest/lbnf.html).  I have therefore created a script,
 
    bnf2lbnf.py

that can convert my BNF to LBNF.  Although since the script is rather simple-minded in terms of its pattern matching, the original BNF description has been massaged somewhat in HAL-S.bnf in terms of its whitespace.
 
I find it more-convenient to provide the rules for the missing types mentioned earlier in LBNF form rather than BNF, because LBNF has ready means of creating various of those rules (particularly <CHAR VERTICAL BAR>, but others as well) by means of regular expressions.  All of those additional definitions reside in a file called
 
    extraHAL-S.lbnf

In Linux or Mac OS X, the complete description of HAL/S in LBNF be created by the following command:
 
    cat extraHAL-S.lbnf HAL-S.bnf | bnf2lbnf.py > HAL_S.cf

In Windows, I've read (though I don't vouch for it!) that you'd replace `cat` by `type`.  By the way, the filename HAL-S.cf would eventually cause our build to fail, which is the reason for the sudden switch to HAL_S.cf.
 
Assuming you've installed BNFC for your particular operating system (Linux, Windows, and Mac OS X are available, and maybe others for all I know), you're ready to build the compiler front-end.  I'd suggest you do this in a separate folder, because the process creates a lot of files.  In Linux, the process looks like this, assuming you're starting from the directory which contains HAL-S.cf:
 
    md temp
    cd temp
    bnfc --c -m ../HAL_S.cf
    make

(If you've previously performed these same steps in the same directory, you'd also be advised to do a `make distclean` prior to the `bnfc ...`, or else you're likely to find that whatever changes have been made to HAL-S.cf in the meantime won't actually appear in the front-end you create.)
 
As you may or may not be able to discern, what the `bnfc` command actually does is to create C-language source code for the HAL/S compiler front-end, and then compiles that C code.  In fact, BNFC can actually create the source code for the compiler front-end in a variety of languages, such as C++ or Java, and I've just chosen C as my personal preference.

The compiler front-end produced in this manner is called `TestHAL_S`, and it is used as follows:

    TestHAL_S SOURCE.hal

However ... there are certain features of HAL/S which are not captured by the BNF (or LBNF) description of it, and which we cannot work around.  Specifically, I refer to the fact that while HAL/S is essentially free-form in columns 2 and rightward &mdash; i.e., it does not respect column alignment or line breaks &mdash; it nevertheless treats column 1 specially.  Column 1 is normall blank, but can also contain the special characters

* C &mdash; full-line comment.
* D &mdash; compilation directive line.
* E &mdash; exponent line.
* M &mdash; main line (in conjunction with E and S lines).
* S &mdash; subscript line.

Neither BNF nor LBNF has any provision for a column-dependent feature of this kind.  Therefore, prior to compiling HAL/S source code, it is necessary to preprocess it,

    HAL-preprocessor.py < TRUE_HAL_SOURCE.hal > TAME_HAL_SOURCE.hal

to "tame" those column-dependent features.  It is the tamed HAL/S source which needs to be compiled.  Specifically, the multiline Exponent/Main/Subscript (E/M/S) constructs are converted to also-legal single-line form.  Moreover, full-line comments are converted to "//"-style comments.  I.e., in the tamed code, "//" anywhere in a line of code (not merely in column 1) indicates that the remainder of the line is a comment.

Some additional major steps are needed *after* creating the compiler front-end, in order to have a complete compiler:

1. A compiler backend has to be created which can convert compiler frontend's output to the target form, which in this case is p-HAL/S p-code.
2. A formatter for an output listing needs to be created.
3. Modifications must be made to produce sensible compilation error messages.

More TBD.

# Changes To the Language

## Comments

In true HAL/S, comments take one of the following two forms:

* "C" in column 1 indicates a full-line comment.
* Anything delimited by "/*" and "*/" is a comment.

Additionally, though, we have the need for "modern" comments that weren't present originally, and we need to be able to distinguish those from the original comments.  Thus, we've added a third type:

* "#" in column 1 indicates a full-line modern comment.

As mentioned before, the modern compiler cannot recognize the special nature of column 1, so HAL/S is preprocessed prior to compilation in order to alter features dependent on column 1.  In the case of full-line comments, the preprocessor transforms them as follows:

* "C" in column 1 &rarr; "//".
* "#" in column 1 &rarr; "///".

As a side effect, "//"-style comments and "///"-style comments can also be inserted into HAL/S source code *prior* to preprocessing ... though I would recommend against doing so.

# The p-Code Format:  p-HAL/S

TBD

# The PHase 1 Emulator:  yaPASS.py

I'm not sure there's any reason to go into much detail about this, but the program consists basically of two Python modules, namely shuttleCrewInterface.py (which emulates displays and keyboards) and gpc.py (which emulates the CPU and executes the p-code).  The two interact via Python thread-safe queues, which emulate the Shuttle's databuses.  Button presses in the crew interface are conveyed to the CPU by passing data in one direction, while commands for displaying data on the displays are passed from the CPU to the crew interface by messages in the opposite direction.

TBD

# The Phase 1.1 Emulator:  yaGPC.c

TBD
