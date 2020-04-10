#!/usr/bin/python3
# This program is a supplement to drilldown.py.  
#
# As originally conceived, drilldown.py builds a G&N assembly drillown 
# in a top down fashion.  Using the data files NNNNNNNR.csv (which 
# contain parts lists for various assembly-drawings NNNNNNNR.csv) 
# and components.csv (which lists drawing numbers NNNNNNN which
# are known to be components rather than assemblies), drilldown.py starts from
# a top-level assembly, interrogates its subassemblies, then interrogates the
# subassemblies of the subassemblies, and so on.
# 
# That process works well, except in the case where an assembly drawing is 
# missing, which means that a parts list for that assembly is missing, which
# means that all subassemblies and components below that branch are missing as
# well.  For example, consider the hypothetical (and purely imaginary example)
# of an assembly hierarchy like the following:
#
#	1000000
#		1100000
#			1110000
#				1111000
#					...
#				1112000
#					...
#				...
#			1120000
#				1121000
#				1122000
#				...
#			1130000
#			...
#		1200000
#			1210000
#			1220000
#			...
#		1300000
#			...
#		...
#
# In this example, suppose that we simply do not have a copy of drawing 1110000.
# When we create the drilldown of assembly 1000000, assembly 1110000 will appear
# in the hierarchy, though of course there will be no link to a scan of its drawing,
# but all of its subassemblies (1111000, 1112000, ...) and their various descendents
# will be missing.
#
# However ... in some cases, the original drawings do have enough information in them
# to *partially* work around this problem, and to restore *some* of the missing 
# elements.  But the data files NNNNNNNR.csv and components.csv don't contain any 
# information that helps, and thus additional data files need to be created to allow
# drilldown.py to fill in those gaps.  This program (bottomUp.py) is an aid to creating
# those additional data files.
#
# The reason some gaps can be filled in is that that original drawings *sometimes* (but
# not always) list the parent assemblies of which they are a member.  For example, 
# consider drawing 2007033; if you inspect it, you will see that it lists a "NEXT ASSY"
# of 2007031 ... which means that if we examine drawing 2007031, we will find that 2007033
# is on its parts list.  Thus if we knew that information, we could include 2007033 in the
# assembly hierarchy in a bottom-up fashion, even if the absence of 2007031 stymied us in
# working from the top down.  If we had a data file that listed *all* such parent assemblies
# reported by all drawings, we could use it to systematically fix a large proportion of such
# gaps.  (We couldn't fix *all* of them, since in addition to the fact that not all
# drawings list their parent assemblies, it could also happen that both a drawing *and*
# its parent drawing were missing, and this method cannot fix a gap of two missing levels.)
#
# The most-thorough way to create the list is to manually inspect every available G&N drawing, 
# and to create a list of the parent drawings they call out.  However, there's a vast 
# number of such drawings, and it would take a very long time to do so.  Moreover, since
# the parent drawings are mostly present, most of the work in creating the list would be
# wasted in the end, because there's no actual gap in the first place.
#
# A less-thorough but much easier way to create an incomplete but still very-useful list
# is to only manually inspect those drawings for which there is no existing NNNNNNNR.csv
# file and no corresponding entry in components.csv.  This is aided by the present program
# (bottomUp.py), which starts from drawings.csv (as list of *all* available drawings) and
# then deletes drawing number for which there is an NNNNNNNR.csv file or an entry in 
# components.csv. In other words, all it does is to create a list of the drawings to be
# examined in the process of creating a bottom-up list, and does not actually create a
# bottom-up list itself.
#
# At first glance, it may seem that the bottom-up list so-created is in fact *complete*, or
# at least as complete as possible given that not every drawing lists its own parents.  But
# that turns out not to be true.  The problem is that any given assembly may appear in the parts 
# list of more than one parent assembly.  Imagine, for example, that drawing 1111000 appears 
# in the part list of 1110000 (as I mentioned in an example above), but *also* in the parts list
# of 1120000.  (In the example) we don't have a copy of 1110000, but we do have a copy of
# 1120000.  Thus, 1111000 will *not* appear in the the output of bottomUp.py, and therefore
# won't appear in the data file of parent drawings we're going to create, and thus drilldown.py
# won't know how to work around the missing 1110000.
#
# But that's not the usual kind of case, I hope.  Perhaps such gaps in the approach can be
# filled in in the future.  My concern right now is just to get the low-hanging fruit ... 
# to fill in gaps where it's easy to do so, and postpone worrying about getting better coverage 
# until later.
#
# I expect that the data file of parent drawings will be called parents.csv, and that it will
# be a tab-delimited file, with the first field in any given line being a drawing number,
# and the subsequent fields of the line being the drawing number of the listed parents of that
# drawing.  I allow the case of there being no additional fields (beyond the first one), meaning
# that no parent drawings are listed.  
#
# Usage:
#	ls -1 [0-9]*.csv | bottomUp.py >newParents.csv
# Additionally, bottomUp.py implicitly transparently uses drawings, parents.csv, and components.csv.
# The contents of parents.csv is output on stdout (newParents.csv), suffixed by a marker 
# (which is a line containing nothing but the symbol '#'). 
# A basic list of all drawings is constructed from drawings.csv, from which all drawings already
# in in parents.csv, components.csv, and stdin are removed.  This list is then output
# to stdout (newParents.csv).  Thus newParents.csv ends up being parents.csv, with an additional
# list of drawings (and no parents for them) suffixed to it, with a marker line ("#") between
# the two.  Somebody can then manually edit newParents.csv (adding parent fields and removing
# the marker like "#"), using it to replace the original parents.csv.

TBD
