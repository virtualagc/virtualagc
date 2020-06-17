set(_libagc_src agc_engine_init.c agc_engine.c agc_utilities.c rfopen.c
Backtrace.c SocketAPI.c DecodeDigitalDownlink.c)

set(_agc_src main.c agc_cli.c agc_simulator.c agc_debugger.c
agc_gdbmi.c agc_disassembler.c agc_help.c nbfgets.c agc_symtab.c
NormalizeSourceName.c ${CMAKE_CURRENT_SOURCE_DIR}/../Tools/checkdec.c Backtrace.c)

find_package(Threads)

add_library(libyaAGC ${_libagc_src})

add_executable(yaAGC ${_agc_src})
target_compile_definitions(yaAGC PRIVATE NVER="${NVER}" NOREADLINE="yes" GDBMI)
target_link_libraries(yaAGC libyaAGC m)
if(Threads_FOUND)
  target_link_libraries(yaAGC Threads::Threads)
endif()

if(WIN32)
  target_sources(yaAGC PRIVATE regex.c random.c)
  target_link_libraries(yaAGC wsock32)
endif()

install(TARGETS yaAGC)
