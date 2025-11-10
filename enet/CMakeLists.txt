add_library(enet OBJECT callbacks.c compress.c host.c list.c packet.c peer.c protocol.c unix.c win32.c)
target_include_directories(enet PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
