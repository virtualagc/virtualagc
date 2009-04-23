# Copyright 2003-2007,2009 Ronald S. Burkey <info@sandroid.org>
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

# NVER is the overall version code for the release.
NVER:=\\\"20090414\\\"
DATE:=`date +%Y%m%d`

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
#NOREADLINE=yes

# Uncomment the following line (or do 'make CURSES=yes') if the build fails
# with an indication that libcurses.a is needed.
#CURSES=yes

SNAP_PREFIX = /usr/local/yaAGC

# Some adjustments for building in Solaris
ifdef SOLARIS
NOREADLINE=yes
LIBS+=-lsocket -lnsl
endif

# Some adjustments for building in Mac OS X
ifdef MACOSX
NOREADLINE=yes
ISMACOSX:=MACOSX=yes
endif

# This Mac stuff in the following conditional isn't used any longer.
ifdef OldTargetSelection
  # This upper part of the ifdef should be completely obsolete now ....
  # The following should be non-zero on Mac OS X, and 0 if not, I hope.
  # (Actually, it doesn't work in Mac OS X, for some reason, because make
  # refuses to notice the 'version' environment variable.  But you can
  # override from the command line with 'make MACVER=apple snapshot'.
  MACVER := $(strip $(shell echo hello $$version))
  MACOSTEST := $(shell echo ${MACVER} | grep -c apple)
  ifeq (${MACOSTEST},0)
    TARGETOS=linux
    WEBSITE=../sandroid.org/public_html/apollo/Downloads
  else
    TARGETOS=macosx
    WEBSITE=..
  endif
else # OldTargetSelection
  # The following stuff should have replaced all the stuff above ....
  # Detect MacOS-X build machine vs. non-MacOS-X.  Don't worry that the 
  # non-MacOS-X settings are "linux", as they will work for Win32 (Msys or CygWin)
  # also.  They're only used for the 'make snapshot' target anyhow.
  ifeq (${OSTYPE},darwin)
    TARGETOS=macosx
    MACVER=apple
    MACOSTEST=1
    WEBSITE=..
  else
    TARGETOS=linux
    MACOSTEST=0
    WEBSITE=../sandroid.org/public_html/apollo/Downloads
  endif
endif # OldTargetSelection

# GROUP is the main group to which the USER belongs.  This seems to be defined
# as an environment variable in Mac OS X, but not in Linux.  You can override this
# with a command-line assignment, but it is only used for the 'snapshot' target.
# For example, "make GROUP=wheel snapshot".  However, the default behavior should
# be okay in Linux or Mac OS X (I hope).
ifndef GROUP
GROUP = users
endif

# Note:  The default build uses no CFLAGS; this makes it easier for a user in
# the field to build it, since unexpected problems won't throw them for a loop.
# But I personally want to build with 
#	CFLAGS=-Wall -Werror
# to catch every possible problem before sending it out into the world.
ifeq (${USER},rburkey)
CFLAGS:="-Wall -Werror -DALLOW_BSUB"
yaACA:=
else 
CFLAGS="-DALLOW_BSUB"
yaACA:=-
endif

ifeq (${OSTYPE},msys)

# This is a feeble attempt to detect that the build is taking placing in an Msys
# environment within Windows.  Previously, you'd be forced to use the command
# "make -f Makefile.Win32" in Windows.

PREFIX=c:/mingw
include Makefile.Win32

else

# We assume a *nix build environment.

include Makefile.yaAGC
ifndef PREFIX
PREFIX=/usr/local
endif

.PHONY: default
default: all

.PHONY: all all-archs
all: ARCHS=default
all-archs: ARCHS=all-archs
all all-archs:
	$(MAKE) -C yaLEMAP PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS}
	$(MAKE) -C yaAGC PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} NOREADLINE=${NOREADLINE} CURSES=${CURSES} ${ARCHS} LIBS2="${LIBS}"
	${MAKE} -C yaAGS PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} NOREADLINE=${NOREADLINE} CURSES=${CURSES} ${ARCHS} LIBS2="${LIBS}"
ifndef NOGUI
ifeq "${YADEDA_SUFFIX}" ""
	$(MAKE) -C yaDEDA/src -f Makefile.all-archs PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	-${MAKE} -C yaDEDA2 NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
else
	-$(MAKE) -C yaDEDA/src -f Makefile.all-archs PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	${MAKE} -C yaDEDA2 NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
endif
ifeq "${YADSKY_SUFFIX}" ""
	$(MAKE) -C yaDSKY/src -f Makefile.all-archs PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	cp yaDSKY/src/yadsky yaDSKY/src/yaDSKY
	-${MAKE} -C yaDSKY2 NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
else
	-$(MAKE) -C yaDSKY/src -f Makefile.all-archs PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	-cp yaDSKY/src/yadsky yaDSKY/src/yaDSKY
	${MAKE} -C yaDSKY2 NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
endif	
endif
	$(MAKE) -C yaYUL PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS}
	$(MAKE) -C yaUniverse PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	${yaACA}${MAKE} -C yaACA2 NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	${yaACA}$(MAKE) -C yaACA PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	${yaACA}${MAKE} -C yaACA3 NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	$(MAKE) -C Luminary131 PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS}
	$(MAKE) -C Colossus249 PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS}
	${MAKE} -C Artemis072 PREFIX=${PREFIX} NVER=${NVER}
	$(MAKE) -C Validation PREFIX=${PREFIX} NVER=${NVER} CFLAGS=${CFLAGS}
	$(MAKE) -C ControlPulseSim NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS}
	${MAKE} -C yaTelemetry NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} LIBS2="${LIBS}"
	${MAKE} -C jWiz NVER=${NVER} CFLAGS=${CFLAGS} ${ARCHS} ${ISMACOSX}
	${MAKE} -C VirtualAGC NVER=${NVER} "YADSKY_SUFFIX=${YADSKY_SUFFIX}" "YADEDA_SUFFIX=${YADEDA_SUFFIX}" clean ${ARCHS} LIBS2="${LIBS}" ${ISMACOSX}

# Here's a target for updating the website.
.PHONY: snapshot
snapshot: dev binaries

.PHONY: binaries
binaries: clean all-archs
	cp -a VirtualAGC/VirtualAGC-installer ${WEBSITE}
	cp -a VirtualAGC/VirtualAGC-setup.exe ${WEBSITE}
	cp -a VirtualAGC/VirtualAGC.app.tar.gz ${WEBSITE}
	ls -ltr ${WEBSITE}

# I used this only for creating a development snapshot.  It's no use to anybody
# else, I expect.
.PHONY: dev
dev:	clean
	-rm ${WEBSITE}/yaAGC-dev-${DATE}.tar.bz2
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
		--exclude=*xvpics* \
		--bzip2 -cvf ${WEBSITE}/yaAGC-dev-${DATE}.tar.bz2 yaAGC
	ls -ltr ${WEBSITE}
		
snapshot-ephemeris:
	cd .. ; tar --bzip2 -cvf ${WEBSITE}/yaAGC-ephemeris.tar.bz2 yaAGC/yaUniverse/*.txt
	ls -l ${WEBSITE}/

clean:
	#echo PREFIX=/usr/local >Makefile.yAGC
	$(MAKE) -C yaLEMAP clean
	$(MAKE) -C yaAGC clean
	$(MAKE) -C yaAGS clean
	-$(MAKE) -C yaDSKY/src -f Makefile.all-archs clean
	-rm yaDSKY/src/yaDSKY
	-$(MAKE) -C yaDEDA/src -f Makefile.all-archs clean
	$(MAKE) -C yaYUL clean
	$(MAKE) -C yaUniverse clean
	${yaACA}$(MAKE) -C yaACA clean
	${yaACA}${MAKE} -C yaACA2 clean
	${yaACA}$(MAKE) -C yaACA3 clean
	$(MAKE) -C Luminary131 clean
	$(MAKE) -C Colossus249 clean
	${MAKE} -C Artemis072 clean
	$(MAKE) -C Validation clean
	${MAKE} -C ControlPulseSim clean
	${MAKE} -C VirtualAGC clean
	${MAKE} -C yaTelemetry clean
	${MAKE} -C jWiz clean
	-${MAKE} -C yaDSKY2 clean
	-${MAKE} -C yaDEDA2 clean
	-${MAKE} -C yaACA2 clean
	-rm `find . -name "core"`

install: all
	-mkdir ${PREFIX}
	-mkdir ${PREFIX}/bin
	-rm ${PREFIX}/bin/VirtualAgcFileStart
	echo hello >${PREFIX}/bin/VirtualAgcFileStart
	sleep 2
	cp ControlPulseSim/ControlPulseSim ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/ControlPulseSim
	$(MAKE) -C yaLEMAP PREFIX=${PREFIX} install
	$(MAKE) -C yaAGC PREFIX=${PREFIX} install NOREADLINE=${NOREADLINE} CURSES=${CURSES}
	$(MAKE) -C yaAGS PREFIX=${PREFIX} install NOREADLINE=${NOREADLINE} CURSES=${CURSES}
	$(MAKE) -C yaYUL PREFIX=${PREFIX} install
	$(MAKE) -C yaUniverse PREFIX=${PREFIX} install
	${yaACA}$(MAKE) -C yaACA PREFIX=${PREFIX} install
	$(MAKE) -C Luminary131 PREFIX=${PREFIX} install
	$(MAKE) -C Colossus249 PREFIX=${PREFIX} install
	${MAKE} -C Artemis072 PREFIX=${PREFIX} install
	$(MAKE) -C Validation PREFIX=${PREFIX} install
	cp yaDSKY/src/*.ini ${PREFIX}/bin
	chmod ugo+r ${PREFIX}/bin/LM*.ini
	chmod ugo+r ${PREFIX}/bin/CM*.ini
ifndef NOGUI
ifeq "${YADSKY_SUFFIX}"	""
	-rm ${PREFIX}/bin/yaDSKY
	$(MAKE) -C yaDSKY PREFIX=${PREFIX} install
	-ln ${PREFIX}/bin/yadsky ${PREFIX}/bin/yaDSKY
endif	
ifeq "${YADEDA_SUFFIX}"	""
	$(MAKE) -C yaDEDA PREFIX=${PREFIX} install
endif	
endif
	cp Sim* ${PREFIX}/bin
	chmod ugo+rx ${PREFIX}/bin/Sim*
	cp Contributed/LM_Simulator/*.tcl Contributed/LM_Simulator/*.ini ${PREFIX}/bin
	cp -R Contributed/LM_Simulator/modules ${PREFIX}/bin
	echo cd ${PREFIX}/bin >${PREFIX}/bin/LM_Simulator
	echo wish lm_simulator.tcl '$$1' '$$2' '$$3' >>${PREFIX}/bin/LM_Simulator
	chmod ugo+x ${PREFIX}/bin/LM_Simulator
	-rm ${PREFIX}/bin/VirtualAgcFileList
	-rm ${PREFIX}/bin/VirtualAgcUninstall
	find ${PREFIX}/bin -cnewer ${PREFIX}/bin/VirtualAgcFileStart >${PREFIX}/bin/VirtualAgcFileList
	echo rm `cat ${PREFIX}/bin/VirtualAgcFileList` >>${PREFIX}/bin/VirtualAgcUninstall
	echo rm -rf ${PREFIX}/share/yaDEDA >>${PREFIX}/bin/VirtualAgcUninstall
	echo rm -rf ${PREFIX}/share/yadsky >>${PREFIX}/bin/VirtualAgcUninstall
	echo rm -rf ${PREFIX}/bin/modules >>${PREFIX}/bin/VirtualAgcUninstall
	echo rm ${PREFIX}/bin/VirtualAgcFileStart >>${PREFIX}/bin/VirtualAgcUninstall
	echo rm ${PREFIX}/bin/VirtualAgcUninstall >>${PREFIX}/bin/VirtualAgcUninstall
	chmod ugo+x ${PREFIX}/bin/VirtualAgcUninstall
	
autogen:
	echo PREFIX=${PREFIX} >Makefile.yaAGC
ifndef NOGUI
	cd yaDSKY && ./autogen.sh --prefix=${PREFIX}
	cd yaDEDA && ./autogen.sh --prefix=${PREFIX}
endif

# Build the yaAGC-os-DATECODE.tar.bz2 snapshot	
os:
	@echo Target OS is $(TARGETOS) \(${MACVER}\)
	./configure --prefix=${SNAP_PREFIX}
	make
	sudo make install
	sudo tar --directory=/ --bzip2 -cf ${WEBSITE}/yaAGC-${TARGETOS}-${DATE}.tar.bz2 ${SNAP_PREFIX}
	sudo chown ${USER}:${GROUP} ${WEBSITE}/yaAGC-${TARGETOS}-${DATE}.tar.bz2
	sudo rm -rf ${SNAP_PREFIX}
ifeq (${MACOSTEST},0)	
	ls -l ${WEBSITE}/*.bz2 -t -r
else
	scp -p ${WEBSITE}/yaAGC-${TARGETOS}-${DATE}.tar.bz2 \
		rburkey@192.168.254.250:Projects/sandroid.org/public_html/apollo/Downloads
endif	

# Build the yaAGC-dev-DATECODE.tar.bz2 snapshot	
#dev:
#	make clean
#	tar --directory=.. --exclude="*.core" --exclude="yaAGC/.snprj" --exclude="*/CVS" --bzip2 -cf ${WEBSITE}/yaAGC-dev-${DATE}.tar.bz2 yaAGC
#	ls -l ${WEBSITE}/*.bz2 -t -r
	
# Build both types of snapshots.
#snapshot: os dev
	
endif

