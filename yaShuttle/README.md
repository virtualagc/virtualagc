*This folder is work in progress and is not presently useful for much ... beginning with the fact that Space Shuttle software is not presently available.*

# Table of Contents

* [What's This?](#WhatIs)
* [Some Background](#Background)
* [Roadmap](#Roadmap)
    * [Phase 1](#Phase1)
    * [Phase 2 and Beyond](#Phase2)
* [The Modern HAL/S Compiler and Preprocessor: modernHAL-S-FC and yaHAL-S-FC.py](#Compiler)
* [Conventions and Restrictions](#Changes)
    * [Column 1 and Comments](#Comments)

# <a name="WhatIs"></a>What's This?

This folder contains software associated with the Virtual AGC web-pages devoted to [Space Shuttle software](https://www.ibiblio.org/apollo/Shuttle.html) and the associated [Space Shuttle library](https://www.ibiblio.org/apollo/links-shuttle.html).  The concept is handling of Space Shuttle software in a manner analogous to our handling of AGC, AGS, LVDC, and Gemini OBC software.  Specifically:

* Presentation of Space Shuttle software source code, to the extent permitted by ITAR.
* Presentation of contemporary support software, such as the original Shuttle-era compiler.
* Presentation of a "modern" compiler and other development tools suitable for use on personal computers
* Presentation of means of emulating execution of Space Shuttle software and certain of its peripheral devices.
* Presentation of means of integrating such emulation with existing spaceflight simulators such as [Orbiter+SSU (Space Shuttle Ultra)](https://sourceforge.net/projects/shuttleultra/) or [FlightGear](https://wiki.flightgear.org/Space_Shuttle).

# <a name="Background"></a>Some Background

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

# <a name="Roadmap"></a>Roadmap

Aside from attempting to acquire Space Shuttle source code, original development-tool source code, and documentation, which is an ongoing process, the intent is to produce "modern" software-development tools, in a phased development, capable of processing and executing the original Space Shuttle flight software.

## <a name="Phase1"></a>Phase 1

1. Creation of an intermediate language ("PALMAT"), i.e., neither source code nor code which is executable on an actual Shuttle computer system, suitable for distributing emulation-ready but unmodifiable Shuttle Software, from which source code is not recoverable.  This is seen as an ITAR-compatible method of open distribution, since the distributed PALMAT contains neither targeting capabilities, nor the means to add such capabilities.
2. Creation of a "modern" compiler for the HAL/S language, generating PALMAT.
3. Creation of an emulation (yaPASS.py) for certain peripherals (displays, keyboards), and low-speed emulation for PALMAT code.
4. Creation of a high-speed emulator for PALMAT code, suitable for integration into existing spaceflight simulation systems.

## <a name="Phase2"></a>Phase 2 and Beyond

This is an open area, as many additional developments are possible.  Here's a list of some of the possibilities:

* The original compiler, HAL/S-360 (HAL/S-FC) ran on an IBM System/360 mainframe.  The [open source Hercules System/370 emulator](http://www.hercules-390.org/) is available, as is the [MVS operating system](http://www.ibiblio.org/jmaynard/), as is the [XPL compiler for MVS](https://www.jaymoseley.com/hercules/compilers/list_of.htm#XPL), so it's possible at least in principal to run the original HAL/S compiler.
* Exploiting the original compiler to produce p-code.
* Using a modern [XPL-to-C preprocessor](https://sourceforge.net/projects/xpl-compiler/) to run the original compiler on modern computers.
* Writing an emulator for the IBM AP-101S avionics computer

But I'm sure there are many other things that could be done as well.

# <a name="Compiler"></a>The Modern HAL/S Compiler and Preprocessor: yaHAL_S and yaHAL-preprocessor.py

When there's something definitive, I'll describe it here.  In general, though, the HAL/S compiler is under development.  You can read about the progress and status in the separate file yaHAL-S-Development.md.

In the "modern" system, compilation of HAL/S source-code is a two-part process:  The source code is first preprocessed and then the preprocessed code is compiled.  The preprocessing step is not optional, as it works around certain issues with HAL/S source code that the compiler proper is unable to handle, for technical reasons probably not of general interest.  (For the record, some of those issues are:  Special interpretation of column 1 of source lines, including full-line comments and multi-line math format; expansion of macros; some compiler directives, including structure templates and inclusion of source files; non-context-free grammar.)

The preprocessor is a Python 3 program called yaHAL-S-FC.py, while the compiler is a C program called modernHAL-S-FC (on Linux, or else modernHAL-S-FC.exe on Windows or modernHAL-S-FC-macosx on Mac).  The proprocessor automatically invokes the compiler as needed, so it's really only necessary to understand how to invoke the proprocessor:

    yaHAL-S-FC.py [OPTIONS] FILE1.hal [FILE2.hal [...] ]

This produces various files, of which the file yaHAL-S-FC.palmat contains the compiled form of the HAL/S source code, in the PALMAT intermediate language mentioned earlier.  Or more accurately, the output file is a JSON representation of the PALMAT code, and is thus not only human readable (if we wish to be charitable), but also readily importable into alternate types of emulators, or to potential compiler passes capable of producing higher-speed versions of the executable.

Alternatively, the command

    yaHAL-S-FC.py --interactive

invokes the preprocessor/compiler in a way that allows the user to repeatedly input lines of HAL/S code from the keyboard and to compile/execute it immediately on a line-by-line basis, or to analyze it in various ways not available in the batch compilation mode described earlier.

# <a name="Changes"></a>Conventions and Restrictions

## <a name="Comments"></a>Column 1 and Comments

In true HAL/S, column 1 of each source-code line has a special interpretation, while columns 2 and beyond are completely free-form.

The special interpretations for column 1 are:

* `C` indicates a full-line comment.
* `D` indicates a compiler directive.
* `E` indicates an "exponent" line.
* Blank or `M` indicates a "main" line.
* `S` indicates a "subscript" line.

Besides full-line comments, there are also inline comments, which can be contained to a single line or can span multiple lines.  These have column 1 blank, but are delimited by `/*` and `*/`.

Conventionally, in the "modern" environment, we have a need for program comments which can be distinguished from the source-code's shuttle-era program comments.  *By convention*, a modern comment is one whose first comment character is '/'.  This remains a legal HAL/S full-line or inline comment, while still being distinguishable from the original comments.  For example:

    C THIS IS A SHUTTLE-ERA FULL-LINE COMMENT
    C/ This is a modern full-line comment
     ... /* THIS IS A SHUTTLE-ERA INLINE COMMENT */ ...
     ... /*/ This is a modern inline comment */ ...

You may suppose from this that the capitalization plays some role.  It doesn't.  In fact, the legal HAL/S character set includes lower-case alphabetic characters, so all of these comments are legal HAL/S in any era.  However, for whatever reason, none of the original source-code files I've seen employ any lower-case.  I'd venture that that's because software development began at a time when source-code was provided on punch cards, and punch cards could encode upper-case alphabetics but not lower-case alphabetics.  And then once this upper-case habit had been formed, it evolved into standard practice that continued long after punch-cards had fallen by the wayside.  But lower-case has always been legal, even in [the very first (1971) version of the HAL/S language specification](https://www.ibiblio.org/apollo/Shuttle/19730003464.pdf#page=26).

As far as preprocessor actions are concerned, the preprocessor simply converts all full-line comments to inline comments beginning in column 2.  For example,

    C FIRST COMMENT
    C/ Second comment

would be turned into

     /* FIRST COMMENT */
     /*/ Second comment */

Of course, if the original shuttle-era source code contains any full-line comments beginning *immediately* in column 2 after the `C` in column 1, with no intervening whitespace, it will defeat this simple-minded convention of mine!

Regarding the other special characters in column 1, the characters `E`, `M`, and `S` are associated a multi-line mathematical format for writing formulas.  For example, <i>z</i><sub>2</sub>=<i>x</i><sup>2</sup>+<i>y</i><sup>2</sup> in multiline format would look like

    E     2  2
    M z =x +y ;
    S  2

However, each multi-line mathematical expression like this has a corresponding single-line form, in the case of this example

     z$2 = x**2 + y**2 ;

and the preprocessor simply replaces the multi-line expressions by their single-line equivalents.

**Note:**  In principle, there can be any number of `E` lines and any number of `S` lines for a given `M` line in multi-line math format.  The preprocessor only deals with 0 or 1 of each.  This is probably not a problem, since in practice the single-line format was used for writing source code, while the multi-line format was used for reading it.

The final special character it's possible to find in column 1 is `D`, indicating a compiler directive.  Some compiler directives can be handled immediately by the preprocessor, such as source-file inclusions.  In general, however, the preprocessor simply converts these lines to inline comments, and hopes that the compiler will know what to do with them.  For example, consider the compiler directives

    D INCLUDE TEMPLATE LIMIT
    D DEVICE CHANNEL=6 UNPAGED

The former can be immediately acted on by the preprocessor &mdash; think of this example as fetching a single declaration of a structure or an external variable or function called `LIMIT` from a C/C++ header file or a Python module, except that you know only the name of the object whose template you are fetching rather than knowing the filename containing it.  The latter can't be acted on by the preprocessor; it relates to the behavior of output devices.  But in any case, whatever overt action the preprocessor takes, it also turns the directives into inline comments:

     /*D INCLUDE TEMPLATE LIMIT */
     /*D DEVICE CHANNEL=6 UNPAGED */

