cmake_minimum_required(VERSION 3.12)
project(yaLVDC LANGUAGES C)

set(SOURCE debug.c parseCommandLineArguments.c readAssemblies.c runOneInstruction.c yaLVDC.c
gdbInterface.c processInterruptsAndIO.c readWriteCore.c virtualWire.c)

add_executable(yaLVDC ${SOURCE})

install(TARGETS yaLVDC)
