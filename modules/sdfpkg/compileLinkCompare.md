The files PFS/mafgen/DASS\*.ASC provide detailed information about the fully-compiled and linked OI340600 as it existed in actual computer (GPC = AP-101S) memory.  There were 8 different memory configurations for which we have DASS\*.ASC files. Those configurations were known as G16, G2, G3, G8, G9, S2, P9, and SSW.  The DASS files are dumps of actual GPC memory, annotated with data taken from SDFs, and disassembled to show actual AP-101S assembly language.  In particular, the entire binary contents of memory have been scraped from the DASS files and are provided in the files G16.fcm, G2.fcm, and so on.  Indices of the CSECTs have also been scraped from the DASS files, and are provided as the files csects-G16.json, csects-G2.json, and so on.

The Python script `compileLinkCompare` performs the following operations:

1. Compiles a specified HAL/S file (or list of HAL/S files) that we believe exist in a specified GPC memory configuration.
2. Links those object files at the exact CSECT locations specified by the CSECT index for the specified configuration, creating an .fcm file.
3. Compares the binary for the list of HAL/S files in the created .fcm with the binary in those same locations for the memory configuration's full .fcm.

The result is a list of <i>discrepancies</i> between our build of PASS (at least for the specific HAL/S files specified) versus the actual memory dump of the specified configuration.  Those discrepancies could be due to many things:

- Bugs in `HALSFC`.
- Bugs in the linker (`lnk101`).
- Different compiler options.
- Some other unknown unknown.

Our goal is to find all such discrepancies and either to remove them, or failing that, get a very clear idea how those discrepancies have come about and why they are unfixable.

A common example is that some kind of operation is performed in which a value is shoved into some CPU register, the specific register used being functionally insignificant, but PASS2 of the compiler has chosen a different register than was used in the DASS file.  Another example is that a literal is shoved into memory in one, but an immediate operand is instead used in the other, which is not only a difference, but also results in all of the succeeding instructions being displaced slightly.  But why?  And how to fix it?

For example, accepting the default memory configuration G16 and testing GSRRSL.hal:
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
  FAIL: #DGSRRSL @ 3973C (224 halfwords) — 29 halfwords differ
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
Conclusion: the <i>code</i> (`#CGSRRSL`) all matches, but the <i>data<i> (`#DGSRRSL` does not).  Next step in diagnosis would be to compare assembly language in current.results/pass2.rpt versus assembly languate in CSECT `#DGSRRSL` in file PFS/mafgen/DASS-G16.ASC.

