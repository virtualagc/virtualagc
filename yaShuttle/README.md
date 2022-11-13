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

* The original compiler, HAL/S-360 (HAL/S-FC) ran on an IBM System/360 mainframe.  The [open source Hercules System/370 emulator](http://www.hercules-390.org/) is available, as is the [MVS operating system][http://www.ibiblio.org/jmaynard/], as is the [XPL compiler for MVS](https://www.jaymoseley.com/hercules/compilers/list_of.htm#XPL), so it's possible at least in principal to run the original HAL/S compiler.
* Exploiting the original compiler to produce p-code.
* Using a modern [XPL-to-C preprocessor](https://sourceforge.net/projects/xpl-compiler/) to run the original compiler on modern computers.
* Writing an emulator for the IBM AP-101S avionics computer

But I'm sure there are many other things that could be done as well.

# The Modern Compiler: yaHAL/S

TBD

# The p-Code Format:  p-HAL/S

TBD

# The PHase 1 Emulator:  yaPASS.py

TBD

# The Phase 1.1 Emulator:  yaGPC.c

TBD
