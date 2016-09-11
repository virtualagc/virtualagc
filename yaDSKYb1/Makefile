# Copyright:	Public Domain
# Filename:	Makefile
# Purpose:	Build my (Ron Burkey) DSKY sim for Block 1 AGC simulator.
# Reference:	http://www.ibiblio.org/apollo/Pultorak.html
# Mod history:	2016-09-04 RSB	Began
#
# Builds two separate programs, yaDSKYb1main and yaDSKYb1nav, because the
# DSKYs for the main control panel and the nav bay are so different in outward
# appearance.  Both programs are based on the same underlying source files
# yaDSKYb1.cpp and yaDSKYb1.h, but they superficial external appearances have
# two separate sets of files, yaDSKYb1main.{cpp,h} and yaDSKYb1nav.{cpp,h},
# generated from the separate wxGlade projects yaDSKYb1{main,nav}.wxg.

.PHONY: all
all:	yaDSKYb1main yaDSKYb1nav

yaDSKYb1main: yaDSKYb1main-widgetized.cpp yaDSKYb1main-widgetized.h yaDSKYb1.cpp yaDSKYb1.h Makefile
	g++ -DMAIN_DSKY_WIDGETIZED `wx-config --cxxflags` $< yaDSKYb1.cpp `wx-config --libs` -o $@

yaDSKYb1nav: yaDSKYb1nav-widgetized.cpp yaDSKYb1nav-widgetized.h yaDSKYb1.cpp yaDSKYb1.h Makefile
	g++ -DNAV_DSKY_WIDGETIZED `wx-config --cxxflags` $< yaDSKYb1.cpp `wx-config --libs` -o $@

.PHONY: clean
clean:
	-rm yaDSKYb1main yaDSKYb1nav

