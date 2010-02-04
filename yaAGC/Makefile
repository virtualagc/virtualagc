# Copyright 2003-2005,2009 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:	Makefile
# Purpose:	Makefile for the AGC simulation,
# Mods:		04/05/03 RSB.	Began.
#		04/21/03 RSB.	Added libyaAGC.a.
#		05/09/04 RSB	Added CheckDec.
#		05/12/04 RSB	Added Backtrace.
#		05/14/04 RSB	Added PREFIX-related stuff.
#		05/30/04 RSB	Added the -Wall switch.
#		08/09/04 RSB	Incorporated nbfgets.
#		08/18/04 RSB	Added SocketAPI.
#				Added the embedded demo thing.
#		08/24/04 RSB	Added some provision for sdcc.  
#				... But foolishly did it before remembering
#				that the ROM requirements of the AGC already
#				overwhelm any 8-bit CPU.
#		04/30/05 RSB	Added CFLAGS
#		06/02/05 RSB	Fixed CFLAGS.
#		06/27/05 RSB	Added DecodeDigitalDownlink.
#		07/30/05 JMS	Added compiling of libreadline
#		08/04/05 RSB	Added the CURSES variable.
#		08/06/05 RSB	... removed it again, and added a path
#				where libcurses.a can be found on some systems.
#				(Sometimes it is in /usr/lib, sometimes in
#				/usr/lib/curses, maybe other places as well.
#		03/06/09 RSB	Added 'all-archs' target, and made other 
#				adjustments related to building for multiple
#				target architectures using IMCROSS.
#		03/08/09 RSB	Added WinAGC.exe
#		........ OH	... something ...
#		04/24/09 RSB	Removed regex.o from OBJECTS.  Redefined
#				CSOURCE, from OBJECTS.  Conditioned
#				use of -lcurses.  Added READLINE back into
#				Win32 and Mac targets.
#		04/25/09 RSB	Fixed up native-Mac builds.
#		05/03/09 RSB	Adjusted for SOLARIS.
#		08/01/09 RSB	Added NormalizeSourceName.o.  Disabling
#				readline support for Win32 because of 
#				bad Vista problems.  ... No, couldn't
#				get rid of it.  Adjusted to link
#				to libcurses, to try and use a newer version
#				of libreadline.
#		08/02/09 RSB	Added Alberto Galdo's iPhone mods.

LIBS=${LIBS2}

ifndef PREFIX
PREFIX=/usr/local
endif

.PHONY: default
default: yaAGC

#---------------------------------------------------------------------------
# The use of libreadline adds a command-history to yaAGC, but may have some
# other side effects.  It it turns out to be a problem, do this:
#	export NOREADLINE=yes
#	make
# instead of just 'make'. 

# Alberto Galdo's iPhone mod.
ifdef IPHONE
NOREADLINE = yes
endif

LIBS0:=${LIBS}
ifndef NOREADLINE
CURSESLIB=-lcurses
CFLAGS2 = -DUSE_READLINE
ifdef MACOSX
# This assumes that readline has been installed into the default (/usr/local)
# directory with
#	configure
#	make
#	sudo make install
CFLAGS2 += -I/usr/local/include
LIBS += /usr/local/lib/libreadline.a
else # MACOSX
#ifdef SOLARIS
#LIBS += /usr/local/lib/libreadline.a
#else # SOLARIS
#LIBS += -lreadline
#endif # SOLARIS
LIBS += -lreadline
endif # MACOSX
endif # NOREADLINE

CFLAGS2 += -DGDBMI

# Alberto Galdo's iPhone mod.
ifdef IPHONE
IPHONE_DEV=/Developer/Platforms/iPhoneOS.platform/Developer
CFLAGS2 += -isysroot ${IPHONE_DEV}/SDKs/iPhoneOS2.0.sdk/
CC=${IPHONE_DEV}/usr/bin/arm-apple-darwin9-gcc-4.0.1
LIBS=
endif # IPHONE

ifndef CC
CC=gcc
endif

# For now, disabling readline support for Win32, because it's messed up 
# really badly in Vista.
# ... Nope, can't do it.  It would destroy gdbmi.
ifdef ReadlineForWin32
CFLAGS2_WIN32=${CFLAGS2}
else
CFLAGS2_WIN32=-DGDBMI
endif

ifdef WIN32
CFLAGS2_NATIVE=${CFLAGS2_WIN32}
else
CFLAGS2_NATIVE=${CFLAGS2}
endif

ifeq "${USER}" "rburkey"
STATIC=-static
endif

OBJECTS := \
	main.o \
	agc_cli.o \
	agc_simulator.o \
	agc_debugger.o \
	agc_gdbmi.o \
	agc_disassembler.o \
	agc_help.o \
	nbfgets.o \
	agc_symtab.o \
	NormalizeSourceName.o

LIBOBJECTS := \
	agc_engine_init.o \
	agc_engine.o \
	agc_utilities.o \
	rfopen.o \
	Backtrace.o \
	SocketAPI.o \
	DecodeDigitalDownlink.o

ifeq "${EXT}" ".exe"
NATIVE_WINAGC=WinAGC.exe
CC_WINAGC=gcc
else
CC_WINAGC=i386-mingw32-gcc
endif

yaAGC:	$(OBJECTS) CheckDec.o libyaAGC.a ${NATIVE_WINAGC}
	${CC} ${CFLAGS} ${CFLAGS2_NATIVE} -o yaAGC ${OBJECTS} CheckDec.o \
	libyaAGC.a -L. ${STATIC} ${LIBS} -lpthread -lyaAGC -lm ${CURSES}

libyaAGC.a: ${LIBOBJECTS}
ifdef IPHONE
	${IPHONE_DEV}/usr/bin/ar -rc $@ $^
	${IPHONE_DEV}/usr/bin/ranlib $@
else
	ar -rc $@ $^
	ranlib $@
endif	
	touch ../yaDSKY/src/main.c
	touch ../yaDEDA/src/main.c

clean:
	-rm -f yaAGC libyaAGC.a *.o *~ *.bak *.elf *.o68 *.o8 *.rel *.exe *-macosx

install:	yaAGC
	cp yaAGC ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/yaAGC

CheckDec.o: ../Luminary131/CheckDec.c
	${CC} ${CFLAGS} ${CFLAGS2} -O0 -DNVER=${NVER} -DINSTALLDIR="\"${PREFIX}/bin\"" -c -o $@ $<

%.o:	%.c agc_engine.h
	${CC} ${CFLAGS} ${CFLAGS2} -DNVER=${NVER} -DINSTALLDIR="\"${PREFIX}/bin\"" -c -o $@ $<

#----------------------------------------------------------------------------------
# Building for multiple architectures, using IMCROSS. 

.PHONY: all-archs
all-archs: default yaAGC.exe WinAGC.exe yaAGC-macosx

#CSOURCE:=main.c agc_engine_init.c agc_engine.c agc_utilities.c rfopen.c \
#	 Backtrace.c SocketAPI.c DecodeDigitalDownlink.c ../Luminary131/CheckDec.c \
#	 nbfgets.c symbol_table.c
CSOURCE:=$(patsubst %.o,%.c,${OBJECTS} ${LIBOBJECTS}) ../Luminary131/CheckDec.c

yaAGC.exe: ${CSOURCE} random.c
	i386-mingw32-gcc \
		${CFLAGS} ${CFLAGS2_WIN32} -DNVER=${NVER} \
		 -DPTW32_STATIC_LIB -DPCRE_STATIC \
		`${HOME}/IMCROSS/i386-mingw32/bin/pcre-config --cflags-posix` \
		-o $@ $^ -L. ${LIBS} ${CURSESLIB} -lpthreadGC2-static -lm -lwsock32 \
		`${HOME}/IMCROSS/i386-mingw32/bin/pcre-config --libs-posix`

WinAGC.exe: WinAGC.c
	${CC_WINAGC} ${CFLAGS} ${CFLAGS2} -o $@ $^

MACDIR:=${HOME}/IMCROSS/mac
yaAGC-macosx: ${CSOURCE}
	powerpc-apple-darwin9-gcc -arch ppc -arch i386 \
		-I${MACDIR}/include \
		${CFLAGS} ${CFLAGS2} -DNVER=${NVER} \
		-o $@ $^ -L${MACDIR}/lib -L. ${LIBS} -lpthread -lm ${CURSESLIB}

#----------------------------------------------------------------------------------
# Embedded-firmware stuff for Coldfire is below this line.	
	
ECC = m68k-elf-gcc
EAR = m68k-elf-ar
EAS = m68k-elf-as
ELD = m68k-elf-ld
EOBJCOPY = m68k-elf-objcopy

# The following is a deduction of the directory in which libgcc.a
# can be found.  It determines the installation directory of 
# m68k-elf-gcc, and then massages it a little to get rid of some
# extraneous characters.
GREPPED:=$(shell ${ECC} -print-search-dirs | grep install)
LIBDIR:=$(subst install:,,$(GREPPED))m5200

EmbeddedAGC68.elf: crt.o68 EmbeddedDemo.o68 NullAPI.o68 random.o68 agc_engine.o68 
	${EOBJCOPY} --add-section .CoreRope=../yaCode/Luminary131/Luminary131.bin \
		--set-section-flags .CoreRope=contents,alloc,load,data \
		agc_engine.o68					
	${ELD} -T EmbeddedLinker.script -o $@ $^ -L${LIBDIR} -lgcc

%.o68: %.agc
	${EAS} -m5206 -o $*.o68 $*.agc

%.o68: %.c
	${ECC}  -c -m5200 -O2 -Wall -o $*.o68 $*.c	

#----------------------------------------------------------------------------------
# Embedded-firmware stuff for 8051 is below this line.	
	
CC8 = sdcc

EmbeddedAGC.ihx: EmbeddedDemo.rel agc_engine.rel random.rel NullAPI.rel
	$(CC8) -o $@ $^

%.rel: %.c
	${CC8}  -c --model-large -o $@ $<	


