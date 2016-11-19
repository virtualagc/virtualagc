# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build my (Ron Burkey) Block 1 AGC simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-09-03 RSB	Began
#		2016-11-18 RSB	Explicitly include socket library in Solaris.

TARGETS:=yaAGCb1 test.agc.bin
SOURCE:=$(wildcard *.c)
HEADERS:=$(wildcard *.h)

ifdef SOLARIS
LIBS += -lxnet
endif # SOLARIS

ifdef WIN32
LIBS += -lwsock32
endif

.PHONY: all
.PHONY: default
.PHONY: clean

all default: ${TARGETS}

yaAGCb1: $(SOURCE) $(HEADERS) Makefile
	gcc -O0 -g -o $@ $(SOURCE) -lpthread $(LIBS)

test.agc.bin: test.agc
	../../virtualagc/yaYUL/yaYUL --block1 $^ >test.agc.lst
	touch test.agc.pad

clean:
	-rm $(TARGETS) test.agc.lst test.agc.pad*

