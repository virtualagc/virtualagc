The core rope for the SUNDANCE AGC program should be 6 rope modules (B1-B6) in total.  At present, we do indeed have the contents of 6 such modules, but unfortunately not all from the _same_ revision of the SUNDANCE program. 

Lately (as of September 2019), we've experienced quite a bit of succces in reliably reconstructing lost revisions of AGC software using similar software revisions and separate documents (memos, flowcharts, etc.).  Therefore, it's entirely possible that some enterprising individual will figure out how to use these modules to recover the complete program for one or more specific revisions of SUNDANCE.  And it's alway possible we may obtain yet more dumps from SUNDANCE rope modules in the future to aid in that task.  In the meantime, though, the contents of these disparate rope modules are just being stored here for archival purposes.  They are stored in the binary core-rope format output by the yaYUL assembler and input by the yaAGC CPU simulator, except that each file is truncated to contain only the contents of a single module.  In other words, if the modules were all from the same SUNDANCE revision, the complete core-rope file for it would be obtained by concatenating the files for B1 through B6 end-to-end.

The data was obtained from dumps of physical fixed-memory modules owned by various individuals, using the restored AGC owned by collector Jimmie Loocke.  Here's the complete list of modules we have dumps for, and the personal collections from which they came:

* B1 (p/n 2003972-371, SUNDANCE 292), Anonymous
* B2 (p/n 2003972-451, SUNDANCE 302), Don Eyles
* B3 (p/n 2003972-391, SUNDANCE 292), Anonymous
* B3 (p/n 2003972-461, SUNDANCE 302), Don Eyles
* B4 (p/n 2003972-471, SUNDANCE 302), Eldon Hall
* B5 (p/n 2003972-421, SUNDANCE 292), Anonymous
* B6 (p/n 2003972-641, SUNDANCE 306), Anonymous

Incidentally, simply combining these modules as-is does _not_ produce an operable program.

Source code may also become available via regeneration from related programs and disassembly.  If/when that occurs, the source will be presented here.