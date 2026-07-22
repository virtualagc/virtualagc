This directory follows [Zane Hambly's lead from his "Halmat" repository in GitHub](https://github.com/Zaneham/Halmat), using essentially the same approach, but leveraging an A.I. coding agent &mdash; specifically ANTHROP\C Claude Sonnet 5 &mdash; to follow up leads in much more obsessive detail, hoping thereby to reach a higher completion level ... or at least, to reach that level a little sooner.

Specifically, two things are accomplished:

- Regeneration of documentation about the HALMAT "intermediate language" used by the HAL/S compiler, to compensate for the fact that the surviving documentation is either superseded or else incomplete, and only about 20% of it can be trusted as-is.
- A HALMAT emulator supporting <i>all</i> features of the HAL/S language supported by the original Intermetric system.

The newly-generated top-level HALMAT documentation [can be found here](reengineered-documentation/HALMAT.md).  Other files potentially of interest are those giving [the maintenance plan used by Claude](Maintenance.md), [the initial development plan used by Claude](Plan.md) and [the status of the development](reengineered-documentation/STATUS.md).

The source code for that new HALMAT emulator, **yaHALMAT2**, can be found in the src/ directory.  To build it, just `cd` into that directory and do `make clean all`.  The directory src/tests/ contains test code consisting of HAL/S source code and shell scripts.  Note that the shell scripts are for Linux, and (for all I know) may work as-is on Mac OS, but are definitly not suitable for Windows. 

Other than this README, all files in this directory were created by Claude Code, under direction.  Because the development plan is preserved, my intention would be for all future development such as feature additions or bug fixes in this directory to continue to be performed by Claude, under direction.

