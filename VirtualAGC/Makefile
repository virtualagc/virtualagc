# Copyright 2009,2016,2017 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of.
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:	Makefile
# Purpose:	This makefile is used to build the GUI-frontend program
#		called VirtualAGC.
# Mods:		2009-03-03 RSB	Wrote.
#		2009-03-13 RSB	Provisions for yaDSKY2 and yaDEDA2.
#		2009-03-14 RSB	For Mac OS, put yaDSKY, yaDEDA, yaDSK2,
#				yaDEDA2, and yaTelemetry into app bundles.
#				This doesn't seem to be necessary in 10.5,
#				but in 10.4 these apps don't respond to 
#				events otherwise.
#		2009-03-25 RSB	On Windows, replace VirtualAGC.zip with
#				VirtualAGC-setup.exe built by InstallJammer.
#		2009-03-26 RSB	On Linux, replaced VirtualAGC.tar.bz2 with
#				VirtualAGC-installer built by InstallJammer.
#				Actually, this is done only for USER rburkey.
#				For anyone else, you're simply left with the
#				installation directory rather than any tarball
#				or installer program created from it afterward,
#				since nobody else is likely to need to 
#				distribute it beyond the build computer.
#		2009-04-11 RSB	Tweaking Mac OS X packages.  Added Terminator
#				on Mac OS X.
#		2009-04-14 RSB	Made some provisions for building in Mac OS X.
#               2009-04-21 OH   Add NATIVE build capability.
#		2009-04-25 RSB	Reverted to prior version.  Added an adjustment
#				via 'sed' to convert the directories used by
#				InstallJammer from */VirtualAGC/temp/... to
#				`pwd`/temp/....  I hadn't realized that the
#				name of my home directory was embedded in the
#				mpi files, and that would have prevented anyone
#				else from creating InstallJammer based 
#				installers.  The present change fixes that
#				by dynamically fixing the mpi files at compile
#				time.  Fixed up for Win32 readline.
#		2009-05-02 RSB	Added DEV_SNAP.
#		2009-05-23 RSB	Added Comanche055.
#		2009-06-01 RSB	The wrong value was being passed to the 
#				CopyApolloSource.sh script's third parameter.
#				Thanks to Onno Hommes for noticing this.  Also
#				added a 4th parameter for Windows vs. non-Windows.
#		2009-06-07 RSB	Added Luminary099.
#		2009-07-02 RSB	Added SyntaxHighlight stuff to the binary installers.
#		2009-08-01 RSB	Putting readline5.dll into the installation 
#				directory is now non-fatal if the dll doesn't 
#				exist, which it wouldn't if readline was built
#				static-only.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-07-17 RSB	Added -lX11 to the VirtualAGC target.
#		2016-08-01 RSB	At least for now, building the installers has been
#				commented out.  Perhaps I'll restore it later.
#		2016-08-06 RSB  A number of programs have previously been set
#				This had been set to build statically-linked
#				for USERNAME=rburkey (me!) and dynamically-linked
#				for everyone else, for the purpose of making it 
#				easier to create installers.  I am in the process
#				of changing all such Linux executables that use
#				agc_utilities.c to be always dynamically-linked,
#				because with newer system libraries, some portions
#				of agc_utilities.c doesn't work when statically 
#				linked.  These changes affect nobody else's builds
#				except mine, and only affect the Linux versions of
#				the executables.
#		2016-08-07 RSB	The Validation "mission" was missing.
#		2016-08-28 RSB	Activated Solarium055 mission.
#		2016-11-07 RSB	Added the Aurora12 and Sunburst120 missions,
#				but also made it so that the MISSIONS 
#				environment variable is assign herein only if
#				it doesn't previously exists.
#		2016-11-16 RSB	Certain resources needed only by the "standard"
#				32-bit Linux VirtualAGC VM I'm now creating are
#				added to the installation bundle.  These are
#				related to debugging on Code::blocks. 
#		2016-11-29 RSB	Fixed formation of .app sub-directories for Mac.
#		2017-08-24 RSB	Added wxFLAGS.
#		2017-12-11 RSB	Added yaDSKY2/*.canned files.
#		2025-03-03 RSB	Accounted for ddd-*.tsv files in Resources/
#		2025-04-03 RSB	Same for yaTelemetry/documentation/.
#		2025-04-20 RSB	And tsv/documentation files in piPeripheral/.

APP=VirtualAGC
# *** BEWARE! ***  The MISSIONS variable is normally inherited from the 
# top-level Makefile, so don't assume you can add missions here!
ifndef MISSIONS
MISSIONS=Colossus249 Luminary131 Artemis072 Validation FP6 FP8 Comanche055
MISSIONS+=Luminary099 Colossus237 Validation Solarium055 Aurora12 Sunburst120
else
MISSIONS+=FP6 FP8
endif

# For cross-platform building --- i.e., for building Win32 and Mac OS X versions
# of VirtualAGC on a Linux platform --- it is assumed that the IMCROSS
# environment (www.sandroid.org/imcross) is installed.  It is further supposed
# that the IMCROSS installation directory is ~/IMCROSS and that ~/IMCROSS/bin 
# is in the PATH.  The following variables just reflect the default setup for
# IMCROSS.
PREFIX_WIN=i386-mingw32
PREFIX_MAC=powerpc-apple-darwin9
BIN_WIN=${HOME}/IMCROSS/i386-mingw32/bin
BIN_MAC=${HOME}/IMCROSS/mac/bin
INC_MAC=${HOME}/IMCROSS/mac/include
SDK_MAC=${HOME}/IMCROSS/mac/SDKs/MacOSX10.4u.sdk
JAMMER_DIR=${HOME}/IMCROSS/installjammer

PLATFORM=
ifdef WIN32
PLATFORM+=-DWIN32=yes
endif
ifdef MACOSX
PLATFORM+=-DMACOSX=yes
endif
ifdef FREEBSD
PLATFORM+=-DFREEBSD=yes
endif
ifdef SOLARIS
PLATFORM+=-DSOLARIS=yes
endif

# cp and sed work slightly differently on Mac OS X than elsewhere.
INPLACE=-i~
CP=cp
CP+=${EXTSW}

ifeq "${YADSKY_SUFFIX}" ""
YADSKY2=
else
YADSKY2=-DYADSKY2
endif
ifeq "${YADEDA_SUFFIX}" ""
YADEDA2=
else
YADEDA2=-DYADEDA2
endif

# This is used only for Mac OS, and can be overridden from the command line
# of the Makefile:
ifndef AGC_SCALE
AGC_SCALE=1.0
endif

# This is just so that when I build it, I can insure that it will be statically or
# dynamically linked in the binary installers, according to my current whims.
# For anybody else, it will just accept whatever your wxWidgets default library is.
ifeq "${USER}" "rburkey"
ifdef DEV_STATIC
WXSTATIC=--static
else
EXTRA_WIN_LIBS=-lwsock32
endif
endif

ifndef WIN32
LIBS2+=-lX11
endif

.PHONY: default
default: Linux

.PHONY: all-archs
all-archs: Linux Win32 MacOsX

.PHONY: Linux
ifdef MACOSX
Linux: temp/VirtualAGC.app
else
Linux: temp/lVirtualAGC
endif

.PHONY: Win32
Win32: VirtualAGC-setup.exe

.PHONY: MacOsX
MacOsX: VirtualAGC.app.tar.gz

.PHONY: clean
clean:
	rm -rf temp
	rm -f *~ *.bak VirtualAGC *.exe *-macosx VirtualAGC-installer
	rm -f VirtualAGC.app.tar.gz VirtualAGC.tar.bz2 VirtualAGC.zip
	rm -rf VirtualAGC-win32/output
	rm -rf VirtualAGC-win32/build
	rm -f VirtualAGC-win32/build.log
	rm -f VirtualAGC-win32/temp.mpi
	rm -rf VirtualAGC-linux/output
	rm -rf VirtualAGC-linux/build
	rm -f VirtualAGC-linux/build.log
	rm -f VirtualAGC-linux/temp.mpi

SOURCES:=${APP}.cpp
SOURCESc:=\
	../yaAGC/agc_utilities.c \
	../yaAGC/DecodeDigitalDownlink.c \
	../yaAGC/agc_engine.c \
	../yaAGC/Backtrace.c \
	../yaAGC/random.c \
	../yaAGC/SocketAPI.c

HEADERS:=${APP}.h

${APP}: ${SOURCES} ${SOURCESc} ${HEADERS}
	${CC} -DONNO_STYLE ${PLATFORM} \
		${YADSKY2} ${YADEDA2} \
		`wx-config --cxxflags` ${wxFLAGS} \
		-o $@ ${SOURCES} ${DASHX} ${SOURCESc} \
		`wx-config --libs` \
		${LIBS2}
	strip $@${EXT}

${APP}.exe: ${SOURCES} ${SOURCESc} ${HEADERS}
	${PREFIX_WIN}-${CC} -DONNO_STYLE \
		${YADSKY2} ${YADEDA2} \
		`${BIN_WIN}/wx-config ${WXSTATIC} --cxxflags` \
		-o $@ ${SOURCES} ${DASHX} ${SOURCESc} \
		`${BIN_WIN}/wx-config ${WXSTATIC} --libs` \
		${EXTRA_WIN_LIBS}
	${PREFIX_WIN}-strip $@

${APP}-macosx: ${SOURCES} ${SOURCESc} ${HEADERS}
	${PREFIX_MAC}-${CC} -DONNO_STYLE \
		${YADSKY2} ${YADEDA2} \
		-arch ppc -arch i386 -I${INC_MAC} -isysroot ${SDK_MAC} \
		`${BIN_MAC}/wx-config ${WXSTATIC} --cxxflags` \
		-o $@ ${SOURCES} ${DASHX} ${SOURCESc} \
		`${BIN_MAC}/wx-config ${WXSTATIC} --libs`
	${PREFIX_MAC}-strip $@

temp/lVirtualAGC/bin temp/VirtualAGC/bin temp/VirtualAGC.app/Contents/MacOS:
	mkdir -p $@

# This target creates a Resources directory for any of the installation
# packages.  Except for gtk+ related stuff, none of the contents of the
# Resources directory vary by target.  This target assumes that the associated
# bin directory has already been populated.
.PHONY: temp/lVirtualAGC/Resources
temp/lVirtualAGC/Resources temp/VirtualAGC/Resources temp/VirtualAGC.app/Contents/Resources:
	mkdir -p $@/pixmaps $@/source
	${CP} ../scenarios $@
	for n in ${MISSIONS}; do \
		sh ./CopyApolloSource.sh $@ $$n ${EXTSW} ${WIN32} ;\
	done
	${CP} *.png *.ico $@
	${CP} ../yaDSKY/src/*.ini $@
ifeq "${YADSKY_SUFFIX}" ""	
	${CP} ../yaDSKY/pixmaps $@/pixmaps/yaDSKY
else
	${CP} ../yaDSKY2/*.jpg $@
	${CP} ../yaDSKY2/*.canned $@
endif	
	-rm -rf $@/pixmaps/yaDSKY/CVS $@/pixmaps/yaDSKY/.xvpics
ifeq "${YADEDA_SUFFIX}" ""	
	${CP} ../yaDEDA/pixmaps $@/pixmaps/yaDEDA
else
	${CP} ../yaDEDA2/*.xpm $@
endif
	${CP} ../yaDSKYb1/images $@/images-yaDSKYb1
	-rm -rf $@/images-yaDSKYb1/CVS $@/images-yaDSKYb1/.xvpics
	${CP} ../jWiz/*.jpg $@
	-rm -rf $@/pixmaps/yaDEDA/CVS $@/pixmaps/yaDEDA/.xvpics
	${CP} ../piPeripheral/ddd-*.tsv $@
	${CP} ../piPeripheral/documentation $@
	${CP} ../yaTelemetry/*.jpg ../yaAGC/ddd-*.tsv $@
	${CP} ../yaTelemetry/documentation $@
	${CP} ../Contributed/LM_Simulator $@
	${CP} VirtualAGC.tcl $@
	-rm -rf $@/LM_Simulator/CVS
	-rm -rf $@/LM_Simulator/modules/CVS
	-rm -rf $@/LM_Simulator/doc/CVS
	-rm -rf $@/LM_Simulator/Documentation/CVS
	${CP} template.app/Contents/Resources/VirtualAGC.icns $@
ifeq "${EXT}" ".exe"
# Copy DLLs.
ifdef IGNORE_THIS
	${CP} /usr/local/bin/SDL.dll $@
	# Very old usage.
	#for n in history pthread readline libgnurx ; \
	#do \
	#	${CP} /usr/local/bin/$$n*.dll $@ ; \
	#done
	# Newer usage (2016-11-19)
	for n in 1.0 ncurses regex ; \
	do \
		${CP} /usr/bin/msys-$$n*.dll $@ ; \
	done
	for n in wxbase28u_gcc_custom wxmsw28u_core_gcc_custom; \
	do \
		${CP} /usr/local/lib/$$n.dll $@ ; \
	done
	for n in libgcc_s_dw2-1 libstdc++-6 pthreadGC-3 ; \
	do \
		${CP} c:/mingw/bin/$$n.dll $@ ; \
	done
else # of IGNORE_THIS. Do this instead:
	echo 'start /b ..\bin\VirtualAGC.exe' >$@/VirtualAGC.bat
	for n in ../bin/*.exe ; do ldd $$n ; done | egrep 'ucrt64|home' | awk '{print $$3}' | sort -u | xargs -i cp {} $@
endif # of IGNORE_THIS
endif # of EXT == .exe
	${CP} ../Contributed/SyntaxHighlight $@
	rm -rf `find $@/SyntaxHighlight -name ".svn"`

# The targets below create a bin directory for the distribution
# packages.  All of the contents of the bin directory vary by
# target architecture.

EXECUTABLES:=\
	VirtualAGC \
	../yaAGC/yaAGC \
	../yaAGS/yaAGS \
	../yaACA3/yaACA3 \
	../yaYUL/yaYUL \
	../Tools/listing2binsource \
	../Tools/oct2bin \
	../Tools/bdiffhead \
	../Tools/checkdec \
	../Tools/webb2burkey-rope \
	../yaLEMAP/yaLEMAP \
	../yaLEMAP/binLEMAP \
	../yaUniverse/yaUniverse \
	../ControlPulseSim/ControlPulseSim \
	../yaTelemetry/yaTelemetry \
	../jWiz/jWiz \
	../yaAGCb1/yaAGCb1 \
	../yaAGC-Block1-Pultorak/yaAGC-Block1 \
	../yaDSKYb1/yaDSKYb1 \
	../yaUplinkBlock1/yaUplinkBlock1
ifeq "${YADSKY_SUFFIX}" ""
EXECUTABLES+=../yaDSKY/src/yaDSKY
else
EXECUTABLES+=../yaDSKY2/yaDSKY2
endif
ifeq "${YADEDA_SUFFIX}" ""
EXECUTABLES+=../yaDEDA/src/yaDEDA
else
EXECUTABLES+=../yaDEDA2/yaDEDA2
endif
ifeq "${EXT}" ".exe"
EXECUTABLES+=../yaAGC/WinAGC
endif

temp/lVirtualAGC : % : VirtualAGC %/bin %/Resources
	for n in ${EXECUTABLES} ; \
	do \
		${CP} $$n${EXT} $@/bin ; \
	done
	-${CP} ../yaACA/yaACA${EXT} ../yaACA2/yaACA2${EXT} $@/bin
	for n in $@/bin/* ; do strip $$n ; done
	cp ApolloPatch2-transparent.png $@/bin/ApolloPatch2.png
	${CP} ../scripts/SimStop $@/bin
	chmod +x $@/bin/SimStop
	-mkdir -p $@/Resources/source
	cp ../Makefile.inc $@/Resources/source
	-mkdir -p $@/Resources/source/yaYUL
	-mkdir -p $@/Resources/source/Tools
	cp ../yaYUL/yaYUL${EXT} $@/Resources/source/yaYUL
	cp ../Tools/oct2bin${EXT} $@/Resources/source/Tools

temp/VirtualAGC : % : VirtualAGC.exe %/bin %/Resources
	for n in ${EXECUTABLES} ../yaAGC/WinAGC ; do cp $$n.exe $@/bin ; done
	#-${CP} ../yaACA/yaACA.exe ../yaACA/yaACA-cfg.exe $@/bin
	${CP} ../yaACA2/yaACA2.exe $@/bin
	cp VirtualAGC-win32/ApolloPatch2.ico $@/bin
	for n in $@/bin/* ; do i386-mingw32-strip $$n ; done
ifeq "$YADSKY2" ""	
	cp ${HOME}/IMCROSS/i386-mingw32/bin/*.dll $@/Resources
endif
ifeq "$YADEDA2" ""	
	cp ${HOME}/IMCROSS/i386-mingw32/bin/*.dll $@/Resources
endif
	-cp ${HOME}/IMCROSS/i386-mingw32/bin/readline5.dll $@/Resources
	-mkdir $@/Resources/etc
	${CP} ${HOME}/IMCROSS/i386-mingw32/etc/gtk-2.0 $@/Resources/etc

.PHONY: create-bundle
create-bundle:
	-rm -rf temp/VirtualAGC.app
	mkdir -p temp/VirtualAGC.app/Contents
	sed "s@<string>1.0</string>@<string>$(AGC_SCALE)</string>@" \
	    template.app/Contents/Info.plist \
	    >temp/VirtualAGC.app/Contents/Info.plist

# The Mac application tarball requires a file called Terminator.app.tar.bz2 in the 
# parent directory of yaAGC.  This file is obtained by downloading terminator.dmg
# from http://software.jessies.org/terminator/, installing it in Mac OS X to 
# create Terminator.app, and then making a tarball from Terminator.app.  Since the
# binary is not changed from what the supplier provides, the GPL requires merely
# that I provide a link to the source tarball at the supplier's site.
ifndef MACOSX
# Come here if the build machine is not Mac OS X and this is being cross-compiled.

temp/VirtualAGC.app : % : VirtualAGC-macosx create-bundle %/Contents/MacOS %/Contents/Resources
	for n in ${EXECUTABLES} ; do ${CP} $$n-macosx $@/Contents/MacOS ; done
	-${CP} ../yaACA/yaACA-macosx $@/Contents/MacOS
	cd $@/Contents/MacOS ; \
	for n in *-macosx ; \
	do \
		mv $$n `echo $$n | sed "s/-macosx//"` ; \
	done
	tar -C $@/Contents/MacOS -xjf ../../Terminator.app.tar.bz2
	for n in yaDSKY2 yaDEDA2 yaTelemetry jWiz yaDSKYb1 ; \
	do \
	  ${CP} template.app $@/Contents/MacOS/$$n.app ; \
	  mv $@/Contents/MacOS/$$n.app/Contents/Resources/VirtualAGC.icns $@/Contents/MacOS/$$n.app/Contents/Resources/$$n.icns ; \
	  sed ${INPLACE} "s/VirtualAGC/$$n/" $@/Contents/MacOS/$$n.app/Contents/Info.plist ; \
	  mv $@/Contents/MacOS/$$n $@/Contents/MacOS/$$n.app/Contents/MacOS ; \
	done
	${CP} ../scripts/SimStop $@/Contents/MacOS
	chmod +x $@/Contents/MacOS/SimStop
ifeq "$YADSKY2" ""	
	-${CP} ${HOME}/IMCROSS/mac/lib/*.dylib $@/Contents/MacOS
endif
ifeq "$YADEDA2" ""	
	-${CP} ${HOME}/IMCROSS/mac/lib/*.dylib $@/Contents/MacOS
endif

else # MACOSX
# Come here if the build machine is Mac OS X.

temp/VirtualAGC.app : % : VirtualAGC create-bundle %/Contents/MacOS %/Contents/Resources
	for n in ${EXECUTABLES} ; do ${CP} $$n $@/Contents/MacOS ; done
	-tar -C $@/Contents/MacOS -xjf ../../Terminator.app.tar.bz2
	for n in yaDSKY2 yaDEDA2 yaTelemetry jWiz yaDSKYb1 ; \
	do \
	  ${CP} template.app $@/Contents/MacOS/$$n.app ; \
	  mv $@/Contents/MacOS/$$n.app/Contents/Resources/VirtualAGC.icns $@/Contents/MacOS/$$n.app/Contents/Resources/$$n.icns ; \
	  sed ${INPLACE} "s/VirtualAGC/$$n/" $@/Contents/MacOS/$$n.app/Contents/Info.plist ; \
	  mv $@/Contents/MacOS/$$n $@/Contents/MacOS/$$n.app/Contents/MacOS ; \
	done
	mv $@/Contents/Resources/documentation $@/Contents/MacOS/yaTelemetry.app/Contents/Resources
	${CP} ../scripts/SimStop $@/Contents/MacOS
	chmod +x $@/Contents/MacOS/SimStop
ifeq "$YADSKY2" ""	
	-${CP} ${HOME}/IMCROSS/mac/lib/*.dylib $@/Contents/MacOS
endif
ifeq "$YADEDA2" ""	
	-${CP} ${HOME}/IMCROSS/mac/lib/*.dylib $@/Contents/MacOS
endif

endif # MACOSX

# No longer used.  Replaced by VirtualAGC-installer
VirtualAGC.tar.bz2: temp/lVirtualAGC
	tar -C temp -cjf $@ lVirtualAGC

CURDIR:=$(shell pwd)
VirtualAGC-installer: temp/lVirtualAGC
	sed "s/APPLICATION_VERSION/${NVER}/;s@/home/.*/VirtualAGC/temp/@${CURDIR}/temp/@" \
		VirtualAGC-linux/VirtualAGC-linux.mpi \
		>VirtualAGC-linux/temp.mpi
	cd VirtualAGC-linux && \
	${JAMMER_DIR}/installjammer --build temp.mpi
	cp -p VirtualAGC-linux/output/Virtual* $@
	rm -rf VirtualAGC-linux/build VirtualAGC-linux/output

# No longer used.  Replaced by VirtualAGC-setup.exe
VirtualAGC.zip: temp/VirtualAGC
	cd temp && zip -r ../$@ VirtualAGC

VirtualAGC-setup.exe: temp/VirtualAGC
	sed "s/APPLICATION_VERSION/${NVER}/;s@/home/.*/VirtualAGC/temp/@${CURDIR}/temp/@" \
		VirtualAGC-win32/VirtualAGC-win32.mpi \
		>VirtualAGC-win32/temp.mpi
	cd VirtualAGC-win32 && \
	${JAMMER_DIR}/installjammer --build temp.mpi
	cp -p VirtualAGC-win32/output/*-Setup.exe $@
	rm -rf VirtualAGC-win32/build VirtualAGC-win32/output

VirtualAGC.app.tar.gz: temp/VirtualAGC.app
	tar -C temp --exclude=*.svn* -czf $@ VirtualAGC.app

