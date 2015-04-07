![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)
# Building Virtual AGC Targets #

First obtain get a working copy of the sources from the Source tab.

## 1 Building for Linux ##

### 1.1 Linux Prerequisites ###
The following software packages are required:
  * gcc
  * pkg-config
  * autoconf
  * automake
  * glib-dev
  * libgtk, libgtk-dev (version 2.0 or higher)
  * readline-devel, (either curses or ncurses)
  * Allegro

### 1.2 Build Linux Software ###
To build the software change your active working directory to the location where you placed the virtualagc files ( e.g. cd 

&lt;path&gt;

/virtualagc ). From there execute the following four commands to consecutively configure your build environment, remove all the previous targets, build the new targets and install them (default: /usr/local). To change this install location use the --prefix=

&lt;InstallDirectory&gt;

 as an argument to the configure script.
```
configure
make clean
make
sudo make install
```

## 2 Building for Win32 ##

### 2.1 Win32 Prerequisites ###
To build under windows an extensive list of packages needs to be installed in order to build the simulation tools yaDEDA and yaDSKY. The gtk+ binaries and development packages can be downloaded from [The GTK+ Project](http://www.gtk.org/). If you are just interested in building the yaAGC, yaAGS and other command line tools then you do not need all gtk+ packages but you still need [POSIX Threads](http://sources.redhat.com/pthreads-win32) for Win32, the [GNU Readline](http://gnuwin32.sourceforge.net/packages/readline.htm) for Win32 library and the GNU Compiler tool set [MinGW](http://www.mingw.org/) with a basic set of UNIX tools packaged as MSYS (also hosted on the MinGW site). The following is a list of all packages that will enable a full Win32 build:

  * MinGW GNU compiler toolset
  * MSYS Base System
  * ATK Binaries and Dev packages
  * cairo Binaries and Dev packges
  * gettext-runtime Binaries and Dev packages
  * GLib Binaries and Dev packages
  * GTK+ Binaries and Dev packages
  * jpeg Binaries and Dev packages
  * GNU libiconv Binaries,Dev and DLL packages
  * libpng Binaries and Dev packages
  * Pango Binaries and Dev packages
  * pkg-config Tool binaries
  * tiff Binaries and Dev packages
  * Zlib Binaries and Dev packages
  * Readline Binaries
  * pthreads-win32 package

### 2.2 Win32 Setup ###
First install MinGW in its default location (i.e. C:\MinGW). Then install MSYS in its default location and make it aware of the MinGW location (as requested during install). Extract all the GTK+ packages to the MinGW as well as the readline package. From the pthreads library make sure to copy the shared libraries files (i.e. .dll) into the bin directory of MinGW and the header files (i.e. .h )and library (i.e. .a) into respectively the include and lib folder of MinGW. If the installers haven't done so make sure both the MinGW and MSYS bin directories are added to your search path.

### 2.3 Build Win32 Software ###
Change directory into the root of the virtualagc project sources and type:
```
make -f Makefile.Win32 all
make -f Makefile.Win32 install
```