#!/bin/bash
# The purpose of this script is for automating the setup of 
# Code::Blocks based GUI debugging for Virtual AGC, per instructions from 
# http://code.google.com/p/virtualagc/wiki/DevelopmentWithCodeBlocks.


WIKI="http://code.google.com/p/virtualagc/wiki/DevelopmentWithCodeBlocks"

# Test the VirtualAGC install directory to find system type.
if test -d "$HOME/Desktop/VirtualAGC.app/Contents"
then
	echo "Configuring Code::Blocks for Mac OS X"
	DIR="$HOME/Desktop/VirtualAGC.app/Contents"
	CLEXERS="/usr/share/codeblocks/lexers"
elif test -d "$HOME/VirtualAGC"
then
	echo "Configuring Code::Blocks for Linux"
	DIR="$HOME/VirtualAGC"
	CLEXERS="/usr/share/codeblocks/lexers"
else
	echo "Unknown system type, or else Virtual AGC is installed in a"
	echo "non-standard way.  Please consult the wiki page at"
	echo $WIKI.
	exit 1
fi
VLEXERS="$DIR/Resources/SyntaxHighlight/CodeBlocks/lexers"

if test ! -d "$CLEXERS"
then
	echo "Code::Blocks is not installed, or else is installed at an"
	echo "unexpected location. Please consult the wiki page at"
	echo $WIKI.
	exit 1
fi

# Syntax-highlighting files present?
if test ! -d "$VLEXERS"
then
	echo "The Virtual AGC installation is not new enough to include"
	echo "the syntax-highlighting files.  (Should be 200907 or"
	echo "later.)  Please update or else consult the wiki page"
	echo $WIKI.
	exit 1
fi

# Install the lexer configuration
cp "$VLEXERS"/*.xml "$CLEXERS"/
cp "$VLEXERS"/*.sample "$CLEXERS"/


#########################################################################
#									#
#	I've only made a small start with this.  On next step,		#
#	fixing Code::Blocks's configuration file, which is XML, 	#
#	I'm undecided how to proceed.  It could be edited directly	#
#	with a program based on libxml, or else a Code::Blocks		#
#	script could be written.  Both approaches sound nasty.		#
#	So I need to think about this a while ....			#
#									#
#########################################################################


