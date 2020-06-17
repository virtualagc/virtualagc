cmake_minimum_required(VERSION 3.12)
project(virtualAGC LANGUAGES C CXX)

# this helps linters e.g. Visual Studio Intellicode work properly
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(NVER \\\"2019-09-22\\\")

add_subdirectory(yaAGC)
add_subdirectory(yaASM)
add_subdirectory(yaDSKY2)
add_subdirectory(yaLVDC)
add_subdirectory(yaYUL)

## install to ~/VirtualAGC upon:
# cmake --build build --target install

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/VirtualAGC" CACHE PATH "..." FORCE)
endif()
