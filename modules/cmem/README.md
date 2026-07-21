## Introduction

> **Note**: This README is a little unusual, in that it serves as a specification and instructions for Claude Code, which was used to create the source code in this directory.  In other words, this README is human-readable, but humans were not the intended audience.

We want this directory to contain a virtual-memory manipulation software, written initially in Python 3, but which when eventually perfected will also be ported to C.  The intention in both cases is to use it as part of a port of the portion of the HAL/S compiler known as SDFPKG.  Specifically, create a file called cmem.py that can be used in Python as an importable module.  Add a stand-alone mode to cmem.py that implements some behavioral tests, and can be used interactively as well for demonstration purposes.

The virtual-memory model simultaneously manages a variable number of "Simulation Data Files" (SDF), which are files in the operating system's filesystem.  All SDF's reside in a single directory, and have the filename extension ".sdf".  However, in the `cmem` API, all SDF's are referred to by their basename alone, and it is `cmem` itself which adds the directory name and filename extension to the basenames when opening their physical files for subsequent access.

## Specification of `cmem` for the Python 3 implementation

`cmem` shall be implemented as a Python `class`.  Below, unless explicitly stated otherwise, when the term "class" is used it refers to the `cmem` class.  When the term "attribute" is used, it refers to a variable belonging to the `cmem` class instance.  When the term "method" is used, it refers to a function belonging to the `cmem` class instance.

The constructor for `cmem` shall have two positional arguments:

- `mem` is a model of physical memory, consisting of a Python `bytearray` object.  It exists in the calling program rather than the class, but the class shall internally maintain a pointer to it. 
- `sdflib` specifies the name of the filesystem directory containing SDF's.  It is provided as a Python string object.

Unless explicitly stated otherwise, use the following assumptions about data read from or written to `mem`:
- Multi-byte areas in `mem` representing integers use a big-endian byte order.
- Integer values stored in `mem` are unsigned rather than signed values.
- When we talk about "bit 0" of an integer, either in `mem` or in a native Python datatype, we are referring to the most-significant bit.
- Textual data stored in `mem` is encoded in EBCDIC, while in a native Python string is it assumed to be ASCII.  The table for converting EBCDIC to ASCII is found in the file asciiToEbcdic.py and is called `ebcdicToAscii`.  The table for converting ASCII to EBCDIC is found there also, and is called `asciiToEbcdic`.

> **Note**: asciiToEbcdic.py has been moved and is now found in the directory ../../asciiToEbcdic/asciiToEbcdic/, relative to cmem.py.

`cmem` shall have a static method called `abend` with numeric a error code as its parameter.  `abend(code)` shall print a message of the Python form `f"Abend {code}"` to `stderr`, and exit to the operating system with return code 1 via `os._exit(1)`.

Central to `cmem`'s API is the concept of the `COMMTABL`. The `COMMTABL` is a 120-byte area within `mem` which is used to pass input arguments to `cmem`'s method and receive outputs from those methods. `COMMTABL` should be thought of as a packed series of fields, in the following order:

 1. `APGAREA` is a 32-bit integer.
 2. `AFCBAREA` is a 32-bit integer.
 3. `NPAGES` is a 16-bit integer.
 4. `NBYTES` is a 16-bit integer.
 5. `MISC` is a 16-bit integer.
 6. `CRETURN` is a 16-bit integer.
 7. `BLKNO` is a 16-bit integer.
 8. `SYMBNO` is a 16-bit integer.
 9. `STMTNO` is a 16-bit integer.
 10. `BLKNLEN` is an 8-bit integer.
 11. `SYMBNLEN` is an 8-bit integer.
 12. `PNTR` is a 32-bit integer.
 13. `ADDR` is a 32-bit integer
 14. `SDFNAM` is an 8-byte text field.
 15. `CSECTNAM` is an 8-byte text field.
 16. `SREFNO` is a 6-byte text field.
 17. `INCLCNT` is a 2-byte integer.
 18. `BLKNAM` is a 32-byte text field.
 19. `SYMBNAM` is a 32-byte text field.

The uses of the fields in `COMMTABL` are described throughout the remainder of this document.

There shall be a method `toNative` that translates `COMMTABL` from `mem` into a Python dictionary with fields of the same name, but converting to native Python datatypes.

There shall be a method `fromNative` that translates a Python dictionary as just described, writing the values into the `COMMTABL` in `mem` after conversion from native Python datatypes.  If the Python dictionary contains only a subset of the `COMMTABL` fields, only those fields are overwritten in `mem`.  Fields with the value `None` should be ignored.  Any additional unknown fields in the Python dictionary shall be ignored.  `fromNative` shall have a named argument `commtabl=None` that can temporarily override `COMMTABL`'s address as stored in `cmem`, thus allowing `COMMTABL` in `mem` to be filled prior to the first call to `monitor22(0)`.

`cmem` manages a Paging Area (PA)  of `mem` consisting of attribute `npages` contiguous "pages", with each page consisting of exactly 1680 bytes, with the first page beginning at the `mem` address given by the attribute `apgarea`.  An additional area called the `FCBAREA` of size `nbytes` (an attribute) is located in `mem` at address `afcbarea` (an attribute); the idea is that `FCBAREA` provides a "file control block" for each of the SDF's being managed, but `cmem` can either use this area or not, as convenient.  At this time, it's recommended that `cmem` not use the `FCBAREA`, but use Python native objects in its place.  It is important not to conflate `COMMTABL` fields like `NPAGES`, `APGAREA`, etc. with `cmem` attributes like `npages`, `apgarea`, and so on, for they are different things.

Terminology:  A "Virtual-Memory Pointer" (VMP) is a 32-bit integer of which the most-significant 16-bit integer is a page number and the least-significant 16-bit integer is a byte-offset into that page.  VMP's relate to the SDF's, not to the PA.

Associated with the PA is a Paging Area Directory (PAD).  The PAD is contained in an area of `mem` or else in a `bytearray` object maintained internally by `cmem`, depending on circumstances described below. The PAD maintains metadata about each page stored in the PA.  PAD entries are as follows:

 1. `PAGEADDR`: A 32-bit integer giving the address in `mem` of the associated page in the PA.
 2. `FCBADDR`:  A 32-bit integer.  The most-significant byte is 0x80 if the page has been modified, 0x00 if not modified.  The least-significant 24 bits are an integer identifying the SDF basename and the open Python "file object" associated with the SDF; the exact means of identifying these things with the 24-bit integer can be chosen by the implementation and is not specified in this document.
 3. `USECOUNT`:  A 32-bit integer.  See the section below on paging strategy.
 4. `PAGENO`:  A 16-bit integer giving the page number, times 8, of the page within the SDF that corresponds to the page in the PA.
 5. `RESUCNT`:  A 16-bit integer.  See the section below on paging strategy.

`cmem` shall have a method called `padSummary` which can summarize the current state of the PAD, returning the summary as a Python dictionary that includes at least the following information:

- The total number of pages in the PAD.
- The number of pages containing cached information.
- A list of cached pages, giving all human-readable information readily derivable from the PAD entry.  It should include the basename of the associated SDF but not the associated Python file object.

`cmem` is allowed to access or modify only portions of `mem` designated as the PA or PAD (if stored in `mem`), the `COMMTABL`, and the `FCBAREA`.  In the case of the PA, the PAD, and the `COMMTABL`, `cmem` can only modify them in the ways specified in this specification.

In addition to the class constructor and destructor, and other methods already mentioned, `cmem` also exposes a method called `monitor22`:

`def monitor22(self, mode, commtabl=None)`

The `commtabl` argument of `monitor22` is used only when `mode` is 0, and is ignored in all other cases.

`mode` is a 32-bit integer, partitioned into the following fields:  bit 0 is the `SELECT` flag, bit 1 is the `MODF` flag, bit 2 is the `RELS` flag, bit 3 is the `RESV` flag, and bits 16-31 are a 16-bit integer `MODE_NUMBER`.  The subsections that follow specify the behavior of `monitor22` for the various allowed values of `MODE_NUMBER`.  These 4 flags are collectively referred to as "disposition parameters".

Terminology:  Anything specified below as "TBD" need not be implemented at this time, and when specified at some future time will represent modifications to the implementation.

### `MODE_NUMBER` == 0

Initializes the virtual-memory model using data in `COMMTABL`.

`monitor22(0, commtabl)` saves the address of the `COMMTABL` for later use, as the attribute `commtabl`.

The following fields of `COMMTABL` are valid and are used now as input:  `MISC`, `APGAREA`, `AFCBAREA`, `NPAGES`, `NBYTES`, `ADDR`, and `PNTR`. `MISC` is resolved into flags:

- `MISC`&0x01:  TBD
- `MISC`&0x02:  Set attribute `updat` as True or False.
- `MISC`&0x04:  (Ignore)
- `MISC`&0x08:  Set attribute `onefcb` as True or False.  If True, then "ONEFCB" mode is used, in which there is a single FCB, and thus only a one SDF can be managed.
- `MISC`&0x10:  Set attribute `first` as True or False.  This flag is used by users of the `cmem` class, but is not used internally by `cmem` itself.
- `MISC`&0x20:  TBD
 
Additionally, the following initializations occur:

- If `PNTR`>0 and `PNTR`<4096, store `ADDR` as the attribute `pad` and `PNTR` as attribute `padSize`.  The PAD is in `mem`, with `pad` and `padSize` giving its address and size (in bytes).  Note that each PAD entry is 16 bytes, so `padSize` is 16 times the maximum number of entries.
- If `ADDR` and `PNTR` are both 0, use an internal `bytearray` for the PAD, `pad`=0 and `padSize`=16*250.
- If `NPAGES`==0 then `abend(4013)`.
- If `APGAREA`>0, then save `APGAREA` as attribute `apgarea` and `NPAGES` as attribute `npages` to define the location in `mem` of the PA, as well as its size.  The PAD must have at least as many entries as there are pages in the PA.
- If `APGAREA`==0, then TBD.
- If `AFCBAREA`>0 and `NBYTES`==0, then `abend(4015)`.
- If `MISC`&0x01==0 and `AFCBAREA`>0, save `AFCBAREA` and `NBYTES` as the location in `mem` of the `FCBAREA` and its size.
- If `MISC`&0x01==1 and `AFCBAREA`>0, then TBD.
- If `AFCBAREA`==0, then TBD.

Output upon return:

- `CRETURN` = 0
- `ADDR` = TBD
- `APGAREA` = 0
- `AFCBAREA` = 0
- `NBYTES` = 0
- `NPAGES` = length of the PAD in entries.  I.e., size in bytes, divided by 16.

In general, any other call to `monitor22` for which a call to `monitor22(0)` has not previously been made should result in `abend(4009)`.

If a call to `monitor22(0)` is made more than once, it should result in an `abend(4017)`.

### `MODE_NUMBER` == 1

This terminates `cmem`.  It should search the PAD for any pages in the PA marked as "changed" via the most-significant byte of `FCBADDR`, write the contents of those pages to the assocated pages in their SDF's, then flush the file objects.  It should then close all open "file objects" referenced in PAD entries.  It should then modify `COMMTABL` as follows and call the class destructor.

- `CRETURN` = 0
- `APGAREA` = 0
- `AFCBAREA` = 0
- `NBYTES` = 0
- `NPAGES` = 250.

### `MODE_NUMBER` == 2

This feature of the original SDFPKG.ASM, "augmenting the paging area and/or FCB area", shall not be implemented. It should result in `abend(4001)`.

### `MODE_NUMBER` == 3

This feature of the original SDFPKG.ASM, "augmenting the paging area and/or FCB area", shall not be implemented.  It should result in `abend(4012)`.

### `MODE_NUMBER` == 4

Upon entry, `SDFNAM` contains the basename of an SDF.  Recall that before associating the basename with an actual SDF, the name needs to be converted from EBCDIC to ASCII, the filename extention ".sdf" needs to be added, and the path to the SDF library directory must be prepended.

`cmem` should be maintaining as an attribute the list of the SDF's currently being managed (initially empty), as well an attribute specifying which of the particular SDF's on the list is the "current" one.   Using the PAD, find any cached pages in the PA associated with this SDF basename.  If there are none, check to see if the SDF is present as a file in the filesystem.  If it is not present, set `CRETURN` to 8 and return immediately.  Otherwise, add the SDF to the list of SDF's being managed, fetch the first page of the SDF into the PA, and adjust the associated PAD entry accordingly.  This will involve opening the SDF as a Python file object with type "r+b".  The file will remain open until the SDF is deselected (see `MODE_NUMBER`=18 below) or `cmem` is terminated (see `MODE_NUMBER`=1 above).

In either case, set the selected SDF as the "current" one.

Set `CRETURN` to 0, and return.

In general, if any other call to `monitor22` is made that requires there to be a currently-selectd SDF, but no call to `monitor22(4)` has previously been made, then `abend(4010)`.


### `MODE_NUMBER` == 5

Upon entry, `PNTR` contains a VMP.  If the offset encoded within the VMP is not in the range 0 through 1679, or if the 1680-byte page number encoded within the VMP does not exist within the currently-selected SDF, then `abend(4005)`.

Otherwise, store the selected page number into the attribute `recentPage` and the currently-selected SDF basename into the attribute `recentSDF`, cache the selected page into the PA, updating the PAD accordingly.  Also, handles the disposition parameters as described for `MODE_NUMBER`==6 below.

Set `CRETURN` to 0 and `ADDR` to the address in `mem` corresponding to the VMP, and then return.

For convenience, `cmem` shall have a method called `mode5` providing the same functionality as `monitor22(5)` insofar as managing the caching is concerned, but bypassing `COMMTABL` for its input and output.  Instead, `mode5` shall accept an input argument which is a VMP, and shall return the address in `mem` corresponding to the VMP.

### `MODE_NUMBER` == 6

This call simply deals with the disposition parameters, and nothing more.  It is intended to allow alternate disposition parameters to be selected after a call with `MODE_NUMBER`==5 has already been made with different disposition parameters.

Specifically, find the  PAD entry for the already-cached page indicated by the attributes `recentPage` and `recentSDF`.  If `MODF` is nonzero, but the `update` attribute is 0, then `abend(4008)`; otherwise, set the most-significant byte of the `FCBADDR` field in the PAD entry for the page to 0x80 (for `MODF`!=0).  If non-zero, `RESV` increments the `RESUCNT`, while `RELS` decrements it unless it's already 0.

Set `CRETURN`=0 and return.

### `MODE_NUMBER` == 18

Upon entry, `SDFNAM` contains the basename of an SDF.

Using the PAD, find any cached pages in the PA associated with this SDF basename.  (Recall that the basename needs to be converted to ASCII).  If there are no such pages, or if any are locked (`RESUCNT`>0), then this operation cannot be performed, `CRETURN` should be set to 8, and `monitor22` should immediately return. 

If any are marked as modified, write the modified pads to the correct locations in the SDF, then flush the SDF and close it.  In the PAD, mark all pages associated with the SDF as free.  Set `CRETURN` to 0 and return.

### Any other `MODE_NUMBER`

Perform an `abend(4016)`.

## `cmem` Paging Strategy

As mentioned, each page cached in the PA is associated with an entry in the PAD, two of whose fields are `USECOUNT` and `RESUCNT`.

`cmem` shall maintain an internal counter (attribute `usecount`) that increments on each call to method `monitor22`.  Whenever a page from the PA is accessed, its `USECOUNT` entry in the PAD is updated with the current `usecount` value. 

As mentioned earlier, it is possible for a call to `monitor22` to "lock" a page.  Every lock operation on a page increases `RESUCNT` by 1, while every "unlock" operation decreases `RESUCNT` by 1.

With each new attempt to access an SDF page via the method `monitor22` that is not already cached, one of three cases applies:  

1. If free pages remain with the PA, then one of those free pages will be used to cache the contents of the page from the SDF, and the entry in the PAD will be updated accordingly.
2. If no free pages remain, and all of the used pages remain "locked" (`RESUCNT`>0), then an `abend(4001)` shall occur.
3. If no free pages remain, but some pages are unlocked, then `cmem` shall choose the least-recently-used unlocked page as indicated by the PAD entries' `USECOUNT` fields.  If the `FCBADDR` field in the PAD entry has its most-significant bit set, then write its contents to the associated page in the SDF.  Then discard the contents of that page in the PA and its entry in the PAD, overwriting both with data appropriate to the new page being accessed.

Note that any activity causing a page in the PA to be written to its corresponding SDF should set the most-significant byte of `FCBADDR` in the PAD entry to 0x00.

