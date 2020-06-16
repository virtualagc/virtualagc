cmake_minimum_required(VERSION 3.12)
project(virtualAGC LANGUAGES C CXX)

# this helps linters e.g. Visual Studio Intellicode work properly
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(NVER \\\"2019-09-22\\\")

add_subdirectory(yaAGC)
add_subdirectory(yaDSKY2)
add_subdirectory(yaYUL)
