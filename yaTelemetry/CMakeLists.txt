if(NOT wxWidgets_FOUND)
  return()
endif()

set(_s ${PROJECT_SOURCE_DIR}/yaAGC)
set(SOURCESc ${_s}/agc_utilities.c ${_s}/DecodeDigitalDownlink.c ${_s}/agc_engine.c ${_s}/Backtrace.c ${_s}/random.c ${_s}/SocketAPI.c)

add_executable(yaTelemetry yaTelemetry.cpp ${SOURCESc})

if(wxWidgets_INCLUDE_DIRS)
  target_include_directories(yaTelemetry PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_compile_definitions(yaTelemetry PRIVATE ${wxWidgets_DEFINITIONS})
else()
  target_compile_options(yaTelemetry PRIVATE ${wxWidgets_FLAGS})
endif()
target_link_libraries(yaTelemetry PRIVATE ${wxWidgets_LIBRARIES})

if(WIN32)
  target_link_libraries(yaTelemetry PRIVATE ${WINSOCK_LIBRARIES})
endif()
