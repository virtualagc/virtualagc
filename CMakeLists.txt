cmake_minimum_required(VERSION 3.14...3.21)
project(virtualAGC
LANGUAGES C CXX
HOMEPAGE_URL "https://github.com/virtualagc/virtualagc")

include(CTest)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(NVER \\\"2020-12-24\\\")


find_package(Threads)

if(WIN32)
  set(WINSOCK_LIBRARIES wsock32 ws2_32 Iphlpapi winmm)
endif()

add_subdirectory(Tools)
add_subdirectory(Luminary099)

add_subdirectory(yaAGC)
add_subdirectory(yaAGS)
add_subdirectory(yaASM)
add_subdirectory(yaDSKY2)
add_subdirectory(yaLEMAP)
add_subdirectory(yaLVDC)
add_subdirectory(yaOBC)
add_subdirectory(yaYUL)
add_subdirectory(yaUniverse)

add_subdirectory(enet)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/VirtualAGC" CACHE PATH "install prefix" FORCE)
endif()
