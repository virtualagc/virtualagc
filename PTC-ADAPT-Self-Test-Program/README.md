# Introduction

The PTC ADAPT Self-Test Program is software for the Launch Vehicle Digital Computer (LVDC) which, along with the companion Launch Vehicle Data Adapter (LVDA), was used in Apollo's Saturn rockets.  The PTC ("Programmable Test Controller") was _ground-based_ equipment, so this particular software was not use onboard the rocket; i.e., it is presented as an example of software for the LVDC computer, and not as flight software.  The reason it is presented as LVDC software, is that the PTC contained a modified LVDC, and thus that is the CPU on which this software runs.  The nature of the modifications to the CPU relate to use of differing peripheral devices and to the migration of some facilities supported natively by the LVDC to peripheral devices in the PTC; examples include multiplication and division.  However, such modifications do not prevent the PTC software from being syntatically-correct LVDC software, nor do they prevent use of the LVDC assembler for PTC software.

The ADAPT ("Aerospace Data Adapter/Processor Tester") was equipment for evaluating the LVDA, thus the PTC ADAPT Self-Test Program illuminates the interaction between the LVDC and LVDA.

Additional documentation may be found on [the Virtual AGC Project main website's LVDC page](http://www.ibiblio.org/apollo/LVDC.html#PTC_ADAPT_Self-Test_Program), which links documents for the PTC and ADAPT.  In particular, there is [a zipfile of the scanned page images of the assembly listing for the PTC ADAPT Self-Test Program](http://www.ibiblio.org/apollo/ScansForConversion/PTC%20ADAPT%20Self-Test%20Program.zip). These scanned images are the basis for the transcribed source code.

# Files

- PTC-ADAPT-Self-Test-Program.tsv &mdash; this is a transcription of the program's octal listing, which begins at p. 221 of the scanned pages and proceeds to the end of the scans.  The octal listing is the assembled form of the PTC ADAPT Self-Test Program.  The modern LVDC assembler also creates its own octal listing, of course, but this transcribed octal listing can be read by the assembler and used as a cross-check to validate that the modern assembler's results compares with the original assembler's results.
- PTC-ADAPT-Self-Test-Program.lvdc &mdash; this is a transcription of the program's assembly-language source code.  It can be used as an input to the modern LVDC assembler.

# Assembly Using the Modern LVDC Assembler (yaASM.py)

TBD


