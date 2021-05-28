add_executable(yaLEMAP yaLEMAP.c
${PROJECT_SOURCE_DIR}/yaYUL/SymbolTable.c ${PROJECT_SOURCE_DIR}/yaYUL/strcmpEBCDIC.c)
target_link_libraries(yaLEMAP PRIVATE m)

add_executable(binLEMAP binLEMAP.c)

install(TARGETS binLEMAP yaLEMAP)
