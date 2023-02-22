# About these Sunrise 45 Files

Sunrise 45 is a Block I AGC program, of which we have very few in our library, and is (at this writing) the *earliest* non-trivial AGC software available to us.

The file Sunrise45-dump.bin contains data dumped from physical fixed-memory modules offered to us by an anonymous collector, and then later cross-checked vs another dump from a module owned by Larry McGlynn.  The source code was later reconstructed by Mike Stewart with the assistance of Nik Beug; it assembles identically to the dumped octal data from the physical core-rope memory modules, but program comments and names of variables, constants, program labels, and so on, are necessarily suspect.

The entire program is made up of dumps initially made from 3 separate memory modules, concatenated to form a complete rope.  The dumps of the individual modules are all available in the Rope-Module Dump Library folder of the Virtual AGC source tree, and specifically are the files

* 1003133-20-BlockI-Sunrise45+-B28-Repaired.bin
* 1003133-18-BlockI-Sunrise33+-B29.bin
* 1003133-19-BlockI-Sunrise38+-B21.bin

The details of the "repairs" that module B28 needed are written up in the Rope-Module Dump Library's README.md file.  Of those, the only questionable repairs, as mentioned above, have been cross-checked and proven correct vs yet another but later dump, this time contained in the file

* 1003733-021-BlockI-Sunrise45+-B28-BadStrand6Parity.bin

*Nota bene*:  If you happen to be running a Unix-style operating system like Linux or Mac OS X, the complete rope for execution on an emulated Block I AGC via the emulation program **yaAGCb1** was created as follows:

    cat ... the first 3 files in the order listed above ... > Sunrise45-hardware.bin
    blk1_hard_to_vagc.py Sunrise45-hardware.bin
    mv Sunrise45-hardware_vagc.bin Sunrise45-dump.bin

In Windows, I *presume* &mdash; but don't vouch for it! &mdash; that the equivalent steps would

    copy /B ... the first 3 files, separated by '+' signs ... Sunrise45-hardware.bin
    blk1_hard_to_vagc.py Sunrise45-hardware.bin
    ren Sunrise45-hardware_vagc.bin Sunrise45-dump.bin

By the way, you'll find the **blk1_hard_to_vagc.py** program in the Tools/disassemblerAGC/ folder of the source tree. The final file mentioned above, Sunrise45-dump.bin, is the rope image required by **yaAGCb1**.  The purpose of the **blk1_hard_to_vagc.py** program is to convert the dumps from a format we call the "hardware" format to the format instead produced by our modern AGC assemblers and accepted by our modern AGC CPU emulators.  The Python programming language is required; specifically Python 3, but Python 2 could be used if the first line of the program is changed appropriately.

Of course, you don't actually need to *do* this yourself, since the file Sunrise45-dump.bin is already present; but that's how it's done if you're curious about the matter.

