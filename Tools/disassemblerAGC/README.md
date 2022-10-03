**Important note:**  This is *experimental* code that's under initial development.  It presently does only a portion of the job it's intended for.

# Introduction

This is an attempt to create a disassembler for octal dumps of AGC core ropes, facilitating recreation of their original source code.  As such, I hope it will be a tool for a very limited purpose, and not really a general-purpose utility.

Disassembly is envisaged as having the following stages:

  * Rough disassembly into numerical form.  In other words, all "basic" and "interpreter" instructions identified correctly, but their operands being numerical in nature.
  * Symbol assignments.
  * Final regeneration with program comments.

None of these steps can be accomplished perfectly if performed automatically, for a variety of reasons, so the best case is simply to reduce the amount of manual intervention needed to a minimum.  Of course, there is no guarantee of perfect accuracy in the final two steps even if there is human intervention, though errors in these steps do not affect the accuracy of core ropes assembled from the reconstructed AGC source code.

# Program: disassemblerAGC.py

This is the program which attempts to perform the rough disassembly, in which basic and interpretive instructions are correct, but their arguments are represented only numerically.

The program is partitioned into a number of modules from which it imports functionality, including

  * disassembleBasic.py &mdash; disassemble a single basic (i.e., assembly language) memory word.
  * disassembleInterpretive.py &mdash; disassemble a memory word containing 1 or 2 packed interpreter instructions, plus all of the memory words containing the arguments for those instructions.
  * engineering.py &mdash; some debugging code used only for initial development.
  * parseCommandLine.py &mdash; parse disassemblerAGC.py's command-line arguments.
  * readCoreRope.py &mdash; read a core rope into memory.  Accepts .binsource files and .bin files (either original format or "hardware" format).
  * searchSpecial.py &mdash; perform pattern matching to find the locations of certain infrastructure subroutines in the core rope, such as INTPRET, BANKCALL, FINDVAC, and so on.
  * semulate.py &mdash; does as much CPU emulation as is possible at assembly time, to track changes to memory-bank selection registers.

However, among these only the top-level program (`disassemblerAGC.py`) is directly executable, and it is the only file (in Linux or Mac OS) which has its executable permission-bit set.

The command

    disassemblerAGC.py --help

provides a list of the options.

Additionally, there are test files with names of the form *.spec which can be used with diassemblerAGC.py's --spec command-line switch.

# Program: TBD

TBD