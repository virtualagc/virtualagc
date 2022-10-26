# Introduction

In general terms, to date, three methods of recovering Apollo Guidance Computer software have presented themselves to us:

 1. Transcription of source code from Apollo-era printouts.
 2. Readback ("dumps") of physical Apollo-era rope-memory modules containing executable forms of the software.
 3. Reconstruction of source code by simultaneous explotation of similar AGC software versions, application of source-code changes from the Apollo-era paper trail, and separately-obtained knowledge of the correct fixed-memory bank checksums.

The material in *this* folder pertains to the 2nd of these methods.  The folder contains all available dumps which have been made from individual physical AGC rope-memory modules.  Where feasible, and specifically where enough modules of compatible AGC software versions exist, source code has also been reconstructed for them as well.  But not in *this* folder.  Such reconstructions appear elsewhere in the source tree, in folders specific to particular AGC software versions.  

Several file formats are used in Virtual AGC for AGC rope images.  The dumps in this library folder are all "bin" files (as opposed to "binsource" files), in so-called "hardware with parity" format, with the specifics of the format varying somewhat according to the target hardware/softare: i.e., depending on whether the AGC is of type Block I, BLK, or Block II.

The filenames obey the following convention:

    PARTNUMBER-DASHNUMBER-TARGET-AGCSOFTWAREVERSION-MODULE[-NOTES].bin

For example, for file 1003133-20-Sunrise45+-B28-BadStrand7_BrokenCore167.bin,

  * The rope-module part number is 1003133.  The engineering drawing for this part number can be looked up in the Virtual AGC engineering-drawing search engine (if we happen to have a copy of the drawing).   In this case, [the drawing is here](https://archive.org/details/aperturecardbox437naraswimages/page/n418/mode/1up?view=theater), *et seq*.
  * The specific part number is 1003133-20, which the drawing just mentioned informs us in its part list is for module B28.  Alas, the drawing does not inform us which AGC software version it relates to.
  * The TARGET is the hardware/software model for which this software is targetted.  The possibilities are:
    * BlockI
    * BLK2
    * BlockII
  * In fact, this module is for AGC software version Sunrise 45, but it remained unchanged for later versions of Sunrise, which is why I've indicated it in the filename as "45+".
  * The module number &mdash; i.e., the AGC slot into which it is plugged &mdash; as I've already mentioned, is B28.
  * Finally, the optional NOTES field is generally present to indicate any hardware faults that were encountered during the dump which may render the dump less useful.  In this example, both "BadStrand7" and "BrokenCore167" are indicated, the former of which is repairable in software (but not yet repaired in this specific file), while the latter can hopefully be worked around (but again, has not been repaired in this specific file).

In general, for the convenience of the software used to transform and/or combine these module dumps into complete AGC executables, the use of commas and hyphens in the filenames (other than those indicated in the template filename pattern above) should be avoided.

# Target-Specific Differences

The principal target-related differences &mdash; i.e., Block I vs BLK2 vs Block II &mdash; between these dumps are these:

  * The number of 2000₈-word "banks" in each module.
  * The ordering of the banks within the modules.
  * The total number of modules.
  * The naming of the modules.

For Block I: There are up to 6 rope-memory modules per AGC, with 4 fixed-memory banks per module.  The modules are used in pairs, designated as pair R (modules B28 and B29), pair S (modules B21 and B22), and pair T (modules B23 and B24).  The fixed-memory banks are arranged within the dumped files in the following order.  Notice that the numbering begins at bank 01, and that there are no fixed-memory banks numbered 00, 15, 16, 17, or 20.

  * B21 &mdash; 10, 05, 30, 25
  * B22 &mdash; 06, 07, 26, 27
  * B23 &mdash; 14, 11, 34, 31
  * B24 &mdash; 12, 13, 32, 33
  * B28 &mdash; 04, 01, 24, 21
  * B29 &mdash; 02, 03, 22, 23

For BLK2:  There are up to 4 rope-memory modules per AGC, with 6 fixed-memory banks per module.  The modules are designated B1 through B4.  The fixed-memory banks are arranged within the dumped files in the following order:

  * B1 &mdash; 00, 01, 02, 03, 04, 05
  * B2 &mdash; 06, 07, 10, 11, 12, 13
  * B3 &mdash; 14, 15, 16, 17, 20, 21
  * B4 &mdash; 22, 23, 24, 25, 26, 27

For Block II:  There are up to 6 rope-memory modules per AGC, with 6 fixed-memory banks per module.  The modules are designated B1 through B6.  The fixed-memory banks are arranged within the dumped files in the following order:

  * B1 &mdash; 00, 01, 02, 03, 04, 05
  * B2 &mdash; 06, 07, 10, 11, 12, 13
  * B3 &mdash; 14, 15, 16, 17, 20, 21
  * B4 &mdash; 22, 23, 24, 25, 26, 27
  * B5 &mdash; 30, 31, 32, 33, 34, 35
  * B6 &mdash; 36, 37, 40, 41, 42, 43

# Inventory

Unless otherwise stated, all dumps of physical rope-memory modules were performed by Mike Stewart. Two methods were used.  One involved the AGC from the collection of Jimmy Loocke, restored in 2019, at which point (as far as I know) it became the only functional AGC then in existence.  The method was to insert available rope-memory modules into this AGC, when compatible, and to exploit the AGC to dump their contents.  Eventually the restored AGC was no longer available for this purpose, and Mike designed and constructed dedicated rope-memory module reader devices which he could use for dumping additional modules as they became available.

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

  * Bad Bit 7:  This means that one of the 16 wires (15 data + 1 parity) or its associated circuitry used to read data from the module is bad.  However, the parity bit provides redundancy allowing us to regenerate the missing bit 7, at the unfortunate cost of losing its value for detecting error.  The data has not been corrected in this specific file, however.
  * Broken Core 167:  The physical construction of a fixed-memory core rope involves the fact that whether or not data is read as a 0 or a 1 from a specific core depends on whether the wire for reading the data is threaded through the core (which is shaped like a tiny doughnut) or else passes around it.  64 wires are used for any given core &mdash; limited by the thickness of the wire and the size of the hole &mdash; so a broken core affects many locations at similar addresses but perhaps different memory banks.  In the case of core 167, data from the following addresses is lost and the indicated software sections are probably affected:
      * 04,6167: EXECUTIVE
      * 04,6567: PROGRESS CONTROL
      * 04,7167: FRESH START
      * 04,7567: Unwired, so no data loss
      * 24,6167: PINBALL
      * 24,6567: PINBALL
      * 24,7167: PINBALL
      * 24,7567: PINBALL (this location is also affected by the bad bit 7).

## 1003733-071-BlockI-Sunrise69-B22-Repaired.bin

Source:  An anonymous collector.

Software:  Sunrise 69

Flaws:  

  * Bad Bit 2:  In the raw dump, bit 2 was dead in all banks.  However, due to the existence of parity bit for each data word in fixed memory, the missing databit can be regenerated, at the cost of no longer being able to use the parity bit as an indication of correctness.  That repair of bit 2 has been made in this file.

## 2003053-031-BLK2-Retread50-B1.bin

Source:  Computer History Museum, Mountain View, California.

Software:  Retread 50

Flaws:

  * Bad Bit 14:  In the raw dump, in the first half of bank 00, bit 14 was stuck HIGH.  This condition is correctable via the parity bit, at the cost of losing the ability to use the parity bit as an indicator of correctness the first half of bank 00.
  * Bad Bit 3:  In the raw dump, in the first half of bank 04, bit 3 was usually (but not always)  stuck HIGH.  This condition is correctable via the parity bit, at the cost of losing the ability to use the parity bit as an indicator of correctness in the first half of bank 04.

Both of the fixes just mentioned have been made within this file.

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

## 2003053-121-BLK2-SundialE-B1.bin

Source:  MIT Museum

Software:  Sundial E

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

## 2003972-371-BlockII-Sundance292-B1.bin

Source:  Anonymous collector

Software:  Sundance 292

Flaws:  None known.

## 2003972-391-BlockII-Sundance292-B3.bin

Source:  Anonymous collector

Software:  Sundance 292

Flaws:  None known.

## 2003972-421-BlockII-Sundance292-B5.bin

Source:  Anonymous collector

Software:  Sundance 292

Flaws:  None known

## 2003972-451-BlockII-Sundance302-B2.bin

Source:  Don Eyles

Software:  Sundance 302

Flaws:  None known

## 2003972-461-BlockII-Sundance302-B3.bin

Source:  Don Eyles

Software:  Sundance 302

Flaws:  None known

## 2003972-471-BlockII-Sundance302-B4.bin

Source:  Eldon Hall

Software:  Sundance 302

Flaws:  None known

## 2003972-641-BlockII-Sundance306-B6.bin

Source:  Anonymous collector

Software:  Sundance 306

Flaws:  None known

## 2010802-021-BlockII-Comanche72-B2.bin

Source:  Anonymous collector

Software:  Comanche 72

Flaws:  None known

## 2010802-171-BlockII-LM131rev1-B5.bin

Source:  Anonymous collector

Software:  LM131rev1

Flaws:  None known

