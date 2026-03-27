In this folder, we have various contemporary source-code files 
related to Space Shuttle software  that have been unsystematically 
collected as opposed to being part of any semi-official release of
some kind.  I've filled in my own inferences, in the descriptions
below,
such as adding filename extensions (".xpl" for XPL/I, ".for" for 
Fortran, ".jcl", ".clist") and explanations of functionality, but you have to take
such details with a grain of salt.

Here's a synopsis:

- LM.for, MLIST.for, MRF.for, MRFBOTH.for, MSIDS.for, MXREF.for, 
OCONFIG.for, SDFTOOL.for, XREFS1.for, COMMBLK.for, UTILITY.for, SDFTOOL.jcl: These 
appear to be members of an interrelated series of Fortran programs (with
COMMBLK.for consisting of COMMON-block declarations and UTILITY.for
consisting of utility subroutines used by all of 
them) that somehow analyze SDFs (produced by HAL/S-FC pass 3).
I think SDFTOOL.for may be the gateway into the others, and that 
SDFTOOL.jcl may build the whole stack.
- DODSTOT.clist: Perhaps a list of PASS and BFS releases, and related
stuff, for dumping the whole collection onto tape.
- HALSTAT.xpl, XPLCOMP.jcl: HALSTAT 8.1 is sort of a general-purpose tool to report
on the characteristics of an already-compiled HAL/S program. It is 
specific to PASS compilations as opposed to BFS compilations, for
which there was a different tool.  Over 
time, HALSTAT's spinoff program, MAFGEN (which we don't have), took over the role of performing
detailed deep-dives into the code (such as disassemblies), while HALSTAT concentrated more
on higher-level issues like a Global Cross-Reference of all HAL/S 
symbols (variables, compilation units, functions, procedures, etc.), 
together with 'top-level' memory maps.  Although HALSTAT is an XPL/I program,
and therefore in principle compilable by our XCOM-I XPL/I 
compiler and runnable today, its utility is limited (as of this 
writing), because it takes input partially from the so-called SDF
files produced by pass 3 of the HAL/S compiler (HAL/S-FC).  But 
passes 3 and 4 have not yet been ported into the modern world.  XPLCOMP.jcl, I think, may be for
compiling HALSTAT from its XPL/I source code and then running it.
- LOCATE.bal, NDX2PTR.bal, OLDSDF.bal, PAGMOD.bal, REGRESS.bal, 
SDFCHECK.bal, SDFOUT.bal, SELECT.bal, TEST1.bal:  These are alternate versions of the source-code
files of the same names in the folder PASS.REL32V0/SDFPKG.ASM/.
(Except that SDFOUT.bal/OLDSDF.bal instead correspond to PASS.REL32V0/MONITOR.ASM/SDFOUT.bal,
while REGRESS.bal is a completely new file.)
My guess is that they are part of an engineering version of SDFPKG.

