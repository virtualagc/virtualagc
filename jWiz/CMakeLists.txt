if(NOT wxWidgets_FOUND)
  return()
endif()

set(_s ${PROJECT_SOURCE_DIR}/yaAGC)
set(SOURCESc ${_s}/agc_utilities.c ${_s}/DecodeDigitalDownlink.c ${_s}/agc_engine.c ${_s}/Backtrace.c ${_s}/random.c ${_s}/SocketAPI.c)

add_executable(jWiz jWiz.cpp ${SOURCESc})

if(wxWidgets_INCLUDE_DIRS)
  target_include_directories(jWiz PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_compile_definitions(jWiz PRIVATE ${wxWidgets_DEFINITIONS})
else()
  target_compile_options(jWiz PRIVATE ${wxWidgets_FLAGS})
endif()
target_link_libraries(jWiz PRIVATE ${wxWidgets_LIBRARIES})

if(WIN32)
  target_link_libraries(jWiz PRIVATE ${WINSOCK_LIBRARIES})
endif()
