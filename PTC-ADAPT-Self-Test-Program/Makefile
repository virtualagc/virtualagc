# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for PTC ADAPT Self Test Program LVDC code.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2023-06-01 RSB	Created.
#
# Note: yaASM.py (the LVDC assembler) must be somewhere in your PATH.  In the
# Virtual AGC source-code tree, it is found at yaASM.py/yaASM.py.

BASENAME=PTC-ADAPT-Self-Test-Program

SOURCES=$(wildcard PTC-ADAPT-Self-Test-Program.lvdc*)

.PHONY: all
all: yaASM.tsv

.PHONY: clean
clean:
	-rm temp.tmp yaASM.tsv yaASM.src yaASM.sym ${BASENAME}.lst

temp.tmp: ${SOURCES}
	cat $^ >temp.tmp

yaASM.tsv: temp.tmp
	yaASM.py --ptc ${BASENAME}.tsv <temp.tmp >${BASENAME}.lst
	@grep --after-context=6 "Assembly[-]message summary" ${BASENAME}.lst

.PHONY: lean
lean: 	clean temp.tmp
	yaASM.py --html --ptc ${BASENAME}.tsv <temp.tmp >${BASENAME}.lst
	@grep --after-context=6 "Assembly[-]message summary" ${BASENAME}.lst
		