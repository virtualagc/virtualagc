The files PFS/mafgen/DASS_\*.ASC provide detailed information about the fully-compiled and linked OI340600 as it existed in actual computer (GPC = AP-101S) memory.  There were 8 different memory configurations for which we have DASS files, known as G16, G2, G3, G8, G9, S2, P9, and SSW.  (The filenames are `DASS_G16.ASC` and so on, except for `DASS_SSW_(PostIPL).ASC`, which carries a suffix.)  The DASS files are dumps of actual GPC memory, annotated with data taken from SDFs, and disassembled to show actual AP-101S assembly language.  In particular, the entire binary contents of memory have been scraped from the DASS files by `PFS/unMAFGEN2.py` and are provided in the files G16.fcm, G2.fcm, and so on.  Indices of the CSECTs have also been scraped, and are provided as the files csects-G16.json, csects-G2.json, and so on.

The Python script `compileLinkCompare` performs the following operations:

1. Compiles a specified HAL/S file (or list of HAL/S files) that we believe exist in a specified GPC memory configuration.
2. Links those object files at the exact CSECT locations specified by the CSECT index for the specified configuration, creating an .fcm file.
3. Compares the binary for the list of HAL/S files in the created .fcm with the binary in those same locations for the memory configuration's full .fcm.

The result is a list of *discrepancies* between our build of PASS (at least for the specific HAL/S files specified) versus the actual memory dump of the specified configuration.

Our goal is to find all such discrepancies and either to remove them, or failing that, get a very clear idea how those discrepancies have come about and why they are unfixable.

Work in a copy of the source tree under `~/ForClaude`, not in `PFS/OI340600` itself.  `compileLinkCompare` leaves residue like archive.results/ behind, and that accumulation is what made an IDE project of PFS unusable: roughly 2.3 million files across two corpora.  The corpus runs were moved out for the same reason.

## Scope, and how much of it there is

Not every CSECT is ours to fix.  They fall into three groups, and only the first is in scope:

- **HAL/S-derived**, compiled from PASS source.  This is the work.
- **Assembly-derived**.  We are not yet in a position to assemble those files.
- **HAL/S runtime library**, linked in rather than compiled: `#0ETOH`, `#0ITOD`, `#0ROUND`, `#LACOS`, `#LDATAN2` and the like, 443 distinct.  The GSRRSL example below includes one of these, `#0ITOD`, and it matches.  Nothing we do to our compilation changes a library routine.

Counting them per configuration, as total / HAL/S / assembly / runtime:

| config | total | HAL/S | assembly | runtime |
|---|---|---|---|---|
| SSW | 660 | **387** | 154 | 119 |
| P9 | 686 | **418** | 143 | 125 |
| G8 | 1227 | **849** | 140 | 238 |
| S2 | 1227 | **865** | 144 | 218 |
| G9 | 1272 | **896** | 158 | 218 |
| G2 | 1417 | **1010** | 140 | 267 |
| G3 | 1629 | **1228** | 140 | 261 |
| G16 | 1819 | **1406** | 141 | 272 |

So the whole job is 3212 distinct CSECTs rather than the 3859 in the indices, and starting with the smallest configuration means 387 rather than 660.

To match a CSECT to its source file, strip the two-character prefix — `#C`, `#D`, `#Z`, `#0`, `A1` through `A9` — and compare the remainder against the *descored, six-character* source name.  Matching against the whole filename fails wherever a stem is longer than six characters: `#CARDCSB` comes from `ARDCSBUS.hal`.

The work divides naturally into one subtask per memory configuration, done serially, starting with the smallest (SSW) and working towards the largest (G16).  That order is well founded and there is a number for it: the per-configuration HAL/S counts sum to 7059 CSECT instances, but only 3212 are distinct, so each appears in an average of 2.2 configurations.  A mechanism knocked down in SSW is therefore already fixed wherever else it occurs, and the later configurations should go much faster than their size suggests.

If the scope proves too large to finish, it simply remains unfinished; that is preferable to narrowing the goal.

## Order of work

**Mass-testing every HAL/S file first would be premature.**  Only a few failure mechanisms are expected, so the way through is to take each one intensively as it is encountered and knock it down before proceeding to the next.

It is worth being explicit about this, because the obvious analogy misleads.  `compilePASS` is a mass driver that made the corpus phase tractable — but it existed only because the mechanism-by-mechanism triage had already been done, long before, and it was the tool that survived that process rather than the thing that started it.  A driver here is worth building *after* the first mechanism falls, as the way to measure how far that fix reached.  Not before, to hunt for work.

## The mechanisms

Discrepancies could be due to many things:

- Bugs in `HALSFC`.
- Bugs in the linker (`lnk101`), which are to be handed off to its developer.
- Different compiler options.
- Some other unknown unknown.

The mechanisms actually seen so far are: linker errors, differing register selection, and a constant used where the other build used an immediate operand.  A common example of the second is that some kind of operation is performed in which a value is shoved into some CPU register, the specific register used being functionally insignificant, but PASS2 of the compiler has chosen a different register than was used in the DASS file.  An example of the third is that a literal is shoved into memory in one, but an immediate operand is instead used in the other, which is not only a difference, but also results in all of the succeeding instructions being displaced slightly.  But why?  And how to fix it?

That displacement has a consequence worth stating in advance: **count root causes, not differing halfwords.**  One constant-versus-immediate difference can make hundreds of halfwords differ, and a raw difference count will be wildly misleading about how much work remains.  The corpus phase ended with twelve failures that proved to be six root causes and four pure cascades; expect the same shape here, more strongly.

The categories above are a starting list, to be grown by observation.  It is premature to decide what the full taxonomy should be before looking.

Two notes on suspects:

- **Compiler options** have already been swept once, and no setting was found that improved on the defaults now built in.  Treat that as a lead worth redoing rather than a closed question.  It is cheaper to repeat than it was: `halsParms.py` now holds the defaults for `compilePASS`, `compileLinkRun` and `compileLinkCompare` together, so an option change applies identically to all three.
- **Errors in the DASS scraping** are a weaker suspect than the analogous risk was for the OI301700 source.  `unMAFGEN2.py` parses a genuinely regular syntax, where the OI301700 extraction was string matching against printed listings.  Keep it in mind only for a discrepancy that makes no sense from either side.

OI301700 is out of scope, for want of DASS dumps and with no prospect of any.  If some ever became available the scope could be expanded to it.

## A worked example

Accepting the default memory configuration G16 and testing GSRRSL.hal:

<pre>
cd PFS/OI340600
compileLinkCompare --filename=APPLSRC/GSRRSL.hal
</pre>

Result:

<pre>
  OK:   #ZGSRRSL @ 003B8 (2 halfwords)
  OK:   #0ITOD   @ 00588 (24 halfwords)
  OK:   #CGSRRSL @ 15BEC (1569 halfwords)
  OK:   A1GSRRSL @ 1620E (18 halfwords)
  OK:   A2GSRRSL @ 16220 (72 halfwords)
  OK:   A3GSRRSL @ 16268 (47 halfwords)
  OK:   A4GSRRSL @ 16298 (282 halfwords)
  OK:   A5GSRRSL @ 163B2 (368 halfwords)
  OK:   A6GSRRSL @ 16522 (52 halfwords)
  OK:   A7GSRRSL @ 16556 (176 halfwords)
  FAIL: #DGSRRSL @ 3973C (224 halfwords) - 29 halfwords differ
                 @ 39770 C150 vs C196
                 @ 39771 0000 vs 6666
                 @ 39774 C1C0 vs C1F0
                 @ 39776 C21E vs C217
                 @ 39778 C310 vs C2F0
                 @ 39779 E000 vs 0000
                 @ 3977A C198 vs C1C8
                 @ 3977C C180 vs C1B0
                 @ 3977E C223 vs C21B
                 @ 3977F 0000 vs EB85
                   ... and 19 more

FAIL: 1/11 section(s) differ
</pre>

Conclusion: the *code* (`#CGSRRSL`) all matches, but the *data* (`#DGSRRSL`) does not.  The next step in diagnosis would be to compare the assembly language in current.results/pass2.rpt against the assembly language in CSECT `#DGSRRSL` in file PFS/mafgen/DASS_G16.ASC.

Whether that code/data split holds generally is itself a cheap early measurement, and a valuable one: if code sections usually match and data sections usually do not, the whole phase points at data generation rather than code generation.
