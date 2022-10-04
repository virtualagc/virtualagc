**Important note:**  This is *experimental* code that's under initial development.  It presently does only a portion of the job it's intended for.

# Introduction

This is an attempt to create a disassembler for octal dumps of AGC core ropes, facilitating recreation of their original source code.  As such, I hope it will be a tool for a very limited purpose, and not really a general-purpose utility.

Disassembly is envisaged as having the following stages:

  * Rough disassembly into numerical form.  In other words, all "basic" and "interpreter" instructions identified correctly, but their operands being numerical in nature.
  * Symbol assignments.
  * Final regeneration with program comments.

None of these steps can be accomplished perfectly if performed automatically, for a variety of reasons, so the best case is simply to reduce the amount of manual intervention needed to a minimum.  Of course, there is no guarantee of perfect accuracy in the final two steps even if there is human intervention, though errors in these steps do not affect the accuracy of core ropes assembled from the reconstructed AGC source code.

# Program: disassemblerAGC.py

This is the program which attempts to perform the rough disassembly, in which basic and interpretive instructions are correct, but their arguments are represented only numerically.

The program is partitioned into a number of modules from which it imports functionality, including

  * disassembleBasic.py &mdash; disassemble a single basic (i.e., assembly language) memory word.
  * disassembleInterpretive.py &mdash; disassemble a memory word containing 1 or 2 packed interpreter instructions, plus all of the memory words containing the arguments for those instructions.
  * engineering.py &mdash; some debugging code used only for initial development.
  * parseCommandLine.py &mdash; parse disassemblerAGC.py's command-line arguments.
  * readCoreRope.py &mdash; read a core rope into memory.  Accepts .binsource files and .bin files (either original format or "hardware" format).
  * searchSpecial.py &mdash; perform pattern matching to find the locations of certain infrastructure subroutines in the core rope, such as INTPRET, BANKCALL, FINDVAC, and so on.
  * semulate.py &mdash; does as much CPU emulation as is possible at assembly time, to track changes to memory-bank selection registers.
  * registers.py &mdash; contains lists of named CPU registers and i/o channels.

However, among these only the top-level program (`disassemblerAGC.py`) is directly executable, and it is the only file (in Linux or Mac OS) which has its executable permission-bit set.

The command

    disassemblerAGC.py --help

provides a list of the options.

Additionally, there are test files with names of the form *.spec which can be used with diassemblerAGC.py's --spec command-line switch.

# Program: TBD

TBD

# Envisaged Workflow

## Introduction

The program disassemblerAGC.py is not intended to be a complete disassembly system for the AGC, but rather a tool in a workflow intended to solve a specific problem, which is as follows.  Suppose that an octal dump of a core-rope module of some AGC software version is available.  We would like to provide AGC source code which assembles to those given octal values.  Moreover, we would like it to be fully AGC source code, with symbolic program labels and variable names, as well as program comments.

The underlying assumption is that the core-rope module is of a software version which is similar but not identical to other software versions existing in our collection.  Large chunks of the code will therefore be identical to existing code, and simply be pasted in, with appropriate adjustment of memory locations.  The problem is making the identification between matching chunks of code in the two software versions, so we know how those addresses must be changed.

The workflow which disassemblerAGC.py aids is essentially the following.  (Sample invocations of disassemblerAGC.py to achieve these steps are given after the summary.)

 1. Determine the memory locations of various subroutines common to all (or at least a wide range) of AGC software versions.  I refer to these as the "special subroutines".  There is a built-in mechanism for 25-30 such common subroutines built into disassemblerAGC.py, which has been tested across a variety of software versions.  (Retread 44, Aurora 12, Sunburst 37, Comanche 55, Luminary 210, Artemis 72).  Presumably, the number of supported special subroutines will increase over time.
 2. Choose an AGC software version (or versions) to be used as baseline(s) for reconstructing the software of the dumped rope module.  For example, in reconstructing a Comanche 72 dump, the baseline versions might be the (fully known) Comanche 55 software and the (incomplete but partially reconstructed) Comanche 67 software.
 3. For the *baseline* software version(s), create "specifications" for all of the subroutines it's desirable to located within the dumped rope.  This needn't be done all at once; for example, it could be done a bank at a time.  The "specification" is basically just a summary of information from the assembly listings of the baseline, and is very quick and easy to construct, although the more subroutines that are chosen, the more time it takes to do so.  Eventually, it may be possible to automate this process, but for now it is manual.
 4. Use disassemblerAGC.py to process the specification file(s), which creates file(s) of "patterns" for pattern matching.
 5. Use disassemblerAGC.py to search the dump of the core rope.

The net result of all this is basically just a list of addresses within the core rope corresponding to the symbols chosen from the baseline versions, or else notifications that the symbols weren't found.  Of course, this isn't *complete*, since all it does is find a selection of matching addresses, without performing the work of using that info to fully fix up symbol tables or to import code.  But first things first!

Before learning the specific steps needed for disassemblerAGC.py to perform these steps, I'd like to comment on how disassemblerAGC.py receives the baseline software or else the dump of the core rope.  In either case, it is a matter of reading either:

  * A .binsource file; or
  * A .bin file, in the format produced by yaYUL; or
  * A .bin file, is "hardware" format.

This is always done on the standard input.  By default, a .binsource file is assumed, but adding the command-line switch `--bin` chooses a .bin (yaYUL) file instead, while the switch `--hardware` chooses a .bin (hardware) file.  I have only used .binsource files extensively, and they are the only ones which presently allow detection of "unused" rope locations vs locations that are merely 00000, so all of the examples I give below will assume that a .binsource file is being read.

## Determining Memory Locations of the Special Subroutines

    disassemblerAGC.py --special <ROPEDUMP.binsource

For example:

    disassemblerAGC.py --special <Comanche055.binsource

You get a list that looks something like this:

    2PHSCHNG = 5372
    ABORT2 = 5730
    ALARM = 5650
    ...
    UPFLAG = 5546
    USPRCADR = 4757
    WAITLIST = 5245

## Creating a Specifications File for a Baseline AGC Software Version

A specification file is simply an ASCII file with a sequence of lines, one for each symbol (program label) of interest, of the form:

    SYMBOL BANK START [END] ["I"]

`SYMBOL` is the literal name of the program label.  `BANK` is a 2-digit octal number in the range 00 through 43.  `START` (and `END` if present) are 4-digit octal numbers in the range 2000 through 3777.  `START` gives the address (within the baseline) of the `SYMBOL`.  `END`, meanwhile, is the first address following the subroutine.  The reason `END` is optional is that if it is omitted, the `START` from the next symbol will be used.  This makes it quick and easy to read the information off of an assembly listing.  

Note that addresses in fixed-fixed continue to use this convention, rather than being represented by the address ranges 4000 through 7777.

By default, the *first* instruction in `START` is assumed to be a basic instruction. If the very first instruction in `START` is interpretive, however, the literal field `"I"` is added.  (Sometimes an I is just an I.)   The remainder of the subroutine can be any mixture of basic and interpreter code, as long as there are orderly transitions between them using `TC INTPRET` and `EXIT`.  At some point, it may be necessary to add some additional hinting to the specification so that the non-orderly cases can be handled as well, but there's no such facility as of this moment.

One thing to beware of in omitting the `END` parameter, is that you want the patterns to be long enough so that there are unique matches, and the interval between two successive symbols may not be long enough to achieve that.  For example, among the "special" subroutines, `BANKCALL` and `IBNKCALL` actually have *identical* patterns, and the only way disassemblerAGC.py distinguishes them is that `IBNKCALL` is known to always follow `BANKCALL` in memory.  Unfortunately, that's not something you're able to specify in specification files.  On the other hand, while I said above that `END` is the end of the subroutine, that's not really so.  It's merely the end of the *pattern* being matched.  So you could bunch several subroutines within a single `START` to `END` interval if you liked, thus making the match-pattern much longer and presumably more unique.

A sample specifications file is Comanche055.specs in the source tree.  I'd lean towards recommending creating separate specification files for each bank of the baseline, and naming them with a convention like AGCVERSION-BANKNUM.specs, such as Comanche055-02.specs for bank 02.

## Creating a Pattern-Matching File from a Specifications File

The command is 

    disassemblerAGC.py --specs=SPECIFICATION.spec <BASELINE.binsource >PATTERNS.patterns

For example,

    disassemblerAGC.py --specs=Comanche055.spec <Comanche055.binsource >Comanche055.patterns

You never have any reason I'm aware of to look at the .patterns file, but it looks something like this:

    BANKCALL basic
            DXCH_
            INDEX_Q
            CA_A
            INCR_Q
    SWCALL basic
            TS_L
            LXCH_FB
            MASK_
            XCH_Q
            DXCH_
            INDEX_Q
            TC_
            XCH_
            XCH_FB
            XCH_
            TC_
    ...
            DCOMP_GOTO
            _
            SLOAD_BON
            _
            _
            _
            DSU_
            _
            STODL_
            _
            STCALL_
            _


Basically, this is just the disassembled code, with all operands that are numerical and couldn't be resolved down to a known symbol being discarded, and an underline being placed between the opcode and operand (or left and right interpretive opcode).  Symbols which are resolved in this pattern are just named CPU registers and i/o channels, along with the "special" subroutines.

If you were to examine the patterns in detail, you may notice errors.  Well, the disassembler is imperfect.  Fortunately, it's not *terribly* important that the disassembly be 100% correct.  All we really require for pattern matching is that disassembly hashes uniquely and that the errors are consistent.

## Matching the Baseline Patterns to the Dumped Rope

The command is

    disassemblerAGC.py --find=PATTERNS.patterns <ROPEDUMP.binsource

For example,

    disassemblerAGC.py --find=Comanche055.patterns <Comanche072-B2.binsource

The search is entirely brute force, and does take some time to complete.  By default, it searches banks 00, 01, ..., 43 for the patterns whose first instruction is basic, and then searches banks 00, 01, ..., 43 again for the patterns whose first instruction is interpretive.

Within each bank, it simplemindedly disassembles a range starting at address 2000 in the bank, and sees if there are matches to any of the patterns.  Then it *restarts* the disassembly at address 2001, 2002, and so on, in succession.

If you have a good idea of what banks in the dumped rope need to be searched, you can override this process somewhat with additional command-line switches.  The switch

    --prio=BANK1,BANK2,...,BANKN

tells the disassembler to search the selected banks *first* (in the order listed) before proceeding to the other banks not listed.  The switch

    --only=BANK1,...,BANKN

tells the disassembler to search *only* the listed banks and to ignore all others.  For example, if you had only (say) module B2 of a Comanche 72 rope dump, you could use the switch

    --only=06,07,10,11,12,13

to limit pattern matching to just the banks of rope module B2.

For example, if you match Comanche055.patterns against Comanche055.binsource (from which it was originally made), all symbols specified in Comanche055.spec will be found, resulting in an output like

    Checking bank 00 for basic
    Checking bank 01 for basic
    Checking bank 02 for basic
    BANKCALL = 02,2662
    SWCALL = 02,2666
    POSTJUMP = 02,2701
    BANKJUMP = 02,2704
    POODOO = 02,3721
    ABORT2 = 02,3730
    Checking bank 03 for basic
    ...
    Checking bank 33 for interpretive
    Checking bank 34 for interpretive
    Checking bank 35 for interpretive
    Checking bank 36 for interpretive
    S17.1 = 36,2012

On the other hand, if you limited the search to just bank 35, using

    disassemblerAGC.py --find=Comanche055.patterns --only=35 <Comanche055.binsource

you'd instead get

    Checking bank 35 for basic
    P17 = 35,3151
    DISP45 = 35,3267
    COMPTGO = 35,3304
    Checking bank 35 for interpretive
    BANKCALL (basic) not found
    SWCALL (basic) not found
    POSTJUMP (basic) not found
    BANKJUMP (basic) not found
    POODOO (basic) not found
    ABORT2 (basic) not found
    NEWDELHI (basic) not found
    TRANSPOS (interpretive) not found
    S17.1 (interpretive) not found

