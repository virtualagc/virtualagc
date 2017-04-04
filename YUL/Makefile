# Copyright:	Public domain.
# Filename:		Makefile
# Purpose:		Makefile for Yul.
# Contact:		Jim Lawton <jim.lawton@gmail.com>
# Website:		http://www.ibiblio.org/apollo
# Mod history:	2016-10-06 JL	Created.

BASENAME=YUL

# This is highly optimistic, as we will need a Burroughs B800/B1800
# cross-assembler, and a B800/B1800 simulator in order to run YUL
# (assuming we get it transcribed correctly)...

H800=$(HOME)/agc/h800

ALL_SOURCE:=$(wildcard *.argus)

# Top-level modules, these include everything else.
# Omit DIGEST.argus and OPGUIDE.argus, since they do not seem to be valid
# sources, i.e. they are purely comment text, but not marked as remarks cards.
SOURCE:=YULPASS0.argus YULPASS1.argus YULPASS2.argus YULPASS3.argus YULMANUF.argus YULSIMUL.argus

check:
	for toplevel in $(SOURCE) ; do \
		echo $$toplevel ; \
		python $(H800)/tools/check-instructions.py -i $$toplevel ; \
	done

