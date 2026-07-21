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
