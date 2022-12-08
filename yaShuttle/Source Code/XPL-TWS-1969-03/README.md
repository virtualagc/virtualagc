This folder contains source code comprising the so-called XPL Translator Writing System (TWS), which is the basis for the original HAL/S-FC compiler, which itself was used to compile the HAL/S language source code for the Space Shuttle's Primary Flight Software (PFS) and Backup Flight Software (BFS).

This folder is believed to pretty-faithfully represent the source code from the Appendices of the book *A Compiler Generator* (1970) by McKeeman, Horning, and Wortman.  This source code was not taken from that book, however, but was derived from files recovered from a shared tape (as described by the file README.txt) and made available online at http://www.cs.toronto.edu/XPL/.  The source code is presented *here* in machine-readable form only because it is quite cumbersome to use in harcopy form, in which it requires >200 printed pages; but I still recommend that you buy the book if you want to explore this code.

Regarding the versioning, March 1969 is the latest date I've seen in any of the program comments in the included files, so I've arbitrarily assigned this software a version code of 1969-03.

The files presented in this folder have been altered by the Virtual AGC Project from those presented at the link above as follows:

1. Executable code (for IBM System/360 computers) has been removed.
2. Filename extensions have been added or changed to reflect the type of file:  ".txt" for text files, ".xpl" for XPL files, and ".bal" for IBM OS/360 Basic Assembly Language.
3. Files have been converted from EBCDIC to 7-bit ASCII encoding.
4. Files containing fixed-length (80-column) records without line breaks have had newlines inserted after every 80 characters.

The Virtual AGC Project does not claim that this software is in the public domain; merely that it comes from an era in which academic software was expected to be freely shared, and that the explanations provided by the authors (see PROSE.txt) and in the header of the XCOM.xpl program make it clear that the software was indeed expected to be shared.  The restorer of the tape (Peter Flass), who had the assistance of two of the three authors of the book and its software, stated in the README.txt file that the software was believed to be in the public domain.

However, if you are the registered copyright owner of this software and wish to complain about its inclusion here, contact the Virtual AGC Project (www.ibiblio.org/apollo) and request its removal.
