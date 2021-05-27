cmake_minimum_required(VERSION 3.14...3.21)
project(virtualAGC
LANGUAGES C CXX
HOMEPAGE_URL "https://github.com/virtualagc/virtualagc")

include(CTest)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(NVER \\\"2020-12-24\\\")


find_package(Threads)
find_package(Curses)

function(wx_config)

find_program(wxcfg NAMES wx-config)
if(NOT wxcfg)
  return()
endif()

execute_process(COMMAND sh -c "wx-config --cflags"
OUTPUT_VARIABLE wxWidgets_FLAGS
OUTPUT_STRIP_TRAILING_WHITESPACE
RESULT_VARIABLE err
)
if(NOT err EQUAL 0)
  message(STATUS "${err}")
  return()
endif()
separate_arguments(wxWidgets_FLAGS)

execute_process(COMMAND sh -c "wx-config --libs"
OUTPUT_VARIABLE wxWidgets_LIBRARIES
OUTPUT_STRIP_TRAILING_WHITESPACE
RESULT_VARIABLE err
)
if(NOT err EQUAL 0)
  message(STATUS "${err}")
  return()
endif()
separate_arguments(wxWidgets_LIBRARIES)

message(STATUS "wxWidgets libs: ${wxWidgets_LIBRARIES}")

set(wxWidgets_FLAGS ${wxWidgets_FLAGS} PARENT_SCOPE)
set(wxWidgets_LIBRARIES ${wxWidgets_LIBRARIES} PARENT_SCOPE)
set(wxWidgets_FOUND true PARENT_SCOPE)

endfunction(wx_config)

find_package(wxWidgets COMPONENTS gl core base)
if(NOT wxWidgets_FOUND)
  wx_config()
endif()

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
add_subdirectory(yaTelemetry)
add_subdirectory(yaYUL)
add_subdirectory(yaUniverse)
add_subdirectory(yaUplinkBlock1)
add_subdirectory(jWiz)

add_subdirectory(enet)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/VirtualAGC" CACHE PATH "install prefix" FORCE)
endif()
