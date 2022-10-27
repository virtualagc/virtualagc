# Contents

  * [Introduction](#Introduction)
  * [Target-Specific Differences](#Target)
  * [Stuck Bits, Parity-Based Fixes, and CCSHOLEs](#Stuck)
  * [Inventory of Dumped Rope-Memory Modules](#Inventory)

# <a name="Introduction">Introduction</a>

In general terms, to date, three methods of recovering Apollo Guidance Computer software have presented themselves to us:

 1. Transcription of source code from Apollo-era printouts.
 2. Readback ("dumps") of physical Apollo-era rope-memory modules containing executable forms of the software.
 3. Reconstruction of source code by simultaneous explotation of similar AGC software versions, application of source-code changes from the Apollo-era paper trail, and separately-obtained knowledge of the correct fixed-memory bank checksums.

The material in *this* folder pertains to the 2nd of these methods.  The folder contains all available dumps which have been made from individual physical AGC rope-memory modules.  Where feasible, and specifically where enough modules of compatible AGC software versions exist, source code has also been reconstructed for them as well.  But not in *this* folder.  Such reconstructions appear elsewhere in the source tree, in folders specific to particular AGC software versions.  

Several file formats are used in Virtual AGC for AGC rope images.  The dumps in this library folder are all "bin" files (as opposed to "binsource" files), in so-called "hardware with parity" format, with the specifics of the format varying somewhat according to the target hardware/softare: i.e., depending on whether the AGC is of type Block I, BLK, or Block II.

The filenames obey the following convention:

    PARTNUMBER-DASHNUMBER-TARGET-AGCSOFTWAREVERSION-MODULE[-NOTES].bin

For example, for file 1003133-20-Sunrise45+-B28-BadStrand7_BrokenCore167.bin,

  * The rope-module part number is 1003133.  The engineering drawing for this part number can be looked up in the Virtual AGC engineering-drawing search engine (if we happen to have a copy of the drawing).   In this case, [the drawing is here](https://archive.org/details/aperturecardbox437naraswimages/page/n414/mode/1up?view=theater).
  * The specific part number, including the dash number is 1003133-20, which the drawing just mentioned informs us in its part list is for module B28.  The drawing also tells us indirectly which AGC software version it relates to, namely "Computer Program Dwg No." 1021102, whose drawing we *don't* have, but which other resources in our document library tell is is Sunrise (version number uncertain without more digging).
  * The TARGET is the hardware/software model for which this software is targeted.  The possibilities are:
    * BlockI
    * BLK2
    * AGC.  (These targets are *all* AGCs, so try not to be confused by the fact this particular target is the only one actually *named* "AGC".)
  * In fact, this module is for AGC software version Sunrise 45, but it remained unchanged for later versions of Sunrise, which is why I've indicated it in the filename as "45+".
  * The module number &mdash; i.e., the AGC slot into which it is plugged &mdash; as I've already mentioned, is B28.
  * Finally, the optional NOTES field is generally present to indicate any hardware faults that were encountered during the dump which may render the dump less useful.  In this example, both "BadStrand7" and "BrokenCore167" are indicated, the former of which is repairable in software (but not yet repaired in this specific file), while the latter can hopefully be worked around (but again, has not been repaired in this specific file).

In general, for the convenience of the software used to transform and/or combine these module dumps into complete AGC executables, the use of commas and hyphens in the filenames (other than those indicated in the template filename pattern above) should be avoided.

# <a name="Target">Target-Specific Differences</a>

The principal target-related differences &mdash; i.e., Block I vs BLK2 vs Block II &mdash; between these dumps are these:

  * The number of 2000₈-word "banks" in each module.
  * The ordering of the banks within the modules.
  * The total number of modules.
  * The naming of the modules.

For Block I target: There are up to 6 rope-memory modules per AGC, with 4 fixed-memory banks per module.  The modules are used in pairs, designated as pair R (modules B28 and B29), pair S (modules B21 and B22), and pair T (modules B23 and B24).  The fixed-memory banks are arranged within the dumped files in the following order.  Notice that the numbering begins at bank 01, and that there are no fixed-memory banks numbered 00, 15, 16, 17, or 20.

  * B21 &mdash; 10, 05, 30, 25
  * B22 &mdash; 06, 07, 26, 27
  * B23 &mdash; 14, 11, 34, 31
  * B24 &mdash; 12, 13, 32, 33
  * B28 &mdash; 04, 01, 24, 21
  * B29 &mdash; 02, 03, 22, 23

For BLK2 or AGC targets:  There are up to 6 rope-memory modules per AGC, with 6 fixed-memory banks per module.  The modules are designated B1 through B6.  The fixed-memory banks are arranged within the dumped files in the following order:

  * B1 &mdash; 00, 01, 02, 03, 04, 05
  * B2 &mdash; 06, 07, 10, 11, 12, 13
  * B3 &mdash; 14, 15, 16, 17, 20, 21
  * B4 &mdash; 22, 23, 24, 25, 26, 27
  * B5 &mdash; 30, 31, 32, 33, 34, 35
  * B6 &mdash; 36, 37, 40, 41, 42, 43

# <a name="Stuck">Stuck Bits, Parity-Based Fixes, and CCSHOLEs</a>

## The Simplified Explanation

Dumps from physical rope-memory modules do not always contain immediately-usable data, because it sometimes happens that the modules being dumped are defective in some way.  The most-commonly-encountered problem turns out to have a relatively-easy fix, and since this problem and its fix will be referred to several times later, I'll discuss them in a general way now to avoid repetition.

Note first that each location in fixed memory holds a data word consisting of 15 bits, plus one extra bit, called the "parity bit", for 16 in all.  The parity bit doesn't contain data as such, but provides a way of partially checking whether the 15 bits of actual data are correct.

The "common problem" that I mentioned is a so-called *stuck bit*.  That means that some particular one of the 15 bits, say bit 3 as an example, always is read as a 1 regardless of which address is being queried.  Normally that wouldn't happen, and you'd expect bit 3 to vary between 0 and 1, depending on the address.  We would say that bit 3 is stuck.

Because of the nature of parity bits, this problem is easily repaired by software, as long as only *one* of the data lines is stuck in any particular region of memory.  If more than one data line is stuck in the same range of memory addresses, then correction becomes much harder, and is not always possible.  However, that's outside of the scope of our discussion.

In the case of the AGC, parity bits are *odd*.  This refers to the way they are calculated.  If you express a 15-bit word in binary notation (i.e., 0's and 1's), the parity bit will have been chosen so that an odd number of bits is 1.  For example, suppose the word stored at address 05,3456 is 12345 in octal notation.  In binary,

    001 010 011 100 101

That's 7 bits which are 1.  That's already an odd number, so the parity bit is chosen to be a 0.  But if the word stored at 05,3456 had been 12344 instead, or

    001 010 011 100 100

that's 6 bits which are 1, an even number, so the parity bit would have to be 1.

The way this is applied to correcting a stuck bit is simple:  In all of the words dumped from the module (in the address range for which a stuck bit is causing a problem), simply replace bit 3 (the one we're pretending is stuck) by 0.  Having done that, in each word count the number of bits (including the parity) which are 1.  If the number is even, change bit 3 to a 1.  Stuck-bit problem solved!

The drawback of this fix is that the parity bit can now no longer be used for cross-checking the correctness.  However, you can't have everything!

## Down the Rabit Hole

As usual with AGC-related matters, it's actually a bit harder and more-complex than the simplified picture painted above suggests.

Perhaps the biggest complicating factor is the problem of "unused" locations in fixed memory.  These are locations where there is no code and no constant data stored.  As you might expect, when the fixed-memory at an unused location is read, it returns the value 00000 (octal).  But the complication is that these unused locations have a parity bit of 0 as well, so these locations have *even parity* in place of the odd parity of all of the used data locations as described above.

So if you simple-mindedly correct all of the data in a stuck-bit memory region by fiddling with the stuck bits to make the parities odd, you will in fact be assigning wrong values to all of the unused memory locations!  In the preceding section, I used as an example the case in which bit 3 is stuck, so if you "corrected" an unused memory location which *should* be

    000 000 000 000 000, parity=0

you'd end up with

    000 000 000 000 100, parity=1

Well, so what?  After all, if there's no code or data stored at an unused location, then what difference does its value make?  A wrong value at that location can't affect the behavior of the software when it's executed, can it?

Unfortunately, yes.  Recall that AGC software is protected by checksums that are computed during the built-in self test.  (This isn't literally true, since early software like Block I's Sunrise or BLK2's Retread didn't have them, but it's true for all later software, and certainly for any software flown in missions or used for system checkout.)  A checksum, in essence, is a sum of all of the words in a fixed-memory bank, *including* the unused locations, so if the unused locations are assigned incorrect values, the checksums will be wrong, and the software is unlikely to pass its built-in self-test, even though executing correctly in every other way!

Most unused words in fixed memory are in a big bunch at the very ends of the memory banks, so finding those is pretty easy:  You can simply scan backward from the ends of the banks.  Admittedly, there's some ambiguity, because it's certainly possible that the very last "used" word in a bank may coincidentally have the same value (except for parity) as an unused location.

Besides which, cases have been seen in which not all "stuck" bits are actually stuck, but mere *mostly* so, so that some of them may intermittently read correctly.  I'm told this is due to fact that the electronics for reading back a strand of memory involves a pair of matched diodes, which after 50 or 60 years of inactivity are no longer quite so matched as they were back in the Apollo era. 

Then too, not *all* unused words are at the ends of the banks, and finding those requires effort ... not to mention experience and knowledge of similar software versions (if any) that is outside of the scope of this discussion.  

Nevertheless, the main example of this kind of thing of which I've been told is what you might call a *CCSHOLE*.  To understand a CCSHOLE, you have to understand the nature of the AGC's `CCS` instruction.  In schematic form, here's the way a `CCS` instruction works:

    ...
    CCS             x
    Instruction1            # Come here if x > 0
    Instruction2            # Come here if x == +0
    Instruction3            # Come here if x < 0
    Instruction4            # Come here if x == -0
    ...

Now, if you knew in advance that the variable `x` was constrained in certain ways, you might know that some of these instructions, say `Instruction3`, could never be reached.  But you have to tell the assembler *something* to do with that address.  There are several things you might do, such as putting a no-op instruction (`NOOP`, `CA A`, etc.) there.  Some software versions literally put an instruction `TC CCSHOLE` there, hence the name CCSHOLE!  Solarium 55 does the latter, for example, and the subroutine `CCSHOLE` is coded as a trap that raises a program alarm signaling an implementation error.

But if you were really concerned about saving memory, you might reason as follows:  If you couldn't ever reach the address at which `Instruction3` resided, why not just make it an unused memory location?  That would have the advantage of *possibly* (but not very likely) being able to omit an entire ferrite core from the rope assembly, thus saving a tiny amount of weight and cost.  This is an example of what today might be called "premature optimization", which some have referred to as "the root of all evil" ... and which indeed does do us some evil in this context of stuck bits and parity fixes!  Perhaps the coders for early versions of AGC software did feel like conserving that extra ferrite core was worth it, so they did indeed code them as unused word sometimes. 

# <a name="Inventory">Inventory of Dumped Rope-Memory Modules</a>

Unless otherwise stated, all dumps of physical rope-memory modules were performed by Mike Stewart. Two methods were used.  One involved [the AGC from the collection of Jimmie Loocke, restored in 2019](http://www.ibiblio.org/apollo/Restoration.html), at which point (as far as I know) it became the only functional AGC then in existence.  The method was to insert available rope-memory modules into this AGC, when compatible, and to exploit the AGC to dump their contents.  Eventually the restored AGC was no longer available for this purpose, and Mike designed and constructed dedicated rope-memory module reader devices which he could use for dumping additional modules as they became available.



## 1003133-18-BlockI-Sunrise33+-B29.bin

Source:  An anonymous collector.

Software:  Sunrise 33, 38, 45, 69

Flaws:  None known.

## 1003133-19-BlockI-Sunrise38+-B21.bin

Source:  An anonymous collector.

Software:  Sunrise 38, 45, 69

Flaws:  None known.

## 1003133-20-BlockI-Sunrise45+-B28-BadStrand7_BrokenCore167.bin

Source:  An anonymous collector.

Software:  Sunrise 45, 69

Flaws:

  * Bad Strand 7 (Stuck Bit 7, last quarter of banks 21 and 24):  As described earlier, stuck bits can be corrected with a parity-based fix.  The parity-based fix has not been applied in this raw dump, however.
  * Broken Core 167:  The physical construction of a fixed-memory core rope involves the fact that whether or not data is read as a 0 or a 1 from a specific core depends on whether the wire for reading the data is threaded through the core (which is shaped like a tiny doughnut) or else passes around it.  64 wires are used for any given core &mdash; limited by the thickness of the wire and the size of the hole &mdash; so a broken core affects many locations at similar addresses but perhaps different memory banks.  In the case of core 167, data from the following addresses is lost and the indicated software sections are probably affected:
      * 04,6167: EXECUTIVE
      * 04,6567: PROGRESS CONTROL
      * 04,7167: FRESH START
      * 04,7567: Unwired, so no data loss
      * 24,6167: PINBALL
      * 24,6567: PINBALL
      * 24,7167: PINBALL
      * 24,7567: PINBALL (this location is also affected by the bad bit 7).

## 1003733-071-BlockI-Sunrise69-B22-BadBit2.bin, 1003733-071-BlockI-Sunrise69-B22-Repaired.bin

Source:  An anonymous collector.

Software:  Sunrise 69

Flaws:  

  * Stuck Bit 2:  The raw dump had this flaw.  A parity fix was applied, and the repaired dump is without known flaws.  Both the flawed raw dump and the repaired dump are provided here.

*Postscript*:  Some time after the module was dumped and repaired, a *second* 1003733-071 module (also belonging to an anonymous collector) was located and dumped, this time flawlessly.  The latter dump was found to be identical, bit-by-bit, to the repaired dump.  This is as we would expect, but it's welcome corroboration of the validity of the method.  Since it's identical to the repaired file, however, I've elected not to provide it as a separate file.

## 2003053-031-BLK2-Retread50-B1-BadBits.bin, 2003053-031-BLK2-Retread50-B1-Repaired.bin

Source:  Computer History Museum, Mountain View, California.

Software:  Retread 50

Flaws:

  * Bad Bit 14:  In the raw dump, in the first half of bank 00, bit 14 was stuck HIGH.  
  * Bad Bit 3:  In the raw dump, in the first half of bank 04, bit 3 was usually (but not always) stuck HIGH. 

A more-exact way of describing the problem is that strands 1 and 9 were bad.  As described earlier, stuck bits can be repaired by a parity-based fix.  For illustrative purposes, library contains both the raw version with its flaws and the repaired version.

## 2003053-041-BLK2-Retread50-B2.bin

Source:  Computer History Museum, Mountain View, California.

Software:  Retread 50

Flaws:  None known.

## 2003053-061-BLK2-Aurora85+-B1.bin

Source:  Anonymous collector

Software:  Aurora 85, 88

Flaws:  None known.

## 2003053-071-BLK2-Aurora85-B2.bin

Source:  Anonymous collector

Software:  Aurora 85

Flaws:  None known.

## 2003053-121-BLK2-SundialB+-B1.bin

Source:  MIT Museum

Software:  Sundial B, D, E

Flaws:  None known.

## 2003053-131-BLK2-SundialB-B2.bin

Source:  Anonymous collector

Software:  Sundial B

Flaws:  None known.

## 2003053-151-BLK2-SundialE-B2.bin

Source:  MIT Museum

Software:  Sundial E

Flaws:  None known.

## 2003053-181-BLK2-Aurora88-B3.bin

Source:  Anonymous collector

Software:  Aurora 88

Flaws:  None known.

## 2003972-211-BLK2-SundialE-B3.bin

Source:  MIT Museum

Software:  Sundial E

Flaws:  None known.

## 2003972-371-AGC-Sundance292-B1.bin

Source:  Anonymous collector

Software:  Sundance 292

Flaws:  None known.

## 2003972-391-AGC-Sundance292-B3.bin

Source:  Anonymous collector

Software:  Sundance 292

Flaws:  None known.

## 2003972-421-AGC-Sundance292-B5.bin

Source:  Anonymous collector

Software:  Sundance 292

Flaws:  None known

## 2003972-451-AGC-Sundance302-B2.bin

Source:  Don Eyles

Software:  Sundance 302

Flaws:  None known

## 2003972-461-AGC-Sundance302-B3.bin

Source:  Don Eyles

Software:  Sundance 302

Flaws:  None known

## 2003972-471-AGC-Sundance302-B4.bin

Source:  Eldon Hall

Software:  Sundance 302

Flaws:  None known

## 2003972-641-AGC-Sundance306-B6.bin

Source:  Anonymous collector

Software:  Sundance 306

Flaws:  None known

## 2010802-021-AGC-Comanche72-B2.bin

Source:  Anonymous collector

Software:  Comanche 72

Flaws:  None known

## 2010802-171-AGC-LM131rev1-B5.bin

Source:  Anonymous collector

Software:  LM131rev1

Flaws:  None known

