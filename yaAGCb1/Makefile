# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build my (Ron Burkey) Block 1 AGC simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-09-03 RSB	Began
#		2016-11-18 RSB	Explicitly include socket library in Solaris.
#		2017-08-22 RSB	Correct path to yaYUL, which apparently reflected
#				my original setup, in which yaAGCb1 was separate
#				from virtualagc, rather than appearing under it.
#				The path worked okay, but only as long as the
#				top-level directory was named "virtualagc".

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
	${cc} ${CFLAGS0} -O0 -g -o $@ $(SOURCE) -lpthread $(LIBS)

test.agc.bin: test.agc
	../yaYUL/yaYUL --block1 $^ >test.agc.lst
	touch test.agc.pad

clean:
	-rm $(TARGETS) test.agc.lst test.agc.pad*

