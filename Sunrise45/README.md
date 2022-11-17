# About the Sunrise 45 Executable Program

Sunrise 45 is a Block I AGC program, of which we have very few in our library, and is (at this writing) the *earliest* AGC software available to us.

The file Sunrise45.bin contains data dumped from physical fixed-memory modules offered to us by an anonymous collector.  Source code for Sunrise 45 will hopefully become available eventually, via reconstruction from related programs and disassembly, but presently we only have the executable form of the program, in the form of this core dump.

The entire program is made up of dumps from 3 separate memory modules, concatenated to form a complete rope.  The dumps of the individual modules are all available in the Rope-Module Dump Library folder of the Virtual AGC source tree, and specifically are the files

* 1003133-20-BlockI-Sunrise45+-B28-Repaired.bin
* 1003133-18-BlockI-Sunrise33+-B29.bin
* 1003133-19-BlockI-Sunrise38+-B21.bin

The details of the "repairs" that module B28 needed are written up in the Rope-Module Dump Library's README.md file.  It is conceivable, though I believe quite unlikely, that some of the repairs may be inadequate and that it may require additional modifications in the future.

If you happen to be running a Unix-style operating system like Linux or Mac OS X, the complete rope for execution on an emulated Block I AGC via the emulation program **yaAGCb1** was created as follows:

    cat ... the 3 files in the order listed above ... > Sunrise45-hardware.bin
    blk1_hard_to_vagc.py Sunrise45-hardware.bin
    mv Sunrise45-hardware_vagc.bin Sunrise45.bin

In Windows, I *presume* &mdash; but don't vouch for it! &mdash; that the equivalent steps would

    copy /B ... the 3 files, separated by '+' signs ... Sunrise45-hardware.bin
    blk1_hard_to_vagc.py Sunrise45-hardware.bin
    ren Sunrise45-hardware_vagc.bin Sunrise45.bin

By the way, you'll find the **blk1_hard_to_vagc.py** program in the Tools/disassemblerAGC/ folder of the source tree. The final file mentioned above, Sunrise45.bin, is the rope image required by **yaAGCb1**.  The purpose of the **blk1_hard_to_vagc.py** program is to convert the dumps from a format we call the "hardware" format to the format instead produced by our modern AGC assemblers and accepted by our modern AGC CPU emulators.  The Python programming language is required; specifically Python 3, but Python 2 could be used if the first line of the program is changed appropriately.

Of course, you don't actually need to *do* this yourself, since the file Sunrise45.bin is already present; but that's how it's done if you need to do it.

