# yaGpcIntegration/Makefile -- builds both emulators' linkable libraries
# and CLI binaries by invoking each sibling repo's own build, then copies
# the results here. The point: an integrator (and this project's own
# write-ups of how to perform the integrations) only ever needs to deal
# with this one directory -- yaGpcIntegration.h, libyaGPC2.a/yaGPC2,
# libyaHALMAT2.a/yaHALMAT2, samples/ -- never yaGPC2/'s or yaHALMAT2/'s
# own individual build peculiarities.
#
# Assumes the usual sibling layout: yaGPC2/, yaHALMAT2/, and this
# directory all live directly under the same parent (yaShuttle/) --
# same assumption yaGPC2/Makefile's own -I../yaGpcIntegration already
# makes in the other direction.
#
# Usage:
#   make            # build+copy both emulators' libs/binaries, then samples
#   make libs       # just the libs/binaries, skip samples
#   make samples    # just samples/ (assumes libs are already here)
#   make test       # libs + samples, then run samples/paced_run against both
#   make clean      # remove copies here and samples/ binaries -- does NOT
#                    # clean either sibling repo's own build/ directory;
#                    # use `make -C ../yaGPC2 clean` etc. for that

YAGPC2_DIR    := ../yaGPC2
YAHALMAT2_DIR := ../yaHALMAT2/src

.PHONY: all libs yagpc2 yahalmat2 samples test clean

all: libs samples

libs: yagpc2 yahalmat2

# Each target invokes the sibling repo's own build (which already
# produces both the CLI binary and the linkable library -- see that
# repo's own Makefile for how), then copies just those two outputs here.
# Deliberately does not try to duplicate either repo's object list --
# that would be exactly the kind of separate-copy-to-keep-in-sync this
# whole directory exists to avoid.
yagpc2:
	$(MAKE) -C $(YAGPC2_DIR)
	cp $(YAGPC2_DIR)/libyaGPC2.a .
	cp $(YAGPC2_DIR)/yaGPC2 .

yahalmat2:
	$(MAKE) -C $(YAHALMAT2_DIR)
	cp $(YAHALMAT2_DIR)/libyaHALMAT2.a .
	cp $(YAHALMAT2_DIR)/yaHALMAT2 .

samples:
	$(MAKE) -C samples

# Integration-level smoke test: builds everything, then runs the shared
# sample against both libraries in turn -- the concrete, checkable proof
# that yaGpcIntegration.h + both libraries actually work together, not
# just that each repo's own (separate) test suite passes in isolation.
test: all
	./samples/paced_run yagpc2
	./samples/paced_run yahalmat2

clean:
	rm -f libyaGPC2.a yaGPC2 libyaHALMAT2.a yaHALMAT2
	$(MAKE) -C samples clean
