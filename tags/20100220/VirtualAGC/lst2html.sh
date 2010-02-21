#!/bin/bash
# Filename:	lst2html.sh
# Mods:		20090316 RSB	Wrote.
#		20090603 RSB	Added Onno's mods for syntax highlighting.  I used Onno's
#				generic AGC+AEA solution rather than his AGC-specific and
#				AEA-specific solutions, out of sheer laziness, though there
#				may be some advantages to doing it this way too.  I'll
#				fix it later if need be.  I assume that the .js and .css
#				files are duplicated in every source directory, which is
#				certainly unnecessary, but I do it to make it easier for
#				someone who wants to save the html/js/css for standalone
#				use, since it prevents having to create a funky directory
#				structure.  Again, I may change this later, but the 
#				amount of space needed for the .css and .js files is
#				trivial compared to the HTML and symbol tables.
#				*Later* ... disabled by default.  For me, it sometimes 
#				(usually) is causing freeze-ups or crashes in Konqueror and
#				Firefox.  We'll revisit it later.
# This is a short script to convert a ASCII program listing to an HTML
# file.  Eventually it would be neat (forgive the strong language!) to
# have syntax highlighting, but for now it's just a simple-minded 
# HTML wrapper around the original contents.

# USAGE:
#	lst2html InputFile OutputFile [anything]
# If "anything" (or anything else, for that matter) is present, then it is assumed
# that the "expand" utility used on *nix systems to convert tabs to spaces in 
# text files is not present.  (Windows has a program called "expand", but it does
# something different and would fail.)

# Comment out the following to remove syntax highlighting
#SYNTAX=yes

if test "$SYNTAX" == "yes"
then
	echo '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' >$2
	echo '<html><head><meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">' >>$2
	echo '<title>AGC/AEA Assembly Listing</title>' >>$2
	echo '<link href="./prettify.css" type="text/css" rel="stylesheet" />' >>$2
	echo '<script src="./prettify.js" type="text/javascript" onerror="alert('Error: failed to load ' + this.src)"></script>' >>$2
	echo '<script src="./lang-apollo.js" type="text/javascript" onerror="alert('Error: failed to load ' + this.src)"></script>' >>$2
	echo '</head>' >>$2
	echo '<body onload="prettyPrint()">' >>$2
	echo '<span style="font-family: monospace;">' >>$2
	echo '<pre class="prettyprint lang-apollo">' >>$2
else
	echo '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' >$2
	echo '<html><head><meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">' >>$2
	echo '<title>AGC/AEA Assembly Listing</title></head><body>' >>$2
	echo '<span style="font-family: monospace;"><PRE>' >>$2
fi
if test $# -le 2
then
expand $1 >>$2
else
cat $1 >>$2
fi
echo '</PRE></span></body></html>' >> $2

