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

# Analysis

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
  * "Core":  These are subroutines sought by the patterns obtained from analyzing the BASELINE.  744 were found and 275 were not.  A pretty big haul, from which we may infer that we can simply paste nearly 75% of the source code directly from Aurora 12 in to Sundial E, with appriate relocation.
  * "Erasable":  These are references to erasable variables, found in the matched "Core" subroutines above.  Only ~200 were found out of ~550 attempted.  Well, better than nothing.
  * "Fixed references":  These are references to fixed-memory constants, found in the matched "Core" subroutines.  Only 345 were found out of ~1600 attempted.
  * "Discrepancies":  6 of these were found.  

Regarding discrepancies, these are cases where (usually) different references in the "Core" subroutines to a given variable (say `ERCOMP`) may have resulted in different numerical addresses.  Usually, these are benign and easily resolvable.  For example, in our preliminary analysis, some references to `ERCOMP` revealed an address 0405 in unswitched erasable while other references revealed E?,1405 in switched erasable &mdash; i.e., the erasable bank number was unknown.  But these are clearly consistent, if the erasable bank is E1.  

Other discrepancies are harder to resolve. In our preliminary analysis, for example, symbol `YNB` is found at both E?,1436 and at E?,1430; meanwhile, `ZNB` is *also* found at both E?,1436 and E?1430!  So there is something more-subtle going on here which will require more cleverness to resolve.  The problem could be a bug in the disassembler.  It could be a case of the parent subroutines being matched wrong because (perhaps) they are identical and were accidentally swapped.  We don't know.  We have to figure it out somehow.

Speaking of which, different subroutines often *are* identical to the point where they can accidentally be swapped by the matching process.  That's the point of the `--hint` command-line switches in the `workflow.sh` and `disassemblerAGC.py` invocations described earlier, and there's no guarantee that we can use the *same* hints in the ROPE-analysis step (`disassemblerAGC.py`) as in the BASELINE-analysis step (`workflow.sh`), so that's something we have to watch out for!

TBD
