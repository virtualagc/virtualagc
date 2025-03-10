# Declared to be in the Public Domain by its author, Ronald S. Burkey.
# 
# Filename:	Makefile
# Purpose:	Builds "modern" HAL/S compiler front-end.
# Requires:	BNF Converter (https://bnfc.digitalgrammars.com/)
# Mods:		2022-12-11 RSB	Adapted from the Makefile autogenerated by
#				BNF Converter from the HAL_S.cf grammar.
#		2023-02-16 RSB	Adapted for line/column numbers in AST.

APP = modernHAL-S-FC

# See if we can build a .exe.
# For Windows 32:
#CC2 = i686-w64-mingw32-gcc
# For Windows 64:
CC2 = x86_64-w64-mingw32-gcc
STRIP2 = x86_64-w64-mingw32-strip
ifeq "" "$(shell which $(CC2))"
  APP2 = 
else
  APP2 = ${APP}.exe
endif

CC = gcc
STRIP = strip
CCFLAGS = -O3
BISON_OPTS = -t -pHAL_S

CFILES = Absyn.c Parser.c Lexer.c Printer.c
HFILES = Absyn.h Parser.h Printer.h

# Just for me
INSTALLATION = ~/Desktop/sandroid.org/public_html/apollo/Shuttle

.PHONY : clean distclean

all : DemoHAL_S ${APP} ${APP2} yaHAL-S-FC.zip

counterexamples :
	-rm temp/Parser.c
	make -C temp BISON_OPTS=-Wcounterexamples Parser.c 

clean :
	rm -f ${APP} ${APP}.o ${APP2}
	if [ -d temp ] ; then rm temp/* -rf; fi
	-make -C temp clean

distclean : clean
	-rm DemoHAL_S
	-rm temp -rf

# BNFC 2.9.x (through x=5) don't work.  2.8.3 does work.
DemoHAL_S ${CFILES} ${HFILES} : HAL_S.cf fixPrinter.c
	if [ ! -d temp ] ; then mkdir temp ; fi
	cd temp && bnfc --c -l -m ../HAL_S.cf
	make -C temp CCFLAGS="${CCFLAGS}" BISON_OPTS="${BISON_OPTS}"
	mv temp/TestHAL_S DemoHAL_S
	cp temp/Printer.h .
	cp temp/Absyn.h .
	cp temp/Parser.h .
	cp temp/Absyn.c .
	cp temp/Lexer.c .
	cp temp/Parser.c .
	cp temp/HAL_S.y .
	cat fixPrinter2.c temp/Printer.c | \
	sed 's/bufAppendS("/bufAppendSp(p, "/g' | \
	sed -e '1h;2,$$H;$$!d;g' -re \
		's/void\s+bufAppendC\s*\([^)]*\)\s*\{/void bufAppendC(const char c)\n{\n\#include "fixPrinter.c"\n/' \
		>Printer.c
	bnfc --latex HAL_S.cf
	sed --in-place -e 's@HAL_S@HAL/S@g' \
		-e 's@literals are recognized by the regular expression@=@' \
		-e 's@The Language HAL/S@Preprocessed HAL/S@' \
		-e 's@\\documentclass\[a4paper,11pt\][{]article[}]@\\documentclass[10pt]{article}\n\\usepackage[letterpaper, margin=1in]{geometry}@' \
		 HAL_S.tex
	-pdflatex HAL_S.tex
	-mv HAL_S.pdf "HAL-S BNF.pdf"

${APP} : modernHAL-S-FC.c ${CFILES} ${HFILES}
	${CC} ${CCFLAGS} -o $@ modernHAL-S-FC.c ${CFILES}
	-${STRIP} $@

${APP}.exe: modernHAL-S-FC.c ${CFILES} ${HFILES}
	${CC2} ${CCFLAGS} -o $@ modernHAL-S-FC.c ${CFILES}
	-${STRIP2} $@

# Here's a target for Mac.  Beware!  It produces an executable if you have
# clang installed, but the executable it produces is only going to work on
# a Mac if you've compiled on a Mac.
modernHAL-S-FC-macosx: modernHAL-S-FC.c ${CFILES} ${HFILES}
	clang ${CCFLAGS} -o $@ modernHAL-S-FC.c ${CFILES}
	strip $@
	
# Make a zipfile for distributing just the preprocess+compiler executables and source.
yaHAL-S-FC.zip: 
	zip -j $@ *.c *.h *.py modernHAL* *.cf *.y *.pdf README.txt Makefile ../"Source Code"/"Programming in HAL-S"/*.hal
	-cp $@ ${INSTALLATION}
	