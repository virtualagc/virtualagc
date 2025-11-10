add_executable(yaOBC yaOBC.c)
target_include_directories(yaOBC PRIVATE ${PROJECT_SOURCE_DIR}/enet/include)
target_link_libraries(yaOBC PRIVATE $<$<NOT:$<BOOL:${MSVC}>>:m>)

add_executable(enetHost enetHost.c)
target_include_directories(enetHost PRIVATE ${PROJECT_SOURCE_DIR}/enet/include)

if(Threads_FOUND)
  target_link_libraries(enetHost PRIVATE Threads::Threads ${WINSOCK_LIBRARIES})
  target_link_libraries(yaOBC PRIVATE Threads::Threads ${WINSOCK_LIBRARIES})
endif()

install(TARGETS enetHost yaOBC)
