add_executable(yaOBC yaOBC.c)
target_include_directories(yaOBC PRIVATE ${PROJECT_SOURCE_DIR}/enet/include)
target_link_libraries(yaOBC PRIVATE m)

add_executable(enetHost enetHost.c)
target_include_directories(enetHost PRIVATE ${PROJECT_SOURCE_DIR}/enet/include)

if(Threads_FOUND)
  target_link_libraries(enetHost PRIVATE Threads::Threads)
  target_link_libraries(yaOBC PRIVATE Threads::Threads)
endif()

if(WIN32)
  target_link_libraries(enetHost PRIVATE ${WINSOCK_LIBRARIES})
  target_link_libraries(yaOBC PRIVATE ${WINSOCK_LIBRARIES})
endif(WIN32)

install(TARGETS enetHost yaOBC)
