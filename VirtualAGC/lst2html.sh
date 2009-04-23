#!/bin/bash
# Filename:	lst2html.sh
# Mods:		20090316 RSB	Wrote.
# This is a short script to convert a ASCII program listing to an HTML
# file.  Eventually it would be neat (forgive the strong language!) to
# have syntax highlighting, but for now it's just a simple-minded 
# HTML wrapper around the original contents.

# USAGE:
#	lst2html InputFile OutputFile

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' >$2
echo '<html><head><meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">' >>$2
echo '<title>AGC/AEA Assembly Listing</title></head><body>' >>$2
echo '<span style="font-family: monospace;"><PRE>' >>$2
expand $1 >>$2
echo '</PRE></span></body></html>' >> $2

