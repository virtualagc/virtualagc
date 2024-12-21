# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build John Pultorak's Block 1 simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-08-29 RSB	Began
#		2016-09-03 RSB	Replaced ncurses by a pthreads-based
#				approach.
#		2018-08-24 RSB	Added -lstdc++ for clang.

TARGETS:=yaAGC-Block1
SOURCE:=$(wildcard *.cpp)
HEADERS:=$(wildcard *.h)

.PHONY: all
.PHONY: default
.PHONY: clean

LIBS = 
ifdef WIN32
LIBS = -L$(MINGW_PREFIX)/lib
endif
LIBS += -lncurses


all default: yaAGC-Block1

# Note that actually only one of -lncurses or -lpthread is
# needed, depending on whether or not the constant USE_NCURSES
# is #defined.
yaAGC-Block1: $(SOURCE) $(HEADERS) Makefile
	${CC} -pthread -O0 -g -o $@ $(SOURCE) $(LIBS) -lstdc++

clean:
	-rm $(TARGETS)

