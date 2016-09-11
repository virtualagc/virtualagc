# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build my (Ron Burkey) DSKY sim for Block 1 AGC simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-09-04 RSB	Began
#
# Builds two separate programs, yaDSKYb1main and yaDSKYb1nav, because the
# DSKYs for the main control panel and the nav bay are so different in outward
# appearance.  Both programs are based on the same underlying source files
# yaDSKYb1.cpp and yaDSKYb1.h, but their superficial external appearances have
# two separate sets of files, yaDSKYb1main.{cpp,h} and yaDSKYb1nav.{cpp,h},
# generated from the separate wxGlade projects yaDSKYb1{main,nav}.wxg.  However,
# the .cpp and .h files have been modified quite a lot from how they were originally
# generated using the .wxg file, so it wouldn't be a good idea to regenerate the
# code in wxGlade again.

EXTRASOURCE=yaDSKYb1.cpp SocketAPI.cpp agc_utilities.cpp
EXTRAHEADERS=yaDSKYb1.h

.PHONY: all
all:	yaDSKYb1main

yaDSKYb1main: yaDSKYb1main-widgetized.cpp yaDSKYb1main-widgetized.h ${EXTRASOURCE} ${EXTRAHEADERS} Makefile
	g++ -DMAIN_DSKY_WIDGETIZED `wx-config --cxxflags` $< ${EXTRASOURCE} `wx-config --libs` -o $@

yaDSKYb1nav: yaDSKYb1nav-widgetized.cpp yaDSKYb1nav-widgetized.h ${EXTRASOURCE} ${EXTRAHEADERS} Makefile
	g++ -DNAV_DSKY_WIDGETIZED `wx-config --cxxflags` $< ${EXTRASOURCE} `wx-config --libs` -o $@

.PHONY: clean
clean:
	-rm yaDSKYb1main yaDSKYb1nav

