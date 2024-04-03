# Licensing:	Declared by the author (Ronald Burkey) to be Public Domain
#		in the U.S., and can be freely distributed or modified in 
#		any desired way whatsoever.
# Filename:	Makefile
# Purpose:	For building C-language source-code output from the XCOM-I.py
#		XPL/I-to-C translator program.  This Makefile does *not* build 
#		XCOM-I itself.
# Requirements: The GNU `gcc` C compiler and GNU `make` program are assumed, 
#		but probably all or lots of others would work as well. 
# Reference:	https://www.ibiblio.org/apollo/Shuttle.html
# Contact:	info@sandroid.org
# Mod history:	2024-03-30 RSB	Wrote
#
# To make this as simple and cross-platform as possible, the compiled 
# program is always called `aout`.  But of course you can rename it to 
# anything you like.

TARGET = aout
CC = gcc
# Comment out the following line in "production".
DEBUG = -ggdb

SOURCES = $(wildcard *.c)
HEADERS = $(wildcard *.h)

$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(DEBUG) -o $@ $(SOURCES)
