# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build my (Ron Burkey) Block 1 AGC simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-09-03 RSB	Began

TARGETS:=yaAGCb1
SOURCE:=$(wildcard *.c)
HEADERS:=$(wildcard *.h)

.PHONY: all
.PHONY: clean

all: ${TARGETS}

${TARGETS}: $(SOURCE) $(HEADERS) Makefile
	gcc -O0 -g -o $@ $(SOURCE) -lpthread

clean:
	-rm $(TARGETS)

