# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build John Pultorak's Block 1 simulator
#		with GNU g++.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-08-29 RSB	Began
#		2016-09-03 RSB	Replaced ncurses by a pthreads-based
#				approach.

TARGETS:=yaAGC-Block1
SOURCE:=$(wildcard *.cpp)
HEADERS:=$(wildcard *.h)

.PHONY: all
.PHONY: default
.PHONY: clean

LIBS = 
ifdef WIN32
LIBS = "-L/usr/lib"
endif
LIBS += -lncurses -lpthread


all default: yaAGC-Block1

# Note that actually only one of -lncurses or -lpthread is
# needed, depending on whether or not the constant USE_NCURSES
# is #defined.
yaAGC-Block1: $(SOURCE) $(HEADERS) Makefile
	g++ -O0 -g -o $@ $(SOURCE) $(LIBS)

clean:
	-rm $(TARGETS)

