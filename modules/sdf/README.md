## Introduction

The file sdf.py can be used only as an importable module. It implements the class `sdf`, which parses SDF's via data in the `vmem` page cache.  The parsed data resides in the `sdf` class's attributes.

Requred is the `cmem` module, which implements the `cmem` class used for providing "virtual memory". In general, external code does not deal with `sdf` directly, but rather with the `sdfpkg` class, which then uses `sdf`.  Functionality which might otherwise be provided by the non-existent stand-alone mode for `sdf` is generally provided by the stand-alone mode of `sdfpkg` instead.

Parsing closely follows the description of the SDF format in document USA001556, 
"HAL/S-FC SDL Interface Control Document".  Some convenience features have been added to the parsed data.

# Unimplemented Features

Some SDF features  may be unimplemented simply because I haven't gotten around
to them yet or haven't understood that they were present.  I won't bother to
list them here, since I may not know about them anyway.  Some features are 
intentionally not implemented, and I want to list those here.

HALMAT:  If the HAL/S compiler parameter HALMAT is used, then HALMAT is included
in the SDF's.  However, the ICD (September 2005) has this comment about it (PDF 
p.132):

> NOTE: The HAL/S-FC compiler feature that results in the creation of HALMAT 
Data Structures [in the SDF] is not used and there are no plans for using 
it. This feature should be considered “unverified “ and should not be used 
in a production environment. The description of HALMAT Data Structures 
contained in the subsequent sections may not accurately reflect what the 
HAL/S-FC compiler will produce if this feature were to be used.

And the surviving BFS reports show explicitly that their source code was 
compiled with the NOHALMAT option.  Given this stance, so near the end of the 
termination of the Shuttle program, and given that no HALMAT data appears in 
any surviving MAFGEN or HALSTAT report, I have little inclination to waste any 
of my own time parsing SDF HALMAT info in the foreseeable future.
