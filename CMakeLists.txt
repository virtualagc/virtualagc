cmake_minimum_required(VERSION 3.14...3.21)
project(virtualAGC
LANGUAGES C CXX
HOMEPAGE_URL "https://github.com/virtualagc/virtualagc")

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(NVER \\\"2020-12-24\\\")


find_package(Threads)

if(WIN32)
  set(WINSOCK_LIBRARIES wsock32)
endif()

add_subdirectory(yaAGC)
add_subdirectory(yaASM)
add_subdirectory(yaDSKY2)
add_subdirectory(yaLEMAP)
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

  set(CMAKE_INSTALL_PREFIX "${HOME}/VirtualAGC" CACHE PATH "install prefix" FORCE)
endif()
