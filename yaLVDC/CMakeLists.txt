include(CheckIncludeFile)

set(SOURCE debug.c parseCommandLineArguments.c readAssemblies.c runOneInstruction.c yaLVDC.c
gdbInterface.c processInterruptsAndIO.c readWriteCore.c virtualWire.c)

check_include_file(time.h HAVE_TIME_H)

add_executable(yaLVDC ${SOURCE})
target_compile_definitions(yaLVDC PRIVATE HAVE_TIME_H=${HAVE_TIME_H} $<$<BOOL:${WIN32}>:HAS_ERRNO_H>)
target_link_libraries(yaLVDC PRIVATE ${WINSOCK_LIBRARIES})

if(MSVC)
  check_symbol_exists(strncasecmp "string.h" HAVE_STRNCASECMP)
  if(NOT HAVE_STRNCASECMP)
    target_compile_definitions(yaLVDC PRIVATE strcasecmp=_stricmp strncasecmp=_strnicmp)
  endif()
endif()

install(TARGETS yaLVDC)
