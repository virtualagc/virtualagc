# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build John Pultorak's Block 1 simulator
#		with GNU g++.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-08-29 RSB	Began

TARGETS:=yaAGC-Block1
SOURCE:=$(wildcard *.cpp)
HEADERS:=$(wildcard *.h)

.PHONY: all
.PHONY: clean

all: yaAGC-Block1

yaAGC-Block1: $(SOURCE) $(HEADERS) Makefile
	g++ -O0 -g -o $@ $(SOURCE) -lncurses

clean:
	-rm $(TARGETS)

