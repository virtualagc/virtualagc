add_executable(yaAGS mainAGS.c symbol_table.c nbfgets.c Backtrace.c
  ${PROJECT_SOURCE_DIR}/yaAGC/NormalizeSourceName.c)
target_link_libraries(yaAGS PRIVATE libyaAGS libyaAGC Threads::Threads m)
target_include_directories(yaAGS PRIVATE ${PROJECT_SOURCE_DIR}/yaAGC)
target_compile_definitions(yaAGS PRIVATE NVER="${NVER}")
if(WIN32)
  target_link_libraries(yaAGS PRIVATE regex ${WINSOCK_LIBRARIES})
endif(WIN32)
if(APPLE OR WIN32)
  target_compile_definitions(yaAGS PRIVATE STDC_HEADERS)
endif()


add_library(libyaAGS aea_engine_init.c aea_engine.c DebuggerHookAGS.c SocketAPI_AGS.c)
target_include_directories(libyaAGS PRIVATE ${PROJECT_SOURCE_DIR}/yaAGC)

install(TARGETS yaAGS)
