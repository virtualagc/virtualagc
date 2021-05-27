find_package(wxWidgets COMPONENTS gl core base)
if(NOT wxWidgets_FOUND)
  find_program(wxcfg NAMES wx-config)
  if(NOT wxcfg)
    return()
  endif()
endif()

set(APPNAME yaDSKY2)

set(SOURCES ${APPNAME}.cpp)

set(SOURCESc
${PROJECT_SOURCE_DIR}/yaAGC/agc_utilities.c
${PROJECT_SOURCE_DIR}/yaAGC/agc_engine.c
${PROJECT_SOURCE_DIR}/yaAGC/Backtrace.c
${PROJECT_SOURCE_DIR}/yaAGC/random.c
${PROJECT_SOURCE_DIR}/yaAGC/SocketAPI.c
${PROJECT_SOURCE_DIR}/yaAGC/rfopen.c)

add_executable(${APPNAME} ${SOURCES} ${SOURCESc})
target_include_directories(${APPNAME} PRIVATE ${PROJECT_SOURCE_DIR}/yaAGC)
target_compile_definitions(${APPNAME} PRIVATE NVER="${NVER}")

if(WIN32)
  target_link_libraries(${APPNAME} PRIVATE ${WINSOCK_LIBRARIES})
endif()

if(wxWidgets_FOUND)
  target_include_directories(${APPNAME} PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_link_libraries(${APPNAME} PRIVATE ${wxWidgets_LIBRARIES})
  target_compile_definitions(${APPNAME} PRIVATE ${wxWidgets_DEFINITIONS})
else()
  # fallback in case CMake FindWx isn't up to date
  execute_process(COMMAND bash -c "wx-config --cflags"
  OUTPUT_VARIABLE wxWidgets_DEFINITIONS
  OUTPUT_STRIP_TRAILING_WHITESPACE)
  separate_arguments(wxWidgets_DEFINITIONS)
  target_compile_options(${APPNAME} PRIVATE ${wxWidgets_DEFINITIONS})

  execute_process(COMMAND bash -c "wx-config --libs"
  OUTPUT_VARIABLE wxWidgets_LIBRARIES
  OUTPUT_STRIP_TRAILING_WHITESPACE)
  separate_arguments(wxWidgets_LIBRARIES)
  target_link_libraries(${APPNAME} PRIVATE ${wxWidgets_LIBRARIES})
endif()

# --- install

install(TARGETS ${APPNAME})

# must have trailing /
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION bin
  FILES_MATCHING PATTERN "*.jpg" PATTERN "*.png")
