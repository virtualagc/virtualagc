## General Rules

This document describes the structure which GPC emulators, whether emulating HALMAT or emulating AP-101S machine code, should have for efficient integration into spaceflight/spacecraft simulation software. The goal is for the spaceflight-simulation software to both have quickly-executing GPC emulations but also to be "emulator agnostic".

Emulators should be written in the C language.

Emulators should be partitioned into a small number of functions forming a public API, compilable into a library with only those functions exposed.

Emulators should have a C-language header file containing prototypes for those public functions.

Emulators should have a separate `main` program that integrates the public functions into a functional stand-alone emulator.

Different emulator implementations should use the same names of functions in the public API, if feasible, but at the very least should use the same function prototypes even if the names differ.

**Note**: Function names can be changed at link-time, using linkers' `alias` or `/ALTERNATENAME` capability, thus allowing the program into which the emulator is integrated to use any emulator interchangeably with any other, or even to link multiple emulators and choose between them at runtime.

## API Functions

### `int gpcStep(void *state);`

**Description**: The function executes a single "instruction", either HALMAT or AP-101, depending on the emulator type.

**Arguments**: `state` is a pointer to a structure that hold _all_ state information about the emulation, such as the GPC ID (1-5), the contents of whatever memory exists, the state of CPU registers (if any), the current program counter, the number of instructions executed, the total emulated time consumed, and so on. The nature of the contents of the structure varies according to the particular emulator. This is why a `void *` is used rather than a particular `typedef` or `struct`. The `state` is updated in place. Rather than dictate any of the layout of the structure, there are separate API functions, `readGpcState` and `writeGpcState` (see below) by which external code can read/write certain common fields of the structure, without knowing anything about the structure layout.

Note that this allows multiple emulators to run simultanously, of the same or different types. For example, one could run 5 different emulators simultaneously, one for each GPC in a Shuttle.

**Returns**: 

- 0 &mdash; Success. The emulator is capable of emulating additional instructions.
- 1 &mdash; Success. The program being emulated has reached its conclusion and nor more instructions can be processed.
- 2 &mdash; Failure. A fatal yaHALMAT2 error has occurred. The error code can be interrogated using `readState`.
- 3 &mdash; Failure. The program being emulated has exited with a error code. The error code can be interrogated using `readState`.

### `uint64_t readGpcState(void *state, int item);`

**Description**: The function reads the value of a single field of `state`. The specific field read is determined by the `item`.

**Arguments**: `state` is as described for `gpcStep` above. The allowed values for `item` are:

- 0 &mdash; the GPC ID (1, 2, 3, 4, 5). Actual type `uint8_t`.
- 1 &mdash; the total number of instructions executed for this GPC.
- 2 &mdash; the total amount of elapsed emulation time, in nanoseconds.
- 3 &mdash; the program counter. This is not necessarily interpreted as a single integer. For AP-101S, it will be the `PSW` register. For yaHALMAT2, it might (perhaps!) consist of a number indicating the particular compilation unit in the upper 32 bits, combined with the HALMAT instruction number within that particular compilation unit.
- 4 &mdash; yaHALMAT2 error code from the latest `gpcStep`. In particular, 0 is "no error". Others are TBD.
- 5 &mdash; error code from the program(s) being emulated, from the latest `gpcStep`. 0 is "no error", others are TBD.
- 6+ &mdash; TBD

**Returns**: The value of the item. Although returned as an "unsigned" value in order to specify some specific C datatype, not all requestable fields of `state` are necessarily of this datatype and may need to be cast or converted to the desired type. If the request itself was illegal due to a bad `item` type, 0 is returned. It is assumed that the documentation has been consulted and that this condition cannot occur.

### `int writeGpcState(void *state, int item, uint64_t value);`

**Description**: The function writes the `value` of a single field of `state`. The specific field read is determined by the `item`.

**Arguments**: The comments in `readGpcState` apply. The `value` argument is what would be returned by `readGpcState`.

**Returns**: Returns 0 on success, 1 on failure. Use `readGpcState` to fetch the exact error code in the latter case.

### `void * initializeGpcState(const char *filename, uint64_t entryPoint);`

**Description**: Creates a `state` object and returns a pointer to it.

**Arguments**: `filename` is the name of a "linked HALMAT" file (\*.yhla) for HALMAT emulators, or an AP-101 memory-image file (\*.fcm) for AP-101 emulators. `entryPoint` is the program counter at which execution should begin, and the same comments apply to it as in the `gpcStep` function above.

**Returns**: The pointer to the `state` object, or else NULL on if no object was created due to memory-allocation failure. Even if the returned pointer isn't `NULL`, there may still have been an error, so `readGpcState` should be used to check error codes.

### `int * svcGpc(void *state, int svcCode, uint16_t *parameters);`

**Description**: This is not so much a function provided by the library as it is a pointer to a callback function provided by the user that can be called when the emulator needs to emulate a `%SVC` call. It provides the means for the emulator to communicate with peripheral devices, among other facilities. `READ`, `WRITE`, and `FILE` are handled directly by the emulator, and are not handled via this callback. The library does provide several sample functions which can be used:

- `svcStub` &mdash; just an empty function.
- `svcVW` &mdash; a "virtual wire" interface, in which peripheral devices are connected to the GPC via networking.

The actual user-provided callback would more-likely be something that directly performed the action(s) desired. The callback would presumably access information in `state`, whose format the callback function does not know.  Howeve, the callback can use `readGpcState` and `writeGpcState` to perform the accesses.

**Arguments**: TBD

**Returns**: Returns 0 on success, 1 on failure. Use `readGpcState` to fetch the exact error code in the latter case.

