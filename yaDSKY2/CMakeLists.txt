if(NOT wxWidgets_FOUND)
  return()
endif()

set(SOURCES yaDSKY2.cpp)

set(SOURCESc
${PROJECT_SOURCE_DIR}/yaAGC/agc_utilities.c
${PROJECT_SOURCE_DIR}/yaAGC/agc_engine.c
${PROJECT_SOURCE_DIR}/yaAGC/Backtrace.c
${PROJECT_SOURCE_DIR}/yaAGC/random.c
${PROJECT_SOURCE_DIR}/yaAGC/SocketAPI.c
${PROJECT_SOURCE_DIR}/yaAGC/rfopen.c)

add_executable(yaDSKY2 ${SOURCES} ${SOURCESc})
target_include_directories(yaDSKY2 PRIVATE ${PROJECT_SOURCE_DIR}/yaAGC)
target_compile_definitions(yaDSKY2 PRIVATE NVER="${NVER}")

if(WIN32)
  target_link_libraries(yaDSKY2 PRIVATE ${WINSOCK_LIBRARIES})
endif()

if(wxWidgets_INCLUDE_DIRS)
  target_include_directories(yaDSKY2 PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_compile_definitions(yaDSKY2 PRIVATE ${wxWidgets_DEFINITIONS})
else()
  target_compile_options(yaDSKY2 PRIVATE ${wxWidgets_FLAGS})
endif()
target_link_libraries(yaDSKY2 PRIVATE ${wxWidgets_LIBRARIES})


# --- install

install(TARGETS yaDSKY2)

# must have trailing /
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION bin
  FILES_MATCHING PATTERN "*.jpg" PATTERN "*.png")
