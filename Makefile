# Copyright 2003-2007,2009-2010,2016-2018,2020,2022 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:	Makefile
# Purpose:	This makefile is used (recursively) to build all
#		components of the Virtual AGC project, for Linux and
#		similar targets.
# Mods:		10/22/03 RSB	Wrote. 
#		11/02/03 RSB	Added Luminary131.
#		11/13/03 RSB	Added Colossus249.
#		05/01/04 RSB	Now provide yadsky also as yaDSKY, after install.
#		05/06/04 RSB	Now installs *.ini.
#		05/13/04 RSB	Now excludes *CVS* and *snprj* from the tarball.
#		05/14/04 RSB	Added PREFIX (for setting the installation
#				directory.
#		05/18/04 RSB	Added a datestamp to the dev. snapshot.
#		05/31/04 RSB	Move snapshot to ftp.
#		07/03/04 RSB	Added the Validation directory.
#		07/14/04 RSB	Added ControlPulseSim
#		08/09/04 RSB	Eliminate the contents of autom4te.cache/* when 
#				building a snapshot.  (These contents mess up
#				'configure' on some systems.)
#		08/10/04 RSB	Added the Sim* shell scripts to the installable
#				files.
#		08/12/04 RSB	Added NVER.  Went to v0.90.
#		08/13/04 RSB	Went to v20040813
#		08/24/04 RSB	Exclude ephemeris data from development snapshot,
#				but make a second file for it.
#		08/25/04 RSB	Added yaIMU.
# 		08/29/04 RSB	Made snapshot-ephemeris a separate target from
#				snapshot.
#		08/30/04 RSB	Moved the directory for snapshots from ftp space
#				into http space.
#		09/02/04 RSB	Changed yaIMU to yaUniverse.
#		01/10/05 RSB	Added binLEMAP.
#		04/30/05 RSB	Added CFLAGS
#		05/08/05 RSB	Added a 'snapshot' target.
#		05/14/05 RSB	Made some Mac OS X related changes for 'snapshot'.
#		05/28/05 RSB	Added yaDEDA.
#		06/02/05 RSB	Added yaAGS.
#		06/14/05 RSB	Updated the version code.
#		06/19/05 RSB	Added the NOGUI=yes command-line option.
#		07/06/05 RSB	Added Artemis072
#		07/28/05 RSB	Oops!  Had multiple "snapshot" targets.
#		08/04/05 RSB	Added the CURSES variable.
#		08/06/05 RSB	Now detect build-platform type using the
#				OSTYPE environment variable, which seems to
#				be reasonably consistent in distinguishing
#				at least the following cases:
#					OSTYPE=linux	
#					OSTYPE=darwin	(MacOS X)
#					OSTYPE=msys	(Msys on Win32)
#					OSTYPE=cygwin	(CygWin on Win32)
#				All of these cases use the "linux" Makefile,
#				but with very minor flourishes, except the
#				Msys case, which uses Makefile.Win32 instead.
#		01/09/06 RSB	Removed the prefix '-' from the lines that
#				build Artemis072.
#		02/26/06 RSB	Now creates a script called VirtualAgcUninstall
#				during installation.
#		03/05/07 RSB	Changed the default compiler flags to include
#				"-DALLOW_BSUB".  This allows yaAGC and friends
#				to pass instructions in the BSUB register upon
#				exiting from an interrupt-service routine.
#		03/01/09 RSB	Updated the version code.
#		03/05/09 RSB	Now builds VirtualAGC.
#		03/06/09 RSB	There are new targets: 'default' is the same 
#				as 'all'.  'all-archs' is like 'all', except 
# 				that 'all' builds only for the native platform
#				while 'all-archs' is used when running under
#				Linux to create the Linux, Win32, and Mac
#				stuff.
#		03/11/09 RSB	yaTelemetry added.
#		03/12/09 RSB	yaDSKY replaced by yaDSKY2, by default..
#		03/13/09 RSB	Added provisions for replacing yaDEDA by yaDEDA2.
#		03/16/09 RSB	"make clean" would fail if ./configure hadn't
#				been performed due to the fact that it isn't
#				needed when yaDSKY and yaDEDA aren't built.
#		03/19/09 RSB	Will now *try* to build yaDSKY/yaDEDA even if
#				yaDSKY2/yaDEDA2 are selected, and vice-versa.
#				However, failure won't a fatal error.  If find
#				it useful for both to be available for 
#				debugging.
#		03/28/09 RSB	Merged in yaACA3.
#		04/14/09 RSB	Made some mods to help this build in Solaris.
#		04/25/09 RSB	Fixed dev snapshots to exclude .svn directories.
#		04/26/09 RSB	Backed out all of the stuff that relies on
#				Makefile.Win32, and most stuff for OS 
#				auto-detection.  Removed the "os" target.
#				Removed the "install" target.
#		05/02/09 RSB	Added DEV_STATIC to change builds of binary
#				installers so that the wxWidgets-based programs
#				are dynamic-linked rather than static-linked.
#				However, it doesn't appear to me as though it
#				would change the size of the binary packages
#				in any significant way to use the dynamic
#				libraries, so I don't bother to do it.
#				Updated to make work with FreeBSD (PC-BSD 7.1).
#				Adjusted for SOLARIS.
#		05/23/09 RSB	Added Comanche055 to the normal build sequence.
#		06/07/09 RSB	Added Luminary099 to the normal build sequence.
#		06/29/09 RSB	Added the 'listings' target.
#		08/02/09 RSB	Now that I got rid of libreadline on the Win32
#				productin build (yesterday), I'm beginning to
#				experience readline-related problems (but 
#				different ones) on Linux.  I'm completely
#				disabling readline for all platforms for now,
#				until these problems can be fixed.
#		09/08/09 JL	Commented out Artemis072 from main build. 
#		01/30/10 RSB	Added yaASM.
#		02/16/10 RSB	Adjustments associated with getting
#				Artemis072 into the installers.
#		02/20/10 RSB	Updated version to 20100220 for release.
#		2011-04-27 JL	Added Colossus237.
#		2011-05-26 JL	Cleanup and rearrange. Add a 'missions' target to
#				build all mission versions. Make use of
#				parens/braces consistent. Add some shortcut 
#				variables for use in sub-make actions.
#		2016-08-07 RSB	Wasn't building the Validation "mission", needed
#				for the VirtualAGC installers.
#		2016-08-24 RSB	Solarium055 added to mission list.
#		2016-08-28 RSB	Somehow, the missions weren't being built before
#				the VirtualAGC installer, so neither the mission
#				binaries nor syntax-highlighted assembly listings
#				were included in the installer.
#		2016-08-29 RSB	Mods related to my personal-build situation, which
#				shouldn't affect anyone else.
#		2016-10-04 JL	Added 'format-missions' rukle to reformat all 
#				mission sources using yaYUL.
#		2016-10-21 RSB	Added AURORA12 to the missions.
#		2016-11-03 RSB	Added SUNBURST120 to the missions.
#		2016-11-08 RSB	Merged in block1 branch.
#		2016-11-16 RSB	Certain resources needed only by the "standard"
#				32-bit Linux VirtualAGC VM I'm now creating are
#				added to the installation bundle.  These are
#				related to debugging on Code::blocks. 
#		2016-11-17 RSB	Fixed a "sed --in-place ..." that doesn't work on
#				systems with non-GNU sed, such as FreeBSD or
#				Solaris.  Other fixes of a similar nature, for those
#				same operating systems.
#		2016-11-18 RSB	Removed yaACA2 from FreeBSD build.
#		2016-12-28 RSB	Added RETREAD44 to the mission list.
#		2017-02-04 RSB	Added SuperJob to the mission list.
#		2017-03-03 RSB	Added LUM99R2 to the list of missions.
#		2017-03-18 RSB	Added Luminary116 to mission list.
#		2017-03-27 RSB	Updated NVER for "releasing" a new installer and VM.
#		2017-04-17 RSB	Updated NVER.
#		2017-06-19 RSB	Updated NVER and added Sunburst37 to the mission list.
#		2017-08-01 MAS	Added LMY99R0 to the list of missions.
#		2017-08-23 RSB	Since Solarium doesn't presently assemble correctly in
#				Mac OS X, it is now only conditionally added to the 
#				mission list for non-Mac build systems.  Hopefully that's
#				temporary.
#		2017-08-24 RSB	Added FORCE_clang, FORCE_cc and FORCE_CC options.
#		2017-08-29 RSB	Added ZERLINA56 to mission list.
#		2017-08-31 RSB	Unconditionally returned Solarium to the mission list, since 
#				the yaYUL bug related to it that was expressing itself in 
#				Mac OS X has been fixed.
#		2018-09-04 MAS	Added LUMINARY130 to mission list.
#		2018-10-12 RSB	Added the Validation-hardware-simulation target.
#		2019-06-17 RSB	Added RETREAD50.
#		2019-07-23 RSB	Added SUNDIALE.
#		2019-07-27 MAS	Added LUM69R2.
#		2019-07-28 MAS	Added Luminary 97 and 98.
#		2019-07-31 RSB	Added COMANCHE051.
#		2019-08-16 RSB	Added Artemis071.
#		2019-09-17 MAS	Added Luminary 178.
#		2019-09-18 RSB	Added yaOBC and yaASM targets.
#		2019-09-22 RSB	Added Luminary163 and 173 missions.
#		2020-05-13 RSB	While I had added the yaOBC and yaASM (Gemini) targets a
#				couple of years ago, for some reason I didn't set them
#				to be built automatically.  Now they are.  Also, added
#				the yaLVDC (LVDC/PTC) target, and have it build automatically.
#		2020-07-22 RSB	Added SundanceXXX.
#		2020-08-05 RSB	Added Sundance306ish.
#		2020-12-05 RSB	Added Comanche044. Also, added some comments mostly
#				intended to help me recall how my own personal build
#				environment works :-), but also provides an example of
#				the FORCE_cc and FORCE_CC build switches.  Also, updated
#				the NVER version code.
#		2020-12-24 RSB	Added Comanche045 and Manche45R2.
#		2021-08-24 RSB	Added Luminary096 and removed LUM99R2.
#		2022-08-07 RSB	Now allows copy the desktop icon to a *nix 
#				desktop to fail, as this is reported to fail
#				with Ubuntu running under WSL on Windows.
#				Also, adds a prominent warning if Tcl/Tk is not
#				found.
#		2022-10-29 RSB	Added LM131R1, Sunrise45, Sunrise69.
#		2022-11-17 RSB	Added Aurora 88.
#		2023-05-02 RSB  Added Corona 261.
#		2024-01-25 RSB  Added Skylark 48
#
# The build box is always Linux for cross-compiles.  For native compiles:
#	Use "make MACOSX=yes" for Mac OS X.
#	Use "gmake SOLARIS=yes" for Solaris.
#	Use "make WIN32=yes" for Windows.
#	Use "gmake FREEBSD=yes" for FreeBSD.
#	Use "make" for Linux.
#
# On some platforms, we simply can't deduce what C or C++ compiler is being used
# from the settings indicated above.  An example is Mac OS X, in which older versions
# of Xcode used gcc, but newer ones use clang (which we don't support, but see below).  
# Or so I'm told.  At any rate, you can force using specific C and C++ compilers by 
# giving their full pathnames. For example:
#	make MACOSX=yes FORCE_cc=/path/to/gcc FORCE_CC=/path/to/g++
# Most people shouldn't need this feature, but the more complex your build environment,
# the more likely. This is clunky, I admit, but it's better than having to perform AGC 
# builds in a clean virtual machine, which is often the only other practical option. It's  
# the curse of having been a software developer for so long!  Too ... many ... versions.
#
# Another available switch is FORCE_clang=yes, which makes certain changes that *may* 
# allow building with clang rather than gcc.  Since I don't have any Macs new 
# enough to be use clang, I can't testify of my own personal knowledge that this
# works as hoped for on a Mac.  But see the examples below. 
#
# Some examples of FORCE_xxx:
#
#    1.	On my own (Linux) computer, with so many competing versions of gcc and libraries, 
#	I'll get a runtime version-mismatch between the VirtualAGC GUI and libstdc++ if 
#	I just run 'make' by itself using the default version of g++ found in my PATH.
#	So instead, I have to run "make FORCE_CC=/usr/bin/g++".  
#
#    2.	I have installed clang on my Linux box, not because I have any interest in clang
#	as such, but just to do my due diligence for Mac users, to the extent feasible 
#	without having an actual modern Mac.  A build of Virtual AGC with clang does 
#	complete without errors on my Linux box, and does seem to work after it is built.  
#	The build-command I have to use for clang 3.9 is:
# 	"make FORCE_clang=yes FORCE_cc=/usr/bin/clang-3.9 FORCE_CC=/usr/bin/clang++-3.9".

# NVER is the overall version code for the release.
NVER:=\\\"2024-03-06\\\"
DATE:=`date +%Y%m%d`

# DON'T CHANGE THE FOLLOWING SWITCH *********************************
# This switch determines whether or not wxWidgets programs are built
# statically linked or dynamically linked for the binary installers
# associated with the development snapshots.  It has nothing whatever
# to do with normal builds by normal users.  Uncommented, they're
# static.  Commented, they're dynamic.  And yes, DEV_STATIC *should*
# be repeated.  I haven't fully worked out yet how to get the dynamic
# libraries into the installers, however, so don't use them!
DEV_STATIC=DEV_STATIC=yes
# *******************************************************************

# Select compiler basenames.  We use
#	${cc}	C compiler
#	${CC}	C++ compiler
# These are almost always gcc and g++, respectively, but on some
# platforms it's necessary to use non-GNU compilers (even if the 
# GNU compilers are actually available and installed)  in order to 
# be able to access the native builds of wxWidgets for programs
# like yaDSKY2. 
cc=gcc
CC=g++

ifdef SOLARIS
cc=cc
endif
ifdef IPHONE
cc=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin9-gcc-4.0.1
LIBS=
endif
ifdef FORCE_cc
cc=$(FORCE_cc)
endif

ifdef SOLARIS
CC=CC
endif
ifdef IPHONE
CC=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin9-g++-4.0.1
LIBS=
endif
ifdef FORCE_CC
CC=$(FORCE_CC)
endif

export cc
export CC

# Comment out the following line(s) to use yaDSKY rather than yaDSKY2 and/or 
# yaDEDA by yaDEDA2.  yaDSKY/yaDEDA have been replaced by yaDSKY2/yaDEDA2 
# principally because yaDSKY/yaDEDA are gtk+ based while yaDSKY2/yaDEDA2
# are wxWidgets based.  At present, I consider wxWidgets superior to gtk+
# (in this particular application) because: a) I can get it to work on a 
# wider range of platforms; b) I can link statically to it rather than 
# being forced to use shared libraries.  yaDSKY2/yaDEDA2 are drop-in 
# identically-featured replacements for yaDSKY/yaDEDA, except that certain
# options useful only in debugging or *only* for GTK+ aren't implemented.
# These include the --test-downlink, --relative-pixmaps, and --show-packets
# switches.  yaTelemetry has already been made available (and is the preferred
# method) to provide the --test-downlink functionaly.  And, of course, the 
# original versions of yaDSKY/yaDEDA are still available even though not 
# compiled by default.
YADSKY_SUFFIX=2
YADEDA_SUFFIX=2

# Uncomment the following line (or do 'make NOREADLINE=yes') if the build 
# gives errors related to readline.
NOREADLINE=yes

# The following line, if uncommented, allows my production builds for Win32
# to use libreadline.  If commented, they can't.  Native Win32 builds aren't
# affected.
#ReadlineForWin32=yes

# Uncomment the following line (or do 'make CURSES=yes') if the build fails
# with an indication that libcurses.a is needed.
#CURSES=yes

SNAP_PREFIX = /usr/local/yaAGC

# Does the compiler accept the -x switch?
DASHX=-x c

# Some adjustments for building in Solaris
ifdef SOLARIS
DASHX=
#NOREADLINE=yes
LIBS+=-L/usr/local/lib
LIBS+=-lsocket
LIBS+=-lnsl
CFLAGS0 += /opt/csw/include/wx-2.8
CFLAGS += /opt/csw/include/wx-2.8
dummy:=$(PATH):/opt/csw/bin
export PATH=$(dummy)
export SOLARIS
endif

# Some adjustments for building in Mac OS X
ifeq ($(OS),Darwin)
MACOSX=yes
endif

ifdef MACOSX
#NOREADLINE=yes
ISMACOSX:=MACOSX=yes
export MACOSX
endif

# Some adjustments for building in FreeBSD
ifdef FREEBSD
LIBS+=`pkg-config --libs gtk+-2.0`
LIBS+=`pkg-config --libs glib`
export FREEBSD
endif

# GROUP is the main group to which the USER belongs.  This seems to be defined
# as an environment variable in Mac OS X, but not in Linux.  You can override this
# with a command-line assignment, but it is only used for the 'snapshot' target.
# For example, "make GROUP=wheel snapshot".  However, the default behavior should
# be okay in Linux or Mac OS X (I hope).
ifndef GROUP
GROUP = users
endif

export DASHX

# Note:  The default build uses no CFLAGS; this makes it easier for a user in
# the field to build it, since unexpected problems won't throw them for a loop.
# But I personally want to build with 
#	CFLAGS=-Wall -Werror
# to catch every possible problem before sending it out into the world.
ifeq ($(USER),rburkey)
WEBSITE=../sandroid.org/public_html/apollo
CFLAGS0=-Werror -DALLOW_BSUB -g -O0
CFLAGS=-Wall $(CFLAGS0)
yaACA=-
else 
ifdef DEV_BUILD
CFLAGS0=-Werror -DALLOW_BSUB -g -O0
CFLAGS=-Wall $(CFLAGS0)
yaACA=-
else 
ifdef DEBUG_BUILD
CFLAGS0=-DALLOW_BSUB -g -O0
CFLAGS=$(CFLAGS0)
yaACA=-
else
CFLAGS0=-DALLOW_BSUB
CFLAGS=$(CFLAGS0)
yaACA=-
endif
endif
WEBSITE=..
endif
ifdef MACOSX
yaACA=-
endif
ifdef SOLARIS
yaACA=-
endif

LIBS2=
ifdef FORCE_clang
wxFLAGS=-Wno-potentially-evaluated-expression
export wxFLAGS
LIBS2=-lstdc++
endif

# Note:  The CURSES variable is misnamed.  It really is just any special libraries
# for yaAGC, yaAGS, or yaACA3 that depend on Win32 vs. non-Win32 native builds.
ifdef WIN32
export WIN32
EXT=.exe
CFLAGS0+=-I/usr/local/include
CFLAGS+=-I/usr/local/include
LIBS+=-L/usr/local/lib
LIBS+=-L/usr/lib
LIBS+=-lkernel32
LIBS+=-lwsock32
CURSES=../yaAGC/random.c
CURSES+=-lregex
else
CURSES=-lcurses
endif

ifdef MACOSX
CFLAGS0+=-I/opt/local/include -I/opt/local/include/allegro
CFLAGS+=-I/opt/local/include -I/opt/local/include/allegro
endif

ifdef SOLARIS
CFLAGS0 += -I/opt/csw/include/wx-2.8
CFLAGS += -I/opt/csw/include/wx-2.8
endif

ifdef MACOSX
CFLAGS0+=-DMACOSX=yes
CFLAGS+=-DMACOSX=yes
endif
ifdef SOLARIS
CFLAGS0+=-DSOLARIS=yes
CFLAGS+=-DSOLARIS=yes
endif
ifdef FREEBSD
CFLAGS0+=-DFREEBSD=yes
CFLAGS+=-DFREEBSD=yes
endif
export CFLAGS0
export CFLAGS

# We assume a *nix build environment.

include Makefile.yaAGC
ifndef PREFIX
PREFIX=/usr/local
endif

LIBS2+=$(LIBS)
BUILD = $(MAKE) PREFIX=$(PREFIX) NVER=$(NVER) CFLAGS="$(CFLAGS)" CURSES="$(CURSES)" LIBS2="$(LIBS2)" NOREADLINE=$(NOREADLINE) ReadlineForWin32=$(ReadlineForWin32) $(ARCHS) EXT=$(EXT)

# List of mission software directories to be built.
MISSIONS = Validation Zerlina56 Luminary131 Colossus249 Comanche055 
MISSIONS += Luminary099 Artemis072 Colossus237 Luminary130
MISSIONS += Aurora12 Sunburst120 Luminary210 Retread44 Luminary069
MISSIONS += SuperJob Luminary116 Borealis Sunburst37 LMY99R0
MISSIONS += Retread50 SundialE LUM69R2 Luminary097 Luminary098
MISSIONS += Comanche051 Artemis071 Luminary178 Luminary163 Luminary173
MISSIONS += SundanceXXX Sundance306ish Comanche044 Comanche045 Manche45R2
# MISSIONS += LUM99R2
MISSIONS += Luminary096 LM131R1 Sunrise45 Sunrise69 Aurora88
MISSIONS += Corona261 Skylark048
# ifndef MACOSX
MISSIONS += Solarium055 TRIVIUM TRIVIUM-repaired
# endif
export MISSIONS

# Missions needing code::blocks project files.
cbMISSIONS = Validation Luminary131 Colossus249 Comanche055 Luminary130
cbMISSIONS += Luminary099 Artemis072 Colossus237 Aurora12 Sunburst120 LMY99R0
cbMISSIONS += Luminary069 LUM99R2 Luminary116 Luminary210 Retread44 Borealis SuperJob
cbMISSIONS += LUM69R2 Luminary097 Luminary098 Luminary178
cbMISSIONS := $(patsubst %,%.cbp,$(cbMISSIONS))

# The base set of targets to be built always.
SUBDIRS = Tools yaLEMAP yaAGC yaAGS yaYUL ControlPulseSim yaUniverse
SUBDIRS += yaAGC-Block1-Pultorak yaAGCb1 yaUplinkBlock1 Validation-Block1
SUBDIRS += yaASM yaOBC
SUBDIRS += yaLVDC
SUBDIRS += $(MISSIONS)

ifndef NOGUI
ifeq "$(YADEDA_SUFFIX)" ""
SUBDIRS += yaDEDA/src
else
SUBDIRS += yaDEDA2
endif
ifeq "$(YADSKY_SUFFIX)" ""
SUBDIRS += yaDSKY/src
else
SUBDIRS += yaDSKY2
endif
ifndef WIN32
SUBDIRS += yaACA
endif
ifndef FREEBSD
SUBDIRS += yaACA2
endif
SUBDIRS += yaACA3
SUBDIRS += jWiz
SUBDIRS += yaTelemetry 
SUBDIRS += yaDSKYb1
SUBDIRS += VirtualAGC
endif # NOGUI

# EXTSW is the switch for cp that's equivalent to -a in Linux.
ifdef MACOSX
EXTSW=-pR
else
ifdef SOLARIS
EXTSW=-r -@ -P
else
EXTSW=-a
endif
endif
export EXTSW

.PHONY: $(SUBDIRS)

.PHONY: default
default: all

.PHONY: $(MISSIONS) clean-missions format-missions
missions: $(MISSIONS)

$(MISSIONS): yaYUL Tools
	$(BUILD) -C $@

Validation-hardware-simulation: yaYUL
	$(BUILD) -C Validation $@.agc.bin 

clean-missions:
	for subdir in $(MISSIONS) ; do $(BUILD) -C $$subdir clean ; done

format-missions:
	for subdir in $(MISSIONS) ; do REFORMAT=no make -C $$subdir format ; done

.PHONY: corediffs
corediffs: yaYUL Tools
	for subdir in $(MISSIONS) ; do $(BUILD) -C $$subdir corediff.txt ; done

.PHONY: all all-archs
all: ARCHS=default
all-archs: ARCHS=all-archs
all all-archs: $(cbMISSIONS) $(SUBDIRS)

.PHONY: Tools yaLEMAP yaAGC yaAGS yaYUL yaUniverse ControlPulseSim
Tools yaLEMAP yaAGC yaAGS yaYUL yaUniverse ControlPulseSim:
	$(BUILD) -C $@ 

.PHONY: yaACA yaACA2 yaACA3
yaACA yaACA2 yaACA3:
	${yaACA}$(BUILD) -C $@ 

.PHONY: yaDEDA
yaDEDA:
	$(BUILD) -C yaDEDA/src -f Makefile.all-archs 
	-$(BUILD) -C yaDEDA2 $(DEV_STATIC)

.PHONY: yaDEDA2
yaDEDA2:
	-$(BUILD) -C yaDEDA/src -f Makefile.all-archs 
	$(BUILD) -C $@ $(DEV_STATIC)

.PHONY: yaDSKY
yaDSKY:
	-$(BUILD) -C yaDSKY/src -f Makefile.all-archs 
	-cp yaDSKY/src/yadsky yaDSKY/src/yaDSKY
	$(BUILD) -C yaDSKY2 $(DEV_STATIC)

.PHONY: yaDSKY2
yaDSKY2:
	-$(BUILD) -C yaDSKY/src -f Makefile.all-archs 
	-cp yaDSKY/src/yadsky yaDSKY/src/yaDSKY
	$(BUILD) -C $@ $(DEV_STATIC)

.PHONY: yaTelemetry
yaTelemetry:
	$(BUILD) -C $@ $(DEV_STATIC)

.PHONY: jWiz
jWiz:
	$(BUILD) -C $@ $(ISMACOSX) $(DEV_STATIC)

yaAGC-Block1-Pultorak yaAGCb1 yaDSKYb1 yaUplinkBlock1 yaValidation-Block1:
	$(BUILD) -C $@ $(DEV_STATIC)

.PHONY: VirtualAGC
VirtualAGC:
	$(BUILD) -C $@ "YADSKY_SUFFIX=$(YADSKY_SUFFIX)" "YADEDA_SUFFIX=$(YADEDA_SUFFIX)" $(ISMACOSX) $(DEV_STATIC)

.PHONY: VirtualAGC-installer
VirtualAGC-installer: all
	$(BUILD) -C VirtualAGC "YADSKY_SUFFIX=$(YADSKY_SUFFIX)" "YADEDA_SUFFIX=$(YADEDA_SUFFIX)" $(ISMACOSX) $(DEV_STATIC) VirtualAGC-installer

.PHONY: yaASM
yaASM:
	$(BUILD) -C $@

.PHONY: yaOBC
yaOBC:
	$(BUILD) -C $@

.PHONY: yaLVDC
yaLVDC:
	$(BUILD) -C $@

# This target is for making HTML assembly listings for the website.
.PHONY: listings
AGC_LISTINGS = $(addprefix listing-agc-, $(MISSIONS))
listings: $(AGC_LISTINGS) listing-aea-FP6 listing-aea-FP8

listing-agc-%:
	rm -f $(WEBSITE)/listings/$*/*.html
	mkdir -p $(WEBSITE)/listings/$*
	cd $* && ../yaYUL/yaYUL --html MAIN.agc >MAIN.lst
	mv $*/*.agc.html $(WEBSITE)/listings/$*
	cp Apollo32.png $(WEBSITE)/listings/$*

listing-aea-%:
	rm -f $(WEBSITE)/listings/$*/*.html
	mkdir -p $(WEBSITE)/listings/$*
	cd $* && ../yaLEMAP/yaLEMAP --html $*.aea
	mv $*/*.aea.html $(WEBSITE)/listings/$*
	cp Apollo32.png $(WEBSITE)/listings/$*

# Here are targets for building the development snapshot, 
# creating the binary installers, and updating local directory
# which sources the Virtual AGC website.  The "snapshot" target
# does this locally, whilst the "buildbox" target does it on a
# (remote) box with a controlled build environment.

.PHONY: snapshot
snapshot: dev binaries

.PHONY: buildbox
buildbox: dev
	sh ./BuildBox.sh

.PHONY: binaries
binaries: clean all-archs
	cp ${EXTSW} VirtualAGC/VirtualAGC-installer $(WEBSITE)/Downloads
	cp ${EXTSW} VirtualAGC/VirtualAGC-setup.exe $(WEBSITE)/Downloads
	cp ${EXTSW} VirtualAGC/VirtualAGC.app.tar.gz $(WEBSITE)/Downloads
	ls -ltr $(WEBSITE)/Downloads | tail -4

# I used this only for creating a development snapshot.  It's no use to anybody
# else, I expect.
.PHONY: dev
dev:	clean
	rm -f $(WEBSITE)/Downloads/yaAGC-dev-$(DATE).tar.bz2
	tar -C .. --exclude=*CVS* --exclude=*snprj* --exclude="*.core" \
		--exclude=yaAGC/yaDSKY/autom4te.cache/* \
		--exclude=yaAGC/yaDSKY/configure \
		--exclude=yaAGC/yaDSKY/config.log \
		--exclude=yaAGC/yaDSKY/config.status \
		--exclude=yaAGC/yaDSKY/aclocal.m4 \
		--exclude=yaAGC/yaDSKY/Makefile.in \
		--exclude=yaAGC/yaDSKY/Makefile \
		--exclude=yaAGC/yaDEDA/autom4te.cache/* \
		--exclude=yaAGC/yaDEDA/configure \
		--exclude=yaAGC/yaDEDA/config.log \
		--exclude=yaAGC/yaDEDA/config.status \
		--exclude=yaAGC/yaDEDA/aclocal.m4 \
		--exclude=yaAGC/yaDEDA/Makefile.in \
		--exclude=yaAGC/yaDEDA/Makefile \
		--exclude=*~ --exclude=*.bak \
		--exclude=*.svn* \
		--exclude=*xvpics* \
		--bzip2 -cvf $(WEBSITE)/Downloads/yaAGC-dev-$(DATE).tar.bz2 yaAGC
	ls -ltr $(WEBSITE)/Downloads
		
snapshot-ephemeris:
	cd .. ; tar --bzip2 -cvf $(WEBSITE)/Downloads/yaAGC-ephemeris.tar.bz2 yaAGC/yaUniverse/*.txt
	ls -l $(WEBSITE)/Downloads

# Code::blocks project file ... for using code::blocks on Linux only.  The 
# cbp file produced needs slight mods to the directory structure for Windows
# or Mac.  However, these files are fine for the standard VirtualAGC VM I'm
# creating.
Validation.cbp:
	sed -e "s/@name@/Validation/" -e 's/MAIN[.]agc[.]bin/Validation.agc.bin/' templateAGC-top.cbp >Validation/temp.txt
	cd Validation ; \
	for n in *.agc ; \
	do \
		echo '                <Unit filename="'$$n'" />'; \
	done >>temp.txt
	cat templateAGC-bottom.cbp >>Validation/temp.txt
	mv Validation/temp.txt Validation/$@

%.cbp:
	@echo Make CBP file $*/$@
	sed "s/@name@/"$*"/" templateAGC-top.cbp >$*/temp.txt
	cd $* ; \
	for n in *.agc ; \
	do \
		echo '                <Unit filename="'$$n'" />'; \
	done >>temp.txt
	cat templateAGC-bottom.cbp >>$*/temp.txt
	mv $*/temp.txt $*/$@

clean: clean-missions
	$(MAKE) -C yaLEMAP clean
	$(MAKE) -C yaASM clean
	$(MAKE) -C yaOBC clean
	$(MAKE) -C yaLVDC clean
	$(MAKE) -C yaAGC clean
	$(MAKE) -C yaAGS clean
	$(MAKE) -C yaDSKY/src -f Makefile.all-archs clean
	rm -f yaDSKY/src/yaDSKY
	$(MAKE) -C yaDEDA/src -f Makefile.all-archs clean
	$(MAKE) -C yaYUL clean
	$(MAKE) -C yaUniverse clean
	$(yaACA)$(MAKE) -C yaACA clean
	$(yaACA)$(MAKE) -C yaACA2 clean
	$(yaACA)$(MAKE) -C yaACA3 clean
	$(MAKE) -C ControlPulseSim clean
	$(MAKE) -C VirtualAGC clean
	$(MAKE) -C yaTelemetry clean
	$(MAKE) -C jWiz clean
	$(MAKE) -C yaDSKY2 clean
	$(MAKE) -C yaDEDA2 clean
	$(MAKE) -C yaACA2 clean
	$(MAKE) -C Tools clean
	$(MAKE) -C yaAGC-Block1-Pultorak clean
	$(MAKE) -C yaAGCb1 clean
	$(MAKE) -C yaDSKYb1 clean
	$(MAKE) -C yaUplinkBlock1 clean
	$(MAKE) -C Validation-Block1 clean
	-rm -f `find . -name "core"` FP6/*.aea.html FP8/*.aea.html

autogen:
	echo PREFIX=$(PREFIX) >Makefile.yaAGC
ifndef NOGUI
	cd yaDSKY && ./autogen.sh --prefix=$(PREFIX)
	cd yaDEDA && ./autogen.sh --prefix=$(PREFIX)
endif

iTMP:=temp.virtualagc
WINHOME=$(subst \,/,$(USERPROFILE))
.PHONY: install
install: all
ifdef MACOSX
	cp ${EXTSW} VirtualAGC/temp/VirtualAGC.app ~/Desktop
	@echo "Run Virtual AGC from its desktop icon."
else
ifdef WIN32
	-mkdir "$(WINHOME)/VirtualAGC"
	cp ${EXTSW} VirtualAGC/temp/lVirtualAGC/* "$(WINHOME)/VirtualAGC"
	@echo "cd %HOMEPATH%\\VirtualAGC\\Resources" >$(iTMP)
	@echo "..\\bin\\VirtualAGC" >>$(iTMP)
	mv $(iTMP) $(WINHOME)/Desktop/VirtualAGC.bat
	@echo ""
	@echo "================================================================"
	@echo "Run Virtual AGC from its desktop launcher."
	@echo "Or else, run Virtual AGC from a Windows command-line as follows:"
	@echo "  cd VirtualAGC\\Resources"
	@echo "  ..\\bin\\VirtualAGC"
	@echo "================================================================"
else
	# Create installation directory.
	-mkdir ~/VirtualAGC
	cp ${EXTSW} VirtualAGC/temp/lVirtualAGC/* ~/VirtualAGC
ifdef SOLARIS
	@echo "#!/bin/sh" >$(iTMP)
	@echo "export LD_LIBRARY_PATH=/opt/csw/lib" >>$(iTMP)
	@echo "cd ~/VirtualAGC/Resources" >>$(iTMP)
	@echo "../bin/VirtualAGC &" >>$(iTMP)
	chmod +x $(iTMP)
	mv $(iTMP) $$HOME/Desktop/VirtualAGC
	@echo ""
	@echo "================================================================"
	@echo "Run Virtual AGC from its desktop launcher.  (You can change the"
	@echo "icon associated with the launcher by right-click, Properties, and"
	@echo "selecting ~/VirtualAGC/Resources/ApolloPatch2-transparent.png.)"
	@echo "If given the choice between \"Run\" and \"Run in Terminal\", choose"
	@echo "\"Run\".  Or else, run Virtual AGC from a command-line as follows:"
	@echo "  cd ~/VirtualAGC/Resources"
	@echo "  ../bin//VirtualAGC"
	@echo "================================================================"
else
	@echo "[Desktop Entry]" >$(iTMP)
	@echo "Encoding=UTF-8" >>$(iTMP)
	@echo "Name=VirtualAGC" >>$(iTMP)
	@echo "Comment=Virtual AGC GUI Application" >>$(iTMP)
	@echo "Terminal=false" >>$(iTMP)
	@echo "Exec=$$HOME/VirtualAGC/bin/VirtualAGC" >>$(iTMP)
	@echo "Type=Application" >>$(iTMP)
	@echo "Icon=$$HOME/VirtualAGC/Resources/ApolloPatch2-transparent.png" >>$(iTMP)
	@echo "Path=$$HOME/VirtualAGC/Resources" >>$(iTMP)
	chmod +x $(iTMP)
	-mv $(iTMP) $$HOME/Desktop/VirtualAGC.desktop
	@echo ""
	@echo "================================================================"
	@echo "Run Virtual AGC from its desktop icon.  If the icon doesn't"
	@echo "exist or doesen't work, run Virtual AGC from a command-line"
	@echo "as follows:"
	@echo "  cd ~/VirtualAGC/Resources"
	@echo "  ../bin/VirtualAGC"
	@echo "================================================================"
	@if ! which wish >/dev/null ; then \
	echo "Important: Tcl/Tk not found. You should install it, or else" ; \
	echo "simulations may silently fail!  You do NOT need to rebuild " ; \
	echo "Virtual AGC after installing Tcl/Tk." ; \
	echo "================================================================" ; \
	fi
endif
endif
endif

# The following target is used only on the build-system that creates the Linux
# (presently Xubuntu 14.04 32-bit) installation tarball.  Its purpose is to look
# into all of the executables being distributed, determine what system libraries
# they use, and to pack all of those into a separate directory that can be 
# included in the installation package.  The result, I hope, is to be able to 
# run the software on any Linux system, 32-bit or 64-bit, newer than 4/2014, and
# possibly on some older ones too.  To take advantage of these libraries
# (as opposed to just being limited to whatever libraries are already installed
# on the target Linux system), one needs to run VirtualAGC as
#	cd Resources
#	LD_LIBRARY_PATH=../lib ../bin/VirtualAGC
# For 64-bit systems, it's additionally necessary to do
#	sudo apt-get install gcc-multilib
# on Debian or Ubuntu, and presumably the equivalent on Fedora, OpenSUSE, ....
#
# Although the libraries are put into a folder called lib/, I wouldn't recommend
# copying them into system directories like /lib, /usr/lib, or /usr/local/lib.
.PHONY: installationLibraries
installationLibraries: install
	mkdir ~/VirtualAGC/lib
	cp `ldd ~/VirtualAGC/bin/* | grep '=>' | sed -e 's/.*=>[[:space:]]*//' -e 's/[[:space:]]*(.*//' | sort -u` ~/VirtualAGC/lib
