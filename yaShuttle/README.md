*This folder is work in progress and is not presently useful for anything ... beginning with the fact that Space Shuttle software is not presently available.  The same comment applies to the Space Shuttle web-pages mentioned below.*

# Table of Contents

* [What's This?](#WhatIs)
* [Some Background](#Background)
* [Roadmap](#Roadmap)
    * [Phase 1](#Phase1)
    * [Phase 1.1](#Phase11)
    * [Phase 2 and Beyond](#Phase2)
* [The Modern HAL/S Compiler: yaHAL-S](#Compiler)
* [Changes To the Language](#Changes)
    * [Program Comments](#Comments)
* [The p-Code Format:  p-HAL/S](#pCode)
* [The PHase 1 Emulator:  yaPASS.py](#Emulator1)
* [The Phase 1.1 Emulator:  yaGPC.c](#Emulator11)

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

1. Creation of a p-code format (p-HAL/S), suitable for distributing emulation-ready but unmodifiable Shuttle Software, from which source code is not recoverable.  This is seen as an ITAR-compatible method of open distribution, since the distributed p-code contains neither targeting capabilities, nor the means to add such capabilities.
2. Creation of a "modern" compiler (yaHAL-S) for the HAL/S language, producing p-HAL/S p-code.
3. Creation of an emulator (yaPASS.py) for executing p-HAL/S p-code and emulating certain Shuttle crew-interface peripherals, specifically the multifunction displays and keyboards.  This emulation is not required to be time-efficient or suitable for integration into a spaceflight-simulation system.

## <a name="Phase11"></a>Phase 1.1

1. Creation of a fast emulation subroutine (yaGPC.c) for executing p-HAL/S p-code, but with no direct means of emulating peripherals.  Instead, there will be some method for developers to interface to their own peripheral devices and/or databuses.  This is intended to be an efficient means of integration for spaceflight-simulation systems.

## <a name="Phase2"></a>Phase 2 and Beyond

This is an open area, as many additional developments are possible.  Here's a list of some of the possibilities:

* The original compiler, HAL/S-360 (HAL/S-FC) ran on an IBM System/360 mainframe.  The [open source Hercules System/370 emulator](http://www.hercules-390.org/) is available, as is the [MVS operating system](http://www.ibiblio.org/jmaynard/), as is the [XPL compiler for MVS](https://www.jaymoseley.com/hercules/compilers/list_of.htm#XPL), so it's possible at least in principal to run the original HAL/S compiler.
* Exploiting the original compiler to produce p-code.
* Using a modern [XPL-to-C preprocessor](https://sourceforge.net/projects/xpl-compiler/) to run the original compiler on modern computers.
* Writing an emulator for the IBM AP-101S avionics computer

But I'm sure there are many other things that could be done as well.

# <a name="Compiler"></a>The Modern HAL/S Compiler: yaHAL-S

When there's something definitive, I'll describe it here.  For now, though, the compiler is under development.  You can read about the progress and status in the separate file yaHAL-S-Development.md.

# <a name="Changes"></a>Changes To the Language

## <a name="Comments"></a>Program Comments and Compiler Directives

In true HAL/S, comments and compiler directives take one of the following forms:

* `C` in column 1 indicates a full-line comment.
* Anything in column 2 and beyond that's delimited by `/*` and `*/` is a comment.
* `D` in column 1 indicates a compiler directive.

Additionally, though, we have the need for "modern" comments that weren't present originally, and we need to be able to distinguish those from the original comments.  For example, we need additional comments to associate the code with the Virtual AGC Project, to indicate the provenance, to indicate the (modern) change history, to describe any licensing or distribution issues (copyright, ITAR), and so on, none of which is covered by the original program comments.  Thus, we've added a third type of comment:

* `#` in column 1 indicates a full-line *modern* comment.

But as mentioned before, the modern compiler cannot recognize the special nature of column 1, so we have to transform notations aligned to column 1 into something palatable to the compiler.  That's done by means of the preprocessor, **yaHAL-reprocessor.py** in the yaShuttle/yaHAL-S/ folder of the software repository.  In the case of full-line comments and compiler directives, the preprocessor transforms them as follows for consumption by the compiler:

* `C` in column 1 &rarr; `//`.
* `#` in column 1 &rarr; `///`.
* `D` in column 1 &rarr; `//D`.

While these new notations remain in column 1, to the compiler they are position-independent, and would be treated the same regardless of which column they appeared in:  i.e., the remainder of the line is not parsed as HAL/S code.

# <a name="pCode"></a>The p-Code Format:  p-HAL/S

TBD

# <a name="Emulator1"></a>The Phase 1 Emulator:  yaPASS.py

I'm not sure there's any reason to go into much detail about this, but the program consists basically of two Python modules, namely shuttleCrewInterface.py (which emulates displays and keyboards) and gpc.py (which emulates the CPU and executes the p-code).  The two interact via Python thread-safe queues, which emulate the Shuttle's databuses.  Button presses in the crew interface are conveyed to the CPU by passing data in one direction, while commands for displaying data on the displays are passed from the CPU to the crew interface by messages in the opposite direction.

TBD

# <a name="Emulator11"></a>The Phase 1.1 Emulator:  yaGPC.c

TBD
