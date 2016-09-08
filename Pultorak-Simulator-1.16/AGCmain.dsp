# Microsoft Developer Studio Project File - Name="AGCmain" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=AGCmain - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "AGCmain.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "AGCmain.mak" CFG="AGCmain - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "AGCmain - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "AGCmain - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "AGCmain - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "AGCmain - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /FR /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "AGCmain - Win32 Release"
# Name "AGCmain - Win32 Debug"
# Begin Source File

SOURCE=.\ADR.cpp
# End Source File
# Begin Source File

SOURCE=.\ADR.h
# End Source File
# Begin Source File

SOURCE=.\AGCmain.cpp
# End Source File
# Begin Source File

SOURCE=.\ALU.cpp
# End Source File
# Begin Source File

SOURCE=.\ALU.h
# End Source File
# Begin Source File

SOURCE=.\BUS.cpp
# End Source File
# Begin Source File

SOURCE=.\BUS.h
# End Source File
# Begin Source File

SOURCE=.\CLK.cpp
# End Source File
# Begin Source File

SOURCE=.\CLK.h
# End Source File
# Begin Source File

SOURCE=.\CPM.cpp
# End Source File
# Begin Source File

SOURCE=.\CPM.h
# End Source File
# Begin Source File

SOURCE=.\CRG.cpp
# End Source File
# Begin Source File

SOURCE=.\CRG.h
# End Source File
# Begin Source File

SOURCE=.\CTR.cpp
# End Source File
# Begin Source File

SOURCE=.\CTR.h
# End Source File
# Begin Source File

SOURCE=.\DSP.cpp
# End Source File
# Begin Source File

SOURCE=.\DSP.h
# End Source File
# Begin Source File

SOURCE=.\INP.cpp
# End Source File
# Begin Source File

SOURCE=.\INP.h
# End Source File
# Begin Source File

SOURCE=.\INT.cpp
# End Source File
# Begin Source File

SOURCE=.\INT.h
# End Source File
# Begin Source File

SOURCE=.\ISD.cpp
# End Source File
# Begin Source File

SOURCE=.\ISD.h
# End Source File
# Begin Source File

SOURCE=.\KBD.cpp
# End Source File
# Begin Source File

SOURCE=.\KBD.h
# End Source File
# Begin Source File

SOURCE=.\MBF.cpp
# End Source File
# Begin Source File

SOURCE=.\MBF.h
# End Source File
# Begin Source File

SOURCE=.\MEM.cpp
# End Source File
# Begin Source File

SOURCE=.\MEM.h
# End Source File
# Begin Source File

SOURCE=.\MON.cpp
# End Source File
# Begin Source File

SOURCE=.\MON.h
# End Source File
# Begin Source File

SOURCE=.\OUT.cpp
# End Source File
# Begin Source File

SOURCE=.\OUT.h
# End Source File
# Begin Source File

SOURCE=.\PAR.cpp
# End Source File
# Begin Source File

SOURCE=.\PAR.h
# End Source File
# Begin Source File

SOURCE=.\reg.cpp
# End Source File
# Begin Source File

SOURCE=.\reg.h
# End Source File
# Begin Source File

SOURCE=.\SCL.cpp
# End Source File
# Begin Source File

SOURCE=.\SCL.h
# End Source File
# Begin Source File

SOURCE=.\SEQ.cpp
# End Source File
# Begin Source File

SOURCE=.\SEQ.h
# End Source File
# Begin Source File

SOURCE=.\TPG.cpp
# End Source File
# Begin Source File

SOURCE=.\TPG.h
# End Source File
# End Target
# End Project
