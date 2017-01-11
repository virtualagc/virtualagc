# The makefile for the website doesn't do anything necessary,
# and the contents of the website should be perfectly fine
# as-is.  What it *does* do is to optionally clean it up.
# Specifically, it runs 'tidy' (http://www.html-tidy.org/)
# on the HTML, which often has a pretty human-unfriendly
# appearance if edited by certain software (such as SeaMonkey).
#
# Whether or not you should run this program depends on how
# much confidence you have in 'tidy', since the files are
# cleaned up in-place.  So I'd definitely recommend checking
# the results before committing them to the repo.

HTML:=$(wildcard *.html)

.PHONY: all default
all default:
	#tidy -e -i -utf8 -m ${HTML}
	for n in ${HTML} ; do echo $$n ; tidy -q -i -utf8 -m $$n ; done

