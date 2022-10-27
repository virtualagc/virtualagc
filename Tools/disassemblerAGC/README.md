# Introduction

This is an attempt to create a disassembler for octal dumps of AGC core ropes, facilitating reconstruction of their original source code.  It targets a pretty-specific concept of a workflow for that disassembly process rather than aiming to be a general-purpose tool.  As far as AGC software prospectively available to us at some point, there are three different versions of the AGC language which are incompatible to a greater or lesser degree.  Ranked from earliest to latest, they are:

* Block I (Sunrise, Corona, Solarium, Sunspot, *et al.*)
* BLK2 (Retread, Sundial, *et al.*)
* Block II (Aurora, Sunburst, Luminary, Colossus, Comanche, Artemis, Skylark, *et al.*)

At the moment, the work on the disassembler applies only to Block II, which covers the vast majority of AGC software available to us. However, the other two are important as well, for recovery of Sundial, Sunrise, and possibly Corona source code in the future.  Therefore, support for BLK2 and Block I will hopefully be added as well.

Disassembly of a rope-memory dump is envisaged as having the following stages:

 1. Creation of *patterns* of selected baseline versions of AGC source code believed to be similar to the rope memory's software version.
 2. *Pattern matching* to determine which sections of baseline code correspond to which sections of the rope memory; i.e., assignment of rope-memory addresses to baseline symbols.
 3. Cut-and-paste of baseline source code to create reconstructed rope source code.

The latter is a manual operation, or at least outside of the scope of what I'm attempting here, but the first two stages can be mostly automated according to our discussion here.

# Provided Software

The there are are four upper-level programs,

* disassemblyAGC.py &mdash; a Python 3 disassembler and pattern-matcher for comparing two AGC software versions.
* specifyAGC.py &mdash; a Python 3 generator of "specifications" files for disassemblerAGC.py's all-important `--find` option.
* workflow.sh &mdash; a bash script that manages commonly-needed sequence of disassemblyAGC.py and specifyAGC.py operations.
* pieceworkAGC.py &mdash; a Python 3 program that can combine bits and pieces of AGC bin files (either "normal" or "hardware" varieties) to produce another AGC bin file (always in the "hardware" variety).

The top-level programs are directly executable from a command line.  They rely on a number of additional Python modules that aren't directly executable by the user:

  * disassembleBasic.py &mdash; disassemble a single basic (i.e., assembly language) memory word.
  * disassembleInterpretive.py &mdash; disassemble a memory word containing 1 or 2 packed interpreter instructions, plus all of the memory words containing the arguments for those instructions.
  * engineering.py &mdash; some debugging code used only for initial development.
  * parseCommandLine.py &mdash; parse disassemblerAGC.py's command-line arguments.
  * readCoreRope.py &mdash; read a core rope into memory.  Accepts .binsource files and .bin files (either original format or "hardware" format).
  * searchSpecial.py &mdash; perform pattern matching to find the locations of certain infrastructure subroutines in the core rope, such as INTPRET, BANKCALL, FINDVAC, and so on.
  * semulate.py &mdash; does as much CPU emulation as is possible at assembly time, to track changes to memory-bank selection registers.
  * registers.py &mdash; contains lists of named CPU registers and i/o channels.

As a general note, I'd observe that the code for some of these files is a total spaghetti-like mess, as *ad hoc* condition turned out to be piled atop *ad hoc* condition.

All of the Python programs accept a `--help` option that provides a description of the various other options available, some of which are also described in the text that follow:

    disassemblerAGC.py --help
    specifyAGC.py --help
    pieceworkAGC.py --help

Notice particularly the following disassemblerAGC.py options which I don't believe are actually described much, if at all, in this README:

* `--dump`, which dumps the entire core in octal form.  This lets you use disassemblerAGC.py as an viewer for bin files.
* `--dtest`, which lets you disassemble a selectable range of memory.
* `--dloop` is like `--dtest`, but with an input loop for manually inputting disassembly ranges repeatedly without having to rerun the program every time, as well as having a couple of additional convenience features, such as using symbolic names for the subroutines to be disassembled, and the ability to disassemble *all* of the subroutines identified via pattern matching.
* `--symbols=SYMBOLFILE` allows `--dtest` or `--dloop` to try and replace numeric operands with symbolic ones.  Every time `disassemblerAGC.py --find=...` is run, it produces as a byproduct a SYMBOLFILE called disassemblerAGC.symbols which is suitable for use with `--symbols`.

Note that with `--dloop`, the syntax used is

    disassemblerAGC.py --dloop=BASELINE.binsource

rather than
    
    disassemblerAGC.py --dloop <BASELINE.binsource

As far as workflow.sh is concerned, it is presently invoked as

    workflow.sh BASELINE [OPTIONS]

I mention this for the sake of completeness.  There are many examples given later, and it's better to adapt those rather than to invent your own OPTIONS from scratch.  Nevertheless, the following OPTIONs are presently supported:

* General:  `--block1`, `--blk2`, `--bin`, `--hardware`.  (The latter two options additionally cause a ROPE.bin file to be used, in place of the default ROPE.binsource.)
* For `specifyAGC.py` alone:  `--min`, `--invent`.
* For `disassemblerAGC.py --find` alone:  All others. 

# Envisaged Workflow<a name="Envisaged"></a>

## In a Nutshell

Without further ado, I'll describe the workflow in the tersest possible terms here.  If you like, the remaining subsections under this "Envisage Workflow" section flesh out the topic much more, and [a later section](#Comanche072B2) provides a still-more-detailed example.

The task at hand is this:  Given an octal dump of a set of physical rope-memory modules, we want to reconstruct the AGC source code that would assemble to give that identical rope.  I'll refer to this dump "the Rope".  This reconstruction is to be performed with the aid of the already-known source code of a similar AGC software version (or versions), which I'll call "the Baseline(s)".  In short, we want to reconstruct source code for the Rope by using the Baseline(s).

Requirements:

* The Rope, in the form of a binsource (or bin) file, which for the sake of discussion I'll assume is ROPE.binsource.
* The Baseline, in the form of its assembly listing, as output by yaYUL, which I'll assume is BASELINE.lst; and its rope file, either transcribed manually or else output by yaYUL, which I'll assume is BASELINE.binsource.

The basic processing chain is as follows.

    specifyAGC.py <BASELINE.lst >BASELINE.specs [OPTIONS]
    disassemblerAGC.py --specs=BASELINE.specs <BASELINE.binsource >BASELINES.patterns
    disassemblerAGC.py --find=BASELINE.patterns <BASELINE.binsource --check=BASELINE.lst >BASELINE.matches [OPTIONS]
    disassemblerAGC.py --find=BASELINE.patterns <ROPE.bin >ROPE.matches --parity --hardware [OPTIONS]

The first two step builds the pattern file used for all subsequent pattern-matching operations.  The third step is a check of that process; its report file (BASELINE.matches) will generally indicate that not all symbols were matched properly, and it's incumbent on you to determine the necessary command-line options which cause the test to pass 100%.  (More on that below.)  The fourth step is the actual attempt to discover information about the ROPE.

The only useful option possible with specifyAGC.py is the `--min=N` switch (present default is `--min=12`), which basically sets a lower limit to the number of words in a named chunk of source code that the disassembler will attempt to deal with.

The first three steps listed can be accomplished by the single command

    cd .../BASELINE
    workflow.sh BASELINE [OPTIONS]

Make sure that the Tools/disassemblerAGC/ directory is in your PATH first.  The OPTIONS mentioned are the ones for specifyAGC.py and/or those relevant to disassemblerAGC.py's `--specs` or `--find` functionality.  

For another, there's often a handful of code chunks in an AGC software version that are so similar to each other that they can be mistaken for each other during matching.  That's why the testing mentioned above usually fails when no command-line options are used.  One way to get around this a little bit is to use a bigger `--min` setting in specifyAGC.py, since longer patterns are less likely to be confused with each other.  But this may not be enough; long jump tables &mdash; i.e., sequences of `TC` or `TCF` instructions &mdash; are a good example of that, because you're unlikely to want to make the search patterns longer than the biggest jump tables in the code.  The disassembler has some built-in heuristics to try to work around the problem, but in spite of everything it's still possible for the condition to occur.  Here are the disassembler command-line options that rescue you:

* The `--skip=S` option causes the first match for code-chunk `S` to be skipped during matching. And repeating the option multiple times causes multiple matches of code-chunk `S` to be skipped.
* The `--hint=S1@S2` option (with a literal '@') tells the disassembler that code-chunk `S1` is at a higher memory location than `S2` &mdash; i.e., that it is either at a higher bank, or else at a higher offset within the same bank.  As many of these can be used as you like.
* The `--ignore=S` option simply says that code chunk `S` is too irritating to deal with, and just to ignore it completely during matching.
* The `--avoid=BB,NNNN-MMMM` option says to avoid the address range during matches.  This is very much a last resort, but I've seen it arise in the following way:  tables of `CADR` pseudo-ops disassemble the same way as jump tables of `TC` instructions do, causing jump tables to erroneously match them.  The other OPTIONS listed above aren't effective in avoiding this problem.

In my (limited) experience, `--hint` solves the majority of problems.

For example (as of *this* writing), if the Comanche 55 baseline is processed using `--min=8` within specifyAGC.py, the following switches are needed for disassemblerAGC.py:

    --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=MOVEPLEM@MOVEALEM --hint=MOVEALEM@SETMOON \
    --hint=J22@J21 --hint=J21@RWORD --hint=RWORD@YWORD --hint=3DAPCAS@2DAPCAS --ignore=SOPTION1

Whereas with `--min=12` (the default) you need only the simpler combination of options,

    --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP

Unfortunately, applying the same switches when trying to match the ROPE against the BASELINE may not work equally well as when matching the BASELINE vs the BASELINE, since some of the problematic chunks of code may have been moved around between versions.  But life isn't perfect, is it? 

The next few subsections are some worked examples of generating match-patterns using workflow.sh, as of *this* writing.  I find that as I find and fix bugs in disassemblerAGC.py and specifyAGC.py, the command-line switches for workflow.sh sometimes change slightly, so that may be true of the worked examples as well. A more fully-worked-out example involving comparison of BASELINE vs ROPE appears later, in [a later section](#Comanche072B2).

*After* the match-patterns are generated is when the final command (of the four listed above) comes into play

    disassemblerAGC.py --find=BASELINE.patterns <ROPE.bin >ROPE.matches --parity --hardware [OPTIONS]

A rope dump will typically be in `--hardware` format rather than `--bin` or binsource format, and will will typically include parity bits.  That will always be the case for ROPE files created by the pieceworkAGC.py program.  But of course, if not, then use of the `--hardware --parity` switches needs to be reconsidered.  Also, once you think the matching process is working as well as it can, it might not hurt to throw in `--check=BASELINE.lst`, just to see how the symbols identified in ROPE.bin differ from the BASELINE.

### Baseline Solarium 55

    workflow.sh Solarium055 --block1 --hint=BMN1@UNAJUMP --skip=GOGETUNB

### Baseline Retread 44, Retread 50, and DAP Aurora 12

    workflow.sh Aurora12        --blk2 --hint=UNAJUMP@MISCJUMP --hint=MISCJUMP@INDJUMP \
                                --hint=PDVL@PDDL --hint=JACCESTR@JACCESTQ

Retread 44 can be processed using the same switches as for DAP Aurora 12.  So can Retread 50, except that we have no binsource file for it, but rather a bin file, so the command reads instead

    workflow.sh Retread50 --bin --blk2 --hint=UNAJUMP@MISCJUMP --hint=MISCJUMP@INDJUMP \
                                --hint=PDVL@PDDL --hint=JACCESTR@JACCESTQ

### Baseline Sunburst 37

    workflow.sh Sunburst37 --hint=R22,2112@MISCJUMP --hint=MISCJUMP@INDJUMP --hint=INDJUMP@UNAJUMP \
                           --avoid=05,2136-2176 --hint=PDVL@PDDL --hint=JACCESTR@JACCESTQ \
                           --hint=TBRIGAL@INDJUMP --skip=TBRIGAL --skip=TBRIGAL

### Baseline Colossus 237

    workflow.sh Colossus237 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE \
                            --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP --skip=9DWTESTJ \
                            --hint='NEWJ(S)@PCOPYCYC' --hint='NEWY(S)@NEWJ(S)'

### Baseline Comanche 55<a name="Comanche055"></a>

    workflow.sh Comanche055 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE \
                            --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP --skip=9DWTESTJ

### Baseline Luminary131

    workflow.sh Luminary131 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=NEWPHASE@MISCJUMP \
                            --skip=NEWPHASE  --hint=AFTRGUID@NEWPHASE

### Baseline Artemis 72

    workflow.sh Artemis072 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE \
                           --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP --skip=9DWTESTJ

### Baseline Luminary 210

    workflow.sh Luminary210 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=NEWPHASE@MISCJUMP \
                            --skip=NEWPHASE  --hint=AFTRGUID@NEWPHASE

## Background

The program disassemblerAGC.py is not intended to be a complete disassembly system for the AGC, but rather a tool in a workflow intended to solve a specific problem, which is as follows.  Suppose that an octal dump of a core-rope module of some AGC software version is available.  We would like to provide AGC source code which assembles to those given octal values.  Moreover, we would like it to be fully AGC source code, with symbolic program labels and variable names, as well as program comments.

The underlying assumption is that the core-rope module is of a software version which is similar but not identical to other software versions existing in our collection.  Large chunks of the code will therefore be identical to existing code, and simply be pasted in, with appropriate adjustment of memory locations.  The problem is making the identification between matching chunks of code in the two software versions, so we know how those addresses must be changed.

The workflow which disassemblerAGC.py aids is essentially the following:

 1. Determine the memory locations of various subroutines common to all (or at least a wide range) of AGC software versions.  I refer to these as the "special subroutines".  There is a built-in mechanism for 25-30 such common subroutines built into disassemblerAGC.py, which has been tested across a variety of software versions. 
 2. Choose an AGC software version (or versions) to be used as baseline(s) for reconstructing the software of the dumped rope module.  For example, in reconstructing a Comanche 72 dump, the baseline versions might be the (fully known) Comanche 55 software, along with additional baselines Artemis 72 and Luminary 131.
 3. For the *baseline* software version(s), create "specifications" for all of the subroutines it's desirable to locate within the dumped rope.  This can be done in an automated way (program specifyAGC.py) or manually.  If manually, it needn't be done all at once; for example, it could be done a bank at a time.  The "specification" is basically just a summary of information from the assembly listings of the baseline, and can be very quick and easy to construct, although the more subroutines that are chosen, the more time it takes to do so. It also becomes much more difficult to do manually if matches for erasable locations are desired.  So all in all, the automated process is usually best.
 4. Use disassemblerAGC.py to process the specification file(s), which creates file(s) of "patterns" for pattern matching.
 5. Use disassemblerAGC.py to search the dump of the core rope.

The net result of all this is basically just a list of addresses within the core rope corresponding to the symbols chosen from the baseline versions, or else notifications that the symbols weren't found.  Of course, this isn't *complete*, since all it does is find a selection of matching addresses, without performing the work of using that info to fully fix up symbol tables or to import code.  But first things first!

Before learning the specific steps needed for disassemblerAGC.py to perform these steps, I'd like to comment on how disassemblerAGC.py receives the baseline software or else the dump of the core rope.  In either case, it is a matter of reading either:

  * A .binsource file; or
  * A .bin file, in the format produced by yaYUL; or
  * A .bin file, is "hardware" format.

This is always done on the standard input.  By default, a .binsource file is assumed, but adding the command-line switch `--bin` chooses a .bin (yaYUL) file instead, while the switch `--hardware` chooses a .bin (hardware) file.  I have only used .binsource files extensively, and they are the only ones which presently allow detection of "unused" rope locations vs locations that are merely 00000, so all of the examples I give below will assume that a .binsource file is being read.

## Determining Memory Locations of the Special Subroutines

This step is actually *optional*, because all "special" subroutines automatically appear among the more-general lists of symbol matches provided in later steps of the workflow.  However, it may still be useful for you to see them up front.

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

### Format of a Specifications File

If you are uninterested in creating the specifications file manually, jump to the next subsection, which tells you how to simply autogenerate one.

A specification file is simply an ASCII file with a sequence of lines, one for each symbol (program label) of interest, of the form:

    SYMBOL BANK START [END] ["I"]

`SYMBOL` is the literal name of the program label.  Moreover, it's automatically converted to upper case, so if it's more convenient to enter symbols in lower case, feel free to do so.  

`BANK` is a 2-digit octal number in the range 00 through 43.  As a shorthand notation, you can use the literal '.' in place of a number, and the disassembler inserts the bank number from the preceding line (or at any rate, from the most-recent line in which a bank number was numerically defined).

`START` (and `END` if present) are 4-digit octal numbers in the range 2000 through 3777.  `START` gives the address (within the baseline) of the `SYMBOL`.  `END`, meanwhile, is the first address following the subroutine.  The reason `END` is optional is that if it is omitted, the `START` from the next symbol will be used. 

Note that addresses in fixed-fixed continue to use this NN,NNNN convention, rather than being represented by the address ranges 4000 through 7777.

You can also include comments, which are transparently discarded by the processing.  A comment is any text preceded by the character '#'.

**Note:**  It goes without saying, but I'll say it anyway:  You don't need to include any of the "special" subroutines in the specification, since the disassembler already has found them for you.

By default, the *first* instruction in `START` is assumed to be a basic instruction. If the very first instruction in `START` is interpretive, however, the literal field `"I"` is added.  (Sometimes an I is just an I.)   The remainder of the subroutine can be any mixture of basic and interpreter code, as long as there are orderly transitions between them using `TC INTPRET` and `EXIT`.  At some point, it may be necessary to add some additional hinting to the specification so that the non-orderly cases can be handled as well, but there's no such facility as of this moment.

One thing to beware of in omitting the `END` parameter, is that you want the patterns to be long enough so that there are unique matches, and the interval between two successive symbols may not be long enough to achieve that.  For example, among the "special" subroutines, `BANKCALL` and `IBNKCALL` actually have *identical* patterns, and the only way disassemblerAGC.py distinguishes them is that `IBNKCALL` is known to always follow `BANKCALL` in memory.  Unfortunately, that's not something you're able to specify in specification files.  On the other hand, while I said above that `END` is the end of the subroutine, that's not really so.  It's merely the end of the *pattern* being matched.  So you could bunch several subroutines within a single `START` to `END` interval if you liked, thus making the match-pattern much longer and presumably more unique.

Besides these lines describing subroutines (which are stored in fixed memory), there are also optional lines which can be added to describe the symbols in erasable memory.  Doing so is much harder, if performed manually.

Each erasable-specification line has three fields, separated by spaces.  Each line represents exactly one word of erasable memory, but only those locations with symbolic names can be used.

* The first field is the literal character '+'.
* The second field is a python list of strings.  The strings are quoted using single-quotes and separated by commas, with not spaces.  The strings are the symbolic name (in the baseline software) of a location in erasable, along with all of its aliases.
* The third field is a python list of tuples.  Each tuple represents a location in rope memory at which code (either basic or interpretive) accesses the erasable memory location via one of the symbols listed in the preceding bullet.  The three components of the tuple are:
    * The name of a subroutine, as a single-quoted string.  It must be one of the subroutines having a specification in fixed memory.
    * The offset (words or lines of code, in decimal) from the top of the subroutine at which the reference to the erasable occurs.  Thus if the reference were in the first line, 0; in the second line, 1; and so on.
    * The "type" of reference.  This is a single character, single-quoted, interpreted as follows:  'B' if the erasable is referenced as the operand of a single-word basic instruction like CA or XCH; 'C' if a complemented basic instruction like -CCS; 'D' if a double-word basic instruction like DCA or DXCH; 'A' if the erasable is referenced as the argument of an interpretive instruction; 'L' if it's the argument for an index instruction such as LXC,1; 'S' if the erasable is referenced inline with an interpretive `STORE`, `STCALL`, `STODL`, or `STOVL` instruction.

For example, 

    + ['UBAR2','P21ALT'] [('HORIZ',11,'S'),('HORIZ',13,'A'),('HORIZ',15,'A'),('P21DSP',15,'S')]

says that a certain erasable location is identified by the symbols `UBAR2` and `P21ALT`.  It says further that the code references this location from lines

* `HORIZ +11D`
* `HORIZ +13D`
* `HORIZ +15D`
* `P21DSP +15D`

And finally, it says that all of these references are from interpretive code, with the first and last of them being from `STXXX` instructions and the middle two just being regular arguments.

### Autogeneration of a Specifications File for a Baseline Software Version

Creating a specifications file is relatively easy, but the program specifyAGC.py is available to do so in an automated way.  It requires as input only the assembly listing for the baseline AGC software version being used, as produced by `yaYUL`.  Of course, it applies no human judgement to this process, so there are some circumstances where a specification file created manually may be superior in certain ways.  The command is simply

    specifyAGC.py [--min=N] <AGCPROGRAM.py >AGCPROGRAM.specs

The --min option is available to help guard against the danger of making patterns which are so short that they have *many* matches, most of which would be wrong.  For example, if you had a pattern that consisted only of (say) a single TC, it would match any TC in the rope module being reconstructed.  By default, all specifications must be at least 12 (14 octal) words long &mdash; i.e., by default, --min=12.  But you can imagine circumstances where you might want to make it smaller for or longer.

In order to meet the minimum-length requirement, specifyAGC.py will attempt to combine the scopes for successive symbols until the combined scope is greater than the required minimum.  However, there are always going to be very short scopes which simply cannot be combined, in which case specifyAGC.py simply rejects them without creating specifications for.  In either case, though, comments are added to the specifications file at the points where these compromises occur, to explain what has happened.

**Note:** Sometimes the situation arises in which unlabeled code immediately follows data in rope memory thus leaving no way that's obvious (from specifyAGC.py's point of view) to reach that code.  In this case, specifyAGC.py automatically creates a label for it that wasn't present in the original source code.  Such a label has the form "R*BB*,*AAAA*", where *BB*,*AAAA* is the address at which the originally-unlabeled code starts.  For example, the label `R12,3456` might be created at address 12,3456.

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

Besides the lines above, describing the code in fixed memory, if there are any specifications for erasable memory, they are simply passed through to the patterns file and therefore appear here unchanged.

## Matching the Baseline Patterns to the Dumped Rope

The command is

    disassemblerAGC.py [OPTIONS] --find=PATTERNS.patterns <ROPEDUMP.binsource

For example,

    disassemblerAGC.py --find=Comanche055.patterns <Comanche072-B2.binsource

The search is entirely brute force, and does take some time to complete ... though with that said, it's not too bad.  On my computer, for example, doing a full match of Comanche 55 patterns vs a Manche45R2 rope takes 77 seconds.  (In case you're interested, that's a total of 1222 basic program labels and 629 interpretive program labels, of which all but 9 of each are found by the matching process.)

Note that this also creates a file called disassemblerAGC.core which shows all of the core-memory locations at which the disassembler has matched code from the BASELINE.

By default, disassemblerAGC.py searches banks 00, 01, ..., 43 for the patterns whose first instruction is basic, and then searches banks 00, 01, ..., 43 again for the patterns whose first instruction is interpretive.

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

As another example, use these Comanche 55 (Apollo 11) patterns for matching in Manche45R2 (Apollo 10):

    disassemblerAGC.py --find=Comanche055.patterns --bin <Manche45R2.bin

You get (after a little editing):

    BANKCALL = 02,2662
    SWCALL = 02,2666
    POSTJUMP = 02,2701
    BANKJUMP = 02,2704
    POODOO = 02,3721
    DISP45 = 15,2020
    NEWDELHI = 22,3026
    P17 = 35,3155
    TRANSPOS = 22,2334
    S17.1 = 36,2000
    ABORT2 (basic) not found
    COMPTGO (basic) not found

It's not terribly surprising that `COMPTGO` isn't found, since Manche45R2 does not in fact have a `COMPTGO`.  As for `ABORT2`, Manche45R2 does indeed have that, but it differs from the one in Comanche 55. So it's a good thing it isn't found.

# An Alternate Workflow

## More-Flexible Patterns for Code Matching

The workflow described above identifies "exact" code (and optionally, erasable) matches between the chosen baseline software and the dump of a core-rope module.

I say "exact" here, because what is matched is sequences of instruction, and *sometimes* their operands, but usually not.  Thus if you have a subroutine that adds 2 to a number, that is very likely going to match a subroutine that adds 3 to a number, because the exact value being added wouldn't play any role in the matching process.

However, there is an additional way in which one might want flexibility to perform flexible matches, in which some of the instructions themselves are optional.  There is a way to do this.  But the cost of the additional flexibility is that it's harder to set up, and that the ability to match erasable locations is lost.

Earlier, I mentioned the patterns used for exact matching of the `BANKCALL` and `SWCALL` subroutines from the Comanche 55 baseline.  They look like the following:

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

However, these happen to be two of the "special" subroutines which the disassembler automatically locates, and the method it uses to do so is the more-flexible method just mentioned.  As such, the patterns it uses are different as well.  They are represented as key/value entries in a Python dictionary as follows:

    {
    ...
    "BANKCALL": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["DXCH"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [True, ["TS"], ["L"]],
                                    [True, ["LXCH"], ["FB"]],
                                    [True, ["MASK"], []],
                                    [True, ["XCH"], ["Q"]]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "SWCALL": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["TS"], ["L"]],
                        [True, ["LXCH"], ["FB"]],
                        [True, ["MASK"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["DXCH"], []],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["XCH"], []],
                        [True, ["XCH"], ["FB"]],
                        [True, ["XCH"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    ...
    }

At first glance, these seem to contain little if anything more than the non-flexible patterns; but look again.  

In the "pattern" key, notice that each instruction line is accompanied by a boolean, all of which happen to be `True`.  The boolean indicates whether the instruction is *required* or not.  If `False`, they are not required.  If you have non-required lines at the beginning, then after making a match of the required lines, the disassembler will backtrack to include as many of the non-required lines as it can.  Non-required lines in the middle are simply stepped over happily.  You shouldn't have any non-required lines at the end, though, because they won't contribute to the match anyway.

**Note:**  Non-required lines can easily result in matches you didn't intend or failed matches you didn't expect, so you have to *test* carefully in using this feature. 

Then too, look at the second field.  This is obviously an opcode ... but actually a *list* of opcodes rather than a single opcode.  If this list were empty, then *any* opcode would match.  If the list had multiple entries, such as `["TS", "XCH"]`, then either of those opcodes would match, but no other opcodes would.

And similarly, for the third field, the operands.  But beware:  You can only use operand entries recognized by the disassembler, and those are the names of CPU registers or i/o channels, and the names of the "special" subroutines in *fixed-fixed* memory. The symbolic register and i/o channel names recognized by the disassembler appear in the registers.py file.

Then you have the "ranges" key.  This is an array of tuples which describes the allowed memory banks and ranges in which the symbol can appear in the dumped rope.  As may be obvious, the triples are the bank number and the *offset* (from 0 through 0o1777) at which the subroutine can appear.  Do not confuse this with the 4-digit value that would be used in an address of the form NN,NNNN.

By the way, you can use the program labels of special subroutines as the starting addresses of ranges, for that matter, the label of one of your flex subroutines, as long as it is earlier in the list and as long as it's in the correct memory bank.  In this way you can insure that a flex pattern is matched only at a higher memory address than another flex pattern.

Plus, you see the "dataWords" and "noReturn" keys.  These don't affect the matching process but do affect how the disassembler subsquently uses them:  The "dataWords" is a count of the number of words of data arguments which follow a `TC` to the subroutine. The "noReturn" field tells whether or not the subroutine actually returns (to the location following the data words), as a number of "special" subroutines do not return. 

Finally, notice that `BANKCALL` or `SWCALL` don't have a *single* such pattern, but rather accept a *list* of patterns ... even though in this example, each happens to have a list that contains a single pattern.  This allows for alternate patterns so different that they cannot be handled by the little tweaks discussed above.

## Generating and Using Flexible Patterns

Creating the flexible patterns just described is kind of a pain in the neck in real life, and prone to error.  So there's a little bit of automation available to help you generate them in small numbers.

Suppose, for the sake of argument that you knew that in your baseline code, `JAMTERM` resided at addresses 4257 through 4266 in your Comanche 55 baseline, and you wanted to create a flexible pattern for it.  You could get a first cut at it with the following disassembler command:

    disassemblerAGC.py --pattern=JAMTERM --dbank=02 --dstart=2256 --dend=2267 <Comanche055.binsource

(notice that `--dend` is one past the end of the subroutine).  The output is

    "JAMTERM": [{
                    "dataWords": 0,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CA"], []],
                        [True, ["EXTEND"], [""]],
                        [True, ["WRITE"], ["SUPERBNK"]],
                        [True, ["CA"], []],
                        [True, ["TS"], []],
                        [True, ["CS"], []],
                        [True, ["TS"], []],
                        [True, ["TC"], ["POSTJUMP"]],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],

As it stands, this is not flexible, but you have a starting point, and can edit it to get whatever flexibility you like.

Actually *using* your flexible pattern requires that it reside in a file, possibly along with others flexible patterns.  Let's say you have such a file, called "myFlexiblePatterns.flex".  What you do is to add a command-line switch to the disassembler, of the form

    --flex=myFlexiblePatterns.flex

This instructs the disassembler to pull in all of the patterns you've defined, and to add them to the list of "special" subroutines.  For example, I have made a file called temp.flex that contains flexible patterns for `BLANKDSP`, `NVSUB1`, `JAMPROC`, `JAMTERM`, and when I use the command

    disassemblerAGC.py --flex=temp.flex --special <Comanche055.binsource

I get the output

    2PHSCHNG = 5372
    ABORT2 = 5730
    ALARM = 5650
    ALARM2 = 5652
    BAILOUT = 7755
    BANKCALL = 4662
    BLANKDSP = 41,3516
    BORTENT = 5655
    CHECKMM = 5364
    COMFLAG = 5553
    DOWNFLAG = 5560
    ENDOFJOB = 5217
    FINDVAC = 5147
    FIXDELAY = 5267
    IBNKCALL = 4740
    INTPRET = 6006
    JAMPROC = 4245
    JAMTERM = 4245
    NEWPHASE = 4114
    NOVAC = 5134
    NVSUB1 = 41,3544
    PHASCHNG = 5412
    POLY = 7171
    POODOO = 5721
    POSTJUMP = 4701
    PRIOENT = 5656
    PRIOENT +1 = 5657
    SWCALL = 4666
    TASKOVER = 5324
    TWIDDLE = 5235
    UPFLAG = 5546
    USPRCADR = 4757
    WAITLIST = 5245

You'll notice that all four of the subroutines I mentioned now appear among the "special" ones, which normally wouldn't be the case.

By the way, I should mention that *only* special subroutines that are in fixed-fixed memory can be used as labels in flexible operands at the present time.  Thus although `BLANKDSP` and `NVSUB` are shown here as having been found, the disassembler doesn't actually treat them as being special.  On the other hand, `JAMPROC` and `JAMTERM` are in fixed-fixed memory, and the disassembler treats them just like any other special subroutine.

#Example: Comanche 72 Module B2<a name="Comanche072B2"></a>

Here's a worked-out example for the following scenario:  We have the dump of rope module B2 for Comanche 72 (Apollo 13 CM), in the form of a partial `--bin --hardware` file.  There are a total of 6 rope modules, B1 through B6, each of which contains 6 memory banks:

  * B1 = banks 00 through 05
  * B2 = banks 06 through 13 (octal)
  * B3 = banks 14 through 21
  * B4 = banks 22 through 27
  * B5 = banks 30 through 35
  * B6 = banks 36 through 43

But we only have module B2.  

The closest AGC software version to Comanche 72 for which we actually have source code is Comanche 55, though there is also [*very* partially (incomplete) reconstructed code for Comanche 67https://github.com/virtualagc/virtualagc/issues/1140](URL), and we do have [engineering drawing 2021153](https://archive.org/details/apertureCardBox467Part2NARASW_images/page/n91/mode/1up?view=theater), which lists all of the memory bank checksums for Comanche 55, 67, and 72.  If any of those of Comanche 72 matched those of Comanche 55 or 67, perhaps we could import those memory banks to supplement module B2.

Alas, there's no agreement between the checksums of Comanche 55 and Comanche 72.  On the other hand, there is agreement of several memory banks between Comanche 67 and 72, namely:  00, 02, 03, 05, 33, 35.  The question would then be, Are those any of the banks in Comanche 67 which are believed to have already been reconstructed?  The possibly-correctly reconstructed banks of Comanche 67 are:  00, 02, 03, 41.  

To summarize all of that, the Comanche 72 material we have to work with is:

  * (Possibly) Bank 00 of the Comanche 67 reconstruction.
  * (Possibly) Bank 02 of the Comanche 67 reconstruction.
  * (Possibly) Bank 03 of the Comanche 67 reconstruction.
  * Bank 06 of the Comanche 72 module B2 dump.
  * Bank 07 of the Comanche 72 module B2 dump.
  * Bank 10 of the Comanche 72 module B2 dump.
  * Bank 11 of the Comanche 72 module B2 dump.
  * Bank 12 of the Comanche 72 module B2 dump.
  * Bank 13 of the Comanche 72 module B2 dump.

So our first step would seem to be to create a *full* `--bin --hardware` file, in which data from the memory banks just mentioned appear at the proper places, while the remainder of the space is filled with 00000 (plus parity=0), which would indicate unused positions in the rope.  This can be done with the pieceworkAGC.py program, an invocation of which might look like the following:

    pieceworkAGC.py --add=Comanche067.bin,0,0,0,0,2,3 \
                    --add=Comanche072-B2.bin,1,1,2 \
                    >Comanche072-partial.bin

The first `--add` switch says that from Comanche067.bin &mdash; which is specified to have no parity bits, to be in `--bin` format rather than `--hardware` format, and to contain a complete rope &mdash; from which we're supposed to extract banks 00, 02, and 03.

The second `--add` switch says that from Comanche072-B2.bin &mdash; which has parity bits, is in `--hardware` format, and contains just module B2 &mdash; from which we're supposed to extract all of its banks.

Altogether, Comanche072-partial.bin is produced, having just banks 00, 02, 03, 06, 07, 10, 11, 12, and 13 filled in with data, and the remainder filled with 00000 (plus 0 parity), which is what an unused memory location looks like.  This file then formes our ROPE file, against which we wish to match the patterns of the BASELINEs.

Recall that Comanche 72 was for the Apollo 13 Command Module.  I've already said that Comanche 55 (Apollo 11 CM) is *the* baseline to use, but at the same time, it would also make sense to do matches vs the Comanche 67 (Apollo 12 CM) reconstruction, Artemis 72 (Apollo 14 CM), and Luminary 131 (Apollo 13 LM).

Now that we have our ROPE.bin (Comanche072-partial.bin), the next step is to match to our BASELINE.patterns (any or all of Comanche055.patterns, Comanche067.patterns, Artemis072.patterns, or Luminary131.patterns), most of which we showed earlier how to derive using workflow.sh.  For example, [Comanche 55](#Comanche055).  The matching would go something like this, modulo any changes to the command-line switches that we feel have to be made, though I've assumed here that the same switches as were used for Comanche 55 will be fine:

    disassemblerAGC.py --find=Comanche055-autogenerated.patterns <Comanche072-partial.bin >Comanche072vs055-partial.matches \
                       --parity --hardware --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE \
                       --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP --skip=9DWTESTJ [--check=Comanche055.lst]

(Note the optional `--check=Comanche055.lst` switch, which can be added to compare the differences between the matched symbols in the partial Comanche 72 rope to those from the Comanche 55 baseline.)

If run the command described above, this process finds about a third of the program labels and variables it seeks.  The great majority of those actually remain at the same addresses as in Comanche 55.  Nevertheless, to proceed, we'll need to look in detail at those results and *manually* adjust source code.  For that, it's helpful to perform test disassemblies of various sections of code we wonder about.  The useful command for that is

    disassemblerAGC.py --dsymbols=disassemblerAGC.symbols --hardware --dloop=Comanche072-partial.bin

(Recall that the `disassemblerAGC.py --find=...` that we performed earlier automatically produces a symbol table called disassemblerAGC.symbols, and we're taking advantage of that here to make our disassemblies prettier and more informative.)  

What this command does is to prompt you with an input loop, in which you can repeatedly describe sections of code you want to disassemble, and then to see the actual attempt at a disassembly.  For example, here's what happens when I look at 20 (octal) words starting at program label `1REV`:

    At the prompt, enter the parameters for disassembling a range
    of core.  There are two ways of doing this.  First, specify
    octal values, in the form:
           BB SSSS EEEE ['I']
    where BB is the bank, SSSS is the starting address within
    the bank, EEEE is the ending address, and I is an optional
    literal 'I' if the instruction is interpretive.  A second
    method is to enter the name of any known program label, along
    with an octal count of the number of words to disassemble:
           SYMBOL COUNT ['I']
    You can also enter the word QUIT to quit.
    Finally, there's this command:
           '@SPECS' BASELINE.specs
    Note that this command requires the --dsymbols command-line
    option to provide the symbol table for the loaded ROPE.
    The command disassembles (in the loaded ROPE) each (and
    only) those subroutines identified previously by pattern-
    matching with --find, outputting the entire disassembly in
    the file named disassemblerAGC.disassembly.
    > 1rev 20 i
    12,0112    55366    1REV            SQRT            BDDV            
    12,0113    11630                                    2PISC           # 11630 (fixed)
    12,0114    77600                    BOV                             
    12,0115    24116                                    STOREMAX        # 24116 (fixed)
    12,0116    00013    STOREMAX        STORE           00012           
    12,0117    65205                    DMP             PDDL            
    12,0120    00023                                    00023           
    12,0121    00011                                    00011           
    12,0122    65301                    NORM            PDDL            
    12,0123    00047                                    00047           
    12,0124    56257                    SL*             DDV             
    12,0125    20173                                    20173           
    12,0126    50000                    BOV             BMN             
    12,0127    24143                                    MODDONE         # 24143 (fixed)
    12,0130    24143                                    MODDONE         # 24143 (fixed)
    12,0131    51525    PERIODCH        PDDL            ABS             
    Disassembly return values = False, True
    > 
It so happens that `1REV` in Comanche 72 apparently remains at the same address as in Comanche 55.  So perhaps a more informative example would be `PTOALEM`, which moves from 13,3004 in Comanche 55 to 13,3013 in Comanche 72:

    > ptoalem 10 i
    13,3013    47014    PTOALEM         BON             RTB             
    13,3014    04307                                    04307           
    13,3015    27034                                    USEPIOS         # 27034 (fixed)
    13,3016    27023                                    MOVEPLEM        # 27023 (fixed)
    13,3017    52014                    BON             GOTO            
    13,3020    04304                                    04304           
    13,3021    26751                                    SETMOON         # 26751 (fixed)
    13,3022    26744                                    CLRMOON         # 26744 (fixed)
    Disassembly return values = False, False
    > 
As compared to what the Comanche 55 assembly listing produced by yaYUL says:

    057393,000427: 13,3004           47014        PTOALEM            BON      RTB                                   
    057394,000428: 13,3005           04307                                    SURFFLAG                              
    057395,000429: 13,3006           27025                                    USEPIOS                               
    057396,000430: 13,3007           27014                                    MOVEPLEM                              
    057397,000431: 13,3010           52014                           BON      GOTO                                  
    057398,000432: 13,3011           04304                                    LMOONFLG                              
    057399,000433: 13,3012           26742                                    SETMOON                               
    057400,000434: 13,3013           26735                                    CLRMOON                               




