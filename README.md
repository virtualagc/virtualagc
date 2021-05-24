Virtual Apollo Guidance Computer
================================

### Build status

| Travis CI (Linux) |
|--------------------------|
| [![travis-image][]][travis-site] |

[travis-image]: https://travis-ci.org/virtualagc/virtualagc.svg?branch=master
[travis-site]: https://travis-ci.org/virtualagc/virtualagc/branches

The [Apollo](https://en.wikipedia.org/wiki/Apollo_(spacecraft)) spacecraft used for lunar missions in the late 1960's and early 1970's was really two different spacecraft, the [Command Module (CM)](https://en.wikipedia.org/wiki/Apollo_command_and_service_module) and the [Lunar Module (LM)](https://en.wikipedia.org/wiki/Apollo_Lunar_Module). The CM was used to get the three astronauts to the moon, and back again. The LM was used to land two of the astronauts on the moon while the third astronaut remained in the CM, in orbit around the moon.

Each of the spacecraft needed to be able to navigate through space, with or without the assistance of the astronauts, and therefore needed to have a "guidance system". The guidance system was developed by [MIT's Instrumentation Lab](https://en.wikipedia.org/wiki/MIT_Instrumentation_Laboratory), now an independent company known as the Charles Stark Draper Laboratory.

An important part of the guidance system was the [Apollo Guidance Computer](https://en.wikipedia.org/wiki/Apollo_Guidance_Computer)—or just "AGC" for short. On any given Apollo mission, there were two AGCs, one for the Command Module, and one for the Lunar Module. The two AGCs were identical and interchangeable, but they ran different software because the tasks the spacecraft had to perform were different. Moreover, the software run by the AGC evolved over time, so that the AGC software used in later missions like [Apollo 17](https://en.wikipedia.org/wiki/Apollo_17) differed somewhat from that of earlier missions like [Apollo 8](https://en.wikipedia.org/wiki/Apollo_8).

Considered just as a computer, the AGC was severely underpowered by modern standards.

# Other Repository Branches

Since you are looking at this README file, you are in the "master" branch of the repository, which contains source-code transcriptions of the original Project Apollo software for the Apollo Guidance Computer (AGC) and [Abort Guidance System (AGS)](https://en.wikipedia.org/wiki/Apollo_Abort_Guidance_System), as well as our software for emulating the AGC, AGS, and some of their peripheral devices (such as the display-keyboard unit, or DSKY).

Other branches of the repository often contain very different files. Here are some of the more-significant branches which differ in that way from the master branch:

* **gh-pages**: HTML files and imagery for the main Virtual AGC Project website. Contains the complete website, exclusive of the large library of scanned supplementary documentation and drawings.
* **mechanical**: 2D CAD files and 3D models in DXF and STEP formats, intended to replicate the original AGC/DSKY mechanical design.
* **scenarios**: Pad loads or other setup for mission scenarios.
* **schematics**: CAD transcriptions in KiCad format of the original AGC/DSKY electrical design.
* **wiki**: Wiki files associated with the repository.

# AGC Specifications
* 2048 words of RAM. A "word" was 15 bits of data—therefore just under 2 bytes (16 bits) of data—and so the total RAM was just 3840 bytes.
* 36,864 words of read-only memory, equivalent to 69,120 bytes.
* Maximum of about 85,000 CPU instructions executed per second.
* Dimensions: 24"×12.5"×6".
* Weight: 70.1 pounds.
* Power supply: 2.5A of current at 28V DC
* Real DSKY.

It is occasionally quipped—with perhaps greater wit than insight—that the AGC was more like a calculator than a computer. But to say this is to grossly underestimate the AGC's sophistication. For example, the AGC was multi-tasking, so that it could seemingly run multiple programs simultaneously.

Another important part of the guidance system was the [Display/Keyboard unit](https://en.wikipedia.org/wiki/Apollo_Guidance_Computer#/media/File:Apollo_DSKY_interface.svg)—or just "DSKY" for short. The AGC by itself was simply a box with electrical connections, without any built-in way for the astronaut to access it. The DSKY provided the astronaut with an interface by which to access the AGC.

The Lunar Module had a single DSKY, positioned between the two astronauts where it could be operated by either of them. The Command Module actually had two DSKYs. One of the CM's DSKYs was only the main control panel, while the other was positioned near the optical equipment used to mark the positions of stars or other landmarks.

# DSKY Specifications
* Dimensions: 8"×8"×7"
* Weight: 17.5 pounds.

Perhaps the most important part of the guidance system was the [Inertial Measurement Unit](https://en.wikipedia.org/wiki/Apollo_PGNCS)—or just "IMU" for short. The IMU continuously kept track of the acceleration and rotation of the spacecraft, and reported this information back to the AGC. By mathematically processing this data, the AGC could know on a moment-by-moment basis the orientation and position of the spacecraft.

# What this project is for

This repository is associated with [the website of the Virtual AGC project](http://www.ibiblio.org/apollo), which provides a virtual machine which simulates the AGC, the DSKY, and some other portions of the guidance system. In other words, if the virtual machine—which we call yaAGC—is given the same software which was originally run by the real AGCs, and is fed the same input signals encountered by the real AGCs during Apollo missions, then it will respond in the same way as the real AGCs did. 

The Virtual AGC software is open source code so that it can be studied or modified. The repository contains the actual assembly-language source code for the AGC, for as many missions as we've been able to acquire, along with software for processing that AGC code. Principal tools are an assembler (to create executable code from the source code) and a CPU simulator (to run the executable code), as well as simulated peripherals (such as the DSKY). Similar source code and tools are provided for the very-different abort computer that resided in the Lunar Module. Finally, any supplemental software material we have been able to find or create for the Saturn rocket's [Launch Vehicle Digital Computer](https://en.wikipedia.org/wiki/Saturn_Launch_Vehicle_Digital_Computer) or for the [Gemini on-board computer (OBC)](https://en.wikipedia.org/wiki/Gemini_Guidance_Computer) are provided, though these materials are minimal at present.

Virtual AGC is a computer model of the AGC. It does not try to mimic the superficial behavioral characteristics of the AGC, but rather to model the AGC's inner workings. The result is a computer model of the AGC which is itself capable of executing the original Apollo software on (for example) a desktop PC. In computer terms, Virtual AGC is an emulator. Virtual AGC also provides an emulated Abort Guidance System (AGS) and (in the planning stages) an emulated LVDC. Virtual AGC is a catch-all term that comprises all of these.

The current version of the Virtual AGC software has been designed to work in Linux, in Windows XP/Vista/7, and in Mac OS X 10.3 or later (but 10.5 or later is best). It also works in at least some versions of FreeBSD. However, since I personally work in Linux, I have the most confidence in the Linux version.

You can read about this project in more detail here:
http://www.ibiblio.org/apollo/index.html

# What this project is not for

Virtual AGC is not a flight simulator, nor a lunar-lander simulator, nor even a behavioral simulation of the Apollo Lunar Module (LM) or Command-Module (CM) control panels. (In other words, if you expect a realistic LM control panel to suddenly appear on your computer screen, you'll be disappointed.) Virtual AGC could be used, however, as a component of such a simulation, and developers of such software are encouraged to do so. Indeed, some developers already have! See the FAQ for more information:
http://www.ibiblio.org/apollo/faq.html


# Requirements

* Tcl/Tk is required for all platforms.

## Linux

* Requires Fedora Core 4 or later.
* Requires Ubuntu 7.04 or later.
* Requires SuSE 10.1 or later.
* Known to work on Raspbian (Raspberry Pi) 2016-05-27.
* et, presumably, cetera.
* 32 and 64-bit systems have been tested successfully.
* The X-Window system, xterm, and gtk+ libraries must be installed.
* You will need the normal gcc C/C++ compiler toolchain, as well as developer packages ("dev" or "devel") for wxWidgets, ncurses and SDL.

On Fedora 22 or later you may encounter that the wxWidgets doesn't have the wx-config but the wx-config-3.0 utility as well as the wxrc-3.0 versus wxrc. Just create a symbolic link for wx-config and wxrc respectively

## Windows

* Requires XP or later. 32-bit systems have been tested successfully.
* Vista and Windows 7 may need workarounds. For example, on the Windows platform it is expected that the Tcl/Tk installation program will create a file called `wish.exe` but on Windows Vista the installation program creates a file called `wish85.exe`. This prevents certain features of Virtual AGC from working. The workaround is to duplicate the file `c:\tcl\bin\wish85.exe` and call the duplicate `c:\tcl\bin\wish.exe`.
* Windows 98 or prior are known not to work. Windows 2000 has not been tested.
* You will need the MinGW compiler with the options selected - if offered - of including g++ compiler and make.
* You will also need the Msys environment, wxWidgets 2.8.9 or above, POSIX Threads for Windows, GNU readline for Windows and the regular-expression library from MinGW called libgnurx.

## Mac OS X:

* Requires 10.4 and later for Intel or PowerPC 
* 10.2 or prior are known not to work.

## FreeBSD:

* Requires FreeBSD 7.2 or later.
* Requires PC-BSD 7.1 or later.
* You will need to install wxWidgets 2.8.9, GNU readline 6.0 into `/usr/local`.
* libSDL must be installed

## OpenSolaris

* Requires OpenSolaris 0811.
* The code is only confirmed to partially work on this platform.
* You will need SUNWgnome-common-devel, SUNWGtk, SUNWxorg-headers, FSWxorg-headers, SUNWncurses, SUNWtcl, SUNWtk and SUNWlibsdl
* You will also need GNU readline 6.0, wxWidgets 2.8.9 (with `configure --disable-shared`), Allegro 4.2.2 (with "configure --enable-shared=no --enable-static=yes") and to put `/usr/local/bin` and/or `/usr/local/bin/wx-config` linked into your `PATH`.

## WebAssembly

* Requires `clang` from the LLVM project, plus a C standard library which compiles down to WASI system calls. Clang can directly emit WebAssembly since version 8.  [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) provides a WebAssembly toolchain (clang plus C/C++ standard libraries).  A build from the source of [wasi-sdk revision a927856 ("use llvm 12.0.0 release")](https://github.com/WebAssembly/wasi-sdk/tree/a927856376271224d30c5d7732c00a0b359eaa45) has been tested with the Virtual AGC components listed in the section "WebAssembly" below, but the project also [supplies pre-built packages](https://github.com/WebAssembly/wasi-sdk/releases) for various platforms which should work just as well. In the build scripts of Virtual AGC, it is assumed that `wasi-sdk` is installed at `/opt/wasi-sdk`, but you can customize this path (see section "WebAssembly" below).
* Requires `wasm-opt` (from the `binaryen` package) for WebAssembly code optimization.
* Requires `wasm-strip` (from the `wabt` package) to minimize the size of the WebAssembly code.
* Optionally, `wasm2wat` (from the `wabt` package) to translate binary code to human-readable text representation.


More information at http://www.ibiblio.org/apollo/download.html#Build

# Building the Virtual AGC software

```
cd yaAGC
make
```

## Linux

These instructions relate specifically to building from source as of 2016-08-07 on 64-bit Linux Mint 17.3. I'm sorry to have to make them so specific, but hopefully they are easily adapted to other Linux environments. Alternate build instructions (for example, for Raspberry Pi) may be found at http://www.ibiblio.org/apollo/download.html.

You will probably have to install a variety of packages which aren't normally installed. I found that I had to install the following, which were all available from the standard software repositories (in Linux Mint, anyway):

* libsdl1.2-dev
* libncurses5-dev
* liballegro4.4-dev or liballegro4-dev
* g++
* libgtk2.0-dev
* libwxgtk2.8-dev

To build, simply `cd` into the directory containing the source and do:

`make`

Note: Do not `configure` and do not `make install`. While there is a `configure` script provided, it is presently used only for setting up builds of a couple of now-obsoleted programs, and it does not matter whether you run it or not nor whether it succeeds or fails. If the build does not complete because of a difference when comparing the `bin` files then you can rebuild with `make -k` to keep going. This however might mask other issues.

You will find that this has created a directory `VirtualAGC/temp/lVirtualAGC/`. 

To match the default setup of the installer program execute the following:

`mv yaAGC/VirtualAGC/temp/lVirtualAGC ~/VirtualAGC`

You can make a desktop icon called *Virtual AGC* that links to `VirtualAGC/bin/VirtualAGC`. The image normally used for the desktop icon is found at `VirtualAGC/bin/ApolloPatch2.png`.

If you try to use the ACA simulation (joystick) and it doesn't work you can find some information on configuring it here:
http://www.ibiblio.org/apollo/yaTelemetry.html#Joystick_configuration_for_use_with_the

## Windows

Run `Msys` to bring up a command shell and enter your home directory.

Install the SDL library with this command:

`make install-sdl prefix=/usr/local`

All software needed to build Virtual AGC will be installed under `/usr/local`, so eventually it will be populated with sub-directories such as `/usr/local/bin`, `/usr/local/include`, `/usr/local/lib`, and so on. The Virtual AGC makefiles are hard-coded to assume these installation locations. Note, the Virtual AGC binaries you are going to create are not installed under `/usr/local`.

At present, Virtual AGC binary packages are always built with wxWidgets 2.8.9, so 2.8.9 is a safe choice. Unpack the tarball in your home directory, 'cd' into the directory this creates, and then do `./configure`, `make`, and `make install`. The `configure` step will accept various command-line options that select unicode vs. ansi, static linking vs. dynamic linking, etc., but the default options seem to work fine.

Install POSIX Threads for Windows ("pthreads"). You can do this by unpacking the source tarball, 'cd' into the directory it creates, then run the command `make clean GC-inlined`. This creates various files that you should copy into `/usr/local` as follows: `copy \*.dll` into `/usr/local/bin`; copy `\*.h` into `/usr/local/include`; copy the single `libpthread\*.a` file created into `/usr/local/lib` and rename it `libpthread.a`.

Install GNU readline for Windows. You should find zipfiles of both binaries and developer files are available for download. They should both be downloaded and unpacked into `/usr/local`. (I.e., each zipfile contains directories like `bin/`, `include/`, `lib/`, and so on, and we want these to be merged into `/usr/local/bin/`, `/usr/local/include/`, etc.)

Install a regular-expression library. The MinGW project has a "contributed" regex library ("libgnurx") that you can use. Download both the `bin` and `dev` tarballs and unpack them into `/usr/local`.

If all of this was done correctly you can build the Virtual AGC as follows:

Unpack the development tarball in your home directory: 

`tar -xjvf yaAGC-dev-YYYYMMDD.tar.bz2`

Build it: 

`make -C yaAGC WIN32=yes`

On Windows 7 (but not on XP) it is also necessary to copy `c:\MinGW\bin\mingwm10.dll` to `yaAGC/VirtualAGC/temp/lVirtualAGC/Resources/`. 

This will create a directory `yaAGC/VirtualAGC/temp/lVirtualAGC/` which is the "installation directory". This directory is relocatable and need to remain within the Msys environment so you can move it wherever you like. Regardless you really need to create a desktop icon in order to run the program. The desktop icon should point to `lVirtualAGC\bin\VirtualAGC.exe` as the executable, and should use a "starting directory" of `lVirtualAGC\Resources`\. The graphic normally used for the desktop icon is `ApolloPatch2.jpg` in the `lVirtualAGC\Resources` directory.

## Mac OS X

From the command line unpack the development-snapshot tarball as follows:

`tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2`

Get the Terminator application's dmg file:
https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/jessies/terminator-26.159.6816.zip

Open the Terminator dmg file and drag the Terminator application to the working directory in which you created `yaAGC/` above.

From a command line in that working directory, make a tarball from Terminator.app:

`tar -cjvf Terminator.app.tar.bz2 Terminator.app`

Once you have the tarball, you can delete the Terminator app and its dmg file.

From the working directory (not from within the `yaAGC/` directory) build Virtual AGC:

`make -C yaAGC MACOSX=yes`


In the folder `yaAGC/VirtualAGC/temp/` you will now find the VirtualAGC application.

Drag the VirtualAGC application from `yaAGC/VirtualAGC/temp/` to the desktop.

## FreeBSD

From the command line unpack the development-snapshot tarball as follows: `tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2`

After unpacking there will be a new directory called `yaAGC`. To build the program:

`gmake FREEBSD=yes`

Do not `configure` and do not `gmake install`.

You will find that this has created a directory `yaAGC/VirtualAGC/temp/lVirtualAGC/`. 

To match the default setup of the installer program execute the following:

`mv yaAGC/VirtualAGC/temp/lVirtualAGC ~/VirtualAGC`

You can make a desktop icon called *Virtual AGC* that links to `/VirtualAGC/bin/VirtualAGC`. The image normally used for the desktop icon is found at `/VirtualAGC/bin/ApolloPatch2.png`.

If you try to use the ACA simulation (joystick) and it doesn't work you can find some information on configuring it here:
http://www.ibiblio.org/apollo/yaTelemetry.html#Joystick_configuration_for_use_with_the

## Solaris

Unpack the Virtual AGC snapshot tarball:

`tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2`

Open the `yaAGC/` directory and build:

`make SOLARIS=yes`

Do not `configure` and do not `gmake install`.

You'll find that this has created a directory `yaAGC/VirtualAGC/temp/lVirtualAGC/`. 

To match the default setup of the installer program execute the following:

`mv yaAGC/VirtualAGC/temp/lVirtualAGC ~/VirtualAGC`

You can make a desktop icon called *Virtual AGC* that links to `/VirtualAGC/bin/VirtualAGC`. The image normally used for the desktop icon is found at `/VirtualAGC/bin/ApolloPatch2.png`.

Unfortunately the ACA simulation (joystick) programs do not work in this environment.


## WebAssembly

In the Virtual AGC build scripts, it is assumed that `wasi-sdk` is installed
at `/opt/wasi-sdk`. You can customize the path by setting
`WASI_SDK_PATH=/path/to/wasi-sdk` on the command line when executing `make`.

For all builds to WebAssembly, put `WASI=yes` before `make`.

Currently, only the following Virtual AGC components can be compiled for the
WebAssembly target:

### yaAGC

If you have any leftover build artifacts in the `yaAGC` directory, run
`make clean` in it.

To build, simply `cd` into the root directory and do:

`WASI=yes make yaAGC`

This will produce `yaAGC.wasm` (about 100 kB).

To additionally get a text representation, go into the `yaAGC` directory and
run:

`make yaAGC.wast`

This will produce `yaAGC.wast` (about 900 kB).


# Endnotes

This Readme was created from information contained in the main project website here:
http://www.ibiblio.org/apollo/index.html

The project website was created by Ronald Burkey. The first version of this Readme was compiled by Shane Coughlan.

