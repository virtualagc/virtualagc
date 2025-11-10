add_executable(yaUplinkBlock1 yaUplinkBlock1.c
${PROJECT_SOURCE_DIR}/yaAGCb1/SocketAPI.c ${PROJECT_SOURCE_DIR}/yaAGCb1/agc_utilities.c)
target_link_libraries(yaUplinkBlock1 PRIVATE ${CURSES_LIBRARIES} ${WINSOCK_LIBRARIES})
target_include_directories(yaUplinkBlock1 PRIVATE ${CURSES_INCLUDE_DIRS})

install(TARGETS yaUplinkBlock1)
