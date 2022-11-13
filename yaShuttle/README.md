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

Here's my current plan, subject to change.

A Backus-Naur Form (BNF) description of the HAL/S language appears in the contemporary documentation, in (AppendiX G of the HAL/S Language Specification](https://www.ibiblio.org/apollo/Shuttle/HAL_S%20Language%20Specification%20Nov%202005.pdf#page=209).  The link is to the latest version of the specification that's available, although as far as I can tell, the same description appears in the very earliest available version, as well as in the original source code, modulo typos.

The documented BNF description is actually incomplete, in the sense that it is missing the following "nonterminals", most or all of which are elementary types:

<pre>
      &lt;EMPTY>
      &lt;NO ARG ARITH FUNC>
      &lt;ARITH FUNC>
      &lt;NO ARG CHAR FUNC>
      &lt;CHAR FUNC>
      &lt;NO ARG BIT FUNC>
      &lt;BIT FUNC>
      &lt;NO ARG STRUCT FUNC>
      &lt;STRUCT FUNC>
      &lt;ARITH ID>
      &lt;CHAR ID>
      &lt;BIT ID>
      &lt;STRUCTURE ID>
      &lt;LABEL>
      &lt;SIMPLE NUMBER>
      &lt;COMPOUND NUMBER>
      &lt;CHAR STRING>
      &lt;TEXT>
      &lt;EVENT>
      &lt;IDENTIFIER>
      &lt;LEVEL>
      &lt;% MACRO NAME>
      &lt;DCL LIST>
      &lt;STRUCT TEMPLATE>
</pre>

At any rate, those missing nonterminals need to be reverse-engineered and their rules created, into order to get a complete BNF description of the language.  

Having done that, I plan to use the [BNF Converter (BNFC)](https://bnfc.digitalgrammars.com/) compiler-compiler to produce a HAL/S compiler frontend.  Two additional major steps are needed:

1. The BNF description cannot be used directly by BNFC, and instead needs first to be converted into an intermediate form known as [Labeled BNF (LBNF) grammar](https://bnfc.readthedocs.io/en/latest/lbnf.html)
2. A compiler backend has to be created which can convert compiler frontend's output to the target form, which in this case is p-HAL/S p-code.

More TBD.

# The p-Code Format:  p-HAL/S

TBD

# The PHase 1 Emulator:  yaPASS.py

I'm not sure there's any reason to go into much detail about this, but the program consists basically of two Python modules, namely shuttleCrewInterface.py (which emulates displays and keyboards) and gpc.py (which emulates the CPU and executes the p-code).  The two interact via Python thread-safe queues, which emulate the Shuttle's databuses.  Button presses in the crew interface are conveyed to the CPU by passing data in one direction, while commands for displaying data on the displays are passed from the CPU to the crew interface by messages in the opposite direction.

TBD

# The Phase 1.1 Emulator:  yaGPC.c

TBD
