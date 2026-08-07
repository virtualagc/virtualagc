# Introduction

The file sdfpkg.py can be used either as a module or as a stand-alone program.  It 
contains a single class, `sdfpkg`, plus a main program.  The `sdfpkg` wraps `cmem` and `sdf` class operations in methods that are intended to be as similar as possible to calls to SDFPKG (usually wrapped in the `MONITOR(22)` function) that the HAL/S compiler, HALSTAT, MAFGEN, etc. use to access SDF's.

In other words, `sdfpkg` serves as an adapter for using between HAL/S code and the SDF operations actually implemented by either `sdf` or `cmem`.

Additionally, while parsed data from SDF's is maintained in the attributes of instances of `sdf`, the instance of `sdf` is available from an instance of `sdfpkg` via its `s` attribute. For example, if `sdfpkg` were instantiated as `mySdfpkg`, the attributes of an SDF parsed by `sdf` would be available via `mySdfpkg.s`, such as `mySdfpkg.s.masterDirectoryCell`, 
`mySdfpkg.s.masterDirectoryCell.phase3VersionNumber`, and so on.  To make sense of those, run "sdfpkg.py --sdf='SOMESDF' --show-dict" in stand-alone modeto get a listing of the full class hierarchy, and cross-reference to the ICD to see which attribute names match to which fields in the SDF.

`MONITOR(22)` calls accept a "mode number" specifying the desired function to
be performed.  There is a Python dictionary called `COMMTABL` which is used to 
pass input arguments from the calling program and to hold the output results to 
the calling.  So to use the `sdfpkg` class, the calling code must first 
establish `COMMTABL`.

Some of the input and output fields in `COMMTABL` are pointers to the page
cache, which is supposed to reside in "memory", so the calling code must also
have a memory model for the page cache to reside in and for the pointers to
point to.  In Python, that model should be a large `bytearray` object, such
as 
    memoryModel = bytearray(0x100000)

The first steps are to instantiate `sdfpkg` and to call `MONITOR(0)`, which 
together will also instantiate the other two classes:

    mysdfpkg = sdfpkg(memoryModel, "SDFLIB", COMMTABL)
    ...
    # Set the fields in `COMMTABL` that are needed for mode 0.
    # According to the "SDFPKG User's Guide", those are `MISC`, `APGAREA`,
    # `AFCBAREA`, `NPAGES`, `NBYTES`, `ADDR`, and `PNTR` ...
    ...
    mysdfpkg.sdfpkg(0, addrComtabl) # Initialize `sdf`.
    # The fields in `COMMTABL` and the page cache in the memory model are now
    # altered somewhat to reflect the results of the operation.

The same pattern applies to all modes calls (i.e., `mysdfpkg.sdfpkg(mode)`, 
except that it is no longer necessary to pass `commtablAddress` as an argument 
after the location has been established by mode 0.

All variables use native Python datatypes, except that blobs or text read from 
the SDF is in `bytearray`'s that retain whatever encoding the SDF uses itself.
In stand-alone mode, text is translated to ASCII for display purposes.

# Unimplemented Features

Some SDF features  may be unimplemented simply because I haven't gotten around
to them yet or haven't understood that they were present.  I won't bother to
list them here, since I may not know about them anyway.  Some features are 
intentionally not implemented, and I want to list those here.

"Augmenting" the Paging Area and/or FCB Area (Mode 2):  This involves the
awful complication of trying to use SPACELIB to reallocate the memory arrays.
The Python version of the HAL/S compiler (HAL_S_FC.py) doesn't even have any
analog for SPACELIB.  But at any rate, it just seems unnecessary.  Instead,
alter the XPL/I or Python code of the HAL/S compiler or HALMAT or whatever
to just use an adequate worst-case size for the Paging and FCB areas to begin
with.  Of course, this is a limitation of `cmem` more than `sdf` or `sdfParser`.

"Rescinding" the Paging Area Augments:  Same thing!

# DASS comparison tooling

These scripts compare HAL/S-FC compilation and linking against the MAFGEN
AP-101S memory dumps.  The end-to-end process is written up separately, in
`PFS/mafgenComparison.md`; what follows is what each script is for.

`dass-db.py` holds the schema and the CSECT-to-source mapping for all eight
memory configurations.

`dass-run.py` drives `compileLinkCompare` over a configuration's source files,
parses `fcmcmp`'s output, and records runs, sections and differences in
`dass-compare.db`.  Two options matter more than they look:

  --reparse    rebuilds the database from the saved logs without recompiling
               anything.  This is what makes improving the parser cheap: the
               first SSW survey had to be re-read twice, once for an em-dash in
               fcmcmp's output and once for its shift analysis.
  --jobs-root  gives each parallel compile its own source tree.  This is not a
               convenience.  HALSFC writes halmat.bin, litfile.bin and
               COMMON*.out into its working directory under fixed names, so two
               compilations sharing a directory destroy each other -- and that
               is true of two *live* sweeps just as much as of a killed run
               leaving debris.  It cost one option sweep and one SDL sweep,
               both restarted, before the cause was understood.

A full SSW sweep is about eleven minutes at roughly three seconds a file, which
is cheap enough that building a driver was worth it immediately.

`dass-syms.py` recovers CSECT addresses that the MAFGEN scrape could not.  It
parses HALSTAT's CSECT INFORMATION blocks and cross-validates each candidate
against the memory dump using the unresolved relocations `lnk101` reports, then
emits an augmented external-symbol table to pass to `compileLinkCompare` as
`--ext-syms`.  It needs a sweep's link outputs, so run one with `--out-dir` kept
first: without them it cannot know which symbols went unresolved, or where.

`dass-literals.py` records the locations MAFGEN marks with `*` -- I-LOADs,
patches and checksums, applied after the build -- as comparison exceptions.

`dass-versions.py` records, as no-claim exceptions, differences attributable to
our source holding a unit at an older revision than the dumped build.  It reads
MAFGEN's own disassembly as well as lnk101's output, because each instruction
line there resolves the operand to an effective address and usually names the
variable -- evidence that exists precisely where a relocation record does not.

# Reading a compiled SDF

Occasionally a question is best answered from an SDF directly: what offset our
compiler assigned a variable, what a COMPOOL declares, how big its
initialization table is.  `modules/sdf` will do that, but its entry point is not
obvious, because the reader never opens the file.  `cmem` -- the compiler's own
virtual-memory manager, reimplemented in `modules/cmem` -- pages the SDF into a
flat `bytearray` first, and `sdf` then walks the structure through it from the
Master Directory Cell.  So `parseSDF()` takes no filename; handing it a path
fails with `'str' object has no attribute 'offsetForGet'`.

    from cmem import cmem
    from sdf import sdf

    c = cmem(bytearray(0x400000), "SDFLIB")
    c.fromNative({"MISC": 0, "APGAREA": 0x2000, "AFCBAREA": 0, "NPAGES": 64,
                  "NBYTES": 0x400, "ADDR": 0, "PNTR": 0}, commtabl=0x100)
    c.monitor22(0, 0x100)                    # mode 0, initialise
    c.fromNative({"SDFNAM": "##CSPCLB"})
    c.monitor22(4)                           # mode 4, select
    s = sdf(c)
    s.parseSDF()

Only initialisation and selection need `MONITOR(22)` mode calls, since those are
`cmem` state changes; everything after reads Python objects rather than querying
through the historical interface.  The parse yields `masterDirectoryCell`,
`directoryRootCell`, `blockIndexTable`, `symbolIndexTable`, `statementIndexTable`,
`initializationTable`, `titleDataCell`, `cardtypeDataCell` and `includeTextData`.
`s.fullSymbolASCII(entry)` decodes the EBCDIC names.

Two things that are easy to miss.  A variable's offset within its CSECT is
`symbolDataCell.relativeMemoryAddressOfSymbol`, present on `symbolClass` 1;
LABEL symbols carry `statementNumber` instead and have no address, so sampling
one of those suggests -- wrongly -- that the SDF does not record allocation at
all.  And `blockIndexTable[0].blockCsectName` gives the CSECT the block belongs
to, in EBCDIC.

# Extracted references

Plain-text extracts live in `refs/`, so they can be grepped rather than
re-opened as PDFs:

  refs/HAL_S-FC-Users-Manual-2005.txt
      from USA003090, the November 2005 HAL/S-FC User's Manual.

  refs/IBM-82-SS-4556-Programming-Standards-Rev4.txt
      the Orbiter Avionics Software Programming Standards Document, for its
      CSECT and block naming standards.
