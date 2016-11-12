# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for AGC Block 1 validation suite.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2016-09-15 RSB	Adapted from the Block 2 Validation suite.

SSOURCE:=$(wildcard *.agc)
# Try to find yaYUL.  I want the location of yaYUL to be flexible because I'm 
# initially building this from a different branch of the repo (with a different
# directory name), which will eventually be merged back into the
# main branch.  Admittedly, the former case relies on my own individual
# choice of directory naming.
ifneq ("$(wildcard ../yaYUL/yaYUL)", "")
yaYUL=../yaYUL/yaYUL
else
yaYUL=../../virtualagc/yaYUL/yaYUL
endif

.PHONY:		default
.PHONY:		all
default all:	Validation-Block1.bin

Validation-Block1.bin:	${SSOURCE}
	${yaYUL} --block1 --html Validation.agc >Validation-Block1.lst
	mv Validation.agc.bin Validation-Block1.bin
	#mv Validation.agc.symtab Validation-Block1.symtab

corediff.txt: Validation.bin
	@echo "No corediff for Validation!" 

clean:
	-rm -f Validation-Block1.bin Validation-Block1.lst Validation.agc.bin *~ *.symtab *.html
