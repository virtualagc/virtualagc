set(enet_src callbacks.c compress.c host.c list.c packet.c peer.c protocol.c unix.c win32.c)

target_sources(yaOBC PRIVATE ${enet_src})
target_sources(enetHost PRIVATE ${enet_src})
