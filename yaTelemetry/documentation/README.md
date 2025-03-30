This folder contains HTML files used by the yaTelemetry program to
display documentation for the downlinked data in the so-called 
downlists that yaTelemetry displays.  These downlinked data items
differ in name and format (e.g., octal vs floating point, single
precision vs double precision, etc.) according to the particular
AGC program transmitting them.

These HTML files are paired (in content but _not_ filename) with 
so-called TSV files ddd-ID-AGCSOFTWARE.tsv found in the ../yaAGC
folder.

yaTelemetry supports only LGC or Block II CMC data, and only those
particular AGC software versions using the later downlist format
as opposed to the earlier format used in Block I, which I believe
means all flown missions from Apollo 7 onward, and none earlier than 
Apollo 7.  I believe that the distinct HTML files (and TSV files,
though named differently) needed are found in the following folders:

* Apollo 7: Sundisk (unavailable)
* Apollo 8: Colossus1
* Apollo 9: Colossus1, Sundance
* Apollo 10: Colossus2, Luminary1
* Apollo 11: Colossus2, Luminary1A
* Apollo 12: Colossus2, Luminary1B (may be identical to Luminary 1C)
* Apollo 13: Colossus2, Luminary1C
* Apollo 14: Colossus2, Luminary1D (Luminary 163 is a minor variant)
* Apollo 15-17: Colossus3, Luminary1E
* Skylab 2-4, ASTP: Skylark1

Some other cases, like Zerlina may be included separately.
