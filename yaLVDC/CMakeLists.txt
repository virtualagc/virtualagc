include(CheckIncludeFile)

set(SOURCE debug.c parseCommandLineArguments.c readAssemblies.c runOneInstruction.c yaLVDC.c
gdbInterface.c processInterruptsAndIO.c readWriteCore.c virtualWire.c)

check_include_file(time.h HAVE_TIME_H)

add_executable(yaLVDC ${SOURCE})
target_compile_definitions(yaLVDC PRIVATE HAVE_TIME_H=${HAVE_TIME_H})
if(WIN32)
  target_link_libraries(yaLVDC PRIVATE ${WINSOCK_LIBRARIES})
endif(WIN32)

install(TARGETS yaLVDC)
