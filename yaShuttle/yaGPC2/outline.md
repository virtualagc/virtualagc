The task is to create an emulator for the AP-101S CPU, otherwise known as the GPC. The emulator program will be called "yaGPC2" (note the capitalization), and will be written in the C language. Present already in this directory is the source code for just such a program, called "yaGPC". You will need to modify the Makefile (and NMakefile) files, to change the name from yaGPC to yaGPC2. After that, the source code will need to be modified in a number of ways, which I will explain.

First, some background info:

- The desire is to run software provided in the form of source code written in the HAL/S language. There are two possible methods for doing so. The HAL/S compiler transforms HAL/S source code into a byte-code language known as HALMAT for internal purposes, and then transforms HALMAT into AP-101S object code. HAL/S software can thus be run either using a HALMAT emulator or else an AP-101S emulator.
- We already have a working HALMAT emulator, namely a program called "yaHALMAT2", created by a Claude agent in the directory /home/rburkey/git/virtualagc/yaShuttle/yaHALMAT2.
- As mentioned, we also already have a working AP-101S emulator, namely a program called yaGPC, created by a Claude agent that ported a Javascript program called "gpc", or more specifically a particular mode of that program "gpc run", to C. The directory in which that agent _originally_ operated was /home/rburkey/git/yaGPC/; it is possible, however unlikely, that that directory might contain useful information which has been stripped as being irrelevant from the present directory. The yaGPC program faithfully reproduces the behavior of "gpc run", _including its bugs_.
- At this time, "git run" has known bugs, and since yaGPC (now copied to yaGPC2) faithfully reproduces "git run" behavior, those bugs in yaGPC2 need to be corrected.
- yaHALMAT2 is also likely to have bugs or omissions, but none are presently known. yaHALMAT2 is believed to be less buggy than yaGPC2 is at present.

Our immediate goal is threefold:

1. For all bugs and omissions to be corrected in yaGPC2.
2. For yaGPC2 to accept yaHALMAT2-like command-line options to the extent feasible.
3. For yaGPC2 and yaHALMAT2 to produce byte-identical outputs given the same starting HAL/S code, using compatible command-line options.

In other words, we would like yaGPC2 and yaHALMAT2 to be both _correct_ and _essentially interchangeable_ in their ability to run HAL/S software.

Bugs in yaHALMAT2 will likely be uncovered in the process of doing this, at which point we will need to discuss how to handle those.

There will be additional development goals for both yaGPC2 and yaHALMAT2 after the two programs have achieved parity, but those need not concern us now.

Here are some of the resources you have to work with, although additional resources may also become available upon request:

- The file tools.md describes the HAL/S development toolchain (compiler, assembler, linker) available for you to use, as well as documentation sources which have proven to be helpful. Additional tools were used in developing yaHALMAT2, and are mentioned in yaHALMAT2 documentation.
- The file problems.md describes known (or believed) existing bugs in yaGPC (now copied to yaGPC2).
- The file sweep_raw_results.txt provides actual output from testing that revealed the problems listed in problems.md.


