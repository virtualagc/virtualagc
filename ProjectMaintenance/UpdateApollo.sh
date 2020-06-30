#!/bin/bash
# Updates the main Virtual AGC Project website (www.ibiblio.org/apollo)
# so that it corresponds to the associated materials stored locally.
#
# The assumption is that there are two separate folders on the local 
# drive that contain materials to be uploaded to the project website.
# One of them (specified by the environment variable HTML) is supposed
# to be the local version of the "gh-pages" branch of the Virtual AGC
# GitHub repository (https://github.com/virtualagc/virtualagc/tree/gh-pages);
# whether this is sync'd to GitHub, or not, the local version is
# always used in the process of updating the website.  The second folder
# (specified by the environment variable DOCS) is the exact image of the 
# Virtual AGC project website the way we want it to be after update, except 
# that the portions of $DOCS/ corresponding to the $HTML/ folder are not 
# necessarily up-to-date prior to invoking this script.  The update process 
# itself copies the contents of $HTML/ into $DOCS/, so $DOCS/ is completely
# up-to-date with respect to $HTML/ when the update process finishes.
#
# Allows up to 3 command-line switches, all of which are used as
# additional switches for the 'rsync' command.  Useful switches
# (in my view) are:
# 	--dry-run	Just shows what rsync would have done to the
#			website, without actually doing.
#	--delete	Deletes files on the website which are not
#			present in local storage.  This is great for
#			cleanup, but very dangerous without coordination
#			between multiple administrators.  For example,
#			suppose that administrator "A" has added a new
#			file (say, "My.File") but not given it to 
#			administrator "B", then updates by "A" will
#			add the file, and updates by "B" will remove it.

# Default values of environment variables, corresponding to my own (RSB)
# computer setup, and my own credentials at ibiblio.org.
if [[ "$HTML" == "" ]]
then
	HTML=~/git/virtualagc-web
fi
if [[ "$DOCS" == "" ]]
then
	DOCS=~/Desktop/sandroid.org/public_html/apollo
fi
if [[ "$LOGIN" == "" ]]
then
	LOGIN=apollo
fi

# A sanity check:
if [[ ! -f "$HTML"/ProjectMaintenance/ProjectMaintenance.html ]]
then
	echo "The specified local staging area ($HTML) does not contain the right files."
	exit 1
fi
if [[ ! -f "$DOCS"/changes.html ]]
then
	echo "The specified local full area ($DOCS) does not contain the right files."
	exit 1
fi

cd "$DOCS"
# Update $DOCS/ with respect to $HTML/.
cp -a "$HTML"/* "$HTML"/.htaccess .
# Make sure that the file permissions are such that all files are readable by
# browsers.
chmod -R ugo+r *
chmod 705 .htaccess
# Make sure that all subfolders have a .htaccess file.
find -type d -exec cp .htaccess {} \;
# Now do the actual update.  Note that --cvs-exclude automatically excludes *.exe, 
# so any exe files have to have an explicit --include.
rsync $1 $2 $3 \
	--include=Downloads/yaOBC.exe \
	--include=Downloads/yaASM.exe \
	--include=Downloads/VirtualAGC-setup.exe \
	--cvs-exclude -av -e ssh * "$LOGIN"@login.ibiblio.org:/public/html/apollo
