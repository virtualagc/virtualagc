# Copyright 2003-2005 Ronald S. Burkey <info@sandroid.org>
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

ifndef PREFIX
PREFIX=/usr/local
endif

#---------------------------------------------------------------------------
# The use of libreadline adds a command-history to yaAGC, but may have some
# other side effects.  It it turns out to be a problem, do this:
#	export NOREADLINE=yes
#	make
# instead of just 'make'.
ifndef NOREADLINE
CFLAGS2 = -DUSE_READLINE
LIBS += -L/sw/lib -lreadline
LIBS += -L/usr/lib/curses -lcurses
endif	# NOREADLINE

yaAGC:	main.o libyaAGC.a CheckDec.o nbfgets.o symbol_table.o
	gcc ${CFLAGS} -o yaAGC $^ -L. ${LIBS} -lpthread -lyaAGC -lm

libyaAGC.a: agc_engine_init.o agc_engine.o agc_utilities.o agc_gdbmi.o agc_help.o \
	rfopen.o Backtrace.o SocketAPI.o DecodeDigitalDownlink.o
	ar -rc $@ $^
	ranlib $@
	touch ../yaDSKY/src/main.c
	touch ../yaDEDA/src/main.c

clean:
	-rm yaAGC libyaAGC.a *.o *~ *.bak *.elf *.o68 *.o8 *.rel

install:	yaAGC
	cp yaAGC ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/yaAGC

CheckDec.o: ../Luminary131/CheckDec.c
	gcc ${CFLAGS} -ggdb -O0 -DNVER=${NVER} -DINSTALLDIR="\"${PREFIX}/bin\"" -c -o $@ $<

%.o:	%.c agc_engine.h
	gcc -ggdb -I/sw/include ${CFLAGS} ${CFLAGS2} -DGDBMI -DNVER=${NVER} -DINSTALLDIR="\"${PREFIX}/bin\"" -c -o $@ $<

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
	${EOBJCOPY} --add-section .CoreRope=../Luminary131/Luminary131.bin \
		--set-section-flags .CoreRope=contents,alloc,load,data \
		agc_engine.o68					
	${ELD} -T EmbeddedLinker.script -o $@ $^ -L${LIBDIR} -lgcc

%.o68: %.s
	${EAS} -m5206 -o $*.o68 $*.s 

%.o68: %.c
	${ECC}  -c -m5200 -O2 -Wall -o $*.o68 $*.c	

#----------------------------------------------------------------------------------
# Embedded-firmware stuff for 8051 is below this line.	
	
CC8 = sdcc

EmbeddedAGC.ihx: EmbeddedDemo.rel agc_engine.rel random.rel NullAPI.rel
	$(CC8) -o $@ $^

%.rel: %.c
	${CC8}  -c --model-large -o $@ $<	


