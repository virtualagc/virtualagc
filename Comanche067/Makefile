# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 067.
#		The original release of the software for the Command Module's
#		(CM) Apollo Guidance Computer (AGC) for Apollo 12. I'm thinking
#		of trying to reconstruct it from a listing of Comanche 055 and 
#		NASA drawing 2021153D.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2020-12-25 RSB	Adapted from Mike's Comanche 044 Makefile.
#		2021-01-05 RSB	Changed to use preprocessor.
#		2021-01-07 RSB	Restored the original non-gpp build whenever
#				ReconstructionLevel is not defined.  The 
#				gpp build occurs only with ReconstructionLevel.
#		2021-02-12 RSB	Have reached the point in reconstruction where
#				there are bank overflows (bank 37) that I just
#				can't get rid of immediately, and will have to
#				let persist for a while.  Under those 
#				circumstances, no banksum diffs were generated
#				for checking, so I've modified this makefile
#				to get around that and always generate the diffs,
#				as long as either Comanche067.bin *or* MAIN.agc.bin
#				exists, in spite of assembly failure.  However, 
#				it requires a special command-line construct:
#					make || make diffComanche067sums

# To build as before, using the .agc files that are already in the folder, just
# use the same 'make' CLI syntax as before.  To use the with the preprocessor,
# the ReconstructionLevel constant must be defined.  Further instructions follow.
#
# Here are the basic ideas behind using the preprocessor for the reconstruction
# process:
#
#   1.	The source files are now in the folder gpp/.  They are AGC source files, 
#	but can contain preprocessor directives, and have the extension .gpp
#	instead of .agc.
#   2.	When the build is performed, each of the .gpp files is processed by 
#	the preprocessor (gpp), turning it into a .agc file.  Since .agc files
#	may be overwritten with every build, do not make changes directly in them.
#	You must have 'gpp' installed.
#   3.  There are many preprocessor features, but the only preprocessor directives
#	I envisage using are #ifdef, #else, #endif, #if, #define, and defined().
#   4.  Each of the reconstruction steps identified in the github issue
#	(https://github.com/virtualagc/virtualagc/issues/1140#issuecomment-751502877)
#	has an associated preprocessor macro (Reconstruction1, Reconstruction2, ...) 
#	which are used with #ifdef to enclose the reconstructed code.  Like so:
#		#ifdef Reconstruction5
#		... reconstructed Comanche 67 code and annotations ...
#		#else
#		... the original Comanche 55 code ...
#		#endif
#	Therefore, if all of Reconstruction1, .... , are #define'd, then the
#	the build uses all of the reconstruction steps.  If none of them are 
#	#define'd, then the original Comanche 55 code is built.
#   5.  There is a convenience file (gpp/defines.default) which can be used to 
#	define a single preprocessor macro name for any particular combination of
#	reconstruction steps you're fond of using.  For example, names I've
#	defined so far are:
#		PreferredReconstruction		All ReconstructionN steps
#		NoReconstruction		None of the ReconstructionN steps 
#						(i.e., Comanche 55)
#		ReconstructThrough3		Just Reconstruction1, 2, and 3.
#   6.  The 'make' command-line syntax is
#		ReconstructionLevel=NAME make clean default
#	where NAME is one of the catch-all names just described above.
#	The default is PreferredReconstruction.
#	This automatically runs the preprocessor, then builts the preprocessed
#	.agc files normally.
#   7.	AN IMPORTANT TRICK: If there's an assembly error, and in *particular* if there's
#	a memory-bank overflow, 'make' will not generate the banksum diffs if run as
#	shown above, but it will generate all of the files needed for the diffs.  The
#	trick is to run
#		ReconstructionLevel=NAME make [TARGETS] || make diffComanche067sums
#   8.	ANOTHER IMPORTANT TRICK: If you change the ReconstructionLevel you've been
#	using (for example, changing from ReconstructionLevel=PreferredReconstruction
#	to ReconstructionLevel=NoReconstruction), then 'make' doesn't know to 
#	re-preprocess the files.  You have to do
#		touch gpp/defines.default
#	to trick it into doing so.
#   9.  Annotations now just read
#		## <b>Reconstruction:</b> ...
#	rather than things like
#		## <b>Reconstruction 5:</b> ...
#   10.	When the reconstruction is eventually complete, we'll comment out the
#	final stuff in this file.  That will prevent the 
#	preprocessor from operating in the future, and therefore freeze the
#	.agc files at that point in time.

BASENAME=Comanche067

NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche067sums
EXTRA_YAYUL_ARGS=--reconstruction --force

include ../Makefile.inc

.NOTPARALLEL:
.PHONY: diffComanche067sums
diffComanche067sums: 
	if test -f MAIN.agc.bin ; then mv MAIN.agc.bin Comanche067.bin ; fi
	../Tools/check_buggers.py --listing=MAIN.agc.lst Comanche067.bin Comanche067.buggers

ifdef ReconstructionLevel

%.agc : gpp/%.gpp gpp/defines.default Makefile
	gpp -D$(ReconstructionLevel) -Igpp --include defines.default gpp/$*.gpp >$*.agc

endif
	