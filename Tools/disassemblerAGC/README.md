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

# Program: specifyAGC.py

The program specifyAGC.py is used for auto-generating a "specifications" file (explained in the section "Envisaged Workflow" below) from an AGC assembly listing.  That's a task which would otherwise need to be performed manually, and while it's relatively easy to do so, it can be time-consuming.  Therefore, automating it can be useful.

An assembly listing is normally output automatically by the process of assembling AGC source code using the `yaYUL` assembler, as in 

    yaYUL ... >AGCPROGRAM.lst

The specifyAGC.py program is used as follows:

    specifyAGC.py [--min=8] &lt;AGCPROGRAM.lst >AGCPROGRAM.specs

The --min option is explained later.

The only dependency is the disassembleInterpretive.py module, also required by disassemblerAGC.py as explained earlier.

# Envisaged Workflow

## Introduction

The program disassemblerAGC.py is not intended to be a complete disassembly system for the AGC, but rather a tool in a workflow intended to solve a specific problem, which is as follows.  Suppose that an octal dump of a core-rope module of some AGC software version is available.  We would like to provide AGC source code which assembles to those given octal values.  Moreover, we would like it to be fully AGC source code, with symbolic program labels and variable names, as well as program comments.

The underlying assumption is that the core-rope module is of a software version which is similar but not identical to other software versions existing in our collection.  Large chunks of the code will therefore be identical to existing code, and simply be pasted in, with appropriate adjustment of memory locations.  The problem is making the identification between matching chunks of code in the two software versions, so we know how those addresses must be changed.

The workflow which disassemblerAGC.py aids is essentially the following.  (Sample invocations of disassemblerAGC.py to achieve these steps are given after the summary.)

 1. Determine the memory locations of various subroutines common to all (or at least a wide range) of AGC software versions.  I refer to these as the "special subroutines".  There is a built-in mechanism for 25-30 such common subroutines built into disassemblerAGC.py, which has been tested across a variety of software versions.  (Retread 44, Aurora 12, Sunburst 37, Comanche 55, Luminary 210, Artemis 72).  Presumably, the number of supported special subroutines will increase over time.
 2. Choose an AGC software version (or versions) to be used as baseline(s) for reconstructing the software of the dumped rope module.  For example, in reconstructing a Comanche 72 dump, the baseline versions might be the (fully known) Comanche 55 software and the (incomplete but partially reconstructed) Comanche 67 software.
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
    * The "type" of reference.  This is a single character, single-quoted, interpreted as follows:  'B' if the erasable is referenced as the operand of a basic instruction; 'A' if the erasable is referenced as the argument of an interpretive instruction; 'S' if the erasable is referenced inline with an interpretive `STORE`, `STCALL`, `STODL`, or `STOVL` instruction.

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

    specifyAGC.py [--min=N] &lt;AGCPROGRAM.py >AGCPROGRAM.specs

The --min option is available to help guard against the danger of making patterns which are so short that they have *many* matches, most of which would be wrong.  For example, if you had a pattern that consisted only of (say) a single TC, it would match any TC in the rope module being reconstructed.  By default, all specifications must be at least 8 words long &mdash; i.e., by default, --min=8.  But you can imagine circumstances where you might want to make it smaller for a few special symbols, or longer.

In order to meet the minimum-length requirement, specifyAGC.py will attempt to combine the scopes for successive symbols until the combined scope is greater than the required minimum.  However, there are always going to be very short scopes which simply cannot be combined, in which case specifyAGC.py simply rejects them without creating specifications for.  In either case, though, comments are added to the specifications file at the points where these compromises occur, to explain what has happened.

The following sample specifications files are in the source tree:

* Comanche055.specs &mdash; Just a few things I was playing around with in debugging the disassembler.
* Comanche067_aborted_reconstruction_20221005.specs &mdash; My attempt at manually creating a specifications file from a reconstruction of Comanche 67 I had been making (see GitHub issue #1140) but eventually had to abandon only partially completed.  The specification file covers only banks 06 through 13, which correspond to rope memory module B2.  I didn't include *all* program labels in those banks, of course, but just chose a few dozen per bank, roughly evenly spaced.
* Comanche055-autogenerated.specs &mdash; A full specifications file for Comanche 55, autogenerated by specifyAGC.py with its default setting for minimum length.

## Creating a Pattern-Matching File from a Specifications File

The command is 

    disassemblerAGC.py --specs=SPECIFICATION.spec &lt;BASELINE.binsource >PATTERNS.patterns

For example,

    disassemblerAGC.py --specs=Comanche055.spec &lt;Comanche055.binsource >Comanche055.patterns

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

    disassemblerAGC.py --find=PATTERNS.patterns <ROPEDUMP.binsource

For example,

    disassemblerAGC.py --find=Comanche055.patterns <Comanche072-B2.binsource

The search is entirely brute force, and does take some time to complete ... though with that said, it's not too bad.  On my computer, for example, doing a full match of Comanche 55 patterns vs a Manche45R2 rope takes 77 seconds.  (In case you're interested, that's a total of 1222 basic program labels and 629 interpretive program labels, of which all but 9 of each are found by the matching process.)

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

Regarding erasable matches, they appear in this output as well, at the end of it, and appear similarly to those lines above.  However, that is work in progress and there are some subtleties about it that I'm not yet prepared to discuss.

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


