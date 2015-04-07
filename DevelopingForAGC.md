![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)

# 1. Developing for the AGC #
The intention of this section is to give you a starting point to develop software for the Apollo Guidance Computer. Just like in the days when the actual software was written for the Command Module and the Lunar Lander we will use simlar but more advanced tools than in the 1960's. Yes even in those days they had an AGC simulation to test the software for the CM or LM. Consider your self lucky to not have to submit a job to test your code and wait for the output. To write code you need to become familiar with the AGC4 assembler language, its I/O channels, have an appropriate assembler and the simulated AGC. The Virtual AGC project provides all of these to learn and experience the thrill of going to the moon from a software engineers point of view. In other sources the AGC for the Lunar Lander is also referred to as the LGC (Lunar Guidance Computer).

The following minimal set of tools are required:

  1. Any text editor to view or edit the AGC source code
  1. yaYUL to compile your AGC assembler code
  1. yaAGC to run and debug your code

For obvious reasons this section does not dwell on the use of a text editor. How ever for demonstration purposes actual code from those days (i.e. Luminary131) will be used when discussing examples.

## 1.1 The Compiler yaYUL ##
The original AGC assembler was called YUL (from "yuletide") because the projected delivery date of the MOD 1A guidance computer, with system software, was Christmas, 1959.  The original YUL assempler eventually supported the MOD 1A, MOD 1B, MOD 3S, MOD 3C, AGC4 (Block I AGC), and two versions of the final Block II AGC.  yaYUL is not so flexible; it only supports the AGC4 assembly language and interpreter language.  In real life, YUL was eventually succeeded by the GAP (General Assembly Program).

### 1.1.1 Invoking yaYUL ###
The YUL assembler can simply be run without any options and a source file.as its argument. However this will result in dumping the listing output to the screen so a typical way to run yaYUL is:

> `yaYUL [options] source-file > program-listing`

where options can be any of the following:
  * --help         This causes the available options to be listed.
  * --force        Forces creation of the core-rope image file, even when fatal errors exist.
  * --max-passes=n This sets the _maximum_ number of passes used by the assembler to the number n.

### 1.1.2 Assembling Luminary131 ###
As a quick example use the following to assemble Luminary131:

```
   cd Luminary131
   yaYUL MAIN.s > Luminary131.lst
   mv MAIN.s.bin Luminary131.bin
   mv MAIN.s.symtab Luminary131.symtab   
```

## 1.2 The Simulator yaAGC ##
yaAGC is a computer program which emulates the behavior of the Apollo Guidance Computer (AGC).  It is a virtual computer (existing within, for example, a desktop PC) which is capable of running software written for the original AGCs used in the Apollo project.  yaAGC emulates only the computer itself, and not the peripheral devices used by the AGC.  For example, the display/keyboard (DSKY) used by the AGC is a peripheral device and is emulated by a completely different computer program called yaDSKY.  Just as the true AGC and DSKY communicated between themselves by mean of wiring, the virtual yaAGC and yaDSKY communicate between themselves using communication channels (sockets) that act like virtual wires.

The development of the yaAGC simulator has been going on for quite some time and has evolved from being just a simulator to a full blown engine to be used in space simulations like Orbiter and now also supports the GDB Console Interpreter Mode (other interpreter modes (m0,m1,m2) will be supported in the future) to allow it to be used in a GUI debugger like Code::Blocks.

### 1.2.1 Running the yaAGC simulation ###
Running a simulation is done by using the yaAGC command. If the classic options are used then running the simulation is as simple as:

> yaAGC --core=BinaryExecutable

The equivalent in gdb compatible mode (see more details below) is as follows:

> yaAGC --nodebug BinaryExecutable

The reason for the nodebug setting is that in gdb mode the default is to behave like a debugger. Besides specifying the core-ropes executeable it is also possible to specify simulation settings to change the base port, change the interlace settings and setting the core dump time frequency. For more details see the yaAGC options under yaAGC Command LIne Options.

Once your have the simulation up and running you typically want to start one of the pheripheral devices or use the uplink to interact with the AGC execution.

### 1.2.2 Debugging with yaAGC ###
Once you have the simulation up and running in debug mode you can use the build-in debugger to set breakpoints, step through the code and examine the AGC memory using GDB commands. Not all commands are supported and not all commands are implemented to handle every possible flavor of the command. However having said that you can still use the GDB manual as background material to learn more about the possible console commands.If the simulation is runnning with debug enable then Ctrl-C will send the SIGINT to the debugger to stop the execution at the current instruction.

#### 1.2.2.1 yaAGC Command Line Options ####
The command line options of yaAGC come in two flavors. The GDB style options and the `classic' style options. The classic style support the original command-line options as designed by Ron Bureky. However to enable and integrate yaAGC as a debugger into an IDE like Code::Blocks (see Visual Debugging Wiki) it is necessary to support the GDB style options. One of the major differences of these modes is that the default mode for the classic style is to autostart the simulation whereas the GDB mode just loads the program and symbol tables. Although a separete symbol table can be loaded yaAGC will try to auto detect the existence of the symbol file and load it if available.

These modes are detected based on the _--core_ option which is required in the classic mode. Although the GDB does have a core option this will not be supported since the core/resume file can also be loaded optionally as the unparameterized second argment (just like with gdb).

The following are the options to be used in gdb compatible command-line mode:

> `yaAGC [options] exec-ropes-file [core-resume-file]`

  * --exec=EXECFILE   Use EXECFILE as the exec-ropes-file
  * --fullname        Output information used by emacs-GDB interface.
  * --symbols=SYMFILE Read symbols from SYMFILE generated by yaYUL.
  * --quiet           Do not print version number on startup.
  * --cd=DIR          Change current directory to DIR.
  * --command=FILE    Execute AGC commands from FILE.
  * --directory=DIR   Search for source files in DIR.
  * --port=N          Change the server port number (default=19697).
  * --nodebug         Disables debugging and run just the simulation
  * --version         Print version information and then exit.
  * --help            Print this message.
  * --interlace=N     Read the socket interface every N CPU instructions.
  * --dump-time=N     Create core image every N seconds (default = 10).
  * --cdu-log         Used only for debugging. Creates the file yaAGC.cdulog containing data related to the bandwidth-limiting of CDU inputs PCDU and MCDU.
  * --debug-dsky      Rather than run the core program, go into DSKY-debug mode. In this mode send pre-determined codes to the DSKY upon receiving DSKY keypresses.
  * --debug-deda      This mode runs the core program as usual, but also responds to messages from yaDEDA and generates fake messages to yaDEDA for testing purposes.
  * --deda-quiet      Used with --debug-deda to eliminate outputs from yaAGC to the DEDA (i.e. lets yaAGC parse the messages being received from the DEDA, but never to send any). This lets "yaAGC --debug-deda --deda-quiet" to be used alongside yaAGS without conflict.
  * --cfg=file        The name of a configuration file.  Presently, the configuration files is used only for --debug-dsky mode.  It would typically be the same configuration file as used for yaDSKY.


However the old classic command-line style (which requires --core) and the classic switches are also available to support existing tools and scripts but not listed in the command-line help to encourage and promote the gdb style. The usage of the classic style is as follows:

> `yaAGC [options] --core=BinaryExecutable`

The additional classic options are:
  * --core=EXECFILE   Use EXECFILE as the BinaryExcutable
  * --symtab=SYMFILE  Read symbols from SYMFILE generated by yaYUL.
  * --debug           Enables debugging since the default for --core is to run the simulation


All options can be passed with either the double dash -- or the single dash since gdb also allows this across different platforms.

#### 1.2.2.2 yaAGC Debug Commands ####

Anywhere addressing comes into play you can use either hexadecimal, decimal, octal or the classic AGC banked address notation.

The following list contains the currently implemented commands with a brief summary of its purpose:

  * info constants --  All constants or those matching REGEXP
  * info line --  Core addresses of the code for a source line
  * info target --  Display target information
  * info files --  Like "info target"
  * info functions --  All functions or those matching REGEXP
  * info registers --  List of registers and contents
  * info all-registers --  List of all registers and contents
  * info channels --  List of channels and contents
  * info io\_registers --  List of I/O registers and contents
  * info threads --  IDs of currently known threads
  * info interrupts --  Show active interrupt
  * info source --  Information about the current source file
  * info sources --  All source files or those matching REGEXP
  * info stack --  Backtrace of the stack
  * info variables --  All variables or those matching REGEXP
  * set prompt --  Set agc's prompt
  * set variable --  assign result to variable or address
  * break --  Set breakpoint at specified line
  * delete --  Delete some breakpoints
  * tbreak --  Set a temporary breakpoint
  * disable --  Disable some breakpoints
  * enable --  Enable some breakpoints
  * watch --  Set a watchpoint
  * disassemble --  Disassemble a specified section of memory
  * inspect --  Same as "print" command
  * print --  Print value of expression EXP
  * output --  Like "print" but no history and no newline
  * x --  Examine memory: x/FMT ADDRESS
  * list --  List specified function or line
  * step --  Step program until it reaches a different source line
  * next --  Step program
  * cont --  Continue program being debugged
  * run --  Start debugged program
  * quit --  Exit agc
  * bt --  Print backtrace of all stack frames
  * where --  Print backtrace of all stack frames
  * log --  Log instructions to a log file
  * getoct --  Converts EXP into octal value
  * inton --  Set interrupt request
  * intoff --  Clear interrupt request
  * show version --  Show what version of yaAGC this is

#### 1.2.2.3 Example Debugging Session ####

