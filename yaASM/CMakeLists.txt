cmake_minimum_required(VERSION 3.12)
project(virtualASM LANGUAGES C)
enable_testing()

add_executable(yaASM yaASM.c)
target_link_libraries(yaASM m)

add_test(NAME ASM:assemble COMMAND $<TARGET_FILE:yaASM> --input=${CMAKE_CURRENT_SOURCE_DIR}/Test.obc)

install(TARGETS yaASM)
