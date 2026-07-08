# Contents

* [Introduction](#introduction)
* [Some Notes About the Ported SDFPKG](#some-notes-about-the-ported-sdfpkg)
* [What's Here](#what-s-here)
* [Some Background Info](#some-background-info)

# Introduction

This folder holds a port of [SDFPKG.ASM](https://github.com/virtualagc/virtualagc/tree/master/yaShuttle/Source%20Code/PASS.REL32V0/SDFPKG.ASM), an IBM Basic Assembly Language (BAL) subroutine called by several passes of the original HAL/S compilers (HAL/S-FC and HAL/S-BFC), to both C and to Python.

The following documentation related to SDFPKG has survived:

* IR-95-5, the <a hrel="https://www.ibiblio.org/apollo/Shuttle/19760015838.pdf#page=108"><i>HAL/S-FC Compiler System Specification</i> (1976), section 4.0</a>, provides some high-level information about SDF's and their creation by PASS3 of the HAL/S compiler.
* IR-182-1, the <a hrel="https://www.ibiblio.org/apollo/Shuttle/19760020796.pdf#page=815"><i>HAL/S-FC & HAL/S-360 Compiler System Program Description</i> (1976), section 12.0</a>, describes the access routines provided by the package for accessing the SDF.  It recommends document IR-60 (see below), but "augments the description" given in it, "providing details inappropriate in that forum".
* IR-60-5, the <a hrel="https://www.ibiblio.org/apollo/Shuttle/HAL_S-360%20Compiler%20System%20Specification%204%20Feb%201977.pdf#page=106"><i>HAL/S Compiler System Specification</i> (1977), section 5.9</a>, describes the usage of the access routines provided by the package.  But unfortunately, our copy contains only <i>changed</i> pages relative to the preceding document revision, and is therefore incomplete.
* Memo, <a hrel="">"Simulation Data File (SDF) Access Package" (1992)</a>, seems to be an earlier version of the <i>SDFPKG User's Guide</i> (see below) but is different in various respects such as describing a PL/I interface to the package.
* SFPC-PASS0092, the <a hrel="https://www.ibiblio.org/apollo/Shuttle/SDFPKG-USERS-GUIDE-29-14.pdf"><i>SDFPKG User's Guide</i> (1999)</a> for PASS 29.0 and BFS 14.0, documents the SDFPKG API, both for the original assembly-language source code and for a C-language port of it (whose source-code has not survived as far as I'm aware).
* USA001556, the <a hrel="https://www.ibiblio.org/apollo/Shuttle/HAL-S-FC-SDL-INTERFACE-CONTROL-DOCUMENT.pdf"><i>HAL/S-FC SDL Interface Control Document</i> (2005)</a>, documents the structure of the Simulation Data Files (SDF) upon which SDFPKG operates.

Our own port was created by submitting the entire BAL source code of SDFPKG.ASM, along with required macro definitions (DIAGNSTC.MACLIB), to Anthropic's Claude Sonnet version 4.6, requesting that it be ported to both C (for integration into HALSFC and HALSTAT) and Python 3 (for integration into HAL&lowbar;S&lowbar;FC).  (I did not submit the file TEST1.bal, a simple test program.)  Each source-code file (&ast;.h, &ast;.c, &ast;.py, Makefile, &ast;.hal) was coded entirely by Claude, albeit with my (RSB) direction.  No source-code file in this directory has been written or even edited by humans.

By definition, <i>Simulation Data Files</i> (SDF) are objects created during compilation of source code written the HAL/S language.  Ideally, they are created by PASS3 of the HAL/S compiler, although the original compilers <i>wrote</i> SDF's directly and only used SDFPKG to <i>read</i> SDF's.  Again ideally, the SDF's are subsequently potentially used in a variety of ways, of which those of most importance to us are (in descending order of importance):

1. Imported into PASS1 of the HAL/S compiler when compiling <i>other</i> HAL/S source-code files, as a transparent alternative to importing so-called "templates".  This is likely key to fixing certain intractable compilation problems &mdash; see issue #1281 and issue #1280 &mdash;, but is not yet implemented in PASS1.
2. Fed into the HALSTAT program (not yet ported for modern use) for producing certain kinds of reports.
3. Fed into PASS4 of the compiler (not yet ported) for actual simulation purposes.

# Some Notes About the Ported SDFPKG

Originally, since HAL/S compilation occurred in an IBM System/360 environment, SDF's partook of the special characteristics of that environment, but that's not necessarily useful in modern terms.  Specifically:

* The SDF's originally were so-called Partitioned Data Sets (PDS).  Claude has instead invented its own "synthetic flat-file" format, based on POSIX-type filesystems.  However, there is a conversion program that can convert back and forth from the synthetic flat-file format to true PDS.  True PDS if implemented strictly is itself a file format, in which a single file contains all of the members of the PDS.  It is more-convenient in some ways to model a PDS as a directory in which each member of the PDS is itself a file.  The conversion program also allows for conversion of PDS files to/from directories of PDS-member files.
* Symbolic labels retained their EBCDIC encoding within the original PDS-based SDF's.  I've asked Claude to use standard ASCII encoding instead.
* SDFPKG originally concerned itself entirely with <i>reading</i> SDF's in various ways.  The port adds a framework (invented by Claude) for <i>writing</i> SDF's as well.
* The HAL/S compiler, in any form (original HAL/S-FC, or modern HALSFC and HAL&lowbar;S&lowbar;FC), does not call `SDFPKG` directly for reading SDF's.  Rather, it calls the `MONITOR(22, ...)` function, which then calls `SDFPKG` essentially by passing its arguments (other than the leading 22) directly to `SDFPKG`.  Writing to SDF's, in the modern ports of the HAL/S compiler, requires direct calls to the ported SDFPKG.
* It should be possible to build the C port in Linux, Mac OS, or Windows w/ MSYS2, using either gcc or clang as the compiler.  To date, I've only tried it in Linux.
* Although I've chosen to locate this material in a directory used for HAL&lowbar;S&lowbar;FC.py source code, only the file sdfpkg.py relates to HAL&lowbar;S&lowbar;FC.py, and in particular, the C files do not do so.  Instead, they are compiled and used by HALSFC, located elsewhere.  Putting them all here was merely a reasonably-convenient way to keep all of the Claude-generated files together, which seems to me at the moment to be a prudent thing to do.

# What's Here

Here is a rundown of the files in this directory, as distributed:

* README.md: This file you're reading right now, of course!
* sample.sdf, make&lowbar;sample&lowbar;sdf.py, NAVCOMP.hal: A sample SDF (synthetic format), the Python file that created it, and a HAL/S source-code file that's intended to be consistent with the contents of the SDF.  (The program demo_sdfpkg.py, below, is actually a more-flexible and possibly more-current way to create these sample SDF's.)
* In Python 3:
    * sdfpkg.py: This is an importable module that comprises the entirety of the original SDFPKG functionality, plus the new framework for writing SDF's. It's intended for integration into the HAL/S compiler HAL&lowbar;S&lowbar;FC.py, but there's no reason it cannot be imported by other Python program as well.  It can also be run in standalone mode (try `sdfpkg.py --help`) to perform various functions.  At this writing, those functions are:
        * List the members of a given SDF (synthetic flat-file format).
        * List the members of a given SDF (true PDS).
        * Convert an SDF in true PDS to the synthetic flat-file format.
        * Convert an SDF in the synthetic flat-file format to true PDS.
        * Validate members of an SDF (synthetic format) via the port of SDFCHECK.
        * Convert a true-PDS file to a directory of member SDF files.
        * Convert a directory of member SDF files to a true-PDS file.
    * sdfpkg&lowbar;dump.py: A utility for creating a human-readable report about the contents of a given SDF (synthetic format).
    * test&lowbar;sdfpkg.py: A program for testing sdfpkg.py.
    * demo&lowbar;sdfpkg.py: A demo program originally intended merely to teach how to use sdfpkg.py to read and write SDF's.  Over time it has acquired useful capabilities as a stand-alone utility, including the ability to create SDF's to which new members (compilation units, described by user-supplied JSON files) can be added, or existing members can be modified, extracted, or deleted.
    * sdf&lowbar;json&lowbar;format.md: A file that documents how to create the JSON files used by demo&lowbar;sdfpkg.py (see preceding item).
* In C:
    * Makefile: For building the C port &mdash; which again, is entirely unnecessary just for <i>using</i> the Python port &mdash;, using a `make` utility such as GNU `make`.  Use `make clean all` for a clean build of the C code.  (The C the compiler is auto-selected, first by consulting the CC environment variable, then falling back on clang if that fails, and finally falling back on gcc.  Use of gcc or clang can be forced with `make CC=gcc clean all` or `make CC=clang clean all`.)
    * All &ast;.c and &ast;.h except test&lowbar;&ast;.c: The C port of SDFPKG.  It's intended for use in HALSFC-PASS1, HALSFC-PASS3, HALSFC-PASS4, and HALMAT, but there's no reason it couldn't be used as well by other C programs or XPL/I programs translated into C.
    * test&lowbar;sdfpkg.c: A comprehensive test program for the C port.
    * test.sdf&lowbar;write.c: An older test program limited to just the SDF-writing framework.
    * (It seemed unnecessary to create a C equivalent for demo&lowbar;sdfpkg.py, so I haven't done so.)

<i>After</i> building the C port, there will be various additional files (removable by <code>make clean</code>) as well:

* libsdfpkg.a: A linkable library containing public functions for the C port of SDFPKG.
* sdf&lowbar;convert\[.exe]: A program having the same SDF-conversion and SDF-listing functionality as sdfpkg.py does (when run in its stand-alone mode).

If you should have occasion to compile NAVCOMP.hal &mdash; for which I personally use the command <code>HALSFC --clean --archive --test NAVCOMP.hal</code> &mdash;, you'll also find additional directories and files like the following:

* &ast;.results/
* TEMPLIB/ and TEMPLIB.json
* INCLIB/ and INCLIB.json

I've provided no particular command for deleting these, so if you object to them they'll have to be removed manually.

# Some Background Info

Craig Schulenberg, the original designer and implementer of SDF's, has told me various things about them, which I'll just quote some of them here for quick reference, verbatim, without any attempt to predigest them for you.

> I believe that the OUTPUTSD code is complete and is 'universal'; it writes out to a datafile (an SDF) the 1680-byte SDF 'pages' that have been used throughout PASS3. The SDF is a series of 1680-byte fixed-length records that contain 'logical' data blocks (cells) that are interconnected by virtual memory 'pointers', a fullword broken up into a 16-bit page number (identifying a 1680 byte record within the SDF) and a 16-bit page offset. PASS3 builds up the SDF as it runs, and uses the various VMEM (VMEM1, VMEM2,...) functions (which I also wrote) to gradually put the SDF together. PASS3 reads the Symbol Table (passed to it from PASS 1 and 2), various  data arrays (also passed via common memory), and even the HALMAT. I believe that after I had ceased to be involved with the compiler, the VMEM machinery was utilized in more and more places in the earlier compiler phases (including AUXMAT, FLOMAT) as a generic way to pass large amounts of structure data  from one part of the compiler to another. Then, PASS3 just has to add its own data, allowing OUTPUTSD (SDF) to simply write the 1680-byte blocks out to the SDF fatafile. So, this is a simple process.

Here, [OUTPUTSD refers to a source-code module](https://github.com/virtualagc/virtualagc/blob/master/yaShuttle/Source%20Code/PASS.REL32V0/PASS3.PROCS/OUTPUTSD.xpl), written in the XPL/I language, within PASS3 of the HAL/S compiler.  Similarly, [VMEM](https://github.com/virtualagc/virtualagc/tree/master/yaShuttle/Source%20Code/PASS.REL32V0/HALINCL) refers to various modules comprising the compiler's "virtual memory" system.

> [I] was asked to add 'SYM' cards to the HAL/S compiler (Pass 3, and then 4), I decided to 'overkill' the job by re-implementing my PDF-15 'virtual memory' functionality  in XPL, using it to actually construct the Simulation Data File (SDF) as a hierarchical structure of 'cells', interconnected by virtual memory 'pointers' (16-bit page# and 16-bit offset on the page). Each 'page' was 1680 bytes of disk space, and there was a 'paging area', with memory addresses of each in-memory 'page', usage counters, etc., so as to form a demand paging system.

> Later, [others] decided to use the VMEM functions (pointing to a different direct-access file) to pass miscellaneous information between the two phases (in addition to the HALMAT), and also into the intermediate code optimization phases (1.5, 1.25?, 1.75?). EVENTUALLY, so much data was packed into each SDF that Intermetrics was able to use SDFs 'instead of' Templates, i.e., instead of including a Compool template as ASCII source, the compiler would instead read in the SDF for the Compool since it contained: (1) the Symbol Table, (2) the Literal Table, and (3) even the HALMAT). This greatly sped up compiles since Phase 1 could simply read the SDF (via the compiler's Submonitor making calls to my SDFPKG SDF Access functions in BAL).  However, we never really need to implement SDFs for anything that we want to do, nor do we care if their availability would allow us to speed up the compilation process.

The term "submonitor" refers to BAL software that formed a bridge between the original HAL/S compiler, HAL/S-FC, and the System/360 operating system; [its source code is here](https://github.com/virtualagc/virtualagc/tree/master/yaShuttle/Source%20Code/PASS.REL32V0/MONITOR.ASM), but it is entirely unused in the modern port of the compilers since there's no System/360 operating system.  To the extent that the submonitor's functionality has been implemented, it has been done in the [XPL/I compiler's (XCOM-I) runtime library](https://github.com/virtualagc/virtualagc/blob/master/XCOM-I/runtimeC.c) and in [HAL&lowbar;S&lowbar;FC.py's runtime library](https://github.com/virtualagc/virtualagc/blob/master/yaShuttle/ported/xplBuiltins.py).  If this experiment with SDFPKG goes well, though, perhaps the submonitor <i>should</i> be ported to C.

> I built the SDFs in the form of Virtual Memory 'databases', implemented via VM pointers within a fixed-blocksize direct access file that contained data structures like 'cells', chains, rings, dequeues, multicopy structs, etc. The SDF creation and access mechanism was to use my BAL program SDFPKG that was called via XPL functions that invoked SDFPKG functions from the Compiler/XPL Monitor.  Later, SDFs were used instead of source templates to implement the compilation process. This turned out to be much faster since SDFs were already fully digested and dense with all the information that PASS1 would need to understand the calling sequences of Comsubs and Common Functions, as well as COMPOOLs, but there was never anything wrong with having the compiler emit condensations of key information about a compilation unit as a source 'template' that would be INCLUDEd by any HAL/S compilation unit that needed to reference that previously-compiled function/comsub/Compool.

> I developed SDFPKG in maybe 1974-75, actually writing a lot of it while testing it line-by-line in the TEST mode that allowed me to set breakpoints and examine registers. Thereafter, the code remained pretty much unaltered for over 30 years and was used as-is right up to the end of the program. The only significant change that I made to the program, perhaps in the late '70s or early '80s was to replace its TTR logic. Partitioned Data Sets (PDS) have an associated list of direct disk pointers (TTRs) that each point to a successive physical data block. I used to read in the TTRs from the PDS and keep them in an internal table, thus permitting 'direct access' to a given 'page' of an SDF, thus resolving a virtual memory pointer (page# + offset on the page). However, eventually IBM found that when they 'moved' PDS datasets to other physical devices, using later utilities, that the TTRs were not recalculated and thus became garbage. So, I modified SDFPKG to read each page of a newly opened SDF member, obtaining its TTR value in the process, and saving them in a Table for further use.  Anyway, the nice thing about a PDS was that you had a 'folder' that contained individual SDF 'databases' of compiler metadata, but that which also supported direct access to any page/offset within each file, thus supporting a virtual memory demand paging environment. I later continued these ideas when I added the VMEM functions in XPL to permit the HAL/S compiler to also use a page/offset demand paging temporary file manipulation capability for passing metadata between the various compiler phases.

> I also worked on the HAL/SDL ICD (USA001556 document), and thus it contains extensive detail about the layout and contents of an SDF. Historically, HAL/S is unique because perhaps as much effort was devoted to having it generate METADATA, as was ever devoted to having it generate code.

> With all of that being said, it would be fairly straightforward to replace SDFs with fixed-blocksize files that could be manipulated using C, for example. It might be 500 lines of C code before all was said and done, but there would be no need for assembly language. After all, I redeveloped a similar concept using XPL (the VMEM machinery in the HAL/S compiler).

> Note that it would not be a major job to redevelop SDFPKG in C, thus allowing the compilation process to switch to its preferred method of using SDFs as input instead of processing source templates. There is a huge speed improvement when doing this, but for your purposes this is no major gain. However, having SDFPKG would allow you to compile the HALSTAT tool, and this would provide visibility over the entire HAL/S program complex. Pass 3 would be straightforward once there is an SDFPKG, and Pass 4 would be totally optional since its main use was in debugging Pass 3 as more and more data categories were added to the SDF as the decades rolled by -- first, the addition of the HALMAT, and eventually, the addition of the entire Symbol Table (and Literal Table) that would permit SDFs to be used instead of source Templates.
