# About the Raw Data

The file SundialE.bin contains data dumped from physical fixed-memory modules from the AGC owned by the MIT Museum.  The dump was performed using the restored AGC owned by collector Jimmie Loocke in July 2019.

Source code will become available eventually, via regeneration from related programs and disassembly.

Identification of this AGC is based on circumstantial evidence, because the AGC itself has no part tag.  The observable facts are that the AGC contains:

1. "B" tray of type 2003075-031
2. Alarm module of type 2003890
3. Fixed-memory modules B1 (p/n 2003053-121), B2 (p/n 2003053-151), B3 (p/n 2003972-211)

On the available information -- and admitting that there may be AGC units not covered by the available information -- this would seem to narrow the AGC p/n to 2003100-061, and possibly the following specific AGC:

* From CSM-098, "2VT-1"
* AGC p/n 2003100-061
* Software SUNDIAL E, 2021104-041

The discrepancy is that the fixed-memory modules listed are known to be from SUNDIAL assembly 2021104-051.  However, both the 2021104-041 and -51 modules contain SUNDIAL E software, so if the modules were exchanged at some point it wouldn't have affected functionality in any way.

By the way, the documentation on which the assertions about fixed-memory modules 2021104-041 vs 2021104-051 are based is this:  All of these dash numbers are past the dash-number range for which we have obtained explicit [engineering drawings (namely, 2021104-011 and -021)](https://archive.org/details/apertureCardBox467Part2NARASW_images/page/n16/mode/1up?view=theater), although the drawings we have _do_ identify 2021104-x as a SUNDIAL assembly. However, [document ND-1021043](https://www.ibiblio.org/apollo/Documents/HSI-208435-002.pdf#page=19) has "compatibility" tables showing what module part numbers are in which positions for 2021104-011 through 2021104-061.  From the tables, it is clear that the combination 2003053-121/2003053-151/2003972-211 is indeed one of the three possible combinations acceptable for 2021104-051.  The compatibility table also states that SUNDIAL assemblies 2021104-041, 2021104-051, and 2021104-061 are compatible replacements for each other under all circumstances (and that -031 is compatible as well, for testing purposes, but is "not as good").

But why SUNDIAL E, as opposed to SUNDIAL A through D?  I haven't found any explicit documentation, but the indirect evidence is that in the afore-mentioned compatibility table, it is noted that 2021104-021 "contains gyro compassing error", whereas -031 through -061 presumably do not.  If we look at [document E-1142 Rev 50, "System Status Report"](https://www.ibiblio.org/apollo/Documents/E1142-50.pdf#page=27), it is noted that "Verification of fix to Sundial C and D gyrocompass program incorporation into Sundial E was completed." From this combination of statements, it seems that we would have to infer that SUNDIAL assemblies 2021104-031 through -061 each contained SUNDIAL E, whereas 2021104-021 likely contained SUNDIAL C or D.

# Some Thoughts About Source-Code Reconstruction

Software for SUNDIAL in general, and SUNDIAL E in particular, used the "BLK2" target of the AGC assembler.  BLK2 is a kind of intermediate form of the language(s), poised between the Block I language and the final Block II language that was used on all manned missions.  It is thus similar to the final Block II language, but not precisely identical.

The only other representative examples of BLK2 language we have as of this writing are the Retread and Aurora software.  Of these, Aurora is the closest for modeling Sundial.  For one thing, Sundial served a similar purpose as checkout software for the Command Module that Aurora did for the Lunar Module; Retread, meanwhile, was earlier software which lacked much of the essential functionality for this purpose.  Besides which, consider document E-1142 (Rev. 48) of April 1966, which says:

    The programming of SUNDIAL has begun by carrying over many
    of the applicable sections from AURORA. Some of these sections have
    been exercised on the digital simulator at M.I.T. and on a GN&C system
    at A.C. Electronics, Inc. in Milwaukee. Program status may be 
    summarized as follows:
    
        Fresh Start and Restart           (4,2,1)
        Interpreter                       (3)
        Executive                         (4)
        Waitlist                          (4)
        Restart Control                   (2)
        T4RUPT Program                    (4,2,1)
        IMU Mode Switching                (4)
        Optics Routines                   (1)
        Extended Verbs                    (4,1)
        Keyboard & Display                (4)
        Alarm & Abort                     (4)
        Downlink                          (2)
        Self-check                        (4)
        Prelaunch Alignment               (2,1)
        CSM & Saturn Integrated Tests     (3)
        G&N System Tests                  (3,2,1)
        CSM Digital Autopilot             (2,1)
    
    Numeric designations have the following meanings:

    1) Planned
    2) Programmed
    3) "Bench" Tested on Digital Simulator
    4) Test run on GN&C System.
    
    Multiple numbers mean that different sections of the program are at
    different stages.

Note also that the only version we presently have of Aurora is a fork called DAP Aurora 12, with a hardcopy printed NOV 10, 1966, just a few months after the report just mentioned.

Idealized, the process of reconstructing source code from a dump of physical rope-memory modules goes something like the following:

 1. Obtain an octal dump of the physical rope-memory modules.  I'll refer to this as the ROPE.  In this case, that's the file SundialE.bin.
 2. Choose software version(s) similar to the ROPE, but for which we have actual source code.  I'll refer to these as the BASELINEs.  In this case, we have a single BASELINE, namely the files in the Aurora12/ folder of the source tree.
 3. Analyze the BASELINE, using the programs found in the Tools/disassemblerAGC/ folder of the source tree.  This analysis results, among other things, in a BASELINE.patterns file, which provides a lot of information about the subroutines and other symbolic data in the BASELINE, but with absolute addressing stripped away, and presented in a form in which a pattern-search based on it can be applied to the ROPE.
 4. Analysis of the ROPE with the BASELINE patterns typically finds a large number of subroutines which have remained essentially the same between the BASELINE and ROPE, but which may have moved to different addresses.  Since those subroutines have remained essentially the same, the analysis can also deduce the addresses in the ROPE of many erasable variables and fixed-memory constants which have also moved somewhat in the ROPE from their locations in the BASELINE.
 5. For items which have simply moved, their source code can essentially be pasted into the ROPE directly from the BASELINE.
 6. For those subroutines which have *not* been matched, they will often reside in expected locations in the gaps between the subroutines that *were* matched, but weren't found because instructions were added, changed, or deleted.
 7. ... ? ...
 8. Profit!

Not having performed such a reconstruction myself, the intermediate steps are something of a mystery to me ... and I'm sure they probably differ from one reconstruction to the next.  Which is why I've simply left them open in the final two steps above.  Hopefully, more detail can be filled in later.

# Preliminary Automated Analysis

As described by [the disassembler's README](https://github.com/virtualagc/virtualagc/tree/master/Tools/disassemblerAGC#readme), the DAP Aurora 12 BASELINE is analyzed by the following command, assuming Linux, and assuming that the Tools/disassemblerAGC/ folder is in the PATH:

    cd Aurora12
    workflow.sh Aurora12 --blk2 --hint=UNAJUMP@MISCJUMP --hint=MISCJUMP@INDJUMP \
                         --hint=PDVL@PDDL --hint=JACCESTR@JACCESTQ

Resulting from this operation are several files in the Aurora12/ folder that will be useful to a greater or lesser degree:

  * Aurora12-autogenerated.specs
  * Aurora12-autogenerated.patterns &mdash; the most-important file for analyzing the ROPE (=SundialE.bin).
  * Aurora12-autogenerated.matches
  * disassemblerAGC.symbols

The subsequent ROPE-analysis step is this:

    disassemblerAGC.py  --blk2 --hint=UNAJUMP@MISCJUMP --hint=MISCJUMP@INDJUMP \
                        --hint=PDVL@PDDL --hint=JACCESTR@JACCESTQ --bin \
                        --find=../Aurora12/Aurora12-autogenerated.patterns \
                        <SundialE.bin \
                        >SundialE-Aurora12.matches

The results (SundialE-Aurora12.matches) are encouraging.  Here's an initial summary:

  * "Special symbols":  This are symbols with patterns hardcoded into the disassembler, rather than being obtained by analysis of the BASELINE.  17 were found and 12 weren't, but the only really significant fact here is that the all-important subroutine `INTPRET` was in fact found.
  * "Core":  These are subroutines sought by the patterns obtained from analyzing the BASELINE.  744 were found and 275 were not.  A pretty big haul, from which we may infer that we can simply paste nearly 75% of the source code directly from Aurora 12 into Sundial E source-code files, with appriate relocation.
  * "Erasable":  These are references to erasable variables, found in the matched "Core" subroutines above.  Only ~200 were found out of ~550 attempted.  Well, better than nothing.
  * "Fixed references":  These are references to fixed-memory constants, found in the matched "Core" subroutines.  Only 345 were found out of ~1600 attempted.
  * "Discrepancies":  6 of these were found.  

Regarding discrepancies, these are cases where (usually) different references in the "Core" subroutines to a given variable (say `ERCOMP`) may have resulted in different numerical addresses.  Usually, these are benign and easily resolvable.  For example, in our preliminary analysis, some references to `ERCOMP` revealed an address 0405 in unswitched erasable while other references revealed E?,1405 in switched erasable &mdash; i.e., the erasable bank number was unknown.  But these are clearly consistent, if the erasable bank is E1.  

Other discrepancies are harder to resolve. In our preliminary analysis, for example, symbol `YNB` is found at both E?,1436 and at E?,1430; meanwhile, `ZNB` is *also* found at both E?,1436 and E?1430!  So there is something more-subtle going on here which will require more cleverness to resolve.  The problem could be a bug in the disassembler.  It could be a case of the parent subroutines being matched wrong because (perhaps) they are identical and were accidentally swapped.  We don't know.  We have to figure it out somehow.

Speaking of which, different subroutines often *are* identical to the point where they can accidentally be swapped by the matching process.  That's the point of the `--hint` command-line switches in the `workflow.sh` and `disassemblerAGC.py` invocations described earlier, and there's no guarantee that we can use the *same* hints in the ROPE-analysis step (`disassemblerAGC.py`) as in the BASELINE-analysis step (`workflow.sh`), so that's something we have to watch out for!

# Manual Refinement of the Analysis

## Method #1

Now, what I (RSB) had forgotten when writing the last couple of sections above &mdash; Mike Stewart had written the 1st section &mdash; was that Mike was very close to finishing up the source-code reconstruction.  [His partial solution is here](https://github.com/thewonderidiot/sundiale/blob/master/sundiale.disagc).  Thus the appropriate goal for the analysis I'm doing now *should* be to see if it's possible to close any of the gaps which Mike hadn't yet closed.

Specifically, where unable to identify how some sections of code related to known code from other AGC versions, he had used invented labels of the form U*BB*,*XXXX*, *BB* is a bank number and *XXXX* is an address within the bank. Therefore, the first priority would be to see if any of these invented labels can be identified more meaningfully.

There are several ways this can be approached.  One way is to use this command to invoke interactive-disassembly mode,

    disassemblerAGC.py --dsymbols=disassemblerAGC.symbols --blk2 --bin --dloop=SundialE.bin

and then once in interactive-disassembly mode, to use the command,

    @SPECS ../Aurora12/Aurora12-autogenerated.specs

The result of this is a new file, disassemblerAGC.disassembly, which contains a disassembly of Sundial E, but only of those portions (and using those symbols) which the disassembler has been able to deduce.  It is thus similar to Mike's disassembly, but *hopefully* complementary to it rather than entirely redundant.

I'll summarize what few results I find in a later section.

One suggestion Mike had was to use Comanche 237 as a baseline rather than DAP Aurora 12.  So let's try that.  In fact, I never really thought of using a non-BLK2 baseline to analyze a BLK2 rope, so it should be a novelty!

    cd Colossus237
    workflow.sh Colossus237 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE \
                            --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP --skip=9DWTESTJ \
                            --hint='NEWJ(S)@PCOPYCYC' --hint='NEWY(S)@NEWJ(S)'
    cd SundialE
    disassemblerAGC.py  --blk2 --hint=MISCJUMP@UNAJUMP --hint=MISCJUMP@INDJUMP --hint=-TORQUE@+TORQUE \
                            --hint=TABYCOM@TABPCOM --hint=ASMBLWY@ASMBLWP --skip=9DWTESTJ \
                            --hint='NEWJ(S)@PCOPYCYC' --hint='NEWY(S)@NEWJ(S)' --bin \
                        --find=../Colossus237/Colossus237-autogenerated.patterns \
                        <SundialE.bin \
                        >SundialE-Colossus237.matches

Surprisingly, this does work.  Not surprisingly, there are considerably fewer matches made vs Colossus 237 than vs DAP Aurora 12.  And, none of the U*BB*,*XXXX* symbols are identified.

# Method #2

Consider this example from Mike's manual disassembly:

    04,3714: 00004 0 U04,3714 INHINT                     ; This RTB op code appears to be unique to Sundial
    04,3715: 37657 1          CAF    ZERO
    04,3716: 56037 0          XCH    PIPAX
    04,3717: 54140 0          TS     MPAC
    04,3720: 37657 1          CAF    ZERO
    04,3721: 56040 0          XCH    PIPAY
    04,3722: 54143 0          TS     MPAC +3
    04,3723: 37657 1          CAF    ZERO
    04,3724: 56041 1          XCH    PIPAZ
    04,3725: 00003 1          RELINT
    04,3726: 54145 0          TS     MPAC +5
    
    04,3727: 37657 1          CAF    ZERO
    04,3730: 54141 1          TS     MPAC +1
    04,3731: 54144 1          TS     MPAC +4
    04,3732: 54146 0          TS     MPAC +6
    
    04,3733: 13576 1          TCF    VECMODE

Now, from the embedded comment, Mike seems already to have done the research to conclude that this RTB opcode won't be found elsewhere, but just as an example, let's suppose that that isn't true and that this code might exist in some baseline (including those we haven't tried).  In a limited sense, what we're going to do is try using Sundial E as a baseline (just for this one subroutine!) and other AGC code versions as the "rope".

The first step is to generate a "pattern" that conforms to the code. Above, we do that in Sundial E as follows:

    cd SundialE
    disassemblerAGC.py --pattern=U04,3714 --dbank=04 --dstart=3714 --dend=3734 --blk2 --bin \
        <SundialE.bin \
        >DUMMY.flex

Though we actualy don't need to see it, since it's safely stored in the file DUMMY.flex, here's the pattern produced by command:

    "U04,3714": [{
                    "dataWords": 0,
                    "noReturn": False,
                    "pattern": [
                        [True, ["INHINT"], [""]],
                        [True, ["CA"], []],
                        [True, ["XCH"], ["PIPAX"]],
                        [True, ["TS"], []],
                        [True, ["CA"], []],
                        [True, ["XCH"], ["PIPAY"]],
                        [True, ["TS"], []],
                        [True, ["CA"], []],
                        [True, ["XCH"], ["PIPAZ"]],
                        [True, ["RELINT"], [""]],
                        [True, ["TS"], []],
                        [True, ["CA"], []],
                        [True, ["TS"], []],
                        [True, ["TS"], []],
                        [True, ["TS"], []],
                        [True, ["TCF"], []],
                     ],
                    "ranges": []
                }],

Now let's try to actually find this file in the rope for some AGC software version.  To get our feet wet, start with somewhere we should be certain of finding it, namely in SundialE itself:

    disassemblerAGC.py --blk2 --flex=DUMMY.flex --special --bin <SundialE.bin

No surprise, `U04,3714` is found at address 04,3714.  But we can now apply this same test to other AGC versions, simply by replacing the bin file, and removing the `--blk2` switch as appropriate to the software version being tested:

    disassemblerAGC.py --flex=DUMMY.flex --special --bin <../Comanche055/MAIN.agc.bin

Again, no surprise, since `U04,3714` is *not* found.  But then, we never expected it to be found anyway.

Let's try it with other invented program labels for which the conclusion isn't so foregone.  **Note:** For efficiency, our DUMMY.flex file can store multiple patterns, so let's have it do so:

    disassemblerAGC.py --pattern=U06,3071 --dbank=06 --dstart=3071 --dend=3112 --blk2 --bin <SundialE.bin >>DUMMY.flex
    disassemblerAGC.py --pattern=U06,3455 --dbank=06 --dstart=3455 --dend=3462 --blk2 --bin <SundialE.bin >>DUMMY.flex
    disassemblerAGC.py --pattern=U15,2000 --dbank=15 --dstart=2000 --dend=2016 --blk2 --bin <SundialE.bin >>DUMMY.flex
    disassemblerAGC.py --pattern=U15,2016 --dbank=15 --dstart=2016 --dend=2031 --blk2 --bin <SundialE.bin >>DUMMY.flex
    disassemblerAGC.py --pattern=U15,2031 --dbank=15 --dstart=2031 --dend=2042 --blk2 --bin <SundialE.bin >>DUMMY.flex

    disassemblerAGC.py --blk2 --flex=DUMMY.flex --special --bin <SundialE.bin
    disassemblerAGC.py --blk2 --flex=DUMMY.flex --special <../Aurora12/Aurora12.binsource
    disassemblerAGC.py --flex=DUMMY.flex --special --bin <../Colossus237/Colossus237.bin
    disassemblerAGC.py --flex=DUMMY.flex --special --bin <../Sunburst37/Sunburst37.bin

Alas, other than in Sundial E, none of these patterns are found in the other AGC versions tried.

Okay, this business of writing separate `disassemblerAGC.py --pattern=...` commands like I've done above is for the birds, because there are several dozen invented labels.  I've written a one-off program, Tools/disassemblerAGC/unMike.py to convert Mike's entire manual disassembly, which I call sundiale.disagc.txt on my local computer, to a file which can be used with `disassemblerAGC.py --flex=...`.  Here's the usage:

    unMike.py --blk2 <sundiale.disagc.txt >sundiale.disagc.flex

Then,

    disassemblerAGC.py --blk2 --flex=sundiale.disagc.flex --special --bin <SundialE.bin
    disassemblerAGC.py --blk2 --flex=sundiale.disagc.flex --special <../Aurora12/Aurora12.binsource
    disassemblerAGC.py --flex=sundiale.disagc.flex --special --bin <../Colossus237/Colossus237.bin
    disassemblerAGC.py --flex=sundiale.disagc.flex --special --bin <../Sunburst37/Sunburst37.bin

# Method #3

Partially through the process of working through Method #2 above, I realized that it was misguided, and that I was essentially reinventing the wheel.  What I should have done is this:

 1. Reformat Mike's manual disassembly so that it resembled yaYUL's assembly listings closely enough to be processed by specifyAGC.py.
 2. Treat Mike's manual disassembly (plus the dump) as the BASELINE.
 3. Treat Solarium55, Sunburst37, Comanche237 as ROPEs.
 4. Process normally, using workflow.sh.

To that end, I've created a script Tools/disassemblerAGC/Mike2Lst.py &mdash; *much* simpler than unMike.py &mdash;, which is used as follows:

    Mike2Lst.py <sundiale.disagc.txt >SundialE.lst

And then &mdash; again, *much* simpler &mdash;, this:

    workflow.sh SundialE --bin --blk2

Now, there are drawbacks to this method, in that Mike's disassembly doesn't allocate any erasables, nor does it have a symbol table.  Since specifyAGC.py relies on the erasable allocations to be able to find references to erasables, that means that the normal workflow can't match any variables in erasable memory.  And since disassemblerAGC.py/workflow.sh relies on the symbol table for cross-checking identified symbols (hence allowing you to tune up your hints like `--hint` and `--skip`), it can't do the desired cross-checking either.  On the other hand, Method #2 above couldn't do those things either, so it's not a great loss.

    disassemblerAGC.py --blk2 --find=SundialE-autogenerated.patterns <../Aurora12/Aurora12.binsource
    disassemblerAGC.py        --find=SundialE-autogenerated.patterns <../Colossus237/Colossus237.binsource
    disassemblerAGC.py        --find=SundialE-autogenerated.patterns <../Sunburst37/Sunburst37.binsource

# Some Observations from the Stuff Above

As of 2022-10-30:  

  * At lines 17394 and 17395, I suspect that instead of `STODL UE5,1404` / `STORE UE5,1712` it should instead be:

            STODL   UE5,1404
                    UE5,1712

  * At line 17432, I think, `BZMF` should be `BZF`.
  * At line 17710, `TC` should be `TCF`.
  * At line 18584, there's a typo.  This line should have been `U17,3410` (rather than `U17,3430`).
  * `U15,2016` seems to be `1TO2SUB` from DAP Aurora 12, Sunburst37, and Colossus 237 with a slightly-modified calling sequence.
  * `U15,2643` seems to be `STOREDTA` from Colossus 237.
  * At line 16007, `U15,2564` should be `U15,2654`. Also, it matches `LOADSTDT` in Colossus 237, but that would be obvious from `U15,2643`/`STOREDTA`.

There are other matches, but no labels for the code in Aurora 12, Colossus 237, or Sunburst 37, so it doesn't really help.

