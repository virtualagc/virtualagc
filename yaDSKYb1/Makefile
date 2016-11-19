# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build my (Ron Burkey) DSKY sim for Block 1 AGC simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-09-04 RSB	Began

EXTRASOURCE=yaDSKYb1.cpp SocketAPI.cpp agc_utilities.cpp
EXTRAHEADERS=yaDSKYb1.h

ifdef SOLARIS
NLIBS = -lxnet
endif # SOLARIS
ifdef WIN32
NLIBS = -lwsock32
endif

.PHONY: all 
.PHONY: default
all default:	yaDSKYb1

yaDSKYb1: yaDSKYb1-widgetized.cpp yaDSKYb1-widgetized.h ${EXTRASOURCE} ${EXTRAHEADERS} Makefile
	g++ -g -O0 -DMAIN_DSKY_WIDGETIZED `wx-config --cxxflags` \
		$< ${EXTRASOURCE} `wx-config --libs` -o $@ $(NLIBS)

.PHONY: clean
clean:
	-rm yaDSKYb1

