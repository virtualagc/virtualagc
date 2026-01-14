add_executable(yaOBC yaOBC.c)
target_include_directories(yaOBC PRIVATE ${PROJECT_SOURCE_DIR}/enet/include)
target_link_libraries(yaOBC PRIVATE enet Threads::Threads ${WINSOCK_LIBRARIES} $<$<NOT:$<BOOL:${MSVC}>>:m>)

add_executable(enetHost enetHost.c)
target_include_directories(enetHost PRIVATE ${PROJECT_SOURCE_DIR}/enet/include)
target_link_libraries(enetHost PRIVATE enet Threads::Threads ${WINSOCK_LIBRARIES})


install(TARGETS enetHost yaOBC)
