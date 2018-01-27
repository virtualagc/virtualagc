# Copyright:	Public domain.
# Filename:		Makefile
# Purpose:		Makefile for Yul.
# Contact:		Jim Lawton <jim.lawton@gmail.com>
# Website:		http://www.ibiblio.org/apollo
# Mod history:	2016-10-06 JL	Created.

BASENAME=YUL

# This is highly optimistic, as we will need a Honeywell H800/H1800
# cross-assembler, and a H800/H1800 simulator in order to run YUL
# (assuming we get it transcribed correctly)...

H800=$(HOME)/agc/h800

ALL_SOURCE:=$(wildcard *.argus)

# Top-level modules, these include everything else.
# Omit DIGEST.argus and OPGUIDE.argus, since they do not seem to be valid
# sources, i.e. they are purely comment text, but not marked as remarks cards.
SOURCES:=YULPASS0.argus YULPASS1.argus YULPASS2.argus YULPASS3.argus # YULMANUF.argus YULSIMUL.argus

default: instrcheck symcheck

clean:
	@rm -f *.symtab *.symerr

symcheck:
	@echo "Checking for bad symbols..."
	python $(H800)/tools/check-symbols.py $(SOURCES)

symtab:
	@echo "Generating symbol table..."
	python $(H800)/tools/list-symbols.py $(SOURCES) >YUL.symtab

instrcheck:
	@echo "Checking instructions..."
	python $(H800)/tools/check-instructions.py -i $(SOURCES)

instrcount:
	@echo "Counting instructions..."
	python $(H800)/tools/check-instructions.py -c -s -u $(SOURCES)

parse:
	@echo "Parsing..."
	python $(H800)/tools/parse.py YULPASS0.argus
	#python $(H800)/tools/list-symbols.py YULPASS2.argus >YULPASS1.symtab
	#python $(H800)/tools/list-symbols.py YULPASS2.argus >YULPASS2.symtab
	#python $(H800)/tools/list-symbols.py YULPASS3.argus >YULPASS3.symtab
	#python $(H800)/tools/list-symbols.py YULMANUF.argus >YULMANUF.symtab
	#python $(H800)/tools/list-symbols.py YULSIMUL.argus >YULSIMUL.symtab

