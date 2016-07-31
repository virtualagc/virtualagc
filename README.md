Virtual Apollo Guidance Computer | 虛擬阿波羅號指引計算機
================================

在上世紀60年代末期到70年代初期, 用於登月計畫的阿波羅載人航天飛船, 實際上是由兩艘不同的艙體所組成. 分別是駕駛艙 (CM) 和登月艙 (LM). 駕駛艙用於載送三位宇航員往返月球, 而登月艙則是用於其中兩位宇航員的登月過程. 另外的一位則會呆在月球軌道上的駕駛艙中.

The Apollo spacecraft used for lunar missions in the late 1960's and early 1970's was really two different spacecraft, the Command Module (CM) and the Lunar Module (LM).  The CM was used to get the three astronauts to the moon, and back again.  The LM was used to land two of the astronauts on the moon while the third astronaut remained in the CM, in orbit around the moon.

每一個艙體都會有一個 "指引系統", 使得它們不管在有沒有宇航員的幫助情況下, 都能在太空中導航. 該指引系統是由 MIT 的儀器實驗室所進行開發. 該實驗室目前已成為大家所熟知的一家獨立公司, 德拉普尔实验室.

Each of the spacecraft needed to be able to navigate through space, with or without the assistance of the astronauts, and therefore needed to have a "guidance system".  The guidance system was developed by MIT's Instrumentation Lab, now an independent company known as the Charles Stark Draper Laboratory.

指引系统其中一個重要的部分是阿波羅指引計算機 - 或簡稱"AGC". 在每一次阿波羅計畫所給出的任務中, 都會有那麼兩台 AGC, 一台用於駕駛艙, 而另一台則用於登月艙. 雖然, 兩台 AGC 完全相同且可互換. 但是, 它們會因為艙體所執行的任務不同, 而運行不同的軟體. 再且, 隨著時間的遷移, 運行在 AGC 的軟體也會隨之升級, 以致於橡後來阿波羅17號上所運行的 AGC 軟體會不同於阿波羅8號上的.

An important part of the guidance system was the Apollo Guidance Computer—or just "AGC" for short.  On any given Apollo mission, there were two AGCs, one for the Command Module, and one for the Lunar Module.  The two AGCs were identical and interchangeable, but they ran different software because the tasks the spacecraft had to perform were different.  Moreover, the software run by the AGC evolved over time, so that the AGC software used in later missions like Apollo 17 differed somewhat from that of earlier missions like Apollo 8.

如果只把 AGC 當作是一台計算機的話, 它在現在的標準來說, 是完全不能滿足性能上的要求.

Considered just as a computer, the AGC was severely underpowered by modern standards.  

# AGC Specifications | AGC 規格說明

* 2048個字的 RAM. 由於每一個"字"佔有15比特位的數據 - 也就是小於兩字節 (16比特位) - 所以整個 RAM 的大小只有3840字節.
* 36,864個字的只讀內存, 相當於69,120字節.
* 每秒最大程度可執行約85,000條CPU指令.
* 尺寸: 24"x12.5"x6".
* 重量: 70.1磅
* 電源供應: 28伏特直流電下通過2.5安電流
* 真正的指引計算機顯示屏及鍵盤

<br />

* 2048 words of RAM.  A "word" was 15 bits of data—therefore just under 2 bytes (16 bits) of data—and so the total RAM was just 3840 bytes.
* 36,864 words of read-only memory, equivalent to 69,120 bytes.
* Maximum of about 85,000 CPU instructions executed per second.
* Dimensions: 24"×12.5"×6".
* Weight:  70.1 pounds.
* Power supply:  2.5A of current at 28V DC
* Real DSKY.

有時候, AGC 會裝備有比自身內部跟好的頭腦, 以致於它比起計算機來說更像是一個計算器. 然而這樣的說辭, 是極度地低估了 AGC 的精密. 舉個例子來說, AGC 說多任務處理型的一台機器, 因此表面上來看, 它可以同時運行多個程序.

It is occasionally quipped—with perhaps greater wit than insight—that the AGC was more like a calculator than a computer.  But to say this is to grossly underestimate the AGC's sophistication. For example, the AGC was multi-tasking, so that it could seemingly run multiple programs simultaneously.

該指引系統的另一重要部分是其顯示屏/鍵盤單元 (Display/Keyboard Unit) - 或簡稱"DSKY". 倘若 AGC 沒有為宇航員提供內置操作方式的話, 它自身就是一台連接有電源的盒子而已. 因此, DSKY 為宇航員提供了訪問 AGC 的接口.

Another important part of the guidance system was the Display/Keyboard unit—or just "DSKY" for short.  The AGC by itself was simply a box with electrical connections, without any built-in way for the astronaut to access it.  The DSKY provided the astronaut with an interface by which to access the AGC.

登月艙有著一個單一的 DSKY, 並且放置在兩位宇航員之間, 以供他們其中一個去操作. 而駕駛艙實際上會有兩個 DSKY 單元. 其中一個只是顯示主控制面板, 而另一個則放置在光學設備旁邊. 該光學設備可用於標記星體的位置或其他航標.

The Lunar Module had a single DSKY, positioned between the two astronauts where it could be operated by either of them.  The Command Module actually had two DSKYs.  One of the CM's DSKYs was only the main control panel, while the other was positioned near the optical equipment used to mark the positions of stars or other landmarks.

# DSKY Specifications DSKY | 規格說明

* 尺寸: 8"x8"x7"
* 重量: 17.5磅

<br />

* Dimensions:  8"×8"×7"
* Weight:  17.5 pounds.

也許, 指引系統最為重要的部分是慣性力測量單元 (Inertial Measurement Unit) - 或簡稱"IMU". IMU 會持續地去檢測艙體的加速度以及行駛角度, 並把這些信息回饋給 AGC. 通過算數處理這些數據, AGC 可以知道艙體的實時方向與位置.

Perhaps the most important part of the guidance system was the Inertial Measurement Unit—or just "IMU" for short.  The IMU continuously kept track of the acceleration and rotation of the spacecraft, and reported this information back to the AGC.  By mathematically processing this data, the AGC could know on a moment-by-moment basis the orientation and position of the spacecraft.

# What this project is for | 項目目標

該虛擬 AGC 項目為我們提供了一個虛擬機, 用於仿真 AGC, DSKY 單元及其他部分的指引系統. 換句話說, 如果該虛擬機 - 我們稱作 yaAGC - 能運行上真實 AGC 上的軟體, 並提供阿波羅任務期間相同的輸入信號, 那麼它就會如同真實 AGC 一樣, 以相同的方式去應答你的輸入. 此外, 該虛擬 AGC 軟體是一個開源的源代碼, 以供我們學習和修改.

The Virtual AGC project provides a virtual machine which simulates the AGC, the DSKY, and some other portions of the guidance system.  In other words, if the virtual machine—which we call yaAGC—is given the same software which was originally run by the real AGCs, and is fed the same input signals encountered by the real AGCs during Apollo missions, then it will responds in the same way as the real AGCs did.  The Virtual AGC software is open source code so that it can be studied or modified.

另外, Virtual AGC 是真實 AGC 的一種電腦模式. 因為, 它並不會去嘗試模仿真正 AGC 其膚淺的行為特徵. 相反, 它會去複製真正 AGC 的內部工作機制. 因此, 舉個例子來說, Virtual AGC 可以使得你在一台桌面 PC 上運行原來 AGC 上所運行的軟體. 在計算機領域的說法就是, Virtual AGC 實際上就是一台模擬器. 它為您提供了一個模擬化的 AGS 以及一個模擬化的 LVDC (正在計畫階段). 所以, 總的來說, "Virtual AGC" 也可稱作是涵蓋所有功能的外掛程序.

Virtual AGC is a computer model of the AGC.  It does not try to mimic the superficial behavioral characteristics of the AGC, but rather to model the AGC's inner workings.  The result is a computer model of the AGC which is itself capable of executing the original Apollo software on (for example) a desktop PC.  In computer terms, Virtual AGC is an emulator.  Virtual AGC also provides an emulated AGS and (in the planning stages) an emulated LVDC.  "Virtual AGC" is a catch-all term that comprises all of these.

Virtual AGC 軟體目前版本已然可以工作在 Linux, Windows XP/Vista/7 以及 Mac OS X 10.3 及其以上 (最好是10.5版本以上) 的系統環境下. 此外, 它至少還可以裝載在 FreeBSD 的部分版本中運行. 然而, 歸因於平常我個人是在 Linux 環境下工作的, 因此, 我會對在 Linux 版本上運行 Virtual AGC 更有信心.

The current version of the Virtual AGC software has been designed to work in Linux, in Windows XP/Vista/7, and in Mac OS X 10.3 or later (but 10.5 or later is best).  It also works in at least some versions of FreeBSD.  However, since I personally work in Linux, I have the most confidence in the Linux version.

在此, 你可以閱讀關於該項目的更多細節:
http://www.ibiblio.org/apollo/index.html

You can read about this project in more detail here:
http://www.ibiblio.org/apollo/index.html

# What this project is not for | 非項目目標

Virtual AGC 既不是一個飛行模擬器, 也不是一個登月模擬器, 甚至也不是一個阿波羅登月艙的行為模擬器或駕駛艙控制面板. (換句話說, 如果你希望你的電腦屏幕能突然地出現一個真正的 LM 控制面板, 那麼你將會為此失望.) 因為, Virtual AGC 僅僅是作為一個模擬的組件而使用. 所以, 我僅提議相關軟件的開發人員去使用它. 當然, 實際上, 部分的開發人員也已經接觸上該項目! 更多信息請觀看 FAQ:
http://www.ibiblio.org/apollo/faq.html

Virtual AGC is not a flight simulator, nor a lunar-lander simulator, nor even a behavioral simulation of the Apollo Lunar Module (LM) or Command-Module (CM) control panels.  (In other words, if you expect a realistic LM control panel to suddenly appear on your computer screen, you'll be disappointed.)  Virtual AGC could be used, however, as a component of such a simulation, and developers of such software are encouraged to do so.  Indeed, some developers already have! See the FAQ for more information:
http://www.ibiblio.org/apollo/faq.html

#  Requirements | 要求

* 所有平臺都要求有 Tcl/Tk.

<br />

* Tcl/Tk is required for all platforms.

## Linux

* 需要 Fedora 內核4或以上版本.
* 需要 Ubuntu 7.04或以上版本.
* 需要 SuSE 10.1或以上版本.
* 32和64位系統已成功通過測試.
* 在 X-Window 系統上, 必須安裝有 xterm 和 gtk+ 庫.
* 你需要一個普通的 gcc C/C++ 編譯鏈, 以及用於 wxWidgets 和 SDL 的開發者工具包 ("dev"或"devel"版本)

<br />

* Requires Fedora Core 4 or later.
* Requires Ubuntu 7.04 or later.
* Requires SuSE 10.1 or later.
* 32 and 64-bit systems have been tested successfully.
* The X-Window system, xterm, and gtk+ libraries must be installed.
* You will need the normal gcc C/C++ compiler toolchain, as well as developer packages ("dev" or "devel") for wxWidgets and SDL.

## Windows

* 需要 XP 或以上版本系統. 32位系統已成功通過測試.
* Vista 及 Windows 7 需要進行一些措施. 例如, 在 Windows 平臺上, 我們期待 Tcl/Tk 的安裝程序會產生一個叫 wish.exe 的文件, 然而在 Vista 版本上, 該文件名字被命名為 wish85.exe. 以致於 Virtual AGC 的部分特性無法正常工作. 因此, 我們需要複製該文件 c:\tcl\bin\wish85.exe 到 c:\tcl\bin\wish.exe 並調用.
* Windows 98 或更舊版本無法使用. Windows 2000 並沒有進行測試.
* 如果選中加載 g++ 編譯器以及編譯選項 - 如果有提供的話 - 你需要一個 MinGW 編譯器.
* 你還需要 Msys 環境, wxWidgets 2.8.9或更高版本, Windows 專用的 POSIX Threads, Windows 專用的 GNU readline 以及源自 MinGW 的正則表達式庫. 該庫名為 libgnurx.

<br />

* Requires XP or later. 32-bit systems have been tested successfully.
* Vista and Windows 7 may need workarounds. For example, on the Windows platform it is expected that the Tcl/Tk installation program will create a file called wish.exe but on Windows Vista the installation program creates a file called wish85.exe. This prevents certain features of Virtual AGC from working. The workaround is to duplicate the file c:\tcl\bin\wish85.exe and call the duplicate c:\tcl\bin\wish.exe.
* Windows 98 or prior are known not to work. Windows 2000 has not been tested.
* You will need the MinGW compiler with the options selected - if offered - of including g++ compiler and make.
* You will also need the Msys environment, wxWidgets 2.8.9 or above, POSIX Threads for Windows, GNU readline for Windows and the regular-expression library from MinGW called libgnurx.

## Mac OS X:

* 需要能用於 Intel 或 PowerPC 的10.4或更高版本.
* 10.2或更舊版本無法使用.

<br />

* Requires 10.4 and later for Intel or PowerPC
* 10.2 or prior are known not to work.

## FreeBSD:

* 需要 FreeBSD 7.2或更高版本.
* 需要 PC-BSD 7.1或更高版本.
* 你需要安裝 wxWidgets 2.8.9 和 GNU readline 6.0 到 /usr/local 目錄下.
* 必須安裝有 libSDL.

<br />

* Requires FreeBSD 7.2 or later.
* Requires PC-BSD 7.1 or later.
* You will need to install wxWidgets 2.8.9, GNU readline 6.0 into /usr/local.
* libSDL must be installed

## OpenSolaris

* 需要 OpenSolaris 0811版本.
* 該代碼僅確認可在該平臺上運行.
* 需要安裝 SUNWgnome-common-devel, SUNWGtk, SUNWxorg-headers, FSWxorg-headers, SUNWncurses, SUNWtcl, SUNWtk 和 SUNWlibsdl.
* 需要安裝 GNU readline 6.0, wxWidgets 2.8.9 (使用命令"configure --disable-shared"進行編譯) 和 Allegro 4.2.2 (使用命令"configure --enable-shared=no --enable-static=yes"進行編譯) , 並把它們放置在 /usr/local/bin 或為 /usr/local/bin/wx-config 建立快捷方式.

更多信息在 http://www.ibiblio.org/apollo/download.html#Build

<br />

* Requires OpenSolaris 0811.
* The code is only confirmed to partially work on this platform.
* You will need SUNWgnome-common-devel, SUNWGtk, SUNWxorg-headers, FSWxorg-headers, SUNWncurses, SUNWtcl, SUNWtk and SUNWlibsdl
* You will also need GNU readline 6.0, wxWidgets 2.8.9 (with "configure --disable-shared"), Allegro 4.2.2 (with "configure --enable-shared=no --enable-static=yes") and to put /usr/local/bin and/or /usr/local/bin/wx-config linked into your PATH.

More information at http://www.ibiblio.org/apollo/download.html#Build

# Building the Virtual AGC software | 構建該虛擬 AGC 軟體

    $ cd yaAGC
    $ make

## Linux

在命令行通過下面的指令去解壓 development-snapshot 包:

From the command line unpack the development-snapshot tarball as follows:

    tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2

解壓後可以看到有一個新的文件夾叫 "yaAGC". 然後, 構建該程序:

After unpacking there will be a new directory called "yaAGC". To build the program:

    $ cd yaAGC
    $ make

不要進行"configure"和"make install". 在裏面你可以看到有一段'configure'腳本, 它是用於配置和構建一些現在已然廢除的程序. 因此, 不管你運行與否且是否成功, 都不會產生任何的影響.

Do not "configure" and do not "make install". While there is a 'configure' script provided, it is presently used only for setting up builds of a couple of now-obsoleted programs, and it does not matter whether you run it or not nor whether it succeeds or fails.

當你構建完後, 你會發現創建有一個文件夾 yaAGC/VirtualAGC/temp/lVirtualAGC/.

You will find that this has created a directory yaAGC/VirtualAGC/temp/lVirtualAGC/.

為了匹配安裝程序的默認配置, 你需要執行下面的指令:

To match the default setup of the installer program execute the following:

    mv yaAGC/VirtualAGC/temp/lVirtualAGC ~/VirtualAGC

當然, 你還可以創建一個命名為"Virtual AGC"的桌面圖標, 用於指向 *~/VirtualAGC/bin/VirtualAGC*. 該圖片一般會尋找 *~/VirtualAGC/bin/ApolloPatch2.png* 作為其圖像.

You can make a desktop icon called "Virtual AGC" that links to *~/VirtualAGC/bin/VirtualAGC*. The image normally used for the desktop icon is found at *~/VirtualAGC/bin/ApolloPatch2.png*.

如果你嘗試使用 ACA 模擬器 (操縱杆) 的過程中, 它並不能工作起來的話, 你可以在這裡找到配置的一些相關信息:
http://www.ibiblio.org/apollo/yaTelemetry.html#Joystick_configuration_for_use_with_the

If you try to use the ACA simulation (joystick) and it doesn't work you can find some information on configuring it here:
http://www.ibiblio.org/apollo/yaTelemetry.html#Joystick_configuration_for_use_with_the

## Windows

通過運行 Msys 來執行一條 shell 命令, 並進入到你的根目錄.

Run Msys to bring up a command shell and enter your home directory.

使用該命令安裝相關的 SDL 庫.

Install the SDL library with this command:

    make install-sdl prefix=/usr/local

所有 Virtual AGC 需要構建的軟體都會被安裝在 /usr/local 下, 因此, 最終我們會習慣有這些子文件, 如 /usr/local/bin, /usr/local/include, /usr/local/lib 等. Virtual AGC 的 makefile 文件都採用硬編碼的方式, 因為, 它們都以這作為其安裝路徑. 注意的是, 通過 Vitual AGC , 你所創建的二進制文件並不是安裝在 /usr/local 下.

All software needed to build Virtual AGC will be installed under /usr/local, so eventually it will be populated with sub-directories such as /usr/local/bin, /usr/local/include, /usr/local/lib, and so on.  The Virtual AGC makefiles are hard-coded to assume these installation locations.  Note, the Virtual AGC binaries you are going to create are not installed under /usr/local.

因為, 目前 Virtual AGC 的二進制包通常是使用 wxWidgets 2.8.9 進行構建, 因此, 版本 2.8.9 是一個較為安全的選擇. 首先, 你需要把包解壓至根目錄, 然後輸入'cd'進入所創建的文件夾, 並按步執行"./configure", "make" 以及 "make install"命令. "configure"這一步需要接收不同的命令行參數, 如選擇 unicode 還是 ansi, static linking 還是 dynamic linking 等. 可是, 我們会发现, 默認的參數運行起來貌似也沒有問題.

At present, Virtual AGC binary packages are always built with wxWidgets 2.8.9, so 2.8.9 is a safe choice.  Unpack the tarball in your home directory, 'cd' into the directory this creates, and then do "./configure", "make", and "make install".  The "configure" step will accept various command-line options that select unicode vs. ansi, static linking vs. dynamic linking, etc., but the default options seem to work fine.

安裝 Windows 專用的 POSIX Threads ("pthreads"). 你可以通過解壓源軟體包, 'cd'進入所創建的文件夾, 並運行命令"make clean GC-inlined"來進行安裝. 安裝期間所建立的不同文件, 你需要像以下這樣, 把它們拷貝到 /usr/local: 拷貝 \*.dll 到 /usr/local/bin; 拷貝 \*.h into /usr/local/include; 拷貝那個獨立的 libpthread\*.a 文件 複製到 /usr/local/lib 並重新命名為 libpthread.a.

Install POSIX Threads for Windows ("pthreads").  You can do this by unpacking the source tarball, 'cd' into the directory it creates, then run the command "make clean GC-inlined".  This creates various files that you should copy into /usr/local as follows:  copy \*.dll into /usr/local/bin; copy \*.h into /usr/local/include; copy the single libpthread\*.a file created into /usr/local/lib and rename it libpthread.a.

Install GNU readline for Windows. You should find zipfiles of both "binaries" and "developer files" are available for download.  They should both be downloaded and unpacked into /usr/local.  (I.e., each zipfile contains directories like bin/, include/, lib/, and so on, and we want these to be merged into /usr/local/bin/, usr/local/include/, etc.)

Install a regular-expression library.  The MinGW project has a "contributed" regex library ("libgnurx") that you can use.  Download both the "bin" and "dev" tarballs and unpack them into /usr/local.

If all of this was done correctly you can build the Virtual AGC as follows:

Unpack the development tarball in your home directory:

    tar -xjvf yaAGC-dev-YYYYMMDD.tar.bz2

Build it:

    make -C yaAGC WIN32=yes

On Windows 7  (but not on XP) it is also necessary  to copy c:\MinGW\bin\mingwm10.dll to yaAGC/VirtualAGC/temp/lVirtualAGC/Resources/.  

This will create a directory yaAGC/VirtualAGC/temp/lVirtualAGC/ which is the "installation directory".  This directory is relocatable and need to remain within the Msys environment so you can move it wherever you like.  Regardless you really need to create a desktop icon in order to run the program.  The desktop icon should point to lVirtualAGC\bin\VirtualAGC.exe as the executable, and should use a "starting directory" of lVirtualAGC\Resources\.  The graphic normally used for the desktop icon is ApolloPatch2.jpg in the lVirtualAGC\Resources directory.

## Mac OS X

From the command line unpack the development-snapshot tarball as follows:

    tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2

Get the Terminator application's dmg file:
https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/jessies/terminator-26.159.6816.zip

Open the Terminator dmg file and drag the Terminator application to the working directory in which you created yaAGC/ above.

From a command line in that working directory, make a tarball from Terminator.app:

    tar -cjvf Terminator.app.tar.bz2 Terminator.app

Once you have the tarball, you can delete the Terminator app and its dmg file.

From the working directory (not from within the yaAGC/ directory) build Virtual AGC:

    make -C yaAGC MACOSX=yes


In the  folder yaAGC/VirtualAGC/temp/ you will now find the VirtualAGC application.

Drag the VirtualAGC application from yaAGC/VirtualAGC/temp/ to the desktop.

## FreeBSD

From the command line unpack the development-snapshot tarball as follows:
    tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2

After unpacking there will be a new directory called "yaAGC". To build the program:

    gmake FREEBSD=yes

Do not "configure" and do not "gmake install".

You will find that this has created a directory yaAGC/VirtualAGC/temp/lVirtualAGC/.  

To match the default setup of the installer program execute the following:

    mv yaAGC/VirtualAGC/temp/lVirtualAGC ~/VirtualAGC

You can make a desktop icon called "Virtual AGC" that links to /VirtualAGC/bin/VirtualAGC. The image normally used for the desktop icon is found at /VirtualAGC/bin/ApolloPatch2.png.

If you try to use the ACA simulation (joystick) and it doesn't work you can find some information on configuring it here:
http://www.ibiblio.org/apollo/yaTelemetry.html#Joystick_configuration_for_use_with_the

## Solaris

Unpack the Virtual AGC snapshot tarball:

    tar --bzip2 -xf yaAGC-dev-YYYYMMDD.tar.bz2

Open the yaAGC/ directory and build:

    make SOLARIS=yes

Do not "configure" and do not "gmake install".

You'll find that this has created a directory yaAGC/VirtualAGC/temp/lVirtualAGC/.

To match the default setup of the installer program execute the following:

    mv yaAGC/VirtualAGC/temp/lVirtualAGC ~/VirtualAGC

You can make a desktop icon called "Virtual AGC" that links to /VirtualAGC/bin/VirtualAGC. The image normally used for the desktop icon is found at /VirtualAGC/bin/ApolloPatch2.png.

Unfortunately the ACA simulation (joystick) programs do not work in this environment.

# Endnotes

This Readme was created from information contained in the main project website here:
http://www.ibiblio.org/apollo/index.html

The project website was created by Ronald Burkey. The first version of this Readme was compiled by Shane Coughlan.
